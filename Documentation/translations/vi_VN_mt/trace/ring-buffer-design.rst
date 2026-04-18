.. SPDX-License-Identifier: GPL-2.0 OR GFDL-1.2-no-invariants-only

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/trace/ring-buffer-design.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============================
Thiết kế bộ đệm vòng không khóa
===========================

Bản quyền 2009 Red Hat Inc.

:Tác giả: Steven Rostedt <srostedt@redhat.com>
:Giấy phép: Giấy phép Tài liệu Miễn phí GNU, Phiên bản 1.2
           (được cấp phép kép theo GPL v2)
:Người phản biện: Mathieu Desnoyers, Huang Ying, Hidetoshi Seto,
	     và Frederic Weisbecker.


Viết cho: 2.6.31

Thuật ngữ được sử dụng trong Tài liệu này
---------------------------------

đuôi
	- nơi việc ghi mới diễn ra trong bộ đệm vòng.

cái đầu
	- nơi các lần đọc mới xảy ra trong bộ đệm vòng.

nhà sản xuất
	- tác vụ ghi vào bộ đệm vòng (giống như tác vụ ghi)

nhà văn
	- giống như nhà sản xuất

người tiêu dùng
	- tác vụ đọc từ bộ đệm (giống như trình đọc)

người đọc
	- giống như người tiêu dùng.

reader_page
	- Một trang nằm ngoài vòng đệm chỉ được sử dụng (phần lớn)
	  bởi người đọc.

đầu_trang
	- một con trỏ tới trang mà người đọc sẽ sử dụng tiếp theo

trang đuôi
	- một con trỏ tới trang sẽ được ghi tiếp theo

trang cam kết
	- một con trỏ tới trang có nội dung ghi không lồng nhau đã hoàn thành cuối cùng.

cmpxchg
	- giao dịch nguyên tử được hỗ trợ bằng phần cứng thực hiện như sau::

A = B nếu trước A == C

R = cmpxchg(A, C, B) có nghĩa là chúng ta thay thế A bằng B khi và chỉ
		nếu hiện tại A bằng C và chúng ta đặt cái cũ (hiện tại)
		A vào R

R nhận được A trước đó bất kể A có được cập nhật với B hay không.

Để xem bản cập nhật có thành công hay không, hãy so sánh ZZ0000ZZ
	  có thể được sử dụng

Bộ đệm vòng chung
-----------------------

Bộ đệm vòng có thể được sử dụng ở chế độ ghi đè hoặc ở chế độ
Chế độ nhà sản xuất/người tiêu dùng.

Chế độ nhà sản xuất/người tiêu dùng là nơi nếu nhà sản xuất điền vào
vùng đệm trước khi người tiêu dùng có thể giải phóng bất cứ thứ gì, nhà sản xuất
sẽ ngừng ghi vào bộ đệm. Điều này sẽ mất các sự kiện gần đây nhất.

Chế độ ghi đè là nơi nếu nhà sản xuất lấp đầy bộ đệm
trước khi người tiêu dùng có thể giải phóng bất cứ thứ gì, nhà sản xuất sẽ
ghi đè lên dữ liệu cũ hơn. Điều này sẽ làm mất các sự kiện lâu đời nhất.

Không có hai người viết nào có thể viết cùng một lúc (trên cùng một bộ đệm trên mỗi CPU),
nhưng người viết có thể ngắt lời người viết khác nhưng phải viết xong
trước khi người viết trước có thể tiếp tục. Điều này rất quan trọng đối với
thuật toán. Các nhà văn hoạt động như một "chồng". Cách thức hoạt động của ngắt
thực thi hành vi này::


nhà văn1 bắt đầu
     <preempted> writer2 bắt đầu
         <preempted> writer3 bắt đầu
                     writer3 kết thúc
                 writer2 kết thúc
  nhà văn1 kết thúc

Điều này rất giống việc một nhà văn bị chặn trước bởi một sự gián đoạn và
ngắt cũng đang viết.

