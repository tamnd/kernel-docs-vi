.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/verify-bugs-and-bisect-regressions.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. [see the bottom of this file for redistribution information]

=============================================
Cách xác minh lỗi và hồi quy chia đôi
=============================================

Tài liệu này mô tả cách kiểm tra xem một số vấn đề về nhân Linux có xảy ra trong mã hay không
hiện được các nhà phát triển hỗ trợ -- để sau đó giải thích cách xác định vị trí thay đổi
gây ra sự cố, nếu đó là sự hồi quy (ví dụ: không xảy ra với các phiên bản trước đó
các phiên bản).

Văn bản này nhằm vào những người chạy hạt nhân từ các bản phân phối Linux chính thống trên
phần cứng hàng hóa muốn báo cáo lỗi kernel cho Linux ngược dòng
nhà phát triển. Bất chấp mục đích này, các hướng dẫn vẫn có tác dụng tốt đối với người dùng
những người đã quen với việc xây dựng hạt nhân của riêng mình: họ giúp tránh
những sai lầm đôi khi mắc phải ngay cả bởi những nhà phát triển có kinh nghiệm.

..
   Note: if you see this note, you are reading the text's source file. You
   might want to switch to a rendered version: it makes it a lot easier to
   read and navigate this document -- especially when you want to look something
   up in the reference section, then jump back to where you left off.
..
   Find the latest rendered version of this text here:
   https://docs.kernel.org/admin-guide/verify-bugs-and-bisect-regressions.html

Bản chất của quy trình (còn gọi là 'TL;DR')
========================================

*[Nếu bạn là người mới xây dựng hoặc chia đôi Linux, hãy bỏ qua phần này và đi đầu
tới* 'ZZ0000ZZ' *bên dưới. Nó sử dụng
các lệnh tương tự như phần này trong khi mô tả chúng một cách ngắn gọn. các
tuy nhiên các bước rất dễ thực hiện và cùng với các mục đi kèm
trong phần tham khảo đề cập đến nhiều lựa chọn thay thế, cạm bẫy và bổ sung
các khía cạnh, tất cả những điều đó có thể cần thiết trong trường hợp hiện tại của bạn.]*

**Trong trường hợp bạn muốn kiểm tra xem có lỗi nào trong mã hiện được hỗ trợ hay không
nhà phát triển**, execute just the *preparations* và ZZ0001ZZ; trong khi làm như vậy,
hãy coi hạt nhân Linux mới nhất mà bạn thường sử dụng là hạt nhân 'đang hoạt động'.
Trong ví dụ sau đây được giả định là 6.0, đó là lý do tại sao nguồn của nó
sẽ được sử dụng để chuẩn bị tệp .config.

ZZ0000ZZ, hãy làm theo các bước ít nhất cho đến hết
ZZ0001ZZ. Sau đó, bạn có thể gửi báo cáo sơ bộ -- hoặc tiếp tục với
ZZ0002ZZ, mô tả cách thực hiện phép chia đôi cần thiết cho một
báo cáo hồi quy đầy đủ. Trong ví dụ sau 6.0.13 được coi là
hạt nhân 'đang hoạt động' và 6.1.5 là hạt nhân 'bị hỏng' đầu tiên, đó là lý do tại sao 6.0
sẽ được coi là bản phát hành “tốt” và được sử dụng để chuẩn bị file .config.

* ZZ0000ZZ: thiết lập mọi thứ để xây dựng kernel của riêng bạn::

# * Xóa mọi phần mềm phụ thuộc vào các mô-đun hạt nhân được duy trì bên ngoài
    #   or tự động xây dựng mọi thứ trong quá trình khởi động.
    # * Đảm bảo Khởi động an toàn cho phép khởi động các hạt nhân Linux tự biên dịch.
    # * Nếu bạn chưa chạy kernel 'đang hoạt động', hãy khởi động lại vào nó.
    # * Cài đặt trình biên dịch và mọi thứ khác cần thiết để xây dựng Linux.
    # * Đảm bảo có 15 Gigabyte dung lượng trống trong thư mục chính của bạn.
    git clone -o dòng chính --no-checkout \
      ZZ0000ZZ ~/linux/
    cd ~/linux/
    git remote add -t master ổn định \
      ZZ0001ZZ
    chuyển đổi git --detach v6.0
    # * Gợi ý: nếu bạn đã sử dụng một bản sao hiện có, hãy đảm bảo không có .config cũ nào tồn tại.
    tạo olddefconfig
    # * Đảm bảo lệnh trước đã chọn .config của kernel 'đang hoạt động'.
    # * Kết nối phần cứng bên ngoài (khóa USB, mã thông báo, ...), khởi động VM, hiển thị
    #   VPNs, gắn kết chia sẻ mạng và thử nhanh tính năng bị hỏng.
    vâng '' | tạo localmodconfig
    ./scripts/config --set-str CONFIG_LOCALVERSION '-local'
    ./scripts/config -e CONFIG_LOCALVERSION_AUTO
    # * Lưu ý, khi thiếu dung lượng lưu trữ, hãy xem hướng dẫn để có giải pháp thay thế:
    ./scripts/config -d DEBUG_INFO_NONE -e KALLSYMS_ALL -e DEBUG_KERNEL \
      -e DEBUG_INFO -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -e KALLSYMS
    # * Gợi ý: tại thời điểm này bạn có thể muốn điều chỉnh cấu hình bản dựng;
    #   you sẽ phải làm vậy nếu bạn đang chạy Debian.
    tạo olddefconfig
    cp .config ~/kernel-config-working

* ZZ0000ZZ: xây dựng kernel từ codebase dòng chính mới nhất.

Điều này trong số những điều khác sẽ kiểm tra xem sự cố đã được khắc phục chưa và nhà phát triển nào
  sau này cần được thông báo về vấn đề đó; trong trường hợp hồi quy, quy tắc này
  đưa ra một thay đổi .config là gốc của vấn đề.

a) Kiểm tra mã đường chính mới nhất::

cd ~/linux/
       git switch --discard-changes --detach mainline/master

b) Xây dựng, cài đặt và khởi động kernel::

cp ~/kernel-config-working .config
       tạo olddefconfig
       tạo -j $(nproc --all)
       # * Đảm bảo có đủ dung lượng đĩa để chứa kernel khác:
       df -h /boot/ /lib/modules/
       # * Lưu ý: trên Arch Linux, các phiên bản phái sinh của nó và một số bản phân phối khác
       #   the các lệnh sau đây sẽ không làm gì cả hoặc chỉ làm một phần của
       #   job. Xem hướng dẫn từng bước để biết thêm chi tiết.
       sudo tạo module_install
       lệnh -v installkernel && sudo thực hiện cài đặt
       # * Kiểm tra xem hạt nhân tự xây dựng của bạn thực sự cần bao nhiêu dung lượng,
       #   enables bạn để ước tính tốt hơn sau này:
       du -ch /boot/ZZ0000ZZ | đuôi -n 1
       du -sh /lib/modules/$(make -s kernelrelease)/
       # * Gợi ý: kết quả của lệnh sau sẽ giúp bạn chọn
       Hạt nhân #   right từ menu khởi động:
       make -s kernelrelease | tee -a ~/kernels-build
       khởi động lại
       # * Sau khi khởi động, hãy đảm bảo bạn đang chạy kernel mà bạn vừa tạo
       #   checking nếu đầu ra của hai lệnh tiếp theo khớp với nhau:
       tail -n 1 ~/kernels-build
       tên -r
       mèo /proc/sys/kernel/bị nhiễm độc

c) Kiểm tra xem sự cố có xảy ra với kernel này không.

* ZZ0000ZZ: đảm bảo kernel “tốt” cũng là kernel “hoạt động tốt”.

Điều này trong số những điều khác xác minh tệp .config đã được cắt bớt thực sự hoạt động tốt, như
  chia đôi với nó nếu không sẽ lãng phí thời gian:

a) Bắt đầu bằng cách kiểm tra nguồn của phiên bản 'tốt'::

cd ~/linux/
       chuyển đổi git --discard-thay đổi --detach v6.0

b) Xây dựng, cài đặt và khởi động kernel như được mô tả trước đó trong *đoạn 1,
     phần b* -- bạn có thể thoải mái bỏ qua các lệnh 'du' vì bạn gặp khó khăn
     ước tính rồi.

c) Đảm bảo tính năng bị thoái lui với kernel 'bị hỏng' thực sự hoạt động
     với cái này

* ZZ0000ZZ: thực hiện và xác nhận phép chia đôi.

a) Truy xuất nguồn cho phiên bản 'xấu' của bạn::

git remote set-branches --add ổn định linux-6.1.y
       git tìm nạp ổn định

b) Khởi tạo phép chia::

cd ~/linux/
       git chia đôi bắt đầu
       git chia đôi tốt v6.0
       git bisect xấu v6.1.5

c) Xây dựng, cài đặt và khởi động kernel như được mô tả trước đó trong *đoạn 1,
     phần b*.

Trong trường hợp việc xây dựng hoặc khởi động kernel bị lỗi vì những lý do không liên quan, hãy chạy
     ZZ0000ZZ. Trong tất cả các kết quả khác, hãy kiểm tra xem tính năng hồi quy có
     hoạt động với kernel mới được xây dựng. Nếu vậy, hãy báo cho Git bằng cách thực thi
     ZZ0001ZZ; nếu không, hãy chạy ZZ0002ZZ.

Cả ba lệnh sẽ khiến Git kiểm tra một cam kết khác; sau đó thực hiện lại
     bước này (ví dụ: xây dựng, cài đặt, khởi động và kiểm tra kernel để báo cho Git
     kết quả). Làm như vậy nhiều lần cho đến khi Git hiển thị cam kết nào bị hỏng
     mọi thứ. Nếu bạn hết dung lượng ổ đĩa trong quá trình này, hãy kiểm tra
     phần 'Nhiệm vụ bổ sung: dọn dẹp trong và sau quá trình'
     bên dưới.

d) Sau khi chia đôi xong, hãy cất một số thứ đi::

cd ~/linux/
       git nhật ký chia đôi > ~/bisect-log
       cp .config ~/bisection-config-thủ phạm
       thiết lập lại git chia đôi

e) Thử kiểm chứng kết quả chia đôi::

git switch --discard-changes --detach mainline/master
       git hoàn nguyên --no-chỉnh sửa cafec0cacaca0
       cp ~/kernel-config-working .config
       ./scripts/config --set-str CONFIG_LOCALVERSION '-local-cafec0cacaca0-reverted'

Đây là tùy chọn vì một số cam kết không thể hoàn nguyên. Nhưng nếu
    lệnh thứ hai hoạt động hoàn hảo, xây dựng, cài đặt và khởi động thêm một kernel
    hạt nhân; lần này hãy bỏ qua lệnh đầu tiên sao chép tệp .config cơ sở
    kết thúc, vì điều đó đã được xử lý xong.

* ZZ0000ZZ: dọn dẹp trong và sau quá trình.

a) Để tránh hết dung lượng ổ đĩa trong quá trình chia đôi, bạn có thể cần phải
     loại bỏ một số hạt nhân bạn đã xây dựng trước đó. Rất có thể bạn muốn giữ những thứ đó
     bạn đã xây dựng trong phân đoạn 1 và 2 được một thời gian, nhưng hầu hết bạn sẽ
     có thể không còn cần hạt nhân được kiểm tra trong quá trình chia đôi thực tế
     (Đoạn 3c). Bạn có thể liệt kê chúng theo thứ tự xây dựng bằng cách sử dụng::

ls -ltr /lib/mô-đun/ZZ0000ZZ

Ví dụ, để xóa một hạt nhân tự nhận mình là
    '6.0-rc1-local-gcafec0cacaca0', hãy sử dụng cái này ::

sudo rm -rf /lib/modules/6.0-rc1-local-gcafec0cacaca0
       sudo kernel-install -v xóa 6.0-rc1-local-gcafec0cacaca0
       # * Lưu ý, trên một số bản phân phối thiếu kernel-install
       #   or chỉ thực hiện một phần công việc.

b) Nếu bạn thực hiện phép chia đôi và xác nhận thành công kết quả, hãy cảm nhận
     tự do loại bỏ tất cả các hạt nhân được xây dựng trong quá trình chia đôi thực tế (Đoạn 3 c);
     các hạt nhân bạn đã xây dựng trước đó và sau này bạn có thể muốn giữ lại để sử dụng
     một hoặc hai tuần.

* ZZ0000ZZ: kiểm tra bản vá gỡ lỗi hoặc bản sửa lỗi được đề xuất sau::

git tìm nạp dòng chính
    git switch --discard-changes --detach mainline/master
    git áp dụng /tmp/foobars-proposes-fix-v1.patch
    cp ~/kernel-config-working .config
    ./scripts/config --set-str CONFIG_LOCALVERSION '-local-foobars-fix-v1'

Xây dựng, cài đặt và khởi động kernel như được mô tả trong ZZ0000ZZ --
  nhưng lần này bỏ qua lệnh đầu tiên sao chép cấu hình bản dựng,
  vì điều đó đã được xử lý rồi.

.. _introguide_bissbs:

Hướng dẫn từng bước về cách xác minh lỗi và chia đôi hồi quy
===============================================================

Hướng dẫn này mô tả cách thiết lập nhân Linux của riêng bạn để điều tra lỗi
hoặc hồi quy mà bạn dự định báo cáo. Bạn muốn làm theo hướng dẫn đến mức nào
phụ thuộc vào vấn đề của bạn:

Thực hiện tất cả các bước cho đến hết ZZ0001ZZ để **xác minh xem kernel của bạn có vấn đề không
có trong mã được các nhà phát triển nhân Linux hỗ trợ**. Nếu đúng như vậy thì bạn là tất cả
được thiết lập để báo cáo lỗi -- trừ khi nó không xảy ra với các phiên bản kernel trước đó,
vì vậy ít nhất bạn muốn tiếp tục với ZZ0002ZZ để **kiểm tra xem sự cố có xảy ra không
đủ điều kiện là hồi quy** được ưu tiên xử lý. Tùy thuộc vào
kết quả là bạn đã sẵn sàng báo cáo lỗi hoặc gửi hồi quy sơ bộ
báo cáo; thay vì cái sau bạn cũng có thể đi thẳng và làm theo
ZZ0003ZZ đến ZZ0000ZZ để có báo cáo hồi quy đầy đủ
các nhà phát triển có nghĩa vụ phải hành động.

ZZ0000ZZ.

ZZ0000ZZ.

ZZ0000ZZ.

ZZ0000ZZ.

ZZ0000ZZ.

ZZ0000ZZ.

Các bước trong mỗi phân đoạn minh họa các khía cạnh quan trọng của quy trình, đồng thời
phần tham khảo toàn diện chứa các chi tiết bổ sung cho hầu hết tất cả các
các bước. Phần tham khảo đôi khi cũng nêu ra những cách tiếp cận khác,
cạm bẫy cũng như các vấn đề có thể xảy ra ở bước cụ thể -- và cách
để mọi thứ quay trở lại.

Để biết thêm chi tiết về cách báo cáo sự cố hoặc hồi quy của nhân Linux, hãy kiểm tra
out Documentation/admin-guide/reporting-issues.rst, hoạt động cùng nhau
với tài liệu này. Nó trong số những thứ khác giải thích lý do tại sao bạn cần xác minh lỗi bằng
hạt nhân 'chính tuyến' mới nhất (ví dụ: các phiên bản như 6.0, 6.1-rc1 hoặc 6.1-rc6),
ngay cả khi bạn gặp phải sự cố với hạt nhân từ dòng 'ổn định/lâu dài'
(nói 6.0.13).

