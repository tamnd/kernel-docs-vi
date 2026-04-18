.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/credentials.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Thông tin xác thực trong Linux
====================

Bởi: David Howells <dhowells@redhat.com>

.. contents:: :local:

Tổng quan
========

Có một số phần trong quá trình kiểm tra bảo mật được Linux thực hiện khi một
vật tác động lên vật khác:

1. Đối tượng.

Đối tượng là những thứ trong hệ thống có thể được tác động trực tiếp bởi
     chương trình không gian người dùng.  Linux có nhiều đối tượng có thể thực hiện được, bao gồm:

- Nhiệm vụ
	- Tập tin/inodes
	- Ổ cắm
	- Hàng đợi tin nhắn
	- Phân đoạn bộ nhớ dùng chung
	- Ngữ nghĩa
	- Chìa khóa

Là một phần của việc mô tả tất cả các đối tượng này, có một tập hợp các
     thông tin xác thực.  Những gì trong bộ phụ thuộc vào loại đối tượng.

2. Quyền sở hữu đối tượng.

Trong số các thông tin xác thực của hầu hết các đối tượng, sẽ có một tập hợp con
     thể hiện quyền sở hữu của đối tượng đó.  Điều này được sử dụng cho tài nguyên
     tính toán và giới hạn (ví dụ như hạn ngạch đĩa và giới hạn nhiệm vụ).

Ví dụ: trong hệ thống tệp UNIX tiêu chuẩn, điều này sẽ được xác định bởi
     UID được đánh dấu trên inode.

3. Bối cảnh khách quan.

Ngoài ra, trong số các thông tin xác thực của các đối tượng đó, sẽ có một tập hợp con
     chỉ ra 'bối cảnh khách quan' của đối tượng đó.  Điều này có thể có hoặc không
     cùng bộ như trong (2) - ví dụ: trong các tệp UNIX tiêu chuẩn, đây là
     được xác định bởi UID và GID được đánh dấu trên inode.

Bối cảnh khách quan được sử dụng như một phần của tính toán bảo mật được
     được thực hiện khi một đối tượng được tác động.

4. Chủ thể.

Chủ thể là một đối tượng tác động lên một đối tượng khác.

Hầu hết các đối tượng trong hệ thống đều không hoạt động: chúng không tác động lên các đối tượng khác.
     các đối tượng bên trong hệ thống.  Quy trình/nhiệm vụ là ngoại lệ rõ ràng:
     họ làm mọi việc; họ truy cập và thao túng mọi thứ.

Các đối tượng khác ngoài nhiệm vụ trong một số trường hợp cũng có thể là chủ thể.
     Ví dụ: một tệp đang mở có thể gửi SIGIO đến một tác vụ bằng cách sử dụng UID và EUID
     được giao cho nó bởi một nhiệm vụ có tên ZZ0000ZZ.  Trong trường hợp này,
     cấu trúc tập tin cũng sẽ có bối cảnh chủ quan.

5. Bối cảnh chủ quan.

Một chủ đề có một cách giải thích bổ sung về thông tin xác thực của nó.  Một tập hợp con
     thông tin xác thực của nó tạo thành 'bối cảnh chủ quan'.  Bối cảnh chủ quan
     được sử dụng như một phần của tính toán bảo mật được thực hiện khi một
     chủ thể hành động.

Ví dụ: một tác vụ Linux có FSUID, FSGID và phần bổ sung
     danh sách nhóm khi nó hoạt động trên một tệp - khá riêng biệt
     từ UID và GID thực thường tạo thành bối cảnh khách quan của
     nhiệm vụ.

6. Hành động.

Linux có sẵn một số hành động mà một chủ thể có thể thực hiện trên một
     đối tượng.  Tập hợp các hành động có sẵn tùy thuộc vào bản chất của chủ đề
     và đối tượng.

Các hành động bao gồm đọc, ghi, tạo và xóa tệp; rẽ nhánh hoặc
     nhiệm vụ báo hiệu và truy tìm.

7. Quy tắc, danh sách kiểm soát truy cập và tính toán bảo mật.

