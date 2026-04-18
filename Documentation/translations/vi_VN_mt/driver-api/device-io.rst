.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/driver-api/device-io.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. Copyright 2001 Matthew Wilcox
................................
..     This documentation is free software; you can redistribute
..     it and/or modify it under the terms of the GNU General Public
..     License as published by the Free Software Foundation; either
..     version 2 of the License, or (at your option) any later
..     version.

==================================
Truy cập thiết bị độc lập với bus
==================================

:Tác giả: Matthew Wilcox
:Tác giả: Alan Cox

Giới thiệu
============

Linux cung cấp API để tóm tắt việc thực hiện IO trên tất cả các xe buýt
và thiết bị, cho phép trình điều khiển thiết bị được viết độc lập với bus
loại.

IO được ánh xạ bộ nhớ
=====================

Nhận quyền truy cập vào thiết bị
--------------------------------

Dạng IO được hỗ trợ rộng rãi nhất là IO được ánh xạ bộ nhớ. Đó là, một
một phần không gian địa chỉ của CPU được hiểu không phải là quyền truy cập vào
bộ nhớ mà là quyền truy cập vào một thiết bị. Một số kiến trúc xác định các thiết bị
ở một địa chỉ cố định, nhưng hầu hết đều có một số phương pháp để khám phá
thiết bị. Tuyến xe buýt đi bộ PCI là một ví dụ điển hình cho kế hoạch như vậy. Cái này
tài liệu không đề cập đến cách nhận địa chỉ đó nhưng giả sử bạn
đang bắt đầu với một. Địa chỉ vật lý thuộc loại không dấu dài.

Địa chỉ này không nên được sử dụng trực tiếp. Thay vào đó, để có được một địa chỉ
thích hợp để chuyển sang các hàm truy cập được mô tả bên dưới, bạn
nên gọi ioremap(). Một địa chỉ phù hợp để truy cập
thiết bị sẽ được trả lại cho bạn.

Sau khi bạn sử dụng xong thiết bị (giả sử trong lối ra của mô-đun
thường lệ), hãy gọi iounmap() để trả về địa chỉ
không gian cho hạt nhân. Hầu hết các kiến trúc đều phân bổ không gian địa chỉ mới cho mỗi
thời gian bạn gọi ioremap() và chúng có thể hết trừ khi bạn
gọi iounmap().

Truy cập thiết bị
--------------------

Phần giao diện được trình điều khiển sử dụng nhiều nhất là đọc và viết
các thanh ghi được ánh xạ bộ nhớ trên thiết bị. Linux cung cấp giao diện để đọc
và ghi các số lượng 8 bit, 16 bit, 32 bit và 64 bit. Do một
tai nạn lịch sử, chúng được đặt tên theo byte, từ, truy cập dài và truy cập quad.
Cả quyền truy cập đọc và ghi đều được hỗ trợ; không có hỗ trợ tìm nạp trước
vào lúc này.

Các hàm được đặt tên là readb(), readw(), readl(), readq(),
readb_relaxed(), readw_relaxed(), readl_relaxed(), readq_relaxed(),
writeb(), writew(), writel() và writeq().

Một số thiết bị (chẳng hạn như bộ đệm khung) muốn sử dụng tốc độ truyền lớn hơn
8 byte mỗi lần. Đối với các thiết bị này, memcpy_toio(),
Các hàm memcpy_fromio() và memset_io() là
được cung cấp. Không sử dụng memset hoặc memcpy trên địa chỉ IO; họ không phải
đảm bảo sao chép dữ liệu theo thứ tự.

Các chức năng đọc và ghi được xác định theo thứ tự. Đó là
trình biên dịch không được phép sắp xếp lại trình tự I/O. Khi đặt hàng
có thể được tối ưu hóa trình biên dịch, bạn có thể sử dụng __readb() và bạn bè để
biểu thị trật tự thoải mái. Sử dụng cái này một cách cẩn thận.

