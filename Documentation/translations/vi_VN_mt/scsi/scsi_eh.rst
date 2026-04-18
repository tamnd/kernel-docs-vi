.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi_eh.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
SCSI EH
=======

Tài liệu này mô tả cơ sở hạ tầng xử lý lỗi lớp giữa SCSI.
Vui lòng tham khảo Tài liệu/scsi/scsi_mid_low_api.rst để biết thêm
thông tin về lớp giữa SCSI.

.. TABLE OF CONTENTS

   [1] How SCSI commands travel through the midlayer and to EH
       [1-1] struct scsi_cmnd
       [1-2] How do scmd's get completed?
   	[1-2-1] Completing a scmd w/ scsi_done
   	[1-2-2] Completing a scmd w/ timeout
       [1-3] How EH takes over
   [2] How SCSI EH works
       [2-1] EH through fine-grained callbacks
   	[2-1-1] Overview
   	[2-1-2] Flow of scmds through EH
   	[2-1-3] Flow of control
       [2-2] EH through transportt->eh_strategy_handler()
   	[2-2-1] Pre transportt->eh_strategy_handler() SCSI midlayer conditions
   	[2-2-2] Post transportt->eh_strategy_handler() SCSI midlayer conditions
   	[2-2-3] Things to consider


1. Cách các lệnh SCSI truyền qua lớp giữa và tới EH
==========================================================

1.1 cấu trúc scsi_cmnd
----------------------

Mỗi lệnh SCSI được biểu diễn bằng struct scsi_cmnd (== scmd).  A
scmd có hai list_head để liên kết chính nó thành danh sách.  Hai là
scmd->list và scmd->eh_entry.  Cái trước được sử dụng cho danh sách miễn phí hoặc
danh sách scmd được phân bổ trên mỗi thiết bị và không được EH này quan tâm nhiều
thảo luận.  Cái sau được sử dụng để hoàn thành và danh sách EH và trừ khi
nếu không thì các scmds luôn được liên kết bằng scmd->eh_entry trong này
thảo luận.


1.2 Làm thế nào để hoàn thành scmd?
-----------------------------------

Khi LLDD có được scmd, LLDD sẽ hoàn thành
lệnh bằng cách gọi lại cuộc gọi lại scsi_done được truyền từ lớp giữa khi
gọi Hostt->queuecommand() nếu không lớp khối sẽ hết thời gian chờ.


1.2.1 Hoàn thành scmd w/ scsi_done
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Đối với tất cả các lệnh không phải EH, scsi_done() là lệnh gọi lại hoàn thành.  Nó
chỉ cần gọi blk_mq_complete_request() để xóa bộ đếm thời gian của lớp khối và
nâng cao BLOCK_SOFTIRQ.

BLOCK_SOFTIRQ gọi gián tiếp scsi_complete(), gọi
scsi_decide_disposition() để xác định phải làm gì với lệnh.
scsi_decide_disposition() xem xét giá trị và ý nghĩa kết quả scmd->
data để xác định phải làm gì với lệnh.

-SUCCESS

scsi_finish_command() được gọi cho lệnh.  các
	chức năng thực hiện một số công việc bảo trì và sau đó gọi
	scsi_io_completion() để hoàn thành I/O.
	scsi_io_completion() sau đó thông báo cho lớp khối trên
	yêu cầu đã hoàn thành bằng cách gọi blk_end_request và
	bạn bè hoặc tìm hiểu xem phải làm gì với phần còn lại
	của dữ liệu trong trường hợp có lỗi.

-NEEDS_RETRY

-ADD_TO_MLQUEUE

scmd được yêu cầu xếp hàng đợi blk.

- nếu không thì

scsi_eh_scmd_add(scmd) được gọi cho lệnh.  Xem
	[1-3] để biết chi tiết về chức năng này.


1.2.2 Hoàn thành scmd khi hết thời gian chờ
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trình xử lý thời gian chờ là scsi_timeout().  Khi hết thời gian chờ, chức năng này

