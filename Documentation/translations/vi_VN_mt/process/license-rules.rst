.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/license-rules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _kernel_licensing:

Quy tắc cấp phép nhân Linux
============================

Hạt nhân Linux được cung cấp theo các điều khoản của GNU General Public
Chỉ phiên bản giấy phép 2 (GPL-2.0), như được cung cấp trong LICENSES/preferred/GPL-2.0,
với một ngoại lệ syscall rõ ràng được mô tả trong
LICENSES/ngoại lệ/Linux-syscall-note, như được mô tả trong tệp COPYING.

Tệp tài liệu này cung cấp mô tả về cách mỗi tệp nguồn
cần được chú thích để làm cho giấy phép của nó rõ ràng và rõ ràng.
Nó không thay thế giấy phép của Kernel.

Giấy phép được mô tả trong tệp COPYING áp dụng cho nguồn kernel
nói chung, mặc dù các tệp nguồn riêng lẻ có thể có giấy phép khác
được yêu cầu phải tương thích với GPL-2.0::

GPL-1.0+ : Giấy phép công cộng GNU v1.0 trở lên
    GPL-2.0+ : GNU Giấy phép Công cộng Chung v2.0 trở lên
    LGPL-2.0 : Thư viện GNU Giấy phép công cộng chung v2 chỉ
    LGPL-2.0+ : Giấy phép Công cộng Chung của Thư viện GNU v2 trở lên
    LGPL-2.1 : Chỉ GNU Giấy phép công cộng chung v2.1
    LGPL-2.1+ : GNU Giấy phép công cộng chung thấp hơn v2.1 trở lên

Ngoài ra, các tệp riêng lẻ có thể được cung cấp theo giấy phép kép,
ví dụ: một trong các biến thể GPL tương thích và theo một cách khác
giấy phép cho phép như BSD, MIT, v.v.

Các tệp tiêu đề API (UAPI) trong không gian người dùng, mô tả giao diện của
các chương trình không gian người dùng vào kernel là một trường hợp đặc biệt.  Theo
lưu ý trong tệp kernel COPYING, giao diện syscall là ranh giới rõ ràng,
không mở rộng các yêu cầu GPL cho bất kỳ phần mềm nào sử dụng nó để
giao tiếp với hạt nhân.  Bởi vì các tiêu đề UAPI phải được bao gồm
vào bất kỳ tệp nguồn nào tạo tệp thực thi chạy trên Linux
kernel, ngoại lệ phải được ghi lại bằng một biểu thức giấy phép đặc biệt.

Cách phổ biến để thể hiện giấy phép của tệp nguồn là thêm phần
khớp văn bản soạn sẵn vào nhận xét trên cùng của tệp.  do
định dạng, lỗi chính tả, v.v. những "bản soạn sẵn" này khó xác thực cho
các công cụ được sử dụng trong bối cảnh tuân thủ giấy phép.

Một cách thay thế cho văn bản soạn sẵn là sử dụng Dữ liệu gói phần mềm
Mã nhận dạng giấy phép Exchange (SPDX) trong mỗi tệp nguồn.  Giấy phép SPDX
số nhận dạng là những cách viết tắt chính xác và có thể phân tích cú pháp của máy đối với giấy phép
trong đó nội dung của tập tin được đóng góp.  Giấy phép SPDX
số nhận dạng được quản lý bởi Nhóm làm việc SPDX tại Linux Foundation và
đã được các đối tác trong toàn ngành, các nhà cung cấp công cụ và
các đội pháp lý.  Để biết thêm thông tin, xem ZZ0000ZZ

Nhân Linux yêu cầu mã định danh SPDX chính xác trong tất cả các tệp nguồn.
Các mã định danh hợp lệ được sử dụng trong kernel được giải thích trong phần
ZZ0000ZZ và đã được lấy từ SPDX chính thức
danh sách giấy phép tại ZZ0001ZZ cùng với văn bản giấy phép.

Cú pháp định danh giấy phép
---------------------------

1. Vị trí:

