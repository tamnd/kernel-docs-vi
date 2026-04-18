.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/keys/core.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
Dịch vụ lưu giữ khóa hạt nhân
===============================

Dịch vụ này cho phép khóa mật mã, mã thông báo xác thực, tên miền chéo
ánh xạ người dùng và tương tự như được lưu trữ trong kernel để sử dụng
hệ thống tập tin và các dịch vụ hạt nhân khác.

Dây móc khóa được cho phép; đây là một loại khóa đặc biệt có thể chứa các liên kết đến
các phím khác. Mỗi quy trình có ba đăng ký khóa tiêu chuẩn mà một
dịch vụ kernel có thể tìm kiếm các khóa có liên quan.

Bạn có thể định cấu hình dịch vụ mã khóa bằng cách bật:

"Tùy chọn bảo mật"/"Bật hỗ trợ lưu giữ khóa truy cập" (CONFIG_KEYS)

Tài liệu này có các phần sau:

.. contents:: :local:


Tổng quan chính
============

Trong ngữ cảnh này, các khóa đại diện cho các đơn vị dữ liệu mật mã, xác thực
mã thông báo, dây móc khóa, v.v.. Chúng được thể hiện trong kernel bằng khóa struct.

Mỗi khóa có một số thuộc tính:

- Một số sê-ri.
	- Một loại.
	- Mô tả (để khớp với khóa trong tìm kiếm).
	- Kiểm soát truy cập thông tin.
	- Hết thời hạn sử dụng.
	- Một trọng tải.
	- Tình trạng.


* Mỗi khóa được cấp một số sê-ri loại key_serial_t duy nhất cho
     thời gian tồn tại của khóa đó. Tất cả các số sê-ri đều dương khác 0 32-bit
     số nguyên.

Các chương trình trong không gian người dùng có thể sử dụng số sê-ri của khóa làm cách để có quyền truy cập
     với nó, tùy thuộc vào việc kiểm tra sự cho phép.

* Mỗi khóa thuộc một "loại" được xác định. Các loại phải được đăng ký bên trong
     kernel bởi một dịch vụ kernel (chẳng hạn như hệ thống tập tin) trước các khóa thuộc loại đó
     có thể được thêm vào hoặc sử dụng. Các chương trình không gian người dùng không thể xác định trực tiếp các loại mới.

Các loại khóa được biểu diễn trong kernel bằng struct key_type. Điều này xác định một
     số thao tác có thể được thực hiện trên một khóa thuộc loại đó.

Nếu một loại bị xóa khỏi hệ thống, tất cả các khóa thuộc loại đó sẽ
     bị vô hiệu.

* Mỗi phím có một mô tả. Đây phải là một chuỗi có thể in được. Chìa khóa
     loại cung cấp một thao tác để thực hiện so khớp giữa mô tả trên một
     khóa và một chuỗi tiêu chí.

* Mỗi khóa có ID người dùng chủ sở hữu, ID nhóm và mặt nạ quyền. Những cái này
     được sử dụng để kiểm soát những gì một quy trình có thể thực hiện đối với một khóa từ không gian người dùng và
     liệu dịch vụ hạt nhân có thể tìm thấy khóa hay không.

* Mỗi khóa có thể được đặt hết hạn vào một thời điểm cụ thể theo loại khóa
     chức năng khởi tạo. Chìa khóa cũng có thể bất tử.

* Mỗi khóa có thể có tải trọng. Đây là một lượng dữ liệu đại diện cho
     "chìa khóa" thực sự. Trong trường hợp một chiếc chìa khóa, đây là danh sách các chìa khóa mà
     các liên kết móc khóa; trong trường hợp khóa do người dùng xác định, đó là khóa tùy ý
     đốm dữ liệu.

Không cần phải có tải trọng; và trên thực tế, tải trọng có thể chỉ là một
     giá trị được lưu trữ trong chính khóa cấu trúc.

Khi một khóa được khởi tạo, chức năng khởi tạo của loại khóa đó là
     được gọi với một khối dữ liệu và sau đó tạo ra tải trọng của khóa trong
     cách nào đó.

Tương tự, khi không gian người dùng muốn đọc lại nội dung của khóa, nếu
     được phép, một thao tác loại khóa khác sẽ được gọi để chuyển đổi khóa
     tải trọng được đính kèm trở lại thành một khối dữ liệu.

* Mỗi khóa có thể ở một trong một số trạng thái cơ bản:

* Không được chứng minh. Khóa tồn tại nhưng không có bất kỳ dữ liệu nào được đính kèm.
     	 Các khóa được yêu cầu từ không gian người dùng sẽ ở trạng thái này.

* Ngay lập tức. Đây là trạng thái bình thường. Chìa khóa được hình thành đầy đủ và
	 có dữ liệu đính kèm.

*  Tiêu cực. Đây là một trạng thái tương đối ngắn ngủi. Chìa khóa hoạt động như một
	 lưu ý rằng lệnh gọi tới không gian người dùng trước đó không thành công và hoạt động như
	 một ga trên tra cứu quan trọng. Khóa âm có thể được cập nhật thành khóa bình thường
	 trạng thái.

*  Hết hạn. Chìa khóa có thể được thiết lập trọn đời. Nếu vượt quá thời gian sống của họ,
	 họ đi qua trạng thái này. Một khóa hết hạn có thể được cập nhật trở lại
	 trạng thái bình thường.

* Bị thu hồi. Một khóa được đặt ở trạng thái này bằng hành động của không gian người dùng. Nó không thể được
	 được tìm thấy hoặc vận hành (ngoài việc hủy liên kết nó).

*  Chết. Loại của khóa chưa được đăng ký và do đó, khóa hiện không còn hữu dụng.

Các khóa ở ba trạng thái cuối cùng có thể bị thu gom rác.  Xem
phần "Thu gom rác".


Tổng quan về dịch vụ chính
====================

Dịch vụ mã khóa cung cấp một số tính năng ngoài khóa:

* Dịch vụ mã khóa xác định ba loại khóa đặc biệt:

(+) "chìa khóa"

Dây móc khóa là các phím đặc biệt chứa danh sách các phím khác. Móc khóa
	 danh sách có thể được sửa đổi bằng cách sử dụng các cuộc gọi hệ thống khác nhau. Móc khóa không nên
	 được cung cấp một tải trọng khi được tạo.

(+) "người dùng"

Khóa thuộc loại này có mô tả và tải trọng tùy ý
	 các đốm màu dữ liệu. Chúng có thể được tạo, cập nhật và đọc bởi không gian người dùng,
	 và không dành cho các dịch vụ kernel sử dụng.

(+) "đăng nhập"

Giống như khóa "người dùng", khóa "đăng nhập" có tải trọng tùy ý
	 đốm dữ liệu. Nó được thiết kế như một nơi để lưu trữ những bí mật
	 có thể truy cập vào kernel nhưng không truy cập được vào các chương trình không gian người dùng.

Mô tả có thể tùy ý, nhưng phải có tiền tố khác 0
	 chuỗi độ dài mô tả khóa "lớp con". Lớp con là
	 được phân tách khỏi phần còn lại của mô tả bằng dấu ':'. Phím "đăng nhập" có thể
	 được tạo và cập nhật từ không gian người dùng, nhưng tải trọng chỉ
	 có thể đọc được từ không gian kernel.

* Mỗi quy trình đăng ký ba chuỗi khóa: một chuỗi khóa dành riêng cho luồng, một
     khóa dành riêng cho quy trình và khóa dành riêng cho phiên.

Khóa dành riêng cho luồng sẽ bị loại bỏ khỏi trẻ khi bất kỳ loại nào
     xảy ra bản sao, fork, vfork hoặc execve. Một khóa mới chỉ được tạo khi
     được yêu cầu.

Khóa dành riêng cho quy trình được thay thế bằng một khóa trống ở trẻ trên
     bản sao, fork, vfork trừ khi CLONE_THREAD được cung cấp, trong trường hợp đó là
     đã chia sẻ. execve cũng loại bỏ việc khóa quy trình của quy trình và tạo ra một
     cái mới.

Việc khóa dành riêng cho phiên được duy trì liên tục trên khắp bản sao, fork, vfork và
     execve, ngay cả khi cái sau thực thi nhị phân set-UID hoặc set-GID. A
     Tuy nhiên, tiến trình có thể thay thế khóa phiên hiện tại của nó bằng một khóa mới
     bằng cách sử dụng PR_JOIN_SESSION_KEYRING. Được phép yêu cầu ẩn danh
     tên mới hoặc cố gắng tạo hoặc nối một trong các tên cụ thể.

Quyền sở hữu chuỗi khóa thay đổi khi UID và GID thực của
     sợi dây thay đổi.

* Mỗi ID người dùng trong hệ thống có hai chuỗi khóa đặc biệt: một người dùng
     khóa cụ thể và khóa phiên người dùng mặc định. Phiên mặc định
     khóa được khởi tạo bằng một liên kết đến khóa dành riêng cho người dùng.

Khi một tiến trình thay đổi UID thực của nó, nếu trước đây nó không có khóa phiên, thì nó
     sẽ được đăng ký khóa phiên mặc định cho UID mới.

Nếu một tiến trình cố gắng truy cập khóa phiên của nó khi nó không có khóa phiên,
     nó sẽ được đăng ký mặc định cho UID hiện tại của nó.

* Mỗi người dùng có hai hạn ngạch để theo dõi các khóa họ sở hữu. một
     giới hạn tổng số chìa khóa và dây móc khóa, giới hạn còn lại giới hạn tổng số
     lượng mô tả và không gian tải trọng có thể được sử dụng.

Người dùng có thể xem thông tin về điều này và các số liệu thống kê khác thông qua Procfs
     tập tin.  Người dùng root cũng có thể thay đổi giới hạn hạn ngạch thông qua các tệp sysctl
     (xem phần "Tệp Procfs mới").

Chuỗi khóa dành riêng cho quy trình và luồng cụ thể không được tính vào
     hạn ngạch của người dùng.

Nếu một lệnh gọi hệ thống sửa đổi một phím hoặc chuỗi khóa theo một cách nào đó sẽ đặt
     người dùng vượt quá hạn ngạch, thao tác bị từ chối và lỗi EDQUOT được trả về.

* Có một giao diện cuộc gọi hệ thống mà qua đó các chương trình không gian người dùng có thể tạo và
     thao tác với chìa khóa và dây móc khóa.

* Có giao diện kernel để các dịch vụ có thể đăng ký loại và tìm kiếm
     cho các phím.

* Có một cách để việc tìm kiếm được thực hiện từ kernel gọi lại
     không gian người dùng để yêu cầu một khóa không thể tìm thấy trong chuỗi khóa của quy trình.

* Một hệ thống tập tin tùy chọn có sẵn thông qua đó cơ sở dữ liệu chính có thể được
     được xem và thao tác.


Quyền truy cập chính
======================

Khóa có ID người dùng chủ sở hữu, ID truy cập nhóm và mặt nạ quyền. Mặt nạ
có tối đa 8 bit cho mỗi người sở hữu, người dùng, nhóm và quyền truy cập khác. Chỉ
sáu trong số mỗi bộ tám bit được xác định. Các quyền được cấp là:

*  Xem

Điều này cho phép xem các thuộc tính của khóa hoặc vòng khóa - bao gồm cả khóa
     loại và mô tả.

*  Đọc

Điều này cho phép xem trọng tải của khóa hoặc danh sách liên kết của khóa
     phím.

*  Viết

Điều này cho phép tải trọng của khóa được khởi tạo hoặc cập nhật hoặc cho phép
     liên kết được thêm vào hoặc xóa khỏi vòng khóa.

*  Tìm kiếm

Điều này cho phép tìm kiếm các chuỗi khóa và tìm thấy chìa khóa. Tìm kiếm có thể
     chỉ lặp lại vào các chuỗi khóa lồng nhau đã được đặt quyền tìm kiếm.

