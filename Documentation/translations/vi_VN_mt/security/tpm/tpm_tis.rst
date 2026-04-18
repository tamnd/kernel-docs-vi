.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/security/tpm/tpm_tis.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Trình điều khiển giao diện TPM FIFO
=========================

Thông số kỹ thuật TCG PTP xác định hai loại giao diện: FIFO và CRB. Cái trước là
dựa trên các hoạt động đọc và ghi theo trình tự, và thao tác sau dựa trên một
bộ đệm chứa lệnh hoặc phản hồi đầy đủ.

Giao diện FIFO (First-In-First-Out) được sử dụng bởi người phụ thuộc tpm_tis_core
trình điều khiển. Ban đầu Linux chỉ có một trình điều khiển tên là tpm_tis, bao gồm
giao diện ánh xạ bộ nhớ (còn gọi là MMIO) nhưng sau đó nó được mở rộng để bao gồm các giao diện khác
giao diện vật lý được hỗ trợ bởi tiêu chuẩn TCG.

Vì các lý do lịch sử nêu trên, trình điều khiển MMIO ban đầu được gọi là tpm_tis và
framework cho trình điều khiển FIFO được đặt tên là tpm_tis_core. Hậu tố "tis" trong
tpm_tis xuất phát từ Đặc tả giao diện TPM, là phần cứng
đặc tả giao diện cho chip TPM 1.x.

Giao tiếp dựa trên bộ đệm 20 KiB được chia sẻ bởi chip TPM thông qua một
bus phần cứng hoặc bản đồ bộ nhớ, tùy thuộc vào hệ thống dây điện vật lý. Bộ đệm là
tiếp tục chia thành năm bộ đệm 4 KiB có kích thước bằng nhau, cung cấp tương đương
bộ thanh ghi để liên lạc giữa CPU và TPM. Những cái này
điểm cuối truyền thông được gọi là địa phương theo thuật ngữ TCG.

Khi kernel muốn gửi lệnh tới chip TPM, trước tiên nó sẽ dự trữ
địa phương 0 bằng cách đặt bit requestUse trong thanh ghi TPM_ACCESS. Một chút là
được xóa bởi chip khi quyền truy cập được cấp. Một khi nó hoàn thành
giao tiếp, kernel ghi bit TPM_ACCESS.activeLocality. Cái này
thông báo cho chip rằng địa phương đã bị từ bỏ.

Các địa phương đang chờ xử lý được chip phục vụ theo thứ tự giảm dần, một tại
một thời gian:

- Địa phương 0 có mức độ ưu tiên thấp nhất.
- Địa phương 5 có mức độ ưu tiên cao nhất.

Thông tin thêm về mục đích và ý nghĩa của các địa phương có thể được tìm thấy
trong phần 3.2 của Thông số cấu hình TPM của Nền tảng máy khách PC TCG.

Tài liệu tham khảo
==========

Thông số kỹ thuật nền tảng máy khách PC TCG Cấu hình TPM (PTP)
ZZ0000ZZ