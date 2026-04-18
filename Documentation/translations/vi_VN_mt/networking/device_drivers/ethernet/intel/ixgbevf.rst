.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/ethernet/intel/ixgbevf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================================================
Trình điều khiển chức năng ảo cơ sở Linux cho Intel(R) 10G Ethernet
===================================================================

Trình điều khiển Linux chức năng ảo Intel 10 Gigabit.
Bản quyền(c) 1999-2018 Tập đoàn Intel.

Nội dung
========

- Xác định bộ chuyển đổi của bạn
- Các vấn đề đã biết
- Hỗ trợ

Trình điều khiển này hỗ trợ các thiết bị chức năng ảo dựa trên 82599, X540, X550 và X552
chỉ có thể được kích hoạt trên các hạt nhân hỗ trợ SR-IOV.

Đối với các câu hỏi liên quan đến yêu cầu phần cứng, hãy tham khảo tài liệu
được cung cấp cùng với bộ điều hợp Intel của bạn. Tất cả các yêu cầu phần cứng được liệt kê đều áp dụng để sử dụng
với Linux.


Xác định bộ điều hợp của bạn
========================
Trình điều khiển tương thích với các thiết bị dựa trên những điều sau:

* Bộ điều khiển Ethernet Intel(R) 82598
  * Bộ điều khiển Ethernet Intel(R) 82599
  * Bộ điều khiển Ethernet Intel(R) X520
  * Bộ điều khiển Ethernet Intel(R) X540
  * Bộ điều khiển Ethernet Intel(R) x550
  * Bộ điều khiển Ethernet Intel(R) X552
  * Bộ điều khiển Ethernet Intel(R) X553

Để biết thông tin về cách xác định bộ điều hợp của bạn và để có phiên bản Intel mới nhất
trình điều khiển mạng, hãy tham khảo trang web Hỗ trợ của Intel:
ZZ0000ZZ

Sự cố đã biết/Khắc phục sự cố
============================

SR-IOV yêu cầu nền tảng và hệ điều hành hỗ trợ chính xác.

Hệ điều hành khách tải trình điều khiển này phải hỗ trợ các ngắt MSI-X.

Trình điều khiển này chỉ được hỗ trợ dưới dạng mô-đun có thể tải vào thời điểm này. Intel thì không
cung cấp các bản vá đối với nguồn kernel để cho phép liên kết tĩnh của
trình điều khiển.

Vlan: Có giới hạn tổng cộng 64 Vlan được chia sẻ cho 1 hoặc nhiều VF.


Ủng hộ
=======
Để biết thông tin chung, hãy truy cập trang web hỗ trợ của Intel tại:
ZZ0000ZZ

Nếu xác định được sự cố với mã nguồn đã phát hành trên hạt nhân được hỗ trợ
với bộ điều hợp được hỗ trợ, hãy gửi email thông tin cụ thể liên quan đến sự cố
tới intel-wired-lan@lists.osuosl.org.