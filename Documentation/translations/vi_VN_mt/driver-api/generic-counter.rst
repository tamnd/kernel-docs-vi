.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/generic-counter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Giao diện bộ đếm chung
=========================

Giới thiệu
============

Các thiết bị đếm rất phổ biến trong nhiều ngành công nghiệp.
Sự hiện diện khắp nơi của các thiết bị này đòi hỏi một giao diện chung
và tiêu chuẩn tương tác và tiếp xúc. Trình điều khiển API này cố gắng
giải quyết vấn đề mã trùng lặp được tìm thấy giữa các thiết bị đếm hiện có
trình điều khiển bằng cách giới thiệu một giao diện truy cập chung để tiêu thụ. các
Giao diện Bộ đếm chung cho phép trình điều khiển hỗ trợ và hiển thị một điểm chung
tập hợp các thành phần và chức năng có trong các thiết bị đếm.

Lý thuyết
======

Các thiết bị đếm có thể khác nhau rất nhiều về thiết kế, nhưng bất kể
một số thiết bị là bộ đếm mã hóa cầu phương hoặc bộ đếm kiểm đếm, tất cả
thiết bị đếm bao gồm một bộ thành phần cốt lõi. Bộ cốt lõi này của
các thành phần, được chia sẻ bởi tất cả các thiết bị đếm, là những gì tạo nên bản chất của
giao diện Bộ đếm chung.

Có ba thành phần cốt lõi của một bộ đếm:

* Tín hiệu:
  Luồng dữ liệu được đánh giá bởi bộ đếm.

* Xinap:
  Liên kết Tín hiệu và trình kích hoạt đánh giá với Số lượng.

* Đếm:
  Tích lũy tác dụng của các khớp thần kinh được kết nối.

SIGNAL
------
Tín hiệu đại diện cho một luồng dữ liệu. Đây là dữ liệu đầu vào được
được bộ đếm đánh giá để xác định dữ liệu đếm; ví dụ. một hình cầu phương
đường đầu ra tín hiệu của bộ mã hóa quay. Không phải tất cả các thiết bị đếm đều cung cấp
quyền truy cập của người dùng vào dữ liệu Tín hiệu, do đó việc hiển thị là tùy chọn đối với người lái xe.

Khi dữ liệu Tín hiệu có sẵn để người dùng truy cập, Bộ đếm chung
giao diện cung cấp các giá trị tín hiệu có sẵn sau đây:

*SIGNAL_LOW:
  Đường tín hiệu đang ở trạng thái thấp.

*SIGNAL_HIGH:
  Đường tín hiệu ở trạng thái cao.

Tín hiệu có thể được liên kết với một hoặc nhiều Số lượng.

SYNAPSE
-------
Synapse thể hiện sự liên kết của Tín hiệu với Số lượng. tín hiệu
dữ liệu ảnh hưởng đến dữ liệu Đếm tương ứng và Synapse thể hiện điều này
mối quan hệ.

Chế độ hành động Synapse chỉ định điều kiện dữ liệu Tín hiệu
kích hoạt đánh giá hàm đếm của Count tương ứng để cập nhật
đếm dữ liệu. Giao diện Bộ đếm chung cung cấp những thông tin sau
chế độ hành động có sẵn:

* Không:
  Tín hiệu không kích hoạt chức năng đếm. Trong số đếm hướng xung
  chế độ chức năng, Tín hiệu này được đánh giá là Hướng.

* Cạnh tăng:
  Chuyển trạng thái thấp lên trạng thái cao.

* Cạnh rơi:
  Chuyển trạng thái cao về trạng thái thấp.

* Cả hai cạnh:
  Bất kỳ sự chuyển đổi trạng thái nào.

Bộ đếm được định nghĩa là một tập hợp các tín hiệu đầu vào liên quan đến số đếm
dữ liệu được tạo ra bằng cách đánh giá trạng thái của các thiết bị liên quan
tín hiệu đầu vào như được xác định bởi các hàm đếm tương ứng. Trong vòng
ngữ cảnh của giao diện Bộ đếm chung, bộ đếm bao gồm Đếm
mỗi tín hiệu được liên kết với một tập hợp Tín hiệu, có Synapse tương ứng
các trường hợp thể hiện các điều kiện cập nhật hàm đếm cho
số đếm liên quan.