Trong khi các chức năng cơ bản được xác định là đồng bộ đối với
nhau và ra lệnh cho nhau các xe buýt các thiết bị
ngồi trên có thể tự mình có sự không đồng bộ. Đặc biệt nhiều tác giả
bị đốt cháy bởi thực tế là việc ghi bus PCI được đăng không đồng bộ. A
tác giả trình điều khiển phải đưa ra lệnh đọc từ cùng một thiết bị để đảm bảo rằng
viết đã xảy ra trong các trường hợp cụ thể mà tác giả quan tâm. Loại này
thuộc tính không thể bị ẩn khỏi người viết trình điều khiển trong API. Ở một số
trong các trường hợp, quá trình đọc được sử dụng để xả thiết bị có thể sẽ thất bại (nếu
ví dụ như thẻ đang được đặt lại). Trong trường hợp đó, việc đọc nên được thực hiện
từ không gian cấu hình, được đảm bảo sẽ bị lỗi phần mềm nếu thẻ không
đáp lại.

Sau đây là ví dụ về việc thực hiện thao tác ghi vào thiết bị khi
người lái xe muốn đảm bảo rằng các hiệu ứng ghi được hiển thị trước khi
tiếp tục thực hiện::

khoảng trống nội tuyến tĩnh
    qla1280_disable_intrs(struct scsi_qla_host *ha)
    {
        struct device_reg *reg;

reg = ha->iobase;
        /* vô hiệu hóa các ngắt risc và máy chủ */
        WRT_REG_WORD(&reg->ictrl, 0);
        /*
         * Việc đọc sau sẽ đảm bảo cho việc viết ở trên
         * đã được thiết bị nhận trước khi chúng tôi quay lại từ đây
         *chức năng.
         */
        RD_REG_WORD(&reg->ictrl);
        ha->flags.ints_enabled = 0;
    }

Quy tắc đặt hàng PCI cũng đảm bảo rằng phản hồi đọc PIO sẽ đến sau bất kỳ
DMA nổi bật ghi từ bus đó, vì đối với một số thiết bị, kết quả của
lệnh gọi readb() có thể báo hiệu cho trình điều khiển rằng giao dịch DMA đang được thực hiện
hoàn thành. Tuy nhiên, trong nhiều trường hợp, người lái xe có thể muốn chỉ ra rằng
lệnh gọi readb() tiếp theo không liên quan đến bất kỳ lần ghi DMA nào trước đó
được thực hiện bởi thiết bị. Trình điều khiển có thể sử dụng readb_relaxed() cho
những trường hợp này, mặc dù chỉ một số nền tảng sẽ tôn trọng sự thoải mái
ngữ nghĩa. Việc sử dụng các chức năng đọc thoải mái sẽ mang lại hiệu quả đáng kể
lợi ích hiệu suất trên các nền tảng hỗ trợ nó. Trình điều khiển qla2xxx
cung cấp các ví dụ về cách sử dụng readX_relaxed(). Trong nhiều trường hợp, đa số
trong số các lệnh gọi readX() của trình điều khiển có thể được chuyển đổi thành readX_relaxed() một cách an toàn
vì chỉ một số cuộc gọi sẽ chỉ ra hoặc phụ thuộc vào việc hoàn thành DMA.

Truy cập không gian cổng
========================

Giải thích về không gian cổng
-----------------------------

Một dạng IO khác thường được hỗ trợ là Port Space. Đây là một loạt các
địa chỉ tách biệt với không gian địa chỉ bộ nhớ thông thường. Truy cập vào những thứ này
địa chỉ thường không nhanh bằng truy cập vào bộ nhớ được ánh xạ
địa chỉ, và nó cũng có không gian địa chỉ nhỏ hơn.

Không giống như IO được ánh xạ bộ nhớ, không cần chuẩn bị gì để truy cập cổng
không gian.

Truy cập không gian cổng
------------------------

Quyền truy cập vào không gian này được cung cấp thông qua một tập hợp các chức năng
cho phép truy cập 8 bit, 16 bit và 32 bit; còn được gọi là byte, word và
dài. Các hàm này là inb(), inw(),
inl(), outb(), outw() và
outl().

Một số biến thể được cung cấp cho các chức năng này. Một số thiết bị yêu cầu
việc truy cập vào cổng của họ bị chậm lại. Chức năng này là
được cung cấp bằng cách thêm ZZ0000ZZ vào cuối hàm.
Ngoài ra còn có tương đương với memcpy. ins() và
Hàm outs() sao chép byte, từ hoặc độ dài vào giá trị đã cho
cổng.

