.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/dma-buf.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Chia sẻ và đồng bộ hóa bộ đệm (dma-buf)
============================================

Hệ thống con dma-buf cung cấp khuôn khổ để chia sẻ bộ đệm cho
truy cập phần cứng (DMA) trên nhiều trình điều khiển thiết bị và hệ thống con, và
để đồng bộ hóa truy cập phần cứng không đồng bộ.

Ví dụ, nó được sử dụng rộng rãi bởi hệ thống con DRM để trao đổi
vùng đệm giữa các tiến trình, ngữ cảnh, API thư viện trong cùng một
xử lý và cũng có thể trao đổi bộ đệm với các hệ thống con khác như
V4L2.

Tài liệu này mô tả cách thức mà các hệ thống con kernel có thể sử dụng và
tương tác với ba nguyên hàm chính được cung cấp bởi dma-buf:

- dma-buf, đại diện cho một sg_table và hiển thị với không gian người dùng dưới dạng một tệp
   bộ mô tả để cho phép chuyển giữa các tiến trình, hệ thống con, thiết bị,
   v.v;
 - dma-fence, cung cấp cơ chế báo hiệu khi không đồng bộ
   hoạt động phần cứng đã hoàn thành; và
 - dma-resv, quản lý một tập hợp các hàng rào dma cho một dma-buf cụ thể
   cho phép đồng bộ hóa công việc ngầm (theo thứ tự hạt nhân) với
   duy trì ảo tưởng về khả năng truy cập mạch lạc


Nguyên tắc và cách sử dụng API của không gian người dùng
--------------------------------

Để biết thêm chi tiết về cách thiết kế API của hệ thống con của bạn để sử dụng dma-buf, vui lòng
xem Tài liệu/userspace-api/dma-buf-alloc-exchange.rst.


Bộ đệm DMA được chia sẻ
------------------

Tài liệu này phục vụ như một hướng dẫn cho người viết trình điều khiển thiết bị về dma-buf là gì
chia sẻ bộ đệm API, cách sử dụng nó để xuất và sử dụng bộ đệm dùng chung.

Bất kỳ trình điều khiển thiết bị nào muốn tham gia chia sẻ bộ đệm DMA đều có thể thực hiện như sau:
hoặc là 'nhà xuất khẩu' bộ đệm hoặc 'người dùng' hoặc 'người nhập' bộ đệm.

Giả sử trình điều khiển A muốn sử dụng bộ đệm do trình điều khiển B tạo thì chúng ta gọi B là
nhà xuất khẩu và A là người dùng/người nhập bộ đệm.

Nhà xuất khẩu

- thực hiện và quản lý các hoạt động trong ZZ0000ZZ cho bộ đệm,
 - cho phép người dùng khác chia sẻ bộ đệm bằng cách sử dụng API chia sẻ dma_buf,
 - quản lý chi tiết phân bổ bộ đệm, được gói trong ZZ0001ZZ,
 - quyết định về dung lượng lưu trữ dự phòng thực tế nơi việc phân bổ này diễn ra,
 - và xử lý mọi hoạt động di chuyển danh sách phân tán - cho tất cả người dùng (được chia sẻ) của
   bộ đệm này.

Người sử dụng bộ đệm

- là một trong (nhiều) người dùng chia sẻ bộ đệm.
 - không cần phải lo lắng về cách phân bổ bộ đệm hoặc ở đâu.
 - và cần một cơ chế để có quyền truy cập vào danh sách phân tán tạo nên điều này
   bộ đệm trong bộ nhớ, được ánh xạ vào không gian địa chỉ của chính nó để nó có thể truy cập vào
   cùng một vùng bộ nhớ. Giao diện này được cung cấp bởi ZZ0000ZZ.

Bất kỳ nhà xuất khẩu hoặc người dùng khung chia sẻ bộ đệm dma-buf đều phải có
'chọn DMA_SHARED_BUFFER' trong Kconfigs tương ứng của chúng.

Ghi chú về giao diện không gian người dùng
~~~~~~~~~~~~~~~~~~~~~~~~~

