.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/spufs/spufs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====
trò đùa
=====

Tên
====

spufs - hệ thống tập tin SPU


Sự miêu tả
===========

Hệ thống tệp SPU được sử dụng trên các máy PowerPC triển khai Cell
       Kiến trúc công cụ băng thông rộng để truy cập Bộ xử lý tổng hợp
       Đơn vị (SPU).

Hệ thống tập tin cung cấp một không gian tên tương tự như bộ nhớ chia sẻ posix hoặc
       hàng đợi tin nhắn. Người dùng có quyền ghi trên hệ thống tập tin
       có thể sử dụng spu_create(2) để thiết lập bối cảnh SPU trong thư mục gốc spufs.

Mỗi bối cảnh SPU được thể hiện bằng một thư mục chứa một
       tập hợp các tập tin. Những tập tin này có thể được sử dụng để thao tác trạng thái của
       logic SPU. Người dùng có thể thay đổi quyền trên các tệp đó, nhưng thực tế thì không.
       đồng minh thêm hoặc xóa tập tin.


Tùy chọn gắn kết
=============

uid=<uid>
              đặt người dùng sở hữu điểm gắn kết, mặc định là 0 (root).

gid=<gid>
              đặt nhóm sở hữu điểm gắn kết, mặc định là 0 (root).


Tập tin
=====

Các tập tin trong spufs chủ yếu tuân theo hành vi tiêu chuẩn của các hệ thống thông thường.
       lệnh gọi tem như đọc(2) hoặc viết(2), nhưng thường chỉ hỗ trợ một tập hợp con của
       các hoạt động được hỗ trợ trên các hệ thống tập tin thông thường. Danh sách này nêu chi tiết
       các hoạt động được hỗ trợ và những sai lệch so với hành vi trong
       trang man tương ứng.

Tất cả các tệp hỗ trợ thao tác read(2) cũng hỗ trợ readv(2) và
       tất cả các tệp hỗ trợ thao tác ghi (2) cũng hỗ trợ ghi (2).
       Tất cả các tệp đều hỗ trợ nhóm hoạt động access(2) và stat(2), nhưng
       chỉ các trường st_mode, st_nlink, st_uid và st_gid của struct stat
       chứa thông tin đáng tin cậy.

Tất cả các tệp đều hỗ trợ toán hạng chmod(2)/fchmod(2) và chown(2)/fchown(2)-
       nhưng sẽ không thể cấp các quyền trái với
       các hoạt động có thể, ví dụ: quyền truy cập đọc trên tệp wbox.

Bộ tập tin hiện tại là:


/mem
       nội dung của bộ nhớ lưu trữ cục bộ của SPU.   Đây có thể là
       được truy cập giống như một tập tin bộ nhớ chia sẻ thông thường và chứa cả mã và
       dữ liệu trong không gian địa chỉ của SPU.  Các hoạt động có thể có trên một
       mở tập tin mem là:

đọc(2), pread(2), viết(2), pwrite(2), lseek(2)
              Chúng hoạt động như được ghi lại, ngoại trừ seek(2),
              write(2) và pwrite(2) không được hỗ trợ sau khi kết thúc
              tập tin. Kích thước tệp là kích thước bộ nhớ cục bộ của SPU,
              thông thường là 256 kilobyte.

mmap(2)
              Ánh xạ mem vào không gian địa chỉ tiến trình cho phép truy cập vào
              Bộ nhớ cục bộ SPU trong không gian địa chỉ quy trình.  Chỉ
              Cho phép ánh xạ MAP_SHARED.


/mbox
       Hộp thư liên lạc từ SPU tới CPU đầu tiên. Tệp này ở chế độ chỉ đọc và
       có thể được đọc theo đơn vị 32 bit.  Tập tin chỉ có thể được sử dụng trong
       chế độ chặn và thậm chí nó còn thăm dò ý kiến() sẽ không chặn nó.   Điều có thể
       các thao tác trên một tệp mbox đang mở là:

đọc(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, read trả về -1 và
              đặt lỗi thành EINVAL.  Nếu không có dữ liệu trong thư
              hộp, giá trị trả về được đặt thành -1 và errno trở thành EAGAIN.
              Khi dữ liệu đã được đọc thành công, bốn byte được đặt vào
              bộ đệm dữ liệu và giá trị bốn được trả về.


/ibox
       Hộp thư liên lạc SPU tới CPU thứ hai. Tập tin này tương tự như
       tệp hộp thư đầu tiên, nhưng có thể được đọc ở chế độ chặn I/O và
       nhóm thăm dò các cuộc gọi hệ thống có thể được sử dụng để chờ đợi nó.  Điều có thể
       các thao tác trên tệp ibox đang mở là:

đọc(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, read trả về -1 và
              đặt lỗi thành EINVAL.  Nếu không có dữ liệu trong thư
              hộp và bộ mô tả tập tin đã được mở bằng O_NONBLOCK,
              giá trị trả về được đặt thành -1 và errno trở thành EAGAIN.

Nếu không có dữ liệu trong hộp thư và tập tin
              bộ mô tả đã được mở mà không có O_NONBLOCK, cuộc gọi sẽ
              chặn cho đến khi SPU ghi vào kênh hộp thư ngắt của nó.
              Khi dữ liệu đã được đọc thành công, bốn byte được đặt vào
              bộ đệm dữ liệu và giá trị bốn được trả về.

thăm dò ý kiến(2)
              Cuộc thăm dò trên tệp ibox trả về (POLLIN | POLLRDNORM) bất cứ khi nào
              dữ liệu có sẵn để đọc.


/wbox
       Hộp thư giao tiếp CPU tới SPU. Nó chỉ ghi và có thể được viết
       theo đơn vị 32 bit. Nếu hộp thư đầy, write() sẽ chặn và
       cuộc thăm dò có thể được sử dụng để chờ nó trở nên trống rỗng.   Điều có thể
       các thao tác trên một tệp wbox đang mở là: write(2) Nếu số lượng nhỏ hơn
       bốn được yêu cầu, ghi trả về -1 và đặt errno thành EINVAL.  Nếu có
       không còn chỗ trống trong hộp thư và bộ mô tả tập tin đã được
       được mở bằng O_NONBLOCK, giá trị trả về được đặt thành -1 và errno trở thành
       EAGAIN.

Nếu không còn chỗ trống trong hộp thư và bộ mô tả tệp
       đã được mở mà không có O_NONBLOCK, cuộc gọi sẽ bị chặn cho đến khi SPU
       đọc từ kênh hộp thư PPE của nó.  Khi dữ liệu đã được đọc thành công-
       đầy đủ, bốn byte được đặt trong bộ đệm dữ liệu và giá trị bốn là
       đã quay trở lại.

thăm dò ý kiến(2)
              Cuộc thăm dò trên tệp ibox trả về (POLLOUT | POLLWRNORM) bất cứ khi nào
              có chỗ trống để viết.


/mbox_stat, /ibox_stat, /wbox_stat
       Các tệp chỉ đọc chứa độ dài của hàng đợi hiện tại, tức là làm thế nào
       có thể đọc được bao nhiêu từ từ mbox hoặc ibox hoặc có thể đọc được bao nhiêu từ
       được ghi vào wbox mà không bị chặn.  Các tập tin chỉ có thể được đọc ở dạng 4 byte
       đơn vị và trả về một số nguyên nhị phân lớn cuối.  Điều có thể
       các thao tác trên tệp ZZ0000ZZ đang mở là:

đọc(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, read trả về -1 và
              đặt lỗi thành EINVAL.  Mặt khác, giá trị bốn byte được đặt trong
              bộ đệm dữ liệu, chứa số phần tử có thể được
              đọc từ (đối với mbox_stat và ibox_stat) hoặc ghi vào (đối với
              wbox_stat) hộp thư tương ứng mà không chặn hoặc dẫn đến
              trong EAGAIN.


/npc, /decr, /decr_status, /spu_tag_mask, /event_mask, /srr0
       Các thanh ghi nội bộ của SPU. Biểu diễn là một chuỗi ASCII
       với giá trị số của lệnh tiếp theo sẽ được thực hiện.  Những cái này
       có thể được sử dụng ở chế độ đọc/ghi để gỡ lỗi, nhưng hoạt động bình thường của
       các chương trình không nên dựa vào chúng vì quyền truy cập vào bất kỳ chương trình nào ngoại trừ
       npc yêu cầu lưu ngữ cảnh SPU và do đó rất kém hiệu quả.

Nội dung của các tập tin này là:

==========================================================
       Bộ đếm chương trình tiếp theo của npc
       Bộ giảm tốc SPU
       decr_status Trạng thái giảm dần
       mặt nạ thẻ spu_tag_mask MFC dành cho SPU DMA
       event_mask Mặt nạ sự kiện cho các ngắt SPU
       srr0 Ngắt Thanh ghi địa chỉ trả về
       ==========================================================


Các hoạt động có thể có trên một npc mở, decr, decr_status,
       Tệp spu_tag_mask, event_mask hoặc srr0 là:

đọc(2)
              Khi số lượng được cung cấp cho cuộc gọi đọc ngắn hơn số lượng
              độ dài cần thiết cho giá trị con trỏ cộng với ký tự dòng mới,
              lần đọc tiếp theo từ cùng một bộ mô tả tập tin sẽ dẫn đến
              hoàn thành chuỗi, bất kể những thay đổi trong sổ đăng ký bởi
              một tác vụ SPU đang chạy.  Khi một chuỗi hoàn chỉnh đã được đọc, tất cả
              các thao tác đọc tiếp theo sẽ trả về 0 byte và một tệp mới
              bộ mô tả cần được mở để đọc lại giá trị.

viết(2)
              Thao tác ghi vào tệp sẽ dẫn đến việc thiết lập thanh ghi thành
              giá trị đã cho trong chuỗi. Chuỗi được phân tích cú pháp từ
              bắt đầu đến ký tự không phải số đầu tiên hoặc kết thúc ký tự
              bộ đệm.  Ghi tiếp theo vào cùng một bộ mô tả tập tin ghi đè
              cài đặt trước đó.


/fpcr
       Tệp này cung cấp quyền truy cập vào Đăng ký kiểm soát và trạng thái dấu phẩy động.
       ter dưới dạng một tệp dài bốn byte. Các thao tác trên tệp fpcr là:

đọc(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, read trả về -1 và
              đặt lỗi thành EINVAL.  Mặt khác, giá trị bốn byte được đặt trong
              bộ đệm dữ liệu, chứa giá trị hiện tại của đăng ký fpcr
              ter.

viết(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, hãy viết trả về -1 và
              đặt lỗi thành EINVAL.  Nếu không, giá trị bốn byte sẽ được sao chép
              từ bộ đệm dữ liệu, cập nhật giá trị của thanh ghi fpcr.


/tín hiệu1, /tín hiệu2
       Hai kênh thông báo tín hiệu của SPU.  Đây là đọc-ghi
       các tập tin hoạt động trên một từ 32 bit.  Ghi vào một trong những tập tin này
       kích hoạt một ngắt trên SPU.  Giá trị được ghi vào tín hiệu
       các tập tin có thể được đọc từ SPU thông qua kênh đọc hoặc từ người dùng máy chủ
       không gian thông qua tập tin.  Sau khi SPU đọc giá trị, nó
       được đặt lại về 0.  Các thao tác có thể thực hiện trên tín hiệu mở1 hoặc sig-
       tập tin nal2 là:

đọc(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, read trả về -1 và
              đặt lỗi thành EINVAL.  Mặt khác, giá trị bốn byte được đặt trong
              bộ đệm dữ liệu, chứa giá trị hiện tại của
              thanh ghi thông báo tín hiệu.

viết(2)
              Nếu yêu cầu số lượng nhỏ hơn 4, hãy viết trả về -1 và
              đặt lỗi thành EINVAL.  Nếu không, giá trị bốn byte sẽ được sao chép
              từ bộ đệm dữ liệu, cập nhật giá trị của tín hiệu đã chỉ định
              đăng ký thông báo.  Thanh ghi thông báo tín hiệu sẽ
              được thay thế bằng dữ liệu đầu vào hoặc sẽ được cập nhật vào
              theo bit HOẶC của giá trị cũ và dữ liệu đầu vào, tùy thuộc vào
              nội dung của signal1_type hoặc signal2_type tương ứng,
              tập tin.


/tín hiệu1_type, /tín hiệu2_type
       Hai tệp này thay đổi hành vi của thông báo signal1 và signal2.
       tập tin cation.  Nó chứa một chuỗi số ASCII được đọc là
       là "1" hoặc "0".  Ở chế độ 0 (ghi đè), phần cứng sẽ thay thế
       nội dung của kênh tín hiệu với dữ liệu được ghi vào nó.  trong
       chế độ 1 (logic OR), phần cứng tích lũy các bit phụ
       thường xuyên được viết cho nó.  Các hoạt động có thể có trên tín hiệu mở1_type
       hoặc tệp signal2_type là:

đọc(2)
              Khi số lượng được cung cấp cho cuộc gọi đọc ngắn hơn số lượng
              độ dài cần thiết cho chữ số cộng với ký tự dòng mới, subse-
              các lần đọc quent từ cùng một bộ mô tả tập tin sẽ dẫn đến kết quả là com-
              xếp chuỗi.  Khi một chuỗi hoàn chỉnh đã được đọc, tất cả
              các thao tác đọc tiếp theo sẽ trả về 0 byte và một tệp mới
              bộ mô tả cần được mở để đọc lại giá trị.

viết(2)
              Thao tác ghi vào tệp sẽ dẫn đến việc thiết lập thanh ghi thành
              giá trị đã cho trong chuỗi. Chuỗi được phân tích cú pháp từ
              bắt đầu đến ký tự không phải số đầu tiên hoặc kết thúc ký tự
              bộ đệm.  Ghi tiếp theo vào cùng một bộ mô tả tập tin ghi đè
              cài đặt trước đó.


Ví dụ
========
mục /etc/fstab
              không /spu spufs gid=spu 0 0


tác giả
=======
Arnd Bergmann <arndb@de.ibm.com>, Mark Nutter <mnutter@us.ibm.com>,
       Ulrich Weigand <Ulrich.Weigand@de.ibm.com>

Xem thêm
========
khả năng(7), close(2), spu_create(2), spu_run(2), spufs(7)