.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/bpf/verifier.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.


===================
trình xác minh eBPF
===================

Sự an toàn của chương trình eBPF được xác định theo hai bước.

Bước đầu tiên là kiểm tra DAG để không cho phép các vòng lặp và xác thực CFG khác.
Đặc biệt nó sẽ phát hiện các chương trình có hướng dẫn không thể truy cập được.
(mặc dù trình kiểm tra BPF cổ điển cho phép chúng)

Bước thứ hai bắt đầu từ quán trọ đầu tiên và đi xuống tất cả các con đường có thể.
Nó mô phỏng việc thực hiện mọi insn và quan sát sự thay đổi trạng thái của
thanh ghi và ngăn xếp.

Khi bắt đầu chương trình, thanh ghi R1 chứa một con trỏ tới ngữ cảnh
và có loại PTR_TO_CTX.
Nếu người xác minh nhìn thấy một insn có R2=R1 thì R2 hiện có loại
PTR_TO_CTX cũng vậy và có thể được sử dụng ở phía bên phải của biểu thức.
Nếu R1=PTR_TO_CTX và insn là R2=R1+R1, thì R2=SCALAR_VALUE,
vì việc thêm hai con trỏ hợp lệ sẽ tạo ra con trỏ không hợp lệ.
(Trong chế độ 'bảo mật', trình xác minh sẽ từ chối mọi loại số học con trỏ để thực hiện
đảm bảo rằng địa chỉ kernel không bị rò rỉ cho người dùng không có đặc quyền)

Nếu đăng ký chưa bao giờ được ghi vào thì nó không thể đọc được::

bpf_mov R0 = R2
  bpf_exit

sẽ bị từ chối vì R2 không thể đọc được khi bắt đầu chương trình.

Sau khi gọi hàm kernel, R1-R5 được đặt lại thành không thể đọc được và
R0 có kiểu trả về của hàm.

Vì R6-R9 được lưu lại nên trạng thái của chúng được giữ nguyên trong suốt cuộc gọi.

::

bpf_mov R6 = 1
  bpf_call foo
  bpf_mov R0 = R6
  bpf_exit

là một chương trình đúng Nếu có R1 thay vì R6 thì nó sẽ có
bị từ chối.

Các lệnh tải/lưu trữ chỉ được phép với các thanh ghi có kiểu hợp lệ,
là PTR_TO_CTX, PTR_TO_MAP, PTR_TO_STACK. Chúng được giới hạn và căn chỉnh được kiểm tra.
Ví dụ::

bpf_mov R1 = 1
 bpf_mov R2 = 2
 bpf_xadd ZZ0000ZZ)(R1 + 3) += R2
 bpf_exit

sẽ bị từ chối vì R1 không có loại con trỏ hợp lệ tại thời điểm
thực hiện lệnh bpf_xadd.

Khi bắt đầu, loại R1 là PTR_TO_CTX (một con trỏ tới ZZ0000ZZ chung)
Lệnh gọi lại được sử dụng để tùy chỉnh trình xác minh nhằm hạn chế quyền truy cập chương trình eBPF chỉ
một số trường nhất định trong cấu trúc ctx với kích thước và căn chỉnh được chỉ định.

Ví dụ: insn sau::

bpf_ld R0 = ZZ0000ZZ)(R6 + 8)

dự định tải một từ từ địa chỉ R6 + 8 và lưu nó vào R0
Nếu R6=PTR_TO_CTX, thông qua lệnh gọi lại is_valid_access(), người xác minh sẽ biết
phần bù 8 có kích thước 4 byte có thể được truy cập để đọc, nếu không
người xác minh sẽ từ chối chương trình.
Nếu R6=PTR_TO_STACK thì quyền truy cập phải được căn chỉnh và nằm trong
giới hạn ngăn xếp, là [-MAX_BPF_STACK, 0). Trong ví dụ này offset là 8,
vì vậy nó sẽ không xác minh được vì nó nằm ngoài giới hạn.

