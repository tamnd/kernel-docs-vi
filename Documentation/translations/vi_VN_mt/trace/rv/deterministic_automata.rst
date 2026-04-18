.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/rv/deterministic_automata.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Máy tự động xác định
======================

Về mặt hình thức, một máy tự động xác định, ký hiệu là G, được định nghĩa là một bộ ngũ:

ZZ0002ZZ = { ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ, x\ ZZ0000ZZ, X\ ZZ0001ZZ }

Ở đâu:

- ZZ0002ZZ là tập hợp các trạng thái;
- ZZ0003ZZ là tập hữu hạn các sự kiện;
- x\ ZZ0000ZZ là trạng thái ban đầu;
- X\ ZZ0001ZZ (tập con của ZZ0004ZZ) là tập hợp các trạng thái được đánh dấu (hoặc cuối cùng).
- ZZ0005ZZ : ZZ0006ZZ x ZZ0007ZZ -> ZZ0008ZZ là hàm chuyển tiếp. Nó xác định trạng thái
  chuyển tiếp khi xảy ra sự kiện từ ZZ0009ZZ ở trạng thái ZZ0010ZZ. trong
  trường hợp đặc biệt của automata xác định, sự xuất hiện của sự kiện trong ZZ0011ZZ
  ở trạng thái trong ZZ0012ZZ có trạng thái tiếp theo xác định từ ZZ0013ZZ.

Ví dụ: một máy tự động nhất định có tên 'wip' (đánh thức trước) có thể
được định nghĩa là:

- ZZ0018ZZ = { ZZ0002ZZ, ZZ0003ZZ}
- ZZ0019ZZ = {ZZ0004ZZ, ZZ0005ZZ, ZZ0006ZZ}
- x\ ZZ0000ZZ = ZZ0007ZZ
- X\ ZZ0001ZZ = {ZZ0008ZZ}
- ZZ0020ZZ =
   - ZZ0021ZZ\ (ZZ0009ZZ, ZZ0010ZZ) = ZZ0011ZZ
   - ZZ0022ZZ\ (ZZ0012ZZ, ZZ0013ZZ) = ZZ0014ZZ
   - ZZ0023ZZ\ (ZZ0015ZZ, ZZ0016ZZ) = ZZ0017ZZ

Một trong những lợi ích của định nghĩa chính thức này là nó có thể được trình bày
ở nhiều định dạng. Ví dụ: sử dụng ZZ0000ZZ, sử dụng
các đỉnh (nút) và các cạnh, rất trực quan cho ZZ0001ZZ
người thực hành mà không bị mất mát gì.

Máy tự động 'wip' trước đó cũng có thể được biểu diễn dưới dạng ::

ưu tiên_enable
          +---------------------------------+
          v |
        #=============#  preempt_disable +-------------------+
    --> H ưu tiên H -->----------------> ZZ0000ZZ
        #=============# +-------------------+
                                            ^ |
                                            ZZ0001ZZ
                                            +--------------+

Máy tự động xác định trong C
----------------------------

Trong bài viết "Xác minh chính thức hiệu quả cho nhân Linux",
các tác giả trình bày một cách đơn giản để biểu diễn một máy tự động trong C có thể
được sử dụng như mã thông thường trong nhân Linux.

Ví dụ: máy tự động 'wip' có thể được trình bày dưới dạng (được tăng cường bằng các nhận xét)::

/* biểu diễn enum của X (tập hợp các trạng thái) được sử dụng làm chỉ mục */
  trạng thái enum {
	ưu tiên = 0,
	không có quyền ưu tiên,
	trạng thái_max
  };

Trạng thái #define INVALID_STATE_max

/* đại diện enum của E (tập hợp các sự kiện) được sử dụng làm chỉ mục */
  sự kiện enum {
	ưu tiên_disable = 0,
	preempt_enable,
	lịch_waking,
	sự kiện_max
  };

cấu trúc tự động hóa {
	char *state_names[state_max];                   // X: tập hợp các trạng thái
	char *event_names[event_max];                   // E: tập hữu hạn các sự kiện
	hàm char không dấu[state_max][event_max];   // f: hàm chuyển tiếp
	char không dấu init_state;                    // x_0: trạng thái ban đầu
	bool Final_states[state_max];                   // X_m: tập hợp các trạng thái được đánh dấu
  };

