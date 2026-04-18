.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/inline-encryption.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _inline_encryption:

===================
Mã hóa nội tuyến
===================

Lý lịch
==========

Phần cứng mã hóa nội tuyến nằm một cách hợp lý giữa bộ nhớ và ổ đĩa và có thể
en/giải mã dữ liệu khi nó vào/ra khỏi đĩa.  Đối với mỗi yêu cầu I/O, phần mềm
có thể kiểm soát chính xác cách phần cứng mã hóa nội tuyến sẽ mã hóa/giải mã dữ liệu
về khóa, thuật toán, kích thước đơn vị dữ liệu (độ chi tiết của mã hóa/giải mã),
và số đơn vị dữ liệu (một giá trị xác định (các) vectơ khởi tạo).

Một số phần cứng mã hóa nội tuyến chấp nhận tất cả các tham số mã hóa bao gồm cả dữ liệu thô
các phím trực tiếp trong các yêu cầu I/O cấp thấp.  Tuy nhiên, hầu hết mã hóa nội tuyến
thay vào đó, phần cứng có số lượng "khe khóa" cố định và yêu cầu khóa đó,
thuật toán và kích thước đơn vị dữ liệu trước tiên được lập trình vào một khe khóa.  Mỗi
yêu cầu I/O cấp thấp sau đó chỉ chứa chỉ mục khe khóa và số đơn vị dữ liệu.

Lưu ý rằng phần cứng mã hóa nội tuyến rất khác so với phần cứng mã hóa truyền thống
bộ tăng tốc, được hỗ trợ thông qua mật mã hạt nhân API.  truyền thống
bộ tăng tốc mật mã hoạt động trên các vùng bộ nhớ, trong khi mã hóa nội tuyến
phần cứng hoạt động theo yêu cầu I/O.  Vì vậy, phần cứng mã hóa nội tuyến cần phải được
được quản lý bởi lớp khối, không phải mật mã hạt nhân API.

Phần cứng mã hóa nội tuyến cũng rất khác với "ổ đĩa tự mã hóa",
chẳng hạn như những sản phẩm dựa trên tiêu chuẩn TCG Opal hoặc ATA Security.  Tự mã hóa
ổ đĩa không cung cấp khả năng kiểm soát mã hóa chi tiết và không cung cấp cách nào để
kiểm tra tính đúng đắn của bản mã thu được.  Phần cứng mã hóa nội tuyến
cung cấp khả năng kiểm soát mã hóa chi tiết, bao gồm cả việc lựa chọn khóa và
vectơ khởi tạo cho từng khu vực và có thể được kiểm tra tính chính xác.

Khách quan
=========

Chúng tôi muốn hỗ trợ mã hóa nội tuyến trong kernel.  Để làm cho việc kiểm tra dễ dàng hơn, chúng tôi
cũng muốn hỗ trợ quay trở lại kernel crypto API khi thực tế nội tuyến
phần cứng mã hóa không có.  Chúng tôi cũng muốn mã hóa nội tuyến hoạt động với
các thiết bị phân lớp như trình ánh xạ thiết bị và loopback (tức là chúng tôi muốn có thể sử dụng
phần cứng mã hóa nội tuyến của các thiết bị cơ bản nếu có, nếu không thì
quay trở lại mật mã API en/giải mã).

Những hạn chế và ghi chú
=====================

- Chúng tôi cần một cách để các lớp trên (ví dụ: hệ thống tệp) chỉ định mã hóa
  ngữ cảnh sử dụng để en/giải mã tiểu sử và trình điều khiển thiết bị (ví dụ: UFSHCD) cần
  để có thể sử dụng bối cảnh mã hóa đó khi họ xử lý yêu cầu.
  Bối cảnh mã hóa cũng đưa ra các hạn chế đối với việc hợp nhất sinh học; lớp khối
  cần phải nhận thức được những hạn chế này.

- Phần cứng mã hóa nội tuyến khác nhau có các thuật toán được hỗ trợ khác nhau,
  kích thước đơn vị dữ liệu được hỗ trợ, số đơn vị dữ liệu tối đa, v.v. Chúng tôi gọi đây là
  thuộc tính "khả năng mã hóa".  Chúng tôi cần một cách để trình điều khiển thiết bị
  quảng cáo khả năng của tiền điện tử lên các lớp trên một cách chung chung.

- Phần cứng mã hóa nội tuyến thường (nhưng không phải luôn luôn) yêu cầu các khóa đó phải được
  được lập trình vào các khe khóa trước khi sử dụng.  Vì các khe phím lập trình có thể
  chậm và có thể không có nhiều khe phím, chúng ta không nên chỉ lập trình
  khóa cho mọi yêu cầu I/O mà thay vào đó hãy theo dõi xem khóa nào nằm trong
  các khe khóa và sử dụng lại khe khóa đã được lập trình sẵn khi có thể.

- Các lớp trên thường xác định thời hạn sử dụng cụ thể cho khóa mật mã, ví dụ:
  khi một thư mục được mã hóa bị khóa hoặc khi ánh xạ mật mã bị phá bỏ.
  Vào những thời điểm này, các phím sẽ bị xóa khỏi bộ nhớ.  Chúng ta phải cung cấp một con đường cho phía trên
  các lớp cũng có thể loại bỏ các khóa khỏi bất kỳ khe khóa nào mà chúng có trong đó.

