.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/refcount-vs-atomic.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
refcount_t API so với Atomic_t
======================================

.. contents:: :local:

Giới thiệu
============

Mục tiêu của refcount_t API là cung cấp API tối thiểu để triển khai
bộ đếm tham chiếu của một đối tượng. Trong khi một kiến trúc chung độc lập
việc triển khai từ lib/refcount.c sử dụng các hoạt động nguyên tử bên dưới,
có một số khác biệt giữa một số ZZ0000ZZ và
ZZ0001ZZ hoạt động liên quan đến việc đảm bảo thứ tự bộ nhớ.
Tài liệu này nêu ra những khác biệt và cung cấp các ví dụ tương ứng
để giúp người bảo trì xác thực mã của họ trước sự thay đổi trong
những đảm bảo thứ tự bộ nhớ này.

Các thuật ngữ được sử dụng trong tài liệu này cố gắng tuân theo LKMM chính thức được xác định trong
công cụ/mô hình bộ nhớ/Tài liệu/explanation.txt.

Memory-barriers.txt và Atomic_t.txt cung cấp thêm thông tin cơ bản cho
thứ tự bộ nhớ nói chung và cho các hoạt động nguyên tử nói riêng.

Các loại thứ tự bộ nhớ có liên quan
=================================

.. note:: The following section only covers some of the memory
   ordering types that are relevant for the atomics and reference
   counters and used through this document. For a much broader picture
   please consult memory-barriers.txt document.

Trong trường hợp không có bất kỳ đảm bảo thứ tự bộ nhớ nào (tức là hoàn toàn không có thứ tự)
nguyên tử & bộ đếm lại chỉ cung cấp tính nguyên tử và
quan hệ thứ tự chương trình (po) (trên cùng CPU). Nó đảm bảo rằng
mỗi hoạt động ZZ0000ZZ và ZZ0001ZZ là nguyên tử và hướng dẫn
được thực thi theo thứ tự chương trình trên một CPU.
Điều này được thực hiện bằng cách sử dụng READ_ONCE()/WRITE_ONCE() và
so sánh và hoán đổi nguyên thủy.

Thứ tự bộ nhớ mạnh (đầy đủ) đảm bảo rằng tất cả các lần tải và
lưu trữ (tất cả các hướng dẫn trước đó) trên cùng một CPU đã được hoàn thành
trước khi bất kỳ lệnh sau nào được thực thi trên cùng CPU.
Nó cũng đảm bảo rằng tất cả các cửa hàng trước đó trên cùng một CPU
và tất cả các kho lưu trữ được truyền từ các CPU khác phải được truyền tới tất cả
các CPU khác trước khi bất kỳ lệnh sau nào được thực thi trên bản gốc
CPU (Thuộc tính tích lũy A). Điều này được thực hiện bằng cách sử dụng smp_mb().

Thứ tự bộ nhớ RELEASE đảm bảo rằng tất cả các lần tải và
lưu trữ (tất cả các hướng dẫn trước đó) trên cùng một CPU đã được hoàn thành
trước khi phẫu thuật. Nó cũng đảm bảo rằng tất cả các po-trước đó
lưu trữ trên cùng một CPU và tất cả các cửa hàng được truyền từ các CPU khác
phải truyền tới tất cả các CPU khác trước hoạt động giải phóng
(A-tài sản tích lũy). Điều này được thực hiện bằng cách sử dụng
smp_store_release().

Thứ tự bộ nhớ ACQUIRE đảm bảo rằng tất cả các lần tải bài và
lưu trữ (tất cả các hướng dẫn sau) trên cùng một CPU được
hoàn thành sau hoạt động mua lại. Nó cũng đảm bảo rằng tất cả
các cửa hàng sau này trên cùng một CPU phải truyền tới tất cả các CPU khác
sau khi hoạt động thu được thực hiện. Điều này được thực hiện bằng cách sử dụng
smp_acquire__after_ctrl_dep().

Sự phụ thuộc kiểm soát (vào thành công) đối với người giới thiệu lại đảm bảo rằng
nếu một tham chiếu cho một đối tượng được lấy thành công (tham chiếu
việc tăng hoặc cộng bộ đếm xảy ra, hàm trả về true),
sau đó các cửa hàng tiếp theo được lệnh chống lại hoạt động này.
Kiểm soát sự phụ thuộc vào các cửa hàng không được triển khai bằng cách sử dụng bất kỳ
rào cản, nhưng dựa vào CPU để không đầu cơ vào các cửa hàng. Đây chỉ là
một mối quan hệ CPU duy nhất và không đảm bảo cho các CPU khác.


