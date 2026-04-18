.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/kbuild/kconfig.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Mục tiêu cấu hình và trình chỉnh sửa
=================================

Tệp này chứa một số hỗ trợ để sử dụng ZZ0000ZZ.

Sử dụng ZZ0000ZZ để liệt kê tất cả các mục tiêu cấu hình có thể.

Xconfig ('qconf'), menuconfig ('mconf') và nconfig ('nconf')
các chương trình cũng có văn bản trợ giúp được nhúng.  Hãy chắc chắn kiểm tra xem
điều hướng, tìm kiếm và văn bản trợ giúp chung khác.

Chương trình gconfig ('gconf') có văn bản trợ giúp hạn chế.


Tổng quan
=======

Các bản phát hành kernel mới thường giới thiệu các ký hiệu cấu hình mới.  Thường xuyên hơn
quan trọng, các bản phát hành kernel mới có thể đổi tên các ký hiệu cấu hình.  Khi nào
điều này xảy ra khi sử dụng tệp .config đang hoạt động trước đó và đang chạy
"make oldconfig" không nhất thiết phải tạo ra kernel mới hoạt động được
cho bạn, vì vậy bạn có thể thấy rằng bạn cần xem kernel NEW nào
các biểu tượng đã được giới thiệu.

Để xem danh sách các ký hiệu cấu hình mới, hãy sử dụng::

cp người dùng/some/old.config .config
    tạo danh sáchnewconfig

và chương trình cấu hình sẽ liệt kê bất kỳ ký hiệu mới nào, mỗi ký hiệu trên một dòng.

Ngoài ra, bạn có thể sử dụng phương pháp vũ phu ::

tạo cấu hình cũ
    scripts/diffconfig .config.old .config | ít hơn


Biến môi trường
=====================

Biến môi trường cho ZZ0000ZZ:

ZZ0000ZZ
    Biến môi trường này có thể được sử dụng để chỉ định cấu hình kernel mặc định
    tên tệp để ghi đè tên mặc định của ".config".

ZZ0000ZZ
    Biến môi trường này chỉ định danh sách các tệp cấu hình có thể
    được sử dụng làm cấu hình cơ sở trong trường hợp .config chưa tồn tại.
    Các mục trong danh sách được phân tách bằng khoảng trắng và
    cái đầu tiên tồn tại được sử dụng.

ZZ0000ZZ
    Nếu bạn đặt KCONFIG_OVERWRITECONFIG trong môi trường, Kconfig sẽ không
    phá vỡ các liên kết tượng trưng khi .config là một liên kết tượng trưng đến một nơi khác.

ZZ0000ZZ
    Biến môi trường này khiến Kconfig cảnh báo về tất cả các thiết bị không được nhận dạng
    các ký hiệu trong đầu vào cấu hình.

ZZ0000ZZ
    Nếu được đặt, Kconfig coi cảnh báo là lỗi.

ZZ0000ZZ
    Nếu bạn đặt ZZ0001ZZ trong môi trường, Kconfig sẽ đặt tiền tố cho tất cả các ký hiệu
    với giá trị của nó khi lưu cấu hình, thay vì sử dụng
    mặc định, ZZ0002ZZ.

Biến môi trường cho ZZ0000ZZ:

ZZ0000ZZ
    Các biến thể allyesconfig/allmodconfig/alldefconfig/allnoconfig/Randconfig
    cũng có thể sử dụng biến môi trường KCONFIG_ALLCONFIG làm cờ hoặc
    tên tệp chứa các ký hiệu cấu hình mà người dùng yêu cầu đặt thành
    giá trị cụ thể.  Nếu KCONFIG_ALLCONFIG được sử dụng mà không có tên tệp trong đó
    KCONFIG_ALLCONFIG == "" hoặc KCONFIG_ALLCONFIG == "1", ZZ0001ZZ
    kiểm tra tệp có tên "all{yes/mod/no/def/random}.config"
    (tương ứng với lệnh ZZ0002ZZ đã được sử dụng) cho các giá trị ký hiệu
    đó là điều bắt buộc.  Nếu không tìm thấy tập tin này, nó sẽ kiểm tra
    tệp có tên "all.config" để chứa các giá trị bắt buộc.

Điều này cho phép bạn tạo cấu hình "thu nhỏ" (miniconfig) hoặc tùy chỉnh
    config chỉ chứa các ký hiệu cấu hình mà bạn quan tâm
    in. Sau đó, hệ thống cấu hình kernel sẽ tạo tệp .config đầy đủ,
    bao gồm các ký hiệu của tệp miniconfig của bạn.

