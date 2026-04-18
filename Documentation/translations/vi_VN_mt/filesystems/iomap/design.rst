.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/iomap/design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _iomap_design:

..
        Dumb style notes to maintain the author's sanity:
        Please try to start sentences on separate lines so that
        sentence changes don't bleed colors in diff.
        Heading decorations are documented in sphinx.rst.

=================
Thiết kế thư viện
=================

.. contents:: Table of Contents
   :local:

Giới thiệu
============

iomap là thư viện hệ thống tệp để xử lý các thao tác tệp phổ biến.
Thư viện có hai lớp:

1. Lớp thấp hơn cung cấp một trình vòng lặp trên các phạm vi bù trừ tệp.
    Lớp này cố gắng lấy ánh xạ của từng phạm vi tệp vào bộ nhớ
    từ hệ thống tập tin, nhưng thông tin lưu trữ không nhất thiết
    được yêu cầu.

2. Lớp trên hoạt động dựa trên ánh xạ không gian được cung cấp bởi
    trình lặp lớp dưới.

Việc lặp lại có thể liên quan đến việc ánh xạ các phạm vi bù logic của tệp tới
phạm vi vật lý, nhưng thông tin lớp lưu trữ không nhất thiết phải
được yêu cầu, ví dụ: để biết thông tin tập tin được lưu trong bộ nhớ cache.
Thư viện xuất các API khác nhau để thực hiện các thao tác với tệp như
như:

* Pagecache đọc và ghi
 * Lỗi ghi Folio vào bộ đệm trang
 * Viết lại những tờ giấy bẩn
 * Đọc và ghi I/O trực tiếp
 * fsdax I/O đọc, ghi, tải và lưu trữ
 * FIEMAP
 * lseek ZZ0000ZZ và ZZ0001ZZ
 * kích hoạt tập tin hoán đổi

Nguồn gốc của thư viện này là đường dẫn I/O của tệp mà XFS đã từng sử dụng; nó
hiện đã được mở rộng để bao gồm một số hoạt động khác.

Ai nên đọc cái này?
=====================

Đối tượng mục tiêu của tài liệu này là hệ thống tập tin, lưu trữ và
lập trình viên pagecache và người đánh giá mã.

Nếu bạn đang làm việc trên PCI, kiến trúc máy hoặc trình điều khiển thiết bị, bạn
rất có thể ở sai chỗ.

Làm thế nào là điều này tốt hơn?
===================

Không giống như mô hình I/O Linux cổ điển chia I/O tệp thành các phần nhỏ.
đơn vị (thường là các trang hoặc khối bộ nhớ) và tra cứu ánh xạ không gian trên
cơ sở của đơn vị đó, mô hình iomap sẽ yêu cầu hệ thống tập tin cung cấp
ánh xạ không gian lớn nhất mà nó có thể tạo cho một thao tác tệp nhất định và
bắt đầu hoạt động trên cơ sở đó.
Chiến lược này cải thiện khả năng hiển thị của hệ thống tập tin về kích thước của
hoạt động đang được thực hiện, cho phép nó chống lại sự phân mảnh bằng
phân bổ không gian lớn hơn khi có thể.
Ánh xạ không gian lớn hơn cải thiện hiệu suất thời gian chạy bằng cách khấu hao chi phí
của hàm ánh xạ gọi vào hệ thống tập tin trên một lượng lớn hơn
dữ liệu.

Ở mức cao, thao tác iomap ZZ0000ZZ:

1. Đối với mỗi byte trong phạm vi hoạt động...

1. Lấy bản đồ không gian qua ZZ0000ZZ

2. Đối với từng tiểu đơn vị công việc...

1. Xác nhận lại ánh xạ và quay lại (1) ở trên, nếu cần.
         Cho đến nay chỉ có các hoạt động pagecache cần thực hiện việc này.

2. Thực hiện công việc

3. Con trỏ thao tác tăng dần

4. Phát hành ánh xạ qua ZZ0000ZZ, nếu cần

Mỗi thao tác iomap sẽ được đề cập chi tiết hơn dưới đây.
Thư viện này trước đây được bao phủ bởi ZZ0000ZZ và ZZ0001ZZ.

