.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/livepatch/shadow-vars.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Biến bóng
================

Biến bóng là một cách đơn giản để các mô-đun livepatch liên kết
dữ liệu "bóng" bổ sung với cấu trúc dữ liệu hiện có.  Dữ liệu bóng là
được phân bổ riêng biệt khỏi cấu trúc dữ liệu gốc, còn lại
không sửa đổi.  Biến bóng API được mô tả trong tài liệu này được sử dụng
để phân bổ/thêm và xóa/giải phóng các biến bóng đến/từ cha mẹ của chúng.

Việc triển khai giới thiệu một bảng băm toàn cầu, trong kernel
liên kết các con trỏ với các đối tượng cha và một mã định danh bằng số của
dữ liệu bóng tối.  Mã định danh số là một bảng liệt kê đơn giản có thể
được sử dụng để mô tả phiên bản, lớp hoặc loại biến bóng, v.v. Thêm
cụ thể, con trỏ cha đóng vai trò là khóa có thể băm trong khi
id số sau đó lọc các truy vấn có thể băm.  Nhiều bóng
các biến có thể gắn vào cùng một đối tượng cha, nhưng số của chúng
định danh phân biệt giữa chúng.


1. Tóm tắt ngắn gọn về API
====================

(Xem ghi chú tài liệu sử dụng API đầy đủ trong livepatch/shadow.c.)

Một bảng băm tham chiếu tất cả các biến bóng.  Những tài liệu tham khảo này là
được lưu trữ và truy xuất thông qua cặp <obj, id>.

* Cấu trúc dữ liệu biến klp_shadow gói gọn cả việc theo dõi
  siêu dữ liệu và dữ liệu bóng:

- siêu dữ liệu

- obj - con trỏ tới đối tượng cha
    - id - mã định danh dữ liệu

- data[] - lưu trữ dữ liệu bóng

Điều quan trọng cần lưu ý là klp_shadow_alloc() và
klp_shadow_get_or_alloc() đang đặt biến về 0 theo mặc định.
Chúng cũng cho phép gọi hàm tạo tùy chỉnh khi giá trị khác 0
giá trị là cần thiết. Người gọi nên cung cấp bất cứ điều gì loại trừ lẫn nhau
được yêu cầu.

Lưu ý rằng hàm tạo được gọi trong spinlock klp_shadow_lock. Nó cho phép
để thực hiện các hành động chỉ có thể được thực hiện một lần khi một biến mới được cấp phát.

* klp_shadow_get() - truy xuất con trỏ dữ liệu biến bóng
  - tìm kiếm hashtable cho cặp <obj, id>

* klp_shadow_alloc() - phân bổ và thêm biến bóng mới
  - tìm kiếm hashtable cho cặp <obj, id>

- nếu tồn tại

- WARN và trả lại NULL

- nếu <obj, id> chưa tồn tại

- phân bổ một biến bóng mới
    - khởi tạo biến bằng cách sử dụng hàm tạo và dữ liệu tùy chỉnh khi được cung cấp
    - thêm <obj, id> vào bảng băm toàn cầu

* klp_shadow_get_or_alloc() - lấy hiện có hoặc cấp phát một biến bóng mới
  - tìm kiếm hashtable cho cặp <obj, id>

- nếu tồn tại

- trả về biến bóng hiện có

- nếu <obj, id> chưa tồn tại

- phân bổ một biến bóng mới
    - khởi tạo biến bằng cách sử dụng hàm tạo và dữ liệu tùy chỉnh khi được cung cấp
    - thêm cặp <obj, id> vào bảng băm toàn cục

* klp_shadow_free() - tách và giải phóng biến bóng <obj, id>
  - tìm và xóa tham chiếu <obj, id> khỏi bảng băm toàn cục

- nếu tìm thấy

- gọi hàm hủy nếu được xác định
      - biến bóng tự do

* klp_shadow_free_all() - tách và giải phóng tất cả các biến bóng <_, id>
  - tìm và xóa mọi tham chiếu <_, id> khỏi bảng băm toàn cục

- nếu tìm thấy

- gọi hàm hủy nếu được xác định
      - biến bóng tự do


2. Các trường hợp sử dụng
============

(Xem ví dụ về mô-đun livepatch biến bóng trong mẫu/livepatch/
để xem các minh họa làm việc đầy đủ.)

Đối với các ví dụ về trường hợp sử dụng sau đây, hãy xem xét cam kết 1d147bfa6429
("mac80211: sửa lỗi AP powersave TX so với cuộc đua đánh thức"), đã thêm một
spinlock vào net/mac80211/sta_info.h :: struct sta_info.  Mỗi trường hợp sử dụng
ví dụ có thể được coi là một triển khai livepatch độc lập của điều này
sửa chữa.


Phù hợp với vòng đời của cha mẹ
---------------------------

