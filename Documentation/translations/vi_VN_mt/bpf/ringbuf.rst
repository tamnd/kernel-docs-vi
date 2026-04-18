.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/ringbuf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================
Bộ đệm vòng BPF
===============

Tài liệu này mô tả thiết kế bộ đệm vòng BPF, API và chi tiết triển khai.

.. contents::
    :local:
    :depth: 2

Động lực
----------

Có hai động lực đặc biệt cho công việc này không được thỏa mãn bởi
bộ đệm hoàn hảo hiện có, điều này đã thúc đẩy việc tạo bộ đệm vòng mới
thực hiện.

- sử dụng bộ nhớ hiệu quả hơn bằng cách chia sẻ bộ đệm vòng giữa các CPU;
- Duy trì thứ tự các sự kiện xảy ra tuần tự theo thời gian, thậm chí xuyên suốt
  nhiều CPU (ví dụ: các sự kiện fork/exec/exit cho một tác vụ).

Hai vấn đề này là độc lập, nhưng bộ đệm hoàn hảo không đáp ứng được cả hai.
Cả hai đều là kết quả của sự lựa chọn có bộ đệm vòng hoàn hảo cho mỗi CPU.  Cả hai đều có thể
cũng được giải quyết bằng cách triển khai bộ đệm vòng MPSC. Việc đặt hàng
vấn đề về mặt kỹ thuật có thể được giải quyết đối với bộ đệm hoàn hảo với một số trong kernel
đếm, nhưng với cái đầu tiên yêu cầu bộ đệm MPSC, giải pháp tương tự
sẽ tự động giải quyết vấn đề thứ hai.

Ngữ nghĩa và API
------------------

Bộ đệm vòng đơn được hiển thị cho các chương trình BPF dưới dạng bản đồ BPF của
loại ZZ0000ZZ. Hai lựa chọn thay thế khác được xem xét, nhưng
cuối cùng bị từ chối.

Một cách tương tự như ZZ0000ZZ là tạo
ZZ0001ZZ có thể đại diện cho một mảng bộ đệm vòng, nhưng không
thực thi quy tắc "chỉ CPU tương tự". Giao diện này sẽ tương thích với giao diện quen thuộc hơn
với việc sử dụng bộ đệm hoàn hảo hiện có trong BPF, nhưng sẽ thất bại nếu ứng dụng cần thêm
logic nâng cao để tra cứu bộ đệm vòng bằng phím tùy ý.
ZZ0002ZZ giải quyết vấn đề này bằng cách tiếp cận hiện tại.
Ngoài ra, với hiệu suất của ringbuf BPF, nhiều trường hợp sử dụng sẽ chỉ
chọn tham gia vào một bộ đệm vòng đơn đơn giản được chia sẻ giữa tất cả các CPU.
cách tiếp cận này sẽ là quá mức cần thiết.

Một cách tiếp cận khác có thể giới thiệu một khái niệm mới, cùng với bản đồ BPF, để thể hiện
đối tượng "container" chung chung, không nhất thiết phải có giao diện khóa/giá trị
với các thao tác tra cứu/cập nhật/xóa. Cách tiếp cận này sẽ bổ sung thêm rất nhiều
cơ sở hạ tầng phải được xây dựng để hỗ trợ khả năng quan sát và xác minh. Nó
cũng sẽ thêm một khái niệm khác mà các nhà phát triển BPF sẽ phải làm quen
với cú pháp mới trong libbpf, v.v. Nhưng sau đó thực sự sẽ không cung cấp
lợi ích bổ sung so với cách tiếp cận sử dụng bản đồ.  ZZ0000ZZ
không hỗ trợ các thao tác tra cứu/cập nhật/xóa, nhưng một số bản đồ khác cũng vậy
các loại (ví dụ: hàng đợi và ngăn xếp; mảng không hỗ trợ xóa, v.v.).

