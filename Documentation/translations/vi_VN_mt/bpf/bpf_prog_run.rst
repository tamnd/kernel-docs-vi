.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/bpf_prog_run.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Chạy các chương trình BPF từ không gian người dùng
==================================================

Tài liệu này mô tả cơ sở ZZ0000ZZ để chạy các chương trình BPF
từ không gian người dùng.

.. contents::
    :local:
    :depth: 2


Tổng quan
--------

Lệnh ZZ0000ZZ có thể được sử dụng thông qua tòa nhà ZZ0001ZZ để
thực thi chương trình BPF trong kernel và trả kết quả về không gian người dùng. Cái này
có thể được sử dụng để kiểm tra đơn vị các chương trình BPF dựa trên các đối tượng ngữ cảnh do người dùng cung cấp và
như một cách để thực thi rõ ràng các chương trình trong kernel để xử lý các tác dụng phụ của chúng. các
lệnh trước đây được đặt tên là ZZ0002ZZ và cả hai hằng số đều tiếp tục
được xác định trong tiêu đề UAPI, được đặt bí danh cho cùng một giá trị.

Lệnh ZZ0000ZZ có thể được sử dụng để thực thi các chương trình BPF của
các loại sau:

-ZZ0000ZZ
-ZZ0001ZZ
-ZZ0002ZZ
-ZZ0003ZZ
-ZZ0004ZZ
-ZZ0005ZZ
-ZZ0006ZZ
-ZZ0007ZZ
-ZZ0008ZZ
-ZZ0009ZZ
-ZZ0010ZZ
-ZZ0011ZZ
-ZZ0012ZZ
-ZZ0013ZZ
- ZZ0014ZZ

Khi sử dụng lệnh ZZ0000ZZ, không gian người dùng sẽ cung cấp bối cảnh đầu vào
đối tượng và (đối với các loại chương trình hoạt động trên các gói mạng) một bộ đệm chứa
dữ liệu gói mà chương trình BPF sẽ hoạt động. Sau đó hạt nhân sẽ
thực hiện chương trình và trả kết quả về không gian người dùng. Lưu ý rằng các chương trình sẽ
không có bất kỳ tác dụng phụ nào khi chạy ở chế độ này; đặc biệt là các gói
sẽ không thực sự được chuyển hướng hoặc loại bỏ, mã trả về của chương trình sẽ chỉ là
được trả về không gian người dùng. Một chế độ riêng biệt để thực hiện trực tiếp các chương trình XDP là
được cung cấp, ghi lại riêng biệt bên dưới.

Chạy các chương trình XDP ở "chế độ khung hình trực tiếp"
-----------------------------------------

Lệnh ZZ0000ZZ có chế độ riêng để chạy các chương trình XDP trực tiếp,
có thể được sử dụng để thực thi các chương trình XDP theo cách mà các gói sẽ thực sự
được xử lý bởi kernel sau khi thực hiện chương trình XDP như thể chúng
đến trên một giao diện vật lý. Chế độ này được kích hoạt bằng cách cài đặt
Cờ ZZ0001ZZ khi cung cấp chương trình XDP cho
ZZ0002ZZ.

Chế độ gói trực tiếp được tối ưu hóa để thực thi hiệu suất cao của gói được cung cấp
Chương trình XDP nhiều lần (thích hợp, ví dụ: chạy như một trình tạo lưu lượng),
điều đó có nghĩa là ngữ nghĩa không hoàn toàn đơn giản như bài kiểm tra thông thường
chế độ chạy. Cụ thể:

- Khi thực hiện chương trình XDP ở chế độ khung hình trực tiếp, kết quả thực hiện
  sẽ không được trả lại không gian người dùng; thay vào đó, kernel sẽ thực hiện
  hoạt động được biểu thị bằng mã trả về của chương trình (bỏ gói, chuyển hướng
  nó, v.v.). Vì lý do này, việc đặt thuộc tính ZZ0000ZZ hoặc ZZ0001ZZ
  trong các tham số syscall khi chạy ở chế độ này sẽ bị từ chối. trong
  Ngoài ra, không phải tất cả các lỗi đều được báo cáo trực tiếp trở lại không gian người dùng;
  cụ thể là chỉ có các lỗi nghiêm trọng trong quá trình thiết lập hoặc trong quá trình thực thi (như bộ nhớ
  lỗi phân bổ) sẽ tạm dừng thực thi và trả về lỗi. Nếu xảy ra lỗi
  trong xử lý gói, như lỗi chuyển hướng đến một giao diện nhất định,
  việc thực hiện sẽ tiếp tục với lần lặp lại tiếp theo; những lỗi này có thể được phát hiện
  thông qua các điểm theo dõi giống như đối với các chương trình XDP thông thường.

