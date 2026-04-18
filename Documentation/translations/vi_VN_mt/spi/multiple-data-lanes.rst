.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/spi/multiple-data-lanes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================
Thiết bị SPI có nhiều làn dữ liệu
====================================

Một số bộ điều khiển và thiết bị ngoại vi SPI chuyên dụng hỗ trợ nhiều làn dữ liệu
cho phép đọc nhiều từ cùng một lúc. Điều này khác
từ SPI kép/bốn/bát phân trong đó nhiều bit của một từ được truyền
đồng thời.

Ví dụ: bộ điều khiển hỗ trợ bộ nhớ flash song song có tính năng này
cũng như một số ADC lấy mẫu đồng thời trong đó mỗi kênh có làn dữ liệu riêng.

---------------------
Mô tả hệ thống dây điện
---------------------

Thuộc tính ZZ0000ZZ và ZZ0001ZZ trong cây thiết bị
được sử dụng để mô tả có bao nhiêu làn dữ liệu được kết nối giữa bộ điều khiển
và mỗi làn đường rộng bao nhiêu. Số phần tử trong mảng cho biết có bao nhiêu phần tử
có các làn đường và giá trị của mỗi mục cho biết độ rộng của nó là bao nhiêu bit.
làn đường là.

Ví dụ: ADC lấy mẫu đồng thời kép với hai làn 4 bit có thể
nối dây như thế này::

+--------------+ +----------+
    ZZ0000ZZ ZZ0001ZZ
    ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ ZZ0005ZZ
    ZZ0006ZZ--->ZZ0007ZZ
    ZZ0008ZZ--->ZZ0009ZZ
    ZZ0010ZZ--->ZZ0011ZZ
    ZZ0012ZZ ZZ0013ZZ
    ZZ0014ZZ<---ZZ0015ZZ
    ZZ0016ZZ<---ZZ0017ZZ
    ZZ0018ZZ<---ZZ0019ZZ
    ZZ0020ZZ<---ZZ0021ZZ
    ZZ0022ZZ ZZ0023ZZ
    ZZ0024ZZ<---ZZ0025ZZ
    ZZ0026ZZ<---ZZ0027ZZ
    ZZ0028ZZ<---ZZ0029ZZ
    ZZ0030ZZ<---ZZ0031ZZ
    ZZ0032ZZ ZZ0033ZZ
    +--------------+ +----------+

Nó được mô tả trong một cây thiết bị như thế này ::

spi {
        tương thích = "của tôi, bộ điều khiển spi";

        ...

adc@0 {
            tương thích = "adi,ad4630";
            reg = <0>;
            ...
spi-rx-bus-width = <4>, <4>; /* 2 làn, mỗi làn 4 bit */
            ...
        };
    };

Trong hầu hết các trường hợp, các làn đường sẽ được nối đối xứng (A đến A, B đến B, v.v.). Nếu
không phải vậy, thêm ZZ0000ZZ và ZZ0001ZZ
các thuộc tính là cần thiết để cung cấp ánh xạ giữa các làn điều khiển và
dây làn đường vật lý.

Dưới đây là ví dụ trong đó bộ điều khiển SPI nhiều làn có mỗi làn được nối dây với
thiết bị ngoại vi một làn riêng biệt::

+--------------+ +----------+
    ZZ0000ZZ ZZ0001ZZ
    ZZ0002ZZ ZZ0003ZZ
    ZZ0004ZZ ZZ0005ZZ
    ZZ0006ZZ--->ZZ0007ZZ
    ZZ0008ZZ--->ZZ0009ZZ
    ZZ0010ZZ<---ZZ0011ZZ
    ZZ0012ZZ--->ZZ0013ZZ
    ZZ0014ZZ ZZ0015ZZ
    ZZ0016ZZ +----------+
    ZZ0017ZZ
    ZZ0018ZZ +----------+
    ZZ0019ZZ ZZ0020ZZ
    ZZ0021ZZ ZZ0022ZZ
    ZZ0023ZZ--->ZZ0024ZZ
    ZZ0025ZZ--->ZZ0026ZZ
    ZZ0027ZZ<---ZZ0028ZZ
    ZZ0029ZZ--->ZZ0030ZZ
    ZZ0031ZZ ZZ0032ZZ
    +--------------+ +----------+

Điều này được mô tả trong một cây thiết bị như thế này::

spi {
        tương thích = "của tôi, bộ điều khiển spi";

        ...

điều1@0 {
            tương thích = "của tôi,thing1";
            reg = <0>;
            ...
        };

điều2@1 {
            tương thích = "của tôi,thing2";
            reg = <1>;
            ...
spi-tx-lane-map = <1>; /* Lane 0 không được sử dụng, Lane 1 được sử dụng cho dây tx */
            spi-rx-lane-map = <1>; /* Lane 0 không được sử dụng, Lane 1 được sử dụng cho dây rx */
            ...
        };
    };


