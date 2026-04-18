.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/channel-mapping-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
ALSA PCM ánh xạ kênh API
===============================

Takashi Iwai <tiwai@suse.de>

Tổng quan
=========

Ánh xạ kênh API cho phép người dùng truy vấn các bản đồ kênh có thể
và bản đồ kênh hiện tại, cũng có thể tùy ý sửa đổi bản đồ kênh
của luồng hiện tại.

Bản đồ kênh là một mảng vị trí cho mỗi kênh PCM.
Thông thường, luồng PCM âm thanh nổi có bản đồ kênh
ZZ0000ZZ
trong khi luồng PCM bao quanh 4.0 có bản đồ kênh
ZZ0001ZZ

Vấn đề cho đến nay là chúng tôi không có bản đồ kênh tiêu chuẩn
một cách rõ ràng và các ứng dụng không có cách nào để biết kênh nào
tương ứng với vị trí (loa) nào.  Vì vậy, các ứng dụng được áp dụng
kênh sai cho đầu ra 5.1 và bạn đột nhiên nghe thấy âm thanh lạ
từ phía sau.  Hoặc, một số thiết bị bí mật cho rằng center/LFE là
kênh thứ ba/thứ tư trong khi các kênh khác có C/LFE là kênh thứ 5/6.

Ngoài ra, một số thiết bị như HDMI có thể cấu hình cho các loa khác nhau
vị trí ngay cả với cùng số lượng kênh.  Tuy nhiên, có
không có cách nào để xác định điều này vì thiếu bản đồ kênh
đặc điểm kỹ thuật.  Đây là động lực chính cho kênh mới
lập bản đồ API.


Thiết kế
========

Trên thực tế, "ánh xạ kênh API" không giới thiệu điều gì mới trong
phối cảnh kernel/không gian người dùng ABI.  Nó chỉ sử dụng cái hiện có
đặc điểm của phần tử điều khiển

Là một thiết kế mặt đất, mỗi luồng con PCM có thể chứa một phần tử điều khiển
cung cấp thông tin và cấu hình ánh xạ kênh.  Cái này
phần tử được chỉ định bởi:

* iface = SNDRV_CTL_ELEM_IFACE_PCM
* name = "Bản đồ kênh phát lại" hoặc "Chụp bản đồ kênh"
* thiết bị = cùng số thiết bị cho luồng con PCM được chỉ định
* chỉ mục = cùng số chỉ mục cho luồng con PCM được chỉ định

Lưu ý tên khác nhau tùy theo hướng dòng phụ PCM.

Mỗi phần tử điều khiển cung cấp ít nhất thao tác đọc TLV và
thao tác đọc.  Tùy chọn, thao tác ghi có thể được cung cấp cho
cho phép người dùng thay đổi bản đồ kênh một cách linh hoạt.

TLV
---

Thao tác TLV đưa ra danh sách kênh khả dụng
bản đồ.  Mục danh sách của bản đồ kênh thường là TLV của
ZZ0000ZZ
trong đó loại là giá trị loại TLV, đối số thứ hai là tổng
byte (không phải số) của giá trị kênh và phần còn lại là
giá trị vị trí cho mỗi kênh.

Là loại TLV, ZZ0000ZZ,
Có thể sử dụng ZZ0001ZZ hoặc ZZ0002ZZ.
Loại ZZ0003ZZ dành cho bản đồ kênh có vị trí kênh cố định
trong khi hai cái sau dành cho các vị trí kênh linh hoạt. Loại ZZ0004ZZ là
dành cho bản đồ kênh trong đó tất cả các kênh đều có thể hoán đổi tự do và ZZ0005ZZ
type là nơi các kênh theo cặp có thể hoán đổi được.  Ví dụ, khi bạn
có bản đồ kênh {FL/FR/RL/RR}, loại ZZ0006ZZ sẽ cho phép bạn chuyển đổi
chỉ {RL/RR/FL/FR} trong khi loại ZZ0007ZZ sẽ cho phép hoán đổi FL và
RR.

Các loại TLV mới này được xác định trong ZZ0000ZZ.

Các giá trị vị trí kênh khả dụng được xác định trong ZZ0000ZZ,
đây là một vết cắt:

::