Mục tiêu của tài liệu này là cung cấp một cuộc thảo luận ngắn gọn về
thiết kế và khả năng của iomap, tiếp theo là danh mục chi tiết hơn
của các giao diện được trình bày bởi iomap.
Nếu bạn thay đổi iomap, vui lòng cập nhật tài liệu thiết kế này.

Trình lặp phạm vi tệp
===================

định nghĩa
-----------

* ZZ0000ZZ: Phá vỡ tàn dư của bộ đệm đệm cũ.

* ZZ0000ZZ: Kích thước khối của một file hay còn gọi là ZZ0001ZZ.

* ZZ0000ZZ: Rwsemaphore VFS ZZ0001ZZ.
   Các quy trình giữ điều này ở chế độ chia sẻ để đọc trạng thái và nội dung tệp.
   Một số hệ thống tập tin có thể cho phép chế độ chia sẻ để ghi.
   Các quy trình thường giữ điều này ở chế độ độc quyền để thay đổi trạng thái tệp và
   nội dung.

* ZZ0000ZZ: Bộ đệm trang ZZ0001ZZ
   rwsemaphore bảo vệ chống lại việc chèn và loại bỏ folio cho
   các hệ thống tập tin hỗ trợ đục lỗ các folio bên dưới EOF.
   Các quy trình muốn chèn folios phải giữ khóa này trong tài khoản chung
   chế độ ngăn chặn việc loại bỏ, mặc dù việc chèn đồng thời được cho phép.
   Các quy trình muốn xóa folio phải giữ khóa này độc quyền
   chế độ để ngăn chặn việc chèn vào.
   Loại bỏ đồng thời không được phép.

* ZZ0000ZZ: Khóa đọc RCU mà dax sử dụng để ngăn chặn
   móc tắt trước thiết bị để quay trở lại trước khi các luồng khác có
   tài nguyên được phát hành.

* ZZ0000ZZ: Nguyên tắc đồng bộ hóa này là
   nội bộ của hệ thống tệp và phải bảo vệ dữ liệu ánh xạ tệp
   từ các bản cập nhật trong khi ánh xạ đang được lấy mẫu.
   Tác giả hệ thống tập tin phải xác định cách thức phối hợp này
   xảy ra; nó không cần phải là một khóa thực sự.

* ZZ0000ZZ: Đây là thuật ngữ chung cho
   nguyên tắc đồng bộ hóa mà các hàm iomap thực hiện khi giữ một
   lập bản đồ.
   Một ví dụ cụ thể là sử dụng khóa folio trong khi đọc hoặc
   viết bộ đệm trang.

* ZZ0001ZZ: Thao tác ghi không yêu cầu bất kỳ
   siêu dữ liệu hoặc các thao tác zeroing để thực hiện trong quá trình gửi
   hoặc hoàn thiện.
   Điều này ngụ ý rằng hệ thống tập tin phải có không gian được phân bổ
   trên đĩa dưới dạng ZZ0000ZZ và hệ thống tập tin không được đặt bất kỳ
   các ràng buộc về căn chỉnh hoặc kích thước IO.
   Hạn chế duy nhất về căn chỉnh I/O là cấp độ thiết bị (I/O tối thiểu
   kích thước và căn chỉnh, thường là kích thước khu vực).

ZZ0000ZZ
----------------

Hệ thống tập tin giao tiếp với trình lặp iomap ánh xạ của
phạm vi byte của tệp đến phạm vi byte của thiết bị lưu trữ với
cấu trúc dưới đây:

.. code-block:: c

 struct iomap {
     u64                 addr;
     loff_t              offset;
     u64                 length;
     u16                 type;
     u16                 flags;
     struct block_device *bdev;
     struct dax_device   *dax_dev;
     void                *inline_data;
     void                *private;
     u64                 validity_cookie;
 };

Các trường như sau:

* ZZ0000ZZ và ZZ0001ZZ mô tả phạm vi bù trừ tệp, trong
   byte, được bao phủ bởi ánh xạ này.
   Các trường này phải luôn được đặt bởi hệ thống tập tin.

* ZZ0000ZZ mô tả kiểu ánh xạ không gian:

* ZZ0003ZZ: Không có dung lượng lưu trữ nào được phân bổ.
     Loại này không bao giờ được trả lại để phản hồi ZZ0000ZZ
     hoạt động vì việc ghi phải phân bổ và ánh xạ không gian và trả về
     bản đồ.
     Trường ZZ0001ZZ phải được đặt thành ZZ0002ZZ.
     iomap không hỗ trợ ghi (dù qua pagecache hay trực tiếp
     I/O) vào một lỗ.

* ZZ0003ZZ: Lời hứa sẽ phân bổ không gian sau này
     ("phân bổ bị trì hoãn").
     Nếu hệ thống tập tin trả về IOMAP_F_NEW ở đây và quá trình ghi không thành công,
     Chức năng ZZ0000ZZ phải xóa đặt chỗ.
     Trường ZZ0001ZZ phải được đặt thành ZZ0002ZZ.

* ZZ0003ZZ: Phạm vi tệp ánh xạ tới không gian cụ thể trên
     thiết bị lưu trữ.
     Thiết bị được trả lại dưới dạng ZZ0000ZZ hoặc ZZ0001ZZ.
     Địa chỉ thiết bị, tính bằng byte, được trả về qua ZZ0002ZZ.

* ZZ0003ZZ: Phạm vi tệp ánh xạ tới không gian cụ thể trên
     thiết bị lưu trữ, nhưng dung lượng vẫn chưa được khởi tạo.
     Thiết bị được trả lại dưới dạng ZZ0000ZZ hoặc ZZ0001ZZ.
     Địa chỉ thiết bị, tính bằng byte, được trả về qua ZZ0002ZZ.
     Các lần đọc từ loại ánh xạ này sẽ trả về số 0 cho người gọi.
     Đối với thao tác ghi hoặc ghi lại, ioend nên cập nhật
     ánh xạ tới MAPPED.
     Tham khảo các phần về ioends để biết thêm chi tiết.

* ZZ0004ZZ: Phạm vi tệp ánh xạ tới bộ nhớ đệm
     được chỉ định bởi ZZ0000ZZ.
     Đối với thao tác ghi, có lẽ hàm ZZ0001ZZ
     xử lý việc duy trì dữ liệu.
     Trường ZZ0002ZZ phải được đặt thành ZZ0003ZZ.

* ZZ0000ZZ mô tả trạng thái của bản đồ không gian.
   Những cờ này phải được đặt bởi hệ thống tệp trong ZZ0001ZZ:

* ZZ0000ZZ: Không gian dưới ánh xạ mới được phân bổ.
     Các vùng không được ghi vào phải bằng 0.
     Nếu việc ghi không thành công và việc ánh xạ là để dành chỗ trống, thì
     đặt chỗ phải được xóa.

* ZZ0000ZZ: Inode sẽ có siêu dữ liệu sẵn có cần thiết
     để truy cập bất kỳ dữ liệu được viết.
     fdatasync được yêu cầu để cam kết những thay đổi này thành liên tục
     lưu trữ.
     Điều này cần tính đến những thay đổi về siêu dữ liệu mà ZZ0001ZZ thực hiện
     khi hoàn thành I/O, chẳng hạn như cập nhật kích thước tệp từ I/O trực tiếp.

* ZZ0000ZZ: Không gian dưới ánh xạ được chia sẻ.
     Sao chép khi ghi là cần thiết để tránh làm hỏng dữ liệu tệp khác.

* ZZ0000ZZ: Ánh xạ này yêu cầu sử dụng bộ đệm
     đầu cho các hoạt động pagecache.
     Không thêm nhiều công dụng của việc này.

* ZZ0000ZZ: Nhiều ánh xạ khối liền kề đã được
     kết hợp lại thành bản đồ duy nhất này.
     Điều này chỉ hữu ích cho FIEMAP.

* ZZ0000ZZ: Ánh xạ dành cho dữ liệu thuộc tính mở rộng, không phải
     dữ liệu tập tin thông thường.
     Điều này chỉ hữu ích cho FIEMAP.

