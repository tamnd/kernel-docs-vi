.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/process/embargoed-hardware-issues.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _embargoed_hardware_issues:

Các vấn đề phần cứng bị cấm vận
=========================

Phạm vi
-----

Các sự cố phần cứng dẫn đến vấn đề bảo mật là một loại khác
lỗi bảo mật nhiều hơn lỗi phần mềm thuần túy chỉ ảnh hưởng đến Linux
hạt nhân.

Các vấn đề về phần cứng như Meltdown, Spectre, L1TF, v.v. phải được xử lý
khác nhau vì chúng thường ảnh hưởng đến tất cả các Hệ điều hành ("OS") và
do đó cần có sự phối hợp giữa các nhà cung cấp, phân phối hệ điều hành khác nhau,
nhà cung cấp silicon, nhà tích hợp phần cứng và các bên khác. Đối với một số
sự cố, việc giảm nhẹ phần mềm có thể phụ thuộc vào các bản cập nhật vi mã hoặc chương trình cơ sở,
những việc cần phối hợp thêm.

.. _Contact:

Liên hệ
-------

Nhóm bảo mật phần cứng nhân Linux tách biệt với Linux thông thường
nhóm bảo mật hạt nhân.

Nhóm chỉ xử lý việc phát triển các bản sửa lỗi cho bảo mật phần cứng bị cấm vận
vấn đề. Các báo cáo về lỗi bảo mật phần mềm thuần túy trong nhân Linux không
do nhóm này xử lý và phóng viên sẽ được hướng dẫn liên hệ với cơ quan quản lý thường xuyên
Thay vào đó, nhóm bảo mật nhân Linux (ZZ0000ZZ).

Bạn có thể liên hệ với nhóm qua email tại <hardware-security@kernel.org>. Cái này
là danh sách riêng của các nhân viên an ninh sẽ giúp bạn phối hợp khắc phục
theo quy trình được ghi lại của chúng tôi.

Danh sách được mã hóa và email tới danh sách có thể được gửi bằng PGP hoặc
S/MIME được mã hóa và phải được ký bằng khóa PGP của người báo cáo hoặc S/MIME
giấy chứng nhận. Khóa PGP và chứng chỉ S/MIME của danh sách có sẵn từ
các URL sau:

-PGP: ZZ0000ZZ
  -S/MIME: ZZ0001ZZ

Trong khi các vấn đề bảo mật phần cứng thường được xử lý bởi silicon bị ảnh hưởng
nhà cung cấp, chúng tôi hoan nghênh liên hệ từ các nhà nghiên cứu hoặc cá nhân có
đã xác định được một lỗ hổng phần cứng tiềm ẩn.

Nhân viên an ninh phần cứng
^^^^^^^^^^^^^^^^^^^^^^^^^^

Đội ngũ nhân viên an ninh phần cứng hiện tại:

- Linus Torvalds (Thành viên Quỹ Linux)
  - Greg Kroah-Hartman (Thành viên Quỹ Linux)
  - Thomas Gleixner (Thành viên Quỹ Linux)

Hoạt động của danh sách gửi thư
^^^^^^^^^^^^^^^^^^^^^^^^^^

Danh sách gửi thư được mã hóa được sử dụng trong quy trình của chúng tôi được lưu trữ trên
Cơ sở hạ tầng CNTT của Linux Foundation. Bằng cách cung cấp dịch vụ này, các thành viên
về mặt kỹ thuật, nhân viên vận hành CNTT của Linux Foundation có
khả năng truy cập thông tin bị cấm, nhưng có nghĩa vụ phải
bảo mật thông qua hợp đồng lao động của họ. CNTT nền tảng Linux
nhân viên cũng chịu trách nhiệm điều hành và quản lý phần còn lại của
cơ sở hạ tầng của kernel.org.

Giám đốc hiện tại của cơ sở hạ tầng Dự án CNTT của Linux Foundation là
Konstantin Ryabitsev.


Thỏa thuận không tiết lộ
-------------------------

Nhóm bảo mật phần cứng nhân Linux không phải là một cơ quan chính thức và do đó
không thể tham gia vào bất kỳ thỏa thuận không tiết lộ nào.  Cộng đồng hạt nhân
nhận thức được tính chất nhạy cảm của những vấn đề đó và đưa ra Biên bản ghi nhớ về
Thay vào đó hãy hiểu.


Biên bản ghi nhớ
---------------------------

