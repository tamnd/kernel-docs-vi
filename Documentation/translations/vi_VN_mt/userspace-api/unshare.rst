.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/unshare.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

hủy chia sẻ cuộc gọi hệ thống
=============================

Tài liệu này mô tả lệnh gọi hệ thống mới, unshare(). Tài liệu
cung cấp cái nhìn tổng quan về tính năng, tại sao nó cần thiết, làm thế nào nó có thể
được sử dụng, đặc tả giao diện, thiết kế, triển khai và
làm thế nào nó có thể được kiểm tra.

Nhật ký thay đổi
----------------
phiên bản 0.1 Tài liệu ban đầu, Janak Desai (janak@us.ibm.com), 11 tháng 1 năm 2006

Nội dung
--------
1) Tổng quan
	2) Lợi ích
	3) Chi phí
	4) Yêu cầu
	5) Đặc tả chức năng
	6) Thiết kế cấp cao
	7) Thiết kế cấp thấp
	8) Đặc điểm kỹ thuật kiểm tra
	9) Công việc tương lai

1) Tổng quan
------------

Hầu hết các nhân của hệ điều hành cũ đều hỗ trợ tính năng trừu tượng hóa các luồng
dưới dạng nhiều bối cảnh thực thi trong một quy trình. Những hạt nhân này cung cấp
các nguồn lực và cơ chế đặc biệt để duy trì các "sợi dây" này. Linux
kernel, một cách thông minh và đơn giản, không tạo ra sự khác biệt
giữa các tiến trình và "luồng". Kernel cho phép các tiến trình chia sẻ
tài nguyên và do đó họ có thể đạt được hành vi "luồng" kế thừa mà không cần
yêu cầu các cấu trúc và cơ chế dữ liệu bổ sung trong kernel. các
sức mạnh của việc triển khai các luồng theo cách này không chỉ đến từ
sự đơn giản của nó mà còn cho phép các lập trình viên ứng dụng làm việc
bên ngoài giới hạn của các tài nguyên được chia sẻ tất cả hoặc không có gì của di sản
chủ đề. Trên Linux, tại thời điểm tạo luồng bằng hệ thống nhân bản
gọi, các ứng dụng có thể chọn lọc các tài nguyên để chia sẻ
giữa các chủ đề.

lệnh gọi hệ thống unshare() thêm một nguyên thủy vào mô hình luồng Linux
cho phép các luồng 'hủy chia sẻ' một cách có chọn lọc bất kỳ tài nguyên nào đang được
được chia sẻ tại thời điểm tạo ra chúng. unshare() được khái niệm hóa bởi
Al Viro vào tháng 8 năm 2000, trên danh sách gửi thư Linux-Kernel, như một phần
cuộc thảo luận về các chủ đề POSIX trên Linux.  unshare() tăng cường
tính hữu ích của các luồng Linux đối với các ứng dụng muốn kiểm soát
tài nguyên được chia sẻ mà không cần tạo ra một tiến trình mới. unshare() là điều đương nhiên
ngoài tập hợp các nguyên thủy có sẵn trên Linux để triển khai
khái niệm tiến trình/luồng như một máy ảo.

2) Lợi ích
-----------

unshare() sẽ hữu ích cho các khung ứng dụng lớn như PAM
nơi tạo một quy trình mới để kiểm soát việc chia sẻ/hủy chia sẻ quy trình
tài nguyên là không thể. Vì không gian tên được chia sẻ theo mặc định
khi tạo một quy trình mới bằng cách sử dụng fork hoặc clone, unshare() có thể có lợi
ngay cả các ứng dụng không theo luồng nếu chúng có nhu cầu tách liên kết
từ không gian tên được chia sẻ mặc định. Sau đây liệt kê hai trường hợp sử dụng
nơi có thể sử dụng unshare().

2.1 Không gian tên ngữ cảnh cho mỗi bảo mật
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

