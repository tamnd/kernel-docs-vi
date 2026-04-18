.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/caching/cachefiles.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Bộ đệm trên hệ thống tập tin đã được gắn
========================================

.. Contents:

 (*) Overview.

 (*) Requirements.

 (*) Configuration.

 (*) Starting the cache.

 (*) Things to avoid.

 (*) Cache culling.

 (*) Cache structure.

 (*) Security model and SELinux.

 (*) A note on security.

 (*) Statistical information.

 (*) Debugging.

 (*) On-demand Read.


Tổng quan
========

CacheFiles là một chương trình phụ trợ bộ đệm được thiết kế để sử dụng làm bộ đệm cho một thư mục trên
một hệ thống tập tin đã được gắn sẵn thuộc loại cục bộ (chẳng hạn như Ext3).

CacheFiles sử dụng daemon không gian người dùng để thực hiện một số công việc quản lý bộ đệm - chẳng hạn như
thu thập các nút cũ và loại bỏ.  Cái này được gọi là cachefilesd và tồn tại ở
/sbin.

Hệ thống tập tin và tính toàn vẹn dữ liệu của bộ đệm chỉ tốt như của bộ đệm
hệ thống tập tin cung cấp các dịch vụ hỗ trợ.  Lưu ý rằng CacheFiles không
cố gắng ghi nhật ký bất cứ điều gì vì giao diện ghi nhật ký của nhiều loại khác nhau
hệ thống tập tin có bản chất rất cụ thể.

CacheFiles tạo một thiết bị ký tự linh tinh - "/dev/cachefiles" - được sử dụng
để giao tiếp với daemon.  Chỉ có một thứ có thể mở cái này cùng một lúc,
và trong khi nó được mở, bộ nhớ đệm ít nhất vẫn tồn tại một phần.  daemon
mở cái này và gửi lệnh xuống nó để kiểm soát bộ đệm.

CacheFiles hiện bị giới hạn ở một bộ đệm duy nhất.

CacheFiles cố gắng duy trì ít nhất một tỷ lệ phần trăm dung lượng trống nhất định trên
hệ thống tập tin, thu nhỏ bộ đệm bằng cách loại bỏ các đối tượng chứa trong đó để tạo
khoảng trống nếu cần - xem phần "Xóa bộ đệm".  Điều này có nghĩa là nó có thể
được đặt trên cùng một phương tiện như một tập hợp dữ liệu trực tiếp và sẽ mở rộng để tận dụng
không gian trống và tự động thu gọn khi bộ dữ liệu yêu cầu nhiều hơn
không gian.



Yêu cầu
============

Việc sử dụng CacheFiles và daemon của nó yêu cầu phải có các tính năng sau:
có sẵn trong hệ thống và trong hệ thống tập tin bộ đệm:

- thông báo.

- thuộc tính mở rộng (xattrs).

- openat() và những người bạn.

- hỗ trợ bmap() trên các tệp trong hệ thống tệp (FIBMAP ioctl).

- Việc sử dụng bmap() để phát hiện một phần trang ở cuối file.

Chúng tôi thực sự khuyên bạn nên bật tùy chọn "dir_index" trên Ext3
hệ thống tập tin đang được sử dụng làm bộ đệm.


Cấu hình
=============

Bộ nhớ đệm được cấu hình bằng tập lệnh trong /etc/cachefilesd.conf.  Những lệnh này
thiết lập bộ đệm sẵn sàng để sử dụng.  Các lệnh script sau đây có sẵn:

brun <N>%, bcull <N>%, bstop <N>%, frun <N>%, fcull <N>%, fstop <N>%
	Cấu hình các giới hạn loại bỏ.  Không bắt buộc.  Xem phần loại bỏ
	Giá trị mặc định lần lượt là 7% (chạy), 5% (loại bỏ) và 1% (dừng).

Các lệnh bắt đầu bằng 'b' là giới hạn không gian tệp (khối), những lệnh đó
	bắt đầu bằng 'f' là giới hạn số lượng tệp.

