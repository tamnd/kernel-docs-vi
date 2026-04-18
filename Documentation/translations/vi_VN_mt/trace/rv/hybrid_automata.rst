.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/hybrid_automata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Máy tự động lai
===============

Các automata lai là một phần mở rộng của automata xác định, có một số
định nghĩa về automata lai trong tài liệu. Việc thích ứng được thực hiện
ở đây được ký hiệu chính thức là G và được định nghĩa là bộ 7:

ZZ0002ZZ = { ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ, x\ ZZ0000ZZ, X\ ZZ0001ZZ, ZZ0007ZZ }

- ZZ0002ZZ là tập hợp các trạng thái;
- ZZ0003ZZ là tập hữu hạn các sự kiện;
- ZZ0004ZZ là tập hữu hạn các biến môi trường;
- x\ ZZ0000ZZ là trạng thái ban đầu;
- X\ ZZ0001ZZ (tập con của ZZ0005ZZ) là tập hợp các trạng thái được đánh dấu (hoặc cuối cùng).
- ZZ0006ZZ : ZZ0007ZZ x ZZ0008ZZ x ZZ0009ZZ -> ZZ0010ZZ là hàm chuyển tiếp.
  Nó xác định sự chuyển đổi trạng thái khi xảy ra sự kiện từ ZZ0011ZZ trong
  trạng thái ZZ0012ZZ. Không giống như automata xác định, hàm chuyển đổi cũng
  bao gồm các bộ bảo vệ từ tập hợp tất cả các ràng buộc có thể có (được định nghĩa là ZZ0013ZZ).
  Các biện pháp bảo vệ có thể đúng hoặc sai với việc định giá ZZ0014ZZ khi sự kiện xảy ra,
  và việc chuyển đổi chỉ có thể thực hiện được khi các ràng buộc là đúng. Tương tự với
  automata xác định, sự xuất hiện của sự kiện trong ZZ0015ZZ ở trạng thái trong ZZ0016ZZ
  có trạng thái tiếp theo xác định từ ZZ0017ZZ, nếu bảo vệ là đúng.
- ZZ0018ZZ : ZZ0019ZZ -> ZZ0020ZZ là hàm gán bất biến, đây là một
  ràng buộc được gán cho từng trạng thái trong ZZ0021ZZ, mọi trạng thái trong ZZ0022ZZ phải được để lại
  trước khi bất biến chuyển thành sai. Chúng ta có thể bỏ qua sự biểu diễn của
  bất biến có giá trị đúng bất kể giá trị của ZZ0023ZZ.

Tập hợp tất cả các ràng buộc có thể có ZZ0000ZZ được xác định theo
ngữ pháp sau:

g = v < c ZZ0000ZZ v <= c ZZ0001ZZ v == c ZZ0002ZZ g && g | ĐÚNG VẬY

Với v một biến trong ZZ0000ZZ và c một giá trị số.

Chúng ta xác định trường hợp đặc biệt của automata lai có các biến tăng dần đều
tỷ lệ như máy tự động tính thời gian. Trong trường hợp này, các biến được gọi là đồng hồ.
Đúng như tên gọi, automata tính thời gian có thể được sử dụng để mô tả thời gian thực.
Ngoài ra, đồng hồ còn hỗ trợ một loại bảo vệ khác luôn đánh giá là đúng:

đặt lại (v)

Ràng buộc reset được sử dụng để đặt giá trị của đồng hồ về 0.

Tập hợp các ràng buộc bất biến ZZ0000ZZ là tập con của ZZ0001ZZ chỉ bao gồm
ràng buộc của hình thức:

g = v < c | ĐÚNG VẬY

Điều này giúp đơn giản hóa việc thực hiện vì việc hết hạn đồng hồ là cần thiết và
điều kiện đủ để vi phạm bất biến trong khi vẫn cho phép nhiều hơn
các ràng buộc phức tạp được chỉ định là bảo vệ.

Điều quan trọng cần lưu ý là bất kỳ máy tự động lai nào cũng có tính xác định hợp lệ.
máy tự động với các bảo vệ bổ sung và bất biến. Những điều đó chỉ có thể tiếp tục
hạn chế những chuyển tiếp nào là hợp lệ nhưng không thể xác định
các hàm chuyển đổi bắt đầu từ cùng một trạng thái trong ZZ0000ZZ và cùng một sự kiện trong
ZZ0001ZZ nhưng kết thúc ở các trạng thái khác nhau trong ZZ0002ZZ dựa trên việc định giá ZZ0003ZZ.

Ví dụ
--------

Lau dưới dạng máy tự động lai
~~~~~~~~~~~~~~~~~~~~~~~