__mã thông báo con trỏ iomem
============================

Kiểu dữ liệu cho địa chỉ MMIO là một con trỏ đủ tiêu chuẩn ZZ0000ZZ, chẳng hạn như
ZZ0001ZZ. Trên hầu hết các kiến trúc, nó là một con trỏ thông thường
trỏ đến một địa chỉ bộ nhớ ảo và có thể được bù đắp hoặc hủy đăng ký, nhưng trong
mã di động, nó chỉ phải được truyền từ và tới các hàm rõ ràng
hoạt động trên mã thông báo ZZ0002ZZ, đặc biệt là ioremap() và
các hàm readl()/writel(). Trình kiểm tra mã ngữ nghĩa 'thưa thớt' có thể được sử dụng để
xác minh rằng việc này được thực hiện chính xác.

Trong khi trên hầu hết các kiến trúc, ioremap() tạo một mục trong bảng trang cho một
địa chỉ ảo không được lưu vào bộ đệm trỏ đến địa chỉ MMIO vật lý, một số
kiến trúc yêu cầu hướng dẫn đặc biệt cho MMIO và con trỏ ZZ0000ZZ
chỉ mã hóa địa chỉ vật lý hoặc cookie có thể bù đắp được diễn giải
bởi readl()/writel().

Sự khác biệt giữa các chức năng truy cập I/O
============================================

readq(), readl(), readw(), readb(), writeq(), writel(), writew(), writeb()

Đây là những trình truy cập chung nhất, cung cấp khả năng tuần tự hóa đối với các trình truy cập khác
  Truy cập MMIO và truy cập DMA cũng như độ bền cố định để truy cập
  các thiết bị PCI endian nhỏ và các thiết bị ngoại vi trên chip. Trình điều khiển thiết bị di động
  thường nên sử dụng những thứ này để truy cập vào con trỏ ZZ0000ZZ.

Lưu ý rằng việc ghi đã đăng không được sắp xếp nghiêm ngặt đối với khóa quay, xem
  Tài liệu/driver-api/io_ordering.rst.

readq_relaxed(), readl_relaxed(), readw_relaxed(), readb_relaxed(),
writeq_relaxed(), writel_relaxed(), writew_relaxed(), writeb_relaxed()

Trên các kiến trúc yêu cầu rào cản đắt tiền để tuần tự hóa chống lại
  DMA, các phiên bản "thoải mái" này của bộ truy cập MMIO chỉ nối tiếp với
  nhau nhưng chứa một hoạt động rào cản ít tốn kém hơn. Trình điều khiển thiết bị
  có thể sử dụng những thứ này theo một đường dẫn nhanh nhạy cảm với hiệu suất đặc biệt, với
  nhận xét giải thích tại sao việc sử dụng ở một vị trí cụ thể lại an toàn mà không cần
  những rào cản bổ sung.

Xem Memory-barriers.txt để thảo luận chi tiết hơn về thứ tự chính xác
  đảm bảo các phiên bản không thư giãn và thoải mái.

ioread64(), ioread32(), ioread16(), ioread8(),
iowrite64(), iowrite32(), iowrite16(), iowrite8()

Đây là một sự thay thế cho các hàm readl()/writel() thông thường, với hầu hết
  hành vi giống hệt nhau, nhưng chúng cũng có thể hoạt động trên các mã thông báo ZZ0000ZZ được trả về
  để ánh xạ không gian I/O PCI với pci_iomap() hoặc ioport_map(). Trên kiến trúc
  yêu cầu hướng dẫn đặc biệt để truy cập cổng I/O, điều này bổ sung thêm một chút
  chi phí chung cho lệnh gọi hàm gián tiếp được triển khai trong lib/iomap.c, trong khi bật
  các kiến trúc khác, đây chỉ đơn giản là các bí danh.

ioread64be(), ioread32be(), ioread16be()
iowrite64be(), iowrite32be(), iowrite16be()