Synapse liên kết một Tín hiệu với một Đếm.

COUNT
-----
Số lượng thể hiện sự tích lũy các tác động của kết nối
Các khớp thần kinh; tức là dữ liệu đếm cho một bộ Tín hiệu. Chung chung
Giao diện bộ đếm biểu thị dữ liệu đếm dưới dạng số tự nhiên.

Đếm có chế độ chức năng đếm thể hiện hành vi cập nhật
cho dữ liệu đếm. Giao diện Bộ đếm chung cung cấp những thông tin sau
Các chế độ chức năng đếm có sẵn:

* Tăng:
  Số lượng tích lũy được tăng lên.

* Giảm:
  Số lượng tích lũy được giảm đi.

* Hướng xung:
  Cạnh tăng trên tín hiệu A cập nhật số đếm tương ứng. Mức đầu vào
  của tín hiệu B xác định hướng.

* Cầu phương:
  Một cặp tín hiệu mã hóa cầu phương được đánh giá để xác định
  vị trí và hướng. Các chế độ Quadrature sau đây có sẵn:

- x1A:
    Nếu hướng thuận, các cạnh tăng trên cặp cầu phương A
    cập nhật số lượng tương ứng; nếu hướng lùi lại, rơi xuống
    các cạnh trên cặp cầu phương tín hiệu A cập nhật số đếm tương ứng.
    Mã hóa cầu phương xác định hướng.

- x1B:
    Nếu hướng thuận, cạnh tăng trên cặp cầu phương B
    cập nhật số lượng tương ứng; nếu hướng lùi lại, rơi xuống
    các cạnh trên cặp cầu phương tín hiệu B cập nhật số lượng tương ứng.
    Mã hóa cầu phương xác định hướng.

- x2A:
    Bất kỳ sự chuyển đổi trạng thái nào trên tín hiệu cặp cầu phương A đều cập nhật
    số lượng tương ứng. Mã hóa cầu phương xác định hướng.

- x2B:
    Bất kỳ sự chuyển đổi trạng thái nào trên tín hiệu cặp cầu phương B đều cập nhật
    số lượng tương ứng. Mã hóa cầu phương xác định hướng.

- x4:
    Bất kỳ sự chuyển đổi trạng thái nào trên các tín hiệu cặp cầu phương sẽ cập nhật
    số lượng tương ứng. Mã hóa cầu phương xác định hướng.

Một Count có một tập hợp một hoặc nhiều Synapse được liên kết.

mô hình
========

Thiết bị đếm cơ bản nhất có thể được biểu diễn dưới dạng một Đếm đơn lẻ
được liên kết với một Tín hiệu thông qua một Synapse duy nhất. Lấy ví dụ
một thiết bị đếm chỉ đơn giản là tích lũy số cạnh tăng trên một
dòng đầu vào nguồn::

Đếm tín hiệu khớp thần kinh
                ----- ------- ------
        +----------------------+
        ZZ0000ZZ Cạnh tăng ________
        ZZ0001ZZ <------------- / Nguồn \
        ZZ0002ZZ ____________
        +----------------------+

Trong ví dụ này, Tín hiệu là đường đầu vào nguồn có xung
điện áp, trong khi Đếm là giá trị đếm liên tục được lặp đi lặp lại
tăng lên. Tín hiệu được liên kết với Số lượng tương ứng thông qua một
Khớp thần kinh. Chức năng tăng được kích hoạt bởi điều kiện dữ liệu Tín hiệu
được chỉ định bởi Synapse -- trong trường hợp này là điều kiện cạnh lên trên
đường dây điện áp đầu vào. Tóm lại, sự tồn tại của thiết bị đếm và
hành vi được thể hiện một cách khéo léo bằng Đếm, Tín hiệu và Khớp thần kinh tương ứng
các thành phần: điều kiện cạnh tăng sẽ kích hoạt chức năng tăng trên một
dữ liệu đếm tích lũy.

