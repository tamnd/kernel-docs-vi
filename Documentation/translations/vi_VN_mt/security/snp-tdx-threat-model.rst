.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/snp-tdx-threat-model.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================================================
Điện toán bí mật trong Linux để ảo hóa x86
===========================================================

.. contents:: :local:

Bởi: Elena Reshetova <elena.reshetova@intel.com> và Carlos Bilbao <carlos.bilbao.osdev@gmail.com>

Động lực
==========

Các nhà phát triển hạt nhân làm việc trên máy tính bí mật cho ảo hóa
môi trường trong x86 hoạt động theo một tập hợp các giả định liên quan đến Linux
mô hình mối đe dọa hạt nhân khác với quan điểm truyền thống. Về mặt lịch sử,
mô hình mối đe dọa Linux thừa nhận những kẻ tấn công cư trú trong không gian người dùng, cũng như
cũng như một số ít kẻ tấn công bên ngoài có khả năng tương tác với
hạt nhân thông qua mạng khác nhau hoặc tiếp xúc với phần cứng cụ thể có giới hạn
giao diện (USB, sấm sét). Mục tiêu của tài liệu này là giải thích
các vectơ tấn công bổ sung phát sinh trong không gian điện toán bí mật
và thảo luận về các cơ chế bảo vệ được đề xuất cho nhân Linux.

Tổng quan và thuật ngữ
========================

Máy tính bí mật (CoCo) là một thuật ngữ rộng bao gồm nhiều loại
công nghệ bảo mật nhằm mục đích bảo vệ tính bí mật và toàn vẹn
dữ liệu đang được sử dụng (so với dữ liệu ở trạng thái nghỉ hoặc dữ liệu đang truyền). Về cốt lõi, CoCo
các giải pháp cung cấp Môi trường thực thi đáng tin cậy (TEE), nơi dữ liệu được bảo mật
quá trình xử lý có thể được thực hiện và kết quả là chúng thường tiến xa hơn
được phân loại thành các loại phụ khác nhau tùy thuộc vào SW được dự định
được chạy trong TEE. Tài liệu này tập trung vào một phân lớp của công nghệ CoCo
đang nhắm mục tiêu các môi trường ảo hóa và cho phép chạy Virtual
Máy (VM) bên trong TEE. Từ nay trở đi trong tài liệu này sẽ đề cập đến
gọi lớp con này của CoCo là 'Máy tính bí mật (CoCo) cho
môi trường ảo hóa (VE)'.

CoCo, trong bối cảnh ảo hóa, đề cập đến một tập hợp CTNH và/hoặc SW
công nghệ cho phép đảm bảo an ninh mạnh mẽ hơn cho SW đang chạy
bên trong máy ảo CoCo. Cụ thể, điện toán bí mật cho phép người dùng của nó
xác nhận độ tin cậy của tất cả các phần SW để đưa vào phần giảm thiểu của nó
Cơ sở tính toán đáng tin cậy (TCB) có khả năng chứng thực trạng thái của những điều này
các thành phần đáng tin cậy.

Mặc dù các chi tiết triển khai cụ thể khác nhau giữa các công nghệ, nhưng tất cả
Các cơ chế sẵn có nhằm mục đích tăng cường tính bảo mật và
tính toàn vẹn cho bộ nhớ khách của VM và trạng thái thực thi (các thanh ghi vCPU),
việc tiêm ngắt khách được kiểm soát chặt chẽ hơn, cũng như một số
cơ chế bổ sung để kiểm soát ánh xạ trang máy chủ-khách. Thêm chi tiết về
các giải pháp dành riêng cho x86 có thể được tìm thấy trong
ZZ0000ZZ và
ZZ0001ZZ.

