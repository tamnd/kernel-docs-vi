.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/device-mapper/verity.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========
dm-sự thật
=========

Mục tiêu "xác thực" của Device-Mapper cung cấp khả năng kiểm tra tính toàn vẹn minh bạch của
chặn các thiết bị bằng cách sử dụng bản tóm tắt mật mã được cung cấp bởi kernel crypto API.
Mục tiêu này là chỉ đọc.

Thông số xây dựng
=======================

::

<phiên bản> <dev> <hash_dev>
    <data_block_size> <hash_block_size>
    <num_data_blocks> <hash_start_block>
    <thuật toán> <tiêu hóa> <muối>
    [<#opt_params> <opt_params>]

<phiên bản>
    Đây là loại định dạng băm trên đĩa.

0 là định dạng ban đầu được sử dụng trong Chrome OS.
      Muối được thêm vào khi băm, các bản tóm tắt được lưu trữ liên tục và
      phần còn lại của khối được đệm bằng số 0.

1 là định dạng hiện tại nên được sử dụng cho các thiết bị mới.
      Muối được thêm vào trước khi băm và mỗi bản tóm tắt được
      được đệm bằng số 0 lũy thừa của hai.

<dev>
    Đây là thiết bị chứa dữ liệu, tính toàn vẹn của nó cần được đảm bảo.
    đã kiểm tra.  Nó có thể được chỉ định dưới dạng đường dẫn, như/dev/sdaX hoặc số thiết bị,
    <chính>:<nhỏ>.

<hash_dev>
    Đây là thiết bị cung cấp dữ liệu cây băm.  Nó có thể là
    được chỉ định tương tự với đường dẫn thiết bị và có thể là cùng một thiết bị.  Nếu
    sử dụng cùng một thiết bị, hash_start phải nằm ngoài cấu hình
    thiết bị dm-verity.

<data_block_size>
    Kích thước khối trên thiết bị dữ liệu tính bằng byte.
    Mỗi khối tương ứng với một thông báo trên thiết bị băm.

<hash_block_size>
    Kích thước của khối băm tính bằng byte.

<num_data_blocks>
    Số khối dữ liệu trên thiết bị dữ liệu.  Các khối bổ sung là
    không thể truy cập được.  Bạn có thể đặt các giá trị băm vào cùng phân vùng với dữ liệu, trong phần này
    băm trường hợp được đặt sau <num_data_blocks>.

<hash_start_block>
    Đây là phần bù, trong các khối <hash_block_size>, tính từ đầu hash_dev
    tới khối gốc của cây băm.

<thuật toán>
    Thuật toán băm mật mã được sử dụng cho thiết bị này.  Điều này nên
    là tên của thuật toán, chẳng hạn như "sha1".

<tiêu hóa>
    Mã hóa thập lục phân của hàm băm mật mã của khối băm gốc
    và muối.  Hàm băm này phải được tin cậy vì không có tính xác thực nào khác
    ngoài điểm này.

<muối>
    Mã hóa thập lục phân của giá trị muối.

<#opt_params>
    Số lượng tham số tùy chọn. Nếu không có tham số tùy chọn,
    phần tham số tùy chọn có thể được bỏ qua hoặc #opt_params có thể bằng 0.
    Mặt khác #opt_params là số đối số sau.

Ví dụ về phần tham số tùy chọn:
        1 bỏ qua_corruption

bỏ qua_corruption
    Ghi nhật ký các khối bị hỏng nhưng cho phép thao tác đọc diễn ra bình thường.

khởi động lại_on_corruption
    Khởi động lại hệ thống khi phát hiện một khối bị hỏng. Tùy chọn này là
    không tương thích với ign_corruption và yêu cầu hỗ trợ không gian người dùng để
    tránh các vòng lặp khởi động lại.

hoảng loạn_on_corruption
    Làm thiết bị hoảng sợ khi phát hiện một khối bị hỏng. Tùy chọn này là
    không tương thích với ign_corruption và restart_on_corruption.

khởi động lại_on_error
    Khởi động lại hệ thống khi phát hiện lỗi I/O.
    Tùy chọn này có thể được kết hợp với tùy chọn restart_on_corruption.

hoảng_on_error
    Làm thiết bị hoảng sợ khi phát hiện lỗi I/O. Tùy chọn này là
    không tương thích với tùy chọn restart_on_error nhưng có thể kết hợp
    với tùy chọn Panic_on_corruption.

bỏ qua_zero_blocks
    Không xác minh các khối dự kiến chứa số 0 và luôn trả về
    thay vào đó là số 0. Điều này có thể hữu ích nếu phân vùng chứa các khối không sử dụng
    không được đảm bảo chứa số 0.

use_fec_from_device <fec_dev>
    Sử dụng dữ liệu chẵn lẻ sửa lỗi chuyển tiếp (FEC) từ thiết bị được chỉ định để
    cố gắng tự động phục hồi sau lỗi hỏng và lỗi I/O.

Nếu tùy chọn này được cung cấp thì <fec_roots> và <fec_blocks> cũng phải được
    đã cho.  <hash_block_size> cũng phải bằng <data_block_size>.

<fec_dev> có thể giống với <dev>, trong trường hợp đó <fec_start> phải là
    ngoài vùng dữ liệu.  Nó cũng có thể giống như <hash_dev>, trong trường hợp đó
    <fec_start> phải nằm ngoài vùng băm và các vùng siêu dữ liệu bổ sung tùy chọn.

Nếu dữ liệu <dev> được mã hóa thì <fec_dev> cũng vậy.

Để biết thêm thông tin, xem ZZ0000ZZ.

fec_roots <num>
    Số byte chẵn lẻ trong mỗi từ mã Reed-Solomon 255 byte.  các
    Mã Reed-Solomon được sử dụng sẽ là mã RS(255, k) trong đó k = 255 - fec_roots.

Các giá trị được hỗ trợ bao gồm từ 2 đến 24.  Giá trị cao hơn cung cấp
    sửa lỗi mạnh mẽ hơn.  Tuy nhiên, giá trị tối thiểu là 2 đã cung cấp
    sửa lỗi mạnh do sử dụng kỹ thuật xen kẽ, vì vậy 2 là
    giá trị được đề xuất cho hầu hết người dùng.  fec_roots=2 tương ứng với một
    Mã RS(255, 253), có chi phí không gian khoảng 0,8%.

fec_blocks <num>
    Tổng số khối <data_block_size> được kiểm tra lỗi bằng cách sử dụng
    FEC.  Đây ít nhất phải là tổng của <num_data_blocks> và số lượng
    các khối cần thiết cho cây băm.  Nó có thể bao gồm các khối siêu dữ liệu bổ sung,
    được cho là có thể truy cập được trên <hash_dev> sau các khối băm.

Lưu ý rằng đây là ZZ0000ZZ số khối chẵn lẻ.  Số lượng chẵn lẻ
    các khối được suy ra từ <fec_blocks>, <fec_roots> và <data_block_size>.

fec_start <bù đắp>
    Đây là phần bù, tính bằng khối <data_block_size>, tính từ đầu <fec_dev>
    đến đầu dữ liệu chẵn lẻ.

kiểm tra_at_most_once
    Chỉ xác minh các khối dữ liệu trong lần đầu tiên chúng được đọc từ thiết bị dữ liệu,
    hơn là mọi lúc.  Điều này làm giảm chi phí của dm-verity để nó
    có thể được sử dụng trên các hệ thống bị hạn chế về bộ nhớ và/hoặc CPU.  Tuy nhiên, nó
    cung cấp mức độ bảo mật giảm vì chỉ giả mạo ngoại tuyến
    nội dung của thiết bị dữ liệu sẽ được phát hiện, không bị giả mạo trực tuyến.

Khối băm vẫn được xác minh mỗi lần chúng được đọc từ thiết bị băm,
    vì việc xác minh các khối băm ít quan trọng hơn về hiệu suất so với dữ liệu
    khối và khối băm sẽ không được xác minh nữa sau khi tất cả dữ liệu
    dù sao thì các khối mà nó bao phủ cũng đã được xác minh.

root_hash_sig_key_desc <key_description>
    Đây là mô tả về USER_KEY mà kernel sẽ tra cứu để lấy
    chữ ký pkcs7 của roothash. Chữ ký pkcs7 được sử dụng để xác thực
    hàm băm gốc trong quá trình tạo thiết bị khối ánh xạ thiết bị.
    Việc xác minh roothash phụ thuộc vào cấu hình DM_VERITY_VERIFY_ROOTHASH_SIG
    được thiết lập trong kernel.  Các chữ ký được kiểm tra dựa trên nội dung
    khóa đáng tin cậy theo mặc định hoặc khóa đáng tin cậy thứ cấp nếu
    DM_VERITY_VERIFY_ROOTHASH_SIG_SECONDARY_KEYRING được thiết lập.  Thứ cấp
    Theo mặc định, khóa đáng tin cậy bao gồm khóa đáng tin cậy dựng sẵn và nó có thể
    cũng đạt được chứng chỉ mới trong thời gian chạy nếu chúng được ký bởi chứng chỉ
    đã có trong khóa đáng tin cậy thứ cấp.

thử_verify_in_tasklet
    Nếu hàm băm xác thực nằm trong bộ đệm và kích thước IO không vượt quá giới hạn,
    xác minh các khối dữ liệu ở nửa dưới thay vì hàng công việc. Tùy chọn này có thể
    giảm độ trễ IO. Giới hạn kích thước có thể được cấu hình thông qua
    /sys/module/dm_verity/parameters/use_bh_bytes. Bốn thông số
    tương ứng với các giới hạn cho IOPRIO_CLASS_NONE, IOPRIO_CLASS_RT,
    IOPRIO_CLASS_BE và IOPRIO_CLASS_IDLE lần lượt.
    Ví dụ:
    <không>,<rt>,<be>,<nhàn rỗi>
    4096,4096,4096,4096

Lý thuyết hoạt động
===================

dm-verity có nghĩa là được thiết lập như một phần của đường dẫn khởi động đã được xác minh.  Cái này
có thể là bất cứ thứ gì, từ khởi động bằng tboot hoặc Trustedgrub cho đến chỉ
khởi động từ một thiết bị nổi tiếng (như ổ đĩa USB hoặc CD).

Khi thiết bị dm-verity được định cấu hình, người gọi sẽ phải
đã được xác thực theo một cách nào đó (chữ ký mật mã, v.v.).
Sau khi khởi tạo, tất cả các giá trị băm sẽ được xác minh theo yêu cầu trong quá trình
truy cập đĩa.  Nếu chúng không thể được xác minh đến nút gốc của
cây, hàm băm gốc thì I/O sẽ thất bại.  Điều này sẽ phát hiện
giả mạo bất kỳ dữ liệu nào trên thiết bị và dữ liệu băm.

Băm mật mã được sử dụng để khẳng định tính toàn vẹn của thiết bị trên một
cơ sở từng khối. Điều này cho phép tính toán hàm băm nhẹ trong lần đọc đầu tiên
vào bộ nhớ đệm của trang. Băm khối được lưu trữ tuyến tính, căn chỉnh theo giá trị gần nhất
kích thước khối.

Cây băm
---------

Mỗi nút trong cây là một hàm băm mật mã.  Nếu là nút lá thì hàm băm
của một số khối dữ liệu trên đĩa được tính toán. Nếu là nút trung gian,
hàm băm của một số nút con được tính toán.

Mỗi mục trong cây là một tập hợp các nút lân cận phù hợp với một
khối.  Số lượng được xác định dựa trên block_size và kích thước của
thuật toán tóm tắt mật mã đã chọn.  Các giá trị băm được sắp xếp tuyến tính trong
mục này và bất kỳ dấu cách không được căn chỉnh nào đều bị bỏ qua nhưng được bao gồm khi
tính toán nút cha.

Cây trông giống như:

alg = sha256, num_blocks = 32768, block_size = 4096

::

[ gốc ]
                                / . . .    \
                     [mục_0] [mục_1]
                    / . . .  \ . . .   \
         [entry_0_0] . . .  [entry_0_127] . . . .  [mục_1_127]
           / ...\ / . . .  \ / \
     blk_0 ... blk_127 blk_16256 blk_16383 blk_32640 . . . blk_32767

Chuyển tiếp sửa lỗi
------------------------

Hỗ trợ sửa lỗi chuyển tiếp tùy chọn (FEC) của dm-verity thêm lỗi mạnh
khả năng sửa lỗi cho dm-verity.  Nó cho phép các hệ thống được hiển thị
không thể hoạt động do lỗi để tiếp tục hoạt động, mặc dù hiệu suất bị giảm.

FEC sử dụng mã Reed-Solomon (RS) được xen kẽ trên toàn bộ
(các) thiết bị, cho phép khôi phục các khối bị hỏng hoặc không thể đọc được trong thời gian dài.

dm-verity xác thực bất kỳ khối FEC nào được sửa theo hàm băm mong muốn trước khi sử dụng
nó.  Do đó, FEC không ảnh hưởng đến thuộc tính bảo mật của dm-verity.

Việc tích hợp FEC với dm-verity mang lại lợi ích đáng kể so với
lớp sửa lỗi riêng biệt:

- dm-verity chỉ gọi FEC khi hàm băm của khối không khớp với hàm băm mong muốn
  hoặc khối không thể đọc được.  Kết quả là FEC không thêm chi phí vào
  trường hợp phổ biến không xảy ra lỗi.

- băm dm-verity cũng được sử dụng để xác định các vị trí xóa để giải mã RS.
  Điều này cho phép sửa lỗi nhiều gấp đôi.

FEC sử dụng mã RS(255, k) trong đó k = 255 - fec_roots.  fec_roots thường là 2.
Điều này có nghĩa là mỗi k byte thông báo (thường là 253) có fec_roots (thường là 2)
byte dữ liệu chẵn lẻ được thêm vào để có được từ mã 255 byte.  (Nhiều nguồn bên ngoài
gọi từ mã RS là "khối".  Vì dm-verity đã sử dụng thuật ngữ "chặn" để
có ý nghĩa khác, chúng tôi sẽ sử dụng thuật ngữ rõ ràng hơn "từ mã RS".)

FEC kiểm tra tổng cộng các khối dữ liệu tin nhắn fec_blocks, bao gồm:

1. Các khối dữ liệu từ thiết bị dữ liệu
2. Khối băm từ thiết bị băm
3. Siêu dữ liệu bổ sung tùy chọn theo sau khối băm trên thiết bị băm

dm-verity giả định rằng dữ liệu chẵn lẻ FEC được tính toán như sau
thủ tục đã được tuân theo:

1. Ghép nối dữ liệu tin nhắn từ các nguồn trên.
2. Zero-pad cho bội số tiếp theo của k khối.  Đặt msg là byte kết quả
   mảng và msglen độ dài của nó tính bằng byte.
3. Với 0 <= i < msglen / k (đối với mỗi từ mã RS):
     một. Chọn msg[i + j * msglen / k] cho 0 <= j < k.
        Hãy coi đây là các byte thông báo 'k' của từ mã RS.
     b. Tính toán các byte chẵn lẻ 'fec_roots' tương ứng của từ mã RS,
        và nối chúng với dữ liệu chẵn lẻ FEC.

Bước 3a xen kẽ các từ mã RS trên toàn bộ thiết bị bằng cách sử dụng
mức độ đan xen của data_block_size * ceil(fec_blocks/k).  Đây là
xen kẽ tối đa, sao cho dữ liệu thông điệp bao gồm một vùng chứa
byte 0 của tất cả các từ mã RS, sau đó là vùng chứa byte 1 của tất cả các từ mã RS.
từ mã, v.v. cho đến vùng của byte 'k - 1'.  Lưu ý rằng số lượng
từ mã được đặt thành bội số của data_block_size; do đó, các khu vực là
được căn chỉnh theo khối và có khoảng đệm bằng 0 ngầm định lên tới các khối 'k - 1'.

Việc xen kẽ này cho phép sửa chữa các lỗi xảy ra trong thời gian dài.  Nó cung cấp
khả năng sửa lỗi mạnh hơn nhiều so với các thiết bị lưu trữ thường cung cấp, trong khi
giữ không gian trên cao ở mức thấp.

Chi phí giải mã chậm: việc sửa một khối thường yêu cầu đọc
254 khối bổ sung trải đều trên (các) thiết bị.  Tuy nhiên, đó là
có thể chấp nhận được vì dm-verity chỉ sử dụng FEC khi thực sự có lỗi.

Danh sách bên dưới chứa các chi tiết bổ sung về mã RS được sử dụng bởi
dm-verity's FEC.  Các chương trình không gian người dùng tạo ra dữ liệu chẵn lẻ cần sử dụng
các tham số này để dữ liệu chẵn lẻ khớp chính xác:

- Trường được sử dụng là GF(256)
- Các byte được ánh xạ tới/từ các phần tử GF(256) theo cách tự nhiên, trong đó các bit 0
  đến 7 (thứ tự thấp đến thứ tự cao) ánh xạ tới các hệ số của x^0 đến x^7
- Đa thức tạo trường là x^8 + x^4 + x^3 + x^2 + 1
- Các mã được sử dụng mang tính hệ thống, mã xem BCH
- Phần tử nguyên thủy alpha là 'x'
- Căn bậc nhất liên tiếp của đa thức sinh mã là 'x^0'

Định dạng trên đĩa
==============

Mã hạt nhân xác thực không đọc tiêu đề siêu dữ liệu xác thực trên đĩa.
Nó chỉ đọc các khối băm trực tiếp theo tiêu đề.
Người ta hy vọng rằng một công cụ không gian người dùng sẽ xác minh tính toàn vẹn của
tiêu đề xác thực.

Ngoài ra, tiêu đề có thể được bỏ qua và các tham số dmsetup có thể
được chuyển qua dòng lệnh kernel trong chuỗi tin cậy gốc trong đó
dòng lệnh được xác minh.

Trực tiếp theo sau tiêu đề (và với số khu vực được đệm vào hàm băm tiếp theo
ranh giới khối) là các khối băm được lưu trữ theo độ sâu tại một thời điểm
(bắt đầu từ gốc), sắp xếp theo thứ tự chỉ số tăng dần.

Đặc tả đầy đủ các tham số hạt nhân và định dạng siêu dữ liệu trên đĩa
có sẵn tại trang wiki của dự án cryptsetup

ZZ0000ZZ

Trạng thái
======
1. V (cho Hợp lệ) được trả về nếu mọi kiểm tra được thực hiện cho đến nay đều hợp lệ.
   Nếu bất kỳ kiểm tra nào không thành công, C (đối với Tham nhũng) sẽ được trả về.
2. Số khối được sửa bằng Forward Error Correction.
   '-' nếu Sửa lỗi chuyển tiếp không được bật.

Ví dụ
=======
Thiết lập thiết bị::

# dmsetup tạo vroot --readonly --table \
    "0 2097152 xác thực 1 /dev/sda1 /dev/sda2 4096 4096 262144 1 sha256 "\
    "4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076"\
    "123400000000000000000000000000000000000000000000000000000000000000000"

Công cụ xác thực dòng lệnh có sẵn để tính toán hoặc xác minh
cây băm hoặc kích hoạt thiết bị hạt nhân. Điều này có sẵn từ
kho lưu trữ ngược dòng cryptsetup ZZ0000ZZ
(dưới dạng phần mở rộng libcryptsetup).

Tạo hàm băm trên thiết bị::

Định dạng # veritysetup/dev/sda1/dev/sda2
  ...
Băm gốc: 4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076

Kích hoạt thiết bị::

# veritysetup tạo vroot /dev/sda1 /dev/sda2 \
    4392712ba01368efdf14b05c76f9e4df0d53664630b5d48632ed17a137f39076
