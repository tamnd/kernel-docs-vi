.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/dmaengine/provider.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================================
Tài liệu bộ điều khiển DMAengine
==================================

Giới thiệu phần cứng
=====================

Hầu hết các bộ điều khiển Slave DMA đều có cùng nguyên tắc chung về
hoạt động.

Họ có một số kênh nhất định để sử dụng cho việc chuyển DMA và
một số dòng yêu cầu nhất định.

Yêu cầu và kênh khá trực giao. Các kênh có thể được sử dụng
để phục vụ một số cho bất kỳ yêu cầu nào. Để đơn giản hóa, các kênh là
các thực thể sẽ thực hiện sao chép và yêu cầu điểm cuối là gì
có liên quan.

Các dòng yêu cầu thực sự tương ứng với các dòng vật lý đi từ
Các thiết bị đủ điều kiện DMA cho chính bộ điều khiển. Bất cứ khi nào thiết bị
sẽ muốn bắt đầu chuyển giao, nó sẽ xác nhận yêu cầu DMA (DRQ) bằng cách
khẳng định dòng yêu cầu đó.

Bộ điều khiển DMA rất đơn giản sẽ chỉ tính đến một
tham số: kích thước truyền. Ở mỗi chu kỳ đồng hồ, nó sẽ truyền một
byte dữ liệu từ bộ đệm này sang bộ đệm khác cho đến khi kích thước truyền đạt
đã đạt được.

Điều đó sẽ không hoạt động tốt trong thế giới thực vì các thiết bị nô lệ có thể
yêu cầu một số bit cụ thể được truyền trong một
chu kỳ. Ví dụ: chúng ta có thể muốn chuyển càng nhiều dữ liệu càng tốt
bus vật lý cho phép tối đa hóa hiệu suất khi thực hiện một thao tác đơn giản
hoạt động sao chép bộ nhớ, nhưng thiết bị âm thanh của chúng tôi có thể có FIFO hẹp hơn
yêu cầu dữ liệu phải được ghi chính xác 16 hoặc 24 bit mỗi lần. Cái này
đó là lý do tại sao hầu hết nếu không phải tất cả các bộ điều khiển DMA đều có thể điều chỉnh điều này bằng cách sử dụng
tham số được gọi là độ rộng truyền.

Hơn nữa, một số bộ điều khiển DMA, bất cứ khi nào RAM được sử dụng làm nguồn
hoặc đích, có thể nhóm các lần đọc hoặc ghi vào bộ nhớ vào bộ đệm,
vì vậy thay vì có nhiều quyền truy cập vào bộ nhớ nhỏ, điều này không
thực sự hiệu quả, bạn sẽ nhận được nhiều khoản chuyển khoản lớn hơn. Việc này được thực hiện
sử dụng một tham số được gọi là kích thước cụm, xác định có bao nhiêu
đọc/ghi nó được phép thực hiện mà không cần bộ điều khiển chia tách
chuyển thành các lần chuyển con nhỏ hơn.

Bộ điều khiển DMA lý thuyết của chúng tôi sau đó sẽ chỉ có thể thực hiện chuyển
liên quan đến một khối dữ liệu liền kề. Tuy nhiên, một số
các giao dịch chuyển tiền mà chúng tôi thường không thực hiện và muốn sao chép dữ liệu từ
bộ đệm không liền kề với bộ đệm liền kề, được gọi là
phân tán-thu thập.

DMAEngine, ít nhất là đối với chuyển giao mem2dev, yêu cầu hỗ trợ cho
phân tán-thu thập. Vì vậy, chúng ta còn lại hai trường hợp ở đây: hoặc là chúng ta có một
Bộ điều khiển DMA khá đơn giản không hỗ trợ nó và chúng ta sẽ phải
triển khai nó trong phần mềm hoặc chúng tôi có bộ điều khiển DMA tiên tiến hơn,
thực hiện trong việc thu thập phân tán phần cứng.

Cái sau thường được lập trình bằng cách sử dụng một tập hợp các khối để
chuyển và bất cứ khi nào quá trình chuyển được bắt đầu, bộ điều khiển sẽ hoạt động
qua bộ sưu tập đó, làm bất cứ điều gì chúng tôi đã lập trình ở đó.

