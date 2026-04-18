.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/self-protection.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Tự bảo vệ hạt nhân
======================

Tự bảo vệ hạt nhân là thiết kế và triển khai các hệ thống và
cấu trúc bên trong nhân Linux để bảo vệ chống lại các lỗi bảo mật trong
chính hạt nhân. Điều này bao gồm nhiều vấn đề, bao gồm cả việc loại bỏ
toàn bộ các loại lỗi, chặn các phương pháp khai thác lỗ hổng bảo mật,
và chủ động phát hiện các nỗ lực tấn công. Không phải tất cả các chủ đề đều được khám phá trong
tài liệu này, nhưng nó phải là điểm khởi đầu hợp lý và
trả lời mọi câu hỏi thường gặp. (Tất nhiên là chào đón các bản vá!)

Trong trường hợp xấu nhất, chúng tôi giả sử kẻ tấn công cục bộ không có đặc quyền
có quyền truy cập đọc và ghi tùy ý vào bộ nhớ của kernel. Ở nhiều nơi
trường hợp, lỗi bị khai thác sẽ không cung cấp mức truy cập này,
nhưng với các hệ thống sẵn sàng chống lại trường hợp xấu nhất, chúng tôi sẽ
cũng bao gồm các trường hợp hạn chế hơn. Một thanh cao hơn và một thanh nên
vẫn được ghi nhớ, đang bảo vệ hạt nhân khỏi _đặc quyền_
kẻ tấn công cục bộ, vì người dùng root có quyền truy cập vào một lượng lớn
bề mặt tấn công (Đặc biệt khi chúng có khả năng nạp tùy ý
mô-đun hạt nhân.)

Mục tiêu của các hệ thống tự bảo vệ thành công là chúng
theo mặc định có hiệu lực, không yêu cầu nhà phát triển chọn tham gia, không có
tác động đến hiệu suất, không cản trở việc gỡ lỗi kernel và có các bài kiểm tra. Nó
hiếm khi tất cả các mục tiêu này có thể đạt được, nhưng nó có giá trị rõ ràng
đề cập đến chúng, vì những khía cạnh này cần được khám phá, xử lý,
và/hoặc được chấp nhận.


Giảm bề mặt tấn công
========================

Biện pháp phòng vệ cơ bản nhất chống lại việc khai thác bảo mật là giảm thiểu
các vùng của kernel có thể được sử dụng để chuyển hướng thực thi. Phạm vi này
từ việc giới hạn các API hiển thị có sẵn cho không gian người dùng, tạo ra các ứng dụng trong kernel
API khó sử dụng không chính xác, giảm thiểu diện tích của kernel có thể ghi
bộ nhớ, v.v.

Quyền bộ nhớ hạt nhân nghiêm ngặt
--------------------------------

Khi tất cả bộ nhớ kernel đều có thể ghi được, việc tấn công trở nên tầm thường
để chuyển hướng luồng thực thi. Để giảm sự sẵn có của các mục tiêu này
kernel cần bảo vệ bộ nhớ của nó bằng một bộ quyền chặt chẽ.

Mã thực thi và dữ liệu chỉ đọc không được phép ghi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bất kỳ vùng nào của kernel có bộ nhớ thực thi đều không thể ghi được.
Trong khi điều này rõ ràng bao gồm chính văn bản kernel, chúng ta phải xem xét
tất cả các vị trí bổ sung nữa: mô-đun hạt nhân, bộ nhớ JIT, v.v. (Có
ngoại lệ tạm thời cho quy tắc này để hỗ trợ những việc như hướng dẫn
các lựa chọn thay thế, điểm dừng, kprobe, v.v. Nếu những thứ này phải tồn tại trong một
kernel, chúng được triển khai theo cách mà bộ nhớ tạm thời
có thể ghi được trong quá trình cập nhật và sau đó quay trở lại bản gốc
quyền.)

Hỗ trợ điều này là ZZ0000ZZ và
ZZ0001ZZ, nhằm đảm bảo mã đó không bị
có thể ghi, dữ liệu không thể thực thi và dữ liệu chỉ đọc không thể ghi
cũng không thể thực thi được.

