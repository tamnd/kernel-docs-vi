.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/seccomp_filter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Seccomp BPF (Máy tính an toàn với bộ lọc)
===========================================

Giới thiệu
============

Một số lượng lớn các cuộc gọi hệ thống được thực hiện trong mọi quy trình của người dùng
với nhiều trong số chúng sẽ không được sử dụng trong suốt thời gian của quá trình.
Khi các cuộc gọi hệ thống thay đổi và hoàn thiện, các lỗi sẽ được tìm thấy và loại bỏ.  A
một số tập hợp con nhất định của các ứng dụng vùng người dùng được hưởng lợi nhờ có một tập hợp giảm bớt
của các cuộc gọi hệ thống có sẵn.  Tập kết quả làm giảm tổng số kernel
bề mặt tiếp xúc với ứng dụng.  Lọc cuộc gọi hệ thống có nghĩa là dành cho
sử dụng với các ứng dụng đó.

Lọc Seccomp cung cấp phương tiện để một quy trình chỉ định bộ lọc cho
các cuộc gọi hệ thống đến.  Bộ lọc được thể hiện dưới dạng Gói Berkeley
Chương trình lọc (BPF), giống như các bộ lọc ổ cắm, ngoại trừ dữ liệu
được vận hành có liên quan đến cuộc gọi hệ thống đang được thực hiện: cuộc gọi hệ thống
số và các đối số cuộc gọi hệ thống.  Điều này cho phép thể hiện
lọc các cuộc gọi hệ thống bằng ngôn ngữ chương trình lọc có thời lượng dài
lịch sử tiếp xúc với vùng người dùng và tập dữ liệu đơn giản.

Ngoài ra, BPF khiến người dùng seccomp không thể trở thành con mồi
trước các cuộc tấn công theo thời gian kiểm tra thời gian sử dụng (TOCTOU) phổ biến trong hệ thống
khung can thiệp cuộc gọi.  Các chương trình BPF có thể không được tham chiếu
các con trỏ hạn chế tất cả các bộ lọc chỉ đánh giá hệ thống
gọi đối số trực tiếp.

Nó không phải là gì
=============

Lọc cuộc gọi hệ thống không phải là hộp cát.  Nó cung cấp một định nghĩa rõ ràng
cơ chế giảm thiểu bề mặt hạt nhân lộ ra ngoài.  Nó có nghĩa là
một công cụ dành cho các nhà phát triển sandbox sử dụng.  Ngoài ra, chính sách logic
hành vi và luồng thông tin cần được quản lý bằng sự kết hợp của
các kỹ thuật tăng cường hệ thống khác và có thể là LSM của bạn
đang lựa chọn.  Các bộ lọc động, biểu cảm cung cấp thêm các tùy chọn sau này
đường dẫn (tránh kích thước bệnh lý hoặc chọn đường dẫn ghép kênh nào
ví dụ: các cuộc gọi hệ thống trong socketcall() được cho phép) có thể
được hiểu không chính xác như một giải pháp hộp cát hoàn chỉnh hơn.

Cách sử dụng
=====

Một chế độ seccomp bổ sung được thêm vào và được kích hoạt bằng cách sử dụng cùng
prctl(2) gọi là seccomp nghiêm ngặt.  Nếu kiến trúc có
ZZ0000ZZ, sau đó các bộ lọc có thể được thêm vào như sau:

ZZ0000ZZ:
	Bây giờ có một đối số bổ sung chỉ định bộ lọc mới
	bằng chương trình BPF.
	Chương trình BPF sẽ được thực thi trên struct seccomp_data
	phản ánh số lệnh gọi hệ thống, đối số và các thông số khác
	siêu dữ liệu.  Chương trình BPF sau đó phải trả về một trong các
	các giá trị có thể chấp nhận được để thông báo cho kernel biết nên thực hiện hành động nào
	đã lấy.

Cách sử dụng::

prctl(PR_SET_SECCOMP, SECCOMP_MODE_FILTER, prog);

