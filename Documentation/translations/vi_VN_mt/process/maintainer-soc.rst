.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-soc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Hệ thống con SoC
================

Tổng quan
--------

Hệ thống con SoC là nơi tổng hợp mã dành riêng cho SoC.
Các thành phần chính của hệ thống con là:

* cây thiết bị (DTS) cho ARM 32 & 64-bit và RISC-V
* Tệp bảng ARM 32-bit (arch/arm/mach*)
* Cấu hình giải mã ARM 32- & 64-bit
* Trình điều khiển dành riêng cho SoC trên các kiến trúc, đặc biệt là cho 32- & 64-bit
  ARM, RISC-V và Loongarch

Những "trình điều khiển dành riêng cho SoC" này không bao gồm các trình điều khiển xung nhịp, GPIO, v.v. có
người bảo trì cấp cao khác. Thư mục driver/soc/ thường có nghĩa là
dành cho các trình điều khiển bên trong kernel được các trình điều khiển khác sử dụng để cung cấp SoC-
chức năng cụ thể như xác định bản sửa đổi SoC hoặc giao tiếp với
các miền quyền lực.

Hệ thống con SoC cũng đóng vai trò là vị trí trung gian cho những thay đổi đối với
trình điều khiển/bus, trình điều khiển/chương trình cơ sở, trình điều khiển/đặt lại và trình điều khiển/bộ nhớ.  Việc bổ sung
các nền tảng mới hoặc việc loại bỏ các nền tảng hiện có thường được thực hiện thông qua SoC
cây như một nhánh chuyên dụng bao gồm nhiều hệ thống con.

Cây SoC chính được đặt trên git.kernel.org:
  ZZ0000ZZ

Người bảo trì
-----------

Rõ ràng đây là một loạt chủ đề khá rộng mà không một ai, thậm chí
một nhóm nhỏ người có khả năng duy trì.  Thay vào đó, hệ thống con SoC
bao gồm nhiều người bảo trì phụ (người bảo trì nền tảng), mỗi người đảm nhiệm
nền tảng riêng lẻ và thư mục con trình điều khiển.
Về vấn đề này, "nền tảng" thường đề cập đến một loạt SoC từ một
nhà cung cấp, chẳng hạn như dòng Tegra SoC của Nvidia.  Nhiều người bảo trì phụ hoạt động
ở cấp độ nhà cung cấp, chịu trách nhiệm về nhiều dòng sản phẩm.  Vì nhiều lý do,
bao gồm cả việc mua lại/các đơn vị kinh doanh khác nhau trong một công ty, mọi thứ đều khác nhau
đáng kể ở đây.  Các nhà bảo trì phụ khác nhau được ghi lại trong
Tệp MAINTAINERS.

Hầu hết những người bảo trì phụ này đều có cây riêng để họ thực hiện các bản vá,
gửi yêu cầu kéo đến cây SoC chính.  Những cây này thường, nhưng không
luôn luôn, được liệt kê trong MAINTAINERS.

Tuy nhiên, cây SoC không phải là vị trí dành cho mã dành riêng cho kiến trúc
những thay đổi.  Mỗi kiến trúc có người bảo trì riêng chịu trách nhiệm về
chi tiết kiến trúc, lỗi CPU và những thứ tương tự.

Gửi bản vá cho SoC nhất định
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tất cả các bản vá liên quan đến nền tảng điển hình phải được gửi qua các nhà bảo trì phụ SoC
(người bảo trì dành riêng cho nền tảng).  Điều này cũng bao gồm những thay đổi đối với mỗi nền tảng hoặc
các cấu hình mặc định được chia sẻ. Lưu ý rằng scripts/get_maintainer.pl có thể không cung cấp
địa chỉ chính xác cho defconfig được chia sẻ, vì vậy hãy bỏ qua đầu ra của nó và thực hiện theo cách thủ công
tạo danh sách CC dựa trên tệp MAINTAINERS hoặc sử dụng cái gì đó như
ZZ0000ZZ).

Gửi bản vá cho nhà bảo trì SoC chính
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn chỉ có thể liên hệ với những người bảo trì SoC chính qua bí danh soc@kernel.org trong
trường hợp sau:

1. Không có người bảo trì dành riêng cho nền tảng.

2. Những người bảo trì dành riêng cho nền tảng không phản hồi.

