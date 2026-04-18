.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/maintainer-kvm-x86.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

KVM x86
=======

Lời nói đầu
--------
KVM phấn đấu trở thành một cộng đồng thân thiện; đóng góp từ những người mới đến là
được đánh giá cao và khuyến khích.  Xin đừng nản lòng hay bị đe dọa bởi
độ dài của tài liệu này và nhiều quy tắc/hướng dẫn trong đó.  mọi người
mắc sai lầm và mọi người đều là người mới ở một thời điểm nào đó.  Miễn là bạn thực hiện
nỗ lực trung thực để tuân theo các nguyên tắc của KVM x86, sẵn sàng tiếp thu phản hồi,
và học hỏi từ bất kỳ sai lầm nào bạn mắc phải, bạn sẽ được chào đón với vòng tay rộng mở chứ không phải
đuốc và chĩa.

TL;DR
-----
Kiểm tra là bắt buộc.  Hãy nhất quán với các phong cách và mẫu đã được thiết lập.

Cây cối
-----
KVM x86 hiện đang trong giai đoạn chuyển tiếp để trở thành một phần của KVM chính
cây, trở thành "chỉ là một vòm KVM khác".  Như vậy, KVM x86 được chia thành
cây KVM chính, ZZ0000ZZ và KVM x86
cây cụ thể, ZZ0001ZZ.

Nói chung, các bản sửa lỗi cho chu kỳ hiện tại được áp dụng trực tiếp vào
cây KVM chính, trong khi tất cả sự phát triển cho chu kỳ tiếp theo được chuyển qua
Cây KVM x86.  Trong trường hợp không chắc chắn rằng bản sửa lỗi cho chu kỳ hiện tại được định tuyến
thông qua cây KVM x86 sẽ được áp dụng cho nhánh ZZ0000ZZ trước đó
tiến tới cây KVM chính.

Lưu ý, giai đoạn chuyển tiếp này dự kiến sẽ kéo dài khá lâu, tức là sẽ
hiện trạng trong tương lai gần.

Chi nhánh
~~~~~~~~
Cây KVM x86 được tổ chức thành nhiều nhánh chủ đề.  Mục đích của
việc sử dụng các nhánh chủ đề chi tiết hơn là giúp việc theo dõi một khu vực trở nên dễ dàng hơn
của sự phát triển và để hạn chế thiệt hại phụ do lỗi của con người và/hoặc lỗi
cam kết, ví dụ: việc bỏ cam kết HEAD của một nhánh chủ đề không ảnh hưởng đến nhánh khác
trong chuyến bay cam kết băm SHA1 của cam kết và phải từ chối yêu cầu kéo do lỗi
chỉ trì hoãn nhánh chủ đề đó.

Tất cả các nhánh chủ đề, ngoại trừ ZZ0000ZZ và ZZ0001ZZ, đều được đưa vào ZZ0002ZZ
thông qua hợp nhất Cthulhu trên cơ sở khi cần thiết, tức là khi một nhánh chủ đề được cập nhật.
Do đó, việc đẩy lực lên ZZ0003ZZ là điều bình thường.

Vòng đời
~~~~~~~~~
Các bản sửa lỗi nhắm vào bản phát hành hiện tại, hay còn gọi là dòng chính, thường được áp dụng
trực tiếp đến cây KVM chính, tức là không định tuyến qua cây KVM x86.

Những thay đổi nhắm tới bản phát hành tiếp theo được định tuyến qua cây KVM x86.  Kéo
các yêu cầu (từ KVM x86 đến KVM chính) được gửi cho từng nhánh chủ đề KVM x86,
thường là một tuần trước khi Linus mở cửa sổ hợp nhất, ví dụ: tuần
theo dõi RC7 cho các bản phát hành "bình thường".  Nếu mọi việc suôn sẻ, các nhánh chủ đề sẽ
được đưa vào yêu cầu kéo KVM chính được gửi trong cửa sổ hợp nhất của Linus.

Cây KVM x86 không có cửa sổ hợp nhất chính thức riêng nhưng có một phần mềm
đóng xung quanh RC5 để có các tính năng mới và đóng nhẹ xung quanh RC6 để sửa lỗi (đối với
bản phát hành tiếp theo; xem ở trên để biết các bản sửa lỗi nhắm tới bản phát hành hiện tại).

