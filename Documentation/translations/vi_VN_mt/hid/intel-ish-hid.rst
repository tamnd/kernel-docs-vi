.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/intel-ish-hid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Trung tâm cảm biến tích hợp Intel (ISH)
=================================

Một trung tâm cảm biến cho phép khả năng giảm tải việc thăm dò cảm biến và thuật toán
xử lý sang bộ đồng xử lý chuyên dụng có công suất thấp. Điều này cho phép lõi
bộ xử lý chuyển sang chế độ năng lượng thấp thường xuyên hơn, dẫn đến tăng
tuổi thọ pin.

Có nhiều nhà cung cấp cung cấp trung tâm cảm biến bên ngoài phù hợp với HID
Bảng sử dụng cảm biến Những thứ này có thể được tìm thấy trong máy tính bảng, máy tính xách tay chuyển đổi 2 trong 1
và các sản phẩm nhúng. Linux đã có hỗ trợ này kể từ Linux 3.9.

Intel® đã giới thiệu các trung tâm cảm biến tích hợp như một phần của SoC bắt đầu từ
Cherry Trail và hiện được hỗ trợ trên nhiều thế hệ gói CPU. Ở đó
rất nhiều thiết bị thương mại đã được xuất xưởng với Trung tâm cảm biến tích hợp (ISH).
Các ISH này cũng tuân thủ thông số kỹ thuật của cảm biến HID, nhưng điểm khác biệt là
giao thức vận chuyển được sử dụng để liên lạc. Các trung tâm cảm biến bên ngoài hiện tại
chủ yếu sử dụng HID thay vì I2C hoặc USB. Nhưng ISH không sử dụng I2C hoặc USB.

Tổng quan
========

Sử dụng sự tương tự với việc triển khai usbhid, ISH tuân theo một mô hình tương tự
để liên lạc tốc độ rất cao::

--------------------------------------
	ZZ0000ZZ --> ZZ0001ZZ
	--------------------------------------
	--------------------------------------
	ZZ0002ZZ --> ZZ0003ZZ
	--------------------------------------
	--------------------------------------
	ZZ0004ZZ --> ZZ0005ZZ
	--------------------------------------
	      PCI PCI
	--------------------------------------
	ZZ0006ZZ --> ZZ0007ZZ
	--------------------------------------
	     Liên kết USB
	--------------------------------------
	ZZ0008ZZ --> ZZ0009ZZ
	--------------------------------------

Giống như giao thức USB cung cấp phương thức liệt kê thiết bị, quản lý liên kết
và đóng gói dữ liệu người dùng, ISH cũng cung cấp các dịch vụ tương tự. Nhưng nó là
trọng lượng rất nhẹ được thiết kế để quản lý và liên lạc với khách hàng ISH
các ứng dụng được triển khai trong phần sụn.

ISH cho phép thực thi nhiều ứng dụng quản lý cảm biến trong
phần sụn. Giống như điểm cuối USB, tin nhắn có thể đến/từ máy khách. Là một phần của
quá trình liệt kê, những khách hàng này được xác định. Những khách hàng này có thể đơn giản
Ứng dụng cảm biến HID, ứng dụng hiệu chỉnh cảm biến hoặc phần mềm cảm biến
cập nhật ứng dụng.

Mô hình triển khai tương tự, giống như bus USB, vận chuyển ISH cũng
thực hiện như một chiếc xe buýt. Mỗi ứng dụng khách thực thi trong bộ xử lý ISH
được đăng ký như một thiết bị trên xe buýt này. Trình điều khiển liên kết từng thiết bị
(Trình điều khiển ISH HID) xác định loại thiết bị và đăng ký với lõi HID.

Triển khai ISH: Sơ đồ khối
=================================

::

--------------------------
	ZZ0000ZZ
	 --------------------------

----------------IIO ABI----------------
	 -----------------
	ZZ0000ZZ
	 -----------------
	 -----------------
	ZZ0001ZZ
	 -----------------
	 -----------------
	ZZ0002ZZ
	 -----------------
	 -----------------
	ZZ0003ZZ
	 -----------------
	 -----------------
	ZZ0004ZZ
	 -----------------
	 -----------------
	ZZ0005ZZ
	 -----------------
	 -----------------
	ZZ0006ZZ
	 -----------------
  hệ điều hành
  ---------------- PCI -----------------
  Phần cứng + Phần sụn
	 ----------------------------
	ZZ0007ZZ
	 ----------------------------

