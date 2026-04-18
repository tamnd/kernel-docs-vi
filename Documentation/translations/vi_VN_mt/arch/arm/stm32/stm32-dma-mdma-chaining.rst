.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/stm32/stm32-dma-mdma-chaining.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Xích STM32 DMA-MDMA
==========================


Giới thiệu
------------

Tài liệu này mô tả tính năng xâu chuỗi STM32 DMA-MDMA. Nhưng trước khi đi
  hơn nữa, hãy giới thiệu các thiết bị ngoại vi có liên quan.

Để giảm tải việc truyền dữ liệu từ bộ vi xử lý CPU, STM32 (MPU) nhúng
  bộ điều khiển truy cập bộ nhớ trực tiếp (DMA).

SoC STM32MP1 nhúng cả bộ điều khiển STM32 DMA và STM32 MDMA. STM32 DMA
  khả năng định tuyến yêu cầu được tăng cường nhờ bộ ghép kênh yêu cầu DMA
  (STM32 DMAMUX).

ZZ0000ZZ

STM32 DMAMUX định tuyến mọi yêu cầu DMA từ một thiết bị ngoại vi nhất định tới bất kỳ STM32 DMA nào
  bộ điều khiển (STM32MP1 đếm hai kênh bộ điều khiển STM32 DMA).

ZZ0000ZZ

STM32 DMA chủ yếu được sử dụng để triển khai lưu trữ bộ đệm dữ liệu trung tâm (thường ở
  hệ thống SRAM) cho các thiết bị ngoại vi khác nhau. Nó có thể truy cập RAM bên ngoài nhưng
  không có khả năng tạo ra sự truyền tải liên tục thuận tiện để đảm bảo kết quả tốt nhất
  tải của AXI.

ZZ0000ZZ

STM32 MDMA (Master DMA) chủ yếu được sử dụng để quản lý việc truyền dữ liệu trực tiếp giữa
  Bộ đệm dữ liệu RAM mà không cần sự can thiệp của CPU. Nó cũng có thể được sử dụng trong một
  cấu trúc phân cấp sử dụng STM32 DMA làm bộ đệm dữ liệu cấp một
  giao diện cho các thiết bị ngoại vi AHB, trong khi STM32 MDMA hoạt động như cấp độ thứ hai
  DMA với hiệu suất tốt hơn. Là chủ AXI/AHB, STM32 MDMA có thể nắm quyền kiểm soát
  của xe buýt AXI/AHB.


Nguyên tắc
----------

Tính năng xích STM32 DMA-MDMA dựa trên thế mạnh của STM32 DMA và
  Bộ điều khiển STM32 MDMA.

STM32 DMA có Chế độ đệm đôi hình tròn (DBM). Tại mỗi thời điểm kết thúc giao dịch
  (khi bộ đếm dữ liệu DMA - DMA_SxNDTR - đạt 0), con trỏ bộ nhớ
  (được định cấu hình bằng DMA_SxSM0AR và DMA_SxM1AR) được hoán đổi và dữ liệu DMA
  bộ đếm được tự động tải lại. Điều này cho phép SW hoặc STM32 MDMA
  xử lý một vùng bộ nhớ trong khi vùng bộ nhớ thứ hai đang được lấp đầy/sử dụng bởi
  chuyển STM32 DMA.

Với chế độ danh sách liên kết STM32 MDMA, một yêu cầu duy nhất sẽ khởi tạo mảng dữ liệu
  (tập hợp các nút) sẽ được chuyển cho đến khi con trỏ danh sách liên kết cho
  kênh là rỗng. Việc chuyển kênh hoàn tất của nút cuối cùng là sự kết thúc của
  chuyển giao, trừ khi nút đầu tiên và nút cuối cùng được liên kết với nhau, theo cách như vậy
  trường hợp, danh sách liên kết lặp lại để tạo ra một chuyển MDMA vòng tròn.

