.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/gcov.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Sử dụng gcov với nhân Linux
================================

Hỗ trợ kernel lược tả gcov cho phép sử dụng thử nghiệm phạm vi bảo hiểm của GCC
công cụ gcov_ với nhân Linux. Dữ liệu bảo hiểm của kernel đang chạy
được xuất ở định dạng tương thích với gcov thông qua thư mục debugfs "gcov".
Để lấy dữ liệu bảo hiểm cho một tệp cụ thể, hãy thay đổi bản dựng kernel
thư mục và sử dụng gcov với tùy chọn ZZ0000ZZ như sau (yêu cầu root)::

# cd /tmp/linux-out
    # gcov -o /sys/kernel/debug/gcov/tmp/linux-out/kernel spinlock.c

Điều này sẽ tạo các tệp mã nguồn được chú thích bằng số lần thực thi
trong thư mục hiện tại. Ngoài ra, giao diện người dùng gcov đồ họa như
vì lcov_ có thể được sử dụng để tự động hóa quá trình thu thập dữ liệu
cho toàn bộ hạt nhân và cung cấp tổng quan về vùng phủ sóng ở định dạng HTML.

Sử dụng có thể:

* gỡ lỗi (đã đạt đến dòng này chưa?)
* cải thiện bài kiểm tra (làm cách nào để thay đổi bài kiểm tra của tôi để bao gồm những dòng này?)
* giảm thiểu cấu hình kernel (tôi có cần tùy chọn này không nếu
  mã liên quan không bao giờ được chạy?)

.. _gcov: https://gcc.gnu.org/onlinedocs/gcc/Gcov.html
.. _lcov: https://github.com/linux-test-project/lcov


Sự chuẩn bị
-----------

Cấu hình kernel với::

CONFIG_DEBUG_FS=y
        CONFIG_GCOV_KERNEL=y

và để lấy dữ liệu bảo hiểm cho toàn bộ kernel ::

CONFIG_GCOV_PROFILE_ALL=y

Lưu ý rằng các hạt nhân được biên dịch bằng cờ định hình sẽ có hiệu suất đáng kể.
lớn hơn và chạy chậm hơn. Ngoài ra CONFIG_GCOV_PROFILE_ALL có thể không được hỗ trợ
trên mọi kiến trúc.

Dữ liệu hồ sơ sẽ chỉ có thể truy cập được sau khi gỡ lỗi
gắn kết::

mount -t debugfs none /sys/kernel/debug


Tùy chỉnh
-------------

Để bật tính năng lập hồ sơ cho các tệp hoặc thư mục cụ thể, hãy thêm một dòng
tương tự như sau với kernel Makefile tương ứng:

- Đối với một tập tin (ví dụ main.o)::

GCOV_PROFILE_main.o := y

- Đối với tất cả các tập tin trong một thư mục::

GCOV_PROFILE := y

Để loại trừ các tập tin khỏi bị lược tả ngay cả khi CONFIG_GCOV_PROFILE_ALL
được chỉ định, sử dụng::

GCOV_PROFILE_main.o := n

Và::

GCOV_PROFILE := n

Chỉ các tập tin được liên kết với hình ảnh hạt nhân chính hoặc được biên dịch dưới dạng
các mô-đun hạt nhân được hỗ trợ bởi cơ chế này.


Cấu hình cụ thể của mô-đun
-----------------------

Cấu hình kernel Gcov cho các mô-đun cụ thể được mô tả bên dưới:

CONFIG_GCOV_PROFILE_RDS:
        Cho phép lập hồ sơ GCOV trên RDS để kiểm tra các chức năng hoặc
        các dòng được thực thi. Cấu hình này được rds selftest sử dụng để
        tạo ra các báo cáo bảo hiểm. Nếu không được đặt, báo cáo sẽ bị bỏ qua.


Tập tin
-----

Hỗ trợ kernel gcov tạo các tệp sau trong debugfs:

ZZ0000ZZ
	Thư mục gốc cho tất cả các tệp liên quan đến gcov.

