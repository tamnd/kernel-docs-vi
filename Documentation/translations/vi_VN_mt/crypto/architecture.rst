.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/architecture.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Kiến trúc hạt nhân Crypto API
==============================

Các loại thuật toán mã hóa
----------------------

Mật mã hạt nhân API cung cấp các lệnh gọi API khác nhau cho các mục sau
các loại mật mã:

- Mật mã đối xứng

- Mật mã AEAD

- Bản tóm tắt tin nhắn, bao gồm cả bản tóm tắt tin nhắn có khóa

- Tạo số ngẫu nhiên

- Giao diện không gian người dùng

Mật mã và mẫu
---------------------

Mật mã hạt nhân API cung cấp việc triển khai mật mã khối đơn
và tóm tắt tin nhắn. Ngoài ra, mật mã hạt nhân API còn cung cấp
nhiều "mẫu" có thể được sử dụng cùng với một đơn
chặn mật mã và tóm tắt thông điệp. Mẫu bao gồm tất cả các loại khối
chế độ chuỗi, cơ chế HMAC, v.v.

Mật mã khối đơn và tóm tắt thông điệp có thể được sử dụng trực tiếp bởi
người gọi hoặc được gọi cùng với một mẫu để tạo thành mật mã nhiều khối
hoặc bản tóm tắt tin nhắn có khóa.

Một mật mã khối đơn thậm chí có thể được gọi với nhiều mẫu.
Tuy nhiên, không thể sử dụng mẫu nếu không có một mật mã duy nhất.

Xem/proc/crypto và tìm kiếm "tên". Ví dụ:

- ae

- ecb(aes)

- cmac(aes)

- ccm(aes)

- rfc4106(gcm(aes))

- sha1

- hmac(sha1)

- authenc(hmac(sha1),cbc(aes))

Trong các ví dụ này, "aes" và "sha1" là mật mã và tất cả các mật mã khác là
các mẫu.

Hoạt động đồng bộ và không đồng bộ
--------------------------------------

Mật mã hạt nhân API cung cấp API đồng bộ và không đồng bộ
hoạt động.

Khi sử dụng thao tác API đồng bộ, người gọi sẽ gọi một mật mã
hoạt động được thực hiện đồng bộ bởi kernel crypto API.
Điều đó có nghĩa là người gọi sẽ đợi cho đến khi thao tác mã hóa hoàn tất.
Do đó, các lệnh gọi API của mật mã hạt nhân hoạt động giống như các lệnh gọi hàm thông thường.
Để hoạt động đồng bộ, tập hợp các lệnh gọi API nhỏ và
về mặt khái niệm tương tự như bất kỳ thư viện tiền điện tử nào khác.

Hoạt động không đồng bộ được cung cấp bởi mật mã hạt nhân API
ngụ ý rằng việc gọi một thao tác mã hóa sẽ gần như hoàn thành
ngay lập tức. Lời gọi đó kích hoạt hoạt động mã hóa nhưng nó không
báo hiệu sự hoàn thành của nó. Trước khi gọi một thao tác mã hóa, người gọi
phải cung cấp chức năng gọi lại mà mật mã hạt nhân API có thể gọi tới
báo hiệu sự hoàn thành của hoạt động mã hóa. Hơn nữa, người gọi
phải đảm bảo nó có thể xử lý các sự kiện không đồng bộ như vậy bằng cách áp dụng
khóa thích hợp xung quanh dữ liệu của nó. Mật mã hạt nhân API không
thực hiện bất kỳ thao tác tuần tự hóa đặc biệt nào để bảo vệ dữ liệu của người gọi
tính chính trực.

Mức độ ưu tiên và tham chiếu mật mã API của tiền điện tử
-----------------------------------------

Một mật mã được người gọi tham chiếu bằng một chuỗi. Chuỗi đó có
ngữ nghĩa sau:

::

mẫu (mật mã khối đơn)


