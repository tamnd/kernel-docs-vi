.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/journalling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Nhật ký Linux API
=========================

Tổng quan
---------

Chi tiết
~~~~~~~~

Lớp nhật ký rất dễ sử dụng. Trước hết bạn cần tạo một
cấu trúc dữ liệu tạp chí_t. Có hai cuộc gọi để thực hiện việc này phụ thuộc vào
cách bạn quyết định phân bổ phương tiện vật lý mà tạp chí sử dụng
cư trú. Lệnh gọi jbd2_journal_init_inode() dành cho các tạp chí được lưu trữ trong
các nút hệ thống tập tin hoặc có thể sử dụng lệnh gọi jbd2_journal_init_dev()
dành cho nhật ký được lưu trữ trên thiết bị thô (trong một phạm vi khối liên tục). A
tạp chí_t là một typedef cho một con trỏ cấu trúc, vì vậy khi cuối cùng bạn
xong nhớ gọi jbd2_journal_destroy() trên đó để giải phóng
bất kỳ bộ nhớ kernel đã sử dụng nào.

Khi bạn đã có đối tượng Journal_t, bạn cần 'gắn kết' hoặc tải
tập tin tạp chí. Lớp nhật ký mong đợi không gian cho tạp chí
đã được phân bổ và khởi tạo đúng cách bởi các công cụ không gian người dùng.
Khi tải nhật ký bạn phải gọi jbd2_journal_load() để xử lý
nội dung tạp chí. Nếu hệ thống tệp khách hàng phát hiện nội dung tạp chí
không cần phải xử lý (hoặc thậm chí không cần có nội dung hợp lệ), nó
có thể gọi jbd2_journal_wipe() để xóa nội dung tạp chí trước
gọi jbd2_journal_load().

Lưu ý rằng các cuộc gọi jbd2_journal_wipe(..,0)
jbd2_journal_skip_recovery() cho bạn nếu phát hiện bất kỳ khoản nợ nào
giao dịch trong tạp chí và tương tự jbd2_journal_load() sẽ
gọi jbd2_journal_recover() nếu cần. Tôi khuyên bạn nên đọc
ext4_load_journal() trong fs/ext4/super.c để biết ví dụ ở giai đoạn này.

Bây giờ bạn có thể tiếp tục và bắt đầu sửa đổi hệ thống tập tin cơ bản.
Hầu hết.

Bạn vẫn cần phải ghi lại những thay đổi trong hệ thống tập tin của mình, việc này đã được thực hiện
bằng cách gói chúng vào các giao dịch. Ngoài ra bạn cũng cần phải bọc
việc sửa đổi từng bộ đệm bằng các lệnh gọi đến lớp nhật ký,
để nó biết những sửa đổi bạn thực sự đang thực hiện là gì. để làm
việc này sử dụng jbd2_journal_start() để trả về một thẻ xử lý giao dịch.

jbd2_journal_start() và đối tác của nó là jbd2_journal_stop(),
cho biết sự kết thúc của giao dịch là các cuộc gọi có thể lồng nhau, vì vậy bạn có thể
nhập lại giao dịch nếu cần, nhưng hãy nhớ rằng bạn phải gọi
jbd2_journal_stop() cùng số lần như
jbd2_journal_start() trước khi giao dịch hoàn tất (hoặc hơn
chính xác rời khỏi giai đoạn cập nhật). Ext4/VFS sử dụng tính năng này để
đơn giản hóa việc xử lý việc làm bẩn inode, hỗ trợ hạn ngạch, v.v.

Bên trong mỗi giao dịch, bạn cần bao gồm các sửa đổi đối với
bộ đệm riêng lẻ (khối). Trước khi bắt đầu sửa đổi bộ đệm, bạn
cần gọi jbd2_journal_get_create_access() /
jbd2_journal_get_write_access() /
jbd2_journal_get_undo_access() nếu thích hợp, điều này cho phép
lớp nhật ký để sao chép phần chưa sửa đổi
dữ liệu nếu cần. Suy cho cùng, bộ đệm có thể là một phần của bộ đệm trước đó
giao dịch không cam kết. Tại thời điểm này, cuối cùng bạn đã sẵn sàng sửa đổi một
đệm và sau khi đã hoàn tất, bạn cần gọi
jbd2_journal_dirty_metadata(). Hoặc nếu bạn đã yêu cầu quyền truy cập vào một
bộ đệm mà bạn biết giờ đây cần được đẩy lùi về phía sau lâu hơn
thiết bị bạn có thể gọi jbd2_journal_forget() theo cách tương tự như bạn
có thể đã sử dụng bforget() trong quá khứ.

