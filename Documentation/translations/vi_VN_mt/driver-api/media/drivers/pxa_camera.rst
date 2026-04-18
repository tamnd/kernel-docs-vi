.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/driver-api/media/drivers/pxa_camera.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Trình điều khiển máy chủ PXA-Camera
======================

Tác giả: Robert Jarzmik <robert.jarzmik@free.fr>

Hạn chế
-----------

a) Kích thước hình ảnh cho định dạng YUV422P
   Tất cả hình ảnh YUV422P được bắt buộc phải có chiều rộng x chiều cao% 16 = 0.
   Điều này là do các ràng buộc của DMA, chỉ truyền các mặt phẳng 8 byte
   bội số.


Quy trình làm việc video toàn cầu
---------------------

a) QCI đã dừng
   Ban đầu, giao diện QCI bị dừng.
   Khi bộ đệm được xếp hàng đợi, start_streaming được gọi và QCI khởi động.

b) QCI đã bắt đầu
   Nhiều bộ đệm hơn có thể được xếp hàng đợi trong khi QCI được khởi động mà không làm dừng quá trình
   bắt giữ.  Bộ đệm mới được "nối" vào cuối chuỗi DMA và
   chụp mượt mà hết khung hình này đến khung hình khác.

Khi bộ đệm được điền vào giao diện QCI, nó sẽ được đánh dấu là "DONE" và
   bị xóa khỏi danh sách bộ đệm đang hoạt động. Sau đó nó có thể được yêu cầu hoặc được xếp hàng bởi
   ứng dụng vùng người dùng.

Khi bộ đệm cuối cùng được điền vào, giao diện QCI sẽ dừng.

c) Nắm bắt lược đồ máy trạng thái hữu hạn toàn cầu

.. code-block:: none

	+----+                             +---+  +----+
	| DQ |                             | Q |  | DQ |
	|    v                             |   v  |    v
	+-----------+                     +------------------------+
	|   STOP    |                     | Wait for capture start |
	+-----------+         Q           +------------------------+
	+-> | QCI: stop | ------------------> | QCI: run               | <------------+
	|   | DMA: stop |                     | DMA: stop              |              |
	|   +-----------+             +-----> +------------------------+              |
	|                            /                            |                   |
	|                           /             +---+  +----+   |                   |
	|capture list empty        /              | Q |  | DQ |   | QCI Irq EOF       |
	|                         /               |   v  |    v   v                   |
	|   +--------------------+             +----------------------+               |
	|   | DMA hotlink missed |             |    Capture running   |               |
	|   +--------------------+             +----------------------+               |
	|   | QCI: run           |     +-----> | QCI: run             | <-+           |
	|   | DMA: stop          |    /        | DMA: run             |   |           |
	|   +--------------------+   /         +----------------------+   | Other     |
	|     ^                     /DMA still            |               | channels  |
	|     | capture list       /  running             | DMA Irq End   | not       |
	|     | not empty         /                       |               | finished  |
	|     |                  /                        v               | yet       |
	|   +----------------------+           +----------------------+   |           |
	|   |  Videobuf released   |           |  Channel completed   |   |           |
	|   +----------------------+           +----------------------+   |           |
	+-- | QCI: run             |           | QCI: run             | --+           |
	| DMA: run             |           | DMA: run             |               |
	+----------------------+           +----------------------+               |
		^                      /           |                           |
		|          no overrun /            | overrun                   |
		|                    /             v                           |
	+--------------------+         /   +----------------------+               |
	|  Frame completed   |        /    |     Frame overran    |               |
	+--------------------+ <-----+     +----------------------+ restart frame |
	| QCI: run           |             | QCI: stop            | --------------+
	| DMA: run           |             | DMA: stop            |
	+--------------------+             +----------------------+

	Legend: - each box is a FSM state
		- each arrow is the condition to transition to another state
		- an arrow with a comment is a mandatory transition (no condition)
		- arrow "Q" means : a buffer was enqueued
		- arrow "DQ" means : a buffer was dequeued
		- "QCI: stop" means the QCI interface is not enabled
		- "DMA: stop" means all 3 DMA channels are stopped
		- "DMA: run" means at least 1 DMA channel is still running

Cách sử dụng DMA
---------

a) Dòng chảy DMA
     - bộ đệm đầu tiên được xếp hàng đợi để chụp
       Khi bộ đệm đầu tiên được xếp hàng đợi để chụp, QCI sẽ được khởi động, nhưng dữ liệu
       quá trình chuyển giao chưa được bắt đầu. Khi ngắt "End Of Frame", trình xử lý irq
       bắt đầu chuỗi DMA.
     - chụp một bộ đệm video
       Chuỗi DMA bắt đầu truyền dữ liệu vào các trang RAM của bộ đệm video.
       Khi tất cả các trang được chuyển, irq DMA được nâng lên ở trạng thái "ENDINTR"
     - hoàn thiện một bộ đệm video
       Trình xử lý irq DMA đánh dấu bộ đệm video là "xong" và xóa nó khỏi
       hàng đợi đang hoạt động
       Trong khi đó, bộ đệm video tiếp theo (nếu có) sẽ được chuyển bởi DMA
     - hoàn thiện bộ đệm video cuối cùng
       Trên irq DMA của bộ đệm video cuối cùng, QCI bị dừng.