Mã định danh giấy phép SPDX trong các tệp hạt nhân sẽ được thêm vào lần đầu tiên
   dòng có thể có trong một tệp có thể chứa nhận xét.  Đối với đa số
   của các tập tin, đây là dòng đầu tiên, ngoại trừ các tập lệnh yêu cầu
   '#!PATH_TO_INTERPRETER' ở dòng đầu tiên.  Đối với những tập lệnh đó, SPDX
   mã định danh đi vào dòng thứ hai.

|

2. Phong cách:

Mã định danh giấy phép SPDX được thêm vào dưới dạng nhận xét.  Bình luận
   phong cách phụ thuộc vào loại tập tin::

Nguồn C: // SPDX-Mã định danh giấy phép: <Biểu thức giấy phép SPDX>
      Tiêu đề C: /* SPDX-Lilicense-Identifier: <SPDX License Expression> */
      ASM: /* SPDX-Mã định danh giấy phép: <SPDX Biểu thức giấy phép> */
      tập lệnh: # ZZ0007ZZ-License-Identifier: <Biểu thức giấy phépSPDX>
      .rst: .. SPDX-Mã định danh giấy phép: <Biểu thức giấy phépSPDX>
      .dts{i}: // SPDX-Mã định danh giấy phép: <Biểu thức giấy phépSPDX>

Nếu một công cụ cụ thể không thể xử lý kiểu nhận xét tiêu chuẩn thì
   phải sử dụng cơ chế nhận xét thích hợp mà công cụ chấp nhận. Cái này
   là lý do có nhận xét kiểu "/\* \*/" trong tiêu đề C
   tập tin. Đã xảy ra sự cố bản dựng với các tệp .lds được tạo trong đó
   'ld' không phân tích được nhận xét C++. Điều này hiện đã được khắc phục nhưng
   vẫn còn những công cụ biên dịch mã cũ hơn không thể xử lý kiểu C++
   ý kiến.

|

3. Cú pháp:

<SPDX License Expression> là giấy phép dạng ngắn SPDX
   mã định danh được tìm thấy trên Danh sách giấy phép SPDX hoặc sự kết hợp của cả hai
   Số nhận dạng giấy phép dạng ngắn SPDX được phân tách bằng "WITH" khi giấy phép
   áp dụng ngoại lệ. Khi áp dụng nhiều giấy phép, một biểu thức bao gồm
   của các từ khóa "AND", "OR" tách các biểu thức phụ và được bao quanh bởi
   "(", ")" .

Mã nhận dạng giấy phép cho các giấy phép như [L]GPL với tùy chọn 'hoặc mới hơn'
   được xây dựng bằng cách sử dụng dấu "+" để biểu thị tùy chọn 'hoặc mới hơn'.::

// SPDX-Mã định danh giấy phép: GPL-2.0+
      // SPDX-Mã định danh giấy phép: LGPL-2.1+

WITH nên được sử dụng khi cần có công cụ sửa đổi giấy phép.
   Ví dụ: các tệp UAPI của kernel linux sử dụng biểu thức ::

// SPDX-Mã định danh giấy phép: GPL-2.0 WITH Linux-syscall-note
      // SPDX-Mã định danh giấy phép: GPL-2.0+ WITH Linux-syscall-note

Các ví dụ khác sử dụng ngoại lệ WITH được tìm thấy trong kernel là::

// SPDX-Mã định danh giấy phép: GPL-2.0 WITH ngoại lệ mif
      // SPDX-Mã định danh giấy phép: GPL-2.0+ WITH GCC-ngoại lệ-2.0

Các ngoại lệ chỉ có thể được sử dụng với số nhận dạng Giấy phép cụ thể. các
   số nhận dạng giấy phép hợp lệ được liệt kê trong các thẻ của văn bản ngoại lệ
   tập tin. Để biết chi tiết, hãy xem điểm ZZ0000ZZ trong chương ZZ0001ZZ.

HOẶC nên được sử dụng nếu tệp được cấp phép kép và chỉ có một giấy phép
   để được chọn.  Ví dụ: một số tệp dtsi có sẵn ở chế độ kép
   giấy phép::

// SPDX-Mã định danh giấy phép: GPL-2.0 HOẶC BSD-3-Clause

Ví dụ từ kernel cho các biểu thức giấy phép trong các tệp được cấp phép kép::

