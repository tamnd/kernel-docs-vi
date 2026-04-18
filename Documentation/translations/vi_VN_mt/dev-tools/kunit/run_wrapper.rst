.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kunit/run_wrapper.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Chạy thử nghiệm với kunit_tool
=============================

Chúng tôi có thể chạy thử nghiệm KUnit bằng kunit_tool hoặc có thể chạy thử nghiệm
theo cách thủ công, sau đó sử dụng kunit_tool để phân tích kết quả. Để chạy thử nghiệm
theo cách thủ công, hãy xem: Documentation/dev-tools/kunit/run_manual.rst.
Miễn là chúng ta có thể xây dựng kernel thì chúng ta có thể chạy KUnit.

kunit_tool là tập lệnh Python dùng để cấu hình và xây dựng kernel, chạy
kiểm tra và định dạng kết quả kiểm tra.

Chạy lệnh:

.. code-block::

	./tools/testing/kunit/kunit.py run

Chúng ta sẽ thấy như sau:

.. code-block::

	Configuring KUnit Kernel ...
	Building KUnit kernel...
	Starting KUnit kernel...

Chúng tôi có thể muốn sử dụng các tùy chọn sau:

.. code-block::

	./tools/testing/kunit/kunit.py run --timeout=30 --jobs=`nproc --all`

- ZZ0000ZZ đặt khoảng thời gian tối đa để chạy thử nghiệm.
- ZZ0001ZZ thiết lập số lượng luồng để xây dựng kernel.

kunit_tool sẽ tạo ZZ0000ZZ với mặc định
cấu hình, nếu không có tệp ZZ0001ZZ nào khác tồn tại
(trong thư mục xây dựng). Ngoài ra, nó xác minh rằng
Tệp ZZ0002ZZ được tạo chứa các tùy chọn ZZ0003ZZ trong
ZZ0004ZZ.
Cũng có thể chuyển một đoạn ZZ0005ZZ riêng biệt tới
kunit_tool. Điều này rất hữu ích nếu chúng ta có nhiều nhóm khác nhau
các thử nghiệm mà chúng tôi muốn chạy độc lập hoặc nếu chúng tôi muốn sử dụng các thử nghiệm được xác định trước
cấu hình thử nghiệm cho các hệ thống con nhất định.

Để sử dụng tệp ZZ0000ZZ khác (chẳng hạn như tệp
được cung cấp để kiểm tra một hệ thống con cụ thể), chuyển nó dưới dạng tùy chọn:

.. code-block::

	./tools/testing/kunit/kunit.py run --kunitconfig=fs/ext4/.kunitconfig

Để xem cờ kunit_tool (đối số dòng lệnh tùy chọn), hãy chạy:

.. code-block::

	./tools/testing/kunit/kunit.py run --help

Tạo tệp ZZ0000ZZ
================================

Nếu chúng ta muốn chạy một bộ thử nghiệm cụ thể (chứ không phải những thử nghiệm được liệt kê
trong KUnit ZZ0000ZZ), chúng tôi có thể cung cấp các tùy chọn Kconfig trong
Tệp ZZ0001ZZ. Để biết .kunitconfig mặc định, hãy xem:
ZZ0006ZZ
ZZ0002ZZ là ZZ0003ZZ (một .config
được tạo bằng cách chạy ZZ0004ZZ), được sử dụng để chạy
tập các bài kiểm tra cụ thể. Tệp này chứa các cấu hình Kernel thông thường
với các mục tiêu thử nghiệm cụ thể. ZZ0005ZZ cũng
chứa bất kỳ tùy chọn cấu hình nào khác mà các bài kiểm tra yêu cầu (Ví dụ:
phần phụ thuộc cho các tính năng đang được thử nghiệm, cấu hình bật/tắt
một số khối mã nhất định, cấu hình vòm, v.v.).

Để tạo ZZ0000ZZ, sử dụng KUnit ZZ0001ZZ:

.. code-block::

	cd $PATH_TO_LINUX_REPO
	cp tools/testing/kunit/configs/default.config .kunit/.kunitconfig

Sau đó chúng ta có thể thêm bất kỳ tùy chọn Kconfig nào khác. Ví dụ:

.. code-block::

	CONFIG_LIST_KUNIT_TEST=y

kunit_tool đảm bảo rằng tất cả các tùy chọn cấu hình trong ZZ0000ZZ đều
được đặt trong kernel ZZ0001ZZ trước khi chạy thử nghiệm. Nó cảnh báo nếu chúng ta
have not included the options dependencies.

