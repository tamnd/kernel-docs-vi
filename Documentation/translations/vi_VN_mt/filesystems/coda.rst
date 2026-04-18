.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/coda.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Giao diện hạt nhân Coda-Venus
===========================

.. Note::

   This is one of the technical documents describing a component of
   Coda -- this document describes the client kernel-Venus interface.

Để biết thêm thông tin:

ZZ0000ZZ

Đối với phần mềm cấp người dùng cần thiết để chạy Coda:

ftp://ftp.coda.cs.cmu.edu

Để chạy Coda, bạn cần có trình quản lý bộ đệm cấp người dùng cho máy khách,
có tên Venus, cũng như các công cụ để thao tác ACL, đăng nhập, v.v.
khách hàng cần phải chọn hệ thống tập tin Coda trong kernel
cấu hình.

Máy chủ cần một máy chủ cấp độ người dùng và hiện tại không phụ thuộc vào
hỗ trợ hạt nhân.

Giao diện hạt nhân Venus

Peter J. Braam

v1.0, ngày 9 tháng 11 năm 1997

Tài liệu này mô tả sự giao tiếp giữa Venus và kernel
  mã hệ thống tập tin cấp độ cần thiết cho hoạt động của hệ thống tập tin Coda-
  tem.  Phiên bản tài liệu này nhằm mô tả giao diện hiện tại
  (phiên bản 1.0) cũng như những cải tiến mà chúng tôi dự tính.

.. Table of Contents

  1. Introduction

  2. Servicing Coda filesystem calls

  3. The message layer

     3.1 Implementation details

  4. The interface at the call level

     4.1 Data structures shared by the kernel and Venus
     4.2 The pioctl interface
     4.3 root
     4.4 lookup
     4.5 getattr
     4.6 setattr
     4.7 access
     4.8 create
     4.9 mkdir
     4.10 link
     4.11 symlink
     4.12 remove
     4.13 rmdir
     4.14 readlink
     4.15 open
     4.16 close
     4.17 ioctl
     4.18 rename
     4.19 readdir
     4.20 vget
     4.21 fsync
     4.22 inactive
     4.23 rdwr
     4.24 odymount
     4.25 ody_lookup
     4.26 ody_expand
     4.27 prefetch
     4.28 signal

  5. The minicache and downcalls

     5.1 INVALIDATE
     5.2 FLUSH
     5.3 PURGEUSER
     5.4 ZAPFILE
     5.5 ZAPDIR
     5.6 ZAPVNODE
     5.7 PURGEFID
     5.8 REPLACE

  6. Initialization and cleanup

     6.1 Requirements

1. Giới thiệu
===============

Thành phần chính trong Hệ thống tệp phân tán Coda là bộ đệm
  quản lý, Venus.

Khi các quy trình trên hệ thống hỗ trợ Coda truy cập các tệp trong Coda
  hệ thống tập tin, các yêu cầu được hướng tới lớp hệ thống tập tin trong
  hệ điều hành. Hệ điều hành sẽ giao tiếp với sao Kim để
  phục vụ yêu cầu của tiến trình.  Venus quản lý một cách kiên trì
  bộ nhớ đệm của máy khách và thực hiện các cuộc gọi thủ tục từ xa đến máy chủ tệp Coda và
  các máy chủ liên quan (chẳng hạn như máy chủ xác thực) để phục vụ các máy chủ này
  yêu cầu nó nhận được từ hệ điều hành.  Khi sao Kim có
  phục vụ một yêu cầu, nó trả lời hệ điều hành bằng các thông tin thích hợp
  mã trả lại và các dữ liệu khác liên quan đến yêu cầu.  Tùy chọn
  hỗ trợ kernel cho Coda có thể duy trì một bộ đệm nhỏ của các dữ liệu được xử lý gần đây
  yêu cầu hạn chế số lượng tương tác với sao Kim.  Sao Kim
  sở hữu khả năng thông báo cho hạt nhân khi các phần tử từ nó
  minicache không còn hợp lệ.

Tài liệu này mô tả chính xác sự giao tiếp giữa
  hạt nhân và sao Kim.  Các định nghĩa của cái gọi là upcalls và downcalls
  sẽ được cung cấp cùng với định dạng của dữ liệu mà họ xử lý. Chúng ta cũng sẽ
  mô tả các bất biến ngữ nghĩa phát sinh từ các cuộc gọi.

Về mặt lịch sử, Coda được triển khai trong hệ thống tệp BSD ở Mach 2.6.
  Giao diện giữa kernel và Venus rất giống với BSD
  Giao diện VFS.  Chức năng tương tự được cung cấp và định dạng của
  các tham số và dữ liệu trả về rất giống với BSD VFS.  Cái này
  dẫn đến một môi trường gần như tự nhiên để triển khai cấp độ hạt nhân
  trình điều khiển hệ thống tập tin cho Coda trong hệ thống BSD.  Tuy nhiên, hoạt động khác
  các hệ thống như Linux và Windows 95 và NT có hệ thống tệp ảo
  với các giao diện khác nhau.

Để triển khai Coda trên các hệ thống này, một số kỹ thuật đảo ngược của
  Giao thức Venus/Kernel là cần thiết.  Ngoài ra, nó cũng được đưa ra ánh sáng
  hệ thống có thể thu được lợi nhuận đáng kể từ một số tối ưu hóa nhỏ nhất định
  và sửa đổi giao thức. Để thuận tiện cho công việc này cũng như
  để làm cho các bến cảng trong tương lai trở nên dễ dàng hơn, việc liên lạc giữa Sao Kim và
  kernel nên được ghi lại rất chi tiết.  Đây là mục đích của việc này
  tài liệu.

2. Phục vụ các cuộc gọi hệ thống tập tin Coda
===================================

Dịch vụ yêu cầu dịch vụ hệ thống tệp Coda bắt nguồn từ
  một quá trình P truy cập vào tệp Coda. Nó thực hiện một cuộc gọi hệ thống
  bẫy vào nhân hệ điều hành. Ví dụ về các cuộc gọi như vậy bẫy vào kernel
  là ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ,
  ZZ0006ZZ, ZZ0007ZZ trong bối cảnh Unix.  Các cuộc gọi tương tự tồn tại trong Win32
  môi trường và được đặt tên là ZZ0008ZZ.

Nói chung hệ điều hành xử lý yêu cầu trong môi trường ảo
  lớp hệ thống tập tin (VFS), được đặt tên là Trình quản lý I/O trong NT và IFS
  quản lý trong Windows 95. VFS chịu trách nhiệm xử lý một phần
  của yêu cầu và để định vị (các) hệ thống tệp cụ thể sẽ
  phần dịch vụ của yêu cầu.  Thông thường thông tin trong đường dẫn
  hỗ trợ trong việc định vị các trình điều khiển FS chính xác.  Đôi khi sau khi mở rộng
  tiền xử lý, VFS bắt đầu gọi các quy trình đã xuất trong FS
  người lái xe.  Đây là điểm mà quá trình xử lý cụ thể của FS của
  yêu cầu bắt đầu và ở đây mã hạt nhân cụ thể của Coda xuất hiện
  chơi.