- Khi có thể, các thiết bị ánh xạ thiết bị phải có khả năng đi qua nội tuyến
  hỗ trợ mã hóa của các thiết bị cơ bản của họ.  Tuy nhiên, nó không làm
  ý nghĩa đối với các thiết bị ánh xạ thiết bị có khe khóa.

Thiết kế cơ bản
============

Chúng tôi giới thiệu ZZ0000ZZ để thể hiện khóa mã hóa nội tuyến và
nó sẽ được sử dụng như thế nào.  Điều này bao gồm loại khóa (thô hoặc
được bọc phần cứng); các byte thực tế của khóa; kích thước của chìa khóa; cái
thuật toán và kích thước đơn vị dữ liệu mà khóa sẽ được sử dụng; và số byte
cần thiết để thể hiện số đơn vị dữ liệu tối đa mà khóa sẽ được sử dụng.

Chúng tôi giới thiệu ZZ0000ZZ để thể hiện bối cảnh mã hóa.  Nó
chứa số đơn vị dữ liệu và một con trỏ tới blk_crypto_key.  Chúng tôi thêm con trỏ
tới bio_crypt_ctx thành ZZ0001ZZ và ZZ0002ZZ; điều này cho phép người dùng
của lớp khối (ví dụ: hệ thống tập tin) để cung cấp bối cảnh mã hóa khi
tạo tiểu sử và chuyển nó xuống ngăn xếp để khối xử lý
layer and device drivers.  Lưu ý rằng bối cảnh mã hóa không rõ ràng
cho biết nên mã hóa hay giải mã, vì điều đó được ngầm định theo hướng của
sinh học; WRITE có nghĩa là mã hóa và READ có nghĩa là giải mã.

Chúng tôi cũng giới thiệu ZZ0000ZZ để chứa tất cả nội tuyến chung
trạng thái liên quan đến mã hóa cho một thiết bị mã hóa nội tuyến cụ thể.  các
blk_crypto_profile đóng vai trò là cách trình điều khiển cho phần cứng mã hóa nội tuyến
quảng cáo khả năng mã hóa của họ và cung cấp các chức năng nhất định (ví dụ:
chức năng lập trình và đẩy phím) lên các lớp trên.  Mỗi trình điều khiển thiết bị đó
muốn hỗ trợ mã hóa nội tuyến sẽ xây dựng một blk_crypto_profile, sau đó
liên kết nó với request_queue của đĩa.

blk_crypto_profile cũng quản lý các khe khóa của phần cứng, nếu có.
Điều này xảy ra trong lớp khối, do đó người dùng lớp khối có thể chỉ
chỉ định bối cảnh mã hóa và không cần biết về các khe khóa cũng như không
Trình điều khiển thiết bị cần quan tâm đến hầu hết các chi tiết về quản lý khe phím.

Cụ thể, đối với mỗi khe khóa, lớp khối (thông qua blk_crypto_profile)
theo dõi blk_crypto_key nào chứa keylot (nếu có) và bao nhiêu
các yêu cầu I/O đang hoạt động đang sử dụng nó.  Khi lớp khối tạo ra một
ZZ0000ZZ cho một tiểu sử có ngữ cảnh mã hóa, nó lấy một khe khóa
đã chứa khóa nếu có thể.  Nếu không thì nó sẽ chờ ở trạng thái rảnh
khe khóa (khe khóa không được sử dụng bởi bất kỳ I/O nào), sau đó lập trình khóa vào
khe phím nhàn rỗi ít được sử dụng gần đây nhất bằng cách sử dụng chức năng mà trình điều khiển thiết bị cung cấp.
Trong cả hai trường hợp, khe khóa kết quả được lưu trữ trong trường ZZ0001ZZ của
yêu cầu, tại đó trình điều khiển thiết bị có thể truy cập được và được giải phóng sau
yêu cầu hoàn tất.

ZZ0000ZZ cũng chứa một con trỏ tới bio_crypt_ctx gốc.
Các yêu cầu có thể được xây dựng từ nhiều bios và lớp khối phải đảm nhận
bối cảnh mã hóa được tính đến khi cố gắng hợp nhất bios và yêu cầu.  Cho hai người
bios/yêu cầu được hợp nhất, chúng phải có bối cảnh mã hóa tương thích: cả hai
không được mã hóa hoặc cả hai được mã hóa bằng cùng một khóa và đơn vị dữ liệu liền kề
những con số.  Chỉ bối cảnh mã hóa cho tiểu sử đầu tiên trong yêu cầu mới được
được giữ lại vì bios còn lại đã được xác minh là tương thích với việc hợp nhất
với sinh học đầu tiên.

Để mã hóa nội tuyến có thể hoạt động dựa trên request_queue
các thiết bị phân lớp, khi một yêu cầu được sao chép, bối cảnh mã hóa của nó sẽ được sao chép dưới dạng
tốt.  Khi yêu cầu nhân bản được gửi, nó sẽ được xử lý như bình thường; cái này
bao gồm việc lấy một khe khóa từ thiết bị mục tiêu của bản sao nếu cần.

blk-crypto-dự phòng
===================

Điều mong muốn là hỗ trợ mã hóa nội tuyến của các lớp trên (ví dụ:
hệ thống tập tin) có thể kiểm tra được mà không cần phần cứng mã hóa nội tuyến thực sự và
tương tự như vậy đối với logic quản lý khe khóa của lớp khối.  Đó cũng là mong muốn
để cho phép các lớp trên luôn sử dụng mã hóa nội tuyến thay vì phải
thực hiện mã hóa theo nhiều cách.

