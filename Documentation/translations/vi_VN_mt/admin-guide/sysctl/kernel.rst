.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysctl/kernel.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Tài liệu cho /proc/sys/kernel/
======================================

.. See scripts/check-sysctl-docs to keep this up to date


Bản quyền (c) 1998, 1999, Rik van Riel <riel@nl.linux.org>

Bản quyền (c) 2009, Shen Feng<shen@cn.fujitsu.com>

Để biết thông tin chung và giới thiệu pháp lý, vui lòng xem tại
Tài liệu/admin-guide/sysctl/index.rst.

------------------------------------------------------------------------------

Tệp này chứa tài liệu cho các tệp sysctl trong
ZZ0000ZZ.

Các tập tin trong thư mục này có thể được sử dụng để điều chỉnh và giám sát
những điều linh tinh và chung chung trong hoạt động của Linux
hạt nhân. Vì một số tệp ZZ0000ZZ được sử dụng để làm hỏng việc của bạn.
hệ thống, nên đọc cả tài liệu và nguồn
trước khi thực sự điều chỉnh.

Hiện tại, các tệp này có thể (tùy thuộc vào cấu hình của bạn)
hiển thị trong ZZ0000ZZ:

.. contents:: :local:


tài khoản
====

::

tần số nước cao

Nếu tính năng tính toán quy trình kiểu BSD được bật, các giá trị này sẽ kiểm soát
hành vi của nó. Nếu không gian trống trên hệ thống tập tin nơi nhật ký tồn tại
xuống dưới mức ZZ0000ZZ\ % kế toán bị đình chỉ. Nếu không gian trống được
trên ZZ0001ZZ\ % sơ yếu lý lịch kế toán. ZZ0002ZZ xác định
tần suất chúng tôi kiểm tra dung lượng trống (giá trị nằm trong
giây). Mặc định:

::

4 2 30

Nghĩa là, tạm dừng tính toán nếu dung lượng trống giảm xuống dưới 2%; tiếp tục nó
nếu nó tăng lên ít nhất 4%; xem xét thông tin về số lượng
không gian trống có hiệu lực trong 30 giây.


acpi_video_flags
================

Xem Tài liệu/power/video.rst. Điều này cho phép thiết lập chế độ tiếp tục video,
theo cách tương tự với tham số kernel ZZ0000ZZ, bằng cách
kết hợp các giá trị sau:

= =======
1 s3_bios
2 s3_mode
4 giây3_bíp
= =======

vòm
====

Tên phần cứng của máy, đầu ra giống như ZZ0000ZZ
(ví dụ: ZZ0001ZZ hoặc ZZ0002ZZ).

auto_msgmni
===========

Biến này không có tác dụng và có thể bị xóa trong kernel sau này
phát hành. Đọc nó luôn trả về 0.
Lên đến Linux 3.17, nó đã bật/tắt tính năng tự động tính toán lại của
ZZ0000ZZ
khi thêm/xóa bộ nhớ hoặc khi tạo/xóa không gian tên IPC.
Việc lặp lại "1" vào tệp này đã kích hoạt tính năng tự động tính toán lại msgmni.
Tiếng vang "0" đã tắt nó đi. Giá trị mặc định là 1.


bootloader_type (chỉ x86)
==========================

Điều này cung cấp số loại bộ nạp khởi động như được chỉ định bởi bộ nạp khởi động,
dịch chuyển sang trái 4 và HOẶC với bốn bit thấp của bộ nạp khởi động
phiên bản.  Lý do cho việc mã hóa này là nó được sử dụng để khớp với
Trường ZZ0000ZZ trong tiêu đề kernel; mã hóa được giữ cho
khả năng tương thích ngược.  Nghĩa là, nếu số loại bộ nạp khởi động đầy đủ
là 0x15 và số phiên bản đầy đủ là 0x234, tệp này sẽ chứa
giá trị 340 = 0x154.

Xem các trường ZZ0000ZZ và ZZ0001ZZ trong
Documentation/arch/x86/boot.rst để biết thêm thông tin.


bootloader_version (chỉ x86)
=============================

Số phiên bản bootloader hoàn chỉnh.  Trong ví dụ trên, điều này
tập tin sẽ chứa giá trị 564 = 0x234.

Xem các trường ZZ0000ZZ và ZZ0001ZZ trong
Documentation/arch/x86/boot.rst để biết thêm thông tin.


bpf_stats_enabled
=================

Kiểm soát xem hạt nhân có nên thu thập số liệu thống kê về các chương trình BPF hay không
(tổng thời gian chạy, số lần chạy...). Kích hoạt
số liệu thống kê làm giảm hiệu suất trên mỗi chương trình một chút
chạy. Số liệu thống kê có thể được xem bằng ZZ0000ZZ.

= ======================================
0 Không thu thập số liệu thống kê (mặc định).
1 Thu thập số liệu thống kê.
= ======================================


cad_pid
=======

Đây là pid sẽ được báo hiệu khi khởi động lại (đặc biệt là bởi
Ctrl-Alt-Xóa). Viết một giá trị vào tập tin này mà không
tương ứng với một tiến trình đang chạy sẽ tạo ra ZZ0000ZZ.

Xem thêm ZZ0000ZZ.


cap_last_cap
============

Khả năng hợp lệ cao nhất của kernel đang chạy.  Xuất khẩu
ZZ0000ZZ từ hạt nhân.


.. _core_pattern:

lõi_pattern
============

ZZ0000ZZ được sử dụng để chỉ định tên mẫu tệp kết xuất lõi.

* độ dài tối đa 127 ký tự; giá trị mặc định là "lõi"
* ZZ0000ZZ được sử dụng làm mẫu mẫu cho đầu ra
  tên tập tin; các mẫu chuỗi nhất định (bắt đầu bằng '%') là
  thay thế bằng giá trị thực tế của chúng.
* khả năng tương thích ngược với ZZ0001ZZ:

Nếu ZZ0000ZZ không bao gồm "%p" (mặc định là không)
	và ZZ0001ZZ được đặt thì .PID sẽ được thêm vào
	tên tập tin.

* công cụ xác định định dạng tên lõi

=======================================================
	%<NUL> '%' bị loại bỏ
	%% xuất ra một '%'
	%p pid
	%P pid chung (không gian tên PID ban đầu)
	%i thời gian
	%I thời gian chung (không gian tên PID ban đầu)
	%u uid (trong không gian tên người dùng ban đầu)
	%g gid (trong không gian tên người dùng ban đầu)
	Chế độ kết xuất %d, khớp với ZZ0000ZZ và
			ZZ0001ZZ
	số tín hiệu %s
	%t UNIX thời gian kết xuất
	tên máy chủ %h
	%e tên tệp thực thi (có thể được rút ngắn, có thể được thay đổi bằng prctl, v.v.)
	%f tên tệp thực thi
	Đường dẫn thực thi %E
	%c kích thước tối đa của tệp lõi theo giới hạn tài nguyên RLIMIT_CORE
	%C CPU tác vụ đã chạy
	%F số pidfd
	%<OTHER> cả hai đều bị loại bỏ
	=======================================================

* Nếu ký tự đầu tiên của mẫu là '|', kernel sẽ xử lý
  phần còn lại của mẫu dưới dạng lệnh chạy.  Bãi chứa lõi sẽ là
  được ghi vào đầu vào tiêu chuẩn của chương trình đó thay vì vào một tệp.


core_pipe_limit
===============

Sysctl này chỉ áp dụng được khi ZZ0003ZZ được cấu hình thành
các tệp lõi ống tới trình trợ giúp không gian người dùng (khi ký tự đầu tiên của
ZZ0000ZZ là '|', xem ở trên).
Khi thu thập lõi qua đường ống tới một ứng dụng, đôi khi
hữu ích cho ứng dụng thu thập để thu thập dữ liệu về
quá trình gặp sự cố từ thư mục ZZ0001ZZ của nó.
Để thực hiện việc này một cách an toàn, kernel phải đợi quá trình thu thập
xử lý để thoát, để không xóa các tệp Proc của quy trình bị lỗi
sớm.
Điều này lại tạo ra khả năng một không gian người dùng hoạt động sai
quá trình thu thập có thể ngăn chặn việc thu thập một quá trình bị lỗi một cách đơn giản
bằng cách không bao giờ thoát ra.
Sysctl này bảo vệ chống lại điều đó.
Nó xác định có bao nhiêu quy trình gặp sự cố đồng thời có thể được chuyển tới người dùng
ứng dụng không gian song song.
Nếu giá trị này bị vượt quá thì các quá trình gặp sự cố ở trên giá trị đó sẽ
giá trị được ghi lại thông qua nhật ký kernel và lõi của chúng bị bỏ qua.
0 là một giá trị đặc biệt, chỉ ra rằng các quy trình không giới hạn có thể được
được bắt song song, nhưng việc chờ đợi sẽ không diễn ra (tức là
quá trình thu thập không được đảm bảo quyền truy cập vào ZZ0002ZZ).
Giá trị này mặc định là 0.


core_sort_vma
=============

Coredump mặc định ghi VMA theo thứ tự địa chỉ. Bằng cách thiết lập
ZZ0000ZZ thành 1, VMA sẽ được ghi từ kích thước nhỏ nhất
đến kích thước lớn nhất. Điều này được biết là có thể phá vỡ ít nhất elfutils, nhưng
có thể hữu ích khi xử lý các vấn đề rất lớn (và bị cắt ngắn)
coredumps nơi bao gồm các chi tiết gỡ lỗi hữu ích hơn
trong các VMA nhỏ hơn.


core_uses_pid
=============

Tên tệp coredump mặc định là "core".  Bằng cách thiết lập
ZZ0000ZZ thành 1, tên tệp coredump sẽ trở thành core.PID.
Nếu ZZ0002ZZ không bao gồm "%p" (mặc định là không)
và ZZ0001ZZ được đặt thì .PID sẽ được thêm vào
tên tập tin.


