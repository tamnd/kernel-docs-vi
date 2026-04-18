.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/security/ipe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Thực thi chính sách toàn vẹn (IPE) - Tài liệu hạt nhân
=========================================================

.. NOTE::

   This is documentation targeted at developers, instead of administrators.
   If you're looking for documentation on the usage of IPE, please see
   :doc:`IPE admin guide </admin-guide/LSM/ipe>`.

Động lực lịch sử
---------------------

Vấn đề ban đầu thúc đẩy việc triển khai IPE là việc tạo
của một hệ thống bị khóa. Hệ thống này sẽ được đảm bảo an toàn ngay từ đầu và có
đảm bảo tính toàn vẹn mạnh mẽ đối với cả mã thực thi và các
ZZ0000ZZ trên hệ thống, điều này rất quan trọng đối với chức năng của nó. Những cái này
các tệp dữ liệu cụ thể sẽ không thể đọc được trừ khi chúng vượt qua tính toàn vẹn
chính sách. Một hệ thống kiểm soát truy cập bắt buộc sẽ có mặt và
kết quả là xattrs sẽ phải được bảo vệ. Điều này dẫn tới sự lựa chọn
về những gì sẽ cung cấp các tuyên bố về tính toàn vẹn. Lúc đó có hai
cơ chế chính được coi là có thể đảm bảo tính toàn vẹn cho hệ thống
với những yêu cầu sau:

1. Chữ ký IMA + EVM
  2. DM-Verity

Cả hai phương án đều đã được cân nhắc kỹ lưỡng, tuy nhiên lựa chọn sử dụng DM-Verity
trên IMA+EVM là ZZ0000ZZ trong trường hợp sử dụng ban đầu của IPE
là do ba lý do chính:

1. Bảo vệ các vectơ tấn công bổ sung:

* Với IMA+EVM, nếu không có giải pháp mã hóa, hệ thống sẽ dễ bị tấn công
      để tấn công ngoại tuyến chống lại các tệp dữ liệu cụ thể nói trên.

Không giống như các tệp thực thi, các thao tác đọc (như các thao tác trên dữ liệu được bảo vệ
      các tập tin), không thể được thực thi để được xác minh tính toàn vẹn trên toàn cầu. Điều này có nghĩa
      phải có một số dạng bộ chọn để xác định xem có nên đọc hay không
      thực thi chính sách toàn vẹn, hoặc không nên làm như vậy.

Vào thời điểm đó, việc này được thực hiện bằng nhãn kiểm soát truy cập bắt buộc. Một chiếc IMA
      chính sách sẽ chỉ ra nhãn nào cần xác minh tính toàn vẹn, nhãn nào
      đã trình bày một vấn đề: EVM sẽ bảo vệ nhãn, nhưng nếu kẻ tấn công có thể
      sửa đổi hệ thống tập tin ngoại tuyến, kẻ tấn công có thể xóa tất cả xattrs -
      bao gồm các nhãn SELinux sẽ được sử dụng để xác định xem
      tập tin phải tuân theo chính sách toàn vẹn.

Với DM-Verity, vì xattr được lưu như một phần của cây Merkel, nếu
      gắn kết ngoại tuyến xảy ra với hệ thống tập tin được bảo vệ bởi dm-verity,
      tổng kiểm tra không còn khớp và không thể đọc được tệp.

* Vì các tệp nhị phân của không gian người dùng được phân trang trong Linux, dm-verity cũng cung cấp
      bảo vệ bổ sung chống lại một thiết bị chặn thù địch. Trong một cuộc tấn công như vậy,
      thiết bị khối báo cáo nội dung phù hợp cho hàm băm IMA
      ban đầu, vượt qua kiểm tra tính toàn vẹn cần thiết. Sau đó, trên trang bị lỗi
      truy cập vào dữ liệu thực sẽ báo cáo tải trọng của kẻ tấn công. Kể từ khi
      dm-verity sẽ kiểm tra dữ liệu khi xảy ra lỗi trang (và ổ đĩa
      truy cập), cuộc tấn công này được giảm thiểu.

