.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-energy.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
Lập kế hoạch nhận biết năng lượng
=======================

1. Giới thiệu
---------------

Lập kế hoạch nhận biết năng lượng (hoặc EAS) cung cấp cho người lập lịch khả năng dự đoán
tác động của các quyết định của nó đối với năng lượng tiêu thụ của CPU. EAS dựa vào
Mô hình năng lượng (EM) của CPU để chọn CPU tiết kiệm năng lượng cho từng tác vụ,
với tác động tối thiểu đến thông lượng. Tài liệu này nhằm mục đích cung cấp một
giới thiệu về cách EAS hoạt động, các quyết định thiết kế chính đằng sau nó là gì và
chi tiết những gì cần thiết để làm cho nó chạy.

Trước khi đi xa hơn, xin lưu ý rằng tại thời điểm viết bài::

/!\ EAS không hỗ trợ các nền tảng có cấu trúc liên kết CPU đối xứng /!\

EAS chỉ hoạt động trên các cấu trúc liên kết CPU không đồng nhất (chẳng hạn như Arm big.LITTLE)
bởi vì đây là nơi có tiềm năng tiết kiệm năng lượng thông qua việc lập kế hoạch
cao nhất.

EM thực tế được EAS sử dụng _không_ được duy trì bởi bộ lập lịch mà bởi một
khuôn khổ chuyên dụng. Để biết chi tiết về khuôn khổ này và những gì nó cung cấp,
vui lòng tham khảo tài liệu của nó (xem Documentation/power/energy-model.rst).


2. Bối cảnh và thuật ngữ
-----------------------------

Để làm rõ ngay từ đầu:
 - năng lượng = [joule] (tài nguyên giống như pin trên các thiết bị được cấp nguồn)
 - công suất = năng lượng/thời gian = [joule/giây] = [watt]

Mục tiêu của EAS là giảm thiểu năng lượng trong khi vẫn hoàn thành công việc. Đó
là, chúng tôi muốn tối đa hóa::

hiệu suất [inst/s]
	--------------------
	    công suất [W]

tương đương với việc giảm thiểu::

năng lượng [J]
	-----------
	hướng dẫn

trong khi vẫn đạt được hiệu suất 'tốt'. Về cơ bản nó là một sự thay thế
mục tiêu tối ưu hóa thành mục tiêu chỉ hiệu suất hiện tại cho
lịch trình. Phương án này xem xét hai mục tiêu: hiệu quả năng lượng và
hiệu suất.

Ý tưởng đằng sau việc giới thiệu EM là cho phép người lập lịch đánh giá
ý nghĩa của các quyết định của mình thay vì áp dụng một cách mù quáng các biện pháp tiết kiệm năng lượng
các kỹ thuật có thể chỉ có tác dụng tích cực trên một số nền tảng. Đồng thời
thời gian, EM phải đơn giản nhất có thể để giảm thiểu độ trễ của bộ lập lịch
tác động.

Nói tóm lại, EAS thay đổi cách giao nhiệm vụ CFS cho CPU. Khi đến lúc
để bộ lập lịch quyết định nơi một tác vụ sẽ chạy (trong khi thức dậy), EM
được sử dụng để phá vỡ mối ràng buộc giữa một số ứng cử viên CPU giỏi và chọn ra một ứng cử viên
được dự đoán sẽ mang lại mức tiêu thụ năng lượng tốt nhất mà không gây hại cho
thông lượng của hệ thống. Những dự đoán do EAS đưa ra dựa trên các yếu tố cụ thể của
kiến thức về cấu trúc liên kết của nền tảng, bao gồm 'dung lượng' của CPU,
và chi phí năng lượng tương ứng của chúng.


3. Thông tin cấu trúc liên kết
-----------------------