b) Bộ đệm được chuẩn bị sẵn DMA sẽ có cấu trúc này

.. code-block:: none

     +------------+-----+---------------+-----------------+
     | desc-sg[0] | ... | desc-sg[last] | finisher/linker |
     +------------+-----+---------------+-----------------+

Cấu trúc này được trỏ bởi dma->sg_cpu.
Các mô tả được sử dụng như sau:

- desc-sg[i]: ký hiệu mô tả thứ i, truyền sg thứ i
  phần tử để thu thập phân tán bộ đệm video
- người về đích: có ddadr=DADDR_STOP, dcmd=ENDIRQEN
- trình liên kết: có ddadr= desc-sg[0] của bộ đệm video tiếp theo, dcmd=0

Đối với lược đồ tiếp theo, hãy giả sử d0=desc-sg[0] .. dN=desc-sg[N],
"f" là viết tắt của trình hoàn thiện và "l" là trình liên kết.
Một chuỗi chạy điển hình là:

.. code-block:: none

         Videobuffer 1         Videobuffer 2
     +---------+----+---+  +----+----+----+---+
     | d0 | .. | dN | l |  | d0 | .. | dN | f |
     +---------+----+-|-+  ^----+----+----+---+
                      |    |
                      +----+

Sau khi kết thúc chuỗi, chuỗi trông như sau:

.. code-block:: none

         Videobuffer 1         Videobuffer 2         Videobuffer 3
     +---------+----+---+  +----+----+----+---+  +----+----+----+---+
     | d0 | .. | dN | l |  | d0 | .. | dN | l |  | d0 | .. | dN | f |
     +---------+----+-|-+  ^----+----+----+-|-+  ^----+----+----+---+
                      |    |                |    |
                      +----+                +----+
                                           new_link

c) Vấn đề về thời gian chuỗi nóng của DMA

Vì việc xâu chuỗi DMA được thực hiện trong khi DMA _is_ đang chạy, nên việc liên kết có thể được thực hiện
trong khi DMA nhảy từ Videobuffer này sang Videobuffer khác. Trên lược đồ, đó
sẽ là một vấn đề nếu gặp phải trình tự sau:

- Chuỗi DMA là Videobuffer1 + Videobuffer2
- pxa_videobuf_queue() được gọi để xếp hàng Videobuffer3
- Bộ điều khiển DMA kết thúc Videobuffer2 và DMA dừng

.. code-block:: none

      =>
         Videobuffer 1         Videobuffer 2
     +---------+----+---+  +----+----+----+---+
     | d0 | .. | dN | l |  | d0 | .. | dN | f |
     +---------+----+-|-+  ^----+----+----+-^-+
                      |    |                |
                      +----+                +-- DMA DDADR loads DDADR_STOP

- pxa_dma_add_tail_buf() được gọi, "bộ hoàn thiện" Videobuffer2 là
  được thay thế bằng "trình liên kết" thành Videobuffer3 (tạo new_link)
- pxa_videobuf_queue() kết thúc
- trình xử lý irq DMA được gọi, kết thúc Videobuffer2
- Quá trình quay Videobuffer3 không được lên lịch trên chuỗi DMA (vì nó đã dừng !!!)

.. code-block:: none

         Videobuffer 1         Videobuffer 2         Videobuffer 3
     +---------+----+---+  +----+----+----+---+  +----+----+----+---+
     | d0 | .. | dN | l |  | d0 | .. | dN | l |  | d0 | .. | dN | f |
     +---------+----+-|-+  ^----+----+----+-|-+  ^----+----+----+---+
                      |    |                |    |
                      +----+                +----+
                                           new_link
                                          DMA DDADR still is DDADR_STOP

- pxa_máy ảnh_check_link_miss() được gọi
  Việc này sẽ kiểm tra xem DMA đã hoàn tất chưa và bộ đệm vẫn còn trên
  pcdev-> danh sách chụp. Nếu đúng như vậy, quá trình chụp sẽ được khởi động lại,
  và Videobuffer3 được lên lịch trên chuỗi DMA.
- bộ xử lý irq DMA kết thúc

.. note::

     If DMA stops just after pxa_camera_check_link_miss() reads DDADR()
     value, we have the guarantee that the DMA irq handler will be called back
     when the DMA will finish the buffer, and pxa_camera_check_link_miss() will
     be called again, to reschedule Videobuffer3.