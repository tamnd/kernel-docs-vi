.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/cards/maya44.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================================
Lưu ý về hỗ trợ âm thanh Maya44 USB
====================================

.. note::
   The following is the original document of Rainer's patch that the
   current maya44 code based on.  Some contents might be obsoleted, but I
   keep here as reference -- tiwai

Ngày 14 tháng 2 năm 2008

Rainer Zimmermann <mail@lightshed.de>
 
STATE CỦA DEVELOPMENT
=====================

Trình điều khiển này đang được phát triển theo sáng kiến ​​của Piotr Makowski (oponek@gmail.com) và được tài trợ bởi Lars Bergmann.
Quá trình phát triển được thực hiện bởi Rainer Zimmermann (mail@lightshed.de).

ESI đã cung cấp thẻ Maya44 mẫu cho công việc phát triển.

Tuy nhiên, thật không may, việc lấy thông tin lập trình chi tiết trở nên khó khăn nên tôi (Rainer Zimmermann) đã phải tìm ra một số thông tin cụ thể về thẻ bằng thử nghiệm và phỏng đoán. Một số thông tin (đặc biệt là một số bit GPIO) vẫn bị thiếu.

Đây là phiên bản thử nghiệm đầu tiên của trình điều khiển Maya44 được phát hành vào danh sách gửi thư của alsa-devel (05/02/2008).


Các chức năng sau hoạt động như đã được Rainer Zimmermann và Piotr Makowski thử nghiệm:

- phát lại và chụp ở mọi tốc độ lấy mẫu
- mức đầu vào/đầu ra
- trộn chéo
- Công tắc đường truyền/mic
- Công tắc nguồn ảo
- màn hình tương tự hay còn gọi là bỏ qua


Các chức năng sau của ZZ0000ZZ hoạt động nhưng chưa được kiểm tra đầy đủ:

- Tương tự kênh 3+4 - Chuyển đổi đầu vào S/PDIF
- Đầu ra S/PDIF
- tất cả đầu vào/đầu ra trên thẻ mở rộng M/IO/DIO
- lựa chọn đồng hồ bên trong / bên ngoài


ZZ0000ZZ


Những điều có vẻ không hiệu quả:

- Máy đo mức ("đa rãnh") trong 'alsamixer' dường như không phản ứng với các tín hiệu trong (nếu đây là lỗi thì có thể nó nằm trong mã ICE1724 hiện có).

- Ardor 2.1 dường như chỉ hoạt động qua JACK, không sử dụng trực tiếp ALSA hoặc qua OSS. Điều này vẫn cần phải được theo dõi.


DRIVER DETAILS
==============

các tập tin sau đã được thêm vào:

* pci/ice1724/maya44.c - Mã cụ thể của Maya44
* pci/ice1724/maya44.h
* pci/ice1724/ice1724.patch
* pci/ice1724/ice1724.h.patch - Bản vá PROPOSED cho Ice1724.h (xem SAMPLING RATES)
* i2c/other/wm8776.c - các quy trình truy cập cấp thấp cho codec Wolfson WM8776 
* bao gồm/wm8776.h


Lưu ý rằng mã wm8776.c có nghĩa là độc lập với thẻ và không thực sự đăng ký codec với cơ sở hạ tầng ALSA.
Điều này được thực hiện trong maya44.c, chủ yếu là do một số điều khiển WM8776 được sử dụng theo cách dành riêng cho Maya44 và phải được đặt tên phù hợp.


các tệp sau được tạo trong pci/ice1724, chỉ đơn giản là #including tệp tương ứng từ cây alsa-kernel:

* wtm.h
* vt1720_mobo.h
* revo.h
* thần đồng192.h
* pontis.h
* pha.h
* maya44.h
* tháng bảy.h
* aureon.h
* amp.h
* ghen tị24ht.h
* se.h
* thần đồng_hifi.h


ZZ0000ZZ


SAMPLING RATES
==============

Thẻ Maya44 (hay chính xác hơn là codec Wolfson WM8776) cho phép tốc độ lấy mẫu tối đa là 192 kHz để phát lại và 92 kHz để thu.

Vì chip ICE1724 chỉ cho phép một tốc độ lấy mẫu toàn cầu nên việc này được xử lý như sau:

* cài đặt tốc độ lấy mẫu trên mọi thiết bị PCM đang mở trên thẻ maya44 sẽ luôn đặt tốc độ lấy mẫu ZZ0000ZZ cho tất cả các kênh phát lại và thu.

