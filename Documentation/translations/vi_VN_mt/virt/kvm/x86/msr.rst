.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/x86/msr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
MSR dành riêng cho KVM
======================

:Tác giả: Glauber Costa <glommer@redhat.com>, Red Hat Inc, 2010

KVM sử dụng một số MSR tùy chỉnh để phục vụ một số yêu cầu.

Các MSR tùy chỉnh có một phạm vi dành riêng cho chúng, bắt đầu từ
0x4b564d00 đến 0x4b564dff. Có MSR bên ngoài khu vực này,
nhưng chúng không được dùng nữa và việc sử dụng chúng không được khuyến khích.

Danh sách MSR tùy chỉnh
---------------

Danh sách MSR tùy chỉnh được hỗ trợ hiện tại là:

MSR_KVM_WALL_CLOCK_NEW:
	0x4b564d00

dữ liệu:
	Địa chỉ vật lý căn chỉnh 4 byte của vùng bộ nhớ phải được
	trong khách RAM. Bộ nhớ này dự kiến sẽ chứa một bản sao của nội dung sau
	cấu trúc::

cấu trúc pvclock_wall_clock {
		phiên bản u32;
		u32 giây;
		u32 nsec;
	  } __thuộc tính__((__ được đóng gói__));

dữ liệu của họ sẽ được điền vào bởi hypervisor. Trình ảo hóa chỉ
	đảm bảo cập nhật dữ liệu này tại thời điểm ghi MSR.
	Người dùng muốn truy vấn thông tin này nhiều lần một cách đáng tin cậy có
	để viết nhiều lần vào MSR này. Các trường có ý nghĩa sau:

phiên bản:
		khách phải kiểm tra phiên bản trước và sau khi lấy
		thông tin về thời gian và kiểm tra xem chúng có bằng nhau và chẵn không.
		Phiên bản lẻ cho biết đang có bản cập nhật.

giây:
		 số giây cho đồng hồ treo tường tại thời điểm khởi động.

nsec:
		 số nano giây cho đồng hồ treo tường tại thời điểm khởi động.

Để có được thời gian treo tường hiện tại, system_time từ
	MSR_KVM_SYSTEM_TIME_NEW cần được thêm vào.

Lưu ý rằng mặc dù MSR là các thực thể trên mỗi CPU, nhưng tác động của điều này
	MSR cụ thể là toàn cầu.

Tính khả dụng của MSR này phải được kiểm tra qua bit 3 trong 0x4000001 cpuid
	lá trước khi sử dụng.

MSR_KVM_SYSTEM_TIME_NEW:
	0x4b564d01

dữ liệu:
	Địa chỉ vật lý được căn chỉnh 4 byte của vùng bộ nhớ phải nằm trong
	khách RAM, cộng với một bit kích hoạt ở bit 0. Bộ nhớ này dự kiến sẽ giữ
	một bản sao của cấu trúc sau::

cấu trúc pvclock_vcpu_time_info {
		phiên bản u32;
		u32 pad0;
		u64 tsc_timestamp;
		u64 system_time;
		u32 tsc_to_system_mul;
		s8 tsc_shift;
		cờ u8;
		đệm u8[2];
	  } __thuộc tính__((__ được đóng gói__)); /* 32 byte */

dữ liệu của họ sẽ được trình ảo hóa điền vào theo định kỳ. Chỉ có một
	viết hoặc đăng ký là cần thiết cho mỗi VCPU. Khoảng thời gian giữa
	các cập nhật của cấu trúc này là tùy ý và phụ thuộc vào việc triển khai.
	Trình ảo hóa có thể cập nhật cấu trúc này bất cứ lúc nào nó thấy phù hợp cho đến khi
	bất cứ điều gì có bit0 == 0 đều được ghi vào nó.

Các trường có ý nghĩa sau:

phiên bản:
		khách phải kiểm tra phiên bản trước và sau khi lấy
		thông tin về thời gian và kiểm tra xem chúng có bằng nhau và chẵn không.
		Phiên bản lẻ cho biết đang có bản cập nhật.

