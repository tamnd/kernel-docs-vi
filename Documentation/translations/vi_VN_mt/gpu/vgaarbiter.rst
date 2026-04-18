.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/vgaarbiter.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============
Trọng tài VGA
=============

Các thiết bị đồ họa được truy cập thông qua các phạm vi trong I/O hoặc không gian bộ nhớ. Trong khi hầu hết
các thiết bị hiện đại cho phép di chuyển các phạm vi như vậy, một số thiết bị VGA "Di sản"
được triển khai trên PCI thường sẽ có cùng địa chỉ "được giải mã cứng" như
họ đã làm trên ISA. Để biết thêm chi tiết, hãy xem "PCI Bus Binding to IEEE Std 1275-1994
Tiêu chuẩn để khởi động (Cấu hình khởi tạo) Bản sửa đổi chương trình cơ sở 2.1"
Phần 7, Thiết bị kế thừa.

Mô-đun Kiểm soát truy cập tài nguyên (RAC) bên trong máy chủ X [0] đã tồn tại từ
nhiệm vụ trọng tài VGA kế thừa (bên cạnh các nhiệm vụ quản lý bus khác) khi có thêm
hơn một thiết bị cũ cùng tồn tại trên cùng một máy. Nhưng vấn đề xảy ra
khi các thiết bị này đang cố gắng được truy cập bởi các máy khách không gian người dùng khác nhau
(ví dụ: hai máy chủ song song). Việc gán địa chỉ của họ xung đột. Hơn nữa,
lý tưởng nhất là một ứng dụng không gian người dùng, vai trò của máy chủ X không phải là
Kiểm soát tài nguyên xe buýt Do đó, sơ đồ trọng tài bên ngoài máy chủ X
là cần thiết để kiểm soát việc chia sẻ các tài nguyên này. Tài liệu này giới thiệu
hoạt động của trọng tài VGA được triển khai cho nhân Linux.

hạt nhân vgaarb/không gian người dùng ABI
---------------------------

Vgaarb là một mô-đun của hạt nhân Linux. Khi nó được tải lần đầu tiên, nó
quét tất cả các thiết bị PCI và thêm các thiết bị VGA vào bên trong trọng tài. các
sau đó trọng tài sẽ bật/tắt tính năng giải mã trên các thiết bị khác nhau của VGA
hướng dẫn kế thừa. Các thiết bị không muốn/cần sử dụng trọng tài có thể
nói rõ ràng bằng cách gọi vga_set_legacy_decoding().

Hạt nhân xuất giao diện thiết bị char (/dev/vga_arbiter) cho máy khách,
có ngữ nghĩa sau:

mở
        Mở một phiên bản người dùng của trọng tài. Theo mặc định, nó được gắn vào
        thiết bị VGA mặc định của hệ thống.

đóng
        Đóng một phiên bản người dùng. Mở khóa do người dùng thực hiện

đọc
        Trả về một chuỗi cho biết trạng thái của mục tiêu như:

"<card_ID>,decodes=<io_state>,owns=<io_state>,locks=<io_state> (ic,mc)"

Chuỗi trạng thái IO có dạng {io,mem,io+mem,none}, mc và
        ic lần lượt là số lượng khóa mem và io (để gỡ lỗi/
        chỉ chẩn đoán). "giải mã" cho biết thẻ hiện tại là gì
        giải mã, "sở hữu" cho biết những gì hiện được kích hoạt trên đó và
        "khóa" cho biết thẻ này đã khóa cái gì. Nếu thẻ là
        khi rút phích cắm, chúng tôi nhận được "không hợp lệ" đối với card_ID và -ENODEV
        lỗi được trả về cho bất kỳ lệnh nào cho đến khi thẻ mới được nhắm mục tiêu.


viết
        Viết lệnh cho trọng tài. Danh sách các lệnh:

mục tiêu <card_ID>
                chuyển mục tiêu sang thẻ <card_ID> (xem bên dưới)
        khóa <io_state>
                lấy được các khóa trên mục tiêu ("không có" là io_state không hợp lệ)
        khóa thử <io_state>
                không chặn thu được các khóa trên mục tiêu (trả về EBUSY nếu
                không thành công)
        mở khóa <io_state>
                nhả khóa vào mục tiêu
        mở khóa tất cả
                giải phóng tất cả các khóa trên mục tiêu do người dùng này nắm giữ (không được triển khai
                chưa)
        giải mã <io_state>
                đặt thuộc tính giải mã kế thừa cho thẻ

thăm dò ý kiến
                sự kiện nếu có gì đó thay đổi trên bất kỳ thẻ nào (không chỉ mục tiêu)

card_ID có dạng "PCI:domain:bus:dev.fn". Nó có thể được đặt thành "mặc định"
        để quay lại thẻ mặc định của hệ thống (TODO: chưa được triển khai). Hiện tại,
        chỉ PCI được hỗ trợ làm tiền tố, nhưng vùng người dùng API có thể hỗ trợ bus khác
        loại trong tương lai, ngay cả khi việc triển khai kernel hiện tại không thực hiện được.

Lưu ý về ổ khóa:

Trình điều khiển theo dõi xem người dùng nào khóa thẻ nào. Nó
hỗ trợ xếp chồng, giống như kernel. Điều này làm phức tạp việc thực hiện
một chút, nhưng làm cho trọng tài khoan dung hơn với các vấn đề về không gian của người dùng và có thể
để dọn dẹp đúng cách trong mọi trường hợp khi một quá trình chết.
Hiện tại, tối đa 16 thẻ có thể được cấp khóa đồng thời từ
không gian người dùng cho một người dùng nhất định (phiên bản mô tả tệp) của trọng tài.