Trình xác minh sẽ chỉ cho phép chương trình eBPF đọc dữ liệu từ ngăn xếp sau khi
nó đã viết vào đó.

Trình xác minh BPF cổ điển thực hiện kiểm tra tương tự với các khe cắm bộ nhớ M[0-15].
Ví dụ::

bpf_ld R0 = ZZ0000ZZ)(R10 - 4)
  bpf_exit

là chương trình không hợp lệ.
Mặc dù R10 là thanh ghi chỉ đọc chính xác và có loại PTR_TO_STACK
và R10 - 4 nằm trong giới hạn ngăn xếp, không có cửa hàng nào ở vị trí đó.

Việc tràn/điền thanh ghi con trỏ cũng được theo dõi vì bốn (R6-R9)
các thanh ghi đã lưu của callee có thể không đủ cho một số chương trình.

Các lệnh gọi hàm được phép được tùy chỉnh bằng bpf_verifier_ops->get_func_proto()
Trình xác minh eBPF sẽ kiểm tra xem các thanh ghi có khớp với các ràng buộc đối số hay không.
Sau thanh ghi cuộc gọi R0 sẽ được đặt thành kiểu trả về của hàm.

Lệnh gọi hàm là cơ chế chính để mở rộng chức năng của các chương trình eBPF.
Bộ lọc ổ cắm có thể cho phép các chương trình gọi một bộ hàm, trong khi theo dõi
bộ lọc có thể cho phép thiết lập hoàn toàn khác nhau.

Nếu một chức năng được chương trình eBPF có thể truy cập được thì cần phải xem xét kỹ lưỡng
từ quan điểm an toàn. Người xác minh sẽ đảm bảo rằng chức năng này được
được gọi với các đối số hợp lệ.

bộ lọc seccomp và ổ cắm có các hạn chế bảo mật khác nhau cho BPF cổ điển.
Seccomp giải quyết vấn đề này bằng trình xác minh hai giai đoạn: trình xác minh BPF cổ điển được tuân theo
bởi trình xác minh seccomp. Trong trường hợp eBPF, một trình xác minh có thể định cấu hình được chia sẻ cho
tất cả các trường hợp sử dụng.

Xem chi tiết về trình xác minh eBPF trong kernel/bpf/verifier.c

Đăng ký theo dõi giá trị
========================

Để xác định tính an toàn của chương trình eBPF, người xác minh phải theo dõi
phạm vi các giá trị có thể có trong mỗi thanh ghi và trong mỗi khe ngăn xếp.
Điều này được thực hiện với ZZ0000ZZ, được xác định trong include/linux/
bpf_verifier.h, thống nhất việc theo dõi các giá trị vô hướng và con trỏ.  Mỗi
trạng thái thanh ghi có một loại là NOT_INIT (thanh ghi chưa được
được ghi vào), SCALAR_VALUE (một số giá trị không thể sử dụng làm con trỏ) hoặc
kiểu con trỏ.  Các loại con trỏ mô tả cơ sở của chúng như sau:


PTR_TO_CTX
			Con trỏ tới bpf_context.
    CONST_PTR_TO_MAP
			Con trỏ tới struct bpf_map.  "Const" vì số học
			trên những con trỏ này bị cấm.
    PTR_TO_MAP_VALUE
			Con trỏ tới giá trị được lưu trữ trong phần tử bản đồ.
    PTR_TO_MAP_VALUE_OR_NULL
			Hoặc là con trỏ tới giá trị bản đồ hoặc NULL; truy cập bản đồ
			(xem maps.rst) trả về loại này, nó sẽ trở thành một
			PTR_TO_MAP_VALUE khi được chọn != NULL. Số học bật
			những con trỏ này bị cấm.
    PTR_TO_STACK
			Con trỏ khung
    PTR_TO_PACKET
			skb->dữ liệu.
    PTR_TO_PACKET_END
			skb->dữ liệu + tiêu đề; số học bị cấm.
    PTR_TO_SOCKET
			Con trỏ tới struct bpf_sock_ops, được tính lại hoàn toàn.
    PTR_TO_SOCKET_OR_NULL
			Con trỏ tới ổ cắm hoặc NULL; tra cứu ổ cắm
			trả về loại này, nó sẽ trở thành PTR_TO_SOCKET khi
			đã kiểm tra != NULL. PTR_TO_SOCKET được tính tham chiếu,
			vì vậy các chương trình phải giải phóng tham chiếu thông qua
			chức năng nhả ổ cắm trước khi kết thúc chương trình.
			Số học trên những con trỏ này bị cấm.

