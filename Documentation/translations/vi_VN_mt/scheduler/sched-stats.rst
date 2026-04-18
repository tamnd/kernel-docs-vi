.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

======================
Thống kê lịch trình
====================

Phiên bản 17 của schedstats đã xóa trường 'lb_imbalance' vì nó không có
ý nghĩa nữa và thay vào đó đã thêm các lĩnh vực có liên quan hơn, cụ thể là
'lb_imbalance_load', 'lb_imbalance_util', 'lb_imbalance_task' và
'lb_imbalance_misfit'. Trường miền in tên của
tên miền được lập lịch tương ứng từ phiên bản này trở đi.

Phiên bản 16 của schedstats đã thay đổi thứ tự các định nghĩa trong
'enum cpu_idle_type', đã thay đổi thứ tự của [CPU_MAX_IDLE_TYPES]
các cột trong show_schedstat(). Đặc biệt là vị trí của CPU_IDLE
và __CPU_NOT_IDLE đã đổi chỗ. Kích thước của mảng không thay đổi.

Phiên bản 15 của schedstats đã bỏ bộ đếm đối với một số sched_yield:
yld_exp_empty, yld_act_empty và yld_both_empty. Nếu không thì đó là
giống hệt phiên bản 14. Chi tiết có tại

ZZ0000ZZ

Phiên bản 14 của schedstats bao gồm hỗ trợ cho sched_domains, đã đạt được
kernel chính trong 2.6.20 mặc dù nó giống hệt với số liệu thống kê từ phiên bản
12 có trong kernel từ 2.6.13-2.6.19 (phiên bản 13 chưa bao giờ thấy kernel
phát hành).  Một số bộ đếm có ý nghĩa hơn khi được đặt trên mỗi lần chạy; khác để được
mỗi tên miền.  Lưu ý rằng tên miền (và thông tin liên quan của chúng) sẽ chỉ
thích hợp và có sẵn trên các máy sử dụng CONFIG_SMP.

Trong phiên bản 14 của schedstat, có ít nhất một cấp độ miền
số liệu thống kê cho từng CPU được liệt kê và có thể có nhiều hơn một
miền.  Tên miền không có tên cụ thể trong việc triển khai này, nhưng
cái được đánh số cao nhất thường phân xử sự cân bằng trên tất cả
cpu trên máy, trong khi domain0 là miền được tập trung chặt chẽ nhất,
đôi khi chỉ cân bằng giữa các cặp cpu.  Vào lúc này, có
không có kiến trúc nào cần nhiều hơn ba cấp độ miền. đầu tiên
trường trong thống kê miền là bản đồ bit cho biết CPU nào bị ảnh hưởng
bởi tên miền đó. Thông tin chi tiết có sẵn tại

ZZ0000ZZ

Tài liệu lịch trình được duy trì từ phiên bản 10 trở đi và không
được cập nhật cho phiên bản 11 và 12. Chi tiết về phiên bản 10 có tại

ZZ0000ZZ

Các trường này là bộ đếm và chỉ tăng.  Các chương trình sử dụng
trong số này sẽ cần phải bắt đầu bằng quan sát cơ bản và sau đó tính toán
sự thay đổi của bộ đếm ở mỗi lần quan sát tiếp theo.  Một kịch bản perl
điều này thực hiện được điều này cho nhiều trường có sẵn tại

ZZ0000ZZ

Lưu ý rằng bất kỳ tập lệnh nào như vậy nhất thiết phải có phiên bản cụ thể, vì tập lệnh chính
Lý do thay đổi phiên bản là thay đổi định dạng đầu ra.  Dành cho những ai mong muốn
để viết tập lệnh của riêng mình, các trường được mô tả ở đây.

Thống kê CPU
--------------
CPU<N> 1 2 3 4 5 6 7 8 9

Trường đầu tiên là thống kê sched_yield():

1) # of lần sched_yield() được gọi

Ba phần tiếp theo là số liệu thống kê về lịch trình():

2) Trường này là trường đếm hết hạn mảng kế thừa được sử dụng trong O(1)
	lịch trình. Chúng tôi giữ nó để tương thích với ABI nhưng nó luôn được đặt ở mức 0.
     3) # of lần lịch() được gọi
     4) # of lần lịch() khiến bộ xử lý không hoạt động

