.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/nfsd-io-modes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============
NFSD IO MODES
==============

Tổng quan
========

NFSD trước đây luôn sử dụng IO đệm khi bảo trì READ và
Hoạt động WRITE. BUFFERED là chế độ IO mặc định của NFSD, nhưng có thể
để ghi đè mặc định đó để sử dụng chế độ IO DONTCACHE hoặc DIRECT.

Các giao diện gỡ lỗi NFSD thử nghiệm có sẵn để cho phép NFSD IO
chế độ được sử dụng để READ và WRITE được cấu hình độc lập. Xem cả hai:

- /sys/kernel/debug/nfsd/io_cache_read
- /sys/kernel/debug/nfsd/io_cache_write

Giá trị mặc định cho cả io_cache_read và io_cache_write đều phản ánh
Chế độ IO mặc định của NFSD (là NFSD_IO_BUFFERED=0).

Dựa trên cài đặt đã định cấu hình, IO của NFSD sẽ là:

- được lưu vào bộ đệm bằng bộ đệm trang (NFSD_IO_BUFFERED=0)
- được lưu vào bộ đệm nhưng bị xóa khỏi bộ đệm của trang khi hoàn thành (NFSD_IO_DONTCACHE=1)
- không được lưu vào bộ nhớ đệm stable_how=NFS_UNSTABLE (NFSD_IO_DIRECT=2)

Để đặt chế độ IO NFSD, hãy ghi giá trị được hỗ trợ (0 - 2) vào
giao diện gỡ lỗi của thao tác IO tương ứng, ví dụ::

echo 2 > /sys/kernel/debug/nfsd/io_cache_read
  echo 2 > /sys/kernel/debug/nfsd/io_cache_write

Để kiểm tra chế độ IO mà NFSD đang sử dụng cho READ hoặc WRITE, chỉ cần đọc phần
giao diện gỡ lỗi của thao tác IO tương ứng, ví dụ::

mèo /sys/kernel/debug/nfsd/io_cache_read
  mèo /sys/kernel/debug/nfsd/io_cache_write

Nếu bạn thử nghiệm các chế độ IO của NFSD trên kernel gần đây và có
kết quả thú vị, vui lòng báo cáo chúng tới linux-nfs@vger.kernel.org

NFSD DONTCACHE
==============

DONTCACHE cung cấp một phương pháp kết hợp để phục vụ IO nhằm mục đích cung cấp
lợi ích của việc sử dụng DIRECT IO mà không có bất kỳ sự căn chỉnh nghiêm ngặt nào
yêu cầu mà DIRECT IO áp đặt. Để đạt được IO đệm này được sử dụng
nhưng IO được gắn cờ là "xuống phía sau" (có nghĩa là các trang được liên kết
bị xóa khỏi bộ đệm trang) khi IO hoàn tất.

DONTCACHE nhằm mục đích tránh những gì đã được chứng minh là khá quan trọng
hạn chế của hệ thống con quản lý bộ nhớ của Linux nếu/khi số lượng lớn
dữ liệu được truy cập không thường xuyên (ví dụ: đọc một lần _hoặc_ được viết một lần nhưng không
đọc mãi về sau). Những trường hợp sử dụng như vậy đặc biệt có vấn đề
vì bộ đệm trang cuối cùng sẽ trở thành nút cổ chai trong việc phục vụ
yêu cầu IO mới.

Để biết thêm ngữ cảnh về DONTCACHE, vui lòng xem các tiêu đề cam kết Linux sau:

- Tổng quan: 9ad6344568cc3 ("mm/filemap: thay đổi filemap_create_folio()
  để lấy cấu trúc kiocb")
- đối với READ: 8026e49bff9b1 ("mm/filemap: thêm hỗ trợ đọc cho
  RWF_DONTCACHE")
- đối với WRITE: 974c5e6139db3 ("xfs: gắn cờ hỗ trợ FOP_DONTCACHE")

NFSD_IO_DONTCACHE sẽ quay trở lại NFSD_IO_BUFFERED nếu cơ sở
hệ thống tập tin không cho biết hỗ trợ bằng cách đặt FOP_DONTCACHE.

NFSD DIRECT
===========

DIRECT IO không sử dụng bộ đệm trang, do đó nó có thể
tránh các vấn đề về khả năng mở rộng của trang quản lý bộ nhớ Linux
mà không cần dùng đến việc sử dụng kết hợp bộ đệm trang mà DONTCACHE thực hiện.

Một số khối lượng công việc được hưởng lợi từ việc NFSD tránh được bộ đệm trang, đặc biệt là
những người có bộ công việc lớn hơn đáng kể so với bộ có sẵn
bộ nhớ hệ thống. Khối lượng công việc trong trường hợp xấu nhất bệnh lý mà NFSD DIRECT có
được chứng minh là hữu ích nhất là: Máy khách NFS phát hành IO tuần tự lớn cho một tệp
lớn hơn 2-3 lần so với bộ nhớ hệ thống khả dụng của máy chủ NFS.
Lý do cho sự cải tiến như vậy là NFSD DIRECT loại bỏ được rất nhiều công việc
rằng hệ thống con quản lý bộ nhớ sẽ được yêu cầu
thực hiện (ví dụ: phân bổ trang, viết lại lỗi, lấy lại trang). Khi nào
sử dụng NFSD DIRECT, kswapd và kcompactd không còn chỉ huy CPU nữa
thời gian cố gắng tìm các trang miễn phí phù hợp để tiến trình IO chuyển tiếp có thể
được thực hiện.

Chiến thắng hiệu suất liên quan đến việc sử dụng NFSD DIRECT trước đây
đã thảo luận trên linux-nfs, xem:
ZZ0000ZZ

Nhưng tóm lại:

- NFSD DIRECT có thể giảm đáng kể yêu cầu bộ nhớ
- NFSD DIRECT có thể giảm tải CPU bằng cách tránh công việc lấy lại trang tốn kém
- NFSD DIRECT có thể cung cấp hiệu suất IO xác định hơn

Như mọi khi, số dặm của bạn có thể thay đổi và vì vậy điều quan trọng là phải cẩn thận
hãy cân nhắc xem/khi nào việc sử dụng NFSD DIRECT có lợi hay không. Khi nào
đánh giá hiệu suất so sánh của khối lượng công việc của bạn, hãy nhớ đăng nhập
số liệu hiệu suất có liên quan trong quá trình thử nghiệm (ví dụ: mức sử dụng bộ nhớ, CPU
cách sử dụng, hiệu suất IO). Sử dụng độ hoàn hảo để thu thập dữ liệu về độ hoàn hảo có thể được sử dụng
để tạo ra một "biểu đồ ngọn lửa" cho công việc Linux phải thực hiện thay mặt bạn
kiểm tra là một cách thực sự có ý nghĩa để so sánh tình trạng tương đối của
hệ thống và cách chuyển đổi chế độ IO của NFSD sẽ thay đổi những gì được quan sát.

Nếu NFSD_IO_DIRECT được chỉ định bằng cách viết 2 (hoặc 3 và 4 cho WRITE) vào
Các giao diện gỡ lỗi của NFSD, lý tưởng nhất là IO sẽ được căn chỉnh tương ứng với
logic_block_size của thiết bị khối cơ bản. Ngoài ra bộ nhớ đệm
được sử dụng để lưu trữ tải trọng READ hoặc WRITE phải được căn chỉnh tương ứng với
dma_alignment của thiết bị khối cơ bản.

Nhưng NFSD DIRECT xử lý IO sai lệch theo O_DIRECT là tốt nhất
nó có thể:

READ bị sai lệch:
    Nếu NFSD_IO_DIRECT được sử dụng, hãy mở rộng bất kỳ READ nào bị lệch sang READ tiếp theo
    Khối căn chỉnh DIO (ở hai đầu của READ). READ mở rộng là
    được xác minh là có offset/len phù hợp (logic_block_size) và
    kiểm tra dma_alignment.

WRITE bị sai lệch:
    Nếu NFSD_IO_DIRECT được sử dụng, hãy chia bất kỳ WRITE nào bị lệch thành một phần bắt đầu,
    giữa và cuối khi cần thiết. Phân khúc lớn ở giữa được căn chỉnh theo DIO
    và phần đầu và/hoặc phần cuối bị sai lệch. IO đệm được sử dụng cho
    các phân đoạn được căn chỉnh sai và O_DIRECT được sử dụng cho các phân đoạn được căn chỉnh ở giữa DIO
    phân đoạn. IO đệm DONTCACHE _không_ được sử dụng cho việc căn chỉnh sai
    các phân đoạn vì sử dụng IO được đệm thông thường mang lại RMW đáng kể
    lợi ích về hiệu suất khi xử lý việc truyền phát các WRITE bị sai lệch.

Truy tìm:
    Sự kiện theo dõi nfsd_read_direct cho thấy NFSD mở rộng bất kỳ
    đã căn chỉnh sai READ thành khối được căn chỉnh DIO tiếp theo (ở hai đầu của
    READ gốc, nếu cần).

Sự kết hợp các sự kiện theo dõi này rất hữu ích cho READ::

echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_vector/enable
      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_direct/enable
      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_read_io_done/enable
      echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_read/enable

Sự kiện theo dõi nfsd_write_direct cho thấy cách NFSD phân chia một
    đã căn chỉnh sai WRITE thành đoạn giữa được căn chỉnh theo DIO.

Sự kết hợp các sự kiện theo dõi này rất hữu ích cho VIẾT::

echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_opened/enable
      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_direct/enable
      echo 1 > /sys/kernel/tracing/events/nfsd/nfsd_write_io_done/enable
      echo 1 > /sys/kernel/tracing/events/xfs/xfs_file_direct_write/enable