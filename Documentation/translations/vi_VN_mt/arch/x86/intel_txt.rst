.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/intel_txt.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Tổng quan về Intel(R) TXT
=========================

Công nghệ của Intel cho khả năng tính toán an toàn hơn, Intel(R) Trusted Execution
Công nghệ (Intel(R) TXT), xác định các cải tiến ở cấp độ nền tảng
cung cấp các khối xây dựng để tạo ra các nền tảng đáng tin cậy.

Intel TXT trước đây được biết đến với tên mã LaGrande Technology (LT).

Tóm tắt Intel TXT:

- Cung cấp nguồn gốc tin cậy động để đo lường (DRTM)
- Bảo vệ dữ liệu trong trường hợp tắt máy không đúng cách
- Đo lường và xác minh môi trường phóng

Intel TXT là một phần của thương hiệu vPro(TM) và cũng có sẵn một số
hệ thống không phải vPro.  Nó hiện có sẵn trên các hệ thống máy tính để bàn
dựa trên các chipset Q35, X38, Q45 và Q43 Express (ví dụ: Dell
Optiplex 755, HP dc7800, v.v.) và các hệ thống di động dựa trên GM45,
Chipset PM45 và GS45 Express.

Để biết thêm thông tin, xem ZZ0000ZZ
Trang web này cũng có liên kết đến Hướng dẫn dành cho nhà phát triển Intel TXT MLE,
đã được cập nhật cho các nền tảng mới được phát hành.

Intel TXT đã được giới thiệu tại nhiều sự kiện khác nhau trong vài năm qua
năm, một số trong số đó là:

-LinuxTAG 2008:
          ZZ0000ZZ

-TRUST2008:
          ZZ0000ZZ
          3_David-Grawrock_The-Front-Door-of-Trusted-Computing.pdf

- IDF, Thượng Hải:
          ZZ0000ZZ

- IDF 2006, 2007
	  (Tôi không chắc liệu họ có trực tuyến ở đâu không)

Tổng quan về dự án khởi động đáng tin cậy
=============================

Trusted Boot (tboot) là một mô-đun tiền nhân/VMM, nguồn mở,
sử dụng Intel TXT để thực hiện quá trình khởi chạy hệ điều hành được đo lường và xác minh
hạt nhân/VMM.

Nó được lưu trữ trên SourceForge tại ZZ0000ZZ
Kho lưu trữ nguồn đồng bóng có sẵn tại ZZ0001ZZ
repos.hg/tboot.hg.

Tboot hiện hỗ trợ khởi chạy Xen (VMM/hypervisor mã nguồn mở
w/ Hỗ trợ TXT kể từ v3.2) và bây giờ là nhân Linux.


Đề xuất giá trị cho Linux hoặc "Tại sao bạn nên quan tâm?"
=====================================================

Mặc dù có nhiều sản phẩm và công nghệ cố gắng
đo hoặc bảo vệ tính toàn vẹn của kernel đang chạy, tất cả đều
giả sử hạt nhân ngay từ đầu là "tốt".  Sự chính trực
Kiến trúc đo lường (IMA) và giao diện Mô-đun toàn vẹn Linux
là những ví dụ về những giải pháp như vậy.

Để có được sự tin cậy trong hạt nhân ban đầu mà không cần sử dụng Intel TXT,
gốc tĩnh của sự tin cậy phải được sử dụng.  Điều này tạo nên niềm tin vào BIOS
bắt đầu từ lúc thiết lập lại hệ thống và yêu cầu đo tất cả mã
được thực hiện giữa quá trình thiết lập lại hệ thống cho đến khi hoàn thành kernel
boot cũng như các đối tượng dữ liệu được mã đó sử dụng.  Trong trường hợp của một
Nhân Linux, điều này có nghĩa là tất cả BIOS, mọi ROM tùy chọn,
bootloader và cấu hình khởi động.  Trong thực tế, điều này là rất nhiều
mã/dữ liệu, phần lớn trong số đó có thể thay đổi từ lần khởi động này sang lần khởi động khác
(ví dụ: thay đổi NIC có thể thay đổi ROM tùy chọn).  Không có tài liệu tham khảo
băm, những thay đổi đo lường này rất khó đánh giá hoặc
xác nhận là lành tính.  Quá trình này cũng không cung cấp DMA
bảo vệ, kiểm tra và khóa cấu hình bộ nhớ/bí danh, sự cố
bảo vệ hoặc hỗ trợ chính sách.

