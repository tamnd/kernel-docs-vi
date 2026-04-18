.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/pti.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Cách ly bảng trang (PTI)
==========================

Tổng quan
========

Cách ly bảng trang (pti, trước đây gọi là KAISER [1]_) là một
biện pháp đối phó chống lại các cuộc tấn công vào địa chỉ người dùng/kernel dùng chung
không gian như phương pháp "Meltdown" [2]_.

Để giảm thiểu lớp tấn công này, chúng tôi tạo ra một tập hợp độc lập
bảng trang chỉ được sử dụng khi chạy các ứng dụng không gian người dùng.  Khi nào
hạt nhân được nhập thông qua các cuộc gọi hệ thống, ngắt hoặc ngoại lệ,
bảng trang được chuyển sang bản sao "kernel" đầy đủ.  Khi hệ thống
chuyển về chế độ người dùng, bản sao của người dùng sẽ được sử dụng lại.

Các bảng trang không gian người dùng chỉ chứa một lượng hạt nhân tối thiểu
dữ liệu: chỉ những gì cần thiết để vào/ra kernel chẳng hạn như
chính các hàm vào/ra và bảng mô tả ngắt
(IDT).  Có một vài thứ hoàn toàn không cần thiết được lập bản đồ
chẳng hạn như hàm C đầu tiên khi nhập một ngắt (xem
bình luận trong pti.c).

Cách tiếp cận này giúp đảm bảo rằng các cuộc tấn công kênh bên tận dụng
cấu trúc phân trang không hoạt động khi PTI được bật.  Nó có thể
được bật bằng cách cài đặt CONFIG_MITIGATION_PAGE_TABLE_ISOLATION=y khi biên dịch
thời gian.  Sau khi được bật vào thời gian biên dịch, nó có thể bị tắt khi khởi động với
tham số kernel 'nopti' hoặc 'pti=' (xem kernel-parameters.txt).

Quản lý bảng trang
=====================

Khi PTI được bật, kernel sẽ quản lý hai bộ bảng trang.
Bộ đầu tiên rất giống với bộ đơn có trong
hạt nhân không có PTI.  Điều này bao gồm một bản đồ hoàn chỉnh về không gian người dùng
mà kernel có thể sử dụng cho những việc như copy_to_user().

Mặc dù _complete_, phần người dùng của các bảng trang kernel là
bị tê liệt bằng cách đặt bit NX ở mức cao nhất.  Điều này đảm bảo
rằng bất kỳ chuyển đổi kernel->user CR3 nào bị bỏ lỡ sẽ ngay lập tức gặp sự cố
không gian người dùng khi thực hiện lệnh đầu tiên của nó.

Các bảng trang không gian người dùng chỉ ánh xạ dữ liệu kernel cần thiết để nhập
và thoát khỏi kernel.  Dữ liệu này hoàn toàn được chứa trong 'struct
cấu trúc cpu_entry_area' được đặt trong bản đồ sửa lỗi cung cấp
mỗi bản sao của vùng CPU là một địa chỉ ảo cố định theo thời gian biên dịch.

Đối với ánh xạ không gian người dùng mới, kernel tạo các mục trong
bảng trang như bình thường.  Sự khác biệt duy nhất là khi kernel
thực hiện các mục ở cấp cao nhất (PGD).  Ngoài việc thiết lập các
mục trong kernel chính PGD, một bản sao của mục này được tạo trong
bảng trang không gian người dùng' PGD.

Việc chia sẻ ở cấp độ PGD này vốn cũng chia sẻ tất cả các cấp độ thấp hơn
các lớp của bảng trang.  Điều này để lại một tập hợp duy nhất được chia sẻ
bảng trang không gian người dùng để quản lý.  Một PTE để khóa, một bộ
các bit được truy cập, các bit bẩn, v.v...

Trên không
========

Bảo vệ chống lại các cuộc tấn công kênh bên là quan trọng.  Nhưng,
sự bảo vệ này phải trả giá:

1. Tăng cường sử dụng bộ nhớ

Một. Mỗi quy trình hiện cần một PGD order-1 thay vì order-0.
     (Tiêu thụ thêm 4k cho mỗi quy trình).
  b. Cấu trúc 'cpu_entry_area' phải có kích thước 2 MB và 2 MB
     căn chỉnh để có thể ánh xạ nó bằng cách đặt một PMD
     nhập cảnh.  Điều này tiêu tốn gần 2 MB RAM một lần kernel
     được giải nén nhưng không có khoảng trống trong ảnh hạt nhân.

