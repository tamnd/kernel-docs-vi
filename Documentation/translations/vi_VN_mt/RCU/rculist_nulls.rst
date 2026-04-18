.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/RCU/rculist_nulls.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================
Sử dụng RCU hlist_nulls để bảo vệ danh sách và đối tượng
========================================================

Phần này mô tả cách sử dụng hlist_nulls để
bảo vệ danh sách liên kết đọc chủ yếu và
các đối tượng sử dụng phân bổ SLAB_TYPESAFE_BY_RCU.

Vui lòng đọc những điều cơ bản trong listRCU.rst.

Sử dụng 'null'
=============

Sử dụng các trình tạo đặc biệt (được gọi là 'null') là một cách thuận tiện
để giải quyết vấn đề sau.

Nếu không có 'null', một danh sách liên kết RCU điển hình sẽ quản lý các đối tượng
được phân bổ bằng SLAB_TYPESAFE_BY_RCU kmem_cache có thể sử dụng như sau
thuật toán.  Các ví dụ sau giả sử 'obj' là một con trỏ tới
các đối tượng có loại dưới đây.

::

đối tượng cấu trúc {
    cấu trúc hlist_node obj_node;
    nguyên tử_t phản ánh;
    khóa int không dấu;
  };

1) Thuật toán tra cứu
-------------------

::

bắt đầu:
  rcu_read_lock();
  obj = lockless_lookup(key);
  nếu (obj) {
    if (!try_get_ref(obj)) { // có thể thất bại đối với các đối tượng miễn phí
      rcu_read_unlock();
      bắt đầu;
    }
    /*
    * Bởi vì người viết có thể xóa đối tượng và người viết có thể
    * tái sử dụng các đối tượng này trước thời gian gia hạn RCU, chúng tôi
    * phải kiểm tra khóa sau khi lấy tham chiếu về đối tượng
    */
    if (obj->key != key) { // không phải đối tượng chúng ta mong đợi
      put_ref(obj);
      rcu_read_unlock();
      bắt đầu;
    }
  }
  rcu_read_unlock();

Xin lưu ý rằng lockless_lookup(key) không thể sử dụng hlist_for_each_entry_rcu() truyền thống
nhưng là một phiên bản có thêm rào cản bộ nhớ (smp_rmb())

::

lockless_lookup(key)
  {
    cấu trúc hlist_node *node, *next;
    for (pos = rcu_dereference((head)->first);
         pos && ({ next = pos->next; smp_rmb(); tìm nạp trước(next); 1; }) &&
         ({ obj = hlist_entry(pos, typeof(*obj), obj_node); 1; });
         pos = rcu_dereference(tiếp theo))
      if (obj->key == khóa)
        trả lại đối tượng;
    trả lại NULL;
  }

Và lưu ý rằng hlist_for_each_entry_rcu() truyền thống bỏ lỡ smp_rmb()::

struct hlist_node *node;
  for (pos = rcu_dereference((head)->first);
       pos && ({ tìm nạp trước(pos->next); 1; }) &&
       ({ obj = hlist_entry(pos, typeof(*obj), obj_node); 1; });
       pos = rcu_dereference(pos->next))
    if (obj->key == khóa)
      trả lại đối tượng;
  trả lại NULL;

Trích dẫn Corey Minyard::

"Nếu đối tượng được chuyển từ danh sách này sang danh sách khác ở giữa
  thời điểm hàm băm được tính toán và trường tiếp theo được truy cập, đồng thời
  đối tượng đã di chuyển đến cuối danh sách mới, việc truyền tải sẽ không
  hoàn thành đúng trong danh sách cần có, vì đối tượng sẽ
  ở cuối danh sách mới và không có cách nào để biết nó nằm trên
  danh sách mới và khởi động lại quá trình duyệt danh sách. Tôi nghĩ rằng điều này có thể
  được giải quyết bằng cách tìm nạp trước trường "tiếp theo" (với các rào cản thích hợp) trước
  kiểm tra chìa khóa."

2) Thuật toán chèn
----------------------

Chúng tôi cần đảm bảo rằng người đọc không thể đọc giá trị 'obj->obj_node.next' mới
và giá trị trước đó của 'obj->key'. Nếu không, một mục có thể bị xóa
từ một chuỗi và chèn vào một chuỗi khác. Nếu chuỗi mới trống
trước khi di chuyển, con trỏ 'tiếp theo' là NULL và đầu đọc không khóa không thể
phát hiện thực tế là nó đã bỏ sót các mục sau trong chuỗi ban đầu.

