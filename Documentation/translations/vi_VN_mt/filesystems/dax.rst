.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/dax.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Truy cập trực tiếp cho các tập tin
==================================

Động lực
----------

Bộ đệm trang thường được sử dụng để đệm đọc và ghi vào tệp.
Nó cũng được sử dụng để cung cấp các trang được ánh xạ vào không gian người dùng
bằng một cuộc gọi tới mmap.

Đối với các thiết bị khối giống như bộ nhớ, các trang bộ đệm trang sẽ
bản sao không cần thiết của bộ nhớ gốc.  Mã ZZ0000ZZ loại bỏ
bản sao bổ sung bằng cách thực hiện đọc và ghi trực tiếp vào thiết bị lưu trữ.
Đối với ánh xạ tệp, thiết bị lưu trữ được ánh xạ trực tiếp vào không gian người dùng.


Cách sử dụng
------------

Nếu bạn có một thiết bị khối hỗ trợ ZZ0000ZZ, bạn có thể tạo một hệ thống tập tin
trên đó như thường lệ.  Mã ZZ0001ZZ hiện chỉ hỗ trợ các tệp có khối
kích thước bằng ZZ0002ZZ của kernel của bạn, vì vậy bạn có thể cần chỉ định một khối
kích thước khi tạo hệ thống tập tin.

Hiện tại có 5 hệ thống tập tin hỗ trợ ZZ0000ZZ: ext2, ext4, xfs, virtiofs và erofs.
Việc kích hoạt ZZ0001ZZ trên chúng là khác nhau.

Kích hoạt DAX trên ext2 và erofs
--------------------------------

Khi gắn hệ thống tập tin, hãy sử dụng tùy chọn ZZ0000ZZ trên dòng lệnh hoặc
thêm 'dax' vào các tùy chọn trong ZZ0001ZZ.  Điều này hoạt động để kích hoạt ZZ0003ZZ trên tất cả các tệp
trong hệ thống tập tin.  Nó tương đương với hành vi ZZ0002ZZ bên dưới.


Kích hoạt DAX trên xfs và ext4
------------------------------

Bản tóm tắt
-----------

1. Tồn tại cờ chế độ truy cập tệp trong kernel ZZ0000ZZ tương ứng với
    cờ statx ZZ0001ZZ.  Xem trang chủ về statx(2) để biết chi tiết
    về chế độ truy cập này.

2. Tồn tại một cờ liên tục ZZ0000ZZ có thể được áp dụng cho các hệ thống thông thường.
    tập tin và thư mục. Cờ tư vấn này có thể được đặt hoặc xóa bất cứ lúc nào
    thời gian, nhưng làm như vậy không ảnh hưởng ngay đến trạng thái ZZ0001ZZ.

3. Nếu cờ ZZ0000ZZ liên tục được đặt trên một thư mục, cờ này sẽ
    được kế thừa bởi tất cả các tập tin và thư mục con thông thường mà sau đó được
    được tạo trong thư mục này. Các tập tin và thư mục con tồn tại vào thời điểm đó
    cờ này được đặt hoặc xóa trên thư mục mẹ không bị sửa đổi bởi
    sự sửa đổi này của thư mục mẹ.

4. Tồn tại các tùy chọn gắn kết dax có thể ghi đè ZZ0000ZZ trong
    cài đặt cờ ZZ0001ZZ.  Với bộ lưu trữ cơ bản hỗ trợ ZZ0002ZZ,
    giữ sau:

ZZ0000ZZ có nghĩa là "theo dõi ZZ0001ZZ" và là mặc định.

ZZ0000ZZ có nghĩa là "không bao giờ đặt ZZ0001ZZ, bỏ qua ZZ0002ZZ."

ZZ0000ZZ có nghĩa là "luôn đặt ZZ0001ZZ bỏ qua ZZ0002ZZ."

