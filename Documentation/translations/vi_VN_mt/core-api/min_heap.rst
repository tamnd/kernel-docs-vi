.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/core-api/min_heap.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================
Đống tối thiểu API
==================

:Tác giả: Kuan-Wei Chiu <visitorckw@gmail.com>

Giới thiệu
============

Min Heap API cung cấp một tập hợp các chức năng và macro để quản lý các vùng heap tối thiểu
trong nhân Linux. Heap tối thiểu là một cấu trúc cây nhị phân trong đó giá trị của
mỗi nút nhỏ hơn hoặc bằng giá trị của các nút con của nó, đảm bảo rằng
phần tử nhỏ nhất luôn ở gốc.

Tài liệu này cung cấp hướng dẫn về Min Heap API, nêu chi tiết cách xác định và
sử dụng đống tối thiểu. Người dùng không nên gọi trực tiếp các hàm bằng *ZZ0000ZZ()**
tiền tố, nhưng thay vào đó nên sử dụng trình bao bọc macro được cung cấp.

Ngoài phiên bản tiêu chuẩn của các chức năng, API còn bao gồm một
tập hợp các phiên bản nội tuyến cho các tình huống quan trọng về hiệu suất. Những nội tuyến này
các hàm có cùng tên với các hàm không cùng dòng nhưng bao gồm một
Hậu tố ZZ0000ZZ. Ví dụ: ZZ0001ZZ và
trình bao bọc macro tương ứng ZZ0002ZZ. Các phiên bản nội tuyến cho phép
các hàm so sánh và hoán đổi tùy chỉnh sẽ được gọi trực tiếp, thay vì thông qua
lời gọi hàm gián tiếp. Điều này có thể làm giảm đáng kể chi phí, đặc biệt là
khi CONFIG_MITIGATION_RETPOLINE được bật, khi các lệnh gọi hàm gián tiếp trở thành
đắt hơn. Giống như các phiên bản không nội tuyến, điều quan trọng là sử dụng
trình bao bọc macro cho các hàm nội tuyến thay vì gọi trực tiếp các hàm
chính họ.

Cấu trúc dữ liệu
===============

Định nghĩa Heap tối thiểu
-------------------

Cấu trúc dữ liệu cốt lõi để biểu diễn vùng heap tối thiểu được xác định bằng cách sử dụng
Macro ZZ0000ZZ và ZZ0001ZZ. Các macro này cho phép
bạn xác định vùng heap tối thiểu bằng bộ đệm được phân bổ trước hoặc được phân bổ động
trí nhớ.

Ví dụ:

.. code-block:: c

    #define MIN_HEAP_PREALLOCATED(_type, _name, _nr)
    struct _name {
        size_t nr;         /* Number of elements in the heap */
        size_t size;       /* Maximum number of elements that can be held */
        _type *data;    /* Pointer to the heap data */
        _type preallocated[_nr];  /* Static preallocated array */
    }

    #define DEFINE_MIN_HEAP(_type, _name) MIN_HEAP_PREALLOCATED(_type, _name, 0)

Một cấu trúc heap điển hình sẽ bao gồm một bộ đếm số phần tử
(ZZ0000ZZ), dung lượng tối đa của heap (ZZ0001ZZ) và một con trỏ tới một mảng
các phần tử (ZZ0002ZZ). Tùy chọn, bạn có thể chỉ định một mảng tĩnh cho phân bổ trước
lưu trữ heap bằng ZZ0003ZZ.

Cuộc gọi lại Heap tối thiểu
------------------

ZZ0000ZZ cung cấp các tùy chọn tùy chỉnh để đặt hàng
các phần tử trong heap và hoán đổi chúng. Nó chứa hai con trỏ hàm:

.. code-block:: c

    struct min_heap_callbacks {
        bool (*less)(const void *lhs, const void *rhs, void *args);
        void (*swp)(void *lhs, void *rhs, void *args);
    };

- ZZ0000ZZ là hàm so sánh dùng để xác lập thứ tự các phần tử.
- ZZ0001ZZ là hàm hoán đổi các phần tử trong heap. Nếu swp được đặt thành
  NULL, chức năng hoán đổi mặc định sẽ được sử dụng để hoán đổi các phần tử dựa trên kích thước của chúng

Trình bao bọc macro
==============