Trong trường hợp thiết bị được cắm nóng{un,}thì sẽ có một cái móc - pci_notify() - để
thông báo thêm/xóa trong hệ thống và tự động thêm/xóa
ở trọng tài.

Ngoài ra còn có API trong kernel của trọng tài trong trường hợp DRM, vgacon hoặc loại khác
người lái xe muốn sử dụng nó.

Giao diện trong kernel
-------------------

.. kernel-doc:: include/linux/vgaarb.h
   :internal:

.. kernel-doc:: drivers/pci/vgaarb.c
   :export:

libpciaaccess
------------

Để sử dụng thiết bị vga abiter char, API đã được triển khai bên trong
thư viện libpciaaccess. Một trường đã được thêm vào struct pci_device (mỗi thiết bị
trên hệ thống)::

/* loại tài nguyên được thiết bị giải mã */
    int vgaarb_rsrc;

Ngoài ra, trong pci_system đã được thêm ::

int vgaarb_fd;
    int vga_count;
    cấu trúc pci_device *vga_target;
    cấu trúc pci_device *vga_default_dev;

vga_count được sử dụng để theo dõi số lượng thẻ đang được phân xử, vì vậy đối với
Chẳng hạn, nếu chỉ có một lá bài thì nó hoàn toàn có thể thoát khỏi sự phân xử.

Các chức năng dưới đây thu thập tài nguyên VGA cho thẻ đã cho và đánh dấu các tài nguyên đó
tài nguyên như bị khóa. Nếu tài nguyên được yêu cầu là "bình thường" (chứ không phải cũ)
tài nguyên, trước tiên trọng tài sẽ kiểm tra xem thẻ có đang hoạt động hay không
giải mã cho loại tài nguyên đó. Nếu có, khóa sẽ được "chuyển đổi" thành
khóa tài nguyên kế thừa. Đầu tiên trọng tài sẽ tìm kiếm tất cả các thẻ VGA
có thể xung đột và vô hiệu hóa quyền truy cập IO và/hoặc Bộ nhớ của họ, bao gồm VGA
chuyển tiếp trên các cầu nối P2P nếu cần thiết, để các tài nguyên được yêu cầu có thể
được sử dụng. Sau đó, thẻ được đánh dấu là khóa các tài nguyên này và IO và/hoặc
Truy cập bộ nhớ được kích hoạt trên thẻ (bao gồm chuyển tiếp VGA trên thẻ gốc
Cầu P2P nếu có). Trong trường hợp vga_arb_lock(), hàm sẽ chặn
nếu một số thẻ xung đột đã khóa một trong các tài nguyên được yêu cầu (hoặc
bất kỳ tài nguyên nào trên một đoạn xe buýt khác, vì các cầu nối P2P không phân biệt
Bộ nhớ VGA và IO afaik). Nếu thẻ đã sở hữu tài nguyên, chức năng
thành công.  vga_arb_trylock() sẽ trả về (-EBUSY) thay vì chặn. Lồng nhau
các cuộc gọi được hỗ trợ (bộ đếm theo tài nguyên được duy trì).

Đặt thiết bị mục tiêu của khách hàng này. ::

int pci_device_vgaarb_set_target (struct pci_device *dev);

Ví dụ: trong x86 nếu hai thiết bị trên cùng một bus muốn khóa khác nhau
tài nguyên, cả hai sẽ thành công (khóa). Nếu các thiết bị ở các bus khác nhau và
cố gắng khóa các tài nguyên khác nhau, chỉ người đầu tiên thử thành công. ::

int pci_device_vgaarb_lock (void);
    int pci_device_vgaarb_trylock (void);

Mở khóa tài nguyên của thiết bị. ::

int pci_device_vgaarb_unlock (void);

Cho trọng tài biết liệu thẻ có giải mã được IO VGA cũ, VGA cũ hay không
Trí nhớ, cả hai, hoặc không có gì. Tất cả các thẻ mặc định cho cả hai, trình điều khiển thẻ (fbdev cho
ví dụ) nên thông báo cho trọng tài nếu nó đã tắt tính năng giải mã kế thừa, vì vậy
thẻ có thể bị loại khỏi quá trình phân xử (và có thể an toàn khi lấy
gián đoạn bất cứ lúc nào. ::

int pci_device_vgaarb_decodes (int new_vgaarb_rsrc);

Kết nối với thiết bị trọng tài, phân bổ struct ::

int pci_device_vgaarb_init (void);

Đóng kết nối ::

void pci_device_vgaarb_fini (void);

xf86VGAArbiter (triển khai máy chủ X)
----------------------------------------

Về cơ bản, máy chủ X bao bọc tất cả các chức năng liên quan đến các thanh ghi VGA.

Tài liệu tham khảo
----------

Benjamin Herrenschmidt (IBM?) bắt đầu công việc này khi ông thảo luận về thiết kế như vậy
với cộng đồng Xorg năm 2005 [1, 2]. Cuối năm 2007, Paulo Zanoni và
Tiago Vignatti (cả hai đều thuộc C3SL/Đại học Liên bang Paraná) đã tiến hành công việc của mình
tăng cường mã hạt nhân để thích ứng như một mô-đun hạt nhân và cũng đã thực hiện
triển khai phía không gian người dùng [3]. Bây giờ (2009) Tiago Vignatti và Dave
Airlie cuối cùng đã hoàn thành tác phẩm này và xếp hàng đến cây PCI của Jesse Barnes.

0) ZZ0000ZZ
1) ZZ0001ZZ
2) ZZ0002ZZ
3) ZZ0003ZZ