thư mục <đường dẫn>
	Chỉ định thư mục chứa thư mục gốc của bộ đệm.  Bắt buộc.

gắn thẻ <tên>
	Chỉ định một thẻ cho FS-Cache để sử dụng trong việc phân biệt nhiều bộ đệm.
	Không bắt buộc.  Mặc định là "CacheFiles".

gỡ lỗi <mặt nạ>
	Chỉ định mặt nạ bit số để kiểm soát việc gỡ lỗi trong mô-đun hạt nhân.
	Không bắt buộc.  Mặc định là 0 (tắt hoàn toàn).  Các giá trị sau đây có thể
	HOẶC vào mặt nạ để thu thập nhiều thông tin khác nhau:

=======================================================
		1 Bật dấu vết của mục nhập hàm (macro_enter())
		2 Bật dấu vết thoát hàm (macro _leave())
		4 Bật theo dõi các điểm gỡ lỗi nội bộ (_debug())
		=======================================================

Mặt nạ này cũng có thể được đặt thông qua sysfs, ví dụ::

echo 5 > /sys/module/cachefiles/parameters/debug


Bắt đầu bộ đệm
==================

Bộ đệm được bắt đầu bằng cách chạy daemon.  Daemon mở thiết bị đệm,
định cấu hình bộ đệm và yêu cầu nó bắt đầu lưu vào bộ đệm.  Tại thời điểm đó bộ đệm
liên kết với fscache và bộ đệm sẽ hoạt động.

Daemon được chạy như sau::

/sbin/cachefilesd [-d]* [-s] [-n] [-f <configfile>]

Các lá cờ là:

ZZ0000ZZ
	Tăng mức độ gỡ lỗi.  Điều này có thể được chỉ định nhiều lần và
	được tích lũy với chính nó.

ZZ0000ZZ
	Gửi tin nhắn tới stderr thay vì syslog.

ZZ0000ZZ
	Đừng daemonise và đi vào nền.

ZZ0000ZZ
	Sử dụng tệp cấu hình thay thế thay vì tệp mặc định.


Những điều cần tránh
===============

Không gắn những thứ khác vào bộ đệm vì điều này sẽ gây ra sự cố.  các
mô-đun hạt nhân chứa cơ sở đi bộ đường dẫn rất đơn giản của riêng nó mà bỏ qua
điểm gắn kết, nhưng daemon không thể tránh được chúng.

Không tạo, đổi tên hoặc hủy liên kết các tập tin và thư mục trong bộ đệm trong khi
bộ đệm đang hoạt động vì điều này có thể khiến trạng thái không chắc chắn.

Việc đổi tên các tập tin trong bộ đệm có thể làm cho các đối tượng trông giống như các đối tượng khác (
tên tệp là một phần của khóa tra cứu).

Không thay đổi hoặc xóa các thuộc tính mở rộng được đính kèm với các tệp bộ nhớ đệm bằng
cache vì điều này sẽ khiến việc quản lý trạng thái bộ đệm bị nhầm lẫn.

Không tạo tập tin hoặc thư mục trong bộ đệm, kẻo bộ đệm bị nhầm lẫn hoặc
phục vụ dữ liệu không chính xác.

Không chmod tập tin trong bộ đệm.  Mô-đun tạo ra mọi thứ với mức tối thiểu
quyền để ngăn người dùng ngẫu nhiên có thể truy cập chúng trực tiếp.


Loại bỏ bộ nhớ đệm
=============

Bộ nhớ đệm đôi khi có thể cần được loại bỏ để tạo khoảng trống.  Điều này liên quan đến
loại bỏ các đối tượng khỏi bộ đệm ít được sử dụng gần đây hơn
bất cứ điều gì khác.  Việc loại bỏ dựa trên thời gian truy cập của các đối tượng dữ liệu.  trống
các thư mục sẽ bị loại bỏ nếu không được sử dụng.

Việc loại bỏ bộ đệm được thực hiện trên cơ sở tỷ lệ phần trăm của các khối và
phần trăm tệp có sẵn trong hệ thống tệp cơ bản.  Có sáu
"giới hạn":