Các trình bao bọc macro sau đây được cung cấp để tương tác với vùng heap trong một
cách thân thiện với người dùng. Mỗi macro tương ứng với một chức năng hoạt động trên
heap và chúng loại bỏ các lệnh gọi trực tiếp đến các hàm nội bộ.

Mỗi macro chấp nhận các tham số khác nhau được trình bày chi tiết bên dưới.

Khởi tạo heap
--------------------

.. code-block:: c

    min_heap_init(heap, data, size);

- ZZ0001ZZ: Con trỏ tới cấu trúc min-heap cần khởi tạo.
- ZZ0002ZZ: Con trỏ tới vùng đệm nơi các phần tử heap sẽ được lưu trữ. Nếu
  ZZ0000ZZ, bộ đệm được phân bổ trước trong cấu trúc heap sẽ được sử dụng.
- ZZ0003ZZ: Số phần tử tối đa mà heap có thể chứa.

Macro này khởi tạo vùng heap, thiết lập trạng thái ban đầu của nó. Nếu ZZ0000ZZ là
ZZ0001ZZ, bộ nhớ được cấp phát trước bên trong cấu trúc heap sẽ được sử dụng cho
lưu trữ. Nếu không, bộ đệm do người dùng cung cấp sẽ được sử dụng. Hoạt động là ZZ0002ZZ.

ZZ0000ZZ min_heap_init_inline(đống, dữ liệu, kích thước)

Truy cập phần tử hàng đầu
-------------------------

.. code-block:: c

    element = min_heap_peek(heap);

- ZZ0000ZZ: Một con trỏ tới vùng heap tối thiểu để lấy giá trị nhỏ nhất từ đó
  phần tử.

Macro này trả về một con trỏ tới phần tử nhỏ nhất (gốc) của vùng heap hoặc
ZZ0000ZZ nếu vùng heap trống. Hoạt động là ZZ0001ZZ.

ZZ0000ZZ min_heap_peek_inline(đống)

Chèn đống
--------------

.. code-block:: c

    success = min_heap_push(heap, element, callbacks, args);

- ZZ0005ZZ: Một con trỏ tới vùng heap tối thiểu mà phần tử sẽ được chèn vào.
- ZZ0006ZZ: Con trỏ tới phần tử cần chèn vào heap.
- ZZ0007ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0008ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này chèn một phần tử vào heap. Nó trả về ZZ0000ZZ nếu việc chèn
đã thành công và ZZ0001ZZ nếu vùng heap đầy. Hoạt động là ZZ0002ZZ.

ZZ0000ZZ min_heap_push_inline(đống, phần tử, lệnh gọi lại, đối số)

Loại bỏ đống
------------

.. code-block:: c

    success = min_heap_pop(heap, callbacks, args);

- ZZ0005ZZ: Con trỏ tới vùng heap tối thiểu để loại bỏ phần tử nhỏ nhất.
- ZZ0006ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0007ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này loại bỏ phần tử nhỏ nhất (gốc) khỏi heap. Nó trở lại
ZZ0000ZZ nếu phần tử được xóa thành công hoặc ZZ0001ZZ nếu vùng heap được giải quyết
trống rỗng. Hoạt động là ZZ0002ZZ.

ZZ0000ZZ min_heap_pop_inline(đống, lệnh gọi lại, đối số)

Bảo trì đống
----------------

Bạn có thể sử dụng các macro sau để duy trì cấu trúc của vùng heap:

.. code-block:: c

    min_heap_sift_down(heap, pos, callbacks, args);

- ZZ0005ZZ: Con trỏ tới vùng heap tối thiểu.
- ZZ0006ZZ: Chỉ số để bắt đầu sàng lọc.
- ZZ0007ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0008ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này khôi phục thuộc tính heap bằng cách di chuyển phần tử tại vị trí đã chỉ định
(ZZ0000ZZ) xuống heap cho đến khi nó ở đúng vị trí. hoạt động
là ZZ0001ZZ.

ZZ0000ZZ min_heap_sift_down_inline(heap, pos, callback, args)

.. code-block:: c

    min_heap_sift_up(heap, idx, callbacks, args);

- ZZ0005ZZ: Con trỏ tới vùng heap tối thiểu.
- ZZ0006ZZ: Chỉ số của phần tử cần sàng lọc.
- ZZ0007ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0008ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này khôi phục thuộc tính heap bằng cách di chuyển phần tử tại vị trí đã chỉ định
chỉ mục (ZZ0000ZZ) lên vùng heap. Hoạt động là ZZ0001ZZ.

