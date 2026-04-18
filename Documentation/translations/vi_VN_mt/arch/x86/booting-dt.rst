.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/booting-dt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Khởi động DeviceTree
--------------------

Có một điểm vào 32 bit duy nhất cho kernel tại code32_start,
  bộ giải nén (điểm vào chế độ thực sẽ chuyển sang cùng 32 bit
  điểm vào khi nó chuyển sang chế độ được bảo vệ). Điểm vào đó
  hỗ trợ một quy ước gọi điện được ghi lại trong
  Tài liệu/arch/x86/boot.rst
  Con trỏ vật lý tới khối cây thiết bị được truyền qua setup_data
  yêu cầu ít nhất giao thức khởi động 2.09.
  Loại hồ sơ được định nghĩa là

#define SETUP_DTB 2

Cây thiết bị này được sử dụng làm phần mở rộng cho "trang khởi động". Như vậy nó
  không phân tích/xem xét dữ liệu đã được khởi động
  trang. Điều này bao gồm kích thước bộ nhớ, phạm vi dành riêng, đối số dòng lệnh
  hoặc địa chỉ initrd. Nó chỉ đơn giản là chứa thông tin không thể lấy được
  mặt khác như định tuyến ngắt hoặc danh sách các thiết bị phía sau bus I2C.