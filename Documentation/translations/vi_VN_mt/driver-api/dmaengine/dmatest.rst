.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/dmaengine/dmatest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================
Hướng dẫn kiểm tra DMA
======================

Andy Shevchenko <andriy.shevchenko@linux.intel.com>

Tài liệu nhỏ này giới thiệu cách kiểm tra trình điều khiển DMA bằng mô-đun dmatest.

Mô-đun dmatest kiểm tra các hoạt động của DMA memcpy, memset, XOR và RAID6 P+Q bằng cách sử dụng
độ dài khác nhau và độ lệch khác nhau vào bộ đệm nguồn và đích. Nó
sẽ khởi tạo cả hai bộ đệm với mẫu có thể lặp lại và xác minh rằng DMA
công cụ sao chép vùng được yêu cầu và không có gì hơn. Nó cũng sẽ xác minh rằng
các byte không bị hoán đổi và bộ đệm nguồn không bị sửa đổi.

Mô-đun dmatest có thể được cấu hình để kiểm tra một kênh cụ thể. Nó cũng có thể
kiểm tra nhiều kênh cùng một lúc và nó có thể bắt đầu nhiều luồng
cạnh tranh cho cùng một kênh.

.. note::
  The test suite works only on the channels that have at least one
  capability of the following: DMA_MEMCPY (memory-to-memory), DMA_MEMSET
  (const-to-memory or memory-to-memory, when emulated), DMA_XOR, DMA_PQ.

.. note::
  In case of any related questions use the official mailing list
  dmaengine@vger.kernel.org.

Phần 1 - Cách xây dựng mô-đun thử nghiệm
=====================================

Menuconfig chứa một tùy chọn có thể được tìm thấy theo đường dẫn sau:

Trình điều khiển thiết bị -> Hỗ trợ DMA Engine -> Máy khách thử nghiệm DMA

Trong tệp cấu hình, tùy chọn có tên CONFIG_DMATEST. Người thân nhất có thể
được xây dựng dưới dạng mô-đun hoặc bên trong kernel. Hãy xem xét những trường hợp đó.

Phần 2 - Khi dmatest được xây dựng dưới dạng mô-đun
==========================================

Ví dụ về cách sử dụng::

% modprobe dmatet timeout=2000 lần lặp=1 kênh=dma0chan0 run=1

...or::

    % modprobe dmatest
    % echo 2000 > /sys/module/dmatest/parameters/timeout
    % echo 1 > /sys/module/dmatest/parameters/iterations
    % echo dma0chan0 > /sys/module/dmatest/parameters/channel
    % echo 1 > /sys/module/dmatest/parameters/run

...or on the kernel command line::

    dmatest.timeout=2000 dmatest.iterations=1 dmatest.channel=dma0chan0 dmatest.run=1

Ví dụ về cách sử dụng thử nghiệm đa kênh (mới trong kernel 5.0)::

% modprobe dmatet
    % echo 2000 > /sys/module/dmatest/parameters/timeout
    % echo 1 > /sys/module/dmatest/parameters/iterations
    % echo dma0chan0 > /sys/module/dmatet/parameters/channel
    % echo dma0chan1 > /sys/module/dmatet/parameters/channel
    % echo dma0chan2 > /sys/module/dmatet/parameters/channel
    % echo 1 > /sys/module/dmatet/parameters/run

.. note::
  For all tests, starting in the 5.0 kernel, either single- or multi-channel,
  the channel parameter(s) must be set after all other parameters. It is at
  that time that the existing parameter values are acquired for use by the
  thread(s). All other parameters are shared. Therefore, if changes are made
  to any of the other parameters, and an additional channel specified, the
  (shared) parameters used for all threads will use the new values.
  After the channels are specified, each thread is set as pending. All threads
  begin execution when the run parameter is set to 1.

.. hint::
  A list of available channels can be found by running the following command::

    % ls -1 /sys/class/dma/

Sau khi bắt đầu một tin nhắn như " dmatest: Đã thêm 1 chủ đề bằng dma0chan0" là
phát ra. Một chuỗi cho kênh cụ thể đó đã được tạo và hiện đang chờ xử lý,
chuỗi đang chờ xử lý được bắt đầu sau khi chạy tới 1.

Lưu ý rằng việc chạy thử nghiệm mới sẽ không dừng bất kỳ thử nghiệm nào đang diễn ra.

Lệnh sau trả về trạng thái của bài kiểm tra. ::

% cat /sys/module/dmatet/parameters/run

Để chờ hoàn thành kiểm tra, người dùng có thể thăm dò 'chạy' cho đến khi sai hoặc sử dụng
tham số chờ đợi. Chỉ định 'wait=1' khi tải mô-đun khiến mô-đun
khởi tạo để tạm dừng cho đến khi chạy thử hoàn tất, trong khi đọc
/sys/module/dmatest/parameters/wait chờ mọi thử nghiệm đang chạy hoàn tất
trước khi quay lại. Ví dụ: các tập lệnh sau chờ 42 bài kiểm tra
để hoàn thành trước khi thoát. Lưu ý rằng nếu 'lặp lại' được đặt thành 'vô hạn' thì
chờ đợi bị vô hiệu hóa.

Ví dụ::

% modprobe dmates run=1 lần lặp=42 chờ=1
    % modprobe -r dmatet

...or::

    % modprobe dmatest run=1 iterations=42
    % cat /sys/module/dmatest/parameters/wait
    % modprobe -r dmatest

Phần 3 - Khi tích hợp sẵn trong kernel
====================================

Các tham số mô-đun được cung cấp cho dòng lệnh kernel sẽ được sử dụng
cho lần thử nghiệm được thực hiện đầu tiên. Sau khi người dùng có quyền kiểm soát, quá trình kiểm tra có thể được thực hiện
chạy lại với các tham số giống nhau hoặc khác nhau. Để biết chi tiết, xem ở trên
phần ZZ0000ZZ.

