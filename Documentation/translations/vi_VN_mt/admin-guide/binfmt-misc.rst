.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/binfmt-misc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Hỗ trợ hạt nhân cho các định dạng nhị phân khác (binfmt_misc)
=============================================================

Tính năng Kernel này cho phép bạn gọi gần như (để biết các hạn chế, hãy xem bên dưới)
mọi chương trình chỉ bằng cách gõ tên của nó vào shell.
Điều này bao gồm các chương trình Java(TM), Python hoặc Emacs được biên dịch chẳng hạn.

Để đạt được điều này, bạn phải cho binfmt_misc biết trình thông dịch nào phải được gọi
với nhị phân nào. Binfmt_misc nhận dạng loại nhị phân bằng cách khớp một số byte
ở đầu tệp có chuỗi byte ma thuật (che giấu được chỉ định
bit) bạn đã cung cấp. Binfmt_misc cũng có thể nhận ra phần mở rộng tên tệp
còn gọi là ZZ0000ZZ hoặc ZZ0001ZZ.

Trước tiên, bạn phải gắn binfmt_misc::

gắn binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc

Để thực sự đăng ký một loại nhị phân mới, bạn phải thiết lập một chuỗi trông giống như
ZZ0000ZZ (nơi bạn có thể chọn
ZZ0001ZZ theo nhu cầu của bạn) và lặp lại nó với ZZ0002ZZ.

Đây là ý nghĩa của các trường:

-ZZ0000ZZ
   là một chuỗi định danh. Một tệp /proc mới sẽ được tạo bằng cách này
   tên bên dưới ZZ0001ZZ; không thể chứa dấu gạch chéo ZZ0002ZZ cho
   lý do rõ ràng.
-ZZ0003ZZ
   là loại công nhận. Tặng ZZ0004ZZ cho phép thuật và ZZ0005ZZ cho phần mở rộng.
-ZZ0006ZZ
   là phần bù của ma thuật/mặt nạ trong tệp, được tính bằng byte. Cái này
   mặc định là 0 nếu bạn bỏ qua nó (tức là bạn viết ZZ0007ZZ).
   Bị bỏ qua khi sử dụng phần mở rộng tên tệp phù hợp.
-ZZ0008ZZ
   là chuỗi byte binfmt_misc phù hợp. Chuỗi ma thuật
   có thể chứa các ký tự được mã hóa hex như ZZ0009ZZ hoặc ZZ0010ZZ. Lưu ý rằng bạn
   phải thoát mọi byte NUL; quá trình phân tích cú pháp dừng lại ở lần đầu tiên. Trong một cái vỏ
   môi trường bạn có thể phải viết ZZ0011ZZ để ngăn shell
   ăn ZZ0012ZZ của bạn.
   Nếu bạn chọn khớp phần mở rộng tên tệp thì đây là phần mở rộng cần được
   được công nhận (không có ZZ0013ZZ, các sản phẩm đặc biệt ZZ0014ZZ không được phép).
   Việc khớp phần mở rộng có phân biệt chữ hoa chữ thường và không được phép gạch chéo ZZ0015ZZ!
-ZZ0016ZZ
   là một mặt nạ (tùy chọn, mặc định là tất cả 0xff). Bạn có thể che giấu một số
   các bit khớp với nhau bằng cách cung cấp một chuỗi như ma thuật và dài như ma thuật.
   Mặt nạ được xác định bằng chuỗi byte của tệp. Lưu ý rằng bạn phải
   thoát mọi byte NUL; quá trình phân tích cú pháp dừng lại ở lần đầu tiên. Bỏ qua khi sử dụng
   phần mở rộng tên tập tin phù hợp.
-ZZ0017ZZ
   là chương trình nên được gọi với nhị phân đầu tiên
   đối số (chỉ định đường dẫn đầy đủ)
-ZZ0018ZZ
   là trường tùy chọn kiểm soát một số khía cạnh của lệnh gọi
   của người phiên dịch. Đó là một chuỗi các chữ in hoa, mỗi chữ điều khiển một
   khía cạnh nhất định. Các cờ sau được hỗ trợ:

ZZ0000ZZ - bảo quản-argv[0]
            Hành vi kế thừa của binfmt_misc là ghi đè
            argv[0] ban đầu với đường dẫn đầy đủ đến nhị phân. Khi điều này
            cờ được bao gồm, binfmt_misc sẽ thêm một đối số vào đối số
            vector cho mục đích này, do đó bảo tồn ZZ0001ZZ gốc.
            ví dụ. Nếu interp của bạn được đặt thành ZZ0002ZZ và bạn chạy ZZ0003ZZ
            (nằm trong ZZ0004ZZ), thì kernel sẽ thực thi
            ZZ0005ZZ với ZZ0006ZZ được đặt thành ZZ0007ZZ.  Interp phải nhận thức được điều này để có thể
            thực hiện ZZ0008ZZ
            với ZZ0009ZZ được đặt thành ZZ0010ZZ.
      ZZ0011ZZ - nhị phân mở
	    Hành vi kế thừa của binfmt_misc là chuyển toàn bộ đường dẫn
            của nhị phân tới trình thông dịch làm đối số. Khi lá cờ này được
            được bao gồm, binfmt_misc sẽ mở tệp để đọc và chuyển nó
            mô tả làm đối số, thay vì đường dẫn đầy đủ, do đó cho phép
            trình thông dịch để thực thi các nhị phân không thể đọc được. Tính năng này
            nên được sử dụng cẩn thận - thông dịch viên phải được tin cậy để không
            phát ra nội dung của tệp nhị phân không thể đọc được.
      ZZ0012ZZ - thông tin xác thực
            Hiện tại, hành vi của binfmt_misc là tính toán
            thông tin xác thực và mã thông báo bảo mật của quy trình mới theo
            người phiên dịch. Khi cờ này được đưa vào, các thuộc tính này được
            tính theo hệ nhị phân. Nó cũng ngụ ý cờ ZZ0013ZZ.
            Tính năng này nên được sử dụng cẩn thận với tư cách là thông dịch viên
            sẽ chạy với quyền root khi tệp nhị phân setuid thuộc sở hữu của root
            được chạy với binfmt_misc.
      ZZ0014ZZ - sửa lỗi nhị phân
            Hành vi thông thường của binfmt_misc là sinh ra
	    nhị phân một cách lười biếng khi tệp định dạng linh tinh được gọi.  Tuy nhiên,
	    điều này không hoạt động tốt khi đối mặt với không gian tên gắn kết và
	    thay đổi gốc, vì vậy chế độ ZZ0015ZZ sẽ mở tệp nhị phân ngay khi
	    mô phỏng được cài đặt và sử dụng hình ảnh đã mở để tạo ra
	    trình mô phỏng, nghĩa là nó luôn có sẵn sau khi được cài đặt,
	    bất chấp môi trường thay đổi như thế nào.


Có một số hạn chế:

- toàn bộ chuỗi đăng ký không được vượt quá 1920 ký tự
 - phép thuật phải nằm trong 128 byte đầu tiên của tệp, tức là.
   offset+size(magic) phải nhỏ hơn 128
 - chuỗi thông dịch không được vượt quá 127 ký tự

Để sử dụng binfmt_misc, trước tiên bạn phải gắn kết nó. Bạn có thể gắn nó với
Lệnh ZZ0000ZZ hoặc bạn có thể thêm
một dòng ZZ0001ZZ tới
ZZ0002ZZ để nó tự động gắn kết khi khởi động.

Bạn có thể muốn thêm các định dạng nhị phân vào một trong các tập lệnh ZZ0000ZZ của mình trong quá trình
khởi động. Đọc hướng dẫn sử dụng chương trình init của bạn để tìm ra cách thực hiện việc này
đúng.

Hãy suy nghĩ về thứ tự thêm các mục! Các mục được thêm sau này sẽ được khớp trước!


Một vài ví dụ (giả sử bạn đang ở ZZ0000ZZ):

- bật hỗ trợ cho em86 (như binfmt_em86, chỉ dành cho Alpha AXP)::

tiếng vọng ':i386:M::\x7fELF\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x03:\xff\ xff\xff\xff\xff\xfe\xfe\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfb\xff\xff:/bin/em86:' > đăng ký
    tiếng vọng ':i486:M::\x7fELF\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x06:\xff\ xff\xff\xff\xff\xfe\xfe\xff\xff\xff\xff\xff\xff\xff\xff\xff\xfb\xff\xff:/bin/em86:' > đăng ký

- cho phép hỗ trợ cho các ứng dụng DOS được đóng gói (hình ảnh hdmumu được cấu hình sẵn)::

echo ':DEXE:M::\x0eDEX::/usr/bin/dosexec:' > đăng ký

- bật hỗ trợ cho các tệp thực thi của Windows bằng wine::

echo ':DOSWin:M::MZ::/usr/local/bin/wine:' > đăng ký

Để được hỗ trợ java, hãy xem Tài liệu/admin-guide/java.rst


Bạn có thể bật/tắt binfmt_misc hoặc một loại nhị phân bằng cách lặp lại 0 (để tắt)
hoặc 1 (để bật) thành ZZ0000ZZ hoặc
ZZ0001ZZ.
Việc trích xuất tệp sẽ cho bạn biết trạng thái hiện tại của ZZ0002ZZ.

Bạn có thể xóa một mục hoặc tất cả các mục bằng cách lặp lại -1 đến ZZ0000ZZ
hoặc ZZ0001ZZ.


gợi ý
-----

Nếu bạn muốn truyền các đối số đặc biệt cho trình thông dịch của mình, bạn có thể
viết một kịch bản bao bọc cho nó.
Xem ZZ0000ZZ để biết ví dụ.

Thông dịch viên của bạn nên NOT tìm tên tệp trong PATH; hạt nhân
chuyển cho nó tên tệp đầy đủ (hoặc bộ mô tả tệp) để sử dụng.  Sử dụng ZZ0000ZZ có thể
gây ra hành vi không mong muốn và có thể là mối nguy hiểm về bảo mật.


Richard Günther <rguenth@tat.phyk.uni-tuebingen.de>
