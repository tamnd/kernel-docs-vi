.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/devel-algos.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Phát triển thuật toán mật mã
============================

Đăng ký và hủy đăng ký chuyển đổi
--------------------------------------------

Có ba loại chức năng đăng ký riêng biệt trong Crypto
API. Một được sử dụng để đăng ký một chuyển đổi mật mã chung,
trong khi hai cái còn lại dành riêng cho các phép biến đổi HASH và
NÉN. Chúng ta sẽ thảo luận về hai điều sau trong một chương riêng, ở đây
chúng ta sẽ chỉ nhìn vào những cái chung chung.

Trước khi thảo luận về các chức năng đăng ký, cấu trúc dữ liệu cần
chứa đầy từng cấu trúc, struct crypto_alg, phải được xem xét -- xem bên dưới
để biết mô tả về cấu trúc dữ liệu này.

Các chức năng đăng ký chung có thể được tìm thấy trong
include/linux/crypto.h và định nghĩa của chúng có thể được xem bên dưới. các
hàm trước đăng ký một phép biến đổi duy nhất, trong khi hàm sau
hoạt động trên một loạt các mô tả chuyển đổi. Cái sau rất hữu ích
khi đăng ký các chuyển đổi hàng loạt, ví dụ như khi một trình điều khiển
thực hiện nhiều phép biến đổi.

::

int crypto_register_alg(struct crypto_alg *alg);
       int crypto_register_algs(struct crypto_alg *algs, int count);


Các đối tác của các chức năng đó được liệt kê dưới đây.

::

void crypto_unregister_alg(struct crypto_alg *alg);
       void crypto_unregister_algs(struct crypto_alg *algs, int count);


Các hàm đăng ký trả về 0 nếu thành công hoặc có lỗi âm
giá trị khi thất bại.  crypto_register_algs() chỉ thành công nếu nó
đăng ký thành công tất cả các thuật toán đã cho; nếu nó thất bại giữa chừng
qua, sau đó mọi thay đổi sẽ được khôi phục.

Chức năng hủy đăng ký luôn thành công nên không có
giá trị trả về.  Đừng cố hủy đăng ký các thuật toán không phù hợp
hiện đã đăng ký.

Mật mã đối xứng một khối [CIPHER]
---------------------------------------

Ví dụ về các phép biến hình: aes, snake, ...

Phần này mô tả cách chuyển đổi đơn giản nhất
triển khai, đó là loại CIPHER được sử dụng cho mật mã đối xứng.
Loại CIPHER được sử dụng cho các phép biến đổi hoạt động trên chính xác một
khối tại một thời điểm và không có sự phụ thuộc nào giữa các khối.

Thông tin đăng ký cụ thể
~~~~~~~~~~~~~~~~~~~~~~

Việc đăng ký thuật toán [CIPHER] cụ thể trong cấu trúc đó
trường crypto_alg .cra_type trống. .cra_u.cipher phải là
điền vào các lệnh gọi lại thích hợp để thực hiện chuyển đổi này.

Xem cấu trúc cipher_alg bên dưới.

Định nghĩa mật mã Với struct cipher_alg
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu trúc cipher_alg xác định một mật mã khối đơn.

Dưới đây là sơ đồ về cách gọi các hàm này khi được vận hành từ
phần khác của hạt nhân. Lưu ý rằng lệnh gọi .cia_setkey() có thể xảy ra
trước hoặc sau khi bất kỳ sơ đồ nào trong số này xảy ra, nhưng không được xảy ra
trong bất kỳ thời điểm nào trong số này đang trên chuyến bay.

::

KEY ---.    PLAINTEXT ---.
                    v v
              .cia_setkey() -> .cia_encrypt()
                                      |
                                      '-------> CIPHERTEXT


Xin lưu ý rằng mẫu trong đó .cia_setkey() được gọi nhiều lần
cũng hợp lệ:

::


KEY1 --.    PLAINTEXT1 --.         KEY2 --.    PLAINTEXT2 --.
             v v v v
       .cia_setkey() -> .cia_encrypt() -> .cia_setkey() -> .cia_encrypt()
                               ZZ0000ZZ
                               '---> CIPHERTEXT1 '---> CIPHERTEXT2


Mật mã nhiều khối
-------------------

Ví dụ về các phép biến đổi: cbc(aes), chacha20, ...

Phần này mô tả việc chuyển đổi mật mã đa khối
triển khai. Mật mã đa khối được sử dụng để chuyển đổi
hoạt động trên danh sách phân tán dữ liệu được cung cấp cho quá trình chuyển đổi
chức năng. Họ cũng xuất kết quả thành một danh sách phân tán dữ liệu.

Thông tin đăng ký cụ thể
~~~~~~~~~~~~~~~~~~~~~~

Việc đăng ký các thuật toán mã hóa đa khối là một trong những
các quy trình tiêu chuẩn trong toàn bộ mật mã API.