// SPDX-Mã định danh giấy phép: GPL-2.0 HOẶC MIT
      // SPDX-Mã định danh giấy phép: GPL-2.0 HOẶC BSD-2-Clause
      // SPDX-Mã định danh giấy phép: GPL-2.0 HOẶC Apache-2.0
      // SPDX-Mã định danh giấy phép: GPL-2.0 HOẶC MPL-1.1
      // SPDX-Mã định danh giấy phép: (GPL-2.0 WITH Linux-syscall-note) HOẶC MIT
      // SPDX-Mã định danh giấy phép: GPL-1.0+ HOẶC BSD-3-Clause HOẶC OpenSSL

Nên sử dụng AND nếu tệp có nhiều giấy phép có tất cả các điều khoản
   áp dụng để sử dụng tập tin. Ví dụ: nếu mã được kế thừa từ một mã khác
   dự án và quyền đã được cấp để đặt nó vào kernel, nhưng
   điều khoản cấp phép ban đầu cần phải có hiệu lực::

// SPDX-Mã định danh giấy phép: (GPL-2.0 WITH Linux-syscall-note) AND MIT

Một ví dụ khác trong đó cả hai bộ điều khoản cấp phép cần phải được
   tuân thủ là::

// SPDX-Mã định danh giấy phép: GPL-1.0+ AND LGPL-2.1+

Mã nhận dạng giấy phép
----------------------

Các giấy phép hiện đang được sử dụng cũng như các giấy phép cho mã được thêm vào
hạt nhân, có thể được chia thành:

1. _ZZ0000ZZ:

Bất cứ khi nào có thể, những giấy phép này nên được sử dụng vì chúng được biết là
   hoàn toàn tương thích và được sử dụng rộng rãi.  Các giấy phép này có sẵn từ
   thư mục::

LICENSES/ưu tiên/

trong cây nguồn kernel.

Các tập tin trong thư mục này chứa văn bản giấy phép đầy đủ và
   ZZ0000ZZ.  Tên file giống hệt với giấy phép SPDX
   mã định danh sẽ được sử dụng cho giấy phép trong các tệp nguồn.

Ví dụ::

LICENSES/ưa thích/GPL-2.0

Chứa văn bản giấy phép GPL phiên bản 2 và các thẻ meta bắt buộc::

LICENSES/ưa thích/MIT

Chứa văn bản giấy phép MIT và các thẻ meta bắt buộc

_ZZ0000ZZ:

Các thẻ meta sau phải có sẵn trong tệp giấy phép:

- Mã định danh giấy phép hợp lệ:

Một hoặc nhiều dòng khai báo Số nhận dạng giấy phép nào hợp lệ
     bên trong dự án để tham chiếu văn bản giấy phép cụ thể này.  Thông thường
     đây là một mã định danh hợp lệ duy nhất, nhưng ví dụ: đối với các giấy phép có 'hoặc
     các tùy chọn sau', hai mã định danh hợp lệ.

- SPDX-URL:

URL của trang SPDX chứa thông tin bổ sung liên quan
     đến giấy phép.

- Hướng dẫn sử dụng:

Văn bản dạng tự do để được tư vấn sử dụng. Văn bản phải bao gồm các ví dụ chính xác
     đối với số nhận dạng giấy phép SPDX vì chúng phải được đưa vào nguồn
     các tập tin theo hướng dẫn ZZ0000ZZ.

- Văn bản giấy phép:

Tất cả văn bản sau thẻ này được coi là văn bản giấy phép gốc

Ví dụ về định dạng tệp::

Mã định danh giấy phép hợp lệ: GPL-2.0
      Mã định danh giấy phép hợp lệ: GPL-2.0+
      SPDX-URL: ZZ0000ZZ
      Hướng dẫn sử dụng:
        Để sử dụng giấy phép này trong mã nguồn, hãy đặt một trong các SPDX sau
	cặp thẻ/giá trị vào nhận xét theo vị trí
	hướng dẫn trong tài liệu quy tắc cấp phép.
	Đối với 'Chỉ dành cho Giấy phép Công cộng GNU (GPL) phiên bản 2', hãy sử dụng:
	  SPDX-Mã định danh giấy phép: GPL-2.0
	Đối với 'GNU Giấy phép Công cộng Chung (GPL) phiên bản 2 hoặc bất kỳ phiên bản nào mới hơn', hãy sử dụng:
	  SPDX-Mã định danh giấy phép: GPL-2.0+
      Văn bản giấy phép:
        Văn bản giấy phép đầy đủ

   ::

