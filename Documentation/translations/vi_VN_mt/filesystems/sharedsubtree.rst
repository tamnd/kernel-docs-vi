.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/sharedsubtree.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

====================
Cây con được chia sẻ
====================

.. Contents:
	1) Overview
	2) Features
	3) Setting mount states
	4) Use-case
	5) Detailed semantics
	6) Quiz
	7) FAQ
	8) Implementation


1) Tổng quan
------------

Hãy xem xét tình huống sau:

Một tiến trình muốn sao chép không gian tên của chính nó nhưng vẫn muốn truy cập vào đĩa CD
đã được gắn kết gần đây.  Ngữ nghĩa cây con được chia sẻ cung cấp những thông tin cần thiết
cơ chế thực hiện được những điều trên.

Nó cung cấp các khối xây dựng cần thiết cho các tính năng như không gian tên cho mỗi người dùng
và hệ thống tập tin được phiên bản.

2) Tính năng
------------

Cây con dùng chung cung cấp bốn loại thú cưỡi khác nhau; cấu trúc vfsmount thành
chính xác:


a) ZZ0000ZZ có thể được sao chép thành nhiều điểm gắn kết và tất cả
   bản sao tiếp tục giống hệt nhau.

Đây là một ví dụ:

Giả sử /mnt có một mount được chia sẻ::

# mount --chia sẻ /mnt

   .. note::
      mount(8) command now supports the --make-shared flag,
      so the sample 'smount' program is no longer needed and has been
      removed.

   ::

# mount --bind /mnt /tmp

Lệnh trên sao chép quá trình gắn kết tại /mnt thành điểm gắn kết /tmp
   và nội dung của cả hai giá treo vẫn giống nhau.

   ::

#ls /mnt
     a b c

#ls /tmp
     a b c

Bây giờ giả sử chúng ta gắn một thiết bị tại /tmp/a::

# mount /dev/sd0 /tmp/a

# ls /tmp/a
     t1 t2 t3

# ls /mnt/a
     t1 t2 t3

Lưu ý rằng giá trị gắn kết cũng đã được truyền đến giá trị gắn kết tại /mnt.

Và điều này cũng đúng ngay cả khi/dev/sd0 được gắn trên/mnt/a. các
   nội dung cũng sẽ hiển thị dưới /tmp/a.


b) ZZ0000ZZ giống như một thú cưỡi được chia sẻ ngoại trừ các sự kiện gắn kết và umount
   chỉ truyền về phía nó.

Tất cả các giá treo nô lệ đều có một giá treo chính được chia sẻ.

Đây là một ví dụ:

Giả sử /mnt có một mount được chia sẻ::

# mount --chia sẻ /mnt

Hãy liên kết mount /mnt với /tmp::

# mount --bind /mnt /tmp

mount mới tại /tmp trở thành mount được chia sẻ và nó là bản sao của
   gắn kết tại /mnt.

Bây giờ hãy gắn kết tại /tmp; nô lệ của /mnt::

# mount --làm nô lệ /tmp

hãy gắn kết /dev/sd0 trên /mnt/a::

# mount /dev/sd0 /mnt/a

# ls /mnt/a
     t1 t2 t3

# ls /tmp/a
     t1 t2 t3

Lưu ý sự kiện gắn kết đã được truyền tới gắn kết tại/tmp

Tuy nhiên, hãy xem điều gì sẽ xảy ra nếu chúng ta gắn thứ gì đó lên giá đỡ tại
   /tmp::

# mount /dev/sd1 /tmp/b

# ls /tmp/b
     s1 s2 s3

# ls /mnt/b

Lưu ý cách sự kiện gắn kết chưa được truyền đến gắn kết tại
   /mnt


c) ZZ0000ZZ không chuyển tiếp hoặc nhận sự lan truyền.

Đây là thú cưỡi mà chúng ta quen thuộc. Đây là loại mặc định.


d) ZZ0000ZZ, đúng như tên gọi, là một thiết bị riêng tư không thể liên kết
   gắn kết.

giả sử chúng ta có một mount tại /mnt và chúng ta làm cho nó không thể liên kết được::

# mount --make-unbindable /mnt

Hãy thử liên kết gắn kết gắn kết này ở một nơi khác::

# mount --bind /mnt /tmp mount: sai loại fs, tùy chọn xấu, xấu
     siêu khối trên /mnt hoặc có quá nhiều hệ thống tệp được gắn

Việc ràng buộc một thú cưỡi không thể liên kết là một thao tác không hợp lệ.


3) Đặt trạng thái gắn kết
-------------------------

Lệnh mount (gói util-linux) có thể được sử dụng để thiết lập mount
tiểu bang::

mount --make-shared điểm gắn kết
    mount --make-slave điểm gắn kết
    mount --make-private điểm gắn kết
    mount --make-unbindable điểm gắn kết


4) Các trường hợp sử dụng
-------------------------

A) Một tiến trình muốn sao chép không gian tên của chính nó nhưng vẫn muốn
   truy cập vào đĩa CD đã được gắn gần đây.

Giải pháp:

Quản trị viên hệ thống có thể thực hiện gắn kết tại /cdrom chia sẻ::

gắn kết --bind /cdrom /cdrom
     gắn kết --make-shared /cdrom