3. Giới thiệu nền tảng SoC hoàn toàn mới.  Công việc SoC mới như vậy nên được gửi
   đầu tiên trong danh sách gửi thư chung, được chỉ ra bởi scripts/get_maintainer.pl, dành cho
   cộng đồng xem xét.  Sau khi được cộng đồng đánh giá tích cực, tác phẩm sẽ được gửi đến
   soc@kernel.org trong một bản vá chứa mục nhập Arch/foo/Kconfig mới, DTS
   tệp, mục nhập tệp MAINTAINERS và trình điều khiển ban đầu tùy chọn với
   Các ràng buộc của cây thiết bị.  Mục nhập tệp MAINTAINERS sẽ liệt kê các mục mới
   những người bảo trì nền tảng cụ thể, những người sẽ chịu trách nhiệm xử lý
   các bản vá cho nền tảng kể từ bây giờ.

Lưu ý rằng soc@kernel.org thường không phải là nơi để thảo luận về các bản vá,
do đó công việc được gửi đến địa chỉ này phải được coi là chấp nhận được bởi
cộng đồng.

Thông tin dành cho Người bảo trì phụ (mới)
------------------------------------

Khi các nền tảng mới xuất hiện, chúng thường mang theo những người bảo trì phụ mới,
nhiều người trong số họ làm việc cho nhà cung cấp silicon và có thể không quen thuộc với
quá trình.

Độ ổn định của Devicetree ABI
~~~~~~~~~~~~~~~~~~~~~~~~

Có lẽ một trong những điều quan trọng nhất cần nhấn mạnh là các ràng buộc dt
ghi lại ABI giữa cây thiết bị và hạt nhân.
Vui lòng đọc Tài liệu/devicetree/binds/ABI.rst.

Nếu những thay đổi đang được thực hiện đối với DTS không tương thích với phiên bản cũ
hạt nhân, bản vá DTS không nên được áp dụng cho đến khi có trình điều khiển hoặc
thời gian thích hợp sau này.  Quan trọng nhất, mọi thay đổi không tương thích đều phải được
được chỉ ra rõ ràng trong phần mô tả bản vá và yêu cầu kéo, cùng với
tác động dự kiến đối với người dùng hiện tại, chẳng hạn như bộ nạp khởi động hoặc các hệ điều hành khác
hệ thống.

Phụ thuộc nhánh tài xế
~~~~~~~~~~~~~~~~~~~~~~~~~~

Một vấn đề thường gặp là đồng bộ hóa các thay đổi giữa trình điều khiển thiết bị và cây thiết bị
tập tin. Ngay cả khi một thay đổi tương thích theo cả hai hướng, điều này có thể yêu cầu
điều phối cách các thay đổi được hợp nhất thông qua các cây duy trì khác nhau.

Thông thường nhánh bao gồm thay đổi trình điều khiển cũng sẽ bao gồm
thay đổi tương ứng với mô tả ràng buộc của cây thiết bị, để đảm bảo chúng
trên thực tế là tương thích.  Điều này có nghĩa là nhánh cây thiết bị cuối cùng có thể gây ra
cảnh báo trong bước ZZ0000ZZ.  Nếu sự thay đổi của cây thiết bị phụ thuộc vào
thiếu phần bổ sung cho tệp tiêu đề trong include/dt-binds/, nó sẽ không thực hiện được
Bước ZZ0001ZZ và không được hợp nhất.

Có nhiều cách để giải quyết vấn đề này:

* Tránh xác định macro tùy chỉnh trong include/dt-binds/ cho các hằng số phần cứng
  có thể được lấy từ biểu dữ liệu -- macro liên kết trong tệp tiêu đề sẽ
  chỉ được sử dụng như là phương sách cuối cùng nếu không có cách tự nhiên nào để xác định ràng buộc

* Sử dụng các giá trị bằng chữ trong tệp devicetree thay cho macro ngay cả khi
  tiêu đề là bắt buộc và thay đổi chúng thành đại diện được đặt tên trong một
  bản phát hành sau

* Trì hoãn các thay đổi của cây thiết bị thành bản phát hành sau khi liên kết và trình điều khiển có
  đã được sáp nhập rồi

* Thay đổi các ràng buộc trong một nhánh bất biến được chia sẻ được sử dụng làm cơ sở cho
  cả trình điều khiển đều thay đổi và cây thiết bị đều thay đổi

* Thêm các định nghĩa trùng lặp trong tệp thiết bị được bảo vệ bởi phần #ifndef,
  loại bỏ chúng trong bản phát hành sau

Quy ước đặt tên cây thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sơ đồ đặt tên chung cho các tập tin devicetree như sau.  Các khía cạnh của một
nền tảng được đặt ở cấp độ SoC, như lõi CPU, được chứa trong một tệp
có tên $soc.dtsi, ví dụ: jh7100.dtsi.  Chi tiết tích hợp, sẽ thay đổi
từ bảng này sang bảng khác, được mô tả trong $soc-$board.dts.  Một ví dụ về điều này là
jh7100-beaglev-starlight.dts.  Thông thường nhiều bảng là những biến thể của một chủ đề, và
thường có các tệp trung gian, chẳng hạn như jh7100-common.dtsi, nằm ở vị trí
giữa các tệp $soc.dtsi và $soc-$board.dts, chứa các mô tả về
phần cứng thông thường.

