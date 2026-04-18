.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/nwfpe/todo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

TODO LIST
=========

::

POW{cond<SZZ0000ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nguồn
  RPW{cond<SZZ0001ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - nguồn đảo ngược
  POL{cond}<SZZ0002ZZE>{P,M,Z} Fd, Fn, <Fm,#value> - polar angle (arctan2)

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

Có một số cách để tiếp cận việc thực hiện những điều này.  một
phương pháp sẽ là sử dụng các phương pháp bảng chính xác cho các hoạt động này.  tôi có
một vài bài báo của S. Gal từ phòng thí nghiệm nghiên cứu của IBM ở Haifa, Israel rằng
dường như hứa hẹn độ chính xác cực cao (theo thứ tự 99,8%) và tốc độ hợp lý.
Các phương pháp này được sử dụng trong GLIBC cho một số hàm siêu việt.

Một cách tiếp cận khác mà tôi biết ít là CORDIC.  Điều này tượng trưng cho
Máy tính kỹ thuật số xoay tọa độ và là một phương pháp tính toán
các hàm siêu việt chủ yếu sử dụng các phép dịch và phép cộng và một số ít
phép nhân và phép chia.  ARM vượt trội trong việc thay đổi và bổ sung thêm,
vì vậy phương pháp như vậy có thể đầy hứa hẹn nhưng cần nhiều nghiên cứu hơn để
xác định xem nó có khả thi hay không.

Phương pháp làm tròn
----------------

Tiêu chuẩn IEEE xác định 4 chế độ làm tròn.  Vòng đến gần nhất là
mặc định, nhưng cũng được phép làm tròn đến + hoặc - vô cùng hoặc làm tròn về 0.
Nhiều kiến trúc cho phép chỉ định chế độ làm tròn bằng cách sửa đổi các bit
trong một thanh ghi điều khiển.  Không như vậy với kiến ​​trúc ARM FPA11.  Để thay đổi
chế độ làm tròn người ta phải chỉ định nó với mỗi lệnh.

Điều này đã làm cho việc chuyển một số điểm chuẩn trở nên khó khăn.  Có thể
giới thiệu khả năng như vậy vào trình mô phỏng.  FPCR chứa
bit mô tả chế độ làm tròn.  Trình mô phỏng có thể được thay đổi thành
kiểm tra một cờ, nếu được đặt sẽ buộc nó bỏ qua chế độ làm tròn trong
lệnh và sử dụng chế độ được chỉ định trong các bit trong FPCR.

Điều này sẽ yêu cầu một phương pháp nhận/đặt cờ và các bit
trong FPCR.  Điều này yêu cầu lệnh gọi kernel trong ArmLinux, vì WFC/RFC là
chỉ dẫn của người giám sát.  Nếu ai có ý kiến hay nhận xét gì tôi
muốn nghe chúng.

NOTE:
 được lấy ra từ một số tài liệu về điểm nổi ARM, cụ thể là
 dành cho Acorn FPE, nhưng không giới hạn ở nó:

Thanh ghi điều khiển dấu phẩy động (FPCR) chỉ có thể có ở một số
 triển khai: nó ở đó để kiểm soát phần cứng trong quá trình triển khai-
 cách cụ thể, ví dụ như để vô hiệu hóa hệ thống dấu phẩy động.  Người dùng
 chế độ của ARM không được phép sử dụng thanh ghi này (vì quyền là
 dành riêng để thay đổi nó giữa các lần triển khai) và WFC và RFC
 hướng dẫn sẽ mắc kẹt nếu thử ở chế độ người dùng.

Do đó, câu trả lời là có, bạn có thể làm điều này, nhưng khi đó bạn sẽ đạt thành tích cao.
 nguy cơ bị cô lập nếu và khi mô phỏng FP phần cứng xuất hiện

-- Russell.