nâu, nâu
     Nếu dung lượng trống và số lượng tệp có sẵn trong bộ đệm
     vượt quá cả hai giới hạn này thì việc loại bỏ sẽ bị tắt.

bcull, fcull
     Nếu dung lượng trống hoặc số lượng tệp có sẵn trong
     bộ nhớ đệm giảm xuống dưới một trong hai giới hạn này thì quá trình loại bỏ sẽ được bắt đầu.

dừng lại, fstop
     Nếu dung lượng trống hoặc số lượng tệp có sẵn trong
     bộ đệm giảm xuống dưới một trong hai giới hạn này thì không được phân bổ thêm
     dung lượng ổ đĩa hoặc các tập tin được cho phép cho đến khi việc loại bỏ đã nâng cao được những thứ trên
     những giới hạn này nữa.

Chúng phải được cấu hình như vậy::

0 <= bstop < bcull < brun < 100
	0 <= fstop < fcull < frun < 100

Lưu ý rằng đây là tỷ lệ phần trăm dung lượng trống và các tệp có sẵn, đồng thời
_not_ xuất hiện dưới dạng 100 trừ phần trăm được hiển thị bởi chương trình "df".

Trình nền không gian người dùng quét bộ nhớ đệm để xây dựng một bảng các đối tượng có thể loại bỏ.
Sau đó chúng sẽ được loại bỏ theo thứ tự ít được sử dụng gần đây nhất.  Một lần quét bộ nhớ đệm mới là
bắt đầu ngay khi có khoảng trống trong bảng.  Các đối tượng sẽ bị bỏ qua nếu
thời gian của chúng đã thay đổi hoặc nếu mô-đun hạt nhân cho biết nó vẫn đang sử dụng chúng.


Cấu trúc bộ đệm
===============

Mô-đun CacheFiles sẽ tạo hai thư mục trong thư mục đó
đã cho:

* bộ nhớ đệm/
 * nghĩa địa/

Tất cả các đối tượng bộ nhớ đệm đang hoạt động đều nằm trong thư mục đầu tiên.  Tệp bộ đệm
mô-đun hạt nhân di chuyển mọi đối tượng đã ngừng hoạt động hoặc bị loại bỏ mà nó không thể hủy liên kết
đến nghĩa địa mà từ đó daemon sẽ thực sự xóa chúng.

Daemon sử dụng dnotify để giám sát thư mục nghĩa địa và sẽ xóa
bất cứ thứ gì xuất hiện trong đó.


Mô-đun này biểu thị các đối tượng chỉ mục dưới dạng các thư mục có tên tệp "I..." hoặc
"J...".  Lưu ý rằng bản thân thư mục "cache/" là một chỉ mục đặc biệt.

Các đối tượng dữ liệu được biểu diễn dưới dạng tệp nếu chúng không có con hoặc thư mục
nếu họ làm vậy.  Tên tệp của chúng đều bắt đầu bằng "D..." hoặc "E...".  Nếu được biểu diễn dưới dạng
thư mục, các đối tượng dữ liệu sẽ có một tệp trong thư mục có tên là "data"
thực sự chứa dữ liệu.

Các đối tượng đặc biệt tương tự như các đối tượng dữ liệu, ngoại trừ tên tập tin của chúng bắt đầu
"S..." hoặc "T...".


Nếu một đối tượng có con thì nó sẽ được biểu diễn dưới dạng một thư mục.
Ngay trong thư mục đại diện là tập hợp các thư mục
được đặt tên theo giá trị băm của các khóa đối tượng con có '@' được thêm vào trước.  vào
thư mục này, nếu có thể, sẽ được đặt các đại diện của trẻ
đối tượng::

/INDEX /INDEX /INDEX /DATA FILES
	/==========/===========/=========================================================
	bộ đệm/@4a/I03nfs/@30/Ji000000000000000--fHg8hi8400
	cache/@4a/I03nfs/@30/Ji0000000000000000--fHg8hi8400/@75/Es0g000w...DB1ry
	cache/@4a/I03nfs/@30/Ji0000000000000000--fHg8hi8400/@75/Es0g000w...N22ry
	cache/@4a/I03nfs/@30/Ji0000000000000000--fHg8hi8400/@75/Es0g000w...FP1ry


