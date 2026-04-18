.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/pmu-ebb.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Các nhánh dựa trên sự kiện PMU
========================

Nhánh dựa trên sự kiện (EBB) là một tính năng cho phép phần cứng
phân nhánh trực tiếp đến một địa chỉ không gian người dùng được chỉ định khi một số sự kiện nhất định xảy ra.

Thông số kỹ thuật đầy đủ có sẵn trong Power ISA v2.07:

ZZ0000ZZ

Một loại sự kiện mà EBB có thể được cấu hình là các ngoại lệ PMU. Cái này
tài liệu mô tả API để định cấu hình Power PMU để tạo EBB,
bằng cách sử dụng Linux perf_events API.


Thuật ngữ
-----------

Trong suốt tài liệu này, chúng tôi sẽ đề cập đến "sự kiện EBB" hoặc "sự kiện EBB". Cái này
chỉ đề cập đến một struct perf_event đã đặt cờ "EBB" trong
attr.config. Tất cả các sự kiện có thể được cấu hình trên phần cứng PMU đều được
có thể xảy ra "sự kiện EBB".


Lý lịch
----------

Khi xảy ra PMU EBB, nó sẽ được chuyển đến quy trình hiện đang chạy. Như vậy
EBB chỉ có thể được các chương trình sử dụng một cách hợp lý để tự giám sát.

Một tính năng của perf_events API là các sự kiện có thể được tạo trên các thiết bị khác
quy trình, tùy thuộc vào việc kiểm tra quyền tiêu chuẩn. Điều này cũng đúng với EBB
tuy nhiên, trừ khi quy trình đích kích hoạt EBB (thông qua mtspr(BESCR)) không
EBB sẽ được chuyển giao.

Điều này giúp một tiến trình có thể kích hoạt EBB cho chính nó, nhưng không
thực sự cấu hình bất kỳ sự kiện nào. Sau đó một quá trình khác có thể xảy ra
và đính kèm một sự kiện EBB vào quy trình, sau đó sẽ khiến EBB bị
được chuyển giao cho quá trình đầu tiên. Không rõ liệu điều này có thực sự hữu ích hay không.


Khi PMU được cấu hình cho EBB, tất cả các ngắt PMU sẽ được gửi tới
quá trình người dùng. Điều này có nghĩa là một khi sự kiện EBB được lên lịch trên PMU thì không có sự kiện nào không phải EBB
các sự kiện có thể được cấu hình. Điều này có nghĩa là các sự kiện EBB không thể chạy được
đồng thời với các lệnh 'perf' thông thường hoặc bất kỳ sự kiện hoàn hảo nào khác.

Tuy nhiên, việc chạy lệnh 'perf' trên quy trình đang sử dụng EBB là an toàn. các
kernel nói chung sẽ lên lịch cho sự kiện EBB và perf sẽ được thông báo rằng
các sự kiện của nó không thể chạy.

Việc loại trừ giữa các sự kiện EBB và các sự kiện thông thường được thực hiện bằng cách sử dụng
các thuộc tính "được ghim" và "độc quyền" hiện có của perf_events. Điều này có nghĩa là EBB
các sự kiện sẽ được ưu tiên hơn các sự kiện khác, trừ khi chúng cũng được ghim.
Nếu cả sự kiện EBB và sự kiện thông thường đều được ghim thì tùy theo sự kiện nào được bật
đầu tiên sẽ được lên lịch và cái còn lại sẽ ở trạng thái lỗi. Xem
phần bên dưới có tiêu đề "Kích hoạt sự kiện EBB" để biết thêm thông tin.


Tạo sự kiện EBB
---------------------

Để yêu cầu tính một sự kiện bằng EBB, mã sự kiện phải có bit
Bộ 63.

Các sự kiện EBB phải được tạo bằng một tập hợp cụ thể và hạn chế
thuộc tính - điều này là để chúng tương tác chính xác với phần còn lại của
hệ thống con perf_events.