Đối với những người dùng đang gặp phải tình trạng hồi quy, tài liệu đó cũng giải thích lý do tại sao việc gửi một
báo cáo sơ bộ sau phân đoạn 2 có thể là khôn ngoan vì hồi quy và
thủ phạm có thể đã được biết đến rồi. Để biết thêm chi tiết về những gì thực sự đủ điều kiện
như một hồi quy, hãy kiểm tra Documentation/admin-guide/reporting-regressions.rst.

Nếu bạn gặp bất kỳ vấn đề nào khi làm theo hướng dẫn này hoặc có ý tưởng về cách
cải thiện nó đi, ZZ0000ZZ.

.. _introprep_bissbs:

Chuẩn bị: thiết lập mọi thứ để xây dựng hạt nhân của riêng bạn
---------------------------------------------------------

Các bước sau đây đặt nền tảng cho tất cả các nhiệm vụ tiếp theo.

Lưu ý: hướng dẫn giả sử bạn đang xây dựng và thử nghiệm trên cùng một
máy; nếu bạn muốn biên dịch kernel trên hệ thống khác, hãy kiểm tra
ZZ0000ZZ bên dưới.

.. _backup_bissbs:

* Tạo một bản sao lưu mới và có sẵn các công cụ sửa chữa và khôi phục hệ thống, chỉ cần
  để chuẩn bị cho trường hợp khó xảy ra là một điều gì đó đi ngang.

[ZZ0000ZZ]

.. _vanilla_bissbs:

* Loại bỏ tất cả phần mềm phụ thuộc vào trình điều khiển hạt nhân được phát triển bên ngoài hoặc
  xây dựng chúng một cách tự động. Điều đó bao gồm nhưng không giới hạn ở DKMS, openZFS,
  Trình điều khiển đồ họa của VirtualBox và Nvidia (bao gồm mô-đun hạt nhân GPLed).

[ZZ0000ZZ]

.. _secureboot_bissbs:

* Trên các nền tảng có 'Khởi động an toàn' hoặc các giải pháp tương tự, hãy chuẩn bị mọi thứ để
  đảm bảo hệ thống sẽ cho phép kernel tự biên dịch của bạn khởi động. các
  cách nhanh nhất và dễ nhất để đạt được điều này trên các hệ thống x86 hàng hóa là
  vô hiệu hóa các kỹ thuật như vậy trong tiện ích thiết lập BIOS; cách khác, loại bỏ
  những hạn chế của họ thông qua một quá trình được khởi xướng bởi
  ZZ0000ZZ.

[ZZ0000ZZ]

.. _rangecheck_bissbs:

* Xác định các phiên bản kernel được coi là “tốt” và “xấu” trong suốt quá trình này
  hướng dẫn:

* Bạn có làm theo hướng dẫn này để xác minh xem có lỗi trong mã không
    các nhà phát triển chính quan tâm đến? Sau đó xem xét phiên bản kernel mới nhất
    hiện tại bạn thường xuyên sử dụng là 'tốt' (ví dụ: 6.0, 6.0.13 hoặc 6.1-rc2).

* Bạn có phải đối mặt với sự hồi quy không, ví dụ: một cái gì đó đã bị hỏng hoặc hoạt động tồi tệ hơn sau đó
    chuyển sang phiên bản kernel mới hơn? Trong trường hợp đó, nó phụ thuộc vào phiên bản
    phạm vi mà sự cố xuất hiện:

* Đã xảy ra lỗi khi cập nhật từ bản phát hành ổn định/dài hạn
      (giả sử 6.0.13) sang dòng chính mới hơn (như 6.1-rc7 hoặc 6.1) hoặc một
      phiên bản ổn định/dài hạn dựa trên một (giả sử 6.1.5)? Sau đó xem xét
      bản phát hành chính tuyến mà hạt nhân đang hoạt động của bạn dựa vào đó để trở thành 'tốt'
      phiên bản (ví dụ: 6.0) và phiên bản đầu tiên bị hỏng là phiên bản 'xấu'
      (ví dụ: 6.1-rc7, 6.1 hoặc 6.1.5). Lưu ý, tại thời điểm này nó chỉ được giả định
      6.0 đó là ổn; giả thuyết này sẽ được kiểm tra trong phân đoạn 2.

* Đã xảy ra lỗi khi chuyển từ một phiên bản chính (ví dụ 6.0) sang
      phiên bản mới hơn (như 6.1-rc1) hoặc bản phát hành ổn định/dài hạn dựa trên nó
      (nói 6.1.5)? Sau đó coi phiên bản hoạt động cuối cùng (ví dụ: 6.0) là 'tốt' và
      lỗi đầu tiên (ví dụ: 6.1-rc1 hoặc 6.1.5) là 'xấu'.

* Đã xảy ra lỗi khi cập nhật trong chuỗi ổn định/dài hạn (giả sử
      từ 6.0.13 đến 6.0.15)? Sau đó coi những phiên bản đó là 'tốt' và 'xấu'
      (ví dụ: 6.0.13 và 6.0.15), vì bạn cần chia đôi trong chuỗi đó.

*Lưu ý, đừng nhầm lẫn phiên bản 'tốt' với kernel 'đang hoạt động'; thuật ngữ sau
  xuyên suốt hướng dẫn này sẽ đề cập đến kernel cuối cùng đang hoạt động
  ổn.*

[ZZ0000ZZ]

.. _bootworking_bissbs:

* Khởi động vào kernel 'đang hoạt động' và sử dụng nhanh tính năng có vẻ bị hỏng.

[ZZ0000ZZ]

.. _diskspace_bissbs:

* Đảm bảo có đủ dung lượng trống để xây dựng Linux. 15 Gigabyte trong nhà bạn
  thư mục thường là đủ. Nếu bạn có ít hơn, hãy chắc chắn trả tiền
  chú ý đến các bước sau về việc truy xuất nguồn Linux và xử lý
  biểu tượng gỡ lỗi: cả hai đều giải thích các phương pháp giảm dung lượng, giúp
  sẽ cho phép bạn thực hiện thành thạo các tác vụ này với dung lượng trống khoảng 4 Gigabyte.

[ZZ0000ZZ]

.. _buildrequires_bissbs:

* Cài đặt tất cả phần mềm cần thiết để xây dựng nhân Linux. Thường thì bạn sẽ cần:
  'bc', 'binutils' ('ld' và cộng sự), 'bison', 'flex', 'gcc', 'git', 'openssl',
  'pahole', 'Perl' và các tiêu đề phát triển cho 'libelf' và 'openssl'. các
  phần tham khảo hướng dẫn cách cài đặt nhanh chóng những thứ đó trên các Linux phổ biến khác nhau
  phân phối.

[ZZ0000ZZ]

.. _sources_bissbs:

* Truy xuất các nguồn Linux chính thống; sau đó thay đổi vào thư mục đang giữ
  chúng, vì tất cả các lệnh khác trong hướng dẫn này đều được thực thi từ
  ở đó.

*Lưu ý, phần sau đây mô tả cách truy xuất các nguồn bằng cách sử dụng toàn bộ
  bản sao chính, tải xuống khoảng 2,75 GByte tính đến đầu năm 2024.*
  ZZ0000ZZ *:
  một tải xuống ít hơn 500 MByte, cái còn lại hoạt động tốt hơn với không đáng tin cậy
  kết nối internet.*

Thực hiện lệnh sau để truy xuất cơ sở mã dòng chính mới trong khi
  chuẩn bị thêm chi nhánh cho chuỗi ổn định/dài hạn sau này::

git clone -o dòng chính --no-checkout \
      ZZ0000ZZ ~/linux/
    cd ~/linux/
    git remote add -t master ổn định \
      ZZ0001ZZ

[ZZ0000ZZ]

.. _stablesources_bissbs:

* Một trong những phiên bản bạn đã xác định trước đó là 'tốt' hay 'xấu' là phiên bản ổn định hay
  phát hành dài hạn (giả sử 6.1.5)? Sau đó tải xuống mã của bộ truyện mà nó thuộc về
  đến ('linux-6.1.y' trong ví dụ này)::

git remote set-branches --add ổn định linux-6.1.y
    git tìm nạp ổn định

.. _oldconfig_bissbs:

* Bắt đầu chuẩn bị cấu hình bản dựng kernel (tệp '.config').

Trước khi làm như vậy, hãy đảm bảo bạn vẫn đang chạy kernel 'đang hoạt động' trước đó
  bước bảo bạn khởi động; nếu bạn không chắc chắn, hãy kiểm tra bản phát hành kernel hiện tại
  định danh bằng ZZ0000ZZ.

Sau đó kiểm tra mã nguồn của phiên bản được thiết lập trước đó dưới dạng
  'tốt'. Trong lệnh ví dụ sau, giá trị này được giả định là 6.0; lưu ý rằng
  số phiên bản trong lệnh này và tất cả các lệnh Git sau này cần phải có tiền tố
  với 'v'::

chuyển đổi git --discard-thay đổi --detach v6.0

Bây giờ hãy tạo tệp cấu hình bản dựng ::

tạo olddefconfig

Các tập lệnh xây dựng kernel sau đó sẽ cố gắng định vị tệp cấu hình bản dựng
  cho kernel đang chạy và sau đó điều chỉnh nó cho phù hợp với nhu cầu của nguồn kernel
  bạn đã kiểm tra. Trong khi làm như vậy, nó sẽ in ra một vài dòng bạn cần kiểm tra.

Hãy để ý dòng bắt đầu bằng '# using defaults known in'. Nó nên như vậy
  theo sau là đường dẫn đến tệp trong '/boot/' chứa mã định danh bản phát hành
  của hạt nhân hiện đang làm việc của bạn. Thay vào đó, nếu dòng tiếp tục với một cái gì đó
  như 'arch/x86/configs/x86_64_defconfig', thì không tìm thấy cơ sở hạ tầng bản dựng
  tệp .config cho kernel đang chạy của bạn -- trong trường hợp đó bạn phải đặt một tệp
  ở đó một cách thủ công, như được giải thích trong phần tham khảo.

Trong trường hợp bạn không thể tìm thấy dòng như vậy, hãy tìm dòng có chứa '# configuration
  được ghi vào .config'. Nếu đúng như vậy thì bạn có cấu hình bản dựng cũ
  nằm xung quanh. Trừ khi bạn có ý định sử dụng nó, hãy xóa nó đi; sau đó chạy
  'tạo lại olddefconfig' và kiểm tra xem bây giờ nó đã chọn đúng tệp cấu hình chưa
  làm cơ sở.

[ZZ0000ZZ]

.. _localmodconfig_bissbs:

* Vô hiệu hóa bất kỳ mô-đun hạt nhân nào dường như không cần thiết cho thiết lập của bạn. Đây là
  tùy chọn, nhưng đặc biệt khôn ngoan đối với việc chia đôi, vì nó tăng tốc độ xây dựng
  xử lý rất nhiều -- ít nhất là trừ khi tệp .config được chọn trong
  bước trước đó đã được điều chỉnh cho phù hợp với nhu cầu phần cứng của bạn, trong đó
  trường hợp bạn nên bỏ qua bước này.

Để chuẩn bị cắt tỉa, hãy kết nối phần cứng bên ngoài mà bạn thỉnh thoảng sử dụng (USB
  khóa, mã thông báo, ...), nhanh chóng khởi động VM và hiển thị VPN. Và nếu bạn khởi động lại
  kể từ khi bạn bắt đầu hướng dẫn đó, hãy đảm bảo rằng bạn đã thử sử dụng tính năng gây ra
  rắc rối kể từ khi bạn khởi động hệ thống. Chỉ sau đó cắt .config:: của bạn

vâng '' | tạo localmodconfig

Có một nhược điểm ở đây, đó là từ 'rõ ràng' trong câu đầu tiên của bước này
  và các hướng dẫn chuẩn bị đã được gợi ý ở đây:

Mục tiêu 'localmodconfig' dễ dàng vô hiệu hóa các mô-đun hạt nhân chỉ dành cho các tính năng
  thỉnh thoảng được sử dụng -- như các mô-đun dành cho các thiết bị ngoại vi bên ngoài chưa được kết nối
  kể từ khi khởi động, phần mềm ảo hóa vẫn chưa được sử dụng, đường hầm VPN và một
  vài thứ khác. Đó là bởi vì một số tác vụ chỉ dựa vào các mô-đun hạt nhân Linux
  tải khi bạn thực hiện các tác vụ như những tác vụ đã nói ở trên lần đầu tiên.

Nhược điểm này của localmodconfig không làm bạn mất ngủ, nhưng
  điều cần lưu ý: nếu có điều gì đó không ổn với các hạt nhân được xây dựng
  trong hướng dẫn này, rất có thể đây là lý do. Bạn có thể giảm hoặc gần như
  loại bỏ rủi ro bằng các thủ thuật được nêu trong phần tham khảo; nhưng khi nào
  xây dựng kernel chỉ nhằm mục đích thử nghiệm nhanh, điều này thường không có giá trị
  dành nhiều nỗ lực, miễn là nó khởi động và cho phép kiểm tra đúng cách
  tính năng gây rắc rối.

[ZZ0000ZZ]

.. _tagging_bissbs:

* Đảm bảo tất cả các hạt nhân bạn sẽ xây dựng đều có thể được nhận dạng rõ ràng bằng cách sử dụng một công cụ đặc biệt
  thẻ và số phiên bản duy nhất::

./scripts/config --set-str CONFIG_LOCALVERSION '-local'
    ./scripts/config -e CONFIG_LOCALVERSION_AUTO

[ZZ0000ZZ]

.. _debugsymbols_bissbs:

* Quyết định cách xử lý các biểu tượng gỡ lỗi.

Trong bối cảnh của tài liệu này, việc kích hoạt chúng thường là điều khôn ngoan vì có một
  rất có thể bạn sẽ cần giải mã dấu vết ngăn xếp khỏi trạng thái 'hoảng loạn', 'Rất tiếc',
  'cảnh báo' hoặc 'BUG'::

./scripts/config -d DEBUG_INFO_NONE -e KALLSYMS_ALL -e DEBUG_KERNEL \
      -e DEBUG_INFO -e DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT -e KALLSYMS

Nhưng nếu bạn cực kỳ thiếu dung lượng lưu trữ, bạn có thể muốn tắt
  biểu tượng gỡ lỗi thay thế::

./scripts/config -d DEBUG_INFO -d DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT \
      -d DEBUG_INFO_DWARF4 -d DEBUG_INFO_DWARF5 -e CONFIG_DEBUG_INFO_NONE

[ZZ0000ZZ]

.. _configmods_bissbs:

* Kiểm tra xem bạn có muốn hoặc cần điều chỉnh một số cấu hình kernel khác không
  tùy chọn:

* Bạn có đang chạy Debian không? Sau đó, bạn muốn tránh các vấn đề đã biết bằng cách thực hiện
    điều chỉnh bổ sung được giải thích trong phần tham khảo.

[ZZ0000ZZ].