Lớp FS cho Coda phải hiển thị và triển khai một số giao diện.
  Đầu tiên và quan trọng nhất VFS phải có khả năng thực hiện tất cả các cuộc gọi cần thiết tới
  lớp Coda FS, do đó trình điều khiển Coda FS phải hiển thị giao diện VFS
  như được áp dụng trong hệ điều hành. Những điều này khác nhau rất đáng kể
  giữa các hệ điều hành nhưng chia sẻ các tính năng như cơ sở vật chất để
  đọc/ghi, tạo và xóa các đối tượng.  Các dịch vụ lớp Coda FS
  các yêu cầu VFS như vậy bằng cách gọi một hoặc nhiều dịch vụ được xác định rõ ràng
  được cung cấp bởi trình quản lý bộ đệm Venus.  Khi câu trả lời từ Venus có
  quay lại trình điều khiển FS, việc phục vụ cuộc gọi VFS vẫn tiếp tục và
  kết thúc bằng việc trả lời VFS của kernel. Cuối cùng là lớp VFS
  quay trở lại quá trình.

Kết quả của thiết kế này là giao diện cơ bản được cung cấp bởi trình điều khiển FS
  phải cho phép Venus quản lý lưu lượng tin nhắn.  Đặc biệt sao Kim phải
  có thể truy xuất và đặt tin nhắn và được thông báo về
  sự xuất hiện của một tin nhắn mới. Việc thông báo phải thông qua cơ chế
  không cản trở Sao Kim vì Sao Kim thậm chí còn phải tham gia các nhiệm vụ khác
  khi không có tin nhắn nào đang chờ hoặc đang được xử lý.

ZZ0000ZZ

Hơn nữa, lớp FS cung cấp một đường truyền thông đặc biệt
  giữa tiến trình người dùng và Venus, được gọi là giao diện pioctl. các
  Giao diện pioctl được sử dụng cho các dịch vụ cụ thể của Coda, chẳng hạn như
  yêu cầu thông tin chi tiết về bộ nhớ đệm liên tục được quản lý bởi
  Sao Kim. Ở đây sự tham gia của kernel là tối thiểu.  Nó xác định
  quá trình gọi điện và chuyển thông tin tới Sao Kim.  Khi nào
  Venus trả lời, phản hồi sẽ được chuyển lại cho người gọi ở dạng chưa sửa đổi
  hình thức.

Cuối cùng, Venus cho phép trình điều khiển kernel FS lưu vào bộ đệm các kết quả từ
  một số dịch vụ nhất định.  Điều này được thực hiện để tránh chuyển đổi ngữ cảnh quá mức
  và tạo ra một hệ thống hiệu quả.  Tuy nhiên, sao Kim có thể có được
  thông tin, ví dụ từ mạng ngụ ý rằng được lưu trong bộ nhớ đệm
  thông tin phải được xóa hoặc thay thế. Venus sau đó thực hiện một cuộc gọi xuống
  đến lớp Coda FS để yêu cầu xóa hoặc cập nhật trong bộ đệm.  các
  trình điều khiển kernel FS xử lý các yêu cầu đó một cách đồng bộ.

Trong số các giao diện này, giao diện VFS và phương tiện để đặt,
  nhận và được thông báo về tin nhắn là nền tảng cụ thể.  chúng tôi sẽ
  không tham gia các cuộc gọi được xuất sang lớp VFS nhưng chúng tôi sẽ nêu rõ
  yêu cầu của cơ chế trao đổi thông điệp.


3. Lớp thông điệp
=====================

Ở mức thấp nhất, giao tiếp giữa Venus và trình điều khiển FS
  tiến hành thông qua tin nhắn.  Sự đồng bộ giữa các tiến trình
  yêu cầu dịch vụ tệp Coda và Venus dựa vào việc chặn và đánh thức
  lên các quá trình.  Trình điều khiển Coda FS xử lý các yêu cầu VFS- và pioctl
  thay mặt cho tiến trình P, tạo tin nhắn cho Sao Kim, chờ phản hồi
  và cuối cùng trả về cho người gọi.  Việc thực hiện trao đổi
  của tin nhắn là nền tảng cụ thể, nhưng ngữ nghĩa có (cho đến nay)
  dường như có thể áp dụng được một cách tổng quát.  Bộ đệm dữ liệu được tạo bởi
  Trình điều khiển FS trong bộ nhớ kernel thay mặt cho P và sao chép vào bộ nhớ người dùng trong
  Sao Kim.

Trình điều khiển FS trong khi phục vụ P thực hiện các cuộc gọi tới Venus.  Như vậy
  upcall được gửi đến sao Kim bằng cách tạo cấu trúc tin nhắn.  các
  cấu trúc chứa mã nhận dạng P, chuỗi thông báo
  số, kích thước của yêu cầu và một con trỏ tới dữ liệu trong kernel
  bộ nhớ cho yêu cầu.  Vì bộ đệm dữ liệu được sử dụng lại để lưu giữ
  trả lời từ Venus, có một trường dành cho kích thước của câu trả lời.  Một lá cờ
  trường được sử dụng trong tin nhắn để ghi lại chính xác trạng thái của
  tin nhắn.  Các cấu trúc phụ thuộc nền tảng bổ sung liên quan đến các con trỏ tới
  xác định vị trí của tin nhắn trên hàng đợi và con trỏ tới
  các đối tượng đồng bộ hóa  Trong quy trình upcall, cấu trúc tin nhắn
  được điền vào, các cờ được đặt thành 0 và nó được đặt trên ZZ0000ZZ
  xếp hàng.  Cuộc gọi upcall thường lệ có trách nhiệm phân bổ
  bộ đệm dữ liệu; cấu trúc của nó sẽ được mô tả trong phần tiếp theo.

Phải tồn tại một cơ sở để thông báo cho Venus rằng tin nhắn đã được
  được tạo và triển khai bằng cách sử dụng các đối tượng đồng bộ hóa có sẵn trong
  hệ điều hành. Thông báo này được thực hiện trong bối cảnh upcall của quá trình
  P. Khi tin nhắn nằm trong hàng chờ xử lý, quá trình P không thể tiếp tục
  trong cuộc gọi nâng cao.  Quá trình xử lý (chế độ hạt nhân) của P trong hệ thống tập tin
  quy trình yêu cầu phải bị tạm dừng cho đến khi Venus trả lời.  Vì thế
  chuỗi cuộc gọi trong P bị chặn trong upcall.  Một con trỏ trong
  Cấu trúc thông báo sẽ định vị đối tượng đồng bộ hóa mà P được đặt trên đó.
  đang ngủ.

Venus phát hiện thông báo rằng có tin nhắn đã đến và FS
  trình điều khiển cho phép Venus truy xuất tin nhắn bằng getmsg_from_kernel
  gọi. Hành động này kết thúc trong kernel bằng cách đặt thông báo vào
  hàng đợi xử lý tin nhắn và đặt cờ thành READ.  Sao Kim là
  đã chuyển nội dung của bộ đệm dữ liệu. Cuộc gọi getmsg_from_kernel
  bây giờ quay trở lại và Venus xử lý yêu cầu.

