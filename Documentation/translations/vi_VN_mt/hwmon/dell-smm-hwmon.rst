.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/dell-smm-hwmon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển hạt nhân dell-smm-hwmon
============================

:Bản quyền: ZZ0000ZZ 2002-2005 Massimo Dal Zotto <dz@debian.org>
:Bản quyền: ZZ0001ZZ 2019 Giovanni Mascellani <gio@debian.org>

Sự miêu tả
-----------

Trên nhiều máy tính xách tay Dell, Chế độ quản lý hệ thống (SMM) BIOS có thể được
truy vấn trạng thái của quạt và cảm biến nhiệt độ.  Không gian người dùng
các tiện ích như ZZ0000ZZ có thể được sử dụng để trả về kết quả đọc. các
bộ không gian người dùng ZZ0002ZZ cũng có thể được sử dụng để đọc các cảm biến và
tự động điều chỉnh tốc độ quạt (xin lưu ý rằng nó hiện đang sử dụng
giao diện ZZ0001ZZ không được dùng nữa).

__ ZZ0000ZZ

Giao diện ZZ0000ZZ
-------------------

Cảm biến nhiệt độ và quạt có thể được truy vấn và thiết lập thông qua tiêu chuẩn
Giao diện ZZ0000ZZ trên ZZ0001ZZ, theo thư mục
ZZ0002ZZ để biết giá trị nào đó của ZZ0003ZZ (tìm kiếm
ZZ0004ZZ sao cho ZZ0005ZZ có nội dung
ZZ0006ZZ). Một số thuộc tính khác có thể được đọc hoặc viết:

================================ ======= ============================================
Tên Perm Mô tả
================================ ======= ============================================
fan[1-4]_input RO Tốc độ quạt ở RPM.
fan[1-4]_label RO Nhãn quạt.
fan[1-4]_min RO Tốc độ quạt tối thiểu trong RPM
fan[1-4]_max RO Tốc độ quạt tối đa trong RPM
fan[1-4]_target RO Tốc độ quạt dự kiến trong RPM
pwm[1-4] RW Điều khiển chu kỳ hoạt động của quạt PWM.
pwm[1-4]_enable RW/WO Bật hoặc tắt quạt BIOS tự động
                                        điều khiển (không được hỗ trợ trên tất cả máy tính xách tay,
                                        xem bên dưới để biết chi tiết).
temp[1-10]_input RO Đọc nhiệt độ tính bằng mili độ
                                        độ C.
temp[1-10]_label RO Nhãn cảm biến nhiệt độ.
================================ ======= ============================================

Do tính chất của giao diện SMM, mỗi thuộc tính pwmX điều khiển
số fan X.

Bật/Tắt điều khiển quạt BIOS tự động
---------------------------------------------

Có hai phương pháp để bật/tắt điều khiển quạt BIOS tự động:

1. Các lệnh SMM riêng biệt để bật/tắt điều khiển quạt BIOS tự động cho tất cả các quạt.

2. Trạng thái quạt đặc biệt cho phép điều khiển quạt BIOS tự động cho từng quạt.

Trình điều khiển không thể phát hiện một cách đáng tin cậy phương pháp nào nên được sử dụng trên một thiết bị nhất định
thiết bị, vì vậy thay vào đó phương pháp phỏng đoán sau sẽ được sử dụng:

- sử dụng trạng thái quạt 3 để bật điều khiển quạt BIOS nếu trạng thái quạt tối đa
  người dùng có thể đặt nhỏ hơn 3 (cài đặt mặc định).

- sử dụng các lệnh SMM riêng biệt nếu thiết bị được đưa vào danh sách trắng để hỗ trợ chúng.

Khi sử dụng cách thứ nhất, mỗi quạt sẽ có một ZZ0000ZZ tiêu chuẩn
thuộc tính sysfs. Viết ZZ0001ZZ vào thuộc tính này sẽ vô hiệu hóa tính năng tự động
Điều khiển quạt BIOS cho quạt liên quan và đặt tốc độ tối đa. Kích hoạt
Bạn có thể thực hiện lại việc kiểm soát quạt BIOS bằng cách ghi ZZ0002ZZ vào thuộc tính này.
Đọc thuộc tính sysfs này sẽ trả về cài đặt hiện tại như được báo cáo bởi
phần cứng cơ bản.