Khi một chủ thể tác động lên một đối tượng, một tính toán bảo mật sẽ được thực hiện.  Cái này
     liên quan đến việc lấy bối cảnh chủ quan, bối cảnh khách quan và
     hành động và tìm kiếm một hoặc nhiều bộ quy tắc để xem liệu chủ đề có
     được cấp hoặc từ chối quyền hành động theo cách mong muốn trên
     đối tượng, dựa trên những bối cảnh đó.

Có hai nguồn chính của quy tắc:

Một. Kiểm soát truy cập tùy ý (DAC):

Đôi khi đối tượng sẽ bao gồm các bộ quy tắc như một phần của nó.
	 mô tả.  Đây là 'Danh sách kiểm soát truy cập' hoặc 'ACL'.  Một Linux
	 tập tin có thể cung cấp nhiều hơn một ACL.

Ví dụ: tệp UNIX truyền thống bao gồm mặt nạ quyền
	 là một ACL viết tắt với ba loại chủ đề cố định ('người dùng',
	 'nhóm' và 'khác'), mỗi nhóm có thể được cấp một số đặc quyền nhất định
	 ('đọc', 'ghi' và 'thực thi' - bất kể những bản đồ đó hướng tới đối tượng
	 trong câu hỏi).  Quyền truy cập tệp UNIX không cho phép tùy ý
	 tuy nhiên, đặc điểm kỹ thuật của các chủ đề và do đó được sử dụng hạn chế.

Tệp Linux cũng có thể có POSIX ACL.  Đây là danh sách các quy tắc
	 cấp nhiều quyền khác nhau cho các đối tượng tùy ý.

b. Kiểm soát truy cập bắt buộc (MAC):

Toàn bộ hệ thống có thể có một hoặc nhiều bộ quy tắc được áp dụng
	 áp dụng cho mọi chủ thể và đối tượng, bất kể nguồn gốc của chúng.
	 SELinux và Smack là những ví dụ về điều này.

Trong trường hợp SELinux và Smack, mỗi đối tượng được gắn nhãn như một phần
	 thông tin xác thực của nó.  Khi một hành động được yêu cầu, họ sẽ thực hiện
	 nhãn chủ đề, nhãn đối tượng và hành động và tìm kiếm quy tắc
	 điều đó nói rằng hành động này được chấp thuận hoặc bị từ chối.


Các loại thông tin xác thực
====================

Nhân Linux hỗ trợ các loại thông tin xác thực sau:

1. Thông tin xác thực UNIX truyền thống.

- ID người dùng thực
	- ID nhóm thực

UID và GID được hầu hết, nếu không phải tất cả, các đối tượng Linux mang theo, ngay cả khi trong
     trong một số trường hợp, nó phải được phát minh (ví dụ: tệp FAT hoặc CIFS, đó là
     có nguồn gốc từ Windows).  Những điều này (hầu hết) xác định bối cảnh khách quan của
     đối tượng đó, với các nhiệm vụ hơi khác nhau trong một số trường hợp.

- ID người dùng hiệu quả, đã lưu và FS
	- ID nhóm hiệu quả, đã lưu và FS
	- Nhóm bổ sung

Đây là những thông tin xác thực bổ sung chỉ được sử dụng bởi các tác vụ.  Thông thường, một
     EUID/EGID/GROUPS sẽ được sử dụng làm bối cảnh chủ quan và UID/GID thực
     sẽ được sử dụng làm mục tiêu.  Đối với các nhiệm vụ, cần lưu ý rằng đây là
     không phải lúc nào cũng đúng.

2. Khả năng.

- Tập hợp các khả năng được phép
	- Tập hợp các khả năng kế thừa
	- Tập hợp các khả năng hiệu quả
	- Bộ giới hạn khả năng

Những thứ này chỉ được thực hiện bởi các nhiệm vụ.  Chúng chỉ ra khả năng vượt trội
     được trao từng phần cho một nhiệm vụ mà một nhiệm vụ bình thường sẽ không có.
     Chúng được thao tác ngầm bằng những thay đổi đối với UNIX truyền thống
     thông tin xác thực, nhưng cũng có thể được ZZ0000ZZ thao tác trực tiếp
     cuộc gọi hệ thống.

