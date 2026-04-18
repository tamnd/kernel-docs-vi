.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/monitor_synthesis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Tổng hợp màn hình xác minh thời gian chạy
======================================

Điểm khởi đầu cho việc áp dụng kỹ thuật xác minh thời gian chạy (RV)
là ZZ0000ZZ hoặc ZZ0001ZZ của hành vi mong muốn (hoặc không mong muốn)
của hệ thống đang được giám sát.

Sau đó, biểu diễn chính thức cần phải là ZZ0000ZZ thành ZZ0001ZZ
sau đó có thể được sử dụng trong việc phân tích dấu vết của hệ thống. các
ZZ0002ZZ kết nối với hệ thống thông qua ZZ0003ZZ chuyển đổi
các sự kiện từ ZZ0004ZZ đến các sự kiện của ZZ0005ZZ.


Theo thuật ngữ Linux, màn hình xác minh thời gian chạy được gói gọn bên trong
sự trừu tượng ZZ0000ZZ. Màn hình RV bao gồm một tập hợp các phiên bản
của màn hình (màn hình mỗi CPU, màn hình mỗi tác vụ, v.v.), trình trợ giúp
các chức năng gắn kết màn hình với mô hình tham chiếu hệ thống và
theo dõi đầu ra như một phản ứng đối với việc phân tích sự kiện và các ngoại lệ, như được mô tả
dưới đây::

Linux +---- Màn hình RV ----------------------------------+ Chính thức
  Vương quốc ZZ0000ZZ Vương quốc
  +-------------------+ +----------------+ +-----------------+
  ZZ0001ZZ ZZ0002ZZ ZZ0003ZZ
  ZZ0004ZZ -> ZZ0005ZZ <- ZZ0006ZZ
  ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ
  +-------------------+ +----------------+ +-----------------+
         ZZ0010ZZ |
         ZZ0011ZZ
         ZZ0012ZZ
         Phản ứng ZZ0013ZZ ZZ0014ZZ
         ZZ0015ZZ
         ZZ0016ZZ ZZ0017ZZ |
         ZZ0018ZZ ZZ0019ZZ
         +-----------------------ZZ0020ZZ----------------------+
                                  |  +----> hoảng loạn ?
                                  +-------> <do người dùng chỉ định>

Tổng hợp màn hình RV
--------------------

Việc tổng hợp một đặc tả vào bản tóm tắt Linux ZZ0000ZZ là
được tự động hóa bởi công cụ rvgen và tệp tiêu đề chứa mã chung cho
tạo màn hình. Các tập tin tiêu đề là:

* rv/da_monitor.h để theo dõi tự động xác định.
  * rv/ltl_monitor.h để theo dõi logic thời gian tuyến tính.
  * rv/ha_monitor.h cho màn hình tự động lai.

rvgen
-----

Tiện ích rvgen chuyển đổi đặc tả thành bản trình bày C và tạo
bộ xương của trình giám sát kernel trong C.

Ví dụ: có thể chuyển đổi mô hình wip.dot có trong
[1] vào màn hình trên mỗi CPU bằng lệnh sau ::

$ rvgen màn hình -c da -s wip.dot -t per_cpu

Thao tác này sẽ tạo một thư mục có tên wip/ với các tệp sau:

- wip.h: mô hình wip trong C
- wip.c: màn hình RV

Tệp wip.c chứa phần khai báo màn hình và điểm bắt đầu cho
thiết bị đo của hệ thống.

Tương tự, một trình giám sát logic thời gian tuyến tính có thể được tạo bằng cách sau
lệnh::

$ rvgen màn hình -c ltl -s pagefault.ltl -t per_task

Điều này tạo ra thư mục pagefault/ với:

- pagefault.h: Máy tự động Buchi (máy trạng thái không xác định để
  xác minh đặc điểm kỹ thuật)
- pagefault.c: Bộ xương cho màn hình RV

Giám sát các tập tin tiêu đề
--------------------

Các tập tin tiêu đề:

