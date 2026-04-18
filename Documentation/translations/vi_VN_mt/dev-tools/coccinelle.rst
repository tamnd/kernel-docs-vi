.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/dev-tools/coccinelle.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. Copyright 2010 Nicolas Palix <npalix@diku.dk>
.. Copyright 2010 Julia Lawall <julia@diku.dk>
.. Copyright 2010 Gilles Muller <Gilles.Muller@lip6.fr>

.. highlight:: none

.. _devtools_coccinelle:

coccinelle
==========

Coccinelle là một công cụ khớp mẫu và chuyển đổi văn bản có
nhiều ứng dụng trong phát triển hạt nhân, bao gồm cả ứng dụng phức tạp,
các bản vá toàn cây và phát hiện các mẫu lập trình có vấn đề.

Bắt Coccinelle
------------------

Các bản vá ngữ nghĩa có trong kernel sử dụng các tính năng và tùy chọn
được cung cấp bởi Coccinelle phiên bản 1.0.0-rc11 trở lên.
Sử dụng các phiên bản cũ hơn sẽ không thành công vì tên tùy chọn được sử dụng bởi
các tập tin Coccinelle và coccicheck đã được cập nhật.

Coccinelle có sẵn thông qua trình quản lý gói
của nhiều bản phân phối, ví dụ: :

- Debian
 - Fedora
 - Ubuntu
 - OpenSUSE
 - Arch Linux
 - Gentoo
 - NetBSD
 - FreeBSD

Một số gói phân phối đã lỗi thời và được khuyến nghị
để sử dụng phiên bản mới nhất được phát hành từ trang chủ Coccinelle tại
ZZ0000ZZ

Hoặc từ Github tại:

ZZ0000ZZ

Khi bạn đã có nó, hãy chạy các lệnh sau ::

./autogen
        ./cấu hình
        làm

với tư cách là người dùng thông thường và cài đặt nó với ::

sudo thực hiện cài đặt

Hướng dẫn cài đặt chi tiết hơn để xây dựng từ nguồn có thể
được tìm thấy tại:

ZZ0000ZZ

Tài liệu bổ sung
--------------------------

Để có tài liệu bổ sung, hãy tham khảo wiki:

ZZ0000ZZ

Tài liệu wiki luôn đề cập đến phiên bản linux-next của tập lệnh.

Để xem tài liệu ngữ pháp Ngôn ngữ bản vá ngữ nghĩa (SmPL), hãy tham khảo:

ZZ0000ZZ

Sử dụng Coccinelle trên nhân Linux
------------------------------------

Mục tiêu dành riêng cho Coccinelle được xác định ở cấp cao nhất
Makefile. Mục tiêu này được đặt tên là ZZ0000ZZ và gọi là ZZ0001ZZ
giao diện người dùng trong thư mục ZZ0002ZZ.

Bốn chế độ cơ bản được xác định: ZZ0000ZZ, ZZ0001ZZ, ZZ0002ZZ và
ZZ0003ZZ. Chế độ sử dụng được chỉ định bằng cách đặt biến MODE với
ZZ0004ZZ.

- ZZ0000ZZ đề xuất cách khắc phục khi có thể.

- ZZ0000ZZ tạo danh sách theo định dạng sau:
  tập tin: dòng: cột-cột: tin nhắn

- ZZ0000ZZ nêu bật các dòng quan tâm và bối cảnh của chúng một cách
  phong cách khác biệt. Các dòng quan tâm được biểu thị bằng ZZ0001ZZ.

- ZZ0000ZZ tạo báo cáo ở định dạng chế độ Tổ chức của Emacs.

Lưu ý rằng không phải tất cả các bản vá ngữ nghĩa đều triển khai tất cả các chế độ. Để dễ sử dụng
của Coccinelle, chế độ mặc định là "báo cáo".

Hai chế độ khác cung cấp một số kết hợp phổ biến của các chế độ này.

- ZZ0000ZZ thử các chế độ trước đó theo thứ tự trên cho đến khi thành công.

- ZZ0000ZZ chạy liên tiếp chế độ báo cáo và chế độ ngữ cảnh.
  Nó nên được sử dụng với tùy chọn C (được mô tả sau)
  kiểm tra mã trên cơ sở tập tin.