Tuy nhiên, một con trỏ có thể bị lệch khỏi cơ sở này (do kết quả của con trỏ
số học) và điều này được theo dõi thành hai phần: 'phần bù cố định' và 'biến
bù đắp'.  Cái trước được sử dụng khi một giá trị được biết chính xác (ví dụ: giá trị tức thời
toán hạng) được thêm vào một con trỏ, trong khi toán hạng sau được sử dụng cho các giá trị
không được biết chính xác.  Biến offset cũng được sử dụng trong SCALAR_VALUE để theo dõi
phạm vi các giá trị có thể có trong thanh ghi.

Kiến thức của người xác minh về độ lệch thay đổi bao gồm:

* giá trị tối thiểu và tối đa là không dấu
* giá trị tối thiểu và tối đa như đã ký

* kiến thức về giá trị của các bit riêng lẻ, dưới dạng 'tnum': u64
  'mặt nạ' và 'giá trị' u64.  Các số 1 trong mặt nạ biểu thị các bit có giá trị không xác định;
  Các số 1 trong giá trị biểu thị các bit được biết là 1. Các bit được biết là 0 có 0 ở cả hai
  mặt nạ và giá trị; không có bit nào nên là 1 trong cả hai.  Ví dụ: nếu một byte được đọc
  vào một thanh ghi từ bộ nhớ, 56 bit trên cùng của thanh ghi được biết đến bằng 0, trong khi
  số 8 thấp chưa được biết - được biểu thị dưới dạng tnum (0x0; 0xff).  Nếu chúng ta
  sau đó HOẶC cái này với 0x40, chúng ta nhận được (0x40; 0xbf), sau đó nếu chúng ta thêm 1 thì chúng ta sẽ nhận được (0x0;
  0x1ff), vì khả năng mang theo tiềm năng.

Ngoài số học, trạng thái thanh ghi còn có thể được cập nhật bằng các điều kiện
chi nhánh.  Ví dụ: nếu SCALAR_VALUE được so sánh > 8, trong nhánh 'true'
nó sẽ có umin_value (giá trị tối thiểu không dấu) là 9, trong khi ở 'false'
nhánh, nó sẽ có giá trị umax_value là 8. Một so sánh có dấu (với BPF_JSGT hoặc
BPF_JSGE) thay vào đó sẽ cập nhật các giá trị tối thiểu/tối đa đã ký.  Thông tin
từ giới hạn đã ký và không dấu có thể được kết hợp; ví dụ nếu một giá trị là
lần đầu tiên kiểm tra < 8 và sau đó kiểm tra s> 4, người kiểm tra sẽ kết luận rằng giá trị
cũng > 4 và s< 8, vì các giới hạn ngăn cản việc vượt qua ranh giới dấu hiệu.

