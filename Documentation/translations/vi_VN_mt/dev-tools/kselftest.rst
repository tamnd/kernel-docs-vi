.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kselftest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================
Tự kiểm tra hạt nhân Linux
======================

Hạt nhân chứa một tập hợp các "tự kiểm tra" trong tools/testing/selftests/
thư mục. Đây là những thử nghiệm nhỏ để thực thi mã riêng lẻ
đường dẫn trong kernel. Các thử nghiệm dự định sẽ được chạy sau khi xây dựng, cài đặt
và khởi động kernel.

Kselftest từ dòng chính có thể chạy trên các hạt nhân ổn định cũ hơn. Chạy thử nghiệm
từ đường dây chính cung cấp phạm vi bảo hiểm tốt nhất. Một số vòng thử nghiệm chạy đường chính
bộ kselftest trên các bản phát hành ổn định. Lý do là khi một bài kiểm tra mới
được thêm vào để kiểm tra mã hiện có nhằm kiểm tra hồi quy một lỗi, chúng ta nên
có thể chạy thử nghiệm đó trên kernel cũ hơn. Do đó, điều quan trọng là phải giữ
mã vẫn có thể kiểm tra kernel cũ hơn và đảm bảo rằng nó bỏ qua bài kiểm tra
một cách duyên dáng trên các phiên bản mới hơn.

Bạn có thể tìm thêm thông tin về khung Kselftest, cách
viết các bài kiểm tra mới bằng cách sử dụng khung trên wiki Kselftest:

ZZ0000ZZ

Trên một số hệ thống, các bài kiểm tra phích cắm nóng có thể bị treo vĩnh viễn khi chờ CPU và
bộ nhớ sẵn sàng để ngoại tuyến. Một mục tiêu cắm nóng đặc biệt được tạo
để chạy đầy đủ các thử nghiệm cắm nóng. Ở chế độ mặc định, các bài kiểm tra cắm nóng sẽ chạy
ở chế độ an toàn với phạm vi hạn chế. Ở chế độ giới hạn, kiểm tra cpu-hotplug là
chạy trên một CPU duy nhất, trái ngược với tất cả các CPU có khả năng cắm nóng và bộ nhớ
kiểm tra hotplug được chạy trên 2% bộ nhớ có khả năng cắm nóng thay vì 10%.

kselftest chạy như một tiến trình không gian người dùng.  Các bài kiểm tra có thể được viết/chạy trong
không gian người dùng có thể muốn sử dụng ZZ0000ZZ.  Những thử nghiệm cần thực hiện
chạy trong không gian kernel có thể muốn sử dụng ZZ0001ZZ.

Tài liệu về các bài kiểm tra
==========================

Để biết tài liệu về kselftests, hãy xem:

.. toctree::

   testing-devices

Chạy tự kiểm tra (kiểm tra hotplug được chạy ở chế độ giới hạn)
=============================================================

Để xây dựng các bài kiểm tra::

$ tạo tiêu đề
  $ make -C công cụ/thử nghiệm/tự kiểm tra

Để chạy thử nghiệm::

$ make -C công cụ/kiểm tra/selftests run_tests

Để xây dựng và chạy thử nghiệm bằng một lệnh duy nhất, hãy sử dụng::

$ tự kiểm tra

Lưu ý rằng một số thử nghiệm sẽ yêu cầu quyền root.

Kselftest hỗ trợ lưu file đầu ra vào một thư mục riêng rồi
chạy thử nghiệm. Để định vị các tệp đầu ra trong một thư mục riêng biệt, có hai cú pháp
được hỗ trợ. Trong cả hai trường hợp, thư mục làm việc phải là thư mục gốc của
hạt nhân src. Điều này có thể áp dụng cho phần "Chạy một tập hợp con các bản tự kiểm tra"
bên dưới.

Để xây dựng, hãy lưu các tệp đầu ra vào một thư mục riêng với O= ::

$ make O=/tmp/kselftest kselftest

Để build, lưu file đầu ra vào một thư mục riêng với KBUILD_OUTPUT ::

$ xuất KBUILD_OUTPUT=/tmp/kselftest; tự kiểm tra

Phép gán O= được ưu tiên hơn môi trường KBUILD_OUTPUT
biến.

