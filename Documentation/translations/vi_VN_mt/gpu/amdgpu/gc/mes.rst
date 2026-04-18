.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/gc/mes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _amdgpu-mes:

================================
 Bộ lập lịch MicroEngine (MES)
=============================

.. note::
   Queue and ring buffer are used as a synonymous.

.. note::
   This section assumes that you are familiar with the concept of Pipes, Queues, and GC.
   If not, check :ref:`GFX, Compute, and SDMA Overall Behavior<pipes-and-queues-description>`
   and :ref:`drm/amdgpu - Graphics and Compute (GC) <amdgpu-gc>`.

Mỗi GFX đều có một thành phần ống với một hoặc nhiều hàng phần cứng. Ống có thể
chuyển đổi giữa các hàng đợi tùy thuộc vào các điều kiện nhất định và một trong các
các thành phần có thể yêu cầu chuyển hàng đợi sang một đường ống là MicroEngine
Bộ lập lịch (MES). Bất cứ khi nào trình điều khiển được khởi tạo, nó sẽ tạo một MQD cho mỗi
hàng đợi phần cứng, sau đó MQD được chuyển tới phần sụn MES để ánh xạ
đến:

1. Hàng đợi hạt nhân (cũ): Hàng đợi này được ánh xạ tĩnh tới các HQD và không bao giờ
   được ưu tiên. Mặc dù đây là tính năng cũ nhưng đây là tính năng mặc định hiện tại và
   hầu hết phần cứng hiện có đều hỗ trợ nó. Khi một ứng dụng nộp tác phẩm tới
   trình điều khiển hạt nhân, nó sẽ gửi tất cả bộ đệm lệnh ứng dụng vào hạt nhân
   hàng đợi. CS IOCTL lấy bộ đệm lệnh từ các ứng dụng và
   sắp xếp chúng trên hàng đợi kernel.

2. Hàng đợi người dùng: Các hàng đợi này được ánh xạ động tới HQD. Về việc
   tận dụng Hàng đợi Người dùng, ứng dụng không gian người dùng sẽ tạo người dùng của nó
   hàng đợi và gửi tác phẩm trực tiếp đến hàng đợi người dùng mà không cần đến IOCTL
   mỗi lần gửi và không cần chia sẻ một hàng đợi kernel.

Về Hàng đợi người dùng, MES có thể tự động ánh xạ chúng tới HQD. Nếu có
nhiều MQD hơn HQD, chương trình cơ sở MES sẽ ưu tiên hàng đợi người dùng khác thực hiện
đảm bảo mỗi hàng đợi có được một lát thời gian; nói cách khác, MES là một vi điều khiển
xử lý việc ánh xạ và hủy ánh xạ các MQD thành HQD, cũng như
ưu tiên và đăng ký vượt mức MQD.
