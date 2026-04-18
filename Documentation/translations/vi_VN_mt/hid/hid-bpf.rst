.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hid/hid-bpf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======
HID-BPF
=======

HID là giao thức chuẩn cho thiết bị đầu vào nhưng một số thiết bị có thể yêu cầu
các chỉnh sửa tùy chỉnh, theo truyền thống được thực hiện với bản sửa lỗi trình điều khiển kernel. Sử dụng eBPF
thay vào đó tăng tốc độ phát triển và bổ sung các khả năng mới cho
giao diện HID hiện có.

.. contents::
    :local:
    :depth: 2


Khi nào (và tại sao) sử dụng HID-BPF
=============================

Có một số trường hợp sử dụng khi sử dụng HID-BPF thì tốt hơn
hơn sửa lỗi trình điều khiển hạt nhân tiêu chuẩn:

Vùng chết của cần điều khiển
-----------------------

Giả sử bạn có một cần điều khiển đã cũ, người ta thường thấy nó
lắc lư quanh điểm trung tính của nó. Điều này thường được lọc tại ứng dụng
bằng cách thêm ZZ0000ZZ cho trục cụ thể này.

Với HID-BPF, chúng ta có thể áp dụng tính năng lọc này trực tiếp trong kernel để không gian người dùng
không bị đánh thức khi không có gì khác xảy ra trên bộ điều khiển đầu vào.

Tất nhiên, do vùng chết này dành riêng cho từng thiết bị riêng lẻ nên chúng tôi
không thể tạo bản sửa lỗi chung cho tất cả các cần điều khiển giống nhau. Thêm tùy chỉnh
kernel API cho việc này (ví dụ: bằng cách thêm mục nhập sysfs) không đảm bảo tính năng mới này
kernel API sẽ được áp dụng và duy trì rộng rãi.

HID-BPF cho phép chương trình không gian người dùng tự tải chương trình, đảm bảo chúng tôi
chỉ tải API tùy chỉnh khi chúng tôi có người dùng.

Sửa lỗi đơn giản của bộ mô tả báo cáo
---------------------------------

Trong cây HID, một nửa số trình điều khiển chỉ sửa một khóa hoặc một byte
trong phần mô tả báo cáo. Tất cả các bản sửa lỗi này đều yêu cầu bản vá kernel và
tiếp theo là đưa nó vào bản phát hành, một quá trình lâu dài và đau đớn cho người dùng.

Thay vào đó, chúng tôi có thể giảm bớt gánh nặng này bằng cách cung cấp chương trình eBPF. Một khi như vậy
chương trình đã được người dùng xác minh, chúng ta có thể nhúng mã nguồn vào
cây nhân và gửi chương trình eBPF và tải trực tiếp thay vì tải
một mô-đun hạt nhân cụ thể cho nó.

Lưu ý: không thể phân phối các chương trình eBPF và đưa chúng vào kernel
chưa thực hiện đầy đủ

Thêm tính năng mới yêu cầu kernel mới API
------------------------------------------------

Một ví dụ cho tính năng như vậy là bút Universal Stylus Interface (USI).
Về cơ bản, bút USI yêu cầu kernel API mới vì có kernel mới
các kênh liên lạc mà HID và ngăn xếp đầu vào của chúng tôi không hỗ trợ.
Thay vì sử dụng hidraw hoặc tạo các mục sysfs hoặc ioctls mới, chúng ta có thể dựa vào
trên eBPF để nhân API được người tiêu dùng kiểm soát và không
tác động đến hiệu suất bằng cách đánh thức không gian người dùng mỗi khi có
sự kiện.

Biến một thiết bị thành một thiết bị khác và điều khiển thiết bị đó từ không gian người dùng
------------------------------------------------------------------

Hạt nhân có ánh xạ tương đối tĩnh các mục HID tới các bit evdev.
Nó không thể quyết định tự động chuyển đổi một thiết bị nhất định thành một thiết bị khác
vì nó không có ngữ cảnh cần thiết và bất kỳ sự chuyển đổi nào như vậy đều không thể thực hiện được
hoàn tác (hoặc thậm chí được phát hiện) bởi không gian người dùng.