2. Hiệu suất:

* dm-verity cung cấp xác minh tính toàn vẹn theo yêu cầu vì các khối
      đọc so với yêu cầu toàn bộ tệp được đọc vào bộ nhớ
      xác nhận.

3. Tính đơn giản của việc ký kết:

* Không cần hai chữ ký (IMA, sau đó là EVM): một chữ ký bao gồm
      toàn bộ thiết bị khối.
    * Chữ ký có thể được lưu trữ bên ngoài siêu dữ liệu hệ thống tập tin.
    * Chữ ký hỗ trợ cơ sở hạ tầng ký dựa trên x.509.

Bước tiếp theo là chọn ZZ0000ZZ để thực thi cơ chế toàn vẹn.
Các yêu cầu tối thiểu cho chính sách là:

1. Bản thân chính sách phải được xác minh tính toàn vẹn (ngăn chặn những lỗi nhỏ
     tấn công chống lại nó).
  2. Bản thân chính sách phải có khả năng chống lại các cuộc tấn công khôi phục.
  3. Việc thực thi chính sách phải có chế độ cho phép.
  4. Chính sách phải có thể được cập nhật toàn bộ mà không cần
     khởi động lại.
  5. Cập nhật chính sách phải mang tính nguyên tử.
  6. Chính sách phải hỗ trợ ZZ0000ZZ của tác giả trước đó
     thành phần.
  7. Chính sách phải được kiểm tra vào bất kỳ thời điểm nào.

IMA, cơ chế chính sách toàn vẹn duy nhất vào thời điểm đó, đã được
được xem xét chống lại danh sách các yêu cầu này và không đáp ứng
tất cả các yêu cầu tối thiểu. Mở rộng IMA để bao gồm những điều này
các yêu cầu đã được xem xét nhưng cuối cùng bị loại bỏ vì lý do
hai lý do:

1. Rủi ro hồi quy; nhiều thay đổi trong số này sẽ dẫn đến
     thay đổi mã đáng kể thành IMA, mã này đã có trong
     kernel và do đó có thể ảnh hưởng đến người dùng.

2. IMA đã được sử dụng trong hệ thống để đo lường và chứng thực;
     tách chính sách đo lường khỏi chính sách toàn vẹn cục bộ
     việc thực thi được coi là thuận lợi.

Vì những lý do này, người ta đã quyết định tạo ra một LSM mới,
trách nhiệm của họ sẽ chỉ là việc thực thi chính sách liêm chính ở địa phương.

Vai trò và phạm vi
--------------

IPE, đúng như tên gọi của nó, về cơ bản là một cơ chế thực thi chính sách toàn vẹn
giải pháp; IPE không bắt buộc phải cung cấp tính toàn vẹn như thế nào mà thay vào đó
để lại quyết định đó cho quản trị viên hệ thống thiết lập thanh bảo mật,
thông qua các cơ chế mà họ lựa chọn phù hợp với nhu cầu cá nhân của họ.
Có một số giải pháp toàn vẹn khác nhau cung cấp một cách khác nhau
mức độ đảm bảo an ninh; và IPE cho phép quản trị viên hệ thống thể hiện chính sách cho
về mặt lý thuyết tất cả chúng.

IPE không có cơ chế vốn có để đảm bảo tính toàn vẹn.
Thay vào đó, có sẵn các lớp hiệu quả hơn để xây dựng các hệ thống
có thể đảm bảo tính toàn vẹn. Điều quan trọng cần lưu ý là cơ chế chứng minh
tính toàn vẹn độc lập với chính sách thực thi yêu cầu về tính toàn vẹn đó.

Do đó, IPE được thiết kế xoay quanh:

1. Dễ dàng tích hợp với các nhà cung cấp tính toàn vẹn.
  2. Dễ sử dụng đối với quản trị viên/quản trị viên hệ thống nền tảng.

