.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/landlock.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright © 2017-2020 Mickaël Salaün <mic@digikod.net>
.. Copyright © 2019-2020 ANSSI
.. Copyright © 2021-2022 Microsoft Corporation

===============================================
Landlock: kiểm soát truy cập không có đặc quyền
===============================================

:Tác giả: Mickaël Salaün
:Ngày: Tháng 3 năm 2026

Mục tiêu của Landlock là cho phép hạn chế các quyền xung quanh (ví dụ: toàn cầu
truy cập hệ thống tập tin hoặc mạng) cho một tập hợp các quy trình.  Bởi vì đất liền
là một LSM có thể xếp chồng lên nhau, nó có thể tạo các hộp cát bảo mật an toàn như
các lớp bảo mật mới bên cạnh các biện pháp kiểm soát truy cập trên toàn hệ thống hiện có.
Loại hộp cát này được kỳ vọng sẽ giúp giảm thiểu tác động bảo mật của lỗi hoặc
hành vi bất ngờ/có hại trong các ứng dụng không gian người dùng.  Landlock trao quyền
bất kỳ quy trình nào, kể cả những quy trình không có đặc quyền, để tự hạn chế một cách an toàn.

Chúng ta có thể nhanh chóng đảm bảo rằng Landlock được kích hoạt trong hệ thống đang chạy bằng cách
đang tìm kiếm "landlock: Up and Running" trong nhật ký kernel (với quyền root):
ZZ0002ZZ.
Các nhà phát triển cũng có thể dễ dàng kiểm tra sự hỗ trợ của Landlock bằng một
ZZ0000ZZ.
Nếu Landlock hiện không được hỗ trợ, chúng ta cần phải
ZZ0001ZZ.

quy tắc đất liền
================

Quy tắc Landlock mô tả một hành động trên một đối tượng mà tiến trình dự định thực hiện.
biểu diễn.  Một bộ quy tắc được tổng hợp thành một bộ quy tắc, sau đó có thể hạn chế
chủ đề thực thi nó và những đứa con tương lai của nó.

Hai loại quy tắc hiện có là:

Quy tắc hệ thống tập tin
    Đối với các quy tắc này, đối tượng là hệ thống phân cấp tệp,
    và các hành động hệ thống tập tin liên quan được xác định bằng
    ZZ0000ZZ.

Quy tắc mạng (kể từ ABI v4)
    Đối với các quy tắc này, đối tượng là cổng TCP,
    và các hành động liên quan được xác định bằng ZZ0000ZZ.

Xác định và thực thi chính sách bảo mật
----------------------------------------

Trước tiên chúng ta cần xác định bộ quy tắc sẽ chứa các quy tắc của chúng ta.

Trong ví dụ này, bộ quy tắc sẽ chứa các quy tắc chỉ cho phép hệ thống tập tin
đọc hành động và thiết lập kết nối TCP cụ thể. Ghi hệ thống tập tin
các hành động và các hành động TCP khác sẽ bị từ chối.

Sau đó, bộ quy tắc cần xử lý cả hai loại hành động này.  Đây là
cần thiết cho khả năng tương thích ngược và xuôi (tức là kernel và người dùng
không gian có thể không biết các hạn chế được hỗ trợ của nhau), do đó cần
phải rõ ràng về quyền truy cập bị từ chối theo mặc định.

.. code-block:: c

    struct landlock_ruleset_attr ruleset_attr = {
        .handled_access_fs =
            LANDLOCK_ACCESS_FS_EXECUTE |
            LANDLOCK_ACCESS_FS_WRITE_FILE |
            LANDLOCK_ACCESS_FS_READ_FILE |
            LANDLOCK_ACCESS_FS_READ_DIR |
            LANDLOCK_ACCESS_FS_REMOVE_DIR |
            LANDLOCK_ACCESS_FS_REMOVE_FILE |
            LANDLOCK_ACCESS_FS_MAKE_CHAR |
            LANDLOCK_ACCESS_FS_MAKE_DIR |
            LANDLOCK_ACCESS_FS_MAKE_REG |
            LANDLOCK_ACCESS_FS_MAKE_SOCK |
            LANDLOCK_ACCESS_FS_MAKE_FIFO |
            LANDLOCK_ACCESS_FS_MAKE_BLOCK |
            LANDLOCK_ACCESS_FS_MAKE_SYM |
            LANDLOCK_ACCESS_FS_REFER |
            LANDLOCK_ACCESS_FS_TRUNCATE |
            LANDLOCK_ACCESS_FS_IOCTL_DEV |
            LANDLOCK_ACCESS_FS_RESOLVE_UNIX,
        .handled_access_net =
            LANDLOCK_ACCESS_NET_BIND_TCP |
            LANDLOCK_ACCESS_NET_CONNECT_TCP,
        .scoped =
            LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET |
            LANDLOCK_SCOPE_SIGNAL,
    };

Bởi vì chúng ta có thể không biết ứng dụng sẽ được thực thi phiên bản kernel nào
trên, sẽ an toàn hơn nếu thực hiện theo phương pháp bảo mật nỗ lực tối đa.  Thật vậy, chúng tôi
nên cố gắng bảo vệ người dùng nhiều nhất có thể, bất kể họ là ai
sử dụng.

Để tương thích với các phiên bản Linux cũ hơn, chúng tôi phát hiện Landlock ABI có sẵn
phiên bản và chỉ sử dụng tập hợp con quyền truy cập có sẵn:

.. code-block:: c

    int abi;

    abi = landlock_create_ruleset(NULL, 0, LANDLOCK_CREATE_RULESET_VERSION);
    if (abi < 0) {
        /* Degrades gracefully if Landlock is not handled. */
        perror("The running kernel does not enable to use Landlock");
        return 0;
    }
    switch (abi) {
    case 1:
        /* Removes LANDLOCK_ACCESS_FS_REFER for ABI < 2 */
        ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_REFER;
        __attribute__((fallthrough));
    case 2:
        /* Removes LANDLOCK_ACCESS_FS_TRUNCATE for ABI < 3 */
        ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_TRUNCATE;
        __attribute__((fallthrough));
    case 3:
        /* Removes network support for ABI < 4 */
        ruleset_attr.handled_access_net &=
            ~(LANDLOCK_ACCESS_NET_BIND_TCP |
              LANDLOCK_ACCESS_NET_CONNECT_TCP);
        __attribute__((fallthrough));
    case 4:
        /* Removes LANDLOCK_ACCESS_FS_IOCTL_DEV for ABI < 5 */
        ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_IOCTL_DEV;
        __attribute__((fallthrough));
    case 5:
        /* Removes LANDLOCK_SCOPE_* for ABI < 6 */
        ruleset_attr.scoped &= ~(LANDLOCK_SCOPE_ABSTRACT_UNIX_SOCKET |
                                 LANDLOCK_SCOPE_SIGNAL);
        __attribute__((fallthrough));
    case 6 ... 8:
        /* Removes LANDLOCK_ACCESS_FS_RESOLVE_UNIX for ABI < 9 */
        ruleset_attr.handled_access_fs &= ~LANDLOCK_ACCESS_FS_RESOLVE_UNIX;
    }

Điều này cho phép tạo ra một bộ quy tắc bao gồm các quy tắc của chúng tôi.

.. code-block:: c

    int ruleset_fd;

    ruleset_fd = landlock_create_ruleset(&ruleset_attr, sizeof(ruleset_attr), 0);
    if (ruleset_fd < 0) {
        perror("Failed to create a ruleset");
        return 1;
    }

Bây giờ chúng ta có thể thêm quy tắc mới vào bộ quy tắc này nhờ vào tệp được trả về
mô tả đề cập đến bộ quy tắc này.  Quy tắc sẽ cho phép đọc và
thực thi hệ thống phân cấp tệp ZZ0000ZZ.  Nếu không có quy tắc khác, hãy viết hành động
sau đó sẽ bị từ chối bởi tập quy tắc.  Để thêm ZZ0001ZZ vào bộ quy tắc, chúng tôi mở
nó với cờ ZZ0002ZZ và điền vào &struct landlock_path_beneath_attr bằng
bộ mô tả tập tin này.

.. code-block:: c

    int err;
    struct landlock_path_beneath_attr path_beneath = {
        .allowed_access =
            LANDLOCK_ACCESS_FS_EXECUTE |
            LANDLOCK_ACCESS_FS_READ_FILE |
            LANDLOCK_ACCESS_FS_READ_DIR,
    };

    path_beneath.parent_fd = open("/usr", O_PATH | O_CLOEXEC);
    if (path_beneath.parent_fd < 0) {
        perror("Failed to open file");
        close(ruleset_fd);
        return 1;
    }
    err = landlock_add_rule(ruleset_fd, LANDLOCK_RULE_PATH_BENEATH,
                            &path_beneath, 0);
    close(path_beneath.parent_fd);
    if (err) {
        perror("Failed to update ruleset");
        close(ruleset_fd);
        return 1;
    }

Cũng có thể được yêu cầu tạo các quy tắc theo logic tương tự như đã giải thích
để tạo bộ quy tắc, bằng cách lọc quyền truy cập theo Landlock
Phiên bản ABI.  Trong ví dụ này, điều này là không bắt buộc vì tất cả các yêu cầu
Quyền ZZ0000ZZ đã có sẵn trong ABI 1.

Để kiểm soát truy cập mạng, chúng ta có thể thêm một bộ quy tắc cho phép sử dụng cổng
số cho một hành động cụ thể: kết nối HTTPS.

.. code-block:: c

    struct landlock_net_port_attr net_port = {
        .allowed_access = LANDLOCK_ACCESS_NET_CONNECT_TCP,
        .port = 443,
    };

    err = landlock_add_rule(ruleset_fd, LANDLOCK_RULE_NET_PORT,
                            &net_port, 0);

Khi chuyển một đối số ZZ0000ZZ khác 0 tới ZZ0001ZZ, một
cần kiểm tra khả năng tương thích ngược tương tự cho các cờ hạn chế
(xem tài liệu sys_landlock_restrict_self() để biết các cờ có sẵn):

.. code-block:: c

    __u32 restrict_flags =
        LANDLOCK_RESTRICT_SELF_LOG_NEW_EXEC_ON |
        LANDLOCK_RESTRICT_SELF_TSYNC;
    switch (abi) {
    case 1 ... 6:
        /* Removes logging flags for ABI < 7 */
        restrict_flags &= ~(LANDLOCK_RESTRICT_SELF_LOG_SAME_EXEC_OFF |
                            LANDLOCK_RESTRICT_SELF_LOG_NEW_EXEC_ON |
                            LANDLOCK_RESTRICT_SELF_LOG_SUBDOMAINS_OFF);
        __attribute__((fallthrough));
    case 7:
        /*
         * Removes multithreaded enforcement flag for ABI < 8
         *
         * WARNING: Without this flag, calling landlock_restrict_self(2) is
         * only equivalent if the calling process is single-threaded. Below
         * ABI v8 (and as of ABI v8, when not using this flag), a Landlock
         * policy would only be enforced for the calling thread and its
         * children (and not for all threads, including parents and siblings).
         */
        restrict_flags &= ~LANDLOCK_RESTRICT_SELF_TSYNC;
    }