Thiết bị đếm không bị giới hạn ở một Tín hiệu duy nhất; trên thực tế, trên lý thuyết
nhiều Tín hiệu có thể được liên kết với ngay cả một Số lượng duy nhất. Ví dụ, một
thiết bị đếm bộ mã hóa cầu phương có thể theo dõi vị trí dựa trên
trạng thái của hai dòng đầu vào::

Đếm tín hiệu khớp thần kinh
                   ----- ------- ------
        +-----------------+
        ZZ0000ZZ Cả hai cạnh ___
        ZZ0001ZZ <------------- / A \
        ZZ0002ZZ _______
        ZZ0003ZZ
        ZZ0004ZZ Cả hai cạnh ___
        ZZ0005ZZ <------------- / B \
        ZZ0006ZZ _______
        +-----------------+

Trong ví dụ này, hai Tín hiệu (dòng mã hóa cầu phương A và B) là
được liên kết với một Đếm duy nhất: cạnh tăng hoặc giảm trên A hoặc
B kích hoạt chức năng "Quadrature x4" xác định hướng
chuyển động và cập nhật dữ liệu vị trí tương ứng. "Hình vuông
chức năng x4" có thể được triển khai trong phần cứng của cầu phương
thiết bị đếm mã hóa; Đếm, Tín hiệu và Khớp thần kinh chỉ đơn giản là
đại diện cho hành vi và chức năng phần cứng này.

Các tín hiệu được liên kết với cùng một Đếm có thể có hành động Synapse khác nhau
điều kiện chế độ. Ví dụ: thiết bị đếm bộ mã hóa cầu phương
hoạt động ở chế độ Hướng xung không vuông góc có thể có một đầu vào
đường dành riêng cho chuyển động và đường đầu vào thứ hai dành riêng cho
hướng::

Đếm tín hiệu khớp thần kinh
                   ----- ------- ------
        +---------------------------+
        ZZ0000ZZ Cạnh tăng ___
        ZZ0001ZZ <------------- / A\ (Chuyển động)
        ZZ0002ZZ _______
        ZZ0003ZZ
        ZZ0004ZZ Không có ___
        ZZ0005ZZ <------------- / B \ (Hướng)
        ZZ0006ZZ _______
        +---------------------------+

Chỉ Tín hiệu A kích hoạt chức năng cập nhật "Pulse-Direction", nhưng
trạng thái tức thời của Tín hiệu B vẫn cần thiết để biết
hướng để dữ liệu vị trí có thể được cập nhật chính xác. Cuối cùng,
cả hai Tín hiệu đều được liên kết với cùng một Đếm thông qua hai tín hiệu tương ứng
Các khớp thần kinh, nhưng chỉ có một khớp thần kinh có điều kiện chế độ hoạt động hoạt động
kích hoạt chức năng đếm tương ứng trong khi chức năng còn lại chỉ còn lại một
Chế độ hành động có điều kiện "Không" để biểu thị Tín hiệu tương ứng của nó
sẵn có để đánh giá trạng thái mặc dù chế độ không kích hoạt của nó.

Hãy nhớ rằng Tín hiệu, Khớp thần kinh và Đếm là trừu tượng
các đại diện không cần phải kết hợp chặt chẽ với chúng
nguồn vật lý tương ứng. Điều này cho phép người sử dụng bộ đếm
tách mình khỏi các sắc thái của các thành phần vật chất (chẳng hạn như
cho dù dòng đầu vào là vi sai hay một đầu cuối) và thay vào đó hãy tập trung
dựa trên ý tưởng cốt lõi về dữ liệu và quy trình thể hiện điều gì (ví dụ: vị trí
như được giải thích từ dữ liệu mã hóa cầu phương).

Trình điều khiển API
==========

Tác giả trình điều khiển có thể sử dụng giao diện Bộ đếm chung trong mã của họ
bằng cách bao gồm tệp tiêu đề include/linux/counter.h. Tập tin tiêu đề này
cung cấp một số cấu trúc dữ liệu cốt lõi, nguyên mẫu hàm và macro
để xác định một thiết bị đếm.

.. kernel-doc:: include/linux/counter.h
   :internal:

.. kernel-doc:: drivers/counter/counter-core.c
   :export:

.. kernel-doc:: drivers/counter/counter-chrdev.c
   :export:

Triển khai trình điều khiển
=====================

Để hỗ trợ thiết bị đếm, trước tiên trình điều khiển phải phân bổ số lượng sẵn có
Tín hiệu truy cập thông qua cấu trúc counter_signal. Những tín hiệu này nên
được lưu trữ dưới dạng một mảng và được đặt thành thành viên mảng tín hiệu của một
cấu trúc counter_device được phân bổ trước khi Bộ đếm được đăng ký
hệ thống.

Số lượng bộ đếm có thể được phân bổ thông qua cấu trúc counter_count và
các liên kết Tín hiệu truy cập tương ứng (Synapse) được thực hiện thông qua
cấu trúc counter_synapse. Các cấu trúc counter_synapse được liên kết là
được lưu trữ dưới dạng một mảng và được đặt thành thành viên mảng khớp thần kinh của
cấu trúc counter_count tương ứng. Các cấu trúc counter_count này là
được đặt thành thành viên mảng đếm của cấu trúc counter_device được phân bổ
trước khi Bộ đếm được đăng ký vào hệ thống.

Lệnh gọi lại trình điều khiển phải được cung cấp cho cấu trúc counter_device trong
để giao tiếp với thiết bị: đọc và ghi các Tín hiệu khác nhau
và Đếm, cũng như để thiết lập và nhận "chế độ hành động" và "chế độ chức năng" cho
các Synapses và Count khác nhau tương ứng.

Cấu trúc counter_device được phân bổ bằng cách sử dụng counter_alloc() và sau đó
đã đăng ký vào hệ thống bằng cách chuyển nó tới hàm counter_add() và
chưa được đăng ký bằng cách chuyển nó tới hàm counter_unregister. có
các biến thể do thiết bị quản lý của các chức năng này: devm_counter_alloc() và
devm_counter_add().

Cấu trúc struct counter_comp được sử dụng để định nghĩa phần mở rộng của bộ đếm
cho Tín hiệu, Khớp thần kinh và Đếm.

Thành viên "loại" chỉ định loại dữ liệu cấp cao (ví dụ: BOOL,
COUNT_DIRECTION, v.v.) được xử lý bởi tiện ích mở rộng này. "ZZ0000ZZ" và
Sau đó, các thành viên "ZZ0001ZZ" có thể được thiết lập bởi trình điều khiển thiết bị truy cập với
gọi lại để xử lý dữ liệu đó bằng cách sử dụng các kiểu dữ liệu C gốc (ví dụ: u8, u64,
v.v.).

Các macro tiện lợi như ZZ0000ZZ được cung cấp cho
sử dụng bởi các tác giả trình điều khiển. Đặc biệt, các tác giả trình điều khiển dự kiến sẽ sử dụng
các macro được cung cấp cho các thuộc tính hệ thống con Counter tiêu chuẩn theo thứ tự
để duy trì một giao diện nhất quán cho không gian người dùng. Ví dụ, một bộ đếm
trình điều khiển thiết bị có thể xác định một số thuộc tính tiêu chuẩn như vậy ::

struct counter_comp count_ext[] = {
                COUNTER_COMP_DIRECTION(đếm_hướng_đọc),
                COUNTER_COMP_ENABLE(đếm_enable_đọc, đếm_enable_write),
                COUNTER_COMP_CEILING(đếm_trần_đọc, đếm_trần_write),
        };

Điều này làm cho việc xem, thêm và sửa đổi các thuộc tính trở nên đơn giản
được hỗ trợ bởi trình điều khiển này ("hướng", "bật" và "trần") và để
duy trì mã này mà không bị lạc trong mạng lưới các dấu ngoặc nhọn.

Cuộc gọi lại phải phù hợp với loại chức năng dự kiến cho tương ứng
thành phần hoặc phần mở rộng. Các kiểu hàm này được định nghĩa trong cấu trúc
cấu trúc counter_comp dưới dạng liên kết "ZZ0000ZZ" và "ZZ0001ZZ"
các thành viên.

Các nguyên mẫu gọi lại tương ứng cho các tiện ích mở rộng được đề cập trong
ví dụ trước ở trên sẽ là::