tsc_timestamp:
		giá trị tsc tại VCPU hiện tại tại thời điểm đó
		cập nhật của cấu trúc này. Khách có thể trừ giá trị này
		từ tsc hiện tại để rút ra khái niệm về thời gian đã trôi qua kể từ
		cập nhật cấu trúc.

hệ thống_thời gian:
		một khái niệm chủ yếu về thời gian đơn điệu, bao gồm cả giấc ngủ
		thời điểm cấu trúc này được cập nhật lần cuối. Đơn vị là
		nano giây.

tsc_to_system_mul:
		hệ số nhân được sử dụng khi chuyển đổi
		số lượng liên quan đến tsc đến nano giây

tsc_shift:
		shift sẽ được sử dụng khi chuyển đổi liên quan đến tsc
		lượng đến nano giây. Sự thay đổi này sẽ đảm bảo rằng
		phép nhân với tsc_to_system_mul không bị tràn.
		Giá trị dương biểu thị sự dịch chuyển trái, giá trị âm biểu thị sự dịch chuyển sang trái
		một sự thay đổi đúng đắn.

Việc chuyển đổi từ tsc sang nano giây liên quan đến một bước bổ sung
		dịch chuyển phải 32 bit. Với thông tin này, du khách có thể
		lấy được thời gian trên mỗi CPU bằng cách thực hiện ::

thời gian = (current_tsc - tsc_timestamp)
			nếu (tsc_shift >= 0)
				thời gian <<= tsc_shift;
			khác
				thời gian >>= -tsc_shift;
			thời gian = (thời gian * tsc_to_system_mul) >> 32
			thời gian = thời gian + system_time

cờ:
		các bit trong trường này biểu thị khả năng mở rộng
		phối hợp giữa khách và hypervisor. sẵn có
		các cờ cụ thể phải được kiểm tra trong lá cpuid 0x40000001.
		Cờ hiện tại là:


+----------+--------------+-----------------------------------+
		ZZ0000ZZ bit cpuid ZZ0001ZZ
		+----------+--------------+-----------------------------------+
		ZZ0002ZZ ZZ0003ZZ
		ZZ0004ZZ 24 ZZ0005ZZ
		ZZ0006ZZ ZZ0007ZZ
		+----------+--------------+-----------------------------------+
		ZZ0008ZZ ZZ0009ZZ
		ZZ0010ZZ Không áp dụng ZZ0011ZZ
		ZZ0012ZZ ZZ0013ZZ
		+----------+--------------+-----------------------------------+

Tính khả dụng của MSR này phải được kiểm tra qua bit 3 trong 0x4000001 cpuid
	lá trước khi sử dụng.


MSR_KVM_WALL_CLOCK:
	0x11

dữ liệu và hoạt động:
	tương tự như MSR_KVM_WALL_CLOCK_NEW. Thay vào đó hãy sử dụng nó.

MSR này nằm ngoài phạm vi KVM dành riêng và có thể bị xóa trong
	tương lai. Việc sử dụng nó không được dùng nữa.

Tính khả dụng của MSR này phải được kiểm tra qua bit 0 trong 0x4000001 cpuid
	lá trước khi sử dụng.

MSR_KVM_SYSTEM_TIME:
	0x12

dữ liệu và hoạt động:
	tương tự như MSR_KVM_SYSTEM_TIME_NEW. Thay vào đó hãy sử dụng nó.

MSR này nằm ngoài phạm vi KVM dành riêng và có thể bị xóa trong
	tương lai. Việc sử dụng nó không được dùng nữa.

Tính khả dụng của MSR này phải được kiểm tra qua bit 0 trong 0x4000001 cpuid
	lá trước khi sử dụng.

Thuật toán được đề xuất để phát hiện sự hiện diện của kvmclock là ::

if (!kvm_para_available()) /* tham khảo cpuid.txt */
			trả lại NON_PRESENT;

cờ = cpuid_eax(0x40000001);
		nếu (cờ & 3) {
			msr_kvm_system_time = MSR_KVM_SYSTEM_TIME_NEW;
			msr_kvm_wall_clock = MSR_KVM_WALL_CLOCK_NEW;
			trả lại PRESENT;
		} khác nếu (cờ & 0) {
			msr_kvm_system_time = MSR_KVM_SYSTEM_TIME;
			msr_kvm_wall_clock = MSR_KVM_WALL_CLOCK;
			trả lại PRESENT;
		} khác
			trả lại NON_PRESENT;