Ví dụ
~~~~~~~~

Để tạo báo cáo cho mọi bản vá ngữ nghĩa, hãy chạy lệnh sau ::

tạo coccicheck MODE=báo cáo

Để tạo các bản vá, hãy chạy::

tạo coccicheck MODE=patch


Mục tiêu coccicheck áp dụng mọi bản vá ngữ nghĩa có sẵn trong
thư mục con của ZZ0000ZZ cho toàn bộ nhân Linux.

Đối với mỗi bản vá ngữ nghĩa, một thông báo cam kết được đề xuất.  Nó mang lại một
mô tả vấn đề đang được kiểm tra bằng bản vá ngữ nghĩa và
bao gồm một tham chiếu đến Coccinelle.

Giống như bất kỳ máy phân tích mã tĩnh nào, Coccinelle tạo ra sai
tích cực. Vì vậy, các báo cáo phải được kiểm tra cẩn thận và các bản vá
được xem xét.

Để bật thông báo dài dòng, hãy đặt biến V=, ví dụ::

tạo coccicheck MODE=báo cáo V=1

Theo mặc định, coccicheck sẽ in nhật ký gỡ lỗi tới thiết bị xuất chuẩn và chuyển hướng thiết bị xuất chuẩn sang
/dev/null. Điều này có thể làm cho đầu ra coccicheck khó đọc và khó hiểu.
Thay vào đó, các thông báo gỡ lỗi và lỗi có thể được ghi vào tệp gỡ lỗi bằng cách
thiết lập biến ZZ0000ZZ::

tạo coccicheck MODE=báo cáo DEBUG_FILE="cocci.log"

Coccinelle không thể ghi đè lên tệp gỡ lỗi. Thay vì liên tục xóa nhật ký
tệp, bạn có thể bao gồm ngày giờ trong tên tệp gỡ lỗi ::

tạo coccicheck MODE=report DEBUG_FILE="cocci-$(date -Iseconds).log"

Song song hóa Coccinelle
--------------------------

Theo mặc định, coccicheck cố gắng chạy song song nhất có thể. Để thay đổi
sự song song, đặt biến J=. Ví dụ: để chạy trên 4 CPU::

tạo coccicheck MODE=báo cáo J=4

Kể từ Coccinelle 1.0.2 Coccinelle sử dụng parmap Ocaml để song song hóa;
nếu hỗ trợ cho việc này được phát hiện, bạn sẽ được hưởng lợi từ việc song song hóa parmap.

Khi parmap được bật, coccicheck sẽ bật cân bằng tải động bằng cách sử dụng
Đối số ZZ0000ZZ. Điều này đảm bảo chúng tôi tiếp tục cung cấp các luồng bằng công việc
từng cái một, để chúng ta tránh được tình trạng hầu hết công việc chỉ được thực hiện bởi
một vài chủ đề. Với cân bằng tải động, nếu một luồng kết thúc sớm, chúng tôi sẽ giữ nguyên
cho nó làm việc nhiều hơn.

Khi parmap được bật, nếu xảy ra lỗi trong Coccinelle, lỗi này
giá trị được truyền trở lại và giá trị trả về của ZZ0000ZZ
lệnh nắm bắt giá trị trả về này.

Sử dụng Coccinelle với một bản vá ngữ nghĩa duy nhất
---------------------------------------------

Biến tạo tùy chọn COCCI có thể được sử dụng để kiểm tra một
bản vá ngữ nghĩa. Trong trường hợp đó, biến phải được khởi tạo bằng
tên của bản vá ngữ nghĩa để áp dụng.

Ví dụ::

tạo coccicheck COCCI=<my_SP.cocci> MODE=patch

hoặc::

tạo coccicheck COCCI=<my_SP.cocci> MODE=báo cáo


Kiểm soát những tập tin nào được Coccinelle xử lý
---------------------------------------------------

Theo mặc định, toàn bộ cây nguồn kernel được chọn.

Để áp dụng Coccinelle cho một thư mục cụ thể, có thể sử dụng ZZ0000ZZ.
Ví dụ, để kiểm tra driver/net/wireless/ người ta có thể viết::