Bây giờ bất kỳ tiến trình nào sao chép một không gian tên mới sẽ có một
   mount tại /cdrom là bản sao của cùng một mount trong
   không gian tên cha mẹ.

Vì vậy, khi một đĩa CD được đưa vào và gắn vào /cdrom thì mount đó sẽ nhận được
   được truyền tới mount khác tại /cdrom trong tất cả các bản sao khác
   không gian tên.

B) Một tiến trình muốn các phần gắn kết của nó vô hình đối với bất kỳ tiến trình nào khác, nhưng
   vẫn có thể nhìn thấy các giá đỡ hệ thống khác.

Giải pháp:

Để bắt đầu, quản trị viên có thể đánh dấu toàn bộ cây gắn kết
   có thể chia sẻ::

gắn kết --make-rshared /

Một quy trình mới có thể sao chép một không gian tên mới. Và đánh dấu một phần nào đó
   không gian tên của nó là nô lệ::

gắn kết --make-rslave /myprivatetree

Do đó, mọi hoạt động gắn kết trong /myprivatetree được thực hiện bởi
   quá trình sẽ không hiển thị trong bất kỳ không gian tên nào khác. Tuy nhiên gắn kết
   được thực hiện trong không gian tên cha mẹ trong/myprivatetree vẫn hiển thị
   trong không gian tên của tiến trình.


Ngoài các ngữ nghĩa trên, tính năng này cung cấp
khối xây dựng để giải quyết các vấn đề sau:

C) Không gian tên cho mỗi người dùng

Ngữ nghĩa ở trên cho phép một cách để chia sẻ các mount trên
    không gian tên.  Nhưng không gian tên được liên kết với các quy trình. Nếu
    không gian tên được tạo thành đối tượng hạng nhất với người dùng API để
    liên kết/tách liên kết một vùng tên với userid, sau đó mỗi người dùng
    có thể có không gian tên riêng của mình và điều chỉnh nó cho phù hợp với mình
    yêu cầu. Điều này cần được hỗ trợ trong PAM.

D) Các tệp đã được phiên bản

Nếu toàn bộ cây gắn kết có thể nhìn thấy được ở nhiều vị trí thì
    một hệ thống tệp phiên bản cơ bản có thể trả về các phiên bản khác nhau
    phiên bản của tệp tùy thuộc vào đường dẫn được sử dụng để truy cập vào tệp đó
    tập tin.

Một ví dụ là::

gắn kết --make-shared /
       gắn kết --rbind / /view/v1
       gắn kết --rbind / /view/v2
       gắn kết --rbind / /view/v3
       gắn kết --rbind / /view/v4

và nếu /usr đã gắn hệ thống tập tin phiên bản thì đó
    mount xuất hiện tại /view/v1/usr, /view/v2/usr, /view/v3/usr và
    /view/v4/usr nữa

Người dùng có thể yêu cầu phiên bản v3 của tệp /usr/fs/namespace.c
    bằng cách truy cập /view/v3/usr/fs/namespace.c . Cơ bản
    hệ thống tập tin phiên bản sau đó có thể giải mã phiên bản v3 của
    hệ thống tập tin đang được yêu cầu và trả về tương ứng
    inode.

5) Ngữ nghĩa chi tiết
---------------------
Phần dưới đây giải thích ngữ nghĩa chi tiết của
các hoạt động liên kết, rbind, di chuyển, gắn kết, umount và sao chép không gian tên.

.. Note::
   the word 'vfsmount' and the noun 'mount' have been used
   to mean the same thing, throughout this document.

a) Trạng thái gắn kết

ZZ0000ZZ được định nghĩa là sự kiện được tạo trên vfsmount
   dẫn đến các hành động gắn kết hoặc ngắt kết nối trong các vfsmount khác.

ZZ0000ZZ được định nghĩa là một nhóm vfsmount lan truyền
   các sự kiện với nhau.

Một mount nhất định có thể ở một trong các trạng thái sau:

(1) Thú cưỡi dùng chung

ZZ0000ZZ được định nghĩa là vfsmount thuộc về một
       nhóm ngang hàng.

Ví dụ::

mount --make-shared /mnt
         gắn kết --bind /mnt /tmp

Mount tại /mnt và tại /tmp đều được chia sẻ và thuộc về
       vào cùng một nhóm ngang hàng. Bất cứ thứ gì được gắn hoặc tháo dưới
       /mnt hoặc /tmp phản ánh trong tất cả các mount khác của nó
       nhóm.


(2) Giá đỡ nô lệ

ZZ0000ZZ được định nghĩa là vfsmount nhận
       các sự kiện lan truyền và không chuyển tiếp các sự kiện lan truyền.

Một giá treo nô lệ như tên gọi của nó có một giá treo chính mà từ đó
       sự kiện mount/unmount được nhận. Sự kiện không lan truyền từ
       nô lệ gắn kết với chủ.  Chỉ có thể thực hiện gắn kết được chia sẻ
       một nô lệ bằng cách thực hiện lệnh sau::

gắn kết --make-nô lệ

Một vật gắn kết được chia sẻ được tạo thành nô lệ sẽ không được chia sẻ nữa trừ khi
       được sửa đổi để được chia sẻ.

