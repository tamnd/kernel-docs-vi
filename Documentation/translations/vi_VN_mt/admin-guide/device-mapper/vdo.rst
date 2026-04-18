.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/vdo.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
dm-vdo
======

Mục tiêu ánh xạ thiết bị dm-vdo (trình tối ưu hóa dữ liệu ảo) cung cấp
chống trùng lặp, nén và cung cấp mỏng ở cấp khối. Là một thiết bị
mục tiêu của người lập bản đồ, nó có thể thêm các tính năng này vào ngăn xếp lưu trữ, tương thích
với bất kỳ hệ thống tập tin nào. Mục tiêu vdo không bảo vệ khỏi dữ liệu
tham nhũng, thay vào đó dựa vào việc bảo vệ tính toàn vẹn của bộ lưu trữ bên dưới
nó. Chúng tôi thực sự khuyên bạn nên sử dụng lvm để quản lý khối lượng vdo. Xem
lvmvdo(7).

Thành phần không gian người dùng
================================

Việc định dạng ổ đĩa vdo yêu cầu sử dụng công cụ 'vdoformat', có sẵn
tại:

ZZ0000ZZ

Trong hầu hết các trường hợp, mục tiêu vdo sẽ tự động phục hồi sau sự cố
lần tiếp theo nó được bắt đầu. Trong trường hợp nó gặp phải một lỗi không thể phục hồi
lỗi (trong quá trình hoạt động bình thường hoặc khôi phục sự cố) mục tiêu sẽ
nhập hoặc xuất hiện ở chế độ chỉ đọc. Bởi vì chế độ chỉ đọc là biểu thị của
mất dữ liệu, phải thực hiện hành động tích cực để đưa vdo ra khỏi chế độ chỉ đọc
chế độ. Công cụ 'vdoforcerebuild', có sẵn từ cùng một kho lưu trữ, được sử dụng để
chuẩn bị một vdo chỉ đọc để thoát khỏi chế độ chỉ đọc. Sau khi chạy công cụ này,
mục tiêu vdo sẽ xây dựng lại siêu dữ liệu của nó vào lần tiếp theo
bắt đầu. Mặc dù một số dữ liệu có thể bị mất nhưng siêu dữ liệu của vdo được xây dựng lại sẽ
nhất quán nội bộ và mục tiêu sẽ có thể ghi lại được.

Kho lưu trữ cũng chứa các công cụ không gian người dùng bổ sung có thể được sử dụng để
kiểm tra siêu dữ liệu trên đĩa của mục tiêu vdo. May mắn thay, những công cụ này
hiếm khi cần thiết ngoại trừ các nhà phát triển dm-vdo.

Yêu cầu về siêu dữ liệu
=======================

Mỗi ổ vdo dành 3GB dung lượng cho siêu dữ liệu hoặc nhiều hơn tùy thuộc vào
cấu hình của nó. Sẽ rất hữu ích khi kiểm tra xem dung lượng được lưu bởi
siêu dữ liệu không loại bỏ sự trùng lặp và nén
yêu cầu. Việc ước tính không gian được lưu cho một tập dữ liệu cụ thể có thể
được tính toán bằng công cụ ước tính vdo, có sẵn tại:

ZZ0000ZZ

Giao diện mục tiêu
==================

Dòng bảng
----------

::

<offset> <kích thước thiết bị logic> vdo V4 <thiết bị lưu trữ>
	<kích thước thiết bị lưu trữ> <kích thước I/O tối thiểu> <kích thước bộ đệm bản đồ khối>
	<độ dài kỷ nguyên bản đồ khối> [đối số tùy chọn]


Các thông số bắt buộc:

bù đắp:
		Phần bù, theo các cung, tại đó khối lượng vdo hợp lý
		không gian bắt đầu.

kích thước thiết bị logic:
		Kích thước của thiết bị mà âm lượng vdo sẽ phục vụ,
		trong các lĩnh vực. Phải phù hợp với kích thước logic hiện tại của vdo
		khối lượng.

thiết bị lưu trữ:
		Thiết bị chứa dữ liệu và siêu dữ liệu của ổ vdo.

kích thước thiết bị lưu trữ:
		Kích thước của thiết bị giữ âm lượng vdo, dưới dạng số
		khối 4096 byte. Phải phù hợp với kích thước hiện tại của vdo
		khối lượng.

