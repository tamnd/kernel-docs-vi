.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/mrvl-odyssey-tad-pmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================================================================
Thiết bị giám sát hiệu suất Marvell Odyssey LLC-TAD (PMU UNCORE)
====================================================================

Mỗi TAD cung cấp tám bộ đếm 64 bit để theo dõi
hành vi của bộ đệm. Trình điều khiển luôn cấu hình cùng một bộ đếm cho
tất cả các TAD. Người dùng cuối cùng sẽ đặt trước một cách hiệu quả một trong những
tám bộ đếm trong mỗi TAD để xem xét tất cả các TAD.
Sự xuất hiện của các sự kiện được tổng hợp và hiển thị cho người dùng
khi kết thúc việc chạy khối lượng công việc. Người lái xe không cung cấp
cách để người dùng phân vùng các TAD để sử dụng các TAD khác nhau cho
các ứng dụng khác nhau.

Các sự kiện biểu diễn phản ánh các hoạt động nội bộ hoặc giao diện khác nhau.
Bằng cách kết hợp các giá trị từ nhiều bộ đếm hiệu suất, bộ đệm
hiệu suất có thể được đo bằng các thuật ngữ như: tỷ lệ lỗi bộ đệm, bộ đệm
phân bổ, tốc độ thử lại giao diện, chiếm dụng tài nguyên nội bộ, v.v.

Trình điều khiển PMU hiển thị các sự kiện và tùy chọn định dạng có sẵn trong sysfs::

/sys/bus/event_source/devices/tad/events/
        /sys/bus/event_source/devices/tad/format/

Ví dụ::

danh sách hoàn hảo $ | hơi khó chịu
        tad/tad_alloc_any/ [Sự kiện hạt nhân PMU]
        tad/tad_alloc_dtg/ [Sự kiện hạt nhân PMU]
        tad/tad_alloc_ltg/ [Sự kiện hạt nhân PMU]
        tad/tad_hit_any/ [Sự kiện hạt nhân PMU]
        tad/tad_hit_dtg/ [Sự kiện hạt nhân PMU]
        tad/tad_hit_ltg/ [Sự kiện hạt nhân PMU]
        tad/tad_req_msh_in_exlmn/ [Sự kiện hạt nhân PMU]
        tad/tad_tag_rd/ [Sự kiện hạt nhân PMU]
        tad/tad_tot_cycle/ [Sự kiện hạt nhân PMU]

$ chỉ số hoàn hảo -e tad_alloc_dtg,tad_alloc_ltg,tad_alloc_any,tad_hit_dtg,tad_hit_ltg,tad_hit_any,tad_tag_rd <khối lượng công việc>
