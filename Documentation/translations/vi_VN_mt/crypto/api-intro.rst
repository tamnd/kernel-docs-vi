.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-intro.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Danh sách phân tán Mật mã API
=============================

Giới thiệu
============

Danh sách phân tán Crypto API lấy vectơ trang (danh sách phân tán) làm
đối số và hoạt động trực tiếp trên các trang.  Trong một số trường hợp (ví dụ: ECB
mật mã chế độ), điều này sẽ cho phép các trang được mã hóa tại chỗ
không có sự sao chép.

Một trong những mục tiêu ban đầu của thiết kế này là sẵn sàng hỗ trợ IPsec,
để việc xử lý có thể được áp dụng cho skb được phân trang mà không cần
để tuyến tính hóa.


Chi tiết
=======

Ở mức thấp nhất là các thuật toán đăng ký động với
API.

'Biến đổi' là các đối tượng do người dùng khởi tạo, duy trì trạng thái, xử lý tất cả
của logic triển khai (ví dụ: thao tác vectơ trang) và cung cấp
trừu tượng hóa các thuật toán cơ bản.  Tuy nhiên, ở người dùng
mức độ chúng rất đơn giản.

Về mặt khái niệm, lớp API trông như thế này::

[chuyển đổi api] (giao diện người dùng)
  [các hoạt động biến đổi] (keo logic cho mỗi loại, ví dụ: cipher.c, Compress.c)
  [algorithm api] (để đăng ký thuật toán)

Ý tưởng là tạo giao diện người dùng và đăng ký thuật toán API
rất đơn giản, đồng thời ẩn logic cốt lõi khỏi cả hai.  Nhiều ý tưởng hay
từ các API hiện có như Cryptoapi và Nettle đã được điều chỉnh cho việc này.

API hiện hỗ trợ năm loại biến đổi chính: AEAD (Xác thực
Mã hóa với dữ liệu liên kết), Mật mã khối, Mật mã, Máy nén và
Băm.

Xin lưu ý rằng Mật mã khối có phần bị sử dụng sai.  Trên thực tế đó là
có nghĩa là hỗ trợ tất cả các mật mã bao gồm cả mật mã luồng.  Sự khác biệt
giữa Mật mã khối và Mật mã là cái sau hoạt động chính xác trên
một khối trong khi khối trước có thể hoạt động trên một lượng dữ liệu tùy ý,
tùy thuộc vào yêu cầu về kích thước khối (nghĩa là mật mã không theo dòng chỉ có thể
xử lý bội số khối).

Đây là ví dụ về cách sử dụng API::

#include <crypto/hash.h>
	#include <linux/err.h>
	#include <linux/scatterlist.h>

danh sách phân tán cấu trúc sg[2];
	kết quả char[128];
	struct crypto_ahash *tfm;
	cấu trúc ahash_request *req;

tfm = crypto_alloc_ahash("md5", 0, CRYPTO_ALG_ASYNC);
	nếu (IS_ERR(tfm))
		thất bại();

/* ... thiết lập danh sách phân tán ... */

req = ahash_request_alloc(tfm, GFP_ATOMIC);
	nếu (!req)
		thất bại();

ahash_request_set_callback(req, 0, NULL, NULL);
	ahash_request_set_crypt(req, sg, result, 2);

nếu (crypto_ahash_digest(req))
		thất bại();

ahash_request_free(req);
	crypto_free_ahash(tfm);


Nhiều ví dụ thực tế có sẵn trong mô-đun kiểm tra hồi quy (tcrypt.c).


Ghi chú của nhà phát triển
===============

Các biến đổi chỉ có thể được phân bổ trong ngữ cảnh của người dùng và mật mã
các phương thức chỉ có thể được gọi từ bối cảnh softirq và người dùng.  cho
biến đổi bằng phương thức setkey, nó cũng chỉ nên được gọi từ
bối cảnh người dùng.

Khi sử dụng API cho mật mã, hiệu suất sẽ tối ưu nếu mỗi
danh sách phân tán chứa dữ liệu là bội số của khối mật mã
kích thước (thường là 8 byte).  Điều này ngăn cản việc phải thực hiện bất kỳ việc sao chép
qua các ranh giới phân đoạn trang không liên kết.


Thêm thuật toán mới
=====================

Khi gửi một thuật toán mới để đưa vào, một yêu cầu bắt buộc
đó là ít nhất một vài vectơ thử nghiệm từ các nguồn đã biết (tốt nhất là
tiêu chuẩn) được đưa vào.

Việc chuyển đổi mã nổi tiếng hiện có được ưu tiên hơn vì có nhiều khả năng hơn
đã được xem xét và thử nghiệm rộng rãi.  Nếu gửi mã từ LGPL
nguồn, vui lòng xem xét việc thay đổi giấy phép thành GPL (xem phần 3 của
LGPL).

