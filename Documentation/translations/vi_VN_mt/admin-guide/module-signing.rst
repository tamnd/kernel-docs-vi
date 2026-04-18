.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/module-signing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cơ sở ký mô-đun hạt nhân
------------------------------

.. CONTENTS
..
.. - Overview.
.. - Configuring module signing.
.. - Generating signing keys.
.. - Public keys in the kernel.
.. - Manually signing modules.
.. - Signed modules and stripping.
.. - Loading signed modules.
.. - Non-valid signatures and unsigned modules.
.. - Administering/protecting the private key.


=========
Tổng quan
=========

Cơ sở ký mô-đun hạt nhân ký mật mã mô-đun trong quá trình
cài đặt và sau đó kiểm tra chữ ký khi tải mô-đun.  Cái này
cho phép tăng cường bảo mật hạt nhân bằng cách không cho phép tải các mô-đun chưa được ký
hoặc các mô-đun được ký bằng khóa không hợp lệ.  Việc ký mô-đun tăng tính bảo mật bằng cách
làm cho việc tải mô-đun độc hại vào kernel trở nên khó khăn hơn.  mô-đun
Việc kiểm tra chữ ký được thực hiện bởi kernel nên không cần thiết phải có
bit không gian người dùng đáng tin cậy.

Cơ sở này sử dụng chứng chỉ tiêu chuẩn X.509 ITU-T để mã hóa khóa chung
có liên quan.  Bản thân các chữ ký không được mã hóa theo bất kỳ tiêu chuẩn công nghiệp nào
loại.  Cơ sở tích hợp hiện chỉ hỗ trợ RSA, NIST P-384 ECDSA
và các tiêu chuẩn ký khóa công khai NIST FIPS-204 ML-DSA (mặc dù nó có thể cắm được
và cho phép người khác được sử dụng).  Đối với RSA và ECDSA, hàm băm có thể có
các thuật toán có thể được sử dụng là SHA-2 và SHA-3 có kích thước 256, 384 và 512 (
thuật toán được chọn theo dữ liệu trong chữ ký); ML-DSA tự băm,
nhưng được phép sử dụng với hàm băm SHA512 cho các thuộc tính đã ký.


=============================
Định cấu hình ký mô-đun
=============================

Tiện ích ký mô-đun được kích hoạt bằng cách đi tới
Phần ZZ0000ZZ của
cấu hình kernel và bật ::

CONFIG_MODULE_SIG "Xác minh chữ ký mô-đun"

Điều này có một số tùy chọn có sẵn:

(1) ZZ0000ZZ
     (ZZ0001ZZ)

Điều này chỉ định cách kernel xử lý một mô-đun có
     chữ ký mà khóa không được biết hoặc mô-đun chưa được ký.

Nếu tùy chọn này tắt (tức là "cho phép"), thì các mô-đun không có khóa
     có sẵn và các mô-đun không được ký đều được phép, nhưng hạt nhân sẽ
     bị đánh dấu là bị nhiễm độc và các mô-đun liên quan sẽ được đánh dấu là
     bị vấy bẩn, hiển thị với ký tự 'E'.

Nếu tính năng này được bật (tức là "hạn chế"), chỉ các mô-đun có giá trị hợp lệ
     chữ ký có thể được xác minh bằng khóa chung do hạt nhân sở hữu
     sẽ được tải.  Tất cả các mô-đun khác sẽ tạo ra lỗi.

Bất kể cài đặt ở đây là gì, nếu mô-đun có khối chữ ký
     không thể phân tích được, nó sẽ bị từ chối ngay lập tức.


(2) ZZ0000ZZ
     (ZZ0001ZZ)

Nếu tính năng này được bật thì các mô-đun sẽ được ký tự động trong quá trình
     giai đoạn module_install của bản dựng.  Nếu tính năng này tắt thì các mô-đun phải
     được ký thủ công bằng cách sử dụng::

tập lệnh/tệp ký hiệu


(3) ZZ0000ZZ

Phần này đưa ra lựa chọn thuật toán băm nào mà giai đoạn cài đặt sẽ
     ký các mô-đun với:

==============================================================================
	ZZ0006ZZ ZZ0000ZZ
	ZZ0007ZZ ZZ0001ZZ
	ZZ0008ZZ ZZ0002ZZ
	ZZ0009ZZ ZZ0003ZZ
	ZZ0010ZZ ZZ0004ZZ
	ZZ0011ZZ ZZ0005ZZ
        ==============================================================================

Thuật toán được chọn ở đây cũng sẽ được tích hợp vào kernel (thay vì
     hơn là một mô-đun) để các mô-đun được ký bằng thuật toán đó có thể có
     chữ ký của họ được kiểm tra mà không gây ra vòng lặp phụ thuộc.


(4) ZZ0000ZZ
     (ZZ0001ZZ)

