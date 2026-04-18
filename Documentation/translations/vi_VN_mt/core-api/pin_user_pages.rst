.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/pin_user_pages.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================================================
pin_user_pages() và các cuộc gọi liên quan
=========================================================

.. contents:: :local:

Tổng quan
========

Tài liệu này mô tả các chức năng sau::

pin_user_pages()
 pin_user_pages_fast()
 pin_user_pages_remote()

Mô tả cơ bản về FOLL_PIN
=============================

FOLL_PIN và FOLL_LONGTERM là các cờ có thể được chuyển tới get_user_pages*()
Nhóm chức năng ("gup"). FOLL_PIN có những tương tác đáng kể và
sự phụ thuộc lẫn nhau với FOLL_LONGTERM, vì vậy cả hai đều được đề cập ở đây.

FOLL_PIN là nội bộ của gup, nghĩa là nó sẽ không xuất hiện trong lệnh gọi gup
các trang web. Điều này cho phép các hàm bao bọc liên quan (pin_user_pages*() và
khác) để đặt sự kết hợp chính xác của các cờ này và để kiểm tra sự cố
cũng vậy.

Mặt khác, FOLL_LONGTERM được phép đặt tại các trang gọi gup.
Điều này là để tránh tạo ra một số lượng lớn các hàm bao bọc để che phủ
tất cả các kết hợp của get*(), pin*(), FOLL_LONGTERM, v.v. Ngoài ra,
API pin_user_pages*() APIs are clearly distinct from the get_user_pages*(), vì vậy
đó là đường phân chia tự nhiên và là điểm hay để thực hiện các lệnh gọi trình bao bọc riêng biệt.
Nói cách khác, hãy sử dụng pin_user_pages*() cho các trang được ghim DMA và
get_user_pages*() cho các trường hợp khác. Có năm trường hợp được mô tả sau này trong
tài liệu này, để làm rõ hơn khái niệm đó.

FOLL_PIN và FOLL_GET loại trừ lẫn nhau cho một lệnh gọi gup nhất định. Tuy nhiên,
nhiều chủ đề và các trang web cuộc gọi có thể tự do ghim các trang cấu trúc giống nhau, thông qua cả hai
FOLL_PIN và FOLL_GET. Chỉ có trang web cuộc gọi cần chọn một hoặc
khác, không phải (các) trang cấu trúc.

Việc triển khai FOLL_PIN gần giống như FOLL_GET, ngoại trừ FOLL_PIN
sử dụng một kỹ thuật đếm tham chiếu khác.

FOLL_PIN là điều kiện tiên quyết để có được FOLL_LONGTERM. Một cách khác để nói điều đó là,
FOLL_LONGTERM là trường hợp cụ thể, hạn chế hơn của FOLL_PIN.

Những cờ nào được đặt bởi mỗi trình bao bọc
===================================

Đối với các hàm pin_user_pages*() này, FOLL_PIN được HOẶC với bất kỳ gup nào
cờ người gọi cung cấp. Người gọi được yêu cầu chuyển vào một cấu trúc không null
pages* mảng và sau đó hàm sẽ ghim các trang bằng cách tăng từng trang bằng một giá trị đặc biệt
giá trị: GUP_PIN_COUNTING_BIAS.

Đối với các folio lớn, sơ đồ GUP_PIN_COUNTING_BIAS không được sử dụng. Thay vào đó,
không gian bổ sung có sẵn trong folio cấu trúc được sử dụng để lưu trữ
đếm trực tiếp.

Cách tiếp cận này dành cho các tờ giấy lớn tránh được các vấn đề về giới hạn trên khi đếm
được thảo luận dưới đây. Những hạn chế đó sẽ trở nên trầm trọng hơn
nghiêm trọng bởi các trang lớn, bởi vì mỗi trang đuôi sẽ thêm một lần đếm lại vào
trang đầu. Và trên thực tế, thử nghiệm đã tiết lộ rằng, nếu không có số lượng pin riêng biệt
trường, số lần đếm lại tràn đã được nhìn thấy trong một số thử nghiệm căng thẳng trang lớn.

Điều này cũng có nghĩa là các trang lớn và folio lớn không bị ảnh hưởng
khỏi vấn đề dương tính giả được đề cập dưới đây.::