Nếu phím dài đến mức vượt quá NAME_MAX với các đồ trang trí được thêm vào
nó, sau đó nó sẽ được cắt thành từng miếng, một vài miếng đầu tiên sẽ được dùng để
tạo một tổ các thư mục và thư mục cuối cùng trong số đó sẽ là các đối tượng
bên trong thư mục cuối cùng.  Tên các thư mục trung gian sẽ có
'+' được thêm vào trước::

J1223/@23/+xy...z/+kl...m/Epqr


Lưu ý rằng khóa là dữ liệu thô và chúng không chỉ có thể vượt quá kích thước NAME_MAX,
chúng cũng có thể chứa những thứ như ký tự '/' và NUL, và vì vậy chúng có thể không
thích hợp để chuyển trực tiếp thành tên tập tin.

Để xử lý việc này, CacheFiles sẽ trực tiếp sử dụng tên tệp có thể in phù hợp và
Mã hóa "base-64" không phù hợp trực tiếp.  Hai phiên bản của
tên tệp đối tượng cho biết mã hóa:

=================================================
	OBJECT TYPE PRINTABLE ENCODED
	=================================================
	Mục lục "Tôi..." "J..."
	Dữ liệu "D..." "E..."
	Đặc biệt "S..." "T..."
	=================================================

Các thư mục trung gian luôn là "@" hoặc "+" nếu thích hợp.


Mỗi đối tượng trong bộ nhớ đệm có một nhãn thuộc tính mở rộng chứa đối tượng đó
ID loại (bắt buộc để phân biệt các đối tượng đặc biệt) và dữ liệu phụ trợ từ
các netfs.  Cái sau được sử dụng để phát hiện các đối tượng cũ trong bộ đệm và cập nhật
hoặc cho họ nghỉ hưu.


Lưu ý rằng CacheFiles sẽ xóa khỏi bộ đệm bất kỳ tệp nào mà nó không nhận ra hoặc
bất kỳ tệp nào thuộc loại không chính xác (chẳng hạn như tệp FIFO hoặc tệp thiết bị).


Mô hình bảo mật và SELinux
==========================

CacheFiles được triển khai để xử lý đúng cách các tính năng bảo mật LSM của
nhân Linux và cơ sở SELinux.

Một trong những vấn đề mà CacheFiles gặp phải là nó thường hoạt động trên
thay mặt cho một quy trình và chạy trong ngữ cảnh của quy trình đó và bao gồm một
bối cảnh bảo mật không phù hợp để truy cập bộ đệm - hoặc
bởi vì các tập tin trong bộ đệm không thể truy cập được vào quá trình đó hoặc vì nếu
quá trình tạo một tệp trong bộ nhớ đệm, tệp đó có thể không truy cập được bởi các tệp khác
quá trình.

Cách thức hoạt động của CacheFiles là tạm thời thay đổi bối cảnh bảo mật (fsuid,
nhãn bảo mật fsgid và diễn viên) mà quy trình hoạt động như - mà không thay đổi
bối cảnh bảo mật của quy trình khi nó là mục tiêu của một hoạt động được thực hiện bởi
một số quy trình khác (vì vậy tín hiệu và những thứ tương tự vẫn hoạt động chính xác).


Khi mô-đun CacheFiles được yêu cầu liên kết với bộ đệm của nó, nó:

(1) Tìm nhãn bảo mật được gắn vào thư mục bộ đệm gốc và sử dụng
     đó là nhãn bảo mật mà nó sẽ tạo tập tin.  Theo mặc định,
     đây là::

tập tin bộ nhớ cache_var_t

(2) Tìm nhãn bảo mật của quy trình đưa ra yêu cầu liên kết
     (được coi là daemon cachefilesd), theo mặc định sẽ là::

tập tin bộ nhớ cached_t

và yêu cầu LSM cung cấp ID bảo mật mà nó sẽ hành động dựa trên
     nhãn của daemon.  Theo mặc định, đây sẽ là::