- ZZ0000ZZ cho màn hình tự động xác định
- ZZ0001ZZ cho màn hình logic thời gian tuyến tính

bao gồm các macro phổ biến và các hàm tĩnh để triển khai *Monitor
(Các) trường hợp*.

Lợi ích của việc có tất cả các chức năng chung trong một tệp tiêu đề duy nhất là
gấp 3 lần:

- Giảm sự trùng lặp mã;
  - Tạo điều kiện sửa lỗi/cải tiến;
  - Tránh trường hợp nhà phát triển thay đổi lõi code màn hình thành
    thao tác mô hình theo một cách (giả sử) không chuẩn.

rv/da_monitor.h
+++++++++++++++

Việc triển khai ban đầu này trình bày ba loại phiên bản giám sát khác nhau:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ

Việc đầu tiên thiết lập khai báo hàm cho một automata xác định toàn cầu
màn hình, màn hình thứ hai dành cho màn hình có phiên bản trên mỗi CPU và màn hình thứ ba có
trường hợp theo từng nhiệm vụ.

Trong mọi trường hợp, tệp C phải bao gồm tệp $(MODEL_NAME).h (được tạo bởi
ZZ0000ZZ), ví dụ: để xác định màn hình 'wip' trên mỗi CPU, nguồn ZZ0001ZZ
tập tin phải bao gồm::

#define RV_MON_TYPE RV_MON_PER_CPU
  #include "wip.h"
  #include <rv/da_monitor.h>

Màn hình được thực thi bằng cách gửi các sự kiện cần xử lý thông qua các hàm
trình bày dưới đây::

da_handle_event($(sự kiện từ sự kiện enum));
  da_handle_start_event($(sự kiện từ sự kiện enum));
  da_handle_start_run_event($(sự kiện từ sự kiện enum));

Hàm ZZ0000ZZ là trường hợp thông thường trong đó
sự kiện sẽ được xử lý nếu màn hình đang xử lý các sự kiện.

Khi màn hình được bật, nó sẽ được đặt ở trạng thái ban đầu của máy tự động.
Tuy nhiên, màn hình không biết liệu hệ thống có nằm trong ZZ0000ZZ hay không.

Chức năng ZZ0000ZZ được sử dụng để thông báo cho
giám sát xem hệ thống có đang trở về trạng thái ban đầu hay không, do đó người giám sát có thể
bắt đầu theo dõi sự kiện tiếp theo.

Chức năng ZZ0000ZZ được sử dụng để thông báo
màn hình mà hệ thống được biết là ở trạng thái ban đầu, do đó
màn hình có thể bắt đầu theo dõi và giám sát sự kiện hiện tại.

Sử dụng mô hình wip làm ví dụ, các sự kiện "preempt_disable" và
"Sched_waking" phải được gửi tới màn hình tương ứng thông qua [2]::

da_handle_event(preempt_disable_wip);
  da_handle_event(lịch_waking_wip);

Trong khi sự kiện "preempt_enabled" sẽ sử dụng::

da_handle_start_event(preempt_enable_wip);

Để thông báo cho người giám sát rằng hệ thống sẽ trở về trạng thái ban đầu,
vì vậy hệ thống và màn hình phải đồng bộ.

rv/ltl_monitor.h
++++++++++++++++
Tệp này phải được kết hợp với tệp $(MODEL_NAME).h (được tạo bởi ZZ0000ZZ)
để được hoàn thiện. Ví dụ: đối với màn hình ZZ0001ZZ, ZZ0002ZZ
tập tin nguồn phải bao gồm::

#include "pagefault.h"
  #include <rv/ltl_monitor.h>

(tệp giám sát bộ xương do ZZ0000ZZ tạo đã thực hiện việc này).

ZZ0000ZZ (ZZ0001ZZ trong ví dụ trên) bao gồm
triển khai máy tự động Buchi - một máy trạng thái không xác định
xác minh thông số kỹ thuật LTL. Trong khi ZZ0002ZZ bao gồm phần chung
chức năng trợ giúp để tương tác với máy tự động Buchi và triển khai RV
màn hình. Một định nghĩa quan trọng trong ZZ0003ZZ là::

