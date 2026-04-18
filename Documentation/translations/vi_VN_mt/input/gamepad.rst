.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/input/gamepad.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

--------------------------
Thông số kỹ thuật gamepad Linux
---------------------------

:Tác giả: 2013 của David Herrmann <dh.herrmann@gmail.com>


Giới thiệu
~~~~~~~~~~~~
Linux cung cấp nhiều trình điều khiển đầu vào khác nhau cho phần cứng gamepad. Để tránh
có không gian người dùng xử lý các cách ánh xạ nút khác nhau cho mỗi gamepad, điều này
tài liệu xác định cách gamepad phải báo cáo dữ liệu của họ.

Hình học
~~~~~~~~
Là "gamepad", chúng tôi xác định các thiết bị gần giống như thế này::

____________________________ __
           / [__ZL__] [__ZR__] \ |
          / [__ TL __] [__ TR __] \ | Kích hoạt phía trước
       __/________________________________\__ __|
      / _ \ |
     / /\ __ (N) \ |
    / |ZZ0000ZZMOZZ0001ZZ Bảng chính
   ZZ0002ZZSEZZ0003ZZSTZZ0004ZZ- (E) ZZ0005ZZ
    \ |ZZ0006ZZ
    /\ \/ / \ / \ (S) /\ __|
   / \________ ZZ0007ZZ ____ ZZ0008ZZ ________/ \ |
  ZZ0009ZZ | Gậy điều khiển
  ZZ0010ZZ __|
  ZZ0011ZZ
   \_____/ \_____/

ZZ0000ZZ______ZZ0001ZZ______ZZ0002ZZ
         D-Pad Trái Phải Action Pad
                 Cây gậy

ZZ0000ZZ
                      Bảng menu

Hầu hết các gamepad đều có các tính năng sau:

- Action-Pad
    4 nút hình kim cương (ở phía bên phải). Các nút là
    được gắn nhãn khác nhau trên hầu hết các thiết bị nên chúng tôi xác định chúng là NORTH,
    SOUTH, WEST và EAST.
  - D-Pad (Bàn phím định hướng)
    4 nút (ở bên trái) hướng lên, xuống, trái và phải.
  - Menu-Pad
    Các chòm sao khác nhau, nhưng hầu hết đều có 2 nút: SELECT - START
    Hơn nữa, nhiều gamepad có một nút có nhãn hiệu lạ mắt được sử dụng làm
    nút hệ thống đặc biệt. Nó thường trông khác với các nút khác và
    được sử dụng để bật lên menu hệ thống hoặc cài đặt hệ thống.
  - Gậy analog
    Cần analog cung cấp cần điều khiển có thể di chuyển tự do để điều khiển hướng. Không
    tất cả các thiết bị đều có cả hai hoặc bất kỳ, nhưng hầu hết chúng đều hiện diện.
    Cần analog cũng có thể cung cấp nút kỹ thuật số nếu bạn nhấn chúng.
  - Kích hoạt
    Bộ kích hoạt được đặt ở mặt trên của miếng đệm theo hướng thẳng đứng.
    Không phải tất cả các thiết bị đều cung cấp chúng, nhưng các nút phía trên thường được đặt tên
    Kích hoạt trái và phải, các nút phía dưới Z-Left và Z-Right.
  - ầm ầm
    Nhiều thiết bị cung cấp tính năng phản hồi lực. Nhưng đa số chỉ
    động cơ ầm ầm đơn giản.

Phát hiện
~~~~~~~~~

Tất cả các gamepad tuân theo giao thức được mô tả ở đây đều ánh xạ BTN_GAMEPAD. Đây là
bí danh cho BTN_SOUTH/BTN_A. Nó có thể được sử dụng để xác định một gamepad như vậy.
Tuy nhiên, không phải tất cả gamepad đều cung cấp tất cả các tính năng, vì vậy bạn cần kiểm tra tất cả
những tính năng mà bạn cần trước tiên. Cách ánh xạ từng tính năng được mô tả dưới đây.

