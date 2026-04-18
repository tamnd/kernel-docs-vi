.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-integrity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
dm-toàn vẹn
=============

Mục tiêu toàn vẹn dm mô phỏng một thiết bị khối có thêm
thẻ theo từng ngành có thể được sử dụng để lưu trữ thông tin về tính toàn vẹn.

Một vấn đề chung khi lưu trữ các thẻ toàn vẹn với mọi lĩnh vực là
ghi khu vực và thẻ toàn vẹn phải là nguyên tử - tức là trong trường hợp
sự cố, cả thẻ khu vực và thẻ toàn vẹn hoặc không có thẻ nào được ghi.

Để đảm bảo tính nguyên tử của việc ghi, mục tiêu toàn vẹn dm sử dụng nhật ký, nó
ghi dữ liệu ngành và các thẻ toàn vẹn vào một tạp chí, cam kết tạp chí
rồi sao chép dữ liệu và thẻ toàn vẹn vào vị trí tương ứng của chúng.

Mục tiêu toàn vẹn dm có thể được sử dụng với mục tiêu dm-crypt - trong trường hợp này
tình huống mục tiêu dm-crypt tạo ra dữ liệu toàn vẹn và chuyển chúng
đến mục tiêu toàn vẹn dm thông qua bio_integrity_payload được đính kèm với tiểu sử.
Trong chế độ này, các mục tiêu dm-crypt và dm-toàn vẹn cung cấp thông tin xác thực
mã hóa ổ đĩa - nếu kẻ tấn công sửa đổi thiết bị được mã hóa, I/O
lỗi được trả về thay vì dữ liệu ngẫu nhiên.

Mục tiêu toàn vẹn dm cũng có thể được sử dụng như một mục tiêu độc lập, trong trường hợp này
chế độ nó tính toán và xác minh thẻ toàn vẹn trong nội bộ. Trong này
chế độ, mục tiêu toàn vẹn dm có thể được sử dụng để phát hiện dữ liệu im lặng
hỏng trên đĩa hoặc trong đường dẫn I/O.

Có một chế độ hoạt động thay thế trong đó dm-integrity sử dụng bitmap
thay vì một cuốn nhật ký. Nếu một bit trong bitmap là 1 thì tương ứng
dữ liệu của khu vực và thẻ toàn vẹn không được đồng bộ hóa - nếu máy
gặp sự cố, các vùng không đồng bộ sẽ được tính toán lại. Chế độ bitmap
nhanh hơn chế độ ghi nhật ký vì chúng ta không phải ghi dữ liệu
hai lần, nhưng nó cũng kém tin cậy hơn, vì nếu dữ liệu bị hỏng
khi máy gặp sự cố có thể không phát hiện được.

Khi tải mục tiêu lần đầu tiên, trình điều khiển kernel sẽ định dạng
thiết bị. Nhưng nó sẽ chỉ định dạng thiết bị nếu siêu khối chứa
số không. Nếu siêu khối không hợp lệ cũng không bằng 0, thì tính toàn vẹn dm
mục tiêu không thể được tải.

Quyền truy cập vào khu vực siêu dữ liệu trên đĩa có chứa tổng kiểm tra (còn gọi là thẻ) được
được đệm bằng dm-bufio. Khi quyền truy cập vào bất kỳ khu vực siêu dữ liệu cụ thể nào
xảy ra, mỗi vùng siêu dữ liệu duy nhất sẽ có (các) bộ đệm riêng. Kích thước bộ đệm
được giới hạn ở kích thước của vùng siêu dữ liệu, nhưng có thể nhỏ hơn, do đó
yêu cầu nhiều bộ đệm để thể hiện toàn bộ khu vực siêu dữ liệu. Nhỏ hơn
kích thước bộ đệm sẽ tạo ra thao tác đọc/ghi kết quả nhỏ hơn đối với
khu vực siêu dữ liệu để đọc/ghi nhỏ. Siêu dữ liệu vẫn được đọc ngay cả trong
ghi đầy đủ vào dữ liệu được bao phủ bởi một bộ đệm duy nhất.

Để sử dụng mục tiêu lần đầu tiên:

1. ghi đè siêu khối bằng số 0
2. tải mục tiêu toàn vẹn dm với kích thước một cung, trình điều khiển hạt nhân
   sẽ định dạng thiết bị
3. dỡ bỏ mục tiêu toàn vẹn dm
4. đọc giá trị "provided_data_sectors" từ siêu khối
5. tải mục tiêu toàn vẹn dm với kích thước mục tiêu
   "được cung cấp_data_sector"
6. nếu bạn muốn sử dụng tính toàn vẹn của dm với dm-crypt, hãy tải mục tiêu dm-crypt
   với kích thước "provided_data_sectors"