Tuy nhiên, khi sử dụng phương pháp thứ hai, chỉ thuộc tính sysfs ZZ0000ZZ
sẽ có sẵn để bật/tắt điều khiển quạt BIOS tự động trên toàn cầu cho tất cả
người hâm mộ có sẵn trên một thiết bị nhất định. Ngoài ra, thuộc tính sysfs này chỉ ghi
vì không tồn tại lệnh SMM để đọc cài đặt điều khiển quạt hiện tại.

Nếu không có thuộc tính ZZ0000ZZ nào thì điều đó có nghĩa là trình điều khiển
không thể sử dụng phương pháp đầu tiên và mã SMM để bật và tắt tính năng tự động
Điều khiển quạt BIOS không nằm trong danh sách trắng cho thiết bị của bạn. Có thể các mã
hoạt động cho các máy tính xách tay khác thực sự cũng hoạt động cho máy tính xách tay của bạn hoặc bạn phải
khám phá mã mới.

Kiểm tra danh sách ZZ0001ZZ trong tập tin
ZZ0002ZZ trong cây hạt nhân: lần đầu tiên
bạn có thể thử thêm máy của mình và sử dụng mã đã biết
cặp. Nếu sau khi biên dịch lại kernel, bạn thấy ZZ0003ZZ
hiện diện và hoạt động (tức là bạn có thể điều khiển tốc độ quạt theo cách thủ công),
thì vui lòng gửi phát hiện của bạn dưới dạng bản vá kernel để những người dùng khác
có thể hưởng lợi từ nó. Xin vui lòng xem
ZZ0000ZZ
để biết thông tin về việc gửi bản vá.

Nếu không có mã nào hoạt động trên máy của bạn, bạn cần phải thực hiện một số
đang thăm dò, vì tiếc là Dell không xuất bản bảng dữ liệu cho
SMM của nó. Bạn có thể thử nghiệm mã trong ZZ0000ZZ để
thăm dò BIOS trên máy của bạn và khám phá các mã thích hợp.

__ ZZ0000ZZ

Xin nhắc lại, khi bạn tìm thấy mã mới, chúng tôi rất vui khi nhận được bản vá lỗi của bạn!

Giao diện ZZ0000ZZ
---------------------------

Trình điều khiển cũng xuất khẩu quạt dưới dạng thiết bị làm mát nhiệt với
ZZ0000ZZ được đặt thành ZZ0001ZZ. Điều này cho phép điều khiển quạt dễ dàng
sử dụng một trong các bộ điều chỉnh nhiệt.

Thông số mô-đun
-----------------

* lực: bool
                   Buộc tải mà không kiểm tra hỗ trợ
                   các mô hình. (mặc định: 0)

* bỏ qua_dmi:bool
                   Tiếp tục thăm dò phần cứng ngay cả khi dữ liệu DMI không
                   trận đấu. (mặc định: 0)

* bị hạn chế:bool
                   Chỉ cho phép điều khiển quạt đối với các quy trình bằng
                   Bộ khả năng hoặc quy trình chạy ZZ0000ZZ
                   với quyền root khi sử dụng ZZ0001ZZ cũ
                   giao diện. Trong trường hợp này người dùng bình thường sẽ có thể
                   để đọc nhiệt độ và trạng thái quạt nhưng không
                   điều khiển quạt.  Nếu sổ ghi chép của bạn được chia sẻ với
                   những người dùng khác và bạn không tin tưởng họ, bạn có thể muốn
                   để sử dụng tùy chọn này. (mặc định: 1, chỉ có sẵn
                   với ZZ0002ZZ)

* power_status: bool
                   Báo cáo trạng thái AC trong ZZ0000ZZ. (mặc định: 0,
                   chỉ khả dụng với ZZ0001ZZ)

* fan_mult:uint
                   Hệ số để nhân tốc độ quạt với. (mặc định:
                   tự động phát hiện)

* fan_max:uint
                   Tốc độ quạt có thể cấu hình tối đa. (mặc định:
                   tự động phát hiện)

Giao diện ZZ0000ZZ kế thừa
--------------------------

.. warning:: This interface is obsolete and deprecated and should not
             used in new applications. This interface is only
             available when kernel is compiled with option
             ``CONFIG_I8K``.

Thông tin được cung cấp bởi trình điều khiển kernel có thể được truy cập bởi
chỉ cần đọc tệp ZZ0000ZZ. Ví dụ::

$ mèo /proc/i8k
    1.0 A17 2J59L02 52 2 1 8040 6420 1 2