(3) Được chia sẻ và nô lệ

Một vfsmount có thể là ZZ0000ZZ cũng như ZZ0001ZZ.  Trạng thái này
       chỉ ra rằng mount là nô lệ của một số vfsmount và
       cũng có nhóm ngang hàng của riêng mình.  Vfsmount này nhận được sự lan truyền
       các sự kiện từ vfsmount chính của nó và cũng chuyển tiếp việc truyền bá
       các sự kiện tới 'nhóm ngang hàng' và tới vfsmounts nô lệ của nó.

Nói đúng ra, vfsmount được chia sẻ có cái riêng của nó
       nhóm ngang hàng và nhóm ngang hàng này là nô lệ của một số nhóm khác
       nhóm ngang hàng.

Chỉ một vfsmount nô lệ mới có thể được tạo thành 'được chia sẻ và nô lệ' bởi
       hoặc thực hiện lệnh sau ::

gắn kết --make-share

hoặc bằng cách di chuyển vfsmount nô lệ dưới một vfsmount được chia sẻ.

(4) Núi riêng

ZZ0000ZZ được định nghĩa là vfsmount không
       nhận hoặc chuyển tiếp bất kỳ sự kiện lan truyền nào.

(5) Gắn kết không thể liên kết

ZZ0000ZZ được định nghĩa là vfsmount không
       nhận hoặc chuyển tiếp bất kỳ sự kiện lan truyền nào và không thể
       được gắn kết.


Sơ đồ trạng thái:

Sơ đồ trạng thái bên dưới giải thích sự chuyển đổi trạng thái của một giá treo,
       để đáp lại các lệnh khác nhau ::

-----------------------------------------------------------------------
            |             |chia sẻ trang điểm ZZ0001ZZ riêng tư ZZ0002ZZ
            --------------ZZ0003ZZ--------------ZZ0004ZZ-------------|
            |shared       |chia sẻ ZZ0006ZZ riêng tư ZZ0007ZZ
            ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ
            ZZ0011ZZ-----------ZZ0012ZZ--------------ZZ0013ZZ
            |slave        |chia sẻ ZZ0015ZZ riêng tư ZZ0016ZZ
            |             |and nô lệ ZZ0018ZZ ZZ0019ZZ
            ZZ0020ZZ-------------ZZ0021ZZ--------------ZZ0022ZZ
            |shared       |chia sẻ ZZ0024ZZ riêng tư ZZ0025ZZ
            |and slave    |và nô lệ ZZ0027ZZ ZZ0028ZZ
            ZZ0029ZZ-------------ZZ0030ZZ--------------ZZ0031ZZ
            |private      |chia sẻ ZZ0033ZZ riêng tư ZZ0034ZZ
            ZZ0035ZZ-------------ZZ0036ZZ--------------ZZ0037ZZ
            |unbindable   |chia sẻ ZZ0039ZZ riêng tư ZZ0040ZZ
            -------------------------------------------------------------------------

* nếu giá treo được chia sẻ là giá treo duy nhất trong nhóm ngang hàng của nó, khiến nó trở thành
            nô lệ, tự động đặt nó ở chế độ riêng tư. Lưu ý rằng không có chủ
            mà nó có thể bị lệ thuộc vào.

** gắn một thú cưỡi không dùng chung không có tác dụng gì với thú cưỡi.

Ngoài các lệnh được liệt kê bên dưới, thao tác 'di chuyển' cũng thay đổi
       trạng thái của giá treo tùy thuộc vào loại giá treo đích. của nó
       giải thích ở phần 5d.

b) Ngữ nghĩa ràng buộc

Hãy xem xét lệnh sau::

mount --bind A/a B/b

trong đó 'A' là giá đỡ nguồn, 'a' là ngàm trong giá đỡ 'A', 'B'
   là giá treo đích và 'b' là răng trong giá treo đích.

Kết quả phụ thuộc vào kiểu thú cưỡi của 'A' và 'B'. cái bàn
   bên dưới chứa tài liệu tham khảo nhanh::

--------------------------------------------------------------------------
            ZZ0000ZZ
            ZZ0001ZZ
            ZZ0002ZZ chia sẻ ZZ0003ZZ nô lệ ZZ0004ZZ
            ZZ0005ZZ ZZ0006ZZ ZZ0007ZZ
            ZZ0008ZZ ZZ0009ZZ ZZ0010ZZ |
            ZZ0011ZZ ZZ0012ZZ ZZ0013ZZ
            ZZ0014ZZ
            ZZ0015ZZ chia sẻ ZZ0016ZZ chia sẻ & nô lệ ZZ0017ZZ
            ZZ0018ZZ ZZ0019ZZ ZZ0020ZZ
            ZZ0021ZZ chia sẻ ZZ0022ZZ nô lệ ZZ0023ZZ
            *******************************************************************************

Chi tiết:

1. 'A' là giá treo dùng chung và 'B' là giá treo dùng chung. Một thú cưỡi mới 'C'
      bản sao của 'A', được tạo. Nha khoa gốc của nó là 'a' . 'C' là
      được gắn trên ngàm 'B' tại nha khoa 'b'. Ngoài ra còn có thú cưỡi mới 'C1', 'C2', 'C3' ...
      được tạo và gắn tại nha khoa 'b' trên tất cả các ngàm nơi 'B'
      truyền bá tới. Cây nhân giống mới chứa 'C1',..,'Cn' là
      được tạo ra. Cây nhân giống này giống hệt cây nhân giống của
      'B'.  Và cuối cùng nhóm ngang hàng của 'C' được sáp nhập với nhóm ngang hàng
      của 'A'.