Ví dụ 'wip' (đánh thức trong chế độ phủ đầu) được giới thiệu dưới dạng máy tự động xác định
cũng có thể được mô tả như sau:

- ZZ0013ZZ = { ZZ0002ZZ }
- ZZ0014ZZ = { ZZ0003ZZ }
- ZZ0015ZZ = { ZZ0004ZZ }
- x\ ZZ0000ZZ = ZZ0005ZZ
- X\ ZZ0001ZZ = {ZZ0006ZZ}
- ZZ0016ZZ =
   - ZZ0017ZZ\ (ZZ0007ZZ, ZZ0008ZZ, ZZ0009ZZ) = ZZ0010ZZ
- ZZ0018ZZ =
   - ZZ0019ZZ\ (ZZ0011ZZ) = ZZ0012ZZ

Có thể được biểu diễn bằng đồ họa dưới dạng::

|
     |
     v
   #======================#   sched_waking; phòng ngừa==0
   HH ------------------------------ +
   H Any_thread_running H |
   HH <-----------------------------+
   #======================#

Trong ví dụ này, bằng cách sử dụng trạng thái ưu tiên của hệ thống làm môi trường
biến, chúng ta có thể xác nhận ràng buộc này trên ZZ0000ZZ mà không yêu cầu
các sự kiện ưu tiên (như chúng ta làm trong một máy tự động xác định), có thể
hữu ích trong trường hợp những sự kiện đó không có sẵn hoặc không đáng tin cậy trên hệ thống.

Vì tất cả các bất biến trong ZZ0000ZZ đều đúng nên chúng ta có thể bỏ qua chúng khỏi biểu diễn.

Mô hình gian hàng có bảo vệ (lần 1)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Là một máy tự động định thời gian mẫu, chúng ta có thể định nghĩa 'gian hàng' là:

- ZZ0022ZZ = {ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ}
- ZZ0023ZZ = {ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ}
- ZZ0024ZZ = { ZZ0008ZZ }
- x\ ZZ0000ZZ = ZZ0009ZZ
- X\ ZZ0001ZZ = {ZZ0010ZZ}
- ZZ0025ZZ =
   - ZZ0026ZZ\ (ZZ0011ZZ, ZZ0012ZZ, ZZ0013ZZ) = ZZ0014ZZ
   - ZZ0027ZZ\ (ZZ0015ZZ, ZZ0016ZZ) = ZZ0017ZZ
   - ZZ0028ZZ\ (ZZ0018ZZ, ZZ0019ZZ, ZZ0020ZZ) = ZZ0021ZZ
- ZZ0029ZZ = ZZ0030ZZ

Được thể hiện bằng đồ họa dưới dạng::

|
       |
       v
     #===============================#
     H đã bị loại H <+
     #================================# |
       ZZ0000ZZ
       ZZ0001ZZ
       v |
     +-----------------------------+ |
     ZZ0002ZZ | xếp hàng
     +-----------------------------+ |
       ZZ0003ZZ
       ZZ0004ZZ
       v |
     +-----------------------------+ |
     ZZ0005ZZ-+
     +-----------------------------+

Mô hình này áp đặt rằng khoảng thời gian giữa khi một tác vụ được xếp vào hàng đợi (nó trở thành
có thể chạy được) và thời điểm tác vụ được chạy phải thấp hơn một ngưỡng nhất định.
Một thất bại trong mô hình này có nghĩa là nhiệm vụ đang bị thiếu.
Một vấn đề trong việc sử dụng các tấm bảo vệ ở các cạnh trong trường hợp này là mô hình sẽ
không báo cáo lỗi cho đến khi sự kiện ZZ0000ZZ xảy ra. Điều này có nghĩa là,
theo mô hình, nó hợp lệ cho tác vụ không bao giờ chạy.

Mô hình dừng với bất biến (lặp 2)
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Lần lặp đầu tiên không chính xác như dự định, chúng ta có thể thay đổi mô hình thành:

- ZZ0023ZZ = { ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ}
- ZZ0024ZZ = {ZZ0005ZZ, ZZ0006ZZ, ZZ0007ZZ}
- ZZ0025ZZ = { ZZ0008ZZ }
- x\ ZZ0000ZZ = ZZ0009ZZ
- X\ ZZ0001ZZ = {ZZ0010ZZ}
- ZZ0026ZZ =
   - ZZ0027ZZ\ (ZZ0011ZZ, ZZ0012ZZ) = ZZ0013ZZ
   - ZZ0028ZZ\ (ZZ0014ZZ, ZZ0015ZZ) = ZZ0016ZZ
   - ZZ0029ZZ\ (ZZ0017ZZ, ZZ0018ZZ, ZZ0019ZZ) = ZZ0020ZZ