Chúng hoạt động theo cách tương tự như họ ioread32()/iowrite32(), nhưng với
  thứ tự byte đảo ngược, để truy cập các thiết bị có thanh ghi MMIO lớn.
  Trình điều khiển thiết bị có thể hoạt động trên big-endian hoặc little-endian
  các thanh ghi có thể phải triển khai chức năng bao bọc tùy chỉnh để chọn một hoặc
  cái còn lại tùy thuộc vào thiết bị nào được tìm thấy.

Lưu ý: Trên một số kiến trúc, các hàm readl()/writel() bình thường
  theo truyền thống cho rằng các thiết bị có cùng độ bền như CPU, trong khi
  sử dụng tính năng đảo ngược byte phần cứng trên bus PCI khi chạy kernel lớn.
  Các trình điều khiển sử dụng readl()/writel() theo cách này thường không thể mang theo được, nhưng
  có xu hướng bị giới hạn ở một SoC cụ thể.

hi_lo_readq(), lo_hi_readq(), hi_lo_readq_relaxed(), lo_hi_readq_relaxed(),
ioread64_lo_hi(), ioread64_hi_lo(), ioread64be_lo_hi(), ioread64be_hi_lo(),
hi_lo_writeq(), lo_hi_writeq(), hi_lo_writeq_relaxed(), lo_hi_writeq_relaxed(),
iowrite64_lo_hi(), iowrite64_hi_lo(), iowrite64be_lo_hi(), iowrite64be_hi_lo()

Một số trình điều khiển thiết bị có các thanh ghi 64 bit không thể truy cập được nguyên tử
  trên kiến trúc 32 bit nhưng thay vào đó cho phép hai lần truy cập 32 bit liên tiếp.
  Vì nó phụ thuộc vào thiết bị cụ thể mà nửa nào trong hai nửa phải được
  được truy cập trước tiên, trình trợ giúp được cung cấp cho mỗi tổ hợp trình truy cập 64 bit
  với thứ tự từ thấp/cao hoặc cao/thấp. Trình điều khiển thiết bị phải bao gồm
  <linux/io-64-nonatomic-lo-hi.h> hoặc <linux/io-64-nonatomic-hi-lo.h> để
  lấy các định nghĩa hàm cùng với các trợ giúp chuyển hướng bình thường
  readq()/writeq() cho chúng trên các kiến trúc không cung cấp quyền truy cập 64-bit
  nguyên bản.

__raw_readq(), __raw_readl(), __raw_readw(), __raw_readb(),
__raw_writeq(), __raw_writel(), __raw_writew(), __raw_writeb()

Đây là các bộ truy cập MMIO cấp thấp không có rào cản hoặc thay đổi thứ tự byte và
  hành vi cụ thể của kiến trúc. Các truy cập thường mang tính nguyên tử theo nghĩa là
  __raw_readl() bốn byte không được chia thành các lần tải byte riêng lẻ, nhưng
  nhiều truy cập liên tiếp có thể được kết hợp trên xe buýt. Trong mã di động, nó
  chỉ an toàn khi sử dụng những thứ này để truy cập bộ nhớ phía sau bus thiết bị chứ không phải MMIO
  đăng ký, vì không có đảm bảo đặt hàng đối với MMIO khác
  truy cập hoặc thậm chí spinlocks. Thứ tự byte nói chung giống như đối với thông thường
  bộ nhớ, do đó không giống như các chức năng khác, chúng có thể được sử dụng để sao chép dữ liệu giữa
  bộ nhớ hạt nhân và bộ nhớ thiết bị.

inl(), inw(), inb(), outl(), outw(), outb()

Theo truyền thống, tài nguyên cổng I/O PCI yêu cầu những người trợ giúp riêng biệt.
  được triển khai bằng các hướng dẫn đặc biệt trên kiến trúc x86. Trên hầu hết các thứ khác
  kiến trúc, chúng được ánh xạ tới các bộ truy cập kiểu readl()/writel()
  nội bộ, thường trỏ đến một vùng cố định trong bộ nhớ ảo. Thay vì một
  Con trỏ ZZ0000ZZ, địa chỉ là mã thông báo số nguyên 32 bit để xác định một cổng
  số. PCI yêu cầu quyền truy cập cổng I/O không được đăng, nghĩa là outb()
  phải hoàn thành trước khi đoạn mã sau được thực thi, trong khi một writeb() bình thường có thể
  vẫn đang được tiến hành. Trên các kiến trúc triển khai chính xác điều này, cổng I/O
  do đó quyền truy cập được ra lệnh chống lại spinlocks. Nhiều cầu nối máy chủ PCI không phải x86
  Tuy nhiên, việc triển khai và kiến trúc CPU không triển khai được I/O không được đăng
  không gian trên PCI, vì vậy chúng có thể được đăng trên phần cứng như vậy.

