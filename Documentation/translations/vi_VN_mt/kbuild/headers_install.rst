.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/headers_install.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=================================================
Xuất tiêu đề kernel để không gian người dùng sử dụng
=============================================

Lệnh "make headers_install" xuất các tệp tiêu đề của kernel theo dạng
hình thức phù hợp để sử dụng bởi các chương trình không gian người dùng.

Các tệp tiêu đề được xuất của hạt nhân linux mô tả API cho không gian người dùng
các chương trình cố gắng sử dụng dịch vụ kernel.  Các tập tin tiêu đề kernel này là
được sử dụng bởi thư viện C của hệ thống (chẳng hạn như glibc hoặc uClibc) để xác định
các cuộc gọi hệ thống, cũng như các hằng số và cấu trúc được sử dụng với các lệnh này
các cuộc gọi hệ thống.  Các tệp tiêu đề của thư viện C bao gồm các tệp tiêu đề kernel
từ thư mục con "linux".  Các tiêu đề libc của hệ thống thường là
được cài đặt ở vị trí mặc định /usr/include và các tiêu đề kernel ở
các thư mục con trong đó (đáng chú ý nhất là /usr/include/linux và
/usr/include/asm).

Tiêu đề hạt nhân tương thích ngược nhưng không tương thích về phía trước.  Cái này
có nghĩa là một chương trình được xây dựng dựa trên thư viện C sử dụng các tiêu đề kernel cũ hơn
nên chạy trên kernel mới hơn (mặc dù nó có thể không có quyền truy cập vào kernel mới
tính năng), nhưng một chương trình được xây dựng dựa trên các tiêu đề kernel mới hơn có thể không hoạt động trên
hạt nhân cũ hơn.

Lệnh "make headers_install" có thể được chạy trong thư mục cấp cao nhất của
mã nguồn kernel (hoặc sử dụng bản dựng ngoài cây tiêu chuẩn).  Phải mất hai
đối số tùy chọn::

tạo headers_install ARCH=i386 INSTALL_HDR_PATH=/usr

ARCH cho biết kiến trúc nào sẽ tạo tiêu đề và mặc định là
kiến trúc hiện nay.  Thư mục linux/asm của các tiêu đề kernel đã xuất
dành riêng cho nền tảng, để xem danh sách đầy đủ các kiến trúc được hỗ trợ, hãy sử dụng
lệnh::

ls -d bao gồm/asm-* | sed 's/.*-//'

INSTALL_HDR_PATH cho biết nơi cài đặt các tiêu đề. Nó mặc định là
"./usr".

Thư mục 'bao gồm' được tạo tự động bên trong INSTALL_HDR_PATH và
các tiêu đề được cài đặt trong 'INSTALL_HDR_PATH/include'.

Cơ sở hạ tầng xuất tiêu đề hạt nhân được duy trì bởi David Woodhouse
<dwmw2@infradead.org>.
