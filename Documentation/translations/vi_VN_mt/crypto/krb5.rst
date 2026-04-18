.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/krb5.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Mật mã Kerberos V API
==============================

.. Contents:

  - Overview.
    - Small Buffer.
  - Encoding Type.
  - Key Derivation.
    - PRF+ Calculation.
    - Kc, Ke And Ki Derivation.
  - Crypto Functions.
    - Preparation Functions.
    - Encryption Mode.
    - Checksum Mode.
  - The krb5enc AEAD algorithm

Tổng quan
========

API này cung cấp mật mã kiểu Kerberos 5 để tạo khóa, mã hóa
và kiểm tra tổng để sử dụng trong các hệ thống tệp mạng và có thể được sử dụng để triển khai
mật mã cấp thấp cần thiết cho GSSAPI.

Các loại tiền điện tử sau được hỗ trợ::

KRB5_ENCTYPE_AES128_CTS_HMAC_SHA1_96
	KRB5_ENCTYPE_AES256_CTS_HMAC_SHA1_96
	KRB5_ENCTYPE_AES128_CTS_HMAC_SHA256_128
	KRB5_ENCTYPE_AES256_CTS_HMAC_SHA384_192
	KRB5_ENCTYPE_CAMELLIA128_CTS_CMAC
	KRB5_ENCTYPE_CAMELLIA256_CTS_CMAC

KRB5_CKSUMTYPE_HMAC_SHA1_96_AES128
	KRB5_CKSUMTYPE_HMAC_SHA1_96_AES256
	KRB5_CKSUMTYPE_CMAC_CAMELLIA128
	KRB5_CKSUMTYPE_CMAC_CAMELLIA256
	KRB5_CKSUMTYPE_HMAC_SHA256_128_AES128
	KRB5_CKSUMTYPE_HMAC_SHA384_192_AES256

API có thể được bao gồm bởi::

#include <crypto/krb5.h>

Bộ đệm nhỏ
------------

Để truyền các mẩu dữ liệu nhỏ, chẳng hạn như các khóa, một cấu trúc bộ đệm được sử dụng
được xác định, đưa ra một con trỏ tới dữ liệu và kích thước của dữ liệu đó ::

cấu trúc krb5_buffer {
		int len không dấu;
		void *dữ liệu;
	};

Loại mã hóa
=============

Kiểu mã hóa được xác định theo cấu trúc sau::

cấu trúc krb5_enctype {
		int etype;
		int ctype;
		const char *tên;
		u16 key_byte;
		u16 key_len;
		u16 Kc_len;
		u16 Ke_len;
		u16 Ki_len;
		u16 prf_len;
		u16 block_len;
		u16 conf_len;
		u16 csum_len;
		...
	};

Các lĩnh vực mà người dùng API quan tâm như sau:

* ZZ0000ZZ và ZZ0001ZZ cho biết số giao thức cho mã hóa này
    type để mã hóa và kiểm tra tổng hợp tương ứng.  Họ nắm giữ
    Các hằng số ZZ0002ZZ và ZZ0003ZZ.

* ZZ0000ZZ là tên chính thức của mã hóa.

* ZZ0000ZZ và ZZ0001ZZ là độ dài khóa đầu vào và khóa dẫn xuất
    chiều dài.  (Tôi nghĩ chúng chỉ khác nhau đối với DES, không được hỗ trợ ở đây).

* ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ là kích thước của Kc, Ke dẫn xuất
    và phím Ki.  Kc được sử dụng ở chế độ tổng kiểm tra; Ke và Ki được sử dụng trong
    chế độ mã hóa.

* ZZ0000ZZ là kích thước của kết quả từ phép tính hàm PRF+.

* ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ là khối mã hóa
    chiều dài, chiều dài gây nhiễu và chiều dài tổng kiểm tra tương ứng.  Cả ba đều là
    được sử dụng trong chế độ mã hóa, nhưng chỉ sử dụng độ dài tổng kiểm tra trong tổng kiểm tra
    chế độ.

Kiểu mã hóa được tra cứu theo số bằng hàm sau ::

const struct krb5_enctype *crypto_krb5_find_enctype(u32 enctype);

