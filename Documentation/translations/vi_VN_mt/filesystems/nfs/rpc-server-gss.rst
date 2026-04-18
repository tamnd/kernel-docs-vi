.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/nfs/rpc-server-gss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=============================================
hỗ trợ rpcsec_gss cho máy chủ kernel RPC
=========================================

Tài liệu này cung cấp tài liệu tham khảo cho các tiêu chuẩn và giao thức được sử dụng để
triển khai xác thực RPCGSS trong các máy chủ RPC kernel chẳng hạn như NFS
máy chủ và máy chủ gọi lại NFSv4.0 của máy khách NFS.  (Nhưng lưu ý rằng
NFSv4.1 trở lên không yêu cầu máy khách hoạt động như một máy chủ cho
mục đích xác thực.)

RPCGSS được chỉ định trong một số tài liệu IETF:

-RFC2203 v1: ZZ0000ZZ
 -RFC5403 v2: ZZ0001ZZ

Có phiên bản thứ ba mà chúng tôi hiện chưa triển khai:

-RFC7861 v3: ZZ0000ZZ

Lý lịch
==========

Phương thức xác thực RPCGSS mô tả cách thực hiện GSSAPI
Xác thực cho NFS.  Mặc dù bản thân GSSAPI hoàn toàn có cơ chế
bất khả tri, trong nhiều trường hợp chỉ có cơ chế KRB5 được NFS hỗ trợ
triển khai.

Hiện tại, nhân Linux chỉ hỗ trợ cơ chế KRB5 và
phụ thuộc vào các tiện ích mở rộng GSSAPI dành riêng cho KRB5.

GSSAPI là một thư viện phức tạp và việc triển khai nó hoàn toàn trong kernel là điều khó khăn.
không chính đáng. Tuy nhiên, hoạt động của GSSAPI về cơ bản có thể tách thành 2
bộ phận:

- thiết lập bối cảnh ban đầu
- bảo vệ tính toàn vẹn/quyền riêng tư (ký và mã hóa thông tin cá nhân
  gói)

Cái trước phức tạp hơn và độc lập về chính sách hơn, nhưng ít
nhạy cảm với hiệu suất.  Cái sau đơn giản hơn và cần phải rất nhanh.

Do đó, chúng tôi thực hiện bảo vệ tính toàn vẹn và quyền riêng tư trên mỗi gói trong
kernel, nhưng để việc thiết lập bối cảnh ban đầu cho không gian người dùng.  Chúng tôi
cần gọi lên để yêu cầu không gian người dùng nhằm thực hiện thiết lập ngữ cảnh.

Cơ chế nâng cấp kế thừa của máy chủ NFS
==================================

Cơ chế upcall cổ điển sử dụng cơ chế upcall dựa trên văn bản tùy chỉnh
để nói chuyện với một daemon tùy chỉnh có tên là rpc.svcgssd được cung cấp bởi
gói nfs-utils.

Cơ chế upcall này có 2 hạn chế:

A) Nó có thể xử lý các mã thông báo không lớn hơn 2KiB

Trong một số mã thông báo GSSAPI triển khai Kerberos có thể khá lớn, cao hơn và
vượt quá kích thước 64KiB do các tiện ích mở rộng ủy quyền khác nhau bị tấn công
vé Kerberos cần được gửi qua lớp GSS trong
để thực hiện việc thiết lập bối cảnh.

B) Nó không xử lý đúng cách các khoản tín dụng khi người dùng là thành viên của nhiều hơn
hơn vài nghìn nhóm (giới hạn cứng hiện tại trong kernel là 65K
nhóm) do giới hạn về kích thước của bộ đệm có thể gửi
quay lại kernel (4KiB).

Máy chủ NFS Cơ chế nâng cấp RPC mới
===================================

Cơ chế upcall mới hơn sử dụng RPC qua ổ cắm unix cho daemon
được gọi là gss-proxy, được triển khai bởi chương trình không gian người dùng có tên Gssproxy.

Giao thức gss_proxy RPC hiện được ghi lại là ZZ0000ZZ.

Cơ chế upcall này sử dụng kernel rpc client và kết nối với gssproxy
chương trình không gian người dùng trên ổ cắm unix thông thường. Giao thức gssproxy không
phải chịu những hạn chế về kích thước của giao thức cũ.

Đàm phán cơ chế Upcall
=============================

Để cung cấp khả năng tương thích ngược, kernel mặc định sử dụng
cơ chế kế thừa.  Để chuyển sang cơ chế mới, gss-proxy phải liên kết
vào /var/run/gssproxy.sock rồi viết "1" vào
/proc/net/rpc/use-gss-proxy.  Nếu gss-proxy chết, nó phải lặp lại cả hai
các bước.

Một khi cơ chế gọi lên đã được chọn thì không thể thay đổi được.  Để ngăn chặn
khóa vào các cơ chế cũ, các bước trên phải được thực hiện
trước khi bắt đầu nfsd.  Bất cứ ai bắt đầu nfsd đều có thể đảm bảo điều này bằng cách đọc
từ /proc/net/rpc/use-gss-proxy và kiểm tra xem nó có chứa
"1"--quá trình đọc sẽ bị chặn cho đến khi gss-proxy ghi xong vào tệp.
