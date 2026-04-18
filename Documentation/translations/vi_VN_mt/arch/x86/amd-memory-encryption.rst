.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/amd-memory-encryption.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Mã hóa bộ nhớ AMD
=======================

Mã hóa bộ nhớ an toàn (SME) và Ảo hóa mã hóa an toàn (SEV) là
các tính năng được tìm thấy trên bộ xử lý AMD.

SME cung cấp khả năng đánh dấu từng trang bộ nhớ là được mã hóa bằng cách sử dụng
bảng trang x86 tiêu chuẩn.  Một trang được đánh dấu là đã mã hóa sẽ được
tự động giải mã khi đọc từ DRAM và được mã hóa khi ghi vào
DRAM.  Do đó, SME có thể được sử dụng để bảo vệ nội dung của DRAM khỏi các sự cố vật lý.
các cuộc tấn công vào hệ thống.

SEV cho phép chạy các máy ảo được mã hóa (VM) trong đó mã và dữ liệu
của máy ảo khách được bảo mật để chỉ có phiên bản được giải mã
trong chính VM. Máy ảo khách SEV có khái niệm riêng tư và chia sẻ
trí nhớ. Bộ nhớ riêng được mã hóa bằng khóa dành riêng cho khách, trong khi được chia sẻ
bộ nhớ có thể được mã hóa bằng khóa ảo hóa. Khi SME được bật, trình ảo hóa
khóa chính là khóa được sử dụng trong SME.

Một trang được mã hóa khi một mục trong bảng trang có tập bit mã hóa (xem
bên dưới về cách xác định vị trí của nó).  Bit mã hóa cũng có thể được
được chỉ định trong thanh ghi cr3, cho phép bảng PGD được mã hóa. Mỗi
cấp độ liên tiếp của bảng trang cũng có thể được mã hóa bằng cách thiết lập mã hóa
bit trong mục nhập bảng trang trỏ đến bảng tiếp theo. Điều này cho phép đầy đủ
phân cấp bảng trang được mã hóa. Lưu ý, điều này có nghĩa là chỉ vì
bit mã hóa được đặt trong cr3, không có nghĩa là toàn bộ hệ thống phân cấp được mã hóa.
Mỗi mục trong bảng trang trong hệ thống phân cấp cần phải có bit mã hóa được đặt thành
đạt được điều đó. Vì vậy, về mặt lý thuyết, bạn có thể đặt bit mã hóa trong cr3
để PGD được mã hóa nhưng không đặt bit mã hóa trong mục nhập PGD
đối với PUD dẫn đến PUD được mục nhập đó trỏ đến không được
được mã hóa.

Khi SEV được bật, các trang hướng dẫn và bảng trang khách luôn được xử lý
như riêng tư. Tất cả các hoạt động DMA bên trong máy khách phải được thực hiện trên thiết bị được chia sẻ
trí nhớ. Vì bit mã hóa bộ nhớ được điều khiển bởi hệ điều hành khách khi nó
đang hoạt động ở chế độ PAE 64-bit hoặc 32-bit, ở tất cả các chế độ khác, phần cứng SEV
buộc bit mã hóa bộ nhớ lên 1.

Hỗ trợ cho SME và SEV có thể được xác định thông qua lệnh CPUID. các
Chức năng CPUID 0x8000001f báo cáo thông tin liên quan đến SME::

0x8000001f[eax]:
		Bit[0] biểu thị hỗ trợ cho SME
		Bit[1] biểu thị sự hỗ trợ cho SEV
	0x8000001f[ebx]:
		Bits[5:0] số bit có thể phân trang được sử dụng để kích hoạt bộ nhớ
			   mã hóa
		Giảm bit[11:6] trong không gian địa chỉ vật lý, tính bằng bit, khi
			   mã hóa bộ nhớ được bật (điều này chỉ ảnh hưởng đến
			   địa chỉ vật lý của hệ thống, không phải địa chỉ vật lý của khách
			   địa chỉ)

Nếu có hỗ trợ cho SME, MSR 0xc00100010 (MSR_AMD64_SYSCFG) có thể được sử dụng để
xác định xem SME có được bật hay không và/hoặc bật mã hóa bộ nhớ::

0xc0010010:
		Bit[23] 0 = tính năng mã hóa bộ nhớ bị tắt
			  1 = tính năng mã hóa bộ nhớ được bật

Nếu SEV được hỗ trợ, MSR 0xc0010131 (MSR_AMD64_SEV) có thể được sử dụng để xác định xem
SEV đang hoạt động::