Trong một số kiến trúc, không gian số cổng I/O có ánh xạ 1:1 tới
  Con trỏ ZZ0000ZZ, nhưng điều này không được khuyến khích và trình điều khiển thiết bị nên
  không dựa vào đó cho tính di động. Tương tự, số cổng I/O như được mô tả
  trong thanh ghi địa chỉ cơ sở PCI có thể không tương ứng với số cổng như đã thấy
  bởi một trình điều khiển thiết bị. Trình điều khiển di động cần đọc số cổng cho
  tài nguyên được cung cấp bởi kernel.

Không có bộ truy cập cổng I/O 64 bit trực tiếp, nhưng kết hợp pci_iomap()
  có thể sử dụng ioread64/iowrite64 để thay thế.

inl_p(), inw_p(), inb_p(), outl_p(), outw_p(), outb_p()

Trên các thiết bị ISA yêu cầu thời gian cụ thể, các phiên bản _p của I/O
  người truy cập thêm một độ trễ nhỏ. Trên các kiến trúc không có bus ISA,
  đây là bí danh của những người trợ giúp inb/outb thông thường.

readsq, readsl, readsw, readsb
viếtq, viếtl, viếtw, viếtb
ioread64_rep, ioread32_rep, ioread16_rep, ioread8_rep
iowrite64_rep, iowrite32_rep, iowrite16_rep, iowrite8_rep
insl, insw, insb, outsl, outsw, outsb

Đây là những người trợ giúp truy cập vào cùng một địa chỉ nhiều lần, thường là để sao chép
  dữ liệu giữa luồng byte bộ nhớ kernel và bộ đệm FIFO. Không giống như bình thường
  Các bộ truy cập MMIO, những bộ truy cập này không thực hiện trao đổi byte trên các hạt nhân lớn, do đó
  byte đầu tiên trong thanh ghi FIFO tương ứng với byte đầu tiên trong bộ nhớ
  bộ đệm bất kể kiến trúc.

Chế độ ánh xạ bộ nhớ thiết bị
=============================

Một số kiến ​​trúc hỗ trợ nhiều chế độ để ánh xạ bộ nhớ thiết bị.
Các biến thể ioremap_*() cung cấp sự trừu tượng chung xung quanh các biến thể này
các chế độ dành riêng cho kiến trúc, với một tập hợp ngữ nghĩa được chia sẻ.

ioremap() là loại ánh xạ phổ biến nhất và có thể áp dụng cho thiết bị thông thường
bộ nhớ (ví dụ: các thanh ghi I/O). Các chế độ khác có thể cung cấp yếu hơn hoặc mạnh hơn
đảm bảo, nếu được hỗ trợ bởi kiến trúc. Từ phổ biến nhất đến ít phổ biến nhất, họ
như sau:

ioremap()
---------

Chế độ mặc định, phù hợp với hầu hết các thiết bị được ánh xạ bộ nhớ, ví dụ: kiểm soát
sổ đăng ký. Bộ nhớ được ánh xạ bằng ioremap() có các đặc điểm sau:

* Không được lưu vào bộ đệm - Bộ nhớ đệm bên CPU được bỏ qua và tất cả hoạt động đọc và ghi đều được xử lý
  trực tiếp bằng thiết bị
* Không có hoạt động suy đoán - CPU có thể không phát hành lệnh đọc hoặc ghi vào mục này
  bộ nhớ, trừ khi lệnh đó đã đạt được trong cam kết
  dòng chảy chương trình.
* Không sắp xếp lại - CPU không thể sắp xếp lại quyền truy cập vào ánh xạ bộ nhớ này với
  tôn trọng lẫn nhau. Trên một số kiến trúc, điều này phụ thuộc vào các rào cản trong
  readl_relaxed()/writel_relaxed().