Tuy nhiên, một số thiết bị trở nên vô dụng với cách xác định thiết bị tĩnh đó. cho
Ví dụ: Microsoft Surface Dial là một nút bấm có phản hồi xúc giác
hầu như không thể sử dụng được cho đến ngày nay.

Với eBPF, không gian người dùng có thể biến thiết bị đó thành chuột và chuyển đổi mặt số
các sự kiện thành các sự kiện bánh xe. Ngoài ra, chương trình không gian người dùng có thể đặt/bỏ đặt xúc giác
phản hồi tùy theo ngữ cảnh. Ví dụ: nếu một menu hiển thị trên
màn hình, chúng ta có thể cần phải có một cú nhấp chuột xúc giác mỗi 15 độ. Nhưng khi
cuộn trong một trang web trải nghiệm người dùng sẽ tốt hơn khi thiết bị phát ra
sự kiện ở độ phân giải cao nhất.

Tường lửa
--------

Điều gì sẽ xảy ra nếu chúng ta muốn ngăn người dùng khác truy cập vào một tính năng cụ thể của một
thiết bị? (nghĩ rằng điểm vào cập nhật chương trình cơ sở có thể bị hỏng)

Với eBPF, chúng tôi có thể chặn bất kỳ lệnh HID nào được phát tới thiết bị và
xác nhận nó hay không.

Điều này cũng cho phép đồng bộ hóa trạng thái giữa không gian người dùng và
chương trình kernel/bpf vì chúng tôi có thể chặn bất kỳ lệnh nào đến.

Truy tìm
-------

Cách sử dụng cuối cùng là truy tìm các sự kiện và tất cả những điều thú vị mà chúng tôi có thể làm BPF tóm tắt
và phân tích các sự kiện.

Hiện tại, việc truy tìm dựa vào hidraw. Nó hoạt động tốt ngoại trừ một vài
của các vấn đề:

1. nếu trình điều khiển không xuất nút ẩn, chúng tôi không thể theo dõi bất cứ điều gì
   (eBPF sẽ là một "chế độ thần thánh" ở đó, vì vậy điều này có thể khiến một số người phải thắc mắc)
2. hidraw không nhận được yêu cầu của các tiến trình khác tới thiết bị, điều này
   có nghĩa là chúng ta có những trường hợp cần thêm bản in vào kernel
   để hiểu chuyện gì đang xảy ra.

Chế độ xem cấp cao của HID-BPF
==========================

Ý tưởng chính đằng sau HID-BPF là nó hoạt động ở một mảng mức byte.
Do đó, tất cả phân tích cú pháp của báo cáo HID và bộ mô tả báo cáo HID
phải được triển khai trong thành phần không gian người dùng tải eBPF
chương trình.

Ví dụ: trong cần điều khiển vùng chết từ trên cao, biết trường nào
trong luồng dữ liệu cần được đặt thành ZZ0000ZZ cần được tính toán theo không gian người dùng.

Hệ quả tất yếu của điều này là HID-BPF không biết về các hệ thống con khác
có sẵn trong hạt nhân. *Bạn không thể trực tiếp phát ra sự kiện đầu vào thông qua
nhập API từ eBPF*.

Khi chương trình BPF cần phát ra các sự kiện đầu vào, nó cần giao tiếp với HID
giao thức và dựa vào quá trình xử lý hạt nhân HID để dịch dữ liệu HID sang
sự kiện đầu vào.

Các chương trình HID-BPF trên cây và ZZ0000ZZ
=============================================

Các bản sửa lỗi thiết bị chính thức được gửi trong cây nhân dưới dạng nguồn trong
Thư mục ZZ0000ZZ. Điều này cho phép thêm các bản tự kiểm tra cho chúng trong
ZZ0001ZZ.