Dòng thời gian
~~~~~~~~
Các bài nộp thường được xem xét và áp dụng theo thứ tự FIFO, có một số thay đổi
chỗ cho kích thước của một bộ truyện, các bản vá lỗi "bộ nhớ đệm nóng", v.v.
đặc biệt đối với bản phát hành hiện tại và cây ổn định, hãy nhảy vào hàng đợi.
Các bản vá sẽ được thực hiện thông qua cây không phải KVM (thường xuyên nhất là thông qua phần đầu
tree) và/hoặc có các xác nhận/đánh giá khác cũng nhảy vào hàng đợi ở một mức độ nào đó.

Lưu ý, phần lớn việc đánh giá được thực hiện giữa RC1 và RC6, cho hay nhận.
Khoảng thời gian giữa RC6 và RC1 tiếp theo được sử dụng để bắt kịp các nhiệm vụ khác,
tức là sự im lặng của đài trong khoảng thời gian này không phải là điều bất thường.

Ping để nhận cập nhật trạng thái đều được chào đón, nhưng hãy nhớ thời gian của
chu kỳ phát hành hiện tại và có những kỳ vọng thực tế.  Nếu bạn đang ping cho
chấp nhận, tức là không chỉ phản hồi hoặc cập nhật, vui lòng làm mọi thứ bạn
có thể, trong lý do, để đảm bảo rằng các bản vá của bạn đã sẵn sàng để được hợp nhất!  Ping
trên loạt sản phẩm làm hỏng bản dựng hoặc thử nghiệm không thành công sẽ khiến người bảo trì không hài lòng!

Phát triển
-----------

Cây/nhánh gốc
~~~~~~~~~~~~~~~~
Các bản sửa lỗi nhắm đến bản phát hành hiện tại, hay còn gọi là dòng chính, phải dựa trên
ZZ0000ZZ.  Lưu ý, sửa lỗi không
tự động đảm bảo đưa vào bản phát hành hiện tại.  Không có số ít
quy tắc, nhưng thường chỉ sửa các lỗi khẩn cấp, nghiêm trọng và/hoặc
được giới thiệu trong bản phát hành hiện tại sẽ nhắm mục tiêu vào bản phát hành hiện tại.

Mọi thứ khác phải dựa trên ZZ0000ZZ, tức là không cần
chọn một nhánh chủ đề cụ thể làm cơ sở.  Nếu có xung đột và/hoặc
phụ thuộc giữa các nhánh chủ đề, công việc của người bảo trì là sắp xếp chúng
ra ngoài.

Ngoại lệ duy nhất đối với việc sử dụng ZZ0000ZZ làm cơ sở là nếu có một bản vá/chuỗi
là một chuỗi nhiều vòm, tức là có những sửa đổi không hề nhỏ đối với mã KVM phổ biến
và/hoặc có nhiều thay đổi bề ngoài đối với mã của các kiến trúc khác.  Đa-
thay vào đó, bản vá/chuỗi vòm nên dựa trên một điểm chung, ổn định trong KVM
lịch sử, ví dụ: ứng cử viên phát hành mà ZZ0001ZZ dựa trên đó.  Nếu
bạn không chắc liệu một bản vá/chuỗi có thực sự là đa vòm hay không, có lẽ là
hãy thận trọng và coi nó như nhiều vòm, tức là sử dụng một đế chung.

Phong cách mã hóa
~~~~~~~~~~~~
Khi nói đến phong cách, cách đặt tên, mẫu mã, v.v., tính nhất quán là số một
ưu tiên trong KVM x86.  Nếu vẫn thất bại, hãy khớp với những gì đã tồn tại.

Với một số lưu ý được liệt kê dưới đây, hãy làm theo những gì người bảo trì cây ngọn ưa thích
ZZ0000ZZ, vì các bản vá/loạt phim thường chạm vào cả KVM và
các tệp x86 không phải KVM, tức là thu hút sự chú ý của những người duy trì cây mẹo KVM ZZ0001ZZ.

Sử dụng cây linh sam đảo ngược, hay còn gọi là cây Giáng sinh đảo ngược hoặc cây XMAS đảo ngược, để
Việc khai báo biến không bắt buộc phải thực hiện, mặc dù nó vẫn được ưu tiên hơn.

