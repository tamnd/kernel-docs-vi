.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/pci_iov_resource_on_powernv.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

========================================================
Tài nguyên ảo hóa I/O Express PCI trên Powerenv
===================================================

Vị Ương <weiyang@linux.vnet.ibm.com>

Benjamin Herrenschmidt <benh@au1.ibm.com>

Bjorn Helgaas <bhelgaas@google.com>

26 tháng 8 năm 2014

Tài liệu này mô tả yêu cầu từ phần cứng đối với tài nguyên PCI MMIO
định cỡ và gán trên PowerKVM cũng như cách mã PCI chung xử lý việc này
yêu cầu. Hai phần đầu tiên mô tả các khái niệm về Có thể phân vùng
Điểm cuối và triển khai trên P8 (IODA2). Hai phần tiếp theo nói chuyện
về những điều cần cân nhắc khi bật SRIOV trên IODA2.

1. Giới thiệu về Điểm cuối có thể phân vùng
==========================================

Điểm cuối có thể phân vùng (PE) là một cách để nhóm các tài nguyên khác nhau
được liên kết với một thiết bị hoặc một bộ thiết bị để cung cấp sự cách ly giữa
phân vùng (tức là lọc DMA, MSI, v.v.) và để cung cấp cơ chế
đóng băng một thiết bị đang gây ra lỗi nhằm hạn chế khả năng xảy ra
lan truyền dữ liệu xấu.

Do đó, trong HW, có một bảng trạng thái PE chứa một cặp trạng thái "đóng băng"
các bit trạng thái (một cho MMIO và một cho DMA, chúng được đặt cùng nhau nhưng có thể
được xóa độc lập) cho mỗi PE.

Khi một PE bị đóng băng, tất cả các kho dự trữ theo bất kỳ hướng nào sẽ bị loại bỏ và tất cả các tải sẽ bị loại bỏ.
trả về tất cả giá trị 1 MSI cũng bị chặn. Có thêm một chút trạng thái đó
nắm bắt những thứ như chi tiết về lỗi gây ra tình trạng treo, v.v., nhưng
điều đó không quan trọng.

Phần thú vị là cách các giao dịch PCIe khác nhau (MMIO, DMA, ...)
được khớp với PE tương ứng của chúng.

Phần sau đây cung cấp mô tả sơ bộ về những gì chúng tôi có trên P8
(IODA2).  Hãy nhớ rằng đây là tất cả cho mỗi PHB (cầu nối máy chủ PCI).  Mỗi PHB
là một thực thể CTNH hoàn toàn riêng biệt, sao chép toàn bộ logic, do đó có
bộ PE riêng của nó, v.v.

2. Triển khai Điểm cuối có thể phân vùng trên P8 (IODA2)
==========================================================

P8 hỗ trợ tới 256 Điểm cuối có thể phân vùng trên mỗi PHB.

* Trong nước

Đối với DMA, MSI và thông báo lỗi PCIe gửi đến, chúng tôi có một bảng (ở dạng
    bộ nhớ nhưng được truy cập trong CTNH bằng chip) cung cấp kết nối trực tiếp
    sự tương ứng giữa PCIe RID (bus/dev/fn) với số PE.
    Chúng tôi gọi đây là RTT.

- Đối với DMA, chúng tôi cung cấp toàn bộ không gian địa chỉ cho mỗi PE có thể
      chứa hai "cửa sổ", tùy thuộc vào giá trị của bit địa chỉ PCI 59.
      Mỗi cửa sổ có thể được cấu hình để được ánh xạ lại thông qua "bảng TCE" (IOMMU
      bảng dịch), có nhiều đặc điểm cấu hình khác nhau
      không được mô tả ở đây.

- Đối với MSI, chúng tôi có hai cửa sổ trong không gian địa chỉ (một ở trên cùng của
      không gian 32-bit và một không gian cao hơn nhiều), thông qua sự kết hợp của
      địa chỉ và giá trị MSI, sẽ dẫn đến một trong 2048 ngắt trên mỗi
      cây cầu đang được kích hoạt.  Có PE# in bộ điều khiển ngắt
      bảng mô tả cũng được so sánh với PE# obtained từ
      RTT "cho phép" thiết bị phát ra ngắt cụ thể đó.

