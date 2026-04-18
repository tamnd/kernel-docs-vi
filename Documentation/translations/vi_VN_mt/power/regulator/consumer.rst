.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/power/regulator/consumer.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Giao diện trình điều khiển người tiêu dùng điều chỉnh
=====================================================

Văn bản này mô tả giao diện điều chỉnh cho trình điều khiển thiết bị tiêu dùng.
Vui lòng xem tổng quan.txt để biết mô tả về các thuật ngữ được sử dụng trong văn bản này.


1. Quyền truy cập của cơ quan quản lý người tiêu dùng (trình điều khiển tĩnh và động)
=======================================================

Người lái xe tiêu dùng có thể truy cập vào bộ điều chỉnh nguồn cung của mình bằng cách gọi ::

bộ điều chỉnh = bộ điều chỉnh_get(dev, "Vcc");

Người tiêu dùng chuyển vào con trỏ thiết bị cấu trúc và ID nguồn điện. Cốt lõi
sau đó tìm bộ điều chỉnh chính xác bằng cách tham khảo bảng tra cứu cụ thể của máy.
Nếu tra cứu thành công thì lệnh gọi này sẽ trả về một con trỏ tới cấu trúc
cơ quan quản lý cung cấp cho người tiêu dùng này.

Để giải phóng bộ điều chỉnh, người lái xe tiêu dùng nên gọi ::

điều chỉnh_put(điều chỉnh);

Người tiêu dùng có thể được cung cấp bởi nhiều cơ quan quản lý, ví dụ: người tiêu dùng codec với
nguồn cung cấp analog và kỹ thuật số bằng các hoạt động số lượng lớn ::

struct điều chỉnh_số lượng lớn nguồn cung cấp dữ liệu [2];

nguồn cung cấp [0].supply = "Vcc"; /* lõi kỹ thuật số */
	nguồn cung cấp[1].supply = "Avdd"; /*tương tự*/

ret = điều chỉnh_bulk_get(dev, ARRAY_SIZE(vật tư), vật tư);

// trợ giúp thuận tiện để gọi bộ điều chỉnh_put() trên nhiều bộ điều chỉnh
	điều chỉnh_bulk_free(ARRAY_SIZE(vật tư), vật tư);


Các chức năng truy cập của bộ điều chỉnh điều chỉnh_get() và điều chỉnh_put() sẽ
thường được gọi lần lượt trong trình điều khiển thiết bị của bạn là thăm dò() và xóa().


2. Kích hoạt và vô hiệu hóa đầu ra bộ điều chỉnh (trình điều khiển tĩnh và động)
===============================================================


Người tiêu dùng có thể kích hoạt nguồn điện của mình bằng cách gọi::

int điều chỉnh_enable(bộ điều chỉnh);

NOTE:
  Nguồn cung cấp có thể đã được kích hoạt trước khi bộ điều chỉnh_enable() được gọi.
  Điều này có thể xảy ra nếu người tiêu dùng chia sẻ cơ quan quản lý hoặc cơ quan quản lý đã
  được kích hoạt trước đó bởi bộ nạp khởi động hoặc mã khởi tạo bảng hạt nhân.

Người tiêu dùng có thể xác định xem bộ điều chỉnh có được bật hay không bằng cách gọi::

int điều chỉnh_is_enabled(bộ điều chỉnh);

Giá trị này sẽ trả về > 0 khi bộ điều chỉnh được bật.

Một bộ bộ điều chỉnh có thể được kích hoạt chỉ bằng một thao tác hàng loạt ::

int điều chỉnh_bulk_enable(int num_consumers,
				  cấu trúc điều chỉnh_số lượng lớn_data *người tiêu dùng);


Người tiêu dùng có thể vô hiệu hóa nguồn cung cấp của mình khi không còn cần thiết bằng cách gọi::

int điều chỉnh_disable(bộ điều chỉnh);

Hoặc một số trong số đó ::

int điều chỉnh_bulk_disable(int num_consumers,
			 	   cấu trúc điều chỉnh_số lượng lớn_data *người tiêu dùng);

NOTE:
  Điều này có thể không vô hiệu hóa nguồn cung cấp nếu nó được chia sẻ với những người tiêu dùng khác. các
  bộ điều chỉnh sẽ chỉ bị tắt khi số tham chiếu được kích hoạt bằng 0.

Cuối cùng, bộ điều chỉnh có thể bị vô hiệu hóa mạnh mẽ trong trường hợp khẩn cấp::

int điều chỉnh_force_disable(bộ điều chỉnh);

Hoạt động này cũng được hỗ trợ cho nhiều cơ quan quản lý ::

int điều chỉnh_bulk_force_disable(int num_consumers,
			 		 cấu trúc điều chỉnh_số lượng lớn_data *người tiêu dùng);

NOTE:
  điều này sẽ tắt ngay lập tức và mạnh mẽ đầu ra của bộ điều chỉnh. Tất cả
  người tiêu dùng sẽ bị tắt nguồn.

