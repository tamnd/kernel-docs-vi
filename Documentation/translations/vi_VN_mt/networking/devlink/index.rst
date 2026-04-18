.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/devlink/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Tài liệu liên kết phát triển Linux
==================================

devlink là một API để tiết lộ thông tin và tài nguyên của thiết bị một cách không trực tiếp
liên quan đến bất kỳ loại thiết bị nào, chẳng hạn như cấu hình toàn chip/switch-ASIC.

Khóa
-------

API đối mặt với trình điều khiển hiện đang chuyển đổi để cho phép rõ ràng hơn
khóa. Trình điều khiển có thể sử dụng bộ API ZZ0000ZZ hiện có hoặc
các API mới có tiền tố ZZ0001ZZ. Các API cũ hơn xử lý tất cả việc khóa
trong lõi devlink, nhưng không cho phép đăng ký hầu hết các đối tượng phụ một lần
đối tượng devlink chính đã được đăng ký. Các API ZZ0002ZZ mới hơn giả định
khóa phiên bản devlink đã được giữ. Trình điều khiển có thể lấy ví dụ
khóa bằng cách gọi ZZ0003ZZ. Nó cũng giữ tất cả các lệnh gọi lại của devlink
các lệnh liên kết mạng.

Trình điều khiển được khuyến khích sử dụng khóa phiên bản devlink cho nhu cầu riêng của họ.

Trình điều khiển cần thận trọng khi sử dụng khóa phiên bản devlink và
lấy khóa RTNL cùng một lúc. Cần phải khóa phiên bản Devlink
đầu tiên, chỉ sau khi khóa RTNL đó mới có thể được lấy.

Các phiên bản lồng nhau
-----------------------

Một số đối tượng, như linecard hoặc chức năng cổng, có thể có một chức năng khác
các phiên bản devlink được tạo bên dưới. Trong trường hợp đó, người lái xe nên thực hiện
chắc chắn tôn trọng các quy tắc sau:

- Thứ tự khóa nên được duy trì. Nếu trình điều khiển cần lấy ví dụ
   khóa cả phiên bản lồng nhau và phiên bản gốc cùng một lúc, devlink
   khóa cá thể của cá thể mẹ phải được thực hiện trước tiên, chỉ sau đó
   khóa phiên bản của phiên bản lồng nhau có thể được thực hiện.
 - Trình điều khiển nên sử dụng các trợ giúp dành riêng cho đối tượng để thiết lập
   mối quan hệ lồng nhau:

- ZZ0000ZZ - được gọi để thiết lập devlink -> lồng nhau
     mối quan hệ liên kết nhà phát triển (có thể là người dùng cho nhiều phiên bản lồng nhau.
   - ZZ0001ZZ - được gọi để thiết lập chức năng cổng ->
     mối quan hệ devlink lồng nhau.
   - ZZ0002ZZ - được gọi để thiết lập linecard ->
     mối quan hệ devlink lồng nhau.

Thông tin liên kết nhà phát triển lồng nhau được hiển thị cho không gian người dùng qua đối tượng cụ thể
các thuộc tính của liên kết mạng devlink.

Tài liệu giao diện
-----------------------

Các trang sau đây mô tả các giao diện khác nhau có sẵn thông qua devlink trong
chung.

.. toctree::
   :maxdepth: 1

   devlink-dpipe
   devlink-eswitch-attr
   devlink-flash
   devlink-health
   devlink-info
   devlink-linecard
   devlink-params
   devlink-port
   devlink-region
   devlink-reload
   devlink-resource
   devlink-selftests
   devlink-trap
   devlink-shared

Tài liệu dành riêng cho trình điều khiển
----------------------------------------

Mỗi trình điều khiển triển khai ZZ0000ZZ phải ghi lại những gì
thông số, phiên bản thông tin và các tính năng khác mà nó hỗ trợ.

.. toctree::
   :maxdepth: 1

   am65-nuss-cpsw-switch
   bnxt
   etas_es58x
   hns3
   i40e
   ice
   ionic
   iosm
   ixgbe
   kvaser_pciefd
   kvaser_usb
   mlx4
   mlx5
   mlxsw
   mv88e6xxx
   netdevsim
   nfp
   octeontx2
   prestera
   qed
   sfc
   stmmac
   ti-cpsw-switch
   zl3073x
