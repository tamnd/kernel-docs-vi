.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/mass-storage.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Tiện ích lưu trữ dung lượng lớn (MSG)
=====================================

Tổng quan
========

Tiện ích lưu trữ dung lượng lớn (hoặc MSG) hoạt động như một thiết bị lưu trữ dung lượng lớn USB,
  xuất hiện trên máy chủ dưới dạng đĩa hoặc ổ CD-ROM.  Nó hỗ trợ
  nhiều đơn vị logic (LUN).  Bộ nhớ sao lưu cho mỗi LUN là
  được cung cấp bởi một tập tin thông thường hoặc một thiết bị khối, quyền truy cập có thể bị hạn chế
  thành chỉ đọc và tiện ích có thể cho biết rằng nó có thể tháo rời và/hoặc
  CD-ROM (cái sau ngụ ý quyền truy cập chỉ đọc).

Yêu cầu của nó rất khiêm tốn; chỉ có một điểm cuối hàng loạt và một điểm cuối hàng loạt
  là cần thiết.  Yêu cầu bộ nhớ lên tới hai bộ đệm 16K.
  Hỗ trợ được bao gồm cho tốc độ đầy đủ, tốc độ cao và SuperSpeed
  hoạt động.

Lưu ý rằng trình điều khiển hơi không di động ở chỗ nó giả định
  một bộ nhớ/bộ đệm DMA sẽ có thể sử dụng được cho việc nhập và xuất hàng loạt
  điểm cuối.  Với hầu hết các bộ điều khiển thiết bị, đây không phải là vấn đề, nhưng
  có thể có một số hạn chế về phần cứng ngăn chặn bộ đệm
  khỏi bị sử dụng bởi nhiều hơn một điểm cuối.

Tài liệu này mô tả cách sử dụng tiện ích từ không gian người dùng,
  liên quan đến chức năng lưu trữ dung lượng lớn (hoặc MSF) và các thiết bị khác
  cách sử dụng nó và nó khác với Tiện ích lưu trữ tệp (hoặc FSG) như thế nào
  (không còn có trong Linux nữa).  Nó sẽ chỉ nói ngắn gọn
  về cách sử dụng MSF trong các tiện ích tổng hợp.

Thông số mô-đun
=================

Tiện ích lưu trữ dung lượng lớn chấp nhận lưu trữ dung lượng lớn cụ thể sau đây
  thông số mô-đun:

- file=tên file[,tên file...]

Tham số này liệt kê các đường dẫn đến tập tin hoặc chặn các thiết bị được sử dụng cho
    lưu trữ dự phòng cho mỗi đơn vị logic.  Có thể có nhiều nhất
    Bộ LUN FSG_MAX_LUNS (8).  Nếu có nhiều tệp được chỉ định hơn, chúng sẽ
    được âm thầm bỏ qua.  Xem thêm thông số “luns”.

ZZ0000ZZ rằng nếu một tập tin được sử dụng làm bộ lưu trữ sao lưu thì nó có thể không
    được sửa đổi bởi bất kỳ quá trình nào khác.  Điều này là do chủ nhà
    giả định dữ liệu không thay đổi nếu nó không biết.  Nó có thể là
    đọc, nhưng (nếu đơn vị logic có thể ghi được) do bộ đệm trên
    phía máy chủ, nội dung không được xác định rõ ràng.

Kích thước của đơn vị logic sẽ được làm tròn xuống đến mức đầy đủ
    khối logic.  Kích thước khối logic là 2048 byte cho LUN
    mô phỏng CD-ROM, kích thước khối của thiết bị nếu tệp sao lưu là
    một thiết bị khối hoặc 512 byte nếu không.

- có thể tháo rời=b[,b...]

Tham số này chỉ định liệu mỗi đơn vị logic có nên được
    có thể tháo rời.  “b” ở đây là “y”, “Y” hoặc “1” cho đúng hoặc “n”,
    “N” hoặc “0” là sai.

Nếu tùy chọn này được đặt cho đơn vị logic, tiện ích sẽ chấp nhận
    Yêu cầu “đẩy” SCSI (Bộ khởi động/dừng).  Khi nó được gửi đi,
    tập tin sao lưu sẽ được đóng lại để mô phỏng quá trình phóng và logic
    máy chủ sẽ không thể gắn kết thiết bị cho đến khi có tệp sao lưu mới
    được chỉ định bởi không gian người dùng trên thiết bị (xem “mục nhập sysfs”
    phần).

Nếu một đơn vị logic không thể tháo rời được (mặc định), một tệp sao lưu
    phải được chỉ định cho nó với tham số “file” làm mô-đun
    được tải.  Điều tương tự cũng áp dụng nếu mô-đun được tích hợp sẵn, không
    ngoại lệ.

