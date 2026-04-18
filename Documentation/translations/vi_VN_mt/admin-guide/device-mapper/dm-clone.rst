.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-clone.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========
dm-bản sao
==========

Giới thiệu
============

dm-clone là mục tiêu của trình ánh xạ thiết bị, tạo ra bản sao một-một của
thiết bị nguồn chỉ đọc hiện có thành thiết bị đích có thể ghi: Nó
trình bày một thiết bị khối ảo giúp tất cả dữ liệu xuất hiện ngay lập tức và
chuyển hướng đọc và viết tương ứng.

Trường hợp sử dụng chính của dm-clone là sao chép một thiết bị có khả năng từ xa, có độ trễ cao,
thiết bị khối loại lưu trữ, chỉ đọc thành thiết bị loại chính, nhanh, có thể ghi
cho I/O nhanh, độ trễ thấp. Thiết bị nhân bản có thể nhìn thấy/có thể gắn kết ngay lập tức
và việc sao chép thiết bị nguồn sang thiết bị đích diễn ra trong
nền, song song với I/O của người dùng.

Ví dụ: người ta có thể khôi phục bản sao lưu ứng dụng từ bản sao chỉ đọc,
có thể truy cập thông qua giao thức lưu trữ mạng (NBD, Fibre Channel, iSCSI, AoE,
v.v.), vào thiết bị SSD hoặc NVMe cục bộ và bắt đầu sử dụng thiết bị ngay lập tức,
mà không cần đợi quá trình khôi phục hoàn tất.

Khi quá trình nhân bản hoàn tất, bảng dm-clone có thể được loại bỏ hoàn toàn và được
được thay thế, ví dụ, bằng một bảng tuyến tính, ánh xạ trực tiếp tới thiết bị đích.

Mục tiêu dm-clone sử dụng lại thư viện siêu dữ liệu được sử dụng bởi hệ thống cung cấp mỏng
mục tiêu.

Thuật ngữ
========

Hydrat hóa
     Quá trình lấp đầy một vùng của thiết bị đích bằng dữ liệu từ
     cùng một vùng của thiết bị nguồn, tức là sao chép vùng từ
     nguồn đến thiết bị đích.

Khi một khu vực được cung cấp đủ nước, chúng tôi sẽ chuyển hướng tất cả I/O liên quan đến khu vực đó đến đích
thiết bị.

Thiết kế
======

Thiết bị phụ
-----------

Mục tiêu được xây dựng bằng cách chuyển ba thiết bị tới nó (cùng với các thiết bị khác
các thông số chi tiết sau):

1. Thiết bị nguồn - thiết bị chỉ đọc được sao chép và nguồn của
   hydrat hóa.

2. Thiết bị đích - đích đến của quá trình hydrat hóa, sẽ trở thành thiết bị
   bản sao của thiết bị nguồn.

3. Một thiết bị siêu dữ liệu nhỏ - nó ghi lại những vùng nào đã hợp lệ trong
   thiết bị đích, tức là vùng nào đã được hydrat hóa hoặc có
   được ghi trực tiếp thông qua I/O của người dùng.

Kích thước của thiết bị đích ít nhất phải bằng kích thước của
thiết bị nguồn.

Khu vực
-------

dm-clone chia thiết bị nguồn và thiết bị đích thành các vùng có kích thước cố định.
Các vùng là đơn vị hydrat hóa, tức là lượng dữ liệu tối thiểu được sao chép từ
nguồn đến thiết bị đích.

Kích thước vùng có thể được cấu hình khi bạn tạo thiết bị dm-clone lần đầu tiên. các
kích thước vùng được đề xuất giống với kích thước khối hệ thống tệp, thường
là 4KB. Kích thước vùng phải nằm trong khoảng từ 8 cung (4KB) đến 2097152 cung
(1GB) và sức mạnh của hai.

Việc đọc và ghi từ/đến các vùng được cung cấp nước được phục vụ từ đích
thiết bị.

Việc đọc tới vùng chưa được ngậm nước được thực hiện trực tiếp từ thiết bị nguồn.

Việc ghi vào vùng chưa được ngậm nước sẽ bị trì hoãn cho đến khi
vùng đã được ngậm nước và quá trình hydrat hóa vùng đó bắt đầu ngay lập tức.