Bằng cách sử dụng gốc tin cậy dựa trên phần cứng mà Intel TXT cung cấp,
nhiều vấn đề trong số này có thể được giảm thiểu.  Cụ thể: nhiều
các thành phần trước khi ra mắt có thể được xóa khỏi chuỗi tin cậy, DMA
sự bảo vệ được cung cấp cho tất cả các thành phần được đưa ra, một số lượng lớn
kiểm tra cấu hình nền tảng được thực hiện và các giá trị bị khóa,
sự bảo vệ được cung cấp cho bất kỳ dữ liệu nào trong trường hợp sử dụng không đúng cách
tắt máy và có hỗ trợ thực thi/xác minh dựa trên chính sách.
Điều này cung cấp phép đo ổn định hơn và đảm bảo cao hơn về
cấu hình hệ thống và trạng thái ban đầu hơn là nếu không
có thể.  Do dự án tboot là mã nguồn mở nên mã nguồn của
hầu hết tất cả các phần của chuỗi tin cậy đều có sẵn (ngoại trừ SMM và
chương trình cơ sở do Intel cung cấp).

Nó hoạt động như thế nào?
=================

- Tboot là một chương trình thực thi được bootloader khởi chạy dưới dạng
   "kernel" (tệp nhị phân mà bộ nạp khởi động thực thi).
- Nó thực hiện tất cả các công việc cần thiết để xác định xem
   nền tảng hỗ trợ Intel TXT và nếu vậy, sẽ thực thi GETSEC[SENTER]
   hướng dẫn bộ xử lý khởi tạo gốc động của sự tin cậy.

- Nếu tboot xác định hệ thống không hỗ trợ Intel TXT
      hoặc không được cấu hình đúng (ví dụ: Mô-đun AC SINIT đã bị
      không chính xác), nó sẽ trực tiếp khởi chạy kernel mà không có thay đổi nào
      tới bất kỳ trạng thái nào.
   - Tboot sẽ xuất ra nhiều thông tin khác nhau về tiến trình của nó tới
      thiết bị đầu cuối, cổng nối tiếp và/hoặc nhật ký trong bộ nhớ; đầu ra
      vị trí có thể được cấu hình bằng một chuyển đổi dòng lệnh.

- Lệnh GETSEC[SENTER] sẽ trả quyền điều khiển về tboot và
   tboot sau đó xác minh các khía cạnh nhất định của môi trường (ví dụ TPM NV
   lock, bảng e820 không có mục nào không hợp lệ, v.v.).
- Nó sẽ đánh thức các AP khỏi trạng thái ngủ đặc biệt GETSEC[SENTER]
   hướng dẫn đã đưa chúng vào và đặt chúng vào SIPI chờ
   trạng thái.

- Bởi vì bộ xử lý sẽ không phản hồi với INIT hoặc SIPI khi
      trong môi trường TXT, cần tạo một VT-x nhỏ
      khách mời cho các AP.  Khi họ chạy vào vị khách này, họ sẽ
      chỉ cần đợi chuỗi INIT-SIPI-SIPI, điều này sẽ gây ra
      VMEXIT, sau đó tắt VT và chuyển sang vectơ SIPI.  Cái này
      cách tiếp cận có vẻ như là một lựa chọn tốt hơn là phải chèn
      mã đặc biệt vào chuỗi đánh thức MP của kernel.

- Sau đó, Tboot áp dụng chính sách khởi chạy (tùy chọn) do người dùng xác định cho
   xác minh kernel và initrd.

- Chính sách này được bắt nguồn từ TPM NV và được mô tả trong tboot
      dự án.  Dự án tboot cũng chứa mã cho các công cụ để
      tạo và cung cấp chính sách.
   - Chính sách hoàn toàn nằm dưới sự kiểm soát của người dùng và nếu không có
      sau đó bất kỳ hạt nhân nào cũng sẽ được khởi chạy.
   - Hành động chính sách rất linh hoạt và có thể bao gồm việc dừng lại khi có thất bại
      hoặc đơn giản là đăng nhập chúng và tiếp tục.

- Tboot điều chỉnh bảng e820 do bootloader cung cấp để dự trữ
   vị trí riêng của nó trong bộ nhớ cũng như để dành một số vị trí khác
   Các vùng liên quan đến TXT.
- Là một phần của đợt ra mắt, tboot DMA bảo vệ tất cả RAM (sử dụng
   VT-d PMR).  Do đó, kernel phải được khởi động bằng 'intel_iommu=on'
   để loại bỏ lớp bảo vệ chăn này và sử dụng VT-d
   bảo vệ cấp trang.
- Tboot sẽ đưa vào một trang được chia sẻ một số dữ liệu về chính nó và
   chuyển cái này tới nhân Linux khi nó chuyển quyền điều khiển.

- Vị trí của trang chia sẻ được chuyển qua boot_params
      struct như một địa chỉ vật lý.

- Kernel sẽ tìm địa chỉ trang chia sẻ tboot và nếu có
   tồn tại, hãy lập bản đồ nó.
- Là một trong những biện pháp kiểm tra/bảo vệ do TXT cung cấp, nó tạo một bản sao
   của DMAR VT-d trong vùng bộ nhớ được bảo vệ DMA và xác minh
   chúng cho đúng đắn.  Mã VT-d sẽ phát hiện xem hạt nhân có bị
   được khởi chạy bằng tboot và sử dụng bản sao này thay vì bản sao trong
   Bàn ACPI.
