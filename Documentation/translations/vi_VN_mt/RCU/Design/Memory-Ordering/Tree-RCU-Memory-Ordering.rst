.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/RCU/Design/Memory-Ordering/Tree-RCU-Memory-Ordering.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================================================
Chuyến tham quan qua thứ tự bộ nhớ thời gian ân hạn của TREE_RCU
======================================================

Ngày 8 tháng 8 năm 2017

Bài viết này được đóng góp bởi Paul E. McKenney

Giới thiệu
============

Tài liệu này cung cấp một cái nhìn tổng quan trực quan sơ bộ về cách thức hoạt động của Tree RCU.
Đảm bảo đặt hàng bộ nhớ trong thời gian gia hạn được cung cấp.

Đảm bảo đặt hàng bộ nhớ trong thời gian ân hạn của Tree RCU là gì?
==========================================================

Thời gian gia hạn RCU cung cấp sự đảm bảo thứ tự bộ nhớ cực kỳ mạnh mẽ
đối với mã không ngoại tuyến không nhàn rỗi.
Bất kỳ mã nào xảy ra sau khi kết thúc thời gian gia hạn RCU nhất định đều được đảm bảo
để xem tác động của tất cả các quyền truy cập trước khi bắt đầu ân hạn đó
khoảng thời gian nằm trong các phần quan trọng của bên đọc RCU.
Tương tự, bất kỳ mã nào xảy ra trước khi bắt đầu thời gian gia hạn RCU nhất định
thời gian được đảm bảo không thấy tác động của tất cả các quyền truy cập sau khi kết thúc
của thời gian gia hạn đó nằm trong các phần quan trọng của bên đọc RCU.

Lưu ý rõ rằng các phần quan trọng phía đọc được lập lịch trình RCU bao gồm bất kỳ vùng nào
mã mà quyền ưu tiên bị vô hiệu hóa.
Cho rằng mỗi lệnh máy riêng lẻ có thể được coi là
một vùng cực kỳ nhỏ của mã bị vô hiệu hóa quyền ưu tiên, người ta có thể nghĩ đến
ZZ0000ZZ là ZZ0001ZZ trên steroid.

Những người cập nhật RCU sử dụng sự đảm bảo này bằng cách chia các bản cập nhật của họ thành
hai giai đoạn, một trong số đó được thực hiện trước thời gian gia hạn và
cái còn lại được thực hiện sau thời gian ân hạn.
Trong trường hợp sử dụng phổ biến nhất, giai đoạn một sẽ loại bỏ một phần tử khỏi
cấu trúc dữ liệu được bảo vệ bằng RCU được liên kết và giai đoạn hai sẽ giải phóng phần tử đó.
Để điều này có hiệu quả, bất kỳ độc giả nào đã chứng kiến trạng thái trước đó
cập nhật giai đoạn một (trong trường hợp thông thường là loại bỏ) không được chứng kiến trạng thái
sau bản cập nhật giai đoạn hai (trong trường hợp thông thường là giải phóng).

Việc triển khai RCU cung cấp sự đảm bảo này bằng cách sử dụng mạng
của các phần quan trọng dựa trên khóa, rào cản bộ nhớ và mỗi CPU
xử lý, như được mô tả trong các phần sau.

Tree RCU Khối xây dựng thứ tự bộ nhớ thời gian ân hạn
=====================================================

Công cụ chính cho việc sắp xếp bộ nhớ trong thời gian gia hạn của RCU là
phần quan trọng cho cấu trúc ZZ0000ZZ
ZZ0001ZZ. Những phần quan trọng này sử dụng các chức năng trợ giúp để khóa
mua lại, bao gồm ZZ0002ZZ,
ZZ0003ZZ và ZZ0004ZZ.
Các đối tác nhả khóa của họ là ZZ0005ZZ,
ZZ0006ZZ, và
ZZ0007ZZ, tương ứng.
Để hoàn thiện, ZZ0008ZZ cũng được cung cấp.
Điểm mấu chốt là các chức năng thu thập khóa, bao gồm
ZZ0009ZZ, tất cả đều gọi ZZ0010ZZ
ngay sau khi lấy được khóa thành công.

