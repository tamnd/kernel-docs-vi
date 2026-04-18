.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/dns_resolver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Mô-đun bộ giải quyết DNS
===================

.. Contents:

 - Overview.
 - Compilation.
 - Setting up.
 - Usage.
 - Mechanism.
 - Debugging.


Tổng quan
========

Mô-đun trình phân giải DNS cung cấp một cách để các dịch vụ kernel thực hiện các truy vấn DNS
bằng cách yêu cầu một khóa thuộc loại khóa dns_resolver.  Những truy vấn này được
được gọi lên không gian người dùng thông qua /sbin/request-key.

Các quy trình này phải được hỗ trợ bởi các công cụ không gian người dùng dns.upcall, cifs.upcall và
khóa yêu cầu.  Nó đang được phát triển và chưa cung cấp đầy đủ tính năng
thiết lập.  Các tính năng nó hỗ trợ bao gồm:

* Triển khai dns_resolver key_type để liên hệ với không gian người dùng.

Nó chưa hỗ trợ các tính năng AFS sau:

* Hỗ trợ truy vấn DNS cho bản ghi tài nguyên AFSDB.

Mã này được trích xuất từ ​​hệ thống tập tin CIFS.


biên soạn
===========

Mô-đun này phải được kích hoạt bằng cách bật các tùy chọn cấu hình kernel::

CONFIG_DNS_RESOLVER - tristate "Hỗ trợ bộ giải quyết DNS"


Đang thiết lập
==========

Để thiết lập cơ sở này, tệp /etc/request-key.conf phải được thay đổi để
/sbin/request-key có thể chỉ đạo các lệnh gọi lên một cách thích hợp.  Ví dụ, để xử lý
dname cơ bản thành độ phân giải địa chỉ IPv4/IPv6, dòng sau phải là
đã thêm::


#OP TYPE DESC CO-INFO PROGRAM ARG1 ARG2 ARG3 ...
	#====== ========================= =============================
	tạo dns_resolver * * /usr/sbin/cifs.upcall %k

Để hướng một truy vấn cho loại truy vấn 'foo', cần thêm một dòng sau
trước dòng tổng quát hơn được đưa ra ở trên vì trận đấu đầu tiên là trận đấu được thực hiện ::

tạo dns_resolver foo:* * /usr/sbin/dns.foo %k


Cách sử dụng
=====

Để sử dụng cơ sở này, trước tiên phải bao gồm ZZ0000ZZ::

#include <linux/dns_resolver.h>

Sau đó, các truy vấn có thể được thực hiện bằng cách gọi::

int dns_query(const char *type, const char *name, size_t namelen,
		     const char *options, char **_result, time_t *_expiry);

Đây là chức năng truy cập cơ bản.  Nó tìm kiếm một truy vấn DNS được lưu trong bộ nhớ cache và nếu
nó không tìm thấy nó, nó gọi lên không gian người dùng để tạo một truy vấn DNS mới, truy vấn này
sau đó có thể được lưu trữ.  Mô tả khóa được xây dựng dưới dạng một chuỗi của
hình thức::

[<loại>:]<tên>

trong đó <type> tùy chọn chỉ định chương trình upcall cụ thể để gọi,
và do đó loại truy vấn và <name> chỉ định chuỗi cần tra cứu.
Loại truy vấn mặc định là tra cứu tên máy chủ trực tiếp tới địa chỉ IP.

Tham số tên không bắt buộc phải là chuỗi kết thúc NUL và
độ dài phải được đưa ra bởi đối số namelen.

Tham số tùy chọn có thể là NULL hoặc có thể là một tập hợp các tùy chọn
phù hợp với loại truy vấn.

Giá trị trả về là một chuỗi phù hợp với loại truy vấn.  Ví dụ,
đối với loại truy vấn mặc định, nó chỉ là danh sách IPv4 được phân tách bằng dấu phẩy và
Địa chỉ IPv6.  Người gọi phải giải phóng kết quả.

Độ dài của chuỗi kết quả được trả về nếu thành công và giá trị âm
mã lỗi được trả về nếu không.  -EKEYREJECTED sẽ được trả lại nếu
Tra cứu DNS không thành công.

Nếu _expiry không phải là NULL thì thời gian hết hạn (TTL) của kết quả sẽ là
cũng quay về.

Hạt nhân duy trì một chuỗi khóa bên trong để lưu trữ các khóa đã tra cứu.
Điều này có thể được xóa bởi bất kỳ quy trình nào có khả năng CAP_SYS_ADMIN bằng cách
việc sử dụng KEYCTL_KEYRING_CLEAR trên ID khóa.


Đọc khóa DNS từ không gian người dùng
===============================

Các khóa thuộc loại dns_resolver có thể được đọc từ không gian người dùng bằng cách sử dụng keyctl_read() hoặc
"keyctl đọc/in/ống".


Cơ chế
=========

Mô-đun dns_resolver đăng ký loại khóa có tên là "dns_resolver".  Chìa khóa của
loại này được sử dụng để vận chuyển và lưu trữ các kết quả tra cứu DNS từ không gian người dùng.

Khi dns_query() được gọi, nó gọi request_key() để tìm kiếm cục bộ
dây móc khóa để có kết quả DNS được lưu trong bộ nhớ cache.  Nếu không tìm thấy, nó sẽ gọi tới
không gian người dùng để có được kết quả mới.

Các cuộc gọi tới không gian người dùng được thực hiện thông qua vectơ gọi lên request_key() và được
được hướng dẫn bằng các dòng cấu hình trong /etc/request-key.conf cho biết
/sbin/request-key nên chạy chương trình nào để khởi tạo khóa.

Chương trình xử lý cuộc gọi lên có trách nhiệm truy vấn DNS, xử lý
kết quả thành một dạng phù hợp để chuyển tới keyctl_instantiate_key()
thường lệ.  Sau đó, dữ liệu này sẽ chuyển đến dns_resolver_instantiate() để loại bỏ
tắt và xử lý mọi tùy chọn có trong dữ liệu, sau đó đính kèm
phần còn lại của chuỗi vào khóa làm tải trọng của nó.

Chương trình xử lý cuộc gọi lên sẽ đặt thời gian hết hạn trên khóa tương ứng với thời gian của
TTL thấp nhất trong số tất cả các bản ghi mà nó đã trích xuất từ đó.  Điều này có nghĩa là
khóa sẽ bị loại bỏ và được tạo lại khi dữ liệu chứa trong đó hết hạn.

dns_query() trả về bản sao của giá trị được đính kèm với khóa hoặc trả về lỗi nếu
thay vào đó, điều đó được chỉ định.

Xem Tài liệu/bảo mật/khóa/request-key.rst để biết thêm thông tin về
chức năng khóa yêu cầu.


Gỡ lỗi
=========

Thông báo gỡ lỗi có thể được bật động bằng cách viết số 1 vào
tập tin sau::

/sys/module/dns_resolver/tham số/gỡ lỗi