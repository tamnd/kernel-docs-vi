.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scheduler/sched-nice-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Lập kế hoạch Thiết kế đẹp
=========================

Tài liệu này giải thích suy nghĩ về việc cải tiến và sắp xếp hợp lý
triển khai mức độ tốt đẹp trong bộ lập lịch Linux mới.

Mức độ tốt luôn khá yếu trong Linux và mọi người liên tục
đã cản trở chúng tôi thực hiện các tác vụ +19 thú vị sử dụng ít thời gian CPU hơn nhiều.

Thật không may, điều đó không dễ thực hiện theo chính sách cũ.
công cụ lập lịch trình, (nếu không thì chúng tôi đã làm việc đó từ lâu rồi) vì mức độ tốt
sự hỗ trợ về mặt lịch sử đã được kết hợp với độ dài khoảng thời gian và khoảng thời gian
các đơn vị được điều khiển bởi tích tắc HZ, do đó khoảng thời gian nhỏ nhất là 1/HZ.

Trong bộ lập lịch O(1) (năm 2003), chúng tôi đã thay đổi mức Nice âm thành
mạnh hơn nhiều so với trước đây ở phiên bản 2.4 (và mọi người rất vui vì
thay đổi đó) và chúng tôi cũng cố tình hiệu chỉnh khoảng thời gian tuyến tính
quy tắc sao cho mức +19 tốt đẹp đó sẽ là _chính xác_ 1 giây lát. Để tốt hơn
hiểu chưa, biểu đồ thời gian đã diễn ra như thế này (nghệ thuật ASCII sến súa
cảnh báo!)::


A
             \ | [độ dài lát cắt thời gian]
              \ |
               \ |
                \ |
                 \ |
                  \|___100ms
                   |^ . _
                   |      ^ . _
                   |            ^ . _
 -ZZ0000ZZ------> [mức độ tốt]
 -20 |                +19
                   |
                   |

Vì vậy, nếu ai đó muốn thực sự gia hạn nhiệm vụ, +19 sẽ mang lại nhiều lợi ích
cú đánh lớn hơn quy tắc tuyến tính thông thường sẽ làm. (Giải pháp của
việc thay đổi ABI để mở rộng mức độ ưu tiên đã bị loại bỏ sớm.)

Cách tiếp cận này có hiệu quả ở một mức độ nào đó trong một thời gian, nhưng sau đó với
HZ=1000, nó khiến 1 giây ngắn ngủi thành 1 mili giây, nghĩa là mức sử dụng CPU là 0,1%, tức là
chúng tôi cảm thấy hơi quá đáng. Quá mức _không_ vì nó quá nhỏ
việc sử dụng CPU, nhưng vì nó gây ra quá thường xuyên (một lần mỗi
mili giây) sắp xếp lại. (và do đó sẽ chuyển bộ nhớ đệm vào thùng rác, v.v. Hãy nhớ rằng,
điều này đã xảy ra từ lâu khi phần cứng còn yếu hơn và bộ nhớ đệm nhỏ hơn, và
mọi người đang chạy các ứng dụng tính toán số ở mức +19.)

Vì vậy, đối với HZ=1000, chúng tôi đã thay đổi từ +19 thành 5 mili giây, vì điều đó giống như
độ chi tiết tối thiểu phù hợp - và điều này có nghĩa là mức sử dụng CPU là 5%.
Nhưng đặc tính nhạy cảm HZ cơ bản của nice+19 vẫn được giữ nguyên,
và chúng tôi chưa bao giờ nhận được một lời phàn nàn nào về việc Nice +19 quá _yếu_ trong
về việc sử dụng CPU, chúng tôi chỉ nhận được khiếu nại về việc nó (vẫn) đang bị
quá _strong_ :-)

Tóm lại: chúng tôi luôn muốn làm cho các cấp độ đẹp nhất quán hơn, nhưng
trong giới hạn của HZ và jiffies cũng như mức độ thiết kế khó chịu của chúng
việc kết hợp với các khoảng thời gian và độ chi tiết không thực sự khả thi.