Đặt tùy chọn này thành một cái gì đó khác với mặc định của nó
     ZZ0000ZZ sẽ vô hiệu hóa tính năng tự động tạo khóa ký
     và cho phép các mô-đun hạt nhân được ký bằng khóa bạn chọn.
     Chuỗi được cung cấp sẽ xác định tệp chứa cả khóa riêng
     và chứng chỉ X.509 tương ứng của nó ở dạng PEM hoặc — trên các hệ thống có
     OpenSSL ENGINE_pkcs11 có chức năng - PKCS#11 URI như được định nghĩa bởi
     RFC7512. Trong trường hợp sau, PKCS#11 URI phải tham chiếu cả a
     chứng chỉ và một khóa riêng.

Nếu tệp PEM chứa khóa riêng được mã hóa hoặc nếu
     Mã thông báo PKCS#11 yêu cầu PIN, mã thông báo này có thể được cung cấp tại thời điểm xây dựng bởi
     có nghĩa là biến ZZ0000ZZ.


(5) ZZ0000ZZ
     (ZZ0001ZZ)

Tùy chọn này có thể được đặt thành tên tệp của tệp được mã hóa PEM có chứa
     các chứng chỉ bổ sung sẽ được bao gồm trong khóa hệ thống bởi
     mặc định.

Lưu ý rằng việc bật ký mô-đun sẽ thêm phần phụ thuộc vào quá trình phát triển OpenSSL
các gói vào quy trình xây dựng kernel cho công cụ thực hiện việc ký kết.


==========================
Tạo khóa ký
==========================

Cần có cặp khóa mật mã để tạo và kiểm tra chữ ký.  A
Khóa riêng được sử dụng để tạo chữ ký và khóa chung tương ứng là
dùng để kiểm tra nó.  Khóa riêng chỉ cần thiết trong quá trình xây dựng, sau đó
nó có thể bị xóa hoặc lưu trữ an toàn.  Khóa công khai được tích hợp vào
kernel để có thể sử dụng nó để kiểm tra chữ ký giống như các mô-đun
đã tải.

Trong điều kiện bình thường, khi ZZ0000ZZ không thay đổi so với
mặc định, bản dựng kernel sẽ tự động tạo một cặp khóa mới bằng cách sử dụng
openssl nếu cái này không tồn tại trong tệp::

certs/signing_key.pem

trong quá trình xây dựng vmlinux (phần công khai của khóa cần được xây dựng
vào vmlinux) bằng cách sử dụng các tham số trong::

certs/x509.genkey

tập tin (cũng được tạo nếu nó chưa tồn tại).

Người ta có thể chọn giữa RSA (ZZ0000ZZ), ECDSA
(ZZ0001ZZ) và ML-DSA (ZZ0002ZZ) đến
tạo cặp khóa RSA 4k, NIST P-384 hoặc cặp khóa ML-DSA 44, 65 hoặc 87.

Chúng tôi thực sự khuyên bạn nên cung cấp tệp x509.genkey của riêng mình.

Đáng chú ý nhất là trong file x509.genkey có phần req_distinguished_name
nên được thay đổi từ mặc định::

[ req_distinguished_name ]
	#O = Công ty không xác định
	CN = Khóa hạt nhân được tạo tự động theo thời gian xây dựng
	#emailAddress = unspecified.user@unspecified.company

Kích thước khóa RSA được tạo cũng có thể được đặt bằng::

[ yêu cầu ]
	mặc định_bits = 4096


Cũng có thể tạo thủ công các tệp riêng tư/công khai bằng cách sử dụng
Tệp cấu hình tạo khóa x509.genkey trong nút gốc của Linux
cây nguồn kernel và lệnh openssl.  Sau đây là một ví dụ để
tạo các tệp khóa công khai/riêng tư::

openssl req -new -nodes -utf8 -sha256 -days 36500 -batch -x509 \
	   -config x509.genkey -outform PEM -out kernel_key.pem \
	   -keyout kernel_key.pem

Sau đó có thể chỉ định tên đường dẫn đầy đủ cho tệp kernel_key.pem kết quả
trong tùy chọn ZZ0000ZZ, chứng chỉ và khóa trong đó sẽ
được sử dụng thay vì một cặp khóa được tạo tự động.


===========================
Khóa công khai trong kernel
===========================

Hạt nhân chứa một vòng khóa công khai mà root có thể xem được.  Họ là
trong một chuỗi khóa có tên ".buildin_trusted_keys" mà:: có thể nhìn thấy

[root@deneb ~]# cat /proc/keys
	...
223c7853 Tôi------ 1 perm 1f030000 0 0 móc khóa .buildin_trusted_keys: 1
	302d2d52 I------ 1 perm 1f010000 0 0 Khóa ký nhân Fedora bất đối xứng: d69a84e6bce3d216b979e9505b3e3ef9a7118079: X509.RSA a7118079 []
	...

