.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/atomic_writes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _atomic_writes:

Viết khối nguyên tử
-------------------------

Giới thiệu
~~~~~~~~~~~~

Ghi khối nguyên tử (chưa bị xé) đảm bảo rằng toàn bộ quá trình ghi được cam kết
vào đĩa hoặc không có gì cả. Điều này ngăn ngừa tình trạng "ghi bị rách" khi mất điện hoặc
hệ thống gặp sự cố. Hệ thống tập tin ext4 hỗ trợ ghi nguyên tử (chỉ với Direct
I/O) trên các tệp thông thường có phạm vi mở rộng, được cung cấp thiết bị lưu trữ cơ bản
hỗ trợ ghi nguyên tử phần cứng. Điều này được hỗ trợ theo hai cách sau:

1. ZZ0000ZZ:
   EXT4 hỗ trợ các hoạt động ghi nguyên tử với một khối hệ thống tệp duy nhất kể từ
   v6.13. Trong phần này, cả kích thước tối thiểu và tối đa của đơn vị ghi nguyên tử đều được đặt
   đến kích thước khối của hệ thống tập tin.
   ví dụ. thực hiện ghi nguyên tử 16KB với kích thước khối hệ thống tệp 16KB trên 64KB
   hệ thống kích thước trang là có thể.

2. ZZ0000ZZ:
   EXT4 hiện cũng hỗ trợ ghi nguyên tử trải rộng trên nhiều khối hệ thống tệp
   sử dụng một tính năng được gọi là bigalloc. Đơn vị ghi nguyên tử tối thiểu và
   kích thước tối đa được xác định bởi kích thước khối hệ thống tập tin và kích thước cụm,
   dựa trên giới hạn đơn vị ghi nguyên tử được hỗ trợ của thiết bị cơ bản.

Yêu cầu
~~~~~~~~~~~~

Yêu cầu cơ bản để ghi nguyên tử trong ext4:

1. Tính năng phạm vi phải được bật (mặc định cho ext4)
 2. Thiết bị khối cơ bản phải hỗ trợ ghi nguyên tử
 3. Đối với ghi nguyên tử một fsblock:

1. Hệ thống tập tin có kích thước khối thích hợp (tối đa kích thước trang)
 4. Đối với ghi nguyên tử đa fsblock:

1. Phải bật tính năng bigalloc
    2. Kích thước cụm phải được cấu hình phù hợp

NOTE: EXT4 không hỗ trợ phần mềm hoặc ghi nguyên tử dựa trên COW, có nghĩa là
ghi nguyên tử trên ext4 chỉ được hỗ trợ nếu thiết bị lưu trữ cơ bản hỗ trợ
nó.

Chi tiết triển khai nhiều fsblock
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tính năng bigalloc thay đổi ext4 để phân bổ theo đơn vị của nhiều hệ thống tệp
khối, còn được gọi là cụm. Với bigalloc mỗi bit trong khối bitmap
đại diện cho một cụm (sức mạnh của 2 số khối) chứ không phải riêng lẻ
khối hệ thống tập tin.
EXT4 hỗ trợ ghi nguyên tử đa fsblock với bigalloc, tùy thuộc vào
những hạn chế sau đây. Kích thước ghi nguyên tử tối thiểu là lớn hơn của fs
kích thước khối và đơn vị ghi nguyên tử phần cứng tối thiểu; và nguyên tử cực đại
kích thước ghi nhỏ hơn kích thước cụm bigalloc và phần cứng tối đa
đơn vị ghi nguyên tử  Bigalloc đảm bảo rằng tất cả việc phân bổ đều được căn chỉnh theo
kích thước cụm, đáp ứng các yêu cầu căn chỉnh LBA của phần cứng
thiết bị nếu phần đầu của phân vùng/khối logic được căn chỉnh chính xác.

Đây là chiến lược phân bổ khối trong bigalloc để ghi nguyên tử:

* Đối với các khu vực có phạm vi được ánh xạ đầy đủ, không cần thực hiện thêm công việc nào
 * Đối với việc ghi thêm, một phạm vi ánh xạ mới sẽ được phân bổ
 * Đối với các vùng hoàn toàn là lỗ hổng, phạm vi không ghi được sẽ được tạo
 * Đối với phạm vi không được ghi lớn, phạm vi được chia thành hai phần không được ghi
   phạm vi kích thước được yêu cầu phù hợp
 * Đối với các vùng ánh xạ hỗn hợp (tổ hợp các lỗ, phạm vi không được ghi hoặc
   phạm vi được ánh xạ), ext4_map_blocks() được gọi trong một vòng lặp với
   Cờ EXT4_GET_BLOCKS_ZERO để chuyển đổi vùng thành một vùng liền kề
   phạm vi được ánh xạ bằng cách viết các số 0 vào đó và chuyển đổi bất kỳ phạm vi chưa được ghi nào thành
   được viết nếu tìm thấy trong phạm vi.

