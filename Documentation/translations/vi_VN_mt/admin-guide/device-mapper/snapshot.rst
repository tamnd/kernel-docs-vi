.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/snapshot.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================================
Hỗ trợ chụp nhanh trình ánh xạ thiết bị
==============================

Trình ánh xạ thiết bị cho phép bạn mà không cần sao chép dữ liệu lớn:

- Để tạo ảnh chụp nhanh của bất kỳ thiết bị khối nào, tức là các trạng thái đã lưu, có thể gắn kết của
   thiết bị khối cũng có thể ghi mà không can thiệp vào
   nội dung gốc;
- Để tạo các "phân nhánh" của thiết bị, tức là nhiều phiên bản khác nhau của
   cùng một luồng dữ liệu.
- Để hợp nhất ảnh chụp nhanh của thiết bị khối trở lại nguồn gốc của ảnh chụp nhanh
   thiết bị.

Trong hai trường hợp đầu tiên, dm chỉ sao chép các khối dữ liệu nhận được
đã thay đổi và sử dụng thiết bị chặn sao chép khi ghi (COW) riêng biệt cho
lưu trữ.

Để hợp nhất ảnh chụp nhanh, nội dung của bộ lưu trữ COW được hợp nhất lại vào
thiết bị gốc.


Có ba mục tiêu dm có sẵn:
ảnh chụp nhanh, nguồn gốc ảnh chụp nhanh và hợp nhất ảnh chụp nhanh.

- ảnh chụp nhanh nguồn gốc <origin>

thường sẽ có một hoặc nhiều ảnh chụp nhanh dựa trên nó.
Các lần đọc sẽ được ánh xạ trực tiếp tới thiết bị sao lưu. Đối với mỗi lần viết,
dữ liệu gốc sẽ được lưu trong <COW device> của mỗi ảnh chụp nhanh để lưu giữ
nội dung hiển thị của nó không thay đổi, ít nhất là cho đến khi <COW device> đầy.