STM32 MDMA có kết nối trực tiếp với STM32 DMA. Điều này cho phép tự chủ
  giao tiếp và đồng bộ hóa giữa các thiết bị ngoại vi, do đó tiết kiệm CPU
  tài nguyên và tắc nghẽn xe buýt. Truyền tín hiệu hoàn chỉnh của kênh STM32 DMA
  có thể kích hoạt chuyển STM32 MDMA. STM32 MDMA có thể xóa yêu cầu được tạo
  bởi STM32 DMA bằng cách ghi vào thanh ghi Xóa ngắt của nó (có địa chỉ là
  được lưu trữ trong MDMA_CxMAR và mặt nạ bit trong MDMA_CxMDR).

  .. table:: STM32 MDMA interconnect table with STM32 DMA

    +--------------+----------------+-----------+------------+
    | STM32 DMAMUX | STM32 DMA      | STM32 DMA | STM32 MDMA |
    | channels     | channels       | Transfer  | request    |
    |              |                | complete  |            |
    |              |                | signal    |            |
    +==============+================+===========+============+
    | Channel *0*  | DMA1 channel 0 | dma1_tcf0 | *0x00*     |
    +--------------+----------------+-----------+------------+
    | Channel *1*  | DMA1 channel 1 | dma1_tcf1 | *0x01*     |
    +--------------+----------------+-----------+------------+
    | Channel *2*  | DMA1 channel 2 | dma1_tcf2 | *0x02*     |
    +--------------+----------------+-----------+------------+
    | Channel *3*  | DMA1 channel 3 | dma1_tcf3 | *0x03*     |
    +--------------+----------------+-----------+------------+
    | Channel *4*  | DMA1 channel 4 | dma1_tcf4 | *0x04*     |
    +--------------+----------------+-----------+------------+
    | Channel *5*  | DMA1 channel 5 | dma1_tcf5 | *0x05*     |
    +--------------+----------------+-----------+------------+
    | Channel *6*  | DMA1 channel 6 | dma1_tcf6 | *0x06*     |
    +--------------+----------------+-----------+------------+
    | Channel *7*  | DMA1 channel 7 | dma1_tcf7 | *0x07*     |
    +--------------+----------------+-----------+------------+
    | Channel *8*  | DMA2 channel 0 | dma2_tcf0 | *0x08*     |
    +--------------+----------------+-----------+------------+
    | Channel *9*  | DMA2 channel 1 | dma2_tcf1 | *0x09*     |
    +--------------+----------------+-----------+------------+
    | Channel *10* | DMA2 channel 2 | dma2_tcf2 | *0x0A*     |
    +--------------+----------------+-----------+------------+
    | Channel *11* | DMA2 channel 3 | dma2_tcf3 | *0x0B*     |
    +--------------+----------------+-----------+------------+
    | Channel *12* | DMA2 channel 4 | dma2_tcf4 | *0x0C*     |
    +--------------+----------------+-----------+------------+
    | Channel *13* | DMA2 channel 5 | dma2_tcf5 | *0x0D*     |
    +--------------+----------------+-----------+------------+
    | Channel *14* | DMA2 channel 6 | dma2_tcf6 | *0x0E*     |
    +--------------+----------------+-----------+------------+
    | Channel *15* | DMA2 channel 7 | dma2_tcf7 | *0x0F*     |
    +--------------+----------------+-----------+------------+

Tính năng xâu chuỗi STM32 DMA-MDMA sau đó sử dụng bộ đệm SRAM. Nhúng SoC STM32MP1
  ba RAM nội tĩnh truy cập nhanh có kích thước khác nhau, được sử dụng để lưu trữ dữ liệu.
  Do di sản STM32 DMA (trong bộ vi điều khiển), hiệu suất của STM32 DMA là
  tệ với DDR, trong khi chúng tối ưu với SRAM. Do đó bộ đệm SRAM được sử dụng
  giữa STM32 DMA và STM32 MDMA. Bộ đệm này được chia thành hai khoảng thời gian bằng nhau
  và STM32 DMA sử dụng một khoảng thời gian trong khi STM32 MDMA sử dụng khoảng thời gian còn lại
  đồng thời.
  ::

