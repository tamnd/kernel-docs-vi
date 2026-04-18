.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/fsverity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _fsverity:

=============================================================
fs-verity: bảo vệ tính xác thực dựa trên tệp chỉ đọc
=============================================================

Giới thiệu
============

fs-verity (ZZ0000ZZ) là lớp hỗ trợ mà hệ thống tập tin có thể
kết nối để hỗ trợ tính toàn vẹn minh bạch và bảo vệ tính xác thực
của các tập tin chỉ đọc.  Hiện tại, nó được hỗ trợ bởi ext4, f2fs và
hệ thống tập tin btrfs.  Giống như fscrypt, không có quá nhiều hệ thống tập tin cụ thể
mã là cần thiết để hỗ trợ fs-verity.

fs-verity tương tự như ZZ0000ZZ
nhưng hoạt động trên các tập tin chứ không phải các thiết bị chặn.  Trên các tập tin thông thường trên
hệ thống tập tin hỗ trợ fs-verity, không gian người dùng có thể thực thi ioctl
khiến hệ thống tệp xây dựng cây Merkle cho tệp và tồn tại
nó đến một vị trí dành riêng cho hệ thống tệp được liên kết với tệp.

Sau đó, tệp được tạo ở chế độ chỉ đọc và tất cả các lần đọc từ tệp đều được
tự động được xác minh dựa trên cây Merkle của tệp.  Đọc bất kỳ
dữ liệu bị hỏng, bao gồm cả việc đọc mmap, sẽ không thành công.

Không gian người dùng có thể sử dụng ioctl khác để truy xuất hàm băm gốc (thực tế là
"thông báo tệp fs-verity", là hàm băm bao gồm Merkle
hàm băm gốc cây) mà fs-verity đang thực thi cho tệp.  ioctl này
thực thi trong thời gian không đổi, bất kể kích thước tệp.

fs-verity về cơ bản là một cách để băm một tệp trong thời gian không đổi,
tùy thuộc vào lời cảnh báo sẽ vi phạm hàm băm
thất bại trong thời gian chạy.

Trường hợp sử dụng
=========

Bản thân fs-verity chỉ cung cấp khả năng bảo vệ tính toàn vẹn, tức là.
phát hiện tham nhũng vô tình (không độc hại).

Tuy nhiên, vì fs-verity khiến việc truy xuất file hash cực kỳ khó khăn.
hiệu quả, nó chủ yếu được sử dụng như một công cụ hỗ trợ
xác thực (phát hiện các sửa đổi độc hại) hoặc kiểm tra
(ghi nhật ký tệp băm trước khi sử dụng).

Hàm băm tệp tiêu chuẩn có thể được sử dụng thay vì fs-verity.  Tuy nhiên,
điều này không hiệu quả nếu tệp lớn và chỉ một phần nhỏ có thể
được truy cập.  Điều này thường xảy ra với gói ứng dụng Android
(APK) chẳng hạn.  Chúng thường chứa nhiều bản dịch,
các lớp học và các tài nguyên khác không thường xuyên hoặc thậm chí không bao giờ
truy cập trên một thiết bị cụ thể.  Sẽ rất chậm và lãng phí nếu
đọc và băm toàn bộ tập tin trước khi khởi động ứng dụng.

Không giống như hàm băm trước đó, fs-verity cũng xác minh lại dữ liệu mỗi lần
thời điểm nó được phân trang. Điều này đảm bảo rằng chương trình cơ sở của đĩa độc hại không thể
thay đổi nội dung của tệp một cách không thể phát hiện được khi chạy.

fs-verity không thay thế hoặc lỗi thời dm-verity.  dm-verity nên
vẫn được sử dụng trên các hệ thống tập tin chỉ đọc.  fs-verity dành cho các tập tin
phải tồn tại trên hệ thống tập tin đọc-ghi vì chúng hoạt động độc lập
đã cập nhật và có khả năng do người dùng cài đặt, vì vậy không thể sử dụng dm-verity.

fs-verity không yêu cầu một sơ đồ cụ thể để xác thực nó
băm tập tin.  (Tương tự, dm-verity không bắt buộc một quy định cụ thể nào
lược đồ để xác thực băm gốc thiết bị khối của nó.) Tùy chọn cho
xác thực băm tệp fs-verity bao gồm:

- Mã không gian người dùng đáng tin cậy.  Thông thường, mã vùng người dùng truy cập
  các tập tin có thể được tin cậy để xác thực chúng.  Hãy xem xét ví dụ. một
  ứng dụng muốn xác thực các tệp dữ liệu trước khi sử dụng chúng,
  hoặc trình tải ứng dụng là một phần của hệ điều hành (có
  đã được xác thực theo một cách khác, chẳng hạn như bằng cách tải
  từ phân vùng chỉ đọc sử dụng dm-verity) và muốn
  xác thực ứng dụng trước khi tải chúng.  Trong những trường hợp này, điều này
  mã không gian người dùng đáng tin cậy có thể xác thực nội dung của tệp bằng cách
  truy xuất bản tóm tắt fs-verity của nó bằng ZZ0000ZZ, sau đó
  xác minh chữ ký của nó bằng cách sử dụng bất kỳ mật mã không gian người dùng nào
  thư viện hỗ trợ chữ ký số.

- Kiến trúc đo lường tính toàn vẹn (IMA).  IMA hỗ trợ fs-verity
  các bản tóm tắt tập tin thay thế cho các bản tóm tắt tệp đầy đủ truyền thống của nó.
  "Thẩm định IMA" buộc các tệp phải chứa thông tin hợp lệ, phù hợp
  chữ ký trong thuộc tính mở rộng "security.ima" của họ, như được kiểm soát
  bởi chính sách IMA.  Để biết thêm thông tin, hãy xem tài liệu IMA.

- Thực thi chính sách liêm chính (IPE).  IPE hỗ trợ thực thi quyền truy cập
  quyết định kiểm soát dựa trên thuộc tính bảo mật bất biến của tập tin,
  bao gồm cả những thứ được bảo vệ bởi chữ ký tích hợp của fs-verity.
  "Chính sách IPE" đặc biệt cho phép ủy quyền fs-verity
  các tập tin sử dụng thuộc tính ZZ0001ZZ để xác định
  các tệp theo bản tóm tắt xác thực của chúng và ZZ0002ZZ để ủy quyền
  các tệp có chữ ký tích hợp của fs-verity đã được xác minh. cho
  chi tiết về cách định cấu hình các chính sách IPE và hiểu hoạt động của nó
  các chế độ, vui lòng tham khảo ZZ0000ZZ.

- Mã không gian người dùng đáng tin cậy kết hợp với ZZ0000ZZ.  Cách tiếp cận này chỉ nên được sử dụng một cách cẩn thận.

Người dùng API
========

FS_IOC_ENABLE_VERITY
--------------------

FS_IOC_ENABLE_VERITY ioctl kích hoạt fs-verity trên một tệp.  Phải mất
trong một con trỏ tới cấu trúc fsverity_enable_arg, được định nghĩa là
sau::

cấu trúc fsverity_enable_arg {
            __u32 phiên bản;
            __u32 thuật toán băm;
            __u32 khối_size;
            __u32 muối_size;
            __u64 muối_ptr;
            __u32 sig_size;
            __u32 __reserved1;
            __u64 sig_ptr;
            __u64 __reserved2[11];
    };

Cấu trúc này chứa các tham số của cây Merkle để xây dựng cho
tập tin.  Nó phải được khởi tạo như sau:

- ZZ0000ZZ phải là 1.
- ZZ0001ZZ phải là mã định danh cho thuật toán băm để
  sử dụng cho cây Merkle, chẳng hạn như FS_VERITY_HASH_ALG_SHA256.  Xem
  ZZ0002ZZ để biết danh sách các giá trị có thể.
- ZZ0003ZZ là kích thước khối cây Merkle, tính bằng byte.  Trong Linux
  v6.3 trở lên, đây có thể là lũy thừa bất kỳ của 2 ở giữa (bao gồm)
  1024 và kích thước trang hệ thống và hệ thống tệp tối thiểu
  kích thước khối.  Trong các phiên bản trước, kích thước trang là kích thước duy nhất được phép
  giá trị.
- ZZ0004ZZ là kích thước của muối tính bằng byte hoặc 0 nếu không có muối
  được cung cấp.  Muối là một giá trị được thêm vào trước mỗi hàm băm
  khối; nó có thể được sử dụng để cá nhân hóa việc băm cho một mục đích cụ thể
  tập tin hoặc thiết bị.  Hiện tại kích thước muối tối đa là 32 byte.
- ZZ0005ZZ là con trỏ tới muối, hoặc NULL nếu không có muối
  được cung cấp.
- ZZ0006ZZ là kích thước của chữ ký dựng sẵn tính bằng byte hoặc 0 nếu không
  chữ ký dựng sẵn được cung cấp.  Hiện tại chữ ký dựng sẵn là
  (hơi tùy ý) giới hạn ở 16128 byte.
- ZZ0007ZZ là con trỏ tới chữ ký dựng sẵn hoặc NULL nếu không
  chữ ký dựng sẵn được cung cấp.  Chỉ cần một chữ ký dựng sẵn
  nếu tính năng ZZ0008ZZ đang được sử dụng.  Nó
  không cần thiết cho việc đánh giá IMA và không cần thiết nếu tệp
  chữ ký đang được xử lý hoàn toàn trong không gian người dùng.
- Tất cả các trường dành riêng phải bằng 0.

FS_IOC_ENABLE_VERITY khiến hệ thống tập tin xây dựng cây Merkle cho
tệp và lưu nó vào một vị trí dành riêng cho hệ thống tệp được liên kết
với tệp, sau đó đánh dấu tệp là tệp xác thực.  Ioctl này có thể
mất nhiều thời gian để thực thi trên các tệp lớn và có thể bị gián đoạn bởi
những tín hiệu chết người.

FS_IOC_ENABLE_VERITY kiểm tra quyền truy cập ghi vào nút.  Tuy nhiên,
nó phải được thực thi trên bộ mô tả tệp O_RDONLY và không có quy trình nào
có thể mở tập tin để ghi.  Cố gắng mở tập tin cho
việc ghi trong khi ioctl này đang thực thi sẽ không thành công với ETXTBSY.  (Cái này
là cần thiết để đảm bảo rằng sẽ không có bộ mô tả tệp có thể ghi nào tồn tại
sau khi tính xác thực được bật và để đảm bảo rằng nội dung của tệp được
ổn định trong khi cây Merkle đang được xây dựng trên đó.)

Nếu thành công, FS_IOC_ENABLE_VERITY trả về 0 và tệp sẽ trở thành
tập tin xác thực.  Khi có sự cố (kể cả trường hợp bị gián đoạn bởi một
tín hiệu nghiêm trọng), không có thay đổi nào được thực hiện đối với tệp.

FS_IOC_ENABLE_VERITY có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: tiến trình không có quyền ghi vào file
- ZZ0001ZZ: chữ ký dựng sẵn không đúng định dạng
- ZZ0002ZZ: ioctl này đã chạy trên file
- ZZ0003ZZ: file đã được kích hoạt xác thực
- ZZ0004ZZ: người gọi cung cấp bộ nhớ không thể truy cập
- ZZ0005ZZ: tệp quá lớn để bật tính năng xác thực
- ZZ0006ZZ: hoạt động bị gián đoạn do tín hiệu nghiêm trọng
- ZZ0007ZZ: phiên bản, thuật toán băm hoặc kích thước khối không được hỗ trợ; hoặc
  bit dành riêng được thiết lập; hoặc bộ mô tả tập tin không đề cập đến một
  tập tin thông thường cũng như một thư mục.
- ZZ0008ZZ: bộ mô tả tập tin đề cập đến một thư mục
- ZZ0009ZZ: chữ ký dựng sẵn không khớp với file
- ZZ0010ZZ: chữ ký muối hoặc nội dung quá dài
- ZZ0011ZZ: khóa ".fs-verity" không chứa chứng chỉ
  cần thiết để xác minh chữ ký dựng sẵn
- ZZ0012ZZ: fs-verity nhận dạng thuật toán băm, nhưng không phải
  có sẵn trong kernel như được cấu hình hiện tại
- ZZ0013ZZ: loại hệ thống tập tin này không triển khai fs-verity
- ZZ0014ZZ: kernel không được cấu hình với fs-verity
  hỗ trợ; hoặc siêu khối hệ thống tập tin chưa có 'tính xác thực'
  tính năng được kích hoạt trên đó; hoặc hệ thống tập tin không hỗ trợ fs-verity
  trên tập tin này.  (Xem ZZ0018ZZ.)
- ZZ0015ZZ: tệp chỉ có phần bổ sung; hoặc, một chữ ký dựng sẵn là
  được yêu cầu và một cái không được cung cấp.
- ZZ0016ZZ: hệ thống tập tin ở chế độ chỉ đọc
- ZZ0017ZZ: có người mở file để ghi.  Đây có thể là
  bộ mô tả tệp của người gọi, bộ mô tả tệp đang mở khác hoặc tệp
  tham chiếu được giữ bởi một bản đồ bộ nhớ có thể ghi được.

FS_IOC_MEASURE_VERITY
---------------------

FS_IOC_MEASURE_VERITY ioctl truy xuất bản tóm tắt của tệp xác thực.
Bản tóm tắt tệp fs-verity là bản tóm tắt mật mã xác định
nội dung tệp đang được thực thi khi đọc; nó được tính toán thông qua
cây Merkle và khác với bản tóm tắt toàn tập tin truyền thống.

ioctl này lấy một con trỏ tới cấu trúc có độ dài thay đổi::

cấu trúc fsverity_digest {
            __u16 tóm tắt_thuật toán;
            __u16 thông báo_size; /*đầu vào/đầu ra */
            __u8 thông báo[];
    };

ZZ0000ZZ là trường đầu vào/đầu ra.  Khi nhập vào, nó phải là
được khởi tạo theo số byte được phân bổ cho độ dài thay đổi
Trường ZZ0001ZZ.

Nếu thành công, 0 được trả về và kernel điền vào cấu trúc như
sau:

- ZZ0000ZZ sẽ là thuật toán băm được sử dụng cho file
  tiêu hóa.  Nó sẽ phù hợp với ZZ0001ZZ.
- ZZ0002ZZ sẽ là kích thước của bản tóm tắt tính bằng byte, ví dụ: 32
  cho SHA-256.  (Điều này có thể dư thừa với ZZ0003ZZ.)
- ZZ0004ZZ sẽ là byte thực tế của thông báo.

FS_IOC_MEASURE_VERITY được đảm bảo thực thi trong thời gian không đổi,
bất kể kích thước của tập tin.