2. 'A' là giá treo riêng và 'B' là giá treo chung. Một thú cưỡi mới 'C'
      bản sao của 'A', được tạo. Nha khoa gốc của nó là 'a'. 'C' là
      được gắn trên ngàm 'B' tại nha khoa 'b'. Ngoài ra còn có thú cưỡi mới 'C1', 'C2', 'C3' ...
      được tạo và gắn tại nha khoa 'b' trên tất cả các ngàm nơi 'B'
      truyền bá tới. Một cây nhân giống mới được thiết lập chứa tất cả các giá trị gắn kết mới
      'C', 'C1',.., 'Cn' có cấu hình hoàn toàn giống với
      cây nhân giống cho 'B'.

3. 'A' là giá treo phụ của giá treo 'Z' và 'B' là giá treo dùng chung. Một cái mới
      mount 'C' là bản sao của 'A', được tạo. Nha khoa gốc của nó là 'a' .
      'C' được gắn trên ngàm 'B' tại nha khoa 'b'. Ngoài ra còn có các thú cưỡi mới 'C1', 'C2',
      'C3' ... được tạo và gắn tại nha khoa 'b' trên tất cả các ngàm nơi
      'B' truyền tới. Một cây nhân giống mới chứa các thú cưỡi mới
      'C','C1',.. 'Cn' được tạo. Cây nhân giống này giống hệt cây
      cây nhân giống cho 'B'. Và cuối cùng là thú cưỡi 'C' và nhóm ngang hàng của nó
      được làm nô lệ của thú cưỡi 'Z'.  Nói cách khác, mount 'C' nằm trong
      trạng thái 'nô lệ và chia sẻ'.

4. 'A' là thú cưỡi không thể liên kết và 'B' là thú cưỡi được chia sẻ. Đây là một
      hoạt động không hợp lệ.

5. 'A' là giá treo riêng tư và 'B' là giá treo không chia sẻ (riêng tư hoặc nô lệ hoặc
      không thể liên kết) gắn kết. Một thú cưỡi 'C' mới là bản sao của 'A', được tạo.
      Nha khoa gốc của nó là 'a'. 'C' được gắn trên ngàm 'B' tại nha khoa 'b'.

6. 'A' là giá treo dùng chung và 'B' là giá treo không dùng chung. Một thú cưỡi mới 'C'
      đó là bản sao của 'A' được tạo. Nha khoa gốc của nó là 'a'. 'C' là
      được gắn trên ngàm 'B' tại nha khoa 'b'.  'C' được trở thành thành viên của
      nhóm ngang hàng của 'A'.

7. 'A' là giá treo phụ của giá treo 'Z' và 'B' là giá treo không dùng chung. A
      thú cưỡi 'C' mới là bản sao của 'A' được tạo. Chân răng của nó là
      'a'.  'C' được gắn trên ngàm 'B' tại nha khoa 'b'. Ngoài ra 'C' được đặt làm
      gắn kết nô lệ của 'Z'. Nói cách khác 'A' và 'C' đều là giá treo nô lệ của
      'Z'.  Tất cả các sự kiện gắn kết/ngắt kết nối trên 'Z' sẽ truyền tới 'A' và 'C'. Nhưng
      gắn kết/ngắt kết nối trên 'A' không lan truyền ở bất kỳ nơi nào khác. Tương tự
      gắn kết/ngắt kết nối trên 'C' không lan truyền ở bất kỳ nơi nào khác.

8. 'A' là thú cưỡi không thể liên kết và 'B' là thú cưỡi không chia sẻ. Đây là một
      hoạt động không hợp lệ. Một giá treo không thể gắn kết thì không thể gắn kết được.

c) Ngữ nghĩa Rbind

rbind giống như liên kết. Bind sao chép gắn kết được chỉ định.  Rbind
   sao chép tất cả các mount trong cây thuộc về mount đã chỉ định.
   Gắn kết Rbind là gắn kết liên kết được áp dụng cho tất cả các gắn kết trong cây.

Nếu cây nguồn là rbind có một số giá trị gắn kết không thể liên kết,
   sau đó cây con bên dưới giá trị gắn kết không thể liên kết sẽ được cắt bớt trong cây mới
   vị trí.

ví dụ:

giả sử chúng ta có cây gắn kết sau::

A
              / \
              B C
             / \ / \
             D E F G

Giả sử tất cả các mount ngoại trừ mount C trong cây đều
   thuộc loại không phải là không thể ràng buộc.

Nếu cây này chắc chắn sẽ nói Z

Chúng ta sẽ có cây sau tại vị trí mới::

Z
                |
                A'
               /
              B' Lưu ý cách tỉa cây dưới C
             / \ ở vị trí mới.
            D'E'



d) Di chuyển ngữ nghĩa

Hãy xem xét lệnh sau::

gắn kết --di chuyển A B/b