* Không lặp lại - CPU có thể không thực hiện nhiều lần đọc hoặc ghi cho một lần
  hướng dẫn chương trình.
* Không kết hợp ghi - Mỗi thao tác I/O dẫn đến một lần đọc hoặc ghi riêng biệt
  được cấp cho thiết bị và nhiều lần ghi không được kết hợp thành lớn hơn
  viết. Điều này có thể được thực thi hoặc không khi sử dụng các bộ truy cập __raw I/O hoặc
  sự hủy bỏ tham chiếu của con trỏ.
* Không thể thực thi - CPU không được phép suy đoán việc thực hiện lệnh
  từ ký ức này (có lẽ không cần phải nói, nhưng bạn cũng không
  được phép nhảy vào bộ nhớ thiết bị).

Trên nhiều nền tảng và xe buýt (ví dụ PCI), ghi được phát hành thông qua ioremap()
ánh xạ được đăng, điều đó có nghĩa là CPU không chờ ghi vào
thực sự đến được thiết bị đích trước khi hủy bỏ lệnh ghi.

Trên nhiều nền tảng, quyền truy cập I/O phải được căn chỉnh theo quyền truy cập
kích thước; không làm như vậy sẽ dẫn đến một ngoại lệ hoặc kết quả không thể đoán trước.

ioremap_wc()
------------

Ánh xạ bộ nhớ I/O thành bộ nhớ bình thường với tính năng kết hợp ghi. Không giống như ioremap(),

* CPU có thể đưa ra các lệnh đọc từ thiết bị mà chương trình
  đã không thực sự thực thi và về cơ bản có thể chọn đọc bất cứ thứ gì nó muốn.
* CPU có thể sắp xếp lại các hoạt động miễn là kết quả phù hợp với
  quan điểm của chương trình.
* CPU có thể ghi vào cùng một vị trí nhiều lần, ngay cả khi chương trình
  ban hành một văn bản duy nhất.
* CPU có thể kết hợp nhiều lần ghi thành một lần ghi lớn hơn.

Chế độ này thường được sử dụng cho bộ đệm khung video, nơi nó có thể tăng
hiệu suất viết. Nó cũng có thể được sử dụng cho các khối bộ nhớ khác trong
thiết bị (ví dụ: bộ đệm hoặc bộ nhớ dùng chung), nhưng phải cẩn thận khi truy cập
không được đảm bảo để được đặt hàng đối với thanh ghi ioremap() MMIO thông thường
truy cập mà không có rào cản rõ ràng.

Trên xe buýt PCI, thường an toàn khi sử dụng ioremap_wc() trên các khu vực MMIO được đánh dấu là
ZZ0000ZZ, nhưng nó không thể được sử dụng trên những thiết bị không có cờ.
Đối với các thiết bị trên chip, không có cờ tương ứng nhưng trình điều khiển có thể sử dụng
ioremap_wc() trên thiết bị được biết là an toàn.

ioremap_wt()
------------

Ánh xạ bộ nhớ I/O thành bộ nhớ bình thường với bộ nhớ đệm ghi qua. Giống như ioremap_wc(),
nhưng cũng có thể,

* CPU có thể ghi vào bộ nhớ đệm được phát hành và đọc từ thiết bị cũng như phục vụ các lần đọc
  từ bộ đệm đó.

Chế độ này đôi khi được sử dụng cho bộ đệm khung video, nơi trình điều khiển vẫn mong đợi
ghi để tiếp cận thiết bị kịp thời (và không bị kẹt trong CPU
cache), nhưng các lần đọc có thể được cung cấp từ bộ đệm để đạt hiệu quả. Tuy nhiên, nó là
ngày nay hiếm khi hữu ích vì trình điều khiển bộ đệm khung thường chỉ thực hiện việc ghi,
trong đó ioremap_wc() hiệu quả hơn (vì nó không cần thiết phải làm hỏng
bộ đệm). Hầu hết các trình điều khiển không nên sử dụng điều này.

ioremap_np()
------------