Khiếu nại thứ hai (ít thường xuyên hơn nhưng vẫn xảy ra định kỳ)
về mức độ hỗ trợ tuyệt vời của Linux là sự bất đối xứng của nó về nguồn gốc
(mà bạn có thể thấy được minh họa trong hình trên), hoặc hơn thế nữa
chính xác: thực tế là hành vi ở mức độ tốt đẹp phụ thuộc vào _absolute_
cũng ở mức độ tốt, trong khi bản thân API đẹp đẽ về cơ bản là
"tương đối":

int Nice(int inc);

asmlinkage dài sys_nice(int tăng)

(cái đầu tiên là glibc API, cái thứ hai là syscall API.)
Lưu ý rằng 'inc' có liên quan đến mức Nice hiện tại. Công cụ như
Lệnh "đẹp" của bash phản chiếu API tương đối này.

Với bộ lập lịch cũ, ví dụ: nếu bạn bắt đầu một tác vụ tốt với +1
và một nhiệm vụ khác có +2, việc phân chia CPU giữa hai nhiệm vụ sẽ
phụ thuộc vào mức Nice của Shell gốc - nếu nó ở mức Nice -10 thì
Sự phân chia CPU khác với khi nó ở mức +5 hoặc +10.

Khiếu nại thứ ba chống lại sự hỗ trợ ở mức độ tốt của Linux là tiêu cực
mức độ tốt không 'đủ mạnh', vì vậy nhiều người đã phải dùng đến
chạy các ứng dụng âm thanh (và đa phương tiện khác) theo mức độ ưu tiên của RT như
SCHED_FIFO. Nhưng điều này gây ra các vấn đề khác: SCHED_FIFO không bị chết đói
bằng chứng và ứng dụng SCHED_FIFO có lỗi cũng có thể khóa hệ thống vĩnh viễn.

Bộ lập lịch mới trong v2.6.23 giải quyết cả ba loại khiếu nại:

Để giải quyết khiếu nại đầu tiên (ở mức độ tốt không phải là "mạnh mẽ"
đủ), bộ lập lịch đã được tách rời khỏi các khái niệm 'lát cắt thời gian' và HZ
(và mức độ chi tiết đã được tạo thành một khái niệm riêng biệt với mức độ tốt đẹp) và do đó
có thể triển khai tốt hơn và nhất quán hơn Nice +19
hỗ trợ: với bộ lập lịch mới, các tác vụ +19 thú vị sẽ có được HZ độc lập
1,5%, thay vì phạm vi biến đổi 3%-5%-9% mà họ có trong phiên bản cũ
lịch trình.

Để giải quyết khiếu nại thứ hai (ở mức độ tốt không nhất quán),
bộ lập lịch mới làm cho Nice(1) có cùng hiệu ứng sử dụng CPU trên
nhiệm vụ, bất kể mức độ tốt đẹp tuyệt đối của họ. Vì vậy trên cái mới
bộ lập lịch, chạy tác vụ Nice +10 và tác vụ Nice 11 có cùng CPU
việc sử dụng "phân chia" giữa chúng khi chạy Nice -5 và Nice -4
nhiệm vụ. (một người sẽ nhận được 55% CPU, người còn lại 45%.) Đó là lý do tại sao tốt
mức độ đã được thay đổi thành "nhân" (hoặc hàm mũ) - theo cách đó
không quan trọng bạn bắt đầu từ cấp độ tốt nào, 'tương đối
result' sẽ luôn giống nhau.

Lời phàn nàn thứ ba (về mức độ tiêu cực tốt đẹp không đủ “mạnh mẽ”
và buộc các ứng dụng âm thanh chạy dưới SCHED_FIFO nguy hiểm hơn
chính sách lập lịch) được giải quyết bởi bộ lập lịch mới gần như
tự động: mức độ tốt đẹp tiêu cực mạnh hơn là tự động
tác dụng phụ của dải động được hiệu chỉnh lại ở các mức tốt.
