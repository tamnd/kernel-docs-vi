.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/usb/dwc3.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============
Trình điều khiển DWC3
===========


TODO
~~~~

Hãy chọn một cái gì đó trong khi đọc :)

- Chuyển đổi trình xử lý ngắt thành per-ep-thread-irq

Hóa ra một số lệnh DWC3 ~ 1ms sẽ hoàn thành. Hiện nay chúng tôi quay
  cho đến khi lệnh hoàn thành thì điều đó là xấu.

Ý tưởng triển khai:

- lõi dwc thực hiện chip irq phân kênh cho các ngắt trên mỗi
    điểm cuối. Các số ngắt được phân bổ trong quá trình thăm dò và thuộc về
    tới thiết bị. Nếu MSI cung cấp cho mỗi điểm cuối, hãy làm gián đoạn hình nộm này
    chip ngắt có thể được thay thế bằng các ngắt "thực".
  - các ngắt được yêu cầu/phân bổ trên usb_ep_enable() và bị xóa trên
    usb_ep_disable(). Trường hợp xấu nhất là 32 ngắt, giới hạn dưới là hai
    cho ep0/1.
  - dwc3_send_gadget_ep_cmd() sẽ ngủ trong wait_for_completion_timeout()
    cho đến khi lệnh hoàn thành.
  - bộ xử lý ngắt được chia thành các phần sau:

- trình xử lý chính của thiết bị
      đi qua mọi sự kiện và gọi generic_handle_irq() cho sự kiện
      nó. Khi trở về từ generic_handle_irq() để xác nhận sự kiện
      bộ đếm nên ngắt biến mất (cuối cùng).

- xử lý luồng của thiết bị
      không có

- xử lý chính của ngắt EP
      đọc sự kiện và cố gắng xử lý nó. Mọi thứ đòi hỏi
      việc ngủ được chuyển giao cho Thread. Sự kiện được lưu trong một
      cấu trúc dữ liệu cho mỗi điểm cuối.
      Có lẽ chúng ta phải chú ý không xử lý các sự kiện một khi chúng ta
      đã đưa thứ gì đó vào chuỗi để chúng tôi không xử lý sự kiện X ưu tiên Y
      trong đó X > Y.

- xử lý luồng của ngắt EP
      xử lý công việc EP còn lại có thể ngủ chẳng hạn như chờ đợi
      để hoàn thành lệnh.

Độ trễ:

Sẽ không có sự gia tăng độ trễ vì luồng ngắt có
   mức độ ưu tiên cao và sẽ được chạy trước một tác vụ trung bình trong vùng đất của người dùng
   (ngoại trừ người dùng đã thay đổi mức độ ưu tiên).
