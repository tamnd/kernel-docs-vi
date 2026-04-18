.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/folio_queue.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
Hàng đợi Folio
==============

:Tác giả: David Howells <dhowells@redhat.com>

.. Contents:

 * Overview
 * Initialisation
 * Adding and removing folios
 * Querying information about a folio
 * Querying information about a folio_queue
 * Folio queue iteration
 * Folio marks
 * Lockless simultaneous production/consumption issues


Tổng quan
=========

Cấu trúc folio_queue tạo thành một phân đoạn duy nhất trong danh sách các folio được phân đoạn
có thể được sử dụng để tạo thành bộ đệm I/O.  Như vậy, danh sách có thể được lặp lại
sử dụng loại ITER_FOLIOQ iov_iter.

Các thành viên có thể truy cập công khai của cấu trúc là::

cấu trúc folio_queue {
		struct folio_queue *next;
		struct folio_queue *prev;
		...
	};

Một cặp con trỏ được cung cấp, ZZ0000ZZ và ZZ0001ZZ, trỏ tới
các phân đoạn ở hai bên của phân đoạn được truy cập.  Trong khi đây là một
danh sách liên kết đôi, nó không phải là danh sách vòng tròn; bên ngoài
con trỏ anh chị em trong phân đoạn đầu cuối phải là NULL.

Mỗi phân đoạn trong danh sách cũng lưu trữ:

* một chuỗi các con trỏ folio được sắp xếp theo thứ tự,
 * kích thước của mỗi folio và
 * ba dấu 1 bit trên mỗi tờ,

nhưng những thứ này không nên được truy cập trực tiếp vì cấu trúc dữ liệu cơ bản có thể
thay đổi, mà nên sử dụng các chức năng truy cập được nêu dưới đây.

Cơ sở này có thể được truy cập bằng cách::

#include <linux/folio_queue.h>

và sử dụng iterator::

#include <linux/uio.h>


Khởi tạo
==============

Một phân đoạn nên được khởi tạo bằng cách gọi::

void folioq_init(struct folio_queue *folioq);

với một con trỏ tới đoạn được khởi tạo.  Lưu ý rằng điều này sẽ không
nhất thiết phải khởi tạo tất cả các con trỏ folio, vì vậy phải cẩn thận kiểm tra
số lượng folio được thêm vào.


Thêm và xóa folio
==========================

Folios có thể được đặt ở vị trí chưa sử dụng tiếp theo trong cấu trúc phân đoạn bằng cách gọi một
của::

unsigned int folioq_append(struct folio_queue *folioq,
				   struct folio *folio);

unsigned int folioq_append_mark(struct folio_queue *folioq,
					struct folio *folio);

Cả hai chức năng đều cập nhật số lượng folio được lưu trữ, lưu trữ folio và ghi chú nó
kích thước.  Chức năng thứ hai cũng đặt dấu đầu tiên cho folio được thêm vào.  Cả hai
các hàm trả về số lượng vị trí được sử dụng.  [!] Lưu ý rằng không có nỗ lực nào được thực hiện
để kiểm tra xem dung lượng không bị vượt quá và danh sách sẽ không được gia hạn
tự động.

Một folio có thể được cắt bỏ bằng cách gọi::

void folioq_clear(struct folio_queue *folioq, unsigned int slot);

Thao tác này sẽ xóa vị trí trong mảng và cũng xóa tất cả các dấu cho folio đó,
nhưng không thay đổi số lượng folio - vì vậy những lần truy cập vào vị trí đó trong tương lai phải kiểm tra
nếu khe cắm bị chiếm dụng.


Truy vấn thông tin về một folio
==================================

Thông tin về folio trong một vị trí cụ thể có thể được truy vấn bởi
chức năng sau::

cấu trúc folio *folioq_folio(const struct folio_queue *folioq,
				   khe int không dấu);

Nếu một folio chưa được đặt vào vị trí đó, điều này có thể mang lại một kết quả không xác định
con trỏ.  Kích thước của folio trong một khe có thể được truy vấn bằng một trong::

unsigned int folioq_folio_order(const struct folio_queue *folioq,
					khe int không dấu);

size_t folioq_folio_size(const struct folio_queue *folioq,
				 khe int không dấu);

Hàm đầu tiên trả về kích thước dưới dạng thứ tự và hàm thứ hai trả về số lượng
byte.


Truy vấn thông tin về folio_queue
========================================

Thông tin có thể được truy xuất về một phân đoạn cụ thể bằng cách sau
chức năng::

