.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_sched.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình theo dõi lịch trình
==================

- Tên: lịch trình
- Loại: hộp đựng nhiều màn hình
- Tác giả: Gabriele Monaco <gmonaco@redhat.com>, Daniel Bristot de Oliveira <bristot@kernel.org>

Sự miêu tả
-----------

Màn hình mô tả các hệ thống phức tạp, chẳng hạn như bộ lập lịch, có thể dễ dàng phát triển thành
điểm mà chúng khó hiểu vì có nhiều khả năng
các chuyển đổi trạng thái.
Thông thường có thể chia các mô tả đó thành các màn hình nhỏ hơn,
chia sẻ một số hoặc tất cả các sự kiện. Việc kích hoạt đồng thời những màn hình nhỏ hơn đó là,
trên thực tế, chúng tôi đang kiểm tra hệ thống như thể chúng tôi có một màn hình lớn hơn.
Việc chia các mô hình thành nhiều đặc tả không chỉ dễ dàng hơn
hiểu, nhưng cung cấp thêm một số manh mối khi chúng ta thấy lỗi.

Giám sát lịch trình là một tập hợp các thông số kỹ thuật để mô tả hành vi của người lập lịch trình.
Nó bao gồm một số màn hình mỗi CPU và mỗi tác vụ hoạt động độc lập để xác minh
các thông số kỹ thuật khác nhau mà người lập lịch trình phải tuân theo.

Để làm cho hệ thống này đơn giản nhất có thể, các thông số kỹ thuật được lập lịch là ZZ0000ZZ
màn hình, trong khi bản thân lịch trình là ZZ0001ZZ.
Từ góc độ giao diện, lịch trình bao gồm các màn hình khác dưới dạng thư mục con,
bật/tắt hoặc đặt bộ phản ứng theo lịch trình, truyền bá thay đổi tới tất cả các màn hình,
tuy nhiên các màn hình đơn cũng có thể được sử dụng độc lập.

Điều quan trọng là các mô-đun trong tương lai phải được xây dựng sau vùng chứa của chúng (được lên lịch, trong
trường hợp này), nếu không thì trình liên kết sẽ không tôn trọng thứ tự và cách lồng nhau
sẽ không hoạt động như mong đợi.
Để làm như vậy, chỉ cần thêm chúng sau khi lên lịch trong Makefile.

Thông số kỹ thuật
--------------

Các thông số kỹ thuật có trong lịch trình hiện đang được tiến hành, điều chỉnh các thông số kỹ thuật
được định nghĩa bởi Daniel Bristot trong [1].

Hiện nay chúng tôi bao gồm những điều sau đây:

Giám sát sco
~~~~~~~~~~~

Trình giám sát các hoạt động bối cảnh lập lịch trình (sco) đảm bảo các thay đổi trong trạng thái nhiệm vụ
chỉ xảy ra trong bối cảnh chủ đề::


|
                        |
                        v
    lịch_set_state +-------------------+
  +---- ZZ0000ZZ
  ZZ0001ZZ thread_context |
  +-----------------> ZZ0002ZZ <+
                      +-------------------+ |
                        ZZ0003ZZ
                        ZZ0004ZZ lịch trình_exit
                        v |
                                            |
                       lập lịch_bối cảnh -+

màn hình snroc
~~~~~~~~~~~~~

Bộ không thể chạy được trên màn hình ngữ cảnh (snroc) của chính nó đảm bảo các thay đổi trong
trạng thái nhiệm vụ chỉ xảy ra trong ngữ cảnh của nhiệm vụ tương ứng. Đây là một nhiệm vụ
giám sát::

|
                        |
                        v
                      +-------------------+
                      ZZ0000ZZ <+
                      +-------------------+ |
                        ZZ0001ZZ
                        ZZ0002ZZ lịch_switch_out
                        v |
    lịch_set_state |
  +----------------- |
  ZZ0003ZZ
  +-----------------> -+

màn hình scpd
~~~~~~~~~~~~

Lịch trình được gọi với trình giám sát bị vô hiệu hóa quyền ưu tiên (scpd) đảm bảo lịch trình được
được gọi với quyền ưu tiên bị vô hiệu hóa::

|
                       |
                       v
                     +-------------------+
                     ZZ0000ZZ <+
                     +-------------------+ |
                       ZZ0001ZZ
                       ZZ0002ZZ ưu tiên_enable
                       v |
    lịch_entry |
    lịch_exit |
  +----------------- can_sched |
  ZZ0003ZZ
  +----------------> -+

Theo dõi ảnh chụp
~~~~~~~~~~~~

Lịch trình không kích hoạt tính năng giám sát trước (snep) đảm bảo cuộc gọi theo lịch trình
không cho phép ưu tiên::