1. gọi lại lệnh gọi lại Hostt->eh_timed_out() tùy chọn.  Giá trị trả về có thể
    là một trong

-SCSI_EH_RESET_TIMER
	Điều này cho thấy cần nhiều thời gian hơn để hoàn thành
	lệnh.  Bộ hẹn giờ được khởi động lại.

-SCSI_EH_NOT_HANDLED
        Lệnh gọi lại eh_timed_out() không xử lý được lệnh.
	Bước #2 được thực hiện.

-SCSI_EH_DONE
        eh_timed_out() đã hoàn thành lệnh.

2. scsi_abort_command() được gọi để lên lịch hủy bỏ không đồng bộ, điều này có thể
    đưa ra thử lại scmd->allowed + 1 lần.  Việc hủy bỏ không đồng bộ không được gọi
    đối với các lệnh có cờ SCSI_EH_ABORT_SCHEDULED được đặt (điều này
    chỉ ra rằng lệnh đã bị hủy bỏ một lần và đây là một
    thử lại nhưng không thành công), khi số lần thử lại vượt quá hoặc khi hết thời hạn EH
    đã hết hạn. Trong những trường hợp này, Bước #3 được thực hiện.

3. scsi_eh_scmd_add(scmd) được gọi cho
    lệnh.  Xem [1-4] để biết thêm thông tin.

1.3 Lệnh hủy bỏ không đồng bộ
-------------------------------

Sau khi hết thời gian chờ, lệnh hủy bỏ được lên lịch từ
 scsi_abort_command(). Nếu hủy bỏ thành công lệnh
 sẽ được thử lại (nếu số lần thử lại chưa hết)
 hoặc chấm dứt bằng DID_TIME_OUT.

Nếu không thì scsi_eh_scmd_add() sẽ được gọi cho lệnh.
 Xem [1-4] để biết thêm thông tin.

1.4 EH tiếp quản như thế nào
----------------------------

scmds nhập EH qua scsi_eh_scmd_add(), thực hiện như sau.

1. Liên kết scmd->eh_entry tới shost->eh_cmd_q

2. Đặt bit SHOST_RECOVERY trong shost->shost_state

3. Tăng shost->host_failed

4. Đánh thức luồng SCSI EH nếu shost->host_busy == shost->host_failed

Như có thể thấy ở trên, khi bất kỳ scmd nào được thêm vào shost->eh_cmd_q,
Bit shost_state SHOST_RECOVERY được bật.  Điều này ngăn cản bất kỳ điều gì mới
scmd được cấp từ hàng đợi blk tới máy chủ; cuối cùng, tất cả các scmds trên
máy chủ hoàn thành bình thường, bị lỗi và được thêm vào eh_cmd_q hoặc
hết thời gian và được thêm vào shost->eh_cmd_q.

Nếu tất cả các scmd hoàn thành hoặc không thành công, số lượng scmd trong chuyến bay
trở thành bằng số lượng scmds không thành công - tức là shost->host_busy ==
shost->host_failed.  Điều này đánh thức chủ đề SCSI EH.  Vì vậy, một khi thức dậy,
Chuỗi SCSI EH có thể cho rằng tất cả các lệnh trong chuyến bay đều không thành công và
được liên kết trên shost->eh_cmd_q.

Lưu ý rằng điều này không có nghĩa là các lớp bên dưới không hoạt động.  Nếu là LLDD
đã hoàn thành một scmd với trạng thái lỗi, LLDD và các lớp thấp hơn được
giả định quên đi scmd tại thời điểm đó.  Tuy nhiên, nếu một scmd
đã hết thời gian chờ, trừ khi Hostt->eh_timed_out() làm cho các lớp bên dưới quên mất
về scmd, hiện tại không có LLDD nào thực hiện, lệnh vẫn là
hoạt động miễn là các lớp thấp hơn có liên quan và việc hoàn thành có thể
xảy ra bất cứ lúc nào.  Tất nhiên, tất cả những sự hoàn thành như vậy đều bị bỏ qua vì
đồng hồ đã hết hạn.

