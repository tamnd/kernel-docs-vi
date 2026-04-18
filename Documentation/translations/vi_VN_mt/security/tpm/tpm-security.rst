.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm-security.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Bảo mật TPM
============

Mục tiêu của tài liệu này là mô tả cách chúng tôi tạo ra kernel
việc sử dụng TPM khá mạnh mẽ khi đối mặt với sự rình mò bên ngoài và
các cuộc tấn công thay đổi gói tin (được gọi là cuộc tấn công xen kẽ thụ động và chủ động
trong văn học).  Tài liệu bảo mật hiện tại dành cho TPM 2.0.

Giới thiệu
------------

TPM thường là một con chip rời được gắn vào PC thông qua một số loại
xe buýt băng thông thấp.  Có những trường hợp ngoại lệ cho điều này chẳng hạn như Intel
PTT, là phần mềm TPM chạy trong môi trường phần mềm
gần với CPU, chịu các cuộc tấn công khác nhau, nhưng ngay tại
hiện tại, hầu hết các môi trường bảo mật cứng nhắc đều yêu cầu một hệ thống riêng biệt
phần cứng TPM, đây là trường hợp sử dụng được thảo luận ở đây.

Các cuộc tấn công theo dõi và thay đổi nhằm vào xe buýt
-----------------------------------------------

Công nghệ tiên tiến hiện nay để theo dõi phần cứng ZZ0000ZZ
bộ chuyển đổi là một thiết bị bên ngoài đơn giản có thể được cài đặt trong
một vài giây trên bất kỳ hệ thống hoặc máy tính xách tay nào.  Các cuộc tấn công gần đây đã
đã trình diễn thành công chống lại hệ thống ZZ0001ZZ.
Gần đây nhất là các chương trình ZZ0002ZZ tương tự.  Giai đoạn nghiên cứu tiếp theo dường như là hack
các thiết bị hiện có trên xe buýt hoạt động như bộ chuyển tiếp, vì vậy thực tế là
kẻ tấn công yêu cầu quyền truy cập vật lý trong vài giây có thể
bay hơi.  Tuy nhiên, mục tiêu của tài liệu này là để bảo vệ TPM
bí mật và tính toàn vẹn trong khả năng của chúng tôi trong môi trường này và để
cố gắng đảm bảo rằng nếu chúng ta không thể ngăn chặn cuộc tấn công thì ít nhất chúng ta có thể
phát hiện nó.

Thật không may, hầu hết chức năng của TPM, bao gồm cả phần cứng
khả năng thiết lập lại có thể được kiểm soát bởi kẻ tấn công có quyền truy cập vào
xe buýt, vì vậy chúng ta sẽ thảo luận về một số khả năng gián đoạn bên dưới.

Đo lường (PCR) Tính toàn vẹn
---------------------------

Vì kẻ tấn công có thể gửi lệnh của riêng chúng tới TPM nên chúng có thể
gửi PCR tùy ý mở rộng và do đó làm gián đoạn hệ thống đo lường,
đó sẽ là một cuộc tấn công từ chối dịch vụ khó chịu.  Tuy nhiên, có
là hai loại tấn công nghiêm trọng hơn nhằm vào các thực thể bị phong ấn
thước đo niềm tin.

1. Kẻ tấn công có thể chặn tất cả các phần mở rộng PCR đến từ hệ thống
   và thay thế hoàn toàn các giá trị của chính chúng, tạo ra sự phát lại
   trạng thái không bị giả mạo sẽ khiến các phép đo PCR chứng thực
   một trạng thái đáng tin cậy và tiết lộ bí mật

2. Tại một thời điểm nào đó, kẻ tấn công có thể đặt lại TPM, xóa
   PCR và sau đó gửi các phép đo của riêng chúng xuống để
   ghi đè một cách hiệu quả các phép đo thời gian khởi động mà TPM có
   đã xong rồi.