|
                        |
                        v
    preempt_disable +------------------------+
    preempt_enable ZZ0000ZZ
  +---- ZZ0001ZZ
  ZZ0002ZZ |
  +-----------------> ZZ0003ZZ <+
                      +------------------------+ |
                        ZZ0004ZZ
                        ZZ0005ZZ lịch_thoát
                        v |
                                                  |
                          lập lịch_contex -+

Theo dõi sts
~~~~~~~~~~~

Lịch trình ngụ ý giám sát chuyển đổi tác vụ (sts) đảm bảo việc chuyển đổi tác vụ xảy ra
chỉ trong bối cảnh lập lịch và tối đa một lần, cũng như việc lập lịch xảy ra với
ngắt được kích hoạt nhưng không có chuyển đổi tác vụ nào có thể xảy ra trước khi ngắt
bị vô hiệu hóa. Khi tác vụ tiếp theo được chọn để thực thi giống với tác vụ trước đó
đang chạy một cái, không có chuyển đổi tác vụ thực sự nào xảy ra nhưng tuy nhiên các ngắt vẫn bị tắt ::

irq_entry |
     +----+ |
     v |                        v
 +-------------+ irq_enable #=====================#   irq_disable
 ZZ0000ZZ -------------> H H irq_entry
 ZZ0001ZZ <------------- H H irq_enable
 ZZ0002ZZ irq_disable H can_sched H --------------+
 +----------+ H H |
                              HH |
            +---------------> H H <-------------+
            |                 #======================#
            ZZ0032ZZ
      lịch_exit | lịch_entry
            |                   v
            |   +-------------------+ không thể bật được
            Lập kế hoạch ZZ0004ZZ | <---------------+
            ZZ0005ZZ
            ZZ0006ZZ |
            ZZ0007ZZ irq_disable +--------+ irq_entry
            ZZ0008ZZ | --------+
            ZZ0009ZZ in_irq ZZ0010ZZ
            ZZ0011ZZ ZZ0012ZZ | <-------+
            ZZ0013ZZ vô hiệu hóa_to_switch |              +--------+
            ZZ0014ZZ | --+
            ZZ0015ZZ
            ZZ0016ZZ |
            ZZ0017ZZ lịch_switch |
            ZZ0018ZZ
            ZZ0019ZZ
            ZZ0020ZZ chuyển đổi ZZ0021ZZ irq_enable
            ZZ0022ZZ
            ZZ0023ZZ |
            ZZ0024ZZ irq_enable |
            ZZ0025ZZ
            ZZ0026ZZ
            +-- ZZ0027ZZ <-+
                +-------------------+
                  ^ | irq_disable
                  ZZ0028ZZ irq_entry
                  +--------------+ irq_enable

Giám sát nrp
-----------

Trình giám sát các quyền ưu tiên được sắp xếp lại (nrp) đảm bảo yêu cầu quyền ưu tiên
ZZ0000ZZ. Chỉ quyền ưu tiên của kernel mới được xem xét, vì quyền ưu tiên
trong khi quay lại không gian người dùng, đối với màn hình này, không thể phân biệt được với
ZZ0001ZZ (được mô tả trong màn hình sssw).
Quyền ưu tiên kernel là bất cứ khi nào ZZ0002ZZ được gọi với quyền ưu tiên
cờ được đặt thành true (ví dụ: từ preempt_enable hoặc thoát khỏi các ngắt). Cái này
loại quyền ưu tiên xảy ra sau khi nhu cầu về ZZ0003ZZ đã được đặt.
Điều này không hợp lệ đối với biến thể cờ ZZ0006ZZ, điều này chỉ gây ra
quyền ưu tiên không gian người dùng.
ZZ0004ZZ có thể liên quan đến chuyển đổi tác vụ hoặc không, sau này
trường hợp, một tác vụ đi qua bộ lập lịch từ ngữ cảnh ưu tiên nhưng nó được
được chọn làm nhiệm vụ tiếp theo để chạy. Vì bộ lập lịch chạy nên điều này loại bỏ nhu cầu
để sắp xếp lại lịch trình. Trạng thái ZZ0005ZZ không hàm ý được giám sát
tác vụ không chạy vì màn hình này không theo dõi kết quả của việc lập kế hoạch.

Về lý thuyết, quyền ưu tiên chỉ có thể xảy ra sau khi cờ ZZ0000ZZ được đặt. trong
tuy nhiên, trong thực tế, có thể thấy sự ưu tiên khi không có cờ
thiết lập. Điều này có thể xảy ra trong một điều kiện cụ thể::