EAS (cũng như phần còn lại của bộ lập lịch) sử dụng khái niệm 'công suất' để
phân biệt các CPU có thông lượng tính toán khác nhau. “Công suất” của một chiếc CPU
đại diện cho khối lượng công việc nó có thể xử lý khi chạy ở mức cao nhất
tần số so với CPU có khả năng cao nhất của hệ thống. Giá trị công suất là
được chuẩn hóa trong phạm vi 1024 và có thể so sánh được với các tín hiệu sử dụng của
các tác vụ và CPU được tính toán bằng cơ chế Theo dõi tải trên mỗi thực thể (PELT). Cảm ơn
đến giá trị công suất và mức sử dụng, EAS có thể ước tính mức độ lớn/bận rộn của một
task/CPU là như vậy và hãy cân nhắc điều này khi đánh giá hiệu suất so với
sự đánh đổi năng lượng. Dung lượng của CPU được cung cấp thông qua mã dành riêng cho Arch
thông qua lệnh gọi lại Arch_scale_cpu_capacity().

Phần còn lại của kiến thức nền tảng được EAS sử dụng được đọc trực tiếp từ Energy
Khung mô hình (EM). EM của một nền tảng bao gồm một bảng chi phí điện năng
theo 'miền hiệu suất' trong hệ thống (xem Tài liệu/power/energy-model.rst
để biết thêm chi tiết về các lĩnh vực hiệu suất).

Bộ lập lịch quản lý các tham chiếu đến các đối tượng EM trong mã cấu trúc liên kết khi
các miền lập kế hoạch được xây dựng hoặc xây dựng lại. Đối với mỗi tên miền gốc (rd),
bộ lập lịch duy trì một danh sách liên kết đơn của tất cả các miền hiệu suất giao nhau
thứ hiện tại-> nhịp. Mỗi nút trong danh sách chứa một con trỏ tới một cấu trúc
em_perf_domain do khung EM cung cấp.

Các danh sách được đính kèm vào các tên miền gốc để đối phó với độc quyền
cấu hình cpuset. Vì ranh giới của các bộ CPU độc quyền không
nhất thiết phải khớp với các miền hiệu suất, danh sách các gốc khác nhau
tên miền có thể chứa các phần tử trùng lặp.

Ví dụ 1.
    Chúng ta hãy xem xét một nền tảng có 12 CPU, được chia thành 3 miền hiệu suất
    (pd0, pd4 và pd8), được tổ chức như sau::

CPU: 0 1 2 3 4 5 6 7 8 9 10 11
	          PD: ZZ0000ZZ--pd4--ZZ0001ZZ
	          RD: ZZ0002ZZ------rd2------|

Bây giờ, hãy xem xét rằng không gian người dùng đã quyết định chia hệ thống thành hai
    các bộ CPU độc quyền, do đó tạo ra hai miền gốc độc lập, mỗi miền
    chứa 6 CPU. Hai miền gốc được ký hiệu là rd1 và rd2 trong
    hình trên. Vì pd4 cắt cả rd1 và rd2 nên nó sẽ là
    có trong danh sách liên kết '->pd' được đính kèm với mỗi danh sách:

* rd1->pd: pd0 -> pd4
       * rd2->pd: pd4 -> pd8

Xin lưu ý rằng bộ lập lịch sẽ tạo hai nút danh sách trùng lặp cho
    pd4 (một cho mỗi danh sách). Tuy nhiên, cả hai chỉ giữ một con trỏ giống nhau
    cấu trúc dữ liệu được chia sẻ của khung EM.

Vì việc truy cập vào các danh sách này có thể xảy ra đồng thời với hotplug và các danh sách khác.
mọi thứ, chúng được bảo vệ bởi RCU, giống như phần còn lại của cấu trúc cấu trúc liên kết
được điều khiển bởi bộ lập lịch.

EAS cũng duy trì khóa tĩnh (sched_energy_Present) được bật khi ở
ít nhất một miền gốc đáp ứng mọi điều kiện để EAS bắt đầu. Những điều kiện đó
được tóm tắt ở Phần 6.


4. Vị trí nhiệm vụ nhận biết năng lượng
------------------------------