Người đọc có thể xảy ra bất cứ lúc nào. Nhưng không có hai độc giả có thể chạy cùng lúc
cùng một lúc, người đọc cũng không thể chặn/làm gián đoạn người đọc khác. Một độc giả
không thể chặn trước/ngắt bộ ghi, nhưng nó có thể đọc/tiêu thụ từ
đệm cùng lúc với lúc người viết đang viết, nhưng người đọc phải
trên bộ xử lý khác để làm như vậy. Một đầu đọc có thể đọc trên bộ xử lý của chính nó
và có thể được ưu tiên bởi một nhà văn.

Nhà văn có thể ưu tiên người đọc nhưng người đọc không thể ưu tiên nhà văn.
Nhưng người đọc có thể đọc bộ đệm cùng lúc (trên bộ xử lý khác)
với tư cách là một nhà văn.

Bộ đệm vòng được tạo thành từ một danh sách các trang được liên kết với nhau bằng một danh sách liên kết.

Khi khởi tạo, một trang đọc được phân bổ cho trình đọc không
một phần của bộ đệm vòng.

head_page, tail_page và commit_page đều được khởi tạo để trỏ
đến cùng một trang.

Trang đọc được khởi tạo để có con trỏ tiếp theo trỏ tới
trang đầu và con trỏ trước đó của nó trỏ đến một trang trước
trang đầu.

Người đọc có trang riêng để sử dụng. Khi khởi động, trang này là
được phân bổ nhưng không được đính kèm vào danh sách. Khi người đọc muốn
để đọc từ bộ đệm, nếu trang của nó trống (giống như khi khởi động),
nó sẽ hoán đổi trang của nó với head_page. Trang đọc cũ sẽ
trở thành một phần của bộ đệm vòng và head_page sẽ bị xóa.
Trang sau trang được chèn (read_page cũ) sẽ trở thành
trang đầu mới.

Khi trang mới được đưa tới tay người đọc, người đọc có thể làm gì
nó muốn với nó, miễn là người viết đã rời khỏi trang đó.

Ví dụ về cách hoán đổi trang đọc: Lưu ý rằng điều này không
hiển thị trang đầu trong bộ đệm, nó dùng để thể hiện sự hoán đổi
chỉ.

::

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ
  +------+
                  +---+ +---+ +---+
                  ZZ0002ZZ->ZZ0003ZZ->ZZ0004ZZ
                  ZZ0005ZZ<--ZZ0006ZZ<--ZZ0007ZZ
                  +---+ +---+ +---+
                   ^ ZZ0008ZZ
                   ZZ0009ZZ
                   +-----------------+


+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------------------+
  +------+ v
    |             +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ |
    ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ |<-+
    ZZ0008ZZ
    ZZ0009ZZ ^ ZZ0010ZZ
    ZZ0011ZZ +-------------+ ZZ0012ZZ
    ZZ0013ZZ
    +------------------------------------+

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------------------+
  +------+ <--------------+ v
    |  ^ +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ->ZZ0004ZZ->ZZ0005ZZ
    ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ<--ZZ0009ZZ<-+
    ZZ0010ZZ +---+ +---+ +---+ |
    ZZ0011ZZ ZZ0012ZZ |
    ZZ0013ZZ +-------------+ ZZ0014ZZ
    ZZ0015ZZ
    +------------------------------------+

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------------------+
  +------+ <--------------+ v
    |  ^ +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ->ZZ0005ZZ
    ZZ0006ZZ Mới ZZ0007ZZ ZZ0008ZZ<--ZZ0009ZZ<-+
    Đầu đọc ZZ0010ZZ +---+ +---+ +---+ |
    Trang ZZ0011ZZ ----^ ZZ0012ZZ
    ZZ0013ZZ ZZ0014ZZ
    ZZ0015ZZ
    +------------------------------------+



Có thể trang được hoán đổi là trang cam kết và trang đuôi,
nếu nội dung trong bộ đệm vòng nhỏ hơn nội dung được giữ trong trang bộ đệm.

::