trong đó "mẫu" và "mật mã khối đơn" được đề cập ở trên
mẫu và mật mã khối đơn tương ứng. Nếu có thể,
các mẫu bổ sung có thể kèm theo các mẫu khác, chẳng hạn như

::

template1(template2(mật mã khối đơn)))


Mật mã hạt nhân API có thể cung cấp nhiều triển khai của một mẫu
hoặc mật mã khối đơn. Ví dụ: AES trên phần cứng Intel mới hơn có
các triển khai sau: AES-NI, triển khai trình biên dịch mã hoặc
thẳng C. Bây giờ, khi sử dụng chuỗi "aes" với kernel crypto API,
việc triển khai mật mã nào được sử dụng? Câu trả lời cho câu hỏi đó là
số ưu tiên được hạt nhân gán cho mỗi lần triển khai mật mã
tiền điện tử API. Khi người gọi sử dụng chuỗi này để tham chiếu đến mật mã trong
khởi tạo một mã điều khiển mật mã, mật mã hạt nhân API sẽ tra cứu tất cả
các triển khai cung cấp một triển khai với tên đó và chọn
thực hiện với mức độ ưu tiên cao nhất.

Bây giờ, người gọi có thể cần tham khảo một mật mã cụ thể
thực hiện và do đó không muốn dựa vào ưu tiên dựa trên
lựa chọn. Để phù hợp với kịch bản này, mật mã hạt nhân API cho phép
việc triển khai mật mã để đăng ký một tên duy nhất ngoài
những cái tên thông dụng. Do đó, khi sử dụng tên duy nhất đó, người gọi luôn luôn
chắc chắn đề cập đến việc thực hiện mật mã dự định.

Danh sách các mật mã có sẵn được đưa ra trong /proc/crypto. Tuy nhiên, điều đó
danh sách không chỉ định tất cả các hoán vị có thể có của các mẫu và
mật mã. Mỗi khối được liệt kê trong /proc/crypto có thể chứa các mục sau
thông tin -- nếu một trong các thành phần được liệt kê dưới đây không
áp dụng cho mật mã, nó không được hiển thị:

- tên: tên chung của mật mã tuân theo
   lựa chọn dựa trên mức độ ưu tiên -- tên này có thể được mật mã sử dụng
   các cuộc gọi API phân bổ (tất cả các tên được liệt kê ở trên là ví dụ cho các cuộc gọi đó
   tên chung)

- trình điều khiển: tên duy nhất của mật mã -- tên này có thể được sử dụng bởi
   phân bổ mật mã cuộc gọi API

- mô-đun: mô-đun hạt nhân cung cấp việc triển khai mật mã (hoặc
   "kernel" cho các mật mã được liên kết tĩnh)

- mức độ ưu tiên: giá trị ưu tiên của việc thực hiện mật mã

- refcnt: số tham chiếu của mật mã tương ứng (tức là số
   của người tiêu dùng hiện tại của mật mã này)

- selftest: đặc tả liệu quá trình tự kiểm tra mật mã có đạt hay không

-  kiểu:

- skcipher cho mật mã khóa đối xứng

- mật mã cho mật mã khối đơn có thể được sử dụng với một
      mẫu bổ sung

- shash để tóm tắt tin nhắn đồng bộ

- ahash để thông báo tin nhắn không đồng bộ

- aead cho loại mật mã AEAD

- nén để chuyển đổi kiểu nén

- rng cho trình tạo số ngẫu nhiên

- kpp cho mật mã Nguyên thủy Giao thức thỏa thuận khóa (KPP), chẳng hạn như
      triển khai ECDH hoặc DH

- blocksize: kích thước khối của mật mã tính bằng byte

- keysize: kích thước khóa tính bằng byte

- ivsize: kích thước IV tính bằng byte

- Seedsize: kích thước yêu cầu của dữ liệu hạt giống cho trình tạo số ngẫu nhiên

- digsize: kích thước đầu ra của thông báo tóm tắt

- geniv: máy phát IV (lỗi thời)