EAS ghi đè mã cân bằng đánh thức tác vụ CFS. Nó sử dụng EM của
nền tảng và tín hiệu PELT để chọn mục tiêu CPU tiết kiệm năng lượng trong quá trình
cân bằng khi thức dậy. Khi EAS được bật, các lệnh gọi select_task_rq_fair()
find_energy_factor_cpu() để đưa ra quyết định về vị trí. Chức năng này trông
dành cho CPU có công suất dự phòng cao nhất (dung lượng CPU - mức sử dụng CPU) trong
mỗi miền hiệu suất vì nó là miền sẽ cho phép chúng ta duy trì
tần số thấp nhất. Sau đó, hàm này sẽ kiểm tra xem việc đặt tác vụ ở đó có thể
tiết kiệm năng lượng so với việc để nó trên prev_cpu, tức là CPU nơi tác vụ chạy
trong lần kích hoạt trước đó của nó.

find_energy_factor_cpu() sử dụng tính toán_energy() để ước tính kết quả sẽ là gì
năng lượng mà hệ thống tiêu thụ nếu tác vụ thức được di chuyển. tính_năng lượng()
xem xét bối cảnh sử dụng hiện tại của CPU và điều chỉnh nó để
'mô phỏng' việc di chuyển nhiệm vụ. Khung EM cung cấp em_pd_energy() API
tính toán mức tiêu thụ năng lượng dự kiến của từng miền hiệu suất cho
bối cảnh sử dụng nhất định.

Dưới đây là một ví dụ về quyết định bố trí nhiệm vụ được tối ưu hóa năng lượng.

Ví dụ 2.
    Chúng ta hãy xem xét một nền tảng (giả) với 2 miền hiệu suất độc lập
    bao gồm hai CPU mỗi cái. CPU0 và CPU1 là những CPU nhỏ; CPU2 và CPU3
    lớn.

Bộ lập lịch phải quyết định vị trí đặt nhiệm vụ P có util_avg = 200
    và prev_cpu = 0.

Bối cảnh sử dụng hiện tại của CPU được mô tả trên biểu đồ
    bên dưới. CPU 0-3 có util_avg lần lượt là 400, 100, 600 và 500
    Mỗi miền hiệu suất có ba Điểm hiệu suất hoạt động (OPP).
    Công suất và chi phí điện năng của CPU liên quan đến mỗi OPP được liệt kê trong
    bảng Mô hình Năng lượng. util_avg của P được thể hiện trên hình
    bên dưới là 'PP'::

CPU sử dụng.
      1024 - - - - - - - Mẫu năng lượng
                                               +----------+-------------+
                                               ZZ0000ZZ Lớn |
       768 ============= +------+------+------+------+
                                               Máy Pwr ZZ0001ZZ Máy Pwr ZZ0002ZZ |
                                               +------+------+------+------+
       512 ============ - ##- - - - - ZZ0003ZZ 50 ZZ0004ZZ 400 |
                             ## ##         ZZ0015ZZ 150 ZZ0006ZZ 800 |
       341 -PP - - - - ## ##         ZZ0017ZZ 300 ZZ0008ZZ 1700 |
             PP ## ## +------+-------+------+------+
       170 -## - - - - ## ##
             ## ## ## ##
           ------------ -------------
            CPU0 CPU1 CPU2 CPU3

OPP hiện tại: ===== OPP khác: - - - util_avg (mỗi cái 100): ##


find_energy_factor_cpu() trước tiên sẽ tìm kiếm các CPU có
    công suất dự phòng tối đa trong hai lĩnh vực hoạt động. Trong ví dụ này,
    CPU1 và CPU3. Sau đó nó sẽ ước tính năng lượng của hệ nếu P là
    đặt trên một trong hai cái đó và kiểm tra xem điều đó có tiết kiệm năng lượng không
    so với việc rời P trên CPU0. EAS giả định rằng OPP tuân theo việc sử dụng
    (phù hợp với hành vi của schedutil CPUFreq
    thống đốc, xem Phần 6. để biết thêm chi tiết về chủ đề này).

ZZ0000ZZ::

1024 - - - - - - -

Tính toán năng lượng:
       768 ============== * CPU0: 200 / 341 * 150 = 88
                                             *CPU1: 300/341*150 = 131
                                             *CPU2: 600/768*800 = 625
       512 - - - - - - - ##- - - - - * CPU3: 500 / 768 * 800 = 520
                             ## ## => tổng_năng lượng = 1364
       341 ============ ## ##
                    PP ## ##
       170 -## - - PP- ## ##
             ## ## ## ##
           ------------ -------------
            CPU0 CPU1 CPU2 CPU3


