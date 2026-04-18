.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/bpf_design_QA.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Hỏi đáp về thiết kế BPF
==============

Khả năng mở rộng và ứng dụng của BPF vào mạng, truy tìm, bảo mật
trong nhân linux và một số triển khai không gian người dùng của BPF
máy ảo đã dẫn đến một số hiểu lầm về BPF thực sự là gì.
QA ngắn này là một nỗ lực nhằm giải quyết vấn đề đó và vạch ra một hướng đi
về nơi BPF đang hướng tới lâu dài.

.. contents::
    :local:
    :depth: 3

Câu hỏi và câu trả lời
=====================

Câu hỏi: BPF có phải là tập lệnh chung tương tự như x64 và arm64 không?
-------------------------------------------------------------
Đ: KHÔNG.

Câu hỏi: BPF có phải là máy ảo chung không?
-------------------------------------
Đ: KHÔNG.

BPF là tập lệnh chung gọi quy ước ZZ0000ZZ C.
-----------------------------------------------------------

Câu hỏi: Tại sao quy ước gọi C được chọn?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trả lời: Bởi vì các chương trình BPF được thiết kế để chạy trong nhân linux
được viết bằng C, do đó BPF định nghĩa tập lệnh tương thích
với hai kiến trúc được sử dụng nhiều nhất là x64 và arm64 (và tính đến
xem xét các đặc điểm quan trọng của các kiến trúc khác) và
xác định quy ước gọi tương thích với cách gọi C
quy ước của nhân linux trên các kiến trúc đó.

Câu hỏi: Có thể hỗ trợ nhiều giá trị trả về trong tương lai không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đ: KHÔNG. BPF chỉ cho phép thanh ghi R0 được sử dụng làm giá trị trả về.

Câu hỏi: Trong tương lai có thể hỗ trợ nhiều hơn 5 đối số hàm không?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đ: KHÔNG. Quy ước gọi BPF chỉ cho phép sử dụng các thanh ghi R1-R5
như những lý lẽ. BPF không phải là tập lệnh độc lập.
(không giống như x64 ISA cho phép msft, cdecl và các quy ước khác)

Câu hỏi: Các chương trình BPF có thể truy cập con trỏ lệnh hoặc địa chỉ trả về không?
-----------------------------------------------------------------
Đ: KHÔNG.

Câu hỏi: Các chương trình BPF có thể truy cập con trỏ ngăn xếp không?
------------------------------------------
Đ: KHÔNG.

Chỉ có con trỏ khung (đăng ký R10) mới có thể truy cập được.
Từ quan điểm của trình biên dịch, cần phải có con trỏ ngăn xếp.
Ví dụ: LLVM định nghĩa thanh ghi R11 là con trỏ ngăn xếp trong
Phần phụ trợ BPF, nhưng nó đảm bảo rằng mã được tạo không bao giờ sử dụng nó.

Câu hỏi: Quy ước gọi điện C có làm giảm các trường hợp sử dụng có thể xảy ra không?
-----------------------------------------------------------
Đ: YES.

Thiết kế BPF buộc phải bổ sung thêm chức năng chính vào biểu mẫu
các hàm trợ giúp kernel và các đối tượng kernel như bản đồ BPF với
khả năng tương tác liền mạch giữa chúng. Nó cho phép kernel gọi vào
Các chương trình và chương trình BPF gọi trình trợ giúp kernel với chi phí bằng 0,
vì tất cả chúng đều là mã C gốc. Đó là trường hợp đặc biệt
dành cho các chương trình JITed BPF không thể phân biệt được với
mã hạt nhân gốc C.

Hỏi: Điều đó có nghĩa là các tiện ích mở rộng 'sáng tạo' cho mã BPF không được phép phải không?
------------------------------------------------------------------------
A: Mềm, đúng vậy.

Ít nhất là cho đến thời điểm hiện tại, cho đến khi lõi BPF hỗ trợ
cuộc gọi bpf-to-bpf, cuộc gọi gián tiếp, vòng lặp, biến toàn cục,
bảng nhảy, phần chỉ đọc và tất cả các cấu trúc thông thường khác
mã C đó có thể tạo ra.

Câu hỏi: Vòng lặp có thể được hỗ trợ một cách an toàn không?
----------------------------------------
Đáp: Vẫn chưa rõ ràng.

Các nhà phát triển BPF đang cố gắng tìm cách
hỗ trợ các vòng giới hạn.

