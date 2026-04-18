.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/arcmsr_spec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
ARECA FIRMWARE SPEC
=====================

Cách sử dụng bộ chuyển đổi IOP331
=================================

(Tất cả vào/ra đều ở chế độ xem của IOP331)

1. Tin nhắn 0
-------------

- Tin nhắn initThread và mã trả về

2. Chuông cửa dùng để mô phỏng RS-232
----------------------------------------

trong Chuông cửa
    bit0
	dữ liệu đã sẵn sàng
	zDRIVER DATA WRITE OK)
    bit1
	dữ liệu đã được đọc
	(DRIVER DATA READ được)

outDooeBell:
    bit0
	dữ liệu đã sẵn sàng
	(IOP331 DATA WRITE được)
    bit1
	dữ liệu trong đã được đọc
	(IOP331 DATA READ được)

3. Sử dụng bộ nhớ chỉ mục
-------------------------

==========================================================
bù 0xf00 cho đầu ra RS232 (bộ đệm yêu cầu)
offset 0xe00 cho RS232 trong (bộ đệm cào)
offset 0xa00 cho mã tin nhắn gửi đến message_rwbuffer
	       (trình điều khiển gửi tới IOP331)
offset 0xa00 cho mã tin nhắn gửi đi message_rwbuffer
	       (IOP331 gửi cho tài xế)
==========================================================

4. Giả lập RS-232
-------------------

Hiện tại bộ đệm 128 byte được sử dụng:

====================================
uint32_t đầu tiên Độ dài dữ liệu (1--124)
Byte 4--127 Tối đa 124 byte dữ liệu
====================================

5. PostQ
--------

Tất cả Lệnh SCSI phải được gửi qua postQ:

(cổng xếp hàng vào)
	Khung yêu cầu phải được căn chỉnh 32 byte:

#bit27--bit31
		cờ cho bài viết ccb
	    #bit0--bit26
		địa chỉ thực (bit27--bit31) của bài đăng arcmsr_cdb

===== =====================
		bit31 == ================
			0 khung 256 byte
			1 khung 512 byte
			==================
		bit30 == ===============
			0 yêu cầu bình thường
			1 yêu cầu BIOS
			=================
		bit29 dành riêng
		bit28 dành riêng
		bit27 dành riêng
		===== =====================

(cổng xếp hàng đi)
	Yêu cầu trả lời:

#bit27--bit31
		    cờ trả lời
	    #bit0--bit26
		    địa chỉ thực (bit27--bit31) của câu trả lời arcmsr_cdb

===== ============================================================
		    bit31 phải là 0 (đối với loại trả lời này)
		    bit30 dành riêng cho bắt tay BIOS
		    bit29 dành riêng
		    bit28 == ========================================================
			    0 không có lỗi, bỏ qua AdapStatus/DevStatus/SenseData
			    1 Lỗi, mã lỗi AdapStatus/DevStatus/SenseData
			    =========================================================
		    bit27 dành riêng
		    ===== ============================================================

6. Yêu cầu BIOS
---------------

Tất cả yêu cầu BIOS đều giống với yêu cầu từ PostQ

Ngoại trừ:

Khung yêu cầu được gửi từ không gian cấu hình:

=========================================
	bù đắp: Khung yêu cầu 0x78 (bit30 == 1)
	offset: 0x18 chỉ ghi để tạo
		       IRQ tới IOP331
	=========================================

Hoàn thành yêu cầu::

(bit30 == 0, bit28==cờ lỗi)

7. Định nghĩa mục nhập SGL (cấu trúc)
--------------------------------------

8. Message1 Out - Mã trạng thái chẩn đoán (????)
------------------------------------------------

9. Mã tin nhắn Message0
------------------------

====== ======================================================================
0x00 NOP
0x01 Nhận cấu hình
	->offset 0xa00 :đối với mã tin nhắn gửi đi message_rwbuffer
	(IOP331 gửi cho tài xế)

