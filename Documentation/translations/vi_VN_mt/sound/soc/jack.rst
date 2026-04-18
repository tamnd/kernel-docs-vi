.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/soc/jack.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=====================
Phát hiện giắc cắm ASoC
===================

ALSA có API tiêu chuẩn để thể hiện các giắc cắm vật lý cho không gian người dùng,
phía kernel của nó có thể được nhìn thấy trong include/sound/jack.h.  ASoC
cung cấp phiên bản API này bổ sung thêm hai tính năng:

- Nó cho phép nhiều phương pháp phát hiện giắc cắm hoạt động cùng nhau trên một
   giắc cắm hiển thị của người dùng.  Trong các hệ thống nhúng, thông thường có nhiều
   hiện diện trên một giắc cắm duy nhất nhưng được xử lý bởi các bit riêng biệt của
   phần cứng.

- Tích hợp với DAPM, cho phép cập nhật điểm cuối DAPM
   tự động dựa trên trạng thái giắc cắm được phát hiện (ví dụ: tắt
   đầu ra tai nghe nếu không có tai nghe).

Điều này được thực hiện bằng cách chia các giắc cắm thành ba thứ hoạt động
cùng nhau: bản thân jack được đại diện bởi một cấu trúc snd_soc_jack, các tập hợp
snd_soc_jack_pins đại diện cho điểm cuối DAPM để cập nhật và các khối
mã cung cấp cơ chế báo cáo jack.

Ví dụ: một hệ thống có thể có giắc cắm tai nghe âm thanh nổi với hai báo cáo
cơ chế, một dành cho tai nghe và một dành cho micrô.  Một số
hệ thống sẽ không thể sử dụng đầu ra loa khi tai nghe đang được bật
đã kết nối và vì vậy sẽ muốn đảm bảo cập nhật cả loa và
tai nghe khi trạng thái giắc cắm tai nghe thay đổi.

Giắc cắm - struct snd_soc_jack
==============================

Điều này thể hiện một giắc cắm vật lý trên hệ thống và là thứ hiển thị cho
không gian người dùng.  Bản thân giắc cắm hoàn toàn thụ động, nó được thiết lập bởi
trình điều khiển máy và cập nhật bằng phương pháp phát hiện jack.

Giắc cắm được tạo bởi trình điều khiển máy gọi snd_soc_jack_new().

snd_soc_jack_pin
================

Chúng đại diện cho chân DAPM để cập nhật tùy thuộc vào một số trạng thái
các bit được hỗ trợ bởi jack.  Mỗi snd_soc_jack không có hoặc nhiều trong số này
được cập nhật tự động.  Chúng được tạo ra bởi trình điều khiển máy
và được liên kết với giắc cắm bằng snd_soc_jack_add_pins().  trạng thái
của điểm cuối có thể được cấu hình ngược lại với trạng thái giắc cắm nếu
bắt buộc (ví dụ: bật micrô tích hợp nếu micrô không
được kết nối thông qua một jack).

Phương pháp phát hiện Jack
======================

Việc phát hiện giắc cắm thực tế được thực hiện bằng mã có khả năng giám sát một số
nhập vào hệ thống và cập nhật giắc cắm bằng cách gọi snd_soc_jack_report(),
chỉ định một tập hợp con các bit cần cập nhật.  Mã phát hiện jack nên
được thiết lập bởi trình điều khiển máy, lấy cấu hình cho giắc cắm
cập nhật và tập hợp những thứ cần báo cáo khi giắc cắm được kết nối.

Thông thường việc này được thực hiện dựa trên trạng thái của GPIO - trình xử lý cho việc này là
được cung cấp bởi hàm snd_soc_jack_add_gpio().  Các phương pháp khác là
cũng có sẵn, ví dụ như được tích hợp vào CODEC.  Một ví dụ về
Có thể thấy tính năng phát hiện giắc cắm tích hợp CODEC trong trình điều khiển WM8350.

Mỗi jack có thể có nhiều cơ chế báo cáo, mặc dù nó sẽ cần ít nhất
ít nhất một cái sẽ hữu ích.

Trình điều khiển máy
===============

Tất cả đều được nối với nhau bởi trình điều khiển máy tùy thuộc vào
phần cứng hệ thống.  Trình điều khiển máy sẽ thiết lập snd_soc_jack và
danh sách các chân cần cập nhật sau đó thiết lập một hoặc nhiều chức năng phát hiện giắc cắm
cơ chế cập nhật jack đó dựa trên trạng thái hiện tại của chúng.
