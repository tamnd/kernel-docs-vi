.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/keystone/overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
Tổng quan về TI Keystone Linux
==============================

Giới thiệu
------------
Dòng SoC chính dựa trên Bộ xử lý MPCore ARM Cortex-A15
và lõi c66x DSP. Tài liệu này mô tả các thông tin cần thiết cần thiết
để người dùng chạy Linux trên EVM dựa trên Keystone từ Texas Instruments.

Các SoC & EVM sau hiện được hỗ trợ: -

K2HK SoC và EVM
=================

hay còn gọi là Keystone 2 Hawking/Kepler SoC
TCI6636K2H & TCI6636K2K: Xem tài liệu tại

ZZ0000ZZ
	ZZ0001ZZ

EVM:
  ZZ0000ZZ

K2E SoC và EVM
===============

hay còn gọi là Keystone 2 Edison SoC

K2E - 66AK2E05:

Xem tài liệu tại

ZZ0000ZZ

EVM:
   ZZ0000ZZ

K2L SoC và EVM
===============

hay còn gọi là Keystone 2 Lamarr SoC

K2L - TCI6630K2L:

Xem tài liệu tại
	ZZ0000ZZ

EVM:
  ZZ0000ZZ

Cấu hình
-------------

Tất cả các SoC/EVM K2 đều có chung một defconfig, keystone_defconfig và giống nhau
image được sử dụng để khởi động trên các EVM riêng lẻ. Cấu hình nền tảng là
được chỉ định thông qua DTS. Sau đây là DTS được sử dụng:

K2HK EVM:
		k2hk-evm.dts
	K2E EVM:
		k2e-evm.dts
	K2L EVM:
		k2l-evm.dts

Tài liệu về cây thiết bị cho các máy keystone được đặt tại

Tài liệu/devicetree/binds/arm/ti/ti,keystone.yaml

Tác giả tài liệu
---------------
Murali Kar Richi <m-karicheri2@ti.com>

Bản quyền 2015 Texas Instruments