::

/*
   * Xin lưu ý rằng việc chèn mới được thực hiện ở đầu danh sách,
   * không ở giữa hoặc cuối.
   */
  obj = kmem_cache_alloc(...);
  lock_chain(); // thường là spin_lock()
  obj->key = key;
  Atomic_set_release(&obj->refcnt, 1); // khóa trước refcnt
  hlist_add_head_rcu(&obj->obj_node, danh sách);
  unlock_chain(); // thường là spin_unlock()


3) Thuật toán loại bỏ
--------------------

Không có gì đặc biệt ở đây, chúng ta có thể sử dụng tính năng xóa danh sách RCU tiêu chuẩn.
Nhưng nhờ SLAB_TYPESAFE_BY_RCU, hãy cẩn thận một đối tượng đã xóa có thể được sử dụng lại
rất rất nhanh (trước khi kết thúc thời gian gia hạn RCU)

::

nếu (put_last_reference_on(obj) {
    lock_chain(); // thường là spin_lock()
    hlist_del_init_rcu(&obj->obj_node);
    unlock_chain(); // thường là spin_unlock()
    kmem_cache_free(cachep, obj);
  }



--------------------------------------------------------------------------

Tránh thêm smp_rmb()
========================

Với hlist_nulls, chúng ta có thể tránh được smp_rmb() thừa trong lockless_lookup().

Ví dụ: nếu chúng tôi chọn lưu trữ số vị trí dưới dạng 'null'
điểm đánh dấu cuối danh sách cho mỗi vị trí của bảng băm, chúng ta có thể phát hiện
một chủng tộc (một số nhà văn đã xóa và/hoặc di chuyển một đối tượng
sang chuỗi khác) kiểm tra giá trị 'null' cuối cùng nếu
việc tra cứu đã gặp phần cuối của chuỗi. Nếu giá trị 'null' cuối cùng
không phải là số vị trí thì chúng ta phải khởi động lại việc tra cứu tại
sự khởi đầu. Nếu đối tượng được chuyển đến cùng một chuỗi,
thì người đọc không quan tâm: Đôi khi có thể
quét lại danh sách mà không gây hại.

Lưu ý rằng việc sử dụng hlist_nulls có nghĩa là loại trường 'obj_node' của
'đối tượng cấu trúc' trở thành 'struct hlist_nulls_node'.


1) thuật toán tra cứu
-------------------

::

đầu = &bảng[khe];
  bắt đầu:
  rcu_read_lock();
  hlist_nulls_for_each_entry_rcu(obj, nút, đầu, obj_node) {
    if (obj->key == key) {
      if (!try_get_ref(obj)) { // có thể thất bại đối với các đối tượng miễn phí
	rcu_read_unlock();
        bắt đầu;
      }
      if (obj->key != key) { // không phải đối tượng chúng ta mong đợi
        put_ref(obj);
	rcu_read_unlock();
        bắt đầu;
      }
      đi ra ngoài;
    }
  }

// Nếu giá trị null chúng ta nhận được ở cuối quá trình tra cứu này là
  // không như mong đợi, chúng ta phải khởi động lại việc tra cứu.
  // Có lẽ chúng ta đã gặp một món đồ đã được chuyển sang chuỗi khác.
  if (get_nulls_value(node) != slot) {
    put_ref(obj);
    rcu_read_unlock();
    bắt đầu;
  }
  obj = NULL;

ra:
  rcu_read_unlock();

2) Thuật toán chèn
-------------------

Tương tự như trên, nhưng sử dụng hlist_nulls_add_head_rcu() thay vì
hlist_add_head_rcu().

::

/*
   * Xin lưu ý rằng việc chèn mới được thực hiện ở đầu danh sách,
   * không ở giữa hoặc cuối.
   */
  obj = kmem_cache_alloc(cachep);
  lock_chain(); // thường là spin_lock()
  obj->key = key;
  Atomic_set_release(&obj->refcnt, 1); // khóa trước refcnt
  /*
   * chèn obj theo cách RCU (người đọc có thể duyệt chuỗi)
   */
  hlist_nulls_add_head_rcu(&obj->obj_node, danh sách);
  unlock_chain(); // thường là spin_unlock()