Chúng ta sẽ nói về cách SCSI EH thực hiện các hành động hủy bỏ - tạo LLDD
quên đi - hết thời gian chờ sau.


2. SCSI EH hoạt động như thế nào
================================

LLDD có thể thực hiện các hành động EH của SCSI theo một trong hai cách sau
cách.

- Lệnh gọi lại EH chi tiết
	LLDD có thể triển khai các lệnh gọi lại EH chi tiết và cho phép SCSI
	xử lý lỗi ổ đĩa giữa và gọi các cuộc gọi lại thích hợp.
	Điều này sẽ được thảo luận thêm trong [2-1].

- gọi lại eh_strategy_handler()
	Đây là một cuộc gọi lại lớn sẽ gây ra toàn bộ lỗi
	xử lý.  Như vậy, nó sẽ làm tất cả công việc của lớp giữa SCSI
	thực hiện trong quá trình phục hồi.  Điều này sẽ được thảo luận trong [2-2].

Sau khi quá trình khôi phục hoàn tất, SCSI EH sẽ tiếp tục hoạt động bình thường bằng cách
gọi scsi_restart_Operations(), trong đó

1. Kiểm tra xem có cần khóa cửa hay không và khóa cửa.

2. Xóa bit shost_state SHOST_RECOVERY

3. Đánh thức người phục vụ trên shost->host_wait.  Điều này xảy ra nếu ai đó
    gọi scsi_block_when_processing_errors() trên máy chủ.
    (ZZ0000ZZ tại sao lại cần thiết? Mọi hoạt động sẽ bị chặn
    dù sao đi nữa sau khi nó đến hàng đợi blk.)

4. Xếp hàng đợi trên tất cả các thiết bị trên máy chủ


2.1 EH thông qua các lệnh gọi lại chi tiết
------------------------------------------

2.1.1 Tổng quan
^^^^^^^^^^^^^^^

Nếu eh_strategy_handler() không xuất hiện, lớp giữa SCSI sẽ chịu trách nhiệm
xử lý lỗi lái xe.  Mục tiêu của EH là hai - tạo LLDD, máy chủ và
thiết bị hãy quên đi các scmds đã hết thời gian chờ và chuẩn bị sẵn sàng cho thiết bị mới
lệnh.  Một scmd được cho là đã được phục hồi nếu scmd bị quên bởi
các lớp thấp hơn và các lớp thấp hơn đã sẵn sàng xử lý hoặc không thực hiện được scmd
một lần nữa.

Để đạt được những mục tiêu này, EH thực hiện các hành động phục hồi với mức độ ngày càng tăng
mức độ nghiêm trọng.  Một số hành động được thực hiện bằng cách phát lệnh SCSI và
những cái khác được thực hiện bằng cách gọi một trong những chi tiết sau đây
lưu trữ các cuộc gọi lại EH.  Các cuộc gọi lại có thể bị bỏ qua và những cuộc gọi lại bị bỏ qua
coi như thất bại luôn.

::

int (* eh_abort_handler)(struct scsi_cmnd *);
    int (* eh_device_reset_handler)(struct scsi_cmnd *);
    int (* eh_bus_reset_handler)(struct scsi_cmnd *);
    int (* eh_host_reset_handler)(struct scsi_cmnd *);

Các hành động có mức độ nghiêm trọng cao hơn chỉ được thực hiện khi các hành động có mức độ nghiêm trọng thấp hơn
không thể phục hồi một số scmds thất bại.  Ngoài ra, hãy lưu ý rằng sự thất bại của
hành động có mức độ nghiêm trọng cao nhất có nghĩa là lỗi EH và dẫn đến việc ngừng hoạt động
tất cả các thiết bị chưa được phục hồi.

Trong quá trình phục hồi, các quy tắc sau được tuân theo

- Các hành động khôi phục được thực hiện trên các scmd bị lỗi trong danh sách việc cần làm,
   eh_work_q.  Nếu hành động khôi phục thành công đối với scmd, đã khôi phục
   scmds được xóa khỏi eh_work_q.