trang đọc trang cam kết trang đuôi
                ZZ0000ZZ |
                v ZZ0001ZZ
               +---+ ZZ0002ZZ
               ZZ0003ZZ<----------+ |
               ZZ0004ZZ<------------------------+
               ZZ0005ZZ------+
               +---+ |
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0006ZZ--->ZZ0007ZZ--->ZZ0008ZZ--->ZZ0009ZZ--->
  --->ZZ0010ZZ<---ZZ0011ZZ<---ZZ0012ZZ<---ZZ0013ZZ<---
      +---+ +---+ +---+ +---+

Trường hợp này vẫn hợp lệ cho thuật toán này.
Khi người viết rời khỏi trang, nó chỉ đơn giản đi vào bộ đệm vòng
vì trang đọc vẫn trỏ đến vị trí tiếp theo trong vòng
bộ đệm.


Các gợi ý chính:

trang đọc
	    - Trang chỉ được người đọc sử dụng và không phải là một phần
              của bộ đệm vòng (có thể được hoán đổi)

trang đầu
	    - trang tiếp theo trong bộ đệm vòng sẽ được hoán đổi
              với trang người đọc.

trang đuôi
	    - trang nơi việc viết tiếp theo sẽ diễn ra.

trang cam kết
	    - trang viết xong lần cuối.

Trang cam kết chỉ được cập nhật bởi người viết ngoài cùng trong
chồng nhà văn. Một nhà văn đi trước một nhà văn khác sẽ không di chuyển được
trang cam kết.

Khi dữ liệu được ghi vào bộ đệm vòng, một vị trí sẽ được bảo lưu
vào bộ đệm vòng và chuyển lại cho người viết. Khi nhà văn
ghi xong dữ liệu vào vị trí đó, nó cam kết ghi.

Việc ghi (hoặc đọc) khác có thể diễn ra bất kỳ lúc nào trong thời gian này.
giao dịch. Nếu một lần ghi khác xảy ra thì nó phải kết thúc trước khi tiếp tục
với lần viết trước đó.


Viết dự trữ::

Trang đệm
      +----------+
      ZZ0000ZZ
      +----------+ <--- được trả lại cho người viết (cam kết hiện tại)
      ZZ0001ZZ
      +----------+ <--- con trỏ đuôi
      ZZ0002ZZ
      +----------+

Viết cam kết::

Trang đệm
      +----------+
      ZZ0000ZZ
      +----------+
      ZZ0001ZZ
      +----------+ <--- vị trí tiếp theo để ghi (cam kết hiện tại)
      ZZ0002ZZ
      +----------+


Nếu việc ghi xảy ra sau lần dự trữ đầu tiên::

Trang đệm
      +----------+
      ZZ0000ZZ
      +----------+ <-- cam kết hiện tại
      ZZ0001ZZ
      +----------+ <--- trả lại cho người viết thứ hai
      ZZ0002ZZ
      +----------+ <--- con trỏ đuôi

Sau khi người viết thứ hai cam kết::


Trang đệm
      +----------+
      ZZ0000ZZ
      +----------+ <--(cam kết đầy đủ cuối cùng)
      ZZ0001ZZ
      +----------+
      ZZ0002ZZ
      ZZ0003ZZ
      +----------+ <--- con trỏ đuôi

Khi người viết đầu tiên cam kết::

Trang đệm
      +----------+
      ZZ0000ZZ
      +----------+
      ZZ0001ZZ
      +----------+
      ZZ0002ZZ
      +----------+ <--(con trỏ đầy đủ và đuôi cuối cùng)


Con trỏ cam kết trỏ tới vị trí ghi cuối cùng đã được
được cam kết mà không ưu tiên một lần viết khác. Khi viết điều đó
ưu tiên một lần ghi khác được cam kết, nó chỉ trở thành một cam kết đang chờ xử lý
và sẽ không phải là một cam kết đầy đủ cho đến khi tất cả các lần ghi đã được cam kết.

Trang cam kết trỏ đến trang có cam kết đầy đủ cuối cùng.
Trang đuôi trỏ đến trang có lần viết cuối cùng (trước
cam kết).

Trang đuôi luôn bằng hoặc sau trang cam kết. Nó có thể
đi trước vài trang. Nếu trang đuôi bắt kịp cam kết
trang thì không thể ghi thêm nữa (bất kể chế độ
của bộ đệm vòng: ghi đè và sản xuất/tiêu dùng).