tạo coccicheck M=drivers/net/wireless/

Để áp dụng Coccinelle trên cơ sở tệp, thay vì trên cơ sở thư mục,
Biến C được makefile sử dụng để chọn tệp nào sẽ làm việc.
Biến này có thể được sử dụng để chạy các tập lệnh cho toàn bộ kernel, một
thư mục cụ thể hoặc cho một tập tin duy nhất.

Ví dụ: để kiểm tra trình điều khiển/bluetooth/bfusb.c, giá trị 1 là
được chuyển đến biến C để kiểm tra các tệp xem xét
cần phải được biên dịch.::

tạo C=1 CHECK=scripts/trình điều khiển coccicheck/bluetooth/bfusb.o

Giá trị 2 được truyền cho biến C để kiểm tra các tập tin bất kể
liệu chúng có cần được biên dịch hay không.::

tạo C=2 CHECK=scripts/trình điều khiển coccicheck/bluetooth/bfusb.o

Trong các chế độ này, hoạt động trên cơ sở tệp, không có thông tin
về các bản vá ngữ nghĩa được hiển thị và không có thông báo cam kết nào được đề xuất.

Điều này chạy mọi bản vá ngữ nghĩa trong scripts/coccinelle theo mặc định. các
Ngoài ra, biến COCCI có thể được sử dụng để chỉ áp dụng một
bản vá ngữ nghĩa như được trình bày trong phần trước.

Chế độ "báo cáo" là mặc định. Bạn có thể chọn một cái khác với
Biến MODE đã được giải thích ở trên.

Gỡ lỗi các bản vá Coccinelle SmPL
---------------------------------

Sử dụng coccicheck là tốt nhất vì nó cung cấp trong dòng lệnh spatch
bao gồm các tùy chọn khớp với các tùy chọn được sử dụng khi chúng tôi biên dịch kernel.
Bạn có thể tìm hiểu những tùy chọn này là gì bằng cách sử dụng V=1; lúc đó bạn có thể
chạy Coccinelle theo cách thủ công với các tùy chọn gỡ lỗi được thêm vào.

Một cách tiếp cận dễ dàng hơn để gỡ lỗi việc chạy Coccinelle dựa trên các bản vá SmPL là hỏi
coccicheck để chuyển hướng stderr sang tệp gỡ lỗi. Như đã đề cập trong các ví dụ, bởi
stderr mặc định được chuyển hướng đến/dev/null; nếu bạn muốn chụp stderr bạn
có thể chỉ định tùy chọn ZZ0000ZZ cho coccicheck. Ví dụ::

rm -f cocci.err
    tạo coccicheck COCCI=scripts/coccinelle/free/kfree.cocci MODE=báo cáo DEBUG_FILE=cocci.err
    mèo cocci.err

Bạn có thể sử dụng SPFLAGS để thêm cờ gỡ lỗi; ví dụ bạn có thể muốn
thêm cả ZZ0000ZZ vào SPFLAGS khi gỡ lỗi. Ví dụ
bạn có thể muốn sử dụng::

rm -f err.log
    xuất COCCI=scripts/coccinelle/misc/irqf_oneshot.cocci
    tạo coccicheck DEBUG_FILE="err.log" MODE=report SPFLAGS="--profile --show-trying" M=./drivers/mfd

err.log bây giờ sẽ có thông tin lược tả, trong khi thiết bị xuất chuẩn sẽ
cung cấp một số thông tin tiến độ khi Coccinelle tiến về phía trước với
làm việc.

NOTE:

Hỗ trợ DEBUG_FILE chỉ được hỗ trợ khi sử dụng coccinelle >= 1.0.2.

Hiện tại, hỗ trợ DEBUG_FILE chỉ khả dụng để kiểm tra các thư mục và
không phải tập tin đơn lẻ. Điều này là do việc kiểm tra một tập tin yêu cầu phải có lỗi
được gọi hai lần dẫn đến DEBUG_FILE được đặt cả hai lần thành cùng một giá trị,
gây ra lỗi.

hỗ trợ .cocciconfig
--------------------

