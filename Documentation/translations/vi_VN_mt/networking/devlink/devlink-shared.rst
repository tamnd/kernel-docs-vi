.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/devlink-shared.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================
Phiên bản dùng chung Devlink
============================

Tổng quan
=========

Các phiên bản liên kết phát triển được chia sẻ cho phép nhiều chức năng vật lý (PF) trên cùng một
chip để chia sẻ một phiên bản liên kết phát triển cho các hoạt động trên toàn chip.

Nhiều PF có thể nằm trên cùng một chip vật lý, chạy một phần sụn duy nhất.
Một số tài nguyên và cấu hình có thể được chia sẻ giữa các PF này. các
phiên bản liên kết phát triển được chia sẻ cung cấp một đối tượng để ghim các nút cấu hình.

Có hai mô hình sử dụng có thể:

1. Phiên bản liên kết nhà phát triển dùng chung được sử dụng cùng với liên kết nhà phát triển PF riêng lẻ
   các phiên bản, cung cấp cấu hình toàn chip ngoài mỗi PF
   cấu hình.
2. Phiên bản liên kết phát triển dùng chung là phiên bản liên kết phát triển duy nhất không có
   mỗi phiên bản PF.

Người lái xe có quyền quyết định sử dụng mô hình sử dụng nào.

Phiên bản liên kết nhà phát triển được chia sẻ không được hỗ trợ bởi bất kỳ cấu trúc ZZ0000ZZ nào.

Thực hiện
==============

Ngành kiến ​​​​trúc
-------------------

Việc thực hiện sử dụng:

* ZZ0000ZZ: PF được nhóm theo chip bằng cách sử dụng mã nhận dạng dành riêng cho trình điều khiển
* ZZ0001ZZ: Danh sách toàn cầu các phiên bản được chia sẻ có tính năng tham chiếu

Chức năng API
-------------

Các chức năng sau được cung cấp để quản lý các phiên bản liên kết nhà phát triển được chia sẻ:

* ZZ0000ZZ: Nhận hoặc tạo một phiên bản liên kết nhà phát triển dùng chung được xác định bằng ID chuỗi
* ZZ0001ZZ: Phát hành một tham chiếu trên phiên bản liên kết nhà phát triển được chia sẻ
* ZZ0002ZZ: Nhận dữ liệu riêng tư từ phiên bản liên kết nhà phát triển được chia sẻ

Luồng khởi tạo
-------------------

1. ZZ0001ZZ trong quá trình thăm dò trình điều khiển
2. ZZ0002ZZ sử dụng phương pháp dành riêng cho trình điều khiển để xác định danh tính thiết bị
3. ZZ0003ZZ sử dụng ZZ0000ZZ:

* Hàm tra cứu instance hiện có theo mã định danh
   * Nếu không tồn tại, tạo phiên bản mới:
     - Phân bổ và đăng ký phiên bản devlink
     - Thêm vào danh sách phiên bản chia sẻ toàn cầu
     - Tăng số lượng tham chiếu

4. ZZ0001ZZ dành cho phiên bản liên kết nhà phát triển PF sử dụng
   ZZ0000ZZ trước khi đăng ký phiên bản liên kết nhà phát triển PF

Luồng dọn dẹp
-------------

1. ZZ0001ZZ khi loại bỏ PF
2. ZZ0002ZZ ZZ0000ZZ để giải phóng tham chiếu (giảm số lượng tham chiếu)
3. ZZ0003ZZ khi PF cuối cùng bị loại bỏ (số tham chiếu đạt đến 0)

Nhận dạng chip
-------------------

Các PF thuộc cùng một chip được xác định bằng phương pháp dành riêng cho trình điều khiển.
Người lái xe có thể tự do lựa chọn bất kỳ số nhận dạng nào phù hợp để xác định
liệu hai PF có phải là một phần của cùng một thiết bị hay không. Ví dụ bao gồm:

* ZZ0000ZZ: Trích xuất từ ​​PCI VPD
* ZZ0001ZZ: Đọc mã định danh chip từ cây thiết bị
* ZZ0002ZZ: Bất kỳ mã định danh duy nhất nào nhóm PF theo chip

Khóa
-------

Một mutex toàn cầu (ZZ0000ZZ) bảo vệ danh sách phiên bản dùng chung trong quá trình đăng ký/hủy đăng ký.

Tương tự như các mối quan hệ phiên bản liên kết phát triển lồng nhau khác, khóa liên kết phát triển của
phiên bản dùng chung phải luôn được lấy sau khóa liên kết phát triển của PF.

Đếm tham chiếu
------------------

Mỗi phiên bản liên kết nhà phát triển được chia sẻ duy trì số lượng tham chiếu (ZZ0000ZZ).
Số lượng tham chiếu được tăng lên khi ZZ0001ZZ được gọi và giảm đi
khi ZZ0002ZZ được gọi. Khi số lượng tham chiếu đạt tới 0, dữ liệu được chia sẻ
instance sẽ tự động bị hủy.