.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/sgx.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================
Phần mở rộng bảo vệ phần mềm (SGX)
==================================

Tổng quan
=========

Phần cứng Software Guard eXtensions (SGX) hỗ trợ các ứng dụng trong không gian người dùng
để dành các vùng bộ nhớ riêng của mã và dữ liệu:

* Các chức năng ENCLS đặc quyền (ring-0) điều phối việc xây dựng
  các vùng.
* Các chức năng ENCLU không có đặc quyền (ring-3) cho phép ứng dụng truy cập và
  thực hiện bên trong các vùng.

Những vùng nhớ này được gọi là vùng bao quanh. Một vùng đất chỉ có thể được nhập vào tại một
tập hợp các điểm vào cố định. Mỗi điểm vào có thể chứa một luồng phần cứng duy nhất
tại một thời điểm.  Trong khi vùng bao quanh được tải từ tệp nhị phân thông thường bằng cách sử dụng
ENCLS hoạt động, chỉ các luồng bên trong vỏ mới có thể truy cập vào bộ nhớ của nó. các
vùng bị CPU từ chối truy cập từ bên ngoài và được mã hóa trước khi nó rời đi
từ LLC.

Sự hỗ trợ có thể được xác định bằng

ZZ0000ZZ

SGX phải được hỗ trợ trong bộ xử lý và được kích hoạt bởi BIOS.  Nếu SGX
dường như không được hỗ trợ trên hệ thống có hỗ trợ phần cứng, hãy đảm bảo
hỗ trợ được kích hoạt trong BIOS.  Nếu BIOS đưa ra lựa chọn giữa "Đã bật"
và chế độ "Đã bật phần mềm" cho SGX, hãy chọn "Đã bật".

Bộ đệm trang Enclave
====================

SGX sử dụng ZZ0000ZZ để lưu trữ các trang được liên kết
với một khu vực bao quanh. Nó được chứa trong vùng bộ nhớ vật lý dành riêng BIOS.
Không giống như các trang được sử dụng cho bộ nhớ thông thường, các trang chỉ có thể được truy cập từ bên ngoài
vỏ bọc trong quá trình xây dựng vỏ bọc với các hướng dẫn SGX đặc biệt, có giới hạn.

Chỉ CPU thực thi bên trong một khu vực mới có thể truy cập trực tiếp vào bộ nhớ của khu vực đó.
Tuy nhiên, CPU thực thi bên trong một vùng có thể truy cập vào bộ nhớ bình thường bên ngoài vùng đó.
bao vây.

Hạt nhân quản lý bộ nhớ kèm theo tương tự như cách nó xử lý bộ nhớ thiết bị.

Các loại trang kèm theo
-----------------------

ZZ0000ZZ
   Phạm vi địa chỉ, thuộc tính và dữ liệu toàn cầu khác của Enclave được xác định
   bởi cấu trúc này.

ZZ0000ZZ
   Các trang EPC thông thường chứa mã và dữ liệu của một vùng.

ZZ0000ZZ
   Các trang Cấu trúc điều khiển luồng xác định các điểm vào một vùng và
   theo dõi trạng thái thực thi của một luồng kèm theo.

ZZ0000ZZ
   Các trang Mảng phiên bản chứa 512 vị trí, mỗi vị trí có thể chứa một phiên bản
   số cho một trang bị xóa khỏi EPC.

Bản đồ bộ đệm trang Enclave
---------------------------

Bộ xử lý theo dõi các trang EPC trong cấu trúc siêu dữ liệu phần cứng được gọi là
ZZ0000ZZ.  EPCM chứa một mục nhập cho mỗi trang EPC
trong đó mô tả vùng sở hữu, quyền truy cập và loại trang cùng với các phần khác
mọi thứ.

Quyền của EPCM tách biệt với các bảng trang thông thường.  Điều này ngăn cản sự
kernel từ, ví dụ, cho phép ghi vào dữ liệu mà một vùng bao bọc mong muốn
vẫn ở chế độ chỉ đọc.  Quyền EPCM chỉ có thể áp đặt các hạn chế bổ sung đối với
đầu các quyền của trang x86 thông thường.

Đối với mọi ý định và mục đích, kiến trúc SGX cho phép bộ xử lý
vô hiệu hóa tất cả các mục EPCM theo ý muốn.  Điều này đòi hỏi phần mềm phải được chuẩn bị để
xử lý lỗi EPCM bất cứ lúc nào.  Trong thực tế, điều này có thể xảy ra trong các sự kiện như
chuyển đổi nguồn khi mất khóa tạm thời mã hóa bộ nhớ kèm theo.

Giao diện ứng dụng
=====================

