.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/stable-kernel-rules.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _stable_kernel_rules:

Mọi thứ bạn từng muốn biết về Linux - bản phát hành ổn định
===============================================================

Các quy tắc về loại bản vá nào được chấp nhận và loại nào không được chấp nhận trong
cây "-ổn định":

- Nó hoặc một bản sửa lỗi tương đương phải tồn tại trong dòng chính của Linux (ngược dòng).
- Nó phải rõ ràng là chính xác và đã được kiểm nghiệm.
- Không được lớn hơn 100 dòng, kèm theo ngữ cảnh.
- Phải tuân theo
  ZZ0000ZZ
  quy luật.
- Nó phải sửa một lỗi thực sự làm phiền mọi người hoặc chỉ cần thêm ID thiết bị.
  Để giải thích về cái trước:

- Nó khắc phục các sự cố như rất tiếc, bị treo, hỏng dữ liệu, bảo mật thực sự
    sự cố, lỗi phần cứng, lỗi xây dựng (nhưng không xảy ra đối với những thứ được đánh dấu
    CONFIG_BROKEN) hoặc một số vấn đề "ồ, điều đó không tốt".
  - Các vấn đề nghiêm trọng do người dùng hạt nhân phân phối báo cáo cũng có thể
    sẽ được xem xét nếu chúng khắc phục được vấn đề về hiệu suất hoặc tính tương tác đáng chú ý.
    Vì những cách khắc phục này không rõ ràng và có nguy cơ xảy ra lỗi tinh vi cao hơn.
    hồi quy, chúng chỉ nên được gửi bởi hạt nhân phân phối
    người bảo trì và bao gồm một phụ lục liên kết tới một mục bugzilla nếu nó
    tồn tại và thông tin bổ sung về tác động mà người dùng có thể nhìn thấy.
  - Không "Đây có thể là một vấn đề..." kiểu như "cuộc đua lý thuyết
    điều kiện", trừ khi có lời giải thích về cách khai thác lỗi.
    được cung cấp.
  - Không sửa lỗi “tầm thường” mà không mang lại lợi ích cho người dùng (thay đổi chính tả, khoảng trắng
    dọn dẹp, v.v.).


Thủ tục gửi các bản vá tới cây ổn định
----------------------------------------------------

.. note::

   Security patches should not be handled (solely) by the -stable review
   process but should follow the procedures in
   :ref:`Documentation/process/security-bugs.rst <securitybugs>`.

Có ba tùy chọn để gửi thay đổi đối với cây ổn định:

1. Thêm 'thẻ ổn định' vào mô tả bản vá mà bạn gửi để nhận
   bao gồm tuyến chính.
2. Yêu cầu nhóm ổn định chọn một bản vá đã có sẵn.
3. Gửi bản vá cho nhóm ổn định tương đương với một thay đổi đã có
   chủ đạo.

Các phần bên dưới mô tả từng tùy chọn chi tiết hơn.

ZZ0000ZZ được ưa thích hơn ZZ0003ZZ, đây là cách dễ nhất và phổ biến nhất.
ZZ0001ZZ chủ yếu dành cho những thay đổi trong đó việc chuyển ngược lại không được xem xét
tại thời điểm nộp hồ sơ. ZZ0002ZZ là sự thay thế cho hai loại trước đó
các tùy chọn cho trường hợp bản vá chính cần điều chỉnh để áp dụng trong phiên bản cũ hơn
loạt (ví dụ do thay đổi API).

Khi sử dụng tùy chọn 2 hoặc 3, bạn có thể yêu cầu đưa thay đổi của mình vào một số thông tin cụ thể.
loạt ổn định. Khi làm như vậy, hãy đảm bảo áp dụng bản sửa lỗi hoặc biện pháp tương đương,
đã gửi hoặc đã có trong tất cả các cây ổn định mới hơn vẫn được hỗ trợ. Đây là
nhằm ngăn chặn sự hồi quy mà người dùng có thể gặp phải sau này khi cập nhật, nếu
ví dụ: một bản sửa lỗi được hợp nhất cho 5.19-rc1 sẽ được chuyển về 5.10.y chứ không phải 5.15.y.

.. _option_1:

Tùy chọn 1
**********