====================================================================
	Chữ ký 0x87974060(4)
	Yêu cầu len 0x00000200(4)
	số hàng đợi 0x00000100(4)
	SDRAM Kích thước 0x00000100(4)->256 MB
	Kênh IDE 0x00000008(4)
	nhà cung cấp 40 byte char
	mô hình 8 byte char
	FirmVer 16 byte char
	Bản đồ thiết bị 16 byte char
	Phiên bản phần mềm DWORD

- Đã thêm để kiểm tra
				khả năng phần mềm mới
	====================================================================
0x02 Đặt cấu hình
	->offset 0xa00 :đối với mã tin nhắn gửi đến message_rwbuffer
	(trình điều khiển gửi tới IOP331)

==============================================
	Chữ ký 0x87974063(4)
	UPPER32 của Khung yêu cầu (4)->Chỉ trình điều khiển
	==============================================
Đặt lại 0x03 (Hủy tất cả lệnh được xếp hàng đợi)
0x04 Dừng hoạt động nền
Bộ đệm ẩn 0x05
0x06 Bắt đầu hoạt động nền
	(bắt đầu lại nếu nền bị tạm dừng)
0x07 Kiểm tra xem lệnh máy chủ đang chờ xử lý
	(Novel Có Thể Cần Chức Năng Này)
0x08 Đặt thời gian điều khiển
	-> offset 0xa00 cho mã tin nhắn gửi đến message_rwbuffer
	(trình điều khiển đến IOP331)

==========================
	byte 0 0xaa <- chữ ký
	byte 1 0x55 <- chữ ký
	byte 2 năm (04)
	byte 3 tháng (1..12)
	ngày byte 4 (1..31)
	byte 5 giờ (0..23)
	byte 6 phút (0..59)
	byte 7 giây (0..59)
	==========================
====== ======================================================================


Giao diện RS-232 cho Bộ điều khiển Areca Raid
=============================================

Giao diện lệnh cấp thấp chỉ dành riêng cho thiết bị đầu cuối VT100

1. Trình tự thực hiện lệnh
--------------------------------

(A) Tiêu đề
		Chuỗi 3 byte (0x5E, 0x01, 0x61)

(B) Khối lệnh
		độ dài thay đổi của dữ liệu bao gồm độ dài,
		mã lệnh, dữ liệu và byte tổng kiểm tra

(C) Trả về dữ liệu
		độ dài thay đổi của dữ liệu

2. Khối lệnh
----------------

(A) byte thứ 1
		độ dài khối lệnh (byte thấp)

(B) byte thứ 2
		độ dài khối lệnh (byte cao)

		.. Note:: command block length shouldn't > 2040 bytes,
			  length excludes these two bytes

(C) byte thứ 3
		mã lệnh

(D) byte thứ 4 và byte tiếp theo
		byte dữ liệu có độ dài thay đổi

phụ thuộc vào mã lệnh

(E) byte cuối cùng
	    byte tổng kiểm tra (tổng của byte đầu tiên cho đến byte dữ liệu cuối cùng)

3. Mã lệnh và dữ liệu liên quan
-----------------------------------

Sau đây là mã lệnh được xác định trong lệnh điều khiển đột kích
mã 0x10--0x1? được sử dụng để quản lý cấp hệ thống,
không cần kiểm tra mật khẩu và nên được thực hiện riêng biệt
tiện ích được kiểm soát tốt và không dành cho người dùng cuối truy cập.
Mã lệnh 0x20--0x?? luôn kiểm tra mật khẩu,
phải nhập mật khẩu để kích hoạt các lệnh này::

