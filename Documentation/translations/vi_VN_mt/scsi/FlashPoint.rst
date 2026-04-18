.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/FlashPoint.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Trình điều khiển BusLogic FlashPoint SCSI
=========================================

Bộ điều hợp máy chủ BusLogic FlashPoint SCSI hiện được hỗ trợ đầy đủ trên Linux.
Chương trình nâng cấp được mô tả bên dưới đã chính thức chấm dứt có hiệu lực
31 tháng 3 năm 1997 vì nó không còn cần thiết nữa.

::

MYLEX INTRODUCES LINUX OPERATING SYSTEM SUPPORT FOR ITS
  	      BUSLOGIC FLASHPOINT LINE CỦA SCSI HOST ADAPTERS


FREMONT, CA, -- 8 tháng 10 năm 1996 -- Mylex Corporation đã mở rộng Linux
  hỗ trợ hệ điều hành cho nhãn hiệu BusLogic của FlashPoint Ultra SCSI
  bộ điều hợp máy chủ.  Tất cả các bộ điều hợp máy chủ SCSI khác của BusLogic, bao gồm cả
  Dòng MultiMaster, hiện hỗ trợ hệ điều hành Linux.  Linux
  trình điều khiển và thông tin sẽ có vào ngày 15 tháng 10 tại
  ZZ0000ZZ

Peter Shambora cho biết: "Mylex cam kết hỗ trợ cộng đồng Linux".
  phó chủ tịch tiếp thị của Mylex.  "Chúng tôi đã hỗ trợ trình điều khiển Linux
  phát triển và cung cấp hỗ trợ kỹ thuật cho các bộ điều hợp máy chủ của chúng tôi trong một số
  năm, và rất vui mừng được cung cấp các sản phẩm FlashPoint của chúng tôi cho việc này
  cơ sở người dùng."

Hệ điều hành Linux
==========================

Linux là một triển khai UNIX được phân phối tự do cho Intel x86, Sun
SPARC, SGI MIPS, Motorola 68k, Alpha kỹ thuật số AXP và Motorola PowerPC
máy móc.  Nó hỗ trợ nhiều loại phần mềm, bao gồm cả X Window
Mạng hệ thống, Emacs và TCP/IP.  Thông tin thêm có sẵn tại
ZZ0000ZZ và ZZ0001ZZ

Bộ điều hợp máy chủ FlashPoint
==============================

Dòng bộ điều hợp máy chủ Ultra SCSI FlashPoint, được thiết kế cho máy trạm
và môi trường máy chủ tệp, có sẵn ở kênh hẹp, rộng, kênh đôi,
và các phiên bản rộng kênh đôi.  Các bộ điều hợp này có tính năng SeqEngine
công nghệ tự động hóa, giúp giảm thiểu chi phí lệnh SCSI và giảm
số lượng ngắt được tạo ra cho CPU.

Giới thiệu về Mylex
===================

Mylex Corporation (NASDAQ/NM SYMBOL: MYLX), được thành lập năm 1983, là công ty hàng đầu
nhà sản xuất các sản phẩm công nghệ và quản lý mạng RAID.  Công ty
sản xuất bộ điều khiển mảng đĩa hiệu suất cao (RAID) và bổ sung
sản phẩm máy tính cho máy chủ mạng, hệ thống lưu trữ dung lượng lớn, máy trạm
và các bo mạch hệ thống.  Thông qua nhiều bộ điều khiển RAID và các
Dòng BusLogic của sản phẩm bộ điều hợp máy chủ Ultra SCSI, Mylex cung cấp khả năng kích hoạt
công nghệ I/O thông minh giúp tăng khả năng kiểm soát quản lý mạng,
nâng cao việc sử dụng CPU, tối ưu hóa hiệu suất I/O và đảm bảo bảo mật dữ liệu
và sự sẵn có.  Sản phẩm được bán trên toàn cầu thông qua mạng lưới các OEM,
nhà phân phối chính, VAR và nhà tích hợp hệ thống.  Tập đoàn Mylex là
có trụ sở tại 34551 Ardenwood Blvd., Fremont, CA.

Liên hệ:
========

::

Peter Shambora
  Phó Chủ tịch Tiếp thị
  Tập đoàn Mylex
  510/796-6100
  peters@mylex.com


::

ANNOUNCEMENT
	       Chương trình nâng cấp BusLogic FlashPoint LT/BT-948
			      1 tháng 2 năm 1996

