.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/nwfpe/netwinder-fpe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Trạng thái hiện tại
=============

Phần sau đây mô tả trạng thái hiện tại của dấu phẩy động của NetWinder
giả lập.

Trong danh pháp sau đây được sử dụng để mô tả dấu phẩy động
hướng dẫn.  Nó tuân theo các quy ước trong hướng dẫn sử dụng ARM.

::

<SZZ0000ZZE> = <single|double|extends>, không có mặc định
  {PZZ0002ZZZ} = {làm tròn đến +vô cực,làm tròn đến -vô cực,làm tròn đến 0},
            mặc định = làm tròn đến gần nhất

Lưu ý: các mục kèm theo {} là tùy chọn.

Hướng dẫn truyền dữ liệu bộ đồng xử lý dấu phẩy động (CPDT)
------------------------------------------------------------

LDF/STF - tải và lưu trữ nổi

<LDFZZ0000ZZD|E> Fd, Rn
<LDFZZ0001ZZD|E> Fd, [Rn, #<biểu thức>]{!}
<LDFZZ0002ZZD|E> Fd, [Rn], #<biểu thức>

Những hướng dẫn này được thực hiện đầy đủ.

LFM/SFM - tải và lưu trữ nhiều tệp nổi

Cú pháp mẫu 1:
<LFMZZ0000ZZD|E> Fd, <đếm>, [Rn]
<LFMZZ0001ZZD|E> Fd, <count>, [Rn, #<biểu thức>]{!}
<LFMZZ0002ZZD|E> Fd, <count>, [Rn], #<biểu thức>

Cú pháp mẫu 2:
<LFM|SFM>{cond<FD,EA> Fd, <count>, [Rn]{!}

Những hướng dẫn này được thực hiện đầy đủ.  Họ lưu trữ/tải ba từ
đối với mỗi dấu phẩy động, hãy đăng ký vào vị trí bộ nhớ được cung cấp trong
hướng dẫn.  Định dạng trong bộ nhớ có thể không tương thích với
các triển khai khác, đặc biệt là phần cứng thực tế.  Cụ thể
đề cập đến điều này được thực hiện trong hướng dẫn sử dụng ARM.

Hướng dẫn chuyển đăng ký bộ đồng xử lý dấu phẩy động (CPRT)
----------------------------------------------------------------

Chuyển đổi, đọc/ghi trạng thái/hướng dẫn thanh ghi điều khiển

FLT{cond<S,D,E>{P,M,Z} Fn, Rd Chuyển đổi số nguyên thành dấu phẩy động
FIX{cond}{P,M,Z} Rd, Fn Chuyển đổi dấu phẩy động thành số nguyên
WFS{cond} Rd Ghi thanh ghi trạng thái dấu phẩy động
RFS{cond} Rd Đọc thanh ghi trạng thái dấu phẩy động
WFC{cond} Rd Ghi thanh ghi điều khiển dấu phẩy động
RFC{cond} Rd Đọc thanh ghi điều khiển dấu phẩy động

FLT/FIX được triển khai đầy đủ.

RFS/WFS được triển khai đầy đủ.

RFC/WFC được triển khai đầy đủ.  RFC/WFC là hướng dẫn chỉ dành cho người giám sát và
hiện đang kiểm tra chế độ CPU và thực hiện bẫy lệnh không hợp lệ nếu không được gọi
từ chế độ giám sát.

So sánh hướng dẫn

CMF{cond} Fn, Fm So sánh nổi
CMFE{cond} Fn, Fm So sánh nổi với ngoại lệ
CNF{cond} Fn, Fm So sánh phủ định nổi
CNFE{cond} Fn, Fm So sánh phủ định nổi với ngoại lệ

Những điều này được thực hiện đầy đủ.

Hướng dẫn dữ liệu bộ đồng xử lý dấu phẩy động (CPDT)
---------------------------------------------------

Hoạt động kép:

ADF{cond<SZZ0000ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - thêm
SUF{cond<SZZ0001ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - trừ
RSF{cond<SZZ0002ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - trừ ngược
MUF{cond<SZZ0003ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nhân lên
DVF{cond<SZZ0004ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - chia
RDV{cond<SZZ0005ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - chia ngược

Những điều này được thực hiện đầy đủ.

FML{cond<SZZ0000ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nhân nhanh
FDV{cond<SZZ0001ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - chia nhanh
FRD{cond<SZZ0002ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - chia ngược nhanh

Những điều này cũng được thực hiện đầy đủ.  Họ sử dụng thuật toán tương tự như
phiên bản không nhanh.  Do đó, trong việc thực hiện này hiệu suất của họ là
tương đương với các lệnh MUF/DVF/RDV.  Điều này có thể chấp nhận được theo
vào hướng dẫn sử dụng ARM.  Các ghi chú thủ công này chỉ được xác định cho một
toán hạng, trên phần cứng FPA11 thực tế, chúng không hoạt động với double hoặc
toán hạng chính xác mở rộng.  Trình mô phỏng hiện không kiểm tra
các điều kiện quyền được yêu cầu và thực hiện thao tác được yêu cầu.

RMF{cond<SZZ0000ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - phần còn lại của IEEE

Điều này được thực hiện đầy đủ.

Hoạt động đơn âm:

MVF{cond<SZZ0000ZZE>{P,M,Z} Fd, <Fm,#value> - di chuyển
MNF{cond<SZZ0001ZZE>{P,M,Z} Fd, <Fm,#value> - nước đi bị phủ định

Những điều này được thực hiện đầy đủ.

ABS{cond<SZZ0000ZZE>{P,M,Z} Fd, <Fm,#value> - giá trị tuyệt đối
SQT{cond<SZZ0001ZZE>{P,M,Z} Fd, <Fm,#value> - căn bậc hai
RND{cond<SZZ0002ZZE>{P,M,Z} Fd, <Fm,#value> - tròn

Những điều này được thực hiện đầy đủ.

URD{cond<SZZ0000ZZE>{P,M,Z} Fd, <Fm,#value> - vòng không chuẩn hóa
NRM{cond<SZZ0001ZZE>{P,M,Z} Fd, <Fm,#value> - chuẩn hóa

Những điều này được thực hiện.  URD được triển khai bằng cùng mã với RND
hướng dẫn.  Vì URD không thể trả về số không chuẩn hóa nên NRM trở thành
một chiếc NOP.

Cuộc gọi thư viện:

POW{cond<SZZ0000ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nguồn
RPW{cond<SZZ0001ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nguồn đảo ngược
POL{cond<SZZ0002ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - góc cực (arctan2)

LOG{cond<SZZ0000ZZE>{P,M,Z} Fd, <Fm,#value> - logarit cơ số 10
LGN{cond<SZZ0001ZZE>{P,M,Z} Fd, <Fm,#value> - logarit cơ số e
EXP{cond<SZZ0002ZZE>{P,M,Z} Fd, <Fm,#value> - số mũ
SIN{cond<SZZ0003ZZE>{P,M,Z} Fd, <Fm,#value> - sin
COS{cond<SZZ0004ZZE>{P,M,Z} Fd, <Fm,#value> - cosine
TAN{cond<SZZ0005ZZE>{P,M,Z} Fd, <Fm,#value> - tiếp tuyến
ASN{cond<SZZ0006ZZE>{P,M,Z} Fd, <Fm,#value> - arcsine
ACS{cond<SZZ0007ZZE>{P,M,Z} Fd, <Fm,#value> - arccosine
ATN{cond<SZZ0008ZZE>{P,M,Z} Fd, <Fm,#value> - arctangent

Những điều này không được thực hiện.  Chúng hiện không được trình biên dịch phát hành,
và được xử lý bởi các thủ tục trong libc.  Những điều này không được FPA11 triển khai
phần cứng, nhưng được xử lý bằng mã hỗ trợ dấu phẩy động.  Họ nên
sẽ được triển khai trong các phiên bản sau.

Báo hiệu:

Tín hiệu được thực hiện.  Tuy nhiên, hạt nhân ELF hiện tại do Rebel.com sản xuất
có một lỗi trong đó khiến mô-đun không thể tạo ra SIGFPE.  Cái này
là do lỗi đặt bí danh fp_current cho biến kernel
current_set[0] một cách chính xác.

Hạt nhân được cung cấp cùng với bản phân phối này (vmlinux-nwfpe-0.93) chứa
một bản sửa lỗi cho vấn đề này và cũng kết hợp phiên bản hiện tại của
giả lập trực tiếp.  Có thể chạy mà không cần mô-đun dấu phẩy động
được nạp với kernel này.  Nó được cung cấp như một minh chứng cho
công nghệ và dành cho những người muốn thực hiện công việc về dấu phẩy động phụ thuộc vào
trên các tín hiệu.  Việc sử dụng mô-đun là không thực sự cần thiết.

Một mô-đun (mô-đun do Russell King cung cấp hoặc mô-đun trong tài liệu này
distribution) có thể được tải để thay thế chức năng của trình mô phỏng
được xây dựng trong hạt nhân.
