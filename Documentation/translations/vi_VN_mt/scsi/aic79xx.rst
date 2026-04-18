.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/aic79xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

======================================
Bộ quản lý gia đình Adaptec Ultra320
======================================

README cho hệ điều hành Linux

.. The following information is available in this file:

  1. Supported Hardware
  2. Version History
  3. Command Line Options
  4. Additional Notes
  5. Contacting Adaptec


1. Phần cứng được hỗ trợ
=====================

Bộ điều hợp máy chủ Adaptec SCSI sau đây được hỗ trợ bởi điều này
   bộ điều khiển.

==========================================================
   Ultra320 ASIC Mô tả
   ==========================================================
   AIC-7901A Kênh đơn 64-bit PCI-X 133 MHz tới
                              Ultra320 SCSI ASIC
   AIC-7901B Kênh đơn 64-bit PCI-X 133 MHz đến
                              Ultra320 SCSI ASIC được đào tạo lại
   AIC-7902A4 Kênh đôi 64-bit PCI-X 133 MHz đến
                              Ultra320 SCSI ASIC
   AIC-7902B Kênh đôi 64-bit PCI-X 133 MHz đến
                              Ultra320 SCSI ASIC được đào tạo lại
   ==========================================================

================================================================== ==============
   Bộ điều hợp Ultra320 Mô tả ASIC
   ================================================================== ==============
   Thẻ Adaptec SCSI 39320 Kênh đôi 64-bit PCI-X 133 MHz đến 7902A4/7902B
                              Thẻ Ultra320 SCSI (một thẻ bên ngoài
                              68 chân, hai bên trong 68 chân)
   Thẻ Adaptec SCSI 39320A Kênh đôi 64-bit PCI-X 133 MHz đến 7902B
                              Thẻ Ultra320 SCSI (một thẻ bên ngoài
                              68 chân, hai bên trong 68 chân)
   Thẻ Adaptec SCSI 39320D Kênh đôi 64-bit PCI-X 133 MHz đến 7902A4
                              Thẻ Ultra320 SCSI (hai thẻ VHDC bên ngoài
                              và một 68 chân bên trong)
   Thẻ Adaptec SCSI 39320D Kênh đôi 64-bit PCI-X 133 MHz đến 7902A4
                              Thẻ Ultra320 SCSI (hai thẻ VHDC bên ngoài
                              và một 68 chân bên trong) dựa trên
                              AIC-7902B ASIC
   Thẻ Adaptec SCSI 29320 Kênh đơn 64-bit PCI-X 133 MHz đến 7901A
                              Thẻ Ultra320 SCSI (một thẻ bên ngoài
                              68 chân, hai chân 68 chân bên trong, một
                              50 chân bên trong)
   Thẻ Adaptec SCSI 29320A Kênh đơn 64-bit PCI-X 133 MHz đến 7901B
                              Thẻ Ultra320 SCSI (một thẻ bên ngoài
                              68 chân, hai chân 68 chân bên trong, một
                              50 chân bên trong)
   Thẻ Adaptec SCSI 29320LP Cấu hình thấp 64-bit kênh đơn 7901A
                              Thẻ PCI-X 133 MHz đến Ultra320 SCSI
                              (Một VHDC bên ngoài, một bên trong
                              68 chân)
   Thẻ Adaptec SCSI 29320ALP Cấu hình thấp 64-bit kênh đơn 7901B
                              Thẻ PCI-X 133 MHz đến Ultra320 SCSI
                              (Một VHDC bên ngoài, một bên trong
                              68 chân)
   ================================================================== ==============

2. Lịch sử phiên bản
==================


* 3.0 (ngày 1 tháng 12 năm 2005)
	- Cập nhật trình điều khiển để sử dụng cơ sở hạ tầng lớp vận chuyển SCSI
	- Trình sắp xếp thứ tự được nâng cấp và các bản sửa lỗi cốt lõi từ Adaptec đã được phát hành
	  phiên bản 2.0.15 của trình điều khiển.

* 1.3.11 (11 tháng 7 năm 2003)
        - Khắc phục một số vấn đề bế tắc.
        - Thêm Id 29320ALP và 39320B.