* ZZ0000ZZ: Điều này cho biết I/O và việc hoàn thành nó không được
     hợp nhất với bất kỳ I/O hoặc hoàn thành nào khác. Hệ thống tập tin phải sử dụng điều này khi
     gửi I/O tới các thiết bị không thể xử lý I/O vượt qua các LBA nhất định
     (ví dụ: thiết bị ZNS). Cờ này chỉ áp dụng cho việc ghi lại I/O được đệm; tất cả
     các chức năng khác bỏ qua nó.

* ZZ0000ZZ: Cờ này được dành riêng cho mục đích sử dụng riêng của hệ thống tệp.

* ZZ0000ZZ: Cho biết rằng (ghi) I/O không có mục tiêu
     khối được gán cho nó và hệ thống tập tin sẽ thực hiện điều đó trong tiểu sử
     trình xử lý gửi, phân tách I/O nếu cần.

* ZZ0001ZZ: Điều này cho biết I/O ghi phải được gửi cùng với
     Cờ ZZ0000ZZ được đặt trong tiểu sử. Hệ thống tập tin cần đặt cờ này thành
     thông báo cho iomap rằng thao tác ghi I/O yêu cầu bảo vệ chống rách ghi
     dựa trên cơ chế giảm tải CTNH. Họ cũng phải đảm bảo rằng các cập nhật bản đồ
     sau khi hoàn thành I/O phải được thực hiện trong một siêu dữ liệu duy nhất
     cập nhật.

Những cờ này có thể được đặt bởi chính iomap trong quá trình thao tác với tệp.
   Hệ thống tập tin sẽ cung cấp chức năng ZZ0000ZZ nếu cần
   để quan sát những lá cờ này:

* ZZ0000ZZ: Kích thước tập tin đã thay đổi do
     sử dụng bản đồ này.

* ZZ0002ZZ: Bản đồ được phát hiện là cũ.
     iomap sẽ gọi ZZ0000ZZ trên ánh xạ này và sau đó
     ZZ0001ZZ để có được ánh xạ mới.

Hiện tại, những cờ này chỉ được đặt bởi các hoạt động của pagecache.

* ZZ0000ZZ mô tả địa chỉ thiết bị, tính bằng byte.

* ZZ0000ZZ mô tả thiết bị khối cho việc ánh xạ này.
   Điều này chỉ cần được đặt cho các hoạt động được ánh xạ hoặc không được ghi lại.

* ZZ0000ZZ mô tả thiết bị DAX cho việc ánh xạ này.
   Điều này chỉ cần được đặt cho các hoạt động được ánh xạ hoặc không được ghi và
   chỉ dành cho hoạt động fsdax.

* ZZ0000ZZ trỏ đến bộ nhớ đệm cho I/O liên quan đến
   Ánh xạ ZZ0001ZZ.
   Giá trị này bị bỏ qua đối với tất cả các loại ánh xạ khác.

* ZZ0000ZZ là con trỏ tới ZZ0002ZZ.
   Giá trị này sẽ được chuyển không thay đổi tới ZZ0001ZZ.

* ZZ0000ZZ là giá trị độ mới kỳ diệu được đặt bởi hệ thống tập tin
   nên được sử dụng để phát hiện ánh xạ cũ.
   Đối với các hoạt động của pagecache, điều này rất quan trọng để hoạt động chính xác
   bởi vì lỗi trang có thể xảy ra, điều này ngụ ý rằng hệ thống tập tin bị khóa
   không nên được giữ giữa ZZ0001ZZ và ZZ0002ZZ.
   Các hệ thống tập tin có ánh xạ hoàn toàn tĩnh không cần đặt giá trị này.
   Chỉ các hoạt động của bộ đệm trang mới xác nhận lại ánh xạ; xem phần về
   ZZ0003ZZ để biết chi tiết.

ZZ0000ZZ
--------------------

Mọi hàm iomap đều yêu cầu hệ thống tập tin phải vượt qua một phép toán
cấu trúc để có được ánh xạ và (tùy chọn) để giải phóng ánh xạ:

.. code-block:: c

 struct iomap_ops {
     int (*iomap_begin)(struct inode *inode, loff_t pos, loff_t length,
                        unsigned flags, struct iomap *iomap,
                        struct iomap *srcmap);

     int (*iomap_end)(struct inode *inode, loff_t pos, loff_t length,
                      ssize_t written, unsigned flags,
                      struct iomap *iomap);
 };