* Nếu bạn muốn tác động đến các khía cạnh khác của cấu hình, hãy thực hiện ngay bằng cách sử dụng
    công cụ ưa thích của bạn. Lưu ý, để sử dụng các mục tiêu như 'menuconfig' hoặc
    'nconfig', bạn sẽ cần cài đặt các tệp phát triển của ncurses; cho
    'xconfig' bạn cũng cần tiêu đề Qt5 hoặc Qt6.

[ZZ0000ZZ].

.. _saveconfig_bissbs:

* Xử lý lại .config sau những điều chỉnh mới nhất và lưu trữ nó ở nơi an toàn
  địa điểm::

tạo olddefconfig
     cp .config ~/kernel-config-working

[ZZ0000ZZ]

.. _introlatestcheck_bissbs:

Phân đoạn 1: cố gắng tái tạo sự cố với cơ sở mã mới nhất
----------------------------------------------------------------

Các bước sau đây sẽ xác minh xem sự cố hiện có xảy ra với mã hay không
được hỗ trợ bởi các nhà phát triển. Trong trường hợp bạn gặp phải hiện tượng hồi quy, nó cũng kiểm tra xem
vấn đề không phải do một số thay đổi .config gây ra, vì khi đó việc báo cáo sự cố sẽ
là một sự lãng phí thời gian. [ZZ0000ZZ]

.. _checkoutmaster_bissbs:

* Kiểm tra cơ sở mã Linux mới nhất.

* Phiên bản 'tốt' và 'xấu' của bạn thuộc cùng một dòng ổn định hay dài hạn?
    Sau đó kiểm tra ZZ0000ZZ: nếu có
    liệt kê bản phát hành từ bộ đó mà không có thẻ '[EOL]', hãy kiểm tra bộ đó
    phiên bản mới nhất ('linux-6.1.y' trong ví dụ sau)::

cd ~/linux/
      git switch --discard-changes --detach stable/linux-6.1.y

Bộ truyện của bạn không được hỗ trợ, nếu không được liệt kê hoặc có dòng 'kết thúc cuộc đời'
    thẻ. Trong trường hợp đó, bạn có thể muốn kiểm tra xem chuỗi tiếp theo (giả sử
    linux-6.2.y) hoặc dòng chính (xem điểm tiếp theo) sửa lỗi.

* Trong tất cả các trường hợp khác, hãy chạy::

cd ~/linux/
      git switch --discard-changes --detach mainline/master

[ZZ0000ZZ]

.. _build_bissbs:

* Xây dựng hình ảnh và các mô-đun của hạt nhân đầu tiên bằng tệp cấu hình mà bạn
  chuẩn bị::

cp ~/kernel-config-working .config
    tạo olddefconfig
    tạo -j $(nproc --all)

Nếu bạn muốn hạt nhân của bạn được đóng gói dưới dạng tệp deb, vòng/phút hoặc tar, hãy xem phần
  phần tham khảo cho các lựa chọn thay thế, rõ ràng sẽ yêu cầu khác
  các bước để cài đặt là tốt.

[ZZ0000ZZ]

.. _install_bissbs:

* Cài đặt kernel mới được xây dựng của bạn.

Trước khi làm như vậy, hãy cân nhắc kiểm tra xem còn đủ dung lượng cho nó không::

df -h /boot/ /lib/modules/

Hiện tại, giả sử 150 MByte trong /boot/ và 200 MByte trong /lib/modules/ là đủ; làm thế nào
  phần lớn hạt nhân của bạn thực sự yêu cầu sẽ được xác định sau trong hướng dẫn này.

Bây giờ hãy cài đặt các mô-đun của kernel và hình ảnh của nó, chúng sẽ được lưu trữ trong
  song song với nhân của bản phân phối Linux của bạn::

sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt

Lý tưởng nhất là lệnh thứ hai sẽ thực hiện ba bước cần thiết tại thời điểm này
  điểm: sao chép hình ảnh của kernel vào /boot/, tạo initramfs và
  thêm mục nhập cho cả hai vào cấu hình của bộ tải khởi động.

Đáng tiếc là một số bản phân phối (trong số đó có Arch Linux, các phiên bản phái sinh của nó và nhiều bản phân phối khác).
  bản phân phối Linux bất biến) sẽ không thực hiện hoặc chỉ thực hiện một số tác vụ đó.
  Do đó, bạn muốn kiểm tra xem tất cả chúng đã được xử lý và xử lý thủ công chưa
  thực hiện những việc chưa được thực hiện. Phần tài liệu tham khảo cung cấp thêm chi tiết về
  cái đó; tài liệu phân phối của bạn cũng có thể hữu ích.

Khi bạn đã tìm ra các bước cần thiết tại thời điểm này, hãy cân nhắc việc viết chúng
  xuống: nếu bạn xây dựng thêm hạt nhân như được mô tả trong phân đoạn 2 và 3, bạn sẽ
  phải thực hiện lại những điều đó sau khi thực hiện ZZ0000ZZ.

[ZZ0000ZZ]

.. _storagespace_bissbs:

* Trong trường hợp bạn định làm theo hướng dẫn này thêm, hãy kiểm tra dung lượng lưu trữ
  kernel, các mô-đun của nó và các tệp liên quan khác như initramfs tiêu thụ ::

du -ch /boot/ZZ0000ZZ | đuôi -n 1
    du -sh /lib/modules/$(make -s kernelrelease)/

Viết ra hoặc ghi nhớ hai giá trị đó để sử dụng sau: chúng cho phép bạn ngăn chặn
  vô tình hết dung lượng đĩa trong quá trình chia đôi.

[ZZ0000ZZ]

.. _kernelrelease_bissbs:

* Hiển thị và lưu trữ mã nhận dạng kernelrelease của kernel bạn vừa tạo::

make -s kernelrelease | tee -a ~/kernels-build

Hãy nhớ mã định danh trong giây lát, vì nó sẽ giúp bạn chọn đúng kernel
  từ menu khởi động khi khởi động lại.

* Khởi động lại vào kernel mới được xây dựng của bạn. Để đảm bảo bạn thực sự đã bắt đầu
  bạn vừa xây dựng, bạn có thể muốn xác minh xem đầu ra của các lệnh này có
  trận đấu::

tail -n 1 ~/kernels-build
    tên -r

.. _tainted_bissbs:

* Kiểm tra xem kernel có tự đánh dấu là 'bị nhiễm độc' không::

mèo /proc/sys/kernel/bị nhiễm độc

Nếu lệnh đó không trả về '0', hãy kiểm tra phần tham chiếu, xem nguyên nhân là gì
  vì điều này có thể cản trở việc kiểm tra của bạn.

[ZZ0000ZZ]

.. _recheckbroken_bissbs:

* Xác minh xem lỗi của bạn có xảy ra với kernel mới được xây dựng hay không. Nếu không, hãy kiểm tra
  đưa ra hướng dẫn trong phần tham khảo để đảm bảo không có gì đi chệch hướng
  trong quá trình kiểm tra của bạn.

[ZZ0000ZZ]

.. _recheckstablebroken_bissbs:

* Bạn vừa xây dựng một kernel ổn định hay lâu dài? Và bạn có thể tái tạo
  sự hồi quy với nó? Sau đó, bạn nên kiểm tra cơ sở mã dòng chính mới nhất như
  à, bởi vì kết quả xác định lỗi phải được gửi cho nhà phát triển nào
  đến.

Để chuẩn bị cho bài kiểm tra đó, hãy kiểm tra dòng chính hiện tại ::

cd ~/linux/
    git switch --discard-changes --detach mainline/master

Bây giờ hãy sử dụng mã đã được kiểm tra để xây dựng và cài đặt kernel khác bằng cách sử dụng
  ra lệnh cho các bước trước đó đã được mô tả chi tiết hơn::

cp ~/kernel-config-working .config
    tạo olddefconfig
    tạo -j $(nproc --all)
    # * Kiểm tra xem dung lượng trống có đủ để chứa kernel khác hay không:
    df -h /boot/ /lib/modules/
    sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt
    make -s kernelrelease | tee -a ~/kernels-build
    khởi động lại

Xác nhận bạn đã khởi động kernel mà bạn định khởi động và kiểm tra xem nó có bị nhiễm độc không
  trạng thái::

tail -n 1 ~/kernels-build
    tên -r
    mèo /proc/sys/kernel/bị nhiễm độc

Bây giờ hãy xác minh xem kernel này có hiển thị sự cố không. Nếu có thì bạn cần
  để báo cáo lỗi cho các nhà phát triển chính; nếu không được thì báo cáo lên
  đội ổn định. Xem Tài liệu/admin-guide/reporting-issues.rst để biết chi tiết.

[ZZ0000ZZ]

Bạn có làm theo hướng dẫn này để xác minh xem mã có vấn đề không
hiện được các nhà phát triển nhân Linux hỗ trợ? Sau đó, bạn đã hoàn thành việc này
điểm. Nếu sau này bạn muốn xóa kernel bạn vừa tạo, hãy kiểm tra
ZZ0000ZZ.

Trong trường hợp bạn gặp phải hiện tượng hồi quy, hãy tiếp tục và thực hiện ít nhất đoạn tiếp theo
cũng vậy.

.. _introworkingcheck_bissbs:

Phân đoạn 2: kiểm tra xem hạt nhân bạn xây dựng có hoạt động tốt không
---------------------------------------------------

Trong trường hợp hồi quy, bây giờ bạn muốn đảm bảo tệp cấu hình được cắt bớt
bạn đã tạo các tác phẩm trước đó như mong đợi; một phần chia đôi với tệp .config
nếu không sẽ lãng phí thời gian. [ZZ0000ZZ]

.. _recheckworking_bissbs:

* Xây dựng biến thể hạt nhân 'đang hoạt động' của riêng bạn và kiểm tra xem tính năng đó có
  thoái lui hoạt động như mong đợi với nó.

Bắt đầu bằng cách kiểm tra các nguồn cho phiên bản được thiết lập trước đó dưới dạng
  'tốt' (một lần nữa được giả định là 6.0 ở đây)::

cd ~/linux/
    chuyển đổi git --discard-thay đổi --detach v6.0

Bây giờ hãy sử dụng mã đã kiểm tra để định cấu hình, xây dựng và cài đặt kernel khác
  bằng cách sử dụng các lệnh mà phần phụ trước đã giải thích chi tiết hơn::

cp ~/kernel-config-working .config
    tạo olddefconfig
    tạo -j $(nproc --all)
    # * Kiểm tra xem dung lượng trống có đủ để chứa kernel khác hay không:
    df -h /boot/ /lib/modules/
    sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt
    make -s kernelrelease | tee -a ~/kernels-build
    khởi động lại

Khi hệ thống khởi động, bạn có thể muốn xác minh lại một lần nữa rằng
  kernel bạn đã khởi động là kernel bạn vừa xây dựng::

tail -n 1 ~/kernels-build
    tên -r

Bây giờ hãy kiểm tra xem kernel này có hoạt động như mong đợi không; nếu không thì tham khảo tài liệu tham khảo
  phần để được hướng dẫn thêm.

[ZZ0000ZZ]

.. _introbisect_bissbs:

Đoạn 3: thực hiện chia đôi và xác nhận kết quả
--------------------------------------------------------

Với tất cả các công tác chuẩn bị và đề phòng đã được thực hiện, giờ đây bạn đã sẵn sàng
để bắt đầu phép chia. Điều này sẽ buộc bạn phải xây dựng khá nhiều hạt nhân -- thường là
khoảng 15 trong trường hợp bạn gặp phải tình trạng hồi quy khi cập nhật lên bộ truyện mới hơn
(nói từ 6.0.13 đến 6.1.5). Nhưng đừng lo lắng, do cấu trúc đã được cắt bớt
cấu hình được tạo trước đó hoạt động nhanh hơn nhiều so với nhiều người nghĩ:
nhìn chung, trung bình thường sẽ chỉ mất khoảng 10 đến 15 phút để biên dịch
mỗi hạt nhân trên máy x86 hàng hóa.

.. _bisectstart_bissbs:

* Bắt đầu chia đôi và cho Git biết về các phiên bản được thiết lập trước đó dưới dạng
  'tốt' (6.0 trong lệnh ví dụ sau) và 'xấu' (6.1.5)::

cd ~/linux/
    git chia đôi bắt đầu
    git chia đôi tốt v6.0
    git bisect xấu v6.1.5

[ZZ0000ZZ]

.. _bisectbuild_bissbs:

* Bây giờ hãy sử dụng mã Git đã kiểm tra để xây dựng, cài đặt và khởi động kernel bằng cách sử dụng
  các lệnh được giới thiệu trước đó::

cp ~/kernel-config-working .config
    tạo olddefconfig
    tạo -j $(nproc --all)
    # * Kiểm tra xem dung lượng trống có đủ để chứa kernel khác hay không:
    df -h /boot/ /lib/modules/
    sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt
    make -s kernelrelease | tee -a ~/kernels-build
    khởi động lại

Nếu vì lý do nào đó quá trình biên dịch không thành công, hãy chạy ZZ0000ZZ và khởi động lại
  thực hiện chồng lệnh ngay từ đầu.

Trong trường hợp bạn bỏ qua bước 'kiểm tra cơ sở mã mới nhất' trong hướng dẫn, hãy kiểm tra bước đó
  mô tả lý do tại sao 'df […]' và 'make -s kernelrelease [...]'
  các lệnh ở đây.

Lưu ý quan trọng: lệnh sau kể từ thời điểm này sẽ in bản phát hành
  số nhận dạng có thể trông kỳ lạ hoặc sai đối với bạn -- thực ra không phải vậy, vì nó
  hoàn toàn bình thường khi thấy các số nhận dạng phát hành như '6.0-rc1-local-gcafec0cacaca0'
  ví dụ: nếu bạn chia đôi giữa phiên bản 6.1 và 6.2.

[ZZ0000ZZ]

.. _bisecttest_bissbs:

* Bây giờ hãy kiểm tra xem tính năng đã hồi quy có hoạt động trong kernel bạn vừa tạo hay không.

Bạn có thể muốn bắt đầu lại bằng cách đảm bảo kernel bạn đã khởi động là kernel
  bạn vừa xây dựng::

cd ~/linux/
    tail -n 1 ~/kernels-build
    tên -r

Bây giờ hãy xác minh xem tính năng hồi quy có hoạt động tại điểm chia đôi hạt nhân này hay không.
  Nếu có, hãy chạy cái này::

git chia đôi tốt

Nếu không, hãy chạy cái này ::

git chia đôi xấu

Hãy chắc chắn về những gì bạn nói với Git, vì chỉ sai một lần sẽ gửi đi
  phần còn lại của phần chia đôi hoàn toàn lệch hướng.

Trong khi quá trình chia đôi đang diễn ra, Git sẽ sử dụng thông tin bạn cung cấp để
  tìm và kiểm tra một điểm chia đôi khác để bạn kiểm tra. Trong khi làm như vậy, nó
  sẽ in nội dung như 'Chia đôi: còn lại 675 bản sửa đổi để kiểm tra sau này
  (khoảng 10 bước)' để cho biết dự kiến sẽ có bao nhiêu thay đổi nữa
  đã thử nghiệm. Bây giờ hãy xây dựng và cài đặt một kernel khác bằng cách sử dụng hướng dẫn từ
  bước trước đó; sau đó làm theo hướng dẫn ở bước này một lần nữa.

