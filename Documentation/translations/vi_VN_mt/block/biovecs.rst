.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/biovecs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================
Biovec bất biến và vòng lặp biovec
======================================

Kent Overstreet <kmo@daterainc.com>

Kể từ ngày 3.13, biovec không bao giờ được sửa đổi sau khi tiểu sử đã được gửi.
Thay vào đó, chúng ta có một cấu trúc bvec_iter mới đại diện cho một phạm vi biovec -
trình lặp sẽ được sửa đổi khi sinh học được hoàn thành, không phải biovec.

Cụ thể hơn, mã cũ cần hoàn thành một phần tiểu sử sẽ
cập nhật bi_sector và bi_size, đồng thời nâng cấp bi_idx lên biovec tiếp theo. Nếu nó
kết thúc giữa chừng trong biovec, nó sẽ tăng bv_offset và giảm
bv_len theo số byte được hoàn thành trong biovec đó.

Trong sơ đồ mới của mọi thứ, mọi thứ phải được thay đổi để
hoàn thiện một phần tiểu sử được tách thành struct bvec_iter: bi_sector,
bi_size và bi_idx đã được chuyển đến đó; và thay vì sửa đổi bv_offset
và bv_len, struct bvec_iter có bi_bvec_done, đại diện cho số lượng
byte hoàn thành trong bvec hiện tại.

Có một loạt macro trợ giúp mới để ẩn các chi tiết đẫm máu - trong
đặc biệt, tạo ra ảo tưởng về các biovec đã hoàn thành một phần để
mã thông thường không phải xử lý bi_bvec_done.

* Mã trình điều khiển không còn đề cập trực tiếp đến biovecs nữa; bây giờ chúng tôi có
   Các macro bio_iovec() và bio_iter_iovec() trả về cấu trúc biovec theo nghĩa đen,
   được xây dựng từ biovec thô nhưng có tính đến bi_bvec_done và
   bi_size.

bio_for_each_segment() đã được cập nhật để lấy đối số bvec_iter
   thay vì số nguyên (tương ứng với bi_idx); đối với rất nhiều mã
   chuyển đổi chỉ yêu cầu thay đổi loại đối số thành
   bio_for_each_segment().

* Việc nâng cấp bvec_iter được thực hiện bằng bio_advance_iter(); bio_advance() là một
   trình bao bọc xung quanh bio_advance_iter() hoạt động trên bio->bi_iter và cả
   nâng cao tính toàn vẹn sinh học nếu có.

Có một hàm nâng cao cấp thấp hơn - bvec_iter_advance() - thực hiện
   một con trỏ tới biovec, không phải biovec; mã này được sử dụng bởi mã toàn vẹn sinh học.

Kể từ 5,12 bvec, các phân đoạn có bv_len bằng 0 không được hỗ trợ.

Tất cả những điều này mang lại cho chúng ta điều gì?
=======================

Việc có một trình vòng lặp thực sự và làm cho các biovec trở nên bất biến có một số
lợi thế:

* Trước đây, việc lặp lại bios rất khó khăn khi bạn không xử lý
   chính xác một bvec tại một thời điểm - ví dụ: bio_copy_data() trong block/bio.c,
   sao chép nội dung của tiểu sử này sang tiểu sử khác. Bởi vì biovec
   không nhất thiết phải có cùng kích thước, mã cũ rất phức tạp -
   nó phải chạy hai bios khác nhau cùng lúc, giữ cả bi_idx và
   và bù vào biovec hiện tại cho mỗi loại.

Mã mới đơn giản hơn nhiều - hãy xem. Kiểu này
   mô hình xuất hiện ở rất nhiều nơi; về cơ bản rất nhiều trình điều khiển đã mở
   mã hóa các trình vòng lặp bvec trước đây và có cách triển khai chung đáng kể
   đơn giản hóa rất nhiều mã.

* Trước đây, bất kỳ mã nào có thể cần sử dụng biovec sau khi biovec đã được
   hoàn thành (có thể để sao chép dữ liệu đi nơi khác, hoặc có thể gửi lại
   nó ở nơi khác nếu có lỗi) phải lưu toàn bộ mảng bvec
   - một lần nữa, việc này đã được thực hiện ở khá nhiều nơi.

* Biovec có thể được chia sẻ giữa nhiều bios - một bvec iter có thể đại diện cho một
   phạm vi tùy ý của một biovec hiện có, cả bắt đầu và kết thúc ở giữa chừng
   thông qua biovec. Đây là điều cho phép phân chia tùy ý một cách hiệu quả
   bios. Lưu ý rằng điều này có nghĩa là chúng tôi _chỉ_ sử dụng bi_size để xác định thời điểm chúng tôi
   đã đến cuối tiểu sử chứ không phải bi_vcnt - và macro bio_iovec() lấy
   bi_size khi xây dựng biovec.

