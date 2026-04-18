.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/sound/utimers.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Bộ hẹn giờ theo không gian người dùng
=======================

:Tác giả: Ivan Orlov <ivan.orlov0322@gmail.com>

Lời nói đầu
=======

Tài liệu này mô tả bộ định thời theo không gian người dùng: bộ định thời ALSA ảo
có thể được tạo và kiểm soát bởi các ứng dụng không gian người dùng bằng cách sử dụng
Cuộc gọi IOCTL. Bộ hẹn giờ như vậy có thể hữu ích khi đồng bộ hóa âm thanh
phát trực tuyến với các nguồn hẹn giờ mà chúng tôi không xuất bộ hẹn giờ ALSA cho
(ví dụ: đồng hồ PTP) và khi đồng bộ hóa luồng âm thanh đi qua
hai thiết bị âm thanh ảo sử dụng ZZ0000ZZ (ví dụ: khi
chúng tôi có một ứng dụng mạng gửi khung tới một thiết bị snd-aloop,
và một ứng dụng âm thanh khác đang nghe ở đầu bên kia của snd-aloop).

Bật bộ hẹn giờ theo không gian người dùng
================================

Bộ hẹn giờ điều khiển theo không gian người dùng có thể được kích hoạt trong kernel bằng cách sử dụng
Tùy chọn cấu hình ZZ0000ZZ. Nó phụ thuộc vào
Tùy chọn ZZ0001ZZ, vì vậy nó cũng nên được kích hoạt.

Bộ hẹn giờ điều khiển theo không gian người dùng API
===========================

Ứng dụng không gian người dùng có thể tạo bộ hẹn giờ ALSA điều khiển không gian người dùng bằng cách
thực hiện lệnh gọi ZZ0000ZZ ioctl trên
Bộ mô tả tập tin thiết bị ZZ0001ZZ. ZZ0002ZZ
cấu trúc phải được thông qua dưới dạng đối số ioctl:

::

cấu trúc snd_timer_uinfo {
        __u64 độ phân giải;
        int fd;
        id int không dấu;
        char không dấu dành riêng [16];
    }

Trường ZZ0000ZZ đặt độ phân giải mong muốn tính bằng nano giây cho
bộ hẹn giờ ảo. Trường ZZ0001ZZ chỉ cung cấp thông tin
về bộ hẹn giờ ảo, nhưng không ảnh hưởng đến thời gian. ZZ0002ZZ
trường bị ghi đè bởi ioctl và mã định danh bạn nhận được trong trường này
trường sau cuộc gọi có thể được sử dụng làm số thiết bị con hẹn giờ khi
chuyển bộ đếm thời gian tới mô-đun hạt nhân ZZ0003ZZ hoặc không gian người dùng khác
ứng dụng. Có thể có tới 128 bộ hẹn giờ do không gian người dùng điều khiển trong
hệ thống tại một thời điểm, do đó giá trị id nằm trong khoảng từ 0 đến 127.

Ngoài việc ghi đè cấu trúc ZZ0000ZZ, ioctl còn lưu trữ
một bộ mô tả tập tin hẹn giờ, có thể được sử dụng để kích hoạt bộ đếm thời gian, trong
Trường ZZ0001ZZ của cấu trúc ZZ0002ZZ. Phân bổ tập tin
bộ mô tả cho bộ hẹn giờ đảm bảo rằng bộ hẹn giờ chỉ có thể được kích hoạt
bởi quá trình tạo ra nó. Bộ hẹn giờ sau đó có thể được kích hoạt bằng
ZZ0003ZZ ioctl gọi trên bộ mô tả tệp hẹn giờ.

Vì vậy, mã ví dụ để tạo và kích hoạt bộ hẹn giờ sẽ là:

::

cấu trúc tĩnh snd_timer_uinfo utimer_info = {
        /* Bộ đếm thời gian sẽ đánh dấu (có lẽ) cứ sau 1000000 ns */
        .độ phân giải = 1000000ULL,
        .id = -1,
    };

int time_device_fd = open("/dev/snd/timer", O_RDWR | O_CLOEXEC);

if (ioctl(timer_device_fd, SNDRV_TIMER_IOCTL_CREATE, &utimer_info)) {
        perror("Không tạo được bộ đếm thời gian");
        trả về -1;
    }

    ...

/*
     * Bây giờ chúng tôi muốn kích hoạt bộ đếm thời gian. Cuộc gọi lại của tất cả các
     * các phiên bản bộ định thời được liên kết với bộ định thời này sẽ được thực thi sau
     * cuộc gọi này.
     */
    ioctl(utimer_info.fd, SNDRV_TIMER_IOCTL_TRIGGER, NULL);

    ...

/* Bây giờ, hãy hủy bộ đếm thời gian */
    đóng(timer_info.fd);


Có thể tìm thấy ví dụ chi tiết hơn về việc tạo và đánh dấu bộ đếm thời gian
trong bản tự kiểm tra ALSA của utimer.

Bộ hẹn giờ điều khiển theo không gian người dùng và snd-aloop
-------------------------------------

Bộ hẹn giờ điều khiển theo không gian người dùng có thể dễ dàng sử dụng với mô-đun ZZ0000ZZ
khi đồng bộ hai ứng dụng âm thanh ở hai đầu của thiết bị ảo
vòng lặp âm thanh. Ví dụ: nếu một trong các ứng dụng nhận được âm thanh
các khung hình từ mạng và gửi chúng đến thiết bị pcm snd-aloop và một thiết bị khác
ứng dụng lắng nghe các khung trên thiết bị pcm snd-aloop khác, nó
có nghĩa là lớp giữa ALSA sẽ khởi tạo dữ liệu
giao dịch khi giai đoạn dữ liệu mới được nhận qua mạng, nhưng
không phải khi số lượng jiffies nhất định trôi qua. ALSA hướng đến không gian người dùng
bộ tính giờ có thể được sử dụng để đạt được điều này.

Để sử dụng bộ định thời ALSA do không gian người dùng điều khiển làm nguồn định thời của snd-aloop, hãy chuyển
chuỗi sau đây làm tham số snd-aloop ZZ0000ZZ:

::

# modprobe bộ đếm thời gian snd-aloop_source="-1.4.<utimer_id>"

Trong đó ZZ0000ZZ là id của bộ hẹn giờ bạn đã tạo
ZZ0001ZZ và ZZ0002ZZ là số lượng
thiết bị hẹn giờ điều khiển không gian người dùng (ZZ0003ZZ).

ZZ0000ZZ dành cho bộ hẹn giờ ALSA điều khiển theo không gian người dùng được sử dụng với snd-aloop
nên được tính là ZZ0001ZZ là
bộ đếm thời gian sẽ tích tắc mỗi khi một khoảng thời gian khung hình mới sẵn sàng.

Sau đó, mỗi lần bạn kích hoạt bộ hẹn giờ bằng
ZZ0000ZZ giai đoạn dữ liệu mới sẽ được chuyển
từ thiết bị snd-aloop này sang thiết bị khác.