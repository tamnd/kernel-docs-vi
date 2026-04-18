.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/nvdimm/btt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
BTT - Bảng dịch khối
================================


1. Giới thiệu
===============

Bộ lưu trữ dựa trên bộ nhớ liên tục có thể thực hiện IO theo byte (hoặc nhiều hơn
chính xác, dòng bộ đệm) chi tiết. Tuy nhiên, chúng ta thường muốn phơi bày những điều đó
lưu trữ như các thiết bị khối truyền thống. Trình điều khiển khối cho bộ nhớ liên tục
sẽ làm chính xác điều này Tuy nhiên, họ không cung cấp bất kỳ sự đảm bảo nào về tính nguyên tử.
SSD truyền thống thường cung cấp khả năng bảo vệ chống lại các thành phần bị rách trong phần cứng,
sử dụng năng lượng dự trữ trong tụ điện để hoàn thành việc ghi khối trong chuyến bay, hoặc có lẽ
trong phần sụn. Chúng tôi không có được sự sang trọng này với bộ nhớ liên tục - nếu một thao tác ghi được thực hiện
tiến triển và chúng tôi gặp sự cố mất điện, khối sẽ chứa hỗn hợp cũ
và dữ liệu mới. Các ứng dụng có thể không được chuẩn bị để xử lý tình huống như vậy.

Bảng dịch khối (BTT) cung cấp ngữ nghĩa cập nhật khu vực nguyên tử cho
thiết bị bộ nhớ liên tục, để các ứng dụng dựa trên khu vực ghi không
bị rách có thể tiếp tục làm như vậy. BTT thể hiện dưới dạng một khối xếp chồng lên nhau
thiết bị và dành một phần dung lượng lưu trữ cơ bản cho siêu dữ liệu của nó. Tại
trung tâm của nó là một bảng hướng dẫn ánh xạ lại tất cả các khối trên
khối lượng. Nó có thể được coi là một hệ thống tập tin cực kỳ đơn giản, chỉ
cung cấp thông tin cập nhật về lĩnh vực nguyên tử.


2. Bố cục tĩnh
================

Bộ lưu trữ cơ bản mà BTT có thể được đặt trên đó không bị giới hạn dưới bất kỳ hình thức nào.
Tuy nhiên, BTT chia không gian có sẵn thành các phần có kích thước lên tới 512 GiB,
được gọi là "Đấu trường".

Mỗi đấu trường tuân theo cùng một bố cục cho siêu dữ liệu của nó và tất cả các tham chiếu trong một
đấu trường là nội bộ của nó (ngoại trừ một trường trỏ đến
đấu trường tiếp theo). Phần sau đây mô tả bố cục siêu dữ liệu "Trên đĩa"::


Cửa hàng ủng hộ +-------> Đấu trường
  +--------------+ |   +-------------------+
  ZZ0000ZZ ZZ0001ZZ Khối thông tin đấu trường |
  ZZ0002ZZ 4K |
  ZZ0003ZZ +-------------------+
  ZZ0004ZZ ZZ0005ZZ
  +--------------+ ZZ0006ZZ
  ZZ0007ZZ ZZ0008ZZ
  ZZ0009ZZ ZZ0010ZZ
  ZZ0011ZZ ZZ0012ZZ
  ZZ0013ZZ ZZ0014ZZ
  +--------------+ ZZ0015ZZ
  ZZ0016ZZ ZZ0017ZZ
  ZZ0018ZZ ZZ0019ZZ
  ZZ0020ZZ ZZ0021ZZ
  ZZ0022ZZ ZZ0023ZZ
  ZZ0024ZZ ZZ0025ZZ
  +--------------+ +-------------------+
                          ZZ0026ZZ
                          ZZ0027ZZ
                          ZZ0028ZZ
                          ZZ0029ZZ
                          +-------------------+
                          ZZ0030ZZ
                          ZZ0031ZZ
                          ZZ0032ZZ
                          +-------------------+
                          ZZ0033ZZ
                          ZZ0034ZZ
                          +-------------------+


3. Lý thuyết hoạt động
======================