ZZ0000ZZ
	Tệp đặt lại toàn cầu: đặt lại tất cả dữ liệu vùng phủ sóng về 0 khi
        được viết cho.

ZZ0000ZZ
	Tệp dữ liệu gcov thực tế được hiểu bởi gcov
        công cụ. Đặt lại dữ liệu phạm vi tệp về 0 khi được ghi vào.

ZZ0000ZZ
	Liên kết tượng trưng đến tệp dữ liệu tĩnh theo yêu cầu của gcov
        công cụ. Tệp này được tạo bởi gcc khi biên dịch với
        tùy chọn ZZ0001ZZ.


Mô-đun
-------

Các mô-đun hạt nhân có thể chứa mã dọn dẹp chỉ được chạy trong
thời gian dỡ mô-đun. Cơ chế gcov cung cấp một phương tiện để thu thập
dữ liệu bảo hiểm cho mã đó bằng cách giữ một bản sao của dữ liệu liên quan
với mô-đun không tải. Dữ liệu này vẫn có sẵn thông qua debugfs.
Sau khi mô-đun được tải lại, các bộ đếm phạm vi liên quan sẽ được
được khởi tạo với dữ liệu từ lần khởi tạo trước đó của nó.

Hành vi này có thể bị vô hiệu hóa bằng cách chỉ định kernel gcov_persist
tham số::

gcov_persist=0

Vào thời gian chạy, người dùng cũng có thể chọn loại bỏ dữ liệu cho một phiên bản chưa được tải.
mô-đun bằng cách ghi vào tệp dữ liệu của nó hoặc tệp đặt lại toàn cầu.


Máy xây dựng và thử nghiệm riêng biệt
---------------------------------

Cơ sở hạ tầng lược tả hạt nhân gcov được thiết kế để hoạt động vượt trội
hộp dành cho các thiết lập trong đó hạt nhân được xây dựng và chạy trên cùng một máy. trong
trường hợp kernel chạy trên một máy riêng biệt, cần chuẩn bị đặc biệt
phải được thực hiện, tùy thuộc vào nơi sử dụng công cụ gcov:

.. _gcov-test:

a) gcov được chạy trên máy TEST

Phiên bản công cụ gcov trên máy thử nghiệm phải tương thích với
    phiên bản gcc được sử dụng để xây dựng kernel. Ngoài ra các tập tin sau đây cần phải có
    sao chép từ bản dựng sang máy thử nghiệm:

từ cây nguồn:
      - tất cả các tệp nguồn C + tiêu đề

từ cây xây dựng:
      - tất cả các tệp nguồn C + tiêu đề
      - tất cả các tệp .gcda và .gcno
      - tất cả các liên kết đến thư mục

Điều quan trọng cần lưu ý là những tập tin này cần phải được đặt vào thư mục
    chính xác cùng một vị trí hệ thống tệp trên máy kiểm tra như trên bản dựng
    máy. Nếu bất kỳ thành phần đường dẫn nào là liên kết tượng trưng thì đường dẫn thực tế
    thư mục cần được sử dụng thay thế (do việc xử lý CURDIR của make).

.. _gcov-build:

b) gcov được chạy trên máy BUILD

Các tập tin sau đây cần được sao chép sau mỗi trường hợp thử nghiệm từ thử nghiệm
    để xây dựng máy:

từ thư mục gcov trong sysfs:
      - tất cả các tệp .gcda
      - tất cả các liên kết đến tập tin .gcno

Các tệp này có thể được sao chép vào bất kỳ vị trí nào trên máy xây dựng. gcov
    sau đó phải được gọi với tùy chọn -o trỏ đến thư mục đó.

Thiết lập thư mục ví dụ trên máy xây dựng::

/tmp/linux: cây nguồn kernel
      /tmp/out: thư mục xây dựng kernel được chỉ định bởi make O=
      /tmp/coverage: vị trí của các file được sao chép từ máy kiểm tra

[người dùng@build] cd /tmp/out
      [user@build] gcov -o /tmp/coverage/tmp/out/init main.c