* Liên kết

Điều này cho phép một khóa hoặc chuỗi khóa được liên kết tới. Để tạo một liên kết từ một
     khóa vào một khóa, một tiến trình phải có quyền Ghi trên khóa và
     Quyền liên kết trên key.

* Đặt thuộc tính

Điều này cho phép thay đổi UID, GID và mặt nạ quyền của khóa.

Để thay đổi quyền sở hữu, ID nhóm hoặc mặt nạ quyền, là chủ sở hữu của
chìa khóa hoặc có khả năng quản trị hệ thống là đủ.


Hỗ trợ SELinux
===============

"Khóa" lớp bảo mật đã được thêm vào SELinux để quyền truy cập bắt buộc
các điều khiển có thể được áp dụng cho các khóa được tạo trong nhiều ngữ cảnh khác nhau.  Sự hỗ trợ này
là sơ bộ và có thể sẽ thay đổi khá đáng kể trong tương lai gần.
Hiện tại, tất cả các quyền cơ bản được giải thích ở trên đều được cung cấp trong SELinux
cũng vậy; SELinux chỉ được gọi sau khi tất cả các bước kiểm tra quyền cơ bản đã được thực hiện.
được thực hiện.

Giá trị của tệp /proc/self/attr/keycreate ảnh hưởng đến việc gắn nhãn của
khóa mới được tạo.  Nếu nội dung của tệp đó tương ứng với SELinux
ngữ cảnh bảo mật thì khóa sẽ được gán ngữ cảnh đó.  Nếu không,
khóa sẽ được gán bối cảnh hiện tại của tác vụ đã gọi khóa
yêu cầu tạo.  Nhiệm vụ phải được cấp quyền rõ ràng để phân công
ngữ cảnh cụ thể cho các khóa mới được tạo bằng cách sử dụng quyền "tạo" trong
lớp bảo mật quan trọng.

Các chuỗi khóa mặc định được liên kết với người dùng sẽ được gắn nhãn mặc định
ngữ cảnh của người dùng khi và chỉ nếu chương trình đăng nhập được cài đặt để
khởi tạo keycreate đúng cách trong quá trình đăng nhập.  Nếu không, họ sẽ
được gắn nhãn với bối cảnh của chính chương trình đăng nhập.

Tuy nhiên, lưu ý rằng các chuỗi khóa mặc định được liên kết với người dùng root là
được gắn nhãn với bối cảnh kernel mặc định, vì chúng được tạo sớm trong
quá trình khởi động, trước khi root có cơ hội đăng nhập.

Các chuỗi khóa liên kết với các chủ đề mới đều được gắn nhãn với ngữ cảnh của
luồng liên quan của chúng và cả chuỗi khóa phiên và quy trình đều được xử lý
tương tự.


Tệp ProcFS mới
================

Hai tệp đã được thêm vào Procfs để quản trị viên có thể tìm ra
về trạng thái của dịch vụ chính:

* /proc/phím

Điều này liệt kê các khóa hiện có thể xem được bởi tác vụ đọc
     tập tin, cung cấp thông tin về loại, mô tả và quyền của chúng.
     Không thể xem tải trọng của khóa theo cách này, mặc dù một số
     thông tin về nó có thể được cung cấp.

Các khóa duy nhất có trong danh sách là những khóa cấp quyền Xem cho
     quá trình đọc dù nó có sở hữu chúng hay không.  Lưu ý rằng LSM
     kiểm tra bảo mật vẫn được thực hiện và có thể lọc thêm các khóa
     quá trình hiện tại không được phép xem.

Nội dung của tập tin trông như thế này::

SERIAL FLAGS USAGE EXPY PERM UID GID TYPE DESCRIPTION: SUMMARY
	00000001 Tôi------ 39 perm 1f3f0000 0 0 móc khóa _uid_ses.0: 1/4
	00000002 Tôi------ 2 perm 1f3f0000 0 0 móc khóa _uid.0: trống
	00000007 Tôi------ 1 perm 1f3f0000 0 0 móc khóa _pid.1: trống
	0000018d I---- 1 perm 1f3f0000 0 0 móc khóa _pid.412: trống
	000004d2 I--Q-- 1 perm 1f3f0000 32 -1 móc khóa _uid.32: 1/4
	000004d3 I--Q-- 3 perm 1f3f0000 32 -1 vòng khóa _uid_ses.32: trống
	00000892 I--QU- 1 perm 1f000000 0 0 người dùng kim loại:đồng: 0
	00000893 I--Q-N 1 35s 1f3f0000 0 0 người dùng kim loại:bạc: 0
	00000894 I--Q-- 1 10h 003f0000 0 0 người dùng kim loại:vàng: 0

Các lá cờ là::

Tôi đã khởi tạo
	R Đã thu hồi
	D Chết
	Q Đóng góp vào hạn ngạch của người dùng
	U Đang được xây dựng bằng cách gọi lại không gian người dùng
	N Phím âm


* /proc/key-người dùng

Tệp này liệt kê dữ liệu theo dõi cho mỗi người dùng có ít nhất một khóa
     trên hệ thống.  Dữ liệu đó bao gồm thông tin và số liệu thống kê về hạn ngạch::

[root@andromeda root]# cat /proc/key-users
	0: 46 45/45 1/100 13/10000
	29: 2 2/2 2/100 40/10000
	32: 2 2/2 2/100 40/10000
	38: 2 2/2 2/100 40/10000

Định dạng của mỗi dòng là::

<UID>: ID người dùng áp dụng điều này
	<cách sử dụng> Hoàn tiền cấu trúc
	<inst>/<keys> Tổng số khóa và số được khởi tạo
	<keys>/<max> Hạn mức số lượng khóa
	<bytes>/<max> Hạn mức kích thước khóa


Bốn tệp sysctl mới cũng đã được thêm vào nhằm mục đích kiểm soát
giới hạn hạn ngạch trên các khóa:

* /proc/sys/kernel/keys/root_maxkeys
     /proc/sys/kernel/keys/root_maxbytes

Những tập tin này chứa số lượng khóa tối đa mà root có thể có và
     tổng số byte dữ liệu tối đa mà root có thể lưu trữ trong đó
     phím.

* /proc/sys/kernel/keys/maxkeys
     /proc/sys/kernel/keys/maxbyte

Những tệp này chứa số lượng khóa tối đa mà mỗi người dùng không phải root có thể
     có và tổng số byte dữ liệu tối đa mà mỗi byte đó
     người dùng có thể đã lưu trữ trong khóa của họ.

Root có thể thay đổi những điều này bằng cách viết mỗi giới hạn mới dưới dạng chuỗi số thập phân vào
tập tin thích hợp.


Giao diện cuộc gọi hệ thống không gian người dùng
===============================

Không gian người dùng có thể thao tác trực tiếp với các khóa thông qua ba lệnh gọi tổng hợp mới: add_key,
request_key và keyctl. Cái sau cung cấp một số chức năng cho
thao tác phím.

Khi đề cập trực tiếp đến một khóa, các chương trình không gian người dùng nên sử dụng khóa
số sê-ri (số nguyên dương 32 bit). Tuy nhiên, có một số điều đặc biệt
các giá trị có sẵn để tham chiếu đến các khóa và chuỗi khóa đặc biệt liên quan đến
quá trình thực hiện cuộc gọi::

CONSTANT VALUE KEY REFERENCED
	=============================== ====== ===============================
	Móc khóa dành riêng cho chủ đề KEY_SPEC_THREAD_KEYRING -1
	Khóa dành riêng cho quy trình KEY_SPEC_PROCESS_KEYRING -2
	Khóa dành riêng cho phiên KEY_SPEC_SESSION_KEYRING -3
	Móc khóa dành riêng cho KEY_SPEC_USER_KEYRING -4 UID
	Móc khóa phiên KEY_SPEC_USER_SESSION_KEYRING -5 UID
	Móc khóa dành riêng cho KEY_SPEC_GROUP_KEYRING -6 GID
	KEY_SPEC_REQKEY_AUTH_KEY -7 giả định request_key()
						  khóa ủy quyền


Các syscalls chính là:

* Tạo một khóa mới có loại, mô tả và tải trọng nhất định và thêm nó vào
     móc khóa được đề cử::

key_serial_t add_key(const char *type, const char *desc,
			     const void *tải trọng, size_t plen,
			     móc khóa key_serial_t);

Nếu khóa cùng loại và mô tả như đề xuất đã tồn tại
     trong chuỗi khóa, điều này sẽ cố gắng cập nhật nó với tải trọng đã cho hoặc nó
     sẽ trả về lỗi EEXIST nếu chức năng đó không được phím hỗ trợ
     loại. Quá trình cũng phải có quyền ghi vào khóa để có thể
     để cập nhật nó. Khóa mới sẽ được cấp tất cả các quyền của người dùng và không
     quyền của nhóm hoặc bên thứ ba.

Nếu không, điều này sẽ cố gắng tạo một khóa mới thuộc loại đã chỉ định và
     mô tả và khởi tạo nó với tải trọng được cung cấp và đính kèm nó
     đến chiếc móc khóa. Trong trường hợp này, lỗi sẽ được tạo ra nếu quá trình
     không có quyền ghi vào keyring.

Nếu loại khóa hỗ trợ nó, nếu mô tả là NULL hoặc trống
     chuỗi, loại khóa sẽ thử và tạo mô tả từ nội dung
     của tải trọng.

Tải trọng là tùy chọn và con trỏ có thể là NULL nếu không được yêu cầu bởi
     kiểu đó. Tải trọng có kích thước plen và plen có thể bằng 0 nếu trống
     tải trọng.

Một chuỗi khóa mới có thể được tạo bằng cách cài đặt loại "chuỗi khóa", tên chuỗi khóa
     làm mô tả (hoặc NULL) và đặt tải trọng thành NULL.

Các khóa do người dùng xác định có thể được tạo bằng cách chỉ định loại "người dùng". Đó là
     khuyến nghị rằng mô tả của khóa do người dùng xác định có tiền tố là một loại
     ID và dấu hai chấm, chẳng hạn như "krb5tgt:" để cấp vé Kerberos 5
     vé.

Bất kỳ loại nào khác phải được đăng ký trước với kernel bởi một
     dịch vụ hạt nhân như hệ thống tập tin.

ID của khóa mới hoặc khóa cập nhật sẽ được trả về nếu thành công.


* Tìm kiếm các chuỗi khóa của quy trình để tìm một khóa, có khả năng gọi tới
     không gian người dùng để tạo nó::

key_serial_t request_key(const char *type, const char *description,
				 const char *callout_info,
				 key_serial_t dest_keyring);

Hàm này tìm kiếm tất cả các chuỗi khóa của quy trình trong chuỗi thứ tự,
     quá trình, phiên cho một khóa phù hợp. Điều này hoạt động rất giống
     KEYCTL_SEARCH, bao gồm phần đính kèm tùy chọn của khóa được phát hiện vào
     một chiếc móc khóa.

Nếu không tìm thấy khóa và nếu callout_info không phải là NULL thì
     /sbin/request-key sẽ được gọi để cố gắng lấy khóa. các
     chuỗi callout_info sẽ được chuyển làm đối số cho chương trình.

Để liên kết một khóa với khóa đích, khóa đó phải cấp liên kết
     quyền trên khóa đối với người gọi và khóa phải cấp quyền ghi
     sự cho phép.

Xem thêm Tài liệu/bảo mật/khóa/request-key.rst.


Các chức năng của tòa nhà keyctl là:

* Ánh xạ ID khóa đặc biệt tới ID khóa thực cho quá trình này::

key_serial_t keyctl(KEYCTL_GET_KEYRING_ID, key_serial_t id,
			    int tạo);

