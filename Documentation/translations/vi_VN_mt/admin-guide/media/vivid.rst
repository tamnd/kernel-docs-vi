.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/vivid.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển kiểm tra video ảo (sống động)
=====================================

Trình điều khiển này mô phỏng phần cứng video4linux thuộc nhiều loại khác nhau: quay video, quay video
đầu ra, thu thập và đầu ra vbi, thu thập và đầu ra siêu dữ liệu, máy thu radio và
máy phát, chụp cảm ứng và máy thu radio được xác định bằng phần mềm. Ngoài ra một
thiết bị bộ đệm khung đơn giản có sẵn để thử nghiệm lớp phủ chụp và đầu ra.

Có thể tạo tối đa 64 phiên bản sống động, mỗi phiên bản có tối đa 16 đầu vào và 16 đầu ra.

Mỗi đầu vào có thể là webcam, thiết bị quay TV, thiết bị quay S-Video hoặc HDMI
thiết bị chụp. Mỗi đầu ra có thể là thiết bị đầu ra S-Video hoặc đầu ra HDMI
thiết bị.

Những đầu vào và đầu ra này hoạt động chính xác như một thiết bị phần cứng thực sự. Cái này
cho phép bạn sử dụng trình điều khiển này làm đầu vào thử nghiệm để phát triển ứng dụng, vì
bạn có thể kiểm tra các tính năng khác nhau mà không cần phần cứng đặc biệt.

Tài liệu này mô tả các tính năng được trình điều khiển này triển khai:

- Hỗ trợ đọc()/ghi(), MMAP, USERPTR và DMABUF truyền phát I/O.
- Một danh sách lớn các mẫu thử nghiệm và các biến thể của chúng
- Điều khiển độ sáng, độ tương phản, độ bão hòa và màu sắc
- Hỗ trợ thành phần màu alpha
- Hỗ trợ không gian màu đầy đủ, bao gồm phạm vi RGB giới hạn/đầy đủ
- Tất cả các loại điều khiển có thể có mặt
- Hỗ trợ các tỷ lệ khung hình pixel và tỷ lệ khung hình video khác nhau
- Chèn lỗi để kiểm tra xem điều gì sẽ xảy ra nếu xảy ra lỗi
- Hỗ trợ cắt/soạn/tỷ lệ theo bất kỳ cách kết hợp nào cho cả đầu vào và đầu ra
- Có thể mô phỏng độ phân giải lên tới 4K
- Tất cả các cài đặt Trường đều được hỗ trợ để thử nghiệm chụp xen kẽ
- Hỗ trợ tất cả các định dạng YUV và RGB tiêu chuẩn, bao gồm hai định dạng YUV đa tầng
- Hỗ trợ chụp và xuất VBI thô và cắt lát
- Hỗ trợ máy thu và phát sóng vô tuyến, bao gồm hỗ trợ RDS
- Hỗ trợ đài phát thanh được xác định bằng phần mềm (SDR)
- Hỗ trợ lớp phủ chụp và đầu ra
- Hỗ trợ thu thập và xuất siêu dữ liệu
- Hỗ trợ chụp ảnh cảm ứng

Những tính năng này sẽ được mô tả chi tiết hơn dưới đây.

Cấu hình trình điều khiển
----------------------

Theo mặc định, trình điều khiển sẽ tạo một phiên bản duy nhất có tính năng quay video
thiết bị có đầu vào webcam, TV, S-Video và HDMI, một thiết bị đầu ra video có
Đầu ra S-Video và HDMI, một thiết bị thu vbi, một thiết bị đầu ra vbi, một
thiết bị thu sóng vô tuyến, một thiết bị phát sóng vô tuyến và một thiết bị SDR.

Số lượng phiên bản, thiết bị, đầu vào và đầu ra video cũng như loại của chúng là
tất cả đều có thể cấu hình bằng các tùy chọn mô-đun sau:

- n_devs:

số phiên bản trình điều khiển cần tạo. Theo mặc định được đặt thành 1. Tối đa 64
	trường hợp có thể được tạo ra.

- nút_types:

mỗi phiên bản trình điều khiển nên tạo thiết bị nào. Một mảng
	các giá trị thập lục phân, một giá trị cho mỗi trường hợp. Mặc định là 0xe1d3d.
	Mỗi giá trị là một bitmask có ý nghĩa như sau:

- bit 0: Nút quay video
		- bit 2-3: Nút chụp VBI: 0 = không có, 1 = vbi thô, 2 = vbi cắt lát, 3 = cả hai
		- bit 4: Nút thu sóng vô tuyến
		- bit 5: Nút thu sóng vô tuyến được xác định bằng phần mềm
		- bit 8: Nút đầu ra video
		- bit 10-11: VBI Nút đầu ra: 0 = không có, 1 = vbi thô, 2 = vbi cắt lát, 3 = cả hai
		- bit 12: Nút phát sóng vô tuyến
		- bit 16: Bộ đệm khung để kiểm tra lớp phủ
		- bit 17: Nút thu thập siêu dữ liệu
		- bit 18: Nút đầu ra siêu dữ liệu
		- bit 19: Nút chụp cảm ứng

Vì vậy, để tạo bốn phiên bản, hai phiên bản đầu tiên chỉ có một lần quay video
	thiết bị, hai thiết bị thứ hai chỉ với một thiết bị đầu ra video bạn sẽ vượt qua
	các tùy chọn mô-đun này trở nên sống động:

	.. code-block:: none

		n_devs=4 node_types=0x1,0x1,0x100,0x100

- num_inputs:

số lượng đầu vào, một cho mỗi trường hợp. Theo mặc định 4 đầu vào
	được tạo cho mỗi thiết bị quay video. Có thể tạo tối đa 16 đầu vào,
	và phải có ít nhất một.

- input_types:

loại đầu vào cho từng phiên bản, mặc định là 0xe4. Điều này xác định
	loại của mỗi đầu vào là gì khi đầu vào được tạo cho mỗi trình điều khiển
	ví dụ. Đây là giá trị thập lục phân có tối đa 16 cặp bit, mỗi cặp
	cặp cung cấp loại và bit 0-1 ánh xạ tới đầu vào 0, bit 2-3 ánh xạ tới đầu vào 1,
	Ánh xạ 30-31 tới đầu vào 15. Mỗi cặp bit có ý nghĩa như sau:

- 00: đây là đầu vào webcam
		- 01: đây là đầu vào của bộ thu sóng TV
		- 10: đây là đầu vào S-Video
		- 11: đây là đầu vào HDMI

Vì vậy, để tạo một thiết bị quay video có 8 đầu vào trong đó đầu vào 0 là TV
	bộ điều chỉnh, đầu vào 1-3 là đầu vào S-Video và đầu vào 4-7 là đầu vào HDMI mà bạn
	sẽ sử dụng các tùy chọn mô-đun sau:

	.. code-block:: none

		num_inputs=8 input_types=0xffa9

- num_outputs:

số lượng đầu ra, một cho mỗi trường hợp. Theo mặc định 2 đầu ra
	được tạo cho mỗi thiết bị đầu ra video. Có thể có tối đa 16 đầu ra
	được tạo và phải có ít nhất một.

- đầu ra_types:

loại đầu ra cho từng phiên bản, mặc định là 0x02. Điều này xác định
	loại của mỗi đầu ra là gì khi đầu ra được tạo cho mỗi đầu ra
	ví dụ về trình điều khiển. Đây là giá trị thập lục phân có tối đa 16 bit, mỗi bit
	cung cấp loại và bit 0 ánh xạ tới đầu ra 0, bit 1 ánh xạ tới đầu ra 1, bit
	15 ánh xạ tới đầu ra 15. Ý nghĩa của từng bit như sau:

- 0: đây là đầu ra S-Video
		- 1: đây là đầu ra HDMI

Vì vậy, để tạo một thiết bị đầu ra video có 8 đầu ra trong đó đầu ra là 0-3
	Đầu ra S-Video và đầu ra 4-7 là đầu ra HDMI mà bạn sẽ sử dụng
	tùy chọn mô-đun sau:

	.. code-block:: none

		num_outputs=8 output_types=0xf0

- vid_cap_nr:

cung cấp số bắt đầu videoX mong muốn cho mỗi thiết bị quay video.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên. Điều này cho phép
	bạn ánh xạ các nút quay video tới các nút thiết bị videoX cụ thể. Ví dụ:

	.. code-block:: none

		n_devs=4 vid_cap_nr=2,4,6,8

Điều này sẽ cố gắng gán /dev/video2 cho thiết bị quay video của
	ví dụ sống động đầu tiên, video4 cho video tiếp theo cho đến video8 cho lần cuối cùng
	ví dụ. Nếu không thành công thì nó sẽ lấy lần miễn phí tiếp theo
	số.

- vid_out_nr:

cung cấp số bắt đầu videoX mong muốn cho từng thiết bị đầu ra video.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- vbi_cap_nr:

cung cấp số bắt đầu vbiX mong muốn cho mỗi thiết bị chụp vbi.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- vbi_out_nr:

đưa ra số bắt đầu vbiX mong muốn cho mỗi thiết bị đầu ra vbi.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- radio_rx_nr:

đưa ra số bắt đầu radioX mong muốn cho mỗi thiết bị thu sóng radio.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- radio_tx_nr:

cung cấp số bắt đầu radioX mong muốn cho mỗi máy phát vô tuyến
	thiết bị. Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- sdr_cap_nr:

cung cấp số bắt đầu swradioX mong muốn cho mỗi thiết bị chụp SDR.
	Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- meta_cap_nr:

cung cấp số bắt đầu videoX mong muốn cho từng thiết bị ghi siêu dữ liệu.
        Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- meta_out_nr:

cung cấp số bắt đầu videoX mong muốn cho từng thiết bị đầu ra siêu dữ liệu.
        Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- touch_cap_nr:

cung cấp số bắt đầu v4l-touchX mong muốn cho mỗi thiết bị chụp cảm ứng.
        Mặc định là -1 sẽ chỉ lấy số miễn phí đầu tiên.

- ccs_cap_mode:

chỉ định kết hợp cắt/soạn/tỷ lệ quay video được phép
	cho mỗi trường hợp trình điều khiển. Thiết bị quay video có thể có bất kỳ sự kết hợp nào
	về khả năng cắt xén, soạn thảo và chia tỷ lệ và điều này sẽ cho biết
	trình điều khiển sống động nào trong số đó nên mô phỏng. Theo mặc định người dùng có thể
	chọn điều này thông qua các điều khiển.

Giá trị là -1 (do người dùng điều khiển) hoặc một bộ ba bit,
	mỗi kích hoạt (1) hoặc vô hiệu hóa (0) một trong các tính năng:

- bit 0:

Kích hoạt tính năng hỗ trợ cắt xén. Việc cắt xén sẽ chỉ chiếm một phần
		hình ảnh đến.
	- bit 1:

Bật hỗ trợ soạn thư. Soạn thảo sẽ sao chép thư đến
		hình ảnh vào một bộ đệm lớn hơn.

- bit 2:

Kích hoạt hỗ trợ mở rộng quy mô. Chia tỷ lệ có thể mở rộng quy mô đến
		hình ảnh. Bộ chia tỷ lệ của trình điều khiển sống động có thể phóng to
		hoặc giảm xuống gấp bốn lần kích thước ban đầu. Bộ chia tỷ lệ là
		rất đơn giản và chất lượng thấp. Sự đơn giản và tốc độ là
		chính, không phải chất lượng.

Lưu ý rằng giá trị này bị bỏ qua bởi đầu vào webcam: những giá trị liệt kê
	kích thước khung rời rạc và không tương thích với việc cắt xén, soạn thảo
	hoặc chia tỷ lệ.

- ccs_out_mode:

chỉ định kết hợp cắt/soạn/tỷ lệ đầu ra video được phép
	cho mỗi trường hợp trình điều khiển. Thiết bị đầu ra video có thể có bất kỳ sự kết hợp nào
	về khả năng cắt xén, soạn thảo và chia tỷ lệ và điều này sẽ cho biết
	trình điều khiển sống động nào trong số đó nên mô phỏng. Theo mặc định người dùng có thể
	chọn điều này thông qua các điều khiển.

Giá trị là -1 (do người dùng điều khiển) hoặc một bộ ba bit,
	mỗi kích hoạt (1) hoặc vô hiệu hóa (0) một trong các tính năng:

- bit 0:

Kích hoạt tính năng hỗ trợ cắt xén. Việc cắt xén sẽ chỉ chiếm một phần
		bộ đệm đi.

- bit 1:

Bật hỗ trợ soạn thư. Soạn thảo sẽ sao chép thư đến
		đệm vào một khung hình lớn hơn.

- bit 2:

Kích hoạt hỗ trợ mở rộng quy mô. Chia tỷ lệ có thể mở rộng quy mô đến
		bộ đệm. Bộ chia tỷ lệ của trình điều khiển sống động có thể phóng to
		hoặc giảm xuống gấp bốn lần kích thước ban đầu. Bộ chia tỷ lệ là
		rất đơn giản và chất lượng thấp. Sự đơn giản và tốc độ là
		chính, không phải chất lượng.

- đa mặt phẳng:

chọn xem mỗi phiên bản thiết bị có hỗ trợ các định dạng đa mặt phẳng hay không,
	và do đó là API đa mặt phẳng V4L2. Theo mặc định, phiên bản thiết bị là
	đơn phẳng.

Tùy chọn mô-đun này có thể ghi đè lên tùy chọn đó cho từng phiên bản. Các giá trị là:

- 1: đây là thể hiện một mặt phẳng.
		- 2: đây là thể hiện đa mặt phẳng.

- Vivid_debug:

bật thông tin gỡ lỗi trình điều khiển

- no_error_inj:

nếu được đặt, hãy tắt các điều khiển chèn lỗi. Tùy chọn này là
	cần thiết để chạy một công cụ như tuân thủ v4l2. Những công cụ như thế
	thực hiện tất cả các biện pháp kiểm soát bao gồm cả biện pháp kiểm soát như 'Ngắt kết nối'
	mô phỏng ngắt kết nối USB, khiến thiết bị không thể truy cập được và do đó
	tất cả các thử nghiệm tuân thủ v4l2 đang thực hiện sẽ thất bại sau đó.

Cũng có thể có những tình huống khác mà bạn muốn tắt tính năng này.
	hỗ trợ tiêm lỗi của Vivid. Khi tùy chọn này được thiết lập thì
	các điều khiển chọn hành vi cắt xén, soạn thảo và chia tỷ lệ cũng được
	bị loại bỏ. Trừ khi bị ghi đè bởi ccs_cap_mode và/hoặc ccs_out_mode,
	sẽ mặc định bật cắt, soạn và chia tỷ lệ.

- người phân bổ:

lựa chọn bộ cấp phát bộ nhớ, mặc định là 0. Nó chỉ định cách bộ đệm
	sẽ được phân bổ.

- 0: vmalloc
		- 1: dma-contig

- cache_hint:

chỉ định xem thiết bị có nên đặt bộ nhớ và bộ nhớ đệm trong không gian người dùng của hàng đợi hay không
	khả năng gợi ý nhất quán (V4L2_BUF_CAP_SUPPORTS_MMAP_CACHE_HINTS).
	Các gợi ý chỉ hợp lệ khi sử dụng I/O phát trực tuyến MMAP. Mặc định là 0.

- 0: cấm gợi ý
		- 1: cho phép gợi ý

- support_requests:

chỉ định xem thiết bị có hỗ trợ Yêu cầu API hay không. có
	ba giá trị có thể, mặc định là 1:

- 0: không có yêu cầu
		- 1: hỗ trợ các yêu cầu
		- 2: yêu cầu yêu cầu

Kết hợp lại với nhau, tất cả các tùy chọn mô-đun này cho phép bạn tùy chỉnh chính xác
hành vi của trình điều khiển và kiểm tra ứng dụng của bạn với đủ loại hoán vị.
Nó cũng rất phù hợp để mô phỏng phần cứng chưa có sẵn, ví dụ:
khi phát triển phần mềm cho một thiết bị mới sắp ra mắt.


Quay video
-------------

Đây có lẽ là tính năng được sử dụng thường xuyên nhất. Thiết bị quay video
có thể được cấu hình bằng cách sử dụng các tùy chọn mô-đun num_inputs, input_types và
ccs_cap_mode (xem "Cấu hình trình điều khiển" để biết thêm thông tin chi tiết),
nhưng theo mặc định, bốn đầu vào được định cấu hình: webcam, bộ dò TV, S-Video
và một đầu vào HDMI, một đầu vào cho mỗi loại đầu vào. Những điều đó được mô tả nhiều hơn
chi tiết dưới đây.

Sự chú ý đặc biệt đã được dành cho tốc độ các khung hình mới trở thành
có sẵn. Độ giật sẽ xảy ra trong khoảng 1 giây (điều đó phụ thuộc vào HZ
cấu hình kernel của bạn, thường là 1/100, 1/250 hoặc 1/1000 giây),
nhưng hành vi lâu dài tuân theo chính xác tốc độ khung hình. Vì vậy, một
tốc độ khung hình 59,94 Hz thực sự khác với 60 Hz. Nếu tốc độ khung hình
vượt quá giá trị HZ của kernel thì bạn sẽ bị rớt khung hình, nhưng
Việc đếm trình tự khung/trường sẽ theo dõi điều đó để trình tự
số lượng sẽ bỏ qua bất cứ khi nào khung hình bị loại bỏ.


Đầu vào webcam
~~~~~~~~~~~~

Đầu vào webcam hỗ trợ ba kích thước khung hình: 320x180, 640x360 và 1280x720. Nó
hỗ trợ cài đặt khung hình trên giây là 10, 15, 25, 30, 50 và 60 khung hình / giây. Cái nào
có sẵn tùy thuộc vào kích thước khung hình đã chọn: kích thước khung hình càng lớn thì
giảm số khung hình tối đa mỗi giây.

Không gian màu được chọn ban đầu khi bạn chuyển sang đầu vào webcam sẽ là
sRGB.


Đầu vào TV và S-Video
~~~~~~~~~~~~~~~~~~~~~

Sự khác biệt duy nhất giữa đầu vào TV và S-Video là TV có một
bộ chỉnh âm. Nếu không thì họ hành xử giống hệt nhau.

