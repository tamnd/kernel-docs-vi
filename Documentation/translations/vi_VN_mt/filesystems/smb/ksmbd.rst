.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/smb/ksmbd.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================
KSMBD - Máy chủ hạt nhân SMB3
==========================

KSMBD là máy chủ hạt nhân linux thực hiện giao thức SMB3 trong không gian hạt nhân
để chia sẻ tập tin qua mạng.

Kiến trúc KSMBD
==================

Tập hợp con của các hoạt động liên quan đến hiệu suất thuộc về kernelspace và
tập hợp con khác thuộc về các hoạt động không thực sự liên quan đến
hiệu suất trong không gian người dùng. Vì vậy, việc quản lý DCE/RPC trước đây đã mang lại kết quả
vào một số vấn đề tràn bộ đệm và các lỗi bảo mật nguy hiểm và người dùng
quản lý tài khoản được triển khai trong không gian người dùng dưới dạng ksmbd.mountd.
Các thao tác tệp liên quan đến hiệu suất (mở/đọc/ghi/đóng, v.v.)
trong không gian hạt nhân (ksmbd). Điều này cũng cho phép tích hợp dễ dàng hơn với VFS
giao diện cho tất cả các hoạt động tập tin.

ksmbd (daemon hạt nhân)
---------------------

Khi daemon máy chủ được khởi động, nó sẽ khởi động một luồng forker
(ksmbd/tên giao diện) tại thời điểm khởi tạo và mở cổng chuyên dụng 445
để nghe các yêu cầu SMB. Bất cứ khi nào khách hàng mới đưa ra yêu cầu, Forker
luồng sẽ chấp nhận kết nối máy khách và phân nhánh một luồng mới cho một luồng chuyên dụng
kênh liên lạc giữa client và server. Nó cho phép song song
xử lý các yêu cầu (lệnh) SMB từ khách hàng cũng như cho phép các yêu cầu mới
khách hàng để thực hiện các kết nối mới. Mỗi phiên bản được đặt tên là ksmbd/1~n(số cổng)
để chỉ ra các máy khách được kết nối. Tùy thuộc vào loại yêu cầu SMB, mỗi loại yêu cầu mới
luồng có thể quyết định chuyển các lệnh tới không gian người dùng (ksmbd.mountd),
hiện tại các lệnh DCE/RPC được xác định là sẽ được xử lý thông qua không gian người dùng.
Để tiếp tục sử dụng kernel linux, nó đã được chọn để xử lý các lệnh
dưới dạng các mục công việc và được thực thi trong trình xử lý của các luồng ksmbd-io kworker.
Nó cho phép ghép kênh các trình xử lý vì kernel đảm nhiệm việc khởi tạo
các luồng công việc bổ sung nếu tải tăng và ngược lại, nếu tải
giảm nó sẽ phá hủy các luồng công nhân bổ sung. Vì vậy, sau khi kết nối được
được thiết lập với khách hàng. Ksmbd/1..n(số cổng) chuyên dụng đã hoàn tất
quyền nhận/phân tích các lệnh SMB. Mỗi lệnh nhận được đều được thực hiện
song song, tức là có thể có nhiều lệnh máy khách được thực hiện cùng lúc
song song. Sau khi nhận được mỗi lệnh, một hạng mục công việc hạt nhân riêng biệt sẽ được chuẩn bị
đối với mỗi lệnh được xếp hàng tiếp theo để được ksmbd-io kworkers xử lý.
Vì vậy, mỗi hạng mục công việc SMB được xếp hàng đợi tới các kworkers. Điều này cho phép lợi ích của tải
chia sẻ được quản lý tối ưu bởi kernel mặc định và tối ưu hóa ứng dụng khách
hiệu suất bằng cách xử lý song song các lệnh của máy khách.

ksmbd.mountd (daemon không gian người dùng)
--------------------------------

ksmbd.mountd là một quá trình không gian người dùng để chuyển tài khoản người dùng và mật khẩu
được đăng ký bằng ksmbd.adduser (một phần của tiện ích dành cho không gian người dùng). Hơn nữa nó
cho phép chia sẻ các thông số thông tin được phân tích từ smb.conf sang ksmbd trong
hạt nhân. Đối với phần thực thi, nó có một daemon chạy liên tục
và được kết nối với giao diện kernel bằng ổ cắm netlink, nó sẽ đợi
yêu cầu (dcerpc và chia sẻ/thông tin người dùng). Nó xử lý các cuộc gọi RPC (ít nhất một vài
tá) quan trọng nhất đối với máy chủ tệp từ NetShareEnum và
NetServerGetInfo. Phản hồi DCE/RPC hoàn chỉnh được chuẩn bị từ không gian người dùng
và được chuyển tới luồng nhân liên quan cho máy khách.


Trạng thái tính năng KSMBD
====================

=====================================================================================
Tên tính năng Trạng thái
=====================================================================================
Phương ngữ được hỗ trợ. Các phương ngữ SMB2.1 SMB3.0, SMB3.1.1
                               (cố ý loại trừ lỗ hổng bảo mật SMB1
                               phương ngữ).
