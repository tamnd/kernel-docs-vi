.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_deadline.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giám sát thời hạn
=================

- Tên: thời hạn
- Loại: hộp đựng nhiều màn hình
- Tác giả: Gabriele Monaco <gmonaco@redhat.com>

Sự miêu tả
-----------

Trình giám sát thời hạn là một tập hợp các thông số kỹ thuật để mô tả thời hạn
hành vi của người lập lịch trình. Nó bao gồm các màn hình cho mỗi thực thể lập kế hoạch (các nhiệm vụ thời hạn
và máy chủ) hoạt động độc lập để xác minh các thông số kỹ thuật khác nhau
người lập lịch trình thời hạn nên tuân theo.

Thông số kỹ thuật
-----------------

Giám sát danh nghĩa
~~~~~~~~~~~~~~~~~~~

Trình giám sát nomiss đảm bảo các thực thể dl có thể chạy ZZ0005ZZ cho đến khi hoàn thành
trước thời hạn của họ, mặc dù các máy chủ có thể trì hoãn có thể không chạy. Một thực thể là
được coi là xong nếu ZZ0000ZZ, vì nó đã mang lại hoặc đã sử dụng hết
thời gian chạy hoặc khi nó tự khởi động ZZ0001ZZ.
Màn hình bao gồm ngưỡng thời hạn có thể định cấu hình của người dùng. Nếu tổng cộng
việc sử dụng các nhiệm vụ có thời hạn lớn hơn 1 thì chúng chỉ được đảm bảo
độ trễ có giới hạn. Xem Tài liệu/lập lịch/sched-deadline.rst để biết thêm
chi tiết. Ngưỡng (tham số mô-đun ZZ0002ZZ) có thể là
được cấu hình để tránh màn hình bị lỗi dựa trên độ trễ có thể chấp nhận được trong
hệ thống. Vì ZZ0003ZZ là kết quả hợp lệ để thực thể được thực hiện,
độ trễ tối thiểu cần là 1 tích tắc để xem xét độ trễ ga, trừ khi
tính năng lập lịch ZZ0004ZZ đang hoạt động.

Máy chủ cũng có trạng thái ZZ0000ZZ trung gian, xảy ra ngay khi không có
tác vụ có thể chạy được có sẵn từ trạng thái sẵn sàng hoặc đang chạy khi không có ràng buộc về thời gian
được áp dụng. Máy chủ chuyển sang chế độ ngủ bằng cách dừng, không có hoạt động đánh thức tương đương
vì thứ tự khởi động và bổ sung máy chủ không được xác định, do đó
máy chủ có thể chạy từ chế độ ngủ mà chưa sẵn sàng::

|
  lịch_wakeup v
  dl_replenish;reset(clk) -- #============================#
               |             H H dl_replenish;reset(clk)
               +-----------> H H <--------------------+
                             HH |
      +- dl_server_stop ---- H sẵn sàng H |
      ZZ0000ZZ
      ZZ0001ZZ H H is_defer == 1 |
      ZZ0002ZZ sched_switch_in - H H ------------------+ |
      ZZ0003ZZ ZZ0004ZZ |
      ZZ0005ZZ ZZ0006ZZ ^ ZZ0007ZZ
      ZZ0008ZZ ZZ0009ZZ |
      ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
      ZZ0013ZZ ZZ0014ZZ |
      ZZ0015ZZ ZZ0016ZZ ZZ0017ZZ |
      ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ |
      ZZ0021ZZ ZZ0022ZZ ZZ0023ZZ ------------------+ ZZ0024ZZ
      ZZ0025ZZ ZZ0026ZZ ZZ0027ZZ ZZ0028ZZ
      ZZ0029ZZ ZZ0030ZZ ZZ0031ZZ ZZ0032ZZ
      ZZ0033ZZ ZZ0034ZZ ZZ0035ZZ ZZ0036ZZ
   +---+--+---+--- dl_server_stop -- +--------------+ ZZ0037ZZ |
   ZZ0038ZZ ZZ0039ZZ ZZ0040ZZ ZZ0041ZZ
   ZZ0042ZZ ZZ0043ZZ lịch_switch_in dl_server_idle ZZ0044ZZ |
   ZZ0045ZZ ZZ0046ZZ và ZZ0047ZZ ZZ0048ZZ
   ZZ0049ZZ ZZ0050ZZ +---------- +----------------------+ ZZ0051ZZ |
   ZZ0052ZZ ZZ0053ZZ lịch_switch_in ZZ0054ZZ ZZ0055ZZ |
   ZZ0056ZZ ZZ0057ZZ lịch_đánh thức ZZ0058ZZ ZZ0059ZZ |
   ZZ0060ZZ ZZ0061ZZ dl_replenish;    ZZ0062ZZ -------+ ZZ0063ZZ |
   ZZ0064ZZ ZZ0065ZZ đặt lại(clk) ZZ0066ZZ ZZ0067ZZ ZZ0068ZZ
   ZZ0069ZZ ZZ0070ZZ +--------> ZZ0071ZZ dl_throttle ZZ0072ZZ |
   ZZ0073ZZ ZZ0074ZZ ZZ0075ZZ ZZ0076ZZ |
   ZZ0077ZZ ZZ0078ZZ ZZ0079ZZ |
   ZZ0080ZZ lịch_wakeup ^ lịch_switch_suspend ZZ0081ZZ ZZ0082ZZ
   v v dl_replenish;reset(clk) ZZ0083ZZ ZZ0084ZZ |
 +--------------+ ZZ0085ZZ v v v |
 ZZ0086ZZ - lịch_switch_in + |                     +--------------+
 ZZ0087ZZ <----------------------+ dl_throttle +-- ZZ0088ZZ
 ZZ0089ZZ lịch trình_wakeup ZZ0090ZZ được điều chỉnh |
 ZZ0091ZZ -- dl_server_stop dl_server_idle +-> ZZ0092ZZ
 ZZ0093ZZ dl_server_idle sched_switch_suspend +--------------+
 +--------------+ <----------+ ^
        ZZ0094ZZ
        +------ dl_throttle;is_constr_dl == 1 || is_defer == 1 ------+