Chức năng xây dựng Enclave
--------------------------

Ngoài quá trình xây dựng trình biên dịch và trình liên kết truyền thống, SGX còn có một
quá trình "xây dựng" khu vực riêng biệt.  Các khu vực phải được xây dựng trước khi có thể
được thực hiện (đã nhập). Bước đầu tiên trong việc xây dựng một khu vực là mở
Thiết bị ZZ0000ZZ.  Vì bộ nhớ kèm theo được bảo vệ khỏi sự xâm nhập trực tiếp
truy cập, các hướng dẫn đặc quyền sau đó được sử dụng để sao chép dữ liệu vào vùng
các trang và thiết lập các quyền của trang kèm theo.

.. kernel-doc:: arch/x86/kernel/cpu/sgx/ioctl.c
   :functions: sgx_ioc_enclave_create
               sgx_ioc_enclave_add_pages
               sgx_ioc_enclave_init
               sgx_ioc_enclave_provision

Quản lý thời gian chạy Enclave
------------------------------

Các hệ thống hỗ trợ SGX2 cũng hỗ trợ thêm các thay đổi đối với các thay đổi đã khởi tạo
phần bao quanh: sửa đổi các quyền và loại trang phần bao quanh và tự động
thêm và loại bỏ các trang kèm theo. Khi một vùng đất truy cập vào một địa chỉ
trong phạm vi địa chỉ của nó mà không có trang hỗ trợ thì một trang mới
trang thông thường sẽ được tự động thêm vào vùng này. Khu vực bao quanh là
vẫn cần phải chạy EACCEPT trên trang mới trước khi có thể sử dụng.

.. kernel-doc:: arch/x86/kernel/cpu/sgx/ioctl.c
   :functions: sgx_ioc_enclave_restrict_permissions
               sgx_ioc_enclave_modify_types
               sgx_ioc_enclave_remove_pages

Enclave vDSO
------------

Việc vào khu vực chỉ có thể được thực hiện thông qua EENTER và ERESUME dành riêng cho SGX
chức năng, và là một quá trình không tầm thường.  Vì sự phức tạp của
chuyển đổi đến và đi từ một vùng đất, các vùng đất thường sử dụng thư viện để
xử lý các chuyển đổi thực tế.  Điều này gần giống với cách glibc
việc triển khai được hầu hết các ứng dụng sử dụng để thực hiện các cuộc gọi hệ thống.

Một đặc điểm quan trọng khác của các khu vực bao quanh là chúng có thể tạo ra các ngoại lệ
như một phần hoạt động bình thường của chúng cần được xử lý trong khu vực hoặc
duy nhất cho SGX.

Thay vì cơ chế tín hiệu truyền thống để xử lý các trường hợp ngoại lệ này, SGX
có thể tận dụng bản sửa lỗi ngoại lệ đặc biệt do vDSO cung cấp.  Kernel được cung cấp
Chức năng vDSO bao bọc các chuyển đổi cấp thấp đến/từ vùng bao quanh như EENTER và
ERESUME.  Hàm vDSO chặn các ngoại lệ có thể tạo ra
một tín hiệu và trả lại thông tin lỗi trực tiếp cho người gọi nó.  Điều này tránh
sự cần thiết phải xử lý tín hiệu.

.. kernel-doc:: arch/x86/include/uapi/asm/sgx.h
   :functions: vdso_sgx_enter_enclave_t

ksgxd
=====

Hỗ trợ SGX bao gồm một luồng nhân có tên là ZZ0000ZZ.

Khử trùng EPC
----------------

ksgxd được bắt đầu khi SGX khởi chạy.  Bộ nhớ Enclave thường sẵn sàng
để sử dụng khi bộ xử lý bật hoặc đặt lại.  Tuy nhiên, nếu SGX đã ở
sử dụng kể từ khi thiết lập lại, các trang kèm theo có thể ở trạng thái không nhất quán.  Điều này có thể
xảy ra sau một sự cố và chu kỳ kexec() chẳng hạn.  Khi khởi động, ksgxd
khởi tạo lại tất cả các trang kèm theo để chúng có thể được phân bổ và sử dụng lại.

Việc dọn dẹp được thực hiện bằng cách đi qua không gian địa chỉ EPC và áp dụng
Chức năng EREMOVE cho từng trang vật lý. Một số trang kèm theo như trang SECS có
sự phụ thuộc phần cứng vào các trang khác khiến EREMOVE không thể hoạt động.
Việc thực thi hai lượt EREMOVE sẽ loại bỏ các phần phụ thuộc.

Trình thu hồi trang
-------------------

