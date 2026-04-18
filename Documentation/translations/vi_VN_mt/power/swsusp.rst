.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/power/swsusp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=================
Hoán đổi tạm dừng
=================

Một số cảnh báo, đầu tiên.

.. warning::

   **BIG FAT WARNING**

   If you touch anything on disk between suspend and resume...
				...kiss your data goodbye.

   If you do resume from initrd after your filesystems are mounted...
				...bye bye root partition.

			[this is actually same case as above]

   If you have unsupported ( ) devices using DMA, you may have some
   problems. If your disk driver does not support suspend... (IDE does),
   it may cause some problems, too. If you change kernel command line
   between suspend and resume, it may do something wrong. If you change
   your hardware while system is suspended... well, it was not good idea;
   but it will probably only crash.

   ( ) suspend/resume support is needed to make it safe.

   If you have any filesystems on USB devices mounted before software suspend,
   they won't be accessible after resume and you may lose data, as though
   you have unplugged the USB devices with mounted filesystems on them;
   see the FAQ below for details.  (This is not true for more traditional
   power states like "standby", which normally don't turn USB off.)

Hoán đổi phân vùng:
  Bạn cần nối thêm sơ yếu lý lịch=/dev/your_swap_partition vào lệnh kernel
  dòng hoặc chỉ định nó bằng cách sử dụng /sys/power/resume.

Hoán đổi tập tin:
  Nếu sử dụng tệp hoán đổi, bạn cũng có thể chỉ định phần bù sơ yếu lý lịch bằng cách sử dụng
  sơ yếu lý lịch_offset=<number> trên dòng lệnh kernel hoặc chỉ định nó
  trong /sys/power/resume_offset.

Sau khi chuẩn bị xong thì bạn tạm dừng bằng cách::

tắt tiếng vang > /sys/power/đĩa; đĩa echo> /sys/power/state

- Nếu bạn cảm thấy ACPI hoạt động khá tốt trên hệ thống của mình, bạn có thể thử ::

nền tảng tiếng vang> /sys/power/đĩa; đĩa echo> /sys/power/state

- Nếu bạn muốn ghi ảnh ngủ đông để hoán đổi rồi tạm dừng
  tới RAM (miễn là nền tảng của bạn hỗ trợ nó), bạn có thể thử ::

echo đình chỉ> /sys/power/đĩa; đĩa echo> /sys/power/state

- Nếu bạn có đĩa SATA, bạn sẽ cần các hạt nhân gần đây có hệ thống treo SATA
  hỗ trợ. Để tạm dừng và tiếp tục hoạt động, hãy đảm bảo trình điều khiển đĩa của bạn
  được tích hợp vào kernel - không phải mô-đun. [Có cách để làm
  tạm dừng/tiếp tục với trình điều khiển đĩa mô-đun, xem FAQ, nhưng bạn có thể
  không nên làm thế.]

Nếu bạn muốn giới hạn kích thước hình ảnh treo ở N byte, hãy làm::

echo N > /sys/power/image_size

trước khi tạm dừng (theo mặc định, nó được giới hạn ở khoảng 2/5 RAM có sẵn).

- Quá trình tiếp tục kiểm tra sự hiện diện của thiết bị sơ yếu lý lịch,
  nếu được tìm thấy, nó sẽ kiểm tra nội dung để tìm chữ ký hình ảnh ngủ đông.
  Nếu cả hai được tìm thấy, nó sẽ tiếp tục hình ảnh ngủ đông.

- Quá trình tiếp tục có thể được kích hoạt theo hai cách:

1) Trong thời gian trễ: Nếu sơ yếu lý lịch=/dev/your_swap_partition được chỉ định trên
     dòng lệnh kernel, Lateinit chạy quá trình tiếp tục.  Nếu
     thiết bị tiếp tục chưa được thăm dò, quá trình tiếp tục không thành công và
     quá trình khởi động tiếp tục.
  2) Thủ công từ initrd hoặc initramfs: Có thể chạy từ
     tập lệnh init bằng cách sử dụng tệp /sys/power/resume.  Nó rất quan trọng
     rằng việc này phải được thực hiện trước khi kết nối lại bất kỳ hệ thống tập tin nào (ngay cả khi
     chỉ đọc) nếu không dữ liệu có thể bị hỏng.

