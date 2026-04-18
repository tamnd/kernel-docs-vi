.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/tee/ts-tee.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
TS-TEE (Dự án dịch vụ đáng tin cậy)
====================================

Trình điều khiển này cung cấp quyền truy cập vào các dịch vụ an toàn do Dịch vụ đáng tin cậy triển khai.

Dịch vụ đáng tin cậy [1] là một dự án TrustedFirmware.org cung cấp một khuôn khổ
để phát triển và triển khai dịch vụ Root of Trust của thiết bị trong FF-A [2] S-EL0
Phân vùng an toàn. Dự án tổ chức triển khai tham chiếu của Arm
Kiến trúc bảo mật nền tảng [3] dành cho thiết bị cấu hình Arm A.

Phân vùng an toàn FF-A (SP) có thể truy cập được thông qua trình điều khiển FF-A [4]
cung cấp giao tiếp cấp thấp cho trình điều khiển này. Trên hết, đáng tin cậy
Dịch vụ Giao thức RPC được sử dụng [5]. Để sử dụng trình điều khiển từ không gian người dùng, hãy tham khảo
việc triển khai được cung cấp tại [6], một phần của ứng dụng khách Dịch vụ đáng tin cậy
thư viện có tên libts [7].

Tất cả SP Dịch vụ đáng tin cậy (TS) đều có cùng FF-A UUID; nó xác định TS RPC
giao thức. TS SP có thể lưu trữ một hoặc nhiều dịch vụ (ví dụ: PSA Crypto, PSA ITS, v.v.).
Một dịch vụ được xác định bởi dịch vụ UUID của nó; không thể có cùng một loại dịch vụ
hiện diện hai lần trong cùng một SP. Trong quá trình SP boot mỗi dịch vụ trong SP được gán
một "ID giao diện". Đây chỉ là một ID ngắn để đơn giản hóa việc đánh địa chỉ tin nhắn.

Thiết kế chung của TEE là chia sẻ bộ nhớ cùng lúc với Hệ điều hành đáng tin cậy, hệ điều hành này có thể
sau đó được tái sử dụng để liên lạc với nhiều ứng dụng chạy trên Trusted
hệ điều hành. Tuy nhiên, trong trường hợp FF-A, việc chia sẻ bộ nhớ hoạt động ở cấp độ điểm cuối, tức là.
bộ nhớ được chia sẻ với một SP cụ thể. Không gian người dùng phải có khả năng tách biệt
chia sẻ bộ nhớ với mỗi SP dựa trên ID điểm cuối của nó; do đó một TEE riêng biệt
thiết bị được đăng ký cho mỗi TS SP được phát hiện. Việc mở SP tương ứng với
mở thiết bị TEE và tạo bối cảnh TEE. TS SP lưu trữ một hoặc nhiều
dịch vụ. Mở một dịch vụ tương ứng với việc mở một phiên trong
tee_context.

Tổng quan về hệ thống với các thành phần Dịch vụ đáng tin cậy::

Không gian người dùng Không gian hạt nhân Thế giới an toàn
   ~~~~~~~~~~ ~~~~~~~~~~~~ ~~~~~~~~~~~~
   +--------+ +-------------+
   ZZ0000ZZ ZZ0001ZZ
   +--------+ ZZ0002ZZ
      /\ +-------------+
      ||                                                          /\
      |ZZ0003ZZ|
      |ZZ0004ZZ|
      \/ \/
   +-------+ +----------+--------+ +-------------+
   ZZ0005ZZ ZZ0006ZZ TS-TEE ZZ0007ZZ FF-A SPMC |
   Trình điều khiển ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ + SPMD |
   +-------+-------+----+------+--------+----------+-------------+
   Giao thức ZZ0011ZZ ZZ0012ZZ TS RPC |
   ZZ0013ZZ ZZ0014ZZ trên FF-A |
   +-----------------------------+ +--------+--------------+

Tài liệu tham khảo
==========

[1] ZZ0000ZZ

[2] ZZ0000ZZ

[3] ZZ0000ZZ

[4] trình điều khiển/chương trình cơ sở/arm_ffa/

[5] ZZ0000ZZ

[6] ZZ0000ZZ

[7] ZZ0000ZZ