Lưu ý rằng hành động khôi phục đơn lẻ trên scmd có thể khôi phục nhiều
   scmds.  ví dụ. việc đặt lại thiết bị sẽ khôi phục tất cả các lỗi scmd trên thiết bị
   thiết bị.

- Các hành động có mức độ nghiêm trọng cao hơn sẽ được thực hiện nếu eh_work_q không trống sau
   các hành động có mức độ nghiêm trọng thấp hơn đã hoàn tất.

- EH tái sử dụng các scmd bị lỗi để ra lệnh phục hồi.  cho
   scmd hết thời gian chờ, SCSI EH đảm bảo rằng LLDD quên mất scmd
   trước khi sử dụng lại nó cho các lệnh EH.

Khi một scmd được phục hồi, scmd sẽ được chuyển từ eh_work_q sang EH
eh_done_q cục bộ bằng cách sử dụng scsi_eh_finish_cmd().  Sau tất cả các scmds là
đã được khôi phục (eh_work_q trống), scsi_eh_flush_done_q() được gọi tới
thử lại hoặc kết thúc lỗi (thông báo lỗi ở lớp trên) đã được khôi phục
scmds.

scmds được thử lại nếu sdev của nó vẫn trực tuyến (không ngoại tuyến trong thời gian
EH), REQ_FAILFAST chưa được đặt và ++scmd->retries nhỏ hơn
scmd-> được phép.


2.1.2 Dòng scmds qua EH
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

1. Lỗi hoàn thành/hết thời gian

:ACTION: scsi_eh_scmd_add() được gọi cho scmd

- thêm scmd vào shost->eh_cmd_q
	- bộ SHOST_RECOVERY
	- shost->host_failed++

:LOCKING: shost->host_lock

2. EH bắt đầu

:ACTION: di chuyển tất cả các scmds tới eh_work_q cục bộ của EH.  shost->eh_cmd_q
	     được xóa.

:LOCKING: shost->host_lock (không thực sự cần thiết, chỉ dành cho
             tính nhất quán)

3. đã phục hồi được scmd

:ACTION: scsi_eh_finish_cmd() được gọi tới scmd kết thúc EH

- di chuyển từ eh_work_q cục bộ sang eh_done_q cục bộ

:LOCKING: không có

:CONCURRENCY: tối đa một luồng cho mỗi eh_work_q riêng biệt tới
		  giữ cho thao tác hàng đợi không bị khóa

4. EH hoàn thành

:ACTION: scsi_eh_flush_done_q() thử lại scmds hoặc thông báo phía trên
	     lớp thất bại. Có thể được gọi đồng thời nhưng phải có
	     không quá một luồng cho mỗi eh_work_q riêng biệt để
	     thao tác hàng đợi một cách không khóa

- scmd bị xóa khỏi eh_done_q và scmd->eh_entry bị xóa
	     - nếu cần thử lại, scmd sẽ được xếp hàng đợi bằng cách sử dụng
	       scsi_queue_insert()
	     - nếu không thì scsi_finish_command() được gọi cho scmd
	     - không có shost->host_failed

:LOCKING: chức năng xếp hàng hoặc kết thúc thực hiện khóa thích hợp


2.1.3 Luồng điều khiển
^^^^^^^^^^^^^^^^^^^^^^

EH thông qua các lệnh gọi lại chi tiết bắt đầu từ scsi_unjam_host().

ZZ0000ZZ

1. Khóa shost->host_lock, splice_init shost->eh_cmd_q vào local
       eh_work_q và mở khóa hosting_lock.  Lưu ý rằng shost->eh_cmd_q là
       được xóa bởi hành động này.

2. Gọi scsi_eh_get_sense.

ZZ0000ZZ