Để có bản vá bạn gửi để đưa vào dòng chính sau đó sẽ được tự động chọn
đối với cây ổn định, hãy thêm thẻ này vào khu vực đăng xuất::

Cc: stable@vger.kernel.org

Thay vào đó, hãy sử dụng ZZ0000ZZ khi sửa các lỗ hổng chưa được công bố:
nó làm giảm nguy cơ vô tình tiết lộ bản sửa lỗi cho công chúng bằng cách
'git send-email', vì thư được gửi đến địa chỉ đó sẽ không được gửi đến bất kỳ đâu.

Sau khi bản vá được làm chính, nó sẽ được áp dụng cho cây ổn định mà không cần
bất cứ điều gì khác cần được thực hiện bởi tác giả hoặc người bảo trì hệ thống con.

Để gửi hướng dẫn bổ sung cho nhóm ổn định, hãy sử dụng nội tuyến kiểu shell
comment để chuyển các ghi chú tùy ý hoặc được xác định trước:

* Chỉ định bất kỳ điều kiện tiên quyết bổ sung nào cho bản vá để hái anh đào::

Cc: <stable@vger.kernel.org> # 3.3.x: a1f84a3: sched: Kiểm tra trạng thái rảnh rỗi
    Cc: <stable@vger.kernel.org> # 3.3.x: 1b9508f: sched: Newidle giới hạn tốc độ
    Cc: <stable@vger.kernel.org> # 3.3.x: fd21073: sched: Khắc phục logic mối quan hệ
    Cc: <stable@vger.kernel.org> # 3.3.x
    Người đăng ký: Ingo Molnar <mingo@elte.hu>

Chuỗi thẻ có ý nghĩa::

git anh đào-pick a1f84a3
    git anh đào-pick 1b9508f
    git anh đào-pick fd21073
    git Cherry-pick <cam kết này>

Lưu ý rằng đối với một loạt bản vá, bạn không cần phải liệt kê các điều kiện tiên quyết
  các bản vá lỗi có trong chính bộ truyện. Ví dụ: nếu bạn có những điều sau đây
  loạt bản vá::

bản vá1
    bản vá2

trong đó patch2 phụ thuộc vào patch1, bạn không cần phải liệt kê patch1 dưới dạng
  điều kiện tiên quyết của patch2 nếu bạn đã đánh dấu patch1 là ổn định
  sự hòa nhập.

* Chỉ ra các điều kiện tiên quyết của phiên bản kernel::

Cc: <stable@vger.kernel.org> # 3.3.x

Thẻ có ý nghĩa::

git Cherry-pick <cam kết này>

Đối với mỗi cây "ổn định" bắt đầu bằng phiên bản được chỉ định.

Lưu ý, việc gắn thẻ như vậy là không cần thiết nếu nhóm ổn định có thể lấy được
  phiên bản thích hợp từ Fixes: tags.

* Trì hoãn việc nhận các bản vá::

Cc: <stable@vger.kernel.org> # after -rc3

* Chỉ ra những vấn đề đã biết::

Cc: <stable@vger.kernel.org> Mô tả bản vá # see, cần điều chỉnh cho <= 6.3

Ngoài ra còn có một biến thể của thẻ ổn định mà bạn có thể sử dụng để tạo sự ổn định
các công cụ backport của nhóm (ví dụ: AUTOSEL hoặc các tập lệnh tìm kiếm các cam kết
chứa thẻ 'Sửa lỗi:') bỏ qua thay đổi::

Cc: <stable+noautosel@kernel.org> # reason ở đây và phải có mặt

.. _option_2:

Tùy chọn 2
**********

Nếu bản vá đã được hợp nhất vào dòng chính, hãy gửi email đến
stable@vger.kernel.org chứa chủ đề của bản vá, ID cam kết,
tại sao bạn nghĩ nên áp dụng nó và phiên bản kernel nào bạn muốn áp dụng
được áp dụng vào.

.. _option_3:

Tùy chọn 3
**********

Gửi bản vá, sau khi xác minh rằng nó tuân theo các quy tắc trên, tới
stable@vger.kernel.org và đề cập đến các phiên bản kernel mà bạn muốn áp dụng
đến. Khi làm như vậy, bạn phải lưu ý ID cam kết ngược dòng trong nhật ký thay đổi của
gửi bằng một dòng riêng phía trên văn bản cam kết, như thế này ::

