.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-encoder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _encoder:

*********************************************************
Giao diện bộ mã hóa video trạng thái từ bộ nhớ đến bộ nhớ
*********************************************************

Bộ mã hóa video có trạng thái lấy các khung hình video thô theo thứ tự hiển thị và mã hóa
chúng thành một dòng byte. Nó tạo ra các đoạn hoàn chỉnh của dòng byte, bao gồm
tất cả siêu dữ liệu, tiêu đề, v.v. Dòng byte kết quả không yêu cầu bất kỳ
quá trình xử lý hậu kỳ tiếp theo của khách hàng.

Thực hiện xử lý luồng phần mềm, tạo tiêu đề, v.v. trong trình điều khiển
để hỗ trợ giao diện này không được khuyến khích. Trong trường hợp như vậy
cần thực hiện các thao tác, hãy sử dụng Giao diện bộ mã hóa video không trạng thái (trong
phát triển) được khuyến khích mạnh mẽ.

Các quy ước và ký hiệu được sử dụng trong tài liệu này
===============================================

1. Các quy tắc chung của V4L2 API được áp dụng nếu không được chỉ định trong tài liệu này
   mặt khác.

2. Ý nghĩa của các từ "phải", "có thể", "nên", v.v... theo ZZ0000ZZ.

3. Tất cả các bước không được đánh dấu "tùy chọn" là bắt buộc.

4. Có thể sử dụng ZZ0000ZZ và ZZ0001ZZ
   có thể hoán đổi cho nhau với ZZ0002ZZ và ZZ0003ZZ,
   trừ khi có quy định khác.

5. API đơn phẳng (xem ZZ0000ZZ) và các cấu trúc áp dụng có thể
   được sử dụng thay thế cho nhau với API đa mặt phẳng, trừ khi có quy định khác,
   tùy thuộc vào khả năng của bộ mã hóa và tuân theo các nguyên tắc chung của V4L2.

6. i = [a..b]: dãy số nguyên từ a đến b, bao hàm, tức là i =
   [0..2]: i = 0, 1, 2.

7. Cho một bộ đệm ZZ0000ZZ A, thì A' đại diện cho bộ đệm trên ZZ0001ZZ
   hàng đợi chứa dữ liệu thu được từ quá trình xử lý bộ đệm A.

Thuật ngữ
========

Tham khảo ZZ0000ZZ.

Máy trạng thái
=============

.. kernel-render:: DOT
   :alt: DOT digraph of encoder state machine
   :caption: Encoder State Machine

   digraph encoder_state_machine {
       node [shape = doublecircle, label="Encoding"] Encoding;

       node [shape = circle, label="Initialization"] Initialization;
       node [shape = circle, label="Stopped"] Stopped;
       node [shape = circle, label="Drain"] Drain;
       node [shape = circle, label="Reset"] Reset;

       node [shape = point]; qi
       qi -> Initialization [ label = "open()" ];

       Initialization -> Encoding [ label = "Both queues streaming" ];

       Encoding -> Drain [ label = "V4L2_ENC_CMD_STOP" ];
       Encoding -> Reset [ label = "VIDIOC_STREAMOFF(CAPTURE)" ];
       Encoding -> Stopped [ label = "VIDIOC_STREAMOFF(OUTPUT)" ];
       Encoding -> Encoding;

       Drain -> Stopped [ label = "All CAPTURE\nbuffers dequeued\nor\nVIDIOC_STREAMOFF(OUTPUT)" ];
       Drain -> Reset [ label = "VIDIOC_STREAMOFF(CAPTURE)" ];

       Reset -> Encoding [ label = "VIDIOC_STREAMON(CAPTURE)" ];
       Reset -> Initialization [ label = "VIDIOC_REQBUFS(OUTPUT, 0)" ];

       Stopped -> Encoding [ label = "V4L2_ENC_CMD_START\nor\nVIDIOC_STREAMON(OUTPUT)" ];
       Stopped -> Reset [ label = "VIDIOC_STREAMOFF(CAPTURE)" ];
   }

Khả năng truy vấn
=====================

1. Để liệt kê tập hợp các định dạng mã hóa được bộ mã hóa hỗ trợ,
   khách hàng có thể gọi ZZ0000ZZ trên ZZ0001ZZ.

