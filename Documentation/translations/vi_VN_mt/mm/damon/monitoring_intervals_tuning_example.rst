.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/mm/damon/monitoring_intervals_tuning_example.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================================
Ví dụ về điều chỉnh tham số khoảng thời gian theo dõi DAMON
=================================================

Các thông số giám sát của DAMON cần được điều chỉnh dựa trên khối lượng công việc nhất định và
mục đích giám sát.  Có ZZ0000ZZ cho điều đó.  Tài liệu này
cung cấp một ví dụ điều chỉnh dựa trên hướng dẫn.

Cài đặt
=====

Ví dụ bên dưới, DAMON của nhân Linux v6.11 và ZZ0000ZZ (công cụ không gian người dùng DAMON) v2.5.9 đã được sử dụng để
giám sát và trực quan hóa các mẫu truy cập trên không gian địa chỉ vật lý của hệ thống
chạy khối lượng công việc của máy chủ trong thế giới thực.

Khoảng thời gian 5ms/100ms: Khoảng thời gian quá ngắn
=======================================

Hãy bắt đầu bằng cách chụp ảnh chụp nhanh mẫu truy cập trên địa chỉ vật lý
không gian của hệ thống sử dụng DAMON, với các tham số khoảng mặc định (5
mili giây và 100 mili giây để lấy mẫu và tổng hợp
các khoảng tương ứng).  Đợi mười phút từ lúc bắt đầu DAMON đến
việc chụp ảnh chụp nhanh, để hiển thị các mẫu truy cập có ý nghĩa theo thời gian.
::

# damo bắt đầu
    # sleep 600
    Bản ghi # damo --ảnh chụp nhanh 0 1
    Dừng # damo

Sau đó, liệt kê các vùng DAMON có các mẫu truy cập khác nhau được tìm thấy, được sắp xếp theo
"nhiệt độ truy cập".  "Nhiệt độ truy cập" là số liệu đại diện cho
mức độ truy cập nóng của một khu vực.  Nó được tính bằng tổng trọng số của quyền truy cập
tần suất và tuổi của khu vực.  Nếu tần số truy cập là 0 % thì
nhiệt độ được nhân với âm một.  Nghĩa là, nếu một khu vực không được truy cập,
nhiệt độ sẽ âm và nhiệt độ sẽ thấp hơn do không được truy cập trong thời gian dài hơn.
Việc sắp xếp theo thứ tự tăng dần nhiệt độ, do đó vùng ở trên cùng của
danh sách là lạnh nhất và danh sách ở dưới cùng là danh sách nóng nhất. ::

Truy cập báo cáo # damo --sort_khu vực_theo nhiệt độ
    0 addr 16.052 GiB kích thước 5.985 GiB truy cập 0 % tuổi 5.900 s # coldest
    1 addr 22.037 GiB kích thước 6.029 GiB truy cập 0 % tuổi 5.300 s
    2 addr 28.065 GiB kích thước 6.045 GiB truy cập 0 % tuổi 5.200 s
    3 addr 10.069 GiB kích thước 5.983 GiB truy cập 0 % tuổi 4.500 s
    4 addr 4.000 GiB kích thước 6.069 GiB truy cập 0 % tuổi 4.400 s
    5 addr 62.008 GiB kích thước 3.992 GiB truy cập 0 % tuổi 3.700 s
    6 addr 56,795 GiB kích thước 5,213 GiB truy cập 0 % tuổi 3,300 s
    7 addr 39.393 GiB size 6.096 GiB truy cập 0 % tuổi 2.800 s
    8 addr 50,782 GiB kích thước 6,012 GiB truy cập 0 % tuổi 2,800 s
    9 addr 34.111 Kích thước GiB 5.282 Truy cập GiB 0 % tuổi 2.300 s
    10 addr 45.489 GiB kích thước 5.293 GiB truy cập 0 % tuổi 1.800 s # hottest
    tổng kích thước: 62.000 GiB

Danh sách hiển thị các khu vực có vẻ không nóng và chỉ hiển thị mẫu truy cập tối thiểu
sự đa dạng.  Mọi vùng đều có tần số truy cập bằng 0.  Số vùng là
10, đây là ZZ0000ZZ mặc định.  Kích thước của từng khu vực cũng
gần giống nhau.  Chúng ta có thể nghi ngờ điều này là do “điều chỉnh vùng thích ứng”
cơ chế hoạt động không tốt.  Theo hướng dẫn gợi ý, chúng ta có thể nhận được tương đối
độ nóng của các vùng sử dụng ZZ0001ZZ làm thông tin gần đây.  Đó sẽ là
còn hơn không, nhưng thực tế là tuổi thọ lâu nhất chỉ khoảng 6
giây trong khi chúng tôi đợi khoảng mười phút, không rõ điều này sẽ hữu ích như thế nào
được.