Các khả năng được phép là những giới hạn mà quy trình có thể cấp
     chính nó với các bộ có hiệu lực hoặc được phép thông qua ZZ0000ZZ.  Cái này
     tập hợp có thể kế thừa cũng có thể bị hạn chế như vậy.

Những khả năng hiệu quả là những khả năng mà một nhiệm vụ thực sự được phép thực hiện.
     tận dụng chính nó.

Khả năng kế thừa là những khả năng có thể được truyền lại
     ZZ0000ZZ.

Tập giới hạn giới hạn các khả năng có thể được kế thừa qua
     ZZ0000ZZ, đặc biệt khi một tệp nhị phân được thực thi sẽ thực thi như
     UID 0.

3. Cờ quản lý an toàn (securebits).

Những thứ này chỉ được thực hiện bởi các nhiệm vụ.  Những điều này chi phối cách trên
     thông tin đăng nhập bị thao túng và kế thừa qua các hoạt động nhất định như
     thực thi().  Chúng không được sử dụng trực tiếp như mục tiêu hay chủ quan
     thông tin xác thực.

4. Chìa khóa và dây móc khóa.

Những thứ này chỉ được thực hiện bởi các nhiệm vụ.  Họ mang và lưu trữ mã thông báo bảo mật
     không phù hợp với thông tin xác thực UNIX tiêu chuẩn khác.  Chúng dành cho
     cung cấp những thứ như khóa hệ thống tệp mạng cho tệp
     truy cập được thực hiện bởi các tiến trình mà không cần đến các thủ tục thông thường
     các chương trình phải biết về các chi tiết bảo mật liên quan.

Móc khóa là một loại chìa khóa đặc biệt.  Họ mang theo bộ chìa khóa khác và có thể
     được tìm kiếm khóa mong muốn.  Mỗi tiến trình có thể đăng ký một số
     của móc khóa:

Khóa trên mỗi luồng
	Khóa mỗi quá trình
	Móc khóa mỗi phiên

Khi một tiến trình truy cập vào một khóa, nếu nó chưa có sẵn thì thông thường nó sẽ bị
     được lưu vào bộ nhớ đệm trên một trong các chuỗi khóa này để tìm kiếm các lần truy cập sau này.

Để biết thêm thông tin về cách sử dụng phím, hãy xem ZZ0000ZZ.

5. LSM

Mô-đun bảo mật Linux cho phép đặt các điều khiển bổ sung trên
     các thao tác mà một tác vụ có thể thực hiện.  Hiện tại Linux hỗ trợ một số LSM
     tùy chọn.

Một số hoạt động bằng cách dán nhãn cho các đối tượng trong hệ thống và sau đó áp dụng các tập hợp
     các quy tắc (chính sách) cho biết những hoạt động mà một tác vụ có một nhãn có thể thực hiện đối với
     một đối tượng có nhãn khác.

6. AF_KEY

Đây là một cách tiếp cận dựa trên socket để quản lý thông tin xác thực cho mạng
     ngăn xếp [RFC 2367].  Nó không được thảo luận trong tài liệu này vì nó không
     tương tác trực tiếp với thông tin xác thực về tác vụ và tệp; đúng hơn là nó giữ hệ thống
     thông tin cấp độ.


Khi một tập tin được mở, một phần ngữ cảnh chủ quan của tác vụ mở được
được ghi vào file struct đã tạo.  Điều này cho phép các hoạt động sử dụng tập tin đó
struct sử dụng những thông tin xác thực đó thay vì bối cảnh chủ quan của nhiệm vụ
đã ban hành hoạt động đó.  Một ví dụ về điều này là một tập tin được mở trên một
hệ thống tệp mạng nơi phải trình bày thông tin xác thực của tệp đã mở
tới máy chủ, bất kể ai đang thực sự đọc hoặc viết lên nó.


Đánh dấu tập tin
=============

Các tệp trên đĩa hoặc được lấy qua mạng có thể có các chú thích tạo thành
bối cảnh bảo mật khách quan của tập tin đó.  Tùy thuộc vào loại hệ thống tập tin,
điều này có thể bao gồm một hoặc nhiều điều sau đây:

* UNIX UID, GID, chế độ;
 * ID người dùng Windows;
 * Danh sách kiểm soát truy cập;
 * Nhãn bảo mật LSM;
 * Các bit leo thang đặc quyền thực thi UNIX (SUID/SGID);
 * Khả năng thực thi các bit leo thang đặc quyền của tệp.

Chúng được so sánh với bối cảnh bảo mật chủ quan của nhiệm vụ và một số
kết quả là các hoạt động được phép hoặc không được phép.  Trong trường hợp execve(),
các bit leo thang đặc quyền phát huy tác dụng và có thể cho phép quá trình kết quả
đặc quyền bổ sung, dựa trên các chú thích trên tệp thực thi.


Thông tin xác thực nhiệm vụ
================

Trong Linux, tất cả thông tin xác thực của tác vụ được lưu giữ trong (uid, gid) hoặc thông qua
(nhóm, khóa, bảo mật LSM) cấu trúc được tính lại thuộc loại 'struct cred'.
Mỗi tác vụ trỏ đến thông tin xác thực của nó bằng một con trỏ có tên 'cred' trong
nhiệm vụ_struct.

Khi một bộ thông tin xác thực đã được chuẩn bị và cam kết, nó có thể không được
đã thay đổi, trừ các ngoại lệ sau:

1. số tham chiếu của nó có thể được thay đổi;

2. số tham chiếu trên cấu trúc group_info mà nó trỏ đến có thể bị thay đổi;

3. số lượng tham chiếu trên dữ liệu bảo mật mà nó trỏ tới có thể bị thay đổi;

4. số tham chiếu trên bất kỳ dây móc khóa nào mà nó chỉ tới có thể bị thay đổi;

5. bất kỳ dây móc khóa nào mà nó trỏ tới đều có thể bị thu hồi, hết hạn hoặc có tính bảo mật
    thuộc tính đã thay đổi; Và

6. nội dung của bất kỳ dây móc khóa nào mà nó chỉ tới có thể được thay đổi (toàn bộ
    điểm của dây móc khóa là một bộ thông tin xác thực được chia sẻ, có thể được sửa đổi bởi bất kỳ ai
    với quyền truy cập thích hợp).

Để thay đổi bất cứ điều gì trong cấu trúc tín dụng, nguyên tắc sao chép và thay thế phải được thực hiện
tuân thủ.  Đầu tiên lấy một bản sao, sau đó thay đổi bản sao và sau đó sử dụng RCU để thay đổi
con trỏ tác vụ để làm cho nó trỏ tới bản sao mới.  Có giấy gói để hỗ trợ
với điều này (xem bên dưới).

Một tác vụ chỉ có thể thay đổi thông tin xác thực _own_ của nó; nó không còn được phép cho một
nhiệm vụ thay đổi thông tin xác thực của người khác.  Điều này có nghĩa là lệnh gọi hệ thống ZZ0000ZZ
không còn được phép lấy bất kỳ PID nào khác ngoài PID hiện tại
quá trình. Ngoài ra chức năng ZZ0001ZZ và ZZ0002ZZ không
cho phép đính kèm lâu hơn vào các chuỗi khóa dành riêng cho quy trình trong yêu cầu
quá trình vì quá trình khởi tạo có thể cần tạo chúng.


Thông tin xác thực bất biến
---------------------

Khi một bộ thông tin xác thực đã được công khai (bằng cách gọi ZZ0000ZZ
chẳng hạn), nó phải được coi là bất biến, trừ hai trường hợp ngoại lệ:

1. Số lượng tham chiếu có thể bị thay đổi.

2. Mặc dù việc đăng ký khóa của một bộ thông tin xác thực có thể không được
    đã thay đổi, các dây móc khóa được đăng ký có thể bị thay đổi nội dung.

Để phát hiện sự thay đổi thông tin xác thực ngẫu nhiên tại thời điểm biên dịch, struct task_struct
có các con trỏ _const_ tới các bộ thông tin xác thực của nó, cũng như tệp cấu trúc.  Hơn nữa,
một số chức năng nhất định như ZZ0000ZZ và ZZ0001ZZ hoạt động trên const
con trỏ, do đó hiển thị các phôi không cần thiết nhưng yêu cầu tạm thời loại bỏ
tiêu chuẩn const để có thể thay đổi số lượng tham chiếu.


