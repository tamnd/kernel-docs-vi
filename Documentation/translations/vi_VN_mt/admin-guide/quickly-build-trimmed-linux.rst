.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/quickly-build-trimmed-linux.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. [see the bottom of this file for redistribution information]

===============================================
Cách nhanh chóng xây dựng kernel Linux đã được cắt bớt
===========================================

Hướng dẫn này giải thích cách xây dựng nhanh chóng các nhân Linux lý tưởng cho
mục đích thử nghiệm nhưng cũng hoàn toàn phù hợp để sử dụng hàng ngày.

Bản chất của quy trình (còn gọi là 'TL;DR')
========================================

*[Nếu bạn mới biên dịch Linux, hãy bỏ qua TLDR này và chuyển sang phần tiếp theo
phần bên dưới: nó chứa hướng dẫn từng bước chi tiết hơn, nhưng
vẫn ngắn gọn, dễ theo dõi; hướng dẫn đó và tài liệu tham khảo kèm theo
phần cũng đề cập đến các lựa chọn thay thế, cạm bẫy và các khía cạnh bổ sung, tất cả
có thể phù hợp với bạn.]*

Nếu hệ thống của bạn sử dụng các kỹ thuật như Khởi động an toàn, hãy chuẩn bị cho phép khởi động
nhân Linux tự biên dịch; cài đặt trình biên dịch và mọi thứ khác cần thiết cho
xây dựng Linux; đảm bảo có 12 Gigabyte dung lượng trống trong thư mục chính của bạn.
Bây giờ hãy chạy các lệnh sau để tải xuống các nguồn chính tuyến Linux mới,
sau đó bạn sử dụng để định cấu hình, xây dựng và cài đặt kernel của riêng mình::

git clone --deep 1 -b master \
      ZZ0000ZZ ~/linux/
    cd ~/linux/
    # Hint: nếu bạn muốn áp dụng các bản vá, hãy thực hiện ngay tại thời điểm này. Xem bên dưới để biết chi tiết.
    # Hint: bạn nên gắn thẻ công trình của mình vào thời điểm này. Xem bên dưới để biết chi tiết.
    vâng "" | tạo localmodconfig
    # Hint: tại thời điểm này, bạn có thể muốn điều chỉnh cấu hình bản dựng; bạn sẽ
    #   have tới, nếu bạn đang chạy Debian. Xem bên dưới để biết chi tiết.
    tạo -j $(nproc --all)
    # Note: trên nhiều bản phân phối hàng hóa, lệnh tiếp theo là đủ, nhưng trên Arch
    #   Linux, các dẫn xuất của nó và một số khác thì không. Xem bên dưới để biết chi tiết.
    lệnh -v installkernel && sudo thực hiện cài đặt module_install
    khởi động lại

Nếu sau này bạn muốn tạo ảnh chụp nhanh dòng chính mới hơn, hãy sử dụng các lệnh sau::

cd ~/linux/
    git tìm nạp --độ sâu 1 nguồn gốc
    # Note: lệnh tiếp theo sẽ loại bỏ mọi thay đổi bạn đã thực hiện đối với mã:
    kiểm tra git --force --detach Origin/master
    # Reminder: nếu bạn muốn (lại) áp dụng các bản vá, hãy thực hiện vào thời điểm này.
    # Reminder: bạn có thể muốn thêm hoặc sửa đổi thẻ xây dựng tại thời điểm này.
    tạo olddefconfig
    tạo -j $(nproc --all)
    # Reminder: lệnh tiếp theo trên một số bản phân phối không đủ.
    lệnh -v installkernel && sudo thực hiện cài đặt module_install
    khởi động lại

Hướng dẫn từng bước
==================

Về nguyên tắc, việc biên dịch nhân Linux của riêng bạn rất dễ dàng. Có nhiều cách khác nhau để
làm điều đó. Cái nào trong số chúng thực sự hoạt động và tốt nhất tùy thuộc vào hoàn cảnh.

Hướng dẫn này mô tả một cách hoàn toàn phù hợp cho những ai muốn nhanh chóng
cài đặt Linux từ các nguồn mà không bị làm phiền bởi các chi tiết phức tạp; cái
mục tiêu là bao gồm mọi thứ thường cần trên các bản phân phối Linux chính thống
chạy trên phần cứng máy tính hoặc máy chủ thông thường.

Cách tiếp cận được mô tả rất phù hợp cho mục đích thử nghiệm, chẳng hạn như thử một
đề xuất khắc phục hoặc để kiểm tra xem sự cố đã được khắc phục trong cơ sở mã mới nhất chưa.
Tuy nhiên, các hạt nhân được xây dựng theo cách này cũng hoàn toàn phù hợp để sử dụng hàng ngày.
đồng thời dễ dàng cập nhật.

Các bước sau đây mô tả các khía cạnh quan trọng của quy trình; một
phần tham khảo toàn diện sau đó sẽ giải thích từng chi tiết hơn. Nó
đôi khi cũng mô tả các cách tiếp cận, cạm bẫy cũng như sai sót thay thế
điều đó có thể xảy ra tại một thời điểm cụ thể -- và làm thế nào để mọi việc diễn ra suôn sẻ
một lần nữa.

..
   Note: if you see this note, you are reading the text's source file. You
   might want to switch to a rendered version, as it makes it a lot easier to
   quickly look something up in the reference section and afterwards jump back
   to where you left off. Find a the latest rendered version here:
   https://docs.kernel.org/admin-guide/quickly-build-trimmed-linux.html

.. _backup_sbs:

 * Create a fresh backup and put system repair and restore tools at hand, just
   to be prepared for the unlikely case of something going sideways.

   [:ref:`details<backup>`]

.. _secureboot_sbs:

 * On platforms with 'Secure Boot' or similar techniques, prepare everything to
   ensure the system will permit your self-compiled kernel to boot later. The
   quickest and easiest way to achieve this on commodity x86 systems is to
   disable such techniques in the BIOS setup utility; alternatively, remove
   their restrictions through a process initiated by
   ``mokutil --disable-validation``.

   [:ref:`details<secureboot>`]

.. _buildrequires_sbs:

 * Install all software required to build a Linux kernel. Often you will need:
   'bc', 'binutils' ('ld' et al.), 'bison', 'flex', 'gcc', 'git', 'openssl',
   'pahole', 'perl', and the development headers for 'libelf' and 'openssl'. The
   reference section shows how to quickly install those on various popular Linux
   distributions.

   [:ref:`details<buildrequires>`]

.. _diskspace_sbs:

 * Ensure to have enough free space for building and installing Linux. For the
   latter 150 Megabyte in /lib/ and 100 in /boot/ are a safe bet. For storing
   sources and build artifacts 12 Gigabyte in your home directory should
   typically suffice. If you have less available, be sure to check the reference
   section for the step that explains adjusting your kernels build
   configuration: it mentions a trick that reduce the amount of required space
   in /home/ to around 4 Gigabyte.

   [:ref:`details<diskspace>`]