Ngoại trừ một số bông tuyết đặc biệt, không sử dụng chú thích kernel-doc cho
chức năng.  Phần lớn các chức năng KVM "công khai" không thực sự công khai như
chúng chỉ dành cho tiêu dùng nội bộ KVM (có kế hoạch
tư nhân hóa các tiêu đề và xuất khẩu của KVM để thực thi điều này).

Bình luận
~~~~~~~~
Viết bình luận bằng cách sử dụng thể mệnh lệnh và tránh đại từ.  Sử dụng nhận xét để
cung cấp một cái nhìn tổng quan cấp cao về mã và/hoặc giải thích lý do tại sao mã đó
nó làm gì.  Đừng nhắc lại nghĩa đen của mã; để mã
nói cho chính nó.  Nếu bản thân mã không thể hiểu được thì các bình luận sẽ không giúp ích gì.

Tài liệu tham khảo SDM và APM
~~~~~~~~~~~~~~~~~~~~~~
Phần lớn cơ sở mã của KVM được gắn trực tiếp với hành vi kiến trúc được xác định trong
Sổ tay phát triển phần mềm của Intel (SDM) và Lập trình viên kiến trúc của AMD
Hướng dẫn sử dụng (APM).  Sử dụng "SDM của Intel" và "AMD của APM" hoặc thậm chí chỉ "SDM" hoặc
"APM", không cần ngữ cảnh bổ sung là được.

Không tham khảo các phần, bảng, hình cụ thể, v.v. bằng số, đặc biệt là
không có trong bình luận.  Thay vào đó, nếu cần thiết (xem bên dưới), hãy sao chép-dán nội dung liên quan
đoạn trích và các phần/bảng/hình tham khảo theo tên.  Bố cục của SDM
và APM liên tục thay đổi nên số lượng/nhãn không ổn định.

Nói chung, không tham chiếu hoặc sao chép-dán một cách rõ ràng từ SDM hoặc
APM trong phần bình luận.  Với một vài ngoại lệ, KVM ZZ0000ZZ tôn vinh hành vi kiến trúc,
do đó, điều này ngụ ý rằng hành vi của KVM đang mô phỏng hành vi của SDM và/hoặc APM.
Lưu ý, tham chiếu SDM/APM trong nhật ký thay đổi để biện minh cho sự thay đổi và cung cấp
bối cảnh là hoàn toàn ổn và được khuyến khích.

Nhật ký ngắn
~~~~~~~~
Định dạng tiền tố ưa thích là ZZ0000ZZ, trong đó ZZ0001ZZ là một trong::

- x86
  - x86/mmu
  - x86/pmu
  - x86/xen
  - tự kiểm tra
  -SVM
  - nSVM
  -VMX
  - nVMX

ZZ0001ZZ ZZ0000ZZ được sử dụng riêng cho Linux-as-a-KVM-guest
những thay đổi, tức là đối với Arch/x86/kernel/kvm.c.  Không sử dụng tên tệp hoặc tệp hoàn chỉnh
đường dẫn làm tiền tố chủ đề/shortlog.

Lưu ý, những điều này không phù hợp với các nhánh chủ đề (các nhánh chủ đề quan tâm nhiều đến
thêm về xung đột mã).

Tất cả các tên đều phân biệt chữ hoa chữ thường!  ZZ0000ZZ tốt, ZZ0001ZZ thì không.

Viết hoa từ đầu tiên của mô tả bản vá cô đọng nhưng bỏ qua phần kết thúc
dấu chấm câu.  Ví dụ.::

KVM: x86: Sửa lỗi vô hiệu hóa con trỏ null trong function_xyz()

không::

kvm: x86: sửa lỗi vô hiệu hóa con trỏ null trong function_xyz.

Nếu một bản vá liên quan đến nhiều chủ đề, hãy duyệt qua cây khái niệm để tìm
cha mẹ chung đầu tiên (thường đơn giản là ZZ0000ZZ).  Khi nghi ngờ,
ZZ0001ZZ sẽ cung cấp gợi ý hợp lý.

Các chủ đề mới thỉnh thoảng xuất hiện nhưng vui lòng bắt đầu thảo luận trong danh sách nếu
bạn muốn đề xuất giới thiệu một chủ đề mới, tức là đừng lừa đảo.