Các giá trị mặc định của ZZ0000ZZ và ZZ0001ZZ là ZZ0002ZZ,
vì vậy các thuộc tính này vẫn có thể bị bỏ qua ngay cả khi ZZ0003ZZ và
ZZ0004ZZ được sử dụng.

----------------------------
Sử dụng trong trình điều khiển ngoại vi
----------------------------

Các loại bộ điều khiển SPI này thường không hỗ trợ việc sử dụng tùy ý
nhiều làn đường. Thay vào đó, chúng hoạt động ở một trong số ít chế độ được xác định. Ngoại vi
trình điều khiển nên đặt ZZ0000ZZ
để cho biết họ muốn sử dụng chế độ nào cho một lần truyền nhất định.

Các giá trị có thể có cho trường này có ngữ nghĩa sau:

- ZZ0000ZZ: Chỉ sử dụng làn đường đầu tiên. Các làn đường khác là
    bị phớt lờ. Điều này có nghĩa là nó hoạt động giống như SPI thông thường
    ngoại vi. Đây là mặc định nên không cần thiết lập rõ ràng.

Ví dụ::

tx_buf[0] = 0x88;

cấu trúc spi_transfer xfer = {
            .tx_buf = tx_buf,
            .len = 1,
        };

spi_sync_transfer(spi, &xfer, 1);

Giả sử bộ điều khiển gửi MSB trước tiên, chuỗi bit
    được gửi qua dây tx sẽ là (bit ngoài cùng bên phải được gửi trước)::

bộ điều khiển> bit dữ liệu> thiết bị ngoại vi
        ---------- ------- ----------
            SDO 0 0-0-0-1-0-0-0-1 SDI 0

- ZZ0000ZZ: Gửi một từ dữ liệu duy nhất trên tất cả các
    làn đường cùng một lúc. Điều này chỉ có ý nghĩa đối với việc viết chứ không phải
    để đọc.

Ví dụ::

tx_buf[0] = 0x88;

cấu trúc spi_transfer xfer = {
            .tx_buf = tx_buf,
            .len = 1,
            .multi_lane_mode = SPI_MULTI_BUS_MODE_MIRROR,
        };

spi_sync_transfer(spi, &xfer, 1);

Dữ liệu được phản ánh trên mỗi dây tx::

bộ điều khiển> bit dữ liệu> thiết bị ngoại vi
        ---------- ------- ----------
            SDO 0 0-0-0-1-0-0-0-1 SDI 0
            SDO 1 0-0-0-1-0-0-0-1 SDI 1

- ZZ0000ZZ: Gửi hoặc nhận hai từ dữ liệu khác nhau
    đồng thời, mỗi làn một chiếc. Điều này có nghĩa là bộ đệm cần phải được
    có kích thước để chứa dữ liệu cho tất cả các làn đường. Dữ liệu được xen kẽ trong bộ đệm, với
    từ đầu tiên tương ứng với làn 0, từ thứ hai tương ứng với làn 1, v.v.
    Khi làn cuối cùng được sử dụng, từ tiếp theo trong bộ đệm sẽ tương ứng với làn
    0 lần nữa. Theo đó, kích thước bộ đệm phải là bội số của số lượng
    làn đường. Chế độ này hoạt động cho cả đọc và ghi.

Ví dụ::

cấu trúc spi_transfer xfer = {
            .rx_buf = rx_buf,
            .len = 2,
            .multi_lane_mode = SPI_MULTI_BUS_MODE_STRIPE,
        };

spi_sync_transfer(spi, &xfer, 1);

Mỗi dây rx có một từ dữ liệu khác nhau được gửi đồng thời ::

bộ điều khiển < bit dữ liệu < thiết bị ngoại vi
        ---------- ------- ----------
            SDI 0 0-0-0-1-0-0-0-1 SDO 0
            SDI 1 1-0-0-0-1-0-0-0 SDO 1

Sau khi chuyển, ZZ0000ZZ (từ từ SDO 0) và
    ZZ0001ZZ (từ từ SDO 1).


-----------------------------
Hỗ trợ trình điều khiển bộ điều khiển SPI
-----------------------------

Để hỗ trợ nhiều làn dữ liệu, trình điều khiển bộ điều khiển SPI cần thiết lập
ZZ0000ZZ thành một giá trị
lớn hơn 1.

Sau đó, phần trình điều khiển xử lý việc chuyển SPI cần kiểm tra
Trường ZZ0000ZZ và triển khai
hành vi thích hợp cho từng chế độ được hỗ trợ và trả về lỗi cho
các chế độ không được hỗ trợ.

Mã SPI cốt lõi sẽ xử lý phần còn lại.