enum ltl_atom {
      LTL_$(FIRST_ATOMIC_PROPOSITION),
      LTL_$(SECOND_ATOMIC_PROPOSITION),
      ...
LTL_NUM_ATOM
  };

đây là danh sách các mệnh đề nguyên tử có trong đặc tả LTL
(có tiền tố là "LTL\_" để tránh xung đột tên). ZZ0000ZZ này được chuyển tới
các chức năng tương tác với máy tự động Buchi.

Trong khi tạo mã, ZZ0000ZZ không thể hiểu ý nghĩa của nguyên tử
đề xuất. Vì vậy, nhiệm vụ đó được giao cho công việc thủ công. Thực hành được đề xuất
đang thêm các dấu vết vào những nơi mà các mệnh đề nguyên tử thay đổi; và trong
trình xử lý của dấu vết: máy tự động Buchi được thực thi bằng cách sử dụng ::

void ltl_atom_update(struct task_struct *task, nguyên tử enum ltl_atom, giá trị bool)

báo cho máy tự động Buchi rằng mệnh đề nguyên tử ZZ0000ZZ bây giờ là
ZZ0001ZZ. Máy tự động Buchi kiểm tra xem thông số kỹ thuật LTL có còn hiệu lực không
hài lòng và gọi điểm theo dõi lỗi của màn hình và bộ phản ứng nếu
vi phạm được phát hiện.

Tracepoints và ZZ0000ZZ nên được sử dụng bất cứ khi nào có thể. Tuy nhiên,
nó đôi khi không phải là thuận tiện nhất. Đối với một số mệnh đề nguyên tử
bị thay đổi ở nhiều vị trí trong kernel, thật khó để theo dõi tất cả những vị trí đó
những nơi. Hơn nữa, việc các mệnh đề nguyên tử có thể không quan trọng
được cập nhật vào những thời điểm chính xác. Ví dụ, xem xét thời gian tuyến tính sau đây
logic::

RULE = luôn luôn (RT ngụ ý không phải PAGEFAULT)

LTL này tuyên bố rằng tác vụ thời gian thực không gây ra lỗi trang. Vì điều này
thông số kỹ thuật, việc ZZ0000ZZ thay đổi không quan trọng, miễn là nó có
giá trị đúng khi ZZ0001ZZ là đúng.  Thúc đẩy bởi trường hợp này, trường hợp khác
chức năng được giới thiệu::

void ltl_atom_fetch(struct task_struct *task, struct ltl_monitor *mon)

Hàm này được gọi bất cứ khi nào máy tự động Buchi được kích hoạt. Vì vậy, nó
có thể được triển khai thủ công để "tìm nạp" ZZ0000ZZ::

void ltl_atom_fetch(struct task_struct *task, struct ltl_monitor *mon)
  {
      ltl_atom_set(mon, LTL_RT, rt_task(task));
  }

Thực tế, bất cứ khi nào ZZ0000ZZ được cập nhật với lệnh gọi tới ZZ0001ZZ,
ZZ0002ZZ cũng được tìm nạp. Do đó, thông số kỹ thuật LTL có thể được xác minh mà không cần
truy tìm ZZ0003ZZ ở khắp mọi nơi.

Đối với các mệnh đề nguyên tử hoạt động giống như các sự kiện, chúng thường cần được thiết lập (hoặc
đã xóa) và sau đó xóa ngay lập tức (hoặc đặt). Một chức năng tiện lợi là
cung cấp::

void ltl_atom_pulse(struct task_struct *task, nguyên tử enum ltl_atom, giá trị bool)

tương đương với::

ltl_atom_update(tác vụ, nguyên tử, giá trị);
  ltl_atom_update(tác vụ, nguyên tử, !value);

Để khởi tạo các mệnh đề nguyên tử, hàm sau phải được
đã thực hiện::

ltl_atoms_init(struct task_struct *task, struct ltl_monitor *mon, bool task_creation)

