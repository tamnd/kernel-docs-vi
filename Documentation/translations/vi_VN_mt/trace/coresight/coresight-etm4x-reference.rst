.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-etm4x-reference.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

================================================================
Tài liệu tham khảo lập trình trình điều khiển linux ETMv4 sysfs.
================================================================

:Tác giả: Mike Leach <mike.leach@linaro.org>
    :Ngày: 11 tháng 10 năm 2019

Bổ sung vào tài liệu trình điều khiển ETMv4 hiện có.

Các tập tin và thư mục Sysfs
---------------------------

Gốc: ZZ0000ZZ


Các đoạn văn sau đây giải thích sự liên kết giữa các tập tin sysfs và
ETMv4 đăng ký mà chúng có hiệu lực. Lưu ý tên đăng ký được đưa ra mà không có
tiền tố 'TRC'.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: {CONFIGR + những người khác}
:Ghi chú:
    Tính năng theo dõi chọn bit. Xem phần 'chế độ' bên dưới. Bit
    trong điều này sẽ gây ra việc lập trình cấu hình theo dõi tương đương và
    các thanh ghi khác để kích hoạt các tính năng được yêu cầu.

:Cú pháp & ví dụ:
    ZZ0000ZZ

bitfield lên đến 32 bit thiết lập các tính năng theo dõi.

:Ví dụ:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (wo)
: Sổ đăng ký dấu vết: Tất cả
:Ghi chú:
    Đặt lại tất cả chương trình để không theo dõi gì/không lập trình logic.

:Cú pháp:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (wo)
: Thanh ghi dấu vết: PRGCTLR, Tất cả các bản ghi phần cứng.
:Ghi chú:
    -> 0 : Lập trình phần cứng với các giá trị hiện tại được giữ trong trình điều khiển
      và cho phép theo dõi.

- = 0 : vô hiệu hóa phần cứng theo dõi.

:Cú pháp:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (ro)
: Sổ đăng ký dấu vết: Không có.
:Ghi chú:
    ID CPU mà ETM này được gắn vào.

:Ví dụ:
    ZZ0000ZZ

ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (ro)
: Sổ đăng ký dấu vết: Không có.
:Ghi chú:
    Khi FEAT_TRF được triển khai, giá trị TRFCR_ELx.TS được sử dụng cho phiên theo dõi. Ngược lại -1
    chỉ ra một nguồn thời gian không xác định. Kiểm tra trcidr0.tssize để xem liệu dấu thời gian chung có
    có sẵn.

:Ví dụ:
    ZZ0000ZZ

ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có.
:Ghi chú:
    Đăng ký ảo để so sánh địa chỉ chỉ mục và phạm vi
    tính năng. Đặt chỉ mục cho cặp đầu tiên trong một phạm vi.

:Cú pháp:
    ZZ0000ZZ

Trong đó idx < nr_addr_cmp x 2

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACVR[idx, idx+1], VIIECTLR
:Ghi chú:
    Cặp địa chỉ cho một phạm vi được chọn bởi addr_idx. Bao gồm
    / loại trừ theo tham số tùy chọn, hoặc nếu bỏ qua
    sử dụng cài đặt 'chế độ' hiện tại. Chọn phạm vi so sánh trong
    thanh ghi điều khiển. Lỗi nếu chỉ mục có giá trị lẻ.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
   ZZ0001ZZ

Trong đó addr1 và addr2 xác định phạm vi và addr1 < addr2.

Giá trị loại trừ tùy chọn: -

- 0 để bao gồm
   - 1 để loại trừ.
:Ví dụ:
   ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACVR[idx]
:Ghi chú:
    Đặt một bộ so sánh địa chỉ duy nhất theo addr_idx. Cái này
    được sử dụng nếu bộ so sánh địa chỉ được sử dụng như một phần của sự kiện
    logic thế hệ, v.v.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
   ZZ0001ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACVR[idx], VISSCTLR
:Ghi chú:
    Đặt bộ so sánh địa chỉ bắt đầu theo dõi theo addr_idx.
    Chọn bộ so sánh trong thanh ghi điều khiển.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACVR[idx], VISSCTLR
:Ghi chú:
    Đặt bộ so sánh địa chỉ dừng theo dõi theo addr_idx.
    Chọn bộ so sánh trong thanh ghi điều khiển.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACATR[idx,{6:4}]
:Ghi chú:
    Liên kết bộ so sánh ID ngữ cảnh với bộ so sánh địa chỉ addr_idx

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó ctxt_idx là chỉ mục của ngữ cảnh được liên kết id/vmid
    bộ so sánh.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACATR[idx,{3:2}]
