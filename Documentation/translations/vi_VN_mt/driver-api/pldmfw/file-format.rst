.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/pldmfw/file-format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Tổng quan về định dạng tệp chương trình cơ sở PLDM
==================================================

Gói chương trình cơ sở PLDM là một tệp nhị phân chứa tiêu đề
mô tả nội dung của gói phần mềm cơ sở. Điều này bao gồm một ban đầu
tiêu đề gói, một hoặc nhiều bản ghi chương trình cơ sở và một hoặc nhiều thành phần
mô tả nội dung flash thực tế cho chương trình.

Sơ đồ này cung cấp cái nhìn tổng quan về định dạng tệp::

bố cục tập tin tổng thể
      +----------------------+
      ZZ0000ZZ
      ZZ0001ZZ
      ZZ0002ZZ
      +----------------------+
      ZZ0003ZZ
      ZZ0004ZZ
      ZZ0005ZZ
      +----------------------+
      ZZ0006ZZ
      ZZ0007ZZ
      ZZ0008ZZ
      +----------------------+
      ZZ0009ZZ
      ZZ0010ZZ
      ZZ0011ZZ
      +----------------------+
      ZZ0012ZZ
      ZZ0013ZZ
      ZZ0014ZZ
      +----------------------+
      ZZ0015ZZ
      ZZ0016ZZ
      ZZ0017ZZ
      +----------------------+
      ZZ0018ZZ
      ZZ0019ZZ
      ZZ0020ZZ
      +----------------------+
      ZZ0021ZZ
      ZZ0022ZZ
      ZZ0023ZZ
      +----------------------+

Tiêu đề gói
==============

Tiêu đề gói bắt đầu bằng UUID của định dạng tệp PLDM và
chứa thông tin về phiên bản định dạng mà tệp sử dụng. Nó
cũng bao gồm tổng kích thước tiêu đề, ngày phát hành, kích thước của
bitmap thành phần và phiên bản gói tổng thể.

Sơ đồ sau đây cung cấp cái nhìn tổng quan về tiêu đề gói::

bố cục tiêu đề
      +-----------------+
      ZZ0000ZZ
      +-----------------+
      ZZ0001ZZ
      +-----------------+
      ZZ0002ZZ
      +-----------------+
      ZZ0003ZZ
      +-----------------+
      ZZ0004ZZ
      +-----------------+
      ZZ0005ZZ
      +-----------------+

Bản ghi thiết bị
==============

Vùng bản ghi chương trình cơ sở của thiết bị bắt đầu bằng số đếm cho biết tổng số
số lượng bản ghi trong tệp, theo sau là mỗi bản ghi. Một thiết bị duy nhất
bản ghi mô tả thiết bị nào phù hợp với bản ghi này. Tất cả phần mềm PLDM hợp lệ
các tệp phải chứa ít nhất một bản ghi, nhưng tùy chọn có thể chứa nhiều hơn
một bản ghi nếu chúng hỗ trợ nhiều thiết bị.

Mỗi bản ghi sẽ xác định thiết bị mà nó hỗ trợ thông qua TLV mô tả
thiết bị, chẳng hạn như thiết bị PCI và thông tin nhà cung cấp. Nó cũng sẽ chỉ ra
bộ thành phần nào được sử dụng bởi thiết bị này. Có thể là
chỉ một tập hợp con của các thành phần được cung cấp sẽ được sử dụng bởi một bản ghi nhất định. Một kỷ lục
cũng có thể tùy chọn chứa dữ liệu gói dành riêng cho thiết bị sẽ được sử dụng
bởi chương trình cơ sở của thiết bị trong quá trình cập nhật.

Sơ đồ sau đây cung cấp cái nhìn tổng quan về khu vực bản ghi thiết bị::

bố trí khu vực
      +--------------+
      ZZ0000ZZ
      ZZ0001ZZ
      ZZ0002ZZ
      +--------------+
      ZZ0003ZZ
      ZZ0004ZZ
      ZZ0005ZZ
      +--------------+
      ZZ0006ZZ
      ZZ0007ZZ
      ZZ0008ZZ
      +--------------+
      ZZ0009ZZ
      ZZ0010ZZ
      ZZ0011ZZ
      +--------------+
      ZZ0012ZZ
      ZZ0013ZZ
      ZZ0014ZZ
      +--------------+

bố cục bản ghi
      +--------------+
      ZZ0000ZZ
      +--------------+
      ZZ0001ZZ
      +--------------+
      ZZ0002ZZ
      +--------------+
      ZZ0003ZZ
      +--------------+
      ZZ0004ZZ
      +--------------+
      ZZ0005ZZ
      +--------------+
      ZZ0006ZZ
      +--------------+
      ZZ0007ZZ
      +--------------+
      ZZ0008ZZ
      +--------------+

Thông tin thành phần
==============

Vùng thông tin thành phần bắt đầu bằng việc đếm số lượng
thành phần. Sau con số này là phần mô tả cho từng thành phần. các
thông tin thành phần trỏ đến vị trí trong tệp nơi thành phần đó
dữ liệu được lưu trữ và bao gồm dữ liệu phiên bản được sử dụng để xác định phiên bản của
thành phần.

Sơ đồ sau đây cung cấp cái nhìn tổng quan về khu vực thành phần::

bố trí khu vực
      +-----------------+
      ZZ0000ZZ
      ZZ0001ZZ
      ZZ0002ZZ
      +-----------------+
      ZZ0003ZZ
      ZZ0004ZZ
      ZZ0005ZZ
      +-----------------+
      ZZ0006ZZ
      ZZ0007ZZ
      ZZ0008ZZ
      +-----------------+
      ZZ0009ZZ
      ZZ0010ZZ
      ZZ0011ZZ
      +-----------------+
      ZZ0012ZZ
      ZZ0013ZZ
      ZZ0014ZZ
      +-----------------+

bố trí thành phần
      +---------------+
      ZZ0000ZZ
      +---------------+
      ZZ0001ZZ
      +---------------+
      ZZ0002ZZ
      +---------------+
      ZZ0003ZZ
      +---------------+
      ZZ0004ZZ
      +---------------+
      ZZ0005ZZ
      +---------------+
      ZZ0006ZZ
      +---------------+
      ZZ0007ZZ
      +---------------+
      ZZ0008ZZ
      +---------------+


Tiêu đề gói CRC
==================

Theo sau thông tin thành phần là một CRC 4 byte ngắn được tính toán trên
nội dung của tất cả các thông tin tiêu đề.

Hình ảnh thành phần
================

Các hình ảnh thành phần tuân theo thông tin tiêu đề gói trong PLDM
tập tin phần sụn. Mỗi trong số này chỉ đơn giản là một đoạn nhị phân có phần bắt đầu và
kích thước được xác định bởi cấu trúc thành phần phù hợp trong vùng thông tin thành phần.