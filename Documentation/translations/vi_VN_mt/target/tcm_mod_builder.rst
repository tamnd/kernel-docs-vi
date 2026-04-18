.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/target/tcm_mod_builder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Trình tạo tập lệnh mô-đun vải TCM v4
=========================================

Xin chào tất cả,

Tài liệu này được dự định là một HOWTO nhỏ để sử dụng tcm_mod_builder.py
tập lệnh để tạo mô-đun .ko vải TCM v4 chức năng hoàn toàn mới của riêng bạn,
sau khi được xây dựng có thể được tải ngay lập tức để bắt đầu truy cập TCM/ConfigFS mới
bộ xương vải, chỉ bằng cách sử dụng ::

đầu dò mod $TCM_NEW_MOD
	mkdir -p /sys/kernel/config/target/$TCM_NEW_MOD

Tập lệnh này sẽ tạo trình điều khiển/mục tiêu/$TCM_NEW_MOD/ mới và sẽ thực hiện như sau

1) Tạo trình gọi API mới cho logic trình điều khiển/mục tiêu/target_core_fabric_configs.c
	   ->make_tpg(), ->drop_tpg(), ->make_wwn(), ->drop_wwn().  Những thứ này được tạo ra
	   vào $TCM_NEW_MOD/$TCM_NEW_MOD_configfs.c
	2) Tạo cơ sở hạ tầng cơ bản để tải/dỡ LKM và mô-đun vải TCM/ConfigFS
	   sử dụng mẫu cấu trúc khung xương target_core_fabric_ops API.
	3) Dựa trên T10 Proto_Ident do người dùng xác định cho mô-đun vải mới đang được xây dựng,
	   các trình xử lý liên quan đến TransportID / Initiator và Target WWPN cho
	   Đặt trước liên tục SPC-3 được tạo tự động trong $TCM_NEW_MOD/$TCM_NEW_MOD_fabric.c
	   sử dụng logic trình điều khiển/mục tiêu/target_core_fabric_lib.c.
	4) NOP API gọi tất cả đường dẫn I/O dữ liệu khác và logic thuộc tính phụ thuộc kết cấu
	   bằng $TCM_NEW_MOD/$TCM_NEW_MOD_fabric.c

tcm_mod_builder.py phụ thuộc vào '-p $PROTO_IDENT' và '-m bắt buộc
tham số $FABRIC_MOD_name' và thực tế việc chạy tập lệnh trông giống như::

mục tiêu:/mnt/sdb/lio-core-2.6.git/Documentation/target# python tcm_mod_builder.py -p iSCSI -m tcm_nab5000
  tcm_dir: /mnt/sdb/lio-core-2.6.git/Documentation/target/../../
  Đặt tên vải_mod_: tcm_nab5000
  Đặt Fabric_mod_dir:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000
  Sử dụng proto_ident: iSCSI
  Tạo Fabric_mod_dir:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/tcm_nab5000_base.h
  Sử dụng tcm_mod_scan_fabric_ops:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../include/target/target_core_fabric_ops.h
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/tcm_nab5000_fabric.c
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/tcm_nab5000_fabric.h
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/tcm_nab5000_configfs.c
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/Kbuild
  Viết tập tin:
  /mnt/sdb/lio-core-2.6.git/Documentation/target/../../drivers/target/tcm_nab5000/Kconfig
  Bạn có muốn thêm tcm_nab5000 vào trình điều khiển/mục tiêu/Kbuild..? [có, không]: có
  Bạn có muốn thêm tcm_nab5000 vào trình điều khiển/đích/Kconfig..? [có, không]: có

Ở cuối tcm_mod_builder.py. kịch bản sẽ yêu cầu thêm vào như sau
dòng tới trình điều khiển/mục tiêu/Kbuild::

obj-$(CONFIG_TCM_NAB5000) += tcm_nab5000/

và tương tự cho trình điều khiển/đích/Kconfig::

nguồn "trình điều khiển/đích/tcm_nab5000/Kconfig"

#) Chạy 'make menuconfig' và chọn mục CONFIG_TCM_NAB5000 mới::

<M> Mô-đun vải TCM_NAB5000

#) Xây dựng bằng cách sử dụng 'tạo mô-đun', sau khi hoàn thành, bạn sẽ có ::

