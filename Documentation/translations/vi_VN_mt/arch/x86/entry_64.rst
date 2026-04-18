.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/entry_64.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Mục nhập hạt nhân
==============

Tệp này ghi lại một số mục kernel trong
Arch/x86/entry/entry_64.S.  Phần lớn lời giải thích này được chuyển thể từ
một email từ Ingo Molnar:

ZZ0000ZZ

Kiến trúc x86 có khá nhiều cách khác nhau để bắt đầu
mã hạt nhân.  Hầu hết các điểm vào này được đăng ký tại
Arch/x86/kernel/traps.c và được triển khai trong Arch/x86/entry/entry_64.S
cho 64-bit, Arch/x86/entry/entry_32.S cho 32-bit và cuối cùng
Arch/x86/entry/entry_64_compat.S triển khai khả năng tương thích 32-bit
điểm truy cập syscall và do đó cung cấp cho các quy trình 32-bit
khả năng thực thi các cuộc gọi tổng hợp khi chạy trên hạt nhân 64-bit.

Phép gán vectơ IDT được liệt kê trong Arch/x86/include/asm/irq_vectors.h.

Một số mục này là:

- system_call: lệnh syscall từ mã 64-bit.

- entry_INT80_compat: int 0x80 từ mã 32 bit hoặc 64 bit; tòa nhà tương thích
   dù thế nào đi nữa.

- entry_INT80_compat, ia32_sysenter: syscall và sysenter từ 32-bit
   mã

- ngắt: Một mảng các mục.  Mọi vectơ IDT không
   chỉ rõ ràng ở một nơi khác được đặt thành tương ứng
   giá trị trong các ngắt.  Những điểm này chỉ ra một loạt các
   các hàm được tạo ra một cách kỳ diệu sẽ tiến tới common_interrupt()
   với số ngắt làm tham số.

- Ngắt APIC: Các ngắt có mục đích đặc biệt khác nhau cho mọi thứ
   giống như vụ bắn hạ TLB.

- Các ngoại lệ được xác định về mặt kiến ​​trúc như Divide_error.

Có một vài điều phức tạp ở đây.  Các mục x86-64 khác nhau
có các quy ước gọi khác nhau.  Syscall và sysenter
hướng dẫn có quy ước gọi đặc biệt của riêng họ.  Một số
các mục IDT sẽ đẩy mã lỗi vào ngăn xếp; những người khác thì không.
Các mục IDT sử dụng cơ chế ngăn xếp thay thế IST cần có cơ chế riêng
phép thuật để có được khung ngăn xếp đúng.  (Bạn có thể tìm thấy một số
tài liệu trong AMD APM, Tập 2, Chương 8 và Intel SDM,
Tập 3, Chương 6.)

Xử lý hướng dẫn swapgs đặc biệt khó khăn.  Hoán đổi
thay đổi xem gs là gs kernel hay gs người dùng.  Trao đổi
hướng dẫn khá mong manh: nó phải lồng ghép một cách hoàn hảo và chỉ trong
độ sâu đơn, nó chỉ nên được sử dụng nếu nhập từ chế độ người dùng sang
chế độ kernel và sau đó khi quay lại không gian người dùng và chính xác
vậy. Nếu chúng ta làm hỏng nó dù chỉ một chút, chúng ta sẽ sụp đổ.

Vì vậy, khi chúng tôi có mục nhập phụ, đã ở chế độ kernel, chúng tôi *phải
không* sử dụng SWAPGS một cách mù quáng - chúng ta cũng không được quên sử dụng SWAPGS khi cần thiết
chưa được chuyển đổi/hoán đổi.

Bây giờ có một vấn đề phức tạp thứ hai: có một cách rẻ tiền để kiểm tra
CPU đang ở chế độ nào và đắt tiền.

Cách rẻ tiền là chọn thông tin này ra khỏi khung nhập trên kernel
ngăn xếp, từ CS của vùng ptregs của ngăn xếp hạt nhân::

xorl %ebx,%ebx
	kiểm tra $3,CS+8(%rsp)
	je error_kernelspace
	SWAPGS

Cách đắt tiền (hoang tưởng) là đọc lại giá trị MSR_GS_BASE
(đó là những gì SWAPGS sửa đổi)::

di chuyển $1,%ebx
	di chuyển $MSR_GS_BASE,%ecx
	rdmsr
	kiểm tra %edx,%edx
	js 1f /* âm -> trong kernel */
	SWAPGS
	xorl %ebx,%ebx
  1: trở lại

Nếu chúng ta đang ở ranh giới gián đoạn hoặc ranh giới bẫy người dùng/cổng giống nhau thì chúng ta có thể
sử dụng kiểm tra nhanh hơn: ngăn xếp sẽ là một chỉ báo đáng tin cậy về
liệu SWAPGS đã được thực hiện chưa: nếu chúng tôi thấy rằng chúng tôi là thứ yếu
mục này làm gián đoạn quá trình thực thi chế độ kernel thì chúng ta biết rằng GS
cơ sở đã được chuyển đổi. Nếu nó nói rằng chúng tôi đã làm gián đoạn
thực thi không gian người dùng thì chúng ta phải thực hiện SWAPGS.

Nhưng nếu chúng ta đang ở trong bối cảnh đầu vào siêu nguyên tử NMI/MCE/DEBUG/bất kỳ thứ gì,
có thể đã được kích hoạt ngay sau khi một mục bình thường ghi CS vào
ngăn xếp nhưng trước khi chúng tôi thực thi SWAPGS thì cách an toàn duy nhất để kiểm tra
đối với GS là phương pháp chậm hơn: RDMSR.

Do đó, các mục siêu nguyên tử (ngoại trừ NMI, được xử lý riêng)
phải sử dụng idtentry với paranoid=1 để xử lý gsbase một cách chính xác.  Cái này
gây ra ba thay đổi hành vi chính:

- Mục nhập ngắt sẽ sử dụng kiểm tra gsbase chậm hơn.
 - Việc ngắt mục nhập từ chế độ người dùng sẽ tắt ngăn xếp IST.
 - Ngắt thoát sang chế độ kernel sẽ không cố gắng lên lịch lại.

Chúng tôi cố gắng chỉ sử dụng các mục nhập IST và mã mục nhập hoang tưởng cho vectơ
điều đó thực sự cần tấm séc đắt tiền hơn cho cơ sở GS - và chúng tôi
tạo tất cả các điểm vào 'bình thường' với paranoid=0 thông thường (nhanh hơn)
biến thể.