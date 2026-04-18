.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/dm-ima.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======
dm-ima
======

Đối với một hệ thống nhất định, các công cụ cơ sở hạ tầng/dịch vụ bên ngoài khác nhau
(bao gồm cả dịch vụ chứng thực) tương tác với nó - cả trong quá trình
thiết lập và trong thời gian còn lại của thời gian chạy hệ thống.  Họ chia sẻ dữ liệu nhạy cảm
và/hoặc thực thi khối lượng công việc quan trọng trên hệ thống đó.  Các dịch vụ bên ngoài
có thể muốn xác minh trạng thái thời gian chạy hiện tại của kernel có liên quan
các hệ thống con trước khi tin tưởng hoàn toàn vào hệ thống với các vấn đề quan trọng trong kinh doanh
dữ liệu/khối lượng công việc.

Trình ánh xạ thiết bị đóng một vai trò quan trọng trên một hệ thống nhất định bằng cách cung cấp
nhiều chức năng quan trọng khác nhau cho các thiết bị khối sử dụng nhiều
các loại mục tiêu như mật mã, tính xác thực, tính toàn vẹn, v.v. Mỗi mục tiêu này
chức năng của các loại có thể được cấu hình với nhiều thuộc tính khác nhau.
Các thuộc tính được chọn để định cấu hình các loại mục tiêu này có thể
tác động đến hồ sơ bảo mật của thiết bị khối và ngược lại, của
bản thân hệ thống.  Ví dụ, loại thuật toán mã hóa và
kích thước khóa xác định cường độ mã hóa cho một thiết bị khối nhất định.

Do đó, việc xác minh trạng thái hiện tại của các thiết bị khối khác nhau cũng
vì các thuộc tính mục tiêu khác nhau của chúng rất quan trọng đối với các dịch vụ bên ngoài trước
hoàn toàn tin tưởng vào hệ thống với dữ liệu/khối lượng công việc quan trọng trong kinh doanh.

Hệ thống con hạt nhân IMA cung cấp các chức năng cần thiết cho
trình ánh xạ thiết bị để đo trạng thái và cấu hình của
các thiết bị khối khác nhau -

- bởi chính trình ánh xạ thiết bị, từ bên trong kernel,
- theo cách chống giả mạo,
- và được đo lại - được kích hoạt khi thay đổi trạng thái/cấu hình.

Đặt chính sách IMA:
=======================
Để IMA đo dữ liệu trên một hệ thống nhất định, chính sách IMA trên
hệ thống cần được cập nhật để có dòng sau và hệ thống cần
được khởi động lại để phép đo có hiệu lực.

::

/etc/ima/ima-chính sách
    đo func=CRITICAL_DATA nhãn=mẫu bản đồ thiết bị=ima-buf

Các phép đo sẽ được phản ánh trong nhật ký IMA, được đặt tại:

::

/sys/kernel/security/integrity/ima/ascii_runtime_measurements
 /sys/kernel/security/integrity/ima/binary_runtime_measurements

Khi đó nhật ký đo IMA ASCII có định dạng sau:

::

<PCR> <TEMPLATE_DATA_DIGEST> <TEMPLATE_NAME> <TEMPLATE_DATA>

PCR := Đăng ký cấu hình nền tảng, trong đó các giá trị được đăng ký.
       Điều này có thể áp dụng nếu chip TPM đang được sử dụng.

TEMPLATE_DATA_DIGEST := Bản tóm tắt dữ liệu mẫu của bản ghi IMA.
 TEMPLATE_NAME := Tên mẫu đã đăng ký giá trị toàn vẹn (ví dụ: ima-buf).

TEMPLATE_DATA := <ALG> => <EVENT_DIGEST> <EVENT_NAME> <EVENT_DATA>
                  Nó chứa dữ liệu cho sự kiện cụ thể cần đo lường,
                  trong một định dạng dữ liệu mẫu nhất định.

ALG := Thuật toán tính toán thông báo sự kiện
 EVENT_DIGEST := Tổng hợp dữ liệu sự kiện
 EVENT_NAME := Mô tả sự kiện (ví dụ: 'dm_table_load').
 EVENT_DATA := Dữ liệu sự kiện cần đo.

|

| ZZ0000ZZ
| Dữ liệu mục tiêu DM được đo bởi hệ thống con IMA có thể thay thế
 được truy vấn từ không gian người dùng bằng cách đặt DM_IMA_MEASUREMENT_FLAG với
 DM_TABLE_STATUS_CMD.

|

