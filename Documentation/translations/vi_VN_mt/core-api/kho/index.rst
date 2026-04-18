.. SPDX-License-Identifier: GPL-2.0-or-later

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/core-api/kho/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _kho-concepts:

===========================
Hệ thống con chuyển giao Kexec
========================

Tổng quan
========

Kexec HandOver (KHO) là cơ chế cho phép Linux bảo toàn bộ nhớ
các vùng có thể chứa các trạng thái hệ thống được tuần tự hóa trên kexec.

KHO sử dụng ZZ0000ZZ để truyền thông tin về
trạng thái được bảo toàn từ kernel pre-exec đến kernel post-kexec và ZZ0001ZZ để đảm bảo tính toàn vẹn của bộ nhớ được bảo toàn.

.. _kho_fdt:

KHO FDT
=======
Mỗi kexec KHO đều mang một blob cây thiết bị phẳng (FDT) dành riêng cho KHO
mô tả trạng thái được bảo tồn. FDT bao gồm các thuộc tính mô tả được bảo quản
các vùng bộ nhớ và các nút chứa trạng thái cụ thể của hệ thống con.

Các vùng bộ nhớ được bảo toàn chứa các trạng thái hệ thống con được tuần tự hóa hoặc
dữ liệu trong bộ nhớ sẽ không được chạm vào trên kexec. Sau KHO, các hệ thống con
có thể truy xuất và khôi phục trạng thái được bảo toàn từ KHO FDT.

Các hệ thống con tham gia KHO có thể xác định định dạng trạng thái riêng của chúng
tuần tự hóa và bảo quản.

KHO FDT và các cấu trúc được xác định bởi các hệ thống con tạo thành ABI giữa tiền kexec
và hạt nhân hậu kexec. ABI này được xác định bởi các tệp tiêu đề trong
Thư mục ZZ0000ZZ.

.. toctree::
   :maxdepth: 1

   abi.rst

.. _kho_scratch:

Vùng cào
===============

Để khởi động vào kexec, chúng ta cần có một phạm vi bộ nhớ liền kề về mặt vật lý
không chứa bộ nhớ được chuyển giao. Kexec sau đó đặt kernel đích và initrd
vào khu vực đó. Kernel mới chỉ sử dụng vùng này cho bộ nhớ
phân bổ trước khi khởi động cho đến khi khởi tạo bộ cấp phát trang.

Chúng tôi đảm bảo rằng chúng tôi luôn có những vùng như vậy thông qua các vùng đầu: Trên
lần khởi động đầu tiên KHO phân bổ một số vùng bộ nhớ liền kề về mặt vật lý. Kể từ khi
sau kexec, các vùng này sẽ được sử dụng để phân bổ bộ nhớ sớm, có một
vùng đầu trên mỗi nút NUMA cộng với một vùng đầu để đáp ứng phân bổ
các yêu cầu không yêu cầu gán nút NUMA cụ thể.
Theo mặc định, kích thước của vùng đầu được tính dựa trên dung lượng bộ nhớ
được phân bổ trong quá trình khởi động. Tùy chọn dòng lệnh kernel ZZ0000ZZ có thể
được sử dụng để xác định rõ ràng kích thước của các vùng đầu.
Các vùng đầu tiên được khai báo là CMA khi bộ cấp phát trang được khởi tạo để
rằng bộ nhớ của họ có thể được sử dụng trong suốt thời gian tồn tại của hệ thống. CMA cung cấp cho chúng tôi
đảm bảo rằng không có trang chuyển giao nào nằm trong khu vực đó, bởi vì các trang chuyển giao
phải ở một vị trí bộ nhớ vật lý tĩnh và CMA chỉ thực thi điều đó
các trang di chuyển có thể được đặt bên trong.

Sau kexec KHO, chúng tôi bỏ qua tùy chọn dòng lệnh kernel ZZ0000ZZ và
thay vào đó hãy sử dụng lại chính xác khu vực đã được phân bổ ban đầu. Điều này cho phép
chúng tôi thực hiện đệ quy bất kỳ số lượng kexecs KHO nào. Bởi vì chúng tôi đã sử dụng khu vực này
để phân bổ bộ nhớ khởi động và làm bộ nhớ đích cho các đốm màu kexec, một số phần
của vùng nhớ đó có thể được dành riêng. Những bảo lưu này không liên quan đến
KHO tiếp theo, vì kexec có thể ghi đè lên cả kernel gốc.

Cây cơ số bàn giao Kexec
=========================

.. kernel-doc:: include/linux/kho_radix_tree.h
  :doc: Kexec Handover Radix Tree

API công khai
==========

.. kernel-doc:: kernel/liveupdate/kexec_handover.c
  :export:

Xem thêm
========

-ZZ0000ZZ