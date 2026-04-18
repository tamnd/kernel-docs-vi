.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/userspace-if.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện không gian người dùng
===============================

Giới thiệu
------------

Các khái niệm về mật mã hạt nhân API hiển thị trong không gian hạt nhân là đầy đủ
cũng có thể áp dụng cho giao diện không gian người dùng. Vì vậy, hạt nhân
áp dụng thảo luận cấp cao về crypto API cho các trường hợp sử dụng trong kernel
ở đây cũng vậy.

Tuy nhiên, sự khác biệt chính là không gian người dùng chỉ có thể hoạt động như một
người tiêu dùng và không bao giờ là nhà cung cấp dịch vụ chuyển đổi hoặc mật mã
thuật toán.

Phần sau đây bao gồm giao diện không gian người dùng được kernel xuất
tiền điện tử API. Một ví dụ hoạt động của mô tả này là libkcapi có thể
được lấy từ [1]. Thư viện đó có thể được sử dụng bởi không gian người dùng
các ứng dụng yêu cầu dịch vụ mật mã từ kernel.

Một số chi tiết về khía cạnh API của mật mã hạt nhân trong nhân không áp dụng cho
không gian người dùng, tuy nhiên. Điều này bao gồm sự khác biệt giữa đồng bộ
và các lời gọi không đồng bộ. Không gian người dùng Cuộc gọi API đã hoàn tất
đồng bộ.

[1] ZZ0000ZZ

Không gian người dùng API Lưu ý chung
-------------------------------------

Mật mã hạt nhân API có thể truy cập được từ không gian người dùng. Hiện nay,
mật mã sau đây có thể truy cập được:

- Thông báo thông báo bao gồm thông báo thông báo có khóa (HMAC, CMAC)

- Mật mã đối xứng

- Mật mã AEAD

- Trình tạo số ngẫu nhiên

Giao diện được cung cấp thông qua loại ổ cắm sử dụng loại AF_ALG. trong
Ngoài ra, loại tùy chọn setsockopt là SOL_ALG. Trong trường hợp không gian người dùng
các tệp tiêu đề chưa xuất các cờ này, hãy sử dụng các macro sau:

::

#ifndef AF_ALG
    #define AF_ALG 38
    #endif
    #ifndef SOL_ALG
    #define SOL_ALG 279
    #endif


Một mật mã được truy cập với cùng tên như được thực hiện cho API trong kernel
cuộc gọi. Điều này bao gồm lược đồ đặt tên chung và duy nhất cho mật mã như
cũng như việc thực thi các ưu tiên cho tên chung.

Để tương tác với kernel crypto API, một socket phải được tạo bởi
ứng dụng không gian người dùng. Không gian người dùng gọi thao tác mã hóa bằng
nhóm lệnh gọi hệ thống send()/write(). Kết quả của phép toán mã hóa là
thu được bằng dòng lệnh gọi hệ thống read()/recv().

Các cuộc gọi API sau đây giả định rằng bộ mô tả ổ cắm đã được
được mở bởi ứng dụng không gian người dùng và chỉ thảo luận về kernel
các lời gọi cụ thể của crypto API.

Để khởi tạo giao diện socket, trình tự sau phải được thực hiện
được thực hiện bởi người tiêu dùng:

1. Tạo một socket kiểu AF_ALG với struct sockaddr_alg
   tham số được chỉ định bên dưới cho các loại mật mã khác nhau.

2. Gọi liên kết với bộ mô tả socket

3. Gọi chấp nhận bằng bộ mô tả socket. Cuộc gọi hệ thống chấp nhận
   trả về một bộ mô tả tệp mới được sử dụng để tương tác với
   trường hợp mật mã cụ thể. Khi gọi gửi/ghi hoặc recv/đọc
   lệnh gọi hệ thống để gửi dữ liệu tới kernel hoặc lấy dữ liệu từ
   kernel, bộ mô tả tập tin được trả về bằng cách chấp nhận phải được sử dụng.

Hoạt động mật mã tại chỗ
-------------------------

Giống như hoạt động trong kernel của mật mã kernel API, người dùng
Giao diện không gian cho phép thực hiện mật mã tại chỗ. Điều đó có nghĩa là
bộ đệm đầu vào được sử dụng cho lệnh gọi hệ thống gửi/ghi và đầu ra
bộ đệm được sử dụng bởi lệnh gọi hệ thống đọc/recv có thể giống nhau. Cái này
được đặc biệt quan tâm đối với các hoạt động mã hóa đối xứng trong đó
Có thể tránh được việc sao chép dữ liệu đầu ra đến đích cuối cùng.

