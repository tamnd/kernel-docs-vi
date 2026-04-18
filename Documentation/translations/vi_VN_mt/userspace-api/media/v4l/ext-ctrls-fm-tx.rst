.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-fm-tx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _fm-tx-controls:

*****************************************
Tài liệu tham khảo điều khiển máy phát FM
*****************************************

Lớp Máy phát FM (FM_TX) bao gồm các điều khiển cho các tính năng phổ biến
của các thiết bị có khả năng truyền sóng FM. Hiện tại lớp này bao gồm
các thông số nén âm thanh, tạo âm thử, độ lệch âm thanh
bộ giới hạn, tính năng điều chỉnh và truyền tải RDS.


.. _fm-tx-control-id:

ID điều khiển FM_TX
===================

ZZ0001ZZ
    Bộ mô tả lớp FM_TX. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0000ZZ
    Định cấu hình mức độ lệch tần số tín hiệu RDS tính bằng Hz. Phạm vi và
    bước là trình điều khiển cụ thể.

ZZ0000ZZ
    Đặt trường Nhận dạng chương trình RDS để truyền.

ZZ0000ZZ
    Đặt trường Loại chương trình RDS để truyền. Điều này mã hóa lên
    tới 31 loại chương trình được xác định trước.

ZZ0001ZZ
    Đặt tên Dịch vụ Chương trình (PS_NAME) để truyền. Đó là
    dành cho hiển thị tĩnh trên máy thu. Đó là sự trợ giúp chính để
    người nghe trong việc xác định và lựa chọn dịch vụ chương trình. trong
    Phụ lục E của ZZ0000ZZ, thông số kỹ thuật RDS, có đầy đủ
    mô tả mã hóa ký tự chính xác cho Dịch vụ Chương trình
    chuỗi tên. Cũng từ thông số kỹ thuật RDS, PS thường là một
    văn bản tám ký tự. Tuy nhiên, cũng có thể tìm thấy người nhận
    có thể cuộn các chuỗi có kích thước 8 x N ký tự. Vì vậy, sự kiểm soát này
    phải được cấu hình với các bước gồm 8 ký tự. Kết quả là phải
    luôn chứa một chuỗi có kích thước bội số của 8.

ZZ0001ZZ
    Đặt thông tin Văn bản Radio để truyền. Nó là một văn bản
    mô tả về những gì đang được phát sóng. Văn bản vô tuyến RDS có thể
    được áp dụng khi đài truyền hình muốn truyền tên PS dài hơn,
    thông tin liên quan đến chương trình hoặc bất kỳ văn bản nào khác. Trong những trường hợp này,
    RadioText nên được sử dụng cùng với ZZ0002ZZ.
    Việc mã hóa các chuỗi Radio Text cũng được mô tả đầy đủ trong Phụ lục
    E của ZZ0000ZZ. Độ dài của chuỗi Radio Text phụ thuộc vào
    Khối RDS nào đang được sử dụng để truyền nó, 32 (khối 2A)
    hoặc 64 (khối 2B). Tuy nhiên, cũng có thể tìm thấy người nhận
    có thể cuộn các chuỗi có kích thước 32 x N hoặc 64 x N ký tự. Vì vậy,
    điều khiển này phải được cấu hình với các bước gồm 32 hoặc 64 ký tự.
    Kết quả là nó phải luôn chứa một chuỗi có kích thước bội số của
    32 hoặc 64.

ZZ0000ZZ
    Đặt bit Mono/Stereo của mã Nhận dạng bộ giải mã. Nếu được đặt,
    sau đó âm thanh được ghi dưới dạng âm thanh nổi.

ZZ0000ZZ
    Đặt
    ZZ0001ZZ
    bit của mã nhận dạng bộ giải mã. Nếu được đặt thì âm thanh sẽ
    được ghi lại bằng đầu nhân tạo.

ZZ0000ZZ
    Đặt bit nén của mã Nhận dạng bộ giải mã. Nếu được đặt,
    sau đó âm thanh được nén.

ZZ0000ZZ
    Đặt bit Dynamic PTY của mã Nhận dạng bộ giải mã. Nếu được đặt,
    thì mã PTY sẽ được chuyển động.

