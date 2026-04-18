.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/display/display-contributing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _display_todos:

=================================
AMDGPU - Đóng góp hiển thị
==============================

Trước hết, nếu bạn ở đây, có lẽ bạn muốn đưa ra một số thông tin kỹ thuật
đóng góp cho mã hiển thị và vì điều đó, chúng tôi xin gửi lời cảm ơn :)

Trang này tóm tắt một số vấn đề bạn có thể trợ giúp; hãy nhớ rằng
đây là một trang tĩnh và bạn nên cố gắng tiếp cận các nhà phát triển
trên danh sách gửi thư amd-gfx hoặc một số nhà bảo trì. Cuối cùng, trang này
tuân theo cách DRM để tạo danh sách TODO; để biết thêm thông tin, hãy kiểm tra
'Tài liệu/gpu/todo.rst'.

Sự cố về Gitlab
=============

Người dùng có thể báo cáo các sự cố liên quan đến GPU AMD tại:

-ZZ0000ZZ

Thông thường, chúng tôi cố gắng thêm nhãn thích hợp cho tất cả các vé mới để dễ dàng
vấn đề về lọc. Nếu bạn có thể tái tạo bất kỳ vấn đề nào, bạn có thể trợ giúp bằng cách bổ sung thêm
thông tin hoặc giải quyết vấn đề.

Cấp độ: đa dạng

IGT
===

ZZ0000ZZ cung cấp nhiều thử nghiệm tích hợp có thể chạy trên GPU của bạn. Chúng tôi luôn luôn
muốn vượt qua một loạt thử nghiệm lớn để tăng phạm vi thử nghiệm trong CI của chúng tôi. Nếu
bạn muốn đóng góp cho mã hiển thị nhưng không chắc chắn nơi nào tốt
là, chúng tôi khuyên bạn nên chạy tất cả các thử nghiệm IGT và cố gắng khắc phục mọi lỗi bạn thấy trong
phần cứng của bạn. Hãy nhớ rằng lỗi này có thể là sự cố IGT hoặc kernel
vấn đề; cần phải phân tích từng trường hợp một.

Cấp độ: đa dạng

.. _IGT: https://gitlab.freedesktop.org/drm/igt-gpu-tools

biên soạn
===========

Sửa các cảnh báo biên dịch
------------------------

Kích hoạt mức cảnh báo W1 hoặc W2 trong quá trình biên dịch kernel và cố gắng sửa lỗi
vấn đề ở phía màn hình.

Cấp độ: Người mới bắt đầu

Khắc phục sự cố biên dịch khi sử dụng kiến ​​trúc um
-------------------------------------------------

Linux có tính năng Linux ở chế độ người dùng (UML) và kernel có thể được biên dịch thành
kiến trúc ZZ0000ZZ. Biên dịch cho ZZ0001ZZ có thể mang lại nhiều lợi thế
từ góc độ thử nghiệm. Chúng tôi hiện có một số vấn đề biên soạn trong này
khu vực mà chúng ta cần khắc phục.

Trình độ: Trung cấp

Tái cấu trúc mã
=============

Thêm tiền tố vào các hàm DC để cải thiện việc gỡ lỗi bằng ftrace
-----------------------------------------------------------

Tính năng gỡ lỗi Ftrace (kiểm tra 'Tài liệu/trace/ftrace.rst') là một
cách tuyệt vời để kiểm tra đường dẫn mã khi các nhà phát triển cố gắng hiểu ý nghĩa của một
lỗi. Ftrace cung cấp cơ chế lọc có thể hữu ích khi nhà phát triển
có linh cảm về phần nào của mã có thể gây ra sự cố; vì lý do này,
nếu một tập hợp các hàm có tiền tố thích hợp thì việc tạo ra một hàm tốt sẽ trở nên dễ dàng
bộ lọc. Ngoài ra, tiền tố có thể cải thiện khả năng đọc dấu vết ngăn xếp.

Mã DC không tuân theo một số quy tắc tiền tố, điều này làm cho bộ lọc Ftrace
phức tạp hơn và làm giảm khả năng đọc của dấu vết ngăn xếp. Nếu bạn muốn
điều gì đó đơn giản để bắt đầu đóng góp cho màn hình, bạn có thể tạo các bản vá cho
thêm tiền tố vào các hàm DC. Để tạo các tiền tố đó, hãy sử dụng một phần của tệp
name làm tiền tố cho tất cả các chức năng trong tệp mục tiêu. Kiểm tra
'amdgpu_dm_crtc.c` and `amdgpu_dm_plane.c` để tham khảo. Tuy nhiên, chúng tôi
khuyên bạn không nên gửi các bản vá lớn thay đổi các tiền tố này; nếu không thì nó
sẽ khó xem xét và kiểm tra, điều này có thể tạo ra những suy nghĩ thứ hai từ
người bảo trì. Hãy thử những bước nhỏ; trong trường hợp gấp đôi, bạn có thể hỏi trước khi đưa vào
nỗ lực. Chúng tôi khuyên bạn trước tiên nên xem các thư mục như dceXYZ, dcnXYZ, cơ bản,
bios, core, clk_mgr, hwss, tài nguyên và irq.