chức năng
 --------
 pin_user_pages FOLL_PIN luôn được thiết lập nội bộ bởi chức năng này.
 pin_user_pages_fast FOLL_PIN luôn được thiết lập nội bộ bởi chức năng này.
 pin_user_pages_remote FOLL_PIN luôn được thiết lập nội bộ bởi chức năng này.

Đối với các hàm get_user_pages*() này, FOLL_GET thậm chí có thể không được chỉ định.
Hành vi phức tạp hơn một chút so với ở trên. Nếu FOLL_GET là ZZ0000ZZ được chỉ định,
nhưng người gọi đã truyền vào một mảng cấu trúc các trang* không có giá trị rỗng, thì hàm
đặt FOLL_GET cho bạn và tiến hành ghim các trang bằng cách tăng số tiền hoàn lại
của mỗi trang bằng +1.::

chức năng
 --------
 get_user_pages FOLL_GET đôi khi được đặt nội bộ bởi chức năng này.
 get_user_pages_fast FOLL_GET đôi khi được thiết lập nội bộ bởi chức năng này.
 get_user_pages_remote FOLL_GET đôi khi được thiết lập nội bộ bởi chức năng này.

Theo dõi các trang được ghim bởi dma
=========================

Một số hạn chế thiết kế chính và giải pháp để theo dõi được ghim bởi dma
trang:

* Cần có số lượng tham chiếu thực tế trên mỗi trang cấu trúc. Điều này là do
  nhiều quy trình có thể ghim và bỏ ghim một trang.

* Kết quả dương tính giả (báo cáo rằng một trang được ghim bằng dma, trong khi thực tế không phải vậy)
  có thể chấp nhận được, nhưng âm tính giả thì không.

* trang cấu trúc có thể không được tăng kích thước cho việc này và tất cả các trường đều đã có sẵn
  đã sử dụng.

* Với những điều trên, chúng ta có thể nạp chồng trường page->_refcount bằng cách sử dụng, sắp xếp,
  các bit trên trong trường đó cho số lượng được ghim bằng dma. "Đại loại", có nghĩa là,
  thay vì chia trang->_refcount thành các trường bit, chúng tôi chỉ cần thêm một phương tiện-
  giá trị lớn (GUP_PIN_COUNTING_BIAS, ban đầu được chọn là 1024: 10 bit) thành
  trang->_refcount. Điều này cung cấp hành vi mờ: nếu một trang có get_page() được gọi
  trên đó 1024 lần, khi đó nó sẽ xuất hiện với một số lượng được ghim bằng dma.
  Và một lần nữa, điều đó có thể chấp nhận được.

Điều này cũng dẫn đến những hạn chế: chỉ có 31-10==21 bit có sẵn cho một
bộ đếm tăng 10 bit mỗi lần.

* Vì hạn chế đó, việc xử lý đặc biệt được áp dụng cho các trang không
  khi sử dụng FOLL_PIN.  Chúng tôi chỉ giả vờ ghim một trang số 0 - chúng tôi không thay đổi trang đó
  hoàn lại tiền hoặc đếm số pin (nó là vĩnh viễn, vì vậy không cần thiết).  các
  chức năng bỏ ghim cũng không làm được gì với một trang không có gì.  Đây là
  minh bạch đối với người gọi.

* Người gọi phải yêu cầu cụ thể "theo dõi các trang được ghim bằng dma". Ở nơi khác
  nói cách khác, chỉ gọi get_user_pages() sẽ không đủ; một tập hợp các chức năng mới,
  pin_user_page() và các nội dung liên quan, phải được sử dụng.

FOLL_PIN, FOLL_GET, FOLL_LONGTERM: khi nào nên sử dụng cờ nào
==========================================================

Cảm ơn Jan Kara, Vlastimil Babka và một số người -mm khác đã mô tả
những loại này:

CASE 1: IO trực tiếp (DIO)
-----------------------
Có các tham chiếu GUP đến các trang đang phân phối
như bộ đệm DIO. Những bộ đệm này cần thiết trong một thời gian tương đối ngắn (vì vậy chúng
không phải là "lâu dài"). Không có sự đồng bộ hóa đặc biệt nào với folio_mkclean() hoặc
munmap() được cung cấp. Do đó, các cờ được đặt tại trang cuộc gọi là: ::

