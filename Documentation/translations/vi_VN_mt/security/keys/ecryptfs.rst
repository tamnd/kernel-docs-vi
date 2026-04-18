.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/keys/ecryptfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================================
Khóa được mã hóa cho hệ thống tệp eCryptfs
==============================================

ECryptfs là một hệ thống tập tin xếp chồng lên nhau, mã hóa và giải mã một cách minh bạch từng tập tin.
tệp bằng Khóa mã hóa tệp được tạo ngẫu nhiên (FEK).

Mỗi FEK lần lượt được mã hóa bằng Khóa mã hóa khóa mã hóa tệp (FEKEK)
trong không gian kernel hoặc trong không gian người dùng có daemon gọi là 'ecryptfsd'.  trong
trường hợp trước, thao tác được thực hiện trực tiếp bởi kernel CryptoAPI
sử dụng khóa, FEKEK, bắt nguồn từ cụm mật khẩu được người dùng nhắc;  ở phần sau
FEK được mã hóa bởi 'ecryptfsd' với sự trợ giúp của các thư viện bên ngoài để
để hỗ trợ các cơ chế khác như mật mã khóa công khai, dựa trên PKCS#11 và TPM
hoạt động.

Cấu trúc dữ liệu được xác định bởi eCryptfs để chứa thông tin cần thiết cho
Giải mã FEK được gọi là mã thông báo xác thực và hiện tại có thể được lưu trữ trong
khóa hạt nhân thuộc loại 'người dùng', được chèn vào khóa cụ thể theo phiên của người dùng
bởi tiện ích không gian người dùng 'mount.ecryptfs' được gửi kèm theo gói
'ecryptfs-utils'.

Loại khóa 'được mã hóa' đã được mở rộng với việc giới thiệu loại khóa mới
định dạng 'ecryptfs' để được sử dụng cùng với eCryptfs
hệ thống tập tin.  Khóa mã hóa của định dạng mới được giới thiệu sẽ lưu trữ một
mã thông báo xác thực trong tải trọng của nó với FEKEK được tạo ngẫu nhiên bởi
kernel và được bảo vệ bởi khóa chính gốc.

Để tránh các cuộc tấn công bằng văn bản rõ ràng, datablob thu được thông qua
lệnh 'keyctl print' hoặc 'keyctl pipe' không chứa tổng thể
mã thông báo xác thực, nội dung nào được nhiều người biết đến nhưng chỉ có FEKEK trong
dạng được mã hóa.

Hệ thống tập tin eCryptfs có thể thực sự được hưởng lợi từ việc sử dụng các khóa được mã hóa trong đó
khóa bắt buộc có thể được Quản trị viên tạo một cách an toàn và được cung cấp khi khởi động
thời gian sau khi mở khóa 'đáng tin cậy' để thực hiện việc gắn kết trong một
môi trường được kiểm soát.  Một ưu điểm khác là chìa khóa không bị lộ
mối đe dọa của phần mềm độc hại, bởi vì nó chỉ có sẵn ở dạng rõ ràng tại
cấp độ hạt nhân.

Cách sử dụng::

keyctl thêm tên được mã hóa vòng "new ecryptfs key-type:master-key-name keylen"
   keyctl thêm tên được mã hóa vòng "load hex_blob"
   keyctl cập nhật keyid "cập nhật loại khóa:tên khóa chính"

Ở đâu::

name:= '<16 ký tự thập lục phân>'
	key-type:= 'đáng tin cậy' | 'người dùng'
	keylen:= 64


Ví dụ về cách sử dụng khóa được mã hóa với hệ thống tệp eCryptfs:

Tạo khóa mã hóa "1000100010001000" có độ dài 64 byte với định dạng
'ecryptfs' và lưu nó bằng khóa người dùng đã tải trước đó "test"::

$ keyctl thêm mã hóa 1000100010001000 "người dùng ecryptfs mới: test 64" @u
    19184530

$ in keyctl 19184530
    Người dùng ecryptfs:kiểm tra 64 490045d4bfe48c99f0d465fbbbb79e7500da954178e2de0697
    dd85091f5450a0511219e9f7cd70dcd498038181466f78ac8d4c19504fcc72402bfc41c2
    f253a41b7507ccaa4b2b03fff19a69d1cc0b16e71746473f023a95488b6edfd86f7fdd40
    9d292e4bacded1258880122dd553a661

$ keyctl ống 19184530 > ecryptfs.blob

Gắn hệ thống tệp eCryptfs bằng khóa mã hóa đã tạo "1000100010001000"
vào thư mục '/secret'::

$ mount -i -t ecryptfs -oecryptfs_sig=1000100010001000,\
      ecryptfs_cipher=aes,ecryptfs_key_bytes=32 /bí mật /bí mật