trong đó 'A' là giá trị nguồn, 'B' là giá trị đích và 'b' là
   nha khoa ở điểm đến gắn kết.

Kết quả phụ thuộc vào kiểu thú cưỡi của 'A' và 'B'. cái bàn
   dưới đây là một tài liệu tham khảo nhanh::

--------------------------------------------------------------------------
            ZZ0000ZZ
            |******************************************************************************
            ZZ0001ZZ chia sẻ ZZ0002ZZ nô lệ ZZ0003ZZ
            ZZ0004ZZ ZZ0005ZZ ZZ0006ZZ
            ZZ0007ZZ ZZ0008ZZ ZZ0009ZZ |
            ZZ0010ZZ ZZ0011ZZ ZZ0012ZZ
            |******************************************************************************
            ZZ0013ZZ đã chia sẻ |     shared     |shared và Slave|  invalid   |
            ZZ0016ZZ ZZ0017ZZ ZZ0018ZZ
            ZZ0019ZZ chia sẻ ZZ0020ZZ nô lệ ZZ0021ZZ
            *******************************************************************************

   .. Note:: moving a mount residing under a shared mount is invalid.

Chi tiết như sau:

1. 'A' là giá treo dùng chung và 'B' là giá treo dùng chung.  Núi 'A' là
      được gắn trên ngàm 'B' tại nha khoa 'b'.  Ngoài ra còn có các thú cưỡi mới 'A1', 'A2'...'An'
      được tạo và gắn tại nha khoa 'b' trên tất cả các giá treo nhận được
      lan truyền từ đỉnh 'B'. Một cây nhân giống mới được tạo ra trong
      cấu hình chính xác giống như của 'B'. Cây nhân giống mới này
      chứa tất cả các giá treo mới 'A1', 'A2'... 'An'.  Và cái mới này
      cây nhân giống được nối vào cây nhân giống đã có
      của 'A'.

2. 'A' là giá treo riêng và 'B' là giá treo chung. Núi 'A' là
      được gắn trên ngàm 'B' tại nha khoa 'b'. Ngoài ra còn có thú cưỡi mới 'A1', 'A2'... 'An'
      được tạo và gắn tại nha khoa 'b' trên tất cả các giá treo nhận được
      lan truyền từ đỉnh 'B'. Giá treo 'A' trở thành giá treo chung và
      cây nhân giống được tạo ra giống hệt với cây
      'B'. Cây nhân giống mới này chứa tất cả các giá trị gắn kết mới 'A1',
      'A2'... 'An'.

3. 'A' là giá treo phụ của giá treo 'Z' và 'B' là giá treo dùng chung.  các
      Giá đỡ 'A' được gắn trên giá đỡ 'B' tại nha khoa 'b'.  Ngoài ra còn có thú cưỡi mới 'A1',
      'A2'... 'An' được tạo và gắn tại nha khoa 'b' trên tất cả các ngàm
      nhận được sự lan truyền từ mount 'B'. Một cây nhân giống mới được tạo
      trong cùng cấu hình với cấu hình của 'B'. Sự lan truyền mới này
      cây chứa tất cả các giá trị gắn kết mới 'A1', 'A2'... 'An'.  Và cái mới này
      cây nhân giống được nối vào cây nhân giống hiện có của
      'A'.  Núi 'A' tiếp tục là núi phụ của 'Z' nhưng nó cũng
      trở thành 'được chia sẻ'.

4. 'A' là thú cưỡi không thể liên kết và 'B' là thú cưỡi được chia sẻ. hoạt động
      không hợp lệ. Bởi vì việc gắn bất cứ thứ gì trên giá treo chung 'B' có thể
      tạo các giá treo mới được gắn trên các giá treo nhận được
      lan truyền từ 'B'.  Và vì thú cưỡi 'A' không thể liên kết được nên việc nhân bản
      nó không thể gắn kết ở các điểm gắn kết khác.

5. 'A' là giá treo riêng tư và 'B' là giá treo không chia sẻ (riêng tư hoặc nô lệ hoặc
      không thể liên kết) gắn kết. Giá đỡ 'A' được gắn trên giá đỡ 'B' tại nha khoa 'b'.

6. 'A' là giá treo dùng chung và 'B' là giá treo không dùng chung.  Núi 'A'
      được gắn trên ngàm 'B' tại nha khoa 'b'.  Núi 'A' tiếp tục là một
      gắn kết được chia sẻ.

7. 'A' là giá treo phụ của giá treo 'Z' và 'B' là giá treo không dùng chung.
      Giá đỡ 'A' được gắn trên giá đỡ 'B' tại nha khoa 'b'.  Núi 'A'
      tiếp tục là thú cưỡi nô lệ của thú cưỡi 'Z'.

8. 'A' là thú cưỡi không thể liên kết và 'B' là thú cưỡi không chia sẻ. gắn kết
      'A' được gắn trên ngàm 'B' tại nha khoa 'b'. Núi 'A' tiếp tục là một
      gắn kết không thể ràng buộc.

e) Ngữ nghĩa gắn kết

Hãy xem xét lệnh sau::

gắn thiết bị B/b

'B' là giá đỡ đích và 'b' là ngàm ở đích
   gắn kết.