Bố cục khách CoCo cơ bản bao gồm máy chủ, khách, các giao diện
giao tiếp với khách và máy chủ, một nền tảng có khả năng hỗ trợ máy ảo CoCo và
một trung gian đáng tin cậy giữa máy ảo khách và nền tảng cơ bản
hoạt động như một người quản lý an ninh. Màn hình máy ảo phía máy chủ
(VMM) thường bao gồm một tập hợp con các tính năng VMM truyền thống và
vẫn chịu trách nhiệm về vòng đời của khách, tức là tạo hoặc hủy CoCo
VM, quản lý quyền truy cập của nó vào tài nguyên hệ thống, v.v. Tuy nhiên, vì nó
thường nằm ngoài CoCo VM TCB, quyền truy cập của nó bị giới hạn để duy trì
mục tiêu an ninh.

Trong sơ đồ sau, các đường "<--->" biểu thị hai chiều
các kênh liên lạc hoặc giao diện giữa người quản lý bảo mật CoCo và
các thành phần còn lại (luồng dữ liệu cho khách, máy chủ, phần cứng) ::

+-------------------+ +--------------+
    ZZ0000ZZ<---->ZZ0001ZZ
    +-------------------+ ZZ0002ZZ
      ZZ0003ZZ ZZ0004ZZ
    +-------------------+ ZZ0005ZZ
    ZZ0006ZZ<---->ZZ0007ZZ
    +-------------------+ ZZ0008ZZ
                               ZZ0009ZZ
    +-------------------+ ZZ0010ZZ
    ZZ0011ZZ<--->ZZ0012ZZ
    +-------------------+ +--------------+

Các chi tiết cụ thể của trình quản lý bảo mật CoCo rất khác nhau giữa
công nghệ. Ví dụ, trong một số trường hợp, nó sẽ được triển khai trong HW
trong khi ở những nơi khác nó có thể là SW thuần túy.

Mô hình mối đe dọa nhân Linux hiện có
==================================

Các thành phần tổng thể của mô hình mối đe dọa nhân Linux hiện tại là::

+-----------------------+ +-------------------+
     ZZ0000ZZ<---->ZZ0001ZZ
     ZZ0002ZZ +-------------------+
     ZZ0003ZZ ZZ0004ZZ
     ZZ0005ZZ +-------------------+
     ZZ0006ZZ<---->ZZ0007ZZ
     ZZ0008ZZ +-------------------+
     +-----------------------+ +-------------------+
                                    ZZ0009ZZ
                                    +-------------------+
                                    +-------------------+
                                    ZZ0010ZZ
                                    +-------------------+

Ngoài ra còn có sự giao tiếp giữa bootloader và kernel trong quá trình
quá trình khởi động, nhưng sơ đồ này không thể hiện nó một cách rõ ràng. các
Hộp "Giao diện" đại diện cho các giao diện khác nhau cho phép
giao tiếp giữa kernel và không gian người dùng. Điều này bao gồm các cuộc gọi hệ thống,
API kernel, trình điều khiển thiết bị, v.v.

Mô hình mối đe dọa nhân Linux hiện tại thường giả định việc thực thi trên một
nền tảng CTNH đáng tin cậy với tất cả chương trình cơ sở và bộ tải khởi động được bao gồm trên
TCB của nó. Kẻ tấn công chính cư trú trong không gian người dùng và tất cả dữ liệu
đến từ đó thường được coi là không đáng tin cậy, trừ khi không gian người dùng
đủ đặc quyền để thực hiện các hành động đáng tin cậy. Ngoài ra, bên ngoài
những kẻ tấn công thường được xem xét, bao gồm cả những kẻ có quyền truy cập vào
mạng bên ngoài (ví dụ: Ethernet, Wireless, Bluetooth), phần cứng lộ ra
giao diện (ví dụ USB, Thunderbolt) và khả năng sửa đổi nội dung
của đĩa ngoại tuyến.

