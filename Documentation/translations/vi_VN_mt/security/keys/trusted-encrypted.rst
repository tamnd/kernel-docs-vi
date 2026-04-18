.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/keys/trusted-encrypted.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Khóa đáng tin cậy và được mã hóa
================================

Khóa đáng tin cậy và khóa mã hóa là hai loại khóa mới được thêm vào kernel hiện có
dịch vụ vòng chìa khóa.  Cả hai loại mới này đều là các khóa đối xứng có độ dài thay đổi,
và trong cả hai trường hợp, tất cả các khóa đều được tạo trong kernel và không gian người dùng sẽ thấy,
lưu trữ và chỉ tải các đốm màu được mã hóa.  Khóa đáng tin cậy yêu cầu tính khả dụng
của Nguồn tin cậy để bảo mật cao hơn, trong khi Khóa mã hóa có thể được sử dụng trên bất kỳ
hệ thống. Tất cả các đốm màu ở cấp độ người dùng đều được hiển thị và tải ở dạng hex ASCII cho
thuận tiện và được xác minh tính toàn vẹn.

Khóa đáng tin cậy làm khóa được bảo vệ
======================================
Đó là cách an toàn để giữ các khóa trong vòng khóa hạt nhân dưới dạng Khóa tin cậy,
như vậy:

- Key-blob, một dữ liệu khóa được mã hóa, được tạo để lưu trữ, tải và xem bởi
  không gian người dùng.
- Dữ liệu khóa, văn bản khóa đơn giản trong bộ nhớ hệ thống, được sử dụng bởi
  chỉ không gian hạt nhân.

Mặc dù dữ liệu khóa không thể truy cập được vào không gian người dùng ở dạng văn bản thuần túy, nhưng nó ở dạng
văn bản thuần túy trong bộ nhớ hệ thống, khi được sử dụng trong không gian kernel. Mặc dù không gian kernel
thu hút sự tấn công bề mặt nhỏ, nhưng với hạt nhân hoặc kênh bên bị xâm phạm
cuộc tấn công truy cập vào bộ nhớ hệ thống có thể dẫn đến khả năng lấy được chìa khóa
bị xâm phạm/rò rỉ.

Để bảo vệ khóa trong không gian kernel, khái niệm "khóa được bảo vệ" là
được giới thiệu sẽ hoạt động như một lớp bảo vệ bổ sung. Dữ liệu khóa của
các khóa được bảo vệ được mã hóa bằng Khóa-Mã hóa-Khóa (KEK) và được giải mã bên trong
ranh giới nguồn tin cậy. Văn bản khóa đơn giản không bao giờ có sẵn bên ngoài
bộ nhớ hệ thống. Do đó, bất kỳ hoạt động mật mã nào được thực hiện bằng cách sử dụng
khóa được bảo vệ, chỉ có thể được thực hiện bởi nguồn tin cậy đã tạo ra
đốm màu chính.

Do đó, nếu khóa được bảo vệ bị rò rỉ hoặc bị xâm phạm, nó sẽ không có tác dụng gì đối với
tin tặc.

Khóa tin cậy là khóa được bảo vệ, với nguồn tin cậy có khả năng
tạo ra:

- Key-Blob, được tải, lưu trữ và xem bởi không gian người dùng.

Nguồn tin cậy
=============

Nguồn tin cậy cung cấp nguồn bảo mật cho Khóa tin cậy.  Cái này
phần liệt kê các nguồn tin cậy hiện được hỗ trợ, cùng với bảo mật của chúng
cân nhắc.  Nguồn tin cậy có đủ an toàn hay không phụ thuộc vào
vào sức mạnh và tính đúng đắn của việc thực hiện nó, cũng như mối đe dọa
môi trường cho một trường hợp sử dụng cụ thể.  Vì kernel không biết cái gì
môi trường là như vậy và không có thước đo về độ tin cậy, nó phụ thuộc vào
người sử dụng Khóa tin cậy để xác định xem nguồn tin cậy có đủ
an toàn.

* Nguồn gốc của niềm tin để lưu trữ

(1) TPM (Mô-đun nền tảng đáng tin cậy: thiết bị phần cứng)

Đã root vào Khóa gốc lưu trữ (SRK) không bao giờ rời khỏi TPM
         cung cấp hoạt động mã hóa để thiết lập nguồn gốc tin cậy cho việc lưu trữ.

(2) TEE (Môi trường thực thi đáng tin cậy: OP-TEE dựa trên Arm TrustZone)