Cấp độ: Người mới bắt đầu

Giảm trùng lặp mã
-----------------------

AMD có một danh mục mở rộng với nhiều dGPU và APU hỗ trợ AMD
hỗ trợ. Để duy trì nhịp độ phát hành phần cứng mới, DCE/DCN được thiết kế theo
một thiết kế kiểu mô-đun, giúp việc cập nhật phần cứng mới trở nên nhanh chóng. Trong những năm qua,
amdgpu đã tích lũy một số nợ kỹ thuật trong lĩnh vực sao chép mã. Vì điều này
nhiệm vụ, sẽ là một ý tưởng hay nếu bạn tìm một công cụ có thể phát hiện ra sự trùng lặp mã
(bao gồm các mẫu) và sử dụng nó làm hướng dẫn để giảm sự trùng lặp.

Trình độ: Trung cấp

Làm cho Atomic_commit_[check|tail] dễ đọc hơn
---------------------------------------------

Các chức năng chịu trách nhiệm về cam kết nguyên tử và đuôi rất phức tạp và
sâu rộng. Đặc biệt ZZ0000ZZ là một hàm dài và
có thể hưởng lợi từ việc được chia thành những người trợ giúp nhỏ hơn. Những cải tiến trong lĩnh vực này
được chào đón nhiều hơn, nhưng hãy nhớ rằng những thay đổi trong lĩnh vực này sẽ ảnh hưởng
tất cả các ASIC, nghĩa là việc tái cấu trúc yêu cầu xác minh toàn diện; trong
nói cách khác, nỗ lực này có thể mất một thời gian để xác nhận.

Cấp độ: Nâng cao

Tài liệu
=============

Mở rộng kernel-doc
-----------------

Nhiều hàm DC không có kernel-doc thích hợp; hiểu chức năng và
thêm tài liệu là một cách tuyệt vời để tìm hiểu thêm về trình điều khiển amdgpu và
cũng để lại những đóng góp nổi bật cho toàn thể cộng đồng.

Cấp độ: Người mới bắt đầu

Ngoài AMDGPU
=============

AMDGPU cung cấp các tính năng chưa được kích hoạt trong không gian người dùng. Cái này
phần nêu bật một số tính năng hiển thị thú vị nhất có thể được kích hoạt
với người trợ giúp nhà phát triển không gian người dùng.

Kích hoạt lớp lót
---------------

Màn hình AMD có tính năng này được gọi là lớp lót (bạn có thể đọc thêm tại
'Documentation/gpu/amdgpu/display/mpo-overview.rst') nhằm mục đích
tiết kiệm năng lượng khi phát video. Ý tưởng cơ bản là đưa một video vào
lót mặt phẳng ở phía dưới và mặt bàn ở mặt phẳng phía trên có một lỗ
trong khu vực video. Tính năng này được bật trong ChromeOS và từ dữ liệu của chúng tôi
đo lường, nó có thể tiết kiệm điện năng.

Cấp độ: Không xác định

Điều chế đèn nền thích ứng (ABM)
-----------------------------------

ABM là tính năng điều chỉnh độ sáng nền và điểm ảnh của bảng hiển thị
giá trị tùy thuộc vào hình ảnh được hiển thị. Tính năng tiết kiệm năng lượng này có thể rất
hữu ích khi hệ thống bắt đầu hết pin; vì điều này sẽ ảnh hưởng đến
hiển thị độ trung thực đầu ra, sẽ tốt hơn nếu tùy chọn này là thứ gì đó
người dùng có thể bật hoặc tắt.

Cấp độ: Không xác định


HDR & Quản lý màu sắc & VRR
----------------------------

HDR, Quản lý màu sắc và VRR là những chủ đề lớn và thật khó để đưa chúng vào
ToDos ngắn gọn. Nếu bạn quan tâm đến chủ đề này, chúng tôi khuyên bạn nên kiểm tra một số
bài đăng trên blog từ các nhà phát triển cộng đồng để hiểu rõ hơn về một số
những thách thức cụ thể và những người làm việc về chủ đề này. Nếu ai muốn làm việc
về một số phần cụ thể, chúng tôi có thể cố gắng trợ giúp bằng một số hướng dẫn cơ bản. Cuối cùng,
hãy nhớ rằng chúng tôi đã có sẵn một số tài liệu kernel cho các khu vực đó.

Cấp độ: Không xác định