Bài viết về mục tiêu và cách thực hiện Software Suspend cho Linux
====================================================================

Tác giả: Gábor Kuti
Sửa đổi lần cuối: 20-10-2003 bởi Pavel Machek

Ý tưởng và mục tiêu cần đạt được
-------------------------

Ngày nay, thông thường ở một số máy tính xách tay có nút treo. Nó
lưu trạng thái của máy vào hệ thống tập tin hoặc vào phân vùng và chuyển đổi
sang chế độ chờ. Sau đó khởi động lại máy, trạng thái đã lưu sẽ được tải trở lại
ram và máy có thể tiếp tục công việc của mình. Nó có hai lợi ích thực sự. Đầu tiên chúng tôi
hãy tự cứu mình khi cỗ máy ngừng hoạt động và sau đó khởi động lại, chi phí năng lượng
thực sự cao khi chạy bằng pin. Lợi ích khác là chúng ta không có
làm gián đoạn các chương trình của chúng tôi nên các quy trình đang tính toán một cái gì đó trong một thời gian dài
thời gian không cần phải được viết gián đoạn.

swsusp lưu trạng thái của máy vào các giao dịch hoán đổi đang hoạt động rồi khởi động lại hoặc
sự cố mất điện.  Bạn phải chỉ định rõ ràng phân vùng trao đổi để tiếp tục từ đó với
Tùy chọn hạt nhân ZZ0000ZZ. Nếu tìm thấy chữ ký, nó sẽ tải và khôi phục đã lưu
trạng thái. Nếu tùy chọn ZZ0001ZZ được chỉ định làm tham số khởi động, nó sẽ bỏ qua
việc nối lại.  Nếu tùy chọn ZZ0002ZZ được chỉ định làm khởi động
tham số, nó lưu hình ảnh ngủ đông mà không cần nén.

Trong thời gian hệ thống bị treo bạn không nên thêm/bớt bất kỳ thông tin nào
của phần cứng, ghi vào hệ thống tập tin, v.v.

Tóm tắt trạng thái ngủ
====================

Có ba giao diện khác nhau mà bạn có thể sử dụng, /proc/acpi nên
làm việc như thế này:

Trong một thế giới thực sự hoàn hảo::

echo 1 > /proc/acpi/sleep # for ở chế độ chờ
  echo 2 > /proc/acpi/sleep # for tạm dừng ram
  echo 3 > /proc/acpi/sleep # for tạm dừng ram, nhưng có nhiều năng lượng hơn
                                  # conservative
  echo 4 > /proc/acpi/sleep # for tạm dừng vào đĩa
  echo 5 > /proc/acpi/sleep # for tắt máy không thân thiện với hệ thống

và có lẽ::

echo 4b > /proc/acpi/sleep # for tạm dừng vào đĩa thông qua s4bios

Câu hỏi thường gặp
==========================

Hỏi:
  à, việc tạm dừng một máy chủ là IMHO thực sự là một điều ngu ngốc,
  nhưng... (Diego Zuccato):

Đáp:
  Bạn đã mua UPS mới cho máy chủ của mình. Làm thế nào để bạn cài đặt nó mà không cần
  hạ máy à? Tạm dừng vào đĩa, sắp xếp lại dây cáp điện,
  tiếp tục.

Bạn có máy chủ của mình trên UPS. Mất điện và UPS đang chỉ báo 30
  giây đến thất bại. Bạn làm nghề gì? Đình chỉ vào đĩa.


Hỏi:
  Có thể tôi đang thiếu thứ gì đó nhưng tại sao đường dẫn I/O thông thường không hoạt động?