Mặt khác, nếu người tiêu dùng muốn duy trì bản rõ và
bản mã ở các vị trí bộ nhớ khác nhau, tất cả những gì người dùng cần làm là
để cung cấp các con trỏ bộ nhớ khác nhau cho việc mã hóa và giải mã
hoạt động.

Thông báo tóm tắt API
---------------------

Kiểu tóm tắt thông điệp được sử dụng cho hoạt động mã hóa đã được chọn
khi gọi syscall liên kết. bind yêu cầu người gọi cung cấp một
cấu trúc dữ liệu struct sockaddr được điền đầy đủ. Cấu trúc dữ liệu này phải
điền như sau:

::

struct sockaddr_alg sa = {
        .salg_family = AF_ALG,
        .salg_type = "hash", /* cái này chọn logic băm trong kernel */
        .salg_name = "sha1" /* đây là tên mật mã */
    };


Giá trị "băm" salg_type áp dụng cho thông báo tóm tắt và thông báo có khóa
tiêu hóa. Mặc dù vậy, bản tóm tắt thông báo có khóa được tham chiếu bằng cách thích hợp
salg_name. Vui lòng xem bên dưới để biết giao diện setsockopt giải thích
cách đặt khóa cho bản tóm tắt thông báo có khóa.

Bằng cách sử dụng lệnh gọi hệ thống send(), ứng dụng sẽ cung cấp dữ liệu
nên được xử lý bằng thông báo tóm tắt. Cuộc gọi hệ thống gửi cho phép
các cờ sau đây cần được chỉ định:

- MSG_MORE: Nếu cờ này được đặt, lệnh gọi hệ thống gửi sẽ hoạt động giống như một
   chức năng cập nhật thông báo trong đó chưa có hàm băm cuối cùng
   tính toán. Nếu cờ không được đặt, lệnh gọi hệ thống gửi sẽ tính toán
   thông báo cuối cùng được tóm tắt ngay lập tức.

Với lệnh gọi hệ thống recv(), ứng dụng có thể đọc bản tóm tắt thông báo
từ mật mã hạt nhân API. Nếu bộ đệm quá nhỏ cho tin nhắn
thông báo, cờ MSG_TRUNC được đặt bởi kernel.

Để đặt khóa tóm tắt tin nhắn, ứng dụng gọi điện phải sử dụng
tùy chọn setsockopt() của ALG_SET_KEY hoặc ALG_SET_KEY_BY_KEY_SERIAL. Nếu
phím không được đặt, thao tác HMAC được thực hiện mà không có trạng thái HMAC ban đầu
thay đổi do chìa khóa gây ra.

Mật mã đối xứng API
--------------------

Hoạt động này rất giống với cuộc thảo luận về thông báo tóm tắt. Trong thời gian
khởi tạo, cấu trúc dữ liệu struct sockaddr phải được điền như
sau:

::

struct sockaddr_alg sa = {
        .salg_family = AF_ALG,
        .salg_type = "skcipher", /* cái này chọn mật mã đối xứng */
        .salg_name = "cbc(aes)" /* đây là tên mật mã */
    };


Trước khi dữ liệu có thể được gửi đến kernel bằng lệnh gọi hệ thống ghi/gửi
gia đình, người tiêu dùng phải đặt chìa khóa. Cài đặt phím được mô tả bằng
lệnh gọi setsockopt bên dưới.

Bằng cách sử dụng lệnh gọi hệ thống sendmsg(), ứng dụng sẽ cung cấp dữ liệu
cần được xử lý để mã hóa hoặc giải mã. Ngoài ra, IV còn
được chỉ định bằng cấu trúc dữ liệu được cung cấp bởi lệnh gọi hệ thống sendmsg().

Tham số cuộc gọi hệ thống sendmsg của struct msghdr được nhúng vào
cấu trúc dữ liệu cmsghdr. Xem recv(2) và cmsg(3) để biết thêm
thông tin về cách sử dụng cấu trúc dữ liệu cmsghdr cùng với
nhóm cuộc gọi hệ thống gửi/recv. Cấu trúc dữ liệu cmsghdr đó chứa
thông tin sau được chỉ định bằng một phiên bản tiêu đề riêng biệt:

- đặc điểm kỹ thuật của loại hoạt động mật mã với một trong các cờ sau:

- ALG_OP_ENCRYPT - mã hóa dữ liệu

- ALG_OP_DECRYPT - giải mã dữ liệu

- đặc điểm kỹ thuật của thông tin IV được đánh dấu bằng cờ ALG_SET_IV

Họ cuộc gọi hệ thống gửi cho phép chỉ định cờ sau:

- MSG_MORE: Nếu cờ này được đặt, lệnh gọi hệ thống gửi sẽ hoạt động giống như một
   chức năng cập nhật mật mã trong đó dự kiến sẽ có nhiều dữ liệu đầu vào hơn với
   việc gọi tiếp theo của cuộc gọi hệ thống gửi.

Lưu ý: Kernel báo cáo -EINVAL về bất kỳ dữ liệu không mong muốn nào. người gọi
phải đảm bảo rằng tất cả dữ liệu phù hợp với các ràng buộc được đưa ra trong
/proc/crypto cho mật mã đã chọn.

Với lệnh gọi hệ thống recv(), ứng dụng có thể đọc kết quả của
hoạt động mã hóa từ hạt nhân mật mã API. Bộ đệm đầu ra phải là
ít nhất là lớn để chứa tất cả các khối được mã hóa hoặc giải mã
dữ liệu. Nếu kích thước dữ liệu đầu ra nhỏ hơn thì chỉ có bao nhiêu khối được
được trả về phù hợp với kích thước bộ đệm đầu ra đó.

Mật mã AEAD API
---------------

Hoạt động này rất giống với thảo luận về mật mã đối xứng. Trong thời gian
khởi tạo, cấu trúc dữ liệu struct sockaddr phải được điền như
sau:

::

struct sockaddr_alg sa = {
        .salg_family = AF_ALG,
        .salg_type = "aead", /* cái này chọn mật mã đối xứng */
        .salg_name = "gcm(aes)" /* đây là tên mật mã */
    };


Trước khi dữ liệu có thể được gửi đến kernel bằng lệnh gọi hệ thống ghi/gửi
gia đình, người tiêu dùng phải đặt chìa khóa. Cài đặt phím được mô tả bằng
lệnh gọi setsockopt bên dưới.

Ngoài ra, trước khi dữ liệu có thể được gửi đến kernel bằng lệnh ghi/gửi
họ cuộc gọi hệ thống, người tiêu dùng phải đặt kích thước thẻ xác thực.
Để đặt kích thước thẻ xác thực, người gọi phải sử dụng setsockopt
lời gọi được mô tả dưới đây.

Bằng cách sử dụng lệnh gọi hệ thống sendmsg(), ứng dụng sẽ cung cấp dữ liệu
cần được xử lý để mã hóa hoặc giải mã. Ngoài ra, IV còn
được chỉ định bằng cấu trúc dữ liệu được cung cấp bởi lệnh gọi hệ thống sendmsg().

Tham số cuộc gọi hệ thống sendmsg của struct msghdr được nhúng vào
cấu trúc dữ liệu cmsghdr. Xem recv(2) và cmsg(3) để biết thêm
thông tin về cách sử dụng cấu trúc dữ liệu cmsghdr cùng với
nhóm cuộc gọi hệ thống gửi/recv. Cấu trúc dữ liệu cmsghdr đó chứa
thông tin sau được chỉ định bằng một phiên bản tiêu đề riêng biệt:

- đặc điểm kỹ thuật của loại hoạt động mật mã với một trong các cờ sau:

- ALG_OP_ENCRYPT - mã hóa dữ liệu

- ALG_OP_DECRYPT - giải mã dữ liệu

- đặc điểm kỹ thuật của thông tin IV được đánh dấu bằng cờ ALG_SET_IV

- đặc điểm kỹ thuật của dữ liệu xác thực liên quan (AAD) với
   cờ ALG_SET_AEAD_ASSOCLEN. AAD được gửi đến kernel cùng nhau
   với bản rõ/bản mã. Xem bên dưới để biết cấu trúc bộ nhớ.

Họ cuộc gọi hệ thống gửi cho phép chỉ định cờ sau:

- MSG_MORE: Nếu cờ này được đặt, lệnh gọi hệ thống gửi sẽ hoạt động giống như một
   chức năng cập nhật mật mã trong đó dự kiến sẽ có nhiều dữ liệu đầu vào hơn với
   việc gọi tiếp theo của cuộc gọi hệ thống gửi.

