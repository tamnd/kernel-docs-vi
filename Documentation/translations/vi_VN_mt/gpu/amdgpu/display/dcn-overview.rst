.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/dcn-overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _dcn_overview:

==========================
Lõi hiển thị tiếp theo (DCN)
=======================

Nhằm trang bị cho độc giả những kiến thức cơ bản về cách AMD Display Core Next
(DCN) hoạt động, chúng ta cần bắt đầu với cái nhìn tổng quan về quy trình phần cứng. Dưới đây
bạn có thể xem hình ảnh cung cấp thông tin tổng quan về DCN, hãy nhớ rằng đây là
sơ đồ chung và chúng tôi có các biến thể cho mỗi ASIC.

.. kernel-figure:: dc_pipeline_overview.svg

Dựa vào sơ đồ này chúng ta có thể đi qua từng khối và mô tả ngắn gọn
họ:

* ZZ0000ZZ: Đây là cửa ngõ giữa Scalable
  Cổng dữ liệu (SDP) và DCN. Thành phần này có nhiều tính năng, chẳng hạn như bộ nhớ
  trọng tài, xoay và thao tác con trỏ.

* ZZ0000ZZ: Khối này cung cấp pixel trộn sẵn
  xử lý như chuyển đổi không gian màu, tuyến tính hóa dữ liệu pixel, tông màu
  ánh xạ và ánh xạ gam.

* ZZ0000ZZ: Thành phần này thực hiện việc trộn
  nhiều mặt phẳng, sử dụng alpha toàn cục hoặc alpha trên mỗi pixel.

* ZZ0000ZZ: Xử lý và định dạng pixel được gửi tới
  màn hình.

* ZZ0000ZZ: Nó tạo ra thời gian để kết hợp
  luồng hoặc phân chia khả năng. Các giá trị CRC được tạo trong khối này.

* ZZ0000ZZ: Mã hóa đầu ra cho màn hình được kết nối với
  GPU.

* ZZ0000ZZ: Nó cung cấp khả năng ghi đầu ra của
  ống hiển thị trở lại bộ nhớ dưới dạng khung hình video.

* ZZ0000ZZ: Giao diện bộ điều khiển bộ nhớ cho DMCUB và DWB
  (Lưu ý DWB chưa được hook).

* ZZ0000ZZ: Nó cung cấp các thanh ghi có khả năng kiểm soát truy cập và
  ngắt bộ điều khiển tới thiết bị ngắt máy chủ SOC. Khối này bao gồm
  Bộ vi điều khiển hiển thị - phiên bản B (DMCUB), được xử lý thông qua
  phần sụn.

* ZZ0000ZZ: Nó cung cấp đồng hồ và đặt lại
  cho tất cả các miền đồng hồ của bộ điều khiển hiển thị.

* ZZ0000ZZ: Công cụ âm thanh.

Sơ đồ trên là sự khái quát hóa kiến trúc của DCN, có nghĩa là
mọi ASIC đều có các biến thể xung quanh mẫu cơ bản này. Chú ý rằng màn hình hiển thị
đường ống được kết nối với Cổng dữ liệu có thể mở rộng (SDP) thông qua DCHUB; bạn có thể thấy
SDP là thành phần từ Cấu trúc dữ liệu của chúng tôi cung cấp đường ống hiển thị.

Luôn tiếp cận kiến trúc DCN như một thứ gì đó linh hoạt có thể
được cấu hình và cấu hình lại theo nhiều cách; nói cách khác, mỗi khối có thể
thiết lập hoặc bỏ qua tương ứng với nhu cầu không gian người dùng. Ví dụ, nếu chúng ta
muốn lái 8k@60Hz khi bật DSC, DCN của chúng tôi có thể yêu cầu 4 DPP và 2
OPP. Trách nhiệm của DC là đưa ra cấu hình tốt nhất cho từng
kịch bản cụ thể. Việc phối hợp tất cả các thành phần này lại với nhau đòi hỏi một
giao diện truyền thông phức tạp được làm nổi bật trong sơ đồ bởi
các cạnh kết nối từng khối; từ biểu đồ, mỗi kết nối giữa
các khối này đại diện cho:

1. Giao diện dữ liệu pixel (màu đỏ): Thể hiện luồng dữ liệu pixel;
2. Tín hiệu đồng bộ toàn cục (màu xanh): Là tập hợp các tín hiệu đồng bộ được cấu thành
   bởi VStartup, VUpdate và VReady;
3. Giao diện cấu hình: Chịu trách nhiệm cấu hình các khối;
4. Tín hiệu dải biên: Tất cả các tín hiệu khác không phù hợp với tín hiệu trước đó.

Những tín hiệu này rất cần thiết và đóng vai trò quan trọng trong DCN. Tuy nhiên,
Global Sync xứng đáng có thêm mức độ chi tiết được mô tả trong phần tiếp theo
phần.