Hai số liệu tiếp theo là số liệu thống kê try_to_wake_up():

5) # of lần try_to_wake_up() được gọi
     6) # of lần try_to_wake_up() được gọi để đánh thức CPU cục bộ

Ba số liệu tiếp theo là số liệu thống kê mô tả độ trễ lập kế hoạch:

7) tổng thời gian chạy các tác vụ trên bộ xử lý này (tính bằng nano giây)
     8) tổng thời gian chờ đợi để chạy các tác vụ trên bộ xử lý này (trong
        nano giây)
     9) Các khoảng thời gian # of chạy trên CPU này


Thống kê tên miền
-----------------
Một trong số này được tạo ra trên mỗi miền cho mỗi CPU được mô tả. (Lưu ý rằng nếu
CONFIG_SMP không được xác định, các miền ZZ0000ZZ được sử dụng và các dòng này
sẽ không xuất hiện ở đầu ra.)

tên miền<N> <tên> <cpumask> 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 43 44 45

Trường <name> in tên miền được lập lịch và chỉ được hỗ trợ
với phiên bản schedstat >= 17. Trên các phiên bản trước, <cpumask> là phiên bản đầu tiên
lĩnh vực.

Trường <cpumask> là mặt nạ bit cho biết miền này hoạt động ở CPU nào
kết thúc.

33 tiếp theo là nhiều số liệu thống kê sched_balance_rq() được nhóm thành các loại
của sự nhàn rỗi (bận rộn, nhàn rỗi và mới nhàn rỗi):

1) Số lần # of trong miền này sched_balance_rq() được gọi khi
        CPU đang bận
    2) Đã kiểm tra # of lần trong miền này sched_balance_rq() nhưng đã tìm thấy
        tải không yêu cầu cân bằng khi bận
    3) # of lần trong miền này sched_balance_rq() đã cố gắng di chuyển một hoặc
        nhiều nhiệm vụ hơn và thất bại, khi cpu bận
    4) Tải mất cân bằng hoàn toàn trong miền này khi CPU bận
    5) Sự mất cân bằng hoàn toàn trong việc sử dụng trong miền này khi CPU bận
    6) Mất cân bằng hoàn toàn về số lượng tác vụ trong miền này khi CPU bận
    7) Mất cân bằng hoàn toàn do các tác vụ không phù hợp trong miền này khi CPU được cài đặt
        bận rộn
    8) Số lần # of trong miền này tách_task() được gọi khi bận
    9) Số lần # of trong miền này tách_task() đã được gọi mặc dù
        tác vụ mục tiêu bị nóng trong bộ nhớ đệm khi bận
    10) # of lần trong miền này sched_balance_rq() đã được gọi nhưng không
        tìm hàng đợi bận rộn hơn trong khi cpu đang bận
    11) # of lần trong miền này hàng đợi bận rộn hơn được tìm thấy trong khi CPU
        đang bận nhưng không tìm thấy nhóm nào bận rộn hơn

12) Số lần # of trong miền này sched_balance_rq() được gọi khi
        cpu không hoạt động
    13) Đã kiểm tra # of lần trong miền này sched_balance_rq() nhưng đã tìm thấy
        tải không yêu cầu cân bằng khi cpu không hoạt động
    14) # of lần trong miền này sched_balance_rq() đã cố gắng di chuyển một hoặc
        nhiều nhiệm vụ hơn và thất bại, khi cpu không hoạt động
    15) Tải mất cân bằng hoàn toàn trong miền này khi CPU không hoạt động
    16) Sự mất cân bằng hoàn toàn trong việc sử dụng trong miền này khi CPU không hoạt động
    17) Mất cân bằng hoàn toàn về số lượng tác vụ trong miền này khi CPU không hoạt động
    18) Mất cân bằng hoàn toàn do các tác vụ không phù hợp trong miền này khi CPU hoạt động
        nhàn rỗi
    19) # of lần trong miền này tách_task() được gọi khi CPU
        đã nhàn rỗi
    20) Số lần # of trong miền này Detach_task() đã được gọi mặc dù
        tác vụ mục tiêu bị nóng trong bộ nhớ đệm khi không hoạt động
    21) # of lần trong miền này sched_balance_rq() đã được gọi nhưng đã thực hiện
        không tìm thấy hàng đợi bận rộn hơn trong khi cpu không hoạt động
    22) # of lần trong miền này hàng đợi bận rộn hơn được tìm thấy trong khi
        cpu không hoạt động nhưng không tìm thấy nhóm bận rộn hơn