Nếu cấu trúc dữ liệu gốc thường xuyên được tạo và hủy, nó có thể
dễ dàng nhất để căn chỉnh thời gian tồn tại của các biến bóng của chúng giống nhau
chức năng cấp phát và giải phóng.  Trong trường hợp này, dữ liệu gốc
cấu trúc thường được phân bổ, khởi tạo, sau đó được đăng ký trong một số
cách.  Việc phân bổ và thiết lập biến bóng sau đó có thể được xem xét
một phần trong quá trình khởi tạo của cha mẹ và phải được hoàn thành trước khi
cha mẹ "đi vào hoạt động" (nghĩa là mọi yêu cầu biến bóng get-API đều được thực hiện
cho cặp <obj, id> này.)

Đối với cam kết 1d147bfa6429, khi cấu trúc sta_info gốc được phân bổ,
phân bổ bản sao bóng của con trỏ ps_lock, sau đó khởi tạo nó::

#define PS_LOCK 1
  cấu trúc sta_info *sta_info_alloc(struct ieee80211_sub_if_data *sdata,
				  const u8 *addr, gfp_t gfp)
  {
	cấu trúc sta_info *sta;
	spinlock_t *ps_lock;

/*Cấu trúc cha được tạo ra */
	sta = kzalloc(sizeof(*sta) + hw->sta_data_size, gfp);

/* Đính kèm một biến bóng tương ứng, sau đó khởi tạo nó */
	ps_lock = klp_shadow_alloc(sta, PS_LOCK, sizeof(*ps_lock), gfp,
				   NULL, NULL);
	nếu (!ps_lock)
		đi tới Shadow_fail;
	spin_lock_init(ps_lock);
	...

Khi yêu cầu ps_lock, hãy truy vấn biến bóng API để lấy một
cho một cấu trúc cụ thể sta_info:::

void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
  {
	spinlock_t *ps_lock;

/* đồng bộ hóa với ieee80211_tx_h_unicast_ps_buf */
	ps_lock = klp_shadow_get(sta, PS_LOCK);
	nếu (ps_lock)
		spin_lock(ps_lock);
	...

Khi cấu trúc sta_info gốc được giải phóng, trước tiên hãy giải phóng bóng
biến::

void sta_info_free(struct ieee80211_local *local, struct sta_info *sta)
  {
	klp_shadow_free(sta, PS_LOCK, NULL);
	kfree(sta);
	...


Đối tượng gốc trong chuyến bay
------------------------

Đôi khi có thể không thuận tiện hoặc không thể phân bổ bóng
các biến bên cạnh các đối tượng cha của chúng.  Hoặc bản sửa lỗi livepatch có thể
chỉ yêu cầu các biến bóng cho một tập hợp con của các thể hiện đối tượng cha.
Trong những trường hợp này, lệnh gọi klp_shadow_get_or_alloc() có thể được sử dụng để đính kèm
các biến bóng đối với cha mẹ đã có trong chuyến bay.

Đối với cam kết 1d147bfa6429, vị trí tốt để phân bổ khóa xoay bóng là
bên trong ieee80211_sta_ps_deliver_wakeup()::

int ps_lock_shadow_ctor(void *obj, void *shadow_data, void *ctor_data)
  {
	spinlock_t *lock = Shadow_data;

spin_lock_init(khóa);
	trả về 0;
  }

#define PS_LOCK 1
  void ieee80211_sta_ps_deliver_wakeup(struct sta_info *sta)
  {
	spinlock_t *ps_lock;

/* đồng bộ hóa với ieee80211_tx_h_unicast_ps_buf */
	ps_lock = klp_shadow_get_or_alloc(sta, PS_LOCK,
			sizeof(*ps_lock), GFP_ATOMIC,
			ps_lock_shadow_ctor, NULL);

nếu (ps_lock)
		spin_lock(ps_lock);
	...

Việc sử dụng này sẽ tạo ra một biến bóng, chỉ khi cần thiết, nếu không nó sẽ
sẽ sử dụng cái đã được tạo cho cặp <obj, id> này.

Giống như trường hợp sử dụng trước, spinlock bóng cần được làm sạch.
Một biến bóng có thể được giải phóng ngay trước khi đối tượng cha của nó được giải phóng,
hoặc thậm chí khi biến bóng không còn cần thiết nữa.


Các trường hợp sử dụng khác
---------------

Biến bóng cũng có thể được sử dụng làm cờ cho biết rằng dữ liệu
cấu trúc đã được phân bổ bằng mã mới, được vá trực tiếp.  Trong trường hợp này, nó
không quan trọng giá trị dữ liệu mà biến bóng giữ là gì, sự tồn tại của nó
gợi ý cách xử lý đối tượng cha.


3. Tài liệu tham khảo
=============

* ZZ0000ZZ

Việc triển khai livepatch dựa trên phiên bản kpatch của bóng
  các biến.

* ZZ0000ZZ

Cập nhật năng động và thích ứng của các hệ thống con không hoạt động trong hàng hóa
  Nhân hệ điều hành (Kritis Makris, Kyung Dong Ryu 2007) đã trình bày
  một kỹ thuật cập nhật kiểu dữ liệu được gọi là "cấu trúc dữ liệu bóng".