Đã root bằng Khóa duy nhất phần cứng (HUK) thường bị cháy trong chip
         cầu chì và chỉ TEE mới có thể truy cập được.

(3) CAAM (Mô-đun đảm bảo và tăng tốc mật mã: IP trên SoC NXP)

Khi Khởi động đảm bảo cao (HAB) được bật và CAAM ở trạng thái an toàn
         chế độ, niềm tin được bắt nguồn từ OTPMK, khóa 256-bit chưa bao giờ được tiết lộ
         được tạo ngẫu nhiên và hợp nhất vào từng SoC tại thời điểm sản xuất.
         Nếu không, khóa kiểm tra cố định chung sẽ được sử dụng thay thế.

(4) DCP (Bộ đồng xử lý dữ liệu: bộ tăng tốc mật mã của nhiều SoC i.MX khác nhau)

Đã root bằng khóa lập trình một lần (OTP) thường bị cháy
         trong các cầu chì trên chip và chỉ có thể truy cập được bằng công cụ mã hóa DCP.
         DCP cung cấp hai khóa có thể được sử dụng làm gốc tin cậy: khóa OTP
         và phím UNIQUE. Mặc định là sử dụng phím UNIQUE nhưng việc chọn
         khóa OTP có thể được thực hiện thông qua tham số mô-đun (dcp_use_otp_key).

(5) PKWM (Mô-đun gói khóa PowerVM: IBM PowerVM + Kho khóa nền tảng)

Bắt nguồn từ một khóa duy nhất trên mỗi LPAR, được lấy từ một khóa toàn hệ thống,
         Khóa gốc LPAR được tạo ngẫu nhiên. Cả khóa per-LPAR và LPAR
         khóa gốc được lưu trữ trong bộ nhớ an toàn do hypervisor sở hữu khi chạy,
         và khóa gốc LPAR cũng được lưu giữ ở các vị trí an toàn
         chẳng hạn như SEEPROM của bộ xử lý và NVRAM được mã hóa.

* Cách ly thực thi

(1) TPM

Đã sửa lỗi tập hợp các thao tác chạy trong môi trường thực thi bị cô lập.

(2) TEE

Tập hợp các hoạt động có thể tùy chỉnh đang chạy trong thực thi biệt lập
         môi trường được xác minh thông qua quy trình khởi động An toàn/Đáng tin cậy.

(3) CAAM

Đã sửa lỗi tập hợp các thao tác chạy trong môi trường thực thi bị cô lập.

(4) DCP

Đã sửa lỗi tập hợp các hoạt động mã hóa đang chạy trong quá trình thực thi riêng biệt
         môi trường. Chỉ mã hóa khóa blob cơ bản được thực thi ở đó.
         Việc niêm phong/mở khóa thực tế được thực hiện trên không gian bộ xử lý/hạt nhân chính.

(5) PKWM (Mô-đun gói khóa PowerVM: IBM PowerVM + Kho khóa nền tảng)

Đã sửa lỗi tập hợp các hoạt động mã hóa được thực hiện trên phần cứng trên chip
         đơn vị tăng tốc mật mã NX. Chìa khóa để gói và mở gói
         được quản lý bởi PowerVM Platform KeyStore, nơi lưu trữ các khóa trong một
         bản sao trong bộ nhớ bị cô lập trong bộ nhớ ảo hóa an toàn, cũng như trong
         bản sao liên tục trong NVRAM được mã hóa ảo hóa.

* Liên kết tùy chọn với trạng thái toàn vẹn nền tảng

(1) TPM

Các khóa có thể được tùy chọn niêm phong theo PCR được chỉ định (đo lường tính toàn vẹn)
         các giá trị và chỉ được TPM hủy niêm phong, nếu PCR và tính toàn vẹn của blob
         xác minh phù hợp. Khóa tin cậy đã tải có thể được cập nhật bằng khóa mới
         (tương lai) Giá trị PCR, do đó, các khóa có thể dễ dàng di chuyển sang giá trị PCR mới,
         chẳng hạn như khi kernel và initramfs được cập nhật. Cùng một khóa có thể
         có nhiều đốm màu được lưu dưới các giá trị PCR khác nhau, vì vậy nhiều lần khởi động sẽ
         dễ dàng được hỗ trợ.

(2) TEE

Dựa vào quy trình khởi động An toàn/Đáng tin cậy để đảm bảo tính toàn vẹn của nền tảng. Nó có thể
         được mở rộng với quy trình khởi động được đo lường dựa trên TEE.