ZZ0000ZZ::

1024 - - - - - - -

Tính toán năng lượng:
       768 ============== * CPU0: 200 / 341 * 150 = 88
                                             *CPU1: 100/341*150 = 43
                                    PP*CPU2: 600/768*800 = 625
       512 - - - - - - - ##- - -PP - *CPU3: 700 / 768 * 800 = 729
                             ## ## => tổng_năng lượng = 1485
       341 ============ ## ##
                             ## ##
       170 -## - - - - ## ##
             ## ## ## ##
           ------------ -------------
            CPU0 CPU1 CPU2 CPU3


ZZ0000ZZ::

1024 - - - - - - -

Tính toán năng lượng:
       768 ============== * CPU0: 400 / 512 * 300 = 234
                                             *CPU1: 100/512*300 = 58
                                             *CPU2: 600/768*800 = 625
       512 ============ - ##- - - - - *CPU3: 500 / 768 * 800 = 520
                             ## ## => tổng_năng lượng = 1437
       341 -PP - - - - ## ##
             PP ## ##
       170 -## - - - - ## ##
             ## ## ## ##
           ------------ -------------
            CPU0 CPU1 CPU2 CPU3


Từ những tính toán này, Trường hợp 1 có tổng năng lượng thấp nhất. Vậy CPU 1
    là ứng cử viên tốt nhất xét theo quan điểm tiết kiệm năng lượng.

CPU lớn thường ngốn nhiều năng lượng hơn CPU nhỏ và do đó được sử dụng
chủ yếu là khi một nhiệm vụ không phù hợp với trẻ nhỏ. Tuy nhiên, các CPU nhỏ không phải lúc nào cũng
nhất thiết phải tiết kiệm năng lượng hơn so với CPU lớn. Đối với một số hệ thống, OPP cao
của các CPU nhỏ có thể ít tiết kiệm năng lượng hơn so với các OPP thấp nhất của
lớn chẳng hạn. Vì vậy, nếu các CPU nhỏ có đủ mức sử dụng ở
một thời điểm cụ thể, một nhiệm vụ nhỏ được thực hiện vào thời điểm đó có thể tốt hơn
thực hiện theo hướng lớn để tiết kiệm năng lượng, mặc dù nó phù hợp
ở phía nhỏ.

Và ngay cả trong trường hợp tất cả OPP của CPU lớn đều kém tiết kiệm năng lượng hơn
hơn so với những CPU nhỏ, việc sử dụng CPU lớn cho một tác vụ nhỏ vẫn có thể, dưới
điều kiện cụ thể, tiết kiệm năng lượng. Thật vậy, việc đặt một nhiệm vụ lên một chiếc CPU nhỏ có thể
dẫn đến việc nâng cao OPP của toàn bộ miền hiệu suất và điều đó sẽ
tăng chi phí của các nhiệm vụ đang chạy ở đó. Nếu nhiệm vụ thức là
được đặt trên một CPU lớn, chi phí thực hiện của nó có thể cao hơn nếu nó được đặt trên một CPU lớn.
chạy chậm một chút nhưng không ảnh hưởng đến các tác vụ khác của CPU nhỏ
sẽ tiếp tục chạy ở OPP thấp hơn. Vì vậy, khi xét tổng năng lượng
được tiêu thụ bởi CPU, chi phí tăng thêm khi chạy một tác vụ đó trên lõi lớn có thể là
nhỏ hơn chi phí nâng cấp OPP trên các CPU nhỏ cho tất cả các CPU khác
nhiệm vụ.

Các ví dụ trên gần như không thể hiểu đúng một cách chung chung, và
cho tất cả các nền tảng mà không cần biết chi phí chạy ở các OPP khác nhau trên tất cả
CPU của hệ thống. Nhờ thiết kế dựa trên EM, EAS có thể giải quyết được chúng
một cách chính xác mà không gặp quá nhiều rắc rối. Tuy nhiên, để đảm bảo tối thiểu
tác động đến thông lượng cho các kịch bản sử dụng cao, EAS cũng triển khai một cách khác
cơ chế được gọi là 'sử dụng quá mức'.


