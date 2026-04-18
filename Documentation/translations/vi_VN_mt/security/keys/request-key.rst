.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/keys/request-key.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Dịch vụ yêu cầu khóa
===================

Dịch vụ yêu cầu khóa là một phần của dịch vụ lưu giữ khóa (tham khảo
Tài liệu/bảo mật/khóa/core.rst).  Tài liệu này giải thích đầy đủ hơn về cách
thuật toán yêu cầu hoạt động.

Quá trình bắt đầu bằng cách kernel yêu cầu dịch vụ bằng cách gọi
ZZ0000ZZ::

khóa cấu trúc *request_key(const struct key_type *type,
				const char * mô tả,
				const char *callout_info);

hoặc::

khóa cấu trúc *request_key_tag(const struct key_type *type,
				    const char * mô tả,
				    const cấu trúc key_tag *domain_tag,
				    const char *callout_info);

hoặc::

khóa cấu trúc *request_key_with_auxdata(const struct key_type *type,
					     const char * mô tả,
					     const cấu trúc key_tag *domain_tag,
					     const char *callout_info,
					     size_t callout_len,
					     vô hiệu *aux);

hoặc::

khóa cấu trúc *request_key_rcu(const struct key_type *type,
				    const char * mô tả,
				    const struct key_tag *domain_tag);

Hoặc bằng không gian người dùng gọi lệnh gọi hệ thống request_key ::

key_serial_t request_key(const char *type,
				 const char * mô tả,
				 const char *callout_info,
				 key_serial_t dest_keyring);

Sự khác biệt chính giữa các điểm truy cập là giao diện trong kernel
không cần liên kết chìa khóa với móc khóa để tránh bị khóa ngay lập tức
bị phá hủy.  Giao diện kernel trả về một con trỏ trực tiếp tới khóa và
việc hủy chìa khóa là tùy thuộc vào người gọi.

Lệnh gọi request_key_tag() giống như lệnh request_key() trong kernel, ngoại trừ việc nó
cũng có một thẻ miền cho phép phân tách các khóa bằng không gian tên và
bị giết theo nhóm.

Lệnh gọi request_key_with_auxdata() giống như lệnh gọi request_key_tag(), ngoại trừ
rằng họ cho phép dữ liệu phụ trợ được chuyển đến người gọi lên (mặc định là
NULL).  Điều này chỉ hữu ích cho những loại khóa xác định cuộc gọi nâng cấp của riêng chúng
cơ chế thay vì sử dụng /sbin/request-key.

Lệnh gọi request_key_rcu() giống như lệnh gọi request_key_tag(), ngoại trừ việc nó
không kiểm tra các khóa đang được xây dựng và không cố gắng
xây dựng các khóa bị thiếu.

Giao diện không gian người dùng liên kết khóa với một chuỗi khóa liên quan đến quy trình
để ngăn chìa khóa biến mất và trả lại số sê-ri của chìa khóa cho
người gọi.


Ví dụ sau giả định rằng các loại khóa liên quan không xác định
cơ chế upcall riêng.  Nếu có thì những thứ đó sẽ được thay thế cho
phân nhánh và thực thi /sbin/request-key.


Quy trình
===========

Một yêu cầu được tiến hành theo cách sau:

1) Quy trình A gọi request_key() [tòa nhà không gian người dùng gọi kernel
     giao diện].

2) request_key() tìm kiếm các chuỗi khóa đã đăng ký của quy trình để xem liệu có
     một chìa khóa phù hợp ở đó.  Nếu có, nó sẽ trả về chìa khóa.  Nếu không có,
     và callout_info không được đặt thì sẽ trả về lỗi.  Nếu không thì quá trình
     tiến tới bước tiếp theo.

3) request_key() thấy A chưa có khóa mong muốn nên tạo
     hai điều:

a) Khóa U chưa được khởi tạo của loại và mô tả được yêu cầu.

b) Khóa ủy quyền V tham chiếu đến khóa U và ghi chú rằng quá trình A
     	 là bối cảnh trong đó khóa U phải được khởi tạo và bảo mật, và
     	 từ đó các yêu cầu chính liên quan có thể được đáp ứng.

4) request_key() sau đó phân nhánh và thực thi /sbin/request-key với một phiên mới
     khóa có chứa liên kết đến khóa xác thực V.

5) /sbin/request-key đảm nhận quyền liên quan đến khóa U.

6) /sbin/request-key thực thi một chương trình thích hợp để thực hiện thao tác thực tế
     khởi tạo.

7) Chương trình có thể muốn truy cập một khóa khác từ ngữ cảnh của A (ví dụ:
     Khóa Kerberos TGT).  Nó chỉ yêu cầu khóa thích hợp và chuỗi khóa
     tìm kiếm lưu ý rằng khóa phiên có khóa xác thực V ở cấp độ dưới cùng.

Điều này sẽ cho phép nó tìm kiếm các chuỗi khóa của quy trình A bằng
     UID, GID, nhóm và thông tin bảo mật của quy trình A như thể đó là quy trình A,
     và tìm ra phím W.

8) Sau đó, chương trình sẽ thực hiện những gì cần thiết để lấy dữ liệu để
     khởi tạo khóa U, sử dụng khóa W làm tham chiếu (có lẽ nó liên lạc với một
     Máy chủ Kerberos sử dụng TGT) rồi khởi tạo khóa U.

9) Khi khởi tạo khóa U, khóa xác thực V sẽ tự động bị thu hồi để nó
     có thể không được sử dụng lại.

