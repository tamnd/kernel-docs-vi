.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/dtv-core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thiết bị truyền hình kỹ thuật số (DVB)
------------------------

Các thiết bị TV kỹ thuật số được triển khai bởi một số trình điều khiển khác nhau:

- Người lái xe cầu có trách nhiệm trao đổi với xe buýt nơi khác
  các thiết bị được kết nối (PCI, USB, SPI), liên kết với các trình điều khiển khác và
  triển khai logic giải mã kỹ thuật số (bằng phần mềm hoặc phần cứng);

- Trình điều khiển giao diện người dùng thường được triển khai dưới dạng hai trình điều khiển riêng biệt:

- Trình điều khiển bộ điều chỉnh thực hiện logic ra lệnh cho phần của
    phần cứng chịu trách nhiệm điều chỉnh thành bộ phát đáp truyền hình kỹ thuật số hoặc
    kênh vật lý. Đầu ra của bộ chỉnh tần thường là baseband hoặc
    Tín hiệu tần số trung gian (IF);

- Trình điều khiển giải điều chế (hay còn gọi là "demod") thực hiện logic
    ra lệnh cho phần cứng giải mã TV kỹ thuật số. Đầu ra của một bản demo là
    một luồng kỹ thuật số, thường có nhiều kênh âm thanh, video và dữ liệu
    được ghép kênh bằng Luồng truyền tải MPEG [#f1]_.

Trên hầu hết phần cứng, trình điều khiển giao diện người dùng giao tiếp với trình điều khiển cầu nối bằng cách sử dụng
Xe buýt I2C.

.. [#f1] Some standards use TCP/IP for multiplexing data, like DVB-H (an
   abandoned standard, not used anymore) and ATSC version 3.0 current
   proposals. Currently, the DVB subsystem doesn't implement those standards.


.. toctree::
    :maxdepth: 1

    dtv-common
    dtv-frontend
    dtv-demux
    dtv-ca
    dtv-net