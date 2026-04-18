.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/amd_hsmp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Giao diện AMD HSMP
============================================

Fam19h mới hơn(model 0x00-0x1f, 0x30-0x3f, 0x90-0x9f, 0xa0-0xaf),
Fam1Ah(model 0x00-0x1f) Dòng bộ xử lý máy chủ EPYC được hỗ trợ bởi AMD
chức năng quản lý hệ thống thông qua HSMP (Cổng quản lý hệ thống máy chủ).

Cổng quản lý hệ thống máy chủ (HSMP) là một giao diện để cung cấp
Phần mềm cấp hệ điều hành có quyền truy cập vào các chức năng quản lý hệ thống thông qua
tập hợp các thanh ghi hộp thư.

Thông tin chi tiết về giao diện có thể được tìm thấy trong chương
"7 Cổng quản lý hệ thống máy chủ (HSMP)" của dòng/model PPR
Ví dụ: ZZ0000ZZ


Giao diện HSMP được hỗ trợ trên dòng CPU máy chủ EPYC và MI300A (APU).


Thiết bị HSMP
============================================

Trình điều khiển amd_hsmp trong trình điều khiển/nền tảng/x86/amd/hsmp/ có các tệp trình điều khiển riêng biệt
để thăm dò dựa trên đối tượng ACPI, thăm dò dựa trên thiết bị nền tảng và cho mục đích chung
mã cho hai trình điều khiển này.

Tùy chọn Kconfig CONFIG_AMD_HSMP_PLAT biên dịch plat.c và tạo amd_hsmp.ko.
Tùy chọn Kconfig CONFIG_AMD_HSMP_ACPI biên dịch acpi.c và tạo hsmp_acpi.ko.
Việc chọn bất kỳ cấu hình nào trong hai cấu hình này sẽ tự động chọn CONFIG_AMD_HSMP. Cái này
biên dịch mã chung hsmp.c và tạo mô-đun hsmp_common.ko.

Cả trình điều khiển ACPI và plat đều tạo ra thiết bị /dev/hsmp để cho phép
chương trình không gian người dùng chạy các lệnh hộp thư hsmp.

Định dạng đối tượng ACPI được trình điều khiển hỗ trợ được xác định bên dưới.

$ ls -al /dev/hsmp
crw-r--r-- 1 gốc gốc 10, 123 Ngày 21 tháng 1 21:41 /dev/hsmp

Đặc điểm của nút dev:
 * Chế độ ghi được sử dụng để chạy các lệnh set/configure
 * Chế độ đọc được sử dụng để chạy các lệnh giám sát get/status

Hạn chế truy cập:
 * Chỉ người dùng root mới được phép mở tệp ở chế độ ghi.
 * Tất cả người dùng có thể mở tệp ở chế độ đọc.

Tích hợp trong kernel:
 * Các hệ thống con khác trong kernel có thể sử dụng phương thức vận chuyển đã xuất
   hàm hsmp_send_message().
 * Việc khóa người gọi do tài xế đảm nhiệm.


Giao diện hệ thống HSMP
====================

1. Hệ thống nhị phân của bảng số liệu

AMD MI300A MCM cung cấp tin nhắn GET_METRICS_TABLE để truy xuất
hầu hết thông tin quản lý hệ thống từ SMU trong một lần.

Bảng số liệu được cung cấp dưới dạng tệp nhị phân sysfs thập lục phân
trong mỗi thư mục socket sysfs được tạo tại
/sys/devices/platform/amd_hsmp/socket%d/metrics_bin

Lưu ý: lseek() không được hỗ trợ khi đọc toàn bộ bảng số liệu.

Các định nghĩa về bảng số liệu sẽ được ghi lại như một phần của Public PPR.
Điều tương tự được định nghĩa trong tiêu đề amd_hsmp.h.

2. Tệp sysfs đo từ xa HSMP

Các tệp sysfs sau có sẵn tại /sys/devices/platform/AMDI0097:0X/.

* c0_residency_input: Tỷ lệ số lõi ở trạng thái C0.
* prochot_status: Báo cáo 1 nếu bộ xử lý ở giá trị ngưỡng nhiệt,
  0 nếu không.