Kích thước phím
---------

Khi cấp phát một mã điều khiển, người gọi chỉ xác định mật mã
loại. Tuy nhiên, mật mã đối xứng thường hỗ trợ nhiều kích cỡ khóa
(ví dụ: AES-128 so với AES-192 so với AES-256). Các kích thước khóa này được xác định
với độ dài của khóa được cung cấp. Do đó, mật mã hạt nhân API thực hiện
không cung cấp một cách riêng để chọn khóa mật mã đối xứng cụ thể
kích thước.

Loại phân bổ mật mã và mặt nạ
--------------------------------

Các chức năng phân bổ xử lý mật mã khác nhau cho phép đặc tả
của một loại và cờ mặt nạ. Cả hai tham số đều có ý nghĩa như sau (và
do đó không được đề cập trong các phần tiếp theo).

Cờ loại chỉ định loại thuật toán mã hóa. người gọi
thường cung cấp số 0 khi người gọi muốn xử lý mặc định.
Mặt khác, người gọi có thể cung cấp các lựa chọn phù hợp sau đây
các loại mật mã nói trên:

- CRYPTO_ALG_TYPE_CIPHER Mật mã khối đơn

- Mã hóa xác thực CRYPTO_ALG_TYPE_AEAD với dữ liệu liên quan
   (MAC)

- CRYPTO_ALG_TYPE_KPP Giao thức thỏa thuận khóa nguyên thủy (KPP) chẳng hạn như
   triển khai ECDH hoặc DH

- CRYPTO_ALG_TYPE_HASH Bản tóm tắt tin nhắn thô

- CRYPTO_ALG_TYPE_SHASH Băm đa khối đồng bộ

- CRYPTO_ALG_TYPE_AHASH Băm đa khối không đồng bộ

- Tạo số ngẫu nhiên CRYPTO_ALG_TYPE_RNG

- Mật mã bất đối xứng CRYPTO_ALG_TYPE_AKCIPHER

- Chữ ký bất đối xứng CRYPTO_ALG_TYPE_SIG

- CRYPTO_ALG_TYPE_PCOMPRESS Phiên bản nâng cao của
   CRYPTO_ALG_TYPE_COMPRESS cho phép nén phân đoạn /
   giải nén thay vì thực hiện thao tác trên một phân đoạn
   chỉ. CRYPTO_ALG_TYPE_PCOMPRESS được thiết kế để thay thế
   CRYPTO_ALG_TYPE_COMPRESS khi người tiêu dùng hiện tại được chuyển đổi.

Cờ mặt nạ hạn chế loại mật mã. Cờ duy nhất được phép là
CRYPTO_ALG_ASYNC để hạn chế chức năng tra cứu mật mã ở
mật mã không đồng bộ. Thông thường, người gọi cung cấp số 0 cho cờ mặt nạ.

Khi người gọi cung cấp đặc tả mặt nạ và loại, người gọi
giới hạn việc tìm kiếm mà mật mã hạt nhân API có thể thực hiện để tìm một loại tiền phù hợp
triển khai mật mã cho tên mật mã đã cho. Điều đó có nghĩa là ngay cả khi một
người gọi sử dụng tên mật mã tồn tại trong cuộc gọi khởi tạo của nó,
mật mã hạt nhân API có thể không chọn nó do loại và mặt nạ được sử dụng
lĩnh vực.

Cấu trúc bên trong của Kernel Crypto API
---------------------------------------

Mật mã hạt nhân API có cấu trúc bên trong nơi mật mã
việc thực hiện có thể sử dụng nhiều lớp và hướng dẫn. Phần này sẽ
giúp làm rõ cách thức kernel crypto API sử dụng các thành phần khác nhau để
thực hiện mật mã hoàn chỉnh.

Các tiểu mục sau đây giải thích cấu trúc bên trong dựa trên
triển khai mật mã hiện có. Phần đầu tiên đề cập nhiều nhất
kịch bản phức tạp trong đó tất cả các kịch bản khác tạo thành một tập hợp con logic.

