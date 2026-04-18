.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/io_ordering.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================================
Thứ tự ghi I/O vào các địa chỉ được ánh xạ bộ nhớ
==============================================

Trên một số nền tảng, cái gọi là I/O ánh xạ bộ nhớ được sắp xếp yếu.  Trên đó
nền tảng, người viết trình điều khiển có trách nhiệm đảm bảo rằng I/O ghi vào
địa chỉ được ánh xạ bộ nhớ trên thiết bị của họ sẽ đến theo thứ tự dự định.  Đây là
thường được thực hiện bằng cách đọc thiết bị 'an toàn' hoặc thanh ghi cầu nối, gây ra I/O
chipset để xóa dữ liệu đang chờ xử lý vào thiết bị trước khi bất kỳ lần đọc nào được đăng.  A
người lái xe thường sử dụng kỹ thuật này ngay trước khi ra khỏi đường
phần quan trọng của mã được bảo vệ bởi spinlocks.  Điều này sẽ đảm bảo rằng
lần ghi tiếp theo vào không gian I/O chỉ đến sau tất cả lần ghi trước đó (giống như
rào cản bộ nhớ op, mb(), chỉ đối với I/O).

Một ví dụ cụ thể hơn từ trình điều khiển thiết bị giả định ::

		...
CPU A: spin_lock_irqsave(&dev_lock, flags)
	CPU A: val = readl(my_status);
	CPU A: ...
	CPU A: writel(newval, ring_ptr);
	CPU A: spin_unlock_irqrestore(&dev_lock, flags)
		...
CPU B: spin_lock_irqsave(&dev_lock, flags)
	CPU B: val = readl(my_status);
	CPU B: ...
	CPU B: writel(newval2, ring_ptr);
	CPU B: spin_unlock_irqrestore(&dev_lock, flags)
		...

Trong trường hợp trên, thiết bị có thể nhận newval2 trước khi nhận newval,
có thể gây ra vấn đề.  Tuy nhiên, việc sửa nó rất dễ dàng ::

		...
CPU A: spin_lock_irqsave(&dev_lock, flags)
	CPU A: val = readl(my_status);
	CPU A: ...
	CPU A: writel(newval, ring_ptr);
	CPU A: (void)readl(safe_register); /* có thể là một thanh ghi cấu hình? */
	CPU A: spin_unlock_irqrestore(&dev_lock, flags)
		...
CPU B: spin_lock_irqsave(&dev_lock, flags)
	CPU B: val = readl(my_status);
	CPU B: ...
	CPU B: writel(newval2, ring_ptr);
	CPU B: (void)readl(safe_register); /* có thể là một thanh ghi cấu hình? */
	CPU B: spin_unlock_irqrestore(&dev_lock, flags)

Ở đây, việc đọc từ safe_register sẽ làm cho chipset I/O xóa bất kỳ
đang chờ ghi trước khi thực sự đăng nội dung đọc lên chipset, ngăn chặn
có thể bị hỏng dữ liệu.