cachefiles_kernel_t

SELinux chuyển ID bảo mật của daemon sang ID bảo mật của mô-đun
     dựa trên quy tắc của biểu mẫu này trong chính sách::

type_transition <daemon's-ID> kernel_t : xử lý <module's-ID>;

Ví dụ::

type_transition cachefilesd_t kernel_t: xử lý cachefiles_kernel_t;


ID bảo mật của mô-đun cho phép nó tạo, di chuyển và xóa tệp
và các thư mục trong bộ đệm, để tìm và truy cập các thư mục và tập tin trong
bộ đệm, để thiết lập và truy cập các thuộc tính mở rộng trên các đối tượng bộ đệm, cũng như đọc và
ghi tập tin vào bộ đệm.

ID bảo mật của daemon chỉ cấp cho nó một bộ quyền rất hạn chế: nó
có thể quét các thư mục, tập tin thống kê và xóa các tập tin và thư mục.  Nó có thể
không đọc hoặc ghi các tập tin trong bộ đệm và do đó nó không thể truy cập vào
dữ liệu được lưu trữ trong đó; cũng không được phép tạo tập tin mới trong bộ đệm.


Có các tệp nguồn chính sách có sẵn trong:

ZZ0000ZZ

và các phiên bản sau này.  Trong tarball đó, hãy xem các tập tin::

cachefilesd.te
	cachefilesd.fc
	cachefilesd.if

Chúng được RPM xây dựng và cài đặt trực tiếp.

Nếu hệ thống dựa trên RPM đang được sử dụng, hãy sao chép các tệp trên vào tệp riêng của chúng
thư mục và chạy::

tạo -f /usr/share/selinux/devel/Makefile
	semodule -i cachefilesd.pp

Bạn sẽ cần cài đặt chính sách kiểm tra và selinux-policy-devel trước
xây dựng.


Theo mặc định, bộ đệm nằm ở /var/fscache, nhưng nếu muốn thì
nó phải ở nơi khác, ngoài việc các tệp chính sách trên phải được thay đổi hoặc
một chính sách phụ trợ phải được cài đặt để gắn nhãn vị trí thay thế của
bộ đệm.

Để biết hướng dẫn về cách thêm chính sách phụ trợ để kích hoạt bộ nhớ đệm
nằm ở nơi khác khi SELinux đang ở chế độ thực thi, vui lòng xem::

/usr/share/doc/cachefilesd-*/move-cache.txt

Khi cài đặt vòng/phút cachefilesd; Ngoài ra, tài liệu có thể được tìm thấy
trong các nguồn.


Lưu ý về bảo mật
==================

CacheFiles sử dụng bảo mật phân chia trong task_struct.  Nó phân bổ
cấu trúc task_security của chính nó và chuyển hướng current->cred để trỏ đến nó
khi nó hành động thay mặt cho một tiến trình khác, trong bối cảnh của tiến trình đó.

Lý do nó thực hiện điều này là vì nó gọi vfs_mkdir() và suchlike thay vì
bỏ qua bảo mật và gọi trực tiếp inode ops.  Do đó VFS và LSM
có thể từ chối quyền truy cập CacheFiles vào dữ liệu bộ đệm vì trong một số trường hợp
trường hợp mã bộ nhớ đệm đang chạy trong bối cảnh bảo mật của bất kỳ điều gì
quá trình ban hành syscall ban đầu trên netfs.

Hơn nữa, nếu CacheFiles tạo một tập tin hoặc thư mục, tính bảo mật sẽ
các tham số với đối tượng đó được tạo (UID, GID, nhãn bảo mật) sẽ là
bắt nguồn từ quá trình đưa ra lệnh gọi hệ thống, do đó có khả năng
ngăn chặn các quá trình khác truy cập vào bộ đệm - bao gồm cả CacheFiles
daemon quản lý bộ đệm (cachefilesd).

