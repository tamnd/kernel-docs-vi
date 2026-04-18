.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/firmware-guide/acpi/apei/output_format.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Định dạng đầu ra APEI
=====================

APEI sử dụng printk làm giao diện báo lỗi phần cứng, đầu ra
định dạng như sau::

<bản ghi lỗi> :=
        Trạng thái lỗi phần cứng chung của APEI
        mức độ nghiêm trọng: <số nguyên>, <chuỗi mức độ nghiêm trọng>
        phần: <số nguyên>, mức độ nghiêm trọng: <số nguyên>, <chuỗi mức độ nghiêm trọng>
        cờ: <số nguyên>
        <phần chuỗi cờ>
        fru_id: <chuỗi uuid>
        fru_text: <string>
        phần_type: <chuỗi loại phần>
        <dữ liệu phần>

<chuỗi mức độ nghiêm trọng>* := ZZ0000ZZ có thể phục hồi được đã sửa | thông tin

<chuỗi cờ phần># :=
        [chính][, cảnh báo ngăn chặn][, đặt lại][, vượt quá ngưỡng]\
        [, tài nguyên không thể truy cập được][, lỗi tiềm ẩn]

<chuỗi loại phần> := lỗi bộ xử lý chung ZZ0000ZZ \
        Lỗi PCIe | không xác định, <chuỗi uuid>

<dữ liệu phần> :=
        <dữ liệu phần bộ xử lý chung> ZZ0000ZZ \
        <dữ liệu phần pcie> | <null>

<dữ liệu phần bộ xử lý chung> :=
        [processor_type: <integer>, <proc type string>]
        [bộ xử lý_isa: <số nguyên>, <proc isa string>]
        [loại_lỗi: <số nguyên>
        <chuỗi loại lỗi proc>]
        [thao tác: <số nguyên>, <chuỗi thao tác proc>]
        [cờ: <số nguyên>
        <chuỗi cờ proc>]
        [cấp độ: <số nguyên>]
        [version_info: <số nguyên>]
        [bộ xử lý_id: <số nguyên>]
        [địa chỉ đích: <số nguyên>]
        [requestor_id: <số nguyên>]
        [responder_id: <số nguyên>]
        [IP: <số nguyên>]

<chuỗi loại proc>* := IA32/X64 | IA64

<proc isa string>* := IA32 ZZ0000ZZ X64

<chuỗi loại lỗi bộ xử lý># :=
        [lỗi bộ đệm] [, lỗi TLB] [, lỗi bus] [, lỗi kiến trúc vi mô]

<chuỗi thao tác Proc>* := ghi dữ liệu ZZ0000ZZ không xác định hoặc chung | \
        thực hiện lệnh

<chuỗi cờ proc># :=
        [có thể khởi động lại] [, IP chính xác] [, tràn] [, đã sửa]

<dữ liệu phần bộ nhớ> :=
        [trạng thái lỗi: <số nguyên>]
        [địa chỉ vật lý: <số nguyên>]
        [physical_address_mask: <số nguyên>]
        [nút: <số nguyên>]
        [thẻ: <số nguyên>]
        [mô-đun: <số nguyên>]
        [ngân hàng: <số nguyên>]
        [thiết bị: <số nguyên>]
        [hàng: <số nguyên>]
        [cột: <số nguyên>]
        [bit_position: <số nguyên>]
        [requestor_id: <số nguyên>]
        [responder_id: <số nguyên>]
        [target_id: <số nguyên>]
        [error_type: <integer>, <mem error type string>]

<chuỗi loại lỗi ghi nhớ>* :=
        ZZ0000ZZ bit đơn không xác định ECC ZZ0001ZZ \
        hủy bỏ chipkill ký hiệu đơn ECC ZZ0002ZZ | \
        hủy bỏ mục tiêu ZZ0003ZZ hết thời gian chờ của cơ quan giám sát ZZ0004ZZ \
        gương bị hỏng ZZ0005ZZ đã sửa lỗi chà | \
        chà lỗi chưa sửa

<dữ liệu phần pcie> :=
        [port_type: <số nguyên>, <chuỗi loại cổng pcie>]
        [phiên bản: <số nguyên>.<số nguyên>]
        [lệnh: <số nguyên>, trạng thái: <số nguyên>]
        [device_id: <integer>:<integer>:<integer>.<integer>
        khe: <số nguyên>
        bus_bus thứ cấp: <số nguyên>
        nhà cung cấp_id: <số nguyên>, device_id: <số nguyên>
        class_code: <số nguyên>]
        [số sê-ri: <số nguyên>, <số nguyên>]
        [cầu nối: trạng thái phụ: <số nguyên>, điều khiển: <số nguyên>]
        [aer_status: <số nguyên>, aer_mask: <số nguyên>
        <chuỗi trạng thái aer>
        [aer_uncor_severity: <số nguyên>]
        aer_layer=<chuỗi lớp aer>, aer_agent=<chuỗi tác nhân aer>
        aer_tlp_header: <số nguyên> <số nguyên> <số nguyên> <số nguyên>]

<chuỗi loại cổng pcie>* := Điểm cuối PCIe ZZ0000ZZ \
        cổng gốc ZZ0001ZZ không xác định ZZ0002ZZ \
        cổng chuyển mạch hạ lưu ZZ0003ZZ \
        Cầu nối PCI/PCI-X tới PCIe ZZ0004ZZ \
        trình thu thập sự kiện phức tạp gốc

nếu mức độ nghiêm trọng của phần là nghiêm trọng hoặc có thể phục hồi
        <chuỗi trạng thái aer># :=
        ZZ0000ZZ chưa biết Giao thức liên kết dữ liệu ZZ0001ZZ chưa biết | \
        chưa biết ZZ0002ZZ chưa biết ZZ0003ZZ chưa biết ZZ0004ZZ chưa biết | \
        Hết thời gian hoàn thành TLP ZZ0005ZZ bị nhiễm độc | \
        Trình hoàn thành Hủy bỏ ZZ0006ZZ Tràn bộ thu | \
        Yêu cầu không được hỗ trợ TLP ZZ0007ZZ không đúng định dạng
        khác
        <chuỗi trạng thái aer># :=
        Lỗi bộ thu ZZ0008ZZ không xác định ZZ0009ZZ không xác định ZZ0010ZZ \
        Xấu TLP ZZ0011ZZ RELAY_NUM Chuyển qua ZZ0012ZZ không xác định ZZ0013ZZ \
        Hết giờ phát lại | Lời khuyên không gây tử vong
        fi

<chuỗi lớp aer> :=
        Lớp vật lý Lớp giao dịch ZZ0000ZZ

<chuỗi tác nhân aer> :=
        ID người nhận ZZ0000ZZ ID người hoàn thành | ID máy phát

Trong đó, [] chỉ định nội dung tương ứng là tùy chọn

Tất cả mô tả <field string> có * có định dạng sau::

trường: <số nguyên>, <chuỗi trường>

Trong đó giá trị của <integer> phải là vị trí của "chuỗi" trong <field
chuỗi> mô tả. Nếu không, <field string> sẽ là "không xác định".

Tất cả mô tả <field strings> có # has có định dạng sau::

trường: <số nguyên>
        <chuỗi trường>

Trong đó mỗi chuỗi trong <fields strings> tương ứng với một tập hợp bit của
<số nguyên>. Vị trí bit là vị trí của "chuỗi" trong <field
chuỗi> mô tả.

Để được giải thích chi tiết hơn về từng lĩnh vực, vui lòng tham khảo UEFI
phiên bản đặc tả 2.3 trở lên, phần Phụ lục N: Chung
Bản ghi lỗi nền tảng.