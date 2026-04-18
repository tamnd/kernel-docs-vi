.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/trace/coresight/coresight-tpda.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=======================================================================
Bộ tổng hợp chẩn đoán và giám sát hiệu suất theo dõi (TPDA)
=================================================================

:Tác giả: Jinlong Mao <quic_jinlmao@quicinc.com>
    :Ngày: Tháng 1 năm 2023

Mô tả phần cứng
--------------------

TPDA - Bộ tổng hợp chẩn đoán và giám sát hiệu suất theo dõi hoặc
Nói tóm lại, TPDA đóng vai trò là công cụ phân xử và đóng gói cho
đặc điểm kỹ thuật mạng chẩn đoán và giám sát hiệu suất.
Trường hợp sử dụng chính của TPDA là cung cấp khả năng đóng gói, phân kênh
và đánh dấu thời gian của dữ liệu Giám sát.


Các tập tin và thư mục Sysfs
---------------------------
Gốc: ZZ0000ZZ

Chi tiết cấu hình
---------------------------

Các nút tpdm và tpda phải được quan sát tại đường dẫn coresight
"/sys/bus/coresight/thiết bị".
ví dụ.
/sys/bus/coresight/thiết bị # ls -l | grep tpd
tpda0 -> ../../../devices/platform/soc@0/6004000.tpda/tpda0
tpdm0 -> ../../../devices/platform/soc@0/6c08000.mm.tpdm/tpdm0

Chúng ta có thể sử dụng các lệnh tương tự như bên dưới để xác thực TPDM.
Trước tiên hãy bật phần chìm coresight. Cổng tpda được kết nối với
tpdm sẽ được kích hoạt sau các lệnh bên dưới.

echo 1 > /sys/bus/coresight/devices/tmc_etf0/enable_sink
echo 1 > /sys/bus/coresight/devices/tpdm0/enable_source
echo 1 > /sys/bus/coresight/devices/tpdm0/integration_test
echo 2 > /sys/bus/coresight/devices/tpdm0/integration_test

Dữ liệu thử nghiệm sẽ được thu thập trong coresight sink được kích hoạt.
Nếu thanh ghi rwp của bồn rửa liên tục cập nhật khi thực hiện
Integration_test (bởi cat tmc_etf0/mgmt/rwp), nghĩa là có dữ liệu
được tạo ra từ TPDM để chìm.

Phải có một tpda giữa tpdm và sink. Khi có một số
các thành phần hw sự kiện theo dõi khác trong cùng khối CTNH với tpdm, tpdm
và các thành phần hw này sẽ kết nối với kênh coresight. Khi nào
chỉ có dấu vết tpdm hw trong khối CTNH, tpdm sẽ kết nối với
tpda trực tiếp.