Những đầu vào này cũng hỗ trợ đầu vào âm thanh: một TV và một đầu vào. Họ
cả hai đều hỗ trợ tất cả các tiêu chuẩn TV. Nếu tiêu chuẩn được truy vấn thì Vivid
điều khiển 'Chế độ tín hiệu tiêu chuẩn' và 'Tiêu chuẩn' xác định những gì
kết quả sẽ là

Những đầu vào này hỗ trợ tất cả các kết hợp của cài đặt trường. Chăm sóc đặc biệt có
được thực hiện để tái tạo một cách trung thực cách các trường được xử lý cho các mục đích khác nhau
Tiêu chuẩn truyền hình. Điều này đặc biệt đáng chú ý khi tạo ra một chiều ngang
hình ảnh chuyển động nên hiệu ứng tạm thời của việc sử dụng các định dạng xen kẽ trở nên rõ ràng
có thể nhìn thấy được. Đối với tiêu chuẩn 50 Hz, trường trên cùng là trường cũ nhất và trường dưới cùng
là mới nhất trong thời gian. Đối với tiêu chuẩn 60 Hz bị đảo ngược: trường dưới cùng
là trường cũ nhất và trường trên cùng là trường mới nhất về thời gian.

Khi bạn bắt đầu chụp ở chế độ V4L2_FIELD_ALTERNATE, bộ đệm đầu tiên sẽ
chứa trường trên cùng cho tiêu chuẩn 50 Hz và trường dưới cùng cho 60 Hz
tiêu chuẩn. Đây cũng là chức năng của phần cứng chụp ảnh.

Cuối cùng, đối với các tiêu chuẩn PAL/SECAM, nửa đầu của dòng trên cùng có chứa nhiễu.
Điều này mô phỏng Tín hiệu màn hình rộng thường được đặt ở đó.

Không gian màu được chọn ban đầu khi bạn chuyển sang đầu vào TV hoặc S-Video
sẽ là SMPTE-170M.

Tỷ lệ khung hình pixel sẽ phụ thuộc vào tiêu chuẩn TV. Tỷ lệ khung hình video
có thể được chọn thông qua điều khiển Sống động 'Tỷ lệ khung hình tiêu chuẩn'.
Các lựa chọn là '4x3', '16x9' sẽ cung cấp video màn hình rộng có hộp thư và
'16x9 Anamorphic' sẽ cung cấp màn hình rộng biến dạng nén toàn màn hình
video sẽ cần được điều chỉnh tỷ lệ cho phù hợp.

'Bộ điều chỉnh' TV hỗ trợ dải tần 44-958 MHz. Các kênh có sẵn
cứ 6 MHz, bắt đầu từ 49,25 MHz. Đối với mỗi kênh, hình ảnh được tạo
sẽ có màu cho +/- 0,25 MHz xung quanh nó và ở thang độ xám cho
+/- 1 MHz xung quanh kênh. Ngoài ra nó chỉ là tiếng ồn. VIDIOC_G_TUNER
ioctl sẽ trả về cường độ tín hiệu 100% cho +/- 0,25 MHz và 50% cho +/- 1 MHz.
Nó cũng sẽ trả về các giá trị afc chính xác để cho biết tần số có quá cao hay không.
thấp hoặc quá cao.

Các kênh con âm thanh được trả về là MONO cho dải tần +/- 1 MHz xung quanh
tần số kênh hợp lệ. Khi tần số nằm trong khoảng +/- 0,25 MHz của
kênh nó sẽ trả về MONO, STEREO, MONO | SAP (đối với NTSC) hoặc
LANG1 ZZ0000ZZ SAP.

Cái nào được trả về tùy thuộc vào kênh đã chọn, mỗi kênh hợp lệ tiếp theo
sẽ chuyển qua các kết hợp kênh con âm thanh có thể có. Điều này cho phép
bạn có thể kiểm tra các kết hợp khác nhau chỉ bằng cách chuyển kênh..

Cuối cùng, đối với những đầu vào này, cấu trúc v4l2_timecode được điền vào
cấu trúc v4l2_buffer đã được loại bỏ.


Đầu vào HDMI
~~~~~~~~~~

Đầu vào HDMI hỗ trợ tất cả các bộ định thời CEA-861 và DMT, cả lũy tiến và
xen kẽ, dành cho tần số pixelclock trong khoảng từ 25 đến 600 MHz. cánh đồng
chế độ cho các định dạng xen kẽ luôn là V4L2_FIELD_ALTERNATE. Đối với HDMI
thứ tự trường luôn là trường trên cùng đầu tiên và khi bạn bắt đầu chụp
định dạng xen kẽ, bạn sẽ nhận được trường trên cùng trước tiên.

Không gian màu được chọn ban đầu khi bạn chuyển sang đầu vào HDMI hoặc
chọn thời gian HDMI dựa trên độ phân giải định dạng: đối với độ phân giải
nhỏ hơn hoặc bằng 720x576 không gian màu được đặt thành SMPTE-170M, đối với
những người khác, nó được đặt thành REC-709 (thời gian CEA-861) hoặc sRGB (thời gian VESA DMT).

Tỷ lệ khung hình pixel sẽ phụ thuộc vào thời gian của HDMI: đối với 720x480 thì phải
được đặt như cho tiêu chuẩn TV NTSC, đối với 720x576, nó được đặt như cho TV PAL
tiêu chuẩn và đối với tất cả các loại khác, tỷ lệ khung hình pixel 1:1 được trả về.

Tỷ lệ khung hình video có thể được chọn thông qua 'Tỷ lệ khung hình thời gian DV'
Kiểm soát sinh động. Các lựa chọn là 'Chiều rộng nguồn x Chiều cao' (chỉ cần sử dụng
cùng tỷ lệ với định dạng đã chọn), '4x3' hoặc '16x9', cả hai đều có thể
dẫn đến video có hộp thư hoặc hộp thư.

Đối với đầu vào HDMI, có thể đặt EDID. Theo mặc định, EDID đơn giản
được cung cấp. Bạn chỉ có thể đặt EDID cho đầu vào HDMI. Tuy nhiên, trong nội bộ,
EDID được chia sẻ giữa tất cả các đầu vào HDMI.

Không có sự giải thích nào được thực hiện đối với dữ liệu EDID ngoại trừ
địa chỉ vật lý. Xem phần CEC để biết thêm chi tiết.

Có tối đa 15 đầu vào HDMI (nếu có nhiều hơn thì chúng sẽ được
giảm xuống 15) vì đó là giới hạn của địa chỉ vật lý EDID.


Đầu ra video
------------

Thiết bị đầu ra video có thể được cấu hình bằng cách sử dụng các tùy chọn mô-đun
num_outputs, out_types và ccs_out_mode (xem "Cấu hình trình điều khiển"
để biết thêm thông tin chi tiết), nhưng theo mặc định, hai đầu ra được cấu hình:
một đầu vào S-Video và một đầu vào HDMI, một đầu ra cho mỗi loại đầu ra. Đó là những
được mô tả chi tiết hơn dưới đây.

Giống như quay video, tốc độ khung hình cũng chính xác về lâu dài.


Đầu ra S-Video
~~~~~~~~~~~~~~

Đầu ra này cũng hỗ trợ đầu ra âm thanh: "Line-Out 1" và "Line-Out 2".
Đầu ra S-Video hỗ trợ tất cả các tiêu chuẩn TV.

Đầu ra này hỗ trợ tất cả các kết hợp của cài đặt trường.

Không gian màu được chọn ban đầu khi bạn chuyển sang đầu vào TV hoặc S-Video
sẽ là SMPTE-170M.


Đầu ra HDMI
~~~~~~~~~~~

Đầu ra HDMI hỗ trợ tất cả các bộ định thời CEA-861 và DMT, cả lũy tiến và
xen kẽ, dành cho tần số pixelclock trong khoảng từ 25 đến 600 MHz. cánh đồng
chế độ cho các định dạng xen kẽ luôn là V4L2_FIELD_ALTERNATE.

Không gian màu được chọn ban đầu khi bạn chuyển sang đầu ra HDMI hoặc
chọn thời gian HDMI dựa trên độ phân giải định dạng: đối với độ phân giải
nhỏ hơn hoặc bằng 720x576 không gian màu được đặt thành SMPTE-170M, đối với
những người khác, nó được đặt thành REC-709 (thời gian CEA-861) hoặc sRGB (thời gian VESA DMT).

Tỷ lệ khung hình pixel sẽ phụ thuộc vào thời gian của HDMI: đối với 720x480 thì phải
được đặt như cho tiêu chuẩn TV NTSC, đối với 720x576, nó được đặt như cho TV PAL
tiêu chuẩn và đối với tất cả các loại khác, tỷ lệ khung hình pixel 1:1 được trả về.

Đầu ra HDMI có EDID hợp lệ có thể lấy được thông qua VIDIOC_G_EDID.

Có tối đa 15 đầu ra HDMI (nếu có nhiều hơn thì chúng sẽ được
giảm xuống 15) vì đó là giới hạn của địa chỉ vật lý EDID. Xem
cũng là phần CEC để biết thêm chi tiết.

Chụp VBI
-----------