Cộng đồng nhân Linux có sự hiểu biết sâu sắc về yêu cầu
cấm vận các vấn đề bảo mật phần cứng để phối hợp giữa
các nhà cung cấp hệ điều hành, nhà phân phối, nhà cung cấp silicon khác nhau và các bên khác.

Cộng đồng nhân Linux đã xử lý thành công vấn đề bảo mật phần cứng
các vấn đề trong quá khứ và có sẵn các cơ chế cần thiết để cho phép
phát triển tuân thủ cộng đồng dưới các hạn chế cấm vận.

Cộng đồng nhân Linux có một nhóm bảo mật phần cứng chuyên trách
liên hệ ban đầu, giám sát quá trình xử lý các vấn đề đó theo
quy định cấm vận.

Nhóm bảo mật phần cứng xác định các nhà phát triển (chuyên gia tên miền)
sẽ thành lập nhóm phản hồi ban đầu cho một vấn đề cụ thể. ban đầu
nhóm phản hồi có thể mời thêm các nhà phát triển (chuyên gia tên miền) để giải quyết
vấn đề một cách kỹ thuật tốt nhất.

Tất cả các nhà phát triển có liên quan cam kết tuân thủ các quy tắc cấm vận và giữ
thông tin nhận được được bảo mật. Vi phạm lời cam kết sẽ dẫn đến
loại trừ ngay lập tức khỏi vấn đề hiện tại và loại bỏ khỏi tất cả các vấn đề liên quan
danh sách gửi thư. Ngoài ra, nhóm bảo mật phần cứng cũng sẽ loại trừ
người phạm tội khỏi các vấn đề trong tương lai. Hậu quả này có tác động rất lớn
răn đe hiệu quả trong cộng đồng của chúng tôi. Trường hợp xảy ra vi phạm
Đội ngũ bảo mật phần cứng sẽ thông báo ngay cho các bên liên quan. Nếu bạn
hoặc bất kỳ ai khác biết được hành vi vi phạm tiềm ẩn, vui lòng báo cáo hành vi đó
ngay lập tức cho nhân viên an ninh phần cứng.


Quá trình
^^^^^^^

Do tính chất phân tán toàn cầu của việc phát triển nhân Linux,
các cuộc gặp mặt trực tiếp gần như không thể giải quyết được vấn đề bảo mật phần cứng
vấn đề.  Hội nghị qua điện thoại khó phối hợp do múi giờ và
yếu tố khác và chỉ nên sử dụng khi thực sự cần thiết. Đã mã hóa
email đã được chứng minh là phương tiện giao tiếp hiệu quả và an toàn nhất
phương pháp cho các loại vấn đề này.

Bắt đầu tiết lộ
"""""""""""""""""""

Việc tiết lộ bắt đầu bằng cách gửi email cho nhóm bảo mật phần cứng nhân Linux theo
phần Liên hệ ở trên.  Liên hệ ban đầu này phải chứa một
mô tả vấn đề và danh sách bất kỳ silicon bị ảnh hưởng nào đã biết. Nếu
tổ chức của bạn xây dựng hoặc phân phối phần cứng bị ảnh hưởng, chúng tôi khuyến khích
bạn cũng phải xem xét phần cứng nào khác có thể bị ảnh hưởng.  Việc tiết lộ
bên có trách nhiệm liên hệ với các nhà cung cấp silicon bị ảnh hưởng theo cách
cách kịp thời.

Nhóm bảo mật phần cứng sẽ cung cấp mã hóa dành riêng cho từng sự cố
danh sách gửi thư sẽ được sử dụng để thảo luận ban đầu với người báo cáo,
tiết lộ thêm và phối hợp khắc phục.

Nhóm bảo mật phần cứng sẽ cung cấp cho bên tiết lộ danh sách các
nhà phát triển (chuyên gia tên miền), những người cần được thông báo ban đầu về
vấn đề sau khi xác nhận với các nhà phát triển rằng họ sẽ tuân thủ điều này
Biên bản ghi nhớ và quy trình được ghi lại. Những nhà phát triển này
thành lập đội ứng phó ban đầu và sẽ chịu trách nhiệm xử lý các vấn đề
vấn đề sau lần liên hệ đầu tiên. Nhóm bảo mật phần cứng đang hỗ trợ
nhóm ứng phó, nhưng không nhất thiết phải tham gia vào việc giảm thiểu
quá trình phát triển.

