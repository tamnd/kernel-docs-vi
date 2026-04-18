.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/zonefs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
ZoneFS - Hệ thống tập tin vùng cho các thiết bị khối được khoanh vùng
================================================

Giới thiệu
============

Zonefs là một hệ thống tệp rất đơn giản hiển thị từng vùng của thiết bị khối được khoanh vùng
dưới dạng một tập tin. Không giống như hệ thống tệp tuân thủ POSIX thông thường với khối được khoanh vùng gốc
hỗ trợ thiết bị (ví dụ: f2fs), Zonefs không ẩn việc ghi tuần tự
hạn chế của các thiết bị khối được khoanh vùng đối với người dùng. Các tập tin biểu diễn tuần tự
vùng ghi của thiết bị phải được ghi tuần tự bắt đầu từ cuối
của tập tin (chỉ nối thêm ghi).

Như vậy, về bản chất, Zonefs gần với giao diện truy cập thiết bị khối thô hơn.
hơn là hệ thống tệp POSIX đầy đủ tính năng. Mục tiêu của Zonefs là đơn giản hóa
việc triển khai hỗ trợ thiết bị khối được khoanh vùng trong các ứng dụng bằng cách thay thế
truy cập tệp thiết bị khối thô bằng tệp API phong phú hơn, tránh dựa vào
chặn trực tiếp tệp thiết bị ioctls, điều này có thể khó hiểu hơn đối với các nhà phát triển. một
ví dụ về phương pháp này là việc triển khai LSM (hợp nhất có cấu trúc nhật ký)
cấu trúc cây (chẳng hạn như được sử dụng trong RocksDB và LevelDB) trên các thiết bị khối được khoanh vùng
bằng cách cho phép SSTables được lưu trữ trong tệp vùng tương tự như tệp thông thường
hệ thống chứ không phải là một phạm vi các lĩnh vực của toàn bộ đĩa. phần giới thiệu
của cấu trúc cấp cao hơn "một tệp là một vùng" có thể giúp giảm
số lượng thay đổi cần thiết trong ứng dụng cũng như giới thiệu sự hỗ trợ cho
ngôn ngữ lập trình ứng dụng khác nhau.

Thiết bị khối được khoanh vùng
-------------------

Các thiết bị lưu trữ được khoanh vùng thuộc loại thiết bị lưu trữ có địa chỉ
không gian được chia thành các khu vực. Một vùng là một nhóm các LBA liên tiếp và tất cả
các vùng liền kề nhau (không có khoảng trống LBA). Các khu vực có thể có nhiều loại khác nhau.

* Vùng thông thường: không có hạn chế truy cập đối với các LBA thuộc về
  các khu thông thường. Mọi quyền truy cập đọc hoặc ghi đều có thể được thực thi, tương tự như
  thiết bị khối thông thường.
* Vùng tuần tự: các vùng này chấp nhận đọc ngẫu nhiên nhưng phải được ghi
  một cách tuần tự. Mỗi vùng tuần tự có một con trỏ ghi được duy trì bởi
  thiết bị theo dõi vị trí bắt đầu LBA của lần ghi tiếp theo
  tới thiết bị. Do hạn chế ghi này, các LBA trong vùng tuần tự
  không thể bị ghi đè. Các vùng tuần tự trước tiên phải được xóa bằng cách sử dụng một công cụ đặc biệt
  lệnh (đặt lại vùng) trước khi viết lại.

Các thiết bị lưu trữ được khoanh vùng có thể được triển khai bằng cách sử dụng nhiều phương tiện ghi và phương tiện khác nhau
công nghệ. Hình thức lưu trữ được khoanh vùng phổ biến nhất hiện nay sử dụng SCSI Zoned storage
Giao diện Lệnh chặn (ZBC) và Lệnh ATA được khoanh vùng (ZAC) trên Shingled
Ổ cứng ghi từ tính (SMR).

Các thiết bị lưu trữ Đĩa thể rắn (SSD) cũng có thể triển khai giao diện được khoanh vùng
ví dụ, để giảm khả năng khuếch đại ghi nội bộ do thu gom rác.
Không gian tên được khoanh vùng NVMe (ZNS) là một đề xuất kỹ thuật của tiêu chuẩn NVMe
ủy ban nhằm mục đích bổ sung giao diện lưu trữ được khoanh vùng vào giao thức NVMe.

