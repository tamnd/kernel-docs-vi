.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/amd-sfh-hid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trung tâm kết hợp cảm biến AMD
=====================
AMD Sensor Fusion Hub (SFH) là một phần của SOC bắt đầu từ các nền tảng dựa trên AMD.
Giải pháp này đang hoạt động tốt trên một số sản phẩm OEM. AMD SFH sử dụng HID trên bus PCIe.
Về mặt kiến trúc, nó giống với ISH, tuy nhiên điểm khác biệt chính là
báo cáo HID được tạo như một phần của trình điều khiển hạt nhân.

Sơ đồ khối
-------------

::

----------------------------------
	ZZ0000ZZ
	- -------------------------------

---------------------------------------------
	 ----------------------------------
	ZZ0000ZZ
	 ----------------------------------

----------------------------------
	ZZ0000ZZ
	 ----------------------------------

--------------------------------
	ZZ0000ZZ
	ZZ0001ZZ
	 --------------------------------

--------------------------------
	ZZ0000ZZ
	 --------------------------------
    hệ điều hành
    ---------------------------------------------
    Phần cứng + Phần sụn
         --------------------------------
         ZZ0001ZZ
         --------------------------------


Lớp vận chuyển AMD HID
-----------------------
Vận chuyển AMD SFH cũng được triển khai dưới dạng xe buýt. Mỗi ứng dụng khách thực thi trong AMD MP2 đều
được đăng ký làm thiết bị trên xe buýt này. Ở đây, MP2 là lõi ARM được kết nối với x86 để xử lý
dữ liệu cảm biến. Lớp liên kết từng thiết bị (trình điều khiển AMD SFH HID) xác định loại thiết bị và
đăng ký với lõi HID. Lớp vận chuyển gắn một đối tượng "struct hid_ll_driver" không đổi với
mỗi thiết bị. Sau khi thiết bị được đăng ký với lõi HID, các cuộc gọi lại được cung cấp qua cấu trúc này sẽ là
được sử dụng bởi lõi HID để giao tiếp với thiết bị. AMD HID Lớp vận chuyển thực hiện các cuộc gọi đồng bộ.

Lớp khách AMD HID
--------------------
Lớp này chịu trách nhiệm triển khai các yêu cầu và mô tả HID. Vì chương trình cơ sở là hệ điều hành bất khả tri, HID
lớp máy khách điền vào cấu trúc và mô tả yêu cầu HID. Lớp máy khách HID rất phức tạp
giao diện giữa lớp PCIe MP2 và HID. Lớp máy khách HID khởi tạo lớp PCIe MP2 và giữ
phiên bản của lớp MP2. Nó xác định số lượng cảm biến được kết nối bằng lớp MP2-PCIe. Dựa trên
trên đó phân bổ địa chỉ DRAM cho từng cảm biến và chuyển nó đến trình điều khiển MP2-PCIe. Bật
liệt kê từng cảm biến, lớp máy khách sẽ điền vào cấu trúc Bộ mô tả HID và báo cáo đầu vào HID
cấu trúc. HID Cấu trúc báo cáo tính năng là tùy chọn. Cấu trúc mô tả báo cáo thay đổi từ
cảm biến đến cảm biến.

Lớp PCIe AMD MP2
------------------
Lớp PCIe MP2 chịu trách nhiệm thực hiện tất cả các giao dịch với phần sụn qua PCIe.
Việc thiết lập kết nối giữa firmware và PCIe diễn ra ở đây.

Giao tiếp giữa X86 và MP2 được chia thành ba phần.
1. Truyền lệnh qua thanh ghi hộp thư C2P.
2. Truyền dữ liệu qua DRAM.
3. Thông tin cảm biến được hỗ trợ thông qua các thanh ghi P2C.

