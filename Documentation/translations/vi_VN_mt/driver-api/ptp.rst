.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/ptp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Cơ sở hạ tầng đồng hồ phần cứng PTP cho Linux
===============================================

Bộ bản vá này giới thiệu hỗ trợ cho đồng hồ IEEE 1588 PTP trong
  Linux. Cùng với các tùy chọn ổ cắm SO_TIMESTAMPING, điều này
  trình bày một phương pháp tiêu chuẩn hóa để phát triển không gian người dùng PTP
  chương trình, đồng bộ hóa Linux với đồng hồ bên ngoài và sử dụng
  tính năng phụ trợ của đồng hồ phần cứng PTP.

Trình điều khiển lớp mới xuất giao diện kernel cho đồng hồ cụ thể
  trình điều khiển và giao diện không gian người dùng. Cơ sở hạ tầng hỗ trợ một
  bộ hoàn chỉnh chức năng đồng hồ phần cứng PTP.

+ Các thao tác đồng hồ cơ bản
    - Đặt thời gian
    - Có được thời gian
    - Dịch chuyển đồng hồ theo một độ lệch nhất định về mặt nguyên tử
    - Điều chỉnh tần số đồng hồ

+ Tính năng đồng hồ phụ trợ
    - Dấu thời gian các sự kiện bên ngoài
    - Tín hiệu đầu ra định kỳ có thể cấu hình từ không gian người dùng
    - Truy cập Bộ lọc thông thấp (LPF) từ không gian người dùng
    - Đồng bộ hóa thời gian hệ thống Linux thông qua hệ thống con PPS

Nhân đồng hồ phần cứng PTP API
==============================

Trình điều khiển đồng hồ PTP tự đăng ký với trình điều khiển lớp. các
   trình điều khiển lớp xử lý tất cả các giao dịch với không gian người dùng. các
   tác giả của một trình điều khiển đồng hồ chỉ cần thực hiện các chi tiết của
   lập trình phần cứng đồng hồ Người điều khiển đồng hồ thông báo cho lớp
   điều khiển các sự kiện không đồng bộ (cảnh báo và dấu thời gian bên ngoài) thông qua
   một giao diện truyền tin nhắn đơn giản.

Trình điều khiển lớp hỗ trợ nhiều trình điều khiển đồng hồ PTP. Trong sử dụng bình thường
   trường hợp, chỉ cần một đồng hồ PTP. Tuy nhiên, để kiểm tra và
   phát triển, sẽ rất hữu ích nếu có nhiều hơn một đồng hồ trong một
   hệ thống duy nhất, để cho phép so sánh hiệu suất.

Không gian người dùng đồng hồ phần cứng PTP API
===============================================

Trình điều khiển lớp cũng tạo ra một thiết bị ký tự cho mỗi
   đồng hồ đã đăng ký Không gian người dùng có thể sử dụng bộ mô tả tệp đang mở từ
   thiết bị ký tự dưới dạng id đồng hồ POSIX và có thể gọi
   clock_gettime, clock_settime và clock_adjtime.  Những cuộc gọi này
   thực hiện các hoạt động đồng hồ cơ bản.

Các chương trình không gian người dùng có thể điều khiển đồng hồ bằng cách sử dụng các
   ioctls. Một chương trình có thể truy vấn, kích hoạt, cấu hình và vô hiệu hóa
   tính năng đồng hồ phụ trợ. Không gian người dùng có thể nhận được dấu thời gian
   sự kiện thông qua việc chặn read() và poll().

Viết trình điều khiển đồng hồ
=============================

Trình điều khiển đồng hồ bao gồm include/linux/ptp_clock_kernel.h và đăng ký
   chính họ bằng cách trình bày 'struct ptp_clock_info' cho
   phương pháp đăng ký. Trình điều khiển đồng hồ phải thực hiện tất cả các
   các chức năng trong giao diện. Nếu một chiếc đồng hồ không cung cấp một thông số cụ thể
   tính năng phụ trợ thì trình điều khiển chỉ cần trả về -EOPNOTSUPP
   từ các chức năng đó.

