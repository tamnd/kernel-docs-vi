.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/data-integrity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Tính toàn vẹn dữ liệu
=====================

1. Giới thiệu
===============

Các hệ thống tập tin hiện đại có tính năng kiểm tra tổng hợp dữ liệu và siêu dữ liệu để
bảo vệ chống tham nhũng dữ liệu.  Tuy nhiên, việc phát hiện các
tham nhũng được thực hiện tại thời điểm đọc, có thể là vài tháng
sau khi dữ liệu được viết.  Tại thời điểm đó, dữ liệu gốc mà
ứng dụng cố gắng viết rất có thể bị mất.

Giải pháp là đảm bảo rằng đĩa thực sự đang lưu trữ những gì
ứng dụng có ý nghĩa như vậy.  Những bổ sung gần đây cho cả gia đình SCSI
các giao thức (Trường toàn vẹn dữ liệu SBC, đề xuất bảo vệ SCC)
vì SATA/T13 (Bảo vệ đường dẫn bên ngoài) cố gắng khắc phục điều này bằng cách thêm
support for appending integrity metadata to an I/O.  Tính toàn vẹn
siêu dữ liệu (hoặc thông tin bảo vệ theo thuật ngữ SCSI) bao gồm một
tổng kiểm tra cho từng lĩnh vực cũng như bộ đếm tăng dần
đảm bảo các lĩnh vực riêng lẻ được viết theo đúng thứ tự.  Và
đối với một số sơ đồ bảo vệ, I/O cũng được ghi ở bên phải
đặt trên đĩa.

Bộ điều khiển và thiết bị lưu trữ hiện tại triển khai nhiều biện pháp bảo vệ khác nhau
các biện pháp, ví dụ như kiểm tra tổng và lọc.  Nhưng những điều này
các công nghệ đang hoạt động trong các lĩnh vực biệt lập của riêng chúng hoặc tốt nhất là
giữa các nút lân cận trong đường dẫn I/O.  Điều thú vị về
DIF và các phần mở rộng toàn vẹn khác là định dạng bảo vệ
được xác định rõ ràng và mọi nút trong đường dẫn I/O đều có thể xác minh
tính toàn vẹn của I/O và từ chối nó nếu phát hiện sai sót.  Cái này
cho phép không chỉ phòng chống tham nhũng mà còn cô lập quan điểm
của sự thất bại.

2. Phần mở rộng về tính toàn vẹn dữ liệu
========================================

Như đã viết, phần mở rộng giao thức chỉ bảo vệ đường dẫn giữa
thiết bị lưu trữ và điều khiển.  Tuy nhiên, nhiều bộ điều khiển thực sự
cho phép hệ điều hành tương tác với siêu dữ liệu toàn vẹn
(IMD).  Chúng tôi đã làm việc với một số nhà cung cấp FC/SAS HBA để kích hoạt
thông tin bảo vệ sẽ được chuyển đến và đi từ họ
bộ điều khiển.

Trường toàn vẹn dữ liệu SCSI hoạt động bằng cách thêm 8 byte bảo vệ
thông tin cho từng lĩnh vực.  Dữ liệu + siêu dữ liệu toàn vẹn được lưu trữ
trong các cung 520 byte trên đĩa.  Dữ liệu + IMD được xen kẽ khi
được chuyển giao giữa bộ điều khiển và mục tiêu.  Đề xuất T13 là
tương tự.

Bởi vì nó rất bất tiện cho hệ điều hành khi xử lý
520 (và 4104) byte, chúng tôi đã tiếp cận một số nhà cung cấp HBA và
khuyến khích họ cho phép tách dữ liệu và siêu dữ liệu toàn vẹn
danh sách thu thập phân tán.

Bộ điều khiển sẽ xen kẽ các bộ đệm khi ghi và phân chia chúng trên
đọc.  Điều này có nghĩa là Linux có thể DMA bộ đệm dữ liệu đến và đi từ
bộ nhớ máy chủ mà không thay đổi bộ đệm trang.

Ngoài ra, tổng kiểm tra CRC 16 bit được bắt buộc bởi cả thông số kỹ thuật SCSI và SATA
tính toán trong phần mềm hơi nặng.  Điểm chuẩn cho thấy rằng
việc tính toán tổng kiểm tra này có tác động đáng kể đến hệ thống
hiệu suất cho một số khối lượng công việc.  Một số bộ điều khiển cho phép
tổng kiểm tra trọng lượng nhẹ hơn sẽ được sử dụng khi giao tiếp với hệ điều hành
hệ thống.  Ví dụ: Emulex hỗ trợ tổng kiểm tra TCP/IP.
Tổng kiểm tra IP nhận được từ HĐH được chuyển đổi thành CRC 16 bit
khi viết và ngược lại.  Điều này cho phép siêu dữ liệu toàn vẹn được
được tạo bởi Linux hoặc ứng dụng với chi phí rất thấp (có thể so sánh với
phần mềm RAID5).