- Không gian người dùng có thể cung cấp ifindex như một phần của đối tượng ngữ cảnh, giống như trong
  chế độ thông thường (không trực tiếp). Chương trình XDP sẽ được thực thi như thể
  gói đến trên giao diện này; tức là ZZ0000ZZ của bối cảnh
  đối tượng sẽ trỏ đến giao diện đó. Hơn nữa, nếu chương trình XDP trả về
  ZZ0001ZZ, gói sẽ được đưa vào ngăn xếp mạng hạt nhân dưới dạng
  mặc dù nó đã xuất hiện trên ifindex đó và nếu nó trả về ZZ0002ZZ, gói
  sẽ được truyền ZZ0006ZZ của cùng giao diện đó. Tuy nhiên, hãy lưu ý rằng
  vì việc thực thi chương trình không diễn ra trong ngữ cảnh của trình điều khiển, nên
  ZZ0003ZZ thực sự được chuyển thành hành động tương tự như ZZ0004ZZ để
  cùng giao diện đó (nghĩa là nó sẽ chỉ hoạt động nếu trình điều khiển có hỗ trợ cho
  Trình điều khiển ZZ0005ZZ op).

- Khi chạy chương trình lặp lại nhiều lần sẽ xảy ra việc thực thi
  theo đợt. Kích thước lô mặc định là 64 gói (tương tự như
  kích thước lô nhận NAPI tối đa), nhưng có thể được chỉ định bởi không gian người dùng thông qua
  tham số ZZ0000ZZ, tối đa 256 gói. Đối với mỗi lô,
  kernel thực thi chương trình XDP nhiều lần, mỗi lần gọi sẽ nhận được một
  bản sao riêng biệt của dữ liệu gói. Đối với mỗi lần lặp lại, nếu chương trình bị hủy
  gói tin, trang dữ liệu sẽ được tái chế ngay lập tức (xem bên dưới). Nếu không,
  gói được lưu vào bộ đệm cho đến hết gói, tại thời điểm đó tất cả các gói
  được đệm theo cách này trong suốt đợt được truyền cùng một lúc.

- Khi thiết lập chạy thử, kernel sẽ khởi tạo một vùng bộ nhớ
  các trang có cùng kích thước với kích thước lô. Mỗi trang bộ nhớ sẽ được khởi tạo
  với dữ liệu gói ban đầu được cung cấp bởi không gian người dùng tại ZZ0000ZZ
  lời kêu gọi. Khi có thể, các trang sẽ được tái chế trong chương trình tương lai
  lời kêu gọi, để cải thiện hiệu suất. Các trang thường sẽ được tái chế hoàn toàn
  theo lô tại một thời điểm, ngoại trừ khi gói bị loại bỏ (do mã trả về hoặc do
  chẳng hạn như lỗi chuyển hướng), trong trường hợp đó trang đó sẽ được tái sử dụng
  ngay lập tức. Nếu một gói cuối cùng được chuyển đến ngăn xếp mạng thông thường
  (vì chương trình XDP trả về ZZ0001ZZ, hoặc vì cuối cùng nó là
  được chuyển hướng đến một giao diện đưa nó vào ngăn xếp), trang sẽ
  được phát hành và một cái mới sẽ được phân bổ khi nhóm trống.

Khi tái chế, nội dung trang không được viết lại; chỉ ranh giới gói
  con trỏ (ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ) trong đối tượng ngữ cảnh sẽ
  được đặt lại về giá trị ban đầu. Điều này có nghĩa là nếu một chương trình viết lại
  nội dung gói tin, nó phải được chuẩn bị để xem nội dung gốc hoặc
  phiên bản đã sửa đổi trong các lần gọi tiếp theo.