Lý do thiết kế:
-----------------

IPE được thiết kế sau khi đánh giá các giải pháp chính sách toàn vẹn hiện có
trong các hệ điều hành và môi trường khác. Trong cuộc khảo sát này của người khác
triển khai, có một số cạm bẫy được xác định:

1. Con người không thể đọc được các chính sách, thường yêu cầu mã nhị phân
     dạng trung gian.
  2. Một hành động duy nhất, không thể tùy chỉnh được ngầm thực hiện làm mặc định.
  3. Việc gỡ lỗi chính sách yêu cầu các bước thủ công để xác định quy tắc nào đã bị vi phạm.
  4. Việc soạn thảo một chính sách đòi hỏi kiến thức chuyên sâu về hệ thống lớn hơn,
     hoặc hệ điều hành.

IPE cố gắng tránh tất cả những cạm bẫy này.

Chính sách
~~~~~~

Văn bản thuần túy
^^^^^^^^^^

Chính sách của IPE là văn bản thuần túy. Điều này giới thiệu các tệp chính sách lớn hơn một chút so với
LSM khác, nhưng giải quyết được hai vấn đề chính xảy ra với một số chính sách toàn vẹn
giải pháp trên các nền tảng khác.

Vấn đề đầu tiên là bảo trì và sao chép mã. Đối với chính sách của tác giả,
chính sách phải là một dạng biểu diễn chuỗi nào đó (có cấu trúc,
thông qua XML, JSON, YAML, v.v.), để cho phép tác giả chính sách hiểu
những gì đang được viết Trong thiết kế chính sách nhị phân giả định, bộ tuần tự hóa
là cần thiết để viết chính sách từ dạng con người có thể đọc được sang dạng nhị phân
và cần có bộ giải tuần tự hóa để diễn giải dạng nhị phân thành dữ liệu
cấu trúc trong hạt nhân.

Cuối cùng, sẽ cần một bộ giải tuần tự khác để chuyển đổi nhị phân từ
trở lại dạng con người có thể đọc được với càng nhiều thông tin được bảo tồn. Điều này là do một
người sử dụng hệ thống kiểm soát truy cập này sẽ phải giữ một bảng tra cứu tổng kiểm tra
và chính tệp gốc để cố gắng hiểu những chính sách nào đã được triển khai
trên hệ thống này và những chính sách nào không có. Đối với một người dùng, điều này có thể ổn,
vì các chính sách cũ có thể bị loại bỏ gần như ngay lập tức sau khi quá trình cập nhật diễn ra.
Đối với người dùng quản lý nhóm máy tính lên tới hàng nghìn, nếu không phải là hàng trăm nghìn,
với nhiều hệ điều hành khác nhau và nhiều nhu cầu hoạt động khác nhau,
điều này nhanh chóng trở thành một vấn đề, vì các chính sách cũ từ nhiều năm trước có thể vẫn còn tồn tại,
nhanh chóng dẫn đến nhu cầu khôi phục chính sách hoặc tài trợ cho cơ sở hạ tầng rộng khắp
để theo dõi nội dung của mỗi chính sách.

Hiện nay, với ba bộ tuần tự hóa/bộ giải tuần tự riêng biệt, việc bảo trì trở nên tốn kém. Nếu
chính sách tránh định dạng nhị phân, chỉ có một bộ nối tiếp được yêu cầu: từ
dạng con người có thể đọc được vào cấu trúc dữ liệu trong kernel, tiết kiệm chi phí bảo trì mã,
và duy trì khả năng hoạt động.