* 1.3.10 (3/6/2003)
        - Căn chỉnh trường SCB_TAG theo ranh giới 16byte.  Điều này tránh
          Lỗi SCB trên một số bus PCI-33.
        - Sửa các lun khác 0 trên phần cứng Rev B.
        - Cập nhật thay đổi trong giao diện Proc FS 2.5.X SCSI.
        - Khi đàm phán không đồng bộ qua tin nhắn WDTR 8bit, hãy gửi
          SDTR có độ lệch bằng 0 để chắc chắn mục tiêu
          biết chúng tôi không đồng bộ.  Điều này hoạt động xung quanh một lỗi phần sụn
          trong Atlas lượng tử 10K.
        - Thực hiện tạm dừng và tiếp tục điều khiển.
        - Xóa trạng thái lỗi PCI trong quá trình đính kèm trình điều khiển để chúng tôi
          không tắt I/O được ánh xạ bộ nhớ do ghi sai
          bởi một số thăm dò trình điều khiển khác đã xảy ra trước khi chúng tôi
          đã tuyên bố người điều khiển.

* 1.3.9 (22 tháng 5 năm 2003)
        - Sửa lỗi biên dịch.
        - Loại bỏ việc phân tách S/G cho các phân đoạn vượt qua ranh giới 4GB.
          Điều này được đảm bảo không xảy ra trong Linux.
        - Thêm hỗ trợ cho scsi_report_device_reset() được tìm thấy trong
          Hạt nhân 2.5.X.
        - Thêm hỗ trợ 7901B.
        - Đơn giản hóa việc xử lý gói lun Rev A.
        - Sửa chữa và đơn giản hóa việc xử lý dư lượng bỏ qua rộng
          tin nhắn.  Mã trước đó sẽ không báo cáo phần dư
          nếu độ dài dữ liệu giao dịch bằng nhau và chúng tôi nhận được
          một tin nhắn IWR.

* 1.3.8 (29 tháng 4 năm 2003)
        - Sửa lỗi các kiểu truy cập thông qua mã giao diện dòng lệnh.
        - Thực hiện một số tối ưu hóa phần mềm.
        - Sửa lỗi "Unexpected PKT busfree".
        - Sử dụng ngắt trình tự tuần tự để thông báo cho máy chủ về
          lệnh có trạng thái xấu.  Chúng tôi trì hoãn thông báo
          cho đến khi không còn lựa chọn nào nổi bật để đảm bảo
          rằng máy chủ bị gián đoạn trong một thời gian ngắn như
          có thể.
        - Loại bỏ hỗ trợ trước 2.2.X.
        - Thêm hỗ trợ cho ngắt 2.5.X mới API.
        - Hỗ trợ đúng kiến ​​trúc big-endian.

* 1.3.7 (16 tháng 4 năm 2003)
        - Sử dụng del_timer_sync() để đảm bảo không có thời gian chờ
          đang chờ xử lý trong khi tắt bộ điều khiển.
        - Đối với các hạt nhân trước 2.5.X, hãy điều chỉnh cẩn thận phân đoạn của chúng tôi
          kích thước danh sách để tránh phân mảnh nhóm malloc SCSI.
        - Hiển thị kênh dọn dẹp trong đầu ra /proc của chúng tôi.
        - Giải pháp thay thế các mục nhập thiết bị trùng lặp ở lớp giữa
          danh sách thiết bị trong quá trình thêm một thiết bị.

* 1.3.6 (28 tháng 3 năm 2003)
        - Sửa lỗi double free trong mã Domain Validation.
        - Sửa tham chiếu đến bộ nhớ đã giải phóng trong quá trình điều khiển
          tắt máy.
        - Đặt lại bus khi thay đổi SE->LVD.  Điều này là bắt buộc
          để thiết lập lại bộ thu phát của chúng tôi.

