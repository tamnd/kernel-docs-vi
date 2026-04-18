.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/orc-unwinder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============
Máy tháo cuộn ORC
============

Tổng quan
========

Tùy chọn kernel CONFIG_UNWINDER_ORC cho phép trình tháo gỡ ORC, đây là
có khái niệm tương tự như bộ tháo gỡ DWARF.  Sự khác biệt là ở chỗ
định dạng của dữ liệu ORC đơn giản hơn nhiều so với DWARF, do đó cho phép
công cụ tháo gỡ ORC trở nên đơn giản và nhanh hơn nhiều.

Dữ liệu ORC bao gồm các bảng thư giãn được tạo bởi objtool.
Chúng chứa dữ liệu ngoài băng tần được ORC trong hạt nhân sử dụng
unser.  Objtool tạo dữ liệu ORC bằng cách thực hiện thời gian biên dịch đầu tiên
xác thực siêu dữ liệu ngăn xếp (CONFIG_STACK_VALIDATION).  Sau khi phân tích
tất cả các đường dẫn mã của tệp .o, nó xác định thông tin về
trạng thái ngăn xếp tại mỗi địa chỉ lệnh trong tệp và xuất ra
thông tin cho các phần .orc_unwind và .orc_unwind_ip.

Các phần ORC của mỗi đối tượng được kết hợp tại thời điểm liên kết và được sắp xếp và
xử lý sau khi khởi động.  Bộ giải mã sử dụng dữ liệu thu được để
tương quan các địa chỉ lệnh với trạng thái ngăn xếp của chúng trong thời gian chạy.


ORC so với con trỏ khung
=====================

Khi bật con trỏ khung, GCC sẽ thêm mã thiết bị vào mọi
chức năng trong hạt nhân.  Kích thước .text của kernel tăng khoảng
3,2%, dẫn đến sự chậm lại trên toàn nhân.  Số đo của Mel
Gorman [1]_ đã cho thấy một số khối lượng công việc bị chậm lại từ 5-10%.

Ngược lại, trình tháo gỡ ORC không ảnh hưởng đến kích thước văn bản hoặc thời gian chạy
hiệu suất, vì thông tin gỡ lỗi nằm ngoài phạm vi.  Vì vậy, nếu bạn vô hiệu hóa
con trỏ khung và kích hoạt trình gỡ bỏ ORC, bạn sẽ có được hiệu suất tốt
cải tiến toàn diện và vẫn có dấu vết ngăn xếp đáng tin cậy.

Ingo Molnar nói:

"Lưu ý rằng đây không chỉ là cải thiện hiệu suất mà còn là một
  hướng dẫn cải thiện vị trí bộ đệm: 3,2% tiết kiệm văn bản gần như
  trực tiếp chuyển đổi thành bộ nhớ đệm có kích thước tương tự
  dấu chân. Điều đó có thể chuyển đổi thành tốc độ cao hơn nữa cho khối lượng công việc
  có vị trí bộ đệm nằm ở ranh giới."

Một lợi ích khác của ORC so với con trỏ khung là nó có thể
thư giãn một cách đáng tin cậy qua các ngắt và ngoại lệ.  Dựa trên con trỏ khung
thư giãn đôi khi có thể bỏ qua người gọi hàm bị gián đoạn, nếu nó
là một hàm lá hoặc nếu ngắt xảy ra trước con trỏ khung
đã lưu.

Nhược điểm chính của bộ tháo gỡ ORC so với con trỏ khung là
rằng nó cần nhiều bộ nhớ hơn để lưu trữ các bảng thư giãn ORC: khoảng 2-4MB
tùy thuộc vào cấu hình kernel.


ORC so với DWARF
============

Ưu điểm của thông tin gỡ lỗi ORC so với bản thân DWARF là nó đơn giản hơn nhiều.
Nó loại bỏ máy trạng thái DWARF CFI phức tạp và cũng loại bỏ
việc theo dõi các sổ đăng ký không cần thiết.  Điều này cho phép bộ tháo cuộn được
đơn giản hơn nhiều, nghĩa là ít lỗi hơn, điều này đặc biệt quan trọng đối với
nhiệm vụ quan trọng mã rất tiếc.

