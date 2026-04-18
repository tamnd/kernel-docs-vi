.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/zynqmp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

====================================================
Hệ thống con Xilinx ZynqMP Ultrascale+ DisplayPort
===============================================

Hệ thống con này xử lý đầu ra âm thanh và video DisplayPort trên ZynqMP. Nó
hỗ trợ bộ đệm khung trong bộ nhớ với bộ điều khiển DisplayPort DMA
(xilinx-dpdma), cũng như video và âm thanh "trực tiếp" từ logic lập trình
(PL). Hệ thống con này có thể thực hiện một số phép biến đổi, bao gồm cả không gian màu
chuyển đổi, trộn alpha và trộn âm thanh, mặc dù không phải tất cả các tính năng đều
hiện được hỗ trợ.

gỡ lỗi
-------

Để hỗ trợ kiểm tra việc gỡ lỗi và tuân thủ, một số chế độ kiểm tra có thể được bật
mặc dù debugfs. Các tệp sau trong /sys/kernel/debug/dri/X/DP-1/test/
kiểm soát các chế độ kiểm tra DisplayPort:

hoạt động:
        Viết số 1 vào tệp này sẽ kích hoạt chế độ kiểm tra và viết số 0 sẽ
        tắt chế độ kiểm tra. Viết số 1 hoặc 0 khi đã có chế độ kiểm tra
        hoạt động/không hoạt động sẽ kích hoạt lại/tắt lại chế độ kiểm tra. Khi kiểm tra
        chế độ không hoạt động, những thay đổi được thực hiện đối với các tệp khác sẽ không có (ngay lập tức)
        có hiệu lực, mặc dù các cài đặt sẽ được lưu khi chế độ kiểm tra được bật
        được kích hoạt. Khi chế độ kiểm tra được kích hoạt, những thay đổi được thực hiện đối với các tệp khác sẽ
        áp dụng ngay lập tức.

tùy chỉnh:
        Giá trị mẫu thử nghiệm tùy chỉnh

giảm dần:
        Bật/tắt tính năng giảm trải rộng đồng hồ (đồng hồ trải phổ) bằng cách
        viết 1/0

nâng cao:
        Bật/tắt tính năng đóng khung nâng cao

bỏ qua_aux_errors:
        Bỏ qua các lỗi AUX khi được đặt thành 1. Việc ghi vào tệp này có hiệu lực
        ngay lập tức (bất kể chế độ kiểm tra có hoạt động hay không) và ảnh hưởng đến tất cả
        Chuyển khoản AUX.

bỏ qua_hpd:
        Bỏ qua các sự kiện cắm nóng (chẳng hạn như tháo cáp hoặc liên kết màn hình
        yêu cầu đào tạo lại) khi được đặt thành 1. Việc ghi vào tệp này có hiệu lực
        ngay lập tức (bất kể chế độ kiểm tra có hoạt động hay không).

làn đườngX_preemphasis:
        Nhấn mạnh từ 0 (thấp nhất) đến 2 (cao nhất) cho làn X

làn đườngX_swing:
        Điện áp dao động từ 0 (thấp nhất) đến 3 (cao nhất) cho làn X

làn đường:
        Số làn đường sử dụng (1, 2 hoặc 4)

mẫu:
        Mẫu thử nghiệm. Có thể là một trong:

video
                        Sử dụng đầu vào video thông thường

lỗi biểu tượng
                        Mẫu đo lỗi ký hiệu

pbs7
                        Đầu ra của đa thức PRBS7 (x^7 + x^6 + 1)

tùy chỉnh 80bit
                        Mẫu 80 bit tùy chỉnh

cp2520
                        Mẫu mắt tuân thủ HBR2

tps1
                        Mẫu biểu tượng đào tạo liên kết TPS1 (/D10.2/)

tps2
                        Mẫu biểu tượng đào tạo liên kết TPS2

tps3
                        Mẫu biểu tượng đào tạo liên kết TPS3 (dành cho HBR2)

tỷ lệ:
        Tỷ lệ tính bằng hertz. Một trong

* 5400000000 (HBR2)
                * 2700000000 (HBR)
                * 1620000000 (RBR)

Bạn có thể kết xuất cài đặt kiểm tra cổng hiển thị bằng lệnh sau ::

cho prop trong /sys/kernel/debug/dri/1/DP-1/test/*; làm
                printf '%-17s ' ${prop##*/}
                if [ ${prop##*/} = tùy chỉnh ]; sau đó
                        hexdump -C $prop | đầu -1
                khác
                        mèo $prop
                fi
        xong

Đầu ra có thể trông giống như::

hoạt động 1
        tùy chỉnh 00000000 00 00 00 00 00 00 00 00 00 00 ZZ0000ZZ
        giảm giá 0
        tăng cường 1
        bỏ qua_aux_errors 1
        bỏ qua_hpd 1
        làn đường0_preemphasis 0
        ngõ0_swing 3
        ngõ1_preemphasis 0
        ngõ1_swing 3
        làn đường 2
        mẫu prbs7
        tỷ lệ 1620000000

Quy trình kiểm tra được khuyến nghị là kết nối bo mạch với màn hình,
định cấu hình chế độ kiểm tra, kích hoạt chế độ kiểm tra và sau đó ngắt kết nối cáp
và kết nối nó với thiết bị kiểm tra mà bạn lựa chọn. Ví dụ, một
chuỗi lệnh có thể là::

echo 1 > /sys/kernel/debug/dri/1/DP-1/test/nâng cao
        echo tps1 > /sys/kernel/debug/dri/1/DP-1/test/pattern
        echo 1620000000 > /sys/kernel/debug/dri/1/DP-1/test/rate
        echo 1 > /sys/kernel/debug/dri/1/DP-1/test/ignore_aux_errors
        echo 1 > /sys/kernel/debug/dri/1/DP-1/test/ignore_hpd
        echo 1 > /sys/kernel/debug/dri/1/DP-1/test/active

tại thời điểm đó cáp có thể bị ngắt kết nối khỏi màn hình.

Nội bộ
---------

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_disp.h

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_dpsub.h

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_kms.h

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_disp.c

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_dp.c

.. kernel-doc:: drivers/gpu/drm/xlnx/zynqmp_kms.c