* 1.3.5 (24 tháng 3 năm 2003)
        - Sửa một số lỗi chế độ cửa sổ đăng ký.
        - Bao gồm tính năng đọc trực tuyến trong các cờ PPR mà chúng tôi hiển thị trong
          chẩn đoán cũng như /proc.
        - Thêm hỗ trợ cắm nóng PCI cho kernel 2.5.X.
        - Sửa giá trị bù trước mặc định cho phần cứng RevA.
        - Sửa lỗi tắt luồng xác thực tên miền.
        - Thêm giải pháp khắc phục lỗi phần mềm khiến LED nhấp nháy
          sáng hơn trong các hoạt động đóng gói trên H2A4.
        - Hiển thị chính xác /proc cài đặt phát trực tuyến đọc của người dùng.
        - Đơn giản hóa việc khóa trình điều khiển bằng cách giải phóng io_request_lock
          khi người lái xe vào từ lớp giữa.
        - Dọn dẹp phân tích cú pháp dòng lệnh và di chuyển phần lớn mã này
          đến aiclib.

* 1.3.4 (28 tháng 2 năm 2003)
        - Sửa điều kiện chạy đua trong trình xử lý khôi phục lỗi của chúng tôi.
        - Cho phép các lệnh Test Unit Ready mất đủ 5 giây
          trong quá trình xác thực tên miền.

* 1.3.2 (19 tháng 2 năm 2003)
        - Sửa lỗi hồi quy Rev B. do GEM318
          sửa lỗi tương thích có trong 1.3.1.

* 1.3.1 (11/02/2003)
        - Thêm hỗ trợ cho 39320A.
        - Cải thiện khả năng phục hồi đối với một số lỗi PCI-X.
        - Sửa lỗi xử lý LQ/DATA/LQ/DATA cho
          cùng một giao dịch ghi có thể xảy ra mà không cần
          đào tạo xen kẽ.
        - Khắc phục sự cố tương thích với GEM318
          thiết bị dịch vụ bao vây.
        - Khắc phục sự cố hỏng dữ liệu xảy ra trong
          tải độ sâu ghi thẻ cao.
        - Thích ứng với sự thay đổi trong daemonize() 2.5.X API.
        - Sửa lỗi "Thiếu trường hợp trong ahd_handle_scsiint".

* 1.3.0 (21 tháng 1 năm 2003)
        - Kiểm tra hồi quy đầy đủ cho tất cả các sản phẩm U320 đã hoàn thành.
        - Đã thêm trình xử lý khôi phục lỗi hủy bỏ và đặt lại mục tiêu/lun và
          làm gián đoạn quá trình kết tụ.

* 1.2.0 (14 tháng 11 năm 2002)
        - Đã thêm hỗ trợ xác thực tên miền
        - Thêm hỗ trợ cho phiên bản Hewlett-Packard của 39320D
          và bộ điều hợp AIC-7902.

Hỗ trợ cho các bộ điều hợp trước đó chưa được kiểm tra đầy đủ và sẽ
        chỉ được sử dụng với rủi ro của riêng khách hàng.

* 1.1.1 (24 tháng 9 năm 2002)
        - Đã thêm hỗ trợ cho dòng kernel Linux 2.5.X

* 1.1.0 (17 tháng 9 năm 2002)
        - Đã thêm hỗ trợ cho bốn sản phẩm SCSI bổ sung:
          ASC-39320, ASC-29320, ASC-29320LP, AIC-7901.

* 1.0.0 (30/5/2002)
        - Phát hành trình điều khiển ban đầu.

* 2.1. Tính năng phần mềm/phần cứng
        - Hỗ trợ chuẩn SPI-4 "Ultra320":
          - Tốc độ truyền 320MB/s
          - Giao thức SCSI được đóng gói ở tốc độ 160MB/s và 320MB/s
          - Lựa chọn trọng tài nhanh (QAS)
          - Thông tin đào tạo được giữ lại (chỉ Rev B. ASIC)
        - Ngắt kết hợp
        - Chế độ khởi tạo (hiện tại không có chế độ mục tiêu
          được hỗ trợ)
        - Hỗ trợ chuẩn PCI-X lên tới 133 MHz
        - Hỗ trợ chuẩn PCI v2.2
        - Xác thực tên miền

* 2.2. Hỗ trợ hệ điều hành:
        - Redhat Linux 7.2, 7.3, 8.0, Máy chủ nâng cao 2.1
        - SuSE Linux 7.3, 8.0, 8.1, Máy chủ doanh nghiệp 7
        - hiện tại chỉ hỗ trợ Intel và AMD x86
        - >Hỗ trợ cấu hình bộ nhớ 4GB.

Tham khảo Hướng dẫn sử dụng để biết thêm chi tiết về điều này.