Định dạng thông tin gỡ lỗi đơn giản hơn cũng cho phép trình gỡ bỏ nhanh hơn nhiều
hơn DWARF, điều này quan trọng đối với sự hoàn hảo và lockdep.  Về cơ bản
thử nghiệm hiệu năng của Jiri Slaby [2]_, bộ tháo gỡ ORC đạt khoảng 20 lần
nhanh hơn bộ tháo gỡ DWARF ngoài cây.  (Lưu ý: Phép đo đó là
được thực hiện trước khi thêm một số điều chỉnh về hiệu suất, điều này đã tăng gấp đôi
hiệu suất, do đó tốc độ tăng tốc trên DWARF có thể gần hơn 40 lần.)

Định dạng dữ liệu ORC có một số nhược điểm so với DWARF.  ORC
các bảng thư giãn chiếm thêm ~50% RAM (+1,3 MB trên hạt nhân defconfig x86)
hơn các bảng eh_frame dựa trên DWARF.

Một nhược điểm tiềm tàng khác là khi GCC phát triển, có thể hình dung được
rằng dữ liệu ORC có thể trở thành ZZ0000ZZ để mô tả trạng thái của
ngăn xếp để tối ưu hóa nhất định.  Nhưng IMO điều này khó xảy ra vì
GCC lưu con trỏ khung cho bất kỳ điều chỉnh ngăn xếp bất thường nào nó thực hiện,
vì vậy tôi nghi ngờ chúng ta thực sự chỉ cần theo dõi ngăn xếp
con trỏ và con trỏ khung giữa các khung cuộc gọi.  Nhưng ngay cả nếu chúng ta làm
cuối cùng phải theo dõi tất cả các rãnh ghi DWARF trong sổ đăng ký, ít nhất chúng tôi sẽ
vẫn có thể kiểm soát định dạng, ví dụ: không có máy trạng thái phức tạp.


Thế hệ bàn thư giãn ORC
===========================

Dữ liệu ORC được tạo bởi objtool.  Với thời gian biên dịch hiện có
tính năng xác thực siêu dữ liệu ngăn xếp, objtool đã tuân theo tất cả mã
đường dẫn, và do đó nó đã có tất cả thông tin cần thiết để có thể
tạo dữ liệu ORC từ đầu.  Vì vậy, đây là một bước dễ dàng để đi từ ngăn xếp
xác thực để tạo dữ liệu ORC.

Thay vào đó, có thể tạo dữ liệu ORC bằng một thao tác đơn giản
công cụ chuyển đổi dữ liệu DWARF thành ORC.  Tuy nhiên, giải pháp như vậy sẽ
không đầy đủ do việc sử dụng rộng rãi asm, asm nội tuyến và
các phần đặc biệt như bảng ngoại lệ.

Điều đó có thể được khắc phục bằng cách chú thích thủ công các đường dẫn mã đặc biệt đó
sử dụng chú thích .cfi của trình biên dịch mã GNU trong các tệp .S và cây nhà lá vườn
chú thích cho asm nội tuyến trong tệp .c.  Nhưng chú thích asm đã được thử
trong quá khứ và được cho là không thể duy trì được.  Họ thường xuyên
không chính xác/không đầy đủ và làm cho mã khó đọc hơn và khó cập nhật hơn.
Và dựa trên việc xem mã glibc, chú thích mã asm nội tuyến trong tệp .c
có thể còn tệ hơn nữa.

Objtool vẫn cần một vài chú thích, nhưng chỉ ở dạng mã
những thứ bất thường đối với ngăn xếp như mã vào.  Và thậm chí sau đó, ít hơn nhiều
cần nhiều chú thích hơn những gì DWARF cần, vì vậy chúng còn hơn thế nữa
có thể duy trì hơn các chú thích DWARF CFI.

Vì vậy, lợi ích của việc sử dụng objtool để tạo dữ liệu ORC là nó
cung cấp thông tin gỡ lỗi chính xác hơn với rất ít chú thích.  Nó cũng
cách ly hạt nhân khỏi các lỗi của chuỗi công cụ có thể gây khó khăn cho
xử lý trong kernel vì chúng ta thường phải giải quyết các vấn đề trong
phiên bản cũ hơn của chuỗi công cụ trong nhiều năm.