Tuy nhiên, việc biên dịch các đối tượng này không phải là một phần của quá trình biên dịch kernel thông thường.
vì họ cần một công cụ bên ngoài để tải. Công cụ này hiện đang
ZZ0000ZZ.

Để thuận tiện, kho lưu trữ bên ngoài đó sẽ sao chép các tệp từ đây trong
ZZ0000ZZ vào thư mục ZZ0001ZZ của chính nó. Điều này cho phép
các bản phân phối để không phải kéo toàn bộ cây nguồn kernel để vận chuyển và đóng gói
những bản sửa lỗi HID-BPF đó. ZZ0002ZZ cũng có khả năng xử lý nhiều
đối tượng tùy thuộc vào kernel mà người dùng đang chạy.

Các loại chương trình có sẵn
===========================

HID-BPF được xây dựng "trên cùng" của BPF, nghĩa là chúng tôi sử dụng phương thức bpf struct_ops để
tuyên bố các chương trình của chúng tôi.

HID-BPF có sẵn các loại tệp đính kèm sau:

1. xử lý/lọc sự kiện với ZZ0000ZZ trong libbpf
2. các hành động đến từ không gian người dùng với ZZ0001ZZ trong libbpf
3. thay đổi bộ mô tả báo cáo bằng ZZ0002ZZ hoặc
   ZZ0003ZZ trong libbpf

ZZ0000ZZ đang gọi chương trình BPF khi nhận được sự kiện từ
thiết bị. Vì vậy, chúng tôi đang ở trong bối cảnh IRQ và có thể hành động dựa trên dữ liệu hoặc thông báo cho không gian người dùng.
Và vì chúng ta đang ở trong bối cảnh IRQ nên chúng ta không thể nói chuyện lại với thiết bị.

ZZ0000ZZ có nghĩa là không gian người dùng được gọi là cơ sở ZZ0001ZZ syscall.
Lần này, chúng ta có thể thực hiện bất kỳ thao tác nào được HID-BPF cho phép và việc nói chuyện với thiết bị là
được phép.

Cuối cùng, ZZ0000ZZ khác với những cái khác vì chỉ có thể có một
Chương trình BPF thuộc loại này. Điều này được gọi trên ZZ0001ZZ từ trình điều khiển và cho phép
thay đổi bộ mô tả báo cáo từ chương trình BPF. Từng là ZZ0002ZZ
chương trình đã được tải, không thể ghi đè lên nó trừ khi chương trình đó
được chèn vào, nó cho phép chúng tôi bằng cách ghim chương trình và đóng tất cả các fds trỏ đến nó.

Lưu ý rằng ZZ0000ZZ có thể được khai báo là có thể ngủ được (ZZ0001ZZ).


Nhà phát triển API:
==============

ZZ0000ZZ có sẵn cho HID-BPF:
-------------------------------------

.. kernel-doc:: include/linux/hid_bpf.h
   :identifiers: hid_bpf_ops


Cấu trúc dữ liệu API của người dùng có sẵn trong các chương trình:
-----------------------------------------------

.. kernel-doc:: include/linux/hid_bpf.h
   :identifiers: hid_bpf_ctx

API có sẵn có thể được sử dụng trong tất cả các chương trình HID-BPF struct_ops:
------------------------------------------------------------------

.. kernel-doc:: drivers/hid/bpf/hid_bpf_dispatch.c
   :identifiers: hid_bpf_get_data

API có sẵn có thể được sử dụng trong các chương trình syscall HID-BPF hoặc trong các chương trình HID-BPF struct_ops có thể ngủ:
-------------------------------------------------------------------------------------------------------

.. kernel-doc:: drivers/hid/bpf/hid_bpf_dispatch.c
   :identifiers: hid_bpf_hw_request hid_bpf_hw_output_report hid_bpf_input_report hid_bpf_try_input_report hid_bpf_allocate_context hid_bpf_release_context

Tổng quan chung về chương trình HID-BPF
=====================================

