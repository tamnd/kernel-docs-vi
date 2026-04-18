.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/thin-provisioning.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===================
Cung cấp mỏng
=================

Giới thiệu
============

Tài liệu này mô tả một tập hợp các mục tiêu của trình ánh xạ thiết bị
giữa chúng thực hiện cung cấp mỏng và ảnh chụp nhanh.

Điểm nổi bật chính của việc thực hiện này, so với trước đây
thực hiện các ảnh chụp nhanh, là nó cho phép nhiều thiết bị ảo
được lưu trữ trên cùng một khối lượng dữ liệu.  Điều này giúp đơn giản hóa việc quản lý và
cho phép chia sẻ dữ liệu giữa các ổ đĩa, do đó giảm mức sử dụng đĩa.

Một tính năng quan trọng khác là hỗ trợ độ sâu tùy ý của
ảnh chụp nhanh đệ quy (ảnh chụp nhanh của ảnh chụp nhanh ...).  các
việc triển khai ảnh chụp nhanh trước đây đã thực hiện điều này bằng cách xâu chuỗi lại với nhau
bảng tra cứu và do đó hiệu suất là O(độ sâu).  Cái mới này
việc triển khai sử dụng một cấu trúc dữ liệu duy nhất để tránh sự xuống cấp này
với chiều sâu.  Tuy nhiên, sự phân mảnh vẫn có thể là một vấn đề ở một số
kịch bản.

Siêu dữ liệu được lưu trữ trên một thiết bị riêng biệt với dữ liệu, mang lại
quản trị viên một số quyền tự do, ví dụ:

- Cải thiện khả năng phục hồi siêu dữ liệu bằng cách lưu trữ siêu dữ liệu trên ổ đĩa được nhân đôi
  nhưng dữ liệu trên một dữ liệu không được nhân đôi.

- Cải thiện hiệu suất bằng cách lưu trữ siêu dữ liệu trên SSD.

Trạng thái
======

Những mục tiêu này được coi là an toàn để sử dụng trong sản xuất.  Nhưng cách sử dụng khác nhau
trường hợp sẽ có đặc điểm hiệu suất khác nhau, ví dụ do
đến sự phân mảnh của khối lượng dữ liệu.

Nếu bạn thấy phần mềm này hoạt động không như mong đợi, vui lòng gửi thư
dm-devel@redhat.com kèm theo thông tin chi tiết và chúng tôi sẽ cố gắng hết sức để cải thiện
những thứ dành cho bạn.

Các công cụ trong không gian người dùng để kiểm tra và sửa chữa siêu dữ liệu đã được cung cấp đầy đủ
được phát triển và có sẵn dưới dạng 'thin_check' và 'thin_repair'.  Tên
của gói cung cấp các tiện ích này khác nhau tùy theo phân phối (trên
một bản phân phối của Red Hat, nó được đặt tên là 'device-mapper-persistent-data').

Sách dạy nấu ăn
========

Phần này mô tả một số công thức nhanh chóng để sử dụng lượng cung cấp mỏng.
Họ sử dụng chương trình dmsetup để điều khiển trình điều khiển trình ánh xạ thiết bị
trực tiếp.  Người dùng cuối sẽ được khuyên nên sử dụng âm lượng ở mức cao hơn
người quản lý như LVM2 khi hỗ trợ đã được thêm vào.

Thiết bị bể bơi
-----------

Thiết bị nhóm liên kết khối lượng siêu dữ liệu và khối lượng dữ liệu với nhau.
Nó ánh xạ I/O tuyến tính tới khối lượng dữ liệu và cập nhật siêu dữ liệu thông qua
hai cơ chế:

- Gọi hàm từ các mục tiêu mỏng

- 'Thông báo' của trình ánh xạ thiết bị từ không gian người dùng kiểm soát việc tạo mới
  thiết bị ảo trong số những thứ khác.

Thiết lập một thiết bị hồ bơi mới
------------------------------