cần_resched
                   preempt_schedule()
                                           preempt_schedule_irq()
                                                   __lịch trình()
  !need_resched
                           __lịch trình()

Trong tình huống trên, quyền ưu tiên tiêu chuẩn bắt đầu (ví dụ: từ preempt_enable
khi cờ được đặt), một ngắt xảy ra trước khi lập kế hoạch và khi thoát khỏi
đường dẫn, nó lập lịch trình để xóa cờ ZZ0000ZZ.
Khi tác vụ được ưu tiên chạy lại, quyền ưu tiên tiêu chuẩn đã bắt đầu sớm hơn
tiếp tục, mặc dù cờ không còn được đặt. Người giám sát coi đây là một
ZZ0001ZZ, điều này cho phép một quyền ưu tiên khác mà không cần thiết lập lại
cờ. Điều kiện này nới lỏng các ràng buộc của màn hình và có thể phát hiện sai
âm bản (tức là không có ZZ0002ZZ thực) nhưng làm cho màn hình trở nên hấp dẫn hơn
mạnh mẽ và có thể xác nhận các kịch bản khác.
Để đơn giản, màn hình khởi động ở ZZ0003ZZ, mặc dù không bị gián đoạn
đã xảy ra, vì tình huống trên rất khó xác định::

lịch_entry
    irq_entry #===============================================#
  +-------------------------- HH
  |                           H H
  +-------------------------> H Any_thread_running H
                              H H
  +-------------------------> HH
  |                           #===============================================#
  ZZ0024ZZ ^
  ZZ0001ZZ lịch_need_resched | lịch_entry
  ZZ0002ZZ lịch_entry_preempt
  ZZ0003ZZ
  ZZ0004ZZ
  ZZ0005ZZ ZZ0006ZZ
  ZZ0007ZZ ZZ0008ZZ -+
  ZZ0009ZZ |
  |                           +----------------------+
  ZZ0010ZZ irq_entry
  |                             v
  |                           +----------------------+
  ZZ0011ZZ | ---+
  ZZ0012ZZ ZZ0013ZZ lịch_need_resched
  ZZ0014ZZ ưu tiên_irq ZZ0015ZZ irq_entry
  ZZ0016ZZ | <--+
  ZZ0017ZZ | <--+
  ZZ0018ZZ
  ZZ0019ZZ lịch_entry | lịch_need_resched
  ZZ0020ZZ lịch_entry_preempt |
  ZZ0021ZZ
  ZZ0022ZZ
  +--------------------------ZZ0023ZZ---+
                              +--------------+
                                ^ irq_entry |
                                +-------------------+

Do cách hoạt động của cờ ZZ0000ZZ trên số lượng quyền ưu tiên trên arm64,
màn hình này không ổn định trên kiến trúc đó vì nó thường ghi lại quyền ưu tiên
khi cờ không được đặt, ngay cả khi có cách giải quyết ở trên.
Hiện tại, màn hình bị tắt theo mặc định trên arm64.

màn hình sssw
------------

Bộ giám sát trạng thái ngủ và thức (sssw) được thiết lập đảm bảo ZZ0000ZZ hoạt động
có thể ngủ được dẫn đến việc ngủ và các công việc ngủ đòi hỏi phải thức dậy. Nó bao gồm
các loại công tắc sau:

*ZZ0000ZZ:
  một tác vụ tự chuyển sang chế độ ngủ, điều này chỉ có thể xảy ra sau khi cài đặt rõ ràng
  nhiệm vụ cho ZZ0001ZZ. Sau khi một nhiệm vụ bị đình chỉ, nó cần được đánh thức
  (trạng thái ZZ0002ZZ) trước khi được bật lại.
  Việc đặt trạng thái của tác vụ thành ZZ0003ZZ có thể được hoàn nguyên trước khi chuyển đổi nếu nó
  được đánh thức hoặc được đặt thành ZZ0004ZZ.
*ZZ0005ZZ:
  một trường hợp đặc biệt của ZZ0006ZZ trong đó tác vụ đang chờ trên
  khóa RT đang ngủ (chỉ ZZ0007ZZ), người ta thường thấy việc đánh thức và thiết lập
  các sự kiện trạng thái chạy đua với nhau và điều này khiến mô hình nhận thức được điều này
  loại chuyển đổi khi tác vụ không được đặt thành có thể ngủ được. Đây là một hạn chế của
  mô hình trong hệ thống SMP và cách giải quyết có thể làm chậm hệ thống.
*ZZ0008ZZ:
  chuyển đổi tác vụ do quyền ưu tiên của kernel (ZZ0009ZZ trong
  mô hình nrp).