FOLL_PIN

...but rather than setting FOLL_PIN directly, call sites should use one of
các quy trình pin_user_pages*() thiết lập FOLL_PIN.

CASE 2: RDMA
------------
Có các tham chiếu GUP tới các trang đang được coi là DMA
bộ đệm. Những bộ đệm này cần thiết trong thời gian dài ("dài hạn"). Không có gì đặc biệt
đồng bộ hóa với folio_mkclean() hoặc munmap() được cung cấp. Vì vậy, cờ
để đặt tại trang cuộc gọi là: ::

FOLL_PIN | FOLL_LONGTERM

NOTE: Một số trang, chẳng hạn như trang DAX, không thể ghim bằng ghim dài hạn. Đó là
bởi vì các trang DAX không có bộ đệm trang riêng và do đó việc "ghim" ngụ ý
khóa các khối hệ thống tệp chưa được hỗ trợ theo cách đó.

.. _mmu-notifier-registration-case:

CASE 3: Đăng ký trình thông báo MMU, có hoặc không có phần cứng lỗi trang
-------------------------------------------------------------------------
Trình điều khiển thiết bị có thể ghim các trang thông qua get_user_pages*() và đăng ký mmu
cuộc gọi lại của trình thông báo cho phạm vi bộ nhớ. Sau đó, khi nhận được thông báo
gọi lại "phạm vi không hợp lệ", ngăn thiết bị sử dụng phạm vi và bỏ ghim
các trang. Có thể có các phương án khả thi khác, chẳng hạn như một cách rõ ràng
đồng bộ hóa với IO đang chờ xử lý, điều đó thực hiện được điều tương tự.

Hoặc, nếu phần cứng hỗ trợ lỗi trang có thể phát lại thì trình điều khiển thiết bị có thể
tránh ghim hoàn toàn (điều này là lý tưởng), như sau: đăng ký trình thông báo mmu
gọi lại như trên nhưng thay vì dừng thiết bị và bỏ ghim trong
gọi lại, chỉ cần xóa phạm vi khỏi bảng trang của thiết bị.

Dù bằng cách nào, miễn là trình điều khiển bỏ ghim các trang khi gọi lại trình thông báo mmu,
sau đó có sự đồng bộ hóa phù hợp với cả hệ thống tập tin và mm
(folio_mkclean(), munmap(), v.v.). Do đó, không cần thiết phải đặt cờ.

CASE 4: Chỉ ghim để thao tác với cấu trúc trang
-------------------------------------------------
Nếu chỉ cấu trúc dữ liệu trang (ngược lại với nội dung bộ nhớ thực tế mà một trang
đang theo dõi) bị ảnh hưởng thì các cuộc gọi GUP bình thường là đủ và không có cờ
cần phải được thiết lập.

CASE 5: Ghim để ghi dữ liệu trong trang
-------------------------------------------------------------
Mặc dù cả DMA lẫn Direct IO đều không liên quan nhưng chỉ là một trường hợp đơn giản về "pin,
ghi vào dữ liệu của trang, bỏ ghim" có thể gây ra sự cố. Trường hợp 5 có thể coi là
siêu tập hợp của Trường hợp 1, cộng với Trường hợp 2, cộng với bất kỳ thứ gì gọi ra mẫu đó. trong
nói cách khác, nếu mã không phải là Trường hợp 1 hay Trường hợp 2, nó vẫn có thể yêu cầu
FOLL_PIN, dành cho các mẫu như thế này:

Đúng (sử dụng các cuộc gọi FOLL_PIN):
    pin_user_pages()
    ghi vào dữ liệu trong các trang
    bỏ ghim_user_pages()

INCORRECT (sử dụng các cuộc gọi FOLL_GET):
    get_user_pages()
    ghi vào dữ liệu trong các trang
    đặt_page()

folio_maybe_dma_pinned(): toàn bộ ý nghĩa của việc ghim
====================================================

Mục đích chung của việc đánh dấu các folio là "DMA-pinned" hoặc "gup-pinned" là để có thể
để truy vấn "đây có phải là folio DMA được ghim không?" Điều đó cho phép mã như folio_mkclean()
(và mã ghi lại hệ thống tệp nói chung) để đưa ra quyết định sáng suốt về
phải làm gì khi một folio không thể được ánh xạ do các chân như vậy.

