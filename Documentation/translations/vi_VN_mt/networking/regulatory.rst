.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/networking/regulatory.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================
Tài liệu quy định không dây Linux
==========================================

Tài liệu này đưa ra một đánh giá ngắn gọn về cách mạng không dây Linux
công trình cơ sở hạ tầng pháp lý.

Thông tin cập nhật hơn có thể được lấy tại trang web của dự án:

ZZ0000ZZ

Giữ các miền quy định trong không gian người dùng
---------------------------------------

Do tính chất năng động của các lĩnh vực quản lý, chúng tôi giữ chúng
trong không gian người dùng và cung cấp khuôn khổ cho không gian người dùng tải lên
đối với hạt nhân một miền quy định sẽ được sử dụng làm trung tâm
miền quy định cốt lõi mà tất cả các thiết bị không dây phải tuân thủ.

Làm cách nào để có được các miền quy định cho kernel
-------------------------------------------

Khi miền quy định được thiết lập lần đầu tiên, kernel sẽ yêu cầu
tệp cơ sở dữ liệu (regulatory.db) chứa tất cả các quy tắc quy định. Nó
sau đó sẽ sử dụng cơ sở dữ liệu đó khi cần tra cứu các quy tắc cho một
đất nước nhất định.

Cách lấy miền quy định vào kernel (giải pháp CRDA cũ)
---------------------------------------------------------------

Không gian người dùng có được miền quy định trong kernel bằng cách có
một tác nhân không gian người dùng xây dựng nó và gửi nó qua nl80211. Chỉ
các miền quy định dự kiến sẽ được hạt nhân tôn trọng.

Một tác nhân không gian người dùng hiện có sẵn có thể thực hiện việc này
là CRDA - đại lý miền quản lý trung tâm. Tài liệu của nó ở đây:

ZZ0000ZZ

Về cơ bản kernel sẽ gửi một sự kiện udev khi nó biết
nó cần một miền quy định mới. Một quy tắc udev có thể được áp dụng
để kích hoạt crda gửi miền quy định tương ứng cho
cụ thể ISO/IEC 3166 alpha2.

Dưới đây là một ví dụ về quy tắc udev có thể được sử dụng:

Tệp # Example, nên được đặt trong /etc/udev/rules.d/regulatory.rules
KERNEL=="quy định*", ACTION=="thay đổi", SUBSYSTEM=="nền tảng", RUN+="/sbin/crda"

Alpha2 được truyền dưới dạng biến môi trường dưới biến COUNTRY.

Ai yêu cầu các miền quy định?
--------------------------------

* Người dùng

Người dùng có thể sử dụng iw:

ZZ0000ZZ

Một ví dụ::

Miền quy định # set tới "Costa Rica"
  tôi đã đặt CR

Điều này sẽ yêu cầu kernel đặt miền quy định thành
alpha2 được chỉ định. Sau đó kernel sẽ hỏi userspace
để cung cấp miền quy định cho alpha2 do người dùng chỉ định
bằng cách gửi một sự kiện.

* Hệ thống con không dây cho các yếu tố Thông tin Quốc gia

Hạt nhân sẽ gửi một sự kiện để thông báo cho người dùng một thông tin mới
miền quy định là bắt buộc. Thông tin thêm về điều này sẽ được thêm vào
khi sự tích hợp của nó được thêm vào.

* Trình điều khiển

Nếu trình điều khiển xác định họ cần một miền quy định cụ thể
được thiết lập, họ có thể thông báo cho lõi không dây bằng cách sử dụng quy định_hint().
Họ có hai lựa chọn -- hoặc họ cung cấp alpha2 để
crda có thể cung cấp lại miền quy định cho quốc gia đó hoặc
họ có thể xây dựng miền quy định của riêng mình dựa trên nội bộ
kiến thức tùy chỉnh để lõi không dây có thể tôn trọng nó.

Trình điều khiển ZZ0000ZZ sẽ dựa vào cơ chế đầu tiên cung cấp
gợi ý quy định với alpha2. Đối với những trình điều khiển này có một bổ sung
kiểm tra xem có thể được sử dụng để đảm bảo tuân thủ dựa trên EEPROM tùy chỉnh
dữ liệu quy định. Việc kiểm tra bổ sung này có thể được người lái xe sử dụng bằng cách
đăng ký trên cấu trúc của nó sẽ thực hiện cuộc gọi lại reg_notifier(). Trình thông báo này
được gọi khi miền quy định của lõi đã được thay đổi. Người lái xe
có thể sử dụng điều này để xem lại những thay đổi đã thực hiện và cũng có thể xem lại ai đã thực hiện chúng
(trình điều khiển, người dùng, IE quốc gia) và xác định những gì sẽ cho phép dựa trên
dữ liệu EEPROM nội bộ. Trình điều khiển thiết bị mong muốn có khả năng trên thế giới
chuyển vùng nên sử dụng lệnh gọi lại này. Sẽ có thêm thông tin về chuyển vùng thế giới
được thêm vào tài liệu này khi hỗ trợ của nó được kích hoạt.

Trình điều khiển thiết bị cung cấp miền quy định được xây dựng của riêng họ
không cần gọi lại vì các kênh được họ đăng ký đã
những thứ duy nhất được phép và do đó ZZ0000ZZ
không thể kích hoạt các kênh.