Giống như ioremap(), nhưng yêu cầu rõ ràng ngữ nghĩa ghi không được đăng. Trên một số
kiến trúc và xe buýt, ánh xạ ioremap() đã đăng ngữ nghĩa ghi, trong đó
có nghĩa là việc ghi có thể có vẻ "hoàn thành" theo quan điểm của
CPU trước khi dữ liệu ghi thực sự đến thiết bị mục tiêu. Viết là
vẫn được sắp xếp theo thứ tự ghi và đọc khác từ cùng một thiết bị, nhưng
do ngữ nghĩa viết được đăng, đây không phải là trường hợp đối với các
thiết bị. ioremap_np() yêu cầu rõ ràng ngữ nghĩa không được đăng, có nghĩa là
rằng hướng dẫn ghi sẽ không hoàn thành cho đến khi thiết bị
đã nhận được (và ở một mức độ cụ thể nào đó của nền tảng đã được thừa nhận) dữ liệu bằng văn bản.

Chế độ ánh xạ này chủ yếu tồn tại để phục vụ cho các nền tảng có kết cấu xe buýt
yêu cầu chế độ ánh xạ cụ thể này hoạt động chính xác. Các nền tảng này thiết lập
Cờ ZZ0000ZZ cho tài nguyên yêu cầu ioremap_np()
ngữ nghĩa và trình điều khiển di động nên sử dụng sự trừu tượng hóa tự động
chọn nó khi thích hợp (xem ZZ0001ZZ
phần bên dưới).

ioremap_np() trần chỉ khả dụng trên một số kiến ​​trúc; trên những người khác, nó
luôn trả về NULL. Người lái xe thường không nên sử dụng nó, trừ khi họ
dành riêng cho nền tảng hoặc họ thu được lợi ích từ việc viết không được đăng ở đâu
được hỗ trợ và có thể quay lại ioremap() nếu không. Cách tiếp cận thông thường đối với
đảm bảo hoàn thành ghi đã đăng là thực hiện đọc giả sau khi viết dưới dạng
được giải thích trong ZZ0000ZZ, hoạt động với ioremap() trên tất cả
nền tảng.

ioremap_np() không bao giờ được sử dụng cho trình điều khiển PCI. Ghi không gian bộ nhớ PCI là
luôn được đăng, ngay cả trên các kiến trúc triển khai ioremap_np().
Sử dụng ioremap_np() cho BAR PCI sẽ mang lại kết quả tốt nhất trong ngữ nghĩa ghi được đăng,
và tệ nhất là bị gãy hoàn toàn.

Lưu ý rằng ngữ nghĩa ghi không được đăng là trực giao với thứ tự phía CPU
sự đảm bảo. CPU vẫn có thể chọn thực hiện các lần đọc hoặc ghi khác trước khi
lệnh ghi không được đăng sẽ ngừng hoạt động. Xem phần trước về truy cập MMIO
chức năng để biết thông tin chi tiết về phía CPU.

ioremap_uc()
------------

ioremap_uc() chỉ có ý nghĩa trên các hệ thống x86-32 cũ có phần mở rộng PAT,
và trên ia64 với hành vi ioremap() hơi khác thường, ở mọi nơi
elss ioremap_uc() mặc định trả về NULL.


Trình điều khiển di động nên tránh sử dụng ioremap_uc(), thay vào đó hãy sử dụng ioremap().

ioremap_cache()
---------------

ioremap_cache() ánh xạ bộ nhớ I/O một cách hiệu quả như RAM bình thường. Ghi lại CPU
bộ nhớ đệm có thể được sử dụng và CPU có thể tự do xử lý thiết bị như thể nó là một thiết bị
khối RAM. Điều này không bao giờ nên được sử dụng cho bộ nhớ thiết bị có bên
ảnh hưởng dưới bất kỳ hình thức nào hoặc không trả lại dữ liệu được ghi trước đó trên
đọc.

Nó cũng không nên được sử dụng cho RAM thực tế, vì con trỏ trả về là một
Mã thông báo ZZ0000ZZ. memremap() có thể được sử dụng để ánh xạ RAM bình thường ở bên ngoài
của vùng bộ nhớ hạt nhân tuyến tính thành một con trỏ thông thường.

Trình điều khiển di động nên tránh sử dụng ioremap_cache().

