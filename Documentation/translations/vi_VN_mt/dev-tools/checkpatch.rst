.. SPDX-License-Identifier: GPL-2.0-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/checkpatch.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========
Bản vá kiểm tra
==========

Checkpatch (scripts/checkpatch.pl) là một tập lệnh perl dùng để kiểm tra các lỗi tầm thường
vi phạm phong cách trong các bản vá và tùy ý sửa chúng.  Bản vá có thể
cũng có thể chạy trên ngữ cảnh tệp và không có cây nhân.

Checkpatch không phải lúc nào cũng đúng. Phán quyết của bạn được ưu tiên hơn bản kiểm tra
tin nhắn.  Nếu mã của bạn có vẻ tốt hơn với các vi phạm thì có thể
tốt nhất là để yên.


Tùy chọn
=======

Phần này sẽ mô tả các tùy chọn mà bản vá kiểm tra có thể được chạy.

Cách sử dụng::

./scripts/checkpatch.pl [OPTION]... [FILE]...

Tùy chọn có sẵn:

- -q, --quiet

Bật chế độ im lặng.

- -v, --verbose
   Bật chế độ dài dòng.  Các mô tả kiểm tra chi tiết bổ sung được đưa ra
   để cung cấp thông tin về lý do tại sao thông báo cụ thể đó được hiển thị.

- --không có cây

Chạy checkpatch mà không có cây kernel.

- --không-đăng ký

Vô hiệu hóa kiểm tra dòng 'Đã đăng xuất bởi'.  Việc đăng xuất là một dòng đơn giản tại
   phần cuối của phần giải thích về bản vá, chứng nhận rằng bạn đã viết nó
   hoặc có quyền chuyển nó dưới dạng bản vá nguồn mở.

Ví dụ::

Người đăng ký: Nhà phát triển Random J <random@developer.example.org>

Việc đặt cờ này sẽ dừng thông báo về việc thiếu người đăng ký một cách hiệu quả
   dòng trong bối cảnh bản vá.

- --patch

Hãy coi FILE như một bản vá.  Đây là tùy chọn mặc định và không cần phải
   được chỉ định rõ ràng.

- --emacs

Đặt đầu ra thành định dạng cửa sổ biên dịch emacs.  Điều này cho phép người dùng emacs nhảy
   từ lỗi trong cửa sổ biên dịch trực tiếp đến dòng vi phạm trong
   vá.

- --ngắn gọn

Chỉ xuất ra một dòng cho mỗi báo cáo.

- --showfile

Hiển thị vị trí tệp khác thay vì vị trí tệp đầu vào.

- -g, --git

Hãy coi FILE là một cam kết duy nhất hoặc một phạm vi sửa đổi git.

Cam kết duy nhất với:

- <rev>
   - <rev>^
   - <rev>~n

Nhiều cam kết với:

- <rev1>..<rev2>
   - <rev1>...<rev2>
   - <rev>-<count>

- -f, --file

Hãy coi FILE như một tệp nguồn thông thường.  Tùy chọn này phải được sử dụng khi chạy
   kiểm tra các tập tin nguồn trong kernel.

- --chủ quan, --nghiêm ngặt

Cho phép kiểm tra chặt chẽ hơn trong bản kiểm tra.  Theo mặc định, các bài kiểm tra được phát ra dưới dạng CHECK
   không kích hoạt theo mặc định.  Sử dụng cờ này để kích hoạt các bài kiểm tra CHECK.

- --list-loại

Mỗi tin nhắn được phát ra bởi bản vá kiểm tra đều có TYPE liên quan.  Thêm cờ này
   để hiển thị tất cả các loại trong bản kiểm tra.

Lưu ý rằng khi cờ này hoạt động, bản vá không đọc FILE đầu vào,
   và không có tin nhắn nào được phát ra.  Chỉ có danh sách các loại trong bản kiểm tra được xuất ra.

- --loại TYPE(,TYPE2...)

Chỉ hiển thị tin nhắn với các loại nhất định.

Ví dụ::

./scripts/checkpatch.pl mypatch.patch --types EMAIL_SUBJECT,BRACES

- --bỏ qua TYPE(,TYPE2...)

Checkpatch sẽ không phát ra thông báo cho các loại được chỉ định.

Ví dụ::

./scripts/checkpatch.pl mypatch.patch --bỏ qua EMAIL_SUBJECT,BRACES

- --show-loại

Theo mặc định, bản vá kiểm tra không hiển thị loại liên quan đến tin nhắn.
   Đặt cờ này để hiển thị loại thông báo ở đầu ra.

- --max-line-length=n

Đặt độ dài dòng tối đa (mặc định là 100).  Nếu một dòng vượt quá quy định
   chiều dài, một thông báo LONG_LINE sẽ được phát ra.


Mức độ thông báo khác nhau đối với bối cảnh bản vá và tệp.  Đối với các bản vá,
   một WARNING được phát ra.  Trong khi CHECK nhẹ hơn được phát ra cho các tệp.  Vì vậy đối với
   ngữ cảnh tệp, cờ --strict cũng phải được bật.

- --min-conf-desc-length=n

Đặt độ dài mô tả tối thiểu của mục nhập Kconfig, nếu ngắn hơn, hãy cảnh báo.

- --tab-size=n

Đặt số lượng khoảng trắng cho tab (mặc định là 8).

- --root=PATH

PATH vào gốc cây hạt nhân.

Tùy chọn này phải được chỉ định khi gọi checkpatch từ bên ngoài
   gốc hạt nhân.

- --không tóm tắt

Loại bỏ phần tóm tắt trên mỗi tập tin.

- --gửi lại

Chỉ tạo báo cáo trong trường hợp Cảnh báo hoặc Lỗi.  Kiểm tra nhẹ hơn là
   bị loại trừ khỏi điều này.

- --tập tin tóm tắt

Bao gồm tên tập tin trong bản tóm tắt.

- --debug KEY=[0|1]

