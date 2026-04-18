.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/iomap/operations.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _iomap_operations:

..
        Dumb style notes to maintain the author's sanity:
        Please try to start sentences on separate lines so that
        sentence changes don't bleed colors in diff.
        Heading decorations are documented in sphinx.rst.

=============================
Hoạt động tập tin được hỗ trợ
=============================

.. contents:: Table of Contents
   :local:

Dưới đây là cuộc thảo luận về các thao tác tệp cấp cao mà iomap
dụng cụ.

I/O được đệm
============

I/O được đệm là đường dẫn I/O tệp mặc định trong Linux.
Nội dung tệp được lưu trữ trong bộ nhớ ("pagecache") để đáp ứng việc đọc và
viết.
Bộ đệm bẩn sẽ được ghi lại vào đĩa tại một thời điểm nào đó có thể
buộc thông qua ZZ0000ZZ và các biến thể.

iomap thực hiện gần như tất cả việc quản lý folio và pagecache mà
các hệ thống tập tin phải tự triển khai theo mô hình I/O cũ.
Điều này có nghĩa là hệ thống tập tin không cần biết chi tiết về việc phân bổ,
ánh xạ, quản lý trạng thái cập nhật và trạng thái bẩn hoặc ghi lại bộ đệm trang
folio.
Theo mô hình I/O cũ, việc này được quản lý rất kém hiệu quả với
danh sách liên kết của các đầu bộ đệm thay vì các ảnh bitmap trên mỗi danh mục mà iomap
công dụng.
Trừ khi hệ thống tập tin chọn tham gia một cách rõ ràng vào các đầu bộ đệm, chúng sẽ không
được sử dụng, điều này làm cho I/O được đệm hiệu quả hơn nhiều và bộ nhớ đệm trang
người bảo trì hạnh phúc hơn nhiều.

ZZ0000ZZ
-----------------------------------

Các hàm iomap sau đây có thể được tham chiếu trực tiếp từ
Cấu trúc hoạt động không gian địa chỉ:

* ZZ0000ZZ
 * ZZ0001ZZ
 * ZZ0002ZZ
 * ZZ0003ZZ

Các hoạt động không gian địa chỉ sau đây có thể được gói gọn dễ dàng:

* ZZ0000ZZ
 * ZZ0001ZZ
 * ZZ0002ZZ
 * ZZ0003ZZ
 * ZZ0004ZZ

ZZ0000ZZ
--------------------------

.. code-block:: c

 struct iomap_write_ops {
     struct folio *(*get_folio)(struct iomap_iter *iter, loff_t pos,
                                unsigned len);
     void (*put_folio)(struct inode *inode, loff_t pos, unsigned copied,
                       struct folio *folio);
     bool (*iomap_valid)(struct inode *inode, const struct iomap *iomap);
     int (*read_folio_range)(const struct iomap_iter *iter,
     			struct folio *folio, loff_t pos, size_t len);
 };

iomap gọi các chức năng này:

- ZZ0000ZZ: Được gọi để cấp phát và trả về một tham chiếu đang hoạt động cho
    một folio bị khóa trước khi bắt đầu viết.
    Nếu chức năng này không được cung cấp, iomap sẽ gọi
    ZZ0001ZZ.
    Điều này có thể được sử dụng cho ZZ0002ZZ
    cho một bài viết.

- ZZ0000ZZ: Được gọi để mở khóa và đặt folio sau pagecache
    hoạt động hoàn tất.
    Nếu chức năng này không được cung cấp, iomap sẽ ZZ0001ZZ và
    ZZ0002ZZ của riêng nó.
    Điều này có thể được sử dụng cho ZZ0004ZZ
    được thiết lập bởi ZZ0003ZZ.

- ZZ0000ZZ: Hệ thống tập tin có thể không giữ các khóa giữa
    ZZ0001ZZ và ZZ0002ZZ vì hoạt động của pagecache
    có thể khóa folio, lỗi trên các trang trong không gian người dùng, bắt đầu viết lại
    để lấy lại bộ nhớ hoặc tham gia vào các hành động tốn thời gian khác.
    Nếu dữ liệu ánh xạ không gian của một tập tin có thể thay đổi được thì có thể
    ánh xạ cho một folio pagecache cụ thể có thể ZZ0003ZZ
    để phân bổ, cài đặt và khóa folio đó.

Đối với pagecache, các cuộc đua có thể xảy ra nếu việc ghi lại không diễn ra
    ZZ0000ZZ hoặc ZZ0001ZZ và cập nhật thông tin bản đồ.
    Các cuộc đua cũng có thể xảy ra nếu hệ thống tập tin cho phép ghi đồng thời.
    Đối với các tệp như vậy, ánh xạ ZZ0002ZZ sẽ được xác nhận lại sau folio
    lock đã được lấy để iomap có thể quản lý folio một cách chính xác.

fsdax không cần xác nhận lại này vì không có phản hồi
    và không hỗ trợ cho các phạm vi bất thành văn.