Việc thiết lập thiết bị nhóm yêu cầu thiết bị siêu dữ liệu hợp lệ và
thiết bị dữ liệu.  Nếu bạn không có thiết bị siêu dữ liệu hiện có, bạn có thể
tạo một cái bằng cách bỏ 4k đầu tiên để biểu thị siêu dữ liệu trống.

dd if=/dev/zero of=$metadata_dev bs=4096 count=1

Lượng siêu dữ liệu bạn cần sẽ thay đổi tùy theo số lượng khối
được chia sẻ giữa các thiết bị mỏng (tức là thông qua ảnh chụp nhanh).  Nếu bạn có
ít chia sẻ hơn mức trung bình, bạn sẽ cần một thiết bị siêu dữ liệu lớn hơn mức trung bình.

Theo hướng dẫn, chúng tôi khuyên bạn nên tính số byte sẽ sử dụng trong
thiết bị siêu dữ liệu là 48 * $data_dev_size / $data_block_size nhưng làm tròn nó lên
đến 2MiB nếu câu trả lời nhỏ hơn.  Nếu bạn đang tạo một số lượng lớn
ảnh chụp nhanh đang ghi lại lượng lớn thay đổi, bạn có thể thấy mình
cần tăng thêm điều này.

Kích thước lớn nhất được hỗ trợ là 16GiB: Nếu thiết bị lớn hơn,
một cảnh báo sẽ được đưa ra và không gian thừa sẽ không được sử dụng.

Tải lại bàn bi-a
----------------------

Bạn có thể tải lại bảng của nhóm, thực sự đây là cách thay đổi kích thước nhóm
nếu nó hết dung lượng.  (N.B. Trong khi chỉ định một siêu dữ liệu khác
thiết bị khi tải lại không bị cấm vào lúc này, mọi thứ sẽ diễn ra
sai nếu nó không định tuyến I/O đến cùng một vị trí trên đĩa như
trước đó.)

Sử dụng thiết bị hồ bơi hiện có
-----------------------------

::

dmsetup tạo nhóm \
	--table "0 20971520 nhóm mỏng $metadata_dev $data_dev \
		 $data_block_size $low_water_mark"

$data_block_size cung cấp đơn vị không gian đĩa nhỏ nhất có thể
được phân bổ tại một thời điểm được biểu thị bằng đơn vị của các cung 512 byte.
$data_block_size phải nằm trong khoảng từ 128 (64KiB) đến 2097152 (1GiB) và a
bội số của 128 (64KiB).  $data_block_size không thể thay đổi sau
bể mỏng được tạo ra.  Mọi người chủ yếu quan tâm đến việc cung cấp mỏng
có thể muốn sử dụng giá trị như 1024 (512KiB).  Người ta làm rất nhiều
chụp nhanh có thể muốn có giá trị nhỏ hơn, chẳng hạn như 128 (64KiB).  Nếu bạn là
không đưa dữ liệu mới được phân bổ về 0, kích thước $data_block_size lớn hơn trong
vùng 262144 (128MiB) được đề xuất.

$low_water_mark được thể hiện bằng các khối có kích thước $data_block_size.  Nếu
dung lượng trống trên thiết bị dữ liệu giảm xuống dưới mức này thì sẽ xảy ra sự kiện dm
sẽ được kích hoạt mà daemon không gian người dùng sẽ bắt được cho phép nó
mở rộng thiết bị hồ bơi.  Chỉ có một sự kiện như vậy sẽ được gửi đi.

Không có sự kiện đặc biệt nào được kích hoạt nếu dung lượng trống của thiết bị vừa được tiếp tục thấp hơn
vạch nước thấp. Tuy nhiên, việc tiếp tục lại thiết bị luôn gây ra lỗi
sự kiện; daemon không gian người dùng phải xác minh rằng dung lượng trống vượt quá mức thấp
dấu nước khi xử lý sự kiện này.

Dấu nước thấp cho thiết bị siêu dữ liệu được duy trì trong kernel và
sẽ kích hoạt sự kiện dm nếu dung lượng trống trên thiết bị siêu dữ liệu giảm xuống dưới
nó.