ctrl-alt-del
============

Khi giá trị trong tệp này là 0, ctrl-alt-del bị kẹt và
được gửi đến chương trình ZZ0000ZZ để xử lý quá trình khởi động lại nhẹ nhàng.
Tuy nhiên, khi giá trị > 0, phản ứng của Linux đối với Vulcan
Nerve Pinch (tm) sẽ được khởi động lại ngay lập tức mà không cần
đồng bộ hóa bộ đệm bẩn của nó.

Lưu ý:
  khi một chương trình (như domu) có bàn phím ở dạng 'thô'
  chế độ này, ctrl-alt-del bị chương trình chặn trước nó
  có bao giờ chạm đến lớp tty kernel và tùy thuộc vào chương trình
  để quyết định phải làm gì với nó.


dmesg_restrict
==============

Chuyển đổi này cho biết liệu người dùng không có đặc quyền có bị ngăn chặn hay không
từ việc sử dụng ZZ0000ZZ để xem tin nhắn từ nhật ký của kernel
bộ đệm.
Khi ZZ0001ZZ được đặt thành 0 thì không có hạn chế nào.
Khi ZZ0002ZZ được đặt thành 1, người dùng phải có
ZZ0003ZZ để sử dụng ZZ0004ZZ.

Tùy chọn cấu hình kernel ZZ0000ZZ đặt
giá trị mặc định của ZZ0001ZZ.


tên miền và tên máy chủ
=====================

Những tệp này có thể được sử dụng để đặt tên miền NIS/YP và
tên máy chủ của hộp của bạn giống hệt như các lệnh
tên miền và tên máy chủ, tức là::

# echo "darkstar" > /proc/sys/kernel/tên máy chủ
	# echo "mydomain" > /proc/sys/kernel/domainname

có tác dụng tương tự như::

# hostname "sao đen"
	# domainname "tên miền của tôi"

Tuy nhiên, hãy lưu ý rằng darkstar.frop.org cổ điển có
tên máy chủ "darkstar" và DNS (Máy chủ tên miền Internet)
tên miền "frop.org", đừng nhầm lẫn với NIS (Mạng
Dịch vụ thông tin) hoặc tên miền YP (Trang vàng). Hai cái này
tên miền nói chung là khác nhau. Để thảo luận chi tiết
xem trang man ZZ0000ZZ.


firmware_config
===============

Xem Tài liệu/driver-api/firmware/fallback-mechanisms.rst.

Các mục trong thư mục này cho phép trình trợ giúp tải chương trình cơ sở
dự phòng cần được kiểm soát:

* ZZ0000ZZ, khi được đặt thành 1, buộc phải sử dụng
  dự phòng;
* ZZ0001ZZ, khi được đặt thành 1, sẽ bỏ qua mọi dự phòng.


ftrace_dump_on_oops
===================

Xác định xem có nên gọi ZZ0000ZZ trong trường hợp rất tiếc (hoặc
hạt nhân hoảng loạn). Điều này sẽ xuất nội dung của bộ đệm ftrace thành
bảng điều khiển.  Điều này rất hữu ích để nắm bắt các dấu vết dẫn đến
gặp sự cố và xuất chúng ra bảng điều khiển nối tiếp.

=======================================================================
0 Đã tắt (mặc định).
1 Kết xuất bộ đệm của tất cả các CPU.
2(orig_cpu) Kết xuất bộ đệm của CPU đã kích hoạt
                        ôi.
<instance> Kết xuất bộ đệm phiên bản cụ thể trên tất cả các CPU.
<instance>=2(orig_cpu) Kết xuất bộ đệm phiên bản cụ thể trên CPU
                        điều đó đã gây ra lỗi rất tiếc.
=======================================================================

Kết xuất nhiều phiên bản cũng được hỗ trợ và các phiên bản được tách riêng
bằng dấu phẩy. Nếu bộ đệm chung cũng cần được kết xuất, vui lòng chỉ định
chế độ kết xuất (1/2/orig_cpu) đầu tiên cho bộ đệm chung.

Vì vậy, ví dụ để kết xuất bộ đệm phiên bản "foo" và "bar" trên tất cả các CPU,
người dùng có thể::

echo "foo,bar" > /proc/sys/kernel/ftrace_dump_on_oops

Để kết xuất bộ đệm chung và bộ đệm cá thể "foo" trên tất cả
CPU cùng với bộ đệm phiên bản "bar" trên CPU đã kích hoạt
Rất tiếc, người dùng có thể::

echo "1,foo,bar=2" > /proc/sys/kernel/ftrace_dump_on_oops

ftrace_enabled, stack_tracer_enabled
====================================

Xem Tài liệu/trace/ftrace.rst.


hardlockup_all_cpu_backtrace
============================

Giá trị này kiểm soát hoạt động của trình phát hiện khóa cứng khi một khóa cứng
tình trạng khóa được phát hiện để biết có nên thu thập thêm hay không
thông tin gỡ lỗi. Nếu được bật, tính năng kết xuất ngăn xếp tất cả CPU dành riêng cho Arch
sẽ được khởi xướng.

= ================================================
0 Không làm gì cả. Đây là hành vi mặc định.
1 Khi phát hiện, nắm bắt thêm thông tin gỡ lỗi.
= ================================================


hardlockup_panic
================

Tham số này có thể được sử dụng để kiểm soát xem kernel có bị hoảng loạn hay không
khi phát hiện khóa cứng.

= ==============================
0 Đừng hoảng sợ khi bị khóa cứng.
1 Hoảng loạn về việc khóa cứng.
= ==============================

Xem Tài liệu/admin-guide/lockup-watchdogs.rst để biết thêm thông tin.
Điều này cũng có thể được thiết lập bằng tham số kernel nmi_watchdog.


phích cắm nóng
=======

Đường dẫn cho tác nhân chính sách hotplug.
Giá trị mặc định là ZZ0000ZZ, do đó giá trị mặc định
vào chuỗi trống.

Tệp này chỉ tồn tại khi ZZ0000ZZ được bật. Hầu hết
các hệ thống hiện đại chỉ dựa vào nguồn sự kiện dựa trên liên kết mạng và
không cần cái này


hung_task_all_cpu_backtrace
===========================

Nếu tùy chọn này được đặt, kernel sẽ gửi NMI tới tất cả các CPU để kết xuất
dấu vết của chúng khi phát hiện một tác vụ bị treo. Tập tin này xuất hiện nếu
CONFIG_DETECT_HUNG_TASK và CONFIG_SMP được bật.

0: Sẽ không hiển thị tất cả các dấu vết quay lại của CPU khi phát hiện tác vụ bị treo.
Đây là hành vi mặc định.

1: Sẽ làm gián đoạn tất cả các CPU và xóa dấu vết của chúng một cách không thể che giấu khi
một nhiệm vụ bị treo được phát hiện.


hung_task_panic
===============

Khi được đặt thành giá trị khác 0, kernel hoảng loạn sẽ được kích hoạt nếu
số tác vụ bị treo được tìm thấy trong một lần quét đạt đến giá trị này.
Tệp này hiển thị nếu ZZ0000ZZ được bật.

= ============================================================
0 Tiếp tục hoạt động. Đây là hành vi mặc định.
N Hoảng sợ khi tìm thấy N tác vụ treo trong một lần quét.
= ============================================================


hung_task_check_count
=====================

Giới hạn trên của số lượng nhiệm vụ được kiểm tra.
Tệp này hiển thị nếu ZZ0000ZZ được bật.


hung_task_Detect_count
======================

Cho biết tổng số tác vụ đã được phát hiện là bị treo kể từ khi
hệ thống khởi động hoặc do bộ đếm được đặt lại. Bộ đếm về 0 khi
giá trị 0 được viết.

Tệp này hiển thị nếu ZZ0000ZZ được bật.

hung_task_sys_info
==================
Một danh sách thông tin hệ thống bổ sung được phân tách bằng dấu phẩy sẽ được kết xuất khi
tác vụ treo được phát hiện, ví dụ: "tác vụ,mem,bộ tính giờ,khóa,...".
Tham khảo phần 'panic_sys_info' bên dưới để biết thêm chi tiết.

hung_task_timeout_secs
======================

Khi một tác vụ ở trạng thái D không được lên lịch
nếu nhiều hơn giá trị này, hãy báo cáo một cảnh báo.
Tệp này hiển thị nếu ZZ0000ZZ được bật.

0 có nghĩa là hết thời gian chờ vô hạn, không thực hiện kiểm tra.

Các giá trị có thể đặt nằm trong phạm vi {0:ZZ0000ZZ/ZZ0001ZZ}.


hung_task_check_interval_secs
=============================

Khoảng thời gian kiểm tra nhiệm vụ Hùng. Nếu việc kiểm tra tác vụ bị treo được bật
(xem ZZ0002ZZ), việc kiểm tra được thực hiện mỗi
ZZ0000ZZ giây.
Tệp này hiển thị nếu ZZ0001ZZ được bật.

0 (mặc định) nghĩa là sử dụng ZZ0000ZZ để kiểm tra
khoảng.

Các giá trị có thể đặt nằm trong phạm vi {0:ZZ0000ZZ/ZZ0001ZZ}.


hung_task_warnings
==================

Số lượng cảnh báo tối đa cần báo cáo. Trong khoảng thời gian kiểm tra
nếu phát hiện tác vụ bị treo, giá trị này sẽ giảm đi 1.
Khi giá trị này đạt tới 0, sẽ không có cảnh báo nào được báo cáo nữa.
Tệp này hiển thị nếu ZZ0000ZZ được bật.

-1: báo cáo vô số cảnh báo.


hyperv_record_panic_msg
=======================

Kiểm soát xem dữ liệu kmsg hoảng loạn có được báo cáo cho Hyper-V hay không.

= ==============================================================
0 Đừng báo cáo dữ liệu kmsg hoảng loạn.
1 Báo cáo dữ liệu kmsg hoảng loạn. Đây là hành vi mặc định.
= ==============================================================