3. Trạng thái và điều khiển điện áp của bộ điều chỉnh (trình điều khiển động)
=======================================================

Một số trình điều khiển tiêu dùng cần có khả năng thay đổi nguồn cung của họ một cách linh hoạt
điện áp để phù hợp với điểm vận hành hệ thống. ví dụ. Trình điều khiển CPUfreq có thể mở rộng quy mô
điện áp cùng với tần số để tiết kiệm điện, trình điều khiển SD có thể cần chọn
điện áp thẻ chính xác, v.v.

Người tiêu dùng có thể kiểm soát điện áp cung cấp của mình bằng cách gọi::

int điều chỉnh_set_điện áp (bộ điều chỉnh, min_uV, max_uV);

Trong đó min_uV và max_uV là điện áp tối thiểu và tối đa có thể chấp nhận được trong
microvolt.

NOTE: điều này có thể được gọi khi bộ điều chỉnh được bật hoặc tắt. Nếu được gọi
khi được bật thì điện áp sẽ thay đổi ngay lập tức, nếu không thì điện áp
cấu hình thay đổi và điện áp được đặt về mặt vật lý khi bộ điều chỉnh được
được kích hoạt tiếp theo.

Có thể tìm thấy đầu ra điện áp được cấu hình của bộ điều chỉnh bằng cách gọi ::

int điều chỉnh_get_điện áp (bộ điều chỉnh);

NOTE:
  get_volt() sẽ trả về điện áp đầu ra được định cấu hình cho dù
  bộ điều chỉnh được bật hoặc tắt và có nên sử dụng NOT để xác định bộ điều chỉnh
  trạng thái đầu ra. Tuy nhiên, điều này có thể được sử dụng cùng với is_enabled() để
  xác định điện áp đầu ra vật lý của bộ điều chỉnh.


4. Kiểm soát và trạng thái giới hạn hiện tại của bộ điều chỉnh (trình điều khiển động)
=============================================================

Một số trình điều khiển tiêu dùng cần có khả năng thay đổi nguồn cung của họ một cách linh hoạt
giới hạn hiện tại để phù hợp với điểm vận hành hệ thống. ví dụ. Trình điều khiển đèn nền LCD có thể
thay đổi giới hạn hiện tại để thay đổi độ sáng đèn nền, trình điều khiển USB có thể muốn
để đặt giới hạn ở mức 500mA khi cấp nguồn.

Người tiêu dùng có thể kiểm soát giới hạn nguồn cung hiện tại của mình bằng cách gọi::

int điều chỉnh_set_current_limit(bộ điều chỉnh, min_uA, max_uA);

Trong đó min_uA và max_uA là giới hạn hiện tại tối thiểu và tối đa có thể chấp nhận được trong
microamp.

NOTE:
  điều này có thể được gọi khi bộ điều chỉnh được bật hoặc tắt. Nếu được gọi
  khi được bật thì giới hạn hiện tại sẽ thay đổi ngay lập tức, nếu không thì giới hạn hiện tại sẽ
  giới hạn thay đổi cấu hình và giới hạn hiện tại được đặt về mặt vật lý khi
  bộ điều chỉnh được kích hoạt tiếp theo.

Có thể tìm thấy giới hạn hiện tại của cơ quan quản lý bằng cách gọi::

int điều chỉnh_get_current_limit(bộ điều chỉnh);

NOTE:
  get_current_limit() sẽ trả về giới hạn hiện tại cho dù bộ điều chỉnh
  được bật hoặc tắt và không được sử dụng để xác định dòng điện của bộ điều chỉnh
  tải.


5. Điều khiển và trạng thái chế độ vận hành của bộ điều chỉnh (trình điều khiển động)
==============================================================

Một số người tiêu dùng có thể tiết kiệm năng lượng hệ thống hơn nữa bằng cách thay đổi chế độ hoạt động của
cơ quan quản lý nguồn cung của họ sẽ hiệu quả hơn khi trạng thái hoạt động của người tiêu dùng
những thay đổi. ví dụ. trình điều khiển của người tiêu dùng không hoạt động và sau đó tiêu thụ ít dòng điện hơn

Chế độ vận hành của bộ điều chỉnh có thể được thay đổi gián tiếp hoặc trực tiếp.

Điều khiển chế độ vận hành gián tiếp.
--------------------------------
Người lái xe tiêu dùng có thể yêu cầu thay đổi chế độ vận hành bộ điều chỉnh nguồn cung cấp của họ
bằng cách gọi::

int điều chỉnh_set_load(bộ điều chỉnh cấu trúc *bộ điều chỉnh, int Load_uA);

Điều này sẽ khiến lõi tính toán lại tổng tải trên bộ điều chỉnh (dựa trên
trên tất cả người tiêu dùng) và thay đổi chế độ hoạt động (nếu cần thiết và được phép)
để phù hợp nhất với tải vận hành hiện tại.

Giá trị Load_uA có thể được xác định từ biểu dữ liệu của người tiêu dùng. ví dụ. nhất
bảng dữ liệu có các bảng hiển thị mức tiêu thụ tối đa trong một số trường hợp nhất định
tình huống.

Hầu hết người tiêu dùng sẽ sử dụng điều khiển chế độ vận hành gián tiếp vì họ không có
kiến thức về cơ quan quản lý hoặc liệu cơ quan quản lý có được chia sẻ với người khác hay không
người tiêu dùng.

Điều khiển chế độ vận hành trực tiếp.
------------------------------

Trình điều khiển riêng biệt hoặc được kết hợp chặt chẽ có thể muốn điều khiển trực tiếp bộ điều chỉnh
chế độ hoạt động tùy thuộc vào điểm hoạt động của chúng. Điều này có thể đạt được bằng cách
đang gọi::

int điều chỉnh_set_mode(bộ điều chỉnh cấu trúc *bộ điều chỉnh, chế độ int không dấu);
	unsigned int điều chỉnh_get_mode(bộ điều chỉnh cấu trúc *bộ điều chỉnh);

Chế độ trực tiếp sẽ chỉ được sử dụng bởi người tiêu dùng ZZ0000ZZ về bộ điều chỉnh và
không chia sẻ bộ điều chỉnh với những người tiêu dùng khác.


6. Sự kiện điều chỉnh
===================

Cơ quan quản lý có thể thông báo cho người tiêu dùng về các sự kiện bên ngoài. Sự kiện có thể được nhận bởi
người tiêu dùng trong điều kiện căng thẳng hoặc thất bại của cơ quan quản lý.

Người tiêu dùng có thể đăng ký quan tâm đến các sự kiện của cơ quan quản lý bằng cách gọi::

int điều chỉnh_register_notifier(bộ điều chỉnh cấu trúc *bộ điều chỉnh,
					struct notifier_block *nb);

Người tiêu dùng có thể hủy đăng ký quan tâm bằng cách gọi::

int điều chỉnh_unregister_notifier(bộ điều chỉnh cấu trúc *bộ điều chỉnh,
					  struct notifier_block *nb);

Cơ quan quản lý sử dụng khung trình thông báo hạt nhân để gửi sự kiện đến những người họ quan tâm
người tiêu dùng.

7. Truy cập đăng ký trực tiếp của cơ quan quản lý
===================================

Một số loại phần cứng hoặc chương trình cơ sở quản lý nguồn được thiết kế sao cho
họ cần thực hiện quyền truy cập phần cứng cấp thấp vào cơ quan quản lý mà không cần tham gia
từ hạt nhân. Ví dụ về các thiết bị như vậy là:

- nguồn xung nhịp với bộ dao động điều khiển điện áp và logic điều khiển để thay đổi
  điện áp cung cấp trên I2C để đạt được tốc độ xung nhịp đầu ra mong muốn
- phần mềm quản lý nhiệt có thể phát hành giao dịch I2C tùy ý tới
  thực hiện tắt nguồn hệ thống trong điều kiện nhiệt độ quá cao

Để thiết lập một thiết bị/chương trình cơ sở như vậy, các tham số khác nhau như địa chỉ I2C của
bộ điều chỉnh, địa chỉ của các thanh ghi bộ điều chỉnh khác nhau, v.v. cần được cấu hình
đến nó. Khung điều chỉnh cung cấp các trợ giúp sau để truy vấn
những chi tiết này.

Các chi tiết dành riêng cho xe buýt, như địa chỉ I2C hoặc tốc độ truyền tải được xử lý bởi
khung regmap. Để có được sơ đồ quy định của cơ quan quản lý (nếu được hỗ trợ), hãy sử dụng::

struct regmap *regulator_get_regmap(struct regulator *regulator);

Để có được phần bù thanh ghi phần cứng và mặt nạ bit cho điện áp của bộ điều chỉnh
đăng ký bộ chọn, sử dụng::

int điều chỉnh_get_hardware_vsel_register(bộ điều chỉnh cấu trúc *bộ điều chỉnh,
						 chưa ký *vsel_reg,
						 không dấu *vsel_mask);

Để chuyển đổi mã chọn điện áp của khung điều chỉnh (được sử dụng bởi
điều chỉnh_list_điện áp) sang bộ chọn điện áp dành riêng cho phần cứng có thể
được ghi trực tiếp vào thanh ghi chọn điện áp, sử dụng::

int điều chỉnh_list_hardware_vsel(bộ điều chỉnh cấu trúc *bộ điều chỉnh,
					 bộ chọn không dấu);

Để truy cập phần cứng để bật/tắt bộ điều chỉnh, người tiêu dùng phải
sử dụng điều chỉnh_get_exclusive(), vì nó không thể hoạt động nếu có nhiều hơn một
người tiêu dùng. Để bật/tắt bộ điều chỉnh, hãy sử dụng::

int điều chỉnh_hardware_enable(bộ điều chỉnh cấu trúc *bộ điều chỉnh, kích hoạt bool);
