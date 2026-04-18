.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/tdx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Phần mở rộng miền tin cậy của Intel (TDX)
=====================================

Tiện ích mở rộng miền tin cậy của Intel (TDX) bảo vệ các máy ảo khách bí mật khỏi
máy chủ và các cuộc tấn công vật lý bằng cách cô lập trạng thái đăng ký khách và bằng cách
mã hóa bộ nhớ khách. Trong TDX, một mô-đun đặc biệt chạy trong một môi trường đặc biệt
chế độ nằm giữa máy chủ và khách và quản lý khách/máy chủ
sự chia ly.

Hỗ trợ hạt nhân máy chủ TDX
=======================

TDX giới thiệu chế độ CPU mới gọi là Chế độ phân xử an toàn (SEAM) và
một phạm vi biệt lập mới được chỉ định bởi Đăng ký Kiểm lâm SEAM (SEAMRR).  A
Mô-đun phần mềm được chứng nhận CPU có tên là 'mô-đun TDX' chạy bên trong phiên bản mới
phạm vi biệt lập để cung cấp các chức năng để quản lý và chạy được bảo vệ
VM.

TDX cũng tận dụng Mã hóa tổng bộ nhớ đa khóa của Intel (MKTME) để
cung cấp khả năng bảo vệ bằng mật mã cho máy ảo.  TDX bảo lưu một phần KeyID của MKTME
dưới dạng KeyID riêng TDX, chỉ có thể truy cập được trong chế độ SEAM.
BIOS chịu trách nhiệm phân vùng các KeyID MKTME và KeyID TDX cũ.

Trước khi mô-đun TDX có thể được sử dụng để tạo và chạy các máy ảo được bảo vệ, nó
phải được tải vào phạm vi bị cô lập và được khởi tạo đúng cách.  TDX
kiến trúc không yêu cầu BIOS để tải mô-đun TDX, nhưng
kernel giả sử nó được tải bởi BIOS.

Phát hiện thời gian khởi động TDX
-----------------------

Hạt nhân phát hiện TDX bằng cách phát hiện KeyID riêng của TDX trong hạt nhân
khởi động.  Dưới đây dmesg hiển thị khi TDX được BIOS bật::

[..] virt/tdx: Đã bật BIOS: phạm vi KeyID riêng: [16, 64)

Khởi tạo mô-đun TDX
---------------------------------------

Hạt nhân giao tiếp với mô-đun TDX thông qua lệnh SEAMCALL mới.  các
Mô-đun TDX triển khai các hàm lá SEAMCALL để cho phép hạt nhân
khởi tạo nó.

Nếu mô-đun TDX không được tải, lệnh SEAMCALL không thành công với
lỗi đặc biệt.  Trong trường hợp này, kernel không khởi tạo được mô-đun
và báo cáo mô-đun không được tải::

[..] virt/tdx: mô-đun không được tải

Việc khởi tạo mô-đun TDX tiêu tốn khoảng ~1/256 kích thước hệ thống RAM để
sử dụng nó làm 'siêu dữ liệu' cho bộ nhớ TDX.  Nó cũng cần thêm CPU
đã đến lúc khởi tạo các siêu dữ liệu đó cùng với chính mô-đun TDX.  Cả hai
không hề tầm thường.  Hạt nhân khởi tạo mô-đun TDX khi chạy trên
nhu cầu.

Bên cạnh việc khởi tạo mô-đun TDX, việc khởi tạo SEAMCALL trên mỗi CPU
phải được thực hiện trên một CPU trước khi có thể thực hiện bất kỳ SEAMCALL nào khác trên CPU đó
cpu.

Người dùng có thể tham khảo dmesg để xem mô-đun TDX đã được khởi tạo chưa.

Nếu mô-đun TDX được khởi tạo thành công, dmesg sẽ hiển thị nội dung nào đó
như dưới đây::

[..] virt/tdx: 262668 KB được phân bổ cho PAMT
  [..] virt/tdx: TDX-Module được khởi tạo

Nếu mô-đun TDX không khởi tạo được, dmesg cũng hiển thị nó không khởi chạy được
khởi tạo::

[..] virt/tdx: Khởi tạo TDX-Module không thành công ...

Tương tác TDX với các thành phần hạt nhân khác
------------------------------------------

Chính sách bộ nhớ TDX
~~~~~~~~~~~~~~~~~