Truy cập thông tin xác thực tác vụ
--------------------------

Một tác vụ chỉ có thể thay đổi thông tin xác thực của chính nó sẽ cho phép quy trình hiện tại
để đọc hoặc thay thế thông tin xác thực của chính nó mà không cần bất kỳ hình thức khóa nào
-- điều này giúp đơn giản hóa mọi việc rất nhiều.  Nó chỉ có thể gọi ::

const struct cred *current_cred()

để có được một con trỏ tới cấu trúc thông tin đăng nhập của nó và nó không cần phải giải phóng
nó sau đó.

Có các trình bao bọc tiện lợi để truy xuất các khía cạnh cụ thể của nhiệm vụ
thông tin đăng nhập (giá trị được trả về đơn giản trong từng trường hợp)::

uid_t current_uid(void) UID thực của hiện tại
	gid_t current_gid(void) GID thực của hiện tại
	uid_t current_euid(void) UID hiệu dụng hiện tại
	gid_t current_egid(void) GID hiệu dụng hiện tại
	uid_t current_fsuid(void) Truy cập tệp hiện tại UID
	gid_t current_fsgid(void) Truy cập tập tin hiện tại GID
	kernel_cap_t current_cap(void) Khả năng hiệu quả của Current
	struct user_struct *current_user(void) Tài khoản người dùng hiện tại

Ngoài ra còn có các trình bao bọc thuận tiện để truy xuất các cặp dữ liệu liên quan cụ thể.
thông tin xác thực của một nhiệm vụ::

void current_uid_gid(uid_t ZZ0000ZZ);
	void current_euid_eid(uid_t ZZ0001ZZ);
	void current_fsuid_fsgid(uid_t ZZ0002ZZ);

trả về các cặp giá trị này thông qua các đối số của chúng sau khi truy xuất
chúng từ thông tin xác thực của nhiệm vụ hiện tại.


Ngoài ra, còn có chức năng lấy tham chiếu về hiện tại
bộ thông tin xác thực hiện tại của quy trình::

const struct cred *get_current_cred(void);

và các chức năng để nhận các tham chiếu đến một trong những thông tin xác thực không
thực sự sống trong struct cred::

cấu trúc user_struct *get_current_user(void);
	struct group_info *get_current_groups(void);

có tham chiếu đến cấu trúc kế toán người dùng của quy trình hiện tại và
danh sách các nhóm bổ sung tương ứng.

Khi đã có được tham chiếu, nó phải được phát hành bằng ZZ0000ZZ,
ZZ0001ZZ hoặc ZZ0002ZZ nếu thích hợp.


Truy cập thông tin xác thực của tác vụ khác
------------------------------------

Mặc dù một tác vụ có thể truy cập thông tin xác thực của chính nó mà không cần khóa,
điều tương tự không đúng với một tác vụ muốn truy cập thông tin xác thực của tác vụ khác.  Nó
phải sử dụng khóa đọc RCU và ZZ0000ZZ.

ZZ0000ZZ được bao bọc bởi::

const struct cred *__task_cred(struct task_struct *task);

Điều này nên được sử dụng bên trong khóa đọc RCU, như trong ví dụ sau::

void foo(struct task_struct *t, struct foo_data *f)
	{
		const struct cred *tcred;
		...
rcu_read_lock();
		tcred = __task_cred(t);
		f->uid = tcred->uid;
		f->gid = tcred->gid;
		f->groups = get_group_info(tcred->groups);
		rcu_read_unlock();
		...
	}

Nếu cần phải giữ thông tin xác thực của nhiệm vụ khác trong một thời gian dài
thời gian và có thể ngủ trong khi làm như vậy thì người gọi sẽ nhận được
tham khảo về chúng bằng cách sử dụng ::

const struct cred *get_task_cred(struct task_struct *task);

Điều này thực hiện tất cả phép thuật RCU bên trong nó.  Người gọi phải gọi put_cred() trên
thông tin đăng nhập có được khi họ hoàn thành.