bỏ qua-unaligned-usertrap
=========================

Trên các kiến trúc nơi các truy cập không được căn chỉnh gây ra bẫy và nơi điều này
tính năng được hỗ trợ (ZZ0000ZZ;
hiện tại, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ), kiểm soát xem tất cả
bẫy không được căn chỉnh được ghi lại.

= ===================================================================
0 Ghi nhật ký tất cả các truy cập chưa được căn chỉnh.
1 Chỉ cảnh báo lần đầu tiên có bẫy quá trình. Đây là mặc định
  thiết lập.
= ===================================================================

Xem thêm ZZ0000ZZ.

io_uring_disabled
=================

Ngăn chặn tất cả các quy trình tạo phiên bản io_uring mới. Kích hoạt tính năng này
thu nhỏ bề mặt tấn công của kernel.

= ============================================================================
0 Tất cả các tiến trình có thể tạo phiên bản io_uring như bình thường. Đây là
  cài đặt mặc định.
1 quá trình tạo io_uring bị vô hiệu hóa (io_uring_setup() sẽ thất bại với
  -EPERM) cho các quy trình không có đặc quyền không thuộc nhóm io_uring_group.
  Các phiên bản io_uring hiện tại vẫn có thể được sử dụng.  Xem
  tài liệu cho io_uring_group để biết thêm thông tin.
2 io_uring việc tạo bị vô hiệu hóa đối với tất cả các quy trình. io_uring_setup()
  luôn thất bại với -EPERM. Các phiên bản io_uring hiện tại vẫn có thể được
  đã sử dụng.
= ============================================================================


io_uring_group
==============

Khi io_uring_disabled được đặt thành 1, một quy trình phải được
đặc quyền (CAP_SYS_ADMIN) hoặc thuộc nhóm io_uring_group theo thứ tự
để tạo một phiên bản io_uring.  Nếu io_uring_group được đặt thành -1 (
mặc định), chỉ các tiến trình có khả năng CAP_SYS_ADMIN mới có thể tạo
io_uring trường hợp.


kernel_sys_info
===============
Một danh sách thông tin hệ thống bổ sung được phân tách bằng dấu phẩy sẽ được kết xuất khi
phát hiện khóa mềm/cứng, ví dụ: "tác vụ, bộ nhớ, bộ hẹn giờ, khóa,...".
Tham khảo phần 'panic_sys_info' bên dưới để biết thêm chi tiết.

Nó đóng vai trò là núm điều khiển kernel mặc định, sẽ có hiệu lực
khi mô-đun hạt nhân gọi sys_info() với tham số==0.

kexec_load_disabled
===================

Một nút chuyển đổi cho biết liệu các tòa nhà có ZZ0000ZZ và
ZZ0001ZZ đã bị vô hiệu hóa.
Giá trị này mặc định là 0 (sai: đã bật ZZ0002ZZ), nhưng có thể
được đặt thành 1 (đúng: ZZ0003ZZ bị tắt).
Khi đúng, kexec không thể được sử dụng nữa và không thể đặt nút chuyển đổi
trở lại sai.
Điều này cho phép tải hình ảnh kexec trước khi tắt syscall,
cho phép một hệ thống thiết lập (và sau này sử dụng) một hình ảnh mà không cần
bị thay đổi.
Thường được sử dụng cùng với sysctl ZZ0004ZZ.

kexec_load_limit_panic
======================

Tham số này chỉ định giới hạn số lần các cuộc gọi hệ thống
ZZ0000ZZ và ZZ0001ZZ có thể được gọi khi gặp sự cố
hình ảnh. Nó chỉ có thể được đặt với giá trị hạn chế hơn giá trị
cái hiện tại.

============================================================
-1 Cuộc gọi không giới hạn tới kexec. Đây là cài đặt mặc định.
N Số lượng cuộc gọi còn lại.
============================================================

kexec_load_limit_reboot
=======================

Chức năng tương tự như ZZ0000ZZ, nhưng đối với phiên bản bình thường
hình ảnh.

kptr_restrict
=============

Chuyển đổi này cho biết liệu các hạn chế có được đặt trên
hiển thị địa chỉ kernel thông qua ZZ0000ZZ và các giao diện khác.

Khi ZZ0000ZZ được đặt thành 0 (mặc định), địa chỉ sẽ được băm
trước khi in.
(Điều này tương đương với %p.)

Khi ZZ0000ZZ được đặt thành 1, con trỏ hạt nhân được in bằng cách sử dụng
Công cụ xác định định dạng %pK sẽ được thay thế bằng 0 trừ khi người dùng có
ZZ0001ZZ và id người dùng và nhóm hiệu quả bằng với id thực
id.
Điều này là do việc kiểm tra %pK được thực hiện tại thời điểm read() thay vì open()
thời gian, vì vậy nếu quyền được nâng lên giữa open() và read()
(ví dụ: thông qua tệp nhị phân setuid) thì %pK sẽ không rò rỉ con trỏ kernel tới
người dùng không có đặc quyền.
Lưu ý, đây chỉ là giải pháp tạm thời.
Giải pháp dài hạn chính xác là thực hiện kiểm tra quyền tại
thời gian mở().
Hãy cân nhắc việc xóa quyền đọc thế giới khỏi các tệp sử dụng %pK và
sử dụng ZZ0003ZZ để bảo vệ khỏi việc sử dụng %pK trong ZZ0002ZZ
nếu việc rò rỉ các giá trị con trỏ kernel cho người dùng không có đặc quyền là điều đáng lo ngại.

Khi ZZ0000ZZ được đặt thành 2, con trỏ hạt nhân được in bằng cách sử dụng
%pK sẽ được thay thế bằng 0 bất kể đặc quyền.

Để vô hiệu hóa sớm các hạn chế bảo mật này khi khởi động (và một khi
cho tất cả), thay vào đó hãy sử dụng tham số khởi động ZZ0000ZZ.

softlockup_sys_info & hardlockup_sys_info
=========================================
Một danh sách thông tin hệ thống bổ sung được phân tách bằng dấu phẩy sẽ được kết xuất khi
phát hiện khóa mềm/cứng, ví dụ: "tác vụ, bộ nhớ, bộ hẹn giờ, khóa,...".
Tham khảo phần 'panic_sys_info' bên dưới để biết thêm chi tiết.

máy dò mod
========

Đường dẫn đầy đủ đến trình trợ giúp usermode để tự động tải các mô-đun hạt nhân,
theo mặc định là ZZ0000ZZ, do đó được mặc định là
"/sbin/modprobe".  Mã nhị phân này được thực thi khi kernel yêu cầu một
mô-đun.  Ví dụ: nếu không gian người dùng vượt qua loại hệ thống tệp không xác định
tới mount() thì kernel sẽ tự động yêu cầu
mô-đun hệ thống tập tin tương ứng bằng cách thực thi trình trợ giúp mã người dùng này.
Trình trợ giúp mã người dùng này sẽ chèn mô-đun cần thiết vào kernel.

Sysctl này chỉ ảnh hưởng đến việc tự động tải mô-đun.  Nó không có tác dụng gì đối với
khả năng chèn các mô-đun một cách rõ ràng.

Sysctl này có thể được sử dụng để gỡ lỗi các yêu cầu tải mô-đun ::

tiếng vang '#! /bin/sh' > /tmp/modprobe
    echo 'echo "$@" >> /tmp/modprobe.log' >> /tmp/modprobe
    echo 'exec /sbin/modprobe "$@"' >> /tmp/modprobe
    chmod a+x /tmp/modprobe
    echo /tmp/modprobe > /proc/sys/kernel/modprobe

Ngoài ra, nếu sysctl này được đặt thành chuỗi trống thì module
tính năng tự động tải bị vô hiệu hóa hoàn toàn.  Hạt nhân sẽ không cố gắng
thực thi một trình trợ giúp usermode nào cả, nó cũng sẽ không gọi
kernel_module_request Móc LSM.

Nếu CONFIG_STATIC_USERMODEHELPER=y được đặt trong cấu hình kernel,
sau đó trình trợ giúp chế độ người dùng tĩnh được định cấu hình sẽ ghi đè sysctl này,
ngoại trừ chuỗi trống vẫn được chấp nhận để vô hiệu hóa hoàn toàn
tự động tải mô-đun như mô tả ở trên.

module_disabled
================

Giá trị chuyển đổi cho biết liệu mô-đun có được phép tải hay không
trong một hạt nhân mô-đun khác.  Nút chuyển đổi này mặc định tắt
(0), nhưng có thể được đặt đúng (1).  Khi đúng, các mô-đun có thể được
không được tải cũng như không được tải và không thể đặt lại nút chuyển đổi
thành sai.  Thường được sử dụng với nút chuyển đổi ZZ0000ZZ.


.. _msgmni:

msgmax, msgmnb và msgmni
==========================

ZZ0000ZZ là kích thước tối đa của tin nhắn IPC, tính bằng byte. 8192 bởi
mặc định (ZZ0001ZZ).

ZZ0000ZZ là kích thước tối đa của hàng đợi IPC, tính bằng byte. 16384 bởi
mặc định (ZZ0001ZZ).

ZZ0000ZZ là số lượng hàng đợi IPC tối đa. 32000 theo mặc định
(ZZ0001ZZ).

Tất cả các tham số này được đặt cho mỗi không gian tên ipc. Số byte tối đa
trong hàng đợi tin nhắn POSIX bị giới hạn bởi ZZ0000ZZ. Giới hạn này là
được tôn trọng theo thứ bậc trong không gian tên của mỗi người dùng.

msg_next_id, sem_next_id và shm_next_id (Hệ thống V IPC)
========================================================

Ba nút chuyển đổi này cho phép chỉ định id mong muốn cho IPC được phân bổ tiếp theo
đối tượng: tin nhắn, semaphore hoặc bộ nhớ dùng chung tương ứng.