Cách tiếp cận được chọn có ưu điểm là sử dụng lại bản đồ BPF hiện có
cơ sở hạ tầng (API xem xét nội tâm trong kernel, hỗ trợ libbpf, v.v.),
khái niệm quen thuộc (không cần dạy người dùng loại đối tượng mới trong chương trình BPF),
và sử dụng công cụ hiện có (bpftool). Đối với trường hợp phổ biến của việc sử dụng một
bộ đệm vòng cho tất cả các CPU, nó đơn giản và dễ hiểu như với
một đối tượng "container" chuyên dụng. Mặt khác, bằng cách là một bản đồ, nó có thể
kết hợp với bản đồ trong bản đồ ZZ0000ZZ và ZZ0001ZZ để triển khai
nhiều cấu trúc liên kết khác nhau, từ một bộ đệm vòng cho mỗi CPU (ví dụ: như
một sự thay thế cho các trường hợp sử dụng bộ đệm hoàn hảo), cho một ứng dụng phức tạp
băm/phân mảnh bộ đệm vòng (ví dụ: có một nhóm nhỏ bộ đệm vòng
với tgid của tác vụ băm là chìa khóa tra cứu để duy trì trật tự nhưng giảm bớt
tranh chấp).

Kích thước khóa và giá trị được thực thi bằng 0. ZZ0000ZZ được sử dụng để chỉ định
kích thước của bộ đệm vòng và phải có giá trị lũy thừa là 2.

Có rất nhiều điểm tương đồng giữa bộ đệm hoàn hảo
(ZZ0000ZZ) và ngữ nghĩa bộ đệm vòng BPF mới:

- bản ghi có độ dài thay đổi;
- nếu không còn chỗ trống trong bộ đệm vòng, việc đặt chỗ không thành công, không
  chặn;
- vùng dữ liệu có thể ánh xạ bộ nhớ dành cho các ứng dụng trong không gian người dùng để dễ dàng
  tiêu thụ và hiệu suất cao;
- thông báo epoll cho dữ liệu mới đến;
- nhưng vẫn có khả năng thực hiện việc thăm dò dữ liệu mới để đạt được mục tiêu
  độ trễ thấp nhất, nếu cần thiết.

BPF ringbuf cung cấp hai bộ API cho các chương trình BPF:

- ZZ0000ZZ cho phép dữ liệu ZZ0005ZZ từ một nơi đến một vòng
  bộ đệm, tương tự như ZZ0001ZZ;
-ZZ0002ZZ/ZZ0003ZZ/ZZ0004ZZ
  API chia toàn bộ quá trình thành hai bước. Đầu tiên, một lượng không gian cố định
  được bảo lưu. Nếu thành công, một con trỏ tới dữ liệu bên trong dữ liệu bộ đệm vòng
  khu vực được trả về, mà các chương trình BPF có thể sử dụng tương tự như dữ liệu bên trong
  bản đồ mảng/băm. Khi đã sẵn sàng, phần bộ nhớ này được cam kết hoặc
  bị loại bỏ. Loại bỏ tương tự như cam kết nhưng khiến người tiêu dùng bỏ qua
  ghi lại.

ZZ0000ZZ có nhược điểm là phát sinh thêm bản sao bộ nhớ,
bởi vì hồ sơ phải được chuẩn bị ở một nơi khác trước. Nhưng nó cho phép
gửi bản ghi có độ dài mà người xác minh không biết trước. Nó cũng
phù hợp chặt chẽ với ZZ0001ZZ, do đó sẽ đơn giản hóa việc di chuyển
đáng kể.

ZZ0000ZZ tránh sao chép thêm bộ nhớ bằng cách cung cấp bộ nhớ
con trỏ trực tiếp tới bộ nhớ đệm vòng. Trong nhiều trường hợp hồ sơ lớn hơn
hơn không gian ngăn xếp BPF cho phép, vì vậy nhiều chương trình đã sử dụng mảng bổ sung trên mỗi CPU như
một đống tạm thời để chuẩn bị mẫu. bpf_ringbuf_reserve() tránh nhu cầu này
hoàn toàn. Nhưng đổi lại, nó chỉ cho phép một kích thước bộ nhớ không đổi đã biết
được bảo lưu, để người xác minh có thể xác minh rằng chương trình BPF không thể truy cập bộ nhớ
bên ngoài không gian bản ghi dành riêng của nó. bpf_ringbuf_output(), tuy chậm hơn một chút
do sao chép thêm bộ nhớ, bao gồm một số trường hợp sử dụng không phù hợp với
ZZ0001ZZ.

