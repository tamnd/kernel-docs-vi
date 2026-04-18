.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/arm/kernel_mode_neon.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==================
Chế độ hạt nhân NEON
================

Tóm tắt TL;DR
-------------
* Chỉ sử dụng các lệnh NEON hoặc các lệnh VFP không phụ thuộc vào sự hỗ trợ
  mã
* Cô lập mã NEON của bạn trong một đơn vị biên dịch riêng biệt và biên dịch nó bằng
  '-march=armv7-a -mfpu=neon -mfloat-abi=softfp'
* Đặt các lệnh gọi kernel_neon_begin() và kernel_neon_end() xung quanh các lệnh gọi vào
  NEON code
* Đừng ngủ trong mã NEON của bạn và lưu ý rằng nó sẽ được thực thi với
  quyền ưu tiên bị vô hiệu hóa


Giới thiệu
------------
Có thể sử dụng các lệnh NEON (và trong một số trường hợp, các lệnh VFP) trong
mã chạy ở chế độ kernel. Tuy nhiên, vì lý do hiệu suất, NEON/VFP
tập tin đăng ký không được bảo tồn và khôi phục mỗi lần chuyển đổi ngữ cảnh hoặc thực hiện
ngoại lệ giống như tệp đăng ký bình thường, vì vậy một số can thiệp thủ công được thực hiện
được yêu cầu. Hơn nữa, cần phải có sự chăm sóc đặc biệt đối với mã có thể ngủ [tức là
có thể gọi lịch trình()], vì các lệnh NEON hoặc VFP sẽ được thực thi trong một
phần không được ưu tiên vì những lý do được nêu dưới đây.


Lười bảo tồn và khôi phục
-------------------------
Tệp đăng ký NEON/VFP được quản lý bằng cách sử dụng bảo quản lười biếng (trên hệ thống UP) và
khôi phục lười biếng (trên cả hệ thống SMP và UP). Điều này có nghĩa là tập tin đăng ký là
được giữ ở trạng thái 'hoạt động' và chỉ được bảo tồn và khôi phục khi có nhiều tác vụ được thực hiện
tranh giành đơn vị NEON/VFP (hoặc, trong trường hợp SMP, khi một tác vụ di chuyển sang
lõi khác). Khôi phục từng phần được thực hiện bằng cách vô hiệu hóa thiết bị NEON/VFP sau
mọi chuyển đổi ngữ cảnh, dẫn đến một cái bẫy khi sau đó là NEON/VFP
lệnh được đưa ra, cho phép kernel bước vào và thực hiện khôi phục nếu
cần thiết.

Bất kỳ việc sử dụng đơn vị NEON/VFP nào trong chế độ kernel sẽ không ảnh hưởng đến điều này, vì vậy
cần phải thực hiện việc bảo tồn 'háo hức' tệp đăng ký NEON/VFP và
bật đơn vị NEON/VFP một cách rõ ràng để không có ngoại lệ nào được tạo ra lần đầu tiên
lần sử dụng tiếp theo. Việc này được xử lý bởi hàm kernel_neon_begin(), hàm này
nên được gọi trước khi bất kỳ lệnh chế độ kernel NEON hoặc VFP nào được ban hành.
Tương tự, thiết bị NEON/VFP phải được tắt lại sau khi sử dụng để đảm bảo người dùng
chế độ sẽ gặp bẫy khôi phục lười biếng trong lần sử dụng tiếp theo. Việc này được xử lý bởi
hàm kernel_neon_end().


Sự gián đoạn trong chế độ kernel
----------------------------
Vì lý do hiệu quả và tính đơn giản, người ta đã quyết định rằng sẽ không có
cơ chế bảo tồn/khôi phục cho nội dung đăng ký chế độ kernel NEON/VFP. Cái này
ngụ ý rằng việc gián đoạn phần NEON của chế độ kernel chỉ có thể được phép nếu
chúng được đảm bảo không chạm vào các thanh ghi NEON/VFP. Vì lý do này,
các quy tắc và hạn chế sau đây áp dụng trong kernel:
* Mã NEON/VFP không được phép trong ngữ cảnh gián đoạn;
* Mã NEON/VFP không được phép ngủ;
* Mã NEON/VFP được thực thi khi quyền ưu tiên bị vô hiệu hóa.