Theo mặc định, chúng bằng -1, có nghĩa là logic phân bổ chung.
Các giá trị có thể đặt nằm trong phạm vi {0:ZZ0000ZZ}.

Ghi chú:
  1) kernel không đảm bảo, đối tượng mới đó sẽ có id mong muốn. Vì vậy,
     tùy thuộc vào không gian người dùng, cách xử lý một đối tượng có id "sai".
  2) Chuyển đổi với giá trị không mặc định sẽ được kernel đặt lại về -1 sau
     phân bổ đối tượng IPC thành công. Nếu một tòa nhà phân bổ đối tượng IPC
     không thành công, nó sẽ không được xác định nếu giá trị vẫn chưa được sửa đổi hoặc được đặt lại về -1.


nggroup_max
===========

Số lượng nhóm bổ sung tối đa, _tức là kích thước tối đa mà
ZZ0000ZZ sẽ chấp nhận. Xuất ZZ0001ZZ từ kernel.



nmi_watchdog
============

Tham số này có thể được sử dụng để điều khiển cơ quan giám sát NMI
(tức là trình phát hiện khóa cứng) trên hệ thống x86.

= ====================================
0 Tắt trình phát hiện khóa cứng.
1 Kích hoạt trình phát hiện khóa cứng.
= ====================================

Trình phát hiện khóa cứng giám sát từng CPU về khả năng đáp ứng với
bộ đếm thời gian bị gián đoạn. Cơ chế sử dụng các thanh ghi bộ đếm hiệu suất CPU
được lập trình để tạo ra các ngắt không thể che giấu (NMI) theo định kỳ
trong khi CPU đang bận. Do đó, tên thay thế là 'cơ quan giám sát NMI'.

Cơ quan giám sát NMI bị tắt theo mặc định nếu kernel đang chạy với tư cách khách
trong máy ảo KVM. Mặc định này có thể được ghi đè bằng cách thêm::

nmi_watchdog=1

vào dòng lệnh kernel khách (xem
Tài liệu/admin-guide/kernel-parameters.rst).


nmi_wd_lpm_factor (chỉ PPC)
============================

Hệ số áp dụng cho thời gian chờ của cơ quan giám sát NMI (chỉ khi ZZ0000ZZ được
đặt thành 1). Yếu tố này thể hiện tỷ lệ phần trăm được thêm vào
ZZ0001ZZ khi tính toán thời gian chờ của cơ quan giám sát NMI trong một
LPM. Thời gian chờ khóa mềm không bị ảnh hưởng.

Giá trị 0 có nghĩa là không có thay đổi. Giá trị mặc định là 200 nghĩa là NMI
cơ quan giám sát được đặt thành 30 giây (dựa trên ZZ0000ZZ bằng 10).


số_cân bằng
==============

Bật/tắt và định cấu hình bộ nhớ NUMA dựa trên lỗi trang tự động
cân bằng.  Bộ nhớ được tự động di chuyển đến các nút thường xuyên truy cập vào nó.
Giá trị cần đặt có thể là kết quả của việc ORing như sau:

= ====================================
0 NUMA_BALANCING_DISABLED
1 NUMA_BALANCING_NORMAL
2 NUMA_BALANCING_MEMORY_TIERING
= ====================================

Hoặc NUMA_BALANCING_NORMAL để tối ưu hóa vị trí trang giữa các trang khác nhau
Các nút NUMA để giảm khả năng truy cập từ xa.  Trên máy NUMA, có một
hình phạt về hiệu suất nếu bộ nhớ từ xa được truy cập bởi CPU. Khi điều này
tính năng được kích hoạt các mẫu hạt nhân mà luồng tác vụ đang truy cập
bộ nhớ bằng cách định kỳ hủy ánh xạ các trang và sau đó bẫy một trang
lỗi. Tại thời điểm xảy ra lỗi trang, nó được xác định xem dữ liệu có
đang được truy cập nên được di chuyển đến một nút bộ nhớ cục bộ.

Việc hủy ánh xạ các trang và lỗi bẫy sẽ phát sinh thêm chi phí
lý tưởng nhất là được bù đắp bằng vị trí bộ nhớ được cải thiện nhưng không có phổ quát
đảm bảo. Nếu khối lượng công việc mục tiêu đã được liên kết với các nút NUMA thì điều này
tính năng nên bị vô hiệu hóa.

Hoặc NUMA_BALANCING_MEMORY_TIERING để tối ưu hóa vị trí trang giữa
các loại bộ nhớ khác nhau (được biểu thị dưới dạng các nút NUMA khác nhau) để
đặt các trang nóng vào bộ nhớ nhanh.  Việc này được thực hiện dựa trên
unmapping và lỗi trang quá.

numa_balancing_promote_rate_limit_MBps
======================================

Thông lượng thăng cấp/xuống cấp quá cao giữa các loại bộ nhớ khác nhau
có thể ảnh hưởng đến độ trễ của ứng dụng.  Điều này có thể được sử dụng để đánh giá giới hạn
thông lượng khuyến mãi.  Thông lượng quảng bá tối đa trên mỗi nút tính bằng MB/s
sẽ bị giới hạn không quá giá trị đã đặt.

Nguyên tắc chung là đặt giá trị này nhỏ hơn 1/10 của nút PMEM
băng thông ghi.

oops_all_cpu_backtrace
======================

Nếu tùy chọn này được đặt, kernel sẽ gửi NMI tới tất cả các CPU để kết xuất
dấu vết của họ khi một sự kiện rất tiếc xảy ra. Nó nên được sử dụng như là cuối cùng
sử dụng biện pháp phòng ngừa trong trường hợp không thể kích hoạt sự hoảng loạn (để bảo vệ các máy ảo đang chạy, ví dụ:
example) hoặc kdump không thể được thu thập. Tập tin này hiển thị nếu CONFIG_SMP
được kích hoạt.

0: Sẽ không hiển thị tất cả các dấu vết quay lại của CPU khi phát hiện thấy lỗi.
Đây là hành vi mặc định.

1: Sẽ làm gián đoạn tất cả các CPU và xóa dấu vết của chúng một cách không thể che giấu khi
một sự kiện rất tiếc được phát hiện.


rất tiếc_giới hạn
==========

Số lượng kernel bị lỗi sau đó kernel sẽ hoảng sợ khi
ZZ0000ZZ chưa được đặt. Đặt giá trị này thành 0 sẽ vô hiệu hóa việc kiểm tra
số đếm. Đặt giá trị này thành 1 có tác dụng tương tự như cài đặt
ZZ0001ZZ. Giá trị mặc định là 10000.


osrelease, ostype & phiên bản
===========================

::

# cat phát hành hệ điều hành
  2.1.88
  Kiểu # cat
  Linux
  Phiên bản # cat
  #5 Thứ Tư ngày 25 tháng 2 21:49:24 MET 1998

Các tệp ZZ0000ZZ và ZZ0001ZZ phải đủ rõ ràng.
ZZ0002ZZ
tuy nhiên cần làm rõ hơn một chút. '#5' có nghĩa là
đây là hạt nhân thứ năm được xây dựng từ cơ sở nguồn này và
ngày đằng sau nó cho biết thời gian kernel được xây dựng.
Cách duy nhất để điều chỉnh các giá trị này là xây dựng lại kernel :-)


tràn & tràn
=========================

nếu kiến trúc của bạn không phải lúc nào cũng hỗ trợ UID 32 bit (tức là cánh tay,
i386, m68k, sh và sparc32), UID và GID cố định sẽ được trả lại cho
các ứng dụng sử dụng lệnh gọi hệ thống UID/GID 16-bit cũ, nếu
UID hoặc GID thực tế sẽ vượt quá 65535.

Các sysctls này cho phép bạn thay đổi giá trị của UID và GID cố định.
Mặc định là 65534.


hoảng loạn
=====

Giá trị trong tệp này xác định hành vi của kernel trên
hoảng sợ:

* nếu bằng 0, kernel sẽ lặp mãi mãi;
* nếu âm tính, kernel sẽ khởi động lại ngay lập tức;
* nếu dương thì kernel sẽ khởi động lại sau số tương ứng
  giây.

Khi bạn sử dụng cơ quan giám sát phần mềm, cài đặt được khuyến nghị là 60.


hoảng sợ_on_io_nmi
===============

Kiểm soát hành vi của kernel khi CPU nhận được NMI do
một lỗi IO.

= =======================================================================
0 Cố gắng tiếp tục hoạt động (mặc định).
1 Hoảng loạn ngay lập tức. Lỗi IO đã kích hoạt NMI. Điều này cho thấy một
  tình trạng hệ thống nghiêm trọng có thể dẫn đến hỏng dữ liệu IO.
  Thay vì tiếp tục, hoảng sợ có thể là lựa chọn tốt hơn. Một số
  máy chủ phát hành loại NMI này khi nhấn nút kết xuất,
  và bạn có thể sử dụng tùy chọn này để thực hiện kết xuất sự cố.
= =======================================================================


hoảng_on_oops
=============

Kiểm soát hành vi của kernel khi gặp lỗi rất tiếc hoặc BUG.

= =========================================================================
0 Cố gắng tiếp tục hoạt động.
1 Hoảng loạn ngay lập tức.  Nếu sysctl ZZ0000ZZ cũng khác 0 thì
  máy sẽ được khởi động lại.
= =========================================================================


hoảng loạn_on_stackoverflow
======================

Kiểm soát hành vi của kernel khi phát hiện sự tràn của
kernel, IRQ và các ngăn xếp ngoại lệ ngoại trừ ngăn xếp người dùng.
Tệp này hiển thị nếu ZZ0000ZZ được bật.

= ============================
0 Cố gắng tiếp tục hoạt động.
1 Hoảng loạn ngay lập tức.
= ============================


hoảng sợ_on_unrecovered_nmi
========================

Hành vi Linux mặc định trên NMI có bộ nhớ hoặc không xác định là
để tiếp tục hoạt động. Đối với nhiều môi trường như khoa học
tính toán thì tốt nhất là lấy hộp ra và lỗi
được xử lý hơn là lỗi chẵn lẻ/ECC chưa được sửa sẽ được lan truyền.