Tổng quan về Zonefs
===============

Zonefs hiển thị các vùng của thiết bị khối được khoanh vùng dưới dạng tệp. Các tập tin
các vùng đại diện được nhóm theo loại vùng, chúng được đại diện
bởi các thư mục con. Cấu trúc tệp này được xây dựng hoàn toàn bằng thông tin vùng
do thiết bị cung cấp và do đó không yêu cầu bất kỳ siêu dữ liệu phức tạp nào trên đĩa
cấu trúc.

Siêu dữ liệu trên đĩa
----------------

siêu dữ liệu trên đĩa của vùng được giảm xuống thành một siêu khối bất biến
liên tục lưu trữ một số ma thuật cũng như các cờ và giá trị tính năng tùy chọn. Bật
mount, Zonefs sử dụng blkdev_report_zones() để lấy cấu hình vùng thiết bị
và điền vào điểm gắn kết một cây tệp tĩnh chỉ dựa trên điều này
thông tin. Kích thước tệp đến từ loại vùng thiết bị và con trỏ ghi
vị trí do chính thiết bị quản lý.

Siêu khối luôn được ghi trên đĩa ở khu vực 0. Vùng đầu tiên của
thiết bị lưu trữ siêu khối không bao giờ được hiển thị dưới dạng tệp vùng bởi Zonefs. Nếu
vùng chứa siêu khối là vùng tuần tự, định dạng mkzonefs
Công cụ luôn "hoàn thành" vùng, nghĩa là nó chuyển vùng đó thành toàn bộ
chuyển sang trạng thái chỉ đọc, ngăn cản việc ghi dữ liệu.

Thư mục con loại vùng
-------------------------

Các tập tin đại diện cho các vùng cùng loại được nhóm lại với nhau dưới cùng một
thư mục con được tạo tự động trên mount.

Đối với các vùng thông thường, thư mục con "cnv" được sử dụng. Thư mục này là
tuy nhiên được tạo khi và chỉ khi thiết bị có các vùng thông thường có thể sử dụng được. Nếu
thiết bị chỉ có một vùng thông thường duy nhất ở khu vực 0, vùng này sẽ không
được hiển thị dưới dạng tệp vì nó sẽ được sử dụng để lưu trữ siêu khối Zonefs. cho
những thiết bị như vậy, thư mục con "cnv" sẽ không được tạo.

Đối với vùng ghi tuần tự, thư mục con "seq" được sử dụng.

Hai thư mục này là những thư mục duy nhất tồn tại trong Zonefs. Người dùng
không thể tạo các thư mục khác và không thể đổi tên cũng như xóa "cnv" và
thư mục con "seq".

Kích thước của các thư mục được biểu thị bằng trường st_size của struct stat,
thu được bằng lệnh gọi hệ thống stat() hoặc fstat(), cho biết số lượng tệp
hiện có trong thư mục.

Tệp vùng
----------

Các tệp vùng được đặt tên bằng cách sử dụng số vùng mà chúng đại diện trong tập hợp
của các vùng thuộc một loại cụ thể. Nghĩa là, cả thư mục "cnv" và "seq"
chứa các file có tên "0", "1", "2",... Các số file cũng thể hiện
tăng vùng bắt đầu khu vực trên thiết bị.

Tất cả các hoạt động đọc và ghi vào tệp vùng không được phép vượt quá tệp
kích thước tối đa, nghĩa là vượt quá dung lượng vùng. Bất kỳ quyền truy cập nào vượt quá vùng
dung lượng không thành công với lỗi -EFBIG.

Tạo, xóa, đổi tên hoặc sửa đổi bất kỳ thuộc tính nào của tệp và
thư mục con không được phép.

Số khối của một tập tin được báo cáo bởi stat() và fstat() cho biết
dung lượng của tệp vùng, hay nói cách khác là kích thước tệp tối đa.

Tập tin vùng thông thường
-----------------------

Kích thước của các tệp vùng thông thường được cố định theo kích thước của vùng mà chúng
đại diện. Các tập tin vùng thông thường không thể bị cắt bớt.

