.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accounting/psi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _psi:

====================================
PSI - Thông tin về trạng thái dừng áp suất
================================

:Ngày: Tháng 4 năm 2018
:Tác giả: Johannes Weiner <hannes@cmpxchg.org>

Khi CPU, bộ nhớ hoặc thiết bị IO bị tranh chấp, khối lượng công việc sẽ gặp phải
độ trễ tăng đột biến, tổn thất thông lượng và có nguy cơ giết chết OOM.

Nếu không có thước đo chính xác về sự tranh chấp đó, người dùng buộc phải
hoặc chơi nó an toàn và sử dụng không đúng mức tài nguyên phần cứng của họ, hoặc
tung xúc xắc và thường xuyên phải chịu sự gián đoạn do
cam kết quá mức.

Tính năng psi xác định và định lượng sự gián đoạn gây ra bởi
sự khủng hoảng tài nguyên như vậy và tác động về mặt thời gian của nó đối với khối lượng công việc phức tạp
hoặc thậm chí toàn bộ hệ thống.

Có thước đo chính xác về tổn thất năng suất do tài nguyên gây ra
sự khan hiếm hỗ trợ người dùng trong việc định cỡ khối lượng công việc cho phần cứng--hoặc cung cấp
phần cứng theo nhu cầu khối lượng công việc.

Khi psi tổng hợp thông tin này theo thời gian thực, hệ thống có thể được quản lý
sử dụng linh hoạt các kỹ thuật như giảm tải, di chuyển công việc sang
các hệ thống hoặc trung tâm dữ liệu khác hoặc tạm dừng hoặc loại bỏ một cách có chiến lược
công việc hàng loạt ưu tiên hoặc có thể khởi động lại.

Điều này cho phép tối đa hóa việc sử dụng phần cứng mà không phải hy sinh
tình trạng khối lượng công việc hoặc có nguy cơ bị gián đoạn lớn chẳng hạn như giết chết OOM.

Giao diện áp suất
==================

Thông tin áp lực cho từng tài nguyên được xuất thông qua
tệp tương ứng trong /proc/áp lực/ -- cpu, bộ nhớ và io.

Định dạng như sau::

một số trung bình10=0,00 trung bình60=0,00 trung bình300=0,00 tổng=0
	trung bình đầy đủ10=0,00 trung bình60=0,00 trung bình300=0,00 tổng=0

Dòng "một số" biểu thị phần thời gian trong đó ít nhất một số
nhiệm vụ bị đình trệ trên một tài nguyên nhất định.

Dòng "đầy đủ" biểu thị phần thời gian trong đó tất cả các máy không nhàn rỗi
các nhiệm vụ bị đình trệ trên một tài nguyên nhất định cùng một lúc. Ở trạng thái này
các chu trình CPU thực tế sẽ bị lãng phí và khối lượng công việc tiêu tốn
thời gian kéo dài ở trạng thái này được coi là bị đập mạnh. Cái này có
ảnh hưởng nghiêm trọng đến hiệu suất và rất hữu ích khi phân biệt điều này
tình huống từ trạng thái một số nhiệm vụ bị đình trệ nhưng CPU vẫn
vẫn đang làm việc hiệu quả. Như vậy, thời gian dành cho tập hợp con này của
trạng thái dừng được theo dõi riêng biệt và xuất ở mức trung bình "đầy đủ".

CPU đầy đủ chưa được xác định ở cấp hệ thống, nhưng đã được báo cáo
kể từ phiên bản 5.13 nên nó được đặt thành 0 để tương thích ngược.

Các tỷ lệ (tính theo%) được theo dõi theo xu hướng gần đây trên 10, 60 và
cửa sổ ba trăm giây, cung cấp cái nhìn sâu sắc về các sự kiện ngắn hạn
cũng như xu hướng trung và dài hạn. Tổng thời gian dừng tuyệt đối
(ở chúng tôi) cũng được theo dõi và xuất ra, để cho phép phát hiện độ trễ
mức tăng đột biến không nhất thiết phải tạo ra vết lõm trong thời gian trung bình,
hoặc theo xu hướng trung bình trên các khung thời gian tùy chỉnh.

Giám sát ngưỡng áp suất
==================================

Người dùng có thể đăng ký trình kích hoạt và sử dụng poll() để đánh thức khi tài nguyên
áp suất vượt quá ngưỡng nhất định.

Trình kích hoạt mô tả thời gian ngừng tích lũy tối đa trong một khoảng thời gian cụ thể
cửa sổ thời gian, ví dụ: Tổng thời gian ngừng hoạt động là 100 mili giây trong bất kỳ khoảng thời gian 500 mili giây nào để
tạo ra một sự kiện đánh thức.

Để đăng ký trình kích hoạt, người dùng phải mở tệp giao diện psi trong
/proc/áp lực/ đại diện cho tài nguyên cần được theo dõi và ghi
ngưỡng mong muốn và cửa sổ thời gian. Bộ mô tả tập tin đang mở phải là
được sử dụng để chờ các sự kiện kích hoạt bằng cách sử dụng select(), poll() hoặc epoll().
Định dạng sau được sử dụng::

<some|full> <số tiền tồn đọng trong chúng tôi> <khoảng thời gian trong chúng tôi>

