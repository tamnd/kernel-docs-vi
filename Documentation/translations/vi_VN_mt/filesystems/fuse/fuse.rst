.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/fuse/fuse.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Tổng quan về FUSE
=============

định nghĩa
===========

Hệ thống tập tin không gian người dùng:
  Một hệ thống tập tin trong đó dữ liệu và siêu dữ liệu được cung cấp bởi một hệ thống thông thường
  quá trình không gian người dùng.  Hệ thống tập tin có thể được truy cập bình thường thông qua
  giao diện hạt nhân.

Trình nền hệ thống tập tin:
  (Các) quy trình cung cấp dữ liệu và siêu dữ liệu của hệ thống tệp.

Gắn kết không có đặc quyền (hoặc gắn kết người dùng):
  Hệ thống tệp không gian người dùng được gắn bởi người dùng không có đặc quyền (không phải root).
  Trình nền hệ thống tập tin đang chạy với các đặc quyền của việc gắn kết
  người dùng.  NOTE: điều này không giống với các loại ngàm được phép sử dụng với "người dùng"
  tùy chọn trong /etc/fstab, điều này không được thảo luận ở đây.

Kết nối hệ thống tập tin:
  Một kết nối giữa daemon hệ thống tập tin và kernel.  các
  kết nối tồn tại cho đến khi daemon chết hoặc hệ thống tập tin bị hỏng
  số lượng.  Lưu ý rằng việc tách (hoặc lười umount) hệ thống tập tin
  ZZ0000ZZ có ngắt kết nối không, trong trường hợp này nó sẽ tồn tại cho đến khi
  tham chiếu cuối cùng đến hệ thống tập tin được phát hành.

Chủ sở hữu núi:
  Người dùng thực hiện việc gắn kết.

Người dùng:
  Người dùng đang thực hiện các hoạt động của hệ thống tập tin.

FUSE là gì?
=============

FUSE là khung hệ thống tệp không gian người dùng.  Nó bao gồm một hạt nhân
mô-đun (fuse.ko), thư viện không gian người dùng (libfuse.*) và tiện ích gắn kết
(fusermount).

Một trong những tính năng quan trọng nhất của FUSE là cho phép bảo mật,
gắn kết không có đặc quyền.  Điều này mở ra những khả năng mới cho việc sử dụng
hệ thống tập tin.  Một ví dụ điển hình là sshfs: một hệ thống tập tin mạng an toàn
sử dụng giao thức sftp.

Thư viện không gian người dùng và các tiện ích có sẵn từ
ZZ0000ZZ

Loại hệ thống tập tin
===============

Loại hệ thống tập tin được cung cấp cho mount(2) có thể là một trong những loại sau:

cầu chì
      Đây là cách thông thường để gắn hệ thống tập tin FUSE.  đầu tiên
      đối số của lệnh gọi hệ thống mount có thể chứa một chuỗi tùy ý,
      mà kernel không giải thích được.

cầu chì
      Hệ thống tập tin dựa trên thiết bị khối.  Lập luận đầu tiên của
      lệnh gọi hệ thống mount được hiểu là tên của thiết bị.

Tùy chọn gắn kết
=============

fd=N
  Bộ mô tả tệp được sử dụng để liên lạc giữa không gian người dùng
  hệ thống tập tin và hạt nhân.  Bộ mô tả tập tin phải được
  thu được bằng cách mở thiết bị FUSE ('/dev/fuse').

mã gốc=M
  Chế độ tệp gốc của hệ thống tệp ở dạng biểu diễn bát phân.

user_id=N
  Id người dùng số của chủ sở hữu gắn kết.

nhóm_id=N
  Id nhóm số của chủ sở hữu gắn kết.

