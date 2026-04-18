.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/asymmetric-32bit.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
SoC 32-bit không đối xứng
=========================

Tác giả: Will Deacon <will@kernel.org>

Tài liệu này mô tả tác động của SoC 32-bit bất đối xứng trên
thực thi các ứng dụng 32-bit (ZZ0000ZZ).

Ngày: 2021-05-17

Giới thiệu
============

Một số SoC Armv9 gặp phải lỗi sai lớn.LITTLE trong đó chỉ có một tập hợp con
trong số các CPU có khả năng thực thi các ứng dụng người dùng 32 bit. Trên đó
một hệ thống, Linux theo mặc định coi sự bất đối xứng là "không khớp" và
vô hiệu hóa hỗ trợ cho cả tính cách ZZ0000ZZ và
ZZ0001ZZ của các tệp nhị phân ELF 32 bit, sau đó quay trở lại
ZZ0002ZZ. Nếu sự không phù hợp được phát hiện trong quá trình trực tuyến muộn của một
CPU chỉ 64-bit, sau đó hoạt động trực tuyến không thành công và CPU mới được
không có sẵn để lập lịch trình.

Điều đáng ngạc nhiên là những SoC này được sản xuất với mục đích
chạy các tệp nhị phân 32 bit cũ. Không có gì đáng ngạc nhiên, điều đó không hiệu quả lắm
tốt với hành vi mặc định của Linux.

Có vẻ như không thể tránh khỏi việc các SoC trong tương lai sẽ ngừng hỗ trợ 32-bit
hoàn toàn, vì vậy nếu bạn bị mắc kẹt trong tình thế khó khăn là cần phải
chạy mã 32 bit trên một trong những nền tảng chuyển tiếp này thì bạn sẽ
hãy khôn ngoan khi xem xét các lựa chọn thay thế như biên dịch lại, mô phỏng hoặc
nghỉ hưu. Nếu cả hai lựa chọn đó đều không thực tế thì hãy đọc tiếp.

Kích hoạt hỗ trợ kernel
=======================

Vì hỗ trợ kernel không hoàn toàn minh bạch đối với không gian người dùng,
cho phép các tác vụ 32 bit chạy trên hệ thống 32 bit không đối xứng yêu cầu
"chọn tham gia" rõ ràng và có thể được kích hoạt bằng cách chuyển
Tham số ZZ0000ZZ trên dòng lệnh kernel.

Trong phần còn lại của tài liệu này, chúng tôi sẽ đề cập đến một *bất đối xứng
system* có nghĩa là SoC 32-bit không đối xứng chạy Linux với kernel này
tùy chọn dòng lệnh được kích hoạt.

Tác động đến không gian người dùng
==================================

Các tác vụ 32 bit chạy trên hệ thống bất đối xứng hoạt động gần như giống nhau
giống như trên một hệ thống đồng nhất, với một số khác biệt chính liên quan đến
Mối quan hệ CPU.

sysfs
-----

Tập hợp con CPU có khả năng chạy các tác vụ 32 bit được mô tả trong
ZZ0000ZZ và được ghi lại thêm trong
Tài liệu/ABI/testing/sysfs-devices-system-cpu.

CPU ZZ0000ZZ được quảng cáo bởi tệp này khi chúng được phát hiện và do đó
việc kết nối muộn của CPU có khả năng 32 bit có thể dẫn đến nội dung tệp
được sửa đổi bởi kernel khi chạy. Sau khi được quảng cáo, CPU không bao giờ
bị xóa khỏi tập tin.

ZZ0000ZZ
-------------

Trên một hệ thống đồng nhất, mối quan hệ CPU của một nhiệm vụ được duy trì trên toàn bộ hệ thống.
ZZ0000ZZ. Điều này không phải lúc nào cũng có thể thực hiện được trên một hệ thống bất đối xứng,
cụ thể là khi chương trình mới đang được thực thi là 32-bit nhưng
mặt nạ ái lực chỉ chứa CPU 64-bit. Trong tình huống này, hạt nhân
xác định mặt nạ ái lực mới như sau:

1. Nếu tập hợp con có khả năng 32 bit của mặt nạ ái lực không trống,
     thì mối quan hệ bị giới hạn ở tập hợp con đó và mối quan hệ cũ
     mặt nạ được lưu. Mặt nạ đã lưu này được kế thừa trên ZZ0000ZZ và
     được bảo tồn trên ZZ0001ZZ của các chương trình 32 bit.

ZZ0002ZZ Bước này không áp dụng cho các tác vụ ZZ0000ZZ.
     Xem ZZ0001ZZ.

2. Nếu không, hệ thống phân cấp cpuset của tác vụ sẽ được thực hiện cho đến khi
     tổ tiên được tìm thấy chứa ít nhất một CPU có khả năng 32 bit. các
     mối quan hệ của nhiệm vụ sau đó được thay đổi để phù hợp với khả năng 32-bit
     tập hợp con của cpuset được xác định bằng bước đi.