Một số ít hệ thống tạo ra NMI vì những lý do ngẫu nhiên kỳ lạ
chẳng hạn như quản lý năng lượng nên mặc định là tắt. sysctl đó hoạt động như thế nào
các biện pháp kiểm soát hoảng loạn hiện có đã có trong thư mục đó.


hoảng loạn_on_warn
=============

Gọi Panic() trong đường dẫn WARN() khi được đặt thành 1. Điều này rất hữu ích để tránh
xây dựng lại kernel khi cố gắng kdump tại vị trí của WARN().

= ====================================================
0 Chỉ WARN(), hoạt động mặc định.
1 Gọi Panic() sau khi in ra vị trí WARN().
= ====================================================


hoảng loạn
===========

Bitmask để in thông tin hệ thống khi hoảng loạn xảy ra. Người dùng có thể chọn
sự kết hợp của các bit sau:

===== =================================================
bit 0 in tất cả thông tin nhiệm vụ
bit 1 in thông tin bộ nhớ hệ thống
thông tin về bộ đếm thời gian in bit 2
thông tin khóa in bit 3 nếu ZZ0000ZZ được bật
bộ đệm in ftrace bit 4
bit 5 phát lại tất cả các thông báo kernel trên bảng điều khiển khi hết hoảng loạn
bit 6 in tất cả các dấu vết ngược lại của CPU (nếu có trong vòm)
bit 7 chỉ in các tác vụ ở trạng thái không bị gián đoạn (bị chặn)
===== =================================================

Vì vậy, ví dụ để in các tác vụ và thông tin bộ nhớ trong tình trạng hoảng loạn, người dùng có thể::

echo 3 > /proc/sys/kernel/panic_print


hoảng_sys_info
==============

Một danh sách thông tin bổ sung được phân tách bằng dấu phẩy sẽ được đưa ra khi hoảng loạn,
ví dụ: "tác vụ, bộ nhớ, bộ hẹn giờ,...".  Nó là một sự thay thế có thể đọc được của con người
thành 'hoảng loạn_print'. Các giá trị có thể là:

======================================================================
nhiệm vụ in tất cả thông tin nhiệm vụ
thông tin bộ nhớ hệ thống in mem
hẹn giờ in thông tin hẹn giờ
khóa in khóa thông tin nếu CONFIG_LOCKDEP được bật
bộ đệm ftrace in ftrace
all_bt in tất cả các dấu vết ngược của CPU (nếu có trong vòm)
bblock_tasks chỉ in các tác vụ ở trạng thái không bị gián đoạn (bị chặn)
======================================================================


hoảng loạn_on_rcu_stall
==================

Khi được đặt thành 1, sẽ gọi hoảng loạn() sau thông báo phát hiện RCU ngừng hoạt động. Cái này
rất hữu ích để xác định nguyên nhân gốc rễ của việc RCU bị treo bằng vmcore.

= =================================================================
0 Đừng hoảng sợ() khi RCU ngừng hoạt động, hành vi mặc định.
1 hoảng loạn() sau khi in thông báo dừng RCU.
= =================================================================

max_rcu_stall_to_panic
======================

Khi ZZ0000ZZ được đặt thành 1, giá trị này sẽ xác định
số lần RCU có thể dừng lại trước khi gọi hoảng loạn().

Khi ZZ0000ZZ được đặt thành 0, giá trị này không có hiệu lực.

perf_cpu_time_max_percent
=========================

Gợi ý cho kernel về thời gian CPU được phép sử dụng
sử dụng để xử lý các sự kiện lấy mẫu hoàn hảo.  Nếu hệ thống con hoàn hảo
được thông báo rằng các mẫu của nó vượt quá giới hạn này, nó
sẽ giảm tần số lấy mẫu để cố gắng giảm CPU của nó
cách sử dụng.

Một số mẫu hoàn hảo xảy ra trong NMI.  Nếu những mẫu này
bất ngờ mất quá nhiều thời gian để thực thi, NMI có thể trở thành
xếp chồng lên nhau nhiều đến mức không có gì khác
được phép thi hành.

==================================================================
0 Vô hiệu hóa cơ chế.  Không theo dõi hoặc chỉnh sửa phần trình diễn
      tốc độ lấy mẫu bất kể thời gian CPU mất bao lâu.

1-100 Cố gắng điều chỉnh tốc độ lấy mẫu của phần trình diễn ở mức này
      tỷ lệ phần trăm của CPU.  Lưu ý: kernel tính toán một
      độ dài "dự kiến" của mỗi sự kiện mẫu.  100 ở đây có nghĩa là
      100% độ dài dự kiến đó.  Ngay cả khi điều này được đặt thành
      100, bạn vẫn có thể thấy điều tiết mẫu nếu điều này
      vượt quá chiều dài.  Đặt thành 0 nếu bạn thực sự không quan tâm
      bao nhiêu CPU được tiêu thụ.
==================================================================


perf_event_paranoid
===================

Kiểm soát việc sử dụng hệ thống sự kiện biểu diễn của những người không có đặc quyền
người dùng (không có CAP_PERFMON).  Giá trị mặc định là 2.

Vì lý do tương thích ngược, quyền truy cập vào hiệu suất hệ thống
khả năng giám sát và quan sát vẫn mở cho CAP_SYS_ADMIN
các quy trình đặc quyền nhưng sử dụng CAP_SYS_ADMIN cho hệ thống an toàn
hoạt động giám sát hiệu suất và khả năng quan sát không được khuyến khích
đối với các trường hợp sử dụng CAP_PERFMON.

=== ========================================================================
 -1 Cho phép tất cả người dùng sử dụng (gần như) tất cả các sự kiện.

Bỏ qua giới hạn mlock sau perf_event_mlock_kb mà không có
     ZZ0000ZZ.

>=0 Không cho phép người dùng theo dõi chức năng ftrace mà không có
     ZZ0000ZZ.

Không cho phép người dùng truy cập điểm theo dõi thô mà không có ZZ0000ZZ.

>=1 Không cho phép người dùng không có ZZ0000ZZ truy cập sự kiện CPU.

>=2 Không cho phép người dùng không có ZZ0000ZZ lập hồ sơ kernel.
=== ========================================================================


perf_event_max_stack
====================

Ví dụ: kiểm soát số lượng khung ngăn xếp tối đa để sao chép cho các sự kiện được định cấu hình (ZZ0000ZZ), khi sử dụng
'ZZ0001ZZ' hoặc 'ZZ0002ZZ'.

Điều này chỉ có thể được thực hiện khi không có sự kiện nào có chuỗi cuộc gọi được sử dụng
được bật, nếu không việc ghi vào tệp này sẽ trả về ZZ0000ZZ.

Giá trị mặc định là 127.


perf_event_mlock_kb
===================

Kích thước kiểm soát của bộ đệm vòng trên mỗi CPU không được tính vào giới hạn mlock.

Giá trị mặc định là 512 + 1 trang


perf_event_max_contexts_per_stack
=================================

Kiểm soát số lượng mục nhập ngữ cảnh khung ngăn xếp tối đa cho
(ZZ0000ZZ) sự kiện được định cấu hình, dành cho
Ví dụ: khi sử dụng 'ZZ0001ZZ' hoặc 'ZZ0002ZZ'.

Điều này chỉ có thể được thực hiện khi không có sự kiện nào có chuỗi cuộc gọi được sử dụng
được bật, nếu không việc ghi vào tệp này sẽ trả về ZZ0000ZZ.

Giá trị mặc định là 8.


perf_user_access (chỉ arm64 và riscv)
=======================================

Kiểm soát quyền truy cập không gian của người dùng để đọc bộ đếm sự kiện hoàn hảo.

* cho cánh tay64
  Giá trị mặc định là 0 (quyền truy cập bị vô hiệu hóa).

Khi được đặt thành 1, không gian người dùng có thể đọc các thanh ghi bộ đếm theo dõi hiệu suất
  trực tiếp.

Xem Tài liệu/arch/arm64/perf.rst để biết thêm thông tin.

* cho riscv
  Khi được đặt thành 0, quyền truy cập không gian người dùng sẽ bị tắt.

Giá trị mặc định là 1, không gian người dùng có thể đọc bộ đếm giám sát hiệu suất
  đăng ký thông qua perf, mọi truy cập trực tiếp mà không có sự can thiệp của perf sẽ kích hoạt
  một hướng dẫn bất hợp pháp.

Khi được đặt thành 2, chế độ này sẽ bật chế độ kế thừa (không gian người dùng có quyền truy cập trực tiếp vào chu kỳ
  và chỉ chèn CSR). Lưu ý rằng giá trị kế thừa này không được dùng nữa và sẽ
  bị xóa sau khi tất cả các ứng dụng không gian người dùng được khắc phục.

Lưu ý rằng thời gian CSR luôn có thể truy cập trực tiếp vào tất cả các chế độ.

pid_max
=======

Giá trị gói phân bổ PID.  Khi giá trị PID tiếp theo của kernel
đạt đến giá trị này thì nó sẽ quay trở lại giá trị PID tối thiểu.
PID có giá trị ZZ0000ZZ hoặc lớn hơn không được phân bổ.


ns_last_pid
===========

pid cuối cùng được phân bổ trong hiện tại (một tác vụ sử dụng sysctl này
sống trong) không gian tên pid. Khi chọn một pid cho tác vụ tiếp theo trên fork
kernel cố gắng phân bổ một số bắt đầu từ số này.


powersave-nap (chỉ PPC)
========================

Nếu được đặt, Linux-PPC sẽ sử dụng chế độ tiết kiệm năng lượng 'ngủ trưa',
nếu không chế độ 'ngủ gật' sẽ được sử dụng.


===================================================================

bản in
======

Bốn giá trị trong printk biểu thị: ZZ0000ZZ,
ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ tương ứng.