Vì vậy, chúng tôi cũng giới thiệu ZZ0000ZZ, đây là một triển khai
mã hóa nội tuyến bằng cách sử dụng mật mã hạt nhân API.  blk-crypto-dự phòng được xây dựng
vào lớp khối, do đó nó hoạt động trên mọi thiết bị khối mà không cần bất kỳ thiết lập đặc biệt nào.
Về cơ bản, khi tiểu sử có bối cảnh mã hóa được gửi tới
block_device không hỗ trợ bối cảnh mã hóa đó, lớp khối sẽ
xử lý en/giải mã sinh học bằng cách sử dụng blk-crypto-fallback.

Để mã hóa, dữ liệu không thể được mã hóa tại chỗ vì người gọi thường dựa vào
trên đó không được sửa đổi.  Thay vào đó, blk-crypto-fallback phân bổ các trang bị trả lại,
điền vào tiểu sử mới với các trang bị trả lại đó, mã hóa dữ liệu vào các trang bị trả lại đó
các trang và gửi tiểu sử "trả lại" đó.  Khi sinh học thoát hoàn tất,
blk-crypto-fallback hoàn thành tiểu sử gốc.  Nếu tiểu sử ban đầu quá
có thể cần có bios lớn, nhiều lần thoát; xem mã để biết chi tiết.

Để giải mã, blk-crypto-fallback "kết thúc" lệnh gọi lại hoàn thành của tiểu sử
(ZZ0000ZZ) và dữ liệu riêng tư (ZZ0001ZZ) bằng dữ liệu riêng của nó, hủy cài đặt
bối cảnh mã hóa của bio, sau đó gửi bio.  Nếu quá trình đọc hoàn tất
thành công, blk-crypto-fallback khôi phục hoàn thành ban đầu của tiểu sử
gọi lại và dữ liệu riêng tư, sau đó giải mã dữ liệu sinh học tại chỗ bằng cách sử dụng
mật mã hạt nhân API.  Quá trình giải mã diễn ra từ hàng đợi công việc vì nó có thể ở chế độ ngủ.
Sau đó, blk-crypto-fallback hoàn thành tiểu sử.

Trong cả hai trường hợp, bios mà blk-crypto-fallback gửi không còn có
bối cảnh mã hóa.  Do đó, các lớp thấp hơn chỉ nhìn thấy I/O không được mã hóa tiêu chuẩn.

blk-crypto-fallback cũng xác định blk_crypto_profile của riêng nó và có riêng
"khe khóa"; các khe khóa của nó chứa các đối tượng ZZ0000ZZ.  Lý do
vì điều này có hai mặt.  Đầu tiên, nó cho phép thử nghiệm logic quản lý khe khóa
không có phần cứng mã hóa nội tuyến thực tế.  Thứ hai, tương tự như nội tuyến thực tế
phần cứng mã hóa, mật mã API không chấp nhận khóa trực tiếp trong các yêu cầu nhưng
đúng hơn là yêu cầu các phím phải được đặt trước và các phím cài đặt có thể được
đắt tiền; hơn nữa, việc phân bổ crypto_skcipher không thể xảy ra trên đường dẫn I/O
tất cả là do ổ khóa mà nó cần.  Vì vậy, khái niệm về khe khóa vẫn còn
có ý nghĩa đối với dự phòng blk-crypto.

Lưu ý rằng bất kể phần cứng mã hóa nội tuyến thực hay
blk-crypto-fallback được sử dụng, văn bản mã hóa được ghi vào đĩa (và do đó
định dạng dữ liệu trên đĩa) sẽ giống nhau (giả sử rằng cả nội tuyến
triển khai phần cứng mã hóa và triển khai mật mã hạt nhân API
của thuật toán đang được sử dụng tuân thủ thông số kỹ thuật và hoạt động chính xác).

blk-crypto-fallback là tùy chọn và được kiểm soát bởi
Tùy chọn cấu hình kernel ZZ0000ZZ.

API được giới thiệu tới người dùng lớp khối
=========================================

ZZ0000ZZ cho phép người dùng kiểm tra trước xem
mã hóa nội tuyến với cài đặt mật mã cụ thể sẽ hoạt động trên một thiết bị cụ thể
block_device -- thông qua phần cứng hoặc thông qua blk-crypto-fallback.  Chức năng này
lấy ZZ0001ZZ giống như blk_crypto_key, nhưng bỏ qua
byte thực tế của khóa và thay vào đó chỉ chứa thuật toán, đơn vị dữ liệu
kích thước, v.v. Chức năng này có thể hữu ích nếu blk-crypto-fallback bị tắt.

ZZ0000ZZ cho phép người dùng khởi tạo blk_crypto_key.

Người dùng phải gọi ZZ0000ZZ trước khi thực sự bắt đầu sử dụng
blk_crypto_key trên block_device (ngay cả khi ZZ0001ZZ
được gọi trước đó).  Điều này là cần thiết để khởi tạo blk-crypto-fallback nếu nó
sẽ cần thiết.  Điều này không được gọi từ đường dẫn dữ liệu, vì điều này có thể phải
phân bổ tài nguyên, có thể bế tắc trong trường hợp đó.

