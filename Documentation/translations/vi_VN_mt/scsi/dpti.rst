.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/dpti.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Trình điều khiển Adaptec dpti
===================

Việc phân phối lại và sử dụng ở dạng nguồn, có hoặc không có sửa đổi, là
được phép với điều kiện là việc phân phối lại mã nguồn phải giữ nguyên
thông báo bản quyền ở trên, danh sách các điều kiện này và tuyên bố từ chối trách nhiệm sau đây.

Phần mềm này được cung cấp ZZ0000ZZ bởi Adaptec và
bất kỳ bảo đảm rõ ràng hay ngụ ý nào, bao gồm nhưng không giới hạn ở
những bảo đảm ngụ ý về khả năng bán được và sự phù hợp cho một mục đích cụ thể,
bị từ chối. Trong mọi trường hợp, Adaptec sẽ không được
chịu trách nhiệm pháp lý về bất kỳ hành động trực tiếp, gián tiếp, ngẫu nhiên, đặc biệt, mẫu mực hoặc
thiệt hại mang tính hậu quả (bao gồm nhưng không giới hạn ở việc mua sắm các
hàng hóa hoặc dịch vụ thay thế; mất quyền sử dụng, dữ liệu hoặc lợi nhuận; hoặc kinh doanh
sự gián đoạn) dù gây ra bởi bất kỳ lý thuyết nào về trách nhiệm pháp lý, cho dù trong
hợp đồng, trách nhiệm nghiêm ngặt hoặc vi phạm pháp luật (bao gồm cả sơ suất hoặc lý do khác)
phát sinh dưới bất kỳ hình thức nào từ việc sử dụng phần mềm trình điều khiển này, ngay cả khi được khuyên
về khả năng xảy ra thiệt hại đó.

Trình điều khiển này hỗ trợ các bo mạch Adaptec I2O RAID và DPT SmartRAID V I2O.

Tín dụng
=======

Trình điều khiển linux gốc đã được Karen White chuyển sang Linux khi ở
Máy tính Dell.  Nó được chuyển từ bản gốc của Bob Pasteur (của DPT)
trình điều khiển không phải Linux.  Mark Salyzyn và Bob Pasteur đã tư vấn về bản gốc
người lái xe.

Phiên bản 2.0 của trình điều khiển của Deanna Bonds và Mark Salyzyn.

Lịch sử
=======

Trình điều khiển ban đầu được chuyển sang phiên bản linux 2.0.34

==== =================================================================================
V2.0 Viết lại trình điều khiển.  Tái cấu trúc dựa trên hệ thống con i2o.
     Đây là phiên bản GPL đầy đủ đầu tiên kể từ phiên bản cuối cùng được sử dụng
     tiêu đề i2osig không phải là GPL.  Phiên bản thử nghiệm dành cho nhà phát triển.
V2.1 Thử nghiệm nội bộ
V2.2 Phiên bản phát hành đầu tiên

V2.3 Thay đổi:

- Đã thêm hỗ trợ Raptor
     - Đã sửa lỗi khiến hệ thống bị treo khi tải quá mức với
     - tiện ích quản lý đang chạy (đã xóa GFP_DMA khỏi cờ kmalloc)

V2.4 Phiên bản đầu tiên sẵn sàng được gửi đi để nhúng vào kernel

Thay đổi:

- Thực hiện các đề xuất từ Alan Cox
     - Đã thêm tính toán dư lượng cho lớp sg
     - Xử lý lỗi tốt hơn
     - Đã thêm kiểm tra điều kiện dòng chảy thấp
     - Đã thêm kiểm tra DATAPROTECT
     - Đã thay đổi mã trả lại lỗi
     - Đã sửa lỗi con trỏ trong quy trình đặt lại xe buýt
     - Đã bật thiết lập lại hba từ ioctls (cho phép flash FW khởi động lại và sử dụng
       FW mới mà không cần phải khởi động lại)
     - Đầu ra của quy trình đã thay đổi
==== =================================================================================

TODO
====
- Thêm 64 bit Scatter Gather khi biên dịch trên kiến trúc 64 bit
- Thêm tính năng quét lun thưa thớt
- Thêm mã để kiểm tra xem thiết bị đã được đưa vào chế độ ngoại tuyến có hoạt động không
  hiện đang trực tuyến (ở cấp FW) khi đơn vị kiểm tra sẵn sàng hoặc có yêu cầu
  lệnh từ scsi-core
- Thêm giao diện đọc proc
- lệnh quét bus
- lệnh quét lại
- Thêm mã vào quy trình quét lại để thông báo cho scsi-core về thiết bị mới
- Thêm hỗ trợ cho C-PCI (công cụ cắm nóng)
- Thêm phục hồi lỗi passthru ioctl

Ghi chú
=====
Thẻ DPT tối ưu hóa thứ tự xử lý lệnh.  Do đó,
một lệnh có thể mất tới 6 phút để hoàn thành sau khi được gửi
lên bảng.

Các tập tin dpti_ioctl.h dptsig.h osd_defs.h osd_util.h sys_info.h là một phần của
các tập tin giao diện cho các hoạt động quản lý của Adaptec.  Chúng xác định các cấu trúc được sử dụng
trong ioctls.  Chúng được viết để có thể mang theo được.  Chúng khó đọc nhưng tôi cần
sử dụng chúng 'nguyên trạng' nếu không tôi có thể bỏ lỡ những thay đổi trong giao diện.