Tệp ZZ0000ZZ này là tệp cấu hình chứa
    (thường là tập hợp con của tất cả) các ký hiệu cấu hình đặt trước.  Những biến này
    cài đặt vẫn phải chịu sự kiểm tra phụ thuộc thông thường.

Ví dụ::

KCONFIG_ALLCONFIG=custom-notebook.config tạo allnoconfig

hoặc::

KCONFIG_ALLCONFIG=mini.config tạo allnoconfig

hoặc::

tạo KCONFIG_ALLCONFIG=mini.config allnoconfig

Những ví dụ này sẽ vô hiệu hóa hầu hết các tùy chọn (allnoconfig) nhưng kích hoạt hoặc
    vô hiệu hóa các tùy chọn được liệt kê rõ ràng trong quy định
    tập tin cấu hình nhỏ.

Biến môi trường cho ZZ0000ZZ:

ZZ0000ZZ
    Bạn có thể đặt giá trị này thành giá trị số nguyên được sử dụng để tạo RNG, nếu bạn muốn
    để bằng cách nào đó gỡ lỗi hành vi của trình phân tích cú pháp/giao diện kconfig.
    Nếu không được đặt, thời gian hiện tại sẽ được sử dụng.

ZZ0000ZZ
    Biến này có thể được sử dụng để làm lệch xác suất. Biến này có thể
    không được đặt hoặc để trống hoặc được đặt thành ba định dạng khác nhau:

===================================================================
    KCONFIG_PROBABILITY y:n chia y:m:n chia
    ===================================================================
    không đặt hoặc trống 50 : 50 33 : 33 : 34
    N N : 100-N N/2 : N/2 : 100-N
    [1] N:M N+M : 100-(N+M) N : M : 100-(N+M)
    [2] N:M:L N : 100-N M : L : 100-(M+L)
    ===================================================================

trong đó N, M và L là các số nguyên (trong cơ số 10) trong khoảng [0,100], v.v.
đó:

[1] N+M nằm trong khoảng [0,100]

[2] M+L nằm trong khoảng [0,100]

Ví dụ::

KCONFIG_PROBABILITY=10
        10% boolean sẽ được đặt thành 'y', 90% thành 'n'
        5% tristate sẽ được đặt thành 'y', 5% thành 'm', 90% thành 'n'
    KCONFIG_PROBABILITY=15:25
        40% boolean sẽ được đặt thành 'y', 60% thành 'n'
        15% tristate sẽ được đặt thành 'y', 25% thành 'm', 60% thành 'n'
    KCONFIG_PROBABILITY=10:15:15
        10% boolean sẽ được đặt thành 'y', 90% thành 'n'
        15% tristate sẽ được đặt thành 'y', 15% thành 'm', 70% thành 'n'

Biến môi trường cho ZZ0000ZZ:

ZZ0000ZZ
    Nếu biến này có giá trị không trống, nó sẽ ngăn kernel im lặng
    cập nhật cấu hình (yêu cầu cập nhật rõ ràng).

ZZ0000ZZ
    Biến môi trường này có thể được đặt để chỉ định đường dẫn và tên của
    tập tin "auto.conf".  Giá trị mặc định của nó là "include/config/auto.conf".

ZZ0000ZZ
    Biến môi trường này có thể được đặt để chỉ định đường dẫn và tên của
    tập tin "autoconf.h" (tiêu đề).
    Giá trị mặc định của nó là "include/generated/autoconf.h".


cấu hình menu
==========

Tìm kiếm trong menuconfig:

Chức năng Tìm kiếm tìm kiếm biểu tượng cấu hình kernel
    tên, vì vậy bạn phải biết điều gì đó gần gũi với bạn
    đang tìm kiếm.

Ví dụ::

/cắm nóng
        Danh sách này liệt kê tất cả các ký hiệu cấu hình có chứa "hotplug",
        ví dụ: HOTPLUG_CPU, MEMORY_HOTPLUG.

Để được trợ giúp tìm kiếm, hãy nhập / theo sau là TAB-TAB (để đánh dấu
    <Trợ giúp>) và Enter.  Điều này sẽ cho bạn biết rằng bạn cũng có thể sử dụng
    biểu thức chính quy (regexes) trong chuỗi tìm kiếm, vì vậy nếu bạn
    không quan tâm đến MEMORY_HOTPLUG, bạn có thể thử ::

/^cắm nóng

Khi tìm kiếm, các ký hiệu được sắp xếp như sau:

- đầu tiên, khớp chính xác, được sắp xếp theo thứ tự abc (khớp chính xác
      là khi tìm kiếm khớp với tên ký hiệu hoàn chỉnh);
    - sau đó, các trận đấu khác, được sắp xếp theo thứ tự bảng chữ cái.