ADDITIONAL ANNOUNCEMENT
	       Chương trình nâng cấp BusLogic FlashPoint LW/BT-958
			       14 tháng 6 năm 1996

Kể từ khi được giới thiệu vào tháng 10 năm ngoái, BusLogic FlashPoint LT đã
  là vấn đề đối với các thành viên của cộng đồng Linux, trong đó không có Linux
  trình điều khiển đã có sẵn cho sản phẩm Ultra SCSI mới này.  Mặc dù nó
  chính thức được định vị là sản phẩm máy trạm để bàn và không bị
  đặc biệt thích hợp cho hoạt động đa nhiệm hiệu suất cao
  hệ thống như Linux, FlashPoint LT đã được hệ thống máy tính chào hàng
  các nhà cung cấp là sản phẩm mới nhất và đã được bán ngay cả trên nhiều sản phẩm cao cấp của họ
  hệ thống cuối, ngoại trừ các sản phẩm MultiMaster cũ hơn.  Cái này có
  gây đau buồn cho nhiều người vô tình mua phải hệ thống với mong muốn
  rằng tất cả các Bộ điều hợp máy chủ BusLogic SCSI đều được Linux hỗ trợ, chỉ để
  phát hiện ra rằng FlashPoint không được hỗ trợ và sẽ không được hỗ trợ lâu dài
  một lúc nào đó, nếu có.

Sau khi xác định được vấn đề này, BusLogic đã liên hệ với OEM chính của mình
  khách hàng để đảm bảo thẻ MultiMaster BT-946C/956C vẫn sẽ hoạt động
  được cung cấp và những người dùng Linux đã đặt hàng nhầm hệ thống với
  FlashPoint có thể nâng cấp lên BT-946C.  Trong khi điều này đã giúp
  nhiều người mua hệ thống mới, nó chỉ là giải pháp một phần cho
  vấn đề chung về hỗ trợ FlashPoint cho người dùng Linux.  Nó không làm gì cả
  hỗ trợ những người ban đầu đã mua FlashPoint để được hỗ trợ
  hệ điều hành và sau đó quyết định chạy Linux hoặc những người đã có
  đã kết thúc với FlashPoint LT vì tin rằng nó được hỗ trợ và không thể
  để trả lại nó.

Giữa tháng 12, tôi xin được gặp cấp trên của BusLogic
  quản lý để thảo luận các vấn đề liên quan đến Linux và hỗ trợ phần mềm miễn phí
  cho FlashPoint.  Tin đồn về độ chính xác khác nhau đã được lan truyền
  công khai về thái độ của BusLogic đối với cộng đồng Linux và tôi cảm thấy
  tốt nhất là những vấn đề này nên được giải quyết trực tiếp.  Tôi đã gửi một email
  nhắn tin sau 11 giờ đêm vào một buổi tối, và cuộc họp diễn ra vào ngày hôm sau
  buổi chiều.  Thật không may, bánh xe của công ty đôi khi bị mài mòn chậm,
  đặc biệt là khi một công ty đang được mua lại, và vì vậy nó được thực hiện cho đến tận bây giờ
  trước khi các chi tiết được xác định hoàn toàn và một tuyên bố công khai có thể
  được thực hiện.

BusLogic chưa được chuẩn bị vào thời điểm này để cung cấp thông tin cần thiết
  cho bên thứ ba viết trình điều khiển cho FlashPoint.  Hiện có duy nhất
  Trình điều khiển FlashPoint được BusLogic Engineering trực tiếp viết và
  không có tài liệu FlashPoint đủ chi tiết để cho phép bên ngoài
  các nhà phát triển viết trình điều khiển mà không cần sự trợ giúp đáng kể.  Trong khi ở đó
  những người ở BusLogic không muốn tiết lộ thông tin chi tiết về
  Kiến trúc FlashPoint nói chung, cuộc tranh luận đó vẫn chưa được giải quyết
  cách.  Trong mọi trường hợp, ngay cả khi tài liệu có sẵn ngày hôm nay thì nó sẽ
  mất khá nhiều thời gian để viết một trình điều khiển có thể sử dụng được, đặc biệt là khi tôi
  không tin rằng nỗ lực cần bỏ ra sẽ đáng giá.

