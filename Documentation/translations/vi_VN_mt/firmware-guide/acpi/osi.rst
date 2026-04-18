.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/osi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================
Phương pháp ACPI _OSI và _REV
=============================

ACPI BIOS có thể sử dụng phương thức "Giao diện hệ điều hành" (_OSI)
để tìm hiểu xem hệ điều hành hỗ trợ những gì. Ví dụ. Nếu BIOS
Mã AML bao gồm _OSI("XYZ"), trình thông dịch AML của kernel
có thể đánh giá phương pháp đó, xem xem nó có hỗ trợ 'XYZ' không
và trả lời YES hoặc KHÔNG cho BIOS.

Phương thức ACPI _REV trả về "Bản sửa đổi đặc tả ACPI
mà OSPM hỗ trợ"

Tài liệu này giải thích cách thức và lý do BIOS và Linux nên sử dụng các phương pháp này.
Nó cũng giải thích làm thế nào và tại sao chúng bị lạm dụng rộng rãi.

Cách sử dụng _OSI
===============

Linux chạy trên hai nhóm máy -- những nhóm được thử nghiệm bởi OEM
tương thích với Linux và những thứ chưa từng được thử nghiệm với Linux,
nhưng Linux đã được cài đặt để thay thế hệ điều hành gốc (Windows hoặc OSX).

Nhóm lớn hơn là các hệ thống được thử nghiệm chỉ chạy Windows.  Không chỉ vậy,
nhưng nhiều phần mềm đã được thử nghiệm để chạy chỉ với một phiên bản Windows cụ thể.
Vì vậy, mặc dù BIOS có thể sử dụng _OSI để truy vấn phiên bản Windows đang chạy,
chỉ có một đường dẫn duy nhất xuyên qua BIOS thực sự đã được thử nghiệm.
Kinh nghiệm cho thấy rằng việc đi theo những con đường chưa được kiểm tra qua BIOS
khiến Linux gặp toàn bộ danh mục lỗi BIOS.
Vì lý do này, các mặc định của Linux _OSI phải tiếp tục yêu cầu khả năng tương thích
với mọi phiên bản Windows.

Nhưng Linux thực sự không tương thích với Windows và cộng đồng Linux
cũng bị ảnh hưởng bởi sự hồi quy khi Linux bổ sung phiên bản mới nhất của
Windows vào danh sách các chuỗi _OSI của nó.  Vì vậy, có thể các chuỗi bổ sung
sẽ được xem xét kỹ lưỡng hơn trước khi vận chuyển ngược dòng trong tương lai.
Nhưng có khả năng là cuối cùng tất cả chúng sẽ được thêm vào.

OEM nên làm gì nếu muốn hỗ trợ Linux và Windows
sử dụng cùng một hình ảnh BIOS?  Thường thì họ cần phải làm điều gì đó khác biệt
để Linux giải quyết Linux khác với Windows như thế nào.

Trong trường hợp này, OEM sẽ tạo ASL tùy chỉnh để được thực thi bởi
Nhân Linux và các thay đổi đối với trình điều khiển nhân Linux để thực thi tùy chỉnh này
ASL.  Cách dễ nhất để thực hiện điều này là giới thiệu một thiết bị cụ thể
phương thức (_DSM) được gọi từ nhân Linux.

Trước đây kernel được sử dụng để hỗ trợ những thứ như:
_OSI("Linux-OEM-my_interface_name")
trong đó cần có 'OEM' nếu đây là hook dành riêng cho OEM,
và 'my_interface_name' mô tả hook, có thể là một
sự khác thường, một lỗi hoặc một bản sửa lỗi.

Tuy nhiên điều này đã bị phát hiện bị các nhà cung cấp BIOS khác lạm dụng để thay đổi
mã hoàn toàn không liên quan trên các hệ thống hoàn toàn không liên quan.  Điều này đã thúc đẩy
đánh giá tất cả các công dụng của nó. Điều này phát hiện ra rằng họ không cần thiết
vì bất kỳ lý do ban đầu nào. Như vậy, kernel sẽ không phản hồi với
bất kỳ chuỗi Linux-* tùy chỉnh nào theo mặc định.

Điều đó thật dễ dàng.  Hãy đọc tiếp để biết cách làm sai.

