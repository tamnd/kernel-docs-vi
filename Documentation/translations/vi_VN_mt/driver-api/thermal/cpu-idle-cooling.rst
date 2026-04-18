.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/cpu-idle-cooling.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================
Làm mát không tải CPU
=====================

Tình huống:
-----------

Trong một số trường hợp nhất định, SoC có thể đạt đến nhiệt độ tới hạn
giới hạn và không thể ổn định nhiệt độ xung quanh nhiệt độ
kiểm soát. Khi SoC phải ổn định nhiệt độ, hạt nhân có thể
hoạt động trên một thiết bị làm mát để giảm thiểu năng lượng tiêu tán. Khi
đạt đến nhiệt độ tới hạn, cần phải đưa ra quyết định để giảm
nhiệt độ, từ đó ảnh hưởng đến hiệu suất.

Một tình huống khác là khi nhiệt độ silicon tiếp tục tăng
tăng ngay cả sau khi rò rỉ động giảm đến mức tối thiểu bằng
đồng hồ kiểm soát thành phần. Hiện tượng chạy trốn này có thể tiếp tục do
đến rò rỉ tĩnh điện. Giải pháp duy nhất là tắt nguồn
thành phần, do đó giảm rò rỉ động và tĩnh sẽ
cho phép thành phần nguội đi.

Cuối cùng nhưng không kém phần quan trọng, hệ thống có thể yêu cầu mức năng lượng cụ thể nhưng
do mật độ OPP nên chúng tôi chỉ có thể chọn OPP có nguồn điện
ngân sách thấp hơn ngân sách được yêu cầu và sử dụng không đúng mức CPU, do đó
mất hiệu suất. Nói cách khác, một OPP sử dụng không đúng mức CPU
với công suất nhỏ hơn mức công suất được yêu cầu và OPP tiếp theo
vượt quá ngân sách điện năng. Một OPP trung gian có thể đã được sử dụng nếu
nó đã có mặt.

Giải pháp:
----------

Nếu chúng ta có thể loại bỏ rò rỉ tĩnh và động cho một trường hợp cụ thể
trong khoảng thời gian được kiểm soát, nhiệt độ SoC sẽ
giảm đi. Hoạt động theo khoảng thời gian ở trạng thái không tải hoặc chu kỳ không tải
trong thời gian tiêm, chúng ta có thể giảm thiểu nhiệt độ bằng cách điều chỉnh
ngân sách điện lực.

Mật độ Điểm hiệu suất hoạt động (OPP) có ảnh hưởng lớn đến
độ chính xác điều khiển của cpufreq, tuy nhiên các nhà cung cấp khác nhau có
rất nhiều mật độ OPP và một số có khoảng cách sức mạnh lớn giữa các OPP,
sẽ dẫn đến mất hiệu suất trong quá trình điều khiển nhiệt và
mất điện trong các tình huống khác.

Tại một OPP cụ thể, chúng ta có thể giả định rằng việc đưa chu kỳ nhàn rỗi vào tất cả các CPU
thuộc cùng một cụm, có thời lượng lớn hơn cụm
trạng thái nhàn rỗi mục tiêu cư trú, chúng tôi dẫn đến thả tĩnh và
rò rỉ động trong giai đoạn này (môđun năng lượng cần thiết để đi vào
trạng thái này). Vì vậy, năng lượng bền vững với chu kỳ nhàn rỗi có tuyến tính
mối quan hệ với sức mạnh bền vững của OPP và có thể được tính toán bằng
hệ số tương tự::

Công suất (IdleCycle) = Coef x Công suất (OPP)

Tiêm nhàn rỗi:
---------------

Khái niệm cơ bản của việc chèn không tải là buộc CPU chuyển sang trạng thái
trạng thái không hoạt động trong một khoảng thời gian nhất định trong mỗi chu kỳ điều khiển, nó cung cấp
một cách khác để kiểm soát năng lượng và nhiệt CPU ngoài
cpufreq. Lý tưởng nhất là nếu tất cả các CPU thuộc cùng một cụm, hãy đưa vào
chu kỳ nhàn rỗi của chúng đồng bộ, cụm có thể tắt nguồn
trạng thái tiêu thụ điện năng tối thiểu và giảm rò rỉ tĩnh
đến gần như bằng không.  Tuy nhiên, việc chèn chu kỳ nhàn rỗi này sẽ bổ sung thêm
độ trễ vì CPU sẽ phải thức dậy từ trạng thái ngủ sâu.

Chúng tôi sử dụng khoảng thời gian chạy không tải cố định để mang lại hiệu suất chấp nhận được
phạt hiệu suất và độ trễ cố định. Giảm thiểu có thể được tăng lên
hoặc giảm đi bằng cách điều chỉnh chu kỳ làm việc của chế độ chạy không tải.

::

^
     |
     |
     |------- -------
     ZZ0000ZZ_______________________ZZ0001ZZ___________

<------>
       nhàn rỗi<---------------------->
                    đang chạy

<------------------------------------------>
              chu kỳ nhiệm vụ 25%


Việc triển khai thiết bị làm mát dựa trên số lượng trạng thái trên
tỷ lệ phần trăm chu kỳ nhiệm vụ. Khi không có biện pháp giảm thiểu nào xảy ra, việc làm mát
trạng thái thiết bị bằng 0, nghĩa là chu kỳ nhiệm vụ là 0%.