Mặc dù các nhà phát triển cá nhân có thể được bảo vệ bởi một thỏa thuận không tiết lộ
thông qua người sử dụng lao động của họ, họ không thể tham gia các thỏa thuận không tiết lộ thông tin cá nhân
trong vai trò là nhà phát triển nhân Linux. Tuy nhiên, họ sẽ đồng ý
tuân thủ quy trình được ghi chép này và Biên bản ghi nhớ.

Bên tiết lộ phải cung cấp danh sách liên hệ cho tất cả những người khác
những thực thể đã hoặc cần được thông báo về vấn đề này.
Điều này phục vụ một số mục đích:

- Danh sách các thực thể được tiết lộ cho phép liên lạc trên toàn
   ngành công nghiệp, ví dụ các nhà cung cấp hệ điều hành khác, nhà cung cấp CTNH, v.v.

- Các thực thể được tiết lộ có thể được liên hệ để nêu tên các chuyên gia cần
   tham gia vào quá trình phát triển giảm thiểu.

- Nếu một chuyên gia được yêu cầu xử lý một vấn đề được tuyển dụng bởi một công ty có tên trong danh sách
   thực thể hoặc thành viên của thực thể được liệt kê thì các nhóm phản hồi có thể
   yêu cầu đơn vị đó tiết lộ chuyên gia đó. Điều này đảm bảo
   rằng chuyên gia cũng là thành viên của nhóm ứng phó của đơn vị.

Tiết lộ
""""""""""

Bên tiết lộ cung cấp thông tin chi tiết cho phản hồi ban đầu
nhóm thông qua danh sách gửi thư được mã hóa cụ thể.

Theo kinh nghiệm của chúng tôi, tài liệu kỹ thuật về những vấn đề này thường
một điểm khởi đầu đầy đủ và tốt nhất là làm rõ thêm về mặt kỹ thuật
được thực hiện qua email.

Phát triển giảm nhẹ
""""""""""""""""""""""

Nhóm phản hồi ban đầu thiết lập danh sách gửi thư được mã hóa hoặc sử dụng lại
một cái hiện có nếu thích hợp.

Việc sử dụng danh sách gửi thư gần giống với quy trình phát triển Linux thông thường và
đã được sử dụng thành công để phát triển các biện pháp giảm thiểu cho các phần cứng khác nhau
vấn đề an ninh trước đây.

Danh sách gửi thư hoạt động giống như cách phát triển Linux thông thường.
Các bản vá được đăng tải, thảo luận, xem xét và nếu được đồng ý, sẽ áp dụng cho
một kho lưu trữ git không công khai mà chỉ những người tham gia mới có thể truy cập được
nhà phát triển thông qua kết nối an toàn. Kho chứa nội dung chính
nhánh phát triển dựa trên hạt nhân dòng chính và các nhánh backport cho
phiên bản kernel ổn định khi cần thiết.

Nhóm phản hồi ban đầu sẽ xác định thêm các chuyên gia từ Linux
cộng đồng nhà phát triển kernel khi cần thiết.  Các bên liên quan đều có thể đề xuất
các chuyên gia khác sẽ được mời vào, mỗi người trong số họ sẽ phải tuân theo các quy định tương tự
yêu cầu đã nêu ở trên.

Việc tuyển dụng chuyên gia có thể xảy ra bất cứ lúc nào trong quá trình phát triển và
cần phải được xử lý kịp thời.

Nếu một chuyên gia được tuyển dụng bởi hoặc là thành viên của một tổ chức trong danh sách công bố thông tin
được cung cấp bởi bên tiết lộ thì sự tham gia sẽ được yêu cầu từ
đơn vị có liên quan.

Nếu không, bên tiết lộ sẽ được thông báo về ý kiến của chuyên gia.
sự tham gia. Các chuyên gia được bảo vệ bởi Biên bản ghi nhớ
và bên tiết lộ được yêu cầu thừa nhận sự tham gia của họ.
Trong trường hợp bên tiết lộ có lý do thuyết phục để phản đối,
mọi phản đối phải được đưa ra trong vòng năm ngày làm việc và được giải quyết bằng
đội xử lý sự cố ngay lập tức. Nếu bên tiết lộ không phản ứng
trong vòng năm ngày làm việc, điều này được coi là sự thừa nhận thầm lặng.

Sau khi nhóm xử lý sự cố thừa nhận hoặc giải quyết phản đối, chuyên gia
được bộc lộ và đưa vào quá trình phát triển.

