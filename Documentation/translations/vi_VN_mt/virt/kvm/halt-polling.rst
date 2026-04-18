.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/halt-polling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Hệ thống bỏ phiếu dừng KVM
==============================

Hệ thống thăm dò tạm dừng KVM cung cấp một tính năng trong KVM nhờ đó độ trễ
của một vị khách, trong một số trường hợp, có thể được giảm bớt bằng cách bỏ phiếu trong máy chủ
trong một khoảng thời gian sau khi khách đã quyết định không điều hành bằng cách nhượng lại nữa.
Nghĩa là, khi một vcpu khách đã nhượng lại, hoặc trong trường hợp powerpc khi tất cả
vcpus của một vcore đã nhượng lại, kernel của máy chủ sẽ thăm dò các điều kiện đánh thức
trước khi nhường CPU cho bộ lập lịch để cho thứ khác chạy.

Bỏ phiếu mang lại lợi thế về độ trễ trong trường hợp khách có thể được chạy lại
rất nhanh bằng cách ít nhất giúp chúng ta tiết kiệm được một chuyến đi thông qua bộ lập lịch, thông thường trên
khoảng vài micro giây, mặc dù lợi ích về hiệu suất là khối lượng công việc
phụ thuộc. Trong trường hợp không có nguồn đánh thức nào đến trong quá trình bỏ phiếu
khoảng thời gian hoặc một số tác vụ khác trên runqueue có thể chạy được, bộ lập lịch là
được gọi. Do đó, việc tạm dừng bỏ phiếu đặc biệt hữu ích đối với khối lượng công việc có thời gian rất ngắn.
khoảng thời gian thức dậy trong đó thời gian dừng bỏ phiếu được giảm thiểu và thời gian
mức tiết kiệm khi không gọi bộ lập lịch có thể phân biệt được.

Mã bỏ phiếu dừng chung được triển khai trong:

đức/kvm/kvm_main.c: kvm_vcpu_block()

Trường hợp cụ thể của powerpc kvm-hv được triển khai trong:

Arch/powerpc/kvm/book3s_hv.c: kvmppc_vcore_blocked()

Dừng khoảng thời gian bỏ phiếu
==============================

Thời gian tối đa để thăm dò trước khi gọi bộ lập lịch, được đề cập
như khoảng thời gian tạm dừng bỏ phiếu, được tăng và giảm dựa trên cảm nhận
hiệu quả của việc bỏ phiếu nhằm hạn chế việc bỏ phiếu vô nghĩa.
Giá trị này được lưu trữ trong cấu trúc vcpu:

kvm_vcpu->halt_poll_ns

hoặc trong trường hợp powerpc kvm-hv, trong cấu trúc vcore:

kvmppc_vcore->halt_poll_ns

Vì vậy, đây là giá trị trên mỗi vcpu (hoặc vcore).

Trong quá trình bỏ phiếu nếu nhận được nguồn đánh thức trong khoảng thời gian tạm dừng bỏ phiếu,
khoảng thời gian được giữ nguyên không thay đổi. Trong trường hợp nguồn đánh thức không
nhận được trong khoảng thời gian thăm dò (và do đó lịch trình được viện dẫn) có
hai tùy chọn, khoảng thời gian bỏ phiếu và tổng thời gian khối [0] nhỏ hơn
khoảng thời gian bỏ phiếu tối đa toàn cầu (xem thông số mô-đun bên dưới) hoặc tổng khối
thời gian lớn hơn khoảng thời gian bỏ phiếu tối đa toàn cầu.

Trong trường hợp cả khoảng thời gian bỏ phiếu và tổng thời gian khối nhỏ hơn
khoảng thời gian bỏ phiếu tối đa toàn cầu thì khoảng thời gian bỏ phiếu có thể được tăng lên trong
hy vọng rằng lần sau trong khoảng thời gian bỏ phiếu dài hơn, nguồn đánh thức
sẽ được nhận trong khi máy chủ đang bỏ phiếu và lợi ích về độ trễ sẽ là
đã nhận được. Khoảng thời gian bỏ phiếu được tăng lên trong hàm Grow_halt_poll_ns() và
được nhân với các tham số mô-đun Halt_poll_ns_grow và
tạm dừng_poll_ns_grow_start.

Trong trường hợp tổng thời gian khối lớn hơn bỏ phiếu tối đa toàn cầu
khoảng thời gian thì máy chủ sẽ không bao giờ thăm dò đủ lâu (bị giới hạn bởi toàn cầu
max) thức dậy trong khoảng thời gian bỏ phiếu để nó có thể được thu nhỏ theo thứ tự
để tránh bỏ phiếu vô nghĩa. Khoảng thời gian bỏ phiếu được thu hẹp trong hàm
thu nhỏ_halt_poll_ns() và được chia cho tham số mô-đun
Halt_poll_ns_shrink hoặc đặt thành 0 nếu Halt_poll_ns_shrink == 0.

Điều đáng chú ý là quá trình điều chỉnh này cố gắng tập trung vào một số
khoảng thời gian bỏ phiếu ở trạng thái ổn định nhưng sẽ chỉ thực sự làm tốt công việc đánh thức
có tốc độ xấp xỉ không đổi, nếu không sẽ có hằng số
điều chỉnh khoảng thời gian bỏ phiếu.

