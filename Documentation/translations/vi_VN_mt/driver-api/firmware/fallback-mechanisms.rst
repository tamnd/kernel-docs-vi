.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/firmware/fallback-mechanisms.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Cơ chế dự phòng
=====================

Cơ chế dự phòng được hỗ trợ để cho phép khắc phục lỗi để thực hiện thao tác trực tiếp
tra cứu hệ thống tập tin trên hệ thống tập tin gốc hoặc khi không thể tìm thấy phần sụn
được cài đặt vì lý do thực tế trên hệ thống tập tin gốc. Hạt nhân
các tùy chọn cấu hình liên quan đến việc hỗ trợ cơ chế dự phòng chương trình cơ sở là:

* CONFIG_FW_LOADER_USER_HELPER: cho phép xây dựng chương trình cơ sở dự phòng
    cơ chế. Hầu hết các bản phân phối hiện nay đều kích hoạt tùy chọn này. Nếu được kích hoạt nhưng
    CONFIG_FW_LOADER_USER_HELPER_FALLBACK bị tắt, chỉ có dự phòng tùy chỉnh
    cơ chế có sẵn và cho lệnh gọi request_firmware_nowait().
  * CONFIG_FW_LOADER_USER_HELPER_FALLBACK: buộc cho phép mỗi yêu cầu
    kích hoạt cơ chế dự phòng sự kiện kobject trên tất cả các lệnh gọi phần mềm API
    ngoại trừ request_firmware_direct(). Hầu hết các bản phân phối đều tắt tùy chọn này
    hôm nay. Cuộc gọi request_firmware_nowait() cho phép một giải pháp thay thế
    cơ chế dự phòng: nếu tùy chọn kconfig này được bật và tùy chọn thứ hai của bạn
    đối số cho request_firmware_nowait(), uevent, được đặt thành false, bạn là
    thông báo cho kernel rằng bạn có cơ chế dự phòng tùy chỉnh và nó sẽ
    tải chương trình cơ sở theo cách thủ công. Đọc dưới đây để biết thêm chi tiết.

Lưu ý rằng điều này có nghĩa là khi có cấu hình này:

CONFIG_FW_LOADER_USER_HELPER=y
CONFIG_FW_LOADER_USER_HELPER_FALLBACK=n

cơ chế dự phòng sự kiện kobject sẽ không bao giờ có hiệu lực ngay cả khi
đối với request_firmware_nowait() khi ueevent được đặt thành true.

Biện minh cho cơ chế dự phòng phần sụn
==========================================

Việc tra cứu hệ thống tập tin trực tiếp có thể không thành công vì nhiều lý do. Những lý do được biết đến
điều này đáng được ghi thành từng khoản và ghi lại vì nó chứng minh sự cần thiết của
cơ chế dự phòng:

* Chạy đua chống lại quyền truy cập bằng hệ thống tập tin gốc khi khởi động.

* Các cuộc đua tiếp tục sau khi bị đình chỉ. Điều này được giải quyết bằng bộ đệm chương trình cơ sở, nhưng
  bộ đệm chương trình cơ sở chỉ được hỗ trợ nếu bạn sử dụng sự kiện và nó không được hỗ trợ
  được hỗ trợ cho request_firmware_into_buf().

* Không thể truy cập chương trình cơ sở thông qua các phương tiện thông thường:

* Nó không thể được cài đặt vào hệ thống tập tin gốc
        * Phần sụn cung cấp dữ liệu cụ thể của thiết bị rất độc đáo được thiết kế riêng cho
          đơn vị đã thu thập thông tin địa phương. Một ví dụ là hiệu chuẩn
          dữ liệu cho chipset WiFi cho thiết bị di động. Dữ liệu hiệu chuẩn này được
          không phổ biến cho tất cả các đơn vị, nhưng được thiết kế riêng cho từng đơn vị.  Những thông tin như vậy có thể
          được cài đặt trên một phân vùng flash riêng biệt ngoài nơi root
          hệ thống tập tin được cung cấp.

Các loại cơ chế dự phòng
============================

Thực sự có hai cơ chế dự phòng có sẵn bằng cách sử dụng một sysfs được chia sẻ
giao diện như một cơ sở tải:

* Cơ chế dự phòng sự kiện Kobject
* Cơ chế dự phòng tùy chỉnh