Các lệnh được gửi đến MP2 bằng cách sử dụng thanh ghi Hộp thư C2P. Viết vào C2P Thanh ghi tin nhắn tạo ra
ngắt đến MP2. Lớp máy khách phân bổ bộ nhớ vật lý và bộ nhớ tương tự được gửi đến MP2 thông qua
lớp PCI. Phần sụn MP2 ghi đầu ra lệnh vào bộ nhớ DRAM truy cập mà máy khách
lớp đã được phân bổ. Phần sụn luôn ghi tối thiểu 32 byte vào DRAM. Vì vậy, với tư cách là một trình điều khiển giao thức
sẽ phân bổ tối thiểu 32 byte không gian DRAM.

Luồng liệt kê và thăm dò
----------------------------
::

HID AMD AMD AMD -PCIe MP2
       Lớp máy khách vận chuyển lõi FW
        ZZ0000ZZ ZZ0001ZZ |
        ZZ0002ZZ ZZ0003ZZ
        ZZ0004ZZ ZZ0005ZZ |
        ZZ0006ZZ ZZ0007ZZ
        ZZ0008ZZ ZZ0009ZZ |
        ZZ0010ZZ ZZ0011ZZ |
        ZZ0012ZZ ZZ0013ZZ
        ZZ0014ZZ ZZ0015ZZ
        ZZ0016ZZ ZZ0017ZZ |
        ZZ0018ZZ ZZ0019ZZ |
        ZZ0020ZZ ZZ0021ZZ ZZ0022ZZ
        ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
        ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ
        ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
        ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ
        ZZ0035ZZ ZZ0036ZZ ZZ0037ZZ
        Kích hoạt ZZ0038ZZ ZZ0039ZZ |
        Cảm biến ZZ0040ZZ ZZ0041ZZ |
        ZZ0042ZZ ZZ0043ZZ ZZ0044ZZ
        ZZ0045ZZ HID vận chuyển|                           | Kích hoạt |
        ZZ0047ZZ<-Đầu dò------ZZ0048ZZ---Cảm biến CMD--> |
        ZZ0049ZZ Tạo ZZ0050ZZ |
        ZZ0051ZZ HID thiết bị ZZ0052ZZ |
        ZZ0053ZZ (MFD) ZZ0054ZZ |
        ZZ0055ZZ bởi Populate|			   | |
        ZZ0057ZZ HID ZZ0058ZZ |
        ZZ0059ZZ ll_driver ZZ0060ZZ |
        ZZ0061ZZ ZZ0062ZZ |
        ZZ0063ZZ ZZ0064ZZ |
        ZZ0065ZZ ZZ0066ZZ |
        ZZ0067ZZ ZZ0068ZZ |


Luồng dữ liệu từ ứng dụng đến Trình điều khiển AMD SFH
------------------------------------------------

::

ZZ0000ZZ ZZ0001ZZ |
                ZZ0002ZZ ZZ0003ZZ |
                ZZ0004ZZ ZZ0005ZZ |
                ZZ0006ZZ ZZ0007ZZ |
                ZZ0008ZZ ZZ0009ZZ |
                ZZ0010ZZ ZZ0011ZZ |
                ZZ0012ZZ ZZ0013ZZ |
                ZZ0014ZZ ZZ0015ZZ |
	        ZZ0016ZZ HID_get_input|                           | |
	        Báo cáo ZZ0018ZZ ZZ0019ZZ |
	        ZZ0020ZZ------------->ZZ0021ZZ ZZ0022ZZ
	        ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
	        ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ
	        ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ
	        ZZ0032ZZ ZZ0033ZZ ZZ0034ZZ
	        ZZ0035ZZ ZZ0036ZZ ZZ0037ZZ
	        |              |Data đã nhận được ZZ0039ZZ |
	        ZZ0040ZZ trong báo cáo HID|                           | |
    Tới ZZ0042ZZ<-------------ZZ0043ZZ |
    Ứng dụng|              | ZZ0045ZZ |
        <-------ZZ0046ZZ ZZ0047ZZ |