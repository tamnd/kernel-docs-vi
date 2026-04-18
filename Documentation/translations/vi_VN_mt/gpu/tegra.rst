.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/tegra.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
 drm/tegra NVIDIA Tegra GPU và trình điều khiển hiển thị
========================================================

NVIDIA Tegra SoC hỗ trợ một bộ chức năng hiển thị, đồ họa và video thông qua
bộ điều khiển Host1x. Host1x cung cấp các luồng lệnh, được thu thập từ một lần đẩy
bộ đệm được CPU cung cấp trực tiếp cho khách hàng thông qua các kênh. phần mềm,
hoặc các khối với nhau, có thể sử dụng các điểm đồng bộ để đồng bộ hóa.

Cho đến, nhưng không bao gồm, Tegra124 (hay còn gọi là Tegra K1), trình điều khiển drm/tegra
hỗ trợ GPU tích hợp, bao gồm các động cơ gr2d và gr3d. Bắt đầu
với Tegra124, GPU dựa trên kiến trúc máy tính để bàn NVIDIA GPU và
được hỗ trợ bởi trình điều khiển drm/nouveau.

Trình điều khiển drm/tegra hỗ trợ các thế hệ NVIDIA Tegra SoC kể từ Tegra20. Nó
có ba phần:

- Trình điều khiển Host1x cung cấp cơ sở hạ tầng và quyền truy cập vào Host1x
    dịch vụ.

- Trình điều khiển KMS hỗ trợ bộ điều khiển hiển thị cũng như một số
    đầu ra, chẳng hạn như RGB, HDMI, DSI và DisplayPort.

- Một tập hợp các IOCTL không gian người dùng tùy chỉnh có thể được sử dụng để gửi công việc tới
    GPU và công cụ video thông qua Host1x.

Cơ sở hạ tầng trình điều khiển
=====================

Các máy khách Host1x khác nhau cần được liên kết với nhau thành một thiết bị logic trong
để giới thiệu chức năng của chúng tới người dùng. Cơ sở hạ tầng hỗ trợ
điều này được thực hiện trong trình điều khiển Host1x. Khi người lái xe đã đăng ký với
cơ sở hạ tầng, nó cung cấp danh sách các chuỗi tương thích chỉ định các thiết bị
mà nó cần. Cơ sở hạ tầng tạo ra một thiết bị logic và quét thiết bị
cây để khớp các nút thiết bị, thêm các máy khách cần thiết vào danh sách. Trình điều khiển
đối với khách hàng cá nhân cũng đăng ký với cơ sở hạ tầng và được thêm vào
đến thiết bị Host1x logic.

Khi tất cả các máy khách đều sẵn sàng, cơ sở hạ tầng sẽ khởi tạo logic
thiết bị sử dụng chức năng do trình điều khiển cung cấp sẽ thiết lập các bit cụ thể cho
hệ thống con và lần lượt khởi tạo từng máy khách của nó.

Tương tự, khi một trong các khách hàng chưa đăng ký, cơ sở hạ tầng sẽ
phá hủy thiết bị logic bằng cách gọi lại trình điều khiển, điều này đảm bảo rằng
các bit cụ thể của hệ thống con bị phá bỏ và lần lượt các máy khách bị phá hủy.

Tham khảo cơ sở hạ tầng Host1x
-------------------------------

.. kernel-doc:: include/linux/host1x.h

.. kernel-doc:: drivers/gpu/host1x/bus.c
   :export:

Tham khảo điểm đồng bộ Host1x
--------------------------

.. kernel-doc:: drivers/gpu/host1x/syncpt.c
   :export:

Trình điều khiển KMS
==========

Phần cứng hiển thị hầu như vẫn tương thích ngược trên nhiều thiết bị khác nhau.
Các thế hệ Tegra SoC, cho đến Tegra186 đã giới thiệu một số thay đổi
gây khó khăn cho việc hỗ trợ với trình điều khiển được tham số hóa.

Bộ điều khiển hiển thị
-------------------

Tegra SoC có hai bộ điều khiển hiển thị, mỗi bộ điều khiển có thể được liên kết với
bằng không hoặc nhiều đầu ra. Đầu ra cũng có thể chia sẻ một bộ điều khiển hiển thị duy nhất, nhưng
chỉ khi chúng chạy với thời gian hiển thị tương thích. Hai bộ điều khiển hiển thị có thể
cũng chia sẻ một bộ đệm khung duy nhất, cho phép cấu hình nhân bản ngay cả khi các chế độ
trên hai đầu ra không khớp. Bộ điều khiển hiển thị được mô hình hóa dưới dạng CRTC trong KMS
điều khoản.

Trên Tegra186, số lượng bộ điều khiển hiển thị đã được tăng lên ba. A
bộ điều khiển hiển thị không còn có thể điều khiển tất cả các đầu ra. Trong khi hai trong số này
bộ điều khiển có thể điều khiển cả đầu ra DSI và cả đầu ra SOR, bộ điều khiển thứ ba không thể
lái bất kỳ chiếc DSI nào.

cửa sổ
~~~~~~~