int count_direction_read(struct counter_device *counter,
                                 cấu trúc counter_count *đếm,
                                 enum counter_count_direction *hướng);
        int count_enable_read(struct counter_device *counter,
                              struct counter_count *count, u8 *enable);
        int count_enable_write(struct counter_device *counter,
                               struct counter_count *count, kích hoạt u8);
        int count_ceiling_read(struct counter_device *counter,
                               struct counter_count *count, u64 *ceiling);
        int count_ceiling_write(struct counter_device *counter,
                                struct counter_count *count, u64 trần);

Việc xác định loại tiện ích mở rộng cần tạo là vấn đề về phạm vi.

* Phần mở rộng tín hiệu là thuộc tính hiển thị thông tin/điều khiển
  cụ thể cho một Tín hiệu. Những loại thuộc tính này sẽ tồn tại dưới một
  Thư mục của Signal trong sysfs.

Ví dụ: nếu bạn có tính năng đảo ngược cho Tín hiệu, bạn có thể có
  tiện ích mở rộng Tín hiệu có tên là "đảo ngược" bật tắt tính năng đó:
  /sys/bus/counter/devices/counterX/signalY/invert

* Phần mở rộng đếm là các thuộc tính hiển thị thông tin/điều khiển
  cụ thể cho một Đếm. Những loại thuộc tính này sẽ tồn tại dưới một
  Thư mục của Count trong sysfs.

Ví dụ: nếu bạn muốn tạm dừng/bỏ tạm dừng Số lượng cập nhật, bạn
  có thể có tiện ích mở rộng Đếm được gọi là "bật" để bật tắt như sau:
  /sys/bus/counter/devices/counterX/countY/bật

* Tiện ích mở rộng thiết bị là thuộc tính hiển thị thông tin/điều khiển
  không cụ thể cho một Số lượng hoặc Tín hiệu cụ thể. Đây là nơi bạn sẽ
  đặt các tính năng chung của bạn hoặc chức năng linh tinh khác.

Ví dụ: nếu thiết bị của bạn có cảm biến quá nhiệt, bạn có thể báo cáo
  chip quá nóng thông qua tiện ích mở rộng thiết bị có tên "error_overtemp":
  /sys/bus/counter/devices/counterX/error_overtemp

Kiến trúc hệ thống con
======================

Trình điều khiển bộ đếm truyền và lấy dữ liệu nguyên bản (ví dụ ZZ0000ZZ, ZZ0001ZZ, v.v.)
và mô-đun bộ đếm dùng chung xử lý việc dịch giữa các sysfs
giao diện. Điều này đảm bảo một giao diện không gian người dùng chuẩn cho tất cả
trình điều khiển bộ đếm và kích hoạt giao diện chrdev của Bộ đếm chung thông qua
trình điều khiển thiết bị tổng quát ABI.

Chế độ xem cấp cao về cách giá trị đếm được truyền xuống từ bộ đếm
trình điều khiển được minh họa bằng cách sau đây. Cuộc gọi lại của trình điều khiển là đầu tiên
đã đăng ký với thành phần lõi của Bộ đếm để Bộ đếm sử dụng
các thành phần giao diện không gian người dùng::

Đăng ký gọi lại tài xế:
        ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
                        +-----------------------------+
                        ZZ0000ZZ
                        +-----------------------------+
                        ZZ0001ZZ
                        +-----------------------------+
                                |
                         -------------------
                        / gọi lại tài xế /
                        -------------------
                                |
                                V.
                        +----------------------+
                        ZZ0002ZZ
                        +----------------------+
                        ZZ0003ZZ
                        ZZ0004ZZ
                        ZZ0005ZZ
                        +----------------------+
                                |
                         -------------------
                        / gọi lại tài xế /
                        -------------------
                                |
                +--------------+--------------+
                ZZ0006ZZ
                V V
        +----------------------+ +----------------------+
        ZZ0007ZZ ZZ0008ZZ
        +----------------------+ +----------------------+
        ZZ0009ZZ ZZ0010ZZ
        ZZ0011ZZ ZZ0012ZZ
        ZZ0013ZZ ZZ0014ZZ
        +----------------------+ +----------------------+

