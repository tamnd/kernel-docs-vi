.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/modifying-patches.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _modifyingpatches:

Sửa đổi bản vá
=================

Nếu bạn là người bảo trì hệ thống con hoặc chi nhánh, đôi khi bạn cần phải
sửa đổi các bản vá bạn nhận được để hợp nhất chúng, vì mã không
hoàn toàn giống nhau trong cây của bạn và người gửi'. Nếu bạn tuân thủ nghiêm ngặt
quy tắc (c) của giấy chứng nhận xuất xứ của nhà phát triển, bạn nên hỏi người gửi
để làm lại, nhưng điều này hoàn toàn phản tác dụng, lãng phí thời gian và năng lượng.
Quy tắc (b) cho phép bạn điều chỉnh mã, nhưng sau đó thay đổi là rất bất lịch sự
một người gửi mã và yêu cầu anh ta xác nhận lỗi của bạn. Để giải quyết vấn đề này, nó
bạn nên thêm một dòng giữa tiêu đề Signed-off-by cuối cùng và
của bạn, cho biết bản chất của những thay đổi của bạn. Mặc dù không có gì bắt buộc
về điều này, có vẻ như việc thêm mô tả vào trước thư của bạn và/hoặc
tên, tất cả được đặt trong dấu ngoặc vuông, đủ nổi bật để làm cho nó rõ ràng
rằng bạn phải chịu trách nhiệm về những thay đổi vào phút chót. Ví dụ::

Người đăng ký: Nhà phát triển Random J <random@developer.example.org>
       [lucky@maintainer.example.org: struct foo đã được chuyển từ foo.c sang foo.h]
       Người đăng ký: Người bảo trì Lucky K <lucky@maintainer.example.org>

Cách thực hành này đặc biệt hữu ích nếu bạn duy trì một nhánh ổn định và
muốn đồng thời ghi nhận tác giả, theo dõi các thay đổi, hợp nhất bản sửa lỗi,
và bảo vệ người gửi khỏi bị khiếu nại. Lưu ý rằng trong mọi trường hợp
bạn có thể thay đổi danh tính của tác giả (tiêu đề Từ) không, vì đó là danh tính
xuất hiện trong nhật ký thay đổi.

Lưu ý đặc biệt dành cho người khuân vác: Đây dường như là một cách làm phổ biến và hữu ích
để chèn dấu hiệu về nguồn gốc của bản vá ở đầu cam kết
tin nhắn (ngay sau dòng chủ đề) để tiện theo dõi. Ví dụ,
đây là những gì chúng ta thấy trong bản phát hành ổn định 3.x::

Ngày: Thứ ba ngày 7 tháng 10 07:26:38 2014 -0400

libata: Hủy phá vỡ danh sách đen ATA

cam kết 1c40279960bcd7d52dbdf1d466b20d24b99176c8 ngược dòng.

Và đây là những gì có thể xuất hiện trong kernel cũ hơn sau khi bản vá được backport::

Ngày: Thứ ba ngày 13 tháng 5 22:12:27 2008 +0200

không dây, airo: waitbusy() sẽ không bị trì hoãn

[backport của 2.6 cam kết b7acbdfbd1f277c1eb23f344f899cfa4cd0bf36a]

Dù ở dạng nào thì thông tin này cũng mang lại sự trợ giúp có giá trị cho mọi người
theo dõi cây của bạn và những người đang cố gắng khắc phục lỗi trong
cây.