Có ba loại thiết bị chụp VBI: những loại chỉ hỗ trợ dữ liệu thô
(chưa mã hóa) VBI, những cái chỉ hỗ trợ VBI cắt lát (đã giải mã) và những cái
ủng hộ cả hai. Điều này được xác định bởi tùy chọn mô-đun node_types. Trong tất cả
trường hợp trình điều khiển sẽ tạo ra dữ liệu VBI hợp lệ: đối với các tiêu chuẩn 60 Hz, nó sẽ
tạo dữ liệu Phụ đề chi tiết và XDS. Luồng phụ đề chi tiết sẽ
xen kẽ giữa "Xin chào thế giới!" và "Kiểm tra phụ đề chi tiết" mỗi giây.
Luồng XDS sẽ cung cấp thời gian hiện tại mỗi phút một lần. Đối với tiêu chuẩn 50 Hz
nó sẽ tạo ra Tín hiệu màn hình rộng dựa trên Video thực tế
Cài đặt kiểm soát Tỷ lệ khung hình và các trang teletext 100-159, một trang trên mỗi khung hình.

Thiết bị VBI sẽ chỉ hoạt động với đầu vào S-Video và TV, nó sẽ cung cấp
quay lại lỗi nếu đầu vào hiện tại là webcam hoặc HDMI.


Đầu ra VBI
----------

Có ba loại thiết bị đầu ra VBI: những loại chỉ hỗ trợ dữ liệu thô
(chưa mã hóa) VBI, những cái chỉ hỗ trợ VBI cắt lát (đã giải mã) và những cái
ủng hộ cả hai. Điều này được xác định bởi tùy chọn mô-đun node_types.

Đầu ra VBI được cắt lát hỗ trợ Tín hiệu màn hình rộng và tín hiệu teletext
cho tiêu chuẩn 50 Hz và Phụ đề chi tiết + XDS cho tiêu chuẩn 60 Hz.

Thiết bị VBI sẽ chỉ hoạt động với đầu ra S-Video, nó sẽ cung cấp
trả lại lỗi nếu đầu ra hiện tại là HDMI.


Máy thu sóng vô tuyến
--------------

Máy thu radio mô phỏng máy thu FM/AM/SW. Băng tần FM cũng hỗ trợ RDS.
Các dải tần số là:

-FM: 64 MHz - 108 MHz
	- AM: 520 kHz - 1710 kHz
	- SW: 2300 kHz - 26,1 MHz

Các kênh hợp lệ được mô phỏng ở tần số 1 MHz cho FM và cứ sau 100 kHz cho AM và SW.
Cường độ tín hiệu càng giảm khi tần số càng xa giá trị hợp lệ
tần số cho đến khi trở thành 0% tại +/- 50 kHz (FM) hoặc 5 kHz (AM/SW) từ
tần số lý tưởng. Tần số ban đầu khi tải trình điều khiển được đặt thành
95 MHz.

Bộ thu FM cũng hỗ trợ RDS, cả hai đều sử dụng 'Chặn I/O' và 'Điều khiển'
chế độ. Trong chế độ 'Điều khiển', thông tin RDS được lưu ở dạng chỉ đọc
điều khiển. Các điều khiển này được cập nhật mỗi khi tần số thay đổi,
hoặc khi trạng thái bộ dò được yêu cầu. Phương thức Chặn I/O sử dụng phương thức read()
giao diện để chuyển các khối RDS vào ứng dụng để giải mã.

Tín hiệu RDS được 'phát hiện' trong khoảng +/- 12,5 kHz xung quanh tần số kênh,
và tần số càng xa tần số hợp lệ thì RDS càng nhiều
các lỗi được đưa ngẫu nhiên vào luồng I/O của khối, chiếm tới 50% tổng số lỗi
chặn nếu bạn ở khoảng +/- 12,5 kHz so với tần số kênh. Cả bốn lỗi
có thể xảy ra với tỷ lệ bằng nhau: các khối được đánh dấu 'CORRECTED', các khối được đánh dấu
'ERROR', các khối được đánh dấu 'INVALID' và các khối bị loại bỏ.

Luồng RDS được tạo chứa tất cả các trường tiêu chuẩn có trong một
Nhóm 0B, cũng như văn bản radio và thời gian hiện tại.

Máy thu hỗ trợ tìm kiếm tần số CTNH, ở chế độ Giới hạn, Bao quanh
hoặc cả hai, có thể định cấu hình bằng điều khiển "Chế độ tìm kiếm CTNH vô tuyến".


Máy phát vô tuyến
-----------------

Máy phát vô tuyến mô phỏng máy phát FM/AM/SW. Băng tần FM cũng hỗ trợ RDS.
Các dải tần số là:

-FM: 64 MHz - 108 MHz
	- AM: 520 kHz - 1710 kHz
	- SW: 2300 kHz - 26,1 MHz

Tần số ban đầu khi tải trình điều khiển là 95,5 MHz.

Bộ phát FM cũng hỗ trợ RDS, cả hai đều sử dụng 'Chặn I/O' và 'Điều khiển'
chế độ. Trong chế độ 'Điều khiển', thông tin RDS được truyền đi được định cấu hình
bằng cách sử dụng các điều khiển và ở chế độ 'Chặn I/O', các khối được chuyển tới trình điều khiển
sử dụng ghi().


Bộ thu sóng vô tuyến được xác định bằng phần mềm
-------------------------------

Bộ thu SDR có ba dải tần cho bộ điều chỉnh ADC:

- 300 kHz
	- 900 kHz - 2800 kHz
	- 3200 kHz

Bộ điều chỉnh RF hỗ trợ 50 MHz - 2000 MHz.

Dữ liệu được tạo chứa các thành phần Cùng pha và Cầu phương của một
Âm 1 kHz có biên độ sqrt(2).


Thu thập siêu dữ liệu
----------------

Việc chụp siêu dữ liệu tạo ra siêu dữ liệu định dạng UVC. PTS và SCR là
được truyền dựa trên các giá trị được đặt trong điều khiển sống động.

Thiết bị Siêu dữ liệu sẽ chỉ hoạt động với đầu vào Webcam, nó sẽ cung cấp
trả lại lỗi cho tất cả các đầu vào khác.


Đầu ra siêu dữ liệu
---------------

Đầu ra siêu dữ liệu có thể được sử dụng để đặt độ sáng, độ tương phản, độ bão hòa và màu sắc.

Thiết bị Siêu dữ liệu sẽ chỉ hoạt động với đầu ra Webcam, nó sẽ cung cấp
trả lại lỗi cho tất cả các đầu ra khác.


Chạm vào Chụp
-------------

Tính năng Chụp cảm ứng tạo ra các mẫu cảm ứng mô phỏng một lần chạm, chạm hai lần,
chạm ba lần, di chuyển từ trái sang phải, phóng to, thu nhỏ, nhấn lòng bàn tay (mô phỏng
một khu vực rộng lớn được nhấn trên bàn di chuột) và mô phỏng 16 thao tác đồng thời
điểm tiếp xúc.

Điều khiển
--------

Các thiết bị khác nhau hỗ trợ các điều khiển khác nhau. Các phần dưới đây sẽ mô tả
từng điều khiển và thiết bị nào hỗ trợ chúng.


Kiểm soát người dùng - Kiểm soát kiểm tra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nút, Boolean, Số nguyên 32 Bit, Số nguyên 64 Bit, Menu, Chuỗi, Bitmask và
Menu số nguyên là các điều khiển đại diện cho tất cả các loại điều khiển có thể có. Thực đơn
cả điều khiển và điều khiển Menu số nguyên đều có 'lỗ hổng' trong danh sách menu của chúng,
nghĩa là một hoặc nhiều mục menu trả về EINVAL khi VIDIOC_QUERYMENU được gọi.
Cả hai điều khiển menu cũng có giá trị điều khiển tối thiểu khác 0.  Những tính năng này
cho phép bạn kiểm tra xem ứng dụng của bạn có thể xử lý những việc đó một cách chính xác hay không.
Các điều khiển này được hỗ trợ cho mọi loại thiết bị.


Kiểm soát người dùng - Quay video
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Các điều khiển sau đây dành riêng cho việc quay video.

Các điều khiển Độ sáng, Độ tương phản, Độ bão hòa và Màu sắc thực sự hoạt động và
tiêu chuẩn. Có một tính năng đặc biệt với điều khiển Độ sáng: mỗi
Đầu vào video có giá trị độ sáng riêng nên việc thay đổi đầu vào sẽ khôi phục
độ sáng cho đầu vào đó. Ngoài ra, mỗi đầu vào video sử dụng một
phạm vi độ sáng (giá trị điều khiển tối thiểu và tối đa). Việc chuyển đổi đầu vào sẽ
khiến một sự kiện điều khiển được gửi cùng với cờ V4L2_EVENT_CTRL_CH_RANGE được đặt.
Điều này cho phép bạn kiểm tra các điều khiển có thể thay đổi phạm vi của chúng.

Các điều khiển 'Tăng, Tự động' và Tăng có thể được sử dụng để kiểm tra các điều khiển dễ bay hơi:
nếu 'Tăng, Tự động' được đặt thì điều khiển Tăng sẽ không ổn định và thay đổi
liên tục. Nếu 'Tăng, Tự động' bị xóa thì điều khiển Tăng là bình thường
kiểm soát.