mục tiêu:/mnt/sdb/lio-core-2.6.git# ls -la driver/target/tcm_nab5000/
    tổng cộng 1348
    drwxr-xr-x 2 gốc gốc 4096 2010-10-05 03:23 .
    drwxr-xr-x 9 gốc gốc 4096 2010-10-05 03:22 ..
    -rw-r--r-- 1 gốc gốc 282 2010-10-05 03:22 Kbuild
    -rw-r--r-- 1 gốc gốc 171 2010-10-05 03:22 Kconfig
    -rw-r--r-- 1 gốc gốc 49 2010-10-05 03:23 module.order
    -rw-r--r-- 1 gốc gốc 738 2010-10-05 03:22 tcm_nab5000_base.h
    -rw-r--r-- 1 gốc gốc 9096 2010-10-05 03:22 tcm_nab5000_configfs.c
    -rw-r--r-- 1 gốc 191200 2010-10-05 03:23 tcm_nab5000_configfs.o
    -rw-r--r-- 1 gốc gốc 40504 2010-10-05 03:23 .tcm_nab5000_configfs.o.cmd
    -rw-r--r-- 1 gốc gốc 5414 2010-10-05 03:22 tcm_nab5000_fabric.c
    -rw-r--r-- 1 gốc 2016 2010-10-05 03:22 tcm_nab5000_fabric.h
    -rw-r--r-- 1 gốc 190932 2010-10-05 03:23 tcm_nab5000_fabric.o
    -rw-r--r-- 1 gốc 40713 2010-10-05 03:23 .tcm_nab5000_fabric.o.cmd
    -rw-r--r-- 1 gốc 401861 2010-10-05 03:23 tcm_nab5000.ko
    -rw-r--r-- 1 gốc 265 2010-10-05 03:23 .tcm_nab5000.ko.cmd
    -rw-r--r-- 1 gốc 459 2010-10-05 03:23 tcm_nab5000.mod.c
    -rw-r--r-- 1 gốc 23896 2010-10-05 03:23 tcm_nab5000.mod.o
    -rw-r--r-- 1 gốc 22655 2010-10-05 03:23 .tcm_nab5000.mod.o.cmd
    -rw-r--r-- 1 gốc 379022 2010-10-05 03:23 tcm_nab5000.o
    -rw-r--r-- 1 gốc 211 2010-10-05 03:23 .tcm_nab5000.o.cmd

#) Tải mô-đun mới, tạo nhóm cấu hình lun_0 và thêm lõi TCM mới
   IBLOCK liên kết tượng trưng backstore tới cổng::

mục tiêu:/mnt/sdb/lio-core-2.6.git# insmod trình điều khiển/target/tcm_nab5000.ko
    mục tiêu:/mnt/sdb/lio-core-2.6.git# mkdir -p /sys/kernel/config/target/nab5000/iqn.foo/tpgt_1/lun/lun_0
    mục tiêu:/mnt/sdb/lio-core-2.6.git# cd /sys/kernel/config/target/nab5000/iqn.foo/tpgt_1/lun/lun_0/
    mục tiêu:/sys/kernel/config/target/nab5000/iqn.foo/tpgt_1/lun/lun_0# ln -s /sys/kernel/config/target/core/iblock_0/lvm_test0 nab5000_port

mục tiêu:/sys/kernel/config/target/nab5000/iqn.foo/tpgt_1/lun/lun_0# cd -
    mục tiêu:/mnt/sdb/lio-core-2.6.git# tree /sys/kernel/config/target/nab5000/
    /sys/kernel/config/target/nab5000/
    |-- khám phá_auth
    |-- iqn.foo
    |   ZZ0000ZZ-- lun_0
    ZZ0002ZZ |-- alua_tg_pt_gp
    ZZ0003ZZ |-- alua_tg_pt_offline
    ZZ0004ZZ |-- alua_tg_pt_status
    ZZ0005ZZ |-- alua_tg_pt_write_md
    ZZ0006ZZ ZZ0001ZZ-- thông số
    `-- phiên bản

mục tiêu:/mnt/sdb/lio-core-2.6.git# lsmod
    Kích thước mô-đun được sử dụng bởi
    tcm_nab5000 3935 4
    iscsi_target_mod 193211 0
    target_core_stgt 8090 0
    target_core_pscsi 11122 1
    target_core_file 9172 2
    target_core_iblock 9280 1
    target_core_mod 228575 31
    tcm_nab5000,iscsi_target_mod,target_core_stgt,target_core_pscsi,target_core_file,target_core_iblock
    libfc 73681 0
    scsi_debug 56265 0
    scsi_tgt 8666 1 target_core_stgt
    configfs 20644 2 target_core_mod

----------------------------------------------------------------------

Các mặt hàng TODO trong tương lai
=================

1) Thêm nhiều proto_idents T10
	2) Làm cho tcm_mod_dump_fabric_ops() thông minh hơn và tạo con trỏ hàm
	   defs trực tiếp từ include/target/target_core_fabric_ops.h:struct target_core_fabric_ops
	   các thành viên cấu trúc.

Ngày 5 tháng 10 năm 2010

Nicholas A. Bellinger <nab@linux-iscsi.org>
