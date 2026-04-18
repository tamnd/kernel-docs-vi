.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/dc-debug.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Công cụ gỡ lỗi lõi hiển thị
========================

Trong phần này, bạn sẽ tìm thấy thông tin hữu ích về cách gỡ lỗi amdgpu.
trình điều khiển từ góc độ hiển thị. Trang này giới thiệu cơ chế gỡ lỗi và
quy trình giúp bạn xác định xem một số vấn đề có liên quan đến mã hiển thị hay không.

Thu hẹp các vấn đề hiển thị
==========================

Vì màn hình là thành phần trực quan của người lái nên người dùng thường thấy
báo cáo sự cố dưới dạng hiển thị khi thành phần khác gây ra sự cố. Cái này
phần trang bị cho người dùng xác định xem một sự cố cụ thể có phải do màn hình gây ra hay không
thành phần hoặc một phần khác của trình điều khiển.

DC dmesg tin nhắn quan trọng
---------------------------

Nhật ký dmesg là nguồn thông tin đầu tiên được kiểm tra và amdgpu
tận dụng tính năng này bằng cách ghi lại một số thông tin có giá trị. Khi nào
đang tìm kiếm các vấn đề liên quan đến amdgpu, hãy nhớ rằng mỗi thành phần của
trình điều khiển (ví dụ: smu, PSP, dm, v.v.) được tải từng cái một và điều này
thông tin có thể được tìm thấy trong nhật ký dmesg. Theo nghĩa này, hãy tìm phần của
nhật ký trông giống như đoạn nhật ký bên dưới::

[ 4.254295] [drm] đang khởi tạo cài đặt chế độ kernel (IP DISCOVERY 0x1002:0x744C 0x1002:0x0E3B 0xC8).
  [ 4.254718] [drm] đăng ký cơ sở mmio: 0xFCB00000
  [ 4.254918] [drm] đăng ký kích thước mmio: 1048576
  [ 4.260095] [drm] thêm số khối ip 0 <soc21_common>
  [ 4.260318] [drm] thêm khối ip số 1 <gmc_v11_0>
  [ 4.260510] [drm] thêm khối ip số 2 <ih_v6_0>
  [ 4.260696] [drm] thêm khối ip số 3 <psp>
  [ 4.260878] [drm] thêm khối ip số 4 <smu>
  [ 4.261057] [drm] thêm khối ip số 5 <dm>
  [ 4.261231] [drm] thêm khối ip số 6 <gfx_v11_0>
  [ 4.261402] [drm] thêm khối ip số 7 <sdma_v6_0>
  [ 4.261568] [drm] thêm khối ip số 8 <vcn_v4_0>
  [ 4.261729] [drm] thêm khối ip số 9 <jpeg_v4_0>
  [ 4.261887] [drm] thêm khối ip số 10 <mes_v11_0>

Từ ví dụ trên, bạn có thể thấy dòng báo cáo rằng ZZ0000ZZ,
(ZZ0001ZZ), đã được tải, có nghĩa là màn hình có thể là một phần của
vấn đề. Nếu bạn không thấy dòng đó thì có thể trước đó đã có lỗi nào đó khác xảy ra
amdgpu tải thành phần hiển thị, cho biết rằng chúng tôi không có
hiển thị vấn đề.

Sau khi bạn xác định rằng DM đã được tải chính xác, bạn có thể kiểm tra
phiên bản hiển thị của phần cứng đang được sử dụng, có thể được lấy từ dmesg
đăng nhập bằng lệnh::

dmesg | grep -i 'lõi hiển thị'

Lệnh này hiển thị một thông báo giống như thế này::

[ 4.655828] [drm] Display Core v3.2.285 được khởi chạy trên DCN 3.2

Thông báo này có hai thông tin chính:

* ZZ0001ZZ: Các nhà phát triển màn hình phát hành phiên bản DC mới
  mỗi tuần và thông tin này có thể hữu ích trong trường hợp
  người dùng/nhà phát triển phải tìm ra điểm tốt và điểm xấu dựa trên kết quả đã được kiểm tra
  phiên bản của mã hiển thị. Hãy nhớ từ trang ZZ0000ZZ,
  rằng mỗi tuần các bản vá mới để hiển thị đều được thử nghiệm kỹ lưỡng với IGT và
  các bài kiểm tra thủ công.
