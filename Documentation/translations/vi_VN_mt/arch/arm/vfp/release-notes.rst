.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/vfp/release-notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================================
Ghi chú phát hành cho mã hỗ trợ Linux Kernel VFP
===============================================

Ngày: 20 tháng 5 năm 2004

Tác giả: Russell King

Đây là bản phát hành đầu tiên của mã hỗ trợ Linux Kernel VFP.  Nó
cung cấp hỗ trợ cho các trường hợp ngoại lệ bị trả về từ phần cứng VFP được tìm thấy
trên ARM926EJ-S.

Bản phát hành này đã được xác thực dựa trên thư viện SoftFloat-2b bởi
John R. Hauser sử dụng bộ thử nghiệm TestFloat-2a.  Chi tiết về điều này
thư viện và bộ thử nghiệm có thể được tìm thấy tại:

ZZ0000ZZ

Các hoạt động đã được thử nghiệm với gói này là:

- fdiv
 - fsub
 - mốt nhất thời
 - fmul
 - fcmp
 - fcmpe
 - fcvtd
 - fcvt
 - fsito
 - ftosi
 - fsqrt

Tất cả các bài kiểm tra phần mềm ở trên đều vượt qua với các ngoại lệ sau:

- fadd/fsub cho thấy một số khác biệt trong cách xử lý kết quả +0/-0
  khi các toán hạng đầu vào khác nhau về dấu.
- việc xử lý các trường hợp ngoại lệ tràn hơi khác một chút.  Nếu một
  kết quả tràn xuống trước khi làm tròn, nhưng trở thành số chuẩn hóa
  sau khi làm tròn, chúng tôi không báo hiệu ngoại lệ tràn.

Các hoạt động khác đã được kiểm tra bằng các thử nghiệm lắp ráp cơ bản
là:

- fcpy
 - tuyệt vời
 - fneg
 - ftoui
 - ftosiz
 - ftouiz

Các hoạt động kết hợp chưa được thử nghiệm:

- fmac
 - fnmac
 - fmsc
 - fnmsc
 - fnmul