Lưu ý: Kernel báo cáo -EINVAL về bất kỳ dữ liệu không mong muốn nào. người gọi
phải đảm bảo rằng tất cả dữ liệu phù hợp với các ràng buộc được đưa ra trong
/proc/crypto cho mật mã đã chọn.

Với lệnh gọi hệ thống recv(), ứng dụng có thể đọc kết quả của
hoạt động mã hóa từ hạt nhân mật mã API. Bộ đệm đầu ra phải là
ít nhất là lớn như được xác định với cấu trúc bộ nhớ bên dưới. Nếu
kích thước dữ liệu đầu ra nhỏ hơn, thao tác mã hóa không được thực hiện.

Hoạt động giải mã được xác thực có thể chỉ ra lỗi toàn vẹn.
Sự vi phạm tính toàn vẹn như vậy được đánh dấu bằng mã lỗi -EBADMSG.

Cấu trúc bộ nhớ AEAD
~~~~~~~~~~~~~~~~~~~~~

Mật mã AEAD hoạt động với thông tin sau:
được giao tiếp giữa người dùng và không gian kernel dưới dạng một luồng dữ liệu:

- bản rõ hoặc bản mã

- dữ liệu xác thực liên quan (AAD)

- thẻ xác thực

Kích thước của AAD và thẻ xác thực được cung cấp cùng với
các cuộc gọi sendmsg và setsockopt (xem ở đó). Khi kernel biết kích thước
của toàn bộ luồng dữ liệu, kernel bây giờ có thể tính toán đúng
độ lệch của các thành phần dữ liệu trong luồng dữ liệu.

Người gọi không gian người dùng phải sắp xếp các thông tin nói trên trong
thứ tự sau:

- Đầu vào mã hóa AEAD: bản rõ AAD \ZZ0000ZZ

- Đầu vào giải mã AEAD: AAD \ZZ0000ZZ bản mã \ZZ0001ZZ thẻ xác thực

Bộ đệm đầu ra mà người gọi không gian người dùng cung cấp ít nhất phải bằng
lớn để chứa dữ liệu sau:

- Đầu ra mã hóa AEAD: thẻ xác thực ciphertext \ZZ0000ZZ

- Đầu ra giải mã AEAD: bản rõ

Trình tạo số ngẫu nhiên API
---------------------------

Một lần nữa, hoạt động rất giống với các API khác. Trong thời gian
khởi tạo, cấu trúc dữ liệu struct sockaddr phải được điền như
sau:

::

struct sockaddr_alg sa = {
        .salg_family = AF_ALG,
        .salg_type = "rng", /* cái này chọn trình tạo số ngẫu nhiên */
        .salg_name = "drbg_nopr_sha256" /* đây là tên RNG */
    };


Tùy thuộc vào loại RNG, RNG phải được gieo hạt. Hạt giống được cung cấp
sử dụng giao diện setsockopt để đặt khóa. SP800-90A DRBG làm được
không cần hạt giống nhưng có thể gieo hạt. Hạt còn được gọi là
ZZ0000ZZ theo tiêu chuẩn NIST SP 800-90A.

Bằng cách sử dụng các lệnh gọi hệ thống read()/recvmsg(), có thể thu được các số ngẫu nhiên.
Hạt nhân tạo ra tối đa 128 byte trong một cuộc gọi. Nếu không gian người dùng
cần nhiều dữ liệu hơn, phải thực hiện nhiều lệnh gọi tới read()/recvmsg().

WARNING: Người gọi không gian người dùng có thể gọi chấp nhận được đề cập ban đầu
gọi hệ thống nhiều lần. Trong trường hợp này, các bộ mô tả tập tin được trả về
có cùng trạng thái.

Các giao diện kiểm tra CAVP sau đây được bật khi kernel được xây dựng bằng
Tùy chọn CRYPTO_USER_API_RNG_CAVP:

- sự kết hợp của ZZ0000ZZ và ZZ0001ZZ có thể được cung cấp cho RNG thông qua
   ALG_SET_DRBG_ENTROPY thiết lập giao diện sockopt. Việc thiết lập entropy yêu cầu
   Quyền CAP_SYS_ADMIN.

- ZZ0000ZZ có thể được cung cấp bằng cách sử dụng lệnh gọi hệ thống send()/sendmsg(),
   nhưng chỉ sau khi entropy đã được thiết lập.