2. Chi phí thời gian chạy

Một. CR3 thao tác chuyển đổi giữa các bản sao bảng trang
     phải được thực hiện khi ngắt, syscall và nhập ngoại lệ
     và thoát (có thể bỏ qua khi kernel bị gián đoạn,
     mặc dù vậy.) Việc di chuyển đến CR3 có thứ tự một trăm
     chu kỳ, và được yêu cầu ở mỗi lần vào và ra.
  b. Percpu TSS được ánh xạ vào bảng trang người dùng để cho phép đường dẫn SYSCALL64
     làm việc theo PTI. Điều này không có chi phí thời gian chạy trực tiếp nhưng nó có thể
     có thể lập luận rằng nó mở ra một số kịch bản tấn công theo thời gian nhất định.
  c. Các trang toàn cầu bị vô hiệu hóa đối với tất cả các cấu trúc hạt nhân
     được ánh xạ vào cả bảng trang kernel và không gian người dùng.  Cái này
     tính năng của MMU cho phép các quy trình khác nhau chia sẻ TLB
     các mục ánh xạ kernel.  Mất tính năng có ý nghĩa hơn
     TLB bị lỗi sau khi chuyển ngữ cảnh.  Sự mất mát thực tế của
     tuy nhiên hiệu suất rất nhỏ, không bao giờ vượt quá 1%.
  d. Mã định danh bối cảnh quy trình (PCID) là một tính năng của CPU
     cho phép chúng tôi bỏ qua việc xóa toàn bộ TLB khi chuyển trang
     các bảng bằng cách thiết lập một bit đặc biệt trong CR3 khi các bảng trang
     được thay đổi.  Điều này làm cho việc chuyển đổi các bảng trang (theo ngữ cảnh
     switch, hoặc vào/ra kernel) rẻ hơn.  Tuy nhiên, trên các hệ thống có
     Hỗ trợ PCID, mã chuyển ngữ cảnh phải xóa cả người dùng
     và các mục kernel ngoài TLB.  Người dùng xả PCID TLB là
     được trì hoãn cho đến khi thoát khỏi không gian người dùng, giảm thiểu chi phí.
     Xem intel.com/sdm để biết thông tin chi tiết về PCID/INVPCID.
  đ. Các bảng trang không gian người dùng phải được điền cho mỗi trang mới
     quá trình.  Ngay cả khi không có PTI, ánh xạ hạt nhân được chia sẻ
     được tạo bằng cách sao chép các mục nhập cấp cao nhất (PGD) vào mỗi
     quá trình mới.  Nhưng với PTI hiện đã có kernel ZZ0000ZZ
     ánh xạ: một trong các bảng trang kernel ánh xạ mọi thứ
     và một cho cấu trúc vào/ra.  Tại fork(), chúng ta cần
     sao chép cả hai.
  f. Ngoài việc sao chép thời gian fork(), còn phải có
     là bản cập nhật cho không gian người dùng PGD bất cứ khi nào set_pgd() hoàn tất
     trên PGD được sử dụng để ánh xạ không gian người dùng.  Điều này đảm bảo rằng hạt nhân
     và các bản sao không gian người dùng luôn ánh xạ cùng một không gian người dùng
     trí nhớ.
  g. Trên các hệ thống không có hỗ trợ PCID, mỗi lần ghi CR3 đều được ghi
     toàn bộ TLB.  Điều đó có nghĩa là mỗi cuộc gọi tòa nhà, ngắt
     hoặc ngoại lệ xóa TLB.
  h. INVPCID là lệnh xả TLB cho phép xả
     của các mục nhập TLB cho các PCID không hiện hành.  Một số hệ thống hỗ trợ
     PCID, nhưng không hỗ trợ INVPCID.  Trên các hệ thống này, địa chỉ
     chỉ có thể được xóa khỏi TLB đối với PCID hiện tại.  Khi nào
     xóa địa chỉ kernel, chúng ta cần xóa tất cả các PCID, do đó
     việc xóa địa chỉ kernel đơn sẽ yêu cầu TLB-xả CR3
     ghi vào lần sử dụng tiếp theo của mỗi PCID.

Công việc có thể có trong tương lai
====================
1. Chúng ta có thể cẩn thận hơn về việc không thực sự viết thư cho CR3
   trừ khi giá trị của nó thực sự thay đổi.