mặc định_permissions
  Theo mặc định FUSE không kiểm tra quyền truy cập tệp,
  hệ thống tập tin được tự do thực hiện chính sách truy cập của nó hoặc để nó tự do
  cơ chế truy cập tệp cơ bản (ví dụ: trong trường hợp mạng
  hệ thống tập tin).  Tùy chọn này cho phép kiểm tra quyền, hạn chế
  truy cập dựa trên chế độ tập tin.  Nó thường hữu ích cùng với
  Tùy chọn gắn kết 'allow_other'.

allow_other
  Tùy chọn này ghi đè biện pháp bảo mật hạn chế quyền truy cập tệp
  cho người dùng gắn hệ thống tập tin.  Tùy chọn này theo mặc định chỉ
  được phép root, nhưng hạn chế này có thể được loại bỏ bằng
  (không gian người dùng) tùy chọn cấu hình.

max_read=N
  Với tùy chọn này, kích thước tối đa của thao tác đọc có thể được đặt.
  Mặc định là vô hạn.  Lưu ý rằng kích thước của yêu cầu đọc là
  dù sao cũng bị giới hạn ở 32 trang (là 128kbyte trên i386).

blksize=N
  Đặt kích thước khối cho hệ thống tập tin.  Mặc định là 512. Cái này
  tùy chọn chỉ hợp lệ cho các giá treo loại 'fuseblk'.

Kiểm soát hệ thống tập tin
==================

Có một hệ thống tệp điều khiển cho FUSE, có thể được gắn kết bởi ::

mount -tfusectl none /sys/fs/fuse/connections

Việc gắn nó vào thư mục '/sys/fs/fuse/connections' sẽ làm cho nó
tương thích ngược với các phiên bản trước đó.

Trong hệ thống tập tin điều khiển cầu chì, mỗi kết nối có một thư mục
được đặt tên bằng một số duy nhất.

Đối với mỗi kết nối, các tệp sau tồn tại trong thư mục này:

chờ đợi
	  Số lượng yêu cầu đang chờ chuyển tới
	  không gian người dùng hoặc đang được xử lý bởi daemon hệ thống tập tin.  Nếu có
	  không có hoạt động hệ thống tập tin và 'chờ' khác 0, thì
	  hệ thống tập tin bị treo hoặc bị bế tắc.

hủy bỏ
	  Viết bất cứ điều gì vào tập tin này sẽ hủy bỏ hệ thống tập tin
	  kết nối.  Điều này có nghĩa là tất cả các yêu cầu chờ đợi sẽ bị hủy bỏ
	  lỗi được trả về cho tất cả các yêu cầu bị hủy bỏ và yêu cầu mới.

max_background
          Số lượng yêu cầu nền tối đa có thể được xử lý
          tại một thời điểm. Khi số lượng yêu cầu nền đạt đến giới hạn này,
          các yêu cầu tiếp theo sẽ bị chặn cho đến khi một số yêu cầu được hoàn thành, có thể
          khiến hoạt động I/O bị đình trệ.

tắc nghẽn_ngưỡng
          Ngưỡng yêu cầu nền mà kernel xem xét
          hệ thống tập tin bị tắc nghẽn. Khi số lượng yêu cầu nền
          vượt quá giá trị này, kernel sẽ bỏ qua việc đọc trước không đồng bộ
          hoạt động, giảm tối ưu hóa việc đọc trước nhưng vẫn giữ được những điều cần thiết
          I/O, cũng như tạm dừng các hoạt động ghi lại không đồng bộ
          (WB_SYNC_NONE), trì hoãn việc xóa bộ đệm trang vào hệ thống tệp.

Chỉ chủ sở hữu của mount mới có thể đọc hoặc ghi những tập tin này.

Làm gián đoạn hoạt động của hệ thống tập tin
##################################

Nếu quá trình đưa ra yêu cầu hệ thống tập tin FUSE bị gián đoạn,
sau đây sẽ xảy ra:

- Nếu yêu cầu chưa được gửi đến không gian người dùng AND thì tín hiệu sẽ là
     gây tử vong (SIGKILL hoặc tín hiệu gây tử vong chưa được xử lý), thì yêu cầu sẽ là
     được xếp hàng đợi và trả về ngay lập tức.

- Nếu yêu cầu chưa được gửi đến không gian người dùng AND thì tín hiệu chưa được gửi
     gây tử vong thì cờ bị gián đoạn sẽ được đặt cho yêu cầu.  Khi nào
     yêu cầu đã được chuyển thành công đến không gian người dùng và
     cờ này được đặt, yêu cầu INTERRUPT sẽ được xếp hàng đợi.

- Nếu yêu cầu đã được gửi đến không gian người dùng thì INTERRUPT
     yêu cầu được xếp hàng đợi.

Các yêu cầu INTERRUPT được ưu tiên hơn các yêu cầu khác, vì vậy
hệ thống tập tin không gian người dùng sẽ nhận được các INTERRUPT được xếp hàng đợi trước bất kỳ INTERRUPT nào khác.

Hệ thống tệp không gian người dùng có thể bỏ qua hoàn toàn các yêu cầu INTERRUPT,
hoặc có thể tôn trọng họ bằng cách gửi phản hồi cho yêu cầu ZZ0000ZZ, kèm theo
lỗi được đặt thành EINTR.

Cũng có thể có một cuộc chạy đua giữa việc xử lý
yêu cầu ban đầu và yêu cầu INTERRUPT của nó.  Có hai khả năng:

1. Yêu cầu INTERRUPT được xử lý trước khi yêu cầu ban đầu được thực hiện
     đã xử lý

2. Yêu cầu INTERRUPT được xử lý sau khi yêu cầu ban đầu được xử lý
     đã được trả lời

Nếu hệ thống tập tin không thể tìm thấy yêu cầu ban đầu, nó sẽ đợi
một khoảng thời gian chờ và/hoặc một số yêu cầu mới đến, sau đó nó
sẽ trả lời yêu cầu INTERRUPT với lỗi EAGAIN.  Trong trường hợp
1) yêu cầu INTERRUPT sẽ được yêu cầu xếp hàng đợi.  Trong trường hợp 2) INTERRUPT
câu trả lời sẽ bị bỏ qua.

Hủy kết nối hệ thống tập tin
================================

Có thể rơi vào những tình huống nhất định trong đó hệ thống tập tin bị
không phản hồi.  Lý do cho điều này có thể là:

a) Triển khai hệ thống tập tin không gian người dùng bị hỏng

b) Kết nối mạng bị ngắt

c) Sự bế tắc ngẫu nhiên

d) Bế tắc độc hại

(Để biết thêm về c) và d) xem các phần sau)

Trong cả hai trường hợp này, việc hủy kết nối tới
hệ thống tập tin.  Có một số cách để làm điều này:

- Tiêu diệt daemon hệ thống tập tin.  Hoạt động trong trường hợp a) và b)

- Tiêu diệt daemon hệ thống tập tin và tất cả người dùng hệ thống tập tin.  Tác phẩm
    trong mọi trường hợp ngoại trừ một số bế tắc có hại

- Sử dụng umount bắt buộc (umount -f).  Hoạt động trong mọi trường hợp nhưng chỉ khi
    hệ thống tập tin vẫn được đính kèm (nó chưa được ngắt kết nối)

- Hủy bỏ hệ thống tập tin thông qua hệ thống tập tin điều khiển FUSE.  Hầu hết
    phương pháp mạnh mẽ, luôn hoạt động.

Các thú cưỡi không có đặc quyền hoạt động như thế nào?
==================================

Vì lệnh gọi hệ thống mount() là một hoạt động đặc quyền, nên một trình trợ giúp
chương trình (fusermount) là cần thiết, được cài đặt root setuid.

Ý nghĩa của việc cung cấp các mount không có đặc quyền là mount
chủ sở hữu không được phép sử dụng khả năng này để xâm phạm
hệ thống.  Các yêu cầu rõ ràng phát sinh từ việc này là:

A) chủ sở hữu thú cưỡi sẽ không thể nhận được các đặc quyền nâng cao với
    trợ giúp của hệ thống tập tin được gắn kết

B) chủ sở hữu thú cưỡi không được truy cập bất hợp pháp vào thông tin từ
    quy trình của người dùng khác và siêu người dùng

C) chủ sở hữu thú cưỡi không thể gây ra hành vi không mong muốn trong
    quy trình của người dùng khác hoặc siêu người dùng

Các yêu cầu được thực hiện như thế nào?
===============================

A) Chủ sở hữu thú cưỡi có thể nhận được các đặc quyền nâng cao bằng cách:

1. tạo một hệ thống tập tin chứa tập tin thiết bị, sau đó mở thiết bị này

2. tạo một hệ thống tập tin chứa ứng dụng suid hoặc sgid, sau đó thực thi ứng dụng này

Giải pháp là không cho phép mở file thiết bị và bỏ qua
    bit setuid và setgid khi thực thi chương trình.  Để đảm bảo điều này
    Fusermount luôn thêm "nosuid" và "nodev" vào các tùy chọn gắn kết
    dành cho các mount không có đặc quyền.

B) Nếu người dùng khác đang truy cập các tập tin hoặc thư mục trong
    hệ thống tập tin, các yêu cầu phục vụ trình nền của hệ thống tập tin có thể ghi lại
    trình tự và thời gian chính xác của các hoạt động được thực hiện.  Cái này
    chủ sở hữu mount không thể truy cập được thông tin, vì vậy điều này
    được coi là rò rỉ thông tin.

Lời giải cho vấn đề này sẽ được trình bày ở điểm 2) của C).

C) Có một số cách mà người sở hữu thú cưỡi có thể khiến
    hành vi không mong muốn trong quy trình của người dùng khác, chẳng hạn như:

1) gắn hệ thống tập tin lên một tập tin hoặc thư mục mà tập tin gắn kết
        chủ sở hữu không thể sửa đổi (hoặc chỉ có thể
        thực hiện các sửa đổi hạn chế).

Điều này được giải quyết trong Fusionmount, bằng cách kiểm tra quyền truy cập
        quyền trên điểm gắn kết và chỉ cho phép gắn kết nếu
        chủ sở hữu mount có thể thực hiện sửa đổi không giới hạn (có ghi
        quyền truy cập vào điểm gắn kết và điểm gắn kết không phải là "dính"
        thư mục)

2) Ngay cả khi giải quyết được 1) chủ sở hữu thú cưỡi vẫn có thể thay đổi hành vi
        các tiến trình của người dùng khác.

i) Nó có thể làm chậm hoặc trì hoãn vô thời hạn việc thực hiện một
            hoạt động hệ thống tập tin tạo DoS chống lại người dùng hoặc
            toàn bộ hệ thống.  Ví dụ: một ứng dụng sus khóa một
            tệp hệ thống, sau đó truy cập tệp trên máy chủ của chủ sở hữu mount
            hệ thống tập tin có thể bị dừng và do đó khiến hệ thống
            tập tin sẽ bị khóa vĩnh viễn.

ii) Nó có thể hiển thị các tập tin hoặc thư mục có độ dài không giới hạn, hoặc
             cấu trúc thư mục có độ sâu không giới hạn, có thể gây ra
             quy trình hệ thống chiếm hết dung lượng ổ đĩa, bộ nhớ hoặc các phần khác
             tài nguyên, một lần nữa gây ra ZZ0000ZZ.

