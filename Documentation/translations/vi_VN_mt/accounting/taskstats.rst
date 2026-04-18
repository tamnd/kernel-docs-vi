.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/accounting/taskstats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
Giao diện thống kê theo từng nhiệm vụ
=====================================


Taskstats là một giao diện dựa trên liên kết mạng để gửi từng tác vụ và
thống kê trên mỗi tiến trình từ kernel đến không gian người dùng.

Taskstats được thiết kế vì những lợi ích sau:

- cung cấp số liệu thống kê hiệu quả trong suốt thời gian tồn tại của một nhiệm vụ và khi thoát khỏi nó
- giao diện thống nhất cho nhiều hệ thống con kế toán
- khả năng mở rộng để sử dụng bởi các bản vá kế toán trong tương lai

Thuật ngữ
-----------

"pid", "tid" và "task" được sử dụng thay thế cho nhau và tham khảo tiêu chuẩn
Nhiệm vụ Linux được xác định bởi struct task_struct.  số liệu thống kê trên mỗi pid giống như
thống kê theo từng nhiệm vụ.

"tgid", "process" và "thread group" được sử dụng thay thế cho nhau và đề cập đến
các tác vụ chia sẻ mm_struct tức là quy trình Unix truyền thống. Mặc dù
sử dụng tgid, không có cách xử lý đặc biệt nào cho tác vụ là nhóm luồng
người lãnh đạo - một quá trình được coi là còn sống miễn là nó có bất kỳ nhiệm vụ nào thuộc về nó.

Cách sử dụng
------------

Để lấy số liệu thống kê trong suốt vòng đời của một tác vụ, không gian người dùng sẽ mở một liên kết mạng đơn hướng
socket (họ NETLINK_GENERIC) và gửi lệnh chỉ định pid hoặc tgid.
Phản hồi chứa số liệu thống kê cho một tác vụ (nếu pid được chỉ định) hoặc tổng của
thống kê cho tất cả các tác vụ của tiến trình (nếu tgid được chỉ định).

Để có được số liệu thống kê cho các tác vụ đang thoát, trình nghe không gian người dùng
gửi lệnh đăng ký và chỉ định cpumask. Bất cứ khi nào một tác vụ thoát ra
một trong các CPU trong cpumask, số liệu thống kê trên mỗi pid của nó sẽ được gửi tới
người nghe đã đăng ký. Sử dụng cpumasks cho phép một người nghe nhận được dữ liệu
bị hạn chế và hỗ trợ kiểm soát luồng qua giao diện netlink và được
được giải thích chi tiết hơn dưới đây.

Nếu tác vụ thoát là luồng cuối cùng thoát khỏi nhóm luồng của nó,
một bản ghi bổ sung chứa số liệu thống kê trên mỗi tgid cũng được gửi đến không gian người dùng.
Cái sau chứa tổng số liệu thống kê trên mỗi pid cho tất cả các luồng trong luồng
nhóm, cả quá khứ và hiện tại.

getdelays.c là một tiện ích đơn giản thể hiện việc sử dụng giao diện taskstats
để báo cáo số liệu thống kê kế toán chậm trễ. Người dùng có thể đăng ký cpumasks,
gửi lệnh và xử lý phản hồi, lắng nghe dữ liệu thoát theo mỗi tid/tgid,
ghi dữ liệu nhận được vào một tập tin và thực hiện kiểm soát luồng cơ bản bằng cách tăng
nhận kích thước bộ đệm.

Giao diện
---------

Giao diện nhân-người dùng được gói gọn trong include/linux/taskstats.h

Để tránh tài liệu này trở nên lỗi thời khi giao diện phát triển, chỉ
một phác thảo của phiên bản hiện tại được đưa ra. taskstats.h luôn ghi đè
mô tả ở đây.

struct taskstats là cấu trúc kế toán chung cho cả per-pid và
dữ liệu trên mỗi tgid. Nó được phiên bản hóa và có thể được mở rộng bởi mỗi hệ thống con kế toán
được thêm vào kernel. Các trường và ngữ nghĩa của chúng được xác định trong
tập tin taskstats.h.

