.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/i915_small_bar.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
I915 Phần BAR RFC nhỏ
==========================
Bắt đầu từ DG2, chúng tôi sẽ hỗ trợ BAR có thể thay đổi kích thước cho bộ nhớ cục bộ của thiết bị (tức là
I915_MEMORY_CLASS_DEVICE), nhưng trong một số trường hợp, kích thước BAR cuối cùng có thể vẫn là
nhỏ hơn tổng kích thước thăm dò. Trong những trường hợp như vậy, chỉ một số tập con của
I915_MEMORY_CLASS_DEVICE sẽ có thể truy cập được CPU (ví dụ: 256M đầu tiên),
trong khi phần còn lại chỉ có thể truy cập được thông qua GPU.

Cờ I915_GEM_CREATE_EXT_FLAG_NEEDS_CPU_ACCESS
----------------------------------------------
Cờ gem_create_ext mới để báo cho kernel biết rằng BO sẽ yêu cầu quyền truy cập CPU.
Điều này trở nên quan trọng khi đặt một đối tượng vào I915_MEMORY_CLASS_DEVICE, trong đó
bên dưới thiết bị có một BAR nhỏ, nghĩa là chỉ một phần của nó là CPU
có thể truy cập được. Nếu không có cờ này, kernel sẽ cho rằng quyền truy cập CPU không được
được yêu cầu và ưu tiên sử dụng phần hiển thị không phải CPU của
I915_MEMORY_CLASS_DEVICE.

.. kernel-doc:: Documentation/gpu/rfc/i915_small_bar.h
   :functions: __drm_i915_gem_create_ext

Thuộc tính thăm dò_cpu_visible_size
---------------------------------
Thuộc tính struct__drm_i915_memory_zone mới trả về tổng kích thước của
Phần có thể truy cập CPU cho khu vực cụ thể. Điều này chỉ nên
áp dụng cho I915_MEMORY_CLASS_DEVICE. Chúng tôi cũng báo cáo
unallocated_cpu_visible_size, cùng với unallocated_size.

Vulkan sẽ cần điều này như một phần của việc tạo VkMemoryHeap riêng biệt với
Bộ VK_MEMORY_PROPERTY_HOST_VISIBLE_BIT, để thể hiện phần hiển thị của CPU,
trong đó tổng kích thước của heap cần được biết. Nó cũng muốn có thể
đưa ra ước tính sơ bộ về khả năng phân bổ bộ nhớ.

.. kernel-doc:: Documentation/gpu/rfc/i915_small_bar.h
   :functions: __drm_i915_memory_region_info

Hạn chế chụp lỗi
--------------------------
Với tính năng chụp lỗi, chúng tôi có hai hạn chế mới:

1) Việc nắm bắt lỗi là nỗ lực tốt nhất trên các hệ thống BAR nhỏ; nếu các trang không
    CPU có thể truy cập được, tại thời điểm chụp, sau đó kernel có thể tự do bỏ qua
    đang cố gắng bắt chúng.

2) Trên các nền tảng tích hợp riêng biệt và mới hơn, chúng tôi hiện từ chối việc ghi lỗi
    trên các bối cảnh có thể phục hồi. Trong tương lai hạt nhân có thể muốn bị hỏng trong quá trình
    chụp lỗi, chẳng hạn như khi có thứ gì đó hiện không thể truy cập được CPU.
