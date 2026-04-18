.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/topology.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Cấu trúc liên kết x86
============

Tài liệu này làm rõ các khía cạnh chính của mô hình hóa cấu trúc liên kết x86 và
biểu diễn trong kernel. Cập nhật/thay đổi khi thực hiện thay đổi đối với
mã tương ứng.

Các định nghĩa cấu trúc liên kết bất khả tri có trong
Tài liệu/admin-guide/cputopology.rst. Tệp này chứa dành riêng cho x86
sự khác biệt/đặc điểm không nhất thiết phải áp dụng cho điểm chung
các định nghĩa. Vì vậy, cách đọc cấu trúc liên kết Linux trên x86 là bắt đầu
với cái chung và xem xét cái này song song để biết chi tiết cụ thể về x86.

Không cần phải nói, mã nên sử dụng các hàm chung - tệp này là ZZ0000ZZ
đây là ZZ0001ZZ hoạt động bên trong của cấu trúc liên kết x86.

Bắt đầu bởi Thomas Gleixner <tglx@kernel.org> và Borislav Petkov <bp@alien8.de>.

Mục đích chính của các cơ sở cấu trúc liên kết là trình bày các giao diện thích hợp để
mã cần biết/truy vấn/sử dụng cấu trúc của hệ thống đang chạy
chủ đề, lõi, gói, v.v.

Hạt nhân không quan tâm đến khái niệm ổ cắm vật lý vì một
socket không liên quan đến phần mềm. Nó là một thành phần cơ điện. trong
trước đây, một ổ cắm luôn chứa một gói duy nhất (xem bên dưới), nhưng với
sự ra đời của Mô-đun nhiều chip (MCM), một ổ cắm có thể chứa nhiều gói. Vì vậy
có thể vẫn còn các tham chiếu đến ổ cắm trong mã, nhưng chúng thuộc loại
bản chất lịch sử và cần được làm sạch.

Cấu trúc liên kết của một hệ thống được mô tả theo các đơn vị:

- gói
    - lõi
    - chủ đề

Bưu kiện
=======
Các gói chứa một số lõi cộng với tài nguyên được chia sẻ, ví dụ: DRAM
bộ điều khiển, bộ đệm chia sẻ, v.v.

Các hệ thống hiện đại cũng có thể sử dụng thuật ngữ 'Die' cho gói hàng.

Danh pháp AMD cho gói là 'Nút'.

Thông tin cấu trúc liên quan đến gói trong kernel:

- topology_num_threads_per_package()

Số lượng chủ đề trong một gói.

- cấu trúc liên kết_num_cores_per_package()

Số lượng lõi trong một gói.

- cấu trúc liên kết_max_dies_per_package()

Số lượng khuôn tối đa trong một gói.

- cpuinfo_x86.topo.die_id:

ID vật lý của khuôn.

- cpuinfo_x86.topo.pkg_id:

ID vật lý của gói. Thông tin này được lấy qua CPUID
    và suy ra từ ID APIC của các lõi trong gói.

Các hệ thống hiện đại sử dụng giá trị này cho ổ cắm. Có thể có nhiều
    các gói trong một ổ cắm. Giá trị này có thể khác với topo.die_id.

- cpuinfo_x86.topo.logic_pkg_id:

ID logic của gói. Vì chúng tôi không tin cậy BIOS để liệt kê
    các gói một cách nhất quán, chúng tôi đã giới thiệu khái niệm gói logic
    ID để chúng tôi có thể tính toán chính xác số lượng gói tối đa có thể có trong
    hệ thống và liệt kê các gói một cách tuyến tính.

- topology_max_packages():

Số lượng gói tối đa có thể có trong hệ thống. Hữu ích cho mỗi
    cơ sở gói để phân bổ trước thông tin cho mỗi gói.

- cpuinfo_x86.topo.llc_id:

- Trên Intel, ID APIC đầu tiên của danh sách CPU chia sẻ Cấp độ cuối cùng
        Bộ nhớ đệm

