.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/bootwrapper.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình bao bọc khởi động PowerPC
========================

Bản quyền (C) Secret Lab Technologies Ltd.

Mục tiêu hình ảnh PowerPC nén và bọc hình ảnh hạt nhân (vmlinux) bằng
một trình bao bọc khởi động để phần sụn hệ thống có thể sử dụng được.  không có
giao diện chương trình cơ sở PowerPC tiêu chuẩn, do đó trình bao bọc khởi động được thiết kế để
có thể thích ứng với từng loại hình ảnh cần xây dựng.

Trình bao bọc khởi động có thể được tìm thấy trong thư mục Arch/powerpc/boot/.  các
Makefile trong thư mục đó có mục tiêu cho tất cả các loại hình ảnh có sẵn.
Các loại hình ảnh khác nhau được sử dụng để hỗ trợ tất cả các phần mềm khác nhau
giao diện được tìm thấy trên nền tảng PowerPC.  OpenFirmware là phổ biến nhất
loại chương trình cơ sở được sử dụng trên các hệ thống PowerPC có mục đích chung từ Apple, IBM và
những người khác.  U-Boot thường được tìm thấy trên phần cứng PowerPC nhúng, nhưng cũng có
là một số cách triển khai chương trình cơ sở khác cũng phổ biến.  Mỗi
giao diện phần sụn yêu cầu định dạng hình ảnh khác.

Trình bao bọc khởi động được xây dựng từ tệp makefile trong Arch/powerpc/boot/Makefile và
nó sử dụng tập lệnh bao bọc (arch/powerpc/boot/wrapper) để tạo mục tiêu
hình ảnh.  Chi tiết về hệ thống xây dựng sẽ được thảo luận trong phần tiếp theo.
Hiện tại, các mục tiêu định dạng hình ảnh sau tồn tại:

==================================================================================
   cuImage.%: uImage tương thích ngược cho phiên bản cũ hơn của
			U-Boot (dành cho phiên bản không hiểu máy
			cây).  Hình ảnh này nhúng một đốm màu cây thiết bị bên trong
			hình ảnh.  Trình bao bọc khởi động, hạt nhân và cây thiết bị
			tất cả đều được nhúng bên trong định dạng tệp U-Boot uImage
			với mã trình bao bọc khởi động trích xuất dữ liệu từ cái cũ
			cấu trúc bd_info và tải dữ liệu vào thiết bị
			cây trước khi nhảy vào kernel.

Bởi vì loạt #ifdefs được tìm thấy trong
			cấu trúc bd_info được sử dụng trong giao diện U-Boot cũ,
			cuImages là nền tảng cụ thể.  Mỗi cụ thể
			Nền tảng U-Boot có tệp init nền tảng khác
			điền vào cây thiết bị nhúng dữ liệu
			từ tệp bd_info cụ thể của nền tảng.  Nền tảng
			Mã khởi tạo nền tảng cuImage cụ thể có thể được tìm thấy trong
			ZZ0000ZZ. Lựa chọn đúng
			Mã init cuImage cho một bảng cụ thể có thể được tìm thấy trong
			cấu trúc bao bọc.

dtbImage.%: Tương tự như zImage, ngoại trừ blob cây thiết bị được nhúng
			bên trong hình ảnh thay vì được cung cấp bởi phần sụn.  các
			Tệp hình ảnh đầu ra có thể là tệp elf hoặc tệp phẳng
			nhị phân tùy thuộc vào nền tảng.

dtbImages được sử dụng trên các hệ thống không có
			giao diện để truyền trực tiếp cây thiết bị.
			dtbImages tương tự như SimpleImages ngoại trừ việc
			dtbImages có mã nền tảng cụ thể để giải nén
			dữ liệu từ chương trình cơ sở của bo mạch, nhưng SimpleImages thì không
			nói chuyện với phần sụn cả.

Hỗ trợ PlayStation 3 sử dụng dtbImage.  Nhúng cũng vậy
			Các bảng hành tinh sử dụng phần mềm PlanetCore.  Ban
			mã khởi tạo cụ thể thường được tìm thấy trong một
			tệp có tên Arch/powerpc/boot/<platform>.c; nhưng cái này
			có thể bị ghi đè bởi tập lệnh bao bọc.

simpleImage.%: Hình ảnh nén độc lập với phần sụn không
			phụ thuộc vào bất kỳ giao diện phần sụn cụ thể nào và các phần nhúng
			một đốm màu cây thiết bị.  Hình ảnh này là một hình nhị phân phẳng
			có thể được tải đến bất kỳ vị trí nào trong RAM và chuyển tới.
			Phần sụn không thể chuyển bất kỳ dữ liệu cấu hình nào tới
			kernel với loại hình ảnh này và nó phụ thuộc hoàn toàn vào
			cây thiết bị nhúng cho tất cả thông tin.