- Thông báo lỗi chỉ sử dụng RTT.

* Xuất ngoại.  Đó là phần khó khăn.

Giống như các cầu nối máy chủ PCI khác, Power8 IODA2 PHB hỗ trợ "windows"
    từ không gian địa chỉ CPU đến không gian địa chỉ PCI.  Có một chiếc M32
    cửa sổ và mười sáu cửa sổ M64.  Họ có những đặc điểm khác nhau.
    Đầu tiên chúng có điểm chung: chúng chuyển tiếp một phần có thể cấu hình được của
    không gian địa chỉ CPU vào bus PCIe và phải được căn chỉnh tự nhiên
    sức mạnh của hai kích thước.  Phần còn lại thì khác:

- Cửa sổ M32:

* Được giới hạn ở kích thước 4GB.

* Bỏ các bit trên cùng của địa chỉ (trên kích thước) và thay thế
	chúng với một giá trị có thể cấu hình được.  Điều này thường được sử dụng để tạo ra
	Truy cập PCIe 32-bit.  Chúng tôi định cấu hình cửa sổ đó khi khởi động từ FW và
	đừng chạm vào nó từ Linux; nó thường được thiết lập để chuyển tiếp 2GB
	phần không gian địa chỉ từ CPU đến PCIe
	0x8000_0000..0xffff_ffff.  (Lưu ý: 64KB hàng đầu thực tế là
	dành riêng cho MSI nhưng đây không phải là vấn đề vào thời điểm này; chúng tôi chỉ
	cần đảm bảo Linux không gán bất cứ thứ gì ở đó, logic M32
	Tuy nhiên, bỏ qua điều đó và sẽ chuyển tiếp vào không gian đó nếu chúng tôi cố gắng).

* Nó được chia thành 256 đoạn có kích thước bằng nhau.  Một bảng trong chip
	ánh xạ từng phân đoạn tới PE#.  Điều đó cho phép các phần của không gian MMIO
	được gán cho PE theo mức độ chi tiết của phân khúc.  Đối với cửa sổ 2GB,
	độ chi tiết của phân đoạn là 2GB/256 = 8MB.

Bây giờ, đây là cửa sổ "chính" mà chúng ta sử dụng trong Linux ngày nay (không bao gồm
    SR-IOV).  Về cơ bản chúng tôi sử dụng thủ thuật buộc cửa sổ cầu MMIO
    vào sự căn chỉnh/độ chi tiết của phân đoạn sao cho không gian phía sau cây cầu
    có thể được gán cho một PE.

Lý tưởng nhất là chúng tôi muốn có thể có các chức năng riêng lẻ trong PE
    nhưng điều đó có nghĩa là sử dụng cách phân bổ địa chỉ hoàn toàn khác
    sơ đồ trong đó các BAR chức năng riêng lẻ có thể được "nhóm" lại để phù hợp với một hoặc
    nhiều phân đoạn hơn.

- Cửa sổ M64:

* Phải có kích thước tối thiểu 256 MB.

* Không dịch địa chỉ (địa chỉ trên PCIe giống với địa chỉ
	địa chỉ trên PowerBus).  Có cách cũng là set top 14
	các bit không được PowerBus truyền tải nhưng chúng tôi không sử dụng nó.

* Có thể được cấu hình để được phân đoạn.  Khi chưa được phân đoạn, chúng ta có thể
	chỉ định PE# for toàn bộ cửa sổ.  Khi được phân đoạn, một cửa sổ
	có 256 đoạn; tuy nhiên, không có bảng để ánh xạ một đoạn
	tới PE#.  Số phân đoạn ZZ0000ZZ PE#.

* Hỗ trợ chồng chéo.  Nếu một địa chỉ được bao phủ bởi nhiều cửa sổ,
	có một thứ tự xác định cho cửa sổ nào được áp dụng.

Chúng tôi có mã (khá mới so với nội dung M32) khai thác điều đó
    đối với các BAR lớn trong không gian 64 bit:

Chúng tôi định cấu hình cửa sổ M64 để bao phủ toàn bộ vùng không gian địa chỉ
    đã được FW chỉ định cho PHB (khoảng 64GB, bỏ qua dung lượng
    đối với M32, nó được lấy từ một "dự trữ" khác.  Chúng tôi cấu hình nó
    như được phân đoạn.

Sau đó chúng ta làm tương tự như với M32, sử dụng căn chỉnh cầu nối
    thủ thuật, để phù hợp với những phân khúc khổng lồ đó.

Vì chúng tôi không thể ánh xạ lại nên chúng tôi có hai ràng buộc bổ sung:

- Chúng tôi thực hiện PE# allocation ZZ0000ZZ không gian 64-bit đã được chỉ định
      vì địa chỉ chúng tôi sử dụng trực tiếp xác định PE#.  Sau đó chúng tôi
      cập nhật M32 PE# for các thiết bị sử dụng cả 32 bit và 64 bit
      dấu cách hoặc chỉ định các thiết bị chỉ 32-bit PE# to còn lại.

- Chúng tôi không thể "nhóm" các phân đoạn trong CTNH, vì vậy nếu một thiết bị sử dụng nhiều hơn
      hơn một phân khúc thì chúng ta sẽ có nhiều hơn một PE#.  Có một CTNH
      cơ chế tạo tầng trạng thái đóng băng thành các PE "đồng hành" nhưng
      chỉ hoạt động đối với các thông báo lỗi PCIe (thường được sử dụng để nếu
      bạn đóng băng một switch, nó sẽ đóng băng tất cả các switch con của nó).  Vì vậy chúng tôi làm điều đó trong
      SW.  Chúng tôi mất một chút hiệu quả của EEH trong trường hợp đó, nhưng đó là
      điều tốt nhất chúng tôi tìm thấy.  Vì vậy, khi bất kỳ PE nào bị đóng băng, chúng tôi sẽ đóng băng
      những cái khác cho "tên miền" đó.  Vì vậy chúng tôi đưa ra khái niệm về
      "PE chính" là loại được sử dụng cho DMA, MSI, v.v. và "thứ cấp
      PE" được sử dụng cho các phân đoạn M64 còn lại.

Chúng tôi muốn điều tra việc sử dụng các cửa sổ M64 bổ sung trong "đơn
    PE" để phủ lên các BAR cụ thể nhằm giải quyết một số vấn đề đó, dành cho
    ví dụ cho các thiết bị có BAR rất lớn, ví dụ: GPU.  Nó sẽ làm cho
    có lý, nhưng chúng tôi vẫn chưa làm được điều đó.

3. Những điều cần cân nhắc đối với SR-IOV trên PowerKVM
========================================

* Nền SR-IOV

Tính năng PCIe SR-IOV cho phép một Chức năng Vật lý (PF) duy nhất thực hiện
    hỗ trợ một số Chức năng ảo (VF).  Các thanh ghi trong SR-IOV của PF
    Khả năng kiểm soát số lượng VF và liệu chúng có được bật hay không.

Khi VF được bật, chúng sẽ xuất hiện trong Không gian cấu hình như bình thường
    Các thiết bị PCI, nhưng các BAR trong tiêu đề không gian cấu hình VF là không bình thường.  cho
    một thiết bị không phải VF, phần mềm sử dụng BAR trong tiêu đề không gian cấu hình để
    khám phá kích thước BAR và gán địa chỉ cho chúng.  Đối với thiết bị VF,
    phần mềm sử dụng các thanh ghi VF BAR trong ZZ0000ZZ SR-IOV
    khám phá kích thước và gán địa chỉ.  Các BAR trong không gian cấu hình của VF
    tiêu đề là số không chỉ đọc.

Khi VF BAR trong Khả năng PF SR-IOV được lập trình, nó sẽ đặt
    địa chỉ cơ sở cho tất cả các BAR VF(n) tương ứng.  Ví dụ, nếu
    Khả năng PF SR-IOV được lập trình để kích hoạt tám VF và nó có một
    1 MB VF BAR0, địa chỉ trong VF BAR đó đặt cơ sở cho vùng 8 MB.
    Vùng này được chia thành 8 vùng 1MB liền kề nhau, mỗi vùng
    là BAR0 cho một trong các VF.  Lưu ý rằng mặc dù VF BAR
    mô tả vùng 8 MB, yêu cầu căn chỉnh dành cho một VF duy nhất,
    tức là 1MB trong ví dụ này.

Có một số chiến lược để cô lập VF trong PE:

- Cửa sổ M32: Có 1 cửa sổ M32, được chia thành 256
    các đoạn có kích thước bằng nhau.  Độ chi tiết tốt nhất có thể là 256MB
    cửa sổ có phân đoạn 1 MB.  Thanh VF có dung lượng 1MB hoặc lớn hơn có thể được
    được ánh xạ tới các PE riêng biệt trong cửa sổ này.  Mỗi phân đoạn có thể
    được ánh xạ riêng tới PE thông qua bảng tra cứu, vì vậy điều này khá
    linh hoạt, nhưng nó hoạt động tốt nhất khi tất cả các thanh VF có cùng kích thước.  Nếu
    chúng có kích thước khác nhau, toàn bộ cửa sổ phải đủ nhỏ để
    kích thước phân đoạn khớp với VF BAR nhỏ nhất, có nghĩa là VF lớn hơn
    BAR trải dài trên nhiều phân đoạn.

- Cửa sổ M64 không được phân đoạn: Cửa sổ M64 không được phân đoạn được ánh xạ toàn bộ
    thành một PE duy nhất, vì vậy nó chỉ có thể cách ly một VF.

- Cửa sổ M64 phân đoạn đơn: Chỉ có thể sử dụng cửa sổ M64 được phân đoạn
    giống như cửa sổ M32, nhưng các phân đoạn không thể được ánh xạ riêng lẻ tới
    PE (số phân đoạn là PE#), do đó không có nhiều
    tính linh hoạt.  Một VF có nhiều BAR sẽ phải nằm trong một "miền" gồm
    nhiều PE, không tách biệt tốt như một PE đơn lẻ.

- Nhiều cửa sổ M64 được phân đoạn: Như thường lệ, mỗi cửa sổ được chia thành 256
    các phân đoạn có kích thước bằng nhau và số phân đoạn là PE#.  Nhưng nếu chúng ta
    sử dụng một số cửa sổ M64, chúng có thể được đặt thành các địa chỉ cơ sở khác nhau
    và kích thước phân khúc khác nhau.  Nếu chúng ta có các VF mà mỗi VF có BAR 1MB
    và BAR 32 MB, chúng ta có thể sử dụng một cửa sổ M64 để gán các phân đoạn 1 MB và
    một cửa sổ M64 khác để gán các phân đoạn 32MB.

Cuối cùng, kế hoạch sử dụng cửa sổ M64 cho SR-IOV sẽ được mô tả
  hơn trong hai phần tiếp theo.  Đối với VF BAR nhất định, chúng ta cần
  dự trữ hiệu quả toàn bộ 256 phân đoạn (kích thước 256 * VF BAR) và
  định vị VF BAR để bắt đầu ở điểm bắt đầu của phạm vi tự do
  phân đoạn/PE bên trong cửa sổ M64 đó.

Tất nhiên, mục tiêu là có thể đưa ra PE riêng cho từng VF.

Nền tảng IODA2 có 16 cửa sổ M64, được sử dụng để ánh xạ MMIO
  phạm vi đến PE #.  Mỗi cửa sổ M64 xác định một phạm vi MMIO và phạm vi này là
  được chia thành 256 đoạn, mỗi đoạn tương ứng với một PE.

Chúng tôi quyết định tận dụng cửa sổ M64 này để ánh xạ các VF tới các PE riêng lẻ, vì
  Các thanh VF SR-IOV đều có cùng kích thước.

Nhưng làm như vậy sẽ gây ra một vấn đề khác: tổng_VF thường nhỏ hơn
  hơn số lượng phân đoạn cửa sổ M64, vì vậy nếu chúng ta ánh xạ trực tiếp một VF BAR
  tới một cửa sổ M64, một phần của cửa sổ M64 sẽ ánh xạ sang cửa sổ khác
  phạm vi MMIO của thiết bị.

IODA hỗ trợ 256 PE, do đó các cửa sổ được phân đoạn chứa 256 phân đoạn, vì vậy nếu
  tổng_VF nhỏ hơn 256, chúng ta có tình huống trong Hình 1.0, trong đó
  các phân đoạn [tổng_VF, 255] của cửa sổ M64 có thể ánh xạ tới một số phạm vi MMIO trên
  các thiết bị khác::

0 1 tổng_VF - 1
     +------+------+- -+------+------+
     ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ
     +------+------+- -+------+------+

Không gian VF(n) BAR

Tổng 0 1_VF - 1 255
     +------+------+- -+------+------+- -+------+------+
     ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ... ZZ0003ZZ |
     +------+------+- -+------+------+- -+------+------+

Cửa sổ M64

Hình 1.0 Bản đồ trực tiếp Không gian VF(n) BAR

Giải pháp hiện tại của chúng tôi là phân bổ 256 phân đoạn ngay cả khi VF(n) BAR
  không gian không cần nhiều như vậy, như trong Hình 1.1::

Tổng 0 1_VF - 1 255
     +------+------+- -+------+------+- -+------+------+
     ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ... ZZ0003ZZ |
     +------+------+- -+------+------+- -+------+------+

Không gian VF(n) BAR + phụ

Tổng 0 1_VF - 1 255
     +------+------+- -+------+------+- -+------+------+
     ZZ0000ZZ ZZ0001ZZ ZZ0002ZZ ... ZZ0003ZZ |
     +------+------+- -+------+------+- -+------+------+

Cửa sổ M64

Hình 1.1 Bản đồ không gian VF(n) BAR + bổ sung

Việc phân bổ không gian bổ sung đảm bảo rằng toàn bộ cửa sổ M64 sẽ được
  được gán cho một thiết bị SR-IOV này và sẽ không có khoảng trống nào được
  có sẵn cho các thiết bị khác.  Lưu ý rằng điều này chỉ mở rộng không gian
  dành riêng trong phần mềm; vẫn chỉ có tổng số VF VF và chúng chỉ
  phản hồi các phân đoạn [0, tổng_VF - 1].  Không có gì trong phần cứng đó
  phản hồi các phân đoạn [total_VFs, 255].

4. Ý nghĩa của Mã PCI Chung
========================================

Thông số kỹ thuật PCIe SR-IOV yêu cầu nền của không gian VF(n) BAR phải
căn chỉnh theo kích thước của một VF BAR riêng lẻ.

Trong IODA2, địa chỉ MMIO xác định PE#.  Nếu địa chỉ nằm trong M32
cửa sổ, chúng ta có thể đặt PE# by cập nhật bảng dịch các phân đoạn
tới PE#s.  Tương tự, nếu địa chỉ nằm trong cửa sổ M64 chưa được phân đoạn, chúng ta có thể
đặt PE# for làm cửa sổ.  Nhưng nếu nó ở trong cửa sổ M64 được phân đoạn, thì
số phân đoạn là PE#.

Do đó, cách duy nhất để điều khiển PE# for a VF là thay đổi đế
của không gian VF(n) BAR trong VF BAR.  Nếu lõi PCI phân bổ chính xác
lượng không gian cần thiết cho không gian VF(n) BAR, giá trị VF BAR là cố định
và không thể thay đổi được.

Mặt khác, nếu lõi PCI phân bổ thêm không gian, thì VF BAR
giá trị có thể được thay đổi miễn là toàn bộ không gian VF(n) BAR vẫn còn bên trong
không gian được phân bổ bởi lõi.

Lý tưởng nhất là kích thước phân đoạn sẽ giống với kích thước VF BAR riêng lẻ.
Sau đó, mỗi VF sẽ có PE riêng.  Các thanh VF (và do đó là PE#s)
là liền kề nhau.  Nếu VF0 nằm trong PE(x), thì VF(n) nằm trong PE(x+n).  Nếu chúng ta
phân bổ 256 phân đoạn, có (256 - numVF) lựa chọn cho PE# of VF0.

Nếu kích thước phân đoạn nhỏ hơn kích thước VF BAR, sẽ mất vài
các phân đoạn để bao phủ VF BAR và VF sẽ có trong một số PE.  Đây là
có thể, nhưng khả năng cách ly không tốt và nó làm giảm số lượng PE#
choices vì thay vì chỉ tiêu thụ các phân đoạn numVF, VF(n) BAR
không gian sẽ tiêu thụ các phân đoạn (numVFs * n).  Điều đó có nghĩa là không có nhiều
các phân đoạn có sẵn để điều chỉnh cơ sở của không gian VF(n) BAR.
