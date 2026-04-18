.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/maintainer/rebasing-and-merging.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=========================
Khởi động lại và hợp nhất
=========================

Việc duy trì một hệ thống con, như một nguyên tắc chung, đòi hỏi sự hiểu biết về
Hệ thống quản lý mã nguồn Git.  Git là một công cụ mạnh mẽ với rất nhiều
tính năng; như thường lệ với các công cụ như vậy, có đúng và sai
cách sử dụng các tính năng đó.  Tài liệu này đặc biệt xem xét việc sử dụng
của việc khởi động lại và sáp nhập.  Người bảo trì thường gặp rắc rối khi sử dụng
những công cụ đó không chính xác, nhưng việc tránh các vấn đề thực sự không phải là tất cả
cứng.

Một điều cần lưu ý nói chung là, không giống như nhiều dự án khác,
cộng đồng hạt nhân không sợ hãi khi thấy các cam kết hợp nhất trong nó
lịch sử phát triển.  Thật vậy, với quy mô của dự án, tránh
việc sáp nhập gần như là không thể.  Một số vấn đề gặp phải của
những người duy trì xuất phát từ mong muốn tránh sự hợp nhất, trong khi những người khác đến từ
hợp nhất một chút quá thường xuyên.

Khởi động lại
========

"Rebasing" là quá trình thay đổi lịch sử của một loạt các commit
trong một kho lưu trữ.  Có hai loại hoạt động khác nhau đó là
được gọi là khởi động lại vì cả hai đều được thực hiện với ZZ0000ZZ
lệnh, nhưng có sự khác biệt đáng kể giữa chúng:

- Thay đổi cam kết gốc (bắt đầu) theo đó một loạt các bản vá được thực hiện
   được xây dựng.  Ví dụ: hoạt động rebase có thể lấy một bộ bản vá được xây dựng trên
   thay vào đó, bản phát hành hạt nhân trước đó sẽ được căn cứ vào bản phát hành hiện tại
   thả ra.  Chúng ta sẽ gọi thao tác này là "reparenting" trong phần thảo luận
   bên dưới.

- Thay đổi lịch sử của một bộ bản vá bằng cách sửa (hoặc xóa) bị hỏng
   cam kết, thêm bản vá, thêm thẻ vào nhật ký thay đổi cam kết hoặc thay đổi
   thứ tự áp dụng các cam kết.  Trong văn bản sau đây, điều này
   loại hoạt động sẽ được gọi là "sửa đổi lịch sử"

Thuật ngữ "rebasing" sẽ được dùng để chỉ cả hai thao tác trên.
Sử dụng đúng cách, rebasing có thể mang lại sự phát triển rõ ràng và sạch sẽ hơn
lịch sử; sử dụng không đúng cách, nó có thể che khuất lịch sử đó và gây ra lỗi.

Có một số quy tắc kinh nghiệm có thể giúp các nhà phát triển tránh được điều tồi tệ nhất
Nguy cơ của việc nổi loạn:

- Lịch sử đã được tiếp xúc với thế giới ngoài hệ thống riêng tư của bạn
   thường không nên thay đổi.  Những người khác có thể đã lấy một bản sao của bạn
   cây và xây dựng trên đó; việc sửa đổi cây của bạn sẽ gây đau đớn cho họ.  Nếu
   công việc đang cần được khởi động lại, đó thường là dấu hiệu cho thấy nó chưa
   sẵn sàng cam kết với một kho lưu trữ công cộng.

Điều đó nói lên rằng, luôn có những ngoại lệ.  Một số cây (linux-next)
   một ví dụ quan trọng) thường xuyên bị phản đối bởi bản chất của chúng, và
   các nhà phát triển biết không dựa vào chúng để làm việc.  Các nhà phát triển đôi khi sẽ
   hiển thị một nhánh không ổn định để người khác kiểm tra hoặc tự động
   dịch vụ thử nghiệm.  Nếu bạn để lộ một nhánh có thể không ổn định trong
   Bằng cách này, hãy đảm bảo rằng những người dùng tiềm năng sẽ không dựa vào đó để làm việc.