| ZZ0000ZZ
| Cấu hình hạt nhân CONFIG_IMA_DISABLE_HTABLE cho phép đo các bản ghi trùng lặp.
| Để hỗ trợ ghi lại các sự kiện IMA trùng lặp trong nhật ký IMA, Kernel cần được cấu hình với
 CONFIG_IMA_DISABLE_HTABLE=y.

Trạng thái thiết bị được hỗ trợ:
================================
Những thay đổi trạng thái thiết bị sau đây sẽ kích hoạt các phép đo IMA:

1. Tải bảng
 #. Sơ yếu lý lịch thiết bị
 #. Xóa thiết bị
 #. Bảng rõ ràng
 #. Đổi tên thiết bị

1. Tải bảng:
---------------
Khi một bảng mới được tải vào vùng bảng không hoạt động của thiết bị,
thông tin thiết bị và chi tiết cụ thể về mục tiêu từ
các mục tiêu trong bảng được đo lường.

Nhật ký đo IMA có định dạng sau cho 'dm_table_load':

::

EVENT_NAME := "dm_table_load"
 EVENT_DATA := <dm_version_str> ";" <device_metadata> ";" <bảng_load_data>

dm_version_str := "dm_version=" <N> "." <N> "." <N>
                  Tương tự như phiên bản trình điều khiển Device Mapper.
 device_metadata := <device_name> "," <device_uuid> "," <device_major> "," <device_minor> ","
                   <minor_count> "," <num_device_targets> ";"

device_name := "name=" <dm-device-name>
 device_uuid := "uuid=" <dm-device-uuid>
 device_major := "chính=" <N>
 device_minor := "minor=" <N>
 Minor_count := "minor_count=" <N>
 num_device_target := "num_targets=" <N>
 dm-device-name := Tên của thiết bị. Nếu nó chứa các ký tự đặc biệt như '\', ',', ';',
                   chúng có tiền tố là '\'.
 dm-device-uuid := UUID của thiết bị. Nếu nó chứa các ký tự đặc biệt như '\', ',', ';',
                   chúng có tiền tố là '\'.

bảng_load_data := <target_data>
                    Biểu thị dữ liệu (dưới dạng cặp tên=giá trị) từ các mục tiêu khác nhau trong bảng,
                    đang được tải vào khe bảng không hoạt động của thiết bị DM.
 target_data := <target_data_row> | <target_data><target_data_row>

target_data_row := <target_index> "," <target_begin> "," <target_len> "," <target_name> ","
                    <target_version> "," <target_attributes> ";"
 target_index := "target_index=" <N>
                 Đại diện cho mục tiêu thứ n trong bảng (từ 0 đến N-1 mục tiêu được chỉ định trong <num_device_targets>)
                 Nếu tất cả dữ liệu cho N mục tiêu không vừa với bộ đệm đã cho - thì dữ liệu phù hợp
                 trong bộ đệm (giả sử từ mục tiêu 0 đến x) được đo trong một sự kiện IMA nhất định.
                 Dữ liệu còn lại từ các mục tiêu x+1 đến N-1 được đo trong các sự kiện IMA tiếp theo,
                 có cùng định dạng với định dạng của 'dm_table_load'
                 tức là <dm_version_str> ";" <device_metadata> ";" <bảng_load_dữ liệu>.

target_begin := "target_begin=" <N>
 target_len := "target_len=" <N>
 target_name := Tên của mục tiêu. 'tuyến tính', 'mật mã', 'toàn vẹn', v.v.
                Các mục tiêu được hỗ trợ cho phép đo IMA được ghi lại bên dưới trong
                Phần 'Mục tiêu được hỗ trợ'.
 target_version := "target_version=" <N> "." <N> "." <N>
 target_attributes := Dữ liệu chứa danh sách các cặp tên=giá trị được phân tách bằng dấu phẩy của các thuộc tính cụ thể của mục tiêu.

Ví dụ: nếu một thiết bị tuyến tính được tạo với các mục trong bảng sau,
  # dmsetup tạo tuyến tính1
  0 2 tuyến tính/dev/loop0 512
  2 2 tuyến tính /dev/loop0 512
  4 2 tuyến tính /dev/loop0 512
  6 2 tuyến tính /dev/loop0 512

Khi đó nhật ký đo IMA ASCII sẽ có mục sau:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 a8c5ff755561c7a28146389d1514c318592af49a ima-buf sha256:4d73481ecce5eadba8ab084640d85bb9ca899af4d0a122989252a76efadc5b72
 dm_table_load
 dm_version=4.45.0;
 name=tuyến tính1,uuid=,major=253,minor=0,minor_count=1,num_targets=4;
 target_index=0,target_begin=0,target_len=2,target_name=tuyến tính,target_version=1.4.0,device_name=7:0,start=512;
 target_index=1,target_begin=2,target_len=2,target_name=tuyến tính,target_version=1.4.0,device_name=7:0,start=512;
 target_index=2,target_begin=4,target_len=2,target_name=tuyến tính,target_version=1.4.0,device_name=7:0,start=512;
 target_index=3,target_begin=6,target_len=2,target_name=tuyến tính,target_version=1.4.0,device_name=7:0,start=512;

