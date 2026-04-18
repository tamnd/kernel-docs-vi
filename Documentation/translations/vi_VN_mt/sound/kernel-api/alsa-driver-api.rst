.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/kernel-api/alsa-driver-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Trình điều khiển ALSA API
===================

Quản lý thẻ và thiết bị
===============================

Quản lý thẻ
---------------
.. kernel-doc:: sound/core/init.c

Linh kiện thiết bị
-----------------
.. kernel-doc:: sound/core/device.c

Yêu cầu mô-đun và mục nhập tệp thiết bị
---------------------------------------
.. kernel-doc:: sound/core/sound.c

Người trợ giúp quản lý bộ nhớ
-------------------------
.. kernel-doc:: sound/core/memory.c
.. kernel-doc:: sound/core/memalloc.c


PCM API
=======

Lõi PCM
--------
.. kernel-doc:: sound/core/pcm.c
.. kernel-doc:: sound/core/pcm_lib.c
.. kernel-doc:: sound/core/pcm_native.c
.. kernel-doc:: include/sound/pcm.h

Trình trợ giúp định dạng PCM
------------------
.. kernel-doc:: sound/core/pcm_misc.c

Quản lý bộ nhớ PCM
---------------------
.. kernel-doc:: sound/core/pcm_memory.c

PCM DMA Động cơ API
------------------
.. kernel-doc:: sound/core/pcm_dmaengine.c
.. kernel-doc:: include/sound/dmaengine_pcm.h

Bộ điều khiển/Trộn API
=================

Giao diện điều khiển chung
-------------------------
.. kernel-doc:: sound/core/control.c

Bộ giải mã AC97 API
--------------
.. kernel-doc:: sound/pci/ac97/ac97_codec.c
.. kernel-doc:: sound/pci/ac97/ac97_pcm.c

Điều khiển tổng thể ảo API
--------------------------
.. kernel-doc:: sound/core/vmaster.c
.. kernel-doc:: include/sound/control.h

MIDI API
========

MIDI API thô
------------
.. kernel-doc:: sound/core/rawmidi.c

MPU401-UART API
---------------
.. kernel-doc:: sound/drivers/mpu401/mpu401_uart.c

Thông tin Proc API
=============

Giao diện thông tin Proc
-------------------
.. kernel-doc:: sound/core/info.c

Nén giảm tải
================

Nén giảm tải API
--------------------
.. kernel-doc:: sound/core/compress_offload.c
.. kernel-doc:: include/uapi/sound/compress_offload.h
.. kernel-doc:: include/uapi/sound/compress_params.h
.. kernel-doc:: include/sound/compress_driver.h

ASoC
====

Lõi ASoC API
-------------
.. kernel-doc:: include/sound/soc.h
.. kernel-doc:: sound/soc/soc-core.c
.. kernel-doc:: sound/soc/soc-devres.c
.. kernel-doc:: sound/soc/soc-component.c
.. kernel-doc:: sound/soc/soc-pcm.c
.. kernel-doc:: sound/soc/soc-ops.c
.. kernel-doc:: sound/soc/soc-compress.c

ASoC DAPM API
-------------
.. kernel-doc:: sound/soc/soc-dapm.c

Động cơ ASoC DMA API
-------------------
.. kernel-doc:: sound/soc/soc-generic-dmaengine-pcm.c

Chức năng khác
=======================

Thiết bị phụ thuộc vào phần cứng API
------------------------------
.. kernel-doc:: sound/core/hwdep.c

Lớp trừu tượng Jack API
--------------------------
.. kernel-doc:: include/sound/jack.h
.. kernel-doc:: sound/core/jack.c
.. kernel-doc:: sound/soc/soc-jack.c

Người trợ giúp ISA DMA
---------------
.. kernel-doc:: sound/core/isadma.c

Macro trợ giúp khác
-------------------
.. kernel-doc:: include/sound/core.h
.. kernel-doc:: sound/sound_core.c