Xử lý cấp cao trong các khối trên
=====================================

Giao diện phần cứng
------------------

ISH được hiển thị dưới dạng "thiết bị PCI không phải VGA chưa được phân loại" đối với máy chủ. PCI
ID sản phẩm và nhà cung cấp được thay đổi từ các thế hệ bộ xử lý khác nhau. Vì vậy
mã nguồn liệt kê các trình điều khiển cần cập nhật từ thế hệ này sang thế hệ khác
thế hệ.

Trình điều khiển Giao tiếp Bộ xử lý Liên bộ (IPC)
------------------------------------------

Vị trí: trình điều khiển/hid/intel-ish-hid/ipc

Thông báo IPC sử dụng I/O được ánh xạ bộ nhớ. Các thanh ghi được xác định trong
hw-ish-regs.h.

Các loại thông báo IPC/FW
^^^^^^^^^^^^^^^^^^^^

Có hai loại tin nhắn, một loại để quản lý liên kết và một loại khác để quản lý liên kết.
các thông điệp đến và đi từ các lớp vận chuyển.

TX và RX của bản tin Transport
...............................

Một tập hợp các thanh ghi ánh xạ bộ nhớ hỗ trợ các thông điệp nhiều byte TX và
RX (ví dụ: IPC_REG_ISH2HOST_MSG, IPC_REG_HOST2ISH_MSG). Lớp IPC duy trì
hàng đợi nội bộ để sắp xếp các tin nhắn và gửi chúng theo thứ tự đến phần sụn.
Tùy chọn người gọi có thể đăng ký trình xử lý để nhận thông báo hoàn thành.
Cơ chế chuông cửa được sử dụng trong việc nhắn tin để kích hoạt quá trình xử lý trong máy chủ và
phía phần sụn của máy khách. Khi trình xử lý ngắt ISH được gọi, ISH2HOST
thanh ghi chuông cửa được trình điều khiển máy chủ sử dụng để xác định rằng ngắt
dành cho ISH.

Mỗi bên có 32 thanh ghi tin nhắn 32 bit và chuông cửa 32 bit. Chuông cửa
đăng ký có định dạng sau::

Bit 0..6: độ dài đoạn (7 bit được sử dụng)
  Bit 10..13: giao thức được đóng gói
  Bit 16..19: lệnh quản lý (đối với giao thức quản lý IPC)
  Bit 31: kích hoạt chuông cửa (tín hiệu ngắt H/W sang phía bên kia)
  Các bit khác được dành riêng, phải bằng 0.

Giao diện lớp vận chuyển
^^^^^^^^^^^^^^^^^^^^^^^^^

Để trừu tượng hóa giao tiếp IPC ở cấp độ CTNH, một tập hợp các lệnh gọi lại được đăng ký.
Lớp vận chuyển sử dụng chúng để gửi và nhận tin nhắn.
Tham khảo struct ishtp_hw_ops để biết các lệnh gọi lại.

Lớp vận chuyển ISH
-------------------

Vị trí: trình điều khiển/hid/intel-ish-hid/ishtp/

Lớp vận chuyển chung
^^^^^^^^^^^^^^^^^^^^^^^^^

Lớp vận chuyển là một giao thức hai chiều, xác định:
- Đặt lệnh khởi động, dừng, kết nối, ngắt kết nối và điều khiển luồng
(xem ishtp/hbm.h để biết chi tiết)
- Cơ chế kiểm soát luồng để tránh tràn bộ đệm

Giao thức này giống với các thông báo bus được mô tả trong tài liệu sau:
ZZ0000ZZ
"Chương 7: Lớp thông báo xe buýt".

Cơ chế kết nối và kiểm soát luồng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Mỗi máy khách FW và một giao thức được xác định bởi UUID. Để giao tiếp
đối với máy khách FW, kết nối phải được thiết lập bằng yêu cầu kết nối và
tin nhắn xe buýt phản hồi. Nếu thành công, một cặp (host_client_id và fw_client_id)
sẽ xác định kết nối.