2. Sơ yếu lý lịch thiết bị:
---------------------------
Khi một thiết bị bị treo được nối lại, thông tin thiết bị và hàm băm của
dữ liệu từ lần tải trước của bảng đang hoạt động sẽ được đo.

Nhật ký đo IMA có định dạng sau cho 'dm_device_resume':

::

EVENT_NAME := "dm_device_resume"
 EVENT_DATA := <dm_version_str> ";" <device_metadata> ";" <active_table_hash> ";" <current_device_capacity> ";"

dm_version_str := Như đã mô tả ở phần 'Tải bảng' ở trên.
 device_metadata := Như đã mô tả ở phần 'Tải bảng' ở trên.
 active_table_hash := "active_table_hash=" <table_hash_alg> ://: <table_hash>
                      Biểu thị hàm băm của dữ liệu IMA đang được đo cho
                      bảng hoạt động cho thiết bị.
 table_hash_alg := Thuật toán dùng để tính toán hàm băm.
 table_hash := Giá trị băm của (<dm_version_str> ";" <device_metadata> ";" <table_load_data> ";")
               như được mô tả trong 'dm_table_load' ở trên.
               Lưu ý: Nếu dữ liệu table_load trải rộng trên nhiều IMA 'dm_table_load'
               sự kiện cho một thiết bị nhất định, hàm băm được tính bằng cách kết hợp tất cả dữ liệu sự kiện
               tức là (<dm_version_str> ";" <device_metadata> ";" <table_load_data> ";")
               qua tất cả những sự kiện đó.
 current_device_capacity := "current_device_capacity=" <N>

Ví dụ: nếu một thiết bị tuyến tính được nối lại bằng lệnh sau,
 #dmsetup tiếp tục tuyến tính1

thì nhật ký đo lường IMA ASCII sẽ có một mục nhập với:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 56c00cc062ffc24ccd9ac2d67d194af3282b934e ima-buf sha256:e7d12c03b958b4e0e53e7363a06376be88d98a1ac191fdbd3baf5e4b77f329b6
 dm_device_resume
 dm_version=4.45.0;
 name=tuyến tính1,uuid=,major=253,minor=0,minor_count=1,num_targets=4;
 active_table_hash=sha256:4d73481ecce5eadba8ab084640d85bb9ca899af4d0a122989252a76efadc5b72;current_device_capacity=8;

3. Tháo thiết bị:
------------------
Khi một thiết bị bị xóa, thông tin thiết bị và hàm băm sha256 của
dữ liệu từ một bảng hoạt động và không hoạt động được đo.

Nhật ký đo IMA có định dạng sau cho 'dm_device_remove':

::

EVENT_NAME := "dm_device_remove"
 EVENT_DATA := <dm_version_str> ";" <device_active_metadata> ";" <device_inactive_metadata> ";"
               <active_table_hash> "," <inactive_table_hash> "," <remove_all> ";" <current_device_capacity> ";"

dm_version_str := Như đã mô tả ở phần 'Tải bảng' ở trên.
 device_active_metadata := Siêu dữ liệu thiết bị phản ánh bảng hoạt động hiện được tải.
                           Định dạng giống như 'device_metadata' được mô tả trong phần 'Tải bảng' ở trên.
 device_inactive_metadata := Siêu dữ liệu thiết bị phản ánh bảng không hoạt động.
                             Định dạng giống như 'device_metadata' được mô tả trong phần 'Tải bảng' ở trên.
 active_table_hash := Hash của bảng đang hoạt động hiện đang được tải.
                      Định dạng giống như 'active_table_hash' được mô tả trong phần 'sơ yếu lý lịch thiết bị' ở trên.
 inactive_table_hash := Hash của bảng không hoạt động.
                         Định dạng giống như 'active_table_hash' được mô tả trong phần 'sơ yếu lý lịch thiết bị' ở trên.
 xóa_all := "remove_all=" <yes_no>
 có_không := "y" | "n"
 current_device_capacity := "current_device_capacity=" <N>

Ví dụ: nếu một thiết bị tuyến tính bị xóa bằng lệnh sau,
  #dmsetup loại bỏ l1