Tuy nhiên, BusLogic vẫn cam kết cung cấp hiệu suất cao
  Giải pháp SCSI dành cho cộng đồng Linux và không muốn thấy ai còn sót lại
  không thể chạy Linux vì họ có Flashpoint LT.  Vì vậy, BusLogic
  đã đưa ra một chương trình nâng cấp trực tiếp để cho phép bất kỳ người dùng Linux nào trên toàn thế giới
  để đổi FlashPoint LT của họ lấy BT-948 MultiMaster PCI Ultra mới
  Bộ điều hợp máy chủ SCSI.  BT-948 là sản phẩm kế thừa Ultra SCSI của BT-946C
  và có tất cả các tính năng tốt nhất của cả BT-946C và FlashPoint LT,
  bao gồm chấm dứt thông minh và đèn flash PROM để cập nhật chương trình cơ sở dễ dàng và
  tất nhiên là tương thích với trình điều khiển Linux hiện tại.  Giá cho việc này
  nâng cấp đã được ấn định ở mức 45 USD cộng với chi phí vận chuyển và xử lý, và nâng cấp
  chương trình sẽ được quản lý thông qua Hỗ trợ Kỹ thuật BusLogic, có thể
  có thể liên hệ bằng thư điện tử tại techsup@buslogic.com, bằng Thoại theo số +1 408
  654-0760 hoặc qua FAX theo số +1 408 492-1542.

Kể từ ngày 14 tháng 6 năm 1996, bản nâng cấp BusLogic FlashPoint LT ban đầu lên BT-948
  chương trình hiện đã được mở rộng để bao gồm FlashPoint LW Wide Ultra
  Bộ điều hợp máy chủ SCSI.  Bất kỳ người dùng Linux nào trên toàn thế giới đều có thể giao dịch bằng FlashPoint của họ
  LW (BT-950) dành cho Bộ điều hợp máy chủ BT-958 MultiMaster PCI Ultra SCSI.  các
  giá cho bản nâng cấp này đã được ấn định ở mức 65 USD cộng với phí vận chuyển và xử lý.

Tôi là trang web thử nghiệm beta cho BT-948/958 và các phiên bản 1.2.1 và 1.3.1 của
  trình điều khiển BusLogic của tôi đã bao gồm hỗ trợ tiềm ẩn cho BT-948/958.
  Hỗ trợ thẩm mỹ bổ sung cho thẻ MultiMaster Ultra SCSI đã được thêm vào
  các bản phát hành tiếp theo.  Là kết quả của quá trình thử nghiệm hợp tác này,
  một số lỗi phần mềm đã được tìm thấy và sửa chữa.  Linux tải nặng của tôi
  hệ thống kiểm tra cung cấp một môi trường lý tưởng để phục hồi lỗi kiểm tra
  các quy trình hiếm khi được thực hiện trong các hệ thống sản xuất, nhưng
  quan trọng đối với sự ổn định chung của hệ thống.  Nó đặc biệt thuận tiện
  có thể làm việc trực tiếp với kỹ sư phần mềm của họ trong việc chứng minh
  các vấn đề dưới sự kiểm soát của môi trường gỡ lỗi phần sụn; nhiều thứ
  chắc chắn tôi đã đi được một chặng đường dài kể từ lần cuối cùng tôi làm việc trên phần mềm cơ sở cho một
  hệ thống nhúng.  Tôi hiện đang thực hiện một số thử nghiệm hiệu suất và
  hy vọng sẽ có một số dữ liệu để báo cáo trong tương lai không xa.

BusLogic đã yêu cầu tôi gửi thông báo này vì phần lớn
  các câu hỏi liên quan đến hỗ trợ cho FlashPoint đã được gửi cho tôi
  trực tiếp qua email hoặc đã xuất hiện trong các nhóm tin Linux mà tôi
  tham gia.  Tóm lại, BusLogic đang cung cấp cho người dùng Linux bản nâng cấp
  từ FlashPoint LT (BT-930) không được hỗ trợ đến BT-948 được hỗ trợ cho Hoa Kỳ
  $45 cộng phí vận chuyển và xử lý hoặc từ FlashPoint LW không được hỗ trợ
  (BT-950) sang BT-958 được hỗ trợ với giá 65 USD cộng phí vận chuyển và xử lý.
  Liên hệ với bộ phận Hỗ trợ Kỹ thuật của BusLogic tại techsup@buslogic.com hoặc +1 408
  654-0760 để tận dụng ưu đãi của họ.

Leonard N. Zubkoff
  		lnz@dandelion.com