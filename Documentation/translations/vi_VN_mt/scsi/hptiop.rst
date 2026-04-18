.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/hptiop.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. include:: <isonum.txt>

===========================================================
Trình điều khiển bộ chuyển đổi Highpoint RocketRAID 3xxx/4xxx (hptiop)
======================================================

Bản đồ đăng ký bộ điều khiển
-----------------------

Đối với bộ điều hợp dựa trên Intel IOP RR44xx, bộ điều khiển IOP được truy cập thông qua PCI BAR0 và BAR2

====================================================
     Đăng ký bù BAR0
     ====================================================
            Bộ giao diện liên kết 0x11C5C IRQ
            Giao diện liên kết 0x11C60 IRQ Xóa
     ====================================================

====================================================
     Đăng ký bù BAR2
     ====================================================
            0x10 Đăng ký tin nhắn gửi đến 0
            0x14 Tin nhắn gửi đến Đăng ký 1
            0x18 Đăng ký tin nhắn gửi đi 0
            0x1C Đăng ký tin nhắn gửi đi 1
            Đăng ký chuông cửa vào 0x20
            Đăng ký trạng thái ngắt đầu vào 0x24
            Đăng ký mặt nạ ngắt đầu vào 0x28
            Đăng ký trạng thái ngắt đi 0x30
            Đăng ký mặt nạ ngắt đi 0x34
            Cổng hàng đợi gửi đến 0x40
            Cổng hàng đợi đi 0x44
     ====================================================

Đối với bộ điều hợp dựa trên Intel IOP, bộ điều khiển IOP được truy cập thông qua PCI BAR0:

====================================================
     Đăng ký bù BAR0
     ====================================================
            0x10 Đăng ký tin nhắn gửi đến 0
            0x14 Tin nhắn gửi đến Đăng ký 1
            0x18 Đăng ký tin nhắn gửi đi 0
            0x1C Đăng ký tin nhắn gửi đi 1
            Đăng ký chuông cửa vào 0x20
            Đăng ký trạng thái ngắt đầu vào 0x24
            Đăng ký mặt nạ ngắt đầu vào 0x28
            Đăng ký trạng thái ngắt đi 0x30
            Đăng ký mặt nạ ngắt đi 0x34
            Cổng hàng đợi gửi đến 0x40
            Cổng hàng đợi đi 0x44
     ====================================================

Đối với các bộ điều hợp dựa trên Marvell không phải Frey IOP, IOP được truy cập thông qua PCI BAR0 và BAR1:

====================================================
     Đăng ký bù BAR0
     ====================================================
         0x20400 Đăng ký chuông cửa vào
         0x20404 Đăng ký mặt nạ ngắt trong nước
         0x20408 Đăng ký chuông cửa đi
         Đăng ký mặt nạ ngắt đi 0x2040C
     ====================================================

====================================================
     Đăng ký bù BAR1
     ====================================================
             Con trỏ đầu hàng đợi vào 0x0
             Con trỏ đuôi hàng đợi vào 0x4
             Con trỏ đầu hàng đợi đi 0x8
             Con trỏ đuôi hàng đợi đi 0xC
            0x10 Đăng ký tin nhắn gửi đến
            Đăng ký tin nhắn gửi đi 0x14
     Hàng đợi gửi đến 0x40-0x1040
     Hàng đợi đi 0x1040-0x2040
     ====================================================

Đối với bộ điều hợp dựa trên Marvell Frey IOP, IOP được truy cập thông qua PCI BAR0 và BAR1:

====================================================
     Đăng ký bù BAR0
     ====================================================
             Thông tin cấu hình 0x0 IOP.
     ====================================================

=======================================================================
     Đăng ký bù BAR1
     =======================================================================
          0x4000 Địa chỉ cơ sở danh sách gửi đến Thấp
          0x4004 Địa chỉ cơ sở danh sách gửi đến Cao
          0x4018 Con trỏ ghi danh sách gửi đến
          Kiểm soát và cấu hình danh sách gửi đến 0x402C
          0x4050 Địa chỉ cơ sở danh sách gửi đi Thấp
          0x4054 Địa chỉ cơ sở danh sách gửi đi Cao
          0x4058 Danh sách gửi đi Sao chép con trỏ Địa chỉ cơ sở bóng thấp
          0x405C Danh sách gửi đi Sao chép con trỏ Địa chỉ cơ sở bóng cao
          Nguyên nhân ngắt danh sách gửi đi 0x4088
          Kích hoạt ngắt danh sách gửi đi 0x408C
         0x1020C Chức năng PCIe 0 Kích hoạt ngắt
         0x10400 PCIe Chức năng 0 đến CPU Thông báo A
         0x10420 CPU sang PCIe Chức năng 0 Tin nhắn A
         0x10480 CPU sang PCIe Chức năng 0 Chuông cửa
         0x10484 CPU sang PCIe Chức năng 0 Kích hoạt chuông cửa
     =======================================================================


Quy trình yêu cầu I/O của Not Marvell Frey
----------------------------------------

Tất cả các yêu cầu được xếp hàng đợi được xử lý thông qua cổng xếp hàng vào/ra.
Gói yêu cầu có thể được phân bổ trong IOP hoặc bộ nhớ máy chủ.

Để gửi yêu cầu đến bộ điều khiển:

- Nhận gói yêu cầu miễn phí bằng cách đọc cổng hàng đợi gửi đến hoặc
      phân bổ một yêu cầu miễn phí trong bộ nhớ kết hợp DMA của máy chủ.

Giá trị được trả về từ cổng hàng đợi gửi đến là giá trị bù
      so với IOP BAR0.

Các yêu cầu được phân bổ trong bộ nhớ máy chủ phải được căn chỉnh trên ranh giới 32 byte.

- Điền vào gói.

- Đăng gói tin lên IOP bằng cách ghi gói tin vào hàng đợi gửi đến. Đối với yêu cầu
      được phân bổ trong bộ nhớ IOP, ghi phần bù vào cổng hàng đợi gửi đến. cho
      yêu cầu được phân bổ trong bộ nhớ máy chủ, ghi (0x80000000|(bus_addr>>5))
      đến cổng xếp hàng vào.

- IOP xử lý yêu cầu. Khi yêu cầu được hoàn thành, nó
      sẽ được đưa vào hàng đợi gửi đi. Một ngắt đi sẽ là
      được tạo ra.

Đối với các yêu cầu được phân bổ trong bộ nhớ IOP, phần bù yêu cầu được đăng lên
      hàng đợi ra ngoài.

Đối với các yêu cầu được phân bổ trong bộ nhớ máy chủ, (0x80000000|(bus_addr>>5))
      được đưa vào hàng đợi gửi đi. Nếu IOP_REQUEST_FLAG_OUTPUT_CONTEXT
      cờ được đặt trong yêu cầu, giá trị ngữ cảnh 32 bit thấp sẽ là
      được đăng thay thế.

- Host đọc hàng đợi gửi đi và hoàn thành yêu cầu.

Đối với các yêu cầu được phân bổ trong bộ nhớ IOP, trình điều khiển máy chủ sẽ giải phóng yêu cầu
      bằng cách ghi nó vào hàng đợi gửi đi.

Các yêu cầu không xếp hàng (đặt lại/xóa, v.v.) có thể được gửi qua tin nhắn gửi đến
đăng ký 0. Một tin nhắn gửi đi có cùng giá trị cho biết đã hoàn thành
của một tin nhắn gửi đến.


Quy trình yêu cầu I/O của Marvell Frey
------------------------------------

Tất cả các yêu cầu xếp hàng đợi được xử lý thông qua danh sách gửi đến/đi.

Để gửi yêu cầu đến bộ điều khiển:

- Phân bổ một yêu cầu miễn phí trong bộ nhớ kết hợp DMA của máy chủ.

Các yêu cầu được phân bổ trong bộ nhớ máy chủ phải được căn chỉnh trên ranh giới 32 byte.

- Điền vào yêu cầu với chỉ mục của yêu cầu trong cờ.

Điền vào đơn vị danh sách gửi đến miễn phí địa chỉ vật lý và kích thước của
      yêu cầu.

Thiết lập con trỏ ghi danh sách gửi đến với chỉ mục của đơn vị trước đó,
      làm tròn thành 0 nếu chỉ mục đạt đến số lượng yêu cầu được hỗ trợ.

- Đăng con trỏ ghi danh sách gửi đến IOP.

- IOP xử lý yêu cầu. Khi yêu cầu được hoàn thành, cờ của
      yêu cầu có or-ed IOPMU_QUEUE_MASK_HOST_BITS sẽ được đưa vào
      đơn vị danh sách gửi đi miễn phí và chỉ mục của đơn vị danh sách gửi đi sẽ là
      đưa vào thanh ghi bóng con trỏ sao chép. Một ngắt đi sẽ là
      được tạo ra.

- Máy chủ đọc thanh ghi bóng con trỏ sao chép danh sách gửi đi và so sánh
      với con trỏ đọc đã lưu trước đó N. Nếu chúng khác nhau, máy chủ sẽ
      đọc đơn vị danh sách gửi đi thứ (N+1).

Máy chủ lấy chỉ mục của yêu cầu từ danh sách gửi đi thứ (N+1)
      đơn vị và hoàn thành yêu cầu.

Các yêu cầu không xếp hàng (đặt lại giao tiếp/đặt lại/xóa, v.v.) có thể được gửi qua PCIe
Chức năng 0 đến CPU Thông báo Thanh ghi. Thanh ghi tin nhắn CPU đến PCIe Chức năng 0
có cùng giá trị cho biết tin nhắn đã hoàn thành.


Giao diện cấp người dùng
---------------------

Trình điều khiển hiển thị các thuộc tính sysfs sau:

================================================
     Mô tả R/W NAME
     ================================================
     chuỗi phiên bản trình điều khiển R
     chuỗi phiên bản phần sụn R phiên bản phần sụn
     ================================================


-----------------------------------------------------------------------------

Bản quyền ZZ0000ZZ 2006-2012 HighPoint Technologies, Inc. Mọi quyền được bảo lưu.

Tập tin này được phân phối với hy vọng nó sẽ hữu ích,
  nhưng WITHOUT ANY WARRANTY; thậm chí không có sự bảo đảm ngụ ý của
  MERCHANTABILITY hoặc FITNESS FOR A PARTICULAR PURPOSE.  Xem
  Giấy phép Công cộng GNU để biết thêm chi tiết.

linux@highpoint-tech.com

ZZ0000ZZ