.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/scsi/scsi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Tài liệu hệ thống con SCSI
===============================

Dự án Tài liệu Linux (LDP) duy trì một tài liệu mô tả
hệ thống con SCSI trong dòng nhân Linux (lk) 2.4. Xem:
ZZ0000ZZ. LDP có một
và nhiều kết xuất trang HTML cũng như phần tái bút và pdf.

Lưu ý khi sử dụng các mô-đun trong hệ thống con SCSI
====================================================
Hỗ trợ SCSI trong nhân Linux có thể được mô đun hóa theo một số
nhiều cách khác nhau tùy theo nhu cầu của người dùng cuối.  Để hiểu
lựa chọn của bạn, trước tiên chúng ta nên xác định một vài thuật ngữ.

Lõi scsi (còn được gọi là "cấp trung") chứa lõi của SCSI
hỗ trợ.  Không có nó, bạn không thể làm gì với bất kỳ trình điều khiển SCSI nào khác.
Hỗ trợ lõi SCSI có thể là một mô-đun (scsi_mod.o) hoặc có thể được tích hợp vào
hạt nhân. Nếu lõi là mô-đun thì nó phải là mô-đun SCSI đầu tiên
đã tải và nếu bạn dỡ các mô-đun xuống, nó sẽ phải là mô-đun cuối cùng
đã dỡ hàng.  Trong thực tế, lệnh modprobe và rmmod
sẽ thực thi thứ tự chính xác của các mô-đun tải và dỡ tải trong
hệ thống con SCSI.

Các trình điều khiển cấp trên và cấp dưới riêng lẻ có thể được tải theo bất kỳ thứ tự nào
khi lõi SCSI có trong kernel (được biên dịch hoặc tải
như một mô-đun).  Trình điều khiển đĩa (sd_mod.o), trình điều khiển CD-ROM (sr_mod.o),
trình điều khiển băng [1]_ (st.o) và trình điều khiển chung SCSI (sg.o) đại diện cho phần trên
trình điều khiển cấp độ để hỗ trợ các loại thiết bị khác nhau có thể
được kiểm soát.  Ví dụ, bạn có thể tải trình điều khiển băng từ để sử dụng ổ băng từ,
và sau đó dỡ nó xuống khi bạn không cần thêm trình điều khiển nữa (và giải phóng
bộ nhớ liên quan).

Trình điều khiển cấp thấp hơn là những trình điều khiển hỗ trợ các thẻ riêng lẻ
được hỗ trợ cho nền tảng phần cứng mà bạn đang chạy. Những cái đó
các thẻ riêng lẻ thường được gọi là Bộ điều hợp bus chủ (HBA). Ví dụ như
Trình điều khiển aic7xxx.o được sử dụng để điều khiển tất cả các thẻ điều khiển SCSI gần đây từ
Adaptec. Hầu hết tất cả các trình điều khiển cấp thấp hơn đều có thể được xây dựng dưới dạng mô-đun hoặc
được xây dựng trong hạt nhân.

.. [1] There is a variant of the st driver for controlling OnStream tape
       devices. Its module name is osst.o .