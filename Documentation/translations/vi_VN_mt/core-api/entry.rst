.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/entry.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Xử lý vào/ra các trường hợp ngoại lệ, ngắt, tòa nhà cao tầng và KVM
===================================================================

Tất cả các quá trình chuyển đổi giữa các miền thực thi đều yêu cầu cập nhật trạng thái.
phải tuân theo các ràng buộc đặt hàng nghiêm ngặt. Cập nhật trạng thái là cần thiết cho
sau đây:

* Lockdep
  * RCU / Theo dõi bối cảnh
  * Bộ đếm ưu tiên
  * Truy tìm
  * Kế toán thời gian

Thứ tự cập nhật phụ thuộc vào loại chuyển tiếp và được giải thích bên dưới trong phần
các phần loại chuyển tiếp: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ.

Mã không thể đo được - noinstr
---------------------------------

Hầu hết các cơ sở thiết bị đo đạc đều phụ thuộc vào RCU, vì vậy việc trang bị thiết bị đo đạc đều bị cấm
để lấy mã vào trước khi RCU bắt đầu xem và mã thoát sau khi RCU dừng
đang xem. Ngoài ra, nhiều kiến trúc phải lưu và khôi phục trạng thái đăng ký,
điều đó có nghĩa là (ví dụ) một điểm dừng trong mã mục nhập điểm dừng sẽ
ghi đè lên các thanh ghi gỡ lỗi của điểm dừng ban đầu.

Mã như vậy phải được đánh dấu bằng thuộc tính 'noinstr', đặt mã đó vào một
phần đặc biệt không thể tiếp cận được với các thiết bị đo đạc và gỡ lỗi. Một số
các chức năng có thể sử dụng được một phần, được xử lý bằng cách đánh dấu chúng
noinstr và sử dụng Instrumentation_begin() và Instrumentation_end() để gắn cờ
phạm vi mã có thể đo được:

.. code-block:: c

  noinstr void entry(void)
  {
  	handle_entry();     // <-- must be 'noinstr' or '__always_inline'
	...

	instrumentation_begin();
	handle_context();   // <-- instrumentable code
	instrumentation_end();

	...
	handle_exit();      // <-- must be 'noinstr' or '__always_inline'
  }

Điều này cho phép xác minh các hạn chế 'noinstr' thông qua objtool trên
các kiến trúc được hỗ trợ.

Việc gọi các hàm không thể đo lường được từ ngữ cảnh có thể đo lường được không có
hạn chế và rất hữu ích để bảo vệ, ví dụ: chuyển đổi trạng thái sẽ
gây ra sự cố nếu được lắp đặt.

Tất cả các phần mã vào/ra không thể sử dụng được trước và sau RCU
chuyển đổi trạng thái phải chạy với các ngắt bị vô hiệu hóa.

tòa nhà chọc trời
-----------------

Mã nhập hệ thống bắt đầu bằng mã hợp ngữ và gọi ra mã C cấp thấp
sau khi thiết lập các khung ngăn xếp và trạng thái dành riêng cho kiến trúc cấp thấp. Cái này
mã C cấp thấp không được sử dụng công cụ. Một chức năng xử lý syscall điển hình
được gọi từ mã lắp ráp cấp thấp trông như thế này:

.. code-block:: c

  noinstr void syscall(struct pt_regs *regs, int nr)
  {
	arch_syscall_enter(regs);
	nr = syscall_enter_from_user_mode(regs, nr);

	instrumentation_begin();
	if (!invoke_syscall(regs, nr) && nr != -1)
	 	result_reg(regs) = __sys_ni_syscall(regs);
	instrumentation_end();

	syscall_exit_to_user_mode(regs);
  }

syscall_enter_from_user_mode() trước tiên gọi enter_from_user_mode()
thiết lập trạng thái theo thứ tự sau:

* Lockdep
  * RCU / Theo dõi bối cảnh
  * Truy tìm

và sau đó gọi các hàm công việc nhập khác nhau như ptrace, seccomp, Audit,
theo dõi cuộc gọi tòa nhà, v.v. Sau khi hoàn thành tất cả, công cụ có thể gọi là seek_syscall
chức năng có thể được gọi. Phần mã có thể sử dụng được sẽ kết thúc, sau đó
syscall_exit_to_user_mode() được gọi.

syscall_exit_to_user_mode() xử lý mọi công việc cần làm trước đó
quay lại không gian người dùng như truy tìm, kiểm tra, tín hiệu, công việc, v.v. Sau
nó gọi exit_to_user_mode() để xử lý lại trạng thái
chuyển tiếp theo thứ tự ngược lại:

* Truy tìm
  * RCU / Theo dõi bối cảnh
  * Lockdep

syscall_enter_from_user_mode() và syscall_exit_to_user_mode() cũng vậy
có sẵn dưới dạng các hàm con chi tiết trong trường hợp mã kiến trúc
phải làm thêm công việc giữa các bước khác nhau. Trong những trường hợp như vậy phải
đảm bảo rằng enter_from_user_mode() được gọi đầu tiên khi nhập và
exit_to_user_mode() được gọi cuối cùng khi thoát.

Không lồng các cuộc gọi tòa nhà. Các tòa nhà cao tầng lồng nhau sẽ gây ra RCU và/hoặc theo dõi ngữ cảnh
để in cảnh báo.

KVM
---

Việc vào hoặc thoát chế độ khách rất giống với syscalls. Từ máy chủ
quan điểm hạt nhân, CPU sẽ chuyển sang không gian người dùng khi vào
khách và quay lại kernel khi thoát.

guest_state_enter_irqoff() là một biến thể dành riêng cho KVM của exit_to_user_mode()
và guest_state_exit_irqoff() là biến thể KVM của enter_from_user_mode().
Các hoạt động trạng thái có cùng thứ tự.

Công việc xử lý công việc được thực hiện riêng cho khách tại ranh giới của
Vòng lặp vcpu_run() thông qua xfer_to_guest_mode_handle_work() là tập hợp con của
công việc được xử lý khi quay trở lại không gian người dùng.

Không lồng các chuyển tiếp vào/ra KVM vì làm như vậy là vô nghĩa.

Ngắt và ngoại lệ thường xuyên
---------------------------------

Việc xử lý ngắt vào và ra phức tạp hơn một chút so với syscalls
và chuyển tiếp KVM.

Nếu một ngắt xuất hiện trong khi CPU thực thi trong không gian người dùng, thì mục nhập
và việc xử lý thoát hoàn toàn giống như đối với các cuộc gọi chung.

Nếu ngắt được nâng lên trong khi CPU thực thi trong không gian kernel thì mục nhập và
xử lý thoát hơi khác một chút. Trạng thái RCU chỉ được cập nhật khi
ngắt được nêu ra trong bối cảnh tác vụ nhàn rỗi của CPU. Nếu không, RCU sẽ
đang xem rồi. Lockdep và truy tìm phải được cập nhật vô điều kiện.

irqentry_enter() và irqentry_exit() cung cấp cách triển khai cho việc này.

Phần dành riêng cho kiến ​​trúc trông tương tự như xử lý cuộc gọi tòa nhà:

.. code-block:: c

  noinstr void interrupt(struct pt_regs *regs, int nr)
  {
	arch_interrupt_enter(regs);
	state = irqentry_enter(regs);

	instrumentation_begin();

	irq_enter_rcu();
	invoke_irq_handler(regs, nr);
	irq_exit_rcu();

	instrumentation_end();

	irqentry_exit(regs, state);
  }

Lưu ý rằng việc gọi trình xử lý ngắt thực tế nằm trong phạm vi
cặp irq_enter_rcu() và irq_exit_rcu().

irq_enter_rcu() cập nhật số lượng quyền ưu tiên tạo nên in_hardirq()
trả về true, xử lý trạng thái đánh dấu NOHZ và tính toán thời gian gián đoạn. Cái này
có nghĩa là đến mức irq_enter_rcu() được gọi in_hardirq()
trả về sai.

irq_exit_rcu() xử lý việc tính toán thời gian gián đoạn, hủy bỏ quyền ưu tiên
cập nhật số lượng và cuối cùng xử lý các ngắt mềm và trạng thái đánh dấu NOHZ.

Về lý thuyết, số lượng quyền ưu tiên có thể được cập nhật trong irqentry_enter(). trong
thực hành, việc trì hoãn cập nhật này thành irq_enter_rcu() sẽ cho phép tính số lần ưu tiên
mã cần truy tìm, đồng thời duy trì tính đối xứng với irq_exit_rcu() và
irqentry_exit(), được mô tả trong đoạn tiếp theo. Nhược điểm duy nhất
là mã nhập sớm lên tới irq_enter_rcu() phải biết rằng
số lượng quyền ưu tiên vẫn chưa được cập nhật với trạng thái HARDIRQ_OFFSET.