Những người tham gia trong danh sách không được trao đổi về vấn đề này bên ngoài
danh sách gửi thư riêng. Những người tham gia danh sách không được sử dụng bất kỳ tài nguyên được chia sẻ nào
(ví dụ: chủ lao động xây dựng trang trại, hệ thống CI, v.v.) khi làm việc trên các bản vá.

Quyền truy cập sớm
""""""""""""

Các bản vá được thảo luận và phát triển trong danh sách không thể được phân phối
cho bất kỳ cá nhân nào không phải là thành viên của nhóm ứng phó cũng như bất kỳ ai khác
tổ chức.

Để cho phép các nhà cung cấp silicon bị ảnh hưởng làm việc với các nhóm nội bộ của họ và
các đối tác trong ngành về thử nghiệm, xác nhận và hậu cần, sau đây
ngoại lệ được cung cấp:

Đại diện được chỉ định của các nhà cung cấp silicon bị ảnh hưởng là
	được phép giao miếng vá bất cứ lúc nào cho silicon
	đội phản hồi của nhà cung cấp. Người đại diện phải thông báo cho kernel
	đội phản ứng về việc bàn giao. Nhà cung cấp silicon bị ảnh hưởng phải
	có và duy trì quy trình bảo mật được ghi lại của riêng họ cho bất kỳ
	các bản vá được chia sẻ với nhóm phản hồi của họ phù hợp với
	chính sách này.

Nhóm phản hồi của nhà cung cấp silicon có thể phân phối các bản vá này tới
	các đối tác trong ngành và các nhóm nội bộ của họ dưới sự chỉ đạo của
	quy trình bảo mật được ghi lại của nhà cung cấp silicon. Phản hồi từ
	các đối tác trong ngành quay trở lại nhà cung cấp silicon và
	được nhà cung cấp silicon truyền đạt tới nhóm phản hồi hạt nhân.

Việc chuyển giao cho nhóm phản hồi của nhà cung cấp silicon sẽ loại bỏ mọi
	trách nhiệm hoặc trách nhiệm pháp lý từ nhóm phản hồi hạt nhân liên quan đến
	tiết lộ sớm, xảy ra do sự tham gia của
	nhóm nội bộ của nhà cung cấp silicon hoặc các đối tác trong ngành. Silicon
	nhà cung cấp đảm bảo việc miễn trừ trách nhiệm pháp lý này bằng cách đồng ý với điều này
	quá trình.

Phối hợp phát hành
"""""""""""""""""""

Các bên sẽ thỏa thuận về ngày, giờ áp dụng lệnh cấm vận
kết thúc. Tại thời điểm đó, các biện pháp giảm nhẹ đã chuẩn bị sẽ được công bố vào
cây hạt nhân có liên quan.  Không có quy trình thông báo trước:
các biện pháp giảm thiểu được công bố công khai và có sẵn cho tất cả mọi người cùng một lúc
thời gian.

Mặc dù chúng tôi hiểu rằng các vấn đề bảo mật phần cứng cần có lệnh cấm vận phối hợp
thời gian cấm vận phải được giới hạn ở mức thời gian tối thiểu
yêu cầu tất cả các bên liên quan phát triển, thử nghiệm và chuẩn bị
giảm nhẹ. Kéo dài thời gian cấm vận một cách giả tạo để đáp ứng cuộc nói chuyện tại hội nghị
ngày tháng hoặc các lý do phi kỹ thuật khác tạo ra nhiều công việc và gánh nặng hơn cho
có sự tham gia của các nhà phát triển và nhóm phản hồi vì các bản vá cần được cập nhật
ngày để theo dõi quá trình phát triển hạt nhân ngược dòng đang diễn ra,
có thể tạo ra những thay đổi trái ngược nhau.

Nhiệm vụ CVE
""""""""""""""

Cả nhóm bảo mật phần cứng lẫn nhóm phản hồi ban đầu đều không chỉ định
CVE, cũng như CVE không cần thiết cho quá trình phát triển. Nếu CVE là
được cung cấp bởi bên tiết lộ, chúng có thể được sử dụng làm tài liệu
mục đích.

Quy trình đại sứ
-------------------