Hầu hết các kiến ​​trúc đều bật các tùy chọn này theo mặc định và người dùng không thể lựa chọn.
Đối với một số kiến trúc như cánh tay muốn có những lựa chọn này,
kiến trúc Kconfig có thể chọn ARCH_OPTIONAL_KERNEL_RWX để kích hoạt
lời nhắc Kconfig. ZZ0000ZZ xác định
cài đặt mặc định khi ARCH_OPTIONAL_KERNEL_RWX được bật.

Con trỏ hàm và các biến nhạy cảm không được phép ghi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Vùng bộ nhớ hạt nhân rộng lớn chứa các con trỏ hàm được tìm kiếm
được nhân lên và sử dụng để tiếp tục thực thi (ví dụ: bộ mô tả/vectơ
bảng, cấu trúc hoạt động của tệp/mạng/vv, v.v.). Số lượng này
các biến phải được giảm đến mức tối thiểu tuyệt đối.

Nhiều biến như vậy có thể được đặt ở chế độ chỉ đọc bằng cách đặt chúng là "const"
để chúng nằm trong phần .rodata thay vì phần .data
của hạt nhân, giành được sự bảo vệ của bộ nhớ nghiêm ngặt của hạt nhân
quyền như đã mô tả ở trên.

Đối với các biến được khởi tạo một lần tại thời điểm ZZ0000ZZ, chúng có thể
được đánh dấu bằng thuộc tính ZZ0001ZZ.

Những gì còn lại là các biến hiếm khi được cập nhật (ví dụ GDT). Những cái này
sẽ cần cơ sở hạ tầng khác (tương tự như các trường hợp ngoại lệ tạm thời
được tạo theo mã kernel đã đề cập ở trên) để cho phép họ sử dụng phần còn lại
chỉ đọc trong suốt cuộc đời của họ. (Ví dụ: khi được cập nhật, chỉ có
Chuỗi CPU thực hiện cập nhật sẽ được ghi liên tục
truy cập vào bộ nhớ.)

Tách bộ nhớ kernel khỏi bộ nhớ không gian người dùng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hạt nhân không bao giờ được thực thi bộ nhớ vùng người dùng. Hạt nhân cũng không bao giờ được
truy cập bộ nhớ không gian người dùng mà không mong muốn làm như vậy một cách rõ ràng. Những cái này
các quy tắc có thể được thực thi bằng cách hỗ trợ các hạn chế dựa trên phần cứng
(SMEP/SMAP của x86, PXN/PAN của ARM) hoặc thông qua mô phỏng (Miền bộ nhớ của ARM).
Bằng cách chặn bộ nhớ không gian người dùng theo cách này, việc thực thi và phân tích dữ liệu
không thể được chuyển tới bộ nhớ không gian người dùng được kiểm soát tầm thường, buộc
các cuộc tấn công hoạt động hoàn toàn trong bộ nhớ kernel.

Giảm quyền truy cập vào syscalls
--------------------------

Một cách đơn giản để loại bỏ nhiều cuộc gọi chung cho hệ thống 64-bit là xây dựng
không có ZZ0000ZZ. Tuy nhiên, đây hiếm khi là một kịch bản khả thi.

Hệ thống "seccomp" cung cấp tính năng chọn tham gia dành cho
không gian người dùng, cung cấp một cách để giảm số lượng mục nhập kernel
điểm có sẵn cho một quá trình đang chạy. Điều này giới hạn độ rộng của kernel
mã có thể đạt được, có thể làm giảm tính sẵn có của một mã nhất định
lỗi cho một cuộc tấn công.

Một lĩnh vực cần cải thiện là tạo ra những cách khả thi để duy trì quyền truy cập vào
những thứ như compat, không gian tên người dùng, tạo BPF và chỉ giới hạn hoàn hảo
đến các quy trình đáng tin cậy. Điều này sẽ giữ phạm vi của các điểm vào kernel
bị giới hạn ở tập hợp thường xuyên hơn thường có sẵn cho những người không có đặc quyền
không gian người dùng.