Đáp:
  Chúng tôi sử dụng các đường dẫn I/O thông thường. Tuy nhiên chúng tôi không thể khôi phục dữ liệu
  đến vị trí ban đầu khi chúng tôi tải nó. Điều đó sẽ tạo ra một
  trạng thái hạt nhân không nhất quán chắc chắn sẽ dẫn đến lỗi.
  Thay vào đó, chúng tôi tải hình ảnh vào bộ nhớ không sử dụng và sau đó sao chép nguyên tử
  nó trở lại vị trí ban đầu. Tất nhiên, điều này hàm ý mức tối đa
  kích thước hình ảnh bằng một nửa dung lượng bộ nhớ.

Có hai giải pháp cho việc này:

* yêu cầu một nửa bộ nhớ trống trong thời gian tạm dừng. Bằng cách đó bạn có thể
    đọc dữ liệu "mới" vào các điểm trống, sau đó bấm và sao chép

* giả sử chúng ta có trình điều khiển ide "bỏ phiếu" đặc biệt chỉ sử dụng bộ nhớ
    trong khoảng 0-640KB. Bằng cách đó, tôi phải đảm bảo rằng 0-640KB là miễn phí
    trong khi tạm dừng, nhưng nếu không thì nó sẽ hoạt động ...

đình chỉ2 chia sẻ hạn chế cơ bản này, nhưng không bao gồm người dùng
  bộ nhớ đệm dữ liệu và đĩa vào "bộ nhớ đã sử dụng" bằng cách lưu chúng vào
  tiến lên. Điều đó có nghĩa là giới hạn sẽ biến mất trong thực tế.

Hỏi:
  Linux có hỗ trợ ACPI S4 không?

Đáp:
  Vâng. Đó chính là chức năng của echo platform > /sys/power/disk.

Hỏi:
  'Đình chỉ2' là gì?

Đáp:
  đình chỉ2 là 'Phần mềm tạm dừng 2', một triển khai phân nhánh của
  đình chỉ vào đĩa có sẵn dưới dạng các bản vá riêng biệt cho 2.4 và 2.6
  hạt nhân từ swsusp.sourceforge.net. Nó bao gồm hỗ trợ cho SMP, 4GB
  highmem và quyền ưu tiên. Nó cũng có một kiến trúc có thể mở rộng
  cho phép thực hiện các phép biến đổi tùy ý trên ảnh (nén,
  mã hóa) và các phần phụ trợ tùy ý để ghi hình ảnh (ví dụ: trao đổi
  hoặc chia sẻ NFS [Đang tiến hành công việc]). Các câu hỏi liên quan đến đình chỉ2
  nên được gửi đến danh sách gửi thư có sẵn thông qua đình chỉ2
  trang web chứ không phải vào Danh sách gửi thư hạt nhân Linux. chúng tôi đang làm việc
  hướng tới việc hợp nhất đình chỉ2 vào hạt nhân dòng chính.

Hỏi:
  Việc đóng băng các nhiệm vụ là gì và tại sao chúng ta lại sử dụng nó?

Đáp:
  Việc đóng băng các tác vụ là một cơ chế trong đó không gian người dùng xử lý và một số
  các luồng nhân được kiểm soát trong thời gian ngủ đông hoặc tạm dừng toàn hệ thống (trên
  một số kiến trúc).  Xem đóng băng nhiệm vụ.txt để biết chi tiết.

Hỏi:
  Sự khác biệt giữa "nền tảng" và "tắt máy" là gì?

Đáp:
  tắt máy:
	lưu trạng thái trong linux, sau đó yêu cầu bios tắt nguồn

nền tảng:
	lưu trạng thái trong linux, sau đó yêu cầu bios tắt nguồn và nhấp nháy
        "đèn led treo"

"nền tảng" thực sự là điều đúng đắn khi được hỗ trợ, nhưng
  "tắt máy" là đáng tin cậy nhất (ngoại trừ trên hệ thống ACPI).

Hỏi:
  Tôi không hiểu tại sao bạn lại phản đối mạnh mẽ ý tưởng của
  đình chỉ có chọn lọc.

Đáp:
  Thực hiện tạm dừng có chọn lọc trong quá trình quản lý nguồn điện trong thời gian chạy, không sao cả. Nhưng
  việc tạm dừng vào đĩa là vô ích. (Và tôi không hiểu bạn có thể sử dụng như thế nào
  nó dành cho hệ thống treo trên ram, tôi hy vọng bạn không muốn điều đó).

