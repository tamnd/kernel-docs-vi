.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/maps.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


========
Bản đồ BPF
========

'Bản đồ' BPF cung cấp bộ lưu trữ chung thuộc nhiều loại khác nhau để chia sẻ dữ liệu giữa
kernel và không gian người dùng. Có một số loại lưu trữ có sẵn, bao gồm
hàm băm, mảng, bộ lọc nở và cây cơ số. Một số loại bản đồ tồn tại
hỗ trợ những người trợ giúp BPF cụ thể thực hiện các hành động dựa trên nội dung bản đồ. các
bản đồ được truy cập từ các chương trình BPF thông qua trình trợ giúp BPF được ghi lại trong
ZZ0000ZZ cho ZZ0001ZZ.

Bản đồ BPF được truy cập từ không gian người dùng thông qua tòa nhà ZZ0000ZZ, cung cấp
các lệnh tạo bản đồ, tra cứu phần tử, cập nhật phần tử và xóa phần tử.
Thông tin chi tiết hơn về tòa nhà chọc trời BPF có sẵn trong ZZ0001ZZ và trong
ZZ0002ZZ cho ZZ0003ZZ.

Các loại bản đồ
=========

.. toctree::
   :maxdepth: 1
   :glob:

   map_*

Ghi chú sử dụng
===========

.. c:function::
   int bpf(int command, union bpf_attr *attr, u32 size)

Sử dụng lệnh gọi hệ thống ZZ0000ZZ để thực hiện thao tác được chỉ định bởi
ZZ0001ZZ. Hoạt động lấy các tham số được cung cấp trong ZZ0002ZZ. ZZ0003ZZ
đối số là kích thước của ZZ0004ZZ trong ZZ0005ZZ.

ZZ0000ZZ

Tạo bản đồ với loại và thuộc tính mong muốn trong ZZ0000ZZ:

.. code-block:: c

    int fd;
    union bpf_attr attr = {
            .map_type = BPF_MAP_TYPE_ARRAY;  /* mandatory */
            .key_size = sizeof(__u32);       /* mandatory */
            .value_size = sizeof(__u32);     /* mandatory */
            .max_entries = 256;              /* mandatory */
            .map_flags = BPF_F_MMAPABLE;
            .map_name = "example_array";
    };

    fd = bpf(BPF_MAP_CREATE, &attr, sizeof(attr));

Trả về bộ mô tả tệp quy trình cục bộ khi thành công hoặc lỗi âm trong trường hợp
thất bại. Bản đồ có thể bị xóa bằng cách gọi ZZ0000ZZ. Bản đồ được giữ bởi mở
bộ mô tả tệp sẽ tự động bị xóa khi quá trình thoát.

.. note:: Valid characters for ``map_name`` are ``A-Z``, ``a-z``, ``0-9``,
   ``'_'`` and ``'.'``.

ZZ0000ZZ

Tra cứu khóa trong bản đồ nhất định bằng ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ. Trả về 0 và lưu trữ phần tử được tìm thấy vào ZZ0003ZZ trên
thành công hoặc lỗi tiêu cực khi thất bại.

ZZ0000ZZ

Tạo hoặc cập nhật cặp khóa/giá trị trong bản đồ nhất định bằng ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ. Trả về 0 nếu thành công hoặc trả về lỗi âm nếu thất bại.

ZZ0000ZZ

Tìm và xóa phần tử theo khóa trong bản đồ nhất định bằng ZZ0000ZZ,
ZZ0001ZZ. Trả về 0 nếu thành công hoặc trả về lỗi âm nếu thất bại.

.. Links:
.. _man-pages: https://www.kernel.org/doc/man-pages/
.. _bpf(2): https://man7.org/linux/man-pages/man2/bpf.2.html
.. _bpf-helpers(7): https://man7.org/linux/man-pages/man7/bpf-helpers.7.html
.. _ebpf-syscall: https://docs.kernel.org/userspace-api/ebpf/syscall.html
