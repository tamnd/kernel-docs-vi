.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/IMA-templates.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================
Cơ chế quản lý mẫu IMA
=================================


Giới thiệu
============

Mẫu ZZ0000ZZ ban đầu có độ dài cố định, chứa hàm băm dữ liệu tệp
và tên đường dẫn. Băm dữ liệu tệp được giới hạn ở 20 byte (md5/sha1).
Tên đường dẫn là một chuỗi kết thúc null, giới hạn ở 255 ký tự.
Để khắc phục những hạn chế này và thêm siêu dữ liệu tệp bổ sung,
cần thiết để mở rộng phiên bản hiện tại của IMA bằng cách xác định thêm
mẫu. Ví dụ: thông tin có thể được báo cáo là
nhãn inode UID/GID hoặc LSM của inode và của quy trình
đó là truy cập vào nó.

Tuy nhiên, vấn đề chính khi giới thiệu tính năng này là ở chỗ, mỗi lần
một mẫu mới được xác định, các chức năng tạo và hiển thị
danh sách đo lường sẽ bao gồm mã để xử lý một định dạng mới
và do đó sẽ tăng trưởng đáng kể theo thời gian.

Giải pháp đề xuất giải quyết vấn đề này bằng cách tách mẫu
quản lý từ mã IMA còn lại. Cốt lõi của giải pháp này là
định nghĩa của hai cấu trúc dữ liệu mới: một bộ mô tả mẫu, để xác định
thông tin nào cần được đưa vào danh sách đo lường; một mẫu
trường, để tạo và hiển thị dữ liệu của một loại nhất định.

Quản lý các mẫu với các cấu trúc này rất đơn giản. Để hỗ trợ
một kiểu dữ liệu mới, các nhà phát triển xác định mã định danh trường và triển khai
hai hàm init() và show() tương ứng để tạo và hiển thị
mục đo lường. Việc xác định một bộ mô tả mẫu mới yêu cầu
chỉ định định dạng mẫu (một chuỗi định danh trường được phân tách
bởi ký tự ZZ0000ZZ) thông qua dòng lệnh kernel ZZ0001ZZ
tham số. Khi khởi động, IMA khởi tạo bộ mô tả mẫu đã chọn
bằng cách dịch định dạng thành một mảng các cấu trúc trường mẫu được lấy
từ tập hợp những cái được hỗ trợ.

Sau bước khởi tạo, IMA sẽ gọi ZZ0000ZZ
(chức năng mới được xác định trong các bản vá dành cho quản lý mẫu mới
cơ chế) để tạo mục nhập đo lường mới bằng cách sử dụng mẫu
mô tả được chọn thông qua cấu hình hạt nhân hoặc thông qua
đã giới thiệu các tham số dòng lệnh kernel ZZ0001ZZ và ZZ0002ZZ.
Chính trong giai đoạn này những lợi thế của kiến trúc mới là
hiển thị rõ ràng: hàm sau sẽ không chứa mã cụ thể để xử lý
một mẫu nhất định nhưng thay vào đó, nó chỉ gọi phương thức ZZ0003ZZ của mẫu
các trường được liên kết với bộ mô tả mẫu đã chọn và lưu trữ kết quả
(con trỏ tới dữ liệu được phân bổ và độ dài dữ liệu) trong cấu trúc mục nhập đo lường.

Cơ chế tương tự được sử dụng để hiển thị các mục đo lường.
Các chức năng truy xuất ZZ0000ZZ cho mỗi mục nhập,
bộ mô tả mẫu được sử dụng để tạo mục nhập đó và gọi show()
phương thức cho từng mục của mảng cấu trúc trường mẫu.



Các trường mẫu và mô tả được hỗ trợ
=========================================

Sau đây là danh sách các trường mẫu được hỗ trợ
ZZ0000ZZ, có thể được sử dụng để xác định mẫu mới
mô tả bằng cách thêm mã định danh của chúng vào chuỗi định dạng
(hỗ trợ nhiều loại dữ liệu hơn sẽ được bổ sung sau):

- 'd': bản tóm tắt của sự kiện (tức là bản tóm tắt của một tệp được đo),
   được tính toán bằng thuật toán băm SHA1 hoặc MD5;
 - 'n': tên sự kiện (tức là tên file), có kích thước tối đa 255 byte;
 - 'd-ng': thông báo sự kiện, được tính bằng hàm băm tùy ý
   thuật toán (định dạng trường: <hash algo>:digest);
 - 'd-ngv2': giống như d-ng, nhưng có tiền tố là kiểu tóm tắt "ima" hoặc "verity"
   (định dạng trường: <digest type>:<hash algo>:digest);
 - 'd-modsig': bản tóm tắt sự kiện không có modsig được thêm vào;
 - 'n-ng': tên của sự kiện, không giới hạn kích thước;
 - 'sig': chữ ký tệp, dựa trên thông báo của tệp/fsverity[1],
   hoặc chữ ký di động EVM, nếu 'security.ima' chứa hàm băm tệp.
 - 'modsig' chữ ký tệp được nối thêm;
 - 'buf': dữ liệu bộ đệm được sử dụng để tạo hàm băm không có giới hạn về kích thước;
 - 'evmsig': chữ ký di động EVM;
 - 'iuid': inode UID;
 - 'igid': inode GID;
 - 'imode': chế độ inode;
 - 'xattrnames': danh sách các tên xattr (được phân tách bằng ZZ0000ZZ), chỉ khi xattr là
    hiện tại;
 - 'xattrlengths': danh sách độ dài xattr (u32), chỉ khi có xattr;
 - 'xattrvalues': danh sách các giá trị xattr;


Dưới đây là danh sách các mô tả mẫu được xác định:

- "ima": định dạng của nó là ZZ0000ZZ;
 - "ima-ng" (mặc định): định dạng của nó là ZZ0001ZZ;
 - "ima-ngv2": định dạng của nó là ZZ0002ZZ;
 - "ima-sig": định dạng của nó là ZZ0003ZZ;
 - "ima-sigv2": định dạng của nó là ZZ0004ZZ;
 - "ima-buf": định dạng của nó là ZZ0005ZZ;
 - "ima-modsig": định dạng của nó là ZZ0006ZZ;
 - "evm-sig": định dạng của nó là ZZ0007ZZ;


Sử dụng
===

Để chỉ định bộ mô tả mẫu sẽ được sử dụng để tạo các mục đo lường,
hiện tại các phương pháp sau được hỗ trợ:

- chọn một bộ mô tả mẫu trong số những bộ mô tả được hỗ trợ trong kernel
   cấu hình (ZZ0000ZZ là lựa chọn mặc định);
 - chỉ định tên mô tả mẫu từ dòng lệnh kernel thông qua
   tham số ZZ0001ZZ;
 - đăng ký một bộ mô tả mẫu mới với định dạng tùy chỉnh thông qua kernel
   tham số dòng lệnh ZZ0002ZZ.