.. note::
   The result of ``__task_cred()`` should not be passed directly to
   ``get_cred()`` as this may race with ``commit_cred()``.

Có một số chức năng tiện lợi để truy cập các bit của tác vụ khác
thông tin xác thực, ẩn phép thuật RCU khỏi người gọi ::

uid_t task_uid(task) UID thực sự của nhiệm vụ
	uid_t task_euid(task) Nhiệm vụ hiệu quả UID

Nếu người gọi vẫn giữ khóa đọc RCU vào thời điểm đó thì::

__task_cred(task)->uid
	__task_cred(task)->euid

nên được sử dụng thay thế.  Tương tự, nếu nhiều khía cạnh của thông tin xác thực của nhiệm vụ
cần được truy cập, nên sử dụng khóa đọc RCU, gọi ZZ0000ZZ,
kết quả được lưu trữ trong một con trỏ tạm thời và sau đó các khía cạnh thông tin xác thực được gọi là
từ đó trước khi thả khóa.  Điều này ngăn ngừa khả năng tốn kém
Phép thuật RCU được thực hiện nhiều lần.

Nếu cần phải có một số khía cạnh riêng lẻ khác của thông tin xác thực của nhiệm vụ khác
được truy cập, thì cái này có thể được sử dụng ::

task_cred_xxx(nhiệm vụ, thành viên)

trong đó 'thành viên' là thành viên không phải là con trỏ của cấu trúc tín dụng.  Ví dụ::

uid_t task_cred_xxx(tác vụ, suid);

sẽ truy xuất 'struct cred::suid' từ tác vụ, thực hiện RCU thích hợp
ma thuật.  Điều này có thể không được sử dụng cho các thành viên con trỏ vì những gì chúng trỏ tới có thể
biến mất ngay khi khóa đọc RCU bị rơi.


Thay đổi thông tin xác thực
--------------------

Như đã đề cập trước đó, một tác vụ chỉ có thể thay đổi thông tin xác thực của chính nó và không được
thay đổi những nhiệm vụ khác.  Điều này có nghĩa là nó không cần sử dụng bất kỳ
lock để thay đổi thông tin xác thực của chính nó.

Để thay đổi thông tin xác thực của quy trình hiện tại, trước tiên một chức năng phải chuẩn bị một
bộ thông tin xác thực mới bằng cách gọi::

struct cred *prepare_creds(void);

cái này khóa current->cred_replace_mutex rồi phân bổ và xây dựng một
trùng lặp thông tin xác thực của quy trình hiện tại, trả về với mutex vẫn
được giữ nếu thành công.  Nó trả về NULL nếu không thành công (hết bộ nhớ).

Mutex ngăn ZZ0000ZZ thay đổi trạng thái ptrace của một quy trình
trong khi việc kiểm tra bảo mật về việc xây dựng và thay đổi thông tin xác thực đang diễn ra
vì trạng thái ptrace có thể làm thay đổi kết quả, đặc biệt trong trường hợp
ZZ0001ZZ.

Bộ thông tin xác thực mới phải được thay đổi một cách thích hợp và mọi biện pháp bảo mật
kiểm tra và móc xong.  Cả bộ thông tin xác thực hiện tại và đề xuất
có sẵn cho mục đích này vì current_cred() sẽ trả về tập hợp hiện tại
vẫn còn ở thời điểm này.

Khi thay thế danh sách nhóm, danh sách mới phải được sắp xếp trước nó
được thêm vào thông tin xác thực, vì tìm kiếm nhị phân được sử dụng để kiểm tra
thành viên.  Trong thực tế, điều này có nghĩa làgroup_sort() phải là
được gọi trước set_groups() hoặc set_current_groups().
Group_sort() không được gọi trên ZZ0000ZZ
được chia sẻ vì nó có thể hoán vị các phần tử như một phần của quá trình sắp xếp
ngay cả khi mảng đã được sắp xếp.

Khi bộ thông tin xác thực đã sẵn sàng, nó phải được cam kết với quy trình hiện tại
bằng cách gọi::

int commit_creds(struct cred *new);