Lưu ý, nếu việc triển khai mật mã yêu cầu căn chỉnh dữ liệu phù hợp,
người gọi nên sử dụng các hàm của crypto_skcipher_alignmask() để
xác định mặt nạ căn chỉnh bộ nhớ. Mật mã hạt nhân API có thể
xử lý các yêu cầu không được căn chỉnh. Tuy nhiên, điều này ngụ ý thêm
chi phí chung vì mật mã hạt nhân API cần thực hiện việc sắp xếp lại
dữ liệu có thể ngụ ý di chuyển dữ liệu.

Định nghĩa mật mã Với struct skcipher_alg
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cấu trúc skcipher_alg định nghĩa một mật mã đa khối, hay nói chung hơn là một
thuật toán mã hóa đối xứng bảo toàn độ dài.

Xử lý danh sách phân tán
~~~~~~~~~~~~~~~~~~~~

Một số trình điều khiển sẽ muốn sử dụng Generic ScatterWalk trong trường hợp
phần cứng cần được cung cấp các phần riêng biệt của danh sách phân tán
chứa bản rõ và sẽ chứa bản mã. Hãy tham khảo
tới giao diện ScatterWalk được cung cấp bởi nhân Linux phân tán /
tập hợp thực hiện danh sách.

Băm [HASH]
--------------

Ví dụ về các phép biến đổi: crc32, md5, sha1, sha256,...

Đăng ký và hủy đăng ký chuyển đổi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có nhiều cách để đăng ký chuyển đổi HASH, tùy thuộc vào
liệu chuyển đổi có đồng bộ [SHASH] hay không đồng bộ
[AHASH] và số lượng phép biến đổi HASH mà chúng tôi đang đăng ký. bạn
có thể tìm thấy các nguyên mẫu được xác định trong include/crypto/internal/hash.h:

::

int crypto_register_ahash(struct ahash_alg *alg);

int crypto_register_shash(struct shash_alg *alg);
       int crypto_register_shashes(struct shash_alg *algs, int count);


Các đối tác tương ứng để hủy đăng ký chuyển đổi HASH
như sau:

::

void crypto_unregister_ahash(struct ahash_alg *alg);

void crypto_unregister_shash(struct shash_alg *alg);
       void crypto_unregister_shashes(struct shash_alg *algs, int count);


Định nghĩa mật mã Với struct shash_alg và ahash_alg
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Dưới đây là sơ đồ về cách gọi các hàm này khi được vận hành từ
phần khác của hạt nhân. Lưu ý rằng cuộc gọi .setkey() có thể xảy ra
trước hoặc sau khi bất kỳ sơ đồ nào trong số này xảy ra, nhưng không được xảy ra
trong bất kỳ thời điểm nào trong số này đang trên chuyến bay. Xin lưu ý rằng việc gọi .init()
ngay sau đó là .final() cũng là một kết quả hoàn toàn hợp lệ
sự biến đổi.

::

Tôi) DATA -----------.
                            v
             .init() -> .update() -> .final() ! .update() có thể không được gọi
                         ^ ZZ0000ZZ trong kịch bản này.
                         '----' '---> HASH

II) DATA -------------.----------.
                            v v
             .init() -> .update() -> .finup() ! .update() có thể không được gọi
                         ^ ZZ0000ZZ trong kịch bản này.
                         '----' '---> HASH

III) DATA ----------.
                            v
                        .digest() ! Toàn bộ quá trình được xử lý
                            |                        bằng lệnh gọi .digest().
                            '---------------> HASH


Dưới đây là sơ đồ về cách gọi các hàm .export()/.import()
khi được sử dụng từ một phần khác của kernel.

::

KEY--.                 DATA--.
            v v ! .update() có thể không được gọi
        .setkey() -> .init() -> .update() -> .export() trong trường hợp này.
                                 ^ ZZ0000ZZ
                                 '------' '--> PARTIAL_HASH

----------- những biến đổi khác xảy ra ở đây -----------

PARTIAL_HASH--.   DATA1--.
                     v v
                 .import -> .update() -> .final() ! .update() có thể không được gọi
                             ^ ZZ0000ZZ trong kịch bản này.
                             '----' '--> HASH1

PARTIAL_HASH--.   DATA2-.
                     v v
                 .import -> .finup()
                               |
                               '---------------> HASH2

Lưu ý rằng việc "từ bỏ" một đối tượng yêu cầu là hoàn toàn hợp pháp:
- gọi .init() và sau đó (nhiều lần) .update()
- _not_ gọi bất kỳ .final(), .finup() hoặc .export() nào tại bất kỳ thời điểm nào trong tương lai

Nói cách khác, việc triển khai nên lưu ý đến việc phân bổ và dọn dẹp tài nguyên.
Không có tài nguyên nào liên quan đến đối tượng yêu cầu sẽ được phân bổ sau cuộc gọi
thành .init() hoặc .update(), vì có thể không có cơ hội giải phóng chúng.


Thông số cụ thể của chuyển đổi HASH không đồng bộ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một số trình điều khiển sẽ muốn sử dụng Generic ScatterWalk trong trường hợp
việc triển khai cần được cung cấp các phần riêng biệt của danh sách phân tán
chứa dữ liệu đầu vào.