- ZZ0030ZZ =
   - ZZ0031ZZ\ (ZZ0021ZZ) = ZZ0022ZZ

Về mặt đồ họa::

|
    |
    v
  #============================#
  H đã bị loại H <+
  #============================# |
    ZZ0000ZZ
    ZZ0001ZZ
    v |
  +-----------------+ |
  ZZ0002ZZ |
  ZZ0003ZZ | xếp hàng
  +-----------------+ |
    ZZ0004ZZ
    ZZ0005ZZ
    v |
  +-----------------+ |
  ZZ0006ZZ-+
  +-----------------+

Trong trường hợp này, chúng tôi đã di chuyển bộ bảo vệ dưới dạng bất biến sang trạng thái ZZ0000ZZ,
điều này có nghĩa là chúng tôi không chỉ cấm sự xuất hiện của ZZ0001ZZ khi ZZ0002ZZ được
vượt quá ngưỡng nhưng cũng đánh dấu là không hợp lệ trong trường hợp chúng tôi là ZZ0004ZZ
ZZ0003ZZ sau ngưỡng. Mô hình này thực sự ở trạng thái không hợp lệ
ngay khi một tác vụ sắp chết đói, thay vì khi tác vụ sắp đói đó cuối cùng đã chạy.

Máy tự động lai trong C
---------------------

Định nghĩa của automata lai trong C chủ yếu dựa trên tính xác định
máy tự động một. Cụ thể, chúng tôi thêm tập hợp các biến môi trường và
các ràng buộc (cả bảo vệ đối với quá trình chuyển đổi và bất biến đối với các trạng thái) như sau.
Đây là sự kết hợp của cả hai lần lặp lại ví dụ gian hàng::

/* biểu diễn enum của X (tập hợp các trạng thái) được sử dụng làm chỉ mục */
  trạng thái enum {
	bị hủy hàng,
	xếp hàng,
	chạy,
	trạng thái_max,
  };

Trạng thái #define INVALID_STATE_max

/* đại diện enum của E (tập hợp các sự kiện) được sử dụng làm chỉ mục */
  sự kiện enum {
	xếp hàng,
	xếp hàng,
	chuyển_in,
	sự kiện_max,
  };

/* biểu diễn enum của V (tập hợp các biến môi trường) được sử dụng làm chỉ mục */
  enum env {
	cạch,
	env_max,
	env_max_stored = env_max,
  };

cấu trúc tự động hóa {
	char *state_names[state_max];                  // X: tập hợp các trạng thái
	char *event_names[event_max];                  // E: tập hữu hạn các sự kiện
	char *env_names[env_max];                      // V: tập hợp hữu hạn các env vars
	hàm char không dấu[state_max][event_max];  // f: hàm chuyển tiếp
	char không dấu init_state;                   // x_0: trạng thái ban đầu
	bool Final_states[state_max];                  // X_m: tập hợp các trạng thái được đánh dấu
  };

cấu trúc máy tự động aut = {
	.state_names = {
		"xếp hàng",
		"xếp hàng",
		"chạy",
	},
	.event_names = {
		"xếp hàng",
		"xếp hàng",
		"switch_in",
	},
	.env_names = {
		"cạch",
	},
	.function = {
		{ INVALID_STATE, đã xếp hàng, INVALID_STATE },
		{ INVALID_STATE, INVALID_STATE, đang chạy },
		{ đã xếp hàng, INVALID_STATE, INVALID_STATE },
	},
	.initial_state = được xếp hàng đợi,
	.final_states = { 1, 0, 0 },
  };

bool tĩnh verify_constraint(enum trạng thái curr_state, sự kiện enum,
                                trạng thái enum next_state)
  {
	bool res = đúng;

/* Xác thực các bộ bảo vệ như một phần của f */
	if (curr_state == được xếp hàng && sự kiện == switch_in)
		res = get_env(clk) < ngưỡng;
	khác nếu (curr_state == đã xếp hàng && sự kiện == enqueue)
		reset_env(clk);

/* Xác thực các bất biến trong i */
	if (next_state == curr_state || !res)
		trả lại độ phân giải;
	if (next_state == được xếp hàng đợi)
		ha_start_timer_jiffy(ha_mon, clk, ngưỡng_jiffies);
	khác nếu (curr_state == được xếp hàng)
		res = !ha_cancel_timer(ha_mon);
	trả lại độ phân giải;
  }