- Không rebase một nhánh chứa lịch sử do người khác tạo.  Nếu bạn
   đã lấy các thay đổi từ kho lưu trữ của nhà phát triển khác, bây giờ bạn là một
   người giám hộ lịch sử của họ.  Bạn không nên thay đổi nó.  Với ít
   các trường hợp ngoại lệ, ví dụ, một cam kết bị hỏng trong một cái cây như thế này sẽ là
   được hoàn nguyên rõ ràng thay vì biến mất thông qua sửa đổi lịch sử.

- Đừng sửa chữa cây mà không có lý do chính đáng.  Chỉ cần ở trên một
   cơ sở mới hơn hoặc tránh hợp nhất với kho lưu trữ ngược dòng thì không
   nói chung là một lý do chính đáng.

- Nếu bạn phải sửa lại kho lưu trữ, đừng chọn một số cam kết kernel ngẫu nhiên
   làm căn cứ mới.  Kernel thường ở trạng thái tương đối không ổn định
   giữa các điểm phát hành; phát triển dựa trên một trong những điểm đó
   làm tăng nguy cơ gặp phải những lỗi đáng ngạc nhiên.  Khi một bản vá
   chuỗi phải di chuyển đến một cơ sở mới, chọn một điểm ổn định (chẳng hạn như một trong
   bản phát hành -rc) để di chuyển đến.

- Nhận ra rằng việc sửa lại một loạt bản vá (hoặc tạo nên lịch sử quan trọng
   sửa đổi) thay đổi môi trường mà nó được phát triển và,
   có khả năng làm mất hiệu lực phần lớn thử nghiệm đã được thực hiện.  Một sự sửa chữa
   loạt bản vá, theo nguyên tắc chung, phải được xử lý như mã mới và
   đã test lại từ đầu.

Một nguyên nhân thường gặp gây ra sự cố cửa sổ hợp nhất là khi Linus gặp một
loạt bản vá rõ ràng đã được sửa lại, thường là một cam kết ngẫu nhiên,
ngay trước khi yêu cầu kéo được gửi.  Cơ hội của một loạt như vậy
đã được kiểm tra đầy đủ là tương đối thấp - cũng như khả năng
yêu cầu kéo đang được thực hiện.

Thay vào đó, nếu việc khởi động lại bị giới hạn ở các cây riêng tư thì các cam kết sẽ dựa trên một
điểm khởi đầu nổi tiếng và chúng đã được thử nghiệm kỹ lưỡng, tiềm năng cho
rắc rối là thấp.

Sáp nhập
=======

Hợp nhất là một thao tác phổ biến trong quá trình phát triển kernel; 5.1
chu kỳ phát triển bao gồm 1.126 cam kết hợp nhất - gần 9% tổng số.
Công việc hạt nhân được tích lũy trong hơn 100 cây hệ thống con khác nhau, mỗi cây
có thể chứa nhiều nhánh chủ đề; mỗi nhánh thường được phát triển
độc lập với những người khác.  Vì vậy, một cách tự nhiên, ít nhất một sự hợp nhất sẽ được
được yêu cầu trước khi bất kỳ nhánh cụ thể nào tìm được đường vào kho lưu trữ ngược dòng.

Nhiều dự án yêu cầu các nhánh trong yêu cầu kéo phải dựa trên
đường trục hiện tại để không có cam kết hợp nhất nào xuất hiện trong lịch sử.  Hạt nhân
không phải là một dự án như vậy; hầu hết mọi hoạt động khởi động lại các nhánh để tránh sáp nhập sẽ
có thể dẫn tới rắc rối.

Những người bảo trì hệ thống con thấy mình phải thực hiện hai loại hợp nhất:
từ các cây hệ thống con cấp thấp hơn và từ các cây khác, hoặc là cây anh em hoặc
đường dây chính.  Các phương pháp thực hành tốt nhất cần tuân theo sẽ khác nhau trong hai tình huống đó.

Hợp nhất từ ​​các cây cấp thấp hơn
------------------------------