Sau khi kết nối được thiết lập, các đồng nghiệp sẽ gửi cho nhau các thông báo bus điều khiển luồng
một cách độc lập. Mỗi máy ngang hàng chỉ có thể gửi tin nhắn nếu nó đã nhận được một
tín dụng kiểm soát dòng chảy trước đây. Một khi nó đã gửi một tin nhắn, nó có thể không gửi một tin nhắn khác
trước khi nhận được tín dụng kiểm soát luồng tiếp theo.
Một trong hai bên có thể gửi tin nhắn bus yêu cầu ngắt kết nối để kết thúc liên lạc. Ngoài ra
liên kết sẽ bị hủy nếu việc thiết lập lại FW lớn xảy ra.

Truyền dữ liệu ngang hàng
^^^^^^^^^^^^^^^^^^^^^^^^^^

Truyền dữ liệu ngang hàng có thể xảy ra khi có hoặc không sử dụng DMA. Tùy thuộc vào
yêu cầu băng thông cảm biến DMA có thể được kích hoạt bằng cách sử dụng tham số mô-đun
ishtp_use_dma trong intel_ishtp.

Mỗi bên (máy chủ và FW) quản lý bộ nhớ truyền DMA của mình một cách độc lập. Khi một
Máy khách ISHTP từ phía máy chủ hoặc phía FW muốn gửi thứ gì đó, nó sẽ quyết định
gửi qua IPC hay qua DMA; đối với mỗi lần chuyển nhượng, quyết định là
độc lập. Bên gửi gửi tin nhắn DMA_XFER khi tin nhắn được gửi
bộ đệm máy chủ tương ứng (TX khi máy khách gửi, RX khi máy khách FW
gửi). Người nhận tin nhắn DMA phản hồi bằng DMA_XFER_ACK, cho biết
người gửi rằng vùng bộ nhớ dành cho tin nhắn đó có thể được sử dụng lại.

Quá trình khởi tạo DMA được bắt đầu bằng việc máy chủ gửi tin nhắn bus DMA_ALLOC_NOTIFY
(bao gồm bộ đệm RX) và FW phản hồi bằng DMA_ALLOC_NOTIFY_ACK.
Ngoài giao tiếp địa chỉ DMA, trình tự này còn kiểm tra các khả năng:
nếu máy chủ không hỗ trợ DMA thì nó sẽ không gửi phân bổ DMA, vì vậy FW không thể
gửi DMA; nếu FW không hỗ trợ DMA thì nó sẽ không phản hồi
DMA_ALLOC_NOTIFY_ACK, trong trường hợp đó máy chủ sẽ không sử dụng chuyển DMA.
Ở đây ISH đóng vai trò là bộ điều khiển busmaster DMA. Do đó khi máy chủ gửi DMA_XFER,
đó là yêu cầu thực hiện chuyển máy chủ->ISH DMA; khi FW gửi DMA_XFER, điều đó có nghĩa là
rằng nó đã thực hiện DMA và thông báo nằm ở máy chủ. Vì vậy, DMA_XFER
và DMA_XFER_ACK đóng vai trò là chỉ báo quyền sở hữu.

Ở trạng thái ban đầu, tất cả bộ nhớ gửi đi đều thuộc về người gửi (TX đến máy chủ, RX đến
FW), DMA_XFER chuyển quyền sở hữu vùng chứa thông báo ISHTP cho
bên nhận, DMA_XFER_ACK trả lại quyền sở hữu cho người gửi. Một người gửi
không cần đợi DMA_XFER trước đó được xác nhận và có thể gửi tin nhắn khác
miễn là bộ nhớ liên tục còn lại trong quyền sở hữu của nó là đủ.
Về nguyên tắc, nhiều tin nhắn DMA_XFER và DMA_XFER_ACK có thể được gửi cùng một lúc
(lên tới IPC MTU), do đó cho phép ngắt điều tiết.
Hiện tại, ISH FW quyết định gửi qua DMA nếu tin nhắn ISHTP nhiều hơn 3 IPC
các mảnh vỡ và thông qua IPC nếu không.