* ZZ0002ZZ: Khối DCN được liên kết với
  thế hệ phần cứng và phiên bản DCN truyền tải thế hệ phần cứng
  trình điều khiển hiện đang chạy. Thông tin này giúp thu hẹp phạm vi
  khu vực gỡ lỗi mã vì mỗi phiên bản DCN đều có các tệp trong thư mục DC trên mỗi DCN
  thành phần (từ ví dụ, nhà phát triển có thể muốn tập trung vào
  các tệp/thư mục/hàm/cấu trúc có nhãn dcn32 có thể được thực thi).
  Tuy nhiên, hãy nhớ rằng DC sử dụng lại mã trên các phiên bản DCN khác nhau; cho
  ví dụ: dự kiến sẽ có một số lệnh gọi lại được đặt trong một DCN giống nhau
  như những chiếc từ DCN khác. Tóm lại, hãy sử dụng phiên bản DCN làm hướng dẫn.

Từ tệp dmesg, bạn cũng có thể lấy mã bios ATOM bằng cách sử dụng ::

dmesg | grep -i 'ATOM BIOS'

Cái nào tạo ra một đầu ra trông như thế này ::

[ 4.274534] amdgpu: ATOM BIOS: 113-D7020100-102

Loại thông tin này rất hữu ích để được báo cáo.

Tránh tải lõi hiển thị
--------------------------

Đôi khi, có thể khó tìm ra phần nào của trình điều khiển gây ra
vấn đề; nếu bạn nghi ngờ rằng màn hình không phải là một phần của vấn đề và
kịch bản lỗi rất đơn giản (ví dụ: một số cấu hình máy tính để bàn), bạn có thể thử xóa
thành phần hiển thị từ phương trình. Đầu tiên bạn cần xác định ID ZZ0000ZZ
từ nhật ký dmesg; ví dụ: tìm kiếm nhật ký sau::

[ 4.254295] [drm] đang khởi tạo cài đặt chế độ kernel (IP DISCOVERY 0x1002:0x744C 0x1002:0x0E3B 0xC8).
  [..]
  [ 4.260095] [drm] thêm số khối ip 0 <soc21_common>
  [ 4.260318] [drm] thêm khối ip số 1 <gmc_v11_0>
  [..]
  [ 4.261057] [drm] thêm khối ip số 5 <dm>

Lưu ý từ ví dụ trên rằng id ZZ0000ZZ là 5 cho phần cứng cụ thể này.
Tiếp theo, bạn cần chạy thao tác nhị phân sau để xác định khối IP
mặt nạ::

0xffffffff & ~(1 << [DM ID])

Từ ví dụ của chúng tôi, mặt nạ IP là::

0xffffffff & ~(1 << 5) = 0xffffffdf

Cuối cùng, để tắt DC, bạn chỉ cần đặt tham số bên dưới trong
bộ nạp khởi động::

amdgpu.ip_block_mask = 0xffffffdf

Nếu bạn có thể khởi động hệ thống của mình khi DC bị tắt mà vẫn thấy sự cố, thì đó là
có nghĩa là bạn có thể loại DC ra khỏi phương trình. Tuy nhiên, nếu lỗi biến mất, bạn
vẫn cần xem xét phần DC của vấn đề và tiếp tục thu hẹp phạm vi
vấn đề. Trong một số trường hợp, việc tắt DC là không thể vì có thể
cần thiết để sử dụng thành phần hiển thị để tái tạo sự cố (ví dụ: phát một
trò chơi).

ZZ0000ZZ

Màn hình nhấp nháy
------------------

Màn hình nhấp nháy có thể có nhiều nguyên nhân; một là thiếu sức mạnh phù hợp
tới GPU hoặc các sự cố trong bộ chuyển mạch DPM. Một xác minh chung đầu tiên tốt
là đặt GPU để sử dụng điện áp cao::

bash -c "echo high > /sys/class/drm/card0/device/power_dpm_force_performance_level"

Lệnh trên đặt GPU/APU sử dụng công suất tối đa được phép
vô hiệu hóa các công tắc DPM. Nếu việc buộc DPM ở mức cao không khắc phục được sự cố thì
ít có khả năng vấn đề liên quan đến quản lý nguồn điện. Nếu vấn đề
biến mất, rất có thể các thành phần khác có thể liên quan, và
Không nên bỏ qua màn hình vì đây có thể là sự cố DPM. Từ
phía hiển thị, nếu việc tăng công suất khắc phục được sự cố thì bạn nên gỡ lỗi
cấu hình đồng hồ và cảnh sát chia đường ống được sử dụng cụ thể
cấu hình.

Hiển thị hiện vật
-----------------