Lưu ý: Viết trên một phạm vi cơ bản liền kề duy nhất, cho dù được lập bản đồ hay
bất thành văn, vốn không phải là vấn đề. Tuy nhiên, việc ghi vào bản đồ hỗn hợp
vùng (tức là vùng chứa sự kết hợp của phạm vi được ánh xạ và không được ghi)
phải tránh khi thực hiện ghi nguyên tử.

Lý do là, ghi nguyên tử khi được phát hành qua pwritev2() với RWF_ATOMIC
cờ, yêu cầu tất cả dữ liệu được ghi hoặc không có dữ liệu nào cả. Trong trường hợp
sự cố hệ thống hoặc mất điện bất ngờ trong quá trình ghi, thiết bị bị ảnh hưởng
vùng (khi đọc sau) phải phản ánh toàn bộ dữ liệu cũ hoặc
hoàn thành dữ liệu mới, nhưng không bao giờ kết hợp cả hai.

Để thực thi bảo đảm này, chúng tôi đảm bảo rằng mục tiêu ghi được hỗ trợ bởi
một phạm vi duy nhất, liền kề trước khi bất kỳ dữ liệu nào được ghi. Điều này rất quan trọng bởi vì
ext4 trì hoãn việc chuyển đổi phạm vi chưa được ghi thành phạm vi được ghi cho đến khi I/O
đường dẫn hoàn thành (thường ở ->end_io()). Nếu việc ghi được phép tiếp tục
một vùng ánh xạ hỗn hợp (với phạm vi được ánh xạ và chưa được ghi) và xảy ra lỗi
giữa quá trình ghi, hệ thống có thể quan sát các vùng được cập nhật một phần sau khi khởi động lại, tức là.
dữ liệu mới trên các khu vực được ánh xạ và dữ liệu cũ (cũ) trên các phạm vi không được ghi lại
chưa bao giờ được đánh dấu bằng văn bản. Điều này vi phạm tính nguyên tử và/hoặc viết bị rách
đảm bảo phòng ngừa.

Để ngăn chặn việc ghi bị rách như vậy, ext4 chủ động phân bổ một vùng liền kề duy nhất
phạm vi cho toàn bộ khu vực được yêu cầu trong ZZ0000ZZ thông qua
ZZ0001ZZ. EXT4 cũng buộc phải cam kết ghi nhật ký hiện tại
giao dịch trong trường hợp nếu việc phân bổ được thực hiện qua ánh xạ hỗn hợp. Điều này đảm bảo bất kỳ
các bản cập nhật siêu dữ liệu đang chờ xử lý (như chuyển đổi phạm vi chưa được ghi thành văn bản) trong phần này
phạm vi ở trạng thái nhất quán với các khối dữ liệu tệp, trước khi thực hiện
viết I/O thực tế. Nếu cam kết thất bại, toàn bộ I/O phải bị hủy bỏ để ngăn chặn
khỏi bất kỳ bài viết bị rách nào có thể xảy ra.
Chỉ sau bước này, thao tác ghi dữ liệu thực tế mới được thực hiện bởi iomap.

Xử lý mức độ phân chia trên các khối lá
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Có thể có một trường hợp đặc biệt mà chúng ta có
các phạm vi liền kề được lưu trữ trong các nút lá riêng biệt của cây phạm vi trên đĩa.
Điều này xảy ra do việc hợp nhất cây trên phạm vi đĩa chỉ xảy ra trong lá
các khối ngoại trừ trường hợp chúng ta có cây 2 cấp có thể được hợp nhất và
sụp đổ hoàn toàn vào inode.
Nếu bố cục như vậy tồn tại và trong trường hợp xấu nhất, các mục trong bộ nhớ đệm trạng thái phạm vi
được thu hồi do áp lực bộ nhớ, ZZ0000ZZ có thể không bao giờ quay trở lại
một phạm vi tiếp giáp duy nhất cho các phạm vi lá chia này.

Để giải quyết trường hợp cạnh này, một cờ chặn get mới
ZZ0000ZZ được thêm vào để nâng cao
Hành vi tra cứu ZZ0001ZZ.

Cờ chặn nhận mới này cho phép ZZ0000ZZ trước tiên kiểm tra xem có
một mục trong bộ đệm trạng thái phạm vi cho toàn bộ phạm vi.
Nếu không có, nó sẽ tra cứu cây phạm vi trên đĩa bằng cách sử dụng
ZZ0001ZZ.
Nếu phạm vi được định vị nằm ở cuối nút lá, nó sẽ thăm dò logic tiếp theo
khối (lblk) để phát hiện phạm vi tiếp giáp ở lá liền kề.