Khóa đặc biệt do "id" chỉ định sẽ được tra cứu (với khóa được tạo
     nếu cần) và ID của khóa hoặc chuỗi khóa được tìm thấy sẽ được trả về nếu
     nó tồn tại.

Nếu khóa chưa tồn tại, khóa sẽ được tạo nếu "tạo" được thực hiện
     khác không; và lỗi ENOKEY sẽ được trả về nếu "tạo" bằng 0.


* Thay thế khóa phiên mà quá trình này đăng ký bằng một khóa mới::

key_serial_t keyctl(KEYCTL_JOIN_SESSION_KEYRING, const char *name);

Nếu tên là NULL, một khóa ẩn danh sẽ được tạo kèm theo quy trình
     làm khóa phiên của nó, thay thế khóa phiên cũ.

Nếu tên không phải là NULL, nếu tồn tại một chuỗi khóa có tên đó thì quy trình
     cố gắng đính kèm nó dưới dạng khóa phiên, trả về lỗi nếu điều đó
     không được phép; nếu không thì một chuỗi khóa mới có tên đó sẽ được tạo và
     được đính kèm dưới dạng khóa phiên.

Để đính kèm vào một chuỗi khóa được đặt tên, chuỗi khóa đó phải có quyền tìm kiếm
     quyền sở hữu của quá trình.

ID của khóa phiên mới sẽ được trả về nếu thành công.


* Cập nhật khóa được chỉ định::

keyctl dài (KEYCTL_UPDATE, khóa key_serial_t, const void *tải trọng,
		    size_t đầy đủ);

Điều này sẽ cố gắng cập nhật khóa đã chỉ định với tải trọng đã cho hoặc nó
     sẽ trả về lỗi EOPNOTSUPP nếu chức năng đó không được phím hỗ trợ
     loại. Quá trình cũng phải có quyền ghi vào khóa để có thể
     để cập nhật nó.

Tải trọng có độ dài lớn và có thể vắng mặt hoặc trống đối với
     add_key().


* Thu hồi chìa khóa::

keyctl dài (khóa KEYCTL_REVOKE, key_serial_t);

Điều này làm cho khóa không có sẵn cho các hoạt động tiếp theo. Những nỗ lực tiếp theo để
     sử dụng key sẽ gặp lỗi EKEYREVOKED và key sẽ không còn nữa
     có thể tìm thấy được.


* Thay đổi quyền sở hữu chìa khóa::

keyctl dài (KEYCTL_CHOWN, khóa key_serial_t, uid_t uid, gid_t gid);

Chức năng này cho phép thay đổi chủ sở hữu khóa và ID nhóm. Một trong hai
     uid hoặc gid có thể được đặt thành -1 để ngăn chặn sự thay đổi đó.

Chỉ siêu người dùng mới có thể thay đổi chủ sở hữu của khóa thành một thứ khác ngoài
     chủ sở hữu hiện tại của chìa khóa. Tương tự, chỉ có siêu người dùng mới có thể thay đổi khóa
     ID nhóm thành một cái gì đó không phải là ID nhóm của quá trình gọi hoặc một trong các
     danh sách thành viên nhóm của nó.


* Thay đổi mặt nạ quyền trên một khóa::

keyctl dài (KEYCTL_SETPERM, khóa key_serial_t, key_perm_t perm);

Chức năng này cho phép chủ sở hữu khóa hoặc siêu người dùng thay đổi
     mặt nạ quyền trên một phím.

Chỉ cho phép các bit có sẵn; nếu có bất kỳ bit nào khác được đặt,
     lỗi EINVAL sẽ được trả về.


* Mô tả một phím::

keyctl dài (KEYCTL_DESCRIBE, khóa key_serial_t, char *buffer,
		    size_t buflen);

Hàm này trả về một bản tóm tắt các thuộc tính của khóa (nhưng không trả về
     dữ liệu tải trọng) dưới dạng một chuỗi trong bộ đệm được cung cấp.

Trừ khi có lỗi, nó luôn trả về lượng dữ liệu có thể
     tạo ra, ngay cả khi nó quá lớn đối với bộ đệm, nhưng nó sẽ không sao chép thêm
     hơn yêu cầu đối với không gian người dùng. Nếu con trỏ đệm là NULL thì không có bản sao
     sẽ diễn ra.

Một tiến trình phải có quyền xem trên khóa để chức năng này được thực hiện
     thành công.

Nếu thành công, một chuỗi sẽ được đặt vào bộ đệm theo định dạng sau::

<type>;<uid>;<gid>;<perm>;<mô tả>

Trong đó loại và mô tả là chuỗi, uid và gid là số thập phân và perm
     là thập lục phân. Ký tự NUL được thêm vào cuối chuỗi nếu
     bộ đệm đủ lớn.

Điều này có thể được phân tích bằng ::

sscanf(buffer, "%[^;];%d;%d;%o;%s", type, &uid, &gid, &mode, desc);


* Xóa móc chìa khóa::

keyctl dài (khóa KEYCTL_CLEAR, key_serial_t);

Chức năng này xóa danh sách các phím được gắn vào một vòng khóa. Sự kêu gọi
     quá trình phải có quyền ghi trên khóa và nó phải là một
     gõ phím (nếu không sẽ xảy ra lỗi ENOTDIR).

Chức năng này cũng có thể được sử dụng để xóa các chuỗi khóa hạt nhân đặc biệt nếu chúng
     được đánh dấu thích hợp nếu người dùng có khả năng CAP_SYS_ADMIN.  các
     Khóa bộ nhớ đệm của trình phân giải DNS là một ví dụ về điều này.


* Liên kết chìa khóa thành móc khóa::

keyctl dài (khóa KEYCTL_LINK, key_serial_t, khóa key_serial_t);

Chức năng này tạo ra một liên kết từ keyring đến key. Quá trình này phải
     có quyền ghi trên móc khóa và phải có quyền liên kết trên
     chìa khóa.

Nếu chuỗi khóa không phải là chuỗi khóa thì sẽ xảy ra lỗi ENOTDIR; và nếu
     khóa đã đầy, sẽ xảy ra lỗi ENFILE.

Quy trình liên kết kiểm tra việc lồng các chuỗi khóa, trả về ELOOP nếu
     nó xuất hiện quá sâu hoặc EDEADLK nếu liên kết tạo ra một chu kỳ.

Bất kỳ liên kết nào trong chuỗi khóa tới các khóa khớp với khóa mới về mặt
     loại và mô tả sẽ bị loại bỏ khỏi chuỗi khóa vì cái mới được
     đã thêm vào.


* Di chuyển một phím từ phím này sang phím khác::

keyctl dài (KEYCTL_MOVE,
		    id key_serial_t,
		    key_serial_t từ_ring_id,
		    key_serial_t tới_ring_id,
		    cờ int không dấu);

Di chuyển khóa được chỉ định bởi "id" khỏi chuỗi khóa được chỉ định bởi
     "from_ring_id" thành chuỗi khóa được chỉ định bởi "to_ring_id".  Nếu hai
     dây móc khóa giống nhau, không có gì được thực hiện.

"cờ" có thể được cài đặt KEYCTL_MOVE_EXCL trong đó để khiến hoạt động không thành công
     với EEXIST nếu tồn tại khóa phù hợp trong khóa đích, nếu không
     một chìa khóa như vậy sẽ được thay thế.

Một tiến trình phải có quyền liên kết trên khóa để chức năng này được thực hiện
     thành công và viết quyền trên cả hai dây móc khóa.  Bất kỳ lỗi nào có thể
     xảy ra từ KEYCTL_LINK cũng được áp dụng cho khóa đích tại đây.


* Hủy liên kết một khóa hoặc khóa với một khóa khác::

keyctl dài (khóa KEYCTL_UNLINK, key_serial_t, khóa key_serial_t);

Hàm này xem qua chuỗi khóa để tìm liên kết đầu tiên tới
     khóa được chỉ định và xóa nó nếu tìm thấy. Các liên kết tiếp theo tới khóa đó là
     bị phớt lờ. Quá trình này phải có quyền ghi trên khóa.

Nếu chuỗi khóa không phải là chuỗi khóa, sẽ xảy ra lỗi ENOTDIR; và nếu chìa khóa
     không xuất hiện thì kết quả sẽ là lỗi ENOENT.


* Tìm kiếm cây khóa để tìm khóa::

key_serial_t keyctl(KEYCTL_SEARCH, key_serial_t keyring,
			    const char *type, const char *mô tả,
			    key_serial_t dest_keyring);

Thao tác này sẽ tìm kiếm trong cây khóa có khóa được chỉ định cho đến khi tìm thấy một khóa
     được tìm thấy phù hợp với tiêu chí loại và mô tả. Mỗi chiếc móc khóa là
     kiểm tra các khóa trước khi đệ quy vào các con của nó.

Quá trình này phải có quyền tìm kiếm trên khóa cấp cao nhất, nếu không
     sẽ xảy ra lỗi EACCES. Chỉ các dây móc khóa mà quá trình này có tìm kiếm
     quyền được bật sẽ được đệ quy vào và chỉ các khóa và chuỗi khóa được
     một quá trình có quyền tìm kiếm có thể được kết hợp. Nếu khóa được chỉ định
     không phải là móc khóa, kết quả sẽ là ENOTDIR.

Nếu tìm kiếm thành công, hàm sẽ cố gắng liên kết khóa tìm thấy
     vào khóa đích nếu một khóa được cung cấp (ID khác 0). Tất cả
     các ràng buộc áp dụng cho KEYCTL_LINK cũng được áp dụng trong trường hợp này.

Lỗi ENOKEY, EKEYREVOKED hoặc EKEYEXPIRED sẽ được trả về nếu tìm kiếm
     thất bại. Nếu thành công, ID khóa kết quả sẽ được trả về.


* Đọc dữ liệu tải trọng từ một khóa::

keyctl dài (KEYCTL_READ, key_serial_t keyring, char *buffer,
		    size_t buflen);

Hàm này cố gắng đọc dữ liệu tải trọng từ khóa được chỉ định
     vào bộ đệm. Quá trình này phải có quyền đọc trên khóa để
     thành công.

Dữ liệu trả về sẽ được xử lý để trình bày theo loại khóa. cho
     Ví dụ, một chuỗi khóa sẽ trả về một mảng các mục key_serial_t
     đại diện cho ID của tất cả các khóa mà nó được đăng ký. Người dùng
     loại khóa được xác định sẽ trả về dữ liệu của nó. Nếu một loại khóa không
     thực hiện chức năng này sẽ xảy ra lỗi EOPNOTSUPP.

Nếu bộ đệm được chỉ định quá nhỏ thì kích thước của bộ đệm cần thiết
     sẽ được trả lại.  Lưu ý rằng trong trường hợp này, nội dung của bộ đệm có thể
     đã bị ghi đè theo một cách nào đó không xác định.

Ngược lại, khi thành công hàm sẽ trả về lượng dữ liệu đã copy
     vào bộ đệm.

* Khởi tạo khóa được xây dựng một phần::

keyctl dài (KEYCTL_INSTANTIATE, khóa key_serial_t,
		    const void *tải trọng, size_t plen,
		    móc khóa key_serial_t);
	keyctl dài (KEYCTL_INSTANTIATE_IOV, khóa key_serial_t,
		    const struct iovec *payload_iov, ioc không dấu,
		    móc khóa key_serial_t);

Nếu kernel gọi trở lại không gian người dùng để hoàn thành việc khởi tạo một
     khóa, không gian người dùng nên sử dụng lệnh gọi này để cung cấp dữ liệu cho khóa trước
     quá trình được gọi sẽ trả về, nếu không khóa sẽ được đánh dấu là âm
     tự động.

Quá trình phải có quyền ghi trên khóa để có thể khởi tạo
     nó và khóa phải chưa được khởi tạo.