FS_IOC_MEASURE_VERITY có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: người gọi cung cấp bộ nhớ không thể truy cập
- ZZ0001ZZ: file không phải là file xác thực
- ZZ0002ZZ: loại hệ thống tập tin này không triển khai fs-verity
- ZZ0003ZZ: kernel không được cấu hình với fs-verity
  hỗ trợ hoặc siêu khối hệ thống tập tin chưa có 'tính xác thực'
  tính năng được kích hoạt trên đó.  (Xem ZZ0006ZZ.)
- ZZ0004ZZ: thông báo dài hơn quy định
  byte ZZ0005ZZ.  Hãy thử cung cấp bộ đệm lớn hơn.

FS_IOC_READ_VERITY_METADATA
---------------------------

FS_IOC_READ_VERITY_METADATA ioctl đọc siêu dữ liệu xác thực từ một
tập tin xác thực.  Ioctl này có sẵn kể từ Linux v5.12.

Ioctl này rất hữu ích cho các trường hợp cần xác minh tính xác thực
được thực hiện ở đâu đó ngoài kernel hiện đang chạy.

Một ví dụ là một chương trình máy chủ nhận một tệp xác thực và phục vụ nó
cho một chương trình máy khách, sao cho máy khách có thể thực hiện fs-verity của riêng mình
xác minh tương thích của tập tin.  Điều này chỉ có ý nghĩa nếu
máy khách không tin cậy máy chủ và nếu máy chủ cần cung cấp thông tin
lưu trữ cho khách hàng.

Một ví dụ khác là sao chép siêu dữ liệu xác thực khi tạo hệ thống tệp
hình ảnh trong không gian người dùng (chẳng hạn như với ZZ0000ZZ).

Đây là trường hợp sử dụng khá chuyên biệt và hầu hết người dùng fs-verity sẽ không
cần ioctl này.

Ioctl này lấy một con trỏ tới cấu trúc sau::

#define FS_VERITY_METADATA_TYPE_MERKLE_TREE 1
   #define FS_VERITY_METADATA_TYPE_DESCRIPTOR 2
   #define FS_VERITY_METADATA_TYPE_SIGNATURE 3

cấu trúc fsverity_read_metadata_arg {
           __u64 siêu dữ liệu_type;
           __u64 bù đắp;
           __u64 chiều dài;
           __u64 buf_ptr;
           __u64 __bảo lưu;
   };

ZZ0000ZZ chỉ định loại siêu dữ liệu cần đọc:

- ZZ0000ZZ đọc các khối của
  Cây Merkle.  Các khối được trả về theo thứ tự từ cấp gốc
  tới mức lá.  Trong mỗi cấp độ, các khối được trả về
  cùng thứ tự mà các giá trị băm của chúng được băm.
  Xem ZZ0001ZZ để biết thêm thông tin.

- ZZ0000ZZ đọc fs-verity
  mô tả.  Xem ZZ0001ZZ.

- ZZ0000ZZ đọc chữ ký dựng sẵn
  đã được chuyển tới FS_IOC_ENABLE_VERITY, nếu có.  Xem ZZ0001ZZ.

Ngữ nghĩa tương tự như ngữ nghĩa của ZZ0000ZZ.  ZZ0001ZZ
chỉ định phần bù theo byte vào mục siêu dữ liệu để đọc từ đó và
ZZ0002ZZ chỉ định số byte tối đa để đọc từ
mục siêu dữ liệu.  ZZ0003ZZ là con trỏ tới bộ đệm để đọc vào,
chuyển sang số nguyên 64 bit.  ZZ0004ZZ phải bằng 0. Nếu thành công,
số byte đã đọc được trả về.  0 được trả về vào cuối
mục siêu dữ liệu.  Độ dài trả về có thể nhỏ hơn ZZ0005ZZ, đối với
ví dụ nếu ioctl bị gián đoạn.

Siêu dữ liệu được FS_IOC_READ_VERITY_METADATA trả về không được đảm bảo
được xác thực dựa vào bản tóm tắt tệp sẽ được trả về bởi
ZZ0000ZZ, vì siêu dữ liệu dự kiến sẽ được sử dụng để
vẫn triển khai xác minh tương thích fs-verity (mặc dù không có
đĩa độc hại thì siêu dữ liệu sẽ thực sự khớp).  Ví dụ. để thực hiện
ioctl này, hệ thống tập tin được phép chỉ đọc cây Merkle
khối từ đĩa mà không thực sự xác minh đường dẫn đến nút gốc.

FS_IOC_READ_VERITY_METADATA có thể bị lỗi với các lỗi sau:

- ZZ0000ZZ: người gọi cung cấp bộ nhớ không thể truy cập
- ZZ0001ZZ: ioctl bị gián đoạn trước khi bất kỳ dữ liệu nào được đọc
- ZZ0002ZZ: các trường dành riêng đã được đặt hoặc ZZ0003ZZ
  tràn
- ZZ0004ZZ: file không phải là file xác thực, hoặc
  FS_VERITY_METADATA_TYPE_SIGNATURE đã được yêu cầu nhưng tệp thì không
  có chữ ký dựng sẵn
- ZZ0005ZZ: loại hệ thống tệp này không triển khai fs-verity hoặc
  ioctl này chưa được triển khai trên nó
- ZZ0006ZZ: kernel không được cấu hình với fs-verity
  hỗ trợ hoặc siêu khối hệ thống tập tin chưa có 'tính xác thực'
  tính năng được kích hoạt trên đó.  (Xem ZZ0007ZZ.)

FS_IOC_GETFLAGS
---------------

ioctl FS_IOC_GETFLAGS hiện có (không dành riêng cho fs-verity)
cũng có thể được sử dụng để kiểm tra xem một tệp có bật fs-verity hay không.
Để làm như vậy, hãy kiểm tra FS_VERITY_FL (0x00100000) trong các cờ được trả về.

Cờ xác thực không thể cài đặt được thông qua FS_IOC_SETFLAGS.  Bạn phải sử dụng
Thay vào đó, FS_IOC_ENABLE_VERITY vì phải cung cấp các tham số.

thống kê
-----

Kể từ Linux v5.5, lệnh gọi hệ thống statx() sẽ đặt STATX_ATTR_VERITY nếu
tập tin đã được kích hoạt fs-verity.  Điều này có thể hoạt động tốt hơn
FS_IOC_GETFLAGS và FS_IOC_MEASURE_VERITY vì nó không yêu cầu
việc mở tệp và mở tệp xác thực có thể tốn kém.

FS_IOC_FSGETXATTR
-----------------

Kể từ Linux v7.0, FS_IOC_FSGETXATTR ioctl đặt FS_XFLAG_VERITY (0x00020000)
trong các cờ được trả về khi tệp đã được kích hoạt tính xác thực. Lưu ý rằng thuộc tính này
không thể được đặt bằng FS_IOC_FSSETXATTR vì việc bật tính xác thực yêu cầu đầu vào
các thông số. Xem FS_IOC_ENABLE_VERITY.

file_getattr
------------

Kể từ Linux v7.0, tòa nhà tập tin file_getattr() đặt FS_XFLAG_VERITY (0x00020000)
trong các cờ được trả về khi tệp đã được kích hoạt tính xác thực. Lưu ý rằng thuộc tính này
không thể được đặt bằng file_setattr() vì việc bật tính xác thực yêu cầu các tham số đầu vào.
Xem FS_IOC_ENABLE_VERITY.

.. _accessing_verity_files:

Truy cập các tập tin xác thực
======================

Các ứng dụng có thể truy cập một cách minh bạch vào một tệp xác thực giống như một
không xác thực, với các ngoại lệ sau:

