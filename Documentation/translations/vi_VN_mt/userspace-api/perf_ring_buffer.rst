.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/perf_ring_buffer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Bộ đệm vòng hoàn hảo
================

.. CONTENTS

    1. Introduction

    2. Ring buffer implementation
    2.1  Basic algorithm
    2.2  Ring buffer for different tracing modes
    2.2.1       Default mode
    2.2.2       Per-thread mode
    2.2.3       Per-CPU mode
    2.2.4       System wide mode
    2.3  Accessing buffer
    2.3.1       Producer-consumer model
    2.3.2       Properties of the ring buffers
    2.3.3       Writing samples into buffer
    2.3.4       Reading samples from buffer
    2.3.5       Memory synchronization

    3. The mechanism of AUX ring buffer
    3.1  The relationship between AUX and regular ring buffers
    3.2  AUX events
    3.3  Snapshot mode


1. Giới thiệu
===============

Bộ đệm vòng là một cơ chế cơ bản để truyền dữ liệu.  công dụng hoàn hảo
bộ đệm vòng để truyền dữ liệu sự kiện từ kernel sang không gian người dùng, một bộ đệm khác
loại bộ đệm vòng còn được gọi là bộ đệm vòng phụ (AUX)
đóng vai trò quan trọng trong việc truy tìm phần cứng với Intel PT, Arm
CoreSight, v.v.

Việc triển khai bộ đệm vòng là rất quan trọng nhưng nó cũng rất quan trọng.
công việc đầy thử thách.  Một mặt, công cụ kernel và perf trong người dùng
space sử dụng bộ đệm vòng để trao đổi dữ liệu và lưu trữ dữ liệu vào dữ liệu
tập tin, do đó bộ đệm vòng cần truyền dữ liệu với thông lượng cao;
mặt khác, việc quản lý bộ đệm vòng sẽ tránh được đáng kể
quá tải để đánh lạc hướng kết quả hồ sơ.

Tài liệu này đi sâu vào chi tiết về bộ đệm vòng hoàn hảo với hai
các phần: đầu tiên nó giải thích cách triển khai bộ đệm vòng hoàn hảo, sau đó là phần
phần thứ hai thảo luận về cơ chế đệm vòng AUX.

2. Triển khai bộ đệm vòng
=============================

2.1 Thuật toán cơ bản
-------------------

Điều đó nói rằng, một bộ đệm vòng điển hình được quản lý bởi một con trỏ đầu và một con trỏ đuôi
con trỏ; con trỏ đầu được thao tác bởi người viết và con trỏ đuôi
con trỏ được cập nhật bởi người đọc tương ứng.

::

+---------------------------+
        ZZ0003ZZ ZZ0004ZZ***ZZ0005ZZ |
        +---------------------------+
                ZZ0000ZZ-> Đầu

* : dữ liệu do người viết điền.

Hình 1. Bộ đệm vòng

Perf sử dụng cách tương tự để quản lý bộ đệm vòng của nó.  Trong việc thực hiện
có hai cấu trúc dữ liệu quan trọng được tổ chức cùng nhau trong một tập hợp liên tiếp
các trang, cấu trúc điều khiển và sau đó là bộ đệm vòng.  trang
với cấu trúc điều khiển được gọi là "trang người dùng".  Đang bị giữ
trong các địa chỉ ảo liên tục giúp đơn giản hóa việc định vị bộ đệm vòng
địa chỉ, nó nằm ở các trang sau trang có trang người dùng.

Cấu trúc điều khiển được đặt tên là ZZ0001ZZ, nó chứa một
con trỏ đầu ZZ0002ZZ và con trỏ đuôi ZZ0003ZZ.  Khi
kernel bắt đầu điền các bản ghi vào bộ đệm vòng, nó cập nhật phần đầu
con trỏ để dự trữ bộ nhớ để sau này nó có thể lưu trữ các sự kiện một cách an toàn vào
bộ đệm.  Mặt khác, khi trang người dùng là một bản đồ có thể ghi được,
công cụ hoàn hảo có quyền cập nhật con trỏ đuôi sau khi sử dụng
dữ liệu từ bộ đệm vòng.  Một trường hợp khác là dành cho trang người dùng
ánh xạ chỉ đọc, sẽ được giải quyết trong phần
ZZ0000ZZ.

::