ZZ0000ZZ min_heap_sift_up_inline(heap, idx, callback, args)

.. code-block:: c

    min_heapify_all(heap, callbacks, args);

- ZZ0005ZZ: Con trỏ tới vùng heap tối thiểu.
- ZZ0006ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0007ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này đảm bảo rằng toàn bộ vùng heap thỏa mãn thuộc tính heap. Đó là
được gọi khi heap được xây dựng từ đầu hoặc sau nhiều lần sửa đổi. các
hoạt động là ZZ0000ZZ.

ZZ0000ZZ min_heapify_all_inline(đống, lệnh gọi lại, đối số)

Loại bỏ các phần tử cụ thể
--------------------------

.. code-block:: c

    success = min_heap_del(heap, idx, callbacks, args);

- ZZ0005ZZ: Con trỏ tới vùng heap tối thiểu.
- ZZ0006ZZ: Chỉ số của phần tử cần xóa.
- ZZ0007ZZ: Một con trỏ tới ZZ0000ZZ cung cấp
  Chức năng ZZ0001ZZ và ZZ0002ZZ.
- ZZ0008ZZ: Đối số tùy chọn được truyền cho hàm ZZ0003ZZ và ZZ0004ZZ.

Macro này loại bỏ một phần tử tại chỉ mục đã chỉ định (ZZ0000ZZ) khỏi heap và
khôi phục thuộc tính heap. Hoạt động là ZZ0001ZZ.

ZZ0000ZZ min_heap_del_inline(heap, idx, callback, args)

Tiện ích khác
===============

- ZZ0000ZZ: Kiểm tra heap đã đầy chưa.
  Độ phức tạp: ZZ0001ZZ.

.. code-block:: c

    bool full = min_heap_full(heap);

- ZZ0000ZZ: Con trỏ tới min-heap để kiểm tra.

Macro này trả về ZZ0000ZZ nếu vùng heap đầy, nếu không thì ZZ0001ZZ.

ZZ0000ZZ min_heap_full_inline(đống)

- ZZ0000ZZ: Kiểm tra xem heap có trống không.
  Độ phức tạp: ZZ0001ZZ.

.. code-block:: c

    bool empty = min_heap_empty(heap);

- ZZ0000ZZ: Con trỏ tới min-heap để kiểm tra.

Macro này trả về ZZ0000ZZ nếu vùng heap trống, nếu không thì ZZ0001ZZ.

ZZ0000ZZ min_heap_empty_inline(đống)

Cách sử dụng ví dụ
=============

Một ví dụ về cách sử dụng API heap tối thiểu sẽ liên quan đến việc xác định cấu trúc heap,
khởi tạo nó cũng như chèn và xóa các phần tử nếu cần.

.. code-block:: c

    #include <linux/min_heap.h>

    int my_less_function(const void *lhs, const void *rhs, void *args) {
        return (*(int *)lhs < *(int *)rhs);
    }

    struct min_heap_callbacks heap_cb = {
        .less = my_less_function,    /* Comparison function for heap order */
        .swp  = NULL,                /* Use default swap function */
    };

    void example_usage(void) {
        /* Pre-populate the buffer with elements */
        int buffer[5] = {5, 2, 8, 1, 3};
        /* Declare a min-heap */
        DEFINE_MIN_HEAP(int, my_heap);

        /* Initialize the heap with preallocated buffer and size */
        min_heap_init(&my_heap, buffer, 5);

        /* Build the heap using min_heapify_all */
        my_heap.nr = 5;  /* Set the number of elements in the heap */
        min_heapify_all(&my_heap, &heap_cb, NULL);

        /* Peek at the top element (should be 1 in this case) */
        int *top = min_heap_peek(&my_heap);
        pr_info("Top element: %d\n", *top);

        /* Pop the top element (1) and get the new top (2) */
        min_heap_pop(&my_heap, &heap_cb, NULL);
        top = min_heap_peek(&my_heap);
        pr_info("New top element: %d\n", *top);

        /* Insert a new element (0) and recheck the top */
        int new_element = 0;
        min_heap_push(&my_heap, &new_element, &heap_cb, NULL);
        top = min_heap_peek(&my_heap);
        pr_info("Top element after insertion: %d\n", *top);
    }