Sự khác biệt giữa cam kết và loại bỏ là rất nhỏ. Loại bỏ chỉ dấu
một bản ghi bị loại bỏ và những bản ghi đó được cho là sẽ bị người tiêu dùng bỏ qua
mã. Loại bỏ rất hữu ích cho một số trường hợp sử dụng nâng cao, chẳng hạn như đảm bảo
gửi nhiều bản ghi tất cả hoặc không có gì hoặc mô phỏng tạm thời
ZZ0000ZZ/ZZ0001ZZ trong lệnh gọi chương trình BPF duy nhất.

Mỗi bản ghi dành riêng được theo dõi bởi người xác minh thông qua
logic theo dõi tham chiếu, tương tự như theo dõi lại ổ cắm. Vì thế
không thể bảo lưu một bản ghi mà quên nộp (hoặc loại bỏ) nó.

Trình trợ giúp ZZ0000ZZ cho phép truy vấn các thuộc tính khác nhau của vòng
bộ đệm.  Hiện tại có 4 được hỗ trợ:

- ZZ0000ZZ trả về lượng dữ liệu chưa được sử dụng trong bộ đệm vòng;
- ZZ0001ZZ trả về kích thước của bộ đệm vòng;
- ZZ0002ZZ/ZZ0003ZZ trả về vị trí logic hiện tại
  của người tiêu dùng/nhà sản xuất tương ứng.

Các giá trị được trả về là ảnh chụp nhanh trong giây lát của trạng thái bộ đệm vòng và có thể
tắt trước khi người trợ giúp quay lại, vì vậy nó chỉ nên được sử dụng cho
lý do gỡ lỗi/báo cáo hoặc để triển khai các phương pháp phỏng đoán khác nhau, cần
tính đến tính chất dễ thay đổi của một số đặc điểm đó.

Một phương pháp phỏng đoán như vậy có thể liên quan đến việc kiểm soát chi tiết hơn đối với thăm dò ý kiến/epoll
thông báo về tính khả dụng của dữ liệu mới trong bộ đệm vòng. Cùng với
Cờ ZZ0000ZZ/ZZ0001ZZ cho đầu ra/cam kết/loại bỏ
người trợ giúp, nó cho phép chương trình BPF có mức độ kiểm soát cao và, ví dụ: hơn thế nữa
thông báo theo đợt hiệu quả. Tuy nhiên, chiến lược tự cân bằng mặc định
phải phù hợp cho hầu hết các ứng dụng và sẽ hoạt động đáng tin cậy và hiệu quả
rồi.

Thiết kế và thực hiện
-------------------------

Lược đồ dự trữ/cam kết này cung cấp một cách tự nhiên cho nhiều nhà sản xuất, hoặc
trên các CPU khác nhau hoặc thậm chí trên cùng một CPU/trong cùng một chương trình BPF, để dự trữ
hồ sơ độc lập và làm việc với họ mà không chặn các nhà sản xuất khác. Cái này
có nghĩa là nếu chương trình BPF bị gián đoạn bởi một chương trình BPF khác chia sẻ
cùng một bộ đệm vòng, cả hai sẽ nhận được một bản ghi dành riêng (miễn là có
còn đủ chỗ trống) và có thể làm việc với nó và gửi nó một cách độc lập. Cái này
cũng áp dụng cho ngữ cảnh NMI, ngoại trừ việc sử dụng khóa xoay trong
đặt trước, trong ngữ cảnh NMI, ZZ0000ZZ có thể không nhận được
một khóa, trong trường hợp đó việc đặt trước sẽ không thành công ngay cả khi bộ đệm vòng không đầy.

Bản thân bộ đệm vòng bên trong được triển khai dưới dạng bộ đệm có kích thước bằng 2
bộ đệm tròn, với hai bộ đếm logic và ngày càng tăng (có thể
xoay quanh kiến ​​trúc 32 bit, đó không phải là vấn đề):

- bộ đếm người tiêu dùng hiển thị vị trí logic mà người tiêu dùng đã tiêu thụ
  dữ liệu;
- bộ đếm nhà sản xuất biểu thị lượng dữ liệu được bảo lưu bởi tất cả các nhà sản xuất.