Tiếp theo, để đính kèm bối cảnh mã hóa vào tiểu sử, người dùng nên gọi
ZZ0000ZZ.  Hàm này phân bổ bio_crypt_ctx và đính kèm
nó vào tiểu sử, được cung cấp blk_crypto_key và số đơn vị dữ liệu sẽ được sử dụng
để giải mã en/.  Người dùng không cần lo lắng về việc giải phóng bio_crypt_ctx
sau đó, vì điều đó sẽ tự động xảy ra khi tiểu sử được giải phóng hoặc đặt lại.

Để gửi tiểu sử sử dụng mã hóa nội tuyến, người dùng phải gọi
ZZ0000ZZ thay vì ZZ0001ZZ thông thường.  Điều này sẽ
gửi tiểu sử cho trình điều khiển cơ bản nếu nó hỗ trợ tiền điện tử nội tuyến, nếu không
gọi các quy trình dự phòng blk-crypto trước khi gửi bios bình thường tới
trình điều khiển cơ bản.

Cuối cùng, khi hoàn tất việc sử dụng mã hóa nội tuyến bằng blk_crypto_key trên
block_device, người dùng phải gọi ZZ0000ZZ.  Điều này đảm bảo rằng
chìa khóa bị loại khỏi tất cả các khe khóa mà nó có thể được lập trình vào và hủy liên kết khỏi
bất kỳ cấu trúc dữ liệu hạt nhân nào mà nó có thể được liên kết vào.

Tóm lại, đối với người dùng lớp khối, vòng đời của blk_crypto_key là
như sau:

1. ZZ0000ZZ (tùy chọn)
2. ZZ0001ZZ
3. ZZ0002ZZ
4. ZZ0003ZZ (có thể nhiều lần)
5. ZZ0004ZZ (sau khi tất cả I/O đã hoàn thành)
6. Zeroize blk_crypto_key (cái này không có chức năng chuyên dụng)

Nếu blk_crypto_key đang được sử dụng trên nhiều block_devices thì
ZZ0000ZZ (nếu được sử dụng), ZZ0001ZZ,
và ZZ0002ZZ phải được gọi trên mỗi block_device.

API được trình bày cho trình điều khiển thiết bị
===============================

Trình điều khiển thiết bị muốn hỗ trợ mã hóa nội tuyến phải thiết lập một
blk_crypto_profile in the request_queue of its device.  Để làm được điều này, trước hết
phải gọi ZZ0000ZZ (hoặc biến thể được quản lý tài nguyên của nó
ZZ0001ZZ), cung cấp số lượng khe khóa.

Tiếp theo, nó phải quảng cáo khả năng mã hóa của mình bằng cách đặt các trường trong
blk_crypto_profile, ví dụ: ZZ0000ZZ và ZZ0001ZZ.

Sau đó nó phải đặt các con trỏ hàm trong trường ZZ0000ZZ của
blk_crypto_profile để cho các lớp trên biết cách kiểm soát mã hóa nội tuyến
phần cứng, ví dụ: cách lập trình và loại bỏ các khe khóa.  Hầu hết người lái xe sẽ cần phải
triển khai ZZ0001ZZ và ZZ0002ZZ.  Để biết chi tiết, xem
ý kiến cho ZZ0003ZZ.

Khi trình điều khiển đăng ký blk_crypto_profile với request_queue, I/O
requests the driver receives via that queue may have an encryption context.  Tất cả
bối cảnh mã hóa sẽ tương thích với các khả năng mật mã được khai báo trong
blk_crypto_profile nên tài xế không cần lo lắng về việc xử lý
các yêu cầu không được hỗ trợ.  Ngoài ra, nếu số lượng khe khóa khác 0 được khai báo trong
blk_crypto_profile thì tất cả các yêu cầu I/O có ngữ cảnh mã hóa sẽ
cũng có một khe khóa đã được lập trình sẵn với chìa khóa thích hợp.

Nếu trình điều khiển thực hiện tạm dừng thời gian chạy và blk_crypto_ll_ops của nó không hoạt động
trong khi thiết bị bị treo thời gian chạy thì trình điều khiển cũng phải đặt ZZ0000ZZ
trường blk_crypto_profile để trỏ đến ZZ0001ZZ sẽ
được tiếp tục lại trước khi bất kỳ hoạt động cấp thấp nào được gọi.

Nếu có trường hợp phần cứng mã hóa nội tuyến mất nội dung
trong số các khe khóa của nó, ví dụ: thiết bị đặt lại, trình điều khiển phải xử lý việc lập trình lại thiết bị
keyslots.  Để thực hiện việc này, người lái xe có thể gọi ZZ0000ZZ.

Cuối cùng, nếu trình điều khiển sử dụng ZZ0000ZZ thay vì
ZZ0001ZZ thì nó có nhiệm vụ gọi
ZZ0002ZZ khi hồ sơ tiền điện tử không còn cần thiết nữa.

Thiết bị lớp
===============

Yêu cầu các thiết bị xếp lớp dựa trên hàng đợi như dm-rq muốn hỗ trợ nội tuyến
mã hóa cần tạo blk_crypto_profile của riêng họ cho request_queue của họ,
và hiển thị bất kỳ chức năng nào họ chọn. Khi một thiết bị lớp muốn
chuyển một bản sao của yêu cầu đó tới một request_queue khác, blk-crypto sẽ
khởi tạo và chuẩn bị bản sao khi cần thiết.

Tương tác giữa mã hóa nội tuyến và tính toàn vẹn blk
=======================================================