Bước tiếp theo là hạn chế luồng hiện tại có được nhiều đặc quyền hơn
(ví dụ: thông qua hệ nhị phân SUID).  Bây giờ chúng ta có một bộ quy tắc với quy tắc đầu tiên
cho phép đọc và thực thi quyền truy cập vào ZZ0000ZZ trong khi từ chối tất cả các quyền được xử lý khác
quyền truy cập vào hệ thống tệp và quy tắc thứ hai cho phép kết nối HTTPS.

.. code-block:: c

    if (prctl(PR_SET_NO_NEW_PRIVS, 1, 0, 0, 0)) {
        perror("Failed to restrict privileges");
        close(ruleset_fd);
        return 1;
    }

Chuỗi hiện tại đã sẵn sàng để tự sandbox với bộ quy tắc.

.. code-block:: c

    if (landlock_restrict_self(ruleset_fd, restrict_flags)) {
        perror("Failed to enforce ruleset");
        close(ruleset_fd);
        return 1;
    }
    close(ruleset_fd);

Nếu cuộc gọi hệ thống ZZ0000ZZ thành công, luồng hiện tại là
hiện bị hạn chế và chính sách này sẽ được thực thi trên tất cả các chính sách được tạo sau đó
trẻ em cũng vậy.  Một khi một tuyến đã nằm trong đất liền thì không có cách nào để loại bỏ nó
chính sách bảo mật; chỉ cho phép thêm nhiều hạn chế hơn.  Những chủ đề này là
hiện thuộc miền Landlock mới, là sự hợp nhất của miền mẹ (nếu có)
với bộ quy tắc mới.

Mã làm việc đầy đủ có thể được tìm thấy trong ZZ0000ZZ.

Thực hành tốt
--------------

Nên đặt quyền truy cập vào phân cấp tệp càng nhiều càng tốt
có thể.  Chẳng hạn, tốt hơn là có thể có ZZ0000ZZ làm
phân cấp chỉ đọc và ZZ0001ZZ là phân cấp đọc-ghi, so với
ZZ0002ZZ là hệ thống phân cấp chỉ đọc và ZZ0003ZZ là hệ thống phân cấp đọc-ghi.
Việc làm theo cách thực hành tốt này sẽ dẫn đến các hệ thống phân cấp tự cung tự cấp, không
phụ thuộc vào vị trí của họ (tức là thư mục mẹ).  Điều này đặc biệt
có liên quan khi chúng tôi muốn cho phép liên kết hoặc đổi tên.  Thật vậy, có sự nhất quán
quyền truy cập cho mỗi thư mục cho phép thay đổi vị trí của các thư mục đó
mà không cần dựa vào quyền truy cập thư mục đích (ngoại trừ những quyền
được yêu cầu cho thao tác này, xem ZZ0004ZZ
tài liệu).

Việc có hệ thống phân cấp tự chủ cũng giúp thắt chặt quyền truy cập cần thiết
quyền đối với tập hợp dữ liệu tối thiểu.  Điều này cũng giúp tránh các thư mục hố sụt,
tức là các thư mục nơi dữ liệu có thể được liên kết đến nhưng không được liên kết từ đó.  Tuy nhiên,
điều này phụ thuộc vào cách tổ chức dữ liệu và có thể không được nhà phát triển kiểm soát.
Trong trường hợp này, cấp quyền truy cập đọc-ghi cho ZZ0000ZZ, thay vì chỉ ghi
truy cập, có khả năng sẽ cho phép di chuyển ZZ0001ZZ sang một thư mục không thể đọc được
và vẫn giữ được khả năng liệt kê nội dung của ZZ0002ZZ.

Các lớp quyền truy cập đường dẫn tệp
------------------------------------

Mỗi khi một luồng thực thi một bộ quy tắc trên chính nó, nó sẽ cập nhật miền Landlock của nó
với một lớp chính sách mới.  Chính sách bổ sung này được xếp chồng lên nhau với bất kỳ
các bộ quy tắc khác có khả năng đã hạn chế chuỗi này.  Một chủ đề hộp cát
sau đó có thể thêm nhiều ràng buộc hơn vào chính nó một cách an toàn bằng bộ quy tắc được thực thi mới.

Một lớp chính sách cấp quyền truy cập vào đường dẫn tệp nếu ít nhất một trong các quy tắc của nó
gặp trên đường dẫn sẽ cấp quyền truy cập.  Một chủ đề hộp cát chỉ có thể truy cập
một đường dẫn tệp nếu tất cả các lớp chính sách được thi hành của nó cấp quyền truy cập cũng như tất cả
các điều khiển truy cập hệ thống khác (ví dụ: hệ thống tệp DAC, các chính sách LSM khác,
v.v.).

Gắn kết và OverlayFS
-------------------------

Landlock cho phép hạn chế quyền truy cập vào hệ thống phân cấp tệp, có nghĩa là những
quyền truy cập có thể được phổ biến bằng các liên kết gắn kết (cf.
Tài liệu/hệ thống tập tin/sharedsubtree.rst) nhưng không có
Tài liệu/hệ thống tập tin/overlayfs.rst.