- Các tập tin xác thực là chỉ đọc.  Chúng không thể được mở để viết hoặc
  truncate()d, ngay cả khi các bit chế độ tệp cho phép điều đó.  Nỗ lực làm
  một trong những điều này sẽ thất bại với EPERM.  Tuy nhiên, những thay đổi về
  siêu dữ liệu như chủ sở hữu, chế độ, dấu thời gian và xattr vẫn
  được phép, vì những điều này không được đo bằng fs-verity.  Tập tin xác thực
  vẫn có thể được đổi tên, xóa và liên kết tới.

- I/O trực tiếp không được hỗ trợ trên các tập tin xác thực.  Nỗ lực sử dụng trực tiếp
  I/O trên các tệp như vậy sẽ quay trở lại I/O được đệm.

- DAX (Truy cập trực tiếp) không được hỗ trợ trên các tệp xác thực, vì điều này
  sẽ phá vỡ việc xác minh dữ liệu.

- Việc đọc dữ liệu không khớp với cây Merkle xác thực sẽ không thành công
  với EIO (để đọc()) hoặc SIGBUS (để đọc mmap()).

- Nếu sysctl "fs.verity.require_signatures" được đặt thành 1 và
  thì tệp không được ký bằng khóa trong chuỗi khóa ".fs-verity", thì
  mở tập tin sẽ thất bại.  Xem ZZ0000ZZ.

Truy cập trực tiếp vào cây Merkle không được hỗ trợ.  Vì vậy, nếu một
tập tin verity được sao chép hoặc được sao lưu và khôi phục sẽ mất
tính "chân thực" của nó.  fs-verity chủ yếu dành cho các tệp như
các tệp thực thi được quản lý bởi người quản lý gói.

Tính toán phân loại tập tin
=======================

Phần này mô tả cách fs-verity băm nội dung tệp bằng cách sử dụng
Cây Merkle để tạo ra thông báo xác định bằng mật mã
nội dung tập tin.  Thuật toán này giống nhau cho tất cả các hệ thống tập tin
hỗ trợ fs-verity.

Không gian người dùng chỉ cần biết đến thuật toán này nếu cần
tính toán tập tin fs-verity tự phân loại, ví dụ: để ký các tập tin.

.. _fsverity_merkle_tree:

Cây Merkle
-----------

Nội dung tập tin được chia thành các khối, trong đó kích thước khối là
có thể cấu hình nhưng thường là 4096 byte.  Điểm cuối của khối cuối cùng là
không đệm nếu cần.  Mỗi khối sau đó được băm, tạo ra khối đầu tiên
mức độ băm.  Sau đó, các giá trị băm ở cấp độ đầu tiên này được nhóm lại
thành các khối byte 'blocksize' (không đệm các đầu nếu cần) và
các khối này được băm, tạo ra cấp độ băm thứ hai.  Cái này
tiếp tục đi lên cây cho đến khi chỉ còn lại một khối duy nhất.  Hàm băm của
khối này là "băm gốc cây Merkle".

Nếu tệp vừa với một khối và không trống thì "Cây Merkle
hàm băm gốc" chỉ đơn giản là hàm băm của khối dữ liệu đơn lẻ.  Nếu tập tin
trống thì "băm gốc cây Merkle" đều là số 0.

Các "khối" ở đây không nhất thiết phải giống như "khối hệ thống tập tin".

Nếu một muối được chỉ định thì nó sẽ được đệm bằng 0 vào bội số gần nhất
kích thước đầu vào của hàm nén của thuật toán băm, ví dụ:
64 byte cho SHA-256 hoặc 128 byte cho SHA-512.  Muối đệm là
thêm vào trước mọi dữ liệu hoặc khối cây Merkle được băm.

Mục đích của việc đệm khối là khiến mọi hàm băm được lấy đi
trên cùng một lượng dữ liệu, giúp đơn giản hóa việc thực hiện và
luôn mở ra nhiều khả năng tăng tốc phần cứng hơn.  Mục đích
của việc đệm muối là làm cho việc muối trở nên "miễn phí" khi băm muối
trạng thái được tính toán trước, sau đó được nhập cho mỗi hàm băm.

Ví dụ: trong cấu hình được đề xuất của khối SHA-256 và 4K,
128 giá trị băm phù hợp với mỗi khối.  Vì vậy, mỗi cấp độ của Merkle
cây nhỏ hơn khoảng 128 lần so với cây trước đó và
các tệp lớn, kích thước của cây Merkle hội tụ đến khoảng 1/127
kích thước tập tin gốc.  Tuy nhiên, đối với các tệp nhỏ, phần đệm là
đáng kể, làm cho không gian trên không tương ứng nhiều hơn.

.. _fsverity_descriptor:

bộ mô tả fs-verity
--------------------

Bản thân hàm băm gốc của cây Merkle là không rõ ràng.  Ví dụ, nó
không thể phân biệt một tệp lớn với một tệp nhỏ thứ hai có dữ liệu
chính xác là khối băm cấp cao nhất của tệp đầu tiên.  sự mơ hồ
cũng phát sinh từ quy ước đệm tới ranh giới khối tiếp theo.

Để giải quyết vấn đề này, bản tóm tắt tệp fs-verity thực sự được tính toán
dưới dạng hàm băm của cấu trúc sau, chứa cây Merkle
hàm băm gốc cũng như các trường khác như kích thước tệp::

cấu trúc fsverity_descriptor {
            __u8 phiên bản;           /* phải là 1 */
            __u8 thuật toán băm;    /* Thuật toán băm cây Merkle */
            __u8 log_blocksize;     /* log2 kích thước của dữ liệu và khối cây */
            __u8 muối_size;         /* kích thước của muối tính bằng byte; 0 nếu không có */
            __le32 __reserved_0x04; /* phải là 0 */
            __le64 data_size;       /* kích thước tệp mà cây Merkle được xây dựng dựa trên */
            __u8 root_hash[64];     /* Hàm băm gốc cây Merkle */
            __u8 muối[32];          /* muối được thêm vào trước mỗi khối băm */
            __u8 __reserved[144];   /* phải là số 0 */
    };

Xác minh chữ ký tích hợp
===============================

CONFIG_FS_VERITY_BUILTIN_SIGNATURES=y thêm hỗ trợ cho in-kernel
xác minh chữ ký dựng sẵn fs-verity.

ZZ0000ZZ!  Hãy cẩn thận trước khi sử dụng tính năng này.
Đây không phải là cách duy nhất để thực hiện chữ ký với fs-verity và
các lựa chọn thay thế (chẳng hạn như xác minh chữ ký vùng người dùng và IMA
đánh giá) có thể tốt hơn nhiều.  Cũng dễ rơi vào bẫy
nghĩ rằng tính năng này giải quyết được nhiều vấn đề hơn thực tế.

Việc bật tùy chọn này sẽ bổ sung thêm các mục sau:

1. Khi khởi động, kernel tạo một chuỗi khóa có tên ".fs-verity".  các
   người dùng root có thể thêm chứng chỉ X.509 đáng tin cậy vào khóa này bằng cách sử dụng
   lệnh gọi hệ thống add_key().

2. ZZ0000ZZ chấp nhận một con trỏ tới định dạng PKCS#7
   chữ ký tách rời ở định dạng DER của bản tóm tắt fs-verity của tệp.
   Khi thành công, ioctl sẽ duy trì chữ ký cùng với Merkle
   cây.  Sau đó, bất cứ khi nào tệp được mở, kernel sẽ xác minh
   bản tóm tắt thực sự của tập tin dựa trên chữ ký này, sử dụng các chứng chỉ
   trong chuỗi khóa ".fs-verity". Việc xác minh này diễn ra miễn là
   chữ ký của tệp tồn tại, bất kể trạng thái của biến sysctl
   "fs.verity.require_signatures" được mô tả trong mục tiếp theo. IPE LSM
   dựa vào hành vi này để nhận biết và gắn nhãn các tệp fsverity
   có chứa chữ ký fsverity tích hợp đã được xác minh.

