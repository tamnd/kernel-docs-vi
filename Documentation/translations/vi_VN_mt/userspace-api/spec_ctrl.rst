.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/spec_ctrl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Kiểm soát đầu cơ
===================

Khá nhiều CPU có các tính năng sai liên quan đến suy đoán.
lỗ hổng thực tế gây rò rỉ dữ liệu dưới nhiều hình thức khác nhau, thậm chí trên khắp
các miền đặc quyền.

Hạt nhân cung cấp khả năng giảm thiểu các lỗ hổng như vậy trong nhiều
các hình thức. Một số biện pháp giảm thiểu này có thể cấu hình được trong thời gian biên dịch và một số
có thể được cung cấp trên dòng lệnh kernel.

Ngoài ra còn có một loại biện pháp giảm thiểu rất tốn kém, nhưng chúng có thể
bị hạn chế ở một tập hợp các quy trình hoặc nhiệm vụ nhất định được kiểm soát
môi trường. Cơ chế kiểm soát các biện pháp giảm nhẹ này là thông qua
ZZ0000ZZ.

Có hai tùy chọn prctl có liên quan đến điều này:

* PR_GET_SPECULATION_CTRL

* PR_SET_SPECULATION_CTRL

PR_GET_SPECULATION_CTRL
-----------------------

PR_GET_SPECULATION_CTRL trả về trạng thái sai sót đầu cơ
được chọn bằng arg2 của prctl(2). Giá trị trả về sử dụng các bit 0-3 với
ý nghĩa sau đây (với lời cảnh báo rằng PR_SPEC_L1D_FLUSH ít rõ ràng hơn
ngữ nghĩa, hãy xem tài liệu về điều khiển cụ thể đó bên dưới):

==== =============================================================================
Mô tả xác định bit
==== =============================================================================
0 PR_SPEC_PRCTL Việc giảm thiểu có thể được kiểm soát trên mỗi tác vụ bằng cách
                            PR_SET_SPECULATION_CTRL.
1 PR_SPEC_ENABLE Tính năng suy đoán được bật, tính năng giảm thiểu được kích hoạt
                            bị vô hiệu hóa.
2 PR_SPEC_DISABLE Tính năng suy đoán bị tắt, tính năng giảm thiểu bị tắt
                            đã bật.
3 PR_SPEC_FORCE_DISABLE Tương tự như PR_SPEC_DISABLE nhưng không thể hoàn tác. A
                            prctl(..., PR_SPEC_ENABLE) tiếp theo sẽ thất bại.
4 PR_SPEC_DISABLE_NOEXEC Tương tự như PR_SPEC_DISABLE, nhưng trạng thái sẽ là
                            đã xóa trên ZZ0000ZZ.
==== =============================================================================

Nếu tất cả các bit bằng 0 thì CPU không bị ảnh hưởng bởi tính năng suy đoán sai.

Nếu PR_SPEC_PRCTL được đặt thì việc kiểm soát giảm thiểu theo mỗi tác vụ sẽ là
có sẵn. Nếu không được đặt, prctl(PR_SET_SPECULATION_CTRL) cho suy đoán
tính năng sai sẽ thất bại.

.. _set_spec_ctrl:

PR_SET_SPECULATION_CTRL
-----------------------

PR_SET_SPECULATION_CTRL cho phép kiểm soát tính năng sai suy đoán,
được chọn bởi arg2 của ZZ0000ZZ cho mỗi tác vụ. arg3 được sử dụng để bàn tay
trong giá trị điều khiển, tức là PR_SPEC_ENABLE hoặc PR_SPEC_DISABLE hoặc
PR_SPEC_FORCE_DISABLE.

Mã lỗi phổ biến
------------------
======= =======================================================================
Giá trị Ý nghĩa
======= =======================================================================
EINVAL Prctl không được triển khai theo kiến trúc hoặc không được sử dụng
        đối số prctl(2) không bằng 0.

ENODEV arg2 đang chọn một tính năng sai suy đoán không được hỗ trợ.
======= =======================================================================

Mã lỗi PR_SET_SPECULATION_CTRL
-----------------------------------
======= =======================================================================
Giá trị Ý nghĩa
======= =======================================================================
0 Thành công

ERANGE arg3 không chính xác, tức là không phải PR_SPEC_ENABLE hay
        PR_SPEC_DISABLE hay PR_SPEC_FORCE_DISABLE.

ENXIO Dành cho PR_SPEC_STORE_BYPASS: kiểm soát tính năng sai suy đoán đã chọn
        không thể thực hiện được qua prctl do cấu hình khởi động của hệ thống.

EPERM Suy đoán đã bị vô hiệu hóa với PR_SPEC_FORCE_DISABLE và người gọi đã cố gắng
        kích hoạt nó một lần nữa.

EPERM Đối với PR_SPEC_L1D_FLUSH và PR_SPEC_INDIRECT_BRANCH: điều khiển
        không thể giảm nhẹ do cấu hình khởi động của hệ thống.

======= =======================================================================

Kiểm soát tính năng sai suy đoán
-------------------------------
- PR_SPEC_STORE_BYPASS: Bỏ qua cửa hàng đầu cơ

Lời kêu gọi:
   * prctl(PR_GET_SPECULATION_CTRL, PR_SPEC_STORE_BYPASS, 0, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_STORE_BYPASS, PR_SPEC_ENABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_STORE_BYPASS, PR_SPEC_DISABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_STORE_BYPASS, PR_SPEC_FORCE_DISABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_STORE_BYPASS, PR_SPEC_DISABLE_NOEXEC, 0, 0);

- PR_SPEC_INDIR_BRANCH: Suy đoán nhánh gián tiếp trong quy trình người dùng
                        (Giảm thiểu các cuộc tấn công kiểu Spectre V2 chống lại quy trình của người dùng)

Lời kêu gọi:
   * prctl(PR_GET_SPECULATION_CTRL, PR_SPEC_INDIRECT_BRANCH, 0, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_INDIRECT_BRANCH, PR_SPEC_ENABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_INDIRECT_BRANCH, PR_SPEC_DISABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_INDIRECT_BRANCH, PR_SPEC_FORCE_DISABLE, 0, 0);

- PR_SPEC_L1D_FLUSH: Xóa bộ nhớ đệm L1D khi chuyển ngữ cảnh ra khỏi tác vụ
                        (chỉ hoạt động khi các tác vụ chạy trên lõi không phải SMT)

Đối với điều khiển này, PR_SPEC_ENABLE có nghĩa là ZZ0000ZZ được bật (L1D
bị xóa), PR_SPEC_DISABLE có nghĩa là nó bị vô hiệu hóa.

Lời kêu gọi:
   * prctl(PR_GET_SPECULATION_CTRL, PR_SPEC_L1D_FLUSH, 0, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_L1D_FLUSH, PR_SPEC_ENABLE, 0, 0);
   * prctl(PR_SET_SPECULATION_CTRL, PR_SPEC_L1D_FLUSH, PR_SPEC_DISABLE, 0, 0);
