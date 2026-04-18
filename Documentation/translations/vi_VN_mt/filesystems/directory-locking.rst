.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/directory-locking.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
Khóa thư mục
===================


Sơ đồ khóa được sử dụng cho các hoạt động thư mục dựa trên hai
các loại khóa - trên mỗi inode (->i_rwsem) và trên mỗi hệ thống tập tin
(->s_vfs_rename_mutex).

Khi lấy i_rwsem trên nhiều đối tượng không có thư mục, chúng tôi
luôn thu được các khóa theo thứ tự bằng cách tăng địa chỉ.  Chúng tôi sẽ gọi
thứ tự "con trỏ inode" đó như sau.


nguyên thủy
==========

Đối với mục đích của chúng tôi, tất cả các hoạt động đều thuộc 6 lớp:

1. truy cập đọc.  Quy tắc khóa:

* khóa thư mục chúng tôi đang truy cập (được chia sẻ)

2. tạo đối tượng.  Quy tắc khóa:

* khóa thư mục chúng tôi đang truy cập (độc quyền)

3. loại bỏ đối tượng.  Quy tắc khóa:

* khóa cha mẹ (độc quyền)
	* tìm nạn nhân
	* khóa nạn nhân (độc quyền)

4. tạo liên kết.  Quy tắc khóa:

* khóa cha mẹ (độc quyền)
	* kiểm tra xem nguồn không phải là một thư mục
	* khóa nguồn (độc quyền; có thể bị suy yếu khi chia sẻ)

5. đổi tên thành _not_ xuyên thư mục.  Quy tắc khóa:

* khóa cha mẹ (độc quyền)
	* tìm nguồn và đích
	* quyết định nguồn và mục tiêu nào cần được khóa.
	  Nguồn cần phải bị khóa nếu đó không phải là thư mục, mục tiêu - nếu đó là
	  không có thư mục hoặc sắp bị xóa.
	* lấy các ổ khóa cần lấy (độc quyền), theo thứ tự con trỏ inode
	  nếu cần lấy cả hai (điều đó chỉ có thể xảy ra khi cả nguồn và đích
	  không phải là thư mục - nguồn vì nó không cần phải khóa
	  mặt khác và mục tiêu vì trộn thư mục và phi thư mục là
	  chỉ được phép với RENAME_EXCHANGE và điều đó sẽ không loại bỏ mục tiêu).

6. đổi tên nhiều thư mục.  Khó nhất trong cả nhóm.  Quy tắc khóa:

* khóa hệ thống tập tin
	* nếu cha mẹ không có tổ tiên chung, thao tác sẽ thất bại.
	* khóa cha mẹ theo thứ tự "tổ tiên trước tiên" (độc quyền). Nếu không phải là một
	  tổ tiên của bên kia, khóa cha mẹ của nguồn trước.
	* tìm nguồn và mục tiêu.
	* xác minh rằng nguồn không phải là hậu duệ của mục tiêu và
	  mục tiêu không phải là hậu duệ của nguồn; thất bại trong hoạt động khác.
	* khóa các thư mục con liên quan (độc quyền), nguồn trước đích.
	* khóa các thư mục không liên quan (độc quyền), theo thứ tự con trỏ inode.

Các quy tắc trên rõ ràng đảm bảo rằng tất cả các thư mục đang hoạt động
được đọc, sửa đổi hoặc xóa bằng phương thức sẽ bị người gọi khóa.


nối
========