Sự kiện EBB phải được tạo bằng bộ thuộc tính "được ghim" và "độc quyền".
Lưu ý rằng nếu bạn đang tạo một nhóm sự kiện EBB, chỉ người lãnh đạo mới có thể có
các thuộc tính này được thiết lập.

Một sự kiện EBB phải NOT đặt bất kỳ giá trị "kế thừa", "sample_ Period", "freq" hoặc
Thuộc tính "enable_on_exec".

Một sự kiện EBB phải được gắn vào một tác vụ. Điều này được chỉ định cho perf_event_open()
bằng cách chuyển một giá trị pid, thường là 0 cho biết tác vụ hiện tại.

Tất cả các sự kiện trong nhóm phải đồng ý về việc họ có muốn EBB hay không. Đó là tất cả sự kiện
phải yêu cầu EBB, hoặc không ai có thể yêu cầu EBB.

Các sự kiện EBB phải chỉ định PMC mà chúng được tính vào. Điều này đảm bảo
không gian người dùng có thể xác định một cách đáng tin cậy sự kiện được lên lịch trên PMC nào.


Kích hoạt sự kiện EBB
---------------------

Khi một sự kiện EBB đã được mở thành công, nó phải được kích hoạt bằng
perf_events API. Điều này có thể đạt được thông qua giao diện ioctl() hoặc
giao diện prctl().

Tuy nhiên, do thiết kế của perf_events API, việc kích hoạt một sự kiện không
đảm bảo rằng nó đã được lên lịch trên PMU. Để đảm bảo rằng sự kiện EBB
đã được lên lịch trên PMU, bạn phải thực hiện đọc() sự kiện này. Nếu
read() trả về EOF, khi đó sự kiện chưa được lên lịch và EBB không
đã bật.

Hiện tượng này xảy ra do sự kiện EBB được ghim và độc quyền. Khi
Sự kiện EBB được bật, nó sẽ buộc tất cả các sự kiện không được ghim khác khỏi PMU. trong
trường hợp này việc kích hoạt sẽ thành công. Tuy nhiên nếu đã có một sự kiện
được ghim trên PMU thì việc kích hoạt sẽ không thành công.


Đọc sự kiện EBB
--------------------

Có thể đọc() từ sự kiện EBB. Tuy nhiên kết quả là
vô nghĩa. Bởi vì các ngắt đang được gửi tới tiến trình của người dùng nên
kernel không thể đếm sự kiện và do đó sẽ trả về giá trị rác.


Kết thúc sự kiện EBB
--------------------

Khi một sự kiện EBB kết thúc, bạn có thể đóng nó bằng cách sử dụng close() như đối với bất kỳ sự kiện nào
sự kiện thường xuyên. Nếu đây là sự kiện EBB cuối cùng thì PMU sẽ được giải cấu hình và
sẽ không có EBB PMU nào nữa được phân phối.


Bộ xử lý EBB
-----------

Trình xử lý EBB chỉ là mã không gian người dùng thông thường, tuy nhiên nó phải được viết bằng
phong cách của một trình xử lý ngắt. Khi trình xử lý được nhập vào tất cả các thanh ghi
đang hoạt động (có thể) và do đó phải được lưu bằng cách nào đó trước khi trình xử lý có thể gọi
mã khác.

Việc xử lý việc này thế nào là tùy thuộc vào chương trình. Đối với các chương trình C, việc này tương đối đơn giản
tùy chọn là tạo khung ngắt trên ngăn xếp và lưu các thanh ghi ở đó.

Cái nĩa
----

Các sự kiện EBB không được kế thừa qua nhánh. Nếu tiến trình con muốn sử dụng
EBB nó sẽ mở ra một sự kiện mới cho chính nó. Tương tự trạng thái EBB trong
BESCR/EBBHR/EBBRR bị xóa qua fork().