Câu hỏi: Giới hạn của người xác minh là gì?
--------------------------------
Đáp: Giới hạn duy nhất được biết đối với không gian người dùng là BPF_MAXINSNS (4096).
Đó là số lượng hướng dẫn tối đa mà bpf không có đặc quyền
chương trình có thể có. Người xác minh có nhiều giới hạn nội bộ khác nhau.
Giống như số lượng hướng dẫn tối đa có thể được khám phá trong quá trình
phân tích chương trình. Hiện tại, giới hạn đó được đặt thành 1 triệu.
Điều đó về cơ bản có nghĩa là chương trình lớn nhất có thể bao gồm
trong số 1 triệu lệnh NOP. Có giới hạn về số lượng tối đa
của các nhánh tiếp theo, giới hạn về số lượng bpf-to-bpf lồng nhau
cuộc gọi, giới hạn số lượng trạng thái xác minh trên mỗi lệnh,
giới hạn số lượng bản đồ được chương trình sử dụng.
Tất cả những giới hạn này có thể đạt được bằng một chương trình đủ phức tạp.
Ngoài ra còn có các giới hạn phi số có thể khiến chương trình
bị từ chối. Trình xác minh được sử dụng để chỉ nhận dạng con trỏ + hằng số
biểu thức. Bây giờ nó có thể nhận ra con trỏ +bounded_register.
bpf_lookup_map_elem(key) có yêu cầu rằng 'key' phải là
một con trỏ tới ngăn xếp. Bây giờ, 'khóa' có thể là một con trỏ tới giá trị bản đồ.
Người xác minh đang dần trở nên 'thông minh hơn'. Các giới hạn là
đang được gỡ bỏ. Cách duy nhất để biết rằng chương trình sẽ
được người xác minh chấp nhận là cố gắng tải nó.
Quá trình phát triển bpf đảm bảo rằng hạt nhân trong tương lai
các phiên bản sẽ chấp nhận tất cả các chương trình bpf đã được chấp nhận bởi
các phiên bản trước đó.


Câu hỏi cấp độ hướng dẫn
---------------------------

Câu hỏi: Hướng dẫn LD_ABS và LD_IND so với mã C
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hỏi: Tại sao lệnh LD_ABS và LD_IND lại xuất hiện trong BPF trong khi
Mã C không thể diễn đạt chúng và phải sử dụng nội tại dựng sẵn?

Trả lời: Đây là hiện tượng tương thích với BPF cổ điển. hiện đại
mã mạng trong BPF hoạt động tốt hơn khi không có chúng.
Xem 'truy cập gói trực tiếp'.

Câu hỏi: Lệnh BPF ánh xạ không phải một-một với CPU gốc
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Câu hỏi: Có vẻ như không phải tất cả các hướng dẫn BPF đều là một đối một với CPU gốc.
Ví dụ: tại sao BPF_JNE và các bước so sánh và nhảy khác không giống CPU?

Trả lời: Điều này là cần thiết để tránh đưa các cờ vào ISA
không thể tạo ra sự chung chung và hiệu quả trên các kiến trúc CPU.

Câu hỏi: Tại sao lệnh BPF_DIV không ánh xạ tới div x64?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đáp: Bởi vì nếu chúng ta chọn mối quan hệ một-một với x64 thì nó sẽ tạo ra
việc hỗ trợ trên arm64 và các vòm khác sẽ phức tạp hơn. Ngoài ra nó
cần kiểm tra thời gian chạy div-by-zero.

Hỏi: Tại sao BPF lại có phần mở đầu và phần kết ngầm?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Đáp: Bởi vì các kiến trúc như sparc có cửa sổ đăng ký và nói chung
có đủ sự khác biệt tinh tế giữa các kiến trúc, thật ngây thơ
lưu trữ địa chỉ trả lại vào ngăn xếp sẽ không hoạt động. Một lý do khác là BPF có
để được an toàn khỏi việc chia cho 0 (và đường dẫn ngoại lệ kế thừa
của LD_ABS insn). Những hướng dẫn đó cần phải gọi phần kết và
ngầm quay trở lại.

Hỏi: Tại sao hướng dẫn BPF_JLT và BPF_JLE không được giới thiệu ngay từ đầu?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Trả lời: Bởi vì BPF cổ điển không có chúng và các tác giả BPF cảm thấy trình biên dịch đó
cách giải quyết sẽ được chấp nhận. Hóa ra các chương trình bị mất hiệu suất
do thiếu các hướng dẫn so sánh này và chúng đã được thêm vào.
Hai hướng dẫn này là một ví dụ hoàn hảo về loại BPF mới
hướng dẫn được chấp nhận và có thể được thêm vào trong tương lai.
Hai cái này đã có hướng dẫn tương đương trong CPU gốc.
Hướng dẫn mới không có ánh xạ một-một với hướng dẫn CTNH
sẽ không được chấp nhận.