Gắn kết liên kết phản chiếu hệ thống phân cấp tệp nguồn tới đích.  Điểm đến
hệ thống phân cấp sau đó bao gồm các tệp giống hệt nhau, trên đó các quy tắc Landlock có thể
được ràng buộc thông qua đường dẫn nguồn hoặc đường dẫn đích.  Những quy định này hạn chế
truy cập khi chúng gặp phải trên một con đường, điều đó có nghĩa là chúng có thể hạn chế
truy cập vào nhiều hệ thống phân cấp tệp cùng một lúc, cho dù các hệ thống phân cấp này
có phải là kết quả của việc gắn kết liên kết hay không.

Điểm gắn kết OverlayFS bao gồm các lớp trên và dưới.  Những lớp này được
được kết hợp trong một thư mục hợp nhất và thư mục đã hợp nhất đó sẽ có sẵn tại
điểm gắn kết.  Hệ thống phân cấp hợp nhất này có thể bao gồm các tệp từ cấp trên và
các lớp thấp hơn, nhưng những sửa đổi được thực hiện trên hệ thống phân cấp hợp nhất chỉ phản ánh
ở lớp trên.  Từ quan điểm chính sách Landlock, tất cả các lớp OverlayFS
và các hệ thống phân cấp hợp nhất là độc lập và mỗi hệ thống chứa tập hợp các tệp riêng của chúng
và các thư mục, khác với các liên kết gắn kết.  Một chính sách hạn chế một
Lớp OverlayFS sẽ không hạn chế hệ thống phân cấp được hợp nhất và ngược lại.
Khi đó, người dùng Landlock chỉ nên nghĩ đến hệ thống phân cấp tệp mà họ muốn cho phép
truy cập vào, bất kể hệ thống tập tin cơ bản.

Kế thừa
-----------

Mỗi luồng mới tạo ra từ ZZ0000ZZ đều kế thừa miền Landlock
hạn chế từ cha mẹ của nó.  Điều này tương tự như kế thừa seccomp (cf.
Documentation/userspace-api/seccomp_filter.rst) hoặc bất kỳ LSM nào khác liên quan đến
ZZ0001ZZ của nhiệm vụ.  Ví dụ: luồng của một tiến trình có thể áp dụng
Landlock quy định chính nó, nhưng chúng sẽ không được tự động áp dụng cho các vùng khác
các luồng anh chị em (không giống như các thay đổi thông tin xác thực của luồng POSIX, cf.
ZZ0002ZZ).

Khi một luồng tự tạo hộp cát, chúng tôi đảm bảo rằng bảo mật liên quan
chính sách sẽ tiếp tục được thực thi trên tất cả các chuỗi con của chuỗi này.  Điều này cho phép
tạo ra các chính sách bảo mật độc lập và mô-đun cho mỗi ứng dụng, điều này sẽ
tự động được sáng tác giữa chúng theo thời gian chạy gốc của chúng
chính sách.

Hạn chế Ptrace
-------------------

Một tiến trình có hộp cát có ít đặc quyền hơn một tiến trình không có hộp cát và phải
sau đó phải chịu những hạn chế bổ sung khi thao tác với một quy trình khác.
Được phép sử dụng ZZ0000ZZ và các tòa nhà có liên quan trên mục tiêu
quy trình, quy trình được đóng hộp cát phải có tập hợp siêu dữ liệu của quy trình đích
quyền truy cập, có nghĩa là người theo dõi phải thuộc miền phụ của người theo dõi.

phạm vi IPC
-----------

Tương tự như ZZ0000ZZ tiềm ẩn, chúng tôi có thể muốn hạn chế hơn nữa
tương tác giữa các hộp cát.  Do đó, tại thời điểm tạo tập quy tắc, mỗi
Miền Landlock có thể hạn chế phạm vi cho một số hoạt động nhất định, do đó những hoạt động này
hoạt động chỉ có thể tiếp cận với các quy trình trong cùng một miền Landlock hoặc trong
một miền Landlock lồng nhau ("phạm vi").

Các hoạt động có thể được phạm vi là:

ZZ0000ZZ
    Điều này hạn chế việc gửi tín hiệu đến các tiến trình đích chạy trong
    cùng hoặc một miền Landlock lồng nhau.

ZZ0002ZZ
    Điều này giới hạn tập hợp các ổ cắm ZZ0000ZZ trừu tượng mà chúng ta có thể
    ZZ0001ZZ tới các địa chỉ ổ cắm được tạo bởi một quy trình trong
    cùng hoặc một miền Landlock lồng nhau.

ZZ0000ZZ trên ổ cắm datagram không được kết nối được xử lý như thể
    nó đang thực hiện một ZZ0001ZZ tiềm ẩn và sẽ bị chặn nếu
    đầu từ xa không xuất phát từ cùng một miền Landlock hoặc một miền Landlock lồng nhau.

ZZ0000ZZ trên ổ cắm đã được kết nối trước đó sẽ không
    bị hạn chế.  Điều này hoạt động cho cả datagram và ổ cắm luồng.

Phạm vi IPC không hỗ trợ ngoại lệ thông qua ZZ0000ZZ.
Nếu một hoạt động nằm trong phạm vi một miền thì không thể thêm quy tắc nào để cho phép truy cập
tới các tài nguyên hoặc quy trình nằm ngoài phạm vi.