Trước tiên, hãy ghi lại cơ sở tải sysfs được chia sẻ.

Cơ sở tải sysfs chương trình cơ sở
===============================

Để giúp trình điều khiển thiết bị tải lên chương trình cơ sở bằng cơ chế dự phòng
cơ sở hạ tầng phần sụn tạo ra giao diện sysfs để kích hoạt không gian người dùng
để tải và cho biết khi nào chương trình cơ sở đã sẵn sàng. Thư mục sysfs được tạo
thông qua fw_create_instance(). Cuộc gọi này tạo ra một thiết bị cấu trúc mới được đặt tên theo
phần sụn được yêu cầu và thiết lập nó trong hệ thống phân cấp thiết bị bằng cách
liên kết thiết bị được sử dụng để thực hiện yêu cầu với tư cách là thiết bị gốc của thiết bị.
Các thuộc tính tệp của thư mục sysfs được xác định và kiểm soát thông qua
lớp của thiết bị mới (firmware_class) và nhóm (fw_dev_attr_groups).
Đây thực sự là nơi lấy tên mô-đun firmware_class ban đầu,
vì ban đầu cơ chế tải chương trình cơ sở duy nhất có sẵn là
cơ chế mà chúng tôi hiện đang sử dụng làm cơ chế dự phòng, đăng ký một lớp cấu trúc
firmware_class. Bởi vì các thuộc tính được hiển thị là một phần của tên mô-đun, nên
tên mô-đun firmware_class không thể được đổi tên trong tương lai, để đảm bảo lạc hậu
khả năng tương thích với không gian người dùng cũ.

Để tải chương trình cơ sở bằng giao diện sysfs, chúng tôi hiển thị chỉ báo tải,
và tải tệp chương trình cơ sở lên:

* /sys/$DEVPATH/đang tải
  * /sys/$DEVPATH/dữ liệu

Để tải lên chương trình cơ sở, bạn sẽ lặp lại 1 vào tệp đang tải để cho biết
bạn đang tải firmware. Sau đó, bạn ghi phần sụn vào tệp dữ liệu,
và bạn thông báo cho kernel rằng phần sụn đã sẵn sàng bằng cách lặp lại 0 trên
tập tin đang tải.

Thiết bị phần sụn được sử dụng để giúp tải phần sụn bằng sysfs chỉ được tạo nếu
tải chương trình cơ sở trực tiếp không thành công và nếu cơ chế dự phòng được bật cho thiết bị của bạn
yêu cầu chương trình cơ sở, điều này được thiết lập với ZZ0000ZZ. Đó là
điều quan trọng là phải nhắc lại rằng không có thiết bị nào được tạo nếu tra cứu hệ thống tệp trực tiếp
đã thành công.

Sử dụng::

echo 1 > /sys/$DEVPATH/đang tải

Sẽ xóa mọi tải một phần trước đó cùng một lúc và tạo phần sụn API
trả về một lỗi. Khi tải firmware, firmware_class sẽ phát triển bộ đệm
để phần sụn tăng dần theo PAGE_SIZE để giữ hình ảnh khi nó xuất hiện.

firmware_data_read() và firmware_loading_show() chỉ được cung cấp cho
test_firmware để kiểm tra, chúng không được gọi trong sử dụng bình thường hoặc
dự kiến sẽ được sử dụng thường xuyên bởi không gian người dùng.

firmware_fallback_sysfs
-----------------------
.. kernel-doc:: drivers/base/firmware_loader/fallback.c
   :functions: firmware_fallback_sysfs

Cơ chế dự phòng sự kiện kobject của chương trình cơ sở
==========================================

Vì một thiết bị được tạo cho giao diện sysfs để giúp tải chương trình cơ sở dưới dạng
Không gian người dùng của cơ chế dự phòng có thể được thông báo về việc bổ sung thiết bị bằng cách
dựa vào các sự kiện kobject. Việc bổ sung thiết bị vào thiết bị
phân cấp có nghĩa là cơ chế dự phòng để tải chương trình cơ sở đã được khởi tạo.
Để biết chi tiết về việc triển khai, hãy tham khảo fw_load_sysfs_fallback(), đặc biệt
về việc sử dụng dev_set_uevent_suppress() và kobject_uevent().

