.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/fiemap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Fiemap Ioctl
=============

Fiemap ioctl là một phương pháp hiệu quả để không gian người dùng lấy tệp
ánh xạ phạm vi. Thay vì ánh xạ theo từng khối (chẳng hạn như bmap), fiemap
trả về một danh sách các phạm vi.


Yêu cầu thông tin cơ bản
------------------------

Yêu cầu fiemap được mã hóa trong struct fiemap:

.. kernel-doc:: include/uapi/linux/fiemap.h
   :identifiers: fiemap

fm_start và fm_length chỉ định phạm vi logic trong tệp
mà quá trình muốn ánh xạ. Mức độ trả về gương
những thứ trên đĩa - nghĩa là phần bù logic của phạm vi được trả về đầu tiên
có thể bắt đầu trước fm_start và phạm vi được trả về cuối cùng
phạm vi có thể kết thúc sau fm_length. Tất cả độ lệch và độ dài đều tính bằng byte.

Một số cờ nhất định để sửa đổi cách ánh xạ được tra cứu có thể được
đặt trong fm_flags. Nếu kernel không hiểu một số điều cụ thể
cờ, nó sẽ trả về EBADR và nội dung của fm_flags sẽ chứa
tập hợp các cờ gây ra lỗi. Nếu kernel tương thích
với tất cả các cờ đã được thông qua, nội dung của fm_flags sẽ không bị sửa đổi.
Tùy thuộc vào không gian người dùng để xác định xem có từ chối một thông tin cụ thể hay không
cờ gây tử vong cho hoạt động của nó. Sơ đồ này nhằm mục đích cho phép các
giao diện fiemap sẽ phát triển trong tương lai nhưng không mất đi
khả năng tương thích với phần mềm cũ.

fm_extent_count chỉ định số phần tử trong mảng fm_extents[]
có thể được sử dụng để trả về phạm vi.  Nếu fm_extent_count bằng 0 thì
mảng fm_extents[] bị bỏ qua (sẽ không có phạm vi nào được trả về) và
số lượng fm_mapped_extents sẽ chứa số lượng phạm vi cần thiết trong
fm_extents[] để giữ ánh xạ hiện tại của tệp.  Lưu ý rằng có
không có gì ngăn cản việc thay đổi tệp giữa các lệnh gọi tới FIEMAP.

Các cờ sau có thể được đặt trong fm_flags:

FIEMAP_FLAG_SYNC
  Nếu cờ này được đặt, kernel sẽ đồng bộ hóa tệp trước khi ánh xạ phạm vi.

FIEMAP_FLAG_XATTR
  Nếu cờ này được đặt, phạm vi được trả về sẽ mô tả các nút
  cây tra cứu thuộc tính mở rộng, thay vì cây dữ liệu của nó.

FIEMAP_FLAG_CACHE
  Cờ này yêu cầu bộ nhớ đệm của phạm vi.

Ánh xạ phạm vi
--------------

Thông tin mức độ được trả về trong mảng fm_extents được nhúng
không gian người dùng nào phải phân bổ cùng với cấu trúc fiemap. các
số phần tử trong mảng fiemap_extents[] phải được chuyển qua
fm_extent_count. Số lượng phạm vi được ánh xạ bởi kernel sẽ là
được trả về qua fm_mapped_extents. Nếu số lượng fiemap_extents
được phân bổ ít hơn mức cần thiết để ánh xạ phạm vi được yêu cầu,
số phạm vi tối đa có thể được ánh xạ trong fm_extent[]
mảng sẽ được trả về và fm_mapped_extents sẽ bằng
fm_extent_count. Trong trường hợp đó, phạm vi cuối cùng trong mảng sẽ không
hoàn thành phạm vi được yêu cầu và sẽ không có FIEMAP_EXTENT_LAST
bộ cờ (xem phần tiếp theo về cờ phạm vi).

Mỗi phạm vi được mô tả bằng một cấu trúc fiemap_extent duy nhất như
được trả về trong fm_extents:

.. kernel-doc:: include/uapi/linux/fiemap.h
    :identifiers: fiemap_extent

Tất cả độ lệch và độ dài đều tính bằng byte và phản chiếu chúng trên đĩa.  Nó hợp lệ
để phần bù logic mở rộng bắt đầu trước yêu cầu hoặc logic của nó
chiều dài để kéo dài vượt quá yêu cầu.  Trừ khi FIEMAP_EXTENT_NOT_ALIGNED là
được trả về, fe_logic, fe_physical và fe_length sẽ được căn chỉnh theo
kích thước khối của hệ thống tập tin.  Ngoại trừ các phạm vi được gắn cờ là
FIEMAP_EXTENT_MERGED, các phạm vi liền kề sẽ không được hợp nhất.