Hạn chế quyền truy cập vào các mô-đun hạt nhân
------------------------------------

Hạt nhân không bao giờ được phép cho phép người dùng không có đặc quyền có khả năng
tải các mô-đun hạt nhân cụ thể, vì điều đó sẽ cung cấp cơ sở để
bất ngờ mở rộng bề mặt tấn công có sẵn. (Tải theo yêu cầu
của các mô-đun thông qua các hệ thống con được xác định trước của chúng, ví dụ: MODULE_ALIAS_*, là
được coi là "dự kiến" ở đây, mặc dù cần xem xét thêm
thậm chí được đưa ra cho những điều này.) Ví dụ: tải một mô-đun hệ thống tập tin thông qua một
ổ cắm không có đặc quyền API là vô nghĩa: chỉ có gốc hoặc cục bộ vật lý
người dùng nên kích hoạt tải mô-đun hệ thống tập tin. (Và thậm chí điều này có thể xảy ra
để tranh luận trong một số tình huống.)

Để bảo vệ khỏi những người dùng có đặc quyền, hệ thống có thể cần phải
vô hiệu hóa hoàn toàn việc tải mô-đun (ví dụ: xây dựng hạt nhân nguyên khối hoặc
module_disabled sysctl) hoặc cung cấp các mô-đun đã ký (ví dụ:
ZZ0000ZZ, hoặc dm-crypt với LoadPin), để tránh gặp phải
root tải mã hạt nhân tùy ý thông qua giao diện trình tải mô-đun.


Tính toàn vẹn của bộ nhớ
================

Có nhiều cấu trúc bộ nhớ trong kernel thường xuyên bị lạm dụng
để giành quyền kiểm soát thực thi trong một cuộc tấn công, cho đến nay, cách phổ biến nhất
được hiểu là tràn bộ đệm ngăn xếp trong đó kết quả trả về
địa chỉ được lưu trữ trên ngăn xếp bị ghi đè. Nhiều ví dụ khác về điều này
loại tấn công tồn tại và các biện pháp bảo vệ tồn tại để chống lại chúng.

Tràn bộ đệm ngăn xếp
---------------------

Tràn bộ đệm ngăn xếp cổ điển liên quan đến việc ghi quá điểm kết thúc dự kiến
của một biến được lưu trữ trên ngăn xếp, cuối cùng ghi một giá trị được kiểm soát
tới địa chỉ trả về được lưu trữ của khung ngăn xếp. Phòng thủ được sử dụng rộng rãi nhất
là sự hiện diện của một canary ngăn xếp giữa các biến ngăn xếp và
địa chỉ trả lại (ZZ0000ZZ), được xác minh ngay trước đó
hàm trả về. Các biện pháp phòng thủ khác bao gồm những thứ như ngăn xếp bóng tối.

Tràn độ sâu ngăn xếp
--------------------

Một cuộc tấn công ít được hiểu rõ hơn là sử dụng một lỗi kích hoạt
kernel sử dụng bộ nhớ ngăn xếp với các lệnh gọi hàm sâu hoặc ngăn xếp lớn
phân bổ. Với cuộc tấn công này, có thể viết vượt quá phần cuối của
không gian ngăn xếp được phân bổ trước của hạt nhân và vào các cấu trúc nhạy cảm. Hai
những thay đổi quan trọng cần được thực hiện để bảo vệ tốt hơn: di chuyển
cấu trúc thread_info nhạy cảm ở nơi khác và thêm bộ nhớ bị lỗi
lỗ ở dưới cùng của ngăn xếp để hứng những lần tràn này.

Tính toàn vẹn của bộ nhớ heap
---------------------

Các cấu trúc được sử dụng để theo dõi danh sách không có đống dữ liệu có thể được kiểm tra độ chính xác trong quá trình
phân bổ và giải phóng để đảm bảo chúng không bị sử dụng để thao túng
vùng nhớ khác.