ZZ0000ZZ là một tùy chọn cũ, là bí danh của ZZ0001ZZ.

    .. warning::

      The option ``-o dax`` may be removed in the future so ``-o dax=always`` is
      the preferred method for specifying this behavior.

    .. note::

      Modifications to and the inheritance behavior of `FS_XFLAG_DAX` remain
      the same even when the filesystem is mounted with a dax option.  However,
      in-core inode state (`S_DAX`) will be overridden until the filesystem is
      remounted with dax=inode and the inode is evicted from kernel memory.

5. Chính sách ZZ0000ZZ có thể được thay đổi thông qua:

a) Thiết lập thư mục mẹ ZZ0000ZZ nếu cần trước khi tải các tập tin
       đã tạo

b) Đặt tùy chọn gắn kết dax="foo" thích hợp

c) Thay đổi cờ ZZ0000ZZ trên các tệp thông thường hiện có và
       thư mục.  Điều này có những hạn chế và hạn chế về thời gian chạy
       được mô tả ở mục 6) dưới đây.

6. Khi thay đổi chính sách ZZ0000ZZ thông qua việc chuyển đổi ZZ0001ZZ liên tục
    cờ, thay đổi đối với các tệp thông thường hiện có sẽ không có hiệu lực cho đến khi
    các tập tin được đóng bởi tất cả các quy trình.


Chi tiết
--------

Có 2 cờ dax cho mỗi tệp.  Một là cài đặt inode liên tục (ZZ0000ZZ)
và cái còn lại là cờ dễ bay hơi cho biết trạng thái hoạt động của tính năng
(ZZ0001ZZ).

ZZ0000ZZ được bảo tồn trong hệ thống tập tin.  Cấu hình liên tục này
cài đặt có thể được đặt, xóa và/hoặc truy vấn bằng cách sử dụng ZZ0001ZZ[ZZ0002ZZ]ZZ0003ZZ ioctl
(xem ioctl_xfs_fsgetxattr(2)) hoặc một tiện ích như 'xfs_io'.

Các tập tin và thư mục mới tự động kế thừa ZZ0000ZZ từ
thư mục mẹ ZZ0002ZZ của họ.  Do đó, cài đặt ZZ0001ZZ ở
thời gian tạo thư mục có thể được sử dụng để thiết lập hành vi mặc định cho toàn bộ
cây con.

Để làm rõ tính kế thừa, đây là 3 ví dụ:

Ví dụ A:

.. code-block:: shell

  mkdir -p a/b/c
  xfs_io -c 'chattr +x' a
  mkdir a/b/c/d
  mkdir a/e

  ------[outcome]------

  dax: a,e
  no dax: b,c,d

Ví dụ B:

.. code-block:: shell

  mkdir a
  xfs_io -c 'chattr +x' a
  mkdir -p a/b/c/d

  ------[outcome]------

  dax: a,b,c,d
  no dax:

Ví dụ C:

.. code-block:: shell

  mkdir -p a/b/c
  xfs_io -c 'chattr +x' c
  mkdir a/b/c/d

  ------[outcome]------

  dax: c,d
  no dax: a,b

Trạng thái kích hoạt hiện tại (ZZ0000ZZ) được đặt khi một nút tệp được khởi tạo trong
bộ nhớ của kernel.  Nó được thiết lập dựa trên sự hỗ trợ phương tiện cơ bản,
giá trị của ZZ0001ZZ và tùy chọn gắn kết dax của hệ thống tập tin.

statx có thể được sử dụng để truy vấn ZZ0000ZZ.

.. note::

  That only regular files will ever have `S_DAX` set and therefore statx
  will never indicate that `S_DAX` is set on directories.

Việc đặt cờ ZZ0000ZZ (cụ thể hoặc thông qua kế thừa) xảy ra ngay cả khi
nếu phương tiện cơ bản không hỗ trợ dax và/hoặc hệ thống tập tin
ghi đè bằng tùy chọn gắn kết.