Đối số 'prog' là một con trỏ tới struct sock_fprog
	sẽ chứa chương trình lọc.  Nếu chương trình không hợp lệ,
	cuộc gọi sẽ trả về -1 và đặt errno thành ZZ0000ZZ.

Nếu ZZ0000ZZ/ZZ0001ZZ và ZZ0002ZZ được @prog cho phép thì bất kỳ đứa trẻ nào
	các quy trình sẽ bị hạn chế trong cùng một bộ lọc và hệ thống
	gọi ABI là cha mẹ.

Trước khi sử dụng, tác vụ phải gọi ZZ0000ZZ hoặc
	chạy với đặc quyền ZZ0001ZZ trong không gian tên của nó.  Nếu những điều này không
	đúng, ZZ0002ZZ sẽ được trả lại.  Yêu cầu này đảm bảo rằng bộ lọc
	các chương trình không thể được áp dụng cho các tiến trình con có đặc quyền cao hơn
	hơn nhiệm vụ đã cài đặt chúng.

Ngoài ra, nếu ZZ0000ZZ được bộ lọc đính kèm cho phép,
	các bộ lọc bổ sung có thể được xếp lớp để tăng cường đánh giá
	thời gian, nhưng cho phép giảm thêm bề mặt tấn công trong thời gian
	thực hiện một quá trình.

Cuộc gọi trên trả về 0 nếu thành công và khác 0 nếu có lỗi.

Giá trị trả về
=============

Bộ lọc seccomp có thể trả về bất kỳ giá trị nào sau đây. Nếu nhiều
bộ lọc tồn tại, giá trị trả về cho việc đánh giá một hệ thống nhất định
cuộc gọi sẽ luôn sử dụng giá trị tiền lệ cao nhất. (Ví dụ:
ZZ0000ZZ sẽ luôn được ưu tiên.)

Theo thứ tự ưu tiên, chúng là:

ZZ0000ZZ:
	Kết quả là toàn bộ quá trình thoát ngay lập tức mà không thực thi
	cuộc gọi hệ thống.  Trạng thái thoát của tác vụ (ZZ0001ZZ)
	sẽ là ZZ0002ZZ, không phải ZZ0003ZZ.

ZZ0000ZZ:
	Kết quả là tác vụ thoát ngay lập tức mà không thực hiện
	cuộc gọi hệ thống.  Trạng thái thoát của tác vụ (ZZ0001ZZ) sẽ
	là ZZ0002ZZ, không phải ZZ0003ZZ.

ZZ0000ZZ:
	Kết quả là hạt nhân gửi tín hiệu ZZ0001ZZ tới bộ kích hoạt
	nhiệm vụ mà không thực hiện cuộc gọi hệ thống. ZZ0002ZZ
	sẽ hiển thị địa chỉ của lệnh gọi hệ thống và
	ZZ0003ZZ và ZZ0004ZZ sẽ cho biết
	syscall đã được thử.  Bộ đếm chương trình sẽ như thể
	cuộc gọi tòa nhà đã xảy ra (tức là nó sẽ không trỏ đến cuộc gọi tòa nhà
	hướng dẫn).  Thanh ghi giá trị trả về sẽ chứa một Arch-
	giá trị phụ thuộc -- nếu tiếp tục thực thi, hãy đặt nó thành giá trị nào đó
	hợp lý.  (Sự phụ thuộc kiến trúc là do việc thay thế
	nó bằng ZZ0005ZZ có thể ghi đè một số thông tin hữu ích.)

Phần ZZ0000ZZ của giá trị trả về sẽ được chuyển
	như ZZ0001ZZ.

ZZ0000ZZ được kích hoạt bởi seccomp sẽ có si_code là ZZ0001ZZ.

ZZ0000ZZ:
	Kết quả là 16 bit thấp hơn của giá trị trả về được chuyển
	đến vùng người dùng là lỗi mà không thực hiện lệnh gọi hệ thống.