3. Tùy chọn dòng lệnh
=======================

    .. Warning::

	         ALTERING OR ADDING THESE DRIVER PARAMETERS
                 INCORRECTLY CAN RENDER YOUR SYSTEM INOPERABLE.
                 USE THEM WITH CAUTION.

Đặt tệp .conf vào thư mục /etc/modprobe.d/ và thêm/chỉnh sửa tệp
   dòng chứa ZZ0000ZZ trong đó
   ZZ0001ZZ là một hoặc nhiều trong số những điều sau đây:


dài dòng
    :Định nghĩa: kích hoạt các thông báo thông tin bổ sung trong quá trình vận hành trình điều khiển.
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

gỡ lỗi: [giá trị]
    :Định nghĩa: Cho phép nhiều cấp độ thông tin gỡ lỗi khác nhau
                 Các định nghĩa bit cho mặt nạ gỡ lỗi có thể
                 được tìm thấy trong driver/scsi/aic7xxx/aic79xx.h bên dưới
                 tiêu đề "Gỡ lỗi".
    : Giá trị có thể: 0x0000 = không gỡ lỗi, 0xffff = gỡ lỗi hoàn toàn
    : Giá trị mặc định: 0x0000

no_reset
    :Định nghĩa: Không thiết lập lại bus trong quá trình thăm dò ban đầu
                 giai đoạn
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

mở rộng
    :Định nghĩa: Buộc dịch mở rộng trên bộ điều khiển
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

định kỳ_otag
    :Định nghĩa: Gửi thẻ theo thứ tự định kỳ để ngăn chặn
                 đánh dấu nạn đói.  Cần thiết cho một số thiết bị cũ
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

quét ngược
    :Định nghĩa: Thăm dò bus scsi theo thứ tự ngược lại, bắt đầu từ mục tiêu 15
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

toàn cầu_tag_deep
    :Định nghĩa: Độ sâu thẻ toàn cầu cho tất cả các mục tiêu trên tất cả các bus.
		 Tùy chọn này đặt độ sâu thẻ mặc định
		 có thể được ghi đè có chọn lọc thông qua tag_info
		 tùy chọn.

: Giá trị có thể: 1 - 253
    : Giá trị mặc định: 32

tag_info:{{value[,value...]fer,{value[,value...]}...]}
    :Định nghĩa: Đặt độ sâu hàng đợi được gắn thẻ cho mỗi mục tiêu trên một
                 theo cơ sở điều khiển.  Cả bộ điều khiển và mục tiêu
                 có thể được bỏ qua chỉ ra rằng họ nên giữ lại
                 độ sâu thẻ mặc định.

: Giá trị có thể: 1 - 253
    : Giá trị mặc định: 32

Ví dụ:


	::

