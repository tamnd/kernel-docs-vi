.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/userspace-api/check_exec.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright © 2024 Microsoft Corporation

=====================
Kiểm tra khả năng thực thi
===================

Cờ ZZ0001ZZ ZZ0000ZZ và
Các bit bảo mật ZZ0002ZZ và ZZ0003ZZ
được dành cho các trình thông dịch tập lệnh và trình liên kết động để thực thi một
chính sách bảo mật thực thi nhất quán được xử lý bởi kernel.  Xem
Ví dụ ZZ0004ZZ.

Việc thông dịch viên có nên kiểm tra các bit bảo mật này hay không phụ thuộc vào
rủi ro bảo mật khi chạy các tập lệnh độc hại liên quan đến việc thực thi
môi trường và liệu kernel có thể kiểm tra xem tập lệnh có đáng tin cậy hay không
không.  Chẳng hạn, các tập lệnh Python chạy trên máy chủ có thể sử dụng tùy ý
syscalls và truy cập các tập tin tùy ý.  Những thông dịch viên như vậy nên được
khai sáng để sử dụng các Securebit này và cho phép người dùng xác định chính sách bảo mật của họ.
Tuy nhiên, một công cụ JavaScript chạy trên trình duyệt web phải được
được đóng hộp cát và sau đó sẽ không thể gây hại cho môi trường của người dùng.

Trình thông dịch tập lệnh hoặc trình liên kết động được xây dựng cho môi trường thực thi phù hợp
(ví dụ: bản phân phối Linux cứng hoặc hình ảnh vùng chứa kín) có thể sử dụng
ZZ0000ZZ mà không kiểm tra các bit bảo mật liên quan nếu lùi
khả năng tương thích được xử lý bởi một thứ khác (ví dụ: cập nhật nguyên tử đảm bảo rằng
tất cả các thư viện hợp pháp đều được phép thực thi).  Sau đó được khuyến khích
dành cho trình thông dịch tập lệnh và trình liên kết động để kiểm tra các bit bảo mật trong thời gian chạy
theo mặc định mà còn để cung cấp khả năng cho các bản dựng tùy chỉnh hoạt động giống như nếu
ZZ0001ZZ hoặc ZZ0002ZZ luôn
được đặt thành 1 (tức là luôn thực thi các hạn chế).

AT_EXECVE_CHECK
===============

Việc chuyển cờ ZZ0001ZZ tới ZZ0000ZZ chỉ thực hiện một
kiểm tra một tệp thông thường và trả về 0 nếu việc thực thi tệp này là
được phép, bỏ qua định dạng tệp và sau đó là các phần phụ thuộc của trình thông dịch có liên quan
(ví dụ: thư viện ELF, shebang của tập lệnh).

Các chương trình phải luôn thực hiện kiểm tra này để áp dụng kiểm tra cấp hạt nhân đối với
các tệp không được kernel thực thi trực tiếp mà được chuyển đến không gian người dùng
thông dịch viên thay thế.  Tất cả các tệp chứa mã thực thi, kể từ thời điểm
quan điểm của người phiên dịch, cần được kiểm tra.  Tuy nhiên kết quả của việc kiểm tra này
chỉ nên được thi hành theo ZZ0000ZZ hoặc
ZZ0001ZZ.

Mục đích chính của cờ này là cải thiện tính bảo mật và tính nhất quán của một
môi trường thực thi để đảm bảo rằng việc thực thi tệp trực tiếp (ví dụ:
ZZ0000ZZ) và việc thực thi tệp gián tiếp (ví dụ ZZ0001ZZ) dẫn đến
kết quả tương tự  Ví dụ, điều này có thể được sử dụng để kiểm tra xem một tập tin có
đáng tin cậy tùy theo môi trường của người gọi.

Trong một môi trường an toàn, các thư viện và mọi phần phụ thuộc có thể thực thi được cũng phải
được kiểm tra.  Ví dụ: liên kết động phải đảm bảo rằng tất cả các thư viện
được phép thực thi để tránh bỏ qua tầm thường (ví dụ: sử dụng ZZ0000ZZ).
Để môi trường thực thi an toàn như vậy có ý nghĩa, chỉ có mã đáng tin cậy mới nên
có thể thực thi được, điều này cũng yêu cầu đảm bảo tính toàn vẹn.

Để tránh các điều kiện chạy đua dẫn đến các vấn đề về thời gian kiểm tra về thời gian sử dụng,
ZZ0000ZZ nên được sử dụng cùng với ZZ0001ZZ để kiểm tra
mô tả tập tin thay vì một đường dẫn.

SECBIT_EXEC_RESTRICT_FILE và SECBIT_EXEC_DENY_INTERACTIVE
==========================================================

Khi ZZ0001ZZ được đặt, một quy trình chỉ nên diễn giải hoặc
thực thi một tệp nếu lệnh gọi tới ZZ0000ZZ bằng tệp liên quan
bộ mô tả và cờ ZZ0002ZZ thành công.

Bit bảo mật này có thể được thiết lập bởi người quản lý phiên người dùng, người quản lý dịch vụ,
thời gian chạy container, công cụ hộp cát... Ngoại trừ môi trường thử nghiệm,
Bit ZZ0000ZZ liên quan cũng nên được đặt.