Ví dụ về kiến ​​trúc
--------------------

Đây là cách các chế độ trên ánh xạ tới cài đặt thuộc tính bộ nhớ trên ARM64
kiến trúc:

+------------------------+---------------------------------------------+
ZZ0000ZZ Loại vùng bộ nhớ và khả năng lưu trữ |
+------------------------+---------------------------------------------+
ZZ0001ZZ Thiết bị-nGnRnE |
+------------------------+---------------------------------------------+
ZZ0002ZZ Thiết bị-nGnRE |
+------------------------+---------------------------------------------+
ZZ0003ZZ (chưa được triển khai) |
+------------------------+---------------------------------------------+
ZZ0004ZZ Bình thường-Không thể lưu vào bộ nhớ đệm |
+------------------------+---------------------------------------------+
ZZ0005ZZ (không được triển khai; dự phòng cho ioremap) |
+------------------------+---------------------------------------------+
ZZ0006ZZ Ghi lại bình thường vào bộ nhớ đệm |
+------------------------+---------------------------------------------+

Tóm tắt ioremap cấp cao hơn
=================================

Thay vì sử dụng các chế độ ioremap() thô ở trên, người lái xe được khuyến khích sử dụng
API cấp cao hơn. Các API này có thể triển khai logic dành riêng cho nền tảng để
tự động chọn chế độ ioremap thích hợp trên bất kỳ xe buýt nào, cho phép
một trình điều khiển không phụ thuộc vào nền tảng để hoạt động trên các nền tảng đó mà không cần bất kỳ điều gì đặc biệt
trường hợp. Tại thời điểm viết bài này, các trình bao bọc ioremap() sau đây có như vậy
logic:

devm_ioremap_resource()

Có thể tự động chọn ioremap_np() trên ioremap() tùy theo nền tảng
  yêu cầu, nếu cờ ZZ0000ZZ được đặt trên cấu trúc
  tài nguyên. Sử dụng devres để tự động hủy ánh xạ tài nguyên khi trình điều khiển
  Chức năng thăm dò() không thành công hoặc thiết bị không được liên kết với trình điều khiển của nó.

Được ghi lại trong Tài liệu/driver-api/driver-model/devres.rst.

of_address_to_resource()

Tự động đặt cờ ZZ0000ZZ cho các nền tảng
  yêu cầu ghi không được đăng đối với một số xe buýt nhất định (xem nonposted-mmio và
  thuộc tính cây thiết bị đã đăng-mmio).

of_iomap()

Ánh xạ tài nguyên được mô tả trong thuộc tính ZZ0000ZZ trong cây thiết bị, thực hiện
  tất cả các bản dịch cần thiết Tự động chọn ioremap_np() theo
  yêu cầu nền tảng, như trên.

pci_ioremap_bar(), pci_ioremap_wc_bar()

Ánh xạ tài nguyên được mô tả trong địa chỉ cơ sở PCI mà không cần phải trích xuất
  địa chỉ vật lý đầu tiên.

pci_iomap(), pci_iomap_wc()

Giống như pci_ioremap_bar()/pci_ioremap_bar(), nhưng cũng hoạt động trên không gian I/O khi
  được sử dụng cùng với ioread32()/iowrite32() và các trình truy cập tương tự

pcim_iomap()

Giống như pci_iomap(), nhưng sử dụng devres để tự động hủy ánh xạ tài nguyên khi
  chức năng thăm dò trình điều khiển() không thành công hoặc một thiết bị không được liên kết với trình điều khiển của nó

Được ghi lại trong Tài liệu/driver-api/driver-model/devres.rst.

Việc không sử dụng các trình bao bọc này có thể khiến trình điều khiển không sử dụng được trên một số nền tảng nhất định với
các quy tắc chặt chẽ hơn để ánh xạ bộ nhớ I/O.

Khái quát hóa quyền truy cập vào hệ thống và bộ nhớ I/O
=======================================================

.. kernel-doc:: include/linux/iosys-map.h
   :doc: overview

.. kernel-doc:: include/linux/iosys-map.h
   :internal:

Chức năng công cộng được cung cấp
=================================

.. kernel-doc:: arch/x86/include/asm/io.h
   :internal:
