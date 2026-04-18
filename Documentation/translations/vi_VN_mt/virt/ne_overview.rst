.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/virt/ne_overview.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================
Vỏ Nitro
==============

Tổng quan
========

Nitro Enclaves (NE) là một tính năng mới của Đám mây điện toán đàn hồi Amazon (EC2)
cho phép khách hàng tạo ra các môi trường điện toán biệt lập trong EC2
trường hợp [1].

Ví dụ: một ứng dụng xử lý dữ liệu nhạy cảm và chạy trong VM,
có thể tách biệt khỏi các ứng dụng khác đang chạy trong cùng một VM. Cái này
Sau đó, ứng dụng sẽ chạy trong một VM riêng biệt hơn VM chính, cụ thể là một vùng bao bọc.
Nó chạy cùng với VM đã sinh ra nó. Thiết lập này phù hợp với độ trễ thấp
nhu cầu ứng dụng.

Các kiến trúc được hỗ trợ hiện tại cho trình điều khiển hạt nhân NE, có sẵn trong
nhân Linux ngược dòng, là x86 và ARM64.

Các tài nguyên được phân bổ cho vùng bao quanh, chẳng hạn như bộ nhớ và CPU, được
được khắc ra khỏi VM chính. Mỗi vùng được ánh xạ tới một tiến trình đang chạy trong
VM chính, giao tiếp với trình điều khiển hạt nhân NE thông qua giao diện ioctl.

Theo nghĩa này, có hai thành phần:

1. Một quy trình trừu tượng hóa kèm theo - một quy trình không gian người dùng đang chạy trong phần chính
Máy khách VM sử dụng giao diện ioctl được cung cấp của trình điều khiển NE để tạo ra một
kèm theo VM (đó là 2 bên dưới).

Có một thiết bị PCI được mô phỏng NE được tiếp xúc với VM chính. Trình điều khiển cho việc này
thiết bị PCI mới được bao gồm trong trình điều khiển NE.

Logic ioctl được ánh xạ tới các lệnh thiết bị PCI, ví dụ: ioctl NE_START_ENCLAVE
ánh xạ tới lệnh khởi động PCI kèm theo. Các lệnh của thiết bị PCI sau đó được
được chuyển thành các hành động được thực hiện ở phía bên ảo hóa; đó là Nitro
bộ ảo hóa chạy trên máy chủ nơi máy ảo chính đang chạy. Nitro
bộ ảo hóa dựa trên công nghệ cốt lõi KVM.

2. Bản thân phần vỏ - một VM chạy trên cùng một máy chủ với VM chính
sinh ra nó. Bộ nhớ và CPU được tách ra từ máy ảo chính và được dành riêng
cho VM kèm theo. Một vùng đất không có bộ lưu trữ liên tục kèm theo.

Các vùng bộ nhớ được tạo ra từ VM chính và được cấp cho một vùng cần phải
được căn chỉnh 2 MiB / 1 GiB vùng bộ nhớ liền kề về mặt vật lý (hoặc nhiều vùng
kích thước này, ví dụ: 8 MiB). Bộ nhớ có thể được phân bổ, ví dụ: bằng cách sử dụng Hugetlbfs từ
không gian người dùng [2] [3] [7]. Kích thước bộ nhớ cho một khu vực cần ít nhất là
64 MiB. Bộ nhớ kèm theo và CPU cần phải từ cùng một nút NUMA.

Một enclave chạy trên các lõi chuyên dụng. CPU 0 và những người anh em CPU của nó cần được giữ lại
có sẵn cho VM chính. Nhóm CPU phải được thiết lập cho mục đích NE bởi một
người dùng có khả năng quản trị viên. Xem phần danh sách cpu từ kernel
tài liệu [4] về giao diện của định dạng nhóm CPU.

Một khu vực giao tiếp với VM chính thông qua kênh liên lạc cục bộ,
sử dụng virtio-vsock [5]. VM chính có thiết bị mô phỏng virtio-pci vsock,
trong khi VM kèm theo có thiết bị mô phỏng virtio-mmio vsock. thiết bị vsock
sử dụng sự kiệnfd để báo hiệu. VM kèm theo nhìn thấy các giao diện thông thường - cục bộ
APIC và IOAPIC - để nhận các ngắt từ thiết bị virtio-vsock. Người tài giỏi
thiết bị được đặt trong bộ nhớ dưới 4 GiB thông thường.

Ứng dụng chạy trong enclave cần phải được đóng gói trong một enclave
hình ảnh cùng với hệ điều hành (ví dụ: kernel, ramdisk, init) sẽ chạy trong
bao vây VM. VM kèm theo có kernel riêng và tuân theo Linux tiêu chuẩn
giao thức khởi động [6] [8].

Kernel bzImage, dòng lệnh kernel, (các) đĩa RAM là một phần của
Định dạng hình ảnh kèm theo (EIF); cộng với tiêu đề EIF bao gồm siêu dữ liệu như phép thuật
số, phiên bản eif, kích thước hình ảnh và CRC.

Giá trị băm được tính cho toàn bộ hình ảnh kèm theo (EIF), hạt nhân và
(các) đĩa RAM. Ví dụ: nó được sử dụng để kiểm tra xem hình ảnh kèm theo có
được tải trong VM kèm theo là VM được dự định chạy.

Các phép đo tiền điện tử này được bao gồm trong tài liệu chứng thực đã ký
được tạo bởi Nitro Hypervisor và tiếp tục được sử dụng để chứng minh danh tính của
bao vây; KMS là một ví dụ về dịch vụ được NE tích hợp và kiểm tra
tài liệu chứng thực.

Hình ảnh kèm theo (EIF) được tải vào bộ nhớ kèm theo ở offset 8 MiB. các
Quá trình init trong vùng này kết nối với vsock CID của VM chính và một
cổng được xác định trước - 9000 - để gửi giá trị nhịp tim - 0xb7. Cơ chế này là
được sử dụng để kiểm tra VM chính mà vùng này đã khởi động. CID của
VM chính là 3.

Nếu VM kèm theo gặp sự cố hoặc thoát ra một cách duyên dáng, một sự kiện ngắt sẽ được nhận bởi
người lái xe NE. Sự kiện này được gửi tiếp đến quá trình bao bọc không gian người dùng
chạy trong máy ảo chính thông qua cơ chế thông báo thăm dò ý kiến. Sau đó không gian người dùng
quá trình kèm theo có thể thoát ra.

[1] ZZ0000ZZ
[2] ZZ0001ZZ
[3] ZZ0002ZZ
[4] ZZ0003ZZ
[5] ZZ0004ZZ
[6] ZZ0005ZZ
[7] ZZ0006ZZ
[8] ZZ0007ZZ