Lặp lại điều này nhiều lần cho đến khi bạn hoàn thành việc chia đôi - trường hợp đó là như vậy
  khi Git sau khi gắn thẻ một thay đổi là 'tốt' hoặc 'xấu' sẽ in nội dung như
  'cafecaca0c0dacafecaca0c0dacafecaca0c0da là cam kết xấu đầu tiên'; đúng
  sau đó nó sẽ hiển thị một số chi tiết về thủ phạm bao gồm cả bản vá
  mô tả sự thay đổi. Cái sau có thể lấp đầy màn hình terminal của bạn, vì vậy bạn
  có thể cần phải cuộn lên để xem thông báo đề cập đến thủ phạm;
  cách khác, hãy chạy ZZ0000ZZ.

[ZZ0000ZZ]

.. _bisectlog_bissbs:

* Lưu trữ nhật ký chia đôi của Git và tệp .config hiện tại ở nơi an toàn trước đó
  yêu cầu Git đặt lại nguồn về trạng thái trước khi chia đôi ::

cd ~/linux/
    git nhật ký chia đôi > ~/log-log
    cp .config ~/bisection-config-thủ phạm
    thiết lập lại git chia đôi

[ZZ0000ZZ]

.. _revert_bissbs:

* Hãy thử đưa thủ phạm lên đầu dòng chính mới nhất để xem liệu điều này có khắc phục được sự cố của bạn không
  hồi quy.

Đây là tùy chọn vì nó có thể không thể hoặc khó nhận ra. Cái trước là
  trường hợp, nếu phép chia đôi xác định cam kết hợp nhất là thủ phạm; cái
  điều sau xảy ra nếu những thay đổi khác phụ thuộc vào thủ phạm. Nhưng nếu quay lại
  thành công, thì đáng để xây dựng một hạt nhân khác, vì nó xác nhận kết quả của
  một sự chia đôi, có thể dễ dàng chuyển hướng; hơn nữa nó sẽ cho phép kernel
  các nhà phát triển biết liệu họ có thể giải quyết hồi quy bằng cách hoàn nguyên nhanh hay không.

Bắt đầu bằng cách kiểm tra cơ sở mã mới nhất tùy thuộc vào phạm vi bạn đã chia đôi:

* Bạn có gặp phải hiện tượng hồi quy trong một chuỗi ổn định/dài hạn không (ví dụ giữa
    6.0.13 và 6.0.15) không xảy ra trong dòng chính? Sau đó kiểm tra
    cơ sở mã mới nhất cho loạt phim bị ảnh hưởng như thế này::

git tìm nạp ổn định
      chuyển đổi git --discard-changes --detach linux-6.0.y

* Trong tất cả các trường hợp khác, hãy xem dòng chính mới nhất::

git tìm nạp dòng chính
      git switch --discard-changes --detach mainline/master

Nếu bạn chia đôi một hồi quy trong một chuỗi ổn định/dài hạn cũng
    xảy ra trong dòng chính, còn một việc nữa phải làm: tra cứu dòng chính
    cam kết-id. Để làm như vậy, hãy sử dụng lệnh như ZZ0000ZZ để
    xem mô tả bản vá của thủ phạm. Sẽ có một đường gần
    phần trên trông giống như 'commit cafec0cacaca0 ngược dòng.' hoặc
    'Cam kết ngược dòng cafec0cacaca0'; sử dụng id cam kết đó trong lệnh tiếp theo
    và không phải là người bị chia đôi đổ lỗi.

Bây giờ hãy thử hoàn nguyên thủ phạm bằng cách chỉ định id cam kết của nó::

git hoàn nguyên --no-chỉnh sửa cafec0cacaca0

Nếu thất bại, hãy từ bỏ việc cố gắng và chuyển sang bước tiếp theo; nếu nó hoạt động,
  điều chỉnh thẻ để thuận tiện cho việc nhận dạng và ngăn ngừa vô tình
  ghi đè kernel khác::

cp ~/kernel-config-working .config
    ./scripts/config --set-str CONFIG_LOCALVERSION '-local-cafec0cacaca0-reverted'

Xây dựng kernel bằng chuỗi lệnh quen thuộc mà không cần sao chép
  .config cơ sở trên::

tạo olddefconfig &&
    tạo -j $(nproc --all)
    # * Kiểm tra xem dung lượng trống có đủ để chứa kernel khác hay không:
    df -h /boot/ /lib/modules/
    sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt
    make -s kernelrelease | tee -a ~/kernels-build
    khởi động lại

Bây giờ hãy kiểm tra lần cuối xem tính năng giúp bạn thực hiện phép chia đôi có hoạt động không
  với kernel đó: nếu mọi thứ diễn ra tốt đẹp, nó sẽ không hiển thị hồi quy.

[ZZ0000ZZ]

.. _introclosure_bissbs:

Công việc bổ sung: dọn dẹp trong và sau khi chia đôi
-----------------------------------------------------------

Trong và sau khi làm theo hướng dẫn này, bạn có thể muốn hoặc cần xóa một số
hạt nhân bạn đã cài đặt: nếu không thì menu khởi động sẽ trở nên khó hiểu hoặc
không gian có thể hết.

.. _makeroom_bissbs:

* Để gỡ bỏ một trong các kernel bạn đã cài đặt, hãy tra cứu 'kernelrelease' của nó
  định danh. Hướng dẫn này lưu trữ chúng trong '~/kernels-build', nhưng sau đây
  lệnh cũng sẽ in chúng ::

ls -ltr /lib/mô-đun/ZZ0000ZZ

Trong hầu hết các trường hợp, bạn muốn loại bỏ các hạt nhân cũ nhất được xây dựng trong quá trình
  chia đôi thực tế (ví dụ: phân đoạn 3 của hướng dẫn này). Hai cái bạn đã tạo
  trước (ví dụ: để kiểm tra cơ sở mã mới nhất và phiên bản được xem xét
  'tốt') có thể hữu ích để xác minh điều gì đó sau này -- do đó tốt hơn hãy giữ chúng
  xung quanh, trừ khi bạn thực sự thiếu dung lượng lưu trữ.

Để loại bỏ các mô-đun của kernel bằng mã định danh kernelrelease
  'ZZ0000ZZ', hãy bắt đầu bằng cách xóa thư mục chứa nó
  mô-đun::

sudo rm -rf /lib/modules/6.0-rc1-local-gcafec0cacaca0

  Afterwards try the following command::

sudo kernel-install -v xóa 6.0-rc1-local-gcafec0cacaca0

Trên một số bản phân phối, thao tác này sẽ xóa tất cả các tệp kernel khác đã được cài đặt
  đồng thời xóa mục nhập của kernel khỏi menu khởi động. Nhưng trên một số
  bản phân phối kernel-install không tồn tại hoặc để lại các mục nhập bộ nạp khởi động hoặc
  hình ảnh hạt nhân và các tập tin liên quan phía sau; trong trường hợp đó hãy loại bỏ chúng như mô tả
  ở phần tham khảo.

[ZZ0000ZZ]

.. _finishingtouch_bissbs:

* Khi bạn đã hoàn thành việc chia đôi, đừng ngay lập tức loại bỏ bất cứ thứ gì bạn
  hãy thiết lập lại vì bạn có thể cần lại một số thứ. Điều gì là an toàn để loại bỏ phụ thuộc
  về kết quả của phép chia:

* Ban đầu bạn có thể tái tạo hồi quy bằng cơ sở mã mới nhất và
    sau khi chia đôi đã có thể khắc phục vấn đề bằng cách hoàn nguyên thủ phạm trên
    đứng đầu cơ sở mã mới nhất? Sau đó, bạn muốn giữ hai hạt nhân đó xung quanh
    trong một thời gian, nhưng hãy xóa tất cả những thứ khác một cách an toàn bằng '-local' trong bản phát hành
    định danh.

* Việc chia đôi có kết thúc bằng một cam kết hợp nhất hay có vẻ đáng nghi ngờ đối với người khác
    lý do? Sau đó, bạn muốn giữ càng nhiều hạt nhân càng tốt trong một vài
    ngày: rất có thể bạn sẽ được yêu cầu kiểm tra lại điều gì đó.

* Trong các trường hợp khác, có lẽ nên giữ lại các hạt nhân sau
    trong một thời gian: cái được xây dựng từ cơ sở mã mới nhất, cái được tạo từ
    phiên bản được coi là 'tốt' và ba hoặc bốn phiên bản cuối cùng bạn đã biên soạn
    trong quá trình chia đôi thực tế.

[ZZ0000ZZ]

.. _introoptional_bissbs:

Tùy chọn: hoàn nguyên thử nghiệm, bản vá hoặc phiên bản mới hơn
--------------------------------------------------

Trong khi hoặc sau khi báo cáo lỗi, bạn có thể muốn hoặc có khả năng sẽ được yêu cầu
hoàn nguyên thử nghiệm, gỡ lỗi, sửa lỗi được đề xuất hoặc các phiên bản khác. Trong trường hợp đó
làm theo những hướng dẫn này.

* Cập nhật bản sao Git của bạn và kiểm tra mã mới nhất.

* Trong trường hợp bạn muốn kiểm tra dòng chính, hãy tìm nạp những thay đổi mới nhất của nó trước khi kiểm tra
    mã của nó đã hết::

git tìm nạp dòng chính
      git switch --discard-changes --detach mainline/master

* Trong trường hợp bạn muốn kiểm tra kernel ổn định hoặc lâu dài, trước tiên hãy thêm nhánh
    giữ bộ truyện bạn quan tâm (trong ví dụ 6.2), trừ khi bạn
    đã làm như vậy trước đó::

git remote set-branches --add ổn định linux-6.2.y

Sau đó tìm nạp những thay đổi mới nhất và kiểm tra phiên bản mới nhất từ
    loạt::

git tìm nạp ổn định
      chuyển đổi git --discard-changes --detach ổn định/linux-6.2.y

* Sao chép cấu hình xây dựng kernel của bạn qua::

cp ~/kernel-config-working .config

* Bước tiếp theo của bạn phụ thuộc vào những gì bạn muốn làm:

* Trong trường hợp bạn chỉ muốn kiểm tra cơ sở mã mới nhất, hãy chuyển sang bước tiếp theo,
    bạn đã sẵn sàng rồi.

* Trong trường hợp bạn muốn kiểm tra xem việc hoàn nguyên có khắc phục được sự cố hay không, hãy hoàn nguyên một hoặc nhiều lần
    thay đổi bằng cách chỉ định id cam kết của họ ::

git hoàn nguyên --no-chỉnh sửa cafec0cacaca0

Bây giờ hãy đặt cho hạt nhân đó một thẻ đặc biệt để tạo điều kiện cho việc nhận dạng và
    ngăn chặn việc vô tình ghi đè lên kernel khác::

./scripts/config --set-str CONFIG_LOCALVERSION '-local-cafec0cacaca0-reverted'

* Trong trường hợp bạn muốn kiểm tra một bản vá, hãy lưu bản vá đó vào một tệp như
    '/tmp/foobars-proposes-fix-v1.patch' và áp dụng nó như thế này ::

git áp dụng /tmp/foobars-proposes-fix-v1.patch

Trong trường hợp có nhiều bản vá, hãy lặp lại bước này với các bản vá khác.

Bây giờ hãy đặt cho hạt nhân đó một thẻ đặc biệt để tạo điều kiện cho việc nhận dạng và
    ngăn chặn việc vô tình ghi đè lên kernel khác::

./scripts/config --set-str CONFIG_LOCALVERSION '-local-foobars-fix-v1'

* Xây dựng kernel bằng các lệnh quen thuộc mà không cần sao chép kernel
  xây dựng lại cấu hình, vì điều đó đã được xử lý rồi ::

tạo olddefconfig &&
    tạo -j $(nproc --all)
    # * Kiểm tra xem dung lượng trống có đủ để chứa kernel khác hay không:
    df -h /boot/ /lib/modules/
    sudo tạo module_install
    lệnh -v installkernel && sudo thực hiện cài đặt
    make -s kernelrelease | tee -a ~/kernels-build
    khởi động lại

* Bây giờ hãy xác minh rằng bạn đã khởi động kernel mới được xây dựng và kiểm tra nó.

[ZZ0000ZZ]

.. _submit_improvements_vbbr:

Phần kết luận
----------

Bạn đã đi đến cuối phần hướng dẫn từng bước.

Bạn có gặp rắc rối khi làm theo hướng dẫn từng bước không được giải thích rõ ràng không?
phần tham khảo dưới đây? Bạn có phát hiện ra lỗi không? Hoặc bạn có ý tưởng nào về cách
cải thiện hướng dẫn?

Nếu bất kỳ điều nào trong số đó áp dụng, vui lòng cho nhà phát triển biết bằng cách gửi một ghi chú ngắn
hoặc một bản vá cho Thorsten Leemhuis <linux@leemhuis.info> trong khi lý tưởng nhất là CC
danh sách gửi thư tài liệu Linux công khai <linux-doc@vger.kernel.org>. Những phản hồi như vậy là
rất quan trọng để cải thiện văn bản này hơn nữa, điều này mang lại lợi ích cho mọi người, vì nó sẽ
cho phép nhiều người nắm vững nhiệm vụ được mô tả ở đây.


Phần tham khảo hướng dẫn từng bước
============================================

Phần này chứa thông tin bổ sung cho hầu hết các mục ở trên
hướng dẫn từng bước.

Chuẩn bị xây dựng hạt nhân của riêng bạn
------------------------------------------

ZZ0001ZZ
  [ZZ0000ZZ]

Các bước trong tất cả các phần sau của hướng dẫn này phụ thuộc vào những bước được mô tả ở đây.

[ZZ0000ZZ].

.. _backup_bisref:

Chuẩn bị cho trường hợp khẩn cấp
~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Hãy nhớ rằng, bạn đang làm việc với máy tính, đôi khi nó làm những việc không mong muốn.
-- đặc biệt nếu bạn mày mò với những phần quan trọng như nhân của một hệ điều hành
hệ thống. Đó là những gì bạn sắp làm trong quá trình này. Vì vậy, hãy chuẩn bị tốt hơn
cho một điều gì đó đi ngang, ngay cả khi điều đó không nên xảy ra.

[ZZ0000ZZ]

.. _vanilla_bisref:

Xóa mọi thứ liên quan đến mô-đun hạt nhân được bảo trì bên ngoài
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Xóa bỏ tất cả phần mềm phụ thuộc vào trình điều khiển hạt nhân được phát triển bên ngoài hoặc
  tự động xây dựng chúng.* [ZZ0000ZZ]

Các mô-đun hạt nhân được phát triển bên ngoài có thể dễ dàng gây rắc rối trong quá trình chia đôi.

Nhưng có một lý do quan trọng hơn khiến hướng dẫn này có bước này: hầu hết
các nhà phát triển kernel sẽ không quan tâm đến các báo cáo về sự hồi quy xảy ra với
hạt nhân sử dụng các mô-đun như vậy. Đó là bởi vì những hạt nhân như vậy không
được coi là 'vani' nữa, dưới dạng Documentation/admin-guide/reporting-issues.rst
giải thích chi tiết hơn.

[ZZ0000ZZ]

.. _secureboot_bisref:

Xử lý các kỹ thuật như Khởi động an toàn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Trên các nền tảng có 'Khởi động an toàn' hoặc các kỹ thuật tương tự, hãy chuẩn bị mọi thứ để
  đảm bảo hệ thống sẽ cho phép hạt nhân tự biên dịch của bạn khởi động sau.*
  [ZZ0000ZZ]