Chức năng này được gọi cho tất cả các tác vụ đang chạy khi màn hình được bật. Đó là
cũng kêu gọi các tác vụ mới được tạo sau khi bật màn hình. Nó nên
khởi tạo càng nhiều mệnh đề nguyên tử càng tốt, ví dụ::

void ltl_atom_init(struct task_struct *task, struct ltl_monitor *mon, bool task_creation)
  {
      ltl_atom_set(mon, LTL_RT, rt_task(task));
      nếu (task_creation)
          ltl_atom_set(mon, LTL_PAGEFAULT, false);
  }

Các đề xuất nguyên tử không được ZZ0000ZZ khởi tạo sẽ vẫn ở trong
trạng thái không xác định cho đến khi đạt được các điểm theo dõi liên quan, việc này có thể mất một chút thời gian. Như
việc giám sát một nhiệm vụ không thể được thực hiện cho đến khi tất cả các mệnh đề nguyên tử được biết đến
nhiệm vụ, người giám sát có thể cần một chút thời gian để bắt đầu xác thực các nhiệm vụ có
đang chạy trước khi màn hình được bật. Vì vậy, nên
bắt đầu các nhiệm vụ quan tâm sau khi kích hoạt màn hình.

rv/ha_monitor.h
+++++++++++++++

Việc triển khai các màn hình tự động lai bắt nguồn trực tiếp từ
máy tự động xác định một. Mặc dù sử dụng tiêu đề khác
(ZZ0000ZZ) các chức năng xử lý sự kiện đều giống nhau (ví dụ:
ZZ0001ZZ).

Ngoài ra, công cụ ZZ0003ZZ sẽ điền các khung cho
ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ dựa trên
thông số kỹ thuật của màn hình trong tệp nguồn màn hình.

ZZ0000ZZ thường sẵn sàng vì nó được tạo bởi ZZ0001ZZ:

* Các ràng buộc tiêu chuẩn trên các cạnh được chuyển thành dạng::

res = ha_get_env(ha_mon, ENV) < VALUE;

* Các ràng buộc đặt lại được chuyển thành dạng::

ha_reset_env(ha_mon, ENV);

* các ràng buộc về trạng thái được thực hiện bằng cách sử dụng bộ tính giờ

- trang bị vũ khí trước khi vào bang

- bị hủy khi vào bất kỳ trạng thái nào khác

- không bị ảnh hưởng nếu trạng thái không thay đổi do sự kiện

- kiểm tra xem bộ hẹn giờ đã hết chưa nhưng cuộc gọi lại không chạy

- triển khai có sẵn là ZZ0000ZZ và ZZ0001ZZ

- giờ chính xác hơn nhưng có thể có chi phí cao hơn

- chọn bằng cách xác định ZZ0000ZZ trước khi bao gồm tiêu đề::

#define HA_TIMER_TYPE HA_TIMER_HRTIMER

Các giá trị ràng buộc có thể được chỉ định theo các dạng khác nhau:

* giá trị bằng chữ (với đơn vị tùy chọn). Ví dụ.::

ưu tiên == 0
    clk < 100ns
    ngưỡng <= 10j

* giá trị không đổi (chuỗi chữ hoa). Ví dụ.::

clk < MAX_NS

* tham số (chuỗi chữ thường). Ví dụ.::

clk <= ngưỡng_jiffies

* macro (chuỗi chữ hoa có dấu ngoặc đơn). Ví dụ.::

clk < MAX_NS()

* Hàm (chuỗi chữ thường có dấu ngoặc đơn). Ví dụ.::

clk <= ngưỡng_jiffies()

Trong mọi trường hợp, ZZ0002ZZ sẽ cố gắng hiểu loại môi trường
biến từ tên hoặc đơn vị. Ví dụ: hằng số hoặc tham số
kết thúc bằng ZZ0000ZZ hoặc ZZ0001ZZ được coi là đồng hồ có ns và jiffy
độ chi tiết tương ứng. Các chữ có đơn vị đo ZZ0003ZZ là jiffies và nếu
đơn vị thời gian được chỉ định (ZZ0004ZZ thành ZZ0005ZZ), ZZ0006ZZ sẽ chuyển đổi giá trị thành ZZ0007ZZ.

