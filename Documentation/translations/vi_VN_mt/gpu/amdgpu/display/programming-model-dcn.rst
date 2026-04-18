.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/programming-model-dcn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Mô hình lập trình DC
======================

Trong các trang ZZ0000ZZ và ZZ0001ZZ, bạn đã tìm hiểu về các thành phần phần cứng và cách chúng
tương tác với nhau. Trên trang này, tiêu điểm được chuyển sang màn hình
kiến trúc mã. Do đó, thật hợp lý khi nhắc nhở người đọc rằng mã
trong DC được chia sẻ với các hệ điều hành khác; vì lý do này, DC cung cấp một bộ
trừu tượng hóa và hoạt động để kết nối các API khác nhau với phần cứng
cấu hình. Xem DC dưới dạng dịch vụ có sẵn cho Trình quản lý hiển thị (amdgpu_dm)
để truy cập và định cấu hình phần cứng DCN/DCE (DCE cũng là một phần của DC, nhưng đối với
vì đơn giản, tài liệu này chỉ kiểm tra DCN).

.. note::
   For this page, we will use the term GPU to refers to dGPU and APU.

Tổng quan
=========

Từ góc độ phần cứng màn hình, có thể hy vọng rằng nếu một
vấn đề đã được xác định rõ ràng thì nó có thể sẽ được triển khai ở cấp độ phần cứng.
Mặt khác, khi có nhiều cách để đạt được điều gì đó mà không cần
phạm vi được xác định rất rõ ràng, giải pháp thường được triển khai như một chính sách tại
cấp độ DC. Nói cách khác, một số chính sách được xác định trong lõi DC
(quản lý tài nguyên, tối ưu hóa năng lượng, chất lượng hình ảnh, v.v.) và các tính năng khác
được triển khai trong phần cứng được kích hoạt thông qua cấu hình DC.

Về mặt quản lý phần cứng, DCN có nhiều phiên bản của cùng một khối
(ví dụ: HUBP, DPP, MPC, v.v.) và trong quá trình thực thi trình điều khiển, nó có thể
cần thiết để sử dụng một số trường hợp này. Cốt lõi có chính sách phù hợp cho
xử lý các trường hợp đó. Về quản lý tài nguyên, mục tiêu của DC là
khá đơn giản: giảm thiểu việc xáo trộn phần cứng khi trình điều khiển thực hiện một số
hành động. Khi trạng thái thay đổi từ A sang B, quá trình chuyển đổi được coi là
điều khiển dễ dàng hơn nếu tài nguyên phần cứng vẫn được sử dụng cho cùng một bộ
đối tượng điều khiển. Thông thường, việc thêm và xóa tài nguyên vào ZZ0000ZZ (thêm
chi tiết bên dưới) không phải là vấn đề; tuy nhiên, việc di chuyển tài nguyên từ một ZZ0001ZZ
sang cái khác nên tránh.

Một lĩnh vực ảnh hưởng khác đối với DC là tối ưu hóa năng lượng, có vô số
khả năng sắp xếp. Theo một cách nào đó, chỉ cần hiển thị một hình ảnh qua DCN
tương đối đơn giản; tuy nhiên, thể hiện nó với sức mạnh tốt nhất
dấu chân được mong muốn hơn, nhưng nó có nhiều thách thức liên quan.
Thật không may, không có cách phân tích đơn giản nào để xác định liệu một
cấu hình là tốt nhất cho bối cảnh do có sự đa dạng to lớn của
các biến liên quan đến vấn đề này (ví dụ: nhiều phần cứng DCN/DCE khác nhau
phiên bản, cấu hình hiển thị khác nhau, v.v.) vì lý do này DC
triển khai một thư viện chuyên dụng để thử một số cấu hình và xác minh xem nó có
có thể hỗ trợ nó hay không. Loại chính sách này cực kỳ phức tạp đối với
tạo và duy trì, đồng thời trình điều khiển amdgpu dựa vào Thư viện Chế độ Hiển thị (DML) để
đưa ra những quyết định tốt nhất.

