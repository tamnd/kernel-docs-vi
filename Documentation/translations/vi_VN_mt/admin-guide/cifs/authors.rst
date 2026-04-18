.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/cifs/authors.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=======
tác giả
=======

Tác giả gốc
---------------

Steve French (smfrench@gmail.com, sfrench@samba.org)

Tác giả xin bày tỏ lòng kính trọng và cảm ơn tới:
Andrew Tridgell (đội Samba) vì những gợi ý ban đầu của anh ấy về SMB/CIFS VFS
cải tiến. Cảm ơn IBM đã cho tôi thời gian và nguồn lực thử nghiệm để theo đuổi
dự án này, gửi tới Jim McDonough từ IBM (và Nhóm Samba) vì sự giúp đỡ của anh ấy, tới
nhóm IBM Linux JFS để giải thích nhiều tính năng bí truyền của hệ thống tệp Linux.
Jeremy Allison của nhóm Samba đã thực hiện công việc vô giá trong việc thêm máy chủ
bên cạnh các phần mở rộng Unix CIFS ban đầu và xem xét và triển khai
các phần mở rộng CIFS POSIX mới hơn vào máy chủ tệp Samba 3. Cảm ơn
Dave Boutcher của IBM Rochester (tác giả của ứng dụng khách hệ thống tập tin OS/400 smb/cifs)
vì đã chứng minh từ nhiều năm trước rằng các ứng dụng khách smb/cifs rất tốt có thể được thực hiện trên Unix-like
các hệ điều hành.  Volker Lendecke, Andrew Tridgell, Urban Widmark, John
Newbigin và những người khác vì công việc của họ trên mô-đun smbfs của Linux.  Nhờ có
các thành viên khác của Hiệp hội Công nghiệp Mạng Lưu trữ CIFS Kỹ thuật
Nhóm làm việc vì công việc của họ chỉ định giao thức rất phức tạp này và cuối cùng
cảm ơn nhóm Samba vì lời khuyên và sự động viên kỹ thuật của họ.

Người đóng góp bản vá
---------------------

- Zwane Mwaikambo
- Andi Kleen
- Amrut Joshi
- Shobhit Dayal
- Serge Vlasov
- Richard Hughes
- Yury Umanets
- Mark Hamzy (đối với một số công việc đầu tiên của cifs IPv6)
- Máy đục lỗ Domen
- Jesper Juhl (đặc biệt đối với nhiều khoảng trắng/dọn dẹp định dạng)
- Vince Negri và Dave Stahl (vì đã tìm ra lỗi quan trọng trong bộ nhớ đệm)
- Adrian Bunk (dọn dẹp kcalloc)
- Miklos Szeredi
- Nhóm Kazeon đưa ra nhiều bản sửa lỗi khác nhau, đặc biệt là cho phiên bản 2.4.
- Asser Ferno (Hỗ trợ thông báo thay đổi)
- Shaggy (Dave Kleikamp) vì vô số gợi ý fs nhỏ và cách dọn dẹp hiệu quả
- Gunter Kukkukk (thử nghiệm và đề xuất hỗ trợ các máy chủ cũ)
- Igor Mammedov (hỗ trợ DFS)
- Jeff Layton (rất nhiều bản sửa lỗi cũng như công việc tuyệt vời về mã cifs Kerberos)
- Scott Lovenberg
- Pavel Shilovsky (vì công việc tuyệt vời khi bổ sung hỗ trợ SMB2 và các tính năng SMB3 khác nhau)
- Aurelien Aptel (dành cho công việc DFS SMB3 và sửa một số lỗi chính)
- Ronnie Sahlberg (cho công việc SMB3 xattr, sửa lỗi và rất nhiều công việc tuyệt vời về kết hợp)
- Shirish Pargaonkar (đối với nhiều bản vá ACL trong những năm qua)
- Sachin Prabhu (sửa nhiều lỗi, bao gồm kết nối lại, giảm tải sao chép và bảo mật)
- Paulo Alcantara (cho một số tác phẩm xuất sắc trong DFS và khi khởi động từ SMB3)
- Long Li (một số tác phẩm tuyệt vời trên RDMA, SMB Direct)


Trường hợp thử nghiệm và người đóng góp Báo cáo lỗi
---------------------------------------------------
Cảm ơn những người trong cộng đồng đã gửi báo cáo lỗi chi tiết
và gỡ lỗi các vấn đề họ đã tìm thấy: Jochen Dolze, David Blaine,
Rene Scharfe, Martin Josefsson, Alexander Wild, Anthony Liguori,
Lars Muller, Urban Widmark, Massimiliano Ferrero, Howard Owen,
Olaf Kirch, Kieron Briggs, Nick Millington và những người khác. Cũng đặc biệt
đề cập đến Stanford Checker (SWAT) đã chỉ ra nhiều lỗi nhỏ
lỗi trong đường dẫn lỗi.  Những gợi ý có giá trị cũng đã đến từ Al Viro
và Dave Miller.

Và xin cảm ơn các nhóm kiểm tra IBM LTC và Power cũng như những người kiểm tra SuSE, Citrix và RedHat vì đã tìm ra nhiều lỗi trong quá trình chạy kiểm tra căng thẳng xuất sắc.