/* vị trí kênh */
  liệt kê {
	SNDRV_CHMAP_UNKNOWN = 0,
	SNDRV_CHMAP_NA, /* N/A, im lặng */
	SNDRV_CHMAP_MONO, /* luồng đơn */
	/* cái này tuân theo giá trị kênh của bộ trộn alsa-lib + 3 */
	SNDRV_CHMAP_FL, /* phía trước bên trái */
	SNDRV_CHMAP_FR, /* phía trước bên phải */
	SNDRV_CHMAP_RL, /* phía sau bên trái */
	SNDRV_CHMAP_RR, /* phía sau bên phải */
	SNDRV_CHMAP_FC, /* trung tâm phía trước */
	SNDRV_CHMAP_LFE, /* LFE */
	SNDRV_CHMAP_SL, /* bên trái */
	SNDRV_CHMAP_SR, /* bên phải */
	SNDRV_CHMAP_RC, /* trung tâm phía sau */
	/*định nghĩa mới */
	SNDRV_CHMAP_FLC, /* ở giữa phía trước bên trái */
	SNDRV_CHMAP_FRC, /* phía trước bên phải ở giữa */
	SNDRV_CHMAP_RLC, /* ở giữa phía sau bên trái */
	SNDRV_CHMAP_RRC, /* phía sau bên phải */
	SNDRV_CHMAP_FLW, /* rộng phía trước bên trái */
	SNDRV_CHMAP_FRW, /* rộng phía trước bên phải */
	SNDRV_CHMAP_FLH, /* phía trước bên trái cao */
	SNDRV_CHMAP_FCH, /* cao ở giữa phía trước */
	SNDRV_CHMAP_FRH, /* cao phía trước bên phải */
	SNDRV_CHMAP_TC, /* ở giữa trên cùng */
	SNDRV_CHMAP_TFL, /* phía trên bên trái */
	SNDRV_CHMAP_TFR, /* phía trên bên phải */
	SNDRV_CHMAP_TFC, /* trung tâm phía trước phía trên */
	SNDRV_CHMAP_TRL, /* phía trên bên trái */
	SNDRV_CHMAP_TRR, /* phía trên bên phải */
	SNDRV_CHMAP_TRC, /* trung tâm phía sau phía trên */
	SNDRV_CHMAP_LAST = SNDRV_CHMAP_TRC,
  };

Khi luồng PCM có thể cung cấp nhiều bản đồ kênh, bạn có thể
cung cấp nhiều bản đồ kênh trong loại vùng chứa TLV.  Dữ liệu TLV
được trả lại sẽ chứa như:
:::::::::::::::::::::::::

SNDRV_CTL_TLVT_CONTAINER 96
	    SNDRV_CTL_TLVT_CHMAP_FIXED 4 SNDRV_CHMAP_FC
	    SNDRV_CTL_TLVT_CHMAP_FIXED 8 SNDRV_CHMAP_FL SNDRV_CHMAP_FR
	    SNDRV_CTL_TLVT_CHMAP_FIXED 16 NDRV_CHMAP_FL SNDRV_CHMAP_FR \
		SNDRV_CHMAP_RL SNDRV_CHMAP_RR

Vị trí kênh được cung cấp ở dạng LSB 16 bit.  Các bit trên là
được sử dụng cho cờ bit.
::::::::::::::::::::::::

#define SNDRV_CHMAP_POSITION_MASK 0xffff
	#define SNDRV_CHMAP_PHASE_INVERSE (0x01 << 16)
	#define SNDRV_CHMAP_DRIVER_SPEC (0x02 << 16)

ZZ0000ZZ cho biết kênh bị đảo pha,
(do đó việc tổng hợp các kênh trái và phải sẽ dẫn đến gần như im lặng).
Một số thiết bị mic kỹ thuật số có điều này.

Khi ZZ0000ZZ được đặt, tất cả các giá trị vị trí kênh
không tuân theo định nghĩa tiêu chuẩn ở trên mà dành riêng cho trình điều khiển.

Đọc hoạt động
--------------

Hoạt động đọc điều khiển là để cung cấp bản đồ kênh hiện tại của
luồng đã cho.  Phần tử điều khiển trả về một mảng số nguyên
chứa vị trí của mỗi kênh.

Khi việc này được thực hiện trước khi số lượng kênh được chỉ định
(tức là hw_params được đặt), nó sẽ trả về tất cả các kênh được đặt thành
ZZ0000ZZ.

Viết hoạt động
---------------

Thao tác ghi điều khiển là tùy chọn và chỉ dành cho các thiết bị có thể
thay đổi cấu hình kênh một cách nhanh chóng, chẳng hạn như HDMI.  Nhu cầu của người dùng
để chuyển một giá trị số nguyên chứa các vị trí kênh hợp lệ cho
tất cả các kênh của luồng con PCM được chỉ định.

Hoạt động này chỉ được phép ở trạng thái PCM PREPARED.  Khi được gọi vào
các trạng thái khác, nó sẽ trả về lỗi.