.. _sources_sbs:

 * Retrieve the sources of the Linux version you intend to build; then change
   into the directory holding them, as all further commands in this guide are
   meant to be executed from there.

   *[Note: the following paragraphs describe how to retrieve the sources by
   partially cloning the Linux stable git repository. This is called a shallow
   clone. The reference section explains two alternatives:* :ref:`packaged
   archives<sources_archive>` *and* :ref:`a full git clone<sources_full>` *;
   prefer the latter, if downloading a lot of data does not bother you, as that
   will avoid some* :ref:`peculiar characteristics of shallow clones the
   reference section explains<sources_shallow>` *.]*

   First, execute the following command to retrieve a fresh mainline codebase::

     git clone --no-checkout --depth 1 -b master \
       https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git ~/linux/
     cd ~/linux/

   If you want to access recent mainline releases and pre-releases, deepen you
   clone's history to the oldest mainline version you are interested in::

     git fetch --shallow-exclude=v6.0 origin

   In case you want to access a stable/longterm release (say v6.1.5), simply add
   the branch holding that series; afterwards fetch the history at least up to
   the mainline version that started the series (v6.1)::

     git remote set-branches --add origin linux-6.1.y
     git fetch --shallow-exclude=v6.0 origin

   Now checkout the code you are interested in. If you just performed the
   initial clone, you will be able to check out a fresh mainline codebase, which
   is ideal for checking whether developers already fixed an issue::

      git checkout --detach origin/master

   If you deepened your clone, you instead of ``origin/master`` can specify the
   version you deepened to (``v6.0`` above); later releases like ``v6.1`` and
   pre-release like ``v6.2-rc1`` will work, too. Stable or longterm versions
   like ``v6.1.5`` work just the same, if you added the appropriate
   stable/longterm branch as described.

   [:ref:`details<sources>`]

.. _patching_sbs:

 * In case you want to apply a kernel patch, do so now. Often a command like
   this will do the trick::

     patch -p1 < ../proposed-fix.patch

   If the ``-p1`` is actually needed, depends on how the patch was created; in
   case it does not apply thus try without it.

   If you cloned the sources with git and anything goes sideways, run ``git
   reset --hard`` to undo any changes to the sources.

   [:ref:`details<patching>`]

.. _tagging_sbs:

 * If you patched your kernel or have one of the same version installed already,
   better add a unique tag to the one you are about to build::

     echo "-proposed_fix" > localversion

   Running ``uname -r`` under your kernel later will then print something like
   '6.1-rc4-proposed_fix'.

   [:ref:`details<tagging>`]

 .. _configuration_sbs:

 * Create the build configuration for your kernel based on an existing
   configuration.

   If you already prepared such a '.config' file yourself, copy it to
   ~/linux/ and run ``make olddefconfig``.

   Use the same command, if your distribution or somebody else already tailored
   your running kernel to your or your hardware's needs: the make target
   'olddefconfig' will then try to use that kernel's .config as base.

   Using this make target is fine for everybody else, too -- but you often can
   save a lot of time by using this command instead::

     yes "" | make localmodconfig

   This will try to pick your distribution's kernel as base, but then disable
   modules for any features apparently superfluous for your setup. This will
   reduce the compile time enormously, especially if you are running an
   universal kernel from a commodity Linux distribution.

   There is a catch: 'localmodconfig' is likely to disable kernel features you
   did not use since you booted your Linux -- like drivers for currently
   disconnected peripherals or a virtualization software not haven't used yet.
   You can reduce or nearly eliminate that risk with tricks the reference
   section outlines; but when building a kernel just for quick testing purposes
   it is often negligible if such features are missing. But you should keep that
   aspect in mind when using a kernel built with this make target, as it might
   be the reason why something you only use occasionally stopped working.

   [:ref:`details<configuration>`]

.. _configmods_sbs:

 * Check if you might want to or have to adjust some kernel configuration
   options:

  * Evaluate how you want to handle debug symbols. Enable them, if you later
    might need to decode a stack trace found for example in a 'panic', 'Oops',
    'warning', or 'BUG'; on the other hand disable them, if you are short on
    storage space or prefer a smaller kernel binary. See the reference section
    for details on how to do either. If neither applies, it will likely be fine
    to simply not bother with this. [:ref:`details<configmods_debugsymbols>`]

  * Are you running Debian? Then to avoid known problems by performing
    additional adjustments explained in the reference section.
    [:ref:`details<configmods_distros>`].

  * If you want to influence the other aspects of the configuration, do so now
    by using make targets like 'menuconfig' or 'xconfig'.
    [:ref:`details<configmods_individual>`].

.. _build_sbs:

 * Build the image and the modules of your kernel::

     make -j $(nproc --all)

   If you want your kernel packaged up as deb, rpm, or tar file, see the
   reference section for alternatives.

   [:ref:`details<build>`]

.. _install_sbs:

 * Now install your kernel::

     command -v installkernel && sudo make modules_install install

   Often all left for you to do afterwards is a ``reboot``, as many commodity
   Linux distributions will then create an initramfs (also known as initrd) and
   an entry for your kernel in your bootloader's configuration; but on some
   distributions you have to take care of these two steps manually for reasons
   the reference section explains.

   On a few distributions like Arch Linux and its derivatives the above command
   does nothing at all; in that case you have to manually install your kernel,
   as outlined in the reference section.

   If you are running an immutable Linux distribution, check its documentation
   and the web to find out how to install your own kernel there.

   [:ref:`details<install>`]

.. _another_sbs:

 * To later build another kernel you need similar steps, but sometimes slightly
   different commands.

   First, switch back into the sources tree::

      cd ~/linux/

   In case you want to build a version from a stable/longterm series you have
   not used yet (say 6.2.y), tell git to track it::

      git remote set-branches --add origin linux-6.2.y

   Now fetch the latest upstream changes; you again need to specify the earliest
   version you care about, as git otherwise might retrieve the entire commit
   history::

     git fetch --shallow-exclude=v6.0 origin

   Now switch to the version you are interested in -- but be aware the command
   used here will discard any modifications you performed, as they would
   conflict with the sources you want to checkout::

     git checkout --force --detach origin/master

   At this point you might want to patch the sources again or set/modify a build
   tag, as explained earlier. Afterwards adjust the build configuration to the
   new codebase using olddefconfig, which will now adjust the configuration file
   you prepared earlier using localmodconfig  (~/linux/.config) for your next
   kernel::

     # reminder: if you want to apply patches, do it at this point
     # reminder: you might want to update your build tag at this point
     make olddefconfig

   Now build your kernel::

     make -j $(nproc --all)

   Afterwards install the kernel as outlined above::

     command -v installkernel && sudo make modules_install install

   [:ref:`details<another>`]

.. _uninstall_sbs:

 * Your kernel is easy to remove later, as its parts are only stored in two
   places and clearly identifiable by the kernel's release name. Just ensure to
   not delete the kernel you are running, as that might render your system
   unbootable.

   Start by deleting the directory holding your kernel's modules, which is named
   after its release name -- '6.0.1-foobar' in the following example::

     sudo rm -rf /lib/modules/6.0.1-foobar

   Now try the following command, which on some distributions will delete all
   other kernel files installed while also removing the kernel's entry from the
   bootloader configuration::

     command -v kernel-install && sudo kernel-install -v remove 6.0.1-foobar

   If that command does not output anything or fails, see the reference section;
   do the same if any files named '*6.0.1-foobar*' remain in /boot/.

   [:ref:`details<uninstall>`]

.. _submit_improvements_qbtl:

Bạn có gặp rắc rối khi làm theo hướng dẫn từng bước không được giải thích rõ ràng không?
phần tham khảo dưới đây? Bạn có phát hiện ra lỗi không? Hoặc bạn có ý tưởng nào về cách
cải thiện hướng dẫn?

