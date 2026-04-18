.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/sak.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
Xử lý Khóa chú ý bảo mật Linux (SAK)
=============================================

:Ngày: 18 tháng 3 năm 2001
:Tác giả: Andrew Morton

Khóa chú ý an toàn của hệ điều hành là một công cụ bảo mật được
được cung cấp để bảo vệ chống lại các chương trình lấy mật khẩu trojan.  Nó
là một cách bất khả chiến bại để tiêu diệt tất cả các chương trình có thể
giả dạng các ứng dụng đăng nhập.  Người dùng cần được dạy để nhập
chuỗi khóa này trước khi họ đăng nhập vào hệ thống.

Từ bàn phím PC, Linux có hai cách tương tự nhưng khác nhau
cung cấp SAK.  Một là chuỗi ALT-SYSRQ-K.  Bạn không nên sử dụng
trình tự này.  Nó chỉ khả dụng nếu kernel được biên dịch bằng
hỗ trợ sysrq.

Cách thích hợp để tạo SAK là xác định chuỗi khóa bằng cách sử dụng
ZZ0000ZZ.  Điều này sẽ hoạt động cho dù hỗ trợ sysrq có được biên dịch hay không
vào hạt nhân.

SAK hoạt động chính xác khi bàn phím ở chế độ thô.  Điều này có nghĩa là
sau khi được xác định, SAK sẽ tắt máy chủ X đang chạy.  Nếu hệ thống đang ở
chạy cấp 5, máy chủ X sẽ khởi động lại.  Đây là điều bạn muốn
xảy ra.

Bạn nên sử dụng chuỗi phím nào? À, CTRL-ALT-DEL dùng để khởi động lại
cái máy.  CTRL-ALT-BACKSPACE thật kỳ diệu đối với máy chủ X.  chúng tôi sẽ
chọn CTRL-ALT-PAUSE.

Trong tệp rc.sysinit (hoặc rc.local) của bạn, hãy thêm lệnh ::

echo "điều khiển mã khóa alt 101 = SAK" | /bin/loadkey

Và thế là xong!  Chỉ siêu người dùng mới có thể lập trình lại khóa SAK.


.. note::

  1. Linux SAK is said to be not a "true SAK" as is required by
     systems which implement C2 level security.  This author does not
     know why.


  2. On the PC keyboard, SAK kills all applications which have
     /dev/console opened.

     Unfortunately this includes a number of things which you don't
     actually want killed.  This is because these applications are
     incorrectly holding /dev/console open.  Be sure to complain to your
     Linux distributor about this!

     You can identify processes which will be killed by SAK with the
     command::

	# ls -l /proc/[0-9]*/fd/* | grep console
	l-wx------    1 root     root           64 Mar 18 00:46 /proc/579/fd/0 -> /dev/console

     Then::

	# ps aux|grep 579
	root       579  0.0  0.1  1088  436 ?        S    00:43   0:00 gpm -t ps/2

     So ``gpm`` will be killed by SAK.  This is a bug in gpm.  It should
     be closing standard input.  You can work around this by finding the
     initscript which launches gpm and changing it thusly:

     Old::

	daemon gpm

     New::

	daemon gpm < /dev/null

     Vixie cron also seems to have this problem, and needs the same treatment.

     Also, one prominent Linux distribution has the following three
     lines in its rc.sysinit and rc scripts::

	exec 3<&0
	exec 4>&1
	exec 5>&2

     These commands cause **all** daemons which are launched by the
     initscripts to have file descriptors 3, 4 and 5 attached to
     /dev/console.  So SAK kills them all.  A workaround is to simply
     delete these lines, but this may cause system management
     applications to malfunction - test everything well.