MSR_KVM_ASYNC_PF_EN:
	0x4b564d02

dữ liệu:
	Kiểm soát lỗi trang không đồng bộ (APF) MSR.

Bit 63-6 giữ địa chỉ vật lý được căn chỉnh 64 byte của vùng bộ nhớ 64 byte
	phải có trong khách RAM. Bộ nhớ này dự kiến sẽ lưu giữ
	cấu trúc sau::

cấu trúc kvm_vcpu_pv_apf_data {
		/* Được sử dụng cho các sự kiện 'trang không có mặt' được gửi qua #PF */
		__u32 cờ;

/* Được sử dụng cho các sự kiện 'trang sẵn sàng' được gửi qua thông báo gián đoạn */
		__u32 mã thông báo;

__u8 pad[56];
	  };

Các bit 5-4 của MSR được dự trữ và phải bằng 0. Bit 0 được đặt thành 1
	khi lỗi trang không đồng bộ được bật trên vcpu, 0 khi bị tắt.
	Bit 1 là 1 nếu lỗi trang không đồng bộ có thể được đưa vào khi vcpu hoạt động
	cpl == 0. Bit 2 là 1 nếu lỗi trang không đồng bộ được gửi tới L1 dưới dạng
	#PF vmexit.  Bit 2 chỉ có thể được đặt nếu KVM_FEATURE_ASYNC_PF_VMEXIT được
	có mặt trong CPUID. Bit 3 cho phép phân phối 'trang sẵn sàng' dựa trên ngắt
	sự kiện. Bit 3 chỉ có thể được đặt nếu KVM_FEATURE_ASYNC_PF_INT có trong
	CPUID.

Các sự kiện 'Trang không có mặt' hiện luôn được phân phối dưới dạng tổng hợp
	Ngoại lệ #PF. Trong quá trình phân phối các sự kiện này, thanh ghi APF CR2 chứa
	một mã thông báo sẽ được sử dụng để thông báo cho khách khi trang bị thiếu
	có sẵn. Ngoài ra, để có thể phân biệt giữa #PF thật và
	APF, 4 byte đầu tiên của vị trí bộ nhớ 64 byte ('cờ') sẽ được ghi
	bởi hypervisor tại thời điểm tiêm. Chỉ bit đầu tiên của 'cờ'
	hiện đang được hỗ trợ, khi được đặt, nó cho biết khách đang giao dịch
	với sự kiện 'trang không có mặt' không đồng bộ. Nếu trong một trang bị lỗi APF
	'cờ' là '0' có nghĩa đây là lỗi trang thông thường. Khách là
	phải xóa 'cờ' khi xử lý xong ngoại lệ #PF để
	sự kiện tiếp theo có thể được chuyển giao.

Lưu ý, vì các sự kiện 'không có trang' của APF sử dụng cùng một vectơ ngoại lệ
	như lỗi trang thông thường, khách phải đặt lại 'cờ' thành '0' trước khi lỗi xảy ra
	một cái gì đó có thể tạo ra lỗi trang bình thường.

Byte 4-7 của vị trí bộ nhớ 64 byte ('mã thông báo') sẽ được ghi vào bởi
	hypervisor tại thời điểm chèn sự kiện APF 'sẵn sàng trang'. Nội dung
	trong số các byte này là mã thông báo đã được phân phối trước đó trong CR2 dưới dạng
	sự kiện 'trang không có mặt'. Sự kiện này cho biết trang hiện có sẵn.
	Khách phải viết '0' vào 'mã thông báo' khi xử lý xong
	sự kiện 'trang sẵn sàng' và ghi '1' vào MSR_KVM_ASYNC_PF_ACK sau
	dọn dẹp vị trí; việc ghi vào MSR buộc KVM phải quét lại
	xếp hàng và gửi thông báo đang chờ xử lý tiếp theo.