:Ghi chú:
    Chuỗi giá trị đầu vào. Đặt loại cho bộ so sánh ID ngữ cảnh được liên kết

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Nhập một trong số {tất cả, vmid, ctxid, none}
:Ví dụ:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACATR[idx,{14:8}]
:Ghi chú:
    Đặt các bit khớp an toàn và không an toàn ELx cho
    bộ so sánh địa chỉ đã chọn

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

val là giá trị 7 bit để loại trừ các mức ngoại lệ. đầu vào
    giá trị được chuyển sang các bit chính xác trong thanh ghi.
:Ví dụ:
    ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: ACATR[idx,{1:0}]
:Ghi chú:
    Đặt loại địa chỉ so sánh để khớp. Chỉ có tài xế
    hỗ trợ cài đặt loại địa chỉ hướng dẫn.

: Phụ thuộc: ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: ACVR[idx, idx+1], ACATR[idx], VIIECTLR
:Ghi chú:
    Đọc bộ so sánh địa chỉ hiện được chọn. Nếu một phần của
    phạm vi địa chỉ sau đó hiển thị cả hai địa chỉ.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ
:Ví dụ:
    ZZ0002ZZ

ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số cặp so sánh địa chỉ

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có
:Ghi chú:
    Chọn bộ thanh ghi bắn đơn.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SSCCR[idx]
:Ghi chú:
    Truy cập vào thanh ghi điều khiển bộ so sánh một lần chụp.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Ghi val vào thanh ghi điều khiển đã chọn.

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: SSCSR[idx]
:Ghi chú:
    Đọc một thanh ghi trạng thái so sánh một lần chụp

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Đọc trạng thái.
:Ví dụ:
    ZZ0000ZZ

ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SSPCICR[idx]
:Ghi chú:
    Truy cập vào thanh ghi điều khiển đầu vào của bộ so sánh PE một lần.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Ghi val vào thanh ghi điều khiển đã chọn.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: VICTLR{23:20}
:Ghi chú:
    Lập trình bộ lọc mức ngoại lệ không an toàn. Đặt/xóa NS
    bit lọc ngoại lệ. Cài đặt '1' loại trừ dấu vết khỏi
    mức độ ngoại lệ.

:Cú pháp:
    ZZ0000ZZ

Trong đó trường bit chứa các bit cần đặt rõ ràng cho EL0 thành EL2
:Ví dụ:
    ZZ0000ZZ

Không bao gồm dấu vết EL2 NS.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: VIPCSSCTLR
:Ghi chú:
    Truy cập các thanh ghi điều khiển đầu vào của bộ so sánh khởi động PE

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: BBCTLR
:Ghi chú:
    Xác định phạm vi mà Branch Broadcast sẽ hoạt động.
    Mặc định (0x0) là tất cả các địa chỉ.

: Phụ thuộc: BB đã bật.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: CCCTLR
:Ghi chú:
    Đặt ngưỡng cho số chu kỳ sẽ được phát ra.
    Lỗi nếu cố gắng đặt dưới mức tối thiểu được xác định trong IDR3, bị che
    theo chiều rộng của các bit hợp lệ.

: Phụ thuộc: CC đã bật.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SYNCPR
:Ghi chú:
    Đặt thời gian đồng bộ hóa dấu vết. lũy thừa 2 giá trị, 0 (tắt)
    hoặc 8-20. Trình điều khiển mặc định là 12 (cứ sau 4096 byte).

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: không có
:Ghi chú:
    Chọn bộ đếm để truy cập

:Cú pháp:
    ZZ0000ZZ

Ở đâu idx < nr_cntr

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: CNTCTLR[idx]
:Ghi chú:
    Đặt giá trị điều khiển bộ đếm.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó val là theo thông số ETMv4.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: CNTRLDVR[idx]
:Ghi chú:
    Đặt giá trị tải lại bộ đếm.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó val là theo thông số ETMv4.

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR5

:Ghi chú:
    Số lượng quầy được thực hiện.

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có
:Ghi chú:
    Chọn bộ so sánh ID ngữ cảnh để truy cập

:Cú pháp:
    ZZ0000ZZ

Trong đó idx < numcidc

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: CIDCVR[idx]
:Ghi chú:
   Đặt giá trị so sánh ID ngữ cảnh

