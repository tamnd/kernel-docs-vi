.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/virt/kvm/s390/s390-pv-dump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
s390 (IBM Z) Kết xuất ảo hóa được bảo vệ
===========================================

Bản tóm tắt
-------

Kết xuất VM là một công cụ thiết yếu để gỡ lỗi các vấn đề bên trong
nó. Điều này đặc biệt đúng khi một máy ảo được bảo vệ gặp rắc rối như
không có cách nào để truy cập vào bộ nhớ và các thanh ghi của nó từ bên ngoài
trong khi nó đang chạy.

Tuy nhiên, khi hủy bỏ một VM được bảo vệ, chúng ta cần duy trì nó
bí mật cho đến khi bãi chứa nằm trong tay chủ sở hữu VM, người
phải là người duy nhất có khả năng phân tích nó.

Tính bảo mật của kết xuất VM được đảm bảo bởi Ultravisor, người
cung cấp giao diện cho KVM qua đó dữ liệu bộ nhớ và CPU được mã hóa
có thể được yêu cầu. Việc mã hóa dựa trên Khách hàng
Khóa giao tiếp là khóa được sử dụng để mã hóa dữ liệu VM trong
theo cách mà khách hàng có thể giải mã.


Quá trình đổ
------------

Việc đổ rác được thực hiện theo 3 bước:

ZZ0000ZZ

Bước này khởi tạo quá trình kết xuất, tạo hạt giống mật mã
và trích xuất các khóa kết xuất mà dữ liệu kết xuất VM sẽ được mã hóa.

ZZ0000ZZ

Hiện tại có hai loại dữ liệu có thể được thu thập từ VM:
bộ nhớ và trạng thái vcpu.

Trạng thái vcpu chứa tất cả các thanh ghi quan trọng, chung, linh hoạt
điểm, vectơ, điều khiển và tod/timer của vcpu. Bãi chứa vcpu có thể
chứa dữ liệu không đầy đủ nếu một vcpu bị hủy trong khi một lệnh được thực hiện
được mô phỏng với sự trợ giúp của hypervisor. Điều này được biểu thị bằng một bit cờ
trong dữ liệu kết xuất. Vì lý do tương tự, điều quan trọng là không chỉ
ghi ra trạng thái vcpu được mã hóa và cả trạng thái không được mã hóa
từ trình ảo hóa.

Trạng thái bộ nhớ còn được chia thành bộ nhớ được mã hóa và
siêu dữ liệu bao gồm các chỉnh sửa mã hóa và cờ trạng thái. các
bộ nhớ được mã hóa có thể được đọc một cách đơn giản sau khi nó được xuất. các
thời gian xuất không quan trọng vì không cần mã hóa lại
cần thiết. Bộ nhớ đã được hoán đổi và do đó được xuất có thể được
đọc từ trao đổi và ghi vào mục tiêu kết xuất mà không cần bất kỳ
những hành động đặc biệt.

Cần phải yêu cầu các chỉnh sửa/cờ trạng thái cho các trang đã xuất
từ Ultravisor.

ZZ0000ZZ

Bước hoàn thiện sẽ cung cấp dữ liệu cần thiết để có thể
giải mã dữ liệu vcpu và bộ nhớ và kết thúc quá trình kết xuất. Khi điều này
bước hoàn tất thành công, quá trình khởi tạo kết xuất mới có thể được bắt đầu.