Bộ sưu tập này thường là một bảng hoặc một danh sách liên kết. Bạn sẽ
sau đó đẩy địa chỉ của bảng và số phần tử của nó,
hoặc mục đầu tiên của danh sách tới một kênh của bộ điều khiển DMA,
và bất cứ khi nào DRQ được xác nhận, nó sẽ được chuyển qua bộ sưu tập
để biết lấy dữ liệu từ đâu.

Dù bằng cách nào, định dạng của bộ sưu tập này hoàn toàn phụ thuộc vào
phần cứng của bạn. Mỗi bộ điều khiển DMA sẽ yêu cầu một cấu trúc khác nhau,
nhưng tất cả chúng sẽ yêu cầu, đối với mỗi đoạn, ít nhất là nguồn và
địa chỉ đích, liệu nó có nên tăng các địa chỉ này hay không
not và ba tham số chúng ta đã thấy trước đó: kích thước cụm,
chiều rộng truyền và kích thước truyền.

Điều cuối cùng là thông thường, các thiết bị phụ sẽ không phát hành DRQ bằng
mặc định và trước tiên bạn phải bật tính năng này trong trình điều khiển thiết bị phụ của mình
bất cứ khi nào bạn sẵn sàng sử dụng DMA.

Đây chỉ là bộ nhớ chung (còn gọi là mem2mem) hoặc
loại chuyển bộ nhớ sang thiết bị (mem2dev). Hầu hết các thiết bị thường
hỗ trợ các loại chuyển giao hoặc hoạt động bộ nhớ khác mà dmaengine
hỗ trợ và sẽ được trình bày chi tiết sau trong tài liệu này.

Hỗ trợ DMA trong Linux
====================

Trong lịch sử, trình điều khiển bộ điều khiển DMA đã được triển khai bằng cách sử dụng
async TX API, để giảm tải các hoạt động như sao chép bộ nhớ, XOR,
mật mã, v.v., về cơ bản là bất kỳ hoạt động bộ nhớ nào đối với bộ nhớ.

Theo thời gian, nhu cầu về bộ nhớ để chuyển thiết bị phát sinh và
dmaengine đã được mở rộng. Ngày nay, TX API không đồng bộ được viết dưới dạng
lớp trên cùng của dmaengine và hoạt động như một máy khách. Tuy nhiên, dmaengine
phù hợp với API đó trong một số trường hợp và đưa ra một số lựa chọn thiết kế để
đảm bảo rằng nó vẫn tương thích.

Để biết thêm thông tin về Async TX API, vui lòng xem tài liệu liên quan
tệp tài liệu trong Documentation/crypto/async-tx-api.rst.

API DMAEengine
==============

Khởi tạo ZZ0000ZZ
------------------------------------

Cũng giống như bất kỳ framework kernel nào khác, toàn bộ quá trình đăng ký DMAEngine
dựa vào trình điều khiển điền vào cấu trúc và đăng ký với
khuôn khổ. Trong trường hợp của chúng tôi, cấu trúc đó là dma_device.

Điều đầu tiên bạn cần làm trong trình điều khiển của mình là phân bổ
cấu trúc. Bất kỳ trình cấp phát bộ nhớ thông thường nào cũng có thể thực hiện được, nhưng bạn cũng sẽ
cần khởi tạo một vài trường trong đó:

- ZZ0000ZZ: nên được khởi tạo dưới dạng danh sách bằng cách sử dụng
  Ví dụ macro INIT_LIST_HEAD

-ZZ0000ZZ:
  phải chứa một bitmask có độ rộng truyền nguồn được hỗ trợ

-ZZ0000ZZ:
  phải chứa một bitmask có độ rộng truyền đích được hỗ trợ

-ZZ0000ZZ:
  phải chứa một bitmask của các hướng nô lệ được hỗ trợ
  (tức là không bao gồm chuyển khoản mem2mem)

-ZZ0000ZZ:
  mức độ chi tiết của dư lượng chuyển giao được báo cáo cho dma_set_residue.
  Đây có thể là:

- Mô tả:
    thiết bị của bạn không hỗ trợ bất kỳ loại dư lượng nào
    báo cáo. Khung sẽ chỉ biết rằng một cụ thể
    mô tả giao dịch được thực hiện.

- Phân đoạn:
    thiết bị của bạn có thể báo cáo những phần nào đã được chuyển

- Bùng nổ:
    thiết bị của bạn có thể báo cáo cụm nào đã được chuyển

- ZZ0000ZZ: nên giữ con trỏ tới ZZ0001ZZ liên kết
  vào phiên bản trình điều khiển hiện tại của bạn.