SPDX-Mã định danh giấy phép: MIT
      SPDX-URL: ZZ0000ZZ
      Hướng dẫn sử dụng:
	Để sử dụng giấy phép này trong mã nguồn, hãy đặt SPDX sau
	cặp thẻ/giá trị vào nhận xét theo vị trí
	hướng dẫn trong tài liệu quy tắc cấp phép.
	  SPDX-Mã định danh giấy phép: MIT
      Văn bản giấy phép:
        Văn bản giấy phép đầy đủ

|

2. Giấy phép không còn được dùng nữa:

Những giấy phép này chỉ nên được sử dụng cho mã hiện có hoặc để nhập
   mã từ một dự án khác.  Các giấy phép này có sẵn từ
   thư mục::

LICENSES/không được dùng nữa/

trong cây nguồn kernel.

Các tập tin trong thư mục này chứa văn bản giấy phép đầy đủ và
   ZZ0000ZZ.  Tên file giống hệt với giấy phép SPDX
   mã định danh sẽ được sử dụng cho giấy phép trong các tệp nguồn.

Ví dụ::

LICENSES/không được dùng nữa/ISC

Chứa văn bản giấy phép của Hiệp hội Hệ thống Internet và các thông tin bắt buộc
   thẻ meta::

LICENSES/không dùng nữa/GPL-1.0

Chứa văn bản giấy phép GPL phiên bản 1 và các thẻ meta bắt buộc.

Thẻ meta:

Các yêu cầu về thẻ meta cho giấy phép 'khác' giống hệt với
   yêu cầu của ZZ0000ZZ.

Ví dụ về định dạng tệp::

Mã định danh giấy phép hợp lệ: ISC
      SPDX-URL: ZZ0000ZZ
      Hướng dẫn sử dụng:
        Việc sử dụng giấy phép này trong kernel cho mã mới không được khuyến khích
	và nó chỉ nên được sử dụng để nhập mã từ một
	dự án hiện có.
        Để sử dụng giấy phép này trong mã nguồn, hãy đặt SPDX sau
	cặp thẻ/giá trị vào nhận xét theo vị trí
	hướng dẫn trong tài liệu quy tắc cấp phép.
	  SPDX-Mã định danh giấy phép: ISC
      Văn bản giấy phép:
        Văn bản giấy phép đầy đủ

|

3. Chỉ cấp phép kép

Những giấy phép này chỉ nên được sử dụng để mã giấy phép kép với một giấy phép khác
   giấy phép ngoài giấy phép ưu tiên.  Những giấy phép này có sẵn
   từ thư mục::

LICENSES/kép/

trong cây nguồn kernel.

Các tập tin trong thư mục này chứa văn bản giấy phép đầy đủ và
   ZZ0000ZZ.  Tên file giống hệt với giấy phép SPDX
   mã định danh sẽ được sử dụng cho giấy phép trong các tệp nguồn.

Ví dụ::

LICENSES/kép/MPL-1.1

Chứa văn bản giấy phép Mozilla Public License phiên bản 1.1 và
   thẻ meta bắt buộc::

LICENSES/kép/Apache-2.0

Chứa văn bản giấy phép Apache phiên bản 2.0 và các thông tin bắt buộc
   thẻ meta.

Thẻ meta:

Các yêu cầu về thẻ meta cho giấy phép 'khác' giống hệt với
   yêu cầu của ZZ0000ZZ.

Ví dụ về định dạng tệp::

