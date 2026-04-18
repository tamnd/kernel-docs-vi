.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/arm.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
ARM Linux 2.6 trở lên
==========================

Vui lòng kiểm tra <ftp://ftp.arm.linux.org.uk/pub/armlinux> để biết
    cập nhật.

Biên soạn hạt nhân
---------------------

Để biên dịch ARM Linux, bạn sẽ cần một trình biên dịch có khả năng
  tạo mã ARM ELF với phần mở rộng GNU.  GCC 3.3 được biết đến là
  một trình biên dịch tốt.  May mắn thay, bạn không cần phải đoán.  Hạt nhân sẽ báo cáo
  một lỗi nếu trình biên dịch của bạn là một kẻ phạm tội được công nhận.

Để xây dựng ARM Linux nguyên bản, bạn không cần phải thay đổi dòng ARCH =
  trong Makefile cấp cao nhất.  Tuy nhiên, nếu bạn không có ARM Linux ELF
  công cụ được cài đặt mặc định thì bạn nên thay đổi CROSS_COMPILE
  dòng như chi tiết dưới đây.

Nếu bạn muốn biên dịch chéo, hãy thay đổi các dòng sau ở trên cùng
  tập tin tạo cấp độ::

ARCH = <sao cũng được>

với::

ARCH = cánh tay

Và::

CROSS_COMPILE=

ĐẾN::

CROSS_COMPILE=<your-path-to-your-compiler-without-gcc>

ví dụ.::

CROSS_COMPILE=arm-linux-

Thực hiện 'tạo cấu hình', sau đó là 'tạo hình ảnh' để xây dựng kernel
  (vòm/cánh tay/khởi động/Hình ảnh).  Một hình ảnh nén có thể được xây dựng bằng cách thực hiện một
  'tạo zImage' thay vì 'tạo hình ảnh'.


Báo cáo lỗi, v.v.
-----------------

Vui lòng gửi bản vá đến hệ thống vá lỗi.  Để biết thêm thông tin, xem
  ZZ0000ZZ Luôn bao gồm một số
  giải thích về chức năng của bản vá và tại sao nó lại cần thiết.

Báo cáo lỗi phải được gửi tới linux-arm-kernel@lists.arm.linux.org.uk,
  hoặc gửi qua mẫu web tại
  ZZ0000ZZ

Khi gửi báo cáo lỗi, hãy đảm bảo rằng chúng chứa tất cả các thông tin liên quan
  thông tin, ví dụ. các thông điệp kernel đã được in trước/trong
  vấn đề, những gì bạn đang làm, v.v.


Bao gồm các tập tin
-------------------

Một số thư mục bao gồm mới đã được tạo trong include/asm-arm,
  có ở đó để giảm bớt sự lộn xộn trong thư mục cấp cao nhất.  Những cái này
  thư mục và mục đích của chúng được liệt kê dưới đây:

============== ===============================================================
   Tệp tiêu đề cụ thể của máy/nền tảng ZZ0000ZZ
   Cấu trúc/định nghĩa dữ liệu cụ thể của trình điều khiển ZZ0001ZZ bên trong ARM
   Mô tả ZZ0002ZZ của ARM chung cho các giao diện máy cụ thể
   Các tệp tiêu đề phụ thuộc vào bộ xử lý ZZ0003ZZ (hiện chỉ có hai
		danh mục)
  ============== ===============================================================


Hỗ trợ máy/nền tảng
------------------------

Cây ARM hỗ trợ rất nhiều loại máy khác nhau.  Đến
  tiếp tục hỗ trợ những khác biệt này, việc chia rẽ đã trở nên cần thiết
  các bộ phận cụ thể của máy theo thư mục.  Đối với điều này, loại máy là
  được sử dụng để chọn thư mục và tập tin nào được đưa vào (chúng tôi sẽ sử dụng
  $(MACHINE) để tham khảo danh mục)

Để đạt được mục đích này, hiện tại chúng ta có các thư mục Arch/arm/mach-$(MACHINE)
  được thiết kế để chứa các tệp không phải trình điều khiển cho một máy cụ thể (ví dụ: PCI,
  quản lý bộ nhớ, định nghĩa kiến trúc, v.v.).  Vì tất cả tương lai
  các máy, cần có Arch/arm/mach-$(MACHINE)/include/mach tương ứng
  thư mục.


Mô-đun
-------

Mặc dù việc mô-đun hóa được hỗ trợ (và bắt buộc đối với trình mô phỏng FP),
  mỗi mô-đun trên máy ARM2/ARM250/ARM3 khi được tải sẽ mất
  bộ nhớ lên tới ranh giới 32k tiếp theo do kích thước của các trang.
  Vì vậy, việc mô-đun hóa trên những chiếc máy này có thực sự đáng giá?

Tuy nhiên, các máy ARM6 trở lên cho phép các mô-đun lấy bội số của 4k và
  như Acorn RiscPC và các kiến trúc khác sử dụng các bộ xử lý này có thể
  tận dụng tốt việc mô-đun hóa.


Tệp hình ảnh ADFS
-----------------

Bạn có thể truy cập các tệp hình ảnh trên phân vùng ADFS của mình bằng cách gắn ADFS
  phân vùng, sau đó sử dụng trình điều khiển thiết bị loopback.  Bạn phải có
  đã cài đặt losstup.

Xin lưu ý rằng các phân vùng PCEmulator DOS có bảng phân vùng tại
  bắt đầu và do đó, bạn sẽ phải cung cấp '-o offset' cho phần thua.