Hãy xem, vì vậy bạn đề nghị

* SUSPEND tất cả trừ thiết bị trao đổi và cha mẹ
  * Ảnh chụp nhanh
  * Ghi hình ảnh vào đĩa
  * SUSPEND trao đổi thiết bị và bố mẹ
  * Tắt nguồn

Ồ không, điều đó không có tác dụng, nếu thiết bị trao đổi hoặc cha mẹ của nó sử dụng DMA,
  bạn đã làm hỏng dữ liệu. Bạn sẽ phải làm

* SUSPEND tất cả trừ thiết bị trao đổi và cha mẹ
  * FREEZE trao đổi thiết bị và bố mẹ
  * Ảnh chụp nhanh
  * UNFREEZE trao đổi thiết bị và bố mẹ
  * Viết
  * SUSPEND trao đổi thiết bị và bố mẹ

Điều đó có nghĩa là bạn vẫn cần trạng thái FREEZE đó và bạn nhận được nhiều hơn
  mã phức tạp. (Và tôi chưa giới thiệu chi tiết như hệ thống
  thiết bị).

Hỏi:
  Dường như không có bất kỳ hành vi hữu ích nào nói chung
  sự khác biệt giữa SUSPEND và FREEZE.

Đáp:
  Làm SUSPEND khi bạn được yêu cầu làm FREEZE luôn đúng,
  nhưng nó có thể chậm một cách không cần thiết. Nếu bạn muốn trình điều khiển của mình luôn đơn giản,
  sự chậm chạp có thể không quan trọng với bạn. Nó luôn có thể được sửa chữa sau này.

Đối với các thiết bị như đĩa, điều đó rất quan trọng, bạn không muốn quay vòng
  FREEZE.

Hỏi:
  Sau khi tiếp tục, hệ thống phân trang rất nhiều, dẫn đến khả năng tương tác rất kém.

Đáp:
  Hãy thử chạy::

cat /proc/[0-9]ZZ0000ZZ /:/:' ZZ0001ZZ trong khi đọc tệp
    làm
      test -f "$file" && cat "$file" > /dev/null
    xong

sau khi tiếp tục. hoán đổi -a; swapon -a cũng có thể hữu ích.

Hỏi:
  Điều gì xảy ra với các thiết bị trong quá trình swsusp? Chúng dường như được nối lại
  trong thời gian hệ thống tạm dừng?

Đáp:
  Điều đó đúng. Chúng ta cần tiếp tục chúng nếu chúng ta muốn ghi hình ảnh vào
  đĩa. Toàn bộ chuỗi diễn ra như thế nào

ZZ0000ZZ

hệ thống đang chạy, người dùng yêu cầu tạm dừng vào đĩa

quá trình người dùng bị dừng

đình chỉ (PMSG_FREEZE): thiết bị bị đóng băng để chúng không can thiệp
      với ảnh chụp trạng thái

ảnh chụp nhanh trạng thái: bản sao của toàn bộ bộ nhớ đã sử dụng được thực hiện với các ngắt
      bị vô hiệu hóa

sơ yếu lý lịch(): các thiết bị được đánh thức để chúng ta có thể ghi hình ảnh để trao đổi

viết hình ảnh để trao đổi

treo (PMSG_SUSPEND): tạm dừng thiết bị để chúng tôi có thể tắt nguồn

tắt nguồn

ZZ0000ZZ

(thực tế là khá giống nhau)

hệ thống đang chạy, người dùng yêu cầu tạm dừng vào đĩa

quá trình người dùng bị dừng lại (trong trường hợp phổ biến là không có,
      nhưng với sơ yếu lý lịch từ initrd thì không ai biết)

đọc hình ảnh từ đĩa

đình chỉ (PMSG_FREEZE): thiết bị bị đóng băng để chúng không can thiệp
      với phục hồi hình ảnh

phục hồi hình ảnh: viết lại bộ nhớ bằng hình ảnh

sơ yếu lý lịch (): các thiết bị được đánh thức để hệ thống có thể tiếp tục

làm tan băng tất cả các tiến trình của người dùng