Các hệ thống con lớn hơn có xu hướng có nhiều cấp độ người bảo trì, với
người bảo trì cấp thấp hơn gửi yêu cầu kéo lên cấp cao hơn.  diễn xuất
với một yêu cầu kéo như vậy gần như chắc chắn sẽ tạo ra một cam kết hợp nhất; đó
là như nó phải vậy.  Trong thực tế, người bảo trì hệ thống con có thể muốn sử dụng
cờ --no-ff để buộc bổ sung cam kết hợp nhất trong một số trường hợp hiếm hoi
nơi thông thường người ta sẽ không được tạo để lý do hợp nhất
có thể được ghi lại.  Nhật ký thay đổi cho việc hợp nhất sẽ, đối với bất kỳ loại
hợp nhất, giả sử ZZ0000ZZ việc hợp nhất đang được thực hiện.  Đối với cây cấp thấp hơn, "tại sao" là
thường là một bản tóm tắt những thay đổi sẽ đi kèm với sự kéo đó.

Người bảo trì ở tất cả các cấp nên sử dụng thẻ đã ký khi thực hiện thao tác kéo của họ
yêu cầu và người bảo trì ngược dòng nên xác minh các thẻ khi kéo
chi nhánh.  Nếu không làm như vậy sẽ đe dọa đến an ninh của sự phát triển
quá trình như một tổng thể.

Theo các quy tắc được nêu ở trên, khi bạn đã hợp nhất tài khoản của người khác
history vào cây của bạn, bạn không thể rebase nhánh đó, ngay cả khi bạn
nếu không sẽ có thể.

Hợp nhất từ ​​cây anh em hoặc cây ngược dòng
--------------------------------------

Trong khi việc sáp nhập từ hạ nguồn là phổ biến và không đáng chú ý, việc sáp nhập từ các nơi khác
cây cối có xu hướng cảnh giác khi đến lúc phải đẩy cành ngược dòng.
Việc sáp nhập như vậy cần phải được suy nghĩ cẩn thận và hợp lý, hoặc
rất có thể yêu cầu kéo tiếp theo sẽ bị từ chối.

Việc muốn hợp nhất nhánh chính vào một kho lưu trữ là điều đương nhiên; cái này
kiểu hợp nhất thường được gọi là "hợp nhất ngược".  Việc hợp nhất lại có thể giúp thực hiện
chắc chắn rằng không có xung đột với sự phát triển song song và nói chung
mang lại cảm giác ấm áp, mờ ảo như được cập nhật.  Nhưng sự cám dỗ này
nên tránh gần như mọi lúc.

Tại sao vậy?  Việc sáp nhập lại sẽ làm vấy bẩn lịch sử phát triển của chính bạn
chi nhánh.  Chúng sẽ làm tăng đáng kể khả năng bạn gặp phải lỗi
từ nơi khác trong cộng đồng và gây khó khăn cho việc đảm bảo rằng công việc
bạn đang quản lý đã ổn định và sẵn sàng cho thượng nguồn.  Sự hợp nhất thường xuyên có thể
cũng che khuất các vấn đề với quá trình phát triển trong cây của bạn; họ có thể
ẩn các tương tác với các cây khác mà lẽ ra không nên xảy ra (thường xuyên) trong
một chi nhánh được quản lý tốt.

Điều đó nói lên rằng, việc hợp nhất ngược đôi khi được yêu cầu; khi điều đó xảy ra, hãy
hãy chắc chắn ghi lại ZZ0000ZZ nó được yêu cầu trong thông báo cam kết.  Như mọi khi,
hợp nhất đến một điểm ổn định nổi tiếng, thay vì một số cam kết ngẫu nhiên.
Ngay cả khi đó, bạn không nên hợp nhất lại một cây phía trên thượng nguồn ngay lập tức của bạn
cây; nếu việc hợp nhất ngược cấp cao hơn thực sự cần thiết thì cây ngược dòng
nên làm điều đó đầu tiên.

Một trong những nguyên nhân thường gặp nhất gây ra rắc rối liên quan đến việc hợp nhất là khi một
người bảo trì hợp nhất với thượng nguồn để giải quyết xung đột hợp nhất
trước khi gửi yêu cầu kéo.  Một lần nữa, sự cám dỗ này đủ dễ để
hiểu nhưng tuyệt đối nên tránh.  Điều này đặc biệt đúng
đối với yêu cầu kéo cuối cùng: Linus kiên quyết rằng anh ấy muốn nhìn thấy hơn
hợp nhất xung đột hơn là hợp nhất ngược lại không cần thiết.  Nhìn thấy những xung đột cho phép
anh ta biết khu vực có vấn đề tiềm ẩn ở đâu.  Anh ấy thực hiện rất nhiều sự hợp nhất (382
trong chu kỳ phát triển 5.1) và đã giải quyết xung đột khá tốt
độ phân giải - thường tốt hơn so với các nhà phát triển có liên quan.