23) Số lần # of trong miền này sched_balance_rq() được gọi khi
        cpu vừa mới ngừng hoạt động
    24) Đã kiểm tra # of lần trong miền này sched_balance_rq() nhưng tìm thấy
        tải không yêu cầu cân bằng khi cpu không hoạt động
    25) # of lần trong miền này sched_balance_rq() đã cố gắng di chuyển một hoặc nhiều
        nhiệm vụ và không thành công, khi CPU không hoạt động
    26) Sự mất cân bằng hoàn toàn về tải trong miền này khi CPU mới bắt đầu hoạt động
        nhàn rỗi
    27) Sự mất cân bằng hoàn toàn trong việc sử dụng trong miền này khi CPU vừa mới hoạt động
        trở nên nhàn rỗi
    28) Sự mất cân bằng hoàn toàn về số lượng tác vụ trong miền này khi CPU vừa mới hoạt động
        trở nên nhàn rỗi
    29) Mất cân bằng hoàn toàn do các tác vụ không phù hợp trong miền này khi CPU hoạt động
        chỉ trở nên nhàn rỗi
    30) Số lần # of trong miền này tách_task() được gọi khi mới không hoạt động
    31) Số lần # of trong miền này tách_task() đã được gọi mặc dù
        tác vụ mục tiêu đã bị nóng trong bộ nhớ đệm khi không hoạt động
    32) # of lần trong miền này sched_balance_rq() đã được gọi nhưng không
        tìm một hàng đợi bận rộn hơn trong khi cpu đang không hoạt động
    33) # of lần trong miền này hàng đợi bận rộn hơn được tìm thấy trong khi CPU
        đang trở nên nhàn rỗi nhưng không tìm thấy nhóm bận rộn hơn

Ba số liệu tiếp theo là số liệu thống kê active_load_balance():

34) # of số lần active_load_balance() được gọi
    35) # of lần active_load_balance() cố gắng di chuyển một tác vụ và không thành công
    36) # of lần active_load_balance() đã di chuyển thành công một tác vụ

Ba số liệu tiếp theo là số liệu thống kê sched_balance_exec():

37) sbe_cnt không được sử dụng
    38) sbe_balance không được sử dụng
    39) sbe_push không được sử dụng

Ba số liệu tiếp theo là số liệu thống kê sched_balance_fork():

40) sbf_cnt không được sử dụng
    41) sbf_balance không được sử dụng
    42) sbf_push không được sử dụng

Ba số liệu tiếp theo là số liệu thống kê try_to_wake_up():

43) # of lần trong miền này try_to_wake_up() đã đánh thức một tác vụ
        lần cuối chạy trên một CPU khác trong miền này
    44) # of lần trong miền này try_to_wake_up() đã chuyển một nhiệm vụ sang
        đánh thức cpu vì dù sao nó cũng bị nguội bộ nhớ đệm trên cpu của nó
    45) # of lần trong miền này try_to_wake_up() bắt đầu cân bằng thụ động

/proc/<pid>/schedstat
---------------------
schedstats cũng thêm một tệp /proc/<pid>/schedstat mới để bao gồm một số
cùng một thông tin ở cấp độ mỗi quá trình.  Có ba trường trong
tập tin này tương quan với quá trình đó:

1) thời gian dành cho CPU (tính bằng nano giây)
     2) thời gian chờ đợi trong hàng đợi (tính bằng nano giây)
     3) Các khoảng thời gian # of chạy trên CPU này

Một chương trình có thể được viết dễ dàng để sử dụng các trường bổ sung này nhằm
báo cáo về việc một quy trình cụ thể hoặc một tập hợp các quy trình đang hoạt động tốt như thế nào
theo chính sách của người lập lịch trình.  Một phiên bản đơn giản của chương trình như vậy là
có sẵn tại

ZZ0000ZZ