Nếu một chuỗi khóa được chỉ định (khác 0), khóa đó cũng sẽ được liên kết vào
     khóa đó, tuy nhiên tất cả các ràng buộc áp dụng trong KEYCTL_LINK đều áp dụng trong
     trường hợp này cũng vậy.

Các đối số tải trọng và plen mô tả dữ liệu tải trọng như đối với add_key().

Các đối số payload_iov và ioc mô tả dữ liệu tải trọng trong iovec
     mảng thay vì một bộ đệm duy nhất.


* Khởi tạo một cách tiêu cực một khóa được xây dựng một phần::

keyctl dài (KEYCTL_NEGATE, khóa key_serial_t,
		    thời gian chờ không dấu, khóa key_serial_t);
	keyctl dài (KEYCTL_REJECT, khóa key_serial_t,
		    thời gian chờ không dấu, lỗi không dấu, khóa key_serial_t);

Nếu kernel gọi trở lại không gian người dùng để hoàn thành việc khởi tạo một
     khóa, không gian người dùng nên sử dụng cuộc gọi này, đánh dấu khóa là số âm trước
     quá trình được gọi sẽ trả về nếu nó không thể thực hiện được yêu cầu.

Quá trình phải có quyền ghi trên khóa để có thể khởi tạo
     nó và khóa phải chưa được khởi tạo.

Nếu một chuỗi khóa được chỉ định (khác 0), khóa đó cũng sẽ được liên kết vào
     khóa đó, tuy nhiên tất cả các ràng buộc áp dụng trong KEYCTL_LINK đều áp dụng trong
     trường hợp này cũng vậy.

Nếu khóa bị từ chối, các tìm kiếm trong tương lai sẽ trả về khóa đã chỉ định
     mã lỗi cho đến khi khóa bị từ chối hết hạn.  Phủ định chìa khóa là như nhau
     như từ chối khóa có mã lỗi ENOKEY.


* Đặt khóa đích của khóa yêu cầu mặc định::

keyctl dài (KEYCTL_SET_REQKEY_KEYRING, int reqkey_defl);

Điều này đặt khóa mặc định cho các khóa được yêu cầu ngầm định.
     đính kèm cho chủ đề này. reqkey_defl phải là một trong những hằng số sau::

CONSTANT VALUE NEW DEFAULT KEYRING
	======================================= ====== ==========================
	KEY_REQKEY_DEFL_NO_CHANGE -1 Không thay đổi
	KEY_REQKEY_DEFL_DEFAULT 0 Mặc định[1]
	KEY_REQKEY_DEFL_THREAD_KEYRING 1 Móc khóa chủ đề
	KEY_REQKEY_DEFL_PROCESS_KEYRING 2 Khóa quy trình
	Móc khóa phiên KEY_REQKEY_DEFL_SESSION_KEYRING 3
	KEY_REQKEY_DEFL_USER_KEYRING 4 Móc khóa người dùng
	KEY_REQKEY_DEFL_USER_SESSION_KEYRING 5 Khóa phiên người dùng
	Móc khóa nhóm KEY_REQKEY_DEFL_GROUP_KEYRING 6

Mặc định cũ sẽ được trả về nếu thành công và lỗi EINVAL sẽ được
     được trả về nếu reqkey_defl không phải là một trong các giá trị trên.

Chuỗi khóa mặc định có thể được ghi đè bằng chuỗi khóa được chỉ định cho
     cuộc gọi hệ thống request_key().

Lưu ý rằng cài đặt này được kế thừa qua fork/exec.

[1] Giá trị mặc định là: chuỗi khóa nếu có, nếu không thì
     khóa quy trình nếu có, nếu không thì khóa phiên nếu có
     có một cái, nếu không thì khóa phiên mặc định của người dùng.


* Đặt thời gian chờ trên một phím::

keyctl dài (KEYCTL_SET_TIMEOUT, khóa key_serial_t, thời gian chờ chưa dấu);

Việc này sẽ đặt hoặc xóa thời gian chờ trên một phím. Thời gian chờ có thể là 0 để xóa
     thời gian chờ hoặc một số giây để đặt thời gian hết hạn đến mức
     tương lai.

Quá trình phải có quyền truy cập sửa đổi thuộc tính trên một khóa để thiết lập nó
     hết thời gian chờ. Không thể đặt thời gian chờ khi chức năng này ở trạng thái âm, bị thu hồi
     hoặc các phím đã hết hạn.


* Giả sử quyền được cấp để khởi tạo một khóa::

keyctl dài (khóa KEYCTL_ASSUME_AUTHORITY, key_serial_t);

Điều này giả định hoặc loại bỏ quyền hạn cần thiết để khởi tạo
     khóa được chỉ định. Quyền hạn chỉ có thể được thừa nhận nếu luồng có
     khóa ủy quyền được liên kết với khóa được chỉ định trong chuỗi khóa của nó
     ở đâu đó.

Khi quyền được thừa nhận, việc tìm kiếm khóa cũng sẽ tìm kiếm
     dây móc khóa của người yêu cầu sử dụng nhãn bảo mật của người yêu cầu, UID, GID và
     các nhóm.

Nếu cơ quan được yêu cầu không có sẵn, lỗi EPERM sẽ được trả về,
     tương tự như vậy nếu quyền hạn đã bị thu hồi vì khóa mục tiêu là
     đã được khởi tạo rồi.

Nếu khóa được chỉ định là 0 thì mọi quyền hạn giả định sẽ bị loại bỏ.

Khóa có thẩm quyền giả định được kế thừa qua fork và exec.


* Lấy bối cảnh bảo mật LSM kèm theo khóa::

keyctl dài (KEYCTL_GET_SECURITY, khóa key_serial_t, char *buffer,
		    size_t lớn)

Hàm này trả về một chuỗi đại diện cho bối cảnh bảo mật LSM
     được gắn vào một khóa trong bộ đệm được cung cấp.

Trừ khi có lỗi, nó luôn trả về lượng dữ liệu có thể
     tạo ra, ngay cả khi nó quá lớn đối với bộ đệm, nhưng nó sẽ không sao chép thêm
     hơn yêu cầu đối với không gian người dùng. Nếu con trỏ đệm là NULL thì không có bản sao
     sẽ diễn ra.

Ký tự NUL được bao gồm ở cuối chuỗi nếu bộ đệm được
     đủ lớn.  Điều này được bao gồm trong số lượng trả về.  Nếu không có LSM
     có hiệu lực thì một chuỗi trống sẽ được trả về.

Một tiến trình phải có quyền xem trên khóa để chức năng này được thực hiện
     thành công.


* Cài đặt khóa phiên của quá trình gọi trên cha của nó::

keyctl dài (KEYCTL_SESSION_TO_PARENT);

Chức năng này cố gắng cài đặt khóa phiên của quá trình gọi
     vào cha của tiến trình gọi, thay thế phiên hiện tại của tiến trình cha
     móc khóa.

Quá trình gọi phải có cùng quyền sở hữu với tiến trình cha của nó,
     việc tạo khóa phải có cùng quyền sở hữu với quá trình gọi, quá trình gọi
     quá trình phải có quyền LINK trên chuỗi khóa và mô-đun LSM đang hoạt động
     không được từ chối quyền, nếu không lỗi EPERM sẽ được trả về.

Lỗi ENOMEM sẽ được trả về nếu không đủ bộ nhớ để hoàn thành
     hoạt động, nếu không sẽ trả về 0 để biểu thị thành công.

Khóa sẽ được thay thế vào lần tới khi tiến trình cha rời khỏi
     kernel và tiếp tục thực thi không gian người dùng.


* Vô hiệu hóa một khóa::

keyctl dài (khóa KEYCTL_INVALIDATE, key_serial_t);

Chức năng này đánh dấu một khóa là không hợp lệ và sau đó đánh thức khóa đó.
     người thu gom rác.  Trình thu gom rác ngay lập tức loại bỏ các thông tin không hợp lệ
     các phím khỏi tất cả các chuỗi móc khóa và xóa khóa khi số tham chiếu của nó
     đạt đến số không.

Các khóa được đánh dấu là không hợp lệ sẽ trở nên vô hình đối với các thao tác phím thông thường
     ngay lập tức, mặc dù chúng vẫn hiển thị trong /proc/keys cho đến khi bị xóa
     (chúng được đánh dấu bằng cờ 'i').

Một tiến trình phải có quyền tìm kiếm trên khóa để chức năng này được thực hiện
     thành công.

* Tính toán khóa bí mật hoặc khóa chung của Diffie-Hellman::

keyctl dài(KEYCTL_DH_COMPUTE, struct keyctl_dh_params *params,
		    char *buffer, size_t buflen, struct keyctl_kdf_params *kdf);

Cấu trúc params chứa số sê-ri cho ba khóa ::

- Số nguyên tố p được cả hai bên biết
	 - Khóa riêng cục bộ
	 - Số nguyên cơ sở, là số nguyên dùng chung hoặc số nguyên
	   khóa công khai từ xa

Giá trị được tính là::

kết quả = cơ sở ^ riêng tư (mod prime)

Nếu cơ sở là trình tạo dùng chung thì kết quả là cục bộ
     khóa công khai.  Nếu cơ sở là khóa chung từ xa thì kết quả là
     bí mật được chia sẻ.

Nếu tham số kdf là NULL thì áp dụng như sau:

- Độ dài bộ đệm ít nhất phải bằng độ dài của số nguyên tố hoặc bằng 0.

- Nếu độ dài bộ đệm khác 0 thì độ dài của kết quả là
	   được trả về khi nó được tính toán thành công và được sao chép vào
	   bộ đệm. Khi độ dài bộ đệm bằng 0, yêu cầu tối thiểu
	   chiều dài bộ đệm được trả về.

Tham số kdf cho phép người gọi áp dụng hàm dẫn xuất khóa
     (KDF) trong phép tính Diffie-Hellman trong đó chỉ có kết quả
     của KDF được trả lại cho người gọi. KDF được đặc trưng bởi
     cấu trúc keyctl_kdf_params như sau:

- ZZ0000ZZ chỉ định nhận dạng chuỗi kết thúc NUL
	   hàm băm được sử dụng từ mật mã hạt nhân API và áp dụng cho KDF
	   hoạt động. Việc triển khai KDF cũng tuân thủ SP800-56A
	   như với SP800-108 (bộ đếm KDF).

- ZZ0000ZZ chỉ định dữ liệu OtherInfo như được ghi trong
	   SP800-56A phần 5.8.1.2. Độ dài của bộ đệm được đưa ra với
	   otherinfolen. Định dạng của OtherInfo được xác định bởi người gọi.
	   Con trỏ thông tin khác có thể là NULL nếu không sử dụng Thông tin khác.

Hàm này sẽ trả về lỗi EOPNOTSUPP nếu loại khóa không
     được hỗ trợ, lỗi ENOKEY nếu không tìm thấy khóa hoặc lỗi
     EACCES nếu người gọi không thể đọc được khóa. Ngoài ra,
     hàm sẽ trả về EMSGSIZE khi tham số kdf không phải là NULL
     và độ dài bộ đệm hoặc độ dài OtherInfo vượt quá
     chiều dài cho phép.


* Hạn chế liên kết khóa::

keyctl dài (KEYCTL_RESTRICT_KEYRING, khóa key_serial_t,
		    const char *type, const char *hạn chế);

Khóa hiện tại có thể hạn chế liên kết các khóa bổ sung bằng cách đánh giá
     nội dung của khóa theo sơ đồ hạn chế.

"Chuỗi khóa" là ID khóa cho khóa hiện có để áp dụng hạn chế
     đến. Nó có thể trống hoặc có thể đã có khóa được liên kết. Các khóa liên kết hiện có
     sẽ vẫn còn trong vòng khóa ngay cả khi hạn chế mới sẽ từ chối chúng.