Câu hỏi: Yêu cầu đăng ký phụ 32-bit BPF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hỏi: Các thanh ghi con 32-bit BPF có yêu cầu về 0 32-bit trên của BPF
các thanh ghi làm cho máy ảo BPF hoạt động kém hiệu quả đối với 32-bit
Kiến trúc CPU và bộ tăng tốc CTNH 32 bit. Có thể đăng ký 32-bit thực sự
được thêm vào BPF trong tương lai?

Đ: KHÔNG.

Nhưng một số tối ưu hóa về 0 trong 32 bit trên cho các thanh ghi BPF là
có sẵn và có thể được tận dụng để cải thiện hiệu suất của JITed BPF
chương trình cho kiến trúc 32-bit.

Bắt đầu với phiên bản 7, LLVM có thể tạo hướng dẫn vận hành
trên các thanh ghi phụ 32 bit, miễn là tùy chọn -mattr=+alu32 được chuyển cho
biên soạn một chương trình. Hơn nữa, người xác minh bây giờ có thể đánh dấu
hướng dẫn xóa các bit trên của thanh ghi đích
là bắt buộc và chèn lệnh không mở rộng (zext) rõ ràng
(một biến thể Mov32). Điều này có nghĩa là đối với các kiến trúc không có phần cứng zext
hỗ trợ, back-end JIT không cần xóa các bit trên cho
các thanh ghi con được viết bằng lệnh alu32 hoặc tải hẹp. Thay vào đó,
back-end chỉ cần hỗ trợ tạo mã cho biến thể Mov32 đó,
và ghi đè bpf_jit_needs_zext() để làm cho nó trả về "true" (để
cho phép chèn zext trong trình xác minh).

Lưu ý rằng back-end JIT có thể có một phần phần cứng
hỗ trợ cho zext. Trong trường hợp đó, nếu tính năng chèn zext của trình xác minh được bật,
nó có thể dẫn đến việc chèn các lệnh zext không cần thiết. Như vậy
có thể xóa hướng dẫn bằng cách tạo một lỗ nhìn trộm đơn giản bên trong JIT
back-end: nếu một lệnh có hỗ trợ phần cứng cho zext và nếu lệnh tiếp theo
lệnh là một zext rõ ràng, sau đó có thể bỏ qua lệnh sau khi thực hiện
việc tạo mã.

Hỏi: BPF có ABI ổn định không?
------------------------------
Đ: YES. Hướng dẫn BPF, đối số cho chương trình BPF, bộ trợ giúp
các hàm và đối số của chúng, mã trả về được công nhận đều là một phần
của ABI. Tuy nhiên có một ngoại lệ cụ thể đối với các chương trình theo dõi
đang sử dụng các trình trợ giúp như bpf_probe_read() để hướng dẫn nội bộ kernel
cấu trúc dữ liệu và biên dịch với các tiêu đề bên trong kernel. Cả hai điều này
phần bên trong kernel có thể thay đổi và có thể bị hỏng với các kernel mới hơn
nên chương trình cần được điều chỉnh cho phù hợp.

Chức năng BPF mới thường được thêm vào thông qua việc sử dụng kfuncs thay vì
những người giúp đỡ mới. Kfuncs không được coi là một phần của API ổn định và có riêng
kỳ vọng về vòng đời như được mô tả trong ZZ0000ZZ.

Câu hỏi: Điểm theo dõi có phải là một phần của ABI ổn định không?
------------------------------------------
Đ: KHÔNG. Các điểm theo dõi được gắn với các chi tiết triển khai nội bộ do đó chúng
có thể thay đổi và có thể bị hỏng với các hạt nhân mới hơn. Các chương trình BPF cần thay đổi
tương ứng khi điều này xảy ra.

Câu hỏi: Có phải những nơi mà kprobe có thể gắn một phần của ABI ổn định không?
--------------------------------------------------------------
Đ: KHÔNG. Những nơi mà kprobe có thể gắn vào là triển khai nội bộ
chi tiết, có nghĩa là chúng có thể thay đổi và có thể bị hỏng do
hạt nhân mới hơn. Các chương trình BPF cần thay đổi tương ứng khi điều này xảy ra.