3. Một hệ thống mới "fs.verity.require_signatures" đã có sẵn.
   Khi được đặt thành 1, kernel yêu cầu tất cả các tệp xác thực phải có
   thông báo được ký chính xác như được mô tả trong (2).

Dữ liệu mà chữ ký được mô tả ở (2) phải là chữ ký của
là bản tóm tắt tệp fs-verity ở định dạng sau ::

cấu trúc fsverity_formatted_digest {
            char ma thuật [8];                  /* phải là "FSVerity" */
            __le16 tóm tắt_thuật toán;
            __le16 thông báo_size;
            __u8 thông báo[];
    };

Thế thôi.  Cần nhấn mạnh lại rằng fs-verity dựng sẵn
chữ ký không phải là cách duy nhất để thực hiện chữ ký với fs-verity.  Xem
ZZ0000ZZ để biết tổng quan về các cách có thể sử dụng fs-verity.
Chữ ký dựng sẵn fs-verity có một số hạn chế lớn cần
được cân nhắc cẩn thận trước khi sử dụng chúng:

- Xác minh chữ ký tích hợp ZZ0000ZZ làm cho kernel thực thi
  rằng bất kỳ tệp nào thực sự đã được bật fs-verity.  Vì vậy, nó không phải là một
  chính sách xác thực hoàn chỉnh.  Hiện tại, nếu nó được sử dụng, một
  cách để hoàn thành chính sách xác thực là dành cho không gian người dùng đáng tin cậy
  mã để kiểm tra rõ ràng xem các tệp có bật fs-verity hay không bằng
  chữ ký trước khi chúng được truy cập.  (Với
  fs.verity.require_signatures=1, chỉ kiểm tra xem fs-verity có
  được kích hoạt là đủ.) Tuy nhiên, trong trường hợp này, mã vùng người dùng đáng tin cậy
  chỉ có thể lưu trữ chữ ký cùng với tệp và xác minh nó
  chính nó bằng cách sử dụng thư viện mật mã, thay vì sử dụng tính năng này.

- Một cách tiếp cận khác là sử dụng chữ ký dựng sẵn fs-verity
  xác minh kết hợp với IPE LSM, hỗ trợ xác định
  chính sách xác thực toàn hệ thống được thực thi bằng kernel chỉ cho phép
  các tệp có chữ ký dựng sẵn fs-verity đã được xác minh để thực hiện một số
  các hoạt động, chẳng hạn như thực hiện. Lưu ý rằng IPE không yêu cầu
  fs.verity.require_signatures=1.
  Vui lòng tham khảo ZZ0000ZZ để biết
  biết thêm chi tiết.

- Chữ ký dựng sẵn của một tập tin chỉ có thể được đặt cùng lúc với
  fs-verity đang được bật trên tệp.  Thay đổi hoặc xóa các
  chữ ký dựng sẵn sau này yêu cầu tạo lại tệp.

- Xác minh chữ ký dựng sẵn sử dụng cùng một bộ khóa công khai cho
  tất cả các tệp kích hoạt fs-verity trên hệ thống.  Không thể có các khóa khác nhau
  đáng tin cậy cho các tập tin khác nhau; mỗi phím là tất cả hoặc không có gì.

- sysctl fs.verity.require_signatures áp dụng trên toàn hệ thống.
  Đặt nó thành 1 chỉ hoạt động khi tất cả người dùng fs-verity trên hệ thống
  đồng ý rằng nó nên được đặt thành 1. Giới hạn này có thể ngăn chặn
  fs-verity không được sử dụng trong trường hợp nó hữu ích.

- Xác minh chữ ký dựng sẵn chỉ có thể sử dụng thuật toán chữ ký
  được hỗ trợ bởi kernel.  Ví dụ, hạt nhân không
  chưa hỗ trợ Ed25519, mặc dù đây thường là chữ ký
  thuật toán được khuyến nghị cho các thiết kế mật mã mới.

- chữ ký dựng sẵn fs-verity có định dạng PKCS#7 và công khai
  các phím có định dạng X.509.  Các định dạng này thường được sử dụng,
  bao gồm cả một số tính năng kernel khác (đó là lý do tại sao fs-verity
  chữ ký dựng sẵn sử dụng chúng) và rất giàu tính năng.
  Thật không may, lịch sử đã chỉ ra rằng mã phân tích và xử lý
  các định dạng này (có từ những năm 1990 và dựa trên ASN.1)
  thường có lỗ hổng do tính phức tạp của chúng.  Cái này
  sự phức tạp không phải là vốn có của mật mã.

người dùng fs-verity không cần các tính năng nâng cao của X.509 và
  PKCS#7 nên cân nhắc sử dụng các định dạng đơn giản hơn, chẳng hạn như đơn giản
  Khóa và chữ ký Ed25519 cũng như xác minh chữ ký trong không gian người dùng.

Người dùng fs-verity chọn sử dụng X.509 và PKCS#7 vẫn nên
  vẫn cho rằng việc xác minh những chữ ký đó trong không gian người dùng sẽ hiệu quả hơn
  linh hoạt (vì những lý do khác được đề cập trước đó trong tài liệu này) và
  loại bỏ sự cần thiết phải kích hoạt CONFIG_FS_VERITY_BUILTIN_SIGNATURES
  và sự gia tăng liên quan của nó trong bề mặt tấn công hạt nhân.  Trong một số trường hợp
  nó thậm chí có thể cần thiết, vì các tính năng X.509 và PKCS#7 nâng cao
  không phải lúc nào cũng hoạt động như dự định với kernel.  Ví dụ,
  kernel không kiểm tra thời gian hiệu lực của chứng chỉ X.509.

Lưu ý: Thẩm định IMA, hỗ trợ fs-verity, không sử dụng PKCS#7
  cho chữ ký của nó, vì vậy nó tránh được một phần các vấn đề được thảo luận
  ở đây.  Đánh giá IMA sử dụng X.509.

Hỗ trợ hệ thống tập tin
==================

fs-verity được hỗ trợ bởi một số hệ thống tệp, được mô tả bên dưới.  các
Tùy chọn kconfig CONFIG_FS_VERITY phải được bật để sử dụng fs-verity trên
bất kỳ hệ thống tập tin nào trong số này.

ZZ0000ZZ khai báo giao diện giữa
Lớp hỗ trợ ZZ0001ZZ và hệ thống tập tin.  Tóm lại, hệ thống tập tin
phải cung cấp cấu trúc ZZ0002ZZ cung cấp
các phương pháp đọc và ghi siêu dữ liệu xác thực vào một hệ thống tệp cụ thể
vị trí, bao gồm các khối cây Merkle và
ZZ0003ZZ.  Hệ thống tập tin cũng phải gọi các hàm trong
ZZ0004ZZ tại một số thời điểm nhất định, chẳng hạn như khi một tệp được mở hoặc khi
các trang đã được đọc vào pagecache.  (Xem ZZ0005ZZ.)

ext4
----

ext4 hỗ trợ fs-verity kể từ Linux v5.4 và e2fsprogs v1.45.2.