Thứ tự các trang là::

trang đầu
 trang cam kết
 trang đuôi

Tình huống có thể xảy ra::

trang đuôi
    trang đầu trang cam kết |
        ZZ0000ZZ |
        v v v
      +---+ +---+ +---+ +---+
  <---ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->ZZ0004ZZ--->
  --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
      +---+ +---+ +---+ +---+

Có một trường hợp đặc biệt là trang đầu nằm sau trang cam kết
và có thể cả trang đuôi. Đó là khi trang cam kết (và đuôi) đã được
hoán đổi với trang đọc. Điều này là do trang đầu luôn
một phần của bộ đệm vòng, nhưng trang đọc thì không. Bất cứ khi nào ở đó
chưa đến một trang đầy đủ đã được cam kết bên trong bộ đệm vòng,
và người đọc hoán đổi một trang, nó sẽ hoán đổi trang cam kết.

::

trang đọc trang cam kết trang đuôi
                ZZ0000ZZ |
                v ZZ0001ZZ
               +---+ ZZ0002ZZ
               ZZ0003ZZ<----------+ |
               ZZ0004ZZ<------------------------+
               ZZ0005ZZ------+
               +---+ |
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0006ZZ--->ZZ0007ZZ--->ZZ0008ZZ--->ZZ0009ZZ--->
  --->ZZ0010ZZ<---ZZ0011ZZ<---ZZ0012ZZ<---ZZ0013ZZ<---
      +---+ +---+ +---+ +---+
                          ^
                          |
                      trang đầu


Trong trường hợp này, trang đầu sẽ không di chuyển khi phần đuôi và cam kết
di chuyển trở lại bộ đệm vòng.

Trình đọc không thể hoán đổi một trang vào bộ đệm vòng nếu trang cam kết
vẫn còn trên trang đó. Nếu lần đọc đáp ứng lần xác nhận cuối cùng (cam kết thực
không chờ xử lý hoặc dành riêng), thì không còn gì để đọc nữa.
Bộ đệm được coi là trống cho đến khi một cam kết đầy đủ khác kết thúc.

Khi phần đuôi gặp trang đầu, nếu bộ đệm ở chế độ ghi đè,
trang đầu sẽ được đẩy lên trước. Nếu bộ đệm nằm trong nhà sản xuất/người tiêu dùng
chế độ ghi sẽ thất bại.

Chế độ ghi đè::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+
                          ^
                          |
                      trang đầu


trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+
                                   ^
                                   |
                               trang đầu


trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+
                                   ^
                                   |
                               trang đầu

Lưu ý, trang đọc vẫn sẽ trỏ về trang đầu trước đó.
Nhưng khi việc hoán đổi diễn ra, nó sẽ sử dụng trang đầu gần đây nhất.


Làm cho bộ đệm vòng không bị khóa:
--------------------------------

Ý tưởng chính đằng sau thuật toán không khóa là kết hợp chuyển động
của con trỏ head_page với việc hoán đổi các trang với đầu đọc.
Cờ trạng thái được đặt bên trong con trỏ tới trang. Để làm điều này,
mỗi trang phải được căn chỉnh trong bộ nhớ 4 byte. Điều này sẽ cho phép 2
Các bit có ý nghĩa nhỏ nhất của địa chỉ được sử dụng làm cờ, vì
chúng sẽ luôn bằng 0 đối với địa chỉ. Để có được địa chỉ,
chỉ cần che dấu các lá cờ::

MASK = ~3

địa chỉ & MASK

Hai cờ sẽ được giữ bởi hai bit này:

HEADER
	- trang được trỏ tới là trang đầu

UPDATE
	- trang được trỏ tới đang được người viết cập nhật
          và đã hoặc sắp trở thành trang đầu.

::

trang đọc
		  |
		  v
		+---+
		ZZ0000ZZ------+
		+---+ |
			    |
			    v
	+---+ +---+ +---+ +---+
    <---ZZ0001ZZ--->ZZ0002ZZ-H->ZZ0003ZZ--->ZZ0004ZZ--->
    --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
	+---+ +---+ +---+ +---+