Lưu ý rằng yêu cầu ghi có kích thước bằng kích thước vùng sẽ bỏ qua việc sao chép
vùng tương ứng từ thiết bị nguồn và ghi đè lên vùng của
thiết bị đích trực tiếp.

Loại bỏ
--------

dm-clone diễn giải yêu cầu loại bỏ đến một phạm vi chưa được hydrat hóa
như một gợi ý để bỏ qua quá trình hydrat hóa các vùng được yêu cầu, tức là nó
bỏ qua việc sao chép dữ liệu của vùng từ nguồn sang thiết bị đích và
chỉ cập nhật siêu dữ liệu của nó.

Nếu thiết bị đích hỗ trợ loại bỏ thì theo mặc định dm-clone sẽ vượt qua
xuống loại bỏ các yêu cầu đối với nó.

Hydrat hóa nền
--------------------

dm-clone sao chép liên tục từ nguồn tới thiết bị đích, cho đến khi
tất cả các thiết bị đã được sao chép.

Sao chép dữ liệu từ nguồn sang thiết bị đích sử dụng băng thông. Người dùng
có thể thiết lập một bộ điều tiết để ngăn chặn nhiều hơn một lượng sao chép nhất định xảy ra tại
bất cứ lúc nào. Hơn nữa, dm-clone tính đến lưu lượng truy cập I/O của người dùng đi tới
các thiết bị và tạm dừng quá trình hydrat hóa nền khi có I/O đang hoạt động.

Một thông báo ZZ0000ZZ có thể được sử dụng để đặt số lượng tối đa
của các vùng được sao chép, mặc định là 1 vùng.

dm-clone sử dụng dm-kcopyd để sao chép các phần của thiết bị nguồn vào
thiết bị đích. Theo mặc định, chúng tôi đưa ra các yêu cầu sao chép có kích thước bằng
quy mô khu vực. Một thông báo ZZ0000ZZ có thể được sử dụng để điều chỉnh
kích thước của các yêu cầu sao chép này. Việc tăng cỡ mẻ hydrat hóa dẫn đến
dm-clone đang cố gắng gộp các vùng liền kề lại với nhau, vì vậy chúng tôi sao chép dữ liệu vào
lô của nhiều khu vực này.

Khi quá trình hydrat hóa của thiết bị đích kết thúc, một sự kiện dm sẽ được gửi
tới không gian người dùng.

Cập nhật siêu dữ liệu trên đĩa
-------------------------

Siêu dữ liệu trên đĩa được cam kết mỗi khi viết tiểu sử FLUSH hoặc FUA. Nếu không
những yêu cầu như vậy được thực hiện thì các cam kết sẽ xảy ra mỗi giây. Điều này có nghĩa là
Thiết bị dm-clone hoạt động giống như một đĩa vật lý có bộ đệm ghi dễ thay đổi. Nếu
mất điện, bạn có thể mất một số lần ghi gần đây. Siêu dữ liệu phải luôn
nhất quán bất chấp mọi sự cố.

Giao diện mục tiêu
================

Người xây dựng
-----------

  ::