Sau đó, dữ liệu có thể được truyền trực tiếp giữa các thiết bị Counter
Giao diện không gian người dùng của trình điều khiển và bộ đếm::

Đếm yêu cầu dữ liệu:
        ~~~~~~~~~~~~~~~~~~~~
                         ----------------------
                        / Thiết bị đếm \
                        +----------------------+
                        ZZ0001ZZ
                        +----------------------+
                                |
                         ------------------
                        / dữ liệu đếm thô /
                        ------------------
                                |
                                V.
                        +-----------------------------+
                        ZZ0002ZZ
                        +-----------------------------+
                        ZZ0003ZZ
                        ZZ0004ZZ
                        ZZ0005ZZ
                        ZZ0006ZZ
                        +-----------------------------+
                                |
                         ----------
                        /u64 /
                        ----------
                                |
                +--------------+--------------+
                ZZ0007ZZ
                V V
        +----------------------+ +----------------------+
        ZZ0008ZZ ZZ0009ZZ
        +----------------------+ +----------------------+
        ZZ0010ZZ ZZ0011ZZ
        ZZ0012ZZ ZZ0013ZZ
        ZZ0014ZZ ZZ0015ZZ
        ZZ0016ZZ ZZ0017ZZ
        ZZ0018ZZ ZZ0019ZZ
        ZZ0020ZZ ZZ0021ZZ
        +----------------------+ +----------------------+
                ZZ0022ZZ
         --------------- --------------
        / const char * / / struct counter_event /
        --------------- --------------
                ZZ0023ZZ
                |                               V.
                |                       +----------+
                ZZ0024ZZ đọc |
                |                       +----------+
                |                       \ Đếm: 42 /
                |                        -----------
                |
                V.
        +---------------------------------------------------+
        ZZ0025ZZ
        +---------------------------------------------------+
        \ Đếm: "42" /
         --------------------------------------------------

Có bốn thành phần chính liên quan:

Trình điều khiển thiết bị đếm
---------------------
Giao tiếp với thiết bị phần cứng để đọc/ghi dữ liệu; ví dụ. quầy tính tiền
trình điều khiển cho bộ mã hóa cầu phương, bộ hẹn giờ, v.v.

lõi truy cập
------------
Đăng ký trình điều khiển thiết bị truy cập vào hệ thống để tương ứng
cuộc gọi lại được gọi trong quá trình tương tác không gian người dùng.

Hệ thống truy cập
-------------
Dịch dữ liệu bộ đếm sang định dạng giao diện Counter sysfs tiêu chuẩn
và ngược lại.

Vui lòng tham khảo tệp Tài liệu/ABI/testing/sysfs-bus-counter
để biết thông tin chi tiết về giao diện Bộ đếm chung có sẵn
thuộc tính sysfs.

truy cập chrdev
--------------
Dịch các sự kiện của Bộ đếm sang thiết bị ký tự Bộ đếm tiêu chuẩn; dữ liệu
được truyền qua lệnh gọi đọc thiết bị ký tự tiêu chuẩn, trong khi Counter
các sự kiện được cấu hình thông qua các cuộc gọi ioctl.

Giao diện hệ thống
===============

Một số thuộc tính sysfs được tạo bởi giao diện Bộ đếm chung,
và nằm trong thư mục ZZ0000ZZ,
trong đó ZZ0001ZZ là id thiết bị truy cập tương ứng. Xin vui lòng xem
Tài liệu/ABI/testing/sysfs-bus-counter để biết thông tin chi tiết
trên mỗi thuộc tính sysfs của giao diện Bộ đếm chung.

Thông qua các thuộc tính sysfs này, các chương trình và tập lệnh có thể tương tác với
Số lượng, tín hiệu và khớp thần kinh của mô hình bộ đếm chung tương ứng
thiết bị đếm.

Thiết bị nhân vật truy cập
========================

Các nút thiết bị ký tự bộ đếm được tạo trong thư mục ZZ0000ZZ
là ZZ0001ZZ, trong đó ZZ0002ZZ là id thiết bị đếm tương ứng.
Các định nghĩa cho các kiểu dữ liệu Bộ đếm tiêu chuẩn được hiển thị thông qua
không gian người dùng tập tin ZZ0003ZZ.