thì nhật ký đo IMA ASCII sẽ có mục sau:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 790e830a3a7a31590824ac0642b3b31c2d0e8b38 ima-buf sha256:ab9f3c959367a8f5d4403d6ce9c3627dadfa8f9f0e7ec7899299782388de3840
 dm_device_remove
 dm_version=4.45.0;
 device_active_metadata=name=l1,uuid=,major=253,minor=2,minor_count=1,num_targets=2;
 device_inactive_metadata=name=l1,uuid=,major=253,minor=2,minor_count=1,num_targets=1;
 active_table_hash=sha256:4a7e62efaebfc86af755831998b7db6f59b60d23c9534fb16a4455907957953a,
 inactive_table_hash=sha256:9d79c175bc2302d55a183e8f50ad4bafd60f7692fd6249e5fd213e2464384b86,remove_all=n;
 current_device_capacity=2048;

4. Bảng rõ ràng:
----------------
Khi một bảng không hoạt động bị xóa khỏi thiết bị, thông tin thiết bị và hàm băm sha256 của
dữ liệu từ một bảng không hoạt động được đo.

Nhật ký đo IMA có định dạng sau cho 'dm_table_clear':

::

EVENT_NAME := "dm_table_clear"
 EVENT_DATA := <dm_version_str> ";" <device_inactive_metadata> ";" <inactive_table_hash> ";" <current_device_capacity> ";"

dm_version_str := Như đã mô tả ở phần 'Tải bảng' ở trên.
 device_inactive_metadata := Siêu dữ liệu thiết bị được ghi lại trong thời gian tải bảng không hoạt động đang bị xóa.
                             Định dạng giống như 'device_metadata' được mô tả trong phần 'Tải bảng' ở trên.
 inactive_table_hash := Hash của bảng không hoạt động đang bị xóa khỏi thiết bị.
                        Định dạng giống như 'active_table_hash' được mô tả trong phần 'sơ yếu lý lịch thiết bị' ở trên.
 current_device_capacity := "current_device_capacity=" <N>

Ví dụ: nếu bảng không hoạt động của thiết bị tuyến tính bị xóa,
  #dmsetup rõ ràng l1

thì nhật ký đo lường IMA ASCII sẽ có một mục nhập với:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 77d347408f557f68f0041acb0072946bb2367fe5 ima-buf sha256:42f9ca22163fdfa548e6229dece2959bc5ce295c681644240035827ada0e1db5
 dm_table_clear
 dm_version=4.45.0;
 name=l1,uuid=,major=253,minor=2,minor_count=1,num_targets=1;
 inactive_table_hash=sha256:75c0dc347063bf474d28a9907037eba060bfe39d8847fc0646d75e149045d545;current_device_capacity=1024;

5. Đổi tên thiết bị:
--------------------
Khi NAME hoặc UUID của thiết bị bị thay đổi, thông tin thiết bị và NAME và UUID mới sẽ
được đo.

Nhật ký đo IMA có định dạng sau cho 'dm_device_rename':

::

EVENT_NAME := "dm_device_rename"
 EVENT_DATA := <dm_version_str> ";" <device_active_metadata> ";" <new_device_name> "," <new_device_uuid> ";" <current_device_capacity> ";"

dm_version_str := Như đã mô tả ở phần 'Tải bảng' ở trên.
 device_active_metadata := Siêu dữ liệu thiết bị phản ánh bảng hoạt động hiện được tải.
                           Định dạng giống như 'device_metadata' được mô tả trong phần 'Tải bảng' ở trên.
 new_device_name := "new_name=" <dm-device-name>
 dm-device-name := Tương tự như <dm-device-name> được mô tả trong phần 'Tải bảng' ở trên
 new_device_uuid := "new_uuid=" <dm-device-uuid>
 dm-device-uuid := Tương tự như <dm-device-uuid> được mô tả trong phần 'Tải bảng' ở trên
 current_device_capacity := "current_device_capacity=" <N>

Ví dụ 1: nếu tên của thiết bị tuyến tính được thay đổi bằng lệnh sau,
  #dmsetup đổi tên tuyến tính1 --setuuid 1234-5678

thì nhật ký đo lường IMA ASCII sẽ có một mục nhập với:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 8b0423209b4c66ac1523f4c9848c9b51ee332f48 ima-buf sha256:6847b7258134189531db593e9230b257c84f04038b5a18fd2e1473860e0569ac
 dm_device_rename
 dm_version=4.45.0;
 name=tuyến tính1,uuid=,major=253,minor=2,minor_count=1,num_targets=1;new_name=tuyến tính1,new_uuid=1234-5678;
 current_device_capacity=1024;

Ví dụ 2: nếu tên của thiết bị tuyến tính được thay đổi bằng lệnh sau,
  # dmsetup đổi tên tuyến tính1 tuyến tính=2

thì nhật ký đo lường IMA ASCII sẽ có một mục nhập với:
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

