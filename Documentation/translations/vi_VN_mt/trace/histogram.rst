.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/histogram.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Biểu đồ sự kiện
================

Tài liệu được viết bởi Tom Zanussi

1. Giới thiệu
===============

Trình kích hoạt biểu đồ là các trình kích hoạt sự kiện đặc biệt có thể được sử dụng để
  tổng hợp dữ liệu sự kiện theo dõi thành biểu đồ.  Để biết thông tin về
  theo dõi sự kiện và trình kích hoạt sự kiện, xem Tài liệu/trace/events.rst.


2. Lệnh kích hoạt biểu đồ
============================

Lệnh kích hoạt biểu đồ là lệnh kích hoạt sự kiện
  tổng hợp các lần truy cập sự kiện vào một bảng băm được khóa trên một hoặc nhiều dấu vết
  các trường định dạng sự kiện (hoặc stacktrace) và một tập hợp tổng số đang chạy
  bắt nguồn từ một hoặc nhiều trường và/hoặc sự kiện định dạng sự kiện theo dõi
  số lượng (hitcount).

Định dạng của trình kích hoạt lịch sử như sau::

hist:keys=<field1[,field2,...]>[:values=<field1[,field2,...]>]
          [:sort=<field1[,field2,...]>][:size=#entries][:pause][:continue]
          [:clear][:name=histname1][:nohitcount][:<handler>.<action>] [if <filter>]

Khi một sự kiện phù hợp được nhấn, một mục nhập sẽ được thêm vào bảng băm
  sử dụng (các) khóa và (các) giá trị được đặt tên.  Các khóa và giá trị tương ứng với
  các trường trong mô tả định dạng của sự kiện.  Các giá trị phải tương ứng với
  trường số - trên một lần truy cập sự kiện, (các) giá trị sẽ được thêm vào một
  tổng được giữ cho trường đó.  Có thể sử dụng chuỗi đặc biệt 'hitcount'
  thay cho trường giá trị rõ ràng - đây chỉ đơn giản là số lượng
  lượt truy cập sự kiện.  Nếu 'giá trị' không được chỉ định, một 'số lần truy cập' ngầm định
  value sẽ được tự động tạo và sử dụng làm giá trị duy nhất.
  Khóa có thể là trường bất kỳ hoặc chuỗi đặc biệt 'common_stacktrace',
  sẽ sử dụng kernel stacktrace của sự kiện làm khóa.  Các từ khóa
  'phím' hoặc 'khóa' có thể được sử dụng để chỉ định khóa và từ khóa
  'values', 'vals' hoặc 'val' có thể được sử dụng để chỉ định giá trị.  hợp chất
  các khóa bao gồm tối đa ba trường có thể được chỉ định bởi 'phím'
  từ khóa.  Băm một khóa ghép sẽ tạo ra một mục nhập duy nhất trong
  bảng cho mỗi tổ hợp khóa thành phần duy nhất và có thể
  hữu ích để cung cấp các bản tóm tắt chi tiết hơn về dữ liệu sự kiện.
  Ngoài ra, các khóa sắp xếp bao gồm tối đa hai trường có thể được
  được chỉ định bởi từ khóa 'sắp xếp'.  Nếu có nhiều hơn một trường
  được chỉ định, kết quả sẽ là 'sắp xếp trong một sắp xếp': khóa đầu tiên
  được coi là khóa sắp xếp chính và khóa thứ hai là khóa phụ
  chìa khóa.  Nếu trình kích hoạt lịch sử được đặt tên bằng tham số 'name',
  dữ liệu biểu đồ của nó sẽ được chia sẻ với các trình kích hoạt khác cùng loại
  tên và lần truy cập kích hoạt sẽ cập nhật dữ liệu chung này.  Chỉ trình kích hoạt
  với các trường 'tương thích' có thể được kết hợp theo cách này; kích hoạt là
  'tương thích' nếu các trường có tên trong trình kích hoạt giống nhau
  số lượng và loại trường và các trường đó cũng có cùng tên.
  Lưu ý rằng hai sự kiện bất kỳ luôn có chung 'số lần truy cập' tương thích và
  các trường 'common_stacktrace' và do đó có thể được kết hợp bằng cách sử dụng các trường đó
  các lĩnh vực, tuy nhiên điều đó có thể vô nghĩa.

Trình kích hoạt 'lịch sử' thêm tệp 'lịch sử' vào thư mục con của mỗi sự kiện.
  Đọc tệp 'lịch sử' cho sự kiện sẽ kết xuất bảng băm vào
  toàn bộ nó thành thiết bị xuất chuẩn.  Nếu có nhiều trình kích hoạt lịch sử
  gắn liền với một sự kiện, sẽ có một bảng cho mỗi lần kích hoạt trong
  đầu ra.  Bảng được hiển thị cho trình kích hoạt được đặt tên sẽ giống như
  bất kỳ trường hợp nào khác có cùng tên. Mỗi bảng băm được in
  mục nhập là một danh sách đơn giản gồm các khóa và giá trị bao gồm mục nhập;
  các phím được in đầu tiên và được phân định bằng dấu ngoặc nhọn và được
  theo sau là tập hợp các trường giá trị cho mục nhập.  Theo mặc định,
  các trường số được hiển thị dưới dạng số nguyên cơ số 10.  Đây có thể là
  được sửa đổi bằng cách thêm bất kỳ công cụ sửa đổi nào sau đây vào trường
  tên:

====================================================================
        .hex hiển thị một số dưới dạng giá trị hex
	.sym hiển thị địa chỉ dưới dạng ký hiệu
	.sym-offset hiển thị địa chỉ dưới dạng ký hiệu và offset
	.syscall hiển thị id cuộc gọi hệ thống dưới dạng tên cuộc gọi hệ thống
	.execname hiển thị common_pid làm tên chương trình
	.log2 hiển thị giá trị log2 thay vì số nguyên
	.buckets=size hiển thị nhóm các giá trị thay vì số nguyên
	.usecs hiển thị common_timestamp tính bằng micro giây
        .percent hiển thị một số giá trị phần trăm
        .graph hiển thị biểu đồ thanh của một giá trị
	.stacktrace hiển thị dưới dạng stacktrace (phải là loại long[])
	====================================================================

Lưu ý rằng nói chung ngữ nghĩa của một trường nhất định không
  được giải thích khi áp dụng một công cụ sửa đổi cho nó, nhưng có một số
  những hạn chế cần lưu ý về vấn đề này:

- chỉ có thể sử dụng công cụ sửa đổi 'hex' cho các giá trị (vì các giá trị
      về cơ bản là tổng và các sửa đổi khác không có ý nghĩa
      trong bối cảnh đó).
    - chỉ có thể sử dụng công cụ sửa đổi 'execname' trên 'common_pid'.  các
      lý do cho điều này là tên thực thi chỉ đơn giản là giá trị 'comm'
      được lưu cho quy trình 'hiện tại' khi một sự kiện được kích hoạt,
      giống với giá trị common_pid được sự kiện lưu
      mã truy tìm.  Đang cố gắng áp dụng giá trị comm đó cho pid khác
      các giá trị sẽ không chính xác và thông thường các sự kiện quan tâm lưu
      các trường comm dành riêng cho pid trong chính sự kiện đó.

Kịch bản sử dụng thông thường sẽ như sau để kích hoạt lịch sử
  kích hoạt, đọc nội dung hiện tại của nó rồi tắt nó đi::

# echo 'hist:keys=skbaddr.hex:vals=len' > \
      /sys/kernel/tracing/events/net/netif_rx/trigger

# cat /sys/kernel/tracing/events/net/netif_rx/hist

# echo '!hist:keys=skbaddr.hex:vals=len' > \
      /sys/kernel/tracing/events/net/netif_rx/trigger

Bản thân tệp kích hoạt có thể được đọc để hiển thị chi tiết về
  trình kích hoạt lịch sử hiện được đính kèm.  Thông tin này cũng được hiển thị
  ở đầu tệp 'lịch sử' khi đọc.

Theo mặc định, kích thước của bảng băm là 2048 mục.  'Kích thước'
  tham số có thể được sử dụng để chỉ định nhiều hơn hoặc ít hơn thế.  các đơn vị
  xét về mặt các mục có thể băm - nếu một lần chạy sử dụng nhiều mục hơn
  được chỉ định, kết quả sẽ hiển thị số lượng “giọt”, số
  trong số lượt truy cập bị bỏ qua.  Kích thước phải là lũy thừa của 2 giữa
  128 và 131072 (bất kỳ số nào không phải lũy thừa 2 được chỉ định sẽ được làm tròn
  lên).

Tham số 'sắp xếp' có thể được sử dụng để chỉ định trường giá trị cần sắp xếp
  trên.  Mặc định nếu không được chỉ định là 'hitcount' và sắp xếp mặc định
  thứ tự là 'tăng dần'.  Để sắp xếp theo hướng ngược lại, hãy nối thêm
  .descending' vào phím sắp xếp.

Tham số 'tạm dừng' có thể được sử dụng để tạm dừng trình kích hoạt lịch sử hiện có
  hoặc để bắt đầu kích hoạt lịch sử nhưng không ghi lại bất kỳ sự kiện nào cho đến khi được yêu cầu thực hiện
  vậy.  'tiếp tục' hoặc 'tiếp tục' có thể được sử dụng để bắt đầu hoặc khởi động lại một chương trình bị tạm dừng
  kích hoạt lịch sử.

Tham số 'clear' sẽ xóa nội dung của lịch sử đang chạy
  kích hoạt và rời khỏi trạng thái tạm dừng/hoạt động hiện tại của nó.

Lưu ý rằng các thông số 'tạm dừng', 'tiếp' và 'xóa' phải là
  được áp dụng bằng cách sử dụng toán tử shell 'chắp thêm' ('>>') nếu được áp dụng cho một
  trình kích hoạt hiện tại, thay vì thông qua toán tử '>', điều này sẽ gây ra
  kích hoạt sẽ được loại bỏ thông qua việc cắt ngắn.

Tham số 'nohitcount' (hoặc NOHC) sẽ ngăn chặn hiển thị
  số lần truy cập thô trong biểu đồ. Tùy chọn này yêu cầu ít nhất một
  trường giá trị không phải là 'số lần truy cập thô'. Ví dụ,
  'hist:...:vals=hitcount:nohitcount' bị từ chối, nhưng
  'hist:...:vals=hitcount.percent:nohitcount' là được.

- kích hoạt_hist/vô hiệu hóa_hist

Có thể sử dụng trình kích hoạt Enable_hist và vô hiệu hóa_hist để có một trình kích hoạt
  sự kiện có điều kiện bắt đầu và dừng sự kiện khác đã được đính kèm
  kích hoạt lịch sử.  Bất kỳ số lượng trình kích hoạt allow_hist và vô hiệu hóa_hist nào
  có thể được gắn vào một sự kiện nhất định, cho phép sự kiện đó bắt đầu
  và ngừng tổng hợp trên một loạt các sự kiện khác.

Định dạng này rất giống với trình kích hoạt Enable/disable_event::

Enable_hist:<system>:<event>[:count]
      vô hiệu hóa_hist:<system>:<event>[:count]

Thay vì bật hoặc tắt tính năng theo dõi sự kiện mục tiêu
  vào bộ đệm theo dõi như các trình kích hoạt bật/tắt_event thực hiện,
  kích hoạt bật/tắt_hist kích hoạt hoặc vô hiệu hóa việc tổng hợp
  sự kiện mục tiêu vào một bảng băm.

Tình huống sử dụng điển hình cho trình kích hoạt Enable_hist/disable_hist
  trước tiên sẽ là thiết lập trình kích hoạt lịch sử bị tạm dừng đối với một số sự kiện,
  theo sau là cặp Enable_hist/disable_hist để chuyển lịch sử
  bật và tắt tổng hợp khi đạt được điều kiện quan tâm::

# echo 'hist:keys=skbaddr.hex:vals=len:pause' > \
      /sys/kernel/tracing/events/net/netif_receive_skb/trigger

# echo 'enable_hist:net:netif_receive_skb if filename==/usr/bin/wget' > \
      /sys/kernel/tracing/events/sched/sched_process_exec/trigger

# echo 'disable_hist:net:netif_receive_skb if comm==wget' > \
      /sys/kernel/tracing/events/sched/sched_process_exit/trigger

Ở trên thiết lập trình kích hoạt lịch sử bị tạm dừng ban đầu không bị tạm dừng
  và bắt đầu tổng hợp các sự kiện khi một chương trình nhất định được thực thi và
  dừng tổng hợp khi quá trình thoát và kích hoạt lịch sử
  lại bị tạm dừng.

Các ví dụ dưới đây cung cấp một minh họa cụ thể hơn về
  các khái niệm và mô hình sử dụng điển hình đã thảo luận ở trên.

2.1. trường sự kiện 'đặc biệt'
---------------------------

Có một số 'trường sự kiện đặc biệt' có sẵn để sử dụng làm
  khóa hoặc giá trị trong trình kích hoạt lịch sử.  Chúng trông giống và hoạt động như thể
  chúng là các trường sự kiện thực tế nhưng không thực sự là một phần của sự kiện
  định nghĩa trường hoặc tập tin định dạng.  Tuy nhiên, chúng có sẵn cho bất kỳ
  sự kiện và có thể được sử dụng ở bất cứ nơi nào có trường sự kiện thực tế.
  Họ là:

======================================================================
    Dấu thời gian common_timestamp u64 (từ bộ đệm vòng) được liên kết
                                với sự kiện, tính bằng nano giây.  Có thể
			        được sửa đổi bởi .usecs để có dấu thời gian
			        được hiểu là micro giây.
    common_cpu int cpu nơi sự kiện xảy ra.
    ======================================================================

2.2. Thông tin lỗi mở rộng
-------------------------------

Đối với một số điều kiện lỗi gặp phải khi gọi trình kích hoạt lịch sử
  lệnh, thông tin lỗi mở rộng có sẵn thông qua
  tập tin truy tìm/error_log.  Xem phần "Điều kiện lỗi" trong
  Tài liệu/trace/ftrace.rst để biết chi tiết.

2.3. ví dụ về trình kích hoạt 'lịch sử'
----------------------------

Tập ví dụ đầu tiên tạo tập hợp bằng cách sử dụng kmalloc
  sự kiện.  Các trường có thể được sử dụng cho trình kích hoạt lịch sử được liệt kê
  trong tệp định dạng của sự kiện kmalloc::

# cat /sys/kernel/tracing/events/kmem/kmalloc/format
    Tên: kmalloc
    Mã số: 374
    định dạng:
	trường:unsigned short common_type;	bù đắp: 0;	kích thước:2;	đã ký: 0;
	trường: char không dấu common_flags;	bù đắp:2;	kích thước: 1;	đã ký: 0;
	trường: char không dấu common_preempt_count;		bù đắp:3;	kích thước: 1;	đã ký: 0;
	trường:int common_pid;					bù đắp:4;	kích thước:4;	đã ký: 1;

trường:cuộc gọi dài không dấu_site;				bù đắp: 8;	kích thước:8;	đã ký: 0;
	trường:const void * ptr;					bù đắp:16;	kích thước:8;	đã ký: 0;
	trường:size_t byte_req;					bù đắp:24;	kích thước:8;	đã ký: 0;
	trường:size_t byte_alloc;				bù đắp:32;	kích thước:8;	đã ký: 0;
	trường:gfp_t gfp_flags;					bù đắp:40;	kích thước:4;	đã ký: 0;

Chúng ta sẽ bắt đầu bằng cách tạo một trình kích hoạt lịch sử để tạo một bảng đơn giản
  liệt kê tổng số byte được yêu cầu cho mỗi chức năng trong
  kernel đã thực hiện một hoặc nhiều lệnh gọi tới kmalloc::

# echo 'hist:key=call_site:val=bytes_req.buckets=32' > \
            /sys/kernel/tracing/events/kmem/kmalloc/trigger

Điều này yêu cầu hệ thống theo dõi tạo trình kích hoạt 'lịch sử' bằng cách sử dụng
  Trường call_site của sự kiện kmalloc làm khóa cho bảng,
  chỉ có nghĩa là mỗi địa chỉ call_site duy nhất sẽ có một mục nhập
  được tạo cho nó trong bảng.  Tham số 'val=bytes_req' cho biết
  trình kích hoạt lịch sử cho mỗi mục nhập duy nhất (call_site) trong
  bảng, nó sẽ giữ tổng số byte đang chạy
  được yêu cầu bởi call_site đó.

Chúng ta sẽ để nó chạy một lúc rồi hủy nội dung của 'lịch sử'
  tập tin trong thư mục con của sự kiện kmalloc (để dễ đọc, một số
  của các mục đã bị bỏ qua)::

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site:vals=bytes_req:sort=hitcount:size=2048 [hoạt động]

{ call_site: 18446744072106379007 } số lần truy cập: 1 byte_req: 176
    { call_site: 18446744071579557049 } số lần truy cập: 1 byte_req: 1024
    { call_site: 18446744071580608289 } số lần truy cập: 1 byte_req: 16384
    { call_site: 18446744071581827654 } số lần truy cập: 1 byte_req: 24
    { call_site: 18446744071580700980 } số lần truy cập: 1 byte_req: 8
    { call_site: 18446744071579359876 } số lần truy cập: 1 byte_req: 152
    { call_site: 18446744071580795365 } số lần truy cập: 3 byte_req: 144
    { call_site: 18446744071581303129 } số lần truy cập: 3 byte_req: 144
    { call_site: 18446744071580713234 } số lần truy cập: 4 byte_req: 2560
    { call_site: 18446744071580933750 } số lần truy cập: 4 byte_req: 736
    .
    .
    .
    { call_site: 18446744072106047046 } số lần truy cập: 69 byte_req: 5576
    { call_site: 18446744071582116407 } số lần truy cập: 73 byte_req: 2336
    { call_site: 18446744072106054684 } số lần truy cập: 136 byte_req: 140504
    { call_site: 18446744072106224230 } số lần truy cập: 136 byte_req: 19584
    { call_site: 18446744072106078074 } số lần truy cập: 153 byte_req: 2448
    { call_site: 18446744072106062406 } số lần truy cập: 153 byte_req: 36720
    { call_site: 18446744071582507929 } số lần truy cập: 153 byte_req: 37088
    { call_site: 18446744072102520590 } số lần truy cập: 273 byte_req: 10920
    { call_site: 18446744071582143559 } số lần truy cập: 358 byte_req: 716
    { call_site: 18446744072106465852 } số lần truy cập: 417 byte_req: 56712
    { call_site: 18446744072102523378 } số lần truy cập: 485 byte_req: 27160
    { call_site: 18446744072099568646 } số lần truy cập: 1676 byte_req: 33520

Tổng số:
        Lượt truy cập: 4610
        Bài dự thi: 45
        Đã đánh rơi: 0

Đầu ra hiển thị một dòng cho mỗi mục, bắt đầu bằng phím
  được chỉ định trong trình kích hoạt, theo sau là (các) giá trị cũng được chỉ định trong
  cò súng.  Ở đầu đầu ra là một dòng hiển thị
  thông tin kích hoạt, cũng có thể được hiển thị bằng cách đọc
  tập tin 'kích hoạt'::

# cat /sys/kernel/tracing/events/kmem/kmalloc/trigger
    lịch sử:keys=call_site:vals=bytes_req:sort=hitcount:size=2048 [hoạt động]

Ở cuối đầu ra là một vài dòng hiển thị tổng thể
  tổng số cho cuộc chạy.  Trường 'Số lần truy cập' hiển thị tổng số
  số lần kích hoạt sự kiện được nhấn, trường 'Mục nhập' hiển thị tổng số lần
  số mục được sử dụng trong bảng băm và trường 'Đã loại bỏ'
  hiển thị số lượt truy cập bị bỏ vì số lượng
  các mục đã sử dụng cho lần chạy đã vượt quá số lượng mục nhập tối đa
  được phép đối với bảng (thông thường là 0, nhưng nếu không phải là gợi ý rằng bạn có thể
  muốn tăng kích thước của bảng bằng tham số 'size').

Lưu ý ở kết quả đầu ra ở trên có một trường bổ sung, 'hitcount',
  không được chỉ định trong trình kích hoạt.  Cũng lưu ý rằng trong
  đầu ra thông tin kích hoạt, có một tham số, 'sort=hitcount', tham số này
  cũng không được chỉ định trong trình kích hoạt.  Lý do cho điều đó là
  mọi trình kích hoạt đều ngầm đếm tổng số lần truy cập
  được quy cho một mục nhất định, được gọi là 'số lần truy cập'.  Số lần truy cập đó
  thông tin được hiển thị rõ ràng ở đầu ra và trong
  sự vắng mặt của tham số sắp xếp do người dùng chỉ định, được sử dụng làm mặc định
  trường sắp xếp.

Giá trị 'hitcount' có thể được sử dụng thay cho giá trị rõ ràng trong
  tham số 'giá trị' nếu bạn không thực sự cần có bất kỳ tham số nào
  lĩnh vực cụ thể được tóm tắt và chủ yếu quan tâm đến lượt truy cập
  tần số.

Để tắt trình kích hoạt lịch sử, chỉ cần gọi trình kích hoạt trong
  lịch sử lệnh và thực hiện lại nó bằng dấu '!' thêm vào trước::

# echo '!hist:key=call_site:val=bytes_req' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

Cuối cùng, hãy lưu ý rằng call_site như được hiển thị ở đầu ra ở trên
  không thực sự rất hữu ích.  Đó là một địa chỉ, nhưng thông thường là địa chỉ
  được hiển thị ở dạng hex.  Để có một trường số được hiển thị dưới dạng hex
  giá trị, chỉ cần thêm '.hex' vào tên trường trong trình kích hoạt::

# echo 'hist:key=call_site.hex:val=bytes_req' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site.hex:vals=bytes_req:sort=hitcount:size=2048 [hoạt động]

{ call_site: ffffffffa026b291 } số lần truy cập: 1 byte_req: 433
    { call_site: ffffffffa07186ff } số lần truy cập: 1 byte_req: 176
    { call_site: ffffffff811ae721 } số lần truy cập: 1 byte_req: 16384
    { call_site: ffffffff811c5134 } số lần truy cập: 1 byte_req: 8
    { call_site: ffffffffa04a9ebb } số lần truy cập: 1 byte_req: 511
    { call_site: ffffffff8122e0a6 } số lần truy cập: 1 byte_req: 12
    { call_site: ffffffff8107da84 } số lần truy cập: 1 byte_req: 152
    { call_site: ffffffff812d8246 } số lần truy cập: 1 byte_req: 24
    { call_site: ffffffff811dc1e5 } số lần truy cập: 3 byte_req: 144
    { call_site: ffffffffa02515e8 } số lần truy cập: 3 byte_req: 648
    { call_site: ffffffff81258159 } số lần truy cập: 3 byte_req: 144
    { call_site: ffffffff811c80f4 } số lần truy cập: 4 byte_req: 544
    .
    .
    .
    { call_site: ffffffffa06c7646 } số lần truy cập: 106 byte_req: 8024
    { call_site: ffffffffa06cb246 } số lần truy cập: 132 byte_req: 31680
    { call_site: ffffffffa06cef7a } số lần truy cập: 132 byte_req: 2112
    { call_site: ffffffff8137e399 } số lần truy cập: 132 byte_req: 23232
    { call_site: ffffffffa06c941c } số lần truy cập: 185 byte_req: 171360
    { call_site: ffffffffa06f2a66 } số lần truy cập: 185 byte_req: 26640
    { call_site: ffffffffa036a70e } số lần truy cập: 265 byte_req: 10600
    { call_site: ffffffff81325447 } số lần truy cập: 292 byte_req: 584
    { call_site: ffffffffa072da3c } số lần truy cập: 446 byte_req: 60656
    { call_site: ffffffffa036b1f2 } số lần truy cập: 526 byte_req: 29456
    { call_site: ffffffffa0099c06 } số lần truy cập: 1780 byte_req: 35600

Tổng số:
        Lượt truy cập: 4775
        Bài dự thi: 46
        Đã đánh rơi: 0

Thậm chí điều đó chỉ hữu ích hơn một chút - trong khi các giá trị hex có vẻ như
  giống địa chỉ hơn, người dùng thường quan tâm đến điều gì hơn
  khi nhìn vào địa chỉ văn bản là các ký hiệu tương ứng
  thay vào đó.  Thay vào đó, để có một địa chỉ được hiển thị dưới dạng giá trị ký hiệu,
  chỉ cần thêm '.sym' hoặc '.sym-offset' vào tên trường trong
  kích hoạt::

# echo 'hist:key=call_site.sym:val=bytes_req' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site.sym:vals=bytes_req:sort=hitcount:size=2048 [hoạt động]

{ call_site: [ffffffff810adcb9] syslog_print_all } số lần truy cập: 1 byte_req: 1024
    { call_site: [ffffffff8154bc62] usb_control_msg } số lần truy cập: 1 byte_req: 8
    { call_site: [ffffffffa00bf6fe] hidraw_send_report [hid] } số lần truy cập: 1 byte_req: 7
    { call_site: [ffffffff8154acbe] usb_alloc_urb } số lần truy cập: 1 byte_req: 192
    { call_site: [ffffffffa00bf1ca] hidraw_report_event [hid] } số lần truy cập: 1 byte_req: 7
    { call_site: [ffffffff811e3a25] __seq_open_private } số lần truy cập: 1 byte_req: 40
    { call_site: [ffffffff8109524a] alloc_fair_sched_group } số lần truy cập: 2 byte_req: 128
    { call_site: [ffffffff811febd5] fsnotify_alloc_group } số lần truy cập: 2 byte_req: 528
    { call_site: [ffffffff81440f58] __tty_buffer_request_room } số lần truy cập: 2 byte_req: 2624
    { call_site: [ffffffff81200ba6] inotify_new_group } số lần truy cập: 2 byte_req: 96
    { call_site: [ffffffffa05e19af] ieee80211_start_tx_ba_session [mac80211] } số lần truy cập: 2 byte_req: 464
    { call_site: [ffffffff81672406] tcp_get_metrics } số lần truy cập: 2 byte_req: 304
    { call_site: [ffffffff81097ec2] alloc_rt_sched_group } số lần truy cập: 2 byte_req: 128
    { call_site: [ffffffff81089b05] sched_create_group } số lần truy cập: 2 byte_req: 1424
    .
    .
    .
    { call_site: [ffffffffa04a580c] intel_crtc_page_flip [i915] } số lần truy cập: 1185 byte_req: 123240
    { call_site: [ffffffffa0287592] drm_mode_page_flip_ioctl [drm] } số lần truy cập: 1185 byte_req: 104280
    { call_site: [ffffffffa04c4a3c] intel_plane_duplicate_state [i915] } số lần truy cập: 1402 byte_req: 190672
    { call_site: [ffffffff812891ca] ext4_find_extent } số lần truy cập: 1518 byte_req: 146208
    { call_site: [ffffffffa029070e] drm_vma_node_allow [drm] } số lần truy cập: 1746 byte_req: 69840
    { call_site: [ffffffffa045e7c4] i915_gem_do_execbuffer.isra.23 [i915] } số lần truy cập: 2021 byte_req: 792312
    { call_site: [ffffffffa02911f2] drm_modeset_lock_crtc [drm] } số lần truy cập: 2592 byte_req: 145152
    { call_site: [ffffffffa0489a66] intel_ring_begin [i915] } số lần truy cập: 2629 byte_req: 378576
    { call_site: [ffffffffa046041c] i915_gem_execbuffer2 [i915] } số lần truy cập: 2629 byte_req: 3783248
    { call_site: [ffffffff81325607] apparmor_file_alloc_security } số lần truy cập: 5192 byte_req: 10384
    { call_site: [ffffffffa00b7c06] hid_report_raw_event [hid] } số lần truy cập: 5529 byte_req: 110584
    { call_site: [ffffffff8131ebf7] aa_alloc_task_context } số lần truy cập: 21943 byte_req: 702176
    { call_site: [ffffffff8125847d] ext4_htree_store_dirent } số lần truy cập: 55759 byte_req: 5074265

Tổng số:
        Lượt truy cập: 109928
        Bài dự thi: 71
        Đã đánh rơi: 0

Vì khóa sắp xếp mặc định ở trên là 'hitcount' nên ở trên hiển thị một
  danh sách call_sites bằng cách tăng số lần truy cập, sao cho ở dưới cùng
  chúng tôi thấy các hàm thực hiện nhiều lệnh gọi kmalloc nhất trong
  chạy.  Thay vào đó, nếu chúng tôi muốn thấy những người gọi kmalloc hàng đầu ở
  về số lượng byte được yêu cầu thay vì số lượng
  cuộc gọi và chúng tôi muốn người gọi hàng đầu xuất hiện ở trên cùng, chúng tôi có thể sử dụng
  tham số 'sắp xếp', cùng với công cụ sửa đổi 'giảm dần'::

# echo 'hist:key=call_site.sym:val=bytes_req:sort=bytes_req.descending' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site.sym:vals=bytes_req:sort=bytes_req.descending:size=2048 [hoạt động]

{ call_site: [ffffffffa046041c] i915_gem_execbuffer2 [i915] } số lần truy cập: 2186 byte_req: 3397464
    { call_site: [ffffffffa045e7c4] i915_gem_do_execbuffer.isra.23 [i915] } số lần truy cập: 1790 byte_req: 712176
    { call_site: [ffffffff8125847d] ext4_htree_store_dirent } số lần truy cập: 8132 byte_req: 513135
    { call_site: [ffffffff811e2a1b] seq_buf_alloc } số lần truy cập: 106 byte_req: 440128
    { call_site: [ffffffffa0489a66] intel_ring_begin [i915] } số lần truy cập: 2186 byte_req: 314784
    { call_site: [ffffffff812891ca] ext4_find_extent } số lần truy cập: 2174 byte_req: 208992
    { call_site: [ffffffff811ae8e1] __kmalloc } số lần truy cập: 8 byte_req: 131072
    { call_site: [ffffffffa04c4a3c] intel_plane_duplicate_state [i915] } số lần truy cập: 859 byte_req: 116824
    { call_site: [ffffffffa02911f2] drm_modeset_lock_crtc [drm] } số lần truy cập: 1834 byte_req: 102704
    { call_site: [ffffffffa04a580c] intel_crtc_page_flip [i915] } số lần truy cập: 972 byte_req: 101088
    { call_site: [ffffffffa0287592] drm_mode_page_flip_ioctl [drm] } số lần truy cập: 972 byte_req: 85536
    { call_site: [ffffffffa00b7c06] hid_report_raw_event [hid] } số lần truy cập: 3333 byte_req: 66664
    { call_site: [ffffffff8137e559] sg_kmalloc } số lần truy cập: 209 byte_req: 61632
    .
    .
    .
    { call_site: [ffffffff81095225] alloc_fair_sched_group } số lần truy cập: 2 byte_req: 128
    { call_site: [ffffffff81097ec2] alloc_rt_sched_group } số lần truy cập: 2 byte_req: 128
    { call_site: [ffffffff812d8406] copy_semundo } số lần truy cập: 2 byte_req: 48
    { call_site: [ffffffff81200ba6] inotify_new_group } số lần truy cập: 1 byte_req: 48
    { call_site: [ffffffffa027121a] drm_getmagic [drm] } số lần truy cập: 1 byte_req: 48
    { call_site: [ffffffff811e3a25] __seq_open_private } số lần truy cập: 1 byte_req: 40
    { call_site: [ffffffff811c52f4] bprm_change_interp } số lần truy cập: 2 byte_req: 16
    { call_site: [ffffffff8154bc62] usb_control_msg } số lần truy cập: 1 byte_req: 8
    { call_site: [ffffffffa00bf1ca] hidraw_report_event [hid] } số lần truy cập: 1 byte_req: 7
    { call_site: [ffffffffa00bf6fe] hidraw_send_report [hid] } số lần truy cập: 1 byte_req: 7

Tổng số:
        Lượt truy cập: 32133
        Bài dự thi: 81
        Đã đánh rơi: 0

Để hiển thị thông tin về offset và kích thước ngoài ký hiệu
  tên, thay vào đó chỉ cần sử dụng 'sym-offset' ::

# echo 'hist:key=call_site.sym-offset:val=bytes_req:sort=bytes_req.descending' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site.sym-offset:vals=bytes_req:sort=bytes_req.descending:size=2048 [hoạt động]

{ call_site: [ffffffffa046041c] i915_gem_execbuffer2+0x6c/0x2c0 [i915] } số lần truy cập: 4569 byte_req: 3163720
    { call_site: [ffffffffa0489a66] intel_ring_begin+0xc6/0x1f0 [i915] } số lần truy cập: 4569 byte_req: 657936
    { call_site: [ffffffffa045e7c4] i915_gem_do_execbuffer.isra.23+0x694/0x1020 [i915] } số lần truy cập: 1519 byte_req: 472936
    { call_site: [ffffffffa045e646] i915_gem_do_execbuffer.isra.23+0x516/0x1020 [i915] } số lần truy cập: 3050 byte_req: 211832
    { call_site: [ffffffff811e2a1b] seq_buf_alloc+0x1b/0x50 } số lần truy cập: 34 byte_req: 148384
    { call_site: [ffffffffa04a580c] intel_crtc_page_flip+0xbc/0x870 [i915] } số lần truy cập: 1385 byte_req: 144040
    { call_site: [ffffffff811ae8e1] __kmalloc+0x191/0x1b0 } số lần truy cập: 8 byte_req: 131072
    { call_site: [ffffffffa0287592] drm_mode_page_flip_ioctl+0x282/0x360 [drm] } số lần truy cập: 1385 byte_req: 121880
    { call_site: [ffffffffa02911f2] drm_modeset_lock_crtc+0x32/0x100 [drm] } số lần truy cập: 1848 byte_req: 103488
    { call_site: [ffffffffa04c4a3c] intel_plane_duplicate_state+0x2c/0xa0 [i915] } số lần truy cập: 461 byte_req: 62696
    { call_site: [ffffffffa029070e] drm_vma_node_allow+0x2e/0xd0 [drm] } số lần truy cập: 1541 byte_req: 61640
    { call_site: [ffffffff815f8d7b] sk_prot_alloc+0xcb/0x1b0 } số lần truy cập: 57 byte_req: 57456
    .
    .
    .
    { call_site: [ffffffff8109524a] alloc_fair_sched_group+0x5a/0x1a0 } số lần truy cập: 2 byte_req: 128
    { call_site: [ffffffffa027b921] drm_vm_open_locked+0x31/0xa0 [drm] } số lần truy cập: 3 byte_req: 96
    { call_site: [ffffffff8122e266] proc_self_follow_link+0x76/0xb0 } số lần truy cập: 8 byte_req: 96
    { call_site: [ffffffff81213e80] Load_elf_binary+0x240/0x1650 } số lần truy cập: 3 byte_req: 84
    { call_site: [ffffffff8154bc62] usb_control_msg+0x42/0x110 } số lần truy cập: 1 byte_req: 8
    { call_site: [ffffffffa00bf6fe] hidraw_send_report+0x7e/0x1a0 [hid] } số lần truy cập: 1 byte_req: 7
    { call_site: [ffffffffa00bf1ca] hidraw_report_event+0x8a/0x120 [hid] } số lần truy cập: 1 byte_req: 7

Tổng số:
        Lượt truy cập: 26098
        Bài dự thi: 64
        Đã đánh rơi: 0

Chúng tôi cũng có thể thêm nhiều trường vào tham số 'giá trị'.  cho
  Ví dụ: chúng ta có thể muốn xem tổng số byte được phân bổ
  cùng với các byte được yêu cầu và hiển thị kết quả được sắp xếp theo byte
  được phân bổ theo thứ tự giảm dần::

# echo 'hist:keys=call_site.sym:values=bytes_req,bytes_alloc:sort=bytes_alloc.descending' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=call_site.sym:vals=bytes_req,bytes_alloc:sort=bytes_alloc.descending:size=2048 [hoạt động]

{ call_site: [ffffffffa046041c] i915_gem_execbuffer2 [i915] } số lần truy cập: 7403 byte_req: 4084360 byte_alloc: 5958016
    { call_site: [ffffffff811e2a1b] seq_buf_alloc } số lần truy cập: 541 byte_req: 2213968 byte_alloc: 2228224
    { call_site: [ffffffffa0489a66] intel_ring_begin [i915] } số lần truy cập: 7404 byte_req: 1066176 byte_alloc: 1421568
    { call_site: [ffffffffa045e7c4] i915_gem_do_execbuffer.isra.23 [i915] } số lần truy cập: 1565 byte_req: 557368 byte_alloc: 1037760
    { call_site: [ffffffff8125847d] ext4_htree_store_dirent } số lần truy cập: 9557 byte_req: 595778 byte_alloc: 695744
    { call_site: [ffffffffa045e646] i915_gem_do_execbuffer.isra.23 [i915] } số lần truy cập: 5839 byte_req: 430680 byte_alloc: 470400
    { call_site: [ffffffffa04c4a3c] intel_plane_duplicate_state [i915] } số lần truy cập: 2388 byte_req: 324768 byte_alloc: 458496
    { call_site: [ffffffffa02911f2] drm_modeset_lock_crtc [drm] } số lần truy cập: 3911 byte_req: 219016 byte_alloc: 250304
    { call_site: [ffffffff815f8d7b] sk_prot_alloc } số lần truy cập: 235 byte_req: 236880 byte_alloc: 240640
    { call_site: [ffffffff8137e559] sg_kmalloc } số lần truy cập: 557 byte_req: 169024 byte_alloc: 221760
    { call_site: [ffffffffa00b7c06] hid_report_raw_event [hid] } số lần truy cập: 9378 byte_req: 187548 byte_alloc: 206312
    { call_site: [ffffffffa04a580c] intel_crtc_page_flip [i915] } số lần truy cập: 1519 byte_req: 157976 byte_alloc: 194432
    .
    .
    .
    { call_site: [ffffffff8109bd3b] sched_autogroup_create_attach } số lần truy cập: 2 byte_req: 144 byte_alloc: 192
    { call_site: [ffffffff81097ee8] alloc_rt_sched_group } số lần truy cập: 2 byte_req: 128 byte_alloc: 128
    { call_site: [ffffffff8109524a] alloc_fair_sched_group } số lần truy cập: 2 byte_req: 128 byte_alloc: 128
    { call_site: [ffffffff81095225] alloc_fair_sched_group } số lần truy cập: 2 byte_req: 128 byte_alloc: 128
    { call_site: [ffffffff81097ec2] alloc_rt_sched_group } số lần truy cập: 2 byte_req: 128 byte_alloc: 128
    { call_site: [ffffffff81213e80] Load_elf_binary } số lần truy cập: 3 byte_req: 84 byte_alloc: 96
    { call_site: [ffffffff81079a2e] kthread_create_on_node } số lần truy cập: 1 byte_req: 56 byte_alloc: 64
    { call_site: [ffffffffa00bf6fe] hidraw_send_report [hid] } số lần truy cập: 1 byte_req: 7 byte_alloc: 8
    { call_site: [ffffffff8154bc62] usb_control_msg } số lần truy cập: 1 byte_req: 8 byte_alloc: 8
    { call_site: [ffffffffa00bf1ca] hidraw_report_event [hid] } số lần truy cập: 1 byte_req: 7 byte_alloc: 8

Tổng số:
        Lượt truy cập: 66598
        Bài dự thi: 65
        Đã đánh rơi: 0

Cuối cùng, để kết thúc ví dụ về kmalloc của chúng ta, thay vì chỉ đơn giản là có
  trình kích hoạt lịch sử hiển thị call_sites mang tính biểu tượng, chúng ta có thể có lịch sử
  kích hoạt bổ sung hiển thị bộ đầy đủ các dấu vết ngăn xếp kernel
  dẫn đến mỗi call_site.  Để làm điều đó, chúng ta chỉ cần sử dụng đặc biệt
  giá trị 'common_stacktrace' cho tham số chính::

# echo 'hist:keys=common_stacktrace:values=bytes_req,bytes_alloc:sort=bytes_alloc' > \
           /sys/kernel/tracing/events/kmem/kmalloc/trigger

Trình kích hoạt ở trên sẽ sử dụng dấu vết ngăn xếp hạt nhân có hiệu lực khi một
  sự kiện được kích hoạt làm khóa cho bảng băm.  Điều này cho phép
  liệt kê mọi đường dẫn gọi kernel dẫn đến một đường dẫn cụ thể
  sự kiện, cùng với tổng số các trường sự kiện đang chạy cho
  sự kiện đó.  Ở đây chúng tôi kiểm đếm số byte được yêu cầu và số byte được phân bổ cho
  mọi đường dẫn cuộc gọi trong hệ thống dẫn tới kmalloc (trong trường hợp này
  mọi đường dẫn gọi đến kmalloc để biên dịch kernel)::

# cat /sys/kernel/tracing/events/kmem/kmalloc/hist
    Thông tin về # trigger: hist:keys=common_stacktrace:vals=bytes_req,bytes_alloc:sort=bytes_alloc:size=2048 [hoạt động]

{ common_stacktrace:
         __kmalloc_track_caller+0x10b/0x1a0
         kmemdup+0x20/0x50
         hidraw_report_event+0x8a/0x120 [ẩn]
         hid_report_raw_event+0x3ea/0x440 [ẩn]
         hid_input_report+0x112/0x190 [ẩn]
         hid_irq_in+0xc2/0x260 [usbhid]
         __usb_hcd_giveback_urb+0x72/0x120
         usb_giveback_urb_bh+0x9e/0xe0
         tasklet_hi_action+0xf8/0x100
         __do_softirq+0x114/0x2c0
         irq_exit+0xa5/0xb0
         do_IRQ+0x5a/0xf0
         ret_from_intr+0x0/0x30
         cpuidle_enter+0x17/0x20
         cpu_startup_entry+0x315/0x3e0
         phần còn lại_init+0x7c/0x80
    } số lần truy cập: 3 byte_req: 21 byte_alloc: 24
    { common_stacktrace:
         __kmalloc_track_caller+0x10b/0x1a0
         kmemdup+0x20/0x50
         hidraw_report_event+0x8a/0x120 [ẩn]
         hid_report_raw_event+0x3ea/0x440 [ẩn]
         hid_input_report+0x112/0x190 [ẩn]
         hid_irq_in+0xc2/0x260 [usbhid]
         __usb_hcd_giveback_urb+0x72/0x120
         usb_giveback_urb_bh+0x9e/0xe0
         tasklet_hi_action+0xf8/0x100
         __do_softirq+0x114/0x2c0
         irq_exit+0xa5/0xb0
         do_IRQ+0x5a/0xf0
         ret_from_intr+0x0/0x30
    } số lần truy cập: 3 byte_req: 21 byte_alloc: 24
    { common_stacktrace:
         kmem_cache_alloc_trace+0xeb/0x150
         aa_alloc_task_context+0x27/0x40
         apparmor_cred_prepare+0x1f/0x50
         security_prepare_creds+0x16/0x20
         chuẩn bị_creds+0xdf/0x1a0
         SyS_capset+0xb5/0x200
         system_call_fastpath+0x12/0x6a
    } số lần truy cập: 1 byte_req: 32 byte_alloc: 32
    .
    .
    .
    { common_stacktrace:
         __kmalloc+0x11b/0x1b0
         i915_gem_execbuffer2+0x6c/0x2c0 [i915]
         drm_ioctl+0x349/0x670 [drm]
         do_vfs_ioctl+0x2f0/0x4f0
         SyS_ioctl+0x81/0xa0
         system_call_fastpath+0x12/0x6a
    } số lần truy cập: 17726 byte_req: 13944120 byte_alloc: 19593808
    { common_stacktrace:
         __kmalloc+0x11b/0x1b0
         tải_elf_phdrs+0x76/0xa0
         tải_elf_binary+0x102/0x1650
         search_binary_handler+0x97/0x1d0
         do_execveat_common.isra.34+0x551/0x6e0
         SyS_execve+0x3a/0x50
         return_from_execve+0x0/0x23
    } số lần truy cập: 33348 byte_req: 17152128 byte_alloc: 20226048
    { common_stacktrace:
         kmem_cache_alloc_trace+0xeb/0x150
         apparmor_file_alloc_security+0x27/0x40
         security_file_alloc+0x16/0x20
         get_empty_filp+0x93/0x1c0
         path_openat+0x31/0x5f0
         do_filp_open+0x3a/0x90
         do_sys_open+0x128/0x220
         SyS_open+0x1e/0x20
         system_call_fastpath+0x12/0x6a
    } số lần truy cập: 4766422 byte_req: 9532844 byte_alloc: 38131376
    { common_stacktrace:
         __kmalloc+0x11b/0x1b0
         seq_buf_alloc+0x1b/0x50
         seq_read+0x2cc/0x370
         proc_reg_read+0x3d/0x80
         __vfs_read+0x28/0xe0
         vfs_read+0x86/0x140
         SyS_read+0x46/0xb0
         system_call_fastpath+0x12/0x6a
    } số lần truy cập: 19133 byte_req: 78368768 byte_alloc: 78368768

Tổng số:
        Lượt truy cập: 6085872
        Bài dự thi: 253
        Đã đánh rơi: 0

Nếu bạn khóa trình kích hoạt lịch sử trên common_pid, chẳng hạn để
  thu thập và hiển thị tổng số được sắp xếp cho mỗi quy trình, bạn có thể sử dụng
  công cụ sửa đổi .execname đặc biệt để hiển thị tên thực thi cho
  các quy trình trong bảng chứ không phải là pid thô.  Ví dụ dưới đây
  giữ tổng số byte được đọc trên mỗi quá trình::

# echo 'hist:key=common_pid.execname:val=count:sort=count.descending' > \
           /sys/kernel/tracing/events/syscalls/sys_enter_read/trigger

# cat /sys/kernel/tracing/events/syscalls/sys_enter_read/hist
    Thông tin về # trigger: hist:keys=common_pid.execname:vals=count:sort=count.descending:size=2048 [hoạt động]

{ common_pid: gnome-terminal [ 3196] } số lần truy cập: 280 số: 1093512
    { common_pid: Xorg [ 1309] } số lần truy cập: 525 số lượng: 256640
    { common_pid: compiz [ 2889] } số lần truy cập: 59 số: 254400
    { common_pid: bash [ 8710] } số lần truy cập: 3 lần đếm: 66369
    { common_pid: dbus-daemon-lau [ 8703] } số lần truy cập: 49 số: 47739
    { common_pid: mất cân bằng [ 1252] } số lần truy cập: 27 số: 27648
    { common_pid: 01ifupdown [ 8705] } số lần truy cập: 3 lần đếm: 17216
    { common_pid: dbus-daemon [ 772] } số lần truy cập: 10 số: 12396
    { common_pid: Chủ đề ổ cắm [ 8342] } số lần truy cập: 11 số: 11264
    { common_pid: nm-dhcp-client. [ 8701] } số lần truy cập: 6 số: 7424
    { common_pid: gmain [ 1315] } số lần truy cập: 18 số: 6336
    .
    .
    .
    { common_pid: postgres [ 1892] } số lần truy cập: 2 số: 32
    { common_pid: postgres [ 1891] } số lần truy cập: 2 số: 32
    { common_pid: gmain [ 8704] } số lần truy cập: 2 số: 32
    { common_pid: upstart-dbus-br [ 2740] } số lần truy cập: 21 số đếm: 21
    { common_pid: nm-dispatcher.a [ 8696] } số lần truy cập: 1 lần đếm: 16
    { common_pid: Indicator-datet [ 2904] } số lần truy cập: 1 lần đếm: 16
    { common_pid: gdbus [ 2998] } số lần truy cập: 1 lần đếm: 16
    { common_pid: rtkit-daemon [ 2052] } số lần truy cập: 1 lần đếm: 8
    { common_pid: init [ 1] } số lần truy cập: 2 số đếm: 2

Tổng số:
        Lượt truy cập: 2116
        Bài dự thi: 51
        Đã đánh rơi: 0

Tương tự, nếu bạn khóa trình kích hoạt lịch sử trên id cuộc gọi tòa nhà, chẳng hạn như
  thu thập và hiển thị danh sách các lần truy cập tòa nhà trên toàn hệ thống, bạn có thể sử dụng
  công cụ sửa đổi .syscall đặc biệt để hiển thị tên tòa nhà thay vì
  hơn id thô.  Ví dụ bên dưới giữ tổng số syscall đang chạy
  tính cho hệ thống trong quá trình chạy::

# echo 'hist:key=id.syscall:val=hitcount' > \
           /sys/kernel/tracing/events/raw_syscalls/sys_enter/trigger

# cat /sys/kernel/tracing/events/raw_syscalls/sys_enter/hist
    Thông tin về # trigger: hist:keys=id.syscall:vals=hitcount:sort=hitcount:size=2048 [hoạt động]

{ id: sys_fsync [ 74] } số lần truy cập: 1
    { id: sys_newuname [ 63] } số lần truy cập: 1
    { id: sys_prctl [157] } số lần truy cập: 1
    { id: sys_statfs [137] } số lần truy cập: 1
    { id: sys_symlink [ 88] } số lần truy cập: 1
    { id: sys_sendmmsg [307] } số lần truy cập: 1
    { id: sys_semctl [ 66] } số lần truy cập: 1
    { id: sys_readlink [ 89] } số lần truy cập: 3
    { id: sys_bind [ 49] } số lần truy cập: 3
    { id: sys_getsockname [ 51] } số lần truy cập: 3
    { id: sys_unlink [ 87] } số lần truy cập: 3
    { id: sys_rename [ 82] } số lần truy cập: 4
    { id: known_syscall [ 58] } số lần truy cập: 4
    { id: sys_connect [ 42] } số lần truy cập: 4
    { id: sys_getpid [ 39] } số lần truy cập: 4
    .
    .
    .
    { id: sys_rt_sigprocmask [ 14] } số lần truy cập: 952
    { id: sys_futex [202] } số lần truy cập: 1534
    { id: sys_write [ 1] } số lần truy cập: 2689
    { id: sys_setitimer [ 38] } số lần truy cập: 2797
    { id: sys_read [ 0] } số lần truy cập: 3202
    { id: sys_select [ 23] } số lần truy cập: 3773
    { id: sys_writev [ 20] } số lần truy cập: 4531
    { id: sys_poll [ 7] } số lần truy cập: 8314
    { id: sys_recvmsg [ 47] } số lần truy cập: 13738
    { id: sys_ioctl [ 16] } số lần truy cập: 21843

Tổng số:
        Lượt truy cập: 67612
        Bài dự thi: 72
        Đã đánh rơi: 0

Số lượng cuộc gọi tòa nhà ở trên cung cấp một bức tranh tổng thể sơ bộ về hệ thống
  hoạt động gọi trên hệ thống; ví dụ chúng ta có thể thấy rằng hầu hết
  Lệnh gọi hệ thống phổ biến trên hệ thống này là lệnh gọi hệ thống 'sys_ioctl'.

Chúng ta có thể sử dụng các phím 'ghép' để tinh chỉnh số đó và cung cấp một số
  cái nhìn sâu sắc hơn về những quá trình nào góp phần chính xác vào
  tổng số ioctl.

Lệnh bên dưới giữ số lần truy cập cho mỗi sự kết hợp duy nhất của
  id cuộc gọi hệ thống và pid - kết quả cuối cùng về cơ bản là một bảng
  giữ tổng số lần truy cập cuộc gọi hệ thống trên mỗi pid.  Kết quả là
  được sắp xếp bằng cách sử dụng id cuộc gọi hệ thống làm khóa chính và
  tổng số lần truy cập làm khóa phụ::

# echo 'hist:key=id.syscall,common_pid.execname:val=hitcount:sort=id,hitcount' > \
           /sys/kernel/tracing/events/raw_syscalls/sys_enter/trigger

# cat /sys/kernel/tracing/events/raw_syscalls/sys_enter/hist
    Thông tin về # trigger: hist:keys=id.syscall,common_pid.execname:vals=hitcount:sort=id.syscall,hitcount:size=2048 [hoạt động]

{ id: sys_read [ 0], common_pid: rtkit-daemon [ 1877] } số lần truy cập: 1
    { id: sys_read [ 0], common_pid: gdbus [ 2976] } số lần truy cập: 1
    { id: sys_read [ 0], common_pid: console-kit-dae [ 3400] } số lần truy cập: 1
    { id: sys_read [ 0], common_pid: postgres [ 1865] } số lần truy cập: 1
    { id: sys_read [ 0], common_pid: deja-dup-monito [ 3543] } số lần truy cập: 2
    { id: sys_read [ 0], common_pid: Trình quản lý mạng [ 890] } số lần truy cập: 2
    { id: sys_read [ 0], common_pid: Evolution-calen [ 3048] } số lần truy cập: 2
    { id: sys_read [ 0], common_pid: postgres [ 1864] } số lần truy cập: 2
    { id: sys_read [ 0], common_pid: nm-applet [ 3022] } số lần truy cập: 2
    { id: sys_read [ 0], common_pid: whoopsie [ 1212] } số lần truy cập: 2
    .
    .
    .
    { id: sys_ioctl [ 16], common_pid: bash [ 8479] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: bash [ 3472] } số lần truy cập: 12
    { id: sys_ioctl [ 16], common_pid: gnome-terminal [ 3199] } số lần truy cập: 16
    { id: sys_ioctl [ 16], common_pid: Xorg [ 1267] } số lần truy cập: 1808
    { id: sys_ioctl [ 16], common_pid: compiz [ 2994] } số lần truy cập: 5580
    .
    .
    .
    { id: sys_waitid [247], common_pid: upstart-dbus-br [ 2690] } số lần truy cập: 3
    { id: sys_waitid [247], common_pid: upstart-dbus-br [ 2688] } số lần truy cập: 16
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 975] } số lần truy cập: 2
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 3204] } số lần truy cập: 4
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 2888] } số lần truy cập: 4
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 3003] } số lần truy cập: 4
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 2873] } số lần truy cập: 4
    { id: sys_inotify_add_watch [254], common_pid: gmain [ 3196] } số lần truy cập: 6
    { id: sys_openat [257], common_pid: java [ 2623] } số lần truy cập: 2
    { id: sys_eventfd2 [290], common_pid: ibus-ui-gtk3 [ 2760] } số lần truy cập: 4
    { id: sys_eventfd2 [290], common_pid: compiz [ 2994] } số lần truy cập: 6

