.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/vcpudispatch_stats.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Thống kê công văn VCPU
========================

Đối với LPAR của bộ xử lý dùng chung, POWER Hypervisor duy trì mức độ tương đối
ánh xạ tĩnh của bộ xử lý LPAR (vcpus) sang bộ xử lý vật lý
chip (đại diện cho nút "nhà") và cố gắng luôn gửi vcpus
trên chip xử lý vật lý liên quan của họ. Tuy nhiên, dưới điều kiện nhất định
trong các trường hợp, vcpus có thể được gửi đi trên một chip xử lý khác (đi
từ nút nhà của nó).

/proc/powerpc/vcpudispatch_stats có thể được sử dụng để lấy số liệu thống kê
liên quan đến hành vi gửi vcpu. Viết '1' vào tập tin này cho phép
thu thập số liệu thống kê, trong khi viết '0' sẽ vô hiệu hóa số liệu thống kê.
Theo mặc định, nhật ký DTLB cho mỗi vcpu được xử lý 50 lần một giây nên
để không bỏ sót bất kỳ mục nào. Tần số xử lý này có thể thay đổi
thông qua /proc/powerpc/vcpudispatch_stats_freq.

Bản thân số liệu thống kê có sẵn bằng cách đọc tệp Procfs
/proc/powerpc/vcpudispatch_stats. Mỗi dòng ở đầu ra tương ứng với
một vcpu được biểu thị bằng trường đầu tiên, theo sau là 8 số.

Số đầu tiên tương ứng với:

1. tổng số công văn vcpu kể từ khi bắt đầu thu thập số liệu thống kê

4 số tiếp theo thể hiện sự phân tán công văn của vcpu:

2. số lần vcpu này được gửi đi trên cùng bộ xử lý như lần trước
   thời gian
3. số lần vcpu này được gửi đi trên lõi bộ xử lý khác
   như lần trước, nhưng trong cùng một con chip
4. số lần vcpu này được gửi đi trên một con chip khác
5. số lần vcpu này được gửi đi trên một ổ cắm/ngăn kéo khác
   (ranh giới số tiếp theo)

3 số cuối cùng thể hiện số liệu thống kê liên quan đến nút chủ của
vcpu:

6. số lần vcpu này được gửi đi trong nút chủ (chip) của nó
7. số lần vcpu này được gửi đi ở một nút khác
8. số lần vcpu này được gửi đến một nút ở xa hơn (numa
   khoảng cách)

Một đầu ra ví dụ::

$ sudo mèo /proc/powerpc/vcpudispatch_stats
    cpu0 6839 4126 2683 30 0 6821 18 0
    cpu1 2515 1274 1229 12 0 2509 6 0
    CPU2 2317 1198 1109 10 0 2312 5 0
    cpu3 2259 1165 1088 6 0 2256 3 0
    cpu4 2205 1143 1056 6 0 2202 3 0
    cpu5 2165 1121 1038 6 0 2162 3 0
    cpu6 2183 1127 1050 6 0 2180 3 0
    CPU7 2193 1133 1052 8 0 2187 6 0
    CPU8 2165 1115 1032 18 0 2156 9 0
    CPU9 2301 1252 1033 16 0 2293 8 0
    cpu10 2197 1138 1041 18 0 2187 10 0
    cpu11 2273 1185 1062 26 0 2260 13 0
    cpu12 2186 1125 1043 18 0 2177 9 0
    cpu13 2161 1115 1030 16 0 2153 8 0
    cpu14 2206 1153 1033 20 0 2196 10 0
    cpu15 2163 1115 1032 16 0 2155 8 0

Trong kết quả đầu ra ở trên, đối với vcpu0, đã có 6839 lần gửi kể từ đó
thống kê đã được kích hoạt. 4126 trong số các công văn đó đều giống nhau
cpu vật lý như lần trước. 2683 nằm trên một lõi khác, nhưng bên trong
cùng một con chip, trong khi 30 lần gửi đi trên một con chip khác so với
công văn cuối cùng của nó.

Ngoài ra, trong tổng số 6839 công văn, chúng tôi thấy có
6821 lần gửi đi trên nút nhà của vcpu, trong khi 18 lần gửi đi
bên ngoài nút chủ của nó, trên một con chip lân cận.