Vậy người bảo trì nên làm gì khi có xung đột giữa
nhánh hệ thống phụ và tuyến chính?  Bước quan trọng nhất là cảnh báo
Linus trong pull yêu cầu rằng xung đột sẽ xảy ra; nếu không có gì khác,
điều đó thể hiện nhận thức về cách chi nhánh của bạn phù hợp với tổng thể.  cho
xung đột đặc biệt khó khăn, tạo và đẩy một nhánh ZZ0000ZZ để hiển thị
bạn sẽ giải quyết mọi việc như thế nào.  Đề cập đến nhánh đó trong yêu cầu kéo của bạn,
nhưng bản thân yêu cầu kéo phải dành cho nhánh chưa được hợp nhất.

Ngay cả khi không có xung đột đã biết, việc thực hiện hợp nhất thử nghiệm trước khi gửi
yêu cầu kéo là một ý tưởng hay.  Nó có thể cảnh báo bạn về những vấn đề mà bạn bằng cách nào đó
không thấy từ linux-next và giúp hiểu chính xác bạn là ai
yêu cầu thượng nguồn làm.

Một lý do khác để thực hiện việc hợp nhất cây hệ thống con ngược dòng hoặc cây hệ thống con khác là để
giải quyết sự phụ thuộc.  Những vấn đề phụ thuộc này đôi khi vẫn xảy ra và
đôi khi việc hợp nhất chéo với cây khác là cách tốt nhất để giải quyết chúng;
như mọi khi, trong những tình huống như vậy, cam kết hợp nhất sẽ giải thích lý do tại sao
việc hợp nhất đã được thực hiện.  Hãy dành một chút thời gian để làm điều đó đúng; mọi người sẽ đọc những thứ đó
nhật ký thay đổi.

Tuy nhiên, thông thường, các vấn đề phụ thuộc chỉ ra rằng việc thay đổi cách tiếp cận là
cần thiết.  Hợp nhất một cây hệ thống con khác để giải quyết rủi ro phụ thuộc
mang lại các lỗi khác và hầu như không bao giờ được thực hiện.  Nếu hệ thống con đó
cây không thể được kéo ngược dòng, bất cứ vấn đề gì nó gặp phải sẽ cản trở
hợp nhất cây của bạn là tốt.  Các lựa chọn thay thế thích hợp hơn bao gồm việc đồng ý
với người bảo trì để thực hiện cả hai tập hợp thay đổi ở một trong các cây hoặc
tạo một nhánh chủ đề dành riêng cho các cam kết tiên quyết có thể
sáp nhập vào cả hai cây.  Nếu sự phụ thuộc có liên quan đến chính
thay đổi cơ sở hạ tầng, giải pháp phù hợp có thể là giữ người phụ thuộc
cam kết cho một chu kỳ phát triển để những thay đổi đó có thời gian thực hiện
ổn định ở tuyến chính.

Cuối cùng
=======

Việc hợp nhất với dòng chính vào đầu phần này là tương đối phổ biến.
chu trình phát triển để tiếp thu những thay đổi và sửa lỗi được thực hiện ở nơi khác
trong cây.  Như mọi khi, việc hợp nhất như vậy sẽ chọn một bản phát hành nổi tiếng
điểm chứ không phải là một số điểm ngẫu nhiên.  Nếu nhánh ngược dòng của bạn có
được làm trống hoàn toàn vào dòng chính trong cửa sổ hợp nhất, bạn có thể kéo nó
chuyển tiếp bằng lệnh như::

git merge --ff-only v5.2-rc1

Các hướng dẫn được nêu ở trên chỉ là: hướng dẫn.  Sẽ luôn có
là những tình huống đòi hỏi một giải pháp khác và những hướng dẫn này
không nên ngăn cản các nhà phát triển làm điều đúng đắn khi cần thiết
phát sinh.  Nhưng người ta phải luôn suy nghĩ xem liệu nhu cầu có thực sự
nảy sinh và sẵn sàng giải thích tại sao cần phải làm điều gì đó bất thường.