Truy cập dữ liệu gắn liền với ngữ cảnh
------------------------------------------

ZZ0001ZZ không xuất trực tiếp các trường ZZ0002ZZ và để truy cập
nó, một chương trình bpf trước tiên cần gọi ZZ0000ZZ.

ZZ0000ZZ có thể là số nguyên bất kỳ, nhưng ZZ0001ZZ cần phải không đổi, được biết khi biên dịch
thời gian.

Điều này cho phép như sau:

1. đối với một thiết bị nhất định, nếu chúng tôi biết rằng độ dài báo cáo sẽ luôn có một giá trị nhất định,
   chúng ta có thể yêu cầu con trỏ ZZ0000ZZ trỏ đến độ dài báo cáo đầy đủ.

Hạt nhân sẽ đảm bảo chúng tôi đang sử dụng kích thước và độ lệch chính xác và eBPF sẽ đảm bảo
   mã sẽ không cố đọc hoặc ghi bên ngoài ranh giới::

__u8 ZZ0000ZZ bù kích thước ZZ0001ZZ */);

nếu (!dữ liệu)
         trả về 0; /* đảm bảo dữ liệu là chính xác, bây giờ người xác minh biết chúng tôi
                    * có sẵn 256 byte */

bpf_printk("xin chào thế giới: %02x %02x %02x", data[0], data[128], data[255]);

2. nếu độ dài báo cáo có thể thay đổi, nhưng chúng tôi biết giá trị của ZZ0000ZZ luôn là 16-bit
   số nguyên, khi đó chúng ta chỉ có thể có một con trỏ tới giá trị đó ::

__u16 *x = hid_bpf_get_data(ctx, offset, sizeof(*x));

nếu (!x)
          trả về 0; /*có gì đó không ổn*/

ZZ0000ZZ tăng X thêm một */

Tác dụng của chương trình HID-BPF
---------------------------

Đối với tất cả các loại tệp đính kèm HID-BPF ngoại trừ ZZ0000ZZ, một số eBPF
các chương trình có thể được gắn vào cùng một thiết bị. Nếu cấu trúc HID-BPF có
ZZ0001ZZ trong khi một cái khác đã được gắn vào thiết bị,
kernel sẽ trả về ZZ0002ZZ khi đính kèm struct_ops.

Trừ khi ZZ0000ZZ được thêm vào cờ trong khi đính kèm chương trình, thì
chương trình được thêm vào cuối danh sách.
ZZ0001ZZ sẽ chèn chương trình mới vào đầu danh sách
hữu ích cho ví dụ truy tìm nơi chúng tôi cần lấy các sự kiện chưa được xử lý từ thiết bị.

Lưu ý rằng nếu có nhiều chương trình sử dụng cờ ZZ0000ZZ,
chỉ có cái được tải gần đây nhất mới thực sự là cái đầu tiên trong danh sách.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bất cứ khi nào một sự kiện trùng khớp được đưa ra, các chương trình eBPF sẽ được gọi lần lượt
và đang làm việc trên cùng một bộ đệm dữ liệu.

Nếu một chương trình thay đổi dữ liệu liên quan đến ngữ cảnh, chương trình tiếp theo sẽ thấy
dữ liệu đã sửa đổi nhưng nó sẽ có ý tưởng ZZ0000ZZ về dữ liệu gốc là gì.

Khi tất cả các chương trình được chạy và trả về ZZ0000ZZ hoặc giá trị dương, phần còn lại của
Ngăn xếp HID sẽ hoạt động trên dữ liệu đã sửa đổi, với trường ZZ0001ZZ của hid_bpf_ctx cuối cùng
là kích thước mới của luồng dữ liệu đầu vào.

Chương trình BPF trả về lỗi tiêu cực sẽ loại bỏ sự kiện, tức là sự kiện này sẽ không được
được xử lý bởi ngăn xếp HID. Khách hàng (hidraw, input, LEDs) sẽ ZZ0000ZZ thấy sự kiện này.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~