- ảnh chụp nhanh <nguồn gốc> <Thiết bị COW> <liên tục?> <chunksize>
   [<# feature lập luận> [<arg>]*]

Ảnh chụp nhanh của thiết bị khối <origin> được tạo. Các phần đã thay đổi của
Các cung <chunksize> sẽ được lưu trữ trên <COW device>.  Viết sẽ
chỉ truy cập <COW device>.  Các lần đọc sẽ đến từ <COW device> hoặc
từ <origin> cho dữ liệu không thay đổi.  <Thiết bị COW> thường sẽ
nhỏ hơn điểm gốc và nếu nó lấp đầy ảnh chụp nhanh sẽ trở thành
vô dụng và bị vô hiệu hóa, trả về lỗi.  Vì vậy điều quan trọng là phải theo dõi
dung lượng trống và mở rộng <COW device> trước khi nó đầy.

<persistent?> là P (Persistent) hoặc N (Không kiên trì - sẽ không tồn tại
sau khi khởi động lại).  O (Tràn) có thể được thêm dưới dạng tùy chọn lưu trữ liên tục
để cho phép không gian người dùng quảng cáo hỗ trợ xem "Tràn" trong
trạng thái ảnh chụp nhanh.  Vì vậy các loại cửa hàng được hỗ trợ là "P", "PO" và "N".

Sự khác biệt giữa liên tục và thoáng qua là với thoáng qua
ảnh chụp nhanh ít siêu dữ liệu phải được lưu trên đĩa - chúng có thể được lưu giữ trong
bộ nhớ của kernel.

Khi tải hoặc dỡ mục tiêu chụp nhanh, tương ứng
Mục tiêu snapshot-origin hoặc snapshot-merge phải bị tạm dừng. Một thất bại
đình chỉ mục tiêu gốc có thể dẫn đến hỏng dữ liệu.

Các tính năng tùy chọn:

loại bỏ_zeroes_cow - loại bỏ được cấp cho thiết bị chụp nhanh
   ánh xạ tới toàn bộ các khối để loại bỏ (các) ngoại lệ tương ứng trong
   kho ngoại lệ của ảnh chụp nhanh.

cancel_passdown_origin - việc loại bỏ thiết bị chụp nhanh được chuyển
   xuống thiết bị cơ bản của nguồn gốc ảnh chụp nhanh.  Điều này không gây ra
   sao chép vào kho lưu trữ ngoại lệ ảnh chụp nhanh vì nguồn gốc ảnh chụp nhanh
   mục tiêu bị bỏ qua.

Tính năng loại bỏ_passdown_origin phụ thuộc vào loại bỏ_zeroes_cow
   tính năng đang được kích hoạt.


- snapshot-merge <origin> <COW device> <persistent> <chunksize>
   [<# feature lập luận> [<arg>]*]

lấy các đối số bảng giống như mục tiêu chụp nhanh ngoại trừ nó chỉ
hoạt động với ảnh chụp nhanh liên tục.  Mục tiêu này đảm nhận vai trò
mục tiêu "snapshot-origin" và không được tải nếu "snapshot-origin"
vẫn còn hiện diện cho <origin>.

Tạo ảnh chụp nhanh hợp nhất để kiểm soát các phần đã thay đổi
được lưu trữ trong <COW device> của ảnh chụp nhanh hiện có, thông qua chuyển giao
thủ tục và hợp nhất các khối này trở lại <origin>.  Sau khi hợp nhất
đã bắt đầu (ở chế độ nền), <origin> có thể được mở và quá trình hợp nhất
sẽ tiếp tục trong khi I/O đang truyền tới nó.  Những thay đổi đối với <origin> là
được hoãn lại cho đến khi (các) đoạn tương ứng của ảnh chụp nhanh hợp nhất đã được
sáp nhập.  Sau khi quá trình hợp nhất đã bắt đầu thiết bị chụp nhanh, được liên kết với
mục tiêu "ảnh chụp nhanh", sẽ trả về -EIO khi được truy cập.


Cách LVM2 sử dụng ảnh chụp nhanh
============================
Khi bạn tạo ảnh chụp nhanh LVM2 đầu tiên của một ổ đĩa, bốn thiết bị dm sẽ được sử dụng:

1) một thiết bị chứa bảng ánh xạ gốc của ổ nguồn;
2) một thiết bị được sử dụng làm <thiết bị COW>;
3) thiết bị "ảnh chụp nhanh", kết hợp #1 và #2, là ảnh chụp nhanh có thể nhìn thấy
   khối lượng;
4) âm lượng "gốc" (sử dụng số thiết bị được sử dụng bởi bản gốc
   khối nguồn), bảng của nó được thay thế bằng ánh xạ "snapshot-origin"
   từ thiết bị #1.

Một sơ đồ đặt tên cố định được sử dụng, do đó, với các lệnh sau ::

lvcreate -L 1G -n nhóm khối lượng cơ sở
  lvcreate -L 100M --snapshot -n snap khối lượngNhóm/cơ sở

chúng ta sẽ gặp tình huống này (với số lượng theo thứ tự trên)::

Bảng # dmsetup|nhóm khối lượng grep

VolumeGroup-base-real: 0 2097152 tuyến tính 8:19 384
  VolumeGroup-snap-cow: 0 204800 tuyến tính 8:19 2097536
  VolumeGroup-snap: 0 2097152 ảnh chụp nhanh 254:11 254:12 P 16
  VolumeGroup-base: 0 2097152 snapshot-origin 254:11

# ls -lL /dev/mapper/volumeGroup-*
  brw------- 1 gốc gốc 254, 11 29 trước 18:15 /dev/mapper/volumeGroup-base-real
  brw------- 1 gốc gốc 254, 12 29 trước 18:15 /dev/mapper/volumeGroup-snap-cow
  brw------- 1 gốc gốc 254, 13 29 trước 18:15 /dev/mapper/volumeGroup-snap
  brw------- 1 gốc gốc 254, 10 29 trước 18:14 /dev/mapper/volumeGroup-base


