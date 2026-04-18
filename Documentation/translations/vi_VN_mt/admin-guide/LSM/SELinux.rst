.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/LSM/SELinux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
SELinux
=======

Thông tin về hệ thống con hạt nhân SELinux có thể được tìm thấy tại
liên kết sau:

ZZ0000ZZ

ZZ0000ZZ

Thông tin về không gian người dùng SELinux có thể được tìm thấy tại:

ZZ0000ZZ

Nếu bạn muốn sử dụng SELinux, rất có thể bạn sẽ muốn
để sử dụng các chính sách do phân phối cung cấp hoặc cài đặt
bản phát hành chính sách tham chiếu mới nhất từ ​​

ZZ0000ZZ

Tuy nhiên, nếu bạn muốn cài đặt một chính sách giả cho
thử nghiệm, bạn có thể thực hiện bằng cách sử dụng ZZ0000ZZ được cung cấp bên dưới
tập lệnh/selinux.  Lưu ý rằng điều này yêu cầu selinux
không gian người dùng sẽ được cài đặt - đặc biệt bạn sẽ
cần chính sách kiểm tra để biên dịch kernel, setfiles và
fixfiles để gắn nhãn cho hệ thống tập tin.

1. Biên dịch kernel với selinux được kích hoạt.
	2. Gõ ZZ0000ZZ để biên dịch ZZ0001ZZ.
	3. Đảm bảo rằng bạn không chạy với
	   SELinux được kích hoạt và một chính sách thực sự.  Nếu
	   bạn đang khởi động lại với selinux bị vô hiệu hóa
	   trước khi tiếp tục.
	4. Chạy install_policy.sh::

tập lệnh cd/selinux
		sh cài đặt_policy.sh

Bước 4 sẽ tạo một chính sách giả mới hợp lệ cho
kernel, với một người dùng, vai trò và loại selinux duy nhất.
Nó sẽ biên dịch chính sách, sẽ đặt ZZ0000ZZ của bạn thành
ZZ0001ZZ trong ZZ0002ZZ, cài đặt chính sách đã biên dịch
dưới dạng ZZ0003ZZ và dán nhãn lại hệ thống tệp của bạn.