bộ đệm vòng trang người dùng
    +----------+----------+ +---------------------------------------+
    |data_head|data_tail|...| ZZ0007ZZZZ0003ZZZZ0008ZZ***ZZ0009ZZ ZZ0010ZZ
    +----------+----------+ +---------------------------------------+
        ZZ0000ZZ----------------^ ^
         `----------------------------------------------|

* : dữ liệu do người viết điền.

Hình 2. Bộ đệm vòng hoàn hảo

Khi sử dụng công cụ ZZ0000ZZ, chúng ta có thể chỉ định kích thước bộ đệm vòng
với tùy chọn ZZ0001ZZ hoặc ZZ0002ZZ, kích thước đã cho sẽ được làm tròn lên
lũy thừa của hai là bội số của kích thước trang.  Mặc dù hạt nhân
phân bổ cùng một lúc cho tất cả các trang bộ nhớ, nó được hoãn lại để ánh xạ các trang
đến khu vực VMA cho đến khi công cụ hoàn hảo truy cập vào bộ đệm từ không gian người dùng.
Nói cách khác, ở lần đầu tiên truy cập trang bộ đệm từ người dùng
khoảng trống trong công cụ hoàn hảo, ngoại lệ hủy bỏ dữ liệu đối với lỗi trang sẽ được lấy
và kernel tận dụng cơ hội này để ánh xạ trang vào tiến trình VMA
(xem ZZ0003ZZ), do đó công cụ hoàn thiện có thể tiếp tục truy cập
trang sau khi trở về từ ngoại lệ.

2.2 Bộ đệm vòng cho các chế độ theo dõi khác nhau
-------------------------------------------

Các chương trình cấu hình hoàn hảo với các chế độ khác nhau: chế độ mặc định, trên mỗi luồng
chế độ, mỗi chế độ CPU và chế độ toàn hệ thống.  Phần này mô tả những
các chế độ và cách bộ đệm vòng đáp ứng các yêu cầu đối với chúng.  Cuối cùng chúng tôi
sẽ xem xét các điều kiện cuộc đua do các chế độ này gây ra.

2.2.1 Chế độ mặc định
^^^^^^^^^^^^^^^^^^

Thông thường chúng tôi thực thi lệnh ZZ0000ZZ, sau đó là chương trình định hình
tên, như lệnh dưới đây::

bản ghi hoàn hảo test_program

Lệnh này không chỉ định bất kỳ tùy chọn nào cho CPU và chế độ luồng,
Công cụ hoàn hảo áp dụng chế độ mặc định cho sự kiện hoàn hảo.  Nó ánh xạ tất cả
CPU trong hệ thống và PID của chương trình được định hình trong sự kiện hoàn hảo và
nó kích hoạt chế độ kế thừa trong sự kiện để các tác vụ con kế thừa
các sự kiện.  Do đó, sự kiện hoàn hảo được quy là::

evsel::cpus::map[] = { 0 .. _SC_NPROCESSORS_ONLN-1 }
    evsel::threads::map[] = { pid }
    evsel::attr::inherit = 1

Những sự phân bổ này cuối cùng sẽ được phản ánh trong việc triển khai vòng
bộ đệm.  Như được hiển thị bên dưới, công cụ hoàn hảo phân bổ bộ đệm vòng riêng lẻ
cho mỗi CPU, nhưng nó chỉ kích hoạt các sự kiện cho chương trình được định hình chứ không phải
hơn cho tất cả các chủ đề trong hệ thống.  Chủ đề ZZ0000ZZ đại diện cho
bối cảnh luồng của 'test_program', trong khi ZZ0001ZZ và ZZ0002ZZ không liên quan
các thread trong hệ thống.   Các mẫu hoàn hảo được thu thập độc quyền cho
luồng ZZ0003ZZ và được lưu trong bộ đệm vòng được liên kết với CPU trên
mà luồng ZZ0004ZZ đang chạy.

::

T1 T2 T1
            +----+ +----------+ +------+
    CPU0 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            +----+--------------+-------------+----------+----+-------->
              ZZ0003ZZ
              v v
            +------------------------------------------------------+
            ZZ0004ZZ
            +------------------------------------------------------+

T1
                 +------+
    CPU1 ZZ0000ZZ
            ------+------+--------------------------------------------->
                    |
                    v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+

T1 T3
                                      +----+ +-------+
    CPU2 ZZ0000ZZ ZZ0001ZZ
            -----------------+----+--------+-------+-------->
                                        |
                                        v
            +------------------------------------------------------+
            ZZ0002ZZ
            +------------------------------------------------------+

T1
                       +--------------+
    CPU3 ZZ0000ZZ
            -----------+--------------+------------------------------>
                              |
                              v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+

T1: Sợi 1; T2: Sợi 2; T3: Chủ đề 3
	    x: Thread đang ở trạng thái chạy

Hình 3. Bộ đệm vòng cho chế độ mặc định

2.2.2 Chế độ trên mỗi luồng
^^^^^^^^^^^^^^^^^^^^^

Bằng cách chỉ định tùy chọn ZZ0000ZZ trong lệnh hoàn hảo, ví dụ:

::

bản ghi hoàn hảo --per-thread test_program

Sự kiện hoàn hảo không ánh xạ tới bất kỳ CPU nào và chỉ bị ràng buộc với
quá trình được định hình, do đó, các thuộc tính của sự kiện hoàn hảo là::

evsel::cpus::map[0] = { -1 }
    evsel::threads::map[] = { pid }
    evsel::attr::inherit = 0

Ở chế độ này, một bộ đệm vòng đơn được phân bổ cho luồng được định hình;
nếu luồng được lên lịch trên CPU thì các sự kiện trên CPU đó sẽ
kích hoạt; và nếu luồng được lên lịch từ CPU, các sự kiện trên
CPU sẽ bị vô hiệu hóa.  Khi luồng được di chuyển từ một CPU sang
khác, các sự kiện sẽ bị tắt trên CPU trước đó và được bật
trên CPU tiếp theo tương ứng.

::

T1 T2 T1
            +----+ +----------+ +------+
    CPU0 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            +----+--------------+-------------+----------+----+-------->
              ZZ0003ZZ
              ZZ0004ZZ
              ZZ0005ZZ
    CPU1 |  |xxxxx|                                  |
            --ZZ0008ZZ---------->
              ZZ0009ZZ |
              ZZ0010ZZ T1 T3 |
              ZZ0011ZZ +----+ +---+ |
    CPU2 ZZ0012ZZ ZZ0013ZZ ZZ0014ZZ |
            --ZZ0015ZZ-----------------+------+--------+---+-|---------->
              ZZ0016ZZ ZZ0017ZZ
              ZZ0018ZZ T1 ZZ0019ZZ
              ZZ0020ZZ +--------------+ ZZ0021ZZ
    CPU3 ZZ0022ZZ ZZ0023ZZ ZZ0024ZZ
            --ZZ0025ZZ--+--------------+-ZZ0026ZZ---------->
              ZZ0027ZZ ZZ0028ZZ |
              v v v v v
            +------------------------------------------------------+
            ZZ0029ZZ
            +------------------------------------------------------+

T1: Chủ đề 1
            x: Thread đang ở trạng thái chạy

Hình 4. Bộ đệm vòng cho chế độ mỗi luồng

Khi perf chạy ở chế độ mỗi luồng, bộ đệm vòng được phân bổ cho
chủ đề định hình ZZ0000ZZ.  Bộ đệm vòng được dành riêng cho luồng ZZ0001ZZ, nếu
thread ZZ0002ZZ đang chạy, các sự kiện biểu diễn sẽ được ghi vào vòng
đệm; khi luồng đang ngủ, tất cả các sự kiện liên quan sẽ được
bị vô hiệu hóa, do đó sẽ không có dữ liệu theo dõi nào được ghi vào bộ đệm vòng.

2.2.3 Chế độ Per-CPU
^^^^^^^^^^^^^^^^^^

Tùy chọn ZZ0000ZZ được sử dụng để thu thập các mẫu trong danh sách CPU, dành cho
ví dụ lệnh hoàn hảo bên dưới nhận tùy chọn ZZ0001ZZ::

bản ghi hoàn hảo -C 0,2 test_program

Nó ánh xạ sự kiện hoàn hảo tới CPU 0 và 2 và sự kiện này không liên quan đến bất kỳ sự kiện nào.
PID.  Do đó, các thuộc tính sự kiện hoàn hảo được đặt là::

evsel::cpus::map[0] = { 0, 2 }
    evsel::threads::map[] = { -1 }
    evsel::attr::inherit = 0

Điều này dẫn đến phiên ZZ0000ZZ sẽ lấy mẫu tất cả các chủ đề trên CPU0
và CPU2 và bị chấm dứt cho đến khi thoát test_program.  Thậm chí còn có nhiệm vụ
chạy trên CPU1 và CPU3, vì chúng không có bộ đệm vòng cho chúng, bất kỳ
các hoạt động trên hai CPU này sẽ bị bỏ qua.  Trường hợp sử dụng là kết hợp
các tùy chọn cho chế độ trên mỗi luồng và chế độ trên mỗi CPU, ví dụ: các tùy chọn ZZ0001ZZ và
ZZ0002ZZ được chỉ định cùng nhau, các mẫu chỉ được ghi lại khi
luồng được định hình được lên lịch trên bất kỳ CPU nào được liệt kê.

::

T1 T2 T1
            +----+ +----------+ +------+
    CPU0 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            +----+--------------+-------------+----------+----+-------->
              ZZ0003ZZ |
              v v v
            +------------------------------------------------------+
            ZZ0004ZZ
            +------------------------------------------------------+

T1
                 +------+
    CPU1 ZZ0000ZZ
            ------+------+--------------------------------------------->

T1 T3
                                      +----+ +-------+
    CPU2 ZZ0000ZZ ZZ0001ZZ
            -----------------+----+--------+-------+-------->
                                        ZZ0002ZZ
                                        v v
            +------------------------------------------------------+
            ZZ0003ZZ
            +------------------------------------------------------+

T1
                       +--------------+
    CPU3 ZZ0000ZZ
            -----------+--------------+------------------------------>

T1: Sợi 1; T2: Sợi 2; T3: Chủ đề 3
            x: Thread đang ở trạng thái chạy

Hình 5. Bộ đệm vòng cho chế độ per-CPU

2.2.4 Chế độ toàn hệ thống
^^^^^^^^^^^^^^^^^^^^^^

Bằng cách sử dụng tùy chọn ZZ0000ZZ hoặc ZZ0001ZZ, Perf sẽ thu thập các mẫu trên tất cả các CPU
đối với tất cả các tác vụ, chúng tôi gọi nó là chế độ toàn hệ thống, lệnh là::

bản ghi hoàn hảo -a test_program

Tương tự như chế độ per-CPU, sự kiện hoàn hảo không liên kết với bất kỳ PID nào và
nó ánh xạ tới tất cả các CPU trong hệ thống ::

evsel::cpus::map[] = { 0 .. _SC_NPROCESSORS_ONLN-1 }
   evsel::threads::map[] = { -1 }
   evsel::attr::inherit = 0

Ở chế độ toàn hệ thống, mỗi CPU đều có bộ đệm vòng riêng, tất cả các luồng
được theo dõi trong trạng thái chạy và các mẫu được ghi vào
bộ đệm vòng thuộc về CPU nơi xảy ra sự kiện.

::

T1 T2 T1
            +----+ +----------+ +------+
    CPU0 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            +----+--------------+-------------+----------+----+-------->
              ZZ0003ZZ |
              v v v
            +------------------------------------------------------+
            ZZ0004ZZ
            +------------------------------------------------------+

T1
                 +------+
    CPU1 ZZ0000ZZ
            ------+------+--------------------------------------------->
                    |
                    v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+

T1 T3
                                      +----+ +-------+
    CPU2 ZZ0000ZZ ZZ0001ZZ
            -----------------+----+--------+-------+-------->
                                        ZZ0002ZZ
                                        v v
            +------------------------------------------------------+
            ZZ0003ZZ
            +------------------------------------------------------+

T1
                       +--------------+
    CPU3 ZZ0000ZZ
            -----------+--------------+------------------------------>
                              |
                              v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+

T1: Sợi 1; T2: Sợi 2; T3: Chủ đề 3
            x: Thread đang ở trạng thái chạy

Hình 6. Bộ đệm vòng cho chế độ toàn hệ thống

2.3 Truy cập bộ đệm
--------------------

Dựa trên sự hiểu biết về cách phân bổ bộ đệm vòng trong
chế độ khác nhau, phần này giải thích cách truy cập bộ đệm vòng.

2.3.1 Mô hình sản xuất-tiêu dùng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong nhân Linux, các sự kiện PMU có thể tạo ra các mẫu được lưu trữ
vào bộ đệm vòng; lệnh hoàn hảo trong không gian người dùng sẽ tiêu tốn
lấy mẫu bằng cách đọc dữ liệu từ bộ đệm vòng và cuối cùng lưu lại
dữ liệu vào tập tin để phân tích bài.  Đó là một nhà sản xuất-người tiêu dùng điển hình
mô hình sử dụng bộ đệm vòng.

Quá trình hoàn hảo thăm dò các sự kiện PMU và ngủ khi không có sự kiện nào
đang đến.  Để ngăn chặn việc trao đổi thường xuyên giữa kernel và người dùng
không gian, lớp lõi sự kiện kernel giới thiệu một hình mờ, đó là
được lưu trữ trong ZZ0000ZZ.  Khi một mẫu được ghi vào
bộ đệm vòng và nếu bộ đệm được sử dụng vượt quá hình mờ,
kernel đánh thức tiến trình hoàn hảo để đọc các mẫu từ bộ đệm vòng.

::

hoàn hảo
                       / | Đọc mẫu
             Thăm dò ý kiến / ZZ0000ZZ------------------------^
             ZZ0001ZZ Lưu trữ mẫu
          +-----------------------------+
          ZZ0002ZZ
          +-----------------------------+

* : dữ liệu do người viết điền.

Hình 7. Ghi và đọc bộ đệm vòng

Khi lớp lõi sự kiện kernel thông báo cho không gian người dùng, bởi vì
nhiều sự kiện có thể chia sẻ cùng một bộ đệm vòng để ghi mẫu,
lớp lõi lặp lại mọi sự kiện liên quan đến bộ đệm vòng và
đánh thức các nhiệm vụ đang chờ trên sự kiện.  Điều này được thực hiện bởi kernel
chức năng ZZ0000ZZ.

Sau khi quá trình hoàn hảo được đánh thức, nó bắt đầu kiểm tra bộ đệm vòng
từng cái một, nếu nó tìm thấy bất kỳ bộ đệm vòng nào chứa mẫu, nó sẽ đọc
lấy mẫu để thống kê hoặc lưu vào file dữ liệu.  Cho
Quá trình hoàn hảo có thể chạy trên bất kỳ CPU nào, điều này dẫn đến bộ đệm vòng
có khả năng được truy cập đồng thời từ nhiều CPU, điều này
gây ra tình trạng chủng tộc.  Việc xử lý tình trạng cuộc đua được mô tả trong
phần ZZ0000ZZ.

2.3.2 Thuộc tính của bộ đệm vòng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Nhân Linux hỗ trợ hai hướng ghi cho bộ đệm vòng: chuyển tiếp và
lạc hậu.  Việc viết tiếp sẽ lưu mẫu từ đầu vòng
bộ đệm, việc ghi ngược sẽ lưu trữ dữ liệu từ cuối bộ đệm vòng với
hướng ngược lại.  Công cụ hoàn hảo xác định hướng viết.

Ngoài ra, công cụ này có thể ánh xạ bộ đệm ở chế độ đọc-ghi hoặc chỉ đọc
mode vào không gian người dùng.

Bộ đệm vòng ở chế độ đọc-ghi được ánh xạ với thuộc tính
ZZ0000ZZ.  Với quyền ghi, công cụ hoàn thiện
cập nhật ZZ0001ZZ để cho biết vị trí bắt đầu dữ liệu.  kết hợp
với con trỏ đầu ZZ0002ZZ, hoạt động như vị trí cuối của
dữ liệu hiện tại, công cụ hoàn thiện có thể dễ dàng biết dữ liệu được đọc ở đâu
từ.

Ngoài ra, ở chế độ chỉ đọc, chỉ kernel tiếp tục cập nhật
ZZ0000ZZ trong khi không gian người dùng không thể truy cập ZZ0001ZZ do
đến thuộc tính ánh xạ ZZ0002ZZ.

Kết quả là, ma trận dưới đây minh họa sự kết hợp khác nhau của
đặc điểm định hướng và lập bản đồ.  Công cụ hoàn hảo sử dụng hai trong số này
các kết hợp để hỗ trợ các loại bộ đệm: bộ đệm không ghi đè và bộ đệm
bộ đệm có thể ghi đè.

.. list-table::
   :widths: 1 1 1
   :header-rows: 1

   * - Mapping mode
     - Forward
     - Backward
   * - read-write
     - Non-overwrite ring buffer
     - Not used
   * - read-only
     - Not used
     - Overwritable ring buffer

Bộ đệm vòng không ghi đè sử dụng ánh xạ đọc-ghi với chuyển tiếp
viết.  Nó bắt đầu lưu dữ liệu từ đầu vòng đệm
và quấn quanh khi tràn, được sử dụng với chế độ đọc-ghi trong
bộ đệm vòng thông thường.  Khi người tiêu dùng không theo kịp
nhà sản xuất, nó sẽ mất một số dữ liệu, kernel giữ bao nhiêu bản ghi
bị mất và tạo bản ghi ZZ0000ZZ trong lần tiếp theo
khi nó tìm thấy một khoảng trống trong bộ đệm vòng.

Bộ đệm vòng có thể ghi đè sử dụng cách viết ngược với
chế độ chỉ đọc.  Nó lưu dữ liệu từ cuối vòng đệm và
ZZ0000ZZ giữ vị trí của dữ liệu hiện tại, luôn hoàn hảo
biết nó bắt đầu đọc từ đâu và cho đến khi kết thúc vòng đệm, do đó
nó không cần ZZ0001ZZ.  Ở chế độ này, nó sẽ không tạo ra
Bản ghi ZZ0002ZZ.

.. _writing_samples_into_buffer:

2.3.3 Ghi mẫu vào bộ đệm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi một mẫu được lấy và lưu vào bộ đệm vòng, hạt nhân
chuẩn bị các trường mẫu dựa trên loại mẫu; sau đó nó chuẩn bị
thông tin để ghi bộ đệm vòng được lưu trữ trong cấu trúc
ZZ0000ZZ.  Cuối cùng, kernel xuất mẫu thành
bộ đệm vòng và cập nhật con trỏ đầu trong trang người dùng để
công cụ hoàn hảo có thể thấy giá trị mới nhất.

Cấu trúc ZZ0000ZZ phục vụ như một bối cảnh tạm thời cho
theo dõi các thông tin liên quan đến bộ đệm.  Ưu điểm của nó là
rằng nó cho phép ghi đồng thời vào bộ đệm bởi các sự kiện khác nhau.
Ví dụ: cả sự kiện phần mềm và sự kiện PMU phần cứng đều được bật
để lập hồ sơ, hai phiên bản ZZ0001ZZ đóng vai trò riêng biệt
bối cảnh cho sự kiện phần mềm và sự kiện phần cứng tương ứng.
Điều này cho phép mỗi sự kiện dành riêng không gian bộ nhớ để điền vào
dữ liệu bản ghi.

2.3.4 Đọc mẫu từ bộ đệm
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trong không gian người dùng, công cụ hoàn thiện sử dụng ZZ0000ZZ
cấu trúc để xử lý phần đầu và phần đuôi của bộ đệm.  Nó cũng sử dụng
Cấu trúc ZZ0001ZZ để theo dõi ngữ cảnh cho bộ đệm vòng, điều này
bối cảnh bao gồm thông tin về sự bắt đầu và kết thúc của bộ đệm
địa chỉ.  Ngoài ra, giá trị mặt nạ có thể được sử dụng để tính toán
con trỏ đệm tròn ngay cả khi bị tràn.

Tương tự như kernel, công cụ perf trong không gian người dùng trước tiên sẽ đọc ra
dữ liệu được ghi từ bộ đệm vòng, sau đó cập nhật bộ đệm
con trỏ đuôi ZZ0000ZZ.

.. _memory_synchronization:

2.3.5 Đồng bộ hóa bộ nhớ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các CPU hiện đại với mô hình bộ nhớ thoải mái không thể hứa hẹn về bộ nhớ
đặt hàng, điều này có nghĩa là có thể truy cập vào bộ đệm vòng và
Cấu trúc ZZ0000ZZ không đúng thứ tự.  Để đảm bảo tính chất cụ thể
trình tự để bộ nhớ truy cập bộ đệm vòng hoàn hảo, các rào cản bộ nhớ là
được sử dụng để đảm bảo sự phụ thuộc dữ liệu.  Lý do của bộ nhớ
đồng bộ hóa như sau::

Không gian người dùng hạt nhân

nếu (LOAD ->data_tail) { LOAD ->data_head
                   (A) smp_rmb() (C)
    Dữ liệu $ STORE $Dữ liệu LOAD $
    smp_wmb() (B) smp_mb() (D)
    STORE ->data_head STORE ->data_tail
  }

Các nhận xét trong tools/include/linux/ring_buffer.h đưa ra mô tả hay
về lý do và cách sử dụng các rào cản bộ nhớ, ở đây chúng tôi sẽ chỉ cung cấp một
giải thích thay thế:

(A) là sự phụ thuộc điều khiển để CPU đảm bảo trật tự giữa việc kiểm tra
con trỏ ZZ0000ZZ và điền mẫu vào vòng
đệm;

(D) cặp với (A).  (D) tách việc đọc dữ liệu bộ đệm vòng khỏi
viết con trỏ ZZ0000ZZ, công cụ hoàn hảo trước tiên sẽ sử dụng các mẫu và sau đó
cho hạt nhân biết rằng đoạn dữ liệu đã được giải phóng.  Kể từ khi đọc
theo sau là thao tác ghi, do đó (D) là bộ nhớ đầy
rào cản.

(B) là rào cản viết ở giữa hai thao tác viết, trong đó
đảm bảo rằng việc ghi mẫu phải được thực hiện trước khi cập nhật phần đầu
con trỏ.

(C) cặp với (B).  (C) là rào cản đọc bộ nhớ để đảm bảo đầu
con trỏ được tìm nạp trước khi đọc mẫu.

Để thực hiện thuật toán trên, hàm ZZ0000ZZ
trong kernel và hai trợ giúp ZZ0001ZZ và
ZZ0002ZZ trong không gian người dùng được giới thiệu, họ dựa vào
trên các rào cản bộ nhớ như được mô tả ở trên để đảm bảo sự phụ thuộc vào dữ liệu.

Một số kiến trúc hỗ trợ rào cản thấm một chiều với tải thu được
và hoạt động phát hành tại cửa hàng, những rào cản này được thoải mái hơn với ít chi phí hơn
phạt hiệu suất, vì vậy (C) và (D) có thể được tối ưu hóa để sử dụng các rào cản
ZZ0000ZZ và ZZ0001ZZ tương ứng.

Nếu một kiến trúc không hỗ trợ thu nhận tải và giải phóng cửa hàng trong
mô hình bộ nhớ, nó sẽ quay trở lại kiểu rào cản bộ nhớ cũ
hoạt động.  Trong trường hợp này, ZZ0000ZZ đóng gói
ZZ0001ZZ + ZZ0002ZZ, vì ZZ0003ZZ đắt tiền,
ZZ0004ZZ không gọi ZZ0005ZZ và nó sử dụng
thay vào đó là các rào cản ZZ0006ZZ + ZZ0007ZZ.

3. Cơ chế của bộ đệm vòng AUX
===================================

Trong chương này, chúng tôi sẽ giải thích cách triển khai vòng AUX
bộ đệm.  Phần đầu tiên sẽ thảo luận về mối liên hệ giữa
Bộ đệm vòng AUX và bộ đệm vòng thông thường, sau đó phần thứ hai sẽ
kiểm tra cách bộ đệm vòng AUX phối hợp hoạt động với bộ đệm vòng thông thường,
cũng như các tính năng bổ sung được giới thiệu bởi bộ đệm vòng AUX cho
cơ chế lấy mẫu

3.1 Mối quan hệ giữa AUX và bộ đệm vòng thông thường
---------------------------------------------------------

Nói chung, bộ đệm vòng AUX là bộ đệm phụ trợ cho vòng thông thường
bộ đệm.  Bộ đệm vòng thông thường chủ yếu được sử dụng để lưu trữ sự kiện
mẫu và mọi định dạng sự kiện đều tuân thủ định nghĩa trong
công đoàn ZZ0000ZZ; bộ đệm vòng AUX dùng để ghi lại phần cứng
dữ liệu theo dõi và định dạng dữ liệu theo dõi phụ thuộc vào IP phần cứng.

Công dụng và ưu điểm chung của bộ đệm vòng AUX là nó
được viết trực tiếp bằng phần cứng chứ không phải bằng kernel.  Ví dụ,
các mẫu hồ sơ thông thường ghi vào bộ đệm vòng thông thường gây ra
ngắt lời.  Việc thực hiện truy tìm đòi hỏi số lượng mẫu lớn và
sử dụng các ngắt sẽ quá sức đối với bộ đệm vòng thông thường
cơ chế.  Có bộ đệm AUX cho phép có nhiều vùng bộ nhớ hơn
được tách rời khỏi kernel và được ghi trực tiếp bằng cách theo dõi phần cứng.

Bộ đệm vòng AUX sử dụng lại thuật toán tương tự với vòng thông thường
bộ đệm để quản lý bộ đệm.  Cấu trúc điều khiển
ZZ0000ZZ mở rộng các trường mới ZZ0001ZZ và ZZ0002ZZ
cho các con trỏ đầu và đuôi của bộ đệm vòng AUX.

Trong giai đoạn khởi tạo, bên cạnh vòng thông thường mmap()-ed
đệm, công cụ hoàn hảo sẽ gọi một tòa nhà thứ hai trong
Hàm ZZ0000ZZ cho mmap của bộ đệm AUX với
độ lệch tập tin khác không; ZZ0001ZZ trong kernel phân bổ các trang
tương ứng, các trang này sẽ được hoãn lại để ánh xạ vào VMA khi
xử lý lỗi trang, đó là cơ chế lười biếng tương tự với
bộ đệm vòng thông thường.

Sự kiện AUX và dữ liệu theo dõi AUX là hai thứ khác nhau.  Chúng ta hãy xem một
ví dụ::

bản ghi hoàn hảo -a -e chu kỳ -e cs_etm// -- ngủ 2

Lệnh trên cho phép hai sự kiện: một là sự kiện ZZ0000ZZ từ PMU
và một cái khác là sự kiện AUX ZZ0001ZZ từ Arm CoreSight, cả hai đều được lưu
vào bộ đệm vòng thông thường trong khi dữ liệu theo dõi AUX của CoreSight được
được lưu trữ trong bộ đệm vòng AUX.

Kết quả là chúng ta có thể thấy bộ đệm vòng thông thường và bộ đệm vòng AUX
được phân bổ theo cặp.  Sự hoàn hảo ở chế độ mặc định phân bổ thông thường
bộ đệm vòng và bộ đệm vòng AUX trên mỗi CPU, tương tự như
tuy nhiên, ở chế độ toàn hệ thống, chế độ mặc định chỉ ghi lại các mẫu cho
chương trình được định hình, trong khi cấu hình chế độ sau cho tất cả các chương trình
trong hệ thống.  Đối với chế độ mỗi luồng, công cụ hoàn hảo chỉ phân bổ một
bộ đệm vòng thông thường và một bộ đệm vòng AUX cho toàn bộ phiên.  cho
chế độ per-CPU, perf phân bổ hai loại bộ đệm vòng cho
CPU được chọn được chỉ định bởi tùy chọn ZZ0000ZZ.

Hình dưới đây minh họa cách bố trí bộ đệm trong toàn hệ thống
chế độ; nếu có bất kỳ hoạt động nào trên một CPU, các mẫu sự kiện AUX và
dữ liệu theo dõi phần cứng sẽ được ghi vào bộ đệm chuyên dụng cho
CPU.

::

T1 T2 T1
            +----+ +----------+ +------+
    CPU0 ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
            +----+--------------+-------------+----------+----+-------->
              ZZ0003ZZ |
              v v v
            +------------------------------------------------------+
            ZZ0004ZZ
            +------------------------------------------------------+
              ZZ0005ZZ |
              v v v
            +------------------------------------------------------+
            ZZ0006ZZ
            +------------------------------------------------------+

T1
                 +------+
    CPU1 ZZ0000ZZ
            ------+------+--------------------------------------------->
                    |
                    v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+
                    |
                    v
            +------------------------------------------------------+
            ZZ0002ZZ
            +------------------------------------------------------+

T1 T3
                                      +----+ +-------+
    CPU2 ZZ0000ZZ ZZ0001ZZ
            -----------------+----+--------+-------+-------->
                                        ZZ0002ZZ
                                        v v
            +------------------------------------------------------+
            ZZ0003ZZ
            +------------------------------------------------------+
                                        ZZ0004ZZ
                                        v v
            +------------------------------------------------------+
            ZZ0005ZZ
            +------------------------------------------------------+

T1
                       +--------------+
    CPU3 ZZ0000ZZ
            -----------+--------------+------------------------------>
                              |
                              v
            +------------------------------------------------------+
            ZZ0001ZZ
            +------------------------------------------------------+
                              |
                              v
            +------------------------------------------------------+
            ZZ0002ZZ
            +------------------------------------------------------+

T1: Sợi 1; T2: Sợi 2; T3: Chủ đề 3
            x: Thread đang ở trạng thái chạy

Hình 8. Bộ đệm vòng AUX cho chế độ toàn hệ thống

3.2 Sự kiện AUX
--------------

Tương tự như ZZ0000ZZ và ZZ0001ZZ hoạt động cho
bộ đệm vòng thông thường, ZZ0002ZZ và ZZ0003ZZ
phục vụ cho bộ đệm vòng AUX để xử lý dữ liệu theo dõi phần cứng.

Khi dữ liệu theo dõi phần cứng được lưu trữ vào bộ đệm vòng AUX, PMU
trình điều khiển sẽ ngừng theo dõi phần cứng bằng cách gọi lại ZZ0001ZZ.
Tương tự như bộ đệm vòng thông thường, bộ đệm vòng AUX cần áp dụng
cơ chế đồng bộ hóa bộ nhớ như đã thảo luận trong phần
ZZ0000ZZ.  Vì bộ đệm vòng AUX được quản lý bởi
Trình điều khiển PMU, rào cản (B), là rào cản viết để đảm bảo dấu vết
dữ liệu được hiển thị bên ngoài trước khi cập nhật con trỏ đầu, được yêu cầu
sẽ được triển khai trong trình điều khiển PMU.

Sau đó ZZ0000ZZ có thể gọi hàm ZZ0001ZZ một cách an toàn để
hoàn thành hai việc:

- Nó điền sự kiện ZZ0000ZZ vào bộ đệm vòng thông thường, điều này
  sự kiện cung cấp thông tin về địa chỉ bắt đầu và kích thước dữ liệu cho một
  đoạn dữ liệu theo dõi phần cứng đã được lưu trữ vào bộ đệm vòng AUX;

- Vì trình điều khiển theo dõi phần cứng đã lưu trữ dữ liệu theo dõi mới vào AUX
  bộ đệm vòng, đối số ZZ0002ZZ cho biết có bao nhiêu byte đã được
  được sử dụng bởi việc theo dõi phần cứng, do đó ZZ0000ZZ cập nhật
  con trỏ tiêu đề ZZ0001ZZ để phản ánh việc sử dụng bộ đệm mới nhất.

Cuối cùng, trình điều khiển PMU sẽ khởi động lại quá trình theo dõi phần cứng.  Trong thời gian này
thời gian tạm dừng tạm thời, nó sẽ mất dữ liệu theo dõi phần cứng, điều này
sẽ gây ra sự gián đoạn trong giai đoạn giải mã.

Sự kiện ZZ0000ZZ trình bày một sự kiện AUX được xử lý trong
kernel, nhưng nó thiếu thông tin để lưu dữ liệu theo dõi AUX trong
tập tin hoàn hảo.  Khi công cụ hoàn hảo sao chép dữ liệu theo dõi từ vòng AUX
đệm vào tệp dữ liệu hoàn hảo, nó tổng hợp ZZ0001ZZ
sự kiện không phải là kernel ABI, nó được xác định bởi công cụ perf để mô tả
phần dữ liệu nào trong bộ đệm vòng AUX được lưu.  Sau đó, sự hoàn hảo
công cụ đọc dữ liệu theo dõi AUX từ tệp perf dựa trên
Sự kiện ZZ0002ZZ và sự kiện ZZ0003ZZ được sử dụng để
giải mã một đoạn dữ liệu bằng cách tương quan với thứ tự thời gian.

3.3 Chế độ chụp nhanh
-----------------

Perf hỗ trợ chế độ chụp nhanh cho bộ đệm vòng AUX, ở chế độ này, người dùng
chỉ ghi lại dữ liệu theo dõi AUX tại một thời điểm cụ thể mà người dùng đang
quan tâm đến. Ví dụ: bên dưới đưa ra ví dụ về cách chụp ảnh nhanh
với khoảng thời gian 1 giây với Arm CoreSight::

bản ghi hoàn hảo -e cs_etm//u -S -a chương trình &
  PERFPID=$!
  trong khi đúng; làm
      giết -USR2 $PERFPID
      ngủ 1
  xong

Luồng chính cho chế độ chụp nhanh là:

- Trước khi chụp ảnh nhanh, bộ đệm vòng AUX hoạt động ở chế độ chạy tự do.
  Trong chế độ chạy tự do, phần hoàn thiện không ghi lại bất kỳ sự kiện AUX nào và
  dữ liệu theo dõi;

- Sau khi công cụ hoàn hảo nhận được tín hiệu ZZ0002ZZ, nó sẽ kích hoạt lệnh gọi lại
  chức năng ZZ0000ZZ để tắt phần cứng
  truy tìm.  Trình điều khiển hạt nhân sau đó sẽ điền vào bộ đệm vòng AUX với
  dữ liệu theo dõi phần cứng và sự kiện ZZ0001ZZ được lưu trữ trong
  bộ đệm vòng thông thường;

- Sau đó công cụ perf sẽ chụp ảnh nhanh, ZZ0000ZZ
  đọc dữ liệu theo dõi phần cứng từ bộ đệm vòng AUX và lưu nó
  vào tệp dữ liệu hoàn hảo;

- Sau khi chụp xong, ZZ0000ZZ
  khởi động lại sự kiện PMU để theo dõi AUX.

Trình hoàn thiện chỉ truy cập vào con trỏ đầu ZZ0000ZZ
ở chế độ chụp nhanh và không chạm vào con trỏ đuôi ZZ0001ZZ, đây là
bởi vì bộ đệm vòng AUX có thể tràn ở chế độ chạy tự do, phần đuôi
con trỏ là vô dụng trong trường hợp này.  Ngoài ra, cuộc gọi lại
ZZ0002ZZ được giới thiệu để đưa ra quyết định
về việc bộ đệm vòng AUX có được bọc xung quanh hay không, tại
cuối cùng nó sửa phần đầu của bộ đệm AUX được sử dụng để tính toán
theo dõi kích thước dữ liệu.

Như chúng ta đã biết, việc triển khai bộ đệm có thể ở chế độ trên mỗi luồng, trên mỗi CPU
hoặc chế độ toàn hệ thống và ảnh chụp nhanh có thể được áp dụng cho bất kỳ chế độ nào
các chế độ này.  Dưới đây là ví dụ về chụp ảnh nhanh trên toàn hệ thống
chế độ.

::

Ảnh chụp nhanh được chụp
                                                 |
                                                 v
                        +---------------+
                        ZZ0000ZZ <- aux_head
                        +---------------+
                                                 v
                +--------------------------------+
                ZZ0001ZZ <- aux_head
                +--------------------------------+
                                                 v
    +---------------------------------------------+
    ZZ0002ZZ <- aux_head
    +---------------------------------------------+
                                                 v
         +---------------------------------------+
         ZZ0003ZZ <- aux_head
         +---------------------------------------+

Hình 9. Ảnh chụp nhanh với chế độ toàn hệ thống