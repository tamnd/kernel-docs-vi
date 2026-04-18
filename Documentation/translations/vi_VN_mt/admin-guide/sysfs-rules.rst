.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/sysfs-rules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Quy tắc về cách truy cập thông tin trong sysfs
===========================================

Các sysfs xuất kernel xuất chi tiết triển khai kernel nội bộ
và phụ thuộc vào cấu trúc và cách bố trí hạt nhân bên trong. Nó đã được thỏa thuận
bởi các nhà phát triển hạt nhân rằng hạt nhân Linux không cung cấp một hệ thống ổn định
API nội bộ. Vì vậy, có những khía cạnh của giao diện sysfs
có thể không ổn định trên các bản phát hành kernel.

Để giảm thiểu nguy cơ phá vỡ người dùng sysfs, trong hầu hết các trường hợp
các ứng dụng không gian người dùng cấp thấp, với bản phát hành kernel mới, người dùng
của sysfs phải tuân theo một số quy tắc để sử dụng một cách trừu tượng nhất có thể để
truy cập hệ thống tập tin này. Các chương trình udev và HAL hiện tại đã có
thực hiện điều này và người dùng được khuyến khích cắm, nếu có thể, vào
sự trừu tượng hóa mà các chương trình này cung cấp thay vì truy cập trực tiếp vào sysfs.

Nhưng nếu bạn thực sự muốn hoặc cần truy cập trực tiếp vào sysfs, hãy làm theo
các quy tắc sau và sau đó chương trình của bạn sẽ hoạt động với tương lai
phiên bản của giao diện sysfs.

- Không sử dụng libsysfs
    Nó đưa ra các giả định về sysfs không đúng sự thật. API của nó không
    cung cấp bất kỳ sự trừu tượng nào, nó sẽ hiển thị tất cả lõi trình điều khiển kernel
    chi tiết triển khai trong API của riêng nó. Vì thế nó không tốt hơn
    đọc thư mục và tự mở tập tin.
    Ngoài ra, nó không được duy trì tích cực theo nghĩa phản ánh
    phát triển hạt nhân hiện nay. Mục tiêu cung cấp giao diện ổn định
    tới sysfs đã thất bại; nó gây ra nhiều vấn đề hơn là giải quyết được. Nó
    vi phạm nhiều quy tắc trong tài liệu này.

- sysfs luôn ở ZZ0000ZZ
    Phân tích cú pháp ZZ0001ZZ là một sự lãng phí thời gian. Các điểm gắn kết khác là
    lỗi cấu hình hệ thống bạn không nên cố gắng giải quyết. Đối với các trường hợp thử nghiệm,
    có thể hỗ trợ biến môi trường ZZ0002ZZ để ghi đè
    hành vi của ứng dụng, nhưng đừng bao giờ thử tìm kiếm sysfs. Đừng bao giờ thử
    để gắn kết nó, nếu bạn không phải là tập lệnh khởi động sớm.

- thiết bị chỉ là "thiết bị"
    Không có những thứ như lớp, xe buýt, thiết bị vật lý,
    các giao diện mà bạn có thể dựa vào trong không gian người dùng. Mọi thứ đều
    chỉ đơn giản là một "thiết bị". Các loại lớp, xe buýt, vật lý, ... chỉ là
    chi tiết triển khai kernel mà người dùng không mong đợi
    các ứng dụng tìm kiếm thiết bị trong sysfs.

Các thuộc tính của một thiết bị là:

- đường dẫn dành cho nhà phát triển (ZZ0000ZZ)

- giống với giá trị DEVPATH trong sự kiện được gửi từ kernel
        khi tạo và xóa thiết bị
      - khóa duy nhất cho thiết bị tại thời điểm đó
      - đường dẫn của kernel đến thư mục thiết bị không có phần đầu
        ZZ0000ZZ và luôn bắt đầu bằng dấu gạch chéo
      - tất cả các thành phần của devpath phải là thư mục thực. Liên kết tượng trưng
        việc trỏ đến/sys/thiết bị phải luôn được phân giải theo địa chỉ thực của chúng
        target và đường dẫn đích phải được sử dụng để truy cập thiết bị.
        Bằng cách đó, đường dẫn phát triển của thiết bị khớp với đường dẫn phát triển của thiết bị
        kernel được sử dụng tại thời điểm sự kiện.
      - sử dụng hoặc hiển thị các giá trị liên kết tượng trưng dưới dạng các phần tử trong chuỗi đường dẫn dành cho nhà phát triển
        là một lỗi trong ứng dụng

