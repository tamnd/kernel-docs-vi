.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-pgp-guide.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _pgpguide:

==============================
Hướng dẫn bảo trì hạt nhân PGP
==============================

:Tác giả: Konstantin Ryabitsev <konstantin@linuxfoundation.org>

Tài liệu này nhằm vào các nhà phát triển nhân Linux, và đặc biệt là
người bảo trì hệ thống con. Nó chứa một tập hợp con thông tin được thảo luận trong
hướng dẫn "ZZ0000ZZ" tổng quát hơn được xuất bản bởi
Nền tảng Linux. Vui lòng đọc tài liệu đó để thảo luận sâu hơn
về một số chủ đề được đề cập trong hướng dẫn này.

.. _`Protecting Code Integrity`: https://github.com/lfit/itpol/blob/master/protecting-code-integrity.md

Vai trò của PGP trong phát triển hạt nhân Linux
===========================================

PGP giúp đảm bảo tính toàn vẹn của mã do Linux tạo ra
cộng đồng phát triển hạt nhân và, ở mức độ thấp hơn, thiết lập sự tin cậy
kênh liên lạc giữa các nhà phát triển thông qua trao đổi email có chữ ký PGP.

Mã nguồn nhân Linux có sẵn ở hai định dạng chính:

- Kho nguồn phân tán (git)
- Ảnh chụp nhanh phát hành định kỳ (tarball)

Cả kho git và tarball đều mang chữ ký PGP của kernel
các nhà phát triển tạo ra các bản phát hành kernel chính thức. Những chữ ký này cung cấp một
đảm bảo bằng mật mã rằng các phiên bản có thể tải xuống được cung cấp thông qua
kernel.org hoặc bất kỳ máy nhân bản nào khác giống hệt với những gì các nhà phát triển này
có trên máy trạm của họ. Để kết thúc này:

- kho git cung cấp chữ ký PGP trên tất cả các thẻ
- tarball cung cấp chữ ký PGP riêng biệt với tất cả các lượt tải xuống

.. _devs_not_infra:

Tin tưởng các nhà phát triển chứ không phải cơ sở hạ tầng
-------------------------------------------

Kể từ sự xâm phạm của các hệ thống kernel.org lõi vào năm 2011, lỗi chính
nguyên tắc hoạt động của dự án Kernel Archives đã được thừa nhận
rằng bất kỳ phần nào của cơ sở hạ tầng đều có thể bị xâm phạm bất cứ lúc nào. cho
lý do này, các quản trị viên đã thực hiện các bước có chủ ý để nhấn mạnh
niềm tin đó phải luôn được đặt vào các nhà phát triển chứ không bao giờ đặt vào mã
cơ sở hạ tầng lưu trữ, bất kể thực tiễn bảo mật tốt như thế nào
vì cái sau có thể là như vậy.

Nguyên tắc hướng dẫn trên là lý do tại sao cần có hướng dẫn này. Chúng tôi
muốn đảm bảo rằng bằng cách đặt niềm tin vào các nhà phát triển, chúng tôi không chỉ
chuyển trách nhiệm về các sự cố bảo mật tiềm ẩn trong tương lai sang người khác.
Mục tiêu là cung cấp một bộ hướng dẫn mà nhà phát triển có thể sử dụng để tạo
một môi trường làm việc an toàn và bảo vệ các khóa PGP được sử dụng để
thiết lập tính toàn vẹn của chính nhân Linux.

.. _pgp_tools:

Dụng cụ PGP
=========

Sử dụng GnuPG 2.4 trở lên
----------------------

Bản phân phối của bạn phải được cài đặt sẵn GnuPG theo mặc định, bạn chỉ cần
cần xác minh rằng bạn đang sử dụng phiên bản hợp lý gần đây của nó.
Để kiểm tra, hãy chạy::

$ gpg --version | đầu -n1

Nếu bạn có phiên bản 2.4 trở lên thì bạn có thể sử dụng. Nếu bạn có
phiên bản cũ hơn thì bạn đang sử dụng bản phát hành GnuPG không có
được duy trì lâu hơn và một số lệnh từ hướng dẫn này có thể không hoạt động.

Định cấu hình tùy chọn tác nhân gpg
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tác nhân GnuPG là một công cụ trợ giúp sẽ tự động khởi động bất cứ khi nào
bạn sử dụng lệnh ZZ0000ZZ và chạy ở chế độ nền với mục đích
lưu trữ cụm mật khẩu khóa riêng. Có hai lựa chọn bạn nên
biết để điều chỉnh khi cụm mật khẩu hết hạn khỏi bộ đệm:

- ZZ0000ZZ (giây): Nếu bạn sử dụng lại phím đó trước đó
  hết thời gian tồn tại, việc đếm ngược sẽ được đặt lại cho một khoảng thời gian khác.
  Mặc định là 600 (10 phút).
- ZZ0001ZZ (giây): Bất kể bạn đã sử dụng gần đây như thế nào
  khóa kể từ mục nhập cụm mật khẩu ban đầu, nếu thời gian tồn tại tối đa
  Hết thời gian đếm ngược, bạn sẽ phải nhập lại cụm mật khẩu. các
  mặc định là 30 phút.

Nếu bạn thấy một trong hai giá trị mặc định này quá ngắn (hoặc quá dài), bạn có thể
chỉnh sửa tệp ZZ0000ZZ của bạn để đặt các giá trị của riêng bạn ::

# set đến 30 phút đối với ttl thông thường và 2 giờ đối với ttl tối đa
    mặc định-cache-ttl 1800
    max-cache-ttl 7200

.. note::

    It is no longer necessary to start gpg-agent manually at the
    beginning of your shell session. You may want to check your rc files
    to remove anything you had in place for older versions of GnuPG, as
    it may not be doing the right thing any more.

.. _protect_your_key:

Bảo vệ khóa PGP của bạn
====================

Hướng dẫn này giả định rằng bạn đã có khóa PGP mà bạn sử dụng cho Linux
mục đích phát triển hạt nhân. Nếu bạn chưa có, vui lòng xem
Tài liệu "ZZ0000ZZ" được đề cập trước đó để được hướng dẫn
về cách tạo một cái mới.

Bạn cũng nên tạo khóa mới nếu khóa hiện tại của bạn yếu hơn 2048
bit (RSA).

