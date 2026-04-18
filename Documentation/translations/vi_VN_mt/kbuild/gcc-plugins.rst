.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/gcc-plugins.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Cơ sở hạ tầng plugin GCC
=========================


Giới thiệu
============

Các plugin GCC là các mô-đun có thể tải được, cung cấp các tính năng bổ sung cho
trình biên dịch [1]_. Chúng rất hữu ích cho thiết bị đo thời gian chạy và phân tích tĩnh.
Chúng ta có thể phân tích, thay đổi và thêm mã trong quá trình biên dịch thông qua
lệnh gọi lại [2]_, GIMPLE [3]_, IPA [4]_ và RTL vượt qua [5]_.

Cơ sở hạ tầng plugin GCC của kernel hỗ trợ xây dựng out-of-tree
mô-đun, biên dịch chéo và xây dựng trong một thư mục riêng.
Các tệp nguồn plugin phải được biên dịch bằng trình biên dịch C++.

Hiện tại cơ sở hạ tầng plugin GCC chỉ hỗ trợ một số kiến ​​trúc.
Grep "select HAVE_GCC_PLUGINS" để tìm hiểu kiến trúc nào hỗ trợ
Các plugin GCC.

Cơ sở hạ tầng này được chuyển từ grsecurity [6]_ và PaX [7]_.

--

.. [1] https://gcc.gnu.org/onlinedocs/gccint/Plugins.html
.. [2] https://gcc.gnu.org/onlinedocs/gccint/Plugin-API.html#Plugin-API
.. [3] https://gcc.gnu.org/onlinedocs/gccint/GIMPLE.html
.. [4] https://gcc.gnu.org/onlinedocs/gccint/IPA.html
.. [5] https://gcc.gnu.org/onlinedocs/gccint/RTL.html
.. [6] https://grsecurity.net/
.. [7] https://pax.grsecurity.net/


Mục đích
=======

Các plugin GCC được thiết kế để cung cấp một nơi để thử nghiệm tiềm năng
các tính năng của trình biên dịch không có trong GCC cũng như Clang ngược dòng. Một lần
tiện ích của họ đã được chứng minh, mục tiêu là đưa tính năng này vào GCC
(và Clang), rồi cuối cùng loại bỏ chúng khỏi kernel sau khi
tính năng này có sẵn trong tất cả các phiên bản được hỗ trợ của GCC.

Cụ thể, các plugin mới chỉ nên triển khai các tính năng không có
hỗ trợ trình biên dịch ngược dòng (trong GCC hoặc Clang).

Khi một tính năng tồn tại trong Clang nhưng không có trong GCC, cần nỗ lực để
đưa tính năng này lên GCC ngược dòng (thay vì chỉ là một phiên bản dành riêng cho kernel
Plugin GCC), vì vậy toàn bộ hệ sinh thái có thể được hưởng lợi từ nó.

Tương tự, ngay cả khi một tính năng được cung cấp bởi plugin GCC thì ZZ0000ZZ vẫn tồn tại
trong Clang, nhưng tính năng này được chứng minh là hữu ích, cần phải nỗ lực
để cập nhật tính năng lên GCC (và Clang).

Sau khi một tính năng có sẵn trong GCC ngược dòng, plugin sẽ được tạo
không thể xây dựng được cho phiên bản GCC tương ứng (và phiên bản mới hơn). Một lần tất cả
phiên bản hỗ trợ kernel của GCC cung cấp tính năng này, plugin sẽ
được loại bỏ khỏi kernel.


Tập tin
=====

ZZ0000ZZ

Đây là thư mục chứa các plugin GCC.

ZZ0000ZZ

Đây là tiêu đề tương thích cho các plugin GCC.
	Nó phải luôn được bao gồm thay vì các tiêu đề gcc riêng lẻ.

**$(src)/scripts/gcc-plugins/gcc-generate-gimple-pass.h,
$(src)/scripts/gcc-plugins/gcc-generate-ipa-pass.h,
$(src)/scripts/gcc-plugins/gcc-generate-simple_ipa-pass.h,
$(src)/scripts/gcc-plugins/gcc-generate-rtl-pass.h**

Các tiêu đề này tự động tạo ra các cấu trúc đăng ký cho
	Vượt qua GIMPLE, SIMPLE_IPA, IPA và RTL.
	Họ nên được ưu tiên hơn là tạo các cấu trúc bằng tay.


Cách sử dụng
=====

Bạn phải cài đặt tiêu đề plugin gcc cho phiên bản gcc của mình,
ví dụ: trên Ubuntu cho gcc-10::

cài đặt apt-get gcc-10-plugin-dev

Hoặc trên Fedora::

dnf cài đặt gcc-plugin-devel libmpc-devel

Hoặc trên Fedora khi sử dụng trình biên dịch chéo bao gồm plugin ::

dnf cài đặt libmpc-devel

Kích hoạt cơ sở hạ tầng plugin GCC và một số plugin bạn muốn sử dụng
trong cấu hình kernel ::

CONFIG_GCC_PLUGINS=y
	CONFIG_GCC_PLUGIN_LATENT_ENTROPY=y
	...

Chạy gcc (trình biên dịch gốc hoặc trình biên dịch chéo) để đảm bảo phát hiện tiêu đề plugin ::

gcc -print-file-name=plugin
	CROSS_COMPILE=arm-linux-gnu- ${CROSS_COMPILE}gcc -print-file-name=plugin

Từ "plugin" có nghĩa là chúng không được phát hiện ::

phần bổ trợ

Đường dẫn đầy đủ có nghĩa là chúng được phát hiện::

/usr/lib/gcc/x86_64-redhat-linux/12/plugin

Để biên dịch bộ công cụ tối thiểu bao gồm (các) plugin::

viết kịch bản

hoặc chỉ chạy kernel tạo và biên dịch toàn bộ kernel với
plugin GCC phức tạp theo chu kỳ.


4. Cách thêm plugin GCC mới
==============================

Các plugin GCC có trong scripts/gcc-plugins/. Bạn cần đặt các tập tin nguồn plugin
ngay dưới scripts/gcc-plugins/. Tạo thư mục con không được hỗ trợ.
Nó phải được thêm vào scripts/gcc-plugins/Makefile, scripts/Makefile.gcc-plugins
và một tệp Kconfig có liên quan.