Dữ liệu được trao đổi giữa không gian người dùng và kernel là một thông điệp liên kết mạng thuộc về
vào họ NETLINK_GENERIC và sử dụng giao diện thuộc tính liên kết mạng.
Các tin nhắn có định dạng::

+----------+- - -+-------------+----------+
    Tải trọng thống kê tác vụ ZZ0000ZZ Pad ZZ0001ZZ |
    +----------+- - -+-------------+----------+


Tải trọng taskstats là một trong ba loại sau:

1. Lệnh: Gửi từ người dùng đến kernel. Các lệnh lấy dữ liệu
   một pid/tgid bao gồm một thuộc tính, thuộc loại TASKSTATS_CMD_ATTR_PID/TGID,
   chứa u32 pid hoặc tgid trong tải trọng thuộc tính. pid/tgid biểu thị
   nhiệm vụ/quy trình mà không gian người dùng muốn thống kê.

Các lệnh đăng ký/hủy đăng ký quan tâm đến dữ liệu thoát khỏi một bộ cpu
   bao gồm một thuộc tính, thuộc loại
   TASKSTATS_CMD_ATTR_REGISTER/DEREGISTER_CPUMASK và chứa cpumask trong
   tải trọng thuộc tính. CPUmask được chỉ định là một chuỗi ascii của
   phạm vi cpu được phân tách bằng dấu phẩy, ví dụ: để nghe dữ liệu thoát khỏi cpu 1,2,3,5,7,8
   cpumask sẽ là "1-3,5,7-8". Nếu không gian người dùng quên hủy đăng ký
   quan tâm đến cpu trước khi đóng socket nghe, kernel dọn dẹp
   lãi suất của nó được thiết lập theo thời gian. Tuy nhiên, vì mục đích hiệu quả, cần có quy định rõ ràng
   hủy đăng ký là điều nên làm.

2. Phản hồi lệnh: được gửi từ kernel để phản hồi tới không gian người dùng
   lệnh. Tải trọng là một chuỗi gồm ba thuộc tính thuộc loại:

a) TASKSTATS_TYPE_AGGR_PID/TGID: thuộc tính không chứa tải trọng nhưng
      cho biết pid/tgid sẽ được theo sau bởi một số số liệu thống kê.

b) TASKSTATS_TYPE_PID/TGID: thuộc tính có tải trọng là pid/tgid có
      số liệu thống kê đang được trả lại.

c) TASKSTATS_TYPE_STATS: thuộc tính có cấu trúc taskstats làm tải trọng. các
      cùng một cấu trúc được sử dụng cho cả số liệu thống kê per-pid và per-tgid.

3. Tin nhắn mới được gửi bởi kernel bất cứ khi nào một tác vụ thoát ra. Tải trọng bao gồm một
   chuỗi các thuộc tính thuộc loại sau:

a) TASKSTATS_TYPE_AGGR_PID: cho biết hai thuộc tính tiếp theo sẽ là pid+stats
   b) TASKSTATS_TYPE_PID: chứa pid của tác vụ đang thoát
   c) TASKSTATS_TYPE_STATS: chứa số liệu thống kê trên mỗi pid của tác vụ đang thoát
   d) TASKSTATS_TYPE_AGGR_TGID: cho biết hai thuộc tính tiếp theo sẽ được
      tgid+số liệu thống kê
   e) TASKSTATS_TYPE_TGID: chứa tgid của tiến trình thuộc nhiệm vụ nào
   f) TASKSTATS_TYPE_STATS: chứa số liệu thống kê trên mỗi tgid để thoát khỏi nhiệm vụ
      quá trình


số liệu thống kê trên mỗi tgid
------------------------------

Thống kê tác vụ cung cấp số liệu thống kê trên mỗi quy trình, ngoài số liệu thống kê trên mỗi tác vụ, vì
quản lý tài nguyên thường được thực hiện ở mức độ chi tiết của quy trình và nhiệm vụ tổng hợp
chỉ riêng số liệu thống kê trong không gian người dùng là không hiệu quả và có khả năng không chính xác (do thiếu
tính nguyên tử).

