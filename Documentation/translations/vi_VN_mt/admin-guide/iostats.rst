.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/iostats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================
Các trường thống kê I/O
=======================

Hạt nhân hiển thị số liệu thống kê đĩa thông qua ZZ0000ZZ và
ZZ0001ZZ. Các số liệu thống kê này thường được truy cập thông qua các công cụ
chẳng hạn như ZZ0002ZZ và ZZ0003ZZ.

Dưới đây là ví dụ sử dụng đĩa có hai phân vùng::

/proc/đĩa thống kê:
     259 0 nvme0n1 255999 814 12369153 47919 996852 81 36123024 425995 0 301795 580470 0 0 0 0 60602 106555
     259 1 nvme0n1p1 492 813 17572 96 848 81 108288 210 0 76 307 0 0 0 0 0 0
     259 2 nvme0n1p2 255401 1 12343477 47799 996004 0 36014736 425784 0 344336 473584 0 0 0 0 0 0

/sys/block/nvme0n1/stat:
     255999 814 12369153 47919 996858 81 36123056 426009 0 301809 580491 0 0 0 0 60605 106562

/sys/block/nvme0n1/nvme0n1p1/stat:
     492 813 17572 96 848 81 108288 210 0 76 307 0 0 0 0 0

Cả hai tệp đều chứa 17 số liệu thống kê giống nhau. ZZ0000ZZ
chứa các trường cho ZZ0001ZZ. Trong ZZ0002ZZ các trường
được bắt đầu bằng số thiết bị chính và phụ và thiết bị
tên. Trong ví dụ trên, giá trị chỉ số đầu tiên cho ZZ0003ZZ là
255999 trong cả hai tệp.

Tệp sysfs ZZ0000ZZ có hiệu quả để theo dõi một tập hợp nhỏ, đã biết
của các đĩa. Nếu bạn đang theo dõi một số lượng lớn thiết bị,
ZZ0001ZZ thường là lựa chọn tốt hơn vì nó tránh được
chi phí mở và đóng nhiều tệp cho mỗi ảnh chụp nhanh.

Tất cả các trường đều là các bộ đếm tích lũy, đơn điệu, ngoại trừ trường 9, là trường
đặt lại về 0 khi I/O hoàn tất. Các trường còn lại được đặt lại khi khởi động, bật
gắn lại hoặc khởi tạo lại thiết bị hoặc khi bộ đếm cơ bản
tràn. Các ứng dụng đọc các bộ đếm này sẽ phát hiện và xử lý
đặt lại khi so sánh ảnh chụp nhanh chỉ số.

Mỗi bộ số liệu thống kê chỉ áp dụng cho thiết bị được chỉ định; nếu bạn muốn
số liệu thống kê toàn hệ thống, bạn sẽ phải tìm tất cả các thiết bị và tổng hợp tất cả chúng lại.

Trường 1 - # of đã đọc xong (dài không dấu)
    Đây là tổng số lần đọc được hoàn thành thành công.

Trường 2 -- # of đọc đã hợp nhất, trường 6 -- # of ghi đã hợp nhất (dài không dấu)
    Các thao tác đọc và ghi liền kề nhau có thể được hợp nhất để
    hiệu quả.  Do đó, hai lần đọc 4K có thể trở thành một lần đọc 8K trước khi nó được thực hiện.
    cuối cùng được chuyển vào đĩa và do đó nó sẽ được tính (và xếp hàng đợi)
    chỉ có một I/O.  Trường này cho bạn biết tần suất việc này được thực hiện.

Trường 3 - Các cung # of đã đọc (dài không dấu)
    Đây là tổng số lĩnh vực được đọc thành công.

Trường 4 -- # of mili giây dành cho việc đọc (unsigned int)
    Đây là tổng số mili giây được sử dụng cho tất cả các lần đọc (như
    được đo từ blk_mq_alloc_request() đến __blk_mq_end_request()).

Trường 5 - Việc ghi # of đã hoàn tất (dài không dấu)
    Đây là tổng số lần viết được hoàn thành thành công.