Lưu ý rằng irq_exit_rcu() phải xóa HARDIRQ_OFFSET khỏi số lần ưu tiên
trước khi nó xử lý các ngắt mềm, trình xử lý của chúng phải chạy trong ngữ cảnh BH thay vì
hơn bối cảnh bị vô hiệu hóa irq. Ngoài ra, irqentry_exit() có thể lên lịch, điều này
cũng yêu cầu HARDIRQ_OFFSET phải được loại bỏ khỏi số lượng quyền ưu tiên.

Mặc dù các trình xử lý ngắt dự kiến sẽ chạy với các ngắt cục bộ
bị vô hiệu hóa, việc lồng ngắt là phổ biến từ góc độ vào/ra. cho
ví dụ: việc xử lý softirq xảy ra trong khối irqentry_{enter,exit}() với
ngắt cục bộ được kích hoạt. Ngoài ra, mặc dù không phổ biến nhưng không có gì ngăn cản được
trình xử lý ngắt kích hoạt lại các ngắt.

Mã vào/ra ngắt không nhất thiết phải xử lý việc vào lại, vì nó
chạy với các ngắt cục bộ bị vô hiệu hóa. Nhưng NMI có thể xảy ra bất cứ lúc nào và rất nhiều
mã vào được chia sẻ giữa hai người.

Các trường hợp ngoại lệ giống NMI và NMI
----------------------------------------

Các ngoại lệ giống NMI và NMI (kiểm tra máy, lỗi kép, gỡ lỗi
ngắt, v.v.) có thể ảnh hưởng đến bất kỳ ngữ cảnh nào và phải hết sức cẩn thận với
nhà nước.

Các thay đổi trạng thái đối với ngoại lệ gỡ lỗi và ngoại lệ kiểm tra máy phụ thuộc vào
liệu những trường hợp ngoại lệ này có xảy ra trong không gian người dùng (điểm dừng hoặc điểm theo dõi) hay không
ở chế độ kernel (vá mã). Từ không gian người dùng, họ được đối xử như
các ngắt, trong khi ở chế độ kernel, chúng được xử lý như NMI.

NMI và các trường hợp ngoại lệ giống NMI khác xử lý việc chuyển đổi trạng thái mà không cần
phân biệt giữa nguồn gốc chế độ người dùng và chế độ kernel.

Cập nhật trạng thái khi nhập được xử lý trong irqentry_nmi_enter() cập nhật
nêu theo trình tự sau:

* Bộ đếm ưu tiên
  * Lockdep
  * RCU / Theo dõi bối cảnh
  * Truy tìm

Đối tác thoát irqentry_nmi_exit() thực hiện thao tác ngược lại trong
thứ tự ngược lại.

Lưu ý rằng việc cập nhật bộ đếm ưu tiên phải là lần đầu tiên
thao tác khi nhập và thao tác cuối cùng khi thoát. Lý do là cả hai
lockdep và RCU dựa vào in_nmi() trả về true trong trường hợp này. các
Không được sửa đổi số quyền ưu tiên trong trường hợp vào/ra NMI
truy tìm.

Mã dành riêng cho kiến ​​trúc trông như thế này:

.. code-block:: c

  noinstr void nmi(struct pt_regs *regs)
  {
	arch_nmi_enter(regs);
	state = irqentry_nmi_enter(regs);

	instrumentation_begin();
	nmi_handler(regs);
	instrumentation_end();

	irqentry_nmi_exit(regs);
  }

và ví dụ: một ngoại lệ gỡ lỗi có thể trông như thế này:

.. code-block:: c

  noinstr void debug(struct pt_regs *regs)
  {
	arch_nmi_enter(regs);

	debug_regs = save_debug_regs();

	if (user_mode(regs)) {
		state = irqentry_enter(regs);

		instrumentation_begin();
		user_mode_debug_handler(regs, debug_regs);
		instrumentation_end();

		irqentry_exit(regs, state);
  	} else {
  		state = irqentry_nmi_enter(regs);

		instrumentation_begin();
		kernel_mode_debug_handler(regs, debug_regs);
		instrumentation_end();

		irqentry_nmi_exit(regs, state);
	}
  }

Không có hàm irqentry_nmi_if_kernel() kết hợp nào có sẵn dưới dạng
ở trên không thể được xử lý theo cách bất khả tri ngoại lệ.

NMI có thể xảy ra trong bất kỳ bối cảnh nào. Ví dụ: một ngoại lệ giống NMI được kích hoạt
trong khi xử lý NMI. Vì vậy, mã nhập NMI phải được cấp lại và cập nhật trạng thái
cần xử lý việc lồng nhau.
