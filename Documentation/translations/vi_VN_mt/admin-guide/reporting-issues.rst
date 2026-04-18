.. SPDX-License-Identifier: (GPL-2.0+ OR CC-BY-4.0)

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/admin-guide/reporting-issues.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. See the bottom of this file for additional redistribution information.

Vấn đề báo cáo
++++++++++++++++


Hướng dẫn ngắn (còn gọi là TL;DR)
===========================

Bạn có đang phải đối mặt với sự hồi quy với hạt vani từ cùng một nguồn ổn định hoặc
chuỗi dài hạn? Một vẫn được hỗ trợ? Sau đó tìm kiếm kho lưu trữ ZZ0000ZZ và ZZ0001ZZ để tìm các báo cáo phù hợp để tham gia. Nếu
bạn không tìm thấy, hãy cài đặt ZZ0002ZZ. Nếu nó vẫn hiển thị sự cố, hãy báo cáo cho bộ phận ổn định
danh sách gửi thư (stable@vger.kernel.org) và CC danh sách hồi quy
(hồi quy@lists.linux.dev); lý tưởng nhất là CC người bảo trì và gửi thư
danh sách cho hệ thống con được đề cập.

Trong tất cả các trường hợp khác, hãy thử đoán xem phần kernel nào có thể gây ra lỗi
vấn đề. Kiểm tra tệp ZZ0000ZZ để biết cách các nhà phát triển của nó
mong đợi được thông báo về các vấn đề mà hầu hết sẽ được thông báo qua email với nội dung
danh sách gửi thư trong CC. Kiểm tra kho lưu trữ của điểm đến để tìm các báo cáo phù hợp;
tìm kiếm ZZ0001ZZ và trên web. Nếu bạn
không tìm thấy gì để tham gia, hãy cài đặt ZZ0002ZZ. Nếu vấn đề xuất hiện ở đó, hãy gửi báo cáo.

Vấn đề đã được khắc phục ở đó nhưng bạn muốn thấy nó được giải quyết một cách tĩnh lặng
có hỗ trợ chuỗi ổn định hay dài hạn không? Sau đó cài đặt bản phát hành mới nhất của nó.
Nếu nó hiển thị sự cố, hãy tìm kiếm thay đổi đã khắc phục sự cố đó trong dòng chính và
kiểm tra xem việc backport đang được thực hiện hay đã bị loại bỏ; nếu không, hãy hỏi
những người xử lý sự thay đổi cho nó.

ZZ0000ZZ: Khi cài đặt và kiểm tra kernel như đã nêu ở trên,
đảm bảo nó là vanilla (IOW: không được vá và không sử dụng các mô-đun bổ trợ). Cũng làm
chắc chắn rằng nó được xây dựng và chạy trong một môi trường lành mạnh và chưa bị nhiễm độc
trước khi vấn đề xảy ra.

Nếu bạn đang gặp phải nhiều vấn đề với nhân Linux cùng một lúc, hãy báo cáo từng vấn đề
riêng biệt. Trong khi viết báo cáo của bạn, hãy bao gồm tất cả thông tin liên quan đến
vấn đề, như kernel và bản phân phối được sử dụng. Trong trường hợp hồi quy, CC
hồi quy danh sách gửi thư (regressions@lists.linux.dev) vào báo cáo của bạn. Cũng thử
để xác định thủ phạm bằng một vết mổ; nếu bạn thành công, hãy bao gồm nó
commit-id và CC cho mọi người trong chuỗi đăng xuất.

Sau khi báo cáo được đưa ra, hãy trả lời bất kỳ câu hỏi nào xuất hiện và giúp bạn
có thể. Điều đó bao gồm việc giữ cho quả bóng lăn bằng cách thỉnh thoảng kiểm tra lại với các thiết bị mới hơn.
phát hành và gửi cập nhật trạng thái sau đó.

..
   Note: If you see this note, you are reading the text's source file. You
   might want to switch to a rendered version: It makes it a lot easier to
   read and navigate this document -- especially when you want to look something
   up in the reference section, then jump back to where you left off.
..
   Find the latest rendered version of this text here:
   https://docs.kernel.org/admin-guide/reporting-issues.html


Hướng dẫn từng bước cách báo cáo sự cố cho người bảo trì kernel
=================================================================

TL;DR ở trên phác thảo đại khái cách báo cáo sự cố đối với nhân Linux
nhà phát triển. Nó có thể là tất cả những gì cần thiết cho những người đã quen thuộc với
báo cáo sự cố cho các dự án Phần mềm nguồn mở/tự do và miễn phí (FLOSS). cho
mọi người khác có phần này. Nó chi tiết hơn và sử dụng một
cách tiếp cận từng bước. Nó vẫn cố gắng ngắn gọn để dễ đọc và để lại
ra rất nhiều chi tiết; những điều đó được mô tả bên dưới hướng dẫn từng bước trong
phần tham khảo, giải thích từng bước chi tiết hơn.

Lưu ý: phần này đề cập đến một số khía cạnh hơn TL;DR và ​​thực hiện mọi việc trong
một thứ tự hơi khác một chút. Đó là mối quan tâm của bạn, để đảm bảo bạn nhận thấy
sớm nếu một sự cố trông giống như sự cố nhân Linux thực sự là do
một cái gì đó khác. Do đó, các bước này giúp đảm bảo thời gian bạn đầu tư vào việc này
quá trình cuối cùng sẽ không cảm thấy lãng phí:

* Bạn đang gặp phải sự cố với nhân Linux, nhà cung cấp phần cứng hoặc phần mềm
   cung cấp? Vậy thì trong hầu hết mọi trường hợp, tốt hơn hết bạn nên ngừng đọc cuốn sách này
   thay vào đó hãy ghi lại và báo cáo vấn đề cho nhà cung cấp của bạn, trừ khi bạn
   sẵn sàng tự cài đặt phiên bản Linux mới nhất. Hãy nhận biết điều sau
   dù sao thì thường sẽ cần thiết để tìm kiếm và khắc phục sự cố.

* Thực hiện tìm kiếm sơ bộ các báo cáo hiện có bằng mạng internet yêu thích của bạn
   công cụ tìm kiếm; Ngoài ra, hãy kiểm tra kho lưu trữ của ZZ0000ZZ. Nếu bạn tìm thấy các báo cáo phù hợp,
   tham gia cuộc thảo luận thay vì gửi một cuộc thảo luận mới.

* Xem liệu vấn đề bạn đang giải quyết có đủ tiêu chuẩn là hồi quy, bảo mật hay không
   vấn đề hoặc một vấn đề thực sự nghiêm trọng: đó là những 'vấn đề có mức độ ưu tiên cao' mà
   cần xử lý đặc biệt ở một số bước sắp thực hiện.

* Đảm bảo rằng không phải môi trường xung quanh kernel đang gây ra sự cố
   bạn phải đối mặt.

* Tạo một bản sao lưu mới và trang bị sẵn các công cụ sửa chữa và khôi phục hệ thống.

* Đảm bảo hệ thống của bạn không nâng cấp nhân của nó bằng cách xây dựng thêm
   các mô-đun hạt nhân đang hoạt động, những giải pháp như DKMS có thể được thực hiện cục bộ
   mà bạn không hề biết.

* Kiểm tra xem kernel của bạn có bị 'nhiễm độc' hay không khi sự cố xảy ra, vì sự kiện này
   điều đó khiến kernel đặt cờ này có thể gây ra sự cố mà bạn gặp phải.

* Viết ra một cách thô thiển cách tái hiện vấn đề. Nếu bạn giải quyết nhiều
   vấn đề cùng một lúc, tạo ghi chú riêng cho từng vấn đề và đảm bảo chúng
   hoạt động độc lập trên một hệ thống mới khởi động. Điều đó là cần thiết, vì mỗi vấn đề
   cần được báo cáo riêng cho các nhà phát triển kernel, trừ khi họ
   vướng víu mạnh mẽ.

* Nếu bạn đang gặp phải tình trạng hồi quy trong dòng phiên bản ổn định hoặc dài hạn
   (giả sử có gì đó bị hỏng khi cập nhật từ 5.10.4 lên 5.10.5), hãy cuộn xuống
   'Xử lý các hiện tượng hồi quy trong dòng hạt nhân ổn định và lâu dài'.

* Xác định vị trí trình điều khiển hoặc hệ thống con kernel dường như đang gây ra sự cố.
   Tìm hiểu cách thức và nơi các nhà phát triển mong đợi báo cáo. Lưu ý: hầu hết các
   lần này sẽ không phải là bugzilla.kernel.org vì các vấn đề thường cần được gửi
   bằng thư đến người bảo trì và danh sách gửi thư công khai.

* Tìm kiếm kho lưu trữ của trình theo dõi lỗi hoặc danh sách gửi thư được đề cập
   kỹ lưỡng để biết các báo cáo có thể phù hợp với vấn đề của bạn. Nếu bạn tìm thấy bất cứ điều gì,
   tham gia thảo luận thay vì gửi báo cáo mới.

Sau những bước chuẩn bị này, bây giờ bạn sẽ bước vào phần chính:

* Trừ khi bạn đang chạy nhân Linux 'chính thống' mới nhất, nếu không thì tốt hơn
   đi và cài đặt nó cho quá trình báo cáo. Kiểm tra và báo cáo với
   Linux 'ổn định' mới nhất có thể là một lựa chọn thay thế có thể chấp nhận được ở một số nơi
   tình huống; trong cửa sổ hợp nhất mà thực sự có thể là tốt nhất
   cách tiếp cận này, nhưng trong giai đoạn phát triển đó, có thể là một ý tưởng tốt hơn nếu
   Dù sao thì hãy tạm dừng nỗ lực của bạn trong vài ngày. Dù bạn chọn phiên bản nào,
   lý tưởng nhất là sử dụng bản dựng 'vanilla'. Bỏ qua những lời khuyên này sẽ
   tăng nguy cơ báo cáo của bạn sẽ bị từ chối hoặc bỏ qua.

* Đảm bảo kernel bạn vừa cài đặt không bị 'làm hỏng' khi
   đang chạy.

* Tái tạo lại vấn đề với kernel bạn vừa cài đặt. Nếu nó không hiển thị
   ở trên đó, cuộn xuống phần hướng dẫn cho các vấn đề chỉ xảy ra với
   hạt nhân ổn định và lâu dài.

* Tối ưu hóa ghi chú của bạn: cố gắng tìm và viết theo cách đơn giản nhất để
   tái tạo vấn đề của bạn. Đảm bảo rằng kết quả cuối cùng có tất cả những thông tin quan trọng
   chi tiết, đồng thời dễ đọc và dễ hiểu đối với người khác
   lần đầu tiên nghe về nó. Và nếu bạn học được điều gì đó trong này
   quá trình này, hãy cân nhắc việc tìm kiếm lại các báo cáo hiện có về vấn đề này.

* Nếu thất bại của bạn liên quan đến 'hoảng loạn', 'Rất tiếc', 'cảnh báo' hoặc 'BUG', hãy cân nhắc
   giải mã nhật ký kernel để tìm dòng mã gây ra lỗi.

* Nếu vấn đề của bạn là sự hồi quy, hãy cố gắng thu hẹp thời điểm vấn đề xảy ra
   được giới thiệu càng nhiều càng tốt.

* Bắt đầu biên soạn báo cáo bằng cách viết mô tả chi tiết về
   vấn đề. Luôn đề cập đến một số điều: phiên bản kernel mới nhất bạn đã cài đặt
   để sao chép, Bản phân phối Linux được sử dụng và các ghi chú của bạn về cách
   tái hiện vấn đề. Lý tưởng nhất là tạo cấu hình xây dựng của kernel
   (.config) và đầu ra từ ZZ0000ZZ có sẵn ở đâu đó trên mạng và
   liên kết đến nó. Bao gồm hoặc tải lên tất cả thông tin khác có thể có liên quan,
   như đầu ra/ảnh chụp màn hình của Rất tiếc hoặc đầu ra từ ZZ0001ZZ. Một lần
   bạn đã viết phần chính này, chèn một đoạn văn dài bình thường lên trên nó
   phác thảo vấn đề và tác động một cách nhanh chóng. Ngoài ra thêm một câu
   mô tả ngắn gọn vấn đề và khiến mọi người đọc tiếp. Bây giờ đưa
   một tiêu đề hoặc chủ đề mô tả lại ngắn hơn. Vậy thì bạn đang
   sẵn sàng gửi hoặc gửi báo cáo giống như tệp MAINTAINERS đã nói với bạn, trừ khi
   bạn đang giải quyết một trong những 'vấn đề có mức độ ưu tiên cao': họ cần
   sự chăm sóc đặc biệt được giải thích trong 'Xử lý đặc biệt đối với các trường hợp có mức độ ưu tiên cao
   vấn đề' bên dưới.

* Chờ phản ứng và tiếp tục công việc cho đến khi bạn có thể chấp nhận
   kết quả bằng cách này hay cách khác. Do đó phản ứng công khai và kịp thời
   cho bất kỳ yêu cầu. Kiểm tra các bản sửa lỗi được đề xuất. Thực hiện kiểm tra chủ động: kiểm tra lại với lúc
   ít nhất mọi ứng cử viên phát hành đầu tiên (RC) của phiên bản dòng chính mới và
   báo cáo kết quả của bạn. Gửi lời nhắc thân thiện nếu mọi thứ bị đình trệ. Và cố gắng
   hãy tự giúp mình nếu bạn không nhận được sự giúp đỡ nào hoặc nếu điều đó khiến bạn không hài lòng.


Báo cáo hồi quy trong dòng hạt nhân ổn định và lâu dài
--------------------------------------------------------------

Tiểu mục này dành cho bạn, nếu bạn đã làm theo quy trình trên và được gửi tới đây tại
quan điểm về hồi quy trong dòng phiên bản hạt nhân ổn định hoặc dài hạn. bạn
phải đối mặt với một trong những vấn đề đó nếu có sự cố xảy ra khi cập nhật từ 5.10.4 lên 5.10.5 (a
chuyển từ 5.9.15 sang 5.10.5 không đủ điều kiện). Các nhà phát triển muốn sửa lỗi như vậy
hồi quy càng nhanh càng tốt, do đó có một quy trình hợp lý để
báo cáo họ:

* Kiểm tra xem các nhà phát triển kernel có còn duy trì phiên bản kernel Linux không
   dòng bạn quan tâm: đi tới ZZ0000ZZ và đảm bảo nó đề cập đến
   bản phát hành mới nhất của dòng phiên bản cụ thể không có thẻ '[EOL]'.

* Kiểm tra kho lưu trữ của ZZ0000ZZ để biết các báo cáo hiện có.

* Cài đặt bản phát hành mới nhất từ dòng phiên bản cụ thể dưới dạng vanilla
   hạt nhân. Đảm bảo hạt nhân này không bị nhiễm độc và vẫn hiển thị vấn đề, như
   vấn đề có thể đã được khắc phục ở đó. Nếu lần đầu tiên bạn nhận thấy
   vấn đề với kernel của nhà cung cấp, hãy kiểm tra bản dựng vanilla của phiên bản cuối cùng
   được biết là làm việc cũng hoạt động tốt.

* Gửi một báo cáo sự cố ngắn tới danh sách gửi thư ổn định của Linux
   (stable@vger.kernel.org) và CC danh sách gửi thư hồi quy Linux
   (hồi quy@lists.linux.dev); nếu bạn nghi ngờ nguyên nhân cụ thể
   hệ thống con, CC người bảo trì và danh sách gửi thư của nó. Mô tả đại khái các
   vấn đề và giải thích một cách lý tưởng cách tái tạo nó. Đề cập đến phiên bản đầu tiên
   điều đó cho thấy sự cố và phiên bản cuối cùng đang hoạt động tốt. Sau đó
   chờ hướng dẫn thêm.

Phần tham khảo bên dưới giải thích chi tiết hơn từng bước.


Báo cáo sự cố chỉ xảy ra trong các dòng phiên bản kernel cũ hơn
-------------------------------------------------------------

Tiểu mục này dành cho bạn, nếu bạn đã thử kernel dòng chính mới nhất như đã nêu
ở trên nhưng không thể tái hiện vấn đề của bạn ở đó; đồng thời bạn muốn
xem sự cố đã được khắc phục trong chuỗi hoặc nhà cung cấp ổn định hoặc dài hạn vẫn được hỗ trợ
hạt nhân thường xuyên dựa trên những hạt nhân đó. Nếu đúng như vậy, hãy làm theo các bước sau:

* Chuẩn bị sẵn sàng cho khả năng thực hiện các bước tiếp theo
   có thể không giải quyết được vấn đề trong các bản phát hành cũ hơn: bản sửa lỗi có thể quá lớn
   hoặc có nguy cơ bị đưa trở lại đó.

* Thực hiện 3 bước đầu trong phần “Xử lý hồi quy
   trong dòng hạt nhân ổn định và lâu dài" ở trên.