So sánh các chức năng
=======================

trường hợp 1) - hoạt động không phải "Đọc/Sửa đổi/Ghi" (RMW)
-------------------------------------------

Thay đổi chức năng:

* Atomic_set() --> refcount_set()
 * Atomic_read() --> refcount_read()

Thay đổi đảm bảo thứ tự bộ nhớ:

* không có (cả hai đều không có thứ tự)


trường hợp 2) - hoạt động không phải "Đọc/Sửa đổi/Ghi" (RMW) với thứ tự phát hành
-----------------------------------------------------------------

Thay đổi chức năng:

* Atomic_set_release() --> refcount_set_release()

Thay đổi đảm bảo thứ tự bộ nhớ:

* không có (cả hai đều cung cấp thứ tự RELEASE)


trường hợp 3) - các hoạt động dựa trên gia tăng không trả về giá trị
--------------------------------------------------

Thay đổi chức năng:

* Atomic_inc() --> refcount_inc()
 * Atomic_add() --> refcount_add()

Thay đổi đảm bảo thứ tự bộ nhớ:

* không có (cả hai đều không có thứ tự)

trường hợp 4) - các hoạt động RMW dựa trên giảm dần không trả về giá trị
------------------------------------------------------

Thay đổi chức năng:

* Atomic_dec() --> refcount_dec()

Thay đổi đảm bảo thứ tự bộ nhớ:

* hoàn toàn không có thứ tự --> Đặt hàng RELEASE


trường hợp 5) - các hoạt động RMW dựa trên gia số trả về một giá trị
-----------------------------------------------------

Thay đổi chức năng:

* Atomic_inc_not_zero() --> refcount_inc_not_zero()
 * không có bản sao nguyên tử --> refcount_add_not_zero()

Thứ tự bộ nhớ đảm bảo thay đổi:

* đã đặt hàng đầy đủ --> kiểm soát sự phụ thuộc vào thành công của cửa hàng

.. note:: We really assume here that necessary ordering is provided as a
   result of obtaining pointer to the object!


trường hợp 6) - các hoạt động RMW dựa trên mức tăng với thứ tự thu được trả về một giá trị
---------------------------------------------------------------------------

Thay đổi chức năng:

* Atomic_inc_not_zero() --> refcount_inc_not_zero_acquire()
 * không có đối tác nguyên tử --> refcount_add_not_zero_acquire()

Thứ tự bộ nhớ đảm bảo thay đổi:

* đã đặt hàng đầy đủ --> ACQUIRE đặt hàng thành công


trường hợp 7) - các hoạt động RMW dựa trên mức giảm dec/phụ chung trả về một giá trị
---------------------------------------------------------------------

Thay đổi chức năng:

* Atomic_dec_and_test() --> refcount_dec_and_test()
 * Atomic_sub_and_test() --> refcount_sub_and_test()

Thứ tự bộ nhớ đảm bảo thay đổi:

* đã đặt hàng đầy đủ --> đặt hàng RELEASE + đặt hàng ACQUIRE thành công


trường hợp 8) các hoạt động RMW dựa trên mức giảm khác trả về một giá trị
---------------------------------------------------------

Thay đổi chức năng:

* không có bản sao nguyên tử --> refcount_dec_if_one()
 * ZZ0000ZZ --> ZZ0001ZZ

Thứ tự bộ nhớ đảm bảo thay đổi:

* được đặt hàng đầy đủ --> Đặt hàng RELEASE + phụ thuộc kiểm soát

.. note:: atomic_add_unless() only provides full order on success.


trường hợp 9) - RMW dựa trên khóa
------------------------

Thay đổi chức năng:

* Atomic_dec_and_lock() --> refcount_dec_and_lock()
 * Atomic_dec_and_mutex_lock() --> refcount_dec_and_mutex_lock()

Thứ tự bộ nhớ đảm bảo thay đổi:

* đã đặt hàng đầy đủ --> Đặt hàng RELEASE + phụ thuộc kiểm soát + giữ
   spin_lock() thành công