Tìm hiểu về khóa con PGP
-------------------------

Khóa PGP hiếm khi bao gồm một cặp khóa duy nhất -- thông thường nó là một
tập hợp các khóa con độc lập có thể được sử dụng cho các mục đích khác nhau
mục đích dựa trên khả năng của họ, được giao tại thời điểm tạo ra chúng.
PGP xác định bốn khả năng mà một khóa có thể có:

- Có thể sử dụng phím ZZ0000ZZ để ký
- Khóa ZZ0001ZZ có thể được sử dụng để mã hóa
- Khóa ZZ0002ZZ có thể được sử dụng để xác thực
- Phím ZZ0003ZZ có thể được sử dụng để xác nhận các phím khác

Chìa khóa có khả năng ZZ0000ZZ thường được gọi là chìa khóa "chính",
nhưng thuật ngữ này gây hiểu lầm vì nó ngụ ý rằng Chứng nhận
khóa có thể được sử dụng thay cho bất kỳ khóa con nào khác trên cùng một chuỗi (như
một "chìa khóa chính" vật lý có thể được sử dụng để mở các ổ khóa được tạo cho các chìa khóa khác).
Vì đây không phải là trường hợp nên hướng dẫn này sẽ gọi nó là "Giấy chứng nhận
key" để tránh mọi sự mơ hồ.

Điều quan trọng là phải hiểu đầy đủ những điều sau đây:

1. Tất cả các khóa con hoàn toàn độc lập với nhau. Nếu bạn mất một
   khóa con riêng tư, nó không thể được khôi phục hoặc tạo lại từ bất kỳ khóa con nào khác.
   khóa riêng trên chuỗi của bạn.
2. Ngoại trừ khóa Chứng nhận, có thể có nhiều khóa con
   có khả năng giống hệt nhau (ví dụ: bạn có thể có 2 mã hóa hợp lệ
   khóa con, 3 khóa con ký hợp lệ, nhưng chỉ có một chứng nhận hợp lệ
   khóa con). Tất cả các khóa con đều hoàn toàn độc lập -- một tin nhắn được mã hóa tới
   một khóa con ZZ0000ZZ không thể được giải mã bằng bất kỳ khóa con ZZ0001ZZ nào khác
   bạn cũng có thể có.
3. Một khóa con có thể có nhiều khả năng (ví dụ: khóa ZZ0002ZZ của bạn
   cũng có thể là khóa ZZ0003ZZ của bạn).

Chìa khóa mang khả năng ZZ0000ZZ (chứng nhận) là chìa khóa duy nhất
có thể được sử dụng để biểu thị mối quan hệ với các khóa khác. Chỉ có ZZ0001ZZ
khóa có thể được sử dụng để:

- thêm hoặc thu hồi các khóa (khóa con) khác có khả năng S/E/A
- thêm, thay đổi hoặc thu hồi danh tính (uids) được liên kết với khóa
- thêm hoặc thay đổi ngày hết hạn của chính nó hoặc bất kỳ khóa con nào
- ký chìa khóa của người khác cho mục đích tin cậy trên web

Theo mặc định, GnuPG tạo thông tin sau khi tạo khóa mới:

- Một khóa con mang cả khả năng Chứng nhận và Ký (ZZ0000ZZ)
- Một khóa con riêng biệt có khả năng Mã hóa (ZZ0001ZZ)

Nếu bạn đã sử dụng các tham số mặc định khi tạo khóa của mình thì điều đó
là những gì bạn sẽ có. Bạn có thể xác minh bằng cách chạy ZZ0000ZZ,
ví dụ::

giây ed25519 2022-12-20 [SC] [hết hạn: 2024-12-19]
          000000000000000000000000AAAABBBBCCCCDDDD
    uid [cuối cùng] Alice Dev <adev@kernel.org>
    ssb cv25519 2022-12-20 [E] [hết hạn: 19-12-2024]

Dòng dài bên dưới mục nhập ZZ0000ZZ là dấu vân tay chìa khóa của bạn --
bất cứ khi nào bạn nhìn thấy ZZ0001ZZ trong các ví dụ bên dưới, 40 ký tự đó
chuỗi là những gì nó đề cập đến.

Đảm bảo cụm mật khẩu của bạn mạnh
--------------------------------

GnuPG sử dụng cụm mật khẩu để mã hóa khóa riêng của bạn trước khi lưu trữ chúng trên
đĩa. Bằng cách này, ngay cả khi thư mục ZZ0000ZZ của bạn bị rò rỉ hoặc bị đánh cắp trong
toàn bộ, những kẻ tấn công không thể sử dụng khóa riêng của bạn mà không có
lấy cụm mật khẩu để giải mã chúng.

Điều thực sự cần thiết là khóa riêng của bạn được bảo vệ bởi một
cụm mật khẩu mạnh. Để đặt hoặc thay đổi nó, hãy sử dụng::

$ gpg --change-passphrase [fpr]

Tạo một khóa con Ký riêng
--------------------------------

Mục tiêu của chúng tôi là bảo vệ khóa Chứng nhận của bạn bằng cách chuyển nó sang phương tiện ngoại tuyến,
vì vậy nếu bạn chỉ có khóa ZZ0000ZZ kết hợp thì bạn nên tạo một khóa
khóa con ký riêng::

$ gpg --quick-addkey [fpr] ed25519 ký

Sao lưu khóa Chứng nhận của bạn để khắc phục thảm họa
----------------------------------------------

Bạn càng có nhiều chữ ký trên khóa PGP của mình từ các nhà phát triển khác thì
có nhiều lý do hơn khiến bạn phải tạo một phiên bản sao lưu tồn tại trên một thứ gì đó
ngoài phương tiện kỹ thuật số, vì lý do khắc phục thảm họa.

Một cách tốt để tạo một bản cứng có thể in được của khóa riêng của bạn là
sử dụng phần mềm ZZ0000ZZ được viết cho mục đích này. Xem ZZ0001ZZ để biết thêm chi tiết về định dạng đầu ra và lợi ích của nó đối với
các giải pháp khác. Hầu hết các Paperkey đều đã được đóng gói sẵn
phân phối.

Chạy lệnh sau để tạo bản sao lưu bản cứng của dữ liệu riêng tư của bạn
chìa khóa::

