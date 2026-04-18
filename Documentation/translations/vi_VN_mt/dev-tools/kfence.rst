.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kfence.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2020, Google LLC.

Hàng rào điện hạt nhân (KFENCE)
===============================

Kernel Electric-Fence (KFENCE) là giải pháp an toàn bộ nhớ dựa trên lấy mẫu với chi phí thấp
máy dò lỗi. KFENCE phát hiện truy cập vượt quá giới hạn, sử dụng sau khi miễn phí và
lỗi không hợp lệ.

KFENCE được thiết kế để kích hoạt trong các hạt nhân sản xuất và gần như không có
chi phí hiệu suất. So với KASAN, KFENCE đánh đổi hiệu suất cho
độ chính xác. Động lực chính đằng sau thiết kế của KFENCE là có đủ
tổng thời gian hoạt động KFENCE sẽ phát hiện lỗi trong các đường dẫn mã thường không được thực hiện bởi
khối lượng công việc thử nghiệm phi sản xuất. Một cách để nhanh chóng đạt được tổng số tiền đủ lớn
thời gian hoạt động là khi công cụ được triển khai trên một nhóm máy lớn.

Cách sử dụng
------------

Để bật KFENCE, hãy định cấu hình kernel bằng::

CONFIG_KFENCE=y

Để xây dựng kernel có hỗ trợ KFENCE nhưng bị tắt theo mặc định (để bật, hãy đặt
ZZ0000ZZ thành giá trị khác 0), hãy định cấu hình kernel bằng::

CONFIG_KFENCE=y
    CONFIG_KFENCE_SAMPLE_INTERVAL=0

KFENCE cung cấp một số tùy chọn cấu hình khác để tùy chỉnh hành vi (xem
văn bản trợ giúp tương ứng trong ZZ0000ZZ để biết thêm thông tin).

Hiệu suất điều chỉnh
~~~~~~~~~~~~~~~~~~~~

Tham số quan trọng nhất là khoảng thời gian mẫu của KFENCE, có thể được đặt qua
tham số khởi động kernel ZZ0000ZZ tính bằng mili giây. các
khoảng thời gian mẫu xác định tần suất phân bổ heap sẽ được thực hiện
được bảo vệ bởi KFENCE. Mặc định có thể cấu hình thông qua tùy chọn Kconfig
ZZ0001ZZ. Cài đặt ZZ0002ZZ
vô hiệu hóa KFENCE.

Khoảng thời gian mẫu kiểm soát bộ đếm thời gian thiết lập phân bổ KFENCE. Bởi
mặc định, để giữ cho khoảng thời gian mẫu thực có thể dự đoán được, bộ hẹn giờ thông thường cũng
gây ra tình trạng đánh thức CPU khi hệ thống hoàn toàn không hoạt động. Điều này có thể là điều không mong muốn
trên các hệ thống bị hạn chế về công suất. Tham số khởi động ZZ0000ZZ
thay vào đó chuyển sang bộ hẹn giờ "có thể trì hoãn" không bắt buộc bật CPU
hệ thống nhàn rỗi, có nguy cơ khoảng thời gian lấy mẫu không thể đoán trước. Mặc định là
có thể định cấu hình thông qua tùy chọn Kconfig ZZ0001ZZ.

.. warning::
   The KUnit test suite is very likely to fail when using a deferrable timer
   since it currently causes very unpredictable sample intervals.

Theo mặc định, KFENCE sẽ chỉ lấy mẫu phân bổ 1 heap trong mỗi mẫu
khoảng. ZZ0003ZZ cho phép lấy mẫu phân bổ đống liên tiếp, trong đó
tham số khởi động kernel ZZ0000ZZ có thể được đặt thành giá trị khác 0
biểu thị sự phân bổ liên tiếp ZZ0004ZZ trong một khoảng mẫu;
cài đặt ZZ0001ZZ có nghĩa là việc phân bổ liên tiếp ZZ0002ZZ là
đã thử qua KFENCE cho mỗi khoảng thời gian lấy mẫu.