Tổng số:
        Lượt truy cập: 31536
        Bài dự thi: 323
        Đã đánh rơi: 0

Danh sách trên cung cấp cho chúng tôi thông tin chi tiết về tòa nhà ioctl theo
  pid, nhưng nó cũng mang lại cho chúng tôi nhiều hơn thế, điều mà chúng tôi
  không thực sự quan tâm vào lúc này.  Vì chúng ta biết syscall
  id cho sys_ioctl (16, hiển thị bên cạnh tên sys_ioctl), chúng ta
  có thể sử dụng điều đó để lọc ra tất cả các tòa nhà cao tầng khác ::

# echo 'hist:key=id.syscall,common_pid.execname:val=hitcount:sort=id,hitcount if id == 16' > \
           /sys/kernel/tracing/events/raw_syscalls/sys_enter/trigger

# cat /sys/kernel/tracing/events/raw_syscalls/sys_enter/hist
    Thông tin # trigger: hist:keys=id.syscall,common_pid.execname:vals=hitcount:sort=id.syscall,hitcount:size=2048 if id == 16 [hoạt động]

{ id: sys_ioctl [ 16], common_pid: gmain [ 2769] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: Evolution-addre [ 8571] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: gmain [ 3003] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: gmain [ 2781] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: gmain [ 2829] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: bash [ 8726] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: bash [ 8508] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: gmain [ 2970] } số lần truy cập: 1
    { id: sys_ioctl [ 16], common_pid: gmain [ 2768] } số lần truy cập: 1
    .
    .
    .
    { id: sys_ioctl [ 16], common_pid: pool [ 8559] } số lần truy cập: 45
    { id: sys_ioctl [ 16], common_pid: pool [ 8555] } số lần truy cập: 48
    { id: sys_ioctl [ 16], common_pid: pool [ 8551] } số lần truy cập: 48
    { id: sys_ioctl [ 16], common_pid: avahi-daemon [ 896] } số lần truy cập: 66
    { id: sys_ioctl [ 16], common_pid: Xorg [ 1267] } số lần truy cập: 26674
    { id: sys_ioctl [ 16], common_pid: compiz [ 2994] } số lần truy cập: 73443