TDX báo cáo danh sách "Vùng bộ nhớ có thể chuyển đổi" (CMR) để thông báo cho
kernel có bộ nhớ tương thích với TDX.  Kernel cần xây dựng một danh sách
vùng bộ nhớ (ngoài CMR) dưới dạng bộ nhớ "TDX-có thể sử dụng được" và chuyển những vùng đó
các vùng vào mô-đun TDX.  Khi việc này hoàn tất, bộ nhớ "TDX có thể sử dụng được" sẽ
các vùng được cố định trong suốt vòng đời của mô-đun.

Để đơn giản, hiện tại kernel chỉ đảm bảo tất cả các trang
trong bộ cấp phát trang là bộ nhớ TDX.  Cụ thể, kernel sử dụng tất cả
bộ nhớ hệ thống trong lõi-mm "tại thời điểm khởi tạo mô-đun TDX"
như bộ nhớ TDX và trong thời gian chờ đợi, từ chối trực tuyến bất kỳ bộ nhớ không phải TDX nào
trong phích cắm nóng bộ nhớ.

Bộ nhớ vật lý cắm nóng
~~~~~~~~~~~~~~~~~~~~~~~

Lưu ý TDX giả định bộ nhớ chuyển đổi luôn hiện diện về mặt vật lý trong quá trình
thời gian chạy của máy.  BIOS không có lỗi sẽ không bao giờ hỗ trợ loại bỏ nóng
bất kỳ bộ nhớ chuyển đổi nào.  Việc triển khai này không xử lý bộ nhớ ACPI
loại bỏ nhưng phụ thuộc vào BIOS để hoạt động chính xác.

Phích cắm nóng CPU
~~~~~~~~~~~

Mô-đun TDX yêu cầu khởi tạo trên mỗi CPU SEAMCALL phải được thực hiện trên
một CPU trước khi bất kỳ SEAMCALL nào khác có thể được tạo trên CPU đó.  Hạt nhân,
thông qua khung cắm nóng CPU, thực hiện khởi tạo cần thiết khi
CPU lần đầu tiên được đưa lên mạng.

TDX không hỗ trợ phích cắm nóng CPU vật lý (ACPI).  Trong quá trình khởi động máy,
TDX xác minh tất cả các CPU logic hiện tại trong thời gian khởi động đều tương thích với TDX trước đó
kích hoạt TDX.  BIOS không có lỗi sẽ không bao giờ hỗ trợ thêm/xóa nóng
vật lý CPU.  Hiện tại kernel không xử lý hotplug CPU vật lý,
nhưng phụ thuộc vào BIOS để hoạt động chính xác.

Lưu ý TDX hoạt động với CPU logic trực tuyến/ngoại tuyến, do đó kernel vẫn
cho phép CPU ngoại tuyến logic và trực tuyến lại.

Lỗi sai
~~~~~~~

Một số thế hệ phần cứng TDX đầu tiên có lỗi.  Một phần
ghi vào bộ đệm bộ nhớ riêng TDX sẽ âm thầm "đầu độc" bộ nhớ
dòng.  Những lần đọc tiếp theo sẽ tiêu thụ chất độc và tạo ra một cỗ máy
kiểm tra.

Ghi một phần là ghi vào bộ nhớ trong đó giao dịch ghi nhỏ hơn
cacheline đáp xuống bộ điều khiển bộ nhớ.  CPU thực hiện những điều này thông qua
hướng dẫn ghi không theo thời gian (như MOVNTI) hoặc thông qua bộ nhớ UC/WC
ánh xạ.  Các thiết bị cũng có thể ghi một phần thông qua DMA.

Về mặt lý thuyết, lỗi kernel có thể ghi một phần vào bộ nhớ riêng TDX
và kích hoạt việc kiểm tra máy bất ngờ.  Hơn nữa, việc kiểm tra máy
mã sẽ hiển thị những lỗi này dưới dạng "Lỗi phần cứng" trong khi trên thực tế, chúng là một lỗi
vấn đề kích hoạt phần mềm.  Nhưng cuối cùng, vấn đề này rất khó xảy ra.

Nếu nền tảng có lỗi như vậy, kernel sẽ in thông báo bổ sung dưới dạng
trình xử lý kiểm tra máy để thông báo cho người dùng biết việc kiểm tra máy có thể do
lỗi kernel trên bộ nhớ riêng TDX.

