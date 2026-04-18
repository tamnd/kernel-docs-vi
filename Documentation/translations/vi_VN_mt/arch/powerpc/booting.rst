.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/booting.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Khởi động DeviceTree
------------------

Trong quá trình phát triển hạt nhân Linux/ppc64 và cụ thể hơn là
bổ sung các loại nền tảng mới bên ngoài cặp IBM pSeries/iSeries cũ, nó
đã quyết định thực thi một số quy tắc nghiêm ngặt liên quan đến việc nhập kernel và
bootloader <-> giao diện kernel, để tránh sự thoái hóa đã có
trở thành điểm vào kernel ppc32 và cách thêm nền tảng mới
tới hạt nhân. Nền tảng iSeries kế thừa đã phá vỡ các quy tắc đó như đã có từ trước
kế hoạch này, nhưng không có sự hỗ trợ bảng mới nào được chấp nhận trong cây chính
không làm theo chúng đúng cách.  Ngoài ra, kể từ sự ra đời của Arch/powerpc
kiến trúc hợp nhất cho ppc32 và ppc64, nền tảng 32-bit mới và 32-bit
các nền tảng di chuyển vào Arch/powerpc sẽ được yêu cầu sử dụng các quy tắc này như
tốt.

Yêu cầu chính sẽ được xác định chi tiết hơn dưới đây là sự hiện diện
của cây thiết bị có định dạng được xác định sau thông số Open Firmware.
Tuy nhiên, để giúp các nhà cung cấp bo mạch nhúng dễ dàng hơn, kernel
không yêu cầu cây thiết bị đại diện cho mọi thiết bị trong hệ thống và chỉ
yêu cầu phải có một số nút và thuộc tính. Ví dụ, kernel làm
không yêu cầu bạn tạo nút cho mọi thiết bị PCI trong hệ thống. Đó là một
yêu cầu phải có một nút cho các cầu nối máy chủ PCI để cung cấp khả năng ngắt
thông tin định tuyến và phạm vi bộ nhớ/IO, cùng nhiều thông tin khác. Nó cũng được khuyến khích
để xác định các nút cho các thiết bị chip và các bus khác không phù hợp cụ thể
trong một đặc tả OF hiện có. Điều này tạo ra sự linh hoạt tuyệt vời trong cách thức
kernel sau đó có thể thăm dò những thứ đó và khớp trình điều khiển với thiết bị mà không cần phải cứng
mã tất cả các loại bảng. Nó cũng giúp các nhà cung cấp bo mạch linh hoạt hơn trong việc thực hiện
nâng cấp phần cứng nhỏ mà không ảnh hưởng đáng kể đến mã hạt nhân hoặc
làm lộn xộn nó với các trường hợp đặc biệt.


Điểm vào
~~~~~~~~~~~

Có một điểm vào kernel duy nhất khi bắt đầu
của hình ảnh hạt nhân. Điểm vào đó hỗ trợ hai cuộc gọi
quy ước:

a) Khởi động từ phần sụn mở. Nếu chương trình cơ sở của bạn tương thích
        với Open Firmware (IEEE 1275) hoặc cung cấp OF tương thích
        giao diện máy khách API (hỗ trợ gọi lại "thông dịch" của
        các từ khác không bắt buộc), bạn có thể nhập kernel bằng:

r5 : Con trỏ gọi lại OF như được xác định bởi IEEE 1275
              các ràng buộc với powerpc. Chỉ giao diện máy khách 32-bit
              hiện đang được hỗ trợ

r3, r4 : địa chỉ và độ dài của initrd nếu có hoặc 0

MMU đang bật hoặc tắt; hạt nhân sẽ chạy
              tấm bạt lò xo nằm trong Arch/powerpc/kernel/prom_init.c tới
              trích xuất cây thiết bị và các thông tin khác từ open
              chương trình cơ sở và xây dựng cây thiết bị phẳng như được mô tả
              ở b). Prom_init() sau đó sẽ nhập lại kernel bằng cách sử dụng
              phương pháp thứ hai. Mã tấm bạt lò xo này chạy trong
              bối cảnh của phần sụn, được cho là xử lý tất cả
              ngoại lệ trong thời gian đó.

b) Vào trực tiếp bằng khối cây thiết bị được làm phẳng. Mục nhập này
        điểm được gọi bởi a) sau tấm bạt lò xo OF và cũng có thể
        được gọi trực tiếp bởi bộ nạp khởi động không hỗ trợ Open
        Giao diện phần mềm máy khách. Nó cũng được sử dụng bởi "kexec" để
        thực hiện khởi động "nóng" hạt nhân mới từ hạt nhân trước đó
        đang chạy một cái. Phương pháp này là những gì tôi sẽ mô tả thêm
        chi tiết trong tài liệu này, như phương pháp a) chỉ đơn giản là tiêu chuẩn Mở
        Phần sụn, và do đó nên được triển khai theo
        các tài liệu tiêu chuẩn khác nhau xác định nó và sự ràng buộc của nó với
        Nền tảng PowerPC. Định nghĩa điểm vào sau đó trở thành:

r3 : con trỏ vật lý tới khối cây thiết bị
                (được định nghĩa ở chương II) trong RAM

r4 : con trỏ vật lý tới chính kernel. Đây là
                được sử dụng bởi mã lắp ráp để vô hiệu hóa MMU đúng cách
                trong trường hợp bạn đang nhập kernel có bật MMU
                và ánh xạ không phải 1: 1.

r5 : NULL (để phân biệt với phương pháp a)

Lưu ý về mục nhập SMP: Phần sụn của bạn đặt phần mềm khác của bạn
CPU trong một số vòng lặp ngủ hoặc vòng quay trong ROM nơi bạn có thể nhận được
chúng ra thông qua thiết lập lại mềm hoặc một số phương tiện khác, trong trường hợp đó
bạn không cần quan tâm, nếu không bạn sẽ phải nhập kernel
với tất cả các CPU. Cách để làm điều đó với phương pháp b) sẽ là
được mô tả trong bản sửa đổi sau này của tài liệu này.

Hỗ trợ bảng (nền tảng) không phải là tùy chọn cấu hình độc quyền. Một
bộ hỗ trợ bảng tùy ý có thể được xây dựng trong một hạt nhân
hình ảnh. Hạt nhân sẽ "biết" tập hợp chức năng nào sẽ được sử dụng cho một
nền tảng nhất định dựa trên nội dung của cây thiết bị. Vì vậy, bạn
nên:

a) thêm hỗ trợ nền tảng của bạn dưới dạng tùy chọn _boolean_ trong
        Arch/powerpc/Kconfig, theo ví dụ của PPC_PSERIES
        và PPC_PMAC. Cái sau có lẽ là tốt
        ví dụ về một bảng hỗ trợ để bắt đầu.

b) tạo tệp nền tảng chính của bạn dưới dạng
        "Arch/powerpc/platforms/myplatform/myboard_setup.c" và thêm nó
        vào Makefile với điều kiện là ZZ0000ZZ của bạn
        tùy chọn. Tệp này sẽ xác định cấu trúc kiểu "ppc_md"
        chứa các lệnh gọi lại khác nhau mà mã chung sẽ
        sử dụng để lấy mã cụ thể cho nền tảng của bạn

Một kernel image có thể hỗ trợ nhiều nền tảng, nhưng chỉ khi
nền tảng có cùng kiến trúc cốt lõi.  Một bản dựng kernel duy nhất
không hỗ trợ cả cấu hình Book E và cấu hình
với kiến trúc Powerpc cổ điển.