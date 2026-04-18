.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/functionfs-desc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================
Bộ mô tả FunctionFS
======================

Một số mô tả có thể được ghi vào tiện ích FFS là
được mô tả dưới đây. Mô tả thiết bị và cấu hình được xử lý
bởi tiện ích tổng hợp và không được người dùng ghi vào
Tiện ích FFS.

Bộ mô tả được ghi vào tệp "ep0" trong tiện ích FFS
theo tiêu đề mô tả.

.. kernel-doc:: include/uapi/linux/usb/functionfs.h
   :doc: descriptors

Bộ mô tả giao diện
---------------------

Bộ mô tả giao diện USB tiêu chuẩn có thể được viết. Lớp/lớp con của
bộ mô tả giao diện gần đây nhất xác định loại cụ thể của lớp
mô tả được chấp nhận.

Bộ mô tả cụ thể theo lớp
--------------------------

Các mô tả dành riêng cho lớp chỉ được chấp nhận cho lớp/lớp con của
mô tả giao diện gần đây nhất. Sau đây là một số
mô tả lớp cụ thể được hỗ trợ.

Bộ mô tả chức năng DFU
~~~~~~~~~~~~~~~~~~~~~~~~~

Khi lớp giao diện là USB_CLASS_APP_SPEC và lớp con giao diện
là USB_SUBCLASS_DFU, có thể cung cấp bộ mô tả chức năng DFU.
Bộ mô tả chức năng DFU được mô tả trong đặc tả USB cho
Nâng cấp chương trình cơ sở thiết bị (DFU), phiên bản 1.1 tính đến thời điểm viết bài này.

.. kernel-doc:: include/uapi/linux/usb/functionfs.h
   :doc: usb_dfu_functional_descriptor
