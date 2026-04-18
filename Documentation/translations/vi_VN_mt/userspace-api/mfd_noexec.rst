.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/mfd_noexec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Giới thiệu mfd không thể thực thi
=====================================
:Tác giả:
    Daniel Verkamp <dverkamp@chromium.org>
    Jeff Xu <jeffxu@chromium.org>

:Người đóng góp:
	Aleksa Sarai <cyphar@cyphar.com>

Kể từ khi Linux giới thiệu tính năng memfd, memfd luôn có tính năng riêng của nó.
thực thi tập hợp bit và tòa nhà memfd_create() không cho phép cài đặt
nó khác đi.

Tuy nhiên, trong hệ thống bảo mật theo mặc định, chẳng hạn như ChromeOS, (trong đó tất cả
các tệp thực thi phải đến từ rootfs, được bảo vệ bởi xác minh
boot), bản chất thực thi này của memfd sẽ mở ra cơ hội vượt qua NoExec
và cho phép "tấn công phó nhầm lẫn".  Ví dụ: trong lỗi VRP [1]: cros_vm
quy trình đã tạo một memfd để chia sẻ nội dung với quy trình bên ngoài,
tuy nhiên memfd bị ghi đè và được sử dụng để thực thi mã tùy ý
và leo thang gốc. [2] liệt kê thêm VRP thuộc loại này.

Mặt khác, memfd thực thi được có cách sử dụng hợp pháp: runc sử dụng memfd
con dấu và tính năng thực thi để sao chép nội dung của tệp nhị phân sau đó
thực hiện chúng. Đối với hệ thống như vậy chúng ta cần có giải pháp để phân biệt runc's
việc sử dụng các memfd thực thi và của kẻ tấn công [3].

Để giải quyết những vấn đề trên:
 - Để memfd_create() thiết lập bit X tại thời điểm tạo.
 - Để memfd được niêm phong để sửa đổi bit X khi NX được thiết lập.
 - Thêm một namespace pid mới sysctl: vm.memfd_noexec để giúp các ứng dụng trong
   di chuyển và thực thi MFD không thể thực thi.

Người dùng API
========
ZZ0000ZZ

ZZ0000ZZ
	Khi bit MFD_NOEXEC_SEAL được đặt trong ZZ0001ZZ, memfd được tạo
	với NX. F_SEAL_EXEC đã được đặt và không thể sửa đổi memfd thành
	thêm X sau. MFD_ALLOW_SEALING cũng được ngụ ý.
	Đây là trường hợp phổ biến nhất mà ứng dụng sử dụng memfd.

ZZ0000ZZ
	Khi bit MFD_EXEC được đặt trong ZZ0001ZZ, memfd được tạo bằng X.

Lưu ý:
	ZZ0000ZZ ngụ ý ZZ0001ZZ. Trong trường hợp đó
	một ứng dụng không muốn niêm phong, nó có thể thêm F_SEAL_SEAL sau khi tạo.


Hệ thống:
========
ZZ0000ZZ

pid mới được đặt tên sysctl vm.memfd_noexec có 3 giá trị:

- 0: MEMFD_NOEXEC_SCOPE_EXEC
	memfd_create() không có MFD_EXEC cũng như MFD_NOEXEC_SEAL hoạt động như
	MFD_EXEC đã được thiết lập.

-1: MEMFD_NOEXEC_SCOPE_NOEXEC_SEAL
	memfd_create() không có MFD_EXEC cũng như MFD_NOEXEC_SEAL hoạt động như
	MFD_NOEXEC_SEAL đã được thiết lập.

- 2: MEMFD_NOEXEC_SCOPE_NOEXEC_ENFORCED
	memfd_create() không có MFD_NOEXEC_SEAL sẽ bị từ chối.

sysctl cho phép kiểm soát memfd_create tốt hơn đối với phần mềm cũ
không đặt bit thực thi; ví dụ: một thùng chứa có
vm.memfd_noexec=1 có nghĩa là phần mềm cũ sẽ tạo memfd không thể thực thi được
theo mặc định trong khi phần mềm mới có thể tạo memfd thực thi bằng cách cài đặt
MFD_EXEC.

Giá trị của vm.memfd_noexec được chuyển tới không gian tên con khi tạo
thời gian. Ngoài ra, cài đặt có tính phân cấp, tức là trong thời gian memfd_create,
chúng ta sẽ tìm kiếm từ ns hiện tại đến ns gốc và sử dụng ns hạn chế nhất
thiết lập.

[1] ZZ0000ZZ

[2] ZZ0000ZZ

[3] ZZ0000ZZ