Cắt bớt tập tin
----------------

Các hoạt động được bao phủ bởi ZZ0000ZZ và
ZZ0001ZZ đều thay đổi nội dung của một tập tin và đôi khi
chồng chéo theo những cách không trực quan.  Chúng tôi đặc biệt khuyên bạn nên luôn chỉ định
cả hai điều này cùng nhau (cấp cả hai hoặc không cấp).

Một ví dụ đặc biệt đáng ngạc nhiên là ZZ0000ZZ.  Cái tên gợi ý
rằng cuộc gọi hệ thống này yêu cầu quyền tạo và ghi tệp.  Tuy nhiên,
nó cũng yêu cầu quyền cắt bớt nếu một tập tin hiện có có cùng tên
đã có mặt rồi.

Cũng cần lưu ý rằng việc cắt bớt các tập tin không yêu cầu
ZZ0002ZZ đúng rồi.  Ngoài ZZ0000ZZ
cuộc gọi hệ thống, điều này cũng có thể được thực hiện thông qua ZZ0001ZZ với các cờ
ZZ0003ZZ.

Đồng thời, trên một số hệ thống tập tin, ZZ0000ZZ cung cấp một cách để
rút ngắn nội dung file bằng ZZ0001ZZ khi mở file
để viết, bỏ qua ZZ0002ZZ.

Quyền cắt ngắn được liên kết với tệp đã mở (xem bên dưới).

Quyền liên quan đến bộ mô tả tập tin
---------------------------------------

Khi mở một tập tin, tính khả dụng của ZZ0005ZZ và
Quyền ZZ0006ZZ được liên kết với quyền mới được tạo
bộ mô tả tệp và sẽ được sử dụng cho các lần cắt ngắn và ioctl tiếp theo
sử dụng ZZ0000ZZ và ZZ0001ZZ.  Hành vi tương tự
để mở một tập tin để đọc hoặc ghi, trong đó các quyền được kiểm tra trong quá trình
ZZ0002ZZ, nhưng không có trong ZZ0003ZZ tiếp theo và
ZZ0004ZZ gọi.

Kết quả là có thể một tiến trình có nhiều tệp đang mở
mô tả đề cập đến cùng một tệp, nhưng Landlock thực thi những thứ khác nhau
khi hoạt động với các bộ mô tả tập tin này.  Điều này có thể xảy ra khi một Landlock
bộ quy tắc được thực thi và quy trình giữ các bộ mô tả tệp đã được mở
cả trước và sau khi thực thi.  Cũng có thể chuyển tập tin đó
mô tả giữa các quy trình, giữ các thuộc tính Landlock của chúng, ngay cả khi một số
trong số các quy trình liên quan không có bộ quy tắc Landlock được thi hành.

Khả năng tương thích
====================

Khả năng tương thích ngược và xuôi
----------------------------------

Landlock được thiết kế để tương thích với các phiên bản trước đây và tương lai của
hạt nhân.  Điều này đạt được nhờ vào các thuộc tính cuộc gọi hệ thống và
các bitflag liên quan, đặc biệt là ZZ0000ZZ của bộ quy tắc.  làm
quyền truy cập được xử lý rõ ràng cho phép hạt nhân và không gian người dùng có sự rõ ràng
ký hợp đồng với nhau.  Điều này là cần thiết để đảm bảo hộp cát sẽ không
trở nên chặt chẽ hơn với bản cập nhật hệ thống, điều này có thể làm hỏng ứng dụng.

Các nhà phát triển có thể đăng ký ZZ0000ZZ để cố ý cập nhật và
kiểm tra ứng dụng của họ với các tính năng mới nhất hiện có.  Vì lợi ích của
người dùng và vì họ có thể sử dụng các phiên bản kernel khác nhau nên điều này rất khó
được khuyến khích thực hiện theo phương pháp bảo mật nỗ lực tốt nhất bằng cách kiểm tra Landlock
Phiên bản ABI khi chạy và chỉ thực thi các tính năng được hỗ trợ.

.. _landlock_abi_versions:

Các phiên bản Landlock ABI
--------------------------

Phiên bản Landlock ABI có thể được đọc bằng sys_landlock_create_ruleset()
cuộc gọi hệ thống:

.. code-block:: c

    int abi;

    abi = landlock_create_ruleset(NULL, 0, LANDLOCK_CREATE_RULESET_VERSION);
    if (abi < 0) {
        switch (errno) {
        case ENOSYS:
            printf("Landlock is not supported by the current kernel.\n");
            break;
        case EOPNOTSUPP:
            printf("Landlock is currently disabled.\n");
            break;
        }
        return 0;
    }
    if (abi >= 2) {
        printf("Landlock supports LANDLOCK_ACCESS_FS_REFER.\n");
    }

Tất cả các giao diện kernel Landlock đều được hỗ trợ bởi phiên bản ABI đầu tiên trừ khi
được ghi chú rõ ràng trong tài liệu của họ.

Lỗi địa phương
---------------

Ngoài các phiên bản ABI, Landlock cung cấp cơ chế lỗi để theo dõi
khắc phục các sự cố có thể ảnh hưởng đến khả năng tương thích ngược hoặc yêu cầu không gian người dùng
nhận thức.  Bitmask lỗi có thể được truy vấn bằng cách sử dụng:

.. code-block:: c

    int errata;

    errata = landlock_create_ruleset(NULL, 0, LANDLOCK_CREATE_RULESET_ERRATA);
    if (errata < 0) {
        /* Landlock not available or disabled */
        return 0;
    }

Giá trị được trả về là một bitmask trong đó mỗi bit đại diện cho một lỗi cụ thể.
Nếu bit N được đặt (ZZ0000ZZ), thì lỗi N đã được sửa
trong kernel đang chạy.

.. warning::

   **Most applications should NOT check errata.** In 99.9% of cases, checking
   errata is unnecessary, increases code complexity, and can potentially
   decrease protection if misused.  For example, disabling the sandbox when an
   erratum is not fixed could leave the system less secure than using
   Landlock's best-effort protection.  When in doubt, ignore errata.

.. kernel-doc:: security/landlock/errata/abi-4.h
    :doc: erratum_1

.. kernel-doc:: security/landlock/errata/abi-6.h
    :doc: erratum_2

.. kernel-doc:: security/landlock/errata/abi-1.h
    :doc: erratum_3

Cách kiểm tra lỗi
~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn xác định rằng ứng dụng của bạn cần kiểm tra lỗi cụ thể,
sử dụng mẫu này:

.. code-block:: c

    int errata = landlock_create_ruleset(NULL, 0, LANDLOCK_CREATE_RULESET_ERRATA);
    if (errata >= 0) {
        /* Check for specific erratum (1-indexed) */
        if (errata & (1 << (erratum_number - 1))) {
            /* Erratum N is fixed in this kernel */
        } else {
            /* Erratum N is NOT fixed - consider implications for your use case */
        }
    }

ZZ0000ZZ Chỉ kiểm tra lỗi nếu ứng dụng của bạn đặc biệt dựa vào
hành vi đã thay đổi do sửa lỗi.  Các bản sửa lỗi nhìn chung làm cho Landlock ít hơn
hạn chế hoặc đúng hơn, không hạn chế hơn.

Giao diện hạt nhân
==================

Quyền truy cập
--------------

.. kernel-doc:: include/uapi/linux/landlock.h
    :identifiers: fs_access net_access scope

Tạo một bộ quy tắc mới
----------------------

.. kernel-doc:: security/landlock/syscalls.c
    :identifiers: sys_landlock_create_ruleset

.. kernel-doc:: include/uapi/linux/landlock.h
    :identifiers: landlock_ruleset_attr

Mở rộng bộ quy tắc
-------------------

.. kernel-doc:: security/landlock/syscalls.c
    :identifiers: sys_landlock_add_rule

.. kernel-doc:: include/uapi/linux/landlock.h
    :identifiers: landlock_rule_type landlock_path_beneath_attr
                  landlock_net_port_attr

Thực thi một bộ quy tắc
-----------------------

.. kernel-doc:: security/landlock/syscalls.c
    :identifiers: sys_landlock_restrict_self

Hạn chế hiện tại
===================

Sửa đổi cấu trúc liên kết hệ thống tập tin
------------------------------------------

Các chủ đề được đóng hộp cát với các hạn chế về hệ thống tệp không thể sửa đổi hệ thống tệp
cấu trúc liên kết, cho dù thông qua ZZ0000ZZ hoặc ZZ0001ZZ.
Tuy nhiên, các cuộc gọi ZZ0002ZZ không bị từ chối.

Hệ thống tập tin đặc biệt
-------------------------

Quyền truy cập vào các tập tin và thư mục thông thường có thể bị hạn chế bởi Landlock,
theo các truy cập được xử lý của một bộ quy tắc.  Tuy nhiên, các tập tin không
đến từ hệ thống tệp mà người dùng có thể nhìn thấy (ví dụ: ống, ổ cắm), nhưng vẫn có thể
được truy cập thông qua ZZ0000ZZ, hiện tại không thể truy cập một cách rõ ràng
bị hạn chế.  Tương tự như vậy, một số hệ thống tập tin hạt nhân đặc biệt như nsfs, có thể
được truy cập thông qua ZZ0001ZZ, hiện tại không thể được truy cập một cách rõ ràng
bị hạn chế.  Tuy nhiên, nhờ có ZZ0003ZZ, khả năng truy cập như vậy
các tệp ZZ0002ZZ nhạy cảm sẽ tự động bị hạn chế theo miền
hệ thống phân cấp.  Sự phát triển của Landlock trong tương lai vẫn có thể cho phép
hạn chế các đường dẫn như vậy bằng các cờ quy tắc chuyên dụng.

Lớp quy tắc
--------------

Có giới hạn 16 lớp bộ quy tắc xếp chồng lên nhau.  Đây có thể là một vấn đề đối với một
nhiệm vụ sẵn sàng thực thi một bộ quy tắc mới để bổ sung cho 16 quy tắc kế thừa của nó
bộ quy tắc.  Khi đạt đến giới hạn này, sys_landlock_restrict_self() sẽ trả về
E2BIG.  Sau đó, chúng tôi khuyên bạn nên xây dựng các bộ quy tắc một cách cẩn thận một lần trong
tuổi thọ của một luồng, đặc biệt đối với các ứng dụng có thể khởi chạy các ứng dụng khác
cũng có thể muốn tự sandbox (ví dụ: shell, trình quản lý vùng chứa,
v.v.).

Sử dụng bộ nhớ
--------------

Bộ nhớ hạt nhân được phân bổ để tạo các bộ quy tắc được tính toán và có thể bị hạn chế
bởi Tài liệu/admin-guide/cgroup-v1/memory.rst.