unshare() có thể được sử dụng để triển khai các thư mục đa tức thời bằng cách sử dụng
cơ chế không gian tên cho mỗi tiến trình của kernel. Thư mục đa nghĩa,
chẳng hạn như phiên bản ngữ cảnh theo từng người dùng và/hoặc theo từng bảo mật của/tmp,/var/tmp hoặc
phiên bản ngữ cảnh theo từng bảo mật của thư mục chính của người dùng, cách ly người dùng
xử lý khi làm việc với các thư mục này. Sử dụng tính năng hủy chia sẻ(), PAM
module có thể dễ dàng thiết lập một không gian tên riêng cho người dùng khi đăng nhập.
Cần có các thư mục được thể hiện bằng nhiều cách để chứng nhận Tiêu chí chung
Tuy nhiên, với Hồ sơ bảo vệ hệ thống được gắn nhãn, với tính khả dụng
về tính năng cây chia sẻ trong nhân Linux, ngay cả các hệ thống Linux thông thường
có thể hưởng lợi từ việc thiết lập không gian tên riêng khi đăng nhập và
polyinstantiating/tmp,/var/tmp và các thư mục khác được coi là
phù hợp bởi người quản trị hệ thống.

2.2 ngừng chia sẻ bộ nhớ ảo và/hoặc mở tệp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy xem xét một ứng dụng máy khách/máy chủ nơi máy chủ đang xử lý
yêu cầu của khách hàng bằng cách tạo ra các quy trình chia sẻ tài nguyên như
bộ nhớ ảo và mở tập tin. Nếu không có tính năng hủy chia sẻ(), máy chủ phải
quyết định những gì cần được chia sẻ tại thời điểm tạo quy trình
dịch vụ nào theo yêu cầu. unshare() cho phép máy chủ có khả năng
tách rời các phần của bối cảnh trong quá trình phục vụ của
yêu cầu. Đối với các khung ứng dụng phần mềm trung gian lớn và phức tạp, điều này
khả năng hủy chia sẻ() sau khi quá trình được tạo có thể rất
hữu ích.

3) Chi phí
----------

Để không trùng lặp mã và xử lý thực tế là unshare()
hoạt động trên một tác vụ đang hoạt động (ngược lại với việc sao chép/phân nhánh làm việc trên một tác vụ mới
nhiệm vụ không hoạt động được phân bổ) unshare() đã phải thực hiện một cuộc tổ chức lại nhỏ
các thay đổi đối với các hàm copy_* được sử dụng bởi lệnh gọi hệ thống sao chép/ngã ba.
Có một chi phí liên quan đến việc thay đổi hiện có, được thử nghiệm tốt và
mã ổn định để triển khai một tính năng mới có thể không được thực hiện
rộng rãi vào thời gian đầu. Tuy nhiên, với thiết kế và mã phù hợp
xem xét các thay đổi và tạo thử nghiệm không chia sẻ() cho LTP
lợi ích của tính năng mới này có thể vượt quá chi phí của nó.

4) Yêu cầu
---------------

unshare() đảo ngược việc chia sẻ đã được thực hiện bằng lệnh gọi hệ thống clone(2),
vì vậy unshare() sẽ có giao diện tương tự như clone(2). Đó là,
vì các cờ trong clone(int flags, void \*stack) chỉ định những gì nên
được chia sẻ, các cờ tương tự trong unshare(int flags) phải chỉ định
những gì không nên chia sẻ. Thật không may, điều này có thể đảo ngược
ý nghĩa của các cờ theo cách chúng được sử dụng trong bản sao (2).
Tuy nhiên, không có giải pháp dễ dàng nào mà ít gây nhầm lẫn hơn và
cho phép không chia sẻ bối cảnh gia tăng trong tương lai mà không cần thay đổi ABI.

