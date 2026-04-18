.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysrq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hack khóa yêu cầu hệ thống Linux Magic
====================================

Tài liệu cho sysrq.c

Khóa SysRq kỳ diệu là gì?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đó là tổ hợp phím 'ma thuật' mà bạn có thể nhấn mà hạt nhân sẽ phản hồi
bất kể nó đang làm gì, trừ khi nó bị khóa hoàn toàn.

Làm cách nào để kích hoạt khóa SysRq kỳ diệu?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn cần nói "có" với 'Magic SysRq key (CONFIG_MAGIC_SYSRQ)' khi
cấu hình hạt nhân. Khi chạy kernel có SysRq được biên dịch,
/proc/sys/kernel/sysrq kiểm soát các hàm được phép gọi thông qua
khóa SysRq. Giá trị mặc định trong tệp này được đặt bởi
Biểu tượng cấu hình CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE, mặc định
đến 1. Đây là danh sách các giá trị có thể có trong /proc/sys/kernel/sysrq:

- 0 - tắt hoàn toàn sysrq
   - 1 - kích hoạt tất cả các chức năng của sysrq
   - >1 - bitmask của các hàm sysrq được phép (xem bên dưới để biết hàm chi tiết
     mô tả)::

2 = 0x2 - cho phép kiểm soát mức ghi nhật ký của bảng điều khiển
          4 = 0x4 - bật điều khiển bàn phím (SAK, unraw)
          8 = 0x8 - cho phép gỡ lỗi các quá trình, v.v.
         16 = 0x10 - bật lệnh đồng bộ
         32 = 0x20 - cho phép gắn lại chỉ đọc
         64 = 0x40 - cho phép báo hiệu các tiến trình (thuật ngữ, kill, oom-kill)
        128 = 0x80 - cho phép khởi động lại/tắt nguồn
        256 = 0x100 - cho phép xử lý tất cả các tác vụ RT

Bạn có thể đặt giá trị trong tệp bằng lệnh sau ::

echo "số" >/proc/sys/kernel/sysrq

Số có thể được viết ở đây dưới dạng thập phân hoặc thập lục phân
với tiền tố 0x. CONFIG_MAGIC_SYSRQ_DEFAULT_ENABLE phải luôn như vậy
được viết dưới dạng thập lục phân.

Lưu ý rằng giá trị của ZZ0000ZZ chỉ ảnh hưởng đến lệnh gọi
thông qua một bàn phím. Việc gọi bất kỳ hoạt động nào thông qua ZZ0001ZZ đều
luôn được cho phép (bởi người dùng có đặc quyền quản trị viên).

Làm cách nào để sử dụng phím SysRq kỳ diệu?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Trên x86
	Bạn nhấn tổ hợp phím ZZ0000ZZ.

	.. note::
	   Some
           keyboards may not have a key labeled 'SysRq'. The 'SysRq' key is
           also known as the 'Print Screen' key. Also some keyboards cannot
	   handle so many keys being pressed at the same time, so you might
	   have better luck with press `Alt`, press `SysRq`,
	   release `SysRq`, press `<command key>`, release everything.

Trên SPARC
	Bạn nhấn ZZ0000ZZ, tôi tin vậy.

Trên bảng điều khiển nối tiếp (chỉ các cổng nối tiếp tiêu chuẩn kiểu PC)
        Bạn gửi ZZ0000ZZ, sau đó trong vòng 5 giây sẽ có một phím lệnh. Đang gửi
        ZZ0001ZZ hai lần được hiểu là BREAK bình thường.

Trên PowerPC
	Nhấn ZZ0000ZZ (hoặc ZZ0001ZZ) - ZZ0002ZZ.
        ZZ0003ZZ (hoặc ZZ0004ZZ) - ZZ0005ZZ có thể đủ.

Mặt khác
	Nếu bạn biết các tổ hợp phím cho các kiến trúc khác, vui lòng
	gửi một bản vá để được đưa vào phần này.

Trên tất cả
	Viết một ký tự đơn vào /proc/sysrq-trigger.
	Chỉ ký tự đầu tiên được xử lý, phần còn lại của chuỗi được xử lý
	bị phớt lờ. Tuy nhiên không nên viết thêm bất kỳ ký tự nào
	vì hành vi không được xác định và có thể thay đổi trong các phiên bản tương lai.
	Ví dụ.::

echo t > /proc/sysrq-trigger

Ngoài ra, hãy viết nhiều ký tự có dấu gạch dưới phía trước.
	Bằng cách này, tất cả các ký tự sẽ được xử lý. Ví dụ.::

echo _reisub > /proc/sysrq-trigger

ZZ0000ZZ phân biệt chữ hoa chữ thường.

Các phím 'lệnh' là gì?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