- tên hạt nhân (ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ...)

- tên thư mục, giống với phần tử cuối cùng của devpath
      - các ứng dụng cần xử lý khoảng trắng và ký tự như ZZ0000ZZ trong
        cái tên

- hệ thống con (ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ...)

- chuỗi đơn giản, không bao giờ là đường dẫn hoặc liên kết
      - được truy xuất bằng cách đọc liên kết "hệ thống con" và chỉ sử dụng
        phần tử cuối cùng của đường dẫn đích

- trình điều khiển (ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ)

- một chuỗi đơn giản, có thể chứa khoảng trắng, không bao giờ có đường dẫn hoặc
        liên kết
      - nó được truy xuất bằng cách đọc liên kết "trình điều khiển" và chỉ sử dụng
        phần tử cuối cùng của đường dẫn đích
      - các thiết bị không có liên kết "trình điều khiển" không có
        người lái xe; sao chép giá trị trình điều khiển trong ngữ cảnh thiết bị con là một
        lỗi trong ứng dụng

- thuộc tính

- các tập tin trong thư mục thiết bị hoặc các tập tin bên dưới thư mục con
        của cùng một thư mục thiết bị
      - truy cập các thuộc tính đạt được bằng một liên kết tượng trưng trỏ đến một thiết bị khác,
        giống như liên kết "thiết bị", là một lỗi trong ứng dụng

Mọi thứ khác chỉ là chi tiết triển khai lõi trình điều khiển kernel
    điều đó không nên được coi là ổn định trên các bản phát hành kernel.

- Thuộc tính của thiết bị mẹ không bao giờ thuộc về thiết bị con.
    Luôn nhìn vào thiết bị gốc để xác định thiết bị
    thuộc tính ngữ cảnh. Nếu thiết bị ZZ0000ZZ hoặc ZZ0001ZZ không có
    "driver"-link thì thiết bị này không có driver. Giá trị của nó trống rỗng.
    Không bao giờ sao chép bất kỳ thuộc tính nào của thiết bị gốc vào thiết bị con. cha mẹ
    thuộc tính của thiết bị có thể thay đổi linh hoạt mà không cần thông báo trước cho
    thiết bị con.

- Phân cấp trong một cây thiết bị duy nhất
    Chỉ có một vị trí hợp lệ trong sysfs nơi có thể kiểm tra hệ thống phân cấp
    và đây là bên dưới: ZZ0000ZZ
    Theo kế hoạch, tất cả các thư mục thiết bị sẽ ở dạng cây
    bên dưới thư mục này.

- Phân loại theo hệ thống con
    Hiện tại có ba nơi để phân loại thiết bị:
    ZZ0000ZZ ZZ0001ZZ và ZZ0002ZZ Theo kế hoạch, những thứ này sẽ
    không chứa bất kỳ thư mục thiết bị nào mà chỉ chứa các danh sách phẳng
    các liên kết tượng trưng trỏ đến cây ZZ0003ZZ hợp nhất.
    Cả 3 nơi đều có quy định hoàn toàn khác nhau về cách vào
    thông tin thiết bị. Dự kiến sáp nhập cả ba
    thư mục phân loại vào một nơi tại ZZ0004ZZ,
    theo cách bố trí của các thư mục xe buýt. Tất cả xe buýt và
    các lớp, bao gồm cả hệ thống con khối được chuyển đổi, sẽ hiển thị
    ở đó.
    Các thiết bị thuộc hệ thống con sẽ tạo một liên kết tượng trưng trong
    thư mục "thiết bị" tại ZZ0005ZZ,

Nếu ZZ0000ZZ tồn tại, ZZ0001ZZ, ZZ0002ZZ và ZZ0003ZZ
    có thể được bỏ qua. Nếu nó không tồn tại, bạn luôn phải quét cả ba
    nơi, vì kernel có thể tự do di chuyển một hệ thống con từ nơi này sang nơi khác
    cái kia, miễn là các thiết bị vẫn có thể truy cập được bằng cùng một
    tên hệ thống con.

Giả sử ZZ0000ZZ và ZZ0001ZZ, hoặc
    ZZ0002ZZ và ZZ0003ZZ không thể thay thế cho nhau là một lỗi trong
    ứng dụng.