Các hệ thống tập tin thuộc loại chủng tộc này phải cung cấp một
    Chức năng ZZ0000ZZ để quyết định xem ánh xạ có còn hợp lệ hay không.
    Nếu ánh xạ không hợp lệ, ánh xạ sẽ được lấy mẫu lại.

Để hỗ trợ đưa ra quyết định hợp lệ, hệ thống tập tin
    Chức năng ZZ0000ZZ có thể thiết lập ZZ0001ZZ
    đồng thời nó điền vào các trường iomap khác.
    Việc triển khai cookie xác thực đơn giản là một bộ đếm trình tự.
    Nếu hệ thống tập tin chạm vào bộ đếm trình tự mỗi lần nó sửa đổi
    bản đồ phạm vi của inode, nó có thể được đặt trong ZZ0002ZZ trong ZZ0003ZZ.
    Nếu giá trị trong cookie được tìm thấy khác với giá trị
    hệ thống tập tin giữ khi ánh xạ được chuyển trở lại
    ZZ0004ZZ thì iomap sẽ được coi là cũ và
    xác thực không thành công.

- ZZ0000ZZ: Được gọi để đọc đồng bộ trong phạm vi sẽ
    được viết cho. Nếu chức năng này không được cung cấp, iomap sẽ mặc định là
    gửi yêu cầu đọc tiểu sử.

Các cờ ZZ0000ZZ này rất quan trọng đối với I/O được đệm bằng iomap:

* ZZ0000ZZ: Bật ZZ0001ZZ.

* ZZ0000ZZ: Bật ZZ0001ZZ.

ZZ0000ZZ
--------------------------

.. code-block:: c

 struct iomap_read_ops {
     int (*read_folio_range)(const struct iomap_iter *iter,
                             struct iomap_read_folio_ctx *ctx, size_t len);
     void (*submit_read)(struct iomap_read_folio_ctx *ctx);
 };

iomap gọi các chức năng này:

- ZZ0000ZZ: Gọi để đọc trong phạm vi. Điều này phải được cung cấp
    bởi người gọi. Nếu điều này thành công, iomap_finish_folio_read() phải được gọi
    sau khi phạm vi được đọc vào, bất kể việc đọc thành công hay
    thất bại.

- ZZ0000ZZ: Gửi mọi yêu cầu đọc đang chờ xử lý. Chức năng này là
    tùy chọn.

Trạng thái mỗi Folio nội bộ
---------------------------

Nếu kích thước fsblock khớp với kích thước của folio pagecache, thì nó được giả định
rằng tất cả các hoạt động I/O của đĩa sẽ hoạt động trên toàn bộ folio.
Bản cập nhật (nội dung bộ nhớ ít nhất cũng mới như nội dung trên đĩa) và
trạng thái bẩn (nội dung bộ nhớ mới hơn nội dung trên đĩa) của
folio là tất cả những gì cần thiết cho trường hợp này.

Nếu kích thước fsblock nhỏ hơn kích thước của folio pagecache, iomap
theo dõi trạng thái cập nhật trên mỗi fsblock và trạng thái bẩn.
Điều này cho phép iomap xử lý cả "bs < ps" ZZ0000ZZ
và các folio lớn trong bộ đệm trang.

iomap theo dõi nội bộ hai bit trạng thái trên mỗi fsblock:

* ZZ0000ZZ: iomap sẽ cố gắng cập nhật đầy đủ các folio.
   Nếu có lỗi đọc (trước), các fsblock đó sẽ không được đánh dấu
   cập nhật.
   Bản thân folio sẽ được đánh dấu cập nhật khi tất cả các fsblock trong
   folio được cập nhật.

* ZZ0000ZZ: iomap sẽ đặt trạng thái bẩn cho mỗi khối khi chương trình
   ghi vào tập tin.
   Bản thân folio sẽ bị đánh dấu bẩn khi có bất kỳ fsblock nào trong
   folio bị bẩn.

iomap cũng theo dõi số lượng IO đọc và ghi đĩa trong
chuyến bay.
Cấu trúc này có trọng lượng nhẹ hơn nhiều so với ZZ0000ZZ
bởi vì chỉ có một cho mỗi folio và chi phí cho mỗi fsblock là hai
bit so với 104 byte.

Các hệ thống tập tin muốn bật các folio lớn trong bộ nhớ đệm trang nên gọi
ZZ0000ZZ khi khởi tạo incore inode.

Đọc trước và đọc vào bộ đệm
----------------------------

Hàm ZZ0000ZZ bắt đầu đọc trước bộ đệm trang.
Hàm ZZ0001ZZ đọc giá trị của một folio dữ liệu vào
bộ đệm trang.
Đối số ZZ0002ZZ cho ZZ0003ZZ sẽ được đặt thành 0.
Pagecache lấy bất kỳ khóa nào nó cần trước khi gọi
hệ thống tập tin.

Cả ZZ0000ZZ và ZZ0001ZZ đều vượt qua ZZ0002ZZ:

.. code-block:: c

 struct iomap_read_folio_ctx {
    const struct iomap_read_ops *ops;
    struct folio *cur_folio;
    struct readahead_control *rac;
    void *read_ctx;
 };