Kexec
~~~~~~~

Hiện tại kexec không hoạt động trên nền tảng TDX với các tính năng đã nói ở trên
lỗi.  Nó không thành công khi tải hình ảnh hạt nhân kexec.  Nếu không thì nó
hoạt động bình thường

Tương tác với S3 và các trạng thái sâu hơn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TDX không thể tồn tại ở trạng thái S3 và sâu hơn.  Phần cứng thiết lập lại và
vô hiệu hóa hoàn toàn TDX khi nền tảng chuyển sang S3 trở xuống.  Cả TDX
khách và mô-đun TDX bị phá hủy vĩnh viễn.

Hạt nhân sử dụng S3 để tạm dừng vào ram và sử dụng S4 và các trạng thái sâu hơn để
ngủ đông.  Hiện tại để đơn giản kernel chọn làm TDX
loại trừ lẫn nhau với S3 và ngủ đông.

Kernel vô hiệu hóa TDX trong quá trình khởi động sớm khi hỗ trợ chế độ ngủ đông được hỗ trợ
có sẵn::

[..] virt/tdx: khởi tạo không thành công: Hỗ trợ chế độ ngủ đông được bật

Thêm dòng lệnh kernel 'nohibernate' để tắt chế độ ngủ đông nhằm
sử dụng TDX.

ACPI S3 bị vô hiệu hóa trong quá trình khởi động sớm kernel nếu TDX được bật.  Người dùng
cần tắt TDX trong BIOS để sử dụng S3.