Có một điều nữa cần xem xét - nối.  Đó không phải là một hoạt động
theo đúng nghĩa của nó; nó có thể xảy ra như một phần của việc tra cứu.  Chúng tôi nói về
thao tác trên cây thư mục, nhưng rõ ràng là chúng ta không có đầy đủ
hình ảnh của những thứ đó - đặc biệt là đối với các hệ thống tập tin mạng.  Những gì chúng tôi có
là một loạt các cây con hiển thị trong dcache và việc khóa xảy ra trên những cây con đó.
Cây cối phát triển khi chúng ta thực hiện các hoạt động; áp lực trí nhớ cắt giảm chúng.  Thông thường
đó không phải là vấn đề, nhưng có một sự thay đổi khó chịu - chúng ta nên làm gì
khi một cây đang lớn đâm vào gốc của một cây khác?  Điều đó có thể xảy ra ở
một số kịch bản, bắt đầu từ "ai đó đã gắn hai cây con lồng nhau
từ cùng một máy chủ NFS4 và thực hiện tra cứu ở một trong số chúng đã đạt tới
gốc rễ của cái khác"; cũng có những thứ mở theo từng tay cầm và có một
khả năng thư mục chúng ta thấy ở một nơi bị máy chủ di chuyển
sang cái khác và chúng tôi gặp phải nó khi tra cứu.

Vì nhiều lý do, chúng tôi muốn có cùng một thư mục trong dcache
chỉ một lần.  Nhiều bí danh không được phép.  Vì vậy, khi tra cứu chạy vào
một thư mục con đã có bí danh, cần phải làm gì đó với
cây dcache.  Tra cứu đã khóa cha mẹ.  Nếu bí danh là
một gốc của cây riêng biệt, nó sẽ được gắn vào thư mục chúng ta đang thực hiện
tra cứu dưới cái tên mà chúng tôi đang tìm kiếm.  Nếu bí danh đã có
một thư mục con của thư mục chúng ta đang tìm kiếm, nó sẽ đổi tên thành thư mục con
chúng tôi đã tìm kiếm.  Không có khóa bổ sung nào liên quan đến hai trường hợp này.
Tuy nhiên, nếu nó là con của một thư mục khác thì mọi việc sẽ phức tạp hơn.
Trước hết, chúng tôi xác minh rằng đó là ZZ0000ZZ, tổ tiên của thư mục của chúng tôi
và thất bại trong việc tra cứu nếu có.  Sau đó, chúng tôi cố gắng khóa hệ thống tập tin và
cha mẹ hiện tại của bí danh.  Nếu một trong hai lần thử không thành công, chúng tôi sẽ không tra cứu được.
Nếu khóa thử thành công, chúng tôi sẽ tách bí danh khỏi cha mẹ hiện tại của nó và
đính kèm vào thư mục của chúng tôi, dưới tên mà chúng tôi đang tìm kiếm.

Lưu ý rằng việc ghép nối ZZ0000ZZ liên quan đến bất kỳ sửa đổi nào của hệ thống tập tin;
tất cả những gì chúng tôi thay đổi là chế độ xem trong dcache.  Hơn nữa, giữ một thư mục bị khóa
độc quyền ngăn chặn những thay đổi như vậy liên quan đến con cái của nó và nắm giữ
khóa hệ thống tập tin ngăn chặn bất kỳ thay đổi nào về cấu trúc liên kết cây, ngoại trừ việc có một
gốc của cây này trở thành thư mục con của cây khác.  Đặc biệt,
nếu hai răng giả được tìm thấy có một tổ tiên chung sau khi lấy
khóa hệ thống tập tin, mối quan hệ của chúng sẽ không thay đổi cho đến khi
ổ khóa bị rơi.  Vì vậy, từ quan điểm của hoạt động thư mục
nối gần như không liên quan - nơi duy nhất quan trọng là một
bước đổi tên nhiều thư mục; chúng ta cần phải cẩn thận khi kiểm tra xem
bố mẹ có một tổ tiên chung.


Nội dung đa hệ thống tập tin
=========================