Điều cần thiết là tạm thời ghi đè tính bảo mật của quy trình
đã đưa ra lời gọi hệ thống.  Tuy nhiên, chúng ta không thể chỉ thực hiện thay đổi tại chỗ của
dữ liệu bảo mật vì nó ảnh hưởng đến quá trình với tư cách là một đối tượng, không chỉ với tư cách là chủ thể.
Điều này có nghĩa là nó có thể mất tín hiệu hoặc sự kiện ptrace chẳng hạn và ảnh hưởng đến những gì
quá trình này trông giống như trong /proc.

Vì vậy CacheFiles sử dụng sự phân chia hợp lý về bảo mật giữa
bảo mật khách quan (task->real_cred) và bảo mật chủ quan (task->cred).
Bảo mật khách quan chứa các thuộc tính bảo mật nội tại của một quy trình và
không bao giờ bị ghi đè.  Đây là những gì xuất hiện trong /proc và được sử dụng khi một
quá trình là mục tiêu của một hoạt động bởi một số quá trình khác (SIGKILL cho
ví dụ).

Bảo mật chủ quan nắm giữ các thuộc tính bảo mật tích cực của một quy trình và
có thể bị ghi đè.  Điều này không được nhìn thấy bên ngoài và được sử dụng khi một quá trình
tác động lên một đối tượng khác, ví dụ SIGKILLing một tiến trình khác hoặc mở một
tập tin.

Các hook LSM tồn tại cho phép SELinux (hoặc Smack hoặc bất cứ thứ gì) từ chối yêu cầu
để CacheFiles chạy trong ngữ cảnh của nhãn bảo mật cụ thể hoặc để tạo
các tập tin và thư mục có nhãn bảo mật khác.


Thông tin thống kê
=======================

Nếu FS-Cache được biên dịch với tùy chọn sau được bật::

CONFIG_CACHEFILES_HISTOGRAM=y

sau đó nó sẽ thu thập số liệu thống kê nhất định và hiển thị chúng thông qua tệp Proc.

/proc/fs/cachefiles/histogram

     ::

cat /proc/fs/cachefiles/histogram
	JIFS SECS LOOKUPS MKDIRS CREATES
	===== ===== =================== ==========

Điều này cho thấy sự phân chia về số lần mỗi khoảng thời gian
     trong khoảng thời gian từ 0 giây đến HZ-1, nhiều nhiệm vụ khác nhau sẽ được thực hiện.  các
     các cột như sau:

======= =============================================================
	COLUMN TIME MEASUREMENT
	======= =============================================================
	LOOKUPS Khoảng thời gian để thực hiện tra cứu trên fs sao lưu
	MKDIRS Khoảng thời gian để thực hiện mkdir trên fs sao lưu
	CREATES Khoảng thời gian để thực hiện tạo trên fs sao lưu
	======= =============================================================

Mỗi hàng hiển thị số lượng sự kiện diễn ra trong một khoảng thời gian cụ thể.
     Mỗi bước có kích thước 1 phút.  Cột JIFS cho biết cụ thể
     phạm vi trong nháy mắt được bao phủ và trường SECS có số giây tương đương.


Gỡ lỗi
=========

Nếu CONFIG_CACHEFILES_DEBUG được bật, tiện ích CacheFiles có thể có thời gian chạy
gỡ lỗi được kích hoạt bằng cách điều chỉnh giá trị trong::

/sys/module/cachefiles/tham số/gỡ lỗi

Đây là một bitmask của các luồng gỡ lỗi để kích hoạt:

============== ================================ ==========================
	BIT VALUE STREAM POINT
	============== ================================ ==========================
	0 1 Chung Dấu vết mục nhập chức năng
	1 2 Dấu vết thoát chức năng
	2 4 Tổng quát
	============== ================================ ==========================

Tập hợp các giá trị thích hợp phải được OR cùng nhau và kết quả được ghi vào
tập tin điều khiển.  Ví dụ::

echo $((1|4|8)) >/sys/module/cachefiles/parameters/debug

sẽ bật tất cả các mục gỡ lỗi chức năng.


Đọc theo yêu cầu
==============

