.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/arm-ccn.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Mạng kết hợp bộ đệm ARM
=============================

CCN-504 là kết nối bus vòng bao gồm 11 điểm giao nhau
(XP), với mỗi điểm chéo hỗ trợ tối đa hai cổng thiết bị,
vì vậy các nút (thiết bị) 0 và 1 được kết nối với điểm chéo 0,
nút 2 và 3 đến điểm giao nhau 1, v.v.

Trình điều khiển PMU (hoàn hảo)
-----------------

Trình điều khiển CCN đăng ký trình điều khiển PMU hoàn hảo, cung cấp
mô tả các sự kiện có sẵn và các tùy chọn cấu hình
trong sysfs, xem /sys/bus/event_source/devices/ccn*.

Thư mục "format" mô tả định dạng của config, config1
và các trường config2 của cấu trúc perf_event_attr. Những “sự kiện”
thư mục cung cấp các mẫu cấu hình cho tất cả các tài liệu
sự kiện, có thể được sử dụng với công cụ hoàn hảo. Ví dụ: "xp_valid_flit"
tương đương với "type=0x8,event=0x4". Các thông số khác phải
được chỉ định rõ ràng.

Đối với các sự kiện bắt nguồn từ thiết bị, "nút" xác định chỉ mục của nó.

Các sự kiện Crosspoint PMU yêu cầu "xp" (chỉ mục), "bus" (số xe buýt)
và "vc" (ID kênh ảo).

Các sự kiện dựa trên điểm theo dõi điểm chéo (giá trị "sự kiện" đặc biệt 0xfe)
yêu cầu "xp" và "vc" như trên cộng với "port" (chỉ mục cổng thiết bị),
"dir" (hướng truyền/nhận), giá trị so sánh ("cmp_l"
và "cmp_h") và "mask", là chỉ mục của mặt nạ so sánh.

Mặt nạ được xác định riêng biệt với mô tả sự kiện
(do số lượng giá trị cấu hình bị giới hạn) trong "cmp_mask"
thư mục, với 8 thư mục đầu tiên có thể được cấu hình bởi người dùng và các thư mục bổ sung
4 được mã hóa cứng cho các trường hợp sử dụng thường xuyên nhất.

Bộ đếm chu kỳ được mô tả bằng giá trị "loại" 0xff và thực hiện
không yêu cầu bất kỳ cài đặt nào khác.

Trình điều khiển cũng cung cấp thuộc tính sysfs "cpumask", chứa
một ID CPU duy nhất của bộ xử lý sẽ được sử dụng để xử lý tất cả
sự kiện CCN PMU. Chúng tôi khuyến nghị rằng các công cụ không gian người dùng
yêu cầu các sự kiện trên bộ xử lý này (nếu không, giá trị perf_event->cpu
dù sao cũng sẽ bị ghi đè). Trong trường hợp bộ xử lý này bị ngoại tuyến,
các sự kiện được di chuyển sang một sự kiện khác và thuộc tính được cập nhật.

Ví dụ về sử dụng công cụ hoàn hảo ::

/ Danh sách # perf | grep ccn
    ccn/cycles/ [Sự kiện hạt nhân PMU]
  <...>
    ccn/xp_valid_flit,xp=?,port=?,vc=?,dir=?/ [Sự kiện Kernel PMU]
  <...>

/ # perf stat -a -e ccn/cycles/,ccn/xp_valid_flit,xp=1,port=0,vc=1,dir=1/ \
                                                                         ngủ 1

Trình điều khiển không hỗ trợ lấy mẫu, do đó "bản ghi hoàn hảo" sẽ
không làm việc. Phiên hoàn thiện mỗi tác vụ (không có "-a") không được hỗ trợ.