- Trên AMD, ID nút hoặc ID phức hợp lõi chứa Cấp độ cuối cùng
        Bộ nhớ đệm. Nói chung, đó là con số xác định duy nhất LLC trên
        hệ thống.

lõi
=====
Một lõi bao gồm 1 hoặc nhiều luồng. Nó không quan trọng cho dù các chủ đề
là các luồng loại SMT- hoặc CMT.

Danh pháp của AMD cho lõi CMT là "Đơn vị tính toán". Hạt nhân luôn sử dụng
"cốt lõi".

chủ đề
=======
Một thread là một đơn vị lập kế hoạch duy nhất. Nó tương đương với một Linux logic
CPU.

Danh pháp của AMD cho các luồng CMT là "Lõi đơn vị tính toán". Hạt nhân luôn
sử dụng "sợi chỉ".

Thông tin cấu trúc liên quan đến luồng trong kernel:

- topology_core_cpumask():

CPUmask chứa tất cả các chủ đề trực tuyến trong gói mà một chủ đề
    thuộc về.

Số lượng chủ đề trực tuyến cũng được in trong /proc/cpuinfo "anh chị em".

- topology_sibling_cpumask():

CPUmask chứa tất cả các luồng trực tuyến trong lõi mà một luồng
    thuộc về.

- topology_logic_package_id():

ID gói logic mà một luồng thuộc về.

- topology_physical_package_id():

ID gói vật lý mà một luồng thuộc về.

- cấu trúc liên kết_core_id();

ID của lõi mà luồng thuộc về. Nó cũng được in trong /proc/cpuinfo
    "core_id."

- cấu trúc liên kết_logic_core_id();

ID lõi logic mà một luồng thuộc về.



Liệt kê cấu trúc liên kết hệ thống
===========================

Cấu trúc liên kết trên hệ thống x86 có thể được phát hiện bằng cách sử dụng kết hợp các nhà cung cấp
các lá CPUID cụ thể liệt kê cấu trúc liên kết bộ xử lý và bộ đệm
thứ bậc.

CPUID để lại thứ tự phân tích ưa thích của họ cho mỗi nhà cung cấp x86 như sau
sau:

1) AMD

1) Lá CPUID 0x80000026 [Cấu trúc liên kết CPU mở rộng] (Core::X86::Cpuid::ExCpuTopology)

Lá CPUID mở rộng 0x80000026 là phần mở rộng của lá CPUID 0xB
      và cung cấp thông tin cấu trúc liên kết của Core, Complex, CCD (Die) và
      Ổ cắm ở mỗi cấp độ.

Hỗ trợ cho lá được phát hiện bằng cách kiểm tra xem mức mở rộng tối đa
      Mức CPUID >= 0x80000026 và sau đó kiểm tra xem ZZ0000ZZ
      trong ZZ0001ZZ ở một mức cụ thể (bắt đầu từ 0) khác không.

ZZ0000ZZ trong ZZ0001ZZ ở cấp độ cung cấp miền cấu trúc liên kết
      cấp độ mô tả - Core, Complex, CCD(Die) hoặc Ổ cắm.

Hạt nhân sử dụng ZZ0000ZZ từ ZZ0001ZZ để khám phá
      số bit cần dịch chuyển sang phải từ ZZ0002ZZ
      trong ZZ0003ZZ để có được ID cấu trúc liên kết duy nhất cho cấu trúc liên kết 
      cấp độ. Các CPU có cùng ID cấu trúc liên kết sẽ chia sẻ tài nguyên ở cấp độ đó.

Lá CPUID 0x80000026 cũng cung cấp thêm thông tin về sức mạnh
      và xếp hạng hiệu quả cũng như về loại lõi trên bộ xử lý AMD với
      đặc điểm không đồng nhất.

Nếu CPUID lá 0x80000026 được hỗ trợ thì không cần phải phân tích cú pháp thêm.

2) Lá CPUID 0x0000000B [Liệt kê cấu trúc liên kết mở rộng] (Core::X86::Cpuid::ExtTopEnum)