Để tạo các tệp xác thực trên hệ thống tệp ext4, hệ thống tệp phải có
đã được định dạng bằng ZZ0000ZZ hoặc đã chạy ZZ0001ZZ
nó.  "verity" là một tính năng của hệ thống tập tin RO_COMPAT, vì vậy một khi được đặt, old
hạt nhân sẽ chỉ có thể gắn hệ thống tập tin ở chế độ chỉ đọc và cũ
các phiên bản e2fsck sẽ không thể kiểm tra hệ thống tập tin.

Ban đầu, một hệ thống tập tin ext4 có tính năng "verity" chỉ có thể được
được gắn khi kích thước khối của nó bằng kích thước trang hệ thống
(thường là 4096 byte).  Trong Linux v6.3, hạn chế này đã được loại bỏ.

ext4 đặt cờ inode trên đĩa EXT4_VERITY_FL trên các tệp xác thực.  Nó
chỉ có thể được đặt bởi ZZ0000ZZ và không thể xóa nó.

ext4 cũng hỗ trợ mã hóa, có thể được sử dụng đồng thời với
fs-verity.  Trong trường hợp này, dữ liệu bản rõ được xác minh thay vì
bản mã.  Điều này là cần thiết để tạo tệp fs-verity
thông báo có ý nghĩa vì mỗi tệp được mã hóa khác nhau.

ext4 lưu trữ siêu dữ liệu xác thực (cây Merkle và fsverity_descriptor)
qua cuối tập tin, bắt đầu từ ranh giới 64K đầu tiên vượt quá
i_size.  Cách tiếp cận này hiệu quả vì (a) các tệp xác thực chỉ đọc,
và (b) các trang hoàn toàn nằm ngoài i_size không hiển thị với không gian người dùng nhưng có thể
được đọc/ghi nội bộ bởi ext4 chỉ với một số tương đối nhỏ
thay đổi thành ext4.  Cách tiếp cận này tránh phải phụ thuộc vào
Tính năng EA_INODE và hỗ trợ xattr của kiến trúc lại ext4 để
hỗ trợ phân trang xattr nhiều gigabyte vào bộ nhớ và hỗ trợ
mã hóa xattrs.  Lưu ý rằng siêu dữ liệu xác thực ZZ0000ZZ được mã hóa
khi có tệp, vì nó chứa các giá trị băm của dữ liệu văn bản gốc.

ext4 chỉ cho phép tính xác thực trên các tệp dựa trên phạm vi.

f2fs
----

f2fs hỗ trợ fs-verity kể từ Linux v5.4 và f2fs-tools v1.11.0.

Để tạo các tệp xác thực trên hệ thống tệp f2fs, hệ thống tệp phải có
đã được định dạng bằng ZZ0000ZZ.

f2fs đặt cờ inode trên đĩa FADVISE_VERITY_BIT trên các tệp xác thực.
Nó chỉ có thể được đặt bởi ZZ0000ZZ và không thể
đã xóa.

Giống như ext4, f2fs lưu trữ siêu dữ liệu xác thực (cây Merkle và
fsverity_descriptor) qua cuối tệp, bắt đầu từ đầu tiên
Ranh giới 64K vượt quá i_size.  Xem giải thích cho ext4 ở trên.
Hơn nữa, f2fs hỗ trợ tối đa 4096 byte mục xattr trên mỗi inode
thường sẽ không đủ cho dù chỉ một khối cây Merkle.

f2fs không hỗ trợ bật tính xác thực trên các tệp hiện có
đang chờ xử lý ghi nguyên tử hoặc dễ bay hơi.

btrfs
-----

btrfs hỗ trợ fs-verity kể từ Linux v5.15.  Các nút kích hoạt xác thực là
được đánh dấu bằng cờ inode RO_COMPAT và siêu dữ liệu xác thực được lưu trữ
trong các mục btree riêng biệt.

Chi tiết triển khai
======================

Xác minh dữ liệu
--------------

fs-verity đảm bảo rằng tất cả các lần đọc dữ liệu của tệp xác thực đều được xác minh,
bất kể syscall nào được sử dụng để đọc (ví dụ: mmap(),
read(), pread()) và bất kể đó là lần đọc đầu tiên hay lần đọc đầu tiên
đọc sau (trừ khi lần đọc sau có thể trả về dữ liệu được lưu trong bộ nhớ đệm đã được
đã được xác minh rồi).  Dưới đây, chúng tôi mô tả cách hệ thống tập tin thực hiện điều này.

Bộ đệm trang
~~~~~~~~~

Đối với các hệ thống tập tin sử dụng pagecache của Linux, ZZ0000ZZ và
Các phương pháp ZZ0001ZZ phải được sửa đổi để xác minh folios trước
chúng được đánh dấu Cập nhật.  Chỉ cần móc ZZ0002ZZ sẽ là
không đủ vì ZZ0003ZZ không được sử dụng cho bản đồ bộ nhớ.

Do đó, fs/verity/ cung cấp hàm fsverity_verify_blocks()
xác minh dữ liệu đã được đọc vào bộ đệm trang của một sự thật
inode.  Folio chứa vẫn phải được khóa và không được cập nhật nên
không gian người dùng vẫn chưa thể đọc được nó.  Khi cần thiết để thực hiện việc xác minh,
fsverity_verify_blocks() sẽ gọi lại vào hệ thống tập tin để đọc
khối băm thông qua fsverity_Operation::read_merkle_tree_page().

fsverity_verify_blocks() trả về sai nếu xác minh không thành công; trong này
trường hợp này, hệ thống tập tin không được thiết lập folio Uptodate.  Theo sau điều này,
theo hành vi bộ đệm trang Linux thông thường, các nỗ lực của không gian người dùng để
read() từ phần tệp chứa folio sẽ không thành công với
EIO và truy cập vào folio trong bản đồ bộ nhớ sẽ nâng cao SIGBUS.

Về nguyên tắc, việc xác minh một khối dữ liệu yêu cầu xác minh toàn bộ
đường dẫn trong cây Merkle từ khối dữ liệu đến hàm băm gốc.
Tuy nhiên, để đạt hiệu quả, hệ thống tập tin có thể lưu trữ các khối băm.
Do đó, fsverity_verify_blocks() chỉ tăng dần hàm băm đọc cây
khối cho đến khi nhìn thấy khối băm đã được xác minh.  Sau đó nó xác minh
đường dẫn đến khối đó.

Sự tối ưu hóa này, cũng được sử dụng bởi dm-verity, dẫn đến
hiệu suất đọc tuần tự tuyệt vời.  Điều này là do thông thường (ví dụ:
127 trong 128 lần đối với khối 4K và SHA-256) khối băm từ
cấp dưới cùng của cây sẽ được lưu vào bộ nhớ đệm và được kiểm tra từ
đọc khối dữ liệu trước đó.  Tuy nhiên, đọc ngẫu nhiên hoạt động kém hơn.

Chặn hệ thống tập tin dựa trên thiết bị
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chặn các hệ thống tệp dựa trên thiết bị (ví dụ: ext4 và f2fs) trong Linux cũng sử dụng
pagecache, vì vậy tiểu mục trên cũng được áp dụng.  Tuy nhiên, họ
cũng thường đọc nhiều khối dữ liệu từ một tệp cùng một lúc, được nhóm thành một
cấu trúc được gọi là "sinh học".  Để tạo điều kiện dễ dàng hơn cho những loại
các hệ thống tập tin hỗ trợ fs-verity, fs/verity/ cũng cung cấp một chức năng
fsverity_verify_bio() xác minh tất cả các khối dữ liệu trong tiểu sử.