Chức năng ZZ0000ZZ, ở đây được báo cáo là đơn giản hóa, kiểm tra các tấm bảo vệ,
thực hiện thiết lập lại và khởi động bộ tính giờ để xác nhận các bất biến theo
đặc điểm kỹ thuật, những đặc điểm đó không thể dễ dàng được biểu diễn trong cấu trúc ô tô.
Do tính chất phức tạp của các biến môi trường, người dùng cần cung cấp
các hàm lấy và đặt lại các biến môi trường không phải là đồng hồ thông thường
(ví dụ: đồng hồ có độ chi tiết ns hoặc jiffy).
Vì các bất biến chỉ được xác định là hết hạn đồng hồ (ví dụ *clk <
ngưỡng*), đạt đến mức hết hạn của bộ hẹn giờ được trang bị khi vào trạng thái
trên thực tế là một thất bại trong mô hình và gây ra phản ứng. Rời khỏi tiểu bang
dừng bộ đếm thời gian.

Điều quan trọng cần lưu ý là bộ tính giờ được triển khai bằng bộ tính giờ giới thiệu
trên không, nếu màn hình có một số phiên bản (ví dụ: tất cả các tác vụ) thì điều này có thể trở thành
một vấn đề. Có thể giảm tác động bằng cách sử dụng bánh xe hẹn giờ (ZZ0000ZZ
được đặt thành ZZ0001ZZ), điều này làm giảm khả năng phản hồi của bộ hẹn giờ mà không
làm hỏng tính chính xác của mô hình, vì điều kiện bất biến được kiểm tra
trước khi tắt bộ hẹn giờ trong trường hợp cuộc gọi lại bị trễ.
Ngoài ra, nếu màn hình được đảm bảo ZZ0002ZZ hãy rời khỏi trạng thái và
sự chậm trễ phát sinh để chờ sự kiện tiếp theo có thể chấp nhận được, có thể sử dụng bảo vệ
thay cho các bất biến, như đã thấy trong ví dụ gian hàng.

Định dạng Graphviz .dot
--------------------

Ngoài ra, biểu diễn Graphviz của automata lai là một phần mở rộng của
automata tất định một. Cụ thể, có thể cung cấp vệ sĩ trong sự kiện
tên được phân tách bằng ZZ0000ZZ::

"state_start" -> "state_dest" [ label = "sched_waking;preemptible==0;reset(clk)" ];

Bất biến có thể được chỉ định trong nhãn trạng thái (không phải tên nút!) được phân tách bằng ZZ0000ZZ::

"được xếp hàng" [nhãn = "được xếp hàng\nclk < ngưỡng_jiffies"];

Các ràng buộc có thể được chỉ định dưới dạng so sánh C hợp lệ và cho phép khoảng trắng, ràng buộc đầu tiên
yếu tố so sánh phải là đồng hồ trong khi giây là số hoặc
giá trị tham số hóa. Guards cho phép so sánh được kết hợp với boolean
(ZZ0000ZZ và ZZ0001ZZ), việc đặt lại phải được tách biệt khỏi các ràng buộc khác.

Đây là ví dụ đầy đủ về phiên bản cuối cùng của mô hình 'gian hàng' trong DOT::

trạng thái chữ ghép_automaton {
      {nút [hình = vòng tròn] "xếp hàng"};
      {nút [hình dạng = văn bản gốc, style=invis, nhãn = ""] "__init_dequeued"};
      {nút [hình dạng = vòng tròn kép] "xếp hàng"};
      {nút [hình = vòng tròn] "đang chạy"};
      "__init_dequeued" -> "dequeued";
      "được xếp hàng" [nhãn = "được xếp hàng\nclk < ngưỡng_jiffies"];
      "đang chạy" [nhãn = "đang chạy"];
      "dequeued" [nhãn = "dequeued"];
      "xếp hàng" -> "đang chạy" [ label = "switch_in" ];
      "đang chạy" -> "đã xếp hàng" [ label = "dequeue"];
      "xếp hàng" -> "xếp hàng" [ label = "enqueue;reset(clk)" ];
      { xếp hạng = phút ;
          "__init_dequeued";
          "xếp hàng";
      }
  }

Tài liệu tham khảo
----------

Một cuốn sách bao gồm việc kiểm tra mô hình và automata tính thời gian là::

Christel Baier và Joost-Pieter Katoen: Nguyên tắc kiểm tra mô hình,
  Nhà xuất bản MIT, 2008.

Máy tự động lai được mô tả chi tiết trong::

Thomas Henzinger: Lý thuyết về máy tự động lai,
  Kỷ yếu Hội nghị chuyên đề IEEE thường niên lần thứ 11 về Logic trong Khoa học Máy tính, 1996.
