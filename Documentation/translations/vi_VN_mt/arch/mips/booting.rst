.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/mips/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Khởi động cây thiết bị BMIPS
------------------------

Một số bộ nạp khởi động chỉ hỗ trợ một điểm vào duy nhất, khi bắt đầu
  hình ảnh hạt nhân.  Các bộ tải khởi động khác sẽ chuyển đến địa chỉ bắt đầu ELF.
  Cả hai chương trình đều được hỗ trợ; CONFIG_BOOT_RAW=y và CONFIG_NO_EXCEPT_FILL=y,
  vì vậy lệnh đầu tiên ngay lập tức chuyển tới kernel_entry().

Tương tự như trường hợp vòm/cánh tay (b), bộ tải khởi động nhận biết DT dự kiến sẽ
  thiết lập các thanh ghi sau:

a0 : 0

a1 : 0xffffffff

a2 : Con trỏ vật lý tới khối cây thiết bị (được định nghĩa trong chương
         II) trong RAM.  Cây thiết bị có thể được đặt ở bất cứ đâu trong phần đầu tiên
         512 MB không gian địa chỉ vật lý (0x00000000 - 0x1fffffff),
         căn chỉnh trên ranh giới 64 bit.

Các bộ tải khởi động kế thừa không sử dụng quy ước này và chúng không chuyển vào
  khối DT.  Trong trường hợp này, Linux sẽ tìm kiếm DTB dựng sẵn, được chọn thông qua
  CONFIG_DT_*.

Quy ước này chỉ được xác định cho hệ thống 32-bit, vì không có
  hiện tại mọi triển khai BMIPS 64 bit.