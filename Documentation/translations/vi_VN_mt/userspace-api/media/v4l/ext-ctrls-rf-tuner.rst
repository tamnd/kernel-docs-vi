.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/ext-ctrls-rf-tuner.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _rf-tuner-controls:

***********************************
Tham chiếu điều khiển bộ dò sóng RF
***********************************

Lớp Bộ điều chỉnh RF (RF_TUNER) bao gồm các điều khiển cho các tính năng chung của
các thiết bị có bộ thu sóng RF.

Trong bối cảnh này, bộ thu sóng RF là mạch thu sóng vô tuyến giữa ăng-ten và
bộ giải điều chế. Nó nhận tần số vô tuyến (RF) từ ăng-ten và
chuyển đổi tín hiệu nhận được sang tần số trung gian thấp hơn (IF) hoặc
tần số băng cơ sở (BB). Các bộ điều chỉnh có thể thực hiện đầu ra băng cơ sở thường là
được gọi là bộ điều chỉnh Zero-IF. Bộ chỉnh cũ hơn thường là bộ chỉnh PLL đơn giản
bên trong một hộp kim loại, trong khi những cái mới hơn là những con chip tích hợp cao
không có hộp kim loại "bộ điều chỉnh silicon". Các biện pháp kiểm soát này chủ yếu
áp dụng cho các bộ điều chỉnh silicon giàu tính năng mới, chỉ vì cũ hơn
bộ chỉnh không có nhiều tính năng điều chỉnh.

Để biết thêm thông tin về bộ điều chỉnh RF, hãy xem
ZZ0000ZZ
và ZZ0001ZZ
từ Wikipedia.


.. _rf-tuner-control-id:

ID điều khiển RF_TUNER
====================

ZZ0001ZZ
    Bộ mô tả lớp RF_TUNER. Đang gọi
    ZZ0000ZZ cho điều khiển này sẽ
    trả về mô tả của lớp điều khiển này.

ZZ0000ZZ
    Bật/tắt cấu hình băng thông kênh radio của bộ điều chỉnh. trong
    cấu hình băng thông ở chế độ tự động được thực hiện bởi trình điều khiển.

ZZ0000ZZ
    (Các) bộ lọc trên đường dẫn tín hiệu của bộ điều chỉnh được sử dụng để lọc tín hiệu theo
    đáp ứng nhu cầu của bên nhận. Trình điều khiển cấu hình các bộ lọc để đáp ứng
    yêu cầu băng thông mong muốn. Được sử dụng khi
    V4L2_CID_RF_TUNER_BANDWIDTH_AUTO chưa được đặt. Đơn vị tính bằng Hz. các
    phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Bật/tắt điều khiển khuếch đại tự động LNA (AGC)

ZZ0000ZZ
    Bật/tắt điều khiển khuếch đại tự động của bộ trộn (AGC)

ZZ0000ZZ
    Bật/tắt điều khiển khuếch đại tự động IF (AGC)

ZZ0000ZZ
    Bộ khuếch đại RF là bộ khuếch đại đầu tiên trên tín hiệu máy thu
    đường dẫn, ngay sau đầu vào ăng-ten. Sự khác biệt giữa
    Độ lợi LNA và độ lợi RF trong tài liệu này là độ lợi LNA là
    được tích hợp trong chip điều chỉnh trong khi mức tăng RF là một chip riêng biệt.
    Có thể có cả điều khiển khuếch đại RF và LNA trong cùng một thiết bị. các
    phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Khuếch đại LNA (bộ khuếch đại nhiễu thấp) là giai đoạn khuếch đại đầu tiên trên bộ điều chỉnh RF
    đường dẫn tín hiệu. Nó nằm rất gần với đầu vào ăng-ten của bộ điều chỉnh. đã qua sử dụng
    khi ZZ0001ZZ chưa được đặt. Xem
    ZZ0002ZZ để hiểu mức tăng RF và mức tăng LNA
    khác nhau. Phạm vi và bước là
    dành riêng cho người lái xe.

ZZ0000ZZ
    Độ lợi của bộ trộn là giai đoạn khuếch đại thứ hai trên đường dẫn tín hiệu của bộ điều chỉnh RF. Đó là
    nằm bên trong khối trộn, nơi tín hiệu RF được chuyển đổi xuống bởi
    máy trộn. Được sử dụng khi ZZ0001ZZ chưa được thiết lập.
    Phạm vi và bước là dành riêng cho người lái xe.

ZZ0000ZZ
    Mức tăng IF là giai đoạn khuếch đại cuối cùng trên đường dẫn tín hiệu của bộ điều chỉnh RF. Đó là
    nằm ở đầu ra của bộ chỉnh tần RF. Nó điều khiển mức tín hiệu của
    đầu ra tần số trung gian hoặc đầu ra băng cơ sở. Được sử dụng khi
    ZZ0001ZZ chưa được đặt. Phạm vi và bước
    dành riêng cho người lái xe.

ZZ0000ZZ
    Bộ tổng hợp PLL có bị khóa không? Bộ dò RF đang nhận tần số nhất định
    khi điều khiển đó được thiết lập. Đây là điều khiển chỉ đọc.