cấu trúc máy tự động aut = {
	.state_names = {
		"ưu tiên",
		"không_preemptive"
	},
	.event_names = {
		"preempt_disable",
		"preempt_enable",
		"lịch_thức"
	},
	.function = {
		{ không được ưu tiên, INVALID_STATE, INVALID_STATE },
		{ INVALID_STATE, ưu tiên, không ưu tiên },
	},
	.initial_state = quyền ưu tiên,
	.final_states = { 1, 0 },
  };

ZZ0000ZZ được biểu diễn dưới dạng ma trận các trạng thái (đường) và
sự kiện (cột) và do đó hàm ZZ0001ZZ : ZZ0002ZZ x ZZ0003ZZ -> ZZ0004ZZ có thể được giải quyết
trong O(1). Ví dụ::

next_state = automaton_wip.function[curr_state][event];

Định dạng Graphviz .dot
-----------------------

Công cụ nguồn mở Graphviz có thể tạo ra biểu diễn đồ họa
của một máy tự động sử dụng ngôn ngữ DOT (văn bản) làm mã nguồn.
Định dạng DOT được sử dụng rộng rãi và có thể chuyển đổi sang nhiều định dạng khác.

Ví dụ: đây là mô hình 'wip' trong DOT::

trạng thái chữ ghép_automaton {
        {nút [hình = vòng tròn] "non_preemptive"};
        {nút [hình dạng = văn bản gốc, style=invis, nhãn = ""] "__init_preemptive"};
        {nút [hình dạng = vòng tròn kép] "ưu tiên"};
        {nút [hình = vòng tròn] "ưu tiên"};
        "__init_preemptive" -> "ưu tiên";
        "non_preemptive" [nhãn = "non_preemptive"];
        "non_preemptive" -> "non_preemptive" [ label = "sched_waking" ];
        "non_preemptive" -> "preemptive" [ nhãn = "preempt_enable" ];
        "ưu tiên" [nhãn = "ưu tiên"];
        "preemptive" -> "non_preemptive" [ nhãn = "preempt_disable" ];
        { xếp hạng = phút ;
                "__init_preemptive";
                "ưu tiên";
        }
  }

Định dạng DOT này có thể được chuyển đổi thành hình ảnh bitmap hoặc vector
bằng cách sử dụng tiện ích dấu chấm hoặc vào tác phẩm nghệ thuật ASCII bằng cách sử dụng biểu đồ dễ dàng. cho
ví dụ::

$ dot -Tsvg -o wip.svg wip.dot
  $ đồ thị dễ dàng wip.dot > wip.txt

dot2c
-----

dot2c là một tiện ích có thể phân tích tệp .dot chứa máy tự động dưới dạng
trong ví dụ trên và tự động chuyển nó sang biểu diễn C
trình bày trong [3].

Ví dụ: đưa mô hình 'wip' trước đó vào một tệp có tên 'wip.dot',
lệnh sau sẽ chuyển đổi tệp .dot thành C
đại diện (được hiển thị trước đó) trong tệp 'wip.h'::

$ dot2c wip.dot > wip.h

Nội dung 'wip.h' là mẫu mã trong phần 'Máy tự động xác định
ở C'.

Bình luận
---------

Chủ nghĩa hình thức automata cho phép mô hình hóa các hệ thống sự kiện rời rạc (DES) trong
nhiều định dạng, phù hợp với các ứng dụng/người dùng khác nhau.

Ví dụ, mô tả hình thức sử dụng lý thuyết tập hợp sẽ phù hợp hơn
cho các hoạt động tự động, trong khi định dạng đồ họa để con người giải thích;
và ngôn ngữ máy tính để thực thi máy.

Tài liệu tham khảo
------------------

Nhiều sách giáo khoa đề cập đến chủ nghĩa hình thức automata. Để biết phần giới thiệu ngắn gọn, hãy xem::

O'Regan, Gerard. Hướng dẫn ngắn gọn về công nghệ phần mềm. mùa xuân,
  Chăm, 2017.

Để biết mô tả chi tiết, bao gồm các hoạt động và ứng dụng trên rời rạc
Hệ thống sự kiện (DES), xem::

Cassandras, Christos G., và Stephane Lafortune, biên tập. Giới thiệu về rời rạc
  hệ thống sự kiện. Boston, MA: Springer Mỹ, 2008.

Để biết cách biểu diễn C trong kernel, hãy xem ::

De Oliveira, Daniel Bristot; Cucinotta, Tommaso; De Oliveira, Romulo
  Silva. Xác minh chính thức hiệu quả cho nhân Linux. Trong:
  Hội nghị quốc tế về Kỹ thuật phần mềm và các phương pháp chính thức.
  Springer, Chăm, 2019. tr. 315-332.