$ gpg --export-secret-key [fpr] | khóa giấy -o /tmp/key-backup.txt

In tập tin đó ra, sau đó lấy bút và viết cụm mật khẩu của bạn lên
lề của tờ giấy. ZZ0000ZZ vì chìa khóa
bản in vẫn được mã hóa bằng cụm mật khẩu đó và nếu bạn thay đổi
bạn sẽ không nhớ nó đã từng như thế nào khi bạn tạo ra
sao lưu -- ZZ0001ZZ.

Đặt bản in thu được và cụm mật khẩu viết tay vào một phong bì
và lưu trữ ở một nơi an toàn và được bảo vệ tốt, tốt nhất là tránh xa
nhà, chẳng hạn như kho tiền ngân hàng của bạn.

.. note::

    The key is still encrypted with your passphrase, so printing out
    even to "cloud-integrated" modern printers should remain a
    relatively safe operation.

Sao lưu toàn bộ thư mục GnuPG của bạn
----------------------------------

.. warning::

    **!!!Do not skip this step!!!**

Điều quan trọng là phải có sẵn bản sao lưu các khóa PGP của bạn
nếu bạn cần khôi phục chúng. Điều này khác với
sự chuẩn bị ở cấp độ thảm họa mà chúng tôi đã thực hiện với ZZ0000ZZ. Bạn cũng sẽ dựa vào
trên các bản sao bên ngoài này bất cứ khi nào bạn cần sử dụng khóa Chứng nhận của mình --
chẳng hạn như khi thực hiện các thay đổi đối với khóa của chính bạn hoặc ký vào khóa của người khác
chìa khóa sau các hội nghị và hội nghị thượng đỉnh.

Bắt đầu bằng cách lấy một thẻ nhớ ngoài (tốt nhất là hai!) mà bạn sẽ
sử dụng cho mục đích sao lưu. Bạn sẽ cần tạo một phân vùng được mã hóa
trên thiết bị này bằng LUKS -- hãy tham khảo tài liệu của bản phân phối của bạn về cách
để thực hiện điều này.

Đối với cụm mật khẩu mã hóa, bạn có thể sử dụng cụm mật khẩu giống như trên
Phím PGP.

Khi quá trình mã hóa kết thúc, hãy lắp lại thiết bị của bạn và đảm bảo
nó được gắn đúng cách. Sao chép toàn bộ thư mục ZZ0000ZZ của bạn sang
bộ nhớ được mã hóa::

$ cp -a ~/.gnupg /media/disk/foo/gnupg-backup

Bây giờ bạn nên kiểm tra để đảm bảo mọi thứ vẫn hoạt động::

$ gpg --homedir=/media/disk/foo/gnupg-backup --list-key [fpr]

Nếu bạn không gặp bất kỳ lỗi nào thì bạn nên tiếp tục. Ngắt kết nối
thiết bị, hãy dán nhãn rõ ràng để bạn không vô tình ghi đè lên nó và
đặt ở một nơi an toàn -- nhưng không quá xa, vì bạn sẽ cần sử dụng
thỉnh thoảng nó dành cho những việc như chỉnh sửa danh tính, thêm hoặc
thu hồi khóa con hoặc ký khóa của người khác.

Xóa khóa Chứng nhận khỏi homedir của bạn
----------------------------------------

Các tập tin trong thư mục chính của chúng tôi không được bảo vệ tốt như chúng tôi mong muốn
nghĩ.  Chúng có thể bị rò rỉ hoặc đánh cắp bằng nhiều cách khác nhau:

- vô tình khi tạo bản sao homedir nhanh để thiết lập máy trạm mới
- do sơ suất hoặc ác ý của quản trị viên hệ thống
- thông qua các bản sao lưu được bảo mật kém
- thông qua phần mềm độc hại trong ứng dụng dành cho máy tính để bàn (trình duyệt, trình xem pdf, v.v.)
- thông qua sự ép buộc khi vượt qua biên giới quốc tế

Bảo vệ khóa của bạn bằng cụm mật khẩu tốt giúp giảm thiểu rủi ro rất nhiều
bất kỳ điều nào ở trên, nhưng cụm mật khẩu có thể được phát hiện thông qua keylogger,
lướt vai hoặc bất kỳ phương tiện nào khác. Vì lý do này,
thiết lập được đề xuất là xóa khóa Chứng nhận khỏi thư mục chính của bạn
và lưu trữ nó trên bộ nhớ ngoại tuyến.

.. warning::

    Please see the previous section and make sure you have backed up
    your GnuPG directory in its entirety. What we are about to do will
    render your key useless if you do not have a usable backup!

Trước tiên, hãy xác định "tay nắm phím" của khóa Chứng nhận của bạn::

$ gpg --with-keygrip --list-key [fpr]

Đầu ra sẽ giống như thế này ::

pub ed25519 2022-12-20 [SC] [hết hạn: 19-12-2022]
          000000000000000000000000AAAABBBBCCCCDDDD
          Báng phím = 1111000000000000000000000000000000000000000
    uid [cuối cùng] Alice Dev <adev@kernel.org>
    sub cv25519 2022-12-20 [E] [hết hạn: 2022-12-19]
          Báng phím = 2222000000000000000000000000000000000000000
    phụ ed25519 2022-12-20 [S]
          Báng phím = 3333000000000000000000000000000000000000000

Tìm mục nhập keygrip bên dưới dòng ZZ0000ZZ (ngay dưới dòng
Xác nhận dấu vân tay của chìa khóa). Điều này sẽ tương ứng trực tiếp với một tập tin trong
Thư mục ZZ0001ZZ::

$ cd ~/.gnupg/private-keys-v1.d
    $ ls
    111100000000000000000000000000000000000000.key
    222200000000000000000000000000000000000000.key
    333300000000000000000000000000000000000000.key

Chỉ cần xóa tệp .key tương ứng với Chứng nhận là đủ
tay cầm phím::

$ cd ~/.gnupg/private-keys-v1.d
    $ rm 1111000000000000000000000000000000000000000.key

Bây giờ, nếu bạn đưa ra lệnh ZZ0000ZZ, nó sẽ hiển thị rằng
khóa Chứng nhận bị thiếu (ZZ0001ZZ cho biết nó không có sẵn)::