Nếu bất kỳ điều nào trong số đó áp dụng, vui lòng cho nhà phát triển biết bằng cách gửi một ghi chú ngắn
hoặc một bản vá cho Thorsten Leemhuis <linux@leemhuis.info> trong khi lý tưởng nhất là CC
danh sách gửi thư tài liệu Linux công khai <linux-doc@vger.kernel.org>. Những phản hồi như vậy là
rất quan trọng để cải thiện văn bản này hơn nữa, điều này mang lại lợi ích cho mọi người, vì nó sẽ
cho phép nhiều người nắm vững nhiệm vụ được mô tả ở đây.

Phần tham khảo hướng dẫn từng bước
============================================

Phần này chứa thông tin bổ sung cho từng bước ở trên
hướng dẫn.

.. _backup:

Chuẩn bị cho trường hợp khẩn cấp
-----------------------

ZZ0001ZZ
   [ZZ0000ZZ]

Hãy nhớ rằng, bạn đang làm việc với máy tính, đôi khi nó làm những việc không mong muốn.
-- đặc biệt nếu bạn mày mò với những phần quan trọng như nhân của một hệ điều hành
hệ thống. Đó là những gì bạn sắp làm trong quá trình này. Vì vậy, hãy chuẩn bị tốt hơn
cho một điều gì đó đi ngang, ngay cả khi điều đó không nên xảy ra.

[ZZ0000ZZ]

.. _secureboot:

Xử lý các kỹ thuật như Khởi động an toàn
----------------------------------------

*Trên các nền tảng có 'Khởi động an toàn' hoặc các kỹ thuật tương tự, hãy chuẩn bị mọi thứ để
   đảm bảo hệ thống sẽ cho phép hạt nhân tự biên dịch của bạn khởi động sau.*
   [ZZ0000ZZ]

Nhiều hệ thống hiện đại chỉ cho phép một số hệ điều hành nhất định khởi động; do đó họ bằng cách
mặc định sẽ từ chối khởi động các hạt nhân tự biên dịch.

Lý tưởng nhất là bạn giải quyết vấn đề này bằng cách làm cho nền tảng của bạn tin cậy vào các hạt nhân tự xây dựng của bạn
với sự giúp đỡ của một giấy chứng nhận và ký kết. Cách thực hiện điều đó không được mô tả
ở đây, vì nó đòi hỏi nhiều bước khác nhau sẽ khiến văn bản đi quá xa so với
mục đích của nó; 'Tài liệu/admin-guide/module-signing.rst' và các trang web khác nhau
các bên đã giải thích điều này chi tiết hơn.

Tạm thời vô hiệu hóa các giải pháp như Khởi động an toàn là một cách khác để bạn tự thực hiện
Khởi động Linux. Trên các hệ thống x86 thông thường, có thể thực hiện việc này trong Cài đặt BIOS
tiện ích; các bước để làm như vậy không được mô tả ở đây vì chúng rất khác nhau giữa
máy móc.

Trên các bản phân phối Linux x86 chính thống, có tùy chọn thứ ba và phổ biến:
vô hiệu hóa tất cả các hạn chế Khởi động an toàn cho môi trường Linux của bạn. bạn có thể
bắt đầu quá trình này bằng cách chạy ZZ0000ZZ; điều này sẽ
yêu cầu bạn tạo mật khẩu dùng một lần để ghi lại một cách an toàn. bây giờ
khởi động lại; ngay sau khi BIOS của bạn thực hiện tất cả quá trình tự kiểm tra, bộ nạp khởi động Shim sẽ
hiển thị hộp màu xanh có thông báo 'Nhấn phím bất kỳ để thực hiện quản lý MOK'. đánh
một số phím trước khi đếm ngược hiển thị. Điều này sẽ mở một menu và chọn 'Thay đổi
Trạng thái khởi động an toàn' ở đó. 'MokManager' của Shim bây giờ sẽ yêu cầu bạn nhập ba
các ký tự được chọn ngẫu nhiên từ mật khẩu một lần được chỉ định trước đó. Một lần
bạn đã cung cấp chúng, hãy xác nhận rằng bạn thực sự muốn tắt xác thực.
Sau đó, cho phép MokManager khởi động lại máy.

[ZZ0000ZZ]

.. _buildrequires:

Yêu cầu xây dựng cài đặt
--------------------------

ZZ0001ZZ
   [ZZ0000ZZ]

Hạt nhân khá độc lập, nhưng bên cạnh các công cụ như trình biên dịch, bạn sẽ
đôi khi cần một vài thư viện để xây dựng một thư viện. Cách cài đặt mọi thứ cần thiết
phụ thuộc vào bản phân phối Linux của bạn và cấu hình kernel mà bạn đang sử dụng
sắp xây dựng.

Dưới đây là một vài ví dụ về những gì bạn thường cần trên một số sản phẩm phổ thông
phân phối:

* Debian, Ubuntu và các phiên bản phái sinh::

sudo apt cài đặt bc binutils bison người lùn flex gcc git make openssl \
       pahole Perl-base libssl-dev libelf-dev

* Fedora và các dẫn xuất::

sudo dnf cài đặt binutils /usr/include/{libelf.h,openssl/pkcs7.h} \
       /usr/bin/{bc,bison,flex,gcc,git,openssl,make,perl,pahole}

* openSUSE và các dẫn xuất::

sudo zypper cài đặt bc binutils bison người lùn flex gcc git tạo perl-base \
       openssl openssl-devel libelf-dev

Trong trường hợp bạn thắc mắc tại sao các danh sách này lại bao gồm openssl và các tiêu đề phát triển của nó:
chúng cần thiết để hỗ trợ Khởi động an toàn, tính năng được nhiều bản phân phối kích hoạt trong
cấu hình kernel của họ cho máy x86.

Đôi khi bạn sẽ cần các công cụ nén các định dạng như bzip2, gzip, lz4,
lzma, lzo, xz hoặc zstd nữa.

Bạn có thể cần các thư viện bổ sung và tiêu đề phát triển của chúng trong trường hợp bạn
thực hiện các nhiệm vụ không được đề cập trong hướng dẫn này. Ví dụ, zlib sẽ cần thiết khi
xây dựng các công cụ kernel từ thư mục tools/; điều chỉnh xây dựng
cấu hình với các mục tiêu tạo như 'menuconfig' hoặc 'xconfig' sẽ yêu cầu
tiêu đề phát triển cho ncurses hoặc Qt5.

[ZZ0000ZZ]

.. _diskspace:

Yêu cầu về không gian
------------------

ZZ0001ZZ
   [ZZ0000ZZ]

Những con số được đề cập chỉ là ước tính sơ bộ kèm theo một khoản phụ phí lớn
bên an toàn, vì vậy thường bạn sẽ cần ít hơn.

Nếu bạn gặp hạn chế về không gian, hãy nhớ đọc phần tham khảo khi bạn
đạt ZZ0000ZZ, như
đảm bảo các biểu tượng gỡ lỗi bị vô hiệu hóa sẽ giảm dung lượng ổ đĩa tiêu thụ khá nhiều
vài gigabyte.

[ZZ0000ZZ]


.. _sources:

Tải xuống các nguồn
--------------------

ZZ0001ZZ
  [ZZ0000ZZ]

Hướng dẫn từng bước phác thảo cách truy xuất các nguồn của Linux bằng cách sử dụng một
bản sao git. Có ZZ0000ZZ và
hai cách thay thế đáng mô tả: ZZ0001ZZ
và ZZ0002ZZ. Và các khía cạnh 'ZZ0003ZZ' và 'ZZ0004ZZ' cũng cần được xây dựng chi tiết.