Các tệp này có thể được đọc và ghi ngẫu nhiên bằng bất kỳ loại thao tác I/O nào:
I/O được đệm, I/O trực tiếp, I/O được ánh xạ bộ nhớ (mmap), v.v. Không có I/O
ràng buộc đối với các tệp này vượt quá giới hạn kích thước tệp được đề cập ở trên.

Tệp vùng tuần tự
---------------------

Kích thước của các tệp vùng tuần tự được nhóm trong thư mục con "seq" thể hiện
vị trí con trỏ ghi vùng của tệp so với khu vực bắt đầu vùng.

Các tệp vùng tuần tự chỉ có thể được ghi tuần tự, bắt đầu từ tệp
cuối cùng, nghĩa là, thao tác ghi chỉ có thể được ghi thêm. Zonefs không đồng ý
cố gắng chấp nhận việc ghi ngẫu nhiên và sẽ không thực hiện được bất kỳ yêu cầu ghi nào có
phần bù bắt đầu không tương ứng với phần cuối của tệp hoặc phần cuối của tệp cuối cùng
write đã được phát hành và vẫn đang hoạt động (đối với các hoạt động I/O không đồng bộ).

Vì việc ghi lại trang bẩn bằng bộ đệm trang không đảm bảo một tuần tự
kiểu ghi, Zonefs ngăn việc ghi vào bộ đệm và ánh xạ chia sẻ có thể ghi
trên các tập tin tuần tự. Chỉ ghi I/O trực tiếp mới được chấp nhận cho các tệp này.
Zonefs dựa vào việc phân phối tuần tự các yêu cầu ghi I/O tới thiết bị
được thực hiện bởi thang máy lớp khối. Một thang máy thực hiện tuần tự
tính năng ghi cho thiết bị khối được khoanh vùng (tính năng thang máy ELEVATOR_F_ZBD_SEQ_WRITE)
phải được sử dụng. Loại thang máy này (ví dụ: mq-deadline) được đặt theo mặc định
cho các thiết bị khối được khoanh vùng khi khởi tạo thiết bị.

Không có hạn chế nào về loại I/O được sử dụng cho các hoạt động đọc trong
tập tin vùng tuần tự. I/O được đệm, I/O trực tiếp và ánh xạ đọc được chia sẻ là
tất cả đều được chấp nhận.

Việc cắt bớt các tệp vùng tuần tự chỉ được phép xuống còn 0, trong trường hợp đó,
vùng được đặt lại để tua lại vùng tập tin vị trí con trỏ ghi về điểm bắt đầu của
vùng hoặc tối đa dung lượng vùng, trong trường hợp đó vùng của tệp là
chuyển sang trạng thái FULL (vùng kết thúc).

Tùy chọn định dạng
--------------

Một số tính năng tùy chọn của vùng có thể được bật tại thời điểm định dạng.

* Tập hợp vùng thông thường: phạm vi của các vùng thông thường liền kề có thể được
  được tổng hợp thành một tệp lớn hơn thay vì một tệp mặc định cho mỗi vùng.
* Quyền sở hữu tệp: Chủ sở hữu UID và GID của các tệp vùng theo mặc định là 0 (root)
  nhưng có thể thay đổi thành bất kỳ UID/GID hợp lệ nào.
* Quyền truy cập tệp: có thể thay đổi quyền truy cập 640 mặc định.

Xử lý lỗi IO
-----------------

Các thiết bị khối được khoanh vùng có thể không thực hiện được các yêu cầu I/O vì những lý do tương tự như khối thông thường
thiết bị, ví dụ: do bad Sector. Tuy nhiên, ngoài các I/O đã biết như vậy
mô hình lỗi, các tiêu chuẩn quản lý hành vi của thiết bị khối được khoanh vùng xác định
điều kiện bổ sung dẫn đến lỗi I/O.

