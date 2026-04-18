.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/running-nested-guests.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Chạy các khách lồng nhau với KVM
=================================

Một khách lồng nhau là khả năng điều hành một khách bên trong một khách khác (nó
có thể dựa trên KVM hoặc một trình ảo hóa khác).  Sự đơn giản
ví dụ là một khách KVM lần lượt chạy trên một khách KVM (phần còn lại của
tài liệu này được xây dựng dựa trên ví dụ này)::

.----------------.  .----------------.
              ZZ0000ZZ ZZ0001ZZ
              ZZ0002ZZ ZZ0003ZZ
              ZZ0004ZZ ZZ0005ZZ
              ZZ0006ZZ ZZ0007ZZ
              ZZ0008ZZ
              ZZ0009ZZ
              ZZ0010ZZ
              ZZ0011ZZ
              ZZ0012ZZ
      .-------------------------------------------------------------------.
      ZZ0013ZZ
      ZZ0014ZZ
      ZZ0015ZZ
      ZZ0016ZZ
      '------------------------------------------------------'

Thuật ngữ:

- L0 – cấp 0; máy chủ kim loại trần, chạy KVM

- L1 – khách cấp 1; một máy ảo chạy trên L0; còn được gọi là “khách
  hypervisor", vì bản thân nó có khả năng chạy KVM.

- L2 – khách cấp 2; một VM chạy trên L1, đây là "khách lồng nhau"

.. note:: The above diagram is modelled after the x86 architecture;
          s390x, ppc64 and other architectures are likely to have
          a different design for nesting.

          For example, s390x always has an LPAR (LogicalPARtition)
          hypervisor running on bare metal, adding another layer and
          resulting in at least four levels in a nested setup — L0 (bare
          metal, running the LPAR hypervisor), L1 (host hypervisor), L2
          (guest hypervisor), L3 (nested guest).

          This document will stick with the three-level terminology (L0,
          L1, and L2) for all architectures; and will largely focus on
          x86.


Trường hợp sử dụng
---------

Có một số tình huống trong đó KVM lồng nhau có thể hữu ích, chẳng hạn như đặt tên cho một
vài:

- Là nhà phát triển, bạn muốn thử nghiệm phần mềm của mình trên các hệ điều hành khác nhau
  hệ thống (OS).  Thay vì thuê nhiều máy ảo từ Đám mây
  Nhà cung cấp, sử dụng KVM lồng nhau cho phép bạn thuê một "khách" đủ lớn
  hypervisor" (khách cấp 1).  Điều này lần lượt cho phép bạn tạo
  nhiều khách lồng nhau (khách cấp 2), chạy các hệ điều hành khác nhau, trên
  mà bạn có thể phát triển và thử nghiệm phần mềm của mình.

- Di chuyển trực tiếp các "người giám sát khách" và các khách lồng nhau của họ, dành cho
  cân bằng tải, khắc phục thảm họa, v.v.

- Các công cụ tạo image VM (ví dụ ZZ0000ZZ, v.v.) thường chạy
  VM của riêng họ và người dùng mong đợi những thứ này hoạt động bên trong VM.

- Một số hệ điều hành sử dụng ảo hóa nội bộ để bảo mật (ví dụ: để cho phép
  các ứng dụng chạy cách ly một cách an toàn).


Kích hoạt "lồng nhau" (x86)
-----------------------

Từ Linux kernel v4.20 trở đi, tham số ZZ0000ZZ KVM được bật
theo mặc định cho Intel và AMD.  (Mặc dù bản phân phối Linux của bạn có thể
ghi đè mặc định này.)

Trong trường hợp bạn đang chạy nhân Linux cũ hơn v4.19, để bật
lồng nhau, đặt tham số mô-đun ZZ0000ZZ KVM thành ZZ0001ZZ hoặc ZZ0002ZZ.  Đến
duy trì cài đặt này trong các lần khởi động lại, bạn có thể thêm nó vào tệp cấu hình, như
hiển thị dưới đây:

1. Trên máy chủ kim loại trần (L0), liệt kê các mô-đun hạt nhân và đảm bảo rằng
   các mô-đun KVM::

$ lsmod | grep -i kvm
    kvm_intel 133627 0
    kvm 435079 1 kvm_intel

2. Hiển thị thông tin module ZZ0000ZZ::