Lá CPUID mở rộng 0x0000000B là tiền thân của phiên bản mở rộng
      CPUID lá 0x80000026 và chỉ mô tả miền lõi và miền ổ cắm
      của cấu trúc liên kết bộ xử lý.

Hỗ trợ cho lá được phát hiện bằng cách kiểm tra xem giá trị được hỗ trợ tối đa
      Cấp độ CPUID là >= 0xB và sau đó nếu ZZ0000ZZ ở một cấp độ cụ thể
      (bắt đầu từ 0) khác 0.

ZZ0000ZZ trong ZZ0001ZZ ở cấp độ cung cấp miền cấu trúc liên kết
      mà cấp độ mô tả - Thread hoặc Bộ xử lý (Socket).

Hạt nhân sử dụng ZZ0000ZZ từ ZZ0001ZZ để khám phá
      số bit cần dịch chuyển sang phải từ ZZ0002ZZ
      trong ZZ0003ZZ để nhận ID cấu trúc liên kết duy nhất cho cấp cấu trúc liên kết đó. CPU
      chia sẻ ID cấu trúc liên kết chia sẻ tài nguyên ở cấp độ đó.

Nếu CPUID lá 0xB được hỗ trợ thì không cần phân tích cú pháp thêm.


3) Lá CPUID 0x80000008 ECX [Mã định danh kích thước] (Core::X86::Cpuid::SizeId)

Nếu cả lá CPUID 0x80000026 và 0xB đều không được hỗ trợ, thì số lượng
      CPU trên gói được phát hiện bằng cách sử dụng lá Mã định danh kích thước
      0x80000008 ECX.

Sự hỗ trợ cho lá được phát hiện bằng cách kiểm tra xem sự hỗ trợ
      Mức CPUID mở rộng là >= 0x80000008.

Các thay đổi từ ID APIC cho ID ổ cắm được tính từ
      Trường ZZ0000ZZ trong ZZ0001ZZ nếu nó khác 0.

Nếu ZZ0000ZZ được báo cáo là bằng 0 thì độ dịch chuyển được tính bằng
      thứ tự của ZZ0001ZZ được tính từ trường ZZ0002ZZ trong
      ZZ0003ZZ mô tả ZZ0004ZZ trên bao bì.

Trừ khi ID APIC mở rộng được hỗ trợ, ID APIC được sử dụng để tìm
      ID ổ cắm là từ trường ZZ0000ZZ của lá CPUID 0x00000001
      ZZ0001ZZ.

Phân tích cấu trúc liên kết tiếp tục phát hiện xem ID APIC mở rộng có
      được hỗ trợ hay không.


4) Lá CPUID 0x8000001E [ID APIC mở rộng, Mã định danh lõi, Mã định danh nút]
      (Lõi::X86::Cpuid::{ExtApicId,CoreId,NodeId})

Có thể phát hiện sự hỗ trợ cho ID APIC mở rộng bằng cách kiểm tra
      sự hiện diện của ZZ0000ZZ trong ZZ0001ZZ của lá CPUID 0x80000001
      [Số nhận dạng tính năng] (Core::X86::Cpuid::FeatureExtIdEcx).

Nếu Phần mở rộng cấu trúc liên kết được hỗ trợ, ID APIC từ ZZ0000ZZ
      từ CPUID lá 0x8000001E ZZ0001ZZ nên được ưu tiên hơn từ đó từ
      Trường ZZ0002ZZ của lá CPUID 0x00000001 ZZ0003ZZ cho cấu trúc liên kết
      sự liệt kê.

Trên bộ xử lý Family 0x17 trở lên không hỗ trợ lá CPUID
      0x80000026 hoặc CPUID lá 0xB, các thay đổi từ ID APIC cho Lõi
      ID được tính theo thứ tự ZZ0000ZZ
      được tính toán bằng cách sử dụng trường ZZ0001ZZ trong ZZ0002ZZ
      mô tả ZZ0003ZZ.