Cập nhật siêu dữ liệu trên đĩa
-------------------------

Siêu dữ liệu trên đĩa được cam kết mỗi khi viết tiểu sử FLUSH hoặc FUA.
Nếu không có yêu cầu nào như vậy được thực hiện thì các lần xác nhận sẽ diễn ra mỗi giây.  Cái này
có nghĩa là mục tiêu cung cấp mỏng hoạt động giống như một đĩa vật lý có
một bộ đệm ghi dễ bay hơi.  Nếu mất điện, bạn có thể mất một số thông tin gần đây
viết.  Siêu dữ liệu phải luôn nhất quán bất chấp mọi sự cố.

Nếu hết dung lượng dữ liệu, nhóm sẽ gặp lỗi hoặc xếp hàng IO
theo cấu hình (xem: error_if_no_space).  Nếu siêu dữ liệu
hết dung lượng hoặc thao tác siêu dữ liệu không thành công: nhóm sẽ báo lỗi IO
cho đến khi nhóm được đưa ngoại tuyến và việc sửa chữa được thực hiện thành 1) khắc phục mọi
những mâu thuẫn tiềm ẩn và 2) xóa cờ yêu cầu sửa chữa.
Sau khi thiết bị siêu dữ liệu của nhóm được sửa chữa, nó có thể được thay đổi kích thước,
sẽ cho phép hồ bơi trở lại hoạt động bình thường.  Lưu ý rằng nếu một hồ bơi
được gắn cờ là cần sửa chữa, các thiết bị dữ liệu và siêu dữ liệu của nhóm
không thể thay đổi kích thước cho đến khi sửa chữa được thực hiện.  Cũng cần lưu ý
rằng khi không gian siêu dữ liệu của nhóm cạn kiệt thì siêu dữ liệu hiện tại
giao dịch bị hủy bỏ.  Cho rằng nhóm sẽ lưu trữ IO có
việc hoàn thành có thể đã được xác nhận ở các lớp IO phía trên
(ví dụ: hệ thống tập tin), chúng tôi khuyên bạn nên kiểm tra tính nhất quán
(ví dụ: fsck) được thực hiện trên các lớp đó khi việc sửa chữa nhóm được thực hiện
được yêu cầu.

Cung cấp mỏng
-----------------

i) Tạo một tập đĩa mới được cung cấp mỏng.

Để tạo một tập đĩa mới được cung cấp mỏng, bạn phải gửi tin nhắn đến một
  thiết bị nhóm đang hoạt động, /dev/mapper/pool trong ví dụ này::

tin nhắn dmsetup/dev/mapper/pool 0 "create_thin 0"

Ở đây '0' là mã định danh cho ổ đĩa, một số 24 bit.  nó lên rồi
  cho người gọi để phân bổ và quản lý các mã định danh này.  Nếu
  mã định danh đã được sử dụng, thông báo sẽ không thành công với -EEXIST.

ii) Sử dụng một khối lượng được cung cấp mỏng.

Các tập đĩa được cung cấp ít được kích hoạt bằng cách sử dụng mục tiêu 'mỏng'::

dmsetup tạo mỏng --table "0 2097152 mỏng/dev/mapper/pool 0"

Tham số cuối cùng là mã định danh cho thiết bị mỏng.

Ảnh chụp nhanh nội bộ
------------------

i) Tạo ảnh chụp nhanh nội bộ.

Ảnh chụp nhanh được tạo bằng một thông báo khác tới nhóm.

N.B.  Nếu thiết bị gốc mà bạn muốn chụp nhanh đang hoạt động, bạn
  phải tạm dừng nó trước khi tạo ảnh chụp nhanh để tránh bị hỏng.
  Hiện tại, NOT đang được thực thi, vì vậy hãy cẩn thận!

  ::

dmsetup đình chỉ/dev/mapper/thin
    tin nhắn dmsetup/dev/mapper/pool 0 "create_snap 1 0"
    sơ yếu lý lịch dmsetup/dev/mapper/thin