Việc đầu tiên có thể được ngăn chặn bằng cách luôn thực hiện bảo vệ HMAC cho PCR
lệnh mở rộng và đọc nghĩa là không thể xác định được các giá trị đo
được thay thế mà không tạo ra lỗi HMAC có thể phát hiện được trong
phản hồi.  Tuy nhiên, thứ hai chỉ có thể thực sự được phát hiện bằng cách dựa vào
về một số loại cơ chế bảo vệ sẽ thay đổi trên TPM
đặt lại.

Bảo vệ bí mật
----------------

Một số thông tin nhất định truyền vào và ra khỏi TPM, chẳng hạn như niêm phong chìa khóa
và nhập khóa riêng và tạo số ngẫu nhiên, dễ bị tấn công
sự đánh chặn mà chỉ riêng biện pháp bảo vệ HMAC không thể bảo vệ chống lại được, vì vậy
đối với những loại lệnh này, chúng ta cũng phải sử dụng yêu cầu và phản hồi
mã hóa để ngăn chặn việc mất thông tin bí mật.

Thiết lập niềm tin ban đầu với TPM
---------------------------------------

Để cung cấp bảo mật ngay từ đầu, một chia sẻ ban đầu hoặc
bí mật bất đối xứng phải được thiết lập và bí mật này cũng phải được biết đến
kẻ tấn công.  Con đường rõ ràng nhất cho việc này là sự chứng thực
và hạt giống lưu trữ, có thể được sử dụng để lấy các khóa bất đối xứng.
Tuy nhiên, việc sử dụng các phím này rất khó khăn vì cách duy nhất để vượt qua
chúng vào kernel sẽ nằm trên dòng lệnh, điều này đòi hỏi
hỗ trợ rộng rãi trong hệ thống khởi động và không có gì đảm bảo rằng
một trong hai hệ thống phân cấp sẽ không có một số loại ủy quyền.

Cơ chế được chọn cho Hạt nhân Linux là lấy ra dữ liệu chính
khóa đường cong elip từ hạt giống rỗng bằng cách sử dụng hạt giống lưu trữ tiêu chuẩn
các thông số.  Hạt giống null có hai ưu điểm: thứ nhất là hệ thống phân cấp
về mặt vật lý không thể có ủy quyền, vì vậy chúng tôi luôn có thể sử dụng
nó và thứ hai, hạt giống rỗng thay đổi trong các lần đặt lại TPM, nghĩa là nếu
chúng tôi thiết lập niềm tin vào hạt giống rỗng vào đầu ngày, tất cả các phiên
được tạo muối bằng khóa dẫn xuất sẽ thất bại nếu TPM được đặt lại và hạt giống
những thay đổi.

Rõ ràng là sử dụng hạt giống rỗng mà không có bất kỳ bí mật nào được chia sẻ trước đó,
chúng ta phải tạo và đọc khóa công khai ban đầu có thể
Tất nhiên, bị chặn và thay thế bởi người xen kẽ xe buýt.
Tuy nhiên, TPM có cơ chế chứng nhận chính (sử dụng EK
chứng chỉ chứng thực, tạo khóa nhận dạng chứng thực và
xác nhận hạt giống chính bằng khóa đó) quá phức tạp
để chạy trong kernel, vì vậy chúng tôi giữ một bản sao của khóa chính null
tên, là tên được xuất qua sysfs để không gian người dùng có thể chạy
chứng nhận đầy đủ khi nó khởi động.  Sự đảm bảo chắc chắn ở đây là
rằng nếu khóa chính null chứng nhận chính xác, bạn sẽ biết tất cả
Các giao dịch TPM kể từ đầu ngày được đảm bảo an toàn và nếu không, bạn
biết có một kẻ can thiệp vào hệ thống của bạn (và bất kỳ bí mật nào được sử dụng
trong quá trình khởi động có thể đã bị rò rỉ).

Xếp chồng niềm tin
--------------

