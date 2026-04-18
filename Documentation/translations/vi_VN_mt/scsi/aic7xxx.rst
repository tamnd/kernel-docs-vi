.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/aic7xxx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

=============================================================
Adaptec Aic7xxx Fast -> Bộ quản lý gia đình Ultra160 v7.0
========================================================

README cho hệ điều hành Linux

Các thông tin sau có sẵn trong tập tin này:

1. Phần cứng được hỗ trợ
  2. Lịch sử phiên bản
  3. Tùy chọn dòng lệnh
  4. Liên hệ với Adaptec

1. Phần cứng được hỗ trợ
=====================

Các chip Adaptec SCSI và bộ điều hợp máy chủ sau đây được hỗ trợ bởi
   trình điều khiển aic7xxx.

======== ===== ========================== ===== =================
   Chip MIPS Host Bus MaxSync MaxWidth SCBs Ghi chú
   ======== ===== ========================== ===== =================
   aic7770 10 EISA/VL 10 MHz 16Bit 4 1
   aic7850 10 PCI/32 10 MHz 8Bit 3
   aic7855 10 PCI/32 10 MHz 8Bit 3
   aic7856 10 PCI/32 10 MHz 8Bit 3
   aic7859 10 PCI/32 20 MHz 8Bit 3
   aic7860 10 PCI/32 20 MHz 8Bit 3
   aic7870 10 PCI/32 10 MHz 16Bit 16
   aic7880 10 PCI/32 20 MHz 16Bit 16
   aic7890 20 PCI/32 40 MHz 16Bit 16 3 4 5 6 7 8
   aic7891 20 PCI/64 40 MHz 16Bit 16 3 4 5 6 7 8
   aic7892 20 PCI/64-66 80 MHz 16Bit 16 3 4 5 6 7 8
   aic7895 15 PCI/32 20 MHz 16Bit 16 2 3 4 5
   aic7895C 15 PCI/32 20 MHz 16Bit 16 2 3 4 5 8
   aic7896 20 PCI/32 40 MHz 16Bit 16 2 3 4 5 6 7 8
   aic7897 20 PCI/64 40 MHz 16Bit 16 2 3 4 5 6 7 8
   aic7899 20 PCI/64-66 80 MHz 16Bit 16 2 3 4 5 6 7 8
   ======== ===== ========================== ===== =================

1. Thiết bị kênh đôi đa kênh - Một bộ điều khiển phục vụ hai
        xe buýt.
   2. Thiết bị kênh đôi đa chức năng - Hai bộ điều khiển trên một chip.
   3. Command Channel Phụ DMA Engine - Cho phép phân tán danh sách thu thập
        và tìm nạp trước SCB.
   4. Hỗ trợ 64 Byte SCB - Cho phép ngắt kết nối, không gắn thẻ bảng yêu cầu
        cho tất cả các kết hợp mục tiêu/lun có thể.
   5. Hỗ trợ hướng dẫn di chuyển khối - Nhân đôi tốc độ nhất định
        các hoạt động của trình sắp xếp thứ tự.
   6. Công cụ thu thập phân tán kiểu 'Lưỡi lê' - Cải thiện tìm nạp trước S/G
        hiệu suất.
   7. Thanh ghi xếp hàng - Cho phép xếp hàng các giao dịch mới mà không cần
        tạm dừng trình sắp xếp thứ tự.
   8. Nhiều ID mục tiêu - Cho phép bộ điều khiển phản hồi lựa chọn
        làm mục tiêu trên nhiều ID SCSI.

