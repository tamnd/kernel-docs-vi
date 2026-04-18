.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/porting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
Chuyển
=======

Lấy từ kho lưu trữ danh sách tại ZZ0000ZZ

Định nghĩa ban đầu
-------------------

Các định nghĩa ký hiệu sau đây phụ thuộc vào việc bạn biết bản dịch
__virt_to_phys() dành cho máy của bạn.  Macro này chuyển đổi thông qua
địa chỉ ảo thành địa chỉ vật lý.  Thông thường, nó chỉ đơn giản là:

vật lý = đức hạnh - PAGE_OFFSET + PHYS_OFFSET


Ký hiệu giải nén
--------------------

ZTEXTADDR
	Địa chỉ bắt đầu của bộ giải nén.  Chẳng ích gì khi nói về
	địa chỉ ảo hoặc vật lý ở đây, vì MMU sẽ tắt vào lúc
	thời điểm bạn gọi mã giải nén.  Bạn thường gọi
	kernel tại địa chỉ này để bắt đầu khởi động.  Cái này không có
	được đặt trong RAM, nó có thể ở dạng flash hoặc dạng chỉ đọc hoặc
	phương tiện có địa chỉ đọc-ghi.

ZBSSADDR
	Địa chỉ bắt đầu của vùng làm việc được khởi tạo bằng 0 cho bộ giải nén.
	Điều này chắc chắn đang trỏ tới RAM.  Bộ giải nén sẽ không khởi tạo
	cái này dành cho bạn.  Một lần nữa, MMU sẽ tắt.

ZRELADDR
	Đây là địa chỉ nơi kernel giải nén sẽ được ghi,
	và cuối cùng bị xử tử.  Ràng buộc sau đây phải hợp lệ:

__virt_to_phys(TEXTADDR) == ZRELADDR

Phần đầu tiên của hạt nhân được mã hóa cẩn thận để xác định vị trí
	độc lập.

INITRD_PHYS
	Địa chỉ vật lý để đặt đĩa RAM ban đầu.  Chỉ có liên quan nếu
	bạn đang sử dụng công cụ bootpImage (chỉ hoạt động trên phiên bản cũ
	cấu trúc param_struct).

INITRD_VIRT
	Địa chỉ ảo của đĩa RAM ban đầu.  Hạn chế sau đây
	phải hợp lệ:

__virt_to_phys(INITRD_VIRT) == INITRD_PHYS

PARAMS_PHYS
	Địa chỉ vật lý của struct param_struct hoặc danh sách thẻ, cung cấp
	kernel các tham số khác nhau về môi trường thực thi của nó.


Ký hiệu hạt nhân
----------------

PHYS_OFFSET
	Địa chỉ bắt đầu vật lý của ngân hàng đầu tiên của RAM.

PAGE_OFFSET
	Địa chỉ bắt đầu ảo của ngân hàng đầu tiên của RAM.  Trong hạt nhân
	giai đoạn khởi động, địa chỉ ảo PAGE_OFFSET sẽ được ánh xạ tới địa chỉ vật lý
	địa chỉ PHYS_OFFSET, cùng với bất kỳ ánh xạ nào khác mà bạn cung cấp.
	Giá trị này phải có cùng giá trị với TASK_SIZE.

TASK_SIZE
	Kích thước tối đa của một tiến trình người dùng tính bằng byte.  Vì không gian người dùng
	luôn bắt đầu từ 0, đây là địa chỉ tối đa mà người dùng
	quá trình có thể truy cập +1.  Ngăn xếp không gian người dùng tăng lên từ đây
	địa chỉ.

Bất kỳ địa chỉ ảo nào dưới TASK_SIZE đều được coi là quy trình của người dùng
	khu vực và do đó được quản lý linh hoạt theo từng quy trình
	cơ sở bởi hạt nhân.  Tôi sẽ gọi đây là phân khúc người dùng.

Mọi điều trên TASK_SIZE đều là chung cho tất cả các quy trình.  tôi sẽ gọi
	đây là phân đoạn kernel.

(Nói cách khác, bạn không thể đặt ánh xạ IO bên dưới TASK_SIZE và
	do đó PAGE_OFFSET).

TEXTADDR
	Địa chỉ bắt đầu ảo của kernel, thông thường là PAGE_OFFSET + 0x8000.
	Đây là nơi hình ảnh hạt nhân kết thúc.  Với các hạt nhân mới nhất,
	nó phải được đặt ở mức 32768 byte trong vùng 128 MB.  trước đó
	hạt nhân đặt giới hạn 256 MB ở đây.

DATAADDR
	Địa chỉ ảo cho phân đoạn dữ liệu kernel.  Không được xác định
	khi sử dụng bộ giải nén.

VMALLOC_START / VMALLOC_END
	Địa chỉ ảo giới hạn vùng vmalloc().  Không được có
	mọi ánh xạ tĩnh trong khu vực này; vmalloc sẽ ghi đè lên chúng.
	Các địa chỉ cũng phải nằm trong phân đoạn kernel (xem ở trên).
	Thông thường, vùng vmalloc() bắt đầu các byte VMALLOC_OFFSET phía trên
	địa chỉ RAM ảo cuối cùng (được tìm thấy bằng biến high_memory).

VMALLOC_OFFSET
	Offset thường được tích hợp vào VMALLOC_START để tạo lỗ
	giữa RAM ảo và khu vực vmalloc.  Chúng tôi làm điều này để cho phép
	truy cập bộ nhớ ngoài giới hạn (ví dụ: có gì đó viết sai ở cuối
	của bản đồ bộ nhớ được ánh xạ) sẽ bị bắt.  Thông thường được đặt thành 8 MB.

Macro cụ thể về kiến ​​trúc
----------------------------

BOOT_MEM(xe đẩy, pio, vio)
	ZZ0000ZZ chỉ định địa chỉ bắt đầu vật lý của RAM.  Phải luôn
	có mặt và phải giống với PHYS_OFFSET.

ZZ0000ZZ là địa chỉ vật lý của vùng 8 MB chứa IO cho
	sử dụng với các macro gỡ lỗi trong Arch/arm/kernel/debug-armv.S.

ZZ0000ZZ là địa chỉ ảo của vùng gỡ lỗi 8 MB.

Dự kiến vùng gỡ lỗi sẽ được khởi tạo lại
	theo mã cụ thể của kiến trúc ở phần sau của mã (thông qua
	Chức năng MAPIO).

BOOT_PARAMS
	Tương tự như và xem PARAMS_PHYS.

FIXUP(chức năng)
	Các bản sửa lỗi cụ thể của máy, chạy trước khi các hệ thống con bộ nhớ được hoàn thiện
	được khởi tạo.

MAPIO(chức năng)
	Chức năng cụ thể của máy để ánh xạ các khu vực IO (bao gồm cả việc gỡ lỗi
	vùng trên).

INITIRQ(chức năng)
	Chức năng cụ thể của máy để khởi tạo các ngắt.
