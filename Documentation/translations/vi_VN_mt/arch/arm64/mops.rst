.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm64/mops.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

======================================
Hướng dẫn sao chép/thiết lập bộ nhớ (MOPS)
===================================

Thao tác sao chép/thiết lập bộ nhớ MOPS bao gồm ba CPY* hoặc SET* liên tiếp
hướng dẫn: phần mở đầu, phần chính và phần kết (ví dụ: CPYP, CPYM, CPYE).

Hướng dẫn chính hoặc phần kết có thể có ngoại lệ MOPS vì nhiều lý do,
ví dụ: khi một tác vụ được di chuyển sang CPU với MOPS khác
việc triển khai hoặc khi các yêu cầu về kích thước và căn chỉnh của lệnh được đáp ứng
không gặp. Sau đó, trình xử lý ngoại lệ phần mềm sẽ thiết lập lại các thanh ghi
và khởi động lại việc thực thi từ lệnh mở đầu. Thông thường việc này được xử lý
bởi hạt nhân.

Để biết thêm chi tiết, hãy tham khảo "Các ngoại lệ của Sao chép bộ nhớ và Bộ nhớ D1.3.5.7" trong
Sổ tay tham khảo kiến trúc cánh tay DDI 0487K.a (Arm ARM).

.. _arm64_mops_hyp:

Yêu cầu của người giám sát
-----------------------

Trình ảo hóa chạy máy khách Linux phải xử lý tất cả các ngoại lệ MOPS từ
kernel khách, vì Linux không phải lúc nào cũng có thể xử lý được ngoại lệ.
Ví dụ: có thể thực hiện ngoại lệ MOPS khi trình ảo hóa di chuyển vCPU
sang CPU vật lý khác với cách triển khai MOPS khác.

Để làm được điều này, hypervisor phải:

- Đặt HCRX_EL2.MCE2 thành 1 để ngoại lệ được đưa tới bộ ảo hóa.

- Có trình xử lý ngoại lệ thực hiện thuật toán từ Arm ARM
    quy tắc CNTMJ và MWFQH.

- Đặt PSTATE.SS của khách thành 0 trong trình xử lý ngoại lệ để xử lý một
    bước tiềm năng của hướng dẫn hiện tại.

Lưu ý: Cần xóa PSTATE.SS để thực hiện ngoại lệ một bước
    ở lệnh tiếp theo (lệnh mở đầu). Nếu không thì mở đầu
    sẽ bị âm thầm bước qua và ngoại lệ một bước được thực hiện trên
    hướng dẫn chính. Lưu ý rằng nếu hướng dẫn của khách không được thực hiện từng bước
    thì việc xóa PSTATE.SS không có hiệu lực.