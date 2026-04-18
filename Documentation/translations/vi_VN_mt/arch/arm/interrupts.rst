.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/interrupts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========
Ngắt
===========

2.5.2-rmk5:
  Đây là hạt nhân đầu tiên có sự thay đổi lớn về một số
  các hệ thống con có kiến trúc cụ thể chính.

Thứ nhất, nó chứa đựng một số thay đổi khá lớn về cách chúng ta xử lý
MMU TLB.  Mỗi biến thể MMU TLB hiện được xử lý hoàn toàn riêng biệt -
chúng tôi có TLB v3, TLB v4 (không có bộ đệm ghi), TLB v4 (có bộ đệm ghi),
và cuối cùng là TLB v4 (có bộ đệm ghi, với mục nhập I TLB không hợp lệ).
Có nhiều mã hợp ngữ hơn bên trong mỗi hàm này, chủ yếu để
cho phép xử lý TLB linh hoạt hơn trong tương lai.

Thứ hai, hệ thống con IRQ.

Hạt nhân 2.5 sẽ có những thay đổi lớn về cách xử lý IRQ.
Thật không may, điều này có nghĩa là các loại máy chạm vào irq_desc[]
mảng (về cơ bản là tất cả các loại máy) sẽ bị hỏng và điều này có nghĩa là mọi
loại máy mà chúng tôi hiện có.

Hãy lấy một ví dụ.  Trên Assabet với Neponset, chúng tôi có::

GPIO25 IRR:2
        SA1100 -----------> Neponset -----------> SA1111
                                         IIR:1
                                      -------> USAR
                                         IIR:0
                                      -----------> SMC9196

Cách thức hoạt động hiện tại, tất cả các ngắt SA1111 đều được thực hiện lẫn nhau
loại trừ lẫn nhau - nếu bạn đang xử lý một ngắt từ
SA1111 và một cái khác xuất hiện, bạn phải đợi sự gián đoạn đó xảy ra
kết thúc quá trình xử lý trước khi bạn có thể phục vụ ngắt mới.  Ví dụ, một
IDE Ngắt dựa trên PIO trên SA1111 loại trừ tất cả các SA1111 khác và
SMC9196 ngắt cho đến khi truyền xong đa khu vực của nó
dữ liệu, có thể là một thời gian dài.  Cũng lưu ý rằng vì chúng ta lặp lại trong
Trình xử lý SA1111 IRQ, IRQ SA1111 có thể giữ IRQ SMC9196 vô thời hạn.


Cách tiếp cận mới mang lại nhiều ý tưởng mới...

Chúng tôi giới thiệu khái niệm về "cha mẹ" và "con".  Ví dụ,
đối với trình xử lý Neponset, "mẹ" là GPIO25 và "con" d
là SA1111, SMC9196 và USAR.

Chúng tôi cũng đưa ra ý tưởng về một "chip" IRQ (chủ yếu để giảm kích thước của
mảng irqdesc).  Đây không nhất thiết phải là một "IC" thực sự; thực sự là
IRQ SA11x0 được xử lý bởi hai cấu trúc "chip" riêng biệt, một dành cho
GPIO0-10 và một cái khác cho tất cả những thứ còn lại.  Nó chỉ là nơi chứa đựng
các hoạt động khác nhau (có thể tên này sẽ đổi thành tên hay hơn).
This structure has the following operations::

cấu trúc irqchip {
          /*
           * Xác nhận IRQ.
           * Nếu đây là IRQ dựa trên cấp độ thì dự kiến nó sẽ che giấu IRQ
           * cũng vậy.
           */
          void (*ack)(unsign int irq);
          /*
           * Che dấu IRQ trong phần cứng.
           */
          void (*mask)(unsign int irq);
          /*
           * Vạch mặt IRQ trong phần cứng.
           */
          void (* vạch mặt)(unsigned int irq);
          /*
           * Chạy lại IRQ
           */
          void (*chạy lại)(unsigned int irq);
          /*
           * Đặt loại IRQ.
           */
          int (*type)(unsigned int irq, unsigned int, type);
  };

ách
       - bắt buộc.  Có thể có chức năng tương tự như mặt nạ cho IRQ
         được xử lý bởi do_level_IRQ.
mặt nạ
       - bắt buộc.
lột mặt nạ
       - bắt buộc.
chạy lại
       - tùy chọn.  Không bắt buộc nếu bạn đang sử dụng do_level_IRQ cho tất cả
         IRQ sử dụng 'irqchip' này.  Nói chung dự kiến ​​sẽ kích hoạt lại
         phần cứng IRQ nếu có thể.  Nếu không, có thể gọi người xử lý
	 trực tiếp.
