.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/usb-legacy-support.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Hỗ trợ USB Legacy
==================

:Tác giả: Vojtech Pavlik <vojtech@suse.cz>, tháng 1 năm 2004


Còn được gọi là "Bàn phím USB" hoặc "Hỗ trợ chuột USB" trong Cài đặt BIOS là một
tính năng cho phép người ta sử dụng chuột và bàn phím USB như thể chúng
đối tác PS/2 cổ điển của họ.  Điều này có nghĩa là người ta có thể sử dụng bàn phím USB để
gõ LILO chẳng hạn.

Tuy nhiên, nó có một số nhược điểm:

1) Trên một số máy, chuột PS/2 giả lập sẽ tiếp quản ngay cả khi không có USB
   có chuột và có chuột PS/2 thật.  Trong trường hợp đó thêm
   các tính năng (bánh xe, nút phụ, chế độ bàn di chuột) của chuột PS/2 thật có thể
   không có sẵn.

2) Nếu chế độ AMD64 64-bit được bật, lỗi hệ thống thường xảy ra,
   bởi vì SMM BIOS không mong đợi CPU ở chế độ 64-bit.  các
   Nhà sản xuất BIOS chỉ thử nghiệm với Windows, Windows không làm được 64-bit
   chưa.

Giải pháp:

Vấn đề 1)
  có thể được giải quyết bằng cách tải trình điều khiển USB trước khi tải
  Trình điều khiển chuột PS/2. Vì trình điều khiển chuột PS/2 ở phiên bản 2.6 được biên dịch thành
  kernel vô điều kiện, điều này có nghĩa là trình điều khiển USB cần phải được
  cũng được biên dịch sẵn.

Vấn đề 2)
  thường được sửa bằng bản cập nhật BIOS. Kiểm tra bảng
  trang web của nhà sản xuất. Nếu không có bản cập nhật, hãy tắt USB
  Hỗ trợ kế thừa trong BIOS. Nếu điều này không giúp ích được gì, hãy thử thêm
  Idle=polll trên dòng lệnh kernel. BIOS có thể đang vào SMM
  trên lệnh HLT.