.. note:: Removing something from the ``.kunitconfig`` will
   not rebuild the ``.config file``. The configuration is only
   updated if the ``.kunitconfig`` is not a subset of ``.config``.
   This means that we can use other tools
   (For example: ``make menuconfig``) to adjust other config options.
   The build dir needs to be set for ``make menuconfig`` to
   work, therefore  by default use ``make O=.kunit menuconfig``.

Định cấu hình, xây dựng và chạy thử nghiệm
========================================

Nếu muốn thực hiện các thay đổi thủ công đối với quy trình xây dựng KUnit, chúng tôi
có thể chạy một phần của quá trình xây dựng KUnit một cách độc lập.
Khi chạy kunit_tool, từ ZZ0000ZZ, chúng ta có thể tạo
ZZ0001ZZ bằng cách sử dụng đối số ZZ0002ZZ:

.. code-block::

	./tools/testing/kunit/kunit.py config

Để xây dựng hạt nhân KUnit từ ZZ0000ZZ hiện tại, chúng ta có thể sử dụng
Đối số ZZ0001ZZ:

.. code-block::

	./tools/testing/kunit/kunit.py build

Nếu chúng tôi đã xây dựng kernel UML với các bài kiểm tra KUnit tích hợp sẵn, chúng tôi
có thể chạy kernel và hiển thị kết quả kiểm tra với ZZ0000ZZ
lập luận:

.. code-block::

	./tools/testing/kunit/kunit.py exec

Lệnh ZZ0000ZZ được thảo luận trong phần: ZZ0001ZZ,
tương đương với việc chạy tuần tự ba lệnh trên.

Phân tích kết quả kiểm tra
====================

Đầu ra kiểm tra KUnit hiển thị kết quả trong TAP (Giao thức kiểm tra mọi thứ)
định dạng. Khi chạy thử nghiệm, kunit_tool phân tích kết quả này và in
một bản tóm tắt. Để xem kết quả kiểm tra thô ở định dạng TAP, chúng tôi có thể vượt qua
Đối số ZZ0000ZZ:

.. code-block::

	./tools/testing/kunit/kunit.py run --raw_output

Nếu chúng tôi có kết quả KUnit ở định dạng TAP thô, chúng tôi có thể phân tích cú pháp chúng và
in bản tóm tắt mà con người có thể đọc được bằng lệnh ZZ0000ZZ cho
kunit_tool. Điều này chấp nhận tên tệp cho một đối số hoặc sẽ đọc từ
đầu vào tiêu chuẩn.

.. code-block:: bash

	# Reading from a file
	./tools/testing/kunit/kunit.py parse /var/log/dmesg
	# Reading from stdin
	dmesg | ./tools/testing/kunit/kunit.py parse

Kiểm tra lọc
===============

Bằng cách chuyển bộ lọc toàn cầu kiểu bash tới ZZ0000ZZ hoặc ZZ0001ZZ
lệnh, chúng ta có thể chạy một tập hợp con các bài kiểm tra được tích hợp trong kernel . cho
ví dụ: nếu chúng tôi chỉ muốn chạy thử nghiệm tài nguyên KUnit, hãy sử dụng:

.. code-block::

	./tools/testing/kunit/kunit.py run 'kunit-resource*'

Điều này sử dụng định dạng toàn cầu tiêu chuẩn với các ký tự đại diện.

.. _kunit-on-qemu:

Chạy thử nghiệm trên QEMU
=====================

kunit_tool hỗ trợ chạy thử nghiệm trên qemu cũng như
thông qua UML. Để chạy thử nghiệm trên qemu, theo mặc định, nó cần có hai cờ:

- ZZ0000ZZ: Chọn bộ sưu tập cấu hình (tùy chọn cấu hình Kconfig, qemu
  v.v.), cho phép chạy thử nghiệm KUnit trên thiết bị được chỉ định
  kiến trúc một cách tối giản. Đối số kiến ​​trúc giống như
  tên tùy chọn được chuyển cho biến ZZ0001ZZ được Kbuild sử dụng.
  Hiện tại không phải tất cả kiến trúc đều hỗ trợ cờ này, nhưng chúng ta có thể sử dụng
  ZZ0002ZZ để xử lý nó. Nếu ZZ0003ZZ được thông qua (hoặc cờ này
  bị bỏ qua), các bài kiểm tra sẽ chạy qua UML. Kiến trúc không phải UML,
  ví dụ: i386, x86_64, arm, v.v.; chạy trên qemu.

ZZ0000ZZ liệt kê tất cả các giá trị ZZ0001ZZ hợp lệ.