Tóm lại, DC phải giải quyết sự phức tạp của việc xử lý nhiều tình huống và
xác định các chính sách để quản lý chúng. Tất cả những thông tin trên được chuyển tới
cung cấp cho người đọc một số ý tưởng về sự phức tạp của việc điều khiển màn hình từ
góc nhìn của người lái xe. Trang này hy vọng sẽ cho phép người đọc điều hướng tốt hơn
qua mã hiển thị amdgpu.

Tổng quan về kiến ​​trúc trình điều khiển hiển thị
==================================================

Sơ đồ bên dưới cung cấp cái nhìn tổng quan về kiến ​​trúc trình điều khiển hiển thị;
lưu ý rằng nó minh họa các lớp phần mềm được DC áp dụng:

.. kernel-figure:: dc-components.svg

Lớp đầu tiên của sơ đồ là DC API cấp cao được biểu thị bằng
Tệp ZZ0000ZZ; bên dưới là hai khối lớn được đại diện bởi Core và Link. Tiếp theo là
khối cấu hình phần cứng; tập tin chính mô tả nó là
the`hw_sequencer.h`, nơi có thể tìm thấy việc triển khai các lệnh gọi lại trong
thư mục trình sắp xếp phần cứng. Gần cuối, bạn có thể thấy cấp độ khối
API (ZZ0002ZZ), đại diện cho mỗi khối cấp thấp DCN, chẳng hạn như HUBP,
DPP, MPC, OPTC, v.v. Lưu ý ở phía bên trái của sơ đồ rằng chúng ta có một
tập hợp các lớp khác nhau thể hiện sự tương tác với DMUB
vi điều khiển.

Đối tượng cơ bản
----------------

Sơ đồ dưới đây phác thảo các đối tượng hiển thị cơ bản. Đặc biệt, trả
chú ý đến tên trong các hộp vì chúng đại diện cho cấu trúc dữ liệu trong
người lái xe:

.. kernel-figure:: dc-arch-overview.svg

Hãy bắt đầu với khối trung tâm trong hình ảnh, ZZ0000ZZ. Cấu trúc ZZ0001ZZ là
được khởi tạo cho mỗi GPU; ví dụ: một GPU có một phiên bản ZZ0002ZZ, hai GPU có
hai phiên bản ZZ0003ZZ, v.v. Nói cách khác, chúng ta có một 'dc' cho mỗi 'amdgpu'
ví dụ. Ở một khía cạnh nào đó, đối tượng này hoạt động giống như mẫu ZZ0004ZZ.

Sau khối ZZ0000ZZ trong sơ đồ, bạn có thể thấy thành phần ZZ0001ZZ,
là một sự trừu tượng hóa mức độ thấp cho trình kết nối. Một khía cạnh thú vị của
hình ảnh là các đầu nối không phải là một phần của khối DCN; chúng được xác định bởi
nền tảng/board chứ không phải bởi SoC. Cấu trúc ZZ0002ZZ là dữ liệu cấp cao
vùng chứa thông tin như bồn chứa được kết nối, trạng thái kết nối, tín hiệu
các loại, v.v. Sau ZZ0003ZZ, có ZZ0004ZZ, là đối tượng
đại diện cho màn hình được kết nối.

.. note::
   For historical reasons, we used the name `dc_link`, which gives the
   wrong impression that this abstraction only deals with physical connections
   that the developer can easily manipulate. However, this also covers
   connections like eDP or cases where the output is connected to other devices.

Có hai cấu trúc không được biểu diễn trong sơ đồ vì chúng
được xây dựng trên trang tổng quan về DCN (kiểm tra sơ đồ khối DCN ZZ0000ZZ); tuy nhiên, nó đáng để mang lại cho việc này
tổng quan đó là ZZ0001ZZ và ZZ0002ZZ. ZZ0003ZZ lưu trữ nhiều
các thuộc tính liên quan đến việc truyền dữ liệu, nhưng quan trọng nhất là nó
đại diện cho luồng dữ liệu từ đầu nối đến màn hình. Tiếp theo chúng ta có
ZZ0004ZZ, đại diện cho trạng thái logic trong phần cứng vào thời điểm hiện tại;
ZZ0005ZZ bao gồm ZZ0006ZZ và ZZ0007ZZ. ZZ0008ZZ là DC
phiên bản ZZ0009ZZ và đại diện cho đường ống sau trộn.