Các lệnh trên theo mặc định chạy thử nghiệm và in báo cáo đạt/không đạt đầy đủ.
Kselftest hỗ trợ tùy chọn “tóm tắt” để dễ hiểu bài thi hơn
kết quả. Vui lòng tìm kết quả chi tiết của từng bài kiểm tra trong
(các) tệp /tmp/testname khi tùy chọn tóm tắt được chỉ định. Điều này có thể áp dụng
tới phần "Chạy một tập hợp con các bài kiểm tra tự kiểm tra" bên dưới.

Để chạy kselftest với tùy chọn tóm tắt được bật ::

$ làm tóm tắt=1 kselftest

Chạy một tập hợp con các bản tự kiểm tra
=============================

Bạn có thể sử dụng biến "TARGETS" trên dòng lệnh make để chỉ định
một thử nghiệm để chạy hoặc một danh sách các thử nghiệm để chạy.

Để chỉ chạy các thử nghiệm được nhắm mục tiêu cho một hệ thống con duy nhất::

$ make -C công cụ/kiểm tra/selftests TARGETS=ptrace run_tests

Bạn có thể chỉ định nhiều thử nghiệm để xây dựng và chạy ::

$ make TARGETS="kích thước bộ đếm thời gian" kselftest

Để xây dựng, hãy lưu các tệp đầu ra vào một thư mục riêng với O= ::

$ make O=/tmp/kselftest TARGETS="kích thước bộ đếm thời gian" kselftest

Để build, lưu file đầu ra vào một thư mục riêng với KBUILD_OUTPUT ::

$ xuất KBUILD_OUTPUT=/tmp/kselftest; tạo TARGETS="kích thước bộ đếm thời gian" kselftest

Ngoài ra, bạn có thể sử dụng biến "SKIP_TARGETS" trên lệnh make
để chỉ định một hoặc nhiều mục tiêu cần loại trừ khỏi danh sách TARGETS.

Để chạy tất cả các thử nghiệm ngoại trừ một hệ thống con duy nhất::

$ make -C công cụ/kiểm tra/selftests SKIP_TARGETS=ptrace run_tests

Bạn có thể chỉ định nhiều bài kiểm tra để bỏ qua::

$ make SKIP_TARGETS="kích thước bộ đếm thời gian" kselftest

Bạn cũng có thể chỉ định một danh sách hạn chế các thử nghiệm để chạy cùng với một
danh sách bỏ qua chuyên dụng::

$ make TARGETS="bộ đếm thời gian kích thước điểm dừng" SKIP_TARGETS=kích thước kselftest

Xem các công cụ/kiểm tra/tự kiểm tra/Makefile cấp cao nhất để biết danh sách tất cả
các mục tiêu có thể.

Chạy tự kiểm tra toàn bộ hotplug
========================================

Để xây dựng các thử nghiệm cắm nóng::

$ make -C công cụ/thử nghiệm/selftests hotplug

Để chạy thử nghiệm hotplug::

$ make -C công cụ/thử nghiệm/selftests run_hotplug

Lưu ý rằng một số thử nghiệm sẽ yêu cầu quyền root.


Cài đặt tự kiểm tra
=================

Bạn có thể sử dụng mục tiêu "cài đặt" của "thực hiện" (gọi ZZ0000ZZ
tool) để cài đặt selftests ở vị trí mặc định (ZZ0001ZZ),
hoặc ở một vị trí do người dùng chỉ định thông qua biến "make" ZZ0002ZZ.

Để cài đặt selftests ở vị trí mặc định::

$ make -C công cụ/thử nghiệm/cài đặt selftests

Để cài đặt bản tự kiểm tra ở vị trí do người dùng chỉ định::

$ make -C tools/testing/selftests cài đặt INSTALL_PATH=/some/other/path

Chạy các bản tự kiểm tra đã cài đặt
===========================

Tìm thấy trong thư mục cài đặt, cũng như trong tarball Kselftest,
là một tập lệnh có tên ZZ0000ZZ để chạy thử nghiệm.

Bạn chỉ cần làm như sau để chạy Kselftests đã cài đặt. làm ơn
lưu ý một số bài kiểm tra sẽ yêu cầu quyền root ::

$ cd kselftest_install
   $ ./run_kselftest.sh

Để xem danh sách các bài kiểm tra có sẵn, có thể sử dụng tùy chọn ZZ0000ZZ ::

$ ./run_kselftest.sh -l

Tùy chọn ZZ0000ZZ có thể được sử dụng để chạy tất cả các xét nghiệm từ bộ sưu tập xét nghiệm hoặc
tùy chọn ZZ0001ZZ cho các thử nghiệm đơn lẻ cụ thể. Hoặc có thể được sử dụng nhiều lần::