Hành động này được thực hiện cho mỗi lỗi hoàn thành
	lệnh không có dữ liệu ý nghĩa hợp lệ.  Hầu hết
	SCSI truyền tải/LLDD tự động thu thập dữ liệu cảm nhận trên
	lỗi lệnh (autosense).  Autosense được khuyên dùng cho
	lý do hiệu suất và thông tin cảm giác có thể thoát ra khỏi
	đồng bộ hóa giữa sự xuất hiện của CHECK CONDITION và hành động này.

Lưu ý rằng nếu autosense không được hỗ trợ, scmd->sense_buffer
	chứa dữ liệu cảm giác không hợp lệ khi hoàn thành lỗi scmd
	với scsi_done().  scsi_decid_disposition() luôn trả về
	FAILED trong những trường hợp như vậy sẽ gọi SCSI EH.  Khi scmd
	đến đây, dữ liệu giác quan được thu thập và
	scsi_decide_disposition() được gọi lại.

1. Gọi scsi_request_sense() phát ra REQUEST_SENSE
           lệnh.  Nếu thất bại, không có hành động.  Lưu ý rằng không thực hiện hành động nào
           gây ra sự phục hồi ở mức độ nghiêm trọng cao hơn cho scmd.

2. Gọi scsi_decide_disposition() trên scmd

-SUCCESS
		scmd->retries được đặt thành scmd->cho phép ngăn chặn
		scsi_eh_flush_done_q() khỏi việc thử lại scmd và
		scsi_eh_finish_cmd() được gọi.

-NEEDS_RETRY
		scsi_eh_finish_cmd() được gọi

- nếu không
		Không có hành động.

4. Nếu !list_empty(&eh_work_q), hãy gọi scsi_eh_ready_devs()

ZZ0000ZZ

Chức năng này thực hiện bốn biện pháp ngày càng nghiêm ngặt hơn để
	làm cho các sdev bị lỗi sẵn sàng cho các lệnh mới.

1. Gọi scsi_eh_stu()

ZZ0000ZZ

Đối với mỗi sdev không thành công với dữ liệu cảm nhận hợp lệ
	    trong đó phán quyết của scsi_check_sense() là FAILED,
	    Lệnh START STOP UNIT được ban hành với w/ start=1.  Lưu ý rằng
	    vì chúng tôi chọn rõ ràng các scmds do hoàn thành lỗi nên được biết
	    rằng các lớp thấp hơn đã quên scmd và chúng ta có thể
	    tái sử dụng nó cho STU.

Nếu STU thành công và sdev ngoại tuyến hoặc sẵn sàng,
	    tất cả các scmds không thành công trên sdev đều được hoàn thành bằng EH
	    scsi_eh_finish_cmd().

ZZ0000ZZ Nếu máy chủ->eh_abort_handler() không được triển khai hoặc
	    không thành công, có thể chúng tôi vẫn đã hết thời gian chờ vào thời điểm này
	    và STU không làm cho các lớp thấp hơn quên đi những điều đó
	    scmds.  Tuy nhiên, chức năng này EH-finish tất cả scmds trên sdev
	    nếu STU thành công khi để lại các lớp thấp hơn trong trạng thái không nhất quán
	    trạng thái.  Có vẻ như hành động STU chỉ nên được thực hiện khi
	    một sdev không có scmd hết thời gian chờ.

2. Nếu !list_empty(&eh_work_q), hãy gọi scsi_eh_bus_device_reset().

ZZ0000ZZ

Hành động này rất giống với scsi_eh_stu() ngoại trừ việc,
	    thay vì phát hành STU, Hostt->eh_device_reset_handler()
	    được sử dụng.  Ngoài ra, vì chúng tôi không đưa ra lệnh SCSI và
	    việc đặt lại sẽ xóa tất cả các scmds trên sdev, không cần thiết
	    để chọn các scmds hoàn thành có lỗi.

3. Nếu !list_empty(&eh_work_q), hãy gọi scsi_eh_bus_reset()

ZZ0000ZZ