Tất cả các thành phần này được biểu diễn bằng cấu trúc dữ liệu có tên dc_state.
Từ DCHUB đến MPC, chúng ta có biểu diễn được gọi là dc_plane; từ MPC đến OPTC,
chúng tôi có dc_stream và đầu ra (DIO) được xử lý bởi dc_link. Hãy ghi nhớ
HUBP truy cập vào một bề mặt bằng cách sử dụng định dạng cụ thể được đọc từ bộ nhớ và
dc_plane sẽ hoạt động để chuyển đổi tất cả các pixel trong mặt phẳng thành thứ có thể
được gửi đến màn hình thông qua dc_stream và dc_link.

Front End và Back End
----------------------

Đường dẫn hiển thị có thể được chia thành hai thành phần thường
được gọi là ZZ0000ZZ và ZZ0001ZZ, trong đó FE bao gồm:

* DCHUB (Chủ yếu đề cập đến một thành phần phụ có tên HUBP)
* DPP
* MPC

Mặt khác, BE bao gồm

* OPP
* OPTC
* DIO (Bộ mã hóa luồng và liên kết DP/HDMI)

OPP và OPTC là hai khối nối giữa FE và BE. Bên cạnh đó, đây là
ánh xạ một-một của bộ mã hóa liên kết tới PHY, nhưng chúng ta có thể định cấu hình DCN
để chọn bộ mã hóa liên kết nào để kết nối với PHY nào. FE chịu trách nhiệm chính
là thay đổi, pha trộn và tổng hợp dữ liệu pixel, trong khi công việc của BE là đóng khung một
luồng pixel chung đến luồng pixel của màn hình cụ thể.

Luồng dữ liệu
---------

Ban đầu, dữ liệu được truyền từ VRAM thông qua Data Fabric (DF) ở pixel gốc
các định dạng. Định dạng dữ liệu như vậy được duy trì cho đến HUBP trong DCHUB, nơi HUBP giải nén
định dạng pixel khác nhau và xuất chúng thành DPP theo các luồng thống nhất thông qua 4
kênh (1 cho alpha + 3 cho màu sắc).

Bộ chuyển đổi và con trỏ (CNVC) trong DPP sau đó sẽ chuẩn hóa dữ liệu
biểu diễn và chuyển đổi chúng sang định dạng dấu phẩy động cụ thể DCN (tức là
khác với định dạng dấu phẩy động IEEE). Trong quá trình này, CNVC cũng
áp dụng hàm degamma để chuyển đổi dữ liệu từ phi tuyến tính sang tuyến tính
không gian để thư giãn các phép tính dấu phẩy động sau đây. Dữ liệu sẽ ở lại
định dạng dấu phẩy động này từ DPP đến OPP.

Đang khởi động OPP, vì quá trình chuyển đổi và trộn màu đã hoàn tất
(tức là alpha có thể bị loại bỏ) và phần chìm cuối không yêu cầu độ chính xác và
phạm vi động mà các dấu phẩy động cung cấp (tức là tất cả các màn hình đều ở dạng số nguyên
định dạng độ sâu), việc giảm/phối màu độ sâu bit sẽ phát huy tác dụng. Trong OPP, chúng tôi sẽ
cũng áp dụng hàm regamma để giới thiệu lại gamma đã loại bỏ trước đó.
Cuối cùng, chúng tôi xuất dữ liệu ở định dạng số nguyên tại DIO.

Đường ống phần cứng AMD
---------------------

Khi thảo luận về đồ họa trên Linux, thuật ngữ ZZ0000ZZ đôi khi có thể được hiểu là
quá tải với nhiều ý nghĩa, vì vậy điều quan trọng là phải xác định ý nghĩa của chúng ta
khi chúng tôi nói ZZ0001ZZ. Trong trình điều khiển DCN, chúng tôi sử dụng thuật ngữ **phần cứng
pipe** or **pipeline** or just **pipe** dưới dạng trừu tượng để biểu thị một
chuỗi các khối DCN được khởi tạo để giải quyết một số cấu hình cụ thể. DC
lõi xử lý các khối DCN dưới dạng tài nguyên riêng lẻ, nghĩa là chúng ta có thể xây dựng một đường dẫn
bằng cách lấy tài nguyên cho tất cả các khối phần cứng riêng lẻ để tạo thành một đường dẫn.
Trong thực tế, chúng ta không thể kết nối một khối tùy ý từ một ống này tới một khối khác từ
một đường ống khác; chúng được định tuyến tuyến tính, ngoại trừ DSC, có thể
được phân công tùy ý khi cần thiết. Chúng tôi có khái niệm quy trình này để cố gắng
tối ưu hóa việc sử dụng băng thông.

.. kernel-figure:: pipeline_4k_no_split.svg

Ngoài ra, chúng ta hãy xem các phần của nhật ký DTN (xem
'Documentation/gpu/amdgpu/display/dc-debug.rst' để biết thêm thông tin) vì
nhật ký này có thể giúp chúng tôi xem một phần hoạt động của quy trình này trong thời gian thực::

HUBP: định dạng addr_hi chiều rộng chiều cao ...
 [0]: 8h 81h 3840 2160
 [1]: 0h 0h 0 0
 [ 2]: 0h 0h 0 0
 [ 3]: 0h 0h 0 0
 [ 4]: 0h 0h 0 0
 ...