Bộ đệm vòng
^^^^^^^^^^^^

Khi máy khách bắt đầu kết nối, một vòng bộ đệm RX và TX sẽ được phân bổ.
Kích thước của vòng có thể được chỉ định bởi khách hàng. Máy khách HID đặt 16 và 32 cho
Bộ đệm TX và RX tương ứng. Khi gửi yêu cầu từ khách hàng, dữ liệu sẽ được
đã gửi được sao chép vào một trong các bộ đệm vòng gửi và được lên lịch gửi bằng cách sử dụng
giao thức tin nhắn xe buýt. Những bộ đệm này là cần thiết vì FW có thể không có
đã xử lý tin nhắn cuối cùng và có thể không có đủ tín dụng kiểm soát luồng
để gửi. Điều tương tự cũng đúng ở phía nhận và cần phải kiểm soát luồng.

Bảng liệt kê máy chủ
^^^^^^^^^^^^^^^^

Lệnh bus liệt kê máy chủ cho phép phát hiện các máy khách có trong FW.
Có thể có nhiều máy khách và máy khách cảm biến cho chức năng hiệu chuẩn.

Để dễ dàng thực hiện và cho phép các trình điều khiển độc lập xử lý từng khách hàng,
lớp vận chuyển này tận dụng mô hình trình điều khiển Bus Linux. Mỗi
khách hàng được đăng ký làm thiết bị trên xe buýt vận chuyển (xe buýt ishtp).

Trình tự liệt kê các thông báo:

- Máy chủ gửi HOST_START_REQ_CMD, cho biết lớp ISHTP của máy chủ đã hoạt động.
- FW phản hồi bằng HOST_START_RES_CMD
- Host gửi HOST_ENUM_REQ_CMD (liệt kê các máy khách FW)
- FW phản hồi với HOST_ENUM_RES_CMD bao gồm bitmap của FW có sẵn
  ID khách hàng
- Đối với mỗi ID FW được tìm thấy trong máy chủ bitmap đó gửi
  HOST_CLIENT_PROPERTIES_REQ_CMD
- FW phản hồi bằng HOST_CLIENT_PROPERTIES_RES_CMD. Thuộc tính bao gồm UUID,
  kích thước tin nhắn ISHTP tối đa, v.v.
- Sau khi máy chủ nhận được các thuộc tính cho máy khách được phát hiện lần cuối đó, nó sẽ xem xét
  Thiết bị ISHTP có đầy đủ chức năng (và phân bổ bộ đệm DMA)

HID trên máy khách ISH
-------------------

Vị trí: trình điều khiển/hid/intel-ish-hid

Trình điều khiển máy khách ISHTP chịu trách nhiệm:

- liệt kê các thiết bị HID trong ứng dụng khách FW ISH
- Nhận mô tả báo cáo
- Đăng ký lõi HID làm trình điều khiển LL
- Xử lý yêu cầu tính năng Nhận/Đặt
- Nhận báo cáo đầu vào

Trình điều khiển cảm biến HID Hub MFD và IIO
-----------------------------------------

Chức năng trong các trình điều khiển này giống như một trung tâm cảm biến bên ngoài.
tham khảo
Tài liệu/hid/hid-sensor.rst cho cảm biến HID
Tài liệu/ABI/testing/sysfs-bus-iio dành cho IIO ABI cho không gian người dùng.

Sơ đồ trình tự vận chuyển HID từ đầu đến cuối
-----------------------------------------

::