Nói về cấu trúc dữ liệu ZZ0000ZZ (phần đầu tiên của sơ đồ), bạn có thể
hãy nghĩ về nó như một sự trừu tượng tương tự như ZZ0001ZZ đại diện cho
phần trộn trước của đường ống. Hình ảnh này có lẽ đã được xử lý bởi GFX
và sẵn sàng được tổng hợp theo ZZ0002ZZ. Thông thường người lái xe có thể
có một hoặc nhiều ZZ0003ZZ được kết nối với cùng một ZZ0004ZZ, xác định một
thành phần ở cấp độ DC.

Hoạt động cơ bản
----------------

Bây giờ chúng ta đã đề cập đến các đối tượng cơ bản, đã đến lúc xem xét một số đối tượng
hoạt động phần cứng/phần mềm cơ bản. Hãy bắt đầu với ZZ0000ZZ
chức năng hoạt động trực tiếp với cấu trúc dữ liệu ZZ0001ZZ; chức năng này hoạt động
giống như một nhà xây dựng chịu trách nhiệm khởi tạo phần mềm cơ bản và
chuẩn bị kích hoạt các phần khác của API. Điều quan trọng là phải làm nổi bật
rằng thao tác này không chạm vào bất kỳ cấu hình phần cứng nào; nó chỉ là một
khởi tạo phần mềm.

Tiếp theo, chúng ta có ZZ0000ZZ, cũng dựa trên dữ liệu ZZ0001ZZ
struct. Chức năng chính của nó là đưa phần cứng vào trạng thái hợp lệ. Nó có giá trị
nhấn mạnh rằng phần cứng có thể khởi chạy ở trạng thái không xác định và đó là
yêu cầu đặt nó ở trạng thái hợp lệ; chức năng này có nhiều cuộc gọi lại
để khởi tạo dành riêng cho phần cứng, trong khi ZZ0002ZZ thực hiện
khởi tạo phần cứng và là điểm đầu tiên chúng ta chạm vào phần cứng.

ZZ0000ZZ là một hoạt động phụ thuộc vào dữ liệu ZZ0001ZZ
cấu trúc. Hàm này truy xuất và liệt kê tất cả ZZ0002ZZ có sẵn
trên thiết bị; điều này là bắt buộc vì thông tin này không phải là một phần của SoC
định nghĩa nhưng phụ thuộc vào cấu hình bảng. Ngay sau khi ZZ0003ZZ được
được khởi tạo, sẽ rất hữu ích nếu tìm hiểu xem có bất kỳ cái nào trong số chúng đã được kết nối với
màn hình bằng cách sử dụng chức năng ZZ0004ZZ. Sau khi số liệu tài xế
out nếu bất kỳ màn hình nào được kết nối với thiết bị, giai đoạn thử thách sẽ bắt đầu:
cấu hình màn hình để hiển thị một cái gì đó. Tuy nhiên, đối phó với lý tưởng
cấu hình không phải là nhiệm vụ DC vì đây là Trình quản lý hiển thị (ZZ0005ZZ)
trách nhiệm mà đến lượt nó lại chịu trách nhiệm giải quyết vấn đề nguyên tử
cam kết. Giao diện duy nhất DC cung cấp cho giai đoạn cấu hình là
chức năng ZZ0006ZZ nhận thông tin cấu hình
và dựa vào đó xác nhận xem phần cứng có thể hỗ trợ nó hay không. Đó là
điều quan trọng cần nói thêm là ngay cả khi màn hình hỗ trợ một số cấu hình cụ thể,
điều đó không có nghĩa là phần cứng DCN có thể hỗ trợ nó.

Sau khi DM và DC đồng ý về cấu hình, cấu hình luồng
giai đoạn bắt đầu. Tác vụ này kích hoạt một hoặc nhiều ZZ0000ZZ ở giai đoạn này và trong
trường hợp tốt nhất, bạn có thể bật màn hình bằng nút màu đen
màn hình (nó chưa hiển thị gì cả vì nó không có bất kỳ mặt phẳng nào
liên quan đến nó). Bước cuối cùng sẽ là gọi
ZZ0001ZZ sẽ thêm hoặc xóa các mặt phẳng.