ZZ0000ZZ:
	Kết quả là một tin nhắn ZZ0001ZZ được gửi trên không gian người dùng
	thông báo fd, nếu nó được đính kèm hoặc ZZ0002ZZ nếu không. Xem
	bên dưới về cuộc thảo luận về cách xử lý thông báo của người dùng.

ZZ0000ZZ:
	Khi được trả về, giá trị này sẽ khiến kernel cố gắng
	thông báo cho trình theo dõi dựa trên ZZ0001ZZ trước khi thực thi hệ thống
	gọi.  Nếu không có chất đánh dấu, ZZ0002ZZ sẽ được trả về
	vùng người dùng và lệnh gọi hệ thống không được thực thi.

Người theo dõi sẽ được thông báo nếu nó yêu cầu ZZ0000ZZ
	sử dụng ZZ0001ZZ.  Người theo dõi sẽ được thông báo
	của phần ZZ0002ZZ và phần ZZ0003ZZ của
	giá trị trả về của chương trình BPF sẽ có sẵn cho người theo dõi
	thông qua ZZ0004ZZ.

Người theo dõi có thể bỏ qua cuộc gọi hệ thống bằng cách thay đổi số cuộc gọi hệ thống
	đến -1.  Ngoài ra, trình theo dõi có thể thay đổi lệnh gọi hệ thống
	được yêu cầu bằng cách thay đổi lệnh gọi hệ thống thành số hệ thống hợp lệ.  Nếu
	người theo dõi yêu cầu bỏ qua cuộc gọi hệ thống, sau đó cuộc gọi hệ thống sẽ
	dường như trả về giá trị mà trình theo dõi đặt vào giá trị trả về
	đăng ký.

Kiểm tra seccomp sẽ không được chạy lại sau khi trình theo dõi được thực hiện
	được thông báo.  (Điều này có nghĩa là hộp cát dựa trên seccomp MUST NOT
	cho phép sử dụng ptrace, ngay cả các quy trình đóng hộp cát khác mà không cần
	cực kỳ cẩn thận; Ptracer có thể sử dụng cơ chế này để trốn thoát.)

ZZ0000ZZ:
	Kết quả là lệnh gọi hệ thống được thực thi sau khi được ghi lại. Cái này
	nên được các nhà phát triển ứng dụng sử dụng để tìm hiểu hệ thống nào của họ
	nhu cầu ứng dụng mà không cần phải lặp qua nhiều thử nghiệm và
	chu kỳ phát triển để xây dựng danh sách.

Hành động này sẽ chỉ được ghi lại nếu "log" có trong
	chuỗi sysctl actions_logged.

ZZ0000ZZ:
	Kết quả là cuộc gọi hệ thống được thực thi.

Nếu có nhiều bộ lọc tồn tại, giá trị trả về cho việc đánh giá một
cuộc gọi hệ thống nhất định sẽ luôn sử dụng giá trị tiền lệ cao nhất.

Ưu tiên chỉ được xác định bằng cách sử dụng mặt nạ ZZ0000ZZ.  Khi nào
nhiều bộ lọc trả về các giá trị có cùng mức độ ưu tiên, chỉ có
ZZ0001ZZ từ bộ lọc được cài đặt gần đây nhất sẽ
đã quay trở lại.

cạm bẫy
========

Cạm bẫy lớn nhất cần tránh trong quá trình sử dụng là lọc lệnh gọi hệ thống
number mà không kiểm tra giá trị kiến trúc.  Tại sao?  Trên bất kỳ
kiến trúc hỗ trợ nhiều quy ước gọi lệnh gọi hệ thống,
số cuộc gọi hệ thống có thể thay đổi dựa trên lệnh gọi cụ thể.  Nếu
các số trong các quy ước gọi khác nhau chồng lên nhau, sau đó kiểm tra
các bộ lọc có thể bị lạm dụng.  Luôn kiểm tra giá trị vòm!

Ví dụ
=======

Thư mục ZZ0000ZZ chứa cả ví dụ dành riêng cho x86
và một ví dụ chung hơn về giao diện macro cấp cao hơn cho BPF
việc tạo chương trình.