* Một vùng có thể chuyển sang điều kiện chỉ đọc (BLK_ZONE_COND_READONLY):
  Trong khi dữ liệu đã được ghi trong vùng vẫn có thể đọc được thì vùng đó có thể
  không còn được viết nữa. Không có hành động nào của người dùng trên vùng (lệnh quản lý vùng hoặc
  truy cập đọc/ghi) có thể thay đổi điều kiện vùng trở lại trạng thái đọc/ghi bình thường
  trạng thái. Trong khi các lý do khiến thiết bị chuyển vùng sang chỉ đọc
  trạng thái không được xác định bởi các tiêu chuẩn, một nguyên nhân điển hình cho sự chuyển đổi đó
  sẽ là đầu ghi bị lỗi trên HDD (tất cả các vùng dưới đầu này đều
  đã thay đổi thành chỉ đọc).

* Một vùng có thể chuyển sang trạng thái ngoại tuyến (BLK_ZONE_COND_OFFLINE):
  Vùng ngoại tuyến không thể đọc hoặc ghi. Không có hành động nào của người dùng có thể chuyển đổi một
  vùng ngoại tuyến trở lại trạng thái hoạt động tốt. Tương tự với vùng chỉ đọc
  chuyển đổi, lý do thúc đẩy chuyển đổi một vùng sang ngoại tuyến
  điều kiện không được xác định. Nguyên nhân điển hình là do đầu đọc ghi bị lỗi
  trên HDD khiến tất cả các vùng trên đĩa dưới đầu bị hỏng bị hỏng
  không thể truy cập được.

* Lỗi ghi không được căn chỉnh: Các lỗi này là do máy chủ phát hành lệnh ghi
  yêu cầu có khu vực bắt đầu không tương ứng với con trỏ ghi vùng
  vị trí khi yêu cầu ghi được thực hiện bởi thiết bị. Mặc dù Zonefs
  thực thi ghi tệp tuần tự cho các vùng tuần tự, lỗi ghi không được căn chỉnh
  vẫn có thể xảy ra trong trường hợp có lỗi một phần của I/O trực tiếp rất lớn.
  hoạt động được chia thành nhiều BIO/yêu cầu hoặc hoạt động I/O không đồng bộ.
  Nếu một trong các yêu cầu ghi trong tập hợp các yêu cầu ghi tuần tự
  cấp cho thiết bị không thành công, tất cả các yêu cầu ghi được xếp hàng đợi sau đó sẽ
  trở nên không liên kết và thất bại.

* Lỗi ghi trễ: tương tự như các thiết bị chặn thông thường, nếu phía thiết bị
  bộ đệm ghi được bật, lỗi ghi có thể xảy ra trong phạm vi trước đó
  ghi hoàn tất khi bộ đệm ghi của thiết bị bị xóa, ví dụ: trên fsync().
  Tương tự như trường hợp lỗi ghi không căn chỉnh ngay trước đó, ghi chậm
  lỗi có thể lan truyền qua luồng dữ liệu tuần tự được lưu trong bộ nhớ đệm cho một vùng
  khiến toàn bộ dữ liệu bị loại bỏ sau khu vực gây ra lỗi.

Tất cả các lỗi I/O được phát hiện bởi Zonefs đều được thông báo cho người dùng bằng mã lỗi
return cho lệnh gọi hệ thống đã kích hoạt hoặc phát hiện lỗi. Sự phục hồi
các hành động được thực hiện bởi các vùng để phản hồi các lỗi I/O phụ thuộc vào loại I/O (đọc
vs ghi) và lý do lỗi (khu vực xấu, ghi không được căn chỉnh hoặc vùng
thay đổi điều kiện).

* Đối với lỗi đọc I/O, Zonefs không thực hiện bất kỳ hành động khôi phục cụ thể nào,
  nhưng chỉ khi vùng tập tin vẫn ở tình trạng tốt và không có
  sự không nhất quán giữa kích thước nút tập tin và vị trí con trỏ ghi vùng của nó.
  Nếu phát hiện thấy sự cố, quá trình khôi phục lỗi I/O sẽ được thực hiện (xem bảng bên dưới).

* Đối với các lỗi ghi I/O, quá trình khôi phục lỗi I/O của vùng luôn được thực thi.

* Điều kiện vùng thay đổi thành chỉ đọc hoặc ngoại tuyến cũng luôn kích hoạt các vùng
  Phục hồi lỗi I/O.

