.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/hwmon/kbatt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển hạt nhân kbatt
===================

Chip được hỗ trợ:

* Bộ điều khiển giám sát pin KEBA (lõi IP trong FPGA)

Tiền tố: 'kbatt'

tác giả:

Gerhard Engleder <eg@keba.com>
	Petar Bojanic <boja@keba.com>

Sự miêu tả
-----------

Bộ điều khiển giám sát pin KEBA là lõi IP cho FPGA,
theo dõi tình trạng của pin đồng xu. Pin đồng xu là
thường được sử dụng để cung cấp cho RTC trong khi tắt nguồn để duy trì dòng điện
thời gian. Ví dụ: CP500 FPGA bao gồm lõi IP này để giám sát ô tiền xu
pin của PLC và trình điều khiển cp500 tương ứng tạo thành một thiết bị phụ trợ
thiết bị cho trình điều khiển kbatt.

Trình điều khiển này cung cấp thông tin về tình trạng pin đồng xu cho
không gian người dùng. Trên thực tế, không gian người dùng sẽ được thông báo rằng ô chứa tiền xu
pin gần hết và cần được thay thế.

Pin dạng đồng xu phải được tích cực kiểm tra để biết liệu nó có gần như
trống rỗng hay không. Do đó, một tải được đặt vào pin dạng đồng xu và
điện áp kết quả được đánh giá. Việc đánh giá này được thực hiện bởi một số máy có dây cứng.
logic tương tự, so sánh điện áp với một giới hạn xác định. Nếu
điện áp vượt quá giới hạn thì pin dạng đồng xu được coi là
được. Nếu điện áp dưới mức giới hạn thì pin dạng đồng xu đang hoạt động.
gần như trống rỗng (hoặc bị hỏng, bị loại bỏ,...) và sẽ được thay thế bằng cái mới.
Bộ điều khiển giám sát pin KEBA cho phép bắt đầu kiểm tra
pin dạng đồng xu và để nhận kết quả nếu điện áp cao hơn hoặc thấp hơn
giới hạn. Điện áp thực tế không có sẵn. Chỉ có thông tin nếu
điện áp dưới mức giới hạn có sẵn.

Tải thử nghiệm được đặt vào pin dạng đồng xu để kiểm tra tình trạng,
tương tự như tải khi tắt nguồn. Vì vậy, tuổi thọ của
pin dạng đồng xu bị giảm trực tiếp theo thời gian của mỗi lần kiểm tra. Đến
hạn chế tác động tiêu cực đến thời gian tồn tại mà thử nghiệm được giới hạn ở mức tối đa
cứ 10 giây một lần. Tải thử nghiệm được đặt vào pin dạng đồng xu trong
100 mili giây. Vì vậy, trong trường hợp xấu nhất, tuổi thọ của pin đồng xu sẽ giảm đi
1% thời gian hoạt động hoặc 3,65 ngày mỗi năm. Khi pin đồng xu kéo dài
nhiều năm, mức giảm suốt đời này không đáng kể.

Trình điều khiển này chỉ cung cấp một thuộc tính cảnh báo duy nhất, thuộc tính này được nâng lên khi
pin đồng xu gần hết.

======================= ==== ========================================================
Nội dung R/W thuộc tính
======================= ==== ========================================================
in0_min_alarm R Điện áp của pin dạng đồng xu đang tải thấp hơn
                            giới hạn
======================= ==== ========================================================