Những giá trị này ảnh hưởng đến hành vi printk() khi in hoặc
thông báo lỗi đăng nhập. Xem 'ZZ0000ZZ' để biết thêm thông tin về
các mức log khác nhau.

==================================================================
thông báo console_loglevel có mức độ ưu tiên cao hơn
                         cái này sẽ được in ra bàn điều khiển
thông báo default_message_loglevel không có mức độ ưu tiên rõ ràng
                         sẽ được in với mức độ ưu tiên này
giá trị tối thiểu_console_loglevel tối thiểu (cao nhất) mà
                         console_loglevel có thể được đặt
default_console_loglevel giá trị mặc định cho console_loglevel
==================================================================


printk_delay
============

Trì hoãn mỗi tin nhắn printk tính bằng ZZ0000ZZ mili giây

Giá trị từ 0 - 10000 được cho phép.


printk_ratelimit
================

Một số thông báo cảnh báo bị giới hạn tốc độ. ZZ0000ZZ chỉ định
khoảng thời gian tối thiểu giữa các tin nhắn này (tính bằng giây).
Giá trị mặc định là 5 giây.

Giá trị 0 sẽ vô hiệu hóa giới hạn tốc độ.


printk_ratelimit_burst
======================

Về lâu dài, chúng tôi thực thi một tin nhắn cho mỗi ZZ0001ZZ
giây, chúng tôi cho phép một loạt tin nhắn đi qua.
ZZ0000ZZ chỉ định số lượng tin nhắn chúng tôi có thể
gửi trước khi giới hạn tốc độ bắt đầu. Sau ZZ0002ZZ giây
đã trôi qua, một loạt tin nhắn khác có thể được gửi đi.

Giá trị mặc định là 10 tin nhắn.


printk_devkmsg
==============

Kiểm soát việc ghi nhật ký vào ZZ0000ZZ từ không gian người dùng:

===========================================================
mặc định giới hạn tốc độ, giới hạn tốc độ
khi đăng nhập không giới hạn vào/dev/kmsg từ không gian người dùng
tắt đăng nhập vào/dev/kmsg bị vô hiệu hóa
===========================================================

Tham số dòng lệnh kernel ZZ0000ZZ ghi đè lên điều này và được
cài đặt một lần cho đến lần khởi động lại tiếp theo: một khi đã đặt, nó không thể thay đổi được
giao diện sysctl này nữa.

===================================================================


pty
===

Xem Tài liệu/hệ thống tập tin/devpts.rst.


ngẫu nhiên
======

Đây là một thư mục, với các mục sau:

* ZZ0000ZZ: UUID được tạo trong lần truy xuất đầu tiên và
  không thay đổi sau đó;

* ZZ0000ZZ: UUID được tạo mỗi lần truy xuất (điều này có thể
  do đó được sử dụng để tạo UUID theo ý muốn);

* ZZ0000ZZ: số entropy của nhóm, tính bằng bit;

* ZZ0000ZZ: kích thước nhóm entropy, tính bằng bit;

* ZZ0000ZZ: lỗi thời (dùng để xác định mức tối thiểu
  số giây giữa các lần gieo lại nhóm urandom). Tập tin này là
  có thể ghi vì mục đích tương thích, nhưng việc ghi vào nó không có tác dụng
  về mọi hành vi của RNG;

* ZZ0000ZZ: khi số entropy giảm xuống dưới mức này
  (dưới dạng một số bit), các quá trình đang chờ ghi vào ZZ0001ZZ
  đang thức dậy. Tập tin này có thể ghi được vì mục đích tương thích, nhưng
  việc ghi vào nó không ảnh hưởng đến bất kỳ hành vi nào của RNG.


ngẫu nhiên_va_space
==================

Tùy chọn này có thể được sử dụng để chọn loại địa chỉ quy trình
ngẫu nhiên hóa không gian được sử dụng trong hệ thống, cho kiến trúc
hỗ trợ tính năng này.

== ==================================================================================
0 Tắt ngẫu nhiên không gian địa chỉ quy trình.  Đây là
    mặc định cho các kiến trúc không hỗ trợ tính năng này,
    và các hạt nhân được khởi động bằng tham số "norandmaps".

1 Đặt địa chỉ của trang mmap base, stack và VDSO một cách ngẫu nhiên.
    Điều này, cùng với những điều khác, ngụ ý rằng các thư viện dùng chung sẽ được
    được tải tới các địa chỉ ngẫu nhiên.  Ngoài ra đối với các tệp nhị phân được liên kết với PIE,
    vị trí bắt đầu mã được chọn ngẫu nhiên.  Đây là mặc định nếu
    Tùy chọn ZZ0000ZZ được bật.

2 Ngoài ra còn cho phép ngẫu nhiên hóa đống.  Đây là mặc định nếu
    ZZ0000ZZ bị vô hiệu hóa.

Có một vài ứng dụng kế thừa hiện có (chẳng hạn như một số ứng dụng cổ xưa
    phiên bản libc.so.5 từ năm 1996) giả định rằng khu vực brk bắt đầu
    ngay sau khi kết thúc mã + bss.  Các ứng dụng này bị hỏng khi
    sự bắt đầu của khu vực brk là ngẫu nhiên.  Tuy nhiên không có cái nào được biết
    các ứng dụng không cũ sẽ bị hỏng theo cách này, vì vậy đối với hầu hết
    hệ thống sẽ an toàn khi chọn ngẫu nhiên hoàn toàn.

Các hệ thống có mã nhị phân cũ và/hoặc bị hỏng nên được cấu hình
    với ZZ0000ZZ được kích hoạt, loại trừ vùng heap khỏi quá trình
    ngẫu nhiên hóa không gian địa chỉ.
== ==================================================================================


khởi động lại-cmd (chỉ SPARC)
=======================

??? Đây dường như là một cách để đưa ra lập luận cho Sparc
Bộ tải khởi động ROM/Flash. Có lẽ để bảo nó phải làm gì sau đó
khởi động lại. ???


lịch_energy_aware
==================

Bật/tắt Lập kế hoạch nhận biết năng lượng (EAS). EAS bắt đầu
tự động trên các nền tảng nơi nó có thể chạy (nghĩa là
nền tảng có cấu trúc liên kết CPU không đối xứng và có Năng lượng
Mẫu có sẵn). Nếu nền tảng của bạn đáp ứng được
yêu cầu đối với EAS nhưng bạn không muốn sử dụng nó, hãy thay đổi
giá trị này thành 0. Trên nền tảng Non-EAS, thao tác ghi không thành công và
đọc không trả lại bất cứ điều gì.

task_delaycct
===============

Bật/tắt tính năng tính toán độ trễ nhiệm vụ (xem
Tài liệu/kế toán/delay-accounting.rst. Việc kích hoạt tính năng này sẽ phát sinh
một lượng nhỏ chi phí trong bộ lập lịch nhưng rất hữu ích cho việc gỡ lỗi
và điều chỉnh hiệu suất. Nó được yêu cầu bởi một số công cụ như iotop.

lịch_schedstats
================

Bật/tắt thống kê lịch trình. Kích hoạt tính năng này
phát sinh một lượng nhỏ chi phí trong bộ lập lịch nhưng
hữu ích cho việc gỡ lỗi và điều chỉnh hiệu suất.

lịch_util_clamp_min
====================

Mức sử dụng ZZ0000ZZ tối đa được phép.

Giá trị mặc định là 1024, là giá trị tối đa có thể.

Điều đó có nghĩa là mọi giá trị uclamp.min được yêu cầu không thể lớn hơn
sched_util_clamp_min, tức là nó bị giới hạn trong phạm vi
[0: lịch_util_clamp_min].

lịch_util_clamp_max
====================

Mức sử dụng ZZ0000ZZ tối đa được phép.

Giá trị mặc định là 1024, là giá trị tối đa có thể.

Điều đó có nghĩa là mọi giá trị uclamp.max được yêu cầu không thể lớn hơn
sched_util_clamp_max, tức là nó bị giới hạn trong phạm vi
[0: lịch_util_clamp_max].

lịch_util_clamp_min_rt_default
===============================

Theo mặc định, Linux được điều chỉnh về hiệu suất. Điều đó có nghĩa là tác vụ RT luôn chạy
ở tần số cao nhất và có khả năng cao nhất (công suất cao nhất) CPU (ở
hệ thống không đồng nhất).

Uclamp đạt được điều này bằng cách đặt uclamp.min được yêu cầu của tất cả các tác vụ RT thành
1024 theo mặc định, giúp tăng cường hiệu quả các tác vụ chạy ở mức cao nhất
tần số và định hướng chúng chạy trên CPU lớn nhất.

Núm này cho phép quản trị viên thay đổi hành vi mặc định khi uclamp đang được kích hoạt.
đã sử dụng. Đặc biệt trong các thiết bị chạy bằng pin, chạy ở mức tối đa
công suất và tần số sẽ làm tăng mức tiêu thụ năng lượng và rút ngắn thời gian sử dụng pin
cuộc sống.

Núm này chỉ có hiệu quả đối với các tác vụ RT mà người dùng chưa sửa đổi
đã yêu cầu giá trị uclamp.min thông qua tòa nhà sched_setattr().

Núm này sẽ không thoát khỏi giới hạn phạm vi do sched_util_clamp_min áp đặt
được xác định ở trên.

Ví dụ nếu

lịch_util_clamp_min_rt_default = 800
	lịch_util_clamp_min = 600

Khi đó boost sẽ bị kẹp ở mức 600 vì 800 nằm ngoài mức cho phép
phạm vi [0:600]. Điều này có thể xảy ra chẳng hạn nếu chế độ tiết kiệm năng lượng sẽ
tạm thời hạn chế tất cả các mức tăng bằng cách sửa đổi sched_util_clamp_min. Ngay khi
hạn chế này được dỡ bỏ, sched_util_clamp_min_rt_default được yêu cầu
sẽ có hiệu lực.

seccomp
=======

Xem Tài liệu/userspace-api/seccomp_filter.rst.


sg-buff lớn
===========

Tệp này hiển thị kích thước của bộ đệm SCSI (sg) chung.
Bạn chưa thể điều chỉnh nó ngay bây giờ nhưng bạn có thể thay đổi nó
biên dịch thời gian bằng cách chỉnh sửa ZZ0000ZZ và thay đổi
giá trị của ZZ0001ZZ.

Không có lý do gì để thay đổi giá trị này. Nếu
bạn có thể nghĩ ra một cái, bạn có thể biết bạn muốn gì
dù sao cũng đang làm :)