Do đó, đối với bất kỳ cấu trúc ZZ0000ZZ nào, mọi quyền truy cập
xảy ra trước khi một trong các chức năng mở khóa ở trên được nhìn thấy
bởi tất cả các CPU xảy ra trước bất kỳ truy cập nào xảy ra sau một
một trong những chức năng thu thập khóa ở trên.
Hơn nữa, bất kỳ truy cập nào xảy ra trước một trong các
chức năng mở khóa ở trên trên bất kỳ CPU nào sẽ được nhìn thấy bởi tất cả mọi người
CPU xảy ra trước bất kỳ quyền truy cập nào xảy ra sau lần truy cập sau
trong số các chức năng thu thập khóa ở trên thực thi trên cùng CPU đó,
ngay cả khi chức năng nhả khóa và thu khóa đang hoạt động
trên các cấu trúc ZZ0001ZZ khác nhau.
Cây RCU sử dụng hai đảm bảo đặt hàng này để tạo thành một đơn đặt hàng
mạng giữa tất cả các CPU có liên quan đến ân sủng theo bất kỳ cách nào
trong khoảng thời gian, bao gồm mọi CPU trực tuyến hoặc ngoại tuyến trong thời gian
thời gian ân hạn được đề cập.

Phép thử giấy quỳ sau đây cho thấy tác dụng sắp xếp của các
chức năng thu thập khóa và mở khóa::

1 int x, y, z;
    2
    3 khoảng trống task0(void)
    4 {
    5 raw_spin_lock_rcu_node(rnp);
    6 WRITE_ONCE(x, 1);
    7 r1 = READ_ONCE(y);
    8 raw_spin_unlock_rcu_node(rnp);
    9 }
   10
   11 khoảng trống nhiệm vụ1(void)
   12 {
   13 raw_spin_lock_rcu_node(rnp);
   14 WRITE_ONCE(y, 1);
   15 r2 = READ_ONCE(z);
   16 raw_spin_unlock_rcu_node(rnp);
   17 }
   18
   19 khoảng trống nhiệm vụ2(void)
   20 {
   21 WRITE_ONCE(z, 1);
   22 smp_mb();
   23 r3 = READ_ONCE(x);
   24 }
   25
   26 WARN_ON(r1 == 0 && r2 == 0 && r3 == 0);

ZZ0000ZZ được đánh giá ở "ngày tận thế",
sau khi tất cả các thay đổi đã được lan truyền khắp hệ thống.
Nếu không có ZZ0001ZZ được cung cấp bởi
chức năng thu thập dữ liệu, chẳng hạn như ZZ0002ZZ này có thể kích hoạt
trên PowerPC.
Các lệnh gọi ZZ0003ZZ ngăn chặn điều này
ZZ0004ZZ khỏi kích hoạt.

+--------------------------------------------------------------------------------------- +
ZZ0002ZZ
+--------------------------------------------------------------------------------------- +
ZZ0003ZZ
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
ZZ0020ZZ
ZZ0021ZZ
ZZ0022ZZ
ZZ0023ZZ
ZZ0024ZZ
+--------------------------------------------------------------------------------------- +

Cách tiếp cận này phải được mở rộng để bao gồm các CPU nhàn rỗi, cần
Đảm bảo đặt hàng bộ nhớ trong thời gian gia hạn của RCU sẽ mở rộng tới bất kỳ
RCU các phần quan trọng phía đọc trước và sau phần hiện tại
tạm trú nhàn rỗi.
Trường hợp này được xử lý bằng cách gọi tới hàm strong order
Hoạt động nguyên tử đọc-sửa-ghi ZZ0000ZZ
được gọi trong ZZ0001ZZ khi vào nhàn rỗi
thời gian và trong ZZ0002ZZ tại thời điểm thoát nhàn rỗi.
Kthread trong thời gian gia hạn gọi ZZ0003ZZ đầu tiên
(trước đó là hàng rào bộ nhớ đầy đủ) và ZZ0004ZZ
(cả hai đều dựa vào ngữ nghĩa thu được) để phát hiện CPU nhàn rỗi.

+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
+--------------------------------------------------------------------------------------- +

Cách tiếp cận này phải được mở rộng để giải quyết một trường hợp cuối cùng, đó là việc đánh thức một
nhiệm vụ bị chặn trong ZZ0000ZZ. Nhiệm vụ này có thể gắn liền với
CPU chưa biết rằng thời gian gia hạn đã kết thúc và do đó
có thể chưa tuân theo thứ tự bộ nhớ của thời gian gia hạn.
Do đó, có ZZ0001ZZ sau khi trở về từ
ZZ0002ZZ trong đường dẫn mã ZZ0003ZZ.