Cấu trúc mật mã AEAD chung
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nghệ thuật ASCII sau đây phân tách các lớp mật mã hạt nhân API khi
sử dụng mật mã AEAD với thế hệ IV tự động. được hiển thị
ví dụ được sử dụng bởi lớp IPSEC.

Đối với các trường hợp sử dụng khác của mật mã AEAD, phần ASCII cũng được áp dụng, nhưng
người gọi không được sử dụng mật mã AEAD với bộ tạo IV riêng. trong
trường hợp này, người gọi phải tạo IV.

Ví dụ được mô tả phân tách mật mã AEAD của GCM(AES) dựa trên
triển khai C chung (gcm.c, aes-generic.c, ctr.c, ghash-generic.c,
seqiv.c). Việc triển khai chung đóng vai trò là một ví dụ cho thấy
logic hoàn chỉnh của mật mã hạt nhân API.

Có thể một số triển khai mật mã được sắp xếp hợp lý (như
AES-NI) cung cấp các khía cạnh hợp nhất triển khai theo quan điểm của
kernel crypto API không thể phân tách thành các lớp nữa. Trong trường hợp
triển khai AES-NI, chế độ CTR, triển khai GHASH và
tất cả mật mã AES đều được hợp nhất thành một triển khai mật mã đã đăng ký
với mật mã hạt nhân API. Trong trường hợp này, khái niệm được mô tả bởi
nghệ thuật ASCII sau đây cũng được áp dụng. Tuy nhiên, việc phân hủy GCM thành
các thành phần phụ riêng lẻ bằng mật mã hạt nhân API không được thực hiện bất kỳ
nhiều hơn nữa.

Mỗi khối trong hình minh họa ASCII sau đây là một phiên bản mật mã độc lập
thu được từ mật mã hạt nhân API. Mỗi khối được truy cập bởi
người gọi hoặc bởi các khối khác bằng cách sử dụng các hàm API được xác định bởi kernel
crypto API cho loại triển khai mật mã.

Các khối bên dưới cho biết loại mật mã cũng như logic cụ thể
được thực hiện trong mật mã.

Bức tranh nghệ thuật ASCII còn cho biết cấu trúc cuộc gọi, tức là ai gọi
thành phần nào. Các mũi tên chỉ vào khối được gọi nơi người gọi
sử dụng API áp dụng cho loại mật mã được chỉ định cho khối.

::


mật mã hạt nhân API |   Lớp IPSEC
                                                     |
    +----------+ |
    ZZ0000ZZ (1)
    ZZ0001ZZ <----------------------------------- Esp_output
    ZZ0002ZZ ---+
    +----------+ |
                     | (2)
    +----------+ |
    ZZ0003ZZ <--+ (2)
    ZZ0004ZZ <----------------------------------- Esp_input
    ZZ0005ZZ ------------+
    +----------+ |
          ZZ0006ZZ (5)
          v v
    +----------+ +-----------+
    ZZ0007ZZ ZZ0008ZZ
    ZZ0009ZZ ZZ0010ZZ
    ZZ0011ZZ ---+ ZZ0012ZZ
    +----------+ |  +----------+
                     |
    +----------+ | (4)
    ZZ0013ZZ <--+
    ZZ0014ZZ
    ZZ0015ZZ
    +----------+



Trình tự cuộc gọi sau đây được áp dụng khi lớp IPSEC kích hoạt
một hoạt động mã hóa với hàm Esp_output. Trong thời gian
cấu hình, quản trị viên thiết lập việc sử dụng seqiv(rfc4106(gcm(aes)))
làm mật mã cho ESP. Chuỗi cuộc gọi sau đây hiện được mô tả trong
nghệ thuật ASCII ở trên:

1. Esp_output() gọi crypto_aead_encrypt() để kích hoạt
   hoạt động mã hóa của mật mã AEAD với trình tạo IV.