Nhiều hệ thống hiện đại chỉ cho phép một số hệ điều hành nhất định khởi động; đó là lý do tại sao
theo mặc định, họ từ chối khởi động các hạt nhân tự biên dịch.

Lý tưởng nhất là bạn giải quyết vấn đề này bằng cách làm cho nền tảng của bạn tin cậy vào các hạt nhân tự xây dựng của bạn
với sự giúp đỡ của một chứng chỉ. Cách thực hiện điều đó không được mô tả
ở đây, vì nó đòi hỏi nhiều bước khác nhau sẽ khiến văn bản đi quá xa so với
mục đích của nó; 'Tài liệu/admin-guide/module-signing.rst' và các trang web khác nhau
các bên đã giải thích mọi thứ cần thiết chi tiết hơn.

Tạm thời vô hiệu hóa các giải pháp như Khởi động an toàn là một cách khác để bạn tự thực hiện
Khởi động Linux. Trên các hệ thống x86 thông thường, có thể thực hiện việc này trong Cài đặt BIOS
tiện ích; các bước yêu cầu khác nhau rất nhiều giữa các máy và do đó không thể thực hiện được
được mô tả ở đây

Trên các bản phân phối Linux x86 chính thống, có tùy chọn thứ ba và phổ biến:
vô hiệu hóa tất cả các hạn chế Khởi động an toàn cho môi trường Linux của bạn. bạn có thể
bắt đầu quá trình này bằng cách chạy ZZ0000ZZ; điều này sẽ
yêu cầu bạn tạo mật khẩu dùng một lần để ghi lại một cách an toàn. bây giờ
khởi động lại; ngay sau khi BIOS của bạn thực hiện tất cả quá trình tự kiểm tra, bộ nạp khởi động Shim sẽ
hiển thị hộp màu xanh có thông báo 'Nhấn phím bất kỳ để thực hiện quản lý MOK'. đánh
một số phím trước khi đồng hồ đếm ngược hiển thị, phím này sẽ mở ra một menu. Chọn 'Thay đổi
Trạng thái khởi động an toàn'. 'MokManager' của Shim bây giờ sẽ yêu cầu bạn nhập ba
các ký tự được chọn ngẫu nhiên từ mật khẩu một lần được chỉ định trước đó. Một lần
bạn đã cung cấp chúng, hãy xác nhận rằng bạn thực sự muốn tắt xác thực.
Sau đó, cho phép MokManager khởi động lại máy.

[ZZ0000ZZ]

.. _bootworking_bisref:

Khởi động kernel cuối cùng đang hoạt động
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Khởi động vào kernel đang hoạt động cuối cùng và kiểm tra lại nhanh xem tính năng đó có
  hồi quy thực sự hoạt động.* [ZZ0000ZZ]

Điều này sẽ thực hiện các bước sau đó bao gồm việc tạo và cắt bớt cấu hình.
điều đúng đắn.

[ZZ0000ZZ]

.. _diskspace_bisref:

Yêu cầu về không gian
~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Những con số được đề cập chỉ là ước tính sơ bộ kèm theo một khoản phụ phí lớn
bên an toàn, vì vậy thường bạn sẽ cần ít hơn.

Nếu bạn có những hạn chế về không gian, hãy nhớ chú ý đến ZZ0000ZZ và ZZ0001ZZ của nó, vì việc tắt nó sẽ làm giảm lượng đĩa tiêu thụ
không gian khoảng vài gigabyte.

[ZZ0000ZZ]

.. _rangecheck_bisref:

Phạm vi chia đôi
~~~~~~~~~~~~~~~

*Xác định các phiên bản kernel được coi là 'tốt' và 'xấu' trong suốt quá trình này
  hướng dẫn.* [ZZ0000ZZ]

Việc thiết lập phạm vi cam kết cần kiểm tra hầu như rất đơn giản,
ngoại trừ khi xảy ra hồi quy khi chuyển từ bản phát hành ổn định
loạt này sang bản phát hành của loạt sau (ví dụ: từ 6.0.13 đến 6.1.5). Trong trường hợp đó
Git sẽ cần một chút nắm tay vì không có đường thẳng đi xuống.

Đó là bởi vì với việc phát hành dòng chính 6.0 được chuyển sang 6.1 trong khi
dòng ổn định 6.0.y phân nhánh sang một bên. Do đó về mặt lý thuyết là có thể
rằng vấn đề bạn gặp phải với 6.1.5 chỉ hoạt động trong 6.0.13 vì nó đã được khắc phục bằng một
cam kết đã được đưa vào một trong các bản phát hành 6.0.y, nhưng chưa bao giờ chạm tới dòng chính hoặc
Dòng 6.1.y. Rất may là điều đó thường không xảy ra do cách
người bảo trì ổn định/dài hạn duy trì mã. Do đó, khá an toàn khi cho rằng
6.0 là hạt nhân 'tốt'. Giả định đó dù sao cũng sẽ được kiểm tra, vì hạt nhân đó
sẽ được xây dựng và thử nghiệm trong phần '2' của hướng dẫn này; Git sẽ buộc bạn
cũng có thể làm điều này nếu bạn thử chia đôi giữa 6.0.13 và 6.1.15.

[ZZ0000ZZ]

.. _buildrequires_bisref:

Yêu cầu xây dựng cài đặt
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Hạt nhân khá độc lập, nhưng bên cạnh các công cụ như trình biên dịch, bạn sẽ
đôi khi cần một vài thư viện để xây dựng một thư viện. Cách cài đặt mọi thứ cần thiết
phụ thuộc vào bản phân phối Linux của bạn và cấu hình kernel mà bạn đang sử dụng
sắp xây dựng.

Dưới đây là một vài ví dụ về những gì bạn thường cần trên một số sản phẩm phổ thông
phân phối:

* Arch Linux và các dẫn xuất::

sudo pacman -- Need -S bc binutils bison flex gcc git kmod libelf openssl \
      pahole perl zlib ncurses qt6-base

* Debian, Ubuntu và các phiên bản phái sinh::

sudo apt cài đặt bc binutils bison người lùn flex gcc git kmod libelf-dev \
      libssl-dev tạo openssl pahole Perl-base pkg-config zlib1g-dev \
      libncurses-dev qt6-base-dev g++

* Fedora và các dẫn xuất::

sudo dnf cài đặt binutils \
      /usr/bin/{bc,bison,flex,gcc,git,openssl,make,perl,pahole,rpmbuild} \
      /usr/include/{libelf.h,openssl/pkcs7.h,zlib.h,ncurses.h,qt6/QtGui/QAction}

* openSUSE và các dẫn xuất::

sudo zypper cài đặt bc binutils bison người lùn flex gcc git \
      kernel-install-tools libelf-devel tạo modutils openssl openssl-devel \
      Perl-base zlib-devel RPM-build ncurses-devel qt6-base-devel

Các lệnh này thường cài đặt một số gói nhưng không phải lúc nào cũng cần thiết. bạn
ví dụ: có thể muốn bỏ qua việc cài đặt các tiêu đề phát triển cho ncurses,
mà bạn sẽ chỉ cần trong trường hợp sau này bạn có thể muốn điều chỉnh bản dựng kernel
cấu hình bằng cách tạo mục tiêu 'menuconfig' hoặc 'nconfig'; tương tự như vậy bỏ qua
các tiêu đề của Qt6 nếu bạn không định điều chỉnh .config bằng 'xconfig'.

Ngoài ra, bạn có thể cần các thư viện bổ sung và tiêu đề phát triển của chúng
đối với các nhiệm vụ không được đề cập trong hướng dẫn này -- ví dụ: khi xây dựng các tiện ích từ
thư mục tools/ của kernel.

[ZZ0000ZZ]

.. _sources_bisref:

Tải xuống các nguồn bằng Git
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Hướng dẫn từng bước phác thảo cách tải xuống các nguồn Linux bằng cách sử dụng bản đầy đủ
Bản sao Git của kho lưu trữ chính của Linus. Không còn gì để nói về
điều đó -- nhưng có hai cách thay thế để truy xuất các nguồn có thể
làm việc tốt hơn cho bạn:

* Nếu bạn có kết nối Internet không ổn định, hãy cân nhắc
  ZZ0000ZZ.

* Nếu tải xuống toàn bộ kho lưu trữ sẽ mất quá nhiều thời gian hoặc yêu cầu quá
  nhiều dung lượng lưu trữ, hãy xem xét ZZ0000ZZ.

.. _sources_bundle_bisref:

Tải xuống các nguồn chính của Linux bằng cách sử dụng gói
"""""""""""""""""""""""""""""""""""""""""""""""""

Sử dụng các lệnh sau để truy xuất các nguồn chính của Linux bằng cách sử dụng
bó::

quên -c \
      ZZ0000ZZ
    git clone --no-checkout clone.bundle ~/linux/
    cd ~/linux/
    git từ xa loại bỏ nguồn gốc
    git từ xa thêm dòng chính \
      ZZ0001ZZ
    git tìm nạp dòng chính
    git remote add -t master ổn định \
      ZZ0002ZZ

Trường hợp lệnh 'wget' bị lỗi thì chỉ cần thực hiện lại là nó sẽ nhận ra đâu
nó bỏ đi.

[ZZ0000ZZ]
[ZZ0001ZZ]

.. _sources_shallow_bisref:

Tải xuống các nguồn chính của Linux bằng cách sử dụng bản sao nông
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đầu tiên, thực hiện lệnh sau để truy xuất cơ sở mã dòng chính mới nhất ::

git clone -o mainline --no-checkout --deep 1 -b master \
      ZZ0000ZZ ~/linux/
    cd ~/linux/
    git remote add -t master ổn định \
      ZZ0001ZZ

Bây giờ hãy đào sâu lịch sử bản sao của bạn về phiên bản tiền nhiệm thứ hai của dòng chính
phát hành phiên bản 'tốt' của bạn. Trong trường hợp cái sau là 6.0 hoặc 6.0.13, thì 5.19 sẽ
là người tiền nhiệm đầu tiên và 5,18 là người thứ hai -- do đó làm sâu sắc thêm lịch sử
phiên bản đó::

git tìm nạp --shallow-exclude=v5.18 dòng chính

Sau đó thêm kho lưu trữ Git ổn định dưới dạng điều khiển từ xa và tất cả đều cần ổn định
các nhánh như được giải thích trong hướng dẫn từng bước.

Lưu ý, các dòng vô tính nông có một số đặc điểm riêng biệt:

* Đối với các đoạn chia đôi, lịch sử cần được đào sâu thêm một số phiên bản chính tuyến
  xa hơn mức cần thiết, như đã giải thích ở trên. Đó là bởi vì
  Nếu không thì Git sẽ không thể hoàn nguyên hoặc mô tả hầu hết các cam kết trong
  một phạm vi (giả sử là 6.1..6.2), vì chúng nội bộ dựa trên các hạt nhân trước đó
  bản phát hành (như 6.0-rc2 hoặc 5.19-rc3).

* Tài liệu này ở hầu hết các nơi sử dụng ZZ0000ZZ với ZZ0001ZZ
  để chỉ định phiên bản sớm nhất mà bạn quan tâm (hay nói chính xác hơn là phiên bản git của nó
  thẻ). Ngoài ra, bạn có thể sử dụng tham số ZZ0002ZZ để chỉ định
  ngày tuyệt đối (ví dụ ZZ0003ZZ) hoặc tương đối (ZZ0004ZZ)
  xác định độ sâu của lịch sử bạn muốn tải xuống. Khi sử dụng chúng trong khi
  chia đôi tuyến chính, đảm bảo khắc sâu lịch sử ít nhất 7 tháng trước
  việc phát hành bản phát hành dòng chính mà hạt nhân 'tốt' của bạn dựa trên đó.

* Được cảnh báo, khi đào sâu bản sao của bạn, bạn có thể gặp phải một lỗi như
  'gây tử vong: lỗi trong đối tượng: không cho phép cafecaca0c0dacafeca0c0dacafeca0c0da'.
  Trong trường hợp đó hãy chạy ZZ0000ZZ và thử lại.

[ZZ0000ZZ]
[ZZ0001ZZ]

.. _oldconfig_bisref:

Bắt đầu xác định cấu hình bản dựng cho kernel của bạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

*Lưu ý, đây là bước đầu tiên trong nhiều bước trong hướng dẫn này để tạo hoặc sửa đổi
xây dựng hiện vật. Các lệnh được sử dụng trong hướng dẫn này lưu trữ chúng ngay trong nguồn
cây để giữ cho mọi thứ đơn giản. Trong trường hợp bạn thích lưu trữ các tạo phẩm xây dựng
riêng biệt, tạo một thư mục như '~/linux-builddir/' và thêm tham số
ZZ0000ZZ để thực hiện cuộc gọi được sử dụng trong suốt hướng dẫn này. Bạn sẽ
cũng phải trỏ các lệnh khác vào đó -- trong số đó có các lệnh ZZ0001ZZ, lệnh này sẽ yêu cầu ZZ0002ZZ thực hiện
xác định cấu hình bản dựng phù hợp.*

Hai điều có thể dễ dàng xảy ra sai sót khi tạo tệp .config như đã khuyên:

* Mục tiêu oldconfig sẽ sử dụng tệp .config từ thư mục bản dựng của bạn, nếu
  một cái đã có sẵn ở đó (ví dụ: '~/linux/.config'). Điều đó hoàn toàn ổn nếu
  đó là những gì bạn dự định (xem bước tiếp theo), nhưng trong tất cả các trường hợp khác, bạn muốn
  xóa nó. Ví dụ, điều này rất quan trọng trong trường hợp bạn làm theo hướng dẫn này
  hơn nữa, nhưng do có vấn đề nên quay lại đây để làm lại cấu hình từ
  gãi.

* Đôi khi olddefconfig không thể định vị được tệp .config cho hoạt động của bạn
  kernel và sẽ sử dụng các giá trị mặc định, như được nêu ngắn gọn trong hướng dẫn. Trong trường hợp đó
  kiểm tra xem bản phân phối của bạn có gửi cấu hình ở đâu đó không và đặt thủ công
  nó ở đúng vị trí (ví dụ: '~/linux/.config') nếu có. Về phân phối
  nơi /proc/config.gz tồn tại, điều này có thể đạt được bằng lệnh này ::

zcat /proc/config.gz > .config

Sau khi bạn đặt nó ở đó, hãy chạy lại ZZ0000ZZ để điều chỉnh nó cho phù hợp.
  nhu cầu của kernel sắp được xây dựng.

Lưu ý, mục tiêu olddefconfig sẽ đặt mọi tùy chọn xây dựng không xác định thành
giá trị mặc định. Nếu bạn muốn đặt các tùy chọn cấu hình như vậy theo cách thủ công, hãy sử dụng
Thay vào đó là ZZ0000ZZ. Sau đó, với mỗi tùy chọn cấu hình không xác định, bạn
sẽ được hỏi cách tiến hành; trong trường hợp bạn không chắc chắn nên trả lời gì, chỉ cần nhấn
'enter' để áp dụng giá trị mặc định. Tuy nhiên, hãy lưu ý rằng đối với các phần chia đôi, bạn thường
muốn sử dụng các cài đặt mặc định, vì nếu không bạn có thể kích hoạt một tính năng mới
gây ra vấn đề trông giống như hồi quy (ví dụ do vấn đề bảo mật
hạn chế).