0xc0010131:
		Bit[0] 0 = mã hóa bộ nhớ không hoạt động
			  1 = mã hóa bộ nhớ đang hoạt động

Linux dựa vào BIOS để thiết lập bit này nếu BIOS đã xác định rằng việc giảm
trong không gian địa chỉ vật lý do cho phép mã hóa bộ nhớ (xem
Thông tin CPUID ở trên) sẽ không xung đột với tài nguyên không gian địa chỉ
các yêu cầu đối với hệ thống.  Nếu bit này không được thiết lập khi khởi động Linux thì
Bản thân Linux sẽ không thiết lập nó và sẽ không thể mã hóa bộ nhớ.

Trạng thái của SME trong nhân Linux có thể được ghi lại như sau:

- Được hỗ trợ:
	  CPU hỗ trợ SME (được xác định thông qua lệnh CPUID).

- Đã bật:
	  Được hỗ trợ và bit 23 của MSR_AMD64_SYSCFG được thiết lập.

- Đang hoạt động:
	  Được hỗ trợ, kích hoạt và nhân Linux đang tích cực áp dụng
	  bit mã hóa cho các mục trong bảng trang (mặt nạ SME trong
	  kernel khác 0).

SME cũng có thể được bật và kích hoạt trong BIOS. Nếu SME được bật và
được kích hoạt trong BIOS thì tất cả các truy cập bộ nhớ sẽ được mã hóa và nó
sẽ không cần thiết phải kích hoạt hỗ trợ mã hóa bộ nhớ Linux.

Nếu BIOS chỉ kích hoạt SME (đặt bit 23 của MSR_AMD64_SYSCFG),
thì có thể kích hoạt mã hóa bộ nhớ bằng cách cung cấp mem_encrypt=on trên
dòng lệnh hạt nhân.  Tuy nhiên, nếu BIOS không kích hoạt SME thì Linux
sẽ không thể kích hoạt mã hóa bộ nhớ, ngay cả khi được định cấu hình để thực hiện
vì vậy theo mặc định hoặc tham số dòng lệnh mem_encrypt=on được chỉ định.

Phân trang lồng nhau an toàn (SNP)
==================================

SEV-SNP giới thiệu các tính năng mới (SEV_FEATURES[1:63]) có thể được kích hoạt
bởi hypervisor để tăng cường bảo mật. Một số tính năng này cần
việc thực hiện phía khách để hoạt động chính xác. Bảng dưới đây liệt kê các
hành vi dự kiến của khách với các tình huống khác nhau có thể xảy ra của khách/người giám sát
Hỗ trợ tính năng SNP.

+--------+--------------+---------------+-------------------+
ZZ0000ZZ Khách cần ZZ0001ZZ Khởi động khách |
Triển khai ZZ0002ZZHành vi | implementation| |
+=====================================================================================================================================================
ZZ0004ZZ Không khởi động ZZ0005ZZ |
ZZ0006ZZ ZZ0007ZZ |
+--------+--------------+---------------+-------------------+
ZZ0008ZZ Có Khởi động ZZ0009ZZ |
ZZ0010ZZ ZZ0011ZZ |
+--------+--------------+---------------+-------------------+
ZZ0012ZZ Có Khởi động ZZ0013ZZ |
ZZ0014ZZ ZZ0015ZZ |
+--------+--------------+---------------+-------------------+
ZZ0016ZZ Không có ZZ0017ZZ Khởi động với |
Đã bật tính năng ZZ0018ZZ ZZ0019ZZ |
+--------+--------------+---------------+-------------------+
ZZ0020ZZ Có ZZ0021ZZ Giày bốt duyên dáng |
ZZ0022ZZ ZZ0023ZZ thất bại |
+--------+--------------+---------------+-------------------+
ZZ0024ZZ Có Khởi động ZZ0025ZZ với |
Đã bật tính năng ZZ0026ZZ ZZ0027ZZ |
+--------+--------------+---------------+-------------------+

Thêm chi tiết trong AMD64 APM[1] Tập 2: 15.34.10 SEV_STATUS MSR

Bảng bản đồ ngược (RMP)
=======================

RMP là một cấu trúc trong bộ nhớ hệ thống được sử dụng để đảm bảo hoạt động một-một
ánh xạ giữa địa chỉ vật lý của hệ thống và địa chỉ vật lý của khách. Mỗi
trang bộ nhớ có thể gán cho khách có một mục nhập bên trong
RMP.

