.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/ext4/bigalloc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Bigalloc
--------

Hiện tại, kích thước mặc định của một khối là 4KiB, đây là kích thước phổ biến
kích thước trang được hỗ trợ trên hầu hết phần cứng hỗ trợ MMU. Đây là điều may mắn vì
Mã ext4 không được chuẩn bị để xử lý trường hợp kích thước khối
vượt quá kích thước trang. Tuy nhiên, đối với một hệ thống tập tin chủ yếu là các tập tin lớn,
mong muốn có thể phân bổ các khối đĩa theo đơn vị gồm nhiều
các khối để giảm cả chi phí phân mảnh và siêu dữ liệu. các
Tính năng bigalloc cung cấp chính xác khả năng này.

Tính năng bigalloc (EXT4_FEATURE_RO_COMPAT_BIGALLOC) thay đổi ext4 thành
sử dụng phân bổ theo cụm, sao cho mỗi bit trong phân bổ khối ext4
bitmap giải quyết lũy thừa của hai số khối. Ví dụ, nếu
hệ thống tập tin chủ yếu sẽ lưu trữ các tập tin lớn trong 4-32
phạm vi megabyte, có thể hợp lý nếu đặt kích thước cụm là 1 megabyte.
Điều này có nghĩa là mỗi bit trong bitmap phân bổ khối bây giờ có địa chỉ
256 khối 4k. Điều này thu nhỏ tổng kích thước của việc phân bổ khối
bitmap cho hệ thống tệp 2T từ 64 megabyte đến 256 kilobyte. Nó cũng
có nghĩa là một nhóm khối có địa chỉ 32 gigabyte thay vì 128 megabyte,
cũng thu hẹp lượng chi phí hệ thống tệp cho siêu dữ liệu.

Quản trị viên có thể đặt kích thước cụm khối tại thời điểm mkfs (tức là
được lưu trữ trong trường s_log_cluster_size trong siêu khối); từ đó
bật, các cụm theo dõi bitmap khối chứ không phải các khối riêng lẻ. Điều này có nghĩa
các nhóm khối đó có thể có kích thước vài gigabyte (thay vì chỉ
128MiB); tuy nhiên, đơn vị phân bổ tối thiểu sẽ trở thành một cụm chứ không phải một
chặn, ngay cả đối với các thư mục. TaoBao đã có một bản vá để mở rộng “việc sử dụng
đơn vị của cụm thay vì khối” vào cây phạm vi, mặc dù nó
không rõ những bản vá đó đã đi đâu-- cuối cùng chúng biến thành
“extent tree v2” nhưng mã đó vẫn chưa cập bến kể từ tháng 5 năm 2015.