Hầu hết bộ mô tả tệp bộ đệm DMA chỉ đơn giản là một đối tượng mờ đục cho không gian người dùng,
và do đó giao diện chung được hiển thị là rất tối thiểu. Có một vài điều cần
mặc dù vậy hãy xem xét:

- Kể từ kernel 3.12, dma-buf FD hỗ trợ lệnh gọi hệ thống llseek, nhưng chỉ
  với offset=0 và fromce=SEEK_END|SEEK_SET. SEEK_SET được hỗ trợ để cho phép
  kích thước mẫu khám phá thông thường kích thước = SEEK_END(0); SEEK_SET(0). Mỗi người khác
  hoạt động llseek sẽ báo cáo -EINVAL.

Nếu llseek trên dma-buf FD không được hỗ trợ thì kernel sẽ báo cáo -ESPIPE cho tất cả
  trường hợp. Không gian người dùng có thể sử dụng điều này để phát hiện hỗ trợ khám phá dma-buf
  kích thước bằng cách sử dụng llseek.

- Để tránh rò rỉ fd trên exec, phải đặt cờ FD_CLOEXEC
  trên bộ mô tả tập tin.  Đây không chỉ là rò rỉ tài nguyên mà còn là một
  lỗ hổng bảo mật tiềm ẩn.  Nó có thể cung cấp cho ứng dụng mới được thực thi
  quyền truy cập vào bộ đệm, thông qua fd bị rò rỉ, nếu không thì nó sẽ
  không được phép truy cập.

Vấn đề khi thực hiện việc này thông qua lệnh gọi fcntl() riêng biệt, so với việc thực hiện nó
  về mặt nguyên tử khi fd được tạo ra, có phải điều này vốn đã đặc biệt trong một
  ứng dụng đa luồng [3].  Vấn đề trở nên tồi tệ hơn khi đó là mã thư viện
  mở/tạo bộ mô tả tập tin, vì ứng dụng thậm chí có thể không
  biết về fd.

Để tránh sự cố này, không gian người dùng phải có cách yêu cầu O_CLOEXEC
  cờ được đặt khi dma-buf fd được tạo.  Vì vậy, bất kỳ API nào được cung cấp bởi
  trình điều khiển xuất để tạo dmabuf fd phải cung cấp một cách để cho phép
  cài đặt kiểm soát không gian người dùng của cờ O_CLOEXEC được chuyển vào dma_buf_fd().

- Bộ nhớ ánh xạ nội dung của bộ đệm DMA cũng được hỗ trợ. Xem
  thảo luận bên dưới về ZZ0000ZZ để biết chi tiết đầy đủ.

- Bộ đệm FD DMA cũng có thể thăm dò được, hãy xem ZZ0000ZZ bên dưới để biết
  chi tiết.

- Bộ đệm FD DMA cũng hỗ trợ một số ioctls dành riêng cho dma-buf, xem
  ZZ0000ZZ bên dưới để biết chi tiết.

Hoạt động cơ bản và truy cập thiết bị DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-buf.c
   :doc: dma buf device access

CPU Truy cập vào các đối tượng bộ đệm DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-buf.c
   :doc: cpu access

Hỗ trợ thăm dò hàng rào ngầm
~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-buf.c
   :doc: implicit fence polling

Bộ đệm DMA ioctls
~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/uapi/linux/dma-buf.h

Quy ước khóa DMA-BUF
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-buf.c
   :doc: locking convention

Tham khảo cấu trúc và chức năng hạt nhân
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-buf.c
   :export:

.. kernel-doc:: include/linux/dma-buf.h
   :internal:

Đối tượng đặt trước
-------------------

.. kernel-doc:: drivers/dma-buf/dma-resv.c
   :doc: Reservation Object Overview

.. kernel-doc:: drivers/dma-buf/dma-resv.c
   :export:

.. kernel-doc:: include/linux/dma-resv.h
   :internal:

Hàng rào DMA
----------

.. kernel-doc:: drivers/dma-buf/dma-fence.c
   :doc: DMA fences overview

Hợp đồng lái xe chéo hàng rào DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence.c
   :doc: fence cross-driver contract

