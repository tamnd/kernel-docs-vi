.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/virt/paravirt_ops.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Paravirt_ops
============

Linux cung cấp hỗ trợ cho các công nghệ ảo hóa ảo hóa khác nhau.
Về mặt lịch sử, các hạt nhân nhị phân khác nhau sẽ được yêu cầu để hỗ trợ
các trình ảo hóa khác nhau; hạn chế này đã được loại bỏ với pv_ops.
Linux pv_ops là một API ảo hóa cho phép hỗ trợ các
siêu giám sát. Nó cho phép mỗi hypervisor ghi đè các hoạt động quan trọng và
cho phép một nhị phân hạt nhân chạy trên tất cả các môi trường thực thi được hỗ trợ
bao gồm cả máy gốc -- không có bất kỳ bộ ảo hóa nào.

pv_ops cung cấp một tập hợp các con trỏ hàm đại diện cho các hoạt động
tương ứng với các hướng dẫn quan trọng cấp thấp và cấp độ cao
chức năng trong các lĩnh vực khác nhau. pv_ops cho phép tối ưu hóa khi chạy
thời gian bằng cách cho phép vá nhị phân các hoạt động quan trọng ở mức độ thấp
lúc khởi động.

Hoạt động pv_ops được phân thành ba loại:

- cuộc gọi gián tiếp đơn giản
   Các hoạt động này tương ứng với chức năng cấp cao nơi nó được
   biết rằng chi phí của cuộc gọi gián tiếp không quan trọng lắm.

- cuộc gọi gián tiếp cho phép tối ưu hóa với bản vá nhị phân
   Thông thường các hoạt động này tương ứng với các hướng dẫn quan trọng ở mức độ thấp. Họ
   được gọi thường xuyên và có hiệu suất rất quan trọng. Chi phí chung là
   rất quan trọng.

- một bộ macro cho mã lắp ráp viết tay
   Mã hợp ngữ viết tay (tệp .S) cũng cần ảo hóa song song
   bởi vì chúng bao gồm các hướng dẫn nhạy cảm hoặc một số đường dẫn mã trong
   chúng rất quan trọng về hiệu suất.