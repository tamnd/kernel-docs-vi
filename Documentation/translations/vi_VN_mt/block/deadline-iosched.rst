.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/deadline-iosched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================
Điều chỉnh lịch trình IO thời hạn
==============================

Tệp nhỏ này cố gắng ghi lại cách thức hoạt động của bộ lập lịch io thời hạn.
Đặc biệt, nó sẽ làm rõ ý nghĩa của các điều chỉnh được tiếp xúc có thể
được người sử dụng điện quan tâm.

Chọn bộ lập lịch IO
-----------------------
Tham khảo Documentation/block/switching-sched.rst để biết thông tin về
chọn bộ lập lịch io trên cơ sở từng thiết bị.

------------------------------------------------------------------------------

read_expire (tính bằng mili giây)
-----------------------

Mục tiêu của bộ lập lịch io thời hạn là cố gắng đảm bảo bắt đầu
thời gian phục vụ cho một yêu cầu. Vì chúng tôi tập trung chủ yếu vào độ trễ đọc nên đây là
có thể điều chỉnh được. Khi một yêu cầu đọc lần đầu tiên vào bộ lập lịch io, nó sẽ được chỉ định
thời hạn là thời gian hiện tại + giá trị read_expire tính bằng đơn vị
mili giây.


write_expire (tính bằng mili giây)
-----------------------

Tương tự như read_expire đã đề cập ở trên, nhưng dành cho ghi.


fifo_batch (số lượng yêu cầu)
------------------------------------

Các yêu cầu được nhóm thành ZZ0000ZZ theo hướng dữ liệu cụ thể (đọc hoặc
write) được phục vụ theo thứ tự ngành tăng dần.  Để hạn chế việc tìm kiếm thêm,
thời hạn hết hạn chỉ được kiểm tra giữa các đợt.  fifo_batch kiểm soát
số lượng yêu cầu tối đa mỗi đợt.

Tham số này điều chỉnh sự cân bằng giữa độ trễ theo yêu cầu và tổng hợp
thông lượng.  Khi độ trễ thấp là mối quan tâm hàng đầu thì càng nhỏ càng tốt (trong đó
giá trị 1 mang lại hành vi đến trước được phục vụ trước).  Tăng fifo_batch
thường cải thiện thông lượng nhưng phải trả giá bằng sự thay đổi độ trễ.


write_starved (số lượng công văn)
--------------------------------------

Khi chúng ta phải di chuyển các yêu cầu từ hàng đợi của bộ lập lịch io sang khối
hàng đợi gửi thiết bị, chúng tôi luôn ưu tiên đọc. Tuy nhiên, chúng tôi
cũng không muốn chết đói viết vô thời hạn. Vì vậy, điều khiển write_starved
bao nhiêu lần chúng ta ưu tiên đọc hơn viết. Khi điều đó đã xảy ra
done write_starved số lần, chúng tôi gửi một số bài viết dựa trên
tiêu chí tương tự như lần đọc.


front_merges (bool)
----------------------

Đôi khi xảy ra trường hợp một yêu cầu đi vào bộ lập lịch io liền kề
với một yêu cầu đã có trong hàng đợi. Hoặc nó vừa với mặt sau của cái đó
yêu cầu, hoặc nó phù hợp ở phía trước. Đó được gọi là ứng cử viên hợp nhất ngược
hoặc một ứng cử viên hợp nhất phía trước. Do cách các tập tin thường được trình bày,
sáp nhập phía sau phổ biến hơn nhiều so với sáp nhập phía trước. Đối với một số khối lượng công việc, bạn
thậm chí có thể biết rằng thật lãng phí thời gian nếu cố gắng
yêu cầu hợp nhất phía trước. Đặt front_merges thành 0 sẽ tắt chức năng này.
Việc hợp nhất mặt trước vẫn có thể xảy ra do gợi ý Last_merge được lưu trong bộ nhớ đệm, nhưng vì
về cơ bản có chi phí bằng 0, chúng tôi để nguyên điều đó. Chúng tôi chỉ đơn giản là vô hiệu hóa
Tra cứu khu vực phía trước rbtree khi hàm hợp nhất bộ lập lịch io được gọi.


Ngày 11 tháng 11 năm 2002, Jens Axboe <jens.axboe@oracle.com>