dma[1:2]-tcf[0:7]
                   .----------------.
     ____________' _________ V____________
    ZZ0000ZZ / __ZZ0001ZZ STM32 MDMA |
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ
    ZZ0005ZZ<=>ZZ0006ZZ SRAM ZZ0007ZZ<=>ZZ0008ZZ
    ZZ0009ZZ ZZ0010ZZ ZZ0011ZZ
    ZZ0012ZZ \___<ZZ0013ZZ____________|

Sử dụng chuỗi STM32 DMA-MDMA (struct dma_slave_config).peripheral_config để
  trao đổi các tham số cần thiết để cấu hình MDMA. Các thông số này được
  được tập hợp thành một mảng u32 với ba giá trị:

* yêu cầu STM32 MDMA (thực tế là ID kênh DMAMUX),
  * địa chỉ của thanh ghi STM32 DMA để xóa Hoàn tất chuyển giao
    cờ ngắt,
  * mặt nạ của cờ ngắt Hoàn tất Truyền của kênh STM32 DMA.

Bản cập nhật Cây thiết bị cho hỗ trợ chuỗi STM32 DMA-MDMA
-------------------------------------------------------

ZZ0000ZZ

Nút cây thiết bị SRAM được xác định trong cây thiết bị SoC. Bạn có thể tham khảo nó ở
    cây thiết bị bảng của bạn để xác định nhóm SRAM của bạn.
    ::

&sram {
                  my_foo_device_dma_pool: dma-sram@0 {
                          reg = <0x0 0x1000>;
                  };
          };

Hãy cẩn thận với chỉ mục bắt đầu, trong trường hợp có những người tiêu dùng SRAM khác.
    Xác định kích thước nhóm của bạn một cách chiến lược: để tối ưu hóa chuỗi, ý tưởng là
    STM32 DMA và STM32 MDMA có thể hoạt động đồng thời trên mỗi bộ đệm của
    SRAM.
    Nếu khoảng thời gian SRAM lớn hơn thời gian chuyển DMA dự kiến thì STM32 DMA
    và STM32 MDMA sẽ hoạt động tuần tự thay vì đồng thời. Nó không phải là một
    vấn đề chức năng nhưng nó không phải là tối ưu.

Đừng quên tham khảo nhóm SRAM trong nút thiết bị của bạn. Bạn cần phải
    xác định một thuộc tính mới.
    ::

&my_foo_device {
                  ...
my_dma_pool = &my_foo_device_dma_pool;
          };

Sau đó lấy nhóm SRAM này trong trình điều khiển foo của bạn và phân bổ bộ đệm SRAM của bạn.

ZZ0000ZZ

Bạn cần xác định một kênh bổ sung trong nút cây thiết bị của mình, ngoài
    cái bạn nên có cho hoạt động DMA "cổ điển".

Kênh mới này phải được lấy từ các kênh STM32 MDMA, do đó, phần chính của
    bộ điều khiển DMA sẽ sử dụng là bộ điều khiển của MDMA.
    ::

&my_foo_device {
                  […]
                  my_dma_pool = &my_foo_device_dma_pool;
                  dmas = <&dmamux1 ...>, // kênh STM32 DMA
                         <&mdma1 0 0x3 0x1200000a 0 0>; // + Kênh STM32 MDMA
          };

Liên quan đến các ràng buộc STM32 MDMA:

1. Số dòng yêu cầu: bất kể giá trị ở đây là gì thì nó sẽ bị ghi đè
    bởi trình điều khiển MDMA với ID kênh STM32 DMAMUX được chuyển qua
    (struct dma_slave_config).peripheral_config

2. Mức độ ưu tiên : chọn Very High (0x3) để kênh của bạn sẽ
    ưu tiên người khác trong quá trình phân xử yêu cầu

3. Mặt nạ 32 bit chỉ định cấu hình kênh DMA: nguồn và
    tăng địa chỉ đích, truyền khối với 128 byte mỗi đơn
    chuyển nhượng

4. Giá trị 32bit chỉ định thanh ghi được sử dụng để xác nhận
    yêu cầu: nó sẽ được ghi đè bởi trình điều khiển MDMA, với kênh DMA
    cờ ngắt xóa địa chỉ đăng ký được chuyển qua
    (struct dma_slave_config).peripheral_config