Giao diện không sao chép
------------------------

Ngoài dòng lệnh gọi hệ thống gửi/ghi/đọc/recv, AF_ALG
giao diện có thể được truy cập với giao diện không sao chép của
mối nối/vmsplice. Như tên đã chỉ ra, kernel cố gắng tránh việc sao chép
hoạt động vào không gian kernel.

Thao tác không sao chép yêu cầu dữ liệu phải được căn chỉnh tại trang
ranh giới. Dữ liệu không liên kết cũng có thể được sử dụng nhưng có thể yêu cầu nhiều hơn
các hoạt động của hạt nhân sẽ đánh bại tốc độ đạt được
từ giao diện không sao chép.

Giới hạn vốn có của hệ thống đối với kích thước của một thao tác không sao chép là 16
trang. Nếu có thêm dữ liệu được gửi tới AF_ALG, không gian người dùng phải cắt
nhập vào các phân đoạn có kích thước tối đa là 16 trang.

Không sao chép có thể được sử dụng với ví dụ mã sau (một bản hoàn chỉnh
ví dụ hoạt động được cung cấp với libkcapi):

::

ống int[2];

ống(ống);
    /*nhập dữ liệu vào iov*/
    vmsplice(pipes[1], iov, iovlen, SPLICE_F_GIFT);
    /* opfd là bộ mô tả tệp được trả về từ lệnh gọi hệ thống Accept() */
    mối nối(ống[0], NULL, opfd, NULL, ret, 0);
    đọc(opfd, out, outlen);


Giao diện Setsockopt
--------------------

Ngoài việc xử lý cuộc gọi hệ thống đọc/recv và gửi/ghi để gửi
và truy xuất dữ liệu theo hoạt động mã hóa, người tiêu dùng cũng cần
để thiết lập thông tin bổ sung cho hoạt động mã hóa. Cái này
thông tin bổ sung được thiết lập bằng lệnh gọi hệ thống setsockopt phải
được gọi bằng bộ mô tả tệp của mật mã mở (tức là tệp
mô tả được trả về bởi lệnh gọi hệ thống chấp nhận).

Mỗi lệnh gọi setsockopt phải sử dụng cấp độ SOL_ALG.

Giao diện setsockopt cho phép thiết lập dữ liệu sau bằng cách sử dụng
tên optname đã đề cập:

- ALG_SET_KEY -- Cài đặt phím. Cài đặt chính được áp dụng cho:

- loại mật mã skcipher (mật mã đối xứng)

- loại mật mã băm (bản tóm tắt thông điệp có khóa)

- loại mật mã AEAD

- loại mật mã RNG để cung cấp hạt giống

- ALG_SET_KEY_BY_KEY_SERIAL -- Đặt khóa thông qua keyring key_serial_t.
   Hoạt động này hoạt động giống như ALG_SET_KEY. Đã giải mã
   dữ liệu được sao chép từ một phím bấm và sử dụng dữ liệu đó làm
   khóa để mã hóa đối xứng.

Phần được truyền trong key_serial_t phải có KEY_(POSZZ0000ZZGRP|OTH)_SEARCH
   được đặt quyền, nếu không -EPERM sẽ được trả về. Hỗ trợ các loại khóa: người dùng,
   đăng nhập, mã hóa và đáng tin cậy.

- ALG_SET_AEAD_AUTHSIZE -- Đặt kích thước thẻ xác thực cho
   Mật mã AEAD. Đối với hoạt động mã hóa, thẻ xác thực của
   kích thước nhất định sẽ được tạo ra. Đối với hoạt động giải mã,
   với điều kiện là bản mã được giả định chứa thẻ xác thực của
   kích thước nhất định (xem phần về bố cục bộ nhớ AEAD bên dưới).

- ALG_SET_DRBG_ENTROPY -- Đặt entropy của bộ tạo số ngẫu nhiên.
   Tùy chọn này chỉ áp dụng cho loại mật mã RNG.

Ví dụ về không gian người dùng API
----------------------------------

Vui lòng xem [1] để biết libkcapi cung cấp trình bao bọc dễ sử dụng xung quanh
giao diện hạt nhân Netlink đã nói ở trên. [1] cũng chứa một bài kiểm tra
ứng dụng gọi tất cả các lệnh gọi libkcapi API.

[1] ZZ0000ZZ