============ =========================================================================
Chức năng lệnh
============ =========================================================================
ZZ0000ZZ Sẽ khởi động lại hệ thống ngay lập tức mà không cần đồng bộ hóa hoặc ngắt kết nối
            đĩa của bạn.

ZZ0000ZZ Sẽ thực hiện một sự cố hệ thống và một kết xuất sự cố sẽ được thực hiện
            nếu được cấu hình.

ZZ0000ZZ Hiển thị tất cả các khóa được giữ.

ZZ0000ZZ Gửi SIGTERM tới tất cả các quy trình, ngoại trừ init.

ZZ0000ZZ Sẽ gọi kẻ giết người oom để tiêu diệt một quá trình hog bộ nhớ, nhưng không
	    hoảng sợ nếu không có gì có thể bị giết.

ZZ0000ZZ Được sử dụng bởi kgdb (trình gỡ lỗi kernel)

ZZ0000ZZ Sẽ hiển thị trợ giúp (thực ra là bất kỳ phím nào khác ngoài những phím được liệt kê
            ở đây sẽ hiển thị trợ giúp. nhưng ZZ0001ZZ rất dễ nhớ :-)

ZZ0000ZZ Gửi SIGKILL tới tất cả các quy trình, ngoại trừ init.

ZZ0000ZZ Buộc phải "Làm tan băng" - hệ thống tập tin bị đóng băng bởi FIFREEZE ioctl.

Khóa truy cập an toàn ZZ0000ZZ (SAK) Giết tất cả các chương trình trên máy ảo hiện tại
            bảng điều khiển. NOTE: Xem các bình luận quan trọng bên dưới trong phần SAK.

ZZ0000ZZ Hiển thị dấu vết ngược ngăn xếp cho tất cả các CPU đang hoạt động.

ZZ0000ZZ Sẽ chuyển thông tin bộ nhớ hiện tại vào bảng điều khiển của bạn.

ZZ0000ZZ Được sử dụng để thực hiện các tác vụ RT dễ dàng

ZZ0000ZZ Sẽ tắt hệ thống của bạn (nếu được định cấu hình và hỗ trợ).

ZZ0000ZZ Sẽ kết xuất các thanh ghi và cờ hiện tại vào bảng điều khiển của bạn.

ZZ0000ZZ Sẽ kết xuất theo danh sách CPU của tất cả các đồng hồ đo thời gian có vũ trang (nhưng NOT thông thường
            time_list tính giờ) và thông tin chi tiết về tất cả
            thiết bị sự kiện đồng hồ.

ZZ0000ZZ Tắt chế độ thô của bàn phím và đặt thành XLATE.

ZZ0000ZZ Sẽ cố gắng đồng bộ hóa tất cả các hệ thống tệp được gắn.

ZZ0000ZZ Sẽ kết xuất danh sách các nhiệm vụ hiện tại và thông tin của chúng vào
            bảng điều khiển.

ZZ0000ZZ Sẽ cố gắng kết nối lại tất cả các hệ thống tệp được gắn ở chế độ chỉ đọc.

ZZ0000ZZ Khôi phục mạnh mẽ bảng điều khiển bộ đệm khung
ZZ0001ZZ gây ra kết xuất bộ đệm ETM [dành riêng cho ARM]

ZZ0000ZZ Kết xuất các tác vụ ở trạng thái không bị gián đoạn (bị chặn).

ZZ0000ZZ Được sử dụng bởi giao diện xmon trên nền tảng ppc/powerpc.
            Hiển thị các thanh ghi PMU toàn cầu trên sparc64.
            Kết xuất tất cả các mục TLB trên MIPS.

ZZ0000ZZ Hiển thị các thanh ghi CPU toàn cầu [SPARC-64 cụ thể]

ZZ0000ZZ Kết xuất bộ đệm ftrace

ZZ0000ZZ-ZZ0001ZZ Đặt mức nhật ký bảng điều khiển, kiểm soát thông báo kernel nào
            sẽ được in ra bảng điều khiển của bạn. (Ví dụ: ZZ0002ZZ sẽ tạo ra
            nó để chỉ những tin nhắn khẩn cấp như PANIC hoặc OOPSes mới có thể
            đưa nó vào bảng điều khiển của bạn.)

ZZ0000ZZ Phát lại thông báo nhật ký kernel trên bảng điều khiển.
============ =========================================================================

Được rồi, vậy tôi có thể sử dụng chúng để làm gì?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chà, unraw(r) rất tiện dụng khi máy chủ X hoặc chương trình svgalib của bạn gặp sự cố.

sak(k) (Khóa truy cập an toàn) rất hữu ích khi bạn muốn chắc chắn rằng không có
chương trình trojan chạy trên bảng điều khiển có thể lấy được mật khẩu của bạn
khi bạn cố gắng đăng nhập. Nó sẽ giết tất cả các chương trình trên bảng điều khiển nhất định,
do đó cho phép bạn đảm bảo rằng lời nhắc đăng nhập mà bạn nhìn thấy thực sự là
cái từ init, không phải chương trình trojan nào đó.