+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
+--------------------------------------------------------------------------------------- +

Sự đảm bảo về thứ tự bộ nhớ theo thời gian của Tree RCU phụ thuộc nhiều nhất vào
trường ZZ0001ZZ của cấu trúc ZZ0000ZZ, nhiều đến mức nó
cần thiết phải viết tắt mẫu này trong các sơ đồ ở phần tiếp theo
phần. Ví dụ: hãy xem xét hàm ZZ0002ZZ
được hiển thị bên dưới, đây là một trong nhiều chức năng thực thi thứ tự của
Lệnh gọi lại RCU mới đến trong thời gian gia hạn trong tương lai:

::

1 khoảng trống tĩnh rcu_prepare_for_idle(void)
    2 {
    3 bool cần thức tỉnh;
    4 cấu trúc rcu_data *rdp = this_cpu_ptr(&rcu_data);
    5 cấu trúc rcu_node *rnp;
    6 int;
    7
    8 lockdep_assert_irqs_disabled();
    9 nếu (rcu_rdp_is_offloaded(rdp))
   10 trở lại;
   11
   12 /* Xử lý thận trọng các công tắc kích hoạt nohz. */
   13 tne = READ_ONCE(tick_nohz_active);
   14 if (tne != rdp->tick_nohz_enabled_snap) {
   15 if (!rcu_segcblist_empty(&rdp->cblist))
   16 gọi_rcu_core(); /* buộc nohz xem bản cập nhật. */
   17 rdp->tick_nohz_enabled_snap = tne;
   18 trở về;
   19 }
   20 nếu (!tne)
   21 trở về;
   22
   23 /*
   24 * Nếu chúng ta chưa tăng tốc nhanh chóng này, hãy tăng tốc tất cả
   25 * số lượt gọi lại trên CPU này.
   26 */
   27 if (rdp->last_accelerate == jiffies)
   28 trở về;
   29 rdp->last_accelerate = nháy mắt;
   30 if (rcu_segcblist_pend_cbs(&rdp->cblist)) {
   31 rnp = rdp->mynode;
   32 raw_spin_lock_rcu_node(rnp); /* irqs đã bị vô hiệu hóa. */
   33 cần thức = rcu_accelerate_cbs(rnp, rdp);
   34 raw_spin_unlock_rcu_node(rnp); /* irqs vẫn bị vô hiệu hóa. */
   35 nếu (cần thức dậy)
   36 rcu_gp_kthread_wake();
   37 }
   38 }

Nhưng phần duy nhất của ZZ0000ZZ thực sự quan trọng đối với
cuộc thảo luận này là dòng 32–34. Vì vậy chúng tôi sẽ viết tắt điều này
chức năng như sau:

.. kernel-figure:: rcu_node-lock.svg

Hộp đại diện cho ZZ0001ZZ quan trọng của cấu trúc ZZ0000ZZ
phần, với dòng đôi ở trên thể hiện phần bổ sung
ZZ0002ZZ.

Cây RCU Các thành phần thứ tự bộ nhớ thời gian gia hạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bảo đảm sắp xếp bộ nhớ trong thời gian gia hạn của Tree RCU được cung cấp bởi một
số lượng thành phần RCU:

#. ZZ0000ZZ
#. ZZ0001ZZ
#. ZZ0002ZZ
#. ZZ0003ZZ
#. ZZ0004ZZ
#. ZZ0005ZZ
#. ZZ0006ZZ
#. ZZ0007ZZ

Mỗi phần sau đây xem xét thành phần tương ứng trong
chi tiết.

Đăng ký gọi lại
^^^^^^^^^^^^^^^^^

Nếu bảo đảm thời gian gia hạn của RCU có ý nghĩa gì đó thì mọi quyền truy cập
điều đó xảy ra trước một lệnh gọi ZZ0000ZZ nhất định cũng phải
xảy ra trước thời gian ân hạn tương ứng. Việc thực hiện điều này
phần bảo đảm thời gian ân hạn của RCU được trình bày dưới đây
hình:

.. kernel-figure:: TreeRCU-callback-registry.svg