Mã định danh giấy phép hợp lệ: MPL-1.1
      SPDX-URL: ZZ0000ZZ
      Hướng dẫn sử dụng:
        Có sử dụng NOT không. MPL-1.1 không tương thích với GPL2. Nó chỉ có thể được sử dụng cho
        các tệp được cấp phép kép trong đó giấy phép còn lại tương thích với GPL2.
        Nếu bạn kết thúc việc sử dụng cái này, hãy sử dụng MUST cùng với GPL2 tương thích
        giấy phép sử dụng "HOẶC".
        Để sử dụng Giấy phép Công cộng Mozilla phiên bản 1.1, hãy đặt SPDX sau đây
        cặp thẻ/giá trị vào nhận xét theo nguyên tắc vị trí trong
        tài liệu về quy tắc cấp phép:
      SPDX-Mã định danh giấy phép: MPL-1.1
      Văn bản giấy phép:
        Văn bản giấy phép đầy đủ

|

4. _ZZ0000ZZ:

Một số giấy phép có thể được sửa đổi với những ngoại lệ cấp một số quyền nhất định
   mà giấy phép ban đầu không có.  Những ngoại lệ này có sẵn
   từ thư mục::

LICENSES/ngoại lệ/

trong cây nguồn kernel.  Các tập tin trong thư mục này chứa đầy đủ
   văn bản ngoại lệ và ZZ0000ZZ được yêu cầu.

Ví dụ::

LICENSES/ngoại lệ/Linux-syscall-note

Chứa ngoại lệ tòa nhà Linux như được ghi lại trong COPYING
   tệp của nhân Linux, được sử dụng cho các tệp tiêu đề UAPI.
   ví dụ. /\* SPDX-Mã định danh giấy phép: GPL-2.0 WITH Linux-syscall-note \*/::

LICENSES/ngoại lệ/GCC-ngoại lệ-2.0

Chứa 'ngoại lệ liên kết' GCC cho phép liên kết bất kỳ tệp nhị phân nào
   độc lập với giấy phép của nó đối với phiên bản đã biên dịch của tệp được đánh dấu
   với ngoại lệ này. Điều này là cần thiết để tạo các tệp thực thi có thể chạy được
   từ mã nguồn không tương thích với GPL.

_ZZ0000ZZ:

Các thẻ meta sau phải có sẵn trong một tệp ngoại lệ:

- Mã định danh ngoại lệ SPDX:

Một mã định danh ngoại lệ có thể được sử dụng với giấy phép SPDX
     số nhận dạng.

- SPDX-URL:

URL của trang SPDX chứa thông tin bổ sung liên quan
     đến ngoại lệ.

- SPDX-Giấy phép:

Danh sách các số nhận dạng giấy phép SPDX được phân tách bằng dấu phẩy mà
     ngoại lệ có thể được sử dụng.

- Hướng dẫn sử dụng:

Văn bản dạng tự do để được tư vấn sử dụng. Văn bản phải được theo sau bởi chính xác
     ví dụ về số nhận dạng giấy phép SPDX khi chúng nên được đưa vào
     tập tin nguồn theo hướng dẫn ZZ0000ZZ.

- Văn bản ngoại lệ:

Tất cả văn bản sau thẻ này được coi là văn bản ngoại lệ ban đầu

Ví dụ về định dạng tệp::

SPDX-Mã định danh ngoại lệ: Linux-syscall-note
      SPDX-URL: ZZ0000ZZ
      SPDX-Giấy phép: GPL-2.0, GPL-2.0+, GPL-1.0+, LGPL-2.0, LGPL-2.0+, LGPL-2.1, LGPL-2.1+
      Hướng dẫn sử dụng:
        Ngoại lệ này được sử dụng cùng với một trong các Giấy phép SPDX ở trên
	để đánh dấu các tệp tiêu đề API (uapi) trong không gian người dùng để có thể đưa chúng vào
	vào mã ứng dụng không gian người dùng không tuân thủ GPL.
        Để sử dụng ngoại lệ này, hãy thêm nó với từ khóa WITH vào một trong các
	số nhận dạng trong thẻ Giấy phép SPDX:
	  SPDX-Mã định danh giấy phép: <SPDX-Lilicense> WITH Linux-syscall-note
      Văn bản ngoại lệ:
        Toàn văn ngoại lệ

   ::