(3) CAAM

Dựa vào cơ chế Khởi động đảm bảo cao (HAB) của NXP SoC
         cho tính toàn vẹn của nền tảng.

(4) DCP

Dựa vào quy trình khởi động An toàn/Đáng tin cậy (được nhà cung cấp gọi là HAB) cho
         tính toàn vẹn của nền tảng.

(5) PKWM (Mô-đun gói khóa PowerVM: IBM PowerVM + Kho khóa nền tảng)

Dựa vào quy trình khởi động an toàn và đáng tin cậy của hệ thống IBM Power cho
         tính toàn vẹn của nền tảng.

* Giao diện và API

(1) TPM

TPM có các giao diện và API được chuẩn hóa, được ghi chép đầy đủ.

(2) TEE

TEE có giao diện máy khách và API được chuẩn hóa rõ ràng, được ghi chép đầy đủ. cho
         biết thêm chi tiết tham khảo ZZ0000ZZ.

(3) CAAM

Giao diện dành riêng cho nhà cung cấp silicon.

(4) DCP

API dành riêng cho nhà cung cấp được triển khai như một phần của trình điều khiển mật mã DCP trong
         ZZ0000ZZ.

(5) PKWM (Mô-đun gói khóa PowerVM: IBM PowerVM + Kho khóa nền tảng)

Kho khóa nền tảng có giao diện được ghi chép rõ ràng trong tài liệu PAPR.
         Tham khảo ZZ0000ZZ

* Mô hình mối đe dọa

Sức mạnh và sự phù hợp của một nguồn tin cậy cụ thể cho một nguồn nhất định
     mục đích phải được đánh giá khi sử dụng chúng để bảo vệ dữ liệu liên quan đến bảo mật.


Tạo khóa
==============

Khóa đáng tin cậy
-----------------

Khóa mới được tạo từ các số ngẫu nhiên. Chúng được mã hóa/giải mã bằng cách sử dụng
một khóa con trong hệ thống phân cấp khóa lưu trữ. Mã hóa và giải mã của
Khóa con phải được bảo vệ bởi chính sách kiểm soát truy cập mạnh mẽ trong
nguồn tin cậy. Trình tạo số ngẫu nhiên được sử dụng khác nhau tùy theo
nguồn tin cậy đã chọn:

* TPM: RNG dựa trên thiết bị phần cứng

Khóa được tạo trong TPM. Độ mạnh của số ngẫu nhiên có thể khác nhau
     từ nhà sản xuất thiết bị này sang nhà sản xuất thiết bị khác.

* TEE: OP-TEE dựa trên RNG dựa trên Arm TrustZone

RNG có thể tùy chỉnh theo nhu cầu nền tảng. Nó có thể là đầu ra trực tiếp
     từ phần cứng RNG dành riêng cho nền tảng hoặc Fortuna CSPRNG dựa trên phần mềm
     có thể được gieo hạt thông qua nhiều nguồn entropy.

* CAAM: Hạt nhân RNG

Trình tạo số ngẫu nhiên kernel bình thường được sử dụng. Để gieo hạt từ
     CAAM HWRNG, kích hoạt CRYPTO_DEV_FSL_CAAM_RNG_API và đảm bảo thiết bị
     được thăm dò.

* DCP (Bộ đồng xử lý dữ liệu: bộ tăng tốc mật mã của nhiều SoC i.MX khác nhau)

Bản thân thiết bị phần cứng DCP không cung cấp giao diện RNG chuyên dụng,
     vì vậy kernel mặc định RNG được sử dụng. Các SoC có DCP như i.MX6ULL đều có
     phần cứng chuyên dụng RNG độc lập với DCP có thể được kích hoạt
     để sao lưu kernel RNG.

* PKWM (Mô-đun gói khóa PowerVM: IBM PowerVM + Kho khóa nền tảng)

Trình tạo số ngẫu nhiên kernel thông thường được sử dụng để tạo khóa.

Người dùng có thể ghi đè điều này bằng cách chỉ định ZZ0000ZZ trên kernel
dòng lệnh để ghi đè RNG đã sử dụng bằng nhóm số ngẫu nhiên của kernel.

Khóa mã hóa
--------------