Người dùng có thể thấy một số tạo phẩm trên màn hình có thể được phân loại thành hai loại khác nhau
loại: hiện vật cục bộ và hiện vật chung. Các hiện vật được bản địa hóa
xảy ra ở một số khu vực cụ thể, chẳng hạn như xung quanh các góc cửa sổ giao diện người dùng; nếu bạn thấy
loại vấn đề này, rất có thể bạn có một không gian người dùng
vấn đề, có thể là Mesa hoặc tương tự. Các tạo tác chung thường xảy ra trên
toàn bộ màn hình. Chúng có thể do cấu hình sai ở cấp trình điều khiển
của các thông số hiển thị, nhưng không gian người dùng cũng có thể gây ra sự cố này. một
cách để xác định nguồn gốc của vấn đề là chụp ảnh màn hình hoặc tạo một
quay video trên máy tính để bàn khi sự cố xảy ra; sau khi kiểm tra
ghi lại ảnh chụp màn hình/video, nếu bạn không thấy bất kỳ tạo phẩm nào, điều đó có nghĩa là
rằng vấn đề có thể nằm ở phía người lái xe. Nếu bạn vẫn có thể nhìn thấy
vấn đề trong dữ liệu được thu thập, đó là một vấn đề có thể xảy ra trong quá trình
kết xuất và mã hiển thị vừa khiến bộ đệm khung bị hỏng.

Tắt/Bật các tính năng cụ thể
====================================

DC có cấu trúc có tên ZZ0000ZZ, được khởi tạo tĩnh bởi
tất cả các thành phần DCE/DCN dựa trên đặc tính phần cứng cụ thể. Cái này
cấu trúc thường tạo điều kiện thuận lợi cho giai đoạn khởi động vì các nhà phát triển có thể bắt đầu
với nhiều tính năng bị vô hiệu hóa và kích hoạt chúng riêng lẻ. Đây cũng là một
tính năng gỡ lỗi quan trọng vì người dùng có thể thay đổi nó khi gỡ lỗi cụ thể
vấn đề.

Ví dụ: người dùng dGPU đôi khi gặp sự cố trong đó góc bo ngang của
nhấp nháy xảy ra ở một số phần cụ thể của màn hình. Đây có thể là một
dấu hiệu của các vấn đề về Chế độ xem phụ; sau khi người dùng xác định được mục tiêu DCN,
họ có thể đặt trường ZZ0000ZZ thành true trong chế độ tĩnh
phiên bản khởi tạo của ZZ0001ZZ để xem sự cố có được khắc phục hay không. Cùng
tương tự, người dùng/nhà phát triển cũng có thể thử tắt ZZ0002ZZ và
ZZ0003ZZ. Tóm lại, ZZ0004ZZ là
một hình thức thú vị để xác định vấn đề.

Xác nhận trực quan DC
======================

Lõi hiển thị cung cấp một tính năng có tên là xác nhận trực quan, là một tập hợp các
các thanh được người lái xe thêm vào lúc quét để truyền tải một số thông tin cụ thể
thông tin. Nói chung, bạn có thể kích hoạt tùy chọn gỡ lỗi này bằng cách sử dụng::

echo <N> > /sys/kernel/debug/dri/0/amdgpu_dm_visual_confirm

Trong đó ZZ0000ZZ là số nguyên cho một số trường hợp cụ thể mà nhà phát triển
muốn kích hoạt, bạn sẽ thấy một số trường hợp gỡ lỗi này trong phần sau
tiểu mục.

Gỡ lỗi nhiều mặt phẳng
---------------------

Nếu bạn muốn bật hoặc gỡ lỗi nhiều mặt phẳng trong một không gian người dùng cụ thể
ứng dụng, bạn có thể tận dụng tính năng gỡ lỗi có tên là xác nhận trực quan. cho
kích hoạt nó, bạn sẽ cần::

echo 1 > /sys/kernel/debug/dri/0/amdgpu_dm_visual_confirm

Bạn cần tải lại GUI của mình để xem xác nhận trực quan. Khi máy bay
thay đổi cấu hình hoặc cập nhật đầy đủ sẽ có một thanh màu ở
phần dưới cùng của mỗi mặt phẳng phần cứng được vẽ trên màn hình.

* Màu sắc biểu thị định dạng - Ví dụ: màu đỏ là AR24 và màu xanh lá cây là NV12
* Chiều cao của thanh biểu thị chỉ số của mặt phẳng
* Có thể quan sát thấy hiện tượng tách ống nếu có hai thanh có chiều cao chênh lệch
  bao phủ cùng một mặt phẳng

Hãy xem xét trường hợp phát lại video trong đó video được phát ở một vị trí cụ thể
mặt phẳng, và mặt bàn được vẽ trong một mặt phẳng khác. Mặt phẳng video nên
làm nổi bật một hoặc hai thanh màu xanh lục ở cuối video tùy thuộc vào đường ống
chia cấu hình.