Tính toàn vẹn của bộ đếm
-----------------

Nhiều nơi trong kernel sử dụng bộ đếm nguyên tử để theo dõi các tham chiếu đối tượng
hoặc thực hiện quản lý trọn đời tương tự. Khi những bộ đếm này có thể được thực hiện
để bọc (trên hoặc dưới) điều này theo truyền thống sẽ thể hiện khả năng sử dụng sau này
lỗ hổng. Bằng cách bẫy lớp bọc nguyên tử, loại lỗi này sẽ biến mất.

Phát hiện tràn tính toán kích thước
-----------------------------------

Tương tự như tràn bộ đếm, tràn số nguyên (thường là tính toán kích thước)
cần được phát hiện trong thời gian chạy để tiêu diệt loại lỗi này.
theo truyền thống dẫn đến khả năng ghi qua phần cuối của bộ đệm kernel.


Phòng thủ xác suất
======================

Mặc dù nhiều biện pháp bảo vệ có thể được coi là mang tính quyết định (ví dụ: chỉ đọc
không thể ghi vào bộ nhớ), một số biện pháp bảo vệ chỉ cung cấp dữ liệu thống kê
phòng thủ, trong đó một cuộc tấn công phải thu thập đủ thông tin về một
hệ thống chạy để vượt qua phòng thủ. Mặc dù không hoàn hảo nhưng những điều này làm được
cung cấp sự phòng thủ có ý nghĩa.

Chim hoàng yến, chói mắt và những bí mật khác
-------------------------------------

Cần lưu ý rằng những thứ như ngăn xếp chim hoàng yến đã thảo luận trước đó
là những biện pháp phòng vệ thống kê về mặt kỹ thuật, vì chúng dựa vào một giá trị bí mật,
và những giá trị đó có thể được khám phá thông qua việc tiếp xúc thông tin
lỗ hổng.

Làm mờ các giá trị theo nghĩa đen đối với những thứ như JIT, trong đó tệp thực thi
nội dung có thể được kiểm soát một phần bởi không gian người dùng, cần một nội dung tương tự
giá trị bí mật.

Điều quan trọng là các giá trị bí mật được sử dụng phải tách biệt (ví dụ:
chim hoàng yến khác nhau trên mỗi ngăn xếp) và entropy cao (ví dụ: thực tế là RNG
đang làm việc?) để tối đa hóa thành công của họ.

Ngẫu nhiên hóa bố cục không gian địa chỉ hạt nhân (KASLR)
-------------------------------------------------

Vì vị trí của bộ nhớ kernel hầu như luôn là công cụ
thực hiện một cuộc tấn công thành công, làm cho vị trí không xác định được
làm tăng độ khó của việc khai thác. (Lưu ý rằng điều này lần lượt làm cho
giá trị của việc tiếp xúc với thông tin cao hơn vì chúng có thể được sử dụng để
khám phá các vị trí bộ nhớ mong muốn.)

Cơ sở văn bản và mô-đun
~~~~~~~~~~~~~~~~~~~~

Bằng cách định vị lại địa chỉ cơ sở vật lý và ảo của kernel tại
thời gian khởi động (ZZ0000ZZ), các cuộc tấn công cần mã kernel sẽ
thất vọng. Ngoài ra, bù đắp địa chỉ cơ sở tải mô-đun
có nghĩa là ngay cả các hệ thống tải cùng một bộ mô-đun trong cùng một
đặt hàng mỗi lần khởi động sẽ không chia sẻ địa chỉ cơ sở chung với phần còn lại của
văn bản hạt nhân.

Đế ngăn xếp
~~~~~~~~~~

Nếu địa chỉ cơ sở của ngăn xếp kernel không giống nhau giữa các tiến trình,
hoặc thậm chí không giống nhau giữa các tòa nhà cao tầng, các mục tiêu trên hoặc ngoài ngăn xếp
trở nên khó khăn hơn để xác định vị trí.

Cơ sở bộ nhớ động
~~~~~~~~~~~~~~~~~~~