- Tại thời điểm này, tboot và TXT không còn hoạt động cho đến khi
   tắt máy (S<n>)
- Để đưa hệ thống vào bất kỳ trạng thái ngủ nào sau TXT
   khởi chạy, trước tiên TXT phải được thoát.  Điều này nhằm ngăn chặn các cuộc tấn công
   cố gắng đánh sập hệ thống để giành quyền kiểm soát khi khởi động lại và đánh cắp
   dữ liệu còn lại trong bộ nhớ.

- Hạt nhân sẽ thực hiện tất cả việc chuẩn bị giấc ngủ và
      điền vào trang được chia sẻ dữ liệu ACPI cần thiết để đặt
      nền tảng ở trạng thái ngủ mong muốn.
   - Sau đó kernel nhảy vào tboot thông qua vector được chỉ định trong
      trang chia sẻ.
   - Tboot sẽ dọn dẹp môi trường và vô hiệu hóa TXT, sau đó sử dụng
      thông tin ACPI do kernel cung cấp để thực sự đặt nền tảng
      vào trạng thái ngủ mong muốn.
   - Trong trường hợp của S3, tboot cũng sẽ tự đăng ký làm sơ yếu lý lịch
      vectơ.  Điều này là cần thiết vì nó phải thiết lập lại
      môi trường được đo khi tiếp tục.  Khi môi trường TXT
      đã được khôi phục, nó sẽ khôi phục PCR TPM và sau đó
      chuyển điều khiển trở lại vectơ sơ yếu lý lịch S3 của kernel.
      Để duy trì tính toàn vẹn của hệ thống trên S3, kernel
      cung cấp cho tboot một tập hợp các phạm vi bộ nhớ (RAM và RESERVED_KERN
      trong bảng e820, nhưng không có bất kỳ bộ nhớ nào mà BIOS có thể thay đổi
      quá trình chuyển đổi S3) mà tboot sẽ tính toán MAC (thông báo
      mã xác thực) rồi đóng dấu bằng TPM. Trên sơ yếu lý lịch
      và khi môi trường đo đã được thiết lập lại, hãy khởi động lại
      sẽ tính toán lại MAC và xác minh nó dựa trên giá trị được niêm phong.
      Chính sách của Tboot xác định điều gì sẽ xảy ra nếu quá trình xác minh không thành công.
      Lưu ý rằng c/s 194 của tboot có mã MAC mới hỗ trợ
      cái này.

Đó là khá nhiều cho sự hỗ trợ của TXT.


Cấu hình hệ thống
======================

Mã này hoạt động với hạt nhân 32bit, 32bit PAE và 64bit (x86_64).

Trong BIOS, người dùng phải kích hoạt: TPM, TXT, VT-x, VT-d.  Không phải tất cả BIOS
cho phép các tính năng này được bật/tắt riêng lẻ và các màn hình ở chế độ
để tìm thấy chúng là dành riêng cho BIOS.

grub.conf cần được sửa đổi như sau::

title Linux 2.6.29-tip w/ tboot
          gốc (hd0,0)
                kernel /tboot.gz log=serial,vga,memory
                mô-đun /vmlinuz-2.6.29-tip intel_iommu=on ro
                       root=LABEL=/ rhgb console=ttyS0,115200 3
                mô-đun /initrd-2.6.29-tip.img
                mô-đun /Q35_SINIT_17.BIN

Tùy chọn kernel để kích hoạt hỗ trợ Intel TXT được tìm thấy trong
Menu bảo mật cấp cao nhất và được gọi là "Kích hoạt Intel(R) Trusted
Công nghệ thực thi (TXT)".  Nó được coi là EXPERIMENTAL và
phụ thuộc vào sự hỗ trợ chung của x86 (để cho phép sự linh hoạt tối đa trong
tùy chọn xây dựng kernel), vì mã tboot sẽ phát hiện xem
nền tảng thực sự hỗ trợ Intel TXT và do đó liệu có bất kỳ
mã hạt nhân được thực thi.

Tệp Q35_SINIT_17.BIN được Intel TXT gọi là tệp
Mô-đun mã xác thực.  Nó dành riêng cho chipset trong
hệ thống và cũng có thể được tìm thấy trên trang Trusted Boot.  Nó là một
mô-đun (không được mã hóa) được Intel ký và được sử dụng như một phần của
Quá trình DRTM để xác minh và cấu hình hệ thống.  Nó được ký
bởi vì nó hoạt động ở mức đặc quyền cao hơn trong hệ thống so với
bất kỳ mã macro nào khác và hoạt động chính xác của nó là rất quan trọng đối với
thành lập DRTM.  Quá trình xác định đúng
SINIT ACM cho một hệ thống được ghi lại trong tệp SINIT-guide.txt
đó là trên trang tboot SourceForge trong phần tải xuống SINIT ACM.