Các trường được đọc từ ZZ0000ZZ là::

1.0 A17 2J59L02 52 2 1 8040 6420 1 2
    ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
    ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ | +------- 10. trạng thái nút
    ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ +---------- 9. Trạng thái AC
    ZZ0013ZZ ZZ0014ZZ ZZ0015ZZ |    +-------------- 8. fan0 RPM
    ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ +------------------- 7. fan1 RPM
    ZZ0019ZZ ZZ0020ZZ | +------------------- 6. trạng thái fan0
    ZZ0021ZZ ZZ0022ZZ +-------------- 5. trạng thái fan1
    ZZ0023ZZ |       +-------------------------- 4. đọc nhiệt độ0 (Celsius)
    ZZ0024ZZ +----------------------------------- 3. Thẻ dịch vụ Dell (sau này được gọi là 'số sê-ri')
    |   +-------------------------------------- 2. Phiên bản BIOS
    +------------------------------------------ Phiên bản định dạng 1. /proc/i8k

Giá trị âm, ví dụ -22, cho biết BIOS không
trả về thông tin tương ứng. Điều này là bình thường đối với một số
mô hình/BIOS.

Vì lý do hiệu suất, ZZ0000ZZ không báo cáo theo mặc định
trạng thái AC do lệnh gọi SMM này mất nhiều thời gian để thực thi và
không thực sự cần thiết  Nếu bạn muốn xem trạng thái ac trong ZZ0001ZZ
bạn phải kích hoạt tùy chọn này một cách rõ ràng bằng cách chuyển
Tham số ZZ0002ZZ cho insmod. Nếu trạng thái AC không
có sẵn -1 được in thay thế.

Trình điều khiển cũng cung cấp giao diện ioctl có thể được sử dụng để
có được thông tin tương tự và để kiểm soát trạng thái quạt. ioctl
giao diện có thể được truy cập từ các chương trình C hoặc từ shell bằng cách sử dụng
tiện ích i8kctl. Xem file nguồn của ZZ0000ZZ để biết thêm
thông tin về cách sử dụng giao diện ioctl.

Giao diện SMM
-------------

.. warning:: The SMM interface was reverse-engineered by trial-and-error
             since Dell did not provide any Documentation,
             please keep that in mind.

Trình điều khiển sử dụng giao diện SMM để gửi lệnh đến hệ thống BIOS.
Giao diện này thường được sử dụng bởi chương trình chẩn đoán 32-bit của Dell hoặc
trên các mẫu máy tính xách tay mới hơn bằng công cụ chẩn đoán BIOS tích hợp sẵn.
SMM có thể bị treo ngắn khi mã BIOS mất quá nhiều thời gian để
thi hành.

Trình xử lý SMM bên trong hệ thống BIOS xem xét nội dung của
Các thanh ghi ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ.
Mỗi đăng ký có một mục đích đặc biệt:

======================================================
Mục đích đăng ký
======================================================
eax Giữ mã lệnh trước SMM,
                giữ kết quả đầu tiên sau SMM.
ebx Giữ các đối số.
ecx Không xác định, được đặt thành 0.
edx Giữ kết quả thứ hai sau SMM.
esi Không xác định, đặt thành 0.
edi Không xác định, đặt thành 0.
======================================================

Trình xử lý SMM có thể báo hiệu lỗi bằng một trong hai cách:

- thiết lập mười sáu bit thấp hơn của ZZ0000ZZ thành ZZ0001ZZ
- hoàn toàn không sửa đổi ZZ0002ZZ
- cài đặt cờ mang (chỉ giao diện SMM cũ)

Giao diện SMM kế thừa
--------------------

Khi sử dụng giao diện SMM cũ, SMM được kích hoạt bằng cách ghi byte có trọng số thấp nhất
của mã lệnh tới các ioport đặc biệt ZZ0000ZZ và ZZ0001ZZ. Giao diện này không
được mô tả bên trong các bảng ACPI và do đó chỉ có thể được phát hiện bằng cách đưa ra lệnh gọi SMM thử nghiệm.

Giao diện WMI SMM
-----------------

Trên các máy Dell hiện đại, các cuộc gọi SMM được thực hiện qua ACPI WMI:

::