Nhóm bộ nhớ KFENCE có kích thước cố định và nếu nhóm đã cạn kiệt, không có
việc phân bổ KFENCE tiếp theo diễn ra. Với ZZ0000ZZ (mặc định
255), số lượng đối tượng được bảo vệ có sẵn có thể được kiểm soát. Mỗi đối tượng
yêu cầu 2 trang, một trang dành cho chính đối tượng và trang còn lại dùng làm bảo vệ
trang; các trang đối tượng được xen kẽ với các trang bảo vệ và mỗi trang đối tượng được
do đó được bao quanh bởi hai trang bảo vệ.

Tổng bộ nhớ dành riêng cho nhóm bộ nhớ KFENCE có thể được tính như sau:

( #objects + 1 ) * 2 * PAGE_SIZE

Sử dụng cấu hình mặc định và giả sử kích thước trang là 4 KiB, sẽ dẫn đến
dành 2 MiB cho nhóm bộ nhớ KFENCE.

Lưu ý: Trên các kiến trúc hỗ trợ các trang lớn, KFENCE sẽ đảm bảo rằng
pool đang sử dụng các trang có kích thước ZZ0000ZZ. Điều này sẽ dẫn đến trang bổ sung
các bảng đang được phân bổ.

Báo cáo lỗi
~~~~~~~~~~~~~

Tham số khởi động ZZ0000ZZ có thể được sử dụng để kiểm soát hành vi khi một
Phát hiện lỗi KFENCE:

- ZZ0000ZZ: In báo lỗi và tiếp tục (mặc định).
- ZZ0001ZZ: In báo lỗi và rất tiếc.
- ZZ0002ZZ: In báo lỗi và hốt hoảng.

Một quyền truy cập ngoài giới hạn điển hình trông như thế này::

=======================================================================
    BUG: KFENCE: đọc ngoài giới hạn trong test_out_of_bounds_read+0xa6/0x234

Đọc ngoài giới hạn ở 0xffff8c3f2e291fff (1B còn lại của kfence-#72):
     test_out_of_bounds_read+0xa6/0x234
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

kfence-#72: 0xffff8c3f2e292000-0xffff8c3f2e29201f, size=32, cache=kmalloc-32

được phân bổ theo nhiệm vụ 484 trên cpu 0 ở 32.919330s:
     test_alloc+0xfe/0x738
     test_out_of_bounds_read+0x9b/0x234
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

CPU: 0 PID: 484 Giao tiếp: kunit_try_catch Không bị nhiễm độc 5.13.0-rc3+ #7
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

Tiêu đề của báo cáo cung cấp một bản tóm tắt ngắn gọn về chức năng liên quan đến
quyền truy cập. Tiếp theo là thông tin chi tiết hơn về quyền truy cập và
nguồn gốc của nó. Lưu ý rằng, địa chỉ kernel thực chỉ được hiển thị khi sử dụng
tùy chọn dòng lệnh kernel ZZ0000ZZ.

Các quyền truy cập sử dụng sau khi miễn phí được báo cáo là::

=======================================================================
    BUG: KFENCE: đọc sau khi sử dụng miễn phí trong test_use_after_free_read+0xb3/0x143

Đọc sau khi sử dụng miễn phí tại 0xffff8c3f2e2a0000 (trong kfence-#79):
     test_use_after_free_read+0xb3/0x143
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

kfence-#79: 0xffff8c3f2e2a0000-0xffff8c3f2e2a001f, size=32, cache=kmalloc-32

được phân bổ theo nhiệm vụ 488 trên cpu 2 ở mức 33,871326:
     test_alloc+0xfe/0x738
     test_use_after_free_read+0x76/0x143
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

được giải phóng bởi nhiệm vụ 488 trên cpu 2 ở mức 33,871358:
     test_use_after_free_read+0xa8/0x143
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

CPU: 2 PID: 488 Comm: kunit_try_catch Bị nhiễm độc: G B 5.13.0-rc3+ #7
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

KFENCE cũng báo cáo về các giải phóng không hợp lệ, chẳng hạn như giải phóng kép::

=======================================================================
    BUG: KFENCE: miễn phí không hợp lệ trong test_double_free+0xdc/0x171

Không hợp lệ nếu không có 0xffff8c3f2e2a4000 (trong kfence-#81):
     test_double_free+0xdc/0x171
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

kfence-#81: 0xffff8c3f2e2a4000-0xffff8c3f2e2a401f, size=32, cache=kmalloc-32

được phân bổ theo nhiệm vụ 490 trên cpu 1 ở 34.175321s:
     test_alloc+0xfe/0x738
     test_double_free+0x76/0x171
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

được giải phóng bởi nhiệm vụ 490 trên cpu 1 ở 34.175348s:
     test_double_free+0xa8/0x171
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

CPU: 1 PID: 490 Comm: kunit_try_catch Bị nhiễm độc: G B 5.13.0-rc3+ #7
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

KFENCE cũng sử dụng các vùng đỏ dựa trên mẫu ở phía bên kia của vùng bảo vệ đối tượng
trang, để phát hiện việc ghi ngoài giới hạn ở phía không được bảo vệ của đối tượng.
Đây là những báo cáo về miễn phí::

=======================================================================
    BUG: KFENCE: hỏng bộ nhớ trong test_kmalloc_aligned_oob_write+0xef/0x184

Bộ nhớ bị hỏng ở 0xffff8c3f2e33aff9 [ 0xac . . . . . . ] (trong kfence-#156):
     test_kmalloc_aligned_oob_write+0xef/0x184
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

kfence-#156: 0xffff8c3f2e33afb0-0xffff8c3f2e33aff8, size=73, cache=kmalloc-96

được phân bổ theo nhiệm vụ 502 trên cpu 7 ở 42.159302s:
     test_alloc+0xfe/0x738
     test_kmalloc_aligned_oob_write+0x57/0x184
     kunit_try_run_case+0x61/0xa0
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x176/0x1b0
     ret_from_fork+0x22/0x30

CPU: 7 PID: 502 Comm: kunit_try_catch Bị nhiễm độc: G B 5.13.0-rc3+ #7
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

Đối với những lỗi như vậy, địa chỉ nơi xảy ra lỗi cũng như địa chỉ
byte được ghi không hợp lệ (bù từ địa chỉ) được hiển thị; trong này
đại diện, '.' biểu thị các byte chưa được chạm tới. Trong ví dụ trên ZZ0000ZZ là
giá trị được ghi vào địa chỉ không hợp lệ ở offset 0 và phần còn lại '.'
biểu thị rằng không có byte tiếp theo nào được chạm vào. Lưu ý rằng, giá trị thực là
chỉ hiển thị nếu kernel được khởi động bằng ZZ0001ZZ; để tránh
tiết lộ thông tin nếu không, '!' được sử dụng thay thế để biểu thị không hợp lệ
byte được viết.

Và cuối cùng, KFENCE cũng có thể báo cáo về các truy cập không hợp lệ vào bất kỳ trang được bảo vệ nào
trong trường hợp không thể xác định đối tượng liên quan, ví dụ: nếu liền kề
các trang đối tượng chưa được phân bổ::

=======================================================================
    BUG: KFENCE: đọc không hợp lệ trong test_invalid_access+0x26/0xe0

Đọc không hợp lệ ở 0xffffffffb670b00a:
     test_invalid_access+0x26/0xe0
     kunit_try_run_case+0x51/0x85
     kunit_generic_run_threadfn_adapter+0x16/0x30
     kthread+0x137/0x160
     ret_from_fork+0x22/0x30

CPU: 4 PID: 124 Comm: kunit_try_catch Bị nhiễm độc: G W 5.8.0-rc6+ #7
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.13.0-1 04/01/2014
    =======================================================================

Giao diện gỡ lỗiFS
~~~~~~~~~~~~~~~~~~

Một số thông tin gỡ lỗi được hiển thị thông qua debugfs:

* Tệp ZZ0000ZZ cung cấp số liệu thống kê thời gian chạy.

* File ZZ0000ZZ cung cấp danh sách các đối tượng
  được phân bổ thông qua KFENCE, bao gồm cả những thứ đã được giải phóng nhưng được bảo vệ.

Chi tiết triển khai
----------------------

Phân bổ bảo vệ được thiết lập dựa trên khoảng thời gian mẫu. Sau khi hết hạn
của khoảng thời gian mẫu, lần phân bổ tiếp theo thông qua bộ cấp phát chính (SLAB hoặc
SLUB) trả về một phân bổ được bảo vệ từ nhóm đối tượng KFENCE (phân bổ
kích thước lên tới PAGE_SIZE được hỗ trợ). Tại thời điểm này, bộ đếm thời gian được đặt lại và
phân bổ tiếp theo được thiết lập sau khi hết khoảng thời gian.

Khi sử dụng ZZ0000ZZ, phân bổ KFENCE bị "kiểm soát"
thông qua đường dẫn nhanh của bộ cấp phát chính bằng cách dựa vào các nhánh tĩnh thông qua
cơ sở hạ tầng khóa tĩnh. Nhánh tĩnh được chuyển đổi để chuyển hướng
phân bổ cho KFENCE. Tùy thuộc vào khoảng thời gian lấy mẫu, khối lượng công việc mục tiêu và
kiến trúc hệ thống, điều này có thể hoạt động tốt hơn nhánh động đơn giản.
Điểm chuẩn cẩn thận được khuyến khích.

Mỗi đối tượng KFENCE nằm trên một trang chuyên dụng, ở bên trái hoặc bên phải
ranh giới trang được chọn ngẫu nhiên. Các trang bên trái và bên phải của
trang đối tượng là "trang bảo vệ", có thuộc tính được thay đổi thành trang được bảo vệ
trạng thái và gây ra lỗi trang khi cố gắng truy cập. Những lỗi trang như vậy là
bị chặn bởi KFENCE, xử lý lỗi một cách khéo léo bằng cách báo cáo
truy cập ngoài giới hạn và đánh dấu trang là có thể truy cập được để lỗi
mã có thể (sai) tiếp tục thực thi (thay vào đó đặt ZZ0000ZZ thành hoảng loạn).

Để phát hiện việc ghi ngoài giới hạn vào bộ nhớ trong chính trang của đối tượng,
KFENCE cũng sử dụng các vùng đỏ dựa trên mẫu. Đối với mỗi trang đối tượng, một vùng đỏ được đặt
lên cho tất cả bộ nhớ phi đối tượng. Đối với sự sắp xếp điển hình, vùng đỏ chỉ
được yêu cầu ở phía không được bảo vệ của một đối tượng. Bởi vì KFENCE phải tôn vinh
căn chỉnh được yêu cầu của bộ đệm, những căn chỉnh đặc biệt có thể dẫn đến những khoảng trống không được bảo vệ
ở hai bên của một vật thể, tất cả đều được khoanh vùng lại.

Hình dưới đây minh họa cách bố trí trang::

---+----------+-------------+----------+----------+----------+---
       ZZ0000ZZ O : ZZ0001ZZ : O ZZ0002ZZ
       ZZ0003ZZ B : ZZ0004ZZ : B ZZ0005ZZ
       ZZ0006ZZ J : RED- ZZ0007ZZ RED- : J ZZ0008ZZ
       ZZ0009ZZ E : ZONE ZZ0010ZZ ZONE : E ZZ0011ZZ
       ZZ0012ZZ C : ZZ0013ZZ : C ZZ0014ZZ
       ZZ0015ZZ T : ZZ0016ZZ : T ZZ0017ZZ
    ---+----------+-------------+----------+----------+----------+---

Khi hủy phân bổ đối tượng KFENCE, trang của đối tượng đó lại được bảo vệ và
đối tượng được đánh dấu là đã giải phóng. Bất kỳ quyền truy cập nào vào đối tượng đều gây ra lỗi
và KFENCE báo cáo quyền truy cập sử dụng miễn phí. Freed objects are inserted at the
đuôi danh sách tự do của KFENCE, để các đối tượng được giải phóng gần đây nhất được sử dụng lại
đầu tiên và cơ hội phát hiện việc sử dụng sau khi giải phóng các đối tượng được giải phóng gần đây
được tăng lên.

Nếu mức sử dụng nhóm đạt 75% (mặc định) hoặc cao hơn, để giảm rủi ro
nhóm cuối cùng bị chiếm dụng hoàn toàn bởi các đối tượng được phân bổ nhưng vẫn đảm bảo tính đa dạng
phạm vi phân bổ, các giới hạn KFENCE hiện được áp dụng cho việc phân bổ
cùng một nguồn từ việc tiếp tục lấp đầy hồ bơi. "Nguồn" của việc phân bổ là
dựa trên dấu vết ngăn xếp phân bổ một phần của nó. Một tác dụng phụ là điều này cũng
giới hạn phân bổ lâu dài thường xuyên (ví dụ: pagecache) của cùng một nguồn
làm đầy hồ bơi vĩnh viễn, đây là rủi ro phổ biến nhất đối với hồ bơi
trở nên đầy đủ và tỷ lệ phân bổ được lấy mẫu giảm xuống 0. Ngưỡng
at which to start limiting currently covered allocations can be configured via
tham số khởi động ZZ0000ZZ (sử dụng nhóm%).

Giao diện
---------

Phần sau đây mô tả các chức năng được sử dụng bởi người cấp phát cũng như
mã xử lý trang để thiết lập và xử lý việc phân bổ KFENCE.

.. kernel-doc:: include/linux/kfence.h
   :functions: is_kfence_address
               kfence_shutdown_cache
               kfence_alloc kfence_free __kfence_free
               kfence_ksize kfence_object_start
               kfence_handle_page_fault

Công cụ liên quan
-----------------

Trong không gian người dùng, ZZ0000ZZ cũng áp dụng cách tiếp cận tương tự. GWP-ASan cũng dựa vào các trang bảo vệ và
chiến lược lấy mẫu để phát hiện lỗi không an toàn bộ nhớ trên quy mô lớn. Thiết kế của KFENCE là
chịu ảnh hưởng trực tiếp bởi GWP-ASan và có thể được coi là anh chị em hạt nhân của nó. Khác
cách tiếp cận tương tự nhưng không lấy mẫu, cũng lấy cảm hứng từ cái tên "KFENCE", có thể
được tìm thấy trong không gian người dùng ZZ0001ZZ.

Trong kernel, có một số công cụ để gỡ lỗi truy cập bộ nhớ và trong
KASAN cụ thể có thể phát hiện tất cả các loại lỗi mà KFENCE có thể phát hiện. Trong khi KASAN
chính xác hơn, dựa vào công cụ biên dịch, điều này xảy ra ở mức
chi phí hiệu suất.

Điều đáng nhấn mạnh là KASAN và KFENCE là bổ sung cho nhau, với
môi trường mục tiêu khác nhau. Ví dụ: KASAN là công cụ hỗ trợ sửa lỗi tốt hơn,
nơi tồn tại các ca kiểm thử hoặc bản sao chép: do cơ hội phát hiện ra phiên bản thử nghiệm thấp hơn
lỗi, sẽ cần nhiều nỗ lực hơn khi sử dụng KFENCE để gỡ lỗi. Triển khai ở quy mô
tuy nhiên, không đủ khả năng kích hoạt KASAN sẽ được hưởng lợi từ việc sử dụng KFENCE để
phát hiện các lỗi do đường dẫn mã không được thực hiện bởi các trường hợp kiểm thử hoặc bộ làm mờ.