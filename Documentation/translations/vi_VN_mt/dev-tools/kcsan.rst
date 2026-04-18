.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/kcsan.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright (C) 2019, Google LLC.

Bộ khử trùng đồng thời hạt nhân (KCSAN)
=======================================

Kernel Concurrency Sanitizer (KCSAN) là một công cụ phát hiện chủng tộc động,
dựa vào công cụ đo thời gian biên dịch và sử dụng lấy mẫu dựa trên điểm quan sát
phương pháp phát hiện chủng tộc. Mục đích chính của KCSAN là phát hiện ZZ0000ZZ.

Cách sử dụng
------------

KCSAN được hỗ trợ bởi cả GCC và Clang. Với GCC, chúng tôi yêu cầu phiên bản 11 hoặc
sau này và với Clang cũng yêu cầu phiên bản 11 trở lên.

Để kích hoạt KCSAN, hãy định cấu hình kernel bằng::

CONFIG_KCSAN = y

KCSAN cung cấp một số tùy chọn cấu hình khác để tùy chỉnh hành vi (xem
văn bản trợ giúp tương ứng trong ZZ0000ZZ để biết thêm thông tin).

Báo cáo lỗi
~~~~~~~~~~~~~

Một báo cáo cuộc đua dữ liệu điển hình trông như thế này::

=======================================================================
    BUG: KCSAN: cuộc đua dữ liệu trong test_kernel_read / test_kernel_write

ghi vào 0xffffffffc009a628 trong số 8 byte theo tác vụ 487 trên cpu 0:
     test_kernel_write+0x1d/0x30
     access_thread+0x89/0xd0
     kthread+0x23e/0x260
     ret_from_fork+0x22/0x30

đọc tới 0xffffffffc009a628 trong số 8 byte theo tác vụ 488 trên cpu 6:
     test_kernel_read+0x10/0x20
     access_thread+0x89/0xd0
     kthread+0x23e/0x260
     ret_from_fork+0x22/0x30

giá trị đã thay đổi: 0x00000000000009a6 -> 0x00000000000009b2

Được báo cáo bởi Kernel Concurrency Sanitizer về:
    CPU: 6 PID: 488 Comm: access_thread Không bị nhiễm độc 5.12.0-rc2+ #1
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

Tiêu đề của báo cáo cung cấp một bản tóm tắt ngắn gọn về các chức năng liên quan đến
cuộc đua. Tiếp theo là các kiểu truy cập và dấu vết ngăn xếp của 2 luồng
tham gia vào cuộc đua dữ liệu Nếu KCSAN cũng quan sát thấy sự thay đổi giá trị thì giá trị được quan sát
giá trị cũ và giá trị mới lần lượt được hiển thị trên dòng "giá trị đã thay đổi".

Loại báo cáo cuộc đua dữ liệu khác ít phổ biến hơn trông như thế này::

=======================================================================
    BUG: KCSAN: cuộc đua dữ liệu trong test_kernel_rmw_array+0x71/0xd0

đua không rõ nguồn gốc, với khả năng đọc tới 0xffffffffc009bdb0 là 8 byte theo tác vụ 515 trên cpu 2:
     test_kernel_rmw_array+0x71/0xd0
     access_thread+0x89/0xd0
     kthread+0x23e/0x260
     ret_from_fork+0x22/0x30

giá trị đã thay đổi: 0x0000000000002328 -> 0x0000000000002329

Được báo cáo bởi Kernel Concurrency Sanitizer về:
    CPU: 2 PID: 515 Comm: access_thread Không bị nhiễm độc 5.12.0-rc2+ #1
    Tên phần cứng: QEMU PC tiêu chuẩn (i440FX + PIIX, 1996), BIOS 1.14.0-2 04/01/2014
    =======================================================================

Báo cáo này được tạo khi không thể xác định được báo cáo khác
chủ đề đua xe, nhưng một cuộc đua đã được suy ra do giá trị dữ liệu của nội dung đã xem
vị trí bộ nhớ đã thay đổi. Các báo cáo này luôn hiển thị "giá trị đã thay đổi"
dòng. Lý do phổ biến cho các báo cáo loại này là thiếu công cụ đo lường trong
chủ đề đua xe, nhưng cũng có thể xảy ra do ví dụ: Truy cập DMA. Những báo cáo như vậy
chỉ được hiển thị nếu ZZ0000ZZ, tức là
được bật theo mặc định.