Giá trị mặc định của cờ là sai, trước đây là ZZ0000ZZ
    đúng.  Điều này đã được thay đổi để phù hợp hơn với Tiện ích lưu trữ tệp
    và bởi vì xét cho cùng thì nó có vẻ như là một mặc định lành mạnh hơn.  Như vậy để
    duy trì khả năng tương thích với các hạt nhân cũ hơn, tốt nhất nên chỉ định
    các giá trị mặc định.  Ngoài ra, nếu người ta dựa vào mặc định cũ, rõ ràng
    “n” cần phải được chỉ định ngay bây giờ.

Lưu ý rằng “có thể tháo rời” có nghĩa là phương tiện của đơn vị logic có thể được
    được đẩy ra hoặc gỡ bỏ (điều này đúng với ổ đĩa CD-ROM hoặc thẻ
    người đọc).  ZZ0000ZZ có nghĩa là toàn bộ tiện ích có thể
    rút phích cắm khỏi máy chủ; thuật ngữ thích hợp cho điều đó là
    “không thể cắm nóng được”.

- cdrom=b[,b...]

Tham số này xác định liệu mỗi đơn vị logic có nên mô phỏng
    CD-ROM.  Mặc định là sai.

- ro=b[,b...]

Tham số này chỉ định liệu mỗi đơn vị logic có nên được
    được báo cáo là chỉ đọc.  Điều này sẽ ngăn chặn máy chủ sửa đổi
    tập tin sao lưu.

Lưu ý rằng nếu cờ này cho đơn vị logic đã cho là sai nhưng
    không thể mở tập tin sao lưu ở chế độ đọc/ghi, tiện ích
    dù sao cũng sẽ quay lại chế độ chỉ đọc.

Giá trị mặc định cho các đơn vị logic không phải CD-ROM là sai; cho
    đơn vị logic mô phỏng CD-ROM nó buộc phải đúng.

- nofua=b[,b...]

Tham số này chỉ định xem có nên bỏ qua cờ FUA trong SCSI hay không
    Lệnh Write10 và Write12 được gửi đến các đơn vị logic nhất định.

MS Windows gắn bộ lưu trữ di động vào “Chế độ tối ưu hóa loại bỏ” bằng cách
    mặc định.  Tất cả việc ghi vào phương tiện đều đồng bộ, nghĩa là
    đạt được bằng cách thiết lập bit FUA (Force Unit Access) trong SCSI
    Viết (10,12) lệnh.  Điều này buộc mỗi lần ghi phải đợi cho đến khi
    dữ liệu thực sự đã được ghi ra và ngăn chặn các yêu cầu I/O
    tập hợp trong lớp khối làm giảm đáng kể hiệu suất.

Lưu ý rằng điều này có thể có nghĩa là nếu thiết bị được cấp nguồn từ USB và
    người dùng rút phích cắm thiết bị mà không tháo thiết bị trước (lúc này
    ít nhất một số người dùng Windows làm), dữ liệu có thể bị mất.

Giá trị mặc định là sai.

- lun=N

Tham số này chỉ định số lượng đơn vị logic mà tiện ích sẽ
    có.  Nó bị giới hạn bởi FSG_MAX_LUNS (8) và giá trị cao hơn sẽ được
    giới hạn.

Nếu tham số này được cung cấp và số lượng tệp được chỉ định
    trong đối số “file” lớn hơn giá trị của “luns”, tất cả đều vượt quá
    tập tin sẽ bị bỏ qua.

Nếu tham số này không xuất hiện thì số lượng đơn vị logic sẽ
    được suy ra từ số lượng file được chỉ định trong “file”
    tham số.  Nếu tham số tệp cũng bị thiếu, thì một tham số là
    giả định.

- gian hàng=b

Chỉ định liệu tiện ích có được phép tạm dừng hàng loạt điểm cuối hay không.
    Mặc định được xác định theo loại thiết bị USB
    điều khiển, nhưng thường đúng.

Ngoài những điều trên, tiện ích còn chấp nhận những điều sau
  các tham số được xác định bởi khung tổng hợp (chúng phổ biến cho
  tất cả các tiện ích tổng hợp nên chỉ là danh sách nhanh):

- idVendor -- ID nhà cung cấp USB (số nguyên 16 bit)
  - idProduct -- ID sản phẩm USB (số nguyên 16 bit)
  - bcdDevice -- Phiên bản thiết bị USB (BCD) (số nguyên 16 bit)
  - iNhà sản xuất -- Chuỗi nhà sản xuất USB (chuỗi)
  - iProduct -- USB Chuỗi sản phẩm (chuỗi)
  - iSerialNumber -- Chuỗi SerialNumber (chuỗi)

mục sysfs
=============

Đối với mỗi đơn vị logic, tiện ích sẽ tạo một thư mục trong sysfs
  thứ bậc.  Bên trong nó có ba tệp sau được tạo:

- tài liệu

Khi đọc nó trả về đường dẫn tới tập tin sao lưu cho
    đơn vị logic  Nếu không có tập tin sao lưu (chỉ có thể nếu
    đơn vị logic có thể tháo rời được), nội dung trống.

