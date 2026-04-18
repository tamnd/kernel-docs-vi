.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/vcpu-requests.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Yêu cầu KVM VCPU
=================

Tổng quan
========

KVM hỗ trợ API nội bộ cho phép các luồng yêu cầu một luồng VCPU để
thực hiện một số hoạt động.  Ví dụ: một luồng có thể yêu cầu VCPU xóa
TLB của nó với yêu cầu VCPU.  API bao gồm các chức năng sau::

/* Kiểm tra xem có bất kỳ yêu cầu nào đang chờ xử lý đối với VCPU @vcpu hay không. */
  bool kvm_request_pending(struct kvm_vcpu *vcpu);

/* Kiểm tra xem VCPU @vcpu có yêu cầu @req đang chờ xử lý hay không. */
  bool kvm_test_request(int req, struct kvm_vcpu *vcpu);

/* Xóa yêu cầu @req cho VCPU @vcpu. */
  void kvm_clear_request(int req, struct kvm_vcpu *vcpu);

/*
   * Kiểm tra xem VCPU @vcpu có yêu cầu @req đang chờ xử lý hay không. Khi yêu cầu được
   * Đang chờ xử lý, nó sẽ bị xóa và rào cản bộ nhớ, kết hợp với
   * một cái khác trong kvm_make_request(), sẽ được phát hành.
   */
  bool kvm_check_request(int req, struct kvm_vcpu *vcpu);

/*
   * Đưa ra yêu cầu @req của VCPU @vcpu. Phát hành một rào cản bộ nhớ, cặp nào
   * bằng một cái khác trong kvm_check_request(), trước khi đặt yêu cầu.
   */
  void kvm_make_request(int req, struct kvm_vcpu *vcpu);

/* Tạo yêu cầu @req của tất cả các VCPU của VM với struct kvm @kvm. */
  bool kvm_make_all_cpus_request(struct kvm *kvm, unsigned int req);

Thông thường, người yêu cầu muốn VCPU thực hiện hoạt động càng sớm càng tốt
nhất có thể sau khi thực hiện yêu cầu.  Điều này có nghĩa là hầu hết các yêu cầu
(các cuộc gọi kvm_make_request()) được theo sau bởi một cuộc gọi đến kvm_vcpu_kick(),
và kvm_make_all_cpus_request() có sức ảnh hưởng lớn đối với tất cả các VCPU được xây dựng
vào đó.

Cú đá VCPU
----------

Mục tiêu của cú đá VCPU là đưa luồng VCPU ra khỏi chế độ khách trong
để thực hiện một số công việc bảo trì KVM.  Để làm như vậy, một IPI được gửi đi, buộc
thoát khỏi chế độ khách.  Tuy nhiên, luồng VCPU có thể không ở chế độ khách tại
thời điểm thực hiện cú đá.  Do đó, tùy thuộc vào chế độ và trạng thái của VCPU
thread, có hai hành động khác mà một cú đá có thể thực hiện.  Cả ba hành động
được liệt kê dưới đây:

1) Gửi IPI.  Điều này buộc phải thoát khỏi chế độ khách.
2) Đánh thức VCPU đang ngủ.  VCPU đang ngủ là các luồng VCPU bên ngoài máy khách
   chế độ chờ đợi trong hàng đợi.  Đánh thức họ sẽ xóa chủ đề khỏi
   hàng đợi, cho phép các luồng chạy lại.  Hành vi này
   có thể bị chặn, xem KVM_REQUEST_NO_WAKEUP bên dưới.
3) Không có gì.  Khi VCPU không ở chế độ khách và luồng VCPU không ở
   ngủ rồi không có việc gì làm.

Chế độ VCPU
---------

