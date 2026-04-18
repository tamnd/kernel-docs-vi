.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/networking/device_drivers/fddi/defza.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================================
Những lưu ý về trình điều khiển DEC FDDIcontroller 700 (DEFZA-xx)
=====================================================

:Phiên bản: v.1.1.4


Bộ điều khiển FDDI DEC 700 là kênh TURBO thế hệ đầu tiên của DEC FDDI
card mạng, được thiết kế năm 1990 dành riêng cho DECstation 5000
máy trạm model 200  Bảng mạch là một trạm đính kèm duy nhất và
nó được sản xuất thành hai biến thể, cả hai đều được hỗ trợ.

Đầu tiên là tùy chọn SAS MMF DEFZA-AA, thiết kế ban đầu triển khai
MMF-PMD tiêu chuẩn, tuy nhiên có một cặp đầu nối ST thay vì
đầu nối MIC thông thường.  Cái còn lại là SAS ThinWire/STP DEFZA-CA
tùy chọn, ký hiệu là 700-C, với phương tiện mạng có thể được lựa chọn bằng một công tắc
giữa ThinWire-PMD độc quyền của DEC sử dụng đầu nối BNC và
tiêu chuẩn STP-PMD sử dụng đầu nối DE-9F.  Tùy chọn này có thể giao tiếp với
một thiết bị DECconcentrator 500 và, trong trường hợp STP-PMD, cả các thiết bị khác
Thiết bị FDDI và được thiết kế để giúp chuyển đổi từ
Mạng Token Ring IEEE 802.3 10BASE2 hiện có và IEEE 802.5
bằng cách cung cấp phương tiện để tái sử dụng hệ thống cáp hiện có.

Trình điều khiển này xử lý bất kỳ số lượng thẻ nào được cài đặt trong một hệ thống.
Họ nhận được tên giao diện fddi0, fddi1, v.v. được gán theo thứ tự
tăng số lượng khe cắm kênh TURBO.

Bo mạch chỉ hỗ trợ DMA ở phía nhận.  Việc truyền tải bao gồm
việc sử dụng PIO.  Kết quả là dưới tải truyền tải lớn sẽ có
có tác động đáng kể đến hiệu suất của hệ thống.

Bảng mạch hỗ trợ CAM 64 mục để khớp địa chỉ đích.
Hai mục đang được định hướng bởi Beacon và Ring Purger
địa chỉ multicast và phần còn lại được sử dụng làm bộ lọc multicast.  Một
Chế độ all-multi cũng được hỗ trợ cho các khung LLC và được sử dụng nếu
được yêu cầu rõ ràng hoặc nếu CAM tràn.  Chế độ lăng nhăng
hỗ trợ kích hoạt riêng biệt cho các khung LLC và SMT, nhưng trình điều khiển này
không hỗ trợ thay đổi chúng riêng lẻ.


Các vấn đề đã biết:

Không có.


Để làm:

5. Thay đổi địa chỉ MAC.  Thẻ không hỗ trợ thay đổi Media
   Các thanh ghi địa chỉ của Bộ điều khiển truy cập nhưng có thể có tác dụng tương tự
   đạt được bằng cách thêm bí danh vào CAM.  Không có cách nào để vô hiệu hóa
   mặc dù phù hợp với địa chỉ ban đầu.

7. Xếp hàng các khung SMT đến/đi trong trình điều khiển nếu SMT
   vòng nhận/RMC truyền đã đầy. (?)

8. Truy xuất/báo cáo số liệu thống kê FDDI/SNMP.


Cả hai báo cáo thành công và thất bại đều được chào đón.

Maciej W. Rozycki <macro@orcam.me.uk>