Giao diện unshare() sẽ phù hợp với khả năng bổ sung trong tương lai của
cờ ngữ cảnh mới mà không yêu cầu xây dựng lại các ứng dụng cũ.
Nếu và khi các cờ ngữ cảnh mới được thêm vào, thiết kế unshare() sẽ cho phép
tăng dần việc ngừng chia sẻ các tài nguyên đó trên cơ sở cần thiết.

5) Đặc tả chức năng
---------------------------

NAME
	hủy chia sẻ - tách các phần của bối cảnh thực thi quy trình

SYNOPSIS
	#include <lịch trình.h>

int không chia sẻ(int flag);

DESCRIPTION
	unshare() cho phép một tiến trình tách rời các phần thực thi của nó
	bối cảnh hiện đang được chia sẻ với các quy trình khác. phần
	bối cảnh thực thi, chẳng hạn như không gian tên, được chia sẻ theo mặc định
	khi một quy trình mới được tạo bằng fork(2), trong khi các phần khác,
	chẳng hạn như bộ nhớ ảo, bộ mô tả tệp đang mở, v.v., có thể
	được chia sẻ theo yêu cầu rõ ràng để chia sẻ chúng khi tạo một quy trình
	sử dụng bản sao (2).

Công dụng chính của unshare() là cho phép một tiến trình kiểm soát nó
	bối cảnh thực thi được chia sẻ mà không tạo ra một quy trình mới.

Đối số flags chỉ định một hoặc bitwise-or'ed của một số
	các hằng số sau.

CLONE_FS
		Nếu CLONE_FS được đặt, thông tin hệ thống tệp của người gọi
		được tách khỏi thông tin hệ thống tệp được chia sẻ.

CLONE_FILES
		Nếu CLONE_FILES được đặt, bảng mô tả tệp của
		người gọi bị tách khỏi bộ mô tả tệp được chia sẻ
		cái bàn.

CLONE_NEWNS
		Nếu CLONE_NEWNS được đặt, không gian tên của người gọi là
		tách khỏi không gian tên được chia sẻ.

CLONE_VM
		Nếu CLONE_VM được đặt, bộ nhớ ảo của người gọi sẽ
		tách khỏi bộ nhớ ảo được chia sẻ.

RETURN VALUE
	Khi thành công, số không trở lại. Khi thất bại, -1 được trả về và errno là

ERRORS
	EPERM CLONE_NEWNS được chỉ định bởi một quy trình không phải root (quy trình
		không có CAP_SYS_ADMIN).

ENOMEM Không thể phân bổ đủ bộ nhớ để sao chép các phần của người gọi
		bối cảnh cần được chia sẻ.

EINVAL Cờ không hợp lệ được chỉ định làm đối số.

CONFORMING ĐẾN
	Lệnh gọi unshare() dành riêng cho Linux và không nên được sử dụng
	trong các chương trình có thể mang theo được.

SEE ALSO
	bản sao(2), ngã ba(2)

6) Thiết kế cấp cao
--------------------

Tùy thuộc vào đối số flags, lệnh gọi hệ thống unshare() sẽ phân bổ
cấu trúc bối cảnh quy trình thích hợp, điền vào đó các giá trị từ
phiên bản chia sẻ hiện tại, liên kết các cấu trúc mới được sao chép
với cấu trúc tác vụ hiện tại và các bản phát hành được chia sẻ tương ứng
các phiên bản. Không thể sử dụng các chức năng trợ giúp của bản sao (copy_*)
trực tiếp bằng unshare() vì hai lý do sau.

1) bản sao hoạt động trên một nhiệm vụ mới được phân bổ chưa hoạt động
     cấu trúc, trong đó unshare() hoạt động trên hoạt động hiện tại
     nhiệm vụ. Do đó, unshare() phải thực hiện task_lock() thích hợp
     trước khi liên kết các cấu trúc ngữ cảnh mới được sao chép

