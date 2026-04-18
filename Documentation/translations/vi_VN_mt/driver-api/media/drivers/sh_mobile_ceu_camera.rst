.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/sh_mobile_ceu_camera.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thuật toán cắt xén và chia tỷ lệ, được sử dụng trong trình điều khiển sh_mobile_ceu_Camera
=======================================================================

Tác giả: Guennadi Liakhovetski <g.liakhovetski@gmx.de>

Thuật ngữ
-----------

thang đo cảm biến: thang đo ngang và dọc, được cấu hình bởi trình điều khiển cảm biến
thang đo máy chủ: -"- trình điều khiển máy chủ
thang đo kết hợp: cảm biến_scale * Host_scale


Sơ đồ chia tỷ lệ/cắt xén chung
---------------------------------

.. code-block:: none

	-1--
	|
	-2-- -\
	|      --\
	|         --\
	+-5-- .      -- -3-- -\
	|      `...            -\
	|          `... -4-- .   - -7..
	|                     `.
	|                       `. .6--
	|
	|                        . .6'-
	|                      .´
	|           ... -4'- .´
	|       ...´             - -7'.
	+-5'- .´               -/
	|            -- -3'- -/
	|         --/
	|      --/
	-2'- -/
	|
	|
	-1'-

Trong biểu đồ trên, các dấu trừ và dấu gạch chéo thể hiện lượng dữ liệu, điểm và
các dấu thể hiện dữ liệu "hữu ích", về cơ bản, đầu ra được chia tỷ lệ và cắt xén của CEU,
được ánh xạ trở lại mặt phẳng nguồn của máy khách.

Cấu hình như vậy có thể được tạo theo yêu cầu của người dùng:

S_CROP(trái / trên = (5) - (1), chiều rộng / chiều cao = (5') - (5))
S_FMT(chiều rộng / chiều cao = (6') - (6))

Đây:

(1) đến (1') - toàn bộ chiều rộng hoặc chiều cao tối đa
(1) đến (2) - cảm biến được cắt sang trái hoặc trên cùng
(2) đến (2') - chiều rộng hoặc chiều cao bị cắt cảm biến
(3) đến (3') - thang đo cảm biến
(3) đến (4) - CEU được cắt sang trái hoặc trên cùng
(4) đến (4') - CEU cắt chiều rộng hoặc chiều cao
(5) đến (5') - thang đo cảm biến ngược được áp dụng cho chiều rộng hoặc chiều cao được cắt của CEU
(2) đến (5) - thang đo cảm biến lùi được áp dụng cho CEU được cắt bên trái hoặc trên cùng
(6) đến (6') - Thang đo CEU - cửa sổ người dùng


S_FMT
-----

Không chạm vào hình chữ nhật đầu vào - nó đã tối ưu rồi.

1. Tính toán thang đo cảm biến hiện tại:

tỉ lệ_s = ((2') - (2)) / ((3') - (3))

2. Tính toán phần cắt đầu vào "hiệu quả" (cửa sổ con cảm biến) - phần cắt CEU được thu nhỏ lại ở
cảm biến hiện tại chia tỷ lệ trên cửa sổ đầu vào - đây là người dùng S_CROP:

width_u = (5') - (5) = ((4') - (4)) * tỉ lệ_s

3. Tính toán các thang đo kết hợp mới từ cửa sổ nhập liệu "hiệu quả" tới người dùng được yêu cầu
cửa sổ:

scale_comb = width_u / ((6') - (6))

4. Tính toán cửa sổ đầu ra cảm biến bằng cách áp dụng thang đo kết hợp cho đầu vào thực
cửa sổ:

width_s_out = ((7') - (7)) = ((2') - (2))/scale_comb

5. Áp dụng cảm biến lặp S_FMT cho cửa sổ đầu ra cảm biến.

subdev->video_ops->s_fmt(.width = width_s_out)

6. Truy xuất cửa sổ đầu ra cảm biến (g_fmt)

7. Tính toán thang đo cảm biến mới:

tỉ lệ_s_new = ((3')_new - (3)_new) / ((2') - (2))

8. Tính toán crop CEU mới - áp dụng thang đo cảm biến cho tính toán trước đó
cây trồng "hiệu quả":

width_ceu = (4')_new - (4)_new = width_u/scale_s_new
	left_ceu = (4)_new - (3)_new = ((5) - (2))/scale_s_new

9. Sử dụng CEU crop để cắt sang cửa sổ mới:

ceu_crop(.width = width_ceu, .left = left_ceu)

10. Sử dụng tỷ lệ CEU để chia tỷ lệ theo cửa sổ người dùng được yêu cầu:

tỉ lệ_ceu = chiều rộng_ceu / chiều rộng


S_CROP
------

ZZ0000ZZ nói:

"...thông số kỹ thuật không xác định nguồn gốc hoặc đơn vị. Tuy nhiên, theo quy ước
trình điều khiển nên đếm các mẫu chưa được chia tỷ lệ theo chiều ngang so với 0H."

Chúng tôi chọn làm theo lời khuyên và giải thích các đơn vị cắt xén là đầu vào của khách hàng
pixel.

Việc cắt xén được thực hiện theo 6 bước sau:

1. Yêu cầu chính xác hình chữ nhật của người dùng từ cảm biến.

2. Nếu nhỏ hơn - lặp lại cho đến khi đạt được giá trị lớn hơn. Kết quả: cảm biến bị cắt
   đến 2 : 2', cắt mục tiêu 5 : 5', định dạng đầu ra hiện tại 6' - 6.

3. Ở bước trước, cảm biến đã cố gắng duy trì khung đầu ra của nó như
   tốt nhất có thể, nhưng nó có thể đã thay đổi. Lấy nó một lần nữa.

4. Cảm biến được chia tỷ lệ thành 3 : 3'. Thang đo của cảm biến là (2' - 2) / (3' - 3). Tính toán
   cửa sổ trung gian: 4' - 4 = (5' - 5) * (3' - 3) / (2' - 2)

5. Tính và áp dụng thang đo chủ = (6' - 6) / (4' - 4)

6. Tính toán và áp dụng cây ký chủ: 6 - 7 = (5 - 2) * (6' - 6) / (5' - 5)