Khôi phục lỗi I/O tối thiểu của Zonefs có thể thay đổi kích thước tệp và quyền truy cập tệp
quyền.

* Thay đổi kích thước tập tin:
  Lỗi ghi ngay lập tức hoặc bị trì hoãn trong tệp vùng tuần tự có thể khiến tệp
  kích thước inode không phù hợp với lượng dữ liệu được ghi thành công
  vùng tập tin. Ví dụ: lỗi một phần của thao tác ghi lớn nhiều BIO
  hoạt động sẽ làm cho con trỏ ghi vùng tiến lên một phần, mặc dù
  toàn bộ thao tác ghi sẽ được báo cáo là không thành công đối với người dùng. Trong đó
  trường hợp, kích thước nút tệp phải được nâng cao để phản ánh con trỏ ghi vùng
  thay đổi và cuối cùng cho phép người dùng bắt đầu viết lại khi kết thúc
  tập tin.
  Kích thước tệp cũng có thể bị giảm để phản ánh lỗi ghi bị trì hoãn được phát hiện trên
  fsync(): trong trường hợp này, lượng dữ liệu được ghi hiệu quả trong vùng có thể
  nhỏ hơn kích thước inode của tệp chỉ định ban đầu. Sau I/O như vậy
  bị lỗi, Zonefs luôn sửa kích thước inode của tệp để phản ánh lượng dữ liệu
  được lưu trữ liên tục trong vùng tập tin.

* Thay đổi quyền truy cập:
  Thay đổi điều kiện vùng thành chỉ đọc được biểu thị bằng thay đổi trong tệp
  quyền truy cập để hiển thị tệp chỉ đọc. Điều này vô hiệu hóa các thay đổi đối với
  thuộc tính tập tin và sửa đổi dữ liệu. Đối với vùng ngoại tuyến, tất cả các quyền
  (đọc và ghi) vào tập tin bị vô hiệu hóa.

Người dùng có thể kiểm soát hành động tiếp theo được thực hiện bởi việc khôi phục lỗi I/O của Zonefs
với tùy chọn gắn kết "error=xxx". Bảng dưới đây tóm tắt kết quả của
xử lý lỗi I/O của Zonefs tùy thuộc vào tùy chọn gắn kết và trên vùng
điều kiện::

+--------------+--------------+------------------------------------------+
    ZZ0000ZZ ZZ0001ZZ
    Thiết bị ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ vùng ZZ0005ZZ
    Tình trạng ZZ0006ZZ ZZ0007ZZ
    +--------------+--------------+------------------------------------------+
    ZZ0008ZZ tốt ZZ0009ZZ
    ZZ0010ZZ chỉ đọc ZZ0011ZZ
    ZZ0012ZZ ngoại tuyến ZZ0013ZZ
    +--------------+--------------+------------------------------------------+
    ZZ0014ZZ tốt ZZ0015ZZ
    ZZ0016ZZ chỉ đọc ZZ0017ZZ
    ZZ0018ZZ ngoại tuyến ZZ0019ZZ
    +--------------+--------------+------------------------------------------+
    ZZ0020ZZ tốt ZZ0021ZZ
    ZZ0022ZZ chỉ đọc ZZ0023ZZ
    ZZ0024ZZ ngoại tuyến ZZ0025ZZ
    +--------------+--------------+------------------------------------------+
    ZZ0026ZZ tốt ZZ0027ZZ
    ZZ0028ZZ chỉ đọc ZZ0029ZZ
    ZZ0030ZZ ngoại tuyến ZZ0031ZZ
    +--------------+--------------+------------------------------------------+

Ghi chú thêm:

* Tùy chọn gắn kết "errors=remount-ro" là hành vi mặc định của I/O vùng
  xử lý lỗi nếu không có tùy chọn gắn lỗi nào được chỉ định.
* Với tùy chọn gắn kết "errors=remount-ro", việc thay đổi quyền truy cập tệp
  quyền chỉ đọc áp dụng cho tất cả các tệp. Hệ thống tập tin được gắn lại
  chỉ đọc.
