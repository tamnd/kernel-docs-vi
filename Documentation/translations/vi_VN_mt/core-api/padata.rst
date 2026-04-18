.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/padata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================
Cơ chế thực thi song song paddata
=======================================

:Ngày: Tháng 5 năm 2020

Padata là một cơ chế mà kernel có thể thực hiện các công việc trong
song song trên nhiều CPU trong khi vẫn giữ nguyên thứ tự tùy ý của chúng.

Ban đầu nó được phát triển cho IPsec, cần thực hiện mã hóa và
giải mã số lượng lớn các gói mà không cần sắp xếp lại các gói đó.  Cái này
hiện là người tiêu dùng duy nhất hỗ trợ công việc được đăng nhiều kỳ của padata.

Padata còn hỗ trợ các công việc đa luồng, chia đều công việc trong khi tải
cân bằng và phối hợp giữa các luồng.

Chạy các công việc được tuần tự hóa
=======================

Đang khởi tạo
------------

Bước đầu tiên trong việc sử dụng paddata để chạy các công việc được tuần tự hóa là thiết lập một
Cấu trúc paddata_instance để kiểm soát tổng thể cách thức chạy các công việc::

#include <linux/padata.h>

cấu trúc paddata_instance *padata_alloc(const char *name);

'tên' chỉ đơn giản là xác định trường hợp.

Sau đó, hoàn tất quá trình khởi tạo paddata bằng cách phân bổ paddata_shell::

cấu trúc paddata_shell *padata_alloc_shell(struct padata_instance *pinst);

Một paddata_shell được sử dụng để gửi một công việc tới paddata và cho phép một loạt các công việc như vậy
công việc được đăng tuần tự độc lập.  Một paddata_instance có thể có một hoặc nhiều
paddata_shells được liên kết với nó, mỗi cái cho phép một chuỗi công việc riêng biệt.

Sửa đổi cpumasks
------------------

Các CPU được sử dụng để chạy các công việc có thể được thay đổi theo hai cách, bằng lập trình với
paddata_set_cpumask() hoặc qua sysfs.  Cái trước được định nghĩa::

int paddata_set_cpumask(struct paddata_instance *pinst, int cpumask_type,
			   cpumask_var_t cpumask);

Ở đây cpumask_type là một trong PADATA_CPU_PARALLEL hoặc PADATA_CPU_SERIAL, trong đó
cpumask song song mô tả bộ xử lý nào sẽ được sử dụng để thực hiện công việc
được gửi song song tới trường hợp này và một cpumask nối tiếp xác định cái nào
bộ xử lý được phép sử dụng làm bộ xử lý gọi lại tuần tự hóa.
cpumask chỉ định cpumask mới để sử dụng.

Có thể có các tệp sysfs cho cpumasks của một phiên bản.  Ví dụ: pcrypt
sống trong /sys/kernel/pcrypt/<instance-name>.  Trong thư mục của một cá thể
có hai tệp, Parallel_cpumask và serial_cpumask và cpumask
có thể được thay đổi bằng cách lặp lại bitmask vào tệp, ví dụ::

echo f > /sys/kernel/pcrypt/pencrypt/parallel_cpumask

Việc đọc một trong các tệp này sẽ hiển thị cpumask do người dùng cung cấp, có thể là
khác với cpumask 'có thể sử dụng được'.

Padata duy trì hai cặp cpumasks nội bộ, cpumasks do người dùng cung cấp
và cpumasks 'có thể sử dụng'.  (Mỗi cặp bao gồm một tín hiệu song song và nối tiếp
cpumask.) CPUmasks do người dùng cung cấp mặc định cho tất cả các CPU có thể có.
phân bổ và có thể được thay đổi như trên.  Các cpumask có thể sử dụng được luôn là một
tập hợp con của cpumasks do người dùng cung cấp và chỉ chứa các CPU trực tuyến trong
khẩu trang do người dùng cung cấp; đây là những cpumasks paddata thực sự sử dụng.  Vì vậy nó là
hợp pháp để cung cấp cpumask cho paddata chứa CPU ngoại tuyến.  Một lần
CPU ngoại tuyến trong cpumask do người dùng cung cấp trực tuyến, paddata sẽ sử dụng
nó.

Thay đổi mặt nạ CPU là một thao tác tốn kém, vì vậy không nên thực hiện bằng
tần số lớn.

Chạy một công việc
-------------

Trên thực tế, việc gửi công việc tới phiên bản paddata yêu cầu tạo một
Cấu trúc paddata_priv, đại diện cho một công việc::

cấu trúc paddata_priv {
        /* Những thứ khác ở đây... */
	khoảng trống (*parallel)(struct padata_priv *padata);
	khoảng trống (*serial)(struct padata_priv *padata);
    };

Cấu trúc này gần như chắc chắn sẽ được nhúng vào trong một số
cấu trúc cụ thể cho công việc cần thực hiện.  Hầu hết các lĩnh vực của nó là riêng tư đối với
paddata, nhưng cấu trúc phải bằng 0 tại thời điểm khởi tạo và
Cần cung cấp các hàm song song() và nối tiếp().  Những chức năng đó sẽ
được gọi trong quá trình hoàn thành công việc như chúng ta sẽ thấy
trong giây lát.