Lưu ý, để đơn giản, các lệnh được sử dụng trong hướng dẫn này lưu trữ bản dựng
các tạo phẩm trong cây nguồn. Nếu bạn muốn tách chúng ra, chỉ cần thêm
thứ gì đó giống như ZZ0000ZZ để thực hiện cuộc gọi; cũng điều chỉnh đường dẫn
trong tất cả các lệnh thêm tệp hoặc sửa đổi bất kỳ lệnh nào được tạo (như '.config' của bạn).

[ZZ0000ZZ]

.. _sources_shallow:

Đặc điểm đáng chú ý của dòng vô tính nông
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hướng dẫn từng bước sử dụng bản sao nông vì đây là giải pháp tốt nhất cho hầu hết mọi người.
đối tượng mục tiêu của tài liệu này. Có một số khía cạnh của phương pháp này
đáng nói đến:

* Tài liệu này ở hầu hết các nơi sử dụng ZZ0000ZZ với ZZ0001ZZ
   để chỉ định phiên bản sớm nhất mà bạn quan tâm (hay nói chính xác hơn là phiên bản git của nó
   thẻ). Ngoài ra, bạn có thể sử dụng tham số ZZ0002ZZ để chỉ định
   ngày tuyệt đối (ví dụ ZZ0003ZZ) hoặc tương đối (ZZ0004ZZ)
   xác định độ sâu của lịch sử bạn muốn tải xuống. Như một giây
   Ngoài ra, bạn cũng có thể chỉ định rõ ràng một độ sâu nhất định bằng một tham số
   như ZZ0005ZZ, trừ khi bạn thêm các nhánh cho hạt nhân ổn định/dài hạn.

* Khi chạy ZZ0000ZZ, hãy nhớ luôn chỉ định phiên bản cũ nhất,
   thời gian bạn quan tâm hoặc độ sâu rõ ràng như được hiển thị trong hướng dẫn từng bước
   hướng dẫn. Nếu không, bạn sẽ có nguy cơ tải xuống gần như toàn bộ lịch sử git,
   việc này sẽ tiêu tốn khá nhiều thời gian và băng thông đồng thời gây căng thẳng cho
   máy chủ.

Lưu ý, bạn không nhất thiết phải sử dụng cùng một phiên bản hoặc ngày tháng. Nhưng khi
   bạn thay đổi nó theo thời gian, git sẽ đào sâu hoặc làm phẳng lịch sử thành
   điểm quy định. Điều đó cho phép bạn truy xuất các phiên bản mà bạn nghĩ ban đầu
   bạn không cần -- hoặc nó sẽ loại bỏ nguồn của các phiên bản cũ hơn, vì
   ví dụ trong trường hợp bạn muốn giải phóng một số dung lượng đĩa. Điều sau sẽ xảy ra
   tự động khi sử dụng ZZ0000ZZ hoặc
   ZZ0001ZZ.

* Được cảnh báo, khi đào sâu bản sao của bạn, bạn có thể gặp phải một lỗi như
   'gây tử vong: lỗi trong đối tượng: không cho phép cafecaca0c0dacafeca0c0dacafeca0c0da'.
   Trong trường hợp đó hãy chạy ZZ0000ZZ và thử lại``

* Trong trường hợp bạn muốn hoàn nguyên các thay đổi từ một phiên bản nhất định (giả sử Linux 6.3) hoặc
   thực hiện chia đôi (v6.2..v6.3), tốt hơn hãy nói với ZZ0000ZZ để truy xuất
   đối tượng tối đa ba phiên bản trước đó (ví dụ: 6.0): ZZ0001ZZ sau đó sẽ
   có thể mô tả hầu hết các cam kết giống như trong một bản sao git đầy đủ.

[ZZ0000ZZ] [ZZ0001ZZ]

.. _sources_archive:

Tải xuống các nguồn bằng cách sử dụng kho lưu trữ gói
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Những người mới biên dịch Linux thường cho rằng việc tải xuống một kho lưu trữ thông qua
trang đầu của ZZ0000ZZ là cách tiếp cận tốt nhất để truy xuất Linux'
nguồn. Thực tế có thể như vậy nếu bạn chắc chắn chỉ xây dựng một
phiên bản kernel mà không thay đổi bất kỳ mã nào. Vấn đề là: bạn có thể chắc chắn điều này sẽ
đúng như vậy, nhưng trong thực tế nó thường trở thành một giả định sai lầm.

Đó là vì khi báo cáo hoặc gỡ lỗi một vấn đề, nhà phát triển thường yêu cầu
hãy thử một phiên bản khác. Họ cũng có thể đề nghị tạm thời hoàn tác một cam kết
với ZZ0000ZZ hoặc có thể cung cấp nhiều bản vá khác nhau để thử. Đôi khi phóng viên
cũng sẽ được yêu cầu sử dụng ZZ0001ZZ để tìm ra thay đổi gây ra sự cố.
Những thứ này dựa vào git hoặc xử lý nó dễ dàng và nhanh chóng hơn rất nhiều.

Một bản sao nông cũng không thêm bất kỳ chi phí đáng kể nào. Ví dụ, khi
bạn sử dụng ZZ0000ZZ để tạo một bản sao nông của dòng chính mới nhất
codebase git sẽ chỉ truy xuất nhiều dữ liệu hơn một chút so với tải xuống bản mới nhất
bản phát hành trước dòng chính (còn gọi là 'rc') thông qua trang đầu của kernel.org sẽ.

Do đó, một bản sao nông thường là lựa chọn tốt hơn. Tuy nhiên, nếu bạn muốn
để sử dụng kho lưu trữ nguồn đóng gói, hãy tải xuống một kho lưu trữ qua kernel.org; sau đó
trích xuất nội dung của nó vào một số thư mục và thay đổi thư mục con đã tạo
trong quá trình khai thác. Phần còn lại của hướng dẫn từng bước sẽ hoạt động tốt, ngoại trừ
từ những thứ dựa vào git -- nhưng điều này chủ yếu liên quan đến phần về
xây dựng liên tiếp các phiên bản khác.

[ZZ0000ZZ] [ZZ0001ZZ]

.. _sources_full:

Tải xuống các nguồn bằng bản sao git đầy đủ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu tải xuống và lưu trữ nhiều dữ liệu (~4,4 Gigabyte tính đến đầu năm 2023) thì
không có gì làm phiền bạn, thay vì một bản sao nông hãy thực hiện một bản sao git đầy đủ
thay vào đó. Khi đó bạn sẽ tránh được những đặc sản nêu trên và sẽ có tất cả
các phiên bản và cam kết riêng lẻ có sẵn bất kỳ lúc nào::

cuộn tròn -L \
      ZZ0000ZZ \
      -o linux-ổn định.git.bundle
    git clone linux-stable.git.bundle ~/linux/
    rm linux-ổn định.git.bundle
    cd ~/linux/
    nguồn gốc url thiết lập từ xa git \
      ZZ0001ZZ
    git tìm nguồn gốc
    kiểm tra git --detach nguồn gốc/master

[ZZ0000ZZ] [ZZ0001ZZ]

.. _sources_snapshot:

Bản phát hành trước (RC) phù hợp so với dòng chính mới nhất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi nhân bản các nguồn bằng git và kiểm tra Origin/master, bạn thường
sẽ truy xuất một cơ sở mã nằm ở đâu đó giữa cái mới nhất và cái tiếp theo
phát hành hoặc phát hành trước. Đây hầu như luôn là mã bạn muốn khi đưa ra
đưa ra quan điểm chính: các bản phát hành trước như v6.1-rc5 không có gì đặc biệt cả, như chúng vốn có
không nhận được bất kỳ thử nghiệm bổ sung đáng kể nào trước khi được xuất bản.