kích thước I/O tối thiểu:
		Kích thước I/O tối thiểu để ổ vdo này chấp nhận, ở
		byte. Giá trị hợp lệ là 512 hoặc 4096. Giá trị được đề xuất
		là 4096.

chặn kích thước bộ đệm bản đồ:
		Kích thước của bộ đệm bản đồ khối, tính bằng số 4096 byte
		khối. Giá trị tối thiểu và được đề xuất là 32768 khối.
		Nếu số lượng luồng logic khác 0, kích thước bộ đệm
		phải có ít nhất 4096 khối trên mỗi luồng logic.

độ dài kỷ nguyên bản đồ khối:
		Tốc độ ghi của bộ đệm bản đồ khối
		các trang bản đồ khối được sửa đổi. Độ dài thời đại nhỏ hơn có thể sẽ
		giảm lượng thời gian dành cho việc xây dựng lại, với chi phí
		ghi bản đồ khối tăng lên trong quá trình hoạt động bình thường. các
		giá trị tối đa và được đề xuất là 16380; giá trị tối thiểu
		là 1.

Các thông số tùy chọn:
----------------------
Một số hoặc tất cả các tham số này có thể được chỉ định dưới dạng cặp <key> <value>.

Các tham số liên quan đến chủ đề:

Các danh mục công việc khác nhau được phân công cho các nhóm chủ đề riêng biệt và
số lượng chủ đề trong mỗi nhóm có thể được cấu hình riêng biệt.

Nếu <hash>, <logic> và <physical> đều được đặt thành 0 thì công việc được xử lý bởi
cả ba loại luồng sẽ được xử lý bởi một luồng duy nhất. Nếu bất kỳ trong số này
các giá trị khác 0, tất cả chúng phải khác 0.

ACK:
		Số lượng chủ đề được sử dụng để hoàn thành bios. Kể từ khi
		hoàn thành tiểu sử gọi một chức năng hoàn thành tùy ý
		bên ngoài âm lượng vdo, các luồng thuộc loại này cho phép vdo
		khối lượng để tiếp tục xử lý các yêu cầu ngay cả khi sinh học
		việc hoàn thiện còn chậm. Mặc định là 1.

sinh học:
		Số lượng chủ đề được sử dụng để cấp bios cho cơ bản
		lưu trữ. Các chủ đề thuộc loại này cho phép âm lượng vdo
		tiếp tục xử lý các yêu cầu ngay cả khi gửi tiểu sử
		chậm. Mặc định là 4.

bioRotationInterval:
		Số lượng bios được xếp vào hàng đợi trên mỗi bio thread trước đó
		chuyển sang chủ đề tiếp theo. Giá trị phải lớn hơn
		hơn 0 và không quá 1024; mặc định là 64.

CPU:
		Số lượng luồng được sử dụng để thực hiện công việc chuyên sâu về CPU, chẳng hạn như
		như băm và nén. Mặc định là 1.

hàm băm:
		Số lượng chủ đề được sử dụng để quản lý so sánh dữ liệu cho
		chống trùng lặp dựa trên giá trị băm của khối dữ liệu. các
		mặc định là 0.

logic:
		Số lượng luồng được sử dụng để quản lý bộ nhớ đệm và khóa
		dựa trên địa chỉ logic của bios đến. Mặc định
		là 0; tối đa là 60.

vật lý:
		Số lượng luồng được sử dụng để quản lý việc quản trị
		thiết bị lưu trữ cơ bản. Tại thời điểm định dạng, kích thước bản sàn cho
		vdo được chọn; thiết bị lưu trữ vdo phải lớn
		đủ để có ít nhất 1 tấm cho mỗi sợi vật lý. các
		mặc định là 0; tối đa là 16.

Các thông số khác:

maxDiscard:
		Kích thước tối đa của sinh học loại bỏ được chấp nhận, tính bằng 4096 byte
		khối. Các yêu cầu I/O đối với ổ vdo thường được phân chia
		thành các khối 4096 byte và được xử lý tối đa 2048 khối mỗi lần.
		Tuy nhiên, việc loại bỏ các yêu cầu đối với ổ đĩa vdo có thể
		tự động chia thành kích thước lớn hơn, tối đa <maxDiscard>
		Các khối 4096 byte trong một tiểu sử và được giới hạn ở 1500
		tại một thời điểm. Tăng giá trị này có thể cung cấp tổng thể tốt hơn
		hiệu suất, với cái giá phải trả là độ trễ tăng lên cho
		yêu cầu loại bỏ cá nhân. Giá trị mặc định và tối thiểu là 1;
		tối đa là UINT_MAX / 4096.