Khi làm việc ở chế độ ban đầu, CacheFiles đóng vai trò là bộ đệm cục bộ cho
fs kết nối mạng từ xa - khi ở chế độ đọc theo yêu cầu, CacheFiles có thể tăng tốc
kịch bản cần có ngữ nghĩa đọc theo yêu cầu, ví dụ: hình ảnh thùng chứa
phân phối.

Sự khác biệt cơ bản giữa hai chế độ này được nhận thấy khi bộ nhớ đệm bị thiếu.
xảy ra: Ở chế độ ban đầu, netfs sẽ lấy dữ liệu từ xa
máy chủ và sau đó ghi nó vào tập tin bộ đệm; ở chế độ đọc theo yêu cầu, tìm nạp
dữ liệu và ghi nó vào bộ đệm được ủy quyền cho daemon người dùng.

ZZ0000ZZ phải được kích hoạt để hỗ trợ chế độ đọc theo yêu cầu.


Giao thức truyền thông
----------------------

Chế độ đọc theo yêu cầu sử dụng giao thức đơn giản để liên lạc giữa kernel
và daemon người dùng. Giao thức có thể được mô hình hóa như::

kernel --[request]--> daemon người dùng --[reply]--> kernel

CacheFiles sẽ gửi yêu cầu tới daemon người dùng khi cần.  Daemon người dùng
nên thăm dò devnode ('/dev/cachefiles') để kiểm tra xem có bản phát hành nào đang chờ xử lý không
yêu cầu được xử lý.  Sự kiện POLLIN sẽ được trả về khi có sự kiện đang chờ xử lý
yêu cầu.

Sau đó, daemon người dùng sẽ đọc devnode để tìm nạp yêu cầu xử lý.  Nó nên
lưu ý rằng mỗi lần đọc chỉ nhận được một yêu cầu. Khi nó xử lý xong
yêu cầu, daemon người dùng sẽ viết câu trả lời cho devnode.

Mỗi yêu cầu bắt đầu bằng tiêu đề thư có dạng::

cấu trúc cachefiles_msg {
		__u32 tin nhắn_id;
		__u32 mã lệnh;
		__u32 len;
		__u32 object_id;
		__u8 dữ liệu[];
	};

Ở đâu:

* ZZ0000ZZ là ID duy nhất xác định yêu cầu này trong số tất cả các yêu cầu đang chờ xử lý
	  yêu cầu.

* ZZ0000ZZ cho biết loại yêu cầu này.

* ZZ0000ZZ là ID duy nhất xác định tệp bộ đệm được vận hành trên đó.

* ZZ0000ZZ cho biết tải trọng của yêu cầu này.

* ZZ0000ZZ cho biết toàn bộ thời lượng của yêu cầu này, bao gồm cả
	  tiêu đề và tải trọng theo loại cụ thể sau.


Bật Chế độ theo yêu cầu
-------------------------

Một tham số tùy chọn sẽ có sẵn cho lệnh "liên kết"::

ràng buộc [theo yêu cầu]

Khi lệnh "liên kết" không có đối số, nó sẽ mặc định ở chế độ ban đầu.
Khi nó được đưa ra đối số "theo yêu cầu", tức là "liên kết theo yêu cầu", đọc theo yêu cầu
chế độ sẽ được kích hoạt.


Yêu cầu OPEN
----------------

Khi netfs mở tệp bộ đệm lần đầu tiên, một yêu cầu có
Opcode CACHEFILES_OP_OPEN, hay còn gọi là yêu cầu OPEN sẽ được gửi tới người dùng
daemon.  Định dạng tải trọng có dạng::

cấu trúc cachefiles_open {
		__u32 Volume_key_size;
		__u32 cookie_key_size;
		__u32 fd;
		__u32 cờ;
		__u8 dữ liệu[];
	};

Ở đâu:

* ZZ0000ZZ chứa khóa_khối lượng, theo sau là khóa_cookie.
	  Phím âm lượng là chuỗi kết thúc NUL; khóa cookie là nhị phân
	  dữ liệu.

* ZZ0000ZZ cho biết kích thước của phím âm lượng tính bằng byte.

