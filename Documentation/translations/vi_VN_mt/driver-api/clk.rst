.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/clk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Khung Clk chung
========================

:Tác giả: Mike Turquette <mturquette@ti.com>

Tài liệu này cố gắng giải thích chi tiết về khung công tác CLK phổ biến,
và cách chuyển một nền tảng sang khung này.  Nó vẫn chưa phải là một
giải thích chi tiết về api đồng hồ trong include/linux/clk.h, nhưng
có lẽ một ngày nào đó nó sẽ bao gồm thông tin đó.

Giới thiệu và chia giao diện
================================

Khung clk chung là một giao diện để điều khiển các nút đồng hồ
hiện có trên nhiều thiết bị khác nhau.  Điều này có thể ở dạng đồng hồ
gating, điều chỉnh tỷ lệ, trộn hoặc các hoạt động khác.  Khuôn khổ này là
được bật với tùy chọn CONFIG_COMMON_CLK.

Bản thân giao diện được chia thành hai nửa, mỗi nửa được bảo vệ khỏi
chi tiết của đối tác của nó.  Đầu tiên là định nghĩa chung về struct
clk hợp nhất kế toán và cơ sở hạ tầng ở cấp độ khung
theo truyền thống đã được sao chép trên nhiều nền tảng khác nhau.  Thứ hai
là cách triển khai phổ biến của api clk.h, được định nghĩa trong
trình điều khiển/clk/clk.c.  Cuối cùng là struct clk_ops, hoạt động của nó
được gọi bằng cách triển khai clk api.

Nửa sau của giao diện bao gồm giao diện dành riêng cho phần cứng
cuộc gọi lại được đăng ký với struct clk_ops và tương ứng
cấu trúc dành riêng cho phần cứng cần thiết để mô hình hóa một đồng hồ cụ thể.  cho
phần còn lại của tài liệu này bất kỳ tham chiếu nào đến lệnh gọi lại trong struct
clk_ops, chẳng hạn như .enable hoặc .set_rate, ngụ ý phần cứng cụ thể
việc thực hiện mã đó.  Tương tự như vậy, các tham chiếu đến struct clk_foo
phục vụ như một cách viết tắt thuận tiện cho việc thực hiện các
các bit dành riêng cho phần cứng cho phần cứng "foo" giả định.

Gắn kết hai nửa của giao diện này lại với nhau là struct clk_hw,
được định nghĩa trong struct clk_foo và được trỏ đến trong struct clk_core.  Cái này
cho phép điều hướng dễ dàng giữa hai nửa riêng biệt của điểm chung
giao diện đồng hồ

Cấu trúc dữ liệu phổ biến và api
==============================

Dưới đây là định nghĩa struct clk_core phổ biến từ
trình điều khiển/clk/clk.c, được sửa đổi cho ngắn gọn::

cấu trúc clk_core {
		const char *tên;
		const struct clk_ops *ops;
		cấu trúc clk_hw *hw;
		mô-đun cấu trúc * chủ sở hữu;
		struct clk_core *parent;
		const char **parent_names;
		struct clk_core **cha mẹ;
		u8 num_parents;
		u8 new_parent_index;
		...
	};

Các thành viên trên tạo nên cốt lõi của cấu trúc liên kết cây clk.  tiếng kêu
Bản thân api xác định một số hàm hướng tới trình điều khiển hoạt động trên
struct clk.  API đó được ghi lại trong include/linux/clk.h.

Nền tảng và thiết bị sử dụng cấu trúc chung clk_core sử dụng cấu trúc
con trỏ clk_ops trong struct clk_core để thực hiện các phần dành riêng cho phần cứng của
các hoạt động được xác định trong clk-provider.h::

cấu trúc clk_ops {
		int (*prepare)(struct clk_hw *hw);
		khoảng trống (*unprepare)(struct clk_hw *hw);
		int (*is_prepared)(struct clk_hw *hw);
		khoảng trống (*unprepare_unused)(struct clk_hw *hw);
		int (*enable)(struct clk_hw *hw);
		khoảng trống (*disable)(struct clk_hw *hw);
		int (*is_enabled)(struct clk_hw *hw);
		khoảng trống (*disable_unused)(struct clk_hw *hw);
		dài không dấu (*recalc_rate)(struct clk_hw *hw,
						parent_rate dài không dấu);
		dài (*round_rate)(struct clk_hw *hw,
						tỷ lệ dài không dấu,
						dài không dấu *parent_rate);
		int (*determine_rate)(struct clk_hw *hw,
						  cấu trúc clk_rate_request *req);
		int (chỉ số ZZ0011Zhw, u8);
		u8 (*get_parent)(struct clk_hw *hw);
		int (*set_rate)(struct clk_hw *hw,
					    tỷ lệ dài không dấu,
					    parent_rate dài không dấu);
		int (*set_rate_and_parent)(struct clk_hw *hw,
					    tỷ lệ dài không dấu,
					    parent_rate dài không dấu,
					    chỉ số u8);
		dài không dấu (*recalc_accuracy)(struct clk_hw *hw,
						parent_accuracy dài không dấu);
		int (*get_phase)(struct clk_hw *hw);
		int (*set_phase)(struct clk_hw *hw, int độ);
		khoảng trống (*init)(struct clk_hw *hw);
		khoảng trống (*debug_init)(struct clk_hw *hw,
					      cấu trúc nha khoa *nha khoa);
	};