Bộ điều khiển hiển thị điều khiển một tập hợp các cửa sổ có thể được sử dụng để tổng hợp
nhiều bộ đệm lên màn hình. Mặc dù có thể gán Z tùy ý
sắp xếp theo từng cửa sổ riêng lẻ (bằng cách lập trình quá trình trộn tương ứng
registers), điều này hiện không được trình điều khiển hỗ trợ. Thay vào đó, nó sẽ
giả sử thứ tự Z cố định của các cửa sổ (cửa sổ A là cửa sổ gốc, đó là
là mức thấp nhất, trong khi cửa sổ B và C được phủ lên trên cửa sổ A). các
cửa sổ lớp phủ hỗ trợ nhiều định dạng pixel và có thể tự động chuyển đổi
từ YUV đến RGB tại thời điểm quét. Điều này làm cho chúng hữu ích cho việc hiển thị video
nội dung. Trong KMS, mỗi cửa sổ được mô hình hóa như một mặt phẳng. Mỗi bộ điều khiển hiển thị
có một con trỏ phần cứng được hiển thị dưới dạng mặt phẳng con trỏ.

đầu ra
-------

Loại và số lượng đầu ra được hỗ trợ khác nhau giữa các thế hệ Tegra SoC.
Tất cả các thế hệ đều hỗ trợ ít nhất HDMI. Trong khi các thế hệ trước ủng hộ
giao diện RGB rất đơn giản (một giao diện cho mỗi bộ điều khiển hiển thị), các thế hệ gần đây không có
còn làm được nữa và thay vào đó cung cấp các giao diện tiêu chuẩn như DSI và eDP/DP.

Các đầu ra được mô hình hóa dưới dạng cặp bộ mã hóa/đầu nối tổng hợp.

RGB/LVDS
~~~~~~~~

Giao diện này không còn khả dụng kể từ Tegra124. Nó đã được thay thế bởi
giao diện DSI và eDP tiêu chuẩn hơn.

HDMI
~~~~

HDMI được hỗ trợ trên tất cả các SoC Tegra. Bắt đầu với Tegra210, HDMI được cung cấp
bởi đầu ra SOR linh hoạt, hỗ trợ eDP, DP và HDMI. SOR có thể
để hỗ trợ HDMI 2.0, mặc dù hỗ trợ cho điều này hiện chưa được hợp nhất.

DSI
~~~

Mặc dù Tegra đã hỗ trợ DSI kể từ Tegra30, bộ điều khiển đã thay đổi trong
một số cách trong Tegra114. Vì không có sự phát triển nào có sẵn công khai
các bo mạch trước Dalmore (Tegra114) đã sử dụng DSI, chỉ Tegra114 và
sau này được hỗ trợ bởi trình điều khiển drm/tegra.

eDP/DP
~~~~~~

eDP lần đầu tiên được giới thiệu trong Tegra124, nơi nó được sử dụng để điều khiển màn hình
bảng điều khiển cho các yếu tố hình thức máy tính xách tay. Tegra210 đã thêm hỗ trợ cho DisplayPort đầy đủ
hỗ trợ, mặc dù điều này hiện không được triển khai trong trình điều khiển drm/tegra.

Giao diện không gian người dùng
===================

Giao diện không gian người dùng được cung cấp bởi drm/tegra cho phép các ứng dụng tạo
Bộ đệm GEM, truy cập và kiểm soát các điểm đồng bộ cũng như gửi luồng lệnh
tới máy chủ1x.

Bộ đệm GEM
-----------

ZZ0000ZZ IOCTL được sử dụng để tạo đối tượng bộ đệm GEM
với các cờ dành riêng cho Tegra. Điều này rất hữu ích cho các bộ đệm cần được xếp lớp hoặc
sẽ được quét lộn ngược (hữu ích cho nội dung 3D).

Sau khi đối tượng bộ đệm GEM được tạo, bộ nhớ của nó có thể được ánh xạ bởi một
ứng dụng sử dụng phần bù mmap được trả về bởi ZZ0000ZZ
IOCTL.

Điểm đồng bộ
----------

Giá trị hiện tại của một điểm đồng bộ có thể thu được bằng cách thực hiện lệnh
ZZ0000ZZ IOCTL. Tăng điểm đồng bộ đạt được
sử dụng ZZ0001ZZ IOCTL.

Không gian người dùng cũng có thể yêu cầu chặn trên một điểm đồng bộ hóa. Để làm được như vậy, cần phải
thực thi ZZ0000ZZ IOCTL, chỉ định giá trị của
điểm đồng bộ để chờ đợi. Hạt nhân sẽ giải phóng ứng dụng khi
điểm đồng bộ đạt đến giá trị đó hoặc sau một khoảng thời gian chờ được chỉ định.

Gửi dòng lệnh
-------------------------

Trước khi một ứng dụng có thể gửi các luồng lệnh tới hosting1x, nó cần mở một
kênh tới động cơ sử dụng ZZ0000ZZ IOCTL. khách hàng
ID được sử dụng để xác định mục tiêu của kênh. Khi một kênh không có
cần thiết lâu hơn, nó có thể được đóng lại bằng ZZ0001ZZ
IOCTL. Để truy xuất điểm đồng bộ được liên kết với một kênh, một ứng dụng
có thể sử dụng ZZ0002ZZ.

Sau khi mở một kênh, việc gửi luồng lệnh thật dễ dàng. ứng dụng
ghi các lệnh vào bộ nhớ sao lưu đối tượng bộ đệm GEM và chuyển chúng
đến ZZ0000ZZ IOCTL cùng với nhiều thông số khác,
chẳng hạn như các điểm đồng bộ hoặc các vị trí tái định vị được sử dụng trong quá trình gửi công việc.