Ở đây '1' là mã định danh cho ổ đĩa, một số 24 bit.  '0' là
  mã định danh cho thiết bị gốc.

ii) Sử dụng ảnh chụp nhanh nội bộ.

Sau khi tạo, người dùng không phải lo lắng về bất kỳ kết nối nào
  giữa nguồn gốc và ảnh chụp nhanh.  Quả thực ảnh chụp nhanh là không
  khác với bất kỳ thiết bị được cung cấp mỏng nào khác và có thể
  tự chụp nhanh thông qua cùng một phương pháp.  Nó hoàn toàn hợp pháp để
  chỉ có một trong số chúng hoạt động và không có yêu cầu đặt hàng trên
  kích hoạt hoặc loại bỏ cả hai.  (Điều này khác với thông thường
  ảnh chụp nhanh của trình ánh xạ thiết bị.)

Kích hoạt nó theo cách giống hệt như bất kỳ ổ đĩa được cung cấp mỏng nào khác::

dmsetup tạo snap --table "0 2097152 mỏng/dev/mapper/pool 1"

Ảnh chụp nhanh bên ngoài
------------------

Bạn có thể sử dụng thiết bị ZZ0000ZZ bên ngoài làm nguồn gốc cho
khối lượng được cung cấp mỏng.  Bất kỳ hoạt động đọc nào đến một khu vực không được cung cấp của
thiết bị mỏng sẽ được chuyển qua điểm gốc.  Trình kích hoạt ghi
việc phân bổ các khối mới như bình thường.

Một trường hợp sử dụng cho việc này là các máy chủ VM muốn chạy khách trên
khối lượng được cung cấp ít nhưng có hình ảnh cơ sở trên thiết bị khác
(có thể được chia sẻ giữa nhiều máy ảo).

Bạn không được ghi vào thiết bị gốc nếu bạn sử dụng kỹ thuật này!
Tất nhiên, bạn có thể ghi vào thiết bị mỏng và chụp ảnh nhanh bên trong
của khối lượng mỏng.

i) Tạo ảnh chụp nhanh của thiết bị bên ngoài

Điều này cũng giống như việc tạo ra một thiết bị mỏng.
  Bạn không đề cập đến nguồn gốc ở giai đoạn này.

  ::

tin nhắn dmsetup/dev/mapper/pool 0 "create_thin 0"

ii) Sử dụng ảnh chụp nhanh của thiết bị bên ngoài.

Nối một tham số bổ sung vào mục tiêu mỏng chỉ định nguồn gốc::

dmsetup tạo snap --table "0 2097152 mỏng/dev/mapper/pool 0/dev/hình ảnh"

N.B. Tất cả các hậu duệ (ảnh chụp nhanh nội bộ) của ảnh chụp nhanh này yêu cầu
  cùng một tham số gốc bổ sung.

Vô hiệu hóa
------------

Tất cả các thiết bị sử dụng nhóm phải được hủy kích hoạt trước khi có nhóm
có thể được.

::

dmsetup loại bỏ mỏng
    dmsetup xóa snap
    dmsetup xóa nhóm

Thẩm quyền giải quyết
=========

mục tiêu 'hồ bơi mỏng'
------------------

i) Nhà xây dựng

    ::

Thin-pool <metadata dev> <data dev> <kích thước khối dữ liệu (sector)> \
	        <dấu nước thấp (khối)> [<số lượng đối số tính năng> [<arg>]*]

Đối số tính năng tùy chọn:

Skip_block_zeroing:
	Bỏ qua việc zeroing các khối mới được cung cấp.

bỏ qua_discard:
	Tắt hỗ trợ loại bỏ.

no_discard_passdown:
	Đừng chuyển phần loại bỏ xuống phần cơ bản
	thiết bị dữ liệu, nhưng chỉ cần loại bỏ ánh xạ.