Hỗ trợ IOCTL
-------------

Quyền ZZ0001ZZ hạn chế việc sử dụng
ZZ0000ZZ, nhưng nó chỉ áp dụng cho các tệp thiết bị ZZ0002ZZ.  Cái này
có nghĩa cụ thể là các bộ mô tả tệp có sẵn như stdin, stdout và
stderr không bị ảnh hưởng.

Người dùng nên biết rằng các thiết bị TTY theo truyền thống được phép kiểm soát
các quy trình khác trên cùng TTY thông qua ZZ0000ZZ và ZZ0001ZZ IOCTL
lệnh.  Cả hai đều yêu cầu ZZ0002ZZ trên các hệ thống Linux hiện đại, nhưng
hành vi có thể được cấu hình cho ZZ0003ZZ.

Do đó, trên các hệ thống cũ hơn, nên đóng tệp TTY được kế thừa
bộ mô tả hoặc để mở lại chúng từ ZZ0000ZZ mà không cần
ZZ0001ZZ đúng rồi, nếu có thể.

Hiện tại, hỗ trợ IOCTL của Landlock ở mức độ thô nhưng có thể trở nên phức tạp hơn
tinh tế trong tương lai.  Cho đến lúc đó, người dùng nên thiết lập
đảm bảo rằng họ cần thông qua hệ thống phân cấp tệp, bằng cách chỉ cho phép
ZZ0000ZZ ngay trên các tập tin thực sự cần thiết.

Những hạn chế trước đó
======================

Đổi tên và liên kết tệp (ABI < 2)
-----------------------------------

Bởi vì Landlock nhắm tới các biện pháp kiểm soát truy cập không có đặc quyền nên nó cần phải
xử lý thành phần của các quy tắc.  Thuộc tính như vậy cũng bao hàm các quy tắc lồng nhau.
Xử lý đúng cách nhiều lớp quy tắc, mỗi lớp có thể
hạn chế quyền truy cập vào các tập tin, cũng ngụ ý kế thừa các hạn chế của bộ quy tắc
từ cha mẹ đến hệ thống phân cấp của nó.  Bởi vì các tập tin được xác định và hạn chế bởi
hệ thống phân cấp của họ, việc di chuyển hoặc liên kết một tập tin từ thư mục này sang thư mục khác ngụ ý
truyền bá các ràng buộc phân cấp hoặc hạn chế các hành động này
theo các ràng buộc có khả năng bị mất.  Để bảo vệ chống lại đặc quyền
leo thang thông qua việc đổi tên hoặc liên kết và để đơn giản,
Landlock trước đây đã hạn chế liên kết và đổi tên vào cùng một thư mục.
Bắt đầu với Landlock ABI phiên bản 2, giờ đây có thể bảo mật
kiểm soát việc đổi tên và liên kết nhờ ZZ0000ZZ mới
quyền truy cập.

Cắt bớt tệp (ABI < 3)
-------------------------

Việc cắt bớt tập tin không thể bị từ chối trước Landlock ABI thứ ba, vì vậy nó là
luôn được phép khi sử dụng kernel chỉ hỗ trợ ABI thứ nhất hoặc thứ hai.

Bắt đầu với Landlock ABI phiên bản 3, giờ đây có thể kiểm soát an toàn
cắt bớt nhờ quyền truy cập ZZ0000ZZ mới.

TCP liên kết và kết nối (ABI <4)
--------------------------------

Bắt đầu với Landlock ABI phiên bản 4, giờ đây có thể hạn chế TCP
liên kết và kết nối các hành động chỉ với một tập hợp các cổng được phép nhờ tính năng mới
ZZ0000ZZ và ZZ0001ZZ
quyền truy cập.

Thiết bị IOCTL (ABI < 5)
------------------------

Các hoạt động của IOCTL không thể bị từ chối trước Landlock ABI thứ năm, vì vậy
ZZ0000ZZ luôn được phép khi sử dụng kernel chỉ hỗ trợ một
ABI trước đó.

Bắt đầu với Landlock ABI phiên bản 5, có thể hạn chế việc sử dụng
ZZ0000ZZ trên các thiết bị ký tự và khối sử dụng công nghệ mới
ZZ0001ZZ đúng rồi.

Ổ cắm UNIX trừu tượng (ABI < 6)
-------------------------------

Bắt đầu với Landlock ABI phiên bản 6, có thể hạn chế
kết nối với ổ cắm ZZ0000ZZ trừu tượng bằng cách cài đặt
ZZ0001ZZ sang thuộc tính bộ quy tắc ZZ0002ZZ.

Tín hiệu (ABI < 6)
------------------

Bắt đầu với Landlock ABI phiên bản 6, có thể hạn chế
ZZ0000ZZ gửi bằng cách đặt ZZ0001ZZ thành
Thuộc tính bộ quy tắc ZZ0002ZZ.

Ghi nhật ký (ABI < 7)
---------------------

Bắt đầu với Landlock ABI phiên bản 7, có thể kiểm soát việc ghi nhật ký
Các sự kiện kiểm tra Landlock với ZZ0000ZZ,
ZZ0001ZZ, và
Cờ ZZ0002ZZ được chuyển tới
sys_landlock_restrict_self().  Xem Tài liệu/admin-guide/LSM/landlock.rst
để biết thêm chi tiết về kiểm toán.

Đồng bộ hóa chủ đề (ABI < 8)
--------------------------------