Chú thích tín hiệu hàng rào DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence.c
   :doc: fence signalling annotation

Gợi ý về thời hạn hàng rào DMA
~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence.c
   :doc: deadline hints

Tham khảo chức năng hàng rào DMA
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence.c
   :export:

.. kernel-doc:: include/linux/dma-fence.h
   :internal:

Mảng hàng rào DMA
~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence-array.c
   :export:

.. kernel-doc:: include/linux/dma-fence-array.h
   :internal:

Chuỗi hàng rào DMA
~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/dma-fence-chain.c
   :export:

.. kernel-doc:: include/linux/dma-fence-chain.h
   :internal:

DMA Hàng rào mở
~~~~~~~~~~~~~~~~

.. kernel-doc:: include/linux/dma-fence-unwrap.h
   :internal:

Tệp đồng bộ hóa hàng rào DMA
~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: drivers/dma-buf/sync_file.c
   :export:

.. kernel-doc:: include/linux/sync_file.h
   :internal:

Tệp đồng bộ hóa hàng rào DMA uABI
~~~~~~~~~~~~~~~~~~~~~~~~

.. kernel-doc:: include/uapi/linux/sync_file.h
   :internal:

Hàng rào DMA không xác định
~~~~~~~~~~~~~~~~~~~~~

Tại nhiều thời điểm, hãy cấu trúc dma_fence với thời gian không xác định cho đến khi dma_fence_wait()
kết thúc đã được đề xuất. Ví dụ bao gồm:

* Hàng rào trong tương lai, được sử dụng trong HWC1 để báo hiệu khi màn hình không sử dụng bộ đệm
  nữa và được tạo bằng bản cập nhật màn hình giúp hiển thị bộ đệm.
  Thời gian hoàn thành hàng rào này hoàn toàn nằm trong tầm kiểm soát của không gian người dùng.

* Hàng rào proxy, được đề xuất xử lý &drm_syncobj mà hàng rào chưa có
  đã được thiết lập. Được sử dụng để trì hoãn việc gửi lệnh một cách không đồng bộ.

* Hàng rào không gian người dùng hoặc gpu futexes, khóa chi tiết trong bộ đệm lệnh
  không gian người dùng đó sử dụng để đồng bộ hóa giữa các công cụ hoặc với CPU,
  sau đó được nhập dưới dạng hàng rào DMA để tích hợp vào winsys hiện có
  giao thức.

* Bộ đệm lệnh tính toán chạy dài, trong khi vẫn sử dụng phần cuối truyền thống của
  hàng rào DMA hàng loạt để quản lý bộ nhớ thay vì ưu tiên ngữ cảnh DMA
  hàng rào được gắn lại khi công việc tính toán được lên lịch lại.

Điểm chung của tất cả các lược đồ này là không gian người dùng kiểm soát sự phụ thuộc của các lược đồ này.
hàng rào và điều khiển khi họ bắn. Trộn hàng rào vô thời hạn với hàng rào bình thường
Hàng rào DMA trong hạt nhân không hoạt động, ngay cả khi đã thêm thời gian chờ dự phòng vào
bảo vệ chống lại không gian người dùng độc hại:

* Chỉ kernel mới biết về tất cả các phụ thuộc hàng rào DMA, không gian người dùng không biết
  của các phần phụ thuộc được đưa vào do quản lý bộ nhớ hoặc các quyết định của người lập lịch.

* Chỉ không gian người dùng mới biết về tất cả các phần phụ thuộc trong hàng rào không xác định và khi nào
  chính xác là chúng sẽ hoàn thành, kernel không có khả năng hiển thị.

Hơn nữa, kernel phải có khả năng xử lý việc gửi lệnh của không gian người dùng
cho nhu cầu quản lý bộ nhớ, điều đó có nghĩa là chúng ta phải hỗ trợ các hàng rào không xác định
phụ thuộc vào hàng rào DMA. Nếu hạt nhân cũng hỗ trợ hàng rào không xác định trong
hạt nhân giống như hàng rào DMA, giống như bất kỳ đề xuất nào ở trên, có
khả năng xảy ra bế tắc.