sự trùng lặp:
		Liệu tính năng chống trùng lặp có được bật hay không. Mặc định là 'bật'; cái
		giá trị chấp nhận được là 'bật' và 'tắt'.

nén:
		Liệu tính năng nén có được bật hay không. Mặc định là 'tắt'; cái
		giá trị chấp nhận được là 'bật' và 'tắt'.

Sửa đổi thiết bị
-------------------

Một bảng đã sửa đổi có thể được tải vào một ổ vdo đang chạy, không bị treo.
Các sửa đổi sẽ có hiệu lực khi thiết bị được nối lại lần tiếp theo. các
các tham số có thể sửa đổi là <kích thước thiết bị logic>, <kích thước thiết bị vật lý>,
<maxDiscard>, <nén> và <loại bỏ trùng lặp>.

Nếu kích thước thiết bị logic hoặc kích thước thiết bị vật lý bị thay đổi, thì
vdo sơ yếu lý lịch thành công sẽ lưu trữ các giá trị mới và yêu cầu chúng trong tương lai
khởi nghiệp. Hai thông số này không thể giảm được. Thiết bị logic
kích thước không được vượt quá 4 PB. Kích thước thiết bị vật lý phải tăng ở mức
ít nhất 32832 khối 4096 byte nếu có và không được vượt quá kích thước của
thiết bị lưu trữ cơ bản. Ngoài ra, khi định dạng thiết bị vdo, một
kích thước bản sàn được chọn: kích thước thiết bị vật lý không bao giờ có thể tăng trên
kích thước cung cấp 8192 tấm và mỗi lần tăng phải đủ lớn để
thêm ít nhất một tấm mới.

Ví dụ:

Bắt đầu ổ đĩa vdo được định dạng trước đó với dung lượng logic 1 GB và 1 GB
không gian vật lý, lưu trữ vào/dev/dm-1 có dung lượng lớn hơn 1 GB.

::

dmsetup tạo vdo0 --table \
	"0 2097152 vdo V4 /dev/dm-1 262144 4096 32768 16380"

Tăng kích thước logic lên 4 GB.

::

dmsetup tải lại vdo0 --table \
	"0 8388608 vdo V4 /dev/dm-1 262144 4096 32768 16380"
	sơ yếu lý lịch dmsetup vdo0

Tăng kích thước vật lý lên 2 GB.

::

dmsetup tải lại vdo0 --table \
	"0 8388608 vdo V4 /dev/dm-1 524288 4096 32768 16380"
	sơ yếu lý lịch dmsetup vdo0

Tăng kích thước vật lý thêm 1 GB nữa và tăng các vùng loại bỏ tối đa.

::

dmsetup tải lại vdo0 --table \
	"0 10485760 vdo V4 /dev/dm-1 786432 4096 32768 16380 maxDiscard 8"
	sơ yếu lý lịch dmsetup vdo0

Dừng âm lượng vdo.

::

dmsetup xóa vdo0

Bắt đầu lại âm lượng vdo. Lưu ý rằng kích thước thiết bị logic và vật lý
vẫn phải khớp nhưng các thông số khác có thể thay đổi.

::

dmsetup tạo vdo1 --table \
	"0 10485760 vdo V4 /dev/dm-1 786432 512 65550 5000 hàm băm 1 logic 3 vật lý 2"

Tin nhắn
--------
Tất cả các thiết bị vdo đều chấp nhận tin nhắn dưới dạng:

::

tin nhắn dmsetup <tên mục tiêu> 0 <tên tin nhắn> <thông số tin nhắn>

Các tin nhắn là:

số liệu thống kê:
		Xuất ra chế độ xem hiện tại của số liệu thống kê vdo. Chủ yếu được sử dụng
		bởi chương trình không gian người dùng vdosstats để diễn giải kết quả
		bộ đệm.

cấu hình:
		Xuất thông tin cấu hình vdo hữu ích. Chủ yếu được sử dụng
		bởi những người dùng muốn tạo lại âm lượng VDO tương tự và
		muốn biết cấu hình tạo được sử dụng.

đổ:
		Kết xuất nhiều cấu trúc bên trong vào nhật ký hệ thống. Đây là
		không phải lúc nào cũng an toàn để chạy, vì vậy nó chỉ nên được sử dụng để gỡ lỗi
		một vdo treo. Các tham số tùy chọn để xác định cấu trúc
		bãi chứa là:

viopool: Nhóm I/O yêu cầu bios đến
			hồ bơi: Một từ đồng nghĩa của 'viopool'
			vdo: Hầu hết các cấu trúc quản lý dữ liệu trên đĩa
			hàng đợi: Thông tin cơ bản về từng luồng vdo
			chủ đề: Từ đồng nghĩa của 'hàng đợi'
			mặc định: Tương đương với 'hàng đợi vdo'
			all: Tất cả những điều trên.

kết xuất khi tắt máy:
		Thực hiện kết xuất mặc định vào lần tiếp theo vdo tắt.


Trạng thái
----------

::

<thiết bị> <chế độ vận hành> <đang khôi phục> <trạng thái chỉ mục>
    <trạng thái nén> <khối vật lý được sử dụng> <tổng khối vật lý>

thiết bị:
		Tên của tập vdo.

chế độ hoạt động:
		Chế độ hoạt động hiện tại của âm lượng vdo; giá trị có thể là
		'bình thường', 'đang phục hồi' (âm lượng đã phát hiện sự cố
		với siêu dữ liệu của nó và đang cố gắng tự sửa chữa) và
		'chỉ đọc' (đã xảy ra lỗi buộc vdo
		Volume chỉ hỗ trợ thao tác đọc và không ghi).

trong quá trình phục hồi:
		Âm lượng vdo hiện có ở chế độ khôi phục hay không;
		các giá trị có thể là 'đang phục hồi' hoặc '-' cho biết không
		đang hồi phục.

trạng thái chỉ số:
		Trạng thái hiện tại của chỉ mục chống trùng lặp trong vdo
		khối lượng; các giá trị có thể là 'đóng', 'đóng', 'lỗi',
		'ngoại tuyến', 'trực tuyến', 'mở' và 'không xác định'.

trạng thái nén:
		Trạng thái nén hiện tại trong ổ đĩa vdo; giá trị
		có thể là 'ngoại tuyến' và 'trực tuyến'.

khối vật lý được sử dụng:
		Số lượng khối vật lý được sử dụng bởi khối lượng vdo.

tổng số khối vật lý:
		Tổng số khối vật lý mà khối vdo có thể sử dụng;
		sự khác biệt giữa giá trị này và
		<khối vật lý đã sử dụng> là số khối vdo
		âm lượng còn lại trước khi đầy.

Yêu cầu bộ nhớ
===================

Mục tiêu vdo yêu cầu 38 MB RAM cố định cùng với số tiền sau
quy mô đó với mục tiêu:

- 1,15 MB RAM cho mỗi 1 MB kích thước bộ đệm bản đồ khối được định cấu hình. các
  bộ đệm bản đồ khối yêu cầu tối thiểu 150 MB.
- 1,6 MB RAM cho mỗi 1 TB không gian logic.
- 268 MB RAM cho mỗi 1 TB dung lượng lưu trữ vật lý được quản lý theo ổ đĩa.

Chỉ số chống trùng lặp yêu cầu bộ nhớ bổ sung sẽ thay đổi theo
kích thước của cửa sổ chống trùng lặp. Đối với các chỉ mục dày đặc, chỉ mục yêu cầu 1
GB RAM trên 1 TB cửa sổ. Đối với các chỉ mục thưa thớt, chỉ mục yêu cầu 1 GB
của RAM trên 10 TB cửa sổ. Cấu hình chỉ mục được đặt khi mục tiêu
được định dạng và không thể sửa đổi.

Thông số mô-đun
=================

Trình điều khiển vdo có tham số số 'log_level' điều khiển
tính chi tiết của việc ghi nhật ký từ trình điều khiển. Cài đặt mặc định là 6
(LOGLEVEL_INFO và các tin nhắn nghiêm trọng hơn).

Sử dụng thời gian chạy
======================

Khi sử dụng dm-vdo, điều quan trọng là phải biết cách thức hoạt động của nó.
hành vi khác với các mục tiêu lưu trữ khác.

- Không có gì đảm bảo rằng việc ghi đè lên các khối hiện có sẽ thành công.
  Bởi vì bộ lưu trữ cơ bản có thể được tham chiếu nhiều lần, ghi đè
  một khối hiện có thường yêu cầu vdo để có một khối miễn phí
  có sẵn.

