.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/perf/imx-ddr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================================================
Bộ giám sát hiệu suất i.MX8 DDR của Freescale (PMU)
=====================================================

Không có bộ đếm hiệu suất bên trong bộ điều khiển DRAM, vì vậy hiệu suất
tín hiệu được đưa ra rìa của bộ điều khiển nơi có một bộ 4 x 32 bit
bộ đếm được thực hiện. Điều này được điều khiển bởi các chế độ CSV được lập trình trong bộ đếm
thanh ghi điều khiển tạo ra một số lượng lớn tín hiệu PERF.

Việc lựa chọn giá trị cho mỗi bộ đếm được thực hiện thông qua các thanh ghi cấu hình. Ở đó
là một thanh ghi cho mỗi bộ đếm. Bộ đếm 0 đặc biệt ở chỗ nó luôn đếm
“thời gian” và khi hết hạn sẽ gây ra khóa trên chính nó và các bộ đếm khác và một
ngắt được nâng lên. Nếu bất kỳ bộ đếm nào khác bị tràn, nó sẽ tiếp tục đếm và
không có ngắt nào được nâng lên.

Thư mục "format" mô tả định dạng của config (ID sự kiện) và config1/2
Các trường (cài đặt bộ lọc AXI) của cấu trúc perf_event_attr, xem /sys/bus/event_source/
thiết bị/imx8_ddr0/format/. Thư mục "sự kiện" mô tả các loại sự kiện
phần cứng được hỗ trợ có thể được sử dụng với công cụ hoàn hảo, xem /sys/bus/event_source/
thiết bị/imx8_ddr0/sự kiện/. Thư mục "caps" mô tả các tính năng lọc được triển khai
trong DDR PMU, xem /sys/bus/events_source/devices/imx8_ddr0/caps/.

    .. code-block:: bash

        perf stat -a -e imx8_ddr0/cycles/ cmd
        perf stat -a -e imx8_ddr0/read/,imx8_ddr0/write/ cmd

Lọc AXI chỉ được sử dụng bởi các chế độ CSV 0x41 (đọc axid) và 0x42 (ghi axid)
để đếm việc đọc hoặc viết phù hợp với cài đặt bộ lọc. Cài đặt bộ lọc rất đa dạng
từ các triển khai bộ điều khiển DRAM khác nhau, được phân biệt bằng các đặc điểm
trong người lái xe. Bạn cũng có thể kết xuất thông tin từ không gian người dùng, thư mục "caps" hiển thị
loại bộ lọc AXI (bộ lọc, bộ lọc nâng cao và bộ lọc super_filter). Giá trị 0 cho
không được hỗ trợ và giá trị 1 là được hỗ trợ.

* Với quirk DDR_CAP_AXI_ID_FILTER (bộ lọc: 1, bộ lọc nâng cao: 0, super_filter: 0).
  Bộ lọc được xác định với hai phần cấu hình:
  --AXI_ID xác định giá trị khớp AxID.
  --AXI_MASKING xác định bit nào của AxID có ý nghĩa cho việc so khớp.

- 0: bit tương ứng bị che.
      - 1: bit tương ứng không bị che, tức là được sử dụng để thực hiện so khớp.

AXI_ID và AXI_MASKING được ánh xạ trên thanh ghi DPCR1 trong bộ đếm hiệu suất.
  Khi các bit không bị che khớp khớp với các bit AXI_ID tương ứng thì bộ đếm sẽ
  tăng lên. Bộ đếm hoàn hảo được tăng lên nếu::

AxID && AXI_MASKING == AXI_ID && AXI_MASKING

Bộ lọc này không hỗ trợ lọc ID AXI khác nhau để đọc và ghi axid
  sự kiện cùng lúc khi bộ lọc này được chia sẻ giữa các bộ đếm.

  .. code-block:: bash

      perf stat -a -e imx8_ddr0/axid-read,axi_mask=0xMMMM,axi_id=0xDDDD/ cmd
      perf stat -a -e imx8_ddr0/axid-write,axi_mask=0xMMMM,axi_id=0xDDDD/ cmd

  .. note::

      axi_mask is inverted in userspace(i.e. set bits are bits to mask), and
      it will be reverted in driver automatically. so that the user can just specify
      axi_id to monitor a specific id, rather than having to specify axi_mask.

  .. code-block:: bash

        perf stat -a -e imx8_ddr0/axid-read,axi_id=0x12/ cmd, which will monitor ARID=0x12

* Với quirk DDR_CAP_AXI_ID_FILTER_ENHANCED (bộ lọc: 1, bộ lọc nâng cao: 1, super_filter: 0).
  Đây là phần mở rộng của lỗi DDR_CAP_AXI_ID_FILTER cho phép
  đếm số byte (trái ngược với số lượng cụm) từ DDR
  đọc và ghi các giao dịch đồng thời với một bộ đếm dữ liệu khác.

* Với quirk DDR_CAP_AXI_ID_PORT_CHANNEL_FILTER (bộ lọc: 0, bộ lọc nâng cao: 0, super_filter: 1).
  Có một hạn chế trong bộ lọc AXI trước đó, nó không thể lọc các ID khác nhau
  đồng thời bộ lọc được chia sẻ giữa các bộ đếm. Điều kỳ quặc này là
  phần mở rộng của bộ lọc ID AXI. Một cải tiến là quầy 1-3 có riêng
  filter, có nghĩa là nó hỗ trợ lọc đồng thời nhiều ID khác nhau. Khác
  cải tiến là bộ đếm 1-3 hỗ trợ lựa chọn AXI PORT và CHANNEL. Hỗ trợ
  chọn kênh địa chỉ hoặc kênh dữ liệu.

Bộ lọc được xác định bằng 2 thanh ghi cấu hình trên mỗi bộ đếm 1-3.
  --Bộ đếm N MASK COMP thanh ghi - bao gồm AXI_ID và AXI_MASKING.
  --Bộ đếm N MUX CNTL đăng ký - bao gồm AXI CHANNEL và AXI PORT.

- 0: kênh địa chỉ
      - 1: kênh dữ liệu

PMU trong hệ thống con DDR, chỉ tồn tại một cổng0 duy nhất, vì vậy axi_port được bảo lưu
  đó phải là 0.

  .. code-block:: bash

      perf stat -a -e imx8_ddr0/axid-read,axi_mask=0xMMMM,axi_id=0xDDDD,axi_channel=0xH/ cmd
      perf stat -a -e imx8_ddr0/axid-write,axi_mask=0xMMMM,axi_id=0xDDDD,axi_channel=0xH/ cmd

  .. note::

      axi_channel is inverted in userspace, and it will be reverted in driver
      automatically. So that users do not need specify axi_channel if want to
      monitor data channel from DDR transactions, since data channel is more
      meaningful.