Tại thời điểm có bản vá này, không có phần cứng thực sự nào hỗ trợ cả hai điều này
tính năng. Tuy nhiên, các tính năng này có tương tác với nhau và không
hoàn toàn tầm thường để làm cho cả hai làm việc cùng nhau đúng cách. Đặc biệt,
khi tiểu sử WRITE muốn sử dụng mã hóa nội tuyến trên thiết bị hỗ trợ cả hai
các tính năng, tiểu sử sẽ có bối cảnh mã hóa được chỉ định, sau đó
thông tin toàn vẹn của nó được tính toán (sử dụng dữ liệu văn bản gốc, vì
quá trình mã hóa sẽ diễn ra trong khi dữ liệu được ghi) và dữ liệu cũng như
thông tin toàn vẹn được gửi đến thiết bị. Rõ ràng, thông tin về tính toàn vẹn phải được
được xác minh trước khi dữ liệu được mã hóa. Sau khi dữ liệu được mã hóa, thiết bị
không được lưu trữ thông tin toàn vẹn mà nó nhận được cùng với dữ liệu văn bản gốc
vì điều đó có thể tiết lộ thông tin về dữ liệu bản rõ. Như vậy, nó phải
tạo lại thông tin toàn vẹn từ dữ liệu bản mã và lưu trữ thông tin đó trên đĩa
thay vào đó. Một vấn đề khác với việc lưu trữ thông tin toàn vẹn của dữ liệu văn bản gốc là
rằng nó thay đổi định dạng trên đĩa tùy thuộc vào việc phần cứng nội tuyến có
hỗ trợ mã hóa hiện có hoặc dự phòng API của mật mã hạt nhân được sử dụng (vì
nếu dự phòng được sử dụng, thiết bị sẽ nhận được thông tin toàn vẹn của
bản mã chứ không phải bản rõ).

Vì chưa có phần cứng thực sự nào nên có vẻ thận trọng khi cho rằng
Việc triển khai phần cứng có thể không triển khai chính xác cả hai tính năng,
và không cho phép kết hợp bây giờ. Bất cứ khi nào một thiết bị hỗ trợ tính toàn vẹn,
kernel sẽ giả vờ rằng thiết bị không hỗ trợ mã hóa nội tuyến phần cứng
(bằng cách đặt blk_crypto_profile trong request_queue của thiết bị thành NULL).
Khi bật dự phòng mật mã API, điều này có nghĩa là tất cả bios có và
bối cảnh mã hóa sẽ sử dụng dự phòng và IO sẽ hoàn tất như bình thường.  Khi nào
dự phòng bị vô hiệu hóa, tiểu sử có bối cảnh mã hóa sẽ không thành công.

.. _hardware_wrapped_keys:

Phím bọc phần cứng
=====================

Mô hình động lực và mối đe dọa
---------------------------

Mã hóa lưu trữ Linux (dm-crypt, fscrypt, eCryptfs, v.v.) theo truyền thống
dựa vào (các) khóa mã hóa thô hiện có trong bộ nhớ hạt nhân để
mã hóa có thể được thực hiện.  Theo truyền thống, điều này không được coi là một vấn đề bởi vì
(các) khóa sẽ không xuất hiện trong cuộc tấn công ngoại tuyến, đây là loại tấn công chính
cuộc tấn công mà mã hóa lưu trữ nhằm mục đích bảo vệ khỏi.

Tuy nhiên, mong muốn bảo vệ dữ liệu của người dùng khỏi những kẻ khác ngày càng tăng.
các loại tấn công (trong phạm vi có thể), bao gồm:

- Tấn công khởi động nguội, trong đó kẻ tấn công có quyền truy cập vật lý vào hệ thống một cách đột ngột
  tắt nguồn rồi ngay lập tức xóa bộ nhớ hệ thống để giải nén gần đây
  các khóa mã hóa đang sử dụng, sau đó sử dụng các khóa này để giải mã dữ liệu người dùng trên đĩa.

- Tấn công trực tuyến trong đó kẻ tấn công có thể đọc bộ nhớ kernel mà không cần
  xâm phạm hệ thống, sau đó là một cuộc tấn công ngoại tuyến trong đó bất kỳ dữ liệu nào được trích xuất
  các khóa có thể được sử dụng để giải mã dữ liệu người dùng trên đĩa.  Một ví dụ về trực tuyến như vậy
  cuộc tấn công sẽ xảy ra nếu kẻ tấn công có thể chạy một số mã trên hệ thống
  khai thác lỗ hổng giống Meltdown nhưng không thể nâng cấp đặc quyền.

- Tấn công trực tuyến trong đó kẻ tấn công xâm phạm hoàn toàn hệ thống nhưng dữ liệu của chúng
  quá trình lọc bị giới hạn đáng kể về thời gian và/hoặc băng thông, vì vậy trong
  để lọc hoàn toàn dữ liệu họ cần để trích xuất mã hóa
  chìa khóa để sử dụng trong cuộc tấn công ngoại tuyến sau này.

Khóa bọc phần cứng là một tính năng của phần cứng mã hóa nội tuyến được
được thiết kế để bảo vệ dữ liệu của người dùng khỏi các cuộc tấn công trên (trong phạm vi có thể),
mà không đưa ra những hạn chế như số lượng khóa tối đa.