ZZ0000ZZ không được gắn vào một thiết bị nhất định. Để cho biết chúng tôi đang làm việc với thiết bị nào
với, không gian người dùng cần tham chiếu đến thiết bị theo id hệ thống duy nhất của nó (4 số cuối
trong đường dẫn sysfs: ZZ0001ZZ).

Để truy xuất ngữ cảnh được liên kết với thiết bị, chương trình phải gọi
hid_bpf_allocate_context() và phải giải phóng nó bằng hid_bpf_release_context()
trước khi quay lại.
Khi bối cảnh được lấy ra, người ta cũng có thể yêu cầu một con trỏ tới bộ nhớ kernel với
hid_bpf_get_data(). Bộ nhớ này đủ lớn để hỗ trợ tất cả các đầu vào/đầu ra/tính năng
báo cáo của thiết bị nhất định.

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chương trình ZZ0000ZZ hoạt động theo cách tương tự như ZZ0001ZZ
của ZZ0002ZZ.

Khi thiết bị được thăm dò, kernel sẽ thiết lập bộ đệm dữ liệu của ngữ cảnh với
nội dung mô tả báo cáo. Bộ nhớ liên kết với bộ đệm đó là
ZZ0000ZZ (hiện tại là 4kB).

Chương trình eBPF có thể sửa đổi bộ đệm dữ liệu theo ý muốn và kernel sử dụng
nội dung và kích thước được sửa đổi làm phần mô tả báo cáo.

Bất cứ khi nào struct_ops chứa chương trình ZZ0000ZZ
được đính kèm (nếu trước đó không có chương trình nào được đính kèm), kernel sẽ ngắt kết nối ngay lập tức
thiết bị HID và thực hiện thăm dò lại.

Theo cách tương tự, khi struct_ops này bị tách ra, kernel sẽ ngắt kết nối
trên thiết bị.

Không có cơ sở ZZ0000ZZ trong HID-BPF. Việc tách một chương trình xảy ra khi
tất cả các bộ mô tả tệp không gian người dùng trỏ vào liên kết HID-BPF struct_ops đều bị đóng.
Vì vậy, nếu chúng ta cần thay thế bản sửa lỗi mô tả báo cáo, cần có sự hợp tác
được yêu cầu từ chủ sở hữu của bản sửa lỗi mô tả báo cáo ban đầu.
Chủ sở hữu trước đó có thể sẽ ghim liên kết struct_ops trong bpffs và sau đó chúng tôi có thể
thay thế nó thông qua các hoạt động bpf bình thường.

Đính kèm chương trình bpf vào thiết bị
===================================

Bây giờ chúng tôi sử dụng tệp đính kèm struct_ops tiêu chuẩn thông qua ZZ0000ZZ.
Nhưng vì chúng ta cần đính kèm struct_ops vào thiết bị HID chuyên dụng, nên người gọi
phải đặt ZZ0001ZZ trong bản đồ struct_ops trước khi tải chương trình vào kernel.

ZZ0000ZZ là ID hệ thống duy nhất của thiết bị HID (4 số cuối trong
đường dẫn sysfs: ZZ0001ZZ)

Người ta cũng có thể đặt ZZ0000ZZ, thuộc loại ZZ0001ZZ.

Chúng tôi không thể dựa vào hidraw để liên kết chương trình BPF với thiết bị HID. ẩn là một
tạo tác của quá trình xử lý thiết bị HID và không ổn định. Một số trình điều khiển
thậm chí vô hiệu hóa nó để loại bỏ khả năng theo dõi trên các thiết bị đó
(nơi thú vị để có được dấu vết không ẩn).

Mặt khác, ZZ0000ZZ ổn định trong suốt vòng đời của thiết bị HID,
ngay cả khi chúng tôi thay đổi mô tả báo cáo của nó.