- Khi các khối không còn được sử dụng nữa, hãy gửi yêu cầu loại bỏ các khối đó
  các khối cho phép vdo phát hành các tham chiếu cho các khối đó. Nếu vdo là
  được cung cấp ít, việc loại bỏ các khối không sử dụng là điều cần thiết để ngăn chặn
  mục tiêu hết dung lượng. Tuy nhiên, do sự chia sẻ của
  các khối trùng lặp, không có yêu cầu loại bỏ đối với bất kỳ khối logic nhất định nào
  đảm bảo lấy lại không gian.

- Giả sử bộ lưu trữ cơ bản thực hiện đúng yêu cầu xóa, vdo
  có khả năng phục hồi trước các sự cố, tuy nhiên, việc ghi không được thực hiện có thể có hoặc không
  tồn tại sau sự cố.

- Mỗi lần ghi vào mục tiêu vdo đòi hỏi một lượng xử lý đáng kể.
  Tuy nhiên, phần lớn công việc là có thể song song hóa được. Vì vậy, mục tiêu vdo
  đạt được thông lượng tốt hơn ở độ sâu I/O cao hơn và có thể hỗ trợ tới 2048
  yêu cầu song song.

điều chỉnh
==========

Thiết bị vdo có nhiều tùy chọn và khó có thể tối ưu
lựa chọn mà không có kiến thức hoàn hảo về khối lượng công việc. Ngoài ra, hầu hết
các tùy chọn cấu hình phải được đặt khi mục tiêu vdo được khởi động và không thể
được thay đổi mà không cần tắt hoàn toàn; cấu hình không thể
thay đổi khi mục tiêu đang hoạt động. Lý tưởng nhất là điều chỉnh bằng mô phỏng
khối lượng công việc phải được thực hiện trước khi triển khai vdo trong sản xuất
môi trường.

Giá trị quan trọng nhất cần điều chỉnh là kích thước bộ đệm của bản đồ khối. để
phục vụ một yêu cầu cho bất kỳ địa chỉ logic nào, vdo phải tải phần của
bản đồ khối chứa bản đồ liên quan. Những ánh xạ này được lưu trữ.
Hiệu suất sẽ bị ảnh hưởng khi tập công việc không vừa với bộ nhớ đệm. Bởi
mặc định, vdo phân bổ 128 MB bộ đệm siêu dữ liệu trong RAM để hỗ trợ
truy cập hiệu quả tới 100 GB không gian logic cùng một lúc. Nó nên được thu nhỏ
tăng tương ứng cho các bộ làm việc lớn hơn.

Số lượng luồng logic và vật lý cũng cần được điều chỉnh. Một logic
luồng kiểm soát một phần rời rạc của bản đồ khối, do đó logic bổ sung
các luồng tăng tính song song và có thể tăng thông lượng. Chủ đề vật lý
kiểm soát phần rời rạc của các khối dữ liệu, do đó vật lý bổ sung
chủ đề cũng có thể tăng thông lượng. Tuy nhiên, các chủ đề dư thừa có thể lãng phí
nguồn lực và tăng cường tranh chấp.

Các luồng gửi sinh học kiểm soát tính song song liên quan đến việc gửi I/O tới
kho lưu trữ cơ bản; ít chủ đề hơn có nghĩa là có nhiều cơ hội hơn để
sắp xếp lại các yêu cầu I/O vì lợi ích hiệu suất, đồng thời mỗi I/O
yêu cầu phải đợi lâu hơn trước khi được gửi.

Chuỗi phản hồi sinh học được sử dụng để hoàn tất các yêu cầu I/O. Đây là
được thực hiện trên các luồng chuyên dụng vì số lượng công việc cần thiết để thực thi một
Cuộc gọi lại của bio không thể được kiểm soát bởi chính vdo. Thông thường một sợi
là đủ nhưng các chủ đề bổ sung có thể có ích, đặc biệt khi
bios có các cuộc gọi lại nặng CPU.

Các luồng CPU được sử dụng để băm và nén; trong khối lượng công việc với
được kích hoạt nén, nhiều luồng hơn có thể mang lại thông lượng cao hơn.

Chuỗi băm được sử dụng để sắp xếp các yêu cầu đang hoạt động theo hàm băm và xác định xem liệu
họ nên loại bỏ trùng lặp; các hành động chuyên sâu nhất của CPU được thực hiện bởi những người này
chủ đề là so sánh các khối dữ liệu 4096 byte. Trong hầu hết các trường hợp, một đơn
chuỗi băm là đủ.