Phân tích chọn lọc
~~~~~~~~~~~~~~~~~~

Có thể nên tắt tính năng phát hiện cuộc đua dữ liệu đối với các quyền truy cập cụ thể,
chức năng, đơn vị biên dịch hoặc toàn bộ hệ thống con.  Đối với danh sách đen tĩnh,
các tùy chọn dưới đây có sẵn:

* KCSAN hiểu chú thích ZZ0000ZZ, chú thích này cho KCSAN biết rằng
  mọi cuộc đua dữ liệu do quyền truy cập vào ZZ0001ZZ sẽ bị bỏ qua và dẫn đến
  hành vi khi gặp phải cuộc đua dữ liệu được coi là an toàn.  Xin vui lòng xem
  ZZ0002ZZ để biết thêm thông tin.

* Tương tự như ZZ0000ZZ, có thể sử dụng bộ định loại ZZ0001ZZ
  để ghi lại rằng tất cả các cuộc đua dữ liệu do quyền truy cập vào một biến đều nhằm mục đích
  và nên được KCSAN bỏ qua::

cấu trúc foo {
        ...
int __data_racy stats_counter;
        ...
    };

* Việc tắt tính năng phát hiện xung đột dữ liệu cho toàn bộ chức năng có thể được thực hiện bằng cách
  sử dụng thuộc tính hàm ZZ0000ZZ::