- Chặn
    Hệ thống con khối được chuyển đổi tại ZZ0000ZZ hoặc
    ZZ0001ZZ sẽ chứa các liên kết cho đĩa và phân vùng
    ở cùng cấp độ, không bao giờ theo thứ bậc. Giả sử hệ thống con khối
    chỉ chứa các đĩa và không chứa các thiết bị phân vùng trong cùng một danh sách phẳng
    một lỗi trong ứng dụng.

- "device"-link và <subsystem>:<kernel name>-links
    Không bao giờ phụ thuộc vào liên kết "thiết bị". Liên kết "thiết bị" là một cách giải quyết
    đối với bố cục cũ, nơi các thiết bị lớp không được tạo trong
    ZZ0000ZZ giống như các thiết bị xe buýt. Nếu việc giải quyết liên kết của một
    device directory does not end in ZZ0001ZZ, you can use the
    "thiết bị"-liên kết để tìm các thiết bị mẹ trong ZZ0002ZZ, Đó là
    việc sử dụng hợp lệ duy nhất liên kết "thiết bị"; nó không bao giờ được xuất hiện trong bất kỳ
    đường dẫn như một phần tử. Giả sử sự tồn tại của liên kết "thiết bị" cho
    một thiết bị trong ZZ0003ZZ là một lỗi trong ứng dụng.
    Truy cập ZZ0004ZZ là một lỗi trong ứng dụng.

Không bao giờ phụ thuộc vào các liên kết dành riêng cho từng lớp quay lại ZZ0000ZZ
    thư mục.  Các liên kết này cũng là cách giải quyết lỗi thiết kế
    các thiết bị lớp đó không được tạo trong ZZ0001ZZ Nếu một thiết bị
    thư mục không chứa thư mục cho các thiết bị con, các liên kết này
    có thể được sử dụng để tìm các thiết bị con trong ZZ0002ZZ Đó là thiết bị duy nhất
    sử dụng hợp lệ các liên kết này; chúng không bao giờ được xuất hiện trong bất kỳ con đường nào với tư cách là một
    phần tử. Giả sử sự tồn tại của các liên kết này cho các thiết bị
    thư mục thiết bị con thực sự trong cây ZZ0003ZZ là một lỗi trong
    ứng dụng.

Dự định sẽ loại bỏ tất cả các liên kết này khi tất cả các thiết bị lớp
    thư mục trực tiếp trong ZZ0000ZZ

- Vị trí của các thiết bị dọc theo chuỗi thiết bị có thể thay đổi.
    Không bao giờ phụ thuộc vào vị trí thiết bị gốc cụ thể trong đường dẫn phát triển,
    hoặc chuỗi thiết bị gốc. Kernel có thể tự do chèn thiết bị vào
    chuỗi. Bạn phải luôn yêu cầu thiết bị gốc mà bạn đang tìm kiếm
    bởi giá trị hệ thống con của nó. Bạn cần phải đi lên dãy này cho đến khi tìm thấy
    thiết bị phù hợp với hệ thống con dự kiến. Tùy thuộc vào một cụ thể
    vị trí của thiết bị mẹ hoặc hiển thị các đường dẫn tương đối bằng ZZ0000ZZ tới
    truy cập vào chuỗi cha mẹ là một lỗi trong ứng dụng.

- Khi đọc và ghi file thuộc tính thiết bị sysfs, tránh phụ thuộc
    về các mã lỗi cụ thể bất cứ khi nào có thể. Điều này giảm thiểu việc ghép nối với
    việc triển khai xử lý lỗi trong kernel.

Nói chung, việc không thể đọc hoặc ghi các thuộc tính thiết bị sysfs sẽ
    tuyên truyền lỗi bất cứ nơi nào có thể. Các lỗi phổ biến bao gồm, nhưng không
    giới hạn ở:

ZZ0000ZZ: Thông thường, thao tác đọc hoặc lưu trữ không được hỗ trợ
	được chính hệ thống sysfs trả về nếu con trỏ đọc hoặc lưu trữ
	là ZZ0001ZZ.

ZZ0000ZZ: Thao tác đọc hoặc lưu trữ không thành công

Mã lỗi sẽ không được thay đổi nếu không có lý do chính đáng và nếu thay đổi
    mã lỗi dẫn đến gián đoạn không gian người dùng, nó sẽ được sửa hoặc
    thay đổi vi phạm sẽ được hoàn nguyên.

Tuy nhiên, các ứng dụng không gian người dùng có thể mong đợi định dạng và nội dung của
    các tệp thuộc tính vẫn nhất quán khi không có phiên bản
    thay đổi thuộc tính trong bối cảnh của một thuộc tính nhất định.