Triển khai clk phần cứng
============================

Sức mạnh của cấu trúc clk_core chung đến từ các con trỏ .ops và .hw của nó
trừu tượng hóa các chi tiết của struct clk từ các bit dành riêng cho phần cứng và
ngược lại.  Để minh họa, hãy xem xét việc triển khai clk có thể cổng đơn giản trong
trình điều khiển/clk/clk-gate.c::

cấu trúc clk_gate {
		struct clk_hw hw;
		void __iomem *reg;
		u8 bit_idx;
		...
	};

struct clk_gate chứa struct clk_hw hw cũng như dành riêng cho phần cứng
kiến thức về thanh ghi và bit nào điều khiển cổng của clk này.
Không có gì về cấu trúc liên kết đồng hồ hoặc kế toán, chẳng hạn như Enable_count hoặc
notifier_count, là cần thiết ở đây.  Mọi việc đều do chung giải quyết
mã khung và struct clk_core.

Hãy cùng hướng dẫn cách bật clk này từ mã trình điều khiển::

struct clk *clk;
	clk = clk_get(NULL, "my_gateable_clk");

clk_prepare(clk);
	clk_enable(clk);

Biểu đồ cuộc gọi cho clk_enable rất đơn giản ::

clk_enable(clk);
		clk->ops->enable(clk->hw);
		[quyết tâm...]
			clk_gate_enable(hw);
			[giải quyết cổng struct clk bằng to_clk_gate(hw)]
				clk_gate_set_bit(cổng);

Và định nghĩa của clk_gate_set_bit::

khoảng trống tĩnh clk_gate_set_bit(struct clk_gate *gate)
	{
		đăng ký u32;

reg = __raw_readl(gate->reg);
		reg |= BIT(gate->bit_idx);
		writel(reg, cổng->reg);
	}

Lưu ý rằng to_clk_gate được định nghĩa là::

#define to_clk_gate(_hw) container_of(_hw, struct clk_gate, hw)

Mẫu trừu tượng này được sử dụng cho mọi phần cứng đồng hồ
đại diện.

Hỗ trợ phần cứng clk của riêng bạn
================================

Khi triển khai hỗ trợ cho một loại đồng hồ mới, chỉ cần
bao gồm tiêu đề sau::

#include <linux/clk-provider.h>

Để xây dựng cấu trúc phần cứng clk cho nền tảng của bạn, bạn phải xác định
sau đây::

cấu trúc clk_foo {
		struct clk_hw hw;
		... hardware specific data goes here ...
	};

Để tận dụng dữ liệu của mình, bạn cần hỗ trợ các hoạt động hợp lệ
cho clk của bạn::

cấu trúc clk_ops clk_foo_ops = {
		.enable = &clk_foo_enable,
		.disable = &clk_foo_disable,
	};

Triển khai các hàm trên bằng container_of::

#define to_clk_foo(_hw) container_of(_hw, struct clk_foo, hw)

int clk_foo_enable(struct clk_hw *hw)
	{
		struct clk_foo *foo;

foo = to_clk_foo(hw);

		... perform magic on foo ...

trả về 0;
	};

Dưới đây là ma trận nêu chi tiết clk_ops nào là bắt buộc dựa trên
khả năng phần cứng của đồng hồ đó.  Một ô được đánh dấu là "y" có nghĩa là
bắt buộc, một ô được đánh dấu là "n" ngụ ý rằng việc bao gồm ô đó
gọi lại không hợp lệ hoặc không cần thiết.  Các ô trống là
tùy chọn hoặc phải được đánh giá theo từng trường hợp cụ thể.

.. table:: clock hardware characteristics

   +----------------+------+-------------+---------------+-------------+------+
   |                | gate | change rate | single parent | multiplexer | root |
   +================+======+=============+===============+=============+======+
   |.prepare        |      |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.unprepare      |      |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   +----------------+------+-------------+---------------+-------------+------+
   |.enable         | y    |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.disable        | y    |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.is_enabled     | y    |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   +----------------+------+-------------+---------------+-------------+------+
   |.recalc_rate    |      | y           |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.round_rate     |      | y [1]_      |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.determine_rate |      | y [1]_      |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   |.set_rate       |      | y           |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   +----------------+------+-------------+---------------+-------------+------+
   |.set_parent     |      |             | n             | y           | n    |
   +----------------+------+-------------+---------------+-------------+------+
   |.get_parent     |      |             | n             | y           | n    |
   +----------------+------+-------------+---------------+-------------+------+
   +----------------+------+-------------+---------------+-------------+------+
   |.recalc_accuracy|      |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+
   +----------------+------+-------------+---------------+-------------+------+
   |.init           |      |             |               |             |      |
   +----------------+------+-------------+---------------+-------------+------+