chỉ đọc:
		 Không cho phép thực hiện bất kỳ thay đổi nào đối với nhóm
		 siêu dữ liệu.  Chế độ này chỉ khả dụng sau khi
		 Thin-pool đã được tạo và lần đầu tiên được sử dụng đầy đủ
		 chế độ đọc/ghi.  Nó không thể được chỉ định ban đầu
		 tạo hồ bơi mỏng.

error_if_no_space:
	Lỗi IO, thay vì xếp hàng, nếu không còn chỗ trống.

Kích thước khối dữ liệu phải nằm trong khoảng từ 64KiB (128 cung) đến 1GiB
    (2097152 lĩnh vực) bao gồm.


ii) Tình trạng

    ::

<id giao dịch> <khối siêu dữ liệu đã sử dụng>/<tổng khối siêu dữ liệu>
      <khối dữ liệu đã sử dụng>/<tổng khối dữ liệu> <gốc siêu dữ liệu được giữ>
      ro|rw|out_of_data_space [no_]discard_passdown [lỗi|hàng đợi]_if_no_space
      nhu cầu_check|- siêu dữ liệu_low_watermark

mã giao dịch:
	Số 64 bit được không gian người dùng sử dụng để giúp đồng bộ hóa với siêu dữ liệu
	từ các nhà quản lý khối lượng.

khối dữ liệu đã sử dụng/tổng khối dữ liệu
	Nếu số khối trống giảm xuống dưới vạch mực nước thấp của hồ bơi thì
	sự kiện dm sẽ được gửi đến không gian người dùng.  Sự kiện này được kích hoạt cạnh và
	nó sẽ chỉ xảy ra một lần sau mỗi lần tiếp tục nên người viết trình quản lý tập
	nên đăng ký sự kiện và sau đó kiểm tra trạng thái của mục tiêu.

gốc siêu dữ liệu được giữ:
	Vị trí, theo khối, của gốc siêu dữ liệu đã được
	'được giữ' để truy cập đọc không gian người dùng.  '-' cho biết không có
	đã bám rễ.

loại bỏ_passdown|no_discard_passdown
	Việc loại bỏ có thực sự được chuyển đến
	thiết bị cơ bản.  Khi tính năng này được kích hoạt khi tải bảng,
	nó có thể bị vô hiệu hóa nếu thiết bị cơ bản không hỗ trợ nó.

ro|rw|out_of_data_space
	Nếu nhóm gặp phải một số loại lỗi thiết bị nhất định, nó sẽ
	chuyển sang chế độ siêu dữ liệu chỉ đọc trong đó không có thay đổi nào đối với
	siêu dữ liệu nhóm (như phân bổ các khối mới) được cho phép.

Trong những trường hợp nghiêm trọng, ngay cả chế độ chỉ đọc cũng được coi là không an toàn
	sẽ không có I/O nào được phép nữa và trạng thái sẽ chỉ
	chứa chuỗi 'Thất bại'.  Các công cụ khôi phục không gian người dùng
	thì nên sử dụng.

error_if_no_space|queue_if_no_space
	Nếu nhóm hết dung lượng dữ liệu hoặc siêu dữ liệu, nhóm sẽ
	xếp hàng hoặc báo lỗi IO dành cho thiết bị dữ liệu.  các
	mặc định là xếp hàng IO cho đến khi có thêm dung lượng hoặc
	'no_space_timeout' hết hạn.  Nhóm dm mỏng 'no_space_timeout'
	tham số mô-đun có thể được sử dụng để thay đổi thời gian chờ này - nó
	mặc định là 60 giây nhưng có thể bị tắt khi sử dụng giá trị 0.

nhu cầu_kiểm tra
	Thao tác siêu dữ liệu không thành công, dẫn đến Need_check
	cờ được đặt trong siêu khối của siêu dữ liệu.  Siêu dữ liệu
	thiết bị phải được hủy kích hoạt và kiểm tra/sửa chữa trước khi
	Thin-pool có thể được vận hành hoàn toàn trở lại.  '-' biểu thị
	Need_check chưa được đặt.