Ngoài khóa công khai được tạo riêng cho việc ký mô-đun, các khóa bổ sung
chứng chỉ tin cậy có thể được cung cấp trong tệp được mã hóa PEM được tham chiếu bởi
Tùy chọn cấu hình ZZ0000ZZ.

Hơn nữa, mã kiến trúc có thể lấy khóa công khai từ kho phần cứng và
thêm những thứ đó vào (ví dụ: từ cơ sở dữ liệu khóa UEFI).

Cuối cùng, có thể thêm khóa công khai bổ sung bằng cách thực hiện ::

keyctl padd bất đối xứng "" [.buildin_trusted_keys-ID] <[key-file]

ví dụ.::

keyctl padd bất đối xứng "" 0x223c7853 <my_public_key.x509

Tuy nhiên, lưu ý rằng kernel sẽ chỉ cho phép thêm khóa vào
ZZ0000ZZ ZZ0002ZZ trình bao bọc X.509 của khóa mới được ký hợp lệ bằng một khóa
đã có sẵn trong ZZ0001ZZ tại thời điểm khóa được thêm vào.


============================
Ký mô-đun theo cách thủ công
============================

Để ký thủ công một mô-đun, hãy sử dụng công cụ tập lệnh/tệp ký tên có sẵn trong
cây nguồn nhân Linux.  Kịch bản yêu cầu 4 đối số:

1. Thuật toán băm (ví dụ: sha256)
	2. Tên tệp khóa riêng hoặc PKCS#11 URI
	3. Tên tệp khóa công khai
	4. Mô-đun hạt nhân được ký

Sau đây là ví dụ để ký mô-đun hạt nhân::

script/sign-file sha512 kernel-signkey.priv \
		kernel-signkey.x509 module.ko

Thuật toán băm được sử dụng không nhất thiết phải khớp với thuật toán được định cấu hình, nhưng nếu nó
không, bạn nên đảm bảo rằng thuật toán băm được tích hợp vào
kernel hoặc có thể được tải mà không cần chính nó.

Nếu khóa riêng yêu cầu cụm mật khẩu hoặc PIN, nó có thể được cung cấp trong
Biến môi trường $KBUILD_SIGN_PIN.


===============================
Các mô-đun đã ký và tước bỏ
===============================

Một mô-đun đã ký có chữ ký điện tử được thêm vào cuối.  Chuỗi
ZZ0000ZZ ở cuối tệp của mô-đun xác nhận rằng
có chữ ký nhưng không khẳng định chữ ký đó hợp lệ!

Các mô-đun đã ký là BRITTLE vì chữ ký nằm ngoài ELF được xác định
thùng chứa.  Do đó, MAY NOT sẽ bị loại bỏ sau khi chữ ký được tính toán và
đính kèm.  Lưu ý toàn bộ mô-đun là tải trọng đã ký, bao gồm bất kỳ và tất cả
thông tin gỡ lỗi hiện tại tại thời điểm ký kết.


=========================
Đang tải các mô-đun đã ký
=========================

Các mô-đun được tải với insmod, modprobe, ZZ0000ZZ hoặc
ZZ0001ZZ, chính xác như đối với các mô-đun chưa được ký vì không xử lý được
được thực hiện trong không gian người dùng.  Việc kiểm tra chữ ký hoàn toàn được thực hiện trong kernel.


=============================================
Chữ ký không hợp lệ và mô-đun không dấu
=============================================

Nếu ZZ0000ZZ được bật hoặc module.sig_enforce=1 được cung cấp trên
dòng lệnh kernel, kernel sẽ chỉ tải các mô-đun được ký hợp lệ
mà nó có khóa công khai.   Nếu không, nó cũng sẽ tải các mô-đun
không dấu.   Bất kỳ mô-đun nào mà hạt nhân có khóa nhưng được chứng minh là có
chữ ký không khớp sẽ không được phép tải.

Bất kỳ mô-đun nào có chữ ký không thể phân tích cú pháp sẽ bị từ chối.


=============================================
Quản trị/bảo vệ khóa riêng
=============================================

Vì khóa riêng được sử dụng để ký các mô-đun nên vi-rút và phần mềm độc hại có thể sử dụng
khóa riêng để ký các mô-đun và xâm phạm hệ điều hành.  các
khóa riêng phải bị hủy hoặc chuyển đến một vị trí an toàn và không được giữ lại
trong nút gốc của cây nguồn kernel.

Nếu bạn sử dụng cùng một khóa riêng để ký các mô-đun cho nhiều hạt nhân
cấu hình, bạn phải đảm bảo rằng thông tin phiên bản mô-đun là
đủ để ngăn chặn việc tải một mô-đun vào một hạt nhân khác.  Hoặc
đặt ZZ0000ZZ hoặc đảm bảo rằng mỗi cấu hình có một
chuỗi phát hành kernel bằng cách thay đổi ZZ0001ZZ hoặc ZZ0002ZZ.