$ modinfo kvm_intel | grep -i lồng nhau
    parm: lồng nhau:bool

3. Để cấu hình KVM lồng nhau vẫn tồn tại qua các lần khởi động lại, hãy đặt
   bên dưới trong ZZ0000ZZ (tạo tệp nếu nó
   không tồn tại)::

$ cat /etc/modprobe.d/kvm_intel.conf
    tùy chọn kvm-intel lồng nhau=y

4. Dỡ và tải lại mô-đun Intel KVM::

$ sudo rmmod kvm-intel
    $ sudo modprobe kvm-intel

5. Xác minh xem tham số ZZ0000ZZ cho KVM có được bật hay không::

$ cat /sys/module/kvm_intel/parameters/nested
    Y

Đối với máy chủ AMD, quy trình tương tự như trên, ngoại trừ mô-đun
tên là ZZ0000ZZ.


Các tham số hạt nhân lồng nhau bổ sung (x86)
-------------------------------------------------

Nếu phần cứng của bạn đủ tiên tiến (bộ xử lý Intel Haswell hoặc
cao hơn, có phần mở rộng phần cứng mới hơn), sau đây
các tính năng bổ sung cũng sẽ được bật theo mặc định: "Shadow VMCS
(Cấu trúc điều khiển máy ảo)", APIC Ảo hóa trên thiết bị trần của bạn
máy chủ kim loại (L0).  Thông số cho máy chủ Intel::

$ cat /sys/module/kvm_intel/parameters/enable_shadow_vmcs
    Y

$ cat /sys/module/kvm_intel/parameters/enable_apicv
    Y

$ cat /sys/module/kvm_intel/parameters/ept
    Y

.. note:: If you suspect your L2 (i.e. nested guest) is running slower,
          ensure the above are enabled (particularly
          ``enable_shadow_vmcs`` and ``ept``).


Bắt đầu một khách lồng nhau (x86)
-----------------------------

Khi máy chủ kim loại trần (L0) của bạn được định cấu hình để lồng nhau, bạn sẽ
có thể bắt đầu một khách L1 với::

$ qemu-kvm -cpu máy chủ […]

Phần trên sẽ chuyển qua các khả năng của máy chủ CPU như hiện tại đối với
khách hoặc để có khả năng tương thích di chuyển trực tiếp tốt hơn, hãy sử dụng CPU có tên
mô hình được hỗ trợ bởi QEMU. ví dụ.::

$ qemu-kvm -cpu Haswell-noTSX-IBRS,vmx=on

thì trình ảo hóa khách sau đó sẽ có khả năng chạy một
khách lồng nhau với KVM được tăng tốc.


Kích hoạt "lồng nhau" (s390x)
-------------------------

1. Trên bộ ảo hóa máy chủ (L0), bật tham số ZZ0000ZZ trên
   s390x::

$ rmmod kvm
    $ modprobe kvm lồng nhau=1

.. note:: On s390x, the kernel parameter ``hpage`` is mutually exclusive
          with the ``nested`` parameter — i.e. to be able to enable
          ``nested``, the ``hpage`` parameter *must* be disabled.

2. Trình ảo hóa khách (L1) phải được cung cấp ZZ0000ZZ CPU
   tính năng - với QEMU, điều này có thể được thực hiện bằng cách sử dụng "truyền qua máy chủ"
   (thông qua dòng lệnh ZZ0001ZZ).

3. Bây giờ mô-đun KVM có thể được tải trong L1 (trình ảo hóa khách)::

$ modprobe kvm


Di chuyển trực tiếp với KVM lồng nhau
------------------------------

Di chuyển một khách L1, với một khách ZZ0000ZZ lồng trong đó, sang một khách khác
máy chủ kim loại trần, hoạt động giống như nhân Linux 5.3 và QEMU 4.2.0 cho
Hệ thống Intel x86 và thậm chí trên các phiên bản cũ hơn cho s390x.