Xem ZZ0000ZZ để biết thêm thông tin, với một sửa đổi:
không coi giới hạn 70-75 ký tự là giới hạn cố định, tuyệt đối.  Thay vào đó,
sử dụng 75 ký tự làm giới hạn chắc chắn nhưng không cứng và sử dụng 80 ký tự làm giới hạn cứng
giới hạn.  tức là hãy để shortlog chạy một vài ký tự vượt quá giới hạn tiêu chuẩn nếu
bạn có lý do chính đáng để làm như vậy.

Nhật ký thay đổi
~~~~~~~~~
Quan trọng nhất, hãy viết nhật ký thay đổi bằng cách sử dụng thể mệnh lệnh và tránh đại từ.

Xem ZZ0000ZZ để biết thêm thông tin, với một sửa đổi: dẫn bằng
một đoạn giới thiệu ngắn gọn về những thay đổi thực tế, sau đó theo dõi bối cảnh và
nền.  Ghi chú!  Thứ tự này mâu thuẫn trực tiếp với ưu tiên của cây mẹo
tiếp cận!  Vui lòng làm theo phong cách ưa thích của cây mẹo khi gửi bản vá
chủ yếu nhắm mục tiêu mã Arch/x86 là mã _NOT_ KVM.

Nêu rõ chức năng của bản vá trước khi đi sâu vào chi tiết được KVM x86 ưa thích
vì một số lý do.  Đầu tiên và quan trọng nhất, mã nào thực sự đang được thay đổi
được cho là thông tin quan trọng nhất và do đó thông tin đó phải dễ dàng được tìm thấy.
tìm. Nhật ký thay đổi chôn vùi "những gì thực sự đang thay đổi" trong một dòng ngắn gọn sau
Hơn 3 đoạn thông tin cơ bản khiến việc tìm kiếm thông tin đó trở nên rất khó khăn.

Trong đánh giá ban đầu, người ta có thể cho rằng “cái gì bị hỏng” là quan trọng hơn, nhưng
để đọc lướt các bản ghi và khảo cổ học git, các chi tiết đẫm máu ngày càng ít quan trọng hơn.
Ví dụ. khi thực hiện một loạt "git đổ lỗi", chi tiết của từng thay đổi dọc theo
cách nào cũng vô ích, chi tiết chỉ quan trọng đối với thủ phạm.  Cung cấp “cái gì
đã thay đổi" giúp bạn dễ dàng nhanh chóng xác định liệu một cam kết có thể có hay không
tiền lãi.

