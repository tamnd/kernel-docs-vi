.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-soc-clean-dts.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================================================
Nền tảng SoC với các yêu cầu tuân thủ DTS
==============================================

Tổng quan
--------

Nền tảng SoC hoặc kiến trúc phụ phải tuân theo tất cả các quy tắc từ
Tài liệu/quy trình/bảo trì-soc.rst.  Tài liệu này được tham chiếu trong
MAINTAINERS áp đặt các yêu cầu bổ sung được liệt kê bên dưới.

Tuân thủ nghiêm ngặt Lược đồ DT DTS và dtc
---------------------------------------

Không có thay đổi nào đối với nguồn Devicetree nền tảng SoC (tệp DTS) sẽ được giới thiệu
cảnh báo ZZ0000ZZ mới.  Cảnh báo trong bảng DTS mới, đó là
kết quả của các vấn đề trong tệp DTSI đi kèm, được coi là hiện có, không phải mới
cảnh báo.  Để phân chia chuỗi giữa các cây khác nhau (liên kết DT đi qua trình điều khiển
cây hệ thống con), cảnh báo trên linux-next có tính chất quyết định.  Những người duy trì nền tảng
có tự động hóa tại chỗ để chỉ ra bất kỳ cảnh báo mới nào.

Nếu một cam kết giới thiệu các cảnh báo mới được chấp nhận bằng cách nào đó, kết quả
các vấn đề sẽ được khắc phục trong thời gian hợp lý (ví dụ: trong một lần phát hành) hoặc
cam kết hoàn nguyên.