Vì hidraw không ổn định khi thiết bị ngắt kết nối/kết nối lại, chúng tôi khuyên bạn nên
truy cập bộ mô tả báo cáo hiện tại của thiết bị thông qua sysfs.
Điều này có sẵn tại ZZ0000ZZ dưới dạng
luồng nhị phân.

Việc phân tích bộ mô tả báo cáo là trách nhiệm của lập trình viên BPF hoặc không gian người dùng
thành phần tải chương trình eBPF.

Một ví dụ (gần như) hoàn chỉnh về thiết bị HID nâng cao BPF
=========================================================

ZZ0000ZZ

Hãy tưởng tượng chúng ta có một thiết bị máy tính bảng mới có một số khả năng xúc giác
để mô phỏng bề mặt mà người dùng đang gãi. Thiết bị này cũng sẽ có
một công tắc 3 vị trí cụ thể để chuyển đổi giữa ZZ0000ZZ, ZZ0001ZZ
và ZZ0002ZZ. Để làm mọi việc tốt hơn nữa, chúng ta có thể kiểm soát
vị trí vật lý của switch thông qua một báo cáo tính năng.

Và tất nhiên, switch dựa vào một số thành phần không gian người dùng để kiểm soát
tính năng xúc giác của chính thiết bị.

Lọc sự kiện
----------------

Bước đầu tiên bao gồm lọc các sự kiện từ thiết bị. Cho rằng công tắc
vị trí thực sự được báo cáo trong luồng sự kiện bút, sử dụng hidraw để triển khai
việc lọc đó có nghĩa là chúng tôi đánh thức không gian người dùng cho mọi sự kiện.

Điều này ổn đối với libinput, nhưng có một thư viện bên ngoài chỉ quan tâm đến
một byte trong báo cáo ít hơn lý tưởng.

Để làm được điều đó, chúng ta có thể tạo bộ khung cơ bản cho chương trình BPF của mình ::

#include "vmlinux.h"
  #include <bpf/bpf_helpers.h>
  #include <bpf/bpf_tracing.h>

/* Các chương trình HID cần phải là GPL */
  char _license[] SEC("giấy phép") = "GPL";

/* Định nghĩa HID-BPF kfunc API */
  bên ngoài __u8 *hid_bpf_get_data(struct hid_bpf_ctx *ctx,
			      phần bù int không dấu,
			      const size_t __sz) __ksym;

cấu trúc {
	__uint(loại, BPF_MAP_TYPE_RINGBUF);
	__uint(max_entries, 4096 * 64);
  } ringbuf SEC(".maps");

__u8 current_value = 0;

SEC("struct_ops/hid_device_event")
  int BPF_PROG(filter_switch, struct hid_bpf_ctx *hid_ctx)
  {
	__u8 ZZ0000ZZ bù kích thước ZZ0001ZZ */);
	__u8 *buf;

nếu (!dữ liệu)
		trả về 0; /* Kiểm tra EPERM */

if (current_value != data[152]) {
		buf = bpf_ringbuf_reserve(&ringbuf, 1, 0);
		nếu (!buf)
			trả về 0;

*buf = dữ liệu[152];

bpf_ringbuf_commit(buf, 0);

current_value = dữ liệu[152];
	}

trả về 0;
  }

SEC(".struct_ops.link")
  cấu trúc hid_bpf_ops haptic_tablet = {
  	.hid_device_event = (void *)filter_switch,
  };


Để đính kèm ZZ0000ZZ, vùng người dùng cần thiết lập ZZ0001ZZ trước tiên::

static int Attach_filter(struct hid *hid_skel, int hid_id)
  {
  	int lỗi, link_fd;

hid_skel->struct_ops.haptic_tablet->hid_id = hid_id;
  	err = hid__load(skel);
  	nếu (err)
  		trả lại lỗi;

link_fd = bpf_map__attach_struct_ops(hid_skel->maps.haptic_tablet);
  	nếu (!link_fd) {
  		fprintf(stderr, "không thể đính kèm chương trình HID-BPF: %m\n");
  		trả về -1;
  	}

trả về link_fd; /* fd của bpf_link đã tạo */
  }