Không gian tên #pragma("\\\\.\\root\\dcim\\sysman\\diagnostics")
 [WMI, Nhà cung cấp("Provider_DiagnosticsServices"), Động, Ngôn ngữ("MS\\0x409"),
  Mô tả("RunDellDiag"), guid("{F1DDEE52-063C-4784-A11E-8A06684B9B01}")]
 lớp LegacyDiags {
  [phím, đọc] chuỗi Tên phiên bản;
  [đọc] boolean Hoạt động;

[WmiMethodId(1), Đã triển khai, đọc, viết, Mô tả("Phương thức cũ")]
  void Thực thi([in, out] uint32 EaxLen, [in, out, WmiSizeIs("EaxLen") : ToInstance] uint8 EaxVal[],
               [vào, ra] uint32 EbxLen, [vào, ra, WmiSizeIs("EbxLen") : ToInstance] uint8 EbxVal[],
               [vào, ra] uint32 EcxLen, [vào, ra, WmiSizeIs("EcxLen") : ToInstance] uint8 EcxVal[],
               [vào, ra] uint32 EdxLen, [vào, ra, WmiSizeIs("EdxLen") : ToInstance] uint8 EdxVal[]);
 };

Một số máy chỉ hỗ trợ giao diện WMI SMM, trong khi một số máy hỗ trợ cả hai giao diện.
Trình điều khiển tự động phát hiện giao diện nào hiện diện và sẽ sử dụng giao diện WMI SMM
nếu không có giao diện SMM cũ. Giao diện WMI SMM thường chậm hơn giao diện
Giao diện SMM cũ vì các phương thức ACPI cần được gọi để kích hoạt SMM.

Mã lệnh SMM
-----------------

=============================================================================================
Mã lệnh Tên lệnh Mô tả
=============================================================================================
ZZ0000ZZ Nhận trạng thái phím Fn Trả về phím Fn được nhấn sau SMM:

- Bit thứ 9 trong ZZ0000ZZ biểu thị Tăng âm lượng
                                        - Bit thứ 10 trong ZZ0001ZZ biểu thị Giảm âm lượng
                                        - cả hai bit đều biểu thị Tắt âm lượng

ZZ0000ZZ Nhận trạng thái nguồn Trả về trạng thái nguồn hiện tại sau SMM:

- Bit thứ 1 trong ZZ0000ZZ biểu thị Đã kết nối pin
                                        - Bit thứ 3 trong ZZ0001ZZ biểu thị kết nối AC

ZZ0000ZZ Nhận trạng thái quạt Trả về trạng thái quạt hiện tại sau SMM:

- Byte đầu tiên trong ZZ0000ZZ chứa dòng điện
                                          trạng thái quạt (0 - 2 hoặc 3)

ZZ0000ZZ Đặt trạng thái quạt Đặt tốc độ quạt:

- Byte thứ 1 trong ZZ0000ZZ chứa số quạt
                                        - Byte thứ 2 trong ZZ0001ZZ chứa giá trị mong muốn
                                          trạng thái quạt (0 - 2 hoặc 3)

ZZ0000ZZ Nhận tốc độ quạt Trả về tốc độ quạt hiện tại trong RPM:

- Byte thứ 1 trong ZZ0000ZZ chứa số quạt
                                        - Từ đầu tiên trong ZZ0001ZZ chứa dòng điện
                                          tốc độ quạt trong RPM (sau SMM)

ZZ0000ZZ Lấy loại quạt Trả về loại quạt:

- Byte thứ 1 trong ZZ0000ZZ chứa số quạt
                                        - Byte đầu tiên trong ZZ0001ZZ chứa
                                          loại quạt (sau SMM):

- Bit thứ 5 biểu thị quạt gắn đế
                                          - 1 biểu thị quạt Bộ xử lý
                                          - 2 biểu thị quạt bo mạch chủ
                                          - 3 biểu thị Quạt video
                                          - 4 chỉ ra quạt cấp nguồn
                                          - 5 biểu thị quạt Chipset
                                          - 6 cho biết loại quạt khác

ZZ0000ZZ Nhận tốc độ quạt danh nghĩa Trả về RPM danh nghĩa ở mỗi trạng thái quạt:

- Byte thứ 1 trong ZZ0000ZZ chứa số quạt
                                        - Byte thứ 2 trong ZZ0001ZZ giữ trạng thái quạt
                                          đang được đề cập (0 - 2 hoặc 3)
                                        - Từ đầu tiên trong ZZ0002ZZ giữ danh nghĩa
                                          tốc độ quạt trong RPM (sau SMM)