Trong kịch bản chính rỗng hiện tại, TPM phải hoàn toàn
được xóa trước khi chuyển nó cho người tiêu dùng tiếp theo.  Tuy nhiên hạt nhân
trao cho không gian người dùng tên của khóa hạt giống null dẫn xuất có thể
sau đó được xác minh bằng chứng nhận trong không gian người dùng.  Vì vậy, chuỗi này
Việc chuyển giao tên có thể được sử dụng giữa các thành phần khởi động khác nhau như
tốt (thông qua một cơ chế không xác định).  Ví dụ, grub có thể sử dụng
sơ đồ hạt giống null để bảo mật và chuyển tên cho kernel trong
khu vực khởi động.  Hạt nhân có thể tạo ra khóa riêng của nó
và tên và biết chắc chắn rằng nếu chúng khác với tay
phiên bản tắt đã xảy ra sự giả mạo.  Vì vậy nó trở nên có thể
xâu chuỗi các thành phần khởi động tùy ý lại với nhau (UEFI để grub vào kernel) thông qua
chuyển giao tên với điều kiện mỗi thành phần kế tiếp biết cách
thu thập tên và xác minh nó dựa trên khóa dẫn xuất của nó.

Thuộc tính phiên
------------------

Tất cả các lệnh TPM mà kernel sử dụng đều cho phép phiên.  Phiên HMAC có thể
được sử dụng để kiểm tra tính toàn vẹn của các yêu cầu và phản hồi cũng như giải mã và
cờ mã hóa có thể được sử dụng để bảo vệ các tham số và phản hồi.  các
HMAC và các khóa mã hóa thường được lấy từ khóa chia sẻ
bí mật ủy quyền, nhưng đối với nhiều hoạt động kernel thì điều đó tốt
đã biết (và thường trống).  Do đó, mỗi phiên HMAC được sử dụng bởi
kernel phải được tạo bằng khóa chính null làm khóa muối
do đó cung cấp đầu vào mật mã vào khóa phiên
dẫn xuất.  Do đó, kernel tạo khóa chính null một lần (dưới dạng
tay cầm TPM dễ bay hơi) và giữ nó trong bối cảnh đã lưu được lưu trữ trong
tpm_chip cho mỗi lần sử dụng TPM trong kernel.  Hiện nay, vì một
thiếu khoảng cách trong trình quản lý tài nguyên trong kernel, phiên phải
được tạo và hủy cho mỗi hoạt động, nhưng trong tương lai, một
phiên cũng có thể được sử dụng lại cho HMAC trong kernel, mã hóa và
các phiên giải mã.

Các loại bảo vệ
----------------

Đối với mọi hoạt động trong kernel, chúng tôi sử dụng HMAC được muối chính null để
bảo vệ sự toàn vẹn.  Ngoài ra, chúng tôi sử dụng mã hóa tham số để
bảo vệ việc niêm phong khóa và giải mã tham số để bảo vệ việc mở khóa
và tạo số ngẫu nhiên.

Chứng nhận khóa chính Null trong không gian người dùng
===========================================

Mỗi TPM đều được cung cấp kèm theo một vài chứng chỉ X.509 cho
khóa chứng thực chính.  Tài liệu này giả định rằng Elliptic
Phiên bản đường cong của chứng chỉ tồn tại ở 01C00002, nhưng sẽ hoạt động
tốt như nhau với chứng chỉ RSA (tại 01C00001).