Có một ngoại lệ: bạn có thể muốn sử dụng bản phát hành chính mới nhất
(giả sử v6.1) trước khi bản phát hành trước đầu tiên của người kế nhiệm (v6.2-rc1) ra mắt. Đó là
bởi vì lỗi trình biên dịch và các vấn đề khác có nhiều khả năng xảy ra hơn trong quá trình này
thời gian, vì dòng chính nằm trong 'cửa sổ hợp nhất' của nó: giai đoạn thường kéo dài hai tuần,
trong đó phần lớn các thay đổi cho bản phát hành tiếp theo được hợp nhất.

[ZZ0000ZZ] [ZZ0001ZZ]

.. _sources_fresher:

Tránh độ trễ của đường chính
~~~~~~~~~~~~~~~~~~~~~~~~~

Những lời giải thích cho cả bản sao nông và bản sao đầy đủ đều lấy lại ý nghĩa
mã từ kho git ổn định của Linux. Điều đó làm cho mọi việc trở nên đơn giản hơn
đối tượng của tài liệu, vì nó cho phép truy cập dễ dàng vào cả dòng chính và
bản phát hành ổn định/dài hạn. Cách tiếp cận này chỉ có một nhược điểm:

Các thay đổi được hợp nhất vào kho lưu trữ chính chỉ được đồng bộ hóa với nhánh chính
của kho lưu trữ ổn định Linux cứ sau vài giờ. Độ trễ này hầu hết thời gian là
không có gì phải lo lắng; nhưng trong trường hợp bạn thực sự cần mã mới nhất, chỉ cần
thêm repo dòng chính làm điều khiển từ xa bổ sung và kiểm tra mã từ đó ::

git từ xa thêm dòng chính \
      ZZ0000ZZ
    git tìm nạp dòng chính
    kiểm tra git --detach dòng chính/chính

Khi thực hiện việc này với một bản sao nông, hãy nhớ gọi ZZ0000ZZ bằng một bản sao nông.
của các tham số được mô tả trước đó để giới hạn độ sâu.

[ZZ0000ZZ] [ZZ0001ZZ]

.. _patching:

Vá các nguồn (tùy chọn)
----------------------------

ZZ0001ZZ
  [ZZ0000ZZ]

Đây là thời điểm mà bạn có thể muốn vá hạt nhân của mình -- ví dụ như khi
một nhà phát triển đã đề xuất một bản sửa lỗi và yêu cầu bạn kiểm tra xem nó có hữu ích không. Từng bước một
hướng dẫn đã giải thích mọi thứ quan trọng ở đây.

[ZZ0000ZZ]

.. _tagging:

Gắn thẻ bản dựng kernel này (tùy chọn, thường là khôn ngoan)
------------------------------------------------

*Nếu bạn đã vá kernel hoặc đã cài đặt phiên bản kernel đó,
  tốt hơn nên gắn thẻ kernel của bạn bằng cách mở rộng tên phát hành của nó:*
  [ZZ0000ZZ]

Gắn thẻ kernel của bạn sẽ giúp tránh nhầm lẫn sau này, đặc biệt là khi bạn vá
hạt nhân của bạn. Việc thêm một thẻ riêng lẻ cũng sẽ đảm bảo hình ảnh của hạt nhân và
các mô-đun của nó được cài đặt song song với bất kỳ hạt nhân hiện có nào.

Có nhiều cách khác nhau để thêm một thẻ như vậy. Hướng dẫn từng bước thực hiện từng bước một
tạo một tệp 'localversion' trong thư mục bản dựng của bạn mà từ đó kernel
tập lệnh xây dựng sẽ tự động nhận thẻ. Sau này bạn có thể thay đổi tập tin đó
để sử dụng một thẻ khác trong các bản dựng tiếp theo hoặc chỉ cần xóa tệp đó để kết xuất
thẻ.

[ZZ0000ZZ]

.. _configuration:

Xác định cấu hình xây dựng cho kernel của bạn
----------------------------------------------

*Tạo cấu hình xây dựng cho kernel của bạn dựa trên cấu hình hiện có
  cấu hình.* [ZZ0000ZZ]

Có nhiều khía cạnh khác nhau cho các bước này đòi hỏi phải cẩn thận hơn
giải thích:

Cạm bẫy khi sử dụng tệp cấu hình khác làm cơ sở
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Làm cho các mục tiêu như localmodconfig và olddefconfig chia sẻ một số bẫy phổ biến mà bạn
muốn nhận thức được:

* Các mục tiêu này sẽ sử dụng lại cấu hình bản dựng kernel trong thư mục bản dựng của bạn
   (ví dụ: '~/linux/.config'), nếu có. Trong trường hợp bạn muốn bắt đầu từ
   gãi do đó bạn cần phải xóa nó.

* Mục tiêu thực hiện cố gắng tìm cấu hình cho kernel đang chạy của bạn
   tự động, nhưng có thể chọn kém. Một dòng như 'Đã tìm thấy mặc định # using
   trong /boot/config-6.0.7-250.fc36.x86_64' hoặc 'sử dụng cấu hình:
   '/boot/config-6.0.7-250.fc36.x86_64' cho bạn biết họ đã chọn tệp nào. Nếu
   đó không phải là mục đích dự định, chỉ cần lưu trữ nó dưới dạng '~/linux/.config'
   trước khi sử dụng những mục tiêu này.

* Những điều không mong muốn có thể xảy ra nếu bạn cố gắng sử dụng tệp cấu hình được chuẩn bị sẵn cho
   một hạt nhân (giả sử v6.0) trên thế hệ cũ hơn (giả sử v5.15). Trong trường hợp đó bạn
   có thể muốn sử dụng cấu hình làm cơ sở mà bản phân phối của bạn sử dụng
   khi họ sử dụng phiên bản kernel đó hoặc phiên bản kernel cũ hơn một chút.

Ảnh hưởng đến cấu hình
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mục tiêu tạo olddefconfig và ZZ0000ZZ được sử dụng khi sử dụng
localmodconfig sẽ đặt mọi tùy chọn xây dựng không xác định thành giá trị mặc định của chúng. Cái này
trong số những tính năng khác sẽ vô hiệu hóa nhiều tính năng kernel được giới thiệu sau
hạt nhân cơ sở đã được phát hành.

Nếu bạn muốn đặt các tùy chọn cấu hình này theo cách thủ công, hãy sử dụng ZZ0000ZZ
thay vì ZZ0001ZZ hoặc bỏ qua ZZ0002ZZ khi sử dụng
localmodconfig. Sau đó, với mỗi tùy chọn cấu hình không xác định, bạn sẽ được hỏi
làm thế nào để tiến hành. Trong trường hợp bạn không chắc chắn nên trả lời gì, chỉ cần nhấn 'enter' để
áp dụng giá trị mặc định.

Cạm bẫy lớn khi sử dụng localmodconfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Như đã giải thích ngắn gọn trong hướng dẫn từng bước: với localmodconfig nó
có thể dễ dàng xảy ra trường hợp hạt nhân tự xây dựng của bạn sẽ thiếu các mô-đun cho các tác vụ mà bạn
đã không thực hiện trước khi sử dụng mục tiêu này. Đó là bởi vì những nhiệm vụ đó
yêu cầu các mô-đun hạt nhân thường được tải tự động khi bạn thực hiện tác vụ đó
lần đầu tiên; nếu bạn không thực hiện tác vụ đó ít nhất một lần trước khi sử dụng
localmodconfig, do đó, localmodconfig sẽ cho rằng các mô-đun này là không cần thiết và
vô hiệu hóa chúng.

