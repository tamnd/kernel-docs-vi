.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/xtensa/atomctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===============================================
Đăng ký điều khiển hoạt động nguyên tử (ATOMCTL)
===========================================

Chúng tôi có Đăng ký Kiểm soát Hoạt động Nguyên tử (ATOMCTL).
Thanh ghi này xác định hiệu quả của việc sử dụng lệnh S32C1I
với sự kết hợp khác nhau của:

1. Có và không có Bộ điều khiển bộ đệm kết hợp
        có thể thực hiện các Giao dịch nguyên tử vào bộ nhớ bên trong.

2. Có và không có Bộ điều khiển bộ nhớ thông minh
        có thể tự thực hiện các Giao dịch nguyên tử.

Core đưa ra giá trị mặc định cho ba loại hoạt động bộ nhớ đệm::

0x28: (WB: Nội bộ, WT: Nội bộ, BY:Ngoại lệ)

Trên Thẻ FPGA, chúng tôi thường mô phỏng bộ điều khiển Bộ nhớ thông minh
có thể thực hiện các giao dịch RCW. Đối với thẻ FPGA có gắn ngoài
Bộ điều khiển bộ nhớ, chúng tôi cho phép nó thực hiện các hoạt động nguyên tử bên trong trong khi
thực hiện giao dịch được lưu trong bộ nhớ đệm (WB) và sử dụng Bộ nhớ RCW để xóa bộ nhớ đệm
hoạt động.

Đối với các hệ thống không có bộ điều khiển bộ nhớ đệm nhất quán, không phải MX, chúng tôi luôn
sử dụng bộ điều khiển bộ nhớ RCW, mặc dù có thể các bộ điều khiển không phải MX
hỗ trợ hoạt động nội bộ.

CUSTOMER-WARNING:
   Hầu như tất cả khách hàng đều mua bộ điều khiển bộ nhớ của họ từ các nhà cung cấp
   không hỗ trợ các giao dịch bộ nhớ RCW nguyên tử và có thể sẽ muốn
   định cấu hình thanh ghi này để không sử dụng RCW.

Các nhà phát triển có thể thấy việc sử dụng RCW ở chế độ Bỏ qua là thuận tiện khi thử nghiệm
với bộ nhớ đệm bị bỏ qua; ví dụ như nghiên cứu các vấn đề về bí danh bộ đệm.

Xem Phần 4.3.12.4 của ISA; Bit::

WB WT BỞI
                           5 4 ZZ0000ZZ 1 0

=============================================== =================
  2 bit
  trường
  Giá trị WB - Viết lại WT - Viết qua BY - Bỏ qua
=============================================== =================
    0 Ngoại lệ Ngoại lệ Ngoại lệ
    1 Giao dịch RCW Giao dịch RCW Giao dịch RCW
    2 Hoạt động nội bộ Hoạt động nội bộ Dự trữ
    3 Dành riêng Dành riêng Dành riêng
=============================================== =================