.. [1] either one of round_rate or determine_rate is required.

Cuối cùng, hãy đăng ký đồng hồ của bạn vào thời gian chạy bằng một phần cứng cụ thể.
chức năng đăng ký.  Hàm này chỉ đơn giản là điền vào struct clk_foo's
data và sau đó chuyển các tham số struct clk chung vào framework
với một cuộc gọi tới::

clk_register(...)

Xem các loại đồng hồ cơ bản trong ZZ0000ZZ để biết ví dụ.

Vô hiệu hóa tính năng kiểm soát đồng hồ của các đồng hồ không sử dụng
=======================================

Đôi khi trong quá trình phát triển, việc có thể bỏ qua
mặc định vô hiệu hóa các đồng hồ không sử dụng. Ví dụ: nếu trình điều khiển không kích hoạt
đồng hồ đúng cách nhưng dựa vào việc chúng được bật từ bộ nạp khởi động, bỏ qua
việc vô hiệu hóa có nghĩa là trình điều khiển sẽ vẫn hoạt động trong khi các vấn đề
được sắp xếp ra.

Bạn có thể xem đồng hồ nào đã bị tắt bằng cách khởi động kernel của bạn bằng những đồng hồ này
thông số::

tp_printk trace_event=clk:clk_disable

Để bỏ qua việc vô hiệu hóa này, hãy thêm "clk_ignore_unused" vào bootargs cho
hạt nhân.

Khóa
=======

Khung đồng hồ chung sử dụng hai khóa toàn cục, khóa chuẩn bị và khóa
kích hoạt khóa.

Khóa kích hoạt là một khóa xoay và được giữ trong các cuộc gọi đến .enable,
.disable hoạt động. Do đó, những hoạt động đó không được phép ngủ,
và các cuộc gọi đến các hàm clk_enable(), clk_disable() API được phép trong
bối cảnh nguyên tử.

Đối với clk_is_enabled() API, nó cũng được thiết kế để được phép sử dụng trong
bối cảnh nguyên tử. Tuy nhiên, việc giữ kích hoạt không thực sự có ý nghĩa gì
khóa trong lõi, trừ khi bạn muốn làm gì khác với thông tin của
trạng thái kích hoạt với khóa đó được giữ. Mặt khác, xem liệu clk có được bật hay không
đọc một lần trạng thái được kích hoạt, trạng thái này có thể dễ dàng thay đổi sau
chức năng trả về vì khóa được giải phóng. Vì vậy, người sử dụng API này
cần xử lý việc đồng bộ hóa việc đọc trạng thái với bất kỳ thứ gì chúng
sử dụng nó để đảm bảo rằng trạng thái kích hoạt không thay đổi trong thời gian đó
thời gian.

Khóa chuẩn bị là một mutex và được giữ trong các cuộc gọi đến tất cả các hoạt động khác.
Tất cả các hoạt động đó được phép ở chế độ ngủ và gọi đến API tương ứng
chức năng không được phép trong bối cảnh nguyên tử.

Điều này phân chia hoạt động thành hai nhóm một cách hiệu quả từ góc độ khóa.

Trình điều khiển không cần bảo vệ tài nguyên được chia sẻ giữa các hoạt động theo cách thủ công
của một nhóm, bất kể những tài nguyên đó có được nhiều người chia sẻ hay không
đồng hồ hay không. Tuy nhiên, quyền truy cập vào các tài nguyên được chia sẻ giữa các hoạt động
của hai nhóm cần được các tài xế bảo vệ. Một ví dụ như vậy
tài nguyên sẽ là một thanh ghi kiểm soát cả tốc độ xung nhịp và xung nhịp
trạng thái bật/tắt.

Khung đồng hồ được đăng nhập lại, trong đó trình điều khiển được phép gọi đồng hồ
các chức năng khung từ bên trong việc thực hiện các hoạt động đồng hồ của nó. Cái này
ví dụ có thể gây ra hoạt động .set_rate của một đồng hồ được gọi từ
trong hoạt động .set_rate của đồng hồ khác. Trường hợp này phải được xem xét
trong quá trình triển khai trình điều khiển, nhưng luồng mã thường được kiểm soát bởi
người lái xe trong trường hợp đó.

Lưu ý rằng việc khóa cũng phải được xem xét khi mã nằm ngoài phạm vi chung
khung đồng hồ cần truy cập các tài nguyên được sử dụng bởi các hoạt động đồng hồ. Cái này
được coi là nằm ngoài phạm vi của tài liệu này.