Hỗ trợ khách TDX
=================
Vì máy chủ không thể truy cập trực tiếp vào thanh ghi hoặc bộ nhớ của khách, nên nhiều
chức năng bình thường của hypervisor phải được chuyển vào máy khách. Đây là
được triển khai bằng Ngoại lệ ảo hóa (#VE) được xử lý bởi
hạt nhân khách. #VE được xử lý hoàn toàn bên trong nhân khách, nhưng một số
yêu cầu hypervisor phải được tư vấn.

TDX bao gồm các cơ chế giống như siêu cuộc gọi mới để liên lạc từ
khách của bộ ảo hóa hoặc mô-đun TDX.

Ngoại lệ TDX mới
------------------

Khách TDX cư xử khác với khách VMX truyền thống và bình thường.
Trong máy khách TDX, nếu không thì các lệnh hoặc truy cập bộ nhớ thông thường có thể gây ra
Ngoại lệ #VE hoặc #GP.

Hướng dẫn được đánh dấu bằng '*' có điều kiện gây ra ngoại lệ.  các
chi tiết về các hướng dẫn này được thảo luận dưới đây.

#VE dựa trên hướng dẫn
~~~~~~~~~~~~~~~~~~~~~

- Cổng I/O (INS, OUTS, IN, OUT)
-HLT
- MONITOR, MWAIT
- WBINVD, INVD
-VMCALL
-RDMSRZZ0000ZZ
-CPUID*

#GP dựa trên hướng dẫn
~~~~~~~~~~~~~~~~~~~~~

- Tất cả các lệnh VMX: INVEPT, INVVPID, VMCLEAR, VMFUNC, VMLAUNCH,
  VMPTRLD, VMPTRST, VMREAD, VMRESUME, VMWRITE, VMXOFF, VMXON
- ENCLS, ENCLU
-GETSEC
-RSM
-ENQCMD
-RDMSRZZ0000ZZ

Hành vi RDMSR/WRMSR
~~~~~~~~~~~~~~~~~~~~

Hành vi truy cập MSR thuộc ba loại:

- #GP được tạo
- #VE được tạo
- "Chỉ có tác dụng thôi"

Nói chung, không nên sử dụng MSR #GP cho khách.  Việc sử dụng chúng có thể
chỉ ra một lỗi trong khách.  Khách có thể thử xử lý #GP bằng một
hypercall nhưng khó có thể thành công.

Các MSR #VE thường có thể được xử lý bởi bộ ảo hóa.  Khách
có thể thực hiện một cuộc gọi siêu giám sát tới bộ ảo hóa để xử lý #VE.

Các MSR "chỉ hoạt động" không cần bất kỳ sự xử lý đặc biệt nào dành cho khách.  Họ có thể
được thực hiện bằng cách chuyển trực tiếp MSR tới phần cứng hoặc bằng
bẫy và xử lý trong mô-đun TDX.  Ngoài việc có thể bị chậm,
những MSR này dường như hoạt động giống như trên kim loại trần.

Hành vi CPUID
~~~~~~~~~~~~~~

Đối với một số lá và lá phụ CPUID, các trường bit ảo hóa của CPUID
các giá trị trả về (trong khách EAX/EBX/ECX/EDX) có thể được cấu hình bởi
siêu giám sát. Đối với những trường hợp như vậy, kiến trúc mô-đun Intel TDX xác định hai
các loại ảo hóa:

- Các trường bit mà trình ảo hóa kiểm soát giá trị mà khách nhìn thấy
  TD.

- Các trường bit mà bộ ảo hóa cấu hình giá trị sao cho
  khách TD nhìn thấy giá trị gốc của chúng hoặc giá trị 0. Đối với các bit này
  các trường, trình ảo hóa có thể che giấu các giá trị gốc nhưng không thể
  biến các giá trị ZZ0000ZZ.

#VE được tạo cho các lá CPUID và các lá phụ mà mô-đun TDX thực hiện
không biết xử lý thế nào. Nhân khách có thể yêu cầu bộ ảo hóa cho
giá trị bằng một hypercall.

#VE về truy cập bộ nhớ
----------------------

Về cơ bản có hai loại bộ nhớ TDX: riêng tư và chia sẻ.
Bộ nhớ riêng nhận được sự bảo vệ TDX đầy đủ.  Nội dung của nó được bảo vệ
chống lại sự truy cập từ hypervisor.  Bộ nhớ dùng chung dự kiến sẽ được
được chia sẻ giữa khách và người giám sát và không nhận được TDX đầy đủ
sự bảo vệ.

Một khách TD có quyền kiểm soát xem các truy cập bộ nhớ của nó có được coi là
riêng tư hoặc chia sẻ.  Nó chọn hành vi với một chút trong bảng trang của nó
mục nhập.  Điều này giúp đảm bảo rằng khách không đặt những vị trí nhạy cảm
thông tin trong bộ nhớ dùng chung, hiển thị nó cho bộ ảo hóa không đáng tin cậy.

#VE trên bộ nhớ dùng chung
~~~~~~~~~~~~~~~~~~~~

Việc truy cập vào ánh xạ được chia sẻ có thể gây ra lỗi #VE.  Cuối cùng thì hypervisor
kiểm soát xem việc truy cập bộ nhớ dùng chung có gây ra #VE hay không, vì vậy khách phải
cẩn thận chỉ tham khảo các trang được chia sẻ, nó có thể xử lý #VE một cách an toàn.  cho
Ví dụ, khách nên cẩn thận không truy cập vào bộ nhớ dùng chung trong
Trình xử lý #VE trước khi đọc cấu trúc thông tin #VE (TDG.VP.VEINFO.GET).

Nội dung ánh xạ được chia sẻ hoàn toàn được kiểm soát bởi trình ảo hóa. vị khách
chỉ nên sử dụng ánh xạ được chia sẻ để liên lạc với bộ điều khiển ảo hóa.
Ánh xạ chia sẻ không bao giờ được sử dụng cho nội dung bộ nhớ nhạy cảm như kernel
ngăn xếp.  Một nguyên tắc nhỏ là bộ nhớ chia sẻ của bộ điều khiển ảo hóa phải được
được xử lý giống như bộ nhớ được ánh xạ tới không gian người dùng.  Cả hypervisor và
không gian người dùng hoàn toàn không đáng tin cậy.

MMIO dành cho thiết bị ảo được triển khai dưới dạng bộ nhớ dùng chung.  Khách phải
hãy cẩn thận không truy cập vào vùng MMIO của thiết bị trừ khi nó cũng được chuẩn bị để
xử lý #VE.

#VE trên trang riêng tư
~~~~~~~~~~~~~~~~~~~~

Quyền truy cập vào ánh xạ riêng tư cũng có thể gây ra #VE.  Vì tất cả kernel
bộ nhớ cũng là bộ nhớ riêng, về mặt lý thuyết hạt nhân có thể cần
xử lý #VE khi truy cập bộ nhớ kernel tùy ý.  Điều này là không khả thi, vì vậy
Khách TDX đảm bảo rằng tất cả bộ nhớ của khách đã được "chấp nhận" trước bộ nhớ
được sử dụng bởi kernel.

Một lượng bộ nhớ khiêm tốn (thường là 512M) được phần sụn chấp nhận trước
trước khi kernel chạy để đảm bảo rằng kernel có thể khởi động mà không cần
đang phải chịu #VE.

Trình ảo hóa được phép đơn phương di chuyển các trang được chấp nhận sang một
trạng thái "bị chặn". Tuy nhiên, nếu thực hiện điều này, việc truy cập trang sẽ không tạo ra
#VE.  Thay vào đó, nó sẽ gây ra "Thoát TD" khi cần có bộ ảo hóa
để xử lý ngoại lệ.

Trình xử lý Linux #VE
-----------------

Cũng giống như lỗi trang hoặc lỗi của #GP, các ngoại lệ của #VE có thể được xử lý hoặc
gây tử vong.  Thông thường, không gian người dùng #VE chưa được xử lý sẽ tạo ra SIGSEGV.
Hạt nhân #VE chưa được xử lý sẽ dẫn đến lỗi rất tiếc.

Xử lý các ngoại lệ lồng nhau trên x86 thường là một công việc khó chịu.  MỘT #VE
có thể bị gián đoạn bởi một NMI, điều này sẽ kích hoạt một #VE khác và sự vui nhộn
xảy ra sau đó.  Kiến trúc TDX #VE đã lường trước tình huống này và bao gồm một
tính năng để làm cho nó bớt khó chịu hơn một chút.

Trong quá trình xử lý #VE, mô-đun TDX đảm bảo rằng tất cả các ngắt (bao gồm cả
NMI) bị chặn.  Khối vẫn giữ nguyên cho đến khi khách thực hiện
TDG.VP.VEINFO.GET TDCALL.  Điều này cho phép khách kiểm soát khi bị gián đoạn
hoặc một chiếc #VE mới có thể được giao.