Trên Bộ xử lý dòng 0x15, Core ID từ ZZ0000ZZ được sử dụng làm
      ZZ0001ZZ (ID đơn vị tính toán) để phát hiện các CPU dùng chung đơn vị tính toán.


Tất cả các bộ xử lý AMD hỗ trợ tính năng ZZ0000ZZ đều lưu trữ
   ZZ0001ZZ từ ZZ0002ZZ của lá CPUID 0x8000001E 
   (Core::X86::Cpuid::NodeId) dưới dạng mỗi CPU ZZ0003ZZ. Trên bộ xử lý cũ hơn,
   ZZ0004ZZ được phát hiện bằng cách sử dụng MSR_FAM10H_NODE_ID MSR (MSR
   0x0xc001_100c). Sự hiện diện của NODE_ID MSR được phát hiện bằng cách kiểm tra
   ZZ0005ZZ của lá CPUID 0x80000001 [Mã định danh tính năng]
   (Lõi::X86::Cpuid::FeatureExtIdEcx).


2) Intel

Trên nền tảng Intel, CPUID để lại liệt kê bộ xử lý
   topo như sau:

1) Lá CPUID 0x1F (Lá liệt kê cấu trúc liên kết mở rộng V2)

Lá CPUID 0x1F là phần mở rộng của lá CPUID 0xB và cung cấp
      thông tin cấu trúc liên kết của Core, Module, Tile, Die, DieGrp và Socket
      ở mỗi cấp độ.

Sự hỗ trợ cho lá được phát hiện bằng cách kiểm tra xem sự hỗ trợ
      Cấp độ CPUID là >= 0x1F và sau đó là ZZ0000ZZ ở một cấp độ cụ thể
      (bắt đầu từ 0) khác 0.

ZZ0000ZZ trong ZZ0001ZZ của lá con cung cấp cấu trúc liên kết
      miền mà cấp độ mô tả - Core, Module, Tile, Die, DieGrp và
      Ổ cắm.

Hạt nhân sử dụng giá trị từ ZZ0000ZZ để khám phá số lượng
      các bit cần được dịch chuyển sang phải từ ZZ0001ZZ trong ZZ0002ZZ
      để có được ID cấu trúc liên kết duy nhất cho cấp độ cấu trúc liên kết. CPU có cùng chức năng
      ID cấu trúc liên kết chia sẻ tài nguyên ở cấp độ đó.

Nếu CPUID lá 0x1F được hỗ trợ thì không cần phân tích cú pháp thêm.


2) Lá CPUID 0x0000000B (Lá liệt kê cấu trúc liên kết mở rộng)

Lá CPUID mở rộng 0x0000000B là tiền thân của V2 Extended
      Lá liệt kê cấu trúc liên kết 0x1F và chỉ mô tả lõi và
      các miền socket của cấu trúc liên kết bộ xử lý.

Hỗ trợ cho lá được khắc phục bằng cách kiểm tra xem CPUID được hỗ trợ có
      cấp độ là >= 0xB và sau đó kiểm tra xem ZZ0000ZZ có ở cấp độ cụ thể không
      (bắt đầu từ 0) khác 0.

Lá CPUID 0x0000000B có cùng bố cục với lá CPUID 0x1F và
      nên được liệt kê theo cách tương tự.

Nếu CPUID lá 0xB được hỗ trợ thì không cần phân tích cú pháp thêm.


3) Lá CPUID 0x00000004 (Lá tham số bộ đệm xác định)

Trên bộ xử lý Intel không hỗ trợ lá CPUID 0x1F cũng như lá CPUID
      0xB, các dịch chuyển cho miền SMT được tính bằng cách sử dụng số lượng
      CPU chia sẻ bộ đệm L1.

Bộ xử lý có tính năng Siêu phân luồng được phát hiện bằng ZZ0000ZZ của
      Lá CPUID 0x1 (Thông tin cơ bản về CPUID).