Khóa được mã hóa không phụ thuộc vào nguồn đáng tin cậy và nhanh hơn vì chúng sử dụng AES
để mã hóa/giải mã. Các khóa mới được tạo từ kernel do kernel tạo
số ngẫu nhiên hoặc dữ liệu được giải mã do người dùng cung cấp và được mã hóa/giải mã
sử dụng khóa 'chính' được chỉ định. Khóa 'chính' có thể là khóa đáng tin cậy hoặc
loại khóa người dùng. Nhược điểm chính của khóa mã hóa là nếu chúng không được
bắt nguồn từ một khóa đáng tin cậy, chúng chỉ an toàn như mã hóa khóa người dùng
họ. Do đó, khóa người dùng chính phải được tải theo cách an toàn như
có thể, tốt nhất là ở giai đoạn khởi động sớm.


Cách sử dụng
============

Cách sử dụng Khóa đáng tin cậy: TPM
-----------------------------------

TPM 1.2: Theo mặc định, các khóa đáng tin cậy được niêm phong trong SRK, có mã
giá trị ủy quyền mặc định (20 byte 0).  Điều này có thể được đặt ở quyền sở hữu
thời gian với tiện ích TrouSerS: "tpm_takeownership -u -z".

TPM 2.0: Trước tiên, người dùng phải tạo khóa lưu trữ và làm cho nó ổn định, do đó,
key có sẵn sau khi khởi động lại. Điều này có thể được thực hiện bằng cách sử dụng các lệnh sau.

Với ngăn xếp IBM TSS 2::

#> tsscreateprimary -hi o -st
  Xử lý 80000000
  #> tssevictcontrol -hi o -ho 80000000 -hp 81000001

Hoặc với ngăn xếp Intel TSS 2 ::

#> tpm2_createprimary --hierarchy o -G rsa2048 -c key.ctxt
  […]
  #> tpm2_evictcontrol -c key.ctxt 0x81000001
  PersistHandle: 0x81000001

Cách sử dụng::

keyctl thêm tên đáng tin cậy vòng "keylen [tùy chọn]" mới
    keyctl thêm tên đáng tin cậy "load hex_blob [pcrlock=pcrnum]"
    Khóa cập nhật keyctl "cập nhật [tùy chọn]"
    keyctl in keyid

tùy chọn:
       keyhandle= giá trị hex ascii của khóa niêm phong
                       TPM 1.2: mặc định 0x40000000 (SRK)
                       TPM 2.0: không có mặc định; phải được thông qua mọi lúc
       keyauth= ascii hex auth để niêm phong khóa mặc định 0x00...i
                     (40 số không ascii)
       blobauth= ascii hex auth cho dữ liệu kín mặc định 0x00...
                     (40 số không ascii)
       pcrinfo= ascii hex của PCR_INFO hoặc PCR_INFO_LONG (không có mặc định)
       pcrlock= số pcr được mở rộng thành blob "lock"
       migratable= 0|1 cho biết quyền gắn lại các giá trị PCR mới,
                     mặc định 1 (cho phép niêm phong lại)
       hash= tên thuật toán băm dưới dạng một chuỗi. Chỉ dành cho TPM 1.x
                     giá trị được phép là sha1. Đối với TPM 2.x, các giá trị được phép
                     là sha1, sha256, sha384, sha512 và sm3-256.
       Policydigest=thông báo cho chính sách ủy quyền. phải được tính toán
                     với cùng thuật toán băm được chỉ định bởi 'hash='
                     tùy chọn.
       Policyhandle= xử lý phiên chính sách ủy quyền xác định
                     cùng một chính sách và với cùng một thuật toán băm như đã được sử dụng để
                     niêm phong chìa khóa.

"keyctl print" trả về một bản sao mã ascii hex của khóa được niêm phong, theo tiêu chuẩn
Định dạng TPM_STORED_DATA.  Độ dài khóa cho khóa mới luôn tính bằng byte.
Khóa tin cậy có thể là 32 - 128 byte (256 - 1024 bit), giới hạn trên là phù hợp
trong độ dài khóa 2048 bit SRK (RSA), với tất cả cấu trúc/phần đệm cần thiết.

Cách sử dụng Khóa đáng tin cậy: TEE
-----------------------------------

Cách sử dụng::

keyctl thêm tên đáng tin cậy vòng "keylen mới"
    keyctl thêm tên đáng tin cậy "tải hex_blob"
    keyctl in keyid

"keyctl print" trả về bản sao lục giác ASCII của khóa được niêm phong, có định dạng
cụ thể cho việc triển khai thiết bị TEE.  Độ dài khóa cho khóa mới luôn là
tính bằng byte. Khóa đáng tin cậy có thể là 32 - 128 byte (256 - 1024 bit).

Cách sử dụng Khóa đáng tin cậy: CAAM
------------------------------------