10 bef70476b99c2bdf7136fae033aa8627da1bf76f ima-buf sha256:8c6f9f53b9ef9dc8f92a2f2cca8910e622543d0f0d37d484870cb16b95111402
 dm_device_rename
 dm_version=4.45.0;
 name=tuyến tính1,uuid=1234-5678,major=253,minor=2,minor_count=1,num_targets=1;
 new_name=tuyến tính\=2,new_uuid=1234-5678;
 current_device_capacity=1024;

Các mục tiêu được hỗ trợ:
=========================

Các mục tiêu sau được hỗ trợ để đo dữ liệu của họ bằng IMA:

1. bộ đệm
 #. hầm mộ
 #. chính trực
 #. tuyến tính
 #. gương
 #. đa đường
 #. cuộc đột kích
 #. ảnh chụp nhanh
 #. sọc
 #. sự thật

1. bộ đệm
---------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'bộ đệm'.

::

target_attributes := <target_name> "," <target_version> "," <metadata_mode> "," <cache_metadata_device> ","
                      <cache_device> "," <cache_origin_device> "," <writethrough> "," <writeback> ","
                      <passthrough> "," <no_discard_passdown> ";"

target_name := "target_name=cache"
 target_version := "target_version=" <N> "." <N> "." <N>
 siêu dữ liệu_mode := "metadata_mode=" <cache_metadata_mode>
 cache_metadata_mode := "thất bại" ZZ0000ZZ "rw"
 cache_device := "cache_device=" <cache_device_name_string>
 cache_origin_device := "cache_origin_device=" <cache_origin_device_string>
 viết qua := "viết qua =" <yes_no>
 viết lại := "writeback=" <yes_no>
 vượt qua := "passthrough=" <yes_no>
 no_discard_passdown := "no_discard_passdown=" <yes_no>
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'bộ đệm' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'bộ đệm' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;name=cache1,uuid=cache_uuid,major=253,minor=2,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=28672,target_name=cache,target_version=2.2.0,metadata_mode=rw,
 cache_metadata_device=253:4,cache_device=253:3,cache_origin_device=253:5,writethrough=y,writeback=n,
 passthrough=n,metadata2=y,no_discard_passdown=n;


2. mật mã
---------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'mật mã'.

::

target_attributes := <target_name> "," <target_version> "," <allow_discards> "," <same_cpu_crypt> ","
                      <submit_from_crypt_cpus> "," <no_read_workqueue> "," <no_write_workqueue> ","
                      <iv_large_sectors> "," <iv_large_sectors> "," [<integrity_tag_size> ","] [<cipher_auth> ","]
                      [<sector_size> ","] [<cipher_string> ","] <key_size> "," <key_parts> ","
                      <key_extra_size> "," <key_mac_size> ";"

target_name := "target_name=crypt"
 target_version := "target_version=" <N> "." <N> "." <N>
 allow_discards := "allow_discards=" <yes_no>
 Same_cpu_crypt := "same_cpu_crypt=" <yes_no>
 submit_from_crypt_cpus := "submit_from_crypt_cpus=" <yes_no>
 no_read_workqueue := "no_read_workqueue=" <yes_no>
 no_write_workqueue := "no_write_workqueue=" <yes_no>
 iv_large_sectors := "iv_large_sectors=" <yes_no>
 tính toàn vẹn_tag_size := "integrity_tag_size=" <N>
 cipher_auth := "cipher_auth=" <string>
 Sector_size := "sector_size=" <N>
 cipher_string := "cipher_string="
 key_size := "key_size=" <N>
 key_parts := "key_parts=" <N>
 key_extra_size := "key_extra_size=" <N>
 key_mac_size := "key_mac_size=" <N>
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'mật mã' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'mật mã' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=crypt1,uuid=crypt_uuid1,major=253,minor=0,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=1953125,target_name=crypt,target_version=1.23.0,
 allow_discards=y,same_cpu=n,submit_from_crypt_cpus=n,no_read_workqueue=n,no_write_workqueue=n,
 iv_large_sectors=n,cipher_string=aes-xts-plain64,key_size=32,key_parts=1,key_extra_size=0,key_mac_size=0;

3. tính chính trực
------------------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'toàn vẹn'.

::

target_attributes := <target_name> "," <target_version> "," <dev_name> "," <start>
                      <tag_size> "," <mode> "," [<meta_device> ","] [<block_size> ","] <tính toán lại> ","
                      <allow_discards> "," <fix_padding> "," <fix_hmac> "," <legacy_recalcate> ","
                      <journal_sectors> "," <interleave_sectors> "," <buffer_sectors> ";"