Tại một thời điểm nào đó, trình điều khiển FS nhận được tin nhắn từ Venus,
  cụ thể là khi Venus gọi sendmsg_to_kernel.  Tại thời điểm này Coda FS
  người lái xe xem nội dung tin nhắn và quyết định xem:


* tin nhắn là câu trả lời cho một chủ đề bị treo P. Nếu vậy nó sẽ xóa
     tin nhắn từ hàng đợi xử lý và đánh dấu tin nhắn là
     WRITTEN.  Cuối cùng, trình điều khiển FS bỏ chặn P (vẫn còn trong kernel
     bối cảnh chế độ của Sao Kim) và lệnh gọi sendmsg_to_kernel quay trở lại
     Sao Kim.  Quá trình P sẽ được lên lịch tại một thời điểm nào đó và tiếp tục
     xử lý cuộc gọi lên của nó bằng bộ đệm dữ liệu được thay thế bằng câu trả lời
     từ sao Kim.

* Tin nhắn là ZZ0000ZZ.  Một cuộc gọi xuống là một yêu cầu từ Venus tới
     Trình điều khiển FS. Trình điều khiển FS xử lý yêu cầu ngay lập tức
     (thường là xóa hoặc thay thế bộ đệm) và khi quá trình này kết thúc
     sendmsg_to_kernel trả về.

Lúc này P đã tỉnh dậy và tiếp tục xử lý cuộc gọi lên.  Có một số
  sự tinh tế cần tính đến. P đầu tiên sẽ xác định xem nó đã được đánh thức chưa
  nâng cấp bằng tín hiệu từ một số nguồn khác (ví dụ:
  cố gắng chấm dứt P) hoặc như trường hợp thông thường của sao Kim trong
  cuộc gọi sendmsg_to_kernel.  Trong trường hợp bình thường, thủ tục upcall sẽ
  giải phóng cấu trúc tin nhắn và trả lại.  Quy trình FS có thể tiếp tục
  với quá trình xử lý của nó.


ZZ0000ZZ

Trong trường hợp P bị đánh thức bởi một tín hiệu chứ không phải bởi sao Kim, trước tiên nó sẽ xem xét
  tại sân cờ.  Nếu thông báo chưa phải là READ thì quá trình P có thể
  xử lý tín hiệu của nó mà không thông báo cho sao Kim.  Nếu sao Kim có READ, và
  yêu cầu không được xử lý, P có thể gửi cho Venus một tin nhắn tín hiệu
  để chỉ ra rằng nó nên bỏ qua tin nhắn trước đó.  Như vậy
  các tín hiệu được xếp vào hàng đợi ở đầu và được sao Kim đọc đầu tiên.  Nếu
  tin nhắn đã được đánh dấu là WRITTEN, đã quá muộn để dừng
  xử lý.  Quy trình VFS bây giờ sẽ tiếp tục.  (-- Nếu yêu cầu VFS
  liên quan đến nhiều lệnh gọi nâng cấp, điều này có thể dẫn đến trạng thái phức tạp,
  trường bổ sung "handle_signals" có thể được thêm vào cấu trúc tin nhắn
  để chỉ ra các điểm không thể quay lại đã được thông qua.--)



3.1.  Chi tiết triển khai
----------------------------

Việc triển khai Unix cơ chế này đã được thực hiện thông qua
  triển khai một thiết bị ký tự liên kết với Coda.  Sao Kim
  truy xuất tin nhắn bằng cách đọc trên thiết bị, trả lời sẽ được gửi
  bằng cách ghi và thông báo thông qua lệnh gọi hệ thống được chọn trên
  mô tả tập tin cho thiết bị.  Quá trình P được giữ chờ trên một
  đối tượng hàng đợi chờ bị gián đoạn.

Trong Windows NT và DPMI Windows 95 triển khai DeviceIoControl
  cuộc gọi được sử dụng.  Cuộc gọi DeviceIoControl được thiết kế để sao chép bộ đệm
  từ bộ nhớ người dùng đến bộ nhớ kernel với OPCODES. sendmsg_to_kernel
  được thực hiện dưới dạng cuộc gọi đồng bộ, trong khi cuộc gọi getmsg_from_kernel là
  không đồng bộ.  Windows EventObjects được sử dụng để thông báo về
  tin nhắn đến.  Quá trình P được tiếp tục chờ đợi trên KernelEvent
  object trong NT và semaphore trong Windows 95.


4. Giao diện ở cấp độ cuộc gọi
===================================


Phần này mô tả các yêu cầu nâng cấp mà trình điều khiển Coda FS có thể thực hiện đối với Venus.
  Mỗi lệnh gọi nâng cao này sử dụng hai cấu trúc: inputArgs và
  đầu raArgs.   Ở dạng giả BNF, các cấu trúc có dạng sau
  hình thức::


cấu trúc đầu vàoArgs {
	    u_mã dài;
	    u_dài độc đáo;     /* Phân biệt nhiều tin nhắn chưa được xử lý */
	    u_pid ngắn;                 /* Chung cho tất cả */
	    u_pgid ngắn;                /* Chung cho tất cả */
	    cấu trúc tín dụng CodaCred;        /* Chung cho tất cả */

<kết hợp "trong" các phần phụ thuộc cuộc gọi của inputArgs>
	};

cấu trúc đầu raArgs {
	    u_mã dài;
	    u_dài độc đáo;       /* Phân biệt nhiều tin nhắn chưa được xử lý */
	    u_kết quả dài;

<kết hợp "ra" các phần phụ thuộc cuộc gọi của inputArgs>
	};



Trước khi tiếp tục, chúng ta hãy làm rõ vai trò của các lĩnh vực khác nhau. các
  inputArgs bắt đầu bằng opcode xác định loại dịch vụ
  được yêu cầu từ sao Kim. Hiện tại có khoảng 30 cuộc gọi lên
  mà chúng ta sẽ thảo luận.   Trường duy nhất gắn nhãn inputArg bằng một
  số duy nhất sẽ xác định tin nhắn một cách duy nhất.  Một quá trình và
  id nhóm quy trình được thông qua.  Cuối cùng thông tin xác thực của người gọi
  được bao gồm.

Trước khi đi sâu vào các cuộc gọi cụ thể, chúng ta cần thảo luận về nhiều vấn đề khác nhau.
  cấu trúc dữ liệu được chia sẻ bởi kernel và Venus.




4.1.  Cấu trúc dữ liệu được chia sẻ bởi kernel và Venus
----------------------------------------------------


Cấu trúc CodaCred xác định nhiều loại id người dùng và nhóm như
  chúng được thiết lập cho quá trình gọi điện. vuid_t và vgid_t là 32 bit
  số nguyên không dấu.  Nó cũng xác định tư cách thành viên nhóm trong một mảng.  Bật
  Unix CodaCred đã được chứng minh là đủ để triển khai bảo mật tốt
  ngữ nghĩa cho Coda nhưng cấu trúc có thể phải sửa đổi
  dành cho môi trường Windows khi chúng trưởng thành::