Tổng kiểm tra IP yếu hơn CRC về khả năng phát hiện bit
lỗi.  Tuy nhiên, sức mạnh thực sự nằm ở việc tách dữ liệu
bộ đệm và siêu dữ liệu toàn vẹn.  Hai bộ đệm riêng biệt này phải
khớp để I/O hoàn thành.

Việc phân tách dữ liệu và bộ đệm siêu dữ liệu toàn vẹn cũng như
sự lựa chọn trong tổng kiểm tra được gọi là Tính toàn vẹn dữ liệu
Phần mở rộng.  Vì các phần mở rộng này nằm ngoài phạm vi của giao thức
(T10, T13), Oracle và các đối tác đang cố gắng chuẩn hóa
chúng trong Hiệp hội Công nghiệp Mạng Lưu trữ.

3. Thay đổi hạt nhân
====================

Khung toàn vẹn dữ liệu trong Linux cho phép bảo vệ thông tin
được ghim vào I/O và gửi đến/nhận từ bộ điều khiển
ủng hộ nó.

Ưu điểm của phần mở rộng tính toàn vẹn trong SCSI và SATA là ở chỗ
chúng cho phép chúng tôi bảo vệ toàn bộ đường dẫn từ ứng dụng đến bộ lưu trữ
thiết bị.  Tuy nhiên, đồng thời đây cũng là lớn nhất
bất lợi. Điều đó có nghĩa là thông tin bảo vệ phải ở dạng
format that can be understood by the disk.

Nói chung các ứng dụng Linux/POSIX không thể biết được sự phức tạp của
các thiết bị lưu trữ mà họ đang truy cập.  Chuyển đổi hệ thống tập tin ảo
và lớp khối tạo ra những thứ như kích thước khu vực phần cứng và
giao thức truyền tải hoàn toàn trong suốt đối với ứng dụng.

Tuy nhiên, mức độ chi tiết này là cần thiết khi chuẩn bị
thông tin bảo vệ để gửi vào đĩa.  Do đó, chính
khái niệm về sơ đồ bảo vệ đầu cuối là vi phạm phân lớp.
Hoàn toàn không hợp lý khi một ứng dụng biết được liệu
nó đang truy cập vào đĩa SCSI hoặc SATA.

Tính năng hỗ trợ tính toàn vẹn dữ liệu được triển khai trong Linux cố gắng che giấu điều này
từ ứng dụng.  Theo như ứng dụng (và ở một mức độ nào đó
kernel) có liên quan, siêu dữ liệu toàn vẹn là thông tin mờ đục
được gắn vào I/O.

Việc triển khai hiện tại cho phép lớp khối tự động
generate the protection information for any I/O.  Cuối cùng thì
mục đích là di chuyển tính toán siêu dữ liệu tính toàn vẹn sang không gian người dùng cho
dữ liệu người dùng.  Siêu dữ liệu và I/O khác bắt nguồn từ kernel
vẫn sẽ sử dụng giao diện tạo tự động.

Một số thiết bị lưu trữ cho phép mỗi khu vực phần cứng được gắn thẻ
Giá trị 16 bit.  Chủ sở hữu không gian thẻ này là chủ sở hữu khối
thiết bị.  tức là hệ thống tập tin trong hầu hết các trường hợp.  Hệ thống tập tin có thể sử dụng
không gian bổ sung này để gắn thẻ các lĩnh vực mà họ thấy phù hợp.  Bởi vì thẻ
không gian bị hạn chế, giao diện khối cho phép gắn thẻ các phần lớn hơn bằng cách
cách xen kẽ.  Bằng cách này, thông tin 8*16 bit có thể được
được gắn vào khối hệ thống tập tin 4KB điển hình.

Điều này cũng có nghĩa là các ứng dụng như fsck và mkfs sẽ cần
truy cập để thao tác các thẻ từ không gian người dùng.  Một sự vượt qua
giao diện cho việc này đang được thực hiện.


4. Chi tiết triển khai lớp khối
=====================================

4.1 Sinh học
------------

Các bản vá toàn vẹn dữ liệu thêm một trường mới vào struct bio khi
CONFIG_BLK_DEV_INTEGRITY được kích hoạt.  bio_integrity(bio) trả về một
con trỏ tới bip struct chứa tải trọng toàn vẹn sinh học.
Về cơ bản, bip là một cấu trúc sinh học được cắt bớt chứa bio_vec
chứa siêu dữ liệu toàn vẹn và công việc dọn phòng cần thiết
thông tin (nhóm bvec, số lượng vectơ, v.v.)

Hệ thống con kernel có thể kích hoạt tính năng bảo vệ tính toàn vẹn dữ liệu trên bio bằng cách
gọi bio_integrity_alloc(bio).  Điều này sẽ phân bổ và đính kèm
bip vào sinh học.