Đối số mục tiêu:

1. thiết bị khối cơ bản

2. số lượng khu vực dành riêng ở đầu thiết bị -
   dm-integrity sẽ không đọc hoặc ghi các lĩnh vực này

3. kích thước của thẻ toàn vẹn (nếu sử dụng "-", kích thước được lấy từ
   thuật toán băm nội bộ)

4. chế độ:

D - viết trực tiếp (không có tạp chí)
		ở chế độ này, ghi nhật ký là
		không được sử dụng và các phần dữ liệu và thẻ toàn vẹn được ghi
		riêng biệt. Trong trường hợp xảy ra sự cố, có thể dữ liệu
		và thẻ toàn vẹn không khớp.
	J - viết nhật ký
		thẻ dữ liệu và tính toàn vẹn được ghi vào
		tạp chí và tính nguyên tử được đảm bảo. Trong trường hợp gặp sự cố,
		cả dữ liệu và thẻ hoặc không có dữ liệu nào được ghi. các
		chế độ ghi nhật ký làm giảm thông lượng ghi hai lần vì
		dữ liệu phải được viết hai lần.
	B - chế độ bitmap - dữ liệu và siêu dữ liệu được ghi mà không có bất kỳ
		đồng bộ hóa, trình điều khiển duy trì một bitmap bẩn
		các khu vực nơi dữ liệu và siêu dữ liệu không khớp. Chế độ này có thể
		chỉ được sử dụng với hàm băm nội bộ.
	R - chế độ khôi phục - ở chế độ này, nhật ký không được phát lại,
		tổng kiểm tra không được kiểm tra và ghi vào thiết bị không
		được phép. Chế độ này rất hữu ích cho việc phục hồi dữ liệu nếu
		thiết bị không thể được kích hoạt theo bất kỳ tiêu chuẩn nào khác
		chế độ.
	I - chế độ nội tuyến - ở chế độ này, dm-integrity sẽ lưu trữ tính toàn vẹn
		dữ liệu trực tiếp trong các lĩnh vực thiết bị cơ bản.
		Thiết bị cơ bản phải có hồ sơ toàn vẹn
		cho phép lưu trữ dữ liệu toàn vẹn của người dùng và cung cấp đủ
		khoảng trống cho thẻ toàn vẹn đã chọn.

5. số lượng đối số bổ sung

Đối số bổ sung:

tạp chí_sector: số
	Kích thước của tạp chí, đối số này chỉ được sử dụng nếu định dạng
	thiết bị. Nếu thiết bị đã được định dạng, giá trị từ
	siêu khối được sử dụng.

interleave_sectors:số (mặc định 32768)
	Số lượng các lĩnh vực xen kẽ. Giá trị này được làm tròn xuống
	sức mạnh của hai. Nếu thiết bị đã được định dạng, giá trị từ
	siêu khối được sử dụng.

meta_device:thiết bị
	Không xen kẽ dữ liệu và siêu dữ liệu trên thiết bị. Sử dụng một
	thiết bị riêng biệt cho siêu dữ liệu.

buffer_sectors:số (mặc định 128)
	Số lượng các lĩnh vực trong một bộ đệm siêu dữ liệu. Giá trị được làm tròn
	xuống lũy thừa hai.

tạp chí_watermark: số (mặc định 50)
	Hình mờ tạp chí theo phần trăm. Khi kích thước của tạp chí
	vượt quá hình mờ này, chủ đề xóa tạp chí sẽ
	được bắt đầu.

commit_time:number (mặc định 10000)
	Cam kết thời gian tính bằng mili giây. Khi thời gian này trôi qua, nhật ký sẽ
	được viết. Nhật ký cũng được viết ngay nếu FLUSH
	yêu cầu được nhận.

Internal_hash:algorithm(:key) (khóa là tùy chọn)
	Sử dụng hàm băm hoặc crc nội bộ.
	Khi đối số này được sử dụng, mục tiêu toàn vẹn dm sẽ không chấp nhận
	thẻ toàn vẹn từ mục tiêu phía trên, nhưng nó sẽ tự động
	tạo và xác minh các thẻ toàn vẹn.

Bạn có thể sử dụng thuật toán crc (chẳng hạn như crc32), sau đó là mục tiêu toàn vẹn
	sẽ bảo vệ dữ liệu khỏi bị hư hỏng do tai nạn.
	Bạn cũng có thể sử dụng thuật toán hmac (ví dụ:
	"hmac(sha256):0123456789abcdef"), ở chế độ này nó sẽ cung cấp
	xác thực mật mã của dữ liệu mà không cần mã hóa.