PTR_TO_PACKET có phần bù thay đổi có 'id', chung cho tất cả
con trỏ chia sẻ cùng một biến offset.  Điều này rất quan trọng đối với phạm vi gói
kiểm tra: sau khi thêm một biến vào con trỏ gói, hãy đăng ký A, nếu sau đó bạn sao chép
nó vào một thanh ghi B khác và sau đó thêm hằng số 4 vào A, cả hai thanh ghi sẽ
chia sẻ cùng một 'id' nhưng A sẽ có độ lệch cố định là +4.  Thế thì nếu A là
được kiểm tra giới hạn và được tìm thấy nhỏ hơn PTR_TO_PACKET_END, thanh ghi B là
hiện được biết là có phạm vi an toàn ít nhất là 4 byte.  Xem 'Truy cập gói trực tiếp',
bên dưới, để biết thêm về dòng sản phẩm PTR_TO_PACKET.

Trường 'id' cũng được sử dụng trên PTR_TO_MAP_VALUE_OR_NULL, phổ biến cho tất cả các bản sao của
con trỏ được trả về từ việc tra cứu bản đồ.  Điều này có nghĩa là khi một bản sao được
đã kiểm tra và phát hiện không phải là NULL, tất cả các bản sao có thể trở thành PTR_TO_MAP_VALUE.
Ngoài việc kiểm tra phạm vi, thông tin được theo dõi cũng được sử dụng để thực thi
căn chỉnh các truy cập con trỏ.  Ví dụ, trên hầu hết các hệ thống, con trỏ gói
là 2 byte sau khi căn chỉnh 4 byte.  Nếu một chương trình thêm 14 byte vào đó để nhảy
qua tiêu đề Ethernet, sau đó đọc IHL và thêm (IHL * 4), kết quả
con trỏ sẽ có độ lệch thay đổi được biết là 4n+2 đối với một số n, vì vậy việc thêm 2
byte (NET_IP_ALIGN) cung cấp căn chỉnh 4 byte và do đó truy cập có kích thước từ thông qua
con trỏ đó an toàn.
Trường 'id' cũng được sử dụng trên PTR_TO_SOCKET và PTR_TO_SOCKET_OR_NULL, phổ biến
tới tất cả các bản sao của con trỏ được trả về từ việc tra cứu ổ cắm. Cái này có cái tương tự
hành vi xử lý PTR_TO_MAP_VALUE_OR_NULL->PTR_TO_MAP_VALUE, nhưng
nó cũng xử lý việc theo dõi tham chiếu cho con trỏ. PTR_TO_SOCKET ngầm
đại diện cho một tham chiếu đến ZZ0000ZZ tương ứng. Để đảm bảo rằng
tài liệu tham khảo không bị rò rỉ, bắt buộc NULL phải kiểm tra tài liệu tham khảo và trong
trường hợp không phải NULL và chuyển tham chiếu hợp lệ đến chức năng giải phóng ổ cắm.

Truy cập gói trực tiếp
======================

Trong các chương trình cls_bpf và Act_bpf trình xác minh cho phép truy cập trực tiếp vào gói
dữ liệu thông qua con trỏ skb->data và skb->data_end.
Bán tại::

1: r4 = ZZ0000ZZ)(r1 +80) /* tải skb->data_end */
    2: r3 = ZZ0001ZZ)(r1 +76) /* tải skb->dữ liệu */
    3: r5 = r3
    4: r5 += 14
    5: nếu r5 > r4 goto pc+16
    R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
    6: r0 = ZZ0002ZZ)(r3 +12) /* truy cập 12 và 13 byte của gói */

việc tải 2byte này từ gói là an toàn để thực hiện vì tác giả chương trình
đã kiểm tra ZZ0000ZZ tại nhà trọ #5
có nghĩa là trong trường hợp dự phòng, thanh ghi R3 (trỏ tới skb->data)
có ít nhất 14 byte có thể truy cập trực tiếp. Người xác minh đánh dấu nó
dưới dạng R3=pkt(id=0,off=0,r=14).
id=0 có nghĩa là không có biến bổ sung nào được thêm vào sổ đăng ký.
off=0 có nghĩa là không có hằng số bổ sung nào được thêm vào.
r=14 là phạm vi truy cập an toàn, có nghĩa là byte [R3, R3 + 14) đều ổn.
Lưu ý rằng R5 được đánh dấu là R5=pkt(id=0,off=14,r=14). Nó cũng điểm
vào dữ liệu gói, nhưng hằng số 14 đã được thêm vào thanh ghi, vì vậy
bây giờ nó trỏ đến ZZ0001ZZ và phạm vi có thể truy cập là [R5, R5 + 14 - 14)
đó là số 0 byte.