Cơ chế sự kiện kobject của kernel được triển khai trong lib/kobject_uevent.c,
nó phát ra các sự kiện cho không gian người dùng. Là một phần bổ sung cho kobject uevents Linux
các bản phân phối cũng có thể kích hoạt CONFIG_UEVENT_HELPER_PATH, sử dụng
Chức năng trợ giúp usermode của lõi kernel (UMH) để gọi ra không gian người dùng
người trợ giúp cho các sự kiện kobject. Trong thực tế mặc dù không có sự phân phối chuẩn nào
từng sử dụng CONFIG_UEVENT_HELPER_PATH. Nếu CONFIG_UEVENT_HELPER_PATH là
đã bật nhị phân này sẽ được gọi mỗi lần kobject_uevent_env() được gọi
trong kernel cho mỗi sự kiện kobject được kích hoạt.

Các triển khai khác nhau đã được hỗ trợ trong không gian người dùng để tận dụng
cơ chế dự phòng này. Khi chỉ có thể tải chương trình cơ sở bằng cách sử dụng
cơ chế sysfs, thành phần không gian người dùng "hotplug" cung cấp chức năng của
giám sát các sự kiện kobject. Trong lịch sử, điều này đã được thay thế bởi systemd
udev, tuy nhiên hỗ trợ tải chương trình cơ sở đã bị xóa khỏi udev kể từ systemd
cam kết be2ea723b1d0 ("udev: xóa hỗ trợ tải chương trình cơ sở không gian người dùng")
kể từ v217 vào tháng 8 năm 2014. Điều này có nghĩa là hầu hết các bản phân phối Linux ngày nay đều
không sử dụng hoặc lợi dụng cơ chế dự phòng phần sụn được cung cấp
bởi kobject uevents. Điều này càng trở nên trầm trọng hơn do thực tế là hầu hết
các bản phân phối ngày nay vô hiệu hóa CONFIG_FW_LOADER_USER_HELPER_FALLBACK.

Tham khảo do_firmware_uevent() để biết chi tiết về các biến sự kiện kobject
thiết lập. Các biến hiện được chuyển đến không gian người dùng bằng "kobject add"
sự kiện là:

* FIRMWARE=tên phần mềm
* TIMEOUT=giá trị thời gian chờ
* ASYNC=yêu cầu API có đồng bộ hay không

Theo mặc định, DEVPATH được thiết lập bởi cơ sở hạ tầng kobject kernel bên trong.
Dưới đây là một ví dụ về tập lệnh uevent kobject đơn giản::

# Both $DEVPATH và $FIRMWARE đã được cung cấp trong môi trường.
        MY_FW_DIR=/lib/firmware/
        echo 1 > /sys/$DEVPATH/đang tải
        mèo $MY_FW_DIR/$FIRMWARE > /sys/$DEVPATH/dữ liệu
        echo 0 > /sys/$DEVPATH/đang tải

Cơ chế dự phòng tùy chỉnh phần sụn
==================================

Người dùng cuộc gọi request_firmware_nowait() có sẵn một tùy chọn khác
theo ý của họ: dựa vào cơ chế dự phòng của sysfs nhưng yêu cầu không
các sự kiện kobject được cấp cho không gian người dùng. Logic ban đầu đằng sau điều này
có phải các tiện ích khác ngoài udev có thể được yêu cầu để tra cứu chương trình cơ sở
trong các đường dẫn phi truyền thống -- các đường dẫn bên ngoài danh sách được ghi lại trong
phần 'Tra cứu hệ thống tập tin trực tiếp'. Tùy chọn này không có sẵn cho bất kỳ
các cuộc gọi API khác vì các sự kiện luôn bị ép buộc đối với họ.

Vì các sự kiện chỉ có ý nghĩa nếu cơ chế dự phòng được bật
trong kernel của bạn, có vẻ kỳ quặc khi kích hoạt các sự kiện với kernel không
có cơ chế dự phòng được kích hoạt trong hạt nhân của họ. Thật không may chúng tôi cũng
dựa vào cờ uevent có thể bị vô hiệu hóa bởi request_firmware_nowait() để
cũng thiết lập bộ đệm chương trình cơ sở cho các yêu cầu chương trình cơ sở. Như tài liệu ở trên,
bộ đệm chương trình cơ sở chỉ được thiết lập nếu sự kiện được bật cho cuộc gọi API.
Mặc dù điều này có thể vô hiệu hóa bộ đệm chương trình cơ sở cho request_firmware_nowait()
cuộc gọi, người dùng API này không nên sử dụng nó cho mục đích vô hiệu hóa
bộ đệm vì đó không phải là mục đích ban đầu của cờ. Không cài đặt
cờ sự kiện có nghĩa là bạn muốn chọn tham gia cơ chế dự phòng chương trình cơ sở
nhưng bạn muốn ngăn chặn các sự kiện kobject, vì bạn có một giải pháp tùy chỉnh
bằng cách nào đó sẽ giám sát việc bổ sung thiết bị của bạn vào hệ thống phân cấp thiết bị và
tải chương trình cơ sở cho bạn thông qua đường dẫn tùy chỉnh.

