.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/legacy_instructions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Hướng dẫn kế thừa
===================

Cổng arm64 của nhân Linux cung cấp cơ sở hạ tầng để hỗ trợ
mô phỏng các hướng dẫn đã không còn được dùng nữa hoặc đã lỗi thời trong
kiến trúc. Mã cơ sở hạ tầng sử dụng hướng dẫn không xác định
móc để hỗ trợ thi đua. Nếu có nó cũng cho phép bật
việc thực hiện lệnh trong phần cứng.

Chế độ mô phỏng có thể được điều khiển bằng cách ghi vào các nút sysctl
(/proc/sys/abi). Phần sau đây giải thích cách thực hiện khác nhau
hành vi và các giá trị tương ứng của các nút sysctl -

* Không xác định
    Giá trị: 0

Tạo lệnh hủy bỏ không xác định. Mặc định cho các hướng dẫn
  đã lỗi thời trong kiến trúc, ví dụ: SWP

* Mô phỏng
    Giá trị: 1

Sử dụng phần mềm mô phỏng. Để hỗ trợ di chuyển phần mềm, ở chế độ này
  việc sử dụng hướng dẫn mô phỏng được theo dõi cũng như giới hạn tốc độ
  những cảnh báo được đưa ra. Đây là mặc định cho không dùng nữa
  hướng dẫn, ví dụ: rào cản CP15

* Thực thi phần cứng
    Giá trị: 2

Mặc dù được đánh dấu là không dùng nữa nhưng một số triển khai có thể hỗ trợ
  bật/tắt hỗ trợ phần cứng để thực hiện những điều này
  hướng dẫn. Việc sử dụng thực thi phần cứng thường mang lại kết quả tốt hơn
  hiệu suất, nhưng mất khả năng thu thập số liệu thống kê thời gian chạy
  về việc sử dụng các hướng dẫn không được dùng nữa.

Chế độ mặc định phụ thuộc vào trạng thái của lệnh trong
kiến trúc. Hướng dẫn không được dùng nữa nên mặc định là mô phỏng
trong khi các hướng dẫn lỗi thời phải không được xác định theo mặc định.

Lưu ý: Việc mô phỏng lệnh có thể không thực hiện được trong mọi trường hợp. Xem
ghi chú hướng dẫn cá nhân để biết thêm thông tin.

Hướng dẫn kế thừa được hỗ trợ
-----------------------------
* SWP{B}

: Nút: /proc/sys/abi/swp
:Tình trạng: Đã lỗi thời
:Mặc định: Không xác định (0)

* Rào cản CP15

: Nút: /proc/sys/abi/cp15_barrier
:Trạng thái: Không dùng nữa
:Mặc định: Giả lập (1)

* SETEND

: Nút: /proc/sys/abi/setend
:Trạng thái: Không dùng nữa
:Mặc định: Giả lập (1)*

Lưu ý: Tất cả các CPU trên hệ thống phải có hỗ trợ endian hỗn hợp tại EL0
  để kích hoạt tính năng này. Nếu CPU mới - không hỗ trợ hỗn hợp
  endian - được cắm nóng sau khi tính năng này được bật, có thể
  được kết quả bất ngờ trong ứng dụng.