Truy cập gói phức tạp hơn có thể trông giống như::


R0=inv1 R1=ctx R3=pkt(id=0,off=0,r=14) R4=pkt_end R5=pkt(id=0,off=14,r=14) R10=fp
    6: r0 = ZZ0000ZZ)(r3 +7) /* tải byte thứ 7 từ gói */
    7: r4 = ZZ0001ZZ)(r3 +12)
    8: r4 *= 14
    9: r3 = ZZ0002ZZ)(r1 +76) /* tải skb->dữ liệu */
    10: r3 += r4
    11: r2 = r1
    12: r2 <<= 48
    13: r2 >>= 48
    14: r3 += r2
    15: r2 = r3
    16: r2 += 8
    17: r1 = ZZ0003ZZ)(r1 +80) /* tải skb->data_end */
    18: nếu r2 > r1 goto pc+2
    R0=inv(id=0,umax_value=255,var_off=(0x0; 0xff)) R1=pkt_end R2=pkt(id=2,off=8,r=8) R3=pkt(id=2,off=0,r=8) R4=inv(id=0,umax_value=3570,var_off=(0x0; 0xfffe)) R5=pkt(id=0,off=14,r=14) R10=fp
    19: r1 = ZZ0004ZZ)(r3 +4)

Trạng thái của thanh ghi R3 là R3=pkt(id=2,off=0,r=8)
id=2 có nghĩa là đã nhìn thấy hai lệnh ZZ0000ZZ, vì vậy r3 trỏ đến một số
bù đắp trong một gói và vì tác giả chương trình đã làm
ZZ0001ZZ và insn #18, phạm vi an toàn là [R3, R3 + 8).
Trình xác minh chỉ cho phép các hoạt động 'thêm'/'phụ' trên các thanh ghi gói. Bất kỳ cái nào khác
hoạt động sẽ đặt trạng thái đăng ký thành 'SCALAR_VALUE' và nó sẽ không
có sẵn để truy cập gói trực tiếp.

Hoạt động ZZ0000ZZ có thể tràn và trở nên ít hơn dữ liệu skb-> ban đầu,
do đó người xác minh phải ngăn chặn điều đó.  Vì vậy khi nhìn thấy ZZ0001ZZ
lệnh và rX lớn hơn giá trị 16 bit, mọi lần kiểm tra giới hạn tiếp theo của r3
chống lại skb->data_end sẽ không cung cấp cho chúng tôi thông tin 'phạm vi', vì vậy hãy thử đọc
thông qua con trỏ sẽ báo lỗi "truy cập gói không hợp lệ".