Trong cả hai trường hợp, các tham số mô-đun được sử dụng làm giá trị thực tế cho thử nghiệm
trường hợp. Bạn luôn có thể kiểm tra chúng trong thời gian chạy bằng cách chạy ::

% grep -H . /sys/mô-đun/dmatest/tham số/*

Phần 4 – Thu thập kết quả kiểm tra
===================================

Kết quả kiểm tra được in vào bộ đệm nhật ký kernel với định dạng::

"dmatest: result <channel>: <test id>: '<error msg>' with src_off=<val> dst_off=<val> len=<val> (<err code>)"

Ví dụ về đầu ra::

% dmesg | đuôi -n 1
    dmatest: kết quả dma0chan0-copy0: #1: Không có lỗi với src_off=0x7bf dst_off=0x8ad len=0x3fea (0)

Định dạng thông báo được thống nhất cho các loại lỗi khác nhau. A
số trong ngoặc thể hiện thông tin bổ sung, ví dụ: lỗi
mã, bộ đếm lỗi hoặc trạng thái. Một luồng kiểm tra cũng phát ra một dòng tóm tắt tại
hoàn thành liệt kê số lượng thử nghiệm được thực hiện, số lượng không thành công và
mã kết quả

Ví dụ::

% dmesg | đuôi -n 1
    dmatest: dma0chan0-copy0: tóm tắt 1 bài kiểm tra, 0 lỗi 1000 iops 100000 KB/s (0)

Các chi tiết về lỗi so sánh sai dữ liệu cũng được đưa ra nhưng không tuân theo
định dạng trên.

Phần 5 - Xử lý phân bổ kênh
====================================

Phân bổ kênh
-------------------

Các kênh không cần phải được cấu hình trước khi bắt đầu chạy thử. Đang cố gắng
chạy thử nghiệm mà không định cấu hình các kênh sẽ dẫn đến việc thử nghiệm bất kỳ
các kênh có sẵn.

Ví dụ::

% echo 1 > /sys/module/dmatet/parameters/run
    dmatest: Không có kênh nào được định cấu hình, hãy tiếp tục với bất kỳ kênh nào

Các kênh được đăng ký bằng tham số "kênh". Các kênh có thể được yêu cầu bởi họ
tên, sau khi được yêu cầu, kênh sẽ được đăng ký và một chuỗi đang chờ xử lý sẽ được thêm vào danh sách kiểm tra.

Ví dụ::

% echo dma0chan2 > /sys/module/dmatet/parameters/channel
    dmatest: Đã thêm 1 chủ đề bằng dma0chan2

Có thể thêm nhiều kênh hơn bằng cách lặp lại ví dụ trên.
Đọc lại tham số kênh sẽ trả về tên của kênh cuối cùng đã được thêm thành công.

Ví dụ::

% echo dma0chan1 > /sys/module/dmatet/parameters/channel
    dmatest: Đã thêm 1 chủ đề bằng dma0chan1
    % echo dma0chan2 > /sys/module/dmatet/parameters/channel
    dmatest: Đã thêm 1 chủ đề bằng dma0chan2
    % cat/sys/mô-đun/dmatet/tham số/kênh
    dma0chan2

Một phương pháp yêu cầu kênh khác là yêu cầu một kênh có chuỗi trống. Làm như vậy
sẽ yêu cầu kiểm tra tất cả các kênh có sẵn:

Ví dụ::

% echo "" > /sys/module/dmatet/parameters/channel
    dmatest: Đã thêm 1 chủ đề bằng dma0chan0
    dmatest: Đã thêm 1 chủ đề bằng dma0chan3
    dmatest: Đã thêm 1 chủ đề bằng dma0chan4
    dmatest: Đã thêm 1 chủ đề bằng dma0chan5
    dmatest: Đã thêm 1 chủ đề bằng dma0chan6
    dmatest: Đã thêm 1 chủ đề bằng dma0chan7
    dmatest: Đã thêm 1 chủ đề bằng dma0chan8

Tại bất kỳ thời điểm nào trong quá trình cấu hình kiểm tra, việc đọc tham số "test_list" sẽ
in danh sách các bài kiểm tra hiện đang chờ xử lý.

Ví dụ::

% cat /sys/module/dmatet/parameters/test_list
    dmatest: 1 chủ đề sử dụng dma0chan0
    dmatest: 1 chủ đề sử dụng dma0chan3
    dmatest: 1 chủ đề sử dụng dma0chan4
    dmatest: 1 chủ đề sử dụng dma0chan5
    dmatest: 1 chủ đề sử dụng dma0chan6
    dmatest: 1 chủ đề sử dụng dma0chan7
    dmatest: 1 chủ đề sử dụng dma0chan8

Lưu ý: Các kênh sẽ phải được định cấu hình cho mỗi lần chạy thử vì cấu hình kênh không
chuyển sang lần chạy thử tiếp theo.

Kênh phát hành
-------------------

Các kênh có thể được giải phóng bằng cách đặt run về 0.

Ví dụ::

% echo dma0chan1 > /sys/module/dmatet/parameters/channel
    dmatest: Đã thêm 1 chủ đề bằng dma0chan1
    % mèo /sys/class/dma/dma0chan1/in_use
    1
    % echo 0 > /sys/module/dmatet/parameters/run
    % mèo /sys/class/dma/dma0chan1/in_use
    0

Các kênh được phân bổ bởi các lần chạy thử trước đó sẽ tự động được giải phóng khi có kênh mới
kênh được yêu cầu sau khi hoàn thành quá trình chạy thử nghiệm thành công.
