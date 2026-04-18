.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/ppc-pv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Giao diện ảo PPC KVM
=================================

Nguyên tắc thực thi cơ bản mà KVM hoạt động trên PowerPC là chạy tất cả kernel
mã khoảng trắng trong PR=1 là không gian người dùng. Bằng cách này chúng ta bẫy tất cả những người có đặc quyền
hướng dẫn và có thể mô phỏng chúng cho phù hợp.

Thật không may đó cũng là sự sụp đổ. Có khá nhiều đặc quyền
các hướng dẫn đưa chúng ta trở lại bộ ảo hóa một cách không cần thiết mặc dù chúng
có thể được xử lý khác nhau.

Đây là những gì giao diện PV PPC giúp ích. Phải có hướng dẫn đặc quyền
và biến chúng thành những thứ không có đặc quyền với sự trợ giúp từ hypervisor.
Điều này giúp giảm chi phí ảo hóa khoảng 50% trên một số điểm chuẩn của tôi.

Mã cho giao diện đó có thể được tìm thấy trong Arch/powerpc/kernel/kvm*

Truy vấn sự tồn tại
======================

Để tìm hiểu xem chúng tôi có đang chạy trên KVM hay không, chúng tôi tận dụng cây thiết bị. Khi nào
Linux đang chạy trên KVM, tồn tại một nút/trình giám sát ảo. Nút đó chứa một
thuộc tính tương thích với giá trị "linux,kvm".

Khi bạn xác định rằng mình đang chạy trên KVM có khả năng PV, giờ đây bạn có thể sử dụng
siêu cuộc gọi như được mô tả dưới đây.

Siêu cuộc gọi KVM
==============

Bên trong nút /hypervisor của cây thiết bị có một thuộc tính được gọi là
'hướng dẫn hypercall'. Thuộc tính này chứa tối đa 4 opcode tạo nên
lên hypercall. Để gọi một siêu cuộc gọi, chỉ cần gọi những hướng dẫn này.

Các thông số như sau:

======== ================= ==================
	Đăng ký TẠI OUT
        ======== ================= ==================
	r0 - dễ bay hơi
	r3 Tham số thứ nhất Mã trả về
	r4 Tham số thứ 2 Giá trị đầu ra thứ 1
	r5 Tham số thứ 3 Giá trị đầu ra thứ 2
	r6 Tham số thứ 4 Giá trị đầu ra thứ 3
	r7 Tham số thứ 5 Giá trị đầu ra thứ 4
	r8 Tham số thứ 6 Giá trị đầu ra thứ 5
	r9 Tham số thứ 7 Giá trị đầu ra thứ 6
	r10 Tham số thứ 8 Giá trị đầu ra thứ 7
	số siêu cuộc gọi r11 giá trị đầu ra thứ 8
	r12 - dễ bay hơi
        ======== ================= ==================

Các định nghĩa siêu cuộc gọi được chia sẻ trong mã chung, vì vậy các số siêu cuộc gọi giống nhau
áp dụng cho x86 và powerpc giống nhau ngoại trừ mỗi hypercall KVM
cũng cần được ORed với mã nhà cung cấp KVM là (42 << 16).

Mã trả lại có thể như sau:

==== ============================
	Ý nghĩa mã
	==== ============================
	0 Thành công
	12 Hypercall không được triển khai
	<0 Lỗi
	==== ============================

Trang ma thuật
==============

Để cho phép liên lạc giữa hypervisor và khách, có một chia sẻ mới
trang chứa các phần của trạng thái đăng ký hiển thị của người giám sát. Khách có thể
ánh xạ trang được chia sẻ này bằng siêu âm KVM KVM_HC_PPC_MAP_MAGIC_PAGE.

Với siêu lệnh gọi này, khách luôn nhận được trang ma thuật được ánh xạ tại
vị trí mong muốn. Tham số đầu tiên cho biết địa chỉ hiệu quả khi
MMU được kích hoạt. Tham số thứ hai cho biết địa chỉ ở chế độ thực, nếu
áp dụng cho mục tiêu. Hiện tại, chúng tôi luôn ánh xạ trang tới -4096. Bằng cách này chúng tôi
có thể truy cập nó bằng cách sử dụng các hàm tải và lưu trữ tuyệt đối. Sau đây
hướng dẫn đọc trường đầu tiên của trang ma thuật::

ld rX, -4096(0)

Giao diện được thiết kế để có thể mở rộng nên sau này cần thêm
các thanh ghi bổ sung vào trang ma thuật. Nếu bạn thêm các trường vào trang ma thuật,
cũng xác định tính năng siêu cuộc gọi mới để cho biết rằng chủ nhà có thể cung cấp cho bạn nhiều hơn
sổ đăng ký. Chỉ khi máy chủ hỗ trợ các tính năng bổ sung thì hãy sử dụng chúng.

Bố cục trang ma thuật được mô tả bởi struct kvm_vcpu_arch_shared
trong Arch/powerpc/include/uapi/asm/kvm_para.h.

Tính năng trang ma thuật
===================

Khi ánh xạ trang ma thuật bằng siêu âm KVM KVM_HC_PPC_MAP_MAGIC_PAGE,
giá trị trả về thứ hai được chuyển cho khách. Giá trị trả về thứ hai này chứa
một bitmap của các tính năng có sẵn bên trong trang ma thuật.

Các cải tiến sau đây cho trang ma thuật hiện có sẵn:

========================================================================
  KVM_MAGIC_FEAT_SR Maps SR đăng ký r/w trong trang ma thuật
  Bản đồ KVM_MAGIC_FEAT_MAS0_TO_SPRG7 MASn, ESR, PIR và SPRG cao
  ========================================================================

Để biết các tính năng nâng cao trong trang ma thuật, vui lòng kiểm tra sự tồn tại của
tính năng trước khi sử dụng chúng!

Cờ trang ma thuật
================

Ngoài các tính năng cho biết liệu máy chủ có khả năng thực hiện một chức năng cụ thể hay không
tính năng chúng tôi cũng có một kênh để khách thông báo cho chủ nhà biết liệu nó có khả năng không
của một cái gì đó. Đây là những gì chúng tôi gọi là "cờ".

Cờ được chuyển đến máy chủ ở mức 12 bit thấp của Địa chỉ hiệu dụng.

Các cờ sau đây hiện có sẵn để khách hiển thị:

MAGIC_PAGE_FLAG_NOT_MAPPED_NX Khách xử lý các bit NX một cách chính xác khi viết trang ma thuật

Bit MSR
========

MSR chứa các bit yêu cầu sự can thiệp của bộ ảo hóa và các bit thực hiện
không yêu cầu sự can thiệp trực tiếp của hypervisor vì chúng chỉ được diễn giải
khi vào khách hoặc không có bất kỳ tác động nào đến hành vi của hypervisor.

Các bit sau đây được đặt an toàn bên trong máy khách:

-MSR_EE
  -MSR_RI

Nếu có bất kỳ bit nào khác thay đổi trong MSR, vui lòng vẫn sử dụng mtmsr(d).

Hướng dẫn vá lỗi
====================

Lệnh "ld" và "std" được chuyển thành lệnh "lwz" và "stw"
tương ứng trên các hệ thống 32-bit có độ lệch bổ sung là 4 để phù hợp với dung lượng lớn
độ bền.

Sau đây là danh sách ánh xạ mà nhân Linux thực hiện khi chạy dưới dạng
khách. Việc triển khai bất kỳ ánh xạ nào trong số đó là tùy chọn, vì các bẫy lệnh
cũng hoạt động trên trang được chia sẻ. Vì vậy, việc gọi các hướng dẫn đặc quyền vẫn hoạt động như
trước đây.

============================================================
từ đến
============================================================
mfmsr rX ld rX, magic_page->msr
mfsprg rX, 0 ld rX, magic_page->sprg0
mfsprg rX, 1 ld rX, magic_page->sprg1
mfsprg rX, 2 ld rX, magic_page->sprg2
mfsprg rX, 3 ld rX, magic_page->sprg3
mfsrr0 rX ld rX, magic_page->srr0
mfsrr1 rX ld rX, magic_page->srr1
mfdar rX ld rX, magic_page->dar
mfdsisr rX lwz rX, magic_page->dsisr

mtmsr rX std rX, magic_page->msr
mtsprg 0, rX std rX, magic_page->sprg0
mtsprg 1, rX std rX, magic_page->sprg1
mtsprg 2, rX std rX, magic_page->sprg2
mtsprg 3, rX std rX, magic_page->sprg3
mtsrr0 rX std rX, magic_page->srr0
mtsrr1 rX std rX, magic_page->srr1
mtdar rX std rX, magic_page->dar
mtdsisr rX stw rX, magic_page->dsisr

không được

mtmsrd rX, 0 b <phần mtmsr đặc biệt>
mtmsr rX b <phần mtmsr đặc biệt>

mtmsrd rX, 1 b <phần mtmsrd đặc biệt>

[Chỉ Book3S]
mtsrin rX, rY b <phần mtsrin đặc biệt>

[Chỉ sáchE]
wrteei [0|1] b <phần viết đặc biệt>
============================================================

Một số hướng dẫn yêu cầu nhiều logic hơn để xác định điều gì đang xảy ra hơn là tải
hoặc hướng dẫn của cửa hàng có thể cung cấp. Để cho phép vá những thứ đó, chúng tôi giữ một số
RAM xung quanh nơi chúng tôi có thể dịch hướng dẫn trực tiếp tới. Điều gì xảy ra là
sau đây:

1) sao chép mã thi đua vào bộ nhớ
	2) vá mã đó để phù hợp với hướng dẫn mô phỏng
	3) vá mã đó để trở về pc gốc + 4
	4) vá hướng dẫn ban đầu để phân nhánh sang mã mới

Bằng cách đó, chúng ta có thể đưa vào một lượng mã tùy ý để thay thế cho một
hướng dẫn. Điều này cho phép chúng tôi kiểm tra các ngắt đang chờ xử lý khi đặt EE=1
chẳng hạn.

Hypercall ABI trong KVM trên PowerPC
=================================

1) Siêu lệnh gọi KVM (ePAPR)

Đây là cách triển khai siêu cuộc gọi tuân thủ ePAPR (đã đề cập ở trên). Thậm chí
các siêu cuộc gọi chung được triển khai ở đây, giống như hcall nhàn rỗi ePAPR. Đây là
có sẵn trên tất cả các mục tiêu.

2) Siêu cuộc gọi PAPR

Cần có siêu lệnh PAPR để chạy máy chủ PowerPC PAPR khách (-M pseries trong QEMU).
Đây là những siêu lệnh tương tự mà pHyp, bộ ảo hóa POWER, triển khai. Một số
chúng được xử lý trong kernel, một số được xử lý trong không gian người dùng. Đây chỉ là
có sẵn trên book3s_64.

3) Siêu cuộc gọi OSI

Mac-on-Linux là một người dùng khác của KVM trên PowerPC, có hypercall riêng (dài
trước KVM). Điều này được hỗ trợ để duy trì khả năng tương thích. Tất cả các siêu cuộc gọi này nhận được
chuyển tiếp đến không gian người dùng. Điều này chỉ hữu ích trên book3s_32, nhưng có thể được sử dụng với
book3s_64 nữa.