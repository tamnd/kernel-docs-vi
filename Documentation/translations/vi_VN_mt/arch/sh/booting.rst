.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/sh/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Khởi động DeviceTree
------------------

Bộ tải khởi động SH tương thích với cây thiết bị được kỳ vọng sẽ cung cấp khả năng vật lý
  địa chỉ của blob cây thiết bị trong r4. Vì bộ tải khởi động kế thừa không
  đảm bảo mọi trạng thái đăng ký ban đầu cụ thể, các hạt nhân được xây dựng để
  tương tác với các bộ tải khởi động cũ phải sử dụng DTB tích hợp hoặc
  chọn tùy chọn bảng kế thừa (thứ gì đó không phải là CONFIG_SH_DEVICE_TREE)
  không sử dụng cây thiết bị. Hỗ trợ cho cái sau đang bị loại bỏ
  ủng hộ cây thiết bị.