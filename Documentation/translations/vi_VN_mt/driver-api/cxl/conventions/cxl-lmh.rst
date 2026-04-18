.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/cxl/conventions/cxl-lmh.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giải quyết xung đột giữa CFMWS, Lỗ bộ nhớ nền tảng và Bộ giải mã điểm cuối
============================================================================

Tài liệu
--------

CXL Phiên bản 3.2, Phiên bản 1.0

Giấy phép
---------

SPDX-Số nhận dạng giấy phép: CC-BY-4.0

Người sáng tạo/Người đóng góp
-----------------------------

- Fabio M. De Francesco, Intel
- Dan J. Williams, Intel
- Mahesh Natu, Intel

Tóm tắt sự thay đổi
---------------------

Theo Thông số kỹ thuật của Computing Express Link (CXL) hiện tại (Bản sửa đổi
3.2, Phiên bản 1.0), Cấu trúc cửa sổ bộ nhớ cố định CXL (CFMWS) mô tả số không
hoặc nhiều cửa sổ Địa chỉ vật lý máy chủ (HPA) được liên kết với mỗi Máy chủ CXL
Cầu. Mỗi cửa sổ đại diện cho một phạm vi HPA liền kề có thể được xen kẽ
trên một hoặc nhiều mục tiêu, bao gồm Cầu nối máy chủ CXL. Mỗi cửa sổ có một bộ
những hạn chế chi phối việc sử dụng nó. Đây là hệ điều hành hướng tới
trách nhiệm cấu hình và Quản lý nguồn (OSPM) để sử dụng từng cửa sổ
cho mục đích sử dụng đã chỉ định.

Bảng 9-22 của Thông số kỹ thuật CXL hiện tại cho biết trường Kích thước cửa sổ
chứa tổng số byte liên tiếp của HPA cửa sổ này mô tả.
Giá trị này phải là bội số của Số cách xen kẽ (NIW) * 256 MB.

Phần sụn nền tảng (BIOS) có thể dự trữ địa chỉ vật lý dưới 4 GB trong đó
khoảng trống bộ nhớ như Lỗ bộ nhớ thấp cho PCIe MMIO có thể tồn tại. Trong những trường hợp như vậy,
Kích thước phạm vi CFMWS có thể không tuân thủ quy tắc NIW * 256 MB.

HPA đại diện cho không gian địa chỉ bộ nhớ vật lý thực tế mà các thiết bị CXL
có thể giải mã và phản hồi, trong khi Địa chỉ vật lý hệ thống (SPA), một địa chỉ liên quan
nhưng khái niệm riêng biệt, đại diện cho không gian địa chỉ hiển thị trên hệ thống mà người dùng có thể
giao dịch trực tiếp và do đó nó loại trừ các khu vực dành riêng.

BIOS xuất bản CFMWS để truyền đạt các phạm vi SPA đang hoạt động trên các nền tảng
với LMH, ánh xạ tới tập hợp con nghiêm ngặt của HPA. Dòng sản phẩm SPA cắt lỗ,
dẫn đến mất dung lượng ở các Điểm cuối không có SPA để ánh xạ tới phần đó của
phạm vi HPA giao với lỗ.

Ví dụ: nền tảng x86 có hai CFMWS và LMH bắt đầu từ 2 GB:

+--------+-------------+-------------------+-------------------+-------------------+------+
 Cơ sở giải mã ZZ0001ZZ CFMWS ZZ0002ZZ HDM Cơ sở giải mã ZZ0003ZZ Cách |
 +=======================+==========================================================================+=======+
 ZZ0004ZZ 0 GB ZZ0005ZZ 0 GB ZZ0006ZZ 12 |
 +--------+-------------+-------------------+-------------------+-------------------+------+
 ZZ0007ZZ 4GB ZZ0008ZZ 12 |
 +--------+-------------+-------------------+-------------------+-------------------+------+

Cơ sở giải mã HDM và kích thước bộ giải mã HDM đại diện cho tất cả 12 Bộ giải mã điểm cuối của
vùng 12 chiều và tất cả các Bộ giải mã chuyển mạch trung gian. Chúng được cấu hình
bởi BIOS theo quy tắc NIW * 256MB, dẫn đến kích thước phạm vi HPA là
3GB. Thay vào đó, CFMWS Base và CFMWS Size được sử dụng để định cấu hình Root
Bộ giải mã HPA có phạm vi nhỏ hơn (2GB) so với Switch và
Bộ giải mã điểm cuối trong hệ thống phân cấp (3GB).