Về các vectơ tấn công từ bên ngoài, điều thú vị cần lưu ý là trong hầu hết
trường hợp kẻ tấn công bên ngoài sẽ cố gắng khai thác lỗ hổng trong không gian người dùng
đầu tiên, nhưng kẻ tấn công có thể nhắm mục tiêu trực tiếp vào
hạt nhân; đặc biệt nếu máy chủ có quyền truy cập vật lý. Ví dụ trực tiếp
các cuộc tấn công hạt nhân bao gồm các lỗ hổng CVE-2019-19524, CVE-2022-0435
và CVE-2020-24490.

Mô hình mối đe dọa máy tính bí mật và các mục tiêu bảo mật của nó
===============================================================

Máy tính bí mật bổ sung thêm một loại kẻ tấn công mới vào danh sách trên:
máy chủ có khả năng hoạt động sai (cũng có thể bao gồm một số phần của
VMM truyền thống hoặc tất cả), thường được đặt bên ngoài
CoCo VM TCB do bề mặt tấn công SW lớn. Điều quan trọng cần lưu ý
rằng điều này không có nghĩa là máy chủ hoặc VMM cố ý
độc hại, nhưng tồn tại một giá trị bảo mật khi có một CoCo nhỏ
VM TCB. Loại đối thủ mới này có thể được coi là loại mạnh hơn
của kẻ tấn công bên ngoài, vì nó cư trú cục bộ trên cùng một máy vật lý
(ngược lại với kẻ tấn công mạng từ xa) và có quyền kiểm soát khách
giao tiếp kernel với hầu hết HW::

+---------------+
                                 ZZ0000ZZ
   +-----------------------+ ZZ0001ZZ
   ZZ0002ZZ<--->ZZ0003ZZ Không gian người dùng ZZ0004ZZ
   ZZ0005ZZ ZZ0006ZZ
   ZZ0007ZZ ZZ0008ZZ Giao diện ZZ0009ZZ
   ZZ0010ZZ ZZ0011ZZ
   ZZ0012ZZ<--->ZZ0013ZZ Hạt nhân Linux ZZ0014ZZ
   ZZ0015ZZ ZZ0016ZZ
   +-----------------------+ ZZ0017ZZ
                                 Bộ tải khởi động ZZ0018ZZ/BIOS ZZ0019ZZ
   +-----------------------+ ZZ0020ZZ
   ZZ0021ZZ<--->+--------------+
   ZZ0022ZZ ZZ0023ZZ
   ZZ0024ZZ +------------------------+
   ZZ0025ZZ<--->ZZ0026ZZ
   ZZ0027ZZ +------------------------+
   ZZ0028ZZ +------------------------+
   ZZ0029ZZ<--->ZZ0030ZZ
   +--------------+ +--------------------------------------- +

Mặc dù theo truyền thống, chủ nhà có quyền truy cập không giới hạn vào dữ liệu của khách và có thể
tận dụng quyền truy cập này để tấn công khách, hệ thống CoCo sẽ giảm thiểu điều đó
tấn công bằng cách thêm các tính năng bảo mật như bảo mật dữ liệu của khách và
bảo vệ tính toàn vẹn. Mô hình mối đe dọa này giả định rằng những tính năng đó là
có sẵn và nguyên vẹn.

ZZ0000ZZ có thể được tóm tắt như sau:

1. Bảo đảm tính bảo mật và toàn vẹn thông tin riêng tư của khách CoCo
bộ nhớ và các thanh ghi.

2. Ngăn chặn việc leo thang đặc quyền từ máy chủ sang nhân Linux dành cho khách CoCo.
Mặc dù đúng là máy chủ (và VMM phía máy chủ) yêu cầu một số mức độ
đặc quyền tạo, hủy hoặc tạm dừng khách, một phần mục tiêu của
ngăn chặn sự leo thang đặc quyền là để đảm bảo rằng các hoạt động này không
cung cấp một con đường cho kẻ tấn công truy cập vào kernel của khách.