*ZZ0010ZZ:
  một tác vụ gọi bộ lập lịch một cách rõ ràng hoặc được ưu tiên trước khi quay lại
  không gian người dùng. Nó có thể xảy ra sau cuộc gọi hệ thống ZZ0011ZZ, từ tác vụ nhàn rỗi hoặc
  nếu cờ ZZ0012ZZ được đặt. Theo định nghĩa, một nhiệm vụ không thể mang lại kết quả trong khi
  ZZ0013ZZ vì đó sẽ là hệ thống treo. Trường hợp đặc biệt của năng suất xảy ra
  khi một tác vụ trong ZZ0014ZZ gọi bộ lập lịch trong khi có tín hiệu
  đang chờ xử lý. Nhiệm vụ không trải qua quá trình chặn/đánh thức thông thường và được đặt
  trở lại trạng thái có thể chạy được, chuyển đổi kết quả (nếu có) trông giống như một kết quả cho
  Trạng thái ZZ0015ZZ và theo sau là việc truyền tín hiệu. Từ đây
  trạng thái, màn hình mong đợi một tín hiệu ngay cả khi nó nhìn thấy một sự kiện đánh thức, mặc dù
  không cần thiết, để loại trừ những kết quả âm tính giả.

Màn hình này không bao gồm trạng thái đang chạy, ZZ0000ZZ và ZZ0001ZZ
chỉ đề cập đến trạng thái mong muốn của nhiệm vụ, có thể được lên lịch
(ví dụ: do quyền ưu tiên). Tuy nhiên, nó bao gồm sự kiện
ZZ0002ZZ để biểu thị thời điểm một tác vụ được phép chạy. Cái này
cũng có thể được kích hoạt bằng quyền ưu tiên, nhưng không thể xảy ra sau khi nhiệm vụ được thực hiện
ZZ0003ZZ trước khi xảy ra ZZ0004ZZ::

+-----------------------------------------------------------------------------------+
   ZZ0000ZZ
   ZZ0001ZZ
   ZZ0002ZZ |
   ZZ0003ZZ |
   v v |
 +----------+ #=============================#   set_state_runnable |
 ZZ0004ZZ H H thức dậy |
 ZZ0005ZZ H H switch_in |
 ZZ0006ZZ H H switch_yield |
 ZZ0007ZZ H H switch_preempt |
 ZZ0008ZZ H H signal_deliver |
 Công tắc ZZ0009ZZ_ H H ------+ |
 ZZ0010ZZ _chặn H chạy được H ZZ0011ZZ
 ZZ0012ZZ <----------- H H <------+ |
 +----------+ H H |
   ZZ0013ZZ
   +--------------------> H H |
                           HH |
               +---------> H H |
               ZZ0014ZZ
               ZZ0015ZZ ^ |
               ZZ0016ZZ ZZ0017ZZ
               ZZ0018ZZ ZZ0019ZZ
               ZZ0020ZZ +------------------------+
               ZZ0021ZZ |
               |           +--------------------------+ set_state_sleepable
               ZZ0022ZZ |  switch_in
               ZZ0023ZZ |  switch_preempt
   tín hiệu_giao hàng ZZ0024ZZ tín hiệu_giao hàng
               ZZ0025ZZ | ------+
               ZZ0026ZZ ZZ0027ZZ
               ZZ0028ZZ | <------+
               |           +--------------------------+
               ZZ0029ZZ ^
               ZZ0030ZZ set_state_sleepable
               ZZ0031ZZ
               ZZ0032ZZ
               +---------- ZZ0033ZZ -+
                           +--------------+
                             ^ | switch_in
                             ZZ0034ZZ switch_preempt
                             ZZ0035ZZ switch_yield
                             +----------+ thức dậy

Màn hình opid
------------

Các hoạt động với màn hình ưu tiên và vô hiệu hóa irq (opid) đảm bảo
các hoạt động như ZZ0000ZZ và ZZ0001ZZ xảy ra với các ngắt và
quyền ưu tiên bị vô hiệu hóa.
ZZ0002ZZ có thể được thiết lập bởi một số chức năng bên trong RCU, trong trường hợp đó nó
không khớp với việc đánh thức tác vụ và có thể xảy ra chỉ khi các ngắt bị tắt.
Trạng thái ngắt và ưu tiên được xác nhận bởi máy tự động lai
các ràng buộc khi xử lý các sự kiện::

|
   |
   v
 #=========#   sched_need_resched;irq_off == 1
 H H sched_waking;irq_off == 1 && preempt_off == 1
 H bất kỳ H ------------------------------------------------+
 HH |
 HH <-------------------------------------------------------- +
 #==========#

Tài liệu tham khảo
----------

[1] - ZZ0000ZZ