Giải pháp cho vấn đề này cũng như B) là không cho phép các quy trình
	để truy cập vào hệ thống tập tin, điều này có thể không được thực hiện
	được giám sát hoặc thao túng bởi chủ sở hữu thú cưỡi.  Vì nếu
	chủ sở hữu gắn kết có thể theo dõi một quy trình, nó có thể thực hiện tất cả những điều trên
	không sử dụng ngàm FUSE, tiêu chí tương tự như được sử dụng trong
	ptrace có thể được sử dụng để kiểm tra xem một tiến trình có được phép truy cập hay không
	hệ thống tập tin hay không.

Lưu ý rằng việc kiểm tra ZZ0000ZZ không thực sự cần thiết để
	ngăn chặn C/2/i, chỉ cần kiểm tra xem chủ sở hữu mount có đủ không
	đặc quyền gửi tín hiệu đến quá trình truy cập
	hệ thống tập tin, vì ZZ0001ZZ có thể được sử dụng để đạt được hiệu ứng tương tự.

Tôi nghĩ những hạn chế này là không thể chấp nhận được?
===========================================

Nếu quản trị viên hệ thống đủ tin tưởng người dùng hoặc có thể đảm bảo thông qua người khác
biện pháp, các quy trình hệ thống đó sẽ không bao giờ đi vào không có đặc quyền
gắn kết, nó có thể nới lỏng giới hạn cuối cùng theo nhiều cách:

- Với tùy chọn cấu hình 'user_allow_other'. Nếu tùy chọn cấu hình này là
    được đặt, người dùng gắn kết có thể thêm tùy chọn gắn kết 'allow_other'
    vô hiệu hóa việc kiểm tra các quy trình của người dùng khác.

Không gian tên người dùng có sự tương tác không trực quan với 'allow_other':
    một người dùng không có đặc quyền - thường bị hạn chế gắn kết với
    'allow_other' - có thể làm như vậy trong không gian tên người dùng nơi họ ở
    đặc quyền. Nếu bất kỳ quá trình nào có thể truy cập vào giá trị 'allow_other' như vậy
    điều này sẽ cung cấp cho người dùng khả năng thao tác
    xử lý trong không gian tên người dùng nơi chúng không có đặc quyền. Vì điều này
    lý do 'allow_other' hạn chế quyền truy cập đối với người dùng trong cùng một người dùng
    hoặc một hậu duệ.

- Với tùy chọn mô-đun 'allow_sys_admin_access'. Nếu tùy chọn này là
    được thiết lập, các tiến trình của siêu người dùng có quyền truy cập không hạn chế vào các mount
    bất kể cài đặt allow_other hoặc không gian tên người dùng của
    người dùng gắn kết.

Lưu ý rằng cả hai sự nới lỏng này đều khiến hệ thống gặp nguy cơ
rò rỉ thông tin hoặc ZZ0000ZZ như được mô tả ở điểm B và C/2/i-ii trong phần
phần trước.

Kernel - giao diện không gian người dùng
============================

Sơ đồ sau đây cho thấy cách hoạt động của hệ thống tập tin (trong phần này
ví dụ hủy liên kết) được thực hiện trong FUSE. ::


Trình nền hệ thống tập tin ZZ0000ZZ FUSE
 ZZ0001ZZ
 ZZ0002ZZ >sys_read()
 ZZ0003ZZ >fuse_dev_read()
 ZZ0004ZZ >request_wait()
 ZZ0005ZZ [ngủ trên fc->chờq]
 ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ
 ZZ0009ZZ
 ZZ0010ZZ
 ZZ0011ZZ
 ZZ0012ZZ
 ZZ0013ZZ [đã thức dậy]
 ZZ0014ZZ
 ZZ0015ZZ
 ZZ0016ZZ <request_wait()
 ZZ0017ZZ [xóa yêu cầu khỏi fc->đang chờ xử lý]
 ZZ0018ZZ [yêu cầu sao chép để đọc bộ đệm]
 ZZ0019ZZ [thêm yêu cầu vào fc->đang xử lý]
 ZZ0020ZZ <fuse_dev_read()
 ZZ0021ZZ <sys_read()
 ZZ0022ZZ
 ZZ0023ZZ [thực hiện hủy liên kết]
 ZZ0024ZZ
 ZZ0025ZZ >sys_write()
 ZZ0026ZZ >fuse_dev_write()
 ZZ0027ZZ [tra cứu yêu cầu trong fc->đang xử lý]
 ZZ0028ZZ [xóa khỏi fc->đang xử lý]
 ZZ0029ZZ [sao chép bộ đệm ghi vào yêu cầu]
 ZZ0030ZZ [yêu cầu đánh thức->chờq]
 ZZ0031ZZ <fuse_dev_write()
 ZZ0032ZZ <sys_write()
 ZZ0033ZZ
 ZZ0034ZZ
 ZZ0035ZZ
 ZZ0036ZZ
 ZZ0037ZZ
 ZZ0038ZZ