Các hằng số cần được người dùng xác định (nhưng không giống như tên, chúng không
nhất thiết phải được định nghĩa là hằng số). Các thông số được chuyển đổi thành
tham số mô-đun và người dùng cần cung cấp giá trị mặc định.
Ngoài ra, chức năng và macro cũng do người dùng xác định, theo mặc định, chúng nhận được dưới dạng
đối số ZZ0000ZZ, cách sử dụng phổ biến là lấy giá trị được yêu cầu
từ mục tiêu, ví dụ: tác vụ trong màn hình theo từng tác vụ, sử dụng trình trợ giúp
ZZ0001ZZ.

Nếu ZZ0000ZZ xác định rằng biến đó là đồng hồ, nó sẽ cung cấp getter và
resetter dựa trên đơn vị. Ngược lại, người dùng cần cung cấp một thông tin thích hợp
định nghĩa.
Thông thường, các biến môi trường không có đồng hồ sẽ không được đặt lại. Trong trường hợp như vậy chỉ có
bộ khung getter sẽ có trong tệp được tạo bởi ZZ0001ZZ.
Ví dụ: getter cho quyền ưu tiên có thể được điền là::

u64 tĩnh ha_get_env(struct ha_monitor *ha_mon, enum envs env)
  {
      if (env == có thể được ưu tiên)
          trả về preempt_count() == 0;
      trả lại ENV_INVALID_VALUE;
  }

Chức năng này được cung cấp tham số ZZ0000ZZ trong trường hợp một số bộ nhớ bị thiếu.
bắt buộc (như đối với đồng hồ), nhưng các biến môi trường không có thiết lập lại thì không
yêu cầu lưu trữ và có thể bỏ qua đối số đó.
Số lượng biến môi trường yêu cầu lưu trữ bị giới hạn bởi
ZZ0001ZZ, tuy nhiên giới hạn đó không áp dụng cho các biến khác.

Cuối cùng, các ràng buộc về trạng thái chỉ có hiệu lực đối với đồng hồ và chỉ khi
ràng buộc có dạng ZZ0000ZZ. Điều này là do những hạn chế như vậy
được thực hiện khi hết thời gian hẹn giờ.
Thông thường, các biến đồng hồ được đặt lại ngay trước khi kích hoạt bộ hẹn giờ, nhưng điều này
không nhất thiết phải như vậy và các chức năng sẵn có sẽ xử lý việc đó.
Người giám sát mỗi tác vụ có trách nhiệm đảm bảo không còn bộ đếm thời gian nào
chạy khi nhiệm vụ thoát.

Theo mặc định, trình tạo thực hiện bộ tính giờ bằng giờ (cài đặt
ZZ0000ZZ đến ZZ0001ZZ), điều này mang lại khả năng phản hồi tốt hơn
nhưng chi phí cao hơn. Bánh xe hẹn giờ (ZZ0002ZZ) là một lựa chọn thay thế tốt
dành cho các màn hình có nhiều phiên bản (ví dụ: mỗi tác vụ) đạt được hiệu suất thấp hơn
với độ trễ tăng lên nhưng không ảnh hưởng đến độ chính xác.

Nhận xét cuối cùng
-------------

Với việc tổng hợp màn hình tại chỗ bằng cách sử dụng các tập tin tiêu đề và
rvgen, công việc của nhà phát triển chỉ nên giới hạn ở phần thiết bị đo đạc
của hệ thống, tăng độ tin cậy trong cách tiếp cận tổng thể.

[1] Để biết chi tiết về định dạng automata xác định và bản dịch
từ cách trình bày này sang cách trình bày khác, xem::

Tài liệu/trace/rv/deterministic_automata.rst

[2] rvgen gắn thêm hậu tố tên của màn hình vào các sự kiện để
tránh các biến xung đột khi xuất vmlinux.h toàn cầu
sử dụng bởi các chương trình BPF.