Bởi vì ZZ0000ZZ thường chỉ hoạt động ở trạng thái cục bộ CPU, nên nó
không cung cấp bảo đảm đặt hàng cho chính nó hoặc cho giai đoạn một của
bản cập nhật (thường sẽ loại bỏ một phần tử khỏi một
Cấu trúc dữ liệu được bảo vệ RCU). Nó chỉ đơn giản là xếp hàng ZZ0001ZZ
cấu trúc trên danh sách mỗi CPU, không thể liên kết với ân hạn
khoảng thời gian cho đến cuộc gọi sau tới ZZ0002ZZ, như được hiển thị trong
sơ đồ trên.

Một bộ đường dẫn mã hiển thị bên trái gọi ZZ0000ZZ
qua ZZ0001ZZ, trực tiếp từ ZZ0002ZZ (nếu
CPU hiện tại tràn ngập các cấu trúc ZZ0003ZZ được xếp hàng đợi) trở lên
có thể từ trình xử lý ZZ0004ZZ. Một đường dẫn mã khác ở giữa
chỉ được lấy trong các hạt nhân được xây dựng bằng ZZ0005ZZ,
gọi ZZ0006ZZ thông qua ZZ0007ZZ. các
đường dẫn mã cuối cùng ở bên phải chỉ được lấy trong các hạt nhân được xây dựng bằng
ZZ0008ZZ, gọi ZZ0009ZZ thông qua
ZZ0010ZZ, ZZ0011ZZ,
ZZ0012ZZ và ZZ0013ZZ, lần lượt
được gọi trên CPU còn sót lại sau khi CPU đi ra đã được kích hoạt hoàn toàn
ngoại tuyến.

Có một vài đường dẫn mã khác trong quá trình xử lý thời gian gia hạn
cơ hội gọi ZZ0000ZZ. Tuy nhiên, dù thế nào đi nữa,
tất cả các cấu trúc ZZ0001ZZ được xếp hàng gần đây của CPU đều được liên kết
với số thời gian gia hạn trong tương lai dưới sự bảo vệ của CPU
ZZ0002ZZ của cấu trúc ZZ0003ZZ. Trong mọi trường hợp đều có đầy đủ
sắp xếp theo bất kỳ phần quan trọng nào trước đó cho cùng ZZ0004ZZ đó
ZZ0005ZZ của cấu trúc và cũng có thể đặt hàng đầy đủ đối với bất kỳ
các phần quan trọng trước đây của nhiệm vụ hiện tại hoặc của CPU đối với bất kỳ ZZ0006ZZ nào
cấu trúc ZZ0007ZZ.

Phần tiếp theo sẽ chỉ ra cách thứ tự này đảm bảo rằng mọi quyền truy cập
trước ZZ0000ZZ (đặc biệt bao gồm giai đoạn một của
update) xảy ra trước khi bắt đầu thời gian gia hạn tương ứng.

+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
+--------------------------------------------------------------------------------------- +

Khởi tạo thời gian gia hạn
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc khởi tạo thời gian gia hạn được thực hiện bởi hạt nhân thời gian gia hạn
luồng, thực hiện một số lần chuyển qua cây ZZ0000ZZ trong
Chức năng ZZ0001ZZ. Điều này có nghĩa là hiển thị toàn bộ luồng của
đặt hàng thông qua tính toán trong thời gian ân hạn sẽ yêu cầu sao chép
cây này. Nếu bạn thấy điều này khó hiểu, xin lưu ý rằng trạng thái của
ZZ0002ZZ thay đổi theo thời gian, giống như dòng sông của Heraclitus. Tuy nhiên,
để giữ cho dòng sông ZZ0003ZZ có thể điều khiển được, hạt nhân trong thời gian gia hạn
quá trình duyệt của luồng được trình bày thành nhiều phần, bắt đầu từ phần này
phần với các giai đoạn khác nhau của quá trình khởi tạo thời gian gia hạn.

Hành động khởi tạo thời gian gia hạn liên quan đến đơn hàng đầu tiên là
nâng cao số thời gian gia hạn ZZ0000ZZ của cấu trúc ZZ0001ZZ
bộ đếm như hình dưới đây:

.. kernel-figure:: TreeRCU-gp-init-1.svg

Việc tăng thực tế được thực hiện bằng cách sử dụng ZZ0000ZZ,
giúp loại bỏ việc phát hiện RCU CPU dương tính giả. Lưu ý rằng chỉ có
cấu trúc gốc ZZ0001ZZ được chạm vào.