Tổng số:
        Lượt truy cập: 101162
        Bài dự thi: 103
        Đã đánh rơi: 0

Kết quả đầu ra ở trên cho thấy 'compiz' và 'Xorg' rất xa
  những người gọi ioctl nặng nhất (có thể dẫn đến câu hỏi về
  liệu họ có thực sự cần thực hiện tất cả những cuộc gọi đó và
  những con đường có thể để điều tra thêm.)

Các ví dụ về khóa ghép đã sử dụng khóa và giá trị tổng (số lần truy cập) để
  sắp xếp kết quả đầu ra, nhưng thay vào đó chúng ta có thể dễ dàng sử dụng hai phím.
  Đây là một ví dụ trong đó chúng tôi sử dụng một khóa ghép bao gồm
  các trường sự kiện common_pid và kích thước.  Sắp xếp với pid là chính
  khóa và 'kích thước' làm khóa phụ cho phép chúng tôi hiển thị
  bản tóm tắt theo thứ tự về kích thước recvfrom, cùng với số lượng, được nhận bởi
  mỗi quá trình::

# echo 'hist:key=common_pid.execname,size:val=hitcount:sort=common_pid,size' > \
           /sys/kernel/tracing/events/syscalls/sys_enter_recvfrom/trigger

# cat /sys/kernel/tracing/events/syscalls/sys_enter_recvfrom/hist
    Thông tin # trigger: hist:keys=common_pid.execname,size:vals=hitcount:sort=common_pid.execname,size:size=2048 [hoạt động]

{ common_pid: smbd [ 784], kích thước: 4 } số lần truy cập: 1
    { common_pid: dnsmasq [ 1412], kích thước: 4096 } số lần truy cập: 672
    { common_pid: postgres [ 1796], kích thước: 1000 } số lần truy cập: 6
    { common_pid: postgres [ 1867], kích thước: 1000 } số lần truy cập: 10
    { common_pid: bamfdaemon [ 2787], kích thước: 28 } số lần truy cập: 2
    { common_pid: bamfdaemon [ 2787], kích thước: 14360 } số lần truy cập: 1
    { common_pid: compiz [ 2994], kích thước: 8 } số lần truy cập: 1
    { common_pid: compiz [ 2994], kích thước: 20 } số lần truy cập: 11
    { common_pid: gnome-terminal [ 3199], kích thước: 4 } số lần truy cập: 2
    { common_pid: firefox [ 8817], kích thước: 4 } số lần truy cập: 1
    { common_pid: firefox [ 8817], kích thước: 8 } số lần truy cập: 5
    { common_pid: firefox [ 8817], kích thước: 588 } số lần truy cập: 2
    { common_pid: firefox [ 8817], kích thước: 628 } số lần truy cập: 1
    { common_pid: firefox [ 8817], kích thước: 6944 } số lần truy cập: 1
    { common_pid: firefox [ 8817], kích thước: 408880 } số lần truy cập: 2
    { common_pid: firefox [ 8822], kích thước: 8 } số lần truy cập: 2
    { common_pid: firefox [ 8822], kích thước: 160 } số lần truy cập: 2
    { common_pid: firefox [ 8822], kích thước: 320 } số lần truy cập: 2
    { common_pid: firefox [ 8822], kích thước: 352 } số lần truy cập: 1
    .
    .
    .
    { common_pid: pool [ 8923], kích thước: 1960 } số lần truy cập: 10
    { common_pid: pool [ 8923], kích thước: 2048 } số lần truy cập: 10
    { common_pid: pool [ 8924], kích thước: 1960 } số lần truy cập: 10
    { common_pid: pool [ 8924], kích thước: 2048 } số lần truy cập: 10
    { common_pid: pool [ 8928], kích thước: 1964 } số lần truy cập: 4
    { common_pid: pool [ 8928], kích thước: 1965 } số lần truy cập: 2
    { common_pid: pool [ 8928], kích thước: 2048 } số lần truy cập: 6
    { common_pid: pool [ 8929], kích thước: 1982 } số lần truy cập: 1
    { common_pid: pool [ 8929], kích thước: 2048 } số lần truy cập: 1

Tổng số:
        Lượt truy cập: 2016
        Bài dự thi: 224
        Đã đánh rơi: 0

Ví dụ trên cũng minh họa một thực tế rằng mặc dù một hợp chất
  khóa được coi là một thực thể duy nhất cho mục đích băm, các khóa phụ
  nó bao gồm có thể được truy cập độc lập.

Ví dụ tiếp theo sử dụng trường chuỗi làm khóa băm và
  trình bày cách bạn có thể tạm dừng và tiếp tục kích hoạt lịch sử theo cách thủ công.
  Trong ví dụ này, chúng tôi sẽ tổng hợp số lượng ngã ba và không mong đợi
  số lượng lớn các mục trong bảng băm, vì vậy chúng tôi sẽ thả nó vào một
  số nhỏ hơn nhiều, chẳng hạn như 256::

# echo 'hist:key=child_comm:val=hitcount:size=256' > \
           /sys/kernel/tracing/events/sched/sched_process_fork/trigger

# cat /sys/kernel/tracing/events/sched/sched_process_fork/hist
    Thông tin về # trigger: hist:keys=child_comm:vals=hitcount:sort=hitcount:size=256 [hoạt động]

{ child_comm: dconf worker } số lần truy cập: 1
    { child_comm: ibus-daemon } số lần truy cập: 1
    { child_comm: whoopsie } số lần truy cập: 1
    { child_comm: smbd } số lần truy cập: 1
    { child_comm: gdbus } số lần truy cập: 1
    { child_comm: kthreadd } số lần truy cập: 1
    { child_comm: dconf worker } số lần truy cập: 1
    { child_comm: Evolution-alarm } số lần truy cập: 2
    { child_comm: Chủ đề ổ cắm } số lần truy cập: 2
    { child_comm: postgres } số lần truy cập: 2
    { child_comm: bash } số lần truy cập: 3
    { child_comm: compiz } số lần truy cập: 3
    { child_comm: nguồn tiến hóa } số lần truy cập: 4
    { child_comm: dhclient } số lần truy cập: 4
    { child_comm: pool } số lần truy cập: 5
    { child_comm: nm-dispatcher.a } số lần truy cập: 8
    { child_comm: firefox } số lượt truy cập: 8
    { child_comm: dbus-daemon } số lần truy cập: 8
    { child_comm: glib-pacrunner } số lần truy cập: 10
    { child_comm: tiến hóa } số lần truy cập: 23

Tổng số:
        Lượt truy cập: 89
        Bài dự thi: 20
        Đã đánh rơi: 0

Nếu chúng ta muốn tạm dừng trình kích hoạt lịch sử, chúng ta chỉ cần thêm :pause vào
  lệnh bắt đầu kích hoạt.  Lưu ý rằng thông tin kích hoạt
  hiển thị dưới dạng [tạm dừng]::

# echo 'hist:key=child_comm:val=hitcount:size=256:pause' >> \
           /sys/kernel/tracing/events/sched/sched_process_fork/trigger

# cat /sys/kernel/tracing/events/sched/sched_process_fork/hist
    Thông tin về # trigger: hist:keys=child_comm:vals=hitcount:sort=hitcount:size=256 [tạm dừng]

{ child_comm: dconf worker } số lần truy cập: 1
    { child_comm: kthreadd } số lần truy cập: 1
    { child_comm: dconf worker } số lần truy cập: 1
    { child_comm: gdbus } số lần truy cập: 1
    { child_comm: ibus-daemon } số lần truy cập: 1
    { child_comm: Chủ đề ổ cắm } số lần truy cập: 2
    { child_comm: Evolution-alarm } số lần truy cập: 2
    { child_comm: smbd } số lần truy cập: 2
    { child_comm: bash } số lần truy cập: 3
    { child_comm: whoopsie } số lần truy cập: 3
    { child_comm: compiz } số lần truy cập: 3
    { child_comm: nguồn tiến hóa } số lần truy cập: 4
    { child_comm: pool } số lần truy cập: 5
    { child_comm: postgres } số lần truy cập: 6
    { child_comm: firefox } số lượt truy cập: 8
    { child_comm: dhclient } số lần truy cập: 10
    { child_comm: emacs } số lần truy cập: 12
    { child_comm: dbus-daemon } số lần truy cập: 20
    { child_comm: nm-dispatcher.a } số lần truy cập: 20
    { child_comm: tiến hóa } số lần truy cập: 35
    { child_comm: glib-pacrunner } số lần truy cập: 59

Tổng số:
        Lượt truy cập: 199
        Bài dự thi: 21
        Đã đánh rơi: 0

Để tiếp tục có các sự kiện tổng hợp trình kích hoạt theo cách thủ công, hãy thêm
  :tiếp thay vào đó.  Lưu ý rằng thông tin kích hoạt hiển thị là [hoạt động]
  một lần nữa và dữ liệu đã thay đổi::

# echo 'hist:key=child_comm:val=hitcount:size=256:cont' >> \
           /sys/kernel/tracing/events/sched/sched_process_fork/trigger

# cat /sys/kernel/tracing/events/sched/sched_process_fork/hist
    Thông tin về # trigger: hist:keys=child_comm:vals=hitcount:sort=hitcount:size=256 [hoạt động]

{ child_comm: dconf worker } số lần truy cập: 1
    { child_comm: dconf worker } số lần truy cập: 1
    { child_comm: kthreadd } số lần truy cập: 1
    { child_comm: gdbus } số lần truy cập: 1
    { child_comm: ibus-daemon } số lần truy cập: 1
    { child_comm: Chủ đề ổ cắm } số lần truy cập: 2
    { child_comm: Evolution-alarm } số lần truy cập: 2
    { child_comm: smbd } số lần truy cập: 2
    { child_comm: whoopsie } số lần truy cập: 3
    { child_comm: compiz } số lần truy cập: 3
    { child_comm: nguồn tiến hóa } số lần truy cập: 4
    { child_comm: bash } số lần truy cập: 5
    { child_comm: pool } số lần truy cập: 5
    { child_comm: postgres } số lần truy cập: 6
    { child_comm: firefox } số lượt truy cập: 8
    { child_comm: dhclient } số lần truy cập: 11
    { child_comm: emacs } số lần truy cập: 12
    { child_comm: dbus-daemon } số lần truy cập: 22
    { child_comm: nm-dispatcher.a } số lần truy cập: 22
    { child_comm: tiến hóa } số lần truy cập: 35
    { child_comm: glib-pacrunner } số lần truy cập: 59

Tổng số:
        Lượt truy cập: 206
        Bài dự thi: 21
        Đã đánh rơi: 0

Ví dụ trước cho thấy cách bắt đầu và dừng trình kích hoạt lịch sử bằng cách
  thêm 'tạm dừng' và 'tiếp tục' vào lệnh kích hoạt lịch sử.  A
  trình kích hoạt lịch sử cũng có thể được bắt đầu ở trạng thái tạm dừng trước tiên
  bắt đầu kích hoạt với ':pause' được thêm vào.  Điều này cho phép bạn
  chỉ bắt đầu kích hoạt khi bạn đã sẵn sàng bắt đầu thu thập dữ liệu
  và không phải trước đó.  Ví dụ: bạn có thể bắt đầu trình kích hoạt trong
  trạng thái tạm dừng, sau đó bỏ tạm dừng và thực hiện điều gì đó bạn muốn đo lường,
  sau đó tạm dừng kích hoạt lại khi hoàn tất.

Tất nhiên, thực hiện việc này một cách thủ công có thể khó khăn và dễ xảy ra lỗi, nhưng
  có thể tự động bắt đầu và dừng trình kích hoạt lịch sử dựa trên
  với một số điều kiện, thông qua trình kích hoạt Enable_hist và vô hiệu hóa_hist.

Ví dụ: giả sử chúng ta muốn xem xét mối quan hệ họ hàng
  trọng số về độ dài skb cho mỗi đường dẫn cuộc gọi dẫn đến một
  netif_receive_skb khi tải xuống tệp có kích thước phù hợp bằng cách sử dụng
  quên đi.

Trước tiên, chúng tôi thiết lập trình kích hoạt stacktrace bị tạm dừng ban đầu trên
  sự kiện netif_receive_skb::

# echo 'hist:key=common_stacktrace:vals=len:pause' > \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger

Tiếp theo, chúng tôi thiết lập trình kích hoạt 'enable_hist' trên sched_process_exec
  sự kiện, với bộ lọc 'if filename==/usr/bin/wget'.  Tác dụng của
  trình kích hoạt mới này là nó sẽ 'bỏ tạm dừng' trình kích hoạt lịch sử mà chúng ta vừa
  được thiết lập trên netif_receive_skb khi và chỉ khi nó nhìn thấy
  sự kiện sched_process_exec có tên tệp là '/usr/bin/wget'.  Khi nào
  điều đó xảy ra, tất cả các sự kiện netif_receive_skb được tổng hợp thành một
  bảng băm được khóa trên stacktrace::

# echo 'enable_hist:net:netif_receive_skb if filename==/usr/bin/wget' > \
           /sys/kernel/tracing/events/sched/sched_process_exec/trigger

Việc tổng hợp tiếp tục cho đến khi netif_receive_skb bị tạm dừng
  một lần nữa, đó là điều mà sự kiện vô hiệu hóa sau đây thực hiện bằng cách
  tạo một thiết lập tương tự cho sự kiện sched_process_exit, bằng cách sử dụng
  lọc 'comm==wget'::

# echo 'disable_hist:net:netif_receive_skb if comm==wget' > \
           /sys/kernel/tracing/events/sched/sched_process_exit/trigger

Bất cứ khi nào một quá trình thoát ra và trường comm của vô hiệu hóa_hist
  bộ lọc kích hoạt khớp với 'comm==wget', lịch sử netif_receive_skb
  kích hoạt bị vô hiệu hóa.

Hiệu ứng tổng thể là các sự kiện netif_receive_skb được tổng hợp
  vào bảng băm chỉ trong thời gian wget.  Thực hiện một
  lệnh wget và sau đó liệt kê tệp 'lịch sử' sẽ hiển thị
  đầu ra được tạo bởi lệnh wget ::

$ wget ZZ0000ZZ

# cat /sys/kernel/tracing/events/net/netif_receive_skb/hist
    Thông tin về # trigger: hist:keys=common_stacktrace:vals=len:sort=hitcount:size=2048 [tạm dừng]

