.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Tài liệu KVM dứt khoát (Máy ảo dựa trên hạt nhân) API
========================================================================

1. Mô tả chung
======================

Kvm API tập trung vào các loại mô tả tệp khác nhau
và ioctls có thể được cấp cho các bộ mô tả tệp này.  Một ban đầu
open("/dev/kvm") lấy một điều khiển cho hệ thống con kvm; tay cầm này
có thể được sử dụng để phát hành ioctls hệ thống.  KVM_CREATE_VM ioctl về điều này
xử lý sẽ tạo một bộ mô tả tệp VM có thể được sử dụng để phát hành VM
ioctls.  KVM_CREATE_VCPU hoặc KVM_CREATE_DEVICE ioctl trên VM fd sẽ
tạo một CPU hoặc thiết bị ảo và trả về một bộ mô tả tệp trỏ tới
tài nguyên mới.

Nói cách khác, kvm API là một tập hợp ioctls được cấp cho
các loại mô tả tập tin khác nhau để kiểm soát các khía cạnh khác nhau của
một máy ảo.  Tùy thuộc vào bộ mô tả tập tin chấp nhận chúng,
ioctls thuộc các lớp sau:

- System ioctls: Truy vấn và thiết lập các thuộc tính toàn cục ảnh hưởng đến
   toàn bộ hệ thống con kvm.  Ngoài ra, hệ thống ioctl được sử dụng để tạo
   máy ảo.

- VM ioctls: Các thuộc tính truy vấn và thiết lập này ảnh hưởng đến toàn bộ máy ảo
   máy, ví dụ như bố trí bộ nhớ.  Ngoài ra, VM ioctl được sử dụng để
   tạo CPU ảo (vcpus) và các thiết bị.

VM ioctls phải được phát hành từ cùng một quy trình (không gian địa chỉ) đã được
   được sử dụng để tạo VM.

- vcpu ioctls: Các thuộc tính truy vấn và thiết lập này điều khiển hoạt động
   của một CPU ảo duy nhất.

vcpu ioctls phải được phát hành từ cùng một luồng đã được sử dụng để tạo
   vcpu, ngoại trừ vcpu ioctl không đồng bộ được đánh dấu như vậy trong
   tài liệu.  Mặt khác, ioctl đầu tiên sau khi chuyển chủ đề
   có thể thấy tác động hiệu suất.

- ioctls thiết bị: Các thuộc tính truy vấn và thiết lập này điều khiển hoạt động
   của một thiết bị duy nhất.

ioctls của thiết bị phải được cấp từ cùng một quy trình (không gian địa chỉ) mà
   đã được sử dụng để tạo VM.

Mặc dù hầu hết các ioctls đều dành riêng cho một loại bộ mô tả tệp, nhưng trong một số
trường hợp cùng một ioctl có thể thuộc nhiều hơn một lớp.

KVM API phát triển theo thời gian.  Vì lý do này, KVM định nghĩa nhiều hằng số
có dạng ZZ0003ZZ, mỗi cái tương ứng với một tập hợp chức năng
được cung cấp bởi một hoặc nhiều ioctls.  Sự sẵn có của những "khả năng" này có thể
được kiểm tra bằng ZZ0000ZZ.  Một số
các khả năng cũng cần được kích hoạt cho các máy ảo hoặc VCPU nơi chúng
chức năng mong muốn (xem ZZ0001ZZ và ZZ0002ZZ).


2. Hạn chế
===============

Nói chung, các bộ mô tả tệp có thể được di chuyển giữa các tiến trình bằng các phương tiện
của fork() và cơ sở SCM_RIGHTS của ổ cắm tên miền unix.  Những cái này
các loại thủ thuật rõ ràng không được kvm hỗ trợ.  Trong khi họ sẽ
không gây hại cho vật chủ, hành vi thực tế của chúng không được đảm bảo bởi
API.  Xem "Mô tả chung" để biết chi tiết về cách sử dụng ioctl
mô hình được hỗ trợ bởi KVM.

Điều quan trọng cần lưu ý là mặc dù VM ioctls chỉ có thể được cấp từ
quá trình tạo ra VM, vòng đời của VM được liên kết với nó
mô tả tập tin, không phải người tạo (quy trình) của nó.  Nói cách khác, VM và
tài nguyên của nó, ZZ0000ZZ, không được giải phóng
cho đến khi tham chiếu cuối cùng tới bộ mô tả tệp của VM được giải phóng.
Ví dụ: nếu fork() được phát hành sau ioctl(KVM_CREATE_VM), VM sẽ
không được giải phóng cho đến khi cả tiến trình cha (nguyên bản) và tiến trình con của nó có
đặt các tham chiếu của chúng vào bộ mô tả tệp của VM.

Bởi vì tài nguyên của máy ảo không được giải phóng cho đến lần tham chiếu cuối cùng tới máy ảo đó.
bộ mô tả tệp được phát hành, tạo các tham chiếu bổ sung cho VM
thông qua fork(), dup(), v.v... mà không có sự cân nhắc cẩn thận.
không được khuyến khích và có thể có tác dụng phụ không mong muốn, ví dụ: bộ nhớ được phân bổ
bởi và thay mặt cho quy trình của VM có thể không được giải phóng/không được tính khi
VM bị tắt.


3. Tiện ích mở rộng
===================

Kể từ Linux 2.6.22, KVM ABI đã ổn định: không bị lùi
cho phép thay đổi không tương thích.  Tuy nhiên, có một phần mở rộng
cơ sở cho phép các phần mở rộng tương thích ngược với API
được truy vấn và sử dụng.

Cơ chế mở rộng không dựa trên số phiên bản Linux.
Thay vào đó, kvm xác định mã định danh tiện ích mở rộng và phương tiện để truy vấn
liệu một mã định danh tiện ích mở rộng cụ thể có sẵn hay không.  Nếu đúng như vậy, một
bộ ioctls có sẵn để sử dụng ứng dụng.


4. Mô tả API
==================

Phần này mô tả ioctls có thể được sử dụng để kiểm soát khách kvm.
Đối với mỗi ioctl, thông tin sau được cung cấp cùng với
mô tả:

Khả năng:
      tiện ích mở rộng KVM nào cung cấp ioctl này.  Có thể là 'cơ bản',
      điều đó có nghĩa là nó sẽ được cung cấp bởi bất kỳ hạt nhân nào hỗ trợ
      API phiên bản 12 (xem ZZ0000ZZ),
      hoặc hằng số KVM_CAP_xyz có thể được kiểm tra bằng
      ZZ0001ZZ.

Kiến trúc:
      kiến trúc tập lệnh nào cung cấp ioctl này.
      x86 bao gồm cả i386 và x86_64.

loại:
      hệ thống, vm hoặc vcpu.

Thông số:
      những tham số nào được ioctl chấp nhận.

Trả về:
      giá trị trả về.  Số lỗi chung (EBADF, ENOMEM, EINVAL)
      không chi tiết nhưng có những lỗi có ý nghĩa cụ thể.


.. _KVM_GET_API_VERSION:

4.1 KVM_GET_API_VERSION
-----------------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Loại: hệ thống ioctl
:Thông số: không có
:Trả về: hằng số KVM_API_VERSION (=12)

Điều này xác định phiên bản API là kvm API ổn định. Nó không phải
dự kiến con số này sẽ thay đổi.  Tuy nhiên, Linux 2.6.20 và
2.6.21 báo cáo các phiên bản trước đó; những điều này không được ghi lại và không
được hỗ trợ.  Ứng dụng sẽ từ chối chạy nếu KVM_GET_API_VERSION
trả về một giá trị khác 12. Nếu việc kiểm tra này thành công, tất cả ioctls
được mô tả là 'cơ bản' sẽ có sẵn.


4.2 KVM_CREATE_VM
-----------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Loại: hệ thống ioctl
:Thông số: mã định danh loại máy (KVM_VM_*)
:Trả về: một VM fd có thể được sử dụng để điều khiển máy ảo mới.

VM mới không có cpu ảo và không có bộ nhớ.
Bạn có thể muốn sử dụng 0 làm loại máy.

X86:
^^^^

Các loại máy ảo X86 được hỗ trợ có thể được truy vấn thông qua KVM_CAP_VM_TYPES.

S390:
^^^^^

Để tạo máy ảo do người dùng điều khiển trên S390, hãy kiểm tra
KVM_CAP_S390_UCONTROL và sử dụng cờ KVM_VM_S390_UCONTROL làm
người dùng đặc quyền (CAP_SYS_ADMIN).

MIPS:
^^^^^

Để sử dụng ảo hóa được hỗ trợ bằng phần cứng trên MIPS (VZ ASE) thay vì
triển khai bẫy & mô phỏng mặc định (làm thay đổi cài đặt ảo
bố trí bộ nhớ để phù hợp với chế độ người dùng), hãy kiểm tra KVM_CAP_MIPS_VZ và sử dụng
cờ KVM_VM_MIPS_VZ.

ARM64:
^^^^^^

Trên arm64, kích thước địa chỉ vật lý cho VM (giới hạn kích thước IPA) bị giới hạn
đến 40bit theo mặc định. Giới hạn có thể được cấu hình nếu máy chủ hỗ trợ
phần mở rộng KVM_CAP_ARM_VM_IPA_SIZE. Khi được hỗ trợ, hãy sử dụng
KVM_VM_TYPE_ARM_IPA_SIZE(IPA_Bits) để đặt kích thước cho loại máy
mã định danh, trong đó IPA_Bits là độ rộng tối đa của bất kỳ vật lý nào
địa chỉ được sử dụng bởi VM. IPA_Bits được mã hóa theo bit[7-0] của
nhận dạng loại máy.

ví dụ: để định cấu hình khách sử dụng kích thước địa chỉ vật lý 48 bit ::

vm_fd = ioctl(dev_fd, KVM_CREATE_VM, KVM_VM_TYPE_ARM_IPA_SIZE(48));

Kích thước được yêu cầu (IPA_Bits) phải là:

===============================================================
  0 Ngụ ý kích thước mặc định, 40 bit (để tương thích ngược)
  N ngụ ý N bit, trong đó N là số nguyên dương sao cho,
      32 <= N <= Host_IPA_Limit
 ===============================================================

Host_IPA_Limit là giá trị tối đa có thể có của IPA_Bits trên máy chủ và
phụ thuộc vào khả năng CPU và cấu hình kernel. Giới hạn có thể
được truy xuất bằng KVM_CAP_ARM_VM_IPA_SIZE của KVM_CHECK_EXTENSION
ioctl() vào thời gian chạy.

Việc tạo VM sẽ thất bại nếu kích thước IPA được yêu cầu (cho dù đó là
ẩn hoặc rõ ràng) không được hỗ trợ trên máy chủ.

Xin lưu ý rằng việc định cấu hình kích thước IPA không ảnh hưởng đến khả năng
được hiển thị bởi các CPU khách trong ID_AA64MMFR0_EL1[PARange]. Nó chỉ ảnh hưởng
kích thước của địa chỉ được dịch theo cấp độ 2 (địa chỉ vật lý của khách đến
lưu trữ các bản dịch địa chỉ vật lý).


4.3 KVM_GET_MSR_INDEX_LIST, KVM_GET_MSR_FEATURE_INDEX_LIST
----------------------------------------------------------

:Khả năng: cơ bản, KVM_CAP_GET_MSR_FEATURES cho KVM_GET_MSR_FEATURE_INDEX_LIST
:Kiến trúc: x86
:Loại: hệ thống ioctl
:Thông số: struct kvm_msr_list (vào/ra)
:Trả về: 0 nếu thành công; -1 do lỗi

Lỗi:

=======================================================================
  EFAULT danh sách chỉ mục msr không thể đọc hoặc ghi vào
  E2BIG danh sách chỉ mục msr quá lớn để vừa với mảng được chỉ định bởi
             người dùng.
  =======================================================================

::

cấu trúc kvm_msr_list {
	__u32 nmsrs; /* số msrs trong mục */
	__u32 chỉ số[0];
  };

Người dùng điền kích thước của mảng chỉ số tính bằng nmsrs và đổi lại
kvm điều chỉnh nmsrs để phản ánh số lượng msrs thực tế và điền vào
mảng chỉ số với số của chúng.

KVM_GET_MSR_INDEX_LIST trả về msrs khách được hỗ trợ.  Danh sách
thay đổi tùy theo phiên bản kvm và bộ xử lý máy chủ, nhưng không thay đổi theo cách khác.

Lưu ý: nếu kvm biểu thị hỗ trợ MCE (KVM_CAP_MCE), thì MSR ngân hàng MCE là
không được trả về trong danh sách MSR, vì các vcpus khác nhau có thể có số khác nhau
của các ngân hàng, như được thiết lập thông qua KVM_X86_SETUP_MCE ioctl.

KVM_GET_MSR_FEATURE_INDEX_LIST trả về danh sách MSR có thể được chuyển
tới hệ thống KVM_GET_MSRS ioctl.  Điều này cho phép không gian người dùng thăm dò khả năng của máy chủ
và các tính năng của bộ xử lý được hiển thị thông qua MSR (ví dụ: khả năng VMX).
Danh sách này cũng thay đổi theo phiên bản kvm và bộ xử lý máy chủ, nhưng không thay đổi
mặt khác.


.. _KVM_CHECK_EXTENSION:

4.4 KVM_CHECK_EXTENSION
-----------------------

:Khả năng: cơ bản, KVM_CAP_CHECK_EXTENSION_VM cho vm ioctl
:Kiến trúc: tất cả
:Loại: hệ thống ioctl, vm ioctl
:Thông số: mã định danh tiện ích mở rộng (KVM_CAP_*)
:Trả về: 0 nếu không được hỗ trợ; 1 (hoặc một số số nguyên dương khác) nếu được hỗ trợ

API cho phép ứng dụng truy vấn về các phần mở rộng của lõi
kvm API.  Vùng người dùng chuyển mã định danh tiện ích mở rộng (số nguyên) và
nhận được một số nguyên mô tả tính khả dụng của tiện ích mở rộng.
Nói chung 0 có nghĩa là không và 1 có nghĩa là có, nhưng một số tiện ích mở rộng có thể báo cáo
thông tin bổ sung trong giá trị trả về số nguyên.

Dựa trên quá trình khởi tạo, các máy ảo khác nhau có thể có các khả năng khác nhau.
Do đó, nên sử dụng vm ioctl để truy vấn các khả năng (có sẵn
với KVM_CAP_CHECK_EXTENSION_VM trên vm fd)

4.5 KVM_GET_VCPU_MMAP_SIZE
--------------------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Loại: hệ thống ioctl
:Thông số: không có
:Trả về: kích thước của vùng vcpu mmap, tính bằng byte

KVM_RUN ioctl (cf.) giao tiếp với không gian người dùng thông qua một chia sẻ
vùng bộ nhớ.  Ioctl này trả về kích thước của vùng đó.  Xem
Tài liệu KVM_RUN để biết chi tiết.

Bên cạnh kích thước của vùng giao tiếp KVM_RUN, các khu vực khác của
bộ mô tả tệp VCPU có thể được mmap-ed, bao gồm:

- nếu KVM_CAP_COALESCED_MMIO có sẵn, một trang tại
  KVM_COALESCED_MMIO_PAGE_OFFSET * PAGE_SIZE; vì lý do lịch sử,
  trang này được bao gồm trong kết quả của KVM_GET_VCPU_MMAP_SIZE.
  KVM_CAP_COALESCED_MMIO chưa được ghi lại.

- nếu KVM_CAP_DIRTY_LOG_RING có sẵn, một số trang tại
  KVM_DIRTY_LOG_PAGE_OFFSET * PAGE_SIZE.  Để biết thêm thông tin về
  KVM_CAP_DIRTY_LOG_RING, xem ZZ0000ZZ.


4.7 KVM_CREATE_VCPU
-------------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: id vcpu (id apic trên x86)
:Trả về: vcpu fd khi thành công, -1 do lỗi

API này thêm vcpu vào máy ảo. Không thể thêm nhiều hơn max_vcpus.
Id vcpu là một số nguyên trong phạm vi [0, max_vcpu_id).

Có thể truy xuất giá trị max_vcpus được đề xuất bằng cách sử dụng KVM_CAP_NR_VCPUS của
KVM_CHECK_EXTENSION ioctl() trong thời gian chạy.
Giá trị tối đa có thể có của max_vcpus có thể được truy xuất bằng cách sử dụng
KVM_CAP_MAX_VCPUS của KVM_CHECK_EXTENSION ioctl() trong thời gian chạy.

Nếu KVM_CAP_NR_VCPUS không tồn tại, bạn nên coi max_vcpus là 4
CPU tối đa
Nếu KVM_CAP_MAX_VCPUS không tồn tại, bạn nên cho rằng max_vcpus là
giống như giá trị được trả về từ KVM_CAP_NR_VCPUS.

Giá trị tối đa có thể có cho max_vcpu_id có thể được truy xuất bằng cách sử dụng
KVM_CAP_MAX_VCPU_ID của KVM_CHECK_EXTENSION ioctl() trong thời gian chạy.

Nếu KVM_CAP_MAX_VCPU_ID không tồn tại, bạn nên cho rằng max_vcpu_id
giống với giá trị được trả về từ KVM_CAP_MAX_VCPUS.

Trên powerpc sử dụng chế độ book3s_hv, vcpus được ánh xạ lên ảo
luồng trong một hoặc nhiều lõi CPU ảo.  (Điều này là do
phần cứng yêu cầu tất cả các luồng phần cứng trong lõi CPU phải nằm trong
cùng một phân vùng.) Khả năng KVM_CAP_PPC_SMT cho biết số lượng
vcpus trên mỗi lõi ảo (vcore).  Id vcore có được bằng cách
chia id vcpu cho số vcpus trên mỗi vcore.  vcpus trong một
vcore đã cho sẽ luôn nằm trong cùng một lõi vật lý với nhau
(mặc dù đôi khi đó có thể là một lõi vật lý khác).
Không gian người dùng có thể điều khiển chế độ phân luồng (SMT) của khách bằng
phân bổ id vcpu.  Ví dụ: nếu không gian người dùng muốn
vcpus khách đơn luồng, nó sẽ làm cho tất cả id vcpu trở thành bội số
về số lượng vcpus trên mỗi vcore.

Đối với CPU ảo đã được tạo bằng ảo do người dùng điều khiển S390
máy, vcpu fd kết quả có thể được ánh xạ bộ nhớ ở độ lệch trang
KVM_S390_SIE_PAGE_OFFSET để có được bản đồ bộ nhớ của máy ảo
khối điều khiển phần cứng của cpu.


4.8 KVM_GET_DIRTY_LOG
---------------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_dirty_log (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

/* cho KVM_GET_DIRTY_LOG */
  cấu trúc kvm_dirty_log {
	__u32 khe cắm;
	__u32 đệm;
	công đoàn {
		void __user ZZ0000ZZ một bit trên mỗi trang */
		__u64 đệm;
	};
  };

Với một khe cắm bộ nhớ, trả về một bitmap chứa bất kỳ trang nào bị bẩn
kể từ cuộc gọi cuối cùng tới ioctl này.  Bit 0 là trang đầu tiên trong
khe cắm bộ nhớ.  Đảm bảo toàn bộ cấu trúc được xóa để tránh đệm
vấn đề.

Nếu KVM_CAP_MULTI_ADDRESS_SPACE khả dụng, các bit 16-31 của trường vị trí chỉ định
không gian địa chỉ mà bạn muốn trả về bitmap bẩn.  Xem
KVM_SET_USER_MEMORY_REGION để biết chi tiết về cách sử dụng trường vị trí.

Các bit trong bitmap bẩn sẽ bị xóa trước khi ioctl trả về, trừ khi
KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2 được kích hoạt.  Để biết thêm thông tin,
xem mô tả về khả năng.

Lưu ý rằng trang Xenshared_info, nếu được định cấu hình, sẽ luôn được giả định
bị bẩn. KVM sẽ không đánh dấu rõ ràng như vậy.


4.10 KVM_RUN
------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

======= ===================================================================
  EINTR một tín hiệu bị lộ đang chờ xử lý
  ENOEXEC vcpu chưa được khởi tạo hoặc khách đã cố thực thi
             hướng dẫn từ bộ nhớ thiết bị (arm64)
  Dữ liệu ENOSYS bị hủy bỏ bên ngoài các khe ghi nhớ mà không có thông tin về hội chứng và
             KVM_CAP_ARM_NISV_TO_USER chưa được kích hoạt (arm64)
  Bộ tính năng EPERM SVE nhưng chưa hoàn thiện (arm64)
  ======= ===================================================================

Ioctl này được sử dụng để chạy một CPU ảo khách.  Trong khi không có
các tham số rõ ràng, có một khối tham số ngầm có thể được
thu được bằng cách mmap() nhập vcpu fd ở offset 0, với kích thước được cho bởi
KVM_GET_VCPU_MMAP_SIZE.  Khối tham số được định dạng dưới dạng 'struct
kvm_run' (xem bên dưới).


4.11 KVM_GET_REGS
-----------------

:Khả năng: cơ bản
:Kiến trúc: tất cả ngoại trừ arm64
:Type: vcpu ioctl
:Thông số: struct kvm_regs (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc các thanh ghi mục đích chung từ vcpu.

::

/* x86 */
  cấu trúc kvm_regs {
	/* ra (KVM_GET_REGS) / vào (KVM_SET_REGS) */
	__u64 rax, rbx, RCx, rdx;
	__u64 rsi, rdi, rsp, rbp;
	__u64 r8, r9, r10, r11;
	__u64 r12, r13, r14, r15;
	__u64 rip, rflags;
  };

/* mips */
  cấu trúc kvm_regs {
	/* ra (KVM_GET_REGS) / vào (KVM_SET_REGS) */
	__u64 gpr[32];
	__u64 xin chào;
	__u64 lo;
	__u64 chiếc;
  };

/*LoongArch*/
  cấu trúc kvm_regs {
	/* ra (KVM_GET_REGS) / vào (KVM_SET_REGS) */
	gpr dài không dấu[32];
	máy tính dài không dấu;
  };


4.12 KVM_SET_REGS
-----------------

:Khả năng: cơ bản
:Kiến trúc: tất cả ngoại trừ arm64
:Type: vcpu ioctl
:Thông số: struct kvm_regs (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ghi các thanh ghi mục đích chung vào vcpu.

Xem KVM_GET_REGS để biết cấu trúc dữ liệu.


4.13 KVM_GET_SREGS
------------------

:Khả năng: cơ bản
:Kiến trúc: x86, ppc
:Type: vcpu ioctl
:Thông số: struct kvm_sregs (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc các thanh ghi đặc biệt từ vcpu.

::

/* x86 */
  cấu trúc kvm_sregs {
	cấu trúc kvm_segment cs, ds, es, fs, gs, ss;
	struct kvm_segment tr, ldt;
	struct kvm_dtable gdt, idt;
	__u64 cr0, cr2, cr3, cr4, cr8;
	__u64 efer;
	__u64 apic_base;
	__u64 ngắt_bitmap [(KVM_NR_INTERRUPTS + 63) / 64];
  };

/* ppc -- xem Arch/powerpc/include/uapi/asm/kvm.h */

ngắt_bitmap là một bitmap của các ngắt bên ngoài đang chờ xử lý.  Nhiều nhất
một bit có thể được thiết lập.  Sự gián đoạn này đã được APIC xác nhận
nhưng chưa được đưa vào lõi cpu.


4.14 KVM_SET_SREGS
------------------

:Khả năng: cơ bản
:Kiến trúc: x86, ppc
:Type: vcpu ioctl
:Thông số: struct kvm_sregs (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ghi các thanh ghi đặc biệt vào vcpu.  Xem KVM_GET_SREGS để biết
các cấu trúc dữ liệu.


4.15 KVM_TRANSLATE
------------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_translation (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Dịch địa chỉ ảo theo địa chỉ hiện tại của vcpu
chế độ dịch

::

cấu trúc kvm_translation {
	/* trong */
	__u64 tuyến tính_địa chỉ;

/* ra */
	__u64 địa chỉ vật lý;
	__u8 hợp lệ;
	__u8 có thể ghi được;
	__u8 mã người dùng;
	__u8 đệm[5];
  };


4.16 KVM_INTERRUPT
------------------

:Khả năng: cơ bản
:Kiến trúc: x86, ppc, mips, riscv, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_interrupt (trong)
:Trả về: 0 nếu thành công, âm nếu thất bại.

Xếp hàng đợi một vectơ ngắt phần cứng được đưa vào.

::

/* cho KVM_INTERRUPT */
  cấu trúc kvm_interrupt {
	/* trong */
	__u32 không rõ;
  };

X86:
^^^^

:Trả về:

================================================
	  0 khi thành công,
	 -EEXIST nếu một ngắt đã được xếp hàng đợi
	 -EINVAL số irq không hợp lệ
	 -ENXIO nếu PIC có trong kernel
	 -EFAULT nếu con trỏ không hợp lệ
	================================================

Lưu ý 'irq' là một vectơ ngắt, không phải là chân hoặc đường ngắt. Cái này
ioctl rất hữu ích nếu PIC trong kernel không được sử dụng.

PPC:
^^^^

Xếp hàng đợi một ngắt bên ngoài được đưa vào. Ioctl này bị quá tải
với 3 giá trị iq khác nhau:

a) KVM_INTERRUPT_SET

Điều này sẽ đưa một ngắt bên ngoài loại cạnh vào khách khi nó sẵn sàng
   để nhận các ngắt. Khi được tiêm, ngắt được thực hiện.

b) KVM_INTERRUPT_UNSET

Điều này hủy bỏ bất kỳ ngắt đang chờ xử lý nào.

Chỉ có sẵn với KVM_CAP_PPC_UNSET_IRQ.

c) KVM_INTERRUPT_SET_LEVEL

Điều này đưa một ngắt bên ngoài loại cấp độ vào ngữ cảnh khách. các
   ngắt vẫn đang chờ xử lý cho đến khi có ioctl cụ thể với KVM_INTERRUPT_UNSET
   được kích hoạt.

Chỉ có sẵn với KVM_CAP_PPC_IRQ_LEVEL.

Lưu ý rằng mọi giá trị cho 'irq' ngoài những giá trị nêu trên đều không hợp lệ
và phát sinh hành vi không mong muốn.

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.

MIPS:
^^^^^

Xếp hàng đợi một ngắt bên ngoài được đưa vào CPU ảo. Một tiêu cực
số ngắt loại bỏ ngắt.

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.

RISC-V:
^^^^^^^

Xếp hàng đợi một ngắt bên ngoài được đưa vào CPU ảo. ioctl này
bị quá tải với 2 giá trị irq khác nhau:

a) KVM_INTERRUPT_SET

Điều này đặt ngắt bên ngoài cho CPU ảo và nó sẽ nhận được
   một khi nó đã sẵn sàng.

b) KVM_INTERRUPT_UNSET

Thao tác này sẽ xóa ngắt bên ngoài đang chờ xử lý đối với CPU ảo.

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.

LOONGARCH:
^^^^^^^^^^

Xếp hàng đợi một ngắt bên ngoài được đưa vào CPU ảo. Một tiêu cực
số ngắt loại bỏ ngắt.

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.


4.18 KVM_GET_MSRS
-----------------

:Khả năng: cơ bản (vcpu), KVM_CAP_GET_MSR_FEATURES (hệ thống)
:Kiến trúc: x86
:Loại: hệ thống ioctl, vcpu ioctl
:Thông số: struct kvm_msrs (vào/ra)
:Trả về: số msrs được trả về thành công;
          -1 do lỗi

Khi được sử dụng như một hệ thống ioctl:
Đọc các giá trị của các tính năng dựa trên MSR có sẵn cho VM.  Cái này
tương tự như KVM_GET_SUPPORTED_CPUID, nhưng nó trả về các chỉ số và giá trị MSR.
Danh sách các tính năng dựa trên msr có thể được lấy bằng KVM_GET_MSR_FEATURE_INDEX_LIST
trong một hệ thống ioctl.

Khi được sử dụng làm vcpu ioctl:
Đọc các thanh ghi dành riêng cho mô hình từ vcpu.  Các chỉ số msr được hỗ trợ có thể
có thể thu được bằng cách sử dụng KVM_GET_MSR_INDEX_LIST trong hệ thống ioctl.

::

cấu trúc kvm_msrs {
	__u32 nmsrs; /* số msrs trong mục */
	__u32 đệm;

struct kvm_msr_entryentry[0];
  };

cấu trúc kvm_msr_entry {
	chỉ số __u32;
	__u32 dành riêng;
	__u64 dữ liệu;
  };

Mã ứng dụng phải đặt thành viên 'nmsrs' (cho biết
kích thước của mảng mục nhập) và thành viên 'chỉ mục' của mỗi mục nhập mảng.
kvm sẽ điền thành viên 'dữ liệu'.


4.19 KVM_SET_MSRS
-----------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_msrs (trong)
:Trả về: số lượng msrs được đặt thành công (xem bên dưới), -1 do lỗi

Ghi các thanh ghi dành riêng cho từng mô hình vào vcpu.  Xem KVM_GET_MSRS để biết
các cấu trúc dữ liệu.

Mã ứng dụng phải đặt thành viên 'nmsrs' (cho biết
kích thước của mảng mục nhập) và các thành viên 'chỉ mục' và 'dữ liệu' của mỗi mảng
mục nhập mảng.

Nó cố gắng đặt từng MSR trong mảng các mục [] một. Nếu cài đặt MSR
không thành công, ví dụ: do cài đặt các bit dành riêng, MSR không được hỗ trợ/mô phỏng
bởi KVM, v.v..., nó dừng xử lý danh sách MSR và trả về số lượng
MSR đã được thiết lập thành công.


4.20 KVM_SET_CPUID
------------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_cpuid (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xác định các phản hồi của vcpu đối với lệnh cpuid.  Ứng dụng
nên sử dụng KVM_SET_CPUID2 ioctl nếu có.

Hãy cẩn thận:
  - Nếu IOCTL này không thành công, KVM không đảm bảo rằng CPUID hợp lệ trước đó
    cấu hình (nếu có) không bị hỏng. Không gian người dùng có thể nhận được một bản sao
    của cấu hình CPUID thu được thông qua KVM_GET_CPUID2 trong trường hợp.
  - Sử dụng KVM_SET_CPUID{,2} sau KVM_RUN, tức là thay đổi mô hình vCPU khách
    sau khi chạy khách có thể gây mất ổn định cho khách.
  - Sử dụng các cấu hình CPUID không đồng nhất, ID APIC modulo, cấu trúc liên kết, v.v...
    có thể gây bất ổn cho du khách.

::

cấu trúc kvm_cpuid_entry {
	__u32 chức năng;
	__u32 eax;
	__u32 ebx;
	__u32 ecx;
	__u32 edx;
	__u32 đệm;
  };

/* cho KVM_SET_CPUID */
  cấu trúc kvm_cpuid {
	__u32 không;
	__u32 đệm;
	struct kvm_cpuid_entry entry[0];
  };


4.21 KVM_SET_SIGNAL_MASK
------------------------

:Khả năng: cơ bản
:Kiến trúc: tất cả
:Type: vcpu ioctl
:Thông số: struct kvm_signal_mask (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xác định tín hiệu nào bị chặn trong quá trình thực thi KVM_RUN.  Cái này
mặt nạ tín hiệu tạm thời ghi đè mặt nạ tín hiệu chủ đề.  bất kỳ
đã nhận được tín hiệu không bị chặn (ngoại trừ SIGKILL và SIGSTOP, giữ lại
hành vi truyền thống của họ) sẽ khiến KVM_RUN quay trở lại với -EINTR.

Lưu ý tín hiệu sẽ chỉ được gửi nếu không bị chặn bởi bản gốc
mặt nạ tín hiệu

::

/* cho KVM_SET_SIGNAL_MASK */
  cấu trúc kvm_signal_mask {
	__u32 len;
	__u8 sigset[0];
  };


4.22 KVM_GET_FPU
----------------

:Khả năng: cơ bản
:Kiến trúc: x86, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_fpu (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc trạng thái dấu phẩy động từ vcpu.

::

/* x86: dành cho KVM_GET_FPU và KVM_SET_FPU */
  cấu trúc kvm_fpu {
	__u8 fpr[8][16];
	__u16 fcw;
	__u16 fsw;
	__u8 ftwx;  /* ở định dạng fxsave */
	__u8 pad1;
	__u16 Last_opcode;
	__u64 cuối_ip;
	__u64 cuối_dp;
	__u8 xmm[16][16];
	__u32 mxcsr;
	__u32 pad2;
  };

/* LoongArch: dành cho KVM_GET_FPU và KVM_SET_FPU */
  cấu trúc kvm_fpu {
	__u32 fcsr;
	__u64 fcc;
	cấu trúc kvm_fpureg {
		__u64 val64[4];
	}fpr[32];
  };


4.23 KVM_SET_FPU
----------------

:Khả năng: cơ bản
:Kiến trúc: x86, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_fpu (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ghi trạng thái dấu phẩy động vào vcpu.

::

/* x86: dành cho KVM_GET_FPU và KVM_SET_FPU */
  cấu trúc kvm_fpu {
	__u8 fpr[8][16];
	__u16 fcw;
	__u16 fsw;
	__u8 ftwx;  /* ở định dạng fxsave */
	__u8 pad1;
	__u16 Last_opcode;
	__u64 cuối_ip;
	__u64 cuối_dp;
	__u8 xmm[16][16];
	__u32 mxcsr;
	__u32 pad2;
  };

/* LoongArch: dành cho KVM_GET_FPU và KVM_SET_FPU */
  cấu trúc kvm_fpu {
	__u32 fcsr;
	__u64 fcc;
	cấu trúc kvm_fpureg {
		__u64 val64[4];
	}fpr[32];
  };


4.24 KVM_CREATE_IRQCHIP
-----------------------

:Khả năng: KVM_CAP_IRQCHIP, KVM_CAP_S390_IRQCHIP (s390)
:Kiến trúc: x86, arm64, s390
:Type: vm ioctl
:Thông số: không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Tạo mô hình bộ điều khiển ngắt trong kernel.
Trên x86, tạo ioapic ảo, PIC ảo (hai PIC, lồng nhau) và thiết lập
vcpus trong tương lai sẽ có APIC cục bộ.  Định tuyến IRQ cho GSI 0-15 được đặt thành cả hai
PIC và IOAPIC; GSI 16-23 chỉ có IOAPIC.
Trên arm64, GICv2 được tạo. Bất kỳ phiên bản GIC nào khác đều yêu cầu sử dụng
KVM_CREATE_DEVICE, cũng hỗ trợ tạo GICv2.  sử dụng
KVM_CREATE_DEVICE được ưu tiên hơn KVM_CREATE_IRQCHIP cho GICv2.
Trên s390, một bảng định tuyến irq giả được tạo.

Lưu ý rằng trên s390, cần phải bật khả năng vm của KVM_CAP_S390_IRQCHIP
trước khi có thể sử dụng KVM_CREATE_IRQCHIP.


4.25 KVM_IRQ_LINE
-----------------

:Khả năng: KVM_CAP_IRQCHIP
:Kiến trúc: x86, arm64
:Type: vm ioctl
:Thông số: struct kvm_irq_level
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt mức đầu vào GSI cho mô hình bộ điều khiển ngắt trong kernel.
Trên một số kiến trúc yêu cầu phải có mô hình bộ điều khiển ngắt
đã được tạo trước đó bằng KVM_CREATE_IRQCHIP.  Lưu ý rằng kích hoạt cạnh
các ngắt yêu cầu mức được đặt thành 1 và sau đó quay lại 0.

Trên phần cứng thực, các chân ngắt có thể ở mức hoạt động thấp hoặc mức hoạt động cao.  Cái này
không quan trọng đối với trường cấp độ của struct kvm_irq_level: 1 luôn
có nghĩa là hoạt động (được xác nhận), 0 có nghĩa là không hoạt động (được xác nhận lại).

x86 cho phép hệ điều hành lập trình phân cực ngắt
(hoạt động-thấp/hoạt động-cao) cho các ngắt được kích hoạt theo cấp độ và KVM được sử dụng
để xem xét sự phân cực.  Tuy nhiên, do bitrot trong việc xử lý
ngắt hoạt động ở mức thấp, quy ước trên hiện cũng hợp lệ trên x86.
Điều này được báo hiệu bởi KVM_CAP_X86_IOAPIC_POLARITY_IGNORED.  Không gian người dùng
không nên hiển thị các ngắt cho khách ở mức hoạt động ở mức thấp trừ khi điều này
có sẵn khả năng (hoặc trừ khi nó không sử dụng irqchip trong nhân,
tất nhiên).


arm64 có thể báo hiệu ngắt ở mức CPU hoặc ở mức
irqchip trong nhân (GIC) và đối với irqchip trong nhân có thể yêu cầu GIC biết
sử dụng PPI được chỉ định cho CPU cụ thể.  Trường irq được giải thích
như thế này::

bit: ZZ0000ZZ 27 ... 24 ZZ0001ZZ 15 ... 0 |
  trường: ZZ0002ZZ irq_type ZZ0003ZZ irq_id |

Trường irq_type có các giá trị sau:

-KVM_ARM_IRQ_TYPE_CPU:
	       GIC ngoài hạt nhân: irq_id 0 là IRQ, irq_id 1 là FIQ
-KVM_ARM_IRQ_TYPE_SPI:
	       trong nhân GICv2/GICv3: SPI, irq_id trong khoảng từ 32 đến 1019 (bao gồm)
               (trường vcpu_index bị bỏ qua)
	       trong nhân GICv5: SPI, irq_id trong khoảng từ 0 đến 65535 (bao gồm)
-KVM_ARM_IRQ_TYPE_PPI:
	       trong nhân GICv2/GICv3: PPI, irq_id trong khoảng từ 16 đến 31 (bao gồm)
	       trong nhân GICv5: PPI, irq_id trong khoảng từ 0 đến 127 (bao gồm)

(Do đó, trường irq_id tương ứng hoàn toàn với ID IRQ trong thông số kỹ thuật ARM GIC)

Trong cả hai trường hợp, cấp độ được sử dụng để xác nhận/xác nhận lại dòng.

Khi KVM_CAP_ARM_IRQ_LINE_LAYOUT_2 được hỗ trợ, vcpu đích là
được xác định là (256 *vcpu2_index + vcpu_index). Ngược lại, vcpu2_index
phải bằng không.

Lưu ý rằng trên arm64, khả năng của KVM_CAP_IRQCHIP chỉ có điều kiện
chèn các ngắt cho irqchip trong kernel. KVM_IRQ_LINE luôn có thể
được sử dụng cho bộ điều khiển ngắt không gian người dùng.

::

cấu trúc kvm_irq_level {
	công đoàn {
		__u32 không rõ;     /* GSI */
		trạng thái __s32;  /* không được sử dụng cho KVM_IRQ_LEVEL */
	};
	__u32 cấp độ;           /* 0 hoặc 1 */
  };


4.26 KVM_GET_IRQCHIP
--------------------

:Khả năng: KVM_CAP_IRQCHIP
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_irqchip (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc trạng thái của bộ điều khiển ngắt kernel được tạo bằng
KVM_CREATE_IRQCHIP vào bộ đệm do người gọi cung cấp.

::

cấu trúc kvm_irqchip {
	__u32chip_id;  /* 0 = PIC1, 1 = PIC2, 2 = IOAPIC */
	__u32 đệm;
        công đoàn {
		char giả[512];  /* dành chỗ trống */
		struct kvm_pic_state pic;
		struct kvm_ioapic_state ioapic;
	} chip;
  };


4.27 KVM_SET_IRQCHIP
--------------------

:Khả năng: KVM_CAP_IRQCHIP
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_irqchip (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt trạng thái của bộ điều khiển ngắt kernel được tạo bằng
KVM_CREATE_IRQCHIP từ bộ đệm do người gọi cung cấp.

::

cấu trúc kvm_irqchip {
	__u32chip_id;  /* 0 = PIC1, 1 = PIC2, 2 = IOAPIC */
	__u32 đệm;
        công đoàn {
		char giả[512];  /* dành chỗ trống */
		struct kvm_pic_state pic;
		struct kvm_ioapic_state ioapic;
	} chip;
  };


4.28 KVM_XEN_HVM_CONFIG
-----------------------

:Khả năng: KVM_CAP_XEN_HVM
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_xen_hvm_config (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt MSR mà khách Xen HVM sử dụng để khởi tạo hypercall của nó
trang và cung cấp địa chỉ bắt đầu cũng như kích thước của siêu cuộc gọi
các đốm màu trong không gian người dùng.  Khi khách viết MSR, kvm sẽ sao chép một
trang của một blob (32 hoặc 64-bit, tùy thuộc vào chế độ vcpu) cho khách
trí nhớ.

Chỉ số MSR phải nằm trong phạm vi [0x40000000, 0x4fffffff], tức là phải nằm trong phạm vi
trong phạm vi được dành riêng không chính thức cho các nhà ảo hóa sử dụng.  Tối thiểu/tối đa
các giá trị được liệt kê thông qua KVM_XEN_MSR_MIN_INDEX và KVM_XEN_MSR_MAX_INDEX.

::

cấu trúc kvm_xen_hvm_config {
	__u32 cờ;
	__u32 msr;
	__u64 blob_addr_32;
	__u64 blob_addr_64;
	__u8 blob_size_32;
	__u8 blob_size_64;
	__u8 pad2[30];
  };

Nếu một số cờ nhất định được trả về từ quá trình kiểm tra KVM_CAP_XEN_HVM, chúng có thể
được đặt trong trường cờ của ioctl này:

Cờ KVM_XEN_HVM_CONFIG_INTERCEPT_HCALL yêu cầu KVM tạo
nội dung của trang siêu cuộc gọi tự động; siêu cuộc gọi sẽ được
bị chặn và chuyển đến không gian người dùng thông qua KVM_EXIT_XEN.  Trong này
trường hợp này, tất cả các trường địa chỉ và kích thước blob phải bằng 0.

Cờ KVM_XEN_HVM_CONFIG_EVTCHN_SEND cho KVM biết không gian người dùng đó
sẽ luôn sử dụng KVM_XEN_HVM_EVTCHN_SEND ioctl để tổ chức sự kiện
kênh bị gián đoạn thay vì thao túng Shared_info của khách
cấu trúc trực tiếp. Ngược lại, điều này có thể cho phép KVM kích hoạt các tính năng
chẳng hạn như chặn siêu lệnh SCHEDOP_poll để tăng tốc PV
hoạt động spinlock cho khách. Không gian người dùng vẫn có thể sử dụng ioctl
để cung cấp các sự kiện nếu nó được quảng cáo, ngay cả khi không gian người dùng không
gửi dấu hiệu này rằng nó sẽ luôn làm như vậy

Hiện tại không có cờ nào khác hợp lệ trong cấu trúc kvm_xen_hvm_config.

4.29 KVM_GET_CLOCK
------------------

:Khả năng: KVM_CAP_ADJUST_CLOCK
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_clock_data (out)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lấy dấu thời gian hiện tại của kvmclock mà khách hiện tại nhìn thấy. trong
kết hợp với KVM_SET_CLOCK, nó được sử dụng để đảm bảo tính đơn điệu trong các tình huống
chẳng hạn như di cư.

Khi KVM_CAP_ADJUST_CLOCK được chuyển tới KVM_CHECK_EXTENSION, nó trả về
tập hợp các bit mà KVM có thể trả về trong thành viên cờ của struct kvm_clock_data.

Các cờ sau được xác định:

KVM_CLOCK_TSC_STABLE
  Nếu được đặt, giá trị trả về là kvmclock chính xác
  giá trị được nhìn thấy bởi tất cả các VCPU tại thời điểm KVM_GET_CLOCK được gọi.
  Nếu xóa, giá trị trả về chỉ đơn giản là CLOCK_MONOTONIC cộng với một hằng số
  bù đắp; phần bù có thể được sửa đổi bằng KVM_SET_CLOCK.  KVM sẽ thử
  để làm cho tất cả các VCPU tuân theo đồng hồ này, nhưng giá trị chính xác được đọc bởi mỗi VCPU
  VCPU có thể khác do máy chủ TSC không ổn định.

KVM_CLOCK_REALTIME
  Nếu được đặt, trường ZZ0000ZZ trong kvm_clock_data
  cấu trúc được điền với giá trị thời gian thực của máy chủ
  nguồn xung nhịp tại thời điểm KVM_GET_CLOCK được gọi. Nếu rõ ràng,
  trường ZZ0001ZZ không chứa giá trị.

KVM_CLOCK_HOST_TSC
  Nếu được đặt, trường ZZ0000ZZ trong kvm_clock_data
  cấu trúc được điền với giá trị của bộ đếm dấu thời gian của máy chủ (TSC)
  vào thời điểm KVM_GET_CLOCK được gọi. Nếu xóa, trường ZZ0001ZZ
  không chứa một giá trị.

::

cấu trúc kvm_clock_data {
	__u64 đồng hồ;  /* giá trị hiện tại của kvmclock */
	__u32 cờ;
	__u32 pad0;
	__u64 thời gian thực;
	__u64 máy chủ_tsc;
	__u32 đệm[4];
  };


4,30 KVM_SET_CLOCK
------------------

:Khả năng: KVM_CAP_ADJUST_CLOCK
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_clock_data (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt dấu thời gian hiện tại của kvmclock thành giá trị được chỉ định trong tham số của nó.
Kết hợp với KVM_GET_CLOCK, nó được sử dụng để đảm bảo tính đơn điệu trong các tình huống
chẳng hạn như di cư.

Các cờ sau có thể được thông qua:

KVM_CLOCK_REALTIME
  Nếu được đặt, KVM sẽ so sánh giá trị của trường ZZ0000ZZ
  với giá trị của nguồn đồng hồ thời gian thực của máy chủ tại thời điểm
  KVM_SET_CLOCK đã được gọi. Sự khác biệt về thời gian trôi qua được thêm vào trận chung kết
  giá trị kvmclock sẽ được cung cấp cho khách.

Các cờ khác được ZZ0000ZZ trả về được chấp nhận nhưng bị bỏ qua.

::

cấu trúc kvm_clock_data {
	__u64 đồng hồ;  /* giá trị hiện tại của kvmclock */
	__u32 cờ;
	__u32 pad0;
	__u64 thời gian thực;
	__u64 máy chủ_tsc;
	__u32 đệm[4];
  };


4.31 KVM_GET_VCPU_EVENTS
------------------------

:Khả năng: KVM_CAP_VCPU_EVENTS
:Người mở rộng: KVM_CAP_INTR_SHADOW
:Kiến trúc: x86, arm64
:Type: vcpu ioctl
:Thông số: struct kvm_vcpu_events (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

X86:
^^^^

Nhận các ngoại lệ, ngắt và NMI hiện đang chờ xử lý cũng như các thông tin liên quan
các trạng thái của vcpu.

::

cấu trúc kvm_vcpu_events {
	cấu trúc {
		__u8 tiêm;
		__u8 nr;
		__u8 has_error_code;
		__u8 đang chờ xử lý;
		__u32 error_code;
	} ngoại lệ;
	cấu trúc {
		__u8 tiêm;
		__u8 nr;
		__u8 mềm mại;
		__u8 bóng;
	} ngắt;
	cấu trúc {
		__u8 tiêm;
		__u8 đang chờ xử lý;
		__u8 đeo mặt nạ;
		__u8 đệm;
	} nmi;
	__u32 sipi_vector;
	__u32 cờ;
	cấu trúc {
		__u8 smm;
		__u8 đang chờ xử lý;
		__u8 smm_inside_nmi;
		__u8 chốt_init;
	} mỉm cười;
	__u8 dành riêng[27];
	__u8 ngoại lệ_has_payload;
	__u64 ngoại lệ_payload;
  };

Các bit sau được xác định trong trường cờ:

- KVM_VCPUEVENT_VALID_SHADOW có thể được đặt để báo hiệu rằng
  ngắt.shadow chứa trạng thái hợp lệ.

- KVM_VCPUEVENT_VALID_SMM có thể được đặt thành tín hiệu rằng smi chứa
  trạng thái hợp lệ.

- KVM_VCPUEVENT_VALID_PAYLOAD có thể được đặt để báo hiệu rằng
  ngoại lệ_has_payload, ngoại lệ_payload và ngoại lệ.pending
  các trường chứa trạng thái hợp lệ. Bit này sẽ được thiết lập bất cứ khi nào
  KVM_CAP_EXCEPTION_PAYLOAD được kích hoạt.

- KVM_VCPUEVENT_VALID_TRIPLE_FAULT có thể được đặt để báo hiệu rằng
  Trường triple_fault_pending chứa trạng thái hợp lệ. Bit này sẽ
  được đặt bất cứ khi nào KVM_CAP_X86_TRIPLE_FAULT_EVENT được bật.

ARM64:
^^^^^^

Nếu khách truy cập vào một thiết bị đang được nhân máy chủ mô phỏng trong
theo cách mà một thiết bị thực sẽ tạo ra SError vật lý, KVM có thể tạo ra
một SError ảo đang chờ xử lý cho VCPU đó. Lỗi hệ thống này vẫn bị gián đoạn
đang chờ xử lý cho đến khi khách chấp nhận ngoại lệ bằng cách vạch mặt PSTATE.A.

Việc chạy VCPU có thể khiến nó gặp phải lỗi SError đang chờ xử lý hoặc tạo quyền truy cập
khiến SError ở trạng thái chờ xử lý. Mô tả của sự kiện chỉ có hiệu lực khi
VPCU không chạy.

API này cung cấp cách đọc và ghi trạng thái 'sự kiện' đang chờ xử lý mà không phải
khách có thể nhìn thấy. Để lưu, khôi phục hoặc di chuyển VCPU, cấu trúc đại diện
trạng thái có thể được đọc rồi ghi bằng GET/SET API này, cùng với trạng thái khác
sổ đăng ký có thể nhìn thấy của khách. Không thể 'hủy' một SError đã được
được thực hiện đang chờ xử lý.

Một thiết bị đang được mô phỏng trong không gian người dùng cũng có thể muốn tạo SError. để làm
cấu trúc sự kiện này có thể được điền theo không gian người dùng. Tình trạng hiện tại
nên được đọc trước để đảm bảo không có SError hiện tại nào đang chờ xử lý. Nếu hiện có
SError đang chờ xử lý, các quy tắc 'Nhiều SError ngắt' của kiến trúc sẽ
được theo sau. (2.5.3 của DDI0587.a "ARM Độ tin cậy, tính sẵn có và
Thông số kỹ thuật về khả năng bảo trì (RAS)").

Các ngoại lệ SError luôn có giá trị ESR. Một số CPU có khả năng
chỉ định giá trị ESR của SError ảo sẽ là bao nhiêu. Các hệ thống này sẽ
quảng cáo KVM_CAP_ARM_INJECT_SERROR_ESR. Trong trường hợp này ngoại lệ.has_esr sẽ
luôn có giá trị khác 0 khi đọc và tác nhân tạo SError đang chờ xử lý
nên chỉ định trường ISS ở 24 bit thấp hơn của ngoại lệ.serror_esr. Nếu
hệ thống hỗ trợ KVM_CAP_ARM_INJECT_SERROR_ESR, nhưng không gian người dùng đặt các sự kiện
với ngoại lệ.has_esr bằng 0, KVM sẽ chọn ESR.

Chỉ định ngoại lệ.has_esr trên hệ thống không hỗ trợ nó sẽ trả về
-EINVAL. Đặt bất kỳ thứ gì khác ngoài 24bit thấp hơn của ngoại lệ.serror_esr
sẽ trả về -EINVAL.

Không thể đọc lại lệnh hủy bỏ bên ngoài đang chờ xử lý (được đưa qua
KVM_SET_VCPU_EVENTS hoặc cách khác) vì ngoại lệ như vậy luôn được gửi
trực tiếp đến CPU ảo).

Việc gọi ioctl này trên vCPU chưa được khởi tạo sẽ trả về
-ENOEXEC.

::

cấu trúc kvm_vcpu_events {
	cấu trúc {
		__u8 lỗi_pending;
		__u8 serror_has_esr;
		__u8 ext_dabt_pending;
		/* Căn chỉnh nó thành 8 byte */
		__u8 đệm[5];
		__u64 lỗi_esr;
	} ngoại lệ;
	__u32 dành riêng[12];
  };

4.32 KVM_SET_VCPU_EVENTS
------------------------

:Khả năng: KVM_CAP_VCPU_EVENTS
:Người mở rộng: KVM_CAP_INTR_SHADOW
:Kiến trúc: x86, arm64
:Type: vcpu ioctl
:Thông số: struct kvm_vcpu_events (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

X86:
^^^^

Đặt các ngoại lệ, ngắt và NMI đang chờ xử lý cũng như các trạng thái liên quan của
vcpu.

Xem KVM_GET_VCPU_EVENTS để biết cấu trúc dữ liệu.

Có thể loại trừ các trường có thể được sửa đổi không đồng bộ bằng cách chạy VCPU
từ bản cập nhật. Các trường này là nmi.pending, Sipi_vector, smi.smm,
smi.pending. Giữ các bit tương ứng trong trường cờ được xóa để
ngăn chặn việc ghi đè trạng thái hiện tại trong kernel. Các bit là:

======================================================================
KVM_VCPUEVENT_VALID_NMI_PENDING chuyển nmi.pending vào kernel
KVM_VCPUEVENT_VALID_SIPI_VECTOR chuyển sipi_vector
KVM_VCPUEVENT_VALID_SMM chuyển cấu trúc phụ smi.
======================================================================

Nếu KVM_CAP_INTR_SHADOW có sẵn, KVM_VCPUEVENT_VALID_SHADOW có thể được đặt trong
trường cờ để báo hiệu rằng ngắt.shadow chứa trạng thái hợp lệ và
sẽ được ghi vào VCPU.

KVM_VCPUEVENT_VALID_SMM chỉ có thể được đặt nếu KVM_CAP_X86_SMM có sẵn.

Nếu KVM_CAP_EXCEPTION_PAYLOAD được bật, KVM_VCPUEVENT_VALID_PAYLOAD
có thể được đặt trong trường cờ để báo hiệu rằng
các trường ngoại lệ_has_payload, ngoại lệ_payload và ngoại lệ.pending
chứa trạng thái hợp lệ và sẽ được ghi vào VCPU.

Nếu KVM_CAP_X86_TRIPLE_FAULT_EVENT được bật, KVM_VCPUEVENT_VALID_TRIPLE_FAULT
có thể được đặt trong trường cờ để báo hiệu rằng trường triple_fault chứa
trạng thái hợp lệ và sẽ được ghi vào VCPU.

ARM64:
^^^^^^

Không gian người dùng có thể cần đưa vào một số loại sự kiện cho khách.

Đặt trạng thái ngoại lệ SError đang chờ xử lý cho VCPU này. Không thể
'hủy' một lỗi đang chờ xử lý.

Nếu khách thực hiện quyền truy cập vào bộ nhớ I/O mà không thể xử lý được
không gian người dùng, ví dụ như do thiếu giải mã hội chứng hướng dẫn
thông tin hoặc do không có thiết bị nào được ánh xạ tại IPA được truy cập, thì
không gian người dùng có thể yêu cầu kernel thực hiện hủy bỏ bên ngoài bằng địa chỉ
từ lỗi thoát trên VCPU. Đó là một lỗi lập trình để thiết lập
ext_dabt_pending sau một lối thoát không phải là KVM_EXIT_MMIO,
KVM_EXIT_ARM_NISV, hoặc KVM_EXIT_ARM_LDST64B. Tính năng này chỉ khả dụng nếu
hệ thống hỗ trợ KVM_CAP_ARM_INJECT_EXT_DABT. Đây là một người trợ giúp
cung cấp điểm chung trong cách truy cập báo cáo không gian người dùng cho các trường hợp trên
khách, trên các triển khai không gian người dùng khác nhau. Tuy nhiên, không gian người dùng
vẫn có thể mô phỏng tất cả các ngoại lệ của Arm bằng cách thao tác các thanh ghi riêng lẻ
sử dụng KVM_SET_ONE_REG API.

Xem KVM_GET_VCPU_EVENTS để biết cấu trúc dữ liệu.

Việc gọi ioctl này trên vCPU chưa được khởi tạo sẽ trả về
-ENOEXEC.

4.33 KVM_GET_DEBUGREGS
----------------------

:Khả năng: KVM_CAP_DEBUGREGS
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_debugregs (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc các thanh ghi gỡ lỗi từ vcpu.

::

cấu trúc kvm_debugregs {
	__u64db[4];
	__u64 dr6;
	__u64 dr7;
	__u64 cờ;
	__u64 dành riêng[9];
  };


4.34 KVM_SET_DEBUGREGS
----------------------

:Khả năng: KVM_CAP_DEBUGREGS
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_debugregs (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ghi các thanh ghi gỡ lỗi vào vcpu.

Xem KVM_GET_DEBUGREGS để biết cấu trúc dữ liệu. Trường cờ không được sử dụng
chưa và phải được thông quan khi nhập cảnh.


4,35 KVM_SET_USER_MEMORY_REGION
-------------------------------

:Khả năng: KVM_CAP_USER_MEMORY
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_userspace_memory_zone (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_userspace_memory_khu vực {
	__u32 khe cắm;
	__u32 cờ;
	__u64 guest_phys_addr;
	__u64 bộ nhớ_size; /* byte */
	__u64 không gian người dùng_addr; /* bắt đầu bộ nhớ được phân bổ của vùng người dùng */
  };

/* dành cho kvm_userspace_memory_zone::flags */
  #define KVM_MEM_LOG_DIRTY_PAGES (1UL << 0)
  #define KVM_MEM_READONLY (1UL << 1)

Ioctl này cho phép người dùng tạo, sửa đổi hoặc xóa tài khoản vật lý của khách
khe cắm bộ nhớ.  Các bit 0-15 của "khe" chỉ định id vị trí và giá trị này
phải nhỏ hơn số lượng khe cắm bộ nhớ người dùng tối đa được hỗ trợ trên mỗi
VM.  Các khe cắm tối đa được phép có thể được truy vấn bằng KVM_CAP_NR_MEMSLOTS.
Các vị trí có thể không trùng nhau trong không gian địa chỉ vật lý của khách.

Nếu KVM_CAP_MULTI_ADDRESS_SPACE khả dụng, các bit 16-31 của "khe"
chỉ định không gian địa chỉ đang được sửa đổi.  Họ phải là
nhỏ hơn giá trị mà KVM_CHECK_EXTENSION trả về cho
Khả năng KVM_CAP_MULTI_ADDRESS_SPACE.  Các khe trong không gian địa chỉ riêng biệt
không liên quan; hạn chế về các vị trí chồng chéo chỉ áp dụng trong
mỗi không gian địa chỉ.

Việc xóa một vị trí được thực hiện bằng cách chuyển số 0 cho Memory_size.  Khi thay đổi
một khe cắm hiện có, nó có thể được di chuyển vào không gian bộ nhớ vật lý của khách,
hoặc cờ của nó có thể được sửa đổi nhưng không thể thay đổi kích thước.

Bộ nhớ cho vùng được lấy bắt đầu từ địa chỉ được biểu thị bằng
trường userspace_addr, trường này phải trỏ đến bộ nhớ có thể định địa chỉ của người dùng
toàn bộ kích thước khe cắm bộ nhớ.  Bất kỳ đối tượng nào cũng có thể sao lưu bộ nhớ này, bao gồm
bộ nhớ ẩn danh, các tệp thông thường và Hugetlbfs.  Những thay đổi ở mặt sau
của vùng nhớ sẽ tự động được phản ánh vào khách.
Ví dụ: một mmap() ảnh hưởng đến vùng sẽ được hiển thị
ngay lập tức.  Một ví dụ khác là madvise(MADV_DROP).

Trên các kiến trúc hỗ trợ dạng gắn thẻ địa chỉ, userspace_addr phải
là một địa chỉ không được gắn thẻ.

Khuyến nghị rằng 21 bit thấp hơn của guest_phys_addr và userspace_addr
giống hệt nhau.  Điều này cho phép các trang lớn trong máy khách được hỗ trợ bởi các trang lớn
các trang trong máy chủ.

Trường cờ hỗ trợ hai cờ: KVM_MEM_LOG_DIRTY_PAGES và
KVM_MEM_READONLY.  Cái trước có thể được thiết lập để hướng dẫn KVM theo dõi
ghi vào bộ nhớ trong khe.  Xem KVM_GET_DIRTY_LOG ioctl để biết cách
sử dụng nó.  Cái sau có thể được đặt, nếu khả năng của KVM_CAP_READONLY_MEM cho phép,
để tạo một khe mới ở chế độ chỉ đọc.  Trong trường hợp này, việc ghi vào bộ nhớ này sẽ là
được đăng lên không gian người dùng khi KVM_EXIT_MMIO thoát.

Đối với khách TDX, việc xóa/di chuyển vùng bộ nhớ sẽ làm mất nội dung bộ nhớ của khách.
Vùng chỉ đọc không được hỗ trợ.  Chỉ hỗ trợ as-id 0.

Lưu ý: Trên arm64, một thao tác ghi được tạo ra bởi trình đi bộ bảng trang (để cập nhật
ví dụ như cờ Truy cập và Cờ bẩn) không bao giờ dẫn đến
KVM_EXIT_MMIO thoát khi slot có cờ KVM_MEM_READONLY. Cái này
là do KVM không thể cung cấp dữ liệu được ghi bởi
walker bảng trang, khiến cho việc mô phỏng quyền truy cập không thể thực hiện được.
Thay vào đó, hãy hủy bỏ (hủy bỏ dữ liệu nếu nguyên nhân của việc cập nhật bảng trang
là tải hoặc lưu trữ, lệnh sẽ bị hủy nếu đó là lệnh
lấy) được đưa vào máy khách.

S390:
^^^^^

Trả về -EINVAL hoặc -EEXIST nếu VM đã đặt cờ KVM_VM_S390_UCONTROL.
Trả về -EINVAL nếu được gọi trên máy ảo được bảo vệ.

4.36 KVM_SET_TSS_ADDR
---------------------

:Khả năng: KVM_CAP_SET_TSS_ADDR
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: tss_address dài không dấu (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ioctl này xác định địa chỉ vật lý của vùng ba trang trong máy khách
không gian địa chỉ vật lý.  Vùng này phải nằm trong 4GB đầu tiên của
không gian địa chỉ vật lý của khách và không được xung đột với bất kỳ khe cắm bộ nhớ nào
hoặc bất kỳ địa chỉ mmio nào.  Khách có thể gặp trục trặc nếu truy cập vào bộ nhớ này
khu vực.

Ioctl này là bắt buộc trên các máy chủ dựa trên Intel.  Điều này là cần thiết trên phần cứng Intel
do một sai sót trong quá trình triển khai ảo hóa (xem phần nội bộ
tài liệu khi nó xuất hiện).


.. _KVM_ENABLE_CAP:

4.37 KVM_ENABLE_CAP
-------------------

:Khả năng: KVM_CAP_ENABLE_CAP
:Kiến trúc: mips, ppc, s390, x86, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_enable_cap (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

:Khả năng: KVM_CAP_ENABLE_CAP_VM
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_enable_cap (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

.. note::

   Not all extensions are enabled by default. Using this ioctl the application
   can enable an extension, making it available to the guest.

Trên các hệ thống không hỗ trợ ioctl này, nó luôn bị lỗi. Trên các hệ thống
hỗ trợ nó, nó chỉ hoạt động đối với các tiện ích mở rộng được hỗ trợ để kích hoạt.

Để kiểm tra xem một khả năng có thể được bật hay không, KVM_CHECK_EXTENSION ioctl phải
được sử dụng.

::

cấu trúc kvm_enable_cap {
       /* trong */
       __u32 mũ;

Khả năng được cho là sẽ được kích hoạt.

::

__u32 cờ;

Một trường bit cho biết những cải tiến trong tương lai. Hiện tại phải là 0.

::

__u64 lập luận[4];

Các đối số để kích hoạt một tính năng. Nếu một tính năng cần giá trị ban đầu để
hoạt động bình thường thì đây là nơi để đặt chúng.

::

__u8 đệm[64];
  };

Nên sử dụng vcpu ioctl cho các khả năng dành riêng cho vcpu, vm ioctl
cho khả năng trên toàn vm.

4.38 KVM_GET_MP_STATE
---------------------

:Khả năng: KVM_CAP_MP_STATE
:Kiến trúc: x86, s390, arm64, riscv, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_mp_state (out)
:Trả về: 0 nếu thành công; -1 do lỗi

::

cấu trúc kvm_mp_state {
	__u32 mp_state;
  };

Trả về "trạng thái đa xử lý" hiện tại của vcpu (mặc dù cũng hợp lệ trên
khách đơn bộ xử lý).

Các giá trị có thể là:

===============================================================================
   KVM_MP_STATE_RUNNABLE vcpu hiện đang chạy
                                 [x86,arm64,riscv,loongarch]
   KVM_MP_STATE_UNINITIALIZED vcpu là bộ xử lý ứng dụng (AP)
                                 chưa nhận được tín hiệu INIT [x86]
   KVM_MP_STATE_INIT_RECEIVED vcpu đã nhận được tín hiệu INIT và đang
                                 hiện đã sẵn sàng cho SIPI [x86]
   KVM_MP_STATE_HALTED vcpu đã thực thi lệnh HLT và
                                 đang chờ ngắt [x86]
   KVM_MP_STATE_SIPI_RECEIVED vcpu vừa nhận được SIPI (vector
                                 có thể truy cập qua KVM_GET_VCPU_EVENTS) [x86]
   KVM_MP_STATE_STOPPED vcpu bị dừng [s390,arm64,riscv]
   KVM_MP_STATE_CHECK_STOP vcpu đang ở trạng thái lỗi đặc biệt [s390]
   KVM_MP_STATE_OPERATING vcpu đang hoạt động (đang chạy hoặc đã dừng)
                                 [s390]
   KVM_MP_STATE_LOAD vcpu đang ở trạng thái tải/khởi động đặc biệt
                                 [s390]
   KVM_MP_STATE_SUSPENDED vcpu đang ở trạng thái tạm dừng và đang chờ
                                 cho một sự kiện đánh thức [arm64]
   ===============================================================================

Trên x86, ioctl này chỉ hữu ích sau KVM_CREATE_IRQCHIP. Không có
irqchip trong kernel, trạng thái đa xử lý phải được duy trì bởi không gian người dùng trên
những kiến trúc này.

Đối với cánh tay64:
^^^^^^^^^^^^^^^^^^^

Nếu vCPU ở trạng thái KVM_MP_STATE_SUSPENDED, KVM sẽ mô phỏng
thực hiện kiến trúc của lệnh WFI.

Nếu một sự kiện đánh thức được nhận ra, KVM sẽ thoát ra không gian người dùng với một
Lối ra KVM_SYSTEM_EVENT, trong đó loại sự kiện là KVM_SYSTEM_EVENT_WAKEUP. Nếu
không gian người dùng muốn tôn vinh việc đánh thức, nó phải đặt trạng thái MP của vCPU thành
KVM_MP_STATE_RUNNABLE. Nếu không, KVM sẽ tiếp tục chờ đánh thức
sự kiện trong các cuộc gọi tiếp theo tới KVM_RUN.

.. warning::

     If userspace intends to keep the vCPU in a SUSPENDED state, it is
     strongly recommended that userspace take action to suppress the
     wakeup event (such as masking an interrupt). Otherwise, subsequent
     calls to KVM_RUN will immediately exit with a KVM_SYSTEM_EVENT_WAKEUP
     event and inadvertently waste CPU cycles.

     Additionally, if userspace takes action to suppress a wakeup event,
     it is strongly recommended that it also restores the vCPU to its
     original state when the vCPU is made RUNNABLE again. For example,
     if userspace masked a pending interrupt to suppress the wakeup,
     the interrupt should be unmasked before returning control to the
     guest.

Đối với riscv:
^^^^^^^^^^^^^^

Các trạng thái duy nhất hợp lệ là KVM_MP_STATE_STOPPED và
KVM_MP_STATE_RUNNABLE phản ánh liệu vcpu có bị tạm dừng hay không.

Trên LoongArch, chỉ trạng thái KVM_MP_STATE_RUNNABLE được sử dụng để phản ánh
liệu vcpu có thể chạy được hay không.

4.39 KVM_SET_MP_STATE
---------------------

:Khả năng: KVM_CAP_MP_STATE
:Kiến trúc: x86, s390, arm64, riscv, loongarch
:Type: vcpu ioctl
:Thông số: struct kvm_mp_state (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

Đặt "trạng thái đa xử lý" hiện tại của vcpu; xem KVM_GET_MP_STATE để biết
lý lẽ.

Trên x86, ioctl này chỉ hữu ích sau KVM_CREATE_IRQCHIP. Không có
irqchip trong kernel, trạng thái đa xử lý phải được duy trì bởi không gian người dùng trên
những kiến trúc này.

Đối với arm64/riscv:
^^^^^^^^^^^^^^^^^^^^

Các trạng thái duy nhất hợp lệ là KVM_MP_STATE_STOPPED và
KVM_MP_STATE_RUNNABLE phản ánh liệu vcpu có nên tạm dừng hay không.

Trên LoongArch, chỉ trạng thái KVM_MP_STATE_RUNNABLE được sử dụng để phản ánh
liệu vcpu có thể chạy được hay không.

4,40 KVM_SET_IDENTITY_MAP_ADDR
------------------------------

:Khả năng: KVM_CAP_SET_IDENTITY_MAP_ADDR
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: danh tính dài không dấu (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ioctl này xác định địa chỉ vật lý của vùng một trang trong máy khách
không gian địa chỉ vật lý.  Vùng này phải nằm trong 4GB đầu tiên của
không gian địa chỉ vật lý của khách và không được xung đột với bất kỳ khe cắm bộ nhớ nào
hoặc bất kỳ địa chỉ mmio nào.  Khách có thể gặp trục trặc nếu truy cập vào bộ nhớ này
khu vực.

Đặt địa chỉ thành 0 sẽ dẫn đến việc đặt lại địa chỉ về mặc định
(0xfffbc000).

Ioctl này là bắt buộc trên các máy chủ dựa trên Intel.  Điều này là cần thiết trên phần cứng Intel
do một sai sót trong quá trình triển khai ảo hóa (xem phần nội bộ
tài liệu khi nó xuất hiện).

Không thành công nếu bất kỳ VCPU nào đã được tạo.

4.41 KVM_SET_BOOT_CPU_ID
------------------------

:Khả năng: KVM_CAP_SET_BOOT_CPU_ID
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: vcpu_id dài không dấu
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xác định vcpu nào là Bộ xử lý Bootstrap (BSP).  Giá trị giống nhau
làm id vcpu trong KVM_CREATE_VCPU.  Nếu ioctl này không được gọi, mặc định
là vcpu 0. ioctl này phải được gọi trước khi tạo vcpu,
nếu không nó sẽ trả về lỗi EBUSY.


4.42 KVM_GET_XSAVE
------------------

:Khả năng: KVM_CAP_XSAVE
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xsave (out)
:Trả về: 0 nếu thành công, -1 nếu có lỗi


::

cấu trúc kvm_xsave {
	__u32 vùng[1024];
	__u32 thêm[0];
  };

Ioctl này sẽ sao chép cấu trúc xsave của vcpu hiện tại vào không gian người dùng.


4.43 KVM_SET_XSAVE
------------------

:Khả năng: KVM_CAP_XSAVE và KVM_CAP_XSAVE2
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xsave (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::


cấu trúc kvm_xsave {
	__u32 vùng[1024];
	__u32 thêm[0];
  };

Ioctl này sẽ sao chép cấu trúc xsave của không gian người dùng vào kernel. Nó sao chép
số byte được trả về bởi KVM_CHECK_EXTENSION(KVM_CAP_XSAVE2),
khi được gọi trên bộ mô tả tệp vm. Giá trị kích thước được trả về bởi
KVM_CHECK_EXTENSION(KVM_CAP_XSAVE2) sẽ luôn có ít nhất 4096.
Hiện tại, nó chỉ lớn hơn 4096 nếu tính năng động đã được
được bật bằng ZZ0000ZZ, nhưng điều này có thể thay đổi trong tương lai.

Độ lệch của vùng lưu trạng thái trong struct kvm_xsave tuân theo
nội dung của CPUID lá 0xD trên máy chủ.


4.44 KVM_GET_XCRS
-----------------

:Khả năng: KVM_CAP_XCRS
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xcrs (out)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_xcr {
	__u32 xcr;
	__u32 dành riêng;
	giá trị __u64;
  };

cấu trúc kvm_xcrs {
	__u32 nr_xcrs;
	__u32 cờ;
	cấu trúc kvm_xcr xcrs[KVM_MAX_XCRS];
	__u64 phần đệm[16];
  };

Ioctl này sẽ sao chép xcrs của vcpu hiện tại vào không gian người dùng.


4,45 KVM_SET_XCRS
-----------------

:Khả năng: KVM_CAP_XCRS
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xcrs (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_xcr {
	__u32 xcr;
	__u32 dành riêng;
	giá trị __u64;
  };

cấu trúc kvm_xcrs {
	__u32 nr_xcrs;
	__u32 cờ;
	cấu trúc kvm_xcr xcrs[KVM_MAX_XCRS];
	__u64 phần đệm[16];
  };

Ioctl này sẽ đặt xcr của vcpu thành giá trị không gian người dùng được chỉ định.


4.46 KVM_GET_SUPPORTED_CPUID
----------------------------

:Khả năng: KVM_CAP_EXT_CPUID
:Kiến trúc: x86
:Loại: hệ thống ioctl
:Thông số: struct kvm_cpuid2 (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_cpuid2 {
	__u32 không;
	__u32 đệm;
	struct kvm_cpuid_entry2 mục [0];
  };

#define KVM_CPUID_FLAG_SIGNIFCANT_INDEX BIT(0)
  #define KVM_CPUID_FLAG_STATEFUL_FUNC BIT(1) /* không dùng nữa */
  #define KVM_CPUID_FLAG_STATE_READ_NEXT BIT(2) /* không dùng nữa */

cấu trúc kvm_cpuid_entry2 {
	__u32 chức năng;
	chỉ số __u32;
	__u32 cờ;
	__u32 eax;
	__u32 ebx;
	__u32 ecx;
	__u32 edx;
	__u32 đệm [3];
  };

Ioctl này trả về các tính năng cpuid x86 được hỗ trợ bởi cả
phần cứng và kvm trong cấu hình mặc định của nó.  Không gian người dùng có thể sử dụng
thông tin được trả về bởi ioctl này để xây dựng thông tin cpuid (đối với
KVM_SET_CPUID2) phù hợp với phần cứng, kernel và
khả năng của không gian người dùng và với các yêu cầu của người dùng (ví dụ:
người dùng có thể muốn hạn chế cpuid mô phỏng phần cứng cũ hơn hoặc để
tính nhất quán trên một cụm).

Các bit tính năng được kích hoạt động cần phải được yêu cầu với
ZZ0000ZZ trước khi gọi ioctl này. Các bit tính năng chưa có
được yêu cầu sẽ bị loại khỏi kết quả.

Lưu ý rằng một số khả năng nhất định, chẳng hạn như KVM_CAP_X86_DISABLE_EXITS, có thể
hiển thị các tính năng cpuid (ví dụ MONITOR) không được kvm hỗ trợ trong
cấu hình mặc định của nó. Nếu không gian người dùng kích hoạt những khả năng như vậy, nó
có trách nhiệm sửa đổi kết quả của ioctl này một cách thích hợp.

Không gian người dùng gọi KVM_GET_SUPPORTED_CPUID bằng cách chuyển cấu trúc kvm_cpuid2
với trường 'nent' cho biết số lượng mục nhập có kích thước thay đổi
mảng 'mục'.  Nếu số lượng mục quá ít để mô tả CPU
khả năng, một lỗi (E2BIG) sẽ được trả về.  Nếu số lượng quá cao,
trường 'nent' được điều chỉnh và trả về lỗi (ENOMEM).  Nếu
số vừa phải, trường 'nent' được điều chỉnh thành số hợp lệ
các mục trong mảng 'mục', sau đó được điền vào.

Các mục được trả về là cpuid của máy chủ được trả về bởi lệnh cpuid,
với các tính năng không xác định hoặc không được hỗ trợ bị che giấu.  Một số tính năng (ví dụ:
x2apic), có thể không có trong CPU chủ, nhưng sẽ bị kvm hiển thị nếu có thể
bắt chước chúng một cách hiệu quả. Các trường trong mỗi mục được xác định như sau:

chức năng:
         giá trị eax được sử dụng để có được mục nhập

chỉ số:
         giá trị ecx được sử dụng để lấy mục nhập (đối với các mục nhập
         bị ảnh hưởng bởi ecx)

cờ:
     OR bằng 0 hoặc nhiều hơn trong số các điều sau:

KVM_CPUID_FLAG_SIGNIFCANT_INDEX:
           nếu trường chỉ mục hợp lệ

eax, ebx, ecx, edx:
         các giá trị được trả về bởi lệnh cpuid cho
         sự kết hợp chức năng/chỉ số này

x2APIC (CPUID lá 1, ecx[21) và bộ đếm thời hạn TSC (CPUID lá 1, ecx[24])
có thể được trả về là đúng, nhưng chúng phụ thuộc vào KVM_CREATE_IRQCHIP cho dữ liệu trong kernel
mô phỏng APIC cục bộ.  Hỗ trợ hẹn giờ thời hạn TSC cũng được báo cáo qua::

ioctl(KVM_CHECK_EXTENSION, KVM_CAP_TSC_DEADLINE_TIMER)

nếu điều đó trả về đúng và bạn sử dụng KVM_CREATE_IRQCHIP hoặc nếu bạn mô phỏng
trong không gian người dùng, thì bạn có thể bật tính năng này cho KVM_SET_CPUID2.

Kích hoạt x2APIC trong KVM_SET_CPUID2 yêu cầu KVM_CREATE_IRQCHIP vì KVM thì không
hỗ trợ chuyển tiếp x2APIC MSR truy cập vào không gian người dùng, tức là KVM không hỗ trợ
mô phỏng x2APIC trong không gian người dùng.

4.47 KVM_PPC_GET_PVINFO
-----------------------

:Khả năng: KVM_CAP_PPC_GET_PVINFO
:Kiến trúc: ppc
:Type: vm ioctl
:Thông số: struct kvm_ppc_pvinfo (ra)
:Trả về: 0 nếu thành công, !0 nếu có lỗi

::

cấu trúc kvm_ppc_pvinfo {
	__u32 cờ;
	__u32 hcall[4];
	__u8 đệm[108];
  };

Ioctl này lấy thông tin cụ thể của PV cần được chuyển cho khách
sử dụng cây thiết bị hoặc các phương tiện khác từ ngữ cảnh vm.

Mảng hcall xác định 4 lệnh tạo nên một hypercall.

Nếu sau này bất kỳ trường bổ sung nào được thêm vào cấu trúc này, một chút cho điều đó
phần thông tin bổ sung sẽ được đặt trong bitmap cờ.

Bitmap cờ được định nghĩa là::

/* máy chủ hỗ trợ hcall nhàn rỗi ePAPR
   #define KVM_PPC_PVINFO_FLAGS_EV_IDLE (1<<0)

4.52 KVM_SET_GSI_ROUTING
------------------------

:Khả năng: KVM_CAP_IRQ_ROUTING
:Kiến trúc: x86 s390 arm64
:Type: vm ioctl
:Thông số: struct kvm_irq_routing (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt các mục trong bảng định tuyến GSI, ghi đè bất kỳ mục nào đã đặt trước đó.

Trên arm64, định tuyến GSI có giới hạn sau:

- Định tuyến GSI không áp dụng cho KVM_IRQ_LINE mà chỉ áp dụng cho KVM_IRQFD.

::

cấu trúc kvm_irq_routing {
	__u32 nr;
	__u32 cờ;
	struct kvm_irq_routing_entryentry[0];
  };

Cho đến nay, không có cờ nào được chỉ định, trường tương ứng phải được đặt thành 0.

::

cấu trúc kvm_irq_routing_entry {
	__u32 gsi;
	__u32 loại;
	__u32 cờ;
	__u32 đệm;
	công đoàn {
		cấu trúc kvm_irq_routing_irqchip irqchip;
		struct kvm_irq_routing_msi msi;
		bộ điều hợp struct kvm_irq_routing_s390_adapter;
		cấu trúc kvm_irq_routing_hv_sint hv_sint;
		struct kvm_irq_routing_xen_evtchn xen_evtchn;
		__u32 đệm[8];
	} bạn;
  };

/* các loại mục nhập định tuyến gsi */
  #define KVM_IRQ_ROUTING_IRQCHIP 1
  #define KVM_IRQ_ROUTING_MSI 2
  #define KVM_IRQ_ROUTING_S390_ADAPTER 3
  #define KVM_IRQ_ROUTING_HV_SINT 4
  #define KVM_IRQ_ROUTING_XEN_EVTCHN 5

Trên s390, việc thêm KVM_IRQ_ROUTING_S390_ADAPTER bị từ chối trên máy ảo ucontrol có
lỗi -EINVAL.

cờ:

- KVM_MSI_VALID_DEVID: được sử dụng cùng với mục định tuyến KVM_IRQ_ROUTING_MSI
  type, chỉ định rằng trường devid chứa giá trị hợp lệ.  Mỗi VM
  Khả năng KVM_CAP_MSI_DEVID quảng cáo yêu cầu cung cấp
  ID thiết bị.  Nếu khả năng này không có sẵn, không gian người dùng sẽ
  không bao giờ đặt cờ KVM_MSI_VALID_DEVID vì ioctl có thể bị lỗi.
- không nếu không thì

::

cấu trúc kvm_irq_routing_irqchip {
	__u32 irqchip;
	__u32 chân;
  };

cấu trúc kvm_irq_routing_msi {
	__u32 địa chỉ_lo;
	__u32 địa chỉ_xin chào;
	__u32 dữ liệu;
	công đoàn {
		__u32 đệm;
		__u32 khác biệt;
	};
  };

Nếu KVM_MSI_VALID_DEVID được đặt, devid chứa mã nhận dạng thiết bị duy nhất
cho thiết bị đã viết tin nhắn MSI.  Đối với PCI, đây thường là một
Mã định danh BDF ở 16 bit thấp hơn.

Trên x86, address_hi bị bỏ qua trừ khi KVM_X2APIC_API_USE_32BIT_IDS
tính năng của khả năng KVM_CAP_X2APIC_API được kích hoạt.  Nếu nó được kích hoạt,
địa chỉ_hi bit 31-8 cung cấp bit 31-8 của id đích.  Bit 7-0 của
address_hi phải bằng 0.

::

cấu trúc kvm_irq_routing_s390_adapter {
	__u64 ind_addr;
	__u64 tóm tắt_addr;
	__u64 ind_offset;
	__u32 tóm tắt_offset;
	__u32 bộ chuyển đổi_id;
  };

cấu trúc kvm_irq_routing_hv_sint {
	__u32 vcpu;
	__u32 tội lỗi;
  };

cấu trúc kvm_irq_routing_xen_evtchn {
	__u32 cổng;
	__u32 vcpu;
	__u32 ưu tiên;
  };


Khi KVM_CAP_XEN_HVM bao gồm bit KVM_XEN_HVM_CONFIG_EVTCHN_2LEVEL
trong chỉ báo về các tính năng được hỗ trợ, định tuyến tới các kênh sự kiện Xen
được hỗ trợ. Mặc dù có trường ưu tiên nhưng chỉ có giá trị
KVM_XEN_HVM_CONFIG_EVTCHN_2LEVEL được hỗ trợ, có nghĩa là giao hàng bằng
Kênh sự kiện 2 cấp. Hỗ trợ kênh sự kiện FIFO có thể được thêm vào
tương lai.


4,55 KVM_SET_TSC_KHZ
--------------------

:Khả năng: KVM_CAP_TSC_CONTROL / KVM_CAP_VM_TSC_CONTROL
:Kiến trúc: x86
:Type: vcpu ioctl / vm ioctl
:Thông số: tsc_khz ảo
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Chỉ định tần số tsc cho máy ảo. Đơn vị của
tần số là KHz.

Nếu khả năng KVM_CAP_VM_TSC_CONTROL được quảng cáo, điều này cũng có thể
được sử dụng như một vm ioctl để đặt tần số tsc ban đầu sau đó
đã tạo vCPU.  Lưu ý, vm ioctl chỉ được phép trước khi tạo vCPU.

Đối với máy ảo Điện toán bí mật (CoCo) được bảo vệ TSC có tần số TSC
được cấu hình một lần ở phạm vi VM và không thay đổi trong quá trình VM
trọn đời, nên sử dụng vm ioctl để định cấu hình tần số TSC
và vcpu ioctl không được hỗ trợ.

Ví dụ về các máy ảo CoCo như vậy: khách TDX.

4,56 KVM_GET_TSC_KHZ
--------------------

:Khả năng: KVM_CAP_GET_TSC_KHZ / KVM_CAP_VM_TSC_CONTROL
:Kiến trúc: x86
:Type: vcpu ioctl / vm ioctl
:Thông số: không có
:Trả về: tsc-khz ảo khi thành công, giá trị âm khi có lỗi

Trả về tần số tsc của khách. Đơn vị của giá trị trả về là
KHz. Nếu máy chủ có tsc không ổn định thì ioctl này sẽ trả về -EIO dưới dạng
lỗi.


4,57 KVM_GET_LAPIC
------------------

:Khả năng: KVM_CAP_IRQCHIP
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_lapic_state (out)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

#define KVM_APIC_REG_SIZE 0x400
  cấu trúc kvm_lapic_state {
	char reg[KVM_APIC_REG_SIZE];
  };

Đọc các thanh ghi APIC cục bộ và sao chép chúng vào đối số đầu vào.  các
định dạng và bố cục dữ liệu giống như được ghi trong sổ tay kiến trúc.

Nếu tính năng KVM_X2APIC_API_USE_32BIT_IDS của KVM_CAP_X2APIC_API là
được bật thì định dạng của thanh ghi APIC_ID sẽ phụ thuộc vào chế độ APIC
(được báo cáo bởi MSR_IA32_APICBASE) của VCPU của nó.  x2APIC lưu trữ ID APIC trong
thanh ghi APIC_ID (byte 32-35).  xAPIC chỉ cho phép ID APIC 8 bit
được lưu trữ trong các bit 31-24 của thanh ghi APIC hoặc tương đương trong
byte 35 của trường reg của struct kvm_lapic_state.  KVM_GET_LAPIC thì phải
được gọi sau khi MSR_IA32_APICBASE được đặt bằng KVM_SET_MSR.

Nếu tính năng KVM_X2APIC_API_USE_32BIT_IDS bị tắt, struct kvm_lapic_state
luôn sử dụng định dạng xAPIC.


4,58 KVM_SET_LAPIC
------------------

:Khả năng: KVM_CAP_IRQCHIP
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_lapic_state (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

#define KVM_APIC_REG_SIZE 0x400
  cấu trúc kvm_lapic_state {
	char reg[KVM_APIC_REG_SIZE];
  };

Sao chép đối số đầu vào vào các thanh ghi APIC cục bộ.  Định dạng dữ liệu
và bố cục giống như được ghi lại trong sổ tay kiến trúc.

Định dạng của thanh ghi ID APIC (byte 32-35 của struct kvm_lapic_state
regs) phụ thuộc vào trạng thái của khả năng KVM_CAP_X2APIC_API.
Xem ghi chú trong KVM_GET_LAPIC.


4,59 KVM_IOEVENTFD
------------------

:Khả năng: KVM_CAP_IOEVENTFD
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_ioeventfd (trong)
:Trả về: 0 nếu thành công, !0 nếu có lỗi

ioctl này gắn hoặc tách ioeventfd vào địa chỉ pio/mmio hợp pháp
bên trong khách.  Một vị khách viết vào địa chỉ đã đăng ký sẽ báo hiệu
sự kiện được cung cấp thay vì kích hoạt một lối thoát.

::

cấu trúc kvm_ioeventfd {
	__u64 kết hợp dữ liệu;
	__u64 địa chỉ;        /* địa chỉ pio/mmio hợp pháp */
	__u32 len;         /* 0, 1, 2, 4 hoặc 8 byte */
	__s32 fd;
	__u32 cờ;
	__u8 đệm[36];
  };

Đối với trường hợp đặc biệt của thiết bị virtio-ccw trên s390, sự kiện trùng khớp
thay vào đó là một bộ dữ liệu kênh con/hàng đợi ảo.

Các cờ sau được xác định::

#define KVM_IOEVENTFD_FLAG_DATAMATCH (1 << kvm_ioeventfd_flag_nr_datamatch)
  #define KVM_IOEVENTFD_FLAG_PIO (1 << kvm_ioeventfd_flag_nr_pio)
  #define KVM_IOEVENTFD_FLAG_DEASSIGN (1 << kvm_ioeventfd_flag_nr_design)
  #define KVM_IOEVENTFD_FLAG_VIRTIO_CCW_NOTIFY \
	(1 << kvm_ioeventfd_flag_nr_virtio_ccw_notify)

Nếu cờ datamatch được đặt, sự kiện sẽ chỉ được báo hiệu nếu giá trị được ghi
đến địa chỉ đã đăng ký bằng datamatch trong struct kvm_ioeventfd.

Đối với các thiết bị virtio-ccw, addr chứa id kênh con và khớp dữ liệu với
chỉ số đức hạnh.

Với KVM_CAP_IOEVENTFD_ANY_LENGTH, ioeventfd có độ dài bằng 0 được cho phép và
kernel sẽ bỏ qua độ dài của lệnh ghi của khách và có thể nhận được vmexit nhanh hơn.
Việc tăng tốc chỉ có thể áp dụng cho các kiến trúc cụ thể, nhưng ioeventfd sẽ
dù sao cũng làm việc.

4,60 KVM_DIRTY_TLB
------------------

:Khả năng: KVM_CAP_SW_TLB
:Kiến trúc: ppc
:Type: vcpu ioctl
:Thông số: struct kvm_dirty_tlb (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_dirty_tlb {
	__u64 bitmap;
	__u32 num_dirty;
  };

Điều này phải được gọi bất cứ khi nào không gian người dùng thay đổi một mục trong phần chia sẻ
TLB, trước khi gọi KVM_RUN trên vcpu được liên kết.

Trường "bitmap" là địa chỉ không gian người dùng của một mảng.  Mảng này
bao gồm một số bit, bằng tổng số mục TLB như
được xác định bởi cuộc gọi thành công cuối cùng tới ZZ0000ZZ,
làm tròn lên bội số gần nhất của 64.

Mỗi bit tương ứng với một mục TLB, được sắp xếp giống như trong TLB được chia sẻ
mảng.

Mảng có dạng little-endian: bit 0 là bit có trọng số nhỏ nhất của
byte đầu tiên, bit 8 là bit có trọng số thấp nhất của byte thứ hai, v.v.
Điều này tránh mọi sự phức tạp với kích thước từ khác nhau.

Trường "num_dirty" là gợi ý hiệu suất cho KVM để xác định xem nó có
nên bỏ qua việc xử lý bitmap và vô hiệu hóa mọi thứ.  Nó phải
được đặt thành số bit được đặt trong bitmap.


4.62 KVM_CREATE_SPAPR_TCE
-------------------------

:Khả năng: KVM_CAP_SPAPR_TCE
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: struct kvm_create_spapr_tce (trong)
:Trả về: bộ mô tả tệp để thao tác bảng TCE đã tạo

Điều này tạo ra một bảng TCE (mục kiểm soát dịch thuật) ảo, bảng này
là IOMMU dành cho I/O ảo kiểu PAPR.  Nó được dùng để dịch
địa chỉ logic được sử dụng trong I/O ảo thành địa chỉ vật lý của khách,
và cung cấp khả năng phân tán/thu thập cho I/O ảo PAPR.

::

/* cho KVM_CAP_SPAPR_TCE */
  cấu trúc kvm_create_spapr_tce {
	__u64 sư tử;
	__u32 kích thước cửa sổ;
  };

Trường liobn cung cấp số bus IO hợp lý để tạo một
Bàn TCE.  Trường window_size chỉ định kích thước của cửa sổ DMA
mà bảng TCE này sẽ dịch - bảng sẽ chứa một 64
mục nhập bit TCE cho mỗi 4kiB của cửa sổ DMA.

Khi khách phát hành H_PUT_TCE hcall trên liobn có TCE
bảng đã được tạo bằng ioctl() này, kernel sẽ xử lý nó
ở chế độ thực, cập nhật bảng TCE.  H_PUT_TCE gọi cho người khác
liobns sẽ gây ra lỗi thoát vm và phải được xử lý bởi không gian người dùng.

Giá trị trả về là một bộ mô tả tệp có thể được chuyển tới mmap(2)
để ánh xạ bảng TCE đã tạo vào không gian người dùng.  Điều này cho phép không gian người dùng đọc
các mục được viết bởi lệnh gọi H_PUT_TCE do kernel xử lý và cũng cho phép
không gian người dùng cập nhật trực tiếp bảng TCE, điều này rất hữu ích trong một số
hoàn cảnh.


4,64 KVM_NMI
------------

:Khả năng: KVM_CAP_USER_NMI
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xếp hàng NMI trên vcpu của luồng.  Lưu ý điều này chỉ được xác định rõ
khi KVM_CREATE_IRQCHIP chưa được gọi, vì đây là giao diện
giữa lõi cpu ảo và APIC cục bộ ảo.  Sau KVM_CREATE_IRQCHIP
đã được gọi, giao diện này được mô phỏng hoàn toàn trong kernel.

Để sử dụng tính năng này để mô phỏng đầu vào LINT1 với KVM_CREATE_IRQCHIP, hãy sử dụng
thuật toán sau:

- tạm dừng vcpu
  - đọc trạng thái của APIC cục bộ (KVM_GET_LAPIC)
  - kiểm tra xem việc thay đổi LINT1 có xếp hàng NMI hay không (xem mục nhập LVT cho LINT1)
  - nếu vậy, hãy phát hành KVM_NMI
  - tiếp tục vcpu

Một số khách định cấu hình đầu vào LINT1 NMI để gây hoảng loạn, hỗ trợ
gỡ lỗi.


4,65 KVM_S390_UCAS_MAP
----------------------

:Khả năng: KVM_CAP_S390_UCONTROL
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: struct kvm_s390_ucas_mapping (trong)
:Trả về: 0 trong trường hợp thành công

Tham số được xác định như sau::

cấu trúc kvm_s390_ucas_mapping {
		__u64 user_addr;
		__u64 vcpu_addr;
		__u64 chiều dài;
	};

Ioctl này ánh xạ bộ nhớ tại "user_addr" với độ dài "length" thành
không gian địa chỉ của vcpu bắt đầu từ "vcpu_addr". Tất cả các thông số cần
được căn chỉnh theo 1 megabyte.


4,66 KVM_S390_UCAS_UNMAP
------------------------

:Khả năng: KVM_CAP_S390_UCONTROL
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: struct kvm_s390_ucas_mapping (trong)
:Trả về: 0 trong trường hợp thành công

Tham số được xác định như sau::

cấu trúc kvm_s390_ucas_mapping {
		__u64 user_addr;
		__u64 vcpu_addr;
		__u64 chiều dài;
	};

Ioctl này hủy ánh xạ bộ nhớ trong không gian địa chỉ của vcpu bắt đầu từ
"vcpu_addr" có độ dài "length". Trường "user_addr" bị bỏ qua.
Tất cả các tham số cần được căn chỉnh theo 1 megabyte.


4,67 KVM_S390_VCPU_FAULT
------------------------

:Khả năng: KVM_CAP_S390_UCONTROL
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: địa chỉ tuyệt đối của vcpu (trong)
:Trả về: 0 trong trường hợp thành công

Cuộc gọi này tạo một mục trong bảng trang trên không gian địa chỉ của CPU ảo
(đối với máy ảo do người dùng điều khiển) hoặc địa chỉ của máy ảo
không gian (đối với máy ảo thông thường). Cách này chỉ có tác dụng với những lỗi nhỏ
do đó nên truy cập trang bộ nhớ chủ đề thông qua trang người dùng
bảng trả trước. Điều này rất hữu ích để xử lý các chặn hợp lệ cho người dùng
các máy ảo được kiểm soát gặp lỗi trong các trang lõi thấp của CPU ảo
trước khi gọi KVM_RUN ioctl.


4,68 KVM_SET_ONE_REG
--------------------

:Khả năng: KVM_CAP_ONE_REG
:Kiến trúc: tất cả
:Type: vcpu ioctl
:Thông số: struct kvm_one_reg (trong)
:Trả về: 0 nếu thành công, giá trị âm nếu thất bại

Lỗi:

=======================================================================
  ENOENT không có đăng ký như vậy
  EINVAL ID đăng ký không hợp lệ hoặc không có đăng ký như vậy hoặc được sử dụng với máy ảo trong
           chế độ ảo hóa được bảo vệ trên s390
  Không được phép truy cập đăng ký EPERM (arm64) trước khi hoàn tất vcpu
  EBUSY (riscv) không được phép thay đổi giá trị đăng ký sau vcpu
           đã chạy ít nhất một lần
  =======================================================================

(Các mã lỗi này chỉ mang tính biểu thị: không dựa vào một lỗi cụ thể nào
mã được trả về trong một tình huống cụ thể.)

::

cấu trúc kvm_one_reg {
       __u64 id;
       __u64 địa chỉ;
 };

Sử dụng ioctl này, một thanh ghi vcpu có thể được đặt thành một giá trị cụ thể
được xác định bởi không gian người dùng với thông tin được truyền trong struct kvm_one_reg, trong đó id
đề cập đến mã định danh đăng ký như được mô tả bên dưới và addr là một con trỏ
đến một biến có kích thước tương ứng. Có thể có kiến trúc bất khả tri
và các thanh ghi kiến trúc cụ thể. Mỗi người có phạm vi hoạt động riêng
và các hằng số và chiều rộng riêng của chúng. Để theo dõi việc thực hiện
đăng ký, tìm danh sách dưới đây:

======= ===============================================
  Độ rộng thanh ghi vòm (bit)
  ======= ===============================================
  PPC KVM_REG_PPC_HIOR 64
  PPC KVM_REG_PPC_IAC1 64
  PPC KVM_REG_PPC_IAC2 64
  PPC KVM_REG_PPC_IAC3 64
  PPC KVM_REG_PPC_IAC4 64
  PPC KVM_REG_PPC_DAC1 64
  PPC KVM_REG_PPC_DAC2 64
  PPC KVM_REG_PPC_DABR 64
  PPC KVM_REG_PPC_DSCR 64
  PPC KVM_REG_PPC_PURR 64
  PPC KVM_REG_PPC_SPURR 64
  PPC KVM_REG_PPC_DAR 64
  PPC KVM_REG_PPC_DSISR 32
  PPC KVM_REG_PPC_AMR 64
  PPC KVM_REG_PPC_UAMOR 64
  PPC KVM_REG_PPC_MMCR0 64
  PPC KVM_REG_PPC_MMCR1 64
  PPC KVM_REG_PPC_MMCRA 64
  PPC KVM_REG_PPC_MMCR2 64
  PPC KVM_REG_PPC_MMCRS 64
  PPC KVM_REG_PPC_MMCR3 64
  PPC KVM_REG_PPC_SIAR 64
  PPC KVM_REG_PPC_SDAR 64
  PPC KVM_REG_PPC_SIER 64
  PPC KVM_REG_PPC_SIER2 64
  PPC KVM_REG_PPC_SIER3 64
  PPC KVM_REG_PPC_PMC1 32
  PPC KVM_REG_PPC_PMC2 32
  PPC KVM_REG_PPC_PMC3 32
  PPC KVM_REG_PPC_PMC4 32
  PPC KVM_REG_PPC_PMC5 32
  PPC KVM_REG_PPC_PMC6 32
  PPC KVM_REG_PPC_PMC7 32
  PPC KVM_REG_PPC_PMC8 32
  PPC KVM_REG_PPC_FPR0 64
  ...
PPC KVM_REG_PPC_FPR31 64
  PPC KVM_REG_PPC_VR0 128
  ...
PPC KVM_REG_PPC_VR31 128
  PPC KVM_REG_PPC_VSR0 128
  ...
PPC KVM_REG_PPC_VSR31 128
  PPC KVM_REG_PPC_FPSCR 64
  PPC KVM_REG_PPC_VSCR 32
  PPC KVM_REG_PPC_VPA_ADDR 64
  PPC KVM_REG_PPC_VPA_SLB 128
  PPC KVM_REG_PPC_VPA_DTL 128
  PPC KVM_REG_PPC_EPCR 32
  PPC KVM_REG_PPC_EPR 32
  PPC KVM_REG_PPC_TCR 32
  PPC KVM_REG_PPC_TSR 32
  PPC KVM_REG_PPC_OR_TSR 32
  PPC KVM_REG_PPC_CLEAR_TSR 32
  PPC KVM_REG_PPC_MAS0 32
  PPC KVM_REG_PPC_MAS1 32
  PPC KVM_REG_PPC_MAS2 64
  PPC KVM_REG_PPC_MAS7_3 64
  PPC KVM_REG_PPC_MAS4 32
  PPC KVM_REG_PPC_MAS6 32
  PPC KVM_REG_PPC_MMUCFG 32
  PPC KVM_REG_PPC_TLB0CFG 32
  PPC KVM_REG_PPC_TLB1CFG 32
  PPC KVM_REG_PPC_TLB2CFG 32
  PPC KVM_REG_PPC_TLB3CFG 32
  PPC KVM_REG_PPC_TLB0PS 32
  PPC KVM_REG_PPC_TLB1PS 32
  PPC KVM_REG_PPC_TLB2PS 32
  PPC KVM_REG_PPC_TLB3PS 32
  PPC KVM_REG_PPC_EPTCFG 32
  PPC KVM_REG_PPC_ICP_STATE 64
  PPC KVM_REG_PPC_VP_STATE 128
  PPC KVM_REG_PPC_TB_OFFSET 64
  PPC KVM_REG_PPC_SPMC1 32
  PPC KVM_REG_PPC_SPMC2 32
  PPC KVM_REG_PPC_IAMR 64
  PPC KVM_REG_PPC_TFHAR 64
  PPC KVM_REG_PPC_TFIAR 64
  PPC KVM_REG_PPC_TEXASR 64
  PPC KVM_REG_PPC_FSCR 64
  PPC KVM_REG_PPC_PSPB 32
  PPC KVM_REG_PPC_EBBHR 64
  PPC KVM_REG_PPC_EBBRR 64
  PPC KVM_REG_PPC_BESCR 64
  PPC KVM_REG_PPC_TAR 64
  PPC KVM_REG_PPC_DPDES 64
  PPC KVM_REG_PPC_DAWR 64
  PPC KVM_REG_PPC_DAWRX 64
  PPC KVM_REG_PPC_CIABR 64
  PPC KVM_REG_PPC_IC 64
  PPC KVM_REG_PPC_VTB 64
  PPC KVM_REG_PPC_CSIGR 64
  PPC KVM_REG_PPC_TACR 64
  PPC KVM_REG_PPC_TCSCR 64
  PPC KVM_REG_PPC_PID 64
  PPC KVM_REG_PPC_ACOP 64
  PPC KVM_REG_PPC_VRSAVE 32
  PPC KVM_REG_PPC_LPCR 32
  PPC KVM_REG_PPC_LPCR_64 64
  PPC KVM_REG_PPC_PPR 64
  PPC KVM_REG_PPC_ARCH_COMPAT 32
  PPC KVM_REG_PPC_DABRX 32
  PPC KVM_REG_PPC_WORT 64
  PPC KVM_REG_PPC_SPRG9 64
  PPC KVM_REG_PPC_DBSR 32
  PPC KVM_REG_PPC_TIDR 64
  PPC KVM_REG_PPC_PSSCR 64
  PPC KVM_REG_PPC_DEC_EXPIRY 64
  PPC KVM_REG_PPC_PTCR 64
  PPC KVM_REG_PPC_HASHKEYR 64
  PPC KVM_REG_PPC_HASHPKEYR 64
  PPC KVM_REG_PPC_DAWR1 64
  PPC KVM_REG_PPC_DAWRX1 64
  PPC KVM_REG_PPC_DEXCR 64
  PPC KVM_REG_PPC_TM_GPR0 64
  ...
PPC KVM_REG_PPC_TM_GPR31 64
  PPC KVM_REG_PPC_TM_VSR0 128
  ...
PPC KVM_REG_PPC_TM_VSR63 128
  PPC KVM_REG_PPC_TM_CR 64
  PPC KVM_REG_PPC_TM_LR 64
  PPC KVM_REG_PPC_TM_CTR 64
  PPC KVM_REG_PPC_TM_FPSCR 64
  PPC KVM_REG_PPC_TM_AMR 64
  PPC KVM_REG_PPC_TM_PPR 64
  PPC KVM_REG_PPC_TM_VRSAVE 64
  PPC KVM_REG_PPC_TM_VSCR 32
  PPC KVM_REG_PPC_TM_DSCR 64
  PPC KVM_REG_PPC_TM_TAR 64
  PPC KVM_REG_PPC_TM_XER 64

MIPS KVM_REG_MIPS_R0 64
  ...
MIPS KVM_REG_MIPS_R31 64
  MIPS KVM_REG_MIPS_HI 64
  MIPS KVM_REG_MIPS_LO 64
  MIPS KVM_REG_MIPS_PC 64
  MIPS KVM_REG_MIPS_CP0_INDEX 32
  MIPS KVM_REG_MIPS_CP0_ENTRYLO0 64
  MIPS KVM_REG_MIPS_CP0_ENTRYLO1 64
  MIPS KVM_REG_MIPS_CP0_CONTEXT 64
  MIPS KVM_REG_MIPS_CP0_CONTEXTCONFIG 32
  MIPS KVM_REG_MIPS_CP0_USERLOCAL 64
  MIPS KVM_REG_MIPS_CP0_XCONTEXTCONFIG 64
  MIPS KVM_REG_MIPS_CP0_PAGEMASK 32
  MIPS KVM_REG_MIPS_CP0_PAGEGRAIN 32
  MIPS KVM_REG_MIPS_CP0_SEGCTL0 64
  MIPS KVM_REG_MIPS_CP0_SEGCTL1 64
  MIPS KVM_REG_MIPS_CP0_SEGCTL2 64
  MIPS KVM_REG_MIPS_CP0_PWBASE 64
  MIPS KVM_REG_MIPS_CP0_PWFIELD 64
  MIPS KVM_REG_MIPS_CP0_PWSIZE 64
  MIPS KVM_REG_MIPS_CP0_WIRED 32
  MIPS KVM_REG_MIPS_CP0_PWCTL 32
  MIPS KVM_REG_MIPS_CP0_HWRENA 32
  MIPS KVM_REG_MIPS_CP0_BADVADDR 64
  MIPS KVM_REG_MIPS_CP0_BADINSTR 32
  MIPS KVM_REG_MIPS_CP0_BADINSTRP 32
  MIPS KVM_REG_MIPS_CP0_COUNT 32
  MIPS KVM_REG_MIPS_CP0_ENTRYHI 64
  MIPS KVM_REG_MIPS_CP0_COMPARE 32
  MIPS KVM_REG_MIPS_CP0_STATUS 32
  MIPS KVM_REG_MIPS_CP0_INTCTL 32
  MIPS KVM_REG_MIPS_CP0_CAUSE 32
  MIPS KVM_REG_MIPS_CP0_EPC 64
  MIPS KVM_REG_MIPS_CP0_PRID 32
  MIPS KVM_REG_MIPS_CP0_EBASE 64
  MIPS KVM_REG_MIPS_CP0_CONFIG 32
  MIPS KVM_REG_MIPS_CP0_CONFIG1 32
  MIPS KVM_REG_MIPS_CP0_CONFIG2 32
  MIPS KVM_REG_MIPS_CP0_CONFIG3 32
  MIPS KVM_REG_MIPS_CP0_CONFIG4 32
  MIPS KVM_REG_MIPS_CP0_CONFIG5 32
  MIPS KVM_REG_MIPS_CP0_CONFIG7 32
  MIPS KVM_REG_MIPS_CP0_XCONTEXT 64
  MIPS KVM_REG_MIPS_CP0_ERROREPC 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH1 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH2 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH3 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH4 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH5 64
  MIPS KVM_REG_MIPS_CP0_KSCRATCH6 64
  MIPS KVM_REG_MIPS_CP0_MAAR(0..63) 64
  MIPS KVM_REG_MIPS_COUNT_CTL 64
  MIPS KVM_REG_MIPS_COUNT_RESUME 64
  MIPS KVM_REG_MIPS_COUNT_HZ 64
  MIPS KVM_REG_MIPS_FPR_32(0..31) 32
  MIPS KVM_REG_MIPS_FPR_64(0..31) 64
  MIPS KVM_REG_MIPS_VEC_128(0..31) 128
  MIPS KVM_REG_MIPS_FCR_IR 32
  MIPS KVM_REG_MIPS_FCR_CSR 32
  MIPS KVM_REG_MIPS_MSA_IR 32
  MIPS KVM_REG_MIPS_MSA_CSR 32
  ======= ===============================================

Các thanh ghi ARM được ánh xạ bằng 32 bit thấp hơn.  16 trên đó
là loại nhóm đăng ký hoặc số bộ đồng xử lý:

Các thanh ghi lõi ARM có các mẫu bit id sau::

0x4020 0000 0010 <chỉ mục vào cấu trúc kvm_regs:16>

Các thanh ghi ARM 32-bit CP15 có các mẫu bit id sau::

0x4020 0000 000F <zero:1> <crn:4> <crm:4> <opc1:4> <opc2:3>

Các thanh ghi ARM 64-bit CP15 có các mẫu bit id sau::

0x4030 0000 000F <zero:1> <zero:4> <crm:4> <opc1:4> <zero:3>

Các thanh ghi ARM CCSIDR được phân kênh theo giá trị CSSELR::

0x4020 0000 0011 00 <csselr:8>

Thanh ghi điều khiển ARM 32-bit VFP có các mẫu bit id sau::

0x4020 0000 0012 1 <regno:12>

Các thanh ghi FP 64-bit ARM có các mẫu bit id sau::

0x4030 0000 0012 0 <regno:12>

Các thanh ghi giả phần sụn ARM có mẫu bit sau ::

0x4030 0000 0014 <regno:16>


các thanh ghi arm64 được ánh xạ bằng 32 bit thấp hơn. 16 trên của
đó là loại nhóm đăng ký hoặc số bộ đồng xử lý:

Các thanh ghi lõi arm64/FP-SIMD có các mẫu bit id sau. Lưu ý
rằng kích thước của quyền truy cập có thể thay đổi, vì cấu trúc kvm_regs
chứa các phần tử có kích thước từ 32 đến 128 bit. Chỉ mục là 32 bit
giá trị trong cấu trúc kvm_regs được xem dưới dạng mảng 32 bit::

0x60x0 0000 0010 <chỉ mục vào cấu trúc kvm_regs:16>

Cụ thể:

================================================================================
    Mã hóa Đăng ký Bits thành viên kvm_regs
================================================================================
  0x6030 0000 0010 0000 X0 64 reg.regs[0]
  0x6030 0000 0010 0002 X1 64 reg.regs[1]
  ...
0x6030 0000 0010 003c X30 64 regs.regs[30]
  0x6030 0000 0010 003e SP 64 regs.sp
  0x6030 0000 0010 0040 PC 64 regs.pc
  0x6030 0000 0010 0042 PSTATE 64 regs.pstate
  0x6030 0000 0010 0044 SP_EL1 64 sp_el1
  0x6030 0000 0010 0046 ELR_EL1 64 elr_el1
  0x6030 0000 0010 0048 SPSR_EL1 64 spsr[KVM_SPSR_EL1] (bí danh SPSR_SVC)
  0x6030 0000 0010 004a SPSR_ABT 64 spsr[KVM_SPSR_ABT]
  0x6030 0000 0010 004c SPSR_UND 64 spsr[KVM_SPSR_UND]
  0x6030 0000 0010 004e SPSR_IRQ 64 spsr[KVM_SPSR_IRQ]
  0x6030 0000 0010 0050 SPSR_FIQ 64 spsr[KVM_SPSR_FIQ]
  0x6040 0000 0010 0054 V0 128 fp_regs.vregs[0] [1]_
  0x6040 0000 0010 0058 V1 128 fp_regs.vregs[1] [1]_
  ...
0x6040 0000 0010 00d0 V31 128 fp_regs.vregs[31] [1]_
  0x6020 0000 0010 00d4 FPSR 32 fp_regs.fpsr
  0x6020 0000 0010 00d5 FPCR 32 fp_regs.fpcr
================================================================================

.. [1] These encodings are not accepted for SVE-enabled vcpus.  See
       :ref:`KVM_ARM_VCPU_INIT`.

       The equivalent register content can be accessed via bits [127:0] of
       the corresponding SVE Zn registers instead for vcpus that have SVE
       enabled (see below).

Các thanh ghi arm64 CCSIDR được phân kênh theo giá trị CSSELR::

0x6020 0000 0011 00 <csselr:8>

Các thanh ghi hệ thống arm64 có các mẫu bit id sau::

0x6030 0000 0013 <op0:2> <op1:3> <crn:4> <crm:4> <op2:3>

.. warning::

     Two system register IDs do not follow the specified pattern.  These
     are KVM_REG_ARM_TIMER_CVAL and KVM_REG_ARM_TIMER_CNT, which map to
     system registers CNTV_CVAL_EL0 and CNTVCT_EL0 respectively.  These
     two had their values accidentally swapped, which means TIMER_CVAL is
     derived from the register encoding for CNTVCT_EL0 and TIMER_CNT is
     derived from the register encoding for CNTV_CVAL_EL0.  As this is
     API, it must remain this way.

Các thanh ghi giả của phần sụn arm64 có mẫu bit sau ::

0x6030 0000 0014 <regno:16>

Các thanh ghi arm64 SVE có các mẫu bit sau::

0x6080 0000 0015 00 <n:5> <lát:5> Bit Zn[2048*slice + 2047 : 2048*slice]
  0x6050 0000 0015 04 <n:4> <slice:5> Pn bit[256*slice + 255 : 256*slice]
  0x6050 0000 0015 060 <lát:5> Bit FFR[256*slice + 255 : 256*slice]
  0x6060 0000 0015 ffff KVM_REG_ARM64_SVE_VLS đăng ký giả

Quyền truy cập vào đăng ký ID trong đó 2048 * slice >= 128 * max_vq sẽ không thành công với
ENOENT.  max_vq là độ dài vectơ được hỗ trợ tối đa của vcpu trong 128-bit
bốn từ: xem [2]_ bên dưới.

Các thanh ghi này chỉ có thể truy cập được trên vcpus đã bật SVE.
Xem KVM_ARM_VCPU_INIT để biết chi tiết.

Ngoài ra, ngoại trừ KVM_REG_ARM64_SVE_VLS, các thanh ghi này không
có thể truy cập cho đến khi cấu hình SVE của vcpu được hoàn tất
sử dụng KVM_ARM_VCPU_FINALIZE(KVM_ARM_VCPU_SVE).  Xem KVM_ARM_VCPU_INIT
và KVM_ARM_VCPU_FINALIZE để biết thêm thông tin về quy trình này.

KVM_REG_ARM64_SVE_VLS là một thanh ghi giả cho phép tập hợp vectơ
độ dài được vcpu hỗ trợ sẽ được phát hiện và định cấu hình bởi
không gian người dùng.  Khi được chuyển đến hoặc từ bộ nhớ người dùng qua KVM_GET_ONE_REG
hoặc KVM_SET_ONE_REG, giá trị của thanh ghi này thuộc loại
__u64[KVM_ARM64_SVE_VLS_WORDS] và mã hóa tập hợp độ dài vectơ thành
sau::

__u64 vector_lengths[KVM_ARM64_SVE_VLS_WORDS];

nếu (vq >= SVE_VQ_MIN && vq <= SVE_VQ_MAX &&
      ((vector_lengths[(vq - KVM_ARM64_SVE_VQ_MIN) / 64] >>
		((vq - KVM_ARM64_SVE_VQ_MIN) % 64)) & 1))
	/* Độ dài vectơ vq * Hỗ trợ 16 byte */
  khác
	/* Độ dài vectơ vq * 16 byte không được hỗ trợ */

.. [2] The maximum value vq for which the above condition is true is
       max_vq.  This is the maximum vector length available to the guest on
       this vcpu, and determines which register slices are visible through
       this ioctl interface.

(Xem Documentation/arch/arm64/sve.rst để biết giải thích về "vq"
danh pháp.)

KVM_REG_ARM64_SVE_VLS chỉ có thể truy cập được sau KVM_ARM_VCPU_INIT.
KVM_ARM_VCPU_INIT khởi tạo nó với tập hợp độ dài vectơ tốt nhất
chủ nhà hỗ trợ.

Không gian người dùng sau đó có thể sửa đổi nó nếu muốn cho đến khi SVE của vcpu
cấu hình được hoàn tất bằng KVM_ARM_VCPU_FINALIZE(KVM_ARM_VCPU_SVE).

Ngoài việc loại bỏ tất cả các độ dài vectơ khỏi bộ máy chủ
vượt quá một số giá trị, hỗ trợ cho các tập hợp độ dài vectơ được chọn tùy ý
phụ thuộc vào phần cứng và có thể không có sẵn.  Đang cố gắng định cấu hình
một tập hợp độ dài vectơ không hợp lệ thông qua KVM_SET_ONE_REG sẽ không thành công với
EINVAL.

Sau khi cấu hình SVE của vcpu được hoàn tất, các nỗ lực tiếp theo để
ghi thanh ghi này sẽ thất bại với EPERM.

Các thanh ghi giả của phần sụn tính năng bitmap arm64 có mẫu bit sau::

0x6030 0000 0016 <regno:16>

Các thanh ghi chương trình cơ sở tính năng bitmap hiển thị các dịch vụ hypercall
có sẵn cho không gian người dùng để cấu hình. Các bit được thiết lập tương ứng với
dịch vụ mà du khách có thể tiếp cận. Theo mặc định, KVM
đặt tất cả các bit được hỗ trợ trong quá trình khởi tạo VM. Không gian người dùng có thể
khám phá các dịch vụ có sẵn thông qua KVM_GET_ONE_REG và viết lại
bitmap tương ứng với các tính năng mà nó mong muốn khách xem qua
KVM_SET_ONE_REG.

Lưu ý: Các thanh ghi này không thể thay đổi khi bất kỳ vCPU nào của VM có
chạy ít nhất một lần. KVM_SET_ONE_REG trong tình huống như vậy sẽ quay trở lại
a -EBUSY vào không gian người dùng.

(Xem Tài liệu/virt/kvm/arm/hypercalls.rst để biết thêm chi tiết.)


Các thanh ghi MIPS được ánh xạ bằng 32 bit thấp hơn.  Số 16 trên đó là
loại nhóm đăng ký:

Các thanh ghi lõi MIPS (xem ở trên) có các mẫu bit id sau ::

0x7030 0000 0000 <reg:16>

Các thanh ghi MIPS CP0 (xem KVM_REG_MIPS_CP0_* ở trên) có bit id sau
các mẫu tùy thuộc vào việc chúng là thanh ghi 32 bit hay 64 bit ::

0x7020 0000 0001 00 <reg:5> <sel:3> (32-bit)
  0x7030 0000 0001 00 <reg:5> <sel:3> (64-bit)

Lưu ý: KVM_REG_MIPS_CP0_ENTRYLO0 và KVM_REG_MIPS_CP0_ENTRYLO1 là MIPS64
các phiên bản của thanh ghi EntryLo bất kể kích thước từ của máy chủ
phần cứng, nhân máy chủ, máy khách và liệu XPA có hiện diện trong máy khách hay không, tức là.
với các bit RI và XI (nếu chúng tồn tại) lần lượt ở các bit 63 và 62, và
trường PFNX bắt đầu từ bit 30.

MAAR MIPS (xem KVM_REG_MIPS_CP0_MAAR(*) ở trên) có bit id sau
mẫu::

0x7030 0000 0001 01 <reg:8>

Các thanh ghi điều khiển MIPS KVM (xem ở trên) có các mẫu bit id sau::

0x7030 0000 0002 <reg:16>

Các thanh ghi MIPS FPU (xem KVM_REG_MIPS_FPR_{32,64}() ở trên) có các mục sau
mẫu bit id tùy thuộc vào kích thước của thanh ghi đang được truy cập. Họ là
luôn được truy cập theo chế độ FPU của khách hiện tại (Status.FR và
Config5.FRE), tức là khi khách nhìn thấy chúng và chúng trở nên khó đoán
nếu chế độ FPU của khách bị thay đổi. Vectơ kiến trúc MIPS SIMD (MSA)
các thanh ghi (xem KVM_REG_MIPS_VEC_128() ở trên) có các mẫu tương tự như chúng
chồng lên các thanh ghi FPU::

0x7020 0000 0003 00 <0:3> <reg:5> (thanh ghi FPU 32-bit)
  0x7030 0000 0003 00 <0:3> <reg:5> (thanh ghi FPU 64-bit)
  0x7040 0000 0003 00 <0:3> <reg:5> (thanh ghi vectơ MSA 128-bit)

Các thanh ghi điều khiển MIPS FPU (xem KVM_REG_MIPS_FCR_{IR,CSR} ở trên) có
các mẫu bit id sau::

0x7020 0000 0003 01 <0:3> <reg:5>

Các thanh ghi điều khiển MIPS MSA (xem KVM_REG_MIPS_MSA_{IR,CSR} ở trên) có
các mẫu bit id sau::

0x7020 0000 0003 02 <0:3> <reg:5>

Các thanh ghi RISC-V được ánh xạ bằng 32 bit thấp hơn. 8 bit trên của
đó là loại nhóm đăng ký.

Các thanh ghi cấu hình RISC-V dùng để định cấu hình Guest VCPU và nó có
các mẫu bit id sau::

0x8020 0000 01 <lập chỉ mục vào cấu trúc kvm_riscv_config:24> (Máy chủ 32bit)
  0x8030 0000 01 <lập chỉ mục vào cấu trúc kvm_riscv_config:24> (Máy chủ 64bit)

Sau đây là các thanh ghi cấu hình RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x80x0 0000 0100 0000 isa ISA tính năng bitmap của Khách VCPU
======================== ===========================================================

Thanh ghi cấu hình isa có thể được đọc bất cứ lúc nào nhưng chỉ có thể được ghi trước
một Khách VCPU chạy. Nó sẽ có các bit tính năng ISA phù hợp với máy chủ cơ bản
được đặt theo mặc định.

Các thanh ghi lõi RISC-V thể hiện trạng thái thực thi chung của Khách VCPU
và nó có các mẫu bit id sau::

0x8020 0000 02 <lập chỉ mục vào cấu trúc kvm_riscv_core:24> (Máy chủ 32bit)
  0x8030 0000 02 <lập chỉ mục vào cấu trúc kvm_riscv_core:24> (Máy chủ 64bit)

Sau đây là các thanh ghi lõi RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x80x0 0000 0200 0000 regs.pc Bộ đếm chương trình
  0x80x0 0000 0200 0001 reg.ra Địa chỉ trả về
  0x80x0 0000 0200 0002 reg.sp Con trỏ ngăn xếp
  0x80x0 0000 0200 0003 regs.gp Con trỏ toàn cầu
  0x80x0 0000 0200 0004 reg.tp Con trỏ tác vụ
  0x80x0 0000 0200 0005 reg.t0 Đăng ký đã lưu của người gọi 0
  0x80x0 0000 0200 0006 reg.t1 Đăng ký người gọi đã lưu 1
  0x80x0 0000 0200 0007 reg.t2 Đăng ký người gọi đã lưu 2
  0x80x0 0000 0200 0008 regs.s0 Đăng ký đã lưu của Callee 0
  0x80x0 0000 0200 0009 reg.s1 Đăng ký đã lưu Callee 1
  0x80x0 0000 0200 000a regs.a0 Đối số hàm (hoặc giá trị trả về) 0
  0x80x0 0000 0200 000b regs.a1 Đối số hàm (hoặc giá trị trả về) 1
  0x80x0 0000 0200 000c regs.a2 Đối số hàm 2
  0x80x0 0000 0200 000d regs.a3 Đối số hàm 3
  0x80x0 0000 0200 000e regs.a4 Đối số hàm 4
  0x80x0 0000 0200 000f regs.a5 Đối số hàm 5
  0x80x0 0000 0200 0010 reg.a6 Đối số hàm 6
  0x80x0 0000 0200 0011 reg.a7 Đối số hàm 7
  0x80x0 0000 0200 0012 reg.s2 Đăng ký đã lưu Callee 2
  0x80x0 0000 0200 0013 reg.s3 Đăng ký đã lưu Callee 3
  0x80x0 0000 0200 0014 reg.s4 Đăng ký đã lưu Callee 4
  0x80x0 0000 0200 0015 reg.s5 Đăng ký đã lưu Callee 5
  0x80x0 0000 0200 0016 reg.s6 Đăng ký đã lưu Callee 6
  0x80x0 0000 0200 0017 reg.s7 Đăng ký đã lưu Callee 7
  0x80x0 0000 0200 0018 reg.s8 Đăng ký đã lưu Callee 8
  0x80x0 0000 0200 0019 reg.s9 Đăng ký đã lưu Callee 9
  0x80x0 0000 0200 001a regs.s10 Đăng ký đã lưu của Callee 10
  0x80x0 0000 0200 001b reg.s11 Đăng ký đã lưu Callee 11
  0x80x0 0000 0200 001c reg.t3 Đăng ký đã lưu của người gọi 3
  0x80x0 0000 0200 001d regs.t4 Đăng ký đã lưu của người gọi 4
  0x80x0 0000 0200 001e reg.t5 Đăng ký đã lưu của người gọi 5
  0x80x0 0000 0200 001f regs.t6 Đăng ký đã lưu của người gọi 6
  Chế độ 0x80x0 0000 0200 0020 Chế độ đặc quyền (1 = Chế độ S hoặc 0 = Chế độ U)
======================== ===========================================================

Các thanh ghi csr RISC-V đại diện cho các thanh ghi trạng thái/điều khiển chế độ giám sát
của Khách VCPU và nó có các mẫu bit id sau::

0x8020 0000 03 <lập chỉ mục vào cấu trúc kvm_riscv_csr:24> (Máy chủ 32bit)
  0x8030 0000 03 <lập chỉ mục vào cấu trúc kvm_riscv_csr:24> (Máy chủ 64bit)

Sau đây là các thanh ghi csr RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x80x0 0000 0300 0000 trạng thái Trạng thái giám sát
  0x80x0 0000 0300 0001 sie Kích hoạt ngắt giám sát
  0x80x0 0000 0300 0002 stvec Cơ sở vector bẫy giám sát
  0x80x0 0000 0300 0003 sscratch Đăng ký vết xước Giám sát
  0x80x0 0000 0300 0004 sepc Bộ đếm chương trình ngoại lệ của người giám sát
  0x80x0 0000 0300 0005 vì nguyên nhân bẫy giám sát
  0x80x0 0000 0300 0006 stval Địa chỉ hoặc hướng dẫn của người giám sát không đúng
  0x80x0 0000 0300 0007 nhâm nhi Giám sát ngắt đang chờ xử lý
  0x80x0 0000 0300 0008 satp Dịch thuật và bảo vệ địa chỉ giám sát
======================== ===========================================================

Các thanh ghi hẹn giờ RISC-V thể hiện trạng thái hẹn giờ của Khách VCPU và nó có
các mẫu bit id sau::

0x8030 0000 04 <lập chỉ mục vào cấu trúc kvm_riscv_timer:24>

Sau đây là các thanh ghi hẹn giờ RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  Tần số 0x8030 0000 0400 0000 Tần số cơ sở thời gian (chỉ đọc)
  0x8030 0000 0400 0001 lần Giá trị thời gian hiển thị cho Khách
  0x8030 0000 0400 0002 so sánh Thời gian so sánh được lập trình bởi Khách
  Trạng thái 0x8030 0000 0400 0003 Trạng thái so sánh thời gian (1 = ON hoặc 0 = OFF)
======================== ===========================================================

Các thanh ghi mở rộng F RISC-V đại diện cho dấu phẩy động chính xác đơn
trạng thái của Khách VCPU và nó có các mẫu bit id sau::

0x8020 0000 05 <lập chỉ mục vào cấu trúc __riscv_f_ext_state:24>

Sau đây là các thanh ghi mở rộng F RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x8020 0000 0500 0000 f[0] Thanh ghi dấu phẩy động 0
  ...
0x8020 0000 0500 001f f[31] Thanh ghi dấu phẩy động 31
  0x8020 0000 0500 0020 fcsr Thanh ghi trạng thái và điều khiển dấu phẩy động
======================== ===========================================================

Các thanh ghi mở rộng D RISC-V đại diện cho dấu phẩy động có độ chính xác kép
trạng thái của Khách VCPU và nó có các mẫu bit id sau::

0x8020 0000 06 <lập chỉ mục vào cấu trúc __riscv_d_ext_state:24> (fcsr)
  0x8030 0000 06 <lập chỉ mục vào cấu trúc __riscv_d_ext_state:24> (không phải fcsr)

Sau đây là các thanh ghi mở rộng D RISC-V:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x8030 0000 0600 0000 f[0] Thanh ghi dấu phẩy động 0
  ...
0x8030 0000 0600 001f f[31] Thanh ghi dấu phẩy động 31
  0x8020 0000 0600 0020 fcsr Thanh ghi trạng thái và điều khiển dấu phẩy động
======================== ===========================================================

Các thanh ghi LoongArch được ánh xạ bằng 32 bit thấp hơn. 16 bit trên của
đó là loại nhóm đăng ký.

Các thanh ghi LoongArch csr được sử dụng để kiểm soát CPU khách hoặc nhận trạng thái của khách
cpu và chúng có các mẫu bit id sau::

0x9030 0000 0001 00 <reg:5> <sel:3> (64-bit)

Các thanh ghi điều khiển LoongArch KVM được sử dụng để thực hiện một số chức năng được xác định mới
chẳng hạn như đặt bộ đếm vcpu hoặc đặt lại vcpu và chúng có các mẫu bit id sau ::

0x9030 0000 0002 <reg:16>

Các thanh ghi x86 MSR có các mẫu bit id sau::
  0x2030 0002 <msr số:32>

Sau đây là các thanh ghi KVM được xác định cho x86:

======================== ===========================================================
    Mã hóa Đăng ký Mô tả
======================== ===========================================================
  0x2030 0003 0000 0000 SSP Con trỏ ngăn xếp bóng
======================== ===========================================================

4,69 KVM_GET_ONE_REG
--------------------

:Khả năng: KVM_CAP_ONE_REG
:Kiến trúc: tất cả
:Type: vcpu ioctl
:Thông số: struct kvm_one_reg (vào và ra)
:Trả về: 0 nếu thành công, giá trị âm nếu thất bại

Các lỗi bao gồm:

==========================================================================
  ENOENT không có đăng ký như vậy
  EINVAL ID đăng ký không hợp lệ hoặc không có đăng ký như vậy hoặc được sử dụng với máy ảo trong
           chế độ ảo hóa được bảo vệ trên s390
  Không được phép truy cập đăng ký EPERM (arm64) trước khi hoàn tất vcpu
  ==========================================================================

(Các mã lỗi này chỉ mang tính biểu thị: không dựa vào một lỗi cụ thể nào
mã được trả về trong một tình huống cụ thể.)

Ioctl này cho phép nhận giá trị của một thanh ghi được triển khai
trong một vcpu. Thanh ghi để đọc được biểu thị bằng trường "id" của
Cấu trúc kvm_one_reg được chuyển vào. Nếu thành công, giá trị đăng ký có thể được tìm thấy
tại vị trí bộ nhớ được trỏ bởi "addr".

Danh sách các thanh ghi có thể truy cập bằng giao diện này giống hệt với danh sách
danh sách trong 4.68.


4,70 KVM_KVMCLOCK_CTRL
----------------------

:Khả năng: KVM_CAP_KVMCLOCK_CTRL
:Architectures: Bất kỳ ứng dụng nào triển khai PVClocks (hiện chỉ có x86)
:Type: vcpu ioctl
:Thông số: Không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ioctl này đặt cờ mà khách có thể truy cập cho biết rằng
vCPU đã bị tạm dừng bởi không gian người dùng máy chủ.

Máy chủ sẽ đặt cờ trong cấu trúc PVClock được kiểm tra từ
cơ quan giám sát khóa mềm.  Cờ là một phần của cấu trúc PVClock
được chia sẻ giữa khách và máy chủ, đặc biệt là bit thứ hai của cờ
trường của cấu trúc pvclock_vcpu_time_info.  Nó sẽ được thiết lập độc quyền bởi
máy chủ và được đọc/xóa độc quyền bởi khách.  Hoạt động khách của
kiểm tra và xóa cờ phải là một hoạt động nguyên tử nên
phải sử dụng liên kết tải/lưu trữ có điều kiện hoặc tương đương.  Có hai trường hợp
nơi khách sẽ xóa cờ: khi bộ hẹn giờ cơ quan giám sát khóa mềm đặt lại
chính nó hoặc khi phát hiện khóa mềm.  ioctl này có thể được gọi bất cứ lúc nào
sau khi tạm dừng vcpu nhưng trước khi nó được tiếp tục.


4,71 KVM_SIGNAL_MSI
-------------------

:Khả năng: KVM_CAP_SIGNAL_MSI
:Kiến trúc: x86 arm64
:Type: vm ioctl
:Thông số: struct kvm_msi (trong)
:Trả về: >0 khi giao hàng, 0 nếu khách chặn MSI và -1 nếu có lỗi

Trực tiếp gửi tin nhắn MSI. Chỉ hợp lệ với irqchip trong kernel xử lý
Tin nhắn MSI.

::

cấu trúc kvm_msi {
	__u32 địa chỉ_lo;
	__u32 địa chỉ_xin chào;
	__u32 dữ liệu;
	__u32 cờ;
	__u32 khác biệt;
	__u8 đệm[12];
  };

cờ:
  KVM_MSI_VALID_DEVID: devid chứa giá trị hợp lệ.  Mỗi VM
  Khả năng KVM_CAP_MSI_DEVID quảng cáo yêu cầu cung cấp
  ID thiết bị.  Nếu khả năng này không có sẵn, không gian người dùng
  không bao giờ nên đặt cờ KVM_MSI_VALID_DEVID vì ioctl có thể bị lỗi.

Nếu KVM_MSI_VALID_DEVID được đặt, devid chứa mã nhận dạng thiết bị duy nhất
cho thiết bị đã viết tin nhắn MSI.  Đối với PCI, đây thường là một
Mã định danh BDF ở 16 bit thấp hơn.

Trên x86, address_hi bị bỏ qua trừ khi KVM_X2APIC_API_USE_32BIT_IDS
tính năng của khả năng KVM_CAP_X2APIC_API được kích hoạt.  Nếu nó được kích hoạt,
địa chỉ_hi bit 31-8 cung cấp bit 31-8 của id đích.  Bit 7-0 của
address_hi phải bằng 0.


4,71 KVM_CREATE_PIT2
--------------------

:Khả năng: KVM_CAP_PIT2
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_pit_config (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Tạo mô hình thiết bị trong nhân cho i8254 PIT. Cuộc gọi này chỉ hợp lệ
sau khi kích hoạt hỗ trợ irqchip trong kernel thông qua KVM_CREATE_IRQCHIP. Sau đây
các tham số phải được thông qua::

cấu trúc kvm_pit_config {
	__u32 cờ;
	__u32 đệm[15];
  };

Cờ hợp lệ là::

#define KVM_PIT_SPEAKER_DUMMY 1 /* mô phỏng cuống cổng loa */

Các ngắt hẹn giờ PIT có thể sử dụng luồng nhân trên mỗi VM để tiêm. Nếu nó
tồn tại, chủ đề này sẽ có tên theo mẫu sau::

kvm-pit/<owner-process-pid>

Khi chạy một khách có mức độ ưu tiên cao hơn, các tham số lập lịch của
chủ đề này có thể phải được điều chỉnh cho phù hợp.

IOCTL này thay thế KVM_CREATE_PIT lỗi thời.


4,72 KVM_GET_PIT2
-----------------

:Khả năng: KVM_CAP_PIT_STATE2
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_pit_state2 (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Truy xuất trạng thái của mô hình PIT trong kernel. Chỉ có hiệu lực sau
KVM_CREATE_PIT2. Trạng thái được trả về theo cấu trúc sau::

cấu trúc kvm_pit_state2 {
	cấu trúc kênh kvm_pit_channel_state[3];
	__u32 cờ;
	__u32 dành riêng[9];
  };

Cờ hợp lệ là::

/* tắt PIT ở chế độ kế thừa HPET */
  #define KVM_PIT_FLAGS_HPET_LEGACY 0x00000001
  /* Đã bật bit dữ liệu cổng loa */
  #define KVM_PIT_FLAGS_SPEAKER_DATA_ON 0x00000002

IOCTL này thay thế KVM_GET_PIT lỗi thời.


4,73 KVM_SET_PIT2
-----------------

:Khả năng: KVM_CAP_PIT_STATE2
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_pit_state2 (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đặt trạng thái của mô hình PIT trong kernel. Chỉ có hiệu lực sau KVM_CREATE_PIT2.
Xem KVM_GET_PIT2 để biết chi tiết về cấu trúc kvm_pit_state2.

.. Tip::
  ``KVM_SET_PIT2`` strictly adheres to the spec of Intel 8254 PIT.  For example,
  a ``count`` value of 0 in ``struct kvm_pit_channel_state`` is interpreted as
  65536, which is the maximum count value. Refer to `Intel 8254 programmable
  interval timer <https://www.scs.stanford.edu/10wi-cs140/pintos/specs/8254.pdf>`_.

IOCTL này thay thế KVM_SET_PIT lỗi thời.


4,74 KVM_PPC_GET_SMMU_INFO
--------------------------

:Khả năng: KVM_CAP_PPC_GET_SMMU_INFO
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: Không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Điều này điền và trả về một cấu trúc mô tả các tính năng của
mô phỏng MMU lớp "Máy chủ" được KVM hỗ trợ.
Điều này lần lượt có thể được sử dụng bởi không gian người dùng để tạo ra
thuộc tính cây thiết bị cho hệ điều hành khách.

Cấu trúc chứa một số thông tin tổng thể, theo sau là một
mảng kích thước trang phân đoạn được hỗ trợ::

cấu trúc kvm_ppc_smmu_info {
	     __u64 cờ;
	     __u32 slb_size;
	     __u32 đệm;
	     cấu trúc kvm_ppc_one_seg_page_size sps[KVM_PPC_PAGE_SIZES_MAX_SZ];
      };

Các cờ được hỗ trợ là:

-KVM_PPC_PAGE_SIZES_REAL:
        Khi cờ đó được đặt, kích thước trang khách phải "vừa" với mặt sau
        kích thước trang lưu trữ. Khi không được đặt, mọi kích thước trang trong danh sách đều có thể
        được sử dụng bất kể chúng được hỗ trợ bởi không gian người dùng như thế nào.

-KVM_PPC_1T_SEGMENTS
        MMU được mô phỏng hỗ trợ các phân đoạn 1T ngoài
        tiêu chuẩn 256M.

-KVM_PPC_NO_HASH
	Cờ này cho biết rằng khách HPT không được KVM hỗ trợ,
	do đó tất cả khách phải sử dụng chế độ cơ số MMU.

Trường "slb_size" cho biết có bao nhiêu mục SLB được hỗ trợ

Mảng "sps" chứa 8 mục cho biết cơ sở được hỗ trợ
kích thước trang cho một phân đoạn theo thứ tự tăng dần. Mỗi mục được xác định
như sau::

cấu trúc kvm_ppc_one_seg_page_size {
	__u32 trang_shift;	/* Dịch chuyển trang cơ sở của đoạn (hoặc 0) */
	__u32 slb_enc;		/* Mã hóa SLB cho BookS */
	cấu trúc kvm_ppc_one_page_size enc[KVM_PPC_PAGE_SIZES_MAX_SZ];
   };

Mục nhập có "page_shift" bằng 0 sẽ không được sử dụng. Bởi vì mảng là
được sắp xếp theo thứ tự tăng dần, việc tra cứu có thể dừng lại khi gặp
một mục như vậy.

Trường "slb_enc" cung cấp mã hóa để sử dụng trong SLB cho
kích thước trang. Các bit ở các vị trí như giá trị có thể trực tiếp
được OR'ed vào đối số "vsid" của lệnh slbmte.

Mảng "enc" là một danh sách dành cho từng trang cơ sở phân đoạn đó
size cung cấp danh sách các kích thước trang thực tế được hỗ trợ (có thể
chỉ lớn hơn hoặc bằng kích thước trang cơ sở), cùng với
mã hóa tương ứng trong hàm băm PTE. Tương tự, mảng là
8 mục được sắp xếp theo kích thước tăng dần và một mục có độ dịch chuyển "0"
là một mục trống và một dấu kết thúc::

cấu trúc kvm_ppc_one_page_size {
	__u32 trang_shift;	/* Chuyển trang (hoặc 0) */
	__u32 pte_enc;		/* Mã hóa trong HPTE (>>12) */
   };

Trường "pte_enc" cung cấp một giá trị có thể OR vào hàm băm
Trường RPN của PTE (tức là nó cần được dịch chuyển sang trái 12 đến OR nó
vào từ kép thứ hai PTE băm).

4,75 KVM_IRQFD
--------------

:Khả năng: KVM_CAP_IRQFD
:Kiến trúc: x86 s390 arm64
:Type: vm ioctl
:Thông số: struct kvm_irqfd (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Cho phép thiết lập một sự kiện để trực tiếp kích hoạt ngắt của khách.
kvm_irqfd.fd chỉ định bộ mô tả tệp sẽ sử dụng làm sự kiện và
kvm_irqfd.gsi chỉ định chân irqchip được bật tắt bởi sự kiện này.  Khi nào
một sự kiện được kích hoạt trên eventfd, một ngắt sẽ được đưa vào
khách sử dụng mã pin gsi được chỉ định.  Irqfd được loại bỏ bằng cách sử dụng
cờ KVM_IRQFD_FLAG_DEASSIGN, chỉ định cả kvm_irqfd.fd
và kvm_irqfd.gsi.

Với KVM_CAP_IRQFD_RESAMPLE, KVM_IRQFD hỗ trợ hủy xác nhận và thông báo
cơ chế cho phép mô phỏng các cơ chế được kích hoạt theo cấp độ, dựa trên irqfd
ngắt quãng.  Khi KVM_IRQFD_FLAG_RESAMPLE được đặt, người dùng phải vượt qua
sự kiện bổ sung trong trường kvm_irqfd.resamplefd.  Khi vận hành
trong chế độ lấy mẫu lại, đăng thông tin ngắt thông qua xác nhận kvm_irq.fd
gsi được chỉ định trong irqchip.  Khi irqchip được lấy mẫu lại, chẳng hạn như
kể từ EOI, gsi sẽ bị hủy xác nhận và người dùng sẽ được thông báo qua
kvm_irqfd.resamplefd.  Trách nhiệm của người dùng là xếp hàng lại
ngắt nếu thiết bị sử dụng nó vẫn yêu cầu dịch vụ.
Lưu ý rằng việc đóng resamplefd là không đủ để vô hiệu hóa
irqfd.  KVM_IRQFD_FLAG_RESAMPLE chỉ cần thiết khi thực hiện nhiệm vụ
và không cần phải chỉ định bằng KVM_IRQFD_FLAG_DEASSIGN.

Trên arm64, định tuyến gsi được hỗ trợ, điều sau đây có thể xảy ra:

- trong trường hợp không có mục định tuyến nào được liên kết với gsi này, việc tiêm không thành công
- trong trường hợp gsi được liên kết với mục định tuyến irqchip,
  irqchip.pin + 32 tương ứng với ID SPI được chèn.
- trong trường hợp gsi được liên kết với mục định tuyến MSI, MSI
  tin nhắn và ID thiết bị được dịch sang LPI (hỗ trợ bị hạn chế
  sang mô phỏng trong kernel GICv3 ITS).

4,76 KVM_PPC_ALLOCATE_HTAB
--------------------------

:Khả năng: KVM_CAP_PPC_ALLOC_HTAB
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: Con trỏ tới u32 chứa thứ tự bảng băm (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Điều này yêu cầu hạt nhân máy chủ phân bổ bảng băm MMU cho
khách sử dụng giao diện ảo hóa song song PAPR.  Điều này chỉ làm
bất cứ điều gì nếu kernel được cấu hình để sử dụng kiểu Book 3S HV của
ảo hóa.  Nếu không thì khả năng đó không tồn tại và ioctl
trả về lỗi ENOTTY.  Phần còn lại của mô tả này giả định Quyển 3S
HV.

Không được có vcpus nào chạy khi ioctl này được gọi; nếu có
là nó sẽ không làm gì và trả về lỗi EBUSY.

Tham số này là một con trỏ tới biến số nguyên không dấu 32 bit
chứa thứ tự (log base 2) của kích thước băm mong muốn
bảng, phải nằm trong khoảng từ 18 đến 46. Khi trở về thành công từ
ioctl, giá trị sẽ không bị thay đổi bởi kernel.

Nếu không có bảng băm nào được phân bổ khi bất kỳ vcpu nào được yêu cầu chạy
(với KVM_RUN ioctl), nhân máy chủ sẽ phân bổ một
bảng băm có kích thước mặc định (16 MB).

Nếu ioctl này được gọi khi bảng băm đã được phân bổ,
với thứ tự khác với bảng băm hiện có, hàm băm hiện có
bảng sẽ được giải phóng và một bảng mới được phân bổ.  Nếu đây là ioctl thì
được gọi khi bảng băm đã được phân bổ theo cùng thứ tự
như được chỉ định, kernel sẽ xóa bảng băm hiện có (không
tất cả các HPTE).  Trong cả hai trường hợp, nếu khách đang sử dụng máy ảo hóa
cơ sở khu vực chế độ thực (VRMA), kernel sẽ tạo lại VMRA
HPTE trên KVM_RUN tiếp theo của bất kỳ vcpu nào.

4,77 KVM_S390_INTERRUPT
-----------------------

:Khả năng: cơ bản
:Kiến trúc: s390
:Loại: vm ioctl, vcpu ioctl
:Thông số: struct kvm_s390_interrupt (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Cho phép đưa ra một ngắt cho khách. Ngắt có thể nổi
(vm ioctl) hoặc mỗi cpu (vcpu ioctl), tùy thuộc vào loại ngắt.

Các tham số ngắt được truyền qua kvm_s390_interrupt::

cấu trúc kvm_s390_interrupt {
	__u32 loại;
	__u32 parm;
	__u64 parm64;
  };

loại có thể là một trong những loại sau:

KVM_S390_SIGP_STOP (vcpu)
    - dừng sigp; cờ tùy chọn trong parm
KVM_S390_PROGRAM_INT (vcpu)
    - kiểm tra chương trình; mã trong parm
KVM_S390_SIGP_SET_PREFIX (vcpu)
    - tiền tố đặt sigp; địa chỉ tiền tố trong parm
KVM_S390_RESTART (vcpu)
    - khởi động lại
KVM_S390_INT_CLOCK_COMP (vcpu)
    - ngắt so sánh đồng hồ
KVM_S390_INT_CPU_TIMER (vcpu)
    - Ngắt hẹn giờ CPU
KVM_S390_INT_VIRTIO (vm)
    - ngắt bên ngoài virtio; ngắt bên ngoài
      tham số trong parm và parm64
KVM_S390_INT_SERVICE (vm)
    - ngắt bên ngoài sclp; tham số sclp trong parm
KVM_S390_INT_EMERGENCY (vcpu)
    - sigp khẩn cấp; nguồn cpu trong parm
KVM_S390_INT_EXTERNAL_CALL (vcpu)
    - sigp cuộc gọi bên ngoài; nguồn cpu trong parm
KVM_S390_INT_IO(ai,cssid,ssid,schid) (vm)
    - giá trị ghép để biểu thị một
      Ngắt I/O (ai - ngắt bộ chuyển đổi; cssid,ssid,schid - kênh con);
      Các tham số gián đoạn I/O trong parm (kênh con) và parm64 (intparm,
      lớp con gián đoạn)
KVM_S390_MCHK (vm, vcpu)
    - ngắt kiểm tra máy; cr 14 bit trong parm, ngắt kiểm tra máy
      mã trong parm64 (lưu ý rằng việc kiểm tra máy cần tải trọng thêm thì không
      được hỗ trợ bởi ioctl này)

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.

4,78 KVM_PPC_GET_HTAB_FD
------------------------

:Khả năng: KVM_CAP_PPC_HTAB_FD
:Kiến trúc: powerpc
:Type: vm ioctl
:Parameters: Con trỏ tới struct kvm_get_htab_fd (in)
:Trả về: số mô tả tệp (>= 0) nếu thành công, -1 nếu lỗi

Điều này trả về một bộ mô tả tập tin có thể được sử dụng để đọc
các mục trong bảng trang băm của khách (HPT) hoặc để ghi các mục vào
khởi tạo HPT.  Fd được trả về chỉ có thể được ghi vào nếu
Bit KVM_GET_HTAB_WRITE được đặt trong trường cờ của đối số và
chỉ có thể được đọc nếu bit đó rõ ràng.  Cấu trúc đối số trông giống như
cái này::

/* Dành cho KVM_PPC_GET_HTAB_FD */
  cấu trúc kvm_get_htab_fd {
	__u64 cờ;
	__u64 start_index;
	__u64 dành riêng[2];
  };

/* Giá trị của kvm_get_htab_fd.flags */
  #define KVM_GET_HTAB_BOLTED_ONLY ((__u64)0x1)
  #define KVM_GET_HTAB_WRITE ((__u64)0x2)

Trường 'start_index' cung cấp chỉ mục trong HPT của mục nhập tại
để bắt đầu đọc.  Nó bị bỏ qua khi viết.

Việc đọc trên fd ban đầu sẽ cung cấp thông tin về tất cả
Các mục HPT "thú vị".  Các mục thú vị là những mục có
được đặt bit được bắt vít, nếu bit KVM_GET_HTAB_BOLTED_ONLY được đặt, nếu không thì
tất cả các mục.  Khi đạt đến cuối HPT, read() sẽ
trở lại.  Nếu read() được gọi lại trên fd, nó sẽ bắt đầu lại từ
phần đầu của HPT, nhưng sẽ chỉ trả về các mục HPT có
đã thay đổi kể từ lần đọc cuối cùng của chúng.

Dữ liệu được đọc hoặc ghi được cấu trúc dưới dạng tiêu đề (8 byte) theo sau là
một loạt các mục nhập HPT hợp lệ (mỗi mục 16 byte).  Tiêu đề cho biết cách
Có nhiều mục HPT hợp lệ và có bao nhiêu mục nhập không hợp lệ theo sau
các mục hợp lệ.  Các mục không hợp lệ không được trình bày rõ ràng
trong luồng.  Định dạng tiêu đề là::

cấu trúc kvm_get_htab_header {
	chỉ số __u32;
	__u16 n_hợp lệ;
	__u16 n_không hợp lệ;
  };

Ghi vào fd tạo các mục HPT bắt đầu từ chỉ mục được đưa ra trong
tiêu đề; mục nhập hợp lệ 'n_valid' đầu tiên có nội dung từ dữ liệu
được viết, sau đó 'n_invalid' mục nhập không hợp lệ, làm mất hiệu lực bất kỳ mục nhập nào trước đó
các mục hợp lệ được tìm thấy.

4,79 KVM_CREATE_DEVICE
----------------------

:Khả năng: KVM_CAP_DEVICE_CTRL
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_create_device (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

====== =============================================================
  ENODEV Loại thiết bị không xác định hoặc không được hỗ trợ
  EEXIST Thiết bị đã được tạo và loại thiết bị này có thể không
          được khởi tạo nhiều lần
  ====== =============================================================

Các điều kiện lỗi khác có thể được xác định bởi từng loại thiết bị hoặc
  có ý nghĩa tiêu chuẩn của chúng.

Tạo một thiết bị mô phỏng trong kernel.  Bộ mô tả tập tin được trả về
trong fd có thể được sử dụng với KVM_SET/GET/HAS_DEVICE_ATTR.

Nếu cờ KVM_CREATE_DEVICE_TEST được đặt, chỉ kiểm tra xem
loại thiết bị được hỗ trợ (không nhất thiết là liệu nó có thể được tạo hay không
trong vm hiện tại).

Các thiết bị riêng lẻ không nên xác định cờ.  Các thuộc tính nên được sử dụng
để chỉ định bất kỳ hành vi nào không được loại thiết bị ngụ ý
số.

::

cấu trúc kvm_create_device {
	__u32 loại;	/* trong: KVM_DEV_TYPE_xxx */
	__u32 fd;	/* out: xử lý thiết bị */
	__u32 cờ;	/* trong: KVM_CREATE_DEVICE_xxx */
  };

4,80 KVM_SET_DEVICE_ATTR/KVM_GET_DEVICE_ATTR
--------------------------------------------

:Khả năng: KVM_CAP_DEVICE_CTRL, KVM_CAP_VM_ATTRIBUTES cho thiết bị vm,
             KVM_CAP_VCPU_ATTRIBUTES cho thiết bị vcpu
             KVM_CAP_SYS_ATTRIBUTES dành cho thiết bị hệ thống (/dev/kvm) (không có bộ)
:Kiến trúc: x86, arm64, s390
:Loại: thiết bị ioctl, vm ioctl, vcpu ioctl
:Thông số: struct kvm_device_attr
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

=======================================================================
  ENXIO Nhóm hoặc thuộc tính không xác định/không được hỗ trợ cho thiết bị này
          hoặc hỗ trợ phần cứng bị thiếu.
  EPERM Thuộc tính không thể (hiện tại) được truy cập theo cách này
          (ví dụ: thuộc tính chỉ đọc hoặc thuộc tính chỉ tạo
          cảm nhận được khi thiết bị ở trạng thái khác)
  =======================================================================

Các điều kiện lỗi khác có thể được xác định theo từng loại thiết bị.

Nhận/đặt một phần cấu hình và/hoặc trạng thái thiết bị được chỉ định.  các
ngữ nghĩa là dành riêng cho thiết bị.  Xem tài liệu về từng thiết bị trong
thư mục "thiết bị".  Như với ONE_REG, kích thước của dữ liệu
được chuyển giao được xác định bởi thuộc tính cụ thể.

::

cấu trúc kvm_device_attr {
	__u32 cờ;		/* hiện tại không có cờ nào được xác định */
	__u32 nhóm;		/* do thiết bị xác định */
	__u64 attr;		/* do nhóm xác định */
	__u64 địa chỉ;		/*địa chỉ vùng người dùng của dữ liệu attr */
  };

4,81 KVM_HAS_DEVICE_ATTR
------------------------

:Khả năng: KVM_CAP_DEVICE_CTRL, KVM_CAP_VM_ATTRIBUTES cho thiết bị vm,
             KVM_CAP_VCPU_ATTRIBUTES cho thiết bị vcpu
             KVM_CAP_SYS_ATTRIBUTES dành cho thiết bị hệ thống (/dev/kvm)
:Loại: thiết bị ioctl, vm ioctl, vcpu ioctl
:Thông số: struct kvm_device_attr
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

=======================================================================
  ENXIO Nhóm hoặc thuộc tính không xác định/không được hỗ trợ cho thiết bị này
          hoặc hỗ trợ phần cứng bị thiếu.
  =======================================================================

Kiểm tra xem một thiết bị có hỗ trợ một thuộc tính cụ thể hay không.  Một thành công
return cho biết thuộc tính được triển khai.  Nó không nhất thiết
chỉ ra rằng thuộc tính có thể được đọc hoặc ghi trong thiết bị
trạng thái hiện tại.  "addr" bị bỏ qua.

.. _KVM_ARM_VCPU_INIT:

4,82 KVM_ARM_VCPU_INIT
----------------------

:Khả năng: cơ bản
:Kiến trúc: arm64
:Type: vcpu ioctl
:Thông số: struct kvm_vcpu_init (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

Lỗi:

====== ======================================================================
  EINVAL mục tiêu không xác định hoặc sự kết hợp các tính năng không hợp lệ.
  ENOENT một bit tính năng được chỉ định không xác định.
  ====== ======================================================================

Điều này cho KVM biết loại CPU nào cần giới thiệu cho khách và loại nào
các tính năng tùy chọn cần có.  Điều này sẽ gây ra sự thiết lập lại của cpu
đăng ký các giá trị ban đầu của chúng.  Nếu điều này không được gọi, KVM_RUN sẽ
trả lại ENOEXEC cho vcpu đó.

Các giá trị ban đầu được xác định là:
	- Trạng thái bộ xử lý:
		* AArch64: Tập hợp các bit EL1h, D, A, I và F. Tất cả các bit khác
		  được xóa.
		* AArch32: Bộ bit SVC, A, I và F. Tất cả các bit khác đều
		  đã xóa.
	- Các thanh ghi mục đích chung, bao gồm PC và SP: đặt thành 0
	- Thanh ghi FPSIMD/NEON: đặt thành 0
	- Thanh ghi SVE: đặt thành 0
	- Các thanh ghi hệ thống: Đặt lại về kiến trúc được xác định của chúng
	  các giá trị như đối với thiết lập lại ấm về EL1 (tương ứng với SVC) hoặc EL2 (trong
	  trường hợp EL2 được kích hoạt).

Lưu ý rằng vì một số thanh ghi phản ánh cấu trúc liên kết của máy nên tất cả vcpus
nên được tạo trước khi ioctl này được gọi.

Không gian người dùng có thể gọi hàm này nhiều lần cho một vcpu nhất định, bao gồm
sau khi vcpu đã được chạy. Điều này sẽ đặt lại vcpu về ban đầu
trạng thái. Tất cả các cuộc gọi đến chức năng này sau cuộc gọi đầu tiên phải sử dụng cùng một
mục tiêu và cùng một bộ cờ tính năng, nếu không EINVAL sẽ được trả về.

Các tính năng có thể có:

- KVM_ARM_VCPU_POWER_OFF: Khởi động CPU ở trạng thái tắt nguồn.
	  Phụ thuộc vào KVM_CAP_ARM_PSCI.  Nếu không được đặt, CPU sẽ được bật nguồn
	  và thực thi mã khách khi KVM_RUN được gọi.
	- KVM_ARM_VCPU_EL1_32BIT: Khởi động CPU ở chế độ 32bit.
	  Phụ thuộc vào KVM_CAP_ARM_EL1_32BIT (chỉ arm64).
	- KVM_ARM_VCPU_PSCI_0_2: Giả lập PSCI v0.2 (hoặc bản sửa đổi trong tương lai
          tương thích ngược với v0.2) cho CPU.
	  Phụ thuộc vào KVM_CAP_ARM_PSCI_0_2.
	- KVM_ARM_VCPU_PMU_V3: Giả lập PMUv3 cho CPU.
	  Phụ thuộc vào KVM_CAP_ARM_PMU_V3.

- KVM_ARM_VCPU_PTRAUTH_ADDRESS: Cho phép xác thực con trỏ địa chỉ
	  chỉ dành cho arm64.
	  Phụ thuộc vào KVM_CAP_ARM_PTRAUTH_ADDRESS.
	  Nếu KVM_CAP_ARM_PTRAUTH_ADDRESS và KVM_CAP_ARM_PTRAUTH_GENERIC là
	  cả hai đều có mặt, thì cả KVM_ARM_VCPU_PTRAUTH_ADDRESS và
	  KVM_ARM_VCPU_PTRAUTH_GENERIC phải được yêu cầu hoặc không được yêu cầu
	  được yêu cầu.

- KVM_ARM_VCPU_PTRAUTH_GENERIC: Cho phép xác thực con trỏ chung
	  chỉ dành cho arm64.
	  Phụ thuộc vào KVM_CAP_ARM_PTRAUTH_GENERIC.
	  Nếu KVM_CAP_ARM_PTRAUTH_ADDRESS và KVM_CAP_ARM_PTRAUTH_GENERIC là
	  cả hai đều có mặt, thì cả KVM_ARM_VCPU_PTRAUTH_ADDRESS và
	  KVM_ARM_VCPU_PTRAUTH_GENERIC phải được yêu cầu hoặc không được yêu cầu
	  được yêu cầu.

- KVM_ARM_VCPU_SVE: Kích hoạt SVE cho CPU (chỉ arm64).
	  Phụ thuộc vào KVM_CAP_ARM_SVE.
	  Yêu cầu KVM_ARM_VCPU_FINALIZE(KVM_ARM_VCPU_SVE):

* Sau KVM_ARM_VCPU_INIT:

- KVM_REG_ARM64_SVE_VLS có thể được đọc bằng KVM_GET_ONE_REG:
	        giá trị ban đầu của thanh ghi giả này cho biết tập hợp tốt nhất của
	        độ dài vectơ có thể có cho một vcpu trên máy chủ này.

* Trước KVM_ARM_VCPU_FINALIZE(KVM_ARM_VCPU_SVE):

- KVM_RUN và KVM_GET_REG_LIST không có sẵn;

- Không thể sử dụng KVM_GET_ONE_REG và KVM_SET_ONE_REG để truy cập
	        các thanh ghi kiến trúc SVE có thể mở rộng
	        KVM_REG_ARM64_SVE_ZREG(), KVM_REG_ARM64_SVE_PREG() hoặc
	        KVM_REG_ARM64_SVE_FFR;

- KVM_REG_ARM64_SVE_VLS có thể được viết tùy ý bằng cách sử dụng
	        KVM_SET_ONE_REG, để sửa đổi tập hợp độ dài vectơ có sẵn
	        dành cho vcpu.

* Sau KVM_ARM_VCPU_FINALIZE(KVM_ARM_VCPU_SVE):

- thanh ghi giả KVM_REG_ARM64_SVE_VLS là bất biến và có thể
	        không còn được viết bằng KVM_SET_ONE_REG nữa.

- KVM_ARM_VCPU_HAS_EL2: Kích hoạt hỗ trợ ảo hóa lồng nhau,
	  khởi động khách từ EL2 thay vì EL1.
	  Phụ thuộc vào KVM_CAP_ARM_EL2.
	  VM đang chạy với HCR_EL2.E2H là RES1 (VHE) trừ khi
	  KVM_ARM_VCPU_HAS_EL2_E2H0 cũng được thiết lập.

- KVM_ARM_VCPU_HAS_EL2_E2H0: Hạn chế ảo hóa lồng nhau
	  hỗ trợ HCR_EL2.E2H là RES0 (không phải VHE).
	  Phụ thuộc vào KVM_CAP_ARM_EL2_E2H0.
	  KVM_ARM_VCPU_HAS_EL2 cũng phải được đặt.

4,83 KVM_ARM_PREFERRED_TARGET
-----------------------------

:Khả năng: cơ bản
:Kiến trúc: arm64
:Type: vm ioctl
:Thông số: struct kvm_vcpu_init (out)
:Trả về: 0 nếu thành công; -1 do lỗi

Lỗi:

====== ==============================================
  ENODEV không có mục tiêu ưa thích nào cho máy chủ
  ====== ==============================================

Truy vấn KVM này để tìm loại mục tiêu CPU ưa thích có thể được mô phỏng
bởi KVM trên máy chủ cơ bản.

ioctl trả về instance struct kvm_vcpu_init chứa thông tin
về loại mục tiêu CPU ưa thích và các tính năng được đề xuất cho nó.  các
kvm_vcpu_init->bitmap tính năng được trả về sẽ có các bit tính năng được đặt nếu
mục tiêu ưa thích khuyên bạn nên thiết lập các tính năng này, nhưng đây là
không bắt buộc.

Thông tin được trả về bởi ioctl này có thể được sử dụng để chuẩn bị một phiên bản
của struct kvm_vcpu_init cho KVM_ARM_VCPU_INIT ioctl sẽ dẫn đến
VCPU phù hợp với máy chủ cơ bản.


4,84 KVM_GET_REG_LIST
---------------------

:Khả năng: cơ bản
:Kiến trúc: arm64, mips, riscv, x86 (nếu KVM_CAP_ONE_REG)
:Type: vcpu ioctl
:Thông số: struct kvm_reg_list (vào/ra)
:Trả về: 0 nếu thành công; -1 do lỗi

Lỗi:

========================================================================
  E2BIG danh sách chỉ mục reg quá lớn để vừa với mảng được chỉ định bởi
             người dùng (số cần tìm sẽ ghi thành n).
  ========================================================================

::

cấu trúc kvm_reg_list {
	__u64 n; /* số lượng thanh ghi trong reg[] */
	__u64 reg[0];
  };

Ioctl này trả về các sổ đăng ký khách được hỗ trợ cho
Cuộc gọi KVM_GET_ONE_REG/KVM_SET_ONE_REG.

Lưu ý rằng s390 không hỗ trợ KVM_GET_REG_LIST vì lý do lịch sử
(đọc: không ai quan tâm).  Tập hợp các thanh ghi trong kernel 4.x và mới hơn là:

-KVM_REG_S390_TODPR

-KVM_REG_S390_EPOCHDIFF

-KVM_REG_S390_CPU_TIMER

-KVM_REG_S390_CLOCK_COMP

-KVM_REG_S390_PFTOKEN

-KVM_REG_S390_PFCOMPARE

-KVM_REG_S390_PFSELECT

-KVM_REG_S390_PP

-KVM_REG_S390_GBEA

Lưu ý, đối với x86, tất cả các MSR được liệt kê bởi KVM_GET_MSR_INDEX_LIST đều được hỗ trợ dưới dạng
gõ KVM_X86_REG_TYPE_MSR, nhưng NOT được liệt kê thông qua KVM_GET_REG_LIST.

4,85 KVM_ARM_SET_DEVICE_ADDR (không dùng nữa)
---------------------------------------------

:Khả năng: KVM_CAP_ARM_SET_DEVICE_ADDR
:Kiến trúc: arm64
:Type: vm ioctl
:Thông số: struct kvm_arm_device_address (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

======================================================
  ENODEV Không xác định được id thiết bị
  ENXIO Thiết bị không được hỗ trợ trên hệ thống hiện tại
  Địa chỉ EEXIST đã được đặt
  E2BIG Địa chỉ bên ngoài không gian địa chỉ vật lý của khách
  EBUSY Địa chỉ trùng lặp với phạm vi thiết bị khác
  ======================================================

::

cấu trúc kvm_arm_device_addr {
	__u64 id;
	__u64 địa chỉ;
  };

Chỉ định địa chỉ thiết bị trong không gian địa chỉ vật lý của khách nơi khách
có thể truy cập các thiết bị được mô phỏng hoặc tiếp xúc trực tiếp mà hạt nhân máy chủ cần
để biết về. Trường id là một mã định danh cụ thể về kiến trúc cho một
thiết bị cụ thể.

arm64 chia trường id thành hai phần, id thiết bị và phần
id loại địa chỉ cụ thể cho từng thiết bị::

bit: ZZ0000ZZ 31 ... 16 ZZ0001ZZ
  trường: ZZ0002ZZ id thiết bị ZZ0003ZZ

arm64 hiện chỉ yêu cầu điều này khi sử dụng GIC trong kernel
hỗ trợ các tính năng VGIC phần cứng, sử dụng KVM_ARM_DEVICE_VGIC_V2
làm id thiết bị.  Khi thiết lập địa chỉ cơ sở cho khách
ánh xạ giao diện nhà phân phối và VGIC ảo VGIC, ioctl
phải được gọi sau khi gọi KVM_CREATE_IRQCHIP, nhưng trước khi gọi
KVM_RUN trên bất kỳ VCPU nào.  Gọi ioctl này hai lần cho bất kỳ
địa chỉ cơ sở sẽ trả về -EEXIST.

Lưu ý, IOCTL này không được dùng nữa và SET/GET_DEVICE_ATTR API linh hoạt hơn
nên được sử dụng thay thế.


4,86 KVM_PPC_RTAS_DEFINE_TOKEN
------------------------------

:Khả năng: KVM_CAP_PPC_RTAS
:Kiến trúc: ppc
:Type: vm ioctl
:Thông số: struct kvm_rtas_token_args
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xác định giá trị mã thông báo cho RTAS (Dịch vụ trừu tượng thời gian chạy)
service để cho phép nó được xử lý trong kernel.  các
đối số struct đưa ra tên của dịch vụ, tên này phải là tên
của một dịch vụ có triển khai phía kernel.  Nếu mã thông báo
giá trị khác 0, nó sẽ được liên kết với dịch vụ đó và
các cuộc gọi RTAS tiếp theo của khách chỉ định mã thông báo đó sẽ
được xử lý bởi kernel.  Nếu giá trị mã thông báo là 0 thì bất kỳ mã thông báo nào
liên quan đến dịch vụ sẽ bị lãng quên và RTAS tiếp theo
các cuộc gọi của khách cho dịch vụ đó sẽ được chuyển đến không gian người dùng để
xử lý.

4,87 KVM_SET_GUEST_DEBUG
------------------------

:Khả năng: KVM_CAP_SET_GUEST_DEBUG
:Kiến trúc: x86, s390, ppc, arm64
:Type: vcpu ioctl
:Thông số: struct kvm_guest_debug (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

::

cấu trúc kvm_guest_debug {
       __u32 điều khiển;
       __u32 đệm;
       cấu trúc kvm_guest_debug_arch;
  };

Thiết lập các thanh ghi gỡ lỗi dành riêng cho bộ xử lý và định cấu hình vcpu cho
xử lý các sự kiện gỡ lỗi của khách. Có hai phần trong cấu trúc, phần
đầu tiên, trường bit điều khiển cho biết loại sự kiện gỡ lỗi cần xử lý
khi chạy. Các bit điều khiển phổ biến là:

- KVM_GUESTDBG_ENABLE: tính năng gỡ lỗi khách được bật
  - KVM_GUESTDBG_SINGLESTEP: lần chạy tiếp theo nên thực hiện một bước

16 bit trên cùng của trường điều khiển là điều khiển dành riêng cho kiến trúc
cờ có thể bao gồm những điều sau đây:

- KVM_GUESTDBG_USE_SW_BP: sử dụng breakpoint phần mềm [x86, arm64]
  - KVM_GUESTDBG_USE_HW_BP: sử dụng breakpoint phần cứng [x86, s390]
  - KVM_GUESTDBG_USE_HW: sử dụng các sự kiện gỡ lỗi phần cứng [arm64]
  - KVM_GUESTDBG_INJECT_DB: tiêm ngoại lệ loại DB [x86]
  - KVM_GUESTDBG_INJECT_BP: tiêm ngoại lệ loại BP [x86]
  - KVM_GUESTDBG_EXIT_PENDING: kích hoạt lối ra của khách ngay lập tức [s390]
  - KVM_GUESTDBG_BLOCKIRQ: tránh chèn các ngắt/NMI/SMI [x86]

Ví dụ KVM_GUESTDBG_USE_SW_BP chỉ ra rằng điểm dừng phần mềm
được kích hoạt trong bộ nhớ nên chúng ta cần đảm bảo các ngoại lệ về điểm dừng được
được giữ đúng cách và vòng lặp chạy KVM thoát ra ở điểm dừng chứ không phải
chạy vào vectơ khách bình thường. Dành cho KVM_GUESTDBG_USE_HW_BP
chúng ta cần đảm bảo rằng các thanh ghi cụ thể của kiến trúc vCPU khách được
được cập nhật theo giá trị chính xác (được cung cấp).

Phần thứ hai của cấu trúc là kiến trúc cụ thể và
thường chứa một tập hợp các thanh ghi gỡ lỗi.

Đối với arm64, số lượng thanh ghi gỡ lỗi được xác định và thực hiện
có thể được xác định bằng cách truy vấn KVM_CAP_GUEST_DEBUG_HW_BPS và
Khả năng KVM_CAP_GUEST_DEBUG_HW_WPS trả về số dương
cho biết số lượng thanh ghi được hỗ trợ.

Đối với ppc, khả năng KVM_CAP_PPC_GUEST_DEBUG_SSTEP cho biết liệu
sự kiện gỡ lỗi một bước (KVM_GUESTDBG_SINGLESTEP) được hỗ trợ.

Ngoài ra, khi được hỗ trợ, khả năng của KVM_CAP_SET_GUEST_DEBUG2 sẽ cho biết
các bit KVM_GUESTDBG_* được hỗ trợ trong trường điều khiển.

Khi sự kiện gỡ lỗi thoát khỏi vòng lặp chạy chính kèm theo lý do
KVM_EXIT_DEBUG với phần kvm_debug_exit_arch của kvm_run
cấu trúc chứa thông tin gỡ lỗi cụ thể về kiến trúc.

4,88 KVM_GET_EMULATED_CPUID
---------------------------

:Khả năng: KVM_CAP_EXT_EMUL_CPUID
:Kiến trúc: x86
:Loại: hệ thống ioctl
:Thông số: struct kvm_cpuid2 (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_cpuid2 {
	__u32 không;
	__u32 cờ;
	struct kvm_cpuid_entry2 mục [0];
  };

'Cờ' thành viên được sử dụng để chuyển cờ từ không gian người dùng.

::

#define KVM_CPUID_FLAG_SIGNIFCANT_INDEX BIT(0)
  #define KVM_CPUID_FLAG_STATEFUL_FUNC BIT(1) /* không dùng nữa */
  #define KVM_CPUID_FLAG_STATE_READ_NEXT BIT(2) /* không dùng nữa */

cấu trúc kvm_cpuid_entry2 {
	__u32 chức năng;
	chỉ số __u32;
	__u32 cờ;
	__u32 eax;
	__u32 ebx;
	__u32 ecx;
	__u32 edx;
	__u32 đệm [3];
  };

Ioctl này trả về các tính năng cpuid x86 được mô phỏng bởi
kvm.Userspace có thể sử dụng thông tin được ioctl này trả về để truy vấn
những tính năng nào được mô phỏng bởi kvm thay vì hiện diện nguyên bản.

Không gian người dùng gọi KVM_GET_EMULATED_CPUID bằng cách chuyển kvm_cpuid2
cấu trúc với trường 'nent' cho biết số lượng mục trong
mảng có kích thước thay đổi 'mục'. Nếu số lượng mục quá ít
để mô tả khả năng của CPU, một lỗi (E2BIG) được trả về. Nếu
số quá cao, trường 'nent' được điều chỉnh và xảy ra lỗi (ENOMEM)
được trả lại. Nếu số vừa phải thì trường 'nent' sẽ được điều chỉnh
với số lượng mục nhập hợp lệ trong mảng 'mục nhập', sau đó là
đầy.

Các mục được trả về là các bit CPUID được đặt của các tính năng tương ứng
mà kvm mô phỏng, được trả về bởi lệnh CPUID, không xác định
hoặc các bit tính năng không được hỗ trợ bị xóa.

Ví dụ: các tính năng như x2apic có thể không có trong CPU chủ
nhưng bị kvm tiếp xúc trong KVM_GET_SUPPORTED_CPUID vì chúng có thể
được mô phỏng hiệu quả và do đó không được đưa vào đây.

Các trường trong mỗi mục được xác định như sau:

chức năng:
	 giá trị eax được sử dụng để có được mục nhập
  chỉ số:
	 giá trị ecx được sử dụng để lấy mục nhập (đối với các mục nhập
         bị ảnh hưởng bởi ecx)
  cờ:
    OR bằng 0 hoặc nhiều hơn trong số các điều sau:

KVM_CPUID_FLAG_SIGNIFCANT_INDEX:
           nếu trường chỉ mục hợp lệ

eax, ebx, ecx, edx:

các giá trị được trả về bởi lệnh cpuid cho
         sự kết hợp chức năng/chỉ số này

4,89 KVM_S390_MEM_OP
--------------------

:Khả năng: KVM_CAP_S390_MEM_OP, KVM_CAP_S390_PROTECTED, KVM_CAP_S390_MEM_OP_EXTENSION
:Kiến trúc: s390
:Loại: vm ioctl, vcpu ioctl
:Thông số: struct kvm_s390_mem_op (trong)
:Trả về: = 0 khi thành công,
          < 0 đối với lỗi chung (ví dụ: -EFAULT hoặc -ENOMEM),
          Mã ngoại lệ chương trình 16 bit nếu quyền truy cập gây ra ngoại lệ đó

Đọc hoặc ghi dữ liệu từ/vào bộ nhớ của VM.
Khả năng KVM_CAP_S390_MEM_OP_EXTENSION chỉ định chức năng là gì
được hỗ trợ.

Các tham số được chỉ định thông qua cấu trúc sau::

cấu trúc kvm_s390_mem_op {
	__u64 gaddr;		/*địa chỉ của khách */
	__u64 cờ;		/* cờ */
	__u32 kích thước;		/*số lượng byte */
	__u32 op;		/*kiểu hoạt động*/
	__u64 nhé;		/* vùng đệm trong vùng người dùng */
	công đoàn {
		cấu trúc {
			__u8 ar;	/*số đăng ký truy cập */
			phím __u8;	/* khóa truy cập, bị bỏ qua nếu cờ không được đặt */
			__u8 pad1[6];	/* bị bỏ qua */
			__u64 old_addr;	/* bị bỏ qua nếu cờ không được đặt */
		};
		__u32 sida_offset; /* offset vào sida */
		__u8 dành riêng[32]; /* bị bỏ qua */
	};
  };

Địa chỉ bắt đầu của vùng bộ nhớ phải được chỉ định trong "gaddr"
trường và độ dài của vùng trong trường "kích thước" (không được
là 0). Giá trị tối đa cho "size" có thể đạt được bằng cách kiểm tra
Khả năng KVM_CAP_S390_MEM_OP. "buf" là bộ đệm được cung cấp bởi
ứng dụng không gian người dùng nơi dữ liệu đọc sẽ được ghi vào
quyền truy cập đọc hoặc nơi lưu trữ dữ liệu cần ghi
một quyền truy cập ghi.  Trường "dành riêng" dành cho các tiện ích mở rộng trong tương lai.
Các giá trị dành riêng và không sử dụng sẽ bị bỏ qua. Tiện ích mở rộng trong tương lai để thêm thành viên phải
giới thiệu cờ mới.

Loại hoạt động được chỉ định trong trường "op". Cờ sửa đổi
hành vi của họ có thể được đặt trong trường "cờ". Các bit cờ không xác định phải
được đặt thành 0.

Các hoạt động có thể là:
  * ZZ0000ZZ
  * ZZ0001ZZ
  * ZZ0002ZZ
  * ZZ0003ZZ
  * ZZ0004ZZ
  * ZZ0005ZZ
  * ZZ0006ZZ

Đọc/ghi logic:
^^^^^^^^^^^^^^^^^^^

Truy cập bộ nhớ logic, tức là dịch địa chỉ khách đã cho thành địa chỉ tuyệt đối
địa chỉ dựa trên trạng thái của VCPU và sử dụng địa chỉ tuyệt đối làm mục tiêu của
quyền truy cập. "ar" chỉ định số đăng ký truy cập sẽ được sử dụng; hợp lệ
phạm vi là 0..15.
Truy cập logic chỉ được phép đối với VCPU ioctl.
Quyền truy cập hợp lý chỉ được phép dành cho những khách không được bảo vệ.

Cờ được hỗ trợ:
  * ZZ0000ZZ
  * ZZ0001ZZ
  * ZZ0002ZZ

Cờ KVM_S390_MEMOP_F_CHECK_ONLY có thể được đặt để kiểm tra xem
truy cập bộ nhớ tương ứng sẽ gây ra ngoại lệ truy cập; tuy nhiên,
không có quyền truy cập thực sự vào dữ liệu trong bộ nhớ tại đích được thực hiện.
Trong trường hợp này, "buf" không được sử dụng và có thể là NULL.

Trong trường hợp xảy ra ngoại lệ truy cập trong quá trình truy cập (hoặc sẽ xảy ra
trong trường hợp KVM_S390_MEMOP_F_CHECK_ONLY), ioctl trả về giá trị dương
số lỗi cho biết loại ngoại lệ. Ngoại lệ này cũng
được nâng trực tiếp tại VCPU tương ứng nếu cờ
KVM_S390_MEMOP_F_INJECT_EXCEPTION được thiết lập.
Về các trường hợp ngoại lệ bảo vệ, trừ khi có quy định khác, phần được tiêm
mã định danh ngoại lệ dịch thuật (TEID) biểu thị sự ngăn chặn.

Nếu cờ KVM_S390_MEMOP_F_SKEY_PROTECTION được đặt, khóa lưu trữ
sự bảo vệ cũng có hiệu lực và có thể gây ra ngoại lệ nếu quyền truy cập bị
bị cấm cung cấp khóa truy cập được chỉ định bởi "khóa"; phạm vi hợp lệ là 0..15.
KVM_S390_MEMOP_F_SKEY_PROTECTION khả dụng nếu KVM_CAP_S390_MEM_OP_EXTENSION
là > 0.
Vì bộ nhớ được truy cập có thể trải rộng trên nhiều trang và những trang đó có thể có
các khóa lưu trữ khác nhau, có thể xảy ra ngoại lệ bảo vệ
sau khi bộ nhớ đã được sửa đổi. Trong trường hợp này, nếu ngoại lệ được đưa vào,
TEID không biểu thị sự triệt tiêu.

Đọc/ghi tuyệt đối:
^^^^^^^^^^^^^^^^^^^^

Truy cập bộ nhớ tuyệt đối. Hoạt động này được thiết kế để sử dụng với
Cờ KVM_S390_MEMOP_F_SKEY_PROTECTION, để cho phép truy cập bộ nhớ và thực hiện
các bước kiểm tra cần thiết để bảo vệ khóa lưu trữ dưới dạng một thao tác (ngược lại với
không gian người dùng nhận khóa lưu trữ, thực hiện kiểm tra và truy cập
bộ nhớ sau đó, điều này có thể dẫn đến sự chậm trễ giữa kiểm tra và truy cập).
Quyền truy cập tuyệt đối được phép cho VM ioctl nếu KVM_CAP_S390_MEM_OP_EXTENSION
có tập bit KVM_S390_MEMOP_EXTENSION_CAP_BASE.
Hiện tại, quyền truy cập tuyệt đối không được phép đối với VCPU ioctls.
Quyền truy cập tuyệt đối chỉ được phép dành cho những khách không được bảo vệ.

Cờ được hỗ trợ:
  * ZZ0000ZZ
  * ZZ0001ZZ

Ngữ nghĩa của các cờ phổ biến với các truy cập logic cũng như đối với các truy cập logic
truy cập.

cmpxchg tuyệt đối:
^^^^^^^^^^^^^^^^^^

Thực hiện cmpxchg trên bộ nhớ khách tuyệt đối. Dành cho sử dụng với
Cờ KVM_S390_MEMOP_F_SKEY_PROTECTION.
Thay vì thực hiện ghi vô điều kiện, quyền truy cập chỉ xảy ra nếu mục tiêu
vị trí chứa giá trị được chỉ ra bởi "old_addr".
Điều này được thực hiện dưới dạng cmpxchg nguyên tử với độ dài được chỉ định bởi "size"
tham số. "size" phải là lũy thừa của hai đến và bao gồm 16.
Nếu việc trao đổi không diễn ra vì giá trị mục tiêu không khớp với
giá trị cũ, giá trị "old_addr" trỏ tới sẽ được thay thế bằng giá trị đích.
Không gian người dùng có thể biết liệu một cuộc trao đổi có diễn ra hay không bằng cách kiểm tra xem sự thay thế này có
đã xảy ra. Op cmpxchg được phép cho VM ioctl nếu
KVM_CAP_S390_MEM_OP_EXTENSION có cờ KVM_S390_MEMOP_EXTENSION_CAP_CMPXCHG được đặt.

Cờ được hỗ trợ:
  * ZZ0000ZZ

SIDA đọc/ghi:
^^^^^^^^^^^^^^^^

Truy cập vùng dữ liệu lệnh an toàn chứa các toán hạng bộ nhớ cần thiết
để hướng dẫn thi đua cho khách được bảo vệ.
Quyền truy cập SIDA khả dụng nếu khả năng KVM_CAP_S390_PROTECTED khả dụng.
Chỉ cho phép truy cập SIDA đối với VCPU ioctl.
Chỉ những khách được bảo vệ mới được phép truy cập SIDA.

Không có cờ nào được hỗ trợ.

4,90 KVM_S390_GET_SKEYS
-----------------------

:Khả năng: KVM_CAP_S390_SKEYS
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_skeys
:Trả về: 0 nếu thành công, KVM_S390_GET_SKEYS_NONE nếu khách không sử dụng bộ nhớ
          khóa, giá trị âm do lỗi

Ioctl này được sử dụng để lấy các giá trị khóa lưu trữ của khách trên s390
kiến trúc. Ioctl lấy tham số thông qua cấu trúc kvm_s390_skeys::

cấu trúc kvm_s390_skeys {
	__u64 start_gfn;
	__u64 đếm;
	__u64 skeydata_addr;
	__u32 cờ;
	__u32 dành riêng[9];
  };

Trường start_gfn là số khung khách đầu tiên có khóa lưu trữ
bạn muốn có được.

Trường đếm là số khung hình liên tiếp (bắt đầu từ start_gfn)
có chìa khóa lưu trữ để lấy. Trường đếm phải có ít nhất là 1 và tối đa
giá trị được phép được xác định là KVM_S390_SKEYS_MAX. Các giá trị ngoài phạm vi này
sẽ khiến ioctl trả về -EINVAL.

Trường skeydata_addr là địa chỉ của bộ đệm đủ lớn để chứa số đếm
byte. Bộ đệm này sẽ được ioctl lấp đầy dữ liệu khóa lưu trữ.

4,91 KVM_S390_SET_SKEYS
-----------------------

:Khả năng: KVM_CAP_S390_SKEYS
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_skeys
:Trả về: 0 nếu thành công, giá trị âm nếu có lỗi

Ioctl này được sử dụng để đặt giá trị khóa lưu trữ của khách trên s390
kiến trúc. Ioctl lấy tham số thông qua cấu trúc kvm_s390_skeys.
Xem phần trên KVM_S390_GET_SKEYS để biết định nghĩa cấu trúc.

Trường start_gfn là số khung khách đầu tiên có khóa lưu trữ
bạn muốn thiết lập.

Trường đếm là số khung hình liên tiếp (bắt đầu từ start_gfn)
có chìa khóa lưu trữ để lấy. Trường đếm phải có ít nhất là 1 và tối đa
giá trị được phép được xác định là KVM_S390_SKEYS_MAX. Các giá trị ngoài phạm vi này
sẽ khiến ioctl trả về -EINVAL.

Trường skeydata_addr là địa chỉ của bộ đệm chứa byte đếm của
khóa lưu trữ. Mỗi byte trong bộ đệm sẽ được đặt làm khóa lưu trữ cho một
khung đơn bắt đầu từ start_gfn để đếm khung.

Lưu ý: Nếu tìm thấy bất kỳ giá trị khóa không hợp lệ về mặt kiến trúc nào trong dữ liệu đã cho thì
ioctl sẽ trả về -EINVAL.

4,92 KVM_S390_IRQ
-----------------

:Khả năng: KVM_CAP_S390_INJECT_IRQ
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: struct kvm_s390_irq (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:


====== ======================================================================
  Loại ngắt EINVAL không hợp lệ
          loại là KVM_S390_SIGP_STOP và tham số cờ là giá trị không hợp lệ,
          loại là KVM_S390_INT_EXTERNAL_CALL và mã lớn hơn
          hơn mức tối đa của VCPU
  Loại EBUSY là KVM_S390_SIGP_SET_PREFIX và vcpu không bị dừng,
          loại là KVM_S390_SIGP_STOP và lệnh dừng irq đang chờ xử lý,
          loại là KVM_S390_INT_EXTERNAL_CALL và ngắt cuộc gọi bên ngoài
          đang chờ xử lý
  ====== ======================================================================

Cho phép đưa ra một ngắt cho khách.

Sử dụng struct kvm_s390_irq làm tham số cho phép
để thêm tải trọng bổ sung mà không phải
có thể thông qua KVM_S390_INTERRUPT.

Các tham số ngắt được truyền qua kvm_s390_irq::

cấu trúc kvm_s390_irq {
	__u64 loại;
	công đoàn {
		cấu trúc kvm_s390_io_info io;
		struct kvm_s390_ext_info ext;
		cấu trúc kvm_s390_pgm_info pgm;
		struct kvm_s390_emerg_info nổi lên;
		struct kvm_s390_extcall_info extcall;
		tiền tố struct kvm_s390_prefix_info;
		struct kvm_s390_stop_info dừng;
		struct kvm_s390_mchk_info mchk;
		char dành riêng[64];
	} bạn;
  };

loại có thể là một trong những loại sau:

- KVM_S390_SIGP_STOP - dừng sigp; tham số trong .stop
- KVM_S390_PROGRAM_INT - kiểm tra chương trình; các tham số trong .pgm
- KVM_S390_SIGP_SET_PREFIX - tiền tố bộ sigp; các tham số trong .prefix
- KVM_S390_RESTART - khởi động lại; không có tham số
- KVM_S390_INT_CLOCK_COMP - ngắt bộ so sánh đồng hồ; không có tham số
- KVM_S390_INT_CPU_TIMER - Ngắt hẹn giờ CPU; không có tham số
- KVM_S390_INT_EMERGENCY - sigp khẩn cấp; các tham số trong .emerg
- KVM_S390_INT_EXTERNAL_CALL - cuộc gọi bên ngoài sigp; các tham số trong .extcall
- KVM_S390_MCHK - ngắt kiểm tra máy; tham số trong .mchk

Đây là vcpu ioctl không đồng bộ và có thể được gọi từ bất kỳ luồng nào.

4,94 KVM_S390_GET_IRQ_STATE
---------------------------

:Khả năng: KVM_CAP_S390_IRQ_STATE
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: struct kvm_s390_irq_state (out)
:Trả về: >= số byte được sao chép vào bộ đệm,
          -EINVAL nếu kích thước bộ đệm là 0,
          -ENOBUFS nếu kích thước bộ đệm quá nhỏ để phù hợp với tất cả các ngắt đang chờ xử lý,
          -EFAULT nếu địa chỉ bộ đệm không hợp lệ

Ioctl này cho phép không gian người dùng truy xuất trạng thái hoàn chỉnh của tất cả các
các ngắt đang chờ xử lý trong một bộ đệm duy nhất. Các trường hợp sử dụng bao gồm di chuyển
và sự xem xét nội tâm. Cấu trúc tham số chứa địa chỉ của một
bộ đệm không gian người dùng và độ dài của nó ::

cấu trúc kvm_s390_irq_state {
	__u64 nhé;
	__u32 cờ;        /* sẽ không được sử dụng vì lý do tương thích */
	__u32 len;
	__u32 dành riêng[4];  /* sẽ không được sử dụng vì lý do tương thích */
  };

Không gian người dùng chuyển vào cấu trúc trên và với mỗi ngắt đang chờ xử lý, một
struct kvm_s390_irq được sao chép vào bộ đệm được cung cấp.

Cấu trúc chứa các cờ và trường dành riêng cho các tiện ích mở rộng trong tương lai. Như
hạt nhân không bao giờ kiểm tra cờ == 0 và QEMU không bao giờ đặt trước cờ và
dành riêng, những trường này không thể được sử dụng trong tương lai mà không bị hỏng
khả năng tương thích.

Nếu -ENOBUFS được trả về thì bộ đệm được cung cấp quá nhỏ và không gian người dùng
có thể thử lại với bộ đệm lớn hơn.

4,95 KVM_S390_SET_IRQ_STATE
---------------------------

:Khả năng: KVM_CAP_S390_IRQ_STATE
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: struct kvm_s390_irq_state (trong)
:Trả về: 0 nếu thành công,
          -EFAULT nếu địa chỉ bộ đệm không hợp lệ,
          -EINVAL cho độ dài bộ đệm không hợp lệ (xem bên dưới),
          -EBUSY nếu đã có các ngắt đang chờ xử lý,
          lỗi xảy ra khi thực sự tiêm
          ngắt lời. Xem KVM_S390_IRQ.

Ioctl này cho phép không gian người dùng thiết lập trạng thái hoàn chỉnh của tất cả các CPU-local
các ngắt hiện đang chờ xử lý đối với vcpu. Nó nhằm mục đích khôi phục
trạng thái ngắt sau khi di chuyển. Tham số đầu vào là bộ đệm không gian người dùng
chứa cấu trúc kvm_s390_irq_state::

cấu trúc kvm_s390_irq_state {
	__u64 nhé;
	__u32 cờ;        /* sẽ không được sử dụng vì lý do tương thích */
	__u32 len;
	__u32 dành riêng[4];  /* sẽ không được sử dụng vì lý do tương thích */
  };

Các hạn chế đối với cờ và dành riêng cũng được áp dụng.
(xem KVM_S390_GET_IRQ_STATE)

Bộ nhớ không gian người dùng được tham chiếu bởi buf chứa cấu trúc kvm_s390_irq
cho mỗi ngắt được đưa vào máy khách.
Nếu một trong các ngắt không thể được đưa vào vì lý do nào đó thì
ioctl hủy bỏ.

len phải là bội số của sizeof(struct kvm_s390_irq). Nó phải > 0
và nó không được vượt quá (max_vcpus + 32) * sizeof(struct kvm_s390_irq),
đó là số lượng tối đa các ngắt CPU cục bộ có thể đang chờ xử lý.

4,96 KVM_SMI
------------

:Khả năng: KVM_CAP_X86_SMM
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Xếp hàng SMI trên vcpu của luồng.

4,97 KVM_X86_SET_MSR_FILTER
----------------------------

:Khả năng: KVM_CAP_X86_MSR_FILTER
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_msr_filter
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

::

cấu trúc kvm_msr_filter_range {
  #define KVM_MSR_FILTER_READ (1 << 0)
  #define KVM_MSR_FILTER_WRITE (1 << 1)
	__u32 cờ;
	__u32 nmsrs; /* số msrs trong bitmap */
	__u32 căn cứ;  /* MSR lập chỉ mục bitmap bắt đầu tại */
	__u8 ZZ0000ZZ a 1 bit cho phép thực hiện các thao tác trong cờ, 0 từ chối */
  };

#define KVM_MSR_FILTER_MAX_RANGES 16
  cấu trúc kvm_msr_filter {
  #define KVM_MSR_FILTER_DEFAULT_ALLOW (0 << 0)
  #define KVM_MSR_FILTER_DEFAULT_DENY (1 << 0)
	__u32 cờ;
	phạm vi cấu trúc kvm_msr_filter_range [KVM_MSR_FILTER_MAX_RANGES];
  };

giá trị cờ cho ZZ0000ZZ:

ZZ0000ZZ

Lọc quyền truy cập đọc vào MSR bằng cách sử dụng bitmap đã cho. Số 0 trong bitmap
  chỉ ra rằng quyền truy cập đọc nên bị từ chối, trong khi 1 chỉ ra rằng
  nên cho phép đọc một MSR cụ thể bất kể mặc định
  hành động lọc

ZZ0000ZZ

Lọc quyền truy cập ghi vào MSR bằng cách sử dụng bitmap đã cho. Số 0 trong bitmap
  chỉ ra rằng quyền truy cập ghi nên bị từ chối, trong khi 1 chỉ ra rằng
  nên cho phép ghi cho một MSR cụ thể bất kể mặc định là gì
  hành động lọc

giá trị cờ cho ZZ0000ZZ:

ZZ0000ZZ

Nếu không có phạm vi bộ lọc nào khớp với chỉ mục MSR đang được truy cập, KVM sẽ
  cho phép truy cập vào tất cả các MSR theo mặc định.

ZZ0000ZZ

Nếu không có phạm vi bộ lọc nào khớp với chỉ mục MSR đang được truy cập, KVM sẽ
  từ chối quyền truy cập vào tất cả các MSR theo mặc định.

Ioctl này cho phép không gian người dùng xác định tối đa 16 bitmap của phạm vi MSR để từ chối
truy cập MSR của khách thường được KVM cho phép.  Nếu MSR không
được bao phủ bởi một phạm vi cụ thể, hành vi lọc "mặc định" sẽ được áp dụng.  Mỗi
phạm vi bitmap bao gồm các MSR từ [base .. base+nmsrs).

Nếu quyền truy cập MSR bị không gian người dùng từ chối, thì hành vi KVM sẽ phụ thuộc vào
KVM_MSR_EXIT_REASON_FILTER của KVM_CAP_X86_USER_SPACE_MSR có hay không
đã bật.  Nếu KVM_MSR_EXIT_REASON_FILTER được bật, KVM sẽ thoát khỏi không gian người dùng
đối với các truy cập bị từ chối, tức là không gian người dùng chặn truy cập MSR một cách hiệu quả.  Nếu
KVM_MSR_EXIT_REASON_FILTER chưa được kích hoạt, KVM sẽ đưa #GP vào máy khách
về các truy cập bị từ chối.  Lưu ý, nếu quyền truy cập MSR bị từ chối trong quá trình mô phỏng MSR
tải/lưu trữ trong quá trình chuyển đổi VMX, KVM bỏ qua KVM_MSR_EXIT_REASON_FILTER.
Xem cảnh báo dưới đây để biết chi tiết đầy đủ.

Nếu không gian người dùng cho phép truy cập MSR, KVM sẽ mô phỏng và/hoặc ảo hóa
quyền truy cập theo mô hình vCPU.  Lưu ý, KVM cuối cùng vẫn có thể
tiêm #GP nếu không gian người dùng cho phép quyền truy cập, ví dụ: nếu KVM không hỗ trợ
MSR hoặc tuân theo hành vi kiến trúc của MSR.

Theo mặc định, KVM hoạt động ở chế độ KVM_MSR_FILTER_DEFAULT_ALLOW không có phạm vi MSR
bộ lọc.

Gọi ioctl này với một tập hợp phạm vi trống (tất cả nmsrs == 0) sẽ vô hiệu hóa MSR
lọc. Ở chế độ đó, ZZ0000ZZ không hợp lệ và gây ra
một lỗi.

.. warning::
   MSR accesses that are side effects of instruction execution (emulated or
   native) are not filtered as hardware does not honor MSR bitmaps outside of
   RDMSR and WRMSR, and KVM mimics that behavior when emulating instructions
   to avoid pointless divergence from hardware.  E.g. RDPID reads MSR_TSC_AUX,
   SYSENTER reads the SYSENTER MSRs, etc.

   MSRs that are loaded/stored via dedicated VMCS fields are not filtered as
   part of VM-Enter/VM-Exit emulation.

   MSRs that are loaded/store via VMX's load/store lists _are_ filtered as part
   of VM-Enter/VM-Exit emulation.  If an MSR access is denied on VM-Enter, KVM
   synthesizes a consistency check VM-Exit(EXIT_REASON_MSR_LOAD_FAIL).  If an
   MSR access is denied on VM-Exit, KVM synthesizes a VM-Abort.  In short, KVM
   extends Intel's architectural list of MSRs that cannot be loaded/saved via
   the VM-Enter/VM-Exit MSR list.  It is platform owner's responsibility to
   to communicate any such restrictions to their end users.

   x2APIC MSR accesses cannot be filtered (KVM silently ignores filters that
   cover any x2APIC MSRs).

Lưu ý, việc gọi ioctl này trong khi vCPU đang chạy vốn dĩ là không phù hợp.  Tuy nhiên,
KVM đảm bảo rằng vCPU sẽ nhìn thấy bộ lọc trước đó hoặc bộ lọc mới
bộ lọc, ví dụ: MSR có cài đặt giống hệt nhau ở cả bộ lọc cũ và mới sẽ
có hành vi xác định.

Tương tự, nếu không gian người dùng muốn chặn các truy cập bị từ chối,
KVM_MSR_EXIT_REASON_FILTER phải được bật trước khi kích hoạt bất kỳ bộ lọc nào và
được bật cho đến khi tất cả các bộ lọc bị tắt.  Không làm như vậy có thể
dẫn đến việc KVM tiêm #GP thay vì thoát ra không gian người dùng.

4,98 KVM_CREATE_SPAPR_TCE_64
----------------------------

:Khả năng: KVM_CAP_SPAPR_TCE_64
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: struct kvm_create_spapr_tce_64 (trong)
:Trả về: bộ mô tả tệp để thao tác bảng TCE đã tạo

Đây là tiện ích mở rộng cho KVM_CAP_SPAPR_TCE chỉ hỗ trợ 32bit
cửa sổ, được mô tả trong 4.62 KVM_CREATE_SPAPR_TCE

Khả năng này sử dụng cấu trúc mở rộng trong giao diện ioctl::

/* cho KVM_CAP_SPAPR_TCE_64 */
  cấu trúc kvm_create_spapr_tce_64 {
	__u64 sư tử;
	__u32 trang_shift;
	__u32 cờ;
	__u64 bù đắp;	/* trong các trang */
	__u64 kích thước; 	/* trong các trang */
  };

Mục đích của việc mở rộng là hỗ trợ thêm một cửa sổ DMA lớn hơn với
kích thước trang thay đổi.
KVM_CREATE_SPAPR_TCE_64 nhận được kích thước cửa sổ 64 bit, chuyển trang IOMMU và
độ lệch bus của cửa sổ DMA tương ứng, @size và @offset là các số
của các trang IOMMU.

@flags hiện không được sử dụng.

Phần còn lại của chức năng giống hệt KVM_CREATE_SPAPR_TCE.

4,99 KVM_REINJECT_CONTROL
-------------------------

:Khả năng: KVM_CAP_REINJECT_CONTROL
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_reinject_control (trong)
:Trả về: 0 nếu thành công,
         -EFAULT nếu không thể đọc được struct kvm_reinject_control,
         -ENXIO nếu KVM_CREATE_PIT hoặc KVM_CREATE_PIT2 không thành công trước đó.

i8254 (PIT) có hai chế độ, tiêm lại và !reinject.  Mặc định là tiêm lại,
trong đó hàng đợi KVM đã trôi qua tích tắc i8254 và giám sát việc hoàn thành ngắt từ
(các) vectơ mà i8254 đưa vào.  Chế độ tái chế loại bỏ một dấu tích và tiêm nó
ngắt bất cứ khi nào không có ngắt đang chờ xử lý từ i8254.
Chế độ !reinject sẽ đưa ra một ngắt ngay khi có dấu tích xuất hiện.

::

cấu trúc kvm_reinject_control {
	__u8 pit_reinject;
	__u8 dành riêng[31];
  };

pit_reinject = 0 (chế độ!reinject) được khuyến nghị, trừ khi chạy phiên bản cũ
hệ điều hành sử dụng PIT để tính thời gian (ví dụ: Linux 2.4.x).

4.100 KVM_PPC_CONFIGURE_V3_MMU
------------------------------

:Khả năng: KVM_CAP_PPC_MMU_RADIX hoặc KVM_CAP_PPC_MMU_HASH_V3
:Kiến trúc: ppc
:Type: vm ioctl
:Thông số: struct kvm_ppc_mmuv3_cfg (trong)
:Trả về: 0 nếu thành công,
         -EFAULT nếu không thể đọc được struct kvm_ppc_mmuv3_cfg,
         -EINVAL nếu cấu hình không hợp lệ

Ioctl này kiểm soát xem khách sẽ sử dụng cơ số hay HPT (được băm
bảng trang) và đặt con trỏ tới bảng quy trình để
vị khách.

::

cấu trúc kvm_ppc_mmuv3_cfg {
	__u64 cờ;
	__u64 tiến trình_bảng;
  };

Có hai bit có thể được đặt trong cờ; KVM_PPC_MMUV3_RADIX và
KVM_PPC_MMUV3_GTSE.  KVM_PPC_MMUV3_RADIX, nếu được đặt, sẽ định cấu hình khách
để sử dụng bản dịch cây cơ số và nếu rõ ràng, hãy sử dụng bản dịch HPT.
KVM_PPC_MMUV3_GTSE, nếu được đặt và nếu KVM cho phép, hãy định cấu hình máy khách
để có thể sử dụng các hướng dẫn vô hiệu hóa TLB và SLB toàn cầu;
nếu rõ ràng, khách không được sử dụng những hướng dẫn này.

Trường process_table chỉ định địa chỉ và kích thước của khách
bảng quy trình nằm trong không gian của khách.  Trường này được định dạng
là từ kép thứ hai của mục nhập bảng phân vùng, như được định nghĩa trong
Power ISA V3.00, Sách III phần 5.7.6.1.

4.101 KVM_PPC_GET_RMMU_INFO
---------------------------

:Khả năng: KVM_CAP_PPC_MMU_RADIX
:Kiến trúc: ppc
:Type: vm ioctl
:Thông số: struct kvm_ppc_rmmu_info (ra)
:Trả về: 0 nếu thành công,
	 -EFAULT nếu không thể ghi struct kvm_ppc_rmmu_info,
	 -EINVAL nếu không có thông tin hữu ích nào có thể được trả lại

ioctl này trả về một cấu trúc chứa hai thứ: (a) một danh sách
chứa hình học cây cơ số được hỗ trợ và (b) danh sách ánh xạ
kích thước trang để đặt vào trường "AP" (kích thước trang thực tế) cho tlbie
(TLB mục nhập không hợp lệ).

::

cấu trúc kvm_ppc_rmmu_info {
	cấu trúc kvm_ppc_radix_geom {
		__u8 trang_shift;
		__u8 cấp_bits[4];
		__u8 đệm[3];
	} hình học[8];
	__u32 ap_encodings[8];
  };

Trường hình học[] cung cấp tối đa 8 hình học được hỗ trợ cho
bảng trang cơ số, xét theo log cơ số 2 của trang nhỏ nhất
kích thước và số bit được lập chỉ mục ở mỗi cấp của cây, từ
cấp PTE lên đến cấp PGD theo thứ tự đó.  Bất kỳ mục nào không được sử dụng
sẽ có 0 trong trường page_shift.

ap_encodings cung cấp kích thước trang được hỗ trợ và trường AP của chúng
mã hóa, được mã hóa với giá trị AP ở 3 bit trên cùng và nhật ký
cơ sở 2 của kích thước trang ở 6 bit dưới cùng.

4.102 KVM_PPC_RESIZE_HPT_PREPARE
--------------------------------

:Khả năng: KVM_CAP_SPAPR_RESIZE_HPT
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: struct kvm_ppc_resize_hpt (trong)
:Trả về: 0 khi hoàn thành thành công,
	 >0 nếu HPT mới đang được chuẩn bị, giá trị này là ước tính
         số mili giây cho đến khi quá trình chuẩn bị hoàn tất,
         -EFAULT nếu không thể đọc được struct kvm_reinject_control,
	 -EINVAL nếu ca hoặc cờ được cung cấp không hợp lệ,
	 -ENOMEM nếu không thể phân bổ HPT mới,

Được sử dụng để triển khai tiện ích mở rộng PAPR để thay đổi kích thước thời gian chạy của khách
Bảng trang băm (HPT).  Cụ thể việc này khởi động, dừng hoặc giám sát
về cơ bản là việc chuẩn bị một HPT tiềm năng mới cho khách
triển khai siêu cuộc gọi H_RESIZE_HPT_PREPARE.

::

cấu trúc kvm_ppc_resize_hpt {
	__u64 cờ;
	__u32 ca;
	__u32 đệm;
  };

Nếu được gọi với shift > 0 khi không có HPT đang chờ xử lý cho khách,
việc này bắt đầu chuẩn bị một HPT mới đang chờ xử lý có kích thước 2^(shift) byte.
Sau đó nó trả về một số nguyên dương với số lượng ước tính của
mili giây cho đến khi quá trình chuẩn bị hoàn tất.

Nếu được gọi khi có HPT đang chờ xử lý có kích thước không khớp với kích thước đó
được yêu cầu trong các tham số, loại bỏ HPT đang chờ xử lý hiện có và
tạo một cái mới như trên.

Nếu được gọi khi có HPT đang chờ xử lý với kích thước được yêu cầu, sẽ:

* Nếu quá trình chuẩn bị HPT đang chờ xử lý đã hoàn tất, hãy trả về 0
  * Nếu quá trình chuẩn bị HPT đang chờ xử lý không thành công, hãy trả về lỗi
    mã, sau đó loại bỏ HPT đang chờ xử lý.
  * Nếu vẫn đang trong quá trình chuẩn bị HPT đang chờ xử lý, hãy trả lại
    số mili giây ước tính cho đến khi quá trình chuẩn bị hoàn tất.

Nếu được gọi với shift == 0, sẽ loại bỏ mọi HPT hiện đang chờ xử lý và
trả về 0 (tức là hủy mọi quá trình chuẩn bị đang diễn ra).

cờ được dành riêng cho việc mở rộng trong tương lai, hiện đang đặt bất kỳ bit nào trong
cờ sẽ dẫn đến -EINVAL.

Thông thường, điều này sẽ được gọi lặp đi lặp lại với cùng tham số cho đến khi
nó trả về <= 0. Cuộc gọi đầu tiên sẽ bắt đầu quá trình chuẩn bị, cuộc gọi tiếp theo
người ta sẽ giám sát việc chuẩn bị cho đến khi nó hoàn thành hoặc thất bại.

4.103 KVM_PPC_RESIZE_HPT_COMMIT
-------------------------------

:Khả năng: KVM_CAP_SPAPR_RESIZE_HPT
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: struct kvm_ppc_resize_hpt (trong)
:Trả về: 0 khi hoàn thành thành công,
         -EFAULT nếu không thể đọc được struct kvm_reinject_control,
	 -EINVAL nếu ca hoặc cờ được cung cấp không hợp lệ,
	 -ENXIO không có HPT đang chờ xử lý hoặc HPT đang chờ xử lý không
         có kích thước yêu cầu,
	 -EBUSY nếu HPT đang chờ xử lý chưa được chuẩn bị đầy đủ,
	 -ENOSPC nếu có xung đột băm khi di chuyển hiện có
         Các mục HPT cho HPT mới,
	 -EIO trong các điều kiện lỗi khác

Được sử dụng để triển khai tiện ích mở rộng PAPR để thay đổi kích thước thời gian chạy của khách
Bảng trang băm (HPT).  Cụ thể điều này yêu cầu khách phải
chuyển sang làm việc với HPT mới, về cơ bản là triển khai
Siêu cuộc gọi H_RESIZE_HPT_COMMIT.

::

cấu trúc kvm_ppc_resize_hpt {
	__u64 cờ;
	__u32 ca;
	__u32 đệm;
  };

Điều này chỉ nên được gọi sau khi KVM_PPC_RESIZE_HPT_PREPARE có
trả về 0 với cùng tham số.  Trong các trường hợp khác
KVM_PPC_RESIZE_HPT_COMMIT sẽ trả về lỗi (thường là -ENXIO hoặc
-EBUSY, mặc dù những điều khác có thể thực hiện được nếu quá trình chuẩn bị đã được bắt đầu,
nhưng không thành công).

Điều này sẽ có tác dụng không xác định đối với khách nếu chưa có
tự đặt nó ở trạng thái không hoạt động, nơi không có vcpu nào kích hoạt MMU
truy cập bộ nhớ.

Khi hoàn thành thành công, HPT đang chờ xử lý sẽ trở thành tài khoản hoạt động của khách
HPT và HPT trước đó sẽ bị loại bỏ.

Nếu không thành công, khách vẫn sẽ hoạt động trên HPT trước đó.

4.104 KVM_X86_GET_MCE_CAP_SUPPORTED
-----------------------------------

:Khả năng: KVM_CAP_MCE
:Kiến trúc: x86
:Loại: hệ thống ioctl
:Thông số: u64 mce_cap (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Trả về các khả năng MCE được hỗ trợ. Tham số u64 mce_cap
có cùng định dạng với thanh ghi MSR_IA32_MCG_CAP. Được hỗ trợ
khả năng sẽ có các bit tương ứng được thiết lập.

4.105 KVM_X86_SETUP_MCE
-----------------------

:Khả năng: KVM_CAP_MCE
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: u64 mcg_cap (trong)
:Trả về: 0 nếu thành công,
         -EFAULT nếu không thể đọc được u64 mcg_cap,
         -EINVAL nếu số lượng ngân hàng được yêu cầu không hợp lệ,
         -EINVAL nếu được yêu cầu thì khả năng MCE không được hỗ trợ.

Khởi tạo hỗ trợ MCE để sử dụng. Tham số u64 mcg_cap
có cùng định dạng với thanh ghi MSR_IA32_MCG_CAP và
chỉ định những khả năng nào sẽ được kích hoạt. Tối đa
số lượng ngân hàng báo cáo lỗi được hỗ trợ có thể được truy xuất khi
đang kiểm tra KVM_CAP_MCE. Các khả năng được hỗ trợ có thể là
được truy xuất bằng KVM_X86_GET_MCE_CAP_SUPPORTED.

4.106 KVM_X86_SET_MCE
---------------------

:Khả năng: KVM_CAP_MCE
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_x86_mce (trong)
:Trả về: 0 nếu thành công,
         -EFAULT nếu không thể đọc được struct kvm_x86_mce,
         -EINVAL nếu số ngân hàng không hợp lệ,
         -EINVAL nếu bit VAL không được đặt trong trường trạng thái.

Đưa lỗi kiểm tra máy (MCE) vào khách. đầu vào
tham số là::

cấu trúc kvm_x86_mce {
	trạng thái __u64;
	__u64 địa chỉ;
	__u64 linh tinh;
	__u64 mcg_status;
	__ngân hàng u8;
	__u8 pad1[7];
	__u64 pad2[3];
  };

Nếu MCE được báo cáo là lỗi chưa được sửa, KVM sẽ
đưa nó dưới dạng ngoại lệ MCE vào khách. Nếu khách
Đăng ký MCG_STATUS báo cáo rằng MCE đang được tiến hành, KVM
gây ra vmexit KVM_EXIT_SHUTDOWN.

Ngược lại, nếu MCE là lỗi đã được sửa, KVM sẽ chỉ
lưu trữ nó trong ngân hàng tương ứng (với điều kiện ngân hàng này là
không giữ lỗi chưa được sửa đã được báo cáo trước đó).

4.107 KVM_S390_GET_CMMA_BITS
----------------------------

:Khả năng: KVM_CAP_S390_CMMA_MIGRATION
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_cmma_log (vào, ra)
:Trả về: 0 nếu thành công, giá trị âm nếu có lỗi

Lỗi:

====== ===================================================================
  ENOMEM không thể phân bổ đủ bộ nhớ để hoàn thành nhiệm vụ
  ENXIO nếu CMMA không được kích hoạt
  EINVAL nếu KVM_S390_CMMA_PEEK không được đặt nhưng chế độ di chuyển không được bật
  EINVAL nếu KVM_S390_CMMA_PEEK chưa được thiết lập nhưng tính năng theo dõi bẩn đã được thực hiện
             bị vô hiệu hóa (và do đó chế độ di chuyển đã tự động bị tắt)
  EFAULT nếu địa chỉ không gian người dùng không hợp lệ hoặc nếu không có bảng trang
             hiện diện cho các địa chỉ (ví dụ: khi sử dụng các trang lớn).
  ====== ===================================================================

Ioctl này được sử dụng để lấy giá trị của các bit CMMA trên s390
kiến trúc. Nó được dùng để sử dụng trong hai trường hợp:

- Trong quá trình di chuyển trực tiếp để lưu các giá trị CMMA. Nhu cầu di cư trực tiếp
  được kích hoạt thông qua thuộc tính KVM_REQ_START_MIGRATION VM.
- Để xem qua các giá trị CMMA một cách không phá hủy, bằng cờ
  Bộ KVM_S390_CMMA_PEEK.

Ioctl lấy tham số thông qua cấu trúc kvm_s390_cmma_log. mong muốn
các giá trị được ghi vào bộ đệm có vị trí được chỉ định thông qua "giá trị"
thành viên trong cấu trúc kvm_s390_cmma_log.  Các giá trị trong cấu trúc đầu vào là
cũng được cập nhật khi cần thiết.

Mỗi giá trị CMMA chiếm một byte.

::

cấu trúc kvm_s390_cmma_log {
	__u64 start_gfn;
	__u32 đếm;
	__u32 cờ;
	công đoàn {
		__u64 còn lại;
		__u64 mặt nạ;
	};
	giá trị __u64;
  };

start_gfn là số khung khách đầu tiên có giá trị CMMA là
cần được lấy lại,

count là độ dài của bộ đệm tính bằng byte,

các giá trị trỏ đến bộ đệm nơi kết quả sẽ được ghi vào.

Nếu số lượng lớn hơn KVM_S390_SKEYS_MAX thì được coi là
KVM_S390_SKEYS_MAX. KVM_S390_SKEYS_MAX được tái sử dụng để đảm bảo tính nhất quán với
ioctl khác.

Kết quả được ghi vào bộ đệm được trỏ bởi các giá trị trường và
các giá trị của tham số đầu vào được cập nhật như sau.

Tùy thuộc vào cờ, các hành động khác nhau được thực hiện. duy nhất
cờ được hỗ trợ cho đến nay là KVM_S390_CMMA_PEEK.

Hành vi mặc định nếu KVM_S390_CMMA_PEEK không được đặt là:
start_gfn sẽ chỉ ra khung trang đầu tiên có bit CMMA bị bẩn.
Nó không nhất thiết phải giống với cái được truyền làm đầu vào, vì các trang sạch
được bỏ qua.

count sẽ cho biết số byte thực sự được ghi trong bộ đệm.
Nó có thể (và rất thường xuyên) nhỏ hơn giá trị đầu vào, vì
bộ đệm chỉ được lấp đầy cho đến khi tìm thấy 16 byte giá trị sạch (mà
sau đó không được sao chép vào bộ đệm). Vì khối di chuyển CMMA cần
địa chỉ cơ sở và độ dài, tổng cộng là 16 byte, chúng tôi sẽ gửi
sao lưu lại một số dữ liệu sạch nếu có một số dữ liệu bẩn sau đó, miễn là
kích thước của dữ liệu sạch không vượt quá kích thước của tiêu đề. Cái này
cho phép giảm thiểu lượng dữ liệu được lưu hoặc chuyển qua
mạng với chi phí là nhiều lượt khứ hồi hơn tới không gian người dùng. Tiếp theo
việc gọi ioctl sẽ bỏ qua tất cả các giá trị sạch, tiết kiệm
có khả năng nhiều hơn chỉ 16 byte mà chúng tôi tìm thấy.

Nếu KVM_S390_CMMA_PEEK được đặt:
các thuộc tính lưu trữ hiện có được đọc ngay cả khi không di chuyển
chế độ và không có hành động nào khác được thực hiện;

start_gfn đầu ra sẽ bằng start_gfn đầu vào,

số lượng đầu ra sẽ bằng số lượng đầu vào, trừ khi kết thúc
đã đạt tới bộ nhớ.

Trong cả hai trường hợp:
trường "còn lại" sẽ cho biết tổng số giá trị CMMA bẩn
vẫn còn lại hoặc 0 nếu KVM_S390_CMMA_PEEK được đặt và chế độ di chuyển là
không được kích hoạt.

mặt nạ chưa được sử dụng.

các giá trị trỏ đến bộ đệm không gian người dùng nơi kết quả sẽ được lưu trữ.

4.108 KVM_S390_SET_CMMA_BITS
----------------------------

:Khả năng: KVM_CAP_S390_CMMA_MIGRATION
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_cmma_log (in)
:Trả về: 0 nếu thành công, giá trị âm nếu có lỗi

Ioctl này được sử dụng để đặt giá trị của các bit CMMA trên s390
kiến trúc. Nó được sử dụng trong quá trình di chuyển trực tiếp để khôi phục
các giá trị CMMA, nhưng không có hạn chế nào trong việc sử dụng nó.
Ioctl lấy tham số thông qua cấu trúc kvm_s390_cmma_values.
Mỗi giá trị CMMA chiếm một byte.

::

cấu trúc kvm_s390_cmma_log {
	__u64 start_gfn;
	__u32 đếm;
	__u32 cờ;
	công đoàn {
		__u64 còn lại;
		__u64 mặt nạ;
 	};
	giá trị __u64;
  };

start_gfn cho biết số khung hình khách bắt đầu,

số đếm cho biết có bao nhiêu giá trị được xem xét trong bộ đệm,

cờ không được sử dụng và phải bằng 0.

mặt nạ cho biết bit PGSTE nào sẽ được xem xét.

còn lại không được sử dụng.

các giá trị trỏ đến bộ đệm trong không gian người dùng nơi lưu trữ các giá trị.

Ioctl này có thể bị lỗi với -ENOMEM nếu không thể phân bổ đủ bộ nhớ cho
hoàn thành nhiệm vụ, với -ENXIO nếu CMMA không được bật, với -EINVAL nếu
trường đếm quá lớn (ví dụ: lớn hơn KVM_S390_CMMA_SIZE_MAX) hoặc
nếu trường cờ không phải là 0, với -EFAULT nếu địa chỉ vùng người dùng là
không hợp lệ, nếu các trang không hợp lệ được ghi vào (ví dụ: sau khi hết bộ nhớ)
hoặc nếu không có bảng trang cho các địa chỉ (ví dụ: khi sử dụng
trang lớn).

4.109 KVM_PPC_GET_CPU_CHAR
--------------------------

:Khả năng: KVM_CAP_PPC_GET_CPU_CHAR
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: struct kvm_ppc_cpu_char (out)
:Trả về: 0 khi hoàn thành thành công,
	 -EFAULT nếu không thể ghi struct kvm_ppc_cpu_char

Ioctl này cung cấp thông tin không gian người dùng về các đặc điểm nhất định
của CPU liên quan đến việc thực hiện các hướng dẫn mang tính suy đoán và
rò rỉ thông tin có thể xảy ra do thực hiện suy đoán (xem
CVE-2017-5715, CVE-2017-5753 và CVE-2017-5754).  Thông tin là
được trả về trong struct kvm_ppc_cpu_char, trông như thế này::

cấu trúc kvm_ppc_cpu_char {
	__u64 ký tự;		/* đặc điểm của CPU */
	__u64 hành vi;		/* hành vi phần mềm được đề xuất */
	__u64 ký tự_mask;		/*các bit hợp lệ trong ký tự */
	__u64 hành vi_mask;		/* các bit hợp lệ trong hành vi */
  };

Để mở rộng, các trường character_mask và Behavior_mask
cho biết những bit nào của ký tự và hành vi đã được điền vào bởi
hạt nhân.  Nếu tập hợp các bit xác định được mở rộng trong tương lai thì
không gian người dùng sẽ có thể biết liệu nó có đang chạy trên kernel hay không
biết về các bit mới.

Trường ký tự mô tả các thuộc tính của CPU có thể giúp
với việc ngăn chặn việc tiết lộ thông tin ngoài ý muốn - cụ thể là,
liệu có hướng dẫn flash vô hiệu hóa bộ đệm dữ liệu L1 hay không
(ori 30,30,0 hoặc mtspr SPRN_TRIG2,rN), cho dù bộ đệm dữ liệu L1 có được đặt hay không
sang chế độ mà các mục chỉ có thể được sử dụng bởi luồng đã tạo
chúng, liệu lệnh bcctr[l] có ngăn chặn việc suy đoán hay không và
liệu hướng dẫn về rào cản đầu cơ (hoặc 31,31,0) có được cung cấp hay không.

Trường hành vi mô tả các hành động mà phần mềm sẽ thực hiện để
ngăn chặn việc tiết lộ thông tin vô tình và do đó mô tả những gì
lỗ hổng mà phần cứng có thể mắc phải; cụ thể là liệu
Bộ đệm dữ liệu L1 phải được xóa khi quay lại chế độ người dùng từ
kernel và liệu có nên đặt một rào cản đầu cơ giữa một
kiểm tra giới hạn mảng và truy cập mảng.

Các trường này sử dụng cùng định nghĩa bit như trường mới
Siêu cuộc gọi H_GET_CPU_CHARACTERISTICS.

4.110 KVM_MEMORY_ENCRYPT_OP
---------------------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Loại: vm ioctl, vcpu ioctl
:Thông số: cấu trúc cụ thể của nền tảng mờ đục (vào/ra)
:Trả về: 0 nếu thành công; -1 do lỗi

Nếu nền tảng hỗ trợ tạo VM được mã hóa thì có thể sử dụng ioctl này
để ban hành các lệnh mã hóa bộ nhớ dành riêng cho nền tảng để quản lý các lệnh đó
VM được mã hóa.

Hiện tại, ioctl này được sử dụng để phát hành cả Ảo hóa được mã hóa an toàn
Các lệnh (SEV) trên các lệnh Bộ xử lý AMD và Phần mở rộng miền đáng tin cậy (TDX)
trên bộ xử lý Intel.  Các lệnh chi tiết được xác định trong
Tài liệu/virt/kvm/x86/amd-memory-encryption.rst và
Tài liệu/virt/kvm/x86/intel-tdx.rst.

4.111 KVM_MEMORY_ENCRYPT_REG_REGION
-----------------------------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Loại: hệ thống
:Thông số: struct kvm_enc_zone (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

Ioctl này có thể được sử dụng để đăng ký vùng bộ nhớ khách có thể
chứa dữ liệu được mã hóa (ví dụ: khách RAM, SMRAM, v.v.).

Nó được sử dụng trong máy khách hỗ trợ SEV. Khi mã hóa được bật, khách
vùng bộ nhớ có thể chứa dữ liệu được mã hóa. Mã hóa bộ nhớ SEV
công cụ sử dụng một tinh chỉnh sao cho hai trang văn bản gốc giống hệt nhau, mỗi trang có
các vị trí khác nhau sẽ có bản mã khác nhau. Vì vậy trao đổi hoặc
việc di chuyển bản mã của các trang đó sẽ không làm cho bản rõ bị
hoán đổi. Vì vậy, việc di dời (hoặc di chuyển) các trang hỗ trợ vật lý cho SEV
khách sẽ yêu cầu một số bước bổ sung.

Lưu ý: Thông số quản lý khóa SEV hiện tại không cung cấp lệnh để
trao đổi hoặc di chuyển (di chuyển) các trang bản mã. Do đó, bây giờ chúng tôi ghim khách
vùng bộ nhớ đã đăng ký với ioctl.

4.112 KVM_MEMORY_ENCRYPT_UNREG_REGION
-------------------------------------

:Khả năng: cơ bản
:Kiến trúc: x86
:Loại: hệ thống
:Thông số: struct kvm_enc_zone (trong)
:Trả về: 0 nếu thành công; -1 do lỗi

Ioctl này có thể được sử dụng để hủy đăng ký vùng bộ nhớ khách đã đăng ký
với KVM_MEMORY_ENCRYPT_REG_REGION ioctl ở trên.

4.113 KVM_HYPERV_EVENTFD
------------------------

:Khả năng: KVM_CAP_HYPERV_EVENTFD
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_hyperv_eventfd (trong)

ioctl (un) này đăng ký một sự kiệnfd để nhận thông báo từ khách trên
id kết nối Hyper-V được chỉ định thông qua hypercall SIGNAL_EVENT, không có
khiến người dùng thoát ra.  Siêu cuộc gọi SIGNAL_EVENT có số cờ sự kiện khác 0
(bit 24-31) vẫn kích hoạt lệnh thoát của người dùng KVM_EXIT_HYPERV_HCALL.

::

cấu trúc kvm_hyperv_eventfd {
	__u32 conn_id;
	__s32 fd;
	__u32 cờ;
	__u32 đệm [3];
  };

Trường conn_id phải vừa trong 24 bit::

#define KVM_HYPERV_CONN_ID_MASK 0x00ffffff

Các giá trị được chấp nhận cho trường cờ là::

#define KVM_HYPERV_EVENTFD_DEASSIGN (1 << 0)

:Trả về: 0 nếu thành công,
 	  -EINVAL nếu conn_id hoặc cờ nằm ngoài phạm vi cho phép,
	  -ENOENT khi hủy gán nếu conn_id chưa được đăng ký,
	  -EEXIST được gán nếu conn_id đã được đăng ký

4.114 KVM_GET_NESTED_STATE
--------------------------

:Khả năng: KVM_CAP_NESTED_STATE
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_nested_state (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

=======================================================================
  E2BIG tổng kích thước trạng thái vượt quá giá trị 'kích thước' được chỉ định bởi
             người dùng; kích thước yêu cầu sẽ được ghi thành kích thước.
  =======================================================================

::

cấu trúc kvm_nested_state {
	__u16 lá cờ;
	định dạng __u16;
	__u32 kích thước;

công đoàn {
		cấu trúc kvm_vmx_nested_state_hdr vmx;
		cấu trúc kvm_svm_nested_state_hdr svm;

/* Đệm tiêu đề thành 128 byte.  */
		__u8 đệm[120];
	} hdr;

công đoàn {
		cấu trúc kvm_vmx_nested_state_data vmx[0];
		cấu trúc kvm_svm_nested_state_data svm[0];
	} dữ liệu;
  };

#define KVM_STATE_NESTED_GUEST_MODE 0x00000001
  #define KVM_STATE_NESTED_RUN_PENDING 0x00000002
  #define KVM_STATE_NESTED_EVMCS 0x00000004

#define KVM_STATE_NESTED_FORMAT_VMX 0
  #define KVM_STATE_NESTED_FORMAT_SVM 1

#define KVM_STATE_NESTED_VMX_VMCS_SIZE 0x1000

#define KVM_STATE_NESTED_VMX_SMM_GUEST_MODE 0x00000001
  #define KVM_STATE_NESTED_VMX_SMM_VMXON 0x00000002

#define KVM_STATE_VMX_PREEMPTION_TIMER_DEADLINE 0x00000001

cấu trúc kvm_vmx_nested_state_hdr {
	__u64 vmxon_pa;
	__u64 vmcs12_pa;

cấu trúc {
		__u16 lá cờ;
	} ừm;

__u32 cờ;
	__u64 ưu tiên_timer_deadline;
  };

cấu trúc kvm_vmx_nested_state_data {
	__u8 vmcs12[KVM_STATE_NESTED_VMX_VMCS_SIZE];
	__u8 Shadow_vmcs12[KVM_STATE_NESTED_VMX_VMCS_SIZE];
  };

Ioctl này sao chép trạng thái ảo hóa lồng nhau của vcpu từ kernel sang
không gian người dùng.

Kích thước tối đa của trạng thái có thể được truy xuất bằng cách chuyển KVM_CAP_NESTED_STATE
tới KVM_CHECK_EXTENSION ioctl().

4.115 KVM_SET_NESTED_STATE
--------------------------

:Khả năng: KVM_CAP_NESTED_STATE
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_nested_state (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Điều này sao chép cấu trúc kvm_nested_state của vcpu từ không gian người dùng vào kernel.
Để biết định nghĩa về struct kvm_nested_state, hãy xem KVM_GET_NESTED_STATE.

4.116 KVM_(UN)REGISTER_COALESCED_MMIO
-------------------------------------

:Khả năng: KVM_CAP_COALESCED_MMIO (dành cho mmio kết hợp)
	     KVM_CAP_COALESCED_PIO (dành cho pio kết hợp)
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_coalesced_mmio_zone
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

I/O kết hợp là một phương pháp tối ưu hóa hiệu suất giúp trì hoãn hoạt động của phần cứng
đăng ký mô phỏng ghi để tránh thoát khỏi không gian người dùng.  Đó là
thường được sử dụng để giảm chi phí mô phỏng thường xuyên truy cập
các thanh ghi phần cứng.

Khi một thanh ghi phần cứng được cấu hình cho I/O kết hợp, các truy cập ghi
không thoát ra không gian người dùng và giá trị của chúng được ghi vào bộ đệm vòng
được chia sẻ giữa kernel và không gian người dùng.

I/O hợp nhất được sử dụng nếu một hoặc nhiều quyền truy cập ghi vào phần cứng
đăng ký có thể được hoãn lại cho đến khi đọc hoặc ghi vào phần cứng khác
đăng ký trên cùng một thiết bị.  Lần truy cập cuối cùng này sẽ gây ra vmexit và
không gian người dùng sẽ xử lý các truy cập từ bộ đệm vòng trước khi mô phỏng
nó. Điều đó sẽ tránh thoát khỏi không gian người dùng khi ghi nhiều lần.

Pio hợp nhất dựa trên mmio hợp nhất. Có rất ít sự khác biệt
giữa mmio hợp nhất và pio ngoại trừ việc các bản ghi pio hợp nhất truy cập
tới các cổng I/O.

4.117 KVM_CLEAR_DIRTY_LOG
-------------------------

:Khả năng: KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2
: Kiến trúc: x86, arm64, mips
:Type: vm ioctl
:Thông số: struct kvm_clear_dirty_log (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

/* cho KVM_CLEAR_DIRTY_LOG */
  cấu trúc kvm_clear_dirty_log {
	__u32 khe cắm;
	__u32 số_trang;
	__u64 trang đầu tiên;
	công đoàn {
		void __user ZZ0000ZZ một bit trên mỗi trang */
		__u64 đệm;
	};
  };

Ioctl xóa trạng thái bẩn của các trang trong khe bộ nhớ, theo
bitmap được truyền trong dirty_bitmap của struct kvm_clear_dirty_log
lĩnh vực.  Bit 0 của bitmap tương ứng với trang "first_page" trong
khe cắm bộ nhớ và num_pages là kích thước tính bằng bit của bitmap đầu vào.
first_page phải là bội số của 64; num_pages cũng phải là bội số của
64 trừ khi first_page + num_pages là kích thước của khe bộ nhớ.  Đối với mỗi
bit được đặt trong bitmap đầu vào, trang tương ứng được đánh dấu là "sạch"
trong bitmap bẩn của KVM và tính năng theo dõi bẩn được bật lại cho trang đó
(ví dụ thông qua tính năng chống ghi hoặc bằng cách xóa bit bẩn trong
một mục trong bảng trang).

Nếu KVM_CAP_MULTI_ADDRESS_SPACE khả dụng, các bit 16-31 của trường vị trí chỉ định
không gian địa chỉ mà bạn muốn xóa trạng thái bẩn.  Xem
KVM_SET_USER_MEMORY_REGION để biết chi tiết về cách sử dụng trường vị trí.

Ioctl này chủ yếu hữu ích khi KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2
được kích hoạt; để biết thêm thông tin, hãy xem mô tả về khả năng.
Tuy nhiên, nó luôn có thể được sử dụng miễn là KVM_CHECK_EXTENSION xác nhận
KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2 có mặt.

4.118 KVM_GET_SUPPORTED_HV_CPUID
--------------------------------

:Khả năng: KVM_CAP_HYPERV_CPUID (vcpu), KVM_CAP_SYS_HYPERV_CPUID (hệ thống)
:Kiến trúc: x86
:Loại: hệ thống ioctl, vcpu ioctl
:Thông số: struct kvm_cpuid2 (vào/ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

::

cấu trúc kvm_cpuid2 {
	__u32 không;
	__u32 đệm;
	struct kvm_cpuid_entry2 mục [0];
  };

cấu trúc kvm_cpuid_entry2 {
	__u32 chức năng;
	chỉ số __u32;
	__u32 cờ;
	__u32 eax;
	__u32 ebx;
	__u32 ecx;
	__u32 edx;
	__u32 đệm [3];
  };

Ioctl này trả về các tính năng cpuid x86 liên quan đến mô phỏng Hyper-V trong
KVM.  Không gian người dùng có thể sử dụng thông tin được trả về bởi ioctl này để xây dựng
thông tin cpuid được trình bày cho khách sử dụng các giải pháp Hyper-V (ví dụ:
Máy khách Windows hoặc Hyper-V).

Các lá tính năng CPUID được trả về bởi ioctl này được xác định bởi Hyper-V Top Level
Đặc điểm kỹ thuật chức năng (TLFS). Những chiếc lá này không thể có được bằng
KVM_GET_SUPPORTED_CPUID ioctl vì một số trong số chúng giao nhau với tính năng KVM
lá (0x40000000, 0x40000001).

Hiện tại, danh sách các lá CPUID sau đây được trả về:

-HYPERV_CPUID_VENDOR_AND_MAX_FUNCTIONS
 -HYPERV_CPUID_INTERFACE
 -HYPERV_CPUID_VERSION
 -HYPERV_CPUID_FEATURES
 -HYPERV_CPUID_ENLIGHTMENT_INFO
 -HYPERV_CPUID_IMPLEMENT_LIMITS
 -HYPERV_CPUID_NESTED_FEATURES
 -HYPERV_CPUID_SYNDBG_VENDOR_AND_MAX_FUNCTIONS
 -HYPERV_CPUID_SYNDBG_INTERFACE
 -HYPERV_CPUID_SYNDBG_PLATFORM_CAPABILITIES

Không gian người dùng gọi KVM_GET_SUPPORTED_HV_CPUID bằng cách chuyển cấu trúc kvm_cpuid2
với trường 'nent' cho biết số lượng mục nhập có kích thước thay đổi
mảng 'mục'.  Nếu số lượng mục nhập quá ít để mô tả tất cả Hyper-V
tính năng rời đi, lỗi (E2BIG) sẽ được trả về. Nếu số lượng nhiều hơn hoặc bằng
theo số lượng lá tính năng Hyper-V, trường 'nent' được điều chỉnh thành
số mục nhập hợp lệ trong mảng 'mục nhập', sau đó được điền vào.

Các trường 'chỉ mục' và 'cờ' trong 'struct kvm_cpuid_entry2' hiện được bảo lưu,
không gian người dùng không nên mong đợi nhận được bất kỳ giá trị cụ thể nào ở đó.

Lưu ý, phiên bản vcpu của KVM_GET_SUPPORTED_HV_CPUID hiện không được dùng nữa. Không giống
hệ thống ioctl hiển thị tất cả các bit tính năng được hỗ trợ một cách vô điều kiện, vcpu
phiên bản có những đặc điểm sau:

- Lá HYPERV_CPUID_NESTED_FEATURES và HV_X64_ENLIGHTENED_VMCS_RECOMMENDED
  bit tính năng chỉ được hiển thị khi Enlightened VMCS đã được bật trước đó
  trên vCPU tương ứng (KVM_CAP_HYPERV_ENLIGHTENED_VMCS).
- Bit HV_STIMER_DIRECT_MODE_AVAILABLE chỉ được hiển thị với LAPIC trong kernel.
  (giả sử KVM_CREATE_IRQCHIP đã được gọi).

4.119 KVM_ARM_VCPU_FINALIZE
---------------------------

:Kiến trúc: arm64
:Type: vcpu ioctl
:Thông số: tính năng int (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

====== ===================================================================
  Tính năng EPERM chưa được bật, cần cấu hình hoặc đã hoàn tất
  Tính năng EINVAL không xác định hoặc không có
  ====== ===================================================================

Giá trị được công nhận cho tính năng:

===== ===============================================
  arm64 KVM_ARM_VCPU_SVE (yêu cầu KVM_CAP_ARM_SVE)
  ===== ===============================================

Hoàn tất cấu hình của tính năng vcpu được chỉ định.

Vcpu phải đã được khởi tạo để kích hoạt tính năng bị ảnh hưởng, bằng cách
nghĩa là cuộc gọi ZZ0000ZZ thành công với
cờ thích hợp được đặt trong các tính năng [].

Đối với các tính năng vcpu bị ảnh hưởng, đây là bước bắt buộc phải được thực hiện
trước khi vcpu hoàn toàn có thể sử dụng được.

Giữa KVM_ARM_VCPU_INIT và KVM_ARM_VCPU_FINALIZE, tính năng này có thể
được định cấu hình bằng cách sử dụng ioctls như KVM_SET_ONE_REG.  Cấu hình chính xác
việc đó cần được thực hiện và cách thực hiện phụ thuộc vào tính năng.

Các cuộc gọi khác phụ thuộc vào một tính năng cụ thể đang được hoàn thiện, chẳng hạn như
KVM_RUN, KVM_GET_REG_LIST, KVM_GET_ONE_REG và KVM_SET_ONE_REG, sẽ thất bại với
-EPERM trừ khi tính năng này đã được hoàn thiện bằng phương pháp
Cuộc gọi KVM_ARM_VCPU_FINALIZE.

Xem KVM_ARM_VCPU_INIT để biết chi tiết về các tính năng vcpu yêu cầu hoàn thiện
sử dụng ioctl này.

4.120 KVM_SET_PMU_EVENT_FILTER
------------------------------

:Khả năng: KVM_CAP_PMU_EVENT_FILTER
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_pmu_event_filter (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Lỗi:

=======================================================================
  Không thể truy cập EFAULT args[0]
  EINVAL args[0] chứa dữ liệu không hợp lệ trong bộ lọc hoặc sự kiện bộ lọc
  E2BIG không có kích thước quá lớn
  EBUSY không đủ bộ nhớ để phân bổ bộ lọc
  =======================================================================

::

cấu trúc kvm_pmu_event_filter {
	__u32 hành động;
	__u32 không có gì mới;
	__u32 cố định_counter_bitmap;
	__u32 cờ;
	__u32 đệm[4];
	__u64 sự kiện[0];
  };

Ioctl này hạn chế tập hợp các sự kiện PMU mà khách có thể lập trình bằng cách giới hạn
sự kết hợp chọn sự kiện và mặt nạ đơn vị nào được phép.

Đối số chứa danh sách các sự kiện lọc sẽ được phép hoặc bị từ chối.

Các sự kiện lọc chỉ kiểm soát các bộ đếm có mục đích chung; quầy mục đích cố định
được điều khiển bởi fix_counter_bitmap.

Giá trị hợp lệ cho 'cờ'::

ZZ0000ZZ

Để sử dụng chế độ này, hãy xóa trường 'cờ'.

Trong chế độ này, mỗi sự kiện sẽ chứa một mặt nạ đơn vị + chọn sự kiện.

Khi khách cố gắng lập trình PMU, sự kiện của khách sẽ chọn +
mặt nạ đơn vị được so sánh với các sự kiện lọc để xác định xem
khách nên có quyền truy cập.

ZZ0000ZZ
:Khả năng: KVM_CAP_PMU_EVENT_MASKED_EVENTS

Trong chế độ này, mỗi sự kiện lọc sẽ chứa một sự kiện chọn, mặt nạ, so khớp và
loại trừ giá trị  Để mã hóa sự kiện bị che, hãy sử dụng::

KVM_PMU_ENCODE_MASKED_ENTRY()

Một sự kiện được mã hóa sẽ tuân theo bố cục sau::

Mô tả bit
  ---- ----------
  Chọn sự kiện 7:0 (bit thấp)
  Trận đấu ô 15:8
  31:16 chưa sử dụng
  35:32 chọn sự kiện (bit cao)
  36:54 chưa sử dụng
  55 loại trừ bit
  63:56 mặt nạ ô

Khi khách cố gắng lập trình PMU, các bước này được thực hiện theo
xác định xem khách có nên có quyền truy cập hay không:

1. So khớp sự kiện được chọn từ khách với các sự kiện lọc.
 2. Nếu tìm thấy sự trùng khớp, hãy ghép mặt nạ của đơn vị khách với mặt nạ và khớp
    giá trị của các sự kiện lọc được bao gồm.
    tức là (mặt nạ đơn vị & mặt nạ) == khớp && !loại trừ.
 3. Nếu tìm thấy sự trùng khớp, hãy ghép mặt nạ của đơn vị khách với mặt nạ và khớp
    giá trị của các sự kiện bộ lọc bị loại trừ.
    tức là (mặt nạ đơn vị & mặt nạ) == khớp && loại trừ.
 4.
   một. Nếu tìm thấy kết quả phù hợp được bao gồm và không tìm thấy kết quả phù hợp bị loại trừ, hãy lọc
      sự kiện.
   b. Đối với mọi thứ khác, không lọc sự kiện.
 5.
   một. Nếu sự kiện được lọc và đó là danh sách cho phép, hãy cho phép khách
      lập trình sự kiện.
   b. Nếu sự kiện được lọc và đó là danh sách từ chối, đừng cho phép khách
      lập trình sự kiện.

Khi cài đặt bộ lọc sự kiện pmu mới, -EINVAL sẽ được trả về nếu bất kỳ
các trường không sử dụng được đặt hoặc nếu bất kỳ bit cao nào (35:32) trong trường hợp
select được đặt khi được gọi trên Intel.

Giá trị hợp lệ cho 'hành động'::

#define KVM_PMU_EVENT_ALLOW 0
  #define KVM_PMU_EVENT_DENY 1

Thông qua API này, không gian người dùng KVM cũng có thể kiểm soát hành vi của các máy ảo đã được sửa lỗi
bộ đếm (nếu có) bằng cách định cấu hình các trường "hành động" và "fixed_counter_bitmap".

Cụ thể, KVM tuân theo mã giả sau khi xác định xem có nên
cho phép khách FixCtr[i] đếm sự kiện cố định được xác định trước ::

FixCtr[i]_is_allowed = (hành động == ALLOW) && (bitmap & BIT(i)) ||
    (hành động == DENY) && !(bitmap & BIT(i));
  FixCtr[i]_is_denied = !FixCtr[i]_is_allowed;

KVM luôn sử dụng fix_counter_bitmap, trách nhiệm của không gian người dùng là
đảm bảo cố định_counter_bitmap được đặt chính xác, ví dụ: nếu không gian người dùng muốn xác định
một bộ lọc chỉ ảnh hưởng đến các bộ đếm có mục đích chung.

Lưu ý, trường "sự kiện" cũng áp dụng cho sự kiện được mã hóa cứng của bộ đếm cố định
và các giá trị unit_mask.  "fixed_counter_bitmap" có mức độ ưu tiên cao hơn "sự kiện"
nếu có sự mâu thuẫn giữa hai điều đó.

4.121 KVM_PPC_SVM_OFF
---------------------

:Khả năng: cơ bản
:Kiến trúc: powerpc
:Type: vm ioctl
:Thông số: không có
:Trả về: 0 khi hoàn thành thành công,

Lỗi:

====== ======================================================================
  EINVAL nếu bộ siêu giám sát không kết thúc được khách an toàn
  ENOMEM nếu trình ảo hóa không phân bổ được các bảng trang cơ số mới cho khách
  ====== ======================================================================

Ioctl này dùng để tắt chế độ bảo mật của khách hoặc chuyển tiếp
khách từ chế độ an toàn sang chế độ bình thường. Điều này được viện dẫn khi khách
được thiết lập lại. Điều này không có tác dụng nếu được gọi cho một vị khách bình thường.

Ioctl này đưa ra lệnh gọi ultravisor để chấm dứt chế độ khách an toàn,
bỏ ghim các trang VPA và giải phóng tất cả các trang thiết bị được sử dụng để
theo dõi các trang bảo mật bằng hypervisor.

4.122 KVM_S390_NORMAL_RESET
---------------------------

:Khả năng: KVM_CAP_S390_VCPU_RESETS
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0

Ioctl này đặt lại các thanh ghi VCPU và cấu trúc điều khiển theo
định nghĩa thiết lập lại cpu trong POP (Nguyên tắc hoạt động).

4.123 KVM_S390_INITIAL_RESET
----------------------------

:Khả năng: cơ bản
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0

Ioctl này đặt lại các thanh ghi VCPU và cấu trúc điều khiển theo
định nghĩa thiết lập lại cpu ban đầu trong POP. Tuy nhiên, CPU không
đưa vào chế độ ESA. Việc thiết lập lại này là một siêu thiết lập của thiết lập lại thông thường.

4.124 KVM_S390_CLEAR_RESET
--------------------------

:Khả năng: KVM_CAP_S390_VCPU_RESETS
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0

Ioctl này đặt lại các thanh ghi VCPU và cấu trúc điều khiển theo
định nghĩa thiết lập lại cpu rõ ràng trong POP. Tuy nhiên, CPU không được đặt
vào chế độ ESA. Thiết lập lại này là siêu bộ của thiết lập lại ban đầu.


4.125 KVM_S390_PV_COMMAND
-------------------------

:Khả năng: KVM_CAP_S390_PROTECTED
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_pv_cmd
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

::

cấu trúc kvm_pv_cmd {
	__u32 cmd;	/* Lệnh cần thực hiện */
	__u16 RC;	/* Mã trả về của Ultravisor */
	__u16 rrc;	/* Mã lý do trả lại của Ultravisor */
	__u64 dữ liệu;	/* Dữ liệu hoặc địa chỉ */
	__u32 cờ;    /* cờ cho các tiện ích mở rộng trong tương lai. Hiện tại phải là 0 */
	__u32 dành riêng[3];
  };

ZZ0002ZZ
Mã trả về Ultravisor (lý do) được hạt nhân cung cấp nếu
Lệnh gọi Ultravisor đã được thực hiện để đạt được kết quả như mong đợi
lệnh. Do đó, chúng độc lập với kết quả trả về IOCTL
mã. Nếu KVM thay đổi ZZ0000ZZ thì giá trị của nó sẽ luôn lớn hơn 0
do đó nên đặt nó thành 0 trước khi đưa ra lệnh PV.
có thể phát hiện sự thay đổi của ZZ0001ZZ.

ZZ0000ZZ

KVM_PV_ENABLE
  Cấp phát bộ nhớ và đăng ký VM với Ultravisor, từ đó
  tặng bộ nhớ cho Ultravisor sẽ không thể truy cập được
  KVM. Tất cả các CPU hiện có đều được chuyển đổi thành CPU được bảo vệ. Sau này
  lệnh đã thành công, mọi CPU được thêm qua hotplug sẽ trở thành
  cũng được bảo vệ trong quá trình tạo ra nó.

Lỗi:

===== ================================
  EINTR một tín hiệu bị lộ đang chờ xử lý
  ===== ================================

KVM_PV_DISABLE
  Hủy đăng ký VM khỏi Ultravisor và lấy lại bộ nhớ đã có
  đã được tặng cho Ultravisor, giúp kernel có thể sử dụng lại nó.
  Tất cả các VCPU đã đăng ký sẽ được chuyển đổi trở lại thành các VCPU không được bảo vệ. Nếu một
  VM được bảo vệ trước đó đã được chuẩn bị cho việc phá bỏ không đồng bộ với
  KVM_PV_ASYNC_CLEANUP_PREPARE và sau đó không bị phá bỏ bằng
  KVM_PV_ASYNC_CLEANUP_PERFORM, nó sẽ bị phá bỏ trong cuộc gọi này
  cùng với VM được bảo vệ hiện tại.

KVM_PV_VM_SET_SEC_PARMS
  Truyền tiêu đề hình ảnh từ bộ nhớ VM tới Ultravisor trong
  chuẩn bị giải nén và xác minh hình ảnh.

KVM_PV_VM_UNPACK
  Giải nén (bảo vệ và giải mã) một trang có hình ảnh khởi động được mã hóa.

KVM_PV_VM_VERIFY
  Xác minh tính toàn vẹn của hình ảnh được giải nén. Chỉ khi việc này thành công,
  KVM được phép khởi động các VCPU được bảo vệ.

KVM_PV_INFO
  :Khả năng: KVM_CAP_S390_PROTECTED_DUMP

Trình bày API cung cấp dữ liệu liên quan đến Ultravisor cho không gian người dùng
  thông qua các lệnh phụ. len_max là kích thước của bộ đệm không gian người dùng,
  len_writing là dấu hiệu của KVM về số lượng byte của bộ đệm đó
  thực sự đã được viết cho. len_writing có thể được sử dụng để xác định
  các trường hợp lệ nếu có nhiều trường phản hồi hơn được thêm vào trong tương lai.

  ::

enum pv_cmd_info_id {
	KVM_PV_INFO_VM,
	KVM_PV_INFO_DUMP,
     };

cấu trúc kvm_s390_pv_info_header {
	__u32 id;
	__u32 len_max;
	__u32 len_write;
	__u32 dành riêng;
     };

cấu trúc kvm_s390_pv_info {
	tiêu đề cấu trúc kvm_s390_pv_info_header;
	kết xuất cấu trúc kvm_s390_pv_info_dump;
	cấu trúc kvm_s390_pv_info_vm vm;
     };

ZZ0000ZZ

KVM_PV_INFO_VM
    Tiểu ban này cung cấp thông tin Ultravisor cơ bản cho PV
    chủ nhà. Các giá trị này có thể cũng được xuất dưới dạng tệp trong sysfs
    giao diện truy vấn UV phần sụn nhưng chúng dễ dàng có sẵn hơn
    các chương trình trong API này.

Các cuộc gọi đã cài đặt và các thành viên feature_indicion cung cấp
    các cuộc gọi UV đã cài đặt và các chỉ dẫn tính năng khác của UV.

Các thành viên max_* cung cấp thông tin về số lượng PV tối đa
    vcpus, khách PV và kích thước bộ nhớ khách PV.

    ::

cấu trúc kvm_s390_pv_info_vm {
	__u64 inst_calls_list[4];
	__u64 max_cpus;
	__u64 max_guests;
	__u64 max_guest_addr;
	__u64 tính năng_indication;
      };


KVM_PV_INFO_DUMP
    Tiểu ban này cung cấp thông tin liên quan đến việc bán phá giá khách PV.

    ::

cấu trúc kvm_s390_pv_info_dump {
	__u64 dump_cpu_buffer_len;
	__u64 dump_config_mem_buffer_per_1m;
	__u64 dump_config_finalize_len;
      };

KVM_PV_DUMP
  :Khả năng: KVM_CAP_S390_PROTECTED_DUMP

Trình bày API cung cấp các cuộc gọi tạo điều kiện thuận lợi cho việc kết thúc cuộc gọi
  VM được bảo vệ.

  ::

cấu trúc kvm_s390_pv_dmp {
      __u64 subcmd;
      __u64 buff_addr;
      __u64 buff_len;
      __u64 gaddr;		/*Đối với trạng thái lưu trữ kết xuất */
    };

ZZ0000ZZ

KVM_PV_DUMP_INIT
    Khởi tạo quá trình kết xuất của một máy ảo được bảo vệ. Nếu cuộc gọi này thực hiện
    không thành công, tất cả các lệnh con khác sẽ thất bại với -EINVAL. Cái này
    lệnh phụ sẽ trả về -EINVAL nếu quá trình kết xuất chưa được thực hiện
    hoàn thành.

Không phải tất cả các vms PV đều có thể được kết xuất, chủ sở hữu cần đặt ZZ0000ZZ PCF bit 34 trong tiêu đề SE để cho phép kết xuất.

KVM_PV_DUMP_CONFIG_STOR_STATE
     Lưu trữ byte ZZ0000ZZ của các giá trị thành phần điều chỉnh bắt đầu bằng
     khối 1 MB được chỉ định bởi địa chỉ khách tuyệt đối
     (ZZ0001ZZ). ZZ0002ZZ cần phải là ZZ0003ZZ
     căn chỉnh và ít nhất >= giá trị ZZ0004ZZ
     được cung cấp bởi dữ liệu uv_info kết xuất. buff_user có thể được ghi vào
     ngay cả khi một lỗi RC được trả về. Ví dụ, nếu chúng ta gặp phải một
     lỗi sau khi ghi trang dữ liệu đầu tiên.

KVM_PV_DUMP_COMPLETE
    Nếu lệnh con thành công, nó sẽ hoàn tất quá trình kết xuất và cho phép
    KVM_PV_DUMP_INIT được gọi lại.

Khi thành công, byte dữ liệu hoàn thành ZZ0000ZZ sẽ được
    được lưu trữ vào ZZ0001ZZ. Dữ liệu hoàn thành chứa một khóa
    hạt giống phái sinh, IV, Tweak nonce và các khóa mã hóa cũng như một
    thẻ xác thực, tất cả đều cần thiết để giải mã kết xuất tại một thời điểm
    thời gian sau.

KVM_PV_ASYNC_CLEANUP_PREPARE
  :Khả năng: KVM_CAP_S390_PROTECTED_ASYNC_DISABLE

Chuẩn bị máy ảo được bảo vệ hiện tại để phá bỏ không đồng bộ. Hầu hết
  tài nguyên được sử dụng bởi VM được bảo vệ hiện tại sẽ được dành cho
  sự cố không đồng bộ tiếp theo. Sau đó, VM được bảo vệ hiện tại sẽ
  tiếp tục thực hiện ngay lập tức khi không được bảo vệ. Có thể có nhiều nhất
  một máy ảo được bảo vệ sẵn sàng cho việc phá bỏ không đồng bộ bất kỳ lúc nào. Nếu
  một máy ảo được bảo vệ đã được chuẩn bị để phá bỏ mà không cần
  sau đó gọi KVM_PV_ASYNC_CLEANUP_PERFORM, cuộc gọi này sẽ
  thất bại. Trong trường hợp đó, quy trình vùng người dùng sẽ đưa ra một thông báo bình thường
  KVM_PV_DISABLE. Các nguồn lực dành riêng cho cuộc gọi này sẽ cần phải
  được dọn dẹp bằng lệnh gọi tiếp theo tới KVM_PV_ASYNC_CLEANUP_PERFORM
  hoặc KVM_PV_DISABLE, nếu không chúng sẽ bị dọn sạch khi KVM
  chấm dứt. KVM_PV_ASYNC_CLEANUP_PREPARE có thể được gọi lại ngay khi có thể
  khi quá trình dọn dẹp bắt đầu, tức là trước khi KVM_PV_ASYNC_CLEANUP_PERFORM kết thúc.

KVM_PV_ASYNC_CLEANUP_PERFORM
  :Khả năng: KVM_CAP_S390_PROTECTED_ASYNC_DISABLE

Xé máy ảo được bảo vệ đã chuẩn bị trước đó để phá bỏ bằng
  KVM_PV_ASYNC_CLEANUP_PREPARE. Các nguồn lực đã được dành riêng
  sẽ được giải phóng trong quá trình thực hiện lệnh này. Lệnh PV này
  lý tưởng nhất là do không gian người dùng phát hành từ một luồng riêng biệt. Nếu một
  nhận được tín hiệu nguy hiểm (hoặc quá trình kết thúc một cách tự nhiên),
  lệnh sẽ chấm dứt ngay lập tức mà không hoàn thành, và lệnh bình thường
  Quy trình tắt máy KVM sẽ đảm nhiệm việc dọn dẹp tất cả các phần còn lại
  các máy ảo được bảo vệ, bao gồm cả những máy ảo bị gián đoạn bởi
  chấm dứt quá trình.

4.126 KVM_XEN_HVM_SET_ATTR
--------------------------

:Khả năng: KVM_CAP_XEN_HVM / KVM_XEN_HVM_CONFIG_SHARED_INFO
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_xen_hvm_attr
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

::

cấu trúc kvm_xen_hvm_attr {
	__u16 loại;
	__u16 đệm[3];
	công đoàn {
		__u8 long_mode;
		__u8 vectơ;
		__u8 runstate_update_flag;
		công đoàn {
			__u64 gfn;
			__u64 hva;
		} chia sẻ_thông tin;
		cấu trúc {
			__u32 send_port;
			__u32 loại; /* EVTCHNSTAT_ipi / EVTCHNSTAT_interdomain */
			__u32 cờ;
			công đoàn {
				cấu trúc {
					__u32 cổng;
					__u32 vcpu;
					__u32 ưu tiên;
				} cổng;
				cấu trúc {
					__u32 cổng; /* Zero cho sự kiệnfd */
					__s32 fd;
				} sự kiệnfd;
				__u32 phần đệm[4];
			} giao;
		} evtchn;
		__u32 xen_version;
		__u64 đệm[8];
	} bạn;
  };

giá trị kiểu:

KVM_XEN_ATTR_TYPE_LONG_MODE
  Đặt chế độ ABI của VM thành 32-bit hoặc 64-bit (chế độ dài). Cái này
  xác định bố cục của trang Shared_info được hiển thị cho VM.

KVM_XEN_ATTR_TYPE_SHARED_INFO
  Đặt số khung vật lý của khách mà Xen đã chia sẻ_info
  trang cư trú. Lưu ý rằng mặc dù Xen đặt vcpu_info ở vị trí đầu tiên
  32 vCPU trong trang Shared_info, KVM không tự động làm như vậy
  và thay vào đó yêu cầu KVM_XEN_VCPU_ATTR_TYPE_VCPU_INFO hoặc
  KVM_XEN_VCPU_ATTR_TYPE_VCPU_INFO_HVA được sử dụng rõ ràng ngay cả khi
  vcpu_info cho một vCPU nhất định nằm ở vị trí "mặc định"
  trong trang Shared_info. Điều này là do KVM có thể không biết về
  id Xen CPU được sử dụng làm chỉ mục trong vcpu_info[]
  mảng, vì vậy có thể biết vị trí mặc định chính xác.

Lưu ý rằng trang Shared_info có thể được KVM ghi liên tục;
  nó chứa bitmap kênh sự kiện được sử dụng để cung cấp các ngắt tới
  một vị khách Xen, trong số những thứ khác. Nó được miễn theo dõi bẩn
  cơ chế - KVM sẽ không đánh dấu rõ ràng trang nào là bẩn
  thời gian ngắt kênh sự kiện được gửi tới khách! Như vậy,
  không gian người dùng phải luôn cho rằng GFN được chỉ định là bẩn nếu
  bất kỳ vCPU nào đang chạy hoặc bất kỳ sự gián đoạn kênh sự kiện nào đều có thể xảy ra
  chuyển tới khách.

Đặt gfn thành KVM_XEN_INVALID_GFN sẽ vô hiệu hóa thông tin chia sẻ
  trang.

KVM_XEN_ATTR_TYPE_SHARED_INFO_HVA
  Nếu cờ KVM_XEN_HVM_CONFIG_SHARED_INFO_HVA cũng được đặt trong
  Xen thì thuộc tính này có thể được sử dụng để thiết lập
  địa chỉ không gian người dùng nơi trang Shared_info cư trú, địa chỉ này
  sẽ luôn được sửa trong VMM bất kể nó được ánh xạ ở đâu
  trong không gian địa chỉ vật lý của khách. Thuộc tính này nên được sử dụng trong
  ưu tiên KVM_XEN_ATTR_TYPE_SHARED_INFO vì nó tránh
  sự mất hiệu lực không cần thiết của bộ đệm trong khi trang được
  ánh xạ lại trong không gian địa chỉ vật lý của khách.

Đặt hva về 0 sẽ vô hiệu hóa trang Shared_info.

KVM_XEN_ATTR_TYPE_UPCALL_VECTOR
  Đặt vectơ ngoại lệ được sử dụng để phân phối các cuộc gọi nâng cấp kênh sự kiện Xen.
  Đây là vectơ toàn HVM được trình ảo hóa trực tiếp đưa vào
  (không thông qua APIC cục bộ), thường được cấu hình bởi khách thông qua
  HVM_PARAM_CALLBACK_IRQ. Điều này có thể bị vô hiệu hóa lại (ví dụ: đối với khách
  SHUTDOWN_soft_reset) bằng cách đặt nó về 0.

KVM_XEN_ATTR_TYPE_EVTCHN
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ các tính năng KVM_XEN_HVM_CONFIG_EVTCHN_SEND. Nó cấu hình
  số cổng gửi đi để chặn các yêu cầu EVTCHNOP_send
  từ khách. Một số cổng gửi nhất định có thể được chuyển hướng trở lại
  một vCPU được chỉ định (theo ID APIC) / cổng / mức độ ưu tiên trên máy khách hoặc tới
  kích hoạt các sự kiện trên một sự kiệnfd. Có thể thay đổi vCPU và mức độ ưu tiên
  bằng cách cài đặt KVM_XEN_EVTCHN_UPDATE trong cuộc gọi tiếp theo, nhưng khác
  các trường không thể thay đổi đối với một cổng gửi nhất định. Bản đồ cổng là
  được xóa bằng cách sử dụng KVM_XEN_EVTCHN_DEASSIGN trong trường cờ. Vượt qua
  KVM_XEN_EVTCHN_RESET trong trường cờ sẽ loại bỏ mọi hoạt động chặn của
  các kênh sự kiện bên ngoài. Các giá trị của trường cờ là lẫn nhau
  độc quyền và không thể kết hợp dưới dạng bitmask.

KVM_XEN_ATTR_TYPE_XEN_VERSION
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ các tính năng KVM_XEN_HVM_CONFIG_EVTCHN_SEND. Nó cấu hình
  mã phiên bản 32-bit được trả về cho khách khi nó gọi
  Cuộc gọi XENVER_version; thông thường (XEN_MAJOR << 16 | XEN_MINOR). PV
  Khách Xen thường sẽ sử dụng điều này như một hypercall giả để kích hoạt
  phân phối kênh sự kiện, do đó phản hồi trong kernel mà không cần
  thoát khỏi không gian người dùng là có lợi.

KVM_XEN_ATTR_TYPE_RUNSTATE_UPDATE_FLAG
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ cho KVM_XEN_HVM_CONFIG_RUNSTATE_UPDATE_FLAG. Nó cho phép
  Cờ XEN_RUNSTATE_UPDATE cho phép vCPU khách đọc an toàn
  vcpu_runstate_info của các vCPU khác. Xen khách kích hoạt tính năng này thông qua
  VMASST_TYPE_runstate_update_flag của HYPERVISOR_vm_assist
  hypercall.

4.127 KVM_XEN_HVM_GET_ATTR
--------------------------

:Khả năng: KVM_CAP_XEN_HVM / KVM_XEN_HVM_CONFIG_SHARED_INFO
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_xen_hvm_attr
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

Cho phép đọc các thuộc tính Xen VM. Về cấu trúc và chủng loại,
xem KVM_XEN_HVM_SET_ATTR ở trên. KVM_XEN_ATTR_TYPE_EVTCHN
thuộc tính không thể đọc được.

4.128 KVM_XEN_VCPU_SET_ATTR
---------------------------

:Khả năng: KVM_CAP_XEN_HVM / KVM_XEN_HVM_CONFIG_SHARED_INFO
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xen_vcpu_attr
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

::

cấu trúc kvm_xen_vcpu_attr {
	__u16 loại;
	__u16 đệm[3];
	công đoàn {
		__u64 gpa;
		__u64 đệm[4];
		cấu trúc {
			__u64 trạng thái;
			__u64 trạng thái_entry_time;
			__u64 time_running;
			__u64 time_runnable;
			__u64 bị chặn thời gian;
			__u64 time_offline;
		} trạng thái chạy;
		__u32 vcpu_id;
		cấu trúc {
			__u32 cổng;
			__u32 ưu tiên;
			__u64 hết hạn_ns;
		} bộ đếm thời gian;
		__u8 vectơ;
	} bạn;
  };

giá trị kiểu:

KVM_XEN_VCPU_ATTR_TYPE_VCPU_INFO
  Đặt địa chỉ vật lý khách của vcpu_info cho một vCPU nhất định.
  Giống như trang Shared_info dành cho VM, trang tương ứng có thể là
  bị bẩn bất cứ lúc nào nếu phân phối ngắt kênh sự kiện được bật, vì vậy
  không gian người dùng phải luôn cho rằng trang bị bẩn mà không cần dựa vào
  về khai thác gỗ bẩn. Đặt gpa thành KVM_XEN_INVALID_GPA sẽ tắt
  vcpu_info.

KVM_XEN_VCPU_ATTR_TYPE_VCPU_INFO_HVA
  Nếu cờ KVM_XEN_HVM_CONFIG_SHARED_INFO_HVA cũng được đặt trong
  Xen thì thuộc tính này có thể được sử dụng để thiết lập
  địa chỉ vùng người dùng của vcpu_info cho một vCPU nhất định. Nó nên
  chỉ được sử dụng khi vcpu_info nằm ở vị trí "mặc định"
  trong trang Shared_info. Trong trường hợp này, có thể an toàn khi giả định rằng
  địa chỉ không gian người dùng sẽ không thay đổi vì trang Shared_info được
  lớp phủ trên bộ nhớ khách và vẫn ở địa chỉ máy chủ cố định
  bất kể nó được ánh xạ ở đâu trong không gian địa chỉ vật lý của khách
  và do đó việc vô hiệu hóa bộ nhớ đệm nội bộ có thể không cần thiết.
  tránh được nếu bố cục bộ nhớ khách được sửa đổi.
  Nếu vcpu_info không nằm ở vị trí "mặc định" thì
  nó không được đảm bảo vẫn ở cùng một địa chỉ máy chủ và
  do đó việc vô hiệu hóa bộ đệm đã nói ở trên là bắt buộc.

KVM_XEN_VCPU_ATTR_TYPE_VCPU_TIME_INFO
  Đặt địa chỉ vật lý của khách của cấu trúc PVClock bổ sung
  cho một vCPU nhất định. Điều này thường được sử dụng để hỗ trợ vsyscall cho khách.
  Đặt gpa thành KVM_XEN_INVALID_GPA sẽ vô hiệu hóa cấu trúc.

KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_ADDR
  Đặt địa chỉ vật lý của khách của vcpu_runstate_info cho một địa chỉ nhất định
  vCPU. Đây là cách khách Xen theo dõi trạng thái CPU chẳng hạn như đánh cắp thời gian.
  Đặt gpa thành KVM_XEN_INVALID_GPA sẽ vô hiệu hóa vùng runstate.

KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_CURRENT
  Đặt trạng thái chạy (RUNSTATE_running/_runnable/_blocked/_offline) của
  vCPU đã cho từ thành viên .u.runstate.state của cấu trúc.
  KVM tự động tính toán thời gian chạy và thời gian chạy nhưng bị chặn
  và trạng thái ngoại tuyến chỉ được nhập một cách rõ ràng.

KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_DATA
  Đặt tất cả các trường của dữ liệu runstate vCPU từ thành viên .u.runstate
  của cấu trúc, bao gồm cả trạng thái chạy hiện tại. Trạng thái_entry_time
  phải bằng tổng của bốn lần còn lại.

KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_ADJUST
  ZZ0000ZZ này là nội dung của các thành viên .u.runstate của cấu trúc
  tới các thành viên tương ứng của dữ liệu trạng thái chạy của vCPU nhất định, do đó
  cho phép điều chỉnh nguyên tử về thời gian chạy. Sự điều chỉnh
  đối với state_entry_time phải bằng tổng số lần điều chỉnh đối với
  bốn lần khác. Trường trạng thái phải được đặt thành -1 hoặc hợp lệ
  giá trị trạng thái chạy (RUNSTATE_running, RUNSTATE_runnable, RUNSTATE_blocked
  hoặc RUNSTATE_offline) để đặt trạng thái tài khoản hiện tại kể từ
  đã điều chỉnh state_entry_time.

KVM_XEN_VCPU_ATTR_TYPE_VCPU_ID
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ các tính năng KVM_XEN_HVM_CONFIG_EVTCHN_SEND. Nó thiết lập Xen
  ID vCPU của vCPU đã cho, để cho phép các hoạt động VCPU liên quan đến bộ đếm thời gian thực hiện
  bị chặn bởi KVM.

KVM_XEN_VCPU_ATTR_TYPE_TIMER
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ các tính năng KVM_XEN_HVM_CONFIG_EVTCHN_SEND. Nó thiết lập
  cổng/mức độ ưu tiên của kênh sự kiện cho VIRQ_TIMER của vCPU
  như cho phép lưu/khôi phục bộ hẹn giờ đang chờ xử lý. Đặt hẹn giờ
  cổng về 0 sẽ vô hiệu hóa việc xử lý kernel của bộ đếm thời gian chụp một lần.

KVM_XEN_VCPU_ATTR_TYPE_UPCALL_VECTOR
  Thuộc tính này khả dụng khi KVM_CAP_XEN_HVM ioctl chỉ ra
  hỗ trợ các tính năng KVM_XEN_HVM_CONFIG_EVTCHN_SEND. Nó thiết lập
  vectơ nâng cấp APIC cục bộ trên mỗi vCPU, được định cấu hình bởi khách Xen với
  siêu lệnh gọi HVMOP_set_evtchn_upcall_vector. Đây thường là
  được sử dụng bởi khách Windows và khác với cuộc gọi nâng cấp toàn HVM
  vector được cấu hình với HVM_PARAM_CALLBACK_IRQ. Nó bị vô hiệu hóa bởi
  đặt vectơ về 0.


4.129 KVM_XEN_VCPU_GET_ATTR
---------------------------

:Khả năng: KVM_CAP_XEN_HVM / KVM_XEN_HVM_CONFIG_SHARED_INFO
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xen_vcpu_attr
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

Cho phép đọc thuộc tính Xen vCPU. Về cấu trúc và chủng loại,
xem KVM_XEN_VCPU_SET_ATTR ở trên.

Loại KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_ADJUST có thể không được sử dụng
với KVM_XEN_VCPU_GET_ATTR ioctl.

4.130 KVM_ARM_MTE_COPY_TAGS
---------------------------

:Khả năng: KVM_CAP_ARM_MTE
:Kiến trúc: arm64
:Type: vm ioctl
:Thông số: struct kvm_arm_copy_mte_tags
:Trả về: số byte được sao chép, < 0 do lỗi (-EINVAL do sai
          đối số, -EFAULT nếu không thể truy cập bộ nhớ).

::

cấu trúc kvm_arm_copy_mte_tags {
	__u64 khách_ipa;
	__u64 chiều dài;
	void __user *addr;
	__u64 cờ;
	__u64 dành riêng[2];
  };

Sao chép các thẻ Tiện ích mở rộng gắn thẻ bộ nhớ (MTE) vào/từ bộ nhớ thẻ khách. các
Các trường ZZ0000ZZ và ZZ0001ZZ phải được căn chỉnh theo ZZ0002ZZ.
ZZ0003ZZ không được lớn hơn 2^31 - PAGE_SIZE byte. ZZ0004ZZ
trường phải trỏ đến bộ đệm mà thẻ sẽ được sao chép đến hoặc từ đó.

ZZ0000ZZ chỉ định hướng sao chép, ZZ0001ZZ hoặc
ZZ0002ZZ.

Kích thước của bộ đệm để lưu trữ thẻ là byte ZZ0000ZZ
(các hạt trong MTE dài 16 byte). Mỗi byte chứa một thẻ duy nhất
giá trị. Điều này phù hợp với định dạng của ZZ0001ZZ và
ZZ0002ZZ.

Nếu xảy ra lỗi trước khi sao chép bất kỳ dữ liệu nào thì mã lỗi âm sẽ được
đã quay trở lại. Nếu một số thẻ đã được sao chép trước khi xảy ra lỗi thì số
số byte được sao chép thành công sẽ được trả về. Nếu cuộc gọi hoàn tất thành công
sau đó ZZ0000ZZ được trả về.

4.131 KVM_GET_SREGS2
--------------------

:Khả năng: KVM_CAP_SREGS2
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_sregs2 (ra)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Đọc các thanh ghi đặc biệt từ vcpu.
Ioctl này (khi được hỗ trợ) sẽ thay thế KVM_GET_SREGS.

::

cấu trúc kvm_sregs2 {
                /* ra (KVM_GET_SREGS2) / vào (KVM_SET_SREGS2) */
                cấu trúc kvm_segment cs, ds, es, fs, gs, ss;
                struct kvm_segment tr, ldt;
                struct kvm_dtable gdt, idt;
                __u64 cr0, cr2, cr3, cr4, cr8;
                __u64 efer;
                __u64 apic_base;
                __u64 cờ;
                __u64 pdptrs[4];
        };

giá trị cờ cho ZZ0000ZZ:

ZZ0000ZZ

Cho biết cấu trúc chứa các giá trị PDPTR hợp lệ.


4.132 KVM_SET_SREGS2
--------------------

:Khả năng: KVM_CAP_SREGS2
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_sregs2 (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Ghi các thanh ghi đặc biệt vào vcpu.
Xem KVM_GET_SREGS2 để biết cấu trúc dữ liệu.
Ioctl này (khi được hỗ trợ) sẽ thay thế KVM_SET_SREGS.

4.133 KVM_GET_STATS_FD
----------------------

:Khả năng: KVM_CAP_STATS_BINARY_FD
:Kiến trúc: tất cả
:Loại: vm ioctl, vcpu ioctl
:Thông số: không có
:Trả về: mô tả tệp thống kê khi thành công, < 0 nếu có lỗi

Lỗi:

====== ===========================================================
  ENOMEM nếu không thể tạo fd do thiếu bộ nhớ
  EMFILE nếu số lượng tệp được mở vượt quá giới hạn
  ====== ===========================================================

Bộ mô tả tệp được trả về có thể được sử dụng để đọc dữ liệu thống kê VM/vCPU trong
định dạng nhị phân. Dữ liệu trong bộ mô tả tệp bao gồm bốn khối
được tổ chức như sau:

+-------------+
ZZ0000ZZ
+-------------+
ZZ0001ZZ
+-------------+
ZZ0002ZZ
+-------------+
ZZ0003ZZ
+-------------+

Ngoài tiêu đề bắt đầu ở offset 0, xin lưu ý rằng đó là
không đảm bảo bốn khối liền kề nhau hoặc theo thứ tự trên;
phần bù của id, bộ mô tả và khối dữ liệu được tìm thấy trong
tiêu đề.  Tuy nhiên, tất cả bốn khối đều được căn chỉnh theo độ lệch 64 bit trong
tập tin và chúng không chồng lên nhau.

Tất cả các khối ngoại trừ khối dữ liệu đều không thay đổi được.  Không gian người dùng có thể đọc chúng
chỉ một lần sau khi truy xuất bộ mô tả tệp, sau đó sử dụng ZZ0000ZZ hoặc
ZZ0001ZZ để đọc số liệu thống kê nhiều lần.

Tất cả dữ liệu đều ở dạng endianness của hệ thống.

Định dạng của tiêu đề như sau::

cấu trúc kvm_stats_header {
		__u32 cờ;
		__u32 tên_size;
		__u32 số_desc;
		__u32 id_offset;
		__u32 desc_offset;
		__u32 dữ liệu_offset;
	};

Trường ZZ0000ZZ hiện không được sử dụng. Nó luôn được đọc là 0.

Trường ZZ0000ZZ là kích thước (tính bằng byte) của chuỗi tên thống kê
(bao gồm cả dấu '\0') được chứa trong khối "chuỗi id" và
được thêm vào cuối mỗi phần mô tả.

Trường ZZ0000ZZ là số lượng bộ mô tả được bao gồm trong
khối mô tả.  (Số lượng giá trị thực tế trong khối dữ liệu có thể là
lớn hơn, vì mỗi bộ mô tả có thể bao gồm nhiều hơn một giá trị).

Trường ZZ0000ZZ là phần bù của chuỗi id từ đầu
tập tin được chỉ định bởi bộ mô tả tập tin. Nó là bội số của 8.

Trường ZZ0000ZZ là phần bù của khối Mô tả ngay từ đầu
của tệp được chỉ định bởi bộ mô tả tệp. Nó là bội số của 8.

Trường ZZ0000ZZ là phần bù của khối Dữ liệu Thống kê từ đầu
của tệp được chỉ định bởi bộ mô tả tệp. Nó là bội số của 8.

Khối chuỗi id chứa một chuỗi xác định bộ mô tả tệp trên
KVM_GET_STATS_FD nào đã được gọi.  Kích thước của khối, bao gồm cả
ZZ0000ZZ theo sau, được biểu thị bằng trường ZZ0001ZZ trong tiêu đề.

Khối mô tả chỉ cần được đọc một lần trong suốt thời gian tồn tại của
bộ mô tả tệp chứa một chuỗi ZZ0000ZZ, mỗi chuỗi theo sau
bằng một chuỗi có kích thước ZZ0001ZZ.
::::::::::::::::::::::::::::::::::::::

#define KVM_STATS_TYPE_SHIFT 0
	#define KVM_STATS_TYPE_MASK (0xF << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_CUMULATIVE (0x0 << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_INSTANT (0x1 << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_PEAK (0x2 << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_LINEAR_HIST (0x3 << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_LOG_HIST (0x4 << KVM_STATS_TYPE_SHIFT)
	#define KVM_STATS_TYPE_MAX KVM_STATS_TYPE_LOG_HIST

#define KVM_STATS_UNIT_SHIFT 4
	#define KVM_STATS_UNIT_MASK (0xF << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_NONE (0x0 << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_BYTES (0x1 << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_SECONDS (0x2 << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_CYCLES (0x3 << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_BOOLEAN (0x4 << KVM_STATS_UNIT_SHIFT)
	#define KVM_STATS_UNIT_MAX KVM_STATS_UNIT_BOOLEAN

#define KVM_STATS_BASE_SHIFT 8
	#define KVM_STATS_BASE_MASK (0xF << KVM_STATS_BASE_SHIFT)
	#define KVM_STATS_BASE_POW10 (0x0 << KVM_STATS_BASE_SHIFT)
	#define KVM_STATS_BASE_POW2 (0x1 << KVM_STATS_BASE_SHIFT)
	#define KVM_STATS_BASE_MAX KVM_STATS_BASE_POW2

cấu trúc kvm_stats_desc {
		__u32 cờ;
		__s16 số mũ;
		__u16 kích thước;
		__u32 bù đắp;
		__u32 xô_size;
		tên char[];
	};

Trường ZZ0000ZZ chứa loại và đơn vị dữ liệu thống kê được mô tả
bởi bộ mô tả này. Độ bền của nó là bản địa CPU.
Các cờ sau được hỗ trợ:

Bit 0-3 của ZZ0000ZZ mã hóa loại:

* ZZ0000ZZ
    Số liệu thống kê báo cáo số lượng tích lũy. Giá trị của dữ liệu chỉ có thể được tăng lên.
    Hầu hết các bộ đếm được sử dụng trong KVM đều thuộc loại này.
    Trường ZZ0001ZZ tương ứng cho loại này luôn là 1.
    Tất cả dữ liệu thống kê tích lũy đều được đọc/ghi.
  * ZZ0002ZZ
    Số liệu thống kê báo cáo một giá trị tức thời. Giá trị của nó có thể tăng lên hoặc
    giảm đi. Loại này thường được sử dụng để đo lường một số tài nguyên,
    như số lượng trang bẩn, số lượng trang lớn, v.v.
    Tất cả số liệu thống kê tức thời chỉ được đọc.
    Trường ZZ0003ZZ tương ứng cho loại này luôn là 1.
  * ZZ0004ZZ
    Dữ liệu thống kê báo cáo giá trị cao nhất, ví dụ: số lượng tối đa
    của các mục trong nhóm bảng băm, thời gian chờ đợi lâu nhất, v.v.
    Giá trị của dữ liệu chỉ có thể được tăng lên.
    Trường ZZ0005ZZ tương ứng cho loại này luôn là 1.
  * ZZ0006ZZ
    Thống kê được báo cáo dưới dạng biểu đồ tuyến tính. Số lượng
    nhóm được chỉ định bởi trường ZZ0007ZZ. Kích thước của thùng được chỉ định
    bởi trường ZZ0008ZZ. Phạm vi của nhóm thứ N (1 <= N < ZZ0009ZZ)
    là [ZZ0010ZZZZ0018ZZN), trong khi phạm vi của giá trị cuối cùng
    nhóm là [ZZ0012ZZ*(ZZ0013ZZ-1), +INF). (+INF nghĩa là dương vô cực
    giá trị.)
  * ZZ0014ZZ
    Thống kê được báo cáo dưới dạng biểu đồ logarit. Số lượng
    các nhóm được chỉ định bởi trường ZZ0015ZZ. Phạm vi của thùng đầu tiên là
    [0, 1), trong khi phạm vi của nhóm cuối cùng là [pow(2, ZZ0016ZZ-2), +INF).
    Mặt khác, thùng thứ N (1 < N < ZZ0017ZZ) bao gồm
    [pow(2, N-2), pow(2, N-1)).

Bit 4-7 của ZZ0000ZZ mã hóa đơn vị:

* ZZ0000ZZ
    Không có đơn vị cho giá trị của dữ liệu thống kê. Điều này thường có nghĩa là
    giá trị là một bộ đếm đơn giản của một sự kiện.
  * ZZ0001ZZ
    Nó chỉ ra rằng dữ liệu thống kê được sử dụng để đo kích thước bộ nhớ, trong
    đơn vị của Byte, KiByte, MiByte, GiByte, v.v. Đơn vị của dữ liệu là
    được xác định bởi trường ZZ0002ZZ trong bộ mô tả.
  * ZZ0003ZZ
    Nó chỉ ra rằng dữ liệu thống kê được sử dụng để đo thời gian hoặc độ trễ.
  * ZZ0004ZZ
    Nó chỉ ra rằng dữ liệu thống kê được sử dụng để đo chu kỳ xung nhịp CPU.
  * ZZ0005ZZ
    Nó chỉ ra rằng số liệu thống kê sẽ luôn là 0 hoặc 1. Boolean
    số liệu thống kê thuộc loại "đỉnh" sẽ không bao giờ quay trở lại từ 1 về 0. Boolean
    số liệu thống kê có thể là biểu đồ tuyến tính (có hai nhóm) nhưng không phải là logarit
    biểu đồ.

Lưu ý rằng, trong trường hợp biểu đồ, đơn vị áp dụng cho nhóm
phạm vi, trong khi giá trị nhóm cho biết có bao nhiêu mẫu rơi vào
phạm vi của xô.

Các bit 8-11 của ZZ0000ZZ, cùng với ZZ0001ZZ, mã hóa thang đo của
đơn vị:

* ZZ0000ZZ
    Thang đo dựa trên lũy thừa 10. Nó được sử dụng để đo thời gian và
    Chu kỳ đồng hồ CPU.  Ví dụ: số mũ của -9 có thể được sử dụng với
    ZZ0001ZZ để biểu thị đơn vị là nano giây.
  * ZZ0002ZZ
    Thang đo dựa trên lũy thừa của 2. Nó được sử dụng để đo kích thước bộ nhớ.
    Ví dụ: số mũ của 20 có thể được sử dụng với ZZ0003ZZ để
    thể hiện đơn vị là MiB.

Trường ZZ0000ZZ là số giá trị của dữ liệu thống kê này. của nó
giá trị thường là 1 đối với hầu hết các số liệu thống kê đơn giản. 1 có nghĩa là nó chứa một
dữ liệu 64bit không dấu.

Trường ZZ0000ZZ là phần bù từ đầu Khối dữ liệu đến đầu
số liệu thống kê tương ứng.

Trường ZZ0000ZZ được sử dụng làm tham số cho dữ liệu thống kê biểu đồ.
Nó chỉ được sử dụng bởi dữ liệu thống kê biểu đồ tuyến tính, xác định kích thước của một
nhóm trong đơn vị được biểu thị bằng các bit 4-11 của ZZ0001ZZ cùng với ZZ0002ZZ.

Trường ZZ0000ZZ là chuỗi tên của dữ liệu thống kê. Chuỗi tên
bắt đầu ở cuối ZZ0001ZZ.  Chiều dài tối đa bao gồm
ZZ0002ZZ ở cuối, được biểu thị bằng ZZ0003ZZ trong tiêu đề.

Khối dữ liệu thống kê chứa một mảng các giá trị 64 bit theo cùng thứ tự
làm bộ mô tả trong khối Bộ mô tả.

4.134 KVM_GET_XSAVE2
--------------------

:Khả năng: KVM_CAP_XSAVE2
:Kiến trúc: x86
:Type: vcpu ioctl
:Thông số: struct kvm_xsave (out)
:Trả về: 0 nếu thành công, -1 nếu có lỗi


::

cấu trúc kvm_xsave {
	__u32 vùng[1024];
	__u32 thêm[0];
  };

Ioctl này sẽ sao chép cấu trúc xsave của vcpu hiện tại vào không gian người dùng. Nó
sao chép số byte được trả về bởi KVM_CHECK_EXTENSION(KVM_CAP_XSAVE2)
khi được gọi trên bộ mô tả tệp vm. Giá trị kích thước được trả về bởi
KVM_CHECK_EXTENSION(KVM_CAP_XSAVE2) sẽ luôn có ít nhất 4096.
Hiện tại, nó chỉ lớn hơn 4096 nếu tính năng động đã được
được bật bằng ZZ0000ZZ, nhưng điều này có thể thay đổi trong tương lai.

Độ lệch của vùng lưu trạng thái trong struct kvm_xsave tuân theo nội dung
của CPUID lá 0xD trên máy chủ.

4.135 KVM_XEN_HVM_EVTCHN_SEND
-----------------------------

:Khả năng: KVM_CAP_XEN_HVM / KVM_XEN_HVM_CONFIG_EVTCHN_SEND
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_irq_routing_xen_evtchn
:Trả về: 0 nếu thành công, < 0 nếu có lỗi


::

cấu trúc kvm_irq_routing_xen_evtchn {
	__u32 cổng;
	__u32 vcpu;
	__u32 ưu tiên;
   };

Ioctl này đưa gián đoạn kênh sự kiện trực tiếp vào vCPU khách.

4.136 KVM_S390_PV_CPU_COMMAND
-----------------------------

:Khả năng: KVM_CAP_S390_PROTECTED_DUMP
:Kiến trúc: s390
:Type: vcpu ioctl
:Thông số: không có
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

Ioctl này phản ánh chặt chẽ ZZ0000ZZ nhưng xử lý các yêu cầu
cho vcpus. Nó sử dụng lại cấu trúc kvm_s390_pv_dmp và do đó cũng chia sẻ
các id lệnh.

ZZ0000ZZ

KVM_PV_DUMP
  Trình bày API cung cấp các cuộc gọi tạo điều kiện thuận lợi cho việc kết xuất vcpu
  của một máy ảo được bảo vệ.

ZZ0000ZZ

KVM_PV_DUMP_CPU
  Cung cấp dữ liệu kết xuất được mã hóa như giá trị đăng ký.
  Độ dài của dữ liệu trả về được cung cấp bởi uv_info.guest_cpu_stor_len.

4.137 KVM_S390_ZPCI_OP
----------------------

:Khả năng: KVM_CAP_S390_ZPCI_OP
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_zpci_op (trong)
:Trả về: 0 nếu thành công, <0 nếu có lỗi

Được sử dụng để quản lý các tính năng ảo hóa được hỗ trợ bằng phần cứng cho các thiết bị zPCI.

Các tham số được chỉ định thông qua cấu trúc sau::

cấu trúc kvm_s390_zpci_op {
	/* trong */
	__u32 fh;		/*thiết bị đích*/
	__u8 op;		/* thao tác cần thực hiện */
	__u8 đệm[3];
	công đoàn {
		/* cho KVM_S390_ZPCIOP_REG_AEN */
		cấu trúc {
			__u64 ibv;	/* Địa chỉ khách của vectơ bit ngắt */
			__u64 sb;	/* Địa chỉ khách của bit tóm tắt */
			__u32 cờ;
			__u32 này;	/*Số lần ngắt */
			__u8 isc;	/* Phân lớp ngắt khách */
			__u8 sbo;	/* Độ lệch của vectơ bit tóm tắt khách */
			__u16 đệm;
		} reg_aen;
		__u64 dành riêng[8];
	} bạn;
  };

Loại hoạt động được chỉ định trong trường "op".
KVM_S390_ZPCIOP_REG_AEN được sử dụng để đăng ký VM cho sự kiện bộ điều hợp
giải thích thông báo, điều này sẽ cho phép phân phối phần sụn của bộ chuyển đổi
các sự kiện trực tiếp đến vm, với KVM cung cấp cơ chế phân phối dự phòng;
KVM_S390_ZPCIOP_DEREG_AEN được sử dụng để sau đó vô hiệu hóa việc giải thích
thông báo sự kiện bộ điều hợp.

Chức năng zPCI đích cũng phải được chỉ định thông qua trường "fh".  Đối với
Hoạt động KVM_S390_ZPCIOP_REG_AEN, thông tin bổ sung để thiết lập chương trình cơ sở
việc phân phối phải được cung cấp thông qua cấu trúc "reg_aen".

Các trường "pad" và "dành riêng" có thể được sử dụng cho các tiện ích mở rộng trong tương lai và phải được
được đặt thành 0 theo không gian người dùng.

4.138 KVM_ARM_SET_COUNTER_OFFSET
--------------------------------

:Khả năng: KVM_CAP_COUNTER_OFFSET
:Kiến trúc: arm64
:Type: vm ioctl
:Thông số: struct kvm_arm_counter_offset (trong)
:Trả về: 0 nếu thành công, < 0 nếu có lỗi

Khả năng này chỉ ra rằng không gian người dùng có thể áp dụng một VM trên toàn bộ
bù đắp cho cả quầy ảo và vật lý mà khách hàng xem
sử dụng KVM_ARM_SET_CNT_OFFSET ioctl và cấu trúc dữ liệu sau:

::

cấu trúc kvm_arm_counter_offset {
		__u64 counter_offset;
		__u64 dành riêng;
	};

Phần bù mô tả một số chu kỳ truy cập được trừ khỏi
cả chế độ xem bộ đếm ảo và vật lý (tương tự như hiệu ứng của
Đăng ký hệ thống CNTVOFF_EL2 và CNTPOFF_EL2, nhưng chỉ đăng ký toàn cầu). Phần bù
luôn áp dụng cho tất cả vcpus (đã được tạo hoặc được tạo sau ioctl này)
cho máy ảo này.

Trách nhiệm của không gian người dùng là tính toán phần bù dựa trên, ví dụ:
trên các giá trị trước đó của bộ đếm khách.

Bất kỳ giá trị nào khác 0 cho trường "dành riêng" có thể dẫn đến lỗi
(-EINVAL) được trả lại. Ioctl này cũng có thể trả về -EBUSY nếu có vcpu
ioctl được phát hành đồng thời.

Lưu ý rằng việc sử dụng ioctl này sẽ dẫn đến KVM bỏ qua không gian người dùng tiếp theo
ghi vào các thanh ghi CNTVCT_EL0 và CNTPCT_EL0 bằng SET_ONE_REG
giao diện. Sẽ không có lỗi nào được trả về nhưng phần bù thu được sẽ không được trả về
áp dụng.

.. _KVM_ARM_GET_REG_WRITABLE_MASKS:

4.139 KVM_ARM_GET_REG_WRITABLE_MASKS
------------------------------------

:Khả năng: KVM_CAP_ARM_SUPPORTED_REG_MASK_RANGES
:Kiến trúc: arm64
:Type: vm ioctl
:Thông số: struct reg_mask_range (vào/ra)
:Trả về: 0 nếu thành công, < 0 nếu có lỗi


::

#define KVM_ARM_FEATURE_ID_RANGE 0
        #define KVM_ARM_FEATURE_ID_RANGE_SIZE (3*8*8)

cấu trúc reg_mask_range {
                __u64 địa chỉ;             /* Con trỏ tới mảng mặt nạ */
                __u32 phạm vi;            /* Phạm vi được yêu cầu */
                __u32 dành riêng[13];
        };

Ioctl này sao chép các mặt nạ có thể ghi cho một phạm vi thanh ghi đã chọn sang
không gian người dùng.

Trường ZZ0000ZZ là một con trỏ tới mảng đích nơi KVM sao chép
mặt nạ có thể ghi được.

Trường ZZ0000ZZ cho biết phạm vi thanh ghi được yêu cầu.
ZZ0001ZZ dành cho ZZ0002ZZ
khả năng trả về phạm vi được hỗ trợ, được biểu thị dưới dạng một tập hợp cờ. Mỗi
chỉ số bit của cờ biểu thị một giá trị có thể có cho trường ZZ0003ZZ.
Tất cả các giá trị khác được dành riêng để sử dụng trong tương lai và KVM có thể trả về lỗi.

Mảng ZZ0000ZZ được dành riêng để sử dụng trong tương lai và phải bằng 0 hoặc
KVM có thể trả về lỗi.

KVM_ARM_FEATURE_ID_RANGE (0)
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Phạm vi ID tính năng được xác định là không gian đăng ký Hệ thống AArch64 với
op0==3, op1=={0, 1, 3}, CRn==0, CRm=={0-7}, op2=={0-7}.

Mảng trả về mặt nạ được trỏ bởi ZZ0000ZZ được macro lập chỉ mục
ZZ0001ZZ, cho phép không gian người dùng
để biết những trường nào có thể được thay đổi cho thanh ghi hệ thống được mô tả bởi
ZZ0002ZZ. KVM từ chối các giá trị thanh ghi ID mô tả một
siêu bộ các tính năng được hệ thống hỗ trợ.

4.140 KVM_SET_USER_MEMORY_REGION2
---------------------------------

:Khả năng: KVM_CAP_USER_MEMORY2
:Kiến trúc: tất cả
:Type: vm ioctl
:Thông số: struct kvm_userspace_memory_khu vực2 (trong)
:Trả về: 0 nếu thành công, -1 nếu có lỗi

KVM_SET_USER_MEMORY_REGION2 là phần mở rộng của KVM_SET_USER_MEMORY_REGION
cho phép ánh xạ bộ nhớ guest_memfd vào một khách.  Tất cả các trường được chia sẻ với
KVM_SET_USER_MEMORY_REGION giống hệt nhau.  Không gian người dùng có thể đặt KVM_MEM_GUEST_MEMFD
trong các cờ để KVM liên kết vùng bộ nhớ với phạm vi guest_memfd nhất định
[guest_memfd_offset, guest_memfd_offset + bộ nhớ_size].  Mục tiêu guest_memfd
phải trỏ đến tệp được tạo qua KVM_CREATE_GUEST_MEMFD trên máy ảo hiện tại và
phạm vi mục tiêu không được bị ràng buộc với bất kỳ vùng bộ nhớ nào khác.  Tất cả các tiêu chuẩn
áp dụng kiểm tra giới hạn (sử dụng thông thường).

::

cấu trúc kvm_userspace_memory_khu vực2 {
	__u32 khe cắm;
	__u32 cờ;
	__u64 guest_phys_addr;
	__u64 bộ nhớ_size; /* byte */
	__u64 không gian người dùng_addr; /* bắt đầu bộ nhớ được phân bổ của vùng người dùng */
	__u64 guest_memfd_offset;
	__u32 guest_memfd;
	__u32 pad1;
	__u64 pad2[14];
  };

Vùng KVM_MEM_GUEST_MEMFD _phải_ có guest_memfd hợp lệ (bộ nhớ riêng) và
userspace_addr (bộ nhớ dùng chung).  Tuy nhiên, "hợp lệ" đối với userspace_addr chỉ đơn giản là
có nghĩa là địa chỉ đó phải là địa chỉ vùng người dùng hợp pháp.  Sự ủng hộ
ánh xạ cho userspace_addr không bắt buộc phải hợp lệ/được điền tại thời điểm
KVM_SET_USER_MEMORY_REGION2, ví dụ: bộ nhớ dùng chung có thể được ánh xạ/phân bổ một cách lười biếng
theo yêu cầu.

Khi ánh xạ một gfn vào khách, KVM chọn chia sẻ và riêng tư, tức là tiêu thụ
userspace_addr so với guest_memfd, dựa trên KVM_MEMORY_ATTRIBUTE_PRIVATE của gfn
trạng thái.  Tại thời điểm tạo VM, tất cả bộ nhớ được chia sẻ, tức là thuộc tính PRIVATE
là '0' cho tất cả gfns.  Không gian người dùng có thể kiểm soát xem bộ nhớ có được chia sẻ/riêng tư hay không
chuyển đổi KVM_MEMORY_ATTRIBUTE_PRIVATE qua KVM_SET_MEMORY_ATTRIBUTES nếu cần.

S390:
^^^^^

Trả về -EINVAL nếu VM đã đặt cờ KVM_VM_S390_UCONTROL.
Trả về -EINVAL nếu được gọi trên máy ảo được bảo vệ.

4.141 KVM_SET_MEMORY_ATTRIBUTES
-------------------------------

:Khả năng: KVM_CAP_MEMORY_ATTRIBUTES
:Kiến trúc: x86
:Type: vm ioctl
:Thông số: struct kvm_memory_attributes (trong)
:Trả về: 0 nếu thành công, <0 nếu có lỗi

KVM_SET_MEMORY_ATTRIBUTES cho phép không gian người dùng đặt thuộc tính bộ nhớ cho một phạm vi
của bộ nhớ vật lý của khách.

::

cấu trúc kvm_memory_attributes {
	địa chỉ __u64;
	__u64 kích thước;
	__u64 thuộc tính;
	__u64 cờ;
  };

#define KVM_MEMORY_ATTRIBUTE_PRIVATE (1ULL << 3)

Địa chỉ và kích thước phải được căn chỉnh theo trang.  Các thuộc tính được hỗ trợ có thể là
được truy xuất qua ioctl(KVM_CHECK_EXTENSION) trên KVM_CAP_MEMORY_ATTRIBUTES.  Nếu
được thực thi trên VM, KVM_CAP_MEMORY_ATTRIBUTES trả về chính xác các thuộc tính
được hỗ trợ bởi VM đó.  Nếu được thực thi ở phạm vi hệ thống, KVM_CAP_MEMORY_ATTRIBUTES
trả về tất cả các thuộc tính được KVM hỗ trợ.  Thuộc tính duy nhất được xác định tại đây
thời gian là KVM_MEMORY_ATTRIBUTE_PRIVATE, đánh dấu gfn liên quan là
ký ức riêng tư của khách.

Lưu ý, không có "lấy" API.  Không gian người dùng chịu trách nhiệm theo dõi rõ ràng
trạng thái của gfn/trang nếu cần.

Trường "cờ" được dành riêng cho các tiện ích mở rộng trong tương lai và phải là '0'.

4.142 KVM_CREATE_GUEST_MEMFD
----------------------------

:Khả năng: KVM_CAP_GUEST_MEMFD
:Kiến trúc: không có
:Type: vm ioctl
:Thông số: struct kvm_create_guest_memfd(in)
:Trả về: Bộ mô tả tệp khi thành công, <0 nếu có lỗi

KVM_CREATE_GUEST_MEMFD tạo một tệp ẩn danh và trả về bộ mô tả tệp
điều đó đề cập đến nó.  Các tệp guest_memfd gần giống với các tệp được tạo
thông qua memfd_create(), ví dụ: Các tệp guest_memfd tồn tại trong RAM, có bộ nhớ dễ thay đổi,
và được tự động giải phóng khi tham chiếu cuối cùng bị loại bỏ.  Không giống
các tệp memfd_create() "thông thường", các tệp guest_memfd bị ràng buộc với quyền sở hữu của chúng
máy ảo (xem bên dưới), không thể ánh xạ, đọc hoặc ghi bởi không gian người dùng,
và không thể thay đổi kích thước (tuy nhiên các tệp guest_memfd hỗ trợ PUNCH_HOLE).

::

cấu trúc kvm_create_guest_memfd {
	__u64 kích thước;
	__u64 cờ;
	__u64 dành riêng[6];
  };

Về mặt khái niệm, inode sao lưu tệp guest_memfd đại diện cho bộ nhớ vật lý,
tức là được ghép nối với máy ảo như một vật thể chứ không phải với "struct kvm".  các
chính tệp đó, được liên kết với "struct kvm", là chế độ xem của phiên bản đó về
bộ nhớ cơ bản, ví dụ: cung cấp hiệu quả việc dịch địa chỉ của khách
để lưu trữ bộ nhớ.  Điều này cho phép các trường hợp sử dụng có nhiều cấu trúc KVM
được sử dụng để quản lý một máy ảo duy nhất, ví dụ: khi thực hiện nội bộ
di chuyển của một máy ảo.

KVM hiện chỉ hỗ trợ ánh xạ guest_memfd qua KVM_SET_USER_MEMORY_REGION2,
và cụ thể hơn là thông qua các trường guest_memfd và guest_memfd_offset trong
"struct kvm_userspace_memory_khu vực2", trong đó guest_memfd_offset là phần bù
vào phiên bản guest_memfd.  Đối với một tệp guest_memfd nhất định, có thể có tại
hầu hết một ánh xạ trên mỗi trang, tức là liên kết nhiều vùng bộ nhớ với một
phạm vi guest_memfd không được phép (bất kỳ số vùng bộ nhớ nào cũng có thể bị ràng buộc với
một tệp guest_memfd duy nhất, nhưng phạm vi giới hạn không được trùng nhau).

Khả năng KVM_CAP_GUEST_MEMFD_FLAGS liệt kê ZZ0000ZZ có thể
được chỉ định thông qua KVM_CREATE_GUEST_MEMFD.  Cờ hiện được xác định:

===================================================================================
  GUEST_MEMFD_FLAG_MMAP Kích hoạt bằng cách sử dụng mmap() trên tệp guest_memfd
                               mô tả.
  GUEST_MEMFD_FLAG_INIT_SHARED Tạo tất cả bộ nhớ trong tệp được chia sẻ trong
                               KVM_CREATE_GUEST_MEMFD (tệp bộ nhớ được tạo
                               không có INIT_SHARED sẽ được đánh dấu là riêng tư).
                               Bộ nhớ dùng chung có thể bị lỗi trong không gian người dùng máy chủ
                               các bảng trang. Bộ nhớ riêng không thể.
  ===================================================================================

Khi KVM MMU thực hiện tra cứu PFN để khắc phục lỗi của khách và sao lưu
guest_memfd đã đặt GUEST_MEMFD_FLAG_MMAP thì lỗi sẽ luôn
được sử dụng từ guest_memfd, bất kể đó là chia sẻ hay riêng tư
lỗi.

Xem KVM_SET_USER_MEMORY_REGION2 để biết thêm chi tiết.

4.143 KVM_PRE_FAULT_MEMORY
---------------------------

:Khả năng: KVM_CAP_PRE_FAULT_MEMORY
:Kiến trúc: không có
:Type: vcpu ioctl
:Thông số: struct kvm_pre_fault_memory (vào/ra)
:Trả về: 0 nếu ít nhất một trang được xử lý, < 0 do lỗi

Lỗi:

===============================================================================
  EINVAL ZZ0000ZZ và ZZ0001ZZ được chỉ định không hợp lệ (ví dụ: không
             căn chỉnh trang, gây tràn trang hoặc kích thước bằng 0).
  ENOENT ZZ0002ZZ được chỉ định nằm ngoài các khe ghi nhớ được xác định.
  EINTR Tín hiệu bị lộ đang chờ xử lý và không có trang nào được xử lý.
  EFAULT Địa chỉ tham số không hợp lệ.
  EOPNOTSUPP Bộ nhớ ánh xạ cho GPA không được hỗ trợ bởi
             bộ ảo hóa và/hoặc trạng thái/chế độ vCPU hiện tại.
  EIO tình trạng lỗi không mong muốn (cũng gây ra WARN)
  ===============================================================================

::

cấu trúc kvm_pre_fault_memory {
	/* vào/ra */
	__u64 gpa;
	__u64 kích thước;
	/* trong */
	__u64 cờ;
	__u64 phần đệm[5];
  };

KVM_PRE_FAULT_MEMORY điền vào các bảng trang giai đoạn 2 của KVM được sử dụng để ánh xạ bộ nhớ
cho trạng thái vCPU hiện tại.  KVM ánh xạ bộ nhớ như thể vCPU đã tạo ra một
lỗi trang đọc giai đoạn 2, ví dụ: lỗi trong bộ nhớ khi cần thiết, nhưng không bị hỏng
Bò.  Tuy nhiên, KVM không đánh dấu bất kỳ PTE giai đoạn 2 mới được tạo nào là Đã truy cập.

Trong trường hợp các loại VM bí mật có thiết lập ban đầu
bộ nhớ riêng của khách trước khi khách được 'hoàn thiện'/đo lường, ioctl này
chỉ nên được cấp sau khi hoàn thành tất cả các thiết lập cần thiết để đặt
khách vào trạng thái 'hoàn thiện' để ngữ nghĩa trên có thể đáng tin cậy
được đảm bảo.

Trong một số trường hợp, nhiều vCPU có thể chia sẻ bảng trang.  Trong này
trường hợp, ioctl có thể được gọi song song.

Khi ioctl trả về, các giá trị đầu vào được cập nhật để trỏ đến
phạm vi còn lại.  Nếu ZZ0000ZZ > 0 khi trả về, người gọi chỉ có thể đưa ra
lại ioctl với cùng đối số ZZ0001ZZ.

Bảng trang bóng không thể hỗ trợ ioctl này vì chúng
được lập chỉ mục theo địa chỉ ảo hoặc địa chỉ vật lý của khách lồng nhau.
Gọi ioctl này khi khách đang sử dụng bảng trang bóng (ví dụ:
ví dụ vì nó đang chạy một khách lồng nhau với các bảng trang lồng nhau)
sẽ thất bại với ZZ0000ZZ ngay cả khi ZZ0001ZZ báo cáo
khả năng có mặt.

ZZ0000ZZ hiện tại phải bằng 0.

4.144 KVM_S390_KEYOP
--------------------

:Khả năng: KVM_CAP_S390_KEYOP
:Kiến trúc: s390
:Type: vm ioctl
:Thông số: struct kvm_s390_keyop (vào/ra)
:Trả về: 0 nếu thành công, < 0 nếu lỗi

Thao tác phím được chỉ định được thực hiện trên địa chỉ khách đã cho. các
khóa lưu trữ trước đó (hoặc phần liên quan của nó) sẽ được trả lại trong
ZZ0000ZZ.

::

cấu trúc kvm_s390_keyop {
	__u64 guest_addr;
	phím __u8;
	__u8 hoạt động;
  };

Các giá trị hiện được hỗ trợ cho ZZ0000ZZ:

KVM_S390_KEYOP_ISKE
  Trả về khóa lưu trữ cho địa chỉ khách ZZ0000ZZ trong ZZ0001ZZ.

KVM_S390_KEYOP_RRBE
  Đặt lại bit tham chiếu cho địa chỉ khách ZZ0000ZZ, trả về địa chỉ
  Các bit R và C của khóa lưu trữ cũ trong ZZ0001ZZ; các trường còn lại của
  khóa lưu trữ sẽ được đặt thành 0.

KVM_S390_KEYOP_SSKE
  Đặt khóa lưu trữ cho địa chỉ khách ZZ0000ZZ thành khóa
  được chỉ định trong ZZ0001ZZ, trả về giá trị trước đó trong ZZ0002ZZ.

.. _kvm_run:

5. Cấu trúc kvm_run
========================

Mã ứng dụng lấy một con trỏ tới cấu trúc kvm_run bằng cách
mmap() đang tạo vcpu fd.  Từ thời điểm đó, mã ứng dụng có thể kiểm soát
thực thi bằng cách thay đổi các trường trong kvm_run trước khi gọi KVM_RUN
ioctl và lấy thông tin về lý do KVM_RUN được trả về bởi
tra cứu các thành viên cấu trúc.

::

cấu trúc kvm_run {
	/* trong */
	__u8 request_interrupt_window;

Yêu cầu KVM_RUN quay trở lại khi có thể tiêm bên ngoài
ngắt lời khách.  Hữu ích khi kết hợp với KVM_INTERRUPT.

::

__u8 ngay_exit;

Trường này được thăm dò một lần khi KVM_RUN bắt đầu; nếu khác 0, KVM_RUN
thoát ngay lập tức, trả về -EINTR.  Trong tình huống chung khi một
tín hiệu được sử dụng để "đá" VCPU ra khỏi KVM_RUN, trường này có thể được sử dụng
để tránh sử dụng KVM_SET_SIGNAL_MASK, loại KVM_SET_SIGNAL_MASK có khả năng mở rộng kém hơn.
Thay vì chặn tín hiệu bên ngoài KVM_RUN, không gian người dùng có thể thiết lập
trình xử lý tín hiệu đặt run->immediate_exit thành giá trị khác 0.

Trường này bị bỏ qua nếu KVM_CAP_IMMEDIATE_EXIT không có sẵn.

::

__u8 đệm1[6];

/* ra */
	__u32 exit_reason;

Khi KVM_RUN trả về thành công (giá trị trả về 0), điều này sẽ thông báo
mã ứng dụng tại sao KVM_RUN đã quay trở lại.  Giá trị cho phép cho việc này
trường được trình bày chi tiết bên dưới.

::

__u8 sẵn sàng_for_interrupt_injection;

Nếu request_interrupt_window đã được chỉ định, trường này cho biết
bây giờ có thể chèn một ngắt bằng KVM_INTERRUPT.

::

__u8 if_flag;

Giá trị của cờ ngắt hiện tại.  Chỉ hợp lệ nếu trong kernel
APIC cục bộ không được sử dụng.

::

__u16 lá cờ;

Nhiều cờ dành riêng cho kiến trúc nêu chi tiết trạng thái của VCPU có thể
ảnh hưởng đến hoạt động của thiết bị. Cờ được xác định hiện tại::

/* x86, đặt nếu VCPU ở chế độ quản lý hệ thống */
  #define KVM_RUN_X86_SMM (1 << 0)
  /* x86, đặt nếu phát hiện khóa bus trong VM */
  #define KVM_RUN_X86_BUS_LOCK (1 << 1)
  /* x86, đặt nếu VCPU đang thực thi một khách (L2) lồng nhau */
  #define KVM_RUN_X86_GUEST_MODE (1 << 2)

/* arm64, đặt cho KVM_EXIT_DEBUG */
  #define KVM_DEBUG_ARCH_HSR_HIGH_VALID (1 << 0)

::

/* vào (pre_kvm_run), ra (post_kvm_run) */
	__u64 cr8;

Giá trị của thanh ghi cr8.  Chỉ hợp lệ nếu APIC cục bộ trong kernel là
không được sử dụng.  Cả đầu vào và đầu ra.

::

__u64 apic_base;

Giá trị của APIC BASE msr.  Chỉ hợp lệ nếu trong kernel cục bộ
APIC không được sử dụng.  Cả đầu vào và đầu ra.

::

công đoàn {
		/* KVM_EXIT_UNKNOWN */
		cấu trúc {
			__u64 phần cứng_exit_reason;
		} sao;

Nếu exit_reason là KVM_EXIT_UNKNOWN thì vcpu đã thoát do không xác định
lý do.  Thông tin cụ thể hơn về kiến trúc có sẵn trong
phần cứng_exit_reason.

::

/* KVM_EXIT_FAIL_ENTRY */
		cấu trúc {
			__u64 phần cứng_entry_failure_reason;
			__u32cpu; /* nếu KVM_LAST_CPU */
		} failed_entry;

Nếu exit_reason là KVM_EXIT_FAIL_ENTRY thì vcpu không thể chạy được
vì những lý do không rõ.  Thông tin cụ thể hơn về kiến trúc là
có sẵn trong phần cứng_entry_failure_reason.

::

/* KVM_EXIT_EXCEPTION */
		cấu trúc {
			__u32 ngoại lệ;
			__u32 error_code;
		} bán tại;

Chưa sử dụng.

::

/* KVM_EXIT_IO */
		cấu trúc {
  #define KVM_EXIT_IO_IN 0
  #define KVM_EXIT_IO_OUT 1
			__u8 hướng;
			__u8 kích thước; /* byte */
			__u16 cổng;
			__u32 đếm;
			__u64 dữ liệu_offset; /* liên quan đến kvm_run bắt đầu */
		} io;

Nếu exit_reason là KVM_EXIT_IO thì vcpu có
đã thực thi một lệnh I/O cổng mà kvm không thể đáp ứng.
data_offset mô tả vị trí của dữ liệu (KVM_EXIT_IO_OUT) hoặc
nơi kvm mong đợi mã ứng dụng sẽ đặt dữ liệu cho lần tiếp theo
Lệnh gọi KVM_RUN (KVM_EXIT_IO_IN).  Định dạng dữ liệu là một mảng đóng gói.

::

/* KVM_EXIT_DEBUG */
		cấu trúc {
			cấu trúc kvm_debug_exit_arch;
		} gỡ lỗi;

Nếu exit_reason là KVM_EXIT_DEBUG thì vcpu đang xử lý sự kiện gỡ lỗi
mà thông tin cụ thể về kiến trúc được trả về.

::

/* KVM_EXIT_MMIO */
		cấu trúc {
			__u64 vật lý_addr;
			__u8 dữ liệu[8];
			__u32 len;
			__u8 là_write;
		} mmio;

Nếu exit_reason là KVM_EXIT_MMIO thì vcpu có
đã thực thi một lệnh I/O được ánh xạ bộ nhớ nhưng không thể đáp ứng được
bởi kvm.  Thành viên 'data' chứa dữ liệu được ghi nếu 'is_write' là
đúng và nếu không thì phải được điền bằng mã ứng dụng.

Thành viên 'dữ liệu' chứa, trong byte 'len' đầu tiên của nó, giá trị như mong muốn
xuất hiện nếu VCPU thực hiện tải hoặc lưu trữ trực tiếp chiều rộng thích hợp
vào mảng byte.

.. note::

      For KVM_EXIT_IO, KVM_EXIT_MMIO, KVM_EXIT_OSI, KVM_EXIT_PAPR, KVM_EXIT_XEN,
      KVM_EXIT_EPR, KVM_EXIT_HYPERCALL, KVM_EXIT_TDX,
      KVM_EXIT_X86_RDMSR and KVM_EXIT_X86_WRMSR the corresponding
      operations are complete (and guest state is consistent) only after userspace
      has re-entered the kernel with KVM_RUN.  The kernel side will first finish
      incomplete operations and then check for pending signals.

      The pending state of the operation is not preserved in state which is
      visible to userspace, thus userspace should ensure that the operation is
      completed before performing a live migration.  Userspace can re-enter the
      guest with an unmasked signal pending or with the immediate_exit field set
      to complete pending operations without allowing any further instructions
      to be executed.

::

/* KVM_EXIT_HYPERCALL */
		cấu trúc {
			__u64 nr;
			__u64 lập luận[6];
			__u64 ret;
			__u64 cờ;
		} siêu gọi;


Chúng tôi đặc biệt khuyến nghị không gian người dùng nên sử dụng ZZ0000ZZ (x86) hoặc
ZZ0001ZZ (tất cả ngoại trừ s390) để triển khai chức năng
yêu cầu khách tương tác với không gian người dùng máy chủ.

.. note:: KVM_EXIT_IO is significantly faster than KVM_EXIT_MMIO.

Đối với cánh tay64:
-------------------

Các lối thoát SMCCC có thể được bật tùy thuộc vào cấu hình của SMCCC
bộ lọc. Xem Tài liệu/virt/kvm/devices/vm.rst
ZZ0000ZZ để biết thêm chi tiết.

ZZ0000ZZ chứa ID chức năng của cuộc gọi SMCCC của khách. Không gian người dùng là
dự kiến sẽ sử dụng ZZ0001ZZ ioctl để nhận cuộc gọi
các tham số từ GPR của vCPU.

Định nghĩa ZZ0000ZZ:
 - ZZ0001ZZ: Cho biết khách đã sử dụng SMC
   ống dẫn để bắt đầu cuộc gọi SMCCC. Nếu bit này bằng 0 thì khách
   đã sử dụng ống dẫn HVC cho cuộc gọi SMCCC.

- ZZ0000ZZ: Cho biết khách đã sử dụng 16bit
   hướng dẫn để bắt đầu cuộc gọi SMCCC. Nếu bit này bằng 0 thì
   khách đã sử dụng lệnh 32 bit. Một vị khách AArch64 luôn có điều này
   bit được đặt thành 0.

Khi thoát ra, PC trỏ tới lệnh ngay sau đó
hướng dẫn bẫy.

::

/* KVM_EXIT_TPR_ACCESS */
		cấu trúc {
			__u64 rip;
			__u32 là_write;
			__u32 đệm;
		} tpr_access;

Được ghi lại (KVM_TPR_ACCESS_REPORTING).

::

/* KVM_EXIT_S390_SIEIC */
		cấu trúc {
			__u8 mã icpt;
			__u64 mặt nạ; /* psw nửa trên */
			__u64 địa chỉ; /* psw nửa dưới */
			__u16 ipa;
			__u32 ipb;
		} s390_sieic;

s390 cụ thể.

::

/* KVM_EXIT_S390_RESET */
  #define KVM_S390_RESET_POR 1
  #define KVM_S390_RESET_CLEAR 2
  #define KVM_S390_RESET_SUBSYSTEM 4
  #define KVM_S390_RESET_CPU_INIT 8
  #define KVM_S390_RESET_IPL 16
		__u64 s390_reset_flags;

s390 cụ thể.

::

/* KVM_EXIT_S390_UCONTROL */
		cấu trúc {
			__u64 trans_exc_code;
			__u32 pgm_code;
		} s390_ucontrol;

s390 cụ thể. Đã xảy ra lỗi trang đối với trang ảo do người dùng kiểm soát
máy (KVM_VM_S390_UNCONTROL) trên bảng trang chủ của nó không thể
được giải quyết bằng kernel.
Mã chương trình và mã ngoại lệ dịch đã được đặt
trong lõi thấp của CPU được trình bày ở đây theo định nghĩa của Kiến trúc z
Sách Nguyên tắc Vận hành trong Chương Dịch Địa chỉ Động
(DAT)

::

/* KVM_EXIT_DCR */
		cấu trúc {
			__u32 dcrn;
			__u32 dữ liệu;
			__u8 là_write;
		} dcr;

Không dùng nữa - đã được sử dụng cho 440 KVM.

::

/* KVM_EXIT_OSI */
		cấu trúc {
			__u64 gprs[32];
		} ôi;

MOL sử dụng giao diện hypercall đặc biệt mà nó gọi là 'OSI'. Để kích hoạt nó, chúng tôi bắt
siêu cuộc gọi và thoát với cấu trúc thoát này chứa tất cả các gprs khách.

Nếu exit_reason là KVM_EXIT_OSI thì vcpu đã kích hoạt siêu lệnh gọi như vậy.
Giờ đây, không gian người dùng có thể xử lý siêu cuộc gọi và khi hoàn tất, hãy sửa đổi gprs thành
cần thiết. Khi khách nhập vào, tất cả GPR của khách sẽ được thay thế bằng các giá trị
trong cấu trúc này.

::

/* KVM_EXIT_PAPR_HCALL */
		cấu trúc {
			__u64 nr;
			__u64 ret;
			__u64 lập luận[9];
		} papr_hcall;

Điều này được sử dụng trên PowerPC 64-bit khi mô phỏng phân vùng pSeries,
ví dụ: với loại máy 'pseries' trong qemu.  Nó xảy ra khi
khách thực hiện siêu cuộc gọi bằng lệnh 'sc 1'.  Trường 'nr'
chứa số siêu cuộc gọi (từ khách R3) và 'args' chứa
các đối số (từ khách R4 - R12).  Không gian người dùng nên đặt
mã trả về trong 'ret' và mọi giá trị được trả về bổ sung trong args[].
Các siêu lệnh có thể có được xác định trong Nền tảng kiến trúc sức mạnh
Tài liệu yêu cầu (PAPR) có sẵn từ www.power.org (miễn phí
cần phải đăng ký nhà phát triển để truy cập nó).

::

/* KVM_EXIT_S390_TSCH */
		cấu trúc {
			__u16 kênh con_id;
			__u16 kênh con_nr;
			__u32 io_int_parm;
			__u32 io_int_word;
			__u32 ipb;
			__u8 bị loại bỏ;
		} s390_tsch;

s390 cụ thể. Lối thoát này xảy ra khi KVM_CAP_S390_CSS_SUPPORT được bật
và TEST SUBCHANNEL đã bị chặn. Nếu đã xếp hàng đợi được đặt, I/O đang chờ xử lý
ngắt cho kênh con mục tiêu đã được loại bỏ khỏi hàng đợi và subchannel_id,
subchannel_nr, io_int_parm và io_int_word chứa các tham số cho điều đó
ngắt lời. ipb là cần thiết để giải mã tham số lệnh.

::

/* KVM_EXIT_EPR */
		cấu trúc {
			__u32 tập;
		} tập;

Trên chip FSL BookE PowerPC, bộ điều khiển ngắt có bản vá nhanh
ngắt xác nhận đường dẫn đến lõi. Khi lõi thành công
tạo ra một ngắt, nó sẽ tự động điền vào thanh ghi EPR với
số vectơ ngắt và xác nhận ngắt bên trong
bộ điều khiển ngắt.

Trong trường hợp bộ điều khiển ngắt nằm trong không gian người dùng, chúng ta cần thực hiện
chu trình xác nhận ngắt đi qua nó để lấy dữ liệu tiếp theo
đã phân phối vectơ ngắt bằng cách sử dụng lối ra này.

Nó được kích hoạt bất cứ khi nào cả KVM_CAP_PPC_EPR được bật và
ngắt bên ngoài vừa được chuyển đến khách. Không gian người dùng
nên đặt vectơ ngắt được xác nhận vào trường 'epr'.

::

/* KVM_EXIT_SYSTEM_EVENT */
		cấu trúc {
  #define KVM_SYSTEM_EVENT_SHUTDOWN 1
  #define KVM_SYSTEM_EVENT_RESET 2
  #define KVM_SYSTEM_EVENT_CRASH 3
  #define KVM_SYSTEM_EVENT_WAKEUP 4
  #define KVM_SYSTEM_EVENT_SUSPEND 5
  #define KVM_SYSTEM_EVENT_SEV_TERM 6
  #define KVM_SYSTEM_EVENT_TDX_FATAL 7
			__u32 loại;
                        __u32 ndata;
                        __u64 dữ liệu[16];
		} system_event;

Nếu exit_reason là KVM_EXIT_SYSTEM_EVENT thì vcpu đã kích hoạt
một sự kiện cấp hệ thống sử dụng một số cơ chế kiến trúc cụ thể (hypercall
hoặc một số hướng dẫn đặc biệt). Trong trường hợp ARM64, điều này được kích hoạt bằng cách sử dụng
Lệnh gọi PSCI dựa trên lệnh HVC từ vcpu.

Trường 'loại' mô tả loại sự kiện cấp hệ thống.
Các giá trị hợp lệ cho 'loại' là:

- KVM_SYSTEM_EVENT_SHUTDOWN -- khách đã yêu cầu tắt máy
   VM. Không gian người dùng không bắt buộc phải tôn trọng điều này và nếu nó tôn trọng
   điều này không cần phải hủy VM một cách đồng bộ (tức là nó có thể gọi
   KVM_RUN một lần nữa trước khi tắt máy).
 - KVM_SYSTEM_EVENT_RESET -- khách đã yêu cầu đặt lại VM.
   Như với SHUTDOWN, không gian người dùng có thể chọn bỏ qua yêu cầu hoặc
   để lên lịch thiết lập lại trong tương lai và có thể gọi lại KVM_RUN.
 - KVM_SYSTEM_EVENT_CRASH -- xảy ra sự cố với khách và khách
   đã yêu cầu bảo trì tình trạng sự cố. Không gian người dùng có thể chọn
   để bỏ qua yêu cầu hoặc để thu thập kết xuất lõi bộ nhớ VM và/hoặc
   thiết lập lại/tắt máy ảo.
 - KVM_SYSTEM_EVENT_SEV_TERM -- một khách AMD SEV đã yêu cầu chấm dứt.
   Địa chỉ vật lý của khách GHCB của khách được lưu trữ trong ZZ0000ZZ.
 - KVM_SYSTEM_EVENT_TDX_FATAL -- khách TDX đã báo cáo trạng thái lỗi nghiêm trọng.
   KVM không thực hiện bất kỳ phân tích cú pháp hoặc chuyển đổi nào, nó chỉ chứa 16 mục đích chung
   đăng ký vào không gian người dùng, theo thứ tự tăng dần của các chỉ số 4 bit cho x86-64
   các thanh ghi có mục đích chung trong mã hóa lệnh, như được định nghĩa trong Intel
   SDM.
 - KVM_SYSTEM_EVENT_WAKEUP -- vCPU đang thoát ở trạng thái treo và
   KVM đã nhận ra một sự kiện đánh thức. Không gian người dùng có thể vinh danh sự kiện này bằng cách
   đánh dấu vCPU đang thoát là có thể chạy được hoặc từ chối nó và gọi lại KVM_RUN.
 - KVM_SYSTEM_EVENT_SUSPEND -- khách đã yêu cầu tạm dừng
   máy ảo.

Nếu có KVM_CAP_SYSTEM_EVENT_DATA, trường 'dữ liệu' có thể chứa
thông tin cụ thể về kiến trúc cho sự kiện cấp hệ thống.  Chỉ
các mục ZZ0000ZZ đầu tiên (có thể bằng 0) của mảng dữ liệu là hợp lệ.

- đối với arm64, data[0] được đặt thành KVM_SYSTEM_EVENT_RESET_FLAG_PSCI_RESET2 nếu
   khách đã thực hiện cuộc gọi SYSTEM_RESET2 theo v1.1 của PSCI
   đặc điểm kỹ thuật.

- đối với arm64, dữ liệu [0] được đặt thành KVM_SYSTEM_EVENT_SHUTDOWN_FLAG_PSCI_OFF2
   nếu khách thực hiện cuộc gọi SYSTEM_OFF2 theo v1.3 của PSCI
   đặc điểm kỹ thuật.

- đối với RISC-V, dữ liệu [0] được đặt thành giá trị của đối số thứ hai của
   Cuộc gọi ZZ0000ZZ.

Các phiên bản trước của Linux đã xác định thành viên ZZ0000ZZ trong cấu trúc này.  các
trường hiện được đặt bí danh là ZZ0001ZZ.  Không gian người dùng có thể cho rằng nó chỉ
được viết nếu ndata lớn hơn 0.

Đối với cánh tay/cánh tay64:
----------------------------

Các lối thoát KVM_SYSTEM_EVENT_SUSPEND được kích hoạt bằng
Khả năng máy ảo KVM_CAP_ARM_SYSTEM_SUSPEND. Nếu khách gọi PSCI
Chức năng SYSTEM_SUSPEND, KVM sẽ thoát khỏi không gian người dùng với sự kiện này
loại.

Trách nhiệm duy nhất của không gian người dùng là triển khai PSCI
SYSTEM_SUSPEND gọi theo ARM DEN0022D.b 5.19 "SYSTEM_SUSPEND".
KVM không thay đổi trạng thái của vCPU trước khi thoát khỏi không gian người dùng, vì vậy
các tham số cuộc gọi được giữ nguyên trong sổ đăng ký vCPU.

Không gian người dùng _bắt buộc_ phải thực hiện hành động để thoát ra như vậy. Nó phải
hoặc:

- Tôn trọng yêu cầu của khách về việc tạm dừng VM. Không gian người dùng có thể yêu cầu
   mô phỏng hệ thống treo trong kernel bằng cách thiết lập vCPU đang gọi
   trạng thái thành KVM_MP_STATE_SUSPENDED. Không gian người dùng phải định cấu hình vCPU
   trạng thái theo các tham số được truyền cho hàm PSCI khi
   vCPU đang gọi được tiếp tục. Xem ARM DEN0022D.b 5.19.1 "Mục đích sử dụng"
   để biết chi tiết về các tham số chức năng.

- Từ chối yêu cầu của khách về việc tạm dừng VM. Xem ARM DEN0022D.b 5.19.2
   "Trách nhiệm của người gọi" đối với các giá trị trả về có thể có.

Chế độ ngủ đông bằng lệnh gọi PSCI SYSTEM_OFF2 được bật khi PSCI v1.3
được kích hoạt. Nếu khách gọi hàm PSCI SYSTEM_OFF2, KVM sẽ
thoát khỏi không gian người dùng với loại sự kiện KVM_SYSTEM_EVENT_SHUTDOWN và với
dữ liệu [0] được đặt thành KVM_SYSTEM_EVENT_SHUTDOWN_FLAG_PSCI_OFF2. duy nhất
loại ngủ đông được hỗ trợ cho chức năng SYSTEM_OFF2 là HIBERNATE_OFF.

::

/* KVM_EXIT_IOAPIC_EOI */
		cấu trúc {
			__u8 vectơ;
		} eoi;

Cho biết rằng APIC cục bộ trong nhân của VCPU đã nhận được EOI cho một
ngắt IOAPIC được kích hoạt theo mức.  Lối thoát này chỉ kích hoạt khi
IOAPIC được triển khai trong không gian người dùng (tức là KVM_CAP_SPLIT_IRQCHIP được bật);
không gian người dùng IOAPIC sẽ xử lý EOI và kích hoạt lại ngắt nếu
nó vẫn được khẳng định.  Vector là vectơ ngắt LAPIC mà đối với nó
EOI đã được nhận.

::

cấu trúc kvm_hyperv_exit {
  #define KVM_EXIT_HYPERV_SYNIC 1
  #define KVM_EXIT_HYPERV_HCALL 2
  #define KVM_EXIT_HYPERV_SYNDBG 3
			__u32 loại;
			__u32 pad1;
			công đoàn {
				cấu trúc {
					__u32 msr;
					__u32 pad2;
					__u64 điều khiển;
					__u64 evt_page;
					__u64 tin nhắn_page;
				} đồng bộ;
				cấu trúc {
					__u64 đầu vào;
					__u64 kết quả;
					__u64 thông số[2];
				} hcall;
				cấu trúc {
					__u32 msr;
					__u32 pad2;
					__u64 điều khiển;
					trạng thái __u64;
					__u64 send_page;
					__u64 recv_page;
					__u64 đang chờ xử lý_page;
				} syndbg;
			} bạn;
		};
		/* KVM_EXIT_HYPERV */
                cấu trúc kvm_hyperv_exit hyperv;

Cho biết VCPU thoát vào không gian người dùng để xử lý một số tác vụ
liên quan đến mô phỏng Hyper-V.

Các giá trị hợp lệ cho 'loại' là:

- KVM_EXIT_HYPERV_SYNIC -- thông báo đồng bộ về không gian người dùng

Thay đổi trạng thái Hyper-V SynIC. Thông báo được sử dụng để ánh xạ lại SynIC
trang sự kiện/thông báo và bật/tắt việc xử lý thông báo/sự kiện SynIC
trong không gian người dùng.

- KVM_EXIT_HYPERV_SYNDBG -- thông báo đồng bộ về không gian người dùng

Thay đổi trạng thái trình gỡ lỗi tổng hợp Hyper-V. Thông báo được sử dụng để cập nhật
vị trí trang đang chờ xử lý hoặc để gửi lệnh điều khiển (gửi bộ đệm được định vị
trong send_page hoặc recv bộ đệm tới recv_page).

::

/*KVM_EXIT_ARM_NISV / KVM_EXIT_ARM_LDST64B */
		cấu trúc {
			__u64 esr_iss;
			__u64 lỗi_ipa;
		} arm_nisv;

-KVM_EXIT_ARM_NISV:

Được sử dụng trên hệ thống arm64. Nếu khách truy cập vào bộ nhớ không phải trong memslot,
KVM thường sẽ quay trở lại không gian người dùng và yêu cầu nó thực hiện mô phỏng MMIO trên
thay mặt. Tuy nhiên, đối với một số loại lệnh nhất định, không có lệnh giải mã nào
(hướng, độ dài truy cập bộ nhớ) được cung cấp, tìm nạp và giải mã
lệnh từ VM quá phức tạp để tồn tại trong kernel.

Trong lịch sử, khi tình huống này xảy ra, KVM sẽ in cảnh báo và tiêu diệt
máy ảo. KVM giả định rằng nếu khách truy cập vào bộ nhớ không phải memslot thì đó là
đang cố gắng thực hiện I/O, việc này không thể mô phỏng được và thông báo cảnh báo là
được diễn đạt tương ứng. Tuy nhiên, điều xảy ra thường xuyên hơn là lỗi của khách
gây ra sự truy cập bên ngoài vùng bộ nhớ của khách, điều này sẽ dẫn đến nhiều hơn
thông báo cảnh báo có ý nghĩa và hủy bỏ bên ngoài đối với khách, nếu quyền truy cập
không nằm trong cửa sổ I/O.

Việc triển khai không gian người dùng có thể truy vấn KVM_CAP_ARM_NISV_TO_USER và kích hoạt
khả năng này khi tạo VM. Một khi điều này được thực hiện, những loại lỗi này sẽ
thay vào đó hãy quay lại không gian người dùng bằng KVM_EXIT_ARM_NISV, với các bit hợp lệ từ
ESR_EL2 trong trường esr_iss và IPA bị lỗi trong trường error_ipa.
Không gian người dùng có thể sửa chữa quyền truy cập nếu đó thực sự là quyền truy cập I/O bằng cách
giải mã lệnh từ bộ nhớ khách (nếu rất dũng cảm) và tiếp tục
thực thi khách hoặc có thể quyết định tạm dừng, kết xuất hoặc khởi động lại khách.

Lưu ý rằng KVM không bỏ qua hướng dẫn báo lỗi như đối với
KVM_EXIT_MMIO, nhưng không gian người dùng phải mô phỏng mọi thay đổi đối với trạng thái xử lý
nếu nó quyết định giải mã và mô phỏng lệnh.

Tính năng này không khả dụng đối với các máy ảo được bảo vệ vì không gian người dùng không có
có quyền truy cập vào trạng thái cần thiết để thực hiện mô phỏng.
Thay vào đó, một ngoại lệ hủy bỏ dữ liệu sẽ được đưa trực tiếp vào máy khách.
Lưu ý rằng mặc dù KVM_CAP_ARM_NISV_TO_USER sẽ được báo cáo nếu
được truy vấn bên ngoài bối cảnh VM được bảo vệ, tính năng này sẽ không được
bị lộ nếu được truy vấn trên bộ mô tả tệp VM được bảo vệ.

-KVM_EXIT_ARM_LDST64B:

Được sử dụng trên hệ thống arm64. Khi khách sử dụng LD64B, ST64B, ST64BV, ST64BV0,
bên ngoài memslot, KVM sẽ quay trở lại không gian người dùng với KVM_EXIT_ARM_LDST64B,
làm lộ thông tin ESR_EL2 có liên quan và gây lỗi cho IPA, tương tự như
KVM_EXIT_ARM_NISV.

Không gian người dùng phải mô phỏng đầy đủ các hướng dẫn, bao gồm:

- tìm nạp các toán hạng cho một cửa hàng, bao gồm ACCDATA_EL1 trong trường hợp
	  của lệnh ST64BV0
	- giải quyết vấn đề cuối cùng nếu khách là người lớn tuổi
	- mô phỏng quyền truy cập, bao gồm cả việc cung cấp một ngoại lệ nếu
	  truy cập không thành công
	- cung cấp giá trị trả về trong trường hợp ST64BV/ST64BV0
	- trả về dữ liệu trong trường hợp tải
	- tăng PC nếu lệnh được thực hiện thành công

Lưu ý rằng không có kỳ vọng nào về hiệu suất của mô phỏng này vì nó
liên quan đến một số lượng lớn các tương tác với trạng thái khách. Tuy nhiên, đó là
mong đợi rằng ngữ nghĩa của lệnh được bảo toàn, đặc biệt là
thuộc tính nguyên tử một bản sao của quyền truy cập 64 byte.

Lý do thoát này phải được xử lý nếu không gian người dùng đặt ID_AA64ISAR1_EL1.LS64 thành
giá trị khác 0, cho biết FEAT_LS64* đã được bật.

::

/*KVM_EXIT_X86_RDMSR / KVM_EXIT_X86_WRMSR */
		cấu trúc {
			__u8 lỗi; /*người dùng -> hạt nhân */
			__u8 đệm[7];
			__u32 lý do; /* hạt nhân -> người dùng */
			chỉ số __u32; /* hạt nhân -> người dùng */
			__u64 dữ liệu; /* hạt nhân <-> người dùng */
		} msr;

Được sử dụng trên hệ thống x86. Khi khả năng VM KVM_CAP_X86_USER_SPACE_MSR là
được bật, MSR truy cập vào các thanh ghi sẽ gọi #GP bằng mã hạt nhân KVM
thay vào đó có thể kích hoạt lối thoát KVM_EXIT_X86_RDMSR để đọc và KVM_EXIT_X86_WRMSR
thoát để viết.

Trường "lý do" chỉ định lý do xảy ra việc chặn MSR. Không gian người dùng sẽ
chỉ nhận được các lần thoát MSR khi một lý do cụ thể được yêu cầu trong suốt quá trình
ENABLE_CAP. Các lý do thoát hợp lệ hiện tại là:

=========================================================================
 KVM_MSR_EXIT_REASON_UNKNOWN truy cập vào MSR mà KVM chưa biết
 KVM_MSR_EXIT_REASON_INVAL truy cập vào các MSR không hợp lệ hoặc các bit dành riêng
 Truy cập KVM_MSR_EXIT_REASON_FILTER bị chặn bởi KVM_X86_SET_MSR_FILTER
=========================================================================

Đối với KVM_EXIT_X86_RDMSR, trường "chỉ mục" cho biết không gian người dùng MSR nào là khách
muốn đọc. Để đáp ứng yêu cầu này bằng một lần đọc thành công, không gian người dùng
ghi dữ liệu tương ứng vào trường "dữ liệu" và phải tiếp tục
thực thi để đảm bảo dữ liệu đã đọc được chuyển sang trạng thái đăng ký khách.

Nếu yêu cầu RDMSR không thành công, không gian người dùng sẽ chỉ ra rằng với số "1" trong
trường "lỗi". Điều này sẽ đưa #GP vào khách khi VCPU được
được thực hiện lại.

Đối với KVM_EXIT_X86_WRMSR, trường "chỉ mục" cho biết không gian người dùng MSR nào là khách
muốn viết. Sau khi xử lý xong sự kiện, không gian người dùng phải tiếp tục
thực thi vCPU. Nếu quá trình ghi MSR không thành công, không gian người dùng cũng đặt
trường "lỗi" thành "1".

Xem KVM_X86_SET_MSR_FILTER để biết chi tiết về tương tác với bộ lọc MSR.

::


cấu trúc kvm_xen_exit {
  #define KVM_EXIT_XEN_HCALL 1
			__u32 loại;
			công đoàn {
				cấu trúc {
					__u32 mã dài;
					__u32 cpl;
					__u64 đầu vào;
					__u64 kết quả;
					__u64 thông số[6];
				} hcall;
			} bạn;
		};
		/* KVM_EXIT_XEN */
                struct kvm_hyperv_exit xen;

Cho biết VCPU thoát vào không gian người dùng để xử lý một số tác vụ
liên quan đến mô phỏng Xen.

Các giá trị hợp lệ cho 'loại' là:

- KVM_EXIT_XEN_HCALL -- thông báo đồng bộ cho không gian người dùng về siêu cuộc gọi Xen.
    Không gian người dùng dự kiến sẽ đặt kết quả hypercall vào vị trí thích hợp
    trường trước khi gọi lại KVM_RUN.

::

/* KVM_EXIT_RISCV_SBI */
		cấu trúc {
			phần mở rộng_id dài không dấu;
			hàm_id dài không dấu;
			đối số dài không dấu [6];
			ret dài không dấu[2];
		} riscv_sbi;

Nếu lý do thoát là KVM_EXIT_RISCV_SBI thì nó chỉ ra rằng VCPU có
đã thực hiện cuộc gọi SBI không được mô-đun hạt nhân KVM RISC-V xử lý. Các chi tiết
của cuộc gọi SBI có sẵn trong thành viên 'riscv_sbi' của cấu trúc kvm_run. các
Trường 'extension_id' của 'riscv_sbi' đại diện cho ID tiện ích mở rộng SBI trong khi trường
Trường 'function_id' biểu thị ID chức năng của tiện ích mở rộng SBI nhất định. Các 'args'
trường mảng của 'riscv_sbi' biểu thị các tham số cho lệnh gọi SBI và 'ret'
trường mảng đại diện cho các giá trị trả về. Không gian người dùng sẽ cập nhật lợi nhuận
các giá trị của SBI gọi trước khi tiếp tục VCPU. Để biết thêm chi tiết về RISC-V SBI
tham khảo thông số kỹ thuật, ZZ0000ZZ

::

/* KVM_EXIT_MEMORY_FAULT */
		cấu trúc {
  #define KVM_MEMORY_EXIT_FLAG_PRIVATE (1ULL << 3)
			__u64 cờ;
			__u64 gpa;
			__u64 kích thước;
		} bộ nhớ_fault;

KVM_EXIT_MEMORY_FAULT cho biết vCPU đã gặp lỗi bộ nhớ
không thể giải quyết được bằng KVM.  'gpa' và 'size' (tính bằng byte) mô tả
phạm vi địa chỉ vật lý của khách [gpa, gpa + size) của lỗi.  Trường 'cờ'
mô tả các thuộc tính của quyền truy cập bị lỗi có thể thích hợp:

- KVM_MEMORY_EXIT_FLAG_PRIVATE - Khi được đặt, cho biết đã xảy ra lỗi bộ nhớ
   trên một truy cập bộ nhớ riêng tư.  Khi xóa, cho biết lỗi xảy ra trên một
   quyền truy cập được chia sẻ.

Ghi chú!  KVM_EXIT_MEMORY_FAULT là lý do duy nhất trong số tất cả các lý do thoát khỏi KVM ở chỗ nó
kèm theo mã trả về là '-1', không phải '0'!  errno sẽ luôn được đặt thành EFAULT
hoặc EHWPOISON khi KVM thoát với KVM_EXIT_MEMORY_FAULT, không gian người dùng sẽ giả định
kvm_run.exit_reason đã cũ/không xác định đối với tất cả các số lỗi khác.

::

/* KVM_EXIT_NOTIFY */
    cấu trúc {
  #define KVM_NOTIFY_CONTEXT_INVALID (1 << 0)
      __u32 cờ;
    } thông báo;

Được sử dụng trên hệ thống x86. Khi khả năng VM KVM_CAP_X86_NOTIFY_VMEXIT là
được bật, lối thoát VM được tạo nếu không có cửa sổ sự kiện nào xảy ra ở chế độ không phải root của VM
trong một khoảng thời gian nhất định. Khi KVM_X86_NOTIFY_VMEXIT_USER được đặt khi
bật giới hạn, nó sẽ thoát ra không gian người dùng với lý do thoát
KVM_EXIT_NOTIFY để xử lý thêm. Trường "cờ" chứa nhiều hơn
thông tin chi tiết.

Giá trị hợp lệ cho 'cờ' là:

- KVM_NOTIFY_CONTEXT_INVALID -- bối cảnh VM bị hỏng và không hợp lệ
    trong VMCS. Nó sẽ có kết quả không xác định nếu tiếp tục VM mục tiêu.

::

/* KVM_EXIT_TDX */
		cấu trúc {
			__u64 cờ;
			__u64 nr;
			công đoàn {
				cấu trúc {
					u64 ret;
					dữ liệu u64[5];
				} không xác định;
				cấu trúc {
					u64 ret;
					u64 gpa;
					kích thước u64;
				} get_quote;
				cấu trúc {
					u64 ret;
					lá u64;
					u64 r11, r12, r13, r14;
				} get_tdvmcall_info;
				cấu trúc {
					u64 ret;
					vectơ u64;
				} setup_event_notify;
			};
		} tdx;

Xử lý TDVMCALL từ khách.  Chuyển tiếp KVM chọn dựa trên TDVMCALL
về thông số kỹ thuật Giao diện giao tiếp khách-Hypervisor (GHCI);
KVM kết nối các yêu cầu này với không gian người dùng VMM với những thay đổi tối thiểu,
đặt các đầu vào vào liên kết và sao chép chúng lại cho khách
khi tái nhập cảnh.

Cờ hiện tại luôn bằng 0, trong khi ZZ0000ZZ chứa TDVMCALL
số từ thanh ghi R11.  Lĩnh vực còn lại của liên minh cung cấp
đầu vào và đầu ra của TDVMCALL.  Hiện tại các giá trị sau của
ZZ0001ZZ được định nghĩa:

* ZZ0000ZZ: khách đã yêu cầu tạo TD-Quote
   được ký bởi dịch vụ lưu trữ TD-Quoting Enclave hoạt động trên máy chủ.
   Các tham số và giá trị trả về nằm trong trường ZZ0001ZZ của liên kết.
   Trường ZZ0002ZZ và ZZ0003ZZ chỉ định địa chỉ vật lý của khách
   (không có tập bit chia sẻ) và kích thước của bộ đệm bộ nhớ dùng chung, trong
   mà khách TDX vượt qua Báo cáo TD.  Trường ZZ0004ZZ đại diện cho
   giá trị trả về của yêu cầu GetQuote.  Khi yêu cầu đã được
   được xếp hàng thành công, khách TDX có thể thăm dò trường trạng thái trong
   vùng bộ nhớ dùng chung để kiểm tra xem việc tạo Báo giá đã hoàn thành hay chưa
   không. Khi hoàn thành, Báo giá đã tạo sẽ được trả về qua cùng một bộ đệm.

* ZZ0000ZZ: khách đã yêu cầu hỗ trợ
   trạng thái của TDVMCALL.  Các giá trị đầu ra cho lá nhất định phải là
   được đặt trong các trường từ ZZ0001ZZ đến ZZ0002ZZ của ZZ0003ZZ
   lĩnh vực của công đoàn.

* ZZ0000ZZ: khách đã yêu cầu
   thiết lập ngắt thông báo cho vector ZZ0001ZZ.

KVM có thể thêm hỗ trợ cho nhiều giá trị hơn trong tương lai, điều này có thể gây ra không gian người dùng
thoát, ngay cả khi không có lệnh gọi tới ZZ0000ZZ hoặc tương tự.  Trong trường hợp này,
nó sẽ nhập với các trường đầu ra đã hợp lệ; trong trường hợp thông thường thì
Trường ZZ0001ZZ của liên minh sẽ là ZZ0002ZZ.
Không gian người dùng không cần phải làm bất cứ điều gì nếu không muốn hỗ trợ TDVMCALL.

::

/* KVM_EXIT_ARM_SEA */
		cấu trúc {
  #define KVM_EXIT_ARM_SEA_FLAG_GPA_VALID (1ULL << 0)
			__u64 cờ;
			__u64 esr;
			__u64 gva;
			__u64 gpa;
		} arm_sea;

Được sử dụng trên hệ thống arm64. Khi khả năng VM ZZ0000ZZ là
được bật, KVM sẽ thoát khỏi không gian người dùng nếu quyền truy cập của khách gây ra sự đồng bộ
hủy bỏ bên ngoài (SEA) và máy chủ APEI không xử lý được SEA.

ZZ0000ZZ được đặt thành giá trị được khử trùng là ESR_EL2 từ ngoại lệ được đưa đến KVM,
gồm các trường sau:

-ZZ0000ZZ
 -ZZ0001ZZ
 -ZZ0002ZZ
 -ZZ0003ZZ
 -ZZ0004ZZ
 -ZZ0005ZZ
 -ZZ0006ZZ
 - ZZ0007ZZ (khi FEAT_RAS được triển khai cho VM)

ZZ0000ZZ được đặt thành giá trị FAR_EL2 từ ngoại lệ được đưa đến KVM khi
ZZ0001ZZ. Mặt khác, giá trị của ZZ0002ZZ không xác định.

ZZ0000ZZ được đặt thành IPA bị lỗi từ ngoại lệ được đưa đến KVM khi
cờ ZZ0001ZZ được đặt. Ngược lại, giá trị của
ZZ0002ZZ chưa được biết.

::

/* Cố định kích thước của liên kết. */
		phần đệm char[256];
	};

/*
	 * đăng ký chia sẻ giữa kvm và không gian người dùng.
	 * kvm_valid_regs chỉ định các lớp đăng ký do máy chủ đặt
	 * kvm_dirty_regs đã chỉ định các lớp đăng ký bị làm bẩn bởi không gian người dùng
	 * struct kvm_sync_regs là kiến trúc cụ thể, cũng như
	 * bit cho kvm_valid_regs và kvm_dirty_regs
	 */
	__u64 kvm_valid_regs;
	__u64 kvm_dirty_regs;
	công đoàn {
		struct kvm_sync_regs reg;
		phần đệm char [SYNC_REGS_SIZE_BYTES];
	} s;

Nếu KVM_CAP_SYNC_REGS được xác định, các trường này cho phép không gian người dùng truy cập
một số khách đăng ký mà không cần phải gọi SET/GET_*REGS. Như vậy chúng ta có thể
tránh một số chi phí cuộc gọi hệ thống nếu không gian người dùng phải xử lý việc thoát.
Không gian người dùng có thể truy vấn tính hợp lệ của cấu trúc bằng cách kiểm tra
kvm_valid_regs cho các bit cụ thể. Các bit này có kiến trúc cụ thể
và thường xác định tính hợp lệ của một nhóm thanh ghi. (ví dụ: một chút
cho các thanh ghi mục đích chung)

Xin lưu ý rằng kernel được phép sử dụng cấu trúc kvm_run làm
lưu trữ chính cho các loại thanh ghi nhất định. Vì vậy, kernel có thể sử dụng
giá trị trong kvm_run ngay cả khi bit tương ứng trong kvm_dirty_regs không được đặt.

::

/* KVM_EXIT_SNP_REQ_CERTS */
		cấu trúc kvm_exit_snp_req_certs {
			__u64 gpa;
			__u64 ntrang;
			__u64 ret;
		};

KVM_EXIT_SNP_REQ_CERTS biểu thị khách SEV-SNP đang tìm nạp chứng chỉ
đã bật (xem KVM_SEV_SNP_ENABLE_REQ_CERTS) đã tạo Khách mở rộng
Yêu cầu NAE #ZZ0005ZZ (SNP_GUEST_REQUEST) với loại tin nhắn MSG_REPORT_REQ,
tức là đã yêu cầu báo cáo chứng thực từ chương trình cơ sở và muốn
dữ liệu chứng chỉ tương ứng với chữ ký báo cáo chứng thực được
được cung cấp bởi hypervisor như một phần của yêu cầu.

Để cho phép không gian người dùng cung cấp chứng chỉ, 'gpa' và 'npages'
được chuyển tiếp nguyên văn từ yêu cầu của khách (các trường RAX và RBX GHCB
tương ứng).  'ret' không phải là "đầu ra" từ KVM và luôn bật '0'
thoát ra.  KVM xác minh 'gpa' được căn chỉnh 4KiB trước khi thoát khỏi không gian người dùng,
nhưng nếu không thì thông tin từ khách sẽ không được xác thực.

Trên KVM_RUN tiếp theo, ví dụ: sau khi không gian người dùng đã phục vụ yêu cầu (hoặc không),
KVM sẽ hoàn thành #ZZ0002ZZ, sử dụng trường 'ret' để xác định xem có nên
báo hiệu thành công hay thất bại cho khách và nếu thất bại, mã lý do sẽ là gì
được liên lạc qua SW_EXITINFO2.  Nếu 'ret' được đặt thành giá trị không được hỗ trợ (xem
bảng bên dưới), KVM_RUN sẽ thất bại với -EINVAL.  Đối với 'ret' của 'ENOSPC', KVM
cũng sử dụng trường 'npages', tức là không gian người dùng có thể sử dụng trường này để thông báo
khách về số lượng trang cần thiết để chứa tất cả dữ liệu chứng chỉ.

Các giá trị 'ret' được hỗ trợ và mã hóa SW_EXITINFO2 tương ứng của chúng:

====== ===================================================================
  0 0x0, tức là thành công.  KVM sẽ phát ra lệnh SNP_GUEST_REQUEST
             sang phần mềm SNP.
  ENOSPC 0x0000000100000000, tức là không đủ trang khách để giữ
             bảng chứng chỉ và dữ liệu chứng chỉ.  KVM cũng sẽ thiết lập
             Trường RBX trong GHBC tới 'npages'.
  EAGAIN 0x0000000200000000, tức là chủ nhà đang bận và khách nên
             thử lại yêu cầu.
  EIO 0xffffffff00000000, đối với tất cả các lỗi khác (mã trả về này là
             giá trị bộ ảo hóa do KVM xác định, được GHCB cho phép)
  ====== ===================================================================


.. _cap_enable:

6. Các khả năng có thể được kích hoạt trên vCPU
===============================================

Có một số khả năng nhất định có thể thay đổi hành vi của CPU ảo hoặc
máy ảo khi được kích hoạt. Để kích hoạt chúng, vui lòng xem
ZZ0000ZZ.

Dưới đây bạn có thể tìm thấy danh sách các khả năng và tác dụng của chúng đối với vCPU hoặc
máy ảo là khi kích hoạt chúng.

Các thông tin sau được cung cấp cùng với mô tả:

Kiến trúc:
      kiến trúc tập lệnh nào cung cấp ioctl này.
      x86 bao gồm cả i386 và x86_64.

Mục tiêu:
      cho dù đây là khả năng trên mỗi vcpu hay mỗi vm.

Thông số:
      những thông số nào được chấp nhận bởi khả năng.

Trả về:
      giá trị trả về.  Số lỗi chung (EBADF, ENOMEM, EINVAL)
      không chi tiết nhưng có những lỗi có ý nghĩa cụ thể.


6.1 KVM_CAP_PPC_OSI
-------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Thông số: không có
:Trả về: 0 nếu thành công; -1 do lỗi

Khả năng này cho phép chặn các siêu cuộc gọi OSI mà nếu không sẽ
được coi như các lệnh gọi hệ thống thông thường được đưa vào máy khách. Siêu cuộc gọi OSI
được Mac-on-Linux phát minh để có cơ chế giao tiếp được tiêu chuẩn hóa
giữa khách và chủ.

Khi khả năng này được bật, KVM_EXIT_OSI có thể xảy ra.


6.2 KVM_CAP_PPC_PAPR
--------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Thông số: không có
:Trả về: 0 nếu thành công; -1 do lỗi

Khả năng này cho phép chặn các siêu cuộc gọi PAPR. Siêu cuộc gọi PAPR là
được thực hiện bằng lệnh hypercall "sc 1".

Nó cũng đặt mức đặc quyền của khách thành chế độ "người giám sát". Thông thường khách
chạy ở chế độ đặc quyền "hypervisor" với một số tính năng bị thiếu.

Ngoài những điều trên, nó còn thay đổi ngữ nghĩa của SDR1. Ở chế độ này,
Phần địa chỉ HTAB của SDR1 chứa HVA thay vì GPA, vì PAPR giữ địa chỉ
HTAB vô hình đối với khách.

Khi khả năng này được bật, KVM_EXIT_PAPR_HCALL có thể xảy ra.


6.3 KVM_CAP_SW_TLB
------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Parameters: args[0] là địa chỉ của struct kvm_config_tlb
:Trả về: 0 nếu thành công; -1 do lỗi

::

cấu trúc kvm_config_tlb {
	__u64 thông số;
	__u64 mảng;
	__u32 mmu_type;
	__u32 mảng_len;
  };

Định cấu hình mảng TLB của CPU ảo, thiết lập vùng bộ nhớ dùng chung
giữa không gian người dùng và KVM.  Các trường "params" và "array" là không gian người dùng
địa chỉ của cấu trúc dữ liệu dành riêng cho loại mmu.  Trường "array_len" là một
cơ chế an toàn và phải được đặt ở kích thước tính bằng byte của bộ nhớ
không gian người dùng đã dành riêng cho mảng.  Nó ít nhất phải có kích thước quy định
bởi "mmu_type" và "params".

Trong khi KVM_RUN hoạt động, vùng chia sẻ nằm dưới sự kiểm soát của KVM.  của nó
nội dung không được xác định và bất kỳ sửa đổi nào bởi không gian người dùng đều dẫn đến
hành vi không xác định rõ ràng.

Khi trở về từ KVM_RUN, vùng chia sẻ sẽ phản ánh trạng thái hiện tại của
TLB của khách.  Nếu không gian người dùng thực hiện bất kỳ thay đổi nào, nó phải gọi KVM_DIRTY_TLB
để cho KVM biết những mục nào đã được thay đổi, trước khi gọi lại KVM_RUN
trên vcpu này.

Đối với loại mmu KVM_MMU_FSL_BOOKE_NOHV và KVM_MMU_FSL_BOOKE_HV:

- Trường "params" thuộc loại "struct kvm_book3e_206_tlb_params".
 - Trường "array" trỏ đến một mảng kiểu "struct
   kvm_book3e_206_tlb_entry".
 - Mảng bao gồm tất cả các mục trong TLB đầu tiên, theo sau là tất cả
   các mục trong TLB thứ hai.
 - Trong TLB, các mục được sắp xếp trước bằng cách tăng số lượng đã đặt.  Trong vòng một
   được đặt, các mục được sắp xếp theo cách (tăng ESEL).
 - Hàm băm xác định số tập hợp trong TLB0 là: (MAS2 >> 12) & (num_sets - 1)
   trong đó "num_sets" là giá trị tlb_sizes[] chia cho giá trị tlb_ways[].
 - Trường tsize của mas1 phải được đặt thành 4K trên TLB0, mặc dù
   phần cứng bỏ qua giá trị này cho TLB0.

6.4 KVM_CAP_S390_CSS_SUPPORT
----------------------------

:Kiến trúc: s390
:Mục tiêu: vcpu
:Thông số: không có
:Trả về: 0 nếu thành công; -1 do lỗi

Khả năng này cho phép hỗ trợ xử lý các lệnh I/O kênh.

TEST PENDING INTERRUPTION và phần ngắt của TEST SUBCHANNEL là
được xử lý trong kernel, trong khi các lệnh I/O khác được chuyển đến không gian người dùng.

Khi khả năng này được bật, KVM_EXIT_S390_TSCH sẽ xuất hiện trên TEST
SUBCHANNEL chặn.

Lưu ý rằng mặc dù khả năng này được kích hoạt trên mỗi vcpu, nhưng toàn bộ
máy ảo bị ảnh hưởng.

6.5 KVM_CAP_PPC_EPR
-------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Parameters: args[0] xác định liệu cơ sở proxy có hoạt động hay không
:Trả về: 0 nếu thành công; -1 do lỗi

Khả năng này cho phép hoặc vô hiệu hóa việc phân phối các ngắt thông qua
cơ sở proxy bên ngoài.

Khi được bật (args[0] != 0), mỗi khi khách nhận được ngắt bên ngoài
được phân phối, nó sẽ tự động thoát vào không gian người dùng với lối thoát KVM_EXIT_EPR
để nhận vectơ ngắt trên cùng.

Khi bị tắt (args[0] == 0), hoạt động sẽ giống như cơ sở này không được hỗ trợ.

Khi khả năng này được bật, KVM_EXIT_EPR có thể xảy ra.

6.6 KVM_CAP_IRQ_MPIC
--------------------

:Kiến trúc: ppc
:Thông số: args[0] là fd thiết bị MPIC;
             args[1] là số MPIC CPU cho vcpu này

Khả năng này kết nối vcpu với thiết bị MPIC trong kernel.

6.7 KVM_CAP_IRQ_XICS
--------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Thông số: args[0] là fd thiết bị XICS;
             args[1] là số XICS CPU (ID máy chủ) cho vcpu này

Khả năng này kết nối vcpu với thiết bị XICS trong kernel.

6.8 KVM_CAP_S390_IRQCHIP
------------------------

:Kiến trúc: s390
:Mục tiêu: vm
:Thông số: không có

Khả năng này kích hoạt irqchip trong nhân cho s390. Vui lòng tham khảo
"4.24 KVM_CREATE_IRQCHIP" để biết chi tiết.

6.9 KVM_CAP_MIPS_FPU
--------------------

:Kiến trúc: mips
:Mục tiêu: vcpu
:Parameters: args[0] được dành riêng để sử dụng trong tương lai (phải là 0).

Khả năng này cho phép khách sử dụng Đơn vị dấu phẩy động của máy chủ. Nó
cho phép đặt bit Config1.FP để kích hoạt FPU trong máy khách. Một khi đây là
đã hoàn tất, các thanh ghi ZZ0000ZZ và ZZ0001ZZ có thể được
được truy cập (tùy thuộc vào chế độ đăng ký FPU của khách hiện tại) và Status.FR,
Các bit Config5.FRE có thể truy cập được thông qua KVM API và cả từ khách,
tùy thuộc vào việc chúng được FPU hỗ trợ.

6.10 KVM_CAP_MIPS_MSA
---------------------

:Kiến trúc: mips
:Mục tiêu: vcpu
:Parameters: args[0] được dành riêng để sử dụng trong tương lai (phải là 0).

Khả năng này cho phép khách sử dụng Kiến trúc MIPS SIMD (MSA).
Nó cho phép thiết lập bit Config3.MSAP để cho phép khách sử dụng MSA.
Khi việc này hoàn tất, ZZ0000ZZ và ZZ0001ZZ
các thanh ghi có thể được truy cập và bit Config5.MSAEn có thể được truy cập thông qua
KVM API và cả từ khách hàng.

6,74 KVM_CAP_SYNC_REGS
----------------------

:Kiến trúc: s390, x86
:Mục tiêu: s390: luôn được bật, x86: vcpu
:Thông số: không có
:Trả về: x86: KVM_CHECK_EXTENSION trả về một mảng bit cho biết thanh ghi nào
          bộ được hỗ trợ
          (các trường bit được xác định trong Arch/x86/include/uapi/asm/kvm.h).

Như đã mô tả ở trên trong thông tin cấu trúc kvm_sync_regs trong phần ZZ0000ZZ,
KVM_CAP_SYNC_REGS "cho phép [các] không gian người dùng truy cập vào một số sổ đăng ký khách nhất định
mà không cần phải gọi SET/GET_*REGS". Điều này làm giảm chi phí bằng cách loại bỏ
các lệnh gọi ioctl lặp đi lặp lại để cài đặt và/hoặc nhận các giá trị đăng ký. Đây là
đặc biệt quan trọng khi không gian người dùng đang ở trạng thái khách đồng bộ
sửa đổi, ví dụ: khi mô phỏng và/hoặc chặn các hướng dẫn trong
không gian người dùng.

Để biết thông tin cụ thể về s390, vui lòng tham khảo mã nguồn.

Đối với x86:

- có thể chọn các bộ thanh ghi được sao chép sang kvm_run
  theo không gian người dùng (thay vào đó là tất cả các bộ được sao chép cho mỗi lần thoát).
- vcpu_events có sẵn ngoài reg và sreg.

Đối với x86, trường 'kvm_valid_regs' của struct kvm_run bị quá tải thành
hoạt động như một trường mảng bit đầu vào được thiết lập bởi không gian người dùng để chỉ ra
bộ thanh ghi cụ thể sẽ được sao chép ở lần thoát tiếp theo.

Để cho biết khi nào không gian người dùng có các giá trị được sửa đổi cần được sao chép vào
vCPU, tất cả trường bitarray kiến trúc, 'kvm_dirty_regs' phải được đặt.
Việc này được thực hiện bằng cách sử dụng các bitflag tương tự như đối với trường 'kvm_valid_regs'.
Nếu dirty bit không được đặt thì giá trị bộ thanh ghi sẽ không được sao chép
vào vCPU ngay cả khi chúng đã được sửa đổi.

Các trường bit không được sử dụng trong mảng bit phải được đặt thành 0.

::

cấu trúc kvm_sync_regs {
        struct kvm_regs reg;
        struct kvm_sregs sregs;
        sự kiện struct kvm_vcpu_events;
  };

6,75 KVM_CAP_PPC_IRQ_XIVE
-------------------------

:Kiến trúc: ppc
:Mục tiêu: vcpu
:Thông số: args[0] là fd thiết bị XIVE;
             args[1] là số XIVE CPU (ID máy chủ) cho vcpu này

Khả năng này kết nối vcpu với thiết bị XIVE trong kernel.

6,76 KVM_CAP_HYPERV_SYNIC
-------------------------

:Kiến trúc: x86
:Mục tiêu: vcpu

Khả năng này, nếu KVM_CHECK_EXTENSION chỉ ra rằng nó là
có sẵn, có nghĩa là kernel có sự triển khai của
Bộ điều khiển ngắt tổng hợp Hyper-V (SynIC). Hyper-V SynIC là
được sử dụng để hỗ trợ trình điều khiển paravirt dành cho khách dựa trên Windows Hyper-V (VMBus).

Để sử dụng SynIC, nó phải được kích hoạt bằng cách cài đặt
khả năng thông qua KVM_ENABLE_CAP ioctl trên vcpu fd. Lưu ý rằng điều này
sẽ vô hiệu hóa việc sử dụng ảo hóa phần cứng APIC ngay cả khi được hỗ trợ
bởi CPU, vì nó không tương thích với hành vi SynIC auto-EOI.

6,77 KVM_CAP_HYPERV_SYNIC2
--------------------------

:Kiến trúc: x86
:Mục tiêu: vcpu

Khả năng này cho phép phiên bản mới hơn của ngắt tổng hợp Hyper-V
bộ điều khiển (SynIC).  Điểm khác biệt duy nhất với KVM_CAP_HYPERV_SYNIC là KVM
không xóa các trang cờ sự kiện và thông báo SynIC khi chúng được bật bởi
ghi vào các MSR tương ứng.

6,78 KVM_CAP_HYPERV_DIRECT_TLBFLUSH
-----------------------------------

:Kiến trúc: x86
:Mục tiêu: vcpu

Khả năng này cho thấy KVM chạy trên Hyper-V hypervisor
cho phép xả trực tiếp TLB cho khách của mình, nghĩa là xả TLB
siêu giám sát được xử lý bởi bộ ảo hóa cấp 0 (Hyper-V) bỏ qua KVM.
Do ABI khác nhau về các tham số hypercall giữa Hyper-V và
KVM, việc kích hoạt khả năng này sẽ vô hiệu hóa tất cả siêu cuộc gọi một cách hiệu quả
xử lý bởi KVM (vì một số siêu lệnh gọi KVM có thể bị coi nhầm là TLB
xóa các siêu lệnh bằng Hyper-V) để không gian người dùng sẽ vô hiệu hóa nhận dạng KVM
trong CPUID và chỉ hiển thị nhận dạng Hyper-V. Trong trường hợp này, khách
cho rằng nó đang chạy trên Hyper-V và chỉ sử dụng siêu lệnh Hyper-V.

6,79 KVM_CAP_HYPERV_ENFORCE_CPUID
---------------------------------

:Kiến trúc: x86
:Mục tiêu: vcpu

Khi được bật, KVM sẽ tắt các tính năng Hyper-V mô phỏng được cung cấp cho
khách theo các bit tính năng Hyper-V CPUID. Nếu không thì tất cả
Các tính năng Hyper-V hiện đang được triển khai sẽ được cung cấp vô điều kiện khi
Nhận dạng Hyper-V được đặt trong HYPERV_CPUID_INTERFACE (0x40000001)
lá.

6,80 KVM_CAP_ENFORCE_PV_FEATURE_CPUID
-------------------------------------

:Kiến trúc: x86
:Mục tiêu: vcpu

Khi được bật, KVM sẽ tắt các tính năng ảo hóa được cung cấp cho
khách theo các bit trong lá KVM_CPUID_FEATURES CPUID
(0x40000001). Nếu không, khách có thể sử dụng các tính năng ảo
bất kể điều gì thực sự đã được phơi bày qua chiếc lá CPUID.

.. _KVM_CAP_DIRTY_LOG_RING:


.. _cap_enable_vm:

7. Các khả năng có thể được kích hoạt trên máy ảo
=================================================

Có một số khả năng nhất định có thể thay đổi hành vi của máy ảo
máy khi được kích hoạt. Để kích hoạt chúng, vui lòng xem phần
ZZ0000ZZ. Dưới đây bạn có thể tìm thấy danh sách các khả năng và
tác dụng của chúng đối với VM là gì khi kích hoạt chúng.

Các thông tin sau được cung cấp cùng với mô tả:

Kiến trúc:
      kiến trúc tập lệnh nào cung cấp ioctl này.
      x86 bao gồm cả i386 và x86_64.

Thông số:
      những thông số nào được chấp nhận bởi khả năng.

Trả về:
      giá trị trả về.  Số lỗi chung (EBADF, ENOMEM, EINVAL)
      không chi tiết nhưng có những lỗi có ý nghĩa cụ thể.


7.1 KVM_CAP_PPC_ENABLE_HCALL
----------------------------

:Kiến trúc: ppc
:Parameters: args[0] là số hcall sPAPR;
	     args[1] là 0 để tắt, 1 để bật xử lý trong kernel

Khả năng này kiểm soát xem các siêu cuộc gọi sPAPR riêng lẻ (hcalls) hay không
có được xử lý bởi kernel hay không.  Kích hoạt hoặc vô hiệu hóa trong kernel
việc xử lý hcall có hiệu quả trên VM.  Khi sáng tạo, một
tập hợp hcall ban đầu được kích hoạt để xử lý trong kernel, điều này
bao gồm các hcalls mà trình xử lý trong kernel đã được triển khai
trước khi khả năng này được triển khai.  Nếu bị vô hiệu hóa, kernel sẽ
không cố gắng xử lý hcall, nhưng sẽ luôn thoát ra không gian người dùng
để xử lý nó.  Lưu ý rằng việc kích hoạt một số và
vô hiệu hóa những người khác trong nhóm hcalls liên quan, nhưng KVM không ngăn chặn
không gian người dùng khỏi việc đó.

Nếu số hcall được chỉ định không phải là số có in-kernel
triển khai, KVM_ENABLE_CAP ioctl sẽ không thành công với EINVAL
lỗi.

7.2 KVM_CAP_S390_USER_SIGP
--------------------------

:Kiến trúc: s390
:Thông số: không có

Khả năng này kiểm soát các đơn hàng SIGP nào sẽ được xử lý hoàn toàn trong người dùng
không gian. Khi kích hoạt khả năng này, mọi đơn hàng nhanh chóng sẽ được xử lý hoàn toàn
trong hạt nhân:

-SENSE
- SENSE RUNNING
- EXTERNAL CALL
- EMERGENCY SIGNAL
- CONDITIONAL EMERGENCY SIGNAL

Tất cả các lệnh khác sẽ được xử lý hoàn toàn trong không gian người dùng.

Chỉ các ngoại lệ hoạt động đặc quyền mới được kiểm tra trong kernel (hoặc thậm chí
trong phần cứng trước khi chặn). Nếu khả năng này không được kích hoạt,
cách xử lý đơn hàng SIGP cũ được sử dụng (một phần trong kernel và không gian người dùng).

7.3 KVM_CAP_S390_VECTOR_REGISTERS
---------------------------------

:Kiến trúc: s390
:Thông số: không có
:Trả về: 0 nếu thành công, giá trị âm nếu có lỗi

Cho phép sử dụng các thanh ghi vectơ được giới thiệu với bộ xử lý z13 và
cung cấp sự đồng bộ giữa không gian máy chủ và người dùng.  Sẽ
trả về -EINVAL nếu máy không hỗ trợ vectơ.

7.4 KVM_CAP_S390_USER_STSI
--------------------------

:Kiến trúc: s390
:Thông số: không có

Khả năng này cho phép các trình xử lý hậu kỳ cho lệnh STSI. Sau
xử lý ban đầu trong kernel, KVM thoát ra không gian người dùng với
KVM_EXIT_S390_STSI cho phép người dùng có không gian để chèn thêm dữ liệu.

Trước khi thoát khỏi không gian người dùng, trình xử lý kvm phải điền vào trường s390_stsi của
vcpu->chạy::

cấu trúc {
	__u64 địa chỉ;
	__u8 ar;
	__u8 dành riêng;
	__u8fc;
	__u8 sel1;
	__u16 sel2;
  } s390_stsi;

@addr - địa chỉ khách của STSI SYSIB
  @fc - mã chức năng
  @sel1 - bộ chọn 1
  @sel2 - bộ chọn 2
  @ar - số đăng ký truy cập

Trình xử lý KVM sẽ thoát khỏi không gian người dùng với rc = -EREMOTE.

7.5 KVM_CAP_SPLIT_IRQCHIP
-------------------------

:Kiến trúc: x86
:Parameters: args[0] - số tuyến dành riêng cho IOAPIIC không gian người dùng
:Trả về: 0 nếu thành công, -1 nếu có lỗi

Tạo một apic cục bộ cho mỗi bộ xử lý trong kernel. Điều này có thể được sử dụng
thay vì KVM_CREATE_IRQCHIP nếu không gian người dùng VMM muốn mô phỏng
IOAPIC và PIC (và cả PIT, mặc dù tính năng này phải được bật
riêng).

Khả năng này cũng cho phép định tuyến hạt nhân các yêu cầu ngắt;
khi KVM_CAP_SPLIT_IRQCHIP chỉ có các tuyến thuộc loại KVM_IRQ_ROUTING_MSI
được sử dụng trong bảng định tuyến IRQ.  Các tuyến args[0] MSI đầu tiên được bảo lưu
cho các chân IOAPIC.  Bất cứ khi nào LAPIC nhận được EOI cho các tuyến đường này,
vmexit KVM_EXIT_IOAPIC_EOI sẽ được báo cáo tới không gian người dùng.

Không thành công nếu VCPU đã được tạo hoặc nếu irqchip đã có trong
kernel (tức là KVM_CREATE_IRQCHIP đã được gọi).

7.6 KVM_CAP_S390_RI
-------------------

:Kiến trúc: s390
:Thông số: không có

Cho phép sử dụng công cụ thời gian chạy được giới thiệu với bộ xử lý zEC12.
Sẽ trả về -EINVAL nếu máy không hỗ trợ công cụ đo thời gian chạy.
Sẽ trả về -EBUSY nếu VCPU đã được tạo.

7.7 KVM_CAP_X2APIC_API
----------------------

:Kiến trúc: x86
:Parameters: args[0] - các tính năng nên được bật
:Trả về: 0 nếu thành công, -EINVAL khi args[0] chứa các tính năng không hợp lệ

Cờ tính năng hợp lệ trong args[0] là::

#define KVM_X2APIC_API_USE_32BIT_IDS (1ULL << 0)
  #define KVM_X2APIC_API_DISABLE_BROADCAST_QUIRK (1ULL << 1)
  #define KVM_X2APIC_ENABLE_SUPPRESS_EOI_BROADCAST (1ULL << 2)
  #define KVM_X2APIC_DISABLE_SUPPRESS_EOI_BROADCAST (1ULL << 3)

Kích hoạt KVM_X2APIC_API_USE_32BIT_IDS sẽ thay đổi hành vi của
KVM_SET_GSI_ROUTING, KVM_SIGNAL_MSI, KVM_SET_LAPIC và KVM_GET_LAPIC,
cho phép sử dụng ID APIC 32 bit.  Xem KVM_CAP_X2APIC_API trong
các phần tương ứng.

KVM_X2APIC_API_DISABLE_BROADCAST_QUIRK phải được kích hoạt để x2APIC hoạt động
ở chế độ logic hoặc với hơn 255 VCPU.  Ngược lại, KVM xử lý 0xff
như một chương trình phát sóng ngay cả ở chế độ x2APIC để hỗ trợ x2APIC vật lý
mà không bị gián đoạn ánh xạ lại.  Đây là điều không mong muốn trong chế độ logic,
trong đó 0xff đại diện cho CPU 0-7 trong cụm 0.

Cài đặt KVM_X2APIC_ENABLE_SUPPRESS_EOI_BROADCAST sẽ hướng dẫn KVM kích hoạt
Ngăn chặn chương trình phát sóng EOI.  KVM sẽ quảng cáo hỗ trợ cho Suppress EOI
Phát tới khách và chặn phát sóng LAPIC EOI khi khách
đặt bit Phát sóng EOI trong thanh ghi SPIV.  Lá cờ này là
chỉ được hỗ trợ khi sử dụng IRQCHIP tách.

Cài đặt KVM_X2APIC_DISABLE_SUPPRESS_EOI_BROADCAST sẽ tắt hỗ trợ cho
Ngăn chặn hoàn toàn các chương trình phát sóng EOI, tức là hướng dẫn KVM quảng cáo cho NOT
hỗ trợ cho khách.

Các VMM hiện đại nên kích hoạt KVM_X2APIC_ENABLE_SUPPRESS_EOI_BROADCAST
hoặc KVM_X2APIC_DISABLE_SUPPRESS_EOI_BROADCAST.  Nếu không, di sản kỳ quặc
hành vi sẽ được KVM sử dụng: ở chế độ IRQCHIP phân chia, KVM sẽ quảng cáo
hỗ trợ cho Chặn phát sóng EOI nhưng không thực sự chặn EOI
chương trình phát sóng; đối với chế độ IRQCHIP trong kernel, KVM sẽ không quảng cáo hỗ trợ cho
Ngăn chặn chương trình phát sóng EOI.

Đặt cả KVM_X2APIC_ENABLE_SUPPRESS_EOI_BROADCAST và
KVM_X2APIC_DISABLE_SUPPRESS_EOI_BROADCAST sẽ bị lỗi với lỗi EINVAL,
cũng như cài đặt KVM_X2APIC_ENABLE_SUPPRESS_EOI_BROADCAST mà không cần phân chia
IRCHIP.

7.8 KVM_CAP_S390_USER_INSTR0
----------------------------

:Kiến trúc: s390
:Thông số: không có

Khi khả năng này được bật, lệnh không hợp lệ 0x0000 (2 byte) sẽ
bị chặn và chuyển tiếp đến không gian người dùng. Không gian người dùng có thể sử dụng cái này
cơ chế, ví dụ: để nhận ra các điểm dừng phần mềm 2 byte. Hạt nhân sẽ
không đưa vào một ngoại lệ vận hành cho các hướng dẫn này, không gian người dùng có
để chăm sóc điều đó.

Khả năng này có thể được kích hoạt một cách linh hoạt ngay cả khi các VCPU đã được
đã tạo và đang chạy.

7.9 KVM_CAP_S390_GS
-------------------

:Kiến trúc: s390
:Thông số: không có
:Trả về: 0 nếu thành công; -EINVAL nếu máy không hỗ trợ
          lưu trữ có bảo vệ; -EBUSY nếu VCPU đã được tạo.

Cho phép sử dụng bộ lưu trữ được bảo vệ cho khách KVM.

7.10 KVM_CAP_S390_AIS
---------------------

:Kiến trúc: s390
:Thông số: không có

Cho phép sử dụng tính năng ngăn chặn gián đoạn bộ điều hợp.
:Trả về: 0 nếu thành công; -EBUSY nếu VCPU đã được tạo.

7.11 KVM_CAP_PPC_SMT
--------------------

:Kiến trúc: ppc
:Thông số: vsmt_mode, cờ

Việc kích hoạt khả năng này trên máy ảo sẽ cung cấp cho không gian người dùng một cách để thiết lập
chế độ SMT ảo mong muốn (tức là số lượng CPU ảo trên mỗi
lõi ảo).  Chế độ SMT ảo, vsmt_mode, phải có lũy thừa bằng 2
trong khoảng từ 1 đến 8. Trên POWER8, vsmt_mode cũng không được lớn hơn
số lượng luồng trên mỗi lõi con cho máy chủ.  Hiện nay cờ phải
là 0. Một cuộc gọi thành công để kích hoạt khả năng này sẽ dẫn đến
vsmt_mode được trả về khi có khả năng KVM_CAP_PPC_SMT
sau đó đã truy vấn VM.  Khả năng này chỉ được hỗ trợ bởi
HV KVM và chỉ có thể được đặt trước khi bất kỳ VCPU nào được tạo.
Khả năng KVM_CAP_PPC_SMT_POSSIBLE cho biết SMT ảo nào
các chế độ có sẵn.

7.12 KVM_CAP_PPC_FWNMI
----------------------

:Kiến trúc: ppc
:Thông số: không có

Với khả năng này, một ngoại lệ kiểm tra máy trong địa chỉ khách
khoảng trống sẽ khiến KVM thoát khỏi khách với lý do thoát NMI. Cái này
cho phép QEMU xây dựng nhật ký lỗi và phân nhánh cho kernel khách đã đăng ký
quy trình xử lý kiểm tra máy. Nếu không có khả năng này KVM sẽ
rẽ nhánh tới vectơ ngắt 0x200 của khách.

7.13 KVM_CAP_X86_DISABLE_EXITS
------------------------------

:Kiến trúc: x86
:Parameters: args[0] xác định lối thoát nào bị vô hiệu hóa
:Trả về: 0 nếu thành công, -EINVAL khi args[0] chứa các lần thoát không hợp lệ
          hoặc nếu có bất kỳ vCPU nào đã được tạo

Các bit hợp lệ trong args[0] là::

#define KVM_X86_DISABLE_EXITS_MWAIT (1 << 0)
  #define KVM_X86_DISABLE_EXITS_HLT (1 << 1)
  #define KVM_X86_DISABLE_EXITS_PAUSE (1 << 2)
  #define KVM_X86_DISABLE_EXITS_CSTATE (1 << 3)
  #define KVM_X86_DISABLE_EXITS_APERFMPERF (1 << 4)

Việc kích hoạt khả năng này trên máy ảo sẽ cung cấp cho người dùng một cách không
chặn một số hướng dẫn lâu hơn để cải thiện độ trễ ở một số
khối lượng công việc và được đề xuất khi vCPU được liên kết với các thiết bị chuyên dụng
CPU vật lý.  Nhiều bit hơn có thể được thêm vào trong tương lai; không gian người dùng có thể
chỉ cần chuyển kết quả KVM_CHECK_EXTENSION tới KVM_ENABLE_CAP để tắt
tất cả các vmexits như vậy.

Không bật KVM_FEATURE_PV_UNHALT nếu bạn tắt các lần thoát HLT.

Ảo hóa MSR ZZ0000ZZ và ZZ0001ZZ yêu cầu nhiều hơn
thay vì chỉ tắt các lối thoát APERF/MPERF. Trong khi cả Intel và AMD
ghi lại các điều kiện sử dụng nghiêm ngặt đối với các MSR này--nhấn mạnh rằng chỉ
tỷ lệ đồng bằng của chúng trong một khoảng thời gian (T0 đến T1) là
được xác định về mặt kiến trúc--chỉ cần đi qua MSR vẫn có thể
tạo ra một tỷ lệ không chính xác.

Tỷ lệ sai lầm này có thể xảy ra nếu giữa T0 và T1:

1. Luồng vCPU di chuyển giữa các bộ xử lý logic.
2. Hoạt động di chuyển trực tiếp hoặc tạm dừng/tiếp tục diễn ra.
3. Một tác vụ khác chia sẻ bộ xử lý logic của vCPU.
4. Các trạng thái C thấp hơn C0 được mô phỏng (ví dụ: thông qua việc chặn HLT).
5. Tần số TSC của khách không khớp với tần số TSC của máy chủ.

Do sự phức tạp này, KVM không tự động liên kết điều này
khả năng chuyển tiếp với bit CPUID khách,
ZZ0000ZZ. VMM không gian người dùng cho rằng điều này
cơ chế thích hợp để ảo hóa ZZ0001ZZ và
MSR ZZ0002ZZ phải đặt bit CPUID khách một cách rõ ràng.


7.14 KVM_CAP_S390_HPAGE_1M
--------------------------

:Kiến trúc: s390
:Thông số: không có
:Trả về: 0 nếu thành công, -EINVAL nếu tham số mô-đun hpage không được đặt
	  hoặc cmma được bật hoặc VM có KVM_VM_S390_UCONTROL
	  bộ cờ

Với khả năng này, KVM hỗ trợ sao lưu bộ nhớ với các trang 1m
thông qua Hugetlbfs có thể được kích hoạt cho VM. Sau khi có khả năng
đã bật, cmma không thể bật được nữa và pfmfi và khóa lưu trữ
giải thích bị vô hiệu hóa. Nếu cmma đã được bật hoặc
Tham số mô-đun hpage không được đặt thành 1, -EINVAL được trả về.

Mặc dù nhìn chung có thể tạo một máy ảo hỗ trợ trang lớn mà không cần
khả năng này, VM sẽ không thể chạy được.

7.15 KVM_CAP_MSR_PLATFORM_INFO
------------------------------

:Kiến trúc: x86
:Parameters: args[0] xem có nên bật tính năng này hay không

Với khả năng này, khách có thể đọc MSR_PLATFORM_INFO MSR. Nếu không,
#GP sẽ được nâng lên khi khách cố gắng truy cập. Hiện nay, điều này
khả năng không cho phép khách ghi quyền ghi của MSR này.

7.16 KVM_CAP_PPC_NESTED_HV
--------------------------

:Kiến trúc: ppc
:Thông số: không có
:Trả về: 0 nếu thành công, -EINVAL khi việc triển khai không hỗ trợ
	  ảo hóa HV lồng nhau.

HV-KVM trên POWER9 và các hệ thống mới hơn cho phép "HV lồng nhau"
ảo hóa, cung cấp một cách để máy ảo khách chạy các máy khách
có thể chạy bằng chế độ giám sát của CPU (đặc quyền không phải hypervisor
trạng thái).  Việc kích hoạt khả năng này trên máy ảo phụ thuộc vào việc CPU có
chức năng cần thiết và trên cơ sở đang được kích hoạt bằng một
tham số mô-đun kvm-hv.

7.17 KVM_CAP_EXCEPTION_PAYLOAD
------------------------------

:Kiến trúc: x86
:Parameters: args[0] xem có nên bật tính năng này hay không

Khi khả năng này được bật, CR2 sẽ không được sửa đổi trước
mô phỏng VM-exit khi L1 chặn ngoại lệ #PF xảy ra trong
L2. Tương tự, chỉ đối với kvm-intel, DR6 sẽ không được sửa đổi trước
lối ra VM được mô phỏng khi L1 chặn ngoại lệ #DB xảy ra trong
L2. Kết quả là, khi KVM_GET_VCPU_EVENTS báo cáo #PF đang chờ xử lý (hoặc
#DB) cho L2, ngoại lệ.has_payload sẽ được đặt và
địa chỉ lỗi (hoặc các bit DR6 mới*) sẽ được báo cáo trong
trường ngoại lệ_payload. Tương tự, khi không gian người dùng chèn #PF (hoặc
#DB) vào L2 bằng KVM_SET_VCPU_EVENTS, dự kiến sẽ thiết lập
ngoại lệ.has_payload và đặt địa chỉ bị lỗi - hoặc DR6 mới
bit\ [#]_ - trong trường ngoại lệ_payload.

Khả năng này cũng cho phép ngoại lệ.pending trong struct
kvm_vcpu_events, cho phép không gian người dùng phân biệt giữa các sự kiện đang chờ xử lý
và tiêm ngoại lệ.


.. [#] For the new DR6 bits, note that bit 16 is set iff the #DB exception
       will clear DR6.RTM.

7.18 KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2
--------------------------------------

: Kiến trúc: x86, arm64, mips
:Parameters: args[0] xem có nên bật tính năng này hay không

Cờ hợp lệ là::

#define KVM_DIRTY_LOG_MANUAL_PROTECT_ENABLE (1 << 0)
  #define KVM_DIRTY_LOG_INITIALLY_SET (1 << 1)

Khi KVM_DIRTY_LOG_MANUAL_PROTECT_ENABLE được thiết lập, KVM_GET_DIRTY_LOG sẽ không
tự động xóa và chống ghi tất cả các trang được trả về là trang bẩn.
Thay vào đó, không gian người dùng sẽ phải thực hiện thao tác này một cách riêng biệt bằng cách sử dụng
KVM_CLEAR_DIRTY_LOG.

Với chi phí của một hoạt động phức tạp hơn một chút, điều này mang lại hiệu quả tốt hơn
khả năng mở rộng và khả năng đáp ứng vì hai lý do.  Đầu tiên,
KVM_CLEAR_DIRTY_LOG ioctl có thể hoạt động ở mức độ chi tiết 64 trang
hơn là yêu cầu đồng bộ hóa toàn bộ vùng nhớ; điều này đảm bảo rằng KVM không
lấy spinlocks trong một khoảng thời gian dài.  Thứ hai, trong một số trường hợp
lượng lớn thời gian có thể trôi qua giữa cuộc gọi đến KVM_GET_DIRTY_LOG và
không gian người dùng thực sự sử dụng dữ liệu trong trang.  Các trang có thể được sửa đổi
trong thời gian này, điều này không hiệu quả cho cả không gian khách và người dùng:
khách sẽ phải chịu mức phạt cao hơn do lỗi bảo vệ ghi,
trong khi không gian người dùng có thể thấy báo cáo sai về các trang bẩn.  Bảo vệ lại thủ công
giúp giảm thời gian này, cải thiện hiệu suất của khách và giảm
số lượng nhật ký bẩn dương tính giả.

Với bộ KVM_DIRTY_LOG_INITIALLY_SET, tất cả các bit của bitmap bẩn
sẽ được khởi tạo thành 1 khi được tạo.  Điều này cũng cải thiện hiệu suất vì
ghi nhật ký bẩn có thể được kích hoạt dần dần theo từng phần nhỏ trong cuộc gọi đầu tiên
tới KVM_CLEAR_DIRTY_LOG.  KVM_DIRTY_LOG_INITIALLY_SET phụ thuộc vào
KVM_DIRTY_LOG_MANUAL_PROTECT_ENABLE (nó cũng chỉ có trên
x86, arm64 và riscv hiện nay).

KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2 trước đây đã có sẵn dưới tên
KVM_CAP_MANUAL_DIRTY_LOG_PROTECT, nhưng quá trình triển khai có lỗi khiến
thật khó hoặc không thể sử dụng nó một cách chính xác.  Sự sẵn có của
KVM_CAP_MANUAL_DIRTY_LOG_PROTECT2 báo hiệu rằng những lỗi đó đã được sửa.
Không gian người dùng không nên thử sử dụng KVM_CAP_MANUAL_DIRTY_LOG_PROTECT.

7.19 KVM_CAP_PPC_SECURE_GUEST
------------------------------

:Kiến trúc: ppc

Khả năng này cho biết KVM đang chạy trên máy chủ có
phần mềm ultravisor và do đó có thể hỗ trợ khách an toàn.  Trên một
hệ thống, khách có thể yêu cầu người giám sát biến họ thành khách an toàn,
một trang có bộ nhớ không thể truy cập được vào máy chủ ngoại trừ các trang
được yêu cầu chia sẻ rõ ràng với máy chủ.  máy siêu âm
thông báo cho KVM khi khách yêu cầu trở thành khách an toàn và KVM
có cơ hội phủ quyết quá trình chuyển đổi.

Nếu có, khả năng này có thể được kích hoạt cho máy ảo, nghĩa là KVM
sẽ cho phép chuyển đổi sang chế độ khách an toàn.  Nếu không KVM sẽ
phủ quyết quá trình chuyển đổi.

7,20 KVM_CAP_HALT_POLL
----------------------

:Kiến trúc: tất cả
:Mục tiêu: VM
:Parameters: args[0] là thời gian thăm dò tối đa tính bằng nano giây
:Trả về: 0 nếu thành công; -1 do lỗi

KVM_CAP_HALT_POLL ghi đè tham số mô-đun kvm.halt_poll_ns để đặt
thời gian thăm dò tạm dừng tối đa cho tất cả vCPU trong VM mục tiêu. Khả năng này có thể
được gọi bất cứ lúc nào và bất kỳ số lần nào để tự động thay đổi
thời gian dừng bỏ phiếu tối đa.

Xem Documentation/virt/kvm/halt-polling.rst để biết thêm thông tin về tạm dừng
bỏ phiếu.

7.21 KVM_CAP_X86_USER_SPACE_MSR
-------------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Parameters: args[0] chứa mặt nạ của các sự kiện KVM_MSR_EXIT_REASON_* cần báo cáo
:Trả về: 0 nếu thành công; -1 do lỗi

Khả năng này cho phép không gian người dùng chặn các hướng dẫn RDMSR và WRMSR nếu
quyền truy cập vào MSR bị từ chối.  Theo mặc định, KVM đưa #GP vào các truy cập bị từ chối.

Khi khách yêu cầu đọc hoặc viết MSR, KVM có thể không triển khai tất cả MSR
có liên quan đến một hệ thống tương ứng. Nó cũng không phân biệt
Loại CPU.

Để cho phép kiểm soát chi tiết hơn việc xử lý MSR, không gian người dùng có thể kích hoạt
khả năng này. Khi được bật, MSR sẽ truy cập phù hợp với mặt nạ được chỉ định trong
args[0] và sẽ kích hoạt #GP bên trong khách thay vào đó sẽ kích hoạt
Thông báo thoát KVM_EXIT_X86_RDMSR và KVM_EXIT_X86_WRMSR.  Không gian người dùng
sau đó có thể triển khai xử lý MSR cụ thể theo mô hình và/hoặc thông báo người dùng
để thông báo cho người dùng rằng MSR không được KVM mô phỏng/ảo hóa.

Các cờ mặt nạ hợp lệ là:

=================================================================================
 KVM_MSR_EXIT_REASON_UNKNOWN chặn quyền truy cập vào các MSR không xác định (đến KVM)
 KVM_MSR_EXIT_REASON_INVAL chặn các truy cập có kiến trúc
                             không hợp lệ theo mô hình và/hoặc chế độ vCPU
 KVM_MSR_EXIT_REASON_FILTER chặn các truy cập bị từ chối bởi không gian người dùng
                             thông qua KVM_X86_SET_MSR_FILTER
=================================================================================

7.22 KVM_CAP_X86_BUS_LOCK_EXIT
-------------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Thông số: args[0] xác định chính sách được sử dụng khi phát hiện khóa xe buýt trong máy khách
:Trả về: 0 nếu thành công, -EINVAL khi args[0] chứa các bit không hợp lệ

Các bit hợp lệ trong args[0] là::

#define KVM_BUS_LOCK_DETECTION_OFF (1 << 0)
  #define KVM_BUS_LOCK_DETECTION_EXIT (1 << 1)

Việc kích hoạt khả năng này trên máy ảo sẽ cung cấp cho người dùng một cách để chọn một
chính sách xử lý các khóa xe buýt được phát hiện trong khách. Không gian người dùng có thể có được
các chế độ được hỗ trợ từ kết quả của KVM_CHECK_EXTENSION và xác định nó thông qua
KVM_ENABLE_CAP. Các chế độ được hỗ trợ là loại trừ lẫn nhau.

Khả năng này cho phép không gian người dùng buộc VM thoát khỏi các khóa xe buýt được phát hiện trong
khách, bất kể máy chủ có bật tính năng phát hiện khóa phân chia hay không
(kích hoạt ngoại lệ #AC mà KVM chặn). Khả năng này là
nhằm mục đích giảm thiểu các cuộc tấn công trong đó khách độc hại/có lỗi có thể khai thác bus
khóa để làm suy giảm hiệu suất của toàn bộ hệ thống.

Nếu KVM_BUS_LOCK_DETECTION_OFF được đặt, KVM không buộc khóa bus khách đối với VM
thoát ra, mặc dù tính năng phát hiện #AC khóa chia tách của nhân máy chủ vẫn được áp dụng, nếu
đã bật.

Nếu KVM_BUS_LOCK_DETECTION_EXIT được đặt, KVM sẽ bật tính năng CPU để đảm bảo
khóa xe buýt trong máy khách kích hoạt lối thoát VM và KVM thoát khỏi không gian người dùng cho tất cả
VM như vậy thoát ra, ví dụ: để cho phép không gian người dùng kiểm soát khách vi phạm và/hoặc
áp dụng một số giảm thiểu dựa trên chính sách khác. Khi thoát khỏi không gian người dùng, KVM sẽ đặt
KVM_RUN_X86_BUS_LOCK trong vcpu-run->flag và đặt có điều kiện exit_reason
tới KVM_EXIT_X86_BUS_LOCK.

Do sự khác biệt trong cách triển khai phần cứng cơ bản, RIP của vCPU tại
thời điểm thoát khác nhau giữa Intel và AMD.  Trên máy chủ Intel, RIP trỏ tới
hướng dẫn tiếp theo, tức là lối ra giống như cái bẫy.  Trên máy chủ AMD, RIP trỏ tới
hướng dẫn vi phạm, tức là lối ra giống như có lỗi.

Ghi chú! Các khóa xe buýt được phát hiện có thể trùng với các lối thoát khác vào không gian người dùng, tức là.
KVM_RUN_X86_BUS_LOCK phải được kiểm tra bất kể lý do thoát chính nếu
không gian người dùng muốn thực hiện hành động đối với tất cả các khóa xe buýt được phát hiện.

7.23 KVM_CAP_PPC_DAWR1
----------------------

:Kiến trúc: ppc
:Thông số: không có
:Trả về: 0 nếu thành công, -EINVAL khi CPU không hỗ trợ DAWR thứ 2

Khả năng này có thể được sử dụng để kiểm tra/kích hoạt tính năng DAWR thứ 2 được cung cấp
bởi bộ xử lý POWER10.


7.24 KVM_CAP_VM_COPY_ENC_CONTEXT_FROM
-------------------------------------

:Kiến trúc: đã bật x86 SEV
:Loại: vm
:Parameters: args[0] là fd của nguồn vm
:Trả về: 0 nếu thành công; ENOTTY bị lỗi

Khả năng này cho phép không gian người dùng sao chép ngữ cảnh mã hóa từ vm
được chỉ định bởi fd tới vm, điều này được gọi.

Điều này nhằm hỗ trợ khối lượng công việc của khách do máy chủ lên lịch. Cái này
cho phép khối lượng công việc của khách duy trì NPT của riêng nó và giữ hai vms
khỏi việc vô tình làm tắc nghẽn lẫn nhau bằng các ngắt và những thứ tương tự (riêng biệt
APIC/MSR/vv).

7,25 KVM_CAP_SGX_ATTRIBUTE
--------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Parameters: args[0] là một tệp xử lý tệp thuộc tính SGX trong securityfs
:Trả về: 0 nếu thành công, -EINVAL nếu việc xử lý tệp không hợp lệ hoặc nếu được yêu cầu
          thuộc tính không được KVM hỗ trợ.

KVM_CAP_SGX_ATTRIBUTE cho phép không gian người dùng VMM cấp quyền truy cập VM vào một hoặc
thuộc tính vùng đặc quyền hơn.  args[0] phải giữ một phần xử lý tệp ở mức hợp lệ
Tệp thuộc tính SGX tương ứng với thuộc tính được hỗ trợ/hạn chế
bởi KVM (hiện chỉ có PROVISIONKEY).

Hệ thống con SGX hạn chế quyền truy cập vào một tập hợp con các thuộc tính kèm theo để cung cấp
bảo mật bổ sung cho hạt nhân không bị thỏa hiệp, ví dụ: sử dụng PROVISIONKEY
bị hạn chế để ngăn chặn phần mềm độc hại sử dụng PROVISIONKEY để có được kết nối ổn định
dấu vân tay hệ thống.  Để ngăn chặn không gian người dùng phá vỡ những hạn chế đó
bằng cách chạy một vùng trong VM, KVM ngăn chặn quyền truy cập vào các thuộc tính đặc quyền bằng cách
mặc định.

Xem Tài liệu/arch/x86/sgx.rst để biết thêm chi tiết.

7.27 KVM_CAP_EXIT_ON_EMULATION_FAILURE
--------------------------------------

:Kiến trúc: x86
:Parameters: args[0] liệu tính năng này có nên được bật hay không

Khi khả năng này được bật, lỗi mô phỏng sẽ dẫn đến việc thoát
tới không gian người dùng bằng KVM_INTERNAL_ERROR (trừ khi trình mô phỏng được gọi
để xử lý lệnh cửa hậu của VMware). Hơn nữa, KVM hiện sẽ từ bỏ
tới 15 byte lệnh cho bất kỳ lần thoát nào vào không gian người dùng do mô phỏng
thất bại.  Khi xảy ra các lần thoát vào không gian người dùng này, hãy sử dụng cấu trúc emulation_failure
thay vì cấu trúc bên trong.  Cả hai đều có cách bố trí giống nhau, nhưng
emulation_failure struct phù hợp với nội dung hơn.  Nó cũng rõ ràng
xác định trường 'cờ' được sử dụng để mô tả các trường trong cấu trúc
hợp lệ (ví dụ: nếu KVM_INTERNAL_ERROR_EMULATION_FLAG_INSTRUCTION_BYTES là
được đặt trong trường 'flags' thì cả 'insn_size' và 'insn_bytes' đều có dữ liệu hợp lệ
trong đó.)

7,28 KVM_CAP_ARM_MTE
--------------------

:Kiến trúc: arm64
:Thông số: không có

Khả năng này cho thấy KVM (và phần cứng) hỗ trợ hiển thị
Tiện ích mở rộng gắn thẻ bộ nhớ (MTE) cho khách. Nó cũng phải được kích hoạt bởi
VMM trước khi tạo bất kỳ VCPU nào để cho phép khách truy cập. Lưu ý rằng MTE chỉ
có sẵn cho khách đang chạy ở chế độ AArch64 và việc bật khả năng này sẽ
khiến các nỗ lực tạo VCPU AArch32 không thành công.

Khi được bật, khách có thể truy cập các thẻ được liên kết với bất kỳ bộ nhớ nào được cung cấp
cho khách. KVM sẽ đảm bảo rằng các thẻ được duy trì trong quá trình trao đổi hoặc
ngủ đông của vật chủ; tuy nhiên VMM cần lưu/khôi phục thủ công
các thẻ phù hợp nếu VM được di chuyển.

Khi khả năng này được kích hoạt, tất cả bộ nhớ trong các khe ghi nhớ phải được ánh xạ dưới dạng
ZZ0000ZZ hoặc với ánh xạ tệp dựa trên RAM (ZZ0001ZZ, ZZ0002ZZ),
cố gắng tạo một memslot với mmap không hợp lệ sẽ dẫn đến một
-EINVAL trở lại.

Khi được bật, VMM có thể sử dụng ioctl ZZ0000ZZ để
thực hiện sao chép hàng loạt thẻ đến/từ khách.

7.29 KVM_CAP_VM_MOVE_ENC_CONTEXT_FROM
-------------------------------------

:Kiến trúc: đã bật x86 SEV
:Loại: vm
:Parameters: args[0] là fd của nguồn vm
:Trả về: 0 nếu thành công

Khả năng này cho phép không gian người dùng di chuyển bối cảnh mã hóa từ VM
được chỉ định bởi fd tới VM, điều này được gọi.

Điều này nhằm hỗ trợ việc di chuyển máy ảo nội bộ giữa các VMM không gian người dùng,
nâng cấp quy trình VMM mà không làm gián đoạn khách.

7.31 KVM_CAP_DISABLE_QUIRKS2
----------------------------

:Thông số: args[0] - tập hợp các quirks KVM để vô hiệu hóa
:Kiến trúc: x86
:Loại: vm

Khả năng này, nếu được bật, sẽ khiến KVM vô hiệu hóa một số hành vi
những điều kỳ quặc.

Việc gọi KVM_CHECK_EXTENSION cho khả năng này sẽ trả về một bitmask
những điều kỳ quặc có thể bị vô hiệu hóa trong KVM.

Đối số của KVM_ENABLE_CAP cho khả năng này là một bitmask của
những điều cần làm để vô hiệu hóa và phải là tập hợp con của mặt nạ bit được trả về bởi
KVM_CHECK_EXTENSION.

Các bit hợp lệ trong cap.args[0] là:

================================================================================================
KVM_X86_QUIRK_LINT0_REENABLED Theo mặc định, giá trị đặt lại cho LVT
                                           Thanh ghi LINT0 là 0x700 (APIC_MODE_EXTINT).
                                           Khi tính năng này bị tắt, giá trị đặt lại
                                           là 0x10000 (APIC_LVT_MASKED).

KVM_X86_QUIRK_CD_NW_CLEARED Theo mặc định, KVM xóa CR0.CD và CR0.NW bật
                                           CPU AMD để khắc phục lỗi phần mềm khách
                                           chạy vĩnh viễn với CR0.CD, tức là.
                                           với bộ nhớ đệm ở chế độ "không điền".

Khi tính năng này bị vô hiệu hóa, KVM sẽ không
                                           thay đổi giá trị của CR0.CD và CR0.NW.

KVM_X86_QUIRK_LAPIC_MMIO_HOLE Theo mặc định, giao diện MMIO LAPIC là
                                           khả dụng ngay cả khi được định cấu hình cho x2APIC
                                           chế độ. Khi tính năng này bị vô hiệu hóa, KVM
                                           vô hiệu hóa giao diện MMIO LAPIC nếu
                                           LAPIC ở chế độ x2APIC.

KVM_X86_QUIRK_OUT_7E_INC_RIP Theo mặc định, KVM tăng trước %rip trước
                                           thoát khỏi không gian người dùng để nhận lệnh OUT
                                           đến cổng 0x7e. Khi tính năng này bị vô hiệu hóa,
                                           KVM không tăng trước %rip trước đó
                                           thoát ra không gian người dùng.

KVM_X86_QUIRK_MISC_ENABLE_NO_MWAIT Khi tính năng này bị vô hiệu hóa, KVM sẽ thiết lập
                                           CPUID.01H:ECX[bit 3] (MONITOR/MWAIT) nếu
                                           IA32_MISC_ENABLE[bit 18] (MWAIT) được đặt.
                                           Ngoài ra, khi tính năng này bị vô hiệu hóa,
                                           KVM xóa CPUID.01H:ECX[bit 3] nếu
                                           IA32_MISC_ENABLE[bit 18] bị xóa.

KVM_X86_QUIRK_FIX_HYPERCALL_INSN Theo mặc định, KVM viết lại khách
                                           Hướng dẫn VMMCALL/VMCALL để khớp với
                                           hướng dẫn hypercall của nhà cung cấp cho
                                           hệ thống. Khi tính năng này bị vô hiệu hóa, KVM
                                           sẽ không còn viết lại khách không hợp lệ
                                           hướng dẫn hypercall. Thực hiện
                                           lệnh hypercall không chính xác sẽ
                                           tạo #UD trong khách.

KVM_X86_QUIRK_MWAIT_NEVER_UD_FAULTS Theo mặc định, KVM mô phỏng MONITOR/MWAIT (nếu
                                           chúng bị chặn) dưới dạng NOP bất kể
                                           MONITOR/MWAIT có được hỗ trợ hay không
                                           theo khách CPUID.  Khi điều kỳ quặc này
                                           bị vô hiệu hóa và KVM_X86_DISABLE_EXITS_MWAIT
                                           chưa được đặt (MONITOR/MWAIT bị chặn),
                                           KVM sẽ tiêm #UD vào MONITOR/MWAIT nếu
                                           chúng không được hỗ trợ cho mỗi khách CPUID.  Lưu ý,
                                           KVM sẽ sửa đổi hỗ trợ MONITOR/MWAIT trong
                                           khách CPUID ghi vào MISC_ENABLE nếu
                                           KVM_X86_QUIRK_MISC_ENABLE_NO_MWAIT là
                                           bị vô hiệu hóa.

KVM_X86_QUIRK_SLOT_ZAP_ALL Theo mặc định, dành cho máy ảo KVM_X86_DEFAULT_VM, KVM
                                           vô hiệu hóa tất cả SPTE trong tất cả các khe nhớ và
                                           không gian địa chỉ khi một memslot bị xóa hoặc
                                           đã di chuyển.  Khi tính năng này bị vô hiệu hóa (hoặc
                                           Loại VM không phải là KVM_X86_DEFAULT_VM), chỉ KVM
                                           đảm bảo bộ nhớ sao lưu của dữ liệu đã xóa
                                           hoặc không thể truy cập được khe nhớ đã di chuyển, tức là KVM
                                           _may_ chỉ vô hiệu hóa các SPTE liên quan đến
                                           memslot.

KVM_X86_QUIRK_STUFF_FEATURE_MSRS Theo mặc định, khi tạo vCPU, KVM đặt
                                           MSR_IA32_PERF_CAPABILITIES của vCPU (0x345),
                                           MSR_IA32_ARCH_CAPABILITIES (0x10a),
                                           MSR_PLATFORM_INFO (0xce) và tất cả các MSR VMX
                                           (0x480..0x492) đến khả năng tối đa
                                           được hỗ trợ bởi KVM.  KVM cũng đặt
                                           MSR_IA32_UCODE_REV (0x8b) thành tùy ý
                                           giá trị (khác với Intel so với Intel).
                                           AMD).  Cuối cùng, khi khách CPUID được đặt (bởi
                                           không gian người dùng), KVM sửa đổi chọn VMX MSR
                                           các trường để buộc sự nhất quán giữa khách
                                           CPUID và ISA hiệu quả của L2.  Khi điều này
                                           quirk bị vô hiệu hóa, KVM chuyển về MSR của vCPU
                                           các giá trị (với hai ngoại lệ, xem bên dưới),
                                           tức là xử lý các MSR tính năng như CPUID
                                           rời khỏi và cung cấp cho không gian người dùng toàn quyền kiểm soát
                                           định nghĩa mô hình vCPU.  Điều kỳ quặc này làm
                                           không ảnh hưởng đến VMX MSR CR0/CR4_FIXED1 (0x487
                                           và 0x489), vì KVM hiện cho phép họ
                                           được đặt theo không gian người dùng (KVM đặt chúng dựa trên
                                           khách CPUID, vì mục đích an toàn).

KVM_X86_QUIRK_IGNORE_GUEST_PAT Theo mặc định, trên nền tảng Intel, KVM bỏ qua
                                           khách PAT và buộc bộ nhớ hiệu quả
                                           gõ vào WB trong EPT.  Điều kỳ quặc không có sẵn
                                           trên nền tảng Intel không có khả năng
                                           tôn vinh khách PAT một cách an toàn (tức là không có CPU
                                           tự rình mò, KVM luôn phớt lờ khách PAT và
                                           buộc loại bộ nhớ hiệu quả vào WB).  Đó là
                                           cũng bị bỏ qua trên nền tảng AMD hoặc trên Intel,
                                           khi máy ảo có thiết bị DMA không kết hợp
                                           được giao; KVM luôn vinh danh khách mời PAT trong
                                           trường hợp như vậy. Điều kỳ quặc là cần thiết để tránh
                                           tình trạng chậm lại trên một số nền tảng Intel Xeon nhất định
                                           (ví dụ: ICX, SPR) có tính năng tự rình mò
                                           được hỗ trợ nhưng UC đủ chậm để gây ra
                                           vấn đề với một số khách lớn tuổi sử dụng
                                           UC thay vì WC để ánh xạ video RAM.
                                           Không gian người dùng có thể vô hiệu hóa tính năng này để tôn vinh
                                           khách PAT nếu biết rằng không có
                                           phần mềm khách, ví dụ nếu nó không
                                           phơi bày một thiết bị đồ họa bochs (đó là
                                           được biết là có trình điều khiển có lỗi).

KVM_X86_QUIRK_VMCS12_ALLOW_FREEZE_IN_SMM Theo mặc định, KVM giảm bớt tính nhất quán
                                           kiểm tra GUEST_IA32_DEBUGCTL trong vmcs12
                                           để cho phép cài đặt FREEZE_IN_SMM.  Khi nào
                                           tính năng này bị vô hiệu hóa, KVM yêu cầu tính năng này
                                           chút để được xóa.  Lưu ý rằng vmcs02
                                           bit vẫn được điều khiển hoàn toàn bởi
                                           máy chủ, bất kể cài đặt ngẫu nhiên.
================================================================================================

7.32 KVM_CAP_MAX_VCPU_ID
------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Thông số: args[0] - Giá trị ID APIC tối đa được đặt cho VM hiện tại
:Trả về: 0 nếu thành công, -EINVAL nếu args[0] vượt quá KVM_MAX_VCPU_IDS
          được hỗ trợ trong KVM hoặc nếu nó đã được đặt.

Khả năng này cho phép không gian người dùng chỉ định ID APIC tối đa có thể
được chỉ định cho phiên VM hiện tại trước khi tạo vCPU, tiết kiệm
bộ nhớ dành cho cấu trúc dữ liệu được lập chỉ mục bởi ID APIC.  Không gian người dùng có thể
để tính giới hạn cho các giá trị ID APIC từ được chỉ định
Cấu trúc liên kết CPU.

Giá trị chỉ có thể được thay đổi cho đến khi KVM_ENABLE_CAP được đặt thành giá trị khác 0
giá trị hoặc cho đến khi vCPU được tạo.  Khi tạo vCPU đầu tiên,
nếu giá trị được đặt thành 0 hoặc KVM_ENABLE_CAP không được gọi, KVM
sử dụng giá trị trả về của KVM_CHECK_EXTENSION(KVM_CAP_MAX_VCPU_ID) làm
ID APIC tối đa.

7.33 KVM_CAP_X86_NOTIFY_VMEXIT
------------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Parameters: args[0] là giá trị của cửa sổ thông báo cũng như một số cờ
:Trả về: 0 nếu thành công, -EINVAL nếu args[0] chứa cờ không hợp lệ hoặc thông báo
          Thoát VM không được hỗ trợ.

Bit 63:32 của args[0] được sử dụng cho cửa sổ thông báo.
Bit 31:0 của args[0] dành cho một số cờ. Các bit hợp lệ là::

#define KVM_X86_NOTIFY_VMEXIT_ENABLED (1 << 0)
  #define KVM_X86_NOTIFY_VMEXIT_USER (1 << 1)

Khả năng này cho phép không gian người dùng định cấu hình bật/tắt thông báo thoát VM
trong phạm vi mỗi VM trong quá trình tạo VM. Thông báo thoát VM bị tắt theo mặc định.
Khi không gian người dùng đặt bit KVM_X86_NOTIFY_VMEXIT_ENABLED trong args[0], VMM sẽ
kích hoạt tính năng này với cửa sổ thông báo được cung cấp, nó sẽ tạo ra
thoát VM nếu không có cửa sổ sự kiện nào xảy ra ở chế độ không phải root của VM đối với một chỉ định
thời gian (cửa sổ thông báo).

Nếu KVM_X86_NOTIFY_VMEXIT_USER được đặt trong args[0], khi có thông báo thoát VM sẽ xảy ra,
KVM sẽ thoát ra không gian người dùng để xử lý.

Khả năng này nhằm mục đích giảm thiểu mối đe dọa mà các máy ảo độc hại có thể
khiến CPU bị kẹt (do cửa sổ sự kiện không mở) và khiến CPU
không có sẵn cho máy chủ hoặc máy ảo khác.

7,35 KVM_CAP_X86_APIC_BUS_CYCLES_NS
-----------------------------------

:Kiến trúc: x86
:Mục tiêu: VM
:Thông số: args[0] là tốc độ xung nhịp bus APIC mong muốn, tính bằng nano giây
:Trả về: 0 nếu thành công, -EINVAL nếu args[0] chứa giá trị không hợp lệ cho
          tần số hoặc nếu bất kỳ vCPU nào đã được tạo, -ENXIO nếu là ảo
          APIC cục bộ chưa được tạo bằng KVM_CREATE_IRQCHIP.

Khả năng này đặt tần số xung nhịp bus APIC của VM, được sử dụng bởi nhân trong KVM
APIC ảo khi mô phỏng bộ định thời APIC.  Có thể truy xuất giá trị mặc định của KVM
bởi KVM_CHECK_EXTENSION.

Lưu ý: Không gian người dùng chịu trách nhiệm định cấu hình chính xác CPUID 0x15, hay còn gọi là
tần số đồng hồ tinh thể lõi, nếu CPUID 0x15 khác 0 được tiếp xúc với khách.

7.36 KVM_CAP_DIRTY_LOG_RING/KVM_CAP_DIRTY_LOG_RING_ACQ_REL
----------------------------------------------------------

:Kiến trúc: x86, arm64, riscv
:Loại: vm
:Thông số: args[0] - kích thước của vòng nhật ký bẩn

KVM có khả năng theo dõi bộ nhớ bẩn bằng cách sử dụng bộ đệm vòng
được đưa vào không gian người dùng; có một vòng bẩn cho mỗi vcpu.

Vòng bẩn có sẵn cho không gian người dùng dưới dạng một mảng
ZZ0000ZZ.  Mỗi mục bẩn được định nghĩa là::

cấu trúc kvm_dirty_gfn {
          __u32 cờ;
          __u32 khe cắm; /* as_id | slot_id */
          __u64 bù đắp;
  };

Các giá trị sau đây được xác định cho trường cờ để xác định
trạng thái hiện tại của mục nhập::

#define KVM_DIRTY_GFN_F_DIRTY BIT(0)
  #define KVM_DIRTY_GFN_F_RESET BIT(1)
  #define KVM_DIRTY_GFN_F_MASK 0x3

Không gian người dùng nên gọi KVM_ENABLE_CAP ioctl ngay sau KVM_CREATE_VM
ioctl để kích hoạt khả năng này cho khách mới và đặt kích thước của
những chiếc nhẫn.  Việc kích hoạt khả năng chỉ được phép trước khi tạo bất kỳ
vCPU và kích thước của vòng phải là lũy thừa của hai.  càng lớn thì
bộ đệm vòng thì khả năng vòng đệm bị đầy càng ít và VM buộc phải
thoát khỏi không gian người dùng. Kích thước tối ưu phụ thuộc vào khối lượng công việc, nhưng nó
khuyến nghị rằng nó có ít nhất 64 KiB (4096 mục).

Giống như đối với các bitmap trang bẩn, các rãnh đệm ghi vào
tất cả các vùng bộ nhớ người dùng có cờ KVM_MEM_LOG_DIRTY_PAGES
được đặt trong KVM_SET_USER_MEMORY_REGION.  Khi một vùng bộ nhớ được đăng ký
với cờ được đặt, không gian người dùng có thể bắt đầu thu thập các trang bẩn từ
bộ đệm vòng.

Một mục trong bộ đệm vòng có thể không được sử dụng (bit cờ ZZ0000ZZ),
bẩn (bit cờ ZZ0001ZZ) hoặc bị thu hoạch (bit cờ ZZ0002ZZ).  các
máy trạng thái cho mục nhập như sau ::

thiết lập lại thu hoạch bẩn
     00 -----------> 01 -------------> 1X -------+
      ^ |
      ZZ0000ZZ
      +------------------------------------------+

Để thu thập các trang bẩn, không gian người dùng truy cập vào bộ đệm vòng được mmapped
để đọc các GFN bẩn.  Nếu các cờ có tập bit DIRTY (ở giai đoạn này
bit RESET phải được xóa), thì điều đó có nghĩa là GFN này là GFN bẩn.
Không gian người dùng sẽ thu thập GFN này và đánh dấu các cờ từ trạng thái
ZZ0000ZZ đến ZZ0001ZZ (bit 0 sẽ bị KVM bỏ qua, nhưng bit 1 phải được đặt
để cho biết rằng GFN này đã được thu hoạch và đang chờ thiết lập lại) và di chuyển
sang GFN tiếp theo.  Không gian người dùng sẽ tiếp tục thực hiện việc này cho đến khi
cờ của GFN có bit DIRTY bị xóa, nghĩa là nó đã thu hoạch
tất cả các GFN bẩn có sẵn.

Lưu ý rằng trên các kiến trúc có trật tự yếu, quyền truy cập vùng người dùng vào
bộ đệm vòng (và cụ thể hơn là trường 'cờ') phải được sắp xếp,
sử dụng các trình truy cập tải thu nhận/giải phóng cửa hàng khi có sẵn hoặc bất kỳ
rào cản bộ nhớ khác sẽ đảm bảo thứ tự này.

Không gian người dùng không cần thiết phải thu thập tất cả GFN bẩn cùng một lúc.
Tuy nhiên, nó phải thu thập các GFN bẩn theo trình tự, tức là không gian người dùng
chương trình không thể bỏ qua một chiếc GFN bẩn để thu thập chiếc bên cạnh nó.

Sau khi xử lý một hoặc nhiều mục trong bộ đệm vòng, vùng người dùng
gọi VM ioctl KVM_RESET_DIRTY_RINGS để thông báo cho kernel về
nó, để hạt nhân sẽ bảo vệ lại các GFN đã thu thập đó.
Vì vậy, ioctl phải được gọi là ZZ0000ZZ đọc nội dung của
những trang bẩn thỉu.

Vòng bẩn có thể đầy.  Khi điều đó xảy ra, KVM_RUN của
vcpu sẽ quay trở lại với lý do thoát KVM_EXIT_DIRTY_RING_FULL.

Giao diện vòng bẩn có sự khác biệt lớn so với
Giao diện KVM_GET_DIRTY_LOG ở chỗ, khi đọc vòng bẩn từ
không gian người dùng, vẫn có khả năng kernel chưa xóa
bộ đệm trang bẩn của bộ xử lý vào bộ đệm hạt nhân (với các bitmap bẩn,
việc xả nước được thực hiện bởi KVM_GET_DIRTY_LOG ioctl).  Để đạt được điều đó, một
cần loại bỏ vcpu ra khỏi KVM_RUN bằng tín hiệu.  Kết quả
vmexit đảm bảo rằng tất cả các GFN bẩn sẽ được chuyển sang các vòng bẩn.

NOTE: KVM_CAP_DIRTY_LOG_RING_ACQ_REL là khả năng duy nhất
nên được bộc lộ bởi kiến trúc có trật tự yếu, để chỉ ra
các yêu cầu sắp xếp bộ nhớ bổ sung được áp dụng cho không gian người dùng khi
đọc trạng thái của một mục và thay đổi nó từ DIRTY thành HARVESTED.
Kiến trúc có thứ tự giống TSO (chẳng hạn như x86) được phép
phơi bày cả KVM_CAP_DIRTY_LOG_RING và KVM_CAP_DIRTY_LOG_RING_ACQ_REL
tới không gian người dùng.

Sau khi kích hoạt các vòng bẩn, không gian người dùng cần phát hiện
khả năng của KVM_CAP_DIRTY_LOG_RING_WITH_BITMAP để xem liệu
cấu trúc vòng có thể được hỗ trợ bởi bitmap trên mỗi khe. Với khả năng này
được quảng cáo, điều đó có nghĩa là kiến trúc có thể làm bẩn các trang khách mà không cần
bối cảnh vcpu/ring, do đó một số thông tin bẩn vẫn sẽ được lưu giữ.
được duy trì trong cấu trúc bitmap. KVM_CAP_DIRTY_LOG_RING_WITH_BITMAP
không thể kích hoạt nếu khả năng của KVM_CAP_DIRTY_LOG_RING_ACQ_REL
chưa được kích hoạt hoặc bất kỳ khe ghi nhớ nào đã tồn tại.

Lưu ý rằng bitmap ở đây chỉ là bản sao lưu của cấu trúc vòng. các
việc sử dụng kết hợp vòng và bitmap chỉ có lợi nếu có
chỉ một lượng rất nhỏ bộ nhớ bị xóa khỏi vcpu/ring
bối cảnh. Mặt khác, cơ chế bitmap trên mỗi khe độc lập cần phải
được xem xét.

Để thu thập các bit bẩn trong bitmap sao lưu, không gian người dùng có thể sử dụng cùng một
KVM_GET_DIRTY_LOG ioctl. KVM_CLEAR_DIRTY_LOG không cần thiết miễn là
việc tạo ra các bit bẩn được thực hiện trong một lần duy nhất. thu thập
bitmap bẩn sẽ là điều cuối cùng mà VMM thực hiện trước đây
coi trạng thái là hoàn chỉnh. VMM cần đảm bảo rằng bụi bẩn
trạng thái là cuối cùng và tránh thiếu các trang bẩn từ ioctl khác
sau khi thu thập bitmap.

NOTE: Nhiều ví dụ về cách sử dụng bitmap dự phòng: (1) save vgic/its
bảng thông qua lệnh KVM_DEV_ARM_{VGIC_GRP_CTRL, ITS_SAVE_TABLES} trên
Thiết bị KVM "kvm-arm-vgic-its". (2) khôi phục vgic/bảng của nó thông qua
lệnh KVM_DEV_ARM_{VGIC_GRP_CTRL, ITS_RESTORE_TABLES} trên thiết bị KVM
"kvm-arm-vgic-its". Trạng thái chờ xử lý của VGICv3 LPI được khôi phục. (3) lưu
bảng đang chờ xử lý vgic3 thông qua KVM_DEV_ARM_VGIC_{GRP_CTRL, SAVE_PENDING_TABLES}
lệnh trên thiết bị KVM "kvm-arm-vgic-v3".

7.37 KVM_CAP_PMU_CAPABILITY
---------------------------

:Kiến trúc: x86
:Loại: vm
:Parameters: arg[0] là bitmask của khả năng ảo hóa PMU.
:Trả về: 0 nếu thành công, -EINVAL khi arg[0] chứa các bit không hợp lệ

Khả năng này làm thay đổi ảo hóa PMU trong KVM.

Việc gọi KVM_CHECK_EXTENSION cho khả năng này sẽ trả về một bitmask
Khả năng ảo hóa PMU có thể được điều chỉnh trên VM.

Đối số của KVM_ENABLE_CAP cũng là một bitmask và chọn cụ thể
Khả năng ảo hóa PMU được áp dụng cho VM.  Điều này có thể
chỉ được gọi trên máy ảo trước khi tạo VCPU.

Tại thời điểm này, KVM_PMU_CAP_DISABLE là khả năng duy nhất.  Cài đặt
khả năng này sẽ vô hiệu hóa ảo hóa PMU cho máy ảo đó.  chế độ người dùng
nên điều chỉnh lá CPUID 0xA để phản ánh rằng PMU bị vô hiệu hóa.

7,38 KVM_CAP_VM_DISABLE_NX_HUGE_PAGES
-------------------------------------

:Kiến trúc: x86
:Loại: vm
:Thông số: arg[0] phải bằng 0.
:Trả về: 0 nếu thành công, -EPERM nếu quá trình không gian người dùng không thành công
          có CAP_SYS_BOOT, -EINVAL nếu args[0] khác 0 hoặc bất kỳ vCPU nào đã bị
          được tạo ra.

Khả năng này vô hiệu hóa việc giảm nhẹ các trang lớn NX cho iTLB MULTIHIT.

Khả năng này không có hiệu lực nếu tham số mô-đun nx_huge_pages không được đặt.

Khả năng này chỉ có thể được đặt trước khi bất kỳ vCPU nào được tạo.

7,39 KVM_CAP_ARM_EAGER_SPLIT_CHUNK_SIZE
---------------------------------------

:Kiến trúc: arm64
:Loại: vm
:Parameters: arg[0] là kích thước phân chia mới.
:Trả về: 0 nếu thành công, -EINVAL nếu bất kỳ khe nhớ nào đã được tạo.

Khả năng này đặt kích thước khối được sử dụng trong Tách trang Eager.

Việc tách trang háo hức cải thiện hiệu suất của việc ghi nhật ký bẩn (được sử dụng
trong quá trình di chuyển trực tiếp) khi bộ nhớ khách được hỗ trợ bởi các trang lớn.  Nó
tránh việc chia các trang lớn (thành các trang PAGE_SIZE) do lỗi, bằng cách thực hiện
nó háo hức khi cho phép ghi nhật ký bẩn (với
Cờ KVM_MEM_LOG_DIRTY_PAGES cho vùng bộ nhớ) hoặc khi sử dụng
KVM_CLEAR_DIRTY_LOG.

Kích thước chunk chỉ định số lượng trang cần ngắt cùng một lúc bằng cách sử dụng
phân bổ duy nhất cho mỗi đoạn. Kích thước chunk lớn hơn, nhiều trang hơn
cần được phân bổ trước thời hạn.

Kích thước khối cần phải là kích thước khối hợp lệ. Danh sách chấp nhận được
kích thước khối được hiển thị trong KVM_CAP_ARM_SUPPORTED_BLOCK_SIZES dưới dạng
Bitmap 64 bit (mỗi bit mô tả kích thước khối). Giá trị mặc định là
0, để tắt tính năng chia trang háo hức.

7,40 KVM_CAP_EXIT_HYPERCALL
---------------------------

:Kiến trúc: x86
:Loại: vm

Khả năng này, nếu được bật, sẽ khiến KVM thoát khỏi không gian người dùng
với lý do thoát KVM_EXIT_HYPERCALL để xử lý một số siêu cuộc gọi.

Gọi KVM_CHECK_EXTENSION cho khả năng này sẽ trả về một bitmask
trong số các siêu cuộc gọi có thể được cấu hình để thoát ra không gian người dùng.
Hiện tại, hypercall duy nhất như vậy là KVM_HC_MAP_GPA_RANGE.

Đối số của KVM_ENABLE_CAP cũng là một bitmask và phải là một tập hợp con
kết quả của KVM_CHECK_EXTENSION.  KVM sẽ chuyển tiếp tới không gian người dùng
các siêu lệnh có bit tương ứng nằm trong đối số và trả về
ENOSYS cho những người khác.

7.41 KVM_CAP_ARM_SYSTEM_SUSPEND
-------------------------------

:Kiến trúc: arm64
:Loại: vm

Khi được bật, KVM sẽ thoát ra không gian người dùng với KVM_EXIT_SYSTEM_EVENT của
gõ KVM_SYSTEM_EVENT_SUSPEND để xử lý yêu cầu tạm dừng của khách.

7.42 KVM_CAP_ARM_WRITABLE_IMP_ID_REGS
-------------------------------------

:Kiến trúc: arm64
:Mục tiêu: VM
:Thông số: Không có
:Trả về: 0 nếu thành công, -EINVAL nếu vCPU đã được tạo trước khi kích hoạt tính năng này
          khả năng.

Khả năng này thay đổi hành vi của các thanh ghi xác định PE
triển khai kiến trúc Arm: MIDR_EL1, REVIDR_EL1 và AIDR_EL1.
Theo mặc định, các thanh ghi này hiển thị với không gian người dùng nhưng được coi là bất biến.

Khi khả năng này được bật, KVM cho phép không gian người dùng thay đổi
các thanh ghi nói trên trước KVM_RUN đầu tiên. Các thanh ghi này là VM
có phạm vi, nghĩa là cùng một bộ giá trị được trình bày trên tất cả các vCPU trong một
VM đã cho.

7.43 KVM_CAP_RISCV_MP_STATE_RESET
---------------------------------

:Kiến trúc: riscv
:Loại: VM
:Thông số: Không có
:Trả về: 0 nếu thành công, -EINVAL nếu arg[0] khác 0

Khi khả năng này được bật, KVM sẽ đặt lại VCPU khi cài đặt
MP_STATE_INIT_RECEIVED đến IOCTL.  MP_STATE ban đầu được bảo tồn.

7,44 KVM_CAP_ARM_CACHEABLE_PFNMAP_SUPPORTED
-------------------------------------------

:Kiến trúc: arm64
:Mục tiêu: VM
:Thông số: Không có

Khả năng này cho biết không gian người dùng có vùng bộ nhớ PFNMAP hay không
có thể được ánh xạ một cách an toàn dưới dạng có thể lưu vào bộ nhớ đệm. Điều này phụ thuộc vào sự có mặt của
hỗ trợ tính năng buộc ghi lại (FWB) trên phần cứng.

7,45 KVM_CAP_ARM_SEA_TO_USER
----------------------------

:Kiến trúc: arm64
:Mục tiêu: VM
:Thông số: không có
:Trả về: 0 nếu thành công, -EINVAL nếu không được hỗ trợ.

Khi khả năng này được bật, KVM có thể thoát khỏi không gian người dùng đối với các SEA được đưa tới
EL2 do quyền truy cập của khách. Xem ZZ0000ZZ để biết thêm
thông tin.

7,46 KVM_CAP_S390_USER_OPEREXEC
-------------------------------

:Kiến trúc: s390
:Thông số: không có

Khi khả năng này được kích hoạt, KVM sẽ chuyển tiếp tất cả các ngoại lệ hoạt động
rằng nó không tự xử lý được không gian người dùng. Điều này cũng bao gồm
Hướng dẫn 0x0000 được quản lý bởi KVM_CAP_S390_USER_INSTR0. Đây là
hữu ích nếu không gian người dùng muốn mô phỏng các hướng dẫn không
(chưa) được triển khai trong phần cứng.

Khả năng này có thể được kích hoạt một cách linh hoạt ngay cả khi các VCPU đã được
đã tạo và đang chạy.

8. Các khả năng khác.
======================

Phần này liệt kê các khả năng cung cấp thông tin về các
các tính năng của việc triển khai KVM.

8.1 KVM_CAP_PPC_HWRNG
---------------------

:Kiến trúc: ppc

Khả năng này, nếu KVM_CHECK_EXTENSION chỉ ra rằng nó là
có sẵn, có nghĩa là kernel có sự triển khai của
Siêu cuộc gọi H_RANDOM được hỗ trợ bởi bộ tạo số ngẫu nhiên phần cứng.
Nếu có, trình xử lý kernel H_RANDOM có thể được kích hoạt để khách sử dụng
với khả năng KVM_CAP_PPC_ENABLE_HCALL.

8.3 KVM_CAP_PPC_MMU_RADIX
-------------------------

:Kiến trúc: ppc

Khả năng này, nếu KVM_CHECK_EXTENSION chỉ ra rằng nó là
có sẵn, có nghĩa là kernel có thể hỗ trợ khách sử dụng
cơ số MMU được xác định trong Power ISA V3.00 (như được triển khai trong POWER9
bộ xử lý).

8.4 KVM_CAP_PPC_MMU_HASH_V3
---------------------------

:Kiến trúc: ppc

Khả năng này, nếu KVM_CHECK_EXTENSION chỉ ra rằng nó là
có sẵn, có nghĩa là kernel có thể hỗ trợ khách sử dụng
bảng trang băm MMU được xác định trong Power ISA V3.00 (như được triển khai trong
bộ xử lý POWER9), bao gồm các bảng phân đoạn trong bộ nhớ.

8,5 KVM_CAP_MIPS_VZ
-------------------

:Kiến trúc: mips

Khả năng này, nếu KVM_CHECK_EXTENSION trên tay cầm kvm chính chỉ ra rằng
nó có sẵn, có nghĩa là khả năng ảo hóa được hỗ trợ đầy đủ bằng phần cứng
phần cứng có sẵn để sử dụng thông qua KVM. Một cách thích hợp
Loại KVM_VM_MIPS_* phải được chuyển tới KVM_CREATE_VM để tạo VM
sử dụng nó.

Nếu KVM_CHECK_EXTENSION trên bộ điều khiển kvm VM chỉ ra rằng khả năng này là
khả dụng, điều đó có nghĩa là VM đang sử dụng ảo hóa được hỗ trợ hoàn toàn bằng phần cứng
khả năng của phần cứng. Điều này rất hữu ích để kiểm tra sau khi tạo VM bằng
KVM_VM_MIPS_DEFAULT.

Giá trị được trả về bởi KVM_CHECK_EXTENSION phải được so sánh với giá trị đã biết
giá trị (xem bên dưới). Tất cả các giá trị khác được bảo lưu. Điều này là để cho phép
khả năng triển khai ảo hóa được hỗ trợ bằng phần cứng khác
có thể không tương thích với MIPS VZ ASE.

== ================================================================================
 0 Việc triển khai bẫy & mô phỏng được sử dụng để chạy mã khách trong người dùng
    chế độ. Các phân đoạn bộ nhớ ảo của khách được sắp xếp lại để phù hợp với khách trong
    không gian địa chỉ chế độ người dùng.

1 MIPS VZ ASE đang được sử dụng, cung cấp đầy đủ phần cứng hỗ trợ
    ảo hóa, bao gồm các phân đoạn bộ nhớ ảo dành cho khách tiêu chuẩn.
== ================================================================================

8.7 KVM_CAP_MIPS_64BIT
----------------------

:Kiến trúc: mips

Khả năng này cho biết loại kiến trúc được hỗ trợ của khách, tức là
thanh ghi được hỗ trợ và độ rộng địa chỉ.

Các giá trị được trả về khi khả năng này được KVM_CHECK_EXTENSION kiểm tra trên một
Trình xử lý kvm VM tương ứng gần đúng với trường thanh ghi CP0_Config.AT và sẽ
được kiểm tra cụ thể dựa trên các giá trị đã biết (xem bên dưới). Tất cả các giá trị khác đều
dành riêng.

== ==============================================================================
 0 MIPS32 hoặc microMIPS32.
    Cả thanh ghi và địa chỉ đều rộng 32 bit.
    Sẽ chỉ có thể chạy mã khách 32 bit.

1 MIPS64 hoặc microMIPS64 chỉ có quyền truy cập vào các phân đoạn tương thích 32 bit.
    Các thanh ghi có chiều rộng 64 bit nhưng địa chỉ rộng 32 bit.
    Mã khách 64 bit có thể chạy nhưng không thể truy cập các đoạn bộ nhớ MIPS64.
    Cũng có thể chạy mã khách 32 bit.

2 MIPS64 hoặc microMIPS64 có quyền truy cập vào tất cả các phân đoạn địa chỉ.
    Cả thanh ghi và địa chỉ đều rộng 64 bit.
    Có thể chạy mã khách 64 bit hoặc 32 bit.
== ==============================================================================

8.9 KVM_CAP_ARM_USER_IRQ
------------------------

:Kiến trúc: arm64

Khả năng này, nếu KVM_CHECK_EXTENSION chỉ ra rằng nó khả dụng, có nghĩa là
rằng nếu không gian người dùng tạo một VM mà không có bộ điều khiển ngắt trong kernel, thì nó
sẽ được thông báo về những thay đổi về mức đầu ra của thiết bị mô phỏng trong nhân,
có thể tạo ra các ngắt ảo, được trình bày cho VM.
Đối với những máy ảo như vậy, mỗi lần quay trở lại không gian người dùng, kernel
cập nhật trường run->s.regs.device_irq_level của vcpu để thể hiện giá trị thực tế
mức đầu ra của thiết bị.

Bất cứ khi nào kvm phát hiện sự thay đổi ở mức đầu ra của thiết bị, kvm sẽ đảm bảo ở mức
ít nhất một lần quay lại không gian người dùng trước khi chạy VM.  Lối ra này có thể
là KVM_EXIT_INTR hoặc bất kỳ sự kiện thoát nào khác, như KVM_EXIT_MMIO. Lối này,
không gian người dùng luôn có thể lấy mẫu mức đầu ra của thiết bị và tính toán lại trạng thái của
bộ điều khiển ngắt không gian người dùng.  Không gian người dùng phải luôn kiểm tra trạng thái
của run->s.regs.device_irq_level trên mỗi lần thoát kvm.
Giá trị trong run->s.regs.device_irq_level có thể biểu thị cả cấp độ và cạnh
kích hoạt tín hiệu ngắt, tùy thuộc vào thiết bị.  Edge kích hoạt ngắt
tín hiệu sẽ thoát ra không gian người dùng với bit trong run->s.regs.device_irq_level
đặt chính xác một lần cho mỗi tín hiệu cạnh.

Trường run->s.regs.device_irq_level khả dụng độc lập với
run->kvm_valid_regs hoặc run->kvm_dirty_regs bit.

Nếu KVM_CAP_ARM_USER_IRQ được hỗ trợ, KVM_CHECK_EXTENSION ioctl sẽ trả về một
số lớn hơn 0 cho biết phiên bản của khả năng này được triển khai
và do đó bit nào trong run->s.regs.device_irq_level có thể báo hiệu các giá trị.

Hiện tại các bit sau được xác định cho bitmap device_irq_level ::

KVM_CAP_ARM_USER_IRQ >= 1:

KVM_ARM_DEV_EL1_VTIMER - Hẹn giờ ảo EL1
    KVM_ARM_DEV_EL1_PTIMER - Bộ hẹn giờ vật lý EL1
    KVM_ARM_DEV_PMU - Tín hiệu ngắt tràn ARM PMU

Các phiên bản tương lai của kvm có thể triển khai các sự kiện bổ sung. Những điều này sẽ nhận được
được biểu thị bằng cách trả về số cao hơn từ KVM_CHECK_EXTENSION và sẽ
liệt kê ở trên.

8.10 KVM_CAP_PPC_SMT_POSSIBLE
-----------------------------

:Kiến trúc: ppc

Truy vấn khả năng này trả về một bitmap cho biết khả năng
các chế độ SMT ảo có thể được đặt bằng KVM_CAP_PPC_SMT.  Nếu bit N
(tính từ bên phải) được đặt thì chế độ SMT ảo 2^N sẽ được thiết lập
có sẵn.

8.12 KVM_CAP_HYPERV_VP_INDEX
----------------------------

:Kiến trúc: x86

Khả năng này cho biết không gian người dùng có thể tải HV_X64_MSR_VP_INDEX msr.  của nó
giá trị được sử dụng để biểu thị vcpu đích cho ngắt SynIC.  cho
tương thích, KVM khởi tạo msr này thành chỉ mục vcpu nội bộ của KVM.  Khi điều này
không có khả năng, không gian người dùng vẫn có thể truy vấn giá trị của msr này.

8.13 KVM_CAP_S390_AIS_MIGRATION
-------------------------------

:Kiến trúc: s390

Khả năng này cho biết liệu thiết bị flic có thể nhận/đặt
AIS trạng thái di chuyển thông qua thuộc tính KVM_DEV_FLIC_AISM_ALL và cho phép
để khám phá điều này mà không cần phải tạo ra thiết bị flic.

8.14 KVM_CAP_S390_PSW
---------------------

:Kiến trúc: s390

Khả năng này cho thấy PSW được hiển thị thông qua cấu trúc kvm_run.

8.15 KVM_CAP_S390_GMAP
----------------------

:Kiến trúc: s390

Khả năng này chỉ ra rằng bộ nhớ không gian người dùng được sử dụng làm ánh xạ khách có thể
ở bất cứ đâu trong không gian địa chỉ bộ nhớ người dùng, miễn là các khe bộ nhớ còn
được căn chỉnh và định kích thước theo ranh giới phân đoạn (1MB).

8.16 KVM_CAP_S390_COW
---------------------

:Kiến trúc: s390

Khả năng này chỉ ra rằng bộ nhớ không gian người dùng được sử dụng làm ánh xạ khách có thể
sử dụng ngữ nghĩa sao chép khi ghi cũng như theo dõi các trang bẩn thông qua trang chỉ đọc
các bảng.

8.17 KVM_CAP_S390_BPB
---------------------

:Kiến trúc: s390

Khả năng này chỉ ra rằng kvm sẽ triển khai các giao diện để xử lý
đặt lại, di chuyển và KVM lồng nhau để chặn dự đoán nhánh. Cái kẹp
cơ sở 82 không nên được cung cấp cho khách nếu không có khả năng này.

8.18 KVM_CAP_HYPERV_TLBFLUSH
----------------------------

:Kiến trúc: x86

Khả năng này cho thấy KVM hỗ trợ Hyper-V TLB Flush ảo hóa song song
siêu cuộc gọi:
HvFlushVirtualAddressSpace, HvFlushVirtualAddressSpaceEx,
HvFlushVirtualAddressList, HvFlushVirtualAddressListEx.

8.19 KVM_CAP_ARM_INJECT_SERROR_ESR
----------------------------------

:Kiến trúc: arm64

Khả năng này chỉ ra rằng không gian người dùng có thể chỉ định (thông qua
KVM_SET_VCPU_EVENTS ioctl) giá trị hội chứng được báo cáo cho khách khi nó
nhận một ngoại lệ ngắt SError ảo.
Nếu KVM quảng cáo khả năng này, không gian người dùng chỉ có thể chỉ định trường ISS cho
hội chứng ESR. Các bộ phận khác của ESR, chẳng hạn như EC được tạo bởi
CPU khi ngoại lệ được thực hiện. Nếu SError ảo này được đưa tới EL1 bằng cách sử dụng
AArch64, giá trị này sẽ được báo cáo trong trường ISS của ESR_ELx.

Xem KVM_CAP_VCPU_EVENTS để biết thêm chi tiết.

8,20 KVM_CAP_HYPERV_SEND_IPI
----------------------------

:Kiến trúc: x86

Khả năng này cho thấy KVM hỗ trợ gửi Hyper-V IPI ảo hóa song song
siêu cuộc gọi:
HvCallSendSyntheticClusterIpi, HvCallSendSyntheticClusterIpiEx.

8.22 KVM_CAP_S390_VCPU_RESETS
-----------------------------

:Kiến trúc: s390

Khả năng này cho thấy rằng KVM_S390_NORMAL_RESET và
KVM_S390_CLEAR_RESET ioctls có sẵn.

8.23 KVM_CAP_S390_PROTECTED
---------------------------

:Kiến trúc: s390

Khả năng này cho biết rằng Ultravisor đã được khởi tạo và
Do đó, KVM có thể khởi động các máy ảo được bảo vệ.
Khả năng này chi phối KVM_S390_PV_COMMAND ioctl và
KVM_MP_STATE_LOAD MP_STATE. KVM_SET_MP_STATE có thể bị lỗi khi được bảo vệ
khách khi thay đổi trạng thái không hợp lệ.

8.24 KVM_CAP_STEAL_TIME
-----------------------

:Kiến trúc: arm64, x86

Khả năng này cho thấy KVM hỗ trợ tính toán thời gian ăn cắp.
Khi kế toán lấy cắp thời gian được hỗ trợ, nó có thể được kích hoạt bằng
giao diện kiến trúc cụ thể.  Khả năng này và kiến trúc-
giao diện cụ thể phải nhất quán, tức là nếu người ta nói tính năng
được hỗ trợ, hơn cái kia cũng nên và ngược lại.  Đối với cánh tay64
xem Tài liệu/virt/kvm/devices/vcpu.rst "KVM_ARM_VCPU_PVTIME_CTRL".
Đối với x86, hãy xem Tài liệu/virt/kvm/x86/msr.rst "MSR_KVM_STEAL_TIME".

8,25 KVM_CAP_S390_DIAG318
-------------------------

:Kiến trúc: s390

Khả năng này cho phép khách thiết lập thông tin về chương trình điều khiển của mình
(tức là loại và phiên bản kernel khách). Thông tin rất hữu ích trong quá trình
sự kiện dịch vụ hệ thống/chương trình cơ sở, cung cấp dữ liệu bổ sung về khách
môi trường đang chạy trên máy.

Thông tin được liên kết với lệnh DIAGNOSE 0x318, thiết lập
một giá trị 8 byte bao gồm Mã tên chương trình điều khiển một byte (CPNC) và
Mã phiên bản chương trình điều khiển 7 byte (CPVC). CPNC xác định những gì
môi trường mà chương trình điều khiển đang chạy (ví dụ: Linux, z/VM...), và
CPVC được sử dụng để biết thông tin dành riêng cho HĐH (ví dụ: phiên bản Linux, Linux
phân phối...)

Nếu khả năng này khả dụng thì CPNC và CPVC có thể được đồng bộ hóa
giữa KVM và không gian người dùng thông qua cơ chế đồng bộ hóa (KVM_SYNC_DIAG318).

8.26 KVM_CAP_X86_USER_SPACE_MSR
-------------------------------

:Kiến trúc: x86

Khả năng này cho thấy KVM hỗ trợ độ lệch của MSR đọc và
ghi vào không gian người dùng. Nó có thể được kích hoạt ở cấp độ VM. Nếu được bật, MSR
các truy cập thường kích hoạt #GP của KVM vào khách sẽ
thay vào đó được trả về không gian người dùng thông qua KVM_EXIT_X86_RDMSR và
Thông báo thoát KVM_EXIT_X86_WRMSR.

8.27 KVM_CAP_X86_MSR_FILTER
---------------------------

:Kiến trúc: x86

Khả năng này cho thấy KVM hỗ trợ truy cập vào MSR do người dùng xác định
có thể bị từ chối. Với khả năng này đã được bộc lộ, KVM xuất VM ioctl mới
KVM_X86_SET_MSR_FILTER mà không gian người dùng có thể gọi để chỉ định bitmap của MSR
phạm vi mà KVM nên từ chối quyền truy cập.

Kết hợp với KVM_CAP_X86_USER_SPACE_MSR, điều này cho phép người dùng có không gian để
bẫy và mô phỏng các MSR nằm ngoài phạm vi của KVM cũng như
hạn chế bề mặt tấn công trên mã giả lập MSR của KVM.

8h30 KVM_CAP_XEN_HVM
--------------------

:Kiến trúc: x86

Khả năng này biểu thị các tính năng mà Xen hỗ trợ cho việc lưu trữ Xen
PVHVM khách nhé. Cờ hợp lệ là::

#define KVM_XEN_HVM_CONFIG_HYPERCALL_MSR (1 << 0)
  #define KVM_XEN_HVM_CONFIG_INTERCEPT_HCALL (1 << 1)
  #define KVM_XEN_HVM_CONFIG_SHARED_INFO (1 << 2)
  #define KVM_XEN_HVM_CONFIG_RUNSTATE (1 << 3)
  #define KVM_XEN_HVM_CONFIG_EVTCHN_2LEVEL (1 << 4)
  #define KVM_XEN_HVM_CONFIG_EVTCHN_SEND (1 << 5)
  #define KVM_XEN_HVM_CONFIG_RUNSTATE_UPDATE_FLAG (1 << 6)
  #define KVM_XEN_HVM_CONFIG_PVCLOCK_TSC_UNSTABLE (1 << 7)

Cờ KVM_XEN_HVM_CONFIG_HYPERCALL_MSR cho biết rằng KVM_XEN_HVM_CONFIG
ioctl có sẵn để khách đặt trang hypercall của mình.

Nếu KVM_XEN_HVM_CONFIG_INTERCEPT_HCALL cũng được đặt, cờ tương tự cũng có thể được đặt
được cung cấp trong cờ tới KVM_XEN_HVM_CONFIG mà không cung cấp trang hypercall
nội dung, để yêu cầu KVM tự động tạo nội dung trang hypercall
và cũng cho phép chặn các siêu cuộc gọi của khách bằng KVM_EXIT_XEN.

Cờ KVM_XEN_HVM_CONFIG_SHARED_INFO cho biết tính khả dụng của
KVM_XEN_HVM_SET_ATTR, KVM_XEN_HVM_GET_ATTR, KVM_XEN_VCPU_SET_ATTR và
KVM_XEN_VCPU_GET_ATTR ioctls, cũng như việc phân phối các vectơ ngoại lệ
dành cho các cuộc gọi nâng cấp kênh sự kiện khi trường evtchn_upcall_pending của vcpu
vcpu_info được đặt.

Cờ KVM_XEN_HVM_CONFIG_RUNSTATE chỉ ra rằng liên quan đến runstate
tính năng KVM_XEN_VCPU_ATTR_TYPE_RUNSTATE_ADDR/_CURRENT/_DATA/_ADJUST là
được hỗ trợ bởi ioctls KVM_XEN_VCPU_SET_ATTR/KVM_XEN_VCPU_GET_ATTR.

Cờ KVM_XEN_HVM_CONFIG_EVTCHN_2LEVEL chỉ ra rằng các mục định tuyến IRQ
thuộc loại KVM_IRQ_ROUTING_XEN_EVTCHN được hỗ trợ, với mức độ ưu tiên
trường được đặt để biểu thị việc phân phối kênh sự kiện cấp 2.

Cờ KVM_XEN_HVM_CONFIG_EVTCHN_SEND cho biết KVM hỗ trợ
đưa các sự kiện kênh sự kiện trực tiếp vào khách bằng
KVM_XEN_HVM_EVTCHN_SEND ioctl. Nó cũng chỉ ra sự hỗ trợ cho
Thuộc tính KVM_XEN_ATTR_TYPE_EVTCHN/XEN_VERSION HVM và
Thuộc tính vCPU KVM_XEN_VCPU_ATTR_TYPE_VCPU_ID/TIMER/UPCALL_VECTOR.
liên quan đến phân phối kênh sự kiện, bộ tính giờ và XENVER_version
đánh chặn.

Cờ KVM_XEN_HVM_CONFIG_RUNSTATE_UPDATE_FLAG cho biết KVM hỗ trợ
thuộc tính KVM_XEN_ATTR_TYPE_RUNSTATE_UPDATE_FLAG trong KVM_XEN_SET_ATTR
và KVM_XEN_GET_ATTR ioctls. Điều này kiểm soát liệu KVM có đặt
Cờ XEN_RUNSTATE_UPDATE trong bộ nhớ khách được ánh xạ vcpu_runstate_info trong
cập nhật thông tin runstate. Lưu ý rằng các phiên bản KVM hỗ trợ
tính năng RUNSTATE ở trên, nhưng không phải tính năng RUNSTATE_UPDATE_FLAG, sẽ
luôn đặt cờ XEN_RUNSTATE_UPDATE khi cập nhật cấu trúc khách,
điều này có lẽ phản trực giác. Khi cờ này được quảng cáo, KVM sẽ
hành xử chính xác hơn, không sử dụng cờ XEN_RUNSTATE_UPDATE cho đến/trừ khi
được kích hoạt cụ thể (do khách thực hiện siêu cuộc gọi, khiến VMM
để kích hoạt thuộc tính KVM_XEN_ATTR_TYPE_RUNSTATE_UPDATE_FLAG).

Cờ KVM_XEN_HVM_CONFIG_PVCLOCK_TSC_UNSTABLE cho biết KVM hỗ trợ
xóa cờ PVCLOCK_TSC_STABLE_BIT trong nguồn Xen plock. Đây sẽ là
được thực hiện khi KVM_CAP_XEN_HVM ioctl đặt
Cờ KVM_XEN_HVM_CONFIG_PVCLOCK_TSC_UNSTABLE.

8.31 KVM_CAP_SPAPR_MULTITCE
---------------------------

:Kiến trúc: ppc
:Loại: vm

Khả năng này có nghĩa là kernel có khả năng xử lý các siêu lệnh
H_PUT_TCE_INDIRECT và H_STUFF_TCE mà không chuyển chúng cho người dùng
không gian. Điều này tăng tốc đáng kể hoạt động DMA cho khách PPC KVM.
Không gian người dùng sẽ mong đợi rằng trình xử lý của nó cho các siêu lệnh gọi này
sẽ không được gọi nếu không gian người dùng đã đăng ký trước đó LIOBN
trong KVM (thông qua KVM_CREATE_SPAPR_TCE hoặc các cuộc gọi tương tự).

Để cho phép sử dụng H_PUT_TCE_INDIRECT và H_STUFF_TCE trong máy khách,
không gian người dùng có thể phải quảng cáo nó cho khách. Ví dụ,
Khách IBM pSeries (sPAPR) bắt đầu sử dụng chúng nếu có "hcall-multi-tce"
có trong thuộc tính cây thiết bị "ibm,hypertas-functions".

Các siêu cuộc gọi được đề cập ở trên có thể được xử lý thành công hoặc không
trong đường dẫn nhanh dựa trên kernel. Nếu chúng không thể được xử lý bởi kernel,
chúng sẽ được chuyển vào không gian người dùng. Vì vậy không gian người dùng vẫn phải có
một triển khai cho những điều này mặc dù có khả năng tăng tốc kernel.

Khả năng này luôn được kích hoạt.

8.32 KVM_CAP_PTP_KVM
--------------------

:Kiến trúc: arm64

Khả năng này cho biết rằng dịch vụ PTP ảo KVM đang được
được hỗ trợ trong máy chủ. VMM có thể kiểm tra xem dịch vụ có
có sẵn cho khách khi di chuyển.

8.37 KVM_CAP_S390_PROTECTED_DUMP
--------------------------------

:Kiến trúc: s390
:Loại: vm

Khả năng này cho thấy rằng KVM và Ultravisor hỗ trợ việc bán phá giá
PV khách mời. Lệnh ZZ0000ZZ có sẵn cho
ZZ0001ZZ ioctl và lệnh ZZ0002ZZ cung cấp
kết xuất dữ liệu UV liên quan. Ngoài ra vcpu ioctl ZZ0003ZZ là
có sẵn và hỗ trợ lệnh con ZZ0004ZZ.

8,39 KVM_CAP_S390_CPU_TOPOLOGY
------------------------------

:Kiến trúc: s390
:Loại: vm

Khả năng này cho thấy rằng KVM sẽ cung cấp Cấu trúc liên kết S390 CPU
cơ sở bao gồm việc giải thích hướng dẫn PTF cho
mã chức năng 2 cùng với việc chặn và chuyển tiếp cả hai
Lệnh PTF với mã chức năng 0 hoặc 1 và STSI(15,1,x)
hướng dẫn cho người ảo hóa vùng người dùng.

Cơ sở stfle 11, cơ sở cấu trúc liên kết CPU, không nên được chỉ định
cho khách mà không có khả năng này.

Khi có khả năng này, KVM sẽ cung cấp một nhóm thuộc tính mới
trên vm fd, KVM_S390_VM_CPU_TOPOLOGY.
Thuộc tính mới này cho phép nhận, đặt hoặc xóa Thay đổi đã sửa đổi
Bit Báo cáo cấu trúc liên kết (MTCR) của SCA thông qua kvm_device_attr
cấu trúc.

Khi nhận được giá trị Báo cáo cấu trúc liên kết thay đổi đã sửa đổi, attr->addr
phải trỏ đến một byte nơi giá trị sẽ được lưu trữ hoặc truy xuất từ đó.

8,41 KVM_CAP_VM_TYPES
---------------------

:Kiến trúc: x86
:Loại: hệ thống ioctl

Khả năng này trả về một bitmap của các loại máy ảo hỗ trợ.  Cài đặt 1 của bit @n
có nghĩa là loại VM có giá trị @n được hỗ trợ.  Các giá trị có thể có của @n là::

#define KVM_X86_DEFAULT_VM 0
  #define KVM_X86_SW_PROTECTED_VM 1
  #define KVM_X86_SEV_VM 2
  #define KVM_X86_SEV_ES_VM 3

Lưu ý, KVM_X86_SW_PROTECTED_VM hiện chỉ dành cho phát triển và thử nghiệm.
Không sử dụng KVM_X86_SW_PROTECTED_VM cho máy ảo "thực" và đặc biệt là không dùng trong
sản xuất.  Hành vi và ABI hiệu quả dành cho máy ảo được bảo vệ bằng phần mềm là
không ổn định.

8,42 KVM_CAP_PPC_RPT_INVALIDATE
-------------------------------

:Kiến trúc: ppc

Khả năng này chỉ ra rằng hạt nhân có khả năng xử lý
H_RPT_INVALIDATE hcall.

Để cho phép sử dụng H_RPT_INVALIDATE trong máy khách,
không gian người dùng có thể phải quảng cáo nó cho khách. Ví dụ,
Khách IBM pSeries (sPAPR) bắt đầu sử dụng nó nếu "hcall-rpt-invalidate" là
có trong thuộc tính cây thiết bị "ibm,hypertas-functions".

Khả năng này được kích hoạt cho các trình ảo hóa trên các nền tảng như POWER9
hỗ trợ cơ số MMU.

8,43 KVM_CAP_PPC_AIL_MODE_3
---------------------------

:Kiến trúc: ppc

Khả năng này chỉ ra rằng hạt nhân hỗ trợ cài đặt chế độ 3 cho
"Chế độ dịch địa chỉ khi ngắt" hay còn gọi là "Vị trí ngắt thay thế"
tài nguyên được kiểm soát bằng siêu lệnh H_SET_MODE.

Khả năng này cho phép kernel khách sử dụng chế độ hiệu suất tốt hơn cho
xử lý các ngắt và các cuộc gọi hệ thống.

8,44 KVM_CAP_MEMORY_FAULT_INFO
------------------------------

:Kiến trúc: x86

Sự hiện diện của khả năng này cho thấy KVM_RUN sẽ lấp đầy
kvm_run.memory_fault nếu KVM không thể giải quyết lỗi trang khách VM-Exit, ví dụ: nếu
có một khe ghi nhớ hợp lệ nhưng không có bản sao lưu VMA cho máy chủ ảo tương ứng
địa chỉ.

Thông tin trong kvm_run.memory_fault hợp lệ khi và chỉ khi KVM_RUN trả về
đã xảy ra lỗi với errno=EFAULT hoặc errno=EHWPOISON ZZ0000ZZ kvm_run.exit_reason
tới KVM_EXIT_MEMORY_FAULT.

Lưu ý: Không gian người dùng cố gắng giải quyết lỗi bộ nhớ để họ có thể thử lại
KVM_RUN được khuyến khích đề phòng việc liên tục nhận được thông tin tương tự
lỗi/lỗi chú thích.

Xem KVM_EXIT_MEMORY_FAULT để biết thêm thông tin.

8,45 KVM_CAP_X86_GUEST_MODE
---------------------------

:Kiến trúc: x86

Sự hiện diện của khả năng này cho thấy KVM_RUN sẽ cập nhật
Bit KVM_RUN_X86_GUEST_MODE trong kvm_run.flags để cho biết liệu
vCPU đang thực thi mã khách lồng nhau khi thoát.

8,46 KVM_CAP_S390_KEYOP
-----------------------

:Kiến trúc: s390

Sự hiện diện của khả năng này cho thấy KVM_S390_KEYOP ioctl
có sẵn.

KVM thoát với trạng thái đăng ký của khách L1 hoặc L2
tùy thuộc vào việc thực hiện tại thời điểm thoát. Không gian người dùng phải
chú ý phân biệt các trường hợp này.

8,47 KVM_CAP_S390_VSIE_ESAMODE
------------------------------

:Kiến trúc: s390

Sự hiện diện của khả năng này cho thấy rằng máy khách KVM lồng nhau có thể
bắt đầu ở chế độ ESA.

9. Các vấn đề về KVM API đã biết
================================

Trong một số trường hợp, API của KVM có một số điểm không nhất quán hoặc những cạm bẫy phổ biến
không gian người dùng đó cần phải biết.  Phần này trình bày chi tiết một số
những vấn đề này.

Hầu hết chúng đều có kiến trúc cụ thể nên phần này được chia thành
kiến trúc.

9.1. x86
--------

Sự cố ZZ0000ZZ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nhìn chung, ZZ0000ZZ được thiết kế sao cho có thể
để lấy kết quả và chuyển trực tiếp đến ZZ0001ZZ.  Phần này
ghi lại một số trường hợp đòi hỏi phải cẩn thận.

Các tính năng APIC cục bộ
~~~~~~~~~~~~~~~~~~~~~~~~~

CPU[EAX=1]:ECX[21] (X2APIC) được báo cáo bởi ZZ0000ZZ,
nhưng nó chỉ có thể được kích hoạt nếu ZZ0001ZZ hoặc
ZZ0002ZZ được sử dụng để cho phép mô phỏng trong kernel của
APIC địa phương.

Điều này cũng đúng với tính năng ảo hóa song song ZZ0000ZZ.

Trên các phiên bản Linux cũ hơn, CPU[EAX=1]:ECX[24] (TSC_DEADLINE) không được báo cáo bởi
ZZ0000ZZ, nhưng nó có thể được kích hoạt nếu ZZ0001ZZ
hiện diện và hạt nhân đã kích hoạt mô phỏng trong hạt nhân của APIC cục bộ.
Trên các phiên bản mới hơn, ZZ0002ZZ báo cáo bit có sẵn.

Cấu trúc liên kết CPU
~~~~~~~~~~~~~~~~~~~~~

Một số giá trị CPUID bao gồm thông tin cấu trúc liên kết cho máy chủ CPU:
0x0b và 0x1f cho hệ thống Intel, 0x8000001e cho hệ thống AMD.  Khác nhau
các phiên bản KVM trả về các giá trị khác nhau cho thông tin và không gian người dùng này
không nên dựa vào nó.  Hiện tại họ trả lại tất cả số không.

Nếu không gian người dùng muốn thiết lập cấu trúc liên kết khách, cần lưu ý rằng
giá trị của ba lá này khác nhau đối với mỗi CPU.  Đặc biệt,
ID APIC được tìm thấy trong EDX cho tất cả các phân lớp 0x0b và 0x1f và trong EAX
cho 0x8000001e; cái sau cũng mã hóa id lõi và id nút theo bit
7:0 của EBX và ECX tương ứng.

ioctls và khả năng lỗi thời
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

KVM_CAP_DISABLE_QUIRKS không cho không gian người dùng biết thực chất đó là những điều kỳ quặc nào
có sẵn.  Thay vào đó hãy sử dụng ZZ0000ZZ nếu
có sẵn.

Thứ tự của KVM_GET_ZZ0000ZZ ioctls
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

TBD