* Tìm kiếm hệ thống kiểm soát phiên bản nhân Linux để biết thay đổi đã sửa
   sự cố trong dòng chính, vì thông báo cam kết của nó có thể cho bạn biết liệu cách khắc phục có hiệu quả hay không
   đã lên lịch cho việc backport rồi. Nếu bạn không tìm thấy bất cứ điều gì theo cách đó,
   tìm kiếm danh sách gửi thư thích hợp cho các bài viết thảo luận về vấn đề đó
   hoặc đánh giá ngang hàng các bản sửa lỗi có thể có; sau đó kiểm tra các cuộc thảo luận xem cách khắc phục có hiệu quả không
   được coi là không phù hợp để chuyển ngược lại. Nếu việc backporting không được xem xét tại
   tất cả, hãy tham gia cuộc thảo luận mới nhất, hỏi xem nó có trong thẻ không.

* Một trong những bước trước đây sẽ dẫn đến giải pháp. Nếu điều đó không hiệu quả
   ra ngoài, hãy hỏi người bảo trì về hệ thống con dường như đang gây ra sự cố
   vấn đề để được tư vấn; CC danh sách gửi thư cho hệ thống con cụ thể
   như danh sách gửi thư ổn định.

Phần tham khảo bên dưới giải thích chi tiết hơn từng bước.


Kết luận của hướng dẫn từng bước
------------------------------------

Bạn có gặp rắc rối khi làm theo hướng dẫn từng bước không được giải thích rõ ràng không?
phần tham khảo dưới đây? Bạn có phát hiện ra lỗi không? Hoặc bạn có ý tưởng nào về cách
cải thiện hướng dẫn?

Nếu bất kỳ điều nào trong số đó áp dụng, vui lòng cho nhà phát triển biết bằng cách gửi một ghi chú ngắn
hoặc một bản vá cho Thorsten Leemhuis <linux@leemhuis.info> trong khi lý tưởng nhất là CC
danh sách gửi thư tài liệu Linux công khai <linux-doc@vger.kernel.org>. Những phản hồi như vậy là
rất quan trọng để cải thiện văn bản này hơn nữa, điều này mang lại lợi ích cho mọi người, vì nó sẽ
cho phép nhiều người nắm vững nhiệm vụ được mô tả ở đây.


Phần tham khảo: Báo cáo sự cố cho người bảo trì kernel
=============================================================

Hướng dẫn từng bước ở trên phác thảo tất cả các bước chính một cách ngắn gọn,
thường bao gồm mọi thứ được yêu cầu. Nhưng ngay cả những người dùng có kinh nghiệm cũng sẽ
đôi khi tự hỏi làm thế nào để thực sự nhận ra một số bước đó hoặc tại sao chúng lại như vậy
cần thiết; cũng có những trường hợp góc mà hướng dẫn bỏ qua để dễ đọc. Đó là
các mục trong phần tham khảo này dùng để làm gì, cung cấp thêm
thông tin cho từng bước trong hướng dẫn.

Một vài lời khuyên chung:

* Các nhà phát triển Linux nhận thức rõ rằng việc báo cáo lỗi cho họ sẽ hiệu quả hơn
  phức tạp và đòi hỏi khắt khe hơn so với các dự án FLOSS khác. Một phần là vì
  hạt nhân thì khác, trong số những hạt nhân khác do sự phát triển dựa trên thư của nó
  quá trình và bởi vì nó bao gồm chủ yếu là các trình điều khiển. Một phần là vì
  cải thiện mọi thứ sẽ đòi hỏi phải làm việc trong một số lĩnh vực kỹ thuật và con người
  phân loại lỗi –– và chưa có ai đứng ra thực hiện hoặc tài trợ cho công việc đó.

* Hợp đồng bảo hành hoặc hỗ trợ với một số nhà cung cấp không cho phép bạn thực hiện
  yêu cầu sửa lỗi từ các nhà phát triển Linux thượng nguồn: Các hợp đồng như vậy là
  hoàn toàn nằm ngoài phạm vi của nhân Linux ngược dòng, sự phát triển của nó
  cộng đồng và tài liệu này -- ngay cả khi những người xử lý vấn đề đó làm việc cho
  người bán đã phát hành hợp đồng. Nếu bạn muốn yêu cầu quyền lợi của mình, hãy sử dụng
  kênh hỗ trợ của nhà cung cấp.

* Nếu trước đây bạn chưa bao giờ báo cáo sự cố cho dự án FLOSS, hãy cân nhắc việc đọc lướt
  các hướng dẫn như ZZ0000ZZ, ZZ0001ZZ và ZZ0002ZZ,.

Bỏ điều đó ra khỏi bảng, hãy tìm thông tin chi tiết bên dưới để biết các bước từ hướng dẫn chi tiết
hướng dẫn về cách báo cáo vấn đề cho nhà phát triển nhân Linux.


Đảm bảo bạn đang sử dụng nhân Linux ngược dòng
------------------------------------------------

*Bạn đang gặp phải sự cố với nhân Linux, nhà cung cấp phần cứng hoặc phần mềm
   cung cấp? Vậy thì trong hầu hết mọi trường hợp, tốt hơn hết bạn nên ngừng đọc cuốn sách này
   thay vào đó hãy ghi lại và báo cáo vấn đề cho nhà cung cấp của bạn, trừ khi bạn
   sẵn sàng tự cài đặt phiên bản Linux mới nhất. Hãy nhận biết điều sau
   dù sao thì thường sẽ cần thiết để tìm kiếm và khắc phục sự cố.*

Giống như hầu hết các lập trình viên, các nhà phát triển nhân Linux không muốn dành thời gian xử lý
với các báo cáo về các vấn đề thậm chí không xảy ra với mã hiện tại của họ. Đó là
chỉ làm lãng phí thời gian của mọi người, đặc biệt là của bạn. Thật không may những tình huống như vậy
dễ dàng xảy ra khi nói đến kernel và thường dẫn đến sự thất vọng cho cả hai
các bên. Đó là bởi vì hầu hết tất cả các nhân dựa trên Linux đều được cài đặt sẵn trên các thiết bị
(Máy tính, Laptop, Điện thoại thông minh, Bộ định tuyến, …) và hầu hết được vận chuyển bởi Linux
các nhà phân phối ở khá xa so với nhân Linux chính thức được phân phối bởi
kernel.org: những hạt nhân này từ những nhà cung cấp này thường rất cổ xưa xét về mặt
Phát triển Linux hoặc sửa đổi nhiều, thường là cả hai.

Hầu hết các hạt nhân của nhà cung cấp này hoàn toàn không phù hợp để báo cáo sự cố cho
Các nhà phát triển nhân Linux: vấn đề mà bạn gặp phải với một trong số họ có thể là
đã được các nhà phát triển nhân Linux sửa lỗi từ nhiều tháng hoặc nhiều năm trước; Ngoài ra,
những sửa đổi và cải tiến của nhà cung cấp có thể gây ra sự cố cho bạn
khuôn mặt, ngay cả khi chúng trông nhỏ hoặc hoàn toàn không liên quan. Đó là lý do tại sao bạn nên báo cáo
các vấn đề với các hạt nhân này cho nhà cung cấp. Các nhà phát triển của nó nên xem xét
báo cáo và, trong trường hợp nó trở thành một vấn đề ngược dòng, hãy khắc phục nó trực tiếp
ngược dòng hoặc chuyển tiếp báo cáo ở đó. Trong thực tế điều đó thường không thành công
hoặc có thể không phải những gì bạn muốn. Do đó, bạn có thể muốn xem xét việc phá vỡ
nhà cung cấp bằng cách tự cài đặt lõi nhân Linux mới nhất. Nếu đó là một
tùy chọn để bạn tiếp tục trong quá trình này, vì bước sau trong hướng dẫn này sẽ
giải thích cách thực hiện điều đó sau khi loại trừ các nguyên nhân tiềm ẩn khác gây ra vấn đề của bạn.

Lưu ý, đoạn trước bắt đầu bằng từ 'nhất', vì đôi khi
trên thực tế, các nhà phát triển sẵn sàng xử lý các báo cáo về các vấn đề xảy ra với
hạt nhân của nhà cung cấp. Cuối cùng thì họ có làm được hay không phụ thuộc rất nhiều vào các nhà phát triển và
vấn đề đang được đề cập. Cơ hội của bạn khá tốt nếu nhà phân phối chỉ áp dụng
những sửa đổi nhỏ đối với kernel dựa trên phiên bản Linux gần đây; cái đó cho
ví dụ này thường đúng với các hạt nhân dòng chính được cung cấp bởi Debian GNU/Linux
Sid hoặc Fedora Rawhide. Một số nhà phát triển cũng sẽ chấp nhận báo cáo về các vấn đề
với các hạt nhân từ các bản phân phối vận chuyển hạt nhân ổn định mới nhất, miễn là
nó chỉ được sửa đổi một chút; ví dụ đó thường là trường hợp của Arch Linux,
các bản phát hành Fedora thường xuyên và openSUSE Tumbleweed. Nhưng hãy nhớ, tốt hơn hết bạn nên
muốn sử dụng Linux chính thống và tránh sử dụng kernel ổn định cho việc này
quá trình, như được nêu trong phần 'Cài đặt hạt nhân mới để thử nghiệm' trong phần khác
chi tiết.

Rõ ràng là bạn có quyền bỏ qua tất cả lời khuyên này và báo cáo vấn đề với một thiết bị cũ.
hoặc hạt nhân của nhà cung cấp được sửa đổi nhiều cho các nhà phát triển Linux cấp cao. Nhưng lưu ý,
những điều đó thường bị từ chối hoặc bỏ qua, vì vậy hãy coi như mình đã được cảnh báo. Nhưng nó vẫn
tốt hơn là không báo cáo vấn đề gì cả: đôi khi những báo cáo đó trực tiếp hoặc
gián tiếp sẽ giúp giải quyết vấn đề theo thời gian.


Tìm kiếm các báo cáo hiện có, chạy lần đầu
--------------------------------------

*Thực hiện tìm kiếm sơ bộ các báo cáo hiện có bằng mạng internet ưa thích của bạn
   công cụ tìm kiếm; Ngoài ra, hãy kiểm tra kho lưu trữ của Linux Kernel Mailing
   Danh sách (LKML). Nếu bạn tìm thấy các báo cáo phù hợp, hãy tham gia thảo luận thay vì
   gửi một cái mới.*

Việc báo cáo một vấn đề mà người khác đã đưa ra thường là một sự lãng phí
thời gian dành cho tất cả mọi người có liên quan, đặc biệt là bạn với tư cách là phóng viên. Vì vậy, nó là của riêng bạn
quan tâm để kiểm tra kỹ lưỡng xem đã có ai báo cáo vấn đề này chưa. Lúc này
bước của quy trình, bạn chỉ cần thực hiện tìm kiếm sơ bộ: bước sau sẽ
yêu cầu bạn thực hiện tìm kiếm chi tiết hơn khi bạn biết vấn đề của mình cần ở đâu
để được báo cáo. Tuy nhiên, đừng vội thực hiện bước báo cáo này
quá trình này, nó có thể giúp bạn tiết kiệm thời gian và rắc rối.

Trước tiên, chỉ cần tìm kiếm trên Internet bằng công cụ tìm kiếm yêu thích của bạn. Sau đó,
tìm kiếm ZZ0000ZZ.

Nếu bạn nhận được quá nhiều kết quả, hãy cân nhắc yêu cầu công cụ tìm kiếm của bạn hạn chế
khung thời gian tìm kiếm đến tháng hoặc năm vừa qua. Và bất cứ nơi nào bạn tìm kiếm, hãy đảm bảo
sử dụng các thuật ngữ tìm kiếm tốt; cũng thay đổi chúng một vài lần. Trong khi làm như vậy hãy cố gắng
nhìn vấn đề từ quan điểm của người khác: điều đó sẽ giúp bạn
nghĩ ra những từ khác để sử dụng làm thuật ngữ tìm kiếm. Cũng đảm bảo không sử dụng quá
nhiều cụm từ tìm kiếm cùng một lúc. Hãy nhớ tìm kiếm có và không có thông tin như
tên của trình điều khiển hạt nhân hoặc tên của thành phần phần cứng bị ảnh hưởng.
Nhưng tên thương hiệu chính xác của nó (ví dụ 'ASUS Red Devil Radeon RX 5700 XT Gaming OC')
thường không hữu ích lắm vì nó quá cụ thể. Thay vào đó hãy thử các cụm từ tìm kiếm như
dòng model (Radeon 5700 hoặc Radeon 5000) và tên mã của chip chính
("Navi" hoặc "Navi10") có và không có nhà sản xuất ('AMD').

Trong trường hợp bạn tìm thấy báo cáo hiện có về vấn đề của mình, hãy tham gia thảo luận, với tư cách là
bạn có thể cung cấp thông tin bổ sung có giá trị. Đó có thể là
quan trọng ngay cả khi bản sửa lỗi đã được chuẩn bị hoặc đang ở giai đoạn cuối, vì
các nhà phát triển có thể tìm kiếm những người có thể cung cấp thêm thông tin hoặc
thử nghiệm bản sửa lỗi được đề xuất. Chuyển tới phần 'Nhiệm vụ sau khi báo cáo được gửi' cho
chi tiết về cách tham gia đúng cách.

Lưu ý, việc tìm kiếm ZZ0000ZZ cũng có thể
là một ý tưởng hay vì điều đó có thể cung cấp thông tin chi tiết có giá trị hoặc mang lại kết quả phù hợp
báo cáo. Nếu bạn tìm thấy điều thứ hai, hãy ghi nhớ: hầu hết các hệ thống con đều mong đợi
báo cáo ở những nơi khác nhau, như được mô tả bên dưới trong phần "Kiểm tra xem bạn
cần báo cáo vấn đề của bạn". Các nhà phát triển nên quan tâm đến vấn đề này
do đó thậm chí có thể không biết về vé bugzilla. Do đó, hãy kiểm tra vé nếu
vấn đề đã được báo cáo như được nêu trong tài liệu này và nếu không xem xét
làm như vậy.


Vấn đề có mức độ ưu tiên cao?
-----------------------

*Xem liệu vấn đề bạn đang giải quyết có đủ tiêu chuẩn là hồi quy, bảo mật hay không
    vấn đề hoặc một vấn đề thực sự nghiêm trọng: đó là những 'vấn đề có mức độ ưu tiên cao' mà
    cần xử lý đặc biệt trong một số bước sắp thực hiện.*

Linus Torvalds và các nhà phát triển nhân Linux hàng đầu muốn thấy một số vấn đề
được khắc phục càng sớm càng tốt, do đó có 'các vấn đề có mức độ ưu tiên cao' cần được giải quyết
được xử lý hơi khác một chút trong quá trình báo cáo. Ba loại trường hợp
đủ điều kiện: hồi quy, vấn đề bảo mật và các vấn đề thực sự nghiêm trọng.

Bạn xử lý hồi quy nếu một số ứng dụng hoặc trường hợp sử dụng thực tế đang chạy
ổn với một nhân Linux hoạt động tệ hơn hoặc hoàn toàn không hoạt động với phiên bản mới hơn
được biên dịch bằng cấu hình tương tự. Tài liệu
Documentation/admin-guide/reporting-regressions.rst giải thích thêm về điều này
chi tiết. Nó cũng cung cấp rất nhiều thông tin khác về hồi quy mà bạn
có thể muốn biết đến; ví dụ: nó giải thích cách thêm vấn đề của bạn vào
danh sách các hồi quy được theo dõi, để đảm bảo nó không bị bỏ sót.

Điều gì đủ điều kiện là vấn đề bảo mật sẽ tùy thuộc vào phán quyết của bạn. Cân nhắc việc đọc
Documentation/process/security-bugs.rst trước khi tiếp tục, vì nó
cung cấp thêm chi tiết về cách xử lý tốt nhất các vấn đề bảo mật.

Một vấn đề là một 'vấn đề thực sự nghiêm trọng' khi một điều gì đó hoàn toàn xấu đến mức không thể chấp nhận được
xảy ra. Ví dụ như trường hợp nhân Linux làm hỏng dữ liệu
xử lý hoặc làm hỏng phần cứng mà nó đang chạy. Bạn cũng đang phải đối mặt với một vấn đề nghiêm trọng
vấn đề khi kernel đột ngột ngừng hoạt động với thông báo lỗi ('kernel
hoảng sợ') hoặc không có lời tạm biệt nào cả. Lưu ý: đừng nhầm lẫn giữa từ 'hoảng loạn' (a
lỗi nghiêm trọng trong đó kernel tự dừng) với 'Rất tiếc' (lỗi có thể phục hồi),
vì kernel vẫn chạy sau cái sau.


Đảm bảo môi trường trong lành
----------------------------

*Đảm bảo rằng không phải môi trường xung quanh kernel đang gây ra sự cố
    bạn phải đối mặt.*

Các vấn đề trông rất giống vấn đề về kernel đôi khi do quá trình xây dựng hoặc
môi trường thời gian chạy. Thật khó để loại trừ hoàn toàn vấn đề đó, nhưng bạn
nên giảm thiểu nó:

* Sử dụng các công cụ đã được chứng minh khi xây dựng kernel của bạn, khi có lỗi trong trình biên dịch hoặc
   binutils có thể khiến kernel kết quả hoạt động sai.