target_name := "target_name=toàn vẹn"
 target_version := "target_version=" <N> "." <N> "." <N>
 dev_name := "dev_name=" <device_name_str>
 bắt đầu := "bắt đầu=" <N>
 tag_size := "tag_size=" <N>
 chế độ := "chế độ =" <integrity_mode_str>
 tính toàn vẹn_mode_str := "J" ZZ0000ZZ "D" | "R"
 meta_device := "meta_device=" <meta_device_str>
 block_size := "block_size=" <N>
 tính toán lại := "tính toán lại=" <yes_no>
 allow_discards := "allow_discards=" <yes_no>
 fix_padding := "fix_padding=" <yes_no>
 fix_hmac := "fix_hmac=" <yes_no>
 Legacy_recalcate := "legacy_recalcate=" <yes_no>
 tạp chí_sectors := "journal_sectors=" <N>
 interleave_sectors := "interleave_sectors=" <N>
 buffer_sectors := "buffer_sectors=" <N>
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'toàn vẹn' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'toàn vẹn' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=integrity1,uuid=,major=253,minor=1,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=7856,target_name=toàn vẹn,target_version=1.10.0,
 dev_name=253:0,start=0,tag_size=32,mode=J,recalcate=n,allow_discards=n,fix_padding=n,
 fix_hmac=n,legacy_recalculate=n,journal_sectors=88,interleave_sectors=32768,buffer_sectors=128;


4. tuyến tính
-------------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'tuyến tính'.

::

target_attributes := <target_name> "," <target_version> "," <device_name> <,> <start> ";"

target_name := "target_name=tuyến tính"
 target_version := "target_version=" <N> "." <N> "." <N>
 device_name := "device_name=" <tuyến tính_device_name_str>
 bắt đầu := "bắt đầu=" <N>

Ví dụ.
 Khi mục tiêu 'tuyến tính' được tải, thì nhật ký đo IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'tuyến tính' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=tuyến tính1,uuid=tuyến tính_uuid1,major=253,minor=2,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=28672,target_name=tuyến tính,target_version=1.4.0,
 device_name=253:1,start=2048;

5. gương
----------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'phản chiếu'.

::

target_attributes := <target_name> "," <target_version> "," <nr_mirrors> ","
                      <mirror_device_data> "," <handle_errors> "," <keep_log> "," <log_type_status> ";"

target_name := "target_name=mirror"
 target_version := "target_version=" <N> "." <N> "." <N>
 nr_mirrors := "nr_mirrors=" <NR>
 mirror_device_data := <mirror_device_row> | <mirror_device_data><mirror_device_row>
                       mirror_device_row được lặp lại <NR> lần - đối với <NR> được mô tả trong <nr_mirrors>.
 mirror_device_row := <mirror_device_name> "," <mirror_device_status>
 mirror_device_name := "mirror_device_" <X> "=" <mirror_device_name_str>
                       trong đó <X> nằm trong khoảng từ 0 đến (<NR> -1) - dành cho <NR> được mô tả trong <nr_mirrors>.
 mirror_device_status := "mirror_device_" <X> "_status=" <mirror_device_status_char>
                         trong đó <X> nằm trong khoảng từ 0 đến (<NR> -1) - dành cho <NR> được mô tả trong <nr_mirrors>.
 mirror_device_status_char := "A" ZZ0000ZZ "D" ZZ0001ZZ "R" | "Bạn"
 hand_errors := "handle_errors=" <yes_no>
 keep_log := "keep_log=" <yes_no>
 log_type_status := "log_type_status=" <log_type_status_str>
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'gương' được tải, thì nhật ký đo IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'gương' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=mirror1,uuid=mirror_uuid1,major=253,minor=6,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=2048,target_name=mirror,target_version=1.14.0,nr_mirrors=2,
    mirror_device_0=253:4,mirror_device_0_status=A,
    mirror_device_1=253:5,mirror_device_1_status=A,
 hand_errors=y,keep_log=n,log_type_status=;

6. đa đường
-------------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'đa đường'.

::

target_attributes := <target_name> "," <target_version> "," <nr_priority_groups>
                      ["," <pg_state> "," <priority_groups> "," <priority_group_paths>] ";"