Hỗ trợ đàm phán tự động.
Yêu cầu tổng hợp được hỗ trợ.
Cơ chế bộ đệm Oplock được hỗ trợ.
Hợp đồng thuê SMB2 (cho thuê v1) Được hỗ trợ.
Cho thuê thư mục (cho thuê v2) Được hỗ trợ.
Hỗ trợ nhiều tín chỉ.
Hỗ trợ NTLM/NTLMv2.
Hỗ trợ ký HMAC-SHA256.
Đàm phán an toàn Được hỗ trợ.
Cập nhật ký được hỗ trợ.
Tính toàn vẹn xác thực trước được hỗ trợ.
Hỗ trợ mã hóa SMB3(CCM, GCM). (Hỗ trợ CCM/GCM128 và CCM/GCM256)
Hỗ trợ SMB trực tiếp (RDMA).
SMB3 Đa kênh được hỗ trợ một phần. Dự kiến thực hiện
                               cơ chế phát lại/thử lại cho tương lai.
Nhận chế độ Side Scaling được hỗ trợ.
Hỗ trợ tiện ích mở rộng SMB3.1.1 POSIX.
ACL được hỗ trợ một phần. chỉ có DACL, SACL
                               (kiểm toán) được lên kế hoạch cho tương lai. cho
                               quyền sở hữu (SID) ksmbd tạo subauth ngẫu nhiên
                               giá trị (sau đó lưu nó vào đĩa) và sử dụng uid/gid
                               lấy từ inode dưới dạng RID cho tên miền cục bộ SID.
                               Việc triển khai acl hiện tại được giới hạn ở
                               máy chủ độc lập, không phải là thành viên miền.
                               Việc tích hợp với các công cụ Samba đang được thực hiện
                               để cho phép hỗ trợ trong tương lai để chạy dưới dạng miền
                               thành viên.
Kerberos được hỗ trợ.
Tay cầm bền bỉ v1,v2 Được lên kế hoạch cho tương lai.
Xử lý liên tục Có kế hoạch cho tương lai.
SMB2 thông báo Kế hoạch cho tương lai.
Hỗ trợ tập tin thưa thớt Được hỗ trợ.
Hỗ trợ DCE/RPC Được hỗ trợ một phần. một vài cuộc gọi(NetShareEnumAll,
                               NetServerGetInfo, SAMR, LSARPC) cần thiết
                               cho máy chủ tập tin được xử lý thông qua giao diện netlink
                               từ ksmbd.mountd. Tích hợp bổ sung với
                               Các công cụ và thư viện Samba thông qua upcall đang được
                               được điều tra để cho phép hỗ trợ thêm
                               Cuộc gọi quản lý DCE/RPC (và hỗ trợ trong tương lai
                               đối với giao thức Nhân chứng, vd)
khả năng tương tác ksmbd/nfsd Được lên kế hoạch cho tương lai. Các tính năng mà ksmbd
                               hỗ trợ là các chế độ Cho thuê, Thông báo, ACL và Chia sẻ.
Dự kiến ​​nén SMB3.1.1 cho tương lai.
SMB3.1.1 trên QUIC Được lên kế hoạch cho tương lai.
Ký/Mã hóa trên RDMA Được lên kế hoạch cho tương lai.
Hỗ trợ ký kết SMB3.1.1 GMAC Được lên kế hoạch cho tương lai.
=====================================================================================


Làm thế nào để chạy
==========

1. Tải xuống ksmbd-tools(ZZ0000ZZ và
   biên dịch chúng.

- Tham khảo README(ZZ0000ZZ
     để biết cách sử dụng ksmbd.mountd/adduser/addshare/control utils

$ ./autogen.sh
     $ ./configure --with-rundir=/run
     $ thực hiện && sudo thực hiện cài đặt

2. Tạo tệp /usr/local/etc/ksmbd/ksmbd.conf, thêm chia sẻ SMB trong tệp ksmbd.conf.

- Tham khảo ksmbd.conf.example trong ksmbd-utils, Xem trang chủ ksmbd.conf
     để biết chi tiết về cách cấu hình chia sẻ.

$ man ksmbd.conf

3. Tạo người dùng/mật khẩu cho chia sẻ SMB.

- Xem trang chủ ksmbd.adduser.

$ man ksmbd.adduser
     $ sudo ksmbd.adduser -a <Nhập USERNAME để có quyền truy cập chia sẻ SMB>

4. Chèn mô-đun ksmbd.ko sau khi bạn xây dựng hạt nhân. Không cần tải mô-đun
   nếu ksmbd được tích hợp vào kernel.

- Đặt ksmbd trong menuconfig (ví dụ: $ make menuconfig)
       [*] Hệ thống tệp mạng --->
           <M> Hỗ trợ máy chủ SMB3 (EXPERIMENTAL)

$ sudo modprobe ksmbd.ko

5. Khởi động daemon không gian người dùng ksmbd

$ sudo ksmbd.mountd

6. Truy cập chia sẻ từ Windows hoặc Linux bằng ứng dụng khách SMB3 (cifs.ko hoặc smbclient của samba)

Tắt máy KSMBD
==============

1. tiêu diệt daemon không gian người dùng và kernel
	# sudo ksmbd.control -s

Cách bật tính năng in gỡ lỗi
==========================

Mỗi lớp
/sys/class/ksmbd-control/gỡ lỗi

1. Kích hoạt tất cả các bản in thành phần
	# sudo ksmbd.control -d "tất cả"

2. Kích hoạt một trong các thành phần (smb, auth, vfs, oplock, ipc, conn, rdma)
	# sudo ksmbd.control -d "smb"

3. Hiển thị những bản in nào được kích hoạt.
	# cat/sys/class/ksmbd-control/gỡ lỗi
	  [smb] auth vfs oplock ipc conn [rdma]

4. Vô hiệu hóa tính năng in:
	Nếu bạn thử thành phần đã chọn một lần nữa, Thành phần đó sẽ bị tắt nếu không có dấu ngoặc.