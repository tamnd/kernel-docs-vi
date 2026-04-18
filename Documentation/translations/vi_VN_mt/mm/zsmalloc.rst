.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/mm/zsmalloc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========
zsmalloc
========

Bộ cấp phát này được thiết kế để sử dụng với zram. Vì vậy, người cấp phát là
được cho là hoạt động tốt trong điều kiện bộ nhớ thấp. Đặc biệt, nó
không bao giờ cố gắng phân bổ trang có thứ tự cao hơn, điều này rất có thể xảy ra
thất bại dưới áp lực bộ nhớ. Mặt khác, nếu chúng ta chỉ sử dụng một
(0-thứ tự), nó sẽ bị phân mảnh rất cao --
bất kỳ đối tượng nào có kích thước PAGE_SIZE/2 hoặc lớn hơn sẽ chiếm toàn bộ trang.
Đây là một trong những vấn đề lớn với phiên bản tiền nhiệm của nó (xvmalloc).

Để khắc phục những vấn đề này, zsmalloc phân bổ một loạt các trang có 0 đơn hàng
và liên kết chúng với nhau bằng cách sử dụng các trường 'trang cấu trúc' khác nhau. Những liên kết này
các trang hoạt động như một trang có thứ tự cao hơn, tức là một đối tượng có thể trải rộng theo thứ tự 0
ranh giới trang. Mã đề cập đến các trang được liên kết này dưới dạng một thực thể duy nhất
được gọi là zspage.

Để đơn giản, zsmalloc chỉ có thể phân bổ các đối tượng có kích thước tối đa PAGE_SIZE
vì điều này đáp ứng yêu cầu của tất cả người dùng hiện tại của nó (trong
trường hợp xấu nhất, trang không thể nén được và do đó được lưu trữ "nguyên trạng", tức là trong
dạng không nén). Đối với các yêu cầu phân bổ lớn hơn kích thước này, lỗi
được trả về (xem zs_malloc).

Ngoài ra, zs_malloc() không trả về một con trỏ không thể tham chiếu.
Thay vào đó, nó trả về một thẻ điều khiển mờ (dài không dấu) mã hóa giá trị thực
vị trí của đối tượng được phân bổ. Sở dĩ có sự gián tiếp này là do
zsmalloc không giữ các trang zspage được ánh xạ vĩnh viễn vì điều đó sẽ gây ra
sự cố trên hệ thống 32 bit trong đó vùng VA dành cho ánh xạ không gian hạt nhân
là rất nhỏ. Vì vậy, việc sử dụng bộ nhớ được cấp phát phải được thực hiện thông qua
API dựa trên tay cầm thích hợp.

chỉ số
======

Với CONFIG_ZSMALLOC_STAT, chúng ta có thể xem thông tin nội bộ của zsmalloc thông qua
ZZ0000ZZ. Đây là một mẫu đầu ra stat ::

# cat/sys/kernel/debug/zsmalloc/zram0/classes

quy mô lớp 10% 20% 30% 40% 50% 60% 70% 80% 90% 99% 100% obj_allocated obj_used pages_used pages_per_zspage freeable
    ...
    ...
30 512 0 12 4 1 0 1 0 0 1 0 414 3464 3346 433 1 14
    31 528 2 7 2 2 1 0 1 0 0 2 117 4154 3793 536 4 44
    32 544 6 3 4 1 2 1 0 0 0 1 260 4170 3965 556 2 26
    ...
    ...


lớp học
	chỉ mục
kích thước
	kích thước đối tượng
10%
	số lượng zspage có tỷ lệ sử dụng nhỏ hơn 10% (xem bên dưới)
20%
	số lượng zspage có tỷ lệ sử dụng từ 10% đến 20%
30%
	số lượng zspage có tỷ lệ sử dụng từ 20% đến 30%
40%
	số lượng zspage có tỷ lệ sử dụng từ 30% đến 40%
50%
	số lượng zspage có tỷ lệ sử dụng từ 40% đến 50%
60%
	số lượng zspage có tỷ lệ sử dụng từ 50% đến 60%
70%
	số lượng zspage có tỷ lệ sử dụng từ 60% đến 70%
80%
	số lượng zspage có tỷ lệ sử dụng từ 70% đến 80%
90%
	số lượng zspage có tỷ lệ sử dụng từ 80% đến 90%
99%
	số lượng zspage có tỷ lệ sử dụng từ 90% đến 99%
100%
	số lượng trang zs với tỷ lệ sử dụng 100%