loại
       - tùy chọn.  Nếu bạn không hỗ trợ thay đổi loại IRQ,
         nó phải là null để mọi người có thể phát hiện nếu họ không thể
         đặt loại IRQ.

Đối với mỗi IRQ, chúng tôi lưu giữ các thông tin sau:

- độ sâu "vô hiệu hóa" (số lượng vô hiệu hóa_irq()s không có Enable_irq()s)
        - cờ cho biết chúng tôi có thể làm gì với IRQ này (hợp lệ, thăm dò,
          noautounmask) như trước
        - trạng thái của IRQ (đang thăm dò, kích hoạt, v.v.)
        - chip
        - trình xử lý mỗi IRQ
        - danh sách cấu trúc phản ứng

Trình xử lý có thể là một trong 3 trình xử lý tiêu chuẩn - "level", "edge" và
"đơn giản" hoặc trình xử lý cụ thể của riêng bạn nếu bạn cần làm điều gì đó đặc biệt.

Trình xử lý "cấp độ" là những gì chúng tôi hiện có - nó khá đơn giản.
"edge" biết về sự sai sót của việc triển khai IRQ như vậy - rằng bạn
cần phải bật phần cứng IRQ trong khi xử lý nó và xếp hàng
các sự kiện IRQ tiếp theo nếu IRQ xảy ra lần nữa trong khi xử lý.  các
trình xử lý "đơn giản" rất cơ bản và không thực hiện bất kỳ phần cứng nào
thao tác, cũng như theo dõi trạng thái.  Điều này rất hữu ích cho những việc như
SMC9196 và USAR ở trên.

Vì vậy, những gì đã thay đổi?
=============================

1. Việc triển khai máy không được ghi vào mảng irqdesc.

2. Các hàm mới để thao tác với mảng irqdesc.  4 cái đầu tiên được mong đợi
   chỉ hữu ích cho mã cụ thể của máy.  Điều cuối cùng được khuyến nghị là
   chỉ được sử dụng theo mã cụ thể của máy, nhưng có thể được sử dụng trong trình điều khiển nếu
   hoàn toàn cần thiết.

set_irq_chip(irq,chip)
                Đặt phương pháp mặt nạ/vạch mặt để xử lý IRQ này

set_irq_handler(irq,handler)
                Đặt trình xử lý cho IRQ này (cấp độ, cạnh, đơn giản)

set_irq_chained_handler(irq,handler)
                Đặt trình xử lý "xích" cho IRQ này - tự động
                kích hoạt IRQ này (ví dụ: trình xử lý Neponset và SA1111).

set_irq_flags(irq,flags)
                Đặt cờ hợp lệ/thăm dò/không thể tự động bật.

set_irq_type(irq,type)
                Thiết lập kích hoạt (các) cạnh/cấp IRQ.  Điều này thay thế
                Thao tác SA1111 INTPOL và set_GPIO_IRQ_edge()
                chức năng.  Loại phải là một trong IRQ_TYPE_xxx được xác định trong
		<linux/irq.h>

3. set_GPIO_IRQ_edge() đã lỗi thời và cần được thay thế bằng set_irq_type.

4. Truy cập trực tiếp vào SA1111 INTPOL không được dùng nữa.  Thay vào đó hãy sử dụng set_irq_type.

5. Người xử lý phải thực hiện bất kỳ xác nhận cần thiết nào về
   cha mẹ IRQ thông qua chức năng cụ thể của chip.  Ví dụ, nếu
   SA1111 được kết nối trực tiếp với SA1110 GPIO, thì bạn nên
   xác nhận SA1110 IRQ mỗi lần bạn đọc lại trạng thái SA1111 IRQ.

6. Đối với bất kỳ đứa trẻ nào không có điều khiển bật/tắt IRQ riêng
   (ví dụ: SMC9196), trình xử lý phải che dấu hoặc thừa nhận IRQ gốc
   trong khi trình xử lý con được gọi và trình xử lý con phải là
   trình xử lý "đơn giản" (không phải "cạnh" hay "cấp độ").  Sau khi trình xử lý hoàn tất,
   IRQ gốc phải được vạch mặt và trạng thái của tất cả trẻ em phải
   được kiểm tra lại cho các sự kiện đang chờ xử lý.  (xem bộ xử lý Neponset IRQ để biết
   chi tiết).

7. fixup_irq() không còn nữa, ZZ0000ZZ cũng vậy

Xin lưu ý rằng cách này sẽ không giải quyết được mọi vấn đề - một số vấn đề
dựa trên phần cứng.  Trộn các IRQ dựa trên cấp độ và cạnh trên cùng một
tín hiệu gốc (ví dụ neponset) là một trong những lĩnh vực mà phần mềm dựa trên
giải pháp không thể cung cấp câu trả lời đầy đủ cho độ trễ IRQ thấp.