Phạm vi nhiệt độ theo tổng kích thước của các vùng của từng biểu đồ phạm vi
trực quan hóa kết quả cũng không cho thấy mô hình phân phối thú vị nào. ::

Truy cập báo cáo # damo --style nhiệt độ-sz-hist
    <nhiệt độ> <tổng kích thước>
    [-,590.000.000, -,549.000.000) 5,985 GiB ZZ0000ZZ
    [-,549.000.000, -,508.000.000) 12.074 GiB ZZ0001ZZ
    [-,508.000.000, -,467.000.000) 0 B ZZ0002ZZ
    [-,467.000.000, -,426.000.000) 12.052 GiB ZZ0003ZZ
    [-,426.000.000, -,385.000.000) 0 B ZZ0004ZZ
    [-,385.000.000, -,344.000.000) 3,992 GiB ZZ0005ZZ
    [-,344.000.000, -,303.000.000) 5.213 GiB ZZ0006ZZ
    [-,303.000.000, -,262.000.000) 12.109 GiB ZZ0007ZZ
    [-,262.000.000, -,221.000.000) 5,282 GiB ZZ0008ZZ
    [-,221.000.000, -,180.000.000) 0 B ZZ0009ZZ
    [-,180.000.000, -,139.000.000) 5,293 GiB ZZ0010ZZ
    tổng kích thước: 62.000 GiB

Nói tóm lại, các thông số cung cấp kết quả giám sát chất lượng kém đối với tình trạng nóng.
phát hiện khu vực. Theo ZZ0000ZZ, điều này là do thời gian quá ngắn
khoảng tổng hợp.

Khoảng thời gian 100ms/2s: Bắt đầu hiển thị các vùng nóng nhỏ
====================================================

Làm theo hướng dẫn, tăng khoảng thời gian lên 20 lần (100 mili giây và 2
giây cho khoảng thời gian lấy mẫu và tổng hợp tương ứng). ::

# damo bắt đầu -s 100ms -a 2s
    # sleep 600
    Bản ghi # damo --ảnh chụp nhanh 0 1
    Dừng # damo
    Truy cập báo cáo # damo --sort_khu vực_theo nhiệt độ
    0 addr 10.180 GiB kích thước 6.117 GiB truy cập 0 % tuổi 7 m 8 s # coldest
    1 addr 49,275 GiB kích thước 6,195 GiB truy cập 0 % tuổi 6 tháng 14 giây
    2 addr 62.421 GiB size 3.579 GiB truy cập 0 % tuổi 6 m 4 s
    3 addr 40.154 GiB size 6.127 GiB truy cập 0 % tuổi 5 m 40 s
    4 addr 16.296 GiB size 6.182 GiB truy cập 0 % tuổi 5 m 32 s
    5 addr 34.254 GiB size 5.899 GiB truy cập 0 % tuổi 5 m 24 s
    6 addr 46.281 GiB size 2.995 GiB truy cập 0 % tuổi 5 tháng 20 giây
    7 addr 28.420 GiB size 5.835 GiB truy cập 0 % tuổi 5 m 6 s
    8 addr 4.000 GiB kích thước 6.180 GiB truy cập 0 % tuổi 4 m 16 s
    9 addr 22.478 GiB size 5.942 GiB truy cập 0 % tuổi 3 m 58 s
    10 addr 55.470 GiB size 915.645 MiB truy cập 0 % tuổi 3 m 6 s
    11 addr 56.364 GiB size 6.056 GiB truy cập 0 % tuổi 2 m 8 s
    12 addr 56.364 GiB size 4.000 KiB truy cập 95 % tuổi 16 s
    13 addr 49.275 GiB size 4.000 KiB truy cập 100 % tuổi 8 m 24 s # hottest
    tổng kích thước: 62.000 GiB
    Truy cập báo cáo # damo --style nhiệt độ-sz-hist
    <nhiệt độ> <tổng kích thước>
    [-42.800.000.000, -33.479.999.000) 22.018 GiB ZZ0000ZZ
    [-33,479,999,000, -24,159,998,000) 27.090 GiB ZZ0001ZZ
    [-24.159.998.000, -14.839.997.000) 6.836 GiB ZZ0002ZZ
    [-14.839.997.000, -5.519.996.000) 6.056 GiB ZZ0003ZZ
    [-5.519.996.000, 3.800.005.000) 4.000 KiB ZZ0004ZZ
    [3.800.005.000, 13.120.006.000) 0 B ZZ0005ZZ
    [13.120.006.000, 22.440.007.000) 0 B ZZ0006ZZ
    [22.440.007.000, 31.760.008.000) 0 B ZZ0007ZZ
    [31.760.008.000, 41.080.009.000) 0 B ZZ0008ZZ
    [41.080.009.000, 50.400.010.000) 0 B ZZ0009ZZ
    [50.400.010.000, 59.720.011.000) 4.000 KiB ZZ0010ZZ
    tổng kích thước: 62.000 GiB