Một. Bản đồ BTT
---------------

Bản đồ là một bảng tra cứu/chỉ dẫn đơn giản ánh xạ LBA tới một bảng nội bộ
khối. Mỗi mục bản đồ là 32 bit. Hai bit quan trọng nhất là đặc biệt
cờ và phần còn lại tạo thành số khối nội bộ.

===========================================================================
Mô tả bit
===========================================================================
31 - 30 Cờ lỗi và cờ Zero - Được sử dụng theo cách sau:

== == =========================================================
	   31 30 Mô tả
	   == == =========================================================
	   0 0 Trạng thái ban đầu. Đọc trả về số 0; Bản đồ trước = Bản đồ bài đăng
	   0 1 Trạng thái 0: Đọc các số 0 trả về
	   1 0 Trạng thái lỗi: Đọc không thành công; Viết bit 'E' rõ ràng
	   1 1 Khối bình thường – có postmap hợp lệ
	   == == =========================================================

29 - 0 Ánh xạ tới các khối 'bản đồ bưu điện' nội bộ
===========================================================================


Một số thuật ngữ sẽ được sử dụng sau này:

==================================================================================
LBA LBA bên ngoài được hiển thị cho các lớp trên.
Địa chỉ khối đấu trường ABA - Khối bù/số trong một đấu trường
Sơ đồ trước ABA Khối chuyển vào đấu trường, được quyết định theo phạm vi
		kiểm tra LBA bên ngoài
Postmap ABA Số khối trong khu vực "Khối dữ liệu" thu được sau
		hướng từ bản đồ
nfree Số lượng khối miễn phí được duy trì tại bất kỳ thời điểm nào.
		Đây là số lần ghi đồng thời có thể xảy ra với
		đấu trường.
==================================================================================


Ví dụ: sau khi thêm BTT, chúng tôi sẽ hiển thị một đĩa có dung lượng 1024G. Chúng tôi nhận được một bài đọc cho
LBA bên ngoài ở 768G. Điều này rơi vào đấu trường thứ hai và của 512G
giá trị khối mà đấu trường này đóng góp, khối này ở mức 256G. Như vậy,
bản đồ trước ABA là 256G. Bây giờ chúng ta tham khảo bản đồ và tìm ra ánh xạ cho khối
'X' (256G) trỏ đến khối 'Y', giả sử '64'. Do đó, postmap ABA là 64.


b. Flog BTT
---------------

BTT cung cấp tính nguyên tử của khu vực bằng cách thực hiện mỗi lần ghi thành "ghi phân bổ",
tức là mỗi lần ghi đều chuyển đến một khối "miễn phí". Một danh sách các khối miễn phí đang chạy là
được duy trì ở dạng phao BTT. 'Flog' là sự kết hợp của các từ
"danh sách miễn phí" và "nhật ký". Flog chứa các mục 'nfree' và một mục chứa:

====================================================================================
lba Bản đồ trước ABA đang được ghi vào
old_map Postmap cũ ABA - sau khi quá trình viết 'cái này' hoàn tất, đây sẽ là một
	  khối miễn phí.
new_map Bản đồ bưu điện mới ABA. Bản đồ sẽ được cập nhật để phản ánh điều này
	  ánh xạ lba->postmap_aba, nhưng chúng tôi đăng nhập nó ở đây trong trường hợp chúng tôi phải
	  phục hồi.
seq Số thứ tự để đánh dấu phần nào trong 2 phần của mục nhập flog này là
	  hợp lệ/mới nhất. Nó quay vòng trong khoảng 01->10->11->01 (nhị phân) trong điều kiện bình thường
	  hoạt động, với 00 biểu thị trạng thái chưa được khởi tạo.
lba' mục nhập lba thay thế
old_map' mục nhập bản đồ cũ thay thế
new_map' mục nhập bản đồ mới thay thế
seq' số thứ tự thay thế.
====================================================================================