5. Mặt nạ 32bit chỉ định giá trị được ghi để xác nhận
    yêu cầu: nó sẽ được ghi đè bởi trình điều khiển MDMA, với kênh DMA
    Chuyển cờ hoàn thành được thông qua
    (struct dma_slave_config).peripheral_config

Cập nhật trình điều khiển cho hỗ trợ chuỗi STM32 DMA-MDMA trong trình điều khiển foo
----------------------------------------------------------------

ZZ0000ZZ

Trong trường hợp dmaengine_prep_slave_sg(), sg_table ban đầu không thể được sử dụng làm
    là. Hai sg_table mới phải được tạo từ bảng gốc. Một cho
    Chuyển STM32 DMA (trong đó địa chỉ bộ nhớ bây giờ nhắm mục tiêu vào bộ đệm SRAM
    của bộ đệm DDR) và một để truyền STM32 MDMA (trong đó địa chỉ bộ nhớ nhắm mục tiêu
    bộ đệm DDR).

Các mục sg_list mới phải phù hợp với độ dài khoảng thời gian SRAM. Đây là một ví dụ cho
    DMA_DEV_TO_MEM:
    ::

/*
        * Giả sử sgl và nents tương ứng là danh sách phân tán ban đầu và danh sách phân tán ban đầu của nó
        * chiều dài.
        * Giả sử lần lượt là sram_dma_buf và sram_ Period là bộ nhớ
        * được phân bổ từ nhóm để sử dụng DMA và thời lượng của khoảng thời gian,
        * bằng một nửa kích thước sram_buf.
        */
      cấu trúc sg_table new_dma_sgt, new_mdma_sgt;
      danh sách phân tán cấu trúc *s, *_sgl;
      dma_addr_t ddr_dma_buf;
      u32 new_nents = 0, len;
      int tôi;

/* Đếm số lượng mục cần thiết */
      for_each_sg(sgl, s, nents, i)
              if (sg_dma_len(s) > sram_apse)
                      new_nents += DIV_ROUND_UP(sg_dma_len(s), sram_ Period);
              khác
                      new_nents++;

/* Tạo bảng sg cho kênh STM32 DMA */
      ret = sg_alloc_table(&new_dma_sgt, new_nents, GFP_ATOMIC);
      nếu (ret)
              dev_err(dev, "Việc phân bổ bảng sg DMA không thành công\n");

for_each_sg(new_dma_sgt.sgl, s, new_dma_sgt.nents, i) {
              _sgl = sgl;
              sg_dma_len(s) = min(sg_dma_len(_sgl), sram_ Period);
              /* Nhắm mục tiêu phần đầu = nửa đầu của sram_buf */
              s->dma_address = sram_buf;
              /*
                * Nhắm mục tiêu vào nửa sau của sram_buf
                * cho chỉ mục lẻ của mục trong sg_list
                */
              nếu (tôi & 1)
                      s->dma_address += sram_ Period;
      }

/* Tạo bảng sg cho kênh STM32 MDMA */
      ret = sg_alloc_table(&new_mdma_sgt, new_nents, GFP_ATOMIC);
      nếu (ret)
              dev_err(dev, "MDMA sg_table cấp phát không thành công\n");

_sgl = sgl;
      len = sg_dma_len(sgl);
      ddr_dma_buf = sg_dma_address(sgl);
      for_each_sg(mdma_sgt.sgl, s, mdma_sgt.nents, i) {
              size_t byte = min_t(size_t, len, sram_ Period);

sg_dma_len(s) = byte;
              sg_dma_address(s) = ddr_dma_buf;
              len -= byte;

if (!len && sg_next(_sgl)) {
                      _sgl = sg_next(_sgl);
                      len = sg_dma_len(_sgl);
                      ddr_dma_buf = sg_dma_address(_sgl);
              } khác {
                      ddr_dma_buf += byte;
              }
      }

Đừng quên phát hành các sg_tables mới này sau khi nhận được phần mô tả
    với dmaengine_prep_slave_sg().

ZZ0000ZZ