{ common_stacktrace:
         __netif_receive_skb_core+0x46d/0x990
         __netif_receive_skb+0x18/0x60
         netif_receive_skb_internal+0x23/0x90
         napi_gro_receive+0xc8/0x100
         ieee80211_deliver_skb+0xd6/0x270 [mac80211]
         ieee80211_rx_handlers+0xccf/0x22f0 [mac80211]
         ieee80211_prepare_and_rx_handle+0x4e7/0xc40 [mac80211]
         ieee80211_rx+0x31d/0x900 [mac80211]
         iwlagn_rx_reply_rx+0x3db/0x6f0 [iwldvm]
         iwl_rx_dispatch+0x8e/0xf0 [iwldvm]
         iwl_pcie_irq_handler+0xe3c/0x12f0 [iwlwifi]
         irq_thread_fn+0x20/0x50
         irq_thread+0x11f/0x150
         kthread+0xd2/0xf0
         ret_from_fork+0x42/0x70
    } số lần truy cập: 85 len: 28884
    { common_stacktrace:
         __netif_receive_skb_core+0x46d/0x990
         __netif_receive_skb+0x18/0x60
         netif_receive_skb_internal+0x23/0x90
         napi_gro_complete+0xa4/0xe0
         dev_gro_receive+0x23a/0x360
         napi_gro_receive+0x30/0x100
         ieee80211_deliver_skb+0xd6/0x270 [mac80211]
         ieee80211_rx_handlers+0xccf/0x22f0 [mac80211]
         ieee80211_prepare_and_rx_handle+0x4e7/0xc40 [mac80211]
         ieee80211_rx+0x31d/0x900 [mac80211]
         iwlagn_rx_reply_rx+0x3db/0x6f0 [iwldvm]
         iwl_rx_dispatch+0x8e/0xf0 [iwldvm]
         iwl_pcie_irq_handler+0xe3c/0x12f0 [iwlwifi]
         irq_thread_fn+0x20/0x50
         irq_thread+0x11f/0x150
         kthread+0xd2/0xf0
    } số lần truy cập: 98 len: 664329
    { common_stacktrace:
         __netif_receive_skb_core+0x46d/0x990
         __netif_receive_skb+0x18/0x60
         process_backlog+0xa8/0x150
         net_rx_action+0x15d/0x340
         __do_softirq+0x114/0x2c0
         do_softirq_own_stack+0x1c/0x30
         do_softirq+0x65/0x70
         __local_bh_enable_ip+0xb5/0xc0
         ip_finish_output+0x1f4/0x840
         ip_output+0x6b/0xc0
         ip_local_out_sk+0x31/0x40
         ip_send_skb+0x1a/0x50
         udp_send_skb+0x173/0x2a0
         udp_sendmsg+0x2bf/0x9f0
         inet_sendmsg+0x64/0xa0
         sock_sendmsg+0x3d/0x50
    } số lần truy cập: 115 len: 13030
    { common_stacktrace:
         __netif_receive_skb_core+0x46d/0x990
         __netif_receive_skb+0x18/0x60
         netif_receive_skb_internal+0x23/0x90
         napi_gro_complete+0xa4/0xe0
         napi_gro_flush+0x6d/0x90
         iwl_pcie_irq_handler+0x92a/0x12f0 [iwlwifi]
         irq_thread_fn+0x20/0x50
         irq_thread+0x11f/0x150
         kthread+0xd2/0xf0
         ret_from_fork+0x42/0x70
    } số lần truy cập: 934 len: 5512212

Tổng số:
        Lượt truy cập: 1232
        Bài dự thi: 4
        Đã đánh rơi: 0

Ở trên hiển thị tất cả các đường dẫn cuộc gọi netif_receive_skb và tổng số của chúng
  độ dài trong suốt thời gian của lệnh wget.

Thông số kích hoạt lịch sử 'xóa' có thể được sử dụng để xóa bảng băm.
  Giả sử chúng ta muốn thử chạy lại ví dụ trước nhưng
  lần này cũng muốn xem danh sách đầy đủ các sự kiện đã diễn ra
  vào biểu đồ.  Để tránh phải thiết lập mọi thứ
  một lần nữa, chúng ta có thể xóa biểu đồ trước::

# echo 'hist:key=common_stacktrace:vals=len:clear' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger

Chỉ để xác minh rằng trên thực tế nó đã được xóa, đây là những gì chúng ta thấy bây giờ trong
  tập tin lịch sử::

# cat /sys/kernel/tracing/events/net/netif_receive_skb/hist
    Thông tin về # trigger: hist:keys=common_stacktrace:vals=len:sort=hitcount:size=2048 [tạm dừng]

Tổng số:
        Lượt truy cập: 0
        Bài viết: 0
        Đã đánh rơi: 0

Vì chúng tôi muốn xem danh sách chi tiết của mọi netif_receive_skb
  sự kiện xảy ra trong lần chạy mới, trên thực tế là giống nhau
  các sự kiện được tổng hợp vào bảng băm, chúng tôi thêm một số sự kiện bổ sung
  các sự kiện 'enable_event' để kích hoạt sched_process_exec và
  sched_process_exit các sự kiện như vậy::

# echo 'enable_event:net:netif_receive_skb if filename==/usr/bin/wget' > \
           /sys/kernel/tracing/events/sched/sched_process_exec/trigger

# echo 'disable_event:net:netif_receive_skb if comm==wget' > \
           /sys/kernel/tracing/events/sched/sched_process_exit/trigger

Nếu bạn đọc các tệp kích hoạt cho sched_process_exec và
  trình kích hoạt sched_process_exit, bạn sẽ thấy hai trình kích hoạt cho mỗi trình kích hoạt:
  một cái cho phép/vô hiệu hóa tập hợp lịch sử và cái kia
  bật/tắt tính năng ghi nhật ký sự kiện::

# cat /sys/kernel/tracing/events/sched/sched_process_exec/trigger
    Enable_event:net:netif_receive_skb:unlimited if filename==/usr/bin/wget
    Enable_hist:net:netif_receive_skb:unlimited if filename==/usr/bin/wget

# cat /sys/kernel/tracing/events/sched/sched_process_exit/trigger
    Enable_event:net:netif_receive_skb:unlimited if comm==wget
    vô hiệu hóa_hist:net:netif_receive_skb:không giới hạn nếu comm==wget

Nói cách khác, bất cứ khi nào một trong hai sched_process_exec hoặc
  sự kiện sched_process_exit được nhấn và khớp với 'wget', nó cho phép hoặc
  vô hiệu hóa cả biểu đồ và nhật ký sự kiện cũng như kết quả cuối cùng của bạn
  with là một bảng băm và tập hợp các sự kiện chỉ bao gồm các mục được chỉ định
  thời lượng.  Chạy lại lệnh wget ::

$ wget ZZ0000ZZ

Hiển thị tệp 'lịch sử' sẽ hiển thị nội dung tương tự như những gì bạn
  đã thấy trong lần chạy trước, nhưng lần này bạn cũng sẽ thấy
  các sự kiện riêng lẻ trong tệp theo dõi::

# cat /sys/kernel/truy tìm/dấu vết

# tracer: không
    #
    # entries-in-buffer/mục viết: 183/1426 #P:4
    #
    #                              _-----=> tắt irqs
    # / _---=> cần được chỉnh sửa lại
    # | / _---=> hardirq/softirq
    # || / _--=> ưu tiên độ sâu
    # ||| / trì hoãn
    #           ZZ0003ZZ-ZZ0004ZZ CPU# ||||    TIMESTAMP FUNCTION
    #              ZZ0008ZZ ZZ0001ZZ||ZZ0002ZZ |
                wget-15108 [000] ..s1 31769.606929: netif_receive_skb: dev=lo skbaddr=ffff88009c353100 len=60
                wget-15108 [000] ..s1 31769.606999: netif_receive_skb: dev=lo skbaddr=ffff88009c353200 len=60
             dnsmasq-1382 [000] ..s1 31769.677652: netif_receive_skb: dev=lo skbaddr=ffff88009c352b00 len=130
             dnsmasq-1382 [000] ..s1 31769.685917: netif_receive_skb: dev=lo skbaddr=ffff88009c352200 len=138
    ####Bộ đệm # ZZ0011ZZ 2 đã khởi động ####
      irq/29-iwlwifi-559 [002] ..s. 31772.031529: netif_receive_skb: dev=wlan0 skbaddr=ffff88009d433d00 len=2948
      irq/29-iwlwifi-559 [002] ..s. 31772.031572: netif_receive_skb: dev=wlan0 skbaddr=ffff88009d432200 len=1500
      irq/29-iwlwifi-559 [002] ..s. 31772.032196: netif_receive_skb: dev=wlan0 skbaddr=ffff88009d433100 len=2948
      irq/29-iwlwifi-559 [002] ..s. 31772.032761: netif_receive_skb: dev=wlan0 skbaddr=ffff88009d433000 len=2948
      irq/29-iwlwifi-559 [002] ..s. 31772.033220: netif_receive_skb: dev=wlan0 skbaddr=ffff88009d432e00 len=1500
    .
    .
    .

Ví dụ sau đây minh họa cách có thể kích hoạt nhiều trình kích hoạt lịch sử
  gắn liền với một sự kiện nhất định.  Khả năng này có thể hữu ích cho
  tạo ra một tập hợp các tóm tắt khác nhau bắt nguồn từ cùng một tập hợp
  sự kiện hoặc để so sánh tác động của các bộ lọc khác nhau, giữa
  những thứ khác::

# echo 'hist:keys=skbaddr.hex:vals=len if len < 0' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger
    # echo 'hist:keys=skbaddr.hex:vals=len if len > 4096' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger
    # echo 'hist:keys=skbaddr.hex:vals=len if len == 256' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger
    # echo 'hist:keys=skbaddr.hex:vals=len' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger
    # echo 'hist:keys=len:vals=common_preempt_count' >> \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger

Tập lệnh trên tạo ra bốn trigger chỉ khác nhau ở
  bộ lọc của họ, cùng với một bộ lọc hoàn toàn khác mặc dù khá
  kích hoạt vô nghĩa.  Lưu ý rằng để nối thêm nhiều lịch sử
  kích hoạt vào cùng một tệp, bạn nên sử dụng toán tử '>>' để
  nối chúng ('>' cũng sẽ thêm trình kích hoạt lịch sử mới, nhưng sẽ xóa
  bất kỳ trình kích hoạt lịch sử hiện có nào trước đó).

Hiển thị nội dung của tệp 'lịch sử' cho sự kiện cho thấy
  nội dung của cả năm biểu đồ::

# cat /sys/kernel/tracing/events/net/netif_receive_skb/hist

Biểu đồ # event
    #
    Thông tin về # trigger: hist:keys=len:vals=hitcount,common_preempt_count:sort=hitcount:size=2048 [hoạt động]
    #

{ len: 176 } số lần truy cập: 1 common_preempt_count: 0
    { len: 223 } số lần truy cập: 1 common_preempt_count: 0
    { len: 4854 } số lần truy cập: 1 common_preempt_count: 0
    { len: 395 } số lần truy cập: 1 common_preempt_count: 0
    { len: 177 } số lần truy cập: 1 common_preempt_count: 0
    { len: 446 } số lần truy cập: 1 common_preempt_count: 0
    { len: 1601 } số lần truy cập: 1 common_preempt_count: 0
    .
    .
    .
    { len: 1280 } số lần truy cập: 66 common_preempt_count: 0
    { len: 116 } số lần truy cập: 81 common_preempt_count: 40
    { len: 708 } số lần truy cập: 112 common_preempt_count: 0
    { len: 46 } số lần truy cập: 221 common_preempt_count: 0
    { len: 1264 } số lần truy cập: 458 common_preempt_count: 0

Tổng số:
        Lượt truy cập: 1428
        Bài dự thi: 147
        Đã đánh rơi: 0


Biểu đồ # event
    #
    Thông tin về # trigger: hist:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 [hoạt động]
    #

{ skbaddr: ffff8800baee5e00 } số lần truy cập: 1 len: 130
    { skbaddr: ffff88005f3d5600 } số lần truy cập: 1 len: 1280
    { skbaddr: ffff88005f3d4900 } số lần truy cập: 1 len: 1280
    { skbaddr: ffff88009fed6300 } số lần truy cập: 1 len: 115
    { skbaddr: ffff88009fe0ad00 } số lần truy cập: 1 len: 115
    { skbaddr: ffff88008cdb1900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff880064b5ef00 } số lần truy cập: 1 len: 118
    { skbaddr: ffff880044e3c700 } số lần truy cập: 1 len: 60
    { skbaddr: ffff880100065900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d46bd500 } số lần truy cập: 1 len: 116
    { skbaddr: ffff88005f3d5f00 } số lần truy cập: 1 len: 1280
    { skbaddr: ffff880100064700 } số lần truy cập: 1 len: 365
    { skbaddr: ffff8800badb6f00 } số lần truy cập: 1 len: 60
    .
    .
    .
    { skbaddr: ffff88009fe0be00 } số lần truy cập: 27 len: 24677
    { skbaddr: ffff88009fe0a400 } số lần truy cập: 27 len: 23052
    { skbaddr: ffff88009fe0b700 } số lần truy cập: 31 len: 25589
    { skbaddr: ffff88009fe0b600 } số lần truy cập: 32 len: 27326
    { skbaddr: ffff88006a462800 } số lần truy cập: 68 len: 71678
    { skbaddr: ffff88006a463700 } số lần truy cập: 70 len: 72678
    { skbaddr: ffff88006a462b00 } số lần truy cập: 71 len: 77589
    { skbaddr: ffff88006a463600 } số lần truy cập: 73 len: 71307
    { skbaddr: ffff88006a462200 } số lần truy cập: 81 len: 81032

Tổng số:
        Lượt truy cập: 1451
        Bài dự thi: 318
        Đã đánh rơi: 0


Biểu đồ # event
    #
    Thông tin về # trigger: hist:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 if len == 256 [hoạt động]
    #


Tổng số:
        Lượt truy cập: 0
        Bài viết: 0
        Đã đánh rơi: 0


Biểu đồ # event
    #
    Thông tin về # trigger: hist:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 nếu len > 4096 [hoạt động]
    #

{ skbaddr: ffff88009fd2c300 } số lần truy cập: 1 len: 7212
    { skbaddr: ffff8800d2bcce00 } số lần truy cập: 1 len: 7212
    { skbaddr: ffff8800d2bcd700 } số lần truy cập: 1 len: 7212
    { skbaddr: ffff8800d2bcda00 } số lần truy cập: 1 len: 21492
    { skbaddr: ffff8800ae2e2d00 } số lần truy cập: 1 len: 7212
    { skbaddr: ffff8800d2bcdb00 } số lần truy cập: 1 len: 7212
    { skbaddr: ffff88006a4df500 } số lần truy cập: 1 len: 4854
    { skbaddr: ffff88008ce47b00 } số lần truy cập: 1 len: 18636
    { skbaddr: ffff8800ae2e2200 } số lần truy cập: 1 len: 12924
    { skbaddr: ffff88005f3e1000 } số lần truy cập: 1 len: 4356
    { skbaddr: ffff8800d2bcdc00 } số lần truy cập: 2 len: 24420
    { skbaddr: ffff8800d2bcc200 } số lần truy cập: 2 len: 12996

Tổng số:
        Lượt truy cập: 14
        Bài dự thi: 12
        Đã đánh rơi: 0


Biểu đồ # event
    #
    Thông tin về # trigger: hist:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 nếu len < 0 [hoạt động]
    #


Tổng số:
        Lượt truy cập: 0
        Bài viết: 0
        Đã đánh rơi: 0

Trình kích hoạt được đặt tên có thể được sử dụng để các trình kích hoạt chia sẻ một tập hợp chung các
  dữ liệu biểu đồ.  Khả năng này chủ yếu hữu ích cho việc kết hợp
  đầu ra của các sự kiện được tạo bởi các điểm theo dõi có bên trong nội tuyến
  các chức năng, nhưng tên có thể được sử dụng trong trình kích hoạt lịch sử trên bất kỳ sự kiện nào.
  Ví dụ 2 trigger này khi đánh sẽ cập nhật cùng một 'len'
  trường trong dữ liệu biểu đồ 'foo' được chia sẻ::

# echo 'hist:name=foo:keys=skbaddr.hex:vals=len' > \
           /sys/kernel/tracing/events/net/netif_receive_skb/trigger
    # echo 'hist:name=foo:keys=skbaddr.hex:vals=len' > \
           /sys/kernel/tracing/events/net/netif_rx/trigger

Bạn có thể thấy rằng họ đang cập nhật dữ liệu biểu đồ chung bằng cách đọc
  các tệp lịch sử của từng sự kiện cùng một lúc::

# cat /sys/kernel/tracing/events/net/netif_receive_skb/hist;
      cat /sys/kernel/tracing/events/net/netif_rx/hist

Biểu đồ # event
    #
    Thông tin về # trigger: hist:name=foo:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 [hoạt động]
    #

{ skbaddr: ffff88000ad53500 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800af5a1500 } số lần truy cập: 1 len: 76
    { skbaddr: ffff8800d62a1900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bccb00 } số lần truy cập: 1 len: 468
    { skbaddr: ffff8800d3c69900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff88009ff09100 } số lần truy cập: 1 len: 52
    { skbaddr: ffff88010f13ab00 } số lần truy cập: 1 len: 168
    { skbaddr: ffff88006a54f400 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcc500 } số lần truy cập: 1 len: 260
    { skbaddr: ffff880064505000 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800baf24e00 } số lần truy cập: 1 len: 32
    { skbaddr: ffff88009fe0ad00 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d3edff00 } số lần truy cập: 1 len: 44
    { skbaddr: ffff88009fe0b400 } số lần truy cập: 1 len: 168
    { skbaddr: ffff8800a1c55a00 } số lần truy cập: 1 len: 40
    { skbaddr: ffff8800d2bcd100 } số lần truy cập: 1 len: 40
    { skbaddr: ffff880064505f00 } số lần truy cập: 1 len: 174
    { skbaddr: ffff8800a8bff200 } số lần truy cập: 1 len: 160
    { skbaddr: ffff880044e3cc00 } số lần truy cập: 1 len: 76
    { skbaddr: ffff8800a8bfe700 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcdc00 } số lần truy cập: 1 len: 32
    { skbaddr: ffff8800a1f64800 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcde00 } số lần truy cập: 1 len: 988
    { skbaddr: ffff88006a5dea00 } số lần truy cập: 1 len: 46
    { skbaddr: ffff88002e37a200 } số lần truy cập: 1 len: 44
    { skbaddr: ffff8800a1f32c00 } số lần truy cập: 2 len: 676
    { skbaddr: ffff88000ad52600 } số lần truy cập: 2 len: 107
    { skbaddr: ffff8800a1f91e00 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800af5a0200 } số lần truy cập: 2 len: 142
    { skbaddr: ffff8800d2bcc600 } số lần truy cập: 2 len: 220
    { skbaddr: ffff8800ba36f500 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800d021f800 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800a1f33600 } số lần truy cập: 2 len: 675
    { skbaddr: ffff8800a8bfff00 } số lần truy cập: 3 len: 138
    { skbaddr: ffff8800d62a1300 } số lần truy cập: 3 len: 138
    { skbaddr: ffff88002e37a100 } số lần truy cập: 4 len: 184
    { skbaddr: ffff880064504400 } số lần truy cập: 4 len: 184
    { skbaddr: ffff8800a8bfec00 } số lần truy cập: 4 len: 184
    { skbaddr: ffff88000ad53700 } số lần truy cập: 5 len: 230
    { skbaddr: ffff8800d2bcdb00 } số lần truy cập: 5 len: 196
    { skbaddr: ffff8800a1f90000 } số lần truy cập: 6 len: 276
    { skbaddr: ffff88006a54f900 } số lần truy cập: 6 len: 276

Tổng số:
        Lượt truy cập: 81
        Bài dự thi: 42
        Đã đánh rơi: 0
    Biểu đồ # event
    #
    Thông tin về # trigger: hist:name=foo:keys=skbaddr.hex:vals=hitcount,len:sort=hitcount:size=2048 [hoạt động]
    #

{ skbaddr: ffff88000ad53500 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800af5a1500 } số lần truy cập: 1 len: 76
    { skbaddr: ffff8800d62a1900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bccb00 } số lần truy cập: 1 len: 468
    { skbaddr: ffff8800d3c69900 } số lần truy cập: 1 len: 46
    { skbaddr: ffff88009ff09100 } số lần truy cập: 1 len: 52
    { skbaddr: ffff88010f13ab00 } số lần truy cập: 1 len: 168
    { skbaddr: ffff88006a54f400 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcc500 } số lần truy cập: 1 len: 260
    { skbaddr: ffff880064505000 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800baf24e00 } số lần truy cập: 1 len: 32
    { skbaddr: ffff88009fe0ad00 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d3edff00 } số lần truy cập: 1 len: 44
    { skbaddr: ffff88009fe0b400 } số lần truy cập: 1 len: 168
    { skbaddr: ffff8800a1c55a00 } số lần truy cập: 1 len: 40
    { skbaddr: ffff8800d2bcd100 } số lần truy cập: 1 len: 40
    { skbaddr: ffff880064505f00 } số lần truy cập: 1 len: 174
    { skbaddr: ffff8800a8bff200 } số lần truy cập: 1 len: 160
    { skbaddr: ffff880044e3cc00 } số lần truy cập: 1 len: 76
    { skbaddr: ffff8800a8bfe700 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcdc00 } số lần truy cập: 1 len: 32
    { skbaddr: ffff8800a1f64800 } số lần truy cập: 1 len: 46
    { skbaddr: ffff8800d2bcde00 } số lần truy cập: 1 len: 988
    { skbaddr: ffff88006a5dea00 } số lần truy cập: 1 len: 46
    { skbaddr: ffff88002e37a200 } số lần truy cập: 1 len: 44
    { skbaddr: ffff8800a1f32c00 } số lần truy cập: 2 len: 676
    { skbaddr: ffff88000ad52600 } số lần truy cập: 2 len: 107
    { skbaddr: ffff8800a1f91e00 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800af5a0200 } số lần truy cập: 2 len: 142
    { skbaddr: ffff8800d2bcc600 } số lần truy cập: 2 len: 220
    { skbaddr: ffff8800ba36f500 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800d021f800 } số lần truy cập: 2 len: 92
    { skbaddr: ffff8800a1f33600 } số lần truy cập: 2 len: 675
    { skbaddr: ffff8800a8bfff00 } số lần truy cập: 3 len: 138
    { skbaddr: ffff8800d62a1300 } số lần truy cập: 3 len: 138
    { skbaddr: ffff88002e37a100 } số lần truy cập: 4 len: 184
    { skbaddr: ffff880064504400 } số lần truy cập: 4 len: 184
    { skbaddr: ffff8800a8bfec00 } số lần truy cập: 4 len: 184
    { skbaddr: ffff88000ad53700 } số lần truy cập: 5 len: 230
    { skbaddr: ffff8800d2bcdb00 } số lần truy cập: 5 len: 196
    { skbaddr: ffff8800a1f90000 } số lần truy cập: 6 len: 276
    { skbaddr: ffff88006a54f900 } số lần truy cập: 6 len: 276

Tổng số:
        Lượt truy cập: 81
        Bài dự thi: 42
        Đã đánh rơi: 0

Và đây là ví dụ cho thấy cách kết hợp dữ liệu biểu đồ từ
  bất kỳ hai sự kiện nào ngay cả khi chúng không chia sẻ bất kỳ trường 'tương thích' nào
  ngoài 'hitcount' và 'common_stacktrace'.  Các lệnh này tạo ra một
  một vài trình kích hoạt có tên 'bar' bằng cách sử dụng các trường đó ::

# echo 'hist:name=bar:key=common_stacktrace:val=hitcount' > \
           /sys/kernel/tracing/events/sched/sched_process_fork/trigger
    # echo 'hist:name=bar:key=common_stacktrace:val=hitcount' > \
          /sys/kernel/tracing/events/net/netif_rx/trigger

Và hiển thị đầu ra của một trong hai cho thấy một số điều thú vị nếu
  đầu ra hơi khó hiểu ::

