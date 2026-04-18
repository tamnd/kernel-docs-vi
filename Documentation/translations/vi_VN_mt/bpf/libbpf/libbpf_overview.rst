.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/bpf/libbpf/libbpf_overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
libbpf Tổng quan
=================

libbpf là một thư viện dựa trên C chứa trình tải BPF được biên dịch BPF
các tệp đối tượng, chuẩn bị và tải chúng vào nhân Linux. libbpf lấy
công việc nặng nhọc tải, xác minh và gắn các chương trình BPF vào nhiều
hook kernel, cho phép các nhà phát triển ứng dụng BPF chỉ tập trung vào chương trình BPF
tính đúng đắn và hiệu suất.

Sau đây là các tính năng cấp cao được libbpf hỗ trợ:

* Cung cấp API cấp cao và cấp thấp để các chương trình không gian người dùng tương tác
  với các chương trình BPF. Các API cấp thấp bao bọc tất cả lệnh gọi hệ thống bpf
  chức năng hữu ích khi người dùng cần kiểm soát chi tiết hơn
  qua sự tương tác giữa không gian người dùng và các chương trình BPF.
* Cung cấp hỗ trợ tổng thể cho khung đối tượng BPF được tạo bởi bpftool.
  Tệp bộ xương đơn giản hóa quy trình để các chương trình không gian người dùng truy cập
  các biến toàn cục và hoạt động với các chương trình BPF.
* Cung cấp APIS phía BPF, bao gồm các định nghĩa trợ giúp BPF, hỗ trợ bản đồ BPF,
  và truy tìm người trợ giúp, cho phép các nhà phát triển đơn giản hóa việc viết mã BPF.
* Hỗ trợ cơ chế BPF CO-RE, cho phép các nhà phát triển BPF viết di động
  Các chương trình BPF có thể được biên dịch một lần và chạy trên các kernel khác nhau
  các phiên bản.

Tài liệu này sẽ đi sâu vào các khái niệm trên một cách chi tiết, cung cấp một cái nhìn sâu hơn
hiểu biết về khả năng và lợi thế của libbpf cũng như cách nó có thể trợ giúp
bạn phát triển các ứng dụng BPF một cách hiệu quả.

API libbpf và vòng đời ứng dụng BPF
==================================

Một ứng dụng BPF bao gồm một hoặc nhiều chương trình BPF (có thể hợp tác hoặc
hoàn toàn độc lập), bản đồ BPF và các biến toàn cục. Toàn cầu
các biến được chia sẻ giữa tất cả các chương trình BPF, cho phép chúng hợp tác trên
một tập dữ liệu chung. libbpf cung cấp các API mà các chương trình không gian người dùng có thể sử dụng để
thao tác các chương trình BPF bằng cách kích hoạt các giai đoạn khác nhau của ứng dụng BPF
vòng đời.

Phần sau đây cung cấp tổng quan ngắn gọn về từng giai đoạn trong vòng đời BPF
chu kỳ:

* ZZ0000ZZ: Trong giai đoạn này, libbpf phân tích BPF
  tệp đối tượng và khám phá bản đồ BPF, chương trình BPF và các biến toàn cục. Sau
  ứng dụng BPF được mở, ứng dụng không gian người dùng có thể thực hiện các điều chỉnh bổ sung
  (cài đặt các loại chương trình BPF, nếu cần; cài đặt trước các giá trị ban đầu cho
  các biến toàn cục, v.v.) trước khi tất cả các thực thể được tạo và tải.

* ZZ0000ZZ: Trong giai đoạn tải, libbpf tạo BPF
  ánh xạ, giải quyết các lần di chuyển khác nhau, xác minh và tải các chương trình BPF vào
  hạt nhân. Tại thời điểm này, libbpf xác thực tất cả các phần của ứng dụng BPF
  và tải chương trình BPF vào kernel, nhưng vẫn chưa có chương trình BPF nào được cài đặt.
  bị xử tử. Sau giai đoạn tải, có thể thiết lập bản đồ BPF ban đầu
  trạng thái mà không phải chạy đua với việc thực thi mã chương trình BPF.

* ZZ0000ZZ: Trong giai đoạn này, libbpf
  gắn các chương trình BPF vào các điểm nối BPF khác nhau (ví dụ: dấu vết, kprobes,
  móc nhóm, đường ống xử lý gói mạng, v.v.). Trong thời gian này
  pha, các chương trình BPF thực hiện công việc hữu ích như xử lý
  gói hoặc cập nhật bản đồ BPF và các biến toàn cục có thể được đọc từ người dùng
  không gian.

* ZZ0000ZZ: Trong giai đoạn tháo dỡ,
  libbpf tách các chương trình BPF và dỡ chúng khỏi kernel. Bản đồ BPF là
  bị phá hủy và tất cả tài nguyên mà ứng dụng BPF sử dụng sẽ được giải phóng.

Tệp bộ xương đối tượng BPF
========================