Bán tại. sau insn ZZ0000ZZ (insn #7 ở trên) trạng thái của r4 là
R4=inv(id=0,umax_value=255,var_off=(0x0; 0xff)) có nghĩa là 56 bit trên
của thanh ghi được đảm bảo bằng 0 và không biết gì về mức thấp hơn
8 bit. Sau khi insn ZZ0001ZZ trạng thái trở thành
R4=inv(id=0,umax_value=3570,var_off=(0x0; 0xfffe)), kể từ khi nhân một 8 bit
giá trị theo hằng số 14 sẽ giữ 52 bit trên bằng 0, cũng là giá trị ít quan trọng nhất
bit sẽ bằng 0 vì 14 là số chẵn.  Tương tự ZZ0002ZZ sẽ làm
R2=inv(id=0,umax_value=65535,var_off=(0x0; 0xffff)), vì phép dịch không có dấu
kéo dài.  Logic này được triển khai trong hàm adjustment_reg_min_max_vals(),
gọi điều chỉnh_ptr_min_max_vals() để thêm con trỏ vào vô hướng (hoặc ngược lại
ngược lại) và adjustment_scalar_min_max_vals() cho các phép tính trên hai đại lượng vô hướng.

Kết quả cuối cùng là tác giả chương trình bpf có thể truy cập gói trực tiếp
sử dụng mã C bình thường như ::

void ZZ0000ZZ)(dài)skb->dữ liệu;
  void ZZ0001ZZ)(dài)skb->data_end;
  struct eth_hdr *eth = dữ liệu;
  cấu trúc iphdr *iph = data + sizeof(*eth);
  cấu trúc udphdr *udp = data + sizeof(*eth) + sizeof(*iph);

if (dữ liệu + sizeof(*eth) + sizeof(*iph) + sizeof(*udp) > data_end)
	  trả về 0;
  if (eth->h_proto != htons(ETH_P_IP))
	  trả về 0;
  if (iph->giao thức != IPPROTO_UDP || iph->ihl != 5)
	  trả về 0;
  if (udp->dest == 53 || udp->source == 9)
	  ...;

điều này làm cho các chương trình như vậy dễ viết hơn so với LD_ABS insn
và nhanh hơn đáng kể.

Cắt tỉa
=======

Người xác minh không thực sự đi qua tất cả các con đường có thể có trong chương trình.  cho
mỗi nhánh mới để phân tích, trình xác minh sẽ xem xét tất cả các trạng thái trước đó của nó
được ở khi theo hướng dẫn này.  Nếu bất kỳ trong số chúng chứa trạng thái hiện tại dưới dạng
tập hợp con, nhánh bị 'cắt tỉa' - nghĩa là thực tế là trạng thái trước đó đã bị
được chấp nhận ngụ ý trạng thái hiện tại cũng sẽ như vậy.  Ví dụ, nếu trong
trạng thái trước đó, r1 giữ một con trỏ gói và ở trạng thái hiện tại, r1 giữ một
con trỏ gói có phạm vi dài hoặc dài hơn và ít nhất là nghiêm ngặt
căn chỉnh thì r1 là an toàn.  Tương tự, nếu trước đó r2 là NOT_INIT thì không thể
đã được sử dụng bởi bất kỳ đường dẫn nào từ thời điểm đó, vì vậy mọi giá trị trong r2 (bao gồm cả
NOT_INIT khác) vẫn an toàn.  Việc triển khai nằm trong hàm regsafe().
Việc cắt tỉa không chỉ xem xét các thanh ghi mà còn cả ngăn xếp (và bất kỳ phần nào bị tràn
đăng ký nó có thể giữ).  Tất cả đều phải an toàn để cành được cắt tỉa.
Điều này được thực hiện trong state_equal().

Bạn có thể tìm thấy một số chi tiết kỹ thuật về việc triển khai cắt tỉa trạng thái bên dưới.

Đăng ký theo dõi sự sống
--------------------------

Để làm cho việc cắt tỉa trạng thái có hiệu quả, trạng thái sống động được theo dõi cho từng
khe đăng ký và ngăn xếp. Ý tưởng cơ bản là theo dõi các thanh ghi và ngăn xếp nào
các khe thực sự được sử dụng trong quá trình thực hiện chương trình tiếp theo, cho đến khi
đã thoát khỏi chương trình. Các thanh ghi và ngăn xếp không bao giờ được sử dụng có thể
bị xóa khỏi trạng thái được lưu trong bộ nhớ đệm, do đó tạo ra nhiều trạng thái tương đương với trạng thái được lưu trong bộ nhớ đệm
trạng thái. Điều này có thể được minh họa bằng chương trình sau::