# cat /sys/kernel/tracing/events/sched/sched_process_fork/hist
    # cat /sys/kernel/tracing/events/net/netif_rx/hist

Biểu đồ # event
    #
    Thông tin về # trigger: hist:name=bar:keys=common_stacktrace:vals=hitcount:sort=hitcount:size=2048 [hoạt động]
    #

{ common_stacktrace:
             kernel_clone+0x18e/0x330
             kernel_thread+0x29/0x30
             kthreadd+0x154/0x1b0
             ret_from_fork+0x3f/0x70
    } số lần truy cập: 1
    { common_stacktrace:
             netif_rx_internal+0xb2/0xd0
             netif_rx_ni+0x20/0x70
             dev_loopback_xmit+0xaa/0xd0
             ip_mc_output+0x126/0x240
             ip_local_out_sk+0x31/0x40
             igmp_send_report+0x1e9/0x230
             igmp_timer_expire+0xe9/0x120
             call_timer_fn+0x39/0xf0
             run_timer_softirq+0x1e1/0x290
             __do_softirq+0xfd/0x290
             irq_exit+0x98/0xb0
             smp_apic_timer_interrupt+0x4a/0x60
             apic_timer_interrupt+0x6d/0x80
             cpuidle_enter+0x17/0x20
             call_cpuidle+0x3b/0x60
             cpu_startup_entry+0x22d/0x310
    } số lần truy cập: 1
    { common_stacktrace:
             netif_rx_internal+0xb2/0xd0
             netif_rx_ni+0x20/0x70
             dev_loopback_xmit+0xaa/0xd0
             ip_mc_output+0x17f/0x240
             ip_local_out_sk+0x31/0x40
             ip_send_skb+0x1a/0x50
             udp_send_skb+0x13e/0x270
             udp_sendmsg+0x2bf/0x980
             inet_sendmsg+0x67/0xa0
             sock_sendmsg+0x38/0x50
             SYSC_sendto+0xef/0x170
             SyS_sendto+0xe/0x10
             entry_SYSCALL_64_fastpath+0x12/0x6a
    } số lần truy cập: 2
    { common_stacktrace:
             netif_rx_internal+0xb2/0xd0
             netif_rx+0x1c/0x60
             loopback_xmit+0x6c/0xb0
             dev_hard_start_xmit+0x219/0x3a0
             __dev_queue_xmit+0x415/0x4f0
             dev_queue_xmit_sk+0x13/0x20
             ip_finish_output2+0x237/0x340
             ip_finish_output+0x113/0x1d0
             ip_output+0x66/0xc0
             ip_local_out_sk+0x31/0x40
             ip_send_skb+0x1a/0x50
             udp_send_skb+0x16d/0x270
             udp_sendmsg+0x2bf/0x980
             inet_sendmsg+0x67/0xa0
             sock_sendmsg+0x38/0x50
             ___sys_sendmsg+0x14e/0x270
    } số lần truy cập: 76
    { common_stacktrace:
             netif_rx_internal+0xb2/0xd0
             netif_rx+0x1c/0x60
             loopback_xmit+0x6c/0xb0
             dev_hard_start_xmit+0x219/0x3a0
             __dev_queue_xmit+0x415/0x4f0
             dev_queue_xmit_sk+0x13/0x20
             ip_finish_output2+0x237/0x340
             ip_finish_output+0x113/0x1d0
             ip_output+0x66/0xc0
             ip_local_out_sk+0x31/0x40
             ip_send_skb+0x1a/0x50
             udp_send_skb+0x16d/0x270
             udp_sendmsg+0x2bf/0x980
             inet_sendmsg+0x67/0xa0
             sock_sendmsg+0x38/0x50
             ___sys_sendmsg+0x269/0x270
    } số lần truy cập: 77
    { common_stacktrace:
             netif_rx_internal+0xb2/0xd0
             netif_rx+0x1c/0x60
             loopback_xmit+0x6c/0xb0
             dev_hard_start_xmit+0x219/0x3a0
             __dev_queue_xmit+0x415/0x4f0
             dev_queue_xmit_sk+0x13/0x20
             ip_finish_output2+0x237/0x340
             ip_finish_output+0x113/0x1d0
             ip_output+0x66/0xc0
             ip_local_out_sk+0x31/0x40
             ip_send_skb+0x1a/0x50
             udp_send_skb+0x16d/0x270
             udp_sendmsg+0x2bf/0x980
             inet_sendmsg+0x67/0xa0
             sock_sendmsg+0x38/0x50
             SYSC_sendto+0xef/0x170
    } số lần truy cập: 88
    { common_stacktrace:
             kernel_clone+0x18e/0x330
             SyS_clone+0x19/0x20
             entry_SYSCALL_64_fastpath+0x12/0x6a
    } số lần truy cập: 244

Tổng số:
        Lượt truy cập: 489
        Bài dự thi: 7
        Đã đánh rơi: 0

2.4. Trình kích hoạt lịch sử giữa các sự kiện
------------------------------

Trình kích hoạt lịch sử giữa các sự kiện là trình kích hoạt lịch sử kết hợp các giá trị từ
một hoặc nhiều sự kiện khác và tạo biểu đồ bằng dữ liệu đó.  dữ liệu
từ biểu đồ giữa các sự kiện có thể lần lượt trở thành nguồn cho
biểu đồ kết hợp hơn nữa, do đó cung cấp một chuỗi các biểu đồ liên quan
biểu đồ, điều này rất quan trọng đối với một số ứng dụng.

Ví dụ quan trọng nhất về đại lượng giữa các sự kiện có thể được sử dụng
theo cách này là độ trễ, đơn giản là sự khác biệt về dấu thời gian
giữa hai sự kiện.  Mặc dù độ trễ là quan trọng nhất
số lượng giữa các sự kiện, lưu ý rằng vì sự hỗ trợ hoàn toàn
chung trên hệ thống con sự kiện theo dõi, bất kỳ trường sự kiện nào cũng có thể được sử dụng
với số lượng giữa các sự kiện.

Một ví dụ về biểu đồ kết hợp dữ liệu từ các biểu đồ khác
thành một chuỗi hữu ích sẽ là biểu đồ 'độ trễ chuyển đổi đánh thức'
kết hợp biểu đồ 'độ trễ đánh thức' và 'độ trễ chuyển đổi'
biểu đồ.

Thông thường, đặc tả kích hoạt lịch sử bao gồm một (có thể
khóa ghép) cùng với một hoặc nhiều giá trị số, đó là
số tiền được cập nhật liên tục liên quan đến khóa đó.  Biểu đồ
đặc điểm kỹ thuật trong trường hợp này bao gồm khóa và giá trị riêng lẻ
thông số kỹ thuật đề cập đến các trường sự kiện theo dõi liên quan đến một
loại sự kiện duy nhất.

Tiện ích mở rộng kích hoạt lịch sử giữa các sự kiện cho phép các trường từ nhiều
các sự kiện được tham chiếu và kết hợp thành biểu đồ nhiều sự kiện
đặc điểm kỹ thuật.  Để hỗ trợ cho mục tiêu tổng thể này, một số hoạt động cho phép
các tính năng đã được thêm vào hỗ trợ kích hoạt lịch sử:

- Để tính toán số lượng giữa các sự kiện, giá trị từ một
    sự kiện cần được lưu và sau đó được tham chiếu từ một sự kiện khác.  Cái này
    yêu cầu giới thiệu sự hỗ trợ cho 'các biến' biểu đồ.

- Việc tính toán số lượng giữa các sự kiện và sự kết hợp của chúng
    yêu cầu một số lượng hỗ trợ tối thiểu để áp dụng đơn giản
    biểu thức cho các biến (+ và -).

- Một biểu đồ bao gồm các đại lượng giữa các sự kiện về mặt logic không phải là một
    biểu đồ về một trong hai sự kiện (do đó có tệp 'lịch sử' cho một trong hai sự kiện
    máy chủ sự kiện, đầu ra biểu đồ không thực sự có ý nghĩa).  Đến
    giải quyết ý tưởng rằng biểu đồ được liên kết với một
    sự kết hợp của các sự kiện, hỗ trợ được thêm vào cho phép tạo ra
    các sự kiện 'tổng hợp' là các sự kiện bắt nguồn từ các sự kiện khác.
    Những sự kiện tổng hợp này là những sự kiện chính thức giống như bất kỳ sự kiện nào khác.
    và có thể được sử dụng như vậy, chẳng hạn như để tạo
    biểu đồ 'kết hợp' đã đề cập trước đó.

- Một tập hợp các 'hành động' có thể được liên kết với các mục biểu đồ -
    chúng có thể được sử dụng để tạo ra chất tổng hợp đã đề cập trước đó
    sự kiện, nhưng cũng có thể được sử dụng cho các mục đích khác, chẳng hạn như cho
    ví dụ lưu bối cảnh khi đạt đến độ trễ 'tối đa'.

- Các sự kiện theo dõi không có 'dấu thời gian' gắn liền với chúng, nhưng
    có một dấu thời gian tiềm ẩn được lưu cùng với một sự kiện trong
    bộ đệm vòng ftrace cơ bản.  Dấu thời gian này hiện được hiển thị dưới dạng
    một trường tổng hợp có tên 'common_timestamp' có thể được sử dụng trong
    biểu đồ như thể nó là bất kỳ trường sự kiện nào khác; nó không phải là thực tế
    trường ở định dạng theo dõi mà đúng hơn là một giá trị tổng hợp
    tuy nhiên có thể được sử dụng như thể nó là một lĩnh vực thực tế.  Theo mặc định
    nó được tính bằng đơn vị nano giây; thêm '.usecs' vào một
    Trường common_timestamp thay đổi đơn vị thành micro giây.

Lưu ý về dấu thời gian giữa các sự kiện: Nếu common_timestamp được sử dụng trong
biểu đồ, bộ đệm theo dõi sẽ tự động được chuyển sang sử dụng
dấu thời gian tuyệt đối và đồng hồ theo dõi "toàn cầu", để tránh
sự khác biệt về dấu thời gian không có thật với các đồng hồ khác không mạch lạc
trên các CPU.  Điều này có thể được ghi đè bằng cách chỉ định một trong những cái khác
thay vào đó, hãy theo dõi đồng hồ bằng cách sử dụng thuộc tính kích hoạt lịch sử "clock=XXX",
trong đó XXX là bất kỳ đồng hồ nào được liệt kê trong tracing/trace_clock
tập tin giả.

Những tính năng này được mô tả chi tiết hơn trong các phần sau.

2.5. Biến biểu đồ
------------------------

Các biến được đặt tên đơn giản là các vị trí được sử dụng để lưu và truy xuất
giá trị giữa các sự kiện phù hợp.  Một sự kiện 'khớp' được định nghĩa là một
sự kiện có khóa khớp - nếu một biến được lưu cho biểu đồ
mục tương ứng với khóa đó, bất kỳ sự kiện tiếp theo nào có kết quả phù hợp
key có thể truy cập vào biến đó.

Giá trị của một biến thường có sẵn cho bất kỳ sự kiện tiếp theo nào cho đến khi
nó được đặt thành một cái gì đó khác bởi một sự kiện tiếp theo.  Một ngoại lệ
theo quy tắc đó là bất kỳ biến nào được sử dụng trong một biểu thức về cơ bản là
'đọc một lần' - khi nó được một biểu thức sử dụng trong sự kiện tiếp theo,
nó được đặt lại về trạng thái 'không được đặt', có nghĩa là nó không thể được sử dụng lại
trừ khi nó được thiết lập lại.  Điều này đảm bảo không chỉ rằng một sự kiện không
sử dụng một biến chưa được khởi tạo trong phép tính, nhưng biến đó
chỉ được sử dụng một lần và không được sử dụng cho bất kỳ trận đấu nào không liên quan tiếp theo.

Cú pháp cơ bản để lưu một biến chỉ đơn giản là thêm tiền tố vào một biến duy nhất.
tên biến không tương ứng với bất kỳ từ khóa nào cùng với dấu '='
đến bất kỳ trường sự kiện nào.

Khóa hoặc giá trị có thể được lưu và truy xuất theo cách này.  Cái này
tạo một biến có tên 'ts0' cho mục nhập biểu đồ bằng khóa
'next_pid'::

# echo 'hist:keys=next_pid:vals=$ts0:ts0=common_timestamp ... >> \
	sự kiện/kích hoạt

Biến ts0 có thể được truy cập bởi bất kỳ sự kiện tiếp theo nào có
cùng một pid với 'next_pid'.

Tham chiếu biến được hình thành bằng cách thêm vào trước tên biến
ký hiệu '$'.  Vì vậy, ví dụ, biến ts0 ở trên sẽ là
được tham chiếu là '$ts0' trong biểu thức.

Vì 'vals=' được sử dụng nên giá trị biến common_timestamp ở trên
cũng sẽ được tính tổng dưới dạng giá trị biểu đồ bình thường (mặc dù đối với
dấu thời gian nó không có ý nghĩa gì).

Phần bên dưới cho thấy rằng giá trị khóa cũng có thể được lưu theo cách tương tự::

# echo 'hist:timer_pid=common_pid:key=timer_pid ...' >> sự kiện/kích hoạt

Nếu một biến không phải là biến khóa hoặc có tiền tố là 'vals=', thì
trường sự kiện liên quan sẽ được lưu trong một biến nhưng sẽ không được tính tổng
dưới dạng một giá trị::

# echo 'hist:keys=next_pid:ts1=common_timestamp ...' >> sự kiện/kích hoạt

Nhiều biến có thể được chỉ định cùng một lúc.  Dưới đây sẽ
dẫn đến cả ts0 và b đều được tạo dưới dạng biến, với cả hai
common_timestamp và field1 cũng được tính tổng dưới dạng giá trị ::

# echo 'hist:keys=pid:vals=$ts0,$b:ts0=common_timestamp,b=field1 ...' >> \
	sự kiện/kích hoạt

Lưu ý rằng các phép gán biến có thể xuất hiện trước hoặc
sau khi sử dụng chúng.  Lệnh dưới đây hoạt động giống hệt với lệnh
lệnh trên::

# echo 'hist:keys=pid:ts0=common_timestamp,b=field1:vals=$ts0,$b ...' >> \
	sự kiện/kích hoạt

Bất kỳ số lượng biến nào không bị ràng buộc với tiền tố 'vals=' cũng có thể được
được chỉ định bằng cách phân tách chúng bằng dấu hai chấm.  Bên dưới cũng như vậy
nhưng không có giá trị được tính tổng trong biểu đồ::

# echo 'hist:keys=pid:ts0=common_timestamp:b=field1 ...' >> sự kiện/kích hoạt

Các biến được đặt như trên có thể được tham chiếu và sử dụng trong các biểu thức trên
một sự kiện khác.

Ví dụ: đây là cách tính độ trễ::

# echo 'hist:keys=pid,prio:ts0=common_timestamp ...' >> sự kiện1/kích hoạt
  # echo 'hist:keys=next_pid:wakeup_lat=common_timestamp-$ts0 ...' >> sự kiện2/kích hoạt

Ở dòng đầu tiên ở trên, dấu thời gian của sự kiện được lưu vào
biến ts0.  Ở dòng tiếp theo, ts0 được trừ vào số thứ hai
dấu thời gian của sự kiện để tạo ra độ trễ, sau đó được gán vào
một biến khác, 'wakeup_lat'.  Lần lượt kích hoạt hist bên dưới
sử dụng biến Wakeup_lat để tính toán độ trễ kết hợp
sử dụng cùng một khóa và biến từ một sự kiện khác::

# echo 'hist:key=pid:wakeupswitch_lat=$wakeup_lat+$switchtime_lat ...' >> sự kiện3/kích hoạt

Các biểu thức hỗ trợ việc sử dụng phép cộng, phép trừ, phép nhân và
toán tử chia (+-\*/).

Lưu ý nếu không thể phát hiện phép chia cho 0 tại thời điểm phân tích cú pháp (tức là
số chia không phải là hằng số), kết quả sẽ là -1.

Các hằng số cũng có thể được sử dụng trực tiếp trong một biểu thức::

# echo 'hist:keys=next_pid:timestamp_secs=common_timestamp/1000000 ...' >> sự kiện/kích hoạt

hoặc được gán cho một biến và được tham chiếu trong biểu thức tiếp theo ::

# echo 'hist:keys=next_pid:us_per_sec=1000000 ...' >> sự kiện/kích hoạt
  # echo 'hist:keys=next_pid:timestamp_secs=common_timestamp/$us_per_sec ...' >> sự kiện/kích hoạt

Các biến thậm chí có thể chứa dấu vết ngăn xếp, rất hữu ích với các sự kiện tổng hợp.

2.6. Sự kiện tổng hợp
---------------------

Sự kiện tổng hợp là các sự kiện do người dùng xác định được tạo từ trình kích hoạt lịch sử
các biến hoặc trường liên quan đến một hoặc nhiều sự kiện khác.  của họ
Mục đích là cung cấp một cơ chế hiển thị dữ liệu trải dài
nhiều sự kiện phù hợp với hiện tại và đã quen thuộc
sử dụng cho các sự kiện thông thường.

Để xác định một sự kiện tổng hợp, người dùng viết một đặc tả đơn giản
bao gồm tên của sự kiện mới cùng với một hoặc nhiều
các biến và loại của chúng, có thể là bất kỳ loại trường hợp lệ nào,
được phân tách bằng dấu chấm phẩy vào tệp tracing/synthetic_events.

Xem synth_field_size() để biết các loại có sẵn.

Nếu field_name chứa [n] thì trường đó được coi là một mảng tĩnh.

Nếu field_names chứa[] (không có chỉ số dưới), trường này được coi là
là một mảng động, sẽ chỉ chiếm nhiều không gian trong sự kiện như
được yêu cầu để giữ mảng.

Trường chuỗi có thể được chỉ định bằng cách sử dụng ký hiệu tĩnh:

tên char[32];

Hoặc động:

tên char[];

Giới hạn kích thước cho một trong hai là 256.

Ví dụ: phần sau đây sẽ tạo một sự kiện mới có tên 'wakeup_latency'
với 3 trường: lat, pid và prio.  Mỗi trường đó chỉ đơn giản là một
tham chiếu biến đến một biến trong một sự kiện khác::

# echo 'wakeup_latency \
          u64 lat; \
          pid_t pid; \
	  int ưu tiên' >> \
	  /sys/kernel/tracing/synthetic_events

Đọc tệp tracing/synthetic_events liệt kê tất cả các sự kiện hiện tại
các sự kiện tổng hợp được xác định, trong trường hợp này là sự kiện được xác định ở trên::

# cat/sys/kernel/tracing/synthetic_events
    Wakeup_latency u64 lat; pid_t pid; int ưu tiên

Bạn có thể xóa định nghĩa sự kiện tổng hợp hiện có bằng cách thêm vào trước
lệnh đã xác định nó bằng '!'::

# echo '!wakeup_latency u64 lat pid_t pid int prio' >> \
    /sys/kernel/tracing/synthetic_events

Tại thời điểm này, vẫn chưa có sự kiện 'wakeup_latency' thực sự
được khởi tạo trong hệ thống con sự kiện - để điều này xảy ra, một 'lịch sử
hành động kích hoạt' cần được khởi tạo và liên kết với các trường thực tế
và các biến được xác định trên các sự kiện khác (xem Phần 2.7. bên dưới về
cách thực hiện điều đó bằng cách sử dụng hành động 'onmatch' kích hoạt lịch sử). Một khi đó là
xong, phiên bản sự kiện tổng hợp 'wakeup_latency' sẽ được tạo.

Sự kiện mới được tạo trong thư mục tracing/events/synthetic/
và trông cũng như hoạt động giống như bất kỳ sự kiện nào khác::

# ls /sys/kernel/tracing/events/synthetic/wakeup_latency
        bật trình kích hoạt id lịch sử định dạng bộ lọc

Giờ đây, bạn có thể xác định biểu đồ cho sự kiện tổng hợp mới::

# echo 'hist:keys=pid,prio,lat.log2:sort=lat' >> \
        /sys/kernel/tracing/events/synthetic/wakeup_latency/trigger

Ở trên cho thấy độ trễ "lat" theo lũy thừa của 2 nhóm.

Giống như bất kỳ sự kiện nào khác, khi biểu đồ được bật cho sự kiện,
đầu ra có thể được hiển thị bằng cách đọc tệp 'lịch sử' của sự kiện ::

# cat /sys/kernel/tracing/events/synthetic/wakeup_latency/hist

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid,prio,lat.log2:vals=hitcount:sort=lat.log2:size=2048 [hoạt động]
  #

{ pid: 2035, prio: 9, lat: ~ 2^2 } số lần truy cập: 43
  { pid: 2034, prio: 9, lat: ~ 2^2 } số lần truy cập: 60
  { pid: 2029, prio: 9, lat: ~ 2^2 } số lần truy cập: 965
  { pid: 2034, prio: 120, lat: ~ 2^2 } số lần truy cập: 9
  { pid: 2033, prio: 120, lat: ~ 2^2 } số lần truy cập: 5
  { pid: 2030, prio: 9, lat: ~ 2^2 } số lần truy cập: 335
  { pid: 2030, trước: 120, lat: ~ 2^2 } số lần truy cập: 10
  { pid: 2032, prio: 120, lat: ~ 2^2 } số lần truy cập: 1
  { pid: 2035, prio: 120, lat: ~ 2^2 } số lần truy cập: 2
  { pid: 2031, prio: 9, lat: ~ 2^2 } số lần truy cập: 176
  { pid: 2028, trước: 120, lat: ~ 2^2 } số lần truy cập: 15
  { pid: 2033, prio: 9, lat: ~ 2^2 } số lần truy cập: 91
  { pid: 2032, prio: 9, lat: ~ 2^2 } số lần truy cập: 125
  { pid: 2029, trước: 120, lat: ~ 2^2 } số lần truy cập: 4
  { pid: 2031, prio: 120, lat: ~ 2^2 } số lần truy cập: 3
  { pid: 2029, trước: 120, lat: ~ 2^3 } số lần truy cập: 2
  { pid: 2035, prio: 9, lat: ~ 2^3 } số lần truy cập: 41
  { pid: 2030, trước: 120, lat: ~ 2^3 } số lần truy cập: 1
  { pid: 2032, prio: 9, lat: ~ 2^3 } số lần truy cập: 32
  { pid: 2031, prio: 9, lat: ~ 2^3 } số lần truy cập: 44
  { pid: 2034, prio: 9, lat: ~ 2^3 } số lần truy cập: 40
  { pid: 2030, prio: 9, lat: ~ 2^3 } số lần truy cập: 29
  { pid: 2033, prio: 9, lat: ~ 2^3 } số lần truy cập: 31
  { pid: 2029, prio: 9, lat: ~ 2^3 } số lần truy cập: 31
  { pid: 2028, trước: 120, lat: ~ 2^3 } số lần truy cập: 18
  { pid: 2031, prio: 120, lat: ~ 2^3 } số lần truy cập: 2
  { pid: 2028, prio: 120, lat: ~ 2^4 } số lần truy cập: 1
  { pid: 2029, prio: 9, lat: ~ 2^4 } số lần truy cập: 4
  { pid: 2031, prio: 120, lat: ~ 2^7 } số lần truy cập: 1
  { pid: 2032, prio: 120, lat: ~ 2^7 } số lần truy cập: 1

Tổng số:
      Lượt truy cập: 2122
      Bài dự thi: 30
      Đã đánh rơi: 0


Các giá trị độ trễ cũng có thể được nhóm tuyến tính theo kích thước nhất định với
công cụ sửa đổi ".buckets" và chỉ định kích thước (trong trường hợp này là nhóm 10)::