* Tập hợp đầy đủ các định dạng được hỗ trợ sẽ được trả về, bất kể
     định dạng được đặt trên ZZ0000ZZ.

2. Để liệt kê tập hợp các định dạng thô được hỗ trợ, khách hàng có thể gọi
   ZZ0000ZZ trên ZZ0001ZZ.

* Chỉ các định dạng được hỗ trợ cho định dạng hiện đang hoạt động trên ZZ0000ZZ
     sẽ được trả lại.

* Để liệt kê các định dạng thô được hỗ trợ bởi một định dạng mã hóa nhất định,
     trước tiên khách hàng phải đặt định dạng được mã hóa đó trên ZZ0000ZZ và sau đó
     liệt kê các định dạng trên ZZ0001ZZ.

3. Máy khách có thể sử dụng ZZ0000ZZ để phát hiện các thiết bị được hỗ trợ
   độ phân giải cho một định dạng nhất định, chuyển định dạng pixel mong muốn sang
   ZZ0001ZZ ZZ0002ZZ.

* Giá trị được ZZ0000ZZ trả về cho pixel được mã hóa
     định dạng sẽ bao gồm tất cả các độ phân giải được mã hóa có thể được hỗ trợ bởi
     bộ mã hóa cho định dạng pixel được mã hóa nhất định.

* Các giá trị được ZZ0000ZZ trả về cho định dạng pixel thô
     sẽ bao gồm tất cả các độ phân giải bộ đệm khung có thể được hỗ trợ bởi
     bộ mã hóa cho định dạng pixel thô nhất định và định dạng được mã hóa hiện được đặt trên
     ZZ0001ZZ.

4. Khách hàng có thể sử dụng ZZ0000ZZ để phát hiện các thiết bị được hỗ trợ
   khoảng thời gian khung hình cho một định dạng và độ phân giải nhất định, chuyển pixel mong muốn
   định dạng trong ZZ0001ZZ ZZ0004ZZ và độ phân giải
   trong ZZ0002ZZ ZZ0005ZZ và ZZ0003ZZ
   ZZ0006ZZ.

* Giá trị được ZZ0000ZZ trả về cho pixel được mã hóa
     định dạng và độ phân giải được mã hóa sẽ bao gồm tất cả các khoảng thời gian khung hình có thể
     được bộ mã hóa hỗ trợ cho định dạng và độ phân giải pixel được mã hóa nhất định.

* Giá trị được ZZ0000ZZ trả về cho pixel thô
     định dạng và độ phân giải sẽ bao gồm tất cả các khoảng thời gian khung hình có thể được hỗ trợ
     bởi bộ mã hóa cho định dạng và độ phân giải pixel thô nhất định và cho
     định dạng được mã hóa, độ phân giải được mã hóa và khoảng thời gian khung được mã hóa hiện được đặt trên
     ZZ0001ZZ.

* Hỗ trợ cho ZZ0000ZZ là tùy chọn. Nếu nó là
     không được thực hiện thì không có hạn chế đặc biệt nào ngoài
     giới hạn của chính codec.

5. Cấu hình và cấp độ được hỗ trợ cho định dạng mã hóa hiện được đặt trên
   ZZ0001ZZ, nếu có, có thể được truy vấn bằng cách sử dụng các điều khiển tương ứng của chúng
   thông qua ZZ0000ZZ.

6. Mọi khả năng mã hóa bổ sung có thể được phát hiện bằng cách truy vấn
   điều khiển tương ứng của họ.

Khởi tạo
==============

1. Đặt định dạng được mã hóa trên hàng đợi ZZ0001ZZ thông qua ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         định dạng mã hóa sẽ được sản xuất.

ZZ0000ZZ
         kích thước mong muốn của bộ đệm ZZ0001ZZ; bộ mã hóa có thể điều chỉnh nó thành
         phù hợp với yêu cầu phần cứng.

ZZ0000ZZ, ZZ0001ZZ
         bị bỏ qua (chỉ đọc).

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
         kích thước được điều chỉnh của bộ đệm ZZ0001ZZ.

ZZ0000ZZ, ZZ0001ZZ
         kích thước mã hóa được bộ mã hóa lựa chọn dựa trên trạng thái hiện tại, ví dụ:
         Định dạng ZZ0002ZZ, hình chữ nhật lựa chọn, v.v. (chỉ đọc).

   .. important::

      Changing the ``CAPTURE`` format may change the currently set ``OUTPUT``
      format. How the new ``OUTPUT`` format is determined is up to the encoder
      and the client must ensure it matches its needs afterwards.