Đối với một số hệ thống tập tin, một phương thức có thể liên quan đến thao tác thư mục trên
một hệ thống tập tin khác; nó có thể là các ecryptfs đang hoạt động trong cơ sở
hệ thống tập tin, lớp phủ làm gì đó với các lớp, hệ thống tập tin mạng
sử dụng bộ đệm cục bộ làm bộ đệm, v.v. Trong tất cả các trường hợp như vậy, các hoạt động
trên các hệ thống tập tin khác phải tuân theo các quy tắc khóa tương tự.  Hơn nữa, “một
Hoạt động thư mục trên hệ thống tập tin này có thể liên quan đến các hoạt động thư mục
trên hệ thống tập tin đó" phải là một mối quan hệ bất đối xứng (hoặc, nếu bạn muốn,
có thể xếp hạng các hệ thống tập tin sao cho hoạt động thư mục
trên hệ thống tập tin chỉ có thể kích hoạt các hoạt động thư mục trên các hệ thống được xếp hạng cao hơn
những cái - trong các thuật ngữ này, lớp phủ xếp hạng thấp hơn các lớp của nó, mạng
hệ thống tập tin xếp hạng thấp hơn bất cứ thứ gì nó lưu vào bộ nhớ đệm, v.v.)


Tránh bế tắc
==================

Nếu không có thư mục nào là tổ tiên của chính nó thì sơ đồ trên không có bế tắc.

Bằng chứng:

Có một thứ hạng trên các ổ khóa, sao cho tất cả các ổ khóa nguyên thủy đều có
chúng theo thứ tự không giảm.  Cụ thể là,

* xếp hạng ->i_rwsem của các thư mục không phải thư mục trên hệ thống tệp đã cho trong con trỏ inode
    đặt hàng.
  * đặt ->i_rwsem của tất cả các thư mục trên hệ thống tập tin ở cùng thứ hạng,
    thấp hơn ->i_rwsem của bất kỳ thư mục nào trên cùng một hệ thống tệp.
  * đặt ->s_vfs_rename_mutex ở thứ hạng thấp hơn bất kỳ ->i_rwsem nào
    trên cùng một hệ thống tập tin.
  * trong số các khóa trên các hệ thống tập tin khác nhau, hãy sử dụng khóa tương đối
    thứ hạng của các hệ thống tập tin đó.

Ví dụ: nếu chúng tôi có bộ nhớ đệm hệ thống tệp NFS trên máy cục bộ, chúng tôi có

1. ->s_vfs_rename_mutex của hệ thống tập tin NFS
  2. ->i_rwsem của các thư mục trên hệ thống tập tin NFS đó, cùng thứ hạng cho tất cả
  3. ->i_rwsem của các thư mục không có trên hệ thống tệp đó, theo thứ tự
     tăng địa chỉ của inode
  4. ->s_vfs_rename_mutex của hệ thống tập tin cục bộ
  5. ->i_rwsem của các thư mục trên hệ thống tập tin cục bộ, cùng thứ hạng cho tất cả
  6. ->i_rwsem của các thư mục không phải trên hệ thống tệp cục bộ, theo thứ tự
     tăng địa chỉ của inode.

Thật dễ dàng để xác minh rằng các hoạt động không bao giờ bị khóa theo thứ hạng
thấp hơn so với khóa đã được giữ.

Giả sử bế tắc có thể xảy ra.  Hãy xem xét sự bế tắc tối thiểu
tập hợp các chủ đề.  Đó là một chu kỳ gồm nhiều luồng, mỗi luồng bị chặn trên một khóa
được giữ bởi luồng tiếp theo trong chu kỳ.

Vì thứ tự khóa phù hợp với thứ hạng nên tất cả
các khóa dự kiến trong bế tắc tối thiểu sẽ có cùng thứ hạng,
tức là tất cả chúng sẽ là ->i_rwsem của các thư mục trên cùng một hệ thống tệp.
Hơn nữa, không mất tính tổng quát, chúng ta có thể giả sử rằng mọi phép toán
được thực hiện trực tiếp với hệ thống tập tin đó và không ai trong số chúng thực sự có
đạt đến cuộc gọi phương thức.