VCPU có trạng thái chế độ, ZZ0000ZZ, được sử dụng để theo dõi xem
khách có chạy ở chế độ khách hay không, cũng như một số thông tin cụ thể
trạng thái chế độ khách bên ngoài.  Kiến trúc có thể sử dụng ZZ0001ZZ để
đảm bảo các yêu cầu VCPU được VCPU nhìn thấy (xem "Đảm bảo các yêu cầu được nhìn thấy"),
cũng như để tránh gửi IPI không cần thiết (xem phần "Giảm IPI") và
thậm chí để đảm bảo các xác nhận IPI được chờ đợi (xem "Đang chờ
Lời cảm ơn").  Các chế độ sau được xác định:

OUTSIDE_GUEST_MODE

Chuỗi VCPU nằm ngoài chế độ khách.

IN_GUEST_MODE

Chuỗi VCPU đang ở chế độ khách.

EXITING_GUEST_MODE

Chuỗi VCPU đang chuyển từ IN_GUEST_MODE sang
  OUTSIDE_GUEST_MODE.

READING_SHADOW_PAGE_TABLES

Chuỗi VCPU nằm ngoài chế độ khách, nhưng nó muốn người gửi
  một số yêu cầu VCPU nhất định, cụ thể là KVM_REQ_TLB_FLUSH, phải đợi cho đến khi VCPU
  thread đã đọc xong các bảng trang.

VCPU Yêu cầu nội bộ
======================

Các yêu cầu VCPU chỉ đơn giản là các chỉ số bit của bitmap ZZ0000ZZ.
Điều này có nghĩa là các bit chung, giống như các bit được ghi trong [atomic-ops]_ có thể
cũng được sử dụng, ví dụ: ::

clear_bit(KVM_REQ_UNBLOCK & KVM_REQUEST_MASK, &vcpu->request);

Tuy nhiên, người dùng yêu cầu VCPU không nên làm như vậy, vì điều đó sẽ
phá vỡ sự trừu tượng  8 bit đầu tiên được dành riêng cho kiến trúc
yêu cầu độc lập; tất cả các bit bổ sung đều có sẵn cho kiến trúc
các yêu cầu phụ thuộc.

Yêu cầu độc lập về kiến ​​trúc
---------------------------------

KVM_REQ_TLB_FLUSH

Trình thông báo MMU phổ biến của KVM có thể cần xóa tất cả TLB của khách
  các mục, gọi kvm_flush_remote_tlbs() để làm như vậy.  Những kiến trúc
  chọn sử dụng cách triển khai kvm_flush_remote_tlbs() thông thường sẽ
  cần xử lý yêu cầu VCPU này.

KVM_REQ_VM_DEAD

Yêu cầu này thông báo cho tất cả các VCPU rằng VM đã chết và không thể sử dụng được, ví dụ: do
  lỗi nghiêm trọng hoặc do trạng thái của VM đã bị cố ý phá hủy.

KVM_REQ_UNBLOCK

Yêu cầu này thông báo cho vCPU thoát kvm_vcpu_block.  Nó được sử dụng cho
  ví dụ từ trình xử lý hẹn giờ chạy trên máy chủ thay mặt cho vCPU,
  hoặc để cập nhật định tuyến ngắt và đảm bảo rằng được chỉ định
  các thiết bị sẽ đánh thức vCPU.

KVM_REQ_OUTSIDE_GUEST_MODE

"Yêu cầu" này đảm bảo vCPU mục tiêu đã thoát khỏi chế độ khách trước khi
  người gửi yêu cầu vẫn tiếp tục.  Mục tiêu không cần phải thực hiện hành động nào,
  và do đó không có yêu cầu nào thực sự được ghi lại cho mục tiêu.  Yêu cầu này tương tự
  thành "cú đá", nhưng không giống như cú đá, nó đảm bảo vCPU đã thực sự thoát
  chế độ khách.  Một cú đá chỉ đảm bảo vCPU sẽ thoát ra vào một thời điểm nào đó trong
  tương lai, v.d. cú đá trước đó có thể đã bắt đầu quá trình, nhưng không có
  đảm bảo vCPU bị loại bỏ đã thoát hoàn toàn chế độ khách.

KVM_REQUEST_MASK
----------------

Các yêu cầu VCPU phải được KVM_REQUEST_MASK che giấu trước khi sử dụng chúng với
bitop.  Điều này là do chỉ có 8 bit thấp hơn được sử dụng để biểu diễn
số yêu cầu.  Các bit trên được sử dụng làm cờ.  Hiện tại chỉ có hai
cờ được xác định.

Cờ yêu cầu VCPU
------------------

KVM_REQUEST_NO_WAKEUP

Cờ này được áp dụng cho các yêu cầu chỉ cần chú ý ngay lập tức
  từ các VCPU đang chạy ở chế độ khách.  Tức là các VCPU đang ngủ không cần
  được đánh thức cho những yêu cầu này.  VCPU đang ngủ sẽ xử lý
  yêu cầu khi chúng được đánh thức sau đó vì một số lý do khác.

KVM_REQUEST_WAIT

Khi các yêu cầu có cờ này được thực hiện bằng kvm_make_all_cpus_request(),
  thì người gọi sẽ đợi mỗi VCPU xác nhận IPI của nó trước
  tiến hành.  Cờ này chỉ áp dụng cho các VCPU sẽ nhận IPI.
  Ví dụ: nếu VCPU đang ngủ, do đó không cần IPI, thì
  chuỗi yêu cầu không chờ đợi.  Điều này có nghĩa là lá cờ này có thể
  kết hợp an toàn với KVM_REQUEST_NO_WAKEUP.  Xem "Chờ đợi
  Lời cảm ơn" để biết thêm thông tin về các yêu cầu với
  KVM_REQUEST_WAIT.

Yêu cầu VCPU với Trạng thái liên kết
===================================

Người yêu cầu muốn VCPU nhận xử lý trạng thái mới cần đảm bảo
trạng thái mới được ghi có thể quan sát được đối với CPU của luồng VCPU đang nhận
vào thời điểm nó tuân theo yêu cầu.  Điều này có nghĩa là rào cản bộ nhớ ghi
phải được chèn sau khi ghi trạng thái mới và trước khi thiết lập VCPU
bit yêu cầu.  Ngoài ra, về phía luồng VCPU nhận, một
rào cản đọc tương ứng phải được chèn sau khi đọc bit yêu cầu
và trước khi tiếp tục đọc trạng thái mới liên quan đến nó.  Xem
kịch bản 3, Tin nhắn và Cờ, của [lwn-mb]_ và tài liệu kernel
[rào cản bộ nhớ]_.

Cặp hàm kvm_check_request() và kvm_make_request() cung cấp
rào cản bộ nhớ, cho phép yêu cầu này được xử lý nội bộ bởi
API.

Đảm bảo yêu cầu được nhìn thấy
==========================

Khi thực hiện yêu cầu tới VCPU, chúng tôi muốn tránh việc nhận VCPU
thực thi ở chế độ khách trong một thời gian dài tùy ý mà không xử lý
yêu cầu.  Chúng tôi có thể chắc chắn điều này sẽ không xảy ra miễn là chúng tôi đảm bảo VCPU
chủ đề kiểm tra kvm_request_pending() trước khi vào chế độ khách và
kick sẽ gửi IPI để buộc thoát khỏi chế độ khách khi cần thiết.
Phải hết sức cẩn thận trong khoảng thời gian sau lần cuối cùng của chuỗi VCPU
kiểm tra kvm_request_pending() và trước khi nó vào chế độ khách, như kick
IPI sẽ chỉ kích hoạt các lần thoát chế độ khách đối với các luồng VCPU ở chế độ khách
chế độ hoặc ít nhất đã vô hiệu hóa các ngắt để chuẩn bị
vào chế độ khách.  Điều này có nghĩa là việc triển khai được tối ưu hóa (xem "IPI
Giảm") phải chắc chắn khi nào thì an toàn để không gửi IPI.  một
giải pháp mà tất cả các kiến trúc ngoại trừ s390 đều áp dụng là:

- đặt ZZ0000ZZ thành IN_GUEST_MODE giữa việc vô hiệu hóa các ngắt và
  lần kiểm tra kvm_request_pending() cuối cùng;
- kích hoạt ngắt nguyên tử khi vào khách.

Giải pháp này cũng yêu cầu các rào cản về bộ nhớ phải được đặt cẩn thận trong cả
luồng yêu cầu và VCPU nhận.  Với những rào cản về trí nhớ, chúng ta
có thể loại trừ khả năng quan sát luồng VCPU
!kvm_request_pending() trong lần kiểm tra cuối cùng và sau đó không nhận được IPI cho
yêu cầu tiếp theo được thực hiện, ngay cả khi yêu cầu được thực hiện ngay sau đó
tấm séc.  Điều này được thực hiện bằng mô hình rào cản bộ nhớ Dekker
(kịch bản 10 của [lwn-mb]_).  Vì mẫu Dekker yêu cầu hai biến,
giải pháp này kết hợp ZZ0000ZZ với ZZ0001ZZ.  Thay thế
chúng vào mẫu mang lại::

CPU1 CPU2
  =====================================
  local_irq_disable();
  WRITE_ONCE(vcpu->chế độ, IN_GUEST_MODE);  kvm_make_request(REQ, vcpu);
  smp_mb();                               smp_mb();
  if (kvm_request_pending(vcpu)) { if (READ_ONCE(vcpu->mode) ==
                                              IN_GUEST_MODE) {
      ...abort guest entry...                 ...send IPI...
} }

Như đã nêu ở trên, IPI chỉ hữu ích cho các luồng VCPU ở chế độ khách hoặc
đã vô hiệu hóa các ngắt.  Đây là lý do tại sao trường hợp cụ thể này của
mẫu Dekker đã được mở rộng để vô hiệu hóa các ngắt trước khi cài đặt
ZZ0000ZZ đến IN_GUEST_MODE.  WRITE_ONCE() và READ_ONCE() được sử dụng để
thực hiện một cách mô phạm mô hình rào cản bộ nhớ, đảm bảo
trình biên dịch không can thiệp vào kế hoạch cẩn thận của ZZ0001ZZ
truy cập.

Giảm IPI
-------------

Vì chỉ cần một IPI để có VCPU nhằm kiểm tra bất kỳ/tất cả các yêu cầu,
sau đó chúng có thể được kết hợp lại.  Điều này được thực hiện dễ dàng bằng cách có IPI đầu tiên
gửi cú đá cũng thay đổi chế độ VCPU thành một cái gì đó !IN_GUEST_MODE.  các
trạng thái chuyển tiếp, EXITING_GUEST_MODE, được sử dụng cho mục đích này.

Chờ đợi sự thừa nhận
----------------------------

Một số yêu cầu, những yêu cầu có cờ KVM_REQUEST_WAIT được đặt, yêu cầu IPI phải
được gửi đi và những xác nhận sẽ được chờ đợi, ngay cả khi mục tiêu
Các luồng VCPU ở các chế độ khác với IN_GUEST_MODE.  Ví dụ, một trường hợp
là khi một luồng VCPU đích ở chế độ READING_SHADOW_PAGE_TABLES,
được thiết lập sau khi vô hiệu hóa các ngắt.  Để hỗ trợ những trường hợp này,
Cờ KVM_REQUEST_WAIT thay đổi điều kiện gửi IPI từ
kiểm tra xem VCPU có phải là IN_GUEST_MODE hay không và kiểm tra xem nó có phải không
OUTSIDE_GUEST_MODE.

Cú đá VCPU không yêu cầu
-----------------------

Vì việc xác định có gửi IPI hay không phụ thuộc vào
mẫu rào cản bộ nhớ Dekker hai biến, thì rõ ràng là
Những cú đá VCPU không có yêu cầu gần như không bao giờ chính xác.  Không có sự đảm bảo
rằng cú đá tạo ra không phải IPI vẫn sẽ dẫn đến hành động của cầu thủ
nhận VCPU, giống như lần kiểm tra kvm_request_pending() cuối cùng đối với
những cú đá kèm theo yêu cầu, thì cú đá đó có thể không có tác dụng gì hữu ích
tất cả.  Ví dụ: nếu một cú đá không có yêu cầu được thực hiện đối với VCPU
sắp đặt chế độ của nó thành IN_GUEST_MODE, nghĩa là không có IPI nào được gửi, sau đó
luồng VCPU có thể tiếp tục mục nhập của nó mà không thực sự hoàn thành
bất kể đó là cú đá có ý nghĩa gì để bắt đầu.

Một ngoại lệ là cơ chế ngắt được đăng của x86.  Tuy nhiên, trong trường hợp này,
ngay cả cú đá VCPU không yêu cầu cũng được kết hợp với cùng một
mẫu local_irq_disable() + smp_mb() được mô tả ở trên; bit BẬT
(Thông báo nổi bật) trong bộ mô tả ngắt đã đăng sẽ lấy
vai trò của ZZ0000ZZ.  Khi gửi một ngắt đã đăng, PIR.ON là
đặt trước khi đọc ZZ0001ZZ; kép, trong chuỗi VCPU,
vmx_sync_pir_to_irr() đọc PIR sau khi đặt ZZ0002ZZ thành
IN_GUEST_MODE.

Cân nhắc bổ sung
=========================

VCPU đang ngủ
--------------

Các luồng VCPU có thể cần xem xét các yêu cầu trước và/hoặc sau khi gọi
các chức năng có thể khiến họ ngủ, ví dụ: kvm_vcpu_block().  Liệu họ
làm hay không, và nếu có, những yêu cầu nào cần được xem xét, là
phụ thuộc vào kiến trúc.  kvm_vcpu_block() gọi kvm_arch_vcpu_runnable()
để kiểm tra xem nó có nên thức dậy không.  Một lý do để làm như vậy là để cung cấp
kiến trúc một chức năng trong đó các yêu cầu có thể được kiểm tra nếu cần thiết.

Tài liệu tham khảo
==========

.. [atomic-ops] Documentation/atomic_bitops.txt and Documentation/atomic_t.txt
.. [memory-barriers] Documentation/memory-barriers.txt
.. [lwn-mb] https://lwn.net/Articles/573436/