# echo 'hist:keys=pid,prio,lat.buckets=10:sort=lat' >> \
        /sys/kernel/tracing/events/synthetic/wakeup_latency/trigger

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=pid,prio,lat.buckets=10:vals=hitcount:sort=lat.buckets=10:size=2048 [hoạt động]
  #

{ pid: 2067, prio: 9, lat: ~ 0-9 } số lần truy cập: 220
  { pid: 2068, prio: 9, lat: ~ 0-9 } số lần truy cập: 157
  { pid: 2070, prio: 9, lat: ~ 0-9 } số lần truy cập: 100
  { pid: 2067, prio: 120, lat: ~ 0-9 } số lần truy cập: 6
  { pid: 2065, prio: 120, lat: ~ 0-9 } số lần truy cập: 2
  { pid: 2066, prio: 120, lat: ~ 0-9 } số lần truy cập: 2
  { pid: 2069, prio: 9, lat: ~ 0-9 } số lần truy cập: 122
  { pid: 2069, prio: 120, lat: ~ 0-9 } số lần truy cập: 8
  { pid: 2070, prio: 120, lat: ~ 0-9 } số lần truy cập: 1
  { pid: 2068, prio: 120, lat: ~ 0-9 } số lần truy cập: 7
  { pid: 2066, prio: 9, lat: ~ 0-9 } số lần truy cập: 365
  { pid: 2064, prio: 120, lat: ~ 0-9 } số lần truy cập: 35
  { pid: 2065, prio: 9, lat: ~ 0-9 } số lần truy cập: 998
  { pid: 2071, prio: 9, lat: ~ 0-9 } số lần truy cập: 85
  { pid: 2065, prio: 9, lat: ~ 10-19 } số lần truy cập: 2
  { pid: 2064, prio: 120, lat: ~ 10-19 } số lần truy cập: 2

Tổng số:
      Lượt truy cập: 2112
      Bài dự thi: 16
      Đã đánh rơi: 0

Để lưu dấu vết ngăn xếp, hãy tạo một sự kiện tổng hợp có trường loại "unsigned long[]"
hoặc thậm chí chỉ là "dài []". Ví dụ: để xem một tác vụ bị chặn trong bao lâu
trạng thái liên tục::

# cd /sys/kernel/truy tìm
  # echo 's:block_lat pid_t pid; đồng bằng u64; ngăn xếp dài không dấu [];' > sự kiện động
  # echo 'hist:keys=next_pid:ts=common_timestamp.usecs,st=common_stacktrace if prev_state == 2' >> sự kiện/lịch biểu/sched_switch/trigger
  # echo 'hist:keys=prev_pid:delta=common_timestamp.usecs-$ts,s=$st:onmax($delta).trace(block_lat,prev_pid,$delta,$s)' >> sự kiện/sched/sched_switch/trigger
  # echo 1 > sự kiện/tổng hợp/block_lat/bật
  Dấu vết # cat

# tracer: không
  #
  # entries-in-buffer/mục viết: 2/2 #P:8
  #
  #                                _-----=> irqs-off/BH-vô hiệu hóa
  # / _---=> cần được chỉnh sửa lại
  # | / _---=> hardirq/softirq
  # || / _--=> ưu tiên độ sâu
  # ||| / _-=> di chuyển-vô hiệu hóa
  # |||| / trì hoãn
  #           ZZ0003ZZ-ZZ0004ZZ CPU# |||||  TIMESTAMP FUNCTION
  #              ZZ0008ZZ ZZ0001ZZ|||ZZ0002ZZ |
            <nhàn rỗi>-0 [005] d..4.   521.164922: block_lat: pid=0 delta=8322 stack=STACK:
  => __ lịch+0x448/0x7b0
  => lịch trình+0x5a/0xb0
  => io_schedule+0x42/0x70
  => bit_wait_io+0xd/0x60
  => __wait_on_bit+0x4b/0x140
  => out_of_line_wait_on_bit+0x91/0xb0
  => jbd2_journal_commit_transaction+0x1679/0x1a70
  => kjournald2+0xa9/0x280
  => kthread+0xe9/0x110
  => ret_from_fork+0x2c/0x50

<...>-2 [004] d..4.   525.184257: block_lat: pid=2 delta=76 stack=STACK:
  => __ lịch+0x448/0x7b0
  => lịch trình+0x5a/0xb0
  => lịch_thời gian chờ+0x11a/0x150
  => wait_for_completion_killable+0x144/0x1f0
  => __kthread_create_on_node+0xe7/0x1e0
  => kthread_create_on_node+0x51/0x70
  => create_worker+0xcc/0x1a0
  => worker_thread+0x2ad/0x380
  => kthread+0xe9/0x110
  => ret_from_fork+0x2c/0x50

Một sự kiện tổng hợp có trường stacktrace có thể sử dụng nó làm khóa trong
biểu đồ::

# echo 'hist:keys=delta.buckets=100,stack.stacktrace:sort=delta' > sự kiện/tổng hợp/block_lat/kích hoạt
  Sự kiện # cat/tổng hợp/block_lat/hist

Biểu đồ # event
  #
  Thông tin về # trigger: hist:keys=delta.buckets=100,stack.stacktrace:vals=hitcount:sort=delta.buckets=100:size=2048 [đang hoạt động]
  #
  { delta: ~ 0-99, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         io_schedule+0x46/0x80
         bit_wait_io+0x11/0x80
         __wait_on_bit+0x4e/0x120
         out_of_line_wait_on_bit+0x8d/0xb0
         __wait_on_buffer+0x33/0x40
         jbd2_journal_commit_transaction+0x155a/0x19b0
         kjournald2+0xab/0x270
         kthread+0xfa/0x130
         ret_from_fork+0x29/0x50
  } số lần truy cập: 1
  { delta: ~ 0-99, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         io_schedule+0x46/0x80
         rq_qos_wait+0xd0/0x170
         wbt_wait+0x9e/0xf0
         __rq_qos_throttle+0x25/0x40
         blk_mq_submit_bio+0x2c3/0x5b0
         __submit_bio+0xff/0x190
         submit_bio_noacct_nocheck+0x25b/0x2b0
         submit_bio_noacct+0x20b/0x600
         submit_bio+0x28/0x90
         ext4_bio_write_page+0x1e0/0x8c0
         mpage_submit_page+0x60/0x80
         mpage_process_page_bufs+0x16c/0x180
         mpage_prepare_extent_to_map+0x23f/0x530
  } số lần truy cập: 1
  { delta: ~ 0-99, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         lịch_hrtimeout_range_clock+0x97/0x110
         lịch_hrtimeout_range+0x13/0x20
         usleep_range_state+0x65/0x90
         __intel_wait_for_register+0x1c1/0x230 [i915]
         intel_psr_wait_for_idle_locked+0x171/0x2a0 [i915]
         intel_pipe_update_start+0x169/0x360 [i915]
         intel_update_crtc+0x112/0x490 [i915]
         skl_commit_modeset_enables+0x199/0x600 [i915]
         intel_atomic_commit_tail+0x7c4/0x1080 [i915]
         intel_atomic_commit_work+0x12/0x20 [i915]
         process_one_work+0x21c/0x3f0
         worker_thread+0x50/0x3e0
         kthread+0xfa/0x130
  } số lần truy cập: 3
  { delta: ~ 0-99, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         lịch_timeout+0x11e/0x160
         __wait_for_common+0x8f/0x190
         wait_for_completion+0x24/0x30
         __flush_work.isra.0+0x1cc/0x360
         Flush_work+0xe/0x20
         drm_mode_rmfb+0x18b/0x1d0 [drm]
         drm_mode_rmfb_ioctl+0x10/0x20 [drm]
         drm_ioctl_kernel+0xb8/0x150 [drm]
         drm_ioctl+0x243/0x560 [drm]
         __x64_sys_ioctl+0x92/0xd0
         do_syscall_64+0x59/0x90
         entry_SYSCALL_64_after_hwframe+0x72/0xdc
  } số lần truy cập: 1
  { delta: ~ 0-99, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         lịch_timeout+0x87/0x160
         __wait_for_common+0x8f/0x190
         wait_for_completion_timeout+0x1d/0x30
         drm_atomic_helper_wait_for_flip_done+0x57/0x90 [drm_kms_helper]
         intel_atomic_commit_tail+0x8ce/0x1080 [i915]
         intel_atomic_commit_work+0x12/0x20 [i915]
         process_one_work+0x21c/0x3f0
         worker_thread+0x50/0x3e0
         kthread+0xfa/0x130
         ret_from_fork+0x29/0x50
  } số lần truy cập: 1
  { delta: ~ 100-199, stack.stacktrace __schedule+0xa19/0x1520
         lịch trình+0x6b/0x110
         lịch_hrtimeout_range_clock+0x97/0x110
         lịch_hrtimeout_range+0x13/0x20
         usleep_range_state+0x65/0x90
         pci_set_low_power_state+0x17f/0x1f0
         pci_set_power_state+0x49/0x250
         pci_finish_runtime_suspend+0x4a/0x90
         pci_pm_runtime_suspend+0xcb/0x1b0
         __rpm_callback+0x48/0x120
         vòng/phút_gọi lại+0x67/0x70
         vòng/phút_đình chỉ+0x167/0x780
         vòng/phút_không hoạt động+0x25a/0x380
         pm_runtime_work+0x93/0xc0
         process_one_work+0x21c/0x3f0
  } số lần truy cập: 1

Tổng số:
    Lượt truy cập: 10
    Bài dự thi: 7
    Đã đánh rơi: 0

2.7. Trình kích hoạt lịch sử 'trình xử lý' và 'hành động'
------------------------------------------

'Hành động' kích hoạt lịch sử là một chức năng được thực thi (trong hầu hết các trường hợp
có điều kiện) bất cứ khi nào một mục biểu đồ được thêm vào hoặc cập nhật.

Khi một mục biểu đồ được thêm hoặc cập nhật, 'trình xử lý' sẽ kích hoạt lịch sử
là yếu tố quyết định liệu hành động tương ứng có thực sự được gọi hay không
hay không.

Trình xử lý và hành động kích hoạt lịch sử được ghép nối với nhau trong tổng thể
hình thức:

<trình xử lý>.<hành động>

Để chỉ định một cặp handler.action cho một sự kiện nhất định, chỉ cần chỉ định
cặp handler.action giữa các dấu hai chấm trong trình kích hoạt lịch sử
đặc điểm kỹ thuật.

Về lý thuyết, bất kỳ trình xử lý nào cũng có thể được kết hợp với bất kỳ hành động nào, nhưng trong
thực hành, không phải mọi kết hợp handler.action hiện đều được hỗ trợ;
nếu một sự kết hợp handler.action nhất định không được hỗ trợ, thì lịch sử
kích hoạt sẽ không thành công với -EINVAL;

'Handler.action' mặc định nếu không được chỉ định rõ ràng là như vậy
luôn luôn như vậy, chỉ đơn giản là cập nhật tập hợp các giá trị liên quan đến một
nhập cảnh.  Tuy nhiên, một số ứng dụng có thể muốn thực hiện thêm
hành động tại thời điểm đó, chẳng hạn như tạo ra một sự kiện khác hoặc so sánh và
tiết kiệm tối đa.

Các trình xử lý và hành động được hỗ trợ được liệt kê bên dưới và mỗi trình xử lý đều được
được mô tả chi tiết hơn trong các đoạn văn sau, trong bối cảnh
mô tả về một số kết hợp handler.action phổ biến và hữu ích.

Các trình xử lý có sẵn là:

- onmatch(matching.event) - thực hiện hành động đối với bất kỳ bổ sung hoặc cập nhật nào
  - onmax(var) - thực hiện hành động nếu var vượt quá mức tối đa hiện tại
  - onchange(var) - gọi hành động nếu var thay đổi

Các hành động có sẵn là:

- trace(<synthetic_event_name>,param list) - tạo sự kiện tổng hợp
  - save(field,...) - lưu các trường sự kiện hiện tại
  - snapshot() - chụp nhanh bộ đệm theo dõi

Có sẵn các cặp handler.action thường được sử dụng sau đây:

- onmatch(matching.event).trace(<synthetic_event_name>,param list)

'onmatch(matching.event).trace(<synthetic_event_name>,param
    list)' hành động kích hoạt lịch sử được gọi bất cứ khi nào một sự kiện khớp
    và mục biểu đồ sẽ được thêm hoặc cập nhật.  Nó gây ra sự
    sự kiện tổng hợp được đặt tên sẽ được tạo với các giá trị được đưa ra trong
    'danh sách tham số'.  Kết quả là tạo ra một sự kiện tổng hợp
    bao gồm các giá trị chứa trong các biến đó tại
    thời điểm sự kiện gọi được thực hiện.  Ví dụ, nếu chất tổng hợp
    tên sự kiện là 'wakeup_latency', sự kiện Wakeup_latency là
    được tạo bằng onmatch(event).trace(wakeup_latency,arg1,arg2).

Ngoài ra còn có một hình thức thay thế tương đương có sẵn cho
    tạo ra các sự kiện tổng hợp.  Ở dạng này, sự kiện tổng hợp
    tên được sử dụng như thể nó là tên hàm.  Ví dụ, sử dụng
    lại tên sự kiện tổng hợp 'wakeup_latency',
    sự kiện Wakeup_latency sẽ được tạo bằng cách gọi nó như thể nó
    là một lệnh gọi hàm, với các giá trị trường sự kiện được chuyển vào dưới dạng
    đối số: onmatch(event).wakeup_latency(arg1,arg2).  Cú pháp
    cho hình thức này là:

onmatch(matching.event).<synthetic_event_name>(danh sách thông số)

Trong cả hai trường hợp, 'danh sách tham số' bao gồm một hoặc nhiều
    các tham số có thể là biến hoặc trường được xác định trên
    'matching.event' hoặc sự kiện mục tiêu.  Các biến hoặc
    các trường được chỉ định trong danh sách thông số có thể đủ điều kiện
    hoặc không đủ tiêu chuẩn.  Nếu một biến được chỉ định là không đủ tiêu chuẩn, nó
    phải là duy nhất giữa hai sự kiện.  Tên trường được sử dụng làm
    param có thể không đủ tiêu chuẩn nếu nó đề cập đến sự kiện mục tiêu, nhưng
    phải đủ điều kiện nếu nó đề cập đến sự kiện phù hợp.  A
    tên đủ điều kiện có dạng 'system.event_name.$var_name'
    hoặc 'system.event_name.field'.

Thông số kỹ thuật 'matching.event' đơn giản là đủ điều kiện
    tên sự kiện của sự kiện phù hợp với sự kiện mục tiêu cho
    chức năng onmatch(), ở dạng 'system.event_name'. biểu đồ
    khóa của cả hai sự kiện được so sánh để tìm xem sự kiện có khớp không. Trong trường hợp
    nhiều khóa biểu đồ được sử dụng, tất cả chúng phải khớp với nhau theo quy định
    đặt hàng.

Cuối cùng, số lượng và loại biến/trường trong 'param
    list' phải khớp với số lượng và loại trường trong
    sự kiện tổng hợp được tạo ra.

Như một ví dụ dưới đây định nghĩa một sự kiện tổng hợp đơn giản và sử dụng
    một biến được xác định trong sự kiện sched_wakeup_new dưới dạng tham số
    khi gọi sự kiện tổng hợp.  Ở đây chúng tôi xác định tổng hợp
    sự kiện::

# echo 'wakeup_new_test pid_t pid' >> \
             /sys/kernel/tracing/synthetic_events

# cat/sys/kernel/tracing/synthetic_events
            Wakeup_new_test pid_t pid

Trình kích hoạt lịch sử sau đây đều xác định testpid bị thiếu
    biến và chỉ định một hành động onmatch() tạo ra một
    sự kiện tổng hợp Wakeup_new_test bất cứ khi nào có sự kiện sched_wakeup_new
    xảy ra, điều này chỉ do bộ lọc 'if comm == "cycletest"'
    xảy ra khi tệp thực thi là cycltest::

# echo 'hist:keys=$testpid:testpid=pid:onmatch(sched.sched_wakeup_new).\
              Wakeup_new_test($testpid) if comm=="cycletest"' >> \
              /sys/kernel/tracing/events/sched/sched_wakeup_new/trigger

Hoặc, tương đương, sử dụng cú pháp từ khóa 'dấu vết'::

# echo 'hist:keys=$testpid:testpid=pid:onmatch(sched.sched_wakeup_new).\
              trace(wakeup_new_test,$testpid) if comm=="cycletest"' >> \
              /sys/kernel/tracing/events/sched/sched_wakeup_new/trigger

Giờ đây, việc tạo và hiển thị biểu đồ dựa trên các sự kiện đó đã trở nên dễ dàng hơn.
    chỉ là vấn đề sử dụng các trường và sự kiện tổng hợp mới trong
    thư mục truy tìm/sự kiện/tổng hợp, như thường lệ::

# echo 'hist:keys=pid:sort=pid' >> \
             /sys/kernel/tracing/events/synthetic/wakeup_new_test/trigger

Chạy 'cycletest' sẽ tạo ra các sự kiện Wakeup_new
    các sự kiện tổng hợp Wakeup_new_test sẽ tạo ra biểu đồ
    xuất ra trong tệp lịch sử của sự kiện Wakeup_new_test::

# cat /sys/kernel/tracing/events/synthetic/wakeup_new_test/hist

Cách sử dụng điển hình hơn là sử dụng hai sự kiện để tính toán
    độ trễ.  Ví dụ sau đây sử dụng một tập hợp các trình kích hoạt lịch sử để
    tạo ra biểu đồ 'wakeup_latency'.

Đầu tiên, chúng tôi xác định sự kiện tổng hợp 'wakeup_latency'::

# echo 'wakeup_latency u64 lat; pid_t pid; int ưu tiên' >> \
              /sys/kernel/tracing/synthetic_events

Tiếp theo, chúng tôi xác định rằng bất cứ khi nào chúng tôi thấy sự kiện sched_waking cho một
    luồng tuần hoàn, lưu dấu thời gian trong biến 'ts0' ::

# echo 'hist:keys=$saved_pid:saved_pid=pid:ts0=common_timestamp.usecs \
              if comm=="cycltest"' >> \
	      /sys/kernel/tracing/events/sched/sched_waking/trigger

Sau đó, khi luồng tương ứng thực sự được lên lịch trên
    CPU bởi sự kiện sched_switch (saved_pid khớp với next_pid), tính toán
    độ trễ và sử dụng nó cùng với một biến khác và trường sự kiện
    để tạo sự kiện tổng hợp Wakeup_latency::

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0:\
              onmatch(sched.sched_waking).wakeup_latency($wakeup_lat,\
	              $saved_pid,next_prio) if next_comm=="cycletest"' >> \
	      /sys/kernel/tracing/events/sched/sched_switch/trigger

Chúng ta cũng cần tạo biểu đồ trên tổng hợp Wakeup_latency
    sự kiện để tổng hợp dữ liệu sự kiện tổng hợp được tạo::

# echo 'hist:keys=pid,prio,lat:sort=pid,lat' >> \
              /sys/kernel/tracing/events/synthetic/wakeup_latency/trigger

Cuối cùng, sau khi chúng tôi chạy cycltest để thực sự tạo ra một số
    sự kiện, chúng ta có thể thấy kết quả đầu ra bằng cách xem Wakeup_latency
    tệp lịch sử của sự kiện tổng hợp::

# cat /sys/kernel/tracing/events/synthetic/wakeup_latency/hist

- onmax(var).save(field,.. .)

Hành động kích hoạt lịch sử 'onmax(var).save(field,...)' được gọi
    bất cứ khi nào giá trị của 'var' được liên kết với mục nhập biểu đồ
    vượt quá mức tối đa hiện tại có trong biến đó.

Kết quả cuối cùng là các trường sự kiện theo dõi được chỉ định là
    thông số onmax.save() sẽ được lưu nếu 'var' vượt quá giá trị hiện tại
    tối đa cho mục nhập kích hoạt lịch sử đó.  Điều này cho phép bối cảnh từ
    sự kiện thể hiện mức tối đa mới sẽ được lưu lại sau này
    tham khảo.  Khi biểu đồ được hiển thị, các trường bổ sung
    hiển thị các giá trị đã lưu sẽ được in.

Như một ví dụ dưới đây định nghĩa một vài trình kích hoạt lịch sử, một cho
    sched_waking và một cái khác cho sched_switch, được khóa trên pid.  Bất cứ khi nào
    xảy ra lịch_waking, dấu thời gian được lưu trong mục nhập
    tương ứng với pid hiện tại và khi bộ lập lịch chuyển đổi
    quay lại pid đó, sự khác biệt về dấu thời gian sẽ được tính toán.  Nếu
    độ trễ dẫn đến, được lưu trữ trong Wakeup_lat, vượt quá độ trễ hiện tại
    độ trễ tối đa, các giá trị được chỉ định trong trường save() là
    đã ghi lại::

# echo 'hist:keys=pid:ts0=common_timestamp.usecs \
              if comm=="cycltest"' >> \
              /sys/kernel/tracing/events/sched/sched_waking/trigger

# echo 'hist:keys=next_pid:\
              Wakeup_lat=common_timestamp.usecs-$ts0:\
              onmax($wakeup_lat).save(next_comm,prev_pid,prev_prio,prev_comm) \
              if next_comm=="cycltest"' >> \
              /sys/kernel/tracing/events/sched/sched_switch/trigger

Khi biểu đồ được hiển thị, giá trị tối đa và giá trị đã lưu
    các giá trị tương ứng với mức tối đa được hiển thị theo phần còn lại
    của các lĩnh vực::

# cat /sys/kernel/tracing/events/sched/sched_switch/hist
        { next_pid: 2255 } số lần truy cập: 239
          common_timestamp-ts0: 0
          tối đa: 27
	  next_comm: kiểm tra chu kỳ
          prev_pid: 0 prev_prio: 120 prev_comm: swapper/1

{ next_pid: 2256 } số lần truy cập: 2355
          common_timestamp-ts0: 0
          tối đa: 49 next_comm: cycltest
          prev_pid: 0 prev_prio: 120 prev_comm: swapper/0

Tổng số:
            Lượt truy cập: 12970
            Bài dự thi: 2
            Đã đánh rơi: 0

- onmax(var).snapshot()

Hành động kích hoạt lịch sử 'onmax(var).snapshot()' được gọi
    bất cứ khi nào giá trị của 'var' được liên kết với mục nhập biểu đồ
    vượt quá mức tối đa hiện tại có trong biến đó.

Kết quả cuối cùng là một ảnh chụp nhanh toàn cục của bộ đệm theo dõi sẽ
    được lưu trong tệp theo dõi/chụp nhanh nếu 'var' vượt quá giá trị hiện tại
    tối đa cho bất kỳ mục nhập kích hoạt lịch sử nào.

Lưu ý rằng trong trường hợp này mức tối đa là mức tối đa toàn cầu cho
    phiên bản theo dõi hiện tại, là phiên bản tối đa trên tất cả các nhóm của
    biểu đồ.  Chìa khóa của sự kiện dấu vết cụ thể đã gây ra
    mức tối đa toàn cầu và mức tối đa toàn cầu được hiển thị,
    cùng với thông báo cho biết ảnh chụp nhanh đã được chụp và
    tìm nó ở đâu  Người dùng có thể sử dụng thông tin chính được hiển thị
    để xác định vị trí nhóm tương ứng trong biểu đồ để biết thêm thông tin
    chi tiết.

Như một ví dụ dưới đây định nghĩa một vài trình kích hoạt lịch sử, một cho
    sched_waking và một cái khác cho sched_switch, được khóa trên pid.  Bất cứ khi nào
    xảy ra sự kiện sched_waking, dấu thời gian sẽ được lưu trong mục nhập
    tương ứng với pid hiện tại và khi bộ lập lịch chuyển đổi
    quay lại pid đó, sự khác biệt về dấu thời gian sẽ được tính toán.  Nếu
    độ trễ dẫn đến, được lưu trữ trong Wakeup_lat, vượt quá độ trễ hiện tại
    độ trễ tối đa, ảnh chụp nhanh sẽ được chụp.  Là một phần của quá trình thiết lập, tất cả
    các sự kiện lên lịch cũng được kích hoạt, đó là những sự kiện
    sẽ hiển thị trong ảnh chụp nhanh khi nó được chụp vào một thời điểm nào đó::