* Đảm bảo các thành phần máy tính của bạn chạy theo thông số kỹ thuật thiết kế của chúng;
   điều đó đặc biệt quan trọng đối với bộ xử lý chính, bộ nhớ chính và
   bo mạch chủ. Do đó, hãy dừng việc giảm điện áp hoặc ép xung khi gặp sự cố
   vấn đề hạt nhân tiềm năng.

* Cố gắng đảm bảo rằng nguyên nhân gây ra sự cố không phải do phần cứng bị lỗi. Xấu
   bộ nhớ chính chẳng hạn có thể dẫn đến vô số vấn đề sẽ
   biểu hiện ở những vấn đề giống như vấn đề về kernel.

* Nếu bạn đang xử lý sự cố hệ thống tệp, bạn có thể muốn kiểm tra tệp
   hệ thống được đề cập với ZZ0000ZZ, vì nó có thể bị hỏng theo cách dẫn đến
   đến hành vi hạt nhân không mong muốn.

* Khi xử lý hồi quy, hãy đảm bảo rằng đó không phải là điều gì khác
   đã thay đổi song song với việc cập nhật kernel. Vấn đề chẳng hạn có thể là
   do phần mềm khác được cập nhật cùng lúc gây ra. Nó cũng có thể
   xảy ra tình cờ một thành phần phần cứng bị hỏng khi bạn khởi động lại
   vào kernel mới lần đầu tiên. Cập nhật hệ thống BIOS hoặc thay đổi
   một cái gì đó trong Cài đặt BIOS cũng có thể dẫn đến các vấn đề nhìn rất nhiều
   giống như hồi quy kernel.


Chuẩn bị cho trường hợp khẩn cấp
-----------------------

ZZ0000ZZ

Xin nhắc lại, bạn đang làm việc với máy tính, đôi khi nó làm những việc không mong muốn,
đặc biệt nếu bạn sử dụng các phần quan trọng như nhân của hệ điều hành của nó
hệ thống. Đó là những gì bạn sắp làm trong quá trình này. Vì vậy, hãy đảm bảo
tạo một bản sao lưu mới; cũng đảm bảo bạn có sẵn tất cả các công cụ để sửa chữa hoặc
cài đặt lại hệ điều hành cũng như mọi thứ bạn cần để khôi phục
sao lưu.


Đảm bảo kernel của bạn không được nâng cao
------------------------------------------

*Đảm bảo hệ thống của bạn không nâng cao nhân của nó bằng cách xây dựng thêm
    các mô-đun hạt nhân đang hoạt động, những giải pháp như DKMS có thể được thực hiện cục bộ
    mà bạn không hề biết.*

Nguy cơ báo cáo vấn đề của bạn bị bỏ qua hoặc bị từ chối sẽ tăng lên đáng kể nếu
kernel của bạn được nâng cao theo bất kỳ cách nào. Đó là lý do tại sao bạn nên loại bỏ hoặc vô hiệu hóa
các cơ chế như akmods và DKMS: xây dựng các mô-đun hạt nhân bổ sung
tự động, ví dụ như khi bạn cài đặt nhân Linux mới hoặc khởi động nó để
lần đầu tiên. Đồng thời xóa mọi mô-đun mà họ có thể đã cài đặt. Sau đó khởi động lại
trước khi tiếp tục.

Lưu ý, bạn có thể không biết rằng hệ thống của mình đang sử dụng một trong các giải pháp sau:
chúng thường được thiết lập một cách âm thầm khi bạn cài đặt đồ họa độc quyền của Nvidia
trình điều khiển, VirtualBox hoặc phần mềm khác yêu cầu một số hỗ trợ từ
mô-đun không phải là một phần của nhân Linux. Đó là lý do tại sao bạn có thể cần phải gỡ cài đặt
các gói có phần mềm như vậy để loại bỏ mọi mô-đun hạt nhân của bên thứ 3.


Kiểm tra cờ 'vết bẩn'
------------------

*Kiểm tra xem hạt nhân của bạn có bị 'nhiễm độc' hay không khi sự cố xảy ra, vì sự kiện này
    điều đó khiến kernel đặt cờ này có thể gây ra sự cố mà bạn gặp phải.*

Hạt nhân tự đánh dấu bằng cờ 'vết bẩn' khi có điều gì đó xảy ra có thể
dẫn đến những lỗi tiếp theo trông hoàn toàn không liên quan. Vấn đề bạn gặp phải có thể
đó là một lỗi nếu hạt nhân của bạn bị nhiễm độc. Đó là lý do vì sao bạn quan tâm đến
loại trừ điều này sớm trước khi đầu tư thêm thời gian vào quá trình này. Đây là
lý do duy nhất tại sao bước này lại ở đây, vì quá trình này sau này sẽ cho bạn biết
cài đặt kernel chính mới nhất; bạn sẽ cần phải kiểm tra lại cờ taint
sau đó, vì đó là lúc quan trọng vì đó là hạt nhân nên báo cáo sẽ tập trung vào
trên.

Trên hệ thống đang chạy, thật dễ dàng để kiểm tra xem kernel có bị nhiễm độc hay không: nếu ZZ0000ZZ trả về '0' thì kernel không bị nhiễm độc và
mọi thứ đều ổn. Việc kiểm tra tệp đó là không thể trong một số trường hợp; đó là
tại sao kernel cũng đề cập đến trạng thái vết bẩn khi nó báo cáo lỗi nội bộ
sự cố ('lỗi hạt nhân'), lỗi có thể phục hồi được ('lỗi hạt nhân') hoặc lỗi
lỗi không thể phục hồi trước khi tạm dừng hoạt động ('hoảng loạn hạt nhân'). Nhìn gần
phần đầu của thông báo lỗi được in khi một trong những lỗi này xảy ra và tìm kiếm
dòng bắt đầu bằng 'CPU:'. Nó sẽ kết thúc bằng 'Không bị nhiễm độc' nếu hạt nhân bị
không bị vấy bẩn khi nhận thấy vấn đề; nó đã bị nhiễm độc nếu bạn nhìn thấy 'Tainted:'
theo sau là một vài khoảng trắng và một số chữ cái.

Nếu kernel của bạn bị nhiễm độc, hãy nghiên cứu Documentation/admin-guide/tainted-kernels.rst
để tìm hiểu lý do tại sao. Cố gắng loại bỏ lý do. Thường thì nguyên nhân là do một trong những điều này
ba điều:

1. Đã xảy ra lỗi có thể phục hồi ('kernel Rất tiếc') và kernel bị nhiễm độc
    chính nó, vì kernel biết rằng sau đó nó có thể hoạt động sai theo những cách kỳ lạ
    điểm. Trong trường hợp đó, hãy kiểm tra kernel hoặc nhật ký hệ thống của bạn và tìm phần
    bắt đầu bằng điều này::