Hết thời gian chờ dự phòng chương trình cơ sở
=========================

Cơ chế dự phòng phần sụn có thời gian chờ. Nếu phần sụn không được tải
trên giao diện sysfs theo giá trị thời gian chờ, một lỗi sẽ được gửi đến
người lái xe. Theo mặc định, thời gian chờ được đặt thành 60 giây nếu có sự kiện
mong muốn, nếu không thì MAX_JIFFY_OFFSET sẽ được sử dụng (có thể hết thời gian chờ tối đa).
Logic đằng sau việc sử dụng MAX_JIFFY_OFFSET cho những sự kiện không phải sự kiện là một tùy chỉnh
giải pháp sẽ có nhiều thời gian cần thiết để tải chương trình cơ sở.

Bạn có thể tùy chỉnh thời gian chờ của chương trình cơ sở bằng cách lặp lại thời gian chờ mong muốn của bạn vào
tập tin sau:

* /sys/class/firmware/hết thời gian

Nếu bạn lặp lại 0 vào thì có nghĩa là MAX_JIFFY_OFFSET sẽ được sử dụng. Kiểu dữ liệu
đối với thời gian chờ là int.

Cơ chế dự phòng firmware nhúng EFI
========================================

Trên một số thiết bị, mã EFI của hệ thống/ROM có thể chứa một bản sao được nhúng
chương trình cơ sở cho một số thiết bị ngoại vi tích hợp của hệ thống và
trình điều khiển thiết bị Linux của thiết bị ngoại vi cần truy cập vào phần sụn này.

Trình điều khiển thiết bị cần phần sụn như vậy có thể sử dụng
firmware_request_platform() cho việc này, hãy lưu ý rằng đây là một
cơ chế dự phòng riêng biệt khỏi các cơ chế dự phòng khác và
cái này không sử dụng giao diện sysfs.

Trình điều khiển thiết bị cần điều này có thể mô tả phần sụn mà nó cần
sử dụng cấu trúc efi_embedded_fw_desc:

.. kernel-doc:: include/linux/efi_embedded_fw.h
   :functions: efi_embedded_fw_desc

Mã nhúng-fw EFI hoạt động bằng cách quét tất cả bộ nhớ EFI_BOOT_SERVICES_CODE
các phân đoạn cho tiền tố khớp chuỗi 8 byte; nếu tiền tố được tìm thấy nó
sau đó thực hiện sha256 theo byte có độ dài và nếu kết quả khớp đó sẽ tạo một bản sao có độ dài
byte và thêm nó vào danh sách của nó với các phần cứng được tìm thấy.

Để tránh thực hiện việc quét tốn kém này trên tất cả các hệ thống, việc so khớp dmi là
đã sử dụng. Trình điều khiển dự kiến sẽ xuất một mảng dmi_system_id, với mỗi mục '
driver_data trỏ đến efi_embedded_fw_desc.

Để đăng ký mảng này với mã efi-embedded-fw, trình điều khiển cần:

1. Luôn được tích hợp sẵn vào kernel hoặc lưu trữ mảng dmi_system_id trong một
   tệp đối tượng riêng biệt luôn được tích hợp sẵn.

2. Thêm một khai báo bên ngoài cho mảng dmi_system_id vào
   bao gồm/linux/efi_embedded_fw.h.

3. Thêm mảng dmi_system_id vào embed_fw_table trong
   driver/firmware/efi/embedded-firmware.c được gói trong thử nghiệm #ifdef
   trình điều khiển đang được tích hợp sẵn.

4. Thêm "select EFI_EMBEDDED_FIRMWARE if EFI_STUB" vào mục Kconfig của nó.