liệt kê
	{
		GUI_SET_SERIAL=0x10,
		GUI_SET_VENDOR,
		GUI_SET_MODEL,
		GUI_IDENTIFY,
		GUI_CHECK_PASSWORD,
		GUI_LOGOUT,
		GUI_HTTP,
		GUI_SET_ETHERNET_ADDR,
		GUI_SET_LOGO,
		GUI_POLL_EVENT,
		GUI_GET_EVENT,
		GUI_GET_HW_MONITOR,
		// GUI_QUICK_CREATE=0x20, (đã xóa chức năng)
		GUI_GET_INFO_R=0x20,
		GUI_GET_INFO_V,
		GUI_GET_INFO_P,
		GUI_GET_INFO_S,
		GUI_CLEAR_EVENT,
		GUI_MUTE_BEEPER=0x30,
		GUI_BEEPER_SETTING,
		GUI_SET_PASSWORD,
		GUI_HOST_INTERFACE_MODE,
		GUI_REBUILD_PRIORITY,
		GUI_MAX_ATA_MODE,
		GUI_RESET_CONTROLLER,
		GUI_COM_PORT_SETTING,
		GUI_NO_OPERATION,
		GUI_DHCP_IP,
		GUI_CREATE_PASS_THROUGH=0x40,
		GUI_MODIFY_PASS_THROUGH,
		GUI_DELETE_PASS_THROUGH,
		GUI_IDENTIFY_DEVICE,
		GUI_CREATE_RAIDSET=0x50,
		GUI_DELETE_RAIDSET,
		GUI_EXPAND_RAIDSET,
		GUI_ACTIVATE_RAIDSET,
		GUI_CREATE_HOT_SPARE,
		GUI_DELETE_HOT_SPARE,
		GUI_CREATE_VOLUME=0x60,
		GUI_MODIFY_VOLUME,
		GUI_DELETE_VOLUME,
		GUI_START_CHECK_VOLUME,
		GUI_STOP_CHECK_VOLUME
	};

Mô tả lệnh
^^^^^^^^^^^^^^^^^^^

GUI_SET_SERIAL
	Đặt số sê-ri của bộ điều khiển

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x10
	độ dài mật khẩu byte 3 (nên là 0x0f)
	byte 4-0x13 phải là "ArEcATEcHnoLogY"
	byte 0x14--0x23 Chuỗi số sê-ri (phải là 16 byte)
	===================================================================

GUI_SET_VENDOR
	Đặt chuỗi nhà cung cấp cho bộ điều khiển

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x11
	độ dài mật khẩu byte 3 (nên là 0x08)
	byte 4-0x13 phải là "ArEcAvAr"
	chuỗi nhà cung cấp byte 0x14--0x3B (phải là 40 byte)
	===================================================================

GUI_SET_MODEL
	Đặt tên model của bộ điều khiển

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x12
	độ dài mật khẩu byte 3 (nên là 0x08)
	byte 4-0x13 phải là "ArEcAvAr"
	chuỗi mô hình byte 0x14--0x1B (phải là 8 byte)
	===================================================================

GUI_IDENTIFY
	Xác định thiết bị

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x13
			    trả về "Hệ thống con Areca RAID"
	===================================================================

GUI_CHECK_PASSWORD
	Xác minh mật khẩu

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x14
	độ dài mật khẩu byte 3
	byte 4-0x??       mật khẩu người dùng cần được kiểm tra
	===================================================================

GUI_LOGOUT
	Đăng xuất GUI (buộc kiểm tra mật khẩu ở lệnh tiếp theo)

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x15
	===================================================================

GUI_HTTP
	Giao diện HTTP (dành riêng cho dịch vụ proxy Http) (0x16)

GUI_SET_ETHERNET_ADDR
	Đặt địa chỉ ethernet MAC

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x17
	độ dài mật khẩu byte 3 (nên là 0x08)
	byte 4-0x13 phải là "ArEcAvAr"
	byte 0x14--0x19 Địa chỉ Ethernet MAC (phải là 6 byte)
	===================================================================

GUI_SET_LOGO
	Đặt logo trong HTTP

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x18
	byte 3 Trang# (0/1/2/3) (0xff --> xóa logo OEM)
	byte 4/5/6/7 0x55/0xaa/0xa5/0x5a
	dữ liệu byte 8 TITLE.JPG (mỗi trang phải là 2000 byte)

			  .. Note:: page0 1st 2 byte must be
				    actual length of the JPG file
===================================================================

GUI_POLL_EVENT
	Thăm dò ý kiến nếu nhật ký sự kiện thay đổi

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x19
	===================================================================

GUI_GET_EVENT
	Đọc sự kiện

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x1a
	Trang sự kiện byte 3 (0:trang đầu tiên/1/2/3:trang cuối)
	===================================================================