Các điều khiển 'Lật ngang' và 'Lật dọc' có thể được sử dụng để lật
hình ảnh. Những điều này kết hợp với 'Cảm biến lật ngang/dọc' Sống động
điều khiển.

Điều khiển 'Thành phần Alpha' có thể được sử dụng để đặt thành phần alpha cho
các định dạng có chứa kênh alpha.


Kiểm soát người dùng - Âm thanh
~~~~~~~~~~~~~~~~~~~~~

Các điều khiển sau đây dành riêng cho việc quay và xuất video cũng như radio
máy thu và máy phát.

Các nút điều khiển âm thanh 'Âm lượng' và 'Tắt tiếng' là đặc trưng của các thiết bị đó để
điều khiển âm lượng và tắt âm thanh. Họ thực sự không làm bất cứ điều gì trong
người lái xe sống động.


Điều khiển sống động
~~~~~~~~~~~~~~

Các điều khiển tùy chỉnh sống động này kiểm soát việc tạo hình ảnh, chèn lỗi, v.v.


Kiểm soát mẫu thử nghiệm
^^^^^^^^^^^^^^^^^^^^^

Tất cả các Điều khiển mẫu thử nghiệm đều dành riêng cho quay video.

- Mẫu thử:

chọn mẫu thử nghiệm nào sẽ sử dụng. Sử dụng Thanh màu CSC để
	thử nghiệm chuyển đổi không gian màu: các màu được sử dụng trong mẫu thử nghiệm đó
	ánh xạ tới các màu hợp lệ trong tất cả các không gian màu. Chuyển đổi không gian màu
	bị vô hiệu hóa đối với các mẫu thử nghiệm khác.

- Chế độ văn bản OSD:

chọn xem văn bản có được xếp chồng lên trên hay không
	mẫu thử nghiệm phải được hiển thị và nếu vậy, liệu chỉ có bộ đếm nên được hiển thị hay không
	được hiển thị hoặc toàn văn.

- Chuyển động ngang:

chọn xem mẫu thử nghiệm có nên
	di chuyển sang trái hoặc phải và với tốc độ nào.

- Chuyển động thẳng đứng:

làm tương tự cho hướng dọc.

- Hiển thị đường viền:

hiển thị đường viền rộng hai pixel ở cạnh của hình ảnh thực tế,
	không bao gồm thư hoặc hộp thư.

- Hiển thị hình vuông:

hiển thị một hình vuông ở giữa hình ảnh. Nếu hình ảnh là
	được hiển thị với các chỉnh sửa tỷ lệ khung hình và pixel chính xác,
	thì chiều rộng và chiều cao của hình vuông trên màn hình sẽ là
	giống nhau.

- Chèn mã SAV vào hình ảnh:

thêm mã SAV (Bắt đầu video hoạt động) vào hình ảnh.
	Điều này có thể được sử dụng để kiểm tra xem các mã như vậy trong hình ảnh có vô tình không
	được giải thích thay vì bị bỏ qua.

- Chèn mã EAV vào hình ảnh:

thực hiện tương tự đối với mã EAV (Kết thúc video hoạt động).

- Chèn dải bảo vệ video

thêm 4 cột pixel với mã HDMI Video Guard Band ở
	bên tay trái của hình ảnh. Điều này chỉ hoạt động với pixel RGB 3 hoặc 4 byte
	các định dạng. Giá trị pixel RGB 0xab/0x55/0xab hóa ra tương đương
	tới mã Dải bảo vệ video HDMI đứng trước mỗi dòng video đang hoạt động
	(xem phần 5.2.2.1 trong Thông số kỹ thuật HDMI 1.3). Để kiểm tra xem một video
	bộ thu đã xử lý Dải bảo vệ video HDMI chính xác, hãy bật tính năng này
	điều khiển rồi di chuyển hình ảnh sang phía bên trái màn hình.
	Điều đó sẽ dẫn đến các dòng video bắt đầu bằng nhiều pixel
	có cùng giá trị với Dải bảo vệ video trước chúng.
	Các máy thu tiếp tục bỏ qua các giá trị của Dải bảo vệ video sẽ
	hiện không thành công và đồng bộ hóa lỏng lẻo hoặc các dòng video này sẽ thay đổi.


Chụp các điều khiển lựa chọn tính năng
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tất cả các điều khiển này đều dành riêng cho quay video.

- Cảm biến lật ngang:

hình ảnh được lật theo chiều ngang và
	Cờ trạng thái đầu vào V4L2_IN_ST_HFLIP được đặt. Điều này mô phỏng trường hợp
	ví dụ như một cảm biến được gắn lộn ngược.

- Cảm biến lật theo chiều dọc:

hình ảnh được lật theo chiều dọc và
	Cờ trạng thái đầu vào V4L2_IN_ST_VFLIP được đặt. Điều này mô phỏng trường hợp
	ví dụ như một cảm biến được gắn lộn ngược.

- Tỷ lệ khung hình tiêu chuẩn:

chọn nếu tỷ lệ khung hình hình ảnh được sử dụng cho TV hoặc
	Đầu vào S-Video phải là màn hình rộng 4x3, 16x9 hoặc anamorphic. Điều này có thể
	giới thiệu hộp thư.

- Tỷ lệ khung hình thời gian DV:

chọn nếu tỷ lệ khung hình hình ảnh được sử dụng cho HDMI
	đầu vào phải giống với tỷ lệ chiều rộng và chiều cao của nguồn hoặc nếu
	nó phải là 4x3 hoặc 16x9. Điều này có thể giới thiệu hộp thư hoặc cột trụ.

- Nguồn dấu thời gian:

chọn thời điểm lấy dấu thời gian cho mỗi bộ đệm.

- Không gian màu:

chọn không gian màu nào sẽ được sử dụng khi tạo hình ảnh.
	Điều này chỉ áp dụng nếu mẫu kiểm tra Thanh màu CSC được chọn,
	nếu không mẫu thử nghiệm sẽ không được chuyển đổi.
	Hành vi này cũng là điều bạn muốn, vì Thanh màu 75%
	thực sự phải có cường độ tín hiệu 75% và không bị ảnh hưởng
	bằng cách chuyển đổi không gian màu.

Thay đổi không gian màu sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng sự thay đổi về không gian màu được phát hiện.

- Hàm chuyển:

chọn chức năng chuyển không gian màu nào sẽ được sử dụng khi
	tạo ra một hình ảnh. Điều này chỉ áp dụng nếu mẫu kiểm tra Thanh màu CSC được
	được chọn, nếu không mẫu thử nghiệm sẽ không được chuyển đổi.
	Hành vi này cũng là điều bạn muốn, vì Thanh màu 75%
	thực sự phải có cường độ tín hiệu 75% và không bị ảnh hưởng
	bằng cách chuyển đổi không gian màu.

Thay đổi chức năng truyền sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng sự thay đổi về không gian màu được phát hiện.

- Mã hóa Y'CbCr:

chọn mã hóa Y'CbCr nào sẽ được sử dụng khi tạo
	ảnh Y'CbCr.	Điều này chỉ áp dụng nếu định dạng được đặt thành định dạng Y'CbCr
	trái ngược với định dạng RGB.

Thay đổi mã hóa Y'CbCr sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng sự thay đổi về không gian màu được phát hiện.

- Lượng tử hóa:

chọn lượng tử hóa nào sẽ được sử dụng cho RGB hoặc Y'CbCr
	mã hóa khi tạo mẫu thử nghiệm.

Thay đổi lượng tử hóa sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng sự thay đổi về không gian màu được phát hiện.

- Phạm vi giới hạn RGB (16-235):

chọn xem phạm vi RGB của nguồn HDMI có nên
	bị giới hạn hoặc đầy đủ. Điều này kết hợp với Video kỹ thuật số 'Rx RGB
	phạm vi lượng tử hóa' và có thể được sử dụng để kiểm tra xem điều gì sẽ xảy ra nếu
	một nguồn cung cấp cho bạn thông tin phạm vi lượng tử hóa sai.
	Xem mô tả về điều khiển đó để biết thêm chi tiết.

- Chỉ áp dụng Alpha cho màu đỏ:

áp dụng kênh alpha do 'Thành phần Alpha' đặt
	người dùng chỉ kiểm soát màu đỏ của mẫu thử.

- Kích hoạt tính năng chụp ảnh cắt xén:

cho phép hỗ trợ cây trồng. Sự kiểm soát này chỉ tồn tại nếu
	tùy chọn mô-đun ccs_cap_mode được đặt thành giá trị mặc định là -1 và nếu
	tùy chọn mô-đun no_error_inj được đặt thành 0 (mặc định).

- Kích hoạt chế độ chụp soạn thảo:

cho phép soạn thảo hỗ trợ. Việc kiểm soát này chỉ
	xuất hiện nếu tùy chọn mô-đun ccs_cap_mode được đặt thành giá trị mặc định là
	-1 và nếu tùy chọn mô-đun no_error_inj được đặt thành 0 (mặc định).

- Kích hoạt tính năng Capture Scaler:

cho phép hỗ trợ cho bộ chia tỷ lệ (nâng cấp tối đa 4 lần
	và thu nhỏ). Kiểm soát này chỉ hiện diện nếu ccs_cap_mode
	tùy chọn mô-đun được đặt thành giá trị mặc định là -1 và nếu no_error_inj
	tùy chọn mô-đun được đặt thành 0 (mặc định).

- Khối EDID tối đa:

xác định có bao nhiêu khối EDID mà trình điều khiển hỗ trợ.
	Lưu ý rằng trình điều khiển sống động không thực sự diễn giải EDID mới
	dữ liệu, nó chỉ lưu trữ nó. Nó cho phép tối đa 256 khối EDID
	đó là mức tối đa được hỗ trợ bởi tiêu chuẩn.

- Tỷ lệ lấp đầy khung hình:

chỉ có thể được sử dụng để vẽ phần trăm X hàng đầu
	của hình ảnh. Vì mỗi khung phải được trình điều khiển vẽ nên
	đòi hỏi rất nhiều CPU. Đối với độ phân giải lớn, điều này trở thành
	có vấn đề. Bằng cách chỉ vẽ một phần của hình ảnh, tải CPU này có thể
	được giảm bớt.


Điều khiển lựa chọn tính năng đầu ra
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Tất cả các điều khiển này đều dành riêng cho đầu ra video.

- Kích hoạt tính năng cắt xén đầu ra:

cho phép hỗ trợ cây trồng. Sự kiểm soát này chỉ tồn tại nếu
	tùy chọn mô-đun ccs_out_mode được đặt thành giá trị mặc định là -1 và nếu
	tùy chọn mô-đun no_error_inj được đặt thành 0 (mặc định).

- Kích hoạt tính năng soạn thảo đầu ra:

cho phép soạn thảo hỗ trợ. Việc kiểm soát này chỉ
	hiện diện nếu tùy chọn mô-đun ccs_out_mode được đặt thành giá trị mặc định là
	-1 và nếu tùy chọn mô-đun no_error_inj được đặt thành 0 (mặc định).

- Kích hoạt Bộ chia tỷ lệ đầu ra:

cho phép hỗ trợ cho bộ chia tỷ lệ (nâng cấp tối đa 4 lần
	và thu nhỏ). Kiểm soát này chỉ hiện diện nếu ccs_out_mode
	tùy chọn mô-đun được đặt thành giá trị mặc định là -1 và nếu no_error_inj
	tùy chọn mô-đun được đặt thành 0 (mặc định).


Kiểm soát tiêm lỗi
^^^^^^^^^^^^^^^^^^^^^^^^

Hai điều khiển sau đây chỉ hợp lệ để quay video và quay vbi.

- Chế độ tín hiệu tiêu chuẩn:

chọn hành vi của VIDIOC_QUERYSTD: nó sẽ trả về cái gì?

Thay đổi điều khiển này sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng một điều kiện đầu vào đã thay đổi (ví dụ: cáp
	đã được cắm vào hoặc ra).

- Tiêu chuẩn:

chọn tiêu chuẩn mà VIDIOC_QUERYSTD sẽ trả về nếu
	điều khiển trước đó được đặt thành "Tiêu chuẩn đã chọn".

Thay đổi điều khiển này sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng một tiêu chuẩn đầu vào đã thay đổi.


Hai điều khiển sau đây chỉ hợp lệ để quay video.

- Chế độ tín hiệu định giờ DV:

chọn hành vi của VIDIOC_QUERY_DV_TIMINGS: cái gì
	nó có nên quay lại không?

Thay đổi điều khiển này sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng một điều kiện đầu vào đã thay đổi (ví dụ: cáp
	đã được cắm vào hoặc ra).

- Thời gian DV:

chọn thời gian mà VIDIOC_QUERY_DV_TIMINGS sẽ quay lại
	nếu điều khiển trước đó được đặt thành "Thời gian DV đã chọn".

Thay đổi điều khiển này sẽ dẫn đến V4L2_EVENT_SOURCE_CHANGE
	được gửi đi vì nó mô phỏng thời gian đầu vào đã thay đổi.


Các điều khiển sau chỉ xuất hiện nếu tùy chọn mô-đun no_error_inj
được đặt thành 0 (mặc định). Các điều khiển này hợp lệ cho video và vbi
các luồng thu và đầu ra cũng như cho thiết bị thu SDR ngoại trừ
Kiểm soát ngắt kết nối có hiệu lực cho tất cả các thiết bị.

- Số thứ tự gói:

kiểm tra xem điều gì xảy ra khi bạn bọc số thứ tự vào
	struct v4l2_buffer xung quanh.

- Dấu thời gian gói:

kiểm tra xem điều gì xảy ra khi bạn bọc dấu thời gian trong struct
	v4l2_buffer xung quanh.

- Tỷ lệ bộ đệm bị rơi:

đặt tỷ lệ phần trăm bộ đệm
	người lái xe không bao giờ trả lại (tức là chúng bị rơi).

- Ngắt kết nối:

mô phỏng ngắt kết nối USB. Thiết bị sẽ hoạt động như thể nó có
	bị ngắt kết nối. Chỉ sau khi mở tất cả các thẻ xử lý tệp cho thiết bị
	nút đã bị đóng thì thiết bị sẽ được 'kết nối' trở lại.

- Tiêm V4L2_BUF_FLAG_ERROR:

khi được nhấn, khung tiếp theo sẽ được trả về bởi
	trình điều khiển sẽ đặt cờ lỗi (tức là khung được đánh dấu
	tham nhũng).

- Tiêm VIDIOC_REQBUFS Lỗi:

khi nhấn, REQBUFS hoặc CREATE_BUFS tiếp theo
	cuộc gọi ioctl sẽ thất bại và có lỗi. Nói chính xác hơn: videobuf2
	queue_setup() op sẽ trả về -EINVAL.

- Tiêm VIDIOC_QBUF Lỗi:

khi nhấn, VIDIOC_QBUF tiếp theo hoặc
	Cuộc gọi ioctl VIDIOC_PREPARE_BUFFER sẽ không thành công và có lỗi. trở thành
	chính xác: videobuf2 buf_prepare() op sẽ trả về -EINVAL.

- Tiêm VIDIOC_STREAMON Lỗi:

khi nhấn, ioctl VIDIOC_STREAMON tiếp theo
	cuộc gọi sẽ thất bại và có lỗi. Nói chính xác hơn: videobuf2
	start_streaming() op sẽ trả về -EINVAL.

- Tiêm lỗi truyền phát nghiêm trọng:

khi được nhấn, lõi phát trực tuyến sẽ
	được đánh dấu là đã gặp phải lỗi nghiêm trọng, cách duy nhất để khôi phục
	từ đó là ngừng phát trực tuyến. Nói chính xác hơn: videobuf2
	Hàm vb2_queue_error() được gọi.


Điều khiển chụp thô VBI
^^^^^^^^^^^^^^^^^^^^^^^^

- Định dạng VBI xen kẽ:

nếu được đặt thì dữ liệu VBI thô sẽ được xen kẽ thay thế
	cung cấp nó được nhóm theo lĩnh vực.


Điều khiển video kỹ thuật số
~~~~~~~~~~~~~~~~~~~~~~

- Phạm vi lượng tử hóa Rx RGB:

đặt phát hiện lượng tử hóa RGB của HDMI
	đầu vào. Điều này kết hợp với Phạm vi RGB có giới hạn của Vivid (16-235)'
	kiểm soát và có thể được sử dụng để kiểm tra xem điều gì sẽ xảy ra nếu một nguồn cung cấp
	bạn có thông tin phạm vi lượng tử hóa sai. Điều này có thể được kiểm tra
	bằng cách chọn đầu vào HDMI, đặt điều khiển này thành Đầy đủ hoặc Giới hạn
	phạm vi và chọn phạm vi ngược lại trong 'Phạm vi RGB có giới hạn (16-235)'
	kiểm soát. Hiệu quả rất dễ nhận thấy nếu mẫu thử nghiệm 'Gray Ramp'
	được chọn.

- Phạm vi lượng tử hóa Tx RGB:

đặt phát hiện lượng tử hóa RGB của HDMI
	đầu ra. Hiện tại nó không được sử dụng cho bất kỳ mục đích sống động nào, nhưng hầu hết HDMI
	máy phát thường có điều khiển này.

- Chế độ truyền:

đặt chế độ truyền của đầu ra HDMI thành HDMI hoặc DVI-D. Cái này
	ảnh hưởng đến không gian màu được báo cáo vì đầu ra DVI_D sẽ luôn sử dụng
	sRGB.


Điều khiển máy thu đài FM
~~~~~~~~~~~~~~~~~~~~~~~~~~

- Tiếp tân RDS:

được đặt xem có nên bật bộ thu RDS hay không.

- Loại chương trình RDS:


- Tên PS RDS:


- Văn bản đài phát thanh RDS:


- Thông báo giao thông RDS:


- Chương trình giao thông RDS:


- Âm nhạc RDS:

đây đều là những điều khiển chỉ đọc. Nếu Chế độ I/O RDS Rx được đặt thành
	"Chặn I/O", thì chúng cũng không hoạt động. Nếu Chế độ I/O RDS Rx được đặt
	thành "Điều khiển", thì các điều khiển này sẽ báo cáo dữ liệu RDS đã nhận.