Nói cách khác, chúng ta có một chu trình gồm các luồng T1,..., Tn,
và cùng số lượng thư mục (D1,...,Dn) sao cho

T1 bị chặn trên D1 do T2 giữ

T2 bị chặn trên D2 do T3 giữ

	...

Tn bị chặn trên Dn do T1 giữ.

Mỗi thao tác trong chu trình tối thiểu phải có ít nhất một
một thư mục và bị chặn khi cố khóa một thư mục khác.  Lá đó
chỉ có 3 thao tác có thể thực hiện: xóa thư mục (khóa cha mẹ, sau đó
con), đổi tên cùng thư mục, hủy thư mục con (như trên) và
đổi tên thư mục chéo của một số loại.

Phải có sự đổi tên giữa nhiều thư mục trong tập hợp; thực sự,
nếu tất cả các hoạt động thuộc loại "khóa cha, rồi con"
chúng ta sẽ có Dn cha của D1, là cha của D2, chính là
cha của D3, ..., là cha của Dn.  Những mối quan hệ không thể
đã thay đổi kể từ thời điểm khóa thư mục được lấy,
vì vậy tất cả chúng sẽ giữ đồng thời vào thời điểm bế tắc và
chúng ta sẽ có một vòng lặp.

Vì tất cả các hoạt động đều diễn ra trên cùng một hệ thống tập tin nên không thể có
nhiều hơn một lần đổi tên giữa các thư mục trong số đó.  Không mất
tổng quát chúng ta có thể giả định rằng T1 là người thực hiện đa thư mục
đổi tên và mọi thứ khác thuộc loại "khóa cha, rồi con".

Nói cách khác, chúng tôi có một tên đổi thư mục chéo đã bị khóa
Dn và bị chặn khi cố gắng khóa D1, là cha của D2, là
cha của D3, ..., là cha của Dn.  Mối quan hệ giữa
D1,...,Dn đều giữ đồng thời tại thời điểm bế tắc.  Hơn nữa,
đổi tên thư mục chéo không thể khóa bất kỳ thư mục nào cho đến khi nó
đã lấy được khóa hệ thống tập tin và xác minh rằng các thư mục liên quan có
một tổ tiên chung, đảm bảo rằng mối quan hệ tổ tiên giữa
tất cả đều đã ổn định.

Hãy xem xét thứ tự các thư mục bị khóa bởi
đổi tên thư mục chéo; đầu tiên là cha mẹ, sau đó có thể là con cái của họ.
Dn và D1 sẽ phải nằm trong số đó, với Dn bị khóa trước D1.
Nó có thể là cặp nào?

Nó không thể là cha mẹ - thực vậy, vì D1 là tổ tiên của Dn,
nó sẽ là cha mẹ đầu tiên bị khóa.  Do đó ít nhất một trong số
trẻ em phải tham gia và do đó cả hai đều không thể là hậu duệ
của người khác - nếu không thì hoạt động sẽ không tiến triển trong quá khứ
nhốt bố mẹ.

Nó không thể là cha mẹ và con của nó; nếu không thì chúng ta đã có
một vòng lặp, vì cha mẹ bị khóa trước con cái, nên cha mẹ
sẽ phải là hậu duệ của con nó.

Nó cũng không thể là cha mẹ và con của cha mẹ khác.
Nếu không thì con của cha mẹ được đề cập sẽ là hậu duệ
của một đứa trẻ khác.

Điều đó chỉ còn lại một khả năng - đó là cả Dn và D1 đều
giữa bọn trẻ, theo một thứ tự nào đó.  Nhưng điều đó cũng là không thể, vì
cả hai đứa trẻ đều không phải là hậu duệ của người khác.

Điều đó kết thúc bằng chứng, vì tập hợp các phép toán với
các thuộc tính cần thiết cho một bế tắc tối thiểu không thể tồn tại.