Bước đầu tiên trong quá trình chứng nhận là tạo cơ sở bằng cách sử dụng
mẫu từ ZZ0000ZZ cho phép so sánh
của khóa chính được tạo so với khóa chính trong chứng chỉ (
khóa công khai phải khớp).  Lưu ý rằng việc tạo EK sơ cấp
yêu cầu mật khẩu phân cấp EK, nhưng phiên bản được tạo trước của
EC chính phải tồn tại ở 81010002 và TPM2_ReadPublic() có thể
thực hiện việc này mà không cần có thẩm quyền chính.  Tiếp theo,
Bản thân chứng chỉ phải được xác minh để liên kết lại với nhà sản xuất
root (phải được công bố trên trang web của nhà sản xuất).  Một lần
việc này hoàn tất, khóa chứng thực (AK) được tạo trong TPM và
đó là tên và khóa chung EK có thể được sử dụng để mã hóa bí mật bằng cách sử dụng
TPM2_MakeCredential.  TPM sau đó chạy TPM2_ActivateCredential
sẽ chỉ khôi phục bí mật nếu liên kết giữa TPM, EK
và AK là đúng. AK được tạo bây giờ có thể được sử dụng để chạy
chứng nhận khóa chính null có tên hạt nhân
đã xuất khẩu.  Vì TPM2_MakeCredential/ActivateCredential có phần
phức tạp hơn, một quy trình đơn giản hơn có sự tham gia của bên ngoài
khóa riêng được tạo được mô tả dưới đây.

Quá trình này là tên viết tắt đơn giản của CA bảo mật thông thường
quá trình chứng thực dựa trên  Giả định ở đây là
việc chứng thực được thực hiện bởi chủ sở hữu TPM, do đó, người này chỉ có quyền truy cập vào
thứ bậc chủ sở hữu.  Chủ sở hữu tạo khóa công khai/riêng tư bên ngoài
ghép nối (giả sử đường cong elip trong trường hợp này) và bọc khóa riêng
để nhập bằng quy trình gói bên trong và được cấp dữ liệu cho EC
lưu trữ có nguồn gốc chính.  TPM2_Import() được thực hiện bằng tham số
giải mã Phiên HMAC được thêm vào phiên bản chính EK (cũng không
yêu cầu quyền khóa EK) nghĩa là khóa gói bên trong là
tham số được mã hóa và do đó TPM sẽ không thể thực hiện
việc nhập trừ khi có EK được chứng nhận nên nếu lệnh
thành công và HMAC xác minh khi trả lại, chúng tôi biết rằng chúng tôi có một thiết bị có thể tải được
bản sao của khóa riêng chỉ dành cho TPM được chứng nhận.  Chìa khóa này bây giờ là
được tải vào TPM và Bộ lưu trữ chính được xóa (để giải phóng dung lượng
để tạo khóa null).

EC chính null hiện được tạo bằng cấu hình lưu trữ
được nêu trong ZZ0000ZZ; tên của
khóa này (mã băm của khu vực công cộng) được tính toán và so sánh với
tên hạt giống null được trình bày bởi kernel trong
/sys/class/tpm/tpm0/null_name.  Nếu tên không khớp thì TPM là
bị thỏa hiệp.  Nếu tên trùng khớp, người dùng thực hiện TPM2_Certify()
sử dụng khóa chính null làm đối tượng xử lý và khóa riêng được tải
làm tay cầm dấu hiệu và cung cấp dữ liệu đủ điều kiện ngẫu nhiên.  các
chữ ký của certifyInfo được trả về được xác minh đối với công chúng
một phần của khóa riêng được tải và dữ liệu đủ điều kiện được kiểm tra
ngăn chặn việc phát lại.  Nếu tất cả các thử nghiệm này vượt qua, người dùng hiện yên tâm
rằng tính toàn vẹn và quyền riêng tư của TPM được bảo toàn trong toàn bộ quá trình khởi động
trình tự của hạt nhân này.

.. _TPM Genie: https://www.nccgroup.trust/globalassets/about-us/us/documents/tpm-genie.pdf
.. _Windows Bitlocker TPM: https://dolosgroup.io/blog/2021/7/9/from-stolen-laptop-to-inside-the-company-network
.. _attack against TPM based Linux disk encryption: https://www.secura.com/blog/tpm-sniffing-attacks-against-non-bitlocker-targets
.. _TCG EK Credential Profile: https://trustedcomputinggroup.org/resource/tcg-ek-credential-profile-for-tpm-family-2-0/
.. _TCG TPM v2.0 Provisioning Guidance: https://trustedcomputinggroup.org/resource/tcg-tpm-v2-0-provisioning-guidance/