Câu hỏi: Chương trình BPF sử dụng bao nhiêu dung lượng ngăn xếp?
-------------------------------------------
Trả lời: Hiện tại tất cả các loại chương trình đều bị giới hạn ở mức 512 byte ngăn xếp
không gian, nhưng trình xác minh sẽ tính toán lượng ngăn xếp thực tế được sử dụng
và cả trình thông dịch và hầu hết mã JITed đều tiêu thụ số lượng cần thiết.

Câu hỏi: BPF có thể được chuyển sang HW không?
------------------------------
Đ: YES. Giảm tải BPF CTNH được hỗ trợ bởi trình điều khiển NFP.

Hỏi: Trình thông dịch BPF cổ điển có còn tồn tại không?
--------------------------------------------
Đ: KHÔNG. Các chương trình BPF cổ điển được chuyển đổi thành các lệnh BPF mở rộng.

Câu hỏi: BPF có thể gọi các hàm kernel tùy ý không?
-------------------------------------------
Đ: KHÔNG. Các chương trình BPF chỉ có thể gọi các chức năng cụ thể được hiển thị dưới dạng trình trợ giúp BPF hoặc
kfuncs. Tập hợp các chức năng có sẵn được xác định cho mọi loại chương trình.

Câu hỏi: BPF có thể ghi đè bộ nhớ kernel tùy ý không?
---------------------------------------------
Đ: KHÔNG.

Truy tìm các chương trình bpf có thể ZZ0000ZZ bộ nhớ tùy ý với bpf_probe_read()
và những người trợ giúp bpf_probe_read_str(). Các chương trình mạng không thể đọc được
bộ nhớ tùy ý, vì họ không có quyền truy cập vào những người trợ giúp này.
Các chương trình không bao giờ có thể đọc hoặc ghi bộ nhớ tùy ý một cách trực tiếp.

Hỏi: BPF có thể ghi đè lên bộ nhớ người dùng tùy ý không?
-------------------------------------------
A: Đại loại thế.

Truy tìm các chương trình BPF có thể ghi đè lên bộ nhớ người dùng
của tác vụ hiện tại bằng bpf_probe_write_user(). Mỗi lần như vậy
chương trình được tải kernel sẽ in thông báo cảnh báo, vì vậy
người trợ giúp này chỉ hữu ích cho các thí nghiệm và nguyên mẫu.
Truy tìm các chương trình BPF chỉ có quyền root.

Câu hỏi: Chức năng mới thông qua mô-đun hạt nhân?
----------------------------------------
Hỏi: Chức năng của BPF có thể như chương trình mới hoặc loại bản đồ, mới
người trợ giúp, v.v. có thể được thêm vào từ mã mô-đun hạt nhân không?

Đ: Có, thông qua kfuncs và kptrs

Không thể hỗ trợ chức năng cốt lõi của BPF như loại chương trình, bản đồ và trình trợ giúp.
được thêm vào bởi các mô-đun. Tuy nhiên, các mô-đun có thể hiển thị chức năng cho các chương trình BPF
bằng cách xuất kfuncs (có thể trả về con trỏ tới dữ liệu bên trong mô-đun
cấu trúc như kptrs).

Câu hỏi: Gọi trực tiếp hàm kernel là ABI?
----------------------------------------------
Hỏi: Một số hàm kernel (ví dụ: tcp_slow_start) có thể được gọi
bởi các chương trình BPF.  Các hàm kernel này có trở thành ABI không?

Đ: KHÔNG.

Các nguyên mẫu hàm kernel sẽ thay đổi và các chương trình bpf sẽ
bị người xác minh từ chối.  Ngoài ra, ví dụ, một số bpf có thể gọi được
các hàm kernel đã được sử dụng bởi tcp kernel khác
triển khai cc (kiểm soát tắc nghẽn).  Nếu bất kỳ hạt nhân nào trong số này
các hàm đã thay đổi, cả hạt nhân trong cây và hạt nhân ngoài cây tcp cc
việc triển khai phải được thay đổi.  Điều tương tự cũng xảy ra với bpf
chương trình và chúng phải được điều chỉnh cho phù hợp. Xem
ZZ0000ZZ để biết chi tiết.

Q: ABI có thể gắn vào các hàm kernel tùy ý?
-----------------------------------------------------
Hỏi: Các chương trình BPF có thể được gắn vào nhiều hàm kernel.  Làm những điều này
các hàm kernel có trở thành một phần của ABI không?

