.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/runtime-verification.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Xác minh thời gian chạy
====================

Xác minh thời gian chạy (RV) là một phương pháp nhẹ (nhưng nghiêm ngặt)
bổ sung cho các kỹ thuật xác minh toàn diện cổ điển (chẳng hạn như *model
kiểm tra* và ZZ0000ZZ) bằng cách tiếp cận thực tế hơn cho các vấn đề phức tạp
hệ thống.

Thay vì dựa vào mô hình chi tiết của một hệ thống (ví dụ:
thực hiện lại ở cấp độ hướng dẫn), RV hoạt động bằng cách phân tích dấu vết của
việc thực thi thực tế của hệ thống, so sánh nó với đặc tả hình thức của
hành vi của hệ thống.

Ưu điểm chính là RV có thể cung cấp thông tin chính xác về thời gian chạy
hành vi của hệ thống được giám sát mà không gặp phải những cạm bẫy khi phát triển mô hình
yêu cầu triển khai lại toàn bộ hệ thống bằng ngôn ngữ mô hình hóa.
Hơn nữa, với một phương pháp giám sát hiệu quả, có thể thực hiện một
ZZ0000ZZ xác minh hệ thống, cho phép ZZ0001ZZ xử lý các trường hợp không mong muốn
các sự kiện, ví dụ như tránh việc truyền bá lỗi trên các thiết bị quan trọng về an toàn
hệ thống.

Màn hình thời gian chạy và lò phản ứng
=============================

Màn hình là phần trung tâm của quá trình xác minh thời gian chạy của hệ thống. các
màn hình đứng giữa đặc điểm kỹ thuật chính thức của mong muốn (hoặc
hành vi không mong muốn) và dấu vết của hệ thống thực tế.

Theo thuật ngữ Linux, các màn hình xác minh thời gian chạy được gói gọn bên trong
Sự trừu tượng của ZZ0000ZZ. ZZ0001ZZ bao gồm một mô hình tham chiếu của
hệ thống, một tập hợp các phiên bản của màn hình (màn hình trên mỗi CPU, màn hình trên mỗi tác vụ,
v.v.) và các chức năng trợ giúp gắn màn hình vào hệ thống thông qua
dấu vết, như được mô tả dưới đây::

Linux +---- Màn hình RV ----------------------------------+ Chính thức
  Vương quốc ZZ0000ZZ Vương quốc
  +-------------------+ +----------------+ +-----------------+
  ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
  ZZ0004ZZ -> ZZ0005ZZ <- ZZ0006ZZ
  ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
  +-------------------+ +----------------+ +-----------------+
         ZZ0010ZZ |
         ZZ0011ZZ
         ZZ0012ZZ
         Phản ứng ZZ0013ZZ ZZ0014ZZ
         ZZ0015ZZ
         ZZ0016ZZ ZZ0017ZZ |
         ZZ0018ZZ ZZ0019ZZ
         +-----------------------ZZ0020ZZ----------------------+
                                  |  +----> hoảng loạn ?
                                  +-------> <do người dùng chỉ định>

Ngoài việc xác minh và giám sát hệ thống, người giám sát có thể
phản ứng trước một sự kiện bất ngờ. Các hình thức phản ứng có thể khác nhau từ việc ghi lại
sự kiện xảy ra để thực thi hành vi đúng đắn đến mức cực đoan
hành động gỡ bỏ một hệ thống để tránh sự lan truyền của lỗi.

Theo thuật ngữ Linux, ZZ0000ZZ là một phương thức phản ứng có sẵn cho ZZ0001ZZ.
Theo mặc định, tất cả các màn hình sẽ cung cấp đầu ra dấu vết về hành động của chúng,
đó đã là một phản ứng. Ngoài ra, các phản ứng khác sẽ có sẵn
để người dùng có thể kích hoạt chúng khi cần thiết.

Để biết thêm thông tin về các nguyên tắc xác minh thời gian chạy và
RV áp dụng cho Linux:

Bartocci, Ezio và cộng sự. ZZ0000ZZ Trong: Bài giảng về
  Xác minh thời gian chạy. Springer, Chăm, 2018. tr. 1-33.

Falcone, Ylies và cộng sự. ZZ0000ZZ
  Trong: Hội nghị quốc tế về xác minh thời gian chạy. Springer, Chăm, 2018. tr.
  241-262.

De Oliveira, Daniel Bristot. * Phân tích chính thức dựa trên Automata và
  xác minh nhân Linux thời gian thực.* Ph.D. Luận án, 2020.

Màn hình RV trực tuyến
==================

Màn hình có thể được phân loại thành màn hình ZZ0000ZZ và ZZ0001ZZ. ZZ0002ZZ
quá trình giám sát các dấu vết do hệ thống tạo ra sau các sự kiện, thường là bởi
đọc quá trình thực hiện theo dõi từ hệ thống lưu trữ cố định. Màn hình ZZ0003ZZ
xử lý dấu vết trong quá trình thực thi hệ thống. Màn hình trực tuyến được cho là
là ZZ0004ZZ nếu việc xử lý sự kiện được gắn vào hệ thống
thực thi, chặn hệ thống trong quá trình giám sát sự kiện. Mặt khác,
màn hình ZZ0005ZZ có quá trình thực thi tách khỏi hệ thống. Mỗi loại
của màn hình có một số lợi thế. Ví dụ: màn hình ZZ0006ZZ có thể
được thực thi trên các máy khác nhau nhưng yêu cầu các thao tác để lưu nhật ký vào một
tập tin. Ngược lại, phương pháp ZZ0007ZZ có thể phản ứng vào thời điểm chính xác
xảy ra vi phạm.

