.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/misc-devices/uacce.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Uacce (Khung tăng tốc hợp nhất/dành cho người dùng truy cập vào không gian)
===========================================================================

Giới thiệu
------------

Mục tiêu của Uacce (Khung tăng tốc hợp nhất/dành cho người dùng truy cập vào không gian) là
cung cấp Địa chỉ ảo được chia sẻ (SVA) giữa các bộ tăng tốc và quy trình.
Vì vậy, máy gia tốc có thể truy cập bất kỳ cấu trúc dữ liệu nào của cpu chính.
Điều này khác với việc chia sẻ dữ liệu giữa CPU và thiết bị io, chia sẻ
chỉ nội dung dữ liệu chứ không phải địa chỉ.
Do địa chỉ thống nhất, phần cứng và không gian người dùng của quy trình có thể
chia sẻ cùng một địa chỉ ảo trong giao tiếp.
Uacce lấy bộ tăng tốc phần cứng làm bộ xử lý không đồng nhất, trong khi
IOMMU chia sẻ cùng các bảng trang CPU và kết quả là có cùng một bản dịch
từ va đến pa.

::

__________________________ __________________________
        ZZ0000ZZ ZZ0001ZZ
        ZZ0002ZZ ZZ0003ZZ
        ZZ0004ZZ ZZ0005ZZ

ZZ0000ZZ
                     ZZ0001ZZ và
                     V V
                 __________ __________
                ZZ0002ZZ ZZ0003ZZ
                ZZ0004ZZ ZZ0005ZZ
                ZZ0006ZZ ZZ0007ZZ
                     ZZ0008ZZ
                     ZZ0009ZZ
                     V pa V pa
                 _______________________________________
                ZZ0010ZZ
                ZZ0011ZZ
                ZZ0012ZZ



Ngành kiến ​​​​trúc
-------------------

Uacce là mô-đun hạt nhân, chịu trách nhiệm về iommu và chia sẻ địa chỉ.
Trình điều khiển và thư viện người dùng được gọi là WarpDrive.

Thiết bị uacce, được xây dựng xung quanh IOMMU SVA API, có thể truy cập nhiều
không gian địa chỉ, bao gồm cả không gian không có PASID.

Một khái niệm ảo, hàng đợi, được sử dụng để liên lạc. Nó cung cấp một
Giao diện giống FIFO. Và nó duy trì một không gian địa chỉ thống nhất giữa
ứng dụng và tất cả phần cứng liên quan.

::

___________________ ________________
                            Người dùng ZZ0000ZZ API ZZ0001ZZ
                            ZZ0002ZZ -----------> ZZ0003ZZ
                            ZZ0004ZZ ZZ0005ZZ
                                     ZZ0006ZZ
                                     ZZ0007ZZ
                                     ZZ0008ZZ
                                     ZZ0009ZZ
                                     ZZ0010ZZ
                                     v |
     ___________________ _________ |
    ZZ0011ZZ ZZ0012ZZ | bộ nhớ mmap
    ZZ0013ZZ ZZ0014ZZ | giao diện r/w
    ZZ0015ZZ ZZ0016ZZ |
    ZZ0017ZZ |
             ZZ0018ZZ |
             Đăng ký ZZ0019ZZ |
             ZZ0020ZZ |
             ZZ0021ZZ |
             ZZ0022ZZ
             ZZ0023ZZ ZZ0024ZZ ZZ0025ZZ
              ------------- ZZ0026ZZ ZZ0027ZZ |
                             ZZ0028ZZ ZZ0029ZZ |
                                     ZZ0030ZZ
                                     |                                    V.
                                     |                            ___________________
                                     ZZ0031ZZ |
                                     ----------------- ZZ0032ZZ
                                                                 ZZ0033ZZ


Nó hoạt động như thế nào
------------------------

Uacce sử dụng mmap và IOMMU để chơi trò lừa.

Uacce tạo chrdev cho mọi thiết bị đã đăng ký với nó. Hàng đợi mới là
được tạo khi ứng dụng người dùng mở chrdev. Bộ mô tả tập tin được sử dụng
với tư cách là người dùng xử lý hàng đợi.
Thiết bị tăng tốc tự thể hiện dưới dạng đối tượng Uacce, xuất dưới dạng
một chrdev vào không gian người dùng. Ứng dụng người dùng giao tiếp với
phần cứng bằng ioctl (dưới dạng đường dẫn điều khiển) hoặc bộ nhớ chia sẻ (dưới dạng đường dẫn dữ liệu).

Đường dẫn điều khiển đến phần cứng là thông qua thao tác tệp, trong khi đường dẫn dữ liệu là
thông qua không gian mmap của hàng đợi fd.

Không gian địa chỉ tệp hàng đợi:

::

/**
   * enum uacce_qfrt: kiểu qfrt
   * @UACCE_QFRT_MMIO: vùng mmio của thiết bị
   * @UACCE_QFRT_DUS: vùng chia sẻ người dùng thiết bị
   */
  enum uacce_qfrt {
          UACCE_QFRT_MMIO = 0,
          UACCE_QFRT_DUS = 1,
  };

Tất cả các vùng đều là tùy chọn và khác nhau tùy theo loại thiết bị.
Mỗi vùng chỉ có thể được thêm một lần, nếu không -EEXIST sẽ trả về.

Vùng mmio của thiết bị được ánh xạ tới không gian mmio phần cứng. Nói chung là
được sử dụng cho chuông cửa hoặc thông báo khác cho phần cứng. Nó không đủ nhanh
dưới dạng kênh dữ liệu.

Vùng chia sẻ người dùng thiết bị được sử dụng để chia sẻ bộ đệm dữ liệu giữa tiến trình người dùng
và thiết bị.


Thanh ghi Uacce API
----------------------

Thanh ghi API được xác định trong uacce.h.

::

cấu trúc uacce_interface {
    tên char[UACCE_MAX_NAME_SIZE];
    cờ int không dấu;
    const struct uacce_ops *ops;
  };

Theo khả năng của IOMMU, cờ uacce_interface có thể là:

::

/**
   * Cờ thiết bị UACCE:
   * UACCE_DEV_SVA: Địa chỉ ảo được chia sẻ
   * Hỗ trợ PASID
   * Hỗ trợ lỗi trang thiết bị (PCI PRI hoặc SMMU Stall)
   */
  #define UACCE_DEV_SVA BIT(0)

cấu trúc uacce_device *uacce_alloc(struct device *parent,
                                   cấu trúc uacce_interface *giao diện);
  int uacce_register(struct uacce_device *uacce);
  void uacce_remove(struct uacce_device *uacce);

kết quả uacce_register có thể là:

Một. Nếu mô-đun uacce không được biên dịch, ERR_PTR(-ENODEV)

b. Thành công với những lá cờ mong muốn

c. Thành công với những lá cờ được đàm phán chẳng hạn

uacce_interface.flags = UACCE_DEV_SVA nhưng uacce->flags = ~UACCE_DEV_SVA

Vì vậy, trình điều khiển người dùng cần kiểm tra giá trị trả về cũng như các cờ uacce-> đã thương lượng.


Trình điều khiển người dùng
---------------------------

Không gian mmap của tệp hàng đợi sẽ cần trình điều khiển người dùng để kết nối liên lạc
giao thức. Uacce cung cấp một số thuộc tính trong sysfs để trình điều khiển người dùng sử dụng
kết hợp máy gia tốc phù hợp cho phù hợp.
Thêm chi tiết trong Tài liệu/ABI/testing/sysfs-driver-uacce.