Thao tác trên giống như thao tác liên kết ngoại trừ
   rằng giá trị gắn kết nguồn luôn là giá trị gắn kết riêng tư.


f) Ngắt kết nối ngữ nghĩa

Hãy xem xét lệnh sau::

số lượng A

trong đó 'A' là giá đỡ được gắn trên giá đỡ 'B' tại nha khoa 'b'.

Nếu ngàm 'B' được chia sẻ thì tất cả các ngàm được lắp gần đây nhất tại nha khoa
   'b' trên các giá treo nhận được sự lan truyền từ giá treo 'B' và không có
   các giá treo phụ bên trong chúng không được gắn kết.

Ví dụ: Giả sử 'B1', 'B2', 'B3' là các giá trị được chia sẻ truyền tới
   lẫn nhau.

giả sử 'A1', 'A2', 'A3' lần đầu tiên được gắn tại nha khoa 'b' trên ngàm
   'B1', 'B2' và 'B3' tương ứng.

giả sử 'C1', 'C2', 'C3' được gắn tiếp theo tại cùng một nha khoa 'b' trên
   gắn kết 'B1', 'B2' và 'B3' tương ứng.

nếu 'C1' không được gắn kết, thì tất cả các giá treo được gắn gần đây nhất trên
   'B1' và trên các giá treo mà 'B1' truyền tới không được gắn kết.

'B1' truyền tới 'B2' và 'B3'. Và giá treo được gắn gần đây nhất
   trên 'B2' tại nha khoa 'b' là 'C2' và của ngàm 'B3' là 'C3'.

Vì vậy, tất cả 'C1', 'C2' và 'C3' phải được ngắt kết nối.

Nếu bất kỳ 'C2' hoặc 'C3' nào có một số giá đỡ con thì giá treo đó không phải là
   chưa được gắn kết, nhưng tất cả các giá treo khác đều chưa được gắn kết. Tuy nhiên nếu 'C1' được thông báo
   để được ngắt kết nối và 'C1' có một số giá trị gắn kết phụ, thao tác umount là
   thất bại hoàn toàn.

g) Sao chép không gian tên

Một không gian tên được nhân bản chứa tất cả các mount giống như của cha mẹ
   không gian tên.

Giả sử 'A' và 'B' là các giá trị gắn kết tương ứng trong cha mẹ và
   không gian tên con.

Nếu 'A' được chia sẻ thì 'B' cũng được chia sẻ và 'A' và 'B' truyền tới
   lẫn nhau.

Nếu 'A' là giá treo phụ của 'Z' thì 'B' cũng là giá treo phụ của
   'Z'.

Nếu 'A' là thú cưỡi riêng thì 'B' cũng là thú cưỡi riêng.

Nếu 'A' là thú cưỡi không thể liên kết thì 'B' cũng là thú cưỡi không thể liên kết.


6) Câu đố
---------

A. Kết quả của chuỗi lệnh sau là gì?

   ::

gắn kết --bind /mnt /mnt
       mount --make-shared /mnt
       gắn kết --bind /mnt /tmp
       gắn kết --move /tmp /mnt/1

nội dung của /mnt /mnt/1 /mnt/1/1 nên là gì?
   Tất cả chúng có nên giống hệt nhau không? hoặc nên /mnt và /mnt/1
   chỉ giống nhau thôi?


B. Kết quả của chuỗi lệnh sau là gì?

   ::

gắn kết --make-rshared /
       mkdir -p /v/1
       gắn kết --rbind / /v/1

nội dung của /v/1/v/1 sẽ là gì?


C. Kết quả của chuỗi lệnh sau là gì?

   ::

gắn kết --bind /mnt /mnt
       mount --make-shared /mnt
       mkdir -p /mnt/1/2/3 /mnt/1/test
       gắn kết --bind /mnt/1 /tmp
       gắn kết --make-slave /mnt
       mount --make-shared /mnt
       gắn kết --bind /mnt/1/2 /tmp1
       gắn kết --make-slave /mnt

Tại thời điểm này, chúng ta có mount đầu tiên tại /tmp và
   răng giả gốc của nó là 1. Hãy gọi ngàm này là 'A'
   Và sau đó chúng ta có lần gắn kết thứ hai tại /tmp1 với root
   nha khoa 2. Hãy gọi ngàm này là 'B'
   Tiếp theo chúng ta có ngàm thứ ba tại /mnt với răng giả gốc
   mnt. Hãy gọi thú cưỡi này là 'C'

'B' là nô lệ của 'A' và 'C' là nô lệ của 'B'
   A -> B -> C

tại thời điểm này nếu chúng ta thực hiện lệnh sau ::

mount --bind /bin /tmp/test

Việc gắn kết được thử trên 'A'

giá treo có truyền tới 'B' và 'C' không?

nội dung của nó sẽ là gì
   /mnt/1/kiểm tra được không?

7) FAQ
------

1. Tại sao cần có bind mount? Nó khác với các liên kết tượng trưng như thế nào?

các liên kết tượng trưng có thể trở nên cũ nếu gắn kết đích bị
   chưa được gắn kết hoặc di chuyển. Các liên kết gắn kết tiếp tục tồn tại ngay cả khi
   gắn kết khác không được gắn kết hoặc di chuyển.