Điều này sẽ thay đổi các khía cạnh khác nhau của thông tin xác thực và quy trình, mang lại cho
LSM có cơ hội làm điều tương tự thì sẽ sử dụng ZZ0000ZZ để
thực sự cam kết thông tin xác thực mới cho ZZ0001ZZ, nó sẽ phát hành
ZZ0002ZZ cho phép ZZ0003ZZ diễn ra và nó
sẽ thông báo cho người lên lịch và những người khác về những thay đổi.

Hàm này được đảm bảo trả về 0, do đó nó có thể được gọi đuôi ở
kết thúc các chức năng như ZZ0000ZZ.

Lưu ý rằng hàm này sử dụng tham chiếu của người gọi đến thông tin xác thực mới.
Sau đó, người gọi sẽ _không_ gọi ZZ0000ZZ bằng thông tin đăng nhập mới.

Hơn nữa, khi chức năng này được gọi trên một bộ thông tin xác thực mới,
những thông tin xác thực đó có thể _không_ được thay đổi thêm.


Nếu việc kiểm tra bảo mật không thành công hoặc một số lỗi khác xảy ra sau
ZZ0000ZZ đã được gọi thì hàm sau sẽ được thực hiện
được gọi::

void abort_creds(struct cred *new);

Thao tác này sẽ giải phóng khóa trên ZZ0000ZZ
ZZ0001ZZ đã nhận được và sau đó phát hành thông tin đăng nhập mới.


Chức năng thay đổi thông tin xác thực thông thường sẽ trông giống như thế này::

int alter_suid(uid_t suid)
	{
		struct cred *mới;
		int ret;

mới = chuẩn bị_creds();
		nếu (!mới)
			trả về -ENOMEM;

mới->suid = suid;
		ret = security_alter_suid(mới);
		nếu (ret < 0) {
			abort_creds(mới);
			trở lại ret;
		}

trả về commit_creds(mới);
	}


Quản lý thông tin xác thực
--------------------

Có một số chức năng giúp quản lý thông tin xác thực:

-ZZ0000ZZ

Điều này giải phóng một tham chiếu đến bộ thông tin xác thực nhất định.  Nếu
     số lượng tham chiếu đạt tới 0, thông tin xác thực sẽ được lên lịch cho
     sự phá hủy bởi hệ thống RCU.

-ZZ0000ZZ

Điều này nhận được một tham chiếu trên một tập hợp thông tin xác thực trực tiếp, trả về một con trỏ tới
     bộ thông tin xác thực đó.


Mở tệp thông tin xác thực
=====================

Khi một tệp mới được mở, một tham chiếu sẽ được lấy trên tác vụ mở.
thông tin đăng nhập và thông tin này được đính kèm vào cấu trúc tệp dưới dạng ZZ0000ZZ thay cho
ZZ0001ZZ và ZZ0002ZZ.  Mã được sử dụng để truy cập ZZ0003ZZ và
ZZ0004ZZ bây giờ sẽ truy cập ZZ0005ZZ và
ZZ0006ZZ.

Có thể truy cập ZZ0000ZZ một cách an toàn mà không cần sử dụng RCU hoặc khóa vì
con trỏ sẽ không thay đổi trong suốt thời gian tồn tại của cấu trúc tệp và cũng không
nội dung của cấu trúc tín dụng được trỏ tới, trừ các trường hợp ngoại lệ được liệt kê ở trên
(xem phần Thông tin xác thực nhiệm vụ).

Để tránh các cuộc tấn công leo thang đặc quyền "cấp phó bối rối", hãy kiểm tra kiểm soát truy cập
trong các thao tác tiếp theo trên tệp đã mở nên sử dụng các thông tin xác thực này
thay vì thông tin xác thực của "hiện tại", vì tệp có thể đã được chuyển đến một địa chỉ khác
quá trình đặc quyền.

Ghi đè việc sử dụng thông tin xác thực của VFS
=======================================

Trong một số trường hợp, nên ghi đè thông tin xác thực được sử dụng bởi
VFS và điều đó có thể được thực hiện bằng cách gọi vào ZZ0000ZZ bằng một
bộ thông tin xác thực khác nhau.  Điều này được thực hiện ở những nơi sau:

* ZZ0000ZZ.
 * ZZ0001ZZ.
 * nfs4recover.c.