# echo 1 > /sys/kernel/tracing/events/scheduled/enable

# echo 'hist:keys=pid:ts0=common_timestamp.usecs \
              if comm=="cycltest"' >> \
              /sys/kernel/tracing/events/sched/sched_waking/trigger

# echo 'hist:keys=next_pid:wakeup_lat=common_timestamp.usecs-$ts0: \
              onmax($wakeup_lat).save(next_prio,next_comm,prev_pid,prev_prio, \
	      prev_comm):onmax($wakeup_lat).snapshot() \
	      if next_comm=="cycltest"' >> \
	      /sys/kernel/tracing/events/sched/sched_switch/trigger

Khi biểu đồ được hiển thị, đối với mỗi nhóm, giá trị tối đa
    và các giá trị đã lưu tương ứng với mức tối đa được hiển thị
    theo các trường còn lại.

Nếu ảnh chụp nhanh được chụp, cũng có thông báo cho biết rằng,
    cùng với giá trị và sự kiện đã kích hoạt mức tối đa toàn cầu::

# cat /sys/kernel/tracing/events/sched/sched_switch/hist
        { next_pid: 2101 } số lần truy cập: 200
	  tối đa: 52 next_prio: 120 next_comm: cycltest \
          prev_pid: 0 prev_prio: 120 prev_comm: swapper/6

{ next_pid: 2103 } số lần truy cập: 1326
	  tối đa: 572 next_prio: 19 next_comm: cycltest \
          prev_pid: 0 prev_prio: 120 prev_comm: swapper/1

{ next_pid: 2102 } số lần truy cập: 1982 \
	  tối đa: 74 next_prio: 19 next_comm: cycltest \
          prev_pid: 0 prev_prio: 120 prev_comm: swapper/5

Đã chụp ảnh nhanh (xem theo dõi/ảnh chụp nhanh).  Chi tiết:
	  giá trị kích hoạt { onmax($wakeup_lat) }: 572 \
	  được kích hoạt bởi sự kiện với khóa: { next_pid: 2103 }

Tổng số:
          Lượt truy cập: 3508
          Bài dự thi: 3
          Đã đánh rơi: 0

Trong trường hợp trên, sự kiện gây ra mức tối đa toàn cầu đã
    khóa có next_pid == 2103. Nếu bạn nhìn vào nhóm có
    2103 làm khóa, bạn sẽ tìm thấy các giá trị bổ sung save() cùng với
    với mức tối đa cục bộ cho nhóm đó, giá trị này phải giống nhau
    là mức tối đa toàn cầu (vì đó là cùng một giá trị mà
    đã kích hoạt ảnh chụp nhanh toàn cầu).

Và cuối cùng, nhìn vào dữ liệu ảnh chụp nhanh sẽ hiển thị ở hoặc gần
    khi kết thúc sự kiện đã kích hoạt ảnh chụp nhanh (trong trường hợp này bạn
    có thể xác minh dấu thời gian giữa sched_waking và
    sự kiện sched_switch, phải khớp với thời gian được hiển thị trong
    tối đa toàn cầu)::

# cat /sys/kernel/truy tìm/ảnh chụp nhanh

<...>-2103 [005] d..3 309.873125: sched_switch: prev_comm=cycletest prev_pid=2103 prev_prio=19 prev_state=D ==> next_comm=swapper/5 next_pid=0 next_prio=120
         <nhàn rỗi>-0 [005] d.h3 309.873611: sched_waking: comm=cycletest pid=2102 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] dNh4 309.873613: sched_wakeup: comm=cycletest pid=2102 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] d..3 309.873616: sched_switch: prev_comm=swapper/5 prev_pid=0 prev_prio=120 prev_state=S ==> next_comm=cycletest next_pid=2102 next_prio=19
         <...>-2102 [005] d..3 309.873625: sched_switch: prev_comm=cycletest prev_pid=2102 prev_prio=19 prev_state=D ==> next_comm=swapper/5 next_pid=0 next_prio=120
         <nhàn rỗi>-0 [005] d.h3 309.874624: sched_waking: comm=cycletest pid=2102 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] dNh4 309.874626: sched_wakeup: comm=cycletest pid=2102 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] dNh3 309.874628: sched_waking: comm=cycletest pid=2103 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] dNh4 309.874630: sched_wakeup: comm=cycletest pid=2103 prio=19 target_cpu=005
         <nhàn rỗi>-0 [005] d..3 309.874633: sched_switch: prev_comm=swapper/5 prev_pid=0 prev_prio=120 prev_state=S ==> next_comm=cycletest next_pid=2102 next_prio=19
         <nhàn rỗi>-0 [004] d.h3 309.874757: sched_waking: comm=gnome-terminal- pid=1699 prio=120 target_cpu=004
         <nhàn rỗi>-0 [004] dNh4 309.874762: sched_wakeup: comm=gnome-terminal- pid=1699 prio=120 target_cpu=004
         <nhàn rỗi>-0 [004] d..3 309.874766: sched_switch: prev_comm=swapper/4 prev_pid=0 prev_prio=120 prev_state=S ==> next_comm=gnome-terminal- next_pid=1699 next_prio=120
     gnome-terminal--1699 [004] d.h2 309.874941: sched_stat_runtime: comm=gnome-terminal- pid=1699 thời gian chạy=180706 [ns] vruntime=1126870572 [ns]
         <nhàn rỗi>-0 [003] d.s4 309.874956: sched_waking: comm=rcu_sched pid=9 prio=120 target_cpu=007
         <nhàn rỗi>-0 [003] d.s5 309.874960: sched_wake_idle_without_ipi: cpu=7
         <nhàn rỗi>-0 [003] d.s5 309.874961: sched_wakeup: comm=rcu_sched pid=9 prio=120 target_cpu=007
         <nhàn rỗi>-0 [007] d..3 309.874963: sched_switch: prev_comm=swapper/7 prev_pid=0 prev_prio=120 prev_state=S ==> next_comm=rcu_sched next_pid=9 next_prio=120
      rcu_sched-9 [007] d..3 309.874973: sched_stat_runtime: comm=rcu_sched pid=9 thời gian chạy=13646 [ns] vruntime=22531430286 [ns]
      rcu_sched-9 [007] d..3 309.874978: sched_switch: prev_comm=rcu_sched prev_pid=9 prev_prio=120 prev_state=R+ ==> next_comm=swapper/7 next_pid=0 next_prio=120
          <...>-2102 [005] d..4 309.874994: sched_migrate_task: comm=cycletest pid=2103 prio=19 orig_cpu=5 dest_cpu=1
          <...>-2102 [005] d..4 309.875185: sched_wake_idle_without_ipi: cpu=1
         <nhàn rỗi>-0 [001] d..3 309.875200: sched_switch: prev_comm=swapper/1 prev_pid=0 prev_prio=120 prev_state=S ==> next_comm=cycletest next_pid=2103 next_prio=19

- onchange(var).save(field,.. .)

Hành động kích hoạt lịch sử 'onchange(var).save(field,...)' được gọi
    bất cứ khi nào giá trị của 'var' được liên kết với mục nhập biểu đồ
    những thay đổi.

Kết quả cuối cùng là các trường sự kiện theo dõi được chỉ định là
    thông số onchange.save() sẽ được lưu nếu 'var' thay đổi cho điều đó
    mục nhập kích hoạt lịch sử.  Điều này cho phép bối cảnh từ sự kiện
    đã thay đổi giá trị được lưu để tham khảo sau.  Khi
    biểu đồ được hiển thị, các trường bổ sung hiển thị dữ liệu đã lưu
    các giá trị sẽ được in.

- onchange(var).snapshot()

Hành động kích hoạt lịch sử 'onchange(var).snapshot()' được gọi
    bất cứ khi nào giá trị của 'var' được liên kết với mục nhập biểu đồ
    những thay đổi.

Kết quả cuối cùng là một ảnh chụp nhanh toàn cục của bộ đệm theo dõi sẽ
    được lưu trong tệp theo dõi/chụp nhanh nếu 'var' thay đổi đối với bất kỳ
    mục nhập kích hoạt lịch sử.

Lưu ý rằng trong trường hợp này giá trị thay đổi là biến toàn cục
    được liên kết với phiên bản dấu vết hiện tại.  Chìa khóa của cụ thể
    theo dõi sự kiện khiến giá trị thay đổi và giá trị chung
    chính nó được hiển thị cùng với thông báo cho biết ảnh chụp nhanh
    đã được lấy đi và tìm nó ở đâu.  Người dùng có thể sử dụng phím
    thông tin được hiển thị để xác định vị trí nhóm tương ứng trong
    biểu đồ để biết thêm chi tiết.

Ví dụ dưới đây xác định trình kích hoạt lịch sử trên tcp_probe
    sự kiện, được khóa trên dport.  Bất cứ khi nào một sự kiện tcp_probe xảy ra,
    Trường cwnd được kiểm tra dựa trên giá trị hiện tại được lưu trong
    biến $cwnd.  Nếu giá trị đã thay đổi, ảnh chụp nhanh sẽ được chụp.
    Là một phần của quá trình thiết lập, tất cả các sự kiện lên lịch và tcp cũng được
    đã bật, đó là những sự kiện sẽ hiển thị trong ảnh chụp nhanh
    khi nó được thực hiện tại một số điểm::

# echo 1 > /sys/kernel/tracing/events/scheduled/enable
      # echo 1 > /sys/kernel/tracing/events/tcp/enable

# echo 'hist:keys=dport:cwnd=snd_cwnd: \
              onchange($cwnd).save(snd_wnd,srtt,rcv_wnd): \
	      onchange($cwnd).snapshot()' >> \
	      /sys/kernel/tracing/events/tcp/tcp_probe/trigger

Khi biểu đồ được hiển thị, đối với mỗi nhóm, giá trị được theo dõi
    và các giá trị đã lưu tương ứng với giá trị đó sẽ được hiển thị
    theo các trường còn lại.

Nếu ảnh chụp nhanh được chụp, cũng có thông báo cho biết rằng,
    cùng với giá trị và sự kiện đã kích hoạt ảnh chụp nhanh::

# cat/sys/kernel/tracing/events/tcp/tcp_probe/hist

{ dport: 1521 } số lần truy cập: 8
	đã thay đổi: 10 snd_wnd: 35456 srtt: 154262 rcv_wnd: 42112

{ dport: 80 } số lần truy cập: 23
	đã thay đổi: 10 snd_wnd: 28960 srtt: 19604 rcv_wnd: 29312

{ dport: 9001 } số lần truy cập: 172
	đã thay đổi: 10 snd_wnd: 48384 srtt: 260444 rcv_wnd: 55168

{ dport: 443 } số lần truy cập: 211
	đã thay đổi: 10 snd_wnd: 26960 srtt: 17379 rcv_wnd: 28800

Đã chụp ảnh nhanh (xem theo dõi/ảnh chụp nhanh).  Chi tiết:

giá trị kích hoạt { onchange($cwnd) }: 10
          được kích hoạt bởi sự kiện với khóa: { dport: 80 }

Tổng số:
          Lượt truy cập: 414
          Bài dự thi: 4
          Đã đánh rơi: 0

Trong trường hợp trên, sự kiện kích hoạt ảnh chụp nhanh có
    khóa có dport == 80. Nếu bạn nhìn vào nhóm có 80 là
    khóa, bạn sẽ tìm thấy các giá trị bổ sung save()'d cùng với
    giá trị đã thay đổi cho nhóm đó, giá trị này phải giống với giá trị
    giá trị thay đổi toàn cầu (vì đó là cùng một giá trị đã kích hoạt
    ảnh chụp nhanh toàn cầu).

Và cuối cùng, nhìn vào dữ liệu ảnh chụp nhanh sẽ hiển thị ở hoặc gần
    kết thúc sự kiện đã kích hoạt ảnh chụp nhanh::

# cat /sys/kernel/truy tìm/ảnh chụp nhanh

gnome-shell-1261 [006] dN.3 49.823113: sched_stat_runtime: comm=gnome-shell pid=1261 thời gian chạy=49347 [ns] vruntime=1835730389 [ns]
       kworker/u16:4-773 [003] d..3 49.823114: sched_switch: prev_comm=kworker/u16:4 prev_pid=773 prev_prio=120 prev_state=R+ ==> next_comm=kworker/3:2 next_pid=135 next_prio=120
         gnome-shell-1261 [006] d..3 49.823114: sched_switch: prev_comm=gnome-shell prev_pid=1261 prev_prio=120 prev_state=R+ ==> next_comm=kworker/6:2 next_pid=387 next_prio=120
         kworker/3:2-135 [003] d..3 49.823118: sched_stat_runtime: comm=kworker/3:2 pid=135 thời gian chạy=5339 [ns] vruntime=17815800388 [ns]
         kworker/6:2-387 [006] d..3 49.823120: sched_stat_runtime: comm=kworker/6:2 pid=387 thời gian chạy=9594 [ns] vruntime=14589605367 [ns]
         kworker/6:2-387 [006] d..3 49.823122: sched_switch: prev_comm=kworker/6:2 prev_pid=387 prev_prio=120 prev_state=R+ ==> next_comm=gnome-shell next_pid=1261 next_prio=120
         kworker/3:2-135 [003] d..3 49.823123: sched_switch: prev_comm=kworker/3:2 prev_pid=135 prev_prio=120 prev_state=T ==> next_comm=swapper/3 next_pid=0 next_prio=120
              <nhàn rỗi>-0 [004] ..s7 49.823798: tcp_probe: src=10.0.0.10:54326 dest=23.215.104.193:80 mark=0x0 length=32 snd_nxt=0xe3ae2ff5 snd_una=0xe3ae2ecd snd_cwnd=10 ssthresh=2147483647 snd_wnd=28960 srtt=19604 rcv_wnd=29312

2.8. Không gian người dùng tạo trình kích hoạt
----------------------------------

Viết vào /sys/kernel/tracing/trace_marker ghi vào ftrace
bộ đệm vòng. Điều này cũng có thể hoạt động giống như một sự kiện, bằng cách ghi vào trình kích hoạt
tập tin nằm trong /sys/kernel/tracing/events/ftrace/print/

Sửa đổi Cyclictest để ghi vào tệp trace_marker trước khi nó ngủ
và sau khi nó thức dậy, một cái gì đó như thế này ::

dấu vết void tĩnh (char *str)
  {
	/* tracemark_fd là phần mô tả tệp trace_marker */
	nếu (tracemark_fd < 0)
		trở lại;
	/*viết thông báo dấu vết */
	write(tracemark_fd, str, strlen(str));
  }

Và sau đó thêm một cái gì đó như ::

dấu vết ("bắt đầu");
	clock_nanosleep(...);
	dấu vết("kết thúc");

Chúng ta có thể tạo biểu đồ từ đây::

# cd /sys/kernel/truy tìm
 # echo 'độ trễ u64 lat' > tổng hợp_events
 # echo 'hist:keys=common_pid:ts0=common_timestamp.usecs if buf == "start"' > events/ftrace/print/trigger
 # echo 'hist:keys=common_pid:lat=common_timestamp.usecs-$ts0:onmatch(ftrace.print).latency($lat) if buf == "end"' >> events/ftrace/print/trigger
 # echo 'hist:keys=lat,common_pid:sort=lat' > sự kiện/tổng hợp/độ trễ/kích hoạt

Ở trên đã tạo ra một sự kiện tổng hợp gọi là "độ trễ" và hai biểu đồ
đối với trace_marker, nó sẽ được kích hoạt khi "bắt đầu" được ghi vào
trace_marker và tệp còn lại khi "kết thúc" được ghi. Nếu các pid khớp nhau thì
nó sẽ gọi sự kiện tổng hợp "độ trễ" với độ trễ được tính toán là
tham số. Cuối cùng, biểu đồ được thêm vào sự kiện tổng hợp độ trễ để
ghi lại độ trễ được tính toán cùng với pid.

Hiện đang chạy cycltest với::

# ./cycltest -p80 -d0 -i250 -n -a -t --tracemark -b 1000

-p80 : chạy thread ở mức ưu tiên 80
 -d0 : cho tất cả các thread chạy trong cùng một khoảng thời gian
 -i250 : bắt đầu khoảng thời gian ở 250 micro giây (tất cả các luồng sẽ thực hiện việc này)
 -n : ngủ với nanosleep
 -a : gắn tất cả các luồng vào một CPU riêng biệt
 -t : một luồng cho mỗi CPU có sẵn
 --tracemark : cho phép ghi dấu vết
 -b 1000 : dừng nếu có độ trễ lớn hơn 1000 micro giây

Lưu ý, -b 1000 chỉ được sử dụng để cung cấp --tracemark.

Sau đó, chúng ta có thể thấy biểu đồ được tạo bởi điều này với::