ZZ0000ZZ phải đặt:
 * ZZ0001ZZ và ZZ0002ZZ

ZZ0000ZZ phải đặt:
 * ZZ0001ZZ và ZZ0002ZZ

ZZ0000ZZ và ZZ0001ZZ là tùy chọn. ZZ0002ZZ được sử dụng để
chuyển bất kỳ dữ liệu tùy chỉnh nào mà người gọi cần có thể truy cập được trong lệnh gọi lại của ops cho
đọc hoàn thành.

Viết vào bộ đệm
---------------

Hàm ZZ0000ZZ ghi ZZ0001ZZ vào
pagecache.
ZZ0002ZZ hoặc ZZ0003ZZ | ZZ0004ZZ sẽ được thông qua dưới dạng
đối số ZZ0005ZZ thành ZZ0006ZZ.
Người gọi thường sử dụng ZZ0007ZZ ở chế độ chia sẻ hoặc độc quyền
trước khi gọi hàm này.

Lỗi ghi mmap
~~~~~~~~~~~~~~~~~

Hàm ZZ0000ZZ xử lý lỗi ghi vào folio trong
bộ đệm trang.
ZZ0001ZZ sẽ được chuyển làm đối số ZZ0002ZZ
tới ZZ0003ZZ.
Người gọi thường sử dụng mmap ZZ0004ZZ ở chế độ chia sẻ hoặc
chế độ độc quyền trước khi gọi chức năng này.

Lỗi ghi vào bộ đệm
~~~~~~~~~~~~~~~~~~~~~~~

Sau khi ghi ngắn vào bộ đệm trang, các vùng không được ghi sẽ không được ghi
trở nên bẩn thỉu.
Hệ thống tập tin phải sắp xếp thành ZZ0004ZZ
chẳng hạn ZZ0005ZZ
bởi vì việc viết lại sẽ không tiêu tốn việc đặt chỗ.
ZZ0000ZZ có thể được gọi từ một
Chức năng ZZ0001ZZ để tìm tất cả các khu vực sạch của folios
lưu vào bộ nhớ đệm bản đồ delalloc mới (ZZ0002ZZ).
Phải mất ZZ0003ZZ.

Hệ thống tập tin phải cung cấp hàm ZZ0000ZZ để được gọi
mỗi phạm vi tập tin ở trạng thái này.
Chức năng này phải ZZ0001ZZ loại bỏ việc đặt trước phân bổ bị trì hoãn, trong
trường hợp một luồng khác chạy đua với luồng hiện tại ghi thành công
đến cùng một khu vực và kích hoạt ghi lại để xóa dữ liệu bẩn ra
đĩa.

Zeroing cho hoạt động tập tin
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hệ thống tập tin có thể gọi ZZ0000ZZ để thực hiện việc zeroing
pagecache dành cho các thao tác tệp không bị cắt bớt và không được căn chỉnh theo
kích thước fsblock.
ZZ0001ZZ sẽ được chuyển làm đối số ZZ0002ZZ cho
ZZ0003ZZ.
Người gọi thường giữ ZZ0004ZZ và ZZ0005ZZ độc quyền
mode trước khi gọi chức năng này.

Hủy chia sẻ dữ liệu tệp được liên kết lại
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hệ thống tệp có thể gọi ZZ0000ZZ để buộc chia sẻ tệp
lưu trữ bằng một tệp khác để sao chép trước dữ liệu được chia sẻ sang tệp mới
phân bổ lưu trữ.
ZZ0001ZZ sẽ được chuyển làm đối số ZZ0002ZZ
tới ZZ0003ZZ.
Người gọi thường giữ ZZ0004ZZ và ZZ0005ZZ độc quyền
mode trước khi gọi chức năng này.

Cắt ngắn
----------

Hệ thống tập tin có thể gọi ZZ0000ZZ về 0 byte trong
pagecache từ EOF đến cuối fsblock trong quá trình cắt bớt tệp
hoạt động.
ZZ0001ZZ hoặc ZZ0002ZZ sẽ đảm nhiệm
mọi thứ sau khối EOF.
ZZ0003ZZ sẽ được chuyển làm đối số ZZ0004ZZ cho
ZZ0005ZZ.
Người gọi thường giữ ZZ0006ZZ và ZZ0007ZZ độc quyền
mode trước khi gọi chức năng này.

Viết lại bộ đệm trang
---------------------

Hệ thống tập tin có thể gọi ZZ0000ZZ để đáp ứng yêu cầu
ghi các folio pagecache bẩn vào đĩa.
Các tham số ZZ0001ZZ và ZZ0002ZZ phải được truyền không thay đổi.
Con trỏ ZZ0003ZZ phải được phân bổ bởi hệ thống tập tin và phải
được khởi tạo về 0.

Bộ đệm trang sẽ khóa từng trang trước khi cố gắng lên lịch cho nó.
viết lại.
Nó không khóa ZZ0000ZZ hoặc ZZ0001ZZ.