Thứ tự của ZZ0000ZZ từ ZZ0001ZZ cấp 0 của CPUID 0x4 cung cấp
      những thay đổi từ ID APIC cần thiết để tính toán ID lõi.

Thông tin ID và gói APIC được tính toán bằng cách sử dụng dữ liệu từ
      Lá CPUID 0x1.


4) Lá CPUID 0x00000001 (Thông tin cơ bản về CPUID)

Mặt nạ và các dịch chuyển để lấy ID gói vật lý (ổ cắm) là
      được tính toán bằng cách sử dụng ZZ0000ZZ từ ZZ0001ZZ của lá CPUID
      0x1.

ID APIC trên các nền tảng cũ được lấy từ trường ZZ0000ZZ từ ZZ0001ZZ của CPUID lá 0x1.


3) Nhân Mã và Zhaoxin

Tương tự như Intel, Centaur và Zhaoxin sử dụng kết hợp lá CPUID
   0x00000004 (Lá tham số bộ đệm xác định) và lá CPUID 0x00000001
   (Thông tin cơ bản về CPUID) để lấy thông tin cấu trúc liên kết.



Ví dụ về cấu trúc liên kết hệ thống
========================

.. note::
  The alternative Linux CPU enumeration depends on how the BIOS enumerates the
  threads. Many BIOSes enumerate all threads 0 first and then all threads 1.
  That has the "advantage" that the logical Linux CPU numbers of threads 0 stay
  the same whether threads are enabled or not. That's merely an implementation
  detail and has no practical impact.

1) Gói đơn, lõi đơn::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0

2) Gói đơn, lõi kép

a) Một luồng trên mỗi lõi ::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 1

b) Hai luồng trên mỗi lõi ::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
				-> [luồng 1] -> Linux CPU 1
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 2
				-> [luồng 1] -> Linux CPU 3

Bảng liệt kê thay thế::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
				-> [luồng 1] -> Linux CPU 2
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 1
				-> [luồng 1] -> Linux CPU 3

Danh pháp AMD cho hệ thống CMT::

[nút 0] -> [Đơn vị tính toán 0] -> [Lõi đơn vị tính toán 0] -> Linux CPU 0
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 1
		 -> [Đơn vị tính toán 1] -> [Lõi đơn vị tính toán 0] -> Linux CPU 2
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 3

4) Gói kép, lõi kép

a) Một luồng trên mỗi lõi ::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 1

[gói 1] -> [lõi 0] -> [luồng 0] -> Linux CPU 2
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 3

b) Hai luồng trên mỗi lõi ::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
				-> [luồng 1] -> Linux CPU 1
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 2
				-> [luồng 1] -> Linux CPU 3

[gói 1] -> [lõi 0] -> [luồng 0] -> Linux CPU 4
				-> [luồng 1] -> Linux CPU 5
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 6
				-> [luồng 1] -> Linux CPU 7

Bảng liệt kê thay thế::

[gói 0] -> [lõi 0] -> [luồng 0] -> Linux CPU 0
				-> [luồng 1] -> Linux CPU 4
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 1
				-> [luồng 1] -> Linux CPU 5

[gói 1] -> [lõi 0] -> [luồng 0] -> Linux CPU 2
				-> [luồng 1] -> Linux CPU 6
		    -> [lõi 1] -> [luồng 0] -> Linux CPU 3
				-> [luồng 1] -> Linux CPU 7

Danh pháp AMD cho hệ thống CMT::

[nút 0] -> [Đơn vị tính toán 0] -> [Lõi đơn vị tính toán 0] -> Linux CPU 0
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 1
		 -> [Đơn vị tính toán 1] -> [Lõi đơn vị tính toán 0] -> Linux CPU 2
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 3

[nút 1] -> [Đơn vị tính toán 0] -> [Lõi đơn vị tính toán 0] -> Linux CPU 4
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 5
		 -> [Đơn vị tính toán 1] -> [Lõi đơn vị tính toán 0] -> Linux CPU 6
				     -> [Đơn vị tính toán lõi 1] -> Linux CPU 7