5. Sử dụng quá mức
-------------------

Từ quan điểm chung, các trường hợp sử dụng mà EAS có thể trợ giúp nhiều nhất là những trường hợp
liên quan đến việc sử dụng CPU nhẹ/trung bình. Bất cứ khi nào các tác vụ có giới hạn CPU dài được thực hiện
đang được chạy, chúng sẽ yêu cầu tất cả dung lượng CPU có sẵn và không có
bộ lập lịch có thể thực hiện nhiều việc để tiết kiệm năng lượng mà không gây tổn hại nghiêm trọng
thông lượng. Để tránh ảnh hưởng đến hiệu suất với EAS, CPU được gắn cờ là
'tận dụng quá mức' ngay khi chúng được sử dụng ở mức hơn 80% công suất tính toán của chúng
năng lực. Miễn là không có CPU nào bị sử dụng quá mức trong miền gốc, cân bằng tải
bị tắt và EAS ghi đè mã cân bằng đánh thức. EAS có khả năng tải
CPU tiết kiệm năng lượng nhất của hệ thống nhiều hơn các CPU khác nếu điều đó có thể
được thực hiện mà không làm tổn hại đến thông lượng. Vì vậy, bộ cân bằng tải bị vô hiệu hóa để ngăn chặn
nó phá vỡ cách bố trí nhiệm vụ tiết kiệm năng lượng được tìm thấy bởi EAS. Nó là an toàn để
làm như vậy khi hệ thống không bị sử dụng quá mức do ở dưới điểm giới hạn 80%
ngụ ý rằng:

Một. có một số thời gian nhàn rỗi trên tất cả các CPU, do đó các tín hiệu sử dụng được sử dụng
       EAS có khả năng thể hiện chính xác 'quy mô' của các nhiệm vụ khác nhau
       trong hệ thống;
    b. tất cả các nhiệm vụ phải được cung cấp đủ dung lượng CPU,
       bất chấp những giá trị tốt đẹp của chúng;
    c. vì có dung lượng dự phòng nên tất cả các tác vụ phải bị chặn/ngủ
       đều đặn và cân bằng khi thức dậy là đủ.

Ngay khi một CPU vượt quá điểm tới hạn 80%, ít nhất một trong ba
giả định trên trở nên không chính xác. Trong trường hợp này, cờ 'sử dụng quá mức'
được nâng lên cho toàn bộ miền gốc, EAS bị vô hiệu hóa và bộ cân bằng tải bị vô hiệu hóa
được kích hoạt lại. Bằng cách đó, bộ lập lịch sẽ quay trở lại các thuật toán dựa trên tải để
đánh thức và cân bằng tải trong điều kiện ràng buộc CPU. Điều này cung cấp một điều tốt hơn
tôn trọng những giá trị tốt đẹp của nhiệm vụ.

Vì khái niệm sử dụng quá mức chủ yếu dựa vào việc phát hiện xem liệu
có một số thời gian nhàn rỗi trong hệ thống, dung lượng CPU bị 'đánh cắp' cao hơn
(hơn CFS) các lớp lập kế hoạch (cũng như IRQ) phải được tính đến. Như
như vậy, việc phát hiện việc sử dụng quá mức không chỉ ảnh hưởng đến công suất được sử dụng
bởi các nhiệm vụ CFS mà còn bởi các lớp lập kế hoạch khác và IRQ.


6. Sự phụ thuộc và yêu cầu đối với EAS
----------------------------------------

Lập kế hoạch nhận biết năng lượng phụ thuộc vào CPU của hệ thống có yêu cầu cụ thể
thuộc tính phần cứng và các tính năng khác của kernel đang được kích hoạt. Cái này
phần liệt kê những phụ thuộc này và cung cấp gợi ý về cách đáp ứng chúng.


6.1 - Cấu trúc liên kết CPU không đối xứng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^


Như đã đề cập trong phần giới thiệu, EAS chỉ được hỗ trợ trên các nền tảng có
cấu trúc liên kết CPU không đối xứng hiện nay. Yêu cầu này được kiểm tra trong thời gian chạy bởi
tìm kiếm sự hiện diện của cờ SD_ASYM_CPUCAPACITY_FULL khi lập kế hoạch
tên miền được xây dựng.