"loại" là loại khóa đã đăng ký.

"hạn chế" là một chuỗi mô tả cách hạn chế liên kết khóa.
     Định dạng khác nhau tùy thuộc vào loại khóa và chuỗi được truyền tới
     hàm lookup_restriction() cho loại được yêu cầu.  Nó có thể chỉ định
     một phương pháp và dữ liệu liên quan cho việc hạn chế như chữ ký
     xác minh hoặc ràng buộc về tải trọng chính. Nếu loại khóa được yêu cầu là
     sau đó chưa được đăng ký, không có khóa nào có thể được thêm vào chuỗi khóa sau loại khóa
     được gỡ bỏ.

Để áp dụng hạn chế khóa, quy trình phải có Đặt thuộc tính
     quyền và khóa không được hạn chế trước đó.

Một ứng dụng của chuỗi khóa bị hạn chế là xác minh chứng chỉ X.509
     chuỗi hoặc chữ ký chứng chỉ riêng lẻ bằng cách sử dụng loại khóa bất đối xứng.
     Xem Tài liệu/crypto/asymic-keys.rst để biết các hạn chế cụ thể
     áp dụng cho loại khóa bất đối xứng.


* Truy vấn khóa bất đối xứng::

keyctl dài (KEYCTL_PKEY_QUERY,
		    key_serial_t key_id, dành riêng lâu dài không dấu,
		    const char *params,
		    struct keyctl_pkey_query *thông tin);

Nhận thông tin về khóa bất đối xứng.  Các thuật toán cụ thể và
     mã hóa có thể được truy vấn bằng cách sử dụng đối số ZZ0000ZZ.  Đây là một
     chuỗi chứa một chuỗi các cặp khóa-giá trị được phân tách bằng dấu cách hoặc tab.
     Các khóa hiện được hỗ trợ bao gồm ZZ0001ZZ và ZZ0002ZZ.  Thông tin
     được trả về trong cấu trúc keyctl_pkey_query::

__u32 được hỗ trợ_ops;
	__u32 key_size;
	__u16 max_data_size;
	__u16 max_sig_size;
	__u16 max_enc_size;
	__u16 max_dec_size;
	__u32 __spare[10];

ZZ0000ZZ chứa một mặt nạ cờ bit cho biết hoạt động nào đang diễn ra
     được hỗ trợ.  Điều này được xây dựng từ bitwise-OR của::

KEYCTL_SUPPORTS_{ENCRYPT,DECRYPT,SIGN,VERIFY}

ZZ0000ZZ cho biết kích thước của khóa tính bằng bit.

ZZ0000ZZ cho biết kích thước tối đa tính bằng byte của một khối dữ liệu cần được
     đã ký, một blob chữ ký, một blob được mã hóa và một blob được
     đã được giải mã.

ZZ0000ZZ phải được đặt thành 0. Giá trị này được thiết kế để sử dụng trong tương lai
     cần có một hoặc nhiều cụm mật khẩu để mở khóa.

Nếu thành công thì trả về 0.  Nếu khóa không phải là khóa bất đối xứng,
     EOPNOTSUPP được trả lại.


* Mã hóa, giải mã, ký hoặc xác minh blob bằng khóa bất đối xứng::

keyctl dài (KEYCTL_PKEY_ENCRYPT,
		    const struct keyctl_pkey_params *params,
		    const char *thông tin,
		    const void *in,
		    vô hiệu * ra);

keyctl dài (KEYCTL_PKEY_DECRYPT,
		    const struct keyctl_pkey_params *params,
		    const char *thông tin,
		    const void *in,
		    vô hiệu * ra);

keyctl dài (KEYCTL_PKEY_SIGN,
		    const struct keyctl_pkey_params *params,
		    const char *thông tin,
		    const void *in,
		    vô hiệu * ra);

keyctl dài (KEYCTL_PKEY_VERIFY,
		    const struct keyctl_pkey_params *params,
		    const char *thông tin,
		    const void *in,
		    const void *in2);

Sử dụng khóa bất đối xứng để thực hiện thao tác mã hóa khóa công khai
     đốm dữ liệu.  Để mã hóa và xác minh, khóa bất đối xứng có thể
     chỉ cần có sẵn các phần công khai nhưng để giải mã và ký
     những phần riêng tư cũng được yêu cầu.

Khối tham số được trỏ tới bởi params chứa một số nguyên
     giá trị::

__s32 key_id;
	__u32 in_len;
	__u32 out_len;
	__u32 in2_len;

ZZ0000ZZ là ID của khóa bất đối xứng sẽ được sử dụng.  ZZ0001ZZ và
     ZZ0002ZZ cho biết lượng dữ liệu trong bộ đệm trong và trong2 và
     ZZ0003ZZ cho biết kích thước của bộ đệm đầu ra phù hợp với
     các thao tác trên.

Đối với một thao tác nhất định, bộ đệm vào và ra được sử dụng như sau::

ID hoạt động in,in_len out,out_len in2,in2_len
	======================================= ================ =================
	KEYCTL_PKEY_ENCRYPT Dữ liệu thô Dữ liệu được mã hóa -
	KEYCTL_PKEY_DECRYPT Dữ liệu được mã hóa Dữ liệu thô -
	KEYCTL_PKEY_SIGN Dữ liệu thô Chữ ký -
	KEYCTL_PKEY_VERIFY Dữ liệu thô - Chữ ký

ZZ0000ZZ là một chuỗi các cặp khóa=giá trị cung cấp thông tin bổ sung
     thông tin.  Chúng bao gồm:

ZZ0000ZZ Mã hóa blob được mã hóa/chữ ký.  Cái này
			có thể là "pkcs1" cho RSASSA-PKCS1-v1.5 hoặc
			RSAES-PKCS1-v1.5; "pss" cho "RSASSA-PSS"; "oaep" cho
			"RSAES-OAEP".  Nếu bị bỏ qua hoặc là "thô", đầu ra thô
			của chức năng mã hóa được chỉ định.

ZZ0000ZZ Nếu bộ đệm dữ liệu chứa đầu ra của hàm băm
			chức năng và mã hóa bao gồm một số dấu hiệu của
			hàm băm nào đã được sử dụng, hàm băm có thể là
			được chỉ định với điều này, ví dụ. "băm = sha256".

Không gian ZZ0000ZZ trong khối tham số phải được đặt thành 0. Đây là
     nhằm mục đích, trong số những thứ khác, để cho phép chuyển các cụm mật khẩu
     cần thiết để mở khóa.

Nếu thành công thì mã hóa, giải mã và ký tất cả trả về lượng dữ liệu
     được ghi vào bộ đệm đầu ra.  Xác minh trả về 0 khi thành công.


* Xem phím hoặc móc khóa để biết các thay đổi::

keyctl dài (KEYCTL_WATCH_KEY, khóa key_serial_t, int queue_fd,
		    const struct watch_notification_filter *filter);

Thao tác này sẽ đặt hoặc xóa đồng hồ đối với các thay đổi trên phím được chỉ định hoặc
     móc khóa.

"key" là ID của key cần theo dõi.

"queue_fd" là bộ mô tả tập tin đề cập đến một đường ống mở
     quản lý bộ đệm nơi thông báo sẽ được gửi vào.

"bộ lọc" là NULL để xóa đồng hồ hoặc thông số bộ lọc để
     cho biết những sự kiện nào được yêu cầu từ khóa.

Xem Tài liệu/core-api/watch_queue.rst để biết thêm thông tin.

Lưu ý rằng chỉ có thể thay thế một đồng hồ cho bất kỳ phím { cụ thể nào,
     queue_fd } kết hợp.

Bản ghi thông báo trông giống như::

cấu trúc key_notification {
		struct watch_notification đồng hồ;
		__u32 key_id;
		__u32 phụ trợ;
	};

Trong phần này, watch::type sẽ là "WATCH_TYPE_KEY_NOTIFY" và subtype sẽ là
     một trong::

NOTIFY_KEY_INSTANTIATED
	NOTIFY_KEY_UPDATED
	NOTIFY_KEY_LINKED
	NOTIFY_KEY_UNLINKED
	NOTIFY_KEY_CLEARED
	NOTIFY_KEY_REVOKED
	NOTIFY_KEY_INVALIDATED
	NOTIFY_KEY_SETATTR

Trong trường hợp những thông tin này cho biết khóa đang được khởi tạo/từ chối, cập nhật, một liên kết
     được tạo thành một chiếc móc khóa, một liên kết được gỡ bỏ khỏi một chiếc móc khóa, một chiếc móc khóa
     bị xóa, khóa bị thu hồi, khóa bị vô hiệu hoặc khóa
     có một trong các thuộc tính của nó bị thay đổi (người dùng, nhóm, perm, thời gian chờ,
     hạn chế).

Nếu khóa đã xem bị xóa, thông báo watch_notification cơ bản sẽ được phát hành
     với "loại" được đặt thành WATCH_TYPE_META và "loại phụ" được đặt thành
     watch_meta_removal_notification.  ID điểm xem sẽ được đặt trong
     trường "thông tin".

Điều này cần phải được cấu hình bằng cách kích hoạt:

"Cung cấp thông báo thay đổi khóa/ổ khóa" (KEY_NOTIFICATIONS)


Dịch vụ hạt nhân
===============

Các dịch vụ kernel để quản lý khóa khá đơn giản để xử lý. Họ có thể
được chia thành hai khu vực: khóa và loại khóa.

Xử lý các phím khá đơn giản. Thứ nhất, dịch vụ kernel
đăng ký loại của nó, sau đó nó tìm kiếm khóa thuộc loại đó. Nó nên giữ lại
chìa khóa miễn là nó cần nó, và sau đó nó sẽ giải phóng nó. Đối với một
tập tin hệ thống tập tin hoặc tập tin thiết bị, việc tìm kiếm có thể được thực hiện trong quá trình mở
gọi và phím sẽ được nhả khi đóng. Cách xử lý các phím xung đột do
hai người dùng khác nhau mở cùng một tệp được để lại cho tác giả hệ thống tệp
giải quyết.

Để truy cập trình quản lý khóa, tiêu đề sau phải là #included::

<linux/key.h>

Các loại khóa cụ thể phải có tệp tiêu đề bên dưới include/keys/.
được sử dụng để truy cập loại đó.  Ví dụ: đối với các khóa thuộc loại "người dùng", đó sẽ là::

<keys/user-type.h>

Lưu ý rằng có hai loại con trỏ khác nhau tới các khóa có thể
gặp phải:

*khóa cấu trúc*

Điều này chỉ đơn giản là trỏ đến cấu trúc chính của chính nó. Các cấu trúc chính sẽ ở
     liên kết ít nhất bốn byte.

* key_ref_t

Điều này tương đương với ZZ0000ZZ, nhưng bit có trọng số thấp nhất được đặt
     nếu người gọi "sở hữu" chìa khóa. “Sở hữu” có nghĩa là
     quá trình gọi có một liên kết có thể tìm kiếm được tới khóa từ một trong các
     dây móc khóa. Có ba chức năng để giải quyết những vấn đề này::

key_ref_t make_key_ref(const struct key *key, sở hữu bool);

khóa cấu trúc *key_ref_to_ptr(const key_ref_t key_ref);

bool is_key_possessed(const key_ref_t key_ref);

Hàm đầu tiên xây dựng một tham chiếu khóa từ một con trỏ khóa và
     thông tin sở hữu (phải đúng hoặc sai).

Hàm thứ hai lấy con trỏ khóa từ một tham chiếu và
     thứ ba lấy lại cờ sở hữu.

Khi truy cập nội dung tải trọng của khóa, phải thực hiện một số biện pháp phòng ngừa nhất định để
ngăn chặn các cuộc đua truy cập và sửa đổi. Xem phần “Lưu ý khi truy cập
nội dung tải trọng" để biết thêm thông tin.

