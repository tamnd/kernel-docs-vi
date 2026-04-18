.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/mpc52xx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================
Linux 2.6.x trên dòng MPC52xx
================================

Để biết thông tin mới nhất, hãy truy cập ZZ0000ZZ

Để biên dịch/sử dụng:

- U-Boot::

# <sửa Makefile để đặt ARCH=ppc & CROSS_COMPILE=... ( cũng là EXTRAVERSION
        nếu bạn muốn).
     # make lite5200_defconfig
     # make uHình ảnh

sau đó, trên U-boot:
     => tftpboot 200000 uImage
     => tftpboot 400000 pRamdisk
     => khởi động 200000 400000

- DBug::

# <sửa Makefile để đặt ARCH=ppc & CROSS_COMPILE=... ( cũng là EXTRAVERSION
        nếu bạn muốn).
     # make lite5200_defconfig
     # cp your_initrd.gz Arch/ppc/boot/images/ramdisk.image.gz
     # make zImage.initrd
     # make

sau đó trong DBug:
     DBug> dn -i zImage.initrd.lite5200


Một số nhận xét:

- Cổng có tên là mpc52xxx, tùy chọn cấu hình là PPC_MPC52xx. MGT5100
   không được hỗ trợ và tôi không chắc có ai quan tâm đến việc phát triển nó không
   vậy. Tôi đã không lấy 5xxx vì rõ ràng có rất nhiều 5xxx có
   không liên quan gì đến MPC5200. Tôi cũng bao gồm 'MPC' cho cùng
   lý do.
 - Tất nhiên là mình lấy cảm hứng từ port 2.4. Nếu bạn nghĩ tôi đã quên
   đề cập đến bạn/công ty của bạn trong bản quyền của một số mã, tôi sẽ sửa nó
   ASAP.