Các loại giao dịch được hỗ trợ
---------------------------

Điều tiếp theo bạn cần là đặt loại giao dịch nào cho thiết bị của bạn
(và trình điều khiển) hỗ trợ.

ZZ0000ZZ của chúng tôi có một trường tên là cap_mask chứa
nhiều loại giao dịch được hỗ trợ và bạn cần sửa đổi điều này
mặt nạ bằng hàm dma_cap_set, với nhiều cờ khác nhau tùy thuộc vào
các loại giao dịch mà bạn hỗ trợ làm đối số.

Tất cả những khả năng đó được xác định trong ZZ0000ZZ,
trong ZZ0001ZZ

Hiện nay có các loại:

-DMA_MEMCPY

- Thiết bị có khả năng sao chép bộ nhớ sang bộ nhớ

- Bất kể kích thước tổng thể của các khối kết hợp cho nguồn và
    đích là, chỉ có bao nhiêu byte nhỏ nhất trong hai byte sẽ được
    được truyền đi. Điều đó có nghĩa là số lượng và kích thước của bộ đệm thu thập phân tán trong
    cả hai danh sách không cần phải giống nhau và hoạt động về mặt chức năng là
    tương đương với ZZ0000ZZ trong đó đối số ZZ0001ZZ bằng giá trị nhỏ nhất
    tổng kích thước của hai bộ đệm danh sách thu thập phân tán.

- Nó thường được sử dụng để sao chép dữ liệu pixel giữa bộ nhớ máy chủ và
    Bộ nhớ thiết bị GPU được ánh xạ bộ nhớ, chẳng hạn như được tìm thấy trên đồ họa video PCI hiện đại
    thẻ. Ví dụ trực quan nhất là hàm OpenGL API
    ZZ0000ZZ, có thể yêu cầu bản sao nguyên văn của một tài liệu khổng lồ
    bộ đệm khung từ bộ nhớ thiết bị cục bộ vào bộ nhớ máy chủ.

-DMA_XOR

- Thiết bị có thể thực hiện các thao tác XOR trên vùng bộ nhớ

- Được sử dụng để tăng tốc các tác vụ chuyên sâu của XOR, chẳng hạn như RAID5

-DMA_XOR_VAL

- Thiết bị có thể thực hiện kiểm tra tính chẵn lẻ bằng XOR
    thuật toán dựa vào bộ nhớ đệm.

-DMA_PQ

- Thiết bị có thể thực hiện các phép tính RAID6 P+Q, P là một
    XOR đơn giản và Q là thuật toán Reed-Solomon.

-DMA_PQ_VAL

- Thiết bị có thể thực hiện kiểm tra tính chẵn lẻ bằng RAID6 P+Q
    thuật toán dựa vào bộ nhớ đệm.

-DMA_MEMSET

- Thiết bị có thể lấp đầy bộ nhớ với mẫu được cung cấp

- Mẫu được coi là một giá trị có dấu byte đơn.

-DMA_INTERRUPT

- Thiết bị có thể kích hoạt chuyển khoản giả sẽ
    tạo ra các ngắt định kỳ

- Được sử dụng bởi trình điều khiển máy khách để đăng ký một cuộc gọi lại sẽ được thực hiện
    được gọi thường xuyên thông qua ngắt bộ điều khiển DMA

-DMA_PRIVATE

- Các thiết bị chỉ hỗ trợ chuyển giao nô lệ và do đó không hỗ trợ
    có sẵn để chuyển không đồng bộ.

-DMA_ASYNC_TX

- Thiết bị hỗ trợ các hoạt động từ bộ nhớ đến bộ nhớ không đồng bộ,
    bao gồm memcpy, memset, xor, pq, xor_val và pq_val.

- Khả năng này được thiết lập tự động bởi động cơ DMA
    framework và không được cấu hình thủ công bằng thiết bị
    trình điều khiển.

-DMA_SLAVE

- Thiết bị có thể xử lý thiết bị chuyển bộ nhớ, bao gồm
    chuyển giao phân tán-thu thập.

- Trong trường hợp mem2mem, chúng tôi có hai loại riêng biệt để
    xử lý một đoạn đơn lẻ để sao chép hoặc một bộ sưu tập chúng ở đây,
    chúng tôi chỉ có một loại giao dịch duy nhất được cho là
    xử lý cả hai.