Kích hoạt DAX trên virtiofs
----------------------------
Ngữ nghĩa của DAX trên virtiofs về cơ bản tương đương với ngữ nghĩa trên ext4 và xfs,
ngoại trừ khi '-o dax=inode' được chỉ định, máy khách virtiofs sẽ đưa ra gợi ý
liệu DAX có được kích hoạt hay không từ máy chủ virtiofs thông qua giao thức FUSE,
thay vì cờ ZZ0000ZZ liên tục. Tức là liệu DAX có được
được kích hoạt hay không hoàn toàn được xác định bởi máy chủ virtiofs, trong khi virtiofs
bản thân máy chủ có thể triển khai các thuật toán khác nhau để đưa ra quyết định này, ví dụ: tùy theo
trên cờ ZZ0001ZZ liên tục trên máy chủ.

Nó vẫn được hỗ trợ để đặt hoặc xóa cờ ZZ0000ZZ liên tục bên trong
khách, nhưng không đảm bảo rằng DAX sẽ được bật hoặc tắt cho
tập tin tương ứng sau đó. Người dùng bên trong khách vẫn cần gọi statx(2) và
kiểm tra cờ statx ZZ0001ZZ để xem DAX có được bật cho tệp này không.


Mẹo triển khai dành cho người viết trình điều khiển khối
--------------------------------------------------------

Để hỗ trợ ZZ0000ZZ trong trình điều khiển khối của bạn, hãy triển khai 'direct_access'
chặn hoạt động của thiết bị.  Nó được sử dụng để dịch số ngành
(được biểu thị bằng đơn vị của các cung 512 byte) thành số khung trang (pfn)
xác định trang vật lý cho bộ nhớ.  Nó cũng trả về một
địa chỉ ảo kernel có thể được sử dụng để truy cập bộ nhớ.

Phương thức direct_access lấy tham số 'size' cho biết
số byte được yêu cầu.  Hàm sẽ trả về số
số byte có thể được truy cập liên tục ở phần bù đó.  Nó cũng có thể
trả về một lỗi âm nếu xảy ra lỗi.

Để hỗ trợ phương pháp này, bộ lưu trữ phải có khả năng truy cập byte bằng
CPU mọi lúc.  Nếu thiết bị của bạn sử dụng kỹ thuật phân trang để hiển thị
một lượng lớn bộ nhớ thông qua một cửa sổ nhỏ hơn thì bạn không thể
triển khai direct_access.  Tương tự, nếu thiết bị của bạn thỉnh thoảng có thể
dừng CPU trong thời gian dài, bạn cũng không nên cố gắng
triển khai direct_access.

Những thiết bị khối này có thể được sử dụng để lấy cảm hứng:
- pmem: Trình điều khiển bộ nhớ liên tục NVDIMM


Mẹo triển khai dành cho người viết hệ thống tập tin
---------------------------------------------------

Hỗ trợ hệ thống tập tin bao gồm:

* Thêm hỗ trợ để đánh dấu các nút là ZZ0004ZZ bằng cách đặt cờ ZZ0005ZZ trong
  i_flags
* Thực hiện các thao tác ->read_iter và ->write_iter sử dụng
  ZZ0000ZZ khi inode có cờ ZZ0006ZZ được đặt
* Triển khai thao tác tệp mmap cho các tệp ZZ0007ZZ để đặt
  Cờ ZZ0008ZZ và ZZ0009ZZ trên ZZ0010ZZ và đặt vm_ops thành
  bao gồm các trình xử lý lỗi, pmd_fault, page_mkwrite, pfn_mkwrite. Những cái này
  người xử lý có lẽ nên gọi ZZ0001ZZ chuyển
  kích thước lỗi thích hợp và hoạt động iomap.
* Gọi ZZ0002ZZ thông qua các hoạt động iomap thích hợp
  thay vì ZZ0003ZZ cho các tệp ZZ0011ZZ
* Đảm bảo có đủ khóa giữa các lần đọc, ghi,
  cắt ngắn và lỗi trang

Trình xử lý iomap để phân bổ các khối phải đảm bảo rằng các khối được phân bổ
được loại bỏ và chuyển đổi thành phạm vi bằng văn bản trước khi được trả về để tránh
hiển thị dữ liệu chưa được khởi tạo thông qua mmap.

Các hệ thống tập tin này có thể được sử dụng để lấy cảm hứng:

.. seealso::

  ext2: see Documentation/filesystems/ext2.rst