: Phụ thuộc: ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: CIDCCTLR0, CIDCCTLR1, CIDCVR<0-7>
:Ghi chú:
    Cặp giá trị để đặt mặt nạ byte cho ID ngữ cảnh 1-8
    bộ so sánh. Tự động xóa byte bị che về 0 trong CID
    các thanh ghi giá trị.

:Cú pháp:
    ZZ0000ZZ

Các giá trị 32 bit được tạo thành từ các byte mặt nạ, trong đó mN đại diện cho
    giá trị mặt nạ byte cho bộ so sánh ID ngữ cảnh N.

Giá trị thứ hai không bắt buộc trên các hệ thống có ít hơn 4
    bộ so sánh ID ngữ cảnh

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số lượng bộ so sánh ID ngữ cảnh

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có
:Ghi chú:
    Chọn bộ so sánh VM ID để truy cập.

:Cú pháp:
    ZZ0000ZZ

Ở đâu idx < numvmidc

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: VMIDCVR[idx]
:Ghi chú:
    Đặt giá trị so sánh VM ID

: Phụ thuộc: ZZ0000ZZ

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: VMIDCCTLR0, VMIDCCTLR1, VMIDCVR<0-7>
:Ghi chú:
    Cặp giá trị để đặt mặt nạ byte cho bộ so sánh ID VM 1-8.
    Tự động xóa các byte bị che về 0 trong các thanh ghi giá trị VMID.

:Cú pháp:
    ZZ0000ZZ

Trong đó mN đại diện cho giá trị mặt nạ byte cho bộ so sánh VMID N.
    Giá trị thứ hai không bắt buộc trên các hệ thống có ít hơn 4
    Bộ so sánh VMID.

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số lượng bộ so sánh VMID

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có.
:Ghi chú:
    Chọn điều khiển bộ chọn tài nguyên để truy cập. Phải là 2 hoặc
    cao hơn khi bộ chọn 0 và 1 được nối cứng.

:Cú pháp:
    ZZ0000ZZ

Trong đó 2 <= idx < nr_resource x 2

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: RSCTLR[idx]
:Ghi chú:
    Đặt giá trị điều khiển bộ chọn tài nguyên. Giá trị trên mỗi thông số ETMv4.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó val là theo thông số ETMv4.

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số cặp bộ chọn tài nguyên

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: EVENTCTRL0R
:Ghi chú:
    Thiết lập tối đa 4 trường sự kiện được triển khai.

:Cú pháp:
    ZZ0000ZZ

Trong đó evN là trường sự kiện 8 bit. Tối đa 4 trường sự kiện tạo nên
    Giá trị đầu vào 32 bit. Số lượng trường hợp lệ phụ thuộc vào việc triển khai,
    được định nghĩa trong IDR0.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: EVENTCTRL1R
:Ghi chú:
    Chọn các sự kiện chèn các gói sự kiện vào luồng theo dõi.

: Phụ thuộc: EVENTCTRL0R
:Cú pháp:
    ZZ0000ZZ

Trong đó bitfield lên tới 4 bit tùy theo số trường sự kiện.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: TSCTLR
:Ghi chú:
    Đặt sự kiện sẽ tạo yêu cầu dấu thời gian.

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó evfield là bộ chọn sự kiện 8 bit.

----

:Tập tin: ZZ0000ZZ (rw)
: Sổ đăng ký dấu vết: Không có
:Ghi chú:
    Chọn thanh ghi sự kiện tuần tự - 0 đến 2

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SEQSTR
:Ghi chú:
    Trạng thái hiện tại của trình sắp xếp - 0 đến 3.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SEQEVR[idx]
:Ghi chú:
    Sổ đăng ký sự kiện chuyển trạng thái

:Phụ thuộc: ZZ0000ZZ
:Cú pháp:
    ZZ0001ZZ

Trong đó evBevF là giá trị 16 bit được tạo thành từ hai bộ chọn sự kiện,

- evB : quay lại
    - evF: chuyển tiếp.

----

:Tập tin: ZZ0000ZZ (rw)
:Thanh ghi dấu vết: SEQRSTEVR
:Ghi chú:
    Sự kiện đặt lại trình tự

:Cú pháp:
    ZZ0000ZZ

Trong đó evfield là bộ chọn sự kiện 8 bit.

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR5
:Ghi chú:
    Số trạng thái của trình sắp xếp thứ tự (0 hoặc 4)

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số lượng đầu vào bộ so sánh PE

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR5
:Ghi chú:
    Số lượng đầu vào bên ngoài

----