=============== ================================= =========================
   Chip điều khiển Bộ kết nối nội bộ Bus-Bus Bộ kết nối mở rộng Ghi chú
   =============== ================================= =========================
   AHA-274X[A] aic7770 EISA SE-50M SE-HD50F
   AHA-274X[A]W aic7770 EISA SE-HD68F SE-HD68F
                                         SE-50M
   AHA-274X[A]T aic7770 EISA 2 X SE-50M SE-HD50F
   AHA-2842 aic7770 VL SE-50M SE-HD50F
   AHA-2940AU aic7860 PCI/32 SE-50M SE-HD50F
   AVA-2902I aic7860 PCI/32 SE-50M
   AVA-2902E aic7860 PCI/32 SE-50M
   AVA-2906 aic7856 PCI/32 SE-50M SE-DB25F
   APC-7850 aic7850 PCI/32 SE-50M 1
   AVA-2940 aic7860 PCI/32 SE-50M
   AHA-2920B aic7860 PCI/32 SE-50M
   AHA-2930B aic7860 PCI/32 SE-50M
   AHA-2920C aic7856 PCI/32 SE-50M SE-HD50F
   AHA-2930C aic7860 PCI/32 SE-50M
   AHA-2930C aic7860 PCI/32 SE-50M
   AHA-2910C aic7860 PCI/32 SE-50M
   AHA-2915C aic7860 PCI/32 SE-50M
   AHA-2940AU/CN aic7860 PCI/32 SE-50M SE-HD50F
   AHA-2944W aic7870 PCI/32 HVD-HD68F HVD-HD68F
                                       HVD-50M
   AHA-3940W aic7870 PCI/32 2 X SE-HD68F SE-HD68F 2
   AHA-2940UW aic7880 PCI/32 SE-HD68F
                                         SE-50M SE-HD68F
   AHA-2940U aic7880 PCI/32 SE-50M SE-HD50F
   AHA-2940D aic7880 PCI/32
   aHA-2940 A/T aic7880 PCI/32
   AHA-2940D A/T aic7880 PCI/32
   AHA-3940UW aic7880 PCI/32 2 X SE-HD68F SE-HD68F 3
   AHA-3940UWD aic7880 PCI/32 2 X SE-HD68F 2 X SE-VHD68F 3
   AHA-3940U aic7880 PCI/32 2 X SE-50M SE-HD50F 3
   AHA-2944UW aic7880 PCI/32 HVD-HD68F HVD-HD68F
                                        HVD-50M
   AHA-3944UWD aic7880 PCI/32 2 X HVD-HD68F 2 X HVD-VHD68F 3
   AHA-4944UW aic7880 PCI/32
   AHA-2930UW aic7880 PCI/32
   AHA-2940UW Pro aic7880 PCI/32 SE-HD68F SE-HD68F 4
                                        SE-50M
   AHA-2940UW/CN aic7880 PCI/32
   AHA-2940UDual aic7895 PCI/32
   AHA-2940UWDual aic7895 PCI/32
   AHA-3940UWD aic7895 PCI/32
   AHA-3940AUW aic7895 PCI/32
   AHA-3940AUWD aic7895 PCI/32
   AHA-3940AU aic7895 PCI/32
   AHA-3944AUWD aic7895 PCI/32 2 X HVD-HD68F 2 X HVD-VHD68F
   AHA-2940U2B aic7890 PCI/32 LVD-HD68F LVD-HD68F
   AHA-2940U2 OEM aic7891 PCI/64
   AHA-2940U2W aic7890 PCI/32 LVD-HD68F LVD-HD68F
                                        SE-HD68F
                                        SE-50M
   AHA-2950U2B aic7891 PCI/64 LVD-HD68F LVD-HD68F
   AHA-2930U2 aic7890 PCI/32 LVD-HD68F SE-HD50F
                                        SE-50M
   AHA-3950U2B aic7897 PCI/64
   AHA-3950U2D aic7897 PCI/64
   AHA-29160 aic7892 PCI/64-66
   AHA-29160 CPQ aic7892 PCI/64-66
   AHA-29160N aic7892 PCI/32 LVD-HD68F SE-HD50F
                                        SE-50M
   AHA-29160LP aic7892 PCI/64-66
   AHA-19160 aic7892 PCI/64-66
   AHA-29150LP aic7892 PCI/64-66
   AHA-29130LP aic7892 PCI/64-66
   AHA-3960D aic7899 PCI/64-66 2 X LVD-HD68F 2 X LVD-VHD68F
                                       LVD-50M
   AHA-3960D CPQ aic7899 PCI/64-66 2 X LVD-HD68F 2 X LVD-VHD68F
                                       LVD-50M
   AHA-39160 aic7899 PCI/64-66 2 X LVD-HD68F 2 X LVD-VHD68F
                                       LVD-50M
   =============== ================================= =========================

1. Không hỗ trợ BIOS
   2. Cầu DEC21050 PCI-PCI với nhiều chip điều khiển trên bus phụ
   3. Cầu DEC2115X PCI-PCI với nhiều chip điều khiển trên bus phụ
   4. Tất cả ba đầu nối SCSI có thể được sử dụng đồng thời mà không cần
      Hiệu ứng "sơ khai" của SCSI.