target_name := "target_name=multipath"
 target_version := "target_version=" <N> "." <N> "." <N>
 nr_priority_groups := "nr_priority_groups=" <NPG>
 nhóm ưu tiên := <priority_groups_row>|<priority_groups_row><priority_groups>
 Prior_groups_row := "pg_state_" <X> "=" <pg_state_str> "," "nr_pgpaths_" <X> "=" <NPGP> ","
                        "path_selector_name_" <X> "=" <string> "," <priority_group_paths>
                        trong đó <X> nằm trong khoảng từ 0 đến (<NPG> -1) - dành cho <NPG> được mô tả trong <nr_priority_groups>.
 pg_state_str := "E" ZZ0000ZZ "D"
 <priority_group_paths> := <priority_group_paths_row> | <priority_group_paths_row><priority_group_paths>
 ưu tiên_group_paths_row := "path_name_" <X> "_" <Y> "=" <string> "," "is_active_" <X> "_" <Y> "=" <is_active_str>
                             "fail_count_" <X> "_" <Y> "=" <N> "," "path_selector_status_" <X> "_" <Y> "=" <path_selector_status_str>
                             trong đó <X> nằm trong khoảng từ 0 đến (<NPG> -1) - cho <NPG> được mô tả trong <nr_priority_groups>,
                             và <Y> nằm trong khoảng từ 0 đến (<NPGP> -1) - cho <NPGP> được mô tả trong <priority_groups_row>.
 is_active_str := "A" | "F"

Ví dụ.
 Khi mục tiêu 'đa đường' được tải, thì nhật ký đo IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'đa đường' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=mp,uuid=,major=253,minor=0,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=2097152,target_name=multipath,target_version=1.14.0,nr_priority_groups=2,
    pg_state_0=E,nr_pgpaths_0=2,path_selector_name_0=độ dài hàng đợi,
        path_name_0_0=8:16,is_active_0_0=A,fail_count_0_0=0,path_selector_status_0_0=,
        path_name_0_1=8:32,is_active_0_1=A,fail_count_0_1=0,path_selector_status_0_1=,
    pg_state_1=E,nr_pgpaths_1=2,path_selector_name_1=độ dài hàng đợi,
        path_name_1_0=8:48,is_active_1_0=A,fail_count_1_0=0,path_selector_status_1_0=,
        path_name_1_1=8:64,is_active_1_1=A,fail_count_1_1=0,path_selector_status_1_1=;

7. đột kích
-----------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'đột kích'.

::

target_attributes := <target_name> "," <target_version> "," <raid_type> "," <raid_disks> "," <raid_state>
                      <raid_device_status> ["," tạp chí_dev_mode] ";"

target_name := "target_name=đột kích"
 target_version := "target_version=" <N> "." <N> "." <N>
 raid_type := "raid_type=" <raid_type_str>
 raid_disks := "raid_disks=" <NRD>
 raid_state := "raid_state=" <raid_state_str>
 raid_state_str := "đông lạnh" ZZ0000ZZ"đồng bộ lại" ZZ0001ZZ "sửa chữa" ZZ0002ZZ "nhàn rỗi" |"undef"
 raid_device_status := <raid_device_status_row> | <raid_device_status_row><raid_device_status>
                       <raid_device_status_row> được lặp lại <NRD> lần - đối với <NRD> được mô tả trong <raid_disks>.
 raid_device_status_row := "raid_device_" <X> "_status=" <raid_device_status_str>
                           trong đó <X> nằm trong khoảng từ 0 đến (<NRD> -1) - dành cho <NRD> được mô tả trong <raid_disks>.
 raid_device_status_str := "A" ZZ0003ZZ "a" | "-"
 tạp chí_dev_mode := "journal_dev_mode=" <journal_dev_mode_str>
 tạp chí_dev_mode_str := "viết qua" ZZ0004ZZ "không hợp lệ"

Ví dụ.
 Khi mục tiêu 'đột kích' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả thuộc tính 'đột kích' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=raid_LV1,uuid=uuid_raid_LV1,major=253,minor=12,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=2048,target_name=raid,target_version=1.15.1,
 raid_type=raid10,raid_disks=4,raid_state=nhàn rỗi,
    raid_device_0_status=A,
    raid_device_1_status=A,
    raid_device_2_status=A,
    raid_device_3_status=A;


8. ảnh chụp nhanh
-----------------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'ảnh chụp nhanh'.

::

target_attributes := <target_name> "," <target_version> "," <snap_origin_name> ","
                      <snap_cow_name> "," <snap_valid> "," <snap_merge_failed> "," <snapshot_overflowed> ";"

target_name := "target_name=ảnh chụp nhanh"
 target_version := "target_version=" <N> "." <N> "." <N>
 snap_origin_name := "snap_origin_name=" <string>
 snap_cow_name := "snap_cow_name=" <string>
 snap_valid := "snap_valid=" <yes_no>
 snap_merge_failed := "snap_merge_failed=" <yes_no>
 snapshot_overflowed := "snapshot_overflowed=" <yes_no>
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'ảnh chụp nhanh' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'ảnh chụp nhanh' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=snap1,uuid=snap_uuid1,major=253,minor=13,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=4096,target_name=snapshot,target_version=1.16.0,
 snap_origin_name=253:11,snap_cow_name=253:12,snap_valid=y,snap_merge_failed=n,snapshot_overflowed=n;