* Để tìm kiếm chìa khóa, hãy gọi::

khóa cấu trúc *request_key(const struct key_type *type,
				const char * mô tả,
				const char *callout_info);

Điều này được sử dụng để yêu cầu một khóa hoặc chuỗi khóa có mô tả phù hợp
    mô tả được chỉ định theo match_preparse() của loại khóa
    phương pháp. Điều này cho phép xảy ra sự kết hợp gần đúng. Nếu callout_string là
    không phải NULL, thì /sbin/request-key sẽ được gọi để cố gắng lấy
    chìa khóa từ không gian người dùng. Trong trường hợp đó, callout_string sẽ được chuyển thành
    đối số cho chương trình.

Nếu chức năng không thành công sẽ có lỗi ENOKEY, EKEYEXPIRED hoặc EKEYREVOKED
    đã quay trở lại.

Nếu thành công, khóa sẽ được gắn vào chuỗi khóa mặc định cho
    ngầm nhận được các khóa khóa yêu cầu, do KEYCTL_SET_REQKEY_KEYRING đặt.

Xem thêm Tài liệu/bảo mật/khóa/request-key.rst.


* Để tìm kiếm khóa trong một miền cụ thể, hãy gọi::

khóa cấu trúc *request_key_tag(const struct key_type *type,
				    const char * mô tả,
				    cấu trúc key_tag *domain_tag,
				    const char *callout_info);

Điều này giống hệt với request_key(), ngoại trừ thẻ tên miền có thể
    chỉ định rằng khiến thuật toán tìm kiếm chỉ khớp với các khóa khớp với điều đó
    thẻ.  Domain_tag có thể là NULL, chỉ định một miền toàn cầu
    tách biệt với bất kỳ tên miền được chỉ định nào.


* Để tìm kiếm key, truyền dữ liệu phụ trợ cho người gọi lên, hãy gọi::

khóa cấu trúc *request_key_with_auxdata(const struct key_type *type,
					     const char * mô tả,
					     cấu trúc key_tag *domain_tag,
					     const void *callout_info,
					     size_t callout_len,
					     vô hiệu *aux);

Điều này giống hệt với request_key_tag(), ngoại trừ dữ liệu phụ trợ là
    được chuyển tới op key_type->request_key() nếu nó tồn tại và
    callout_info là một đốm màu có độ dài callout_len, nếu được cung cấp (độ dài có thể là
    0).


* Để tìm kiếm key theo điều kiện RCU, hãy gọi::

khóa cấu trúc *request_key_rcu(const struct key_type *type,
				    const char * mô tả,
				    cấu trúc key_tag *domain_tag);

tương tự như request_key_tag() ngoại trừ việc nó không kiểm tra
    các khóa đang được xây dựng và nó sẽ không gọi tới không gian người dùng để
    tạo một khóa nếu nó không thể tìm thấy kết quả khớp.


* Khi không còn cần thiết nữa, khóa sẽ được giải phóng bằng cách sử dụng ::

void key_put(khóa struct *key);

Hoặc::

void key_ref_put(key_ref_t key_ref);

Chúng có thể được gọi từ bối cảnh ngắt. Nếu CONFIG_KEYS không được đặt thì
    đối số sẽ không được phân tích cú pháp.


* Có thể tạo các tham chiếu bổ sung cho một khóa bằng cách gọi một trong các cách sau
    chức năng::

khóa cấu trúc *__key_get(struct key *key);
	khóa cấu trúc *key_get(struct key *key);

Các khóa để tham chiếu sẽ cần được loại bỏ bằng cách gọi key_put() khi
    họ đã xong việc rồi.  Con trỏ khóa được truyền vào sẽ được trả về.

Trong trường hợp key_get(), nếu con trỏ là NULL hoặc CONFIG_KEYS không được đặt
    thì khóa sẽ không bị hủy đăng ký và sẽ không có sự gia tăng nào diễn ra.


* Bạn có thể lấy số sê-ri của chìa khóa bằng cách gọi::

key_serial_t key_serial(khóa cấu trúc *key);

Nếu khóa là NULL hoặc nếu CONFIG_KEYS không được đặt thì 0 sẽ được trả về (trong
    trường hợp sau mà không phân tích đối số).


* Nếu tìm thấy một móc khóa trong quá trình tìm kiếm, bạn có thể tìm kiếm thêm bằng cách::

key_ref_t keyring_search(key_ref_t keyring_ref,
				 const struct key_type *loại,
				 const char * mô tả,
				 tái diễn bool)

Điều này chỉ tìm kiếm chuỗi khóa được chỉ định (recurse == false) hoặc cây khóa
    (recurse == true) được chỉ định cho khóa khớp. Lỗi ENOKEY được trả về
    khi thất bại (sử dụng IS_ERR/PTR_ERR để xác định). Nếu thành công sẽ trả về
    chìa khóa sẽ cần phải được phát hành.

Thuộc tính sở hữu từ tham chiếu khóa được sử dụng để kiểm soát
    truy cập thông qua mặt nạ quyền và được truyền tới khóa được trả về
    con trỏ tham chiếu nếu thành công.


* Một móc khóa có thể được tạo bởi::

khóa cấu trúc *keyring_alloc(const char *description, uid_t uid, gid_t gid,
				  const struct cred *cred,
				  key_perm_t perm,
				  cấu trúc key_restriction *restrict_link,
				  cờ dài không dấu,
				  khóa cấu trúc * đích);

Điều này tạo ra một chuỗi khóa với các thuộc tính đã cho và trả về nó.  Nếu đích
    không phải là NULL, chuỗi khóa mới sẽ được liên kết với chuỗi khóa mà nó kết nối
    điểm.  Không có kiểm tra quyền nào được thực hiện khi khóa đích.

Lỗi EDQUOT có thể được trả về nếu việc khóa sẽ làm quá tải hạn ngạch (vượt qua
    KEY_ALLOC_NOT_IN_QUOTA trong cờ nếu không tính đến khóa
    hướng tới hạn ngạch của người dùng).  Lỗi ENOMEM cũng có thể được trả về.

Nếu limit_link không phải là NULL, nó sẽ trỏ đến cấu trúc chứa
    hàm sẽ được gọi mỗi lần cố gắng liên kết một
    chìa khóa vào ổ khóa mới.  Cấu trúc cũng có thể chứa một con trỏ khóa
    và một loại khóa liên quan.  Hàm này được gọi để kiểm tra xem một khóa có
    có thể được thêm vào móc khóa hay không.  Loại khóa được sử dụng bởi rác
    bộ thu thập để dọn sạch các con trỏ hàm hoặc dữ liệu trong cấu trúc này nếu
    loại khóa đã cho chưa được đăng ký.  Người gọi key_create_or_update() trong
    kernel có thể vượt qua KEY_ALLOC_BYPASS_RESTRICTION để chặn kiểm tra.
    Một ví dụ về việc sử dụng tính năng này là để quản lý các vòng khóa mật mã được
    thiết lập khi kernel khởi động nơi không gian người dùng cũng được phép thêm khóa
    - miễn là chúng có thể được xác minh bằng khóa mà hạt nhân đã có.

Khi được gọi, hàm hạn chế sẽ được chuyển qua khóa
    được thêm vào, loại khóa, tải trọng của khóa được thêm vào và dữ liệu sẽ được thêm vào.
    được sử dụng trong kiểm tra hạn chế.  Lưu ý rằng khi một khóa mới được tạo,
    điều này được gọi giữa việc chuẩn bị tải trọng và tạo khóa thực tế.  các
    hàm sẽ trả về 0 để cho phép liên kết hoặc lỗi từ chối nó.

Một hàm tiện lợi, limit_link_reject, tồn tại để luôn trả về
    -EPERM trong trường hợp này.


* Để kiểm tra tính hợp lệ của khóa, hàm này có thể được gọi::

int valid_key(khóa cấu trúc *key);

Việc này sẽ kiểm tra xem khóa được đề cập chưa hết hạn hoặc chưa được
    bị thu hồi. Nếu khóa không hợp lệ, lỗi EKEYEXPIRED hoặc EKEYREVOKED sẽ
    được trả lại. Nếu khóa là NULL hoặc nếu CONFIG_KEYS không được đặt thì 0 sẽ là
    được trả về (trong trường hợp sau mà không phân tích đối số).


* Để đăng ký một loại khóa, nên gọi hàm sau::

int register_key_type(struct key_type *type);

Điều này sẽ trả về lỗi EEXIST nếu đã có một loại cùng tên
    hiện tại.


* Để hủy đăng ký loại khóa, hãy gọi::

void unregister_key_type(struct key_type *type);


Trong một số trường hợp, có thể nên xử lý một bó chìa khóa.
Cơ sở này cung cấp quyền truy cập vào loại khóa để quản lý gói đó ::

cấu trúc key_type key_type_keyring;

Điều này có thể được sử dụng với một hàm như request_key() để tìm một địa chỉ cụ thể
móc khóa trong chuỗi khóa của một quá trình.  Do đó, một móc khóa được tìm thấy có thể được tìm kiếm
với keyring_search().  Lưu ý rằng không thể sử dụng request_key() để
tìm kiếm một chuỗi khóa cụ thể, vì vậy việc sử dụng chuỗi khóa theo cách này sẽ có ích hạn chế.


Lưu ý khi truy cập nội dung tải trọng
===================================

Tải trọng đơn giản nhất chỉ là dữ liệu được lưu trữ trực tiếp trong key->payload.  Trong này
trong trường hợp này, không cần phải sử dụng RCU hoặc khóa khi truy cập vào tải trọng.

Nội dung tải trọng phức tạp hơn phải được phân bổ và con trỏ tới chúng được đặt trong
mảng key->payload.data[].  Phải chọn một trong các cách sau để
truy cập dữ liệu:

1) Loại khóa không thể sửa đổi.

Nếu loại khóa không có phương thức sửa đổi thì tải trọng của khóa có thể
     được truy cập mà không cần bất kỳ hình thức khóa nào, miễn là nó được biết là
     đã được khởi tạo (không thể "tìm thấy các khóa chưa được khởi tạo").

2) Semaphore của khóa.

Semaphore có thể được sử dụng để quản lý quyền truy cập vào tải trọng và kiểm soát
     con trỏ tải trọng. Nó phải được khóa ghi để sửa đổi và sẽ
     phải được khóa đọc để truy cập chung. Nhược điểm của việc làm này
     là người truy cập có thể được yêu cầu ngủ.

3) RCU.

RCU phải được sử dụng khi semaphore chưa được giữ; nếu ngữ nghĩa
     được giữ thì nội dung không thể thay đổi theo ý bạn một cách bất ngờ vì
     semaphore vẫn phải được sử dụng để tuần tự hóa các sửa đổi đối với khóa. các
     mã quản lý khóa đảm nhiệm việc này cho loại khóa.

Tuy nhiên, điều này có nghĩa là sử dụng::

rcu_read_lock() ... rcu_dereference() ... rcu_read_unlock()

để đọc con trỏ và::

rcu_dereference() ... rcu_sign_pointer() ... call_rcu()

để đặt con trỏ và loại bỏ nội dung cũ sau một thời gian gia hạn.
     Lưu ý rằng chỉ loại khóa mới được sửa đổi tải trọng của khóa.

Hơn nữa, tải trọng được điều khiển RCU phải chứa struct rcu_head cho
     sử dụng call_rcu() và nếu tải trọng có kích thước thay đổi thì độ dài của
     tải trọng. key->datalen không thể dựa vào để nhất quán với
     tải trọng chỉ bị hủy đăng ký nếu semaphore của khóa không được giữ.