Các trang riêng lẻ chứa siêu dữ liệu về tính toàn vẹn sau đó có thể được
được đính kèm bằng bio_integrity_add_page().

bio_free() sẽ tự động giải phóng bip.


4.2 Chặn thiết bị
-----------------

Các thiết bị khối có thể thiết lập thông tin toàn vẹn trong tính toàn vẹn
cấu trúc phụ của cấu trúc queue_limits.

Các thiết bị khối phân lớp sẽ cần chọn một cấu hình phù hợp
cho tất cả các thiết bị phụ.  queue_limits_stack_integrity() có thể trợ giúp việc đó.  DM
và tuyến tính MD, RAID0 và RAID1 hiện được hỗ trợ.  RAID4/5/6
sẽ yêu cầu thêm công việc do thẻ ứng dụng.


Tính toàn vẹn của lớp khối 5.0 API
==================================

5.1 Hệ thống tập tin thông thường
---------------------------------

Hệ thống tập tin bình thường không biết rằng thiết bị khối cơ bản
    có khả năng gửi/nhận siêu dữ liệu toàn vẹn.  IMD sẽ
    được tạo tự động bởi lớp khối tại thời điểm submit_bio()
    trong trường hợp WRITE.  Yêu cầu READ sẽ đảm bảo tính toàn vẹn I/O
    để được xác minh sau khi hoàn thành.

Việc tạo và xác minh IMD có thể được chuyển đổi bằng cách sử dụng ::

/sys/block/<bdev>/integrity/write_generate

Và::

/sys/block/<bdev>/integrity/read_verify

cờ.


5.2 Hệ thống tập tin nhận biết tính toàn vẹn
--------------------------------------------

Một hệ thống tập tin có tính toàn vẹn có thể chuẩn bị I/O với IMD
    đính kèm.  Nó cũng có thể sử dụng không gian thẻ ứng dụng nếu đây là
    được hỗ trợ bởi thiết bị khối.


ZZ0000ZZ

Để tạo IMD cho WRITE và thiết lập bộ đệm cho READ,
      hệ thống tập tin phải gọi bio_integrity_prep(bio).

Trước khi gọi chức năng này, hướng dữ liệu sinh học và bắt đầu
      khu vực phải được thiết lập và tiểu sử phải có tất cả các trang dữ liệu
      đã thêm vào.  Người gọi có quyền đảm bảo rằng tiểu sử không
      thay đổi trong khi I/O đang được tiến hành.
      Hoàn thành tiểu sử có lỗi nếu quá trình chuẩn bị không thành công vì lý do nào đó.


5.3 Truyền siêu dữ liệu toàn vẹn hiện có
----------------------------------------

Các hệ thống tập tin tạo ra siêu dữ liệu về tính toàn vẹn của riêng chúng hoặc
    có khả năng chuyển IMD từ không gian người dùng có thể sử dụng
    các cuộc gọi sau:


ZZ0000ZZ

Phân bổ trọng tải toàn vẹn sinh học và treo nó khỏi sinh học.
      nr_pages cho biết cần có bao nhiêu trang dữ liệu bảo vệ
      được lưu trữ trong danh sách bio_vec toàn vẹn (tương tự như bio_alloc()).

Tải trọng toàn vẹn sẽ được giải phóng vào thời điểm bio_free().


ZZ0000ZZ

Đính kèm một trang chứa siêu dữ liệu về tính toàn vẹn vào một trang hiện có
      sinh học.  Tiểu sử phải có bip hiện có,
      tức là bio_integrity_alloc() phải được gọi.  Đối với WRITE,
      siêu dữ liệu toàn vẹn trong các trang phải ở định dạng
      được thiết bị mục tiêu hiểu với ngoại lệ đáng chú ý là
      số khu vực sẽ được ánh xạ lại khi yêu cầu đi qua
      Ngăn xếp I/O.  Điều này ngụ ý rằng các trang được thêm bằng lệnh gọi này
      sẽ được sửa đổi trong I/O!  Thẻ tham chiếu đầu tiên trong
      siêu dữ liệu toàn vẹn phải có giá trị bip->bip_sector.

Các trang có thể được thêm bằng cách sử dụng bio_integrity_add_page() miễn là
      có chỗ trong mảng bip bio_vec (nr_pages).

Sau khi hoàn thành thao tác READ, các trang đính kèm sẽ
      chứa siêu dữ liệu toàn vẹn nhận được từ thiết bị lưu trữ.
      Người nhận có trách nhiệm xử lý chúng và xác minh dữ liệu
      tính toàn vẹn khi hoàn thành.


----------------------------------------------------------------------

24-12-2007 Martin K. Petersen <martin.petersen@oracle.com>