ext4 và f2fs cũng hỗ trợ mã hóa.  Nếu một tập tin xác thực cũng
được mã hóa, dữ liệu phải được giải mã trước khi được xác minh.  Đến
hỗ trợ điều này, các hệ thống tập tin này phân bổ "ngữ cảnh sau đọc" cho
mỗi tiểu sử và lưu trữ nó trong ZZ0000ZZ::

cấu trúc bio_post_read_ctx {
           cấu trúc sinh học *sinh học;
           cấu trúc công việc_cấu trúc công việc;
           unsigned int cur_step;
           int unsigned_steps;
    };

ZZ0000ZZ là một mặt nạ bit chỉ định việc giải mã,
tính xác thực hoặc cả hai đều được kích hoạt.  Sau khi phần sinh học hoàn tất, đối với mỗi phần cần thiết
bước xử lý hậu kỳ, hệ thống tập tin sẽ xếp bio_post_read_ctx vào hàng đợi
hàng công việc, sau đó hàng công việc sẽ thực hiện việc giải mã hoặc
xác minh.  Cuối cùng, folios không có lỗi giải mã hoặc xác thực
xảy ra được đánh dấu Cập nhật và các folios được mở khóa.

Trên nhiều hệ thống tập tin, tập tin có thể chứa lỗ hổng.  Thông thường,
ZZ0000ZZ chỉ đơn giản là xóa các khối lỗ và xem xét
dữ liệu tương ứng được cập nhật; không có bios được phát hành.  Để ngăn chặn
trường hợp này bỏ qua fs-verity, hệ thống tập tin sử dụng
fsverity_verify_blocks() để xác minh các khối lỗ.

Hệ thống tập tin cũng vô hiệu hóa I/O trực tiếp trên các tập tin xác thực, nếu không thì
I/O trực tiếp sẽ bỏ qua fs-verity.

Tiện ích không gian người dùng
=================

Tài liệu này tập trung vào kernel, nhưng là tiện ích không gian người dùng dành cho
fs-verity có thể được tìm thấy tại:

ZZ0000ZZ

Xem tệp README.md trong cây nguồn fsverity-utils để biết chi tiết,
bao gồm các ví dụ về thiết lập các tệp được bảo vệ fs-verity.

Kiểm tra
=====

Để kiểm tra fs-verity, hãy sử dụng xfstests.  Ví dụ: sử dụng ZZ0000ZZ::

kvm-xfstests -c ext4,f2fs,btrfs -g verity

FAQ
===

Phần này trả lời các câu hỏi thường gặp về fs-verity
chưa được trả lời trực tiếp trong các phần khác của tài liệu này.

:Q: Tại sao fs-verity không phải là một phần của IMA?
:A: fs-verity và IMA (Kiến trúc đo lường tính toàn vẹn) có
    trọng tâm khác nhau.  fs-verity là một cơ chế cấp hệ thống tập tin để
    băm các tệp riêng lẻ bằng cây Merkle.  Ngược lại, IMA
    chỉ định chính sách toàn hệ thống chỉ định tệp nào được
    đã băm và phải làm gì với những giá trị băm đó, chẳng hạn như ghi nhật ký chúng,
    xác thực chúng hoặc thêm chúng vào danh sách đo lường.

IMA hỗ trợ cơ chế băm fs-verity thay thế
    thành các bản băm tập tin đầy đủ, dành cho những ai muốn có hiệu suất và
    lợi ích bảo mật của hàm băm dựa trên cây Merkle.  Tuy nhiên, nó
    không có ý nghĩa gì khi buộc phải thông qua tất cả việc sử dụng fs-verity
    IMA.  fs-verity đã đáp ứng được nhiều nhu cầu của người dùng ngay cả khi
    tính năng hệ thống tập tin độc lập và có thể kiểm tra được như các tính năng khác
    các tính năng của hệ thống tập tin, ví dụ: với xfstests.

:Q: Chẳng phải fs-verity vô dụng vì kẻ tấn công chỉ có thể sửa đổi
    băm trong cây Merkle, được lưu trữ trên đĩa?
:A: Để xác minh tính xác thực của tệp fs-verity, bạn phải xác minh
    tính xác thực của "bản tóm tắt tệp fs-verity", trong đó
    kết hợp hàm băm gốc của cây Merkle.  Xem ZZ0000ZZ.

:Q: Chẳng phải fs-verity vô dụng vì kẻ tấn công chỉ có thể thay thế một
    tập tin xác thực với một tập tin không xác thực?
:A: Xem ZZ0000ZZ.  Trong trường hợp sử dụng ban đầu, nó thực sự đáng tin cậy
    mã không gian người dùng xác thực các tập tin; fs-verity chỉ là một
    công cụ để thực hiện công việc này một cách hiệu quả và an toàn.  Người đáng tin cậy
    mã không gian người dùng sẽ coi các tệp không xác thực là không xác thực.

:Q: Tại sao cây Merkle cần được lưu trữ trên đĩa?  bạn có thể không
    chỉ lưu trữ hàm băm gốc?
:A: Nếu cây Merkle không được lưu trữ trên đĩa thì bạn sẽ phải
    tính toán toàn bộ cây khi tệp được truy cập lần đầu tiên, ngay cả khi
    chỉ một byte đang được đọc.  Đây là hệ quả cơ bản của
    cách băm cây Merkle hoạt động.  Để xác minh một nút lá, bạn cần phải
    xác minh toàn bộ đường dẫn đến hàm băm gốc, bao gồm cả nút gốc
    (thứ mà hàm băm gốc là hàm băm của).  Nhưng nếu gốc
    nút không được lưu trữ trên đĩa, bạn phải tính toán nó bằng cách băm nó
    trẻ em, v.v. cho đến khi bạn thực sự băm toàn bộ tệp.

Điều đó đánh bại hầu hết ý nghĩa của việc thực hiện hàm băm dựa trên cây Merkle,
    vì nếu bạn vẫn phải băm toàn bộ tập tin trước,
    thì bạn có thể chỉ cần thực hiện sha256(file) thay thế.  Sẽ nhiều lắm
    đơn giản hơn và nhanh hơn một chút.

Đúng là cây Merkle trong bộ nhớ vẫn có thể cung cấp
    lợi thế của việc xác minh trên mỗi lần đọc thay vì chỉ trên
    đọc đầu tiên.  Tuy nhiên, nó sẽ không hiệu quả vì mỗi lần
    trang băm bị xóa (bạn không thể ghim toàn bộ cây Merkle vào
    bộ nhớ, vì nó có thể rất lớn), để khôi phục nó, bạn
    một lần nữa cần băm mọi thứ bên dưới nó trong cây.  Cái này nữa
    đánh bại hầu hết ý nghĩa của việc thực hiện hàm băm dựa trên cây Merkle, vì
    một lần đọc khối có thể kích hoạt việc băm lại hàng gigabyte dữ liệu.

:Q: Nhưng bạn không thể chỉ lưu trữ các nút lá và tính toán phần còn lại sao?
:A: Xem câu trả lời trước; điều này thực sự chỉ tăng lên một cấp độ, vì
    người ta có thể hiểu theo cách khác các khối dữ liệu là
    các nút lá của cây Merkle.  Đúng là cái cây có thể
    tính toán nhanh hơn nhiều nếu mức lá được lưu trữ thay vì chỉ
    dữ liệu, nhưng đó chỉ là do mỗi cấp độ nhỏ hơn 1%
    kích thước của cấp độ bên dưới (giả sử cài đặt được đề xuất là
    Khối SHA-256 và 4K).  Vì lý do tương tự, bằng cách lưu trữ
    "chỉ là nút lá" bạn đã lưu trữ hơn 99%
    cây, vì vậy bạn có thể chỉ cần lưu trữ toàn bộ cây.