* ZZ0000ZZ có thể bị hỏng hình ảnh
* ZZ0001ZZ có hiện tượng tràn nước hoặc nhấp nháy màn hình
* ZZ0002ZZ sẽ có màn hình đen
* ZZ0003ZZ có thể bị hỏng con trỏ
* Nhiều mặt phẳng ZZ0004ZZ bị vô hiệu hóa trong thời gian ngắn trong quá trình chuyển đổi cửa sổ hoặc
  thay đổi kích thước nhưng sẽ quay lại sau khi hành động kết thúc

Gỡ lỗi chia ống
----------------

Đôi khi chúng tôi cần gỡ lỗi xem DCN có chia ống chính xác không và
xác nhận cũng có ích cho trường hợp này. Tương tự như trường hợp MPO, bạn có thể sử dụng
lệnh dưới đây để kích hoạt xác nhận trực quan::

echo 1 > /sys/kernel/debug/dri/0/amdgpu_dm_visual_confirm

Trong trường hợp này, nếu bạn có phần chia ống, bạn sẽ thấy một thanh nhỏ màu đỏ ở
phần dưới cùng của màn hình bao phủ toàn bộ chiều rộng màn hình và một thanh khác
che ống thứ hai. Nói cách khác, bạn sẽ thấy thanh cao hơn một chút trong
ống thứ hai.

Gỡ lỗi DTN
=========

DC (DCN) cung cấp nhật ký mở rộng chứa nhiều chi tiết từ
cấu hình phần cứng. Thông qua debugfs, bạn có thể nắm bắt các giá trị trạng thái đó bằng cách
sử dụng nhật ký Display Test Next (DTN), có thể được ghi lại thông qua debugfs bằng cách sử dụng ::

mèo /sys/kernel/debug/dri/0/amdgpu_dm_dtn_log

Vì nhật ký này được cập nhật tương ứng với trạng thái DCN nên bạn cũng có thể làm theo
thay đổi theo thời gian thực bằng cách sử dụng cái gì đó như ::

sudo watch -d cat /sys/kernel/debug/dri/0/amdgpu_dm_dtn_log

Khi báo cáo lỗi liên quan đến DC, hãy cân nhắc việc đính kèm nhật ký này trước và
sau khi bạn tạo lại lỗi.

Thu thập thông tin phần mềm
============================

Khi báo cáo sự cố, điều quan trọng là phải có thông tin về phần sụn vì
nó có thể hữu ích cho mục đích gỡ lỗi. Để có được tất cả thông tin về phần sụn,
sử dụng lệnh::

mèo /sys/kernel/debug/dri/0/amdgpu_firmware_info

Từ góc độ hiển thị, hãy chú ý đến phần sụn của DMCU và
DMCUB.

Gỡ lỗi phần mềm DMUB
===================

Đôi khi, nhật ký dmesg là không đủ. Điều này đặc biệt đúng nếu một tính năng
được triển khai chủ yếu trong phần mềm DMUB. Trong những trường hợp như vậy, tất cả những gì chúng ta thấy trong dmesg khi
một vấn đề phát sinh là một số lỗi hết thời gian chờ chung. Vì vậy, để có được sự liên quan nhiều hơn
thông tin, chúng ta có thể theo dõi các lệnh DMUB bằng cách kích hoạt các bit có liên quan trong
ZZ0000ZZ.

Hiện tại, chúng tôi hỗ trợ truy tìm các nhóm sau:

Nhóm theo dõi
------------

.. csv-table::
   :header-rows: 1
   :widths: 1, 1
   :file: ./trace-groups-table.csv

ZZ0000ZZ

Vì vậy, để chỉ kích hoạt tính năng theo dõi PSR, bạn có thể sử dụng lệnh sau ::

# echo 0x8020 > /sys/kernel/debug/dri/0/amdgpu_dm_dmub_trace_mask

Sau đó, bạn cần kích hoạt tính năng ghi nhật ký các sự kiện theo dõi vào bộ đệm, việc này bạn có thể thực hiện
sử dụng như sau::

# echo 1 > /sys/kernel/debug/dri/0/amdgpu_dm_dmcub_trace_event_en

Cuối cùng, sau khi bạn có thể tái tạo lại sự cố mà bạn đang cố gắng gỡ lỗi,
bạn có thể tắt tính năng theo dõi và đọc nhật ký theo dõi bằng cách sử dụng cách sau::

# echo 0 > /sys/kernel/debug/dri/0/amdgpu_dm_dmcub_trace_event_en
  # cat/sys/kernel/debug/dri/0/amdgpu_dm_dmub_tracebuffer

Vì vậy, khi báo cáo lỗi liên quan đến các tính năng như PSR và ABM, hãy cân nhắc
kích hoạt các bit có liên quan trong mặt nạ trước khi tái tạo sự cố và
đính kèm nhật ký mà bạn thu được từ bộ đệm theo dõi trong bất kỳ báo cáo lỗi nào mà bạn
tạo ra.