Hàm firmware_request_platform() sẽ luôn thử tải firmware trước tiên
với tên được chỉ định trực tiếp từ đĩa, do đó, fw nhúng EFI có thể
luôn bị ghi đè bằng cách đặt tệp trong /lib/firmware.

Lưu ý rằng:

1. Quá trình quét mã cho phần mềm nhúng EFI chạy gần cuối
   của start_kernel(), ngay trước khi gọi Rest_init(). Đối với người lái xe bình thường và
   các hệ thống con sử dụng subsys_initcall() để tự đăng ký thì điều này không
   vấn đề. Điều này có nghĩa là mã chạy trước đó không thể sử dụng EFI
   phần mềm nhúng.

2. Hiện tại, mã fw nhúng EFI giả định rằng các phần cứng luôn bắt đầu ở
   phần bù là bội số của 8 byte, nếu điều này không đúng với trường hợp của bạn
   gửi một bản vá để sửa lỗi này.

3. Hiện tại mã fw nhúng EFI chỉ hoạt động trên x86 vì các vòm khác
   EFI_BOOT_SERVICES_CODE miễn phí trước khi mã fw nhúng EFI có cơ hội
   quét nó.

4. Quá trình quét mạnh mẽ hiện tại của EFI_BOOT_SERVICES_CODE là một tính năng đặc biệt
   giải pháp vũ phu. Đã có cuộc thảo luận về việc sử dụng Nền tảng UEFI
   Giao thức Khối lượng chương trình cơ sở của thông số khởi tạo (PI). Điều này đã bị từ chối
   vì Giao thức FV dựa trên giao diện ZZ0000ZZ của thông số PI và:
   1. Thông số PI hoàn toàn không xác định phần sụn ngoại vi
   2. Các giao diện bên trong của thông số PI không đảm bảo bất kỳ giao diện ngược nào
   khả năng tương thích. Mọi chi tiết triển khai trong FV có thể thay đổi,
   và có thể thay đổi từ hệ thống này sang hệ thống khác. Hỗ trợ Giao thức FV sẽ là
   khó khăn vì nó cố tình mơ hồ.

Ví dụ về cách kiểm tra và giải nén phần mềm nhúng
------------------------------------------------------

Để kiểm tra, ví dụ như chương trình cơ sở nhúng của bộ điều khiển màn hình cảm ứng Silead,
làm như sau:

1. Khởi động hệ thống với efi=debug trên dòng lệnh kernel

2. cp /sys/kernel/debug/efi/boot_services_code? đến địa chỉ nhà của bạn

3. Mở boot_services_code? các tập tin trong trình soạn thảo hex, tìm kiếm
   tiền tố ma thuật cho phần mềm Silead: F0 00 00 00 02 00 00 00, điều này mang lại cho bạn
   địa chỉ bắt đầu của phần sụn bên trong boot_services_code? tài liệu.

4. Phần sụn có một mẫu cụ thể, nó bắt đầu bằng địa chỉ trang 8 byte,
   thường là F0 00 00 00 02 00 00 00 cho trang đầu tiên theo sau là 32-bit
   cặp địa chỉ từ + giá trị 32 bit. Với địa chỉ từ tăng dần 4
   byte (1 từ) cho mỗi cặp cho đến khi hoàn thành một trang. Một trang hoàn chỉnh là
   theo sau là địa chỉ trang mới, theo sau là nhiều cặp từ + giá trị hơn. Cái này
   dẫn đến một mô hình rất khác biệt. Cuộn xuống cho đến khi mẫu này dừng lại,
   điều này mang lại cho bạn phần cuối của phần sụn bên trong boot_services_code? tài liệu.

5. "dd if=boot_services_code? of=firmware bs=1 Skip=<begin-addr> count=<len>"
   sẽ giải nén firmware cho bạn. Kiểm tra tập tin phần vững trong một
   hexeditor để đảm bảo bạn đã hiểu đúng các tham số dd.

6. Sao chép nó vào /lib/firmware dưới tên dự kiến ​​để kiểm tra.

7. Nếu chương trình cơ sở được giải nén hoạt động, bạn có thể sử dụng thông tin tìm thấy để điền vào
   efi_embedded_fw_desc để mô tả nó, chạy "sha256sum firmware"
   để lấy sha256sum đưa vào trường sha256.