Khóa đáng tin cậy

keyctl thêm tên đáng tin cậy vòng "keylen mới"
    keyctl thêm tên đáng tin cậy "tải hex_blob"
    keyctl in keyid

"keyctl print" trả về bản sao lục giác ASCII của khóa được niêm phong, nằm trong một
Định dạng dành riêng cho CAAM.  Độ dài khóa cho khóa mới luôn tính bằng byte.
Khóa đáng tin cậy có thể là 32 - 128 byte (256 - 1024 bit).

Khóa đáng tin cậy làm khóa được bảo vệ

keyctl thêm tên đáng tin cậy "keylen pk [tùy chọn]" mới
    keyctl thêm tên đáng tin cậy "tải hex_blob [tùy chọn]"
    keyctl in keyid

trong đó, 'pk' được sử dụng để hướng nguồn tin cậy nhằm tạo khóa được bảo vệ.

tùy chọn:
       key_enc_algo = Đối với CAAM, thuật toán enc được hỗ trợ là ECB(2), CCM(1).

"keyctl print" trả về bản sao lục giác ASCII của khóa được niêm phong, nằm trong một
Định dạng dành riêng cho CAAM.  Độ dài khóa cho khóa mới luôn tính bằng byte.
Khóa đáng tin cậy có thể là 32 - 128 byte (256 - 1024 bit).

Cách sử dụng Khóa đáng tin cậy: DCP
-----------------------------------

Cách sử dụng::

keyctl thêm tên đáng tin cậy vòng "keylen mới"
    keyctl thêm tên đáng tin cậy "tải hex_blob"
    keyctl in keyid

"keyctl print" trả về bản sao lục giác ASCII của khóa được niêm phong, có định dạng
cụ thể cho việc triển khai key-blob DCP này.  Độ dài khóa cho khóa mới là
luôn tính bằng byte. Khóa đáng tin cậy có thể là 32 - 128 byte (256 - 1024 bit).

Cách sử dụng Khóa đáng tin cậy: PKWM
------------------------------------

Cách sử dụng::

keyctl thêm tên đáng tin cậy vòng "keylen [tùy chọn]" mới
    keyctl thêm tên đáng tin cậy "tải hex_blob"
    keyctl in keyid

tùy chọn:
       quấn_flags=giá trị hex ascii của yêu cầu chính sách bảo mật
                       0x00: không có yêu cầu khởi động an toàn (mặc định)
                       0x01: yêu cầu khởi động an toàn ở chế độ kiểm tra hoặc
                             chế độ thực thi
                       0x02: yêu cầu khởi động an toàn ở chế độ thực thi

"keyctl print" trả về bản sao lục giác ASCII của khóa được niêm phong, có định dạng
dành riêng cho việc triển khai key-blob PKWM.  Độ dài khóa cho khóa mới là
luôn tính bằng byte. Khóa đáng tin cậy có thể là 32 - 128 byte (256 - 1024 bit).

Cách sử dụng Khóa được mã hóa
-----------------------------

Phần được giải mã của khóa mã hóa có thể chứa một mã đối xứng đơn giản
khóa hoặc một cấu trúc phức tạp hơn. Định dạng của cấu trúc phức tạp hơn là
ứng dụng cụ thể, được xác định bằng 'định dạng'.

Cách sử dụng::

keyctl thêm tên được mã hóa "loại khóa [định dạng] mới: keylen tên khóa chính"
        chiếc nhẫn
    keyctl thêm tên được mã hóa "loại khóa [định dạng] mới: keylen tên khóa chính
        dữ liệu được giải mã"
    keyctl thêm tên được mã hóa vòng "load hex_blob"
    keyctl cập nhật keyid "cập nhật loại khóa:tên khóa chính"

Ở đâu::

định dạng:= 'ZZ0000ZZ enc32 mặc định'
	key-type:= 'đáng tin cậy' | 'người dùng'

Ví dụ về cách sử dụng khóa được mã hóa và đáng tin cậy
------------------------------------------------------

Tạo và lưu khóa đáng tin cậy có tên "kmk" có độ dài 32 byte.

Lưu ý: Khi sử dụng TPM 2.0 có phím cố định có tay cầm 0x81000001,
nối 'keyhandle=0x81000001' vào các câu lệnh giữa các dấu ngoặc kép, chẳng hạn như
"tay cầm phím 32 mới=0x81000001".

::

$ keyctl thêm kmk đáng tin cậy "mới 32" @u
    440502848

