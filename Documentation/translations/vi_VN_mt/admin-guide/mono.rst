.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/mono.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ hạt nhân nhị phân Mono(tm) cho Linux
-------------------------------------------

Để định cấu hình Linux nhằm tự động thực thi các tệp nhị phân .NET dựa trên Mono
(ở dạng tệp .exe) mà không cần sử dụng CLR đơn sắc
trình bao bọc, bạn có thể sử dụng hỗ trợ kernel BINFMT_MISC.

Điều này sẽ cho phép bạn thực thi các tệp nhị phân .NET dựa trên Mono giống như bất kỳ tệp nhị phân nào
chương trình khác sau khi bạn đã thực hiện những điều sau:

1) Bạn MUST FIRST cài đặt hỗ trợ Mono CLR bằng cách tải xuống
   gói nhị phân, tarball nguồn hoặc bằng cách cài đặt từ Git. nhị phân
   các gói cho một số bản phân phối có thể được tìm thấy tại:

ZZ0000ZZ

Hướng dẫn biên dịch Mono có thể tham khảo tại:

ZZ0000ZZ

Khi hỗ trợ Mono CLR đã được cài đặt, chỉ cần kiểm tra xem
   ZZ0000ZZ (có thể được đặt ở nơi khác, ví dụ
   ZZ0001ZZ) đang hoạt động.

2) Bạn phải biên dịch BINFMT_MISC dưới dạng mô-đun hoặc thành
   kernel (ZZ0000ZZ) và thiết lập nó đúng cách.
   Nếu bạn chọn biên dịch nó thành một mô-đun, bạn sẽ có
   để chèn thủ công bằng modprobe/insmod, dưới dạng kmod
   không thể được hỗ trợ dễ dàng bằng binfmt_misc.
   Đọc file ZZ0001ZZ trong thư mục này để biết
   thêm về quá trình cấu hình.

3) Thêm các mục sau vào ZZ0000ZZ hoặc tập lệnh tương tự
   được chạy khi khởi động hệ thống:

   .. code-block:: sh

    # Insert BINFMT_MISC module into the kernel
    if [ ! -e /proc/sys/fs/binfmt_misc/register ]; then
        /sbin/modprobe binfmt_misc
Các bản phân phối # Some, như Fedora Core, hoạt động
	# the tự động tuân theo lệnh khi
	Mô-đun # binfmt_misc được tải vào kernel
	# or trong quá trình khởi động bình thường (hệ thống dựa trên systemd).
	# Thus, có thể dòng sau
	# is hoàn toàn không cần thiết.
	mount -t binfmt_misc none /proc/sys/fs/binfmt_misc
    fi

# Register hỗ trợ cho các tệp nhị phân .NET CLR
    nếu [ -e /proc/sys/fs/binfmt_misc/register ]; sau đó
	# Replace /usr/bin/mono với tên đường dẫn chính xác tới
	# the Mono CLR thời gian chạy (thường là /usr/local/bin/mono
	# when biên dịch từ các nguồn hoặc CVS).
        echo ':CLR:M::MZ::/usr/bin/mono:' > /proc/sys/fs/binfmt_misc/register
    khác
        echo "Không hỗ trợ binfmt_misc"
        lối ra 1
    fi

4) Kiểm tra xem các tệp nhị phân ZZ0000ZZ có thể chạy mà không cần
   tập lệnh bao bọc, chỉ cần khởi chạy trực tiếp tệp ZZ0001ZZ
   từ dấu nhắc lệnh, ví dụ::

/usr/bin/xsd.exe

   .. note::

      If this fails with a permission denied error, check
      that the ``.exe`` file has execute permissions.
