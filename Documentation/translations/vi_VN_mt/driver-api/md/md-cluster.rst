.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/md/md-cluster.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Cụm MD
==========

Cụm MD là thiết bị dùng chung RAID cho một cụm, nó hỗ trợ
hai cấp độ: raid1 và raid10 (hỗ trợ hạn chế).


1. Định dạng trên đĩa
=================

Các bitmap mục đích ghi riêng biệt được sử dụng cho mỗi nút cụm.
Bitmap ghi lại tất cả các thao tác ghi có thể đã được bắt đầu trên nút đó,
và có thể vẫn chưa kết thúc. Bố cục trên đĩa là::

0 4k 8k 12k
  -------------------------------------------------------------------
  ZZ0000ZZ md siêu ZZ0001ZZ
  ZZ0002ZZ bm siêu [1] + bit ZZ0003ZZ
  ZZ0004ZZ bm bit [2, tiếp theo] ZZ0005ZZ
  ZZ0006ZZ ZZ0007ZZ

Trong quá trình hoạt động "bình thường", chúng tôi giả sử hệ thống tập tin đảm bảo rằng chỉ
một nút ghi vào bất kỳ khối nhất định nào tại một thời điểm, vì vậy một yêu cầu ghi sẽ

- đặt bit thích hợp (nếu chưa được đặt)
 - cam kết ghi vào tất cả các máy nhân bản
 - lập lịch để xóa bit sau khi hết thời gian chờ.

Việc đọc chỉ được xử lý bình thường. Tùy thuộc vào hệ thống tập tin để đảm bảo
một nút không đọc từ một vị trí mà nút khác (hoặc nút tương tự
nút) đang viết.


2. Khóa DLM để quản lý
===========================

Có ba nhóm khóa để quản lý thiết bị:

2.1 Tài nguyên khóa bitmap (bm_lockres)
-------------------------------------

bm_lockres bảo vệ các bitmap nút riêng lẻ. Họ có tên trong
 dạng bitmap000 cho nút 1, bitmap001 cho nút 2, v.v. Khi một
 nút tham gia vào cụm, nó lấy được khóa ở chế độ PW và nó vẫn giữ nguyên
 vì vậy trong suốt thời gian tồn tại, nút là một phần của cụm. cái khóa
 số tài nguyên dựa trên số vị trí được DLM trả về
 hệ thống con. Vì DLM bắt đầu đếm nút từ một và các khe bitmap
 bắt đầu từ số 0, số vị trí DLM bị trừ đi một để đến nơi
 tại số vị trí bitmap.

LVB của khóa bitmap cho một nút cụ thể ghi lại phạm vi
 của các lĩnh vực đang được nút đó đồng bộ hóa lại.  không có cái khác
 nút có thể ghi vào các lĩnh vực đó.  Điều này được sử dụng khi một nút mới
 tham gia vào cụm.

2.2 Khóa chuyển tin nhắn
-------------------------

Mỗi nút phải liên lạc với các nút khác khi bắt đầu hoặc kết thúc
 đồng bộ lại và cập nhật siêu khối siêu dữ liệu.  Sự giao tiếp này là
 được quản lý thông qua ba khóa: "mã thông báo", "tin nhắn" và "ack" cùng nhau
 với Khối giá trị khóa (LVB) của một trong các khóa "tin nhắn".

2.3 quản lý thiết bị mới
-------------------------

Một khóa duy nhất: "no-new-dev" được sử dụng để phối hợp việc thêm
 thiết bị mới - điều này phải được đồng bộ hóa trên toàn mảng.
 Thông thường tất cả các nút đều có khóa đọc đồng thời trên thiết bị này.

3. Giao tiếp
================

Tin nhắn có thể được phát đến tất cả các nút và người gửi sẽ đợi tất cả
 các nút khác xác nhận tin nhắn trước khi tiếp tục.  Chỉ có một
 tin nhắn có thể được xử lý tại một thời điểm.

3.1 Các loại thông báo
-----------------

Có sáu loại tin nhắn được truyền:

3.1.1 METADATA_UPDATED
^^^^^^^^^^^^^^^^^^^^^^

thông báo cho các nút khác rằng siêu dữ liệu có
   đã được cập nhật và nút phải đọc lại siêu khối md. Đây là
   được thực hiện đồng bộ. Nó chủ yếu được sử dụng để báo hiệu thiết bị
   thất bại.