Lưu ý về trình biên dịch
-----------------

Các công cụ gcov GCC và LLVM không nhất thiết phải tương thích. Sử dụng gcov_ để làm việc với
Các tệp .gcno và .gcda do GCC tạo và sử dụng llvm-cov_ cho Clang.

.. _gcov: https://gcc.gnu.org/onlinedocs/gcc/Gcov.html
.. _llvm-cov: https://llvm.org/docs/CommandGuide/llvm-cov.html

Sự khác biệt về bản dựng giữa GCC và Clang gcov do Kconfig xử lý. Nó
tự động chọn định dạng gcov thích hợp tùy thuộc vào phát hiện
toolchain.


Khắc phục sự cố
---------------

vấn đề
    Quá trình biên dịch bị hủy bỏ trong bước liên kết.

nguyên nhân
    Cờ hồ sơ được chỉ định cho các tệp nguồn không
    được liên kết với kernel chính hoặc được liên kết bởi một tùy chỉnh
    thủ tục liên kết.

Giải pháp
    Loại trừ các tệp nguồn bị ảnh hưởng khỏi hồ sơ bằng cách chỉ định
    ZZ0000ZZ hoặc ZZ0001ZZ trong
    Makefile tương ứng.

vấn đề
    Các tệp được sao chép từ sysfs có vẻ trống hoặc không đầy đủ.

nguyên nhân
    Do cách thức hoạt động của seq_file nên một số công cụ như cp hoặc tar
    có thể sao chép không chính xác các tập tin từ sysfs.

Giải pháp
    Sử dụng ZZ0000ZZ để đọc tệp ZZ0001ZZ và ZZ0002ZZ để sao chép liên kết.
    Hoặc sử dụng cơ chế được trình bày trong Phụ lục B.


Phụ lục A: Gather_on_build.sh
------------------------------

Tập lệnh mẫu để thu thập các tệp meta bảo hiểm trên máy xây dựng
(xem ZZ0000ZZ):

.. code-block:: sh

    #!/bin/bash

    KSRC=$1
    KOBJ=$2
    DEST=$3

    if [ -z "$KSRC" ] || [ -z "$KOBJ" ] || [ -z "$DEST" ]; then
      echo "Usage: $0 <ksrc directory> <kobj directory> <output.tar.gz>" >&2
      exit 1
    fi

    KSRC=$(cd $KSRC; printf "all:\n\t@echo \${CURDIR}\n" | make -f -)
    KOBJ=$(cd $KOBJ; printf "all:\n\t@echo \${CURDIR}\n" | make -f -)

    find $KSRC $KOBJ \( -name '*.gcno' -o -name '*.[ch]' -o -type l \) -a \
                     -perm /u+r,g+r | tar cfz $DEST -P -T -

    if [ $? -eq 0 ] ; then
      echo "$DEST successfully created, copy to test system and unpack with:"
      echo "  tar xfz $DEST -P"
    else
      echo "Could not create file $DEST"
    fi


Phụ lục B: Gather_on_test.sh
-----------------------------

Tập lệnh mẫu để thu thập các tệp dữ liệu phủ sóng trên máy kiểm tra
(xem ZZ0000ZZ):

.. code-block:: sh

    #!/bin/bash -e

    DEST=$1
    GCDA=/sys/kernel/debug/gcov

    if [ -z "$DEST" ] ; then
      echo "Usage: $0 <output.tar.gz>" >&2
      exit 1
    fi

    TEMPDIR=$(mktemp -d)
    echo Collecting data..
    find $GCDA -type d -exec mkdir -p $TEMPDIR/\{\} \;
    find $GCDA -name '*.gcda' -exec sh -c 'cat < $0 > '$TEMPDIR'/$0' {} \;
    find $GCDA -name '*.gcno' -exec sh -c 'cp -d $0 '$TEMPDIR'/$0' {} \;
    tar czf $DEST -C $TEMPDIR sys
    rm -rf $TEMPDIR

    echo "$DEST successfully created, copy to build system and unpack with:"
    echo "  tar xfz $DEST"