Con trỏ ở trên "-H->" sẽ có cờ HEADER được đặt. Đó là
trang tiếp theo là trang tiếp theo được người đọc hoán đổi.
Con trỏ này có nghĩa là trang tiếp theo là trang đầu.

Khi trang đuôi gặp con trỏ đầu, nó sẽ sử dụng cmpxchg để
thay đổi con trỏ sang trạng thái UPDATE ::


trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-H->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

"-U->" đại diện cho một con trỏ ở trạng thái UPDATE.

Mọi quyền truy cập vào trình đọc sẽ cần phải có một số loại khóa để tuần tự hóa
các độc giả. Nhưng các nhà văn sẽ không bao giờ lấy một cái khóa để viết vào
bộ đệm vòng. Điều này có nghĩa là chúng ta chỉ cần lo lắng về một đầu đọc duy nhất,
và chỉ viết trước trong đội hình "ngăn xếp".

Khi đầu đọc cố gắng hoán đổi trang bằng bộ đệm vòng, nó
cũng sẽ sử dụng cmpxchg. Nếu cờ bit trong con trỏ tới
trang đầu không có cờ HEADER, việc so sánh sẽ thất bại
và người đọc sẽ cần tìm trang đầu mới và thử lại.
Lưu ý, cờ UPDATE và HEADER không bao giờ được đặt cùng một lúc.

Người đọc hoán đổi trang người đọc như sau::

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ
  +------+
                  +---+ +---+ +---+
                  ZZ0002ZZ--->ZZ0003ZZ--->ZZ0004ZZ
                  ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ
                  +---+ +---+ +---+
                   ^ ZZ0008ZZ
                   ZZ0009ZZ
                   +------H-------------+

Đầu đọc đặt con trỏ tiếp theo của trang đọc là HEADER tới trang sau
trang đầu::


+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------H----------+
  +------+ v
    |             +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ |
    ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ |<-+
    ZZ0008ZZ
    ZZ0009ZZ ^ ZZ0010ZZ
    ZZ0011ZZ +--------------+ ZZ0012ZZ
    ZZ0013ZZ
    +--------------------------------------+

Nó thực hiện cmpxchg với con trỏ tới trang đầu trước đó để tạo nó
trỏ đến trang người đọc. Lưu ý rằng con trỏ mới không có HEADER
bộ cờ.  Hành động này sẽ di chuyển trang đầu về phía trước một cách nguyên tử::

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------H----------+
  +------+ v
    |  ^ +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ->ZZ0004ZZ->ZZ0005ZZ
    ZZ0006ZZ ZZ0007ZZ<--ZZ0008ZZ<--ZZ0009ZZ<-+
    ZZ0010ZZ +---+ +---+ +---+ |
    ZZ0011ZZ ZZ0012ZZ |
    ZZ0013ZZ +-------------+ ZZ0014ZZ
    ZZ0015ZZ
    +------------------------------------+

Sau khi thiết lập trang đầu mới, con trỏ trước đó của trang đầu sẽ được đặt
đã cập nhật lên trang đọc::

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------H----------+
  +------+ <--------------+ v
    |  ^ +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ->ZZ0004ZZ->ZZ0005ZZ
    ZZ0006ZZ ZZ0007ZZ ZZ0008ZZ<--ZZ0009ZZ<-+
    ZZ0010ZZ +---+ +---+ +---+ |
    ZZ0011ZZ ZZ0012ZZ |
    ZZ0013ZZ +-------------+ ZZ0014ZZ
    ZZ0015ZZ
    +------------------------------------+

+------+
  ZZ0000ZZ RING BUFFER
  ZZ0001ZZ-------H-------------+ <--- Trang đầu mới
  +------+ <--------------+ v
    |  ^ +---+ +---+ +---+
    ZZ0002ZZ ZZ0003ZZ ZZ0004ZZ->ZZ0005ZZ
    ZZ0006ZZ Mới ZZ0007ZZ ZZ0008ZZ<--ZZ0009ZZ<-+
    Đầu đọc ZZ0010ZZ +---+ +---+ +---+ |
    Trang ZZ0011ZZ ----^ ZZ0012ZZ
    ZZ0013ZZ ZZ0014ZZ
    ZZ0015ZZ
    +------------------------------------+

