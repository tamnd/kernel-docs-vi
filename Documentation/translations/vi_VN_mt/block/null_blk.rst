.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/block/null_blk.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================================
Trình điều khiển thiết bị khối Null
===================================

Tổng quan
========

Thiết bị khối null (ZZ0000ZZ) được sử dụng để đo điểm chuẩn khác nhau
triển khai lớp khối. Nó mô phỏng một thiết bị khối có kích thước X gigabyte.
Nó không thực hiện bất kỳ thao tác đọc/ghi nào, chỉ đánh dấu chúng là hoàn thành trong
hàng đợi yêu cầu. Có thể xảy ra các trường hợp sau:

Lớp khối nhiều hàng đợi

- Dựa trên yêu cầu.
    - Hàng đợi gửi cấu hình cho mỗi thiết bị.

Không có lớp khối (Được gọi là dựa trên sinh học)

- Dựa trên sinh học. Yêu cầu IO được gửi trực tiếp đến trình điều khiển thiết bị.
    - Trực tiếp chấp nhận cấu trúc dữ liệu sinh học và trả về chúng.

Tất cả đều có hàng đợi hoàn thành cho từng lõi trong hệ thống.

Thông số mô-đun
=================

queue_mode=[0-2]: Mặc định: 2-Nhiều hàng đợi
  Chọn lớp khối mà mô-đun sẽ khởi tạo.

= =============
  0 Dựa trên sinh học
  1 hàng đợi đơn (không dùng nữa)
  2 Nhiều hàng đợi
  = =============

home_node=[0--nr_nodes]: Mặc định: NUMA_NO_NODE
  Chọn nút CPU mà cấu trúc dữ liệu được phân bổ từ đó.

gb=[Kích thước tính bằng GB]: Mặc định: 250GB
  Kích thước của thiết bị được báo cáo cho hệ thống.

bs=[Kích thước khối (tính bằng byte)]: Mặc định: 512 byte
  Kích thước khối được báo cáo cho hệ thống.

nr_devices=[Số lượng thiết bị]: Mặc định: 1
  Số lượng thiết bị khối được khởi tạo. Chúng được khởi tạo dưới dạng/dev/nullb0,
  v.v.

irqmode=[0-2]: Mặc định: 1-Soft-irq
  Chế độ hoàn thành được sử dụng để hoàn thành IO cho lớp khối.

= =================================================================================
  0 Không có.
  1 mềm-irq. Sử dụng IPI để hoàn thành IO trên các nút CPU. Mô phỏng chi phí
     khi IO được phát hành từ nút CPU khác ngoài nút chủ thì thiết bị sẽ
     được kết nối với.
  2 Bộ hẹn giờ: Chờ một khoảng thời gian cụ thể (completion_nsec) cho mỗi IO trước
     hoàn thành.
  = =================================================================================

hoàn thành_nsec=[ns]: Mặc định: 10.000ns
  Kết hợp với irqmode=2 (bộ đếm thời gian). Thời gian mỗi sự kiện hoàn thành phải chờ.

submit_queues=[1..nr_cpus]: Mặc định: 1
  Số lượng hàng đợi gửi được đính kèm với trình điều khiển thiết bị. Nếu không được đặt, nó
  mặc định là 1. Đối với nhiều hàng đợi, nó bị bỏ qua khi mô-đun use_per_node_hctx
  tham số là 1.

hw_queue_deep=[0..qdeep]: Mặc định: 64
  Độ sâu hàng đợi phần cứng của thiết bị.

Memory_Backed=[0/1]: Mặc định: 0
  Có hay không sử dụng bộ nhớ đệm để đáp ứng các yêu cầu IO

= =================================================
  0 Không truyền dữ liệu để đáp ứng yêu cầu IO
  1 Sử dụng bộ nhớ đệm để đáp ứng các yêu cầu IO
  = =================================================

loại bỏ=[0/1]: Mặc định: 0
  Hỗ trợ các thao tác loại bỏ (yêu cầu thiết bị null_blk được hỗ trợ bộ nhớ).

= ========================================
  0 Không hỗ trợ thao tác loại bỏ
  1 Kích hoạt hỗ trợ cho các hoạt động loại bỏ
  = ========================================

cache_size=[Kích thước tính bằng MB]: Mặc định: 0
  Kích thước bộ đệm tính bằng MB cho thiết bị được hỗ trợ bộ nhớ.

mbps=[Băng thông tối đa tính bằng MB/s]: Mặc định: 0 (không giới hạn)
  Giới hạn băng thông cho hiệu suất của thiết bị.

Tham số cụ thể cho nhiều hàng đợi
-------------------------------

use_per_node_hctx=[0/1]: Mặc định: 0
  Số lượng hàng đợi ngữ cảnh phần cứng.

= ===========================================================================
  0 Số lượng hàng đợi gửi được đặt thành giá trị của submit_queues
     tham số.
  1 Lớp khối nhiều hàng đợi được khởi tạo bằng cách gửi phần cứng
     hàng đợi cho mỗi nút CPU trong hệ thống.
  = ===========================================================================

no_sched=[0/1]: Mặc định: 0
  Bật/tắt bộ lập lịch io.

= =========================================
  0 nullb* sử dụng bộ lập lịch blk-mq io mặc định
  1 nullb* không sử dụng bộ lập lịch io
  = =========================================

chặn=[0/1]: Mặc định: 0
  Chặn hành vi của hàng đợi yêu cầu.

= =====================================================================
  0 Đăng ký làm thiết bị trình điều khiển blk-mq không chặn.
  1 Đăng ký làm thiết bị trình điều khiển blk-mq chặn, null_blk sẽ đặt
     cờ BLK_MQ_F_BLOCKING, biểu thị rằng đôi khi/luôn luôn
     cần chặn hàm ->queue_rq() của nó.
  = =====================================================================

Shared_tags=[0/1]: Mặc định: 0
  Chia sẻ thẻ giữa các thiết bị.

= =====================================================================
  0 Bộ thẻ không được chia sẻ.
  1 Bộ thẻ được chia sẻ giữa các thiết bị cho blk-mq. Chỉ có ý nghĩa với
     nr_devices > 1, nếu không thì không có thẻ nào được đặt để chia sẻ.
  = =====================================================================

khoanh vùng=[0/1]: Mặc định: 0
  Thiết bị là thiết bị truy cập ngẫu nhiên hoặc khối được khoanh vùng.

= ============================================================================
  0 Thiết bị chặn được hiển thị dưới dạng thiết bị chặn truy cập ngẫu nhiên.
  1 Thiết bị khối được hiển thị dưới dạng thiết bị khối được khoanh vùng do máy chủ quản lý. Yêu cầu
     CONFIG_BLK_DEV_ZONED.
  = ============================================================================

vùng_size=[MB]: Mặc định: 256
  Kích thước trên mỗi vùng khi được hiển thị dưới dạng thiết bị khối được khoanh vùng. Phải là sức mạnh của hai.

zone_nr_conv=[nr_conv]: Mặc định: 0
  Số lượng vùng thông thường cần tạo khi thiết bị khối được phân vùng.  Nếu
  vùng_nr_conv >= nr_zones, nó sẽ giảm xuống nr_zones - 1.