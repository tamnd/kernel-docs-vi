.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-fm-rx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _fm-rx-controls:

*****************************
Tham khảo điều khiển máy thu FM
*****************************

Lớp Bộ thu FM (FM_RX) bao gồm các điều khiển cho các tính năng chung của
Thiết bị có khả năng thu sóng FM.


.. _fm-rx-control-id:

ID điều khiển FM_RX
=================

ZZ0001ZZ
    Bộ mô tả lớp FM_RX. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0000ZZ
    Bật/tắt việc thu sóng RDS bằng bộ dò đài

ZZ0000ZZ
    Nhận trường Loại chương trình RDS. Điều này mã hóa lên đến 31 được xác định trước
    các loại chương trình.

ZZ0001ZZ
    Lấy tên Dịch vụ Chương trình (PS_NAME). Nó được dành cho
    hiển thị tĩnh trên máy thu. Nó là sự trợ giúp chính cho người nghe trong
    nhận dạng và lựa chọn dịch vụ chương trình. Trong Phụ lục E của
    ZZ0000ZZ, thông số kỹ thuật RDS, có đầy đủ
    mô tả mã hóa ký tự chính xác cho Dịch vụ Chương trình
    chuỗi tên. Cũng từ thông số kỹ thuật RDS, PS thường là một
    văn bản tám ký tự. Tuy nhiên, cũng có thể tìm thấy người nhận
    có thể cuộn các chuỗi có kích thước 8 x N ký tự. Vì vậy, sự kiểm soát này
    phải được cấu hình với các bước gồm 8 ký tự. Kết quả là phải
    luôn chứa một chuỗi có kích thước bội số của 8.

ZZ0001ZZ
    Nhận thông tin Văn bản Radio. Đó là sự mô tả bằng văn bản về những gì
    đang được phát sóng. RDS Radio Text có thể được áp dụng khi đài truyền hình
    mong muốn truyền tải tên PS dài hơn, thông tin liên quan đến chương trình hoặc
    any other text. Trong những trường hợp này, RadioText có thể được sử dụng ngoài
    ZZ0002ZZ. Mã hóa cho chuỗi Văn bản Radio là
    cũng được mô tả đầy đủ trong Phụ lục E của ZZ0000ZZ. Chiều dài của
    Chuỗi văn bản vô tuyến phụ thuộc vào Khối RDS nào đang được sử dụng để
    truyền nó, 32 (khối 2A) hoặc 64 (khối 2B). Tuy nhiên, nó là
    cũng có thể tìm thấy các máy thu có thể cuộn các chuỗi có kích thước 32
    x N hoặc 64 x N ký tự. Vì vậy, điều khiển này phải được cấu hình với
    bước 32 hoặc 64 ký tự. Kết quả là nó phải luôn chứa một
    chuỗi có kích thước bội số của 32 hoặc 64.

ZZ0000ZZ
    Nếu được đặt thì thông báo giao thông đang được xử lý.

ZZ0000ZZ
    Nếu được đặt thì chương trình đã điều chỉnh sẽ mang thông báo giao thông.

ZZ0000ZZ
    Nếu được đặt thì kênh này sẽ phát nhạc. Nếu được xóa thì nó
    phát sóng bài phát biểu. Nếu máy phát không tạo ra sự khác biệt này,
    sau đó nó sẽ được thiết lập.

ZZ0000ZZ
    Định cấu hình giá trị khử nhấn mạnh để tiếp nhận. Bộ lọc giảm nhấn mạnh
    được áp dụng cho chương trình phát sóng để làm nổi bật âm thanh cao
    tần số. Tùy thuộc vào khu vực, hằng số thời gian là 50
    hoặc 75 micro giây được sử dụng. Enum v4l2_deemphasis xác định có thể
    các giá trị để giảm sự nhấn mạnh. Họ là:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_DEEMPHASIS_DISABLED``
      - No de-emphasis is applied.
    * - ``V4L2_DEEMPHASIS_50_uS``
      - A de-emphasis of 50 uS is used.
    * - ``V4L2_DEEMPHASIS_75_uS``
      - A de-emphasis of 75 uS is used.