tag_info:{{16,32,32,64,8,8,,32,32,32,32,32,32,32,32,32}

Trên Bộ điều khiển 0

- chỉ định độ sâu thẻ là 16 cho mục tiêu 0
	    - chỉ định độ sâu thẻ là 64 cho mục tiêu 3
	    - chỉ định độ sâu thẻ là 8 cho mục tiêu 4 và 5
	    - để mặc định mục tiêu 6
	    - chỉ định độ sâu thẻ là 32 cho mục tiêu 1,2,7-15

Tất cả các mục tiêu khác giữ nguyên độ sâu mặc định.

	::

tag_info:{{},{32,,32}}

Trên Bộ điều khiển 1

- chỉ định độ sâu thẻ là 32 cho mục tiêu 0 và 2

Tất cả các mục tiêu khác giữ nguyên độ sâu mặc định.


rd_strm: {rd_strm_bitmask[,rd_strm_bitmask...]}
    :Định nghĩa: Cho phép truyền phát đọc trên cơ sở từng mục tiêu.
		 rd_strm_bitmask là giá trị hex 16 bit trong đó
		 mỗi bit đại diện cho một mục tiêu.  Việc thiết lập mục tiêu
		 bit thành '1' cho phép đọc luồng cho điều đó
		 mục tiêu.  Bộ điều khiển có thể được bỏ qua chỉ ra rằng
		 họ nên giữ lại cài đặt phát trực tuyến đọc mặc định.

Ví dụ:

	    ::

rd_strm:{0x0041}

Trên Bộ điều khiển 0

- cho phép đọc luồng cho mục tiêu 0 và 6.
		- vô hiệu hóa việc đọc luồng cho các mục tiêu 1-5,7-15.

Tất cả các mục tiêu khác giữ nguyên chế độ đọc mặc định
	    cài đặt phát trực tuyến.

	    ::

rd_strm:{0x0023,,0xFFFF}

Trên Bộ điều khiển 0

- cho phép đọc luồng cho các mục tiêu 1,2 và 5.
		- vô hiệu hóa việc đọc luồng cho các mục tiêu 3,4,6-15.

Trên Bộ điều khiển 2

- cho phép đọc luồng cho tất cả các mục tiêu.

Tất cả các mục tiêu khác giữ nguyên chế độ đọc mặc định
	    cài đặt phát trực tuyến.

: Giá trị có thể: 0x0000 - 0xffff
    : Giá trị mặc định: 0x0000

dv: {giá trị[,giá trị...]}
    :Định nghĩa: Đặt Chính sách xác thực tên miền trên cơ sở từng bộ điều khiển.
                 Bộ điều khiển có thể được bỏ qua chỉ ra rằng
                 họ nên giữ lại cài đặt phát trực tuyến đọc mặc định.

: Các giá trị có thể có:

==== ==================================
		       < 0 Sử dụng cài đặt từ EEPROM nối tiếp.
                         0 Tắt DV
		       > 0 Bật DV
		      ==== ==================================

: Giá trị mặc định: Cài đặt cấu hình DV Serial EEPROM.

Ví dụ:

	::

dv:{-1,0,,1,1,0}

- Trên Bộ điều khiển 0 để DV ở cài đặt mặc định.
	- Trên Bộ điều khiển 1 tắt DV.
	- Bỏ qua cấu hình trên Controller 2.
	- Trên Bộ điều khiển 3 và 4 bật DV.
	- Trên Controller 5 tắt DV.

seltime:[giá trị]
    :Định nghĩa: Chỉ định giá trị thời gian chờ lựa chọn
    :Các giá trị có thể: 0 = 256ms, 1 = 128ms, 2 = 64ms, 3 = 32ms
    : Giá trị mặc định: 0

.. Warning:

    The following three options should only be changed at
    the direction of a technical support representative.


biên dịch trước: {value[,value...]}
    :Định nghĩa: Đặt giá trị bù trước ô IO trên cơ sở mỗi bộ điều khiển.
                 Bộ điều khiển có thể được bỏ qua chỉ ra rằng
                 họ nên giữ lại cài đặt bù trước mặc định.

: Giá trị có thể: 0 - 7
    : Giá trị mặc định: Khác nhau tùy theo phiên bản chip

Ví dụ:

	::

biên dịch trước:{0x1}

Trên Bộ điều khiển 0, đặt bù trước thành 1.

	::

biên dịch trước:{1,,7}

- Trên Bộ điều khiển 0 đặt bù trước thành 1.
	- Trên Bộ điều khiển 2 đặt bù trước thành 8.

tốc độ quay: {value[,value...]}
    :Định nghĩa: Đặt tốc độ xoay Ô IO trên cơ sở mỗi bộ điều khiển.
                      Bộ điều khiển có thể được bỏ qua chỉ ra rằng
                      họ nên giữ lại cài đặt tốc độ quay mặc định.

: Giá trị có thể: 0 - 15
    : Giá trị mặc định: Khác nhau tùy theo phiên bản chip

Ví dụ:

	::

tốc độ quay:{0x1}

- Trên Bộ điều khiển 0 đặt tốc độ quay thành 1.

	::

tốc độ quay :{1,,8}

- Trên Bộ điều khiển 0 đặt tốc độ quay thành 1.
	- Trên Bộ điều khiển 2 đặt tốc độ quay thành 8.

biên độ: {value[,value...]}
    :Định nghĩa: Đặt biên độ tín hiệu IO Cell trên cơ sở mỗi bộ điều khiển.
                 Bộ điều khiển có thể được bỏ qua chỉ ra rằng
                 họ nên giữ lại cài đặt phát trực tuyến đọc mặc định.

: Giá trị có thể: 1 - 7
    : Giá trị mặc định: Khác nhau tùy theo phiên bản chip

Ví dụ:

    ::

biên độ:{0x1}

Trên Bộ điều khiển 0 đặt biên độ thành 1.

    ::

biên độ :{1,,7}

- Trên Bộ điều khiển 0 đặt biên độ thành 1.
    - Trên Bộ điều khiển 2 đặt biên độ thành 7.

Ví dụ::

tùy chọn aic79xx aic79xx=verbose,rd_strm:{{0x0041}}

cho phép đầu ra dài dòng trong trình điều khiển và bật tính năng đọc trực tuyến
cho mục tiêu 0 và 6 của Bộ điều khiển 0.

4. Ghi chú bổ sung
===================

4.1. Các vấn đề đã biết/chưa được giải quyết hoặc FYI
-----------------------------------

* Trong SuSE Linux Enterprise 7, trình điều khiển có thể không hoạt động
          chính xác do có vấn đề với định tuyến ngắt PCI trong
          Hạt nhân Linux.  Vui lòng liên hệ với SuSE để có bản Linux cập nhật
          hạt nhân.

4.2. Sự cố tương thích của bên thứ ba
-------------------------------------

* Adaptec chỉ hỗ trợ chạy ổ cứng Ultra320
          chương trình cơ sở mới nhất hiện có. Vui lòng kiểm tra với
          nhà sản xuất ổ cứng của bạn để đảm bảo bạn có
          phiên bản mới nhất.

4.3. Hạn chế về hệ điều hành hoặc công nghệ
-----------------------------------------------

* Ổ cắm nóng PCI chưa được kiểm tra và có thể gây ra lỗi hệ điều hành
          để ngừng phản hồi.
        * Các Lun không được đánh số liên tục bắt đầu bằng 0 có thể không được đánh số
          được tự động thăm dò trong quá trình khởi động hệ thống.  Đây là một hạn chế
          của hệ điều hành.  Vui lòng liên hệ với nhà cung cấp Linux của bạn để được hướng dẫn về
          thăm dò thủ công các luns không liền kề.
        * Sử dụng phiên bản Đĩa cập nhật trình điều khiển của gói này trong hệ điều hành
          cài đặt trong RedHat có thể dẫn đến hai phiên bản này
          trình điều khiển đang được cài đặt vào thư mục mô-đun hệ thống.  Cái này
          có thể gây ra sự cố với chương trình /sbin/mkinitrd và/hoặc
          các gói RPM khác cố gắng cài đặt các mô-đun hệ thống.  điều tốt nhất
          Cách khắc phục điều này khi hệ thống đang chạy là cài đặt
          phiên bản gói RPM mới nhất của trình điều khiển này, có sẵn từ
          ZZ0000ZZ


5. Hỗ trợ khách hàng của Adaptec
===========================

Cần có Số nhận dạng hỗ trợ kỹ thuật (TSID) cho
   Hỗ trợ kỹ thuật Adaptec.

- TSID gồm 12 chữ số có thể được tìm thấy trên nhãn loại mã vạch màu trắng
      đi kèm bên trong hộp với sản phẩm của bạn.  TSID giúp chúng tôi
      cung cấp dịch vụ hiệu quả hơn bằng cách xác định chính xác
      trạng thái sản phẩm và hỗ trợ.

Tùy chọn hỗ trợ
    - Tìm kiếm Cơ sở kiến thức Hỗ trợ Adaptec (ASK) tại
      ZZ0000ZZ để biết các bài viết, mẹo khắc phục sự cố và
      câu hỏi thường gặp về sản phẩm của bạn.
    - Để được hỗ trợ qua Email, hãy gửi câu hỏi của bạn tới Adaptec's
      Chuyên gia hỗ trợ kỹ thuật tại ZZ0001ZZ

Bắc Mỹ
    - Truy cập trang web của chúng tôi tại ZZ0000ZZ
    - Để biết thông tin về các tùy chọn hỗ trợ của Adaptec, hãy gọi
      408-957-2550, 24 giờ một ngày, 7 ngày một tuần.
    - Để nói chuyện với Chuyên gia hỗ trợ kỹ thuật,

* Đối với sản phẩm phần cứng, hãy gọi 408-934-7274,
        Thứ Hai đến Thứ Sáu, 3 giờ sáng đến 5 giờ chiều, PDT.
      * Đối với các sản phẩm RAID và Fibre Channel, hãy gọi 321-207-2000,
        Thứ Hai đến Thứ Sáu, 3 giờ sáng đến 5 giờ chiều, PDT.

Để đẩy nhanh dịch vụ của bạn, hãy mang theo máy tính bên mình.
    - Đặt mua sản phẩm Adaptec, bao gồm phụ kiện và cáp,
      gọi 408-957-7274.  Để đặt mua cáp trực tuyến, hãy truy cập
      ZZ0000ZZ

Châu Âu
    - Truy cập trang web của chúng tôi tại ZZ0000ZZ
    - Để nói chuyện với Chuyên gia hỗ trợ kỹ thuật, hãy gọi điện hoặc gửi email,

* Tiếng Đức: +49 89 4366 5522, Thứ Hai-Thứ Sáu, 9:00-17:00 CET,
        ZZ0000ZZ
      * Tiếng Pháp: +49 89 4366 5533, Thứ Hai-Thứ Sáu, 9:00-17:00 CET,
	ZZ0001ZZ
      * Tiếng Anh: +49 89 4366 5544, Thứ Hai-Thứ Sáu, 9:00-17:00 GMT,
	ZZ0002ZZ

- Bạn có thể đặt mua cáp Adaptec trực tuyến tại
      ZZ0000ZZ

Nhật Bản
    - Truy cập trang web của chúng tôi tại ZZ0000ZZ
    - Để nói chuyện với Chuyên gia hỗ trợ kỹ thuật, hãy gọi
      +81 3 5308 6120, Thứ Hai-Thứ Sáu, 9:00 sáng đến 12:00 trưa,
      1 giờ chiều đến 6 giờ chiều

Bản quyền ZZ0000ZZ 2003 Adaptec Inc. 691 S. Milpitas Blvd., Milpitas CA 95035 USA.
Mọi quyền được bảo lưu.

Bạn được phép phân phối lại, sử dụng và sửa đổi toàn bộ tệp README này
hoặc một phần kết hợp với việc phân phối lại phần mềm được quản lý bởi
Giấy phép Công cộng Chung, với điều kiện đáp ứng các điều kiện sau:

1. Việc phân phối lại tệp README phải giữ bản quyền trên
   thông báo, danh sách các điều kiện này và tuyên bố từ chối trách nhiệm sau đây,
   mà không cần sửa đổi.
2. Không được sử dụng tên tác giả để xác nhận hoặc quảng bá sản phẩm
   bắt nguồn từ phần mềm này mà không có sự cho phép cụ thể trước bằng văn bản.
3. Các sửa đổi hoặc đóng góp mới phải được ghi nhận trong bản quyền
   thông báo xác định tác giả ("Người đóng góp") và được thêm vào bên dưới
   thông báo bản quyền gốc. Thông báo bản quyền là nhằm mục đích
   xác định những người đóng góp và không được coi là được phép thay đổi
   các quyền do Adaptec đưa ra.

THIS README FILE LÀ PROVIDED BỞI ADAPTEC AND CONTRIBUTORS ZZ0000ZZ AND
ANY EXPRESS HOẶC IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED ĐẾN, ANY
WARRANTIES CỦA NON-INFRINGEMENT HOẶC THE IMPLIED WARRANTIES CỦA MERCHANTABILITY
AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. KHÔNG CÓ EVENT SHALL
ADAPTEC HOẶC CONTRIBUTORS LÀ LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
SPECIAL, EXEMPLARY, HOẶC CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
ĐẾN, PROCUREMENT CỦA SUBSTITUTE GOODS HOẶC SERVICES; LOSS CỦA USE, DATA, HOẶC
PROFITS; HOẶC BUSINESS INTERRUPTION) HOWEVER CAUSED AND TRÊN ANY THEORY CỦA
LIABILITY, WHETHER TRONG CONTRACT, STRICT LIABILITY, HOẶC TORT (INCLUDING
NEGLIGENCE HOẶC OTHERWISE) ARISING TRONG ANY WAY OUT CỦA THE USE CỦA THIS README
FILE, EVEN NẾU ADVISED CỦA THE POSSIBILITY CỦA SUCH DAMAGE.