10) Chương trình sau đó thoát 0 và request_key() xóa khóa V và trả về khóa
      U cho người gọi.

Điều này còn mở rộng hơn nữa.  Nếu phím W (bước 7 ở trên) không tồn tại, phím W sẽ
được tạo mà không được khởi tạo, một khóa xác thực khác (X) sẽ được tạo (theo bước
3) và một bản sao khác của /sbin/request-key được sinh ra (theo bước 4); nhưng
bối cảnh được chỉ định bởi khóa xác thực X sẽ vẫn là quy trình A, giống như trong khóa xác thực
V.

Điều này là do dây móc khóa của quy trình A không thể được gắn vào
/sbin/request-key ở những vị trí thích hợp vì (a) execve sẽ loại bỏ hai
trong số chúng và (b) nó yêu cầu cùng một UID/GID/Groups xuyên suốt.


Sự khởi tạo và từ chối tiêu cực
====================================

Thay vì khởi tạo một khóa, người sở hữu khóa có thể
khóa ủy quyền để khởi tạo tiêu cực một khóa đang được xây dựng.
Đây là một trình giữ chỗ có thời lượng ngắn gây ra bất kỳ nỗ lực nào trong việc yêu cầu lại
khóa trong khi nó tồn tại không thành công với lỗi ENOKEY nếu bị phủ định hoặc được chỉ định
lỗi nếu bị từ chối.

Điều này được cung cấp để ngăn chặn việc lặp đi lặp lại quá nhiều /sbin/request-key
xử lý một khóa mà sẽ không bao giờ có thể lấy được.

Quá trình /sbin/request-key có nên thoát khỏi giá trị khác 0 hoặc chết trên một
tín hiệu, chìa khóa đang được xây dựng sẽ tự động âm
được khởi tạo trong một khoảng thời gian ngắn.


Thuật toán tìm kiếm
====================

Việc tìm kiếm bất kỳ móc khóa cụ thể nào sẽ được tiến hành theo cách sau:

1) Khi mã quản lý khóa tìm kiếm khóa (keyring_search_rcu), nó
     trước tiên hãy gọi key_permission(SEARCH) trên khóa mà nó bắt đầu bằng,
     nếu điều này từ chối sự cho phép, nó sẽ không tìm kiếm thêm.

2) Nó xem xét tất cả các phím không tạo khóa trong vòng khóa đó và, nếu có bất kỳ khóa nào
     khớp với tiêu chí đã chỉ định, gọi key_permission(SEARCH) trên đó để xem
     nếu chìa khóa được phép tìm thấy.  Nếu đúng như vậy, khóa đó sẽ được trả về; nếu
     không, việc tìm kiếm vẫn tiếp tục và mã lỗi được giữ lại nếu giá trị cao hơn
     ưu tiên hơn mức hiện được đặt.

3) Sau đó, nó sẽ xem xét tất cả các phím kiểu vòng khóa trong chuỗi khóa hiện tại
     đang tìm kiếm.  Nó gọi key_permission(SEARCH) trên mỗi lần bấm khóa và nếu điều này
     cấp quyền, nó lặp lại, thực hiện các bước (2) và (3) trên đó
     móc khóa.

Quá trình dừng ngay lập tức khi tìm thấy khóa hợp lệ với quyền được cấp cho
sử dụng nó.  Bất kỳ lỗi nào từ lần so khớp trước đó sẽ bị loại bỏ và khóa sẽ được
đã quay trở lại.

Khi request_key() được gọi, nếu CONFIG_KEYS_REQUEST_CACHE=y, mỗi tác vụ
bộ nhớ đệm một phím lần đầu tiên được kiểm tra xem có khớp không.

Khi search_process_keyrings() được gọi, nó sẽ thực hiện các tìm kiếm sau
cho đến khi thành công:

1) Nếu còn tồn tại, chuỗi khóa của quy trình sẽ được tìm kiếm.

2) Nếu còn tồn tại, khóa quy trình của quy trình sẽ được tìm kiếm.

3) Khóa phiên của quy trình được tìm kiếm.

4) Nếu quy trình đã đảm nhận quyền được liên kết với request_key()
     khóa ủy quyền sau đó:

a) Nếu còn tồn tại, chuỗi khóa của quá trình gọi sẽ được tìm kiếm.

b) Nếu còn tồn tại, khóa quy trình của quá trình gọi sẽ được tìm kiếm.

c) Khóa phiên của quá trình gọi được tìm kiếm.

Thời điểm thành công, tất cả các lỗi đang chờ xử lý sẽ bị loại bỏ và khóa tìm thấy sẽ được
đã quay trở lại.  Nếu CONFIG_KEYS_REQUEST_CACHE=y thì khóa đó được đặt trong
bộ đệm cho mỗi tác vụ, thay thế khóa trước đó.  Bộ nhớ đệm sẽ bị xóa khi thoát hoặc
ngay trước khi nối lại không gian người dùng.

Chỉ khi tất cả những điều này thất bại thì toàn bộ sự việc mới thất bại với mức độ ưu tiên cao nhất
lỗi.  Lưu ý rằng một số lỗi có thể đến từ LSM.

Mức độ ưu tiên của lỗi là::

EKEYREVOKED > EKEYEXPIRED > ENOKEY

EACCES/EPERM chỉ được trả về khi tìm kiếm trực tiếp một chuỗi khóa cụ thể trong đó
khóa cơ bản không cấp quyền Tìm kiếm.