Thông báo không gian người dùng
======================

Mã trả về ZZ0000ZZ cho phép các bộ lọc seccomp vượt qua
syscall cụ thể đến không gian người dùng sẽ được xử lý. Điều này có thể hữu ích cho
các ứng dụng như trình quản lý vùng chứa, muốn chặn các thông tin cụ thể
syscalls (ZZ0001ZZ, ZZ0002ZZ, v.v.) và thay đổi hành vi của chúng.

Để nhận được FD thông báo, hãy sử dụng ZZ0000ZZ
đối số cho tòa nhà cao tầng ZZ0001ZZ:

.. code-block:: c

    fd = seccomp(SECCOMP_SET_MODE_FILTER, SECCOMP_FILTER_FLAG_NEW_LISTENER, &prog);

cái nào (nếu thành công) sẽ trả về một fd người nghe cho bộ lọc, sau đó có thể
được chuyển qua ZZ0000ZZ hoặc tương tự. Lưu ý rằng bộ lọc fds tương ứng với
một bộ lọc cụ thể chứ không phải một nhiệm vụ cụ thể. Vì vậy, nếu nhiệm vụ này phân nhánh,
thông báo từ cả hai tác vụ sẽ xuất hiện trên cùng một bộ lọc fd. Đọc và
việc ghi vào/từ bộ lọc fd cũng được đồng bộ hóa, do đó bộ lọc fd có thể an toàn
có nhiều độc giả.

Giao diện cho fd thông báo seccomp bao gồm hai cấu trúc:

.. code-block:: c

    struct seccomp_notif_sizes {
        __u16 seccomp_notif;
        __u16 seccomp_notif_resp;
        __u16 seccomp_data;
    };

    struct seccomp_notif {
        __u64 id;
        __u32 pid;
        __u32 flags;
        struct seccomp_data data;
    };

    struct seccomp_notif_resp {
        __u64 id;
        __s64 val;
        __s32 error;
        __u32 flags;
    };

Cấu trúc ZZ0000ZZ có thể được sử dụng để xác định kích thước
của các cấu trúc khác nhau được sử dụng trong thông báo seccomp. Kích thước của ZZ0001ZZ có thể thay đổi trong tương lai, vì vậy mã nên sử dụng:

.. code-block:: c

    struct seccomp_notif_sizes sizes;
    seccomp(SECCOMP_GET_NOTIF_SIZES, 0, &sizes);

để xác định kích thước của các cấu trúc khác nhau để phân bổ. Xem
samples/seccomp/user-trap.c làm ví dụ.

Người dùng có thể đọc qua ZZ0000ZZ (hoặc ZZ0001ZZ) trên
seccomp thông báo fd để nhận ZZ0002ZZ, chứa
năm thành viên: độ dài đầu vào của cấu trúc, ZZ0003ZZ cho mỗi bộ lọc duy nhất,
ZZ0004ZZ của tác vụ đã kích hoạt yêu cầu này (có thể là 0 nếu
tác vụ nằm trong pid ns không hiển thị từ không gian tên pid của người nghe). các
thông báo cũng chứa ZZ0005ZZ được chuyển tới seccomp và cờ bộ lọc.
Cấu trúc phải được loại bỏ trước khi gọi ioctl.

Sau đó, không gian người dùng có thể đưa ra quyết định dựa trên thông tin này về những việc cần làm,
và ZZ0000ZZ một phản hồi, cho biết điều gì sẽ xảy ra
được trả về không gian người dùng. Thành viên ZZ0001ZZ của ZZ0002ZZ nên
giống ZZ0003ZZ như trong ZZ0004ZZ.

