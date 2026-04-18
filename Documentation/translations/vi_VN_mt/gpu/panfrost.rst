.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/panfrost.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
 Trình điều khiển drm/Pan Frost Mali
====================================

.. _panfrost-usage-stats:

Triển khai số liệu thống kê sử dụng máy khách Pan Frost DRM
===========================================================

Trình điều khiển drm/Pan Frost triển khai thông số thống kê sử dụng máy khách DRM như
được ghi lại trong ZZ0000ZZ.

Ví dụ về đầu ra hiển thị các cặp giá trị khóa được triển khai và toàn bộ
các tùy chọn định dạng hiện có thể có:

::
      vị trí: 0
      cờ: 02400002
      mnt_id: 27
      vào: 531
      trình điều khiển drm: panrost
      drm-client-id: 14
      đoạn động cơ drm: 1846584880 ns
      đoạn drm-chu kỳ: 1424359409
      đoạn drm-maxfreq: 799999987 Hz
      đoạn drm-curfreq: 799999987 Hz
      drm-engine-vertex-tiler: 71932239 ns
      drm-cycles-vertex-tiler: 52617357
      drm-maxfreq-vertex-tiler: 799999987 Hz
      drm-curfreq-vertex-tiler: 799999987 Hz
      drm-tổng bộ nhớ: 290 MiB
      bộ nhớ chia sẻ drm: 0 MiB
      bộ nhớ hoạt động drm: 226 MiB
      drm-cư dân-bộ nhớ: 36496 KiB
      bộ nhớ có thể xóa drm: 128 KiB

Tên khóa ZZ0000ZZ có thể có là: ZZ0001ZZ và ZZ0002ZZ.
Giá trị ZZ0003ZZ truyền tải tần số hoạt động hiện tại của động cơ đó.

Người dùng phải nhớ rằng việc lấy mẫu động cơ và chu trình bị tắt theo mặc định,
vì lo ngại tiết kiệm điện. Người dùng ZZ0000ZZ và các ứng dụng chuẩn
truy vấn tệp fdinfo phải đảm bảo chuyển đổi trạng thái hồ sơ công việc của
trình điều khiển bằng cách ghi vào nút sysfs thích hợp::

echo <N> > /sys/bus/platform/drivers/panblast/[a-f0-9]*.gpu/profiling

Trong đó ZZ0000ZZ là ZZ0001ZZ hoặc ZZ0002ZZ, tùy thuộc vào trạng thái kích hoạt mong muốn.