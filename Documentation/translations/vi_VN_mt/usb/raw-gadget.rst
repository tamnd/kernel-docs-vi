.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/raw-gadget.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================
Tiện ích thô USB
==============

USB Raw Gadget là trình điều khiển tiện ích cung cấp cho không gian người dùng quyền kiểm soát cấp thấp đối với
quá trình giao tiếp của tiện ích.

Giống như bất kỳ trình điều khiển tiện ích nào khác, Raw Gadget triển khai các thiết bị USB thông qua
USB tiện ích API. Không giống như hầu hết các trình điều khiển tiện ích, Raw Gadget không triển khai
mọi USB cụ thể đều tự hoạt động nhưng yêu cầu không gian người dùng để thực hiện điều đó.

Tiện ích thô hiện là tính năng gỡ lỗi nghiêm ngặt và không nên sử dụng
trong sản xuất. Thay vào đó hãy sử dụng GadgetFS.

Kích hoạt với CONFIG_USB_RAW_GADGET.

So sánh với GadgetFS
~~~~~~~~~~~~~~~~~~~~~~

Tiện ích thô tương tự như GadgetFS nhưng cung cấp nhiều quyền truy cập trực tiếp hơn vào
Lớp tiện ích USB cho không gian người dùng. Sự khác biệt chính là:

1. Tiện ích thô chuyển mọi yêu cầu USB tới không gian người dùng để nhận phản hồi, đồng thời
   GadgetFS phản hồi một số yêu cầu USB nội bộ dựa trên yêu cầu được cung cấp
   những người mô tả. Lưu ý rằng trình điều khiển UDC có thể đáp ứng một số yêu cầu trên
   của riêng nó và không bao giờ chuyển tiếp chúng đến lớp tiện ích.

2. Tiện ích thô cho phép cung cấp dữ liệu tùy ý dưới dạng phản hồi cho các yêu cầu USB,
   trong khi GadgetFS thực hiện kiểm tra độ chính xác trên các bộ mô tả USB được cung cấp.
   Điều này làm cho Tiện ích thô phù hợp với việc làm mờ bằng cách cung cấp dữ liệu không đúng định dạng dưới dạng
   phản hồi các yêu cầu USB.

3. Tiện ích thô cung cấp cách chọn thiết bị/trình điều khiển UDC để liên kết,
   trong khi GadgetFS hiện liên kết với UDC có sẵn đầu tiên. Điều này cho phép
   có nhiều phiên bản Tiện ích thô được liên kết với các UDC khác nhau.

4. Tiện ích thô hiển thị rõ ràng thông tin về địa chỉ điểm cuối và
   khả năng. Điều này cho phép người dùng viết các tiện ích bất khả tri UDC.

5. Tiện ích thô có giao diện dựa trên ioctl thay vì dựa trên hệ thống tệp
   một.

Giao diện không gian người dùng
~~~~~~~~~~~~~~~~~~~

Người dùng có thể tương tác với Raw Gadget bằng cách mở ZZ0000ZZ và
phát hành cuộc gọi ioctl; xem các nhận xét trong include/uapi/linux/usb/raw_gadget.h
để biết chi tiết. Nhiều phiên bản Tiện ích thô (được liên kết với các UDC khác nhau) có thể được
được sử dụng cùng một lúc.

Kịch bản sử dụng điển hình của Raw Gadget:

1. Tạo một phiên bản Tiện ích thô bằng cách mở ZZ0000ZZ.
2. Khởi tạo phiên bản thông qua ZZ0001ZZ.
3. Khởi chạy phiên bản với ZZ0002ZZ.
4. Trong vòng lặp phát hành ZZ0003ZZ để nhận các sự kiện từ
   Tiện ích thô và phản ứng với những tiện ích đó tùy thuộc vào loại tiện ích USB phải
   được thực hiện.

Lưu ý rằng một số trình điều khiển UDC có địa chỉ cố định được gán cho điểm cuối và
do đó, địa chỉ điểm cuối tùy ý không thể được sử dụng trong bộ mô tả.
Tuy nhiên, Raw Gadget cung cấp một cách không thể tin được UDC để viết các tiện ích USB.
Sau khi nhận được ZZ0000ZZ qua ZZ0001ZZ,
ZZ0002ZZ có thể được sử dụng để tìm hiểu thông tin về
điểm cuối mà trình điều khiển UDC có. Dựa vào đó, không gian người dùng phải chọn UDC
điểm cuối cho tiện ích và gán địa chỉ trong phần mô tả điểm cuối
tương ứng.

Ví dụ về cách sử dụng Tiện ích thô và bộ thử nghiệm:

ZZ0000ZZ

Chi tiết nội bộ
~~~~~~~~~~~~~~~~

Mọi điểm cuối đọc/ghi ioctl của Tiện ích thô đều gửi yêu cầu USB và chờ
cho đến khi nó hoàn thành. Điều này được thực hiện có chủ ý để hỗ trợ việc đưa tin theo hướng dẫn
làm mờ bằng cách có một tòa nhà cao tầng duy nhất xử lý đầy đủ một yêu cầu USB. Cái này
tính năng phải được giữ trong việc thực hiện.

Những cải tiến tiềm năng trong tương lai
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

- Hỗ trợ I/O ZZ0000ZZ. Đây sẽ là một phương thức hoạt động khác, trong đó
  Tiện ích thô sẽ không đợi cho đến khi hoàn thành từng yêu cầu USB.

- Hỗ trợ các tính năng USB 3 (chấp nhận bộ mô tả đồng hành điểm cuối SS khi
  kích hoạt điểm cuối; cho phép cung cấp ZZ0000ZZ để chuyển số lượng lớn).

- Hỗ trợ các tính năng chuyển ISO (hiển thị ZZ0000ZZ để hoàn thành
  yêu cầu).