Yêu cầu nhà phát triển
----------------------

Khi viết trình điều khiển thiết bị bao gồm một tập tin biên dịch mã riêng biệt, vui lòng
  đưa nó vào trong tệp C chứ không phải thư mục Arch/arm/lib.  Cái này
  cho phép trình điều khiển được biên dịch thành một mô-đun có thể tải mà không yêu cầu
  một nửa mã sẽ được biên dịch thành hình ảnh hạt nhân.

Nói chung, hãy cố gắng tránh sử dụng trình biên dịch chương trình trừ khi thực sự cần thiết.  Nó
  làm cho trình điều khiển khó chuyển sang phần cứng khác hơn.


Ổ cứng ST506
-----------------

Bộ điều khiển ổ cứng ST506 dường như đang hoạt động tốt (nếu có một chút
  từ từ).  Hiện tại, họ sẽ chỉ làm việc với bộ điều khiển trên một
  Bo mạch chủ của A4x0, nhưng để nó hoạt động với Podule chỉ cần
  ai đó có podule để thêm địa chỉ cho mặt nạ IRQ và
  HDC căn cứ vào nguồn.

Kể từ ngày 31/3/96, nó hoạt động với hai ổ đĩa (bạn nên lấy ADFS
  Ổ cứng ZZ0000ZZ được đặt thành 2). Tôi có 20 MB nội bộ và một bộ nhớ tuyệt vời
  ổ đĩa lớn 5,25" FH 64 MB bên ngoài (ai có thể muốn nhiều hơn :-)).

Tôi vừa giảm được 240K/s (một dd có bs=128k); đó là khoảng một nửa những gì
  RiscOS được; nhưng nó tốt hơn rất nhiều so với tốc độ 50K/s tôi nhận được
  tuần trước :-)

Lỗi đã biết: Lỗi dữ liệu ổ đĩa có thể gây treo máy; bao gồm cả những trường hợp
  bộ điều khiển đã sửa lỗi bằng ECC. (Có thể là ONLY
  trong trường hợp đó...hmm).


1772 Đĩa mềm
------------
Điều này có vẻ cũng ổn, nhưng gần đây không bị căng thẳng nhiều.  Nó
  hiện tại không có bất kỳ mã nào để phát hiện sự thay đổi đĩa
  có thể có chút vấn đề!  Gợi ý về cách chính xác để thực hiện việc này
  được chào đón.


ZZ0000ZZ và ZZ0001ZZ
---------------------------------
Một sự thay đổi đã được thực hiện vào năm 2003 đối với tên macro cho các máy mới.
  Trong lịch sử, ZZ0000ZZ được sử dụng cho kiến trúc bonafide,
  ví dụ: SA1100, cũng như việc triển khai kiến trúc,
  ví dụ: Assabet.  Nó đã được quyết định thay đổi macro thực hiện
  để đọc ZZ0001ZZ cho rõ ràng.  Hơn nữa, một bản sửa lỗi có hiệu lực hồi tố có
  không được thực hiện vì nó sẽ làm phức tạp việc vá lỗi.

Đăng ký trước đó có thể được tìm thấy trực tuyến.

<ZZ0000ZZ

Mục nhập hạt nhân (head.S)
--------------------------
Mục nhập ban đầu vào kernel là thông qua head.S, sử dụng máy
  mã độc lập.  Máy được chọn theo giá trị 'r1' trên
  mục nhập, phải được giữ duy nhất.

Do số lượng máy mà cổng ARM của Linux cung cấp rất lớn
  vì chúng tôi có một phương pháp để quản lý việc này nhằm đảm bảo rằng chúng tôi không kết thúc
  sao chép số lượng lớn mã.

Chúng tôi nhóm mã hỗ trợ máy (hoặc nền tảng) thành các lớp máy.  A
  lớp thường dựa trên một hoặc nhiều hệ thống trên thiết bị chip và
  hoạt động như một thùng chứa tự nhiên xung quanh việc triển khai thực tế.  Những cái này
  các lớp được cung cấp các thư mục - Arch/arm/mach-<class> - chứa
  các tệp nguồn và include/mach/ để hỗ trợ lớp máy.

Ví dụ: lớp SA1100 dựa trên SA1100 và SA1110 SoC
  thiết bị và chứa mã để hỗ trợ cách thức hoạt động trên và ngoài
  thiết bị bo mạch được sử dụng hoặc thiết bị được thiết lập và cung cấp điều đó
  "tính cách" cụ thể của máy.

Đối với các nền tảng hỗ trợ cây thiết bị (DT), việc lựa chọn máy là
  được kiểm soát trong thời gian chạy bằng cách chuyển blob cây thiết bị tới kernel.  Tại
  thời gian biên dịch, phải chọn hỗ trợ cho loại máy.  Điều này cho phép
  một bản dựng hạt nhân đa nền tảng duy nhất được sử dụng cho một số loại máy.

Đối với các nền tảng không sử dụng cây thiết bị, việc lựa chọn máy này là
  được kiểm soát bởi ID loại máy, hoạt động như thời gian chạy và
  phương pháp lựa chọn mã thời gian biên dịch.  Bạn có thể đăng ký một máy mới thông qua
  trang web tại:

<ZZ0000ZZ

Lưu ý: Vui lòng không đăng ký loại máy cho nền tảng chỉ DT.  Nếu bạn
  nền tảng chỉ có DT, bạn không cần loại máy đã đăng ký.

---

Russell King (15/03/2004)