2. ZZ0002ZZ Liệt kê các định dạng ZZ0001ZZ được hỗ trợ (định dạng thô cho
   nguồn) cho định dạng mã hóa đã chọn qua ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
         định dạng thô được hỗ trợ cho định dạng mã hóa hiện được chọn trên
         hàng đợi ZZ0001ZZ.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

3. Đặt định dạng nguồn thô trên hàng đợi ZZ0001ZZ thông qua
   ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         định dạng thô của nguồn.

ZZ0000ZZ, ZZ0001ZZ
         độ phân giải nguồn

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0001ZZ, ZZ0002ZZ
         có thể được điều chỉnh để phù hợp với mức tối thiểu, mức tối đa và căn chỉnh của bộ mã hóa
         yêu cầu, theo yêu cầu của các định dạng hiện được chọn, như
         được báo cáo bởi ZZ0000ZZ.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* Đặt định dạng ZZ0000ZZ sẽ đặt lại các hình chữ nhật được chọn về vị trí của chúng
     giá trị mặc định, dựa trên độ phân giải mới, như được mô tả trong phần tiếp theo
     bước.

4. Đặt khoảng thời gian khung thô trên hàng đợi ZZ0001ZZ thông qua
   ZZ0000ZZ. Điều này cũng đặt khoảng thời gian khung được mã hóa trên
   Hàng đợi ZZ0002ZZ có cùng giá trị.

* ZZ0000ZZ

ZZ0000ZZ
	 một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
	 đặt tất cả các trường ngoại trừ ZZ0001ZZ thành 0.

ZZ0000ZZ
	 khoảng thời gian khung hình mong muốn; bộ mã hóa có thể điều chỉnh nó thành
	 phù hợp với yêu cầu phần cứng.

* ZZ0000ZZ

ZZ0000ZZ
	 khoảng thời gian khung được điều chỉnh.

   .. important::

      Changing the ``OUTPUT`` frame interval *also* sets the framerate that
      the encoder uses to encode the video. So setting the frame interval
      to 1/24 (or 24 frames per second) will produce a coded video stream
      that can be played back at that speed. The frame interval for the
      ``OUTPUT`` queue is just a hint, the application may provide raw
      frames at a different rate. It can be used by the driver to help
      schedule multiple encoders running in parallel.

      In the next step the ``CAPTURE`` frame interval can optionally be
      changed to a different value. This is useful for off-line encoding
      were the coded frame interval can be different from the rate at
      which raw frames are supplied.

   .. important::

      ``timeperframe`` deals with *frames*, not fields. So for interlaced
      formats this is the time per two fields, since a frame consists of
      a top and a bottom field.

   .. note::

      It is due to historical reasons that changing the ``OUTPUT`` frame
      interval also changes the coded frame interval on the ``CAPTURE``
      queue. Ideally these would be independent settings, but that would
      break the existing API.

5. ZZ0003ZZ Đặt khoảng thời gian khung được mã hóa trên hàng đợi ZZ0002ZZ thông qua
   ZZ0000ZZ. Điều này chỉ cần thiết nếu khung được mã hóa
   khoảng thời gian khác với khoảng thời gian khung hình thô, thường là
   trường hợp mã hóa ngoại tuyến. Hỗ trợ cho tính năng này được báo hiệu
   bằng cờ định dạng ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
	 một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
	 đặt tất cả các trường ngoại trừ ZZ0001ZZ thành 0.

ZZ0000ZZ
	 khoảng thời gian khung được mã hóa mong muốn; bộ mã hóa có thể điều chỉnh nó thành
	 phù hợp với yêu cầu phần cứng.

* ZZ0000ZZ

ZZ0000ZZ
	 khoảng thời gian khung được điều chỉnh.

   .. important::

      Changing the ``CAPTURE`` frame interval sets the framerate for the
      coded video. It does *not* set the rate at which buffers arrive on the
      ``CAPTURE`` queue, that depends on how fast the encoder is and how
      fast raw frames are queued on the ``OUTPUT`` queue.

   .. important::

      ``timeperframe`` deals with *frames*, not fields. So for interlaced
      formats this is the time per two fields, since a frame consists of
      a top and a bottom field.

   .. note::

      Not all drivers support this functionality, in that case just set
      the desired coded frame interval for the ``OUTPUT`` queue.

      However, drivers that can schedule multiple encoders based on the
      ``OUTPUT`` frame interval must support this optional feature.

