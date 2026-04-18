.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/pnfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
Đếm tham chiếu trong pnfs
==========================

Có một số bộ đệm liên quan đến nhau.  Chúng tôi có bố cục có thể
tham chiếu nhiều thiết bị, mỗi thiết bị có thể tham chiếu nhiều máy chủ dữ liệu.
Mỗi máy chủ dữ liệu có thể được tham chiếu bởi nhiều thiết bị.  Mỗi thiết bị
có thể được tham chiếu bởi nhiều bố cục. Để giữ tất cả những điều này thẳng thắn,
chúng ta cần tham khảo số lượng.


cấu trúc pnfs_layout_hdr
======================

Lệnh trực tuyến LAYOUTGET tương ứng với struct
pnfs_layout_segment, thường được gọi bằng tên biến lseg.
Mỗi nfs_inode có thể chứa một con trỏ tới bộ đệm của các bố cục này
các phân đoạn trong nfsi->layout, thuộc loại struct pnfs_layout_hdr.

Chúng tôi tham chiếu tiêu đề cho nút trỏ tới nó, trên mỗi
gọi RPC nổi bật tham chiếu đến nó (LAYOUTGET, LAYOUTRETURN,
LAYOUTCOMMIT) và cho mỗi lseg được giữ bên trong.

Mỗi tiêu đề cũng được (khi không trống) được đưa vào danh sách liên kết với
cấu trúc nfs_client (cl_layouts).  Được đưa vào danh sách này không va chạm
số lượng tham chiếu, vì bố cục được giữ bởi lseg
giữ nó trong danh sách.

deviceid_cache
==============

Id thiết bị tham chiếu lsegs, được phân giải theo nfs_client và
kiểu trình điều khiển bố trí.  Id thiết bị được giữ trong bộ đệm RCU (struct
nfs4_deviceid_cache).  Bản thân bộ đệm được tham chiếu qua mỗi
gắn kết.  Bản thân các mục (struct nfs4_deviceid) được giữ trên
thời gian tồn tại của mỗi lseg tham chiếu đến chúng.

RCU được sử dụng vì về cơ bản, deviceid là viết một lần, đọc nhiều
cấu trúc dữ liệu.  Kích thước hlist của 32 thùng cần tốt hơn
biện minh, nhưng có vẻ hợp lý vì chúng ta có thể có nhiều
deviceid trên mỗi hệ thống tệp và nhiều hệ thống tệp trên mỗi nfs_client.

Mã băm được sao chép từ cơ sở mã nfsd.  Một cuộc thảo luận về
băm và các biến thể của thuật toán này có thể được tìm thấy ZZ0000ZZ

bộ đệm máy chủ dữ liệu
=================

thiết bị trình điều khiển tệp đề cập đến các máy chủ dữ liệu, được lưu giữ trong một mô-đun
bộ nhớ đệm cấp độ.  Tham chiếu của nó được giữ trong suốt thời gian tồn tại của deviceid
chỉ vào nó.

lseg
====

lseg duy trì một tham chiếu bổ sung tương ứng với NFS_LSEG_VALID
bit giữ nó trong danh sách của pnfs_layout_hdr.  Khi lseg cuối cùng
bị xóa khỏi danh sách của pnfs_layout_hdr, NFS_LAYOUT_DESTROYED
bit được thiết lập, ngăn không cho bất kỳ lseg mới nào được thêm vào.

trình điều khiển bố trí
==============

PNFS sử dụng cái được gọi là trình điều khiển bố cục. STD xác định 4 cơ bản
các loại bố cục: "tệp", "đối tượng", "khối" và "tệp linh hoạt". Đối với mỗi
trong số các loại này có một trình điều khiển bố cục có các vectơ chức năng chung
bảng được gọi bởi nfs-client pnfs-core để triển khai
các kiểu bố cục khác nhau.

Mã trình điều khiển bố cục tệp nằm trong thư mục fs/nfs/filelayout/..
Mã trình điều khiển bố cục khối nằm trong thư mục fs/nfs/blocklayout/..
Mã trình điều khiển bố cục Flexfiles nằm trong: thư mục fs/nfs/flexfilelayout/..

thiết lập bố cục khối
===================

TODO: Ghi lại nhu cầu thiết lập của trình điều khiển bố cục khối