Phải làm gì trong những trường hợp đó là chủ đề của hàng loạt cuộc thảo luận kéo dài nhiều năm
và tranh luận (xem phần Tài liệu tham khảo ở cuối tài liệu này). Đó là vật phẩm TODO
ở đây: điền thông tin chi tiết khi đã xong. Trong khi đó, có thể nói là an toàn
rằng có sẵn cái này: ::

bool nội tuyến tĩnh folio_maybe_dma_pinned(struct folio *folio)

...is a prerequisite to solving the long-running gup+DMA problem.

Một cách nghĩ khác về FOLL_GET, FOLL_PIN và FOLL_LONGTERM
===================================================================

Một cách nghĩ khác về những lá cờ này là sự tiến triển của các hạn chế:
FOLL_GET dùng để thao tác trên trang cấu trúc mà không ảnh hưởng đến dữ liệu
trang cấu trúc đề cập đến. FOLL_PIN là ZZ0000ZZ dành cho FOLL_GET và dành cho
ghim ngắn hạn trên các trang có dữ liệu ZZ0001ZZ được truy cập. Như vậy, FOLL_PIN là
một hình thức ghim "nghiêm khắc hơn". Và cuối cùng, FOLL_LONGTERM còn hơn thế nữa
trường hợp hạn chế có FOLL_PIN làm điều kiện tiên quyết: trường hợp này dành cho các trang
sẽ được ghim lâu dài và dữ liệu của ai sẽ được truy cập.

Kiểm tra đơn vị
============
Tập tin này::

công cụ/kiểm tra/selftests/mm/gup_test.c

có các lệnh gọi mới sau đây để thực hiện các hàm bao bọc pin*() mới:

* PIN_FAST_BENCHMARK (./gup_test -a)
* PIN_BASIC_TEST (./gup_test -b)

Bạn có thể theo dõi tổng số trang được ghim bằng dma đã được mua và phát hành
kể từ khi hệ thống được khởi động, thông qua hai mục /proc/vmstat mới: ::

/proc/vmstat/nr_foll_pin_acquired
    /proc/vmstat/nr_foll_pin_released

Trong điều kiện bình thường, hai giá trị này sẽ bằng nhau trừ khi có bất kỳ
các chân [R]DMA dài hạn tại chỗ hoặc trong quá trình chuyển đổi ghim/bỏ ghim.

*nr_foll_pin_acquired: Đây là số chân logic đã được
  có được kể từ khi hệ thống được bật nguồn. Đối với các trang lớn, trang đầu là
  được ghim một lần cho mỗi trang (trang đầu và mỗi trang đuôi) trong trang lớn.
  Điều này tuân theo cùng loại hành vi mà get_user_pages() sử dụng cho các
  trang: trang đầu được tính lại một lần cho mỗi trang đuôi hoặc trang đầu trong trang lớn
  trang, khi get_user_pages() được áp dụng cho một trang lớn.

* nr_foll_pin_released: Số lượng chân logic đã được giải phóng kể từ đó
  hệ thống đã được bật nguồn. Lưu ý rằng các trang được phát hành (bỏ ghim) trên một
  Độ chi tiết của PAGE_SIZE, ngay cả khi mã pin ban đầu được áp dụng cho một trang lớn.
  Do hành vi đếm số pin được mô tả ở trên trong "nr_foll_pin_acquired",
  kế toán cân đối nên sau khi thực hiện việc này::

pin_user_pages(huge_page);
    cho (mỗi trang trong Huge_page)
        unpin_user_page(trang);

...the following is expected::

    nr_foll_pin_released == nr_foll_pin_acquired

(...trừ khi nó đã mất cân bằng do chân RDMA dài hạn đang ở trong
nơi.)

Chẩn đoán khác
=================

dump_page() đã được cải tiến một chút để xử lý các thao tác đếm mới này
các lĩnh vực và để báo cáo tốt hơn về các folio lớn nói chung.  Cụ thể,
đối với những tờ giấy lớn, số lượng pin chính xác sẽ được báo cáo.

Tài liệu tham khảo
==========

* ZZ0000ZZ
* ZZ0001ZZ
* ZZ0002ZZ
* ZZ0003ZZ

John Hubbard, tháng 10 năm 2019