Không gian người dùng cũng có thể thêm bộ mô tả tệp vào quy trình thông báo thông qua
ZZ0000ZZ. Thành viên ZZ0001ZZ của
ZZ0002ZZ phải giống ZZ0003ZZ như trong
ZZ0004ZZ. Cờ ZZ0005ZZ có thể được sử dụng để đặt cờ
như O_CLOEXEC trên phần mô tả tệp trong quá trình thông báo. Nếu người giám sát
muốn đưa vào bộ mô tả tập tin một số cụ thể,
Có thể sử dụng cờ ZZ0006ZZ và đặt thành viên ZZ0007ZZ thành
số cụ thể để sử dụng. Nếu bộ mô tả tập tin đó đã được mở trong
quá trình thông báo nó sẽ được thay thế. Người giám sát cũng có thể thêm một FD, và
phản hồi nguyên tử bằng cách sử dụng cờ ZZ0008ZZ và trả về
giá trị sẽ là số mô tả tệp được chèn.

Quá trình thông báo có thể được ưu tiên trước, dẫn đến việc thông báo bị
bị hủy bỏ. Điều này có thể trở thành vấn đề khi cố gắng thực hiện các hành động thay mặt cho
quá trình thông báo chạy dài và thường có thể thử lại được (gắn một
hệ thống tập tin). Ngoài ra, tại thời điểm lắp đặt bộ lọc,
Cờ ZZ0000ZZ có thể được đặt. Lá cờ này làm cho nó
sao cho khi người giám sát nhận được thông báo của người dùng, thông báo
quá trình sẽ bỏ qua các tín hiệu không nghiêm trọng cho đến khi phản hồi được gửi. Tín hiệu rằng
được gửi trước khi không gian người dùng nhận được thông báo sẽ được xử lý
bình thường.

Điều đáng chú ý là ZZ0000ZZ chứa các giá trị của thanh ghi
đối số cho syscall, nhưng không chứa con trỏ tới bộ nhớ. Nhiệm vụ của
bộ nhớ có thể truy cập được theo dấu vết đặc quyền phù hợp thông qua ZZ0001ZZ hoặc
ZZ0002ZZ. Tuy nhiên, cần lưu ý tránh TOCTOU được đề cập
ở trên trong tài liệu này: tất cả các đối số được đọc từ bộ nhớ của người theo dõi
nên được đọc vào bộ nhớ của thiết bị theo dõi trước khi đưa ra bất kỳ quyết định chính sách nào.
Điều này cho phép đưa ra quyết định nguyên tử về các đối số syscall.

hệ thống
=======

Các tập tin sysctl của Seccomp có thể được tìm thấy trong ZZ0000ZZ
thư mục. Đây là mô tả của từng tệp trong thư mục đó:

ZZ0000ZZ:
	Danh sách có thứ tự chỉ đọc các giá trị trả về seccomp (tham khảo phần
	Các macro ZZ0001ZZ ở trên) ở dạng chuỗi. Việc đặt hàng, từ
	từ trái sang phải, là giá trị trả về ít được phép nhất đối với nhiều nhất
	giá trị trả về cho phép.

Danh sách đại diện cho tập hợp các giá trị trả về seccomp được hỗ trợ
	bởi hạt nhân. Một chương trình không gian người dùng có thể sử dụng danh sách này để
	xác định xem các hành động được tìm thấy trong ZZ0000ZZ, khi
	chương trình được xây dựng, khác với tập hợp các hành động thực tế
	được hỗ trợ trong kernel đang chạy hiện tại.

ZZ0000ZZ:
	Danh sách các giá trị trả về seccomp theo thứ tự đọc-ghi (tham khảo phần
	ZZ0001ZZ macro ở trên) được phép ghi lại. viết
	vào tệp không cần phải ở dạng có thứ tự mà đọc từ tệp
	sẽ được sắp xếp theo cách tương tự như sysctl actions_avail.

Chuỗi ZZ0000ZZ không được chấp nhận trong hệ thống ZZ0001ZZ
	vì không thể ghi lại các hành động ZZ0002ZZ. Đang cố gắng
	để ghi ZZ0003ZZ vào sysctl sẽ dẫn đến EINVAL
	đã quay trở lại.

Thêm hỗ trợ kiến ​​trúc
===========================