Khi đối số này không được sử dụng, thẻ toàn vẹn sẽ được chấp nhận
	từ mục tiêu lớp trên, chẳng hạn như dm-crypt. Lớp trên
	mục tiêu nên kiểm tra tính hợp lệ của các thẻ toàn vẹn.

tính toán lại
	Tự động tính toán lại các thẻ toàn vẹn. Nó chỉ có hiệu lực
	khi sử dụng hàm băm nội bộ.

tạp chí_crypt:algorithm(:key) (khóa là tùy chọn)
	Mã hóa tạp chí bằng thuật toán đã cho để đảm bảo rằng
	kẻ tấn công không thể đọc nhật ký. Bạn có thể sử dụng mật mã khối tại đây
	(chẳng hạn như "cbc(aes)") hoặc mật mã luồng (ví dụ "chacha20"
	hoặc "ctr(aes)").

Nhật ký chứa lịch sử ghi lần cuối vào thiết bị khối,
	kẻ tấn công đọc nhật ký có thể thấy số ngành cuối cùng
	đã được viết. Từ số khu vực, kẻ tấn công có thể suy ra
	kích thước của tập tin đã được viết. Để bảo vệ chống lại điều này
	tình huống, bạn có thể mã hóa tạp chí.

tạp chí_mac:algorithm(:key) (khóa là tùy chọn)
	Bảo vệ số ngành trong tạp chí khỏi sự vô tình hoặc độc hại
	sửa đổi. Để bảo vệ khỏi việc vô tình sửa đổi, hãy sử dụng
	thuật toán crc, để bảo vệ khỏi sửa đổi độc hại, hãy sử dụng thuật toán
	thuật toán hmac có khóa.

Tùy chọn này không cần thiết khi sử dụng hàm băm nội bộ vì trong trường hợp này
	chế độ, tính toàn vẹn của các mục nhật ký được kiểm tra khi phát lại
	tạp chí. Do đó, số ngành được sửa đổi sẽ được phát hiện tại
	giai đoạn này.

block_size:number (mặc định 512)
	Kích thước của khối dữ liệu tính bằng byte. Kích thước khối càng lớn thì
	có ít chi phí hơn cho siêu dữ liệu về tính toàn vẹn trên mỗi khối.
	Các giá trị được hỗ trợ là 512, 1024, 2048 và 4096 byte.

ngành_per_bit:số
	Trong chế độ bitmap, tham số này chỉ định số lượng
	Các cung 512 byte tương ứng với một bit bitmap.

bitmap_flush_interval:số
	Khoảng thời gian xóa bitmap tính bằng mili giây. Bộ đệm siêu dữ liệu
	được đồng bộ hóa khi khoảng thời gian này hết hạn.

allow_discards
	Cho phép yêu cầu loại bỏ khối (còn gọi là TRIM) đối với thiết bị toàn vẹn.
	Việc loại bỏ chỉ được phép đối với các thiết bị sử dụng hàm băm nội bộ.

fix_padding
	Sử dụng phần đệm nhỏ hơn của vùng thẻ
	không gian hiệu quả. Nếu tùy chọn này không xuất hiện, phần đệm lớn sẽ được
	được sử dụng - đó là để tương thích với các hạt nhân cũ hơn.

fix_hmac
	Cải thiện tính bảo mật của Internal_hash và Journal_mac:

- số phần được trộn với mac, để kẻ tấn công không thể
	  sao chép các lĩnh vực từ phần tạp chí này sang phần tạp chí khác
	- siêu khối được bảo vệ bởi tạp chí_mac
	- một muối 16 byte được lưu trữ trong siêu khối được trộn vào mac, vì vậy
	  kẻ tấn công không thể phát hiện ra rằng hai đĩa có cùng hmac
	  khóa và cũng để không cho phép kẻ tấn công di chuyển các khu vực từ một khu vực
	  đĩa này sang đĩa khác

kế thừa_retính toán
	Cho phép tính toán lại âm lượng bằng phím HMAC. Điều này bị vô hiệu hóa bởi
	mặc định vì lý do bảo mật - kẻ tấn công có thể sửa đổi âm lượng,
	đặt recalc_sector về 0 và kernel sẽ không phát hiện được
	sửa đổi.

Chế độ nhật ký (D/J), buffer_sectors, tạp chí_watermark, commit_time và
allow_discards có thể được thay đổi khi tải lại mục tiêu (tải một mục tiêu không hoạt động
table và hoán đổi các bảng bằng cách tạm dừng và tiếp tục). Những lý lẽ khác
không nên thay đổi khi tải lại mục tiêu vì cách bố trí đĩa
dữ liệu phụ thuộc vào chúng và mục tiêu được tải lại sẽ không hoạt động.