2. Cho phép bật/tắt PTI trong thời gian chạy ngoài
   chuyển đổi thời gian khởi động.

Kiểm tra
========

Để kiểm tra độ ổn định của PTI, nên thực hiện quy trình kiểm tra sau:
lý tưởng nhất là thực hiện song song tất cả những điều này:

1. Đặt CONFIG_DEBUG_ENTRY=y
2. Chạy một số bản sao của tất cả các công cụ/kiểm tra/selftests/x86/kiểm tra
   (không bao gồm MPX và Protection_keys) trong một vòng lặp trên nhiều CPU cho
   vài phút.  Những thử nghiệm này thường phát hiện ra các trường hợp góc trong
   mã nhập hạt nhân.  Nói chung, kernel cũ có thể gây ra những thử nghiệm này
   có thể tự sụp đổ, nhưng chúng sẽ không bao giờ làm hỏng hạt nhân.
3. Chạy công cụ 'perf' ở chế độ (trên cùng hoặc bản ghi) tạo ra nhiều
   giám sát hiệu suất thường xuyên các ngắt không thể che dấu (xem "NMI"
   trong/Proc/ngắt).  Điều này thực hiện mã vào/ra NMI.
   được biết là gây ra lỗi trong các đường dẫn mã mà bạn không mong đợi.
   bị gián đoạn, bao gồm cả NMI lồng nhau.  Sử dụng "-c" sẽ tăng tốc độ
   NMI và việc sử dụng hai -c với các bộ đếm riêng biệt sẽ khuyến khích các NMI lồng nhau
   và hành vi ít quyết định hơn.
   ::

trong khi đúng; thực hiện bản ghi hoàn hảo -c 10000 -e hướng dẫn, chu kỳ -a ngủ 10; xong

4. Khởi chạy máy ảo KVM.
5. Chạy các tệp nhị phân 32 bit trên các hệ thống hỗ trợ lệnh SYSCALL.
   Đây là đường dẫn mã được thử nghiệm nhẹ và cần được xem xét kỹ lưỡng hơn.

Gỡ lỗi
=========

Lỗi trong PTI gây ra một số dấu hiệu lỗi khác nhau
điều đáng lưu ý ở đây.

* Lỗi của mã selftests/x86.  Thông thường một lỗi ở một trong
   những góc khuất hơn của entry_64.S
 * Gặp sự cố khi khởi động sớm, đặc biệt là khi khởi động CPU.  Lỗi
   trong ánh xạ gây ra những điều này.
 * Sự cố ở lần ngắt đầu tiên.  Nguyên nhân là do lỗi trong entry_64.S,
   giống như vặn một công tắc bảng trang.  Cũng do do
   ánh xạ không chính xác mã nhập trình xử lý IRQ.
 * Sự cố ở NMI đầu tiên.  Mã NMI tách biệt với mã chính
   trình xử lý ngắt và có thể có lỗi không ảnh hưởng đến
   ngắt thông thường.  Cũng do ánh xạ NMI không chính xác
   mã.  NMI làm gián đoạn mã nhập phải rất
   cẩn thận và có thể là nguyên nhân gây ra sự cố xuất hiện khi
   chạy hoàn hảo.
 * Kernel gặp sự cố ở lần thoát đầu tiên vào không gian người dùng.  mục_64.S
   lỗi hoặc không ánh xạ được một số mã thoát.
 * Sự cố ở lần ngắt đầu tiên làm gián đoạn không gian người dùng. Những con đường
   trong entry_64.S quay trở lại không gian người dùng đôi khi tách biệt
   từ những cái quay trở lại kernel.
 * Lỗi kép: tràn kernel stack vì trang
   lỗi nối tiếp lỗi trang.  Nguyên nhân do chạm vào không được ánh xạ pti
   dữ liệu trong mã nhập hoặc quên chuyển sang kernel
   CR3 trước khi gọi vào các hàm C không được ánh xạ pti.
 * Lỗi phân tách không gian người dùng sớm khi khởi động, đôi khi hiển thị
   vì mount(8) không gắn được rootfs.  Những cái này có
   có xu hướng là vấn đề vô hiệu hóa TLB.  Thường vô hiệu
   PCID sai hoặc thiếu thông tin vô hiệu.

.. [1] https://gruss.cc/files/kaiser.pdf
.. [2] https://meltdownattack.com/meltdown.pdf