Ví dụ: ^ATH.K khớp:

ATH5K ATH9K ATH5K_AHB ATH5K_DEBUG […] ATH6KL ATH6KL_DEBUG
        […] ATH9K_AHB ATH9K_BTCOEX_SUPPORT ATH9K_COMMON […]

trong đó chỉ có ATH5K và ATH9K khớp chính xác và được sắp xếp
    đầu tiên (và theo thứ tự bảng chữ cái), sau đó đến tất cả các ký hiệu khác,
    sắp xếp theo thứ tự bảng chữ cái.

Trong menu này, nhấn phím ở tiền tố (#) sẽ nhảy
    trực tiếp đến vị trí đó. Bạn sẽ được trả về hiện tại
    kết quả tìm kiếm sau khi thoát khỏi menu mới này.

Tùy chọn giao diện người dùng cho 'menuconfig':

ZZ0000ZZ
    Có thể chọn các chủ đề màu khác nhau bằng cách sử dụng biến
    MENUCONFIG_COLOR.  Để chọn một chủ đề, hãy sử dụng::

tạo cấu hình menu MENUCONFIG_COLOR=<theme>

Các chủ đề có sẵn là::

- mono => chọn màu phù hợp với màn hình đơn sắc
      - blackbg => chọn bảng màu có nền đen
      - cổ điển => chủ đề có nền màu xanh. Cái nhìn cổ điển
      - bluetitle => một phiên bản cổ điển thân thiện với LCD. (mặc định)

ZZ0000ZZ
    Chế độ này hiển thị tất cả các menu phụ trong một cây lớn.

Ví dụ::

tạo MENUCONFIG_MODE=single_menu menuconfig


nconfig
=======

nconfig là một bộ cấu hình dựa trên văn bản thay thế.  Nó liệt kê chức năng
các phím ở cuối thiết bị đầu cuối (cửa sổ) thực thi các lệnh.
Bạn cũng có thể chỉ cần sử dụng phím số tương ứng để thực hiện
lệnh trừ khi bạn đang ở trong cửa sổ nhập dữ liệu.  Ví dụ: thay vì F6
để Lưu, bạn chỉ cần nhấn phím 6.

Sử dụng F1 cho Trợ giúp chung hoặc F3 cho menu Trợ giúp ngắn.

Tìm kiếm trong nconfig:

Bạn có thể tìm kiếm trong chuỗi "nhắc nhở" của mục menu
    hoặc trong các ký hiệu cấu hình.

Sử dụng / để bắt đầu tìm kiếm thông qua các mục menu.  Điều này không
    không hỗ trợ các biểu thức thông thường.  Sử dụng <Down> hoặc <Up> để
    Lượt truy cập tiếp theo và lượt truy cập trước tương ứng.  Sử dụng <Esc> để
    chấm dứt chế độ tìm kiếm.

F8 (SymSearch) tìm kiếm các ký hiệu cấu hình cho
    chuỗi đã cho hoặc biểu thức chính quy (regex).

Trong SymSearch, nhấn phím ở tiền tố (#) sẽ
    nhảy thẳng tới vị trí đó. Bạn sẽ được quay trở lại
    kết quả tìm kiếm hiện tại sau khi thoát khỏi menu mới này.

Biến môi trường:

ZZ0000ZZ
    Chế độ này hiển thị tất cả các menu phụ trong một cây lớn.

Ví dụ::

tạo NCONFIG_MODE=single_menu nconfig


xconfig
=======

Tìm kiếm trong xconfig:

Chức năng Tìm kiếm tìm kiếm biểu tượng cấu hình kernel
    tên, vì vậy bạn phải biết điều gì đó gần gũi với bạn
    đang tìm kiếm.

Ví dụ::

phích cắm nóng Ctrl-F

hoặc::

Menu: Tệp, Tìm kiếm, cắm nóng

liệt kê tất cả các mục biểu tượng cấu hình có chứa "hotplug" trong
    tên biểu tượng.  Trong hộp thoại Tìm kiếm này, bạn có thể thay đổi
    cài đặt cấu hình cho bất kỳ mục nào không bị chuyển sang màu xám.
    Bạn cũng có thể nhập chuỗi tìm kiếm khác mà không cần
    để quay lại menu chính.


gconfig
=======

Tìm kiếm trong gconfig:

Không có lệnh tìm kiếm trong gconfig.  Tuy nhiên, gconfig có
    có nhiều lựa chọn, chế độ và tùy chọn xem khác nhau.