2. Lịch sử phiên bản
==================

* 7.0 (ngày 4 tháng 8 năm 2005)
	- Cập nhật trình điều khiển để sử dụng cơ sở hạ tầng lớp vận chuyển SCSI
	- Trình sắp xếp thứ tự được nâng cấp và các bản sửa lỗi cốt lõi từ bộ điều hợp được phát hành lần cuối
	  phiên bản của trình điều khiển.

* 6.2.36 (3/6/2003)
        - Mã chính xác vô hiệu hóa việc kiểm tra lỗi chẵn lẻ PCI.
        - Sửa chữa và đơn giản hóa việc xử lý dư lượng bỏ qua rộng
          tin nhắn.  Mã trước đó sẽ không báo cáo phần dư
          nếu độ dài dữ liệu giao dịch bằng nhau và chúng tôi nhận được
          một tin nhắn IWR.
        - Thêm hỗ trợ cho khung 2.5.X EISA.
        - Cập nhật thay đổi trong giao diện Proc FS 2.5.X SCSI.
        - Phân tích cú pháp tùy chọn dòng lệnh xác thực tên miền chính xác.
        - Khi đàm phán không đồng bộ qua tin nhắn WDTR 8bit, hãy gửi
          SDTR có độ lệch bằng 0 để chắc chắn mục tiêu
          biết chúng tôi không đồng bộ.  Điều này hoạt động xung quanh một lỗi phần sụn
          trong Atlas lượng tử 10K.
        - Xóa trạng thái lỗi PCI trong quá trình đính kèm trình điều khiển để chúng tôi
          không tắt I/O được ánh xạ bộ nhớ do ghi sai
          bởi một số thăm dò trình điều khiển khác đã xảy ra trước khi chúng tôi
          đã tuyên bố người điều khiển.

* 6.2.35 (14/05/2003)
        - Sửa một số cảnh báo của trình biên dịch GCC 3.3.
        - Vận hành đúng trên bộ điều khiển kênh đôi EISA.
        - Thêm hỗ trợ cho scsi_report_device_reset() của 2.5.X.

* 6.2.34 (5/5/2003)
        - Sửa lỗi khóa hồi quy được giới thiệu trong 6.2.29
          có thể gây ra sự đảo ngược thứ tự khóa giữa io_request_lock
          và khóa per-softc của chúng tôi.  Điều này chỉ có thể thực hiện được trên RH9,
          Hạt nhân SuSE và kernel.org 2.4.X.

* 6.2.33 (30/04/2003)
        - Tự động vô hiệu hóa báo cáo lỗi chẵn lẻ PCI sau
          10 lỗi được thông báo cho người dùng.  Những lỗi này là
          kết quả của một số thiết bị khác phát hành giao dịch PCI
          với tính chẵn lẻ xấu.  Một khi người dùng đã được thông báo về
          vấn đề, tiếp tục báo cáo lỗi chỉ làm suy giảm
          hiệu suất của chúng tôi.

* 6.2.32 (28 tháng 3 năm 2003)
        - Danh sách S/G có kích thước động để tránh malloc SCSI
          phân mảnh nhóm và bế tắc lớp giữa SCSI.

* 6.2.28 (20/01/2003)
        - Sửa lỗi xác thực tên miền
        - Thêm khả năng vô hiệu hóa việc kiểm tra lỗi chẵn lẻ PCI.
        - Đầu dò I/O được ánh xạ bộ nhớ nâng cao

* 6.2.20 (7/11/2002)
        - Đã thêm xác thực tên miền.

3. Tùy chọn dòng lệnh
=======================


    .. Warning::

                 ALTERING OR ADDING THESE DRIVER PARAMETERS
                 INCORRECTLY CAN RENDER YOUR SYSTEM INOPERABLE.
                 USE THEM WITH CAUTION.

Đặt tệp .conf vào thư mục /etc/modprobe.d và thêm/chỉnh sửa tệp
   dòng chứa ZZ0000ZZ trong đó
   ZZ0001ZZ là một hoặc nhiều trong số những điều sau đây:

dài dòng

:Định nghĩa: kích hoạt các thông báo thông tin bổ sung trong quá trình vận hành trình điều khiển.
    : Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa


gỡ lỗi: [giá trị]