Trình điều khiển cũ thường không tuân thủ các quy tắc này. Vì chúng ta không thể thay đổi chúng
vì lý do tương thích ngược, bạn cần cung cấp ánh xạ sửa lỗi trong
không gian người dùng của chính bạn. Một số trong số họ cũng có thể cung cấp các tùy chọn mô-đun
thay đổi ánh xạ để bạn có thể khuyên người dùng thiết lập những ánh xạ này.

Tất cả các gamepad mới phải tuân thủ ánh xạ này. Hãy báo cáo bất kỳ
lỗi, nếu không.

Có rất nhiều thiết bị ít tính năng/kém mạnh mẽ hơn sử dụng lại
các nút từ giao thức này. Tuy nhiên, họ cố gắng thực hiện điều này một cách tương thích
thời trang. Ví dụ: "Nintendo Wii Nunchuk" cung cấp hai nút kích hoạt
và một thanh analog. Nó báo cáo chúng như thể đó là một gamepad chỉ có một
cần analog và hai nút kích hoạt ở cạnh phải.
Nhưng điều đó có nghĩa là nếu bạn chỉ hỗ trợ gamepad "thật", bạn phải kiểm tra
thiết bị cho _all_ sự kiện được báo cáo mà bạn cần. Nếu không, bạn cũng sẽ nhận được
thiết bị báo cáo một tập hợp con nhỏ của các sự kiện.

Không có thiết bị nào khác trông/có cảm giác giống gamepad sẽ báo cáo những điều này
sự kiện.

Sự kiện
~~~~~~

Tay cầm chơi game báo cáo các sự kiện sau:

- Action-Pad:

Mỗi thiết bị gamepad đều có ít nhất 2 nút hành động. Điều này có nghĩa là, mỗi
  thiết bị báo cáo BTN_SOUTH (BTN_GAMEPAD là bí danh của). Bất kể
  của các nhãn trên nút, mã sẽ được gửi theo
  vị trí vật lý của các nút.

Xin lưu ý rằng các miếng đệm 2 và 3 nút khá hiếm và cũ. Bạn có thể
  muốn lọc gamepad không báo cáo cả bốn.

- Bàn phím 2 nút:

Nếu chỉ có 2 nút hành động, chúng sẽ được báo cáo là BTN_SOUTH và
      BTN_EAST. Đối với bố cục dọc, nút trên là BTN_EAST. cho
      bố cục theo chiều ngang, nút thêm ở bên phải là BTN_EAST.

- Bàn phím 3 nút:

Nếu chỉ có 3 nút hành động, chúng sẽ được báo cáo là (từ trái sang
      sang phải): BTN_WEST, BTN_SOUTH, BTN_EAST
      Nếu các nút được căn chỉnh hoàn hảo theo chiều dọc, chúng sẽ được báo cáo là
      (từ trên xuống): BTN_WEST, BTN_SOUTH, BTN_EAST

- Bàn phím 4 nút:

Nếu có tất cả 4 nút hành động, chúng có thể được căn chỉnh thành hai
      sự hình thành khác nhau. Nếu có hình kim cương, chúng được báo cáo là BTN_NORTH,
      BTN_WEST, BTN_SOUTH, BTN_EAST theo vị trí thực tế của chúng.
      Nếu là hình chữ nhật thì nút trên bên trái là BTN_NORTH, nút dưới bên trái
      là BTN_WEST, phía dưới bên phải là BTN_SOUTH và phía trên bên phải là BTN_EAST.

- D-Pad:

Mỗi gamepad đều cung cấp một D-Pad với bốn hướng: Lên, Xuống, Trái, Phải
  Một số trong số này có sẵn dưới dạng nút kỹ thuật số, một số ở dạng nút analog. Một số
  thậm chí có thể báo cáo cả hai. Hạt nhân không chuyển đổi giữa những thứ này nên
  các ứng dụng nên hỗ trợ cả hai và chọn những gì phù hợp hơn nếu
  cả hai đều được báo cáo.