Phần lớn bộ nhớ động của kernel (ví dụ: kmalloc, vmalloc, v.v.) kết thúc
có tính quyết định tương đối trong cách bố trí do thứ tự khởi động sớm
các khởi tạo. Nếu địa chỉ cơ sở của các khu vực này không giống nhau
giữa các lần khởi động, việc nhắm mục tiêu vào chúng thật khó chịu, đòi hỏi thông tin
tiếp xúc cụ thể cho khu vực.

Bố trí kết cấu
~~~~~~~~~~~~~~~~

Bằng cách thực hiện ngẫu nhiên bố cục của các thông tin nhạy cảm trên mỗi bản dựng
cấu trúc, các cuộc tấn công phải được điều chỉnh theo các bản dựng kernel đã biết hoặc để lộ
đủ bộ nhớ kernel để xác định bố cục cấu trúc trước khi thao tác
họ.


Ngăn chặn việc lộ thông tin
================================

Vì vị trí của các công trình nhạy cảm là mục tiêu chính cho
các cuộc tấn công, điều quan trọng là phải bảo vệ khỏi bị lộ cả bộ nhớ kernel
địa chỉ và nội dung bộ nhớ kernel (vì chúng có thể chứa kernel
địa chỉ hoặc những thứ nhạy cảm khác như giá trị canary).

Địa chỉ hạt nhân
----------------

In địa chỉ kernel vào không gian người dùng làm rò rỉ thông tin nhạy cảm về
bố trí bộ nhớ hạt nhân. Cần thận trọng khi sử dụng bất kỳ bản in nào
công cụ xác định in địa chỉ thô, hiện tại là %px, %p[ad], (và %p[sSb]
trong một số trường hợp nhất định [*]).  Bất kỳ tệp nào được ghi bằng cách sử dụng một trong những tệp này
các thông số xác định chỉ có thể được đọc bởi các quy trình đặc quyền.

Hạt nhân 4.14 trở lên in địa chỉ thô bằng %p. Kể từ 4.15-rc1
các địa chỉ được in bằng mã xác định %p sẽ được băm trước khi in.

[*] Nếu KALLSYMS được bật và tra cứu biểu tượng không thành công, địa chỉ thô là
được in. Nếu KALLSYMS không được bật, địa chỉ thô sẽ được in.

Số nhận dạng duy nhất
------------------

Địa chỉ bộ nhớ hạt nhân không bao giờ được sử dụng làm mã định danh tiếp xúc với
không gian người dùng. Thay vào đó, hãy sử dụng bộ đếm nguyên tử, idr hoặc các bộ đếm duy nhất tương tự.
định danh.

Khởi tạo bộ nhớ
---------------------

Bộ nhớ được sao chép vào không gian người dùng phải luôn được khởi tạo đầy đủ. Nếu không
rõ ràng là memset(), điều này sẽ yêu cầu thay đổi trình biên dịch để thực hiện
chắc chắn các lỗ cấu trúc được xóa.

Ngộ độc trí nhớ
----------------

Khi giải phóng bộ nhớ, tốt nhất nên đầu độc nội dung, tránh sử dụng lại
các cuộc tấn công dựa vào nội dung cũ của bộ nhớ. Ví dụ: xóa ngăn xếp trên một
trả về syscall (ZZ0000ZZ), xóa bộ nhớ heap trên
miễn phí. Điều này làm nản lòng nhiều cuộc tấn công biến đổi chưa được khởi tạo, ngăn xếp nội dung
hiển thị, hiển thị nội dung đống và các cuộc tấn công sử dụng sau khi miễn phí.

Theo dõi điểm đến
--------------------

Để giúp tiêu diệt các lớp lỗi dẫn đến địa chỉ kernel bị
được ghi vào không gian người dùng, đích của việc ghi cần được theo dõi. Nếu
bộ đệm được dành cho không gian người dùng (ví dụ: các tệp ZZ0000ZZ được hỗ trợ bởi seq_file),
nó sẽ tự động kiểm duyệt các giá trị nhạy cảm.