unsigned int folioq_nr_slots(const struct folio_queue *folioq);

unsigned int folioq_count(struct folio_queue *folioq);

bool folioq_full(struct folio_queue *folioq);

Hàm đầu tiên trả về dung lượng tối đa của một phân đoạn.  Nó không được
giả định rằng điều này sẽ không khác nhau giữa các phân khúc.  Thứ hai trả về số
số folio được thêm vào một phân đoạn và phần thứ ba là cách viết tắt để cho biết liệu
phân khúc đã được lấp đầy công suất.

Không phải là số lượng và độ đầy đủ không bị ảnh hưởng bởi việc xóa các folio khỏi
phân khúc.  Đây là thông tin thêm về việc cho biết có bao nhiêu vị trí trong mảng đã được
được khởi tạo và nó giả định rằng các vị trí sẽ không được sử dụng lại mà thay vào đó là phân đoạn
sẽ bị loại bỏ khi hàng đợi được sử dụng.


Dấu folio
===========

Các folio trong hàng đợi cũng có thể được gán điểm cho chúng.  Những dấu hiệu này có thể
được sử dụng để ghi chú thông tin chẳng hạn như nếu một folio cần folio_put() gọi nó.
Có ba điểm có sẵn để đặt cho mỗi folio.

Các dấu hiệu có thể được thiết lập bởi::

void folioq_mark(struct folio_queue *folioq, unsigned int slot);
	void folioq_mark2(struct folio_queue *folioq, unsigned int slot);

Đã xóa bởi::

void folioq_unmark(struct folio_queue *folioq, unsigned int slot);
	void folioq_unmark2(struct folio_queue *folioq, unsigned int slot);

Và các dấu hiệu có thể được truy vấn bởi::

bool folioq_is_marked(const struct folio_queue *folioq, unsigned int slot);
	bool folioq_is_marked2(const struct folio_queue *folioq, unsigned int slot);

Các nhãn hiệu có thể được sử dụng cho bất kỳ mục đích nào và API này không giải thích được.


Lặp lại hàng đợi Folio
======================

Một danh sách các phân đoạn có thể được lặp lại bằng cách sử dụng tiện ích I/O iterator bằng cách sử dụng
một trình vòng lặp ZZ0000ZZ thuộc loại ZZ0001ZZ.  Trình vòng lặp có thể là
được khởi tạo với::

void iov_iter_folio_queue(struct iov_iter *i, hướng int không dấu,
				  const struct folio_queue *folioq,
				  unsigned int first_slot, unsigned int offset,
				  số lượng size_t);

Điều này có thể được yêu cầu bắt đầu tại một phân đoạn, vị trí và độ lệch cụ thể trong một
xếp hàng.  Các hàm lặp của iov sẽ đi theo các con trỏ tiếp theo khi tiến lên
và các con trỏ trước khi hoàn nguyên khi cần thiết.


Các vấn đề về sản xuất/tiêu thụ đồng thời không khóa
====================================================

Nếu được quản lý hợp lý, danh sách này có thể được nhà sản xuất mở rộng ở phần đầu
và được người tiêu dùng rút ngắn đồng thời ở phần cuối mà không cần
để lấy ổ khóa.  Trình lặp ITER_FOLIOQ chèn các rào cản thích hợp để hỗ trợ
với điều này.

Phải cẩn thận khi đồng thời tạo và sử dụng danh sách.  Nếu
đã đạt đến phân khúc cuối cùng và các folio mà nó đề cập đến hoàn toàn được tiêu thụ bởi
các trình vòng lặp IOV, cấu trúc iov_iter sẽ được trỏ đến đoạn cuối cùng
với số slot bằng với dung lượng của đoạn đó.  Trình vòng lặp sẽ
cố gắng tiếp tục từ đây nếu có sẵn một phân khúc khác khi nó được
được sử dụng lại, nhưng phải cẩn thận kẻo đoạn đó bị xóa và giải phóng bởi
người tiêu dùng trước khi vòng lặp được nâng cao.

Khuyến cáo rằng hàng đợi luôn chứa ít nhất một đoạn, ngay cả khi
phân khúc đó chưa bao giờ được lấp đầy hoặc đã được chi tiêu hoàn toàn.  Điều này ngăn cản sự
con trỏ đầu và đuôi không bị sụp đổ.


Tham khảo chức năng API
=======================

.. kernel-doc:: include/linux/folio_queue.h