Các mục tiêu bảo mật ở trên dẫn đến hai **hạt nhân Linux CoCo chính
Tài sản VM**:

1. Bối cảnh thực thi kernel khách.
2. Bộ nhớ riêng của nhân khách.

Máy chủ giữ toàn quyền kiểm soát tài nguyên của khách CoCo và có thể từ chối
truy cập vào chúng bất cứ lúc nào. Ví dụ về tài nguyên bao gồm thời gian CPU, bộ nhớ
mà khách có thể sử dụng, băng thông mạng, v.v. Vì điều này,
tổ chức các cuộc tấn công từ chối dịch vụ (DoS) chống lại khách CoCo nằm ngoài khả năng
phạm vi của mô hình mối đe dọa này.

ZZ0000ZZ là bất kỳ giao diện nào được hiển thị từ CoCo
nhân Linux khách hướng tới một máy chủ không đáng tin cậy không nằm trong phạm vi bảo vệ của
Công nghệ CoCo bảo vệ SW/HW. Điều này bao gồm mọi khả năng
các kênh bên, cũng như các kênh bên thực thi nhất thời. Ví dụ về
giao diện rõ ràng (không phải kênh bên) bao gồm quyền truy cập vào cổng I/O, MMIO
và giao diện DMA, truy cập vào không gian cấu hình PCI, dành riêng cho VMM
siêu cuộc gọi (hướng tới VMM phía máy chủ), truy cập vào các trang bộ nhớ dùng chung,
các ngắt được phép đưa vào kernel khách bởi máy chủ, như
cũng như các siêu lệnh dành riêng cho công nghệ CoCo, nếu có. Ngoài ra,
máy chủ trong hệ thống CoCo thường kiểm soát quá trình tạo CoCo
khách: nó có một phương thức để tải vào máy khách phần sụn và bộ nạp khởi động
hình ảnh, hình ảnh hạt nhân cùng với dòng lệnh hạt nhân. Tất cả điều này
dữ liệu cũng nên được coi là không đáng tin cậy cho đến khi tính toàn vẹn và
tính xác thực được thiết lập thông qua chứng thực.

Bảng bên dưới hiển thị ma trận mối đe dọa đối với nhân Linux khách CoCo nhưng
không thảo luận về các chiến lược giảm thiểu tiềm năng. Ma trận đề cập đến
Các phiên bản dành riêng cho CoCo của khách, máy chủ và nền tảng.

.. list-table:: CoCo Linux guest kernel threat matrix
   :widths: auto
   :align: center
   :header-rows: 1

   * - Threat name
     - Threat description

   * - Guest malicious configuration
     - A misbehaving host modifies one of the following guest's
       configuration:

       1. Guest firmware or bootloader

       2. Guest kernel or module binaries

       3. Guest command line parameters

       This allows the host to break the integrity of the code running
       inside a CoCo guest, and violates the CoCo security objectives.

   * - CoCo guest data attacks
     - A misbehaving host retains full control of the CoCo guest's data
       in-transit between the guest and the host-managed physical or
       virtual devices. This allows any attack against confidentiality,
       integrity or freshness of such data.

   * - Malformed runtime input
     - A misbehaving host injects malformed input via any communication
       interface used by the guest's kernel code. If the code is not
       prepared to handle this input correctly, this can result in a host
       --> guest kernel privilege escalation. This includes traditional
       side-channel and/or transient execution attack vectors.

   * - Malicious runtime input
     - A misbehaving host injects a specific input value via any
       communication interface used by the guest's kernel code. The
       difference with the previous attack vector (malformed runtime input)
       is that this input is not malformed, but its value is crafted to
       impact the guest's kernel security. Examples of such inputs include
       providing a malicious time to the guest or the entropy to the guest
       random number generator. Additionally, the timing of such events can
       be an attack vector on its own, if it results in a particular guest
       kernel action (i.e. processing of a host-injected interrupt).
       resistant to supplied host input.