Hiện tại chỉ có một khối lá bổ sung được truy vấn để duy trì hiệu quả, như
ghi nguyên tử thường bị hạn chế ở kích thước nhỏ
(ví dụ: [kích thước khối, kích thước cụm]).


Xử lý giao dịch Nhật ký
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để hỗ trợ ghi nguyên tử nhiều fsblock, chúng tôi đảm bảo có đủ tín chỉ tạp chí
được bảo lưu trong thời gian:

1. Thời gian phân bổ khối trong ZZ0000ZZ. Đầu tiên chúng tôi truy vấn nếu có
    có thể là ánh xạ hỗn hợp cho phạm vi được yêu cầu cơ bản. Nếu có thì chúng tôi
    tín dụng dự trữ lên tới ZZ0001ZZ, giả sử mọi khối thay thế đều có thể
    một mức độ bất thành văn theo sau là một lỗ hổng.

2. Trong cuộc gọi ZZ0000ZZ, chúng tôi đảm bảo một giao dịch được bắt đầu cho
    thực hiện chuyển đổi không ghi thành văn bản. Vòng lặp chuyển đổi chủ yếu là
    chỉ cần thiết để xử lý một phạm vi phân chia trên các khối lá.

Làm cách nào để
~~~~~~

Tạo hệ thống tập tin với hỗ trợ ghi nguyên tử
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Trước tiên hãy kiểm tra đơn vị ghi nguyên tử được hỗ trợ bởi thiết bị khối.
Xem ZZ0000ZZ để biết thêm chi tiết.

Để ghi nguyên tử một fsblock với kích thước khối lớn hơn
(trên các hệ thống có kích thước khối < kích thước trang):

.. code-block:: bash

    # Create an ext4 filesystem with a 16KB block size
    # (requires page size >= 16KB)
    mkfs.ext4 -b 16384 /dev/device

Đối với việc ghi nguyên tử đa fsblock bằng bigalloc:

.. code-block:: bash

    # Create an ext4 filesystem with bigalloc and 64KB cluster size
    mkfs.ext4 -F -O bigalloc -b 4096 -C 65536 /dev/device

Trong đó ZZ0000ZZ chỉ định kích thước khối, ZZ0001ZZ chỉ định kích thước cụm theo byte,
và ZZ0002ZZ kích hoạt tính năng bigalloc.

Giao diện ứng dụng
^^^^^^^^^^^^^^^^^^^^^

Các ứng dụng có thể sử dụng lệnh gọi hệ thống ZZ0000ZZ với cờ ZZ0001ZZ
để thực hiện viết nguyên tử:

.. code-block:: c

    pwritev2(fd, iov, iovcnt, offset, RWF_ATOMIC);

Việc ghi phải được căn chỉnh theo kích thước khối của hệ thống tập tin và không vượt quá
kích thước đơn vị ghi nguyên tử tối đa của hệ thống tập tin.
Xem ZZ0000ZZ để biết thêm chi tiết.

Cuộc gọi hệ thống ZZ0000ZZ với cờ ZZ0001ZZ có thể cung cấp những điều sau
chi tiết:

* ZZ0000ZZ: Kích thước tối thiểu của yêu cầu ghi nguyên tử.
 * ZZ0001ZZ: Kích thước tối đa của yêu cầu ghi nguyên tử.
 * ZZ0002ZZ: Giới hạn trên cho các phân đoạn. Số lượng
   bộ nhớ đệm riêng biệt có thể được tập hợp thành thao tác ghi
   (ví dụ: tham số iovcnt cho IOV_ITER). Hiện tại, điều này luôn được đặt thành một.

Cờ STATX_ATTR_WRITE_ATOMIC trong ZZ0000ZZ được đặt nếu nguyên tử
viết được hỗ trợ.

.. _atomic_write_bdev_support:

Hỗ trợ phần cứng
~~~~~~~~~~~~~~~~

Thiết bị lưu trữ cơ bản phải hỗ trợ hoạt động ghi nguyên tử.
Các thiết bị NVMe và SCSI hiện đại thường cung cấp khả năng này.
Nhân Linux hiển thị thông tin này thông qua sysfs:

* ZZ0000ZZ - Kích thước ghi nguyên tử tối thiểu
* ZZ0001ZZ - Kích thước ghi nguyên tử tối đa

Giá trị khác 0 cho các thuộc tính này cho biết thiết bị hỗ trợ
viết nguyên tử.

Xem thêm
~~~~~~~~

* ZZ0000ZZ - Tài liệu về tính năng bigalloc
* ZZ0001ZZ - Tài liệu về phân bổ khối trong ext4
* Hỗ trợ ghi khối nguyên tử trong 6.13:
  ZZ0002ZZ