Hỏi:
  'Mã hóa hình ảnh treo' này để làm gì?

Đáp:
  Trước hết: nó không phải là sự thay thế cho trao đổi mã hóa dm-crypt.
  Nó không thể bảo vệ máy tính của bạn trong khi nó bị treo. Thay vào đó nó làm
  bảo vệ khỏi rò rỉ dữ liệu nhạy cảm sau khi tiếp tục tạm dừng.

Hãy nghĩ đến điều sau: bạn tạm dừng trong khi ứng dụng đang chạy
  giữ dữ liệu nhạy cảm trong bộ nhớ. Bản thân ứng dụng này ngăn chặn
  dữ liệu khỏi bị hoán đổi. Tuy nhiên, đình chỉ phải viết những điều này
  dữ liệu cần trao đổi để có thể tiếp tục lại sau này. Không đình chỉ mã hóa
  dữ liệu nhạy cảm của bạn sau đó được lưu trữ dưới dạng bản rõ trên đĩa.  Điều này có nghĩa
  rằng sau khi tiếp tục, tất cả dữ liệu nhạy cảm của bạn đều có thể truy cập được
  các ứng dụng có quyền truy cập trực tiếp vào thiết bị trao đổi đã được sử dụng
  để đình chỉ. Nếu bạn không cần trao đổi sau khi tiếp tục, những dữ liệu này có thể vẫn còn
  trên đĩa hầu như mãi mãi. Do đó, có thể xảy ra trường hợp hệ thống của bạn gặp phải
  bị hỏng trong vài tuần sau đó và dữ liệu nhạy cảm mà bạn nghĩ là
  được mã hóa và bảo vệ sẽ bị truy xuất và đánh cắp từ thiết bị trao đổi.
  Để ngăn chặn tình trạng này bạn nên sử dụng “Mã hóa hình ảnh treo”.

Trong quá trình tạm dừng, một khóa tạm thời được tạo và khóa này được sử dụng để
  mã hóa dữ liệu được ghi vào đĩa. Khi, trong quá trình tiếp tục, dữ liệu đã được
  đọc lại vào bộ nhớ, khóa tạm thời bị hủy, đơn giản là
  có nghĩa là tất cả dữ liệu được ghi vào đĩa trong thời gian tạm dừng sau đó sẽ được
  không thể truy cập được nên sau này chúng không thể bị đánh cắp.  Điều duy nhất mà
  sau đó bạn phải lưu ý rằng bạn gọi 'mkswap' để trao đổi
  phân vùng được sử dụng để tạm dừng càng sớm càng tốt trong thời gian thường xuyên
  khởi động. Điều này khẳng định rằng bất kỳ khóa tạm thời nào từ việc tạm dừng hoặc tạm dừng bị hủy
  từ một sơ yếu lý lịch bị lỗi hoặc bị hủy bỏ sẽ bị xóa khỏi thiết bị trao đổi.

Theo nguyên tắc chung, hãy sử dụng trao đổi được mã hóa để bảo vệ dữ liệu của bạn trong khi
  hệ thống bị tắt hoặc bị đình chỉ. Ngoài ra, hãy sử dụng mã hóa
  treo hình ảnh để ngăn dữ liệu nhạy cảm bị đánh cắp sau
  tiếp tục.

Hỏi:
  Tôi có thể tạm dừng một tập tin trao đổi không?

Đáp:
  Nói chung là có, bạn có thể.  Tuy nhiên, nó yêu cầu bạn sử dụng "sơ yếu lý lịch=" và
  Các tham số dòng lệnh kernel "resume_offset=", do đó, sơ yếu lý lịch từ một trao đổi
  không thể khởi tạo tệp từ hình ảnh initrd hoặc initramfs.  Xem
  swsusp-and-swap-files.txt để biết chi tiết.

Hỏi:
  Có kích thước RAM hệ thống tối đa được swsusp hỗ trợ không?

Đáp:
  Nó sẽ hoạt động ổn với highmem.

Hỏi:
  Swsusp (vào đĩa) chỉ sử dụng một phân vùng trao đổi hay nó có thể sử dụng
  nhiều phân vùng trao đổi (tổng hợp chúng thành một không gian logic)?