Lần đầu tiên đi qua cây ZZ0000ZZ cập nhật mặt nạ bit dựa trên
CPU đã trực tuyến hoặc ngoại tuyến kể từ khi bắt đầu phiên bản trước
thời gian ân hạn. Trong trường hợp phổ biến khi số lượng CPU trực tuyến cho
cấu trúc ZZ0001ZZ này chưa được chuyển sang hoặc từ 0, điều này
pass sẽ chỉ quét các cấu trúc ZZ0002ZZ lá. Tuy nhiên, nếu
số lượng CPU trực tuyến cho một cấu trúc ZZ0003ZZ lá nhất định có
được chuyển từ 0, ZZ0004ZZ sẽ được gọi cho
CPU đến đầu tiên. Tương tự, nếu số lượng CPU trực tuyến cho một
cấu trúc lá ZZ0005ZZ đã chuyển sang 0,
ZZ0006ZZ sẽ được gọi cho CPU gửi đi cuối cùng.
Sơ đồ bên dưới thể hiện đường dẫn đặt hàng nếu ngoài cùng bên trái
Cấu trúc ZZ0007ZZ trực tuyến CPU đầu tiên của nó và nếu tiếp theo
Cấu trúc ZZ0008ZZ không có CPU trực tuyến (hoặc, cách khác, nếu
Cấu trúc ZZ0009ZZ ngoài cùng bên trái sẽ ngoại tuyến CPU cuối cùng của nó và nếu cấu trúc tiếp theo
Cấu trúc ZZ0010ZZ không có CPU trực tuyến).

.. kernel-figure:: TreeRCU-gp-init-2.svg

ZZ0000ZZ cuối cùng đi qua cây ZZ0001ZZ
theo chiều rộng, thiết lập trường ZZ0003ZZ của mỗi cấu trúc ZZ0002ZZ
đến giá trị mới nâng cao từ cấu trúc ZZ0004ZZ, như được hiển thị
trong sơ đồ sau.

.. kernel-figure:: TreeRCU-gp-init-3.svg

Thay đổi này cũng sẽ khiến cuộc gọi tiếp theo của mỗi CPU tới
ZZ0000ZZ để thông báo rằng thời gian gia hạn mới đã bắt đầu,
như được mô tả trong phần tiếp theo. Nhưng vì kthread có thời gian gia hạn
bắt đầu thời gian ân hạn từ gốc (với sự tiến bộ của
trường ZZ0002ZZ của cấu trúc ZZ0001ZZ) trước khi thiết lập từng lá
Trường ZZ0004ZZ của cấu trúc ZZ0003ZZ, quan sát của mỗi CPU về
thời điểm bắt đầu thời gian ân hạn sẽ diễn ra sau khi thời gian bắt đầu thực tế
thời gian ân hạn.

+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +
ZZ0010ZZ
+--------------------------------------------------------------------------------------- +
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
ZZ0016ZZ
ZZ0017ZZ
ZZ0018ZZ
ZZ0019ZZ
+--------------------------------------------------------------------------------------- +

Tự báo cáo trạng thái yên tĩnh
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Khi tất cả các thực thể có thể chặn thời gian gia hạn đã báo cáo
trạng thái tĩnh (hoặc như được mô tả ở phần sau, có trạng thái tĩnh
các tiểu bang thay mặt họ báo cáo), thời gian gia hạn có thể kết thúc. trực tuyến
CPU không rảnh sẽ báo cáo trạng thái không hoạt động của chính chúng, như được hiển thị trong
sơ đồ sau:

.. kernel-figure:: TreeRCU-qs.svg

Đây là lần cuối cùng CPU báo cáo trạng thái không hoạt động, báo hiệu
kết thúc thời gian ân hạn. Các trạng thái tĩnh trước đó sẽ đẩy lên
Chỉ cây ZZ0000ZZ cho đến khi gặp cấu trúc ZZ0001ZZ
đang chờ đợi các trạng thái tĩnh bổ sung. Tuy nhiên, việc đặt hàng là
tuy nhiên vẫn được bảo tồn vì một số trạng thái không hoạt động sau này sẽ có được
ZZ0003ZZ của cấu trúc ZZ0002ZZ đó.