Trên hệ thống AMD, khi khách L1 đã bắt đầu khách L2, khách L1 sẽ
sẽ không còn được di chuyển hoặc lưu nữa (tham khảo tài liệu QEMU trên
"savevm"/"loadvm") cho đến khi khách L2 tắt.  Đang cố gắng di cư
hoặc lưu và tải một khách L1 trong khi khách L2 đang chạy sẽ dẫn đến
hành vi không xác định.  Bạn có thể thấy mục nhập ZZ0000ZZ trong ZZ0001ZZ, một
kernel 'oops', hoặc kernel hoàn toàn hoảng loạn.  L1 được di chuyển hoặc tải như vậy
khách không còn được coi là ổn định hoặc an toàn nữa và phải được khởi động lại.
Di chuyển một khách L1 chỉ được cấu hình để hỗ trợ lồng nhau, trong khi không
thực sự đang chạy khách L2, dự kiến sẽ hoạt động bình thường ngay cả trên AMD
hệ thống nhưng có thể bị lỗi khi khách được khởi động.

Việc di chuyển một khách L2 luôn được kỳ vọng sẽ thành công, vì vậy tất cả những điều sau đây
các kịch bản sẽ hoạt động ngay cả trên các hệ thống AMD:

- Di chuyển một khách lồng nhau (L2) sang một khách L1 khác trên ZZ0000ZZ
  máy chủ kim loại.

- Di chuyển một khách lồng nhau (L2) sang một khách L1 khác trên ZZ0000ZZ
  máy chủ kim loại trần.

- Di chuyển máy khách lồng nhau (L2) sang máy chủ kim loại trần.

Báo cáo lỗi từ các thiết lập lồng nhau
-----------------------------------

Gỡ lỗi các vấn đề "lồng nhau" có thể liên quan đến việc sàng lọc các tệp nhật ký trên
L0, L1 và L2; điều này có thể dẫn đến việc qua lại tẻ nhạt giữa lỗi
người báo cáo và người sửa lỗi.

- Đề cập rằng bạn đang ở trong một thiết lập "lồng nhau".  Nếu bạn đang chạy bất kỳ loại nào
  về việc "làm tổ" chút nào, nói như vậy.  Thật không may, điều này cần phải được gọi
  bởi vì khi báo cáo lỗi, mọi người thậm chí có xu hướng quên
  ZZ0000ZZ rằng họ đang sử dụng ảo hóa lồng nhau.

- Đảm bảo bạn đang thực sự chạy KVM trên KVM.  Đôi khi người ta không
  đã kích hoạt KVM cho bộ ảo hóa khách (L1) của họ, điều này dẫn đến
  chúng chạy với mô phỏng thuần túy hoặc cái mà QEMU gọi là "TCG", nhưng
  họ nghĩ rằng họ đang chạy KVM lồng nhau.  Do đó, "virt lồng nhau" khó hiểu
  (cũng có thể có nghĩa là QEMU trên KVM) với "KVM lồng nhau" (KVM trên KVM).

Thông tin cần thu thập (chung)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sau đây không phải là danh sách đầy đủ nhưng là điểm khởi đầu rất tốt:

- Phiên bản kernel, libvirt và QEMU từ L0

- Phiên bản kernel, libvirt và QEMU từ L1

- Dòng lệnh QEMU của L1 - khi sử dụng libvirt, bạn sẽ tìm thấy nó ở đây:
    ZZ0000ZZ

- Dòng lệnh QEMU của L2 -- như trên, khi sử dụng libvirt, lấy
    hoàn thành dòng lệnh QEMU do libvirt tạo

- ZZ0000ZZ từ L0

-ZZ0000ZZ từ L1

- ZZ0000ZZ từ L0

-ZZ0000ZZ từ L1

- Đầu ra ZZ0000ZZ đầy đủ từ L0

- Đầu ra ZZ0000ZZ đầy đủ từ L1

thông tin cụ thể về x86 cần thu thập
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cả hai lệnh dưới đây, ZZ0000ZZ và ZZ0001ZZ, đều phải
có sẵn trên hầu hết các bản phân phối Linux có cùng tên:

- Đầu ra: ZZ0000ZZ từ L0

- Đầu ra: ZZ0000ZZ từ L1

- Đầu ra: ZZ0000ZZ từ L0

- Đầu ra: ZZ0000ZZ từ L1

thông tin cụ thể về s390x cần thu thập
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Cùng với các chi tiết chung được đề cập trước đó, dưới đây là
cũng đề nghị:

- ZZ0000ZZ từ L1; điều này cũng sẽ bao gồm thông tin từ L0