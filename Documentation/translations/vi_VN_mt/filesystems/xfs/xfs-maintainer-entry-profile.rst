.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/filesystems/xfs/xfs-maintainer-entry-profile.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

Hồ sơ đăng nhập của người bảo trì XFS
============================

Tổng quan
--------
XFS là một hệ thống tệp hiệu suất cao nổi tiếng trong nhân Linux.
Mục đích của dự án này là cung cấp và duy trì một hệ thống mạnh mẽ và
hệ thống tập tin hiệu suất.

Các bản vá thường được hợp nhất vào nhánh tiếp theo của nhánh thích hợp
kho lưu trữ git.
Sau một thời gian thử nghiệm, nhánh tiếp theo sẽ được sáp nhập vào nhánh chính
chi nhánh.

Mã hạt nhân được hợp nhất vào cây xfs-linux [0].
Mã vùng người dùng được hợp nhất vào cây xfsprogs[1].
Các trường hợp thử nghiệm được hợp nhất vào cây xfstests[2].
Tài liệu định dạng Ondisk được hợp nhất vào cây tài liệu xfs[3].

Tất cả các bản vá liên quan đến XFS ZZ0000ZZ đều được gửi toàn bộ qua đường bưu điện
liệt kê linux-xfs@vger.kernel.org.

Vai trò
-----
Có tám vai trò chính trong dự án XFS.
Một người có thể đảm nhận nhiều vai trò và một vai trò có thể được lấp đầy bởi
nhiều người.
Bất kỳ ai đảm nhận một vai trò nào đó đều nên kiểm tra lại bản thân và
những người khác một cách thường xuyên về tình trạng kiệt sức.

- ZZ0000ZZ: Bất kỳ ai gửi bản vá nhưng không liên quan
  trong dự án XFS một cách thường xuyên.
  Những người này thường là những người làm việc trên các hệ thống tập tin khác hoặc
  nơi khác trong cộng đồng hạt nhân.

- ZZ0000ZZ: Người đã quen thuộc với codebase XFS đủ để
  viết mã, tài liệu và bài kiểm tra mới.

Các nhà phát triển thường có thể được tìm thấy trong kênh IRC được ZZ0000ZZ đề cập
  mục trong tệp MAINTAINERS kernel.

- ZZ0000ZZ: Một nhà phát triển ít nhất rất quen thuộc với
  một phần nào đó của cơ sở mã XFS và/hoặc các hệ thống con khác trong kernel.
  Những người này cùng nhau quyết định các mục tiêu dài hạn của dự án
  và thúc đẩy cộng đồng theo hướng đó.
  Họ nên giúp ưu tiên phát triển và đánh giá công việc cho mỗi bản phát hành
  chu kỳ.

Các nhà phát triển cấp cao có xu hướng tham gia tích cực hơn vào kênh IRC.

- ZZ0000ZZ: Người nào đó (rất có thể cũng là nhà phát triển) đọc mã
  trình để quyết định:

0. Ý tưởng đằng sau sự đóng góp có hợp lý không?
  1. Ý tưởng có phù hợp với mục tiêu của dự án không?
  2. Đóng góp có được thiết kế chính xác không?
  3. Đóng góp có được đánh giá cao không?
  4. Sự đóng góp có thể được kiểm tra một cách hiệu quả không?

Người đánh giá nên tự xác định mình có mục ZZ0000ZZ trong kernel
  và fstests các tệp MAINTAINERS.

- ZZ0000ZZ: Người này chịu trách nhiệm ra đề thi
  mục tiêu bao quát của dự án, đàm phán với các nhà phát triển để quyết định
  về các thử nghiệm mới cho các tính năng mới và đảm bảo rằng các nhà phát triển và
  người quản lý phát hành thực hiện thử nghiệm.

Trưởng nhóm kiểm tra phải tự xác định mình bằng mục nhập ZZ0000ZZ trong
  phần XFS của tệp MAINTAINERS fstests.

- ZZ0000ZZ: Người kiểm tra các báo cáo lỗi gửi đến chỉ trong
  đủ chi tiết để xác định người sẽ gửi báo cáo
  chuyển tiếp.

Người xử lý lỗi phải tự xác định mình bằng mục nhập ZZ0000ZZ trong
  tệp hạt nhân MAINTAINERS.

- ZZ0000ZZ: Người này hợp nhất các bản vá đã được đánh giá thành một
  nhánh tích hợp, kiểm tra kết quả cục bộ, đẩy nhánh tới một
  kho lưu trữ git công khai và gửi các yêu cầu kéo ngược dòng.
  Trình quản lý phát hành dự kiến ​​sẽ không hoạt động trên các bản vá tính năng mới.
  Nếu nhà phát triển và người đánh giá không đạt được giải pháp ở một điểm nào đó,
  người quản lý phát hành phải có khả năng can thiệp để cố gắng điều khiển một
  độ phân giải.

Người quản lý phát hành phải tự xác định mình bằng mục nhập ZZ0000ZZ trong
  tệp hạt nhân MAINTAINERS.

- ZZ0000ZZ: Người này gọi điện và điều hành các cuộc họp của bao nhiêu người
  Những người tham gia XFS mà họ có thể nhận được khi các cuộc thảo luận về danh sách gửi thư chứng minh
  không đủ cho việc ra quyết định tập thể.
  Họ cũng có thể đóng vai trò là người liên lạc giữa các nhà quản lý của tổ chức
  tài trợ cho công việc trên bất kỳ phần nào của XFS.