- ZZ0000ZZ: Chỉ định chuỗi công cụ Kbuild. Nó vượt qua
  đối số tương tự như được truyền cho biến ZZ0001ZZ được sử dụng bởi
  Kbuild. Xin nhắc lại, đây sẽ là tiền tố của chuỗi công cụ
  nhị phân như GCC. Ví dụ:

- ZZ0000ZZ nếu chúng ta đã cài đặt chuỗi công cụ sparc trên
    hệ thống của chúng tôi.

-ZZ0000ZZ
    nếu chúng tôi đã tải xuống chuỗi công cụ microblaze từ 0 ngày
    website vào một thư mục trong thư mục chính của chúng ta có tên là toolchains.

Điều này có nghĩa là đối với hầu hết các kiến ​​trúc, việc chạy trong qemu đơn giản như:

.. code-block:: bash

	./tools/testing/kunit/kunit.py run --arch=x86_64

Khi biên dịch chéo, chúng tôi có thể cần chỉ định một chuỗi công cụ khác, cho
ví dụ:

.. code-block:: bash

	./tools/testing/kunit/kunit.py run \
		--arch=s390 \
		--cross_compile=s390x-linux-gnu-

Nếu chúng tôi muốn chạy thử nghiệm KUnit trên kiến trúc không được hỗ trợ bởi
cờ ZZ0000ZZ hoặc muốn chạy thử nghiệm KUnit trên qemu bằng cách sử dụng
cấu hình không mặc định; sau đó chúng ta có thể viết``QemuConfig`` của riêng mình.
Những ZZ0002ZZ này được viết bằng Python. Họ có một dòng nhập khẩu
ZZ0003ZZ ở đầu tệp.
Tệp phải chứa một biến có tên ZZ0004ZZ có phần mở rộng
phiên bản ZZ0005ZZ được gán cho nó. Xem ví dụ trong:
ZZ0006ZZ.

Khi có ZZ0000ZZ, chúng ta có thể chuyển nó vào kunit_tool,
sử dụng cờ ZZ0001ZZ. Khi được sử dụng, cờ này sẽ thay thế
Cờ ZZ0002ZZ. Ví dụ: sử dụng
ZZ0003ZZ, lệnh gọi xuất hiện
như

.. code-block:: bash

	./tools/testing/kunit/kunit.py run \
		--timeout=60 \
		--jobs=12 \
		--qemu_config=./tools/testing/kunit/qemu_configs/x86_64.py

Chạy đối số dòng lệnh
==============================

kunit_tool có một số đối số dòng lệnh khác có thể
hữu ích cho môi trường thử nghiệm của chúng tôi. Dưới đây là những cách được sử dụng phổ biến nhất
đối số dòng lệnh:

- ZZ0000ZZ: Liệt kê tất cả các tùy chọn có sẵn. Để liệt kê các tùy chọn phổ biến,
  đặt ZZ0001ZZ trước lệnh. Để liệt kê các tùy chọn cụ thể cho điều đó
  lệnh, đặt ZZ0002ZZ sau lệnh.

  .. note:: Different commands (``config``, ``build``, ``run``, etc)
            have different supported options.
- ZZ0000ZZ: Chỉ định thư mục build kunit_tool. Nó bao gồm
  các tệp ZZ0001ZZ, ZZ0002ZZ và kernel đã biên dịch.

- ZZ0000ZZ: Chỉ định các tùy chọn bổ sung cần chuyển để thực hiện, khi
  biên dịch kernel (sử dụng lệnh ZZ0001ZZ hoặc ZZ0002ZZ). Ví dụ:
  để bật cảnh báo trình biên dịch, chúng ta có thể chuyển ZZ0003ZZ.

- ZZ0000ZZ: Kích hoạt bộ tùy chọn được xác định trước để xây dựng
  càng nhiều bài kiểm tra càng tốt.

  .. note:: The list of enabled options can be found in
            ``tools/testing/kunit/configs/all_tests.config``.

            If you only want to enable all tests with otherwise satisfied
            dependencies, instead add ``CONFIG_KUNIT_ALL_TESTS=y`` to your
            ``.kunitconfig``.

- ZZ0000ZZ: Chỉ định đường dẫn hoặc thư mục của ZZ0001ZZ
  tập tin. Ví dụ:

- ZZ0000ZZ có thể là đường dẫn của file.

- ZZ0000ZZ có thể là thư mục chứa tập tin.

Tệp này được sử dụng để xây dựng và chạy với một bộ thử nghiệm được xác định trước
  và sự phụ thuộc của chúng. Ví dụ: để chạy thử nghiệm cho một hệ thống con nhất định.