Đạo hàm chính
==============

Sau khi ứng dụng đã chọn loại mã hóa, các khóa sẽ được
được sử dụng để thực hiện mật mã thực tế có thể được lấy từ khóa vận chuyển.

Tính toán PRF+
----------------

Để hỗ trợ việc dẫn xuất khóa, một hàm tính toán Kerberos GSSAPI
PRF+ của cơ chế được cung cấp::

int crypto_krb5_calc_PRFplus(const struct krb5_enctype *krb5,
				     const struct krb5_buffer *K,
				     int không dấu L,
				     const struct krb5_buffer *S,
				     struct krb5_buffer *kết quả,
				     gfp_t gfp);

Điều này có thể được sử dụng để lấy khóa vận chuyển từ khóa nguồn cộng với khóa bổ sung
dữ liệu để hạn chế việc sử dụng nó.

Chức năng tiền điện tử
================

Khi các khóa đã được lấy, việc mã hóa có thể được thực hiện trên dữ liệu.  các
người gọi phải để lại những khoảng trống trong bộ đệm để lưu trữ tác nhân gây nhiễu (nếu
cần thiết) và tổng kiểm tra khi chuẩn bị thông báo để truyền.  Một enum
và một cặp chức năng được cung cấp để hỗ trợ việc này::

enum krb5_crypto_mode {
		KRB5_CHECKSUM_MODE,
		KRB5_ENCRYPT_MODE,
	};

size_t crypto_krb5_how_much_buffer(const struct krb5_enctype *krb5,
					   chế độ enum krb5_crypto_mode,
					   size_t data_size, size_t *_offset);

size_t crypto_krb5_how_much_data(const struct krb5_enctype *krb5,
					 chế độ enum krb5_crypto_mode,
					 size_t *_buffer_size, size_t *_offset);

Tất cả các chức năng này đều có kiểu mã hóa và chỉ báo chế độ mật mã
(chỉ mã hóa tổng kiểm tra hoặc mã hóa toàn bộ).

Hàm đầu tiên trả về độ lớn của bộ đệm để chứa một giá trị nhất định
lượng dữ liệu; hàm thứ hai trả về lượng dữ liệu sẽ vừa với bộ đệm
có kích thước cụ thể và điều chỉnh kích thước của bộ đệm cần thiết
tương ứng.  Trong cả hai trường hợp, độ lệch của dữ liệu trong bộ đệm cũng
đã quay trở lại.

Khi nhận được một tin nhắn, vị trí và kích thước của dữ liệu với
tin nhắn có thể được xác định bằng cách gọi::

void crypto_krb5_where_is_the_data(const struct krb5_enctype *krb5,
					   chế độ enum krb5_crypto_mode,
					   size_t *_offset, size_t *_len);

Người gọi cung cấp độ lệch và độ dài của thông báo cho hàm, điều này
sau đó thay đổi các giá trị đó để biểu thị vùng chứa dữ liệu (cộng với bất kỳ giá trị nào
đệm).  Người gọi có thể quyết định có bao nhiêu phần đệm.

Chức năng chuẩn bị
---------------------

Hai chức năng được cung cấp để phân bổ và chuẩn bị một đối tượng mật mã để sử dụng bởi
các chức năng hành động::

cấu trúc crypto_aead *
	crypto_krb5_prepare_encryption(const struct krb5_enctype *krb5,
				       const struct krb5_buffer *TK,
				       sử dụng u32, gfp_t gfp);
	cấu trúc crypto_shash *
	crypto_krb5_prepare_checksum(const struct krb5_enctype *krb5,
				     const struct krb5_buffer *TK,
				     sử dụng u32, gfp_t gfp);

Cả hai chức năng này đều có kiểu mã hóa, khóa vận chuyển và cách sử dụng
giá trị được sử dụng để lấy (các) khóa con thích hợp.  Họ tạo ra một môi trường thích hợp
đối tượng mật mã, mẫu AEAD để mã hóa và hàm băm đồng bộ cho
kiểm tra tổng hợp, đặt (các) khóa trên đó và định cấu hình nó.  Người gọi dự kiến sẽ
chuyển các thẻ điều khiển này tới các hàm hành động bên dưới.