Tương tự như kswapd lõi, ksgxd, chịu trách nhiệm quản lý
cam kết quá mức của bộ nhớ kèm theo.  Nếu hệ thống hết bộ nhớ kèm theo,
ZZ0000ZZ “hoán đổi” bộ nhớ kèm theo thành bộ nhớ bình thường.

Kiểm soát khởi chạy
===================

SGX cung cấp cơ chế kiểm soát khởi chạy. Sau khi tất cả các trang kèm theo đã được
được sao chép, kernel sẽ thực thi hàm EINIT, khởi tạo vùng bao bọc. Chỉ sau
điều này CPU có thể thực thi bên trong vỏ bọc.

Hàm EINIT lấy chữ ký RSA-3072 của phép đo vùng kín.  chức năng
kiểm tra xem phép đo có đúng không và chữ ký được ký bằng khóa
được băm thành bốn MSR ZZ0000ZZ đại diện cho
SHA256 của khóa công khai.

Những MSR đó có thể được BIOS cấu hình để có thể đọc hoặc ghi được.
Linux chỉ hỗ trợ cấu hình có thể ghi để trao toàn quyền kiểm soát cho
kernel về chính sách kiểm soát khởi chạy. Trước khi gọi chức năng EINIT, trình điều khiển sẽ thiết lập
các MSR để khớp với khóa ký của khu vực.

Công cụ mã hóa
==================

Để che giấu dữ liệu kèm theo khi nó nằm ngoài gói CPU,
bộ điều khiển bộ nhớ có một công cụ mã hóa để mã hóa và giải mã một cách minh bạch
bao bọc bộ nhớ.

Trong các CPU trước Ice Lake, Công cụ mã hóa bộ nhớ (MEE) được sử dụng để
mã hóa các trang rời khỏi bộ đệm CPU. MEE sử dụng cây Merkle n-ary có gốc trong
SRAM để duy trì tính toàn vẹn của dữ liệu được mã hóa. Điều này mang lại tính toàn vẹn và
bảo vệ chống phát lại nhưng không mở rộng được kích thước bộ nhớ lớn vì thời gian
cần thiết để cập nhật cây Merkle tăng theo logarit tương ứng với
kích thước bộ nhớ.

Các CPU bắt đầu từ Icelake sử dụng Mã hóa toàn bộ bộ nhớ (TME) thay cho
MEE. Việc triển khai SGX dựa trên TME không có cây Merkle toàn vẹn.
có nghĩa là tính toàn vẹn và các cuộc tấn công lặp lại không bị giảm nhẹ.  B, nó bao gồm
các thay đổi bổ sung để ngăn văn bản mật mã được trả về và bộ nhớ SW
bí danh được tạo ra.

DMA để bao bọc bộ nhớ bị chặn bởi các thanh ghi phạm vi trên cả hai hệ thống MEE và TME
(SDM phần 41.10).

Mô hình sử dụng
===============

Thư viện chia sẻ
----------------

Dữ liệu nhạy cảm và mã hoạt động trên đó được phân vùng khỏi ứng dụng
vào một thư viện riêng. Thư viện sau đó được liên kết dưới dạng DSO có thể được tải
vào một khu khép kín. Sau đó, ứng dụng có thể thực hiện các lệnh gọi hàm riêng lẻ vào
vỏ bọc thông qua các lệnh SGX đặc biệt. Thời gian chạy trong vùng bao quanh là
được cấu hình để sắp xếp các tham số chức năng vào và ra khỏi vùng và để
gọi đúng chức năng thư viện.

Vùng chứa ứng dụng
---------------------

Một ứng dụng có thể được tải vào một vùng chứa được thiết kế đặc biệt
được cấu hình với hệ điều hành thư viện và thời gian chạy cho phép ứng dụng chạy.
Thời gian chạy kèm theo và hệ điều hành thư viện phối hợp với nhau để thực thi ứng dụng
khi một sợi đi vào vùng bao quanh.

Tác động của lỗi SGX hạt nhân tiềm năng
=======================================

Rò rỉ EPC
---------

Khi xảy ra rò rỉ trang EPC, WARNING như thế này sẽ được hiển thị trong dmesg:

"EREMOVE đã quay trở lại ... và một trang EPC đã bị rò rỉ. SGX có thể không sử dụng được..."

Đây thực sự là một kernel không cần sử dụng sau này của trang EPC, và do
theo cách hoạt động của SGX, lỗi được phát hiện khi giải phóng. Thay vì
thêm trang trở lại nhóm các trang EPC có sẵn, kernel
cố tình rò rỉ trang để tránh các lỗi khác trong tương lai.

