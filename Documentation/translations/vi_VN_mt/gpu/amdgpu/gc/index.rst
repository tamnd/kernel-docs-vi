.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/gc/index.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _amdgpu-gc:

============================================
 drm/amdgpu - Đồ họa và Điện toán (GC)
========================================

Mối quan hệ giữa CPU và GPU có thể được mô tả là
vấn đề nhà sản xuất-người tiêu dùng, trong đó CPU điền vào bộ đệm bằng các thao tác
(nhà sản xuất) được thực thi bởi GPU (người tiêu dùng). Các thao tác được yêu cầu trong
bộ đệm được gọi là ZZ0000ZZ, có thể được tóm tắt là
cách nén để truyền thông tin lệnh đến bộ điều khiển đồ họa.

Thành phần đóng vai trò là giao diện người dùng giữa CPU và GPU được gọi là
ZZ0000ZZ. Thành phần này chịu trách nhiệm cung cấp nhiều hơn
tính linh hoạt của ZZ0001ZZ vì CP cho phép
lập trình các khía cạnh khác nhau của đường ống GPU. CP cũng điều phối
giao tiếp giữa CPU và GPU thông qua cơ chế có tên ZZ0002ZZ,
trong đó CPU thêm thông tin vào bộ đệm trong khi GPU xóa
hoạt động. CP cũng chịu trách nhiệm xử lý ZZ0003ZZ.

Để tham khảo, CP bên trong bao gồm một số khối con (CPC - CP
tính toán, CPG - đồ họa CP và CPF - trình tìm nạp CP). Một số từ viết tắt này
xuất hiện trong tên đăng ký, nhưng đây thiên về chi tiết triển khai hơn chứ không phải
thứ gì đó tác động trực tiếp đến việc lập trình hoặc gỡ lỗi trình điều khiển.

Đồ họa (GFX) và Vi điều khiển điện toán
-------------------------------------------

GC là một khối lớn và kết quả là nó có nhiều phần sụn được liên kết với
nó. Một số trong số đó là:

CP (Bộ xử lý lệnh)
    Tên của khối phần cứng bao gồm mặt trước của
    GFX/Đường dẫn tính toán. Bao gồm chủ yếu là một loạt các bộ vi điều khiển
    (PFP, ME, CE, MEC). Phần sụn chạy trên các bộ vi điều khiển này
    cung cấp giao diện trình điều khiển để tương tác với công cụ GFX/Compute.

MEC (Tính toán vi động cơ)
        Đây là bộ vi điều khiển điều khiển hàng đợi tính toán trên
        GFX/công cụ tính toán.

MES (Bộ lập lịch MicroEngine)
        Đây là công cụ để quản lý hàng đợi. Để biết thêm chi tiết, hãy kiểm tra
        ZZ0000ZZ.

RLC (Bộ điều khiển RunList)
    Đây là một bộ vi điều khiển khác trong công cụ GFX/Compute. Nó xử lý
    chức năng liên quan đến quản lý năng lượng trong công cụ GFX/Compute.
    Tên này là dấu tích của phần cứng cũ nơi nó được thêm vào ban đầu
    và không thực sự có nhiều liên quan đến những gì động cơ làm hiện nay.

.. toctree::

   mes.rst