Lưu ý rằng key->payload.data[0] có bóng được đánh dấu cho __rcu
     cách sử dụng.  Đây được gọi là khóa->payload.rcu_data0.  Các phụ kiện sau
     gói các lệnh gọi RCU tới phần tử này:

a) Đặt hoặc thay đổi con trỏ tải trọng đầu tiên::

rcu_sign_keypointer(khóa cấu trúc *key, void *data);

b) Đọc con trỏ tải trọng đầu tiên có khóa semaphore được giữ::

[const] void *dereference_key_locked([const] struct key *key);

Lưu ý rằng giá trị trả về sẽ kế thừa hằng số của nó từ khóa
	 tham số.  Phân tích tĩnh sẽ báo lỗi nếu nó khóa
	 không được tổ chức.

c) Đọc con trỏ tải trọng đầu tiên với khóa đọc RCU được giữ::

const void *dereference_key_rcu(const struct key *key);


Xác định loại khóa
===================

Một dịch vụ kernel có thể muốn xác định loại khóa riêng của nó. Ví dụ: AFS
hệ thống tập tin có thể muốn xác định loại khóa vé Kerberos 5. Để làm điều này, nó
tác giả điền vào cấu trúc key_type và đăng ký nó với hệ thống.

Các tệp nguồn triển khai các loại khóa phải bao gồm tệp tiêu đề sau::

<linux/key-type.h>

Cấu trúc có một số trường, một số trường là bắt buộc:

* ZZ0000ZZ

Tên của loại khóa. Điều này được sử dụng để dịch tên loại khóa
     được cung cấp bởi không gian người dùng thành một con trỏ tới cấu trúc.


* ZZ0000ZZ

Đây là tùy chọn - nó cung cấp độ dài dữ liệu tải trọng mặc định dưới dạng
     đã đóng góp vào hạn ngạch. Nếu tải trọng của loại khóa luôn hoặc gần như
     luôn có cùng kích thước thì đây là cách hiệu quả hơn để thực hiện mọi việc.

Độ dài dữ liệu (và hạn ngạch) trên một khóa cụ thể luôn có thể thay đổi được
     trong quá trình khởi tạo hoặc cập nhật bằng cách gọi::

int key_payload_reserve(struct key *key, size_t datalen);

Với độ dài dữ liệu được sửa đổi. Lỗi EDQUOT sẽ được trả về nếu không có
     khả thi.


* ZZ0000ZZ

Phương pháp tùy chọn này được gọi để kiểm tra mô tả chính.  Nếu loại khóa
     không chấp thuận mô tả khóa, nó có thể trả về lỗi, nếu không
     nó sẽ trả về 0.


* ZZ0000ZZ

Phương thức tùy chọn này cho phép loại khóa cố gắng phân tích tải trọng
     trước khi một khóa được tạo (thêm khóa) hoặc semaphore khóa được lấy (cập nhật hoặc
     khóa khởi tạo).  Cấu trúc được chỉ ra bởi prep trông giống như::

cấu trúc key_preparsed_payload {
		char *mô tả;
		tải trọng key_payload của liên minh;
		const void *dữ liệu;
		dữ liệu size_t;
		size_t hạn ngạch;
		thời gian_t hết hạn;
	};

Trước khi gọi phương thức, người gọi sẽ điền dữ liệu và datalen bằng
     các tham số blob tải trọng; quolen sẽ được điền theo mặc định
     kích thước hạn ngạch từ loại khóa; hết hạn sẽ được đặt thành TIME_T_MAX và
     phần còn lại sẽ được xóa.

Nếu một mô tả có thể được đề xuất từ nội dung tải trọng, thì đó phải là
     được đính kèm dưới dạng chuỗi vào trường mô tả.  Điều này sẽ được sử dụng cho
     mô tả khóa nếu người gọi add_key() vượt qua NULL hoặc "".

Phương thức này có thể đính kèm bất cứ thứ gì nó thích vào tải trọng.  Điều này chỉ được thông qua
     cùng với các hoạt động instantiate() hoặc update().  Nếu được đặt, hết hạn
     thời gian sẽ được áp dụng cho khóa nếu nó được khởi tạo từ dữ liệu này.

Phương thức sẽ trả về 0 nếu thành công hoặc có mã lỗi âm
     mặt khác.


* ZZ0000ZZ

Phương thức này chỉ được yêu cầu nếu phương thức preparse() được cung cấp,
     nếu không thì nó không được sử dụng.  Nó dọn sạch mọi thứ gắn liền với mô tả
     và các trường tải trọng của cấu trúc key_preparsed_payload được điền bởi
     phương thức chuẩn bị ().  Nó sẽ luôn được gọi sau khi trả về preparse()
     thành công, ngay cả khi instantiate() hoặc update() thành công.


* ZZ0000ZZ

Phương thức này được gọi để gắn tải trọng vào khóa trong quá trình xây dựng.
     Tải trọng được đính kèm không cần bất kỳ mối liên hệ nào với dữ liệu được truyền tới đây
     chức năng.

Các trường prep->data và prep->datalen sẽ xác định tải trọng ban đầu
     đốm màu.  Nếu preparse() được cung cấp thì các trường khác cũng có thể được điền vào.

Nếu lượng dữ liệu gắn vào khóa khác với kích thước trong
     keytype->def_datalen, sau đó nên gọi key_payload_reserve().

Phương pháp này không cần phải khóa chìa khóa để gắn tải trọng.
     Việc KEY_FLAG_INSTANTIATED không được đặt trong key->flags sẽ ngăn cản
     bất cứ điều gì khác từ việc có được quyền truy cập vào khóa.

Ngủ theo phương pháp này là an toàn.

generic_key_instantiate() được cung cấp để sao chép dữ liệu từ
     prep->payload.data[] thành key->payload.data[], với chức năng gán RCU-safe được bật
     phần tử đầu tiên.  Sau đó nó sẽ xóa prep->payload.data[] để
     Phương thức free_preparse không giải phóng dữ liệu.


* ZZ0000ZZ

Nếu loại khóa này có thể được cập nhật thì phương pháp này sẽ được cung cấp.
     Nó được gọi để cập nhật tải trọng của khóa từ khối dữ liệu được cung cấp.

Các trường prep->data và prep->datalen sẽ xác định tải trọng ban đầu
     đốm màu.  Nếu preparse() được cung cấp thì các trường khác cũng có thể được điền vào.

key_payload_reserve() nên được gọi nếu độ dài dữ liệu có thể thay đổi
     trước khi bất kỳ thay đổi nào thực sự được thực hiện. Lưu ý rằng nếu điều này thành công, loại
     cam kết thay đổi khóa vì nó đã bị thay đổi rồi, vì vậy tất cả
     Việc phân bổ bộ nhớ phải được thực hiện trước tiên.

Khóa sẽ bị khóa ghi semaphore trước khi phương thức này được gọi,
     nhưng điều này chỉ làm nản lòng những nhà văn khác; mọi thay đổi đối với tải trọng của khóa phải
     được thực hiện trong điều kiện RCU và phải sử dụng call_rcu() để loại bỏ
     tải trọng cũ.

key_payload_reserve() nên được gọi trước khi thực hiện thay đổi, nhưng
     sau khi tất cả các phân bổ và các lệnh gọi hàm có khả năng bị lỗi khác đã được thực hiện
     thực hiện.

Ngủ theo phương pháp này là an toàn.


* ZZ0000ZZ

Phương pháp này là tùy chọn.  Nó được gọi khi một tìm kiếm quan trọng sắp được thực hiện
     được thực hiện.  Nó được đưa ra cấu trúc sau::

cấu trúc key_match_data {
		bool (*cmp)(const struct key *key,
			    const struct key_match_data *match_data);
		const void *raw_data;
		void *chuẩn bị;
		tra cứu_type không dấu;
	};

Khi nhập, raw_data sẽ trỏ đến các tiêu chí được sử dụng để so khớp
     một chìa khóa của người gọi và không nên sửa đổi.  ZZ0000ZZ sẽ trỏ
     với chức năng so khớp mặc định (thực hiện khớp mô tả chính xác
     dựa vào raw_data) và lookup_type sẽ được đặt để biểu thị tra cứu trực tiếp.

Các giá trị lookup_type sau đây có sẵn:

* KEYRING_SEARCH_LOOKUP_DIRECT - Tra cứu trực tiếp băm loại và
      	  mô tả để thu hẹp tìm kiếm vào một số lượng nhỏ các khóa.

* KEYRING_SEARCH_LOOKUP_ITERATE - Tra cứu lặp đi lặp lại tất cả
      	  các phím trong chuỗi khóa cho đến khi khớp một phím.  Điều này phải được sử dụng cho bất kỳ
      	  tìm kiếm không thực hiện đối sánh trực tiếp đơn giản trên mô tả chính.

Phương thức này có thể đặt cmp để trỏ đến một hàm mà nó chọn để thực hiện một số
     dạng đối sánh khác, có thể đặt lookup_type thành KEYRING_SEARCH_LOOKUP_ITERATE
     và có thể đính kèm thứ gì đó vào con trỏ đã chuẩn bị sẵn để ZZ0000ZZ sử dụng.
     ZZ0001ZZ sẽ trả về true nếu khóa khớp và ngược lại là sai.

Nếu tính năng chuẩn bị sẵn được thiết lập, có thể cần phải sử dụng phương thức match_free() để
     dọn dẹp nó đi.

Phương thức sẽ trả về 0 nếu thành công hoặc có mã lỗi âm
     mặt khác.

Được phép ngủ theo phương pháp này, nhưng ZZ0000ZZ có thể không ngủ như
     ổ khóa sẽ được giữ trên nó.

Nếu match_preparse() không được cung cấp, các khóa thuộc loại này sẽ được khớp
     chính xác theo mô tả của họ.


* ZZ0000ZZ

Phương pháp này là tùy chọn.  Nếu được thì nó gọi dọn dẹp
     match_data->được chuẩn bị sau khi gọi thành công tới match_preparse().


* ZZ0000ZZ

Phương pháp này là tùy chọn.  Nó được gọi để loại bỏ một phần payload
     dữ liệu khi một khóa bị thu hồi.  Người gọi sẽ có semaphore chính
     bị khóa ghi.

Ngủ theo phương pháp này là an toàn, tuy nhiên cần cẩn thận để tránh
     một sự bế tắc đối với semaphore chính.


* ZZ0000ZZ

Phương pháp này là tùy chọn. Nó được gọi để loại bỏ dữ liệu tải trọng trên một khóa
     khi nó đang bị phá hủy.

Phương pháp này không cần khóa chìa khóa để truy cập tải trọng; nó có thể
     coi như khóa đó không thể truy cập được vào lúc này. Lưu ý rằng chìa khóa
     loại có thể đã được thay đổi trước khi hàm này được gọi.

Ngủ theo phương pháp này không an toàn; người gọi có thể giữ spinlocks.


* ZZ0000ZZ

Phương pháp này là tùy chọn. Nó được gọi trong khi đọc /proc/keys tới
     tóm tắt mô tả và tải trọng của khóa ở dạng văn bản.

Phương thức này sẽ được gọi khi khóa đọc RCU được giữ. rcu_dereference()
     nên được sử dụng để đọc con trỏ tải trọng nếu tải trọng đó được
     đã truy cập. key->datalen không thể tin cậy được để luôn nhất quán với
     nội dung của tải trọng.

Mô tả sẽ không thay đổi, mặc dù trạng thái của khóa có thể thay đổi.

Ngủ theo phương pháp này không an toàn; khóa đọc RCU được giữ bởi
     người gọi.


* ZZ0000ZZ

Phương pháp này là tùy chọn. Nó được gọi bởi KEYCTL_READ để dịch
     tải trọng của khóa thành một khối dữ liệu để không gian người dùng xử lý.
     Lý tưởng nhất là blob phải có cùng định dạng với định dạng được chuyển vào
     khởi tạo và cập nhật các phương thức.