Nếu độ trễ là vấn đề đáng lo ngại, bạn có thể thực hiện các cuộc gọi quay lại tới
kernel_neon_end() và kernel_neon_begin() ở những vị trí trong mã của bạn mà không có
các thanh ghi NEON đang hoạt động. (Các lệnh gọi bổ sung tới kernel_neon_begin() phải là
khá rẻ nếu không có chuyển đổi ngữ cảnh nào xảy ra trong thời gian chờ đợi)


VFP và mã hỗ trợ
--------------------
Các phiên bản trước của VFP (trước phiên bản 3) dựa vào sự hỗ trợ của phần mềm cho mọi thứ
như xử lý dòng chảy dưới tuân thủ IEEE-754, v.v. Khi đơn vị VFP cần như vậy
hỗ trợ phần mềm, nó báo hiệu cho kernel bằng cách đưa ra một lệnh không xác định
ngoại lệ. Hạt nhân phản hồi bằng cách kiểm tra các thanh ghi điều khiển VFP và
hướng dẫn và đối số hiện tại, đồng thời mô phỏng hướng dẫn trong phần mềm.

Hỗ trợ phần mềm như vậy hiện không được triển khai cho các lệnh VFP
được thực thi ở chế độ kernel. Nếu gặp phải tình trạng như vậy, kernel sẽ
thất bại và tạo ra OOPS.


Tách mã NEON khỏi mã thông thường
---------------------------------------
Trình biên dịch không nhận thức được tầm quan trọng đặc biệt của kernel_neon_begin() và
kernel_neon_end(), tức là nó chỉ được phép đưa ra các lệnh NEON/VFP
giữa các cuộc gọi đến các chức năng tương ứng này. Hơn nữa, GCC có thể tạo ra NEON
hướng dẫn riêng ở mức -O3 nếu -mfpu=neon được chọn và ngay cả khi
kernel hiện được biên dịch ở -O2, những thay đổi trong tương lai có thể dẫn đến NEON/VFP
hướng dẫn xuất hiện ở những nơi không ngờ tới nếu không có sự quan tâm đặc biệt.

Do đó, cách sử dụng NEON/VFP được khuyến nghị và duy nhất được hỗ trợ trong
kernel bằng cách tuân thủ các quy tắc sau:

* tách mã NEON trong một đơn vị biên dịch riêng và biên dịch nó với
  '-march=armv7-a -mfpu=neon -mfloat-abi=softfp';
* thực hiện các cuộc gọi tới kernel_neon_begin(), kernel_neon_end() cũng như các cuộc gọi
  vào đơn vị chứa mã NEON từ đơn vị biên dịch là ZZ0000ZZ
  được xây dựng với bộ cờ GCC '-mfpu=neon'.

Vì kernel được biên dịch bằng '-msoft-float', nên điều trên sẽ đảm bảo rằng
cả hai lệnh NEON và VFP sẽ chỉ xuất hiện trong phần biên dịch được chỉ định
đơn vị ở bất kỳ mức độ tối ưu hóa nào.


Bộ lắp ráp NEON
--------------
Trình biên dịch mã NEON được hỗ trợ mà không cần cảnh báo bổ sung miễn là tuân thủ các quy tắc
ở trên được tuân theo.


Mã NEON được tạo bởi GCC
--------------------------
Tùy chọn GCC -ftree-vectorize (ngụ ý bởi -O3) cố gắng khai thác tiềm ẩn
song song và tạo mã NEON từ mã nguồn C thông thường. Điều này hoàn toàn
được hỗ trợ miễn là các quy tắc trên được tuân theo.


Bản chất NEON
---------------
Nội tại NEON cũng được hỗ trợ. Tuy nhiên, như code sử dụng nội tại NEON
dựa vào tiêu đề GCC <arm_neon.h>, (#includes <stdint.h>), bạn nên
tuân thủ những điều sau đây ngoài các quy tắc trên:

* Biên dịch đơn vị chứa nội tại NEON với '-ffreestanding' nên GCC
  sử dụng phiên bản dựng sẵn của <stdint.h> (đây là tiêu đề C99 mà kernel
  không cung cấp);
* Bao gồm <arm_neon.h> cuối cùng hoặc ít nhất là sau <linux/types.h>