Một jbd2_journal_flush() có thể được gọi bất cứ lúc nào để cam kết và
kiểm tra tất cả các giao dịch của bạn.

Sau đó, vào thời điểm umount, trong put_super() bạn có thể gọi
jbd2_journal_destroy() để dọn sạch đối tượng nhật ký trong lõi của bạn.

Thật không may, có một số cách mà lớp tạp chí có thể gây ra
bế tắc. Điều đầu tiên cần lưu ý là mỗi nhiệm vụ chỉ có thể có một
giao dịch chưa thanh toán duy nhất tại một thời điểm, hãy nhớ không có gì cam kết
cho đến jbd2_journal_stop() ngoài cùng. Điều này có nghĩa là bạn phải hoàn thành
giao dịch ở cuối mỗi tệp/inode/địa chỉ, v.v. thao tác bạn
thực hiện để hệ thống ghi nhật ký không được nhập lại vào một hệ thống khác
tạp chí. Vì các giao dịch không thể được lồng/theo nhóm trên nhiều nền tảng khác nhau.
các tạp chí và hệ thống tập tin khác không phải của bạn (chẳng hạn như ext4) có thể
được sửa đổi trong một syscall sau này.

Trường hợp thứ hai cần lưu ý là jbd2_journal_start() có thể chặn
nếu không có đủ chỗ trong nhật ký cho giao dịch của bạn (dựa trên
trên thông số nblocks đã qua) - khi nó chặn nó chỉ (!) cần đợi
để các giao dịch hoàn thành và được cam kết từ các nhiệm vụ khác, vì vậy
về cơ bản chúng tôi đang đợi jbd2_journal_stop(). Vì vậy để tránh
bế tắc bạn phải xử lý jbd2_journal_start() /
jbd2_journal_stop() như thể chúng là các ẩn dụ và đưa chúng vào
quy tắc đặt hàng semaphore của bạn để ngăn chặn
bế tắc. Lưu ý rằng jbd2_journal_extend() có tính năng chặn tương tự
hành vi đối với jbd2_journal_start() để bạn có thể bế tắc ở đây giống như
dễ dàng như trên jbd2_journal_start().

Cố gắng dự trữ đúng số khối trong lần đầu tiên. ;-). Điều này sẽ
là số khối tối đa bạn sẽ chạm vào trong này
giao dịch. Tôi khuyên bạn nên xem ít nhất ext4_jbd.h để xem
cơ sở mà ext4 sử dụng để đưa ra các quyết định này.

Một điều rắc rối khác cần chú ý là việc phân bổ khối trên đĩa của bạn
chiến lược. Tại sao? Bởi vì, nếu bạn thực hiện xóa, bạn cần đảm bảo rằng bạn
chưa sử dụng lại bất kỳ khối giải phóng nào cho đến khi giải phóng giao dịch
các khối này cam kết. Nếu bạn sử dụng lại các khối này và xảy ra sự cố,
không có cách nào để khôi phục nội dung của các khối được phân bổ lại tại
kết thúc giao dịch được cam kết đầy đủ cuối cùng. Một cách làm đơn giản
điều này là để đánh dấu các khối là miễn phí trong phân bổ khối trong bộ nhớ nội bộ
cấu trúc chỉ sau khi giao dịch giải phóng chúng cam kết. Sử dụng Ext4
tạp chí cam kết gọi lại cho mục đích này.

Với các lệnh gọi lại cam kết nhật ký, bạn có thể yêu cầu lớp ghi nhật ký gọi
chức năng gọi lại khi giao dịch cuối cùng được chuyển vào đĩa,
để bạn có thể thực hiện một số công việc quản lý của riêng mình. Bạn hỏi tờ báo
lớp để gọi lại cuộc gọi lại bằng cách cài đặt đơn giản
Con trỏ hàm ZZ0000ZZ và hàm đó là
được gọi sau mỗi lần cam kết giao dịch.