:Tập tin: ZZ0000ZZ (ro)
:Thanh ghi dấu vết: Từ IDR4
:Ghi chú:
    Số lượng thanh ghi điều khiển Single Shot

----

ZZ0000ZZ Khi lập trình bất kỳ bộ so sánh địa chỉ nào, trình điều khiển sẽ gắn thẻ
bộ so sánh với loại được sử dụng - tức là RANGE, SINGLE, START, STOP. Một khi thẻ này
được đặt, thì chỉ có thể thay đổi các giá trị bằng cách sử dụng cùng một tệp/loại sysfs
dùng để lập trình nó.

Như vậy::

% echo 0 > addr_idx ; chọn bộ so sánh địa chỉ 0
  % echo 0x1000 0x5000 0 > addr_range ; đặt phạm vi địa chỉ trên bộ so sánh 0, 1.
  % echo 0x2000 > addr_start ; lỗi vì bộ so sánh 0 là bộ so sánh phạm vi
  % echo 2 > addr_idx ; chọn bộ so sánh địa chỉ 2
  % echo 0x2000 > addr_start ; điều này không sao vì bộ so sánh 2 không được sử dụng.
  % echo 0x3000 > addr_stop ; lỗi so sánh 2 được đặt làm địa chỉ bắt đầu.
  % echo 2 > addr_idx ; chọn bộ so sánh địa chỉ 3
  % echo 0x3000 > addr_stop ; điều này ổn

Để loại bỏ lập trình trên tất cả các bộ so sánh (và tất cả các phần cứng khác), hãy sử dụng
tham số đặt lại::

% echo 1 > đặt lại



Tham số sysfs 'chế độ'.
---------------------------

Đây là tham số lựa chọn trường bit để đặt chế độ theo dõi tổng thể cho
ETM. Bảng bên dưới mô tả các bit, sử dụng định nghĩa từ trình điều khiển
tệp nguồn, cùng với mô tả về tính năng mà chúng đại diện. Nhiều
các tính năng là tùy chọn và do đó phụ thuộc vào việc triển khai trong
phần cứng.

Bài tập bit được hiển thị bên dưới: -

----

ZZ0000ZZ
    ETM_MODE_EXCLUDE

ZZ0000ZZ
    Đây là giá trị mặc định cho hàm bao gồm/loại trừ khi
    thiết lập phạm vi địa chỉ. Đặt 1 cho phạm vi loại trừ. Khi chế độ
    tham số được đặt, giá trị này được áp dụng cho chỉ mục hiện tại
    phạm vi địa chỉ.

.. _coresight-branch-broadcast:

ZZ0000ZZ
    ETM_MODE_BB

ZZ0000ZZ
    Đặt để bật phát sóng nhánh nếu được hỗ trợ trong phần cứng [IDR0]. Công dụng chính của tính năng này
    là khi mã được vá động trong thời gian chạy và toàn bộ luồng chương trình có thể không được thực hiện
    được xây dựng lại chỉ bằng cách sử dụng các nhánh có điều kiện.

Hiện tại Perf không hỗ trợ việc cung cấp các tệp nhị phân đã sửa đổi cho bộ giải mã, vì vậy điều này
    tính năng này chỉ nhằm mục đích sử dụng cho mục đích gỡ lỗi hoặc với công cụ của bên thứ 3.

Việc chọn tùy chọn này sẽ làm tăng đáng kể lượng dấu vết được tạo ra -
    có thể có nguy cơ tràn hoặc có ít hướng dẫn hơn. Lưu ý rằng tùy chọn này cũng
    ghi đè bất kỳ cài đặt nào của ZZ0000ZZ, do đó, nơi một nhánh
    phạm vi phát sóng chồng lên phạm vi ngăn xếp trả về, ngăn xếp trả về sẽ không có sẵn cho phạm vi đó
    phạm vi.

.. _coresight-cycle-accurate:

ZZ0000ZZ
    ETMv4_MODE_CYCACC

ZZ0000ZZ
    Đặt để bật theo dõi chính xác chu kỳ nếu được hỗ trợ [IDR0].


ZZ0000ZZ
    ETMv4_MODE_CTXID

ZZ0000ZZ
    Đặt để bật theo dõi ID ngữ cảnh nếu được hỗ trợ trong phần cứng [IDR2].


ZZ0000ZZ
    ETM_MODE_VMID

ZZ0000ZZ
    Đặt để bật theo dõi ID máy ảo nếu được hỗ trợ [IDR2].

.. _coresight-timestamp:

ZZ0000ZZ
    ETMv4_MODE_TIMESTAMP