Một lợi ích khác của việc nêu rõ “điều gì đang thay đổi” trước tiên là nó hầu như luôn luôn
có thể nêu "điều gì đang thay đổi" trong một câu duy nhất.  Ngược lại, tất cả trừ
những lỗi đơn giản nhất cần nhiều câu hoặc đoạn văn để mô tả đầy đủ
vấn đề.  Nếu cả "điều gì đang thay đổi" và "lỗi là gì" đều tuyệt vời
ngắn thì thứ tự không quan trọng.  Nhưng nếu một cái ngắn hơn (hầu như luôn luôn là
"điều gì đang thay đổi), thì việc che phần ngắn hơn trước sẽ có lợi vì
sẽ ít gây bất tiện hơn cho người đọc/người đánh giá có thứ tự nghiêm ngặt
ưu tiên.  Ví dụ: ít phải bỏ qua một câu để hiểu ngữ cảnh
đau đớn hơn là phải bỏ qua ba đoạn văn để đến phần "điều gì đang thay đổi".

sửa lỗi
~~~~~
Nếu một thay đổi sửa được lỗi KVM/kernel, hãy thêm thẻ Fixes: ngay cả khi thay đổi đó không khắc phục được
cần được chuyển ngược sang các hạt nhân ổn định và ngay cả khi thay đổi đó sửa được lỗi trong
một bản phát hành cũ hơn.

Ngược lại, nếu một bản sửa lỗi cần được chuyển ngược lại, hãy gắn thẻ bản vá một cách rõ ràng với
"Cc: stable@vger.kernel" (mặc dù bản thân email không cần Cc: stable);
KVM x86 chọn không tham gia backporting Các bản sửa lỗi: theo mặc định.  Một số bản vá được chọn tự động
được nhập lại nhưng cần có sự phê duyệt rõ ràng của người bảo trì (tìm kiếm MANUALSEL).

Tài liệu tham khảo chức năng
~~~~~~~~~~~~~~~~~~~
Khi một chức năng được đề cập trong một nhận xét, nhật ký thay đổi hoặc nhật ký ngắn (hoặc bất cứ nơi nào
đối với vấn đề đó), hãy sử dụng định dạng ZZ0000ZZ.  Các dấu ngoặc đơn cung cấp
bối cảnh và phân biệt tài liệu tham khảo.

Kiểm tra
-------
Ở mức tối thiểu, các bản vá ZZ0000ZZ trong một chuỗi phải được xây dựng rõ ràng để có KVM_INTEL=m
KVM_AMD=m, và KVM_WERROR=y.  Xây dựng mọi sự kết hợp có thể có của Kconfigs
là không khả thi, nhưng càng nhiều càng tốt.  KVM_SMM, KVM_XEN, PROVE_LOCKING và
X86_64 là những nút xoay đặc biệt thú vị.

Chạy các bài kiểm tra bản thân KVM và các bài kiểm tra đơn vị KVM cũng là bắt buộc (và nêu rõ
hiển nhiên, các bài kiểm tra cần phải vượt qua).  Ngoại lệ duy nhất là đối với những thay đổi có
xác suất không đáng kể ảnh hưởng đến hành vi thời gian chạy, ví dụ: bản vá lỗi chỉ
sửa đổi nhận xét.  Khi có thể và phù hợp, việc thử nghiệm trên cả Intel và AMD là
được ưu tiên mạnh mẽ.  Việc khởi động một máy ảo thực tế được khuyến khích nhưng không bắt buộc.

Đối với những thay đổi liên quan đến mã phân trang bóng của KVM, chạy với TDP (EPT/NPT)
bị vô hiệu hóa là bắt buộc.  Đối với những thay đổi ảnh hưởng đến mã KVM MMU phổ biến, đang chạy
với TDP bị vô hiệu hóa được khuyến khích mạnh mẽ.  Đối với tất cả các thay đổi khác, nếu mã
được sửa đổi phụ thuộc vào và/hoặc tương tác với thông số mô-đun, kiểm tra với
các cài đặt có liên quan là bắt buộc.

Lưu ý, các bài kiểm tra tự kiểm tra KVM và các bài kiểm tra đơn vị KVM đều có lỗi đã biết.  Nếu bạn nghi ngờ
lỗi không phải do thay đổi của bạn, hãy xác minh rằng lỗi ZZ0000ZZ
xảy ra khi có và không có sự thay đổi của bạn.

Những thay đổi liên quan đến tài liệu Văn bản được cấu trúc lại, tức là các tệp .rst, phải được xây dựng
htmldocs một cách rõ ràng, tức là không có cảnh báo hoặc lỗi mới.

Nếu bạn không thể kiểm tra đầy đủ một thay đổi, ví dụ: do thiếu phần cứng, ghi rõ
mức độ kiểm tra bạn có thể thực hiện, ví dụ: trong thư xin việc.

Tính năng mới
~~~~~~~~~~~~
Với một ngoại lệ, các tính năng mới ZZ0000ZZ sẽ được đưa vào thử nghiệm.  KVM cụ thể
các bài kiểm tra không được yêu cầu nghiêm ngặt, ví dụ: nếu phạm vi bảo hiểm được cung cấp bằng cách chạy một
VM khách được kích hoạt đầy đủ hoặc bằng cách chạy selftest hạt nhân có liên quan trong VM,
nhưng các thử nghiệm KVM chuyên dụng được ưu tiên trong mọi trường hợp.  Các trường hợp xét nghiệm âm tính trong
cụ thể là bắt buộc để kích hoạt các tính năng phần cứng mới vì lỗi và
các luồng ngoại lệ hiếm khi được thực hiện đơn giản bằng cách chạy VM.

Ngoại lệ duy nhất cho quy tắc này là nếu KVM chỉ đơn giản là quảng cáo hỗ trợ cho một
tính năng thông qua KVM_GET_SUPPORTED_CPUID, tức là để biết các hướng dẫn/tính năng mà KVM
không thể ngăn cản khách sử dụng và không có khả năng thực sự cho phép.

Lưu ý, "tính năng mới" không chỉ có nghĩa là "tính năng phần cứng mới"!  Tính năng mới
không thể được xác thực tốt bằng cách sử dụng các bài kiểm tra KVM và/hoặc các bài kiểm tra đơn vị KVM hiện có
phải đi kèm với các bài kiểm tra.

Đăng bài phát triển tính năng mới mà không cần kiểm tra để nhận phản hồi sớm sẽ tốt hơn
được chào đón, nhưng những bài nộp như vậy phải được gắn thẻ RFC và thư xin việc
cần nêu rõ loại phản hồi nào được yêu cầu/mong đợi.  Đừng lạm dụng
quy trình RFC; RFC thường sẽ không nhận được đánh giá chuyên sâu.

Sửa lỗi
~~~~~~~~~
Ngoại trừ các lỗi được phát hiện "rõ ràng" qua quá trình kiểm tra, các bản sửa lỗi phải kèm theo một
bản sao chép cho lỗi đang được sửa.  Trong nhiều trường hợp, người sao chép là ngầm định,
ví dụ: đối với các lỗi xây dựng và lỗi kiểm tra, nhưng vẫn phải rõ ràng
Bạn đọc xem nó bị hỏng gì và cách xác minh cách khắc phục.  Một số thời gian được đưa ra cho
các lỗi được tìm thấy thông qua khối lượng công việc/kiểm tra không công khai nhưng cung cấp khả năng hồi quy
các thử nghiệm tìm lỗi như vậy được ưu tiên hơn.

Nói chung, các thử nghiệm hồi quy được ưa thích hơn đối với bất kỳ lỗi nào không nghiêm trọng đối với
đánh.  Ví dụ. ngay cả khi lỗi ban đầu được tìm thấy bởi một trình làm mờ như syzkaller,
kiểm tra hồi quy có mục tiêu có thể được đảm bảo nếu lỗi yêu cầu phải đánh một
điều kiện chủng tộc có một trong một triệu.

Lưu ý, lỗi KVM hiếm khi khẩn cấp ZZ0000ZZ không tầm thường để tái tạo.  Hãy tự hỏi mình
nếu một lỗi thực sự là ngày tận thế trước khi đăng bản sửa lỗi mà không có
người tái tạo.

Đăng bài
-------

Liên kết
~~~~~
Không tham chiếu rõ ràng các báo cáo lỗi, các phiên bản trước của bản vá/bộ, v.v.
thông qua các tiêu đề ZZ0000ZZ.  Sử dụng ZZ0001ZZ sẽ trở thành một mớ hỗn độn
dành cho loạt phim lớn và/hoặc khi số lượng phiên bản tăng cao và ZZ0002ZZ
vô dụng đối với bất kỳ ai không có tin nhắn gốc, ví dụ: nếu ai đó
không có Cc trong báo cáo lỗi hoặc nếu danh sách người nhận thay đổi giữa
các phiên bản.

Để liên kết tới báo cáo lỗi, phiên bản trước hoặc bất kỳ điều gì đáng quan tâm, hãy sử dụng truyền thuyết
liên kết.  Để tham khảo (các) phiên bản trước, nói chung không bao gồm
a Liên kết: trong nhật ký thay đổi vì không cần ghi lại lịch sử trong git, tức là
đặt liên kết trong thư xin việc hoặc trong phần git bỏ qua.  Hãy cung cấp một
Liên kết chính thức: dành cho các báo cáo lỗi và/hoặc các cuộc thảo luận dẫn đến bản vá.  các
bối cảnh tại sao một sự thay đổi được thực hiện là rất có giá trị đối với độc giả trong tương lai.

Cơ sở Git
~~~~~~~~
Nếu bạn đang sử dụng git phiên bản 2.9.0 trở lên (Nhân viên của Google, đây là tất cả của bạn!),
sử dụng ZZ0000ZZ với cờ ZZ0001ZZ để tự động bao gồm
thông tin cây cơ sở trong các bản vá được tạo ra.

Lưu ý, ZZ0000ZZ hoạt động như mong đợi khi và chỉ khi thượng nguồn của nhánh là
được đặt thành nhánh chủ đề cơ sở, ví dụ: nó sẽ làm sai nếu ngược dòng của bạn
được đặt vào kho lưu trữ cá nhân của bạn cho mục đích sao lưu.  Một "tự động" thay thế
giải pháp là lấy tên của các nhánh phát triển của bạn dựa trên
Chủ đề KVM x86 và đưa chủ đề đó vào ZZ0001ZZ.  Ví dụ. ZZ0002ZZ,
rồi viết một trình bao bọc nhỏ để trích xuất ZZ0003ZZ từ tên nhánh hiện tại
để tạo ra ZZ0004ZZ, trong đó ZZ0005ZZ là bất kỳ tên nào mà kho lưu trữ của bạn sử dụng
theo dõi điều khiển từ xa KVM x86.

Bài kiểm tra đồng đăng
~~~~~~~~~~~~~~~~
Tự kiểm tra KVM có liên quan đến các thay đổi của KVM, ví dụ: kiểm tra hồi quy cho
các bản sửa lỗi nên được đăng cùng với các thay đổi của KVM dưới dạng một chuỗi duy nhất.  các
áp dụng các quy tắc hạt nhân tiêu chuẩn để chia đôi, tức là các thay đổi KVM dẫn đến kết quả kiểm tra
các lỗi phải được sắp xếp sau khi cập nhật selftests và ngược lại, các lỗi mới
các thử nghiệm không thành công do lỗi KVM phải được thực hiện sau khi sửa lỗi KVM.

KVM-unit-tests ZZ0000ZZ phải được đăng riêng.  Công cụ, ví dụ: b4 giờ sáng, đừng
biết rằng KVM-unit-tests là một kho lưu trữ riêng biệt và bị nhầm lẫn khi các bản vá
trong một loạt áp dụng trên các cây khác nhau.  Để buộc các bản vá lỗi KVM-unit-tests trở lại
Các bản vá KVM, trước tiên hãy đăng các thay đổi của KVM và sau đó cung cấp Liên kết truyền thuyết: tới
Bản vá/chuỗi KVM trong (các) bản vá thử nghiệm đơn vị KVM.

Thông báo
-------------
Khi một bản vá/bộ truyện được chính thức chấp nhận, một email thông báo sẽ được gửi
để trả lời bài đăng ban đầu (thư xin việc cho loạt bài nhiều bản vá).  các
thông báo sẽ bao gồm cây và nhánh chủ đề, cùng với SHA1 của
các cam kết của các bản vá được áp dụng.

Nếu một tập hợp con các bản vá được áp dụng, điều này sẽ được nêu rõ trong
thông báo.  Trừ khi có quy định khác, điều đó có nghĩa là bất kỳ bản vá nào trong
loạt bài không được chấp nhận cần phải hoàn thiện thêm và phải được gửi dưới dạng mới
phiên bản.

Nếu vì lý do nào đó một bản vá bị loại bỏ sau khi được chấp nhận chính thức, một phản hồi
sẽ được gửi tới email thông báo giải thích lý do tại sao bản vá bị hủy, vì
cũng như các bước tiếp theo.

Độ ổn định của SHA1
~~~~~~~~~~~~~~
SHA1 không được đảm bảo 100% sẽ ổn định cho đến khi chúng đáp xuống cây của Linus!  A
SHA1 là ZZ0000ZZ ổn định sau khi thông báo được gửi nhưng có sự cố xảy ra.
Trong hầu hết các trường hợp, bản cập nhật cho email thông báo sẽ được cung cấp nếu áp dụng
thay đổi SHA1 của bản vá.  Tuy nhiên, trong một số trường hợp, ví dụ: nếu tất cả các nhánh KVM x86
cần phải được khởi động lại, các thông báo riêng lẻ sẽ không được đưa ra.

Lỗ hổng
---------------
Các lỗi mà khách có thể khai thác để tấn công máy chủ (kernel hoặc
không gian người dùng) hoặc có thể bị khai thác bởi một máy ảo lồng vào máy chủ ZZ0001ZZ (tấn công L2
L1), được KVM đặc biệt quan tâm.  Hãy làm theo quy trình dành cho
ZZ0000ZZ nếu bạn nghi ngờ có lỗi có thể dẫn đến thoát, rò rỉ dữ liệu, v.v.