Lưu ý rằng ZZ0000ZZ không thể bảo vệ dữ liệu của người dùng khỏi các cuộc tấn công này.
Ngay cả trong các cuộc tấn công mà kẻ tấn công "chỉ" có được quyền truy cập đọc vào bộ nhớ kernel,
họ vẫn có thể trích xuất bất kỳ dữ liệu người dùng nào có trong bộ nhớ, bao gồm cả
các trang bộ nhớ đệm văn bản gốc của các tập tin được mã hóa.  Trọng tâm ở đây chỉ là vào
bảo vệ các khóa mã hóa, vì những khóa đó ngay lập tức cấp quyền truy cập cho người dùng ZZ0001ZZ
dữ liệu trong bất kỳ cuộc tấn công ngoại tuyến nào sau đây, thay vì chỉ một số dữ liệu đó (trong đó
dữ liệu được bao gồm trong đó "một số" có thể không bị kẻ tấn công kiểm soát).

Tổng quan về giải pháp
-----------------

Phần cứng mã hóa nội tuyến thường có các "khe khóa" để phần mềm có thể
các phím chương trình để phần cứng sử dụng; nội dung của các khe khóa thường không thể
được phần mềm đọc lại.  Như vậy, các mục tiêu bảo mật trên có thể đạt được
nếu hạt nhân chỉ xóa bản sao của (các) khóa sau khi lập trình chúng vào
(các) khe khóa và sau đó chỉ gọi chúng thông qua số khe khóa.

Tuy nhiên, cách tiếp cận ngây thơ đó gặp phải một số vấn đề:

- Nó giới hạn số lượng phím được mở khóa ở số lượng khe khóa,
  thường là một con số nhỏ.  Trong trường hợp chỉ có một khóa mã hóa
  toàn hệ thống (ví dụ: khóa mã hóa toàn bộ đĩa), có thể chấp nhận được.
  Tuy nhiên, nhìn chung có thể có nhiều người dùng đăng nhập với nhiều tài khoản khác nhau.
  khóa và/hoặc nhiều ứng dụng đang chạy có mã hóa dành riêng cho ứng dụng
  các khu vực lưu trữ.  Điều này đặc biệt đúng nếu mã hóa dựa trên tệp (ví dụ:
  fscrypt) đang được sử dụng.

- Công cụ mã hóa nội tuyến thường mất nội dung trong các khe khóa của chúng nếu
  bộ điều khiển lưu trữ (thường là UFS hoặc eMMC) được đặt lại.  Đặt lại bộ nhớ
  bộ điều khiển là một quy trình khôi phục lỗi tiêu chuẩn được thực thi nếu có một số
  các loại lỗi lưu trữ xảy ra và những lỗi đó có thể xảy ra bất cứ lúc nào.
  Do đó, khi sử dụng mật mã nội tuyến, hệ điều hành phải luôn
  sẵn sàng lập trình lại các khe phím mà không cần sự can thiệp của người dùng.

Vì vậy, điều quan trọng là kernel vẫn phải có cách “nhắc nhở”
phần cứng về một khóa mà không thực sự có khóa thô.

Ít quan trọng hơn, điều mong muốn là các khóa thô không bao giờ bị
phần mềm hoàn toàn có thể nhìn thấy ngay cả khi được mở khóa lần đầu.  Điều này sẽ
đảm bảo rằng sự thỏa hiệp chỉ đọc của bộ nhớ hệ thống sẽ không bao giờ cho phép một khóa được
được trích xuất để sử dụng ngoài hệ thống, ngay cả khi nó xảy ra khi một phím đang được mở khóa.

Để giải quyết tất cả những vấn đề này, một số nhà cung cấp phần cứng mã hóa nội tuyến đã
đã hỗ trợ phần cứng ZZ0000ZZ của họ.  Phím bọc phần cứng
là các khóa được mã hóa chỉ có thể được mở (giải mã) và được sử dụng bởi phần cứng
-- bằng chính phần cứng mã hóa nội tuyến hoặc bằng phần cứng chuyên dụng
khối có thể cung cấp khóa trực tiếp cho phần cứng mã hóa nội tuyến.

(Chúng tôi gọi chúng là "khóa bọc phần cứng" thay vì chỉ đơn giản là "khóa bọc"
để thêm phần rõ ràng trong trường hợp có thể có các loại khóa được bọc khác,
chẳng hạn như trong mã hóa dựa trên tập tin.  Gói khóa là một kỹ thuật thường được sử dụng.)

Khóa bao bọc (mã hóa) các khóa được bọc phần cứng là khóa bên trong phần cứng
điều đó không bao giờ được tiếp xúc với phần mềm; nó có thể là một khóa liên tục ("khóa dài hạn
khóa gói") hoặc khóa mỗi lần khởi động ("khóa gói tạm thời").  Dài hạn
dạng bọc của chìa khóa là thứ được mở khóa ban đầu, nhưng nó bị xóa khỏi
bộ nhớ ngay khi nó được chuyển đổi thành một khóa được bọc tạm thời.  Đang sử dụng
các khóa được bọc phần cứng luôn được bọc tạm thời, không được bọc lâu dài.

Vì phần cứng mã hóa nội tuyến chỉ có thể được sử dụng để mã hóa/giải mã dữ liệu trên đĩa,
phần cứng cũng bao gồm một mức độ gián tiếp; nó không sử dụng cái đã được mở
khóa trực tiếp để mã hóa nội tuyến, mà xuất phát cả mã hóa nội tuyến
khóa và một "bí mật phần mềm" từ nó.  Phần mềm có thể sử dụng "bí mật phần mềm" để
các tác vụ không thể sử dụng phần cứng mã hóa nội tuyến, chẳng hạn như tên tệp
mã hóa.  Bí mật phần mềm không được bảo vệ khỏi sự xâm phạm bộ nhớ.

Hệ thống phân cấp khóa
-------------

Đây là hệ thống phân cấp khóa cho khóa được bọc phần cứng::

Khóa bọc phần cứng
                                |
                                |
                          <Phần cứng KDF>
                                |
                  -----------------------------
                  ZZ0000ZZ
        Khóa mã hóa nội tuyến Bí mật phần mềm

Các thành phần là:

- ZZ0000ZZ: chìa khóa cho KDF (Key Derivation) của phần cứng
  Function), ở dạng được bao bọc tạm thời.  Thuật toán gói khóa là một
  chi tiết triển khai phần cứng không ảnh hưởng đến hoạt động của kernel, nhưng
  Nên sử dụng thuật toán mã hóa được xác thực mạnh như AES-256-GCM.