Trường 6 - # of ghi đã hợp nhất (dài không dấu)
    Xem mô tả của trường 2.

Trường 7 - Các lĩnh vực # of được viết (dài không dấu)
    Đây là tổng số lĩnh vực được viết thành công.

Trường 8 -- # of mili giây dành cho việc viết (unsigned int)
    Đây là tổng số mili giây được sử dụng cho tất cả các lần ghi (như
    được đo từ blk_mq_alloc_request() đến __blk_mq_end_request()).

Trường 9 - I/O # of hiện đang được xử lý (unsign int)
    Trường duy nhất sẽ về 0. Tăng dần theo yêu cầu
    được cung cấp cho cấu trúc request_queue thích hợp và giảm dần khi hoàn thành.

Trường 10 -- # of mili giây dành để thực hiện I/O (unsigned int)
    Trường này tăng miễn là trường 9 khác 0.

Kể từ phiên bản 5.0, trường này sẽ tính ngay lập tức khi có ít nhất một yêu cầu được thực hiện.
    bắt đầu hoặc hoàn thành. Nếu yêu cầu chạy hơn 2 giây thì một số
    Thời gian I/O có thể không được tính trong trường hợp có yêu cầu đồng thời.

Trường 11 - mili giây # of có trọng số dành để thực hiện I/O (unsigned int)
    Trường này được tăng lên ở mỗi lần bắt đầu I/O, hoàn thành I/O, I/O
    hợp nhất hoặc đọc các số liệu thống kê này theo số lượng I/O đang diễn ra
    (trường 9) nhân với số mili giây dành cho việc thực hiện I/O kể từ
    cập nhật cuối cùng của lĩnh vực này.  Điều này có thể cung cấp một thước đo dễ dàng cho cả hai
    Thời gian hoàn thành I/O và tồn đọng có thể đang tích lũy.

Trường 12 -- # of loại bỏ đã hoàn thành (dài không dấu)
    Đây là tổng số lần hủy được hoàn thành thành công.

Trường 13 - # of loại bỏ đã hợp nhất (dài không dấu)
    Xem mô tả của trường 2

Trường 14 -- Các cung # of bị loại bỏ (dài không dấu)
    Đây là tổng số lĩnh vực bị loại bỏ thành công.

Trường 15 -- # of mili giây dành cho việc loại bỏ (unsigned int)
    Đây là tổng số mili giây được sử dụng bởi tất cả các lần loại bỏ (như
    được đo từ blk_mq_alloc_request() đến __blk_mq_end_request()).

Trường 16 -- Yêu cầu xóa # of đã hoàn thành
    Đây là tổng số yêu cầu tuôn ra được hoàn thành thành công.

Lớp khối kết hợp các yêu cầu tuôn ra và thực hiện nhiều nhất một yêu cầu cùng một lúc.
    Điều này đếm các yêu cầu tuôn ra được thực hiện bởi đĩa. Không được theo dõi cho các phân vùng.

Trường 17 - # of dành một phần nghìn giây để xả
    Đây là tổng số mili giây được sử dụng bởi tất cả các yêu cầu xóa.

Để tránh gây tắc nghẽn hiệu suất, không có khóa nào được giữ trong khi
sửa đổi các bộ đếm này.  Điều này ngụ ý rằng những sai sót nhỏ có thể xảy ra
được đưa ra khi các thay đổi xung đột, vì vậy (ví dụ) cộng tất cả các
đọc I/O được cấp cho mỗi phân vùng phải bằng với các I/O được tạo cho đĩa ...
nhưng do không có khóa nên có thể chỉ ở rất gần.

Ở phiên bản 2.6+, có bộ đếm cho mỗi CPU, điều này khiến cho việc thiếu khóa
gần như không phải là vấn đề.  Khi số liệu thống kê được đọc, bộ đếm trên mỗi CPU
được tính tổng (có thể vượt quá biến dài không dấu mà chúng
được tính tổng) và kết quả được cung cấp cho người dùng.  Không có thuận tiện
giao diện người dùng để truy cập vào các bộ đếm trên mỗi CPU.