Xem ZZ0000ZZ để biết các yêu cầu chính thức.  Nói chung, nếu một
kiến trúc hỗ trợ cả ptrace_event và seccomp, nó sẽ có thể
hỗ trợ bộ lọc seccomp với bản sửa lỗi nhỏ: Hỗ trợ ZZ0001ZZ và trả lại seccomp
kiểm tra giá trị.  Sau đó chỉ cần thêm ZZ0002ZZ
đến Kconfig dành riêng cho Arch của nó.



Hãy cẩn thận
=======

vDSO có thể khiến một số lệnh gọi hệ thống chạy hoàn toàn trong không gian người dùng,
dẫn đến những bất ngờ khi bạn chạy các chương trình trên các máy khác nhau mà
quay trở lại với các cuộc gọi chung thực sự.  Để giảm thiểu những bất ngờ này trên x86, hãy thực hiện
chắc chắn bạn kiểm tra với
ZZ0000ZZ được đặt thành
giống như ZZ0001ZZ.

Trên x86-64, mô phỏng vsyscall được bật theo mặc định.  (vsyscalls là
các biến thể cũ của cuộc gọi vDSO.) Hiện tại, vsyscalls được mô phỏng sẽ
tôn vinh seccomp, với một vài điều kỳ lạ:

- Giá trị trả về của ZZ0000ZZ sẽ đặt ZZ0001ZZ trỏ tới
  mục nhập vsyscall cho cuộc gọi đã cho chứ không phải địa chỉ sau
  hướng dẫn 'syscall'.  Bất kỳ mã nào muốn bắt đầu lại cuộc gọi
  cần lưu ý rằng (a) lệnh ret đã được mô phỏng và (b)
  cố gắng tiếp tục syscall sẽ lại kích hoạt vsyscall tiêu chuẩn
  kiểm tra bảo mật mô phỏng, chủ yếu khiến việc tiếp tục cuộc gọi hệ thống
  vô nghĩa.

- Giá trị trả về là ZZ0000ZZ sẽ báo hiệu cho bộ theo dõi như bình thường,
  nhưng cuộc gọi hệ thống có thể không được thay đổi thành cuộc gọi hệ thống khác bằng cách sử dụng
  đăng ký orig_rax. Nó chỉ có thể được thay đổi thành -1 để bỏ qua
  cuộc gọi hiện được mô phỏng. Bất kỳ thay đổi nào khác MAY sẽ chấm dứt quá trình.
  Giá trị rip mà trình theo dõi nhìn thấy sẽ là địa chỉ mục nhập tòa nhà;
  điều này khác với hành vi bình thường.  Bộ theo dõi MUST NOT sửa đổi
  rip hoặc rsp.  (Đừng dựa vào những thay đổi khác để chấm dứt quá trình.
  Họ có thể làm việc.  Ví dụ: trên một số hạt nhân, việc chọn một cuộc gọi hệ thống
  chỉ tồn tại trong các hạt nhân trong tương lai sẽ được mô phỏng chính xác (bằng
  trả lại ZZ0001ZZ).

Để phát hiện hành vi kỳ quặc này, hãy kiểm tra ZZ0000ZZ.  (Đối với ZZ0001ZZ, hãy sử dụng rip. Đối với
ZZ0002ZZ, sử dụng ZZ0003ZZ.) Không kiểm tra bất kỳ mục nào khác
điều kiện: các hạt nhân trong tương lai có thể cải thiện việc mô phỏng vsyscall và hiện tại
hạt nhân ở chế độ vsyscall=native sẽ hoạt động khác nhau, nhưng
hướng dẫn tại ZZ0004ZZ sẽ không phải là cuộc gọi hệ thống trong các
trường hợp.

Lưu ý rằng các hệ thống hiện đại dường như không sử dụng vsyscalls -- chúng
là một tính năng cũ và chúng chậm hơn đáng kể so với tiêu chuẩn
syscalls.  Mã mới sẽ sử dụng vDSO và các cuộc gọi hệ thống do vDSO phát hành
không thể phân biệt được với các cuộc gọi hệ thống thông thường.