Chương trình không gian người dùng của chúng tôi hiện có thể nghe thông báo trên bộ đệm vòng và
chỉ được đánh thức khi giá trị thay đổi.

Khi chương trình không gian người dùng không cần nghe các sự kiện nữa, nó chỉ có thể
đóng liên kết bpf được trả về từ ZZ0000ZZ, liên kết này sẽ báo cho kernel biết
tách chương trình khỏi thiết bị HID.

Tất nhiên, trong các trường hợp sử dụng khác, chương trình không gian người dùng cũng có thể ghim fd vào
Hệ thống tập tin BPF thông qua lệnh gọi tới ZZ0000ZZ, như với bất kỳ bpf_link nào.

Kiểm soát thiết bị
----------------------

Để có thể thay đổi phản hồi xúc giác từ máy tính bảng, chương trình không gian người dùng
cần phát ra một báo cáo tính năng trên chính thiết bị đó.

Thay vì sử dụng hidraw cho việc đó, chúng ta có thể tạo chương trình ZZ0000ZZ
nói chuyện với thiết bị::

/* một số định nghĩa khác về HID-BPF kfunc API */
  cấu trúc bên ngoài hid_bpf_ctx *hid_bpf_allocate_context(unsigned int hid_id) __ksym;
  bên ngoài void hid_bpf_release_context(struct hid_bpf_ctx *ctx) __ksym;
  extern int hid_bpf_hw_request(struct hid_bpf_ctx *ctx,
			      __u8* dữ liệu,
			      size_t len,
			      loại enum hid_report_type,
			      enum hid_class_request reqtype) __ksym;


cấu trúc hid_send_haptics_args {
	/* dữ liệu cần đến offset 0 để chúng ta có thể thực hiện memcpy vào đó */
	__u8 dữ liệu[10];
	ẩn int không dấu;
  };

SEC("tòa nhà chung cư")
  int send_haptic(struct hid_send_haptics_args *args)
  {
	cấu trúc hid_bpf_ctx *ctx;
	int ret = 0;

ctx = hid_bpf_allocate_context(args->hid);
	nếu (!ctx)
		trả về 0; /* Kiểm tra EPERM */

ret = hid_bpf_hw_request(ctx,
				 đối số-> dữ liệu,
				 10,
				 HID_FEATURE_REPORT,
				 HID_REQ_SET_REPORT);

hid_bpf_release_context(ctx);

trở lại ret;
  }

Và sau đó không gian người dùng cần gọi trực tiếp chương trình đó ::

int tĩnh set_haptic(struct hid *hid_skel, int hid_id, __u8 haptic_value)
  {
	int err, prog_fd;
	int ret = -1;
	cấu trúc hid_send_haptics_args args = {
		.hid = hid_id,
	};
	DECLARE_LIBBPF_OPTS(bpf_test_run_opts, tattrs,
		.ctx_in = &args,
		.ctx_size_in = sizeof(args),
	);

args.data[0] = 0x02; /* ID báo cáo của tính năng trên thiết bị của chúng tôi */
	args.data[1] = haptic_value;

prog_fd = bpf_program__fd(hid_skel->progs.set_haptic);

err = bpf_prog_test_run_opts(prog_fd, &tattrs);
	trả lại lỗi;
  }

Bây giờ chương trình không gian người dùng của chúng tôi đã nhận biết được trạng thái xúc giác và có thể kiểm soát nó. các
chương trình có thể cung cấp thêm trạng thái này cho các chương trình không gian người dùng khác
(ví dụ: thông qua DBus API).

Điều thú vị ở đây là chúng tôi không tạo kernel API mới cho việc này.
Điều đó có nghĩa là nếu có lỗi trong quá trình triển khai, chúng tôi có thể thay đổi
giao diện với kernel theo ý muốn, vì ứng dụng vùng người dùng được
chịu trách nhiệm về việc sử dụng của mình.