- ZZ0000ZZ: KDF (Chức năng dẫn xuất khóa) mà phần cứng sử dụng để
  lấy được các khóa con sau khi mở khóa được bọc.  Sự lựa chọn phần cứng của KDF
  không ảnh hưởng đến hoạt động của kernel, nhưng cần phải biết nó để kiểm tra
  mục đích và nó cũng được cho là có độ mạnh bảo mật ít nhất là 256-bit.
  Tất cả phần cứng đã biết đều sử dụng SP800-108 KDF ở Chế độ truy cập với AES-256-CMAC,
  với sự lựa chọn cụ thể về nhãn và bối cảnh; phần cứng mới nên sử dụng cái này
  KDF đã được hiệu đính.

- ZZ0000ZZ: khóa dẫn xuất được cung cấp trực tiếp bởi phần cứng
  vào khe khóa của phần cứng mã hóa nội tuyến mà không để lộ nó ra
  phần mềm.  Trong tất cả các phần cứng đã biết, đây sẽ luôn là khóa AES-256-XTS.
  Tuy nhiên, về nguyên tắc, các thuật toán mã hóa khác cũng có thể được hỗ trợ.
  Phần cứng phải lấy được các khóa con riêng biệt cho từng thuật toán mã hóa được hỗ trợ.

- ZZ0000ZZ: khóa dẫn xuất mà phần cứng trả về phần mềm
  phần mềm đó có thể sử dụng nó cho các tác vụ mã hóa không thể sử dụng nội tuyến
  mã hóa.  Giá trị này được cách ly bằng mật mã với giá trị nội tuyến
  khóa mã hóa, tức là biết cái này không tiết lộ cái kia.  (KDF đảm bảo
  này.) Hiện tại, bí mật của phần mềm luôn là 32 byte và do đó phù hợp
  dành cho các ứng dụng mật mã yêu cầu cường độ bảo mật lên tới 256 bit.
  Một số trường hợp sử dụng (ví dụ: mã hóa toàn bộ đĩa) sẽ không yêu cầu bí mật phần mềm.

Ví dụ: trong trường hợp của fscrypt, khóa chính fscrypt (khóa bảo vệ một
tập hợp các thư mục được mã hóa cụ thể) được gói trong phần cứng.  Nội tuyến
khóa mã hóa được sử dụng làm khóa mã hóa nội dung tệp, trong khi phần mềm
bí mật (chứ không phải khóa chính trực tiếp) được sử dụng để khóa KDF của fscrypt
(HKDF-SHA512) để lấy các khóa con khác như khóa mã hóa tên tệp.

Lưu ý rằng hiện tại thiết kế này giả định một khóa mã hóa nội tuyến duy nhất cho mỗi
khóa được bọc phần cứng, không có bất kỳ dẫn xuất khóa nào nữa.  Như vậy, trong trường hợp
fscrypt, hiện tại các khóa được bao bọc bằng phần cứng chỉ tương thích với "nội tuyến
tối ưu hóa mã hóa", cài đặt này sử dụng một khóa mã hóa nội dung tệp cho mỗi
chính sách mã hóa thay vì một chính sách cho mỗi tập tin.  Thiết kế này có thể được mở rộng để
làm cho phần cứng lấy được các khóa trên mỗi tệp bằng cách sử dụng các số không trên mỗi tệp được truyền xuống
ngăn xếp lưu trữ và trên thực tế một số phần cứng đã hỗ trợ điều này; công việc tương lai là
đã lên kế hoạch loại bỏ giới hạn này bằng cách thêm hỗ trợ kernel tương ứng.

Hỗ trợ hạt nhân
--------------

Hỗ trợ mã hóa nội tuyến của lớp khối của kernel ("blk-crypto") có
được mở rộng để hỗ trợ các khóa được bọc trong phần cứng thay thế cho các khóa thô,
khi có hỗ trợ phần cứng.  Điều này hoạt động theo cách sau:

- Trường ZZ0000ZZ được thêm vào khả năng mã hóa trong
  ZZ0001ZZ.  Điều này cho phép trình điều khiển thiết bị tuyên bố rằng
  chúng hỗ trợ khóa thô, khóa bọc phần cứng hoặc cả hai.

- ZZ0000ZZ hiện có thể chứa khóa được bọc phần cứng dưới dạng
  thay thế cho khóa thô; trường ZZ0001ZZ được thêm vào
  ZZ0002ZZ để phân biệt các loại khóa khác nhau.
  Điều này cho phép người dùng blk-crypto mã hóa/giải mã dữ liệu bằng cách sử dụng gói phần cứng
  key theo cách rất giống với việc sử dụng khóa thô.