.. important::

   In its true form it is not a true SAK like the one in a
   c2 compliant system, and it should not be mistaken as
   such.

Có vẻ như những người khác thấy nó hữu ích vì (Khóa chú ý hệ thống)
hữu ích khi bạn muốn thoát khỏi một chương trình không cho phép bạn chuyển đổi bảng điều khiển.
(Ví dụ: X hoặc chương trình svgalib.)

ZZ0000ZZ rất tốt khi bạn không thể tắt máy, nó tương đương
bằng cách nhấn nút "đặt lại".

ZZ0000ZZ có thể được sử dụng để kích hoạt kết xuất sự cố theo cách thủ công khi hệ thống bị treo.
Lưu ý rằng điều này chỉ gây ra sự cố nếu không có sẵn cơ chế kết xuất.

ZZ0000ZZ rất tiện dụng trước khi kéo phương tiện có thể tháo rời hoặc sau khi sử dụng phương tiện cứu hộ
shell không cho phép tắt máy dễ dàng -- nó sẽ đảm bảo dữ liệu của bạn được
được ghi vào đĩa một cách an toàn. Lưu ý rằng quá trình đồng bộ hóa chưa diễn ra cho đến khi bạn thấy
"OK" và "Xong" xuất hiện trên màn hình.

ZZ0000ZZ có thể được sử dụng để đánh dấu hệ thống tập tin là đã được ngắt kết nối đúng cách. Từ
theo quan điểm của hệ thống đang chạy, chúng sẽ được gắn lại ở chế độ chỉ đọc. số tiền còn lại
chưa hoàn thành cho đến khi bạn thấy thông báo "OK" và "Xong" xuất hiện trên màn hình.

Loglevels ZZ0000ZZ-ZZ0001ZZ rất hữu ích khi bảng điều khiển của bạn đang tràn ngập
tin nhắn kernel mà bạn không muốn xem. Việc chọn ZZ0002ZZ sẽ ngăn chặn tất cả trừ
các thông báo kernel khẩn cấp nhất gửi đến bảng điều khiển của bạn. (Họ sẽ
Tuy nhiên, vẫn được ghi lại nếu syslogd/klogd còn sống.)

ZZ0000ZZ và ZZ0001ZZ rất hữu ích nếu bạn có một số loại quy trình chạy trốn
bạn không thể giết bằng bất kỳ cách nào khác, đặc biệt nếu nó sinh sản khác
quá trình.

"just tan ZZ0000ZZ" rất hữu ích nếu hệ thống của bạn không phản hồi do
hệ thống tập tin bị đóng băng (có thể là root) thông qua FIFREEZE ioctl.

ZZ0000ZZ rất hữu ích để xem thông báo nhật ký kernel khi hệ thống bị treo
hoặc bạn không thể sử dụng lệnh dmesg để xem tin nhắn trong bộ đệm printk.
Người dùng có thể phải nhấn tổ hợp phím nhiều lần nếu hệ thống bảng điều khiển bị lỗi.
bận rộn. Nếu nó bị khóa hoàn toàn thì tin nhắn sẽ không được in. đầu ra
thông báo phụ thuộc vào mức nhật ký của bảng điều khiển hiện tại, có thể được sửa đổi bằng cách sử dụng
sysrq[0-9] (xem ở trên).

Đôi khi SysRq dường như bị 'kẹt' sau khi sử dụng, tôi phải làm sao?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi điều này xảy ra, hãy thử nhấn vào shift, alt và control ở cả hai bên của màn hình.
bàn phím và nhấn lại chuỗi sysrq không hợp lệ. (tức là, một cái gì đó như
ZZ0000ZZ).

Chuyển sang bảng điều khiển ảo khác (ZZ0000ZZ) rồi quay lại
cũng nên giúp đỡ.

Tôi nhấn SysRq, nhưng dường như không có gì xảy ra, có chuyện gì vậy?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có một số bàn phím tạo ra mã khóa cho SysRq khác với bàn phím
giá trị được xác định trước là 99
(xem ZZ0000ZZ trong ZZ0001ZZ), hoặc
không có khóa SysRq nào cả. Trong những trường hợp này, hãy chạy ZZ0002ZZ để tìm
một chuỗi scancode thích hợp và sử dụng ZZ0003ZZ để ánh xạ
chuỗi này thành mã SysRq thông thường (ví dụ: ZZ0004ZZ). Đó là
có lẽ tốt nhất nên đặt lệnh này trong tập lệnh khởi động. Ồ, và nhân tiện, bạn
thoát khỏi ZZ0005ZZ bằng cách không gõ bất cứ thứ gì trong mười giây.