.. note:: Everything in the description above is greatly simplified

Có một số cách để làm bế tắc hệ thống tập tin FUSE.
Vì chúng ta đang nói về các chương trình không gian người dùng không có đặc quyền,
phải làm gì đó về những điều này.

ZZ0000ZZ::

Trình nền hệ thống tập tin ZZ0001ZZ FUSE
 ZZ0002ZZ
 ZZ0003ZZ
 ZZ0004ZZ
 ZZ0005ZZ
 ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ <sys_read()
 ZZ0009ZZ >sys_unlink("/mnt/fuse/file")
 ZZ0010ZZ [thu được semaphore inode
 ZZ0011ZZ cho "tập tin"]
 ZZ0012ZZ ZZ0000ZZ

Giải pháp cho vấn đề này là cho phép hủy bỏ hệ thống tập tin.

ZZ0000ZZ


Cái này cần một hệ thống tập tin được chế tạo cẩn thận.  Đó là một biến thể trên
ở trên, chỉ có lệnh gọi lại hệ thống tập tin là không rõ ràng,
nhưng là do lỗi trang. ::

Chủ đề hệ thống tập tin ZZ0000ZZ Kamikaze 2
 ZZ0001ZZ
 ZZ0002ZZ [yêu cầu được phục vụ bình thường]
 ZZ0003ZZ
 ZZ0004ZZ [FLUSH kích hoạt cờ 'ma thuật']
 ZZ0005ZZ
 ZZ0006ZZ
 ZZ0007ZZ
 ZZ0008ZZ
 ZZ0009ZZ
 ZZ0010ZZ
 ZZ0011ZZ
 ZZ0012ZZ [đọc yêu cầu vào bộ đệm]
 ZZ0013ZZ [tạo tiêu đề trả lời trước addr]
 ZZ0014ZZ >sys_write(addr - độ dài tiêu đề)
 ZZ0015ZZ >fuse_dev_write()
 ZZ0016ZZ [tra cứu yêu cầu trong fc->đang xử lý]
 ZZ0017ZZ [xóa khỏi fc->đang xử lý]
 ZZ0018ZZ [sao chép bộ đệm ghi vào yêu cầu]
 ZZ0019ZZ >do_page_fault()
 ZZ0020ZZ [tìm hoặc tạo trang]
 ZZ0021ZZ [trang khóa]
 ZZ0022ZZ * DEADLOCK *

Giải pháp về cơ bản giống như trên.

Một vấn đề nữa là trong khi bộ đệm ghi đang được sao chép
theo yêu cầu, yêu cầu không được bị gián đoạn/hủy bỏ.  Đây là
vì địa chỉ đích của bản sao có thể không hợp lệ sau khi
yêu cầu đã trở lại.

Điều này được giải quyết bằng cách thực hiện sao chép một cách nguyên tử và cho phép hủy bỏ
trong khi (các) trang thuộc bộ đệm ghi bị lỗi
get_user_pages().  Cờ 'req->locked' cho biết khi nào bản sao được
diễn ra và việc hủy bỏ bị trì hoãn cho đến khi cờ này không được đặt.