- ZZ0000ZZ: Người backport và kiểm tra các bản sửa lỗi từ
  ngược dòng tới hạt nhân LTS.
  Có xu hướng có sáu cây LTS riêng biệt tại bất kỳ thời điểm nào.

Người bảo trì cho bản phát hành LTS nhất định phải tự nhận dạng mình bằng một
  Mục nhập ZZ0000ZZ trong tệp MAINTAINERS cho cây LTS đó.
  Hạt nhân LTS không được bảo trì phải được đánh dấu bằng trạng thái ZZ0001ZZ trong đó
  cùng một tập tin.

Phụ lục danh sách kiểm tra bài nộp
-----------------------------
Vui lòng tuân theo các quy tắc bổ sung sau khi gửi tới XFS:

- Các bản vá chỉ ảnh hưởng đến chính hệ thống tập tin phải dựa trên
  -rc mới nhất hoặc nhánh for-next.
  Các bản vá này sẽ được hợp nhất trở lại nhánh tiếp theo.

- Tác giả các bản vá chạm vào các hệ thống con khác cần phối hợp với
  người bảo trì XFS và các hệ thống con có liên quan quyết định cách
  tiến hành hợp nhất.

- Mọi bản vá thay đổi XFS phải được cc toàn bộ sang linux-xfs.
  Không gửi các bản vá lỗi một phần; điều đó làm cho việc phân tích ở phạm vi rộng hơn
  bối cảnh của những thay đổi khó khăn không cần thiết.

- Bất cứ ai thực hiện thay đổi kernel có những thay đổi tương ứng với
  tiện ích không gian người dùng sẽ gửi các thay đổi không gian người dùng dưới dạng riêng biệt
  các bản vá ngay sau các bản vá kernel.

- Tác giả của các bản vá sửa lỗi dự kiến sẽ sử dụng fstests[2] để thực hiện
  thử nghiệm A/B của bản vá để xác định rằng không có hồi quy.
  Khi có thể, nên viết một trường hợp kiểm thử hồi quy mới cho
  fstests.

- Tác giả của các bản vá tính năng mới phải đảm bảo rằng các fstest sẽ có
  các trường hợp thử nghiệm trường hợp góc đầu vào và chức năng thích hợp cho phiên bản mới
  tính năng.

- Khi triển khai một tính năng mới, chúng tôi khuyên bạn nên
  các nhà phát triển viết một tài liệu thiết kế để trả lời các câu hỏi sau:

* Vấn đề ZZ0000ZZ này có đang được giải quyết không?

* ZZ0000ZZ sẽ được hưởng lợi từ giải pháp này và ZZ0001ZZ cũng vậy
    truy cập nó?

* ZZ0000ZZ tính năng mới này có hoạt động không?  Điều này sẽ chạm vào dữ liệu chính
    các cấu trúc và thuật toán hỗ trợ giải pháp ở mức cao hơn
    hơn là nhận xét về mã.

* Cần có giao diện không gian người dùng ZZ0000ZZ để xây dựng dựa trên giao diện mới
    tính năng?

* ZZ0000ZZ công việc này sẽ được kiểm tra để đảm bảo rằng nó giải quyết được vấn đề
    các vấn đề được nêu trong tài liệu thiết kế mà không gây ra vấn đề mới
    vấn đề?

Tài liệu thiết kế phải được cam kết trong tài liệu kernel
  thư mục.
  Nó có thể được bỏ qua nếu tính năng này đã được nhiều người biết đến.
  cộng đồng.

- Các bản vá cho các thử nghiệm mới phải được gửi dưới dạng các bản vá riêng biệt
  ngay sau các bản vá lỗi kernel và mã không gian người dùng.

- Những thay đổi về định dạng trên đĩa của XFS phải được mô tả trong ondisk
  định dạng tài liệu [3] và gửi dưới dạng bản vá sau fstests
  bản vá lỗi.

- Các bản vá thực hiện sửa lỗi và dọn dẹp mã tiếp theo nên được đưa vào
  đã sửa lỗi ở phần đầu của loạt bài này để dễ dàng chuyển ngược lại.

Ngày của chu kỳ phát hành chính
-----------------------
Các bản sửa lỗi có thể được gửi bất cứ lúc nào, mặc dù người quản lý phát hành có thể quyết định
trì hoãn một bản vá khi cửa sổ hợp nhất tiếp theo đóng lại.

Việc gửi mã nhắm mục tiêu đến cửa sổ hợp nhất tiếp theo sẽ được gửi giữa
-rc1 và -rc6.
Điều này giúp cộng đồng có thời gian để xem xét các thay đổi, đề xuất các thay đổi khác,
và để tác giả kiểm tra lại những thay đổi đó.

Việc gửi mã cũng yêu cầu thay đổi fs/iomap và nhắm mục tiêu
cửa sổ hợp nhất tiếp theo sẽ được gửi giữa -rc1 và -rc4.
Điều này cho phép cộng đồng kernel rộng hơn có đủ thời gian để kiểm tra
những thay đổi về cơ sở hạ tầng.

Xem lại nhịp
--------------
Nói chung, vui lòng đợi ít nhất một tuần trước khi gửi phản hồi.
Để tìm người đánh giá, hãy tham khảo tệp MAINTAINERS hoặc hỏi
các nhà phát triển có thẻ Người đánh giá về những thay đổi của XFS để xem xét và
đưa ra ý kiến của họ.

Tài liệu tham khảo
----------
| [0] ZZ0000ZZ
| [1] ZZ0001ZZ
| [2] ZZ0002ZZ
| [3] ZZ0003ZZ
