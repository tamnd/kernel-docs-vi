.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/swsusp-and-swap-files.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======================================================
Sử dụng tập tin trao đổi với phần mềm tạm dừng (swsusp)
=======================================================

(C) 2006 Rafael J. Wysocki <rjw@sisk.pl>

Nhân Linux xử lý các tập tin hoán đổi gần giống như cách nó xử lý trao đổi
phân vùng và chỉ có hai điểm khác biệt giữa hai loại trao đổi này
khu vực:
(1) các tệp hoán đổi không cần phải liền kề nhau,
(2) tiêu đề của tệp hoán đổi không nằm trong khối đầu tiên của phân vùng
giữ nó.  Từ quan điểm của swsusp (1) không phải là vấn đề, bởi vì nó
đã được xử lý bằng mã xử lý trao đổi, nhưng (2) phải được tính đến
xem xét.

Về nguyên tắc, vị trí tiêu đề của tệp hoán đổi có thể được xác định bằng
sự trợ giúp của trình điều khiển hệ thống tập tin thích hợp.  Tuy nhiên, thật không may, nó đòi hỏi
hệ thống tập tin đang giữ tập tin hoán đổi sẽ được gắn kết và nếu hệ thống tập tin này được
được ghi nhật ký, nó không thể được gắn kết trong quá trình tiếp tục từ đĩa.  Vì lý do này để
xác định tệp hoán đổi swsusp sử dụng tên của phân vùng chứa tệp
và phần bù từ đầu phân vùng nơi chứa tệp hoán đổi
tiêu đề được đặt.  Để thuận tiện, phần bù này được biểu thị bằng <PAGE_SIZE>
đơn vị.

Để sử dụng tệp hoán đổi với swsusp, bạn cần:

1) Tạo tệp hoán đổi và kích hoạt nó, ví dụ:::

# dd if=/dev/zero of=<swap_file_path> bs=1024 count=<swap_file_size_in_k>
    # mkswap <swap_file_path>
    # swapon <swap_file_path>

2) Sử dụng một ứng dụng sẽ lập bản đồ tệp hoán đổi với sự trợ giúp của
FIBMAP ioctl và xác định vị trí của tiêu đề trao đổi của tệp, làm
offset, tính bằng đơn vị <PAGE_SIZE>, tính từ đầu phân vùng
giữ tập tin trao đổi.

3) Thêm các tham số sau vào dòng lệnh kernel ::

sơ yếu lý lịch=<swap_file_partition> sơ yếu lý lịch_offset=<swap_file_offset>

trong đó <swap_file_partition> là phân vùng chứa tệp hoán đổi
và <swap_file_offset> là phần bù của tiêu đề trao đổi được xác định bởi
ứng dụng ở mục 2) (tất nhiên, bước này có thể được thực hiện tự động
bởi cùng một ứng dụng xác định độ lệch tiêu đề của tệp hoán đổi bằng cách sử dụng
FIBMAP ioctl)

HOẶC

Sử dụng ứng dụng tạm dừng vùng người dùng để thiết lập phân vùng và bù đắp
với sự trợ giúp của SNAPSHOT_SET_SWAP_AREA ioctl được mô tả trong
Documentation/power/userland-swsusp.rst (đây là phương pháp duy nhất để tạm dừng
sang một tệp hoán đổi cho phép bắt đầu sơ yếu lý lịch từ initrd hoặc initramfs
hình ảnh).

Bây giờ, swsusp sẽ sử dụng tệp hoán đổi giống như cách nó sử dụng tệp hoán đổi
phân vùng.  Đặc biệt, tệp hoán đổi phải đang hoạt động (tức là có mặt trong
/proc/swaps) để có thể sử dụng nó để tạm dừng.

Lưu ý rằng nếu tệp hoán đổi được sử dụng để tạm dừng bị xóa và được tạo lại,
vị trí tiêu đề của nó không cần phải giống như trước.  Như vậy mỗi lần
điều này xảy ra với giá trị của tham số dòng lệnh kernel "resume_offset="
phải được cập nhật.