* ZZ0000ZZ cho biết kích thước của khóa cookie tính bằng byte.

* ZZ0000ZZ biểu thị một fd ẩn danh đề cập đến tệp bộ đệm, thông qua
	  mà daemon người dùng có thể thực hiện các thao tác ghi/llseek tệp trên
	  tập tin bộ đệm.


Daemon người dùng có thể sử dụng cặp (volume_key, cookie_key) đã cho để phân biệt
tập tin bộ đệm được yêu cầu.  Với fd ẩn danh đã cho, daemon người dùng có thể
tìm nạp dữ liệu và ghi nó vào tập tin bộ nhớ đệm ở chế độ nền, ngay cả khi
kernel chưa kích hoạt lỗi bộ đệm.

Xin lưu ý rằng mỗi tệp bộ đệm có một object_id duy nhất, trong khi nó có thể có nhiều
fds ẩn danh.  Trình nền của người dùng có thể sao chép các fds ẩn danh từ ban đầu
fd ẩn danh được biểu thị bằng trường @fd thông qua dup().  Vì vậy mỗi object_id có thể
được ánh xạ tới nhiều fds ẩn danh, trong khi bản thân daemon usr cần phải
duy trì việc lập bản đồ.

Khi triển khai daemon người dùng, hãy cẩn thận với RLIMIT_NOFILE,
ZZ0000ZZ và ZZ0001ZZ.  Thông thường những điều này không cần thiết
rất lớn vì chúng liên quan đến số lượng đốm màu thiết bị mở hơn là
mở các tập tin của từng hệ thống tập tin riêng lẻ.

Daemon người dùng phải trả lời yêu cầu OPEN bằng cách đưa ra "copen" (hoàn thành
open) trên devnode::

copen <msg_id>,<cache_size>

Ở đâu:

* ZZ0000ZZ phải khớp với trường msg_id của yêu cầu OPEN.

* Khi >= 0, ZZ0000ZZ cho biết kích thước của tệp bộ đệm;
	  khi < 0, ZZ0001ZZ cho biết bất kỳ mã lỗi nào mà máy gặp phải
	  daemon của người dùng.


Yêu cầu CLOSE
-----------------

Khi cookie bị rút, yêu cầu CLOSE (mã opZ0001ZZ) sẽ được
được gửi tới daemon của người dùng.  Điều này báo cho daemon người dùng đóng tất cả các fds ẩn danh
được liên kết với object_id đã cho.  Yêu cầu CLOSE không có tải trọng bổ sung,
và không nên được trả lời.


Yêu cầu READ
----------------

Khi gặp lỗi bộ đệm trong chế độ đọc theo yêu cầu, CacheFiles sẽ gửi một
Yêu cầu READ (opcode CACHEFILES_OP_READ) tới daemon người dùng. Điều này cho người dùng biết
daemon để tìm nạp nội dung của phạm vi tệp được yêu cầu.  Tải trọng là của
hình thức::

cấu trúc cachefiles_read {
		__u64 tắt;
		__u64 len;
	};

Ở đâu:

* ZZ0000ZZ cho biết độ lệch bắt đầu của phạm vi tệp được yêu cầu.

* ZZ0000ZZ cho biết độ dài của phạm vi tệp được yêu cầu.


Khi nhận được yêu cầu READ, daemon người dùng sẽ tìm nạp dữ liệu được yêu cầu
và ghi nó vào tệp bộ đệm được xác định bởi object_id.

Khi nó xử lý xong yêu cầu READ, daemon người dùng sẽ trả lời
bằng cách sử dụng CACHEFILES_IOC_READ_COMPLETE ioctl trên một trong các fds ẩn danh
được liên kết với object_id được đưa ra trong yêu cầu READ.  Ioctl là của
hình thức::

ioctl(fd, CACHEFILES_IOC_READ_COMPLETE, msg_id);

Ở đâu:

* ZZ0000ZZ là một trong những fds ẩn danh được liên kết với object_id
	  đã cho.

* ZZ0000ZZ phải khớp với trường msg_id của yêu cầu READ.