Mỗi trường trên là 32 bit, tạo thành một mục nhập 32 byte. Các mục cũng được
được đệm đến 64 byte để tránh chia sẻ hoặc đặt bí danh dòng bộ đệm. Cập nhật Flog là
được thực hiện sao cho đối với bất kỳ mục nào được viết, nó:
một. ghi đè phần 'cũ' trong mục nhập dựa trên số thứ tự
b. ghi phần 'mới' sao cho số thứ tự được viết cuối cùng.


c. Khái niệm làn đường
-----------------------

Trong khi 'nfree' mô tả số lượng IO đồng thời mà một đấu trường có thể xử lý
đồng thời, 'nlanes' là số lượng IO mà toàn bộ thiết bị BTT có thể
quá trình::

nlanes = phút(nfree, num_cpus)

Số làn được lấy khi bắt đầu bất kỳ IO nào và được sử dụng để lập chỉ mục vào
tất cả cấu trúc dữ liệu trên đĩa và trong bộ nhớ trong suốt thời gian của IO. Nếu
có nhiều CPU hơn số làn tối đa có sẵn, hơn số làn
được bảo vệ bởi spinlocks.


d. Cấu trúc dữ liệu trong bộ nhớ: Bảng theo dõi đọc (RTT)
---------------------------------------------------------

Hãy xem xét trường hợp chúng ta có hai luồng, một luồng đọc và luồng kia,
viết. Chúng ta có thể gặp phải điều kiện trong đó luồng tác giả lấy một khối trống để thực hiện
một IO mới, nhưng chuỗi trình đọc (chậm) vẫn đang đọc từ nó. Nói cách khác,
người đọc tham khảo một mục bản đồ và bắt đầu đọc khối tương ứng. A
người viết bắt đầu ghi vào cùng một LBA bên ngoài và hoàn tất việc cập nhật ghi
bản đồ cho LBA bên ngoài đó trỏ tới bản đồ bưu điện ABA mới của nó. Tại thời điểm này
khối nội bộ, postmap mà người đọc đang (vẫn) đọc đã được chèn vào
vào danh sách các khối miễn phí. Nếu có một lần ghi khác cho cùng một LBA, nó có thể
lấy khối trống này và bắt đầu viết vào nó, khiến người đọc đọc
dữ liệu không chính xác. Để ngăn chặn điều này, chúng tôi giới thiệu RTT.

RTT là một bảng đấu trường đơn giản với các mục 'không miễn phí'. Mỗi độc giả chèn
vào rtt[lane_number], postmap ABA mà nó đang đọc và xóa nó sau
đọc là xong. Mỗi chuỗi nhà văn, sau khi lấy một khối trống, sẽ kiểm tra
RTT vì sự hiện diện của nó. Nếu khối miễn phí của bản đồ bưu điện nằm trong RTT, nó sẽ đợi cho đến khi
đầu đọc xóa mục nhập RTT và chỉ sau đó mới bắt đầu ghi vào mục đó.


đ. Cấu trúc dữ liệu trong bộ nhớ: khóa bản đồ
---------------------------------------------

Hãy xem xét trường hợp hai luồng tác giả đang ghi vào cùng một LBA. Có thể có
là một cuộc đua theo trình tự các bước sau::

free[lane] = bản đồ[premap_aba]
	bản đồ[premap_aba] = postmap_aba

Cả hai luồng đều có thể cập nhật [làn đường] miễn phí tương ứng của chúng với cùng một làn đường cũ, được giải phóng
postmap_aba. Điều này đã làm cho bố cục không nhất quán do mất một mục nhập miễn phí và
đồng thời nhân đôi một lối vào tự do khác cho hai làn đường.

Để giải quyết vấn đề này, chúng ta có thể phải sử dụng một khóa bản đồ duy nhất (mỗi đấu trường)
trước khi thực hiện trình tự trên nhưng chúng tôi cảm thấy điều đó có thể gây tranh cãi.
Thay vào đó, chúng tôi sử dụng một mảng map_locks (nfree) được lập chỉ mục bởi
(premap_aba modulo nfree).


f. Tái thiết từ Flog
-------------------------------