HID-ISH-CLN ISHTP IPC HW
          ZZ0000ZZ ZZ0001ZZ
          ZZ0002ZZ ZZ0003ZZ
          ZZ0004ZZ ZZ0005ZZ
          ZZ0006ZZ ZZ0007ZZ
          ZZ0008ZZ ZZ0009ZZ
          ZZ0010ZZ ZZ0011ZZ
          ZZ0012ZZ ZZ0013ZZ
          ZZ0014ZZ<------ISHTP_START------ ZZ0015ZZ
          ZZ0016ZZ ZZ0017ZZ
          ZZ0018ZZ<-----------------HOST_START_RES_CMD-------------------|
          ZZ0019ZZ ZZ0020ZZ
          ZZ0021ZZ-------------------QUERY_SUBSCRIBER-------------------->|
          ZZ0022ZZ ZZ0023ZZ
          ZZ0024ZZ-------------------HOST_ENUM_REQ_CMD------------------->|
          ZZ0025ZZ ZZ0026ZZ
          ZZ0027ZZ<-----------------HOST_ENUM_RES_CMD-------------------|
          ZZ0028ZZ ZZ0029ZZ
          ZZ0030ZZ-------------------HOST_CLIENT_PROPERTIES_REQ_CMD------>|
          ZZ0031ZZ ZZ0032ZZ
          ZZ0033ZZ<-----------------HOST_CLIENT_PROPERTIES_RES_CMD-------|
          ZZ0034ZZ |
          ZZ0035ZZ ZZ0036ZZ
          ZZ0037ZZ-------------------HOST_CLIENT_PROPERTIES_REQ_CMD------>|
          ZZ0038ZZ ZZ0039ZZ
          ZZ0040ZZ<-----------------HOST_CLIENT_PROPERTIES_RES_CMD-------|
          ZZ0041ZZ |
          ZZ0042ZZ ZZ0043ZZ
          ZZ0044ZZ--Lặp lại HOST_CLIENT_PROPERTIES_REQ_CMD-cho đến lần cuối cùng--|
          ZZ0045ZZ ZZ0046ZZ
       đã thăm dò()
          ZZ0047ZZ----------------- CLIENT_CONNECT_REQ_CMD-------------->|
          ZZ0048ZZ ZZ0049ZZ
          ZZ0050ZZ<----------------CLIENT_CONNECT_RES_CMD----------------|
          ZZ0051ZZ ZZ0052ZZ
          ZZ0053ZZ ZZ0054ZZ
          ZZ0055ZZ ZZ0056ZZ
          |ishtp_cl_send(
          HOSTIF_DM_ENUM_DEVICES) ZZ0057ZZ
          ZZ0058ZZ ZZ0059ZZ
          ZZ0060ZZ ZZ0061ZZ
          ZZ0062ZZ ZZ0063ZZ
          ZZ0064ZZ ZZ0065ZZ
          ZZ0066ZZ ZZ0067ZZ
  cho mỗi thiết bị được liệt kê
          |ishtp_cl_send(
          HOSTIF_GET_HID_DESCRIPTORZZ0068ZZ
          ZZ0069ZZ ZZ0070ZZ
          ...Response
ZZ0000ZZ ZZ0001ZZ
  cho mỗi thiết bị được liệt kê
          |ishtp_cl_send(
       HOSTIF_GET_REPORT_DESCRIPTORZZ0002ZZ
          ZZ0003ZZ ZZ0004ZZ
          ZZ0005ZZ ZZ0006ZZ
   hid_allocate_device
          ZZ0007ZZ ZZ0008ZZ
   hid_add_device ZZ0009ZZ |
          ZZ0010ZZ ZZ0011ZZ


Tải chương trình cơ sở ISH từ luồng máy chủ
-----------------------------------

Bắt đầu từ thế hệ Lunar Lake, firmware ISH đã được chia thành hai thành phần để tối ưu hóa không gian tốt hơn và tăng tính linh hoạt. Các thành phần này bao gồm bộ tải khởi động được tích hợp vào BIOS và phần sụn chính được lưu trữ trong hệ thống tệp của hệ điều hành.

Quá trình này hoạt động như sau:

- Ban đầu, trình điều khiển ISHTP gửi lệnh HOST_START_REQ_CMD tới bộ tải khởi động ISH. Đáp lại, bộ nạp khởi động sẽ gửi lại HOST_START_RES_CMD. Phản hồi này bao gồm bit ISHTP_SUPPORT_CAP_LOADER. Sau đó, trình điều khiển ISHTP sẽ kiểm tra xem bit này có được đặt hay không. Nếu đúng như vậy, quá trình tải chương trình cơ sở từ máy chủ sẽ bắt đầu.

- Trong quá trình này, trình điều khiển ISHTP trước tiên gọi hàm request_firmware(), sau đó gửi lệnh LOADER_CMD_XFER_QUERY. Khi nhận được phản hồi từ bộ nạp khởi động, trình điều khiển ISHTP sẽ gửi lệnh LOADER_CMD_XFER_FRAGMENT. Sau khi nhận được phản hồi khác, trình điều khiển ISHTP sẽ gửi lệnh LOADER_CMD_START. Bộ nạp khởi động sẽ phản hồi và sau đó chuyển sang Phần sụn chính.

- Sau khi quá trình kết thúc, trình điều khiển ISHTP gọi hàm Release_firmware().

Để biết thêm thông tin chi tiết, vui lòng tham khảo mô tả luồng được cung cấp bên dưới:

::

+--------------+ +-------------------+
  ZZ0000ZZ ZZ0001ZZ
  +--------------+ +-------------------+
          ZZ0002ZZ
          ZZ0003ZZ
          ZZ0004ZZ
          ZZ0005ZZ
          ZZ0006ZZ
  **********************************************************************************************
  * nếu bit ISHTP_SUPPORT_CAP_LOADER được đặt *
  **********************************************************************************************
          ZZ0007ZZ
          ZZ0008ZZ
          ZZ0009ZZ |
          ZZ0010ZZ
          ZZ0011ZZ
  ----------------------------- |
  ZZ0012ZZ |
  ----------------------------- |
          ZZ0013ZZ
          ZZ0014ZZ
          ZZ0015ZZ
          ZZ0016ZZ
          ZZ0017ZZ
          ZZ0018ZZ
          ZZ0019ZZ
          ZZ0020ZZ
          ZZ0021ZZ
          ZZ0022ZZ
          ZZ0023ZZ
          ZZ0024ZZ
          ZZ0025ZZ
          ZZ0026ZZ~~~Chuyển đến Firmware chính~~+
          ZZ0027ZZ |
          ZZ0028ZZ<--------------------------+
          ZZ0029ZZ
  ----------------------------- |
  ZZ0030ZZ |
  ----------------------------- |
          ZZ0031ZZ
  **********************************************************************************************
  *kết thúc nếu*
  **********************************************************************************************
          ZZ0032ZZ
  +--------------+ +-------------------+
  ZZ0033ZZ ZZ0034ZZ
  +--------------+ +-------------------+

Đang tải chương trình cơ sở tùy chỉnh của nhà cung cấp
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Phần sụn chạy bên trong ISH có thể do Intel cung cấp hoặc do các nhà cung cấp phát triển bằng cách sử dụng Bộ công cụ phát triển phần sụn (FDK) do Intel cung cấp.
Intel sẽ cập nhật chương trình cơ sở do Intel xây dựng lên kho lưu trữ ZZ0000ZZ, nằm trong đường dẫn ZZ0001ZZ. Đối với nền tảng Lunar Lake, firmware ISH do Intel sản xuất sẽ có tên là ZZ0002ZZ.
Các nhà cung cấp muốn cập nhật chương trình cơ sở tùy chỉnh của họ nên tuân theo các nguyên tắc sau để đặt tên cho tệp chương trình cơ sở của họ:

- Tên file firmware nên sử dụng một trong các mẫu sau:

-ZZ0000ZZ
  -ZZ0001ZZ
  -ZZ0002ZZ
  -ZZ0003ZZ
  -ZZ0004ZZ
  -ZZ0005ZZ
  -ZZ0006ZZ
  -ZZ0007ZZ

- ZZ0000ZZ biểu thị thế hệ nền tảng Intel (ví dụ: ZZ0001ZZ cho Lunar Lake) và độ dài không được vượt quá 8 ký tự.
- ZZ0002ZZ là tổng kiểm tra CRC32 của giá trị ZZ0003ZZ từ trường DMI ZZ0004ZZ.
- ZZ0005ZZ là tổng kiểm tra CRC32 của giá trị ZZ0006ZZ từ trường DMI ZZ0007ZZ.
- ZZ0008ZZ là tổng kiểm tra CRC32 của giá trị ZZ0009ZZ từ trường DMI ZZ0010ZZ.
- ZZ0011ZZ là tổng kiểm tra CRC32 của giá trị ZZ0012ZZ từ trường DMI ZZ0013ZZ.

Trong quá trình khởi động hệ thống, trình điều khiển ISH Linux sẽ cố tải chương trình cơ sở theo thứ tự sau, ưu tiên chương trình cơ sở tùy chỉnh với các mẫu khớp chính xác hơn:

1. ZZ0000ZZ
2. ZZ0001ZZ
3. ZZ0002ZZ
4. ZZ0003ZZ
5. ZZ0004ZZ
6. ZZ0005ZZ
7. ZZ0006ZZ
8. ZZ0007ZZ
9. ZZ0008ZZ

Trình điều khiển sẽ tải chương trình cơ sở phù hợp đầu tiên và bỏ qua phần còn lại. Nếu không tìm thấy phần sụn phù hợp, nó sẽ chuyển sang mẫu tiếp theo theo thứ tự đã chỉ định. Nếu tất cả tìm kiếm đều không thành công, chương trình cơ sở mặc định của Intel, được liệt kê cuối cùng theo thứ tự trên, sẽ được tải.

Gỡ lỗi ISH
-------------

Để gỡ lỗi ISH, cơ chế theo dõi sự kiện được sử dụng. Để bật nhật ký gỡ lỗi::

echo 1 > /sys/kernel/tracing/events/intel_ish/enable
  mèo /sys/kernel/truy tìm/dấu vết

ISH IIO sysfs Ví dụ trên Lenovo thinkpad Yoga 260
-------------------------------------------------

::

root@otcpl-ThinkPad-Yoga-260:~# tree -l /sys/bus/iio/devices/
  /sys/bus/iio/thiết bị/
  ├── iio:device0 -> ../../../devices/0044:8086:22D8.0001/HID-SENSOR-200073.9.auto/iio:device0
  │   ├── bộ đệm
  │   │   ├── bật
  │   │   ├── chiều dài
  │   │   └── hình mờ
  ...
│   ├── in_accel_hysteresis
  │   ├── in_accel_offset
  │   ├── trong_accel_sampling_tần số
  │   ├── in_accel_scale
  │   ├── in_accel_x_raw
  │   ├── in_accel_y_raw
  │   ├── in_accel_z_raw
  │   ├── tên
  │   ├── quét_elements
  │   │   ├── in_accel_x_en
  │   │   ├── in_accel_x_index
  │   │   ├── in_accel_x_type
  │   │   ├── in_accel_y_en
  │   │   ├── in_accel_y_index
  │   │   ├── in_accel_y_type
  │   │   ├── in_accel_z_en
  │   │   ├── in_accel_z_index
  │   │   └── in_accel_z_type
  ...
│   │   ├── thiết bị
  │   │   │   │   ├── bộ đệm
  │   │   │   │   │   ├── bật
  │   │   │   │   │   ├── chiều dài
  │   │   │   │   │   └── hình mờ
  │   │   │   │   ├── nhà phát triển
  │   │   │   │   ├── in_intensity_both_raw
  │   │   │   │   ├── in_intensity_hysteresis
  │   │   │   │   ├── in_intensity_offset
  │   │   │   │   ├── trong_cường độ_sampling_tần số
  │   │   │   │   ├── in_intensity_scale
  │   │   │   │   ├── tên
  │   │   │   │   ├── scan_elements
  │   │   │   │   │   ├── in_intensity_both_en
  │   │   │   │   │   ├── in_intensity_both_index
  │   │   │   │   │   └── in_intensity_both_type
  │   │   │   │   ├── kích hoạt
  │   │   │   │   │   └── current_trigger
  ...
│   │   │   │   ├── bộ đệm
  │   │   │   │   │   ├── bật
  │   │   │   │   │   ├── chiều dài
  │   │   │   │   │   └── hình mờ
  │   │   │   │   ├── nhà phát triển
  │   │   │   │   ├── in_magn_hysteresis
  │   │   │   │   ├── in_magn_offset
  │   │   │   │   ├── in_magn_sampling_tần số
  │   │   │   │   ├── in_magn_scale
  │   │   │   │   ├── in_magn_x_raw
  │   │   │   │   ├── in_magn_y_raw
  │   │   │   │   ├── in_magn_z_raw
  │   │   │   │   ├── in_rot_from_north_magnetic_tilt_comp_raw
  │   │   │   │   ├── in_rot_hysteresis
  │   │   │   │   ├── in_rot_offset
  │   │   │   │   ├── trong_rot_sampling_tần số
  │   │   │   │   ├── in_rot_scale
  │   │   │   │   ├── tên
  ...
│   │   │   │   ├── scan_elements
  │   │   │   │   │   ├── in_magn_x_en
  │   │   │   │   │   ├── in_magn_x_index
  │   │   │   │   │   ├── in_magn_x_type
  │   │   │   │   │   ├── in_magn_y_en
  │   │   │   │   │   ├── in_magn_y_index
  │   │   │   │   │   ├── in_magn_y_type
  │   │   │   │   │   ├── in_magn_z_en
  │   │   │   │   │   ├── in_magn_z_index
  │   │   │   │   │   ├── in_magn_z_type
  │   │   │   │   │   ├── in_rot_from_north_magnetic_tilt_comp_en
  │   │   │   │   │   ├── in_rot_from_north_magnetic_tilt_comp_index
  │   │   │   │   │   └── in_rot_from_north_magnetic_tilt_comp_type
  │   │   │   │   ├── kích hoạt
  │   │   │   │   │   └── current_trigger
  ...
│   │   │   │   ├── bộ đệm
  │   │   │   │   │   ├── bật
  │   │   │   │   │   ├── chiều dài
  │   │   │   │   │   └── hình mờ
  │   │   │   │   ├── nhà phát triển
  │   │   │   │   ├── trong_anglvel_hysteresis
  │   │   │   │   ├── in_anglvel_offset
  │   │   │   │   ├── trong_anglvel_sampling_tần số
  │   │   │   │   ├── in_anglvel_scale
  │   │   │   │   ├── in_anglvel_x_raw
  │   │   │   │   ├── in_anglvel_y_raw
  │   │   │   │   ├── in_anglvel_z_raw
  │   │   │   │   ├── tên
  │   │   │   │   ├── scan_elements
  │   │   │   │   │   ├── in_anglvel_x_en
  │   │   │   │   │   ├── in_anglvel_x_index
  │   │   │   │   │   ├── in_anglvel_x_type
  │   │   │   │   │   ├── in_anglvel_y_en
  │   │   │   │   │   ├── in_anglvel_y_index
  │   │   │   │   │   ├── in_anglvel_y_type
  │   │   │   │   │   ├── in_anglvel_z_en
  │   │   │   │   │   ├── in_anglvel_z_index
  │   │   │   │   │   └── in_anglvel_z_type
  │   │   │   │   ├── kích hoạt
  │   │   │   │   │   └── current_trigger
  ...
│   │   │   │   ├── bộ đệm
  │   │   │   │   │   ├── bật
  │   │   │   │   │   ├── chiều dài
  │   │   │   │   │   └── hình mờ
  │   │   │   │   ├── nhà phát triển
  │   │   │   │   ├── trong_anglvel_hysteresis
  │   │   │   │   ├── in_anglvel_offset
  │   │   │   │   ├── trong_anglvel_sampling_tần số
  │   │   │   │   ├── in_anglvel_scale
  │   │   │   │   ├── in_anglvel_x_raw
  │   │   │   │   ├── in_anglvel_y_raw
  │   │   │   │   ├── in_anglvel_z_raw
  │   │   │   │   ├── tên
  │   │   │   │   ├── scan_elements
  │   │   │   │   │   ├── in_anglvel_x_en
  │   │   │   │   │   ├── in_anglvel_x_index
  │   │   │   │   │   ├── in_anglvel_x_type
  │   │   │   │   │   ├── in_anglvel_y_en
  │   │   │   │   │   ├── in_anglvel_y_index
  │   │   │   │   │   ├── in_anglvel_y_type
  │   │   │   │   │   ├── in_anglvel_z_en
  │   │   │   │   │   ├── in_anglvel_z_index
  │   │   │   │   │   └── in_anglvel_z_type
  │   │   │   │   ├── kích hoạt
  │   │   │   │   │   └── current_trigger
  ...