Một khía cạnh quan trọng khác liên quan đến màn hình là chi phí liên quan đến
phân tích sự kiện. Nếu hệ thống tạo ra các sự kiện ở tần suất cao hơn tần số
khả năng xử lý chúng của màn hình trong cùng một hệ thống, chỉ có ZZ0000ZZ
những phương pháp khả thi. Mặt khác, nếu việc theo dõi các sự kiện xảy ra
với chi phí cao hơn việc xử lý sự kiện đơn giản bằng màn hình, thì
Màn hình ZZ0001ZZ sẽ có chi phí hoạt động thấp hơn.

Thật vậy, nghiên cứu được trình bày trong:

De Oliveira, Daniel Bristot; Cucinotta, Tommaso; De Oliveira, Romulo Silva.
  ZZ0000ZZ Trong: Quốc tế
  Hội nghị về Kỹ thuật phần mềm và các phương pháp chính thức. Springer, Chăm, 2019.
  trang. 315-332.

Cho thấy rằng đối với các mô hình Automata xác định, việc xử lý đồng bộ
các sự kiện trong kernel gây ra chi phí thấp hơn so với việc lưu các sự kiện tương tự vào dấu vết
đệm, thậm chí không xem xét việc thu thập dấu vết để phân tích không gian người dùng.
Điều này thúc đẩy sự phát triển giao diện trong kernel cho màn hình trực tuyến.

Để biết thêm thông tin về mô hình hóa hành vi của nhân Linux bằng automata,
xem:

De Oliveira, Daniel B.; De Oliveira, Romulo S.; Cucinotta, Tommaso. *Một sợi chỉ
  mô hình đồng bộ hóa cho nhân Linux PREEMPT_RT.* Tạp chí Hệ thống
  Kiến trúc, 2020, 107: 101729.

Giao diện người dùng
==================

Giao diện người dùng giống với giao diện theo dõi (có mục đích). Đó là
hiện ở "/sys/kernel/tracing/rv/".

Các tập tin/thư mục sau hiện có sẵn:

ZZ0000ZZ

- Đọc danh sách các màn hình có sẵn, mỗi màn hình một dòng

Ví dụ::

# cat có sẵn_màn hình
   lau
   wwnr

ZZ0000ZZ

- Đọc hiển thị các lò phản ứng có sẵn, mỗi lò một dòng.

Ví dụ::

# cat có sẵn_reactors
   không
   hoảng loạn
   bản in

ZZ0000ZZ:

- Đọc danh sách các màn hình được kích hoạt, mỗi màn hình một dòng
- Viết cho nó cho phép một màn hình nhất định
- Viết tên màn hình bằng dấu '!' tiền tố vô hiệu hóa nó
- Cắt bớt tập tin sẽ vô hiệu hóa tất cả các màn hình được kích hoạt

Ví dụ::

# cat đã bật_màn hình
   Xóa # echo > đã bật_monitor
   # echo wwnr >> đã bật_monitor
   # cat kích hoạt_màn hình
   lau
   wwnr
   # echo '!wip' >> Enable_monitors
   # cat kích hoạt_màn hình
   wwnr
   # echo > đã bật_monitor
   # cat kích hoạt_màn hình
   #

Lưu ý rằng có thể kích hoạt đồng thời nhiều màn hình.

ZZ0000ZZ

Đây là một công tắc bật/tắt chung để theo dõi. Nó giống như
trình chuyển đổi "tracing_on" trong giao diện theo dõi.

- Viết "0" dừng việc giám sát
- Viết “1” tiếp tục theo dõi
- Đọc trả về trạng thái hiện tại của việc giám sát

Lưu ý rằng nó không vô hiệu hóa các màn hình được kích hoạt nhưng dừng từng thực thể
giám sát việc theo dõi các sự kiện nhận được từ hệ thống.

ZZ0000ZZ

- Viết “0” ngăn chặn phản ứng xảy ra
- Viết "1" kích hoạt phản ứng
- Đọc trả về trạng thái hiện tại của phản ứng

ZZ0000ZZ

Mỗi màn hình sẽ có thư mục riêng bên trong "monitor/". Ở đó
các tập tin dành riêng cho màn hình sẽ được trình bày. Thư mục "monitor/" trông giống như
thư mục "sự kiện" trên tracefs.

Ví dụ::

Màn hình/wip/# cd
   # ls
   kích hoạt mô tả
   mô tả # cat
   đánh thức trong màn hình kiểm tra ưu tiên trên mỗi CPU.
   Kích hoạt # cat
   0

ZZ0000ZZ

- Đọc hiển thị mô tả về màn hình ZZ0000ZZ

ZZ0000ZZ

- Viết "0" sẽ vô hiệu hóa ZZ0000ZZ
- Viết "1" cho phép ZZ0001ZZ
- Đọc trả về trạng thái hiện tại của ZZ0002ZZ

ZZ0000ZZ

- Liệt kê các lò phản ứng có sẵn, với phản ứng chọn cho ZZ0000ZZ đã cho
  bên trong "[]". Cái mặc định là lò phản ứng nop (không hoạt động).
- Viết tên của lò phản ứng sẽ kích hoạt nó với MONITOR đã cho.

Ví dụ::

Màn hình/lau/lò phản ứng # cat
   [không]
   hoảng loạn
   bản in
   # echo hoảng loạn > màn hình/wip/lò phản ứng
   Màn hình/lau/lò phản ứng # cat
   không
   [hoảng loạn]
   bản in