0: gọi bpf_get_prandom_u32()
  1: r1 = 0
  2: nếu r0 == 0 goto +1
  3: r0 = 1
  --- trạm kiểm soát ---
  4: r0 = r1
  5: thoát

Giả sử rằng một mục trong bộ đệm trạng thái được tạo theo lệnh #4 (các mục đó được
còn được gọi là "điểm kiểm tra" trong văn bản bên dưới). Người xác minh có thể đạt được
hướng dẫn với một trong hai trạng thái thanh ghi có thể có:

* r0 = 1, r1 = 0
* r0 = 0, r1 = 0

Tuy nhiên, chỉ có giá trị của thanh ghi ZZ0000ZZ là quan trọng để hoàn thành thành công
xác minh. Mục tiêu của thuật toán theo dõi sự sống là phát hiện ra sự thật này
và tìm ra rằng cả hai trạng thái thực sự tương đương nhau.

Hiểu thông báo xác minh eBPF
====================================

Sau đây là một số ví dụ về chương trình eBPF không hợp lệ và lỗi xác minh
thông báo như đã thấy trong nhật ký:

Chương trình có hướng dẫn không thể truy cập::

cấu trúc tĩnh bpf_insn prog[] = {
  BPF_EXIT_INSN(),
  BPF_EXIT_INSN(),
  };

Lỗi::

nhà trọ không thể truy cập 1

Chương trình đọc thanh ghi chưa được khởi tạo::

BPF_MOV64_REG(BPF_REG_0, BPF_REG_2),
  BPF_EXIT_INSN(),

Lỗi::

0: (bf) r0 = r2
  R2 !đọc_ok

Chương trình không khởi tạo R0 trước khi thoát::

BPF_MOV64_REG(BPF_REG_2, BPF_REG_1),
  BPF_EXIT_INSN(),

Lỗi::

0: (bf) r2 = r1
  1: (95) thoát
  R0 !đọc_ok

Chương trình truy cập ngăn xếp ngoài giới hạn::

BPF_ST_MEM(BPF_DW, BPF_REG_10, 8, 0),
    BPF_EXIT_INSN(),

Lỗi::

0: (7a) ZZ0000ZZ)(r10 +8) = 0
    ngăn xếp không hợp lệ = 8 kích thước = 8

Chương trình không khởi tạo ngăn xếp trước khi chuyển địa chỉ của nó vào hàm::

BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
  BPF_EXIT_INSN(),

Lỗi::

0: (bf) r2 = r10
  1: (07) r2 += -8
  2: (b7) r1 = 0x0
  3: (85) gọi 1
  đọc gián tiếp không hợp lệ từ ngăn xếp -8+0 kích thước 8

Chương trình sử dụng map_fd=0 không hợp lệ trong khi gọi tới hàm map_lookup_elem() ::

BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
  BPF_EXIT_INSN(),

Lỗi::

0: (7a) ZZ0000ZZ)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 0x0
  4: (85) gọi 1
  fd 0 không trỏ đến bpf_map hợp lệ

Chương trình không kiểm tra giá trị trả về của map_lookup_elem() trước khi truy cập
yếu tố bản đồ::

BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
  BPF_EXIT_INSN(),

Lỗi::

0: (7a) ZZ0000ZZ)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 0x0
  4: (85) gọi 1
  5: (7a) ZZ0001ZZ)(r0 +0) = 0
  R0 truy cập mem không hợp lệ 'map_value_or_null'

Chương trình kiểm tra chính xác giá trị trả về của map_lookup_elem() cho NULL, nhưng
truy cập bộ nhớ với căn chỉnh không chính xác::

BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 1),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 4, 0),
  BPF_EXIT_INSN(),

Lỗi::

0: (7a) ZZ0000ZZ)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 1
  4: (85) gọi 1
  5: (15) if r0 == 0x0 goto pc+1
   R0=map_ptr R10=fp
  6: (7a) ZZ0001ZZ)(r0 +4) = 0
  truy cập sai lệch tắt 4 kích thước 8

