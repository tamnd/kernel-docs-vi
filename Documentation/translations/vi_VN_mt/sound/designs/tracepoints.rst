.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/designs/tracepoints.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Dấu vết trong ALSA
===================

2017/07/02
Takasahi Sakamoto

Dấu vết trong lõi ALSA PCM
============================

Lõi ALSA PCM đăng ký hệ thống con ZZ0000ZZ vào hệ thống điểm theo dõi hạt nhân.
Hệ thống con này bao gồm hai loại điểm theo dõi; cho trạng thái của bộ đệm PCM
và để xử lý các thông số phần cứng PCM. Những dấu vết này có sẵn
khi cấu hình kernel tương ứng được kích hoạt. Khi ZZ0001ZZ
được kích hoạt, các điểm theo dõi sau sẽ có sẵn. Khi bổ sung
ZZ0002ZZ cũng được bật, các điểm theo dõi trước đây cũng được bật.

Dấu vết cho trạng thái của bộ đệm PCM
------------------------------------

Loại này bao gồm bốn điểm theo dõi; ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ.

Dấu vết để xử lý các tham số phần cứng PCM
-----------------------------------------------------

Danh mục này bao gồm hai điểm theo dõi; ZZ0000ZZ và
ZZ0001ZZ.

Trong thiết kế lõi ALSA PCM, việc truyền dữ liệu được trừu tượng hóa dưới dạng luồng phụ PCM.
Các ứng dụng quản lý luồng con PCM để duy trì việc truyền dữ liệu cho các khung PCM.
Trước khi bắt đầu truyền dữ liệu, các ứng dụng cần cấu hình PCM
dòng phụ. Trong quy trình này, các tham số phần cứng PCM được quyết định bởi
tương tác giữa các ứng dụng và lõi ALSA PCM. Sau khi đã quyết định, thời gian chạy của
dòng con PCM giữ các tham số.

Các tham số được mô tả trong struct snd_pcm_hw_params. Cái này
Cấu trúc bao gồm một số loại tham số. Ứng dụng được thiết lập thích hợp hơn
giá trị cho các tham số này, sau đó thực thi ioctl(2) với SNDRV_PCM_IOCTL_HW_REFINE
hoặc SNDRV_PCM_IOCTL_HW_PARAMS. Cái trước chỉ được sử dụng để tinh chế có sẵn
tập hợp các tham số. Cái sau được sử dụng để quyết định thực tế các tham số.

Cấu trúc snd_pcm_hw_params có các thành viên bên dưới:

ZZ0000ZZ
        Có thể định cấu hình. Lõi ALSA PCM và một số trình điều khiển xử lý cờ này để chọn
        các tham số thuận tiện hoặc thay đổi hành vi của chúng.
ZZ0001ZZ
        Có thể định cấu hình. Loại tham số này được mô tả trong
        struct snd_mask và biểu thị các giá trị mặt nạ. Kể từ giao thức PCM
        v2.0.13, ba loại được xác định.

-SNDRV_PCM_HW_PARAM_ACCESS
        -SNDRV_PCM_HW_PARAM_FORMAT
        -SNDRV_PCM_HW_PARAM_SUBFORMAT
ZZ0000ZZ
        Có thể định cấu hình. Loại tham số này được mô tả trong
        struct snd_interval và biểu thị các giá trị bằng một phạm vi. Kể từ
        Giao thức PCM v2.0.13, có 12 loại được xác định.

-SNDRV_PCM_HW_PARAM_SAMPLE_BITS
        -SNDRV_PCM_HW_PARAM_FRAME_BITS
        -SNDRV_PCM_HW_PARAM_CHANNELS
        -SNDRV_PCM_HW_PARAM_RATE
        -SNDRV_PCM_HW_PARAM_PERIOD_TIME
        -SNDRV_PCM_HW_PARAM_PERIOD_SIZE
        -SNDRV_PCM_HW_PARAM_PERIOD_BYTES
        -SNDRV_PCM_HW_PARAM_PERIODS
        -SNDRV_PCM_HW_PARAM_BUFFER_TIME
        -SNDRV_PCM_HW_PARAM_BUFFER_SIZE
        -SNDRV_PCM_HW_PARAM_BUFFER_BYTES
        -SNDRV_PCM_HW_PARAM_TICK_TIME
ZZ0000ZZ
        Có thể định cấu hình. Điều này được đánh giá ở ioctl(2) với
        Chỉ SNDRV_PCM_IOCTL_HW_REFINE. Ứng dụng có thể chọn cái nào
        tham số mặt nạ/khoảng có thể được thay đổi bởi lõi ALSA PCM. cho
        SNDRV_PCM_IOCTL_HW_PARAMS, mặt nạ này bị bỏ qua và tất cả các tham số
        sẽ được thay đổi.
ZZ0001ZZ
        Chỉ đọc. Sau khi trở về từ ioctl(2), bộ đệm trong không gian người dùng dành cho
        struct snd_pcm_hw_params bao gồm kết quả của mỗi thao tác.
        Mặt nạ này thể hiện tham số mặt nạ/khoảng nào thực sự được thay đổi.
ZZ0002ZZ
        Chỉ đọc. Điều này thể hiện khả năng của phần cứng/trình điều khiển dưới dạng cờ bit
        với SNDRV_PCM_INFO_XXX. Thông thường, các ứng dụng thực thi ioctl(2) với
        SNDRV_PCM_IOCTL_HW_REFINE để lấy cờ này rồi quyết định ứng viên
        của các tham số và thực thi ioctl(2) với SNDRV_PCM_IOCTL_HW_PARAMS để
        định cấu hình luồng con PCM.