Vấn đề thứ hai với định dạng nhị phân là vấn đề về tính minh bạch. Như điều khiển IPE
quyền truy cập dựa trên sự tin cậy của tài nguyên hệ thống, chính sách của nó cũng phải được
đáng tin cậy để được thay đổi. Điều này được thực hiện thông qua chữ ký, dẫn đến cần
ký kết như một quá trình. Việc ký kết, như một quá trình, thường được thực hiện bằng một
thanh bảo mật cao, vì bất kỳ thứ gì được ký đều có thể được sử dụng để tấn công tính toàn vẹn
các hệ thống thực thi. Điều quan trọng nữa là, khi ký một cái gì đó,
người ký nhận thức được những gì họ đang ký. Chính sách nhị phân có thể gây ra
sự xáo trộn của thực tế đó; những gì người ký nhìn thấy là một đốm màu nhị phân mờ đục. A
Mặt khác, chính sách văn bản thuần túy, người ký sẽ thấy chính sách thực tế
trình để ký.

Chính sách khởi động
~~~~~~~~~~~

IPE, nếu được cấu hình phù hợp, có thể thực thi chính sách ngay khi
kernel được khởi động và usermode bắt đầu. Điều đó ngụ ý một số mức độ lưu trữ
của chính sách để áp dụng thời điểm chế độ người dùng bắt đầu. Nói chung, việc lưu trữ đó
có thể được xử lý theo một trong ba cách:

1. (Các) tệp chính sách nằm trên đĩa và kernel tải chính sách trước
     đến một đường dẫn mã sẽ dẫn đến quyết định thực thi.
  2. (Các) tệp chính sách được bộ tải khởi động chuyển tới kernel, ai
     phân tích chính sách.
  3. Có một tệp chính sách được biên dịch vào kernel
     được phân tích cú pháp và thực thi khi khởi tạo.

Tùy chọn đầu tiên có vấn đề: kernel đọc tệp từ không gian người dùng
thường không được khuyến khích và rất không phổ biến trong kernel.

Tùy chọn thứ hai cũng có vấn đề: Linux hỗ trợ nhiều loại bootloader
trên toàn bộ hệ sinh thái của nó - mọi bộ nạp khởi động sẽ phải hỗ trợ điều này
phương pháp mới hoặc phải có nguồn độc lập. Nó có thể sẽ
dẫn đến những thay đổi mạnh mẽ hơn đối với quá trình khởi động kernel hơn mức cần thiết.

Tùy chọn thứ ba là tốt nhất nhưng điều quan trọng cần lưu ý là chính sách
sẽ chiếm không gian đĩa so với kernel mà nó được biên dịch. Điều quan trọng là
giữ cho chính sách này đủ khái quát để không gian người dùng có thể tải một chính sách mới, nhiều hơn
chính sách phức tạp nhưng đủ hạn chế để không ủy quyền quá mức
và gây ra các vấn đề về bảo mật.

Initramfs cung cấp cách thiết lập đường dẫn khởi động này. các
kernel bắt đầu với một chính sách tối thiểu, chỉ tin cậy vào initramfs. Bên trong
initramfs, khi rootfs thực được gắn kết, nhưng chưa được chuyển sang,
nó triển khai và kích hoạt một chính sách tin cậy vào hệ thống tập tin gốc mới.
Điều này ngăn chặn việc ủy quyền quá mức ở bất kỳ bước nào và giữ chính sách kernel
đến kích thước tối thiểu.

Khởi động
^^^^^^^

Tuy nhiên, không phải mọi hệ thống đều bắt đầu bằng initramfs, vì vậy chính sách khởi động
được biên dịch vào kernel sẽ cần một số tính linh hoạt để thể hiện mức độ tin cậy
được thiết lập cho giai đoạn khởi động tiếp theo. Để đạt được mục đích này, nếu chúng ta chỉ
biến chính sách được biên dịch thành chính sách IPE đầy đủ, nó cho phép các nhà xây dựng hệ thống
để thể hiện các yêu cầu khởi động giai đoạn đầu một cách thích hợp.