* Quyền truy cập và thay đổi kích thước tệp do vùng chuyển đổi thiết bị
  đến trạng thái ngoại tuyến là vĩnh viễn. Gắn lại hoặc định dạng lại thiết bị
  với mkfs.zonefs (mkzonefs) sẽ không thay đổi lại các tệp vùng ngoại tuyến thành tốt
  trạng thái.
* Quyền truy cập tệp thay đổi thành chỉ đọc do chuyển đổi thiết bị
  các vùng ở trạng thái chỉ đọc là vĩnh viễn. Gắn lại hoặc định dạng lại
  thiết bị sẽ không kích hoạt lại quyền truy cập ghi tập tin.
* Các thay đổi về quyền truy cập tệp được ngụ ý bởi remount-ro,zone-ro và
  Các tùy chọn gắn kết vùng ngoại tuyến chỉ là tạm thời đối với các vùng ở tình trạng tốt.
  Việc ngắt kết nối và kết nối lại hệ thống tập tin sẽ khôi phục mặc định trước đó
  (định dạng giá trị thời gian) quyền truy cập vào các tệp bị ảnh hưởng.
* Tùy chọn gắn sửa chữa chỉ kích hoạt bộ khôi phục lỗi I/O tối thiểu
  hành động, tức là sửa kích thước tệp cho các vùng ở tình trạng tốt. Khu vực
  được thiết bị cho biết là chỉ đọc hoặc ngoại tuyến vẫn hàm ý những thay đổi đối với
  quyền truy cập tệp vùng như đã lưu ý trong bảng trên.

Tùy chọn gắn kết
-------------

Zonefs xác định một số tùy chọn gắn kết:
* lỗi=<hành vi>
* rõ ràng-mở

tùy chọn "lỗi=<hành vi>"
~~~~~~~~~~~~~~~~~~~~~~~~~~

Tùy chọn gắn kết tùy chọn "errors=<behavior>" cho phép người dùng chỉ định các vùng
hành vi phản ứng với các lỗi I/O, sự không nhất quán về kích thước inode hoặc vùng
điều kiện thay đổi. Các hành vi được xác định như sau:

* remount-ro (mặc định)
* khu-ro
* khu vực ngoại tuyến
* sửa chữa

Các hành động lỗi I/O trong thời gian chạy được xác định cho từng hành vi được trình bày chi tiết trong
phần trước. Lỗi I/O thời gian gắn kết sẽ khiến thao tác gắn kết không thành công.
Việc xử lý các vùng chỉ đọc cũng khác nhau giữa thời gian gắn kết và thời gian chạy.
Nếu tìm thấy vùng chỉ đọc tại thời điểm gắn kết, vùng đó luôn được xử lý trong
theo cách tương tự như các vùng ngoại tuyến, nghĩa là tất cả các quyền truy cập đều bị vô hiệu hóa và vùng đó
kích thước tệp được đặt thành 0. Điều này là cần thiết vì con trỏ ghi của vùng chỉ đọc
được xác định là không hợp lệ theo tiêu chuẩn ZBC và ZAC, khiến không thể
khám phá lượng dữ liệu đã được ghi vào vùng. Trong trường hợp của một
vùng chỉ đọc được phát hiện trong thời gian chạy, như đã chỉ ra trong phần trước.
Kích thước của tệp vùng không thay đổi so với giá trị cập nhật cuối cùng của nó.

tùy chọn "rõ ràng-mở"
~~~~~~~~~~~~~~~~~~~~~~

Một thiết bị khối được khoanh vùng (ví dụ: thiết bị Không gian tên được khoanh vùng NVMe) có thể có các giới hạn về
số vùng có thể hoạt động, nghĩa là các vùng nằm trong
điều kiện mở ngầm, điều kiện mở hoặc đóng rõ ràng.  Hạn chế tiềm tàng này
chuyển thành rủi ro cho các ứng dụng gặp lỗi ghi IO do điều này
giới hạn bị vượt quá nếu vùng của tệp chưa hoạt động khi ghi
yêu cầu được đưa ra bởi người dùng.