$ ./run_kselftest.sh -c size -c seccomp -t bộ tính giờ:posix_timers -t bộ đếm thời gian:nanosleep

Đối với các tính năng khác, hãy xem đầu ra sử dụng tập lệnh, được thấy với tùy chọn ZZ0000ZZ.

Hết thời gian chờ tự kiểm tra
=====================

Quá trình tự kiểm tra được thiết kế nhanh chóng và do đó thời gian chờ mặc định được sử dụng là 45
giây cho mỗi bài kiểm tra. Các bài kiểm tra có thể ghi đè thời gian chờ mặc định bằng cách thêm
một tệp cài đặt trong thư mục của họ và đặt biến thời gian chờ ở đó thành
đã định cấu hình thời gian chờ trên mong muốn cho bài kiểm tra. Chỉ có một số bài kiểm tra ghi đè
thời gian chờ có giá trị cao hơn 45 giây, quá trình tự kiểm tra sẽ cố gắng giữ
nó theo cách đó. Hết thời gian chờ trong quá trình tự kiểm tra không được coi là nghiêm trọng vì
hệ thống trong đó quá trình chạy thử có thể thay đổi và điều này cũng có thể sửa đổi
thời gian dự kiến để chạy thử nghiệm. Nếu bạn có quyền kiểm soát hệ thống
sẽ chạy thử nghiệm, bạn có thể định cấu hình trình chạy thử nghiệm trên các hệ thống đó để
sử dụng thời gian chờ lớn hơn hoặc thấp hơn trên dòng lệnh như với ZZ0000ZZ hoặc
đối số ZZ0001ZZ. Ví dụ: sử dụng 165 giây thay thế
người ta sẽ sử dụng ::

$ ./run_kselftest.sh --override-timeout 165

Bạn có thể xem đầu ra TAP để xem liệu bạn có hết thời gian chờ hay không. kiểm tra
người chạy biết bài kiểm tra phải chạy trong một thời gian cụ thể thì có thể tùy ý
coi những khoảng thời gian chờ này là nghiêm trọng.

Tự kiểm tra bao bì
===================

Trong một số trường hợp cần phải đóng gói, chẳng hạn như khi các bài kiểm tra cần chạy trên một
hệ thống khác nhau. Để đóng gói selftests, hãy chạy::

$ make -C công cụ/thử nghiệm/selftests gen_tar

Điều này tạo ra một tarball trong thư mục ZZ0001ZZ. Bởi
mặc định, định dạng ZZ0002ZZ được sử dụng. Định dạng nén tar có thể bị ghi đè bởi
chỉ định biến tạo ZZ0003ZZ. Bất kỳ giá trị nào được ZZ0000ZZ công nhận
tùy chọn được hỗ trợ, chẳng hạn như::

$ make -C công cụ/thử nghiệm/selftests gen_tar FORMAT=.xz

ZZ0001ZZ gọi ZZ0002ZZ để bạn có thể sử dụng nó để đóng gói một tập hợp con của
kiểm tra bằng cách sử dụng các biến được chỉ định trong ZZ0000ZZ
phần::

$ make -C công cụ/kiểm tra/selftests gen_tar TARGETS="size" FORMAT=.xz

.. _tar's auto-compress: https://www.gnu.org/software/tar/manual/html_node/gzip.html#auto_002dcompress

Đóng góp các thử nghiệm mới
======================

Nói chung, các quy tắc để tự kiểm tra là

* Làm nhiều nhất có thể nếu bạn chưa root;

* Đừng mất quá nhiều thời gian;

* Không phá vỡ công trình trên bất kỳ kiến ​​trúc nào và

* Đừng làm lỗi "make run_tests" cấp cao nhất nếu tính năng của bạn bị lỗi
   chưa được định cấu hình.

* Đầu ra của các bài kiểm tra phải phù hợp với tiêu chuẩn TAP để đảm bảo chất lượng cao
   kiểm tra chất lượng và nắm bắt các lỗi/lỗi bằng các chi tiết cụ thể.
   Các tiêu đề kselftest.h và kselftest_harness.h cung cấp các hàm bao cho
   xuất kết quả kiểm tra. Những trình bao bọc này nên được sử dụng để vượt qua,
   thất bại, thoát và bỏ qua tin nhắn. Hệ thống CI có thể dễ dàng phân tích đầu ra TAP
   tin nhắn để phát hiện kết quả kiểm tra.

Đóng góp các thử nghiệm mới (chi tiết)
================================