cấu trúc CodaCred {
	    vuid_t cr_uid, cr_euid, cr_suid, cr_fsuid; /* Thực tế, hiệu quả, thiết lập, fs uid */
	    vgid_t cr_gid, cr_egid, cr_sgid, cr_fsgid; /*tương tự cho các nhóm */
	    vgid_t cr_groups[NGROUPS];        /* Tư cách thành viên nhóm cho người gọi */
	};


  .. Note::

     It is questionable if we need CodaCreds in Venus. Finally Venus
     doesn't know about groups, although it does create files with the
     default uid/gid.  Perhaps the list of group membership is superfluous.


Mục tiếp theo là mã định danh cơ bản được sử dụng để xác định Coda
  các tập tin, ViceFid.  Một fi của một tệp xác định duy nhất một tệp hoặc
  thư mục trong hệ thống tập tin Coda trong một ô [1]_::

cấu trúc typedef ViceFid {
	    VolumeId Khối lượng;
	    VnodeId Vnode;
	    Unique_t Duy nhất;
	} ViceFid;

  .. [1] A cell is agroup of Coda servers acting under the aegis of a single
máy điều khiển hệ thống hoặc SCM. Xem hướng dẫn quản trị Coda
	 để biết mô tả chi tiết về vai trò của SCM.

Mỗi trường cấu thành: VolumeId, VnodeId và Unique_t là
  số nguyên 32 bit không dấu.  Chúng tôi dự tính rằng một lĩnh vực khác sẽ cần
  được đặt tiền tố để xác định ô Coda; điều này có thể sẽ mất
  dạng địa chỉ IP kích thước Ipv6 đặt tên cho ô Coda thông qua DNS.

Cấu trúc quan trọng tiếp theo được chia sẻ giữa Sao Kim và hạt nhân là
  các thuộc tính của tập tin.  Cấu trúc sau đây được sử dụng để
  trao đổi thông tin.  Nó có chỗ cho các phần mở rộng trong tương lai như
  hỗ trợ cho các tập tin thiết bị (hiện không có trong Coda)::


cấu trúc coda_timespec {
		int64_t tv_sec;         /* giây */
		tv_nsec dài;        /* nano giây */
	};

cấu trúc coda_vattr {
		enum coda_vtype va_type;        /* Loại vnode (để tạo) */
		u_short va_mode;        /* kiểu truy cập và gõ tập tin */
		va_nlink ngắn;       /*số lượng tham chiếu tới file */
		vuid_t và_uid;         /* id người dùng chủ sở hữu */
		vgid_t và_gid;         /* id nhóm chủ sở hữu */
		va_fsid dài;        /* id hệ thống tập tin (hiện tại là nhà phát triển) */
		va_fileid dài;      /* id tập tin */
		u_quad_t và_size;        /* kích thước file tính bằng byte */
		va_blocksize dài;   /* kích thước khối được ưu tiên cho i/o */
		struct coda_timespec va_atime;  /*thời điểm truy cập lần cuối*/
		struct coda_timespec va_mtime;  /*thời điểm sửa đổi lần cuối */
		struct coda_timespec va_ctime;  /*tập tin thời gian đã thay đổi */
		u_long và_gen;         /* số thứ tự tạo file */
		u_long và_flags;       /* các cờ được định nghĩa cho tập tin */
		dev_t và_rdev;        /* Tệp đặc biệt của thiết bị đại diện cho */
		u_quad_t va_bytes;       /* byte dung lượng ổ đĩa được giữ bởi tệp */
		u_quad_t và_filerev;     /* số sửa đổi tập tin */
		u_int va_vaflags;     /* cờ hoạt động, xem bên dưới */
		dài va_spare;       /* vẫn giữ nguyên tư thế thẳng hàng */
	};


4.2.  Giao diện pioctl
--------------------------


Các yêu cầu cụ thể của Coda có thể được ứng dụng thực hiện thông qua pioctl
  giao diện. Pioctl được triển khai như một ioctl thông thường trên một
  tệp hư cấu /coda/.CONTROL.  Cuộc gọi pioctl sẽ mở tệp này, nhận
  một trình xử lý tệp và thực hiện cuộc gọi ioctl. Cuối cùng nó đóng tập tin.

Sự tham gia của hạt nhân vào việc này chỉ giới hạn ở việc cung cấp phương tiện để
  mở, đóng và chuyển thông báo ioctl cũng như xác minh rằng đường dẫn trong
  bộ đệm dữ liệu pioctl là một tệp trong hệ thống tệp Coda.

Hạt nhân được trao một gói dữ liệu có dạng ::

cấu trúc {
	    const char *đường dẫn;
	    struct ViceIoctl vidata;
	    int theo dõi;
	} dữ liệu;



Ở đâu::


cấu trúc ViceIoctl {
		caddr_t vào, ra;        /* Dữ liệu được truyền vào hoặc ra */
		in_size ngắn;          /* Kích thước bộ đệm đầu vào <= 2K */
		out_size ngắn;         /* Kích thước tối đa của bộ đệm đầu ra, <= 2K */
	};



Đường dẫn phải là tệp Coda, nếu không lệnh gọi lên ioctl sẽ không được
  thực hiện.

  .. Note:: The data structures and code are a mess.  We need to clean this up.


ZZ0000ZZ:


4.3.  gốc
----------


Đối số
     trong

trống

ngoài::

cấu trúc cfs_root_out {
		    ViceFid VFid;
		} cfs_root;



Mô tả
    Cuộc gọi này được thực hiện tới Sao Kim trong quá trình khởi tạo
    hệ thống tập tin Coda. Nếu kết quả bằng 0 thì cấu trúc cfs_root
    chứa ViceFid của thư mục gốc của hệ thống tập tin Coda. Nếu khác không
    kết quả được tạo ra, giá trị của nó là mã lỗi phụ thuộc vào nền tảng
    cho thấy khó khăn mà sao Kim gặp phải trong việc xác định nguồn gốc của
    hệ thống tập tin Coda.

4.4.  tra cứu
------------


Tóm tắt
    Tìm ViceFid và nhập đối tượng vào thư mục nếu nó tồn tại.

Đối số
     trong::

