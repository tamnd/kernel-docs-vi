.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-crypt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========
dm-mật mã
========

Mục tiêu "mật mã" của Device-Mapper cung cấp mã hóa minh bạch cho các thiết bị khối
sử dụng mật mã hạt nhân API.

Để biết mô tả chi tiết hơn về các tham số được hỗ trợ, hãy xem:
ZZ0000ZZ

Thông số::

<cipher> <key> <iv_offset> <đường dẫn thiết bị> \
	      <bù đắp> [<#opt_params> <opt_params>]

<mật mã>
    Mật mã mã hóa, chế độ mã hóa và trình tạo Vector ban đầu (IV).

Định dạng thông số kỹ thuật mã hóa là::

cipher[:keycount]-chainmode-ivmode[:ivopts]

Ví dụ::

aes-cbc-essiv:sha256
       aes-xts-plain64
       con rắn-xts-plain64

Định dạng mật mã cũng hỗ trợ đặc tả trực tiếp với mật mã kernel API
    định dạng (được chọn bởi tiền tố capi:). Thông số kỹ thuật IV giống nhau
    đối với loại định dạng đầu tiên.
    Định dạng này chủ yếu được sử dụng để đặc tả các chế độ được xác thực.

Định dạng thông số kỹ thuật mật mã API của tiền điện tử là::

capi:cipher_api_spec-ivmode[:ivopts]

Ví dụ::

capi:cbc(aes)-essiv:sha256
        capi:xts(aes)-plain64

Ví dụ về các chế độ được xác thực::

capi:gcm(aes)-ngẫu nhiên
        capi:authenc(hmac(sha256),xts(aes))-random
        capi:rfc7539(chacha20,poly1305)-ngẫu nhiên

/proc/crypto chứa danh sách các chế độ mật mã hiện được tải.

<chìa khóa>
    Khóa được sử dụng để mã hóa. Nó được mã hóa dưới dạng số thập lục phân
    hoặc nó có thể được chuyển dưới dạng <key_string> có tiền tố bằng dấu hai chấm đơn
    ký tự (':') cho các khóa nằm trong dịch vụ khóa kernel.
    Bạn chỉ có thể sử dụng kích thước khóa hợp lệ cho mật mã đã chọn
    kết hợp với chế độ iv đã chọn.
    Lưu ý rằng đối với một số chế độ iv, chuỗi khóa có thể chứa thêm
    các khóa (ví dụ như hạt IV) nên khóa chứa nhiều phần được nối hơn
    thành một chuỗi duy nhất.

<key_string>
    Khóa khóa hạt nhân được xác định bằng chuỗi theo định dạng sau:
    <key_size>:<key_type>:<key_description>.

<key_size>
    Kích thước khóa mã hóa tính bằng byte. Kích thước tải trọng khóa kernel phải khớp
    giá trị được truyền vào <key_size>.

<key_type>
    Loại khóa hạt nhân 'đăng nhập', 'người dùng', 'được mã hóa' hoặc 'đáng tin cậy'.

<key_description>
    Mục tiêu mật mã mô tả khóa nhân khóa sẽ tìm kiếm
    khi tải khóa của <key_type>.

<số phím>
    Chế độ tương thích đa phím. Bạn có thể xác định các phím <keycount> và
    sau đó các khu vực được mã hóa theo độ lệch của chúng (khu vực 0 sử dụng khóa0;
    khu vực 1 sử dụng key1, v.v.).  <keycount> phải là lũy thừa của hai.

<iv_offset>
    Phần bù IV là số lượng khu vực được thêm vào số khu vực
    trước khi tạo IV.

<đường dẫn thiết bị>
    Đây là thiết bị sẽ được sử dụng làm phụ trợ và chứa
    dữ liệu được mã hóa.  Bạn có thể chỉ định nó làm đường dẫn như/dev/xxx hoặc một thiết bị
    số <chính>:<thứ>.

<bù đắp>
    Khu vực bắt đầu trong thiết bị nơi dữ liệu được mã hóa bắt đầu.

<#opt_params>
    Số lượng tham số tùy chọn. Nếu không có tham số tùy chọn,
    phần tham số tùy chọn có thể được bỏ qua hoặc #opt_params có thể bằng 0.
    Mặt khác #opt_params là số đối số sau.

Ví dụ về phần tham số tùy chọn:
        3 allow_discards giống_cpu_crypt submit_from_crypt_cpus

allow_discards
    Yêu cầu loại bỏ khối (còn gọi là TRIM) được chuyển qua thiết bị mật mã.
    Mặc định là bỏ qua các yêu cầu loại bỏ.

WARNING: Đánh giá cẩn thận các rủi ro bảo mật cụ thể trước khi kích hoạt tính năng này
    tùy chọn.  Ví dụ: cho phép loại bỏ trên thiết bị được mã hóa có thể dẫn đến
    sự rò rỉ thông tin về thiết bị bản mã (loại hệ thống tập tin,
    không gian đã sử dụng, v.v.) nếu các khối bị loại bỏ có thể được định vị dễ dàng trên
    thiết bị sau này.

Same_cpu_crypt
    Thực hiện mã hóa bằng cùng một CPU mà IO đã được gửi.
    Mặc định là sử dụng hàng đợi công việc không liên kết để mã hóa hoạt động
    được tự động cân bằng giữa các CPU có sẵn.

ưu tiên cao
    Đặt hàng đợi công việc dm-crypt và luồng trình ghi ở mức ưu tiên cao. Cái này
    cải thiện thông lượng và độ trễ của dm-crypt trong khi làm giảm chất lượng chung
    khả năng đáp ứng của hệ thống.

gửi_from_crypt_cpus
    Tắt tính năng giảm tải ghi vào một luồng riêng biệt sau khi mã hóa.
    Có một số trường hợp giảm tải việc ghi bios từ
    các luồng mã hóa thành một luồng đơn làm giảm hiệu suất
    đáng kể.  Mặc định là giảm tải ghi bios vào cùng
    chủ đề vì nó mang lại lợi ích cho CFQ khi gửi bài viết bằng cách sử dụng
    cùng một bối cảnh.

no_read_workqueue
    Bỏ qua hàng đợi công việc nội bộ dm-crypt và xử lý các yêu cầu đọc một cách đồng bộ.

no_write_workqueue
    Bỏ qua hàng đợi công việc nội bộ dm-crypt và xử lý yêu cầu ghi một cách đồng bộ.
    Tùy chọn này được bật tự động cho các thiết bị khối được khoanh vùng do máy chủ quản lý
    (ví dụ: đĩa cứng SMR do máy chủ quản lý).

tính toàn vẹn:<byte>:<type>
    Thiết bị yêu cầu lưu trữ siêu dữ liệu <byte> bổ sung cho mỗi khu vực
    trong cấu trúc toàn vẹn theo từng sinh học. Siêu dữ liệu này phải được cung cấp
    bởi mục tiêu toàn vẹn dm cơ bản.

<type> có thể là "không" nếu siêu dữ liệu chỉ được sử dụng cho IV liên tục.

Để mã hóa xác thực với dữ liệu bổ sung (AEAD)
    <type> là "aead". Chế độ AEAD còn tính toán và xác minh
    tính toàn vẹn cho thiết bị được mã hóa. Không gian bổ sung sau đó là
    được sử dụng để lưu trữ thẻ xác thực (và IV liên tục nếu cần).

tính toàn vẹn_key_size:<byte>
    Tùy chọn đặt kích thước khóa toàn vẹn nếu nó khác với kích thước thông báo.
    Nó cho phép sử dụng các thuật toán khóa được bao bọc trong đó kích thước khóa là
    độc lập với kích thước khóa mật mã.

kích thước ngành:<byte>
    Sử dụng <bytes> làm đơn vị mã hóa thay vì các cung 512 byte.
    Tùy chọn này có thể nằm trong phạm vi 512 - 4096 byte và phải là lũy thừa của hai.
    Thiết bị ảo sẽ thông báo kích thước này dưới dạng IO và khu vực logic tối thiểu.

iv_large_sector
   Trình tạo IV sẽ sử dụng số khu vực được tính bằng đơn vị <sector_size>
   thay vì các cung 512 byte mặc định.

Ví dụ: nếu <sector_size> là 4096 byte, plain64 IV cho giây
   ngành sẽ là 8 (không có cờ) và 1 nếu có iv_large_sectors.
   <iv_offset> phải là bội số của <sector_size> (theo đơn vị 512 byte)
   nếu cờ này được chỉ định.

tính toàn vẹn_key_size:<byte>
   Sử dụng khóa toàn vẹn có kích thước <byte> thay vì sử dụng kích thước khóa toàn vẹn
   về kích thước tóm tắt của thuật toán HMAC đã sử dụng.


Thông số mô-đun::
   max_read_size
      Kích thước tối đa của yêu cầu đọc. Khi một yêu cầu lớn hơn kích thước này
      được nhận, dm-crypt sẽ phân chia yêu cầu. Sự phân chia được cải thiện
      đồng thời (các yêu cầu phân chia có thể được mã hóa song song bởi nhiều
      lõi), nhưng nó cũng gây ra chi phí. Người dùng nên điều chỉnh các thông số này để
      phù hợp với khối lượng công việc thực tế.

max_write_size
      Kích thước tối đa của yêu cầu ghi. Khi một yêu cầu lớn hơn kích thước này
      được nhận, dm-crypt sẽ phân chia yêu cầu. Sự phân chia được cải thiện
      đồng thời (các yêu cầu phân chia có thể được mã hóa song song bởi nhiều
      lõi), nhưng nó cũng gây ra chi phí. Người dùng nên điều chỉnh các thông số này để
      phù hợp với khối lượng công việc thực tế.


Tập lệnh mẫu
===============
LUKS (Thiết lập khóa hợp nhất Linux) hiện là cách ưa thích để thiết lập đĩa
mã hóa bằng dm-crypt bằng tiện ích 'cryptsetup', xem
ZZ0000ZZ

::

#!/bin/sh
	# Create một thiết bị mật mã sử dụng dmsetup
	dmsetup tạo crypt1 --table "0 ZZ0000ZZ mật mã aes-cbc-essiv:sha256 babebabebabebabebabebabebabebabe 0 $1 0"

::

#!/bin/sh
	# Create một thiết bị mật mã sử dụng dmsetup khi khóa mã hóa được lưu trữ trong dịch vụ khóa
	dmsetup tạo crypt2 --table "0 ZZ0000ZZ mật mã aes-cbc-essiv:sha256 :32:logon:my_prefix:my_key 0 $1 0"

::

#!/bin/sh
	# Create một thiết bị mã hóa sử dụng cryptsetup và tiêu đề LUKS với mật mã mặc định
	cryptsetup luksFormat $1
	cryptsetup luksMở $1 crypt1