Một điểm quan trọng khác: Trang mà trang người đọc trỏ lại
bởi con trỏ trước đó của nó (con trỏ hiện trỏ đến trang đầu mới)
không bao giờ trỏ lại trang người đọc. Đó là bởi vì trang đọc là
không phải là một phần của bộ đệm vòng. Duyệt bộ đệm vòng thông qua các con trỏ tiếp theo
sẽ luôn ở trong bộ đệm vòng. Duyệt qua bộ đệm vòng thông qua
con trỏ trước có thể không.

Lưu ý, cách xác định trang người đọc chỉ đơn giản bằng cách kiểm tra trang trước đó.
con trỏ của trang. Nếu con trỏ tiếp theo của trang trước không
trỏ lại trang gốc thì trang gốc là trang đọc::


+--------+
             ZZ0000ZZ tiếp theo +----+
             ZZ0001ZZ-------->ZZ0002ZZ<====== (trang đệm)
             +--------+ +----+
                 ZZ0003ZZ ^
                 ZZ0004ZZ tiếp theo
            trước |              +----+
                 +------------->ZZ0005ZZ
                                +----+

Cách trang đầu tiến về phía trước:

Khi trang đuôi gặp trang đầu và bộ đệm ở chế độ ghi đè
và có nhiều hoạt động viết diễn ra hơn, trang đầu phải được chuyển về phía trước trước khi
người viết có thể di chuyển trang đuôi. Cách thực hiện điều này là người viết
thực hiện cmpxchg để chuyển đổi con trỏ sang trang đầu từ HEADER
flag để đặt cờ UPDATE. Khi điều này được thực hiện, người đọc sẽ
không thể hoán đổi trang đầu từ bộ đệm và cũng không thể
di chuyển trang đầu cho đến khi người viết hoàn thành việc di chuyển.

Điều này giúp loại bỏ mọi chủng tộc mà người đọc có thể có đối với người viết. Người đọc
phải quay, và đây là lý do tại sao người đọc không thể đánh trước người viết::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-H->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Trang sau sẽ được đưa vào trang đầu mới::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Sau khi đã thiết lập trang đầu mới, chúng ta có thể đặt trang đầu cũ
con trỏ quay lại NORMAL::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Sau khi trang đầu đã được di chuyển, trang đuôi bây giờ có thể di chuyển về phía trước::

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+


Trên đây là những cập nhật tầm thường. Bây giờ cho các kịch bản phức tạp hơn.


Như đã nêu trước đó, nếu đủ số lần ghi trước lần ghi đầu tiên, thì
trang đuôi có thể đi vòng quanh bộ đệm và đáp ứng cam kết
trang. Tại thời điểm này, chúng ta phải bắt đầu bỏ thao tác ghi (thường là với một số loại
cảnh báo cho người dùng). Nhưng điều gì sẽ xảy ra nếu cam kết vẫn còn trên
trang đọc? Trang cam kết không phải là một phần của bộ đệm vòng. Trang đuôi
phải tính đến điều này::


trang đọc trang cam kết
                ZZ0000ZZ
                v |
               +---+ |
               ZZ0001ZZ<----------+
               ZZ0002ZZ
               ZZ0003ZZ------+
               +---+ |
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0004ZZ--->ZZ0005ZZ-H->ZZ0006ZZ--->ZZ0007ZZ--->
  --->ZZ0008ZZ<---ZZ0009ZZ<---ZZ0010ZZ<---ZZ0011ZZ<---
      +---+ +---+ +---+ +---+
                 ^
                 |
             trang đuôi

Nếu trang đuôi chỉ đơn giản là đẩy trang đầu về phía trước, thì cam kết khi
rời khỏi trang đọc sẽ không trỏ đến đúng trang.