ZZ0003ZZ
        Chỉ đọc. Giá trị này thể hiện độ rộng bit khả dụng ở phía MSB của
        một mẫu PCM. Khi một tham số của SNDRV_PCM_HW_PARAM_SAMPLE_BITS được
        được quyết định là một số cố định, giá trị này cũng được tính theo
        nó. Khác, không. Nhưng hành vi này phụ thuộc vào việc triển khai trong trình điều khiển
        bên.
ZZ0004ZZ
        Chỉ đọc. Giá trị này đại diện cho tử số của tốc độ lấy mẫu theo phân số
        ký hiệu. Về cơ bản, khi một tham số của SNDRV_PCM_HW_PARAM_RATE được
        được quyết định dưới dạng một giá trị duy nhất, giá trị này cũng được tính theo
        nó. Khác, không. Nhưng hành vi này phụ thuộc vào việc triển khai trong trình điều khiển
        bên.
ZZ0005ZZ
        Chỉ đọc. Giá trị này đại diện cho mẫu số của tốc độ lấy mẫu trong
        ký hiệu phân số. Về cơ bản, khi một tham số của
        SNDRV_PCM_HW_PARAM_RATE được quyết định là một giá trị duy nhất, giá trị này là
        cũng tính theo đó. Khác, không. Nhưng hành vi này phụ thuộc
        về việc triển khai ở phía trình điều khiển.
ZZ0006ZZ
        Chỉ đọc. Giá trị này thể hiện kích thước của FIFO trong âm thanh nối tiếp
        giao diện của phần cứng. Về cơ bản, mỗi trình điều khiển có thể chỉ định một
        giá trị cho tham số này nhưng một số trình điều khiển cố tình đặt 0 với
        quan tâm đến thiết kế phần cứng hoặc giao thức truyền dữ liệu.

Lõi ALSA PCM xử lý bộ đệm của struct snd_pcm_hw_params khi
các ứng dụng thực thi ioctl(2) với SNDRV_PCM_HW_REFINE hoặc SNDRV_PCM_HW_PARAMS.
Các thông số trong bộ đệm được thay đổi theo
struct snd_pcm_hardware và các quy tắc ràng buộc trong thời gian chạy. các
cấu trúc mô tả khả năng của phần cứng được xử lý. Các quy tắc mô tả
phụ thuộc vào đó một tham số được quyết định theo một số tham số.
Một quy tắc có chức năng gọi lại và trình điều khiển có thể đăng ký các chức năng tùy ý
để tính toán tham số mục tiêu. Lõi ALSA PCM đăng ký một số quy tắc cho
thời gian chạy làm mặc định.

Mỗi người lái xe có thể tham gia tương tác miễn là họ chuẩn bị sẵn hai thứ
trong lệnh gọi lại của struct snd_pcm_ops.open.

1. Trong lệnh gọi lại, người lái xe phải thay đổi thành viên của
   gõ struct snd_pcm_hardware trong thời gian chạy, theo
   dung lượng của phần cứng tương ứng.
2. Trong cùng một cuộc gọi lại, người lái xe cũng phải đăng ký các quy tắc bổ sung
   các ràng buộc trong thời gian chạy khi một số tham số có sự phụ thuộc
   do thiết kế phần cứng.

Trình điều khiển có thể đề cập đến kết quả của sự tương tác trong lệnh gọi lại của
struct snd_pcm_ops.hw_params, tuy nhiên nó sẽ không thay đổi
nội dung.

Các điểm theo dõi trong danh mục này được thiết kế để theo dõi những thay đổi của
tham số mặt nạ/khoảng. Khi lõi ALSA PCM thay đổi chúng, ZZ0000ZZ hoặc
Sự kiện ZZ0001ZZ được thăm dò theo loại tham số đã thay đổi.

Lõi ALSA PCM cũng có định dạng in đẹp cho từng dấu vết. Dưới đây
là một ví dụ cho ZZ0000ZZ.

::

hw_mask_param: pcmC0D0p 001/023 FORMAT 0000000000000000000000001000000044 00000000000000000000000001000000044


Dưới đây là một ví dụ cho ZZ0000ZZ.

::

hw_interval_param: pcmC0D0p 000/023 BUFFER_SIZE 0 0 [0 4294967295] 0 1 [0 4294967295]

Ba lĩnh vực đầu tiên là phổ biến. Chúng đại diện cho tên của nhân vật ALSA PCM
thiết bị, quy tắc ràng buộc và tên của tham số đã thay đổi theo thứ tự. các
trường quy tắc ràng buộc bao gồm hai trường con; chỉ số của quy tắc áp dụng
và tổng số quy tắc được thêm vào thời gian chạy. Là một ngoại lệ, chỉ số 000
có nghĩa là tham số được thay đổi bởi lõi ALSA PCM, bất kể quy tắc.

Phần còn lại của trường biểu thị trạng thái của tham số trước/sau khi thay đổi. Những cái này
các trường khác nhau tùy theo loại tham số. Đối với các thông số của mặt nạ
loại, các trường biểu thị kết xuất thập lục phân của nội dung của tham số. cho
tham số của loại khoảng, các trường biểu thị giá trị của từng thành viên của
ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ trong
struct snd_interval theo thứ tự này.

Dấu vết trong trình điều khiển
======================

Một số trình điều khiển có các điểm theo dõi để thuận tiện cho nhà phát triển. Vì họ hãy làm ơn
tham khảo từng tài liệu hoặc cách thực hiện.