ZZ0000ZZ
~~~~~~~~~~~~~~~~~

Các hoạt động iomap gọi ZZ0000ZZ để lấy một ánh xạ tệp cho
phạm vi byte được chỉ định bởi ZZ0001ZZ và ZZ0002ZZ cho tệp
ZZ0003ZZ.
Ánh xạ này phải được trả về thông qua con trỏ ZZ0004ZZ.
Ánh xạ phải bao gồm ít nhất byte đầu tiên của tệp được cung cấp
phạm vi, nhưng nó không cần phải bao phủ toàn bộ phạm vi được yêu cầu.

Mỗi thao tác iomap mô tả thao tác được yêu cầu thông qua
Đối số ZZ0000ZZ.
Giá trị chính xác của ZZ0001ZZ sẽ được ghi lại trong
phần hoạt động cụ thể bên dưới.
Về nguyên tắc, những cờ này có thể áp dụng chung cho iomap
hoạt động:

* ZZ0000ZZ được đặt khi người gọi muốn gửi tệp I/O tới
   khối lưu trữ.

* ZZ0000ZZ được đặt khi người gọi muốn gửi tệp I/O tới
   lưu trữ giống như bộ nhớ.

* ZZ0000ZZ được đặt khi người gọi muốn thực hiện tốt nhất
   nỗ lực tránh bất kỳ hoạt động nào có thể dẫn đến việc chặn
   nhiệm vụ nộp.
   Điều này có mục đích tương tự như ZZ0001ZZ dành cho API mạng - đó là
   dành cho các ứng dụng không đồng bộ để tiếp tục thực hiện công việc khác
   thay vì chờ đợi tài nguyên hệ thống tập tin không có sẵn cụ thể
   để trở nên có sẵn.
   Các hệ thống tập tin triển khai ngữ nghĩa ZZ0002ZZ cần sử dụng
   thuật toán trylock.
   Họ cần có khả năng đáp ứng toàn bộ phạm vi yêu cầu I/O với
   ánh xạ iomap đơn.
   Họ cần tránh đọc hoặc ghi siêu dữ liệu một cách đồng bộ.
   Họ cần tránh chặn việc phân bổ bộ nhớ.
   Họ cần tránh phải chờ đợi đặt chỗ giao dịch để cho phép
   những sửa đổi sắp diễn ra.
   Có lẽ họ không nên phân bổ không gian mới.
   Và vân vân.
   Nếu có bất kỳ nghi ngờ nào trong đầu của nhà phát triển hệ thống tập tin về
   liệu bất kỳ hoạt động ZZ0003ZZ cụ thể nào có thể bị chặn hay không,
   thì họ nên trả lại ZZ0004ZZ càng sớm càng tốt thay vì
   bắt đầu hoạt động và buộc tác vụ gửi phải chặn.
   ZZ0005ZZ thường được đặt thay mặt cho ZZ0006ZZ hoặc
   ZZ0007ZZ.

* ZZ0000ZZ được đặt khi người gọi muốn thực hiện
   I/O tập tin đệm và muốn hạt nhân loại bỏ bộ nhớ đệm trang
   sau khi I/O hoàn tất, nếu nó chưa được người khác sử dụng
   chủ đề.

Nếu cần đọc nội dung tệp hiện có từ ZZ0001ZZ
thiết bị hoặc phạm vi địa chỉ trên thiết bị, hệ thống tập tin sẽ trả về thông tin đó
thông tin qua ZZ0000ZZ.
Chỉ các hoạt động pagecache và fsdax mới hỗ trợ đọc từ một ánh xạ và
viết cho người khác.

ZZ0000ZZ
~~~~~~~~~~~~~~~

Sau khi thao tác hoàn tất, chức năng ZZ0000ZZ, nếu có,
được gọi để báo hiệu rằng iomap đã hoàn tất việc ánh xạ.
Thông thường, việc triển khai sẽ sử dụng chức năng này để loại bỏ mọi
bối cảnh đã được thiết lập trong ZZ0001ZZ.
Ví dụ: một lệnh ghi có thể muốn cam kết đặt trước các byte
đã được vận hành và giải phóng bất kỳ không gian nào chưa được vận hành
trên.
ZZ0002ZZ có thể bằng 0 nếu không có byte nào được chạm vào.
ZZ0003ZZ sẽ chứa cùng giá trị được truyền cho ZZ0004ZZ.
Các hoạt động đọc iomap có thể không cần cung cấp chức năng này.