.. kernel-render:: DOT
   :alt: Indefinite Fencing Dependency Cycle
   :caption: Indefinite Fencing Dependency Cycle

   digraph "Fencing Cycle" {
      node [shape=box bgcolor=grey style=filled]
      kernel [label="Kernel DMA Fences"]
      userspace [label="userspace controlled fences"]
      kernel -> userspace [label="memory management"]
      userspace -> kernel [label="Future fence, fence proxy, ..."]

      { rank=same; kernel userspace }
   }

Điều này có nghĩa là kernel có thể vô tình tạo ra deadlocks
thông qua các phần phụ thuộc quản lý bộ nhớ mà không gian người dùng không biết đến,
treo khối lượng công việc một cách ngẫu nhiên cho đến khi hết thời gian chờ. Khối lượng công việc, từ
phối cảnh của không gian người dùng, không chứa bế tắc.  Trong một hàng rào hỗn hợp như vậy
kiến trúc không có thực thể duy nhất nào có kiến thức về tất cả các phụ thuộc.
Do đó, việc ngăn chặn những bế tắc như vậy từ bên trong kernel là không thể.

Giải pháp duy nhất để tránh vòng lặp phụ thuộc là không cho phép sử dụng không xác định
hàng rào trong hạt nhân. Điều này có nghĩa là:

* Không có hàng rào, hàng rào proxy hoặc hàng rào không gian người dùng trong tương lai được nhập dưới dạng hàng rào DMA,
  có hoặc không có thời gian chờ.

* Không có hàng rào DMA báo hiệu kết thúc bộ đệm lô để gửi lệnh trong đó
  không gian người dùng được phép sử dụng hàng rào không gian người dùng hoặc điện toán chạy dài
  khối lượng công việc. Điều này cũng có nghĩa là không có hàng rào ngầm cho các bộ đệm dùng chung trong các
  trường hợp.

Ý nghĩa của lỗi trang phần cứng có thể phục hồi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Phần cứng hiện đại hỗ trợ các lỗi trang có thể phục hồi, có rất nhiều lỗi.
ý nghĩa đối với hàng rào DMA.

Đầu tiên, một lỗi trang đang chờ xử lý rõ ràng đã cản trở công việc đang chạy trên
thường cần phải có bộ tăng tốc và phân bổ bộ nhớ để giải quyết lỗi.
Nhưng việc phân bổ bộ nhớ không được phép hoàn thành cổng của hàng rào DMA, điều này
có nghĩa là bất kỳ khối lượng công việc nào sử dụng lỗi trang có thể phục hồi đều không thể sử dụng hàng rào DMA cho
đồng bộ hóa. Phải sử dụng hàng rào đồng bộ hóa được kiểm soát bởi không gian người dùng
thay vào đó.

Trên GPU, điều này gây ra một vấn đề vì các giao thức tổng hợp máy tính để bàn hiện tại trên
Linux dựa vào hàng rào DMA, nghĩa là không có ngăn xếp không gian người dùng hoàn toàn mới
được xây dựng dựa trên hàng rào không gian người dùng, họ không thể hưởng lợi từ trang có thể phục hồi
lỗi. Cụ thể điều này có nghĩa là việc đồng bộ hóa ngầm sẽ không thể thực hiện được.
Ngoại lệ là khi lỗi trang chỉ được sử dụng làm gợi ý di chuyển và không bao giờ được sử dụng.
theo yêu cầu điền vào một yêu cầu bộ nhớ. Hiện tại điều này có nghĩa là trang có thể phục hồi được
lỗi trên GPU chỉ giới hạn ở khối lượng công việc tính toán thuần túy.

Hơn nữa, GPU thường có tài nguyên được chia sẻ giữa kết xuất 3D và
phía tính toán, như đơn vị tính toán hoặc công cụ gửi lệnh. Nếu cả 3D
công việc với hàng rào DMA và khối lượng công việc tính toán sử dụng các lỗi trang có thể phục hồi là
đang chờ xử lý họ có thể bế tắc:

- Khối lượng công việc 3D có thể phải đợi công việc tính toán kết thúc và giải phóng
  tài nguyên phần cứng đầu tiên.

- Khối lượng công việc tính toán có thể bị kẹt do lỗi trang do bộ nhớ
  việc phân bổ đang chờ hàng rào DMA của khối lượng công việc 3D hoàn tất.

Có một số tùy chọn để ngăn chặn sự cố này, một trong số đó trình điều khiển cần phải
đảm bảo:

- Khối lượng công việc tính toán luôn có thể được ưu tiên, ngay cả khi lỗi trang đang chờ xử lý
  và vẫn chưa được sửa chữa. Không phải tất cả phần cứng đều hỗ trợ điều này.

- Khối lượng công việc hàng rào DMA và khối lượng công việc cần xử lý lỗi trang có
  tài nguyên phần cứng độc lập để đảm bảo tiến độ về phía trước. Đây có thể là
  đạt được thông qua ví dụ. thông qua các công cụ chuyên dụng và đơn vị tính toán tối thiểu
  đặt chỗ cho khối lượng công việc hàng rào DMA.

- Phương pháp đặt trước có thể được cải tiến hơn nữa bằng cách chỉ đặt trước
  tài nguyên phần cứng cho khối lượng công việc hàng rào DMA khi chúng đang hoạt động. Điều này phải
  bao gồm thời gian từ khi hàng rào DMA hiển thị cho các luồng khác cho đến khi
  thời điểm hàng rào được hoàn thành thông qua dma_fence_signal().

- Biện pháp cuối cùng, nếu phần cứng không cung cấp cơ chế đặt trước hữu ích,
  tất cả khối lượng công việc phải được xóa khỏi GPU khi chuyển đổi giữa các công việc
  yêu cầu hàng rào DMA hoặc công việc yêu cầu xử lý lỗi trang: Điều này có nghĩa là tất cả DMA
  hàng rào phải hoàn thành trước khi công việc tính toán có xử lý lỗi trang có thể được thực hiện
  được chèn vào hàng đợi của bộ lập lịch. Và ngược lại, trước khi hàng rào DMA có thể được
  hiển thị ở mọi nơi trong hệ thống, tất cả khối lượng công việc điện toán phải được ưu tiên
  để đảm bảo tất cả các lỗi trang GPU đang chờ xử lý đều được xóa.

- Chỉ có một lựa chọn khá lý thuyết là gỡ rối những sự phụ thuộc này khi
  phân bổ bộ nhớ để sửa lỗi trang phần cứng, thông qua các
  khối bộ nhớ hoặc theo dõi thời gian chạy của biểu đồ phụ thuộc đầy đủ của tất cả DMA
  hàng rào. Kết quả này tác động rất rộng đến kernel, kể từ khi giải quyết trang
  về phía CPU bản thân nó có thể liên quan đến lỗi trang. Nó khả thi hơn nhiều và
  mạnh mẽ để hạn chế tác động của việc xử lý lỗi trang phần cứng đối với các lỗi cụ thể
  người lái xe.

Lưu ý rằng khối lượng công việc chạy trên phần cứng độc lập như công cụ sao chép hoặc các công cụ khác
GPU không có bất kỳ tác động nào. Điều này cho phép chúng tôi tiếp tục sử dụng hàng rào DMA trong nội bộ
trong kernel ngay cả để giải quyết các lỗi trang phần cứng, ví dụ: bằng cách sử dụng bản sao
công cụ xóa hoặc sao chép bộ nhớ cần thiết để giải quyết lỗi trang.

Ở một khía cạnh nào đó, vấn đề lỗi trang này là một trường hợp đặc biệt trong các cuộc thảo luận về ZZ0000ZZ: Hàng rào vô hạn từ khối lượng công việc tính toán được phép
phụ thuộc vào hàng rào DMA, nhưng không phải ngược lại. Và thậm chí không có lỗi trang
vấn đề này là mới, bởi vì một số luồng CPU khác trong không gian người dùng có thể
gặp phải một lỗi trang làm cản trở không gian người dùng - hỗ trợ các lỗi trang trên
GPU về cơ bản không có gì mới.