Lưu ý rằng việc kiểm tra có tổ tiên chung trong thư mục chéo
đổi tên là rất quan trọng - nếu không có nó thì có thể xảy ra bế tắc.  Thật vậy,
giả sử ban đầu cây bố mẹ ở những cây khác nhau; chúng tôi sẽ khóa
cha của nguồn, sau đó cố gắng khóa cha của đích, chỉ để có
một tra cứu không liên quan nối một tổ tiên xa xôi của nguồn với một số xa xôi
hậu duệ của cha mẹ của mục tiêu.   Tại thời điểm đó chúng tôi có thư mục chéo
đổi tên giữ khóa trên nguồn gốc và cố gắng khóa nó
tổ tiên xa xôi.  Thêm một loạt các lần thử rmdir() trên tất cả các thư mục
ở giữa (tất cả những điều đó sẽ thất bại với -ENOTEMPTY, nếu họ từng nhận được
ổ khóa) và thì đấy - chúng ta gặp bế tắc.

Tránh vòng lặp
==============

Các hoạt động này được đảm bảo để tránh tạo vòng lặp.  Thật vậy,
thao tác duy nhất có thể gây ra vòng lặp là đổi tên nhiều thư mục.
Giả sử sau thao tác có một vòng lặp; vì đã không có như vậy
vòng lặp trước hoạt động, ít nhất trên các nút trong vòng lặp đó phải có
cha mẹ của nó đã thay đổi.  Nói cách khác, vòng lặp phải đi qua
nguồn hoặc, trong trường hợp trao đổi, có thể là mục tiêu.

Vì hoạt động đã thành công nên cả nguồn và đích đều không thể có
là tổ tiên của nhau.  Vì thế chuỗi tổ tiên bắt đầu
trong phần gốc của nguồn không thể đi qua mục tiêu và
ngược lại.  Mặt khác, chuỗi tổ tiên của bất kỳ nút nào cũng có thể
chưa đi qua chính nút đó, nếu không chúng ta đã có một vòng lặp trước đó
hoạt động.  Nhưng mọi thứ khác ngoài nguồn và đích đều được giữ nguyên
cha mẹ sau thao tác, do đó thao tác không làm thay đổi
chuỗi tổ tiên của cha mẹ (cũ) của nguồn và đích.  Đặc biệt,
những chuỗi đó phải kết thúc sau một số bước hữu hạn.

Bây giờ hãy xem xét vòng lặp được tạo bởi thao tác này.  Nó đi qua hoặc
nguồn hoặc đích; nút tiếp theo trong vòng lặp sẽ là nút cha cũ của
mục tiêu hoặc nguồn tương ứng.  Sau đó vòng lặp sẽ đi theo chuỗi
tổ tiên của cha mẹ đó.  Nhưng như chúng tôi vừa trình bày, chuỗi đó phải
kết thúc sau một số hữu hạn bước, nghĩa là nó không thể là một phần
của bất kỳ vòng lặp nào.  Q.E.D.

Mặc dù sơ đồ khóa này hoạt động với các DAG tùy ý nhưng nó dựa vào
khả năng kiểm tra thư mục đó là hậu duệ của một đối tượng khác.  hiện tại
việc triển khai giả định rằng biểu đồ thư mục là một cây.  Giả định này là
cũng được bảo toàn bởi tất cả các hoạt động (đổi tên thư mục chéo trên cây sẽ
không giới thiệu một chu trình sẽ để lại một cây và link() không thành công đối với các thư mục).

Lưu ý rằng "thư mục" ở trên == "bất cứ thứ gì có thể có
trẻ em", vì vậy nếu chúng ta định giới thiệu các đối tượng lai chúng ta sẽ cần
hoặc để đảm bảo rằng liên kết(2) không hoạt động với họ hoặc để thực hiện thay đổi
trong is_subdir() điều đó sẽ khiến nó hoạt động ngay cả khi có sự hiện diện của những con thú như vậy.
