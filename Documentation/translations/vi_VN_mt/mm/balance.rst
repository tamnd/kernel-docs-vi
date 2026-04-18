.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/balance.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Cân bằng bộ nhớ
================

Bắt đầu vào tháng 1 năm 2000 bởi Kanoj Sarcar <kanoj@sgi.com>

Cân bằng bộ nhớ là cần thiết cho !__GFP_HIGH và !__GFP_KSWAPD_RECLAIM vì
cũng như đối với các phân bổ không phải __GFP_IO.

Lý do đầu tiên khiến người gọi có thể tránh đòi lại là người gọi không thể
ngủ do đang giữ spinlock hoặc đang ở trong bối cảnh bị gián đoạn. Thứ hai có thể
có thể là người gọi sẵn sàng thất bại trong việc phân bổ mà không phải chịu
chi phí thu hồi trang. Điều này có thể xảy ra đối với những người có tính cơ hội cao
yêu cầu phân bổ có tùy chọn dự phòng đơn hàng 0. Trong những trường hợp như vậy,
người gọi cũng có thể muốn tránh đánh thức kswapd.

Yêu cầu phân bổ __GFP_IO được thực hiện để ngăn chặn tình trạng bế tắc hệ thống tệp.

Trong trường hợp không có yêu cầu phân bổ không thể ngủ được, điều đó có vẻ bất lợi
đang thực hiện việc cân bằng. Việc thu hồi trang có thể được khởi động một cách lười biếng, điều đó
là, chỉ khi cần thiết (hay còn gọi là bộ nhớ trống vùng là 0), thay vì thực hiện
một quá trình chủ động.

Điều đó đang được nói, hạt nhân nên cố gắng thực hiện các yêu cầu trực tiếp
các trang được ánh xạ từ nhóm được ánh xạ trực tiếp, thay vì quay trở lại
nhóm dma, để giữ cho nhóm dma luôn được lấp đầy cho các yêu cầu dma (atomic
hay không). Lập luận tương tự áp dụng cho các trang được ánh xạ trực tiếp và highmem.
OTOH, nếu có nhiều trang dma miễn phí thì nên đáp ứng
thay vào đó, các yêu cầu bộ nhớ thông thường bằng cách phân bổ một bộ nhớ từ nhóm dma
phát sinh chi phí cân bằng vùng thường xuyên.

Trong phiên bản 2.2, việc cân bằng bộ nhớ/thu hồi trang sẽ chỉ bắt đầu khi
_total_ số trang trống giảm xuống dưới 1/64 tổng bộ nhớ. Với
tỷ lệ phù hợp giữa dma và bộ nhớ thông thường, rất có thể việc cân bằng
sẽ không được thực hiện ngay cả khi vùng dma hoàn toàn trống rỗng. 2.2 có
đang chạy các máy sản xuất có kích thước bộ nhớ khác nhau và dường như
làm tốt ngay cả khi có sự hiện diện của vấn đề này. Trong 2.3, do
HIGHMEM, vấn đề này trở nên trầm trọng hơn.

Trong 2.3, cân bằng vùng có thể được thực hiện theo một trong hai cách: tùy thuộc vào
kích thước vùng (và có thể là kích thước của các khu vực cấp thấp hơn), chúng ta có thể quyết định
tại thời điểm đầu chúng ta nên nhắm đến bao nhiêu trang miễn phí trong khi cân bằng mọi
khu. Điều hay là khi cân bằng, chúng ta không cần nhìn vào kích thước
của các khu vực tầng lớp thấp hơn, điều tồi tệ là chúng ta có thể thực hiện việc cân bằng quá thường xuyên
do bỏ qua mức sử dụng có thể thấp hơn ở các khu vực hạng thấp hơn. Ngoài ra,
với một sự thay đổi nhỏ trong quy trình phân bổ, có thể giảm
macro memclass() là một đẳng thức đơn giản.