$ gpg --list-secret-key
    sec#  ed25519 2022-12-20 [SC] [hết hạn: 2024-12-19]
          000000000000000000000000AAAABBBBCCCCDDDD
    uid [cuối cùng] Alice Dev <adev@kernel.org>
    ssb cv25519 2022-12-20 [E] [hết hạn: 19-12-2024]
    ssb ed25519 2022-12-20 [S]

Bạn cũng nên xóa mọi tệp ZZ0000ZZ trong ZZ0001ZZ
thư mục có thể còn sót lại từ các phiên bản trước của GnuPG.

Nếu bạn không có thư mục "private-keys-v1.d"
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn không có thư mục ZZ0000ZZ thì
khóa bí mật vẫn được lưu trữ trong tệp ZZ0001ZZ cũ được sử dụng bởi
GnuPG v1. Thực hiện bất kỳ thay đổi nào đối với khóa của bạn, chẳng hạn như thay đổi
cụm mật khẩu hoặc thêm khóa con, sẽ tự động chuyển đổi cụm mật khẩu cũ
Định dạng ZZ0002ZZ để sử dụng ZZ0003ZZ thay thế.

Khi bạn hoàn thành việc đó, hãy đảm bảo xóa ZZ0000ZZ lỗi thời
tệp vẫn chứa khóa riêng của bạn.

.. _smartcards:

Di chuyển các khóa con sang một thiết bị mật mã chuyên dụng
=============================================

Mặc dù khóa Chứng nhận hiện đã an toàn không bị rò rỉ hoặc bị đánh cắp,
các khóa con vẫn còn trong thư mục chính của bạn. Bất cứ ai quản lý để có được
bàn tay của họ sẽ có thể giải mã thông tin liên lạc của bạn hoặc giả mạo
chữ ký của bạn (nếu họ biết cụm mật khẩu). Hơn nữa, mỗi lần một
Hoạt động GnuPG được thực hiện, các phím được tải vào bộ nhớ hệ thống và
có thể bị đánh cắp từ đó bởi phần mềm độc hại đủ tiên tiến (hãy nghĩ
Meltdown và Spectre).

Một cách tốt để bảo vệ hoàn toàn chìa khóa của bạn là di chuyển chúng đến một nơi
thiết bị phần cứng chuyên dụng có khả năng hoạt động thẻ thông minh.

Lợi ích của thẻ thông minh
--------------------------

Thẻ thông minh chứa một chip mật mã có khả năng lưu trữ
khóa riêng và thực hiện các hoạt động mã hóa trực tiếp trên thẻ
chính nó. Vì nội dung chính không bao giờ rời khỏi thẻ thông minh nên
hệ điều hành của máy tính mà bạn cắm phần cứng vào
thiết bị không thể tự lấy khóa riêng. Điều này rất
khác với thiết bị lưu trữ phương tiện được mã hóa mà chúng tôi đã sử dụng trước đó
mục đích sao lưu -- trong khi thiết bị đó được cắm và lắp,
hệ điều hành có thể truy cập nội dung khóa riêng.

Việc sử dụng phương tiện được mã hóa bên ngoài không thể thay thế cho việc có một
thiết bị có khả năng thẻ thông minh.

Các thiết bị thẻ thông minh hiện có
---------------------------

Trừ khi tất cả máy tính xách tay và máy trạm của bạn đều có đầu đọc thẻ thông minh,
dễ nhất là mua một thiết bị USB chuyên dụng thực hiện thẻ thông minh
chức năng. Có một số tùy chọn có sẵn:

- ZZ0000ZZ: Phần cứng mở và Phần mềm miễn phí, dựa trên FSI
  ZZ0001ZZ của Nhật Bản. Một trong những lựa chọn rẻ nhất nhưng cung cấp ít nhất
  các tính năng bảo mật (chẳng hạn như khả năng chống giả mạo hoặc một số
  tấn công kênh bên).
- ZZ0002ZZ: Tương tự như Nitrokey Start nhưng hơn thế nữa
  chống giả mạo và cung cấp nhiều tính năng bảo mật hơn và USB
  yếu tố hình thức. Hỗ trợ mật mã ECC (ED25519 và NISTP).
- ZZ0003ZZ: phần cứng và phần mềm độc quyền nhưng rẻ hơn
  Nitrokey với bộ tính năng tương tự. Hỗ trợ mật mã ECC
  (ED25519 và NISTP).

Sự lựa chọn của bạn sẽ phụ thuộc vào chi phí, khả năng vận chuyển trong
khu vực địa lý và các cân nhắc về phần cứng mở/độc quyền.

.. note::

    If you are listed in an `M:` entry in MAINTAINERS or have an account at
    kernel.org, you `qualify for a free Nitrokey Start`_ courtesy of The Linux
    Foundation.

.. _`Nitrokey Start`: https://www.nitrokey.com/products/nitrokeys
.. _`Nitrokey 3`: https://www.nitrokey.com/products/nitrokeys
.. _`Yubikey 5`: https://www.yubico.com/products/yubikey-5-overview/
.. _Gnuk: https://www.fsij.org/doc-gnuk/
.. _`qualify for a free Nitrokey Start`: https://www.kernel.org/nitrokey-digital-tokens-for-kernel-developers.html

Cấu hình thiết bị thẻ thông minh của bạn
-------------------------------

Thiết bị thẻ thông minh của bạn sẽ hoạt động (TM) ngay khi bạn cắm nó vào
bất kỳ máy trạm Linux hiện đại nào. Bạn có thể xác minh nó bằng cách chạy::

$ gpg --trạng thái thẻ

Nếu bạn thấy thông tin chi tiết đầy đủ về thẻ thông minh thì bạn đã sẵn sàng.
Thật không may, việc khắc phục tất cả các lý do có thể khiến mọi thứ có thể không xảy ra
làm việc cho bạn nằm ngoài phạm vi của hướng dẫn này. Nếu bạn là
gặp sự cố khi thẻ hoạt động với GnuPG, vui lòng tìm kiếm trợ giúp qua
các kênh hỗ trợ thông thường.

Để định cấu hình thẻ thông minh của bạn, bạn sẽ cần sử dụng hệ thống menu GnuPG, như
không có công tắc dòng lệnh thuận tiện nào::