Phần bẩn sẽ được xóa cho tất cả các folio chạy qua
Máy ZZ0000ZZ được mô tả bên dưới ngay cả khi quá trình ghi lại không thành công.
Điều này nhằm ngăn chặn các cục folio bị bẩn khi thiết bị lưu trữ bị lỗi; một
ZZ0001ZZ được ghi lại để không gian người dùng thu thập thông qua ZZ0002ZZ.

Cấu trúc ZZ0000ZZ phải được chỉ định và như sau:

ZZ0000ZZ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

 struct iomap_writeback_ops {
    int (*writeback_range)(struct iomap_writepage_ctx *wpc,
        struct folio *folio, u64 pos, unsigned int len, u64 end_pos);
    int (*writeback_submit)(struct iomap_writepage_ctx *wpc, int error);
 };

Các trường như sau:

- ZZ0000ZZ: Đặt ZZ0001ZZ thành ánh xạ không gian của tệp
    phạm vi (tính bằng byte) được cung cấp bởi ZZ0002ZZ và ZZ0003ZZ.
    iomap gọi hàm này cho từng khối fs bẩn trong mỗi folio bẩn,
    mặc dù nó sẽ là ZZ0008ZZ
    để chạy các fsblock bẩn liền kề trong một folio.
    Không trả lại ánh xạ ZZ0004ZZ tại đây; ZZ0005ZZ
    chức năng phải xử lý dữ liệu được ghi liên tục.
    Không trả lại ánh xạ ZZ0006ZZ tại đây; iomap hiện tại
    yêu cầu ánh xạ tới không gian được phân bổ.
    Hệ thống tập tin có thể bỏ qua việc tra cứu ánh xạ có thể tốn kém nếu
    bản đồ không thay đổi.
    Việc xác nhận lại này phải được hệ thống tập tin mã hóa mở; nó là
    không rõ liệu ZZ0007ZZ có thể được tái sử dụng cho mục đích này hay không
    mục đích.

Nếu phương pháp này không thể lên lịch I/O cho bất kỳ phần nào của một tờ giấy bẩn, thì nó
    nên vứt bỏ mọi sự dè dặt có thể đã được thực hiện cho bài viết.
    Folio sẽ được đánh dấu sạch sẽ và ZZ0000ZZ được ghi vào
    pagecache.
    Hệ thống tập tin có thể sử dụng lệnh gọi lại này tới ZZ0001ZZ
    đặt chỗ delalloc để tránh việc đặt chỗ delalloc cho
    bộ đệm trang sạch.
    Chức năng này phải được cung cấp bởi hệ thống tập tin.
    Nếu điều này thành công, iomap_finish_folio_write() phải được gọi sau khi viết lại
    hoàn thành cho phạm vi, bất kể việc ghi lại thành công hay
    thất bại.

- ZZ0000ZZ: Gửi bối cảnh ghi lại được tạo trước đó.
    Hệ thống tệp dựa trên khối nên sử dụng iomap_ioend_writeback_submit
    trợ giúp, hệ thống tập tin khác có thể tự triển khai.
    Hệ thống tập tin có thể tùy chọn nối vào việc gửi tiểu sử viết lại.
    Điều này có thể bao gồm các cập nhật tính toán dung lượng được ghi trước hoặc cài đặt
    chức năng ZZ0001ZZ tùy chỉnh cho các mục đích nội bộ, chẳng hạn như
    trì hoãn quá trình hoàn thành ioend vào hàng công việc để chạy cập nhật siêu dữ liệu
    giao dịch từ bối cảnh quy trình trước khi gửi tiểu sử.
    Chức năng này phải được cung cấp bởi hệ thống tập tin.

Hoàn tất ghi lại bộ đệm trang
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để xử lý việc ghi sổ phải xảy ra sau I/O đĩa để ghi lại
hoàn tất, iomap tạo ra các chuỗi đối tượng ZZ0000ZZ
bọc ZZ0001ZZ được sử dụng để ghi dữ liệu bộ đệm trang vào đĩa.
Theo mặc định, iomap hoàn tất các ioend ghi lại bằng cách xóa phần ghi lại
bit trên các tờ giấy gắn vào ZZ0002ZZ.
Nếu việc ghi không thành công, nó cũng sẽ đặt các bit lỗi trên các folio và
không gian địa chỉ.
Điều này có thể xảy ra trong bối cảnh ngắt hoặc bối cảnh xử lý, tùy thuộc vào
thiết bị lưu trữ.
Các hệ thống tập tin cần cập nhật sổ sách kế toán nội bộ (ví dụ:
chuyển đổi phạm vi) nên đặt bi_end_io của riêng mình trên bios
đệ trình bởi ZZ0003ZZ
Hàm này sẽ gọi ZZ0004ZZ sau khi hoàn thành
công việc riêng (ví dụ: chuyển đổi phạm vi bất thành văn).

