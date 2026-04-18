.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/dev-decoder.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _decoder:

*************************************************
Giao diện bộ giải mã video trạng thái từ bộ nhớ đến bộ nhớ
*************************************************

Bộ giải mã video có trạng thái lấy các đoạn hoàn chỉnh của dòng byte (ví dụ: Phụ lục-B
luồng H.264/HEVC, luồng VP8/9 thô) và giải mã chúng thành các khung hình video thô trong
thứ tự hiển thị. Bộ giải mã dự kiến sẽ không yêu cầu bất kỳ thông tin bổ sung nào
từ máy khách để xử lý các bộ đệm này.

Thực hiện phân tích cú pháp phần mềm, xử lý, v.v. của luồng trong trình điều khiển trong
để hỗ trợ giao diện này không được khuyến khích. Trong trường hợp như vậy
cần thực hiện các thao tác, hãy sử dụng Giao diện bộ giải mã video không trạng thái (trong
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
   tùy thuộc vào khả năng của bộ giải mã và tuân theo các nguyên tắc chung của V4L2.

6. i = [a..b]: dãy số nguyên từ a đến b, bao hàm, tức là i =
   [0..2]: i = 0, 1, 2.

7. Cho một bộ đệm ZZ0000ZZ A, thì A' đại diện cho bộ đệm trên ZZ0001ZZ
   hàng đợi chứa dữ liệu thu được từ quá trình xử lý bộ đệm A.

.. _decoder-glossary:

Thuật ngữ
========

CAPTURE
   hàng đợi bộ đệm đích; đối với bộ giải mã, hàng đợi các bộ đệm chứa
   khung được giải mã; đối với bộ mã hóa, hàng đợi bộ đệm chứa dữ liệu được mã hóa
   dòng byte; ZZ0000ZZ hoặc
   ZZ0001ZZ; dữ liệu được lấy từ phần cứng
   vào bộ đệm ZZ0002ZZ.

khách hàng
   ứng dụng giao tiếp với bộ giải mã hoặc bộ mã hóa đang thực hiện
   giao diện này.

định dạng được mã hóa
   định dạng dòng byte video được mã hóa/nén (ví dụ: H.264, VP8, v.v.); xem
   Ngoài ra: định dạng thô.

chiều cao được mã hóa
   chiều cao cho độ phân giải được mã hóa nhất định.

độ phân giải được mã hóa
   độ phân giải luồng theo pixel được căn chỉnh theo yêu cầu về codec và phần cứng;
   độ phân giải hiển thị thường được làm tròn thành macroblock đầy đủ;
   xem thêm: độ phân giải nhìn thấy được.

chiều rộng được mã hóa
   chiều rộng cho độ phân giải được mã hóa nhất định.

đơn vị cây mã hóa
   bộ xử lý của codec HEVC (tương ứng với các đơn vị macroblock trong
   H.264, VP8, VP9),
   có thể sử dụng cấu trúc khối lên tới 64 × 64 pixel.
   Giỏi phân vùng hình ảnh thành các cấu trúc có kích thước thay đổi.

giải mã thứ tự
   thứ tự các khung được giải mã; có thể khác với thứ tự hiển thị nếu
   định dạng được mã hóa bao gồm tính năng sắp xếp lại khung; cho bộ giải mã,
   Bộ đệm ZZ0000ZZ phải được khách hàng xếp hàng theo thứ tự giải mã; cho
   bộ mã hóa Bộ đệm ZZ0001ZZ phải được bộ mã hóa trả về theo thứ tự giải mã.

điểm đến
   dữ liệu thu được từ quá trình giải mã; xem ZZ0000ZZ.

thứ tự hiển thị
   thứ tự các khung phải được hiển thị; cho bộ mã hóa, ZZ0000ZZ
   bộ đệm phải được khách hàng xếp hàng theo thứ tự hiển thị; cho bộ giải mã,
   Bộ đệm ZZ0001ZZ phải được bộ giải mã trả về theo thứ tự hiển thị.

DPB
   Bộ đệm hình ảnh được giải mã; thuật ngữ H.264/HEVC cho bộ đệm lưu trữ dữ liệu được giải mã
   khung thô có sẵn để tham khảo trong các bước giải mã tiếp theo.

EOS
   cuối luồng.

IDR
   Làm mới bộ giải mã tức thời; một loại khung hình chính trong mã hóa H.264/HEVC
   luồng này sẽ xóa danh sách các khung tham chiếu trước đó (DPB).

khung hình chính
   một khung được mã hóa không tham chiếu các khung được giải mã trước đó, tức là
   có thể được giải mã hoàn toàn.

khối macro
   một đơn vị xử lý ở các định dạng nén hình ảnh và video dựa trên tuyến tính
   biến đổi khối (ví dụ: H.264, VP8, VP9); codec cụ thể, nhưng đối với hầu hết
   codec phổ biến có kích thước mẫu là 16x16 (pixel). Bộ giải mã HEVC sử dụng một
   đơn vị xử lý linh hoạt hơn một chút được gọi là đơn vị cây mã hóa (CTU).

OUTPUT
   hàng đợi bộ đệm nguồn; đối với bộ giải mã, hàng đợi các bộ đệm chứa
   một dòng byte được mã hóa; đối với bộ mã hóa, hàng đợi bộ đệm chứa dữ liệu thô
   khung; ZZ0000ZZ hoặc
   ZZ0001ZZ; phần cứng được cung cấp dữ liệu
   từ bộ đệm ZZ0002ZZ.

PPS
   Bộ thông số hình ảnh; một loại thực thể siêu dữ liệu trong dòng byte H.264/HEVC.

định dạng thô
   định dạng không nén chứa dữ liệu pixel thô (ví dụ: định dạng YUV, RGB).

điểm tiếp tục
   một điểm trong dòng byte mà từ đó quá trình giải mã có thể bắt đầu/tiếp tục mà không cần
   mọi trạng thái/dữ liệu hiện tại trước đó, ví dụ: khung hình chính (VP8/VP9) hoặc
   Chuỗi SPS/PPS/IDR (H.264/HEVC); cần có điểm tiếp tục để bắt đầu giải mã
   của luồng mới hoặc để tiếp tục giải mã sau khi tìm kiếm.

nguồn
   dữ liệu được đưa đến bộ giải mã hoặc bộ mã hóa; xem ZZ0000ZZ.

chiều cao nguồn
   chiều cao tính bằng pixel cho độ phân giải nguồn nhất định; chỉ liên quan đến bộ mã hóa.

độ phân giải nguồn
   độ phân giải tính bằng pixel của khung nguồn là nguồn cho bộ mã hóa và
   có thể bị cắt xén thêm theo giới hạn của độ phân giải nhìn thấy được; liên quan đến
   chỉ có bộ mã hóa.

chiều rộng nguồn
   chiều rộng tính bằng pixel cho độ phân giải nguồn nhất định; chỉ liên quan đến bộ mã hóa.

SPS
   Bộ tham số trình tự; một loại thực thể siêu dữ liệu trong dòng byte H.264/HEVC.

truyền phát siêu dữ liệu
   thông tin bổ sung (không trực quan) chứa bên trong dòng byte được mã hóa;
   ví dụ: độ phân giải được mã hóa, độ phân giải hiển thị, cấu hình codec.

chiều cao nhìn thấy được
   chiều cao cho độ phân giải có thể nhìn thấy được; chiều cao hiển thị.

độ phân giải nhìn thấy được
   độ phân giải luồng của hình ảnh hiển thị, tính bằng pixel, được sử dụng cho
   mục đích hiển thị; phải nhỏ hơn hoặc bằng độ phân giải được mã hóa;
   độ phân giải hiển thị.

chiều rộng nhìn thấy được
   chiều rộng cho độ phân giải hiển thị nhất định; chiều rộng hiển thị.

Máy trạng thái
=============

.. kernel-render:: DOT
   :alt: DOT digraph of decoder state machine
   :caption: Decoder State Machine

   digraph decoder_state_machine {
       node [shape = doublecircle, label="Decoding"] Decoding;

       node [shape = circle, label="Initialization"] Initialization;
       node [shape = circle, label="Capture\nsetup"] CaptureSetup;
       node [shape = circle, label="Dynamic\nResolution\nChange"] ResChange;
       node [shape = circle, label="Stopped"] Stopped;
       node [shape = circle, label="Drain"] Drain;
       node [shape = circle, label="Seek"] Seek;
       node [shape = circle, label="End of Stream"] EoS;

       node [shape = point]; qi
       qi -> Initialization [ label = "open()" ];

       Initialization -> CaptureSetup [ label = "CAPTURE\nformat\nestablished" ];

       CaptureSetup -> Stopped [ label = "CAPTURE\nbuffers\nready" ];

       Decoding -> ResChange [ label = "Stream\nresolution\nchange" ];
       Decoding -> Drain [ label = "V4L2_DEC_CMD_STOP" ];
       Decoding -> EoS [ label = "EoS mark\nin the stream" ];
       Decoding -> Seek [ label = "VIDIOC_STREAMOFF(OUTPUT)" ];
       Decoding -> Stopped [ label = "VIDIOC_STREAMOFF(CAPTURE)" ];
       Decoding -> Decoding;

       ResChange -> CaptureSetup [ label = "CAPTURE\nformat\nestablished" ];
       ResChange -> Seek [ label = "VIDIOC_STREAMOFF(OUTPUT)" ];

       EoS -> Drain [ label = "Implicit\ndrain" ];

       Drain -> Stopped [ label = "All CAPTURE\nbuffers dequeued\nor\nVIDIOC_STREAMOFF(CAPTURE)" ];
       Drain -> Seek [ label = "VIDIOC_STREAMOFF(OUTPUT)" ];

       Seek -> Decoding [ label = "VIDIOC_STREAMON(OUTPUT)" ];
       Seek -> Initialization [ label = "VIDIOC_REQBUFS(OUTPUT, 0)" ];

       Stopped -> Decoding [ label = "V4L2_DEC_CMD_START\nor\nVIDIOC_STREAMON(CAPTURE)" ];
       Stopped -> Seek [ label = "VIDIOC_STREAMOFF(OUTPUT)" ];
   }

Khả năng truy vấn
=====================

1. Để liệt kê tập hợp các định dạng mã hóa được bộ giải mã hỗ trợ,
   khách hàng có thể gọi ZZ0000ZZ trên ZZ0001ZZ.

* Tập hợp đầy đủ các định dạng được hỗ trợ sẽ được trả về, bất kể
     định dạng được đặt trên ZZ0001ZZ.
   * Kiểm tra trường cờ của ZZ0000ZZ để biết thêm thông tin
     về khả năng của bộ giải mã đối với từng định dạng được mã hóa.
     Cụ thể là bộ giải mã có dòng byte đầy đủ hay không
     trình phân tích cú pháp và liệu bộ giải mã có hỗ trợ thay đổi độ phân giải động hay không.

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
     bộ giải mã cho định dạng pixel được mã hóa nhất định.

* Các giá trị được ZZ0000ZZ trả về cho định dạng pixel thô
     sẽ bao gồm tất cả các độ phân giải bộ đệm khung có thể được hỗ trợ bởi
     bộ giải mã cho định dạng pixel thô nhất định và định dạng được mã hóa hiện được đặt trên
     ZZ0001ZZ.

4. Cấu hình và cấp độ được hỗ trợ cho định dạng mã hóa hiện được đặt trên
   ZZ0001ZZ, nếu có, có thể được truy vấn bằng cách sử dụng các điều khiển tương ứng của chúng
   thông qua ZZ0000ZZ.

Khởi tạo
==============

1. Đặt định dạng mã hóa trên ZZ0001ZZ thông qua ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         một định dạng pixel được mã hóa.

ZZ0000ZZ, ZZ0001ZZ
         độ phân giải được mã hóa của luồng; chỉ được yêu cầu nếu nó không thể được phân tích cú pháp
         từ luồng cho định dạng được mã hóa nhất định; nếu không bộ giải mã sẽ
         sử dụng độ phân giải này làm độ phân giải giữ chỗ có thể sẽ thay đổi
         ngay khi nó có thể phân tích độ phân giải được mã hóa thực tế từ luồng.

ZZ0000ZZ
         kích thước mong muốn của bộ đệm ZZ0001ZZ; bộ giải mã có thể điều chỉnh nó thành
         phù hợp với yêu cầu phần cứng.

các lĩnh vực khác
         tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
         kích thước được điều chỉnh của bộ đệm ZZ0001ZZ.

* Định dạng ZZ0001ZZ sẽ được cập nhật với bộ đệm khung phù hợp
     độ phân giải ngay lập tức dựa trên chiều rộng và chiều cao được trả về bởi
     ZZ0000ZZ.
     Tuy nhiên, đối với các định dạng được mã hóa bao gồm thông tin độ phân giải luồng,
     sau khi bộ giải mã phân tích xong thông tin từ luồng, nó sẽ
     cập nhật định dạng ZZ0002ZZ với các giá trị mới và báo hiệu sự thay đổi nguồn
     sự kiện, bất kể chúng có khớp với các giá trị do khách hàng đặt hay không
     không.

   .. important::

      Changing the ``OUTPUT`` format may change the currently set ``CAPTURE``
      format. How the new ``CAPTURE`` format is determined is up to the decoder
      and the client must ensure it matches its needs afterwards.

2. Phân bổ bộ đệm nguồn (dòng byte) qua ZZ0000ZZ trên
    ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm thực tế được phân bổ.

    .. warning::

       The actual number of allocated buffers may differ from the ``count``
       given. The client must check the updated value of ``count`` after the
       call returns.

Ngoài ra, ZZ0000ZZ trên hàng đợi ZZ0001ZZ có thể
    được sử dụng để có nhiều quyền kiểm soát hơn đối với việc phân bổ bộ đệm.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
          được điều chỉnh theo số lượng bộ đệm được phân bổ.

    .. warning::

       The actual number of allocated buffers may differ from the ``count``
       given. The client must check the updated value of ``count`` after the
       call returns.

3. Bắt đầu phát trực tuyến trên hàng đợi ZZ0001ZZ qua ZZ0000ZZ.

4. **Bước này chỉ áp dụng cho các định dạng được mã hóa có chứa thông tin độ phân giải
    trong luồng.** Tiếp tục xếp hàng/xóa hàng đợi bộ đệm dòng byte đến/từ
    Hàng đợi ZZ0002ZZ qua ZZ0000ZZ và ZZ0001ZZ. các
    bộ đệm sẽ được xử lý và trả lại cho máy khách theo thứ tự, cho đến khi
    Đã tìm thấy siêu dữ liệu cần thiết để định cấu hình hàng đợi ZZ0003ZZ. Đây là
    được chỉ định bởi bộ giải mã gửi sự kiện ZZ0004ZZ với
    ZZ0005ZZ được đặt thành ZZ0006ZZ.

* Sẽ không có lỗi nếu bộ đệm đầu tiên không chứa đủ dữ liệu cho
      điều này xảy ra. Quá trình xử lý bộ đệm sẽ tiếp tục miễn là
      dữ liệu là cần thiết.

* Nếu cần có dữ liệu trong bộ đệm kích hoạt sự kiện để giải mã
      frame đầu tiên, nó sẽ không được trả lại cho client cho đến khi
      trình tự khởi tạo hoàn tất và khung được giải mã.

* Nếu máy khách chưa tự thiết lập độ phân giải được mã hóa của luồng,
      gọi ZZ0000ZZ, ZZ0001ZZ,
      ZZ0002ZZ hoặc ZZ0003ZZ trên ZZ0004ZZ
      hàng đợi sẽ không trả về giá trị thực cho luồng cho đến khi
      Sự kiện ZZ0005ZZ với ZZ0006ZZ được đặt thành
      ZZ0007ZZ được báo hiệu.

    .. important::

       Any client query issued after the decoder queues the event will return
       values applying to the just parsed stream, including queue formats,
       selection rectangles and controls.

    .. note::

       A client capable of acquiring stream parameters from the bytestream on
       its own may attempt to set the width and height of the ``OUTPUT`` format
       to non-zero values matching the coded size of the stream, skip this step
       and continue with the `Capture Setup` sequence. However, it must not
       rely on any driver queries regarding stream parameters, such as
       selection rectangles and controls, since the decoder has not parsed them
       from the stream yet. If the values configured by the client do not match
       those parsed by the decoder, a `Dynamic Resolution Change` will be
       triggered to reconfigure them.

    .. note::

       No decoded frames are produced during this phase.

5. Tiếp tục với trình tự ZZ0000ZZ.

Cài đặt chụp
=============

1. Gọi ZZ0000ZZ trên hàng đợi ZZ0001ZZ để nhận định dạng cho
    bộ đệm đích được phân tích/giải mã từ dòng byte.

* ZZ0000ZZ

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

* ZZ0000ZZ

ZZ0000ZZ, ZZ0001ZZ
          độ phân giải bộ đệm khung cho các khung được giải mã.

ZZ0000ZZ
          định dạng pixel cho khung được giải mã.

ZZ0000ZZ (chỉ dành cho _MPLANE ZZ0001ZZ)
          số lượng mặt phẳng cho định dạng pixel.

ZZ0000ZZ, ZZ0001ZZ
          theo ngữ nghĩa tiêu chuẩn; định dạng bộ đệm khung phù hợp.

    .. note::

       The value of ``pixelformat`` may be any pixel format supported by the
       decoder for the current stream. The decoder should choose a
       preferred/optimal format for the default configuration. For example, a
       YUV format may be preferred over an RGB format if an additional
       conversion step would be required for the latter.

2. ZZ0001ZZ Thu được độ phân giải hiển thị thông qua
    ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          được đặt thành ZZ0001ZZ.

* ZZ0000ZZ

ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ
          hình chữ nhật có thể nhìn thấy; nó phải vừa với độ phân giải của bộ đệm khung
          được trả lại bởi ZZ0000ZZ trên ZZ0005ZZ.

* Các mục tiêu lựa chọn sau được hỗ trợ trên ZZ0000ZZ:

ZZ0000ZZ
          tương ứng với độ phân giải được mã hóa của luồng.

ZZ0000ZZ
          hình chữ nhật bao phủ phần bộ đệm ZZ0001ZZ
          chứa dữ liệu hình ảnh có ý nghĩa (vùng nhìn thấy được); chiều rộng và chiều cao
          sẽ bằng độ phân giải hiển thị của luồng.

ZZ0000ZZ
          hình chữ nhật trong độ phân giải được mã hóa sẽ được xuất ra
          ZZ0001ZZ; mặc định là ZZ0002ZZ; chỉ đọc trên
          phần cứng mà không có khả năng soạn thảo/mở rộng quy mô bổ sung.

ZZ0000ZZ
          hình chữ nhật tối đa trong bộ đệm ZZ0001ZZ, được cắt xén
          khung có thể được sáng tác thành; bằng ZZ0002ZZ nếu
          phần cứng không hỗ trợ soạn thảo/chia tỷ lệ.

ZZ0000ZZ
          bằng ZZ0001ZZ.

ZZ0000ZZ
          hình chữ nhật bên trong bộ đệm ZZ0001ZZ để cắt vào đó
          khung được viết; mặc định là ZZ0002ZZ;
          chỉ đọc trên phần cứng mà không có khả năng soạn thảo/mở rộng quy mô bổ sung.

ZZ0000ZZ
          hình chữ nhật bên trong bộ đệm ZZ0001ZZ được ghi đè bởi
          phần cứng; bằng ZZ0002ZZ nếu phần cứng không
          ghi các pixel đệm.

    .. warning::

       The values are guaranteed to be meaningful only after the decoder
       successfully parses the stream metadata. The client must not rely on the
       query before that happens.

3. ZZ0004ZZ Liệt kê các định dạng ZZ0002ZZ thông qua ZZ0000ZZ trên
    hàng đợi ZZ0003ZZ. Sau khi thông tin luồng được phân tích cú pháp và biết,
    khách hàng có thể sử dụng ioctl này để khám phá những định dạng thô nào được hỗ trợ cho
    luồng đã cho và chọn một trong số chúng thông qua ZZ0001ZZ.

    .. important::

       The decoder will return only formats supported for the currently
       established coded format, as per the ``OUTPUT`` format and/or stream
       metadata parsed in this initialization sequence, even if more formats
       may be supported by the decoder in general. In other words, the set
       returned will be a subset of the initial query mentioned in the
       `Querying Capabilities` section.

       For example, a decoder may support YUV and RGB formats for resolutions
       1920x1088 and lower, but only YUV for higher resolutions (due to
       hardware limitations). After parsing a resolution of 1920x1088 or lower,
       :c:func:`VIDIOC_ENUM_FMT` may return a set of YUV and RGB pixel formats,
       but after parsing resolution higher than 1920x1088, the decoder will not
       return RGB, unsupported for this resolution.

       However, subsequent resolution change event triggered after
       discovering a resolution change within the same stream may switch
       the stream into a lower resolution and :c:func:`VIDIOC_ENUM_FMT`
       would return RGB formats again in that case.

4. ZZ0004ZZ Đặt định dạng ZZ0002ZZ qua ZZ0000ZZ trên
    Hàng đợi ZZ0003ZZ. Khách hàng có thể chọn một định dạng khác với
    được bộ giải mã chọn/đề xuất trong ZZ0001ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          một định dạng pixel thô.

ZZ0001ZZ, ZZ0002ZZ
         độ phân giải bộ đệm khung của luồng được giải mã; thường không thay đổi so với
	 những gì đã được trả lại với ZZ0000ZZ, nhưng nó có thể khác
	 liệu phần cứng có hỗ trợ bố cục và/hoặc chia tỷ lệ hay không.

* Đặt định dạng ZZ0000ZZ sẽ đặt lại các hình chữ nhật lựa chọn soạn thư
     về giá trị mặc định của chúng, dựa trên độ phân giải mới, như được mô tả trong
     bước trước đó.

5. ZZ0002ZZ Đặt hình chữ nhật soạn thư qua ZZ0000ZZ trên
   hàng đợi ZZ0001ZZ nếu muốn và nếu bộ giải mã đã soạn và/hoặc
   khả năng mở rộng quy mô.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
         được đặt thành ZZ0001ZZ.

ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ
         hình chữ nhật bên trong bộ đệm ZZ0004ZZ được cắt vào đó
         khung được viết; mặc định là ZZ0005ZZ;
         chỉ đọc trên phần cứng mà không có khả năng soạn thảo/mở rộng quy mô bổ sung.

* ZZ0000ZZ

ZZ0001ZZ, ZZ0002ZZ, ZZ0003ZZ, ZZ0004ZZ
         hình chữ nhật có thể nhìn thấy; nó phải vừa với độ phân giải của bộ đệm khung
         được trả lại bởi ZZ0000ZZ trên ZZ0005ZZ.

   .. warning::

      The decoder may adjust the compose rectangle to the nearest
      supported one to meet codec and hardware requirements. The client needs
      to check the adjusted rectangle returned by :c:func:`VIDIOC_S_SELECTION`.

6. Nếu tất cả các điều kiện sau được đáp ứng, khách hàng có thể tiếp tục giải mã
    ngay lập tức:

* ZZ0000ZZ của định dạng mới (được xác định ở các bước trước) ít hơn
      lớn hơn hoặc bằng kích thước của bộ đệm hiện được phân bổ,

* số lượng bộ đệm hiện được phân bổ lớn hơn hoặc bằng
      số lượng bộ đệm tối thiểu có được ở các bước trước. Để đáp ứng điều này
      yêu cầu, khách hàng có thể sử dụng ZZ0000ZZ để thêm mới
      bộ đệm.

Trong trường hợp đó, các bước còn lại không áp dụng và khách hàng có thể tiếp tục
    giải mã bằng một trong các hành động sau:

* nếu hàng đợi ZZ0001ZZ đang phát trực tuyến, hãy gọi ZZ0000ZZ
      bằng lệnh ZZ0002ZZ,

* nếu hàng đợi ZZ0001ZZ không phát trực tuyến, hãy gọi ZZ0000ZZ
      trên hàng đợi ZZ0002ZZ.

Tuy nhiên, nếu khách hàng có ý định thay đổi bộ đệm, hãy giảm
    sử dụng bộ nhớ hoặc vì bất kỳ lý do nào khác, nó có thể đạt được bằng cách làm theo
    các bước dưới đây.

7. ZZ0003ZZ ZZ0000ZZ ZZ0004ZZ tiếp tục xếp hàng và xếp hàng
    bộ đệm trên hàng đợi ZZ0001ZZ cho đến khi bộ đệm được đánh dấu bằng
    Cờ ZZ0002ZZ bị loại bỏ.

8. ZZ0003ZZ ZZ0001ZZ ZZ0004ZZ gọi ZZ0000ZZ
    trên hàng đợi ZZ0002ZZ để ngừng phát trực tuyến.

    .. warning::

       The ``OUTPUT`` queue must remain streaming. Calling
       :c:func:`VIDIOC_STREAMOFF` on it would abort the sequence and trigger a
       seek.

9. ZZ0003ZZ ZZ0001ZZ ZZ0004ZZ giải phóng ZZ0002ZZ
    bộ đệm sử dụng ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          đặt thành 0.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

10. Phân bổ bộ đệm ZZ0001ZZ thông qua ZZ0000ZZ trên
    Hàng đợi ZZ0002ZZ.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm thực tế được phân bổ.

    .. warning::

       The actual number of allocated buffers may differ from the ``count``
       given. The client must check the updated value of ``count`` after the
       call returns.

    .. note::

       To allocate more than the minimum number of buffers (for pipeline
       depth), the client may query the ``V4L2_CID_MIN_BUFFERS_FOR_CAPTURE``
       control to get the minimum number of buffers required, and pass the
       obtained value plus the number of additional buffers needed in the
       ``count`` field to :c:func:`VIDIOC_REQBUFS`.

Ngoài ra, ZZ0000ZZ trên hàng đợi ZZ0001ZZ có thể
    được sử dụng để có nhiều quyền kiểm soát hơn đối với việc phân bổ bộ đệm. Ví dụ, bởi
    phân bổ bộ đệm lớn hơn định dạng ZZ0002ZZ hiện tại, trong tương lai
    thay đổi độ phân giải có thể được cung cấp.

* ZZ0000ZZ

ZZ0000ZZ
          số lượng bộ đệm được yêu cầu phân bổ; lớn hơn không.

ZZ0000ZZ
          một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

ZZ0000ZZ
          tuân theo ngữ nghĩa tiêu chuẩn.

ZZ0000ZZ
          một định dạng thể hiện độ phân giải bộ đệm khung tối đa sẽ được
          được cung cấp bởi bộ đệm mới được phân bổ.

* ZZ0000ZZ

ZZ0000ZZ
          được điều chỉnh theo số lượng bộ đệm được phân bổ.

    .. warning::

        The actual number of allocated buffers may differ from the ``count``
        given. The client must check the updated value of ``count`` after the
        call returns.

    .. note::

       To allocate buffers for a format different than parsed from the stream
       metadata, the client must proceed as follows, before the metadata
       parsing is initiated:

       * set width and height of the ``OUTPUT`` format to desired coded resolution to
         let the decoder configure the ``CAPTURE`` format appropriately,

       * query the ``CAPTURE`` format using :c:func:`VIDIOC_G_FMT` and save it
         until this step.

       The format obtained in the query may be then used with
       :c:func:`VIDIOC_CREATE_BUFS` in this step to allocate the buffers.

11. Gọi ZZ0000ZZ trên hàng đợi ZZ0001ZZ để bắt đầu giải mã
    khung.

Giải mã
========

Trạng thái này đạt được sau khi chuỗi ZZ0002ZZ kết thúc thành công.
Ở trạng thái này, máy khách xếp hàng và loại bỏ bộ đệm cho cả hai hàng đợi thông qua
ZZ0000ZZ và ZZ0001ZZ, theo tiêu chuẩn
ngữ nghĩa.

Nội dung của bộ đệm ZZ0000ZZ nguồn phụ thuộc vào pixel được mã hóa hoạt động
định dạng và có thể bị ảnh hưởng bởi các điều khiển mở rộng dành riêng cho codec, như đã nêu trong
tài liệu của từng định dạng.

Cả hai hàng đợi hoạt động độc lập, tuân theo hành vi tiêu chuẩn của V4L2
hàng đợi bộ đệm và các thiết bị chuyển bộ nhớ sang bộ nhớ. Ngoài ra, thứ tự giải mã
các khung được loại bỏ khỏi hàng đợi ZZ0000ZZ có thể khác với thứ tự của hàng đợi
các khung được mã hóa vào hàng đợi ZZ0001ZZ, do các thuộc tính của mã hóa đã chọn
định dạng, ví dụ: sắp xếp lại khung.

Khách hàng không được thừa nhận bất kỳ mối quan hệ trực tiếp nào giữa ZZ0000ZZ
và bộ đệm ZZ0001ZZ cũng như bất kỳ thời gian cụ thể nào của bộ đệm trở thành
có sẵn để dequeue. Cụ thể:

* bộ đệm được xếp hàng tới ZZ0000ZZ có thể dẫn đến không có bộ đệm nào được tạo
  trên ZZ0001ZZ (ví dụ: nếu nó không chứa dữ liệu được mã hóa hoặc nếu chỉ
  cấu trúc cú pháp siêu dữ liệu có trong đó),

* một bộ đệm được xếp hàng đợi tới ZZ0000ZZ có thể dẫn đến nhiều bộ đệm được tạo
  trên ZZ0001ZZ (nếu dữ liệu được mã hóa chứa nhiều hơn một khung hình hoặc nếu
  trả về khung đã giải mã cho phép bộ giải mã trả về khung
  đi trước nó trong việc giải mã, nhưng đã thành công trong thứ tự hiển thị),

* bộ đệm được xếp hàng đợi tới ZZ0000ZZ có thể dẫn đến việc bộ đệm được tạo trên
  ZZ0001ZZ sau đó chuyển sang quá trình giải mã và/hoặc sau khi xử lý thêm
  Bộ đệm ZZ0002ZZ hoặc bị trả lại không theo thứ tự, ví dụ: nếu hiển thị
  sắp xếp lại được sử dụng,

* bộ đệm có thể có sẵn trên hàng đợi ZZ0000ZZ mà không cần bổ sung
  bộ đệm được xếp hàng đợi tới ZZ0001ZZ (ví dụ: trong khi thoát hoặc ZZ0002ZZ), do
  Bộ đệm ZZ0003ZZ được xếp hàng đợi trong quá khứ có kết quả giải mã chỉ
  có sẵn sau này, do đặc thù của quá trình giải mã.

.. note::

   To allow matching decoded ``CAPTURE`` buffers with ``OUTPUT`` buffers they
   originated from, the client can set the ``timestamp`` field of the
   :c:type:`v4l2_buffer` struct when queuing an ``OUTPUT`` buffer. The
   ``CAPTURE`` buffer(s), which resulted from decoding that ``OUTPUT`` buffer
   will have their ``timestamp`` field set to the same value when dequeued.

   In addition to the straightforward case of one ``OUTPUT`` buffer producing
   one ``CAPTURE`` buffer, the following cases are defined:

   * one ``OUTPUT`` buffer generates multiple ``CAPTURE`` buffers: the same
     ``OUTPUT`` timestamp will be copied to multiple ``CAPTURE`` buffers.

   * multiple ``OUTPUT`` buffers generate one ``CAPTURE`` buffer: timestamp of
     the ``OUTPUT`` buffer queued first will be copied.

   * the decoding order differs from the display order (i.e. the ``CAPTURE``
     buffers are out-of-order compared to the ``OUTPUT`` buffers): ``CAPTURE``
     timestamps will not retain the order of ``OUTPUT`` timestamps.

.. note::

   The backing memory of ``CAPTURE`` buffers that are used as reference frames
   by the stream may be read by the hardware even after they are dequeued.
   Consequently, the client should avoid writing into this memory while the
   ``CAPTURE`` queue is streaming. Failure to observe this may result in
   corruption of decoded frames.

   Similarly, when using a memory type other than ``V4L2_MEMORY_MMAP``, the
   client should make sure that each ``CAPTURE`` buffer is always queued with
   the same backing memory for as long as the ``CAPTURE`` queue is streaming.
   The reason for this is that V4L2 buffer indices can be used by drivers to
   identify frames. Thus, if the backing memory of a reference frame is
   submitted under a different buffer ID, the driver may misidentify it and
   decode a new frame into it while it is still in use, resulting in corruption
   of the following frames.

Trong quá trình giải mã, bộ giải mã có thể bắt đầu một trong các chuỗi đặc biệt, như
được liệt kê dưới đây. Các trình tự sẽ dẫn đến việc bộ giải mã trả về tất cả các
Bộ đệm ZZ0000ZZ có nguồn gốc từ tất cả các bộ đệm ZZ0001ZZ được xử lý
trước khi trình tự bắt đầu. Bộ đệm cuối cùng sẽ có
Bộ cờ ZZ0002ZZ. Để xác định trình tự cần thực hiện, khách hàng
phải kiểm tra xem có sự kiện nào đang chờ xử lý hay không và:

* nếu sự kiện ZZ0000ZZ với ZZ0001ZZ được đặt thành
  ZZ0002ZZ đang chờ xử lý, cần phải tuân theo trình tự ZZ0003ZZ,

* nếu sự kiện ZZ0000ZZ đang chờ xử lý, chuỗi ZZ0001ZZ cần
  được theo sau.

Một số trình tự có thể được trộn lẫn với nhau và cần được xử lý
khi chúng xảy ra. Hoạt động chính xác được ghi lại cho từng trình tự.

Nếu xảy ra lỗi giải mã, nó sẽ được thông báo cho khách hàng với mức độ
chi tiết tùy thuộc vào khả năng giải mã. Cụ thể:

* bộ đệm CAPTURE chứa kết quả của thao tác giải mã không thành công
  sẽ được trả về cùng với bộ cờ V4L2_BUF_FLAG_ERROR,

* nếu bộ giải mã có thể báo cáo chính xác bộ đệm OUTPUT đã kích hoạt
  lỗi, bộ đệm đó sẽ được trả về cùng với cờ V4L2_BUF_FLAG_ERROR
  thiết lập.

Trong trường hợp xảy ra lỗi nghiêm trọng không cho phép tiếp tục giải mã, bất kỳ
các thao tác tiếp theo trên phần xử lý tệp giải mã tương ứng sẽ trả về -EIO
mã lỗi. Máy khách có thể đóng phần xử lý tệp và mở một phần mới, hoặc
cách khác là khởi tạo lại phiên bản bằng cách dừng phát trực tuyến trên cả hai hàng đợi,
giải phóng tất cả bộ đệm và thực hiện lại trình tự Khởi tạo.

Tìm kiếm
====

Tìm kiếm được kiểm soát bởi hàng đợi ZZ0000ZZ, vì đây là nguồn dữ liệu được mã hóa.
Việc tìm kiếm không yêu cầu bất kỳ thao tác cụ thể nào trên hàng đợi ZZ0001ZZ, nhưng
nó có thể bị ảnh hưởng theo hoạt động giải mã thông thường.

1. Dừng hàng đợi ZZ0001ZZ để bắt đầu chuỗi tìm kiếm thông qua
   ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

* Bộ giải mã sẽ loại bỏ tất cả các bộ đệm ZZ0000ZZ đang chờ xử lý và chúng phải
     được coi là được trả lại cho khách hàng (theo ngữ nghĩa tiêu chuẩn).

2. Khởi động lại hàng đợi ZZ0001ZZ qua ZZ0000ZZ.

* ZZ0000ZZ

ZZ0000ZZ
         một enum ZZ0001ZZ thích hợp cho ZZ0002ZZ.

* Bộ giải mã sẽ bắt đầu chấp nhận bộ đệm dòng byte nguồn mới sau
     cuộc gọi trở lại.

3. Bắt đầu xếp hàng các bộ đệm chứa dữ liệu được mã hóa sau khi tìm kiếm ZZ0000ZZ
   xếp hàng cho đến khi tìm thấy điểm tiếp tục phù hợp.

   .. note::

      There is no requirement to begin queuing coded data starting exactly
      from a resume point (e.g. SPS or a keyframe). Any queued ``OUTPUT``
      buffers will be processed and returned to the client until a suitable
      resume point is found.  While looking for a resume point, the decoder
      should not produce any decoded frames into ``CAPTURE`` buffers.

      Some hardware is known to mishandle seeks to a non-resume point. Such an
      operation may result in an unspecified number of corrupted decoded frames
      being made available on the ``CAPTURE`` queue. Drivers must ensure that
      no fatal decoding errors or crashes occur, and implement any necessary
      handling and workarounds for hardware issues related to seek operations.

   .. warning::

      In case of the H.264/HEVC codec, the client must take care not to seek
      over a change of SPS/PPS. Even though the target frame could be a
      keyframe, the stale SPS/PPS inside decoder state would lead to undefined
      results when decoding. Although the decoder must handle that case without
      a crash or a fatal decode error, the client must not expect a sensible
      decode output.

      If the hardware can detect such corrupted decoded frames, then
      corresponding buffers will be returned to the client with the
      V4L2_BUF_FLAG_ERROR set. See the `Decoding` section for further
      description of decode error reporting.

4. Sau khi tìm thấy điểm tiếp tục, bộ giải mã sẽ bắt đầu trả về ZZ0000ZZ
   bộ đệm chứa các khung đã được giải mã.

.. important::

   A seek may result in the `Dynamic Resolution Change` sequence being
   initiated, due to the seek target having decoding parameters different from
   the part of the stream decoded before the seek. The sequence must be handled
   as per normal decoder operation.

.. warning::

   It is not specified when the ``CAPTURE`` queue starts producing buffers
   containing decoded data from the ``OUTPUT`` buffers queued after the seek,
   as it operates independently from the ``OUTPUT`` queue.

   The decoder may return a number of remaining ``CAPTURE`` buffers containing
   decoded frames originating from the ``OUTPUT`` buffers queued before the
   seek sequence is performed.

   The ``VIDIOC_STREAMOFF`` operation discards any remaining queued
   ``OUTPUT`` buffers, which means that not all of the ``OUTPUT`` buffers
   queued before the seek sequence may have matching ``CAPTURE`` buffers
   produced.  For example, given the sequence of operations on the
   ``OUTPUT`` queue:

     QBUF(A), QBUF(B), STREAMOFF(), STREAMON(), QBUF(G), QBUF(H),

   any of the following results on the ``CAPTURE`` queue is allowed:

     {A', B', G', H'}, {A', G', H'}, {G', H'}.

   To determine the CAPTURE buffer containing the first decoded frame after the
   seek, the client may observe the timestamps to match the CAPTURE and OUTPUT
   buffers or use V4L2_DEC_CMD_STOP and V4L2_DEC_CMD_START to drain the
   decoder.

.. note::

   To achieve instantaneous seek, the client may restart streaming on the
   ``CAPTURE`` queue too to discard decoded, but not yet dequeued buffers.

Thay đổi độ phân giải động
=========================

Các luồng bao gồm siêu dữ liệu độ phân giải trong luồng byte có thể yêu cầu chuyển đổi
sang độ phân giải khác trong quá trình giải mã.

.. note::

   Not all decoders can detect resolution changes. Those that do set the
   ``V4L2_FMT_FLAG_DYN_RESOLUTION`` flag for the coded format when
   :c:func:`VIDIOC_ENUM_FMT` is called.

Trình tự bắt đầu khi bộ giải mã phát hiện một khung được mã hóa với một hoặc nhiều
các tham số sau đây khác với các tham số đã thiết lập trước đó (và
được phản ánh bởi các truy vấn tương ứng):

* độ phân giải được mã hóa (chiều rộng và chiều cao ZZ0000ZZ),

* độ phân giải hiển thị (hình chữ nhật lựa chọn),

* số lượng bộ đệm tối thiểu cần thiết để giải mã,

* độ sâu bit của dòng bit đã được thay đổi,

* không gian màu của dòng bit đã được thay đổi, nhưng không yêu cầu
  tái phân bổ bộ đệm.

Bất cứ khi nào điều đó xảy ra, bộ giải mã phải tiến hành như sau:

1. Sau khi gặp phải sự thay đổi độ phân giải trong luồng, bộ giải mã sẽ gửi một
    Sự kiện ZZ0000ZZ với ZZ0001ZZ được đặt thành
    ZZ0002ZZ.

    .. important::

       Any client query issued after the decoder queues the event will return
       values applying to the stream after the resolution change, including
       queue formats, selection rectangles and controls.

2. Bộ giải mã sau đó sẽ xử lý và giải mã tất cả các bộ đệm còn lại từ trước đó
    điểm thay đổi độ phân giải

* Vùng đệm cuối cùng trước khi thay đổi phải được đánh dấu bằng
      Cờ ZZ0000ZZ, tương tự như chuỗi ZZ0001ZZ ở trên.

    .. warning::

       The last buffer may be empty (with :c:type:`v4l2_buffer` ``bytesused``
       = 0) and in that case it must be ignored by the client, as it does not
       contain a decoded frame.

    .. note::

       Any attempt to dequeue more ``CAPTURE`` buffers beyond the buffer marked
       with ``V4L2_BUF_FLAG_LAST`` will result in a -EPIPE error from
       :c:func:`VIDIOC_DQBUF`.

Khách hàng phải tiếp tục trình tự như được mô tả bên dưới để tiếp tục quá trình
quá trình giải mã.

1. Xếp hàng sự kiện thay đổi nguồn.

    .. important::

       A source change triggers an implicit decoder drain, similar to the
       explicit `Drain` sequence. The decoder is stopped after it completes.
       The decoding process must be resumed with either a pair of calls to
       :c:func:`VIDIOC_STREAMOFF` and :c:func:`VIDIOC_STREAMON` on the
       ``CAPTURE`` queue, or a call to :c:func:`VIDIOC_DECODER_CMD` with the
       ``V4L2_DEC_CMD_START`` command.

2. Tiếp tục với trình tự ZZ0000ZZ.

.. note::

   During the resolution change sequence, the ``OUTPUT`` queue must remain
   streaming. Calling :c:func:`VIDIOC_STREAMOFF` on the ``OUTPUT`` queue would
   abort the sequence and initiate a seek.

   In principle, the ``OUTPUT`` queue operates separately from the ``CAPTURE``
   queue and this remains true for the duration of the entire resolution change
   sequence as well.

   The client should, for best performance and simplicity, keep queuing/dequeuing
   buffers to/from the ``OUTPUT`` queue even while processing this sequence.

Làm khô hạn
=====

Để đảm bảo rằng tất cả các bộ đệm ZZ0000ZZ được xếp hàng đợi đã được xử lý và liên quan
Bộ đệm ZZ0001ZZ được cấp cho máy khách, máy khách phải tuân theo cống
trình tự được mô tả dưới đây. Sau khi trình tự xả kết thúc, khách hàng có
đã nhận được tất cả các khung được giải mã cho tất cả bộ đệm ZZ0002ZZ được xếp hàng đợi trước
trình tự đã được bắt đầu.

1. Bắt đầu xả bằng cách phát hành ZZ0000ZZ.

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
      :c:func:`VIDIOC_DECODER_CMD` will not fail even if any of the queues is
      not streaming, but at the same time it will not initiate the `Drain`
      sequence and so the steps described below would not be applicable.

2. Bất kỳ bộ đệm ZZ0001ZZ nào được khách hàng xếp hàng trước
   ZZ0000ZZ được phát hành sẽ được xử lý và giải mã dưới dạng
   bình thường. Máy khách phải tiếp tục xử lý cả hai hàng đợi một cách độc lập,
   tương tự như hoạt động giải mã thông thường. Điều này bao gồm:

* xử lý mọi hoạt động được kích hoạt do xử lý các bộ đệm đó,
     chẳng hạn như trình tự ZZ0000ZZ, trước khi tiếp tục với
     trình tự thoát nước,

* xếp hàng và loại bỏ bộ đệm ZZ0000ZZ, cho đến khi bộ đệm được đánh dấu bằng
     Cờ ZZ0001ZZ bị loại bỏ,

     .. warning::

        The last buffer may be empty (with :c:type:`v4l2_buffer`
        ``bytesused`` = 0) and in that case it must be ignored by the client,
        as it does not contain a decoded frame.

     .. note::

        Any attempt to dequeue more ``CAPTURE`` buffers beyond the buffer
        marked with ``V4L2_BUF_FLAG_LAST`` will result in a -EPIPE error from
        :c:func:`VIDIOC_DQBUF`.

* loại bỏ các bộ đệm ZZ0000ZZ đã xử lý, cho đến khi tất cả các bộ đệm được xếp hàng đợi
     trước khi lệnh ZZ0001ZZ bị loại bỏ,

* loại bỏ sự kiện ZZ0000ZZ, nếu khách hàng đã đăng ký sự kiện đó.

   .. note::

      For backwards compatibility, the decoder will signal a ``V4L2_EVENT_EOS``
      event when the last frame has been decoded and all frames are ready to be
      dequeued. It is a deprecated behavior and the client must not rely on it.
      The ``V4L2_BUF_FLAG_LAST`` buffer flag should be used instead.

3. Sau khi tất cả bộ đệm ZZ0000ZZ được xếp hàng trước lệnh gọi ZZ0001ZZ
   được loại bỏ hàng đợi và bộ đệm ZZ0002ZZ cuối cùng được loại bỏ, bộ giải mã được
   đã dừng và nó sẽ chấp nhận, nhưng không xử lý, mọi ZZ0003ZZ mới được xếp hàng đợi
   bộ đệm cho đến khi máy khách thực hiện bất kỳ thao tác nào sau đây:

* ZZ0000ZZ - bộ giải mã sẽ không được đặt lại và sẽ tiếp tục
     hoạt động bình thường, với mọi trạng thái từ trước khi xả,

* một cặp ZZ0000ZZ và ZZ0001ZZ trên
     Hàng đợi ZZ0002ZZ - bộ giải mã sẽ tiếp tục hoạt động bình thường,
     tuy nhiên mọi bộ đệm ZZ0003ZZ vẫn còn trong hàng đợi sẽ được trả về
     khách hàng,

* một cặp ZZ0000ZZ và ZZ0001ZZ trên
     Hàng đợi ZZ0002ZZ - mọi bộ đệm nguồn đang chờ xử lý sẽ được trả về
     client và chuỗi ZZ0003ZZ sẽ được kích hoạt.

.. note::

   Once the drain sequence is initiated, the client needs to drive it to
   completion, as described by the steps above, unless it aborts the process by
   issuing :c:func:`VIDIOC_STREAMOFF` on any of the ``OUTPUT`` or ``CAPTURE``
   queues.  The client is not allowed to issue ``V4L2_DEC_CMD_START`` or
   ``V4L2_DEC_CMD_STOP`` again while the drain sequence is in progress and they
   will fail with -EBUSY error code if attempted.

   Although not mandatory, the availability of decoder commands may be queried
   using :c:func:`VIDIOC_TRY_DECODER_CMD`.

Kết thúc luồng
=============

Nếu bộ giải mã gặp phải dấu kết thúc luồng trong luồng, bộ giải mã
sẽ bắt đầu chuỗi ZZ0001ZZ mà khách hàng phải xử lý như mô tả
ở trên, bỏ qua ZZ0000ZZ ban đầu.

Điểm cam kết
=============

Việc thiết lập các định dạng và phân bổ bộ đệm sẽ kích hoạt những thay đổi trong hoạt động của
bộ giải mã.

1. Đặt định dạng trên hàng đợi ZZ0000ZZ có thể thay đổi bộ định dạng
   được hỗ trợ/quảng cáo trên hàng đợi ZZ0001ZZ. Đặc biệt, nó còn có nghĩa
   rằng định dạng ZZ0002ZZ có thể được đặt lại và máy khách không được dựa vào
   định dạng đã đặt trước đó được giữ nguyên.

2. Việc liệt kê các định dạng trên hàng đợi ZZ0000ZZ luôn chỉ trả về các định dạng
   được hỗ trợ cho định dạng ZZ0001ZZ hiện tại.

3. Đặt định dạng trên hàng đợi ZZ0000ZZ không làm thay đổi danh sách
   các định dạng có sẵn trên hàng đợi ZZ0001ZZ. Nỗ lực thiết lập ZZ0002ZZ
   định dạng không được hỗ trợ cho định dạng ZZ0003ZZ hiện được chọn
   sẽ dẫn đến việc bộ giải mã điều chỉnh định dạng ZZ0004ZZ được yêu cầu thành định dạng
   được hỗ trợ một.

4. Việc liệt kê các định dạng trên hàng đợi ZZ0000ZZ luôn trả về tập hợp đầy đủ các
   các định dạng được mã hóa được hỗ trợ, không phân biệt định dạng ZZ0001ZZ hiện tại.

5. Trong khi bộ đệm được phân bổ trên bất kỳ hàng đợi ZZ0000ZZ hoặc ZZ0001ZZ nào,
   máy khách không được thay đổi định dạng trên hàng đợi ZZ0002ZZ. Người lái xe sẽ
   trả lại mã lỗi -EBUSY cho bất kỳ nỗ lực thay đổi định dạng nào như vậy.

Tóm lại, việc thiết lập định dạng và phân bổ phải luôn bắt đầu bằng
Hàng đợi ZZ0000ZZ và hàng đợi ZZ0001ZZ là chủ quản lý
tập hợp các định dạng được hỗ trợ cho hàng đợi ZZ0002ZZ.