DAMON tìm thấy hai vùng 4 KiB riêng biệt khá nóng.  Các vùng cũng
cũng già rồi.  Vùng 4 KiB nóng nhất đang giữ tần số truy cập trong khoảng
8 phút và vùng lạnh nhất không thể truy cập được trong khoảng 7 phút.
Sự phân bố trên biểu đồ cũng giống như có một mẫu.

Đặc biệt việc tìm ra 4 vùng KiB trong tổng bộ nhớ 62 GiB
cho thấy điều chỉnh vùng thích ứng của DAMON đang hoạt động như thiết kế.

Tuy nhiên, số lượng vùng vẫn gần bằng ZZ0000ZZ và kích thước của
Tuy nhiên, vùng lạnh cũng tương tự.  Rõ ràng nó đã được cải thiện, nhưng nó vẫn có
phòng để cải thiện.

Khoảng thời gian 400ms/8 giây: Kết quả được cải thiện khá
===========================================

Tăng khoảng thời gian bốn lần (400 mili giây và 8 giây
tương ứng cho khoảng thời gian lấy mẫu và tổng hợp). ::

# damo bắt đầu -s 400ms -a 8s
    # sleep 600
    Bản ghi # damo --ảnh chụp nhanh 0 1
    Dừng # damo
    Truy cập báo cáo # damo --sort_khu vực_theo nhiệt độ
    0 addr 64.492 GiB kích thước 1.508 GiB truy cập 0 % tuổi 6 m 48 s # coldest
    1 địa chỉ 21.749 GiB kích thước 5.674 GiB truy cập 0 % tuổi 6 tháng 8 giây
    2 addr 27.422 GiB kích thước 5.801 GiB truy cập 0 % tuổi 6 m
    3 addr 49.431 GiB size 8.675 GiB truy cập 0 % tuổi 5 m 28 s
    4 addr 33.223 GiB size 5.645 GiB truy cập 0 % tuổi 5 m 12 s
    5 addr 58.321 GiB kích thước 6.170 GiB truy cập 0 % tuổi 5 m 4 s
    […]
    25 addr 6.615 GiB kích thước 297.531 MiB truy cập 15 % tuổi 0 ns
    26 addr 9.513 GiB size 12.000 KiB truy cập 20 % tuổi 0 ns
    27 addr 9.511 GiB kích thước 108.000 KiB truy cập 25 % tuổi 0 ns
    28 addr 9.513 GiB kích thước 20.000 KiB truy cập 25 % tuổi 0 ns
    29 addr 9.511 GiB kích thước 12.000 KiB truy cập 30 % tuổi 0 ns
    30 addr 9.520 GiB kích thước 4.000 KiB truy cập 40 % tuổi 0 ns
    […]
    41 addr 9.520 GiB kích thước 4.000 KiB truy cập 80 % tuổi 56 s
    42 addr 9.511 GiB size 12.000 KiB truy cập 100 % tuổi 6 m 16 s
    43 addr 58.321 GiB size 4.000 KiB truy cập 100 % tuổi 6 m 24 s
    44 addr 9.512 GiB size 4.000 KiB truy cập 100 % tuổi 6 m 48 s
    45 addr 58.106 GiB kích thước 4.000 KiB truy cập 100 % tuổi 6 m 48 s # hottest
    tổng kích thước: 62.000 GiB
    Truy cập báo cáo # damo --style nhiệt độ-sz-hist
    <nhiệt độ> <tổng kích thước>
    [-40.800.000.000, -32.639.999.000) 21.657 GiB ZZ0000ZZ
    [-32.639.999.000, -24.479.998.000) 17.938 GiB ZZ0001ZZ
    [-24,479,998,000, -16,319,997,000) 16.885 GiB ZZ0002ZZ
    [-16.319.997.000, -8.159.996.000) 586.879 MiB ZZ0003ZZ
    [-8.159.996.000, 5.000) 4.946 GiB ZZ0004ZZ
    [5.000, 8.160.006.000) 260.000 KiB ZZ0005ZZ
    [8.160.006.000, 16.320.007.000) 0 B ZZ0006ZZ
    [16.320.007.000, 24.480.008.000) 0 B ZZ0007ZZ
    [24.480.008.000, 32.640.009.000) 0 B ZZ0008ZZ
    [32.640.009.000, 40.800.010.000) 16.000 KiB ZZ0009ZZ
    [40.800.010.000, 48.960.011.000) 8.000 KiB ZZ0010ZZ
    tổng kích thước: 62.000 GiB