Một số hệ thống tập tin có thể muốn ZZ0001ZZ
để biết các cập nhật sau khi viết lại bằng cách gộp chúng lại.
Họ cũng có thể yêu cầu các giao dịch chạy từ bối cảnh quy trình, điều này
ngụ ý đưa các lô vào hàng công việc.
iomap ioend chứa ZZ0000ZZ để kích hoạt tính năng tạo khối.

Với một loạt ioend, iomap có một vài người trợ giúp để hỗ trợ
khấu hao:

* ZZ0000ZZ: Sắp xếp tất cả các ioend trong danh sách theo file
   bù đắp.

* ZZ0000ZZ: Cho một ioend không có trong danh sách nào và
   một danh sách riêng biệt gồm các ioend được sắp xếp, hợp nhất càng nhiều ioend từ
   đầu danh sách vào ioend đã cho.
   ioends chỉ có thể được hợp nhất nếu phạm vi tệp và địa chỉ lưu trữ là
   liền kề; trạng thái bất thành văn và chia sẻ đều giống nhau; và
   ghi kết quả I/O là như nhau.
   Các ioend đã hợp nhất sẽ trở thành danh sách riêng của chúng.

* ZZ0000ZZ: Hoàn thành một ioend có thể có khác
   ioends được liên kết với nó.

Vào/ra trực tiếp
================

Trong Linux, I/O trực tiếp được định nghĩa là I/O tệp được cấp trực tiếp tới
lưu trữ, bỏ qua pagecache.
Hàm ZZ0000ZZ thực hiện đọc và ghi O_DIRECT (I/O trực tiếp)
ghi cho các tập tin.

.. code-block:: c

 ssize_t iomap_dio_rw(struct kiocb *iocb, struct iov_iter *iter,
                      const struct iomap_ops *ops,
                      const struct iomap_dio_ops *dops,
                      unsigned int dio_flags, void *private,
                      size_t done_before);

Hệ thống tập tin có thể cung cấp tham số ZZ0000ZZ nếu nó cần thực hiện
công việc bổ sung trước hoặc sau khi I/O được cấp vào bộ lưu trữ.
Tham số ZZ0001ZZ cho biết số lượng yêu cầu có
đã được chuyển giao rồi.
Nó được sử dụng để tiếp tục yêu cầu không đồng bộ khi ZZ0002ZZ
đã được hoàn thành đồng bộ.

Tham số ZZ0000ZZ phải được đặt nếu ghi cho ZZ0001ZZ
đã được bắt đầu trước cuộc gọi.
Hướng của I/O được xác định từ ZZ0002ZZ được truyền vào.

Đối số ZZ0000ZZ có thể được đặt thành bất kỳ sự kết hợp nào của
các giá trị sau:

* ZZ0000ZZ: Đợi I/O hoàn tất ngay cả khi
   kiocb không đồng bộ.

* ZZ0000ZZ: Thực hiện ghi đè thuần túy cho phạm vi này
   hoặc thất bại với ZZ0001ZZ.
   Điều này có thể được sử dụng bởi các hệ thống tập tin có I/O không được sắp xếp phức tạp
   đường dẫn ghi để cung cấp đường dẫn nhanh được tối ưu hóa cho việc ghi không được căn chỉnh.
   Nếu việc ghi đè thuần túy có thể được thực hiện thì việc tuần tự hóa theo
   các I/O khác cho cùng (các) khối hệ thống tập tin là không cần thiết vì có
   không có nguy cơ lộ dữ liệu cũ hoặc mất dữ liệu.
   Nếu việc ghi đè thuần túy không thể được thực hiện thì hệ thống tập tin có thể
   thực hiện các bước tuần tự hóa cần thiết để cung cấp quyền truy cập độc quyền
   tới phạm vi I/O chưa được sắp xếp để nó có thể thực hiện phân bổ và
   zeroing khối con một cách an toàn.
   Hệ thống tập tin có thể sử dụng cờ này để cố gắng giảm sự tranh chấp về khóa,
   nhưng rất nhiều ZZ0002ZZ
   được yêu cầu phải làm điều đó ZZ0003ZZ.

* ZZ0000ZZ: Nếu xảy ra lỗi trang, hãy trả lại bất cứ thứ gì
   sự tiến bộ đã được thực hiện.
   Người gọi có thể xử lý lỗi trang và thử lại thao tác.
   Nếu người gọi quyết định thử lại thao tác, nó sẽ chuyển
   giá trị trả về tích lũy của tất cả các cuộc gọi trước đó dưới dạng
   Tham số ZZ0001ZZ cho cuộc gọi tiếp theo.

Các cờ ZZ0000ZZ này rất quan trọng đối với I/O trực tiếp với iomap:

* ZZ0000ZZ: Bật ZZ0001ZZ.

* ZZ0000ZZ: Đảm bảo rằng thiết bị có dữ liệu được lưu vào đĩa
   trước khi kết thúc cuộc gọi.
   Trong trường hợp ghi đè thuần túy, I/O có thể được cấp FUA
   đã bật.

* ZZ0000ZZ: Thăm dò để hoàn thành I/O thay vì chờ đợi
   ngắt lời.
   Chỉ có ý nghĩa đối với I/O không đồng bộ và chỉ khi toàn bộ I/O có thể
   được phát hành dưới dạng một ZZ0001ZZ duy nhất.