Coccinelle hỗ trợ đọc .cocciconfig cho các tùy chọn Coccinelle mặc định
nên được sử dụng mỗi khi spatch được sinh ra. Thứ tự ưu tiên cho
các biến cho .cocciconfig như sau:

- Thư mục chính của người dùng hiện tại của bạn được xử lý trước tiên
- Thư mục chứa spatch được gọi sẽ được xử lý tiếp theo
- Thư mục được cung cấp với tùy chọn ZZ0000ZZ được xử lý cuối cùng, nếu được sử dụng

ZZ0000ZZ cũng hỗ trợ sử dụng mục tiêu M=. Nếu bạn không cung cấp
bất kỳ mục tiêu M= nào, giả sử bạn muốn nhắm mục tiêu toàn bộ hạt nhân.
Tập lệnh coccicheck hạt nhân có::

OPTIONS="--dir $srcroot $COCCIINCLUDE"

Ở đây, $srcroot đề cập đến thư mục nguồn của đích: nó trỏ đến
thư mục nguồn của mô-đun bên ngoài khi M= được sử dụng và nếu không thì vào kernel
thư mục nguồn. Quy tắc thứ ba đảm bảo spatch đọc .cocciconfig từ
thư mục đích, cho phép các mô-đun bên ngoài có .cocciconfig riêng
tập tin.

Nếu không sử dụng target coccicheck của kernel thì giữ nguyên quyền ưu tiên trên
logic thứ tự của việc đọc .cocciconfig. Nếu sử dụng mục tiêu coccicheck của kernel,
ghi đè bất kỳ cài đặt .coccicheck nào của kernel bằng SPFLAGS.

Chúng tôi trợ giúp Coccinelle khi được sử dụng với Linux bằng một bộ mặc định hợp lý
các tùy chọn cho Linux bằng .cocciconfig Linux của riêng chúng tôi. Điều này gợi ý đến coccinelle
git đó có thể được sử dụng cho các truy vấn ZZ0000ZZ qua coccigrep. Thời gian chờ là 200
giây là đủ cho bây giờ.

Các tùy chọn được coccinelle chọn khi đọc .cocciconfig không xuất hiện
làm đối số cho các quy trình gửi tin nhắn đang chạy trên hệ thống của bạn. Để xác nhận điều gì
các tùy chọn sẽ được sử dụng bởi Coccinelle run::

spatch --print-options-chỉ

Bạn có thể ghi đè bằng tùy chọn chỉ mục ưa thích của riêng mình bằng cách sử dụng SPFLAGS. lấy
lưu ý rằng khi có các lựa chọn xung đột, Coccinelle sẽ được ưu tiên
các lựa chọn cuối cùng đã được thông qua. Tuy nhiên, sử dụng .cocciconfig có thể sử dụng idutils
đưa ra thứ tự ưu tiên theo sau là Coccinelle, vì hạt nhân bây giờ
mang .cocciconfig riêng, bạn sẽ cần sử dụng SPFLAGS để sử dụng idutils nếu
mong muốn. Xem phần "Cờ bổ sung" bên dưới để biết thêm chi tiết về cách sử dụng
idutils.

Cờ bổ sung
----------------

Các cờ bổ sung có thể được chuyển để phân phát thông qua SPFLAGS
biến. Điều này hoạt động khi Coccinelle tôn trọng những lá cờ cuối cùng
được trao cho nó khi các lựa chọn có xung đột. ::

tạo SPFLAGS=--sử dụng coccicheck thoáng qua

Coccinelle cũng hỗ trợ idutils nhưng yêu cầu coccinelle >= 1.0.6.
Khi không có tệp ID nào được chỉ định, coccinelle sẽ giả định tệp cơ sở dữ liệu ID của bạn
nằm trong tệp .id-utils.index ở cấp cao nhất của kernel. coccinelle
mang tập lệnh scripts/idutils_index.sh để tạo cơ sở dữ liệu với ::

mkid -i C --output .id-utils.index

Nếu bạn có tên tệp cơ sở dữ liệu khác, bạn cũng có thể liên kết tượng trưng với tên này
tên. ::

tạo SPFLAGS=--use-idutils coccicheck

