.. SPDX-License-Identifier: BSD-3-Clause

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/netlink/intro-specs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Sử dụng thông số kỹ thuật giao thức Netlink
=====================================

Tài liệu này là hướng dẫn bắt đầu nhanh để sử dụng giao thức Netlink
thông số kỹ thuật. Để biết mô tả chi tiết hơn về thông số kỹ thuật, hãy xem ZZ0000ZZ.

CLI đơn giản
==========

Kernel đi kèm với một công cụ CLI đơn giản sẽ hữu ích khi
phát triển mã liên quan đến Netlink. Công cụ này được triển khai bằng Python
và có thể sử dụng đặc tả YAML để đưa ra yêu cầu Netlink
tới hạt nhân.

Công cụ này được đặt tại ZZ0000ZZ. Nó chấp nhận
một số lý lẽ, những lý lẽ quan trọng nhất là:

- ZZ0000ZZ - trỏ tới file spec
 - ZZ0001ZZ / ZZ0002ZZ - yêu cầu phát hành ZZ0003ZZ
 - ZZ0004ZZ - cung cấp thuộc tính cho yêu cầu
 - ZZ0005ZZ - nhận thông báo từ ZZ0006ZZ

Thông số kỹ thuật của YAML có thể được tìm thấy trong ZZ0000ZZ.

Ví dụ sử dụng::

$ ./tools/net/ynl/pyynl/cli.py --spec Tài liệu/netlink/specs/ethtool.yaml \
        --làm nhẫn-get \
	--json '{"tiêu đề":{"dev-index": 18}}'
  {'tiêu đề': {'dev-index': 18, 'dev-name': 'eni1np1'},
   'rx': 0,
   'rx-jumbo': 0,
   'rx-jumbo-max': 4096,
   'rx-max': 4096,
   'rx-mini': 0,
   'rx-mini-max': 4096,
   'tx': 0,
   'tx-max': 4096,
   'tx-push': 0}

Các đối số đầu vào được phân tích cú pháp là JSON, trong khi đầu ra chỉ là
Python-in đẹp. Điều này là do một số loại Netlink không thể
được thể hiện trực tiếp dưới dạng JSON. Nếu những thuộc tính đó là cần thiết trong
việc nhập một số bản hack của tập lệnh sẽ là cần thiết.

Thông số kỹ thuật và nội bộ Netlink được coi là độc lập
thư viện - thật dễ dàng để viết lại các công cụ/kiểm tra Python
mã từ ZZ0000ZZ.

Tạo mã hạt nhân
======================

ZZ0000ZZ quét cây nhân để tìm kiếm
các tập tin được tạo tự động cần được cập nhật. Sử dụng công cụ này là dễ nhất
cách tạo/cập nhật mã được tạo tự động.

Theo mặc định, mã chỉ được tạo lại nếu thông số kỹ thuật mới hơn nguồn,
để buộc tái sinh sử dụng ZZ0000ZZ.

ZZ0000ZZ tìm kiếm ZZ0001ZZ trong nội dung của tệp
(lưu ý rằng nó chỉ quét các tệp trong chỉ mục git, đó chỉ là các tệp
được theo dõi bởi git!) Ví dụ: nguồn kernel ZZ0002ZZ chứa ::

/* Tài liệu/netlink/specs/fou.yaml */
  /* Nguồn hạt nhân YNL-GEN */

ZZ0000ZZ sẽ tìm điểm đánh dấu này và thay thế tệp bằng
nguồn kernel dựa trên fou.yaml.

Cách đơn giản nhất để tạo một tệp mới dựa trên thông số kỹ thuật là thêm
hai dòng đánh dấu như trên vào một tệp, thêm tệp đó vào git,
và chạy công cụ tái tạo. Grep cây cho ZZ0000ZZ
để xem các ví dụ khác.

Việc tạo mã được thực hiện bởi ZZ0000ZZ
nhưng phải mất một vài đối số nên gọi trực tiếp cho từng tệp
nhanh chóng trở nên nhàm chán.

YNL lib
=======

ZZ0000ZZ chứa triển khai thư viện C
(dựa trên libmnl) tích hợp với mã được tạo bởi
ZZ0001ZZ để tạo các trình bao bọc liên kết mạng dễ sử dụng.

Thông tin cơ bản về YNL
----------

Thư viện YNL bao gồm hai phần - mã chung (chức năng
tiền tố của ZZ0000ZZ) và mã được tạo tự động cho mỗi họ (có tiền tố
với tên của gia đình).

Để tạo ổ cắm YNL, hãy gọi ynl_sock_create() chuyển qua họ
struct (cấu trúc gia đình được xuất bằng mã được tạo tự động).
ynl_sock_destroy() đóng ổ cắm.

Yêu cầu YNL
------------

Các bước đưa ra yêu cầu YNL được giải thích rõ nhất trên một ví dụ.
Tất cả các hàm và kiểu trong ví dụ này đều đến từ tệp được tạo tự động
mã (đối với họ netdev trong trường hợp này):

.. code-block:: c

   // 0. Request and response pointers
   struct netdev_dev_get_req *req;
   struct netdev_dev_get_rsp *d;

   // 1. Allocate a request
   req = netdev_dev_get_req_alloc();
   // 2. Set request parameters (as needed)
   netdev_dev_get_req_set_ifindex(req, ifindex);

   // 3. Issues the request
   d = netdev_dev_get(ys, req);
   // 4. Free the request arguments
   netdev_dev_get_req_free(req);
   // 5. Error check (the return value from step 3)
   if (!d) {
	// 6. Print the YNL-generated error
	fprintf(stderr, "YNL: %s\n", ys->err.msg);
        return -1;
   }

   // ... do stuff with the response @d

   // 7. Free response
   netdev_dev_get_rsp_free(d);

Đổ YNL
---------

Việc thực hiện kết xuất theo mô hình tương tự như yêu cầu.
Kết xuất trả về danh sách các đối tượng được kết thúc bằng một điểm đánh dấu đặc biệt,
hoặc NULL bị lỗi. Sử dụng ZZ0000ZZ để lặp lại
kết quả.

Thông báo YNL
-----------------

YNL lib hỗ trợ sử dụng cùng một ổ cắm cho thông báo và
yêu cầu. Trong trường hợp thông báo đến trong quá trình xử lý yêu cầu
chúng được xếp hàng nội bộ và có thể được lấy ra sau đó.

Để đăng ký nhận thông báo, hãy sử dụng ZZ0000ZZ.
Các thông báo phải được đọc từ ổ cắm,
ZZ0001ZZ trả về ổ cắm fd cơ bản có thể
được cắm vào IO API không đồng bộ thích hợp như ZZ0002ZZ,
hoặc ZZ0003ZZ.

Thông báo có thể được truy xuất bằng ZZ0000ZZ và có
được giải phóng bằng ZZ0001ZZ. Vì chúng tôi không biết thông báo
gõ trước các thông báo được trả về dưới dạng ZZ0002ZZ
và người dùng dự kiến sẽ chuyển chúng sang loại đầy đủ thích hợp dựa trên
trên thành viên ZZ0003ZZ.