Lưu ý, MSR_KVM_ASYNC_PF_INT MSR chỉ định vectơ ngắt cho 'trang
	sẵn sàng' Việc phân phối APF cần được ghi vào trước khi kích hoạt cơ chế APF
	trong MSR_KVM_ASYNC_PF_EN hoặc ngắt #0 có thể được đưa vào. MSR là
	khả dụng nếu KVM_FEATURE_ASYNC_PF_INT có trong CPUID.

Lưu ý, trước đây, các sự kiện 'sẵn sàng trang' được phân phối qua cùng một #PF
	ngoại lệ là sự kiện 'trang không có mặt' nhưng tính năng này hiện không được dùng nữa. Nếu
	bit 3 (phân phối dựa trên ngắt) không được thiết lập Các sự kiện APF không được phân phối.

Nếu APF bị vô hiệu hóa trong khi có các APF chưa thanh toán, chúng sẽ
	không được giao.

Các sự kiện APF 'sẵn sàng trang' hiện tại sẽ luôn được phân phối trên
	vcpu giống như sự kiện 'trang không có mặt', nhưng khách không nên dựa vào
	đó.

MSR_KVM_STEAL_TIME:
	0x4b564d03

dữ liệu:
	Địa chỉ vật lý căn chỉnh 64 byte của vùng bộ nhớ phải được
	trong máy khách RAM, cộng với một bit kích hoạt ở bit 0. Bộ nhớ này dự kiến sẽ
	giữ một bản sao của cấu trúc sau::

cấu trúc kvm_steal_time {
		__u64 ăn trộm;
		__u32 phiên bản;
		__u32 cờ;
		__u8 chiếm trước;
		__u8 u8_pad[3];
		__u32 đệm[11];
	  }

dữ liệu của họ sẽ được trình ảo hóa điền vào theo định kỳ. Chỉ có một
	viết hoặc đăng ký là cần thiết cho mỗi VCPU. Khoảng thời gian giữa
	các cập nhật của cấu trúc này là tùy ý và phụ thuộc vào việc triển khai.
	Trình ảo hóa có thể cập nhật cấu trúc này bất cứ lúc nào nó thấy phù hợp cho đến khi
	bất cứ điều gì có bit0 == 0 đều được ghi vào nó. Khách hàng cần đảm bảo
	cấu trúc này được khởi tạo bằng 0.

Các trường có ý nghĩa sau:

phiên bản:
		một bộ đếm trình tự. Nói cách khác, khách phải kiểm tra
		trường này trước và sau khi lấy thông tin thời gian và thực hiện
		chắc chắn chúng đều bằng nhau và chẵn. Một phiên bản lẻ chỉ ra một
		đang trong quá trình cập nhật.

cờ:
		Tại thời điểm này, luôn luôn bằng không. Có thể dùng để chỉ
		những thay đổi trong cấu trúc này trong tương lai.

ăn trộm:
		khoảng thời gian mà vCPU này không chạy, trong
		nano giây. Thời gian mà vcpu không hoạt động sẽ không
		được báo cáo là thời gian ăn cắp.

ưu tiên:
		cho biết vCPU sở hữu cấu trúc này đang chạy hoặc
		không. Giá trị khác 0 có nghĩa là vCPU đã được ưu tiên. số không
		có nghĩa là vCPU không được ưu tiên. NOTE, nó luôn bằng 0 nếu
		trình ảo hóa không hỗ trợ trường này.

MSR_KVM_EOI_EN:
	0x4b564d04

dữ liệu:
	Bit 0 là 1 khi kết thúc ngắt PV được bật trên vcpu; 0
	khi bị vô hiệu hóa.  Bit 1 được dành riêng và phải bằng 0.  Khi PV kết thúc
	ngắt được bật (đặt bit 0), bit 63-2 giữ liên kết 4 byte
	địa chỉ vật lý của vùng bộ nhớ 4 byte phải nằm trong RAM của khách và
	phải bằng không.

Bit đầu tiên, ít quan trọng nhất của vị trí bộ nhớ 4 byte sẽ là
	được viết bởi hypervisor, thường là vào thời điểm bị gián đoạn
	tiêm.  Giá trị 1 có nghĩa là khách có thể bỏ qua việc ghi EOI vào apic
	(sử dụng ghi MSR hoặc MMIO); thay vào đó, nó đủ để báo hiệu
	EOI bằng cách xóa bit trong bộ nhớ khách - vị trí này sẽ
	sau đó sẽ được thăm dò bởi hypervisor.
	Giá trị 0 có nghĩa là cần phải ghi EOI.