Bạn có thể cố gắng tránh điều này bằng cách thực hiện các tác vụ thông thường thường sẽ tự động tải
các mô-đun hạt nhân bổ sung: khởi động VM, thiết lập kết nối VPN, gắn vòng lặp
CD/DVD ISO, gắn kết chia sẻ mạng (CIFS, NFS, ...) và kết nối tất cả các thiết bị bên ngoài
các thiết bị (key 2FA, tai nghe, webcam, ...) cũng như các thiết bị lưu trữ có tập tin
các hệ thống mà bạn không sử dụng (btrfs, ext4, FAT, NTFS, XFS, ...). Nhưng nó
thật khó để nghĩ ra mọi thứ có thể cần thiết -- ngay cả các nhà phát triển hạt nhân
thường quên điều này hay điều khác vào thời điểm này.

Đừng để rủi ro đó làm phiền bạn, đặc biệt khi biên dịch kernel chỉ dành cho
mục đích thử nghiệm: mọi thứ thường quan trọng sẽ ở đó. Và nếu bạn quên
một cái gì đó quan trọng bạn có thể bật một tính năng còn thiếu sau và nhanh chóng chạy
các lệnh biên dịch và cài đặt kernel tốt hơn.

Nhưng nếu bạn dự định xây dựng và sử dụng các hạt nhân tự xây dựng thường xuyên, bạn có thể muốn
giảm rủi ro bằng cách ghi lại những mô-đun mà hệ thống của bạn tải trong quá trình
một vài tuần. Bạn có thể tự động hóa việc này với ZZ0001ZZ. Sau đó sử dụng ZZ0000ZZ để
trỏ localmodconfig vào danh sách các mô-đun modprobed-db được chú ý đang được sử dụng ::

vâng "" | tạo LSMOD="${HOME}"/.config/modprobed.db localmodconfig

Tòa nhà từ xa với localmodconfig
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn muốn sử dụng localmodconfig để xây dựng kernel cho máy khác, hãy chạy
ZZ0000ZZ trên đó và chuyển tệp đó đến máy chủ xây dựng của bạn.
Bây giờ hãy trỏ tập lệnh xây dựng vào tệp như thế này: ZZ0001ZZ. Lưu ý, trong trường hợp này
bạn có thể muốn sao chép cấu hình kernel cơ sở từ máy khác sang
cũng như đặt nó dưới dạng .config trong thư mục bản dựng của bạn.

[ZZ0000ZZ]

.. _configmods:

Điều chỉnh cấu hình bản dựng
--------------------------

*Kiểm tra xem bạn có muốn hoặc phải điều chỉnh một số cấu hình kernel không
   tùy chọn:*

Tùy thuộc vào nhu cầu của bạn, tại thời điểm này bạn có thể muốn hoặc phải điều chỉnh một số
tùy chọn cấu hình hạt nhân.

.. _configmods_debugsymbols:

Biểu tượng gỡ lỗi
~~~~~~~~~~~~~

ZZ0001ZZ
   [ZZ0000ZZ]

Hầu hết người dùng không cần quan tâm đến điều này, thường thì để lại mọi thứ cũng không sao
như nó vốn có; nhưng bạn nên xem xét kỹ hơn điều này, nếu bạn cần giải mã
dấu vết ngăn xếp hoặc muốn giảm mức tiêu thụ dung lượng.

Việc có sẵn các biểu tượng gỡ lỗi có thể rất quan trọng khi hạt nhân của bạn ném một lỗi
'hoảng loạn', 'Rất tiếc', 'cảnh báo' hoặc 'BUG' sau khi chạy, khi đó bạn sẽ
có thể tìm thấy chính xác vị trí xảy ra sự cố trong mã. Nhưng
việc thu thập và nhúng thông tin gỡ lỗi cần thiết sẽ tốn thời gian và tiêu tốn
khá nhiều dung lượng: vào cuối năm 2022, các tạo phẩm xây dựng cho hạt nhân x86 điển hình
được định cấu hình với localmodconfig tiêu tốn khoảng 5 Gigabyte dung lượng khi gỡ lỗi
các ký hiệu, nhưng nhỏ hơn 1 khi chúng bị vô hiệu hóa. Hình ảnh hạt nhân thu được và
các mô-đun cũng lớn hơn, giúp tăng thời gian tải.

Do đó, nếu bạn muốn có một hạt nhân nhỏ và không có khả năng giải mã dấu vết ngăn xếp
sau này, bạn có thể muốn tắt các biểu tượng gỡ lỗi để tránh những nhược điểm trên ::

./scripts/config --file .config -d DEBUG_INFO \
      -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -d DEBUG_INFO_DWARF4 \
      -d DEBUG_INFO_DWARF5 -e CONFIG_DEBUG_INFO_NONE
    tạo olddefconfig

Mặt khác, bạn chắc chắn muốn kích hoạt chúng, nếu có đủ
có thể sau này bạn cần giải mã dấu vết ngăn xếp (như được giải thích bởi 'Giải mã
thông báo lỗi' trong Tài liệu/admin-guide/tainted-kernels.rst trong phần khác
chi tiết)::

./scripts/config --file .config -d DEBUG_INFO_NONE -e DEBUG_KERNEL
      -e DEBUG_INFO -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -e KALLSYMS -e KALLSYMS_ALL
    tạo olddefconfig

Lưu ý, nhiều bản phân phối chính thống cho phép biểu tượng gỡ lỗi trong kernel của chúng
cấu hình -- do đó tạo các mục tiêu như localmodconfig và olddefconfig
thường chọn thiết lập đó.

[ZZ0000ZZ]

.. _configmods_distros:

Phân phối điều chỉnh cụ thể
~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ [ZZ0000ZZ]

Các phần sau đây giúp bạn tránh các sự cố xây dựng thường xảy ra
khi làm theo hướng dẫn này về một số phân phối hàng hóa.

ZZ0000ZZ

* Xóa tham chiếu cũ tới tệp chứng chỉ có thể khiến bản dựng của bạn bị lỗi
   thất bại::

./scripts/config --file .config --set-str SYSTEM_TRUSTED_KEYS ''

Ngoài ra, hãy tải xuống chứng chỉ cần thiết và thực hiện cấu hình đó
   tùy chọn trỏ đến nó, như ZZ0000ZZ
   -- hoặc tạo của riêng bạn, như được giải thích trong
   Tài liệu/admin-guide/module-signing.rst.

[ZZ0000ZZ]

.. _configmods_individual:

Điều chỉnh riêng lẻ
~~~~~~~~~~~~~~~~~~~~~~

*Nếu bạn muốn tác động đến các khía cạnh khác của cấu hình, hãy làm như vậy
   bây giờ* [ZZ0000ZZ]

Tại thời điểm này, bạn có thể sử dụng lệnh như ZZ0000ZZ để bật hoặc
vô hiệu hóa một số tính năng nhất định bằng giao diện người dùng dựa trên văn bản; sử dụng đồ họa
sử dụng cấu hình, thay vào đó hãy sử dụng mục tiêu tạo ZZ0001ZZ hoặc ZZ0002ZZ.
Tất cả đều yêu cầu thư viện phát triển từ bộ công cụ mà chúng dựa trên
(ncurses, Qt5, Gtk2); một thông báo lỗi sẽ cho bạn biết nếu có điều gì đó cần thiết
thiếu.