Để tránh những lỗi tiềm ẩn này, tùy chọn gắn kết "rõ ràng-mở" buộc các vùng
được kích hoạt bằng cách sử dụng lệnh vùng mở khi tệp được mở để ghi
lần đầu tiên. Nếu lệnh mở vùng thành công thì ứng dụng sẽ được
đảm bảo rằng các yêu cầu ghi có thể được xử lý. Ngược lại,
Tùy chọn gắn kết "rõ ràng-mở" sẽ dẫn đến lệnh đóng vùng được ban hành
tới thiết bị ở lần đóng() cuối cùng của tệp vùng nếu vùng đó không đầy hoặc
trống rỗng.

Thuộc tính sysfs thời gian chạy
------------------------

Zonefs xác định một số thuộc tính sysfs cho các thiết bị được gắn kết.  Tất cả thuộc tính
người dùng có thể đọc được và có thể tìm thấy trong thư mục /sys/fs/zonefs/<dev>/,
trong đó <dev> là tên của thiết bị khối được khoanh vùng được gắn kết.

Các thuộc tính được xác định như sau.

* ZZ0000ZZ: Thuộc tính này báo cáo số lượng tối đa
  các tập tin vùng tuần tự có thể được mở để ghi.  Con số này tương ứng
  đến số vùng mở tối đa rõ ràng hoặc ngầm định mà thiết bị
  hỗ trợ.  Giá trị 0 có nghĩa là thiết bị không có giới hạn và bất kỳ vùng nào
  (bất kỳ tệp nào) có thể được mở để ghi và ghi vào bất kỳ lúc nào, bất kể
  trạng thái của các khu vực khác.  Khi tùy chọn gắn ZZ0004ZZ được sử dụng, các vùng
  sẽ thất bại bất kỳ cuộc gọi hệ thống open() nào yêu cầu mở tệp vùng tuần tự cho
  ghi khi số lượng tệp vùng tuần tự đã mở để ghi đã hết
  đạt đến giới hạn ZZ0005ZZ.
* ZZ0001ZZ: Thuộc tính này báo cáo số lượng tuần tự hiện tại
  tập tin vùng mở để ghi.  Khi tùy chọn gắn kết "rõ ràng-mở" được sử dụng,
  con số này không bao giờ có thể vượt quá ZZ0006ZZ.  Nếu ZZ0007ZZ
  tùy chọn gắn kết không được sử dụng, số được báo cáo có thể lớn hơn
  ZZ0008ZZ.  Trong trường hợp đó, trách nhiệm của
  ứng dụng không ghi đồng thời nhiều hơn ZZ0009ZZ
  tập tin vùng tuần tự.  Không làm như vậy có thể dẫn đến lỗi ghi.
* ZZ0002ZZ: Thuộc tính này báo cáo số lượng tối đa
  các tệp vùng tuần tự ở trạng thái hoạt động, nghĩa là vùng tuần tự
  các tập tin được ghi một phần (không trống cũng không đầy) hoặc có một vùng
  được mở rõ ràng (điều này chỉ xảy ra nếu tùy chọn gắn ZZ0010ZZ được
  đã sử dụng).  Con số này luôn bằng số lượng vùng hoạt động tối đa mà
  thiết bị hỗ trợ.  Giá trị 0 có nghĩa là thiết bị được gắn không có giới hạn
  về số lượng tệp vùng tuần tự có thể hoạt động.
* ZZ0003ZZ: Thuộc tính này báo cáo số lượng hiện tại của
  tập tin vùng tuần tự đang hoạt động. Nếu ZZ0011ZZ khác 0,
  thì giá trị của ZZ0012ZZ không bao giờ có thể vượt quá giá trị của
  ZZ0013ZZ, bất kể việc sử dụng ngàm ZZ0014ZZ
  tùy chọn.

Công cụ không gian người dùng Zonefs
=======================

Công cụ mkzonefs được sử dụng để định dạng các thiết bị khối được khoanh vùng để sử dụng với Zonefs.
Công cụ này có sẵn trên Github tại:

ZZ0000ZZ

Zonefs-tools cũng bao gồm một bộ thử nghiệm có thể chạy trên bất kỳ thiết bị được khoanh vùng nào.
thiết bị chặn, bao gồm thiết bị khối null_blk được tạo bằng chế độ khoanh vùng.

Ví dụ
--------

Các định dạng sau đây là SMR HDD 15TB do máy chủ quản lý với vùng 256 MB
với tính năng tổng hợp vùng thông thường được bật ::