obj_allocated
	số lượng đối tượng được phân bổ
obj_use
	số lượng đối tượng được phân bổ cho người dùng
trang_sử dụng
	số trang được phân bổ cho lớp
trang_per_zspage
	số lượng trang 0 thứ tự để tạo thành một trang zspage
có thể tự do
	số trang gần đúng mà việc nén lớp có thể giải phóng

Mỗi zspage duy trì bộ đếm sử dụng để theo dõi số lượng
các đối tượng được lưu trữ trong zspage.  Bộ đếm inuse xác định zspage
"nhóm đầy đủ" được tính bằng tỷ lệ của các đối tượng "không sử dụng" với
tổng số đối tượng mà zspage có thể chứa (objs_per_zspage). các
càng gần bộ đếm sử dụng tới objs_per_zspage thì càng tốt.

Nội bộ
=========

zsmalloc có 255 lớp kích thước, mỗi lớp có thể chứa một số zspage.
Mỗi zspage có thể chứa tối đa các trang ZSMALLOC_CHAIN_SIZE vật lý (0 thứ tự).
Kích thước chuỗi zspage tối ưu cho từng loại kích thước được tính toán trong quá trình
tạo nhóm zsmalloc (xem tính toán_zspage_chain_size()).

Để tối ưu hóa, zsmalloc hợp nhất các lớp kích thước có
đặc điểm về số lượng trang trên mỗi zspage và số lượng
của các đối tượng mà mỗi zspage có thể lưu trữ.

Ví dụ: hãy xem xét các lớp kích thước sau:::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable
  ...
     94  1536        0    ....       0             0          0          0                3        0
    100  1632        0    ....       0             0          0          0                2        0
  ...


Các lớp kích thước #95-99 được hợp nhất với lớp kích thước #100. Điều này có nghĩa là khi chúng ta
cần lưu trữ một đối tượng có kích thước, chẳng hạn như 1568 byte, cuối cùng chúng ta sử dụng lớp kích thước
#100 thay vì lớp kích thước #96. Lớp kích thước #100 dành cho các đối tượng có kích thước
1632 byte, vì vậy mỗi đối tượng có kích thước 1568 byte sẽ lãng phí 1632-1568=64 byte.

Lớp kích thước #100 bao gồm các trang zs với mỗi trang có 2 trang vật lý, có thể
giữ tổng cộng 5 đối tượng. Nếu chúng ta cần lưu trữ 13 đối tượng có kích thước 1568, chúng ta
cuối cùng phân bổ ba trang zspage hoặc 6 trang vật lý.

Tuy nhiên, nếu chúng ta xem xét kỹ hơn về lớp kích thước #96 (dành cho
đối tượng có kích thước 1568 byte) và theo dõi ZZ0000ZZ, chúng tôi
thấy rằng cấu hình zspage tối ưu nhất cho lớp này là một chuỗi
trong số 5 trang vật lý:::

số trang trên mỗi zspage bị lãng phí byte%
           1 960 76
           2 352 95
           3 1312 89
           4 704 95
           5 96 99

Điều này có nghĩa là cấu hình lớp #96 với 5 trang vật lý có thể lưu trữ 13
các đối tượng có kích thước 1568 trong một trang zspage, sử dụng tổng cộng 5 trang vật lý.
Điều này hiệu quả hơn cấu hình lớp #100, sẽ sử dụng 6
các trang vật lý để lưu trữ cùng một số lượng đối tượng.

Khi kích thước chuỗi zspage cho lớp #96 tăng lên, các đặc điểm chính của nó
chẳng hạn như các trang trên mỗi zspage và các đối tượng trên mỗi zspage cũng thay đổi. Điều này dẫn đến
sáp nhập lớp Dewer, dẫn đến một nhóm các lớp nhỏ gọn hơn,
giảm lãng phí bộ nhớ.

Chúng ta hãy xem xét kỹ hơn phần dưới cùng của ZZ0000ZZ:::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable

  ...
    202  3264         0   ..         0             0          0          0                4        0
    254  4096         0   ..         0             0          0          0                1        0
  ...

Lớp kích thước #202 lưu trữ các đối tượng có kích thước 3264 byte và có tối đa 4 trang
mỗi zspage. Bất kỳ đối tượng nào lớn hơn 3264 byte đều được coi là lớn và thuộc về
để định cỡ lớp #254, lưu trữ từng đối tượng trong trang vật lý của chính nó (các đối tượng
trong các lớp học lớn không chia sẻ trang).