Giải pháp cho vấn đề này là kiểm tra xem trang cam kết có nằm trên trang đọc không
trước khi đẩy trang đầu. Nếu đúng như vậy thì có thể giả định rằng
trang đuôi bao bọc bộ đệm và chúng ta phải bỏ ghi mới.

Đây không phải là điều kiện chạy đua vì trang cam kết chỉ có thể được di chuyển
bởi người viết ngoài cùng (người viết được ưu tiên trước).
Điều này có nghĩa là cam kết sẽ không di chuyển trong khi người viết đang di chuyển
trang đuôi. Người đọc không thể hoán đổi trang người đọc nếu nó cũng đang được
được sử dụng làm trang cam kết. Người đọc có thể chỉ cần kiểm tra xem cam kết
nằm ngoài trang người đọc. Khi trang cam kết rời khỏi trang đọc
nó sẽ không bao giờ quay trở lại trừ khi người đọc thực hiện một thao tác hoán đổi khác với
trang đệm cũng là trang cam kết.


Viết lồng nhau
-------------

Trong quá trình đẩy về phía trước của trang đuôi, trước tiên chúng ta phải đẩy về phía trước
trang đầu nếu trang đầu là trang tiếp theo. Nếu trang đầu
không phải là trang tiếp theo, trang đuôi chỉ được cập nhật bằng cmpxchg.

Chỉ có người viết mới di chuyển trang đuôi. Việc này phải được thực hiện một cách nguyên tử để bảo vệ
chống lại các nhà văn lồng nhau::

trang tạm thời = trang đuôi
  next_page = temp_page->tiếp theo
  cmpxchg(tail_page, temp_page, next_page)

Ở trên sẽ cập nhật trang đuôi nếu nó vẫn trỏ đến dự kiến
trang. Nếu điều này không thành công, thao tác ghi lồng nhau sẽ đẩy nó về phía trước, thao tác ghi hiện tại
không cần phải đẩy nó::


trang tạm thời
                 |
                 v
              trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Viết lồng nhau xuất hiện và di chuyển trang đuôi về phía trước::

trang đuôi (được di chuyển bởi người viết lồng nhau)
              trang tạm thời |
                 ZZ0000ZZ
                 v v
      +---+ +---+ +---+ +---+
  <---ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->ZZ0004ZZ--->
  --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
      +---+ +---+ +---+ +---+

Ở trên sẽ thất bại với cmpxchg, nhưng vì trang đuôi đã có rồi
được di chuyển về phía trước, người viết sẽ thử lại để dự trữ dung lượng lưu trữ
trên trang đuôi mới.

Nhưng việc di chuyển trang đầu phức tạp hơn một chút::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-H->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Việc ghi chuyển đổi con trỏ trang đầu thành UPDATE::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Nhưng nếu một trình soạn thảo lồng nhau ưu tiên ở đây, nó sẽ thấy rằng phần tiếp theo
trang là trang đầu nhưng nó cũng được lồng vào nhau. Nó sẽ phát hiện ra điều đó
nó được lồng vào nhau và sẽ lưu thông tin đó. Việc phát hiện là
thực tế là nó nhìn thấy cờ UPDATE thay vì HEADER hoặc NORMAL
con trỏ.

Người viết lồng nhau sẽ đặt con trỏ trang đầu mới::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Nhưng nó sẽ không thiết lập lại bản cập nhật trở lại bình thường. Chỉ có người viết
đã chuyển đổi một con trỏ từ HEAD sang UPDATE sẽ chuyển đổi nó trở lại
tới NORMAL::

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Sau khi trình ghi lồng nhau kết thúc, trình ghi ngoài cùng sẽ chuyển đổi
con trỏ UPDATE tới NORMAL::


trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ--->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+


Nó có thể còn phức tạp hơn nếu một số thao tác ghi lồng nhau được đưa vào và di chuyển
trang đuôi phía trước vài trang::


(người viết đầu tiên)

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-H->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Việc ghi chuyển đổi con trỏ trang đầu thành UPDATE::

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Người viết tiếp theo bước vào, xem bản cập nhật và thiết lập bản mới
trang đầu::

(người viết thứ hai)