Một giải pháp khả thi khác là chúng ta chỉ cân bằng khi bộ nhớ trống
của một vùng _và_ tất cả các vùng cấp thấp hơn của nó nằm dưới 1/64 của
tổng bộ nhớ trong vùng và các vùng lớp thấp hơn của nó. Điều này sửa lỗi 2.2
vấn đề cân bằng và duy trì hành vi càng gần với hành vi 2.2 càng tốt. Ngoài ra,
thuật toán cân bằng hoạt động theo cách tương tự trên các kiến trúc khác nhau,
có số lượng và loại vùng khác nhau. Nếu chúng ta muốn có được
Thật thú vị, chúng ta có thể gán các trọng số khác nhau cho các trang miễn phí ở các vị trí khác nhau.
các khu trong tương lai.

Lưu ý rằng nếu kích thước của vùng thông thường lớn so với vùng dma,
việc xem xét các trang dma miễn phí trở nên ít quan trọng hơn trong khi
quyết định có nên cân bằng vùng thông thường hay không. Giải pháp đầu tiên
thì sẽ trở nên hấp dẫn hơn.

Bản vá được thêm vào thực hiện giải pháp thứ hai. Nó cũng "sửa" hai
vấn đề: đầu tiên, kswapd được đánh thức như trong 2.2 trong điều kiện bộ nhớ thấp
đối với phân bổ không thể ngủ được. Thứ hai, vùng HIGHMEM cũng được cân bằng,
để tạo cơ hội chiến đấu cho thay thế_with_highmem() để có được
trang HIGHMEM, cũng như để đảm bảo rằng việc phân bổ HIGHMEM không
rơi trở lại vùng thông thường. Điều này cũng đảm bảo rằng các trang HIGHMEM
không bị rò rỉ (ví dụ: trong trường hợp trang HIGHMEM nằm trong
swapcache nhưng không được ai sử dụng)

kswapd cũng cần biết về các vùng cần cân bằng. kswapd là
chủ yếu cần thiết trong tình huống không thể thực hiện được sự cân bằng,
có lẽ bởi vì tất cả các yêu cầu phân bổ đều đến từ bối cảnh intr
và tất cả các bối cảnh quá trình đang ngủ. Đối với 2.3, kswapd không thực sự
cần cân bằng vùng highmem, vì bối cảnh intr không yêu cầu
trang cao cấp. kswapd nhìn vào trườngzone_wake_kswapd trong vùng
cấu trúc để quyết định xem một vùng có cần cân bằng hay không.

Việc đánh cắp trang từ bộ nhớ tiến trình và shm được thực hiện nếu việc đánh cắp trang sẽ
giảm bớt áp lực bộ nhớ lên bất kỳ vùng nào trong nút của trang bị giảm xuống dưới
hình mờ của nó.

hình mờ[WMARK_MIN/WMARK_LOW/WMARK_HIGH]/low_on_memory/zone_wake_kswapd: Những cái này
là các trường trên mỗi vùng, được sử dụng để xác định khi nào một vùng cần được cân bằng. Khi nào
số trang nằm dưới hình mờ[WMARK_MIN], trường cuồng loạn
low_on_memory được thiết lập. Điều này vẫn được đặt cho đến khi số lượng trang miễn phí trở thành
hình mờ [WMARK_HIGH]. Khi low_on_memory được đặt, yêu cầu phân bổ trang sẽ
cố gắng giải phóng một số trang trong vùng (cung cấp GFP_WAIT được đặt trong yêu cầu).
Trực giao với điều này, là quyết định chọc kswapd để giải phóng một số trang vùng.
Quyết định đó không dựa trên độ trễ và được thực hiện khi số lượng
các trang nằm dưới hình mờ[WMARK_LOW]; trong trường hợp đó Zone_wake_kswapd cũng được đặt.


(Tốt) Những ý tưởng mà tôi đã nghe:

1. Trải nghiệm động sẽ ảnh hưởng đến việc cân bằng: số lượng yêu cầu không thành công
   đối với một vùng có thể được theo dõi và đưa vào sơ đồ cân bằng (jalvo@mbay.net)
2. Triển khai thay thế_with_highmem() giống như thay thế_with_regular() để duy trì
   trang dma. (lkd@tantalophile.demon.co.uk)