Điều này tạo ra 2 vấn đề dẫn đến việc không xây dựng được vùng:

1) Kích thước vùng không khớp giữa gốc và bất kỳ bộ giải mã HDM nào. Bộ giải mã gốc
   sẽ luôn nhỏ hơn do bị cắt bớt.

2) Việc cắt xén khiến bộ giải mã gốc vi phạm quy tắc (NIW * 256MB).

Thay đổi này cho phép khu vực có địa chỉ cơ sở là 0GB bỏ qua các bước kiểm tra này để
cho phép tạo vùng với phạm vi địa chỉ bộ giải mã gốc được cắt bớt.

Thay đổi này không cho phép bất kỳ khu vực tùy ý nào khác vi phạm những điều này
kiểm tra - nó được thiết kế dành riêng để kích hoạt các nền tảng x86 ánh xạ bộ nhớ CXL
dưới 4GB.

Mặc dù bộ giải mã HDM bao phủ vùng PCIE lỗ HPA, người ta vẫn mong đợi rằng
nền tảng sẽ không bao giờ định tuyến các quyền truy cập địa chỉ vào tổ hợp CXL vì
bộ giải mã gốc chỉ bao gồm vùng được cắt bớt (loại trừ vùng này). Đây là
nằm ngoài khả năng thực thi của Linux.

Trên nền tảng ví dụ, chỉ 2GB đầu tiên mới có khả năng sử dụng được, nhưng
Linux, nhằm mục đích tuân thủ các thông số kỹ thuật hiện tại, đã không xây dựng được
Các khu vực và gắn Bộ giải mã chuyển mạch điểm cuối và trung gian vào chúng.

Có một số điểm thất bại do kỳ vọng rằng Root
Kích thước bộ giải mã HPA, bằng với CFMWS mà nó được cấu hình, có
lớn hơn hoặc bằng Bộ giải mã Switch và Endpoint HDM phù hợp.

Để thành công trong việc xây dựng và đính kèm, Linux phải xây dựng một
Vùng có kích thước phạm vi Bộ giải mã gốc HPA, sau đó gắn vào đó tất cả
Bộ giải mã chuyển mạch trung gian và Bộ giải mã điểm cuối thuộc hệ thống phân cấp
bất kể kích thước phạm vi của chúng.

Lợi ích của sự thay đổi
-----------------------

Nếu không có sự thay đổi, OSPM sẽ không phù hợp với Switch và Endpoint trung gian
Bộ giải mã với Bộ giải mã gốc được định cấu hình với kích thước CFMWS HPA không căn chỉnh
với giới hạn NIW * 256 MB, dẫn đến mất dung lượng memdev.

Thay đổi này cho phép OSPM xây dựng Vùng và gắn Công tắc trung gian
và Bộ giải mã điểm cuối cho chúng, sao cho phần có thể định địa chỉ của bộ nhớ
tổng công suất của thiết bị được cung cấp cho người dùng.

Tài liệu tham khảo
------------------

Bản sửa đổi đặc tả liên kết nhanh điện toán 3.2, phiên bản 1.0
<ZZ0000ZZ

Mô tả chi tiết về sự thay đổi
----------------------------------

Mô tả trường Kích thước cửa sổ trong bảng 9-22 cần tính đến
nền tảng có Lỗ bộ nhớ thấp, trong đó phạm vi SPA có thể là tập hợp con của
điểm cuối HPA. Vì vậy, nó phải được thay đổi như sau:

"Tổng số byte liên tiếp của HPA mà cửa sổ này đại diện. Giá trị này
sẽ là bội số của NIW * 256 MB.

Trên các nền tảng dự trữ địa chỉ vật lý dưới 4 GB, chẳng hạn như Low Memory
Lỗ dành cho PCIe MMIO trên x86, một phiên bản của CFMWS có phạm vi Base HPA là 0 có thể
có kích thước không phù hợp với ràng buộc NIW * 256 MB.

Lưu ý rằng Bộ giải mã chuyển mạch trung gian và Bộ giải mã điểm cuối phù hợp
Kích thước phạm vi HPA vẫn phải căn chỉnh theo quy tắc nêu trên, nhưng bộ nhớ
dung lượng vượt quá kích thước cửa sổ CFMWS sẽ không thể truy cập được.".