Chương trình kiểm tra chính xác giá trị trả về của map_lookup_elem() cho NULL và
truy cập bộ nhớ với căn chỉnh chính xác ở một bên của nhánh 'if', nhưng không thành công
để làm như vậy ở phía bên kia của nhánh 'if'::

BPF_ST_MEM(BPF_DW, BPF_REG_10, -8, 0),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_LD_MAP_FD(BPF_REG_1, 0),
  BPF_RAW_INSN(BPF_JMP | BPF_CALL, 0, 0, 0, BPF_FUNC_map_lookup_elem),
  BPF_JMP_IMM(BPF_JEQ, BPF_REG_0, 0, 2),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 0),
  BPF_EXIT_INSN(),
  BPF_ST_MEM(BPF_DW, BPF_REG_0, 0, 1),
  BPF_EXIT_INSN(),

Lỗi::

0: (7a) ZZ0000ZZ)(r10 -8) = 0
  1: (bf) r2 = r10
  2: (07) r2 += -8
  3: (b7) r1 = 1
  4: (85) gọi 1
  5: (15) if r0 == 0x0 goto pc+2
   R0=map_ptr R10=fp
  6: (7a) ZZ0001ZZ)(r0 +0) = 0
  7: (95) thoát

từ 5 đến 8: R0=imm0 R10=fp
  8: (7a) ZZ0000ZZ)(r0 +0) = 1
  R0 truy cập mem không hợp lệ 'imm'

Chương trình thực hiện tra cứu socket sau đó đặt con trỏ tới NULL mà không cần
kiểm tra nó::

BPF_MOV64_IMM(BPF_REG_2, 0),
  BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_2, -8),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_MOV64_IMM(BPF_REG_3, 4),
  BPF_MOV64_IMM(BPF_REG_4, 0),
  BPF_MOV64_IMM(BPF_REG_5, 0),
  BPF_EMIT_CALL(BPF_FUNC_sk_lookup_tcp),
  BPF_MOV64_IMM(BPF_REG_0, 0),
  BPF_EXIT_INSN(),

Lỗi::

0: (b7) r2 = 0
  1: (63) ZZ0000ZZ)(r10 -8) = r2
  2: (bf) r2 = r10
  3: (07) r2 += -8
  4: (b7) r3 = 4
  5: (b7) r4 = 0
  6: (b7) r5 = 0
  7: (85) gọi bpf_sk_lookup_tcp#65
  8: (b7) r0 = 0
  9: (95) thoát
  Tham chiếu chưa được phát hành id=1, alloc_insn=7

Chương trình thực hiện tra cứu ổ cắm nhưng không kiểm tra NULL được trả về
giá trị::

BPF_MOV64_IMM(BPF_REG_2, 0),
  BPF_STX_MEM(BPF_W, BPF_REG_10, BPF_REG_2, -8),
  BPF_MOV64_REG(BPF_REG_2, BPF_REG_10),
  BPF_ALU64_IMM(BPF_ADD, BPF_REG_2, -8),
  BPF_MOV64_IMM(BPF_REG_3, 4),
  BPF_MOV64_IMM(BPF_REG_4, 0),
  BPF_MOV64_IMM(BPF_REG_5, 0),
  BPF_EMIT_CALL(BPF_FUNC_sk_lookup_tcp),
  BPF_EXIT_INSN(),

Lỗi::

0: (b7) r2 = 0
  1: (63) ZZ0000ZZ)(r10 -8) = r2
  2: (bf) r2 = r10
  3: (07) r2 += -8
  4: (b7) r3 = 4
  5: (b7) r4 = 0
  6: (b7) r5 = 0
  7: (85) gọi bpf_sk_lookup_tcp#65
  8: (95) thoát
  Tham chiếu chưa được phát hành id=1, alloc_insn=7