Trường fe_flags chứa các cờ mô tả phạm vi được trả về.
Một lá cờ đặc biệt, FIEMAP_EXTENT_LAST luôn được đặt ở mức cuối cùng trong
tệp để quá trình thực hiện lệnh gọi fiemap có thể xác định khi nào không
có nhiều phạm vi hơn mà không cần phải gọi lại ioctl.

Một số cờ có chủ ý mơ hồ và sẽ luôn được đặt ở vị trí
sự hiện diện của các cờ cụ thể hơn. Bằng cách này, một chương trình đang tìm kiếm
một thuộc tính chung không cần phải biết tất cả các cờ hiện có và tương lai
hàm ý tính chất đó.

Ví dụ: nếu FIEMAP_EXTENT_DATA_INLINE hoặc FIEMAP_EXTENT_DATA_TAIL
được đặt, FIEMAP_EXTENT_NOT_ALIGNED cũng sẽ được đặt. Một chương trình đang tìm kiếm
đối với dữ liệu nội tuyến hoặc dữ liệu được đóng gói theo đuôi có thể nhập vào cờ cụ thể. Phần mềm
đơn giản là không quan tâm đến việc thử hoạt động trên các phạm vi không liên kết
tuy nhiên, chỉ có thể nhập vào FIEMAP_EXTENT_NOT_ALIGNED và không cần phải
lo lắng về tất cả các lá cờ hiện tại và tương lai có thể ngụ ý không được căn chỉnh
dữ liệu. Lưu ý rằng điều ngược lại không đúng - nó sẽ đúng cho
FIEMAP_EXTENT_NOT_ALIGNED xuất hiện một mình.

FIEMAP_EXTENT_LAST
  Đây thường là phạm vi cuối cùng trong tập tin. Một nỗ lực lập bản đồ trong quá khứ
  mức độ này có thể không trả lại gì. Một số triển khai đặt cờ này thành
  cho biết phạm vi này là phạm vi cuối cùng trong phạm vi được người dùng truy vấn
  (thông qua fiemap->fm_length).

FIEMAP_EXTENT_UNKNOWN
  Vị trí của phạm vi này hiện chưa được biết. Điều này có thể chỉ ra
  dữ liệu được lưu trữ trên một ổ đĩa không thể truy cập được hoặc không có bộ lưu trữ nào có
  đã được phân bổ cho tập tin chưa.

FIEMAP_EXTENT_DELALLOC
  Điều này cũng sẽ đặt FIEMAP_EXTENT_UNKNOWN.

Phân bổ bị trì hoãn - mặc dù có dữ liệu về phạm vi này nhưng nó
  vị trí thực tế chưa được phân bổ.

FIEMAP_EXTENT_ENCODED
  Phạm vi này không bao gồm các khối hệ thống tập tin đơn giản nhưng
  được mã hóa (ví dụ: được mã hóa hoặc nén).  Đọc dữ liệu trong này
  phạm vi thông qua I/O tới thiết bị khối sẽ có kết quả không xác định.

Lưu ý rằng ZZ0000ZZ chưa được xác định để thử cập nhật dữ liệu
tại chỗ bằng cách ghi vào vị trí được chỉ định mà không cần
hỗ trợ của hệ thống tập tin hoặc để truy cập dữ liệu bằng cách sử dụng
thông tin được trả về bởi giao diện FIEMAP trong khi hệ thống tập tin
được gắn kết.  Nói cách khác, ứng dụng người dùng chỉ có thể đọc
mở rộng dữ liệu qua I/O tới thiết bị khối trong khi hệ thống tập tin
chưa được gắn kết và chỉ khi cờ FIEMAP_EXTENT_ENCODED được
rõ ràng; ứng dụng người dùng không được thử đọc hoặc ghi vào
hệ thống tập tin thông qua thiết bị khối trong bất kỳ trường hợp nào khác.

FIEMAP_EXTENT_DATA_ENCRYPTED
  Điều này cũng sẽ đặt FIEMAP_EXTENT_ENCODED
  Dữ liệu trong phạm vi này đã được mã hóa bởi hệ thống tập tin.

FIEMAP_EXTENT_NOT_ALIGNED
  Độ lệch mức độ và độ dài không được đảm bảo được căn chỉnh theo khối.