3.1.2 RESYNCING
^^^^^^^^^^^^^^^
thông báo cho các nút khác rằng quá trình đồng bộ lại được bắt đầu hoặc
   kết thúc để mỗi nút có thể tạm dừng hoặc tiếp tục khu vực.  Mỗi
   Thông báo RESYNCING xác định một loạt các thiết bị mà
   nút gửi sắp đồng bộ lại. Điều này ghi đè mọi thứ trước đó
   thông báo từ nút đó: chỉ có thể đồng bộ lại một phạm vi tại một thời điểm
   thời gian trên mỗi nút.

3.1.3 NEWDISK
^^^^^^^^^^^^^

thông báo cho các nút khác rằng một thiết bị đang được thêm vào
   mảng. Tin nhắn chứa mã định danh cho thiết bị đó.  Xem
   bên dưới để biết thêm chi tiết.

3.1.4 REMOVE
^^^^^^^^^^^^

Một thiết bị bị lỗi hoặc dự phòng đang bị xóa khỏi
   mảng. Số khe cắm của thiết bị được bao gồm trong tin nhắn.

3.1.5 RE_ADD:

Một thiết bị bị lỗi đang được kích hoạt lại - giả định
   là nó đã được xác định là sẽ hoạt động trở lại.

3.1.6 BITMAP_NEEDS_SYNC:

Nếu một nút bị dừng cục bộ nhưng bitmap
   không sạch thì nút khác sẽ được thông báo để sở hữu
   đồng bộ lại.

3.2 Cơ chế giao tiếp
---------------------------

DLM LVB được sử dụng để liên lạc trong các nút của cụm. Ở đó
 Có ba tài nguyên được sử dụng cho mục đích này:

3.2.1 mã thông báo
^^^^^^^^^^^
Tài nguyên bảo vệ toàn bộ thông tin liên lạc
   hệ thống. Nút có tài nguyên mã thông báo được phép
   giao tiếp.

3.2.2 tin nhắn
^^^^^^^^^^^^^
Tài nguyên khóa mang dữ liệu để liên lạc.

3.2.3 xác nhận
^^^^^^^^^

Tài nguyên thu được có nghĩa là thông điệp đã được
   được thừa nhận bởi tất cả các nút trong cụm. BAST của tài nguyên
   được sử dụng để thông báo cho nút nhận rằng nút đó muốn
   giao tiếp.

Thuật toán là:

1. trạng thái nhận - tất cả các nút đều có khóa trình đọc đồng thời trên "ack"::

người gửi người nhận người nhận
	"ack":CR "ack":CR "ack":CR

2. người gửi nhận EX trên "mã thông báo",
    người gửi nhận được EX trên "tin nhắn"::

người gửi người nhận người nhận
	"mã thông báo":EX "ack":CR "ack":CR
	"tin nhắn":EX
	"ack":CR

Người gửi kiểm tra xem nó vẫn cần gửi tin nhắn. Tin nhắn
    nhận được hoặc các sự kiện khác xảy ra trong khi chờ đợi
    "mã thông báo" có thể khiến thông báo này không phù hợp hoặc dư thừa.

3. người gửi viết LVB

người gửi chuyển đổi "tin nhắn" từ EX sang CW

người gửi cố gắng lấy EX của "ack"

    ::

[đợi cho đến khi tất cả người nhận có "tin nhắn" ZZ0000ZZ]

[ được kích hoạt bởi tiếng "ack"]
                                       người nhận nhận được CR trên "tin nhắn"
                                       đầu thu đọc LVB
                                       người nhận xử lý tin nhắn
                                       [chờ kết thúc]
                                       người nhận phát hành "ack"
                                       người nhận cố gắng PR về "tin nhắn"

người gửi người nhận người nhận
     "mã thông báo":EX "tin nhắn":CR "tin nhắn":CR
     "tin nhắn":CW
     "ack":EX

4. được kích hoạt bằng cách cấp EX trên "ack" (cho biết tất cả người nhận
    đã xử lý tin nhắn)

người gửi chuyển đổi xuống "ack" từ EX sang CR

người gửi phát hành "tin nhắn"

người gửi phát hành "mã thông báo"

    ::

người nhận chuyển đổi sang PR trên "tin nhắn"
                                 người nhận nhận được CR của "ack"
                                 người nhận phát hành "tin nhắn"

người gửi người nhận người nhận
     "ack":CR "ack":CR "ack":CR


4. Xử lý lỗi
====================

4.1 Lỗi nút
----------------

Khi một nút bị lỗi, DLM sẽ thông báo cho cụm có khe cắm
 số. Nút bắt đầu một chuỗi khôi phục cụm. Cụm
 chủ đề phục hồi:

- lấy được khóa bitmap<number> của nút bị lỗi
	- mở bitmap
	- đọc bitmap của nút bị lỗi
	- sao chép bitmap đã đặt vào nút cục bộ
	- làm sạch bitmap của nút bị lỗi
	- giải phóng khóa bitmap<number> của nút bị lỗi
	- bắt đầu đồng bộ lại bitmap trên nút hiện tại
	  md_check_recovery được gọi trong recovery_bitmaps,
	  sau đó md_check_recovery -> siêu dữ liệu_update_start/kết thúc,
	  nó sẽ khóa liên lạc bằng lock_comm.
	  Điều đó có nghĩa là khi một nút đang đồng bộ lại, nó sẽ chặn tất cả
	  các nút khác ghi vào bất kỳ vị trí nào trên mảng.

Quá trình đồng bộ lại là quá trình đồng bộ lại md thông thường. Tuy nhiên, trong một cụm
 môi trường khi thực hiện đồng bộ lại, nó cần thông báo cho các nút khác
 trong số các khu vực bị đình chỉ. Trước khi quá trình đồng bộ lại bắt đầu, nút
 gửi RESYNCING với phạm vi (lo,hi) của khu vực cần gửi
 bị đình chỉ. Mỗi nút duy trì một danh sách treo, trong đó có chứa
 danh sách các phạm vi hiện đang bị đình chỉ. Khi nhận được RESYNCING,
 nút thêm phạm vi vào danh sách treo. Tương tự, khi nút
 thực hiện kết thúc đồng bộ lại, nó sẽ gửi RESYNCING với phạm vi trống tới
 các nút khác và các nút khác loại bỏ mục nhập tương ứng khỏi
 đình chỉ_list.

Một hàm trợ giúp ->area_resyncing() có thể được sử dụng để kiểm tra xem
 phạm vi I/O cụ thể có nên bị đình chỉ hay không.

4.2 Lỗi thiết bị
==================

Lỗi thiết bị được xử lý và liên lạc với bản cập nhật siêu dữ liệu
 thường lệ.  Khi một nút phát hiện lỗi thiết bị, nó không cho phép
 mọi thao tác ghi tiếp vào thiết bị đó cho đến khi lỗi được khắc phục
 được tất cả các nút khác thừa nhận.

5. Thêm thiết bị mới
----------------------

Để thêm một thiết bị mới, điều cần thiết là tất cả các nút đều "nhìn thấy" thiết bị mới
 thiết bị cần được thêm vào. Đối với điều này, thuật toán sau được sử dụng:

1. Nút 1 phát hành mdadm --manage /dev/mdX --add /dev/sdYY phát hành
       ioctl(ADD_NEW_DISK với disc.state được đặt thành MD_DISK_CLUSTER_ADD)
   2. Nút 1 gửi tin nhắn NEWDISK với uuid và số vị trí
   3. Các nút khác phát hành kobject_uevent_env với uuid và số vị trí
       (Bước 4,5 có thể là quy tắc udev)
   4. Trong không gian người dùng, nút có thể tìm kiếm đĩa
       sử dụng blkid -t SUB_UUID=""
   5. Các nút khác đưa ra một trong những điều sau đây tùy thuộc vào việc
       đĩa đã được tìm thấy:
       ioctl(ADD_NEW_DISK với disc.state được đặt thành MD_DISK_CANDIDATE và
       disc.number được đặt thành số khe)
       ioctl(CLUSTERED_DISK_NACK)
   6. Các nút khác sẽ khóa "no-new-devs" (CR) nếu tìm thấy thiết bị
   7. Nút 1 thử khóa EX trên "no-new-dev"
   8. Nếu nút 1 nhận được khóa, nó sẽ gửi METADATA_UPDATED sau
       bỏ đánh dấu đĩa là SpareLocal
   9. Nếu không (nhận khóa "no-new-dev"), thao tác sẽ không thành công và gửi
       METADATA_UPDATED.
   10. Các nút khác nhận được thông tin về việc đĩa có được thêm vào hay không
       bởi METADATA_UPDATED sau đây.

6. Giao diện mô-đun
===================

Có 17 lệnh gọi lại mà lõi md có thể thực hiện đối với cụm
 mô-đun.  Hiểu những điều này có thể cung cấp một cái nhìn tổng quan tốt về toàn bộ
 quá trình.

6.1 tham gia (nút) và rời khỏi ()
---------------------------