Bất kỳ số lượng sự kiện nào cũng có thể dẫn đến CPU gọi ZZ0000ZZ
(hoặc cách khác là gọi trực tiếp ZZ0001ZZ), tại đó
điểm rằng CPU sẽ thông báo bắt đầu thời gian gia hạn mới trong khi nắm giữ
khóa ZZ0002ZZ lá của nó. Vì vậy, tất cả việc thực hiện được hiển thị trong này
sơ đồ xảy ra sau khi bắt đầu thời gian gia hạn. Ngoài ra, điều này
CPU sẽ xem xét mọi phần quan trọng phía đọc RCU đã bắt đầu trước đó
lệnh gọi ZZ0003ZZ đã bắt đầu trước
thời gian ân hạn, và do đó, một phần quan trọng mà thời gian ân hạn phải
chờ đã.

+--------------------------------------------------------------------------------------- +
ZZ0003ZZ
+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
+--------------------------------------------------------------------------------------- +
ZZ0008ZZ
+--------------------------------------------------------------------------------------- +
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
+--------------------------------------------------------------------------------------- +

Nếu CPU thực hiện chuyển đổi ngữ cảnh, trạng thái không hoạt động sẽ được ghi nhận bởi
ZZ0000ZZ ở bên trái. Mặt khác, nếu CPU
nhận một ngắt đồng hồ lập lịch trong khi thực thi ở chế độ người dùng, một
trạng thái không hoạt động sẽ được ZZ0001ZZ ghi chú ở bên phải.
Dù bằng cách nào, việc đi qua trạng thái tĩnh lặng sẽ được ghi nhận trong một
biến mỗi CPU.

Lần tiếp theo trình xử lý ZZ0000ZZ thực thi trên CPU này (đối với
Ví dụ: sau lần ngắt đồng hồ lập lịch tiếp theo), ZZ0001ZZ sẽ
gọi ZZ0002ZZ, nó sẽ thông báo
trạng thái không hoạt động và gọi ZZ0003ZZ. Nếu
ZZ0004ZZ xác minh rằng trạng thái tĩnh thực sự có
áp dụng cho thời gian gia hạn hiện tại, nó sẽ gọi ZZ0005ZZ
duyệt cây ZZ0006ZZ như được hiển thị ở cuối
sơ đồ, xóa các bit từ ZZ0008ZZ của mỗi cấu trúc ZZ0007ZZ
trường và truyền lên cây khi kết quả bằng 0.

Lưu ý rằng quá trình truyền tải đi lên trên cấu trúc ZZ0000ZZ đã cho
chỉ khi CPU hiện tại đang báo cáo trạng thái không hoạt động cuối cùng cho
cây con đứng đầu là cấu trúc ZZ0001ZZ đó. Điểm mấu chốt là nếu một
Quá trình truyền tải của CPU dừng ở cấu trúc ZZ0002ZZ nhất định, sau đó sẽ
được truyền tải sau đó bởi một CPU khác (hoặc có lẽ là cùng một)
tiến lên từ điểm đó và ZZ0003ZZ ZZ0004ZZ
đảm bảo rằng trạng thái không hoạt động của CPU đầu tiên xảy ra trước
phần còn lại của quá trình truyền tải CPU thứ hai. Áp dụng dòng suy nghĩ này
liên tục cho thấy rằng tất cả các trạng thái không hoạt động của CPU đều xảy ra trước lần cuối cùng
CPU đi qua cấu trúc ZZ0005ZZ gốc, “CPU cuối cùng”
là cái xóa bit cuối cùng trong thư mục gốc ZZ0006ZZ
trường ZZ0007ZZ của cấu trúc.

Giao diện đánh dấu động
^^^^^^^^^^^^^^^^^^^^^^

Do cân nhắc về hiệu quả năng lượng, RCU bị cấm sử dụng
làm phiền các CPU nhàn rỗi. Do đó, CPU phải thông báo cho RCU khi
vào hoặc rời khỏi trạng thái không hoạt động, họ thực hiện thông qua việc đặt hàng đầy đủ
các hoạt động nguyên tử trả về giá trị trên một biến per-CPU. Việc đặt hàng
các hiệu ứng như hình dưới đây:

.. kernel-figure:: TreeRCU-dyntick.svg