trang đuôi
                 |
                 v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Người viết lồng nhau di chuyển trang đuôi về phía trước. Nhưng không đặt cái cũ
cập nhật trang lên NORMAL vì đây không phải là người viết ngoài cùng::

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Một người viết khác đánh trước và coi trang sau trang đuôi là trang đầu.
Nó thay đổi từ HEAD thành UPDATE::

(người viết thứ ba)

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-U->ZZ0003ZZ--->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Người viết sẽ chuyển trang đầu về phía trước::


(người viết thứ ba)

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-U->ZZ0003ZZ-H->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Nhưng bây giờ người viết thứ ba đã thay đổi cờ HEAD thành UPDATE
sẽ chuyển đổi nó thành bình thường::


(người viết thứ ba)

trang đuôi
                          |
                          v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ-H->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+


Sau đó nó sẽ di chuyển trang đuôi và quay trở lại người viết thứ hai::


(người viết thứ hai)

trang đuôi
                                   |
                                   v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ-H->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+


Người viết thứ hai sẽ không thể di chuyển trang đuôi vì nó đã được
đã di chuyển nên nó sẽ thử lại và thêm dữ liệu của nó vào trang đuôi mới.
Nó sẽ trở lại với người viết đầu tiên::


(người viết đầu tiên)

trang đuôi
                                   |
                                   v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ--->ZZ0003ZZ-H->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Người viết đầu tiên không thể biết rõ liệu trang đuôi có bị di chuyển hay không
trong khi nó cập nhật trang HEAD. Sau đó nó sẽ cập nhật trang đầu thành
những gì nó nghĩ là trang đầu mới::


(người viết đầu tiên)

trang đuôi
                                   |
                                   v
      +---+ +---+ +---+ +---+
  <---ZZ0000ZZ--->ZZ0001ZZ-U->ZZ0002ZZ-H->ZZ0003ZZ-H->
  --->ZZ0004ZZ<---ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---
      +---+ +---+ +---+ +---+

Vì cmpxchg trả về giá trị cũ của con trỏ nên người viết đầu tiên
sẽ thấy nó đã thành công trong việc cập nhật con trỏ từ NORMAL lên HEAD.
Nhưng như chúng ta có thể thấy, điều này là chưa đủ tốt. Nó cũng phải kiểm tra xem
nếu trang đuôi ở vị trí cũ hoặc ở trang tiếp theo::


(người viết đầu tiên)

Trang đuôi A B
                 ZZ0000ZZ |
                 v v v
      +---+ +---+ +---+ +---+
  <---ZZ0001ZZ--->ZZ0002ZZ-U->ZZ0003ZZ-H->ZZ0004ZZ-H->
  --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
      +---+ +---+ +---+ +---+

Nếu trang đuôi != A và trang đuôi != B thì phải reset con trỏ
quay lại NORMAL. Thực tế là nó chỉ cần lo lắng về việc lồng nhau
người viết có nghĩa là nó chỉ cần kiểm tra điều này sau khi thiết lập trang HEAD ::


(người viết đầu tiên)

Trang đuôi A B
                 ZZ0000ZZ |
                 v v v
      +---+ +---+ +---+ +---+
  <---ZZ0001ZZ--->ZZ0002ZZ-U->ZZ0003ZZ--->ZZ0004ZZ-H->
  --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
      +---+ +---+ +---+ +---+

Bây giờ người viết có thể cập nhật trang đầu. Đây cũng là lý do tại sao trang đầu phải
vẫn ở UPDATE và chỉ được thiết lập lại bởi người ghi ngoài cùng. Điều này ngăn cản
người đọc nhìn thấy trang đầu không chính xác::


(người viết đầu tiên)

Trang đuôi A B
                 ZZ0000ZZ |
                 v v v
      +---+ +---+ +---+ +---+
  <---ZZ0001ZZ--->ZZ0002ZZ--->ZZ0003ZZ--->ZZ0004ZZ-H->
  --->ZZ0005ZZ<---ZZ0006ZZ<---ZZ0007ZZ<---ZZ0008ZZ<---
      +---+ +---+ +---+ +---+