Bộ xương BPF là một giao diện thay thế cho API libbpf để làm việc với BPF
đồ vật. Mã Skeleton trừu tượng hóa các API libbpf chung một cách đáng kể
đơn giản hóa mã để thao tác các chương trình BPF từ không gian người dùng. Mã xương
bao gồm một biểu diễn mã byte của tệp đối tượng BPF, đơn giản hóa
quá trình phân phối mã BPF của bạn. Với mã byte BPF được nhúng, không có
các tệp bổ sung để triển khai cùng với tệp nhị phân ứng dụng của bạn.

Bạn có thể tạo tệp tiêu đề khung ZZ0000ZZ cho một đối tượng cụ thể
tệp bằng cách chuyển đối tượng BPF tới bpftool. Bộ xương BPF được tạo
cung cấp các chức năng tùy chỉnh sau tương ứng với vòng đời BPF,
mỗi trong số chúng có tiền tố là tên đối tượng cụ thể:

* ZZ0000ZZ – tạo và mở ứng dụng BPF (ZZ0001ZZ là viết tắt của
  tên đối tượng bpf cụ thể)
* ZZ0002ZZ – khởi tạo, tải và xác minh các phần ứng dụng BPF
* ZZ0003ZZ – đính kèm tất cả các chương trình BPF có thể tự động đính kèm (đó là
  tùy chọn, bạn có thể có nhiều quyền kiểm soát hơn bằng cách sử dụng trực tiếp API libbpf)
* ZZ0004ZZ – tách tất cả các chương trình BPF và
  giải phóng tất cả các tài nguyên đã sử dụng

Sử dụng mã khung là cách được khuyến nghị để làm việc với các chương trình bpf. Giữ
Lưu ý, bộ xương BPF cung cấp quyền truy cập vào đối tượng BPF cơ bản, vì vậy bất kể điều gì
vẫn có thể thực hiện được với các API libbpf chung ngay cả khi BPF
bộ xương được sử dụng. Đây là một tính năng tiện lợi bổ sung, không có cuộc gọi tổng hợp và không có
mã rườm rà.

Ưu điểm khác của việc sử dụng tệp Skeleton
---------------------------------------

* Bộ xương BPF cung cấp giao diện cho các chương trình không gian người dùng hoạt động với BPF
  các biến toàn cục. Bộ nhớ mã khung ánh xạ các biến toàn cục dưới dạng cấu trúc
  vào không gian người dùng. Giao diện struct cho phép các chương trình không gian người dùng khởi tạo
  BPF lập trình trước giai đoạn tải BPF và tìm nạp và cập nhật dữ liệu từ người dùng
  không gian sau đó.

* Tệp ZZ0000ZZ phản ánh cấu trúc tệp đối tượng bằng cách liệt kê
  bản đồ, chương trình có sẵn, v.v. Bộ xương BPF cung cấp quyền truy cập trực tiếp vào tất cả
  Bản đồ BPF và chương trình BPF dưới dạng trường cấu trúc. Điều này giúp loại bỏ sự cần thiết
  tra cứu dựa trên chuỗi với ZZ0001ZZ và
  API ZZ0002ZZ, giảm lỗi do nguồn BPF
  mã và mã không gian người dùng không đồng bộ.

* Biểu diễn mã byte nhúng của tệp đối tượng đảm bảo rằng
  bộ xương và tệp đối tượng BPF luôn được đồng bộ hóa.

Người trợ giúp BPF
===========

libbpf cung cấp các API phía BPF mà các chương trình BPF có thể sử dụng để tương tác với
hệ thống. Định nghĩa trình trợ giúp BPF cho phép các nhà phát triển sử dụng chúng trong mã BPF như
bất kỳ hàm C đơn giản nào khác. Ví dụ: có các hàm trợ giúp để in
thông báo gỡ lỗi, xem thời gian kể từ khi hệ thống được khởi động, tương tác với BPF
bản đồ, thao tác các gói mạng, v.v.

Để có mô tả đầy đủ về những gì người trợ giúp làm, các lập luận họ đưa ra và
giá trị trả về, hãy xem trang man ZZ0000ZZ.

BPF CO-RE (Biên dịch một lần – Chạy mọi nơi)
=========================================

Các chương trình BPF hoạt động trong không gian kernel và có quyền truy cập vào bộ nhớ và dữ liệu kernel
các cấu trúc. Một hạn chế mà các ứng dụng BPF gặp phải là thiếu
tính di động trên các phiên bản và cấu hình kernel khác nhau. ZZ0000ZZ là một trong những giải pháp dành cho BPF
tính di động. Tuy nhiên, nó đi kèm với chi phí thời gian chạy và kích thước nhị phân lớn
từ việc nhúng trình biên dịch vào ứng dụng.

libbpf nâng cao tính di động của chương trình BPF bằng cách hỗ trợ khái niệm BPF CO-RE.
BPF CO-RE tập hợp thông tin loại BTF, libbpf và trình biên dịch để
tạo ra một tệp nhị phân thực thi duy nhất mà bạn có thể chạy trên nhiều phiên bản kernel
và cấu hình.