Đôi khi có những điều kỳ lạ xảy ra khi cố gắng sử dụng tệp cấu hình được chuẩn bị cho một tệp
kernel (giả sử là 6.1) trên bản phát hành dòng chính cũ hơn -- đặc biệt nếu nó cũ hơn nhiều
(nói 5,15). Đó là một trong những lý do tại sao bước trước trong hướng dẫn lại nói
bạn khởi động kernel nơi mọi thứ hoạt động. Nếu bạn thêm .config theo cách thủ công
do đó bạn muốn đảm bảo nó đến từ kernel đang hoạt động chứ không phải từ kernel
điều đó cho thấy sự hồi quy.

Trong trường hợp bạn muốn xây dựng kernel cho máy khác, hãy tìm bản dựng kernel của nó
cấu hình; thông thường ZZ0000ZZ sẽ in tên của nó. Sao chép
tệp đó vào máy xây dựng và lưu trữ dưới dạng ~/linux/.config; sau đó chạy
ZZ0001ZZ để điều chỉnh nó.

[ZZ0000ZZ]

.. _localmodconfig_bisref:

Cắt cấu hình bản dựng cho kernel của bạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Như đã giải thích ngắn gọn trong hướng dẫn từng bước: với localmodconfig nó
có thể dễ dàng xảy ra trường hợp các hạt nhân tự xây dựng của bạn sẽ thiếu các mô-đun cho các nhiệm vụ mà bạn
đã không thực hiện ít nhất một lần trước khi sử dụng mục tiêu này. Điều đó xảy ra
khi một tác vụ yêu cầu các mô-đun hạt nhân chỉ được tải tự động khi bạn thực thi
nó lần đầu tiên. Vì vậy, khi bạn chưa bao giờ thực hiện nhiệm vụ đó kể từ khi bắt đầu
kernel, các mô-đun sẽ không được tải - và từ quan điểm của localmodconfig
của chế độ xem trông không cần thiết, do đó vô hiệu hóa chúng để giảm số lượng mã
để được biên soạn.

Bạn có thể cố gắng tránh điều này bằng cách thực hiện các tác vụ thông thường thường sẽ tự động tải
các mô-đun hạt nhân bổ sung: khởi động VM, thiết lập kết nối VPN, gắn vòng lặp
CD/DVD ISO, gắn kết chia sẻ mạng (CIFS, NFS, ...) và kết nối tất cả các thiết bị bên ngoài
các thiết bị (key 2FA, tai nghe, webcam, ...) cũng như các thiết bị lưu trữ có tập tin
các hệ thống mà bạn không sử dụng (btrfs, ext4, FAT, NTFS, XFS, ...). Nhưng nó
thật khó để nghĩ ra mọi thứ có thể cần thiết -- ngay cả các nhà phát triển hạt nhân
thường quên điều này hay điều khác vào thời điểm này.

Đừng để rủi ro đó làm phiền bạn, đặc biệt khi biên dịch kernel chỉ dành cho
mục đích thử nghiệm: mọi thứ thường quan trọng sẽ ở đó. Và nếu bạn quên
một cái gì đó quan trọng bạn có thể bật một tính năng bị thiếu theo cách thủ công sau này và nhanh chóng
chạy lại các lệnh để biên dịch và cài đặt kernel có mọi thứ bạn
cần.

Nhưng nếu bạn dự định xây dựng và sử dụng các hạt nhân tự xây dựng thường xuyên, bạn có thể muốn
giảm rủi ro bằng cách ghi lại những mô-đun mà hệ thống của bạn tải trong quá trình
một vài tuần. Bạn có thể tự động hóa việc này với ZZ0001ZZ. Sau đó sử dụng ZZ0000ZZ để
trỏ localmodconfig vào danh sách các mô-đun modprobed-db được chú ý đang được sử dụng ::

vâng '' | tạo LSMOD='${HOME}'/.config/modprobed.db localmodconfig

Tham số đó cũng cho phép bạn xây dựng các hạt nhân đã được cắt bớt cho một máy khác trong
trường hợp bạn đã sao chép một .config phù hợp để sử dụng làm cơ sở (xem bước trước). chỉ
chạy ZZ0000ZZ trên hệ thống đó và sao chép tệp được tạo vào
thư mục chính của máy chủ xây dựng của bạn. Sau đó chạy các lệnh này thay vì lệnh
hướng dẫn từng bước đề cập::

vâng '' | tạo LSMOD=~/lsmod_foo-machine localmodconfig

[ZZ0000ZZ]

.. _tagging_bisref:

Gắn thẻ các hạt nhân sắp được xây dựng
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Đảm bảo tất cả các hạt nhân bạn sẽ xây dựng đều có thể được nhận dạng rõ ràng bằng cách sử dụng
  thẻ đặc biệt và mã nhận dạng phiên bản duy nhất.* [ZZ0000ZZ]

Điều này cho phép bạn phân biệt hạt nhân của bản phân phối với hạt nhân được tạo
trong quá trình này, vì tệp hoặc thư mục sau này sẽ chứa
'-local' trong tên; nó cũng giúp chọn đúng mục trong menu khởi động và
không làm mất dấu hạt nhân của bạn, vì số phiên bản của chúng trông hơi giống
bối rối trong quá trình chia đôi.

[ZZ0000ZZ]

.. _debugsymbols_bisref:

Quyết định bật hoặc tắt các biểu tượng gỡ lỗi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ [ZZ0000ZZ]

Việc có sẵn các biểu tượng gỡ lỗi có thể rất quan trọng khi hạt nhân của bạn ném một lỗi
'hoảng loạn', 'Rất tiếc', 'cảnh báo' hoặc 'BUG' sau khi chạy, khi đó bạn sẽ
có thể tìm thấy chính xác vị trí xảy ra sự cố trong mã. Nhưng
việc thu thập và nhúng thông tin gỡ lỗi cần thiết sẽ tốn thời gian và tiêu tốn
khá nhiều dung lượng: vào cuối năm 2022, các tạo phẩm xây dựng cho hạt nhân x86 điển hình
được cắt bớt bằng localmodconfig tiêu tốn khoảng 5 Gigabyte dung lượng khi gỡ lỗi
các ký hiệu, nhưng nhỏ hơn 1 khi chúng bị vô hiệu hóa. Hình ảnh hạt nhân thu được và
các mô-đun cũng lớn hơn, điều này làm tăng yêu cầu lưu trữ cho /boot/ và
lần tải.

Trong trường hợp bạn muốn có một hạt nhân nhỏ và không có khả năng giải mã dấu vết ngăn xếp sau này,
do đó bạn có thể muốn tắt các biểu tượng gỡ lỗi để tránh những nhược điểm đó. Nếu nó
sau này hóa ra bạn cần chúng, chỉ cần kích hoạt chúng như được hiển thị và xây dựng lại
hạt nhân.

Mặt khác, bạn chắc chắn muốn kích hoạt chúng cho quá trình này, nếu có
rất có thể sau này bạn cần giải mã dấu vết ngăn xếp. phần
'Giải mã thông báo lỗi' trong Tài liệu/admin-guide/reporting-issues.rst
giải thích quá trình này chi tiết hơn.

[ZZ0000ZZ]

.. _configmods_bisref:

Điều chỉnh cấu hình bản dựng
~~~~~~~~~~~~~~~~~~~~~~~~~~

*Kiểm tra xem bạn có muốn hoặc cần điều chỉnh một số cấu hình kernel khác không
  tùy chọn:*

Tùy thuộc vào nhu cầu của bạn, tại thời điểm này bạn có thể muốn hoặc phải điều chỉnh một số
tùy chọn cấu hình hạt nhân.

.. _configmods_distros_bisref:

Phân phối điều chỉnh cụ thể
"""""""""""""""""""""""""""

ZZ0001ZZ [ZZ0000ZZ]

Các phần sau đây giúp bạn tránh các sự cố xây dựng thường xảy ra
khi làm theo hướng dẫn này về một số phân phối hàng hóa.

ZZ0000ZZ

* Xóa tham chiếu cũ tới tệp chứng chỉ có thể khiến bản dựng của bạn bị lỗi
  thất bại::

./scripts/config --set-str SYSTEM_TRUSTED_KEYS ''

Ngoài ra, hãy tải xuống chứng chỉ cần thiết và thực hiện cấu hình đó
  tùy chọn trỏ đến nó, như ZZ0000ZZ
  -- hoặc tạo của riêng bạn, như được giải thích trong
  Tài liệu/admin-guide/module-signing.rst.

[ZZ0000ZZ]

.. _configmods_individual_bisref:

Điều chỉnh riêng lẻ
""""""""""""""""""""""

*Nếu bạn muốn tác động đến các khía cạnh khác của cấu hình, hãy làm như vậy
  ngay bây giờ.* [ZZ0000ZZ]

Tại thời điểm này, bạn có thể sử dụng lệnh như ZZ0000ZZ hoặc ZZ0001ZZ
để bật hoặc tắt một số tính năng nhất định bằng giao diện người dùng dựa trên văn bản; sử dụng
một tiện ích cấu hình đồ họa, thay vào đó hãy chạy ZZ0002ZZ. Cả hai người họ
yêu cầu các thư viện phát triển từ bộ công cụ mà họ dựa vào (ncurses
tương ứng là Qt5 hoặc Qt6); một thông báo lỗi sẽ cho bạn biết nếu có điều gì đó cần thiết
bị thiếu.

[ZZ0000ZZ]

.. _saveconfig_bisref:

Đặt file .config sang một bên
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Đặt .config bạn đã chuẩn bị sang một bên vì bạn muốn sao chép nó trở lại bản dựng
thư mục mọi lúc trong hướng dẫn này trước khi bạn bắt đầu xây dựng một thư mục khác
hạt nhân. Đó là vì việc qua lại giữa các phiên bản khác nhau có thể làm thay đổi
tập tin .config theo những cách kỳ lạ; đôi khi chúng gây ra tác dụng phụ có thể
nhầm lẫn việc kiểm tra hoặc trong một số trường hợp hiển thị kết quả chia đôi của bạn
vô nghĩa.

[ZZ0000ZZ]

.. _introlatestcheck_bisref:

Cố gắng tái tạo vấn đề với cơ sở mã mới nhất
-----------------------------------------------------

*Xác minh hồi quy không phải do một số thay đổi .config gây ra và kiểm tra xem nó có
  vẫn xảy ra với cơ sở mã mới nhất.* [ZZ0000ZZ]

Đối với một số độc giả, có vẻ như không cần thiết phải kiểm tra cơ sở mã mới nhất tại đây
điểm, đặc biệt nếu bạn đã làm điều đó với kernel do bạn chuẩn bị
nhà phân phối hoặc phải đối mặt với sự thoái lui trong một chuỗi ổn định/dài hạn. Nhưng đó là
rất khuyến khích vì những lý do sau:

* Bạn sẽ gặp phải bất kỳ vấn đề nào do thiết lập của mình gây ra trước khi thực sự bắt đầu
  một sự chia đôi. Điều đó sẽ làm cho việc phân biệt giữa 'cái này' dễ dàng hơn nhiều
  rất có thể là có vấn đề gì đó trong quá trình thiết lập của tôi' và 'cần bỏ qua thay đổi này
  trong quá trình chia đôi, vì các nguồn kernel ở giai đoạn đó chứa một phần không liên quan
  vấn đề khiến quá trình xây dựng hoặc khởi động không thành công'.

* Các bước này sẽ loại trừ trường hợp sự cố của bạn xảy ra do một số thay đổi trong
  xây dựng cấu hình giữa kernel 'đang hoạt động' và kernel 'bị hỏng'. Cái này dành cho
  Ví dụ có thể xảy ra khi nhà phân phối của bạn kích hoạt bảo mật bổ sung
  tính năng trong kernel mới hơn đã bị vô hiệu hóa hoặc chưa được hỗ trợ bởi
  hạt nhân cũ hơn. Tính năng bảo mật đó có thể cản trở điều gì đó mà bạn
  làm -- trong trường hợp đó vấn đề của bạn nhìn từ góc độ nhân Linux
  các nhà phát triển ngược dòng không phải là một sự hồi quy, vì
  Documentation/admin-guide/reporting-regressions.rst giải thích chi tiết hơn.
  Do đó, bạn sẽ lãng phí thời gian nếu cố gắng chia đôi điều này.

* Nếu nguyên nhân hồi quy của bạn đã được khắc phục trong dòng chính mới nhất
  codebase, bạn sẽ thực hiện phép chia đôi mà không mất gì. Điều này đúng đối với một
  hồi quy mà bạn gặp phải với bản phát hành ổn định/dài hạn, vì chúng là như vậy
  thường gây ra bởi các vấn đề trong các thay đổi chính đã được nhập lại -- trong đó
  trong trường hợp vấn đề sẽ phải được khắc phục trong tuyến chính trước. Có lẽ nó đã như vậy rồi
  đã sửa ở đó và bản sửa lỗi đang trong quá trình được chuyển ngược lại.

* Đối với các hồi quy trong một chuỗi ổn định/dài hạn, điều quan trọng hơn nữa là phải
  biết liệu sự cố có xảy ra riêng với bộ truyện đó hay cũng xảy ra trong dòng chính
  kernel, vì báo cáo cần được gửi cho những người khác nhau:

* Các hồi quy cụ thể cho chuỗi ổn định/dài hạn là của nhóm ổn định
    trách nhiệm; các nhà phát triển Linux chính thống có thể quan tâm hoặc có thể không quan tâm.

* Sự hồi quy cũng xảy ra trong dòng chính là điều xảy ra với Linux thông thường
    nhà phát triển và người bảo trì phải xử lý; đội ổn định không quan tâm
    và không cần phải tham gia vào báo cáo, họ chỉ cần được thông báo
    để quay lại bản sửa lỗi khi nó đã sẵn sàng.

Báo cáo của bạn có thể bị bỏ qua nếu bạn gửi nó tới nhầm bên -- và thậm chí
  khi bạn nhận được phản hồi, rất có thể các nhà phát triển sẽ yêu cầu bạn làm như vậy
  đánh giá xem đó là trường hợp nào trong hai trường hợp trước khi họ xem xét kỹ hơn.

[ZZ0000ZZ]

.. _checkoutmaster_bisref:

Kiểm tra cơ sở mã Linux mới nhất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Trong trường hợp sau này bạn muốn kiểm tra lại xem một cơ sở mã mới hơn có thể khắc phục được lỗi không
vấn đề, hãy nhớ chạy lệnh ZZ0000ZZ đó
một lần nữa được đề cập trước đó để cập nhật kho lưu trữ Git cục bộ của bạn.

[ZZ0000ZZ]

.. _build_bisref:

Xây dựng hạt nhân của bạn
~~~~~~~~~~~~~~~~~

*Xây dựng hình ảnh và các mô-đun của hạt nhân đầu tiên của bạn bằng tệp cấu hình
  bạn đã chuẩn bị.* [ZZ0000ZZ]

Rất nhiều lỗi có thể xảy ra ở giai đoạn này, nhưng những hướng dẫn bên dưới sẽ giúp bạn
chính bạn. Một tiểu mục khác giải thích cách đóng gói trực tiếp kernel của bạn dưới dạng
deb, vòng/phút hoặc tar.

Xử lý lỗi xây dựng
"""""""""""""""""""""""""