Chính sách có thể cập nhật, không cần khởi động lại
~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Khi các yêu cầu thay đổi theo thời gian (các lỗ hổng được tìm thấy trong
các ứng dụng đáng tin cậy, cuộn phím, vân vân), cập nhật kernel để đáp ứng
những mục tiêu bảo mật đó không phải lúc nào cũng là một lựa chọn phù hợp, vì các bản cập nhật không
luôn không có rủi ro và việc chặn bản cập nhật bảo mật khiến hệ thống dễ bị tấn công.
Điều này có nghĩa là IPE yêu cầu một chính sách có thể được cập nhật hoàn toàn (cho phép
thu hồi chính sách hiện tại) từ nguồn bên ngoài vào kernel (cho phép
các chính sách được cập nhật mà không cần cập nhật kernel).

Ngoài ra, do kernel không có trạng thái giữa các lần gọi và đọc
các tệp chính sách ra khỏi đĩa từ không gian kernel là một ý tưởng tồi (tm), thì
cập nhật chính sách phải được thực hiện khởi động lại.

Để cho phép cập nhật từ nguồn bên ngoài, nó có thể có khả năng độc hại,
vì vậy chính sách này cần phải có cách để được xác định là đáng tin cậy. Đây là
được thực hiện thông qua chữ ký được nối với nguồn tin cậy trong kernel. Tùy tiện,
đây là ZZ0000ZZ, một chiếc móc khóa ban đầu được
được điền vào thời gian biên dịch kernel, vì điều này phù hợp với kỳ vọng rằng
tác giả của chính sách được biên soạn ở trên là cùng một thực thể có thể
triển khai cập nhật chính sách.

Chống Rollback / Chống phát lại
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Theo thời gian, các lỗ hổng được tìm thấy và các tài nguyên đáng tin cậy có thể không được
được tin tưởng nữa. Chính sách của IPE cũng không ngoại lệ. có thể có
trường hợp tác giả chính sách nhầm lẫn triển khai chính sách không an toàn,
trước khi sửa nó bằng một chính sách an toàn.

Giả sử rằng ngay khi chính sách không an toàn được ký và kẻ tấn công
có được chính sách không an toàn, IPE cần một cách để ngăn chặn việc khôi phục
từ bản cập nhật chính sách bảo mật đến bản cập nhật chính sách không an toàn.

Ban đầu, chính sách của IPE có thể có một phiên bản chính sách cho biết
phiên bản bắt buộc tối thiểu trên tất cả các chính sách có thể hoạt động trên
hệ thống. Điều này sẽ ngăn chặn việc khôi phục trong khi hệ thống đang hoạt động.

.. WARNING::

  However, since the kernel is stateless across boots, this policy
  version will be reset to 0.0.0 on the next boot. System builders
  need to be aware of this, and ensure the new secure policies are
  deployed ASAP after a boot to ensure that the window of
  opportunity is minimal for an attacker to deploy the insecure policy.

Hành động ngầm định:
~~~~~~~~~~~~~~~~~

Vấn đề về hành động ngầm chỉ trở nên rõ ràng khi bạn xem xét
một mức độ hỗn hợp của các thanh bảo mật trên nhiều hoạt động trong một hệ thống.
Ví dụ, hãy xem xét một hệ thống có sự đảm bảo tính toàn vẹn mạnh mẽ
trên cả mã thực thi và ZZ0000ZZ cụ thể trên hệ thống,
điều đó rất quan trọng đối với chức năng của nó. Trong hệ thống này, ba loại chính sách
có thể:

1. Chính sách không phù hợp với bất kỳ quy tắc nào trong chính sách dẫn đến
     trong hành động bị từ chối.
  2. Một chính sách không phù hợp với bất kỳ quy tắc nào trong chính sách
     trong hành động được phép.
  3. Một chính sách trong đó hành động được thực hiện khi không có quy tắc nào phù hợp là
     do tác giả chính sách quy định.

Tùy chọn đầu tiên có thể đưa ra chính sách như thế này ::

op=EXECUTE tính toàn vẹn_verified=YES hành động=ALLOW

Trong hệ thống ví dụ, điều này hoạt động tốt đối với các tệp thực thi, vì tất cả
các tệp thực thi phải có đảm bảo tính toàn vẹn, không có ngoại lệ. các
vấn đề trở thành yêu cầu thứ hai về các tệp dữ liệu cụ thể.
Điều này sẽ dẫn đến một chính sách như thế này (giả sử mỗi dòng là
đánh giá theo thứ tự)::