Sự kiện # cat/tổng hợp/độ trễ/lịch sử
 Biểu đồ # event
 #
 Thông tin về # trigger: hist:keys=lat,common_pid:vals=hitcount:sort=lat:size=2048 [hoạt động]
 #

 { lat:        107, common_pid:       2039 } hitcount:          1
 { lat:        122, common_pid:       2041 } hitcount:          1
 { lat:        166, common_pid:       2039 } hitcount:          1
 { lat:        174, common_pid:       2039 } hitcount:          1
 { lat:        194, common_pid:       2041 } hitcount:          1
 { lat:        196, common_pid:       2036 } hitcount:          1
 { lat:        197, common_pid:       2038 } hitcount:          1
 { lat:        198, common_pid:       2039 } hitcount:          1
 { lat:        199, common_pid:       2039 } hitcount:          1
 { lat:        200, common_pid:       2041 } hitcount:          1
 { lat:        201, common_pid:       2039 } hitcount:          2
 { lat:        202, common_pid:       2038 } hitcount:          1
 { lat:        202, common_pid:       2043 } hitcount:          1
 { lat:        203, common_pid:       2039 } hitcount:          1
 { lat:        203, common_pid:       2036 } hitcount:          1
 { lat:        203, common_pid:       2041 } hitcount:          1
 { lat:        206, common_pid:       2038 } hitcount:          2
 { lat:        207, common_pid:       2039 } hitcount:          1
 { lat:        207, common_pid:       2036 } hitcount:          1
 { lat:        208, common_pid:       2040 } hitcount:          1
 { lat:        209, common_pid:       2043 } hitcount:          1
 { lat:        210, common_pid:       2039 } hitcount:          1
 { lat:        211, common_pid:       2039 } hitcount:          4
 { lat:        212, common_pid:       2043 } hitcount:          1
 { lat:        212, common_pid:       2039 } hitcount:          2
 { lat:        213, common_pid:       2039 } hitcount:          1
 { lat:        214, common_pid:       2038 } hitcount:          1
 { lat:        214, common_pid:       2039 } hitcount:          2
 { lat:        214, common_pid:       2042 } hitcount:          1
 { lat:        215, common_pid:       2039 } hitcount:          1
 { lat:        217, common_pid:       2036 } hitcount:          1
 { lat:        217, common_pid:       2040 } hitcount:          1
 { lat:        217, common_pid:       2039 } hitcount:          1
 { lat:        218, common_pid:       2039 } hitcount:          6
 { lat:        219, common_pid:       2039 } hitcount:          9
 { lat:        220, common_pid:       2039 } hitcount:         11
 { lat:        221, common_pid:       2039 } hitcount:          5
 { lat:        221, common_pid:       2042 } hitcount:          1
 { lat:        222, common_pid:       2039 } hitcount:          7
 { lat:        223, common_pid:       2036 } hitcount:          1
 { lat:        223, common_pid:       2039 } hitcount:          3
 { lat:        224, common_pid:       2039 } hitcount:          4
 { lat:        224, common_pid:       2037 } hitcount:          1
 { lat:        224, common_pid:       2036 } hitcount:          2
 { lat:        225, common_pid:       2039 } hitcount:          5
 { lat:        225, common_pid:       2042 } hitcount:          1
 { lat:        226, common_pid:       2039 } hitcount:          7
 { lat:        226, common_pid:       2036 } hitcount:          4
 { lat:        227, common_pid:       2039 } hitcount:          6
 { lat:        227, common_pid:       2036 } hitcount:         12
 { lat:        227, common_pid:       2043 } hitcount:          1
 { lat:        228, common_pid:       2039 } hitcount:          7
 { lat:        228, common_pid:       2036 } hitcount:         14
 { lat:        229, common_pid:       2039 } hitcount:          9
 { lat:        229, common_pid:       2036 } hitcount:          8
 { lat:        229, common_pid:       2038 } hitcount:          1
 { lat:        230, common_pid:       2039 } hitcount:         11
 { lat:        230, common_pid:       2036 } hitcount:          6
 { lat:        230, common_pid:       2043 } hitcount:          1
 { lat:        230, common_pid:       2042 } hitcount:          2
 { lat:        231, common_pid:       2041 } hitcount:          1
 { lat:        231, common_pid:       2036 } hitcount:          6
 { lat:        231, common_pid:       2043 } hitcount:          1
 { lat:        231, common_pid:       2039 } hitcount:          8
 { lat:        232, common_pid:       2037 } hitcount:          1
 { lat:        232, common_pid:       2039 } hitcount:          6
 { lat:        232, common_pid:       2040 } hitcount:          2
 { lat:        232, common_pid:       2036 } hitcount:          5
 { lat:        232, common_pid:       2043 } hitcount:          1
 { lat:        233, common_pid:       2036 } hitcount:          5
 { lat:        233, common_pid:       2039 } hitcount:         11
 { lat:        234, common_pid:       2039 } hitcount:          4
 { lat:        234, common_pid:       2038 } hitcount:          2
 { lat:        234, common_pid:       2043 } hitcount:          2
 { lat:        234, common_pid:       2036 } hitcount:         11
 { lat:        234, common_pid:       2040 } hitcount:          1
 { lat:        235, common_pid:       2037 } hitcount:          2
 { lat:        235, common_pid:       2036 } hitcount:          8
 { lat:        235, common_pid:       2043 } hitcount:          2
 { lat:        235, common_pid:       2039 } hitcount:          5
 { lat:        235, common_pid:       2042 } hitcount:          2
 { lat:        235, common_pid:       2040 } hitcount:          4
 { lat:        235, common_pid:       2041 } hitcount:          1
 { lat:        236, common_pid:       2036 } hitcount:          7
 { lat:        236, common_pid:       2037 } hitcount:          1
 { lat:        236, common_pid:       2041 } hitcount:          5
 { lat:        236, common_pid:       2039 } hitcount:          3
 { lat:        236, common_pid:       2043 } hitcount:          9
 { lat:        236, common_pid:       2040 } hitcount:          7
 { lat:        237, common_pid:       2037 } hitcount:          1
 { lat:        237, common_pid:       2040 } hitcount:          1
 { lat:        237, common_pid:       2036 } hitcount:          9
 { lat:        237, common_pid:       2039 } hitcount:          3
 { lat:        237, common_pid:       2043 } hitcount:          8
 { lat:        237, common_pid:       2042 } hitcount:          2
 { lat:        237, common_pid:       2041 } hitcount:          2
 { lat:        238, common_pid:       2043 } hitcount:         10
 { lat:        238, common_pid:       2040 } hitcount:          1
 { lat:        238, common_pid:       2037 } hitcount:          9
 { lat:        238, common_pid:       2038 } hitcount:          1
 { lat:        238, common_pid:       2039 } hitcount:          1
 { lat:        238, common_pid:       2042 } hitcount:          3
 { lat:        238, common_pid:       2036 } hitcount:          7
 { lat:        239, common_pid:       2041 } hitcount:          1
 { lat:        239, common_pid:       2043 } hitcount:         11
 { lat:        239, common_pid:       2037 } hitcount:         11
 { lat:        239, common_pid:       2038 } hitcount:          6
 { lat:        239, common_pid:       2036 } hitcount:          7
 { lat:        239, common_pid:       2040 } hitcount:          1
 { lat:        239, common_pid:       2042 } hitcount:          9
 { lat:        240, common_pid:       2037 } hitcount:         29
 { lat:        240, common_pid:       2043 } hitcount:         15
 { lat:        240, common_pid:       2040 } hitcount:         44
 { lat:        240, common_pid:       2039 } hitcount:          1
 { lat:        240, common_pid:       2041 } hitcount:          2
 { lat:        240, common_pid:       2038 } hitcount:          1
 { lat:        240, common_pid:       2036 } hitcount:         10
 { lat:        240, common_pid:       2042 } hitcount:         13
 { lat:        241, common_pid:       2036 } hitcount:         21
 { lat:        241, common_pid:       2041 } hitcount:         36
 { lat:        241, common_pid:       2037 } hitcount:         34
 { lat:        241, common_pid:       2042 } hitcount:         14
 { lat:        241, common_pid:       2040 } hitcount:         94
 { lat:        241, common_pid:       2039 } hitcount:         12
 { lat:        241, common_pid:       2038 } hitcount:          2
 { lat:        241, common_pid:       2043 } hitcount:         28
 { lat:        242, common_pid:       2040 } hitcount:        109
 { lat:        242, common_pid:       2041 } hitcount:        506
 { lat:        242, common_pid:       2039 } hitcount:        155
 { lat:        242, common_pid:       2042 } hitcount:         21
 { lat:        242, common_pid:       2037 } hitcount:         52
 { lat:        242, common_pid:       2043 } hitcount:         21
 { lat:        242, common_pid:       2036 } hitcount:         16
 { lat:        242, common_pid:       2038 } hitcount:        156
 { lat:        243, common_pid:       2037 } hitcount:         46
 { lat:        243, common_pid:       2039 } hitcount:         40
 { lat:        243, common_pid:       2042 } hitcount:        119
 { lat:        243, common_pid:       2041 } hitcount:        611
 { lat:        243, common_pid:       2036 } hitcount:         69
 { lat:        243, common_pid:       2038 } hitcount:        784
 { lat:        243, common_pid:       2040 } hitcount:        323
 { lat:        243, common_pid:       2043 } hitcount:         14
 { lat:        244, common_pid:       2043 } hitcount:         35
 { lat:        244, common_pid:       2042 } hitcount:        305
 { lat:        244, common_pid:       2039 } hitcount:          8
 { lat:        244, common_pid:       2040 } hitcount:       4515
 { lat:        244, common_pid:       2038 } hitcount:        371
 { lat:        244, common_pid:       2037 } hitcount:         31
 { lat:        244, common_pid:       2036 } hitcount:        114
 { lat:        244, common_pid:       2041 } hitcount:       3396
 { lat:        245, common_pid:       2036 } hitcount:        700
 { lat:        245, common_pid:       2041 } hitcount:       2772
 { lat:        245, common_pid:       2037 } hitcount:        268
 { lat:        245, common_pid:       2039 } hitcount:        472
 { lat:        245, common_pid:       2038 } hitcount:       2758
 { lat:        245, common_pid:       2042 } hitcount:       3833
 { lat:        245, common_pid:       2040 } hitcount:       3105
 { lat:        245, common_pid:       2043 } hitcount:        645
 { lat:        246, common_pid:       2038 } hitcount:       3451
 { lat:        246, common_pid:       2041 } hitcount:        142
 { lat:        246, common_pid:       2037 } hitcount:       5101
 { lat:        246, common_pid:       2040 } hitcount:         68
 { lat:        246, common_pid:       2043 } hitcount:       5099
 { lat:        246, common_pid:       2039 } hitcount:       5608
 { lat:        246, common_pid:       2042 } hitcount:       3723
 { lat:        246, common_pid:       2036 } hitcount:       4738
 { lat:        247, common_pid:       2042 } hitcount:        312
 { lat:        247, common_pid:       2043 } hitcount:       2385
 { lat:        247, common_pid:       2041 } hitcount:        452
 { lat:        247, common_pid:       2038 } hitcount:        792
 { lat:        247, common_pid:       2040 } hitcount:         78
 { lat:        247, common_pid:       2036 } hitcount:       2375
 { lat:        247, common_pid:       2039 } hitcount:       1834
 { lat:        247, common_pid:       2037 } hitcount:       2655
 { lat:        248, common_pid:       2037 } hitcount:         36
 { lat:        248, common_pid:       2042 } hitcount:         11
 { lat:        248, common_pid:       2038 } hitcount:        122
 { lat:        248, common_pid:       2036 } hitcount:        135
 { lat:        248, common_pid:       2039 } hitcount:         26
 { lat:        248, common_pid:       2041 } hitcount:        503
 { lat:        248, common_pid:       2043 } hitcount:         66
 { lat:        248, common_pid:       2040 } hitcount:         46
 { lat:        249, common_pid:       2037 } hitcount:         29
 { lat:        249, common_pid:       2038 } hitcount:          1
 { lat:        249, common_pid:       2043 } hitcount:         29
 { lat:        249, common_pid:       2039 } hitcount:          8
 { lat:        249, common_pid:       2042 } hitcount:         56
 { lat:        249, common_pid:       2040 } hitcount:         27
 { lat:        249, common_pid:       2041 } hitcount:         11
 { lat:        249, common_pid:       2036 } hitcount:         27
 { lat:        250, common_pid:       2038 } hitcount:          1
 { lat:        250, common_pid:       2036 } hitcount:         30
 { lat:        250, common_pid:       2040 } hitcount:         19
 { lat:        250, common_pid:       2043 } hitcount:         22
 { lat:        250, common_pid:       2042 } hitcount:         20
 { lat:        250, common_pid:       2041 } hitcount:          1
 { lat:        250, common_pid:       2039 } hitcount:          6
 { lat:        250, common_pid:       2037 } hitcount:         48
 { lat:        251, common_pid:       2037 } hitcount:         43
 { lat:        251, common_pid:       2039 } hitcount:          1
 { lat:        251, common_pid:       2036 } hitcount:         12
 { lat:        251, common_pid:       2042 } hitcount:          2
 { lat:        251, common_pid:       2041 } hitcount:          1
 { lat:        251, common_pid:       2043 } hitcount:         15
 { lat:        251, common_pid:       2040 } hitcount:          3
 { lat:        252, common_pid:       2040 } hitcount:          1
 { lat:        252, common_pid:       2036 } hitcount:         12
 { lat:        252, common_pid:       2037 } hitcount:         21
 { lat:        252, common_pid:       2043 } hitcount:         14
 { lat:        253, common_pid:       2037 } hitcount:         21
 { lat:        253, common_pid:       2039 } hitcount:          2
 { lat:        253, common_pid:       2036 } hitcount:          9
 { lat:        253, common_pid:       2043 } hitcount:          6
 { lat:        253, common_pid:       2040 } hitcount:          1
 { lat:        254, common_pid:       2036 } hitcount:          8
 { lat:        254, common_pid:       2043 } hitcount:          3
 { lat:        254, common_pid:       2041 } hitcount:          1
 { lat:        254, common_pid:       2042 } hitcount:          1
 { lat:        254, common_pid:       2039 } hitcount:          1
 { lat:        254, common_pid:       2037 } hitcount:         12
 { lat:        255, common_pid:       2043 } hitcount:          1
 { lat:        255, common_pid:       2037 } hitcount:          2
 { lat:        255, common_pid:       2036 } hitcount:          2
 { lat:        255, common_pid:       2039 } hitcount:          8
 { lat:        256, common_pid:       2043 } hitcount:          1
 { lat:        256, common_pid:       2036 } hitcount:          4
 { lat:        256, common_pid:       2039 } hitcount:          6
 { lat:        257, common_pid:       2039 } hitcount:          5
 { lat:        257, common_pid:       2036 } hitcount:          4
 { lat:        258, common_pid:       2039 } hitcount:          5
 { lat:        258, common_pid:       2036 } hitcount:          2
 { lat:        259, common_pid:       2036 } hitcount:          7
 { lat:        259, common_pid:       2039 } hitcount:          7
 { lat:        260, common_pid:       2036 } hitcount:          8
 { lat:        260, common_pid:       2039 } hitcount:          6
 { lat:        261, common_pid:       2036 } hitcount:          5
 { lat:        261, common_pid:       2039 } hitcount:          7
 { lat:        262, common_pid:       2039 } hitcount:          5
 { lat:        262, common_pid:       2036 } hitcount:          5
 { lat:        263, common_pid:       2039 } hitcount:          7
 { lat:        263, common_pid:       2036 } hitcount:          7
 { lat:        264, common_pid:       2039 } hitcount:          9
 { lat:        264, common_pid:       2036 } hitcount:          9
 { lat:        265, common_pid:       2036 } hitcount:          5
 { lat:        265, common_pid:       2039 } hitcount:          1
 { lat:        266, common_pid:       2036 } hitcount:          1
 { lat:        266, common_pid:       2039 } hitcount:          3
 { lat:        267, common_pid:       2036 } hitcount:          1
 { lat:        267, common_pid:       2039 } hitcount:          3
 { lat:        268, common_pid:       2036 } hitcount:          1
 { lat:        268, common_pid:       2039 } hitcount:          6
 { lat:        269, common_pid:       2036 } hitcount:          1
 { lat:        269, common_pid:       2043 } hitcount:          1
 { lat:        269, common_pid:       2039 } hitcount:          2
 { lat:        270, common_pid:       2040 } hitcount:          1
 { lat:        270, common_pid:       2039 } hitcount:          6
 { lat:        271, common_pid:       2041 } hitcount:          1
 { lat:        271, common_pid:       2039 } hitcount:          5
 { lat:        272, common_pid:       2039 } hitcount:         10
 { lat:        273, common_pid:       2039 } hitcount:          8
 { lat:        274, common_pid:       2039 } hitcount:          2
 { lat:        275, common_pid:       2039 } hitcount:          1
 { lat:        276, common_pid:       2039 } hitcount:          2
 { lat:        276, common_pid:       2037 } hitcount:          1
 { lat:        276, common_pid:       2038 } hitcount:          1
 { lat:        277, common_pid:       2039 } hitcount:          1
 { lat:        277, common_pid:       2042 } hitcount:          1
 { lat:        278, common_pid:       2039 } hitcount:          1
 { lat:        279, common_pid:       2039 } hitcount:          4
 { lat:        279, common_pid:       2043 } hitcount:          1
 { lat:        280, common_pid:       2039 } hitcount:          3
 { lat:        283, common_pid:       2036 } hitcount:          2
 { lat:        284, common_pid:       2039 } hitcount:          1
 { lat:        284, common_pid:       2043 } hitcount:          1
 { lat:        288, common_pid:       2039 } hitcount:          1
 { lat:        289, common_pid:       2039 } hitcount:          1
 { lat:        300, common_pid:       2039 } hitcount:          1
 { lat:        384, common_pid:       2039 } hitcount:          1

Tổng số:
     Lượt truy cập: 67625
     Bài dự thi: 278
     Đã đánh rơi: 0

Lưu ý, số lần ghi diễn ra xung quanh giấc ngủ, vì vậy lý tưởng nhất là tất cả chúng sẽ có giá trị 250
micro giây. Nếu bạn đang thắc mắc làm thế nào có một số điều đó nằm dưới
250 micro giây, đó là do cách thức hoạt động của cycltest, là nếu một
lần lặp đến muộn, lần tiếp theo sẽ đặt đồng hồ để thức dậy ít hơn
250. Nghĩa là, nếu một lần lặp lại trễ 50 micro giây thì lần đánh thức tiếp theo
sẽ ở mức 200 micro giây.

Nhưng điều này có thể dễ dàng được thực hiện trong không gian người dùng. Để làm điều này nhiều hơn nữa
Thật thú vị, chúng ta có thể kết hợp biểu đồ giữa các sự kiện xảy ra trong
hạt nhân với trace_marker::

# cd /sys/kernel/truy tìm
 # echo 'độ trễ u64 lat' > tổng hợp_events
 # echo 'hist:keys=pid:ts0=common_timestamp.usecs' > events/sched/sched_waking/trigger
 # echo 'hist:keys=common_pid:lat=common_timestamp.usecs-$ts0:onmatch(sched.sched_waking).latency($lat) if buf == "end"' > events/ftrace/print/trigger
 # echo 'hist:keys=lat,common_pid:sort=lat' > sự kiện/tổng hợp/độ trễ/kích hoạt

Sự khác biệt lần này là thay vì sử dụng trace_marker để bắt đầu
độ trễ, sự kiện sched_waking được sử dụng, khớp với common_pid cho
trace_marker viết bằng pid đang được đánh thức bởi sched_waking.

Sau khi chạy lại cyclest với các thông số tương tự, bây giờ chúng ta có ::

Sự kiện # cat/tổng hợp/độ trễ/lịch sử
 Biểu đồ # event
 #
 Thông tin về # trigger: hist:keys=lat,common_pid:vals=hitcount:sort=lat:size=2048 [hoạt động]
 #

 { lat:          7, common_pid:       2302 } hitcount:        640
 { lat:          7, common_pid:       2299 } hitcount:         42
 { lat:          7, common_pid:       2303 } hitcount:         18
 { lat:          7, common_pid:       2305 } hitcount:        166
 { lat:          7, common_pid:       2306 } hitcount:          1
 { lat:          7, common_pid:       2301 } hitcount:         91
 { lat:          7, common_pid:       2300 } hitcount:         17
 { lat:          8, common_pid:       2303 } hitcount:       8296
 { lat:          8, common_pid:       2304 } hitcount:       6864
 { lat:          8, common_pid:       2305 } hitcount:       9464
 { lat:          8, common_pid:       2301 } hitcount:       9213
 { lat:          8, common_pid:       2306 } hitcount:       6246
 { lat:          8, common_pid:       2302 } hitcount:       8797
 { lat:          8, common_pid:       2299 } hitcount:       8771
 { lat:          8, common_pid:       2300 } hitcount:       8119
 { lat:          9, common_pid:       2305 } hitcount:       1519
 { lat:          9, common_pid:       2299 } hitcount:       2346
 { lat:          9, common_pid:       2303 } hitcount:       2841
 { lat:          9, common_pid:       2301 } hitcount:       1846
 { lat:          9, common_pid:       2304 } hitcount:       3861
 { lat:          9, common_pid:       2302 } hitcount:       1210
 { lat:          9, common_pid:       2300 } hitcount:       2762
 { lat:          9, common_pid:       2306 } hitcount:       4247
 { lat:         10, common_pid:       2299 } hitcount:         16
 { lat:         10, common_pid:       2306 } hitcount:        333
 { lat:         10, common_pid:       2303 } hitcount:         16
 { lat:         10, common_pid:       2304 } hitcount:        168
 { lat:         10, common_pid:       2302 } hitcount:        240
 { lat:         10, common_pid:       2301 } hitcount:         28
 { lat:         10, common_pid:       2300 } hitcount:         95
 { lat:         10, common_pid:       2305 } hitcount:         18
 { lat:         11, common_pid:       2303 } hitcount:          5
 { lat:         11, common_pid:       2305 } hitcount:          8
 { lat:         11, common_pid:       2306 } hitcount:        221
 { lat:         11, common_pid:       2302 } hitcount:         76
 { lat:         11, common_pid:       2304 } hitcount:         26
 { lat:         11, common_pid:       2300 } hitcount:        125
 { lat:         11, common_pid:       2299 } hitcount:          2
 { lat:         12, common_pid:       2305 } hitcount:          3
 { lat:         12, common_pid:       2300 } hitcount:          6
 { lat:         12, common_pid:       2306 } hitcount:         90
 { lat:         12, common_pid:       2302 } hitcount:          4
 { lat:         12, common_pid:       2303 } hitcount:          1
 { lat:         12, common_pid:       2304 } hitcount:        122
 { lat:         13, common_pid:       2300 } hitcount:         12
 { lat:         13, common_pid:       2301 } hitcount:          1
 { lat:         13, common_pid:       2306 } hitcount:         32
 { lat:         13, common_pid:       2302 } hitcount:          5
 { lat:         13, common_pid:       2305 } hitcount:          1
 { lat:         13, common_pid:       2303 } hitcount:          1
 { lat:         13, common_pid:       2304 } hitcount:         61
 { lat:         14, common_pid:       2303 } hitcount:          4
 { lat:         14, common_pid:       2306 } hitcount:          5
 { lat:         14, common_pid:       2305 } hitcount:          4
 { lat:         14, common_pid:       2304 } hitcount:         62
 { lat:         14, common_pid:       2302 } hitcount:         19
 { lat:         14, common_pid:       2300 } hitcount:         33
 { lat:         14, common_pid:       2299 } hitcount:          1
 { lat:         14, common_pid:       2301 } hitcount:          4
 { lat:         15, common_pid:       2305 } hitcount:          1
 { lat:         15, common_pid:       2302 } hitcount:         25
 { lat:         15, common_pid:       2300 } hitcount:         11
 { lat:         15, common_pid:       2299 } hitcount:          5
 { lat:         15, common_pid:       2301 } hitcount:          1
 { lat:         15, common_pid:       2304 } hitcount:          8
 { lat:         15, common_pid:       2303 } hitcount:          1
 { lat:         15, common_pid:       2306 } hitcount:          6
 { lat:         16, common_pid:       2302 } hitcount:         31
 { lat:         16, common_pid:       2306 } hitcount:          3
 { lat:         16, common_pid:       2300 } hitcount:          5
 { lat:         17, common_pid:       2302 } hitcount:          6
 { lat:         17, common_pid:       2303 } hitcount:          1
 { lat:         18, common_pid:       2304 } hitcount:          1
 { lat:         18, common_pid:       2302 } hitcount:          8
 { lat:         18, common_pid:       2299 } hitcount:          1
 { lat:         18, common_pid:       2301 } hitcount:          1
 { lat:         19, common_pid:       2303 } hitcount:          4
 { lat:         19, common_pid:       2304 } hitcount:          5
 { lat:         19, common_pid:       2302 } hitcount:          4
 { lat:         19, common_pid:       2299 } hitcount:          3
 { lat:         19, common_pid:       2306 } hitcount:          1
 { lat:         19, common_pid:       2300 } hitcount:          4
 { lat:         19, common_pid:       2305 } hitcount:          5
 { lat:         20, common_pid:       2299 } hitcount:          2
 { lat:         20, common_pid:       2302 } hitcount:          3
 { lat:         20, common_pid:       2305 } hitcount:          1
 { lat:         20, common_pid:       2300 } hitcount:          2
 { lat:         20, common_pid:       2301 } hitcount:          2
 { lat:         20, common_pid:       2303 } hitcount:          3
 { lat:         21, common_pid:       2305 } hitcount:          1
 { lat:         21, common_pid:       2299 } hitcount:          5
 { lat:         21, common_pid:       2303 } hitcount:          4
 { lat:         21, common_pid:       2302 } hitcount:          7
 { lat:         21, common_pid:       2300 } hitcount:          1
 { lat:         21, common_pid:       2301 } hitcount:          5
 { lat:         21, common_pid:       2304 } hitcount:          2
 { lat:         22, common_pid:       2302 } hitcount:          5
 { lat:         22, common_pid:       2303 } hitcount:          1
 { lat:         22, common_pid:       2306 } hitcount:          3
 { lat:         22, common_pid:       2301 } hitcount:          2
 { lat:         22, common_pid:       2300 } hitcount:          1
 { lat:         22, common_pid:       2299 } hitcount:          1
 { lat:         22, common_pid:       2305 } hitcount:          1
 { lat:         22, common_pid:       2304 } hitcount:          1
 { lat:         23, common_pid:       2299 } hitcount:          1
 { lat:         23, common_pid:       2306 } hitcount:          2
 { lat:         23, common_pid:       2302 } hitcount:          6
 { lat:         24, common_pid:       2302 } hitcount:          3
 { lat:         24, common_pid:       2300 } hitcount:          1
 { lat:         24, common_pid:       2306 } hitcount:          2
 { lat:         24, common_pid:       2305 } hitcount:          1
 { lat:         24, common_pid:       2299 } hitcount:          1
 { lat:         25, common_pid:       2300 } hitcount:          1
 { lat:         25, common_pid:       2302 } hitcount:          4
 { lat:         26, common_pid:       2302 } hitcount:          2
 { lat:         27, common_pid:       2305 } hitcount:          1
 { lat:         27, common_pid:       2300 } hitcount:          1
 { lat:         27, common_pid:       2302 } hitcount:          3
 { lat:         28, common_pid:       2306 } hitcount:          1
 { lat:         28, common_pid:       2302 } hitcount:          4
 { lat:         29, common_pid:       2302 } hitcount:          1
 { lat:         29, common_pid:       2300 } hitcount:          2
 { lat:         29, common_pid:       2306 } hitcount:          1
 { lat:         29, common_pid:       2304 } hitcount:          1
 { lat:         30, common_pid:       2302 } hitcount:          4
 { lat:         31, common_pid:       2302 } hitcount:          6
 { lat:         32, common_pid:       2302 } hitcount:          1
 { lat:         33, common_pid:       2299 } hitcount:          1
 { lat:         33, common_pid:       2302 } hitcount:          3
 { lat:         34, common_pid:       2302 } hitcount:          2
 { lat:         35, common_pid:       2302 } hitcount:          1
 { lat:         35, common_pid:       2304 } hitcount:          1
 { lat:         36, common_pid:       2302 } hitcount:          4
 { lat:         37, common_pid:       2302 } hitcount:          6
 { lat:         38, common_pid:       2302 } hitcount:          2
 { lat:         39, common_pid:       2302 } hitcount:          2
 { lat:         39, common_pid:       2304 } hitcount:          1
 { lat:         40, common_pid:       2304 } hitcount:          2
 { lat:         40, common_pid:       2302 } hitcount:          5
 { lat:         41, common_pid:       2304 } hitcount:          1
 { lat:         41, common_pid:       2302 } hitcount:          8
 { lat:         42, common_pid:       2302 } hitcount:          6
 { lat:         42, common_pid:       2304 } hitcount:          1
 { lat:         43, common_pid:       2302 } hitcount:          3
 { lat:         43, common_pid:       2304 } hitcount:          4
 { lat:         44, common_pid:       2302 } hitcount:          6
 { lat:         45, common_pid:       2302 } hitcount:          5
 { lat:         46, common_pid:       2302 } hitcount:          5
 { lat:         47, common_pid:       2302 } hitcount:          7
 { lat:         48, common_pid:       2301 } hitcount:          1
 { lat:         48, common_pid:       2302 } hitcount:          9
 { lat:         49, common_pid:       2302 } hitcount:          3
 { lat:         50, common_pid:       2302 } hitcount:          1
 { lat:         50, common_pid:       2301 } hitcount:          1
 { lat:         51, common_pid:       2302 } hitcount:          2
 { lat:         51, common_pid:       2301 } hitcount:          1
 { lat:         61, common_pid:       2302 } hitcount:          1
 { lat:        110, common_pid:       2302 } hitcount:          1

Tổng số:
     Lượt truy cập: 89565
     Bài dự thi: 158
     Đã đánh rơi: 0

Điều này không cho chúng tôi biết bất kỳ thông tin nào về việc kiểm tra chu kỳ muộn có thể xảy ra như thế nào
thức dậy, nhưng nó cho chúng ta thấy một biểu đồ đẹp về khoảng thời gian
thời điểm cyclest được đánh thức tính đến thời điểm nó được đưa vào không gian người dùng.