Số vùng có các kiểu truy cập khác nhau đã giảm đáng kể
tăng lên.  Kích thước của mỗi vùng cũng đa dạng hơn. Tổng kích thước khác không
vùng tần số truy cập cũng được tăng lên đáng kể. Có lẽ điều này đã rồi
đủ tốt để thực hiện một số thay đổi có ý nghĩa về hiệu quả quản lý bộ nhớ.

Khoảng thời gian 800ms/16s: Một sai lệch khác
=================================

Tăng gấp đôi khoảng thời gian (800 mili giây và 16 giây để lấy mẫu
và các khoảng tổng hợp tương ứng).  Kết quả được cải thiện nhiều hơn đối với
phát hiện vùng nóng, nhưng bắt đầu tìm kiếm phát hiện vùng lạnh xuống cấp. ::

# damo bắt đầu -s 800ms -a 16s
    # sleep 600
    Bản ghi # damo --ảnh chụp nhanh 0 1
    Dừng # damo
    Truy cập báo cáo # damo --sort_khu vực_theo nhiệt độ
    0 addr 64.781 GiB size 1.219 GiB truy cập 0 % tuổi 4 m 48 s
    1 addr 24.505 GiB size 2.475 GiB truy cập 0 % tuổi 4 m 16 s
    2 addr 26.980 GiB size 504.273 MiB truy cập 0 % tuổi 4 m
    3 addr 29.443 GiB kích thước 2.462 GiB truy cập 0 % tuổi 4 m
    4 addr 37.264 GiB kích thước 5.645 GiB truy cập 0 % tuổi 4 m
    5 addr 31.905 GiB size 5.359 GiB truy cập 0 % tuổi 3 m 44 s
    […]
    20 addr 8.711 GiB size 40.000 KiB truy cập 5 % tuổi 2 m 40 s
    21 addr 27.473 GiB kích thước 1.970 GiB truy cập 5 % tuổi 4 m
    22 addr 48.185 GiB kích thước 4.625 GiB truy cập 5 % tuổi 4 m
    23 addr 47.304 GiB size 902.117 MiB truy cập 10 % tuổi 4 m
    24 addr 8.711 GiB size 4.000 KiB truy cập 100 % tuổi 4 m
    25 addr 20,793 GiB size 3,713 GiB truy cập 5 % tuổi 4 m 16 s
    26 addr 8.773 GiB size 4.000 KiB truy cập 100 % tuổi 4 m 16 s
    tổng kích thước: 62.000 GiB
    Truy cập báo cáo # damo --style nhiệt độ-sz-hist
    <nhiệt độ> <tổng kích thước>
    [-28.800.000.000, -23.359.999.000) 12.294 GiB ZZ0000ZZ
    [-23,359,999,000, -17,919,998,000) 9.753 GiB ZZ0001ZZ
    [-17.919.998.000, -12.479.997.000) 15.131 GiB ZZ0002ZZ
    [-12,479,997,000, -7,039,996,000) 0 B ZZ0003ZZ
    [-7.039.996.000, -1.599.995.000) 7.506 GiB ZZ0004ZZ
    [-1.599.995.000, 3.840.006.000) 6.127 GiB ZZ0005ZZ
    [3,840,006,000, 9,280,007,000) 0 B ZZ0006ZZ
    [9.280.007.000, 14.720.008.000) 136.000 KiB ZZ0007ZZ
    [14.720.008.000, 20.160.009.000) 40.000 KiB ZZ0008ZZ
    [20.160.009.000, 25.600.010.000) 11.188 GiB ZZ0009ZZ
    [25.600.010.000, 31.040.011.000) 4.000 KiB ZZ0010ZZ
    tổng kích thước: 62.000 GiB

Nó tìm thấy nhiều vùng tần số truy cập khác 0. Số vùng vẫn còn
cao hơn nhiều so với ZZ0000ZZ, nhưng nó giảm so với ZZ0000ZZ
thiết lập trước đó. Và rõ ràng sự phân bổ có vẻ hơi thiên về nóng
các vùng.

Phần kết luận
==========

Với kết quả điều chỉnh thực nghiệm ở trên, chúng ta có thể kết luận lý thuyết và
hướng dẫn ít nhất có ý nghĩa đối với khối lượng công việc này và có thể được áp dụng cho các công việc tương tự
trường hợp.