# mkzonefs -o aggr_cnv /dev/sdX
    # mount -t vùngfs/dev/sdX/mnt
    # ls -l /mnt/
    tổng 0
    dr-xr-xr-x 2 gốc gốc 1 ngày 25 tháng 11 13:23 cnv
    dr-xr-xr-x 2 gốc gốc 55356 25 tháng 11 13:23 seq

Kích thước của các thư mục con của tập tin vùng cho biết số lượng tập tin
hiện có cho từng loại vùng. Trong ví dụ này chỉ có một
tệp vùng thông thường (tất cả các vùng thông thường được tổng hợp dưới một tệp duy nhất
tập tin)::

# ls -l /mnt/cnv
    tổng cộng 137101312
    -rw-r------ 1 gốc 140391743488 25/11 13:23 0

Tệp vùng thông thường tổng hợp này có thể được sử dụng như một tệp thông thường ::

# mkfs.ext4 /mnt/cnv/0
    # mount -o vòng lặp/mnt/cnv/0/dữ liệu

Các tệp nhóm thư mục con "seq" cho các vùng ghi tuần tự có trong phần này
ví dụ 55356 vùng::

# ls -lv /mnt/seq
    tổng số 14511243264
    -rw-r------ 1 gốc gốc 0 25/11 13:23 0
    -rw-r------ 1 gốc gốc 0 25/11 13:23 1
    -rw-r------ 1 gốc gốc 0 25/11 13:23 2
    ...
-rw-r------ 1 gốc gốc 0 25/11 13:23 55354
    -rw-r------ 1 gốc gốc 0 25/11 13:23 55355

Đối với các tệp vùng ghi tuần tự, kích thước tệp thay đổi khi dữ liệu được thêm vào
ở cuối tệp, tương tự như bất kỳ hệ thống tệp thông thường nào::

# dd if=/dev/zero of=/mnt/seq/0 bs=4096 count=1 conv=notrunc oflag=direct
    Bản ghi 1+0 trong
    1+0 hồ sơ hết
    Đã sao chép 4096 byte (4,1 kB, 4,0 KiB), 0,00044121 giây, 9,3 MB/s

# ls -l /mnt/seq/0
    -rw-r------ 1 gốc gốc 4096 25/11 13:23 /mnt/seq/0

Tệp văn bản có thể được cắt bớt theo kích thước vùng, ngăn chặn bất kỳ
thao tác ghi::

# truncate -s 268435456 /mnt/seq/0
    # ls -l /mnt/seq/0
    -rw-r------ 1 gốc gốc 268435456 25/11 13:49 /mnt/seq/0

Việc cắt bớt kích thước về 0 cho phép giải phóng không gian lưu trữ vùng tệp và khởi động lại
nối thêm-ghi vào tập tin::

# truncate -s 0 /mnt/seq/0
    # ls -l /mnt/seq/0
    -rw-r----- 1 gốc gốc 0 25/11 13:49 /mnt/seq/0

Vì các tập tin được ánh xạ tĩnh tới các vùng trên đĩa nên số khối
của một tệp được báo cáo bởi stat() và fstat() cho biết dung lượng của tệp
khu vực::

# stat /mnt/seq/0
    Tập tin: /mnt/seq/0
    Kích thước: 0 Khối: 524288 Khối IO: 4096 tệp trống thông thường
    Thiết bị: 870h/2160d Inode: 50431 Liên kết: 1
    Truy cập: (0640/-rw-r------) Uid: ( 0/ root) Gid: ( 0/ root)
    Truy cập: 2019-11-25 13:23:57.048971997 +0900
    Sửa đổi: 2019-11-25 13:52:25.553805765 +0900
    Thay đổi: 25-11-2019 13:52:25.553805765 +0900
    Sinh: -

Số khối của tệp ("Khối") theo đơn vị khối 512B cho biết
kích thước file tối đa 524288 * 512 B = 256 MB, tương ứng với vùng thiết bị
năng lực trong ví dụ này. Điều đáng chú ý là trường "khối IO" luôn
cho biết kích thước I/O tối thiểu để ghi và tương ứng với thiết bị
kích thước khu vực vật lý.