Việc tăng kích thước của chuỗi zspage cũng dẫn đến hình mờ cao hơn
dành cho lớp có quy mô lớn và ít lớp có quy mô lớn hơn về tổng thể. Điều này cho phép nhiều hơn
lưu trữ hiệu quả các đối tượng lớn.

Đối với kích thước chuỗi zspage là 8, hình mờ lớp lớn sẽ trở thành 3632 byte :::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable

  ...
    202  3264         0   ..         0             0          0          0                4        0
    211  3408         0   ..         0             0          0          0                5        0
    217  3504         0   ..         0             0          0          0                6        0
    222  3584         0   ..         0             0          0          0                7        0
    225  3632         0   ..         0             0          0          0                8        0
    254  4096         0   ..         0             0          0          0                1        0
  ...

Đối với kích thước chuỗi zspage là 16, hình mờ lớp lớn sẽ trở thành 3840 byte :::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable

  ...
    202  3264         0   ..         0             0          0          0                4        0
    206  3328         0   ..         0             0          0          0               13        0
    207  3344         0   ..         0             0          0          0                9        0
    208  3360         0   ..         0             0          0          0               14        0
    211  3408         0   ..         0             0          0          0                5        0
    212  3424         0   ..         0             0          0          0               16        0
    214  3456         0   ..         0             0          0          0               11        0
    217  3504         0   ..         0             0          0          0                6        0
    219  3536         0   ..         0             0          0          0               13        0
    222  3584         0   ..         0             0          0          0                7        0
    223  3600         0   ..         0             0          0          0               15        0
    225  3632         0   ..         0             0          0          0                8        0
    228  3680         0   ..         0             0          0          0                9        0
    230  3712         0   ..         0             0          0          0               10        0
    232  3744         0   ..         0             0          0          0               11        0
    234  3776         0   ..         0             0          0          0               12        0
    235  3792         0   ..         0             0          0          0               13        0
    236  3808         0   ..         0             0          0          0               14        0
    238  3840         0   ..         0             0          0          0               15        0
    254  4096         0   ..         0             0          0          0                1        0
  ...

Nhìn chung, hiệu ứng kích thước chuỗi zspage kết hợp trên cấu hình nhóm zsmalloc :::

số trang trên mỗi zspage số lớp kích thước (cụm) hình mờ lớp kích thước lớn
         4 69 3264
         5 86 3408
         6 93 3504
         7 112 3584
         8 123 3632
         9 140 3680
        10 143 3712
        11 159 3744
        12 164 3776
        13 180 3792
        14 183 3808
        15 188 3840
        16 191 3840


Một thử nghiệm tổng hợp
-----------------------

zram làm nơi lưu trữ tạo phẩm xây dựng (biên dịch nhân Linux).

* ZZ0000ZZ

số liệu thống kê của lớp zsmalloc :::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable

    ...
Tổng cộng 13 .. 51 413836 412973 159955 3

zram mm_stat:::

1691783168 628083717 655175680 0 655175680 60 0 34048 34049


* ZZ0000ZZ

số liệu thống kê của lớp zsmalloc :::

quy mô lớp 10% .... 100% obj_allocated obj_used pages_used pages_per_zspage freeable

    ...
Tổng cộng 18 .. 87 414852 412978 156666 0

zram mm_stat:::

1691803648 627793930 641703936 0 641703936 60 0 33591 33591

Việc sử dụng chuỗi zspage lớn hơn có thể dẫn đến việc sử dụng ít trang vật lý hơn, như đã thấy
trong ví dụ trong đó số lượng trang vật lý được sử dụng giảm từ 159955
xuống 156666, đồng thời mức sử dụng bộ nhớ nhóm zsmalloc tối đa đã giảm từ
655175680 đến 641703936 byte.

Tuy nhiên, lợi thế này có thể được bù đắp bởi tiềm năng tăng cường hệ thống
áp lực bộ nhớ (vì một số trang z có kích thước chuỗi lớn hơn) trong trường hợp có
bị phân mảnh nội bộ nặng nề và nén zspool không thể di chuyển
đối tượng và phát hành zspages. Trong những trường hợp này, nên giảm
giới hạn về kích thước của chuỗi zspage (như được chỉ định bởi
Tùy chọn CONFIG_ZSMALLOC_CHAIN_SIZE).

Chức năng
=========

.. kernel-doc:: mm/zsmalloc.c