Bảng RMP có thể liền kề trong bộ nhớ hoặc tập hợp các phân đoạn
trong bộ nhớ.

RMP liền kề
--------------

Hỗ trợ cho dạng RMP này hiện có khi hỗ trợ cho SEV-SNP
hiện tại, có thể được xác định bằng lệnh CPUID ::

0x8000001f[eax]:
		Bit[4] biểu thị sự hỗ trợ cho SEV-SNP

Vị trí của RMP được phần cứng xác định thông qua hai MSR::

0xc0010132 (RMP_BASE):
                Địa chỉ vật lý hệ thống của byte đầu tiên của RMP

0xc0010133 (RMP_END):
                Địa chỉ vật lý hệ thống của byte cuối cùng của RMP

Phần cứng yêu cầu RMP_BASE và (RPM_END + 1) phải được căn chỉnh 8KB, nhưng SEV
chương trình cơ sở tăng yêu cầu căn chỉnh để yêu cầu căn chỉnh 1MB.

RMP bao gồm vùng 16KB được sử dụng để ghi sổ bộ xử lý theo sau
bởi các mục RMP, có kích thước 16 byte. Kích thước của RMP
xác định phạm vi bộ nhớ vật lý mà trình ảo hóa có thể gán cho
Khách SEV-SNP. RMP bao gồm địa chỉ vật lý của hệ thống từ::

0 đến ((RMP_END + 1 - RMP_BASE - 16KB) / 16B) x 4KB.

Hỗ trợ Linux hiện tại dựa vào BIOS để phân bổ/dự trữ bộ nhớ cho
RMP và đặt RMP_BASE và RMP_END một cách thích hợp. Linux sử dụng MSR
các giá trị để xác định vị trí RMP và xác định kích thước của RMP. RMP phải
bao gồm tất cả bộ nhớ hệ thống để Linux kích hoạt SEV-SNP.

RMP được phân đoạn
------------------

Hỗ trợ RMP được phân đoạn là một cách mới để thể hiện bố cục của RMP.
Hỗ trợ RMP ban đầu yêu cầu bảng RMP phải liền kề trong bộ nhớ.
RMP truy cập từ nút NUMA mà RMP không cư trú
có thể mất nhiều thời gian hơn so với truy cập từ nút NUMA nơi RMP cư trú.
Hỗ trợ RMP được phân đoạn cho phép các mục RMP được đặt trên cùng một
nút làm bộ nhớ mà RMP đang bao phủ, có khả năng giảm độ trễ
liên quan đến việc truy cập mục RMP được liên kết với bộ nhớ. Mỗi
Phân đoạn RMP bao gồm một phạm vi địa chỉ vật lý hệ thống cụ thể.

Có thể xác định hỗ trợ cho dạng RMP này bằng cách sử dụng CPUID
hướng dẫn::

0x8000001f[eax]:
                Bit[23] biểu thị sự hỗ trợ cho RMP được phân đoạn

Nếu được hỗ trợ, có thể tìm thấy các thuộc tính RMP được phân đoạn bằng CPUID
hướng dẫn::

0x80000025[eax]:
                Bits[5:0] kích thước phân đoạn RMP được hỗ trợ tối thiểu
                Bits[11:6] kích thước phân đoạn RMP được hỗ trợ tối đa

0x80000025[ebx]:
                Số bit[9:0] của định nghĩa phân đoạn RMP có thể lưu trong bộ nhớ đệm
                Bit[10] cho biết số lượng phân đoạn RMP có thể lưu trong bộ nhớ đệm hay không
                           là một giới hạn cứng

Để kích hoạt RMP được phân đoạn, MSR mới có sẵn::

0xc0010136 (RMP_CFG):
                Bit[0] cho biết liệu RMP được phân đoạn có được bật hay không
                Bits[13:8] chứa kích thước bộ nhớ được bao phủ bởi RMP
                           phân đoạn (được biểu thị dưới dạng lũy thừa của 2)

Kích thước phân đoạn RMP được xác định trong RMP_CFG MSR áp dụng cho tất cả các phân đoạn
của RMP. Do đó, mỗi phân đoạn RMP bao gồm một phạm vi hệ thống cụ thể
địa chỉ vật lý. Ví dụ: nếu giá trị RMP_CFG MSR là 0x2401 thì
giá trị bao phủ phân đoạn RMP là 0x24 => 36, nghĩa là kích thước của bộ nhớ
được bao phủ bởi phân đoạn RMP là 64GB (1 << 36). Vậy đoạn RMP đầu tiên
bao gồm các địa chỉ vật lý từ 0 đến 0xF_FFFF_FFFF, phân đoạn RMP thứ hai
bao gồm các địa chỉ vật lý từ 0x10_0000_0000 đến 0x1F_FFFF_FFFF, v.v.