6. ZZ0002ZZ Đặt độ phân giải hiển thị cho siêu dữ liệu luồng thông qua
   ZZ0000ZZ trên hàng đợi ZZ0001ZZ nếu muốn
   khác với độ phân giải OUTPUT đầy đủ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         được đặt thành ZZ0001ZZ.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
         hình chữ nhật có thể nhìn thấy; cái này phải vừa với ZZ0004ZZ
         hình chữ nhật và có thể được điều chỉnh để phù hợp với codec và
         hạn chế về phần cứng.

* ZZ0000ZZ

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
         hình chữ nhật có thể nhìn thấy được điều chỉnh bởi bộ mã hóa.

* Các mục tiêu lựa chọn sau được hỗ trợ trên ZZ0000ZZ:

ZZ0000ZZ
         bằng khung nguồn đầy đủ, khớp với ZZ0001ZZ đang hoạt động
         định dạng.

ZZ0000ZZ
         bằng ZZ0001ZZ.

ZZ0000ZZ
         hình chữ nhật trong bộ đệm nguồn được mã hóa vào
         Luồng ZZ0001ZZ; mặc định là ZZ0002ZZ.

         .. note::

            A common use case for this selection target is encoding a source
            video with a resolution that is not a multiple of a macroblock,
            e.g.  the common 1920x1080 resolution may require the source
            buffers to be aligned to 1920x1088 for codecs with 16x16 macroblock
            size. To avoid encoding the padding, the client needs to explicitly
            configure this selection target to 1920x1080.

   .. warning::

      The encoder may adjust the crop/compose rectangles to the nearest
      supported ones to meet codec and hardware requirements. The client needs
      to check the adjusted rectangle returned by :c:func:`VIDIOC_S_SELECTION`.

7. Phân bổ bộ đệm cho cả ZZ0001ZZ và ZZ0002ZZ thông qua
   ZZ0000ZZ. Điều này có thể được thực hiện theo bất kỳ thứ tự nào.

* ZZ0000ZZ

ZZ0000ZZ
         số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ hoặc
         ZZ0003ZZ.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm thực tế được phân bổ.

   .. warning::

      The actual number of allocated buffers may differ from the ``count``
      given. The client must check the updated value of ``count`` after the
      call returns.

   .. note::

      To allocate more than the minimum number of OUTPUT buffers (for pipeline
      depth), the client may query the ``V4L2_CID_MIN_BUFFERS_FOR_OUTPUT``
      control to get the minimum number of buffers required, and pass the
      obtained value plus the number of additional buffers needed in the
      ``count`` field to :c:func:`VIDIOC_REQBUFS`.

Ngoài ra, ZZ0000ZZ có thể được sử dụng để có thêm
   kiểm soát việc cấp phát bộ đệm.

* ZZ0000ZZ

ZZ0000ZZ
         số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
         được điều chỉnh theo số lượng bộ đệm được phân bổ.

8. Bắt đầu phát trực tuyến trên cả hàng đợi ZZ0001ZZ và ZZ0002ZZ qua
   ZZ0000ZZ. Điều này có thể được thực hiện theo bất kỳ thứ tự nào. thực tế
   quá trình mã hóa bắt đầu khi cả hai hàng đợi bắt đầu truyền phát.

.. note::

   If the client stops the ``CAPTURE`` queue during the encode process and then
   restarts it again, the encoder will begin generating a stream independent
   from the stream generated before the stop. The exact constraints depend
   on the coded format, but may include the following implications:

   * encoded frames produced after the restart must not reference any
     frames produced before the stop, e.g. no long term references for
     H.264/HEVC,

   * any headers that must be included in a standalone stream must be
     produced again, e.g. SPS and PPS for H.264/HEVC.

Mã hóa
========

Trạng thái này đạt được sau khi chuỗi ZZ0002ZZ kết thúc
thành công.  Ở trạng thái này, máy khách xếp hàng và loại bỏ bộ đệm cho cả hai
hàng đợi qua ZZ0000ZZ và ZZ0001ZZ, theo
ngữ nghĩa tiêu chuẩn.

