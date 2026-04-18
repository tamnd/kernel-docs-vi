.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/sha3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Bộ sưu tập thuật toán SHA-3
=============================

.. contents::

Tổng quan
========

Nhóm thuật toán SHA-3, như được chỉ định trong NIST FIPS-202 [1]_, chứa sáu
thuật toán dựa trên hàm xốp Keccak.  Sự khác biệt giữa chúng
là: "tốc độ" (bao nhiêu bộ đệm trạng thái được cập nhật với dữ liệu mới giữa
các lệnh gọi hàm Keccak và tương tự như "kích thước khối"), thì sao?
hậu tố phân tách miền được thêm vào dữ liệu đầu vào và lượng dữ liệu đầu ra
dữ liệu được trích xuất ở cuối.  Chức năng bọt biển Keccak được thiết kế sao cho
số lượng đầu ra tùy ý có thể thu được cho các thuật toán nhất định.

Bốn thuật toán tóm tắt được cung cấp:

-SHA3-224
 -SHA3-256
 -SHA3-384
 -SHA3-512

Ngoài ra, hai Chức năng đầu ra có thể mở rộng (XOF) được cung cấp:

-SHAKE128
 -SHAKE256

Thư viện SHA-3 API hỗ trợ tất cả sáu thuật toán này.  Bốn bản tóm tắt
các thuật toán cũng được hỗ trợ bởi API crypto_shash và crypto_ahash.

Tài liệu này mô tả thư viện SHA-3 API.


Thông báo
=======

Các hàm sau tính toán các bản tóm tắt SHA-3::

void sha3_224(const u8 *in, size_t in_len, u8 out[SHA3_224_DIGEST_SIZE]);
	void sha3_256(const u8 *in, size_t in_len, u8 out[SHA3_256_DIGEST_SIZE]);
	void sha3_384(const u8 *in, size_t in_len, u8 out[SHA3_384_DIGEST_SIZE]);
	void sha3_512(const u8 *in, size_t in_len, u8 out[SHA3_512_DIGEST_SIZE]);

Đối với người dùng cần truyền dữ liệu tăng dần, API tăng dần cũng
được cung cấp.  API tăng dần sử dụng cấu trúc sau::

cấu trúc sha3_ctx { ... };

Việc khởi tạo được thực hiện bằng một trong::

void sha3_224_init(struct sha3_ctx *ctx);
	void sha3_256_init(struct sha3_ctx *ctx);
	void sha3_384_init(struct sha3_ctx *ctx);
	void sha3_512_init(struct sha3_ctx *ctx);

Dữ liệu đầu vào sau đó được thêm vào với bất kỳ số lượng cuộc gọi nào tới ::

void sha3_update(struct sha3_ctx *ctx, const u8 *in, size_t in_len);

Cuối cùng, thông báo được tạo bằng cách sử dụng ::

void sha3_final(struct sha3_ctx *ctx, u8 *out);

điều này cũng làm mất đi bối cảnh.  Độ dài của quá trình phân hủy được xác định bởi
hàm khởi tạo được gọi.


Chức năng đầu ra có thể mở rộng
===========================

Các hàm sau tính toán các hàm đầu ra có thể mở rộng SHA-3 (XOF)::

void shake128(const u8 *in, size_t in_len, u8 *out, size_t out_len);
	void shake256(const u8 *in, size_t in_len, u8 *out, size_t out_len);

Đối với người dùng cần cung cấp dữ liệu đầu vào tăng dần và/hoặc nhận
dữ liệu đầu ra tăng dần, API tăng dần cũng được cung cấp.  Sự gia tăng
API sử dụng cấu trúc sau ::

struct shake_ctx { ... };

Việc khởi tạo được thực hiện bằng một trong::

void shake128_init(struct shake_ctx *ctx);
	void shake256_init(struct shake_ctx *ctx);

Dữ liệu đầu vào sau đó được thêm vào với bất kỳ số lượng cuộc gọi nào tới ::

void shake_update(struct shake_ctx *ctx, const u8 *in, size_t in_len);

Cuối cùng, dữ liệu đầu ra được trích xuất với số lượng lệnh gọi bất kỳ tới ::

void shake_squeeze(struct shake_ctx *ctx, u8 *out, size_t out_len);

và cho nó biết lượng dữ liệu cần được trích xuất.  Lưu ý rằng việc thực hiện nhiều
siết chặt, với đầu ra được đặt liên tiếp trong bộ đệm, sẽ giống hệt nhau
đầu ra giống như thực hiện một lần ép cho tổng số lượng trên cùng một bộ đệm.

Không thể thêm nhiều dữ liệu đầu vào hơn sau khi quá trình ép đã bắt đầu.

Khi tất cả đầu ra mong muốn đã được trích xuất, hãy xóa bối cảnh ::

void shake_zeroize_ctx(struct shake_ctx *ctx);


Kiểm tra
=======

Để kiểm tra mã SHA-3, hãy sử dụng sha3_kunit (CONFIG_CRYPTO_LIB_SHA3_KUNIT_TEST).

Do thuật toán SHA-3 được FIPS phê duyệt nên khi kernel được khởi động trong FIPS
chế độ thư viện SHA-3 cũng thực hiện tự kiểm tra đơn giản.  Đây hoàn toàn là để gặp gỡ
yêu cầu FIPS.  Thử nghiệm thông thường được thực hiện bởi các nhà phát triển và tích hợp kernel
thay vào đó nên sử dụng bộ kiểm tra KUnit toàn diện hơn nhiều.


Tài liệu tham khảo
==========

.. [1] https://nvlpubs.nist.gov/nistpubs/FIPS/NIST.FIPS.202.pdf


Tham khảo chức năng API
======================

.. kernel-doc:: include/crypto/sha3.h