- Nút bấm số được báo cáo là:

BTN_DPAD_*

- Nút Analog được báo cáo là:

ABS_HAT0X và ABS_HAT0Y

(đối với ABS giá trị âm là trái/lên, dương là phải/xuống)

- Gậy analog:

Cần analog bên trái được báo cáo là ABS_X, ABS_Y. Cần analog bên phải là
  được báo cáo là ABS_RX, ABS_RY. Không, có thể có một hoặc hai que.
  Nếu cần analog cung cấp các nút kỹ thuật số, chúng sẽ được ánh xạ tương ứng dưới dạng
  BTN_THUMBL (thứ nhất/trái) và BTN_THUMBR (thứ hai/phải).

(đối với ABS giá trị âm là trái/lên, dương là phải/xuống)

- Tác nhân kích hoạt:

Nút kích hoạt có thể có sẵn dưới dạng nút kỹ thuật số hoặc nút analog hoặc cả hai. Người dùng-
  không gian phải giải quyết chính xác mọi tình huống và chọn cách thích hợp nhất
  chế độ.

Các nút kích hoạt phía trên được báo cáo là BTN_TR hoặc ABS_HAT1X (phải) và BTN_TL
  hoặc ABS_HAT1Y (trái). Các nút kích hoạt phía dưới được báo cáo là BTN_TR2 hoặc
  ABS_HAT2X (phải/ZR) và BTN_TL2 hoặc ABS_HAT2Y (trái/ZL).

Nếu chỉ có một tổ hợp nút kích hoạt (trên + dưới), thì chúng
  được báo cáo là trình kích hoạt "đúng" (BTN_TR/ABS_HAT1X).

(Giá trị kích hoạt ABS bắt đầu từ 0, áp suất được báo cáo là giá trị dương)

- Menu-Pad:

Các nút menu luôn ở dạng kỹ thuật số và được ánh xạ theo vị trí của chúng
  thay vì nhãn của họ. Đó là:

- Bàn phím 1 nút:

Được ánh xạ là BTN_START

- Bàn phím 2 nút:

Nút bên trái được ánh xạ là BTN_SELECT, nút bên phải được ánh xạ là BTN_START

Nhiều miếng đệm còn có nút thứ ba được gắn nhãn hiệu hoặc có biểu tượng đặc biệt
  và ý nghĩa. Các nút như vậy được ánh xạ là BTN_MODE. Ví dụ như Nintendo
  Nút "HOME", nút Xbox "X" hoặc nút "PS" của Sony PlayStation.

- Rầm rầm:

Rumble được quảng cáo là FF_RUMBLE.

- Nút bấm cầm nắm:

Nhiều miếng đệm bao gồm các nút ở phía sau, thường được gọi là tay cầm hoặc
  nút phía sau, hoặc mái chèo. Chúng thường được lập trình lại bằng phần sụn để
  xuất hiện dưới dạng các nút "bình thường", nhưng đôi khi cũng được tiếp xúc với phần mềm. Một số
  ví dụ đáng chú ý về điều này là Steam Deck, có R4, R5, L4 và L5 trên
  mặt sau; các miếng đệm Xbox Elite, có P1-P4; và Switch 2 Pro
  Bộ điều khiển có GL và GR.

Đối với các bộ điều khiển này, nên sử dụng BTN_GRIPR và BTN_GRIPR2 cho phần trên cùng.
  và (các) nút tay cầm bên phải phía dưới (nếu có), và BTN_GRIPL và BTN_GRIPL2
  nên được sử dụng cho (các) nút tay cầm bên trái trên cùng và dưới cùng (nếu có).

- Hồ sơ:

Một số miếng đệm cung cấp công tắc lựa chọn cấu hình đa giá trị. Ví dụ bao gồm
  bộ điều khiển Xbox Adaptive và Xbox Elite 2. Khi hồ sơ hoạt động
  được chuyển đổi, giá trị mới được chọn của nó sẽ được phát ra dưới dạng sự kiện ABS_PROFILE.