- Nếu bạn muốn chuyển một bộ nhớ đệm liền kề,
    chỉ cần xây dựng một danh sách phân tán chỉ với một mục.

-DMA_CYCLIC

- Thiết bị có thể xử lý chuyển giao theo chu kỳ.

- Chuyển theo chu kỳ là chuyển trong đó tập hợp chunk sẽ
    lặp lại chính nó, với mục cuối cùng trỏ đến mục đầu tiên.

- Nó thường được sử dụng để truyền âm thanh, nơi bạn muốn hoạt động
    trên một bộ đệm vòng duy nhất mà bạn sẽ điền dữ liệu âm thanh của mình.

-DMA_INTERLEAVE

- Thiết bị hỗ trợ chuyển xen kẽ.

- Những lần chuyển này có thể truyền dữ liệu từ bộ đệm không liền kề
    vào bộ đệm không liền kề, trái ngược với DMA_SLAVE có thể
    chuyển dữ liệu từ tập dữ liệu không liền kề sang tập dữ liệu liên tục
    bộ đệm đích.

- Nó thường được sử dụng để chuyển nội dung 2d, trong trường hợp đó bạn
    muốn chuyển một phần dữ liệu không nén trực tiếp sang
    hiển thị để in nó

-DMA_COMPLETION_NO_ORDER

- Máy không hỗ trợ hoàn tất đơn hàng.

- Trình điều khiển nên trả về DMA_OUT_OF_ORDER cho device_tx_status nếu
    thiết bị đang cài đặt khả năng này.

- Tất cả việc theo dõi và kiểm tra cookie API sẽ được coi là không hợp lệ nếu
    thiết bị xuất khả năng này.

- Tại thời điểm này, tính năng này không tương thích với tùy chọn bỏ phiếu cho dmatest.

- Nếu giới hạn này được đặt, người dùng nên cung cấp một địa chỉ duy nhất
    mã định danh cho mỗi bộ mô tả được gửi đến thiết bị DMA để
    theo dõi việc hoàn thành một cách chính xác.

-DMA_REPEAT

- Thiết bị hỗ trợ chuyển khoản nhiều lần. Việc chuyển tiền lặp đi lặp lại, được biểu thị bằng
    cờ chuyển DMA_PREP_REPEAT, tương tự như chuyển tuần hoàn ở chỗ
    nó được tự động lặp lại khi kết thúc, nhưng ngoài ra có thể
    được thay thế bởi khách hàng.

- Tính năng này bị giới hạn ở các lần chuyển xen kẽ, do đó cờ này không nên
    được đặt nếu cờ DMA_INTERLEAVE không được đặt. Hạn chế này dựa trên
    nhu cầu hiện tại của khách hàng DMA, hỗ trợ các loại chuyển bổ sung
    nên được bổ sung trong tương lai nếu và khi có nhu cầu.

-DMA_LOAD_EOT

- Thiết bị hỗ trợ thay thế các lần truyền lặp lại khi kết thúc quá trình truyền (EOT)
    bằng cách xếp hàng một lần chuyển mới với bộ cờ DMA_PREP_LOAD_EOT.

- Hỗ trợ thay thế chuyển khoản đang chạy tại một điểm khác (chẳng hạn như
    khi kết thúc đợt thay vì kết thúc chuyển) sẽ được thêm vào trong tương lai
    dựa trên nhu cầu của khách hàng DMA, nếu và khi có nhu cầu.

Những loại khác nhau này cũng sẽ ảnh hưởng đến cách nguồn và đích
địa chỉ thay đổi theo thời gian.

Địa chỉ trỏ đến RAM thường được tăng (hoặc giảm)
sau mỗi lần chuyển giao. Trong trường hợp bộ đệm vòng, chúng có thể lặp
(DMA_CYCLIC). Địa chỉ trỏ đến thanh ghi của thiết bị (ví dụ: FIFO)
thường được cố định.

Hỗ trợ siêu dữ liệu cho mỗi bộ mô tả
-------------------------------
Một số kiến trúc di chuyển dữ liệu (bộ điều khiển và thiết bị ngoại vi DMA) sử dụng siêu dữ liệu
gắn liền với một giao dịch. Vai trò của bộ điều khiển DMA là chuyển giao
tải trọng và siêu dữ liệu cùng với.
Bản thân siêu dữ liệu không được sử dụng bởi chính công cụ DMA nhưng nó chứa
tham số, khóa, vectơ, v.v. cho thiết bị ngoại vi hoặc từ thiết bị ngoại vi.