* Ở trạng thái hiện tại của trình điều khiển, tốc độ cài đặt lên tới 192 kHz được cho phép ngay cả đối với các thiết bị thu.

ZZ0000ZZ, mặc dù nó có vẻ hoạt động. Codec thực sự không thể ghi được ở tốc độ như vậy, nghĩa là chất lượng kém.


Tôi đề xuất một số mã bổ sung để hạn chế tốc độ lấy mẫu khi cài đặt trên thiết bị chụp pcm. Tuy nhiên, do tốc độ lấy mẫu toàn cầu, logic này sẽ có vấn đề.

Mã được đề xuất (hiện đã ngừng hoạt động) nằm trong Ice1712.h.patch, Ice1724.c và maya44.c (trong pci/ice1712).


SOUND DEVICES
=============

Các thiết bị PCM tương ứng với đầu vào/đầu ra như sau (giả sử Maya44 là thẻ #0):

* Đầu vào hw:0,0 - đầu vào âm thanh nổi, đầu vào analog 1+2
* Đầu ra hw:0,0 - đầu ra âm thanh nổi, đầu ra analog 1+2
* Đầu vào hw:0,1 - đầu vào âm thanh nổi, đầu vào analog 3+4 HOẶC đầu vào S/PDIF
* Đầu ra hw:0,1 - đầu ra âm thanh nổi, đầu ra analog 3+4 (và đầu ra SPDIF)


NAMING CỦA MIXER CONTROLS
=========================

(để biết thêm thông tin về luồng tín hiệu, vui lòng tham khảo sơ đồ khối trên trang 24 của hướng dẫn sử dụng ESI Maya44 hoặc trong phần mềm Windows ESI).


PCM
    Mức đầu ra (kỹ thuật số) cho kênh 1+2
PCM 1
    tương tự cho kênh 3+4

Mic Phantom+48V
    công tắc nguồn ảo +48V cho micrô tĩnh điện ở đầu vào 1/2.

Đảm bảo tính năng này không được bật trong khi bất kỳ nguồn nào khác được kết nối với đầu vào 1/2.
    Nó có thể làm hỏng nguồn và/hoặc thẻ maya44.

Đầu vào micrô/đường truyền
    nếu công tắc bật, giắc đầu vào 1/2 là đầu vào micrô (mono), nếu không thì đầu vào đường truyền (âm thanh nổi).

Bỏ qua
    bỏ qua tương tự từ đầu vào ADC đến đầu ra cho kênh 1+2. Tương tự như "Màn hình" trong trình điều khiển windows.
Bỏ qua 1
    tương tự cho kênh 3+4.

Trộn chéo
    máy trộn chéo từ kênh 1+2 đến kênh 3+4
Trộn chéo 1
    máy trộn chéo từ kênh 3+4 đến kênh 1+2

Đầu ra IEC958
    chuyển đổi cho đầu ra S/PDIF.

Điều này không được trình điều khiển Windows ESI hỗ trợ.
    S/PDIF phải xuất ra tín hiệu giống như kênh 3+4. [chưa được kiểm tra!]


Bộ chọn đầu ra kỹ thuật số
    Các công tắc này cho phép định tuyến kỹ thuật số trực tiếp từ ADC đến DAC.
    Mỗi công tắc xác định nguồn gốc của dữ liệu đầu vào kỹ thuật số đến một trong các DAC.
    Chúng không được trình điều khiển Windows ESI hỗ trợ.
    Để hoạt động bình thường, tất cả chúng phải được đặt thành "PCM out".

H/W
    Kênh nguồn đầu ra 1
H/W 1
    Kênh nguồn đầu ra 2
H/W 2
    Kênh nguồn đầu ra 3
H/W 3
    Kênh nguồn đầu ra 4

Cao/T 4 ... Cao/T 9
    chức năng không xác định, còn lại để cho phép thử nghiệm.

Có thể một số trong số này kiểm soát (các) đầu ra S/PDIF.
    Nếu những thứ này không được sử dụng, chúng sẽ biến mất trong các phiên bản trình điều khiển sau này.

Các giá trị có thể lựa chọn cho mỗi bộ chọn đầu ra kỹ thuật số là:

PCM ra
	Đầu ra DAC của kênh tương ứng (cài đặt mặc định)
Đầu vào 1 ... Đầu vào 4
	định tuyến trực tiếp từ đầu ra ADC của kênh đầu vào đã chọn