$ gpg --card-chỉnh sửa
    [...bỏ qua...]
    gpg/thẻ> quản trị viên
    Lệnh quản trị được cho phép
    gpg/thẻ> mật khẩu

Bạn nên đặt người dùng PIN (1), Quản trị viên PIN (3) và Mã đặt lại (4).
Hãy đảm bảo ghi lại và lưu trữ những thông tin này ở nơi an toàn -- đặc biệt
Quản trị PIN và Mã đặt lại (cho phép bạn xóa hoàn toàn
thẻ thông minh). Bạn hiếm khi cần sử dụng Quản trị viên PIN nên bạn sẽ
chắc chắn sẽ quên nó là gì nếu bạn không ghi lại nó.

Quay lại menu thẻ chính, bạn cũng có thể đặt các giá trị khác (chẳng hạn như
như tên, giới tính, dữ liệu đăng nhập, v.v.), nhưng điều đó không cần thiết và sẽ
Ngoài ra còn có thông tin rò rỉ về thẻ thông minh của bạn nếu bạn đánh mất nó.

.. note::

    Despite having the name "PIN", neither the user PIN nor the admin
    PIN on the card need to be numbers.

.. warning::

    Some devices may require that you move the subkeys onto the device
    before you can change the passphrase. Please check the documentation
    provided by the device manufacturer.

Di chuyển các khóa con vào thẻ thông minh của bạn
----------------------------------

Thoát khỏi menu thẻ (sử dụng "q") và lưu tất cả các thay đổi. Tiếp theo, hãy di chuyển
khóa con của bạn vào thẻ thông minh. Bạn sẽ cần cả khóa PGP của mình
cụm mật khẩu và quản trị viên PIN của thẻ cho hầu hết các hoạt động::

$ gpg --edit-key [fpr]

Các khóa con bí mật có sẵn.

quán rượu ed25519/AAAABBBBCCCCDDDD
         đã tạo: 2022-12-20 hết hạn: 2024-12-19 sử dụng: SC
         niềm tin: giá trị tối thượng: tối thượng
    ssb cv25519/1111222233334444
         đã tạo: 2022-12-20 hết hạn: không bao giờ sử dụng: E
    ssb ed25519/5555666677778888
         đã tạo: 2017-12-07 hết hạn: không bao giờ sử dụng: S
    [cuối cùng] (1). Alice Dev <adev@kernel.org>

gpg>

Việc sử dụng ZZ0000ZZ sẽ đưa chúng ta trở lại chế độ menu và bạn sẽ
lưu ý rằng danh sách chính có một chút khác biệt. Từ đây trở đi, tất cả
các lệnh được thực hiện từ bên trong chế độ menu này, như được chỉ ra bởi ZZ0001ZZ.

Trước tiên, hãy chọn chìa khóa mà chúng ta sẽ đặt vào thẻ -- bạn làm như vậy
điều này bằng cách gõ ZZ0000ZZ (đây là cái đầu tiên trong danh sách, ZZ0001ZZ
khóa con)::

gpg> phím 1

Ở đầu ra, bây giờ bạn sẽ thấy ZZ0000ZZ trên phím ZZ0004ZZ. ZZ0001ZZ
cho biết khóa nào hiện đang được "chọn". Nó hoạt động như một ZZ0005ZZ,
nghĩa là nếu bạn gõ lại ZZ0002ZZ, ZZ0003ZZ sẽ biến mất và
chìa khóa sẽ không được chọn nữa.

Bây giờ, hãy di chuyển chìa khóa đó vào thẻ thông minh::

gpg> thẻ khóa
    Vui lòng chọn nơi lưu trữ chìa khóa:
       (2) Khóa mã hóa
    Lựa chọn của bạn? 2

Vì đó là khóa ZZ0000ZZ của chúng tôi nên việc đưa nó vào Mã hóa là điều hợp lý
khe cắm.  Khi bạn gửi lựa chọn của mình, trước tiên bạn sẽ được nhắc về
cụm mật khẩu khóa PGP của bạn và sau đó dành cho quản trị viên PIN. Nếu lệnh
trả về không có lỗi, khóa của bạn đã được di chuyển.

ZZ0002ZZ: Bây giờ gõ lại ZZ0000ZZ để bỏ chọn phím đầu tiên và
ZZ0001ZZ để chọn phím ZZ0003ZZ::

gpg> phím 1
    gpg> phím 2
    gpg> thẻ khóa
    Vui lòng chọn nơi lưu trữ chìa khóa:
       (1) Phím chữ ký
       (3) Khóa xác thực
    Lựa chọn của bạn? 1

Bạn có thể sử dụng khóa ZZ0000ZZ cho cả Chữ ký và Xác thực, nhưng
chúng tôi muốn đảm bảo nó nằm trong ô Chữ ký, vì vậy hãy chọn (1). Một lần
một lần nữa, nếu lệnh của bạn trả về không có lỗi thì thao tác đó đã được thực hiện
thành công::

gpg> q
    Lưu thay đổi? (có/không) có

Việc lưu các thay đổi sẽ xóa các khóa bạn đã di chuyển vào thẻ khỏi
thư mục chính (nhưng không sao, vì chúng tôi có chúng trong bản sao lưu của mình
nếu chúng tôi cần thực hiện lại việc này đối với thẻ thông minh thay thế).

Xác minh rằng các phím đã được di chuyển
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn thực hiện ZZ0000ZZ bây giờ, bạn sẽ thấy một biểu tượng tinh tế
sự khác biệt trong đầu ra::

$ gpg --list-secret-key
    sec#  ed25519 2022-12-20 [SC] [hết hạn: 2024-12-19]
          000000000000000000000000AAAABBBBCCCCDDDD
    uid [cuối cùng] Alice Dev <adev@kernel.org>
    ssb> cv25519 2022-12-20 [E] [hết hạn: 2024-12-19]
    ssb> ed25519 2022-12-20 [S]

ZZ0000ZZ trong đầu ra ZZ0001ZZ chỉ ra rằng khóa con chỉ
sẵn có trên thẻ thông minh. Nếu bạn quay lại với chìa khóa bí mật của mình
thư mục và nhìn vào nội dung ở đó, bạn sẽ nhận thấy rằng
Các tệp ZZ0002ZZ đã được thay thế bằng các tệp sơ khai::