Khung DMAengine cung cấp những cách chung để tạo điều kiện thuận lợi cho siêu dữ liệu cho
những người mô tả. Tùy thuộc vào kiến trúc, trình điều khiển DMA có thể triển khai
hoặc cả hai phương pháp và tùy thuộc vào trình điều khiển máy khách chọn phương pháp nào
để sử dụng.

-DESC_METADATA_CLIENT

Bộ đệm siêu dữ liệu được phân bổ/cung cấp bởi trình điều khiển máy khách và nó được
  được đính kèm (thông qua trình trợ giúp dmaengine_desc_attach_metadata() vào bộ mô tả.

Từ trình điều khiển DMA, những điều sau đây được mong đợi cho chế độ này:

-DMA_MEM_TO_DEV / DEV_MEM_TO_MEM

Dữ liệu từ bộ đệm siêu dữ liệu được cung cấp phải được chuẩn bị cho DMA
    bộ điều khiển sẽ được gửi cùng với dữ liệu tải trọng. Hoặc bằng cách sao chép vào một
    mô tả phần cứng hoặc gói có tính kết hợp cao.

-DMA_DEV_TO_MEM

Khi hoàn tất quá trình truyền, trình điều khiển DMA phải sao chép siêu dữ liệu sang máy khách
    đã cung cấp bộ đệm siêu dữ liệu trước khi thông báo cho khách hàng về việc hoàn thành.
    Sau khi quá trình truyền hoàn tất, trình điều khiển DMA không được chạm vào siêu dữ liệu
    đệm do khách hàng cung cấp.

-DESC_METADATA_ENGINE

Bộ đệm siêu dữ liệu được phân bổ/quản lý bởi trình điều khiển DMA. Trình điều khiển khách hàng
  có thể yêu cầu con trỏ, kích thước tối đa và kích thước hiện đang được sử dụng của
  siêu dữ liệu và có thể trực tiếp cập nhật hoặc đọc nó. dmaengine_desc_get_metadata_ptr()
  và dmaengine_desc_set_metadata_len() được cung cấp dưới dạng hàm trợ giúp.

Từ trình điều khiển DMA, những điều sau đây được mong đợi cho chế độ này:

- get_metadata_ptr()

Sẽ trả về một con trỏ cho bộ đệm siêu dữ liệu, kích thước tối đa của
    bộ đệm siêu dữ liệu và các byte hiện đang được sử dụng/hợp lệ (nếu có) trong bộ đệm.

- set_metadata_len()

Nó được máy khách gọi sau khi đặt siêu dữ liệu vào bộ đệm
    để cho trình điều khiển DMA biết số byte hợp lệ được cung cấp.

Lưu ý: vì máy khách sẽ yêu cầu con trỏ siêu dữ liệu khi hoàn thành
  gọi lại (trong trường hợp DMA_DEV_TO_MEM), trình điều khiển DMA phải đảm bảo rằng
  bộ mô tả không được giải phóng trước khi gọi lại.

Hoạt động của thiết bị
-----------------

Cấu trúc dma_device của chúng ta cũng yêu cầu một vài con trỏ hàm trong
để triển khai logic thực tế, bây giờ chúng tôi đã mô tả những gì
hoạt động chúng tôi có thể thực hiện.

Các chức năng mà chúng ta phải điền vào đó và do đó phải
triển khai, rõ ràng phụ thuộc vào loại giao dịch bạn đã báo cáo
được hỗ trợ.

-ZZ0000ZZ

-ZZ0000ZZ

- Các chức năng này sẽ được gọi bất cứ khi nào tài xế gọi
    ZZ0000ZZ hoặc ZZ0001ZZ cho lần đầu tiên/cuối cùng
    thời gian trên kênh liên kết với trình điều khiển đó.

- Họ chịu trách nhiệm phân bổ/giải phóng tất cả những thứ cần thiết
    tài nguyên để kênh đó hữu ích cho tài xế của bạn.

- Các chức năng này có thể ngủ.

-ZZ0000ZZ

- Các chức năng này phù hợp với khả năng bạn đã đăng ký
    trước đó.

- Các hàm này đều lấy vùng đệm hoặc danh sách phân tán có liên quan
    cho việc chuyển giao đang được chuẩn bị và nên tạo một phần cứng
    bộ mô tả hoặc danh sách các bộ mô tả phần cứng từ nó

- Các hàm này có thể được gọi từ ngữ cảnh ngắt

- Bất kỳ sự phân bổ nào bạn có thể thực hiện đều phải sử dụng GFP_NOWAIT
    cờ, để không có khả năng ngủ, nhưng không cạn kiệt
    hồ bơi khẩn cấp.

- Trình điều khiển nên cố gắng phân bổ trước bất kỳ bộ nhớ nào họ có thể cần
    trong quá trình thiết lập chuyển giao tại thời điểm thăm dò để tránh đưa vào
    nhiều áp lực lên người cấp phát hiện nay.

- Nó sẽ trả về một thể hiện duy nhất của
    ZZ0000ZZ, điều đó còn thể hiện điều này
    chuyển giao cụ thể.

- Cấu trúc này có thể được khởi tạo bằng hàm
    ZZ0000ZZ.

- Bạn cũng cần đặt các trường sau trong cấu trúc này:

- cờ:
      TODO: Nó có thể được sửa đổi bởi chính trình điều khiển hay không
      nó có phải luôn là những lá cờ được truyền trong các đối số không

- tx_submit: Một con trỏ tới hàm bạn phải triển khai,
      được cho là đẩy bộ mô tả giao dịch hiện tại tới một
      hàng đợi đang chờ xử lý, đang chờ issue_pending được gọi.

- Phys: Địa chỉ vật lý của bộ mô tả được sử dụng sau này bởi
      công cụ DMA để đọc bộ mô tả và bắt đầu truyền.

- Trong cấu trúc này con trỏ hàm callback_result có thể là
    được khởi tạo để người gửi được thông báo rằng một
    giao dịch đã hoàn tất. Trong đoạn mã trước đó, con trỏ hàm
    gọi lại đã được sử dụng. Tuy nhiên nó không cung cấp bất kỳ trạng thái nào cho
    giao dịch và sẽ không còn được dùng nữa. Cấu trúc kết quả được xác định là
    ZZ0000ZZ được chuyển vào callback_result
    có hai trường:

- kết quả: Điều này cung cấp kết quả chuyển giao được xác định bởi
      ZZ0000ZZ. Thành công hoặc một số điều kiện lỗi.

- dư lượng: Cung cấp các byte dư của quá trình truyền cho những byte
      dư lượng hỗ trợ.

-ZZ0000ZZ

- Tương tự như ZZ0000ZZ, nhưng nó lấy một con trỏ tới một
    mảng cấu trúc ZZ0001ZZ, (về lâu dài) sẽ thay thế
    danh sách phân tán.

-ZZ0000ZZ

- Lấy bộ mô tả giao dịch đầu tiên trong hàng đợi đang chờ xử lý,
    và bắt đầu quá trình chuyển giao. Bất cứ khi nào việc chuyển giao đó được thực hiện, nó
    nên chuyển sang giao dịch tiếp theo trong danh sách.

- Hàm này có thể được gọi trong ngữ cảnh ngắt

-ZZ0000ZZ

- Nên báo cáo số byte còn lại đi qua kênh đã cho

- Chỉ nên quan tâm đến phần mô tả giao dịch được truyền dưới dạng
    đối số, không phải đối số hiện đang hoạt động trên một kênh nhất định

- Đối số tx_state có thể là NULL

- Nên dùng dma_set_residue để báo cáo

- Trong trường hợp chuyển giao theo chu kỳ, chỉ cần tính đến
    chiếm tổng kích thước của bộ đệm tuần hoàn.

- Nên trả lại DMA_OUT_OF_ORDER nếu máy không hỗ trợ theo thứ tự
    hoàn thành và đang hoàn thành hoạt động không theo thứ tự.

- Hàm này có thể được gọi trong ngữ cảnh ngắt.

- thiết bị_config

- Cấu hình lại kênh với cấu hình được đưa ra làm đối số

- Lệnh này nên NOT thực hiện đồng bộ hoặc trên bất kỳ
    chuyển khoản hiện đang xếp hàng đợi, nhưng chỉ trên những chuyển tiếp theo

- Trong trường hợp này, hàm sẽ nhận được ZZ0000ZZ
    con trỏ cấu trúc làm đối số, nó sẽ nêu chi tiết
    cấu hình để sử dụng.

- Mặc dù cấu trúc đó chứa trường định hướng, nhưng cấu trúc này
    trường này không được dùng nữa để thay thế cho đối số hướng được đưa ra cho
    các hàm prep_*

- Cuộc gọi này chỉ bắt buộc đối với các hoạt động phụ. Đây có phải là NOT
    được đặt hoặc dự kiến sẽ được đặt cho các hoạt động memcpy.
    Nếu một trình điều khiển hỗ trợ cả hai, nó sẽ sử dụng lệnh gọi này cho nô lệ
    chỉ hoạt động chứ không phải cho hoạt động memcpy.

- thiết bị_tạm dừng

- Tạm dừng chuyển trên kênh

- Lệnh này phải hoạt động đồng bộ trên kênh,
    tạm dừng ngay công việc của kênh đã cho

- thiết bị_sơ yếu lý lịch

- Tiếp tục chuyển khoản trên kênh

- Lệnh này phải hoạt động đồng bộ trên kênh,
    tiếp tục ngay lập tức công việc của kênh đã cho

- thiết bị_terminate_all

- Hủy bỏ tất cả các giao dịch chuyển đang chờ xử lý và đang diễn ra trên kênh

- Đối với các lần chuyển bị hủy bỏ, không nên gọi lại cuộc gọi lại hoàn chỉnh

- Có thể được gọi từ ngữ cảnh nguyên tử hoặc từ bên trong một ngữ cảnh hoàn chỉnh
    gọi lại của một bộ mô tả. Không được ngủ. Người lái xe phải có khả năng
    để xử lý việc này một cách chính xác.

- Việc chấm dứt có thể không đồng bộ. Người lái xe không cần phải
    đợi cho đến khi quá trình truyền hiện đang hoạt động đã dừng hoàn toàn.
    Xem device_synchronize.

- thiết bị_đồng bộ hóa

- Phải đồng bộ hóa việc chấm dứt kênh với hiện tại
    bối cảnh.

- Phải đảm bảo rằng bộ nhớ đã được gửi trước đó
    bộ mô tả không còn được bộ điều khiển DMA truy cập nữa.

- Phải đảm bảo rằng tất cả các cuộc gọi lại hoàn chỉnh cho trước đó
    các mô tả được gửi đã chạy xong và không có mô tả nào
    đã lên lịch chạy.

- Có thể ngủ.


ghi chú linh tinh
==========

(những thứ đáng lẽ phải được ghi lại, nhưng thực sự không biết
đặt chúng ở đâu)

ZZ0000ZZ

- Nên được gọi khi kết thúc quá trình truyền TX không đồng bộ và có thể
  bị bỏ qua trong trường hợp chuyển giao nô lệ.

- Đảm bảo rằng các hoạt động phụ thuộc được chạy trước khi đánh dấu nó
  như hoàn chỉnh.

dma_cookie_t

- đó là ID giao dịch DMA sẽ tăng dần theo thời gian.

- Không thực sự phù hợp nữa kể từ khi ZZ0000ZZ được giới thiệu
  điều đó trừu tượng hóa nó đi.

dma_vec

- Một cấu trúc nhỏ chứa địa chỉ và độ dài DMA.

DMA_CTRL_ACK

- Nếu không rõ ràng, bộ mô tả không thể được nhà cung cấp sử dụng lại cho đến khi
  khách hàng xác nhận đã nhận, tức là có cơ hội thiết lập bất kỳ
  chuỗi phụ thuộc

- Điều này có thể được xác nhận bằng cách gọi async_tx_ack()

- Nếu được đặt, không có nghĩa là bộ mô tả có thể được sử dụng lại

DMA_CTRL_REUSE

- Nếu được đặt, bộ mô tả có thể được sử dụng lại sau khi hoàn thành. Nó nên
  không được nhà cung cấp giải phóng nếu cờ này được đặt.

- Bộ mô tả nên được chuẩn bị để tái sử dụng bằng cách gọi
  ZZ0000ZZ sẽ đặt DMA_CTRL_REUSE.

- ZZ0000ZZ sẽ chỉ thành công khi được hỗ trợ kênh
  mô tả có thể tái sử dụng được thể hiện bằng khả năng

- Kết quả là, nếu trình điều khiển thiết bị muốn bỏ qua
  ZZ0000ZZ và ZZ0001ZZ ở giữa 2 lần chuyển,
  vì dữ liệu DMA'd chưa được sử dụng nên nó có thể gửi lại quá trình chuyển ngay sau đó
  sự hoàn thành của nó.

- Bộ mô tả có thể được giải phóng bằng một số cách

- Xóa DMA_CTRL_REUSE bằng cách gọi
    ZZ0000ZZ và gửi lần txn cuối cùng

- Gọi ZZ0000ZZ một cách rõ ràng, việc này chỉ có thể thành công
    khi DMA_CTRL_REUSE đã được thiết lập

- Chấm dứt kênh

-DMA_PREP_CMD

- Nếu được đặt, trình điều khiển máy khách sẽ thông báo cho bộ điều khiển DMA đã truyền dữ liệu trong DMA
    API là dữ liệu lệnh.

- Giải thích dữ liệu lệnh là bộ điều khiển DMA cụ thể. Nó có thể
    được sử dụng để phát lệnh tới các thiết bị ngoại vi khác/đăng ký đọc/đăng ký
    viết mà bộ mô tả phải ở định dạng khác với
    mô tả dữ liệu thông thường.

-DMA_PREP_REPEAT

- Nếu được đặt, quá trình truyền sẽ được tự động lặp lại khi kết thúc cho đến khi
    chuyển mới được xếp hàng đợi trên cùng một kênh với cờ DMA_PREP_LOAD_EOT.
    Nếu lần truyền tiếp theo được xếp hàng đợi trên kênh không có
    Cờ DMA_PREP_LOAD_EOT được đặt, quá trình truyền hiện tại sẽ được lặp lại cho đến khi
    khách hàng chấm dứt tất cả các giao dịch chuyển tiền.

- Cờ này chỉ được hỗ trợ nếu kênh báo cáo DMA_REPEAT
    khả năng.

-DMA_PREP_LOAD_EOT

- Nếu được đặt, việc chuyển tiền sẽ thay thế việc chuyển tiền hiện đang được thực hiện tại
    sự kết thúc của việc chuyển giao.

- Đây là hành vi mặc định cho các lần chuyển không lặp lại, chỉ định
    Do đó, DMA_PREP_LOAD_EOT đối với các lần chuyển không lặp lại sẽ không tạo ra sự khác biệt.

- Khi sử dụng chuyển khoản lặp lại, máy khách DMA thường sẽ cần đặt
    Cờ DMA_PREP_LOAD_EOT trên tất cả các lần chuyển, nếu không kênh sẽ giữ nguyên
    lặp lại lần chuyển lặp lại cuối cùng và bỏ qua các lần chuyển mới đang được thực hiện
    xếp hàng. Việc không đặt DMA_PREP_LOAD_EOT sẽ xuất hiện như thể kênh đó đã được
    bị kẹt ở lần chuyển trước đó.

- Cờ này chỉ được hỗ trợ nếu kênh báo cáo DMA_LOAD_EOT
    khả năng.

Ghi chú thiết kế chung
====================

Hầu hết các trình điều khiển DMAEngine bạn sẽ thấy đều dựa trên thiết kế tương tự
xử lý việc kết thúc các ngắt truyền trong trình xử lý, nhưng trì hoãn
hầu hết đều hoạt động với một tasklet, bao gồm cả việc bắt đầu chuyển giao mới bất cứ khi nào
lần chuyển tiền trước đó đã kết thúc.

Tuy nhiên, đây là một thiết kế khá kém hiệu quả, bởi vì việc chuyển giao giữa các
độ trễ sẽ không chỉ là độ trễ ngắt mà còn là độ trễ
độ trễ lập kế hoạch của tasklet, điều này sẽ khiến kênh không hoạt động
ở giữa, điều này sẽ làm chậm tốc độ truyền tải toàn cầu.

Bạn nên tránh kiểu thực hành này và thay vì chọn một phương pháp mới
chuyển trong tasklet của bạn, hãy di chuyển phần đó tới bộ xử lý ngắt trong
để có thời gian chờ ngắn hơn (điều mà chúng tôi thực sự không thể tránh được
dù sao đi nữa).

Thuật ngữ
========

- Burst: Một số thao tác đọc hoặc ghi liên tiếp được thực hiện
  có thể được xếp hàng vào bộ đệm trước khi được chuyển vào bộ nhớ.

- Chunk: Tập hợp các cụm liền kề nhau

- Chuyển giao: Một tập hợp các khối (có thể liền kề hoặc không)