Tuy nhiên, kernel khách vẫn phải cẩn thận để tránh khả năng
Các hành động #VE-triggering (đã thảo luận ở trên) trong khi khối này được áp dụng.
Trong khi khối được đặt đúng chỗ, mọi #VE đều được nâng lên thành lỗi kép (#DF)
đó là điều không thể phục hồi được.

Xử lý MMIO
-------------

Trong các máy ảo không phải TDX, MMIO thường được triển khai bằng cách cấp cho khách quyền truy cập vào một
ánh xạ sẽ gây ra VMEXIT khi truy cập và sau đó là trình ảo hóa
mô phỏng quyền truy cập.  Điều đó là không thể đối với khách TDX vì VMEXIT
sẽ hiển thị trạng thái đăng ký cho máy chủ. Khách TDX không tin tưởng chủ nhà
và không thể để trạng thái của họ tiếp xúc với máy chủ.

Trong các vùng TDX, MMIO thường kích hoạt ngoại lệ #VE trong máy khách.  các
trình xử lý #VE của khách sau đó mô phỏng lệnh MMIO bên trong khách và
chuyển đổi nó thành TDCALL được điều khiển tới máy chủ, thay vì hiển thị
trạng thái khách tới máy chủ.

Địa chỉ MMIO trên x86 chỉ là địa chỉ vật lý đặc biệt. Họ có thể
về mặt lý thuyết có thể được truy cập bằng bất kỳ lệnh nào truy cập bộ nhớ.
Tuy nhiên, phương pháp giải mã lệnh kernel bị hạn chế. Nó chỉ
được thiết kế để giải mã các lệnh giống như các lệnh được tạo bởi macro io.h.

Truy cập MMIO thông qua các phương tiện khác (như lớp phủ cấu trúc) có thể dẫn đến
ôi.

Chuyển đổi bộ nhớ dùng chung
-------------------------

Tất cả bộ nhớ khách TDX khởi động ở chế độ riêng tư khi khởi động.  Bộ nhớ này không thể
được truy cập bởi hypervisor.  Tuy nhiên, một số người dùng kernel thích thiết bị
trình điều khiển có thể có nhu cầu chia sẻ dữ liệu với bộ ảo hóa.  Để làm điều này,
bộ nhớ phải được chuyển đổi giữa chia sẻ và riêng tư.  Đây có thể là
được thực hiện bằng cách sử dụng một số trình trợ giúp mã hóa bộ nhớ hiện có:

* set_memory_decrypted() chuyển đổi một loạt trang thành trang được chia sẻ.
 * set_memory_encrypted() chuyển bộ nhớ về chế độ riêng tư.

Trình điều khiển thiết bị là người dùng chính của bộ nhớ dùng chung, nhưng không cần
chạm vào mọi tài xế. Bộ đệm DMA và ioremap() thực hiện chuyển đổi
tự động.

TDX sử dụng SWIOTLB cho hầu hết các phân bổ DMA. Bộ đệm SWIOTLB là
được chuyển đổi thành chia sẻ khi khởi động.

Để phân bổ DMA mạch lạc, bộ đệm DMA được chuyển đổi trên
phân bổ. Kiểm tra Force_dma_unencrypted() để biết chi tiết.

Chứng thực
===========

Chứng thực được sử dụng để xác minh độ tin cậy của khách TDX đối với người khác
các thực thể trước khi cung cấp bí mật cho khách. Ví dụ, một chìa khóa
máy chủ có thể muốn sử dụng chứng thực để xác minh rằng khách là
mong muốn trước khi giải phóng các khóa mã hóa để gắn kết mã hóa
rootfs hoặc ổ đĩa phụ.

Mô-đun TDX ghi lại trạng thái của khách TDX trong các giai đoạn khác nhau của
quá trình khởi động khách bằng cách sử dụng thanh ghi đo thời gian xây dựng (MRTD)
và các thanh ghi đo thời gian chạy (RTMR). Các phép đo liên quan đến
cấu hình ban đầu của khách và hình ảnh chương trình cơ sở được ghi lại trong MRTD
đăng ký. Các phép đo liên quan đến trạng thái ban đầu, kernel image, firmware
hình ảnh, tùy chọn dòng lệnh, bảng initrd, ACPI, v.v. được ghi lại trong
Thanh ghi RTMR. Để biết thêm chi tiết, làm ví dụ, vui lòng tham khảo TDX
Đặc tả thiết kế phần mềm ảo, phần có tiêu đề "Đo lường TD".
Tại thời gian chạy máy khách TDX, quy trình chứng thực được sử dụng để chứng thực những điều này
số đo.

Quá trình chứng thực bao gồm hai bước: tạo TDREPORT và
Tạo trích dẫn.

Khách TDX sử dụng TDCALL[TDG.MR.REPORT] để nhận TDREPORT (TDREPORT_STRUCT)
từ mô-đun TDX. TDREPORT là cấu trúc dữ liệu có kích thước cố định được tạo bởi
mô-đun TDX chứa thông tin dành riêng cho khách (chẳng hạn như bản dựng
và đo khởi động), phiên bản bảo mật nền tảng và MAC để bảo vệ
tính toàn vẹn của TDREPORT. Sử dụng REPORTDATA 64-Byte do người dùng cung cấp
làm đầu vào và được bao gồm trong TDREPORT. Thông thường nó có thể là một số nonce
được cung cấp bởi dịch vụ chứng thực để TDREPORT có thể được xác minh duy nhất.
Bạn có thể tìm thêm thông tin chi tiết về TDREPORT trong Mô-đun Intel TDX
thông số kỹ thuật, phần có tiêu đề "TDG.MR.REPORT Leaf".

Sau khi nhận được TDREPORT, bước thứ hai của quy trình chứng thực
là gửi nó đến Khu vực trích dẫn (QE) để tạo Báo giá. TDREPORT
theo thiết kế chỉ có thể được xác minh trên nền tảng cục bộ vì khóa MAC
bị ràng buộc vào nền tảng. Để hỗ trợ xác minh từ xa TDREPORT,
TDX tận dụng Intel SGX Quoting Enclave để xác minh TDREPORT cục bộ
và chuyển đổi nó thành một Báo giá có thể kiểm chứng từ xa. Phương thức gửi TDREPORT
QE là việc triển khai cụ thể. Phần mềm chứng thực có thể chọn
bất kỳ kênh liên lạc nào có sẵn (ví dụ: vsock hoặc TCP/IP) để
gửi TDREPORT tới QE và nhận Báo giá.

Tài liệu tham khảo
==========

Tài liệu tham khảo TDX được thu thập tại đây:

ZZ0000ZZ