Hệ thống tập tin nên gọi ZZ0000ZZ từ ZZ0001ZZ và
ZZ0002ZZ và đặt ZZ0003ZZ trong ZZ0004ZZ
chức năng cho tập tin.
Họ không nên đặt ZZ0005ZZ, ZZ0005ZZ không được dùng nữa.

Nếu một hệ thống tập tin muốn thực hiện công việc của chính nó trước khi vào/ra trực tiếp
hoàn thành, nó sẽ gọi ZZ0000ZZ.
Nếu giá trị trả về của nó không phải là con trỏ lỗi hoặc con trỏ NULL, thì
hệ thống tập tin sẽ chuyển giá trị trả về cho ZZ0001ZZ sau
hoàn thành công việc nội bộ của mình.

Giá trị trả về
--------------

ZZ0000ZZ có thể trả về một trong những điều sau:

* Số byte không âm được truyền.

* ZZ0000ZZ: Quay trở lại I/O được đệm.
   Bản thân iomap sẽ trả về giá trị này nếu nó không thể làm mất hiệu lực trang
   cache trước khi cấp I/O tới bộ lưu trữ.
   Các hàm ZZ0001ZZ hoặc ZZ0002ZZ cũng có thể trả về
   giá trị này.

* ZZ0000ZZ: Yêu cầu I/O trực tiếp không đồng bộ đã được
   xếp hàng và sẽ được hoàn thành riêng biệt.

* Bất kỳ mã lỗi tiêu cực nào khác.

Đọc trực tiếp
-------------

Việc đọc I/O trực tiếp bắt đầu việc đọc I/O từ thiết bị lưu trữ tới
bộ đệm của người gọi.
Các phần bẩn của bộ đệm trang sẽ được chuyển vào bộ lưu trữ trước khi bắt đầu
io đã đọc.
Giá trị ZZ0000ZZ cho ZZ0001ZZ sẽ là ZZ0002ZZ với
bất kỳ sự kết hợp nào của các cải tiến sau:

* ZZ0000ZZ, như được định nghĩa trước đó.

Người gọi thường giữ ZZ0000ZZ ở chế độ chia sẻ trước khi gọi
chức năng.

Viết trực tiếp
--------------

Việc ghi I/O trực tiếp bắt đầu việc ghi I/O vào thiết bị lưu trữ từ
bộ đệm của người gọi.
Các phần bẩn của bộ đệm trang sẽ được chuyển vào bộ lưu trữ trước khi bắt đầu
viết io.
Bộ đệm trang bị vô hiệu cả trước và sau khi ghi io.
Giá trị ZZ0000ZZ cho ZZ0001ZZ sẽ là ZZ0002ZZ với bất kỳ sự kết hợp nào của các cải tiến sau:

* ZZ0000ZZ, như được định nghĩa trước đó.

* ZZ0000ZZ: Phân bổ khối và zeroing một phần
   khối không được phép.
   Toàn bộ phạm vi tệp phải ánh xạ tới một tệp được ghi hoặc không được ghi
   mức độ.
   Phạm vi I/O của tệp phải được căn chỉnh theo kích thước khối hệ thống tệp
   nếu ánh xạ không được ghi và hệ thống tập tin không thể xử lý việc đưa về 0
   các vùng không được căn chỉnh mà không để lộ nội dung cũ.

* ZZ0000ZZ: Bản ghi này đang được phát hành bằng bản ghi rách
   bảo vệ.
   Tính năng bảo vệ chống rách ghi có thể được cung cấp dựa trên việc giảm tải CTNH hoặc bằng
   cơ chế phần mềm được cung cấp bởi hệ thống tập tin.

Đối với hỗ trợ dựa trên giảm tải CTNH, chỉ có thể tạo một tiểu sử duy nhất cho
   ghi và việc ghi không được chia thành nhiều yêu cầu I/O, tức là.
   cờ REQ_ATOMIC phải được đặt.
   Phạm vi tệp cần ghi phải được căn chỉnh để đáp ứng yêu cầu
   của cả hệ thống tập tin và nguyên tử của thiết bị khối cơ bản
   khả năng cam kết.
   Nếu cần cập nhật siêu dữ liệu hệ thống tập tin (ví dụ: phạm vi không được ghi
   chuyển đổi hoặc sao chép khi ghi), tất cả các bản cập nhật cho toàn bộ phạm vi tệp
   cũng phải được cam kết nguyên tử.
   Phần ghi chưa xé có thể dài hơn một khối tệp. Trong mọi trường hợp,
   khối đĩa khởi động ánh xạ ít nhất phải có sự căn chỉnh giống như
   phần bù ghi.
   Các hệ thống tập tin phải đặt IOMAP_F_ATOMIC_BIO để thông báo lõi iomap của một
   chưa được ghi dựa trên CT-offload.