Khi điều này xảy ra, kernel có thể sẽ sớm rò rỉ thêm nhiều trang EPC hơn và
SGX có thể sẽ không sử dụng được vì bộ nhớ khả dụng cho SGX đã hết
hạn chế. Tuy nhiên, trong khi điều này có thể gây tử vong cho SGX, phần còn lại của kernel
khó có thể bị ảnh hưởng và nên tiếp tục hoạt động.

Kết quả là, khi điều này xảy ra, người dùng nên ngừng chạy bất kỳ ứng dụng mới nào.
Khối lượng công việc SGX (hoặc bất kỳ khối lượng công việc mới nào) và di chuyển tất cả các khối lượng công việc có giá trị
khối lượng công việc. Mặc dù việc khởi động lại máy có thể khôi phục toàn bộ bộ nhớ EPC nhưng lỗi
nên được báo cáo cho các nhà phát triển Linux.


EPC ảo
===========

Việc triển khai cũng có trình điều khiển EPC ảo để hỗ trợ các vùng SGX
ở khách. Không giống như trình điều khiển SGX, trang EPC được phân bổ bởi máy ảo
Trình điều khiển EPC không có vùng cụ thể được liên kết với nó. Đây là
vì KVM không theo dõi cách khách sử dụng các trang EPC.

Do đó, trình thu hồi trang lõi SGX không hỗ trợ việc xác nhận lại EPC
các trang được phân bổ cho khách KVM thông qua trình điều khiển EPC ảo. Nếu
người dùng muốn triển khai các ứng dụng SGX cả trên máy chủ và máy khách
trên cùng một máy, người dùng nên dự trữ đủ EPC (bằng cách lấy ra
tổng kích thước EPC ảo của tất cả các máy ảo SGX từ kích thước EPC vật lý) cho
lưu trữ các ứng dụng SGX để chúng có thể chạy với hiệu suất chấp nhận được.

Hành vi kiến trúc là khôi phục tất cả các trang EPC về trạng thái chưa được khởi tạo
trạng thái cũng sau khi khởi động lại khách.  Bởi vì trạng thái này chỉ có thể đạt được
thông qua lệnh ZZ0000ZZ đặc quyền, ZZ0001ZZ
cung cấp ZZ0002ZZ ioctl để thực hiện lệnh
trên tất cả các trang trong EPC ảo.

ZZ0000ZZ có thể thất bại vì ba lý do.  Không gian người dùng phải chú ý
những hư hỏng dự kiến và xử lý chúng như sau:

1. Việc xóa trang sẽ luôn thất bại khi có bất kỳ chủ đề nào đang chạy trong
   vùng mà trang đó thuộc về.  Trong trường hợp này, ioctl sẽ
   trả về ZZ0000ZZ độc lập với việc nó đã xóa thành công hay chưa
   một số trang; không gian người dùng có thể tránh những lỗi này bằng cách ngăn chặn việc thực thi
   của bất kỳ vcpu nào ánh xạ EPC ảo.

2. Việc xóa trang sẽ gây ra lỗi bảo vệ chung nếu hai lệnh gọi tới
   ZZ0000ZZ xảy ra đồng thời trên các trang có cùng tham chiếu
   Các trang siêu dữ liệu "SECS".  Điều này có thể xảy ra nếu có sự đồng thời
   lời gọi tới ZZ0001ZZ, hoặc nếu ZZ0002ZZ
   bộ mô tả tập tin trong khách được đóng cùng lúc với
   ZZ0003ZZ; nó cũng sẽ được báo cáo là ZZ0004ZZ.
   Điều này có thể tránh được trong không gian người dùng bằng cách tuần tự hóa các cuộc gọi đến ioctl()
   và đóng(), nhưng nói chung điều đó không thành vấn đề.

3. Cuối cùng, việc xóa trang sẽ không thành công đối với các trang siêu dữ liệu SECS vẫn còn
   có trang con.  Các trang con có thể được loại bỏ bằng cách thực thi
   ZZ0000ZZ trên tất cả các bộ mô tả tệp ZZ0001ZZ
   ánh xạ vào khách.  Điều này có nghĩa là ioctl() phải được gọi
   hai lần: một loạt lệnh gọi ban đầu để xóa các trang con và một lần tiếp theo
   tập hợp các lệnh gọi để xóa các trang SECS.  Nhóm cuộc gọi thứ hai chỉ
   cần thiết cho những ánh xạ trả về giá trị khác 0 từ
   cuộc gọi đầu tiên.  Nó chỉ ra một lỗi trong kernel hoặc ứng dụng khách không gian người dùng
   nếu bất kỳ cuộc gọi ZZ0002ZZ nào trong vòng thứ hai có
   mã trả về khác 0.