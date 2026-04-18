.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/sound/hd-audio/dp-mst.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
Hỗ trợ âm thanh HD DP-MST
=======================

Để hỗ trợ âm thanh DP MST, trình điều khiển codec hdmi HD Audio giới thiệu pin ảo
và phân công pcm động.

Ghim ảo là phần mở rộng của per_pin. Điểm khác biệt nhất của DP MST
kế thừa là DP MST giới thiệu mục nhập thiết bị. Mỗi chân có thể chứa
một số mục nhập thiết bị. Mỗi mục nhập thiết bị hoạt động như một mã pin.

Vì mỗi pin có thể chứa một số mục thiết bị và mỗi codec có thể chứa
nhiều chân, nếu chúng ta sử dụng một pcm cho mỗi chân, sẽ có nhiều PCM.
Giải pháp mới là tạo ra một vài PCM và liên kết động pcm với
per_pin. Trình điều khiển sử dụng cờ spec->dyn_pcm_sign để cho biết có nên sử dụng hay không
giải pháp mới.

PCM
===
Để được thêm vào

Khởi tạo mã pin
==================
Mỗi chân có thể có một số mục thiết bị (chân ảo). Trên nền tảng Intel,
số mục nhập thiết bị được thay đổi linh hoạt. Nếu trung tâm DP MST được kết nối,
nó ở chế độ DP MST và số mục nhập thiết bị là 3. Nếu không,
số mục nhập thiết bị là 1.

Để đơn giản hóa việc thực hiện, tất cả các mục thiết bị sẽ được khởi tạo
khi khởi động bất kể nó có ở chế độ DP MST hay không.

Danh sách kết nối
===============
DP MST sử dụng lại mã danh sách kết nối. Mã có thể được sử dụng lại vì
các mục thiết bị trên cùng một pin có cùng danh sách kết nối.

Điều này có nghĩa là DP MST nhận danh sách kết nối mục nhập thiết bị mà không cần
cài đặt nhập thiết bị.

Jack
====

Giả sử:
 - MST phải là dyn_pcm_task và là acomp (đối với kịch bản Intel);
 - NON-MST có thể là dyn_pcm_signed hoặc không, nó có thể là acomp hoặc !acomp;

Vì vậy có các tình huống sau:
 một. MST (&& dyn_pcm_sign && acomp)
 b. NON-MST && dyn_pcm_sign && acomp
 c. NON-MST && !dyn_pcm_sign && !acomp

Cuộc thảo luận bên dưới sẽ bỏ qua sự khác biệt của MST và NON-MST vì nó không
ảnh hưởng đến việc xử lý jack quá nhiều.

Trình điều khiển sử dụng mảng struct hdmi_pcm pcm[] trong hdmi_spec và snd_jack là
một thành viên của hdmi_pcm. Mỗi chân có một con trỏ struct hdmi_pcm * pcm.

Đối với !dyn_pcm_sign, per_pin->pcm sẽ được gán tĩnh cho spec->pcm[n].

Đối với dyn_pcm_sign, per_pin->pcm sẽ được gán cho spec->pcm[n]
khi màn hình được cắm nóng.


Xây dựng Jack
----------

- dyn_pcm_sign

Sẽ không sử dụng hda_jack mà sử dụng snd_jack trong spec->pcm_rec[pcm_idx].jack trực tiếp.

- !dyn_pcm_sign

Sử dụng hda_jack và gán tĩnh spec->pcm_rec[pcm_idx].jack = jack->jack.


Kích hoạt sự kiện không được yêu cầu
--------------------------
Kích hoạt sự kiện không được yêu cầu nếu !acomp.


Giám sát việc xử lý sự kiện Hotplug
------------------------------
- acomp

pin_eld_notify() -> check_presence_and_report() -> hdmi_ Present_sense() ->
  sync_eld_via_acomp().

Sử dụng trực tiếp snd_jack_report() trên spec->pcm_rec[pcm_idx].jack cho
  cả dyn_pcm_sign và !dyn_pcm_sign

- !acomp

hdmi_unsol_event() -> hdmi_intrinsic_event() -> check_presence_and_report() ->
  hdmi_hiện_sense() -> hdmi_prepsent_sense_via_verbs()

Sử dụng trực tiếp snd_jack_report() trên spec->pcm_rec[pcm_idx].jack cho dyn_pcm_sign.
  Sử dụng cơ chế hda_jack để xử lý các sự kiện jack.


Những người khác sẽ được bổ sung sau
========================