GUI_GET_HW_MONITOR
	Nhận dữ liệu giám sát CTNH

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x1b
	QUẠT # of byte 3(ví dụ 2)
	Cảm biến điện áp byte 4 # of(ví dụ 3)
	cảm biến nhiệt độ byte 5 # of (ví dụ 2)
	nguồn 6 byte # of
	byte 7/8 Fan#0 (RPM)
	byte 9/10 Fan#1
	byte 11/12 Điện áp#0 giá trị ban đầu trong ZZ0000ZZ
	byte 13/14 Giá trị điện áp#0
	byte 15/16 Điện áp#1 tổ chức
	byte 17/18 Điện áp#1
	byte 19/20 Điện áp#2 tổ chức
	byte 21/22 Điện áp#2
	byte 23 Temp#0
	byte 24 Temp#1
	byte 25 Chỉ báo nguồn (bit0 power#0,
			  bit1 power#1)
	chỉ báo byte 26 UPS
	===================================================================

GUI_QUICK_CREATE
	Tạo nhanh tập đột kích/âm lượng

====================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x20
	dung lượng thô byte 3/4/5/6
	cấp độ đột kích byte 7
	kích thước sọc byte 8
	byte 9 dự phòng
	byte 10/11/12/13 mặt nạ thiết bị (các thiết bị để tạo đột kích/âm lượng)
	====================================================================

Chức năng này bị loại bỏ, ứng dụng như
    để thực hiện chức năng tạo nhanh

cần sử dụng chức năng GUI_CREATE_RAIDSET và GUI_CREATE_VOLUMESET.

GUI_GET_INFO_R
	Nhận thông tin về tập hợp đột kích

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x20
	tập đột kích byte 3#
	===================================================================

	::

cấu trúc typedef sGUI_RAISET
	    {
		    BYTE grsRaidSetName[16];
		    DWORD grsCông suất;
		    DWORD grsCapacityX;
		    DWORD grsFailMask;
		    BYTE grsDevArray[32];
		    BYTE grsMemberThiết bị;
		    BYTE grsNewMemberThiết bị;
		    BYTE grsRaidState;
		    BYTE grsVolumes;
		    BYTE grsVolumeList[16];
		    BYTE grsRes1;
		    BYTE grsRes2;
		    BYTE grsRes3;
		    BYTE grsFreeSegments;
		    DWORD grsRawStripes[8];
		    DWORD grsRes4;
		    DWORD grsRes5; // Tổng cộng tới 128 byte
		    DWORD grsRes6; // Tổng cộng tới 128 byte
	    } sGUI_RAISET, *pGUI_RAISET;

GUI_GET_INFO_V
	Nhận thông tin về tập đĩa

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x21
	tập đĩa byte 3#
	===================================================================

	::

cấu trúc typedef sGUI_VOLUMESET
	    {
		    BYTE gvsVolumeName[16]; // 16
		    DWORD gvsCapacity;
		    DWORD gvsCapacityX;
		    DWORD gvsFailMask;
		    DWORD gvsStripeSize;
		    DWORD gvsNewFailMask;
		    DWORD gvsNewStripeSize;
		    DWORD gvsVolumeStatus;
		    DWORD gvsProgress; // 32
		    sSCSI_ATTR gvsScsi;
		    BYTE gvsMemberDisks;
		    BYTE gvsRaidLevel; // 8
		    BYTE gvsNewMemberDisks;
		    BYTE gvsNewRaidLevel;
		    BYTE gvsRaidSetNumber;
		    BYTE gvsRes0; // 4
		    BYTE gvsRes1[4]; // 64 byte
	    } sGUI_VOLUMESET, *pGUI_VOLUMESET;

GUI_GET_INFO_P
	Nhận thông tin ổ đĩa vật lý

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x22
	ổ đĩa byte 3 # (từ 0 đến kênh tối đa - 1)
	===================================================================

	::

cấu trúc typedef sGUI_PHY_DRV
	    {
		    BYTE gpdModelName[40];
		    BYTE gpdSerialNumber[20];
		    BYTE gpdFirmRev[8];
		    DWORD gpdCapacity;
		    DWORD gpdCapacityX; // Dành riêng cho việc mở rộng
		    BYTE gpdDeviceState;
		    BYTE gpdPioMode;
		    BYTE gpdCurrentUdmaMode;
		    BYTE gpdUdmaChế độ;
		    BYTE gpdDriveSelect;
		    BYTE gpdRaidNumber; // 0xff nếu không thuộc nhóm đột kích
		    sSCSI_ATTR gpdScsi;
		    BYTE gpdReserved[40]; // Tổng cộng tới 128 byte
	    } sGUI_PHY_DRV, *pGUI_PHY_DRV;

GUI_GET_INFO_S
	Nhận thông tin hệ thống

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x23
	===================================================================

	::

cấu trúc typedef sCOM_ATTR
	    {
		    BYTE comBaudRate;
		    BYTE comDataBits;
		    BYTE comStopBits;
		    BYTE tương đương;
		    BYTE comFlowControl;
	    } sCOM_ATTR, *pCOM_ATTR;
	    cấu trúc typedef sSYSTEM_INFO
	    {
		    BYTE gsiVendorName[40];
		    BYTE gsiSerialNumber[16];
		    BYTE gsiFirmVersion[16];
		    BYTE gsiBootVersion[16];
		    BYTE gsiMbVersion[16];
		    BYTE gsiModelName[8];
		    BYTE gsiLocalIp[4];
		    BYTE gsiCurrentIp[4];
		    DWORD gsiTimeTick;
		    DWORD gsiCpuTốc độ;
		    DWORD gsiICache;
		    DWORD gsiDCache;
		    DWORD gsiScache;
		    DWORD gsiMemorySize;
		    DWORD gsiBộ nhớTốc độ;
		    DWORD gsiSự kiện;
		    BYTE gsiMacAddress[6];
		    BYTE gsiDhcp;
		    BYTE gsiBeeper;
		    BYTE gsiChannelSử dụng;
		    BYTE gsiMaxAtaMode;
		    BYTE gsiSdramEcc; // 1: nếu ECC được bật
		    BYTE gsiRebuildPriority;
		    sCOM_ATTR gsiComA; // 5 byte
		    sCOM_ATTR gsiComB; // 5 byte
		    BYTE gsiIdeKênh;
		    BYTE gsiScsiHostCác kênh;
		    BYTE gsiIdeHostCác kênh;
		    BYTE gsiMaxVolumeSet;
		    BYTE gsiMaxRaidSet;
		    BYTE gsiEtherPort; // 1: nếu cổng mạng ether được hỗ trợ
		    BYTE gsiRaid6Engine; // 1: Hỗ trợ động cơ Raid6
		    BYTE gsiRes[75];
	    } sSYSTEM_INFO, *pSYSTEM_INFO;

GUI_CLEAR_EVENT
	Xóa sự kiện hệ thống

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x24
	===================================================================

GUI_MUTE_BEEPER
	Tắt tiếng bíp hiện tại

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x30
	===================================================================
GUI_BEEPER_SETTING
	Tắt tiếng bíp

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x31
	byte 3 0-> vô hiệu hóa, 1-> kích hoạt
	===================================================================

GUI_SET_PASSWORD
	Thay đổi mật khẩu

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x32
	độ dài từ truyền byte 3 (phải <= 15)
	mật khẩu byte 4 (phải là chữ và số)
	===================================================================

GUI_HOST_INTERFACE_MODE
	Đặt chế độ giao diện máy chủ

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x33
	byte 3 0->Độc lập, 1->cụm
	===================================================================

GUI_REBUILD_PRIORITY
	Đặt mức độ ưu tiên xây dựng lại

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x34
	byte 3 0/1/2/3 (thấp->cao)
	===================================================================

GUI_MAX_ATA_MODE
	Đặt chế độ ATA tối đa sẽ được sử dụng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x35
	byte 3 0/1/2/3 (133/100/66/33)
	===================================================================

GUI_RESET_CONTROLLER
	Đặt lại bộ điều khiển

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x36
			  * Phản hồi bằng màn hình VT100 (loại bỏ nó)
	===================================================================

GUI_COM_PORT_SETTING
	Cài đặt cổng COM

=======================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x37
	byte 3 0->COMA (cổng hạn),
			  1->COMB (cổng gỡ lỗi)
	byte 4 0/1/2/3/4/5/6/7
			  (1200/2400/4800/9600/19200/38400/57600/115200)
	bit dữ liệu byte 5
			  (0:7 bit, 1:8 bit phải là 8 bit)
	byte 6 bit dừng (bit dừng 0:1, 1:2)
	tính chẵn lẻ byte 7 (0:không, 1:tắt, 2:chẵn)
	điều khiển luồng byte 8
			  (0:none, 1:xon/xoff, 2:hardware => không được sử dụng)
	=======================================================================

GUI_NO_OPERATION
	Không có hoạt động

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x38
	===================================================================

GUI_DHCP_IP
	Đặt tùy chọn DHCP và địa chỉ IP cục bộ

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x39
	byte 3 0:dhcp bị tắt, 1:dhcp được bật
	địa chỉ IP byte 4/5/6/7
	===================================================================

GUI_CREATE_PASS_THROUGH
	Tạo thông qua đĩa

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x40
	thiết bị byte 3 #
	byte 4 kênh scsi (0/1)
	id scsi byte 5 (0->15)
	byte 6 scsi lun (0-->7)
	hàng đợi được gắn thẻ byte 7 (đã bật 1)
	Chế độ bộ đệm byte 8 (bật 1)
	tốc độ tối đa byte 9 (0/1/2/3/4,
			  không đồng bộ/20/40/80/160 cho scsi)
			  (0/1/2/3/4, 33/66/100/133/150 cho ide)
	===================================================================

GUI_MODIFY_PASS_THROUGH
	Sửa đổi chuyển qua đĩa

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x41
	thiết bị byte 3 #
	byte 4 kênh scsi (0/1)
	id scsi byte 5 (0->15)
	byte 6 scsi lun (0-->7)
	hàng đợi được gắn thẻ byte 7 (đã bật 1)
	Chế độ bộ đệm byte 8 (bật 1)
	tốc độ tối đa byte 9 (0/1/2/3/4,
			  không đồng bộ/20/40/80/160 cho scsi)
			  (0/1/2/3/4, 33/66/100/133/150 cho ide)
	===================================================================

GUI_DELETE_PASS_THROUGH
	Xóa đĩa đi qua

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x42
	byte 3 device# to sẽ bị xóa
	===================================================================
GUI_IDENTIFY_DEVICE
	Xác định thiết bị

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x43
	Phương thức flash byte 3
			  (0: đã chọn flash, 1: không chọn flash)
	mặt nạ thiết bị byte 4/5/6/7 IDE sẽ được flash
			  .. Note:: no response data available
===================================================================

GUI_CREATE_RAIDSET
	Tạo nhóm đột kích

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x50
	mặt nạ thiết bị byte 3/4/5/6
	Tên tập hợp byte 7-22 (nếu byte 7 == 0: sử dụng mặc định)
	===================================================================

GUI_DELETE_RAIDSET
	Xóa bộ đột kích

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x51
	tập đột kích byte 3#
	===================================================================

GUI_EXPAND_RAIDSET
	Mở rộng bộ đột kích

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x52
	mặt nạ thiết bị byte 3 raidset#
	byte 4/5/6/7 để mở rộng
	byte 8/9/10 (8:0 không thay đổi, 1 thay đổi, 0xff:chấm dứt,
			  9: cấp độ đột kích mới,
			  10: kích thước sọc mới
			  0/1/2/3/4/5->4/8/16/32/64/128K )
	lặp lại byte 12/11/13 cho mỗi tập trong tập hợp đột kích
	===================================================================

GUI_ACTIVATE_RAIDSET
	Kích hoạt bộ đột kích chưa hoàn thành

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x53
	tập đột kích byte 3#
	===================================================================

GUI_CREATE_HOT_SPARE
	Tạo đĩa dự phòng nóng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x54
	Mặt nạ thiết bị byte 3/4/5/6 để tạo dự phòng nóng
	===================================================================

GUI_DELETE_HOT_SPARE
	Xóa đĩa dự phòng nóng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x55
	mặt nạ thiết bị byte 3/4/5/6 để xóa dự phòng nóng
	===================================================================

GUI_CREATE_VOLUME
	Tạo bộ âm lượng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x60
	tên tập hợp khối lượng byte 3 raidset#
	byte 4-19
			  (nếu byte4 == 0, sử dụng mặc định)
	dung lượng âm lượng byte 20-27 (khối)
	cấp độ đột kích byte 28
	kích thước sọc byte 29
			  (0/1/2/3/4/5->4/8/16/32/64/128K)
	kênh byte 30
	ID byte 31
	byte 32 LUN
	thẻ kích hoạt byte 33 1
	byte 34 1 kích hoạt bộ đệm
	tốc độ byte 35
			  (0/1/2/3/4->async/20/40/80/160 cho scsi)
			  (0/1/2/3/4->33/66/100/133/150 cho IDE )
	byte 36 1 để chọn khởi tạo nhanh
	===================================================================

GUI_MODIFY_VOLUME
	Chỉnh sửa âm lượng Đặt

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x61
	tập byte 3#
	byte 4-19 tên bộ tập mới
			  (nếu byte4 == 0, không thay đổi)
	dung lượng ổ đĩa mới byte 20-27 (dành riêng)
	cấp độ đột kích mới byte 28
	byte 29 kích thước sọc mới
			  (0/1/2/3/4/5->4/8/16/32/64/128K)
	kênh mới byte 30
	byte 31 ID mới
	byte 32 LUN mới
	thẻ kích hoạt byte 33 1
	byte 34 1 kích hoạt bộ đệm
	tốc độ byte 35
			  (0/1/2/3/4->async/20/40/80/160 cho scsi)
			  (0/1/2/3/4->33/66/100/133/150 cho IDE )
	===================================================================

GUI_DELETE_VOLUME
	Xóa bộ âm lượng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x62
	tập đĩa byte 3#
	===================================================================

GUI_START_CHECK_VOLUME
	Bắt đầu kiểm tra tính nhất quán của âm lượng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x63
	tập đĩa byte 3#
	===================================================================

GUI_STOP_CHECK_VOLUME
	Dừng kiểm tra tính nhất quán của âm lượng

===================================================================
	độ dài byte 0,1
	mã lệnh byte 2 0x64
	===================================================================

4. Dữ liệu trả về
-----------------

(A) Tiêu đề
    Chuỗi 3 byte (0x5E, 0x01, 0x61)
(B) Chiều dài
    2 byte
    (byte thấp thứ 1, không bao gồm độ dài và byte tổng kiểm tra)
(C)
    trạng thái hoặc dữ liệu:

1) Nếu độ dài == 1 ==> mã trạng thái 1 byte ::

#define GUI_OK 0x41
		#define GUI_RAIDSET_NOT_NORMAL 0x42
		#define GUI_VOLUMESET_NOT_NORMAL 0x43
		#define GUI_NO_RAIDSET 0x44
		#define GUI_NO_VOLUMESET 0x45
		#define GUI_NO_PHYSICAL_DRIVE 0x46
		#define GUI_PARAMETER_ERROR 0x47
		#define GUI_UNSUPPORTED_COMMAND 0x48
		#define GUI_DISK_CONFIG_CHANGED 0x49
		#define GUI_INVALID_PASSWORD 0x4a
		#define GUI_NO_DISK_SPACE 0x4b
		#define GUI_CHECKSUM_ERROR 0x4c
		#define GUI_PASSWORD_REQUIRED 0x4d

2) Nếu độ dài > 1:

khối dữ liệu được trả về từ bộ điều khiển
		và nội dung phụ thuộc vào mã lệnh

(E) Tổng kiểm tra
    tổng kiểm tra độ dài và trạng thái hoặc byte dữ liệu