Đối với các bản ghi không bị xé dựa trên cơ chế phần mềm được cung cấp bởi
   hệ thống tập tin, tất cả các căn chỉnh khối đĩa và các hạn chế sinh học đơn lẻ
   áp dụng cho việc ghi không bị xé dựa trên CTNH không áp dụng.
   Cơ chế này thường được sử dụng làm phương án dự phòng khi
   Không thể phát hành các bản ghi không bị xén dựa trên phần mềm giảm tải, ví dụ: phạm vi của
   viết bao gồm nhiều phạm vi, có nghĩa là không thể phát hành
   một sinh học duy nhất.
   Tất cả các bản cập nhật siêu dữ liệu hệ thống tệp cho toàn bộ phạm vi tệp phải được
   cam kết nguyên tử là tốt.

Người gọi thường giữ ZZ0000ZZ ở chế độ chia sẻ hoặc độc quyền trước
gọi chức năng này.

ZZ0000ZZ
-------------------------
.. code-block:: c

 struct iomap_dio_ops {
     void (*submit_io)(const struct iomap_iter *iter, struct bio *bio,
                       loff_t file_offset);
     int (*end_io)(struct kiocb *iocb, ssize_t size, int error,
                   unsigned flags);
     struct bio_set *bio_set;
 };

Các trường của cấu trúc này như sau:

- ZZ0000ZZ: iomap gọi hàm này khi nó đã xây dựng một
    Đối tượng ZZ0001ZZ cho I/O được yêu cầu và muốn gửi nó
    tới thiết bị khối.
    Nếu không có chức năng nào được cung cấp, ZZ0002ZZ sẽ được gọi trực tiếp.
    Các hệ thống tập tin muốn thực hiện công việc bổ sung trước đó (ví dụ:
    sao chép dữ liệu cho btrfs) nên triển khai chức năng này.

- ZZ0000ZZ: Cái này được gọi sau khi ZZ0001ZZ hoàn thành.
    Hàm này sẽ thực hiện chuyển đổi sau khi ghi các dữ liệu chưa được ghi
    ánh xạ phạm vi, xử lý lỗi ghi, v.v.
    Đối số ZZ0002ZZ có thể được đặt thành sự kết hợp của các mục sau:

* ZZ0000ZZ: Ánh xạ không được ghi lại nên ioend
      nên đánh dấu mức độ như được viết.

* ZZ0000ZZ: Việc ghi vào khoảng trống trong ánh xạ yêu cầu một
      sao chép trong thao tác ghi, vì vậy ioend sẽ chuyển đổi ánh xạ.

- ZZ0000ZZ: Điều này cho phép hệ thống tập tin cung cấp một bio_set tùy chỉnh
    để phân bổ bios I/O trực tiếp.
    Điều này cho phép hệ thống tập tin ZZ0002ZZ
    để sử dụng riêng.
    Nếu trường này là NULL, các đối tượng ZZ0001ZZ chung sẽ được sử dụng.

Các hệ thống tập tin muốn thực hiện công việc bổ sung sau khi hoàn thành I/O
nên đặt chức năng ZZ0000ZZ tùy chỉnh thông qua ZZ0001ZZ.
Sau đó, hàm endio tùy chỉnh phải gọi
ZZ0002ZZ để hoàn thành I/O trực tiếp.

Đầu vào/đầu ra DAX
==================

Một số thiết bị lưu trữ có thể được ánh xạ trực tiếp dưới dạng bộ nhớ.
Các thiết bị này hỗ trợ chế độ truy cập mới được gọi là "fsdax" cho phép
tải và lưu trữ thông qua CPU và bộ điều khiển bộ nhớ.

fsdax đọc
-----------

Quá trình đọc fsdax thực hiện memcpy từ thiết bị lưu trữ tới thiết bị của người gọi
bộ đệm.
Giá trị ZZ0000ZZ cho ZZ0001ZZ sẽ là ZZ0002ZZ với bất kỳ
sự kết hợp của các cải tiến sau:

* ZZ0000ZZ, như được định nghĩa trước đó.

Người gọi thường giữ ZZ0000ZZ ở chế độ chia sẻ trước khi gọi
chức năng.

fsdax viết
------------

Lệnh ghi fsdax sẽ khởi tạo một memcpy tới thiết bị lưu trữ từ máy gọi của người gọi.
bộ đệm.
Giá trị ZZ0000ZZ cho ZZ0001ZZ sẽ là ZZ0002ZZ với bất kỳ sự kết hợp nào của các cải tiến sau:

* ZZ0000ZZ, như được định nghĩa trước đó.

* ZZ0000ZZ: Người gọi yêu cầu ghi đè thuần túy
   được thực hiện từ ánh xạ này.
   Điều này yêu cầu ánh xạ phạm vi hệ thống tập tin phải tồn tại dưới dạng
   ZZ0001ZZ loại và mở rộng toàn bộ phạm vi I/O ghi
   yêu cầu.
   Nếu hệ thống tập tin không thể ánh xạ yêu cầu này theo cách cho phép
   cơ sở hạ tầng iomap để thực hiện ghi đè thuần túy, nó phải thất bại
   hoạt động ánh xạ với ZZ0002ZZ.

