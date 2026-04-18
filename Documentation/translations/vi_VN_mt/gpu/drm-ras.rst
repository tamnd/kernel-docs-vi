.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/drm-ras.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================
DRM RAS qua Netlink chung
===============================

Giao diện DRM RAS (Độ tin cậy, Tính khả dụng, Khả năng phục vụ) cung cấp một
cách tiêu chuẩn hóa cho trình điều khiển máy gia tốc/GPU để hiển thị bộ đếm lỗi và
các nút đáng tin cậy khác đối với không gian người dùng thông qua Generic Netlink. Điều này cho phép
công cụ chẩn đoán, trình nền giám sát hoặc cơ sở hạ tầng kiểm tra để truy vấn phần cứng
sức khỏe một cách thống nhất trên các trình điều khiển DRM khác nhau.

Mục tiêu chính:

* Cung cấp giải pháp RAS được tiêu chuẩn hóa cho GPU và trình điều khiển máy gia tốc, cho phép
  hoạt động giám sát và độ tin cậy của trung tâm dữ liệu.
* Triển khai một dòng Netlink chung drm-ras duy nhất để đáp ứng Netlink YAML hiện đại
  thông số kỹ thuật và tập trung tất cả các thông tin liên lạc liên quan đến RAS trong một không gian tên.
* Hỗ trợ giao diện truy cập lỗi cơ bản, giải quyết ngay lập tức, cần thiết
  nhu cầu giám sát.
* Cung cấp một giao diện linh hoạt, phù hợp với tương lai và có thể được mở rộng để hỗ trợ
  các loại dữ liệu RAS bổ sung trong tương lai.
* Cho phép nhiều nút trên mỗi trình điều khiển, cho phép trình điều khiển đăng ký riêng
  các nút cho các khối IP, khối con khác nhau hoặc các phân vùng logic khác
  như có thể áp dụng.

Nút
=====

Các nút là sự trừu tượng hóa logic biểu thị một loại lỗi hoặc nguồn lỗi trong
thiết bị. Hiện tại, chỉ có các nút bộ đếm lỗi được hỗ trợ.

Trình điều khiển có trách nhiệm đăng ký và hủy đăng ký các nút thông qua
API ZZ0000ZZ và ZZ0001ZZ.

Quản lý nút
-------------------

.. kernel-doc:: drivers/gpu/drm/drm_ras.c
   :doc: DRM RAS Node Management
.. kernel-doc:: drivers/gpu/drm/drm_ras.c
   :internal:

Cách sử dụng Netlink chung
==========================

Giao diện được triển khai dưới dạng họ Netlink chung có tên ZZ0000ZZ.
Công cụ không gian người dùng có thể:

* Liệt kê các nút đã đăng ký bằng lệnh ZZ0000ZZ.
* Liệt kê tất cả các bộ đếm lỗi trong một nút bằng lệnh ZZ0001ZZ với ZZ0002ZZ
  như một tham số.
* Truy vấn các giá trị bộ đếm lỗi cụ thể bằng lệnh ZZ0003ZZ, sử dụng cả hai
  ZZ0004ZZ và ZZ0005ZZ làm thông số.

Giao diện dựa trên YAML
-----------------------

Giao diện được mô tả trong đặc tả YAML ZZ0000ZZ

YAML này được sử dụng để tự động tạo các liên kết không gian người dùng thông qua
ZZ0000ZZ và điều khiển cấu trúc của liên kết mạng
thuộc tính và thao tác.

Ghi chú sử dụng
---------------

* Không gian người dùng trước tiên phải liệt kê các nút để lấy ID của họ.
* ID nút hoặc tên nút có thể được sử dụng cho tất cả các truy vấn tiếp theo, chẳng hạn như bộ đếm lỗi.
* Bộ đếm lỗi có thể được truy vấn bằng ID lỗi hoặc tên lỗi.
* Tham số truy vấn phải được xác định như một phần của uAPI để đảm bảo tính ổn định của giao diện người dùng.
* Giao diện hỗ trợ mở rộng trong tương lai bằng cách thêm các loại nút mới và
  các thuộc tính bổ sung.

Ví dụ: Liệt kê các nút bằng ynl

.. code-block:: bash

    sudo ynl --family drm_ras --dump list-nodes
    [{'device-name': '0000:03:00.0',
    'node-id': 0,
    'node-name': 'correctable-errors',
    'node-type': 'error-counter'},
    {'device-name': '0000:03:00.0',
     'node-id': 1,
     'node-name': 'uncorrectable-errors',
     'node-type': 'error-counter'}]

Ví dụ: Liệt kê tất cả các bộ đếm lỗi bằng ynl

.. code-block:: bash

    sudo ynl --family drm_ras --dump get-error-counter --json '{"node-id":0}'
    [{'error-id': 1, 'error-name': 'error_name1', 'error-value': 0},
    {'error-id': 2, 'error-name': 'error_name2', 'error-value': 0}]

Ví dụ: Truy vấn bộ đếm lỗi cho một nút nhất định

.. code-block:: bash

    sudo ynl --family drm_ras --do get-error-counter --json '{"node-id":0, "error-id":1}'
    {'error-id': 1, 'error-name': 'error_name1', 'error-value': 0}