cam kết <sha1> ngược dòng.

Hoặc cách khác::

[ Cam kết ngược dòng <sha1> ]

Nếu bản vá được gửi khác với bản vá ngược dòng ban đầu (ví dụ:
bởi vì nó phải được điều chỉnh cho API cũ hơn), điều này phải rất rõ ràng
được ghi lại và chứng minh trong phần mô tả bản vá.


Sau khi nộp hồ sơ
------------------------

Người gửi sẽ nhận được ACK khi bản vá được chấp nhận vào
hàng đợi hoặc NAK nếu bản vá bị từ chối.  Phản hồi này có thể mất một vài
ngày, theo lịch trình của các thành viên trong nhóm ổn định.

Nếu được chấp nhận, bản vá sẽ được thêm vào hàng đợi ổn định để người khác xem xét
các nhà phát triển và người bảo trì hệ thống con có liên quan.


Chu kỳ xem xét
--------------

- Khi những người bảo trì ổn định quyết định thực hiện chu kỳ xem xét, các bản vá sẽ được
  được gửi đến ủy ban đánh giá và người duy trì khu vực bị ảnh hưởng của
  bản vá (trừ khi người gửi là người duy trì khu vực) và CC: để
  danh sách gửi thư hạt nhân linux.
- Ủy ban đánh giá có 48 giờ để gửi bản vá cho ACK hoặc NAK.
- Nếu bản vá bị thành viên ủy ban hoặc hạt nhân linux từ chối
  các thành viên phản đối bản vá, đưa ra các vấn đề mà người bảo trì và
  các thành viên không nhận ra, bản vá sẽ bị loại khỏi hàng đợi.
- Các bản vá lỗi ACKed sẽ được đăng lại như một phần của ứng cử viên phát hành (-rc)
  để được thử nghiệm bởi các nhà phát triển và người thử nghiệm.
- Thông thường chỉ có một bản phát hành -rc được thực hiện, tuy nhiên nếu có bất kỳ bản phát hành nào còn tồn đọng
  vấn đề, một số bản vá có thể được sửa đổi hoặc loại bỏ hoặc các bản vá bổ sung có thể
  được xếp hàng. Các bản phát hành -rc bổ sung sau đó được phát hành và thử nghiệm cho đến khi không còn
  các vấn đề được tìm thấy.
- Việc phản hồi các bản phát hành -rc có thể được thực hiện trên danh sách gửi thư bằng cách gửi
  email "Được kiểm tra bởi:" với bất kỳ thông tin kiểm tra nào mong muốn. "Đã được thử nghiệm bởi:"
  các thẻ sẽ được thu thập và thêm vào cam kết phát hành.
- Khi kết thúc chu kỳ xét duyệt, bản phát hành ổn định mới sẽ được phát hành
  chứa tất cả các bản vá được xếp hàng đợi và thử nghiệm.
- Các bản vá bảo mật sẽ được chấp nhận vào cây ổn định trực tiếp từ
  nhóm hạt nhân bảo mật và không trải qua chu kỳ đánh giá thông thường.
  Hãy liên hệ với nhóm bảo mật kernel để biết thêm chi tiết về quy trình này.


Cây cối
-------

- Hàng đợi các bản vá, cho cả phiên bản đã hoàn thành và đang tiến hành
  các phiên bản có thể được tìm thấy tại:

ZZ0000ZZ

- Có thể tìm thấy bản phát hành cuối cùng và được gắn thẻ của tất cả các hạt nhân ổn định
  trong các nhánh riêng biệt cho mỗi phiên bản tại:

ZZ0000ZZ

- Ứng viên phát hành của tất cả các phiên bản kernel ổn định có thể được tìm thấy tại:

ZZ0000ZZ

  .. warning::
     The -stable-rc tree is a snapshot in time of the stable-queue tree and
     will change frequently, hence will be rebased often. It should only be
     used for testing purposes (e.g. to be consumed by CI systems).


Ủy ban xét duyệt
----------------

- Điều này bao gồm một số nhà phát triển hạt nhân đã tình nguyện tham gia
  nhiệm vụ này và một số nhiệm vụ khác thì không.