Chúng được gọi khi một mảng được bắt đầu bằng một bitmap được nhóm,
 và khi mảng dừng lại.  join() đảm bảo cụm được
 có sẵn và khởi tạo các tài nguyên khác nhau.
 Chỉ các nút 'nút' đầu tiên trong cụm mới có thể sử dụng mảng.

6.2 slot_number()
-----------------

Báo cáo số vị trí được cơ sở hạ tầng cụm tư vấn.
 Phạm vi là từ 0 đến nút-1.

6.3 resync_info_update()
------------------------

Điều này cập nhật phạm vi đồng bộ lại được lưu trữ trong khóa bitmap.
 Điểm bắt đầu được cập nhật khi quá trình đồng bộ lại diễn ra.  các
 điểm cuối luôn là điểm cuối của mảng.
 Nó thực hiện ZZ0000ZZ gửi tin nhắn RESYNCING.

6.4 resync_start(), resync_finish()
-----------------------------------

Chúng được gọi khi quá trình đồng bộ lại/khôi phục/định hình lại bắt đầu hoặc dừng.
 Họ cập nhật phạm vi đồng bộ lại trong khóa bitmap và cả
 gửi tin nhắn RESYNCING.  resync_start báo cáo toàn bộ
 mảng đang đồng bộ hóa lại, resync_finish không báo cáo điều đó.

resync_finish() cũng gửi tin nhắn BITMAP_NEEDS_SYNC
 cho phép một số nút khác tiếp quản.

6.5 siêu dữ liệu_update_start(), siêu dữ liệu_update_finish(), siêu dữ liệu_update_cancel()
-------------------------------------------------------------------------------

siêu dữ liệu_update_start được sử dụng để có quyền truy cập độc quyền vào
 siêu dữ liệu.  Nếu vẫn cần thay đổi khi quyền truy cập đó đã hết
 đạt được, siêu dữ liệu_update_finish() sẽ gửi METADATA_UPDATE
 thông báo tới tất cả các nút khác, nếu không thì metadata_update_cancel()
 có thể được sử dụng để mở khóa.

6.6 vùng_resyncing()
--------------------

Điều này kết hợp hai yếu tố chức năng.

Đầu tiên, nó sẽ kiểm tra xem có nút nào hiện đang đồng bộ lại không
 bất cứ điều gì trong một phạm vi nhất định của các lĩnh vực.  Nếu tìm thấy bất kỳ đồng bộ lại nào,
 thì người gọi sẽ tránh viết hoặc cân bằng đọc trong đó
 phạm vi.

Thứ hai, trong khi quá trình khôi phục nút đang diễn ra, nó báo cáo rằng
 tất cả các khu vực đang đồng bộ lại cho các yêu cầu READ.  Điều này tránh các cuộc đua
 giữa hệ thống tập tin cụm và xử lý cụm-RAID
 một nút bị lỗi.

6.7 add_new_disk_start(), add_new_disk_finish(), new_disk_ack()
---------------------------------------------------------------

Chúng được sử dụng để quản lý giao thức đĩa mới được mô tả ở trên.
 Khi một thiết bị mới được thêm vào, add_new_disk_start() được gọi trước
 nó được liên kết với mảng và nếu thành công, add_new_disk_finish()
 được gọi là thiết bị được thêm đầy đủ.

Khi một thiết bị được thêm vào để xác nhận thiết bị trước đó
 yêu cầu hoặc khi thiết bị được tuyên bố là "không khả dụng",
 new_disk_ack() được gọi.

6.8 xóa_đĩa()
-----------------

Điều này được gọi khi một thiết bị dự phòng hoặc bị lỗi được gỡ bỏ khỏi
 mảng.  Nó khiến một thông báo REMOVE được gửi đến các nút khác.

6.9 tập hợp_bitmaps()
--------------------

Điều này sẽ gửi tin nhắn RE_ADD đến tất cả các nút khác và sau đó
 thu thập thông tin bitmap từ tất cả các bitmap.  Điều này kết hợp
 bitmap sau đó được sử dụng để khôi phục thiết bị được thêm lại.

6.10 lock_all_bitmaps() và unlock_all_bitmaps()
------------------------------------------------

Chúng được gọi khi thay đổi bitmap thành không. Nếu một nút có kế hoạch
 để xóa bitmap của cluster raid, cần đảm bảo không có bitmap nào khác
 các nút đang sử dụng cuộc đột kích đạt được bằng cách khóa tất cả bitmap
 khóa trong cụm và những khóa đó cũng được mở khóa
 tương ứng.

7. Các tính năng không được hỗ trợ
=======================

Có một số thứ chưa được cụm MD hỗ trợ.

- thay đổi mảng_sector.