Sẽ luôn an toàn nếu khách bỏ qua việc tối ưu hóa và thực hiện
	dù sao thì APIC EOI vẫn ghi.

Hypervisor được đảm bảo chỉ sửa đổi điều này ít nhất
	bit đáng kể trong bối cảnh VCPU hiện tại, điều này có nghĩa là
	khách không cần sử dụng tiền tố khóa hoặc thứ tự bộ nhớ
	nguyên thủy để đồng bộ hóa với bộ ảo hóa.

Tuy nhiên, trình ảo hóa có thể thiết lập và xóa bit bộ nhớ này bất kỳ lúc nào:
	do đó để đảm bảo trình ảo hóa không làm gián đoạn quá trình
	khách và xóa bit có ý nghĩa nhỏ nhất trong vùng bộ nhớ
	trong cửa sổ giữa khách kiểm tra nó để phát hiện
	liệu nó có thể bỏ qua việc ghi apic EOI và giữa các khách không
	xóa nó để báo hiệu EOI cho bộ ảo hóa,
	khách phải đọc cả bit có ý nghĩa nhỏ nhất trong vùng bộ nhớ và
	xóa nó bằng cách sử dụng một lệnh CPU duy nhất, chẳng hạn như kiểm tra và xóa, hoặc
	so sánh và trao đổi.

MSR_KVM_POLL_CONTROL:
	0x4b564d05

Kiểm soát việc bỏ phiếu phía máy chủ.

dữ liệu:
	Bit 0 cho phép (1) hoặc vô hiệu hóa (0) logic thăm dò HLT phía máy chủ.

Khách KVM có thể yêu cầu chủ nhà không thăm dò ý kiến trên HLT, chẳng hạn nếu
	họ đang tự mình thực hiện việc bỏ phiếu.

MSR_KVM_ASYNC_PF_INT:
	0x4b564d06

dữ liệu:
	Kiểm soát lỗi trang không đồng bộ thứ hai (APF) MSR.

Bit 0-7: Vectơ APIC để phân phối các sự kiện APF 'sẵn sàng trang'.
	Bit 8-63: Dự trữ

Vectơ ngắt để phân phối thông báo 'trang sẵn sàng' không đồng bộ.
	Vectơ phải được thiết lập trước cơ chế lỗi trang không đồng bộ
	được kích hoạt trong MSR_KVM_ASYNC_PF_EN.  MSR chỉ khả dụng nếu
	KVM_FEATURE_ASYNC_PF_INT có mặt trong CPUID.

MSR_KVM_ASYNC_PF_ACK:
	0x4b564d07

dữ liệu:
	Xác nhận lỗi trang không đồng bộ (APF).

Khi khách xử lý xong 'trang sẵn sàng' sự kiện APF và 'mã thông báo'
	trường trong 'struct kvm_vcpu_pv_apf_data' bị xóa, lẽ ra nó phải như vậy
	ghi '1' vào bit 0 của MSR, điều này khiến máy chủ quét lại hàng đợi của nó
	và kiểm tra xem có thêm thông báo nào đang chờ xử lý không. MSR có sẵn
	nếu KVM_FEATURE_ASYNC_PF_INT có trong CPUID.

MSR_KVM_MIGRATION_CONTROL:
        0x4b564d08

dữ liệu:
        MSR này khả dụng nếu KVM_FEATURE_MIGRATION_CONTROL có trong
        CPUID.  Bit 0 biểu thị liệu khách có được phép di chuyển trực tiếp hay không.

Khi khách bắt đầu, bit 0 sẽ là 0 nếu khách đã mã hóa
        bộ nhớ và 1 nếu khách không có bộ nhớ được mã hóa.  Nếu
        khách đang truyền đạt trạng thái mã hóa trang tới máy chủ bằng cách sử dụng
        Siêu cuộc gọi ZZ0000ZZ, nó có thể đặt bit 0 trong MSR này thành
        cho phép di chuyển trực tiếp của khách.