$ cd ~/.gnupg/private-keys-v1.d
    $ chuỗi *.key | grep 'khóa riêng'

Đầu ra phải chứa ZZ0000ZZ để chỉ ra rằng
những tập tin này chỉ là sơ khai và nội dung thực tế nằm trên thẻ thông minh.

Xác minh rằng thẻ thông minh đang hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Để xác minh rằng thẻ thông minh đang hoạt động như dự kiến, bạn có thể tạo một
chữ ký::

$ echo "Xin chào thế giới" | gpg --clearsign > /tmp/test.asc
    $ gpg --verify /tmp/test.asc

Điều này sẽ yêu cầu thẻ thông minh PIN của bạn trong lệnh đầu tiên, sau đó
hiển thị "Chữ ký tốt" sau khi bạn chạy ZZ0000ZZ.

Xin chúc mừng, bạn đã thành công trong việc vượt qua khó khăn
đánh cắp danh tính nhà phát triển kỹ thuật số của bạn!

Các hoạt động GnuPG phổ biến khác
-----------------------------

Đây là tài liệu tham khảo nhanh về một số thao tác phổ biến mà bạn cần thực hiện
bằng khóa PGP của bạn.

Gắn bộ nhớ ngoại tuyến an toàn của bạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn sẽ cần khóa Chứng nhận cho bất kỳ thao tác nào dưới đây, vì vậy bạn
trước tiên sẽ cần gắn bộ lưu trữ ngoại tuyến dự phòng của bạn và yêu cầu GnuPG
sử dụng nó::

$ xuất GNUPGHOME=/media/disk/foo/gnupg-backup
    $ gpg --list-secret-key

Bạn muốn đảm bảo rằng bạn nhìn thấy ZZ0000ZZ chứ không phải ZZ0001ZZ trong
đầu ra (ZZ0002ZZ có nghĩa là khóa không có sẵn và bạn vẫn đang sử dụng
vị trí thư mục chính thông thường của bạn).

Gia hạn ngày hết hạn khóa
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khóa Chứng nhận có ngày hết hạn mặc định là 2 năm kể từ ngày
của sự sáng tạo. Điều này được thực hiện vì lý do bảo mật và làm cho nó trở nên lỗi thời
các khóa cuối cùng sẽ biến mất khỏi máy chủ khóa.

Để gia hạn thời hạn sử dụng khóa của bạn thêm một năm kể từ ngày hiện tại, chỉ cần
chạy::

$ gpg --quick-set-hết hạn [fpr] 1y

Bạn cũng có thể sử dụng một ngày cụ thể nếu điều đó dễ nhớ hơn (ví dụ:
sinh nhật của bạn, ngày 1 tháng 1 hoặc Ngày Canada)::

$ gpg --quick-set-hết hạn [fpr] 2038-07-01

Hãy nhớ gửi lại khóa đã cập nhật cho máy chủ khóa::

$ gpg --send-key [fpr]

Cập nhật thư mục công việc của bạn sau bất kỳ thay đổi nào
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Sau khi thực hiện bất kỳ thay đổi nào đối với khóa của mình bằng bộ nhớ ngoại tuyến, bạn sẽ
muốn nhập lại những thay đổi này vào thư mục làm việc thông thường của bạn::

$gpg --xuất khẩu | gpg --homedir ~/.gnupg --import
    $ chưa đặt GNUPGHOME

Sử dụng tác nhân gpg qua ssh
~~~~~~~~~~~~~~~~~~~~~~~~

Bạn có thể chuyển tiếp tác nhân gpg của mình qua ssh nếu bạn cần ký thẻ hoặc
cam kết trên một hệ thống từ xa. Vui lòng tham khảo hướng dẫn được cung cấp
trên wiki GnuPG:

-ZZ0000ZZ

Nó hoạt động trơn tru hơn nếu bạn có thể sửa đổi cài đặt máy chủ sshd trên
đầu xa.

.. _`Agent Forwarding over SSH`: https://wiki.gnupg.org/AgentForwarding

.. _pgp_with_git:

Sử dụng PGP với Git
==================

Một trong những tính năng cốt lõi của Git là tính chất phi tập trung của nó -- một khi
kho lưu trữ được sao chép vào hệ thống của bạn, bạn có toàn bộ lịch sử của
dự án, bao gồm tất cả các thẻ, cam kết và nhánh của nó. Tuy nhiên, với
hàng trăm kho lưu trữ nhân bản trôi nổi khắp nơi, làm sao có ai xác minh được
rằng bản sao linux.git của họ không bị phần mềm độc hại giả mạo
bên thứ ba?

Hoặc điều gì sẽ xảy ra nếu mã độc được phát hiện trong kernel và
Dòng "Tác giả" trong cam kết nói rằng nó được thực hiện bởi bạn, trong khi bạn xinh đẹp
chắc chắn bạn đã có ZZ0000ZZ?

Để giải quyết cả hai vấn đề này, Git đã giới thiệu tích hợp PGP. Đã ký
các thẻ chứng minh tính toàn vẹn của kho lưu trữ bằng cách đảm bảo rằng nội dung của nó là
hoàn toàn giống như trên máy trạm của nhà phát triển đã tạo ra
tag, trong khi các cam kết đã ký khiến ai đó gần như không thể thực hiện được
mạo danh bạn mà không có quyền truy cập vào khóa PGP của bạn.

.. _`nothing to do with it`: https://github.com/jayphelps/git-blame-someone-else

Định cấu hình git để sử dụng khóa PGP của bạn
---------------------------------

Nếu bạn chỉ có một khóa bí mật trong móc khóa thì bạn thực sự không
cần phải làm gì thêm vì nó sẽ trở thành khóa mặc định của bạn.  Tuy nhiên, nếu
tình cờ bạn có nhiều khóa bí mật, bạn có thể cho git biết khóa nào
nên được sử dụng (ZZ0000ZZ là dấu vân tay của chìa khóa của bạn)::

$ git config --global user.signingKey [fpr]

Cách làm việc với thẻ đã ký
----------------------------

Để tạo thẻ đã ký, hãy chuyển công tắc ZZ0000ZZ sang lệnh thẻ ::

$ git tag -s [tên thẻ]

