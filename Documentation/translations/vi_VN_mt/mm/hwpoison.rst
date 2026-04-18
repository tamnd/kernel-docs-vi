.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/hwpoison.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
chất độc
========

hwpoison là gì?
=================

Các CPU Intel sắp ra mắt có hỗ trợ khôi phục một số lỗi bộ nhớ
(ZZ0000ZZ). Điều này yêu cầu HĐH phải tuyên bố một trang "bị nhiễm độc",
tiêu diệt các tiến trình liên quan đến nó và tránh sử dụng nó trong tương lai.

Bộ vá này triển khai cơ sở hạ tầng cần thiết trong VM.

Để trích dẫn nhận xét tổng quan ::

Trình xử lý kiểm tra máy cấp cao. Xử lý các trang được báo cáo bởi
	phần cứng bị hỏng thường do bộ nhớ hoặc bộ nhớ đệm ECC 2bit
	thất bại.

Điều này tập trung vào các trang được phát hiện là bị hỏng trong nền.
	Khi CPU hiện tại cố gắng tiêu diệt tham nhũng hiện tại
	Thay vào đó, quá trình đang chạy có thể bị giết trực tiếp. Điều này ngụ ý
	rằng nếu lỗi không thể xử lý được vì lý do nào đó thì có thể an toàn
	cứ bỏ qua nó vì chưa có tham nhũng nào được tiêu thụ. Thay vào đó
	khi điều đó xảy ra, một cuộc kiểm tra máy khác sẽ diễn ra.

Xử lý các trang bộ đệm trang ở nhiều trạng thái khác nhau. Phần khó khăn
	ở đây là chúng ta có thể truy cập bất kỳ trang nào không đồng bộ với máy ảo khác
	người dùng, vì lỗi bộ nhớ có thể xảy ra mọi lúc, mọi nơi,
	có thể vi phạm một số giả định của họ. Đây là lý do tại sao mã này
	phải cực kỳ cẩn thận. Nói chung nó cố gắng sử dụng khóa thông thường
	các quy tắc, chẳng hạn như lấy các ổ khóa tiêu chuẩn, ngay cả khi điều đó có nghĩa là
	việc xử lý lỗi có thể mất nhiều thời gian.

Một số hoạt động ở đây có phần kém hiệu quả và không có
	độ phức tạp của thuật toán tuyến tính, bởi vì cấu trúc dữ liệu chưa
	đã được tối ưu hóa cho trường hợp này. Đây là trường hợp đặc biệt
	để ánh xạ từ vma tới một tiến trình. Vì trường hợp này được mong đợi
	hiếm khi chúng tôi hy vọng chúng tôi có thể thoát khỏi điều này.

Mã bao gồm trình xử lý cấp cao trong mm/memory-failure.c,
một trang mới bị nhiễm độc và nhiều bước kiểm tra khác nhau trong VM để xử lý các trang bị nhiễm độc
trang.

Mục tiêu chính hiện nay là khách KVM, nhưng nó phù hợp với mọi loại khách
của các ứng dụng. Hỗ trợ KVM yêu cầu bản phát hành qemu-kvm gần đây.

Để sử dụng KVM, cần có loại tín hiệu mới để
KVM có thể đưa thông tin kiểm tra máy vào khách bằng cách thích hợp
địa chỉ. Về lý thuyết, điều này cho phép các ứng dụng khác xử lý
lỗi bộ nhớ quá. Kỳ vọng là hầu hết các ứng dụng
sẽ không làm điều đó, nhưng một số cái rất chuyên biệt thì có thể.

Chế độ phục hồi lỗi
======================

Có hai (thực tế là ba) chế độ phục hồi lỗi bộ nhớ có thể ở:

vm.memory_failure_recovery sysctl được đặt thành 0:
	Tất cả các lỗi bộ nhớ đều gây ra sự hoảng loạn. Đừng cố gắng phục hồi.

giết sớm
	(có thể được kiểm soát trên toàn cầu và theo từng quy trình)
	Gửi SIGBUS tới ứng dụng ngay khi phát hiện lỗi
	Điều này cho phép các ứng dụng có thể xử lý lỗi bộ nhớ một cách nhẹ nhàng
	cách (ví dụ: thả đối tượng bị ảnh hưởng)
	Đây là chế độ được KVM qemu sử dụng.

giết muộn
	Gửi SIGBUS khi ứng dụng chạy vào trang bị hỏng.
	Điều này là tốt nhất cho các ứng dụng không biết lỗi bộ nhớ và mặc định
	Lưu ý một số trang luôn được xử lý dưới dạng tiêu diệt muộn.

Kiểm soát người dùng
============

vm.memory_failure_recovery
	Xem sysctl.txt