Các chương trình chỉ nên thực thi các hạn chế nhất quán theo
Securebits nhưng không dựa vào bất kỳ cấu hình nào khác do người dùng kiểm soát.
Thật vậy, trường hợp sử dụng của các bit bảo mật này là chỉ tin cậy vào mã thực thi
được hiệu chỉnh bởi cấu hình hệ thống (thông qua kernel), vì vậy chúng ta nên
cẩn thận không để người dùng không đáng tin cậy kiểm soát cấu hình này.

Tuy nhiên, trình thông dịch tập lệnh vẫn có thể sử dụng cấu hình người dùng như
các biến môi trường miễn là đó không phải là cách để vô hiệu hóa các bit bảo mật
séc.  Ví dụ: các biến ZZ0000ZZ và ZZ0001ZZ có thể được đặt bởi
người gọi của một tập lệnh.  Việc thay đổi các biến này có thể dẫn đến mã ngoài ý muốn
thực thi, nhưng chỉ từ các chương trình thực thi đã được hiệu đính, điều này không sao cả.  Đối với điều này
hợp lý, hệ thống cần cung cấp một chính sách bảo mật nhất quán để tránh
thực thi mã tùy ý, ví dụ: bằng cách thực thi chính sách thực thi ghi xor.

Khi ZZ0001ZZ được đặt, một quy trình sẽ không bao giờ diễn giải
lệnh người dùng tương tác (ví dụ: tập lệnh).  Tuy nhiên, nếu các lệnh đó được thông qua
thông qua một bộ mô tả tập tin (ví dụ: stdin), nội dung của nó sẽ được diễn giải nếu một
gọi tới ZZ0000ZZ bằng bộ mô tả tệp liên quan và
Cờ ZZ0002ZZ thành công.

Ví dụ: trình thông dịch tập lệnh được gọi với đoạn mã làm đối số
phải luôn từ chối việc thực thi đó nếu ZZ0000ZZ được đặt.

Bit bảo mật này có thể được thiết lập bởi người quản lý phiên người dùng, người quản lý dịch vụ,
thời gian chạy container, công cụ hộp cát... Ngoại trừ môi trường thử nghiệm,
Bit ZZ0000ZZ liên quan cũng nên được đặt.

Đây là hành vi mong đợi đối với trình thông dịch tập lệnh theo sự kết hợp
của bất kỳ bit bảo mật thực thi nào:

1. ZZ0000ZZ và ZZ0001ZZ

Luôn diễn giải tập lệnh và cho phép người dùng thực hiện các lệnh tùy ý (mặc định).

Không có mối đe dọa nào, mọi người và mọi thứ đều được tin cậy, nhưng chúng ta có thể vượt lên dẫn trước
   các vấn đề tiềm ẩn nhờ lệnh gọi tới ZZ0000ZZ với
   ZZ0001ZZ phải luôn được thực hiện nhưng bị bỏ qua
   trình thông dịch kịch bản.  Quả thực, việc kiểm tra này vẫn rất quan trọng để cho phép các hệ thống
   quản trị viên để xác minh các yêu cầu (ví dụ: kiểm tra) và chuẩn bị cho
   di chuyển sang chế độ an toàn.

2. ZZ0000ZZ và ZZ0001ZZ

Từ chối giải thích tập lệnh nếu chúng không thể thực thi được, nhưng cho phép
   lệnh người dùng tùy ý.

Mối đe dọa là các tập lệnh độc hại (tiềm ẩn) được điều hành bởi những tập lệnh đáng tin cậy (và không bị lừa)
   người dùng.  Điều đó có thể bảo vệ khỏi việc thực thi tập lệnh ngoài ý muốn (ví dụ: ZZ0000ZZ).  Điều này có ý nghĩa đối với các phiên người dùng (bán hạn chế).

3. ZZ0000ZZ và ZZ0001ZZ

Luôn diễn giải các tập lệnh nhưng từ chối các lệnh tùy ý của người dùng.

Ca sử dụng này có thể hữu ích cho các dịch vụ an toàn (tức là không có sự tương tác
   phiên người dùng) trong đó tính toàn vẹn của tập lệnh được xác minh (ví dụ: với IMA/EVM hoặc
   dm-verity/IPE) nhưng quyền truy cập có thể chưa sẵn sàng.  Thật vậy,
   các lệnh tương tác tùy ý sẽ khó kiểm tra hơn nhiều.

4. ZZ0000ZZ và ZZ0001ZZ

Từ chối việc giải thích tập lệnh nếu chúng không thể thực thi được và cũng từ chối
   bất kỳ lệnh người dùng tùy ý nào.

Mối đe dọa là các tập lệnh độc hại được chạy bởi người dùng không đáng tin cậy (nhưng mã đáng tin cậy).
   Điều này có ý nghĩa đối với các dịch vụ hệ thống chỉ có thể thực thi các tập lệnh đáng tin cậy.

.. Links
.. _samples/check-exec/inc.c:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/tree/samples/check-exec/inc.c