3. Khi thất bại (tức là hết bộ nhớ), mối quan hệ được thay đổi thành tập hợp
     của tất cả các CPU có khả năng 32-bit mà hạt nhân nhận biết được.

ZZ0000ZZ tiếp theo của chương trình 64 bit theo tác vụ 32 bit sẽ
vô hiệu hóa mặt nạ ái lực được lưu trong (1) và cố gắng khôi phục CPU
mối quan hệ của nhiệm vụ bằng cách sử dụng mặt nạ đã lưu nếu nó hợp lệ trước đó.
Việc khôi phục này có thể không thành công do những thay đổi can thiệp vào thời hạn
chính sách hoặc phân cấp cpuset, trong trường hợp đó ZZ0001ZZ tiếp tục
với ái lực không đổi.

Các lệnh gọi tới ZZ0000ZZ cho tác vụ 32 bit sẽ chỉ được xem xét
CPU có khả năng 32 bit của mặt nạ ái lực được yêu cầu. Về thành công,
mối quan hệ với nhiệm vụ được cập nhật và mọi mặt nạ đã lưu từ nhiệm vụ trước đó
ZZ0001ZZ bị vô hiệu.

ZZ0000ZZ
------------------

Chấp nhận rõ ràng nhiệm vụ có thời hạn 32 bit đối với miền gốc mặc định
(ví dụ: bằng cách gọi ZZ0000ZZ) bị từ chối trên một giao thức không đối xứng
Hệ thống 32 bit trừ khi kiểm soát nhập học bị vô hiệu hóa bằng cách ghi -1 vào
ZZ0001ZZ.

ZZ0000ZZ của chương trình 32 bit từ tác vụ thời hạn 64 bit sẽ
trả về ZZ0001ZZ nếu miền gốc của tác vụ chứa bất kỳ
CPU chỉ 64 bit và kiểm soát nhập học được bật. Ngoại tuyến đồng thời
CPU có khả năng 32-bit vẫn có thể cần đến quy trình được mô tả trong
ZZ0002ZZ, trong trường hợp đó bước (1) bị bỏ qua và có cảnh báo
phát ra trên bàn điều khiển.

ZZ0001ZZ Nên đặt một bộ CPU có khả năng 32-bit
vào một miền gốc riêng biệt nếu ZZ0000ZZ được sử dụng với
Nhiệm vụ 32 bit trên hệ thống bất đối xứng. Không làm như vậy có thể
dẫn đến trễ thời hạn.

CPU
-------

Mối quan hệ của tác vụ 32 bit trên hệ thống bất đối xứng có thể bao gồm CPU
không được cho phép rõ ràng bởi bộ xử lý mà nó được gắn vào.
Điều này có thể xảy ra do hai tình huống sau:

- Tác vụ 64 bit được gắn vào bộ xử lý chỉ cho phép CPU 64 bit
    thực hiện chương trình 32-bit.

- Tất cả các CPU có khả năng 32-bit được cho phép bởi một bộ CPU có chứa một
    Tác vụ 32 bit được ngoại tuyến.

Trong cả hai trường hợp này, ái lực mới được tính theo bước
(2) của quy trình được mô tả trong ZZ0000ZZ và hệ thống phân cấp cpuset là
không thay đổi bất kể phiên bản cgroup.

phích cắm nóng CPU
------------------

Trên hệ thống bất đối xứng, CPU có khả năng 32 bit được phát hiện đầu tiên là
không bị ngoại tuyến bởi không gian người dùng và mọi nỗ lực như vậy sẽ
trả lại ZZ0000ZZ. Lưu ý rằng việc đình chỉ vẫn được cho phép ngay cả khi
CPU chính (tức là CPU 0) chỉ có 64 bit.

KVM
---

Mặc dù KVM sẽ không quảng cáo hỗ trợ EL0 32-bit cho bất kỳ vCPU nào trên
hệ thống bất đối xứng, một vị khách bị hỏng tại EL1 vẫn có thể cố gắng thực thi
Mã 32 bit tại EL0. Trong trường hợp này, lối thoát khỏi luồng vCPU ở chế độ 32-bit
chế độ sẽ quay trở lại không gian người dùng máy chủ với ZZ0000ZZ của
ZZ0001ZZ và sẽ không thể chạy được cho đến khi thành công
được khởi tạo lại bằng thao tác ZZ0002ZZ tiếp theo.

SCHEDULER DOMAIN ISOLATION
--------------------------

Để tránh làm xáo trộn miền xác định khởi động được cách ly CPU (được chỉ định bằng cách sử dụng
ZZ0000ZZ) khi tác vụ 32-bit được di chuyển cưỡng bức, các CPU này
được coi là chỉ 64 bit khi hỗ trợ cho hệ thống 32 bit không đối xứng
được kích hoạt.

Tuy nhiên, trái ngược với sự cô lập miền do khởi động xác định, miền do thời gian chạy xác định
cách ly bằng cách sử dụng phân vùng cách ly cpuset không được khuyên dùng trên tính không đối xứng
Hệ thống 32 bit và sẽ dẫn đến hành vi không xác định.