Khuyến nghị của chúng tôi là luôn ký thẻ git, vì điều này cho phép người khác
các nhà phát triển để đảm bảo rằng kho lưu trữ git mà họ đang lấy từ đó có
không bị thay đổi một cách ác ý.

Cách xác minh thẻ đã ký
~~~~~~~~~~~~~~~~~~~~~~~~~

Để xác minh thẻ đã ký, hãy sử dụng lệnh ZZ0000ZZ ::

$ git xác minh-thẻ [tên thẻ]

Nếu bạn đang lấy thẻ từ một nhánh khác của kho lưu trữ dự án,
git sẽ tự động xác minh chữ ký ở đầu bạn đang kéo
và hiển thị cho bạn kết quả trong quá trình hợp nhất::

$ git kéo thẻ [url]/sometag

Thông báo hợp nhất sẽ chứa nội dung như thế này ::

Hợp nhất thẻ 'sometag' của [url]

[Thẻ tin nhắn]

# gpg: Chữ ký được tạo […]
    # gpg: Chữ ký tốt từ […]

Nếu bạn đang xác minh thẻ git của người khác, trước tiên bạn cần phải
nhập khóa PGP của họ. Vui lòng tham khảo "ZZ0000ZZ"
phần bên dưới.

Định cấu hình git để luôn ký các thẻ chú thích
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Rất có thể, nếu bạn đang tạo một thẻ có chú thích, bạn sẽ muốn ký
nó. Để buộc git luôn ký các thẻ chú thích, bạn có thể đặt toàn cục
tùy chọn cấu hình::

$ git config --global tag.forceSignAnnotated true

Cách làm việc với các cam kết đã ký
-------------------------------

Cũng có thể tạo các cam kết đã ký, nhưng chúng có giới hạn
hữu ích trong việc phát triển nhân Linux. Quy trình đóng góp hạt nhân
dựa vào việc gửi các bản vá và việc chuyển đổi các cam kết thành các bản vá không
giữ chữ ký cam kết git. Hơn nữa, khi rebasing của riêng bạn
kho lưu trữ trên thượng nguồn mới hơn, chữ ký cam kết PGP sẽ kết thúc
bị loại bỏ. Vì lý do này, hầu hết các nhà phát triển kernel không bận tâm đến việc ký
cam kết của họ và sẽ bỏ qua các cam kết đã ký trong bất kỳ bên ngoài nào
kho lưu trữ mà họ dựa vào trong công việc của họ.

Điều đó có nghĩa là, nếu bạn công khai cây git đang hoạt động của mình tại một số nơi
dịch vụ lưu trữ git (kernel.org, infradead.org, ozlabs.org hoặc các dịch vụ khác),
thì lời khuyên là bạn nên ký tất cả các cam kết git của mình ngay cả khi
các nhà phát triển thượng nguồn không được hưởng lợi trực tiếp từ hoạt động này.

Chúng tôi khuyên bạn nên làm điều này vì những lý do sau:

1. Nếu có nhu cầu thực hiện điều tra mã hoặc mã theo dõi
   xuất xứ, ngay cả những cây được bảo trì bên ngoài mang cam kết PGP
   chữ ký sẽ có giá trị cho những mục đích đó.
2. Nếu bạn cần sao chép lại kho lưu trữ cục bộ của mình (ví dụ:
   sau khi cài đặt lại hệ thống của bạn), điều này cho phép bạn xác minh kho lưu trữ
   tính chính trực trước khi tiếp tục công việc của bạn.
3. Nếu ai đó cần chọn những cam kết của bạn, điều này cho phép họ
   nhanh chóng xác minh tính toàn vẹn của chúng trước khi áp dụng chúng.

Tạo các cam kết đã ký
~~~~~~~~~~~~~~~~~~~~~~~

Để tạo một cam kết đã ký, hãy chuyển cờ ZZ0000ZZ cho ZZ0001ZZ
lệnh (đó là chữ hoa ZZ0002ZZ do va chạm với cờ khác)::

$ git cam kết -S

Định cấu hình git để luôn ký xác nhận
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bạn có thể yêu cầu git luôn ký các cam kết ::

cấu hình git --global commit.gpgSign true

.. note::

    Make sure you configure ``gpg-agent`` before you turn this on.

.. _verify_identities:

Cách làm việc với các bản vá đã ký
-------------------------------

Có thể sử dụng khóa PGP của bạn để ký các bản vá được gửi tới kernel
danh sách gửi thư của nhà phát triển. Vì cơ chế chữ ký email hiện có
(PGP-Mime hoặc PGP-inline) có xu hướng gây ra sự cố với mã thông thường
Xem lại tác vụ, bạn nên sử dụng công cụ kernel.org được tạo cho việc này
mục đích đặt chữ ký chứng thực mật mã vào tin nhắn
tiêu đề (a-la DKIM):

-ZZ0000ZZ

.. _`Patatt Patch Attestation`: https://pypi.org/project/patatt/

Cài đặt và cấu hình patatt
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. note::

    If you use B4 to send in your patches, patatt is already installed
    and integrated into your workflow.

Patatt đã được đóng gói cho nhiều bản phân phối rồi, vì vậy vui lòng kiểm tra tại đó
đầu tiên. Bạn cũng có thể cài đặt nó từ pypi bằng "ZZ0000ZZ".

Nếu bạn đã cấu hình khóa PGP bằng git (thông qua
Tham số cấu hình ZZ0000ZZ), thì patatt không yêu cầu
cấu hình thêm. Bạn có thể bắt đầu ký các bản vá của mình bằng cách cài đặt
hook git-send-email trong kho lưu trữ mà bạn muốn ::

móc cài đặt patatt

Bây giờ mọi bản vá bạn gửi bằng ZZ0000ZZ sẽ được tự động
được ký bằng chữ ký mật mã của bạn.

Kiểm tra chữ ký patatt
~~~~~~~~~~~~~~~~~~~~~~~~~~

Nếu bạn đang sử dụng ZZ0000ZZ để truy xuất và áp dụng các bản vá thì nó sẽ
tự động cố gắng xác minh tất cả chữ ký DKIM và patatt
gặp gỡ, ví dụ::