2. Tại sao cây con chia sẻ không thể được triển khai bằng cách sử dụng importfs?

importfs là một cách nặng nề để hoàn thành một phần những gì
   cây con chia sẻ có thể làm được. Tôi không thể tưởng tượng được một cách để thực hiện
   ngữ nghĩa của việc gắn kết nô lệ bằng cách sử dụng importfs?

3. Tại sao cần gắn kết không thể liên kết?

Giả sử chúng ta muốn sao chép cây gắn kết ở nhiều
   các vị trí trong cùng một cây con.

nếu một rbind gắn kết một cây trong cùng một cây con 'n' lần
   số lượng gắn kết được tạo là hàm số mũ của 'n'.
   Việc gắn kết không thể liên kết có thể giúp loại bỏ liên kết không cần thiết
   gắn kết. Đây là một ví dụ.

bước 1:
      giả sử cây gốc chỉ có hai thư mục với
      một vfsmount::

gốc
                                   / \
                                  tmp usr

Và chúng tôi muốn nhân rộng cây ở nhiều
      điểm gắn kết trong /root/tmp

bước 2:
      ::


mount --make-shared /root

mkdir -p /tmp/m1

gắn kết --rbind /root /tmp/m1

cây mới bây giờ trông như thế này::

gốc
                                   / \
                                 tmp usr
                                /
                               m1
                              / \
                             tmp usr
                             /
                            m1

nó có hai vfsmount

bước 3:
      ::

mkdir -p /tmp/m2
                            gắn kết --rbind /root /tmp/m2

cây mới bây giờ trông như thế này::

gốc
                                     / \
                                   tmp usr
                                  / \
                                m1 m2
                               / \ / \
                             tmp usr tmp usr
                             / \ /
                            m1 m2 m1
                                / \ / \
                              tmp usr tmp usr
                              / / \
                             m1 m1 m2
                            / \
                          tmp usr
                          / \
                         m1 m2

nó có 6 vfsmount

bước 4:
      ::

mkdir -p /tmp/m3
                          gắn kết --rbind /root /tmp/m3

Tôi sẽ không vẽ cái cây..nhưng nó có 24 vfsmount


ở bước i số lượng vfsmounts là V[i] = i*V[i-1].
   Đây là một hàm số mũ. Và cây này còn nhiều hơn thế nữa
   gắn kết hơn những gì chúng tôi thực sự cần ngay từ đầu.

Người ta có thể sử dụng một loạt umount ở mỗi bước để cắt tỉa
   loại bỏ các gắn kết không cần thiết. Nhưng có một giải pháp tốt hơn.
   Gắn kết không thể nhân bản có ích ở đây.

bước 1:
      giả sử cây gốc chỉ có hai thư mục với
      một vfsmount::

gốc
                                   / \
                                  tmp usr

Làm cách nào để thiết lập cùng một cây ở nhiều vị trí trong
         /root/tmp

bước 2:
      ::


gắn kết --bind /root/tmp /root/tmp

gắn kết --make-rshared /root
                        mount --make-unbindable /root/tmp

mkdir -p /tmp/m1

gắn kết --rbind /root /tmp/m1

cây mới bây giờ trông như thế này::

gốc
                                   / \
                                 tmp usr
                                /
                               m1
                              / \
                             tmp usr

bước 3:
      ::

mkdir -p /tmp/m2
                            gắn kết --rbind /root /tmp/m2

cây mới bây giờ trông như thế này::

gốc
                                   / \
                                 tmp usr
                                / \
                               m1 m2
                              / \ / \
                             tmp usr tmp usr

bước 4:
      ::

mkdir -p /tmp/m3
                            gắn kết --rbind /root /tmp/m3

cây mới bây giờ trông như thế này::

gốc
                                      / \
                                     tmp usr
                                 / \ \
                               m1 m2 m3
                              / \ / \ / \
                             tmp usr tmp usr tmp usr

8) Thực hiện
-----------------

A) Cơ sở hạ tầng

Một số trường mới được giới thiệu trong struct vfsmount:

->mnt_share
           Liên kết tất cả các mount tới/từ đó vfsmount này
           gửi/nhận các sự kiện lan truyền.

->mnt_slave_list
           Liên kết tất cả các mount mà vfsmount này truyền tới
           đến.

->mnt_slave
           Liên kết tất cả các nô lệ mà chủ vfsmount của nó lại với nhau
           truyền bá tới.

->mnt_master
           Trỏ tới vfsmount chính mà từ đó vfsmount này
           nhận được sự lan truyền.

->mnt_flags
           Cần thêm hai cờ nữa để biểu thị trạng thái truyền của
           vfsmount.  MNT_SHARE chỉ ra rằng vfsmount được chia sẻ
           vfsmount.  MNT_UNCLONABLE chỉ ra rằng vfsmount không thể
           được nhân rộng.

Tất cả các vfsmount được chia sẻ trong một nhóm ngang hàng tạo thành một danh sách tuần hoàn thông qua
   ->mnt_share.

Tất cả các vfsmount có cùng dạng ->mnt_master trên danh sách tuần hoàn được neo
   trong ->mnt_master->mnt_slave_list và đi qua ->mnt_slave.