Ngoài ra, bạn có thể chỉ định rõ ràng tên tệp cơ sở dữ liệu, ví dụ:
ví dụ::

tạo coccicheck SPFLAGS="--use-idutils /full-path/to/ID"

Xem ZZ0000ZZ để tìm hiểu thêm về các tùy chọn spam.

Lưu ý rằng các tùy chọn ZZ0000ZZ và ZZ0001ZZ
yêu cầu các công cụ bên ngoài để lập chỉ mục mã. Không ai trong số họ là
do đó hoạt động theo mặc định. Tuy nhiên, bằng cách lập chỉ mục mã với
một trong những công cụ này, và theo tệp cocci được sử dụng,
spatch có thể tiến hành toàn bộ cơ sở mã nhanh hơn.

Tùy chọn cụ thể của bản vá SmPL
---------------------------

Các bản vá SmPL có thể có yêu cầu riêng đối với các tùy chọn được thông qua
tới Coccinelle. Các tùy chọn dành riêng cho bản vá SmPL có thể được cung cấp bởi
cung cấp chúng ở đầu bản vá SmPL, ví dụ::

// Tùy chọn: --no-includes --include-headers

Yêu cầu về bản vá SmPL của Coccinelle
----------------------------------

Khi các tính năng của Coccinelle được bổ sung thêm một số bản vá SmPL nâng cao hơn
có thể yêu cầu các phiên bản mới hơn của Coccinelle. Nếu bản vá SmPL yêu cầu
phiên bản tối thiểu của Coccinelle, điều này có thể được chỉ định như sau,
làm ví dụ nếu yêu cầu ít nhất Coccinelle >= 1.0.5::

// Yêu cầu: 1.0.5

Đề xuất các bản vá ngữ nghĩa mới
------------------------------

Các bản vá ngữ nghĩa mới có thể được đề xuất và gửi bởi kernel
nhà phát triển. Để rõ ràng, chúng nên được tổ chức theo
thư mục con của ZZ0000ZZ.


Mô tả chi tiết về chế độ ZZ0000ZZ
-------------------------------------------

ZZ0000ZZ tạo danh sách theo định dạng sau ::

tập tin: dòng: cột-cột: tin nhắn

Ví dụ
~~~~~~~

Đang chạy::

tạo coccicheck MODE=báo cáo COCCI=scripts/coccinelle/api/err_cast.cocci

sẽ thực thi phần sau của tập lệnh SmPL::

<smpl>
   @r phụ thuộc vào !context && !patch && (org || report)@
   biểu thức x;
   vị trí p;
   @@

ERR_PTR@p(PTR_ERR(x))

@script:python phụ thuộc vào report@
   p << r.p;
   x << r.x;
   @@

msg="ERR_CAST có thể được sử dụng với %s" % (x)
   coccilib.report.print_report(p[0], tin nhắn)
   </smpl>

Đoạn trích SmPL này tạo ra các mục trên đầu ra tiêu chuẩn, như
minh họa dưới đây::

/home/user/linux/crypto/ctr.c:188:9-16: ERR_CAST có thể được sử dụng với alg
    /home/user/linux/crypto/authenc.c:619:9-16: ERR_CAST có thể được sử dụng với auth
    /home/user/linux/crypto/xts.c:227:9-16: ERR_CAST có thể được sử dụng với alg


Mô tả chi tiết về chế độ ZZ0000ZZ
------------------------------------------

Khi có chế độ ZZ0000ZZ, nó sẽ đề xuất cách khắc phục cho từng vấn đề
được xác định.

Ví dụ
~~~~~~~

Đang chạy::

tạo coccicheck MODE=patch COCCI=scripts/coccinelle/api/err_cast.cocci

sẽ thực thi phần sau của tập lệnh SmPL::

<smpl>
    @ phụ thuộc vào !context && patch && !org && !report @
    biểu thức x;
    @@

-ERR_PTR(PTR_ERR(x))
    + ERR_CAST(x)
    </smpl>

Đoạn trích SmPL này tạo ra các bản vá trên đầu ra tiêu chuẩn, như
minh họa dưới đây::

