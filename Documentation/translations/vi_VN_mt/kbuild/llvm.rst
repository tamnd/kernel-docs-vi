.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/llvm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kbuild_llvm:

=================================
Xây dựng Linux với Clang/LLVM
=================================

Tài liệu này trình bày cách xây dựng nhân Linux bằng Clang và LLVM
tiện ích.

Về
-----

Nhân Linux theo truyền thống luôn được biên dịch bằng chuỗi công cụ GNU
chẳng hạn như GCC và binutils. Công việc đang tiến hành đã cho phép các tiện ích ZZ0000ZZ và ZZ0001ZZ được
được sử dụng như những chất thay thế khả thi. Các bản phân phối như ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ và ZZ0005ZZ sử dụng hạt nhân được xây dựng bằng Clang. của Google và Meta
Nhóm trung tâm dữ liệu cũng chạy các hạt nhân được xây dựng bằng Clang.

ZZ0000ZZ. Clang là giao diện người dùng của LLVM
hỗ trợ các phần mở rộng C và GNU C mà kernel yêu cầu và
phát âm là “klang,” không phải “see-lang.”

Xây dựng với LLVM
------------------

Gọi ZZ0000ZZ qua::

làm cho LLVM=1

để biên dịch cho mục tiêu máy chủ. Để biên dịch chéo::

tạo LLVM=1 ARCH=arm64

Đối số LLVM=
------------------

LLVM có các sản phẩm thay thế cho tiện ích binutils GNU. Chúng có thể được kích hoạt
riêng lẻ. Danh sách đầy đủ các biến được hỗ trợ::

tạo CC=clang LD=ld.lld AR=llvm-ar NM=llvm-nm STRIP=llvm-strip \
	  OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf \
	  HOSTCC=clang HOSTCXX=clang++ HOSTAR=llvm-ar HOSTLD=ld.lld

ZZ0000ZZ mở rộng đến mức trên.

Nếu công cụ LLVM của bạn không có sẵn trong PATH, bạn có thể cung cấp chúng
vị trí bằng cách sử dụng biến LLVM có dấu gạch chéo ở cuối::

tạo LLVM=/path/to/llvm/

sẽ sử dụng ZZ0000ZZ, ZZ0001ZZ, v.v.
sau đây cũng có thể được sử dụng ::

PATH=/path/to/llvm:$PATH tạo LLVM=1

Nếu công cụ LLVM của bạn có hậu tố phiên bản và bạn muốn thử nghiệm với hậu tố đó
phiên bản rõ ràng thay vì các tệp thực thi không có hậu tố như ZZ0000ZZ, bạn
có thể chuyển hậu tố bằng biến ZZ0001ZZ ::

tạo LLVM=-14

sẽ sử dụng ZZ0000ZZ, ZZ0001ZZ, v.v.

Để hỗ trợ sự kết hợp của các đường dẫn ngoài cây với hậu tố phiên bản, chúng tôi
đề nghị::

PATH=/path/to/llvm/:$PATH tạo thành LLVM=-14

Giá trị tương tự được sử dụng cho ZZ0000ZZ phải được đặt cho mỗi lần gọi ZZ0001ZZ
nếu cấu hình và xây dựng thông qua các lệnh riêng biệt. ZZ0002ZZ cũng nên được đặt
như một biến môi trường khi chạy các tập lệnh mà cuối cùng sẽ chạy
ZZ0003ZZ.

Biên dịch chéo
---------------

Một trình biên dịch Clang nhị phân (và các tiện ích LLVM tương ứng) sẽ
thường chứa tất cả các phần cuối được hỗ trợ, có thể giúp đơn giản hóa chéo
biên dịch đặc biệt khi ZZ0000ZZ được sử dụng. Nếu bạn chỉ sử dụng công cụ LLVM,
ZZ0001ZZ hoặc tiền tố ba mục tiêu trở nên không cần thiết. Ví dụ::

tạo LLVM=1 ARCH=arm64

Như một ví dụ về việc trộn các tiện ích LLVM và GNU, cho mục tiêu như ZZ0000ZZ
chưa có hỗ trợ ZZ0001ZZ hoặc ZZ0002ZZ, bạn có thể
gọi ZZ0003ZZ qua::

tạo LLVM=1 ARCH=s390 LD=s390x-linux-gnu-ld.bfd \
	  OBJCOPY=s390x-linux-gnu-objcopy

Ví dụ này sẽ gọi ZZ0000ZZ làm trình liên kết và
ZZ0001ZZ, vì vậy hãy đảm bảo rằng những nội dung đó có thể truy cập được trong ZZ0002ZZ của bạn.

ZZ0000ZZ không được sử dụng để thêm tiền tố nhị phân của trình biên dịch Clang (hoặc
tiện ích LLVM tương ứng) như trường hợp của tiện ích GNU khi ZZ0001ZZ
không được thiết lập.