JBD2 cũng cung cấp cách chặn tất cả các cập nhật giao dịch thông qua
jbd2_journal_lock_updates() /
jbd2_journal_unlock_updates(). Ext4 sử dụng điều này khi nó muốn
cửa sổ với fs sạch sẽ và ổn định trong giây lát. Ví dụ.

::


jbd2_journal_lock_updates() //ngăn chặn những điều mới xảy ra..
        jbd2_journal_flush() // kiểm tra mọi thứ.
        ..do stuff on stable fs
jbd2_journal_unlock_updates() // tiếp tục sử dụng hệ thống tập tin.

Cơ hội lạm dụng và tấn công DOS bằng cách này là hiển nhiên,
nếu bạn cho phép không gian người dùng không có đặc quyền kích hoạt các đường dẫn mã có chứa
những cuộc gọi này.

Cam kết nhanh
~~~~~~~~~~~~~

JBD2 cũng cho phép bạn thực hiện các cam kết delta cụ thể của hệ thống tệp được gọi là
cam kết nhanh chóng. Để sử dụng các cam kết nhanh, bạn sẽ cần phải thiết lập sau
cuộc gọi lại thực hiện công việc tương ứng:

ZZ0000ZZ: Chức năng dọn dẹp được gọi sau mỗi lần xác nhận đầy đủ và
cam kết nhanh chóng.

ZZ0000ZZ: Chức năng phát lại được gọi để phát lại cam kết nhanh
khối.

Hệ thống tập tin có thể tự do thực hiện các cam kết nhanh chóng khi nào nó muốn miễn là nó
được JBD2 cho phép làm như vậy bằng cách gọi hàm
ZZ0000ZZ. Sau khi một cam kết nhanh được thực hiện, khách hàng
hệ thống tập tin sẽ thông báo cho JBD2 về nó bằng cách gọi
ZZ0001ZZ. Nếu hệ thống tập tin muốn JBD2 thực hiện đầy đủ
cam kết ngay sau khi dừng cam kết nhanh, nó có thể thực hiện bằng cách gọi
ZZ0002ZZ. Điều này rất hữu ích nếu hoạt động cam kết nhanh
không thành công vì lý do nào đó và cách duy nhất để đảm bảo tính nhất quán là JBD2
thực hiện đầy đủ cam kết truyền thống.

Chức năng trợ giúp JBD2 để quản lý bộ đệm cam kết nhanh. Hệ thống tập tin có thể sử dụng
ZZ0000ZZ và ZZ0001ZZ để phân bổ
và đợi IO hoàn thành bộ đệm cam kết nhanh.

Hiện tại, chỉ Ext4 thực hiện các cam kết nhanh. Để biết chi tiết về việc thực hiện nó
về các cam kết nhanh, vui lòng tham khảo các nhận xét cấp cao nhất trong
fs/ext4/fast_commit.c.

Bản tóm tắt
~~~~~~~~~~~

Sử dụng nhật ký là vấn đề bao hàm những thay đổi bối cảnh khác nhau,
là mỗi lần gắn kết, mỗi lần sửa đổi (giao dịch) và mỗi lần thay đổi
đệm để thông báo cho lớp nhật ký về chúng.

Kiểu dữ liệu
------------

Lớp nhật ký sử dụng typedefs để 'ẩn' các định nghĩa cụ thể
của các kết cấu được sử dụng. Là khách hàng của lớp JBD2, bạn chỉ có thể tin cậy
về việc sử dụng con trỏ như một loại bánh quy ma thuật nào đó. Rõ ràng là
việc ẩn không được thực thi vì đây là 'C'.

Cấu trúc
~~~~~~~~~~

.. kernel-doc:: include/linux/jbd2.h
   :internal:

Chức năng
---------

Các chức năng ở đây được chia thành hai nhóm ảnh hưởng đến tạp chí
nói chung và những thứ được sử dụng để quản lý giao dịch

Cấp tạp chí
~~~~~~~~~~~~~

.. kernel-doc:: fs/jbd2/journal.c
   :export:

.. kernel-doc:: fs/jbd2/recovery.c
   :internal:

Cấp độ giao dịch
~~~~~~~~~~~~~~~~~~

.. kernel-doc:: fs/jbd2/transaction.c

Xem thêm
--------

ZZ0000ZZ

ZZ0000ZZ