Ví dụ: viết "khoảng 150000 1000000" vào /proc/áp lực/bộ nhớ
sẽ thêm ngưỡng 150ms cho tình trạng dừng bộ nhớ một phần được đo trong
Cửa sổ thời gian 1 giây. Viết "đầy đủ 50000 1000000" vào /proc/áp lực/io
sẽ thêm ngưỡng 50ms cho toàn bộ gian hàng io được đo trong khoảng thời gian 1 giây.

Trình kích hoạt có thể được đặt trên nhiều chỉ số psi và nhiều trình kích hoạt
cho cùng một số liệu psi có thể được chỉ định. Tuy nhiên đối với mỗi trình kích hoạt có một cách riêng
cần có bộ mô tả tập tin để có thể thăm dò nó một cách riêng biệt với những người khác,
do đó, đối với mỗi trình kích hoạt, một tòa nhà open() riêng biệt phải được thực hiện ngay cả
khi mở cùng một tập tin giao diện psi. Viết các thao tác vào một bộ mô tả tập tin
với trình kích hoạt psi hiện có sẽ không thành công với EBUSY.

Màn hình chỉ kích hoạt khi hệ thống chuyển sang trạng thái ngừng hoạt động đối với thiết bị được giám sát
psi và ngừng hoạt động khi thoát khỏi trạng thái dừng. Trong khi hệ thống là
ở trạng thái ngừng tăng trưởng tín hiệu psi được theo dõi với tốc độ 10 lần mỗi
cửa sổ theo dõi.

Hạt nhân chấp nhận kích thước cửa sổ từ 500 mili giây đến 10 giây, do đó tối thiểu
khoảng thời gian cập nhật giám sát là 50ms và tối đa là 1 giây. Giới hạn tối thiểu được đặt thành
ngăn chặn việc bỏ phiếu quá thường xuyên. Giới hạn tối đa được chọn là số đủ cao
sau đó rất có thể không cần đến màn hình và có thể sử dụng mức trung bình psi
thay vào đó.

Người dùng không có đặc quyền cũng có thể tạo màn hình, với hạn chế duy nhất là
kích thước cửa sổ phải là bội số của 2, để tránh sử dụng quá nhiều tài nguyên
cách sử dụng.

Khi được kích hoạt, màn hình psi vẫn hoạt động trong ít nhất một khoảng thời gian.
cửa sổ theo dõi để tránh kích hoạt/hủy kích hoạt nhiều lần khi hệ thống
nảy vào và ra khỏi trạng thái ngừng hoạt động.

Thông báo tới không gian người dùng được giới hạn tỷ lệ ở một thông báo trên mỗi cửa sổ theo dõi.

Trình kích hoạt sẽ hủy đăng ký khi bộ mô tả tệp được sử dụng để xác định
cò súng đã đóng.

Ví dụ về cách sử dụng màn hình không gian người dùng
===============================

::

#include <errno.h>
  #include <fcntl.h>
  #include <stdio.h>
  #include <thăm dò ý kiến.h>
  #include <string.h>
  #include <unistd.h>

/*
   * Giám sát tình trạng ngừng hoạt động một phần bộ nhớ với kích thước cửa sổ theo dõi 1 giây
   * và ngưỡng 150ms.
   */
  int chính() {
	const char trig[] = "khoảng 150000 1000000";
	cấu trúc pollfd fds;
	int n;

fds.fd = open("/proc/áp lực/bộ nhớ", O_RDWR | O_NONBLOCK);
	nếu (fds.fd < 0) {
		printf("/proc/áp lực/lỗi mở bộ nhớ: %s\n",
			lỗi strerror(errno));
		trả về 1;
	}
	fds.events = POLLPRI;

if (write(fds.fd, trig, strlen(trig) + 1) < 0) {
		printf("/proc/áp lực/lỗi ghi bộ nhớ: %s\n",
			lỗi strerror(errno));
		trả về 1;
	}

printf("đang chờ sự kiện...\n");
	trong khi (1) {
		n = thăm dò ý kiến(&fds, 1, -1);
		nếu (n < 0) {
			printf("lỗi thăm dò: %s\n", strerror(errno));
			trả về 1;
		}
		nếu (fds.revents & POLLERR) {
			printf("đã nhận được POLLERR, nguồn sự kiện đã biến mất\n");
			trả về 0;
		}
		nếu (fds.revents & POLLPRI) {
			printf("sự kiện đã được kích hoạt!\n");
		} khác {
			printf("đã nhận được sự kiện không xác định: 0x%x\n", fds.revents);
			trả về 1;
		}
	}

trả về 0;
  }

Giao diện Cgroup2
=================

Trong hệ thống có hạt nhân CONFIG_CGROUPS=y và hệ thống tập tin cgroup2
được gắn kết, thông tin về mức áp suất cũng được theo dõi cho các nhiệm vụ được nhóm lại
thành các nhóm. Mỗi thư mục con trong điểm gắn kết cgroupfs chứa
các tập tin cpu. Pressure, Memory. Pressure và io. Pressure; định dạng là
giống như các tập tin /proc/áp lực/.

Màn hình psi trên mỗi nhóm có thể được chỉ định và sử dụng theo cách tương tự như
những cái trên toàn hệ thống.