Vì thời gian yêu cầu 4,19 được đo với độ chính xác nano giây và
bị cắt ngắn đến mili giây trước khi hiển thị trong giao diện này.

Đĩa vs phân vùng
-------------------

Có những thay đổi đáng kể giữa 2,4 và 2,6+ trong hệ thống con I/O.
Kết quả là một số thông tin thống kê đã biến mất. Bản dịch từ
địa chỉ đĩa tương ứng với phân vùng và địa chỉ đĩa tương ứng với
đĩa chủ xảy ra sớm hơn nhiều.  Tất cả sự hợp nhất và thời gian bây giờ xảy ra
ở cấp độ đĩa chứ không phải ở cả cấp độ đĩa và phân vùng như
trong 2.4.  Do đó, bạn sẽ thấy kết quả thống kê khác trên 2.6+ cho
phân vùng từ đó cho đĩa.  Chỉ có các trường ZZ0000ZZ
cho các phân vùng trên máy 2.6+.  Điều này được phản ánh trong các ví dụ trên.

Trường 1 - # of đọc được phát hành
    Đây là tổng số lần đọc được cấp cho phân vùng này.

Trường 2 -- Các lĩnh vực # of được đọc
    Đây là tổng số lĩnh vực được yêu cầu đọc từ đây
    phân vùng.

Trường 3 -- # of viết đã được phát hành
    Đây là tổng số lần ghi được cấp cho phân vùng này.

Trường 4 -- Các lĩnh vực # of được viết
    Đây là tổng số lĩnh vực được yêu cầu ghi vào
    phân vùng này.

Lưu ý rằng vì địa chỉ được dịch sang địa chỉ tương đối trên đĩa và không có
bản ghi địa chỉ tương đối của phân vùng được lưu giữ, thành công tiếp theo
hoặc lỗi đọc không thể được quy cho phân vùng.  Ở nơi khác
từ, số lần đọc cho phân vùng được tính nhẹ trước thời gian
xếp hàng cho các phân vùng và khi hoàn thành cho toàn bộ đĩa.  Đây là
một sự khác biệt tinh tế có lẽ không thú vị đối với hầu hết các trường hợp.

Điều quan trọng hơn là sai số gây ra khi đếm số lượng
đọc/ghi trước khi hợp nhất đối với phân vùng và sau đối với đĩa. Vì một
khối lượng công việc điển hình thường chứa rất nhiều yêu cầu liên tiếp và liền kề,
số lần đọc/ghi được phát hành có thể cao hơn nhiều lần so với
số lần đọc/ghi hoàn thành.

Trong 2.6.25, bộ thống kê đầy đủ lại có sẵn cho các phân vùng và
số liệu thống kê về đĩa và phân vùng lại nhất quán. Vì chúng ta vẫn chưa
giữ bản ghi địa chỉ liên quan đến phân vùng, một hoạt động được quy cho
phân vùng chứa khu vực đầu tiên của yêu cầu sau
sự hợp nhất cuối cùng. Vì các yêu cầu có thể được hợp nhất trên toàn bộ phân vùng, điều này có thể dẫn đến
đến một số điểm không chính xác (có thể không đáng kể).

Ghi chú bổ sung
----------------

Trong 2.6+, sysfs không được gắn theo mặc định.  Nếu việc phân phối của bạn
Linux chưa thêm nó vào, đây là dòng bạn sẽ muốn thêm vào
ZZ0000ZZ của bạn::

không có /sys sysfs mặc định 0 0


Trong phiên bản 2.6+, tất cả số liệu thống kê về ổ đĩa đã bị xóa khỏi ZZ0000ZZ.  Trong 2.4, họ
xuất hiện trong cả ZZ0001ZZ và ZZ0002ZZ, mặc dù những cái trong
ZZ0003ZZ có định dạng rất khác so với ZZ0004ZZ
(xem Proc(5), nếu hệ thống của bạn có nó.)

-- ricklind@us.ibm.com
