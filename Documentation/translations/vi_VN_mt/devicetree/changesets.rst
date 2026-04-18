.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/changesets.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================
Bộ thay đổi Devicetree
=====================

Bộ thay đổi Devicetree là một phương pháp cho phép một người áp dụng các thay đổi
trong cây sống theo cách mà toàn bộ các thay đổi
sẽ được áp dụng, hoặc không có điều nào trong số đó sẽ được áp dụng. Nếu xảy ra lỗi giữa chừng
thông qua việc áp dụng bộ thay đổi, sau đó cây sẽ được khôi phục về
trạng thái trước đó. Một bộ thay đổi cũng có thể được gỡ bỏ sau khi nó đã được
áp dụng.

Khi một tập hợp thay đổi được áp dụng, tất cả các thay đổi sẽ được áp dụng cho cây
cùng một lúc trước khi phát ra thông báo OF_RECONFIG. Điều này là để
người nhận nhìn thấy trạng thái đầy đủ và nhất quán của cây khi nó
nhận được người thông báo.

Trình tự của một bộ thay đổi như sau.

1. of_changeset_init() - khởi tạo một bộ thay đổi

2. Một số lệnh gọi thay đổi cây DT, of_changeset_attach_node(),
   of_changeset_detach_node(), of_changeset_add_property(),
   of_changeset_remove_property, of_changeset_update_property() để chuẩn bị
   một tập hợp các thay đổi Không có thay đổi nào đối với cây đang hoạt động được thực hiện tại thời điểm này.
   Tất cả các hoạt động thay đổi được ghi lại trong 'mục' of_changeset
   danh sách.

3. of_changeset_apply() - Áp dụng các thay đổi cho cây. Hoặc là
   toàn bộ tập hợp thay đổi sẽ được áp dụng hoặc nếu có lỗi thì cây sẽ
   được khôi phục lại trạng thái trước đó. Cốt lõi đảm bảo tuần tự hóa thích hợp
   thông qua việc khóa. Đã có phiên bản mở khóa __of_changeset_apply,
   nếu cần.

Nếu cần xóa một bộ thay đổi được áp dụng thành công, có thể thực hiện được
với of_changeset_revert().