nhỏ
======

Tham số này đặt tổng số trang bộ nhớ dùng chung có thể được sử dụng
bên trong không gian tên ipc. Việc đếm trang bộ nhớ dùng chung xảy ra cho mỗi ipc
không gian tên riêng biệt và không được kế thừa. Do đó, ZZ0000ZZ phải luôn ở mức
ít nhất là ZZ0001ZZ.

Nếu bạn không chắc chắn ZZ0000ZZ mặc định trên Linux của mình là gì
hệ thống, bạn có thể chạy lệnh sau ::

# getconf PAGE_SIZE

Để giảm hoặc vô hiệu hóa khả năng phân bổ bộ nhớ dùng chung, bạn phải tạo một
không gian tên ipc mới, hãy đặt tham số này thành giá trị được yêu cầu và cấm
việc tạo một không gian tên ipc mới trong không gian tên người dùng hiện tại hoặc các nhóm có thể
được sử dụng.

shmmax
======

Giá trị này có thể được sử dụng để truy vấn và đặt giới hạn thời gian chạy
về kích thước phân đoạn bộ nhớ chia sẻ tối đa có thể được tạo.
Các phân đoạn bộ nhớ dùng chung lên tới 1Gb hiện được hỗ trợ trong
hạt nhân.  Giá trị này mặc định là ZZ0000ZZ.


smmni
======

Giá trị này xác định số lượng phân đoạn bộ nhớ chia sẻ tối đa.
4096 theo mặc định (ZZ0000ZZ).


shm_rmid_forced
===============

Linux cho phép bạn đặt giới hạn tài nguyên, bao gồm cả dung lượng bộ nhớ
quá trình có thể tiêu thụ, thông qua ZZ0000ZZ.  Thật không may, bộ nhớ được chia sẻ
các phân đoạn được phép tồn tại mà không liên kết với bất kỳ quy trình nào và
do đó có thể không được tính vào bất kỳ giới hạn tài nguyên nào.  Nếu được kích hoạt,
các phân đoạn bộ nhớ dùng chung sẽ tự động bị hủy khi chúng được đính kèm
số lượng trở thành 0 sau khi tách ra hoặc chấm dứt quá trình.  Nó sẽ
cũng hủy các phân đoạn đã được tạo nhưng không bao giờ được gắn vào khi thoát
từ quá trình này.  Công dụng duy nhất còn lại của ZZ0001ZZ là ngay lập tức
phá hủy một phân đoạn không được đính kèm.  Tất nhiên, điều này phá vỡ cách mọi thứ diễn ra
được xác định nên một số ứng dụng có thể ngừng hoạt động.  Lưu ý rằng điều này
tính năng này sẽ không có ích gì trừ khi bạn cũng định cấu hình tài nguyên của mình
giới hạn (đặc biệt là ZZ0002ZZ và ZZ0003ZZ).  Hầu hết các hệ thống không
need this.

Lưu ý rằng nếu bạn thay đổi giá trị này từ 0 thành 1 thì các phân đoạn đã được tạo
không có người dùng và có quy trình gốc đã chết sẽ bị phá hủy.


sysctl_writes_strict
====================

Kiểm soát cách vị trí tệp ảnh hưởng đến hành vi cập nhật giá trị sysctl
thông qua giao diện ZZ0000ZZ:

== ============================================================================
  -1 Xử lý giá trị sysctl kế thừa cho mỗi lần ghi, không có cảnh báo printk.
       Mỗi syscall ghi phải chứa đầy đủ giá trị sysctl mới được
       được viết và ghi nhiều lần trên cùng một bộ mô tả tệp sysctl
       sẽ ghi lại giá trị sysctl, bất kể vị trí tệp.
   0 Hoạt động tương tự như trên, nhưng cảnh báo về các tiến trình thực hiện ghi
       đến bộ mô tả tệp sysctl khi vị trí tệp không bằng 0.
   1 (mặc định) Tôn trọng vị trí tệp khi viết chuỗi sysctl. Nhiều
       ghi sẽ thêm vào bộ đệm giá trị sysctl. Bất cứ điều gì vượt quá mức tối đa
       độ dài của bộ đệm giá trị sysctl sẽ bị bỏ qua. Viết thành số
       các mục sysctl phải luôn ở vị trí tệp 0 và giá trị phải
       được chứa đầy đủ trong bộ đệm được gửi trong tòa nhà ghi.
  == ============================================================================


softlockup_all_cpu_backtrace
============================

Giá trị này kiểm soát hành vi của luồng phát hiện khóa mềm
khi phát hiện tình trạng khóa mềm về việc có hay không
để thu thập thêm thông tin gỡ lỗi. Nếu được bật, mỗi CPU sẽ
được cấp NMI và được hướng dẫn ghi lại dấu vết ngăn xếp.

Tính năng này chỉ áp dụng cho các kiến trúc hỗ trợ
NMI.

= ================================================
0 Không làm gì cả. Đây là hành vi mặc định.
1 Khi phát hiện, nắm bắt thêm thông tin gỡ lỗi.
= ================================================


softlockup_panic
=================

Tham số này có thể được sử dụng để kiểm soát xem kernel có bị hoảng loạn hay không
khi phát hiện khóa mềm.

= ================================================
0 Đừng hoảng sợ khi khóa mềm.
1 Hoảng loạn về khóa mềm.
= ================================================

Điều này cũng có thể được thiết lập bằng tham số kernel softlockup_panic.


soft_watchdog
=============

Tham số này có thể được sử dụng để điều khiển bộ phát hiện khóa mềm.

= ====================================
0 Tắt trình phát hiện khóa mềm.
1 Kích hoạt trình phát hiện khóa mềm.
= ====================================

Trình phát hiện khóa mềm giám sát CPU để tìm các luồng đang chiếm dụng CPU
mà không tự nguyện sắp xếp lại lịch trình và do đó ngăn chặn các luồng 'di chuyển/N'
chạy, khiến công việc giám sát không thực thi được. Cơ chế phụ thuộc
về khả năng đáp ứng của CPU với các ngắt hẹn giờ cần thiết cho
công việc của cơ quan giám sát sẽ được xếp hàng bởi chức năng hẹn giờ của cơ quan giám sát, nếu không thì NMI
cơ quan giám sát - nếu được bật - có thể phát hiện tình trạng khóa cứng.


Split_lock_mitigate (chỉ x86)
==============================

Trên x86, mỗi "khóa phân chia" sẽ áp đặt hình phạt hiệu suất trên toàn hệ thống. Trên lớn hơn
hệ thống, số lượng lớn các khóa phân chia từ người dùng không có đặc quyền có thể dẫn đến
từ chối dịch vụ đối với những người dùng có hành vi tốt và có khả năng quan trọng hơn.

Hạt nhân giảm thiểu những người dùng xấu này bằng cách phát hiện các khóa phân chia và áp đặt
hình phạt: buộc họ phải chờ và chỉ cho phép một lõi thực hiện phân chia
khóa cùng một lúc.

Những biện pháp giảm thiểu này có thể làm cho các ứng dụng xấu đó chậm đến mức không thể chịu nổi. Cài đặt
chia_lock_mitigate=0 có thể khôi phục một số hiệu suất ứng dụng, nhưng cũng sẽ
tăng khả năng hệ thống gặp phải các cuộc tấn công từ chối dịch vụ từ người dùng khóa chia tách.

= =========================================================================
0 Tắt chế độ giảm nhẹ - chỉ cảnh báo khóa phân chia trên nhật ký kernel
  và khiến hệ thống có nguy cơ bị từ chối dịch vụ từ các tủ khóa phân chia.
1 Kích hoạt chế độ giảm thiểu (đây là mặc định) - xử phạt việc chia tách
  tủ khóa với sự suy giảm hiệu suất có chủ ý.
= =========================================================================


ngăn xếp_erasing
=============

Tham số này có thể được sử dụng để kiểm soát việc xóa ngăn xếp kernel ở cuối
tổng số tòa nhà cho các hạt nhân được xây dựng bằng ZZ0000ZZ.

Việc xóa đó làm giảm thông tin về lỗi rò rỉ ngăn xếp kernel
có thể tiết lộ và chặn một số cuộc tấn công biến ngăn xếp chưa được khởi tạo.
Sự đánh đổi là tác động đến hiệu suất: trên một hạt nhân hệ thống CPU
quá trình biên dịch thấy chậm lại 1%, các hệ thống và khối lượng công việc khác có thể thay đổi.

= =========================================================================
0 Tính năng xóa ngăn xếp hạt nhân bị tắt, KSTACK_ERASE_METRICS không được cập nhật.
1 Tính năng xóa ngăn xếp hạt nhân được bật (mặc định), nó được thực hiện trước
  quay trở lại không gian người dùng khi kết thúc cuộc gọi chung.
= =========================================================================


dừng-a (chỉ SPARC)
===================

Kiểm soát điểm dừng A:

= =======================================
0 Stop-A không có hiệu lực.
1 Stop-A ngắt thành PROM (mặc định).
= =======================================

Stop-A luôn được kích hoạt khi có sự cố để người dùng có thể quay lại
khởi động PROM.


sysrq
=====

Xem Tài liệu/admin-guide/sysrq.rst.


bị vấy bẩn
=======