Bật/tắt gỡ lỗi KEY, trong đó KEY là một trong các 'giá trị', 'có thể',
   'type' và 'attr' (mặc định là tắt hoàn toàn).

- --sửa chữa

Đây là một tính năng EXPERIMENTAL.  Nếu tồn tại lỗi có thể sửa được, một tập tin
   <inputfile>.EXPERIMENTAL-checkpatch-fixes được tạo có
   tự động sửa chữa các lỗi có thể sửa được.

- --fix-tại chỗ

EXPERIMENTAL - Tương tự --fix nhưng tệp đầu vào bị ghi đè bằng các bản sửa lỗi.

LÀM NOT USE gắn cờ này trừ khi bạn hoàn toàn chắc chắn và có bản sao lưu
   tại chỗ.

- --ignore-Perl-phiên bản

Ghi đè kiểm tra phiên bản Perl.  Lỗi thời gian chạy có thể gặp phải sau
   bật cờ này nếu phiên bản Perl không đáp ứng mức tối thiểu được chỉ định.

- --codespell

Sử dụng từ điển codespell để kiểm tra lỗi chính tả.

- --codespellfile

Sử dụng tệp codespell được chỉ định.
   Mặc định là '/usr/share/codespell/dictionary.txt'.

- --typedefsfile

Đọc các loại bổ sung từ tập tin này.

- --color[=WHEN]

Sử dụng các màu 'luôn luôn', 'không bao giờ' hoặc chỉ khi đầu ra là thiết bị đầu cuối ('tự động').
   Mặc định là 'tự động'.

- --kconfig-prefix=WORD

Sử dụng WORD làm tiền tố cho ký hiệu Kconfig (mặc định là ZZ0000ZZ).

- -h, --help, --version

Hiển thị văn bản trợ giúp.

Cấp độ tin nhắn
==============

Tin nhắn trong bản kiểm tra được chia thành ba cấp độ. Các cấp độ tin nhắn
trong bản kiểm tra biểu thị mức độ nghiêm trọng của lỗi. Họ là:

-ERROR

Đây là mức độ nghiêm ngặt nhất.  Tin nhắn loại ERROR phải được thực hiện
   nghiêm túc vì chúng biểu thị những điều rất có thể sai.

-WARNING

Đây là cấp độ chặt chẽ hơn tiếp theo.  Tin nhắn loại WARNING yêu cầu
   xem xét cẩn thận hơn.  Nhưng nó nhẹ hơn ERROR.

-CHECK

Đây là mức độ nhẹ nhất.  Đây là những điều có thể cần phải suy nghĩ.

Loại mô tả
=================

Phần này chứa mô tả về tất cả các loại thông báo trong bản kiểm tra.

.. Types in this section are also parsed by checkpatch.
.. The types are grouped into subsections based on use.


Kiểu phân bổ
----------------

ZZ0000ZZ
    Đối số đầu tiên cho kcalloc hoặc kmalloc_array phải là
    số phần tử.  sizeof() làm đối số đầu tiên thường là
    sai.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Phong cách phân bổ là xấu.  Nói chung đối với gia đình
    các hàm phân bổ sử dụng sizeof() để lấy kích thước bộ nhớ,
    các cấu trúc như::

p = phân bổ(sizeof(struct foo), ...)

nên là::

p = cấp phát(sizeof(*p), ...)

Xem: ZZ0000ZZ

ZZ0000ZZ
    Thích kmalloc_array/kcalloc hơn kmalloc/kzalloc với
    kích thước của nhân lên.

Xem: ZZ0000ZZ


Cách sử dụng API
---------

ZZ0000ZZ
    Nên tránh định nghĩa cụ thể về kiến trúc ở mọi nơi
    có thể.

ZZ0000ZZ
    Bất cứ khi nào asm/file.h được bao gồm và linux/file.h tồn tại, một
    chuyển đổi có thể được thực hiện khi linux/file.h bao gồm asm/file.h.
    Tuy nhiên điều này không phải lúc nào cũng đúng (Xem signal.h).
    Loại thông báo này chỉ được phát ra để bao gồm từ Arch/.

ZZ0000ZZ
    Nên tránh hoàn toàn BUG() hoặc BUG_ON().
    Thay vào đó, hãy sử dụng WARN() và WARN_ON() và xử lý "không thể"
    tình trạng lỗi một cách duyên dáng nhất có thể.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Simple_strtol(), simple_strtoll(), simple_strtoul() và
    Các hàm simple_strtoll() bỏ qua lỗi tràn một cách rõ ràng, điều này
    có thể dẫn đến kết quả không mong đợi ở người gọi.  kstrtol() tương ứng,
    Các hàm kstrtoll(), kstrtoul() và kstrtoll() có xu hướng là
    những thay thế chính xác.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Việc sử dụng biểu mẫu __constant_<foo> không được khuyến khích cho các chức năng sau::

__constant_cpu_to_be[x]
      __constant_cpu_to_le[x]
      __constant_be[x]_to_cpu
      __constant_le[x]_to_cpu
      __constant_htons
      __hằng_ntohs

Việc sử dụng bất kỳ thứ nào trong số này bên ngoài include/uapi/ không được ưu tiên như sử dụng
    hàm không có __constant_ giống hệt nhau khi đối số là một
    hằng số.

Trong các hệ thống endian lớn, các macro như __constant_cpu_to_be32(x) và
    cpu_to_be32(x) mở rộng sang cùng một biểu thức ::

#define __constant_cpu_to_be32(x) ((__force __be32)(__u32)(x))
      #define __cpu_to_be32(x) ((__force __be32)(__u32)(x))

Trong các hệ thống endian nhỏ, các macro __constant_cpu_to_be32(x) và
    cpu_to_be32(x) mở rộng thành __constant_swab32 và __swab32.  __tăm bông32
    có kiểm tra __buildin_constant_p::

#define __swab32(x) \
        (__buildin_constant_p((__u32)(x)) ? \
        ___constant_swab32(x): \
        __fswab32(x))