SPDX-Mã định danh ngoại lệ: GCC-ngoại lệ-2.0
      SPDX-URL: ZZ0000ZZ
      SPDX-Giấy phép: GPL-2.0, GPL-2.0+
      Hướng dẫn sử dụng:
        "GCC Ngoại lệ thư viện thời gian chạy 2.0" được sử dụng cùng với một
	trong số các Giấy phép SPDX ở trên cho mã được nhập từ thời gian chạy GCC
	thư viện.
        Để sử dụng ngoại lệ này, hãy thêm nó với từ khóa WITH vào một trong các
	số nhận dạng trong thẻ Giấy phép SPDX:
	  SPDX-Mã định danh giấy phép: <SPDX-Lilicense> WITH GCC-ngoại lệ-2.0
      Văn bản ngoại lệ:
        Toàn văn ngoại lệ


Tất cả các mã định danh và ngoại lệ giấy phép SPDX phải có tệp tương ứng
trong thư mục con LICENSES. Điều này là cần thiết để cho phép công cụ
xác minh (ví dụ: checkpatch.pl) và chuẩn bị sẵn giấy phép để đọc
và trích xuất ngay từ nguồn, được nhiều FOSS khuyên dùng
các tổ chức, ví dụ: ZZ0000ZZ.

_ZZ0000ZZ
-----------------

Các mô-đun hạt nhân có thể tải cũng yêu cầu thẻ MODULE_LICENSE(). Thẻ này là
   không phải là sự thay thế cho thông tin giấy phép mã nguồn thích hợp
   (SPDX-Mã định danh giấy phép) cũng như không có bất kỳ cách nào liên quan đến việc thể hiện hoặc
   xác định giấy phép chính xác theo đó mã nguồn của mô-đun
   được cung cấp.

Mục đích duy nhất của thẻ này là cung cấp đầy đủ thông tin
   mô-đun này là phần mềm miễn phí hay độc quyền cho hạt nhân
   trình tải mô-đun và cho các công cụ không gian người dùng.

Chuỗi giấy phép hợp lệ cho MODULE_LICENSE() là:

================================================================================
    Mô-đun "GPL" được cấp phép theo GPL phiên bản 2. Điều này
				  không thể hiện bất kỳ sự phân biệt nào giữa
				  Chỉ GPL-2.0 hoặc GPL-2.0 trở lên. Chính xác
				  thông tin giấy phép chỉ có thể được xác định
				  thông qua thông tin giấy phép trong
				  các tập tin nguồn tương ứng.

"GPL v2" Tương tự như "GPL". Nó tồn tại vì lịch sử
				  lý do.

"GPL và các quyền bổ sung" Biến thể lịch sử của việc thể hiện rằng
				  nguồn mô-đun được cấp phép kép theo một
				  Biến thể GPL v2 và giấy phép MIT. Xin vui lòng làm
				  không sử dụng trong mã mới.

"Dual MIT/GPL" Cách diễn đạt chính xác rằng
				  mô-đun được cấp phép kép theo GPL v2
				  lựa chọn giấy phép biến thể hoặc MIT.

"Dual BSD/GPL" Mô-đun này được cấp phép kép theo GPL v2
				  lựa chọn giấy phép biến thể hoặc BSD. Chính xác
				  biến thể của giấy phép BSD chỉ có thể
				  được xác định thông qua thông tin giấy phép
				  trong các tập tin nguồn tương ứng.

"Dual MPL/GPL" Mô-đun này được cấp phép kép theo GPL v2
				  biến thể hoặc Giấy phép Công cộng Mozilla (MPL)
				  sự lựa chọn. Biến thể chính xác của MPL
				  giấy phép chỉ có thể được xác định thông qua
				  thông tin giấy phép tương ứng
				  các tập tin nguồn.

"Độc quyền" Mô-đun này có giấy phép độc quyền.
				  “Độc quyền” chỉ được hiểu là
				  "Giấy phép không tương thích với GPLv2".
                                  Chuỗi này chỉ dành cho không tương thích với GPL2
                                  mô-đun của bên thứ ba và không thể được sử dụng cho
                                  các mô-đun có mã nguồn của chúng trong
                                  cây hạt nhân. Các mô-đun được gắn thẻ theo cách đó là
                                  làm hỏng kernel bằng cờ 'P' khi
                                  đã tải và trình tải mô-đun hạt nhân từ chối
                                  để liên kết các mô-đun như vậy với các ký hiệu
                                  được xuất với EXPORT_SYMBOL_GPL().
    ================================================================================