:Q: Cây Merkle có thể được xây dựng trước thời hạn không, ví dụ: phân phối như
    một phần của gói được cài đặt cho nhiều máy tính?
:A: Điều này hiện không được hỗ trợ.  Đó là một phần của bản gốc
    thiết kế, nhưng đã bị loại bỏ để đơn giản hóa kernel UAPI và vì nó
    không phải là một trường hợp sử dụng quan trọng.  Các tập tin thường được cài đặt một lần và
    được sử dụng nhiều lần và việc băm mật mã diễn ra khá nhanh
    bộ vi xử lý hiện đại nhất.

:Q: Tại sao hỗ trợ fs-verity không ghi?
:A: Việc hỗ trợ viết sẽ rất khó khăn và cần có một
    thiết kế hoàn toàn khác, vì vậy nó nằm ngoài phạm vi của
    fs-verity.  Hỗ trợ viết sẽ yêu cầu:

- Một cách để duy trì tính nhất quán giữa dữ liệu và giá trị băm,
      bao gồm tất cả các cấp độ băm, vì tham nhũng sau sự cố
      (đặc biệt là có thể là toàn bộ tệp!) là không thể chấp nhận được.
      Các lựa chọn chính để giải quyết vấn đề này là ghi nhật ký dữ liệu,
      sao chép khi ghi và khối lượng có cấu trúc nhật ký.  Nhưng rất khó để
      trang bị thêm các hệ thống tập tin hiện có với các cơ chế nhất quán mới.
      Ghi nhật ký dữ liệu có sẵn trên ext4, nhưng rất chậm.

- Xây dựng lại cây Merkle sau mỗi lần viết
      cực kỳ kém hiệu quả.  Ngoài ra, một xác thực khác
      cấu trúc từ điển chẳng hạn như "danh sách bỏ qua được xác thực" có thể
      được sử dụng.  Tuy nhiên, điều này sẽ phức tạp hơn nhiều.

So sánh nó với dm-verity và dm-integrity.  dm-verity rất
    đơn giản: kernel chỉ xác minh dữ liệu chỉ đọc đối với
    cây Merkle chỉ đọc.  Ngược lại, dm-integrity hỗ trợ ghi
    nhưng chậm, phức tạp hơn nhiều và không thực sự hỗ trợ
    xác thực toàn bộ thiết bị vì nó xác thực từng khu vực
    độc lập, tức là không có "băm gốc".  Nó không thực sự
    có ý nghĩa đối với cùng một mục tiêu của trình ánh xạ thiết bị để hỗ trợ hai mục tiêu này
    những trường hợp rất khác nhau; điều tương tự cũng áp dụng cho fs-verity.

:Q: Vì các tệp xác thực là bất biến, tại sao bit bất biến không được đặt?
:A: Bit "bất biến" hiện có (FS_IMMUTABLE_FL) đã có
    tập hợp ngữ nghĩa cụ thể không chỉ làm cho nội dung tệp
    chỉ đọc mà còn ngăn chặn việc xóa, đổi tên tệp,
    được liên kết tới hoặc đã thay đổi chủ sở hữu hoặc chế độ của nó.  Những thứ bổ sung này
    các thuộc tính không mong muốn đối với fs-verity, vì vậy việc sử dụng lại các thuộc tính bất biến
    chút không thích hợp.

:Q: Tại sao API sử dụng ioctls thay vì setxattr() và getxattr()?
:A: Lạm dụng giao diện xattr cho các tòa nhà cao tầng tùy ý về cơ bản là
    hầu hết các nhà phát triển hệ thống tập tin Linux đều không tán thành.
    Một xattr thực sự chỉ là một xattr trên đĩa chứ không phải API để
    ví dụ: kích hoạt việc xây dựng cây Merkle một cách kỳ diệu.

:Q: fs-verity có hỗ trợ hệ thống tập tin từ xa không?
:A: Cho đến nay tất cả các hệ thống tập tin đã triển khai hỗ trợ fs-verity đều
    các hệ thống tập tin cục bộ, nhưng về nguyên tắc, bất kỳ hệ thống tập tin nào có thể lưu trữ
    Siêu dữ liệu xác thực trên mỗi tệp có thể hỗ trợ fs-verity, bất kể
    cho dù đó là địa phương hay từ xa.  Một số hệ thống tập tin có thể có ít hơn
    các tùy chọn về nơi lưu trữ siêu dữ liệu xác thực; một khả năng là
    để lưu trữ nó ở cuối tệp và "ẩn" nó khỏi không gian người dùng
    bằng cách thao tác i_size.  Các chức năng xác minh dữ liệu được cung cấp
    bởi ZZ0000ZZ cũng cho rằng hệ thống tập tin sử dụng Linux
    pagecache, nhưng cả hệ thống tập tin cục bộ và từ xa thường làm như vậy.

:Q: Tại sao lại có mọi thứ dành riêng cho hệ thống tập tin?  Không nên fs-verity
    được triển khai hoàn toàn ở cấp độ VFS?
:A: Có nhiều lý do tại sao điều này là không thể hoặc sẽ rất khó thực hiện.
    khó khăn, trong đó có những nội dung sau:

- Để tránh bỏ qua việc xác minh, các folio không được đánh dấu
      Cập nhật cho đến khi chúng được xác minh.  Hiện tại, mỗi
      hệ thống tập tin chịu trách nhiệm đánh dấu folios Uptodate thông qua
      ZZ0000ZZ.  Vì vậy, hiện tại không thể
      VFS để tự xác minh.  Thay đổi điều này sẽ
      yêu cầu những thay đổi đáng kể đối với VFS và tất cả các hệ thống tập tin.

- Nó đòi hỏi phải xác định một cách độc lập với hệ thống tập tin để lưu trữ
      siêu dữ liệu xác thực.  Thuộc tính mở rộng không hoạt động cho việc này
      bởi vì (a) cây Merkle có thể nặng hàng gigabyte, nhưng nhiều
      hệ thống tập tin giả định rằng tất cả xattr đều phù hợp với một 4K
      khối hệ thống tập tin và (b) mã hóa ext4 và f2fs không
      mã hóa xattrs, nhưng cây Merkle ZZ0000ZZ vẫn được mã hóa khi
      nội dung tập tin là bởi vì nó lưu trữ các giá trị băm của bản rõ
      nội dung tập tin.

Vì vậy, siêu dữ liệu xác thực sẽ phải được lưu trữ trong một hệ thống thực tế
      tập tin.  Sử dụng một tập tin riêng biệt sẽ rất xấu, vì
      siêu dữ liệu về cơ bản là một phần của tệp cần được bảo vệ và
      nó có thể gây ra vấn đề trong đó người dùng có thể xóa tệp thực
      nhưng không phải tệp siêu dữ liệu hoặc ngược lại.  Mặt khác,
      có nó trong cùng một tập tin sẽ phá vỡ các ứng dụng trừ khi
      khái niệm i_size của hệ thống tập tin đã được tách khỏi VFS,
      điều này sẽ phức tạp và yêu cầu thay đổi đối với tất cả các hệ thống tập tin.

- Điều mong muốn là FS_IOC_ENABLE_VERITY sử dụng hệ thống tập tin
      cơ chế giao dịch để tệp kết thúc bằng
      tính xác thực được bật hoặc không có thay đổi nào được thực hiện.  Cho phép trung gian
      các trạng thái xảy ra sau va chạm có thể gây ra vấn đề.