- Một phương pháp mới ZZ0000ZZ được thêm vào.  Trình điều khiển thiết bị
  hỗ trợ các khóa bọc phần cứng phải triển khai phương pháp này.  Người dùng của
  blk-crypto có thể gọi ZZ0001ZZ để truy cập phương thức này.

- Việc lập trình và loại bỏ các khóa bọc phần cứng diễn ra thông qua
  ZZ0000ZZ và
  ZZ0001ZZ, giống như đối với khóa thô.  Nếu một
  trình điều khiển hỗ trợ các khóa được bọc phần cứng thì nó phải xử lý các khóa được bọc phần cứng
  các khóa được truyền cho các phương thức này.

blk-crypto-fallback không hỗ trợ các khóa được bọc phần cứng.  Vì vậy,
các khóa được bọc phần cứng chỉ có thể được sử dụng với phần cứng mã hóa nội tuyến thực tế.

Tất cả các vấn đề trên chỉ đề cập đến các khóa được bọc phần cứng ở dạng được bọc tạm thời.
Để có được những khóa như vậy ngay từ đầu, ioctls thiết bị khối mới đã được thêm vào
cung cấp giao diện chung để tạo và chuẩn bị các khóa đó:

- ZZ0000ZZ chuyển đổi khóa thô sang dạng gói dài hạn.  Phải mất
  trong một con trỏ tới ZZ0001ZZ.  Người gọi phải đặt
  ZZ0002ZZ và ZZ0003ZZ tới con trỏ và kích thước (tính bằng byte) của
  khóa thô để nhập.  Khi thành công, ZZ0004ZZ trả về 0 và ghi
  kết quả là blob khóa được bọc dài hạn vào bộ đệm được chỉ ra bởi
  ZZ0005ZZ, có kích thước tối đa ZZ0006ZZ.  Nó cũng cập nhật
  ZZ0007ZZ là kích thước thực của khóa.  Khi thất bại, nó trả về -1
  và đặt lỗi.  Lỗi ZZ0008ZZ cho biết thiết bị chặn
  không hỗ trợ các phím bọc phần cứng.  Một lỗi của ZZ0009ZZ cho biết
  rằng bộ đệm đầu ra không có đủ dung lượng cho đốm màu chính.

- ZZ0000ZZ giống như ZZ0001ZZ, nhưng nó có
  phần cứng tạo khóa thay vì nhập khóa.  Nó cần một con trỏ để
  một chiếc ZZ0002ZZ.

- ZZ0000ZZ chuyển đổi khóa từ dạng gói dài hạn sang dạng
  hình thức bao bọc phù du.  Nó nhận một con trỏ tới ZZ0001ZZ.  Người gọi phải đặt ZZ0002ZZ và
  ZZ0003ZZ tới con trỏ và kích thước (tính bằng byte) của gói dài hạn
  key blob để chuyển đổi.  Khi thành công, ZZ0004ZZ trả về 0 và ghi
  kết quả là blob khóa được bao bọc tạm thời vào bộ đệm được trỏ đến bởi
  ZZ0005ZZ, có kích thước tối đa ZZ0006ZZ.  Nó cũng cập nhật
  ZZ0007ZZ là kích thước thực của khóa.  Khi thất bại, nó trả về -1
  và đặt lỗi.  Giá trị lỗi của ZZ0008ZZ và ZZ0009ZZ có nghĩa là
  tương tự như cách họ làm với ZZ0010ZZ.  Một lỗi của ZZ0011ZZ cho biết
  rằng khóa được gói dài hạn không hợp lệ.

Không gian người dùng cần sử dụng ZZ0000ZZ hoặc ZZ0001ZZ
một lần để tạo khóa và sau đó là ZZ0002ZZ mỗi lần khóa được
đã được mở khóa và thêm vào kernel.  Lưu ý rằng những ioctls này không liên quan đến
khóa thô; chúng chỉ dành cho các khóa được bọc phần cứng.

Khả năng kiểm tra
-----------

Cả phần cứng KDF và mã hóa nội tuyến đều được xác định rõ ràng
các thuật toán không phụ thuộc vào bất kỳ bí mật nào ngoài khóa chưa được mở.
Do đó, nếu phần mềm biết được khóa chưa được gói thì các thuật toán này có thể được
được sao chép trong phần mềm để xác minh bản mã được ghi vào đĩa
bởi phần cứng mã hóa nội tuyến.

Tuy nhiên, khóa chưa được gói sẽ chỉ được phần mềm kiểm tra biết nếu
chức năng "nhập khẩu" được sử dụng.  Việc kiểm tra thích hợp là không thể thực hiện được trong
trường hợp "tạo" trong đó phần cứng tự tạo khóa.  Đúng
do đó hoạt động của chế độ "tạo" phụ thuộc vào tính bảo mật và tính chính xác của
phần cứng RNG và cách sử dụng nó để tạo khóa cũng như kiểm tra
chế độ "nhập" vì chế độ đó sẽ bao gồm tất cả các phần khác ngoài việc tạo khóa.

Để biết ví dụ về kiểm tra xác minh văn bản mã hóa được ghi vào đĩa trong
chế độ "nhập", xem các bài kiểm tra khóa được bọc phần cứng fscrypt trong xfstests hoặc
ZZ0000ZZ.