[0] tổng thời gian khối:
		      khoảng thời gian kể từ khi chức năng dừng bỏ phiếu được thực hiện
		      được gọi và nguồn đánh thức đã nhận được (không phân biệt
		      liệu bộ lập lịch có được gọi trong hàm đó hay không).

Thông số mô-đun
=================

Mô-đun kvm có 4 tham số mô-đun có thể điều chỉnh để điều chỉnh việc bỏ phiếu tối đa toàn cầu
khoảng thời gian, giá trị ban đầu (tăng từ 0) và tốc độ bỏ phiếu
khoảng cách tăng lên và thu hẹp lại. Các biến này được xác định trong
bao gồm/linux/kvm_host.h và dưới dạng tham số mô-đun trong virt/kvm/kvm_main.c hoặc
Arch/powerpc/kvm/book3s_hv.c trong trường hợp powerpc kvm-hv.

+--------------+---------------------------------------+------------------------+
ZZ0000ZZ Mô tả ZZ0001ZZ
+--------------+---------------------------------------+------------------------+
ZZ0002ZZ Cuộc bỏ phiếu tối đa toàn cầu ZZ0003ZZ
Khoảng ZZ0004ZZ xác định ZZ0005ZZ
ZZ0006ZZ giá trị trần của ZZ0007ZZ
Khoảng thời gian thăm dò ZZ0008ZZ cho ZZ0009ZZ
ZZ0010ZZ mỗi vcpu.		    ZZ0011ZZ
+--------------+---------------------------------------+------------------------+
ZZ0012ZZ Giá trị mà ZZ0013ZZ
Khoảng thời gian dừng bỏ phiếu của ZZ0014ZZ là ZZ0015ZZ
ZZ0016ZZ được nhân trong ZZ0017ZZ
ZZ0018ZZ Grow_halt_poll_ns() ZZ0019ZZ
Chức năng ZZ0020ZZ.		    ZZ0021ZZ
+--------------+---------------------------------------+------------------------+
ZZ0022ZZ Giá trị ban đầu để phát triển ZZ0023ZZ
ZZ0024ZZ từ 0 lên ZZ0025ZZ
ZZ0026ZZ Grow_halt_poll_ns() ZZ0027ZZ
Chức năng ZZ0028ZZ.		    ZZ0029ZZ
+--------------+---------------------------------------+------------------------+
ZZ0030ZZ Giá trị mà ZZ0031ZZ
Khoảng thời gian dừng bỏ phiếu của ZZ0032ZZ là ZZ0033ZZ
ZZ0034ZZ được chia thành ZZ0035ZZ
ZZ0036ZZ thu nhỏ_halt_poll_ns() ZZ0037ZZ
Chức năng ZZ0038ZZ.		    ZZ0039ZZ
+--------------+---------------------------------------+------------------------+

Các tham số mô-đun này có thể được đặt từ các tệp sysfs trong:

/sys/mô-đun/kvm/tham số/

Lưu ý: các tham số mô-đun này là giá trị toàn hệ thống và không thể
      được điều chỉnh trên cơ sở mỗi vm.

Mọi thay đổi đối với các tham số này sẽ được các vCPU mới và hiện tại xử lý.
lần tới họ sẽ tạm dừng, ngoại trừ các máy ảo sử dụng KVM_CAP_HALT_POLL
(xem phần tiếp theo).

KVM_CAP_HALT_POLL
=================

KVM_CAP_HALT_POLL là một khả năng VM cho phép không gian người dùng ghi đè Halt_poll_ns
trên cơ sở mỗi VM. Máy ảo sử dụng KVM_CAP_HALT_POLL hoàn toàn bỏ qua Halt_poll_ns (nhưng
vẫn tuân theo lệnh dừng_poll_ns_grow, dừng_poll_ns_grow_start và dừng_poll_ns_shrink).

Xem Documentation/virt/kvm/api.rst để biết thêm thông tin về khả năng này.

Ghi chú thêm
=============

- Cần cẩn thận khi đặt tham số mô-đun Halt_poll_ns là giá trị lớn
  có khả năng tăng mức sử dụng CPU lên 100% trên một máy gần như
  hoàn toàn nhàn rỗi nếu không. Điều này là do ngay cả khi khách thức dậy trong thời gian đó
  ít công việc được thực hiện và cách nhau khá xa nếu khoảng thời gian ngắn hơn thời gian
  khoảng thời gian thăm dò tối đa toàn cầu (halt_poll_ns) thì máy chủ sẽ luôn thăm dò ý kiến
  toàn bộ thời gian khối và do đó mức sử dụng CPU sẽ đạt 100%.

- Việc dừng bỏ phiếu về cơ bản thể hiện sự cân bằng giữa việc sử dụng năng lượng và độ trễ và
  các tham số mô-đun nên được sử dụng để điều chỉnh mối quan hệ cho việc này. Thời gian CPU nhàn rỗi là
  về cơ bản được chuyển đổi thành thời gian của lõi máy chủ với mục đích giảm độ trễ khi
  bước vào khách.

- Việc tạm dừng bỏ phiếu sẽ chỉ được máy chủ tiến hành khi không có tác vụ nào khác có thể thực hiện được trên đó
  CPU đó, nếu không quá trình bỏ phiếu sẽ dừng ngay lập tức và lịch trình sẽ được gọi tới
  cho phép tác vụ khác chạy. Vì vậy, điều này không cho phép khách gây ra sự từ chối dịch vụ
  của CPU.