Nội dung của bộ đệm ZZ0000ZZ được mã hóa phụ thuộc vào pixel được mã hóa hoạt động
định dạng và có thể bị ảnh hưởng bởi các điều khiển mở rộng dành riêng cho codec, như đã nêu
trong tài liệu của từng định dạng.

Cả hai hàng đợi hoạt động độc lập, tuân theo hành vi tiêu chuẩn của bộ đệm V4L2
hàng đợi và các thiết bị chuyển bộ nhớ sang bộ nhớ. Ngoài ra, thứ tự của các khung được mã hóa
được loại bỏ khỏi hàng đợi ZZ0000ZZ có thể khác với thứ tự xếp hàng thô
khung vào hàng đợi ZZ0001ZZ, do thuộc tính của định dạng mã hóa đã chọn,
ví dụ: sắp xếp lại khung.

Khách hàng không được thừa nhận bất kỳ mối quan hệ trực tiếp nào giữa ZZ0000ZZ và
Bộ đệm ZZ0001ZZ và bất kỳ thời gian cụ thể nào của bộ đệm trở thành
có sẵn để dequeue. Cụ thể:

* một bộ đệm được xếp hàng đợi tới ZZ0000ZZ có thể dẫn đến nhiều hơn một bộ đệm được tạo trên
  ZZ0001ZZ (ví dụ: nếu trả về khung được mã hóa cho phép bộ mã hóa
  để trả về một khung trước nó được hiển thị nhưng đã thành công trong việc giải mã
  đặt hàng; tuy nhiên, cũng có thể có những lý do khác cho việc này),

* bộ đệm được xếp hàng đợi tới ZZ0000ZZ có thể dẫn đến việc bộ đệm được tạo trên
  ZZ0001ZZ sau đó vào quá trình mã hóa và/hoặc sau khi xử lý thêm
  Bộ đệm ZZ0002ZZ hoặc bị trả lại không theo thứ tự, ví dụ: nếu hiển thị
  sắp xếp lại được sử dụng,

* bộ đệm có thể có sẵn trên hàng đợi ZZ0000ZZ mà không cần bổ sung
  bộ đệm được xếp hàng đợi tới ZZ0001ZZ (ví dụ: trong khi thoát hoặc ZZ0002ZZ), do
  Bộ đệm ZZ0003ZZ được xếp hàng đợi trong quá khứ có kết quả mã hóa chỉ
  có sẵn sau này, do đặc thù của quá trình mã hóa,

* bộ đệm được xếp hàng đợi vào ZZ0000ZZ có thể không có sẵn để loại bỏ hàng đợi ngay lập tức
  sau khi được mã hóa vào bộ đệm ZZ0001ZZ tương ứng, ví dụ: nếu
  bộ mã hóa cần sử dụng khung làm tham chiếu để mã hóa các khung tiếp theo.

.. note::

   To allow matching encoded ``CAPTURE`` buffers with ``OUTPUT`` buffers they
   originated from, the client can set the ``timestamp`` field of the
   :c:type:`v4l2_buffer` struct when queuing an ``OUTPUT`` buffer. The
   ``CAPTURE`` buffer(s), which resulted from encoding that ``OUTPUT`` buffer
   will have their ``timestamp`` field set to the same value when dequeued.

   In addition to the straightforward case of one ``OUTPUT`` buffer producing
   one ``CAPTURE`` buffer, the following cases are defined:

   * one ``OUTPUT`` buffer generates multiple ``CAPTURE`` buffers: the same
     ``OUTPUT`` timestamp will be copied to multiple ``CAPTURE`` buffers,

   * the encoding order differs from the presentation order (i.e. the
     ``CAPTURE`` buffers are out-of-order compared to the ``OUTPUT`` buffers):
     ``CAPTURE`` timestamps will not retain the order of ``OUTPUT`` timestamps.

.. note::

   To let the client distinguish between frame types (keyframes, intermediate
   frames; the exact list of types depends on the coded format), the
   ``CAPTURE`` buffers will have corresponding flag bits set in their
   :c:type:`v4l2_buffer` struct when dequeued. See the documentation of
   :c:type:`v4l2_buffer` and each coded pixel format for exact list of flags
   and their meanings.

Nếu xảy ra lỗi mã hóa, nó sẽ được thông báo cho khách hàng với mức độ
chi tiết tùy thuộc vào khả năng của bộ mã hóa. Cụ thể:

* bộ đệm ZZ0000ZZ (nếu có) chứa kết quả mã hóa không thành công
  hoạt động sẽ được trả về với bộ cờ ZZ0001ZZ,

* nếu bộ mã hóa có thể báo cáo chính xác (các) bộ đệm ZZ0000ZZ đã kích hoạt
  lỗi, (các) bộ đệm đó sẽ được trả về cùng với cờ ZZ0001ZZ
  thiết lập.

.. note::

   If a ``CAPTURE`` buffer is too small then it is just returned with the
   ``V4L2_BUF_FLAG_ERROR`` flag set. More work is needed to detect that this
   error occurred because the buffer was too small, and to provide support to
   free existing buffers that were too small.

Trong trường hợp xảy ra lỗi nghiêm trọng khiến quá trình mã hóa không thể tiếp tục, bất kỳ
các thao tác tiếp theo trên phần xử lý tệp bộ mã hóa tương ứng sẽ trả về -EIO
mã lỗi. Máy khách có thể đóng phần xử lý tệp và mở một phần mới, hoặc
cách khác là khởi tạo lại phiên bản bằng cách dừng phát trực tuyến trên cả hai hàng đợi,
giải phóng tất cả bộ đệm và thực hiện lại trình tự Khởi tạo.

Thay đổi thông số mã hóa
==========================

Khách hàng được phép sử dụng ZZ0000ZZ để thay đổi bộ mã hóa
các thông số bất cứ lúc nào. Tính khả dụng của các tham số dành riêng cho bộ mã hóa
và khách hàng phải truy vấn bộ mã hóa để tìm bộ điều khiển có sẵn.

Khả năng thay đổi từng tham số trong quá trình mã hóa là dành riêng cho bộ mã hóa, vì
theo ngữ nghĩa tiêu chuẩn của giao diện điều khiển V4L2. Khách hàng có thể
cố gắng thiết lập điều khiển trong quá trình mã hóa và nếu thao tác không thành công với
-Mã lỗi -EBUSY, hàng đợi ZZ0000ZZ cần được dừng lại để
cho phép thay đổi cấu hình. Để làm điều này, nó có thể tuân theo ZZ0001ZZ
trình tự để tránh mất các khung đã được xếp hàng/mã hóa.

Thời gian cập nhật tham số dành riêng cho bộ mã hóa, theo tiêu chuẩn
ngữ nghĩa của giao diện điều khiển V4L2. Nếu khách hàng có nhu cầu áp dụng
tham số chính xác ở khung cụ thể, sử dụng Yêu cầu API
(ZZ0000ZZ) nên được xem xét nếu được bộ mã hóa hỗ trợ.

Làm khô hạn
=====

Để đảm bảo rằng tất cả các bộ đệm ZZ0000ZZ được xếp hàng đợi đã được xử lý và
bộ đệm ZZ0001ZZ liên quan được cung cấp cho máy khách, máy khách phải tuân theo
trình tự thoát nước được mô tả dưới đây. Sau khi trình tự xả kết thúc, khách hàng có
đã nhận được tất cả các khung được mã hóa cho tất cả bộ đệm ZZ0002ZZ được xếp hàng đợi trước
trình tự đã được bắt đầu.

1. Bắt đầu trình tự xả bằng cách phát hành ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         được đặt thành ZZ0001ZZ.

ZZ0000ZZ
         đặt thành 0.

ZZ0000ZZ
         đặt thành 0.

   .. warning::

      The sequence can be only initiated if both ``OUTPUT`` and ``CAPTURE``
      queues are streaming. For compatibility reasons, the call to
      :c:func:`VIDIOC_ENCODER_CMD` will not fail even if any of the queues is
      not streaming, but at the same time it will not initiate the `Drain`
      sequence and so the steps described below would not be applicable.

2. Bất kỳ bộ đệm ZZ0001ZZ nào được khách hàng xếp hàng trước
   ZZ0000ZZ được phát hành sẽ được xử lý và mã hóa dưới dạng
   bình thường. Máy khách phải tiếp tục xử lý cả hai hàng đợi một cách độc lập,
   tương tự như hoạt động mã hóa thông thường. Điều này bao gồm:

* xếp hàng và loại bỏ bộ đệm ZZ0000ZZ, cho đến khi bộ đệm được đánh dấu bằng
     Cờ ZZ0001ZZ bị loại bỏ,

     .. warning::

        The last buffer may be empty (with :c:type:`v4l2_buffer`
        ``bytesused`` = 0) and in that case it must be ignored by the client,
        as it does not contain an encoded frame.

     .. note::

        Any attempt to dequeue more ``CAPTURE`` buffers beyond the buffer
        marked with ``V4L2_BUF_FLAG_LAST`` will result in a -EPIPE error from
        :c:func:`VIDIOC_DQBUF`.

* loại bỏ các bộ đệm ZZ0000ZZ đã xử lý, cho đến khi tất cả các bộ đệm được xếp hàng đợi
     trước khi lệnh ZZ0001ZZ bị loại bỏ,

* loại bỏ sự kiện ZZ0000ZZ, nếu khách hàng đăng ký sự kiện đó.

   .. note::

      For backwards compatibility, the encoder will signal a ``V4L2_EVENT_EOS``
      event when the last frame has been encoded and all frames are ready to be
      dequeued. It is deprecated behavior and the client must not rely on it.
      The ``V4L2_BUF_FLAG_LAST`` buffer flag should be used instead.

3. Khi tất cả bộ đệm ZZ0000ZZ được xếp hàng trước lệnh gọi ZZ0001ZZ được
   bị loại bỏ và bộ đệm ZZ0002ZZ cuối cùng bị loại bỏ, bộ mã hóa bị dừng
   và nó sẽ chấp nhận, nhưng không xử lý bất kỳ bộ đệm ZZ0003ZZ mới được xếp hàng nào
   cho đến khi khách hàng thực hiện bất kỳ thao tác nào sau đây:

* ZZ0000ZZ - bộ mã hóa sẽ không được đặt lại và sẽ tiếp tục
     hoạt động bình thường, với mọi trạng thái từ trước khi xả,

* một cặp ZZ0000ZZ và ZZ0001ZZ trên
     Hàng đợi ZZ0002ZZ - bộ mã hóa sẽ được đặt lại (xem trình tự ZZ0003ZZ)
     và sau đó tiếp tục mã hóa,

* một cặp ZZ0000ZZ và ZZ0001ZZ trên
     Hàng đợi ZZ0003ZZ - bộ mã hóa sẽ tiếp tục hoạt động bình thường, tuy nhiên bất kỳ
     các khung nguồn được xếp hàng vào hàng đợi ZZ0004ZZ giữa ZZ0005ZZ
     và ZZ0002ZZ sẽ bị loại bỏ.

.. note::

   Once the drain sequence is initiated, the client needs to drive it to
   completion, as described by the steps above, unless it aborts the process by
   issuing :c:func:`VIDIOC_STREAMOFF` on any of the ``OUTPUT`` or ``CAPTURE``
   queues.  The client is not allowed to issue ``V4L2_ENC_CMD_START`` or
   ``V4L2_ENC_CMD_STOP`` again while the drain sequence is in progress and they
   will fail with -EBUSY error code if attempted.

   For reference, handling of various corner cases is described below:

   * In case of no buffer in the ``OUTPUT`` queue at the time the
     ``V4L2_ENC_CMD_STOP`` command was issued, the drain sequence completes
     immediately and the encoder returns an empty ``CAPTURE`` buffer with the
     ``V4L2_BUF_FLAG_LAST`` flag set.

   * In case of no buffer in the ``CAPTURE`` queue at the time the drain
     sequence completes, the next time the client queues a ``CAPTURE`` buffer
     it is returned at once as an empty buffer with the ``V4L2_BUF_FLAG_LAST``
     flag set.

   * If :c:func:`VIDIOC_STREAMOFF` is called on the ``CAPTURE`` queue in the
     middle of the drain sequence, the drain sequence is canceled and all
     ``CAPTURE`` buffers are implicitly returned to the client.

   * If :c:func:`VIDIOC_STREAMOFF` is called on the ``OUTPUT`` queue in the
     middle of the drain sequence, the drain sequence completes immediately and
     next ``CAPTURE`` buffer will be returned empty with the
     ``V4L2_BUF_FLAG_LAST`` flag set.

   Although not mandatory, the availability of encoder commands may be queried
   using :c:func:`VIDIOC_TRY_ENCODER_CMD`.

Cài lại
=====

Máy khách có thể muốn yêu cầu bộ mã hóa khởi tạo lại quá trình mã hóa, vì vậy
dữ liệu luồng sau trở nên độc lập với dữ liệu luồng
tạo ra trước đó. Tùy thuộc vào định dạng được mã hóa, điều đó có thể ngụ ý rằng:

* các khung được mã hóa được tạo sau khi khởi động lại không được tham chiếu bất kỳ khung nào
  được sản xuất trước khi dừng, ví dụ: không có tài liệu tham khảo dài hạn cho H.264/HEVC,

* mọi tiêu đề phải được đưa vào luồng độc lập đều phải được tạo
  một lần nữa, ví dụ. SPS và PPS cho H.264/HEVC.

Điều này có thể đạt được bằng cách thực hiện trình tự thiết lập lại.

1. Thực hiện trình tự ZZ0000ZZ để đảm bảo tất cả quá trình mã hóa đang diễn ra đều hoàn tất
   và bộ đệm tương ứng được loại bỏ.

2. Dừng phát trực tuyến trên hàng đợi ZZ0001ZZ qua ZZ0000ZZ. Cái này
   sẽ trả lại tất cả các bộ đệm ZZ0002ZZ hiện đang được xếp hàng đợi cho máy khách mà không cần
   dữ liệu khung hợp lệ.

3. Bắt đầu phát trực tuyến trên hàng đợi ZZ0001ZZ qua ZZ0000ZZ và
   tiếp tục với chuỗi mã hóa thông thường. Các khung được mã hóa được tạo thành
   Bộ đệm ZZ0002ZZ từ giờ trở đi sẽ chứa một luồng độc lập có thể
   được giải mã mà không cần các khung được mã hóa trước trình tự đặt lại,
   bắt đầu từ bộ đệm ZZ0003ZZ đầu tiên được xếp hàng sau khi phát hành
   ZZ0004ZZ của chuỗi ZZ0005ZZ.

Trình tự này cũng có thể được sử dụng để thay đổi các tham số mã hóa cho bộ mã hóa
không có khả năng thay đổi các thông số một cách nhanh chóng.

Điểm cam kết
=============

Việc thiết lập các định dạng và phân bổ bộ đệm sẽ kích hoạt những thay đổi trong hành vi của
bộ mã hóa.

1. Đặt định dạng trên hàng đợi ZZ0000ZZ có thể thay đổi bộ định dạng
   được hỗ trợ/quảng cáo trên hàng đợi ZZ0001ZZ. Đặc biệt, nó còn có nghĩa
   rằng định dạng ZZ0002ZZ có thể được đặt lại và máy khách không được dựa vào
   định dạng đã đặt trước đó được giữ nguyên.

2. Việc liệt kê các định dạng trên hàng đợi ZZ0000ZZ luôn chỉ trả về các định dạng
   được hỗ trợ cho định dạng ZZ0001ZZ hiện tại.

3. Đặt định dạng trên hàng đợi ZZ0000ZZ không làm thay đổi danh sách
   các định dạng có sẵn trên hàng đợi ZZ0001ZZ. Một nỗ lực để thiết lập ZZ0002ZZ
   định dạng không được hỗ trợ cho định dạng ZZ0003ZZ hiện được chọn
   sẽ dẫn đến việc bộ mã hóa điều chỉnh định dạng ZZ0004ZZ được yêu cầu thành định dạng
   được hỗ trợ một.

4. Việc liệt kê các định dạng trên hàng đợi ZZ0000ZZ luôn trả về tập hợp đầy đủ các
   các định dạng được mã hóa được hỗ trợ, bất kể định dạng ZZ0001ZZ hiện tại.

5. Trong khi bộ đệm được phân bổ trên bất kỳ hàng đợi ZZ0000ZZ hoặc ZZ0001ZZ nào,
   máy khách không được thay đổi định dạng trên hàng đợi ZZ0002ZZ. Người lái xe sẽ
   trả lại mã lỗi -EBUSY cho bất kỳ nỗ lực thay đổi định dạng nào như vậy.

Tóm lại, việc thiết lập định dạng và phân bổ phải luôn bắt đầu bằng
Hàng đợi ZZ0000ZZ và hàng đợi ZZ0001ZZ là chủ quản lý
tập hợp các định dạng được hỗ trợ cho hàng đợi ZZ0002ZZ.