->mnt_master có thể trỏ tới các thành viên tùy ý (và có thể khác nhau)
   của nhóm ngang hàng chính.  Để tìm tất cả nô lệ trực tiếp của một nhóm ngang hàng
   bạn cần phải xem qua _all_ ->mnt_slave_list các thành viên của nó.
   Về mặt khái niệm, nó chỉ là một tập hợp duy nhất - sự phân bổ giữa các
   danh sách riêng lẻ không ảnh hưởng đến việc truyền bá hoặc cách truyền bá
   cây được sửa đổi bởi các hoạt động.

Tất cả các vfsmount trong một nhóm ngang hàng đều có cùng ->mnt_master.  Nếu nó là
   không phải NULL, chúng tạo thành một phân đoạn liền kề (có thứ tự) của danh sách nô lệ.

Một cây nhân giống ví dụ trông như trong hình bên dưới.

   .. note::
      Though it looks like a forest, if we consider all the shared
      mounts as a conceptual entity called 'pnode', it becomes a tree.

   ::


A <--> B <--> C <---> D
                       /ZZ0000ZZ |\
                      / F G J K H I
                     /
                    E<-->K
                        /|\
                       M L N

Trong hình A,B,C và D trên đều được chia sẻ và truyền bá đến từng người
   khác.   'A' có 3 thú cưỡi nô lệ 'E' 'F' và 'G' 'C' có 2 thú cưỡi nô lệ
   các ngàm 'J' và 'K' và 'D' có hai ngàm phụ 'H' và 'I'.
   'E' cũng được chia sẻ với 'K' và chúng truyền bá cho nhau.  Và
   'K' có 3 nô lệ 'M', 'L' và 'N'

->mnt_share của A liên kết với ->mnt_share của 'B' 'C' và 'D'

->mnt_slave_list của A liên kết với ->mnt_slave của 'E', 'K', 'F' và 'G'

E của ->mnt_share liên kết với ->mnt_share của K

'E', 'K', 'F', 'G' có điểm ->mnt_master của chúng để cấu trúc vfsmount của 'A'

'M', 'L', 'N' có điểm ->mnt_master của chúng để cấu trúc vfsmount của 'K'

K's ->mnt_slave_list liên kết với ->mnt_slave của 'M', 'L' và 'N'

C's ->mnt_slave_list liên kết với ->mnt_slave của 'J' và 'K'

J và K's ->mnt_master trỏ tới struct vfsmount của C

và cuối cùng là D's ->mnt_slave_list liên kết với ->mnt_slave của 'H' và 'I'

'H' và 'I' có ->mnt_master trỏ tới struct vfsmount của 'D'.


NOTE: Cây nhân giống trực giao với cây gắn kết.

B) Khóa:

->mnt_share, ->mnt_slave, ->mnt_slave_list, ->mnt_master được bảo vệ
   bởi namespace_sem (dành riêng cho sửa đổi, chia sẻ để đọc).

Thông thường chúng tôi có các sửa đổi ->mnt_flags được vfsmount_lock tuần tự hóa.
   Có hai trường hợp ngoại lệ: do_add_mount() và clone_mnt().
   Cái trước sửa đổi một vfsmount chưa được hiển thị trong bất kỳ chia sẻ nào
   cấu trúc dữ liệu chưa.
   Cái sau chứa namespace_sem và các tham chiếu duy nhất đến vfsmount
   nằm trong danh sách không thể duyệt qua nếu không có namespace_sem.

C) Thuật toán:

Mấu chốt của việc triển khai nằm trong hoạt động rbind/move.

Thuật toán tổng thể chia hoạt động thành 3 giai đoạn: (xem
   Attach_recursive_mnt() và tuyên truyền_mnt())

1. Giai đoạn chuẩn bị.

Đối với mỗi lần gắn kết trong cây nguồn:

a) Tạo số lượng cây gắn kết cần thiết để
         được gắn vào mỗi giá đỡ nhận được
         lan truyền từ mount đích.
      b) Không gắn bất kỳ cây nào vào đích của nó.
         Tuy nhiên hãy ghi lại ->mnt_parent và ->mnt_mountpoint
      c) Liên kết tất cả các giá treo mới để tạo thành cây nhân giống
         giống hệt với cây nhân giống của đích
         gắn kết.

Nếu giai đoạn này thành công thì sẽ có 'n' mới
      cây nhân giống; trong đó 'n' là số lần gắn kết trong
      cây nguồn  Chuyển đến giai đoạn cam kết

Ngoài ra nên có 'm' cây gắn kết mới, trong đó 'm' ở đâu
      số lần gắn kết mà điểm đích gắn kết vào
      truyền bá tới.

Nếu bất kỳ việc cấp phát bộ nhớ nào không thành công, hãy chuyển sang giai đoạn hủy bỏ.

2. Giai đoạn cam kết.

Gắn từng cây gắn kết vào tương ứng của chúng
      gắn kết đích.

3. Giai đoạn hủy bỏ.

Xóa tất cả các cây mới tạo.

   .. Note::
      all the propagation related functionality resides in the file pnode.c


-------------------------------------------------------------------------

phiên bản 0.1 (đã tạo tài liệu ban đầu, Ram Pai linuxram@us.ibm.com)

phiên bản 0.2 (Nhận xét tổng hợp từ Al Viro)