Tuy nhiên, việc duy trì số liệu thống kê trên mỗi quy trình, ngoài số liệu thống kê trên mỗi nhiệm vụ, trong
kernel có chi phí về không gian và thời gian. Để giải quyết vấn đề này, mã taskstats
tích lũy số liệu thống kê của từng tác vụ đang thoát thành cấu trúc dữ liệu trên toàn quy trình.
Khi tác vụ cuối cùng của một tiến trình thoát ra, dữ liệu cấp tiến trình cũng được tích lũy
được gửi đến không gian người dùng (cùng với dữ liệu trên mỗi tác vụ).

Khi người dùng truy vấn để nhận dữ liệu trên mỗi tgid, tổng của tất cả các luồng trực tiếp khác trong
nhóm được cộng lại và cộng vào tổng số tích lũy đã thoát trước đó
chủ đề của cùng một nhóm chủ đề.

Mở rộng taskstats
-------------------

Có hai cách để mở rộng giao diện taskstats để xuất thêm
số liệu thống kê trên mỗi tác vụ/quy trình dưới dạng các bản vá để thu thập chúng sẽ được thêm vào kernel
trong tương lai:

1. Thêm nhiều trường hơn vào cuối các thống kê tác vụ cấu trúc hiện có. Lùi lại
   khả năng tương thích được đảm bảo bởi số phiên bản trong
   cấu trúc. Không gian người dùng sẽ chỉ sử dụng các trường của cấu trúc tương ứng
   vào phiên bản nó đang sử dụng.

2. Xác định các cấu trúc thống kê riêng biệt và sử dụng các thuộc tính netlink
   giao diện để trả lại chúng. Vì không gian người dùng xử lý từng thuộc tính liên kết mạng
   một cách độc lập, nó luôn có thể bỏ qua các thuộc tính có kiểu không phù hợp
   hiểu (vì nó đang sử dụng phiên bản giao diện cũ hơn).


Lựa chọn giữa 1. và 2. là vấn đề đánh đổi tính linh hoạt và
trên cao. Nếu chỉ cần thêm một vài trường thì 1. là thích hợp hơn
đường dẫn vì kernel và không gian người dùng không cần phải chịu chi phí chung
xử lý các thuộc tính liên kết mạng mới. Nhưng nếu các lĩnh vực mới mở rộng các lĩnh vực hiện có
cấu trúc quá nhiều, đòi hỏi các tiện ích quản lý không gian người dùng khác nhau để
nhận những cấu trúc lớn mà lĩnh vực của chúng không được quan tâm một cách không cần thiết, thì
việc mở rộng cấu trúc thuộc tính sẽ có giá trị.

Kiểm soát luồng cho taskstats
-----------------------------

Khi tốc độ thoát tác vụ trở nên lớn, người nghe có thể không thể giữ được
theo tốc độ gửi dữ liệu thoát mỗi tid/tgid của kernel dẫn đến dữ liệu
mất mát. Khả năng này trở nên phức tạp hơn khi cấu trúc taskstats được
được mở rộng và số lượng CPU ngày càng lớn.

Để tránh mất số liệu thống kê, vùng người dùng nên thực hiện một hoặc nhiều thao tác sau:

- tăng kích thước bộ đệm nhận cho các ổ cắm liên kết mạng được mở bởi
  người nghe để nhận dữ liệu thoát.

- tạo thêm người nghe và giảm số lượng CPU được nghe
  mỗi người nghe. Trong trường hợp cực đoan, có thể có một người nghe cho mỗi CPU.
  Người dùng cũng có thể xem xét việc đặt mối quan hệ CPU của người nghe vào tập hợp con
  số lượng CPU mà nó nghe, đặc biệt nếu chúng chỉ nghe một CPU.

Bất chấp các biện pháp này, nếu không gian người dùng nhận được thông báo lỗi ENOBUFS
được chỉ định tràn bộ đệm nhận, cần có biện pháp để xử lý
mất dữ liệu.