Chế độ mã hóa
---------------

Một cặp chức năng được cung cấp để mã hóa và giải mã tin nhắn::

ssize_t crypto_krb5_encrypt(const struct krb5_enctype *krb5,
				    cấu trúc crypto_aead *aead,
				    danh sách phân tán cấu trúc *sg, unsigned int nr_sg,
				    size_t sg_len,
				    size_t data_offset, size_t data_len,
				    bool được xác định trước);
	int crypto_krb5_decrypt(const struct krb5_enctype *krb5,
				cấu trúc crypto_aead *aead,
				danh sách phân tán cấu trúc *sg, unsigned int nr_sg,
				size_t *_offset, size_t *_len);

Trong cả hai trường hợp, bộ đệm đầu vào và đầu ra được biểu thị bằng cùng một
danh sách phân tán.

Đối với chức năng mã hóa, bộ đệm đầu ra có thể lớn hơn mức cần thiết
(lượng đầu ra được tạo sẽ được trả về) và vị trí cũng như kích thước của
dữ liệu được chỉ định (phải khớp với mã hóa).  Nếu không có yếu tố gây nhiễu nào được thiết lập,
chức năng sẽ chèn một.

Đối với chức năng giải mã, độ lệch và độ dài của thông báo trong bộ đệm là
được cung cấp và chúng được thu nhỏ để phù hợp với dữ liệu.  Chức năng giải mã sẽ
xác minh mọi tổng kiểm tra trong tin nhắn và đưa ra lỗi nếu chúng không khớp.

Chế độ tổng kiểm tra
-------------

Một cặp chức năng được cung cấp để tạo ra tổng kiểm tra trên một tin nhắn và để
xác minh tổng kiểm tra đó::

ssize_t crypto_krb5_get_mic(const struct krb5_enctype *krb5,
				    cấu trúc crypto_shash *shash,
				    const struct krb5_buffer *siêu dữ liệu,
				    danh sách phân tán cấu trúc *sg, unsigned int nr_sg,
				    size_t sg_len,
				    size_t data_offset, size_t data_len);
	int crypto_krb5_verify_mic(const struct krb5_enctype *krb5,
				   cấu trúc crypto_shash *shash,
				   const struct krb5_buffer *siêu dữ liệu,
				   danh sách phân tán cấu trúc *sg, unsigned int nr_sg,
				   size_t *_offset, size_t *_len);

Trong cả hai trường hợp, bộ đệm đầu vào và đầu ra được biểu thị bằng cùng một
danh sách phân tán.  Siêu dữ liệu bổ sung có thể được chuyển vào đó sẽ được thêm vào
băm trước dữ liệu.

Đối với hàm get_mic, bộ đệm đầu ra có thể lớn hơn mức cần thiết (
lượng đầu ra được tạo sẽ được trả về) và vị trí cũng như kích thước của dữ liệu
được chỉ định (phải khớp với mã hóa).

Đối với chức năng xác minh, độ lệch và độ dài của thông báo trong bộ đệm
được cung cấp và chúng được thu nhỏ lại để phù hợp với dữ liệu.  Một lỗi sẽ được trả lại
nếu tổng kiểm tra không khớp.

Thuật toán krb5enc AEAD
==========================

Một thuật toán mật mã AEAD mẫu, được gọi là "krb5enc", được cung cấp để băm
bản rõ trước khi mã hóa nó (ngược lại với authenc).  Tay cầm đã quay trở lại
của ZZ0000ZZ có thể là một trong số đó, nhưng không có
yêu cầu người dùng API này phải tương tác trực tiếp với nó.

Để tham khảo, định dạng khóa của nó bắt đầu bằng BE32 của số định dạng.  Chỉ
định dạng 1 được cung cấp và tiếp tục với BE32 có độ dài khóa Ke
theo sau là BE32 có độ dài khóa Ki, theo sau là các byte từ khóa Ke
và sau đó là phím Ki.

Sử dụng các từ được sắp xếp cụ thể có nghĩa là dữ liệu thử nghiệm tĩnh không
yêu cầu trao đổi byte.