op=EXECUTE tính toàn vẹn_verified=YES hành động=ALLOW

op=READ tính toàn vẹn_verified=KHÔNG có nhãn=quan trọng_t hành động=DENY
  op=READ hành động=ALLOW

Điều này có phần rõ ràng nếu bạn đọc tài liệu, hiểu chính sách
được thực hiện theo thứ tự và mặc định là từ chối; tuy nhiên,
dòng cuối cùng thay đổi mặc định đó thành ALLOW một cách hiệu quả. Đây là
cần thiết, bởi vì trong một hệ thống thực tế, có một số thông tin chưa được xác minh
đọc (hãy tưởng tượng việc thêm vào một tệp nhật ký).

Tùy chọn thứ hai, không khớp với quy tắc nào dẫn đến cho phép, rõ ràng hơn
đối với các tệp dữ liệu cụ thể::

op=READ tính toàn vẹn_verified=KHÔNG có nhãn=quan trọng_t hành động=DENY

Và, giống như tùy chọn đầu tiên, không phù hợp với kịch bản thực thi,
thực sự cần ghi đè mặc định ::

op=EXECUTE tính toàn vẹn_verified=YES hành động=ALLOW
  op=EXECUTE hành động=DENY

op=READ tính toàn vẹn_verified=KHÔNG có nhãn=quan trọng_t hành động=DENY

Điều này để lại lựa chọn thứ ba. Thay vì bắt người dùng phải thông minh
và ghi đè mặc định bằng quy tắc trống, buộc người dùng cuối
để xem xét mức mặc định thích hợp cho
kịch bản và nêu rõ nó ::

DEFAULT op=EXECUTE hành động=DENY
  op=EXECUTE tính toàn vẹn_verified=YES hành động=ALLOW

DEFAULT op=READ hành động=ALLOW
  op=READ tính toàn vẹn_verified=KHÔNG có nhãn=quan trọng_t hành động=DENY

Gỡ lỗi chính sách:
~~~~~~~~~~~~~~~~~

Khi xây dựng một chính sách, sẽ rất hữu ích nếu biết được dòng chính sách nào
đang bị vi phạm để giảm chi phí gỡ lỗi; thu hẹp phạm vi của
điều tra chính xác đường lối dẫn đến hành động đó. Một số tính chính trực
hệ thống chính sách không cung cấp thông tin này, thay vào đó cung cấp
thông tin đã được sử dụng trong đánh giá. Điều này sau đó đòi hỏi một mối tương quan
với chính sách để đánh giá xem điều gì đã xảy ra.

Thay vào đó, IPE chỉ đưa ra quy tắc phù hợp. Điều này giới hạn phạm vi
của cuộc điều tra đến dòng chính sách chính xác (trong trường hợp cụ thể
quy tắc) hoặc phần (trong trường hợp DEFAULT). Điều này làm giảm sự lặp lại
và thời gian điều tra khi quan sát thấy các lỗi chính sách trong khi đánh giá
chính sách.

Công cụ chính sách của IPE cũng được thiết kế theo cách làm cho nó trở nên rõ ràng đối với
một con người về cách điều tra một thất bại chính sách. Mỗi dòng được đánh giá trong
trình tự được viết nên thuật toán rất đơn giản để làm theo
để con người tạo lại các bước và có thể gây ra lỗi. Ở nơi khác
hệ thống được khảo sát, tối ưu hóa xảy ra (ví dụ: quy tắc sắp xếp) khi tải
chính sách. Trong các hệ thống đó, cần có nhiều bước để gỡ lỗi và
thuật toán có thể không phải lúc nào cũng rõ ràng đối với người dùng cuối nếu không đọc mã trước.

Chính sách đơn giản hóa:
~~~~~~~~~~~~~~~~~~