Bắt đầu với Landlock ABI phiên bản 8, giờ đây bạn có thể
thực thi các bộ quy tắc Landlock trên tất cả các luồng của quá trình gọi
sử dụng cờ ZZ0000ZZ được chuyển tới
sys_landlock_restrict_self().

Tên đường dẫn Ổ cắm UNIX (ABI < 9)
----------------------------------

Bắt đầu với Landlock ABI phiên bản 9, có thể hạn chế
kết nối với tên đường dẫn ổ cắm miền UNIX (ZZ0000ZZ) bằng cách sử dụng
ZZ0001ZZ mới phải không.

.. _kernel_support:

Hỗ trợ hạt nhân
===============

Xây dựng cấu hình thời gian
---------------------------

Landlock được giới thiệu lần đầu tiên trong Linux 5.13 nhưng nó phải được cấu hình khi xây dựng
thời gian với ZZ0000ZZ.  Landlock cũng phải được kích hoạt khi khởi động
thời gian như các module bảo mật khác.  Danh sách các mô-đun bảo mật được kích hoạt bởi
mặc định được đặt bằng ZZ0001ZZ.  Cấu hình kernel sau đó sẽ
chứa ZZ0002ZZ với ZZ0003ZZ là danh sách khác
các mô-đun bảo mật có khả năng hữu ích cho hệ thống đang chạy (xem phần
Trợ giúp ZZ0004ZZ).

Cấu hình thời gian khởi động
----------------------------

Nếu kernel đang chạy không có ZZ0000ZZ trong ZZ0001ZZ thì chúng ta có thể
bật Landlock bằng cách thêm ZZ0002ZZ vào
Tài liệu/admin-guide/kernel-parameters.rst trong bộ tải khởi động
cấu hình.

Ví dụ: nếu cấu hình tích hợp hiện tại là:

.. code-block:: console

    $ zgrep -h "^CONFIG_LSM=" "/boot/config-$(uname -r)" /proc/config.gz 2>/dev/null
    CONFIG_LSM="lockdown,yama,integrity,apparmor"

...and if the cmdline doesn't contain ``landlock`` either:

.. code-block:: console

    $ sed -n 's/.*\(\<lsm=\S\+\).*/\1/p' /proc/cmdline
    lsm=lockdown,yama,integrity,apparmor

...we should configure the boot loader to set a cmdline extending the ``lsm``
danh sách có tiền tố ZZ0000ZZ::

lsm=đất liền,phong tỏa,yama,liêm chính,apparmor

Sau khi khởi động lại, chúng ta có thể kiểm tra xem Landlock có hoạt động hay không bằng cách xem
nhật ký hạt nhân:

.. code-block:: console

    # dmesg | grep landlock || journalctl -kb -g landlock
    [    0.000000] Command line: [...] lsm=landlock,lockdown,yama,integrity,apparmor
    [    0.000000] Kernel command line: [...] lsm=landlock,lockdown,yama,integrity,apparmor
    [    0.000000] LSM: initializing lsm=lockdown,capability,landlock,yama,integrity,apparmor
    [    0.000000] landlock: Up and running.

Hạt nhân có thể được cấu hình tại thời điểm xây dựng để luôn tải ZZ0000ZZ và
LSM ZZ0001ZZ.  Trong trường hợp đó, các LSM này sẽ xuất hiện ở đầu
dòng nhật ký ZZ0002ZZ, ngay cả khi chúng không được định cấu hình trong
bộ tải khởi động.

Hỗ trợ mạng
---------------

Để có thể cho phép rõ ràng các hoạt động TCP (ví dụ: thêm quy tắc mạng với
ZZ0000ZZ), kernel phải hỗ trợ TCP
(ZZ0001ZZ).  Ngược lại, sys_landlock_add_rule() trả về một
Lỗi ZZ0002ZZ, có thể bỏ qua một cách an toàn vì loại TCP này
hoạt động đã không thể thực hiện được.

Câu hỏi và câu trả lời
======================

Còn người quản lý hộp cát không gian người dùng thì sao?
--------------------------------------------------------

Việc sử dụng các quy trình không gian người dùng để thực thi các hạn chế đối với tài nguyên kernel có thể dẫn đến
để đua các điều kiện hoặc đánh giá không nhất quán (ví dụ ZZ0000ZZ).

Còn không gian tên và vùng chứa thì sao?
----------------------------------------

Không gian tên có thể giúp tạo hộp cát nhưng chúng không được thiết kế cho
kiểm soát truy cập và sau đó bỏ lỡ các tính năng hữu ích cho trường hợp sử dụng đó (ví dụ: không
hạn chế chi tiết).  Hơn nữa, sự phức tạp của chúng có thể dẫn đến vấn đề an ninh
các vấn đề, đặc biệt là khi các quy trình không đáng tin cậy có thể thao túng chúng (cf.
ZZ0000ZZ).

Làm cách nào để vô hiệu hóa hồ sơ kiểm toán Landlock?
-----------------------------------------------------

Bạn có thể muốn đặt các bộ lọc tại chỗ như được giải thích ở đây:
Tài liệu/admin-guide/LSM/landlock.rst

Tài liệu bổ sung
========================

* Tài liệu/admin-guide/LSM/landlock.rst
* Tài liệu/bảo mật/landlock.rst
* ZZ0000ZZ

.. Links
.. _samples/landlock/sandboxer.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux.git/tree/samples/landlock/sandboxer.c