* smu_fw_version: Phiên bản phần mềm SMU.
* Protocol_version: Phiên bản giao diện HSMP.
* ddr_max_bw: Băng thông DDR tối đa theo lý thuyết tính bằng GB/s.
* ddr_utilised_bw_input: Băng thông DDR được sử dụng hiện tại tính bằng GB/s.
* ddr_utilised_bw_perc_input(%): Phần trăm băng thông DDR hiện đang sử dụng.
*mclk_input: Đồng hồ bộ nhớ tính bằng MHz.
* fclk_input: Đồng hồ vải tính bằng MHz.
* clk_fmax: Tần số tối đa của ổ cắm tính bằng MHz.
* clk_fmin: Tần số tối thiểu của ổ cắm tính bằng MHz.
* cclk_freq_limit_input: Giới hạn tần số xung nhịp lõi trên mỗi ổ cắm tính bằng MHz.
* pwr_current_active_freq_limit: Giới hạn tần số hoạt động hiện tại của socket
  tính bằng MHz.
* pwr_current_active_freq_limit_source: Nguồn tần số hoạt động hiện tại
  giới hạn.

Định dạng đối tượng thiết bị ACPI
=========================
Định dạng đối tượng ACPI được mong đợi từ trình điều khiển AMD_hsmp
đối với ổ cắm có ID00 được đưa ra dưới đây ::

Thiết bị (HSMP)
		{
			Tên (_HID, "AMDI0097")
			Tên (_UID, "ID00")
			Tên (HSE0, 0x00000001)
			Tên(RBF0, ResourceTemplate()
			{
				Memory32Fixed(ReadWrite, 0xxxxxxx, 0x00100000)
			})
			Phương thức(_CRS, 0, NotSerialized)
			{
				Trở lại (RBF0)
			}
			Phương thức(_STA, 0, NotSerialized)
			{
				Nếu(LEqual(HSE0, Một))
				{
					Trả về(0x0F)
				}
				Khác
				{
					Trả lại(Không)
				}
			}
			Tên (_DSD, Gói (2)
			{
				Bộ đệm (0x10)
				{
					0x9D, 0x61, 0x4D, 0xB7, 0x07, 0x57, 0xBD, 0x48,
					0xA6, 0x9F, 0x4E, 0xA2, 0x87, 0x1F, 0xC2, 0xF6
				},
				Gói(3)
				{
					Gói (2) {"MsgIdOffset", 0x00010934},
					Gói (2) {"MsgRspOffset", 0x00010980},
					Gói (2) {"MsgArgOffset", 0x000109E0}
				}
			})
		}

Giao diện HSMP HWMON
====================
Cảm biến nguồn HSMP được đăng ký với giao diện hwmon. Một hwmon riêng biệt
thư mục được tạo cho mỗi ổ cắm và các tệp sau được tạo
trong thư mục hwmon.
- power1_input (chỉ đọc)
- power1_cap_max (chỉ đọc)
- power1_cap (đọc, viết)

Một ví dụ
==========

Để truy cập thiết bị hsmp từ chương trình C.
Trước tiên, bạn cần bao gồm các tiêu đề ::

#include <linux/amd_hsmp.h>

Xác định các tin nhắn/ID tin nhắn được hỗ trợ.

Điều tiếp theo, mở tệp thiết bị, như sau ::

tập tin int;

tệp = open("/dev/hsmp", O_RDWR);
  nếu (tệp < 0) {
    /* ERROR HANDLING; bạn có thể kiểm tra errno để xem có vấn đề gì */
    thoát (1);
  }

IOCTL sau đây được xác định:

ZZ0000ZZ
  Đối số là một con trỏ tới a::

cấu trúc hsmp_message {
    	__u32 tin nhắn_id;				/* Mã thông báo */
    	__u16 số_args;			/* Số từ đối số đầu vào trong tin nhắn */
    	__u16 phản hồi_sz;			/* Số lượng từ đầu ra/phản hồi dự kiến */
    	__u32 lập luận [HSMP_MAX_MSG_LEN];		/* đối số/bộ đệm phản hồi */
    	__u16 sock_ind;			/* số ổ cắm */
    };

ioctl sẽ trả về giá trị khác 0 khi thất bại; bạn có thể đọc errno để xem
chuyện gì đã xảy ra. Giao dịch trả về 0 khi thành công.

Thông tin chi tiết hơn về giao diện và định nghĩa thông báo có thể được tìm thấy trong chương
"7 Cổng quản lý hệ thống máy chủ (HSMP)" của dòng/model PPR tương ứng
ví dụ: ZZ0000ZZ

C-API không gian người dùng được cung cấp bằng cách liên kết với thư viện esmi,
được cung cấp bởi dự án E-SMS ZZ0000ZZ
Xem: ZZ0001ZZ