Tôi muốn thêm các sự kiện chính của SysRQ vào một mô-đun, nó hoạt động như thế nào?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để đăng ký một hàm cơ bản với bảng, trước tiên bạn phải bao gồm
tiêu đề ZZ0000ZZ, tiêu đề này sẽ xác định mọi thứ khác mà bạn cần.
Tiếp theo, bạn phải tạo cấu trúc ZZ0001ZZ và điền vào đó bằng khóa A)
hàm xử lý bạn sẽ sử dụng, B) chuỗi help_msg, sẽ in khi SysRQ
in trợ giúp và C) một chuỗi action_msg, sẽ in ngay trước
trình xử lý được gọi. Trình xử lý của bạn phải tuân theo nguyên mẫu trong 'sysrq.h'.

Sau khi ZZ0000ZZ được tạo, bạn có thể gọi hàm kernel
ZZ0001ZZ điều này sẽ
đăng ký thao tác được trỏ bởi ZZ0002ZZ tại phím 'key' của bảng,
nếu ô đó trong bảng trống. Tại thời điểm dỡ mô-đun, bạn phải gọi
chức năng ZZ0003ZZ,
thao tác này sẽ xóa khóa op được chỉ định bởi 'op_p' khỏi khóa 'key', nếu và
chỉ khi nó hiện được đăng ký trong vị trí đó. Đây là trường hợp khe cắm có
đã bị ghi đè kể từ khi bạn đăng ký nó.

Hệ thống Magic SysRQ hoạt động bằng cách đăng ký các thao tác chính với một phím op
bảng tra cứu, được xác định trong 'drivers/tty/sysrq.c'. Bảng khóa này có
một số hoạt động được đăng ký vào nó tại thời điểm biên dịch, nhưng có thể thay đổi được,
và 2 hàm được xuất để giao diện với nó ::

register_sysrq_key và unregister_sysrq_key.

Tất nhiên, đừng bao giờ để lại một con trỏ không hợp lệ trong bảng. Tức là khi
mô-đun có tên register_sysrq_key() của bạn thoát ra, nó phải gọi
unregister_sysrq_key() để dọn sạch mục nhập bảng khóa sysrq mà nó đã sử dụng.
Con trỏ null trong bảng luôn an toàn. :)

Nếu vì lý do nào đó bạn cảm thấy cần phải gọi hàm hand_sysrq từ
trong một hàm được gọi bởi hand_sysrq, bạn phải biết rằng bạn đang ở trong
một khóa (bạn cũng đang sử dụng trình xử lý ngắt, có nghĩa là đừng ngủ!), vì vậy
thay vào đó bạn phải gọi ZZ0000ZZ.

Khi tôi nhấn tổ hợp phím SysRq, chỉ có tiêu đề xuất hiện trên bảng điều khiển?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đầu ra Sysrq chịu sự kiểm soát loglevel của bảng điều khiển giống như tất cả
đầu ra giao diện điều khiển khác.  Điều này có nghĩa là nếu kernel được khởi động ở trạng thái 'yên tĩnh'
như thường thấy trên hạt nhân phân phối, đầu ra có thể không xuất hiện trên thực tế
console, mặc dù nó sẽ xuất hiện trong bộ đệm dmesg và có thể truy cập được
thông qua lệnh dmesg và tới người tiêu dùng ZZ0000ZZ.  Như một điều cụ thể
ngoại trừ dòng tiêu đề từ lệnh sysrq được chuyển tới tất cả bảng điều khiển
người tiêu dùng như thể loglevel hiện tại là tối đa.  Nếu chỉ có tiêu đề
được phát ra thì gần như chắc chắn rằng mức log của kernel quá thấp.
Nếu bạn yêu cầu đầu ra trên kênh console thì bạn sẽ cần
để tạm thời nâng cấp nhật ký bảng điều khiển bằng ZZ0001ZZ hoặc::

echo 8 > /proc/sysrq-trigger

Hãy nhớ đưa loglevel trở lại bình thường sau khi kích hoạt sysrq
lệnh mà bạn quan tâm.

Tôi có thêm câu hỏi, tôi có thể hỏi ai?
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Chỉ cần hỏi họ trên danh sách gửi thư hạt nhân linux:
	linux-kernel@vger.kernel.org

Tín dụng
~~~~~~~

- Viết bởi Mydraal <vulpyne@vulpyne.net>
- Cập nhật bởi Adam Sulmicki <adam@cfar.umd.edu>
- Cập nhật bởi Jeremy M. Dolan <jmd@turbogeek.org> 28/01/2001 10:15:59
- Được thêm vào bởi Crutcher Dunnavant <crutcher+kernel@datastacks.com>