Hostt->eh_bus_reset_handler() được gọi cho mỗi kênh
	    với những scmds thất bại.  Nếu thiết lập lại xe buýt thành công, tất cả đều thất bại
	    scmds trên tất cả các sdev sẵn sàng hoặc ngoại tuyến trên kênh đều
	    EH-hoàn thành.

4. Nếu !list_empty(&eh_work_q), hãy gọi scsi_eh_host_reset()

ZZ0000ZZ

Đây là phương sách cuối cùng.  Hostt->eh_host_reset_handler()
	    được gọi.  Nếu thiết lập lại máy chủ thành công, tất cả các scmds đều không thành công
	    tất cả các sdev sẵn sàng hoặc ngoại tuyến trên máy chủ đều đã được hoàn thiện EH.

5. Nếu !list_empty(&eh_work_q), hãy gọi scsi_eh_offline_sdevs()

ZZ0000ZZ

Đưa tất cả các sdev vẫn còn scmd chưa được khôi phục ngoại tuyến
	    và EH-hoàn thành các scmds.

5. Gọi scsi_eh_flush_done_q().

ZZ0000ZZ

Tại thời điểm này, tất cả các scmds đều được phục hồi (hoặc bị loại bỏ) và
	    đeo eh_done_q bởi scsi_eh_finish_cmd().  Chức năng này
	    xóa eh_done_q bằng cách thử lại hoặc thông báo phía trên
	    lớp thất bại của scmds.


2.2 EH thông qua Transportt->eh_strategy_handler()
--------------------------------------------------

Transportt->eh_strategy_handler() được gọi thay cho
scsi_unjam_host() và nó chịu trách nhiệm cho toàn bộ quá trình khôi phục.
Sau khi hoàn thành, trình xử lý lẽ ra phải làm cho các lớp thấp hơn quên đi
tất cả các scmds đều không thành công và sẵn sàng cho các lệnh mới hoặc ngoại tuyến.  Ngoài ra,
nó phải thực hiện các công việc bảo trì SCSI EH để duy trì tính toàn vẹn của
Lớp giữa SCSI.  IOW, trong số các bước được mô tả trong [2-1-2], tất cả các bước
ngoại trừ #1 phải được triển khai bởi eh_strategy_handler().


2.2.1 Điều kiện trước khi vận chuyển->eh_strategy_handler() SCSI
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các điều kiện sau đây đúng khi truy cập vào trình xử lý.

- Mỗi trường eh_flags của scmd bị lỗi đều được đặt phù hợp.

- Mỗi scmd thất bại được liên kết trên scmd->eh_cmd_q bởi scmd->eh_entry.

- SHOST_RECOVERY đã được đặt.

- shost->host_failed == shost->host_busy


2.2.2 Đăng điều kiện vận chuyển->eh_strategy_handler() SCSI của lớp giữa
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Các điều kiện sau đây phải đúng khi thoát khỏi trình xử lý.

- shost->host_failed bằng 0.

- shost->eh_cmd_q bị xóa.

- Mỗi scmd->eh_entry đều bị xóa.

- Hoặc scsi_queue_insert() hoặc scsi_finish_command() được gọi
   mỗi scmd.  Lưu ý rằng trình xử lý có thể tự do sử dụng scmd->retries và
   -> được phép giới hạn số lần thử lại.


2.2.3 Những điều cần xem xét
^^^^^^^^^^^^^^^^^^^^^^^^^^^^

- Biết rằng các scmds đã hết thời gian vẫn hoạt động ở các lớp thấp hơn.  làm
   các lớp thấp hơn hãy quên chúng đi trước khi làm bất cứ điều gì khác với
   những lời lừa đảo đó.

- Để thống nhất, khi truy cập/sửa đổi cấu trúc dữ liệu shost,
   lấy shost->host_lock.

- Khi hoàn thành, mỗi sdev bị lỗi chắc hẳn đã quên hết
   scmds đang hoạt động.

- Khi hoàn thành, mỗi sdev bị lỗi phải sẵn sàng cho lệnh mới hoặc
   ngoại tuyến.


Tejun Heo
htejun@gmail.com

11 tháng 9 năm 2005