Khi khởi động, chúng tôi phân tích Flog BTT để tạo danh sách các khối miễn phí. Chúng tôi đi bộ
thông qua tất cả các mục và đối với mỗi làn, trong số hai mục có thể
'phần', chúng tôi luôn chỉ xem xét phần gần đây nhất (dựa trên trình tự
số). Các quy tắc/bước xây dựng lại rất đơn giản:

- Đọc bản đồ[log_entry.lba].
- Nếu log_entry.new khớp với mục nhập bản đồ thì log_entry.old miễn phí.
- Nếu log_entry.new không khớp với mục bản đồ thì log_entry.new sẽ miễn phí.
  (Trường hợp này chỉ có thể xảy ra do mất điện/tắt máy không an toàn)


g. Tóm tắt - Luồng đọc và ghi
-------------------------------------

Đọc:

1. Chuyển đổi LBA bên ngoài thành số đấu trường + ABA trước bản đồ
2. Nhận làn đường (và lấy làn_lock)
3. Đọc bản đồ để lấy mục nhập cho bản đồ trước ABA này
4. Nhập post-map ABA vào RTT[lane]
5. Nếu cờ TRIM được đặt trên bản đồ, hãy trả về số 0 và kết thúc IO (chuyển tới bước 8)
6. Nếu cờ ERROR được đặt trên bản đồ, hãy kết thúc IO bằng EIO (chuyển tới bước 8)
7. Đọc dữ liệu từ khối này
8. Xóa mục nhập ABA sau bản đồ khỏi RTT[lane]
9. Nhả làn (và Lane_lock)

Viết:

1. Chuyển đổi LBA bên ngoài thành số Arena + ABA trước bản đồ
2. Nhận làn đường (và lấy làn_lock)
3. Sử dụng làn đường để lập chỉ mục vào danh sách trống trong bộ nhớ và nhận khối mới, lượt tiếp theo
    chỉ mục, số thứ tự tiếp theo
4. Quét RTT để kiểm tra xem có khối trống hay không và quay/chờ nếu có.
5. Ghi dữ liệu vào khối trống này
6. Đọc bản đồ để lấy mục ABA sau bản đồ hiện có cho ABA trước bản đồ này
7. Viết mục nhập flog: [premap_aba / old postmap_aba / new postmap_aba / seq_num]
8. Viết post-map ABA mới vào bản đồ.
9. Viết mục post-map cũ vào danh sách miễn phí
10. Tính số thứ tự tiếp theo và ghi vào mục danh sách trống
11. Nhả làn (và Lane_lock)


4. Xử lý lỗi
=================

Đấu trường sẽ ở trạng thái lỗi nếu bất kỳ siêu dữ liệu nào bị hỏng
không thể phục hồi được do lỗi hoặc lỗi phương tiện. Các điều kiện sau
chỉ ra một lỗi:

- Tổng kiểm tra khối thông tin không khớp (và việc khôi phục từ bản sao cũng không thành công)
- Tất cả các khối có sẵn bên trong không được xử lý duy nhất và hoàn toàn bởi
  tổng số khối được ánh xạ và khối miễn phí (từ flog BTT).
- Việc xây dựng lại danh sách miễn phí từ flog bị thiếu/trùng lặp/không thể
  mục
- Một mục bản đồ nằm ngoài giới hạn

Nếu gặp phải bất kỳ tình trạng lỗi nào trong số này, đấu trường sẽ được chuyển sang trạng thái đọc
trạng thái duy nhất sử dụng cờ trong khối thông tin.


5. Cách sử dụng
===============

BTT có thể được thiết lập trên bất kỳ đĩa (không gian tên) nào được hệ thống con libnvdimm hiển thị
(chế độ pmem hoặc blk). Cách dễ nhất để thiết lập một không gian tên như vậy là sử dụng
Tiện ích 'ndctl' [1]:

Ví dụ: dòng lệnh ndctl để thiết lập btt với kích thước cung 4k là::

ndctl create-namespace -f -e namespace0.0 -m Sector -l 4k

Xem ndctl create-namespace --help để có thêm tùy chọn.

[1]: ZZ0000ZZ