Xem Documentation/scheduler/sched-capacity.rst để biết các yêu cầu cần đáp ứng cho việc này
cờ được đặt trong hệ thống phân cấp sched_domain.

Xin lưu ý rằng EAS về cơ bản không tương thích với SMP, nhưng không
người ta đã thấy tiết kiệm đáng kể trên nền tảng SMP. Hạn chế này
có thể được sửa đổi trong tương lai nếu được chứng minh khác đi.


6.2 - Sự hiện diện của Mô hình Năng lượng
^^^^^^^^^^^^^^^^^^^^^^^^^^^

EAS sử dụng EM của nền tảng để ước tính tác động của các quyết định lập kế hoạch đối với
năng lượng. Vì vậy, nền tảng của bạn phải cung cấp bảng chi phí điện năng cho khung EM trong
để khởi động EAS. Để thực hiện việc này, vui lòng tham khảo tài liệu của
khung EM độc lập trong Documentation/power/energy-model.rst.

Cũng xin lưu ý rằng các miền lập kế hoạch cần phải được xây dựng lại sau
EM đã được đăng ký để khởi động EAS.

EAS sử dụng EM để đưa ra quyết định dự báo về việc sử dụng năng lượng và do đó
tập trung hơn vào sự khác biệt khi kiểm tra các tùy chọn khả thi cho nhiệm vụ
vị trí. Đối với EAS, việc giá trị công suất EM có được biểu thị hay không không quan trọng
tính bằng mili-Watt hoặc ở 'thang trừu tượng'.


6.3 - Độ phức tạp của mô hình năng lượng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

EAS không áp đặt bất kỳ giới hạn phức tạp nào đối với số lượng PD/OPP/CPU nhưng
giới hạn số lượng CPU ở EM_MAX_NUM_CPUS để tránh tràn trong quá trình
việc ước lượng năng lượng.


6.4 - Thống đốc Schedutil
^^^^^^^^^^^^^^^^^^^^^^^^

EAS cố gắng dự đoán CPU nào sẽ chạy OPP trong tương lai gần
để ước tính mức tiêu thụ năng lượng của họ. Để làm như vậy, giả định rằng OPP
của CPU tuân theo việc sử dụng chúng.

Mặc dù rất khó đưa ra những đảm bảo chắc chắn về tính chính xác
của giả định này trong thực tế (vì phần cứng có thể không làm được những gì nó vốn có)
được yêu cầu làm chẳng hạn), schedutil trái ngược với các bộ điều chỉnh CPUFreq khác tại
tần số _requests_ tối thiểu được tính bằng cách sử dụng tín hiệu sử dụng.
Do đó, bộ điều chỉnh lành mạnh duy nhất được sử dụng cùng với EAS là schedutil,
bởi vì nó là cách duy nhất cung cấp mức độ nhất quán nào đó giữa
yêu cầu tần số và dự đoán năng lượng.

Việc sử dụng EAS với bất kỳ bộ điều chỉnh nào khác ngoài schedutil đều không được hỗ trợ.


6.5 Tín hiệu sử dụng bất biến tỷ lệ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Để đưa ra dự đoán chính xác trên các CPU và cho mọi hiệu suất
trạng thái, EAS cần tín hiệu PELT bất biến tần số và CPU. Những cái này có thể
có thể thu được bằng cách sử dụng Arch_scale{cpu,freq__capacity() do kiến trúc xác định
cuộc gọi lại.

Việc sử dụng EAS trên nền tảng không triển khai hai lệnh gọi lại này thì không
được hỗ trợ.


6.6 Đa luồng (SMT)
^^^^^^^^^^^^^^^^^^^^^^^^

EAS ở dạng hiện tại không được biết đến và không thể tận dụng
phần cứng đa luồng để tiết kiệm năng lượng. EAS coi các luồng là độc lập
CPU, thực sự có thể phản tác dụng cả về hiệu suất và năng lượng.

EAS trên SMT không được hỗ trợ.