Trước _OSI đã có _OS
==========================

ACPI 1.0 đã chỉ định "_OS" làm
"đối tượng đánh giá thành một chuỗi xác định hệ điều hành."

Luồng ACPI BIOS sẽ bao gồm đánh giá _OS và AML
trình thông dịch trong kernel sẽ trả về cho nó một chuỗi xác định hệ điều hành:

Windows 98, SE: "Microsoft Windows"
Windows ME: "Microsoft WindowsME:Phiên bản thiên niên kỷ"
Windows NT: "Microsoft Windows NT"

Ý tưởng là trên một nền tảng có nhiệm vụ chạy nhiều hệ điều hành,
BIOS có thể sử dụng _OS để kích hoạt các thiết bị có hệ điều hành
có thể hỗ trợ hoặc kích hoạt các điểm kỳ quặc hoặc cách giải quyết lỗi
cần thiết để làm cho nền tảng tương thích với hệ điều hành có sẵn đó.

Nhưng _OS có những vấn đề cơ bản.  Đầu tiên BIOS cần biết tên
của mọi phiên bản hệ điều hành có thể chạy trên nó và cần biết
tất cả những điều kỳ quặc của những hệ điều hành đó.  Chắc chắn sẽ có ý nghĩa hơn
để BIOS hỏi ZZ0000ZZ những điều về hệ điều hành, chẳng hạn như
"bạn có hỗ trợ giao diện cụ thể không" và do đó trong ACPI 3.0,
_OSI ra đời để thay thế _OS.

_OS đã bị bỏ rơi, mặc dù cho đến ngày nay, nhiều BIOS vẫn đang tìm kiếm
_OS "Microsoft Windows NT", mặc dù nó có vẻ hơi xa vời
rằng bất cứ ai cũng sẽ cài đặt những hệ điều hành cũ đó
về những gì đi kèm với máy.

Linux trả lời "Microsoft Windows NT" để làm hài lòng thành ngữ BIOS đó.
Đó là chiến lược khả thi của ZZ0000ZZ, cũng như những gì Windows hiện đại thực hiện,
và làm như vậy có thể khiến BIOS đi theo con đường chưa được thử nghiệm.

_OSI ra đời và ngay lập tức bị lạm dụng
=====================================

Với _OSI, ZZ0000ZZ cung cấp chuỗi mô tả giao diện,
và hỏi HĐH: "YES/NO, bạn có tương thích với giao diện này không?"

ví dụ. _OSI("Mô hình nhiệt 3.0") sẽ trả về TRUE nếu HĐH biết cách
để xử lý các phần mở rộng nhiệt được thực hiện theo thông số kỹ thuật ACPI 3.0.
Một hệ điều hành cũ không biết về các tiện ích mở rộng đó sẽ trả lời FALSE,
và một hệ điều hành mới có thể trả về TRUE.

Đối với giao diện dành riêng cho hệ điều hành, thông số ACPI cho biết BIOS và hệ điều hành
đã đồng ý về một chuỗi có dạng như "Windows-interface_name".

Nhưng có hai điều tồi tệ đã xảy ra.  Đầu tiên, hệ sinh thái Windows sử dụng _OSI
không phải như được thiết kế mà là sự thay thế trực tiếp cho _OS -- xác định
phiên bản hệ điều hành chứ không phải là giao diện được hệ điều hành hỗ trợ.  Quả thực là đúng
ngay từ đầu, thông số ACPI 3.0 đã hệ thống hóa việc sử dụng sai mục đích này
trong mã ví dụ sử dụng _OSI("Windows 2001").

Việc lạm dụng này đã được thông qua và tiếp tục cho đến ngày nay.

Linux không có lựa chọn nào khác ngoài việc trả TRUE về _OSI("Windows 2001")
và những người kế nhiệm nó.  Làm khác đi hầu như sẽ đảm bảo phá vỡ
một BIOS chỉ được thử nghiệm với _OSI đó trả về TRUE.

Chiến lược này có vấn đề vì Linux không bao giờ tương thích hoàn toàn với
phiên bản Windows mới nhất và đôi khi phải mất hơn một năm
để giải quyết những điểm không tương thích.