Cuối cùng, chính sách của IPE được thiết kế cho quản trị viên hệ thống, không phải cho nhà phát triển kernel. Thay vào đó
bao gồm các móc LSM riêng lẻ (hoặc các tòa nhà cao tầng), IPE bao gồm các hoạt động. Điều này có nghĩa
thay vì quản trị viên hệ thống cần biết rằng các tòa nhà chọc trời ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ và ZZ0003ZZ phải có quy tắc bảo vệ chúng, đơn giản là chúng phải biết
rằng họ muốn hạn chế việc thực thi mã. Điều này hạn chế số lượng bỏ qua
có thể xảy ra do thiếu kiến thức về hệ thống cơ bản; trong khi đó
người bảo trì IPE, là nhà phát triển kernel có thể đưa ra lựa chọn chính xác để xác định
liệu có thứ gì đó ánh xạ tới các hoạt động này hay không và trong những điều kiện nào.

Ghi chú thực hiện
--------------------

Ký ức ẩn danh
~~~~~~~~~~~~~~~~

Bộ nhớ ẩn danh không được xử lý khác biệt với bất kỳ quyền truy cập nào khác trong IPE.
Khi bộ nhớ ẩn danh được ánh xạ với ZZ0000ZZ, nó vẫn đi vào ZZ0001ZZ
hoặc móc ZZ0002ZZ, nhưng với đối tượng tệp ZZ0003ZZ. Điều này được gửi tới
việc đánh giá, giống như bất kỳ tập tin nào khác. Tuy nhiên, tất cả các thuộc tính ủy thác hiện tại sẽ
đánh giá là sai vì tất cả chúng đều dựa trên tệp và thao tác không
liên kết với một tập tin.

.. WARNING::

  This also occurs with the ``kernel_load_data`` hook, when the kernel is
  loading data from a userspace buffer that is not backed by a file. In this
  scenario all current trust properties will also evaluate to false.

Giao diện bảo mật
~~~~~~~~~~~~~~~~~~~~

Cây bảo mật cho mỗi chính sách có phần độc đáo. Ví dụ, đối với
cây chính sách securityfs tiêu chuẩn::

Chính sách của tôi
    |- đang hoạt động
    |- xóa
    |- tên
    |- pkcs7
    |- chính sách
    |- cập nhật
    |- phiên bản

Chính sách được lưu trữ trong dữ liệu ZZ0000ZZ của inode MyPolicy.

Kiểm tra
-----

IPE có Kiểm tra KUnit cho trình phân tích cú pháp chính sách. Kunitconfig được đề xuất::

CONFIG_KUNIT=y
  CONFIG_SECURITY=y
  CONFIG_SECURITYFS=y
  CONFIG_PKCS7_MESSAGE_PARSER=y
  CONFIG_SYSTEM_DATA_VERIFICATION=y
  CONFIG_FS_VERITY=y
  CONFIG_FS_VERITY_BUILTIN_SIGNATURES=y
  CONFIG_BLOCK=y
  CONFIG_MD=y
  CONFIG_BLK_DEV_DM=y
  CONFIG_DM_VERITY=y
  CONFIG_DM_VERITY_VERIFY_ROOTHASH_SIG=y
  CONFIG_NET=y
  CONFIG_AUDIT=y
  CONFIG_AUDITSYSCALL=y
  CONFIG_BLK_DEV_INITRD=y

CONFIG_SECURITY_IPE=y
  CONFIG_IPE_PROP_DM_VERITY=y
  CONFIG_IPE_PROP_DM_VERITY_SIGNATURE=y
  CONFIG_IPE_PROP_FS_VERITY=y
  CONFIG_IPE_PROP_FS_VERITY_BUILTIN_SIG=y
  CONFIG_SECURITY_IPE_KUNIT_TEST=y

Ngoài ra, IPE còn tích hợp dựa trên python
ZZ0000ZZ đó
có thể kiểm tra cả giao diện người dùng và chức năng thực thi.