MPCC: OPP DPP ...
 [0]: 0h 0h...

Điều đầu tiên cần chú ý từ sơ đồ và nhật ký DTN đó là thực tế là chúng ta
có các miền đồng hồ khác nhau cho từng phần của khối DCN. Trong ví dụ này,
chúng ta chỉ có một ZZ0000ZZ duy nhất trong đó dữ liệu truyền từ DCHUB đến DIO, như
chúng ta mong đợi bằng trực giác. Tuy nhiên, DCN rất linh hoạt, như đã đề cập trước đó và
chúng ta có thể phân chia đường ống đơn này theo cách khác, như được mô tả trong sơ đồ bên dưới:

.. kernel-figure:: pipeline_4k_split.svg

Bây giờ, nếu kiểm tra lại nhật ký DTN, chúng ta có thể thấy một số thay đổi thú vị ::

HUBP: định dạng addr_hi chiều rộng chiều cao ...
 [ 0]: 8h 81h 1920 2160 ...
 ...
[4]: 0h 0h 0 0 ...
 [ 5]: 8h 81h 1920 2160 ...
 ...
MPCC: OPP DPP ...
 [0]: 0h 0h...
 [ 5]: 0h 5h ...

Từ ví dụ trên, giờ đây chúng tôi chia quy trình hiển thị thành hai phần dọc
các phần của 1920x2160 (tức là 3440x2160) và kết quả là chúng tôi có thể giảm
tần số xung nhịp trong phần DPP. Điều này không chỉ hữu ích trong việc tiết kiệm điện mà còn
cũng để xử lý tốt hơn thông lượng cần thiết. Ý tưởng cần ghi nhớ ở đây là
cấu hình đường ống có thể thay đổi rất nhiều tùy theo màn hình
cấu hình và DML có trách nhiệm thiết lập tất cả các yêu cầu
tham số cấu hình cho nhiều tình huống được phần cứng của chúng tôi hỗ trợ.

Đồng bộ hóa toàn cầu
-----------

Nhiều thanh ghi DCN được đệm đôi, quan trọng nhất là địa chỉ bề mặt.
Điều này cho phép chúng tôi cập nhật phần cứng DCN một cách nguyên tử để lật trang, cũng như
đối với hầu hết các bản cập nhật khác không yêu cầu bật hoặc tắt các đường ống mới.

(Lưu ý: Có nhiều trường hợp DC quyết định dự trữ thêm đường ống
để hỗ trợ các đầu ra cần xung nhịp pixel rất cao hoặc để
mục đích tiết kiệm điện.)

Các cập nhật đăng ký nguyên tử này được điều khiển bởi tín hiệu đồng bộ hóa toàn cầu trong DCN. trong
để hiểu cách các bản cập nhật nguyên tử tương tác với phần cứng DCN và cách DCN
tín hiệu sự kiện lật trang và vblank sẽ rất hữu ích khi hiểu cách đồng bộ hóa toàn cầu
được lập trình.

Đồng bộ hóa toàn cầu bao gồm ba tín hiệu VSTARTUP, VUPDATE và VREADY. Đây là
được tính toán bởi Thư viện Chế độ Hiển thị - DML (drivers/gpu/drm/amd/display/dc/dml)
dựa trên một số lượng lớn các tham số và đảm bảo phần cứng của chúng tôi có thể cung cấp
đường ống DCN không bị tràn hoặc bị treo trong bất kỳ cấu hình hệ thống nhất định nào.
Các tín hiệu đồng bộ toàn cầu luôn diễn ra trong VBlank, độc lập với
Tín hiệu VSync và không chồng chéo lên nhau.

VUPDATE là tín hiệu duy nhất được phần còn lại của ngăn xếp trình điều khiển quan tâm
hoặc máy khách không gian người dùng vì nó báo hiệu thời điểm phần cứng bám vào
các thanh ghi được lập trình nguyên tử (tức là được đệm đôi). Mặc dù nó là
độc lập với tín hiệu VSync, chúng tôi sử dụng VUPDATE để báo hiệu sự kiện VSync vì nó
cung cấp dấu hiệu tốt nhất về cách tương tác giữa các cam kết nguyên tử và phần cứng.

Vì phần cứng DCN được đệm đôi nên trình điều khiển DC có thể lập trình
phần cứng tại bất kỳ điểm nào trong khung.

Hình ảnh dưới đây minh họa các tín hiệu đồng bộ hóa toàn cầu:

.. kernel-figure:: global_sync_vblank.svg

Những tín hiệu này ảnh hưởng đến hành vi cốt lõi của DCN. Lập trình chúng không chính xác sẽ dẫn đến
đến một số hậu quả tiêu cực, hầu hết đều khá thảm khốc.

Hình ảnh sau đây cho thấy cách đồng bộ hóa toàn cầu cho phép kiểu hộp thư
cập nhật, tức là nó cho phép nhiều cấu hình lại giữa VUpdate
các sự kiện trong đó chỉ có cấu hình cuối cùng được lập trình trước tín hiệu VUpdate
trở nên có hiệu lực.

.. kernel-figure:: config_example.svg