Khi xảy ra lỗi xây dựng, lỗi đó có thể do một số khía cạnh trong máy của bạn gây ra.
thiết lập thường có thể được sửa chữa nhanh chóng; những lần khác mặc dù vấn đề nằm ở
mã và chỉ có thể được sửa bởi nhà phát triển. Một cuộc kiểm tra chặt chẽ của
thông báo lỗi cùng với một số nghiên cứu trên internet thường sẽ cho bạn biết
đó là cái nào trong hai cái đó. Để thực hiện điều tra như vậy, hãy khởi động lại bản dựng
quá trình như thế này::

làm cho V=1

ZZ0000ZZ kích hoạt đầu ra chi tiết, có thể cần thiết để xem thực tế
lỗi. Để dễ phát hiện hơn, lệnh này cũng bỏ qua ZZ0001ZZ được sử dụng trước đó để sử dụng mọi lõi CPU trong hệ thống cho công việc -- nhưng
sự song song này cũng dẫn đến một số lộn xộn khi xảy ra lỗi.

Sau vài giây, quá trình xây dựng sẽ lại gặp lỗi. Bây giờ hãy thử
để tìm dòng quan trọng nhất mô tả vấn đề. Sau đó tìm kiếm trên mạng
phần quan trọng nhất và không chung chung của dòng đó (nói 4 đến 8 từ);
tránh hoặc xóa bất cứ thứ gì có vẻ dành riêng cho hệ thống từ xa, như tên người dùng của bạn
hoặc tên đường dẫn cục bộ như ZZ0000ZZ. Trước tiên hãy thử thường xuyên của bạn
công cụ tìm kiếm trên internet với chuỗi đó, sau đó tìm kiếm gửi thư nhân Linux
danh sách qua ZZ0001ZZ.

Điều này thường sẽ tìm thấy điều gì đó giải thích được điều gì sai; khá
thường thì một trong những cú truy cập cũng sẽ cung cấp giải pháp cho vấn đề của bạn. Nếu bạn
không tìm thấy bất cứ điều gì phù hợp với vấn đề của bạn, hãy thử lại từ một góc độ khác
bằng cách sửa đổi cụm từ tìm kiếm của bạn hoặc sử dụng một dòng khác từ thông báo lỗi.

Cuối cùng, hầu hết các vấn đề bạn gặp phải đều có thể đã gặp phải và
đã được người khác báo cáo rồi. Điều đó bao gồm các vấn đề mà nguyên nhân không phải do bạn
hệ thống, nhưng nằm trong mã. Nếu bạn gặp phải một trong số đó, bạn có thể tìm thấy
một giải pháp (ví dụ: một bản vá) hoặc cách giải quyết cho vấn đề của bạn.