Cách LVM2 sử dụng tính năng hợp nhất ảnh chụp nhanh
==================================
Một ảnh chụp nhanh hợp nhất đảm nhận vai trò "nguồn gốc ảnh chụp nhanh" trong khi
sáp nhập.  Vì vậy, "snapshot-origin" được thay thế bằng
"ảnh chụp nhanh hợp nhất".  Thiết bị "-real" không bị thay đổi và thiết bị "-cow"
thiết bị được đổi tên thành <origin name>-cow để hỗ trợ LVM2 dọn dẹp
hợp nhất ảnh chụp nhanh sau khi hoàn thành.  "Ảnh chụp nhanh" chuyển giao nó
Thiết bị COW thành "snapshot-merge" bị vô hiệu hóa (trừ khi sử dụng lvchange
--làm mới); nhưng nếu nó vẫn hoạt động thì nó sẽ trả về lỗi I/O.

Ảnh chụp nhanh sẽ hợp nhất vào nguồn gốc của nó bằng lệnh sau ::

lvconvert --merge VolumeGroup/snap

bây giờ chúng ta sẽ gặp tình huống này::

Bảng # dmsetup|nhóm khối lượng grep

VolumeGroup-base-real: 0 2097152 tuyến tính 8:19 384
  VolumeGroup-base-bò: 0 204800 tuyến tính 8:19 2097536
  khối lượng Nhóm cơ sở: 0 2097152 hợp nhất ảnh chụp nhanh 254:11 254:12 P 16

# ls -lL /dev/mapper/volumeGroup-*
  brw------- 1 gốc gốc 254, 11 29 trước 18:15 /dev/mapper/volumeGroup-base-real
  brw------- 1 gốc gốc 254, 12 29 trước 18:16 /dev/mapper/volumeGroup-base-cow
  brw------- 1 gốc gốc 254, 10 29 trước 18:16 /dev/mapper/volumeGroup-base


Cách xác định khi nào quá trình hợp nhất hoàn tất
===========================================
Các dòng trạng thái snapshot-merge và snapshot kết thúc bằng:

<sector_allocated>/<total_sector> <metadata_sector>

Cả <sector_allocated> và <total_sectors> đều bao gồm cả dữ liệu và siêu dữ liệu.
Trong quá trình sáp nhập, số lượng các lĩnh vực được phân bổ sẽ nhỏ hơn và
nhỏ hơn.  Việc sáp nhập kết thúc khi số lượng các ngành chứa dữ liệu
bằng 0, nói cách khác <sector_allocated> == <metadata_sectors>.

Đây là một ví dụ thực tế (sử dụng kết hợp các lệnh lvm và dmsetup)::

# lvs
    LV VG Attr Lsize Origin Snap% Di chuyển Nhật ký Sao chép% Chuyển đổi
    khối lượng cơ sởNhóm nợ-a- 4,00g
    khối lượng snapNhóm swi-a- 1,00g cơ sở 18,97

Khối lượng trạng thái # dmsetupNhóm-snap
  0 8388608 ảnh chụp nhanh 397896/2097152 1560
                                    ^^^ các lĩnh vực siêu dữ liệu

# lvconvert --merge -b nhóm/snap
    Việc hợp nhất snap âm lượng đã bắt đầu.

# lvs nhóm âm lượng/snap
    LV VG Attr Lsize Origin Snap% Di chuyển Nhật ký Sao chép% Chuyển đổi
    khối lượng cơ sởNhóm Owi-a- 4,00g 17,23

Khối lượng trạng thái # dmsetupCơ sở nhóm
  0 8388608 hợp nhất ảnh chụp nhanh 281688/2097152 1104

Khối lượng trạng thái # dmsetupCơ sở nhóm
  0 8388608 hợp nhất ảnh chụp nhanh 180480/2097152 712

Khối lượng trạng thái # dmsetupCơ sở nhóm
  0 8388608 hợp nhất ảnh chụp nhanh 16/2097152 16

Việc sáp nhập đã kết thúc.

::

# lvs
    LV VG Attr Lsize Origin Snap% Di chuyển Nhật ký Sao chép% Chuyển đổi
    khối lượng cơ sởNhóm nợ-a- 4,00g