Chuỗi hạt nhân thời gian gia hạn RCU lấy mẫu biến trạng thái nhàn rỗi trên mỗi CPU
trong khi giữ cấu trúc ZZ0000ZZ lá của CPU tương ứng
ZZ0001ZZ. Điều này có nghĩa là bất kỳ phần quan trọng nào của RCU phía đọc
trước khoảng thời gian nhàn rỗi (hình bầu dục gần đầu sơ đồ trên)
sẽ xảy ra trước khi kết thúc thời gian ân hạn hiện tại. Tương tự, các
thời gian gia hạn hiện tại sẽ bắt đầu trước bất kỳ RCU nào
các phần quan trọng phía đọc theo sau khoảng thời gian nhàn rỗi (hình bầu dục gần
phần dưới của sơ đồ trên).

Việc đưa điều này vào quá trình thực thi thời gian gia hạn đầy đủ được mô tả
ZZ0000ZZ.

Giao diện cắm nóng CPU
^^^^^^^^^^^^^^^^^^^^^

RCU cũng bị cấm làm phiền các CPU ngoại tuyến, điều này có thể
tắt nguồn và xóa hoàn toàn khỏi hệ thống. Do đó, các CPU
được yêu cầu thông báo cho RCU về việc đến và đi của họ như một phần của
hoạt động cắm nóng CPU tương ứng. Hiệu ứng thứ tự được hiển thị
dưới đây:

.. kernel-figure:: TreeRCU-hotplug.svg

Bởi vì các hoạt động cắm nóng CPU ít thường xuyên hơn so với khi không hoạt động
chuyển tiếp, chúng có trọng lượng nặng hơn và do đó thu được lá của CPU
ZZ0000ZZ của cấu trúc ZZ0001ZZ và cập nhật cấu trúc này
ZZ0002ZZ. Chuỗi hạt nhân thời gian gia hạn RCU lấy mẫu này
mặt nạ để phát hiện các CPU đã ngoại tuyến kể từ khi bắt đầu quá trình này
thời gian ân hạn.

Việc đưa điều này vào quá trình thực thi thời gian gia hạn đầy đủ được mô tả
ZZ0000ZZ.

Buộc trạng thái tĩnh
^^^^^^^^^^^^^^^^^^^^^^^^

Như đã lưu ý ở trên, CPU nhàn rỗi và ngoại tuyến không thể báo cáo trạng thái không hoạt động của chính chúng.
trạng thái, và do đó, luồng hạt nhân trong thời gian gia hạn phải thực hiện
báo cáo thay mặt họ. Quá trình này được gọi là “buộc tĩnh
trạng thái”, nó được lặp lại cứ sau vài giây và hiệu ứng trật tự của nó là
hiển thị dưới đây:

.. kernel-figure:: TreeRCU-gp-fqs.svg

Mỗi lần buộc ở trạng thái tĩnh được đảm bảo đi ngang qua lá
Cấu trúc ZZ0000ZZ và nếu không có trạng thái tĩnh mới do
các CPU không hoạt động và/hoặc ngoại tuyến gần đây thì chỉ các lá được duyệt qua.
Tuy nhiên, nếu có CPU mới ngoại tuyến như minh họa ở bên trái hoặc
một chiếc CPU mới không hoạt động như minh họa bên phải, tương ứng
trạng thái tĩnh sẽ được đẩy lên về phía gốc. Như với
trạng thái không hoạt động tự báo cáo, việc lái xe đi lên sẽ dừng lại khi nó
đạt đến cấu trúc ZZ0001ZZ có trạng thái tĩnh vượt trội
từ các CPU khác.

+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
ZZ0006ZZ
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
+--------------------------------------------------------------------------------------- +
ZZ0010ZZ
+--------------------------------------------------------------------------------------- +
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
ZZ0015ZZ
+--------------------------------------------------------------------------------------- +

Dọn dẹp thời gian gia hạn
^^^^^^^^^^^^^^^^^^^^

Việc dọn dẹp trong thời gian gia hạn sẽ quét theo chiều rộng của cây ZZ0000ZZ trước tiên
nâng cao tất cả các trường ZZ0001ZZ, sau đó nó sẽ nâng cao
Trường ZZ0003ZZ của cấu trúc ZZ0002ZZ. Các hiệu ứng sắp xếp là
hiển thị dưới đây:

.. kernel-figure:: TreeRCU-gp-cleanup.svg

Như được biểu thị bằng hình bầu dục ở cuối sơ đồ, khi thời gian gia hạn
việc dọn dẹp hoàn tất, thời gian gia hạn tiếp theo có thể bắt đầu.

