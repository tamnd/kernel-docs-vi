.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/xen-tpmfront.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

================================
Giao diện TPM ảo cho Xen
=============================

Tác giả: Matthew Fioravante (JHUAPL), Daniel De Graaf (NSA)

Tài liệu này mô tả hệ thống con Mô-đun nền tảng đáng tin cậy (vTPM) ảo cho
Xen. Người đọc được cho là đã quen với việc xây dựng và cài đặt Xen,
Linux và hiểu biết cơ bản về các khái niệm TPM và vTPM.

Giới thiệu
------------

Mục tiêu của công việc này là cung cấp chức năng TPM cho khách ảo
hệ điều hành (theo thuật ngữ Xen là DomU).  Điều này cho phép các chương trình tương tác với
TPM trong hệ thống ảo giống như cách chúng tương tác với TPM trên hệ thống vật lý
hệ thống.  Mỗi khách sẽ có phần mềm mô phỏng TPM độc đáo của riêng mình.  Tuy nhiên, mỗi
các bí mật của vTPM (Khóa, NVRAM, v.v.) được quản lý bởi miền vTPM Manager,
nơi phong ấn các bí mật của TPM vật lý.  Nếu quá trình tạo ra mỗi
các miền này (người quản lý, vTPM và khách) được tin cậy, hệ thống con vTPM sẽ mở rộng
chuỗi tin cậy bắt nguồn từ phần cứng TPM đến các máy ảo trong Xen. Mỗi
thành phần chính của vTPM được triển khai dưới dạng một miền riêng biệt, cung cấp tính bảo mật
sự tách biệt được đảm bảo bởi hypervisor. Các miền vTPM được triển khai trong
mini-os để giảm chi phí bộ nhớ và bộ xử lý.

Hệ thống con vTPM mini-os này được xây dựng dựa trên công việc vTPM trước đó được thực hiện bởi
IBM và tập đoàn Intel.


Tổng quan về thiết kế
---------------

Kiến trúc của vTPM được mô tả dưới đây:

+-------------------+
  ZZ0000ZZ ...
  ZZ0001ZZ ^ |
  ZZ0002ZZ |
  ZZ0003ZZ
  +-------------------+
          |  ^
          v |
  +-------------------+
  ZZ0004ZZ
  ZZ0005ZZ ^ |
  ZZ0006ZZ |
  ZZ0007ZZ ...
  ZZ0008ZZ ^ |
  ZZ0009ZZ |
  ZZ0010ZZ
  +-------------------+
          |  ^
          v |
  +-------------------+
  ZZ0011ZZ
  ZZ0012ZZ ^ |
  ZZ0013ZZ |
  ZZ0014ZZ
  ZZ0015ZZ ^ |
  ZZ0016ZZ |
  ZZ0017ZZ
  +-------------------+
          |  ^
          v |
  +-------------------+
  ZZ0018ZZ
  +-------------------+

* Linux DomU:
	       Khách dựa trên Linux muốn sử dụng vTPM. Có thể có
	       nhiều hơn một trong số này

* xen-tpmfront.ko:
		    Trình điều khiển giao diện ảo TPM của nhân Linux. Người lái xe này
                    cung cấp quyền truy cập vTPM vào DomU dựa trên Linux.

* mini-os/tpmback:
		    Trình điều khiển phụ trợ Mini-os TPM. Trình điều khiển giao diện người dùng Linux
		    kết nối với trình điều khiển phụ trợ này để tạo điều kiện liên lạc
		    giữa Linux DomU và vTPM của nó. Người lái xe này cũng
		    được sử dụng bởi vtpmmgr-stubdom để giao tiếp với vtpm-stubdom.

* vtpm-stubdom:
		 Một miền sơ khai hệ điều hành mini triển khai vTPM. có một
		 ánh xạ 1-1 giữa các phiên bản vtpm-stubdom đang chạy và
                 vtpms logic trên hệ thống. Cấu hình nền tảng vTPM
                 Các thanh ghi (PCR) thường được khởi tạo về 0.

* mini-os/tpmfront:
		     Trình điều khiển giao diện Mini-os TPM. Miền mini-os vTPM
		     vtpm-stubdom sử dụng trình điều khiển này để liên lạc với
		     vtpmmgr-stubdom. Driver này cũng được dùng trong mini-os
		     các miền như pv-grub giao tiếp với miền vTPM.

* vtpmmgr-stubdom:
		    Một miền mini-os triển khai trình quản lý vTPM. có
		    chỉ có một trình quản lý vTPM và nó sẽ chạy trong suốt quá trình
		    toàn bộ tuổi thọ của máy.  Miền này quy định
		    truy cập vào TPM vật lý trên hệ thống và bảo mật
		    trạng thái liên tục của mỗi vTPM.

* mini-os/tpm_tis:
		    Mini-os TPM phiên bản 1.2 TPM Thông số giao diện (TIS)
                    người lái xe. Trình điều khiển này được vtpmmgr-stubdom sử dụng để nói chuyện trực tiếp với
                    phần cứng TPM. Giao tiếp được tạo điều kiện thuận lợi bằng cách lập bản đồ
                    các trang bộ nhớ phần cứng vào vtpmmgr-stubdom.

* Phần cứng TPM:
		TPM vật lý được hàn vào bo mạch chủ.


Tích hợp với Xen
--------------------

Hỗ trợ cho trình điều khiển vTPM đã được thêm vào Xen bằng cách sử dụng bộ công cụ libxl trong Xen
4.3.  Xem tài liệu Xen (docs/misc/vtpm.txt) để biết chi tiết về cách thiết lập
tên miền sơ khai vTPM và vTPM Manager.  Khi các miền sơ khai đang chạy, một
Thiết bị vTPM được thiết lập theo cách tương tự như thiết bị đĩa hoặc mạng trong
tập tin cấu hình của tên miền.

Để sử dụng các tính năng như IMA yêu cầu phải tải TPM trước
initrd, trình điều khiển xen-tpmfront phải được biên dịch vào kernel.  Nếu không
bằng cách sử dụng các tính năng như vậy, trình điều khiển có thể được biên dịch thành một mô-đun và sẽ được tải
như thường lệ.