Để hỗ trợ quá trình này, chúng tôi đã thành lập các đại sứ ở nhiều nước khác nhau.
các tổ chức, những người có thể trả lời các câu hỏi hoặc cung cấp hướng dẫn về
trình báo cáo và xử lý tiếp theo. Đại sứ không tham gia vào
tiết lộ một vấn đề cụ thể, trừ khi được yêu cầu bởi nhóm ứng phó hoặc bởi
một bên liên quan được tiết lộ. Danh sách đại sứ hiện tại:

============== =============================================================
  AMD Tom Lendacky <thomas.lendacky@amd.com>
  Ampe Darren Hart <darren@os.amperecomputing.com>
  Bến du thuyền Catalin ARM <catalin.marinas@arm.com>
  IBM Power Madhavan Srinivasan <maddy@linux.ibm.com>
  IBM Z Christian Borntraeger <borntraeger@de.ibm.com>
  Intel Tony Luck <tony.luck@intel.com>
  Qualcomm Trilok Soni <quic_tsoni@quicinc.com>
  RISC-V Palmer Dabbelt <palmer@dabbelt.com>
  Samsung Javier González <javier.gonz@samsung.com>

Microsoft James Morris <jamorris@linux.microsoft.com>
  Xen Andrew Cooper <andrew.cooper3@citrix.com>

Kinh điển John Johansen <john.johansen@canonical.com>
  Debian Ben Hutchings <ben@decadent.org.uk>
  Oracle Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
  Mũ Đỏ Josh Poimboeuf <jpoimboe@redhat.com>
  SUSE Jiri Kosina <jkosina@suse.cz>

Google Kees Cook <keescook@chromium.org>

LLVM Nick Desaulniers <nick.desaulniers+lkml@gmail.com>
  ============== =============================================================

Nếu bạn muốn tổ chức của mình được thêm vào danh sách đại sứ, vui lòng
liên hệ với nhóm bảo mật phần cứng. Đại sứ được đề cử phải
hiểu và hỗ trợ đầy đủ quy trình của chúng tôi và lý tưởng nhất là có mối liên hệ tốt trong
cộng đồng nhân Linux.

Danh sách gửi thư được mã hóa
-----------------------

Chúng tôi sử dụng danh sách gửi thư được mã hóa để liên lạc. Nguyên tắc hoạt động
trong số các danh sách này là email được gửi đến danh sách được mã hóa bằng
khóa PGP của danh sách hoặc với chứng chỉ S/MIME của danh sách. Danh sách gửi thư
phần mềm giải mã email và mã hóa lại từng email cho từng email
thuê bao có khóa PGP hoặc chứng chỉ S/MIME của thuê bao. Chi tiết
về phần mềm danh sách gửi thư và cách cài đặt được sử dụng để đảm bảo
bảo mật danh sách và bảo vệ dữ liệu có thể được tìm thấy ở đây:
ZZ0000ZZ

Danh sách các phím
^^^^^^^^^

Để liên hệ lần đầu, hãy xem phần ZZ0000ZZ ở trên. Đối với sự cố
danh sách gửi thư cụ thể, khóa và chứng chỉ S/MIME sẽ được chuyển đến
người đăng ký bằng email được gửi từ danh sách cụ thể.

Đăng ký vào danh sách theo sự cố cụ thể
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Việc đăng ký danh sách theo sự cố cụ thể sẽ do các nhóm ứng phó xử lý.
Các bên được tiết lộ muốn tham gia giao tiếp gửi danh sách
các chuyên gia tiềm năng cho nhóm ứng phó để nhóm ứng phó có thể xác nhận
yêu cầu đăng ký.

Mỗi thuê bao cần gửi yêu cầu đăng ký đến nhóm phản hồi
qua email. Email phải được ký bằng khóa PGP của người đăng ký hoặc S/MIME
giấy chứng nhận. Nếu sử dụng khóa PGP thì khóa đó phải có sẵn từ khóa chung
máy chủ và được kết nối lý tưởng với trang web tin cậy PGP của nhân Linux. Xem
Ngoài ra: ZZ0000ZZ

Nhóm phản hồi xác minh rằng yêu cầu của người đăng ký là hợp lệ và thêm
người đăng ký vào danh sách. Sau khi đăng ký thuê bao sẽ nhận được
email từ danh sách gửi thư được ký bằng khóa PGP của danh sách
hoặc chứng chỉ S/MIME của danh sách. Ứng dụng email của người đăng ký có thể trích xuất
khóa PGP hoặc chứng chỉ S/MIME từ chữ ký để người đăng ký
có thể gửi email được mã hóa vào danh sách.