siêu dữ liệu_low_watermark:
	Giá trị của siêu dữ liệu hình mờ thấp trong khối.  Kernel thiết lập cái này
	giá trị nội bộ nhưng không gian người dùng cần biết giá trị này để
	xác định xem một sự kiện có phải do vượt qua ngưỡng này hay không.

iii) Tin nhắn

create_thin <dev id>
	Tạo một thiết bị mới được cung cấp mỏng.
	<dev id> là mã định danh 24 bit duy nhất tùy ý được chọn bởi
	người gọi.

create_snap <dev id> <id gốc>
	Tạo ảnh chụp nhanh mới của một thiết bị được cung cấp mỏng khác.
	<dev id> là mã định danh 24 bit duy nhất tùy ý được chọn bởi
	người gọi.
	<origin id> là mã định danh của thiết bị được cung cấp mỏng
	trong đó thiết bị mới sẽ là ảnh chụp nhanh.

xóa <id nhà phát triển>
	Xóa một thiết bị mỏng.  Không thể đảo ngược.

set_transaction_id <id hiện tại> <id mới>
	Trình quản lý khối lượng người dùng, chẳng hạn như LVM, cần một cách để
	đồng bộ hóa siêu dữ liệu bên ngoài của họ với siêu dữ liệu bên trong của
	mục tiêu nhóm.  Mục tiêu nhóm mỏng cung cấp để lưu trữ một
	id giao dịch 64-bit tùy ý và trả lại nó trên mục tiêu
	dòng trạng thái.  Để tránh các cuộc đua, bạn phải cung cấp những gì bạn nghĩ
	id giao dịch hiện tại là khi bạn thay đổi nó bằng cái này
	tin nhắn so sánh và trao đổi.

dự trữ_metadata_snap
        Dự trữ một bản sao của btree ánh xạ dữ liệu để người dùng sử dụng.
        Điều này cho phép người dùng kiểm tra ánh xạ như khi
        tin nhắn này đã được thực thi.  Sử dụng lệnh trạng thái của nhóm để
        lấy khối gốc được liên kết với ảnh chụp nhanh siêu dữ liệu.

phát hành_metadata_snap
        Phát hành một bản sao đã được đặt trước của btree ánh xạ dữ liệu.

mục tiêu 'mỏng'
-------------

i) Nhà xây dựng

    ::

mỏng <pool dev> <dev id> [<nhà phát triển nguồn gốc bên ngoài>]

nhà phát triển nhóm:
	thiết bị bể bơi mỏng, ví dụ: /dev/mapper/my_pool hoặc 253:0

id nhà phát triển:
	mã định danh thiết bị bên trong của thiết bị sẽ được
	được kích hoạt.

nhà phát triển nguồn gốc bên ngoài:
	một thiết bị khối tùy chọn bên ngoài nhóm được coi là một
	Nguồn gốc ảnh chụp nhanh chỉ đọc: đọc vào các khu vực không được cung cấp của
	mục tiêu mỏng sẽ được ánh xạ tới thiết bị này.

Bể bơi không lưu trữ bất kỳ kích thước nào so với các thiết bị mỏng.  Nếu bạn
tải một mục tiêu mỏng nhỏ hơn mục tiêu bạn đã sử dụng trước đây,
thì bạn sẽ không có quyền truy cập vào các khối được ánh xạ ở phía cuối.  Nếu bạn
tải một mục tiêu lớn hơn trước, sau đó sẽ có thêm các khối
được cung cấp khi và khi cần thiết.

ii) Tình trạng

<nr khu vực được ánh xạ> <khu vực được ánh xạ cao nhất>
	Nếu nhóm gặp lỗi thiết bị và không thành công, trạng thái
	sẽ chỉ chứa chuỗi 'Thất bại'.  Phục hồi không gian người dùng
	thì nên sử dụng các công cụ này.

Trong trường hợp <nr Mapped Sector> bằng 0 thì không có giá trị cao nhất
    khu vực được ánh xạ và giá trị của <khu vực được ánh xạ cao nhất> không được chỉ định.