ZZ0000ZZ Nhận dung sai tốc độ quạt Trả về dung sai tốc độ cho từng trạng thái quạt:

- Byte thứ 1 trong ZZ0000ZZ chứa số quạt
                                        - Byte thứ 2 trong ZZ0001ZZ giữ trạng thái quạt
                                          đang được đề cập (0 - 2 hoặc 3)
                                        - Byte thứ 1 trong ZZ0002ZZ trả về tốc độ
                                          khoan dung

ZZ0000ZZ Nhận nhiệt độ cảm biến Trả về nhiệt độ đo được:

- Byte thứ 1 trong ZZ0000ZZ chứa số cảm biến
                                        - Byte thứ 1 trong ZZ0001ZZ giữ giá trị đo được
                                          nhiệt độ (sau SMM)

ZZ0000ZZ Nhận loại cảm biến Trả về loại cảm biến:

- Byte thứ 1 trong ZZ0000ZZ chứa số cảm biến
                                        - Byte đầu tiên trong ZZ0001ZZ chứa
                                          loại nhiệt độ (sau SMM):

- 1 biểu thị cảm biến CPU
                                          - 2 cho biết cảm biến GPU
                                          - 3 cho biết cảm biến SODIMM
                                          - 4 cho biết loại cảm biến khác
                                          - 5 cho biết Cảm biến môi trường xung quanh
                                          - 6 cho biết loại cảm biến khác

ZZ0000ZZ Nhận chữ ký SMM Trả về chữ ký Dell nếu giao diện
                                        được hỗ trợ (sau SMM):

- ZZ0000ZZ giữ 1145651527
                                          (0x44494147 hoặc "DIAG")
                                        - ZZ0001ZZ giữ 1145392204
                                          (0x44454c4c hoặc "DELL")

ZZ0000ZZ Lấy chữ ký SMM Tương tự như ZZ0001ZZ, kiểm tra cả hai.
=============================================================================================

Có các lệnh bổ sung để kích hoạt (ZZ0000ZZ hoặc ZZ0001ZZ) và
vô hiệu hóa điều khiển tốc độ quạt tự động (ZZ0002ZZ hoặc ZZ0003ZZ).
Tuy nhiên, các lệnh này gây ra tác dụng phụ nghiêm trọng trên nhiều máy, vì vậy
chúng không được sử dụng theo mặc định.

Trên một số máy (Inspiron 3505, Precision 490, Vostro 1720, ...),
người hâm mộ hỗ trợ trạng thái "ma thuật" thứ 4, báo hiệu cho BIOS tự động
điều khiển quạt phải được bật cho một quạt cụ thể.
Tuy nhiên cũng có một số máy hỗ trợ trạng thái quạt thông thường thứ 4,
nhưng trong trường hợp trạng thái "ma thuật", RPM danh nghĩa được báo cáo cho trạng thái này là
giá trị giữ chỗ, tuy nhiên không phải lúc nào cũng có thể phát hiện được.

Lỗi phần mềm
-------------

Cuộc gọi SMM có thể hoạt động thất thường trên một số máy:

===============================================================================
Máy bị lỗi firmware
===============================================================================
Việc đọc trạng thái quạt sẽ trả về các lỗi giả.           Độ chính xác 490

OptiPlex 7060

Việc đọc loại quạt khiến quạt hoạt động thất thường.      Studio XPS 8000

Studio XPS 8100

Inspiron 580

Inspiron 3505

Các cuộc gọi SMM liên quan đến quạt mất quá nhiều thời gian (khoảng 500 mili giây).      Inspiron 7720

Vostro 3360

XPS 13 9333

XPS 15 L502X
===============================================================================

Trong trường hợp bạn gặp sự cố tương tự trên máy Dell của mình, vui lòng
gửi báo cáo lỗi về bugzilla để chúng tôi có thể áp dụng cách giải quyết.

Hạn chế
-----------

Cuộc gọi SMM có thể mất quá nhiều thời gian để thực hiện trên một số máy, khiến
bị treo ngắn và/hoặc trục trặc về âm thanh.
Ngoài ra, trạng thái quạt cần được khôi phục sau khi tạm dừng, cũng như
cài đặt chế độ tự động.
Khi đọc cảm biến nhiệt độ, giá trị trên 127 độ cho biết
lỗi đọc BIOS hoặc cảm biến bị vô hiệu hóa.