Một số nền tảng cũng có Hệ thống trên Mô-đun, chứa SoC, sau đó được
tích hợp vào nhiều bảng khác nhau. Đối với các nền tảng này, $soc-$som.dtsi
và $soc-$som-$board.dts là điển hình.

Các thư mục thường được đặt theo tên của nhà cung cấp SoC tại thời điểm nó được phát hành.
đưa vào, dẫn đến một số tên thư mục lịch sử trong cây.

Xác thực tập tin Devicetree
~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ có thể được sử dụng để xác thực rằng các tệp thiết bị đều tuân thủ
với các ràng buộc dt mô tả ABI.  Hãy đọc phần
"Đang chạy kiểm tra" Documentation/devicetree/binds/writing-schema.rst cho
thêm thông tin về việc xác nhận của cây thiết bị.

Đối với các nền tảng mới hoặc bổ sung cho nền tảng hiện có, ZZ0000ZZ không nên
thêm bất kỳ cảnh báo mới nào.  Đối với RISC-V và Samsung SoC, ZZ0001ZZ là
bắt buộc không thêm bất kỳ cảnh báo mới nào.
Nếu có bất kỳ nghi ngờ nào về sự thay đổi của cây thiết bị, hãy liên hệ với cây thiết bị
người bảo trì.

Chi nhánh và yêu cầu kéo
~~~~~~~~~~~~~~~~~~~~~~~~~~

Giống như cây SoC chính có nhiều nhánh, người ta mong đợi rằng
những người bảo trì phụ cũng sẽ làm như vậy. Các thay đổi về trình điều khiển, defconfig và cây thiết bị sẽ
tất cả đều được chia thành các nhánh riêng biệt và xuất hiện trong các yêu cầu kéo riêng biệt tới
Người bảo trì SoC.  Mỗi nhánh nên có thể sử dụng riêng và tránh
hồi quy bắt nguồn từ sự phụ thuộc vào các nhánh khác.

Một số bản vá lỗi cũng có thể được gửi dưới dạng email riêng biệt tới soc@kernel.org,
được nhóm vào cùng loại.

Nếu những thay đổi không phù hợp với các mẫu thông thường, có thể có thêm
các nhánh cấp cao nhất, ví dụ: để làm lại trên toàn cây hoặc bổ sung SoC mới
nền tảng bao gồm các tập tin dts và trình điều khiển.

Các chi nhánh có nhiều thay đổi có thể được hưởng lợi từ việc chia thành các nhánh riêng biệt
các nhánh chủ đề, ngay cả khi cuối cùng chúng được sáp nhập vào cùng một nhánh của
Cây SoC.  Một ví dụ ở đây sẽ là một nhánh dành cho các bản sửa lỗi cảnh báo của devicetree, một nhánh
để làm lại và một cho bảng mới được thêm vào.

Một cách phổ biến khác để phân chia các thay đổi là gửi yêu cầu kéo sớm với
phần lớn các thay đổi tại một số điểm giữa RC1 và RC4, tiếp theo là một
hoặc nhiều yêu cầu kéo nhỏ hơn vào cuối chu kỳ có thể thêm vào muộn
những thay đổi hoặc giải quyết các vấn đề được xác định trong khi thử nghiệm bộ đầu tiên.

Mặc dù không có thời gian giới hạn cho các yêu cầu kéo muộn nhưng nó chỉ hữu ích khi gửi
các nhánh nhỏ khi thời gian đến gần cửa sổ hợp nhất.

Các yêu cầu sửa lỗi cho bản phát hành hiện tại có thể được gửi bất cứ lúc nào, nhưng
một lần nữa có nhiều nhánh nhỏ hơn sẽ tốt hơn là cố gắng kết hợp quá nhiều
các bản vá thành một yêu cầu kéo.

Dòng chủ đề của yêu cầu kéo phải bắt đầu bằng "[GIT PULL]" và được thực hiện bằng cách sử dụng
một thẻ đã ký, chứ không phải là một nhánh.  Thẻ này phải chứa một mô tả ngắn
tóm tắt những thay đổi trong yêu cầu kéo.  Để biết thêm chi tiết về việc gửi kéo
yêu cầu, vui lòng xem Tài liệu/người bảo trì/pull-requests.rst.