Mỗi khi một bản ghi được bảo lưu, nhà sản xuất “sở hữu” bản ghi đó sẽ
nâng cao thành công bộ đếm nhà sản xuất. Khi đó dữ liệu vẫn chưa
Tuy nhiên, đã sẵn sàng để được tiêu thụ. Mỗi bản ghi có tiêu đề 8 byte, chứa
độ dài của bản ghi dành riêng, cũng như hai bit bổ sung: bit bận để biểu thị rằng
bản ghi vẫn đang được xử lý và loại bỏ bit, có thể được đặt ở cam kết
thời gian nếu bản ghi bị loại bỏ. Trong trường hợp sau, người tiêu dùng có nghĩa vụ phải bỏ qua
bản ghi và chuyển sang bản ghi tiếp theo. Tiêu đề bản ghi cũng mã hóa thông tin của bản ghi
độ lệch tương đối so với phần đầu của vùng dữ liệu bộ đệm vòng (tính bằng trang). Cái này
cho phép ZZ0000ZZ/ZZ0001ZZ chỉ chấp nhận
con trỏ tới chính bản ghi mà không yêu cầu con trỏ tới bộ đệm vòng
chính nó. Vị trí bộ nhớ đệm vòng sẽ được khôi phục từ siêu dữ liệu bản ghi
tiêu đề. Điều này đơn giản hóa đáng kể trình xác minh cũng như cải thiện API
khả năng sử dụng.

Số gia tăng bộ đếm của nhà sản xuất được tuần tự hóa dưới dạng spinlock, do đó có
một trật tự nghiêm ngặt giữa các đặt phòng. Mặt khác, các cam kết là
hoàn toàn không khóa và độc lập. Tất cả hồ sơ đều có sẵn cho người tiêu dùng
theo thứ tự đặt trước, nhưng chỉ sau tất cả các hồ sơ trước đó mà
đã cam kết rồi. Do đó, các nhà sản xuất chậm có thể tạm thời giữ lại
hồ sơ đã nộp sẽ được bảo lưu sau đó.

Một bước triển khai thú vị, giúp đơn giản hóa đáng kể (và do đó
cũng tăng tốc) việc triển khai của cả nhà sản xuất và người tiêu dùng là cách dữ liệu
khu vực được ánh xạ hai lần liên tiếp nhau trong bộ nhớ ảo. Cái này
cho phép không thực hiện bất kỳ biện pháp đặc biệt nào đối với các mẫu phải quấn quanh
ở cuối vùng dữ liệu bộ đệm tròn, vì trang tiếp theo sau
trang dữ liệu cuối cùng sẽ lại là trang dữ liệu đầu tiên và do đó mẫu vẫn sẽ
xuất hiện hoàn toàn liền kề trong bộ nhớ ảo. Xem bình luận và một ASCII đơn giản
sơ đồ hiển thị điều này một cách trực quan trong ZZ0000ZZ.

Một tính năng khác giúp phân biệt ringbuf BPF với bộ đệm vòng hoàn hảo là
thông báo tự điều chỉnh về dữ liệu mới có sẵn.
Việc triển khai ZZ0000ZZ sẽ gửi thông báo về bản ghi mới
chỉ khả dụng sau khi cam kết nếu người tiêu dùng đã bắt kịp ngay
hồ sơ được cam kết. Nếu không, người tiêu dùng vẫn phải bắt kịp và do đó
vẫn sẽ thấy dữ liệu mới mà không cần thêm thông báo thăm dò ý kiến.
Điểm chuẩn (xem công cụ/kiểm tra/selftests/bpf/benchs/bench_ringbufs.c) cho thấy điều đó
điều này cho phép đạt được thông lượng rất cao mà không cần phải dùng đến
các thủ thuật như "chỉ thông báo cho mọi mẫu thứ N", cần thiết với sự hoàn hảo
bộ đệm. Đối với những trường hợp đặc biệt, khi chương trình BPF muốn điều khiển thủ công nhiều hơn
thông báo, người trợ giúp cam kết/loại bỏ/đầu ra chấp nhận ZZ0001ZZ và
Cờ ZZ0002ZZ, cung cấp toàn quyền kiểm soát các thông báo của
tính sẵn có của dữ liệu, nhưng cần hết sức thận trọng và siêng năng khi sử dụng API này.