.. note::
	The vivid implementation of this is pretty basic: they are only
	updated when you set a new frequency or when you get the tuner status
	(VIDIOC_G_TUNER).

- Chế độ tìm kiếm CTNH Radio:

có thể là một trong những "Bị giới hạn", "Quấn quanh" hoặc "Cả hai". Cái này
	xác định xem VIDIOC_S_HW_FREQ_SEEK có bị giới hạn bởi tần số hay không
	phạm vi hoặc bao quanh hoặc nếu người dùng có thể chọn.

- Tìm kiếm HW có thể lập trình bằng radio:

nếu được đặt thì người dùng có thể cung cấp mức thấp hơn và
	giới hạn trên của HW Seek. Mặt khác, ranh giới dải tần số
	sẽ được sử dụng.

- Tạo RBDS thay vì RDS:

nếu được đặt, thì hãy tạo RBDS (biến thể của Hoa Kỳ
	Dữ liệu RDS) thay vì RDS (RDS kiểu Châu Âu). Điều này chỉ ảnh hưởng đến
	Mã PICODE và PTY.

- Chế độ I/O RDS Rx:

đây có thể là "Chặn I/O" trong đó các khối RDS phải được đọc()
	bởi ứng dụng hoặc "Điều khiển" trong đó dữ liệu RDS được cung cấp bởi
	các điều khiển RDS được đề cập ở trên.


Điều khiển bộ điều biến đài FM
~~~~~~~~~~~~~~~~~~~~~~~~~~~

- ID chương trình RDS:


- Loại chương trình RDS:


- Tên PS RDS:


- Văn bản đài phát thanh RDS:


- Âm thanh nổi RDS:


- Đầu nhân tạo RDS:


- RDS nén:


- RDS PTY động:


- Thông báo giao thông RDS:


- Chương trình giao thông RDS:


- Âm nhạc RDS:

đây là tất cả các điều khiển thiết lập dữ liệu RDS được truyền bởi
	bộ điều chế FM.

- Chế độ I/O RDS Tx:

đây có thể là "Chặn I/O" trong đó ứng dụng phải sử dụng write()
	để chuyển các khối RDS cho trình điều khiển hoặc "Điều khiển" trong đó dữ liệu RDS
	được cung cấp bởi các điều khiển RDS đã đề cập ở trên.

Kiểm soát thu thập siêu dữ liệu
~~~~~~~~~~~~~~~~~~~~~~~~~~

- Tạo PTS

nếu được đặt thì luồng siêu dữ liệu được tạo sẽ chứa dấu thời gian của Bản trình bày.

- Tạo SCR

nếu được đặt thì luồng siêu dữ liệu được tạo sẽ chứa thông tin Đồng hồ nguồn.


Video, Vòng lặp VBI được cắt lát và HDMI CEC
--------------------------------------

Chức năng Video Looping được hỗ trợ cho các thiết bị được tạo bởi cùng một
phiên bản trình điều khiển sống động, cũng như trên nhiều phiên bản của trình điều khiển sống động.
Trình điều khiển sống động hỗ trợ lặp video và dữ liệu Sliced VBI giữa đầu ra S-Video
và một đầu vào S-Video. Nó cũng hỗ trợ lặp video và dữ liệu HDMI CEC giữa một
Đầu ra HDMI và đầu vào HDMI.

Để bật vòng lặp, hãy đặt (các) điều khiển 'HDMI/S-Video XXX-N được kết nối với' để chọn
liệu một đầu vào có sử dụng Trình tạo mẫu thử hay không, bị ngắt kết nối hay được kết nối
đến một đầu ra. Đầu vào có thể được kết nối với đầu ra từ bất kỳ phiên bản sống động nào.
Đầu vào và đầu ra được đánh số XXX-N trong đó XXX là số phiên bản sống động
(xem tùy chọn mô-đun n_devs). Nếu chỉ có một trường hợp sống động (mặc định), thì
XXX sẽ là 000. Và N là đầu vào hoặc đầu ra S-Video/HDMI thứ N của phiên bản đó.
Nếu sống động được tải mà không có tùy chọn mô-đun thì bạn có thể kết nối đầu vào S-Video 000-0
đến đầu ra S-Video 000-0 hoặc đầu vào HDMI 000-0 đến đầu ra HDMI 000-0.
Điều này tương đương với việc kết nối hoặc ngắt kết nối cáp giữa đầu vào và
đầu ra trong một thiết bị vật lý.

Nếu điều khiển 'HDMI/S-Video XXX-N được kết nối với' đã chọn một đầu ra thì video
đầu ra sẽ được lặp lại với đầu vào video với điều kiện:

- đầu vào hiện được chọn khớp với đầu vào được chỉ định bởi tên điều khiển.

- trong phiên bản sống động của đầu nối đầu ra, đầu ra hiện được chọn khớp với
  đầu ra được chỉ định bởi giá trị của điều khiển.

- độ phân giải video của đầu vào video phải phù hợp với độ phân giải của đầu ra video.
  Vì vậy, không thể lặp đầu ra S-Video 50 Hz (720x576) thành 60 Hz
  (720x480) Đầu vào S-Video hoặc đầu ra 720p60 HDMI thành đầu vào 1080p30.

- định dạng pixel phải giống hệt nhau ở cả hai mặt. Nếu không thì người lái xe sẽ
  cũng phải thực hiện chuyển đổi định dạng pixel và điều đó đang đi quá xa.

- cài đặt trường phải giống hệt nhau ở cả hai bên. Lý do tương tự như trên:
  yêu cầu trình điều khiển chuyển đổi từ định dạng trường này sang định dạng phức tạp khác
  quan trọng quá nhiều. Điều này cũng cấm chụp bằng 'Field Top' hoặc 'Field
  Dưới cùng' khi video đầu ra được đặt thành 'Field Alternate'. Sự kết hợp này,
  trong khi hợp pháp, trở nên quá phức tạp để hỗ trợ. Cả hai bên đều phải là 'Field'
  Alternate' để làm việc này. Cũng lưu ý rằng đối với trường hợp cụ thể này,
  trình tự và đếm trường trong struct v4l2_buffer ở phía chụp có thể không
  chính xác 100%.

- cài đặt trường V4L2_FIELD_SEQ_TB/BT không được hỗ trợ. Trong khi có thể
  thực hiện điều này thì sẽ cần rất nhiều công sức để thực hiện được điều này. Vì những điều này
  các giá trị trường hiếm khi được sử dụng nên quyết định không thực hiện điều này cho
  bây giờ.

- ở phía đầu vào "Chế độ tín hiệu tiêu chuẩn" cho đầu vào S-Video hoặc
  "Chế độ tín hiệu định giờ DV" cho đầu vào HDMI phải được cấu hình sao cho
  tín hiệu hợp lệ được chuyển đến đầu vào video.

Nếu bất kỳ điều kiện nào không hợp lệ thì mẫu kiểm tra 'Tiếng ồn' sẽ được hiển thị.

Tốc độ khung hình không cần phải khớp nhau, mặc dù điều này có thể thay đổi trong tương lai.

Theo mặc định, bạn sẽ thấy văn bản OSD được xếp chồng lên trên video được lặp.
Có thể tắt tính năng này bằng cách thay đổi điều khiển "Chế độ văn bản OSD" của video
thiết bị chụp.

Để vòng lặp VBI hoạt động, tất cả những điều trên phải hợp lệ và ngoài ra, vbi
đầu ra phải được cấu hình cho VBI được cắt lát. Bên chụp VBI có thể được cấu hình
cho VBI sống hoặc cắt lát. Lưu ý rằng hiện tại chỉ có CC/XDS (định dạng 60 Hz)
và WSS (định dạng 50 Hz) Dữ liệu VBI được lặp lại. Dữ liệu Teletext VBI không được lặp lại.


Vòng lặp vô tuyến & RDS
-------------------

Trình điều khiển sống động hỗ trợ lặp vòng đầu ra RDS sang đầu vào RDS.

Vì radio là không dây nên việc lặp này luôn xảy ra nếu máy thu radio
tần số gần bằng tần số máy phát vô tuyến. Trong trường hợp đó đài phát thanh
máy phát sẽ 'ghi đè' các đài phát thanh giả lập.

Vòng lặp RDS hiện chỉ được hỗ trợ giữa các thiết bị được tạo bởi cùng một
ví dụ trình điều khiển sống động.

Như đã đề cập trong phần "Bộ thu sóng vô tuyến", bộ thu sóng vô tuyến mô phỏng
các đài ở các khoảng tần số đều đặn. Tùy thuộc vào tần số của
máy thu radio, giá trị cường độ tín hiệu được tính toán (giá trị này được trả về bởi
VIDIOC_G_TUNER). Tuy nhiên, nó cũng sẽ xem xét tần số do đài đặt
máy phát và nếu điều đó dẫn đến cường độ tín hiệu cao hơn cài đặt
của máy phát vô tuyến sẽ được sử dụng như thể nó là một đài hợp lệ. Điều này cũng
bao gồm dữ liệu RDS (nếu có) mà bộ phát 'truyền'. Đây là
nhận được một cách trung thực ở phía người nhận. Lưu ý rằng khi tải trình điều khiển
tần số của máy thu và máy phát vô tuyến không giống nhau, do đó
ban đầu không có vòng lặp nào diễn ra.