Sự kiện truy cập
--------------
Trình điều khiển thiết bị bộ đếm có thể hỗ trợ các sự kiện Bộ đếm bằng cách sử dụng
Chức năng ZZ0000ZZ::

void counter_push_event(struct counter_device *const counter, sự kiện const u8,
                                kênh const u8);

Id sự kiện được chỉ định bởi tham số ZZ0000ZZ; kênh sự kiện
id được chỉ định bởi tham số ZZ0001ZZ. Khi chức năng này được
được gọi, dữ liệu Bộ đếm liên quan đến sự kiện tương ứng là
được thu thập và ZZ0002ZZ được tạo cho mỗi mốc thời gian và
được đẩy vào không gian người dùng.

Người dùng có thể định cấu hình các sự kiện của bộ đếm để báo cáo các sự kiện Bộ đếm khác nhau
dữ liệu quan tâm. Điều này có thể được khái niệm hóa như một danh sách các Counter
lệnh đọc thành phần để thực hiện. Ví dụ:

+------------------------+--------------------------+
        ZZ0000ZZ COUNTER_EVENT_INDEX |
        +==============================================================================================================
        ZZ0001ZZ Kênh 0 |
        +------------------------+--------------------------+
        ZZ0002ZZ * Tín hiệu 0 |
        ZZ0003ZZ * Tín hiệu 0 Phần mở rộng 0 |
        ZZ0004ZZ * Phần mở rộng 4 |
        | * Đếm 4 Phần mở rộng 2 +---------------+
        ZZ0005ZZ Kênh 1 |
        |                        +---------------+
        ZZ0006ZZ * Tín hiệu 4 |
        ZZ0007ZZ * Tín hiệu 4 mở rộng 0 |
        ZZ0008ZZ * Đếm 7 |
        +------------------------+--------------------------+

Khi ZZ0000ZZ được gọi
ví dụ: nó sẽ đi xuống danh sách dành cho ZZ0001ZZ
kênh sự kiện 1 và thực hiện lệnh gọi lại đọc cho Tín hiệu 4, Tín hiệu 4
Phần mở rộng 0 và Đếm 7 -- dữ liệu được trả về cho mỗi phần được đẩy tới một
kfifo dưới dạng ZZ0002ZZ, không gian người dùng có thể truy xuất thông qua
thao tác đọc tiêu chuẩn trên nút thiết bị ký tự tương ứng.

Không gian người dùng
---------
Các ứng dụng không gian người dùng có thể định cấu hình các sự kiện Bộ đếm thông qua các hoạt động ioctl
trên nút thiết bị ký tự Counter. Có mã ioctl sau đây là
được hỗ trợ và cung cấp bởi tệp tiêu đề không gian người dùng ZZ0000ZZ:

* ZZ0000ZZ

* ZZ0000ZZ

* ZZ0000ZZ

Để định cấu hình các sự kiện nhằm thu thập dữ liệu Bộ đếm, trước tiên người dùng phải điền một
ZZ0000ZZ với id sự kiện liên quan, id kênh sự kiện,
và thông tin về thành phần Bộ đếm mong muốn để từ đó
đọc và sau đó chuyển nó qua ZZ0001ZZ ioctl
lệnh.

Lưu ý rằng có thể theo dõi một sự kiện mà không cần thu thập dữ liệu Bộ đếm bằng cách
thiết lập thành viên ZZ0000ZZ bằng
ZZ0001ZZ. Với cấu hình này, Bộ đếm
thiết bị ký tự sẽ chỉ điền dấu thời gian sự kiện cho những
phần tử ZZ0002ZZ tương ứng và bỏ qua thành phần
giá trị.

Lệnh ZZ0000ZZ sẽ đệm các Bộ đếm này
đồng hồ. Khi sẵn sàng, lệnh ZZ0001ZZ ioctl
có thể được sử dụng để kích hoạt những chiếc đồng hồ Counter này.

Sau đó, các ứng dụng không gian người dùng có thể thực thi thao tác ZZ0000ZZ (tùy chọn
gọi ZZ0001ZZ trước) trên nút thiết bị ký tự Counter để truy xuất
Các phần tử ZZ0002ZZ với dữ liệu mong muốn.