SEQIV tạo ra IV.

2. Bây giờ, SEQIV sử dụng lệnh gọi hàm AEAD API để gọi liên kết
   Mật mã AEAD. Trong trường hợp của chúng tôi, trong quá trình khởi tạo SEQIV,
   mã xử lý cho GCM được cung cấp cho SEQIV. Điều này có nghĩa là SEQIV
   gọi các hoạt động mật mã AEAD bằng tay cầm mật mã GCM.

Trong quá trình khởi tạo bộ điều khiển GCM, CTR(AES) và GHASH
   mật mã được khởi tạo. Mã xử lý cho CTR(AES) và GHASH
   được giữ lại để sử dụng sau này.

Việc triển khai GCM có trách nhiệm gọi chế độ CTR AES và
   mật mã GHASH theo đúng cách để triển khai GCM
   đặc điểm kỹ thuật.

3. Việc triển khai loại mật mã GCM AEAD hiện gọi SKCIPHER API
   với mã xử lý mật mã CTR(AES) được khởi tạo.

Trong quá trình khởi tạo mật mã CTR(AES), loại CIPHER
   việc triển khai AES được khởi tạo. Mã xử lý mật mã cho AES là
   được giữ lại.

Điều đó có nghĩa là việc triển khai SKCIPHER chỉ của CTR(AES)
   thực hiện chế độ chuỗi khối CTR. Sau khi thực hiện khối
   hoạt động xâu chuỗi, việc triển khai CIPHER của AES được gọi.

4. SKCIPHER của CTR(AES) hiện gọi CIPHER API bằng AES
   xử lý mật mã để mã hóa một khối.

5. Việc triển khai GCM AEAD cũng gọi mật mã GHASH
   triển khai thông qua AHASH API.

Khi lớp IPSEC kích hoạt hàm Esp_input(), lệnh gọi tương tự
trình tự được theo sau với sự khác biệt duy nhất là hoạt động bắt đầu
với bước (2).

Cấu trúc mật mã khối chung
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mật mã khối chung tuân theo khái niệm tương tự như được mô tả với ASCII
bức tranh nghệ thuật trên.

Ví dụ: CBC(AES) được triển khai với cbc.c và aes-generic.c. các
Hình ảnh nghệ thuật ASCII trên cũng được áp dụng với sự khác biệt mà chỉ
bước (4) được sử dụng và chế độ chuỗi khối SKCIPHER là CBC.

Cấu trúc tóm tắt thông điệp có khóa chung
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Việc triển khai thông báo thông báo có khóa lại tuân theo khái niệm tương tự như
được mô tả trong bức tranh nghệ thuật ASCII ở trên.

Ví dụ: HMAC(SHA256) được triển khai với hmac.c và
sha256_generic.c. Nghệ thuật ASCII sau đây minh họa
thực hiện:

::


mật mã hạt nhân API |       Người gọi
                                 |
    +----------+ (1) |
    ZZ0000ZZ <------------------- một số_chức năng
    ZZ0001ZZ
    ZZ0002ZZ ---+
    +----------+ |
                     | (2)
    +----------+ |
    ZZ0003ZZ <--+
    ZZ0004ZZ
    ZZ0005ZZ
    +----------+



Trình tự cuộc gọi sau đây được áp dụng khi người gọi kích hoạt HMAC
hoạt động:

1. Các hàm AHASH API được gọi bởi người gọi. HMAC
   việc triển khai thực hiện hoạt động của nó khi cần thiết.

Trong quá trình khởi tạo mật mã HMAC, loại mật mã SHASH của
   SHA256 được khởi tạo. Mã xử lý cho phiên bản SHA256 là
   được giữ lại.

Tại một thời điểm, việc triển khai HMAC yêu cầu thao tác SHA256
   nơi sử dụng mã xử lý mật mã SHA256.

2. Phiên bản HMAC hiện gọi SHASH API bằng mật mã SHA256
   xử lý để tính toán thông báo.