Đ: KHÔNG.

Các nguyên mẫu hàm kernel sẽ thay đổi và các chương trình BPF gắn vào
họ sẽ cần phải thay đổi.  BPF biên dịch một lần chạy mọi nơi (CO-RE)
nên được sử dụng để giúp điều chỉnh các chương trình BPF của bạn dễ dàng hơn
phiên bản khác nhau của hạt nhân.

Hỏi: Việc đánh dấu một chức năng bằng BTF_ID có làm cho chức năng đó trở thành ABI không?
-------------------------------------------------------------
Đ: KHÔNG.

Macro BTF_ID không khiến hàm trở thành một phần của ABI
nhiều hơn macro EXPORT_SYMBOL_GPL.

Câu hỏi: Câu chuyện về khả năng tương thích của các loại BPF đặc biệt trong giá trị bản đồ là gì?
-----------------------------------------------------------------------
Hỏi: Người dùng được phép nhúng các trường bpf_spin_lock, bpf_timer vào bản đồ BPF của họ
các giá trị (khi sử dụng hỗ trợ BTF cho bản đồ BPF). Điều này cho phép sử dụng trợ giúp cho
các đối tượng như vậy trên các trường này bên trong các giá trị bản đồ. Người dùng cũng được phép nhúng
con trỏ tới một số loại kernel (với thẻ __kptr_untrusted và __kptr BTF). Liệu
kernel duy trì khả năng tương thích ngược cho các tính năng này?

Đáp: Còn tùy. Đối với bpf_spin_lock, bpf_timer: YES, cho kptr và mọi thứ khác:
KHÔNG, nhưng hãy xem bên dưới.

Đối với các kiểu cấu trúc đã được thêm vào, như bpf_spin_lock và bpf_timer,
hạt nhân sẽ duy trì khả năng tương thích ngược vì chúng là một phần của UAPI.

Đối với kptr, chúng cũng là một phần của UAPI, nhưng chỉ đối với kptr
cơ chế. Các loại mà bạn có thể sử dụng với thẻ __kptr_untrusted và __kptr
con trỏ trong cấu trúc của bạn là một phần NOT của hợp đồng UAPI. Các loại được hỗ trợ có thể
và sẽ thay đổi trên các bản phát hành kernel. Tuy nhiên, các hoạt động như truy cập kptr
các trường và trình trợ giúp bpf_kptr_xchg() sẽ tiếp tục được hỗ trợ trên kernel
bản phát hành cho các loại được hỗ trợ.

Đối với bất kỳ loại cấu trúc được hỗ trợ nào khác, trừ khi được nêu rõ ràng trong tài liệu này
và được thêm vào tiêu đề bpf.h UAPI, những loại như vậy có thể và sẽ tùy ý thay đổi
kích thước, loại và căn chỉnh hoặc bất kỳ chi tiết API hoặc ABI nào khác mà người dùng khác có thể nhìn thấy trên
phát hành hạt nhân. Người dùng phải điều chỉnh chương trình BPF của họ với những thay đổi mới và
cập nhật chúng để đảm bảo chương trình của chúng tiếp tục hoạt động chính xác.

NOTE: Hệ thống con BPF đặc biệt dành tiền tố 'bpf\_' cho tên loại, trong
để giới thiệu nhiều lĩnh vực đặc biệt hơn trong tương lai. Do đó, các chương trình người dùng phải
tránh xác định loại bằng tiền tố 'bpf\_' để không bị hỏng trong các bản phát hành sau này.
Nói cách khác, không có khả năng tương thích ngược nào được đảm bảo nếu sử dụng một loại
trong BTF với tiền tố 'bpf\_'.

Câu hỏi: Câu chuyện về khả năng tương thích của các loại BPF đặc biệt trong các đối tượng được phân bổ là gì?
------------------------------------------------------------------------------
Q: Tương tự như trên, nhưng đối với các đối tượng được cấp phát (tức là các đối tượng được cấp phát bằng cách sử dụng
bpf_obj_new cho các loại do người dùng xác định). Hạt nhân sẽ bảo tồn ngược
khả năng tương thích cho các tính năng này?

Đ: KHÔNG.

Không giống như các loại giá trị bản đồ, API hoạt động với các đối tượng được phân bổ và mọi hỗ trợ
đối với các trường đặc biệt bên trong chúng được hiển thị thông qua kfuncs và do đó có cùng
kỳ vọng về vòng đời cũng như chính kfuncs. Xem
ZZ0000ZZ để biết chi tiết.