$ keyctl hiển thị
    Khóa phiên
           -3 --alswrv 500 500 móc khóa: _ses
     97833714 --alswrv 500 -1 \_ móc khóa: _uid.500
    440502848 --alswrv 500 500 \_ đáng tin cậy: kmk

$ in keyctl 440502848
    01010000000000000000001005d01b7e3f4a6be5709930f3b70a743cbb42e0cc95e18e915
    3f60da455bbf1144ad12e4f92b452f966929f6105fd29ca28e4d4d5a031d068478bacb0b
    27351119f822911b0a11ba3d3498ba6a32e50dac7f32894dd890eb9ad578e4e292c83722
    a52e56a097e6a68b3f56f7a52ece0cdccba1eb62cad7d817f6dc58898b3ac15f36026fec
    d568bd4a706cb60bb37be6d8f1240661199d640b66fb0fe3b079f97f450b9ef9c22c6d5d
    dd379f0facd1cd020281dfa3c70ba21a3fa6fc2471dc6d13ecf8298b946f65345faa5ef0
    f1f8fff03ad0acb083725535636addb08d73dedb9832da198081e5deae84bfaf0409c22b
    e4a8aea2b607ec96931e6f4d4fe563ba

$ keyctl ống 440502848 > kmk.blob

Tải khóa đáng tin cậy từ blob đã lưu::

$ keyctl thêm kmk đáng tin cậy "tải ZZ0000ZZ" @u
    268728824

$ in keyctl 268728824
    01010000000000000000001005d01b7e3f4a6be5709930f3b70a743cbb42e0cc95e18e915
    3f60da455bbf1144ad12e4f92b452f966929f6105fd29ca28e4d4d5a031d068478bacb0b
    27351119f822911b0a11ba3d3498ba6a32e50dac7f32894dd890eb9ad578e4e292c83722
    a52e56a097e6a68b3f56f7a52ece0cdccba1eb62cad7d817f6dc58898b3ac15f36026fec
    d568bd4a706cb60bb37be6d8f1240661199d640b66fb0fe3b079f97f450b9ef9c22c6d5d
    dd379f0facd1cd020281dfa3c70ba21a3fa6fc2471dc6d13ecf8298b946f65345faa5ef0
    f1f8fff03ad0acb083725535636addb08d73dedb9832da198081e5deae84bfaf0409c22b
    e4a8aea2b607ec96931e6f4d4fe563ba

Tạo và lưu khóa đáng tin cậy làm khóa được bảo vệ có tên "kmk" có độ dài 32 byte.

::

$ keyctl thêm kmk đáng tin cậy "32 pk key_enc_algo=1" mới @u
    440502848

$ keyctl hiển thị
    Khóa phiên
           -3 --alswrv 500 500 móc khóa: _ses
     97833714 --alswrv 500 -1 \_ móc khóa: _uid.500
    440502848 --alswrv 500 500 \_ đáng tin cậy: kmk

$ in keyctl 440502848
    01010000000000000000001005d01b7e3f4a6be5709930f3b70a743cbb42e0cc95e18e915
    3f60da455bbf1144ad12e4f92b452f966929f6105fd29ca28e4d4d5a031d068478bacb0b
    27351119f822911b0a11ba3d3498ba6a32e50dac7f32894dd890eb9ad578e4e292c83722
    a52e56a097e6a68b3f56f7a52ece0cdccba1eb62cad7d817f6dc58898b3ac15f36026fec
    d568bd4a706cb60bb37be6d8f1240661199d640b66fb0fe3b079f97f450b9ef9c22c6d5d
    dd379f0facd1cd020281dfa3c70ba21a3fa6fc2471dc6d13ecf8298b946f65345faa5ef0
    f1f8fff03ad0acb083725535636addb08d73dedb9832da198081e5deae84bfaf0409c22b
    e4a8aea2b607ec96931e6f4d4fe563ba

$ keyctl ống 440502848 > kmk.blob

Tải khóa đáng tin cậy từ blob đã lưu::

$ keyctl thêm kmk đáng tin cậy "tải ZZ0000ZZ key_enc_algo=1" @u
    268728824