Ví dụ: trên một thiết bị sử dụng interleave_sector mặc định là 32768,
block_size là 512 và Internal_hash của crc32c với kích thước thẻ là 4
byte, sẽ cần 128 KiB thẻ để theo dõi toàn bộ vùng dữ liệu, yêu cầu
256 lĩnh vực siêu dữ liệu trên mỗi vùng dữ liệu. Với buffer_sector mặc định của
128, điều đó có nghĩa là sẽ có 2 bộ đệm cho mỗi vùng siêu dữ liệu hoặc 2 bộ đệm
trên 16 MiB dữ liệu.

Dòng trạng thái:

1. số lượng tính toàn vẹn không khớp
2. cung cấp các lĩnh vực dữ liệu - đó là số lĩnh vực mà người dùng
   có thể sử dụng
3. vị trí tính toán lại hiện tại (hoặc '-' nếu chúng tôi không tính toán lại)


Bố cục của thiết bị khối được định dạng:

* lĩnh vực dành riêng
    (chúng không được sử dụng bởi mục tiêu này, chúng có thể được sử dụng cho
    lưu trữ siêu dữ liệu LUKS hoặc cho mục đích khác), kích thước của dữ liệu dành riêng
    khu vực được chỉ định trong các đối số mục tiêu

* siêu khối (4kiB)
	* chuỗi ma thuật - xác định rằng thiết bị đã được định dạng
	* phiên bản
	* log2(các cung xen kẽ)
	* kích thước thẻ toàn vẹn
	* số lượng phần tạp chí
	* cung cấp các lĩnh vực dữ liệu - số lĩnh vực mà mục tiêu này
	  cung cấp (tức là kích thước của thiết bị trừ đi kích thước của tất cả
	  siêu dữ liệu và phần đệm). Người sử dụng mục tiêu này không nên gửi
	  bios truy cập dữ liệu vượt quá giới hạn "cung cấp dữ liệu".
	* cờ
	    SB_FLAG_HAVE_JOURNAL_MAC
		- cờ được đặt nếu sử dụng tạp chí_mac
	    SB_FLAG_RECALCULATING
		- đang tính toán lại
	    SB_FLAG_DIRTY_BITMAP
		- khu vực nhật ký chứa bitmap bẩn
		  khối
	* log2(cung trên mỗi khối)
	* vị trí tính toán lại đã hoàn tất
* tạp chí
	Tạp chí được chia thành các phần, mỗi phần bao gồm:

* vùng siêu dữ liệu (4kiB), nó chứa các mục nhật ký

- mỗi mục nhật ký có chứa:

* khu vực logic (chỉ định nơi dữ liệu và thẻ sẽ
		  được viết)
		* 8 byte dữ liệu cuối cùng
		* thẻ toàn vẹn (kích thước được chỉ định trong siêu khối)

- mọi lĩnh vực siêu dữ liệu đều kết thúc bằng

* mac (8 byte), tất cả các máy mac trong 8 lĩnh vực siêu dữ liệu tạo thành một
		  Giá trị 64 byte. Nó được sử dụng để lưu trữ hmac của ngành
		  số trong phần tạp chí, để bảo vệ chống lại một
		  khả năng kẻ tấn công giả mạo khu vực
		  số trong nhật ký.
		* id cam kết

* vùng dữ liệu (kích thước có thể thay đổi; nó phụ thuộc vào số lượng tạp chí
	  các mục phù hợp với khu vực siêu dữ liệu)

- Mỗi lĩnh vực trong vùng dữ liệu chứa:

* dữ liệu (504 byte dữ liệu, 8 byte cuối cùng được lưu trữ trong
		  mục nhật ký)
		* id cam kết

Để kiểm tra xem toàn bộ phần nhật ký có được viết đúng hay không, mỗi
	Khu vực 512 byte của nhật ký kết thúc bằng id xác nhận 8 byte. Nếu
	id cam kết khớp với tất cả các lĩnh vực trong một phần tạp chí, thì đó là
	cho rằng phần này đã được viết chính xác. Nếu id cam kết
	không khớp, phần này được viết một phần và lẽ ra không nên
	được phát lại.

* một hoặc nhiều lượt thẻ và dữ liệu xen kẽ.
    Mỗi lần chạy chứa:

* vùng thẻ - nó chứa các thẻ toàn vẹn. Có một thẻ cho mỗi
	  lĩnh vực trong vùng dữ liệu. Kích thước của vùng này luôn là 4KiB hoặc
	  lớn hơn.
	* vùng dữ liệu - nó chứa các lĩnh vực dữ liệu. Số lượng lĩnh vực dữ liệu
	  trong một lần chạy phải là sức mạnh của hai. log2 của giá trị này được lưu trữ
	  trong siêu khối.