ZZ0000ZZ
    Nếu được đặt thì thông báo giao thông đang được xử lý.

ZZ0000ZZ
    Nếu được đặt thì chương trình đã điều chỉnh sẽ mang thông báo giao thông.

ZZ0000ZZ
    Nếu được đặt thì kênh này sẽ phát nhạc. Nếu được xóa thì nó
    phát sóng bài phát biểu. Nếu máy phát không tạo ra sự khác biệt này,
    thì nó nên được thiết lập.

ZZ0000ZZ
    Nếu được đặt thì truyền tần số thay thế.

ZZ0000ZZ
    Các tần số thay thế tính bằng đơn vị kHz. Tiêu chuẩn RDS cho phép
    lên đến 25 tần số được xác định. Trình điều khiển có thể hỗ trợ ít hơn
    tần số để kiểm tra kích thước mảng.

ZZ0000ZZ
    Bật hoặc tắt tính năng giới hạn độ lệch âm thanh. Bộ giới hạn
    rất hữu ích khi cố gắng tối đa hóa âm lượng, giảm thiểu
    méo do máy thu tạo ra và ngăn ngừa điều chế quá mức.

ZZ0000ZZ
    Đặt thời gian phát hành tính năng giới hạn độ lệch âm thanh. Đơn vị đang ở
    micro giây. Bước và phạm vi dành riêng cho người lái xe.

ZZ0000ZZ
    Định cấu hình mức độ lệch tần số âm thanh tính bằng Hz. Phạm vi và bước
    dành riêng cho người lái xe.

ZZ0000ZZ
    Bật hoặc tắt tính năng nén âm thanh. Tính năng này
    khuếch đại tín hiệu dưới ngưỡng bằng mức tăng cố định và nén
    tín hiệu âm thanh vượt quá ngưỡng theo tỷ lệ Ngưỡng/(Tăng +
    ngưỡng).

ZZ0000ZZ
    Đặt mức tăng cho tính năng nén âm thanh. Đó là giá trị dB. các
    phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Đặt mức ngưỡng cho tính năng nén âm thanh. Đó là một dB
    giá trị. Phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Đặt thời gian tấn công cho tính năng nén âm thanh. Đó là một phần triệu giây
    giá trị. Phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Đặt thời gian phát hành cho tính năng nén âm thanh. Đó là một
    giá trị micro giây. Phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Bật hoặc tắt tính năng tạo âm thử.

ZZ0000ZZ
    Định cấu hình mức độ lệch tần số âm thử. Đơn vị tính bằng Hz. các
    phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Định cấu hình giá trị tần số âm thử. Đơn vị tính bằng Hz. Phạm vi và
    bước là trình điều khiển cụ thể.

ZZ0000ZZ
    Định cấu hình giá trị nhấn mạnh trước để phát sóng. Sự nhấn mạnh trước
    bộ lọc được áp dụng cho chương trình phát sóng để làm nổi bật âm thanh cao
    tần số. Tùy thuộc vào khu vực, hằng số thời gian là 50
    hoặc 75 micro giây được sử dụng. Enum v4l2_preemphasis xác định có thể
    các giá trị để nhấn mạnh trước. Họ là:

.. flat-table::
    :header-rows:  0
    :stub-columns: 0

    * - ``V4L2_PREEMPHASIS_DISABLED``
      - No pre-emphasis is applied.
    * - ``V4L2_PREEMPHASIS_50_uS``
      - A pre-emphasis of 50 uS is used.
    * - ``V4L2_PREEMPHASIS_75_uS``
      - A pre-emphasis of 75 uS is used.

ZZ0000ZZ
    Đặt mức công suất đầu ra để truyền tín hiệu. Đơn vị đang ở
    dBuV. Phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Việc này chọn giá trị của tụ điều chỉnh ăng-ten bằng tay hoặc
    tự động nếu được đặt thành 0. Đơn vị, phạm vi và bước là
    dành riêng cho người lái xe.

Để biết thêm chi tiết về thông số kỹ thuật RDS, hãy tham khảo ZZ0000ZZ
tài liệu, từ CENELEC.