[ZZ0000ZZ]

.. _build:

Xây dựng hạt nhân của bạn
-----------------

ZZ0001ZZ [ZZ0000ZZ]

Rất nhiều lỗi có thể xảy ra ở giai đoạn này, nhưng những hướng dẫn bên dưới sẽ giúp bạn
chính bạn. Một tiểu mục khác giải thích cách đóng gói trực tiếp kernel của bạn dưới dạng
deb, vòng/phút hoặc tar.

Xử lý lỗi xây dựng
~~~~~~~~~~~~~~~~~~~~~~~~~

Khi xảy ra lỗi xây dựng, lỗi đó có thể do một số khía cạnh trong máy của bạn gây ra.
thiết lập thường có thể được sửa chữa nhanh chóng; những lần khác mặc dù vấn đề nằm ở
mã và chỉ có thể được sửa bởi nhà phát triển. Một cuộc kiểm tra chặt chẽ của
thông báo lỗi cùng với một số nghiên cứu trên internet thường sẽ cho bạn biết
đó là cái nào trong hai cái đó. Để thực hiện điều tra như vậy, hãy khởi động lại bản dựng
quá trình như thế này::

làm cho V=1

ZZ0000ZZ kích hoạt đầu ra chi tiết, có thể cần thiết để xem thực tế
lỗi. Để dễ phát hiện hơn, lệnh này cũng bỏ qua ZZ0001ZZ được sử dụng trước đó để sử dụng mọi lõi CPU trong hệ thống cho công việc -- nhưng
sự song song này cũng dẫn đến một số lộn xộn khi xảy ra lỗi.

Sau vài giây, quá trình xây dựng sẽ lại gặp lỗi. Bây giờ hãy thử
để tìm dòng quan trọng nhất mô tả vấn đề. Sau đó tìm kiếm trên mạng
phần quan trọng nhất và không chung chung của dòng đó (nói 4 đến 8 từ);
tránh hoặc xóa bất cứ thứ gì có vẻ dành riêng cho hệ thống từ xa, như tên người dùng của bạn
hoặc tên đường dẫn cục bộ như ZZ0000ZZ. Trước tiên hãy thử thường xuyên của bạn
công cụ tìm kiếm trên internet với chuỗi đó, sau đó tìm kiếm gửi thư nhân Linux
danh sách qua ZZ0001ZZ.

Điều này thường sẽ tìm thấy điều gì đó giải thích được điều gì sai; khá
thường thì một trong những cú truy cập cũng sẽ cung cấp giải pháp cho vấn đề của bạn. Nếu bạn
không tìm thấy bất cứ điều gì phù hợp với vấn đề của bạn, hãy thử lại từ một góc độ khác
bằng cách sửa đổi cụm từ tìm kiếm của bạn hoặc sử dụng một dòng khác từ thông báo lỗi.

Cuối cùng, hầu hết rắc rối bạn gặp phải đều có thể đã gặp phải và
đã được người khác báo cáo rồi. Điều đó bao gồm các vấn đề mà nguyên nhân không phải do bạn
hệ thống, nhưng nằm mã. Nếu bạn gặp phải một trong số đó, bạn có thể tìm thấy một
giải pháp (ví dụ: bản vá) hoặc cách giải quyết cho vấn đề của bạn.

Đóng gói kernel của bạn
~~~~~~~~~~~~~~~~~~~~~~

Hướng dẫn từng bước sử dụng mục tiêu tạo mặc định (ví dụ: 'bzImage' và
'mô-đun' trên x86) để xây dựng hình ảnh và các mô-đun hạt nhân của bạn, sau này
các bước của hướng dẫn sau đó cài đặt. Thay vào đó bạn cũng có thể trực tiếp xây dựng mọi thứ
và trực tiếp đóng gói nó bằng cách sử dụng một trong các mục tiêu sau:

* ZZ0000ZZ để tạo gói gỡ lỗi

* ZZ0000ZZ để tạo gói vòng/phút

* ZZ0000ZZ để tạo tarball nén bz2

Đây chỉ là một lựa chọn các mục tiêu có sẵn cho mục đích này, xem
ZZ0000ZZ cho người khác. Bạn cũng có thể sử dụng các mục tiêu này sau khi chạy
ZZ0001ZZ, vì họ sẽ tiếp thu mọi thứ đã được xây dựng.

Nếu bạn sử dụng các mục tiêu để tạo các gói gỡ lỗi hoặc vòng/phút, hãy bỏ qua
hướng dẫn từng bước về cách cài đặt và gỡ bỏ kernel của bạn;
thay vào đó hãy cài đặt và gỡ bỏ các gói bằng tiện ích gói dành cho định dạng
(ví dụ: dpkg và vòng/phút) hoặc tiện ích quản lý gói được xây dựng dựa trên chúng (apt,
năng khiếu, dnf/yum, zypper, ...). Xin lưu ý rằng các gói được tạo bằng cách sử dụng
hai mục tiêu này được thiết kế để hoạt động trên nhiều bản phân phối khác nhau bằng cách sử dụng
những định dạng đó, do đó đôi khi chúng sẽ hoạt động khác với định dạng của bạn
gói kernel của bản phân phối.

[ZZ0000ZZ]

.. _install:

Cài đặt hạt nhân của bạn
-------------------

ZZ0001ZZ [ZZ0000ZZ]

Những việc bạn cần làm sau khi thực hiện lệnh trong hướng dẫn từng bước
phụ thuộc vào sự tồn tại và triển khai ZZ0000ZZ
thực thi được. Nhiều bản phân phối Linux phổ thông cung cấp trình cài đặt hạt nhân như vậy ở dạng
ZZ0001ZZ thực hiện mọi thứ cần thiết, do đó không còn gì cho bạn
ngoại trừ việc khởi động lại. Nhưng một số bản phân phối có chứa hạt nhân cài đặt
chỉ là một phần của công việc -- và một số ít hoàn toàn thiếu nó và để lại toàn bộ công việc cho
bạn.

Nếu tìm thấy ZZ0000ZZ, hệ thống xây dựng của kernel sẽ ủy quyền
cài đặt thực tế hình ảnh hạt nhân của bạn và các tệp liên quan vào tệp thực thi này.
Trên hầu hết các bản phân phối Linux, nó sẽ lưu trữ hình ảnh dưới dạng '/boot/vmlinuz-
<tên phát hành kernel của bạn>' và đặt 'System.map-<bản phát hành kernel của bạn
name>' bên cạnh nó. Do đó hạt nhân của bạn sẽ được cài đặt song song với bất kỳ
những cái hiện có, trừ khi bạn đã có một cái có cùng tên phát hành.

Hạt nhân cài đặt trên nhiều bản phân phối sau đó sẽ tạo ra 'initramfs'
(thường còn được gọi là 'initrd'), phân phối hàng hóa dựa vào đó để khởi động;
do đó hãy đảm bảo giữ đúng thứ tự của cả hai mục tiêu được sử dụng theo từng bước
hướng dẫn, vì mọi thứ sẽ không ổn nếu bạn cài đặt hình ảnh hạt nhân trước
mô-đun. Thông thường, installkernel sẽ thêm kernel của bạn vào bootloader
cấu hình cũng vậy. Bạn phải đảm nhiệm một hoặc cả hai nhiệm vụ này
chính bạn, nếu hạt nhân cài đặt bản phân phối của bạn không xử lý được chúng.