khác -u -p a/crypto/ctr.c b/crypto/ctr.c
    --- a/crypto/ctr.c 2010-05-26 10:49:38.000000000 +0200
    +++ b/crypto/ctr.c 2010-06-03 23:44:49.000000000 +0200
    @@ -185,7 +185,7 @@ cấu trúc tĩnh crypto_instance *crypto_ct
 	alg = crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_CIPHER,
 				  CRYPTO_ALG_TYPE_MASK);
 	nếu (IS_ERR(alg))
    - trả về ERR_PTR(PTR_ERR(alg));
    + trả về ERR_CAST(alg);

/* Kích thước khối phải >= 4 byte. */
 	lỗi = -EINVAL;

Mô tả chi tiết về chế độ ZZ0000ZZ
--------------------------------------------

ZZ0000ZZ nêu bật các dòng quan tâm và bối cảnh của chúng
theo một phong cách khác biệt.

ZZ0002ZZ: Đầu ra giống khác biệt được tạo ra là NOT, một bản vá có thể áp dụng. các
      Mục đích của chế độ ZZ0000ZZ là làm nổi bật các dòng quan trọng
      (được chú thích bằng dấu trừ, ZZ0001ZZ) và đưa ra một số bối cảnh xung quanh
      các đường xung quanh. Đầu ra này có thể được sử dụng với chế độ khác biệt của
      Emacs để xem lại mã.

Ví dụ
~~~~~~~

Đang chạy::

tạo coccicheck MODE=context COCCI=scripts/coccinelle/api/err_cast.cocci

sẽ thực thi phần sau của tập lệnh SmPL::

<smpl>
    @ phụ thuộc vào ngữ cảnh && !patch && !org && !report@
    biểu thức x;
    @@

* ERR_PTR(PTR_ERR(x))
    </smpl>

Đoạn trích SmPL này tạo ra các khối khác biệt trên đầu ra tiêu chuẩn, như
minh họa dưới đây::

khác -u -p /home/user/linux/crypto/ctr.c /tmp/nothing
    --- /home/user/linux/crypto/ctr.c 2010-05-26 10:49:38.000000000 +0200
    +++ /tmp/không có gì
    @@ -185,7 +185,6 @@ cấu trúc tĩnh crypto_instance *crypto_ct
 	alg = crypto_attr_alg(tb[1], CRYPTO_ALG_TYPE_CIPHER,
 				  CRYPTO_ALG_TYPE_MASK);
 	nếu (IS_ERR(alg))
    - trả về ERR_PTR(PTR_ERR(alg));

/* Kích thước khối phải >= 4 byte. */
 	lỗi = -EINVAL;

Mô tả chi tiết về chế độ ZZ0000ZZ
----------------------------------------

ZZ0000ZZ tạo báo cáo ở định dạng chế độ Tổ chức của Emacs.

Ví dụ
~~~~~~~

Đang chạy::

tạo coccicheck MODE=org COCCI=scripts/coccinelle/api/err_cast.cocci

sẽ thực thi phần sau của tập lệnh SmPL::

<smpl>
    @r phụ thuộc vào !context && !patch && (org || report)@
    biểu thức x;
    vị trí p;
    @@

ERR_PTR@p(PTR_ERR(x))

@script:python phụ thuộc vào org@
    p << r.p;
    x << r.x;
    @@

msg="ERR_CAST có thể được sử dụng với %s" % (x)
    msg_safe=msg.replace("[","@(").replace("]",")")
    coccilib.org.print_todo(p[0], msg_safe)
    </smpl>

Đoạn trích SmPL này tạo ra các mục Org trên đầu ra tiêu chuẩn, như
minh họa dưới đây::

* TODO [[view:/home/user/linux/crypto/ctr.c::face=ovl-face1::linb=188::colb=9::cole=16][ERR_CAST có thể được sử dụng với alg]]
    * TODO [[view:/home/user/linux/crypto/authenc.c::face=ovl-face1::linb=619::colb=9::cole=16][ERR_CAST có thể được sử dụng với auth]]
    * TODO [[view:/home/user/linux/crypto/xts.c::face=ovl-face1::linb=227::colb=9::cole=16][ERR_CAST có thể được sử dụng với alg]]