Không chịu thua kém, cộng đồng Linux còn khiến mọi chuyện trở nên tồi tệ hơn khi trả lại TRUE
tới _OSI("Linux").  Làm như vậy còn tệ hơn cả việc lạm dụng Windows
của _OSI, vì "Linux" thậm chí không chứa bất kỳ thông tin phiên bản nào.
_OSI("Linux") đã khiến một số BIOS' gặp trục trặc do người viết BIOS
sử dụng nó trong các luồng BIOS chưa được kiểm tra.  Nhưng một số OEM đã sử dụng _OSI("Linux")
trong các luồng đã được thử nghiệm để hỗ trợ các tính năng thực của Linux.  Năm 2009, Linux
đã xóa _OSI("Linux") và thêm tham số cmdline để khôi phục nó
đối với các hệ thống cũ vẫn cần nó.  Thêm một bản in cảnh báo BIOS_BUG
cho tất cả BIOS gọi nó.

Không có BIOS nào nên sử dụng _OSI("Linux").

Kết quả là một chiến lược dành cho Linux để tối đa hóa khả năng tương thích với
ACPI BIOS được thử nghiệm trên máy Windows.  Có một nguy cơ thực sự
nói quá mức về khả năng tương thích đó; nhưng giải pháp thay thế thường là
thất bại thảm khốc do BIOS đi theo đường dẫn
chưa bao giờ được xác nhận theo hệ điều hành ZZ0000ZZ.

Không sử dụng _REV
===============

Kể từ khi _OSI("Linux") không còn nữa, một số người viết BIOS đã sử dụng _REV
để hỗ trợ sự khác biệt giữa Linux và Windows trong cùng một BIOS.

_REV đã được xác định trong ACPI 1.0 để trả về phiên bản ACPI
được hỗ trợ bởi HĐH và trình thông dịch OS AML.

Windows hiện đại trả về _REV = 2. Linux đã sử dụng ACPI_CA_SUPPORT_LEVEL,
sẽ tăng lên, dựa trên phiên bản của thông số kỹ thuật được hỗ trợ.

Thật không may, _REV cũng bị lạm dụng.  ví dụ. một số BIOS sẽ kiểm tra
cho _REV = 3, và làm gì đó cho Linux, nhưng khi Linux quay trở lại
_REV = 4, hỗ trợ đó đã bị phá vỡ.

Để giải quyết vấn đề này, Linux luôn trả về _REV = 2,
từ giữa năm 2015 trở đi.  Thông số kỹ thuật ACPI cũng sẽ được cập nhật
để phản ánh rằng _REV không được dùng nữa và luôn trả về 2.

Apple Mac và _OSI("Darwin")
============================

Trên nền tảng Mac của Apple, ACPI BIOS gọi _OSI("Darwin")
để xác định xem máy có đang chạy Apple OSX hay không.

Giống như chiến lược _OSI("ZZ0000ZZ") của Linux, Linux mặc định
trả lời YES tới _OSI("Darwin") để cho phép truy cập đầy đủ
tới phần cứng và các đường dẫn BIOS được xác thực mà OSX nhìn thấy.
Cũng giống như trên các nền tảng đã được Windows thử nghiệm, chiến lược này có rủi ro.

Bắt đầu từ Linux-3.18, kernel đã trả lời YES thành _OSI("Darwin")
nhằm mục đích kích hoạt hỗ trợ Mac Thunderbolt.  Hơn nữa,
nếu hạt nhân nhận thấy _OSI("Darwin") đang được gọi thì nó cũng
đã vô hiệu hóa tất cả _OSI("ZZ0000ZZ") để giữ cho máy Mac BIOS được viết kém
từ việc đi xuống các tổ hợp đường dẫn chưa được kiểm tra.

Thay đổi mặc định của Linux-3.18 đã gây ra tình trạng suy giảm nguồn trên máy Mac
máy tính xách tay và việc triển khai 3.18 không cho phép thay đổi
mặc định thông qua cmdline "acpi_osi=!Darwin".  Đã sửa lỗi Linux-4.7
khả năng sử dụng acpi_osi=!Darwin như một giải pháp thay thế và
chúng tôi hy vọng sẽ thấy hỗ trợ quản lý nguồn Mac Thunderbolt trong Linux-4.11.