$ b4 sáng 20220720205013.890942-1-broonie@kernel.org
    […]
    Đang kiểm tra chứng thực trên tất cả thư, có thể mất chút thời gian...
    ---
      ✓ [PATCH v1 1/3] kselftest/arm64: Phân bổ bộ đệm chính xác cho các thanh ghi SVE Z
      ✓ [PATCH v1 2/3] arm64/sve: Ghi lại ABI thực tế của chúng tôi để xóa các thanh ghi trên syscall
      ✓ [PATCH v1 3/3] kselftest/arm64: Thực thi ABI thực tế cho các tòa nhà cao tầng SVE
      ---
      ✓ Đã ký: openpgp/broonie@kernel.org
      ✓ Đã ký: DKIM/kernel.org

.. note::

    Patatt and b4 are still in active development and you should check
    the latest documentation for these projects for any new or updated
    features.

.. _kernel_identities:

Cách xác minh danh tính nhà phát triển kernel
=========================================

Việc ký thẻ và cam kết rất đơn giản, nhưng thực hiện như thế nào
xác minh rằng khóa được sử dụng để ký một cái gì đó thuộc về thực tế
nhà phát triển kernel chứ không phải kẻ mạo danh độc hại?

Định cấu hình tự động truy xuất khóa bằng WKD và DANE
-----------------------------------------------

Nếu bạn chưa phải là người có bộ sưu tập phong phú về những thứ khác
khóa công khai của nhà phát triển thì bạn có thể khởi động lại khóa của mình bằng cách dựa vào
về tự động phát hiện và tự động truy xuất khóa. GnuPG có thể dựa vào những thứ khác
các công nghệ tin cậy được ủy quyền, cụ thể là DNSSEC và TLS, để giúp bạn thực hiện nếu
triển vọng bắt đầu Web of Trust của riêng bạn từ đầu cũng vậy
đáng ngại.

Thêm phần sau vào ZZ0000ZZ của bạn::

tự động định vị khóa wkd,dane,local
    tự động lấy chìa khóa

Xác thực dựa trên DNS của các thực thể được đặt tên ("DANE") là một phương pháp để
xuất bản khóa công khai trong DNS và bảo mật chúng bằng DNSSEC đã ký
khu. Thư mục khóa Web ("WKD") là phương pháp thay thế sử dụng
tra cứu https cho cùng mục đích. Khi sử dụng DANE hoặc WKD cho
tra cứu khóa công khai, GnuPG sẽ xác thực chứng chỉ DNSSEC hoặc TLS,
tương ứng, trước khi thêm khóa công khai được tự động truy xuất vào địa phương của bạn
móc khóa.

Kernel.org xuất bản WKD cho tất cả các nhà phát triển có kernel.org
tài khoản. Khi bạn có những thay đổi ở trên trong ZZ0000ZZ của mình, bạn có thể
tự động lấy chìa khóa cho Linus Torvalds và Greg Kroah-Hartman (nếu bạn
chưa có chúng)::

$ gpg --locate-keys torvalds@kernel.org gregkh@kernel.org

Nếu bạn có tài khoản kernel.org thì bạn nên sử dụng ZZ0000ZZ để WKD trở nên hữu ích hơn cho các nhà phát triển kernel khác.

.. _`add the kernel.org UID to your key`: https://korg.docs.kernel.org/mail.html#adding-a-kernel-org-uid-to-your-pgp-key

Web of Trust (WOT) so với Trust khi sử dụng lần đầu (TOFU)
------------------------------------------------

PGP kết hợp cơ chế ủy quyền tin cậy được gọi là "Web of
Hãy tin tưởng." Về cốt lõi, đây là một nỗ lực nhằm thay thế nhu cầu về
Cơ quan chứng nhận tập trung của thế giới HTTPS/TLS. Thay vì
các nhà sản xuất phần mềm khác nhau quyết định ai sẽ là người chứng nhận đáng tin cậy của bạn
thực thể, PGP giao trách nhiệm này cho mỗi người dùng.

Thật không may, rất ít người hiểu cách thức hoạt động của Web of Trust.
Mặc dù nó vẫn là một phần quan trọng của đặc tả OpenPGP,
các phiên bản gần đây của GnuPG (2.2 trở lên) đã triển khai một giải pháp thay thế
cơ chế được gọi là "Tin cậy khi sử dụng lần đầu" (TOFU). Bạn có thể coi TOFU là
"cách tiếp cận tin cậy giống như SSH." Với SSH, lần đầu tiên bạn kết nối
đến một hệ thống từ xa, dấu vân tay chính của nó sẽ được ghi lại và ghi nhớ. Nếu
những thay đổi quan trọng trong tương lai, ứng dụng khách SSH sẽ cảnh báo bạn và từ chối
để kết nối, buộc bạn phải đưa ra quyết định xem bạn có chọn
có tin tưởng vào khóa đã thay đổi hay không. Tương tự, lần đầu tiên bạn nhập
khóa PGP của ai đó, nó được coi là hợp lệ. Nếu tại bất kỳ thời điểm nào trong
GnuPG trong tương lai tình cờ gặp một khóa khác có cùng danh tính, cả khóa
khóa đã nhập trước đó và khóa mới sẽ được đánh dấu để xác minh
và bạn sẽ cần phải tìm ra cái nào cần giữ lại theo cách thủ công.

Chúng tôi khuyên bạn nên sử dụng mô hình tin cậy TOFU+PGP kết hợp (là
mặc định mới trong GnuPG v2). Để thiết lập nó, hãy thêm (hoặc sửa đổi)
Cài đặt ZZ0000ZZ trong ZZ0001ZZ::

mô hình tin cậy đậu phụ+pgp

.. _kernel_org_trust_repository:

Sử dụng web kernel.org của kho lưu trữ tin cậy
--------------------------------------------

Kernel.org duy trì một kho lưu trữ git với các khóa công khai của nhà phát triển dưới dạng
thay thế cho việc sao chép các mạng máy chủ khóa gần như đã hoạt động
đen tối trong vài năm qua. Tài liệu đầy đủ về cách thiết lập
kho lưu trữ đó làm nguồn khóa công khai của bạn có thể được tìm thấy ở đây:

-ZZ0000ZZ

Nếu bạn là nhà phát triển hạt nhân, vui lòng xem xét việc gửi khóa của bạn cho
đưa vào chiếc móc khóa đó.

.. _`Kernel developer PGP Keyring`: https://korg.docs.kernel.org/pgpkeys.html