+--------------------------------------------------------------------------------------- +
ZZ0004ZZ
+--------------------------------------------------------------------------------------- +
ZZ0005ZZ
+--------------------------------------------------------------------------------------- +
ZZ0006ZZ
+--------------------------------------------------------------------------------------- +
ZZ0007ZZ
ZZ0008ZZ
ZZ0009ZZ
ZZ0010ZZ
ZZ0011ZZ
ZZ0012ZZ
ZZ0013ZZ
ZZ0014ZZ
+--------------------------------------------------------------------------------------- +

Lời gọi gọi lại
^^^^^^^^^^^^^^^^^^^

Khi trường ZZ0001ZZ của cấu trúc ZZ0000ZZ lá của CPU nhất định có
đã được cập nhật, CPU có thể bắt đầu gọi các lệnh gọi lại RCU đã được
chờ đợi thời gian ân hạn này kết thúc. Những cuộc gọi lại này được xác định bởi
ZZ0002ZZ, thường được gọi bởi
ZZ0003ZZ. Như được hiển thị trong sơ đồ bên dưới, lời gọi này
có thể được kích hoạt bởi ngắt đồng hồ lập lịch
(ZZ0004ZZ ở bên trái) hoặc bằng cách vào nhàn rỗi
(ZZ0005ZZ ở bên phải, nhưng chỉ dành cho xây dựng hạt nhân
với ZZ0006ZZ). Dù sao đi nữa, ZZ0007ZZ là
được nâng lên, dẫn đến việc ZZ0008ZZ gọi các lệnh gọi lại,
điều này cho phép các cuộc gọi lại đó được thực hiện (trực tiếp hoặc
gián tiếp thông qua việc đánh thức) quá trình xử lý giai đoạn hai cần thiết cho mỗi bản cập nhật.

.. kernel-figure:: TreeRCU-callback-invocation.svg

Xin lưu ý rằng việc gọi lại cũng có thể được nhắc nhở bởi bất kỳ số nào
của các đường dẫn mã trường hợp góc, ví dụ: khi CPU lưu ý rằng nó có
quá nhiều cuộc gọi lại được xếp hàng đợi. Trong mọi trường hợp, CPU thu được
ZZ0001ZZ của cấu trúc ZZ0000ZZ lá của nó trước khi gọi lệnh gọi lại,
duy trì thứ tự cần thiết so với ân hạn mới hoàn thành
kỳ.

Tuy nhiên, nếu chức năng gọi lại giao tiếp với các CPU khác, đối với
Ví dụ: thực hiện đánh thức, thì trách nhiệm của chức năng đó là
duy trì trật tự. Ví dụ: nếu chức năng gọi lại đánh thức một tác vụ
chạy trên một số CPU khác, phải có thứ tự phù hợp trong cả
chức năng gọi lại và nhiệm vụ được đánh thức. Để xem tại sao điều này là
quan trọng, hãy xem xét nửa trên của sơ đồ ZZ0002ZZ. Cuộc gọi lại có thể là
chạy trên CPU tương ứng với lá ngoài cùng bên trái ZZ0000ZZ
cấu trúc và đánh thức một tác vụ chạy trên CPU tương ứng với
cấu trúc ZZ0001ZZ lá ngoài cùng bên phải và hạt nhân thời gian gia hạn
thread có thể chưa đến được lá ngoài cùng bên phải. Trong trường hợp này,
Thứ tự bộ nhớ của thời gian gia hạn có thể chưa đạt đến CPU đó, vì vậy
một lần nữa chức năng gọi lại và tác vụ được đánh thức phải cung cấp thích hợp
đặt hàng.

Đặt tất cả lại với nhau
~~~~~~~~~~~~~~~~~~~~~~~

Một sơ đồ được ghép lại với nhau ở đây:

.. kernel-figure:: TreeRCU-gp.svg

Tuyên bố pháp lý
~~~~~~~~~~~~~~~

Tác phẩm này thể hiện quan điểm của tác giả và không nhất thiết
đại diện cho quan điểm của IBM.

Linux là nhãn hiệu đã đăng ký của Linus Torvalds.

Tên công ty, sản phẩm và dịch vụ khác có thể là nhãn hiệu hoặc dịch vụ
dấu ấn của người khác.