Để tạo các chương trình BPF, libbpf di động dựa vào thông tin loại BTF của
chạy hạt nhân. Kernel cũng tiết lộ BTF có thẩm quyền tự mô tả này
thông tin qua ZZ0000ZZ tại ZZ0001ZZ.

Bạn có thể tạo thông tin BTF cho kernel đang chạy bằng cách sau
lệnh:

::

$ bpftool btf tệp kết xuất /sys/kernel/btf/vmlinux định dạng c > vmlinux.h

Lệnh tạo tệp tiêu đề ZZ0001ZZ với tất cả các loại kernel
(ZZ0000ZZ) mà kernel đang chạy sử dụng. Bao gồm
ZZ0002ZZ trong chương trình BPF của bạn sẽ loại bỏ sự phụ thuộc vào kernel toàn hệ thống
tiêu đề.

libbpf cho phép tính di động của các chương trình BPF bằng cách xem chương trình BPF
đã ghi lại loại BTF và thông tin di chuyển và khớp chúng với BTF
thông tin (vmlinux) được cung cấp bởi kernel đang chạy. libbpf sau đó giải quyết và
khớp với tất cả các loại và trường, đồng thời cập nhật các giá trị bù trừ cần thiết và các giá trị khác
dữ liệu có thể định vị lại để đảm bảo logic của chương trình BPF hoạt động chính xác cho
kernel cụ thể trên máy chủ. Do đó, khái niệm BPF CO-RE giúp loại bỏ chi phí
liên kết với sự phát triển BPF và cho phép các nhà phát triển viết BPF di động
các ứng dụng không cần sửa đổi và biên dịch mã nguồn thời gian chạy trên
máy mục tiêu.

Đoạn mã sau đây cho biết cách đọc trường cha của hạt nhân
ZZ0000ZZ sử dụng BPF CO-RE và libbf. Trình trợ giúp cơ bản để đọc một trường trong một
Cách có thể định vị lại CO-RE là ZZ0001ZZ, sẽ đọc
Các byte ZZ0002ZZ từ trường được tham chiếu bởi ZZ0003ZZ vào bộ nhớ được trỏ bởi
ZZ0004ZZ.

.. code-block:: C
   :emphasize-lines: 6

    //...
    struct task_struct *task = (void *)bpf_get_current_task();
    struct task_struct *parent_task;
    int err;

    err = bpf_core_read(&parent_task, sizeof(void *), &task->parent);
    if (err) {
      /* handle error */
    }

    /* parent_task contains the value of task->parent pointer */

Trong đoạn mã, trước tiên chúng ta lấy một con trỏ tới ZZ0000ZZ hiện tại bằng cách sử dụng
ZZ0001ZZ.  Sau đó chúng tôi sử dụng ZZ0002ZZ để đọc phần gốc
trường cấu trúc nhiệm vụ vào biến ZZ0003ZZ. ZZ0004ZZ là
giống như trình trợ giúp ZZ0005ZZ BPF, ngoại trừ việc nó ghi lại thông tin
về trường cần được di dời trên kernel đích. tức là, nếu
Trường ZZ0006ZZ được chuyển sang phần bù khác trong
ZZ0007ZZ do một số trường mới được thêm vào phía trước nó, libbpf sẽ
tự động điều chỉnh độ lệch thực tế về giá trị thích hợp.

Bắt đầu với libbpf
===========================

Hãy kiểm tra ZZ0000ZZ
kho lưu trữ với các ví dụ đơn giản về cách sử dụng libbpf để xây dựng nhiều BPF khác nhau
ứng dụng.

Xem thêm ZZ0000ZZ.

libbpf và Rust
===============

Nếu bạn đang xây dựng các ứng dụng BPF trong Rust, bạn nên sử dụng
Thư viện ZZ0000ZZ thay vì bindgen
liên kết trực tiếp với libbpf. Libbpf-rs bao bọc chức năng libbpf trong
Giao diện đặc trưng của Rust và cung cấp plugin libbpf-cargo để xử lý mã BPF
biên dịch và tạo bộ xương. Sử dụng Libbpf-rs sẽ khiến người dùng xây dựng
phần không gian của ứng dụng BPF dễ dàng hơn. Lưu ý rằng bản thân chương trình BPF
vẫn phải được viết bằng chữ C.

ghi nhật ký libbpf
==============

Theo mặc định, libbpf ghi các thông báo thông tin và cảnh báo vào stderr. các
độ dài của các thông báo này có thể được kiểm soát bằng cách thiết lập môi trường
biến LIBBPF_LOG_LEVEL để cảnh báo, thông tin hoặc gỡ lỗi. Nhật ký tùy chỉnh
gọi lại có thể được đặt bằng ZZ0000ZZ.

Tài liệu bổ sung
========================

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ
* ZZ0003ZZ