Vì vậy, cuối cùng họ có một trường hợp đặc biệt cho hằng số.
    Tương tự là trường hợp với tất cả các macro trong danh sách.  Như vậy
    việc sử dụng các biểu mẫu __constant_... là dài dòng không cần thiết và
    không được ưu tiên bên ngoài include/uapi.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Đã phát hiện việc sử dụng RCU API không dùng nữa.  Nên thay thế
    các API RCU đầy hương vị cũ của các đối tác vanilla-RCU mới của họ.

Bạn có thể xem danh sách đầy đủ các API RCU có sẵn từ tài liệu kernel.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Tên hàm được sử dụng trong DEVICE_ATTR là không bình thường.
    Thông thường, các hàm lưu trữ và hiển thị được sử dụng với <attr>_store và
    <attr>_show, trong đó <attr> là biến thuộc tính được đặt tên của thiết bị.

Hãy xem xét các ví dụ sau::

DEVICE_ATTR tĩnh (loại, 0444, type_show, NULL);
      DEVICE_ATTR tĩnh (nguồn, 0644, power_show, power_store);

Tốt nhất nên đặt tên hàm theo mẫu trên.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Có thể sử dụng macro trợ giúp DEVICE_ATTR_RO(name) thay vì
    DEVICE_ATTR(tên, 0444, name_show, NULL);

Lưu ý rằng macro tự động thêm _show vào tên được đặt tên
    biến thuộc tính của thiết bị cho phương thức hiển thị.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Có thể sử dụng macro trợ giúp DEVICE_ATTR_RW(name) thay vì
    DEVICE_ATTR(tên, 0644, name_show, name_store);

Lưu ý rằng macro tự động thêm _show và _store vào
    biến thuộc tính được đặt tên của thiết bị cho các phương thức hiển thị và lưu trữ.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Có thể sử dụng macro trợ giúp DEVICE_AATR_WO(name) thay vì
    DEVICE_ATTR(tên, 0200, NULL, name_store);