Đóng gói kernel của bạn
""""""""""""""""""""""

Hướng dẫn từng bước sử dụng mục tiêu tạo mặc định (ví dụ: 'bzImage' và
'mô-đun' trên x86) để xây dựng hình ảnh và các mô-đun hạt nhân của bạn, sau này
các bước của hướng dẫn sau đó cài đặt. Thay vào đó bạn cũng có thể trực tiếp xây dựng mọi thứ
và trực tiếp đóng gói nó bằng cách sử dụng một trong các mục tiêu sau:

* ZZ0000ZZ để tạo gói gỡ lỗi

* ZZ0000ZZ để tạo gói vòng/phút

* ZZ0000ZZ để tạo tarball nén bz2

Đây chỉ là một lựa chọn các mục tiêu có sẵn cho mục đích này, xem
ZZ0000ZZ cho người khác. Bạn cũng có thể sử dụng các mục tiêu này sau khi chạy
ZZ0001ZZ, vì họ sẽ tiếp thu mọi thứ đã được xây dựng.

Nếu bạn sử dụng các mục tiêu để tạo các gói gỡ lỗi hoặc vòng/phút, hãy bỏ qua
hướng dẫn từng bước về cách cài đặt và gỡ bỏ kernel của bạn;
thay vào đó hãy cài đặt và gỡ bỏ các gói bằng tiện ích gói dành cho định dạng
(ví dụ: dpkg và vòng/phút) hoặc tiện ích quản lý gói được xây dựng dựa trên chúng (apt,
năng khiếu, dnf/yum, zypper, ...). Xin lưu ý rằng các gói được tạo bằng cách sử dụng
hai mục tiêu này được thiết kế để hoạt động trên nhiều bản phân phối khác nhau bằng cách sử dụng
những định dạng đó, do đó đôi khi chúng sẽ hoạt động khác với định dạng của bạn
gói kernel của bản phân phối.

[ZZ0000ZZ]

.. _install_bisref:

Put the kernel in place
~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ [ZZ0000ZZ]

Những việc bạn cần làm sau khi thực hiện lệnh trong hướng dẫn từng bước
phụ thuộc vào sự tồn tại và triển khai ZZ0000ZZ
thực thi được trên bản phân phối của bạn.

Nếu tìm thấy kernel cài đặt, hệ thống xây dựng của kernel sẽ ủy quyền thực tế
cài đặt hình ảnh hạt nhân của bạn vào tệp thực thi này, sau đó thực hiện một số
hoặc tất cả các nhiệm vụ này:

* Trên hầu hết các bản phân phối Linux, kernel cài đặt sẽ lưu trữ kernel của bạn
  hình ảnh trong /boot/, thường là '/boot/vmlinuz-<kernelrelease_id>'; thường thì nó sẽ
  đặt 'System.map-<kernelrelease_id>' bên cạnh nó.

* Trên hầu hết các bản phân phối, hạt nhân cài đặt sẽ tạo ra 'initramfs'
  (đôi khi còn được gọi là 'initrd'), thường được lưu dưới dạng
  '/boot/initramfs-<kernelrelease_id>.img' hoặc
  '/boot/initrd-<kernelrelease_id>'. Phân phối hàng hóa dựa vào tệp này
  để khởi động, do đó hãy đảm bảo thực hiện mục tiêu 'module_install' trước tiên,
  làm trình tạo initramfs của bản phân phối của bạn nếu không sẽ không thể tìm thấy
  các mô-đun đi vào hình ảnh.

* Trên một số bản phân phối, installkernel sẽ thêm một mục cho kernel của bạn
  vào cấu hình bootloader của bạn.

Bạn phải tự mình thực hiện một số hoặc tất cả các công việc đó, nếu bạn
bản phân phối thiếu tập lệnh hạt nhân cài đặt hoặc chỉ xử lý một phần của chúng.
Tham khảo tài liệu của bản phân phối để biết chi tiết. Nếu nghi ngờ, hãy cài đặt
hạt nhân theo cách thủ công::

cài đặt sudo -m 0600 $(make -s image_name) /boot/vmlinuz-$(make -s kernelrelease)
   cài đặt sudo -m 0600 System.map /boot/System.map-$(make -s kernelrelease)

Bây giờ hãy tạo initramfs của bạn bằng cách sử dụng các công cụ mà bản phân phối của bạn cung cấp cho việc này
quá trình. Sau đó thêm kernel của bạn vào cấu hình bootloader và khởi động lại.

[ZZ0000ZZ]

.. _storagespace_bisref:

Yêu cầu lưu trữ cho mỗi hạt nhân
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Kiểm tra dung lượng lưu trữ của kernel, các mô-đun của nó và các tệp liên quan khác
  giống như tiêu thụ initramfs.* [ZZ0000ZZ]

Các hạt nhân được xây dựng trong quá trình chia đôi tiêu tốn khá nhiều dung lượng trong /boot/ và
/lib/modules/, đặc biệt nếu bạn bật biểu tượng gỡ lỗi. Điều đó làm cho nó dễ dàng
lấp đầy các tập trong quá trình chia đôi -- và do đó, ngay cả các hạt nhân đã từng
làm việc trước đó có thể không khởi động được. Để ngăn chặn điều đó bạn sẽ cần phải biết bao nhiêu
khoảng trống mà mỗi kernel được cài đặt thường yêu cầu.

Lưu ý, hầu hết các trường hợp mẫu '/boot/ZZ0000ZZ' được sử dụng trong
hướng dẫn sẽ khớp với tất cả các tệp cần thiết để khởi động kernel của bạn -- nhưng cả tệp
đường dẫn cũng như sơ đồ đặt tên là bắt buộc. Do đó, trên một số bản phân phối, bạn sẽ
cần phải tìm ở những nơi khác nhau.

[ZZ0000ZZ]

.. _tainted_bisref:

Kiểm tra xem kernel mới xây dựng của bạn có bị coi là 'bị nhiễm độc' không
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Linux tự coi mình là bị nhiễm độc khi điều gì đó xảy ra có khả năng dẫn đến
các lỗi tiếp theo trông hoàn toàn không liên quan. Đó là lý do tại sao các nhà phát triển có thể
phớt lờ hoặc phản ứng nhẹ với các báo cáo về hạt nhân bị nhiễm độc -- tất nhiên là trừ khi
kernel đặt cờ ngay khi xảy ra lỗi được báo cáo.

Đó là lý do tại sao bạn muốn kiểm tra lý do tại sao hạt nhân bị nhiễm độc như được giải thích trong
Tài liệu/admin-guide/tainted-kernels.rst; làm như vậy cũng là việc của riêng bạn
quan tâm, vì nếu không thì thử nghiệm của bạn có thể bị sai sót.

[ZZ0000ZZ]

.. _recheckbroken_bisref:

Kiểm tra kernel được xây dựng từ cơ sở mã dòng chính gần đây
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Có một số lý do khiến lỗi hoặc hồi quy của bạn có thể không hiển thị cùng với
hạt nhân bạn đã xây dựng từ cơ sở mã mới nhất. Đây là những thường xuyên nhất:

* Lỗi đã được sửa trong khi đó.

* Điều bạn nghi ngờ là hồi quy là do thay đổi trong bản dựng
  cấu hình mà nhà cung cấp kernel của bạn thực hiện.

* Vấn đề của bạn có thể là tình trạng chạy đua không hiển thị cùng với kernel của bạn;
  cấu hình bản dựng đã được cắt bớt, một cài đặt khác cho các biểu tượng gỡ lỗi,
  trình biên dịch được sử dụng và nhiều thứ khác có thể gây ra điều này.

* Trong trường hợp bạn gặp phải hiện tượng hồi quy với hạt nhân ổn định/dài hạn thì có thể
  là một vấn đề dành riêng cho chuỗi đó; bước tiếp theo trong hướng dẫn này sẽ
  kiểm tra cái này

[ZZ0000ZZ]

.. _recheckstablebroken_bisref:

Kiểm tra kernel được xây dựng từ cơ sở mã ổn định/dài hạn mới nhất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Bạn có đang gặp phải tình trạng thoái lui trong bản phát hành ổn định/dài hạn nhưng không thể
  tái tạo nó bằng kernel bạn vừa xây dựng bằng các nguồn chính mới nhất?
  Sau đó kiểm tra xem cơ sở mã mới nhất cho chuỗi cụ thể đã khắc phục được chưa
  vấn đề.* [ZZ0000ZZ]

Nếu kernel này cũng không hiển thị hồi quy thì rất có thể không cần
cho một sự chia đôi.

[ZZ0000ZZ]

.. _introworkingcheck_bisref:

Đảm bảo phiên bản “tốt” thực sự hoạt động tốt
------------------------------------------------

ZZ0001ZZ
  [ZZ0000ZZ]

Phần này sẽ thiết lập lại một cơ sở làm việc đã biết. Bỏ qua nó có thể là
hấp dẫn, nhưng thường là một ý tưởng tồi, vì nó thực hiện điều gì đó quan trọng:

Nó sẽ đảm bảo tệp .config bạn đã chuẩn bị trước đó thực sự hoạt động như mong đợi.
Đó là lợi ích của riêng bạn, vì việc cắt bớt cấu hình không phải là điều dễ dàng --
và trước đây bạn có thể đang xây dựng và thử nghiệm mười hạt nhân trở lên mà không làm gì cả
bắt đầu nghi ngờ có điều gì đó không ổn với cấu hình bản dựng.

Chỉ riêng điều đó thôi cũng đủ lý do để bạn dành thời gian cho việc này, nhưng không phải là lý do duy nhất.

Nhiều độc giả của hướng dẫn này thường chạy các kernel đã được vá, sử dụng tiện ích bổ sung
mô-đun, hoặc cả hai. Do đó, những hạt nhân đó không được coi là 'vani' -- do đó
có thể thứ bị thoái lui có thể không bao giờ hoạt động trong vanilla
bản dựng của phiên bản 'tốt' ngay từ đầu.

Có lý do thứ ba cho những người nhận thấy sự hồi quy giữa
hạt nhân ổn định/dài hạn của các dòng khác nhau (ví dụ: 6.0.13..6.1.5): nó sẽ
đảm bảo phiên bản kernel mà bạn cho là 'tốt' trước đó trong quy trình (ví dụ:
6.0) thực sự đang hoạt động.

[ZZ0000ZZ]

.. _recheckworking_bisref:

Xây dựng phiên bản hạt nhân 'tốt' của riêng bạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Xây dựng biến thể hạt nhân đang hoạt động của riêng bạn và kiểm tra xem tính năng đó có
  hồi quy hoạt động như mong đợi với nó.* [ZZ0000ZZ]

Trong trường hợp tính năng bị lỗi với hạt nhân mới hơn không hoạt động với hạt nhân đầu tiên của bạn
kernel tự build, tìm và giải quyết nguyên nhân trước khi tiếp tục. có một
vô số lý do tại sao điều này có thể xảy ra. Một số ý tưởng nơi để tìm:

* Kiểm tra trạng thái vết bẩn và đầu ra của ZZ0000ZZ, có thể có gì đó không liên quan
  đã sai.

* Có lẽ localmodconfig đã làm điều gì đó kỳ quặc và vô hiệu hóa mô-đun cần thiết để
  kiểm tra tính năng? Sau đó, bạn có thể muốn tạo lại tệp .config dựa trên
  một từ hạt nhân hoạt động cuối cùng và bỏ qua việc cắt bớt nó; vô hiệu hóa thủ công
  một số tính năng trong .config cũng có thể hoạt động để giảm thời gian xây dựng.

* Có thể đó không phải là sự hồi quy của kernel mà là do sự cố ngẫu nhiên nào đó gây ra,
  initramfs bị hỏng (còn được gọi là initrd), tệp chương trình cơ sở mới hoặc bản cập nhật
  phần mềm người dùng?

* Có thể đó là một tính năng được thêm vào nhân của nhà phân phối của bạn mà vanilla Linux
  tại thời điểm đó không bao giờ được hỗ trợ?

Lưu ý, nếu bạn tìm thấy và khắc phục được sự cố với file .config thì bạn muốn sử dụng nó
để xây dựng một hạt nhân khác từ cơ sở mã mới nhất, như các thử nghiệm trước đó của bạn với
dòng chính và phiên bản mới nhất từ loạt ổn định/dài hạn bị ảnh hưởng là
rất có thể là thiếu sót.

[ZZ0000ZZ]

Thực hiện chia đôi và xác nhận kết quả
-------------------------------------------

*Với tất cả các công tác chuẩn bị và đề phòng đã được thực hiện, giờ đây bạn đã có thể
  sẵn sàng bắt đầu chia đôi.* [ZZ0000ZZ]

Các bước trong phân đoạn này thực hiện và xác nhận phép chia đôi.

[ZZ0000ZZ].

.. _bisectstart_bisref:

Bắt đầu chia đôi
~~~~~~~~~~~~~~~~~~~

*Bắt đầu chia đôi và cho Git biết về các phiên bản được thiết lập trước đó dưới dạng
  'tốt' và 'xấu'.* [ZZ0000ZZ]

Điều này sẽ bắt đầu quá trình chia đôi; lệnh cuối cùng sẽ tạo ra Git
kiểm tra vòng cam kết nằm giữa những thay đổi 'tốt' và 'xấu'
để bạn kiểm tra.

[ZZ0000ZZ]

.. _bisectbuild_bisref:

Xây dựng hạt nhân từ điểm chia đôi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Xây dựng, cài đặt và khởi động kernel từ mã Git đã kiểm tra bằng cách sử dụng
  các lệnh tương tự bạn đã sử dụng trước đó.* [ZZ0000ZZ]

Có hai điều đáng lưu ý ở đây:

* Đôi khi việc xây dựng kernel sẽ bị lỗi hoặc có thể không khởi động được do một số lỗi
  vấn đề trong mã tại điểm chia đôi. Trong trường hợp đó hãy chạy lệnh này ::

bỏ qua git chia đôi

Sau đó, Git sẽ kiểm tra một cam kết khác gần đó mà nếu may mắn thì sẽ
  làm việc tốt hơn. Sau đó khởi động lại thực hiện bước này.

* Những số nhận dạng phiên bản trông hơi kỳ quặc đó có thể xảy ra trong quá trình chia đôi,
  bởi vì các hệ thống con nhân Linux chuẩn bị các thay đổi của chúng cho dòng chính mới
  bản phát hành (giả sử là 6.2) trước khi phiên bản tiền nhiệm của nó (ví dụ: 6.1) kết thúc. Vì thế họ
  căn cứ vào một điểm sớm hơn một chút như 6.1-rc1 hoặc thậm chí 6.0 -- và sau đó
  được hợp nhất trong phiên bản 6.2 mà không cần khởi động lại cũng như không nén chúng sau khi hết phiên bản 6.1. Cái này
  dẫn đến những số nhận dạng phiên bản trông hơi kỳ lạ xuất hiện trong quá trình
  sự chia đôi.

[ZZ0000ZZ]

.. _bisecttest_bisref:

Điểm kiểm tra chia đôi
~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Đảm bảo những gì bạn nói với Git là chính xác: chỉ sai một lần sẽ mang lại kết quả
phần còn lại của phần chia đôi hoàn toàn lệch hướng, do đó tất cả các thử nghiệm sau thời điểm đó
sẽ chẳng là gì cả.

[ZZ0000ZZ]

.. _bisectlog_bisref:

Bỏ khúc gỗ chia đôi đi
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0001ZZ
  [ZZ0000ZZ]

Như đã chỉ ra ở trên: chỉ khai báo sai một hạt nhân là 'tốt' hoặc 'xấu' sẽ
làm cho kết quả cuối cùng của phép chia đôi trở nên vô dụng. Trong trường hợp đó bạn thường có
để bắt đầu lại việc chia đôi từ đầu. Nhật ký có thể ngăn chặn điều đó, vì nó có thể
cho phép ai đó chỉ ra nơi đường chia đôi có thể đi ngang -- và sau đó
thay vì thử nghiệm mười hạt nhân trở lên, bạn có thể chỉ phải xây dựng một vài hạt nhân để
giải quyết mọi việc.

Tệp .config được đặt sang một bên, vì rất có thể các nhà phát triển có thể
yêu cầu nó sau khi bạn báo cáo hồi quy.

[ZZ0000ZZ]

.. _revert_bisref:

Hãy thử hoàn nguyên thủ phạm
~~~~~~~~~~~~~~~~~~~~~~~~~

*Thử hoàn nguyên thủ phạm lên trên cơ sở mã mới nhất để xem lỗi này có khắc phục được không
  hồi quy của bạn.* [ZZ0000ZZ]

Đây là bước tùy chọn, nhưng bất cứ khi nào có thể bạn nên thử: có một
rất có thể các nhà phát triển sẽ yêu cầu bạn thực hiện bước này khi bạn mang theo
kết quả chia đôi lên. Vì vậy, hãy thử xem, bạn đã bắt tay vào xây dựng rồi
thêm một hạt nhân nữa không phải là vấn đề lớn vào thời điểm này.

Hướng dẫn từng bước bao gồm mọi thứ có liên quan ngoại trừ một chút
điều hiếm gặp: bạn có chia đôi một hồi quy cũng xảy ra với dòng chính bằng cách sử dụng
một chuỗi ổn định/dài hạn, nhưng Git không thể hoàn nguyên cam kết trong dòng chính? Sau đó
cố gắng hoàn nguyên thủ phạm trong chuỗi dài hạn/ổn định bị ảnh hưởng -- và nếu điều đó
thành công, thay vào đó hãy kiểm tra phiên bản kernel đó.

[ZZ0000ZZ]

Các bước dọn dẹp trong và sau khi làm theo hướng dẫn này
---------------------------------------------------

*Trong và sau khi làm theo hướng dẫn này, bạn có thể muốn hoặc cần xóa một số
  trong số hạt nhân bạn đã cài đặt.* [ZZ0000ZZ]

Các bước trong phần này mô tả các thủ tục làm sạch.

[ZZ0000ZZ].

.. _makeroom_bisref:

Dọn dẹp trong quá trình chia đôi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Để xóa một trong các hạt nhân bạn đã cài đặt, hãy tra cứu 'kernelrelease' của nó
  định danh.* [ZZ0000ZZ]

Các hạt nhân bạn cài đặt trong quá trình này rất dễ bị gỡ bỏ sau này, vì nó
các bộ phận chỉ được lưu trữ ở hai nơi và có thể nhận dạng rõ ràng. Do đó bạn không
cần phải lo lắng về việc làm hỏng máy của bạn khi bạn cài đặt hạt nhân theo cách thủ công (và
do đó bỏ qua hệ thống đóng gói của bản phân phối của bạn): tất cả các phần trong hạt nhân của bạn đều được
tương đối dễ dàng để loại bỏ sau này.

Một trong hai vị trí đó là thư mục trong /lib/modules/, nơi chứa các mô-đun
cho mỗi hạt nhân được cài đặt. Thư mục này được đặt tên theo bản phát hành của kernel
định danh; do đó, để xóa tất cả các mô-đun cho một trong các hạt nhân bạn đã tạo,
chỉ cần xóa thư mục mô-đun của nó trong /lib/modules/.

Vị trí còn lại là /boot/, nơi thường có từ hai đến năm tệp được đặt
trong quá trình cài đặt kernel. Tất cả chúng thường chứa tên phát hành trong
tên tệp của chúng, nhưng có bao nhiêu tệp và tên chính xác của chúng phụ thuộc phần nào vào
tệp thực thi hạt nhân cài đặt của bản phân phối của bạn và trình tạo initramfs của nó. Bật
một số bản phân phối lệnh ZZ0000ZZ được đề cập trong
hướng dẫn từng bước sẽ xóa tất cả các tệp này cho bạn đồng thời xóa
mục menu cho kernel từ cấu hình bootloader của bạn. Trên những người khác bạn
phải tự mình đảm đương hai nhiệm vụ này. Lệnh sau sẽ
tương tác loại bỏ ba tệp chính của kernel bằng tên phát hành
'6.0-rc1-local-gcafec0cacaca0'::

rm -i /boot/{System.map,vmlinuz,initr}-6.0-rc1-local-gcafec0cacaca0

Sau đó kiểm tra các tập tin khác trong /boot/ có
'6.0-rc1-local-gcafec0cacaca0' trong tên của họ và cân nhắc việc xóa chúng.
Bây giờ hãy xóa mục khởi động cho kernel khỏi cấu hình bộ nạp khởi động của bạn;
các bước để thực hiện điều đó khác nhau khá nhiều giữa các bản phân phối Linux.

Lưu ý, hãy cẩn thận với các ký tự đại diện như “*” khi xóa file hoặc thư mục
đối với hạt nhân theo cách thủ công: bạn có thể vô tình xóa các tệp của hạt nhân 6.0.13
khi tất cả những gì bạn muốn là xóa 6.0 hoặc 6.0.1.

[ZZ0000ZZ]

Dọn dẹp sau khi chia đôi
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. _finishingtouch_bisref:

  *Once you have finished the bisection, do not immediately remove anything
  you set up, as you might need a few things again.*
  [:ref:`... <finishingtouch_bissbs>`]

Khi bạn thực sự thiếu dung lượng lưu trữ, hãy loại bỏ hạt nhân như được mô tả trong
hướng dẫn từng bước có thể không giải phóng nhiều dung lượng như bạn muốn. Trong đó
trường hợp này hãy cân nhắc việc chạy ZZ0000ZZ ngay bây giờ. Điều này sẽ loại bỏ
xây dựng các tạo phẩm và nguồn Linux, nhưng sẽ rời khỏi kho Git
(~/linux/.git/) đằng sau -- một ZZ0001ZZ đơn giản sẽ mang lại
nguồn trở lại.

Việc xóa kho lưu trữ cũng có thể là không khôn ngoan vào thời điểm này: đó
rất có thể các nhà phát triển sẽ yêu cầu bạn xây dựng một hạt nhân khác để
thực hiện các thử nghiệm bổ sung -- như thử nghiệm bản vá gỡ lỗi hoặc bản sửa lỗi được đề xuất.
Bạn có thể tìm thấy chi tiết về cách thực hiện những điều đó trong phần ZZ0000ZZ.

Các bài kiểm tra bổ sung cũng là lý do tại sao bạn muốn giữ lại
~/kernel-config-working trong vài tuần.

[ZZ0000ZZ]

.. _introoptional_bisref:

Kiểm tra hoàn nguyên, bản vá hoặc phiên bản mới hơn
----------------------------------------

*Trong hoặc sau khi báo cáo lỗi, bạn có thể muốn hoặc có khả năng sẽ được hỏi
  để kiểm tra các bản hoàn nguyên, bản vá, bản sửa lỗi được đề xuất hoặc các phiên bản khác.*
  [ZZ0000ZZ]

Tất cả các lệnh được sử dụng trong phần này đều khá đơn giản, vì vậy
không có gì nhiều để thêm ngoại trừ một điều: khi đặt thẻ kernel là
được hướng dẫn, hãy đảm bảo nó không dài hơn nhiều so với cái được sử dụng trong ví dụ, như
vấn đề sẽ phát sinh nếu mã định danh kernelrelease vượt quá 63 ký tự.

[ZZ0000ZZ].


Thông tin bổ sung
======================

.. _buildhost_bis:

Xây dựng hạt nhân trên một máy khác
------------------------------------

Để biên dịch hạt nhân trên hệ thống khác, hãy thay đổi một chút hướng dẫn từng bước
hướng dẫn:

* Bắt đầu làm theo hướng dẫn trên máy bạn muốn cài đặt và kiểm tra
  hạt nhân sau này.

* Sau khi thực hiện 'ZZ0000ZZ', hãy lưu danh sách đã tải
  mô-đun vào một tệp bằng ZZ0002ZZ. Sau đó xác định vị trí
  xây dựng cấu hình cho kernel đang chạy (xem 'ZZ0001ZZ' để biết gợi ý về vị trí
  để tìm nó) và lưu nó dưới dạng '~/test-machine-config-working'. Chuyển cả hai
  các tập tin vào thư mục chính của máy chủ xây dựng của bạn.

* Tiếp tục hướng dẫn trên máy chủ xây dựng (ví dụ: với 'ZZ0000ZZ').

* Khi bạn đạt 'ZZ0000ZZ': trước khi chạy ZZ0001ZZ lần đầu tiên,
  thực hiện lệnh sau để căn cứ cấu hình của bạn dựa trên lệnh từ
  hạt nhân 'đang hoạt động' của máy kiểm tra::

cp ~/test-machine-config-working ~/linux/.config

* Trong bước tiếp theo tới 'ZZ0000ZZ', hãy sử dụng lệnh sau thay thế::

vâng '' | tạo localmodconfig LSMOD=~/lsmod_foo-machine localmodconfig

* Tiếp tục hướng dẫn nhưng bỏ qua các hướng dẫn phác thảo cách biên dịch,
  cài đặt và khởi động lại vào kernel mỗi khi chúng xuất hiện. Thay vào đó hãy xây dựng
  như thế này::

cp ~/kernel-config-working .config
    tạo olddefconfig &&
    tạo -j $(nproc --all) targz-pkg

Điều này sẽ tạo ra một tệp tar được nén bằng gzip có tên được in ở cuối cùng.
  dòng hiển thị; ví dụ: một kernel có mã định danh kernelrelease
  '6.0.0-rc1-local-g928a87efa423' được xây dựng cho máy x86 thường sẽ
  được lưu trữ dưới dạng '~/linux/linux-6.0.0-rc1-local-g928a87efa423-x86.tar.gz'.

Sao chép tập tin đó vào thư mục chính của máy kiểm tra của bạn.

* Chuyển sang máy kiểm tra để kiểm tra xem bạn có đủ chỗ để chứa máy khác không
  hạt nhân. Sau đó giải nén tập tin bạn đã chuyển ::

sudo tar -xvzf ~/linux-6.0.0-rc1-local-g928a87efa423-x86.tar.gz -C /

Sau đó là ZZ0000ZZ; trên một số bản phân phối sau đây
  lệnh sẽ đảm nhiệm cả hai nhiệm vụ này ::

sudo /sbin/installkernel 6.0.0-rc1-local-g928a87efa423 /boot/vmlinuz-6.0.0-rc1-local-g928a87efa423

Bây giờ khởi động lại và đảm bảo bạn đã khởi động kernel dự định.

Cách tiếp cận này thậm chí còn hiệu quả khi xây dựng cho một kiến trúc khác: chỉ cần cài đặt
trình biên dịch chéo và thêm các tham số thích hợp vào mỗi lệnh gọi make
(ví dụ: ZZ0000ZZ).

Tài liệu đọc bổ sung
---------------------------

* ZZ0000ZZ và
  ZZ0001ZZ
  trong tài liệu Git.
* ZZ0002ZZ
  từ nhà phát triển hạt nhân Nathan Chancellor.
* ZZ0003ZZ.
*ZZ0004ZZ.

.................
   end-of-content
.................
   This document is maintained by Thorsten Leemhuis <linux@leemhuis.info>. If
   you spot a typo or small mistake, feel free to let him know directly and
   he'll fix it. You are free to do the same in a mostly informal way if you
   want to contribute changes to the text -- but for copyright reasons please CC
   linux-doc@vger.kernel.org and 'sign-off' your contribution as
   Documentation/process/submitting-patches.rst explains in the section 'Sign
   your work - the Developer's Certificate of Origin'.
..
   This text is available under GPL-2.0+ or CC-BY-4.0, as stated at the top
   of the file. If you want to distribute this text under CC-BY-4.0 only,
   please use 'The Linux kernel development community' for author attribution
   and link this as source:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/admin-guide/verify-bugs-and-bisect-regressions.rst

..
   Note: Only the content of this RST file as found in the Linux kernel sources
   is available under CC-BY-4.0, as versions of this text that were processed
   (for example by the kernel's build system) might contain content taken from
   files which use a more restrictive license.