__no_kcsan
    void foo(void) {
        ...

Để giới hạn động những chức năng nào sẽ tạo báo cáo, hãy xem phần
  Tính năng danh sách đen/danh sách trắng của ZZ0000ZZ.

* Để tắt tính năng phát hiện cuộc đua dữ liệu cho một đơn vị biên dịch cụ thể, hãy thêm vào
  ZZ0000ZZ::

KCSAN_SANITIZE_file.o := n

* Để tắt tính năng phát hiện chủng tộc dữ liệu cho tất cả các đơn vị biên dịch được liệt kê trong một
  ZZ0000ZZ, thêm vào ZZ0001ZZ tương ứng::

KCSAN_SANITIZE := n

.. _"Marking Shared-Memory Accesses" in the LKMM: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/memory-model/Documentation/access-marking.txt

Hơn nữa, có thể yêu cầu KCSAN hiển thị hoặc ẩn toàn bộ các lớp
cuộc đua dữ liệu, tùy thuộc vào sở thích. Những điều này có thể được thay đổi thông qua những điều sau đây
Tùy chọn Kconfig:

* ZZ0000ZZ: Nếu được bật và ghi xung đột
  được quan sát thông qua một điểm theo dõi, nhưng giá trị dữ liệu của vị trí bộ nhớ là
  được quan sát là không thay đổi, không báo cáo cuộc đua dữ liệu.

* ZZ0000ZZ: Giả sử rằng thao tác ghi được căn chỉnh đơn giản
  kích thước tối đa từ là nguyên tử theo mặc định. Giả sử rằng việc viết như vậy là không
  tùy thuộc vào việc tối ưu hóa trình biên dịch không an toàn dẫn đến chạy đua dữ liệu. tùy chọn
  khiến KCSAN không báo cáo các cuộc đua dữ liệu do xung đột trong đó đơn giản duy nhất
  quyền truy cập được căn chỉnh ghi theo kích thước từ.

* ZZ0000ZZ: Cho phép bỏ qua các quy tắc cho phép bổ sung
  một số loại cuộc đua dữ liệu phổ biến. Không giống như trên, các quy tắc có nhiều
  phức tạp liên quan đến các mẫu thay đổi giá trị, loại truy cập và địa chỉ. Cái này
  tùy chọn phụ thuộc vào ZZ0001ZZ. Để biết chi tiết
  vui lòng xem ZZ0002ZZ. Người kiểm tra và người bảo trì
  chỉ tập trung vào các báo cáo từ các hệ thống con cụ thể chứ không phải toàn bộ kernel
  đề nghị tắt tùy chọn này.

Để sử dụng các quy tắc chặt chẽ nhất có thể, hãy chọn ZZ0000ZZ,
định cấu hình KCSAN để tuân theo mô hình nhất quán bộ nhớ nhân Linux (LKMM) như
chặt chẽ nhất có thể.

Giao diện gỡ lỗiFS
~~~~~~~~~~~~~~~~~~

Tệp ZZ0000ZZ cung cấp giao diện sau:

* Đọc ZZ0000ZZ trả về nhiều số liệu thống kê thời gian chạy khác nhau.

* Viết ZZ0000ZZ hoặc ZZ0001ZZ vào ZZ0002ZZ cho phép chuyển KCSAN
  bật hoặc tắt tương ứng.

* Viết ZZ0000ZZ vào ZZ0001ZZ sẽ thêm
  ZZ0002ZZ vào danh sách bộ lọc báo cáo, danh sách đen (theo mặc định)
  báo cáo các cuộc đua dữ liệu trong đó một trong các khung ngăn xếp hàng đầu là một chức năng
  trong danh sách.

* Viết ZZ0000ZZ hoặc ZZ0001ZZ vào ZZ0002ZZ
  thay đổi hành vi lọc báo cáo. Ví dụ: tính năng danh sách đen
  có thể được sử dụng để tắt các cuộc đua dữ liệu thường xuyên xảy ra; tính năng danh sách trắng
  có thể giúp tái tạo và thử nghiệm các bản sửa lỗi.

Hiệu suất điều chỉnh
~~~~~~~~~~~~~~~~~~~~

Các thông số cốt lõi ảnh hưởng đến hiệu suất tổng thể và phát hiện lỗi của KCSAN
khả năng được hiển thị dưới dạng các đối số dòng lệnh kernel mà giá trị mặc định của chúng cũng có thể là
đã thay đổi thông qua các tùy chọn Kconfig tương ứng.

* ZZ0000ZZ (ZZ0001ZZ): Số lượng bộ nhớ trên mỗi CPU
  bỏ qua các hoạt động trước khi thiết lập điểm quan sát khác. Đang thiết lập
  các điểm quan sát thường xuyên hơn sẽ dẫn đến khả năng xảy ra các cuộc đua
  được quan sát thấy tăng lên. Thông số này có ảnh hưởng lớn nhất đến
  hiệu suất tổng thể của hệ thống và khả năng phát hiện chủng tộc.

* ZZ0000ZZ (ZZ0001ZZ): Đối với các tác vụ,
  độ trễ micro giây để ngừng thực thi sau khi thiết lập điểm theo dõi.
  Các giá trị lớn hơn dẫn đến khoảng thời gian mà chúng ta có thể quan sát một cuộc đua
  tăng lên.

* ZZ0000ZZ (ZZ0001ZZ): Dành cho
  bị gián đoạn, độ trễ micro giây để ngừng thực thi sau khi điểm quan sát đã kết thúc
  đã được thiết lập. Các ngắt có yêu cầu về độ trễ chặt chẽ hơn và độ trễ của chúng
  thường phải nhỏ hơn cái được chọn cho nhiệm vụ.

Chúng có thể được điều chỉnh trong thời gian chạy thông qua ZZ0000ZZ.

Cuộc đua dữ liệu
----------------

Trong quá trình thực thi, hai lần truy cập bộ nhớ sẽ tạo thành ZZ0001ZZ nếu chúng là ZZ0002ZZ,
chúng xảy ra đồng thời trong các luồng khác nhau và ít nhất một trong số đó là
ZZ0003ZZ; chúng là ZZ0004ZZ nếu cả hai đều truy cập vào cùng một vị trí bộ nhớ và tại
ít nhất một là viết. Để biết thảo luận và định nghĩa kỹ lưỡng hơn, hãy xem ZZ0000ZZ.

.. _"Plain Accesses and Data Races" in the LKMM: https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/tools/memory-model/Documentation/explanation.txt?id=8f6629c004b193d23612641c3607e785819e97ab#n2164

Mối quan hệ với Mô hình nhất quán bộ nhớ Linux-Kernel (LKMM)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

LKMM xác định các quy tắc truyền bá và sắp xếp của các bộ nhớ khác nhau
hoạt động, cung cấp cho các nhà phát triển khả năng suy luận về mã đồng thời.
Cuối cùng, điều này cho phép xác định khả năng thực thi mã đồng thời,
và liệu mã đó có thoát khỏi cuộc đua dữ liệu hay không.

KCSAN biết về ZZ0009ZZ (ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ, v.v.) và một tập hợp con các đảm bảo về thứ tự được ngụ ý bởi bộ nhớ
rào cản. Với các mẫu ZZ0003ZZ, KCSAN tải hoặc lưu trữ
đệm và có thể phát hiện ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ bị thiếu,
ZZ0007ZZ và tất cả các hoạt động ZZ0008ZZ tương đương
những rào cản ngụ ý.

Lưu ý, KCSAN sẽ không báo cáo tất cả các cuộc đua dữ liệu do thiếu thứ tự bộ nhớ,
đặc biệt là ở những nơi cần có rào cản bộ nhớ để cấm các hoạt động tiếp theo
hoạt động bộ nhớ từ việc sắp xếp lại trước rào cản. Các nhà phát triển nên
do đó hãy xem xét cẩn thận các yêu cầu sắp xếp bộ nhớ cần thiết mà
vẫn không được kiểm tra.

Phát hiện cuộc đua ngoài cuộc đua dữ liệu
-----------------------------------------

Đối với mã có thiết kế đồng thời phức tạp, lỗi điều kiện chủng tộc có thể không phải lúc nào cũng
biểu hiện dưới dạng các cuộc đua dữ liệu. Điều kiện chạy đua xảy ra nếu thực hiện đồng thời
hoạt động dẫn đến hành vi hệ thống không mong muốn. Mặt khác, cuộc đua dữ liệu
được xác định ở cấp độ ngôn ngữ C. Các macro sau có thể được sử dụng để kiểm tra
thuộc tính của mã đồng thời trong đó lỗi sẽ không biểu hiện dưới dạng cuộc đua dữ liệu.

.. kernel-doc:: include/linux/kcsan-checks.h
    :functions: ASSERT_EXCLUSIVE_WRITER ASSERT_EXCLUSIVE_WRITER_SCOPED
                ASSERT_EXCLUSIVE_ACCESS ASSERT_EXCLUSIVE_ACCESS_SCOPED
                ASSERT_EXCLUSIVE_BITS

Chi tiết triển khai
----------------------

KCSAN dựa vào việc quan sát hai truy cập xảy ra đồng thời. Điều quan trọng là chúng tôi
muốn (a) tăng cơ hội quan sát các cuộc đua (đặc biệt đối với các cuộc đua
hiếm khi biểu hiện) và (b) có thể thực sự quan sát chúng. Chúng ta có thể hoàn thành
(a) bằng cách đưa vào các độ trễ khác nhau và (b) bằng cách sử dụng các điểm giám sát địa chỉ (hoặc
điểm dừng).

Nếu chúng ta cố tình trì hoãn việc truy cập bộ nhớ trong khi chúng ta có điểm theo dõi
địa chỉ được thiết lập và sau đó quan sát điểm quan sát để kích hoạt, hai quyền truy cập vào
cùng một địa chỉ vừa chạy đua. Sử dụng các điểm theo dõi phần cứng, đây là cách tiếp cận được thực hiện
trong ZZ0000ZZ.
Không giống như DataCollider, KCSAN không sử dụng điểm theo dõi phần cứng mà thay vào đó
dựa vào công cụ biên dịch và "điểm quan sát mềm".

Trong KCSAN, các điểm theo dõi được triển khai bằng cách sử dụng mã hóa hiệu quả để lưu trữ
loại truy cập, kích thước và địa chỉ trong một thời gian dài; lợi ích của việc sử dụng "mềm
điểm quan sát" là tính di động và tính linh hoạt cao hơn. KCSAN sau đó dựa vào
truy cập đơn giản của công cụ biên dịch. Đối với mỗi quyền truy cập đơn giản được đo lường:

1. Kiểm tra xem có tồn tại điểm theo dõi phù hợp hay không; nếu có, và ít nhất một quyền truy cập là
   write, sau đó chúng tôi gặp phải một cuộc đua truy cập.

2. Định kỳ, nếu không có điểm theo dõi phù hợp, hãy thiết lập điểm theo dõi và
   dừng lại trong một độ trễ ngẫu nhiên nhỏ.

3. Đồng thời kiểm tra giá trị dữ liệu trước độ trễ và kiểm tra lại giá trị dữ liệu
   sau khi trì hoãn; nếu các giá trị không khớp, chúng tôi suy ra một chủng tộc không rõ nguồn gốc.

Để phát hiện các cuộc đua dữ liệu giữa các truy cập đơn giản và được đánh dấu, KCSAN cũng chú thích
các quyền truy cập được đánh dấu, nhưng chỉ để kiểm tra xem điểm theo dõi có tồn tại hay không; tức là KCSAN không bao giờ
thiết lập một điểm theo dõi trên các truy cập được đánh dấu. Bằng cách không bao giờ thiết lập các điểm theo dõi cho
các hoạt động được đánh dấu, nếu tất cả quyền truy cập vào một biến được truy cập đồng thời
được đánh dấu chính xác, KCSAN sẽ không bao giờ kích hoạt điểm theo dõi và do đó không bao giờ
báo cáo các truy cập.

Mô hình hóa trí nhớ yếu
~~~~~~~~~~~~~~~~~~~~~~~

Phương pháp tiếp cận của KCSAN để phát hiện các cuộc chạy đua dữ liệu do thiếu rào cản bộ nhớ là
dựa trên việc sắp xếp lại thứ tự truy cập mô hình (với ZZ0000ZZ).
Mỗi quyền truy cập bộ nhớ đơn giản mà điểm theo dõi được thiết lập cũng được chọn cho
sắp xếp lại mô phỏng trong phạm vi chức năng của nó (tối đa 1 lần trong chuyến bay
truy cập).

Khi một quyền truy cập đã được chọn để sắp xếp lại, nó sẽ được kiểm tra theo mọi
truy cập khác cho đến khi kết thúc phạm vi chức năng. Nếu một bộ nhớ thích hợp
gặp phải rào cản, quyền truy cập sẽ không còn được xem xét cho mô phỏng
sắp xếp lại.

Khi kết quả của hoạt động bộ nhớ phải được sắp xếp theo rào cản, KCSAN có thể
sau đó phát hiện các cuộc đua dữ liệu trong đó xung đột chỉ xảy ra do thiếu
rào cản. Hãy xem xét ví dụ::

int x, cờ;
    khoảng trống T1(khoảng trống)
    {
        x = 1;                  // cuộc đua dữ liệu!
        WRITE_ONCE(cờ, 1);    // đúng: smp_store_release(&flag, 1)
    }
    khoảng trống T2(khoảng trống)
    {
        while (!READ_ONCE(cờ));   // đúng: smp_load_acquire(&flag)
        ... = x;                    // data race!
    }

Khi mô hình bộ nhớ yếu được bật, KCSAN có thể xem xét ZZ0000ZZ trong ZZ0001ZZ cho
sắp xếp lại mô phỏng. Sau khi ghi ZZ0002ZZ, ZZ0003ZZ lại được kiểm tra
truy cập đồng thời: vì ZZ0004ZZ có thể tiếp tục sau khi ghi
ZZ0005ZZ, phát hiện cuộc đua dữ liệu. Với các rào cản chính xác được đặt đúng chỗ, ZZ0006ZZ
sẽ không được xem xét sắp xếp lại sau khi phát hành ZZ0007ZZ hợp lệ,
và không có cuộc đua dữ liệu nào được phát hiện.

Sự đánh đổi có chủ ý về độ phức tạp nhưng cũng có những hạn chế thực tế chỉ có nghĩa là một
có thể phát hiện tập hợp con của các cuộc đua dữ liệu do thiếu rào cản bộ nhớ. Với
hỗ trợ trình biên dịch hiện có sẵn, việc triển khai được giới hạn ở mô hình hóa
ảnh hưởng của việc "lưu vào bộ nhớ đệm" (làm chậm truy cập), vì thời gian chạy không thể
truy cập "tìm nạp trước". Cũng nhớ lại rằng các điểm theo dõi chỉ được thiết lập cho đồng bằng
quyền truy cập và loại quyền truy cập duy nhất mà KCSAN mô phỏng việc sắp xếp lại. Cái này
có nghĩa là sắp xếp lại các truy cập được đánh dấu không được mô hình hóa.

Hệ quả của điều trên là các hoạt động thu mua không yêu cầu rào cản
thiết bị đo đạc (không tìm nạp trước). Hơn nữa, các truy cập được đánh dấu giới thiệu
các phụ thuộc địa chỉ hoặc điều khiển không yêu cầu xử lý đặc biệt (được đánh dấu
quyền truy cập không thể được sắp xếp lại, các quyền truy cập phụ thuộc sau này không thể được tìm nạp trước).

Thuộc tính chính
~~~~~~~~~~~~~~~~

1. ZZ0000ZZ Tổng chi phí bộ nhớ chỉ bằng vài MiB
   tùy thuộc vào cấu hình. Việc triển khai hiện tại sử dụng một mảng nhỏ
   mong muốn mã hóa thông tin về điểm quan sát, điều này không đáng kể.

2. Thời gian chạy của ZZ0000ZZ KCSAN hướng tới mức tối thiểu, sử dụng
   mã hóa điểm quan sát hiệu quả mà không yêu cầu thu thập bất kỳ thông tin chia sẻ nào
   khóa trong đường dẫn nhanh. Để khởi động kernel trên hệ thống có 8 CPU:

- Giảm tốc độ 5,0 lần với cấu hình KCSAN mặc định;
   - Giảm tốc độ 2,8 lần so với chi phí đường dẫn nhanh thời gian chạy (được đặt rất lớn
     ZZ0000ZZ và bỏ đặt ZZ0001ZZ).

3. ZZ0000ZZ Cần có chú thích tối thiểu bên ngoài KCSAN
   thời gian chạy. Kết quả là, chi phí bảo trì là tối thiểu vì kernel
   phát triển.

4. ZZ0000ZZ Do kiểm tra giá trị dữ liệu theo
   thiết lập điểm theo dõi, ghi không phù hợp từ thiết bị cũng có thể được phát hiện.

5. ZZ0000ZZ KCSAN chỉ biết một tập hợp con các quy tắc đặt hàng LKMM;
   điều này có thể dẫn đến việc bỏ lỡ các cuộc đua dữ liệu (âm tính giả).

6. ZZ0000ZZ Đối với các lần thực thi được quan sát, do sử dụng mẫu
   chiến lược, phân tích là ZZ0001ZZ (có thể âm tính giả), nhưng nhằm mục đích
   phải đầy đủ (không có kết quả dương tính giả).

Các lựa chọn thay thế được xem xét
----------------------------------

Có thể tìm thấy một phương pháp phát hiện xung đột dữ liệu thay thế cho kernel trong
ZZ0000ZZ.
KTSAN là một công cụ phát hiện cuộc đua dữ liệu xảy ra trước đó, thiết lập rõ ràng
Thứ tự xảy ra trước giữa các thao tác bộ nhớ, sau đó có thể được sử dụng để
xác định các chủng tộc dữ liệu như được xác định trong ZZ0001ZZ.

Để xây dựng mối quan hệ xảy ra trước chính xác, KTSAN phải nhận thức được tất cả các thứ tự
các quy tắc của LKMM và nguyên tắc đồng bộ hóa. Thật không may, bất kỳ sự thiếu sót nào
dẫn đến số lượng lớn các kết quả dương tính giả, điều này đặc biệt có hại trong
bối cảnh của kernel bao gồm nhiều đồng bộ hóa tùy chỉnh
cơ chế. Để theo dõi mối quan hệ xảy ra trước đó, việc triển khai KTSAN
yêu cầu siêu dữ liệu cho từng vị trí bộ nhớ (bộ nhớ tối), cho mỗi trang
tương ứng với 4 trang của bộ nhớ ẩn và có thể chuyển thành chi phí chung của
hàng chục GiB trên một hệ thống lớn.