$ in keyctl 268728824
    01010000000000000000001005d01b7e3f4a6be5709930f3b70a743cbb42e0cc95e18e915
    3f60da455bbf1144ad12e4f92b452f966929f6105fd29ca28e4d4d5a031d068478bacb0b
    27351119f822911b0a11ba3d3498ba6a32e50dac7f32894dd890eb9ad578e4e292c83722
    a52e56a097e6a68b3f56f7a52ece0cdccba1eb62cad7d817f6dc58898b3ac15f36026fec
    d568bd4a706cb60bb37be6d8f1240661199d640b66fb0fe3b079f97f450b9ef9c22c6d5d
    dd379f0facd1cd020281dfa3c70ba21a3fa6fc2471dc6d13ecf8298b946f65345faa5ef0
    f1f8fff03ad0acb083725535636addb08d73dedb9832da198081e5deae84bfaf0409c22b
    e4a8aea2b607ec96931e6f4d4fe563ba

Đóng lại (dành riêng cho TPM) một khóa đáng tin cậy theo các giá trị PCR mới::

$ keyctl cập nhật 268728824 "cập nhật pcrinfo=ZZ0000ZZ"
    $ in keyctl 268728824
    010100000000002c0002800093c35a09b70fff26e7a98ae786c641e678ec6ffb6b46d805
    77c8a6377aed9d3219c6dfec4b23ffe3000001005d37d472ac8a44023fbb3d18583a4f73
    d3a076c0858f6f1dcaa39ea0f119911ff03f5406df4f7f27f41da8d7194f45c9f4e00f2e
    df449f266253aa3f52e55c53de147773e00f0f9aca86c64d94c95382265968c354c5eab4
    9638c5ae99c89de1e0997242edfb0b501744e11ff9762dfd951cffd93227cc513384e7e6
    e782c29435c7ec2edafaa2f4c1fe6e7a781b59549ff5296371b42133777dcc5b8b971610
    94bc67ede19e43ddb9dc2baacad374a36feaf0314d700af0a65c164b7082401740e489c9
    7ef6a24defe4846104209bf0c3eced7fa1a672ed5b125fc9d8cd88b476a658a4434644ef
    df8ae9a178e9f83ba9f08d10fa47e4226b98b0702f06b3b8


Người sử dụng khóa đáng tin cậy ban đầu là EVM, lúc khởi động cần mật độ cao
khóa đối xứng chất lượng để bảo vệ siêu dữ liệu tệp HMAC. Việc sử dụng một
khóa đáng tin cậy cung cấp sự đảm bảo mạnh mẽ rằng khóa EVM chưa được
bị xâm phạm bởi sự cố ở cấp độ người dùng và khi được niêm phong với tính toàn vẹn của nền tảng
trạng thái, bảo vệ chống lại các cuộc tấn công khởi động và ngoại tuyến. Tạo và lưu một
khóa được mã hóa "evm" bằng khóa đáng tin cậy ở trên "kmk":

tùy chọn 1: bỏ qua 'định dạng'::

$ keyctl thêm evm được mã hóa "đáng tin cậy mới:kmk 32" @u
    159771175

tùy chọn 2: xác định rõ ràng 'định dạng' là 'mặc định'::

$ keyctl thêm evm được mã hóa "đáng tin cậy mặc định mới: kmk 32" @u
    159771175

$ in keyctl 159771175
    đáng tin cậy mặc định: kmk 32 2375725ad57798846a9bbd240de8906f006e66c03af53b1b3
    82dbbc55be2a44616e4959430436dc4f2a7a9659aa60bb4652aeb2120f149ed197c564e0
    24717c64 5972dcb82ab2dde83376d82b2e3c09ffc

$ keyctl ống 159771175 > evm.blob

Tải khóa mã hóa "evm" từ blob đã lưu::

$ keyctl thêm evm được mã hóa "tải ZZ0000ZZ" @u
    831684262

$ in keyctl 831684262
    đáng tin cậy mặc định: kmk 32 2375725ad57798846a9bbd240de8906f006e66c03af53b1b3
    82dbbc55be2a44616e4959430436dc4f2a7a9659aa60bb4652aeb2120f149ed197c564e0
    24717c64 5972dcb82ab2dde83376d82b2e3c09ffc

Khởi tạo khóa được mã hóa "evm" bằng cách sử dụng dữ liệu được giải mã do người dùng cung cấp::

$ evmkey=$(dd if=/dev/urandom bs=1 count=32 | xxd -c32 -p)
    $ keyctl thêm evm được mã hóa "người dùng mặc định mới: kmk 32 $evmkey" @u
    794890253

$ in keyctl 794890253
    người dùng mặc định: kmk 32 2375725ad57798846a9bbd240de8906f006e66c03af53b1b382d
    bbc55be2a44616e4959430436dc4f2a7a9659aa60bb4652aeb2120f149ed197c564e0247
    17c64 5972dcb82ab2dde83376d82b2e3c09ffc