Đáp:
  Xin lỗi, chỉ có một phân vùng trao đổi.

Hỏi:
  Nếu (các) ứng dụng của tôi gây ra việc sử dụng nhiều bộ nhớ và dung lượng trao đổi
  (hơn một nửa tổng số hệ thống RAM), có đúng là có khả năng không
  việc cố gắng tạm dừng vào đĩa trong khi ứng dụng đó đang chạy là vô ích?

Đáp:
  Không, nó sẽ hoạt động ổn, miễn là ứng dụng của bạn không mlock()
  nó. Chỉ cần chuẩn bị phân vùng trao đổi đủ lớn.

Hỏi:
  Thông tin nào hữu ích cho việc gỡ lỗi các vấn đề treo vào đĩa?

Đáp:
  Chà, những tin nhắn cuối cùng trên màn hình luôn hữu ích. Nếu có gì đó
  bị hỏng, thường là do trình điều khiển hạt nhân nào đó, do đó hãy thử với as
  tải càng ít mô-đun càng tốt sẽ giúp ích rất nhiều. Tôi cũng thích mọi người
  tạm dừng từ bảng điều khiển, tốt nhất là không chạy X. Khởi động với
  init=/bin/bash, sau đó hoán đổi và bắt đầu trình tự tạm dừng theo cách thủ công
  thường thực hiện thủ thuật. Sau đó, bạn nên thử với phiên bản mới nhất
  hạt vani.

Hỏi:
  Làm cách nào các bản phân phối có thể gửi hạt nhân hỗ trợ swsusp với mô-đun
  trình điều khiển đĩa (đặc biệt là SATA)?

Đáp:
  Chà, có thể làm được, tải trình điều khiển, sau đó thực hiện echo vào
  /sys/power/tập tin tiếp tục từ initrd. Đảm bảo không gắn kết
  bất cứ thứ gì, kể cả ngàm chỉ đọc, nếu không bạn sẽ mất
  dữ liệu.

Hỏi:
  Làm cách nào để tạm dừng dài dòng hơn?

Đáp:
  Nếu bạn muốn xem bất kỳ thông báo kernel không có lỗi nào trên máy ảo
  terminal của kernel chuyển sang trong khi tạm dừng, bạn phải đặt
  mức log của bảng điều khiển hạt nhân lên ít nhất là 4 (KERN_WARNING), ví dụ: bằng
  đang làm::

# save cấp độ log cũ
	đọc LOGLEVEL DUMMY < /proc/sys/kernel/printk
	# set loglevel để chúng ta thấy thanh tiến trình.
	# if mức độ cao hơn mức cần thiết, chúng tôi để yên.
	nếu [ $LOGLEVEL -lt 5]; sau đó
	        echo 5 > /proc/sys/kernel/printk
		fi

IMG_SZ=0
        đọc IMG_SZ < /sys/power/image_size
        echo -n disk > /sys/power/state
        RET=$?
        #
        Logic # the ở đây là:
        # if image_size > 0 (không hỗ trợ kernel, IMG_SZ sẽ bằng 0),
        # then thử lại với image_size được đặt thành 0.
	nếu [ $RET -ne 0 -a $IMG_SZ -ne 0 ]; sau đó lại là # try với kích thước hình ảnh tối thiểu
                echo 0 > /sys/power/image_size
                echo -n disk > /sys/power/state
                RET=$?
        fi

Cấp độ log trước của # restore
	echo $LOGLEVEL > /proc/sys/kernel/printk
	thoát $RET

Hỏi:
  Điều này có đúng không nếu tôi có hệ thống tập tin được gắn trên thiết bị USB và
  Tôi tạm dừng vào đĩa, tôi có thể mất dữ liệu trừ khi hệ thống tập tin được gắn kết
  với "đồng bộ hóa"?