vm.memory_failure_early_kill
	Kích hoạt chế độ tiêu diệt sớm trên toàn cầu

PR_MCE_KILL
	Đặt chế độ tiêu diệt sớm/muộn/hoàn nguyên về mặc định hệ thống

arg1: PR_MCE_KILL_CLEAR:
		Hoàn nguyên về mặc định của hệ thống
	arg1: PR_MCE_KILL_SET:
		arg2 xác định chế độ cụ thể của luồng

PR_MCE_KILL_EARLY:
			Giết sớm
		PR_MCE_KILL_LATE:
			Giết muộn
		PR_MCE_KILL_DEFAULT
			Sử dụng mặc định chung của hệ thống

Lưu ý rằng nếu bạn muốn có một luồng chuyên dụng xử lý
	SIGBUS(BUS_MCEERR_AO) thay mặt cho quy trình, bạn nên
	gọi prctl(PR_MCE_KILL_EARLY) trên chuỗi được chỉ định. Nếu không,
	SIGBUS được gửi đến luồng chính.

PR_MCE_KILL_GET
	trở lại chế độ hiện tại

Kiểm tra
=======

* madvise(MADV_HWPOISON, ....) (với quyền root) - Đầu độc một trang trong
  quá trình thử nghiệm

* mô-đun hwpoison-tiêm thông qua debugfs ZZ0000ZZ

tham nhũng-pfn
	Tiêm lỗi hwpoison tại PFN vang vọng vào tập tin này. Điều này không
	một số tính năng lọc sớm để tránh các trang không mong muốn bị hỏng trong bộ thử nghiệm.

unpoison-pfn
	Trang giải độc phần mềm tại PFN vang vọng vào tập tin này. Lối này
	một trang có thể được sử dụng lại một lần nữa.  Điều này chỉ hoạt động cho Linux
	lỗi được chèn vào, không phải lỗi bộ nhớ thực. Một khi bất kỳ phần cứng nào
	lỗi bộ nhớ xảy ra, tính năng này bị tắt.

Lưu ý các giao diện tiêm này không ổn định và có thể thay đổi giữa
  phiên bản hạt nhân

tham nhũng-lọc-dev-chính, tham nhũng-lọc-dev-thứ yếu
	Chỉ xử lý lỗi bộ nhớ đối với các trang được liên kết với tệp
	hệ thống được xác định bởi khối thiết bị chính/phụ.  -1U là
	giá trị ký tự đại diện.  Điều này chỉ nên được sử dụng để thử nghiệm với
	tiêm nhân tạo.

bộ lọc-memcg bị hỏng
	Giới hạn việc tiêm vào các trang thuộc sở hữu của memgroup. Được chỉ định bởi inode
	số lượng của memcg.

Ví dụ::

mkdir /sys/fs/cgroup/mem/hwpoison

sử dụngmem -m 100 -s 1000 &
		echo ZZ0000ZZ > /sys/fs/cgroup/mem/hwpoison/tác vụ

memcg_ino=$(ls -id /sys/fs/cgroup/mem/hwpoison | cut -f1 -d' ')
		echo $memcg_ino > /debug/hwpoison/corrupt-filter-memcg

loại trang -p ZZ0000ZZ --hwpoison # shall không làm gì cả
		page-types -p ZZ0001ZZ --hwpoison # poison các trang của nó

tham nhũng-lọc-cờ-mặt nạ, tham nhũng-lọc-cờ-giá trị
	Khi được chỉ định, chỉ các trang độc hại nếu ((page_flags & mặt nạ) ==
	giá trị).  Điều này cho phép kiểm tra sức chịu đựng của nhiều loại
	trang. page_flags giống như trong /proc/kpageflags. các
	bit cờ được xác định trong include/linux/kernel-page-flags.h và
	được ghi lại trong Documentation/admin-guide/mm/pagemap.rst

* Kiến trúc kim phun MCE cụ thể

x86 có mce-tiêm, mce-test

Một số chương trình kiểm tra độc tố di động trong mce-test, xem bên dưới.

Tài liệu tham khảo
==========

ZZ0000ZZ
	Trình bày tổng quan từ LinuxCon 09

git://git.kernel.org/pub/scm/utils/cpu/mce/mce-test.git
	Bộ thử nghiệm (các thử nghiệm di động cụ thể về hwpoison trong tsrc)

git://git.kernel.org/pub/scm/utils/cpu/mce/mce-inject.git
	kim phun cụ thể x86


Hạn chế
===========
- Không phải tất cả các loại trang đều được hỗ trợ và sẽ không bao giờ hỗ trợ. Hầu hết hạt nhân nội bộ
  không thể khôi phục các đối tượng, hiện tại chỉ có các trang LRU.

---
Andi Kleen, tháng 10 năm 2009
