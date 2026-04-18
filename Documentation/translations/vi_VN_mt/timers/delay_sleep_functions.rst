.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/timers/delay_sleep_functions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Cơ chế trì hoãn và ngủ
==========================

Tài liệu này tìm cách trả lời câu hỏi phổ biến: "Cái gì là
RightWay (TM) để chèn độ trễ?"

Câu hỏi này thường gặp nhất bởi những người viết tài xế, những người phải
giải quyết sự chậm trễ của phần cứng và ai có thể không phải là người thân thiết nhất
quen thuộc với hoạt động bên trong của Linux Kernel.

Bảng sau đây cung cấp cái nhìn tổng quan sơ bộ về chức năng hiện có
'gia đình' và những hạn chế của họ. Bảng tổng quan này không thay thế bảng
đọc mô tả chức năng trước khi sử dụng!

.. list-table::
   :widths: 20 20 20 20 20
   :header-rows: 2

   * -
     - `*delay()`
     - `usleep_range*()`
     - `*sleep()`
     - `fsleep()`
   * -
     - busy-wait loop
     - hrtimers based
     - timer list timers based
     - combines the others
   * - Usage in atomic Context
     - yes
     - no
     - no
     - no
   * - precise on "short intervals"
     - yes
     - yes
     - depends
     - yes
   * - precise on "long intervals"
     - Do not use!
     - yes
     - max 12.5% slack
     - yes
   * - interruptible variant
     - no
     - yes
     - yes
     - no

Lời khuyên chung cho bối cảnh phi nguyên tử có thể là:

#. Sử dụng ZZ0000ZZ bất cứ khi nào không chắc chắn (vì nó kết hợp tất cả các ưu điểm của
   những người khác)
#. Sử dụng ZZ0001ZZ bất cứ khi nào có thể
#. Sử dụng ZZ0002ZZ bất cứ khi nào độ chính xác của ZZ0003ZZ không đủ
#. Sử dụng ZZ0004ZZ cho độ trễ rất ngắn

Tìm một số thông tin chi tiết hơn về chức năng 'gia đình' trong phần tiếp theo
phần.

Nhóm chức năng ZZ0000ZZ
------------------------------

Các chức năng này sử dụng ước tính nhanh chóng về tốc độ đồng hồ và sẽ bận chờ
đủ số chu kỳ vòng lặp để đạt được độ trễ mong muốn. udelay() là cơ bản
triển khai và ndelay() cũng như mdelay() là các biến thể.

Các chức năng này chủ yếu được sử dụng để thêm độ trễ trong bối cảnh nguyên tử. Xin vui lòng thực hiện
hãy chắc chắn tự hỏi bản thân trước khi thêm độ trễ vào bối cảnh nguyên tử: Đây có thực sự là
được yêu cầu?

.. kernel-doc:: include/asm-generic/delay.h
	:identifiers: udelay ndelay

.. kernel-doc:: include/linux/delay.h
	:identifiers: mdelay


Nhóm chức năng ZZ0000ZZ và ZZ0001ZZ
----------------------------------------------------

Các chức năng này sử dụng bộ đếm thời gian hoặc bộ đếm thời gian trong danh sách bộ hẹn giờ để cung cấp các yêu cầu
thời gian ngủ. Để quyết định chức năng nào là phù hợp để sử dụng,
tính đến một số thông tin cơ bản:

#. giờ đắt hơn vì họ đang sử dụng cây rb (thay vì băm)
#. giờ ngủ đắt hơn khi thời gian ngủ được yêu cầu là lần đầu tiên
   bộ đếm thời gian có nghĩa là phần cứng thực sự phải được lập trình
#. bộ hẹn giờ trong danh sách hẹn giờ luôn cung cấp một số loại thời gian trễ vì chúng dựa trên thời gian nhanh chóng

Lời khuyên chung được lặp lại ở đây:

#. Sử dụng ZZ0000ZZ bất cứ khi nào không chắc chắn (vì nó kết hợp tất cả các ưu điểm của
   những người khác)
#. Sử dụng ZZ0001ZZ bất cứ khi nào có thể
#. Sử dụng ZZ0002ZZ bất cứ khi nào độ chính xác của ZZ0003ZZ không đủ

Trước tiên hãy kiểm tra mô tả hàm fsleep() và để tìm hiểu thêm về độ chính xác,
vui lòng kiểm tra mô tả hàm msleep().


ZZ0000ZZ
~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/delay.h
	:identifiers: usleep_range usleep_range_idle

.. kernel-doc:: kernel/time/sleep_timeout.c
	:identifiers: usleep_range_state


ZZ0000ZZ
~~~~~~~~~~

.. kernel-doc:: kernel/time/sleep_timeout.c
       :identifiers: msleep msleep_interruptible

.. kernel-doc:: include/linux/delay.h
	:identifiers: ssleep fsleep