:Định nghĩa: Cho phép nhiều cấp độ thông tin gỡ lỗi khác nhau
    : Giá trị có thể: 0x0000 = không gỡ lỗi, 0xffff = gỡ lỗi hoàn toàn
    : Giá trị mặc định: 0x0000

không_thăm dò

thăm dò_eisa_vl

:Định nghĩa: Không thăm dò bộ điều khiển EISA/VLB.
		 Đây là một sự chuyển đổi.  Nếu trình điều khiển được biên dịch
		 theo mặc định, không thăm dò bộ điều khiển EISA/VLB,
		 việc chỉ định "no_probe" sẽ kích hoạt việc thăm dò này.
		 Nếu trình điều khiển được biên dịch để thăm dò EISA/VLB
		 bộ điều khiển theo mặc định, chỉ định "no_probe"
		 sẽ vô hiệu hóa việc thăm dò này.

: Giá trị có thể: Tùy chọn này là một nút chuyển đổi
    :Giá trị mặc định: Việc thăm dò EISA/VLB bị tắt theo mặc định.

pci_chẵn lẻ

:Định nghĩa: Chuyển đổi việc phát hiện lỗi chẵn lẻ PCI.
		 Trên nhiều bo mạch chủ có chipset VIA,
		 Tính chẵn lẻ PCI không được tạo chính xác trên
		 Xe buýt PCI.  Phần cứng không thể
		 phân biệt giữa sự chẵn lẻ "giả" này
		 lỗi và lỗi chẵn lẻ thực.  Triệu chứng của
		 vấn đề này là một luồng tin nhắn::

"scsi0: Đã phát hiện lỗi chẵn lẻ dữ liệu trong giai đoạn ghi địa chỉ hoặc ghi dữ liệu"

đầu ra của người lái xe.

: Giá trị có thể: Tùy chọn này là một nút chuyển đổi
    : Giá trị mặc định: Báo cáo lỗi chẵn lẻ PCI bị tắt

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

:Định nghĩa: Thăm dò bus scsi theo thứ tự ngược lại, bắt đầu
		với mục tiêu 15

: Giá trị có thể: Tùy chọn này là cờ
    : Giá trị mặc định: bị vô hiệu hóa

toàn cầu_tag_deep:[giá trị]

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

Trên Bộ điều khiển 0:

- chỉ định độ sâu thẻ là 16 cho mục tiêu 0
		- chỉ định độ sâu thẻ là 64 cho mục tiêu 3
		- chỉ định độ sâu thẻ là 8 cho mục tiêu 4 và 5
		- để mặc định mục tiêu 6
		- chỉ định độ sâu thẻ là 32 cho mục tiêu 1,2,7-15
		- Tất cả các mục tiêu khác giữ nguyên độ sâu mặc định.

	    ::

tag_info:{{},{32,,32}}

Trên Bộ điều khiển 1:

- chỉ định độ sâu thẻ là 32 cho mục tiêu 0 và 2
		- Tất cả các mục tiêu khác giữ nguyên độ sâu mặc định.

seltime:[giá trị]

:Định nghĩa: Chỉ định giá trị thời gian chờ lựa chọn
    :Các giá trị có thể: 0 = 256ms, 1 = 128ms, 2 = 64ms, 3 = 32ms
    : Giá trị mặc định: 0

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


: Giá trị mặc định: Cài đặt SCSI-Select trên bộ điều khiển có SCSI Select
		    tùy chọn cho DV.  Ngược lại, bật để hỗ trợ bộ điều khiển
		    Tốc độ và tắt U160 cho tất cả các loại bộ điều khiển khác.

Ví dụ:

	    ::

dv:{-1,0,,1,1,0}

- Trên Bộ điều khiển 0 để DV ở cài đặt mặc định.
	   - Trên Bộ điều khiển 1 tắt DV.
	   - Bỏ qua cấu hình trên Controller 2.
	   - Trên Bộ điều khiển 3 và 4 bật DV.
	   - Trên Controller 5 tắt DV.

Ví dụ::

tùy chọn aic7xxx aic7xxx=verbose,no_probe,tag_info:{{},{,,10}},seltime:1

cho phép ghi nhật ký dài dòng, Tắt tính năng thăm dò EISA/VLB,
và đặt độ sâu thẻ trên Bộ điều khiển 1/Mục tiêu 2 thành 10 thẻ.

4. Hỗ trợ khách hàng của Adaptec
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