2) unshare() phải phân bổ và sao chép tất cả cấu trúc ngữ cảnh
     đang không được chia sẻ, trước khi liên kết chúng với
     nhiệm vụ hiện tại và giải phóng các cấu trúc chia sẻ cũ hơn. Thất bại
     làm như vậy sẽ tạo ra các điều kiện cạnh tranh và/hoặc rất tiếc khi cố gắng
     để quay trở lại do một lỗi. Hãy xem xét trường hợp không chia sẻ
     cả bộ nhớ ảo và không gian tên. Sau khi hủy chia sẻ thành công
     vm, nếu lệnh gọi hệ thống gặp lỗi khi cấp phát
     cấu trúc không gian tên mới, mã trả về lỗi sẽ phải
     đảo ngược việc không chia sẻ của vm. Là một phần của sự đảo ngược
     cuộc gọi hệ thống sẽ phải quay lại phiên bản cũ hơn, chia sẻ, vm
     cấu trúc có thể không còn tồn tại nữa.

Do đó, mã từ các hàm copy_* được phân bổ và sao chép
cấu trúc ngữ cảnh hiện tại đã được chuyển sang các hàm dup_* mới. Bây giờ,
Hàm copy_* gọi hàm dup_* để phân bổ và sao chép
cấu trúc ngữ cảnh thích hợp và sau đó liên kết chúng với
cấu trúc nhiệm vụ đang được xây dựng. cuộc gọi hệ thống unshare() được bật
mặt khác thực hiện như sau:

1) Kiểm tra các cờ để buộc các cờ bị thiếu, nhưng ngụ ý

2) Đối với mỗi cấu trúc ngữ cảnh, hãy gọi hàm unshare() tương ứng
     chức năng trợ giúp để phân bổ và sao chép một bối cảnh mới
     cấu trúc, nếu bit thích hợp được đặt trong đối số cờ.

3) Nếu không có lỗi trong việc phân bổ và sao chép và có
     là các cấu trúc ngữ cảnh mới sau đó khóa cấu trúc tác vụ hiện tại,
     liên kết cấu trúc ngữ cảnh mới với cấu trúc nhiệm vụ hiện tại,
     và giải phóng khóa trên cấu trúc nhiệm vụ hiện tại.

4) Phát hành một cách thích hợp các cấu trúc ngữ cảnh, chia sẻ, cũ hơn.

7) Thiết kế cấp thấp
--------------------

Việc thực hiện unshare() có thể được nhóm lại thành 4 nhóm khác nhau sau đây:
các mục:

a) Tổ chức lại các hàm copy_* hiện có

b) chức năng dịch vụ cuộc gọi hệ thống unshare()

c) các hàm trợ giúp unshare() cho từng bối cảnh quy trình khác nhau

d) Đăng ký số cuộc gọi hệ thống cho các kiến ​​trúc khác nhau

7.1) Tổ chức lại hàm copy_*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mỗi chức năng sao chép như copy_mm, copy_namespace, copy_files,
v.v., có khoảng hai thành phần. Thành phần đầu tiên được phân bổ
và nhân đôi cấu trúc thích hợp và thành phần thứ hai
liên kết nó với cấu trúc tác vụ được truyền vào dưới dạng đối số cho bản sao
chức năng. Thành phần đầu tiên được chia thành chức năng riêng của nó.
Các hàm dup_* này được phân bổ và nhân đôi
cấu trúc ngữ cảnh. Các hàm copy_* được sắp xếp lại được gọi
các hàm dup_* tương ứng của chúng và sau đó liên kết các hàm mới
cấu trúc trùng lặp với cấu trúc nhiệm vụ mà
chức năng sao chép đã được gọi.

7.2) chức năng dịch vụ cuộc gọi hệ thống unshare()
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

* Kiểm tra cờ
	 Buộc cờ ngụ ý. Nếu CLONE_THREAD được đặt bắt buộc CLONE_VM.
	 Nếu CLONE_VM được đặt, buộc CLONE_SIGHAND. Nếu CLONE_SIGHAND là
	 được thiết lập và các tín hiệu cũng đang được chia sẻ, buộc CLONE_THREAD. Nếu
	 CLONE_NEWNS được thiết lập, buộc CLONE_FS.