* Trong Makefile của bạn, hãy sử dụng các tiện ích từ lib.mk bằng cách đưa nó vào thay vì
   phát minh lại bánh xe. Chỉ định cờ và cờ tạo nhị phân trên
   cần có cơ sở trước khi đưa lib.mk vào. ::

CFLAGS = $(KHDR_INCLUDES)
    TEST_GEN_PROGS := close_range_test
    bao gồm ../lib.mk

* Sử dụng TEST_GEN_XXX nếu các tệp nhị phân hoặc tệp đó được tạo trong quá trình
   biên soạn.

TEST_PROGS, TEST_GEN_PROGS có nghĩa là nó được kiểm tra bởi
   mặc định.

TEST_GEN_MODS_DIR nên được sử dụng bởi các thử nghiệm yêu cầu xây dựng mô-đun
   trước khi bài kiểm tra bắt đầu. Biến sẽ chứa tên của thư mục
   chứa các module.

TEST_CUSTOM_PROGS nên được sử dụng bởi các thử nghiệm yêu cầu xây dựng tùy chỉnh
   quy tắc và ngăn chặn việc sử dụng quy tắc xây dựng chung.

TEST_PROGS dành cho các tập lệnh shell thử nghiệm. Hãy đảm bảo tập lệnh shell có
   tập bit thực thi của nó. Nếu không, lib.mk run_tests sẽ tạo cảnh báo.

TEST_CUSTOM_PROGS và TEST_PROGS sẽ được chạy bởi run_tests chung.

TEST_PROGS_EXTENDED, TEST_GEN_PROGS_EXTENDED có nghĩa là
   thực thi mà không được kiểm tra theo mặc định.

TEST_FILES, TEST_GEN_FILES có nghĩa là tệp được sử dụng bởi
   kiểm tra.

TEST_INCLUDES tương tự như TEST_FILES, nó liệt kê các tập tin cần được
   được bao gồm khi xuất hoặc cài đặt các bài kiểm tra, với nội dung sau
   sự khác biệt:

* symlinks to files in other directories are preserved
    * phần đường dẫn bên dưới tools/testing/selftests/ được giữ nguyên khi
      sao chép các tập tin vào thư mục đầu ra

TEST_INCLUDES có nghĩa là liệt kê các phụ thuộc nằm trong các thư mục khác của
   hệ thống phân cấp selftests.

* Trước tiên hãy sử dụng các tiêu đề bên trong nguồn kernel và/hoặc git repo, sau đó
   tiêu đề hệ thống.  Tiêu đề cho bản phát hành kernel trái ngược với tiêu đề
   được cài đặt bởi bản phân phối trên hệ thống phải là trọng tâm chính để có thể
   để tìm hồi quy. Sử dụng KHDR_INCLUDES trong Makefile để bao gồm các tiêu đề từ
   nguồn hạt nhân.

* Nếu bài kiểm tra cần bật các tùy chọn cấu hình kernel cụ thể, hãy thêm tệp cấu hình vào
   thư mục kiểm tra để kích hoạt chúng.

ví dụ: công cụ/thử nghiệm/selftests/android/config

* Tạo tệp .gitignore trong thư mục kiểm tra và thêm tất cả các đối tượng được tạo
   trong đó.

* Thêm tên thử nghiệm mới trong TARGETS trong selftests/Makefile::

TARGETS += android

* Tất cả các thay đổi sẽ vượt qua::

kselftest-{all,install,clean,gen_tar}
    kselftest-{all,install,clean,gen_tar} O=abo_path
    kselftest-{all,install,clean,gen_tar} O=rel_path
    tạo -C công cụ/kiểm tra/selftests {all,install,clean,gen_tar}
    tạo -C công cụ/kiểm tra/selftests {all,install,clean,gen_tar} O=abs_path
    tạo -C công cụ/kiểm tra/selftests {all,install,clean,gen_tar} O=rel_path

Mô-đun thử nghiệm
===========

Kselftest kiểm tra kernel từ không gian người dùng.  Đôi khi có những điều cần
kiểm tra từ bên trong kernel, một phương pháp để thực hiện việc này là tạo một
mô-đun thử nghiệm.  Chúng ta có thể gắn mô-đun vào khung kselftest bằng cách
bằng cách sử dụng trình chạy thử tập lệnh shell.  ZZ0000ZZ được thiết kế
để tạo thuận lợi cho quá trình này.  Ngoài ra còn có một tệp tiêu đề được cung cấp cho
hỗ trợ viết các mô-đun hạt nhân để sử dụng với kselftest:

-ZZ0000ZZ
-ZZ0001ZZ

Lưu ý rằng các mô-đun kiểm tra sẽ làm hỏng hạt nhân bằng TAINT_TEST. Điều này sẽ
tự động xảy ra đối với các mô-đun trong ZZ0000ZZ
thư mục hoặc cho các mô-đun sử dụng tiêu đề ZZ0001ZZ ở trên.
Nếu không, bạn sẽ cần thêm ZZ0002ZZ vào mô-đun của mình
nguồn. các bản tự kiểm tra không tải mô-đun thường sẽ không làm hỏng
kernel, nhưng trong trường hợp mô-đun không kiểm tra được tải, TEST_TAINT có thể
được áp dụng từ không gian người dùng bằng cách ghi vào ZZ0003ZZ.

Cách sử dụng
----------

Ở đây chúng tôi trình bày các bước điển hình để tạo một mô-đun thử nghiệm và gắn nó vào
kselftest.  Chúng tôi sử dụng kselftests cho lib/ làm ví dụ.

1. Tạo mô-đun thử nghiệm

2. Tạo tập lệnh kiểm thử sẽ chạy (tải/dỡ tải) mô-đun
   ví dụ: ZZ0000ZZ

3. Thêm dòng vào tệp cấu hình, ví dụ: ZZ0000ZZ

4. Thêm tập lệnh kiểm tra vào makefile, vd ZZ0000ZZ

5. Xác minh nó hoạt động:

.. code-block:: sh

   # Assumes you have booted a fresh build of this kernel tree
   cd /path/to/linux/tree
   make kselftest-merge
   make modules
   sudo make modules_install
   make TARGETS=lib kselftest

Mô-đun ví dụ
--------------

Một mô-đun thử nghiệm cơ bản có thể trông như thế này:

.. code-block:: c

   // SPDX-License-Identifier: GPL-2.0+

   #define pr_fmt(fmt) KBUILD_MODNAME ": " fmt

   #include "../tools/testing/selftests/kselftest_module.h"

   KSTM_MODULE_GLOBALS();

   /*
    * Kernel module for testing the foobinator
    */

   static int __init test_function()
   {
           ...
   }

   static void __init selftest(void)
   {
           KSTM_CHECK_ZERO(do_test_case("", 0));
   }

   KSTM_MODULE_LOADERS(test_foo);
   MODULE_AUTHOR("John Developer <jd@fooman.org>");
   MODULE_LICENSE("GPL");
   MODULE_INFO(test, "Y");

Kịch bản thử nghiệm mẫu
-------------------

.. code-block:: sh

    #!/bin/bash
    # SPDX-License-Identifier: GPL-2.0+
    $(dirname $0)/../kselftest/module.sh "foo" test_foo


Khai thác thử nghiệm
============

Tệp kselftest_harness.h chứa các trợ giúp hữu ích để xây dựng các bài kiểm tra.  các
khai thác kiểm tra là để kiểm tra không gian người dùng, để kiểm tra không gian kernel, hãy xem ZZ0000ZZ ở trên.

Các bài kiểm tra từ tools/testing/selftests/seccomp/seccomp_bpf.c có thể được sử dụng như
ví dụ.

Ví dụ
-------

.. kernel-doc:: tools/testing/selftests/kselftest_harness.h
    :doc: example


Người trợ giúp
-------

.. kernel-doc:: tools/testing/selftests/kselftest_harness.h
    :functions: TH_LOG TEST TEST_SIGNAL FIXTURE FIXTURE_DATA FIXTURE_SETUP
                FIXTURE_TEARDOWN TEST_F TEST_HARNESS_MAIN FIXTURE_VARIANT
                FIXTURE_VARIANT_ADD

Toán tử
---------

.. kernel-doc:: tools/testing/selftests/kselftest_harness.h
    :doc: operators

.. kernel-doc:: tools/testing/selftests/kselftest_harness.h
    :functions: ASSERT_EQ ASSERT_NE ASSERT_LT ASSERT_LE ASSERT_GT ASSERT_GE
                ASSERT_NULL ASSERT_TRUE ASSERT_NULL ASSERT_TRUE ASSERT_FALSE
                ASSERT_STREQ ASSERT_STRNE EXPECT_EQ EXPECT_NE EXPECT_LT
                EXPECT_LE EXPECT_GT EXPECT_GE EXPECT_NULL EXPECT_TRUE
                EXPECT_FALSE EXPECT_STREQ EXPECT_STRNE