- ZZ0000ZZ: Chỉ định các tùy chọn cấu hình bổ sung cần thực hiện
  được thêm vào tệp ZZ0001ZZ. Ví dụ:

  .. code-block::

./tools/testing/kunit/kunit.py run --kconfig_add CONFIG_KASAN=y

- ZZ0000ZZ: Chạy thử nghiệm trên kiến ​​trúc được chỉ định. Kiến trúc
  đối số giống với biến môi trường Kbuild ARCH.
  Ví dụ: i386, x86_64, arm, ừm, v.v. Kiến trúc không phải UML chạy trên qemu.
  Mặc định là ZZ0001ZZ.

- ZZ0000ZZ: Chỉ định chuỗi công cụ Kbuild. Nó vượt qua
  đối số tương tự như được truyền cho biến ZZ0001ZZ được sử dụng bởi
  Kbuild. Đây sẽ là tiền tố cho chuỗi công cụ
  nhị phân như GCC. Ví dụ:

- ZZ0000ZZ nếu chúng ta đã cài đặt chuỗi công cụ sparc trên
    hệ thống của chúng tôi.

-ZZ0000ZZ
    nếu chúng tôi đã tải xuống chuỗi công cụ microblaze từ 0 ngày
    website tới một đường dẫn cụ thể trong thư mục chính của chúng tôi được gọi là toolchains.

- ZZ0000ZZ: Chỉ định đường dẫn tới file chứa
  định nghĩa kiến trúc qemu tùy chỉnh. Đây phải là một tập tin python
  chứa đối tượng ZZ0001ZZ.

- ZZ0000ZZ: Chỉ định các đối số qemu bổ sung, ví dụ ZZ0001ZZ.

- ZZ0000ZZ: Chỉ định số lượng công việc (lệnh) sẽ chạy đồng thời.
  Theo mặc định, điều này được đặt thành số lõi trên hệ thống của bạn.

- ZZ0000ZZ: Chỉ định số giây tối đa được phép để chạy tất cả các bài kiểm tra.
  Điều này không bao gồm thời gian thực hiện để xây dựng các bài kiểm tra.

- ZZ0000ZZ: Chỉ định các đối số dòng lệnh kernel bổ sung. Có thể được lặp đi lặp lại.

- ZZ0000ZZ: Nếu được đặt, hãy khởi động kernel cho từng bộ/kiểm tra riêng lẻ.
  Điều này rất hữu ích cho việc gỡ lỗi một bài kiểm tra không kín, một bài kiểm tra
  có thể đạt/không đạt dựa trên những gì chạy trước nó.

- ZZ0000ZZ: Nếu được đặt, sẽ tạo đầu ra chưa được định dạng từ kernel. Các lựa chọn có thể là:

- ZZ0000ZZ: Để xem đầu ra kernel đầy đủ, hãy sử dụng ZZ0001ZZ.

- ZZ0000ZZ: Đây là tùy chọn mặc định và lọc ra đầu ra KUnit. Sử dụng ZZ0001ZZ hoặc ZZ0002ZZ.

- ZZ0000ZZ: Nếu được đặt, lưu kết quả kiểm tra ở định dạng JSON và in thành ZZ0001ZZ hoặc
  lưu vào một tập tin nếu tên tập tin được chỉ định.

- ZZ0000ZZ: Chỉ định các bộ lọc trên thuộc tính thử nghiệm, ví dụ ZZ0001ZZ.
  Có thể sử dụng nhiều bộ lọc bằng cách gói đầu vào trong dấu ngoặc kép và tách các bộ lọc
  bằng dấu phẩy. Ví dụ: ZZ0002ZZ.

- ZZ0000ZZ: Nếu đặt thành ZZ0001ZZ, các bài kiểm tra đã lọc sẽ hiển thị là bị bỏ qua
  ở đầu ra thay vì hiển thị không có đầu ra.

- ZZ0000ZZ: Nếu được đặt, liệt kê tất cả các bài kiểm tra sẽ được chạy.

- ZZ0000ZZ: Nếu được đặt, liệt kê tất cả các bài kiểm tra sẽ được chạy và tất cả các bài kiểm tra của chúng
  thuộc tính.

- ZZ0000ZZ: Nếu được đặt, liệt kê tất cả các bộ sẽ được chạy.

Hoàn thành dòng lệnh
==============================

kunit_tool đi kèm với tập lệnh hoàn thành bash:

.. code-block:: bash

	source tools/testing/kunit/kunit-completion.sh