Cả hai hàm sẽ trả về mã lỗi âm nếu có lỗi hoặc bằng 0 nếu
thành công.

Chuẩn bị cho hoạt động tập tin
=============================

iomap chỉ xử lý ánh xạ và I/O.
Hệ thống tập tin vẫn phải gọi VFS để kiểm tra các tham số đầu vào
và trạng thái tệp trước khi bắt đầu thao tác I/O.
Nó không xử lý việc bảo vệ chống đóng băng hệ thống tập tin, cập nhật
dấu thời gian, tước bỏ đặc quyền hoặc kiểm soát truy cập.

Khóa phân cấp
=================

iomap yêu cầu hệ thống tập tin cung cấp mô hình khóa riêng của chúng.
Có ba loại nguyên thủy đồng bộ hóa, theo như
iomap có liên quan:

* Mức nguyên thủy ZZ0003ZZ được hệ thống tập tin cung cấp để
   phối hợp truy cập vào các hoạt động iomap khác nhau.
   Nguyên thủy chính xác là dành riêng cho hệ thống tập tin và hoạt động,
   nhưng thường là inode VFS, vô hiệu hóa bộ đệm trang hoặc khóa folio.
   Ví dụ: một hệ thống tập tin có thể lấy ZZ0000ZZ trước khi gọi
   ZZ0001ZZ và ZZ0002ZZ để ngăn chặn
   hai thao tác tập tin này khỏi ghi đè lẫn nhau.
   Việc ghi lại Pagecache có thể khóa một folio để ngăn các chủ đề khác truy cập
   truy cập folio cho đến khi quá trình viết lại được tiến hành.

* Mức nguyên thủy ZZ0004ZZ được lấy bởi hệ thống tập tin trong
     ZZ0000ZZ và ZZ0001ZZ có chức năng phối hợp
     truy cập vào thông tin ánh xạ không gian tập tin.
     Các trường của đối tượng iomap phải được điền trong khi giữ
     nguyên thủy này.
     Nguyên thủy đồng bộ hóa cấp cao hơn, nếu có, vẫn được giữ
     trong khi có được nguyên thủy đồng bộ hóa cấp thấp hơn.
     Ví dụ: XFS lấy ZZ0002ZZ và ext4 lấy ZZ0003ZZ
     trong khi lấy mẫu ánh xạ.
     Hệ thống tập tin có thông tin ánh xạ bất biến có thể không yêu cầu
     đồng bộ ở đây

* Nguyên hàm ZZ0000ZZ được thực hiện bằng thao tác iomap để
     phối hợp truy cập vào cấu trúc dữ liệu nội bộ của chính nó.
     Nguyên thủy đồng bộ hóa cấp cao hơn, nếu có, vẫn được giữ
     trong khi có được nguyên thủy này.
     Nguyên thủy cấp thấp hơn không được giữ trong khi có được điều này
     nguyên thủy.
     Ví dụ: thao tác ghi pagecache sẽ thu được ánh xạ tệp,
     sau đó lấy và khóa một tờ giấy để sao chép nội dung mới.
     Nó cũng có thể khóa một đối tượng trạng thái folio nội bộ để cập nhật siêu dữ liệu.

Các yêu cầu khóa chính xác dành riêng cho hệ thống tập tin; cho
một số hoạt động nhất định, một số khóa này có thể được bỏ qua.
Tất cả những đề cập thêm về khóa là ZZ0000ZZ, không phải là bắt buộc.
Mỗi tác giả hệ thống tập tin phải tự tìm ra cách khóa.

Lỗi và hạn chế
====================

* Không hỗ trợ fscrypt.
 * Không hỗ trợ nén.
 * Chưa hỗ trợ cho fsverity.
 * Giả định chắc chắn rằng IO sẽ hoạt động giống như trên XFS.
 * Iomap ZZ0000ZZ có hoạt động với dữ liệu tệp không thông thường không?

Các bản vá chào mừng!