Đầu tiên, sử dụng dmaengine_slave_config() với struct dma_slave_config để
    định cấu hình kênh STM32 DMA. Bạn chỉ cần quan tâm đến địa chỉ DMA,
    địa chỉ bộ nhớ (tùy thuộc vào hướng truyền) phải trỏ vào
    Bộ đệm SRAM và đặt (struct dma_slave_config).peripheral_size != 0.

Trình điều khiển STM32 DMA sẽ kiểm tra (struct dma_slave_config).peripheral_size thành
    xác định xem chuỗi có được sử dụng hay không. Nếu nó được sử dụng thì STM32 DMA
    trình điều khiển điền vào (struct dma_slave_config).peripheral_config với một mảng
    ba u32 : cái đầu tiên chứa ID kênh STM32 DMAMUX, cái thứ hai
    cờ ngắt kênh xóa địa chỉ thanh ghi và cờ thứ ba
    Chuyển kênh Hoàn thành mặt nạ cờ.

Sau đó, sử dụng dmaengine_slave_config với một cấu trúc dma_slave_config khác để
    định cấu hình kênh STM32 MDMA. Chăm sóc các địa chỉ DMA, địa chỉ thiết bị
    (tùy thuộc vào hướng truyền) phải trỏ vào bộ đệm SRAM của bạn và
    địa chỉ bộ nhớ phải trỏ đến bộ đệm ban đầu được sử dụng cho "cổ điển"
    Hoạt động DMA. Sử dụng (struct dma_slave_config).peripheral_size trước đó
    và .peripheral_config đã được trình điều khiển STM32 DMA cập nhật, để thiết lập
    (struct dma_slave_config).peripheral_size và .peripheral_config của
    struct dma_slave_config để định cấu hình kênh STM32 MDMA.
    ::

cấu trúc dma_slave_config dma_conf;
      cấu trúc dma_slave_config mdma_conf;

bộ nhớ(&dma_conf, 0, sizeof(dma_conf));
      […]
      config.direction = DMA_DEV_TO_MEM;
      config.dst_addr = sram_dma_buf;        // Bộ đệm SRAM
      config.peripheral_size = 1;            // ngoại vi_size != 0 => xâu chuỗi

dmaengine_slave_config(dma_chan, &dma_config);

bộ nhớ(&mdma_conf, 0, sizeof(mdma_conf));
      config.direction = DMA_DEV_TO_MEM;
      mdma_conf.src_addr = sram_dma_buf;     // Bộ đệm SRAM
      mdma_conf.dst_addr = rx_dma_buf;       // vùng đệm bộ nhớ gốc
      mdma_conf.peripheral_size = dma_conf.peripheral_size;       // <- dma_conf
      mdma_conf.peripheral_config = dma_config.peripheral_config; // <- dma_conf

dmaengine_slave_config(mdma_chan, &mdma_conf);

ZZ0000ZZ

Tương tự như cách bạn lấy bộ mô tả cho thao tác DMA "cổ điển" của mình,
    bạn chỉ cần thay thế sg_list ban đầu (trong trường hợp
    dmaengine_prep_slave_sg()) với sg_list mới sử dụng bộ đệm SRAM hoặc để
    thay thế địa chỉ bộ đệm ban đầu, độ dài và khoảng thời gian (trong trường hợp
    dmaengine_prep_dma_cycle()) với bộ đệm SRAM mới.

ZZ0000ZZ

Nếu trước đây bạn nhận được bộ mô tả (đối với STM32 DMA) với

* dmaengine_prep_slave_sg(), sau đó sử dụng dmaengine_prep_slave_sg() cho
      STM32 MDMA;
    * dmaengine_prep_dma_cycle(), sau đó sử dụng dmaengine_prep_dma_cycle() cho
      STM32 MDMA.

Sử dụng sg_list mới bằng bộ đệm SRAM (trong trường hợp dmaengine_prep_slave_sg())
    hoặc, tùy thuộc vào hướng truyền, bộ đệm DDR ban đầu (trong
    trường hợp DMA_DEV_TO_MEM) hoặc bộ đệm SRAM (trong trường hợp DMA_MEM_TO_DEV),
    địa chỉ nguồn được đặt trước đó bằng dmaengine_slave_config().

ZZ0000ZZ