Đáp:
  Đúng rồi... nếu bạn ngắt kết nối thiết bị đó thì có thể sẽ mất dữ liệu.
  Trên thực tế, ngay cả với "-o sync", bạn vẫn có thể mất dữ liệu nếu chương trình của bạn có
  thông tin trong bộ đệm mà chúng chưa được ghi vào đĩa mà bạn ngắt kết nối,
  hoặc nếu bạn ngắt kết nối trước khi thiết bị lưu xong dữ liệu bạn đã ghi.

Phần mềm tạm dừng thường tắt nguồn bộ điều khiển USB, tương đương
  để ngắt kết nối tất cả các thiết bị USB được gắn vào hệ thống của bạn.

Hệ thống của bạn có thể hỗ trợ tốt các chế độ năng lượng thấp cho bộ điều khiển USB của nó
  trong khi hệ thống đang ngủ, duy trì kết nối, sử dụng chế độ ngủ thật
  các chế độ như "tạm dừng đến RAM" hoặc "chờ".  (Đừng ghi "đĩa" vào
  tập tin /sys/power/state; viết "chờ" hoặc "mem".) Chúng tôi chưa thấy cái nào
  phần cứng có thể sử dụng các chế độ này thông qua việc tạm dừng phần mềm, mặc dù trong
  về lý thuyết một số hệ thống có thể hỗ trợ các chế độ "nền tảng" sẽ không phá vỡ
  Kết nối USB.

Hãy nhớ rằng việc rút phích cắm ổ đĩa có chứa tập tin lưu trữ luôn là một ý tưởng tồi.
  hệ thống tập tin được gắn kết.  Điều đó đúng ngay cả khi hệ thống của bạn đang ngủ!  các
  điều an toàn nhất là ngắt kết nối tất cả các hệ thống tập tin trên phương tiện di động (chẳng hạn như USB,
  Firewire, CompactFlash, MMC, SATA bên ngoài hoặc thậm chí các khay cắm nóng IDE)
  trước khi tạm dừng; sau đó kể lại chúng sau khi tiếp tục.

Có một cách giải quyết cho vấn đề này.  Để biết thêm thông tin, xem
  Tài liệu/driver-api/usb/persist.rst.

Hỏi:
  Tôi có thể tạm dừng vào đĩa bằng phân vùng trao đổi trong LVM không?

Đáp:
  Có và Không. Bạn có thể tạm dừng thành công, nhưng kernel sẽ không thể
  để tự tiếp tục.  Bạn cần một initramfs có thể nhận dạng sơ yếu lý lịch
  tình huống, hãy kích hoạt khối logic chứa khối lượng trao đổi (nhưng không
  chạm vào bất kỳ hệ thống tập tin nào!), và cuối cùng gọi ::

echo -n "$major:$minor" > /sys/power/resume

trong đó $major và $minor là số thiết bị chính và phụ tương ứng của
  khối lượng trao đổi.

uswsusp cũng hoạt động với LVM.  Xem ZZ0000ZZ

Hỏi:
  Tôi đã nâng cấp kernel từ 2.6.15 lên 2.6.16. Cả hai hạt nhân đều
  được biên dịch với các tập tin cấu hình tương tự. Dù sao tôi cũng tìm thấy điều đó
  tạm dừng vào đĩa (và tiếp tục) chậm hơn nhiều trên 2.6.16 so với
  2.6.15. Bất kỳ ý tưởng nào về lý do tại sao điều đó có thể xảy ra hoặc làm cách nào tôi có thể tăng tốc nó?

Đáp:
  Điều này là do kích thước của hình ảnh treo bây giờ lớn hơn
  cho phiên bản 2.6.15 (bằng cách tiết kiệm nhiều dữ liệu hơn, chúng tôi có thể có được hệ thống phản hồi nhanh hơn
  sau khi tiếp tục).

Có núm /sys/power/image_size để điều khiển kích thước của
  hình ảnh.  Nếu bạn đặt nó thành 0 (ví dụ: bằng echo 0 > /sys/power/image_size as
  root), hành vi 2.6.15 sẽ được khôi phục.  Nếu vẫn còn quá
  chậm, hãy xem Suspend.sf.net -- việc đình chỉ vùng người dùng nhanh hơn và
  hỗ trợ nén LZF để tăng tốc độ hơn nữa.