Nhược điểm là trình tháo gỡ bây giờ trở nên phụ thuộc vào objtool's
khả năng đảo ngược dòng mã GCC.  Nếu tối ưu hóa GCC trở thành
quá phức tạp để objtool có thể theo dõi, việc tạo dữ liệu ORC có thể
ngừng hoạt động hoặc trở nên không đầy đủ.  (Điều đáng lưu ý là livepatch
đã phụ thuộc như vậy vào khả năng tuân theo mã GCC của objtool
dòng chảy.)

Nếu các phiên bản mới hơn của GCC đưa ra một số tối ưu hóa làm hỏng
objtool, chúng ta có thể cần phải xem lại cách triển khai hiện tại.  Một số
các giải pháp khả thi sẽ yêu cầu GCC thực hiện tối ưu hóa nhiều hơn
ngon miệng hoặc có objtool sử dụng DWARF làm đầu vào bổ sung hoặc
tạo plugin GCC để hỗ trợ objtool phân tích.  Nhưng bây giờ,
objtool tuân theo mã GCC khá tốt.


Chi tiết triển khai Unwinder
===============================

Objtool tạo dữ liệu ORC bằng cách tích hợp với thời gian biên dịch
tính năng xác thực siêu dữ liệu ngăn xếp, được mô tả chi tiết trong
công cụ/objtool/Tài liệu/objtool.txt.  Sau khi phân tích tất cả
đường dẫn mã của tệp .o, nó tạo ra một mảng cấu trúc orc_entry,
và một mảng song song các địa chỉ lệnh liên kết với những địa chỉ đó
cấu trúc và ghi chúng vào phần .orc_unwind và .orc_unwind_ip
tương ứng.

Dữ liệu ORC được chia thành hai mảng vì lý do hiệu suất, để
làm cho phần dữ liệu có thể tìm kiếm được (.orc_unwind_ip) nhỏ gọn hơn.  các
mảng được sắp xếp song song lúc khởi động.

Hiệu suất được cải thiện hơn nữa bằng cách sử dụng bảng tra cứu nhanh
được tạo ra trong thời gian chạy.  Bảng tra cứu nhanh liên kết một địa chỉ nhất định
với một loạt các chỉ mục cho bảng .orc_unwind, do đó chỉ một lượng nhỏ
tập hợp con của bảng cần được tìm kiếm.


Từ nguyên
=========

Orc, sinh vật đáng sợ trong văn hóa dân gian thời trung cổ, là bản chất tự nhiên của Người lùn.
kẻ thù.  Tương tự, bộ tháo gỡ ORC được tạo ra để đối lập với
độ phức tạp và chậm chạp của DWARF.

"Mặc dù loài Orc hiếm khi xem xét nhiều giải pháp cho một vấn đề, nhưng chúng có
xuất sắc trong việc hoàn thành công việc vì họ là sinh vật của hành động chứ không phải
nghĩ." [3]_ Tương tự, không giống như công cụ tháo gỡ DWARF bí truyền,
Bộ giải mã ORC đích thực không lãng phí thời gian hoặc công sức giải mã siloconic
mã byte số nguyên không dấu có độ dài thay đổi bằng 0
các mục thông tin gỡ lỗi dựa trên trạng thái máy.

Tương tự như cách lũ Orc thường xuyên làm sáng tỏ những kế hoạch có thiện chí của
đối thủ của họ, công cụ gỡ bỏ ORC thường xuyên giải quyết các ngăn xếp với
hiệu quả tàn bạo, kiên cường.

ORC là viết tắt của Khả năng tua lại rất tiếc.


.. [1] https://lore.kernel.org/r/20170602104048.jkkzssljsompjdwy@suse.de
.. [2] https://lore.kernel.org/r/d2ca5435-6386-29b8-db87-7f227c2b713a@suse.cz
.. [3] http://dustin.wikidot.com/half-orcs-and-orcs