* Việc chia bios giờ đây đã đơn giản hơn rất nhiều. bio_split() cũ thậm chí còn không hoạt động
   bios có nhiều hơn một bvec! Bây giờ, chúng ta có thể phân chia tùy ý một cách hiệu quả
   size bios - because the new bio can share the old bio's biovec.

Phải cẩn thận để đảm bảo biovec không được giải phóng trong khi biovec được phân chia
   Tuy nhiên, vẫn sử dụng nó, trong trường hợp tiểu sử ban đầu hoàn thành trước. sử dụng
   bio_chain() khi chia bios sẽ giúp ích cho việc này.

* Việc gửi tiểu sử đã hoàn thành một phần hiện hoàn toàn ổn - điều này xuất hiện
   đôi khi trong các trình điều khiển khối xếp chồng và các mã khác nhau (ví dụ: md và
   bcache) có một số cách giải quyết khó khăn cho việc này.

Trước đây, việc gửi tiểu sử đã hoàn thiện một phần sẽ có hiệu quả
   tốt đối với các thiết bị _most_, nhưng vì việc truy cập vào mảng bvec thô là
   tiêu chuẩn, không phải tất cả các trình điều khiển đều tôn trọng bi_idx và những điều đó sẽ bị hỏng. Bây giờ,
   vì tất cả các trình điều khiển _phải_ đi qua trình vòng lặp bvec - và đã được
   đã được kiểm tra để đảm bảo rằng chúng đúng như vậy - việc gửi tiểu sử đã hoàn thành một phần là
   hoàn toàn ổn.

Ý nghĩa khác:
===================

* Hầu như tất cả việc sử dụng bi_idx hiện không chính xác và đã bị xóa; thay vào đó,
   nơi mà trước đây bạn đã sử dụng bi_idx thì bây giờ bạn sẽ sử dụng bvec_iter,
   có thể chuyển nó tới một trong các macro trợ giúp.

tức là thay vì sử dụng bio_iovec_idx() (hoặc bio->bi_iovec[bio->bi_idx]), bạn
   bây giờ hãy sử dụng bio_iter_iovec(), nó nhận bvec_iter và trả về một
   struct bio_vec theo nghĩa đen - được xây dựng nhanh chóng từ biovec thô nhưng
   có tính đến bi_bvec_done (và bi_size).

* bi_vcnt không thể tin cậy hoặc dựa vào mã trình điều khiển - tức là bất cứ điều gì
   không thực sự sở hữu tiểu sử. Lý do có hai phần: thứ nhất, không phải
   thực sự cần thiết để lặp lại tiểu sử nữa - chúng tôi chỉ sử dụng bi_size.
   Thứ hai, khi nhân bản một tiểu sử và tái sử dụng (một phần) tiểu sử gốc
   biovec, để tính bi_vcnt cho bio mới, chúng ta phải lặp lại
   trên tất cả các biovec trong biovec mới - điều này thật ngớ ngẩn vì nó không cần thiết.

Vì vậy, đừng sử dụng bi_vcnt nữa.

* Giao diện hiện tại cho phép lớp khối phân chia bios khi cần thiết, vì vậy chúng tôi
   có thể loại bỏ rất nhiều sự phức tạp, đặc biệt là trong các trình điều khiển xếp chồng lên nhau. Mã
   người tạo bios sau đó có thể tạo bios ở bất kỳ kích thước nào thuận tiện và
   quan trọng hơn là các trình điều khiển xếp chồng lên nhau không phải xử lý cả tiểu sử của chính chúng
   giới hạn kích thước và giới hạn của các thiết bị cơ bản. Như vậy
   không cần phải xác định lệnh gọi lại ->merge_bvec_fn() cho từng khối riêng lẻ
   trình điều khiển.

Cách sử dụng người trợ giúp:
=================

* Chỉ có thể sử dụng những người trợ giúp sau có tên có hậu tố ZZ0000ZZ
  trên sinh học không phải BIO_CLONED. Chúng thường được sử dụng bởi mã hệ thống tập tin. Trình điều khiển
  không nên sử dụng chúng vì tiểu sử có thể đã bị chia tách trước khi nó đạt tới
  người lái xe.

::

bio_for_each_segment_all()
	bio_for_each_bvec_all()
	bio_first_bvec_all()
	bio_first_page_all()
	bio_first_folio_all()

* Những người trợ giúp sau đây lặp lại trên phân đoạn một trang. Cấu trúc đã được thông qua
  bio_vec' sẽ chứa một vectơ IO một trang trong quá trình lặp::

bio_for_each_segment()
	bio_for_each_segment_all()

* Những người trợ giúp sau lặp lại bvec nhiều trang. Cấu trúc đã được thông qua
  bio_vec' sẽ chứa vectơ IO nhiều trang trong quá trình lặp::

bio_for_each_bvec()
	bio_for_each_bvec_all()
	rq_for_each_bvec()