Trước khi gửi giao dịch của mình, bạn có thể cần phải xác định những giao dịch nào
    mô tả bạn muốn gọi lại khi kết thúc quá trình chuyển
    (dmaengine_prep_slave_sg()) hoặc dấu chấm (dmaengine_prep_dma_cycle()).
    Tùy thuộc vào hướng, đặt lệnh gọi lại trên bộ mô tả kết thúc
    chuyển giao tổng thể:

* DMA_DEV_TO_MEM: đặt lệnh gọi lại trên bộ mô tả "MDMA"
    * DMA_MEM_TO_DEV: đặt lệnh gọi lại trên bộ mô tả "DMA"

Sau đó, gửi các bộ mô tả theo thứ tự bất kỳ, với dmaengine_tx_submit().

ZZ0000ZZ

Vì việc chuyển kênh STM32 MDMA được kích hoạt bởi STM32 DMA, bạn phải phát hành
  Kênh STM32 MDMA trước kênh STM32 DMA.

Nếu có, cuộc gọi lại của bạn sẽ được gọi để cảnh báo bạn về sự kết thúc của cuộc gọi tổng thể
  chuyển giao hoặc hoàn thành giai đoạn.

Đừng quên chấm dứt cả hai kênh. Kênh STM32 DMA được cấu hình trong
  chế độ Bộ đệm đôi theo chu kỳ để nó không bị CTNH vô hiệu hóa, bạn cần chấm dứt
  nó. Kênh STM32 MDMA sẽ bị HW dừng trong trường hợp chuyển sg, nhưng không
  trong trường hợp chuyển giao theo chu kỳ. Bạn có thể chấm dứt nó bất kể hình thức chuyển giao nào.

ZZ0000ZZ

Xích STM32 DMA-MDMA trong DMA_MEM_TO_DEV là một trường hợp đặc biệt. Thật vậy,
  STM32 MDMA cung cấp bộ đệm SRAM với dữ liệu DDR và STM32 DMA đọc
  dữ liệu từ bộ đệm SRAM. Vì vậy một số dữ liệu (giai đoạn đầu tiên) phải được sao chép vào
  Bộ đệm SRAM khi STM32 DMA bắt đầu đọc.

Một thủ thuật có thể là tạm dừng kênh STM32 DMA (điều đó sẽ gây ra Chuyển khoản
  Tín hiệu hoàn chỉnh, kích hoạt kênh STM32 MDMA), nhưng dữ liệu đầu tiên được đọc
  của STM32 DMA có thể "sai". Cách thích hợp là chuẩn bị SRAM đầu tiên
  dấu chấm với dmaengine_prep_dma_memcpy(). Sau đó giai đoạn đầu tiên này sẽ là
  "loại bỏ" khỏi sg hoặc chuyển giao theo chu kỳ.

Do sự phức tạp này, nên sử dụng chuỗi STM32 DMA-MDMA cho
  DMA_DEV_TO_MEM và giữ nguyên cách sử dụng DMA "cổ điển" cho DMA_MEM_TO_DEV, trừ khi
  bạn không sợ.

Tài nguyên
---------

Ghi chú ứng dụng, bảng dữ liệu và tài liệu tham khảo có sẵn trên trang web ST
  (STM32MP1_).

Tập trung chuyên dụng vào ba ghi chú ứng dụng (AN5224_, AN4031_ & AN5001_)
  xử lý STM32 DMAMUX, STM32 DMA và STM32 MDMA.

.. _STM32MP1: https://www.st.com/en/microcontrollers-microprocessors/stm32mp1-series.html
.. _AN5224: https://www.st.com/resource/en/application_note/an5224-stm32-dmamux-the-dma-request-router-stmicroelectronics.pdf
.. _AN4031: https://www.st.com/resource/en/application_note/dm00046011-using-the-stm32f2-stm32f4-and-stm32f7-series-dma-controller-stmicroelectronics.pdf
.. _AN5001: https://www.st.com/resource/en/application_note/an5001-stm32cube-expansion-package-for-stm32h7-series-mdma-stmicroelectronics.pdf

:Tác giả:

- Amelie Delaunay <amelie.delaunay@foss.st.com>