Việc gửi công việc được thực hiện với::

int paddata_do_parallel(struct paddata_shell *ps,
		           cấu trúc paddata_priv *padata, int *cb_cpu);

Cấu trúc ps và paddata phải được thiết lập như mô tả ở trên; cb_cpu
trỏ đến CPU ưu tiên sẽ được sử dụng cho cuộc gọi lại cuối cùng khi công việc được hoàn thành
xong; nó phải nằm trong mặt nạ CPU của phiên bản hiện tại (nếu không phải là con trỏ cb_cpu
được cập nhật để trỏ đến CPU thực sự được chọn).  Giá trị trả về từ
paddata_do_parallel() là 0 nếu thành công, cho biết rằng công việc đang được thực hiện
tiến bộ. -EBUSY có nghĩa là ai đó, ở một nơi nào khác đang gây rối với
mặt nạ CPU của phiên bản, trong khi -EINVAL là lời phàn nàn về việc cb_cpu không có trong
cpumask nối tiếp, không có CPU trực tuyến trong cpumasks song song hoặc nối tiếp hoặc đã dừng
ví dụ.

Mỗi công việc được gửi tới paddata_do_parallel() sẽ lần lượt được chuyển đến
chính xác một lệnh gọi đến hàm Parallel() đã đề cập ở trên, trên một CPU, vì vậy
sự song song thực sự đạt được bằng cách gửi nhiều công việc.  song song() chạy với
ngắt phần mềm bị vô hiệu hóa và do đó không thể ngủ.  Sự song song()
hàm lấy con trỏ cấu trúc paddata_priv làm tham số duy nhất của nó;
thông tin về công việc thực tế cần thực hiện có thể thu được bằng cách sử dụng
container_of() để tìm cấu trúc kèm theo.

Lưu ý rằng Parallel() không có giá trị trả về; hệ thống con paddata giả định rằng
Parallel() sẽ chịu trách nhiệm về công việc kể từ thời điểm này.  công việc
không cần phải hoàn thành trong cuộc gọi này, nhưng, nếu Parallel() không hoạt động
xuất sắc, nên chuẩn bị sẵn sàng để được gọi lại với công việc mới trước khi
cái trước hoàn thành.

Công việc tuần tự hóa
----------------

Khi một công việc hoàn thành, song song() (hoặc bất kỳ chức năng nào thực sự kết thúc
công việc) nên thông báo cho padata về thực tế bằng cách gọi tới ::

void paddata_do_serial(struct paddata_priv *padata);

Tại một thời điểm nào đó trong tương lai, paddata_do_serial() sẽ kích hoạt lệnh gọi tới
hàm serial() trong cấu trúc paddata_priv.  Cuộc gọi đó sẽ diễn ra vào
CPU được yêu cầu trong lệnh gọi đầu tiên tới paddata_do_parallel(); nó cũng vậy
chạy với các ngắt phần mềm cục bộ bị vô hiệu hóa.
Lưu ý rằng cuộc gọi này có thể bị hoãn lại một thời gian vì mã paddata mất
nỗ lực đảm bảo rằng các công việc được hoàn thành theo đúng thứ tự
đã gửi.

Phá hủy
----------

Việc dọn dẹp một phiên bản paddata có thể dự đoán được liên quan đến việc gọi hai phiên bản miễn phí
các hàm tương ứng với việc phân bổ ngược lại::

void paddata_free_shell(struct paddata_shell *ps);
    void paddata_free(struct paddata_instance *pinst);

Trách nhiệm của người dùng là đảm bảo tất cả các công việc còn tồn đọng được hoàn thành
trước khi bất kỳ điều nào ở trên được gọi.

Chạy công việc đa luồng
==========================

Một công việc đa luồng có một luồng chính và không có hoặc nhiều luồng trợ giúp, với
luồng chính tham gia vào công việc và sau đó đợi cho đến khi tất cả những người trợ giúp đã hoàn thành
đã xong.  paddata chia công việc thành các đơn vị gọi là chunk, trong đó chunk là
phần công việc mà một luồng hoàn thành trong một lần gọi hàm luồng.

Người dùng phải thực hiện ba việc để chạy một công việc đa luồng.  Đầu tiên, hãy mô tả các
công việc bằng cách xác định cấu trúc paddata_mt_job, được giải thích trong Giao diện
phần.  Điều này bao gồm một con trỏ tới hàm luồng, mà paddata sẽ
gọi mỗi lần nó gán một đoạn công việc cho một luồng.  Sau đó, xác định chủ đề
hàm chấp nhận ba đối số, ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ, trong đó
hai cái đầu tiên phân định phạm vi mà luồng hoạt động và cái cuối cùng là
con trỏ tới trạng thái chia sẻ của công việc, nếu có.  Chuẩn bị trạng thái chia sẻ, đó là
thường được phân bổ trên ngăn xếp của luồng chính.  Cuối cùng, hãy gọi
paddata_do_multithreaded(), sẽ trả về sau khi công việc kết thúc.

Giao diện
=========

.. kernel-doc:: include/linux/padata.h
.. kernel-doc:: kernel/padata.c