Khác 0 nếu hạt nhân đã bị nhiễm độc. Các giá trị số có thể
ORed cùng nhau. Các chữ cái được nhìn thấy trong dòng "Tainted" của báo cáo Rất tiếc.

====== ===== ===================================================================
     1 mô-đun độc quyền ZZ0000ZZ đã được tải
     2 mô-đun ZZ0001ZZ đã bị buộc tải
     4 Kernel ZZ0002ZZ chạy trên hệ thống không có thông số kỹ thuật
     8 mô-đun ZZ0003ZZ bị buộc phải dỡ tải
    16 bộ xử lý ZZ0004ZZ đã báo cáo Ngoại lệ kiểm tra máy (MCE)
    32 ZZ0005ZZ trang xấu được tham chiếu hoặc một số cờ trang không mong muốn
    64 vết bẩn ZZ0006ZZ do ứng dụng không gian người dùng yêu cầu
   128 kernel ZZ0007ZZ đã chết gần đây, tức là có OOPS hoặc BUG
   256 ZZ0008ZZ một bảng ACPI đã bị người dùng ghi đè
   Cảnh báo hạt nhân 512 ZZ0009ZZ
  Trình điều khiển dàn 1024 ZZ0010ZZ đã được tải
  Đã áp dụng cách giải quyết 2048 ZZ0011ZZ cho lỗi trong chương trình cơ sở nền tảng
  4096 ZZ0012ZZ mô-đun được xây dựng bên ngoài ("ngoài cây") đã được tải
  Mô-đun không dấu 8192 ZZ0013ZZ đã được tải
 Đã xảy ra khóa mềm 16384 ZZ0014ZZ
 Kernel 32768 ZZ0015ZZ đã được vá trực tiếp
 65536 ZZ0016ZZ Vết bẩn phụ trợ, được xác định và sử dụng bởi các bản phân phối
131072 ZZ0017ZZ Hạt nhân được xây dựng bằng plugin ngẫu nhiên hóa cấu trúc
====== ===== ===================================================================

Xem Tài liệu/admin-guide/tainted-kernels.rst để biết thêm thông tin.

Lưu ý:
  việc ghi vào giao diện sysctl này sẽ không thành công với ZZ0000ZZ nếu kernel
  được khởi động với tùy chọn dòng lệnh ZZ0001ZZ
  và bất kỳ giá trị ORed nào được ghi vào ZZ0002ZZ đều khớp với
  bitmask được khai báo trên Panic_on_taint.
  Xem Tài liệu/admin-guide/kernel-parameters.rst để biết thêm chi tiết về
  tùy chọn dòng lệnh kernel cụ thể đó và tùy chọn của nó
  Công tắc ZZ0003ZZ.

chủ đề-max
===========

Giá trị này kiểm soát số lượng chủ đề tối đa có thể được tạo
sử dụng ZZ0000ZZ.

Trong quá trình khởi tạo kernel đặt giá trị này sao cho ngay cả khi
số lượng luồng tối đa được tạo, cấu trúc luồng chỉ chiếm
một phần (1/8) của các trang RAM có sẵn.

Giá trị tối thiểu có thể được ghi vào ZZ0000ZZ là 1.

Giá trị tối đa có thể được ghi vào ZZ0000ZZ được cho bởi
hằng số ZZ0001ZZ (0x3fffffff).

Nếu một giá trị nằm ngoài phạm vi này được ghi vào ZZ0000ZZ thì
Xảy ra lỗi ZZ0001ZZ.

hẹn giờ_migration
===============

Khi được đặt thành giá trị khác 0, hãy thử di chuyển bộ hẹn giờ khỏi CPU nhàn rỗi sang
cho phép chúng duy trì ở trạng thái năng lượng thấp lâu hơn.

Mặc định được đặt (1).

theo dõi_on_warning
===================

Khi được đặt, sẽ tắt tính năng theo dõi (xem Tài liệu/trace/ftrace.rst) khi
ZZ0000ZZ bị bắn trúng.


tracepoint_printk
=================

Khi các điểm theo dõi được gửi tới printk() (được kích hoạt bởi ZZ0000ZZ
tham số khởi động), mục này cung cấp khả năng kiểm soát thời gian chạy::

echo 0 > /proc/sys/kernel/tracepoint_printk

sẽ dừng việc gửi dấu vết tới printk() và::

echo 1 > /proc/sys/kernel/tracepoint_printk

sẽ gửi chúng tới printk() một lần nữa.

Điều này chỉ hoạt động nếu kernel được khởi động với ZZ0000ZZ được kích hoạt.

Xem Tài liệu/admin-guide/kernel-parameters.rst và
Tài liệu/trace/boottime-trace.rst.


bẫy không liên kết
==============

Trên các kiến trúc nơi các truy cập không được căn chỉnh gây ra bẫy và nơi điều này
tính năng được hỗ trợ (ZZ0000ZZ; hiện tại,
ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ), kiểm soát xem bẫy không được căn chỉnh hay không
bị bắt và bắt chước (thay vì thất bại).

= =============================================================
0 Không mô phỏng các truy cập không được căn chỉnh.
1 Mô phỏng các truy cập không được căn chỉnh. Đây là cài đặt mặc định.
= =============================================================

Xem thêm ZZ0000ZZ.


không rõ_nmi_panic
=================

Giá trị trong tệp này ảnh hưởng đến hành vi xử lý NMI. Khi
giá trị khác 0, NMI không xác định bị mắc kẹt và sau đó xảy ra hoảng loạn. Tại
lúc đó, thông tin gỡ lỗi kernel sẽ được hiển thị trên bảng điều khiển.

Bộ chuyển đổi NMI mà hầu hết các máy chủ IA32 đều kích hoạt NMI không xác định, đối với
ví dụ.  Nếu hệ thống bị treo, hãy thử nhấn công tắc NMI.


không có đặc quyền_bpf_disabled
=========================

Viết 1 vào mục này sẽ vô hiệu hóa các cuộc gọi không có đặc quyền tới ZZ0000ZZ;
một khi bị vô hiệu hóa, hãy gọi ZZ0001ZZ mà không có ZZ0002ZZ hoặc ZZ0003ZZ
sẽ trả về ZZ0004ZZ. Sau khi được đặt thành 1, bạn không thể xóa thông tin này khỏi
chạy kernel nữa.

Viết 2 vào mục này cũng sẽ vô hiệu hóa các cuộc gọi không có đặc quyền tới ZZ0000ZZ,
tuy nhiên, quản trị viên vẫn có thể thay đổi cài đặt này sau này, nếu cần, bằng cách
viết 0 hoặc 1 vào mục này.

Nếu ZZ0000ZZ được bật trong cấu hình kernel thì cái này
mục nhập sẽ mặc định là 2 thay vì 0.

= ===================================================================
0 Cuộc gọi không đặc quyền tới ZZ0000ZZ được bật
1 Các cuộc gọi không đặc quyền tới ZZ0001ZZ bị vô hiệu hóa mà không thể khôi phục
2 Cuộc gọi không đặc quyền tới ZZ0002ZZ bị tắt
= ===================================================================


cảnh báo_giới hạn
==========

Số lượng cảnh báo kernel mà sau đó kernel sẽ hoảng sợ khi
ZZ0000ZZ chưa được đặt. Đặt giá trị này thành 0 sẽ vô hiệu hóa việc kiểm tra
số cảnh báo. Đặt giá trị này thành 1 có tác dụng tương tự như cài đặt
ZZ0001ZZ. Giá trị mặc định là 0.


cơ quan giám sát
========

Tham số này có thể được sử dụng để tắt hoặc bật trình phát hiện khóa mềm
ZZ0000ZZ cơ quan giám sát NMI (tức là máy dò khóa cứng) cùng một lúc.

= =================================
0 Vô hiệu hóa cả hai máy dò khóa.
1 Kích hoạt cả hai trình phát hiện khóa.
= =================================

Bộ phát hiện khóa mềm và cơ quan giám sát NMI cũng có thể bị vô hiệu hóa hoặc
được bật riêng lẻ, sử dụng ZZ0000ZZ và ZZ0001ZZ
các thông số.
Ví dụ: nếu tham số ZZ0002ZZ được đọc, bằng cách thực thi::

mèo /proc/sys/kernel/cơ quan giám sát

đầu ra của lệnh này (0 hoặc 1) hiển thị OR logic của
ZZ0000ZZ và ZZ0001ZZ.


cơ quan giám sát_cpumask
================

Giá trị này có thể được sử dụng để kiểm soát CPU nào mà cơ quan giám sát có thể chạy.
CPUmask mặc định là tất cả các lõi có thể có, nhưng nếu ZZ0000ZZ là
được kích hoạt trong cấu hình kernel và các lõi được chỉ định bằng
Đối số khởi động ZZ0001ZZ, các lõi đó bị loại trừ theo mặc định.
Các lõi ngoại tuyến có thể được bao gồm trong mặt nạ này và nếu lõi muộn hơn
được đưa lên mạng, cơ quan giám sát sẽ được bắt đầu dựa trên giá trị mặt nạ.

Thông thường, giá trị này sẽ chỉ được chạm vào trong trường hợp ZZ0000ZZ
để kích hoạt lại các lõi mà theo mặc định không chạy cơ quan giám sát,
nếu nghi ngờ có khóa kernel trên các lõi đó.

Giá trị đối số là định dạng cpulist tiêu chuẩn cho cpumasks,
vì vậy, ví dụ để bật cơ quan giám sát trên các lõi 0, 2, 3 và 4, bạn
có thể nói::

echo 0,2-4 > /proc/sys/kernel/watchdog_cpumask


cơ quan giám sát_thresh
===============

Giá trị này có thể được sử dụng để kiểm soát tần số của giờ và NMI
các sự kiện và ngưỡng khóa mềm và cứng. Ngưỡng mặc định
là 10 giây.

Ngưỡng khóa mềm là (ZZ0000ZZ). Cài đặt cái này
có thể điều chỉnh về 0 sẽ vô hiệu hóa hoàn toàn việc phát hiện khóa.
