.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/visl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển bộ giải mã không trạng thái ảo (visl)
======================================================

Một thiết bị giải mã không trạng thái ảo để phát triển uAPI không trạng thái
mục đích.

Mục tiêu của công cụ này là giúp phát triển và thử nghiệm các
các ứng dụng không gian người dùng sử dụng V4L2 không trạng thái API để giải mã phương tiện.

Việc triển khai không gian người dùng có thể sử dụng visl để chạy vòng giải mã ngay cả khi
không có sẵn phần cứng hoặc khi chưa có uAPI kernel cho codec
đã được thượng nguồn chưa. Điều này có thể tiết lộ lỗi ở giai đoạn đầu.

Trình điều khiển này cũng có thể theo dõi nội dung của các điều khiển V4L2 được gửi
đến nó.  Nó cũng có thể kết xuất nội dung của bộ đệm vb2 thông qua một
giao diện debugfs. Điều này về nhiều mặt tương tự như việc truy tìm
cơ sở hạ tầng có sẵn cho các API mã hóa/giải mã phổ biến khác hiện có
và có thể giúp phát triển một ứng dụng không gian người dùng bằng cách sử dụng một ứng dụng khác (đang hoạt động)
một cái làm tài liệu tham khảo.

.. note::

        No actual decoding of video frames is performed by visl. The
        V4L2 test pattern generator is used to write various debug information
        to the capture buffers instead.

Thông số mô-đun
-----------------

- visl_debug: Kích hoạt thông tin gỡ lỗi, in các thông báo gỡ lỗi khác nhau thông qua
  dprintk. Đồng thời kiểm soát xem thông tin gỡ lỗi trên mỗi khung hình có được hiển thị hay không. Mặc định là tắt.
  Lưu ý rằng việc bật tính năng này có thể dẫn đến hiệu suất chậm thông qua serial.

- visl_transtime_ms: Thời gian xử lý mô phỏng tính bằng mili giây. Làm chậm lại
  tốc độ giải mã có thể hữu ích cho việc gỡ lỗi.

- visl_dprintk_frame_start, visl_dprintk_frame_nframes: Chỉ ra một phạm vi
  các khung nơi dprintk được kích hoạt. Điều này chỉ kiểm soát việc theo dõi dprintk trên một
  cơ sở từng khung hình. Lưu ý rằng việc in nhiều dữ liệu có thể bị chậm thông qua nối tiếp.

- keep_bitstream_buffers: Kiểm soát xem bộ đệm dòng bit (tức là OUTPUT) có
  được giữ lại sau phiên giải mã. Mặc định là sai để giảm số lượng
  sự lộn xộn. keep_bitstream_buffers == false hoạt động tốt khi gỡ lỗi trực tiếp
  chương trình khách hàng với GDB.

- bitstream_trace_frame_start, bitstream_trace_nframes: Tương tự như
  visl_dprintk_frame_start, visl_dprintk_nframes, nhưng kiểm soát việc bán phá giá
  thay vào đó, hãy đệm dữ liệu thông qua debugfs.

- tpg_verbose: Viết thêm thông tin trên mỗi khung đầu ra để dễ dàng gỡ lỗi
  API. Khi được đặt thành true, khung đầu ra không ổn định đối với đầu vào nhất định
  vì một số thông tin như con trỏ hoặc trạng thái hàng đợi sẽ được thêm vào chúng.

Trường hợp sử dụng mặc định cho trình điều khiển này là gì?
-----------------------------------------------------------

Trình điều khiển này có thể được sử dụng như một cách để so sánh việc triển khai không gian người dùng khác nhau.
Điều này giả định rằng một máy khách đang hoạt động đang chạy chống lại visl và ftrace và
Dữ liệu bộ đệm OUTPUT sau đó được sử dụng để gỡ lỗi một công việc đang thực hiện
thực hiện.

Mặc dù không thực sự giải mã video nhưng các khung hình đầu ra có thể được sử dụng
dựa vào tham chiếu cho một đầu vào nhất định, trừ khi tpg_verbose được đặt thành true.

Tùy thuộc vào giá trị tham số tpg_verbose, thông tin về khung tham chiếu,
dấu thời gian của chúng, trạng thái của hàng đợi OUTPUT và CAPTURE, v.v.
đọc trực tiếp từ bộ đệm CAPTURE.

Codec được hỗ trợ
-----------------

Các codec sau được hỗ trợ:

-FWHT
-MPEG2
-VP8
-VP9
-H.264
-HEVC
-AV1

sự kiện dấu vết visl
--------------------
Các sự kiện theo dõi được xác định trên cơ sở mỗi codec, ví dụ:

.. code-block:: bash

        $ ls /sys/kernel/tracing/events/ | grep visl
        visl_av1_controls
        visl_fwht_controls
        visl_h264_controls
        visl_hevc_controls
        visl_mpeg2_controls
        visl_vp8_controls
        visl_vp9_controls

Ví dụ: để kết xuất dữ liệu HEVC SPS:

.. code-block:: bash

        $ echo 1 >  /sys/kernel/tracing/events/visl_hevc_controls/v4l2_ctrl_hevc_sps/enable

Dữ liệu SPS sẽ được chuyển vào bộ đệm theo dõi, tức là:

.. code-block:: bash

        $ cat /sys/kernel/tracing/trace
        video_parameter_set_id 0
        seq_parameter_set_id 0
        pic_width_in_luma_samples 1920
        pic_height_in_luma_samples 1080
        bit_depth_luma_minus8 0
        bit_depth_chroma_minus8 0
        log2_max_pic_order_cnt_lsb_minus4 4
        sps_max_dec_pic_buffering_minus1 6
        sps_max_num_reorder_pics 2
        sps_max_latency_increase_plus1 0
        log2_min_luma_coding_block_size_minus3 0
        log2_diff_max_min_luma_coding_block_size 3
        log2_min_luma_transform_block_size_minus2 0
        log2_diff_max_min_luma_transform_block_size 3
        max_transform_hierarchy_depth_inter 2
        max_transform_hierarchy_depth_intra 2
        pcm_sample_bit_depth_luma_minus1 0
        pcm_sample_bit_depth_chroma_minus1 0
        log2_min_pcm_luma_coding_block_size_minus3 0
        log2_diff_max_min_pcm_luma_coding_block_size 0
        num_short_term_ref_pic_sets 0
        num_long_term_ref_pics_sps 0
        chroma_format_idc 1
        sps_max_sub_layers_minus1 0
        flags AMP_ENABLED|SAMPLE_ADAPTIVE_OFFSET|TEMPORAL_MVP_ENABLED|STRONG_INTRA_SMOOTHING_ENABLED


Kết xuất dữ liệu bộ đệm OUTPUT thông qua debugfs
------------------------------------------------

Nếu ZZ0000ZZ Kconfig được bật, visl sẽ xuất hiện
ZZ0001ZZ với dữ liệu bộ đệm OUTPUT theo
giá trị của bitstream_trace_frame_start và bitstream_trace_nframes. Điều này có thể
đánh dấu các lỗi vì máy khách bị hỏng có thể không lấp đầy bộ đệm đúng cách.

Một tệp duy nhất được tạo cho mỗi bộ đệm OUTPUT đã xử lý. Tên của nó chứa một
số nguyên biểu thị chuỗi bộ đệm, tức là:

.. code-block:: c

	snprintf(name, 32, "bitstream%d", run->src->sequence);

Việc kết xuất các giá trị chỉ đơn giản là vấn đề đọc từ tệp, tức là:

Đối với bộ đệm có chuỗi == 0:

.. code-block:: bash

        $ xxd /sys/kernel/debug/visl/bitstream/bitstream0
        00000000: 2601 af04 d088 bc25 a173 0e41 a4f2 3274  &......%.s.A..2t
        00000010: c668 cb28 e775 b4ac f53a ba60 f8fd 3aa1  .h.(.u...:.`..:.
        00000020: 46b4 bcfc 506c e227 2372 e5f5 d7ea 579f  F...Pl.'#r....W.
        00000030: 6371 5eb5 0eb8 23b5 ca6a 5de5 983a 19e4  cq^...#..j]..:..
        00000040: e8c3 4320 b4ba a226 cbc1 4138 3a12 32d6  ..C ...&..A8:.2.
        00000050: fef3 247b 3523 4e90 9682 ac8e eb0c a389  ..${5#N.........
        00000060: ddd0 6cfc 0187 0e20 7aae b15b 1812 3d33  ..l.... z..[..=3
        00000070: e1c5 f425 a83a 00b7 4f18 8127 3c4c aefb  ...%.:..O..'<L..

Đối với bộ đệm có chuỗi == 1:

.. code-block:: bash

        $ xxd /sys/kernel/debug/visl/bitstream/bitstream1
        00000000: 0201 d021 49e1 0c40 aa11 1449 14a6 01dc  ...!I..@...I....
        00000010: 7023 889a c8cd 2cd0 13b4 dab0 e8ca 21fe  p#....,.......!.
        00000020: c4c8 ab4c 486e 4e2f b0df 96cc c74e 8dde  ...LHnN/.....N..
        00000030: 8ce7 ee36 d880 4095 4d64 30a0 ff4f 0c5e  ...6..@.Md0..O.^
        00000040: f16b a6a1 d806 ca2a 0ece a673 7bea 1f37  .k.....*...s{..7
        00000050: 370f 5bb9 1dc4 ba21 6434 bc53 0173 cba0  7.[....!d4.S.s..
        00000060: dfe6 bc99 01ea b6e0 346b 92b5 c8de 9f5d  ........4k.....]
        00000070: e7cc 3484 1769 fef2 a693 a945 2c8b 31da  ..4..i.....E,.1.

Và vân vân.

Theo mặc định, các tệp sẽ bị xóa trong STREAMOFF. Điều này nhằm giảm số lượng
của sự lộn xộn.