Đối số LLVM_IAS=
----------------------

Clang có thể lắp ráp mã trình biên dịch mã. Bạn có thể vượt qua ZZ0000ZZ để tắt tính năng này
hành vi và yêu cầu Clang gọi trình biên dịch không tích hợp tương ứng
thay vào đó. Ví dụ::

tạo LLVM=1 LLVM_IAS=0

ZZ0000ZZ là cần thiết khi biên dịch chéo và ZZ0001ZZ
được sử dụng để đặt ZZ0002ZZ cho trình biên dịch tìm
trình biên dịch không tích hợp tương ứng (thông thường, bạn không muốn sử dụng
trình biên dịch hệ thống khi nhắm mục tiêu vào kiến trúc khác). Ví dụ::

tạo LLVM=1 ARCH=cánh tay LLVM_IAS=0 CROSS_COMPILE=arm-linux-gnueabi-


bộ đệm
------

ZZ0000ZZ có thể được sử dụng với ZZ0001ZZ để cải thiện các bản dựng tiếp theo, (mặc dù
KBUILD_BUILD_TIMESTAMP_ phải được đặt thành giá trị xác định giữa các bản dựng
để tránh lỗi bộ nhớ đệm 100%, hãy xem Reproducible_builds_ để biết thêm thông tin)::

KBUILD_BUILD_TIMESTAMP='' tạo LLVM=1 CC="ccache clang"

.. _KBUILD_BUILD_TIMESTAMP: kbuild.html#kbuild-build-timestamp
.. _Reproducible_builds: reproducible-builds.html#timestamps

Kiến trúc được hỗ trợ
-----------------------

LLVM không nhắm mục tiêu tất cả các kiến trúc mà Linux hỗ trợ và
chỉ vì mục tiêu được hỗ trợ trong LLVM không có nghĩa là kernel
sẽ xây dựng hoặc làm việc mà không có bất kỳ vấn đề. Dưới đây là tóm tắt chung về
kiến trúc hiện đang hoạt động với ZZ0000ZZ hoặc ZZ0001ZZ. Cấp độ
hỗ trợ tương ứng với giá trị "S" trong tệp MAINTAINERS. Nếu một
kiến trúc không có mặt, điều đó có nghĩa là LLVM không nhắm mục tiêu
nó hoặc có những vấn đề đã biết. Sử dụng phiên bản ổn định mới nhất của LLVM hoặc
ngay cả cây phát triển cũng sẽ mang lại kết quả tốt nhất.
ZZ0002ZZ của kiến trúc thường được mong đợi sẽ hoạt động tốt,
một số cấu hình nhất định có thể có vấn đề chưa được phát hiện
chưa. Báo cáo lỗi luôn được chào đón tại trình theo dõi vấn đề bên dưới!

.. list-table::
   :widths: 10 10 10
   :header-rows: 1

   * - Architecture
     - Level of support
     - ``make`` command
   * - arm
     - Supported
     - ``LLVM=1``
   * - arm64
     - Supported
     - ``LLVM=1``
   * - hexagon
     - Maintained
     - ``LLVM=1``
   * - loongarch
     - Maintained
     - ``LLVM=1``
   * - mips
     - Maintained
     - ``LLVM=1``
   * - powerpc
     - Maintained
     - ``LLVM=1``
   * - riscv
     - Supported
     - ``LLVM=1``
   * - s390
     - Maintained
     - ``LLVM=1`` (LLVM >= 18.1.0), ``CC=clang`` (LLVM < 18.1.0)
   * - sparc (sparc64 only)
     - Maintained
     - ``CC=clang LLVM_IAS=0`` (LLVM >= 20)
   * - um (User Mode)
     - Maintained
     - ``LLVM=1``
   * - x86
     - Supported
     - ``LLVM=1``

Nhận trợ giúp
------------

-ZZ0000ZZ
- ZZ0001ZZ: <llvm@lists.linux.dev>
-ZZ0002ZZ
-ZZ0003ZZ
- IRC: #clangbuiltlinux trên irc.libera.chat
- ZZ0004ZZ: @ClangBuiltLinux
-ZZ0005ZZ
-ZZ0006ZZ

.. _getting_llvm:

Nhận LLVM
-------------

Chúng tôi cung cấp các phiên bản ổn định dựng sẵn của LLVM trên ZZ0000ZZ. Chúng đã được tối ưu hóa với hồ sơ
dữ liệu để xây dựng nhân Linux, giúp cải thiện thời gian xây dựng nhân
so với các bản phân phối khác của LLVM.

Dưới đây là các liên kết có thể hữu ích cho việc xây dựng LLVM từ nguồn hoặc mua sắm
nó thông qua trình quản lý gói của nhà phân phối.

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ
-ZZ0007ZZ
-ZZ0008ZZ