bản sao <nhà phát triển siêu dữ liệu> <nhà phát triển đích> <nhà phát triển nguồn> <kích thước vùng>
         [<#feature tranh luận> [<feature arg>]* [<#core tranh luận> [<core arg>]*]]

=====================================================================================
 nhà phát triển siêu dữ liệu Thiết bị nhanh chứa siêu dữ liệu liên tục
 Destination dev Thiết bị đích, nơi nguồn sẽ được sao chép
 source dev Thiết bị chỉ đọc chứa dữ liệu được sao chép
 kích thước khu vực Kích thước của một khu vực trong các lĩnh vực

#feature đối số Số lượng đối số tính năng được truyền
 tính năng lập luận no_hydrat hóa hoặc no_discard_passdown

#core đối số Một số chẵn đối số tương ứng với các cặp khóa/giá trị
                  được chuyển tới dm-clone
 core args Các cặp khóa/giá trị được truyền cho dm-clone, ví dụ: ZZ0000ZZ
 =====================================================================================

Đối số tính năng tùy chọn là:

===================================================================================
 no_hydration Tạo một phiên bản dm-clone với tính năng hydrat hóa nền
                      bị vô hiệu hóa
 no_discard_passdown Tắt truyền xuống thiết bị đích
 ===================================================================================

Đối số cốt lõi tùy chọn là:

====================================================================================
 hydrat_threshold <#regions> Số vùng tối đa được sao chép từ
                                  nguồn tới thiết bị đích bất cứ lúc nào
                                  một lần, trong quá trình hydrat hóa nền.
 hydrat hóa_batch_size <#regions> Trong quá trình hydrat hóa nền, hãy thử phân đợt
                                  các vùng liền kề nhau, vì vậy chúng tôi sao chép dữ liệu
                                  từ nguồn đến thiết bị đích trong
                                  lô của nhiều khu vực này.
 ====================================================================================

Trạng thái
------

  ::

<kích thước khối siêu dữ liệu> <khối siêu dữ liệu #used>/<khối siêu dữ liệu #total>
   <kích thước vùng> <vùng #hydrated>/<vùng #total> <vùng #hydrating>
   <#feature đối số> <đối số tính năng>* <#core đối số> <đối số lõi>*
   <chế độ siêu dữ liệu sao chép>

====================================================================================
 kích thước khối siêu dữ liệu Kích thước khối cố định cho từng khối siêu dữ liệu trong các lĩnh vực
 Khối siêu dữ liệu #used Số khối siêu dữ liệu được sử dụng
 Khối siêu dữ liệu #total Tổng số khối siêu dữ liệu
 kích thước vùng Kích thước vùng có thể định cấu hình cho thiết bị theo các khu vực
 Vùng #hydrated Số vùng đã dưỡng ẩm xong
 Vùng #total Tổng số vùng cần hydrat hóa
 Vùng #hydrating Số vùng hiện đang dưỡng ẩm
 #feature đối số Số lượng đối số tính năng cần tuân theo
 feature args Đối số của tính năng, ví dụ: ZZ0000ZZ
 #core lập luận Số lượng đối số cốt lõi chẵn cần tuân theo
 core args Các cặp khóa/giá trị để điều chỉnh lõi, ví dụ:
                         ZZ0001ZZ
 sao chép chế độ siêu dữ liệu ro nếu chỉ đọc, rw nếu đọc-ghi

Trong những trường hợp nghiêm trọng, ngay cả chế độ chỉ đọc cũng được coi là
                         không an toàn sẽ không cho phép I/O thêm nữa và trạng thái
                         sẽ chỉ chứa chuỗi 'Thất bại'. Nếu siêu dữ liệu
                         thay đổi chế độ, một sự kiện dm sẽ được gửi đến không gian người dùng.
 ====================================================================================

Tin nhắn
--------

ZZ0000ZZ
      Tắt tính năng hydrat hóa nền của thiết bị đích.

ZZ0000ZZ
      Kích hoạt tính năng hydrat hóa nền của thiết bị đích.

ZZ0000ZZ
      Đặt ngưỡng hydrat hóa nền.

ZZ0000ZZ
      Đặt kích thước lô hydrat hóa nền.

Ví dụ
========

Sao chép một thiết bị chứa hệ thống tập tin
---------------------------------------

1. Tạo thiết bị dm-clone.

   ::

dmsetup tạo bản sao --table "0 1048576000 bản sao $metadata_dev $dest_dev \
      $source_dev 8 1 no_hydrat hóa"

2. Gắn thiết bị và cắt bớt hệ thống tập tin. dm-clone diễn giải việc loại bỏ
   được gửi bởi hệ thống tập tin và nó sẽ không hydrat hóa không gian chưa sử dụng.

   ::

mount /dev/mapper/clone /mnt/clone-fs
    fstrim /mnt/nhân bản-fs

3. Kích hoạt tính năng hydrat hóa nền của thiết bị đích.

   ::

bản sao thông báo dmsetup 0 allow_hydration

4. Khi quá trình hydrat hóa kết thúc, chúng ta có thể thay thế bảng dm-clone bằng bảng tuyến tính
   cái bàn.

   ::

bản sao đình chỉ dmsetup
    bản sao tải dmsetup --table "0 1048576000 tuyến tính $dest_dev 0"
    bản sao sơ yếu lý lịch dmsetup

Thiết bị siêu dữ liệu không còn cần thiết nữa và có thể được loại bỏ hoặc tái sử dụng một cách an toàn
   cho các mục đích khác.

Các vấn đề đã biết
============

1. Chúng tôi chuyển hướng các lần đọc đến các vùng chưa được cấp nước đến thiết bị nguồn. Nếu
   việc đọc thiết bị nguồn có độ trễ cao và người dùng liên tục đọc từ
   cùng một khu vực, hành vi này có thể làm giảm hiệu suất. Chúng ta nên sử dụng
   những điều này được coi là gợi ý để hydrat hóa các khu vực liên quan sớm hơn. Hiện tại, chúng tôi
   dựa vào bộ nhớ đệm của trang để lưu vào bộ nhớ đệm các vùng này nên chúng tôi hy vọng không kết thúc
   đọc chúng nhiều lần từ thiết bị nguồn.

2. Phát hành các tài nguyên cốt lõi, tức là các bitmap theo dõi các khu vực
   ngậm nước, sau khi quá trình hydrat hóa kết thúc.

3. Trong quá trình hydrat hóa nền, nếu chúng ta không đọc được nguồn hoặc ghi vào
   thiết bị đích, chúng tôi in một thông báo lỗi, nhưng quá trình hydrat hóa
   tiếp tục vô thời hạn, cho đến khi nó thành công. Chúng ta nên dừng nền
   hydrat hóa sau một số lần thất bại và phát ra sự kiện dm cho không gian người dùng để
   thông báo.

Tại sao không...?
===========

Chúng tôi đã khám phá các lựa chọn thay thế sau trước khi triển khai dm-clone:

1. Sử dụng dm-cache với kích thước bộ đệm bằng thiết bị nguồn và triển khai bộ đệm mới
   chính sách nhân bản:

* Thiết bị bộ đệm kết quả không phải là bản sao một-một của thiết bị nguồn
     và do đó chúng tôi không thể xóa thiết bị bộ nhớ đệm sau khi quá trình sao chép hoàn tất.

* dm-cache ghi vào thiết bị nguồn, vi phạm yêu cầu của chúng tôi rằng
     thiết bị nguồn phải được coi là chỉ đọc.

* Bộ nhớ đệm khác với việc sao chép về mặt ngữ nghĩa.

2. Sử dụng dm-snapshot với thiết bị COW tương đương với thiết bị nguồn:

* dm-snapshot lưu trữ siêu dữ liệu của nó trong thiết bị COW, do đó thiết bị thu được
     không phải là bản sao một-một của thiết bị nguồn.

* Không có cơ chế sao chép nền.

* dm-snapshot cần xác nhận siêu dữ liệu của nó bất cứ khi nào có ngoại lệ đang chờ xử lý
     hoàn tất, để đảm bảo tính nhất quán của ảnh chụp nhanh. Trong trường hợp nhân bản, chúng tôi không
     cần phải rất nghiêm ngặt và có thể dựa vào việc cam kết siêu dữ liệu mỗi khi FLUSH
     hoặc tiểu sử FUA được viết hoặc định kỳ, giống như dm-thin và dm-cache. Cái này
     cải thiện hiệu suất đáng kể.

3. Sử dụng dm-mirror: Mục tiêu nhân bản có sao chép/phản chiếu nền
   cơ chế, nhưng nó ghi vào tất cả các máy nhân bản, do đó vi phạm yêu cầu của chúng tôi rằng
   thiết bị nguồn phải được coi là chỉ đọc.

4. Sử dụng chức năng chụp nhanh bên ngoài của dm-thin. Cách tiếp cận này là nhất
   đầy hứa hẹn trong số tất cả các lựa chọn thay thế, vì khối lượng được cung cấp ít là một
   bản sao một-một của thiết bị nguồn và xử lý việc đọc và ghi vào
   các khu vực chưa được cung cấp/chưa được sao chép giống như cách làm của dm-clone.

Vẫn:

* Không có cơ chế sao chép nền, mặc dù cơ chế này có thể được triển khai.

* Quan trọng nhất, chúng tôi muốn hỗ trợ các thiết bị chặn tùy ý vì
     đích của quá trình nhân bản và không hạn chế bản thân chúng ta
     khối lượng được cung cấp mỏng. Cung cấp mỏng có siêu dữ liệu vốn có
     chi phí chung, để duy trì ánh xạ khối lượng mỏng, điều này đáng kể
     làm suy giảm hiệu suất.

Hơn nữa, việc nhân bản một thiết bị không nên buộc phải sử dụng thiết bị cung cấp mỏng. Bật
   mặt khác, nếu chúng ta muốn sử dụng việc cung cấp mỏng, chúng ta có thể chỉ cần sử dụng một lớp mỏng
   LV là thiết bị đích của dm-clone.