.. seealso::

  xfs:  see Documentation/admin-guide/xfs.rst

.. seealso::

  ext4: see Documentation/filesystems/ext4/


Xử lý lỗi phương tiện
---------------------

Hệ thống con libnvdimm lưu trữ bản ghi các vị trí lỗi phương tiện đã biết cho
mỗi thiết bị khối pmem (trong gendisk->badblocks). Nếu chúng tôi có lỗi ở vị trí đó,
hoặc một lỗi tiềm ẩn chưa được phát hiện, ứng dụng có thể mong đợi
để nhận được ZZ0000ZZ. Libnvdimm cũng cho phép xóa các lỗi này bằng cách đơn giản
viết các lĩnh vực bị ảnh hưởng (thông qua trình điều khiển pmem, và nếu cơ bản
NVDIMM hỗ trợ clear_poison DSM được xác định bởi ACPI).

Vì ZZ0002ZZ IO thường không đi qua đường dẫn ZZ0000ZZ, các ứng dụng hoặc
quản trị viên hệ thống có tùy chọn khôi phục dữ liệu bị mất từ ZZ0001ZZ trước đó
dư thừa theo các cách sau:

1. Xóa tệp bị ảnh hưởng và khôi phục từ bản sao lưu (tuyến quản trị hệ thống):
   Điều này sẽ giải phóng các khối hệ thống tệp đang được tệp sử dụng,
   và lần tiếp theo chúng được phân bổ, chúng sẽ về 0 trước tiên, điều này
   xảy ra thông qua trình điều khiển và sẽ xóa các thành phần xấu.

2. Cắt bớt hoặc đục lỗ phần tệp có khối xấu (ít nhất là
   toàn bộ khu vực liên kết phải được đục lỗ, nhưng không nhất thiết phải là
   toàn bộ khối hệ thống tập tin).

Đây là hai đường dẫn cơ bản cho phép hệ thống tập tin ZZ0000ZZ tiếp tục hoạt động
trong trường hợp có lỗi phương tiện. Cơ chế phục hồi lỗi mạnh mẽ hơn có thể được
được xây dựng dựa trên điều này trong tương lai, chẳng hạn như liên quan đến sự dư thừa/sao chép
được cung cấp ở lớp khối thông qua DM hoặc ngoài ra, tại hệ thống tệp
cấp độ. Những điều này sẽ phải dựa vào hai nguyên lý trên, việc xóa lỗi
có thể xảy ra bằng cách gửi IO qua trình điều khiển hoặc về 0 (cũng thông qua
người lái xe).


Những thiếu sót
---------------

Ngay cả khi hạt nhân hoặc các mô-đun của nó được lưu trữ trên hệ thống tập tin hỗ trợ
ZZ0000ZZ trên thiết bị khối hỗ trợ ZZ0001ZZ, chúng vẫn sẽ được sao chép vào RAM.

Mã DAX không hoạt động chính xác trên các kiến trúc có hầu như
bộ đệm được ánh xạ như ARM, MIPS và SPARC.

Gọi ZZ0000ZZ trên một dải bộ nhớ người dùng đã được
mmapped từ tệp ZZ0002ZZ sẽ thất bại khi không có 'trang cấu trúc' để mô tả
những trang đó.  Vấn đề này đã được giải quyết trong một số trình điều khiển thiết bị
bằng cách thêm hỗ trợ trang cấu trúc tùy chọn cho các trang dưới sự kiểm soát của
trình điều khiển (xem ZZ0003ZZ trong ZZ0001ZZ để biết ví dụ về
làm thế nào để làm điều này). Trong trường hợp trang không có cấu trúc, ZZ0004ZZ đọc/ghi vào
những phạm vi bộ nhớ đó từ tệp không phải ZZ0005ZZ sẽ không thành công


.. note::

  `O_DIRECT` reads/writes _of a `DAX` file do work, it is the memory that
  is being accessed that is key here).  Other things that will not work in
  the non struct page case include RDMA, :c:func:`sendfile()` and
  :c:func:`splice()`.