* Đối với mỗi cờ ngữ cảnh, hãy gọi unshare_* tương ứng
	 quy trình trợ giúp với các cờ được chuyển vào lệnh gọi hệ thống và một
	 tham chiếu đến con trỏ trỏ cấu trúc không chia sẻ mới

* Nếu bất kỳ cấu trúc mới nào được tạo bởi trình trợ giúp unshare_*
	 các chức năng, hãy thực hiện task_lock() cho tác vụ hiện tại,
	 sửa đổi các con trỏ ngữ cảnh thích hợp và giải phóng
         khóa nhiệm vụ

* Đối với tất cả các cấu trúc mới chưa được chia sẻ, hãy giải phóng tương ứng
         cấu trúc cũ hơn, được chia sẻ.

7.3) các hàm trợ giúp unshare_*
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đối với người trợ giúp unshare_* tương ứng với CLONE_SYSVSEM, CLONE_SIGHAND,
và CLONE_THREAD, trả về -EINVAL vì chúng chưa được triển khai.
Đối với những người khác, hãy kiểm tra giá trị cờ để xem liệu việc hủy chia sẻ có được thực hiện hay không
cần thiết cho cấu trúc đó. Nếu có, hãy gọi tương ứng
hàm dup_* để phân bổ và sao chép cấu trúc và trả về
một con trỏ tới nó.

7.4) Cuối cùng
~~~~~~~~~~~~~~

Sửa đổi mã cụ thể của kiến trúc một cách thích hợp để đăng ký
cuộc gọi hệ thống mới.

8) Đặc điểm kỹ thuật kiểm tra
-----------------------------

Việc kiểm tra unshare() sẽ kiểm tra những điều sau:

1) Cờ hợp lệ: Kiểm tra để kiểm tra các cờ sao chép tín hiệu và
     trình xử lý tín hiệu không được triển khai
     chưa, trả về -EINVAL.

2) Cờ bị thiếu/ngụ ý: Kiểm tra để đảm bảo rằng nếu không chia sẻ
     không gian tên mà không chỉ định chính xác việc hủy chia sẻ hệ thống tập tin
     hủy chia sẻ cả không gian tên và thông tin hệ thống tập tin.

3) Đối với mỗi trong số bốn (không gian tên, hệ thống tệp, tệp và vm)
     được hỗ trợ hủy chia sẻ, xác minh rằng hệ thống gọi chính xác
     không chia sẻ cấu trúc thích hợp. Xác minh rằng việc hủy chia sẻ
     chúng một cách riêng lẻ cũng như kết hợp với từng
     các công việc khác như mong đợi.

4) Thực thi đồng thời: Sử dụng các phân đoạn bộ nhớ dùng chung và futex trên
     một địa chỉ trong phân đoạn shm để đồng bộ hóa việc thực thi
     khoảng 10 thread. Có một vài chủ đề thực thi execve,
     một vài _exit và phần còn lại không chia sẻ với sự kết hợp khác nhau
     của những lá cờ. Xác minh rằng việc hủy chia sẻ được thực hiện như mong đợi và
     rằng không có lỗi hoặc bị treo.

9) Công việc tương lai
----------------------

Việc triển khai unshare() hiện tại không cho phép hủy chia sẻ
tín hiệu và bộ xử lý tín hiệu. Tín hiệu ban đầu rất phức tạp và
để hủy chia sẻ tín hiệu và/hoặc bộ xử lý tín hiệu của một hệ thống hiện đang chạy
quá trình thậm chí còn phức tạp hơn. Nếu trong tương lai có một quyết định cụ thể
cần cho phép không chia sẻ tín hiệu và/hoặc bộ xử lý tín hiệu, nó có thể
được thêm dần vào unshare() mà không ảnh hưởng đến di sản
các ứng dụng sử dụng chức năng unshare().