FIEMAP_EXTENT_DATA_INLINE
  Điều này cũng sẽ đặt FIEMAP_EXTENT_NOT_ALIGNED
  Dữ liệu được đặt trong một khối dữ liệu meta.

FIEMAP_EXTENT_DATA_TAIL
  Điều này cũng sẽ đặt FIEMAP_EXTENT_NOT_ALIGNED
  Dữ liệu được đóng gói thành một khối với dữ liệu từ các tệp khác.

FIEMAP_EXTENT_UNWRITTEN
  Phạm vi bất thành văn - phạm vi được phân bổ nhưng dữ liệu của nó chưa được
  được khởi tạo.  Điều này cho biết dữ liệu của phạm vi sẽ hoàn toàn bằng 0 nếu được đọc
  thông qua hệ thống tập tin nhưng nội dung không được xác định nếu đọc trực tiếp từ
  thiết bị.

FIEMAP_EXTENT_MERGED
  Điều này sẽ được đặt khi một tệp không hỗ trợ phạm vi, tức là nó sử dụng một khối
  sơ đồ địa chỉ dựa trên  Kể từ khi trả lại một phạm vi cho mỗi khối trở lại
  không gian người dùng sẽ rất kém hiệu quả, kernel sẽ cố gắng hợp nhất hầu hết
  các khối liền kề thành 'phạm vi'.

FIEMAP_EXTENT_SHARED
  Cờ này được đặt để yêu cầu chia sẻ không gian với các tệp khác.

VFS -> Triển khai hệ thống tệp
---------------------------------

Các hệ thống tệp muốn hỗ trợ fiemap phải triển khai lệnh gọi lại ->fiemap trên
cấu trúc inode_operating của chúng. Cuộc gọi fs ->fiemap chịu trách nhiệm
xác định tập hợp các cờ fiemap được hỗ trợ và gọi hàm trợ giúp trên
mỗi phạm vi được phát hiện::

cấu trúc inode_operating {
       ...

int (ZZ0000ZZ, struct fiemap_extent_info *, u64 bắt đầu,
                     u64 len);

->fiemap được truyền vào struct fiemap_extent_info mô tả
yêu cầu bản đồ phim:

.. kernel-doc:: include/linux/fiemap.h
    :identifiers: fiemap_extent_info

Dự định là hệ thống tập tin không cần phải truy cập bất kỳ thứ gì trong số này
cấu trúc trực tiếp. Trình xử lý hệ thống tập tin phải chấp nhận các tín hiệu và trả về
EINTR khi nhận được tín hiệu nghiêm trọng.


Việc kiểm tra cờ phải được thực hiện khi bắt đầu lệnh gọi lại ->fiemap thông qua
người trợ giúp fiemap_prep()::

int fiemap_prep(struct inode *inode, struct fiemap_extent_info *fieinfo,
		  bắt đầu u64, u64 *len, u32 được hỗ trợ_flags);

Cấu trúc fieinfo phải được chuyển vào khi nhận được từ ioctl_fiemap(). các
tập hợp các cờ fiemap mà fs hiểu phải được chuyển qua fs_flags. Nếu
fiemap_prep tìm thấy cờ người dùng không hợp lệ, nó sẽ đặt các giá trị xấu vào
fieinfo->fi_flags và trả về -EBADR. Nếu hệ thống tệp nhận được -EBADR, từ
fiemap_prep(), nó sẽ thoát ngay lập tức và trả lại lỗi đó cho
ioctl_fiemap().  Ngoài ra, phạm vi được xác thực dựa trên hỗ trợ
kích thước tập tin tối đa.


Đối với mỗi phạm vi trong phạm vi yêu cầu, hệ thống tệp sẽ gọi
hàm trợ giúp, fiemap_fill_next_extent()::

int fiemap_fill_next_extent(struct fiemap_extent_info *thông tin, u64 logic,
			      u64 phys, u64 len, u32 flag, u32 dev);

fiemap_fill_next_extent() sẽ sử dụng các giá trị được truyền để điền vào
phạm vi miễn phí tiếp theo trong mảng fm_extents. Cờ phạm vi 'chung' sẽ
tự động được đặt từ các cờ cụ thể thay mặt cho tệp gọi
hệ thống để không gian người dùng API không bị hỏng.

fiemap_fill_next_extent() trả về 0 nếu thành công và 1 khi
mảng fm_extents do người dùng cung cấp đã đầy. Nếu gặp lỗi
trong khi sao chép phạm vi vào bộ nhớ người dùng, -EFAULT sẽ được trả về.