Cắt xén, soạn thảo, chia tỷ lệ
----------------------------

Trình điều khiển này hỗ trợ cắt xén, soạn thảo và chia tỷ lệ theo bất kỳ sự kết hợp nào. Thông thường
Những tính năng nào được hỗ trợ có thể được chọn thông qua các điều khiển Sống động,
nhưng cũng có thể mã hóa cứng nó khi mô-đun được tải thông qua
Tùy chọn mô-đun ccs_cap_mode và ccs_out_mode. Xem phần "Cấu hình trình điều khiển" trên
chi tiết về các tùy chọn mô-đun này.

Điều này cho phép bạn kiểm tra ứng dụng của mình để tìm tất cả các biến thể này.

Lưu ý rằng đầu vào webcam không bao giờ hỗ trợ cắt xén, soạn thảo hoặc chia tỷ lệ. Đó
chỉ áp dụng cho đầu vào và đầu ra TV/S-Video/HDMI. Lý do là vậy
webcam, bao gồm cả việc triển khai ảo này, thường sử dụng
VIDIOC_ENUM_FRAMESIZES để liệt kê một tập hợp các kích thước khung hình riêng biệt mà nó hỗ trợ.
Và điều đó không kết hợp với việc cắt xén, soạn thảo hoặc chia tỷ lệ. Đây là
chủ yếu là một hạn chế của V4L2 API được sao chép cẩn thận ở đây.

Độ phân giải tối thiểu và tối đa mà bộ chia tỷ lệ có thể đạt được là 16x16 và
(4096 * 4) x (2160 x 4), nhưng nó chỉ có thể tăng hoặc giảm tỷ lệ theo hệ số 4 hoặc
ít hơn. Vì vậy, đối với độ phân giải nguồn 1280x720, mức tối thiểu mà bộ chia tỷ lệ có thể làm là
320x180 và tối đa là 5120x2880. Bạn có thể giải quyết vấn đề này bằng cách sử dụng
công cụ kiểm tra qv4l2 và bạn sẽ thấy những phần phụ thuộc này.

Trình điều khiển này cũng hỗ trợ cài đặt 'bytesperline' lớn hơn, điều này
VIDIOC_S_FMT cho phép nhưng ít trình điều khiển thực hiện.

Bộ chia tỷ lệ là một bộ chia tỷ lệ đơn giản sử dụng thuật toán Coarse Bresenham. Đó là
được thiết kế cho tốc độ và sự đơn giản, không phải chất lượng.

Nếu sự kết hợp giữa cắt xén, soạn thảo và chia tỷ lệ cho phép thì có thể thực hiện được
để thay đổi cắt xén và soạn các hình chữ nhật một cách nhanh chóng.


Định dạng
-------

Trình điều khiển hỗ trợ tất cả các định dạng đóng gói và phẳng thông thường 4:4:4, 4:2:2 và 4:2:0
Các định dạng YUYV, các định dạng đóng gói 8, 16, 24 và 32 RGB và nhiều định dạng đa mặt phẳng khác nhau
các định dạng.

Thành phần alpha có thể được đặt thông qua Kiểm soát người dùng 'Thành phần Alpha'
cho những định dạng hỗ trợ nó. Nếu điều khiển 'Chỉ áp dụng Alpha cho màu đỏ'
được đặt thì thành phần alpha chỉ được sử dụng cho màu đỏ và được đặt thành
0 nếu không.

Trình điều khiển phải được cấu hình để hỗ trợ các định dạng đa mặt phẳng. Theo mặc định
các phiên bản trình điều khiển là đơn phẳng. Điều này có thể được thay đổi bằng cách thiết lập
tùy chọn mô-đun nhiều mặt phẳng, hãy xem "Cấu hình trình điều khiển" để biết thêm chi tiết về điều đó
tùy chọn.

Nếu phiên bản trình điều khiển đang sử dụng định dạng nhiều mặt phẳng/API thì phiên bản đầu tiên
định dạng mặt phẳng đơn (YUYV) và định dạng NV16M và NV61M đa mặt phẳng
sẽ có một mặt phẳng có data_offset khác 0 là 128 byte. Thật hiếm khi
data_offset khác 0, vì vậy đây là một tính năng hữu ích để thử nghiệm các ứng dụng.

Đầu ra video cũng sẽ tôn trọng mọi data_offset mà ứng dụng đã đặt.


Lớp phủ đầu ra
--------------

Lưu ý: lớp phủ đầu ra chủ yếu được triển khai để kiểm tra lớp phủ hiện có
Lớp phủ đầu ra V4L2 API. Liệu API này có nên được sử dụng cho trình điều khiển mới hay không
đáng nghi ngờ.

Trình điều khiển này có hỗ trợ lớp phủ đầu ra và có khả năng:

- cắt bitmap,
	- cắt danh sách (tối đa 16 hình chữ nhật)
	- sắc tố
	- nguồn chromakey
	- alpha toàn cầu
	- alpha cục bộ
	- alpha nghịch đảo cục bộ

Lớp phủ đầu ra không được hỗ trợ cho các định dạng nhiều mặt phẳng. Ngoài ra,
pixelformat của định dạng chụp và của bộ đệm khung phải là
tương tự để lớp phủ hoạt động. Nếu không VIDIOC_OVERLAY sẽ trả về lỗi.

Lớp phủ đầu ra chỉ hoạt động nếu trình điều khiển đã được cấu hình để tạo
bộ đệm khung bằng cách đặt cờ 0x10000 trong tùy chọn mô-đun node_types. các
bộ đệm khung được tạo có kích thước 720x576 và hỗ trợ ARGB 1:5:5:5 và
RGB 5:6:5.

Để thấy được tác dụng của các thao tác cắt, tạo màu hoặc alpha khác nhau,
khả năng xử lý bạn cần để bật tính năng lặp video và xem kết quả
ở phía bắt giữ. Việc sử dụng phương pháp cắt, tạo màu hoặc xử lý alpha
các khả năng sẽ làm chậm đáng kể vòng lặp video vì có rất nhiều bước kiểm tra
được thực hiện trên mỗi pixel.


CEC (Điều khiển điện tử tiêu dùng)
----------------------------------

Nếu có đầu vào HDMI thì bộ chuyển đổi CEC sẽ được tạo có
cùng số lượng cổng đầu vào. Điều này tương đương với ví dụ: một cái tivi đó
có số lượng đầu vào đó. Mỗi đầu ra HDMI cũng sẽ tạo ra một
Bộ chuyển đổi CEC được nối với cổng đầu vào tương ứng hoặc (nếu có
có nhiều đầu ra hơn đầu vào) hoàn toàn không được kết nối. Nói cách khác,
điều này tương đương với việc kết nối từng thiết bị đầu ra với một cổng đầu vào của
cái tivi. Mọi thiết bị đầu ra còn lại vẫn chưa được kết nối.

EDID mà mỗi đầu ra đọc báo cáo một địa chỉ vật lý CEC duy nhất được
dựa trên địa chỉ vật lý của EDID của đầu vào. Vì vậy, nếu EDID của
máy thu có địa chỉ vật lý A.B.0.0 thì mỗi đầu ra sẽ thấy EDID
chứa địa chỉ vật lý A.B.C.0 trong đó C là 1 cho số lượng đầu vào. Nếu
có nhiều đầu ra hơn đầu vào thì các đầu ra còn lại có bộ chuyển đổi CEC
bị vô hiệu hóa và báo cáo địa chỉ vật lý không hợp lệ.


Một số cải tiến trong tương lai
------------------------

Chỉ như một lời nhắc nhở và không theo thứ tự cụ thể:

- Thêm driver alsa ảo để test âm thanh
- Thêm thiết bị phụ ảo
- Một số hỗ trợ test video nén
- Thêm hỗ trợ để lặp đầu ra VBI thô vào đầu vào VBI thô
- Thêm hỗ trợ để lặp đầu ra VBI được cắt từ teletext thành đầu vào VBI
- Sửa lỗi đánh số thứ tự/trường khi lặp video với các trường thay thế
- Thêm hỗ trợ cho V4L2_CID_BG_COLOR cho đầu ra video
- Thêm hỗ trợ lớp phủ ARGB888: kiểm tra kênh alpha tốt hơn
- Cải thiện khả năng hỗ trợ khía cạnh pixel trong mã tpg bằng cách chuyển v4l2_fract thực
- Sử dụng khóa theo hàng đợi và/hoặc khóa trên mỗi thiết bị để cải thiện thông lượng
- Đài SDR nên sử dụng cùng 'tần số' cho các đài như bình thường
  máy thu radio và phát lại tiếng ồn nếu tần số không khớp với
  tần số trạm
- Tạo một chủ đề cho thế hệ RDS, điều này đặc biệt hữu ích cho
  Chế độ I/O "Điều khiển" RDS Rx vì có thể cập nhật các điều khiển RDS chỉ đọc
  trong thời gian thực.
- Thay đổi EDID không đợi 100 ms trước khi thiết lập tín hiệu HPD.