.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/kaslr-booke32.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==============================
KASLR dành cho Freescale BookE32
===========================

Từ KASLR là viết tắt của Ngẫu nhiên bố cục không gian địa chỉ hạt nhân.

Tài liệu này cố gắng giải thích việc triển khai KASLR cho
Sách FreescaleE32. KASLR là tính năng bảo mật ngăn chặn việc khai thác
nỗ lực dựa vào kiến thức về vị trí của các phần bên trong hạt nhân.

Vì CONFIG_RELOCATABLE đã được hỗ trợ nên điều chúng ta cần làm là
ánh xạ hoặc sao chép kernel đến một nơi thích hợp và di chuyển. Sách Freescale-E
các bộ phận mong muốn lowmem được ánh xạ bởi các mục TLB cố định (TLB1). TLB1
các mục không phù hợp để ánh xạ hạt nhân trực tiếp theo kiểu ngẫu nhiên
vùng, vì vậy chúng tôi đã chọn sao chép kernel vào một nơi thích hợp và khởi động lại vào
di dời.

Entropy có nguồn gốc từ cơ sở biểu ngữ và bộ đếm thời gian, sẽ thay đổi mỗi
xây dựng và khởi động. Điều này không an toàn lắm nên ngoài ra bộ nạp khởi động có thể
truyền entropy qua nút /chosen/kaslr-seed trong cây thiết bị.

Chúng tôi sẽ sử dụng 512M đầu tiên của bộ nhớ thấp để ngẫu nhiên hóa kernel
hình ảnh. Bộ nhớ sẽ được chia thành các vùng 64M. Chúng ta sẽ sử dụng số 8 thấp hơn
bit entropy để quyết định chỉ số của vùng 64M. Sau đó chúng tôi chọn một
Độ lệch căn chỉnh 16K bên trong vùng 64M để đặt kernel vào ::

KERNELBASE

ZZ0000ZZ
        ZZ0001ZZ
        +--------------+ +----------------+---------------+
        ZZ0002ZZ....|    |kernel|    | |
        +--------------+ +----------------+---------------+
        ZZ0005ZZ
        ZZ0006ZZ

kernstart_virt_addr

Để bật KASLR, hãy đặt CONFIG_RANDOMIZE_BASE = y. Nếu KASLR được bật và bạn
muốn tắt nó khi chạy, hãy thêm "nokaslr" vào dòng lệnh kernel.