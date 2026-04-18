.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/xgene-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Thiết bị giám sát hiệu suất SoC APM X-Gene (PMU)
================================================

X-Gene SoC PMU bao gồm nhiều PMU thiết bị hệ thống độc lập khác nhau như
(Các) bộ nhớ đệm L3, (các) cầu nối I/O, (các) cầu nối bộ điều khiển bộ nhớ và bộ nhớ
(các) bộ điều khiển. Các thiết bị PMU này được thiết kế lỏng lẻo để tuân theo
cùng model với PMU dành cho lõi ARM. Các Ban QLDA có chung cấp cao nhất
ngắt và trạng thái vùng CSR.

Trình điều khiển PMU (hoàn hảo)
-----------------

Trình điều khiển xgene-pmu đăng ký một số trình điều khiển PMU hoàn hảo. Mỗi sự hoàn hảo
trình điều khiển cung cấp mô tả về các sự kiện có sẵn và các tùy chọn cấu hình
trong sysfs, xem /sys/bus/event_source/devices/<l3cX/iobX/mcbX/mcX>/.

Thư mục "format" mô tả định dạng của cấu hình (ID sự kiện),
Các trường config1 (ID tác nhân) của cấu trúc perf_event_attr. Những “sự kiện”
thư mục cung cấp các mẫu cấu hình cho tất cả các loại sự kiện được hỗ trợ
có thể được sử dụng với công cụ hoàn hảo. Ví dụ: "l3c0/bank-fifo-full/" là một
tương đương với "l3c0/config=0x0b/".

Hầu hết SoC PMU đều có danh sách ID tác nhân cụ thể được sử dụng để giám sát
hiệu suất của một đường dẫn dữ liệu cụ thể. Ví dụ: các tác nhân của bộ đệm L3 có thể
một CPU cụ thể hoặc một cầu nối I/O. Mỗi PMU có một bộ 2 thanh ghi có khả năng
che giấu các tác nhân mà yêu cầu đến từ đó. Nếu bit với
số bit tương ứng với tác nhân được thiết lập, sự kiện chỉ được tính nếu
nó được gây ra bởi một yêu cầu từ đại lý đó. Mỗi bit ID tác nhân được ánh xạ nghịch đảo
đến một bit tương ứng trong trường "config1". Theo mặc định, sự kiện sẽ được
được tính cho tất cả các yêu cầu của tác nhân (config1 = 0x0). Đối với tất cả các đại lý được hỗ trợ của
mỗi PMU, vui lòng tham khảo Hướng dẫn sử dụng APM X-Gene.

Mỗi trình điều khiển hoàn hảo cũng cung cấp thuộc tính sysfs "cpumask", chứa một
ID CPU duy nhất của bộ xử lý sẽ được sử dụng để xử lý tất cả các sự kiện PMU.

Ví dụ về việc sử dụng công cụ hoàn hảo ::

/ Danh sách # perf | grep -e l3c -e iob -e mcb -e mc
   l3c0/ackq-full/ [Sự kiện hạt nhân PMU]
 <...>
   mcb1/mcb-csw-stall/ [Sự kiện hạt nhân PMU]

/ # perf stat -a -e l3c0/read-miss/,mcb1/csw-write-request/ ngủ 1

/ # perf stat -a -e l3c0/read-miss,config1=0xffffffffffffffffe/ ngủ 1

Trình điều khiển không hỗ trợ lấy mẫu, do đó "bản ghi hoàn hảo" sẽ
không làm việc. Phiên hoàn thiện mỗi tác vụ (không có "-a") không được hỗ trợ.