câyImage.%;		Đã tìm thấy định dạng hình ảnh để sử dụng với phần mềm OpenBIOS
			trên một số phần cứng ppc4xx.  Hình ảnh này nhúng một thiết bị
			đốm màu cây bên trong hình ảnh.

uImage: Định dạng hình ảnh gốc được U-Boot sử dụng.  Mục tiêu uImage
			không thêm bất kỳ mã khởi động nào.  Nó chỉ bao bọc một nén
			vmlinux trong cấu trúc dữ liệu uImage.  Hình ảnh này
			yêu cầu một phiên bản U-Boot có khả năng vượt qua
			cây thiết bị vào kernel khi khởi động.  Nếu sử dụng cái cũ hơn
			phiên bản U-Boot thì bạn cần sử dụng cuImage
			thay vào đó.

zImage.%: Định dạng hình ảnh không nhúng cây thiết bị.
			Được sử dụng bởi OpenFirmware và các giao diện phần sụn khác
			có khả năng cung cấp một cây thiết bị.  Hình ảnh này
			mong đợi phần sụn sẽ cung cấp cây thiết bị khi khởi động.
			Thông thường, nếu bạn có PowerPC mục đích chung
			phần cứng thì bạn muốn định dạng hình ảnh này.
   ==================================================================================

Các loại hình ảnh nhúng blob cây thiết bị (simpleImage, dtbImage, treeImage,
và cuImage) đều tạo blob cây thiết bị từ một tệp trong
thư mục Arch/powerpc/boot/dts/.  Makefile chọn đúng thiết bị
nguồn cây dựa trên tên của mục tiêu.  Vì vậy, nếu hạt nhân
được xây dựng bằng 'make treeImage.walnut', thì hệ thống xây dựng sẽ sử dụng
Arch/powerpc/boot/dts/walnut.dts để xây dựng treeImage.walnut.

Hai mục tiêu đặc biệt gọi là 'zImage' và 'zImage.initrd' cũng tồn tại.  Những cái này
mục tiêu xây dựng tất cả các hình ảnh mặc định được cấu hình kernel chọn.
Hình ảnh mặc định được chọn bởi trình bao bọc khởi động Makefile
(Arch/powerpc/boot/Makefile) bằng cách thêm mục tiêu vào biến $image-y.  Nhìn kìa
tại Makefile để xem mục tiêu hình ảnh mặc định nào có sẵn.

Nó được xây dựng như thế nào
---------------
Arch/powerpc được thiết kế để hỗ trợ các hạt nhân đa nền tảng, có nghĩa là
rằng một hình ảnh vmlinux có thể được khởi động trên nhiều bảng mục tiêu khác nhau.
Điều đó cũng có nghĩa là trình bao bọc khởi động phải có khả năng bao bọc cho nhiều loại
hình ảnh trên một bản dựng duy nhất.  Quyết định thiết kế được đưa ra là không sử dụng bất kỳ
mã biên dịch có điều kiện (#ifdef, v.v.) trong mã nguồn trình bao bọc khởi động.
Tất cả các phần của trình bao bọc khởi động đều có thể được xây dựng bất kỳ lúc nào bất kể
cấu hình hạt nhân.  Xây dựng tất cả các bit bao bọc trên mỗi bản dựng kernel
cũng đảm bảo rằng các phần tối nghĩa của trình bao bọc ít nhất được biên dịch
được thử nghiệm trong nhiều môi trường khác nhau.

Trình bao bọc được điều chỉnh cho phù hợp với các loại hình ảnh khác nhau tại thời điểm liên kết bằng cách liên kết trong
chỉ các bit bao bọc phù hợp với loại hình ảnh.  'Trình bao bọc
script' (tìm thấy trong Arch/powerpc/boot/wrapper) được gọi bởi Makefile và
chịu trách nhiệm chọn các bit bao bọc chính xác cho loại hình ảnh.
Các đối số được ghi lại rõ ràng trong khối nhận xét của tập lệnh, vì vậy chúng
không được lặp lại ở đây.  Tuy nhiên, điều đáng nói là kịch bản
sử dụng đối số -p (nền tảng) làm phương thức chính để quyết định trình bao bọc nào
bit để biên dịch. Hãy tìm khối 'case "$platform" in' lớn trong
giữa kịch bản.  Đây cũng là nơi sửa lỗi nền tảng cụ thể
có thể được lựa chọn bằng cách thay đổi thứ tự liên kết.

Đặc biệt, cần cẩn thận khi làm việc với cuImages.  cuImage
các bit bao bọc rất cụ thể cho bảng và cần phải cẩn thận để đảm bảo
mục tiêu bạn đang cố gắng xây dựng được hỗ trợ bởi các bit bao bọc.