Khi được ghi vào, nó sẽ thay đổi tệp sao lưu theo logic đã cho
    đơn vị.  Sự thay đổi này có thể được thực hiện ngay cả khi đơn vị logic đã cho là
    không được chỉ định là có thể tháo rời (nhưng điều đó có thể trông lạ đối với
    chủ nhà).  Tuy nhiên, nó có thể thất bại nếu máy chủ không cho phép loại bỏ phương tiện
    bằng lệnh Prevent-Allow Medium Removal SCSI.

- ro

Phản ánh trạng thái cờ ro cho đơn vị logic đã cho.  Nó có thể
    được đọc bất cứ lúc nào và được ghi vào khi không có tệp sao lưu
    mở cho đơn vị logic nhất định.

- nofua

Phản ánh trạng thái cờ nofua cho đơn vị logic nhất định.  Nó có thể
    được đọc và viết.

- buộc_đẩy

Khi ghi vào, nó khiến tập tin sao lưu bị ép buộc
    tách khỏi LUN, bất kể máy chủ có cho phép hay không
    nó.  Nội dung không quan trọng, bất kỳ số byte nào khác 0
    được viết sẽ dẫn đến việc phóng ra.

Không thể đọc được.

Ngoài ra, như thường lệ, các giá trị của tham số mô-đun có thể là
  đọc từ các tệp /sys/module/g_mass_storage/parameters/*.

Các tiện ích khác sử dụng chức năng lưu trữ lớn
=========================================

Tiện ích lưu trữ dung lượng lớn sử dụng Chức năng lưu trữ dung lượng lớn để xử lý
  giao thức lưu trữ lớn.  Là một hàm tổng hợp, MSF có thể được sử dụng bởi
  các tiện ích khác (ví dụ: g_multi và acm_ms).

Tất cả thông tin trong các phần trước đều hợp lệ cho các mục khác
  các tiện ích sử dụng MSF, ngoại trừ việc hỗ trợ lưu trữ dung lượng lớn liên quan
  các tham số mô-đun có thể bị thiếu hoặc các tham số có thể có
  một tiền tố.  Để tìm hiểu xem điều nào trong số này là đúng, người ta cần phải
  tham khảo tài liệu của tiện ích hoặc mã nguồn của tiện ích.

Để biết ví dụ về cách đưa chức năng lưu trữ dung lượng lớn vào các tiện ích, một
  có thể xem mass_storage.c, acm_ms.c và multi.c (được sắp xếp theo
  độ phức tạp).

Liên quan đến tiện ích lưu trữ tập tin
===============================

Chức năng lưu trữ lớn và do đó là Tiện ích lưu trữ lớn đã được
  dựa trên Tiện ích lưu trữ tệp.  Sự khác biệt giữa hai là
  MSG là một tiện ích tổng hợp (tức là sử dụng khung tổng hợp)
  trong khi tiện ích lưu trữ tập tin là một tiện ích truyền thống.  Từ không gian người dùng
  quan điểm khác biệt này không thực sự quan trọng, nhưng từ
  quan điểm của hacker hạt nhân, điều này có nghĩa là (i) MSG không
  mã trùng lặp cần thiết để xử lý các lệnh giao thức USB cơ bản và
  (ii) MSF có thể được sử dụng trong bất kỳ thiết bị tổng hợp nào khác.

Vì lý do đó, File Storage Gadget đã bị loại bỏ trong Linux 3.8.
  Tất cả người dùng cần chuyển sang Tiện ích lưu trữ dung lượng lớn.  hai
  các tiện ích hoạt động gần như giống nhau từ bên ngoài ngoại trừ:

1. Trong FSG, các tham số mô-đun “có thể tháo rời” và “cdrom” đặt cờ
     đối với tất cả các đơn vị logic trong khi ở MSG, chúng chấp nhận danh sách y/n
     giá trị cho mỗi đơn vị logic.  Nếu người ta chỉ sử dụng một logic duy nhất
     đơn vị, điều này không quan trọng, nhưng nếu có nhiều hơn, giá trị y/n
     cần được lặp lại cho mỗi đơn vị logic.

2. Mô-đun “serial”, “nhà cung cấp”, “sản phẩm” và “phát hành” của FSG
     các tham số được xử lý trong MSG bởi các tham số của lớp tổng hợp
     được đặt tên lần lượt là: “iSerialnumber”, “idVendor”, “idProduct” và
     “thiết bị bcd”.

3. MSG không hỗ trợ chế độ thử nghiệm của FSG, do đó “vận chuyển”,
     Các tham số mô-đun của “giao thức” và “buflen” FSG không
     được hỗ trợ.  MSG luôn sử dụng giao thức SCSI chỉ với số lượng lớn
     chế độ vận chuyển và 16 bộ đệm KiB.