9. sọc
-----------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'sọc'.

::

target_attributes := <target_name> "," <target_version> "," <stripes> "," <chunk_size> ","
                      <dữ liệu sọc> ";"

target_name := "target_name=sọc"
 target_version := "target_version=" <N> "." <N> "." <N>
 sọc := "sọc=" <NS>
 chunk_size := "chunk_size=" <N>
 sọc_data := <stripe_data_row>|<stripe_data><stripe_data_row>
 sọc_data_row := <stripe_device_name> "," <stripe_physical_start> "," <stripe_status>
 sọc_device_name := "sọc_" <X> "_device_name=" <stripe_device_name_str>
                       trong đó <X> nằm trong khoảng từ 0 đến (<NS> -1) - dành cho <NS> được mô tả trong <stripes>.
 sọc_physical_start := "sọc_" <X> "_physical_start=" <N>
                           trong đó <X> nằm trong khoảng từ 0 đến (<NS> -1) - dành cho <NS> được mô tả trong <stripes>.
 sọc_status := "sọc_" <X> "_status=" <stripe_status_str>
                  trong đó <X> nằm trong khoảng từ 0 đến (<NS> -1) - dành cho <NS> được mô tả trong <stripes>.
 sọc_status_str := "D" | "MỘT"

Ví dụ.
 Khi mục tiêu 'sọc' được tải, thì nhật ký đo IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả các thuộc tính 'sọc' được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=striped1,uuid=striped_uuid1,major=253,minor=5,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=640,target_name=striped,target_version=1.6.0,stripes=2,chunk_size=64,
    sọc_0_device_name=253:0,stripe_0_physical_start=2048,stripe_0_status=A,
    sọc_1_device_name=253:3,stripe_1_physical_start=2048,stripe_1_status=A;

10. sự thật
-----------
'target_attributes' (được mô tả như một phần của EVENT_DATA trong 'Tải bảng'
phần trên) có định dạng dữ liệu sau cho mục tiêu 'xác thực'.

::

target_attributes := <target_name> "," <target_version> "," <hash_failed> "," <verity_version> ","
                      <data_device_name> "," <hash_device_name> "," <verity_algorithm> "," <root_digest> ","
                      <salt> "," <ignore_zero_blocks> "," <check_at_most_once> ["," <root_hash_sig_key_desc>]
                      ["," <verity_mode>] ";"

target_name := "target_name=verity"
 target_version := "target_version=" <N> "." <N> "." <N>
 hash_failed := "hash_failed=" <hash_failed_str>
 hash_failed_str := "C" | "V"
 verity_version := "verity_version=" <verity_version_str>
 data_device_name := "data_device_name=" <data_device_name_str>
 hash_device_name := "hash_device_name=" <hash_device_name_str>
 verity_algorithm := "verity_algorithm=" <verity_algorithm_str>
 root_digest := "root_digest=" <root_digest_str>
 muối := "muối=" <salt_str>
 salt_str := "-" <verity_salt_str>
 bỏ qua_zero_blocks := "ignore_zero_blocks=" <yes_no>
 check_at_most_once := "check_at_most_once=" <yes_no>
 root_hash_sig_key_desc := "root_hash_sig_key_desc="
 verity_mode := "verity_mode=" <verity_mode_str>
 verity_mode_str := "ignore_corruption" ZZ0000ZZ "panic_on_corruption" | "không hợp lệ"
 có_không := "y" | "N"

Ví dụ.
 Khi mục tiêu 'xác thực' được tải, thì nhật ký đo lường IMA ASCII sẽ có một mục nhập
 tương tự như sau, mô tả những thuộc tính 'chân thực' nào được đo trong EVENT_DATA
 cho sự kiện 'dm_table_load'.
 (được chuyển đổi từ ASCII thành văn bản để dễ đọc)

dm_version=4.45.0;
 name=test-verity,uuid=,major=253,minor=2,minor_count=1,num_targets=1;
 target_index=0,target_begin=0,target_len=1953120,target_name=verity,target_version=1.8.0,hash_failed=V,
 verity_version=1,data_device_name=253:1,hash_device_name=253:0,verity_algorithm=sha256,
 root_digest=29cb87e60ce7b12b443ba6008266f3e41e93e403d7f298f8e3f316b29ff89c5e,
 muối=e48da609055204e89ae53b655ca2216dd983cf3cb829f34f63a297d106d53e2d,
 bỏ qua_zero_blocks=n,check_at_most_once=n;