Người gọi thường giữ ZZ0000ZZ ở chế độ độc quyền trước khi gọi
chức năng.

Lỗi mmap fsdax
~~~~~~~~~~~~~~~~~

Hàm ZZ0000ZZ xử lý lỗi đọc và ghi vào fsdax
lưu trữ.
Đối với lỗi đọc, ZZ0001ZZ sẽ được chuyển thành
Đối số ZZ0002ZZ thành ZZ0003ZZ.
Đối với lỗi ghi, ZZ0004ZZ sẽ
được chuyển dưới dạng đối số ZZ0005ZZ cho ZZ0006ZZ.

Người gọi thường giữ các khóa giống như cách họ gọi iomap của họ
đối tác của bộ đệm trang.

fsdax Cắt ngắn, sai vị trí và không chia sẻ
-------------------------------------------

Đối với các tệp fsdax, các chức năng sau được cung cấp để thay thế chúng
đối tác I/O của iomap pagecache.
Đối số ZZ0000ZZ của ZZ0001ZZ giống như đối số
các bản sao của pagecache, có thêm ZZ0002ZZ.

* ZZ0000ZZ
 * ZZ0001ZZ
 * ZZ0002ZZ

Người gọi thường giữ các khóa giống như cách họ gọi iomap của họ
đối tác của bộ đệm trang.

Chống trùng lặp fsdax
---------------------

Các hệ thống tập tin triển khai ZZ0000ZZ ioctl phải gọi phương thức
ZZ0001ZZ có chức năng đọc iomap riêng.

Tìm kiếm tập tin
================

iomap triển khai hai chế độ lặp từ đâu của hệ thống ZZ0000ZZ
gọi.

SEEK_DATA
---------

Hàm ZZ0000ZZ thực hiện giá trị "từ đâu" SEEK_DATA
cho llseek.
ZZ0001ZZ sẽ được chuyển làm đối số ZZ0002ZZ cho
ZZ0003ZZ.

Đối với ánh xạ không được viết, bộ đệm trang sẽ được tìm kiếm.
Các vùng của bộ đệm trang có fsblock được ánh xạ folio và cập nhật
trong các folio đó sẽ được báo cáo dưới dạng vùng dữ liệu.

Người gọi thường giữ ZZ0000ZZ ở chế độ chia sẻ trước khi gọi
chức năng.

SEEK_HOLE
---------

Hàm ZZ0000ZZ thực hiện giá trị "từ đâu" SEEK_HOLE
cho llseek.
ZZ0001ZZ sẽ được chuyển làm đối số ZZ0002ZZ cho
ZZ0003ZZ.

Đối với ánh xạ không được viết, bộ đệm trang sẽ được tìm kiếm.
Các vùng của bộ đệm trang không được ánh xạ folio hoặc fsblock !uptodate
trong một folio sẽ được báo cáo là các vùng lỗ thưa thớt.

Người gọi thường giữ ZZ0000ZZ ở chế độ chia sẻ trước khi gọi
chức năng.

Kích hoạt tập tin hoán đổi
==========================

Hàm ZZ0000ZZ tìm tất cả các trang cơ sở được căn chỉnh
các vùng trong một tệp và thiết lập chúng làm không gian hoán đổi.
Tệp sẽ là ZZ0001ZZ'd trước khi kích hoạt.
ZZ0002ZZ sẽ được chuyển làm đối số ZZ0003ZZ cho
ZZ0004ZZ.
Tất cả các ánh xạ phải được lập bản đồ hoặc không được ghi lại; không thể bị bẩn hoặc chia sẻ, và
không thể mở rộng nhiều thiết bị khối.
Người gọi phải giữ ZZ0005ZZ ở chế độ độc quyền; cái này đã rồi
được cung cấp bởi ZZ0006ZZ.

Báo cáo ánh xạ không gian tệp
=============================

iomap thực hiện hai lệnh gọi hệ thống ánh xạ không gian tệp.

FS_IOC_FIEMAP
-------------

Hàm ZZ0000ZZ xuất ánh xạ phạm vi tệp sang không gian người dùng
ở định dạng được chỉ định bởi ZZ0001ZZ ioctl.
ZZ0002ZZ sẽ được chuyển làm đối số ZZ0003ZZ cho
ZZ0004ZZ.
Người gọi thường giữ ZZ0005ZZ ở chế độ chia sẻ trước khi gọi
chức năng.

FIBMAP (không dùng nữa)
-----------------------

ZZ0000ZZ triển khai FIBMAP.
Quy ước gọi cũng giống như FIEMAP.
Chức năng này chỉ được cung cấp để duy trì khả năng tương thích cho các hệ thống tập tin
đã triển khai FIBMAP trước khi chuyển đổi.
ioctl này không được dùng nữa; ZZ0002ZZ có thêm triển khai FIBMAP vào
hệ thống tập tin không có nó.
Người gọi có lẽ nên giữ ZZ0001ZZ ở chế độ chia sẻ trước khi gọi
chức năng này, nhưng điều này là không rõ ràng.