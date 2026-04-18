.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/adfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Hệ thống lưu trữ đĩa Acorn - ADFS
==================================

Hệ thống tập tin được hỗ trợ bởi ADFS
-----------------------------

Mô-đun ADFS hỗ trợ các định dạng Filecore sau:

- bản đồ mới
- thư mục mới hoặc thư mục lớn

Về các định dạng được đặt tên, điều này có nghĩa là chúng tôi hỗ trợ:

- E và E+, có hoặc không có khối khởi động
- F và F+

Chúng tôi hỗ trợ đầy đủ việc đọc tệp từ các hệ thống tệp này và ghi vào
các tập tin hiện có trong phân bổ hiện có của họ.  Về cơ bản, chúng tôi làm
không hỗ trợ thay đổi bất kỳ siêu dữ liệu hệ thống tập tin nào.

Điều này nhằm hỗ trợ các hệ thống tập tin gốc Linux được gắn loopback
trên hệ thống tệp Filecore của RISC OS, nhưng sẽ cho phép dữ liệu trong các tệp
được thay đổi.

Nếu hỗ trợ ghi (ADFS_FS_RW) được định cấu hình, chúng tôi cho phép
cập nhật thư mục, cụ thể là cập nhật chế độ truy cập và dấu thời gian.

Tùy chọn gắn kết cho ADFS
----------------------

============= ===========================================================
  uid=nnn Tất cả các tập tin trong phân vùng sẽ thuộc quyền sở hữu của
		id người dùng nnn.  Mặc định 0 (gốc).
  gid=nnn Tất cả các tệp trong phân vùng sẽ nằm trong nhóm
		nn.  Mặc định 0 (gốc).
  ownmask=nnn Mặt nạ cấp phép cho các quyền của 'chủ sở hữu' ADFS
		sẽ là nnn.  Mặc định 0700.
  othmask=nnn Mặt nạ cấp phép cho các quyền 'khác' của ADFS
		sẽ là nnn.  Mặc định 0077.
  ftsuffix=n Khi ftsuffix=0, sẽ không có hậu tố loại tệp nào được áp dụng.
		Khi ftsuffix=1, hậu tố thập lục phân tương ứng với
		loại tệp hệ điều hành RISC sẽ được thêm vào.  Mặc định 0.
  ============= ===========================================================

Ánh xạ các quyền ADFS sang các quyền Linux
------------------------------------------------

Các quyền của ADFS bao gồm:

- Chủ đọc
	- Chủ sở hữu viết
	- Đọc khác
	- Viết khác

(Trong các phiên bản cũ hơn, quyền 'thực thi' đã tồn tại, nhưng quyền này
  không có cùng ý nghĩa với quyền 'thực thi' Linux
  và bây giờ đã lỗi thời).

Việc ánh xạ được thực hiện như sau::

Chủ sở hữu đã đọc -> -r--r--r--
	Chủ sở hữu viết -> --w--w---w
	Chủ sở hữu đọc và gõ tệp UnixExec -> ---x--x--x
    Những thứ này sau đó được che bởi ownmask, ví dụ: 700 -> -rwx------
	Quyền chế độ chủ sở hữu có thể có -> -rwx------

Đọc khác -> -r--r--r--
	Viết khác -> --w--w--w-
	Kiểu đọc và kiểu tệp khác UnixExec -> ---x--x--x
    Những thứ này sau đó được che bởi othmask, ví dụ: 077 -> ----rwxrwx
	Các quyền chế độ khác có thể có -> ----rwxrwx

Do đó, với các mặt nạ mặc định, nếu một tệp được chủ sở hữu đọc/ghi và
  không phải là kiểu tệp UnixExec, thì các quyền sẽ là::

-rw-------

Tuy nhiên, nếu mặt nạ là ownmask=0770,othmask=0007 thì điều này sẽ
  được sửa đổi thành::

-rw-rw----

Không có hạn chế về những gì bạn có thể làm với những chiếc mặt nạ này.  Bạn có thể
  mong muốn rằng tất cả các bit đọc đều cung cấp quyền truy cập đọc vào tệp, nhưng
  giữ nguyên chế độ bảo vệ ghi mặc định (ownmask=0755,othmask=0577)::

-rw-r--r--

Do đó, bạn có thể điều chỉnh bản dịch quyền theo bất cứ điều gì bạn
  mong muốn các quyền phải có trong Linux.

Hậu tố loại tệp hệ điều hành RISC
------------------------

Các loại tệp hệ điều hành RISC được lưu trữ ở bit 19..8 của địa chỉ tải tệp.

Để cho phép sử dụng các hệ điều hành không phải RISC để lưu trữ tệp mà không làm mất
  thông tin về loại tập tin, một quy ước đặt tên tập tin đã được đưa ra (ban đầu
  để sử dụng với NFS) sao cho hậu tố thập lục phân có dạng ,xyz
  biểu thị loại tệp: ví dụ: BasicFile,ffb là tệp BASIC (0xffb).  Cái này
  quy ước đặt tên hiện cũng được sử dụng bởi các trình giả lập hệ điều hành RISC như RPCEmu.

Việc gắn đĩa ADFS với tùy chọn ftsuffix=1 sẽ tạo ra tệp thích hợp
  hậu tố gõ được thêm vào tên tệp được đọc từ một thư mục.  Nếu
  tùy chọn ftsuffix bằng 0 hoặc bị bỏ qua, sẽ không có hậu tố loại tệp nào được thêm vào.