Mã ví dụ - trình điều khiển gợi ý alpha2:
------------------------------------------

Ví dụ này xuất phát từ trình điều khiển thiết bị zd1211rw. Bạn có thể bắt đầu
bằng cách có bản đồ quốc gia/quy định EEPROM trên thiết bị của bạn
giá trị miền cho một alpha2 cụ thể như sau::

cấu trúc tĩnh zd_reg_alpha2_map reg_alpha2_map[] = {
	{ ZD_REGDOMAIN_FCC, "US" },
	{ ZD_REGDOMAIN_IC, "CA" },
	{ ZD_REGDOMAIN_ETSI, "DE" }, /* ETSI chung, sử dụng hạn chế nhất */
	{ ZD_REGDOMAIN_JAPAN, "JP" },
	{ ZD_REGDOMAIN_JAPAN_ADD, "JP" },
	{ ZD_REGDOMAIN_SPAIN, "ES" },
	{ ZD_REGDOMAIN_FRANCE, "FR" },

Sau đó, bạn có thể xác định một quy trình để ánh xạ giá trị EEPROM đã đọc của mình thành alpha2,
như sau::

int tĩnh zd_reg2alpha2(u8 regdomain, char *alpha2)
  {
	unsigned int i;
	cấu trúc zd_reg_alpha2_map *reg_map;
		cho (i = 0; i < ARRAY_SIZE(reg_alpha2_map); i++) {
			reg_map = &reg_alpha2_map[i];
			if (regdomain == reg_map->reg) {
			alpha2[0] = reg_map->alpha2[0];
			alpha2[1] = reg_map->alpha2[1];
			trả về 0;
		}
	}
	trả về 1;
  }

Cuối cùng, bạn có thể gợi ý cốt lõi của alpha2 đã khám phá của mình, nếu khớp
đã được tìm thấy. Bạn cần thực hiện việc này sau khi đã đăng ký wiphy của mình. bạn
dự kiến ​​sẽ làm điều này trong quá trình khởi tạo.

::

r = zd_reg2alpha2(mac->regdomain, alpha2);
	nếu (!r)
		quy_hint(hw->wiphy, alpha2);

Mã ví dụ - trình điều khiển cung cấp miền quy định tích hợp:
--------------------------------------------------------------

[NOTE: API này hiện không có sẵn, có thể bổ sung khi cần]

Nếu bạn có thông tin quy định, bạn có thể lấy từ
trình điều khiển và bạn ZZ0000ZZ để sử dụng điều này, chúng tôi cho phép bạn xây dựng một miền quy định
cấu trúc và chuyển nó đến lõi không dây. Để làm điều này bạn nên
kmalloc() một cấu trúc đủ lớn để chứa miền quy định của bạn
cấu trúc và sau đó bạn nên điền dữ liệu của mình vào đó. Cuối cùng bạn chỉ đơn giản là
gọi quy định_hint() với cấu trúc miền quy định trong đó.

Dưới đây là một ví dụ đơn giản, với miền quy định được lưu vào bộ đệm bằng cách sử dụng ngăn xếp.
Việc triển khai của bạn có thể khác nhau (ví dụ: đọc bộ đệm EEPROM).

Bộ nhớ đệm mẫu của một số miền quy định::

struct ieee80211_regdomain mydriver_jp_regdom = {
	.n_reg_rules = 3,
	.alpha2 = "JP",
	//.alpha2 = "99", /* Nếu tôi không có alpha2 để ánh xạ nó tới */
	.reg_rules = {
		/* IEEE 802.11b/g, kênh 1..14 */
		REG_RULE(2412-10, 2484+10, 40, 6, 20, 0),
		/* IEEE 802.11a, kênh 34..48 */
		REG_RULE(5170-10, 5240+10, 40, 6, 20,
			NL80211_RRF_NO_IR),
		/* IEEE 802.11a, kênh 52..64 */
		REG_RULE(5260-10, 5320+10, 40, 6, 20,
			NL80211_RRF_NO_IR|
			NL80211_RRF_DFS),
	}
  };

Sau đó, trong một phần mã của bạn sau khi wiphy của bạn đã được đăng ký::

cấu trúc ieee80211_regdomain *rd;
	int size_of_regd;
	int num_rules = mydriver_jp_regdom.n_reg_rules;
	unsigned int i;

size_of_regd = sizeof(struct ieee80211_regdomain) +
		(num_rules * sizeof(struct ieee80211_reg_rule));

rd = kzalloc(size_of_regd, GFP_KERNEL);
	nếu (!rd)
		trả về -ENOMEM;

memcpy(rd, &mydriver_jp_regdom, sizeof(struct ieee80211_regdomain));

cho (i=0; i < num_rules; i++)
		memcpy(&rd->reg_rules[i],
		       &mydriver_jp_regdom.reg_rules[i],
		       sizeof(struct ieee80211_reg_rule));
	quy định_struct_hint(rd);

Cơ sở dữ liệu quy định được biên soạn tĩnh
---------------------------------------

Khi một cơ sở dữ liệu cần được cố định vào kernel, nó có thể được cung cấp dưới dạng
tập tin chương trình cơ sở tại thời điểm xây dựng, sau đó được liên kết vào kernel.