Trình điều khiển phải đảm bảo rằng tất cả các phương thức trong giao diện đều được
   tái gia nhập. Vì hầu hết việc triển khai phần cứng đều xử lý giá trị thời gian
   dưới dạng số nguyên 64 bit được truy cập dưới dạng hai thanh ghi 32 bit, trình điều khiển
   nên sử dụng spin_lock_irqsave/spin_unlock_irqrestore để bảo vệ
   chống lại sự truy cập đồng thời. Việc khóa này không thể thực hiện được trong
   trình điều khiển lớp, vì đồng hồ cũng có thể cần khóa
   thói quen phục vụ gián đoạn của tài xế.

Yêu cầu về xung nhịp phần cứng PTP cho '.adjphase'
--------------------------------------------------

Giao diện 'struct ptp_clock_info' có chức năng '.adjphase'.
   Chức năng này có một bộ yêu cầu từ PHC để được
   được thực hiện.

* PHC triển khai thuật toán servo bên trong được sử dụng để
       sửa phần bù được chuyển trong lệnh gọi '.adjphase'.
     * Khi các chức năng điều chỉnh PTP khác được gọi, servo PHC
       thuật toán bị vô hiệu hóa.

ZZ0000ZZ '.adjphase' không phải là chức năng điều chỉnh thời gian đơn giản
   'tăng' thời gian đồng hồ PHC dựa trên độ lệch được cung cấp. Nó
   nên sửa phần bù được cung cấp bằng thuật toán nội bộ.

Phần cứng được hỗ trợ
=====================

* Gianfar eTSEC Freescale

- 2 bộ kích hoạt bên ngoài tem thời gian, cực có thể lập trình (ngắt tùy chọn)
     - 2 thanh ghi cảnh báo (ngắt tùy chọn)
     - 3 tín hiệu định kỳ (ngắt tùy chọn)

* DP83640 quốc gia

- 6 GPIO có thể lập trình làm đầu vào hoặc đầu ra
     - 6 GPIO với các chức năng chuyên dụng (LED/JTAG/đồng hồ) cũng có thể được
       được sử dụng làm đầu vào hoặc đầu ra chung
     - Đầu vào GPIO có thể đánh dấu thời gian kích hoạt bên ngoài
     - Đầu ra GPIO có thể tạo ra tín hiệu định kỳ
     - 1 chân ngắt

* Intel IXP465

- Ảnh chụp nhanh chế độ Slave/Master phụ trợ (ngắt tùy chọn)
     - Thời gian mục tiêu (ngắt tùy chọn)

* Renesas (IDT) ClockMatrix™

- Lên đến 4 kênh PHC độc lập
     - Tích hợp bộ lọc thông thấp (LPF), truy cập qua .adjPhase (tuân thủ ITU-T G.8273.2)
     - Lập trình tín hiệu định kỳ đầu ra
     - Đầu vào có thể lập trình có thể đánh dấu thời gian kích hoạt bên ngoài
     - Cấu hình trình điều khiển và/hoặc phần cứng thông qua phần sụn (idtcm.bin)
          - Cài đặt LPF (băng thông, giới hạn pha, tự động lưu giữ, hỗ trợ lớp vật lý (theo ITU-T G.8273.2))
          - Đồng hồ PTP đầu ra có thể lập trình, bất kỳ tần số nào lên tới 1GHz (đối với các bộ đóng dấu thời gian PHY/MAC khác, chuyển sang ASSP/SoC/FPGA)
          - Khóa đầu vào GNSS, tự động chuyển đổi giữa GNSS và điều khiển PHC trong không gian người dùng (tùy chọn)

* NVIDIA Mellanox

-GPIO
          - Một số biến thể của ConnectX-6 Dx và các sản phẩm mới hơn hỗ trợ một
            GPIO có thể đánh dấu thời gian kích hoạt bên ngoài và một GPIO để tạo
            tín hiệu định kỳ.
          - Một số biến thể của ConnectX-5 và các sản phẩm cũ hơn hỗ trợ một GPIO,
            được định cấu hình để kích hoạt dấu thời gian bên ngoài hoặc tạo ra
            tín hiệu định kỳ.
     - Phiên bản PHC
          - Tất cả các thiết bị ConnectX đều có bộ đếm chạy tự do
          - Các thiết bị ConnectX-6 Dx trở lên có bộ đếm định dạng UTC