Các mục đích sử dụng khác cho các khóa được mã hóa và đáng tin cậy, chẳng hạn như mã hóa ổ đĩa và tệp
được dự kiến.  Đặc biệt định dạng mới 'ecryptfs' đã được xác định
để sử dụng các khóa được mã hóa để gắn hệ thống tệp eCryptfs.  Thêm chi tiết
về việc sử dụng có thể được tìm thấy trong tập tin
ZZ0000ZZ.

Một định dạng mới khác 'enc32' đã được xác định để hỗ trợ các khóa được mã hóa
với kích thước tải trọng là 32 byte. Điều này ban đầu sẽ được sử dụng để bảo mật nvdimm
nhưng có thể mở rộng sang các mục đích sử dụng khác yêu cầu tải trọng 32 byte.


Định dạng khóa TPM 2.0 ASN.1
----------------------------

Định dạng khóa TPM 2.0 ASN.1 được thiết kế để dễ dàng nhận dạng,
ngay cả ở dạng nhị phân (khắc phục sự cố chúng tôi gặp phải với TPM 1.2 ASN.1
định dạng) và có thể mở rộng cho các bổ sung như khóa có thể nhập và
chính sách::

TPMKey ::= SEQUENCE {
        loại OBJECT IDENTIFIER
        trốngAuth [0] EXPLICIT BOOLEAN OPTIONAL
        cha mẹ INTEGER
        khóa công khai OCTET STRING
        khóa riêng OCTET STRING
    }

loại là thứ phân biệt khóa ngay cả ở dạng nhị phân kể từ OID
được TCG cung cấp là duy nhất và do đó tạo thành một biểu tượng dễ nhận biết
mẫu nhị phân ở offset 3 trong khóa.  Các OID hiện đang được thực hiện
có sẵn là::

2.23.133.10.1.3 TPM Khóa có thể tải.  Đây là khóa bất đối xứng (Thường
                    RSA2048 hoặc Đường cong Elliptic) có thể được nhập bởi
                    Hoạt động TPM2_Load().

2.23.133.10.1.4 Khóa có thể nhập TPM.  Đây là khóa bất đối xứng (Thường
                    RSA2048 hoặc Đường cong Elliptic) có thể được nhập bởi
                    Hoạt động TPM2_Import().

2.23.133.10.1.5 TPM Dữ liệu được niêm phong.  Đây là một tập hợp dữ liệu (lên tới 128
                    byte) được niêm phong bởi TPM.  Nó thường
                    đại diện cho một khóa đối xứng và phải được hủy niêm phong trước khi
                    sử dụng.

Mã khóa đáng tin cậy chỉ sử dụng Dữ liệu được niêm phong TPM OID.

trốngAuth là đúng nếu khóa có ủy quyền nổi tiếng "".  Nếu nó
là sai hoặc không có, khóa cần có sự ủy quyền rõ ràng
cụm từ.  Điều này được hầu hết người tiêu dùng không gian người dùng sử dụng để quyết định xem
để nhắc nhập mật khẩu.

cha mẹ đại diện cho tay cầm khóa cha, trong không gian 0x81 MSO,
như 0x81000001 cho khóa lưu trữ chính RSA.  Chương trình không gian người dùng
cũng hỗ trợ chỉ định tay cầm chính trong không gian 0x40 MSO.  Nếu
điều này xảy ra với biến thể Đường cong Elliptic của khóa chính bằng cách sử dụng
Mẫu được xác định TCG sẽ được tạo nhanh chóng trong môi trường không ổn định
đối tượng và được sử dụng làm cha mẹ.  Mã kernel hiện tại chỉ hỗ trợ
dạng 0x81 MSO.

pubkey là biểu diễn nhị phân của TPM2B_PRIVATE không bao gồm
Tiêu đề TPM2B ban đầu, có thể được xây dựng lại từ octet ASN.1
chiều dài chuỗi.

khóa riêng là biểu diễn nhị phân của TPM2B_PUBLIC không bao gồm
Tiêu đề TPM2B ban đầu có thể được xây dựng lại từ ASN.1 tháng 10
chiều dài chuỗi.

Định dạng Blob DCP
------------------

.. kernel-doc:: security/keys/trusted-keys/trusted_dcp.c
   :doc: dcp blob format

.. kernel-doc:: security/keys/trusted-keys/trusted_dcp.c
   :identifiers: struct dcp_blob_fmt