ZZ0000ZZ
    Đặt để bật tạo dấu thời gian nếu được hỗ trợ [IDR0].

.. _coresight-return-stack:

ZZ0000ZZ
    ETM_MODE_RETURNSTACK
ZZ0001ZZ
    Đặt để bật sử dụng ngăn xếp trả về dấu vết nếu được hỗ trợ [IDR0].


ZZ0000ZZ
    ETM_MODE_QELEM(giá trị)

ZZ0000ZZ
    'val' xác định mức độ hỗ trợ phần tử Q được bật nếu
    được thực hiện bởi ETM [IDR0]


ZZ0000ZZ
    ETM_MODE_ATB_TRIGGER

ZZ0000ZZ
    Đặt để kích hoạt bit ATBTRIGGER trong thanh ghi điều khiển sự kiện
    [EVENTCTLR1] nếu được hỗ trợ [IDR5].


ZZ0000ZZ
    ETM_MODE_LPOVERRIDE

ZZ0000ZZ
    Đặt để kích hoạt bit LPOVERRIDE trong thanh ghi điều khiển sự kiện
    [EVENTCTLR1], nếu được hỗ trợ [IDR5].


ZZ0000ZZ
    ETM_MODE_ISTALL_EN

ZZ0000ZZ
    Đặt để kích hoạt bit ISTALL trong thanh ghi điều khiển dừng
    [STALLCTLR]


ZZ0000ZZ
    ETM_MODE_INSTPRIO

ZZ0000ZZ
	      Đặt để kích hoạt bit INSTPRIORITY trong thanh ghi điều khiển dừng
	      [STALLCTLR] , nếu được hỗ trợ [IDR0].


ZZ0000ZZ
    ETM_MODE_NOOVERFLOW

ZZ0000ZZ
    Đặt để kích hoạt bit NOOVERFLOW trong thanh ghi điều khiển dừng
    [STALLCTLR], nếu được hỗ trợ [IDR3].


ZZ0000ZZ
    ETM_MODE_TRACE_RESET

ZZ0000ZZ
    Đặt để kích hoạt bit TRCRESET trong thanh ghi điều khiển viewinst
    [VICTLR] , nếu được hỗ trợ [IDR3].


ZZ0000ZZ
    ETM_MODE_TRACE_ERR

ZZ0000ZZ
    Đặt để kích hoạt bit TRCCTRL trong thanh ghi điều khiển viewinst
    [VICTLR].


ZZ0000ZZ
    ETM_MODE_VIEWINST_STARTSTOP

ZZ0000ZZ
    Đặt giá trị trạng thái ban đầu của logic bắt đầu/dừng ViewInst
    trong thanh ghi điều khiển viewinst [VICTLR]


ZZ0000ZZ
    ETM_MODE_EXCL_KERN

ZZ0000ZZ
    Đặt thiết lập theo dõi mặc định để loại trừ dấu vết chế độ kernel (xem lưu ý a)


ZZ0000ZZ
    ETM_MODE_EXCL_USER

ZZ0000ZZ
    Đặt thiết lập theo dõi mặc định để loại trừ dấu vết không gian người dùng (xem lưu ý a)

----

ZZ0000ZZ Khi khởi động, ETM được lập trình để theo dõi không gian địa chỉ đầy đủ
sử dụng bộ so sánh dải địa chỉ 0. Các bit 'chế độ' 30/31 sửa đổi cài đặt này thành
đặt các bit loại trừ EL cho trạng thái NS trong không gian người dùng (EL0) hoặc không gian kernel
(EL1) trong bộ so sánh dải địa chỉ. (cài đặt mặc định loại trừ tất cả
EL an toàn và NS EL2)

Khi tham số đặt lại đã được sử dụng và/hoặc lập trình tùy chỉnh đã được
được triển khai - sử dụng các bit này sẽ tạo ra các bit EL cho địa chỉ
bộ so sánh 0 được đặt theo cách tương tự.

ZZ0000ZZ Bits 2-3, 8-10, 15-16, 18, 22, các tính năng điều khiển chỉ hoạt động với
dấu vết dữ liệu. Vì dấu vết dữ liệu cấu hình A bị cấm về mặt kiến trúc trong ETMv4,
những điều này đã bị bỏ qua ở đây. Các ứng dụng có thể có có thể là nơi hạt nhân có
hỗ trợ kiểm soát cơ sở hạ tầng hồ sơ R hoặc M như một phần của hệ thống không đồng nhất
hệ thống.

Bit 17, 28-29 không được sử dụng.
