.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/ampere_cspmu.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================
Bộ giám sát hiệu suất Ampe SoC (PMU)
================================================

Ampere SoC PMU là IP PMU chung tuân theo kiến ​​trúc Arm CoreSight PMU.
Do đó, trình điều khiển được triển khai dưới dạng mô-đun con của trình điều khiển arm_cspmu. Tại
giai đoạn đầu tiên nó được sử dụng để đếm các sự kiện MCU trên AmpereOne.


Sự kiện MCU PMU
---------------

Trình điều khiển PMU hỗ trợ cài đặt các bộ lọc cho "xếp hạng", "ngân hàng" và "ngưỡng".
Lưu ý rằng các bộ lọc dành cho mỗi phiên bản PMU chứ không phải cho mỗi sự kiện.


Ví dụ về việc sử dụng công cụ hoàn hảo ::

/ Ampe danh sách # perf

ampere_mcu_pmu_0/act_sent/ [Sự kiện hạt nhân PMU]
    <...>
    ampere_mcu_pmu_1/rd_sent/ [Sự kiện hạt nhân PMU]
    <...>

/ # perf stat -a -e ampere_mcu_pmu_0/act_sent,bank=5,rank=3,threshold=2/,ampere_mcu_pmu_1/rd_sent/ \
        ngủ 1