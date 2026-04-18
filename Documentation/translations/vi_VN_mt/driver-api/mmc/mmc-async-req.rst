.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mmc/mmc-async-req.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Yêu cầu không đồng bộ MMC
========================

Cơ sở lý luận
=========

Chi phí bảo trì bộ đệm đáng kể như thế nào?

Nó phụ thuộc. eMMC nhanh và nhiều cấp độ bộ đệm với bộ đệm suy đoán
tìm nạp trước làm cho chi phí bộ nhớ đệm tương đối đáng kể. Nếu DMA
việc chuẩn bị cho yêu cầu tiếp theo được thực hiện song song với yêu cầu hiện tại
chuyển, chi phí chuẩn bị DMA sẽ không ảnh hưởng đến hiệu suất của MMC.

Mục đích của các yêu cầu MMC không chặn (không đồng bộ) là để giảm thiểu
khoảng thời gian từ khi một yêu cầu MMC kết thúc đến khi một yêu cầu MMC khác bắt đầu.

Sử dụng mmc_wait_for_req(), bộ điều khiển MMC không hoạt động trong khi dma_map_sg và
dma_unmap_sg đang xử lý. Việc sử dụng các yêu cầu MMC không chặn sẽ khiến nó
có thể chuẩn bị bộ đệm cho công việc tiếp theo song song với hoạt động
Yêu cầu MMC.

Trình điều khiển khối MMC
================

mmc_blk_issue_rw_rq() trong trình điều khiển khối MMC được đặt ở chế độ không chặn.

Sự gia tăng thông lượng tỷ lệ thuận với thời gian cần thiết để
chuẩn bị (phần chính của việc chuẩn bị là dma_map_sg() và dma_unmap_sg())
một yêu cầu và tốc độ bộ nhớ. MMC/SD càng nhanh thì
thời gian yêu cầu chuẩn bị trở nên quan trọng hơn. Đại khái là dự kiến
tăng hiệu suất là 5% khi ghi lớn và 10% khi đọc lớn trên bộ đệm L2
nền tảng. Ở chế độ tiết kiệm năng lượng, khi đồng hồ chạy ở tần số thấp hơn, DMA
việc chuẩn bị có thể tốn kém hơn nữa. Miễn là việc chuẩn bị chậm hơn này được thực hiện
song song với hiệu suất truyền sẽ không bị ảnh hưởng.

Chi tiết về các phép đo từ IOZone và mmc_test
================================================

ZZ0000ZZ

Phần mở rộng MMC lõi API
======================

Có một hàm công khai mới mmc_start_req().

Nó bắt đầu yêu cầu lệnh MMC mới cho máy chủ. Chức năng này không
thực sự không bị chặn. Nếu có một yêu cầu không đồng bộ đang diễn ra, nó sẽ chờ
để hoàn thành yêu cầu đó và bắt đầu yêu cầu mới và trả về. Nó
không đợi yêu cầu mới hoàn thành. Nếu không có hoạt động liên tục
request nó bắt đầu yêu cầu mới và trả về ngay lập tức.

Tiện ích mở rộng máy chủ MMC
===================

Có hai thành viên tùy chọn trong mmc_host_ops -- pre_req() và
post_req() -- trình điều khiển máy chủ có thể triển khai để di chuyển công việc
trước và sau hàm mmc_host_ops.request() thực tế được gọi.

Trong trường hợp DMA pre_req() có thể thực hiện dma_map_sg() và chuẩn bị DMA
bộ mô tả và post_req() chạy dma_unmap_sg().

Tối ưu hóa cho yêu cầu đầu tiên
==============================

Yêu cầu đầu tiên trong một loạt yêu cầu không thể được chuẩn bị song song
với lần chuyển tiền trước đó, vì không có yêu cầu nào trước đó.

Đối số is_first_req trong pre_req() chỉ ra rằng không có giá trị nào trước đó
yêu cầu. Trình điều khiển máy chủ có thể tối ưu hóa cho tình huống này để giảm thiểu
sự mất hiệu suất. Một cách để tối ưu hóa điều này là chia dòng điện
yêu cầu thành hai phần, chuẩn bị phần đầu tiên và bắt đầu yêu cầu,
và cuối cùng chuẩn bị đoạn thứ hai và bắt đầu chuyển.

Mã giả để xử lý tình huống is_first_req với chi phí chuẩn bị tối thiểu::

if (is_first_req && req->size > ngưỡng)
     /* bắt đầu truyền MMC để có kích thước truyền hoàn chỉnh */
     mmc_start_command(MMC_CMD_TRANSFER_FULL_SIZE);

/*
      * Bắt đầu chuẩn bị DMA trong khi cmd đang được MMC xử lý.
      * Đoạn đầu tiên của yêu cầu sẽ mất cùng thời gian
      * để chuẩn bị làm "thời gian lệnh xử lý MMC".
      * Nếu thời gian chuẩn bị vượt quá thời gian cmd MMC
      * quá trình chuyển bị trì hoãn, ước tính tối đa 4k là kích thước đoạn đầu tiên.
      */
      chuẩn bị_1st_chunk_for_dma(req);
      /* xả desc đang chờ xử lý sang DMAC (dmaengine.h) */
      dma_issue_pending(req->dma_desc);

prepare_2nd_chunk_for_dma(req);
      /*
       * Vấn đề thứ hai đang chờ xử lý phải được gọi trước khi hết MMC
       * của đoạn đầu tiên. Nếu MMC hết đoạn dữ liệu đầu tiên
       * trước cuộc gọi này, quá trình chuyển bị trì hoãn.
       */
      dma_issue_pending(req->dma_desc);