cấu trúc cfs_lookup_in {
		    ViceFid VFid;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_lookup;



ngoài::

cấu trúc cfs_lookup_out {
		    ViceFid VFid;
		    int vtype;
		} cfs_lookup;



Mô tả
    Cuộc gọi này được thực hiện để xác định ViceFid và kiểu tệp của
    một mục nhập thư mục.  Mục thư mục được yêu cầu mang tên 'name'
    và Venus sẽ tìm kiếm thư mục được xác định bởi cfs_lookup_in.VFid.
    Kết quả có thể chỉ ra rằng tên đó không tồn tại hoặc
    gặp khó khăn trong việc tìm kiếm nó (ví dụ: do mất kết nối).
    Nếu kết quả bằng 0, trường cfs_lookup_out.VFid chứa
    nhắm mục tiêu ViceFid và cfs_lookup_out.vtype coda_vtype đưa ra
    loại đối tượng mà tên chỉ định.

Tên của đối tượng là chuỗi ký tự 8 bit có độ dài tối đa
  CFS_MAXNAMLEN, hiện được đặt thành 256 (bao gồm cả dấu kết thúc 0.)

Điều cực kỳ quan trọng là phải nhận ra rằng sao Kim theo chiều kim đồng hồ
  cfs_lookup.vtype với CFS_NOCACHE để chỉ ra rằng đối tượng nên
  không được đặt trong bộ đệm tên kernel.

  .. Note::

     The type of the vtype is currently wrong.  It should be
     coda_vtype. Linux does not take note of CFS_NOCACHE.  It should.


4.5.  getattr
-------------


Tóm tắt Lấy các thuộc tính của một tập tin.

Đối số
     trong::

cấu trúc cfs_getattr_in {
		    ViceFid VFid;
		    struct coda_vattr attr; /* XXXXX */
		} cfs_getattr;



ngoài::

cấu trúc cfs_getattr_out {
		    struct coda_vattr attr;
		} cfs_getattr;



Mô tả
    Cuộc gọi này trả về các thuộc tính của tệp được xác định bởi fid.

Lỗi
    Lỗi có thể xảy ra nếu đối tượng có fid không tồn tại,
    không thể truy cập hoặc nếu người gọi không có quyền tìm nạp
    thuộc tính.

  .. Note::

     Many kernel FS drivers (Linux, NT and Windows 95) need to acquire
     the attributes as well as the Fid for the instantiation of an internal
     "inode" or "FileHandle".  A significant improvement in performance on
     such systems could be made by combining the lookup and getattr calls
     both at the Venus/kernel interaction level and at the RPC level.

Cấu trúc vattr có trong các đối số đầu vào là không cần thiết và
  nên được loại bỏ.


4.6.  setattr
-------------


Tóm tắt
    Đặt thuộc tính của một tập tin.

Đối số
     trong::

cấu trúc cfs_setattr_in {
		    ViceFid VFid;
		    struct coda_vattr attr;
		} cfs_setattr;




ngoài

trống

Mô tả
    Cấu trúc attr chứa đầy các thuộc tính cần thay đổi
    theo phong cách BSD.  Các thuộc tính không thể thay đổi được đặt thành -1, ngoại trừ
    vtype được đặt thành VNON. Các giá trị khác được đặt thành giá trị được chỉ định.
    Các thuộc tính duy nhất mà trình điều khiển FS có thể yêu cầu thay đổi là
    chế độ, chủ sở hữu, nhóm, atime, mtime và ctime.  Giá trị trả về
    biểu thị sự thành công hay thất bại.

Lỗi
    Một loạt các lỗi có thể xảy ra.  Đối tượng có thể không tồn tại, có thể
    không thể truy cập được hoặc có thể không được Venus cấp phép.


4.7.  truy cập
------------


Đối số
     trong::

cấu trúc cfs_access_in {
		    ViceFid VFid;
		    cờ int;
		} cfs_access;



ngoài

trống

Mô tả
    Xác minh xem quyền truy cập vào đối tượng được xác định bởi VFid cho
    cho phép các hoạt động được mô tả bằng cờ.  Kết quả cho biết nếu
    quyền truy cập sẽ được cấp.  Điều quan trọng cần nhớ là Coda sử dụng
    ACL để thực thi bảo vệ và cuối cùng là các máy chủ, không phải
    khách hàng thực thi bảo mật của hệ thống.  Kết quả của cuộc gọi này
    sẽ phụ thuộc vào việc người dùng có giữ mã thông báo hay không.

Lỗi
    Đối tượng có thể không tồn tại hoặc ACL mô tả biện pháp bảo vệ
    có thể không truy cập được.


4.8.  tạo nên
------------


Tóm tắt
    Được gọi để tạo một tập tin

Đối số
     trong::

cấu trúc cfs_create_in {
		    ViceFid VFid;
		    struct coda_vattr attr;
		    int loại trừ;
		    chế độ int;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_create;




ngoài::

cấu trúc cfs_create_out {
		    ViceFid VFid;
		    struct coda_vattr attr;
		} cfs_create;



Mô tả
    Upcall này được gọi để yêu cầu tạo một tập tin.
    Tệp sẽ được tạo trong thư mục được xác định bởi VFid, tên của nó
    sẽ là tên và chế độ sẽ là chế độ.  Nếu đặt loại trừ sẽ xảy ra lỗi
    được trả về nếu tập tin đã tồn tại.  Nếu trường kích thước trong attr là
    được đặt thành 0, tập tin sẽ bị cắt bớt.  uid và gid của tập tin
    được thiết lập bằng cách chuyển đổi CodaCred thành uid bằng macro CRTOUID
    (macro này phụ thuộc vào nền tảng).  Sau khi thành công, VFid và
    thuộc tính của tập tin được trả về.  Trình điều khiển Coda FS thường sẽ
    khởi tạo một vnode, inode hoặc xử lý tệp ở cấp kernel cho phiên bản mới
    đối tượng.


Lỗi
    Một loạt các lỗi có thể xảy ra. Quyền có thể không đủ.
    Nếu đối tượng tồn tại và không phải là tệp thì lỗi EISDIR sẽ được trả về
    dưới Unix.

  .. Note::

     The packing of parameters is very inefficient and appears to
     indicate confusion between the system call creat and the VFS operation
     create. The VFS operation create is only called to create new objects.
     This create call differs from the Unix one in that it is not invoked
     to return a file descriptor. The truncate and exclusive options,
     together with the mode, could simply be part of the mode as it is
     under Unix.  There should be no flags argument; this is used in open
     (2) to return a file descriptor for READ or WRITE mode.

Các thuộc tính của thư mục cũng phải được trả về vì kích thước
  và thời gian đã thay đổi.


4.9.  mkdir
-----------


Tóm tắt
    Tạo một thư mục mới.

Đối số
     trong::

cấu trúc cfs_mkdir_in {
		    ViceFid VFid;
		    struct coda_vattr attr;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_mkdir;



ngoài::

cấu trúc cfs_mkdir_out {
		    ViceFid VFid;
		    struct coda_vattr attr;
		} cfs_mkdir;




Mô tả
    Cuộc gọi này tương tự như tạo nhưng tạo một thư mục.
    Chỉ trường chế độ trong các tham số đầu vào mới được sử dụng để tạo.
    Sau khi tạo thành công, attr trả về chứa các thuộc tính của
    thư mục mới.

Lỗi
    Đối với việc tạo ra.

  .. Note::

     The input parameter should be changed to mode instead of
     attributes.

Các thuộc tính của cha mẹ phải được trả về vì kích thước và
  thời gian thay đổi.


4.10.  liên kết
-----------


Tóm tắt
    Tạo một liên kết đến một tập tin hiện có.

Đối số
     trong::

cấu trúc cfs_link_in {
		    Nguồn ViceFidFid;          /* cnode để liên kết ZZ0000ZZ */
		    ViceFid desFid;            /* Thư mục chứa liên kết */
		    char ZZ0001ZZ Nơi chứa dữ liệu. */
		} cfs_link;



ngoài

trống

Mô tả
    Cuộc gọi này tạo một liên kết đến sourceFid trong thư mục
    được xác định bởi destFid với tên tname.  Nguồn phải nằm trong
    cha mẹ của mục tiêu, tức là nguồn phải có DestFid cha, tức là Coda
    không hỗ trợ các liên kết cứng thư mục chéo.  Chỉ có giá trị trả về là
    có liên quan.  Nó chỉ ra sự thành công hoặc loại thất bại.

Lỗi
    Các lỗi thông thường có thể xảy ra.


4.11.  liên kết tượng trưng
--------------


Tóm tắt
    tạo một liên kết tượng trưng

Đối số
     trong::

cấu trúc cfs_symlink_in {
		    ViceFid VFid;          /* Thư mục để đặt liên kết tượng trưng */
		    char *srcname;
		    struct coda_vattr attr;
		    char *tname;
		} cfs_symlink;



ngoài

không có

Mô tả
    Tạo một liên kết tượng trưng. Liên kết phải được đặt trong
    thư mục được xác định bởi VFid và được đặt tên là tname.  Nó nên trỏ đến
    tên đường dẫn srcname.  Các thuộc tính của đối tượng mới được tạo là
    được đặt thành attr.

  .. Note::

     The attributes of the target directory should be returned since
     its size changed.


4.12.  di dời
-------------


Tóm tắt
    Xóa một tập tin

Đối số
     trong::

cấu trúc cfs_remove_in {
		    ViceFid VFid;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_remove;



ngoài

không có

Mô tả
    Xóa file có tên cfs_remove_in.name trong thư mục
    được xác định bởi VFid.


  .. Note::

     The attributes of the directory should be returned since its
     mtime and size may change.


4.13.  rmdir
------------


Tóm tắt
    Xóa một thư mục

Đối số
     trong::

cấu trúc cfs_rmdir_in {
		    ViceFid VFid;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_rmdir;



ngoài

không có

Mô tả
    Xóa thư mục có tên 'name' khỏi thư mục
    được xác định bởi VFid.

  .. Note:: The attributes of the parent directory should be returned since
	    its mtime and size may change.


4.14.  liên kết đọc
---------------


Tóm tắt
    Đọc giá trị của một liên kết tượng trưng.

Đối số
     trong::

cấu trúc cfs_readlink_in {
		    ViceFid VFid;
		} cfs_readlink;



ngoài::

cấu trúc cfs_readlink_out {
		    số int;
		    dữ liệu caddr_t;           /* Nơi chứa dữ liệu. */
		} cfs_readlink;



Mô tả
    Thói quen này đọc nội dung của liên kết tượng trưng
    được xác định bởi VFid vào dữ liệu bộ đệm.  Dữ liệu bộ đệm phải có khả năng
    để giữ bất kỳ tên nào lên tới CFS_MAXNAMLEN (PATH hoặc NAM??).

Lỗi
    Không có lỗi bất thường.


4.15.  mở
-----------


Tóm tắt
    Mở một tập tin.

Đối số
     trong::

cấu trúc cfs_open_in {
		    ViceFid VFid;
		    cờ int;
		} cfs_open;



ngoài::

cấu trúc cfs_open_out {
		    dev_t dev;
		    ino_t inode;
		} cfs_open;



Mô tả
    Yêu cầu này yêu cầu Venus đặt tập tin được xác định bởi
    VFid trong bộ đệm của nó và lưu ý rằng quá trình gọi muốn mở
    nó có cờ như trong open(2).  Giá trị trả về cho kernel khác nhau
    cho hệ thống Unix và Windows.  Đối với hệ thống Unix, Trình điều khiển Coda FS là
    thông báo về thiết bị và số inode của file chứa trong
    trường dev và inode.  Đối với Windows, đường dẫn của tệp chứa là
    được trả về kernel.


  .. Note::

     Currently the cfs_open_out structure is not properly adapted to
     deal with the Windows case.  It might be best to implement two
     upcalls, one to open aiming at a container file name, the other at a
     container file inode.


4.16.  đóng
------------


Tóm tắt
    Đóng một tập tin, cập nhật nó trên máy chủ.

Đối số
     trong::

cấu trúc cfs_close_in {
		    ViceFid VFid;
		    cờ int;
		} cfs_close;



ngoài

không có

Mô tả
    Đóng tệp được xác định bởi VFid.

  .. Note::

     The flags argument is bogus and not used.  However, Venus' code
     has room to deal with an execp input field, probably this field should
     be used to inform Venus that the file was closed but is still memory
     mapped for execution.  There are comments about fetching versus not
     fetching the data in Venus vproc_vfscalls.  This seems silly.  If a
     file is being closed, the data in the container file is to be the new
     data.  Here again the execp flag might be in play to create confusion:
     currently Venus might think a file can be flushed from the cache when
     it is still memory mapped.  This needs to be understood.


4.17.  ioctl
------------


Tóm tắt
    Thực hiện ioctl trên một tập tin. Điều này bao gồm giao diện pioctl.

Đối số
     trong::

cấu trúc cfs_ioctl_in {
		    ViceFid VFid;
		    int cmd;
		    int len;
		    int rwflag;
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} cfs_ioctl;



ngoài::


cấu trúc cfs_ioctl_out {
		    int len;
		    dữ liệu caddr_t;           /* Nơi chứa dữ liệu. */
		} cfs_ioctl;



Mô tả
    Thực hiện thao tác ioctl trên một tệp.  Lệnh len và
    đối số dữ liệu được điền như bình thường.  cờ không được sử dụng bởi sao Kim.

  .. Note::

     Another bogus parameter.  flags is not used.  What is the
     business about PREFETCHING in the Venus code?



4.18.  đổi tên
-------------


Tóm tắt
    Đổi tên một fid.

Đối số
     trong::

cấu trúc cfs_rename_in {
		    Nguồn ViceFidFid;
		    char *srcname;
		    ViceFid desFid;
		    char *tên đích;
		} cfs_rename;



ngoài

không có

Mô tả
    Đổi tên đối tượng bằng tên srcname trong thư mục
    sourceFid thành tên đích trong destFid.   Điều quan trọng là những cái tên
    srcname và destname là 0 chuỗi kết thúc.  Chuỗi trong Unix
    hạt nhân không phải lúc nào cũng bị chấm dứt.


4.19.  thư mục đọc
--------------


Tóm tắt
    Đọc các mục thư mục.

Đối số
     trong::

cấu trúc cfs_readdir_in {
		    ViceFid VFid;
		    số int;
		    int bù đắp;
		} cfs_readdir;




ngoài::

cấu trúc cfs_readdir_out {
		    kích thước int;
		    dữ liệu caddr_t;           /* Nơi chứa dữ liệu. */
		} cfs_readdir;



Mô tả
    Đọc các mục thư mục từ VFid bắt đầu từ offset và
    đọc tối đa số byte.  Trả về dữ liệu trong data và trả về
    kích thước trong kích thước.


  .. Note::

     This call is not used.  Readdir operations exploit container
     files.  We will re-evaluate this during the directory revamp which is
     about to take place.


4,20.  vget
-----------


Tóm tắt
    hướng dẫn sao Kim thực hiện FSDB->Nhận.

Đối số
     trong::

cấu trúc cfs_vget_in {
		    ViceFid VFid;
		} cfs_vget;



ngoài::

cấu trúc cfs_vget_out {
		    ViceFid VFid;
		    int vtype;
		} cfs_vget;



Mô tả
    Lệnh gọi lên này yêu cầu Venus thực hiện thao tác get trên fsobj
    được dán nhãn bởi VFid.

  .. Note::

     This operation is not used.  However, it is extremely useful
     since it can be used to deal with read/write memory mapped files.
     These can be "pinned" in the Venus cache using vget and released with
     inactive.


4.21.  fsync
------------


Tóm tắt
    Yêu cầu Venus cập nhật thuộc tính RVM của tệp.

Đối số
     trong::

cấu trúc cfs_fsync_in {
		    ViceFid VFid;
		} cfs_fsync;



ngoài

không có

Mô tả
    Yêu cầu Venus cập nhật thuộc tính RVM của đối tượng VFid. Cái này
    nên được gọi như một phần của cuộc gọi loại fsync cấp hạt nhân.  các
    kết quả cho biết đồng bộ hóa có thành công hay không.

  .. Note:: Linux does not implement this call. It should.


4.22.  không hoạt động
---------------


Tóm tắt
    Nói với Venus rằng vnode không còn được sử dụng nữa.

Đối số
     trong::

cấu trúc cfs_inactive_in {
		    ViceFid VFid;
		} cfs_inactive;



ngoài

không có

Mô tả
    Hoạt động này trả về EOPNOTSUPP.

  .. Note:: This should perhaps be removed.


4.23.  thứ ba
-----------


Tóm tắt
    Đọc hoặc ghi từ một tập tin

Đối số
     trong::

cấu trúc cfs_rdwr_in {
		    ViceFid VFid;
		    int rwflag;
		    số int;
		    int bù đắp;
		    int ioflag;
		    dữ liệu caddr_t;           /* Nơi chứa dữ liệu. */
		} cfs_rdwr;




ngoài::

cấu trúc cfs_rdwr_out {
		    int rwflag;
		    số int;
		    dữ liệu caddr_t;   /* Nơi chứa dữ liệu. */
		} cfs_rdwr;



Mô tả
    Lệnh gọi lên này yêu cầu Venus đọc hoặc ghi từ một tập tin.


  .. Note::

    It should be removed since it is against the Coda philosophy that
    read/write operations never reach Venus.  I have been told the
    operation does not work.  It is not currently used.



4.24.  leo núi
---------------


Tóm tắt
    Cho phép gắn nhiều "hệ thống tập tin" Coda trên một điểm gắn kết Unix.

Đối số
     trong::

cấu trúc ody_mount_in {
		    char ZZ0000ZZ Nơi chứa dữ liệu. */
		} ody_mount;



ngoài::

cấu trúc ody_mount_out {
		    ViceFid VFid;
		} ody_mount;



Mô tả
    Yêu cầu Venus trả lại rootfid của hệ thống Coda có tên
    tên.  Fid được trả về trong VFid.

  .. Note::

     This call was used by David for dynamic sets.  It should be
     removed since it causes a jungle of pointers in the VFS mounting area.
     It is not used by Coda proper.  Call is not implemented by Venus.


4,25.  ody_lookup
-----------------


Tóm tắt
    Tra cứu một cái gì đó.

Đối số
     trong

không liên quan


ngoài

không liên quan


  .. Note:: Gut it. Call is not implemented by Venus.


4.26.  ody_expand
-----------------


Tóm tắt
    mở rộng một cái gì đó trong một tập hợp năng động.

Đối số
     trong

không liên quan

ngoài

không liên quan

  .. Note:: Gut it. Call is not implemented by Venus.


4.27.  tìm nạp trước
---------------


Tóm tắt
    Tìm nạp trước một bộ động.

Đối số

TRONG

Không có tài liệu.

ngoài

Không có tài liệu.

Mô tả
    Venus worker.cc có hỗ trợ cho cuộc gọi này, mặc dù nó
    lưu ý rằng nó không hoạt động.  Không có gì đáng ngạc nhiên, vì hạt nhân không
    có sự hỗ trợ cho nó. (ODY_PREFETCH không phải là một hoạt động được xác định).


  .. Note:: Gut it. It isn't working and isn't used by Coda.



4,28.  tín hiệu
-------------


Tóm tắt
    Gửi cho Venus một tín hiệu về một cuộc gọi nâng cấp.

Đối số
     trong

không có

ngoài

không áp dụng được.

Mô tả
    Đây là một cuộc gọi ngoài ban nhạc tới Venus để thông báo cho Venus
    rằng quá trình gọi đã nhận được tín hiệu sau khi Venus đọc
    thông báo từ hàng đợi đầu vào.  Sao Kim được cho là sẽ dọn dẹp
    hoạt động.

Lỗi
    Không có câu trả lời nào được đưa ra.

  .. Note::

     We need to better understand what Venus needs to clean up and if
     it is doing this correctly.  Also we need to handle multiple upcall
     per system call situations correctly.  It would be important to know
     what state changes in Venus take place after an upcall for which the
     kernel is responsible for notifying Venus to clean up (e.g. open
     definitely is such a state change, but many others are maybe not).


5. Minicache và downcall
===============================


Trình điều khiển Coda FS có thể lưu vào bộ nhớ đệm các kết quả tra cứu và truy cập các cuộc gọi nâng cấp, để
  hạn chế tần suất upcall.  Upcalls mang một mức giá kể từ một quá trình
  chuyển đổi ngữ cảnh cần phải diễn ra.  Bản sao của bộ nhớ đệm
  thông tin là Venus sẽ thông báo cho Trình điều khiển FS đã lưu vào bộ nhớ đệm
  các mục phải được xóa hoặc đổi tên.

Mã hạt nhân thường phải duy trì một cấu trúc liên kết
  các trình xử lý tệp nội bộ (được gọi là vnodes trong BSD, inodes trong Linux và
  FileHandles trong Windows) với ViceFid's mà Venus duy trì.  các
  lý do là cần phải dịch qua lại thường xuyên trong
  để thực hiện upcalls và sử dụng kết quả của upcalls.  Liên kết như vậy
  các đối tượng được gọi là cnodes.

Việc triển khai minicache hiện tại có các mục bộ đệm ghi lại
  sau đây:

1. tên của tập tin

2. cnode của thư mục chứa đối tượng

3. danh sách CodaCred được phép tra cứu.

4. cnode của đối tượng

Cuộc gọi tra cứu trong Trình điều khiển Coda FS có thể yêu cầu cnode của
  đối tượng mong muốn từ bộ đệm, bằng cách chuyển tên, thư mục và
  CodaCred của người gọi.  Bộ đệm sẽ trả về cnode hoặc cho biết
  rằng nó không thể được tìm thấy.  Trình điều khiển Coda FS phải cẩn thận
  vô hiệu hóa các mục trong bộ đệm khi nó sửa đổi hoặc xóa các đối tượng.

Khi Venus thu được thông tin chỉ ra rằng các mục trong bộ nhớ đệm đã được
  không còn hợp lệ, nó sẽ tạo một lệnh gọi xuống kernel.  Cuộc gọi xuống là
  bị chặn bởi Trình điều khiển Coda FS và dẫn đến việc vô hiệu hóa bộ đệm của
  loại được mô tả dưới đây.  Trình điều khiển Coda FS không trả về lỗi
  trừ khi dữ liệu downcall không thể đọc được vào bộ nhớ kernel.


5.1.  INVALIDATE
----------------


Không có thông tin có sẵn về cuộc gọi này.


5.2.  FLUSH
-----------



Đối số
    không có

Tóm tắt
    Xóa hoàn toàn bộ đệm tên.

Mô tả
    Sao Kim đưa ra lời kêu gọi này khi khởi động và khi nó chết. Cái này
    là để ngăn chặn việc lưu giữ thông tin bộ đệm cũ.  Một số hoạt động
    hệ thống cho phép tắt bộ đệm tên kernel một cách linh hoạt.
    Khi điều này được thực hiện, cuộc gọi xuống này được thực hiện.


5.3.  PURGEUSER
---------------


Đối số
    ::

struct cfs_purgeuser_out {/* CFS_PURGEUSER là lệnh gọi venus->kernel */
	      cấu trúc tín dụng CodaCred;
	  } cfs_purgeuser;



Mô tả
    Xóa tất cả các mục trong bộ đệm mang Tín dụng.  Cái này
    cuộc gọi được phát hành khi mã thông báo của người dùng hết hạn hoặc bị xóa.


5.4.  ZAPFILE
-------------


Đối số
    ::

struct cfs_zapfile_out { /* CFS_ZAPFILE là lệnh gọi venus->kernel */
	      ViceFid CodaFid;
	  } cfs_zapfile;



Mô tả
    Xóa tất cả các mục có cặp (dir vnode, name).
    Điều này được đưa ra do sự vô hiệu của các thuộc tính được lưu trong bộ nhớ đệm của
    một vnode.

  .. Note::

     Call is not named correctly in NetBSD and Mach.  The minicache
     zapfile routine takes different arguments. Linux does not implement
     the invalidation of attributes correctly.



5.5.  ZAPDIR
------------


Đối số
    ::

struct cfs_zapdir_out { /* CFS_ZAPDIR là lệnh gọi venus->kernel */
	      ViceFid CodaFid;
	  } cfs_zapdir;



Mô tả
    Xóa tất cả các mục trong bộ đệm nằm trong một thư mục
    CodaFid và tất cả con của thư mục này. Cuộc gọi này được thực hiện khi
    Venus nhận được một cuộc gọi lại trên thư mục.


5.6.  ZAPVNODE
--------------



Đối số
    ::

struct cfs_zapvnode_out { /* CFS_ZAPVNODE là lệnh gọi venus->kernel */
	      cấu trúc tín dụng CodaCred;
	      ViceFid VFid;
	  } cfs_zapvnode;



Mô tả
    Xóa tất cả các mục trong bộ đệm mang tín dụng và VFid
    như trong các lập luận. Cuộc gọi xuống này có lẽ không bao giờ được ban hành.


5.7.  PURGEFID
--------------


Đối số
    ::

struct cfs_purgefid_out { /* CFS_PURGEFID là lệnh gọi venus->kernel */
	      ViceFid CodaFid;
	  } cfs_purgefid;



Mô tả
    Xóa thuộc tính cho tập tin. Nếu đó là một thư mục (lẻ
    vnode), xóa các phần tử con của nó khỏi bộ đệm tên và xóa tệp khỏi
    bộ đệm tên.



5.8.  REPLACE
-------------


Tóm tắt
    Thay thế Fid cho một tập hợp tên.

Đối số
    ::

struct cfs_replace_out { /* cfs_replace là lệnh gọi venus->kernel */
	      ViceFid NewFid;
	      ViceFid OldFid;
	  } cfs_replace;



Mô tả
    Quy trình này thay thế ViceFid trong bộ đệm tên bằng
    cái khác.  Nó được thêm vào để cho phép sao Kim trong quá trình tái hòa nhập thay thế
    các fids tạm thời được phân bổ cục bộ trong khi thậm chí bị ngắt kết nối với các fids toàn cầu
    khi số lượng tham chiếu trên các fid đó không bằng 0.


6. Khởi tạo và dọn dẹp
==============================


Phần này đưa ra gợi ý ngắn gọn về các tính năng mong muốn cho Coda
  Trình điều khiển FS khi khởi động và khi tắt máy hoặc lỗi Venus.  trước đây
  khi tham gia cuộc thảo luận, điều hữu ích là nhắc lại rằng Trình điều khiển Coda FS
  duy trì các dữ liệu sau:


1. hàng đợi tin nhắn

2. cnode

3. mục bộ đệm tên

Các mục trong bộ đệm tên hoàn toàn riêng tư đối với trình điều khiển, vì vậy chúng
     có thể dễ dàng bị thao túng.   Hàng đợi tin nhắn thường sẽ có
     điểm khởi tạo và hủy diệt rõ ràng.  Các cnode là
     tinh tế hơn nhiều.  Quy trình người dùng giữ số lượng tham chiếu trong Coda
     hệ thống tập tin và có thể khó dọn sạch các cnode.

Nó có thể mong đợi các yêu cầu thông qua:

1. hệ thống con tin nhắn

2. lớp VFS

3. giao diện pioctl

Hiện tại pioctl chuyển qua VFS cho Coda nên chúng tôi có thể
     đối xử với những điều này tương tự.


6.1.  Yêu cầu
------------------


Cần đáp ứng các yêu cầu sau:

1. Hàng đợi tin nhắn phải có quy trình mở và đóng.  Trên Unix
     việc mở các thiết bị nhân vật là những thói quen như vậy.

- Trước khi mở không được phép đặt tin nhắn.

- Việc mở sẽ xóa mọi tin nhắn cũ vẫn đang chờ xử lý.

- Close sẽ thông báo bất kỳ tiến trình đang ngủ nào mà upcall của chúng không thể thực hiện được
       được hoàn thành.

- Đóng sẽ giải phóng tất cả bộ nhớ được phân bổ bởi hàng đợi tin nhắn.


2. Khi mở namecache sẽ được khởi tạo ở trạng thái trống.

3. Trước khi hàng đợi tin nhắn được mở, tất cả các thao tác VFS sẽ không thành công.
     May mắn thay, điều này có thể đạt được bằng cách đảm bảo rằng việc lắp đặt
     Hệ thống tập tin Coda không thể thành công trước khi mở.

4. Sau khi đóng hàng đợi, không có hoạt động VFS nào có thể thành công.  đây
     người ta cần phải cẩn thận, vì một vài thao tác (tra cứu,
     đọc/ghi, readdir) có thể tiếp tục mà không cần gọi lại.  Đây phải là
     bị chặn một cách rõ ràng.

5. Sau khi đóng bộ đệm tên sẽ bị xóa và vô hiệu hóa.

6. Tất cả bộ nhớ do cnode nắm giữ có thể được giải phóng mà không cần dựa vào lệnh gọi lên.

7. Việc ngắt kết nối hệ thống tập tin có thể được thực hiện mà không cần dựa vào lệnh gọi lên.

8. Việc gắn hệ thống tập tin Coda sẽ thất bại nếu Venus không thể
     lấy rootfid hoặc các thuộc tính của rootfid.  Cái sau là
     được triển khai tốt nhất bằng cách sao Kim tìm nạp các vật thể này trước khi thử
     để gắn kết.

  .. Note::

     NetBSD in particular but also Linux have not implemented the
     above requirements fully.  For smooth operation this needs to be
     corrected.