Các thuật toán được gửi nói chung cũng phải không có bằng sáng chế (ví dụ: IDEA
sẽ không được đưa vào dòng chính cho đến khoảng năm 2011) và dựa trên
theo tiêu chuẩn được công nhận và/hoặc đã được áp dụng các biện pháp thích hợp
đánh giá ngang hàng.

Đồng thời kiểm tra mọi RFC có thể liên quan đến việc sử dụng các thuật toán cụ thể,
cũng như các ghi chú ứng dụng chung như RFC2451 ("ESP CBC-Mode
Thuật toán mật mã").

Bạn nên tránh sử dụng nhiều macro và sử dụng các hàm nội tuyến
thay vào đó, vì gcc thực hiện tốt công việc nội tuyến, trong khi việc sử dụng quá nhiều
macro có thể gây ra sự cố biên dịch trên một số nền tảng.

Đồng thời kiểm tra danh sách TODO tại trang web được liệt kê bên dưới để xem mọi người
có thể đã đang làm việc.


Lỗi
====

Gửi báo cáo lỗi tới:
    linux-crypto@vger.kernel.org

Cc:
    Herbert Xu <herbert@gondor.apana.org.au>,
    David S. Miller <davem@redhat.com>


Thông tin thêm
===================

Để biết thêm các bản vá và cập nhật khác nhau, bao gồm TODO hiện tại
danh sách, xem:
ZZ0000ZZ


tác giả
=======

- James Morris
- David S. Miller
- Herbert Xu


Tín dụng
=======

Những người sau đây đã cung cấp phản hồi có giá trị trong quá trình phát triển
của API:

- Alexey Kuznetzov
  - Rusty Russell
  - Herbert Valerio Riedel
  - Jeff Garzik
  - Michael Richardson
  - Andrew Morton
  - Ingo Oeser
  - Christoph Hellwig

Các phần của API này được lấy từ các dự án sau:

Hạt nhân tiền điện tử (ZZ0000ZZ
   - Alexander Kjeldaas
   - Herbert Valerio Riedel
   - Kyle McMartin
   - Jean-Luc Cooke
   - David Bryson
   - Clemens Fruhwirth
   - Tobias Ringstrom
   - Harald Welte

Và;

Cây tầm ma (ZZ0000ZZ
   - Niels Möller

Các nhà phát triển ban đầu của thuật toán tiền điện tử:

- Dana L. Thế nào (DES)
  - Andrew Tridgell và Steve French (MD4)
  - Colin Plumb (MD5)
  - Steve Reid (SHA1)
  - Jean-Luc Cooke (SHA256, SHA384, SHA512)
  - Kazunori Miyazawa / USAGI (HMAC)
  - Matthew Skala (Hai con cá)
  - Dag Arne Osvik (Con rắn)
  - Brian Gladman (AES)
  - Kartikey Mahendra Bhatt (CAST6)
  - Jon Oberheide (ARC4)
  - Jouni Malinen (Michael MIC)
  - NTT(Tập đoàn điện thoại và điện thoại Nippon) (Camellia)

Những người đóng góp thuật toán SHA1:
  - Lặn Jean-Francois

Những người đóng góp thuật toán DES:
  - Raimar Falke
  - Gisle Sælensminde
  - Niels Möller

Những người đóng góp cho thuật toán Blowfish:
  - Herbert Valerio Riedel
  - Kyle McMartin

Những người đóng góp cho thuật toán Twofish:
  - Werner Koch
  - Marc Mutz

Những người đóng góp thuật toán SHA256/384/512:
  - Andrew McDonald
  - Kyle McMartin
  - Herbert Valerio Riedel

Những người đóng góp thuật toán AES:
  - Alexander Kjeldaas
  - Herbert Valerio Riedel
  - Kyle McMartin
  - Adam J. Richter
  - Fruhwirth Clemens (i586)
  - Linus Torvalds (i586)

Những người đóng góp thuật toán CAST5:
  - Kartikey Mahendra Bhatt (không rõ nhà phát triển ban đầu, bản quyền FSF).

Những người đóng góp thuật toán TEA/XTEA:
  - Aaron Grothe
  - Michael Ringe

Những người đóng góp cho thuật toán Khazad:
  - Aaron Grothe

Những người đóng góp cho thuật toán Whirlpool:
  - Aaron Grothe
  - Jean-Luc Cooke

Những người đóng góp thuật toán Anubis:
  - Aaron Grothe

Những người đóng góp cho thuật toán Tiger:
  - Aaron Grothe

Những người đóng góp cho VIA PadLock:
  - Michal Ludvig

Những người đóng góp thuật toán Camellia:
  - NTT(Tập đoàn điện thoại và điện thoại Nippon) (Camellia)

Mã phân tán chung của Adam J. Richter <adam@yggdrasil.com>

Vui lòng gửi bất kỳ thông tin cập nhật hoặc chỉnh sửa nào về tín dụng tới:
Herbert Xu <herbert@gondor.apana.org.au>