Khi việc giảm thiểu bắt đầu, tùy thuộc vào chính sách của thống đốc,
trạng thái bắt đầu được chọn. Với thời gian nhàn rỗi cố định và nhiệm vụ
chu kỳ (hay còn gọi là trạng thái thiết bị làm mát), thời gian chạy có thể là
tính toán.

Bộ điều tốc sẽ thay đổi trạng thái thiết bị làm mát do đó chu kỳ làm việc sẽ thay đổi
và sự thay đổi này sẽ điều chỉnh hiệu ứng làm mát.

::

^
     |
     |
     |------- -------
     ZZ0000ZZ_______________ZZ0001ZZ___________

<------>
       nhàn rỗi <-------------->
                đang chạy

<----------------------->
          chu kỳ nhiệm vụ 33%


^
     |
     |
     |------- -------
     ZZ0000ZZ_______ZZ0001ZZ___________

<------>
       nhàn rỗi <------>
              đang chạy

<------------->
       chu kỳ nhiệm vụ 50%

Giá trị thời gian chèn không tải phải tuân theo các ràng buộc:

- Nó nhỏ hơn hoặc bằng độ trễ mà chúng tôi có thể chịu đựng được khi
  quá trình giảm nhẹ bắt đầu. Nó phụ thuộc vào nền tảng và sẽ phụ thuộc vào
  trải nghiệm người dùng, khả năng phản ứng và sự đánh đổi hiệu suất mà chúng tôi mong muốn. Cái này
  giá trị cần được chỉ định.

- Nó lớn hơn nơi cư trú mục tiêu của trạng thái nhàn rỗi mà chúng tôi muốn đến
  để giảm thiểu nhiệt, nếu không chúng ta sẽ tiêu thụ nhiều năng lượng hơn.

Cân nhắc về quyền lực
---------------------

Khi chúng ta đạt đến điểm ngắt nhiệt, chúng ta phải duy trì một nhiệt độ nhất định
cung cấp năng lượng cho một nhiệt độ cụ thể nhưng tại thời điểm này chúng ta tiêu thụ ::

Công suất = Điện dung x Điện áp^2 x Tần số x Công dụng

... which is more than the sustainable power (or there is something
sai trong thiết lập hệ thống). 'Điện dung' và 'Công dụng' là một
giá trị cố định, 'Điện áp' và 'Tần số' được cố định một cách giả tạo
bởi vì chúng tôi không muốn thay đổi OPP. Chúng ta có thể nhóm các
'Điện dung' và 'Công dụng' thành một thuật ngữ duy nhất là
‘Hệ số công suất động (Cdyn)’ Đơn giản hóa phần trên, chúng ta có::

Pdyn = Cdyn x Điện áp^2 x Tần số

Thống đốc cơ quan phân bổ quyền lực sẽ yêu cầu chúng ta bằng cách nào đó giảm bớt quyền lực của mình
để hướng tới nguồn năng lượng bền vững được xác định trong thiết bị
cây. Vì vậy, với cơ chế tiêm không tải, chúng ta muốn có công suất trung bình
(Ptarget) dẫn đến một khoảng thời gian chạy hết công suất trên một
OPP cụ thể và nhàn rỗi trong một khoảng thời gian khác. Điều đó có thể được đặt trong một
phương trình::

P(opp)target = ((Đang chạy x (P(opp)đang chạy) + (Tidle x P(opp)idle)) /
			(Chạy + Tiddle)

  ...

Tidle = Chạy x ((P(opp)running / P(opp)target) - 1)

Tại thời điểm này, nếu chúng ta biết thời gian chạy của CPU, điều đó cho chúng ta
tiêm nhàn rỗi mà chúng tôi cần. Ngoài ra, nếu chúng ta có thời gian rảnh
thời gian tiêm, chúng ta có thể tính thời lượng chạy bằng::

Đang chạy = Tidle / ((P(opp)running / P(opp)target) - 1)

Thực tế, nếu công suất chạy nhỏ hơn công suất mục tiêu, chúng ta
kết thúc với giá trị thời gian âm, vì vậy rõ ràng việc sử dụng phương trình là
bị ràng buộc với việc giảm công suất, do đó cần có OPP cao hơn để có
công suất hoạt động lớn hơn công suất mục tiêu.

Tuy nhiên, trong phần trình diễn này, chúng tôi bỏ qua ba khía cạnh:

* Rò rỉ tĩnh không được xác định ở đây, chúng ta có thể giới thiệu nó trong
   phương trình nhưng giả sử nó sẽ bằng 0 trong hầu hết thời gian như hiện tại
   khó nhận được giá trị từ các nhà cung cấp SoC

* Độ trễ đánh thức trạng thái không hoạt động (hoặc độ trễ vào + thoát) không
   được tính đến, nó phải được thêm vào phương trình để
   tính toán nghiêm ngặt việc tiêm nhàn rỗi

* Thời lượng không tải được đưa vào phải lớn hơn trạng thái không hoạt động
   nơi cư trú mục tiêu, nếu không chúng ta sẽ tiêu tốn nhiều năng lượng hơn và
   có khả năng đảo ngược tác dụng giảm thiểu

Vậy phương trình cuối cùng là::

Chạy = (Tidle - Twakeup ) x
		(((P(opp)dyn + P(opp)static ) - P(opp)target) / P(opp)target )