Khi RMP được phân đoạn được bật, RMP_BASE trỏ đến sổ sách kế toán RMP
như ngày nay (kích thước 16K). Tuy nhiên, thay vì các mục RMP
bắt đầu ngay sau khu vực kế toán, có 4K RMP
bảng phân đoạn (RST). Mỗi mục trong RST có kích thước 8 byte và đại diện cho
phân đoạn RMP::

Kích thước ánh xạ Bits[19:0] (tính bằng GB)
                    Kích thước được ánh xạ có thể nhỏ hơn kích thước phân đoạn đã xác định.
                    Giá trị bằng 0, biểu thị rằng không tồn tại RMP trong phạm vi
                    địa chỉ vật lý của hệ thống được liên kết với phân đoạn này.
        Địa chỉ vật lý phân đoạn Bits[51:20]
                    Địa chỉ này được dịch trái 20 bit (hoặc chỉ bị che khi
                    read) để tạo thành địa chỉ vật lý của phân đoạn (1MB
                    căn chỉnh).

RST có thể chứa 512 mục phân đoạn nhưng có thể bị giới hạn về kích thước ở số lượng
của các phân đoạn RMP có thể lưu vào bộ nhớ đệm (CPUID 0x80000025_EBX[9:0]) nếu số lượng phân đoạn có thể lưu vào bộ nhớ đệm
Các phân đoạn RMP là một giới hạn cứng (CPUID 0x80000025_EBX[10]).

Hỗ trợ Linux hiện tại dựa vào BIOS để phân bổ/dự trữ bộ nhớ cho
RMP được phân đoạn (khu vực kế toán, RST và tất cả các phân đoạn), xây dựng RST
và đặt RMP_BASE, RMP_END và RMP_CFG một cách thích hợp. Linux sử dụng MSR
các giá trị để xác định vị trí RMP và xác định kích thước cũng như vị trí của RMP
phân đoạn. RMP phải chiếm toàn bộ bộ nhớ hệ thống để Linux có thể kích hoạt
SEV-SNP.

Xem thêm chi tiết trong AMD64 APM Tập 2, phần "Bảng bản đồ ngược 15.36.3",
ID tài liệu: 24593.

Mô-đun dịch vụ VM an toàn (SVSM)
================================

SNP cung cấp một tính năng gọi là Cấp độ đặc quyền của máy ảo (VMPL).
xác định bốn cấp độ đặc quyền mà phần mềm khách có thể chạy. nhất
mức đặc quyền là 0 và số cao hơn có đặc quyền thấp hơn.
Thêm chi tiết trong AMD64 APM Vol 2, phần "Máy ảo 15.35.7
Cấp độ đặc quyền", docID: 24593.

Khi sử dụng tính năng đó, các dịch vụ khác nhau có thể chạy ở mức bảo vệ khác nhau
các cấp độ, ngoài hệ điều hành khách nhưng vẫn nằm trong môi trường SNP an toàn.
Họ có thể cung cấp dịch vụ cho khách, chẳng hạn như vTPM.

Khi khách không chạy tại VMPL0, nó cần giao tiếp với phần mềm
chạy tại VMPL0 để thực hiện các hoạt động đặc quyền hoặc để tương tác với các thiết bị bảo mật
dịch vụ. Một ví dụ về hoạt động đặc quyền như vậy là PVALIDATE.
ZZ0000ZZ sẽ được thực thi tại VMPL0.

Trong trường hợp này, phần mềm chạy ở VMPL0 thường được gọi là Secure VM
Mô-đun dịch vụ (SVSM). Khám phá SVSM và API được sử dụng để liên lạc
với nó được ghi lại trong "Mô-đun dịch vụ VM an toàn dành cho khách SEV-SNP", docID:
58019.

(Có thể tìm thấy phiên bản mới nhất của các tài liệu nêu trên bằng cách sử dụng
một công cụ tìm kiếm như duckduckgo.com và gõ vào:

site:amd.com "Mô-đun dịch vụ VM an toàn dành cho khách SEV-SNP", docID: 58019

Ví dụ.)