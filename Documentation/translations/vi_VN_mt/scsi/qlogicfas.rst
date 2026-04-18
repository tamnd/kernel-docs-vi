.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/qlogicfas.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Ghi chú về trình điều khiển dòng Qlogic FASXXX
=================================

Trình điều khiển này hỗ trợ dòng chip Qlogic FASXXX.  Người lái xe này
chỉ hoạt động với các phiên bản ISA, VLB và PCMCIA của Qlogic
NhanhSCSI!  cũng như bất kỳ thẻ nào khác dựa trên chip FASXX
(bao gồm các thẻ Khái niệm điều khiển SCSI/IDE/SIO/PIO/FDC).

Trình điều khiển này NOT hỗ trợ phiên bản PCI.  Hỗ trợ cho các PCI này
Bảng Qlogic:

* IQ-PCI
	* IQ-PCI-10
	* IQ-PCI-D

được cung cấp bởi trình điều khiển qla1280.

Nó cũng không hỗ trợ PCI-Basic, được hỗ trợ bởi
Trình điều khiển 'am53c974'.

Hỗ trợ PCMCIA
==============

Điều này hiện chỉ hoạt động nếu thẻ được kích hoạt trước từ DOS.  Cái này
có nghĩa là bạn sẽ phải tải các dịch vụ ổ cắm và thẻ của mình, và
QL41DOS.SYS và QL40ENBL.SYS.  Đây là mức tối thiểu, nhưng việc tải
phần còn lại của các mô-đun sẽ không can thiệp vào hoạt động.  Tiếp theo
điều cần làm là tải kernel mà không cần thiết lập lại phần cứng, điều này
có thể là một thao tác ctrl-alt-delete đơn giản bằng đĩa mềm khởi động hoặc bằng cách sử dụng
Loadlin với hình ảnh hạt nhân có thể truy cập được từ DOS.  Nếu bạn đang sử dụng
trình điều khiển Linux PCMCIA, bạn sẽ phải điều chỉnh nó hoặc dừng lại
nó từ việc cấu hình thẻ.

Tôi đang làm việc với nhóm PCMCIA để làm cho nó linh hoạt hơn, nhưng điều đó
có thể mất một thời gian.

Tất cả các thẻ
=========

Phần trên cùng của tệp qlogic.c có một số định nghĩa điều khiển
cấu hình.  Khi vận chuyển, nó cung cấp sự cân bằng giữa tốc độ và
chức năng.  Nếu có bất kỳ vấn đề nào, hãy thử đặt SLOW_CABLE thành 1 và
sau đó thử thay đổi USE_IRQ và TURBO_PDMA thành 0.  Nếu bạn quen
với SCSI, có các cài đặt khác có thể điều chỉnh bus.

Có thể nên kích hoạt RESET_AT_START, đặc biệt nếu
các thiết bị có thể chưa được cấp nguồn hoặc nếu bạn đang khởi động lại
sau một vụ tai nạn, vì họ có thể đang bận cố gắng hoàn thành việc cuối cùng
lệnh hay gì đó.  Nó xuất hiện nhanh hơn nếu giá trị này được đặt thành 0 và
nếu bạn có phần cứng và kết nối đáng tin cậy, nó có thể hữu ích hơn khi
không thiết lập lại mọi thứ.

Một số mẹo khắc phục sự cố
=========================

Đảm bảo nó hoạt động bình thường dưới DOS.  Bạn cũng nên thực hiện FDISK ban đầu
trên một ổ đĩa mới nếu bạn muốn phân vùng.

Trước tiên, đừng kích hoạt tất cả các tính năng tăng tốc.  Nếu có gì sai sót, họ sẽ thực hiện
bất kỳ vấn đề tồi tệ hơn.

Quan trọng
=========

Cách tốt nhất để kiểm tra xem cáp, đầu cuối, v.v. của bạn có tốt hay không là
sao chép một tệp rất lớn (ví dụ: tệp chứa khoảng cách kép hoặc tệp rất
tệp thực thi hoặc kho lưu trữ lớn).  Nó phải có ít nhất 5 megabyte, nhưng
bạn có thể thực hiện nhiều bài kiểm tra trên các tệp nhỏ hơn.  Sau đó thực hiện COMP để xác minh
rằng tập tin đã được sao chép đúng cách.  (Tắt tất cả bộ nhớ đệm khi thực hiện các thao tác này
kiểm tra, nếu không bạn sẽ kiểm tra RAM của mình chứ không phải các tệp).  Sau đó làm
10 COMP, so sánh cùng một tệp trên ổ cứng SCSI, tức là "COMP
realbig.doc realbig.doc".  Sau đó thực hiện sau khi máy tính ấm lên.

Tôi nhận thấy hệ thống của tôi dường như hoạt động 100% nhưng sẽ thất bại trong bài kiểm tra này nếu
máy tính đã được bật trong vài giờ.  Nó còn tệ hơn nữa
cáp và nhiều thiết bị khác trên bus SCSI.  Điều dường như xảy ra là
rằng nó nhận được một ACK sai khiến cho một byte bổ sung được chèn vào
luồng (và điều này không được phát hiện).  Điều này có thể được gây ra bởi xấu
chấm dứt (ACK có thể được phản xạ) hoặc do nhiễu khi chip
hoạt động kém hiệu quả do sức nóng hoặc khi dây cáp quá dài
tốc độ.

Hãy nhớ rằng, nếu nó không hoạt động theo DOS, có thể nó sẽ không hoạt động theo
Linux.