Một số bản phân phối như Arch Linux và các phiên bản phái sinh của nó hoàn toàn thiếu
hạt nhân cài đặt có thể thực thi được. Trên đó chỉ cần cài đặt các mô-đun bằng kernel
xây dựng hệ thống rồi cài đặt hình ảnh và tệp System.map theo cách thủ công ::

sudo tạo module_install
     cài đặt sudo -m 0600 $(make -s image_name) /boot/vmlinuz-$(make -s kernelrelease)
     cài đặt sudo -m 0600 System.map /boot/System.map-$(make -s kernelrelease)

Nếu bản phân phối của bạn khởi động với sự trợ giúp của initramfs, bây giờ hãy tạo một bản phân phối cho
kernel của bạn bằng cách sử dụng các công cụ mà bản phân phối của bạn cung cấp cho quá trình này.
Sau đó thêm kernel của bạn vào cấu hình bootloader và khởi động lại.

[ZZ0000ZZ]

.. _another:

Một vòng nữa sau
-------------------

*Để sau này xây dựng một kernel khác bạn cần tương tự, nhưng đôi khi cần một chút
  các lệnh khác nhau* [ZZ0000ZZ]

Quá trình xây dựng các kernel sau này cũng tương tự, nhưng ở một số điểm hơi
khác nhau. Ví dụ: bạn không muốn sử dụng 'localmodconfig' để thành công
các bản dựng kernel, vì bạn đã tạo một cấu hình rút gọn mà bạn muốn
sử dụng từ bây giờ. Do đó thay vào đó chỉ cần sử dụng ZZ0000ZZ hoặc ZZ0001ZZ để
điều chỉnh cấu hình bản dựng của bạn theo nhu cầu của phiên bản kernel mà bạn đang có
sắp xây dựng.

Nếu bạn đã tạo một bản sao nông bằng git, hãy nhớ ZZ0000ZZ: bạn cần sử dụng một
Lệnh ZZ0001ZZ hơi khác một chút và khi chuyển sang dòng khác
cần thêm một nhánh từ xa bổ sung.

[ZZ0000ZZ]

.. _uninstall:

Gỡ cài đặt kernel sau
--------------------------

*Tất cả các phần của kernel đã cài đặt của bạn đều có thể được nhận dạng bằng tên phát hành và
  do đó dễ dàng loại bỏ sau này.* [ZZ0000ZZ]

Đừng lo lắng về việc cài đặt kernel theo cách thủ công và do đó bỏ qua
Hệ thống đóng gói của nhà phân phối sẽ làm hỏng hoàn toàn máy của bạn: tất cả các bộ phận của
kernel của bạn sau này dễ dàng được gỡ bỏ vì các tập tin chỉ được lưu trữ ở hai nơi và
thường được xác định bằng tên phát hành của kernel.

Một trong hai vị trí đó là thư mục trong /lib/modules/, nơi chứa các mô-đun
cho mỗi hạt nhân được cài đặt. Thư mục này được đặt tên theo bản phát hành của kernel
tên; do đó, để xóa tất cả các mô-đun cho một trong các hạt nhân của bạn, chỉ cần xóa nó
thư mục mô-đun trong /lib/modules/.

Vị trí còn lại là /boot/, nơi thường đặt từ một đến năm tệp
trong quá trình cài đặt kernel. Tất cả chúng thường chứa tên phát hành trong
tên tệp của chúng, nhưng có bao nhiêu tệp và tên của chúng phụ thuộc phần nào vào
hạt nhân cài đặt thực thi của bản phân phối (ZZ0000ZZ) và của nó
trình tạo initramfs. Trên một số bản phân phối, lệnh ZZ0001ZZ
được đề cập trong hướng dẫn từng bước sẽ xóa tất cả các tệp này cho bạn --
và mục nhập cho kernel của bạn trong cấu hình bootloader cùng một lúc,
quá. Đối với những người khác, bạn phải tự mình thực hiện các bước này. Sau đây
lệnh sẽ loại bỏ tương tác hai tệp chính của kernel bằng
tên phát hành '6.0.1-foobar'::

rm -i /boot/{System.map,vmlinuz}-6.0.1-foobar

Bây giờ hãy xóa các initramf thuộc về, thường được gọi là như thế này
ZZ0000ZZ hoặc ZZ0001ZZ.
Sau đó kiểm tra các tập tin khác trong /boot/ có '6.0.1-foobar' trong
đặt tên và xóa chúng đi. Bây giờ hãy gỡ bỏ kernel khỏi bộ nạp khởi động của bạn
cấu hình.

Lưu ý, hãy hết sức cẩn thận với các ký tự đại diện như “*” khi xóa file hoặc thư mục
đối với hạt nhân theo cách thủ công: bạn có thể vô tình xóa các tệp của hạt nhân 6.0.11
khi tất cả những gì bạn muốn là xóa 6.0 hoặc 6.0.1.

[ZZ0000ZZ]

.. _faq:

FAQ
===

Tại sao 'cách thực hiện' này không hoạt động trên hệ thống của tôi?
---------------------------------------------

Như đã nêu ban đầu, hướng dẫn này được thiết kế để bao gồm mọi thứ thông thường
cần [để xây dựng hạt nhân] trên các bản phân phối Linux chính thống chạy trên
phần cứng máy chủ hoặc PC hàng hóa'. Cách tiếp cận được phác thảo mặc dù điều này sẽ hoạt động
trên nhiều thiết lập khác nữa. Nhưng cố gắng bao quát mọi trường hợp sử dụng có thể trong một
hướng dẫn sẽ làm hỏng mục đích của nó, vì nếu không có sự tập trung như vậy bạn sẽ cần hàng tá hoặc
hàng trăm cấu trúc dọc theo dòng 'trong trường hợp bạn đang gặp <insert
máy hoặc bản phân phối>, lúc này bạn phải làm <cái này và cái kia>
<thay vào đó|bổ sung>'. Mỗi cách trong số đó sẽ làm cho văn bản dài hơn, nhiều hơn
phức tạp và khó theo dõi hơn.

Điều đó đang được nói: tất nhiên đây là một hành động cân bằng. Do đó, nếu bạn nghĩ một
trường hợp sử dụng bổ sung đáng được mô tả, hãy đề xuất nó cho những người duy trì trường hợp này
tài liệu, như ZZ0000ZZ.


..
   end-of-content
..
   This document is maintained by Thorsten Leemhuis <linux@leemhuis.info>. If
   you spot a typo or small mistake, feel free to let him know directly and
   he'll fix it. You are free to do the same in a mostly informal way if you
   want to contribute changes to the text -- but for copyright reasons please CC
   linux-doc@vger.kernel.org and 'sign-off' your contribution as
   Documentation/process/submitting-patches.rst explains in the section 'Sign
   your work - the Developer's Certificate of Origin'.
..
   This text is available under GPL-2.0+ or CC-BY-4.0, as stated at the top
   of the file. If you want to distribute this text under CC-BY-4.0 only,
   please use 'The Linux kernel development community' for author attribution
   and link this as source:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/admin-guide/quickly-build-trimmed-linux.rst
..
   Note: Only the content of this RST file as found in the Linux kernel sources
   is available under CC-BY-4.0, as versions of this text that were processed
   (for example by the kernel's build system) might contain content taken from
   files which use a more restrictive license.