Lưu ý rằng macro tự động thêm _store vào
    biến thuộc tính được đặt tên của thiết bị cho phương thức lưu trữ.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Cam kết d91bff3011cf ("proc/sysctl: thêm các biến dùng chung cho phạm vi
    check") đã thêm một số biến const được chia sẻ sẽ được sử dụng thay vì biến cục bộ
    sao chép trong mỗi tập tin nguồn.

Hãy xem xét việc thay thế giá trị kiểm tra phạm vi sysctl bằng giá trị được chia sẻ
    một trong include/linux/sysctl.h.  Sơ đồ chuyển đổi sau đây có thể
    được sử dụng::

&không -> SYSCTL_ZERO
      &một -> SYSCTL_ONE
      &int_max -> SYSCTL_INT_MAX

Nhìn thấy:

1. ZZ0000ZZ
      2. ZZ0001ZZ

ZZ0000ZZ
    ENOSYS có nghĩa là cuộc gọi hệ thống không tồn tại đã được gọi.
    Trước đó, nó đã được sử dụng sai cho những việc như thao tác không hợp lệ trên
    nếu không thì syscalls hợp lệ.  Điều này nên tránh trong mã mới.

Xem: ZZ0000ZZ

ZZ0000ZZ
    ENOTSUPP không phải là mã lỗi tiêu chuẩn và cần tránh trong các bản vá mới.
    EOPNOTSUPP nên được sử dụng thay thế.

Xem: ZZ0000ZZ

ZZ0000ZZ
    EXPORT_SYMBOL phải ngay lập tức theo biểu tượng để được xuất.

ZZ0000ZZ
    in_atomic() không dành cho việc sử dụng trình điều khiển nên bất kỳ việc sử dụng nào như vậy đều được báo cáo là ERROR.
    Ngoài ra in_atomic() thường được sử dụng để xác định xem có được phép ngủ hay không,
    nhưng nó không đáng tin cậy trong mô hình sử dụng này.  Vì vậy việc sử dụng nó là
    nản lòng một cách mạnh mẽ.

Tuy nhiên, in_atomic() vẫn phù hợp để sử dụng kernel lõi.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Lớp lockdep_no_validate đã được thêm vào như một biện pháp tạm thời để
    ngăn cảnh báo khi chuyển đổi thiết bị->sem sang thiết bị->mutex.
    Nó không nên được sử dụng cho bất kỳ mục đích nào khác.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Câu lệnh #include có đường dẫn không đúng định dạng.  Điều này đã xảy ra
    vì tác giả đã thêm dấu gạch chéo kép "//" vào tên đường dẫn
    vô tình.

ZZ0000ZZ
    Các chú thích lockdep_assert_held() nên được ưu tiên hơn
    xác nhận dựa trên spin_is_locked()

Xem: ZZ0000ZZ

ZZ0000ZZ
    Không có câu lệnh #include nào trong include/uapi nên sử dụng đường dẫn uapi/.

ZZ0000ZZ
    usleep_range() nên được ưu tiên hơn udelay(). Cách thích hợp của
    việc sử dụng usleep_range() được đề cập trong tài liệu kernel.


Bình luận
--------

ZZ0000ZZ
    Phong cách bình luận không chính xác.  Phong cách ưa thích cho đa
    nhận xét dòng là::

/*
       * Đây là phong cách ưa thích
       * cho nhận xét nhiều dòng.
       */

Xem: ZZ0000ZZ

ZZ0000ZZ
    Không nên sử dụng nhận xét một dòng kiểu C99 (//).
    Thay vào đó, hãy thích kiểu bình luận khối hơn.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Các ứng dụng của data_race() phải có chú thích để ghi lại
    lý do tại sao nó được coi là an toàn.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Những người bảo trì hạt nhân từ chối các phiên bản mới của đoạn bản mẫu GPL
    hướng dẫn mọi người viết thư tới FSF để lấy một bản sao của GPL, vì
    FSF đã di chuyển trong quá khứ và có thể làm như vậy một lần nữa.
    Vì vậy đừng viết những đoạn văn về việc viết thư cho Tổ chức Phần mềm Tự do.
    địa chỉ gửi thư.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Trong lịch sử, các chế độ RGMII PHY được chỉ định trong Cây thiết bị đã được
    được sử dụng không nhất quán, thường đề cập đến việc sử dụng độ trễ trên PHY
    bên thay vì mô tả bảng.

Các chế độ PHY "rgmii", "rgmii-rxid" và "rgmii-txid" yêu cầu đồng hồ
    tín hiệu bị trễ trên PCB; cấu hình bất thường này nên
    được mô tả trong một bình luận. Nếu không (có nghĩa là sự chậm trễ được thực hiện
    bên trong MAC hoặc PHY), "rgmii-id" là chế độ PHY chính xác.

Thông báo cam kết
--------------

ZZ0000ZZ
    Dòng ký tắt không đúng tiêu chuẩn
    do cộng đồng quy định.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Định dạng email ổn định không chính xác.
    Một số tùy chọn hợp lệ cho địa chỉ ổn định là::

1. ổn định@vger.kernel.org
      2. ổn định@kernel.org

Để thêm thông tin phiên bản, nên sử dụng kiểu nhận xét sau ::

stable@vger.kernel.org Thông tin # version

ZZ0000ZZ
    Các dòng nhật ký cam kết bắt đầu bằng '#' bị git bỏ qua vì
    ý kiến.  Để giải quyết vấn đề này, việc thêm một khoảng trắng
    trước dòng nhật ký là đủ.

ZZ0000ZZ
    Bản vá thiếu mô tả cam kết.  Tóm tắt
    nên thêm mô tả về những thay đổi được thực hiện bởi bản vá.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Việc đặt tên cho công cụ tìm ra vấn đề không hữu ích lắm trong
    dòng chủ đề.  Một dòng chủ đề tốt sẽ tóm tắt sự thay đổi
    bản vá mang lại.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Email của tác giả không khớp với email trong phần Người đăng ký:
    (các) dòng. Điều này đôi khi có thể xảy ra do cấu hình không đúng
    ứng dụng email.

Thông báo này được phát ra do bất kỳ lý do nào sau đây::

- Tên email không khớp.
      - Các địa chỉ email không khớp.
      - Địa chỉ email phụ không khớp.
      - Các nhận xét trong email không khớp.

ZZ0000ZZ
    Bản vá thiếu dòng Đã đăng ký.  Người đã ký xác nhận
    dòng này phải được thêm vào theo chứng chỉ của Nhà phát triển
    Nguồn gốc.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Tác giả của bản vá chưa ký tắt bản vá.  Đó là
    yêu cầu phải có một dòng đăng xuất đơn giản tại
    kết thúc phần giải thích của bản vá để biểu thị rằng tác giả đã
    đã viết nó hoặc có quyền chuyển nó đi dưới dạng mở
    bản vá nguồn.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Tránh có nội dung khác biệt trong thông báo cam kết.
    Điều này gây ra vấn đề khi người ta cố gắng áp dụng một tập tin chứa cả hai
    nhật ký thay đổi và khác biệt vì bản vá (1) cố gắng áp dụng khác biệt
    mà nó tìm thấy trong nhật ký thay đổi.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Để được gerrit chọn, phần chân trang của thông báo cam kết có thể
    có Id thay đổi như::

Id thay đổi: Ic8aaa0728a43936cd4c6e1ed590e01ba8f0fbf5b
      Người đăng ký: A. U. Thor <author@example.com>

Dòng Thay đổi-Id phải được loại bỏ trước khi gửi.

ZZ0000ZZ
    Cách thích hợp để tham chiếu id cam kết là:
    cam kết <12+ ký tự của sha1> ("<dòng tiêu đề>")

Một ví dụ có thể là::

Cam kết e21d2170f36602ae2708 ("video: xóa không cần thiết
      platform_set_drvdata()") đã loại bỏ những thứ không cần thiết
      platform_set_drvdata(), nhưng không sử dụng biến "dev",
      xóa nó.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Thẻ Fixes: không đúng định dạng hoặc không tuân theo quy ước cộng đồng.
    Điều này có thể xảy ra nếu thẻ được chia thành nhiều dòng (ví dụ: khi
    dán vào chương trình email có bật gói từ).

Xem: ZZ0000ZZ

ZZ0000ZZ
    Dấu phân cách cam kết là một dòng duy nhất có 3 dấu gạch ngang.
    Trận đấu biểu thức chính quy là '^---$'
    Các dòng bắt đầu bằng 3 dấu gạch ngang và có nhiều nội dung trên cùng một dòng
    có thể nhầm lẫn các công cụ áp dụng các bản vá.

Phong cách so sánh
----------------

ZZ0000ZZ
    Không sử dụng bài tập trong điều kiện if.
    Ví dụ::

if ((foo = bar(...)) < BAZ) {

nên viết là::

foo = thanh(...);
      nếu (foo < BAZ) {

ZZ0000ZZ
    So sánh A với đúng và sai được viết tốt hơn
    là A và !A.

Xem: ZZ0000ZZ

ZZ0000ZZ
    So sánh với NULL ở dạng (foo == NULL) hoặc (foo != NULL)
    tốt hơn nên viết là (!foo) và (foo).

ZZ0000ZZ
    So sánh với mã định danh hằng hoặc chữ hoa ở bên trái
    mặt của bài kiểm tra nên tránh.


Thụt lề và ngắt dòng
---------------------------

ZZ0000ZZ
    Mã thụt lề nên sử dụng tab thay vì dấu cách.
    Ngoài nhận xét, tài liệu và Kconfig,
    khoảng trắng không bao giờ được sử dụng để thụt lề.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Thụt lề có 6 tab trở lên thường biểu thị thụt lề quá mức
    mã.

Nên tái cấu trúc phần thụt đầu dòng quá mức của
    câu lệnh if/else/for/do/while/switch.

Xem: ZZ0000ZZ

ZZ0000ZZ
    switch phải ở cùng mức thụt lề với case.
    Ví dụ::

chuyển đổi (hậu tố) {
      trường hợp 'G':
      trường hợp 'g':
              bộ nhớ <<= 30;
              phá vỡ;
      trường hợp 'M':
      trường hợp 'm':
              bộ nhớ <<= 20;
              phá vỡ;
      trường hợp 'K':
      trường hợp 'k':
              bộ nhớ <<= 10;
              thất bại;
      mặc định:
              phá vỡ;
      }

Xem: ZZ0000ZZ

ZZ0000ZZ
    Dòng đã vượt quá độ dài tối đa được chỉ định.
    Để sử dụng độ dài dòng tối đa khác, tùy chọn --max-line-length=n
    có thể được thêm vào trong khi gọi bản kiểm tra.

Trước đó, độ dài dòng mặc định là 80 cột.  Cam kết bdc48fa11e46
    ("kiểu kiểm tra/kiểu mã hóa: không dùng cảnh báo 80 cột") đã tăng
    giới hạn ở 100 cột.  Đây cũng không phải là một giới hạn cứng và nó
    tốt nhất là ở trong phạm vi 80 cột bất cứ khi nào có thể.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Một chuỗi bắt đầu trước nhưng vượt quá độ dài dòng tối đa.
    Để sử dụng độ dài dòng tối đa khác, tùy chọn --max-line-length=n
    có thể được thêm vào trong khi gọi bản kiểm tra.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Một nhận xét bắt đầu trước nhưng vượt quá độ dài dòng tối đa.
    Để sử dụng độ dài dòng tối đa khác, tùy chọn --max-line-length=n
    có thể được thêm vào trong khi gọi bản kiểm tra.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Các chuỗi được trích dẫn xuất hiện dưới dạng tin nhắn trong không gian người dùng và có thể
    đã được xử lý, không nên chia thành nhiều dòng.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Một mã định danh hội thảo duy nhất trải dài trên nhiều dòng như ::

struct_identifier->thành viên [chỉ mục].
      thành viên = <foo>;

nói chung là khó theo dõi. Nó có thể dễ dàng dẫn đến lỗi chính tả và do đó làm cho
    mã dễ bị lỗi.

Nếu sửa lỗi hội thảo nhiều dòng dẫn đến cột 80
    vi phạm thì hãy viết lại mã theo cách đơn giản hơn hoặc nếu
    phần bắt đầu của mã định danh hội thảo giống nhau và được sử dụng tại
    nhiều nơi rồi lưu nó vào một biến tạm thời và sử dụng biến đó
    biến tạm thời chỉ ở tất cả các nơi. Ví dụ, nếu có
    hai số nhận dạng hội thảo::

member1->member2->member3.foo1;
      member1->member2->member3.foo2;

sau đó lưu trữ phần member1->member2->member3 trong một biến tạm thời.
    Nó không chỉ giúp tránh vi phạm cột 80 mà còn giảm
    kích thước chương trình bằng cách loại bỏ các tham chiếu không cần thiết.

Nhưng nếu không có phương pháp nào ở trên hoạt động thì hãy bỏ qua cột 80
    vi phạm vì việc đọc mã định danh hội thảo dễ dàng hơn nhiều
    trên một dòng duy nhất.

ZZ0000ZZ
    Các câu lệnh ở cuối (ví dụ sau bất kỳ điều kiện nào) phải là
    ở dòng tiếp theo.
    Các tuyên bố, chẳng hạn như::

nếu (x == y) phá vỡ;

nên là::

nếu (x == y)
              phá vỡ;


Macro, thuộc tính và ký hiệu
------------------------------

ZZ0000ZZ
    Nên ưu tiên macro ARRAY_SIZE(foo) hơn
    sizeof(foo)/sizeof(foo[0]) để tìm số phần tử trong một
    mảng.

Macro được xác định trong include/linux/array_size.h::

#define ARRAY_SIZE(x) (sizeof(x) / sizeof((x)[0]))

ZZ0000ZZ
    Nguyên mẫu hàm không cần phải được khai báo bên ngoài trong .h
    tập tin.  Nó được trình biên dịch giả định và không cần thiết.

ZZ0002ZZ
    Nên tránh các tên biểu tượng cục bộ có tiền tố ZZ0000ZZ,
    vì điều này có ý nghĩa đặc biệt đối với người lắp ráp; một mục ký hiệu sẽ
    không được đưa vào bảng ký hiệu.  Điều này có thể ngăn chặn ZZ0001ZZ
    từ việc tạo ra thông tin thư giãn chính xác.

Các ký hiệu có liên kết STB_LOCAL vẫn có thể được sử dụng và có tiền tố ZZ0000ZZ
    tên ký hiệu cục bộ nhìn chung vẫn có thể sử dụng được trong một hàm,
    nhưng không nên sử dụng tên ký hiệu cục bộ có tiền tố ZZ0001ZZ để biểu thị
    phần đầu hoặc phần cuối của vùng mã thông qua
    ZZ0002ZZ/ZZ0003ZZ

ZZ0000ZZ
    Định nghĩa như sau: 1 << <chữ số> có thể là BIT(chữ số).
    Macro BIT() được xác định thông qua include/linux/bits.h::

#define BIT(nr) (1UL << (nr))

ZZ0000ZZ
    Khi một biến được gắn thẻ với chú thích __read_mostly, đó là một biến
    tín hiệu tới trình biên dịch truy cập vào biến sẽ chủ yếu là
    đọc và hiếm khi (nhưng NOT không bao giờ) viết.

const __read_mostly không có ý nghĩa gì vì dữ liệu const đã có rồi
    chỉ đọc.  Do đó, nên xóa chú thích __read_mostly.

ZZ0000ZZ
    Nhìn chung, điều mong muốn là việc xây dựng cùng một mã nguồn với
    cùng một bộ công cụ có thể tái tạo được, tức là đầu ra luôn
    hoàn toàn giống nhau.

Hạt nhân ZZ0002ZZ sử dụng macro ZZ0000ZZ và ZZ0001ZZ,
    và kích hoạt cảnh báo nếu chúng được sử dụng vì chúng có thể dẫn đến
    các bản dựng không xác định.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Các mẫu ARCH_HAS_xyz và ARCH_HAVE_xyz sai.

Đối với các tính năng mang tính khái niệm lớn, hãy sử dụng ký hiệu Kconfig thay thế.  Và đối với
    những thứ nhỏ hơn nơi chúng tôi có chức năng dự phòng tương thích nhưng
    muốn các kiến trúc có thể ghi đè chúng bằng những kiến trúc được tối ưu hóa, chúng tôi
    nên sử dụng các hàm yếu (phù hợp với một số trường hợp) hoặc
    biểu tượng bảo vệ chúng phải giống với biểu tượng chúng ta sử dụng.

Xem: ZZ0000ZZ

ZZ0000ZZ
    macro do {} while(0) không được có dấu chấm phẩy ở cuối.

ZZ0000ZZ
    Định nghĩa init const nên sử dụng __initconst thay vì
    __initdata.

Tương tự, các định nghĩa init không có const yêu cầu một định nghĩa riêng
    sử dụng const.

ZZ0000ZZ
    Từ khóa nội tuyến phải nằm giữa lớp lưu trữ và loại.

Ví dụ: đoạn sau::

int tĩnh nội tuyến example_function(void)
      {
              ...
      }

nên là::

int nội tuyến tĩnh example_function(void)
      {
              ...
      }

ZZ0000ZZ
    Có thể sử dụng dấu phần trên các biến theo cách
    mà gcc không hiểu (hoặc ít nhất là không hiểu theo cách
    nhà phát triển dự định)::

cấu trúc tĩnh __initdata samsung_pll_clock exynos4_plls[nr_plls] = {

không đặt exynos4_plls trong phần .initdata. __initdata
    điểm đánh dấu có thể hầu như ở bất cứ đâu trên dòng, ngoại trừ ngay sau
    "cấu trúc". Vị trí ưa thích là trước dấu "=" nếu có
    một hoặc trước dấu ";" nếu không thì.

Xem: ZZ0000ZZ

ZZ0001ZZ
    Macro có nhiều câu lệnh phải được đặt trong một khung
    khối do - while.  Điều tương tự cũng xảy ra với macro
    bắt đầu bằng ZZ0000ZZ để tránh lỗi logic::

#define macrofun(a, b, c) \
        làm { \
                nếu (a == 5) \
                        do_this(b, c);          \
        } trong khi (0)

Xem: ZZ0000ZZ

ZZ0002ZZ
    Sử dụng từ khóa giả ZZ0000ZZ thay vì
    ZZ0001ZZ thích bình luận.

ZZ0000ZZ
    Định nghĩa macro không được kết thúc bằng dấu chấm phẩy. vĩ mô
    kiểu gọi phải nhất quán với các lệnh gọi hàm.
    Điều này có thể ngăn chặn mọi đường dẫn mã không mong muốn::

#define MAC làm_điều gì đó;

Nếu macro này được sử dụng trong câu lệnh if else, như::

nếu (một số_điều kiện)
              MAC;

khác
              làm_điều gì đó;

Khi đó sẽ xảy ra lỗi biên dịch, vì khi macro được
    được mở rộng có hai dấu chấm phẩy ở cuối, vì vậy nhánh else sẽ có
    mồ côi.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Nếu các macro giống chức năng không sử dụng tham số, điều đó có thể dẫn đến
    trong một cảnh báo xây dựng. Chúng tôi ủng hộ việc sử dụng các hàm nội tuyến tĩnh
    để thay thế các macro như vậy.
    Ví dụ: đối với macro như macro bên dưới::

Kiểm tra #define(a) do { } while (0)

sẽ có một cảnh báo như dưới đây::

WARNING: Đối số 'a' không được sử dụng trong macro giống hàm.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Đối với các macro đa câu lệnh, cần sử dụng lệnh do-while
    vòng lặp để tránh các đường dẫn mã không thể đoán trước. The do-while loop helps to
    nhóm nhiều câu lệnh thành một câu lệnh duy nhất sao cho
    macro giống như chức năng chỉ có thể được sử dụng làm chức năng.

Nhưng đối với các macro câu lệnh đơn, không cần thiết phải sử dụng
    vòng lặp do-while. Mặc dù mã đúng về mặt cú pháp nhưng việc sử dụng
    vòng lặp do-while là dư thừa. Vì vậy hãy loại bỏ vòng lặp do-while cho single
    macro tuyên bố.

ZZ0000ZZ
    Sử dụng các khai báo yếu như __attribute__((weak)) hoặc __weak
    có thể có lỗi liên kết ngoài ý muốn.  Tránh sử dụng chúng.


Hàm và Biến
-----------------------

ZZ0000ZZ
    Tránh các mã định danh CamelCase.

Xem: ZZ0000ZZ

ZZ0002ZZ
    Sử dụng ZZ0000ZZ thường có nghĩa là
    viết ZZ0001ZZ.

ZZ0000ZZ
    Sử dụng const nói chung là một ý tưởng hay.  Bản kiểm tra đọc
    một danh sách các cấu trúc được sử dụng thường xuyên luôn luôn hoặc
    hầu như luôn luôn không đổi.

Danh sách cấu trúc hiện có có thể được xem từ
    ZZ0000ZZ.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Tên hàm nhúng ít thích hợp hơn để sử dụng làm
    tái cấu trúc có thể gây ra việc đổi tên chức năng.  Ưu tiên sử dụng
    "%s", __func__ vào tên hàm được nhúng.

Lưu ý rằng điều này không hoạt động với tùy chọn bản kiểm tra -f (--file)
    vì nó phụ thuộc vào bối cảnh bản vá cung cấp tên hàm.

ZZ0000ZZ
    Cảnh báo này được phát ra do bất kỳ lý do nào sau đây:

1. Các đối số khai báo hàm không tuân theo
         tên định danh.  Ví dụ::

vô hiệu
           (thanh int, int baz)

Điều này cần được sửa thành::

void foo(int bar, int baz)

2. Một số đối số cho định nghĩa hàm không
         có tên định danh.  Ví dụ::

void foo(int)

Tất cả các đối số phải có tên định danh.

ZZ0000ZZ
    Khai báo hàm không có đối số như::

int foo()

nên là::

int foo(void)

ZZ0000ZZ
    Các biến toàn cục không nên được khởi tạo một cách rõ ràng để
    0 (hoặc NULL, sai, v.v.).  Trình biên dịch của bạn (hay đúng hơn là của bạn
    bộ nạp, chịu trách nhiệm loại bỏ các thông tin liên quan
    phần) tự động làm điều đó cho bạn.

ZZ0000ZZ
    Các biến tĩnh không nên được khởi tạo rõ ràng về 0.
    Trình biên dịch của bạn (hay đúng hơn là trình tải của bạn) sẽ tự động thực hiện
    nó dành cho bạn.

ZZ0000ZZ
    Nhiều phép gán trên một dòng khiến mã trở nên không cần thiết
    phức tạp. Vì vậy, trên một dòng, gán giá trị cho một biến
    mà thôi, điều này làm cho mã dễ đọc hơn và giúp tránh lỗi chính tả.

ZZ0000ZZ
    return không phải là một hàm và do đó không cần dấu ngoặc đơn::

trở lại (thanh);

có thể đơn giản là::

thanh quay lại;

ZZ0000ZZ
    Con trỏ có thuộc tính __free phải được khai báo tại nơi sử dụng
    và được khởi tạo (xem include/linux/cleanup.h). Trong trường hợp này
    các khai báo ở đầu quy tắc hàm có thể được nới lỏng. Không làm
    do đó có thể dẫn đến hành vi không xác định khi bộ nhớ được cấp phát (rác,
    trong trường hợp không được khởi tạo) vào con trỏ sẽ tự động được giải phóng khi
    con trỏ đi ra khỏi phạm vi.

Xem thêm: ZZ0000ZZ

Ví dụ::

gõ var __free(free_func);
      ... // var not used, but, in future someone might add a return here
var = malloc(var_size);
      ...

nên được khởi tạo là::

      ...
gõ var __free(free_func) = malloc(var_size);
      ...


Quyền
-----------

ZZ0000ZZ
    Các quyền được sử dụng trong DEVICE_ATTR là không bình thường.
    Thông thường chỉ có ba quyền được sử dụng - 0644 (RW), 0444 (RO)
    và 0200 (WO).

Xem: ZZ0000ZZ

ZZ0000ZZ
    Không có lý do gì để các tập tin nguồn có thể thực thi được.  Việc thực thi
    bit có thể được gỡ bỏ một cách an toàn.

ZZ0000ZZ
    Xuất các tệp sysfs/debugfs có thể ghi trên thế giới thường là một điều xấu.
    Khi được thực hiện một cách tùy tiện, chúng có thể gây ra các lỗi bảo mật nghiêm trọng.
    Trước đây, một số lỗ hổng debugfs dường như cho phép
    bất kỳ người dùng cục bộ nào có thể ghi các giá trị tùy ý vào các thanh ghi thiết bị - a
    tình huống mà từ đó ít điều tốt đẹp có thể được mong đợi sẽ xuất hiện.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Các bit quyền nên sử dụng quyền bát phân gồm 4 chữ số (như 0700 hoặc 0444).
    Tránh sử dụng bất kỳ cơ số nào khác như số thập phân.

ZZ0000ZZ
    Các bit cấp phép ở dạng bát phân dễ đọc hơn và dễ dàng hơn
    hiểu hơn so với các đối tác mang tính biểu tượng của chúng vì nhiều dòng lệnh
    công cụ sử dụng ký hiệu này. Các nhà phát triển hạt nhân có kinh nghiệm đã và đang sử dụng
    những quyền truy cập Unix truyền thống này trong nhiều thập kỷ và vì vậy họ tìm thấy nó
    dễ hiểu ký hiệu bát phân hơn các macro tượng trưng.
    Ví dụ: khó đọc S_IWUSR|S_IRUGO hơn 0644, điều này
    che khuất ý định của nhà phát triển hơn là làm rõ nó.

Xem: ZZ0000ZZ


Khoảng cách và dấu ngoặc
--------------------

ZZ0000ZZ
    Các toán tử gán không nên được viết ở đầu một
    dòng nhưng phải theo toán hạng ở dòng trước.

ZZ0000ZZ
    Vị trí của niềng răng không đúng về mặt phong cách.
    Cách tốt nhất là đặt dấu ngoặc mở cuối cùng trên dòng,
    và đặt dấu ngoặc đóng trước::

nếu (x đúng) {
              chúng tôi làm vậy
      }

Điều này áp dụng cho tất cả các khối không có chức năng.
    Tuy nhiên, có một trường hợp đặc biệt, đó là các hàm: chúng có
    opening brace at the beginning of the next line, thus::

hàm int(int x)
      {
              cơ thể của chức năng
      }

Xem: ZZ0000ZZ

ZZ0000ZZ
    Cấm khoảng trắng trước dấu ngoặc mở '['.
    Có một số trường hợp ngoại lệ:

1. Với loại ở bên trái::

int [] a;

2. Ở đầu dòng dành cho phần khởi tạo lát cắt::

[0...10] = 5,

3. Bên trong dấu ngoặc nhọn::

= { [0...10] = 5 }

ZZ0000ZZ
    Các phần tử được nối phải có khoảng trống ở giữa.
    Ví dụ::

printk(KERN_INFO"thanh");

nên là::

printk(KERN_INFO "thanh");

ZZ0002ZZ
    ZZ0000ZZ phải tuân theo khối đóng ZZ0001ZZ trên cùng một dòng.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Không gian theo chiều dọc bị lãng phí do số lượng dòng có hạn
    cửa sổ soạn thảo có thể hiển thị khi sử dụng nhiều dòng trống.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Dấu ngoặc mở phải tuân theo các định nghĩa hàm trên
    dòng tiếp theo.  Đối với bất kỳ khối phi chức năng nào, nó phải nằm trên cùng một dòng
    như là cấu trúc cuối cùng.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Khi sử dụng dữ liệu con trỏ hoặc hàm trả về kiểu con trỏ,
    việc sử dụng ưa thích của * nằm liền kề với tên dữ liệu hoặc tên hàm
    và không liền kề với tên loại.
    Ví dụ::

char *linux_banner;
      memparse dài không dấu (char ZZ0000ZZ*retptr);
      char *match_strdup(substring_t *);

Xem: ZZ0000ZZ

ZZ0000ZZ
    Kiểu khoảng trắng được sử dụng trong nguồn kernel được mô tả trong tài liệu kernel.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Khoảng trắng ở cuối phải luôn được loại bỏ.
    Một số trình soạn thảo đánh dấu khoảng trắng ở cuối và gây ra hiện tượng trực quan
    phiền nhiễu khi chỉnh sửa tập tin.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Không cần phải có dấu ngoặc đơn trong các trường hợp sau:

1. Con trỏ hàm sử dụng ::

(foo->bar)();

có thể là::

foo->bar();

2. So sánh trong if::

if ((foo->bar) && (foo->baz))
          nếu ((foo == thanh))

có thể là::

if (foo->bar && foo->baz)
          nếu (foo == thanh)

3. Giá trị địa chỉ/lệnh hủy đăng ký duy nhất::

&(foo->bar)
          *(foo->bar)

có thể là::

&foo->thanh
          *foo->thanh

ZZ0000ZZ
    while nên theo dấu ngoặc đóng trên cùng một dòng ::

LÀM {
              ...
} trong khi(cái gì đó);

Xem: ZZ0000ZZ


Người khác
------

ZZ0000ZZ
    Biểu tượng Kconfig phải có văn bản trợ giúp mô tả đầy đủ
    nó.

ZZ0000ZZ
    Bản vá dường như bị hỏng hoặc các dòng bị ngắt quãng.
    Vui lòng tạo lại tệp vá trước khi gửi cho người bảo trì.

ZZ0000ZZ
    Kể từ khi linux chuyển sang git, các điểm đánh dấu CVS không còn được sử dụng nữa.
    Vì vậy, các từ khóa kiểu CVS ($Id$, $Revision$, $Log$) không nên
    đã thêm vào.

ZZ0000ZZ
    trường hợp mặc định của switch đôi khi được viết là "default:;".  Điều này có thể
    khiến các trường hợp mới được thêm vào dưới mức mặc định bị lỗi.

Một "nghỉ;" nên được thêm vào sau câu lệnh mặc định trống để tránh
    sự suy giảm không mong muốn.

ZZ0000ZZ
    Đối với các bản vá có định dạng DOS, có thêm ký hiệu ^M ở cuối
    dòng.  Những điều này nên được loại bỏ.

ZZ0000ZZ
    Các liên kết DT được chuyển sang định dạng dựa trên lược đồ json thay vì
    văn bản dạng tự do.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Các ràng buộc của Devicetree phải là bản vá riêng của chúng.  Điều này là do
    các ràng buộc độc lập về mặt logic với việc triển khai trình điều khiển,
    họ có một người bảo trì khác (mặc dù họ thường xuyên
    được áp dụng thông qua cùng một cây) và nó tạo ra một lịch sử rõ ràng hơn trong
    Cây chỉ DT được tạo bằng git-filter-branch.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Nhúng đường dẫn tên tệp đầy đủ vào trong tệp không đặc biệt
    hữu ích vì đường dẫn thường xuyên bị di chuyển xung quanh và trở nên không chính xác.

ZZ0000ZZ
    Bất cứ khi nào tệp được thêm, di chuyển hoặc xóa, tệp MAINTAINERS
    các mẫu có thể không đồng bộ hoặc lỗi thời.

Vì vậy MAINTAINERS có thể cần cập nhật trong những trường hợp này.

ZZ0000ZZ
    Việc sử dụng bộ nhớ có vẻ không chính xác.  Điều này có thể được gây ra do
    các thông số có thứ tự sai.  Vui lòng kiểm tra lại việc sử dụng.

ZZ0000ZZ
    Tệp vá dường như không ở định dạng khác biệt thống nhất.  làm ơn
    tạo lại tệp vá trước khi gửi nó cho người bảo trì.

ZZ0000ZZ
    Phát hiện văn bản giữ chỗ chưa được xử lý còn sót lại trong thư xin việc hoặc tiêu đề/nhật ký cam kết.
    Trình giữ chỗ phổ biến bao gồm các dòng như::

ZZ0002ZZ
      ZZ0003ZZ

Chúng thường đến từ các mẫu được tạo tự động. Thay thế chúng bằng một từ thích hợp
    chủ đề và mô tả trước khi gửi.

ZZ0000ZZ
    Tiền tố 0x với đầu ra thập phân bị lỗi và cần được sửa.

ZZ0000ZZ
    Tệp nguồn bị thiếu hoặc có thẻ nhận dạng SPDX không đúng.
    Nhân Linux yêu cầu mã định danh SPDX chính xác trong tất cả các tệp nguồn,
    và nó được ghi lại kỹ lưỡng trong tài liệu kernel.

Xem: ZZ0000ZZ

ZZ0000ZZ
    Một số từ có thể đã bị sai chính tả.  Hãy xem xét việc xem xét chúng.