Nếu thành công, kích thước blob có thể được tạo ra sẽ được trả về
     thay vì kích thước được sao chép.

Phương thức này sẽ được gọi với semaphore của khóa bị khóa. Điều này sẽ
     ngăn chặn việc thay đổi tải trọng của khóa. Không cần thiết phải sử dụng khóa RCU
     khi truy cập tải trọng của khóa. Ngủ theo phương pháp này là an toàn, chẳng hạn như
     điều có thể xảy ra khi bộ đệm vùng người dùng được truy cập.


* ZZ0000ZZ

Phương pháp này là tùy chọn.  Nếu được cung cấp, request_key() và bạn bè sẽ
     gọi hàm này thay vì gọi tới /sbin/request-key để hoạt động
     trên một khóa thuộc loại này.

Tham số aux được truyền tới request_key_async_with_auxdata() và
     tương tự hoặc là NULL.  Hồ sơ xây dựng cũng đã được thông qua
     phím được vận hành và loại hoạt động (hiện tại chỉ
     “tạo”).

Phương thức này được phép quay lại trước khi lệnh gọi lên hoàn tất, nhưng
     Hàm sau phải được gọi trong mọi trường hợp để hoàn thành
     quá trình khởi tạo, cho dù nó có thành công hay không, có hay không
     một lỗi::

void Complete_request_key(struct key_construction *cons, lỗi int);

Tham số lỗi phải là 0 nếu thành công, -ve nếu có lỗi.  các
     hồ sơ xây dựng bị phá hủy bởi hành động này và khóa ủy quyền
     sẽ bị thu hồi.  Nếu có lỗi được chỉ ra, khóa đang được xây dựng
     sẽ được khởi tạo một cách tiêu cực nếu nó chưa được khởi tạo.

Nếu phương thức này trả về lỗi, lỗi đó sẽ được trả về
     người gọi request_key*().  Complete_request_key() phải được gọi trước
     đang quay trở lại.

Khóa đang được xây dựng và khóa ủy quyền có thể được tìm thấy trong
     Cấu trúc key_construction được chỉ ra bởi khuyết điểm:

* ZZ0000ZZ

Chìa khóa đang được xây dựng.

* ZZ0000ZZ

Chìa khóa ủy quyền.


* ZZ0000ZZ

Phương pháp tùy chọn này được sử dụng để kích hoạt cấu hình không gian người dùng của khóa
     hạn chế. Chuỗi tham số hạn chế (không bao gồm loại khóa
     name) được truyền vào và phương thức này trả về một con trỏ tới key_restriction
     cấu trúc chứa các chức năng và dữ liệu liên quan để đánh giá từng
     đã thử thao tác liên kết khóa. Nếu không khớp, -EINVAL sẽ được trả về.


* ZZ0000ZZ và ZZ0001ZZ::

int (*asym_eds_op)(struct kernel_pkey_params *params,
			  const void *in, void *out);
       int (*asym_verify_signature)(struct kernel_pkey_params *params,
				    const void *in, const void *in2);

Những phương pháp này là tùy chọn.  Nếu được cung cấp cái đầu tiên cho phép một khóa được
     được sử dụng để mã hóa, giải mã hoặc ký một khối dữ liệu và cái thứ hai cho phép
     khóa để xác minh chữ ký.

Trong mọi trường hợp, thông tin sau được cung cấp trong khối params::

cấu trúc kernel_pkey_params {
		khóa cấu trúc *phím;
		mã hóa const char *;
		const char *hash_algo;
		char *thông tin;
		__u32 in_len;
		công đoàn {
			__u32 out_len;
			__u32 in2_len;
		};
		enum kernel_pkey_Operation op: 8;
	};

Điều này bao gồm chìa khóa được sử dụng; một chuỗi biểu thị mã hóa sẽ sử dụng
     (ví dụ: "pkcs1" có thể được sử dụng với phím RSA để biểu thị
     Mã hóa RSASSA-PKCS1-v1.5 hoặc RSAES-PKCS1-v1.5 hoặc "thô" nếu không mã hóa);
     tên của thuật toán băm được sử dụng để tạo dữ liệu cho chữ ký
     (nếu thích hợp); kích thước của đầu vào và đầu ra (hoặc đầu vào thứ hai)
     bộ đệm; và ID của hoạt động sẽ được thực hiện.

Đối với một ID hoạt động nhất định, bộ đệm đầu vào và đầu ra được sử dụng làm
     sau::

ID hoạt động in,in_len out,out_len in2,in2_len
	======================================= ================ =================
	kernel_pkey_encrypt Dữ liệu thô Dữ liệu được mã hóa -
	kernel_pkey_decrypt Dữ liệu được mã hóa Dữ liệu thô -
	kernel_pkey_sign Dữ liệu thô Chữ ký -
	kernel_pkey_verify Dữ liệu thô - Chữ ký

asym_eds_op() xử lý việc mã hóa, giải mã và tạo chữ ký như
     được chỉ định bởi params->op.  Lưu ý rằng params->op cũng được đặt cho
     asym_verify_signature().

Mã hóa và tạo chữ ký đều lấy dữ liệu thô trong bộ đệm đầu vào
     và trả về kết quả được mã hóa trong bộ đệm đầu ra.  Phần đệm có thể có
     được thêm vào nếu mã hóa được đặt.  Trong trường hợp tạo chữ ký,
     tùy thuộc vào mã hóa, phần đệm được tạo có thể cần chỉ ra
     thuật toán tóm tắt - tên của nó phải được cung cấp trong hash_algo.

Quá trình giải mã lấy dữ liệu được mã hóa vào bộ đệm đầu vào và trả về dữ liệu thô
     dữ liệu trong bộ đệm đầu ra.  Phần đệm sẽ được kiểm tra và loại bỏ nếu
     một mã hóa đã được thiết lập.

Việc xác minh lấy dữ liệu thô trong bộ đệm đầu vào và chữ ký trong
     bộ đệm đầu vào thứ hai và kiểm tra xem cái này có khớp với cái kia không.  Phần đệm
     sẽ được xác nhận.  Tùy thuộc vào mã hóa, thuật toán tóm tắt được sử dụng
     để tạo dữ liệu thô có thể cần phải được chỉ định trong hash_algo.

Nếu thành công, asym_eds_op() sẽ trả về số byte đã ghi
     vào bộ đệm đầu ra.  asym_verify_signature() sẽ trả về 0.

Nhiều lỗi có thể được trả về, bao gồm cả lỗi EOPNOTSUPP nếu thao tác
     không được hỗ trợ; EKEYREJECTED nếu xác minh không thành công; ENOPKG nếu
     mật mã được yêu cầu không có sẵn.


*ZZ0000ZZ::

int (*asym_query)(const struct kernel_pkey_params *params,
			 struct kernel_pkey_query *thông tin);

Phương pháp này là tùy chọn.  Nếu được cung cấp, nó cho phép thông tin về
     khóa công khai hoặc khóa bất đối xứng được giữ trong khóa cần xác định.

Khối tham số giống như asym_eds_op() và co. nhưng in_len và out_len
     không được sử dụng.  Các trường mã hóa và hash_algo nên được sử dụng để giảm
     kích thước bộ đệm/dữ liệu được trả về nếu thích hợp.

Nếu thành công, các thông tin sau sẽ được điền vào::

cấu trúc kernel_pkey_query {
		__u32 được hỗ trợ_ops;
		__u32 key_size;
		__u16 max_data_size;
		__u16 max_sig_size;
		__u16 max_enc_size;
		__u16 max_dec_size;
	};

Trường được hỗ trợ_ops sẽ chứa mặt nạ bit cho biết hoạt động nào
     được hỗ trợ bởi khóa, bao gồm mã hóa blob, giải mã một
     blob, ký một blob và xác minh chữ ký trên một blob.  Sau đây
     các hằng số được xác định cho việc này::

KEYCTL_SUPPORTS_{ENCRYPT,DECRYPT,SIGN,VERIFY}

Trường key_size là kích thước của khóa tính bằng bit.  max_data_size và
     max_sig_size là kích thước chữ ký và dữ liệu thô tối đa để tạo và
     xác minh chữ ký; max_enc_size và max_dec_size là mức tối đa
     dữ liệu thô và kích thước chữ ký để mã hóa và giải mã.  các
     Các trường max_*_size được đo bằng byte.

Nếu thành công sẽ trả về 0.  Nếu khóa không hỗ trợ điều này,
     EOPNOTSUPP sẽ được trả lại.


Dịch vụ gọi lại khóa yêu cầu
============================

Để tạo khóa mới, kernel sẽ cố gắng thực thi lệnh sau
dòng::

/sbin/request-key tạo <key> <uid> <gid> \
		<threadring> <processring> <sessionring> <callout_info>

<key> là chìa khóa đang được xây dựng và ba chuỗi khóa là quá trình
dây móc khóa từ quá trình khiến việc tìm kiếm được thực hiện. Đây là
đưa vào vì hai lý do:

1 Có thể có mã thông báo xác thực ở một trong các chuỗi khóa được
      được yêu cầu để lấy chìa khóa, ví dụ: Vé cấp vé Kerberos.

2 Khóa mới có thể sẽ được lưu vào bộ nhớ đệm ở một trong các vòng này.

Chương trình này nên đặt UID và GID thành các giá trị được chỉ định trước khi thử
truy cập bất kỳ phím nào nữa. Sau đó nó có thể tìm kiếm một quy trình cụ thể của người dùng để
chuyển yêu cầu tới (có lẽ một đường dẫn được giữ trong một khóa khác bởi, đối với
ví dụ: trình quản lý máy tính để bàn KDE).

Chương trình (hoặc bất cứ thứ gì nó gọi) sẽ hoàn thành việc xây dựng khóa bằng cách
gọi KEYCTL_INSTANTIATE hoặc KEYCTL_INSTANTIATE_IOV, điều này cũng cho phép nó
lưu trữ khóa vào một trong các chuỗi khóa (có thể là vòng phiên) trước
đang quay trở lại.  Ngoài ra, khóa có thể được đánh dấu là âm bằng KEYCTL_NEGATE
hoặc KEYCTL_REJECT; điều này cũng cho phép khóa được lưu vào bộ nhớ đệm ở một trong các
dây móc khóa.

Nếu nó trả về với khóa còn lại ở trạng thái chưa được xây dựng, khóa sẽ
được đánh dấu là âm, nó sẽ được thêm vào khóa phiên và
lỗi sẽ được trả về cho người yêu cầu khóa.

Thông tin bổ sung có thể được cung cấp từ bất cứ ai hoặc bất cứ điều gì viện dẫn điều này
dịch vụ. Điều này sẽ được chuyển dưới dạng tham số <callout_info>. Nếu không như vậy
thông tin đã có sẵn thì "-" sẽ được chuyển dưới dạng tham số này
thay vào đó.


Tương tự, kernel có thể cố gắng cập nhật một khóa đã hết hạn hoặc sắp hết hạn.
bằng cách thực hiện::

/sbin/request-key cập nhật <key> <uid> <gid> \
		<chuỗi chuỗi> <chuỗi xử lý> <chuẩn phiên>

Trong trường hợp này, chương trình không bắt buộc phải gắn chìa khóa vào vòng;
những chiếc nhẫn được cung cấp để tham khảo.


Thu gom rác
==================

Các phím chết (loại đã bị xóa) sẽ tự động được hủy liên kết
từ những dây móc khóa trỏ đến chúng và bị xóa càng sớm càng tốt bởi một
người thu gom rác nền.

Tương tự, các khóa bị thu hồi và hết hạn sẽ được thu gom rác nhưng chỉ sau một thời gian.
một khoảng thời gian nhất định đã trôi qua.  Thời gian này được đặt là số giây trong::

/proc/sys/kernel/keys/gc_delay