Rất tiếc: 0000 [#1] SMP

Đó là lần đầu tiên Rất tiếc kể từ khi khởi động, như '#1' giữa các dấu ngoặc hiển thị.
    Mọi Rất tiếc và bất kỳ vấn đề nào khác xảy ra sau thời điểm đó đều có thể là một
    vấn đề tiếp theo cho Rất tiếc lần đầu tiên đó, ngay cả khi cả hai trông hoàn toàn không liên quan.
    Hãy loại trừ điều này bằng cách loại bỏ nguyên nhân gây ra Lỗi đầu tiên và tái tạo
    vấn đề sau đó. Đôi khi chỉ cần khởi động lại là đủ, đôi khi
    một sự thay đổi về cấu hình sau khi khởi động lại có thể loại bỏ lỗi Rất tiếc.
    Nhưng đừng đầu tư quá nhiều thời gian vào việc này ở thời điểm này của quá trình, vì
    nguyên nhân gây ra lỗi Rất tiếc có thể đã được khắc phục trong nhân Linux mới hơn
    phiên bản bạn sẽ cài đặt sau trong quá trình này.

2. Hệ thống của bạn sử dụng phần mềm cài đặt các mô-đun hạt nhân của riêng nó, để
    ví dụ trình điều khiển đồ họa độc quyền của Nvidia hoặc VirtualBox. Hạt nhân
    tự gây hại khi tải mô-đun đó từ các nguồn bên ngoài (ngay cả khi
    chúng là Nguồn mở): đôi khi chúng gây ra lỗi trong kernel không liên quan
    khu vực và do đó có thể gây ra vấn đề bạn gặp phải. Do đó bạn phải
    ngăn không cho các mô-đun đó tải khi bạn muốn báo cáo sự cố cho
    Các nhà phát triển hạt nhân Linux. Hầu hết thời gian, cách dễ nhất để làm điều đó là:
    tạm thời gỡ cài đặt phần mềm đó bao gồm mọi mô-đun mà họ có thể có
    đã cài đặt. Sau đó khởi động lại.

3. Hạt nhân cũng tự làm hỏng chính nó khi nó tải một mô-đun nằm trong
    cây phân giai đoạn của nguồn nhân Linux. Đó là khu vực đặc biệt dành cho
    mã (chủ yếu là trình điều khiển) chưa hoàn thiện nhân Linux thông thường
    tiêu chuẩn chất lượng. Khi bạn báo cáo sự cố với mô-đun như vậy, đó là
    rõ ràng là không sao nếu hạt nhân bị nhiễm độc; chỉ cần đảm bảo mô-đun trong
    câu hỏi là lý do duy nhất cho vết bẩn. Nếu sự cố xảy ra trong một
    khởi động lại khu vực không liên quan và tạm thời chặn tải mô-đun
    bằng cách chỉ định ZZ0000ZZ làm tham số kernel (thay thế 'foo' bằng
    tên của mô-đun được đề cập).


Tài liệu cách tái tạo vấn đề
-------------------------------

*Viết lại một cách thô sơ cách tái hiện vấn đề. Nếu bạn giải quyết nhiều
    vấn đề cùng một lúc, tạo ghi chú riêng cho từng vấn đề và đảm bảo chúng
    hoạt động độc lập trên một hệ thống mới khởi động. Điều đó là cần thiết, vì mỗi vấn đề
    cần được báo cáo riêng cho các nhà phát triển kernel, trừ khi họ
    vướng víu mạnh mẽ.*

Nếu bạn giải quyết nhiều vấn đề cùng một lúc, bạn sẽ phải báo cáo từng vấn đề đó
riêng biệt vì chúng có thể được xử lý bởi các nhà phát triển khác nhau. mô tả
nhiều vấn đề khác nhau trong một báo cáo cũng khiến người khác khó xé bỏ
nó xa nhau. Do đó, chỉ tổng hợp các vấn đề trong một báo cáo nếu chúng rất nghiêm trọng.
vướng víu.

Ngoài ra, trong quá trình báo cáo, bạn sẽ phải kiểm tra xem sự cố có
xảy ra với các phiên bản kernel khác. Vì vậy, nó sẽ làm cho công việc của bạn dễ dàng hơn nếu
bạn biết chính xác cách tái tạo sự cố một cách nhanh chóng trên hệ thống mới khởi động.

Lưu ý: việc báo cáo các sự cố chỉ xảy ra một lần thường không có kết quả vì chúng
có thể được gây ra bởi sự đảo bit do bức xạ vũ trụ. Đó là lý do tại sao bạn nên
cố gắng loại trừ điều đó bằng cách tái tạo vấn đề trước khi đi xa hơn. Hãy thoải mái
bỏ qua lời khuyên này nếu bạn đủ kinh nghiệm để nhận ra lỗi một lần
do phần cứng bị lỗi ngoài vấn đề kernel hiếm khi xảy ra và do đó
rất khó để tái tạo.


Hồi quy trong kernel ổn định hay lâu dài?
----------------------------------------

*Nếu bạn đang gặp phải tình trạng hồi quy trong dòng phiên bản ổn định hoặc dài hạn
    (giả sử có gì đó bị hỏng khi cập nhật từ 5.10.4 lên 5.10.5), hãy cuộn xuống
    'Xử lý các hiện tượng hồi quy trong dòng hạt nhân ổn định và lâu dài'.*

Hồi quy trong một dòng phiên bản hạt nhân ổn định và lâu dài là điều mà
Các nhà phát triển Linux muốn khắc phục một cách tồi tệ, vì những vấn đề như vậy thậm chí còn không mong muốn hơn
hồi quy trong nhánh phát triển chính, vì chúng có thể nhanh chóng ảnh hưởng đến nhiều
mọi người. Do đó, các nhà phát triển muốn tìm hiểu về những vấn đề như vậy càng nhanh càng tốt.
có thể, do đó có một quy trình hợp lý để báo cáo chúng. Lưu ý,
hồi quy với dòng phiên bản kernel mới hơn (giả sử có gì đó bị hỏng khi chuyển đổi
từ 5.9.15 đến 5.10.5) không đủ điều kiện.


Kiểm tra nơi bạn cần báo cáo vấn đề của mình
-----------------------------------------

*Xác định vị trí trình điều khiển hoặc hệ thống con kernel dường như đang gây ra sự cố.
    Tìm hiểu cách thức và nơi các nhà phát triển mong đợi báo cáo. Lưu ý: hầu hết các
    lần này sẽ không phải là bugzilla.kernel.org vì các vấn đề thường cần được gửi
    bằng thư đến người bảo trì và danh sách gửi thư công khai.*

Điều quan trọng là gửi báo cáo của bạn đến đúng người, vì nhân Linux là một
dự án lớn và hầu hết các nhà phát triển của nó chỉ quen thuộc với một tập hợp con nhỏ của
nó. Ví dụ, khá nhiều lập trình viên chỉ quan tâm đến một trình điều khiển, ví dụ:
ví dụ một cho chip WiFi; nhà phát triển của nó có thể sẽ chỉ có ít hoặc không có
kiến thức về phần bên trong của các "hệ thống con" từ xa hoặc không liên quan, như TCP
ngăn xếp, hệ thống con PCIe/PCI, quản lý bộ nhớ hoặc hệ thống tệp.

Vấn đề là: nhân Linux thiếu trình theo dõi lỗi trung tâm nơi bạn có thể chỉ cần
gửi vấn đề của bạn và chuyển vấn đề đó đến tay các nhà phát triển cần biết về vấn đề đó.
Đó là lý do tại sao bạn phải tự mình tìm đúng nơi và cách để báo cáo vấn đề.
Bạn có thể làm điều đó với sự trợ giúp của tập lệnh (xem bên dưới), nhưng nó chủ yếu nhắm mục tiêu
các nhà phát triển và chuyên gia hạt nhân. Đối với những người khác, tệp MAINTAINERS là
nơi tốt hơn

Cách đọc tệp MAINTAINERS
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Để minh họa cách sử dụng tệp ZZ0000ZZ, hãy giả sử
WiFi trong Máy tính xách tay của bạn đột nhiên hoạt động sai sau khi cập nhật kernel. Trong đó
trường hợp đó có thể là sự cố trong trình điều khiển WiFi. Rõ ràng nó cũng có thể là một số
mã được xây dựng dựa trên đó, nhưng trừ khi bạn nghi ngờ điều gì đó tương tự dính vào
người lái xe. Nếu đó thực sự là thứ gì đó khác, thì các nhà phát triển trình điều khiển sẽ nhận được
đúng người có liên quan.

Đáng buồn thay, không có cách nào để kiểm tra mã nào đang điều khiển một phần cứng cụ thể
thành phần vừa phổ biến vừa dễ dàng.

Trong trường hợp có vấn đề với trình điều khiển WiFi, ví dụ bạn có thể muốn xem xét
đầu ra của ZZ0000ZZ, vì nó liệt kê các thiết bị trên bus PCI/PCIe và
mô-đun hạt nhân điều khiển nó::

[người dùng@thứ gì đó ~]$ lspci -k
       […]
       Bộ điều khiển mạng 3a:00.0: Bộ điều hợp mạng không dây Qualcomm Atheros QCA6174 802.11ac (rev 32)
         Hệ thống con: Bigfoot Networks, Inc. Thiết bị 1535
         Trình điều khiển hạt nhân đang sử dụng: ath10k_pci
         Mô-đun hạt nhân: ath10k_pci
       […]

Nhưng cách tiếp cận này sẽ không hiệu quả nếu chip WiFi của bạn được kết nối qua USB hoặc một số
xe buýt nội bộ khác. Trong những trường hợp đó, bạn có thể muốn kiểm tra trình quản lý WiFi của mình hoặc
đầu ra của ZZ0000ZZ. Tìm tên của mạng có vấn đề
giao diện, có thể giống như 'wlp58s0'. Tên này có thể được sử dụng như
cái này để tìm mô-đun điều khiển nó ::

[user@something ~]$ realpath --relative-to=/sys/module/ /sys/class/net/wlp58s0/device/driver/module
       ath10k_pci

Trong trường hợp những thủ thuật như thế này không giúp bạn tiến xa hơn, hãy thử tìm kiếm
internet về cách thu hẹp trình điều khiển hoặc hệ thống con được đề cập. Và nếu bạn
không chắc chắn đó là cái gì: chỉ cần thử suy đoán tốt nhất của bạn, sẽ có người giúp bạn nếu bạn
đoán kém.

Khi bạn đã biết trình điều khiển hoặc hệ thống con, bạn muốn tìm kiếm nó trong
Tệp MAINTAINERS. Trong trường hợp 'ath10k_pci' bạn sẽ không tìm thấy gì cả, vì
tên cụ thể quá. Đôi khi bạn sẽ cần tìm kiếm trên mạng để được trợ giúp;
nhưng trước khi làm như vậy, hãy thử một tên rút ngắn hoặc sửa đổi một chút khi tìm kiếm
MAINTAINERS, khi đó bạn có thể tìm thấy nội dung như thế này ::

QUALCOMM ATHEROS ATH10K WIRELESS DRIVER
       Thư: A. Một số con người <shuman@example.com>
       Danh sách gửi thư: ath10k@lists.infradead.org
       Trạng thái: Được hỗ trợ
       Trang web: ZZ0000ZZ
       SCM: git git://git.kernel.org/pub/scm/linux/kernel/git/kvalo/ath.git
       Tệp: trình điều khiển/net/không dây/ath/ath10k/

Lưu ý: phần mô tả dòng sẽ là chữ viết tắt, nếu bạn đọc kỹ
Tệp MAINTAINERS được tìm thấy trong thư mục gốc của cây nguồn Linux. 'Thư:' cho
ví dụ sẽ là 'M:', 'Danh sách gửi thư:' sẽ là 'L' và 'Trạng thái:' sẽ là 'S:'.
Phần gần đầu tập tin giải thích những từ viết tắt này và các từ viết tắt khác.

Đầu tiên hãy nhìn vào dòng 'Trạng thái'. Lý tưởng nhất là 'Được hỗ trợ' hoặc
'Duy trì'. Nếu nó ghi 'Lỗi thời' thì bạn đang sử dụng một số phương pháp lỗi thời
đã được thay thế bằng một giải pháp mới hơn mà bạn cần chuyển sang. Đôi khi mã
chỉ có người đưa ra 'Những cách sửa lỗi kỳ lạ' khi cảm thấy có động lực. Và với
'Mồ côi' bạn hoàn toàn không gặp may vì không còn ai quan tâm đến mã nữa.
Điều đó chỉ còn lại những lựa chọn sau: tự sắp xếp để chung sống với vấn đề, khắc phục nó
chính bạn, hoặc tìm một lập trình viên ở đâu đó sẵn sàng sửa nó.

Sau khi kiểm tra trạng thái, hãy tìm dòng bắt đầu bằng 'bugs:': nó sẽ cho biết
bạn có thể tìm trình theo dõi lỗi cụ thể của hệ thống con ở đâu để báo cáo vấn đề của mình. các
ví dụ trên không có dòng như vậy. Đó là trường hợp của hầu hết các phần, vì
Việc phát triển nhân Linux hoàn toàn được điều khiển bằng thư. Rất ít hệ thống con sử dụng
một trình theo dõi lỗi và chỉ một số trong số đó dựa vào bugzilla.kernel.org.

Trong trường hợp này và nhiều trường hợp khác, bạn phải tìm các dòng bắt đầu bằng
'Thư:' thay vào đó. Những người đó đề cập đến tên và địa chỉ email của
người duy trì mã cụ thể. Đồng thời tìm dòng bắt đầu bằng 'Gửi thư
list:', cho bạn biết danh sách gửi thư công khai nơi mã được phát triển.
Báo cáo của bạn sau này cần được gửi qua đường bưu điện đến những địa chỉ đó. Ngoài ra, đối với tất cả
báo cáo vấn đề được gửi qua email, hãy đảm bảo thêm Danh sách gửi thư hạt nhân Linux
(LKML) <linux-kernel@vger.kernel.org> sang CC. Đừng bỏ sót một trong hai việc gửi thư
danh sách khi gửi báo cáo vấn đề của bạn qua thư sau này! Người bảo trì là những người bận rộn
và có thể để lại một số công việc cho các nhà phát triển khác trong danh sách cụ thể của hệ thống con;
và LKML rất quan trọng để có một nơi có thể tìm thấy tất cả các báo cáo vấn đề.


Tìm người bảo trì với sự trợ giúp của tập lệnh
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Đối với những người có sẵn nguồn Linux, có tùy chọn thứ hai để tìm
nơi thích hợp để báo cáo: tập lệnh 'scripts/get_maintainer.pl' sẽ thử
để tìm tất cả mọi người để liên lạc. Nó truy vấn tệp MAINTAINERS và cần phải
được gọi với đường dẫn tới mã nguồn được đề cập. Đối với trình điều khiển được biên dịch dưới dạng
mô-đun nếu thường có thể được tìm thấy bằng một lệnh như thế này ::

$ modinfo ath10k_pci ZZ0000ZZ sed 's!/lib/modules/.*/kernel/!!; s!tên tệp:!!; s!\.ko\(\|\.xz\)!!'
       trình điều khiển/net/không dây/ath/ath10k/ath10k_pci.ko

Chuyển các phần này vào tập lệnh::

$ ./scripts/get_maintainer.pl -f driver/net/wireless/ath/ath10k*
       Một số con người <shuman@example.com> (người ủng hộ:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER)
       Một S. Human khác <asomehuman@example.com> (người bảo trì:NETWORKING DRIVERS)
       ath10k@lists.infradead.org (danh sách mở:QUALCOMM ATHEROS ATH10K WIRELESS DRIVER)
       linux-wireless@vger.kernel.org (danh sách mở:NETWORKING DRIVERS (WIRELESS))
       netdev@vger.kernel.org (danh sách mở:NETWORKING DRIVERS)
       linux-kernel@vger.kernel.org (danh sách mở)

Đừng gửi báo cáo của bạn cho tất cả họ. Gửi nó cho những người bảo trì, mà
tập lệnh gọi "người hỗ trợ:"; Ngoài ra CC danh sách gửi thư cụ thể nhất cho
mã cũng như Danh sách gửi thư hạt nhân Linux (LKML). Trong trường hợp này bạn do đó
sẽ cần gửi báo cáo tới 'Some Human <shuman@example.com>' với
'ath10k@lists.infradead.org' và 'linux-kernel@vger.kernel.org' trong CC.

Lưu ý: trong trường hợp bạn sao chép nguồn Linux bằng git, bạn có thể muốn gọi
ZZ0000ZZ lần thứ hai với ZZ0001ZZ. Kịch bản sau đó sẽ nhìn
vào lịch sử cam kết để tìm những người gần đây đã làm việc với mã trong
câu hỏi vì họ có thể giúp đỡ. Nhưng hãy sử dụng những kết quả này một cách cẩn thận, vì nó
có thể dễ dàng đưa bạn đi sai hướng. Ví dụ, điều đó xảy ra nhanh chóng trong
các khu vực hiếm khi được thay đổi (như trình điều khiển cũ hoặc không được bảo trì): đôi khi mã như vậy
được sửa đổi trong quá trình dọn dẹp cây bởi các nhà phát triển không quan tâm đến
trình điều khiển cụ thể nào cả.


Tìm kiếm các báo cáo hiện có, chạy lần thứ hai
---------------------------------------

*Tìm kiếm trong kho lưu trữ của trình theo dõi lỗi hoặc danh sách gửi thư được đề cập
    kỹ lưỡng để biết các báo cáo có thể phù hợp với vấn đề của bạn. Nếu bạn tìm thấy bất cứ điều gì,
    tham gia thảo luận thay vì gửi báo cáo mới.*

Như đã đề cập trước đó: báo cáo một vấn đề mà người khác đã
được đưa ra thường gây lãng phí thời gian cho tất cả những người có liên quan, đặc biệt là bạn
với tư cách là phóng viên. Đó là lý do tại sao bạn nên tìm kiếm lại báo cáo hiện tại ngay bây giờ
rằng bạn biết họ cần được báo cáo đến đâu. Nếu đó là danh sách gửi thư, bạn sẽ
thường tìm thấy kho lưu trữ của nó trên ZZ0000ZZ.

Nhưng một số danh sách được lưu trữ ở những nơi khác nhau. Ví dụ đó là trường hợp của
trình điều khiển WiFi ath10k được sử dụng làm ví dụ ở bước trước. Nhưng bạn sẽ thường xuyên
tìm các kho lưu trữ các danh sách này một cách dễ dàng trên mạng. Đang tìm kiếm 'lưu trữ
ath10k@lists.infradead.org' sẽ dẫn bạn đến ZZ0000ZZ,
ở trên cùng liên kết với nó
ZZ0001ZZ. Đáng buồn là điều này và
khá nhiều danh sách khác không tìm được cách tìm kiếm trong kho lưu trữ. Trong những trường hợp đó hãy sử dụng một
công cụ tìm kiếm internet thông thường và thêm một cái gì đó như
'site:lists.infradead.org/pipermail/ath10k/' theo cụm từ tìm kiếm của bạn, điều này sẽ giới hạn
kết quả vào kho lưu trữ tại URL đó.

Bạn cũng nên kiểm tra lại Internet, LKML và có thể bugzilla.kernel.org
vào thời điểm này. Nếu báo cáo của bạn cần được gửi vào trình theo dõi lỗi, bạn có thể muốn
để kiểm tra kho lưu trữ danh sách gửi thư của hệ thống con, vì ai đó có thể
chỉ báo cáo ở đó.

Để biết chi tiết về cách tìm kiếm và những việc cần làm nếu bạn tìm thấy các báo cáo phù hợp, hãy xem
"Tìm kiếm các báo cáo hiện có, chạy lần đầu" ở trên.

Đừng vội thực hiện bước này của quy trình báo cáo: dành 30 đến 60 phút
hoặc thậm chí nhiều thời gian hơn có thể giúp bạn và người khác tiết kiệm khá nhiều thời gian và rắc rối.


Cài đặt kernel mới để thử nghiệm
----------------------------------

*Trừ khi bạn đang chạy nhân Linux 'chính thống' mới nhất, nếu không thì tốt hơn
    đi và cài đặt nó cho quá trình báo cáo. Kiểm tra và báo cáo với
    Linux 'ổn định' mới nhất có thể là một lựa chọn thay thế có thể chấp nhận được ở một số nơi
    tình huống; trong cửa sổ hợp nhất mà thực sự có thể là tốt nhất
    cách tiếp cận này, nhưng trong giai đoạn phát triển đó, có thể là một ý tưởng tốt hơn nếu
    Dù sao thì hãy tạm dừng nỗ lực của bạn trong vài ngày. Dù bạn chọn phiên bản nào,
    lý tưởng nhất là sử dụng một chiếc 'vanilla' được chế tạo. Bỏ qua những lời khuyên này sẽ
    tăng nguy cơ báo cáo của bạn sẽ bị từ chối hoặc bỏ qua.*

Như đã đề cập trong phần giải thích chi tiết cho bước đầu tiên: Giống như hầu hết
lập trình viên, các nhà phát triển nhân Linux không muốn dành thời gian xử lý
báo cáo về các vấn đề thậm chí không xảy ra với mã hiện tại. Nó chỉ là một
lãng phí thời gian của mọi người, đặc biệt là của bạn. Đó là lý do tại sao nó có trong mọi người
quan tâm rằng bạn xác nhận rằng sự cố vẫn tồn tại với mã ngược dòng mới nhất
trước khi báo cáo nó. Bạn có quyền bỏ qua lời khuyên này, nhưng như đã nêu
sớm hơn: làm như vậy sẽ làm tăng đáng kể nguy cơ mà báo cáo sự cố của bạn có thể
bị từ chối hoặc đơn giản là bị bỏ qua.

Trong phạm vi của kernel "ngược dòng mới nhất" thường có nghĩa là:

* Cài đặt kernel chính; hạt nhân ổn định mới nhất có thể là một tùy chọn, nhưng
   hầu hết thời gian tốt hơn nên tránh. Hạt nhân dài hạn (đôi khi được gọi là 'LTS
   kernels') không phù hợp tại thời điểm này của quy trình. Tiểu mục tiếp theo
   giải thích tất cả điều này chi tiết hơn.

* Phần tiếp theo sẽ mô tả cách lấy và cài đặt một hạt nhân như vậy.
   Nó cũng nêu rõ rằng sử dụng kernel được biên dịch trước là tốt, nhưng tốt hơn là
   vani, có nghĩa là: nó được xây dựng bằng cách sử dụng các nguồn Linux lấy thẳng ZZ0000ZZ và không được sửa đổi hoặc nâng cao dưới bất kỳ hình thức nào.

Chọn phiên bản phù hợp để thử nghiệm
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Hãy truy cập ZZ0000ZZ để biết bạn đang sử dụng phiên bản nào
muốn sử dụng để thử nghiệm. Bỏ qua nút lớn màu vàng có nội dung 'Bản phát hành mới nhất'
và nhìn xuống bàn một chút. Ở trên cùng, bạn sẽ thấy một dòng bắt đầu bằng
dòng chính, phần lớn thời gian sẽ trỏ đến bản phát hành trước với một phiên bản
số như '5,8-rc2'. Nếu đúng như vậy, bạn sẽ muốn sử dụng dòng chính này
kernel để thử nghiệm, vì đó là nơi mà tất cả các bản sửa lỗi phải được áp dụng trước tiên. Đừng để
'rc' đó làm bạn sợ, những 'hạt nhân phát triển' này khá đáng tin cậy — và bạn
đã sao lưu như hướng dẫn ở trên phải không?

Khoảng hai trong số chín đến mười tuần, tuyến chính có thể chỉ cho bạn một
bản phát hành phù hợp với số phiên bản như '5.7'. Nếu điều đó xảy ra, hãy xem xét
tạm dừng quá trình báo cáo cho đến lần phát hành trước đầu tiên của báo cáo tiếp theo
phiên bản (5.8-rc1) hiển thị trên kernel.org. Đó là vì sự phát triển của Linux
chu kỳ sau đó sẽ ở trong 'cửa sổ hợp nhất' kéo dài hai tuần. Phần lớn những thay đổi và
tất cả những thứ xâm nhập sẽ được hợp nhất cho bản phát hành tiếp theo trong thời gian này. Đó là một chút
rủi ro hơn khi sử dụng đường chính trong giai đoạn này. Các nhà phát triển hạt nhân cũng thường xuyên
lúc đó khá bận và có thể không có thời gian rảnh để xử lý các báo cáo vấn đề. Đó là
cũng rất có thể một trong nhiều thay đổi được áp dụng trong quá trình hợp nhất
cửa sổ khắc phục sự cố bạn gặp phải; đó là lý do tại sao bạn sẽ sớm phải kiểm tra lại với
dù sao cũng là một phiên bản kernel mới hơn, như được nêu bên dưới trong phần 'Nhiệm vụ sau
báo cáo đã được đưa ra'.

Đó là lý do tại sao nên đợi cho đến khi cửa sổ hợp nhất kết thúc. Nhưng đừng
đến điều đó nếu bạn đang giải quyết một việc gì đó không nên chờ đợi. Trong trường hợp đó
hãy cân nhắc việc lấy kernel dòng chính mới nhất thông qua git (xem bên dưới) hoặc sử dụng
phiên bản ổn định mới nhất được cung cấp trên kernel.org. Việc sử dụng nó cũng được chấp nhận trong
dòng chính của trường hợp vì lý do nào đó hiện không phù hợp với bạn. An nói chung:
sử dụng nó để tái tạo vấn đề cũng tốt hơn là không báo cáo vấn đề
không hề.

Tốt hơn nên tránh sử dụng kernel ổn định mới nhất bên ngoài các cửa sổ hợp nhất, vì tất cả các bản sửa lỗi
phải được áp dụng cho đường chính trước. Đó là lý do tại sao kiểm tra đường dây chính mới nhất
kernel rất quan trọng: mọi vấn đề bạn muốn thấy đều được khắc phục trong các dòng phiên bản cũ hơn
cần phải được sửa trong dòng chính trước khi nó có thể được chuyển ngược lại, điều này có thể
mất vài ngày hoặc vài tuần. Một lý do khác: cách khắc phục mà bạn hy vọng có thể quá
khó khăn hoặc rủi ro cho việc backport; báo cáo vấn đề một lần nữa do đó khó có thể
thay đổi bất cứ điều gì.

Những khía cạnh này cũng là lý do tại sao hạt nhân dài hạn (đôi khi được gọi là "hạt nhân LTS")
không phù hợp với phần này của quy trình báo cáo: chúng quá xa so với
mã hiện tại. Do đó, hãy đi kiểm tra đường chính trước và làm theo quy trình
hơn nữa: nếu sự cố không xảy ra với đường dây chính, nó sẽ hướng dẫn bạn cách lấy
nó đã được sửa trong các dòng phiên bản cũ hơn, nếu điều đó nằm trong thẻ dành cho bản sửa lỗi được đề cập.

Cách lấy kernel Linux mới
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ: Đây thường là cách nhanh nhất, dễ dàng nhất và an toàn nhất
cách kiểm tra — đặc biệt là khi bạn chưa quen với nhân Linux. các
vấn đề: hầu hết những thứ được nhà phân phối hoặc kho bổ sung vận chuyển đều được xây dựng
từ các nguồn Linux đã sửa đổi. Do đó chúng không phải là vani và do đó thường
không phù hợp để thử nghiệm và báo cáo sự cố: những thay đổi có thể gây ra sự cố
bạn phải đối mặt hoặc ảnh hưởng đến nó bằng cách nào đó.

Nhưng bạn thật may mắn nếu bạn đang sử dụng một bản phân phối Linux phổ biến: trong khá lâu
một vài trong số đó bạn sẽ tìm thấy các kho lưu trữ trên mạng chứa các gói có phần mở rộng
dòng chính mới nhất hoặc Linux ổn định được xây dựng dưới dạng hạt nhân vanilla. Hoàn toàn ổn thôi
sử dụng những thứ này, chỉ cần đảm bảo từ mô tả của kho lưu trữ rằng chúng là vanilla hoặc
ít nhất là gần nó. Ngoài ra, hãy đảm bảo các gói chứa phiên bản mới nhất
các phiên bản được cung cấp trên kernel.org. Các gói có thể không phù hợp nếu chúng
đã cũ hơn một tuần, vì các hạt nhân chính và hạt nhân ổn định mới thường được phát hành
ít nhất một lần một tuần.

Xin lưu ý rằng sau này bạn có thể cần xây dựng hạt nhân của riêng mình một cách thủ công: đó là
đôi khi cần thiết để gỡ lỗi hoặc kiểm tra các bản sửa lỗi, như được mô tả sau trong phần này
tài liệu. Cũng nên lưu ý rằng các hạt nhân được biên dịch trước có thể thiếu các biểu tượng gỡ lỗi
là cần thiết để giải mã các thông báo mà kernel in ra khi xảy ra hoảng loạn, Rất tiếc, cảnh báo hoặc
BUG xảy ra; nếu bạn dự định giải mã chúng, tốt hơn hết bạn nên biên soạn một
kernel (xem phần cuối của tiểu mục này và phần có tiêu đề 'Giải mã
thông báo lỗi' để biết chi tiết).

ZZ0001ZZ: Các nhà phát triển và người dùng Linux có kinh nghiệm quen thuộc với git đều
thường được phục vụ tốt nhất bằng cách lấy các nguồn nhân Linux mới nhất trực tiếp từ
ZZ0000ZZ.
Những điều đó có thể đi trước một chút so với bản phát hành trước dòng chính mới nhất. Đừng lo lắng
về nó: chúng đáng tin cậy như một bản phát hành trước thích hợp, trừ khi kernel
chu kỳ phát triển hiện đang ở giữa cửa sổ hợp nhất. Nhưng ngay cả khi đó
họ khá đáng tin cậy.

ZZ0001ZZ: Những người không quen với git thường được phục vụ tốt nhất bởi
tải xuống các nguồn dưới dạng tarball từ ZZ0000ZZ.

Cách xây dựng kernel thực sự không được mô tả ở đây, như nhiều trang web giải thích
các bước cần thiết rồi. Nếu bạn chưa quen với nó, hãy cân nhắc làm theo một trong những
những cách thực hiện đó gợi ý sử dụng ZZ0000ZZ, vì nó cố gắng
chọn cấu hình kernel hiện tại của bạn và sau đó thử điều chỉnh nó
phần nào cho hệ thống của bạn. Điều đó không làm cho hạt nhân kết quả tốt hơn chút nào,
nhưng biên dịch nhanh hơn.

Lưu ý: Nếu bạn đang xử lý tình trạng hoảng loạn, Rất tiếc, cảnh báo hoặc BUG từ kernel,
vui lòng thử bật CONFIG_KALLSYMS khi định cấu hình kernel của bạn.
Ngoài ra, hãy bật CONFIG_DEBUG_KERNEL và CONFIG_DEBUG_INFO; cái
cái sau là cái có liên quan trong hai cái đó, nhưng chỉ có thể đạt được nếu bạn bật
cái trước. Hãy lưu ý CONFIG_DEBUG_INFO tăng dung lượng lưu trữ cần thiết để
xây dựng một hạt nhân khá nhiều. Nhưng điều đó đáng giá vì những lựa chọn này sẽ cho phép
sau này bạn có thể xác định chính xác dòng mã gây ra sự cố của mình. các
phần 'Giải mã thông báo lỗi' bên dưới giải thích điều này chi tiết hơn.

Nhưng hãy nhớ: Luôn ghi lại vấn đề gặp phải trong trường hợp nó xảy ra.
khó tái tạo. Gửi một báo cáo không được mã hóa còn tốt hơn là không báo cáo
vấn đề đó chút nào.


Kiểm tra cờ 'vết bẩn'
------------------

*Đảm bảo kernel bạn vừa cài đặt không bị 'làm hỏng' khi
    đang chạy.*

Như đã trình bày chi tiết hơn ở trên: kernel đặt cờ 'vết bẩn' khi
điều gì đó xảy ra có thể dẫn đến các lỗi tiếp theo trông có vẻ hoàn toàn
không liên quan. Đó là lý do tại sao bạn cần kiểm tra xem kernel bạn vừa cài đặt có
không đặt cờ này. Và nếu có, trong hầu hết các trường hợp bạn cần phải
loại bỏ lý do của nó trước khi bạn báo cáo các vấn đề xảy ra với nó. Xem
phần trên để biết chi tiết cách thực hiện điều đó.


Tái tạo vấn đề với kernel mới
-------------------------------------

*Tạo lại vấn đề với kernel bạn vừa cài đặt. Nếu nó không hiển thị
    ở trên đó, cuộn xuống phần hướng dẫn cho các vấn đề chỉ xảy ra với
    hạt nhân ổn định và lâu dài.*

Kiểm tra xem sự cố có xảy ra với phiên bản nhân Linux mới mà bạn vừa
đã cài đặt. Nếu nó đã được sửa ở đó rồi, hãy cân nhắc việc gắn bó với phiên bản này
và từ bỏ kế hoạch báo cáo vấn đề của bạn. Nhưng hãy nhớ rằng khác
người dùng vẫn có thể bị ảnh hưởng bởi nó, miễn là nó không được sửa ở chế độ ổn định
và phiên bản dài hạn từ kernel.org (và do đó hạt nhân của nhà cung cấp có nguồn gốc từ
những cái đó). Nếu bạn thích sử dụng một trong những thứ đó hoặc chỉ muốn giúp đỡ người dùng của họ,
hãy đi tới phần "Chi tiết về các vấn đề báo cáo chỉ xảy ra trong
dòng phiên bản kernel cũ hơn" bên dưới.


Tối ưu hóa mô tả để tái tạo vấn đề
---------------------------------------

*Tối ưu hóa ghi chú của bạn: cố gắng tìm và viết theo cách đơn giản nhất để
    tái tạo vấn đề của bạn. Đảm bảo rằng kết quả cuối cùng có tất cả những thông tin quan trọng
    chi tiết, đồng thời dễ đọc và dễ hiểu đối với người khác
    lần đầu tiên nghe về nó. Và nếu bạn học được điều gì đó trong này
    xử lý, hãy cân nhắc việc tìm kiếm lại các báo cáo hiện có về vấn đề này.*

Một báo cáo phức tạp không cần thiết sẽ khiến người khác khó hiểu được
báo cáo. Vì vậy, hãy cố gắng tìm một nhà tái tạo dễ dàng mô tả và
do đó dễ hiểu ở dạng viết. Bao gồm tất cả các chi tiết quan trọng, nhưng tại
đồng thời cố gắng giữ nó càng ngắn càng tốt.

Trong các bước trước, bạn có thể đã học được một hoặc hai điều về
vấn đề bạn gặp phải. Sử dụng kiến thức này và tìm kiếm lại các báo cáo hiện có
thay vào đó bạn có thể tham gia.


Giải mã thông báo lỗi
-----------------------

*Nếu thất bại của bạn liên quan đến 'hoảng loạn', 'Rất tiếc', 'cảnh báo' hoặc 'BUG', hãy cân nhắc
    giải mã nhật ký kernel để tìm dòng mã gây ra lỗi.*

Khi kernel phát hiện một vấn đề bên trong, nó sẽ ghi lại một số thông tin về
mã được thực thi. Điều này giúp có thể xác định chính xác đường trong
mã nguồn đã gây ra sự cố và cho biết cách gọi sự cố. Nhưng điều đó chỉ
hoạt động nếu bạn bật CONFIG_DEBUG_INFO và CONFIG_KALLSYMS khi định cấu hình
hạt nhân của bạn. Nếu bạn đã làm như vậy, hãy cân nhắc việc giải mã thông tin từ
nhật ký của kernel. Điều đó sẽ giúp bạn dễ dàng hiểu được điều gì dẫn đến
'hoảng loạn', 'Rất tiếc', 'cảnh báo' hoặc 'BUG', điều này làm tăng khả năng ai đó
có thể cung cấp một sửa chữa.

Việc giải mã có thể được thực hiện bằng một tập lệnh bạn tìm thấy trong cây nguồn Linux. Nếu bạn
đang chạy kernel mà bạn đã tự biên dịch trước đó, hãy gọi nó như thế này ::

[người dùng@thứ gì đó ~]$ sudo dmesg | ./linux-5.10.5/scripts/decode_stacktrace.sh ./linux-5.10.5/vmlinux

Nếu bạn đang chạy kernel vanilla đóng gói, có thể bạn sẽ phải cài đặt
các gói tương ứng với các biểu tượng gỡ lỗi. Sau đó gọi tập lệnh (mà bạn
có thể cần lấy từ các nguồn Linux nếu bản phân phối của bạn không đóng gói nó)
như thế này::

[người dùng@thứ gì đó ~]$ sudo dmesg | ./linux-5.10.5/scripts/decode_stacktrace.sh \
        /usr/lib/debug/lib/modules/5.10.10-4.1.x86_64/vmlinux /usr/src/kernels/5.10.10-4.1.x86_64/

Tập lệnh sẽ hoạt động trên các dòng nhật ký như sau, hiển thị địa chỉ của
mã mà kernel đang thực thi khi xảy ra lỗi::

[ 68.387301] RIP: 0010:test_module_init+0x5/0xffa [test_module]

Sau khi được giải mã, những dòng này sẽ trông như thế này::

[ 68.387301] RIP: 0010:test_module_init (/home/username/linux-5.10.5/test-module/test-module.c:16) test_module

Trong trường hợp này, mã thực thi được tạo từ tệp
'~/linux-5.10.5/test-module/test-module.c' và lỗi xảy ra bởi
hướng dẫn tìm thấy ở dòng '16'.

Kịch bản sẽ giải mã tương tự các địa chỉ được đề cập trong phần
bắt đầu bằng 'Theo dõi cuộc gọi', hiển thị đường dẫn đến hàm nơi
vấn đề xảy ra. Ngoài ra, tập lệnh sẽ hiển thị đầu ra của trình biên dịch mã cho
phần mã mà kernel đang thực thi.

Lưu ý, nếu bạn không thể làm việc này, chỉ cần bỏ qua bước này và đề cập đến
lý do trong báo cáo. Nếu bạn may mắn, nó có thể không cần thiết. Và nếu nó
là ai đó có thể giúp bạn giải quyết mọi việc. Cũng nên lưu ý rằng đây chỉ là một
một số cách để giải mã dấu vết ngăn xếp hạt nhân. Đôi khi các bước khác nhau sẽ
được yêu cầu truy xuất các chi tiết liên quan. Đừng lo lắng về điều đó, nếu đó là
cần thiết trong trường hợp của bạn, các nhà phát triển sẽ cho bạn biết phải làm gì.


Chăm sóc đặc biệt cho hồi quy
----------------------------

*Nếu vấn đề của bạn là sự hồi quy, hãy cố gắng thu hẹp thời điểm vấn đề xảy ra
    được giới thiệu càng nhiều càng tốt.*

Nhà phát triển Linux Linus Torvalds khẳng định rằng nhân Linux không bao giờ
trở nên tồi tệ hơn, đó là lý do tại sao anh ấy coi sự hồi quy là không thể chấp nhận được và muốn xem chúng
cố định nhanh chóng. Đó là lý do tại sao những thay đổi dẫn đến hồi quy thường
hoàn nguyên ngay lập tức nếu vấn đề họ gây ra không thể được giải quyết nhanh chóng
cách. Do đó, việc báo cáo một sự hồi quy giống như chơi một loại quân át chủ bài để
nhanh chóng sửa chữa một cái gì đó Nhưng để điều đó xảy ra thì sự thay đổi gây ra
sự hồi quy cần phải được biết. Thông thường, việc theo dõi là tùy thuộc vào phóng viên
tìm ra thủ phạm, vì người bảo trì thường không có thời gian hoặc thiết lập sẵn sàng để
tự tái tạo nó.

Để tìm ra sự thay đổi, có một quá trình gọi là 'chia đôi' mà tài liệu
Documentation/admin-guide/bug-bisect.rst mô tả chi tiết. Quá trình đó
thường sẽ yêu cầu bạn xây dựng khoảng 10 đến 20 kernel image, cố gắng
tái tạo vấn đề với từng vấn đề trước khi xây dựng vấn đề tiếp theo. Vâng, điều đó cần
đôi khi, nhưng đừng lo lắng, nó hoạt động nhanh hơn rất nhiều so với những gì mọi người nghĩ.
Nhờ 'tìm kiếm nhị phân', điều này sẽ dẫn bạn đến một cam kết trong nguồn
hệ thống quản lý mã gây ra sự hồi quy. Khi bạn tìm thấy nó, hãy tìm kiếm
mạng cho chủ đề thay đổi, id cam kết của nó và id cam kết rút gọn
(12 ký tự đầu tiên của id xác nhận). Điều này sẽ dẫn bạn đến hiện tại
báo cáo về nó, nếu có.

Lưu ý, việc chia đôi cần có một chút bí quyết mà không phải ai cũng có và khá nhiều
một chút nỗ lực mà không phải ai cũng sẵn sàng đầu tư. Tuy nhiên, đó là
rất khuyến khích tự mình thực hiện việc chia đôi. Nếu bạn thực sự không thể hoặc
không muốn đi theo con đường đó ít nhất hãy tìm ra kernel chính nào
giới thiệu hồi quy. Ví dụ: nếu có thứ gì đó bị hỏng khi chuyển từ
5.5.15 đến 5.8.4, sau đó thử ít nhất tất cả các bản phát hành chính trong khu vực đó (5.6,
5.7 và 5.8) để kiểm tra thời điểm nó xuất hiện lần đầu. Trừ khi bạn đang cố gắng tìm một
hồi quy trong kernel ổn định hoặc lâu dài, tránh thử nghiệm các phiên bản có số lượng
có ba phần (5.6.12, 5.7.8), vì điều đó làm cho kết quả khó có thể
diễn giải, điều này có thể khiến việc kiểm tra của bạn trở nên vô ích. Một khi bạn đã tìm được chuyên ngành
phiên bản đã giới thiệu hồi quy, vui lòng tiếp tục phần báo cáo
quá trình. Nhưng hãy nhớ: điều đó phụ thuộc vào vấn đề hiện tại nếu các nhà phát triển
sẽ có thể giúp đỡ mà không cần biết thủ phạm. Đôi khi họ có thể
nhận biết từ báo cáo muốn sai sót và có thể khắc phục; lần khác họ sẽ
không thể giúp đỡ trừ khi bạn thực hiện chia đôi.

Khi xử lý các hồi quy, hãy đảm bảo rằng vấn đề bạn gặp phải thực sự là do
kernel chứ không phải bởi cái gì khác, như đã nêu ở trên rồi.

Trong toàn bộ quá trình, hãy ghi nhớ: một vấn đề chỉ được coi là hồi quy nếu
kernel cũ hơn và kernel mới hơn được xây dựng với cấu hình tương tự. Đây có thể là
đạt được bằng cách sử dụng ZZ0000ZZ, như được giải thích chi tiết hơn bởi
Tài liệu/admin-guide/reporting-regressions.rst; tài liệu đó cũng
cung cấp rất nhiều thông tin khác về hồi quy mà bạn có thể muốn
nhận thức được.


Viết và gửi báo cáo
-------------------------

*Bắt đầu biên soạn báo cáo bằng cách viết mô tả chi tiết về
    vấn đề. Luôn đề cập đến một số điều: phiên bản kernel mới nhất bạn đã cài đặt
    để sao chép, Bản phân phối Linux được sử dụng và các ghi chú của bạn về cách
    tái hiện vấn đề. Lý tưởng nhất là tạo cấu hình xây dựng của kernel
    (.config) và đầu ra từ ZZ0000ZZ có sẵn ở đâu đó trên mạng và
    liên kết đến nó. Bao gồm hoặc tải lên tất cả thông tin khác có thể có liên quan,
    như đầu ra/ảnh chụp màn hình của Rất tiếc hoặc đầu ra từ ZZ0001ZZ. Một lần
    bạn đã viết phần chính này, chèn một đoạn văn dài bình thường lên trên nó
    phác thảo vấn đề và tác động một cách nhanh chóng. Ngoài ra thêm một câu
    mô tả ngắn gọn vấn đề và khiến mọi người đọc tiếp. Bây giờ đưa
    một tiêu đề hoặc chủ đề mô tả lại ngắn hơn. Vậy thì bạn đang
    sẵn sàng gửi hoặc gửi báo cáo giống như tệp MAINTAINERS đã nói với bạn, trừ khi
    bạn đang giải quyết một trong những 'vấn đề có mức độ ưu tiên cao': họ cần
    sự chăm sóc đặc biệt được giải thích trong 'Xử lý đặc biệt đối với các trường hợp có mức độ ưu tiên cao
    vấn đề' bên dưới.*

Bây giờ bạn đã chuẩn bị mọi thứ, đã đến lúc viết báo cáo. Làm thế nào để làm
điều đó được giải thích một phần bởi ba tài liệu được liên kết ở lời nói đầu ở trên.
Đó là lý do tại sao văn bản này sẽ chỉ đề cập đến một số điều cơ bản cũng như
những thứ cụ thể cho nhân Linux.

Có một thứ phù hợp với cả hai loại: những phần quan trọng nhất trong
báo cáo là tiêu đề/chủ đề, câu đầu tiên và đoạn đầu tiên.
Các nhà phát triển thường nhận được khá nhiều thư. Do đó họ thường chỉ mất một vài
giây để đọc lướt thư trước khi quyết định tiếp tục hoặc xem xét kỹ hơn. Như vậy: cái
phần trên cùng của báo cáo của bạn càng tốt thì khả năng ai đó
sẽ xem xét nó và giúp bạn. Và đó là lý do tại sao bạn nên bỏ qua chúng lúc này
và viết báo cáo chi tiết trước. ;-)

Những điều mỗi báo cáo nên đề cập
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mô tả chi tiết vấn đề của bạn xảy ra như thế nào với nhân vani tươi mà bạn
đã cài đặt. Cố gắng bao gồm các hướng dẫn từng bước bạn đã viết và tối ưu hóa
trước đó phác thảo cách bạn và lý tưởng nhất là những người khác có thể tái tạo vấn đề; trong
những trường hợp hiếm hoi mà điều đó là không thể, hãy thử mô tả những gì bạn đã làm
kích hoạt nó.

Đồng thời bao gồm tất cả các thông tin liên quan mà người khác có thể cần để hiểu được
vấn đề và môi trường của nó. Những gì thực sự cần thiết phụ thuộc rất nhiều vào vấn đề,
nhưng có một số điều bạn nên luôn luôn đưa vào:

* đầu ra từ ZZ0000ZZ, chứa nhân Linux
   số phiên bản và trình biên dịch được xây dựng cùng với nó.

* bản phân phối Linux mà máy đang chạy (ZZ0000ZZ)

* kiến ​​trúc của CPU và hệ điều hành (ZZ0000ZZ)

* nếu bạn đang xử lý phép hồi quy và thực hiện phép chia đôi, hãy đề cập đến
   chủ đề và id xác nhận của thay đổi gây ra thay đổi đó.

Trong nhiều trường hợp, điều khôn ngoan là cung cấp thêm hai thứ nữa cho những người đó.
đã đọc báo cáo của bạn:

* cấu hình được sử dụng để xây dựng nhân Linux của bạn (tệp '.config')

* thông báo của kernel mà bạn nhận được từ ZZ0000ZZ được ghi vào một tệp. làm
   chắc chắn rằng nó bắt đầu bằng một dòng như 'Linux phiên bản 5.8-1
   (foobar@example.com) (gcc (GCC) 10.2.1, GNU ld phiên bản 2.34) #1 SMP Thứ Hai tháng 8
   3 14:54:37 UTC 2020' Nếu thiếu thì những tin nhắn quan trọng từ đầu
   giai đoạn khởi động đã bị loại bỏ. Trong trường hợp này thay vào đó hãy xem xét sử dụng
   ZZ0001ZZ; Ngoài ra, bạn cũng có thể khởi động lại, sao chép
   vấn đề và gọi ZZ0002ZZ ngay sau đó.

Hai tệp này có dung lượng lớn, đó là lý do tại sao việc đặt chúng trực tiếp vào là một ý tưởng tồi.
báo cáo của bạn. Nếu bạn đang gửi vấn đề trong trình theo dõi lỗi thì hãy đính kèm chúng vào
tấm vé. Nếu bạn báo cáo vấn đề qua thư thì đừng đính kèm chúng vì điều đó làm cho
thư quá lớn; thay vào đó hãy thực hiện một trong những điều sau:

* Tải các tập tin lên một nơi nào đó công khai (trang web của bạn, dán tập tin công khai
   dịch vụ, một vé được tạo ra chỉ nhằm mục đích này trên ZZ0000ZZ, ...) và đính kèm một liên kết tới chúng trong
   báo cáo. Lý tưởng nhất là sử dụng thứ gì đó mà các tập tin vẫn có sẵn trong nhiều năm, như
   chúng có thể hữu ích cho ai đó trong nhiều năm tới; điều này chẳng hạn có thể
   xảy ra nếu năm hoặc mười năm nữa một nhà phát triển làm việc trên một số mã đã được
   đã thay đổi chỉ để khắc phục vấn đề của bạn.

* Đặt các tập tin sang một bên và đề cập rằng bạn sẽ gửi chúng sau
   trả lời thư của chính bạn. Chỉ cần nhớ thực sự làm điều đó khi báo cáo
   đã đi ra ngoài. ;-)

Những điều có thể là khôn ngoan để cung cấp
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Tùy thuộc vào vấn đề, bạn có thể cần thêm nhiều dữ liệu nền hơn. Đây là một
một vài gợi ý về những gì thường là tốt để cung cấp:

* Nếu bạn đang gặp phải 'cảnh báo', 'OOPS' hoặc 'hoảng loạn' từ kernel,
   bao gồm nó. Nếu bạn không thể sao chép và dán nó, hãy thử ghi lại dấu vết netconsole
   hoặc ít nhất là chụp ảnh màn hình.

* Nếu sự cố có thể liên quan đến phần cứng máy tính của bạn, hãy đề cập đến loại phần cứng nào
   của hệ thống bạn sử dụng. Ví dụ: nếu bạn gặp vấn đề với card đồ họa của mình,
   đề cập đến nhà sản xuất, kiểu thẻ và loại chip được sử dụng. Nếu đó là một
   máy tính xách tay nhắc đến tên của nó nhưng hãy cố gắng đảm bảo rằng nó có ý nghĩa. 'Dell XPS 13'
   ví dụ là không, vì nó có thể là của năm 2012; cái đó trông
   không khác mấy so với cái được bán hôm nay, nhưng ngoài điều đó ra thì cả hai đều có
   không có gì chung Do đó, trong những trường hợp như vậy, hãy thêm số model chính xác,
   ví dụ: '9380' hoặc '7390' cho các mẫu XPS 13 được giới thiệu trong năm 2019.
   Những cái tên như “Lenovo Thinkpad T590” cũng có phần mơ hồ: có
   các biến thể của máy tính xách tay này có và không có chip đồ họa chuyên dụng, vì vậy hãy thử
   để tìm tên model chính xác hoặc chỉ định các thành phần chính.

* Đề cập đến phần mềm có liên quan đang sử dụng. Nếu bạn gặp vấn đề với việc tải
   module, bạn muốn đề cập đến các phiên bản kmod, systemd và udev đang sử dụng.
   Nếu một trong các trình điều khiển DRM hoạt động sai, bạn muốn nêu rõ phiên bản của
   libdrm và Mesa; cũng chỉ định bộ tổng hợp Wayland của bạn hoặc X-Server và
   trình điều khiển của nó. Nếu bạn gặp vấn đề về hệ thống tập tin, hãy đề cập đến phiên bản của
   các tiện ích hệ thống tập tin tương ứng (e2fsprogs, btrfs-progs, xfsprogs, ...).

* Thu thập thông tin bổ sung từ hạt nhân có thể được quan tâm. các
   đầu ra từ ZZ0000ZZ chẳng hạn sẽ giúp người khác xác định những gì
   phần cứng bạn sử dụng. Nếu bạn gặp vấn đề với phần cứng, bạn thậm chí có thể muốn
   cung cấp đầu ra từ ZZ0001ZZ, vì điều đó cung cấp
   hiểu biết sâu sắc về cách các thành phần được cấu hình. Đối với một số vấn đề, nó có thể là
   thật tốt khi bao gồm nội dung của các tệp như ZZ0002ZZ,
   ZZ0003ZZ, ZZ0004ZZ, ZZ0005ZZ hoặc
   ZZ0006ZZ. Một số hệ thống con cũng cung cấp các công cụ để thu thập thông tin liên quan
   thông tin. Một công cụ như vậy là ZZ0007ZZ ZZ0008ZZ.

Những ví dụ đó sẽ cung cấp cho bạn một số ý tưởng về dữ liệu nào có thể phù hợp
đính kèm, nhưng bạn phải tự mình nghĩ xem điều gì sẽ có ích cho người khác biết.
Đừng lo lắng quá nhiều về việc quên thứ gì đó, vì các nhà phát triển sẽ yêu cầu
chi tiết bổ sung mà họ cần. Nhưng làm cho mọi thứ quan trọng có sẵn từ
sự bắt đầu làm tăng cơ hội ai đó sẽ xem xét kỹ hơn.


Phần quan trọng: phần đầu báo cáo của bạn
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Bây giờ bạn đã chuẩn bị xong phần chi tiết của báo cáo, hãy chuyển sang phần
phần quan trọng nhất: một vài câu đầu tiên. Vì vậy hãy lên đầu, thêm
đại loại như 'Mô tả chi tiết:' trước phần bạn vừa viết và
chèn hai dòng mới ở trên cùng. Bây giờ hãy viết một đoạn văn có độ dài bình thường
mô tả vấn đề một cách đại khái. Bỏ đi những chi tiết nhàm chán và tập trung vào
những phần quan trọng mà độc giả cần biết để hiểu nội dung của điều này; nếu bạn
nghĩ rằng lỗi này ảnh hưởng đến nhiều người dùng, hãy đề cập đến điều này để mọi người quan tâm.

Khi bạn đã làm xong, hãy chèn thêm hai dòng ở trên cùng và viết một câu
bản tóm tắt giải thích nhanh chóng nội dung của báo cáo. Sau đó bạn phải
thậm chí còn trừu tượng hơn và viết chủ đề/tiêu đề thậm chí còn ngắn hơn cho báo cáo.

Bây giờ bạn đã viết xong phần này, hãy dành chút thời gian để tối ưu hóa nó, vì đây là phần
phần quan trọng nhất trong báo cáo của bạn: rất nhiều người sẽ chỉ đọc phần này trước đây
họ quyết định xem việc đọc phần còn lại có dành thời gian hợp lý hay không.

Bây giờ hãy gửi hoặc gửi báo cáo giống như tệp ZZ0000ZZ đã nói
bạn, trừ khi đó là một trong những 'vấn đề có mức độ ưu tiên cao' đã nêu trước đó: trong
trường hợp đó vui lòng đọc tiểu mục tiếp theo trước khi gửi báo cáo tới
theo cách của nó.

Xử lý đặc biệt đối với các vấn đề có mức độ ưu tiên cao
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Báo cáo về các vấn đề có mức độ ưu tiên cao cần được xử lý đặc biệt.

ZZ0000ZZ: đảm bảo tiêu đề hoặc tiêu đề vé cũng như tiêu đề đầu tiên
Đoạn văn làm cho sự nghiêm trọng trở nên rõ ràng.

ZZ0000ZZ: đặt chủ đề của báo cáo bắt đầu bằng '[REGRESSION]'.

Trong trường hợp bạn thực hiện chia đôi thành công, hãy sử dụng tiêu đề của thay đổi đó
đã giới thiệu hồi quy như là phần thứ hai của chủ đề của bạn. Thực hiện báo cáo
cũng đề cập đến id cam kết của thủ phạm. Trong trường hợp chia đôi không thành công,
làm cho báo cáo của bạn đề cập đến phiên bản thử nghiệm mới nhất đang hoạt động tốt (giả sử 5.7)
và cái cũ nhất xảy ra sự cố (giả sử 5,8-rc1).

Khi gửi báo cáo qua thư, CC Linux sẽ hồi quy danh sách gửi thư
(regressions@lists.linux.dev). Trong trường hợp báo cáo cần được nộp lên một số trang web
Tracker, hãy tiếp tục làm như vậy. Sau khi nộp, hãy chuyển báo cáo qua đường bưu điện đến
danh sách hồi quy; CC người bảo trì và danh sách gửi thư cho hệ thống con trong
câu hỏi. Đảm bảo đưa báo cáo được chuyển tiếp vào nội tuyến, do đó không đính kèm báo cáo đó.
Đồng thời thêm một ghi chú ngắn ở đầu nơi bạn đề cập đến URL vào phiếu.

Khi gửi thư hoặc chuyển tiếp báo cáo, trong trường hợp chia đôi thành công, hãy thêm
tác giả của thủ phạm đối với người nhận; đồng thời CC cho mọi người trong chữ ký xác nhận của
chuỗi mà bạn tìm thấy ở cuối thông báo cam kết của nó.

ZZ0000ZZ: đối với những vấn đề này, bạn sẽ phải đánh giá xem liệu
rủi ro ngắn hạn đối với những người dùng khác sẽ phát sinh nếu thông tin chi tiết được tiết lộ công khai.
Nếu không phải như vậy, bạn chỉ cần tiếp tục báo cáo sự cố như được mô tả.
Đối với các vấn đề có nguy cơ như vậy, bạn sẽ cần điều chỉnh quy trình báo cáo
hơi:

* Nếu tệp MAINTAINERS hướng dẫn bạn báo cáo sự cố qua thư, đừng
   CC mọi danh sách gửi thư công khai.

* Nếu bạn phải gửi vấn đề vào trình theo dõi lỗi, hãy đảm bảo đánh dấu
   vé là 'riêng tư' hoặc 'vấn đề bảo mật'. Nếu trình theo dõi lỗi không
   cung cấp một cách để giữ báo cáo ở chế độ riêng tư, hãy quên nó đi và gửi báo cáo của bạn dưới dạng
   thay vào đó hãy gửi một thư riêng cho người bảo trì.

Trong cả hai trường hợp, hãy đảm bảo gửi báo cáo của bạn qua thư đến các địa chỉ
Danh sách tệp MAINTAINERS trong phần 'liên hệ bảo mật'. Lý tưởng nhất là trực tiếp CC
chúng khi gửi báo cáo qua đường bưu điện. Nếu bạn đã gửi nó vào trình theo dõi lỗi, hãy chuyển tiếp
văn bản báo cáo gửi tới các địa chỉ này; nhưng trên đó có ghi một ghi chú nhỏ
bạn đề cập rằng bạn đã gửi nó cùng với một liên kết đến vé.

Xem Tài liệu/quy trình/security-bugs.rst để biết thêm thông tin.


Nhiệm vụ sau khi báo cáo được đưa ra
--------------------------------

*Đợi phản ứng và tiếp tục tiến hành cho đến khi bạn có thể chấp nhận
    kết quả bằng cách này hay cách khác. Do đó phản ứng công khai và kịp thời
    cho bất kỳ yêu cầu. Kiểm tra các bản sửa lỗi được đề xuất. Thực hiện kiểm tra chủ động: kiểm tra lại với lúc
    ít nhất mọi ứng cử viên phát hành đầu tiên (RC) của phiên bản dòng chính mới và
    báo cáo kết quả của bạn. Gửi lời nhắc thân thiện nếu mọi thứ bị đình trệ. Và cố gắng
    hãy tự giúp mình nếu bạn không nhận được sự giúp đỡ nào hoặc nếu điều đó khiến bạn không hài lòng.*

Nếu báo cáo của bạn tốt và bạn thực sự may mắn thì một trong những nhà phát triển
có thể ngay lập tức phát hiện ra nguyên nhân gây ra sự cố; sau đó họ có thể viết một bản vá
để sửa nó, kiểm tra nó và gửi thẳng để tích hợp vào dòng chính trong khi
gắn thẻ nó để backport sau này tới các hạt nhân ổn định và lâu dài cần nó. Sau đó
tất cả những gì bạn cần làm là trả lời 'Cảm ơn rất nhiều' và chuyển sang phiên bản
với bản sửa lỗi sau khi nó được phát hành.

Nhưng kịch bản lý tưởng này hiếm khi xảy ra. Đó là lý do tại sao công việc chỉ mới bắt đầu
một khi bạn đã nhận được báo cáo. Những gì bạn sẽ phải làm tùy thuộc vào tình huống,
nhưng thường thì đó sẽ là những điều được liệt kê dưới đây. Nhưng trước khi đi sâu vào
chi tiết, dưới đây là một số điều quan trọng bạn cần ghi nhớ cho phần này
của quá trình.


Lời khuyên chung cho các tương tác tiếp theo
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ: Khi bạn gửi vấn đề vào trình theo dõi lỗi, hãy luôn
trả lời ở đó và không liên hệ riêng với bất kỳ nhà phát triển nào về vấn đề đó. cho
báo cáo được gửi qua thư luôn sử dụng chức năng 'Trả lời tất cả' khi trả lời bất kỳ thư nào
bạn nhận được. Điều đó bao gồm các thư có bất kỳ dữ liệu bổ sung nào bạn có thể muốn thêm
vào báo cáo của bạn: đi tới thư mục 'Đã gửi' của ứng dụng thư của bạn và sử dụng 'trả lời tất cả'
trên thư của bạn với báo cáo. Cách tiếp cận này sẽ đảm bảo việc gửi thư công khai
(các) danh sách và tất cả những người khác có liên quan theo thời gian vẫn được cập nhật; nó
cũng giữ nguyên chuỗi thư, điều này thực sự quan trọng đối với
danh sách gửi thư để nhóm tất cả các thư có liên quan lại với nhau.

Chỉ có hai trường hợp trong đó nhận xét trong trình theo dõi lỗi hoặc 'Trả lời tất cả'
là không phù hợp:

* Ai đó bảo bạn gửi thứ gì đó riêng tư.

* Bạn được yêu cầu gửi nội dung nào đó nhưng nhận thấy nội dung đó có nội dung nhạy cảm
   những thông tin cần được giữ kín. Trong trường hợp đó bạn có thể gửi nó
   riêng tư với nhà phát triển đã yêu cầu điều đó. Nhưng lưu ý trong vé hoặc một
   mail rằng bạn đã làm điều đó để mọi người khác biết rằng bạn đã tôn trọng yêu cầu đó.

ZZ0000ZZ: Trong phần này của
xử lý ai đó có thể yêu cầu bạn làm điều gì đó đòi hỏi kỹ năng mà bạn có thể
vẫn chưa thành thạo. Ví dụ: bạn có thể được yêu cầu sử dụng một số công cụ kiểm tra
bạn chưa bao giờ nghe nói đến; hoặc bạn có thể được yêu cầu áp dụng một bản vá cho
Nguồn nhân Linux để kiểm tra xem nó có giúp ích không. Trong một số trường hợp, việc gửi sẽ ổn thôi
một câu trả lời yêu cầu hướng dẫn cách thực hiện điều đó. Nhưng trước khi đi con đường đó hãy thử
để tự mình tìm ra câu trả lời bằng cách tìm kiếm trên internet; cách khác
hãy cân nhắc việc hỏi ý kiến ở những nơi khác. Ví dụ: hỏi một người bạn hoặc đăng
về nó tới một phòng chat hoặc diễn đàn mà bạn thường lui tới.

ZZ0000ZZ: Nếu bạn thực sự may mắn, bạn có thể nhận được phản hồi cho báo cáo của mình
trong vòng vài giờ. Nhưng hầu hết thời gian sẽ mất nhiều thời gian hơn, vì người bảo trì
nằm rải rác trên toàn cầu và do đó có thể ở múi giờ khác – một
nơi họ đã tận hưởng buổi tối không cần bàn phím.

Nói chung, các nhà phát triển kernel sẽ mất từ ​​1 đến 5 ngày làm việc để phản hồi
báo cáo. Đôi khi sẽ mất nhiều thời gian hơn vì họ có thể bận rộn với việc hợp nhất
windows, công việc khác, tham dự hội nghị dành cho nhà phát triển hoặc đơn giản là tận hưởng một thời gian dài
kỳ nghỉ hè.

'Các vấn đề có mức độ ưu tiên cao' (xem giải thích ở trên) là một ngoại lệ
ở đây: người bảo trì nên giải quyết chúng càng sớm càng tốt; đó là lý do tại sao bạn
nên đợi tối đa một tuần (hoặc chỉ hai ngày nếu có việc khẩn cấp)
trước khi gửi lời nhắc nhở thân thiện.

Đôi khi người bảo trì có thể không phản hồi kịp thời; khác
đôi khi có thể có những bất đồng, ví dụ như nếu một vấn đề được coi là
hồi quy hay không. Trong những trường hợp như vậy, hãy nêu mối quan ngại của bạn lên danh sách gửi thư và
yêu cầu người khác trả lời công khai hoặc riêng tư cách tiếp tục. Nếu thất bại, nó
có thể thích hợp để có được sự tham gia của cơ quan có thẩm quyền cao hơn. Trong trường hợp có WiFi
trình điều khiển sẽ là người bảo trì mạng không dây; nếu không có cấp độ cao hơn
người bảo trì hoặc tất cả những thứ khác đều thất bại, đó có thể là một trong những tình huống hiếm hoi mà
có thể mời Linus Torvalds tham gia.

ZZ0000ZZ: Mỗi lần phát hành trước lần đầu tiên ('rc1') của một sản phẩm mới
phiên bản kernel chính được phát hành, hãy đi và kiểm tra xem sự cố đã được khắc phục ở đó chưa
hoặc nếu có bất cứ điều gì quan trọng thay đổi. Đề cập đến kết quả trong phiếu hoặc trong một
thư bạn đã gửi để trả lời báo cáo của mình (đảm bảo rằng nó có tất cả những thư có trong CC
cho đến thời điểm đó đã tham gia vào cuộc thảo luận). Điều này sẽ hiển thị của bạn
cam kết và rằng bạn sẵn sàng giúp đỡ. Nó cũng cho các nhà phát triển biết nếu
vấn đề vẫn tồn tại và đảm bảo họ không quên nó. Một số khác
thỉnh thoảng kiểm tra lại (ví dụ với RC3, RC5 và trận chung kết) cũng là một cách tốt
ý tưởng, nhưng chỉ báo cáo kết quả của bạn nếu có điều gì đó liên quan thay đổi hoặc nếu bạn
dù sao cũng đang viết gì đó.

Với tất cả những điều chung chung này, hãy đi vào chi tiết về cách
để giúp giải quyết các vấn đề sau khi chúng được báo cáo.

Hỏi và yêu cầu kiểm tra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Dưới đây là nhiệm vụ của bạn trong trường hợp bạn nhận được phản hồi cho báo cáo của mình:

ZZ0000ZZ: Hầu hết thời gian nó sẽ là người bảo trì hoặc
nhà phát triển vùng mã cụ thể sẽ phản hồi báo cáo của bạn. Nhưng như
các vấn đề thường được báo cáo công khai, có thể là bất kỳ ai đang phản hồi —
bao gồm cả những người muốn giúp đỡ, nhưng cuối cùng có thể khiến bạn hoàn toàn thất vọng
theo dõi các câu hỏi hoặc yêu cầu của họ. Điều đó hiếm khi xảy ra, nhưng đó là một trong
nhiều lý do tại sao việc nhanh chóng tìm kiếm trên internet để xem bạn là ai là điều khôn ngoan
tương tác với. Bằng cách này, bạn cũng biết liệu báo cáo của bạn có được người khác nghe hay không.
đúng người, như một lời nhắc nhở cho người bảo trì (xem bên dưới) có thể theo thứ tự
sau này nếu cuộc thảo luận nhạt dần mà không dẫn đến một giải pháp thỏa đáng cho vấn đề.
vấn đề.

ZZ0000ZZ: Thường thì bạn sẽ được yêu cầu kiểm tra điều gì đó hoặc cung cấp
chi tiết bổ sung. Cố gắng cung cấp thông tin được yêu cầu sớm vì bạn có
sự chú ý của ai đó có thể giúp đỡ nhưng bạn càng có nguy cơ mất nó lâu hơn
chờ đợi; kết quả đó thậm chí có thể xảy ra nếu bạn không cung cấp thông tin trong vòng
một vài ngày làm việc.

ZZ0000ZZ: Khi bạn được yêu cầu kiểm tra bản vá chẩn đoán hoặc
có thể khắc phục được, hãy cố gắng kiểm tra nó kịp thời. Nhưng hãy làm điều đó đúng cách và thực hiện
chắc chắn không vội vàng: trộn lẫn mọi thứ có thể xảy ra dễ dàng và có thể dẫn đến nhiều điều
gây nhầm lẫn cho tất cả mọi người liên quan. Ví dụ, một sai lầm phổ biến là nghĩ
bản vá được đề xuất có bản sửa lỗi đã được áp dụng, nhưng thực tế thì không. Những điều như vậy
thỉnh thoảng xảy ra ngay cả với những người thử nghiệm có kinh nghiệm, nhưng hầu hết thời gian họ sẽ
chú ý khi kernel có bản sửa lỗi hoạt động giống như kernel không có bản sửa lỗi.

Phải làm gì khi không có gì đáng kể xảy ra
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Một số báo cáo sẽ không nhận được bất kỳ phản ứng nào từ nhân Linux chịu trách nhiệm
nhà phát triển; hoặc một cuộc thảo luận xung quanh vấn đề đã phát triển nhưng nhạt dần với
không có gì có chất lượng phát ra từ nó.

Trong những trường hợp này, hãy đợi hai (tốt hơn: ba) tuần trước khi gửi một lời mời thân thiện
lời nhắc: có thể người bảo trì đã rời xa bàn phím một thời gian khi
báo cáo của bạn đã đến hoặc có điều gì đó quan trọng hơn cần quan tâm. Khi nào
viết lời nhắc nhở, vui lòng hỏi xem bạn có cần điều gì khác từ phía bạn không
làm cho quả bóng chạy bằng cách nào đó. Nếu báo cáo được gửi qua đường bưu điện, hãy thực hiện việc đó trong
dòng đầu tiên của thư là thư trả lời cho thư đầu tiên của bạn (xem ở trên)
bao gồm trích dẫn đầy đủ của báo cáo gốc bên dưới: đó là một trong số ít
những tình huống mà 'TOFU' (Chữ trên, Trích dẫn đầy đủ) như vậy là đúng
tiếp cận, khi đó tất cả người nhận sẽ có thông tin chi tiết ngay lập tức
theo đúng thứ tự.

Sau lời nhắc, hãy đợi thêm ba tuần nữa để nhận được phản hồi. Nếu bạn vẫn không nhận được
phản ứng thích hợp, trước tiên bạn nên xem xét lại cách tiếp cận của mình. Bạn có thể thử
để tiếp cận nhầm người? Báo cáo có thể gây khó chịu hay như vậy
khó hiểu khi mọi người quyết định tránh xa nó hoàn toàn? Cách tốt nhất để
loại trừ các yếu tố đó: hiển thị báo cáo cho một hoặc hai người quen thuộc với FLOSS
đưa ra báo cáo và hỏi ý kiến của họ. Đồng thời yêu cầu họ cho lời khuyên của họ như thế nào
để tiến về phía trước. Điều đó có thể có nghĩa là: chuẩn bị một bản báo cáo tốt hơn và khiến những người đó
xem xét nó trước khi bạn gửi nó đi. Cách tiếp cận như vậy là hoàn toàn ổn; chỉ
đề cập rằng đây là báo cáo thứ hai và được cải tiến về vấn đề này và bao gồm một
liên kết đến báo cáo đầu tiên.

Nếu báo cáo phù hợp, bạn có thể gửi lời nhắc thứ hai; trong đó xin lời khuyên
tại sao báo cáo không nhận được bất kỳ phản hồi nào. Thời điểm thích hợp cho lời nhắc thứ hai này
mail ngay sau bản phát hành trước đầu tiên ('rc1') của nhân Linux mới
phiên bản đã được xuất bản, vì vậy bạn nên kiểm tra lại và cung cấp cập nhật trạng thái tại thời điểm đó
dù sao đi nữa (xem ở trên).

Nếu nhắc lại lần thứ hai mà không có phản ứng gì trong vòng một tuần, hãy thử
liên hệ với người bảo trì cấp cao hơn để xin lời khuyên: ngay cả những người bảo trì bận rộn
thì ít nhất cũng phải gửi một lời xác nhận nào đó.

Hãy nhớ chuẩn bị tinh thần cho sự thất vọng: lý tưởng nhất là những người bảo trì nên
phản ứng bằng cách nào đó với mọi báo cáo vấn đề, nhưng họ chỉ có nghĩa vụ khắc phục những vấn đề đó
'các vấn đề ưu tiên cao' đã nêu trước đó. Vì vậy, đừng quá tàn phá nếu bạn
nhận được câu trả lời kiểu như 'cảm ơn vì báo cáo, tôi có việc quan trọng hơn
các vấn đề cần giải quyết hiện tại và sẽ không có thời gian để xem xét vấn đề này
tương lai có thể thấy trước'.

Cũng có thể sau một số cuộc thảo luận trong trình theo dõi lỗi hoặc trên danh sách
không có gì xảy ra nữa và những lời nhắc nhở không giúp thúc đẩy mọi người tập thể dục
một sự sửa chữa. Những tình huống như vậy có thể rất tàn khốc, nhưng có thể xảy ra khi nó
nói đến việc phát triển nhân Linux. Điều này và một số lý do khác không
nhận trợ giúp được giải thích trong phần 'Tại sao một số vấn đề không nhận được bất kỳ phản hồi nào hoặc vẫn tiếp tục
chưa được sửa sau khi được báo cáo' ở gần cuối tài liệu này.

Đừng thất vọng nếu bạn không tìm thấy bất kỳ sự giúp đỡ nào hoặc nếu vấn đề cuối cùng lại xảy ra.
không được giải quyết: nhân Linux là FLOSS và do đó bạn vẫn có thể tự giúp mình.
Ví dụ: bạn có thể cố gắng tìm những người khác bị ảnh hưởng và hợp tác với
họ để giải quyết vấn đề. Một nhóm như vậy có thể chuẩn bị một báo cáo mới
cùng nhau đề cập đến số lượng bạn và tại sao đây là thứ mà trong bạn
tùy chọn sẽ được sửa chữa. Có lẽ cùng nhau bạn cũng có thể thu hẹp nguyên nhân gốc rễ
hoặc sự thay đổi dẫn đến sự hồi quy, điều này thường khiến việc phát triển một bản sửa lỗi
dễ dàng hơn. Và với một chút may mắn, có thể có ai đó trong nhóm biết
một chút về lập trình và có thể viết một bản sửa lỗi.


Tham khảo "Báo cáo hồi quy trong dòng hạt nhân ổn định và lâu dài"
------------------------------------------------------------------------------

Tiểu mục này cung cấp chi tiết về các bước bạn cần thực hiện nếu gặp phải
một sự hồi quy trong dòng hạt nhân ổn định và lâu dài.

Đảm bảo dòng phiên bản cụ thể vẫn được hỗ trợ
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Kiểm tra xem các nhà phát triển kernel có còn duy trì phiên bản kernel Linux không
    dòng bạn quan tâm: hãy vào trang đầu của kernel.org và đảm bảo rằng nó
    đề cập đến bản phát hành mới nhất của dòng phiên bản cụ thể mà không có
    Thẻ '[EOL]'.*

Hầu hết các dòng phiên bản kernel chỉ được hỗ trợ trong khoảng ba tháng, vì
duy trì chúng lâu hơn là khá nhiều công việc. Vì vậy, mỗi năm chỉ có một
được chọn và được hỗ trợ trong ít nhất hai năm (thường là sáu năm). Đó là lý do tại sao bạn
cần kiểm tra xem nhà phát triển kernel có còn hỗ trợ dòng phiên bản bạn quan tâm không
cho.

Lưu ý, nếu kernel.org liệt kê hai dòng phiên bản ổn định trên trang đầu, bạn
nên cân nhắc chuyển sang cái mới hơn và quên cái cũ đi:
hỗ trợ cho nó có thể sẽ sớm bị bỏ rơi. Rồi nó sẽ có cái “kết thúc cuộc đời”
(EOL) tem. Các dòng phiên bản đạt đến điểm đó vẫn được đề cập trên
trang đầu kernel.org trong một hoặc hai tuần nhưng không phù hợp để thử nghiệm và
báo cáo.

Tìm kiếm danh sách gửi thư ổn định
~~~~~~~~~~~~~~~~~~~~~~~~~~

ZZ0000ZZ

Có thể vấn đề bạn gặp phải đã được biết và đã được khắc phục hoặc sắp khắc phục. Do đó,
ZZ0000ZZ để biết các báo cáo về sự cố giống như của bạn. Nếu
bạn tìm thấy bất kỳ kết quả phù hợp nào, hãy cân nhắc tham gia thảo luận, trừ khi cách khắc phục
đã hoàn thành và dự kiến ​​sẽ sớm được áp dụng.

Tái tạo vấn đề với bản phát hành mới nhất
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Cài đặt bản phát hành mới nhất từ dòng phiên bản cụ thể dưới dạng vanilla
    hạt nhân. Đảm bảo hạt nhân này không bị nhiễm độc và vẫn hiển thị vấn đề, như
    vấn đề có thể đã được khắc phục ở đó. Nếu lần đầu tiên bạn nhận thấy
    vấn đề với kernel của nhà cung cấp, hãy kiểm tra bản dựng vanilla của phiên bản cuối cùng
    được biết đến là công việc cũng hoạt động tốt.*

Trước khi đầu tư thêm thời gian vào quá trình này, bạn muốn kiểm tra xem sự cố có
đã được sửa trong phiên bản mới nhất của dòng phiên bản mà bạn quan tâm.
Hạt nhân này phải là hạt nhân vani và không bị nhiễm độc trước khi xảy ra sự cố
xảy ra, như đã trình bày chi tiết ở trên trong phần "Cài đặt phiên bản mới
hạt nhân để thử nghiệm".

Lần đầu tiên bạn có nhận thấy sự hồi quy với nhân của nhà cung cấp không? Sau đó thay đổi
nhà cung cấp áp dụng có thể gây trở ngại. Bạn cần loại trừ điều đó bằng cách thực hiện
một cuộc kiểm tra lại. Nói có gì đó đã xảy ra khi bạn cập nhật từ 5.10.4-vendor.42 lên
5.10.5-nhà cung cấp.43. Sau đó, sau khi thử nghiệm bản phát hành 5.10 mới nhất như được nêu trong
đoạn trước hãy kiểm tra xem bản dựng vanilla của Linux 5.10.4 có hoạt động tốt như không
tốt. Nếu mọi thứ bị hỏng ở đó, thì vấn đề không được coi là ngược dòng
hồi quy và bạn cần chuyển về hướng dẫn từng bước chính để báo cáo
vấn đề.

Báo cáo hồi quy
~~~~~~~~~~~~~~~~~~~~~

*Gửi một báo cáo sự cố ngắn đến danh sách gửi thư ổn định của Linux
    (stable@vger.kernel.org) và CC danh sách gửi thư hồi quy Linux
    (hồi quy@lists.linux.dev); nếu bạn nghi ngờ nguyên nhân cụ thể
    hệ thống con, CC người bảo trì và danh sách gửi thư của nó. Mô tả đại khái các
    vấn đề và giải thích một cách lý tưởng cách tái tạo nó. Đề cập đến phiên bản đầu tiên
    điều đó cho thấy sự cố và phiên bản cuối cùng đang hoạt động tốt. Sau đó
    chờ hướng dẫn thêm.*

Khi báo cáo hồi quy xảy ra trong hạt nhân ổn định hoặc lâu dài
dòng (giả sử khi cập nhật từ 5.10.4 lên 5.10.5), một báo cáo ngắn gọn là đủ cho
sự khởi đầu để nhận được vấn đề được báo cáo một cách nhanh chóng. Do đó một mô tả sơ bộ về
danh sách gửi thư ổn định và hồi quy là tất cả những gì cần thiết; nhưng trong trường hợp bạn nghi ngờ
nguyên nhân trong một hệ thống con cụ thể, CC người bảo trì và danh sách gửi thư của nó
nữa, bởi vì điều đó sẽ đẩy nhanh tiến độ mọi việc.

And note, it helps developers a great deal if you can specify the exact version
đã giới thiệu vấn đề. Do đó, nếu có thể trong một khung thời gian hợp lý,
hãy thử tìm phiên bản đó bằng hạt vani. Giả sử có thứ gì đó bị hỏng khi
nhà phân phối của bạn đã phát hành bản cập nhật từ nhân Linux 5.10.5 lên 5.10.8. Sau đó như
đã hướng dẫn ở trên, hãy kiểm tra kernel mới nhất từ dòng phiên bản đó, chẳng hạn
5.10.9. Nếu nó có vấn đề, hãy thử bản vani 5.10.5 để đảm bảo rằng không có bản vá nào
nhà phân phối áp dụng can thiệp. Nếu vấn đề không tự biểu hiện ở đó,
thử 5.10.7 và sau đó (tùy thuộc vào kết quả) 5.10.8 hoặc 5.10.6 để tìm
phiên bản đầu tiên nơi mọi thứ bị hỏng. Đề cập đến nó trong báo cáo và nêu rõ rằng 5.10.9
vẫn bị hỏng.

Những gì đoạn trước phác thảo về cơ bản là một 'sự chia đôi' thô sơ bằng tay.
Khi báo cáo của bạn được đưa ra, bạn có thể được yêu cầu thực hiện một báo cáo thích hợp vì nó cho phép
xác định chính xác sự thay đổi gây ra sự cố (sau đó có thể dễ dàng nhận được
được hoàn nguyên để khắc phục sự cố nhanh chóng). Do đó hãy cân nhắc thực hiện phép chia đôi thích hợp
ngay nếu thời gian cho phép. Xem phần 'Quan tâm đặc biệt đến hiện tượng hồi quy' và
tài liệu Documentation/admin-guide/bug-bisect.rst để biết chi tiết về cách
thực hiện một. Trong trường hợp chia đôi thành công, hãy thêm tác giả của thủ phạm vào
những người nhận; đồng thời CC cho mọi người trong chuỗi đã được ký xác nhận mà bạn tìm thấy tại
phần cuối của thông điệp cam kết của nó.


Tham khảo "Báo cáo sự cố chỉ xảy ra trong các dòng phiên bản kernel cũ hơn"
-----------------------------------------------------------------------------

Phần này cung cấp chi tiết về các bước bạn cần thực hiện nếu không thể
tái tạo vấn đề của bạn bằng hạt nhân dòng chính, nhưng muốn thấy nó được sửa trong phiên bản cũ hơn
dòng phiên bản (hay còn gọi là hạt nhân ổn định và lâu dài).

Một số bản sửa lỗi quá phức tạp
~~~~~~~~~~~~~~~~~~~~~~~~~~

*Hãy chuẩn bị sẵn sàng cho khả năng thực hiện các bước tiếp theo
    có thể không giải quyết được vấn đề trong các bản phát hành cũ hơn: bản sửa lỗi có thể quá lớn
    hoặc có nguy cơ bị đưa trở lại đó.*

Ngay cả những thay đổi mã nhỏ và dường như rõ ràng đôi khi cũng đưa ra những thay đổi mới và
những vấn đề hoàn toàn bất ngờ. Người duy trì hạt nhân ổn định và lâu dài
rất ý thức được điều đó và do đó chỉ áp dụng những thay đổi đối với những hạt nhân này
trong các quy tắc được nêu trong Documentation/process/stable-kernel-rules.rst.

Ví dụ: những thay đổi phức tạp hoặc rủi ro không đủ điều kiện và do đó chỉ được áp dụng
đến đường chính. Các bản sửa lỗi khác rất dễ được chuyển sang bản ổn định mới nhất và
hạt nhân dài hạn, nhưng quá rủi ro để tích hợp vào hạt nhân cũ hơn. Vì vậy hãy nhận biết
bản sửa lỗi mà bạn đang hy vọng có thể là một trong những bản sửa lỗi không được đưa vào
phiên bản bạn quan tâm. Trong trường hợp đó bạn sẽ không còn lựa chọn nào khác
giải quyết vấn đề hoặc chuyển sang phiên bản Linux mới hơn, trừ khi bạn muốn
tự mình vá bản sửa lỗi vào hạt nhân của bạn.

Các chế phẩm thông thường
~~~~~~~~~~~~~~~~~~~

*Thực hiện ba bước đầu tiên trong phần "Chỉ báo cáo sự cố
    xảy ra trong các dòng phiên bản kernel cũ hơn" ở trên.*

Bạn cần thực hiện một số bước đã được mô tả trong phần khác của tài liệu này
hướng dẫn. Những bước đó sẽ cho phép bạn:

* Kiểm tra xem các nhà phát triển kernel có còn duy trì dòng phiên bản kernel Linux không
   bạn quan tâm đến.

* Tìm kiếm danh sách gửi thư ổn định của Linux để tìm các báo cáo đã thoát.

* Kiểm tra với bản phát hành mới nhất.


Kiểm tra lịch sử mã và tìm kiếm các cuộc thảo luận hiện có
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

*Tìm kiếm hệ thống kiểm soát phiên bản nhân Linux để tìm thay đổi đã được sửa
    sự cố trong dòng chính, vì thông báo cam kết của nó có thể cho bạn biết liệu cách khắc phục có hiệu quả hay không
    đã lên lịch cho việc backport rồi. Nếu bạn không tìm thấy bất cứ điều gì theo cách đó,
    tìm kiếm danh sách gửi thư thích hợp cho các bài viết thảo luận về vấn đề đó
    hoặc đánh giá ngang hàng các bản sửa lỗi có thể có; sau đó kiểm tra các cuộc thảo luận xem cách khắc phục có hiệu quả không
    được coi là không phù hợp để chuyển ngược lại. Nếu việc backporting không được xem xét tại
    tất cả, hãy tham gia cuộc thảo luận mới nhất, hỏi xem nó có trong thẻ không.*

Trong nhiều trường hợp, vấn đề bạn giải quyết sẽ xảy ra với đường dây chính, nhưng
đã sửa ở đó. Cam kết đã sửa nó cũng cần được đưa vào backport
để giải quyết vấn đề. Đó là lý do tại sao bạn muốn tìm kiếm nó hoặc bất kỳ
có rất nhiều cuộc thảo luận về nó.

* Trước tiên hãy thử tìm bản sửa lỗi trong kho Git chứa kernel Linux
   nguồn. Bạn có thể làm điều này với giao diện web ZZ0001ZZ
   hoặc gương ZZ0002ZZ của nó; nếu bạn có
   một bản sao cục bộ, bạn có thể tìm kiếm trên dòng lệnh bằng ZZ0000ZZ.

Nếu bạn tìm thấy cách khắc phục, hãy xem liệu thông báo cam kết ở gần cuối có chứa
   'thẻ ổn định' trông như thế này:

Cc: <stable@vger.kernel.org> # 5.4+

Nếu đúng như vậy, nhà phát triển đã đánh dấu bản sửa lỗi an toàn để chuyển ngược sang phiên bản
   dòng 5.4 trở lên. Hầu hết thời gian nó được áp dụng ở đó trong vòng hai
   tuần, nhưng đôi khi phải lâu hơn một chút.

* Nếu cam kết không cho bạn biết bất cứ điều gì hoặc nếu bạn không thể tìm ra cách khắc phục, hãy xem
   một lần nữa để thảo luận về vấn đề này. Tìm kiếm trên mạng với mục yêu thích của bạn
   công cụ tìm kiếm trên internet cũng như kho lưu trữ cho ZZ0000ZZ. Cũng đọc
   phần ZZ0001ZZ ở trên và làm theo
   hướng dẫn để tìm hệ thống con được đề cập: trình theo dõi lỗi hoặc gửi thư của nó
   danh sách lưu trữ có thể có câu trả lời mà bạn đang tìm kiếm.

* Nếu bạn thấy bản sửa lỗi được đề xuất, hãy tìm kiếm bản sửa lỗi đó trong hệ thống kiểm soát phiên bản dưới dạng
   đã nêu ở trên, vì cam kết có thể cho bạn biết liệu có thể mong đợi một backport hay không.

* Kiểm tra các cuộc thảo luận để tìm bất kỳ dấu hiệu nào mà việc khắc phục có thể quá rủi ro
     được chuyển ngược lại dòng phiên bản mà bạn quan tâm. Nếu đó là trường hợp bạn có
     để giải quyết vấn đề hoặc chuyển sang dòng phiên bản kernel có bản sửa lỗi
     đã được áp dụng.

* Nếu bản sửa lỗi không chứa thẻ ổn định và việc backport không được thảo luận,
     tham gia thảo luận: đề cập đến phiên bản mà bạn gặp phải vấn đề và phiên bản đó
     bạn muốn thấy nó được sửa chữa, nếu phù hợp.


Xin lời khuyên
~~~~~~~~~~~~~~

*Một trong những bước trước đây sẽ dẫn đến giải pháp. Nếu điều đó không hiệu quả
    ra ngoài, hãy hỏi người bảo trì về hệ thống con dường như đang gây ra sự cố
    vấn đề để được tư vấn; CC danh sách gửi thư cho hệ thống con cụ thể
    như danh sách gửi thư ổn định.*

Nếu ba bước trước không giúp bạn tiến gần hơn đến giải pháp thì chỉ có
chỉ còn một lựa chọn: xin lời khuyên. Làm điều đó trong thư bạn đã gửi cho người bảo trì
đối với hệ thống con nơi vấn đề có vẻ bắt nguồn từ đó; CC danh sách gửi thư
cho hệ thống con cũng như danh sách gửi thư ổn định (stable@vger.kernel.org).


Phụ lục: Tại sao việc báo cáo lỗi kernel hơi khó
=======================================================

Các nhà phát triển nhân Linux nhận thức rõ rằng việc báo cáo lỗi cho họ khó hơn
hơn so với các Dự án mã nguồn mở miễn phí/tự do khác. Nhiều nguyên nhân nằm ở chỗ
bản chất của hạt nhân, mô hình phát triển của Linux và cách thế giới sử dụng hạt nhân:

* *Hầu hết nhân của các bản phân phối Linux hoàn toàn không phù hợp để báo cáo lỗi
  ngược dòng.* Phần tham khảo ở trên đã giải thích chi tiết điều này:
  cơ sở mã lỗi thời cũng như các sửa đổi và tiện ích bổ sung dẫn đến lỗi kernel
  đã được khắc phục ở thượng nguồn từ lâu hoặc chưa bao giờ xảy ra ở đó trong lần đầu tiên
  nơi. Các nhà phát triển phần mềm Nguồn mở khác cũng gặp phải những vấn đề này,
  nhưng tình hình còn tệ hơn nhiều khi nói đến kernel, khi những thay đổi
  và tác động của chúng nghiêm trọng hơn nhiều -- đó là lý do tại sao nhiều nhà phát triển hạt nhân
  mong đợi các báo cáo với hạt nhân được xây dựng từ các nguồn mới và gần như chưa sửa đổi.

* ZZ0000ZZ Đó là vì Linux
  chủ yếu là trình điều khiển và có thể được sử dụng theo nhiều cách. Các nhà phát triển thường không
  có sẵn thiết lập phù hợp -- và do đó thường xuyên phải dựa vào lỗi
  các phóng viên để xác định nguyên nhân của vấn đề và thử nghiệm các giải pháp được đề xuất.

*ZZ0000ZZ Đó
  một lần nữa là và hiệu ứng gây ra bởi vô số tính năng và trình điều khiển, do
  điều mà nhiều nhà phát triển kernel biết rất ít về các lớp thấp hơn hoặc cao hơn có liên quan
  về mã của họ và thậm chí ít hơn về các lĩnh vực khác.

* *Thật khó để tìm nơi để báo cáo vấn đề, trong số những vấn đề khác, do thiếu
  của một trình theo dõi lỗi trung tâm.* Đây là điều mà ngay cả một số nhà phát triển hạt nhân cũng
  không thích, nhưng đó là tình huống hiện tại mà mọi người phải giải quyết.

* *Các hạt nhân ổn định và dài hạn chủ yếu được duy trì bởi một bộ phận 'ổn định' chuyên dụng
  team', chỉ xử lý các hồi quy được đưa ra trong phạm vi ổn định và dài hạn
  series.* Khi ai đó báo cáo một lỗi, chẳng hạn như sử dụng Linux 6.1.2, nhóm sẽ,
  do đó, hãy luôn hỏi xem đường dây chính có bị ảnh hưởng không: lỗi đã xảy ra chưa
  trong 6.1 hoặc xuất hiện với dòng chính mới nhất (ví dụ: 6.2-rc3), chúng có trong
  sự quan tâm sẽ chuyển nó cho các nhà phát triển thường xuyên, vì những người biết mã tốt nhất.

* ZZ0000ZZ Do đó, một số phản ứng
  lạnh lùng với các báo cáo về lỗi trong Linux 6.0 khi 6.1 đã ra mắt;
  thậm chí cái sau có thể không đủ khi hết 6.2-rc1. Một số cũng sẽ không
  rất hoan nghênh các báo cáo có 6.1.5 hoặc 6.1.6, vì vấn đề có thể là một
  hồi quy theo từng chuỗi cụ thể mà nhóm ổn định (xem ở trên) đã gây ra và phải khắc phục.

* ZZ0000ZZ Đôi khi điều này là do thiếu
  tài liệu phần cứng - ví dụ: khi trình điều khiển được xây dựng bằng cách sử dụng đảo ngược
  kỹ thuật hoặc được tiếp quản bởi các nhà phát triển thời gian rảnh rỗi khi phần cứng
  nhà sản xuất đã bỏ nó lại. Những lúc khác thậm chí không có ai báo cáo lỗi
  tới: khi người bảo trì tiếp tục mà không có người thay thế, mã của họ thường vẫn còn
  trong kernel miễn là nó hữu ích.

Một số khía cạnh này có thể được cải thiện để tạo điều kiện thuận lợi cho việc báo cáo lỗi -- nhiều khía cạnh
Các nhà phát triển nhân Linux nhận thức rõ điều này và sẽ rất vui nếu một số
các cá nhân hoặc một tổ chức sẽ thực hiện sứ mệnh này của họ.

..
   end-of-content
..
   This document is maintained by Thorsten Leemhuis <linux@leemhuis.info>. If
   you spot a typo or small mistake, feel free to let him know directly and
   he'll fix it. You are free to do the same in a mostly informal way if you
   want to contribute changes to the text, but for copyright reasons please CC
   linux-doc@vger.kernel.org and "sign-off" your contribution as
   Documentation/process/submitting-patches.rst outlines in the section "Sign
   your work - the Developer's Certificate of Origin".
..
   This text is available under GPL-2.0+ or CC-BY-4.0, as stated at the top
   of the file. If you want to distribute this text under CC-BY-4.0 only,
   please use "The Linux kernel developers" for author attribution and link
   this as source:
   https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git/plain/Documentation/admin-guide/reporting-issues.rst
..
   Note: Only the content of this RST file as found in the Linux kernel sources
   is available under CC-BY-4.0, as versions of this text that were processed
   (for example by the kernel's build system) might contain content taken from
   files which use a more restrictive license.