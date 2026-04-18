.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/automated_testing.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

=============================================
Kiểm tra tự động hệ thống con DRM
=========================================

Giới thiệu
============

Đảm bảo rằng những thay đổi về lõi hoặc trình điều khiển không gây ra hiện tượng hồi quy có thể
rất tốn thời gian khi cần nhiều cấu hình phần cứng khác nhau
được thử nghiệm. Hơn nữa, nó không thực tế đối với mỗi người quan tâm đến điều này.
thử nghiệm để có được và duy trì những gì có thể là một lượng đáng kể
phần cứng.

Ngoài ra, các nhà phát triển nên kiểm tra sự hồi quy trong mã của họ bằng cách
bản thân họ, thay vì dựa vào những người bảo trì để tìm thấy chúng và sau đó
báo cáo lại.

Có các phương tiện trong gitlab.freedesktop.org để tự động kiểm tra Mesa
cũng có thể được sử dụng để thử nghiệm hệ thống con DRM. Tài liệu này giải thích cách
những người quan tâm đến việc thử nghiệm nó có thể sử dụng cơ sở hạ tầng dùng chung này để tiết kiệm
khá nhiều thời gian và công sức.


Các tập tin liên quan
==============

trình điều khiển/gpu/drm/ci/gitlab-ci.yml
--------------------------------

Đây là tệp cấu hình gốc cho GitLab CI. Trong số những thứ khác ít thú vị hơn
bit, nó chỉ định phiên bản cụ thể của tập lệnh sẽ được sử dụng. có
một số biến có thể được sửa đổi để thay đổi hoạt động của đường ống:

DRM_CI_PROJECT_PATH
    Kho chứa cơ sở hạ tầng phần mềm Mesa cho CI

DRM_CI_COMMIT_SHA
    Một bản sửa đổi cụ thể để sử dụng từ kho lưu trữ đó

UPSTREAM_REPO
    URL vào kho git chứa nhánh mục tiêu

TARGET_BRANCH
    Chi nhánh mà chi nhánh này sẽ được sáp nhập vào

IGT_VERSION
    Bản sửa đổi của igt-gpu-tools đang được sử dụng, từ
    ZZ0000ZZ

trình điều khiển/gpu/drm/ci/testlist.txt
-------------------------------

IGT kiểm tra khả năng chạy trên tất cả các trình điều khiển (trừ khi được đề cập trong \*-skips.txt của trình điều khiển
tập tin, xem bên dưới).

trình điều khiển/gpu/drm/ci/${DRIVER_NAME}-${HW_REVISION}-fails.txt
----------------------------------------------------------

Liệt kê các lỗi đã biết đối với một trình điều khiển nhất định trên một bản sửa đổi phần cứng cụ thể.

trình điều khiển/gpu/drm/ci/${DRIVER_NAME}-${HW_REVISION}-flakes.txt
-----------------------------------------------------------

Liệt kê các bài kiểm tra dành cho một trình điều khiển nhất định trên một bản sửa đổi phần cứng cụ thể là
được biết là cư xử không đáng tin cậy. Những thử nghiệm này sẽ không khiến công việc thất bại bất kể
kết quả. Chúng vẫn sẽ được điều hành.

Mỗi mục nhập vảy mới phải được liên kết với một liên kết đến email báo cáo
lỗi cho tác giả của trình điều khiển bị ảnh hưởng hoặc vấn đề GitLab có liên quan. Mục nhập
cũng phải bao gồm tên bo mạch hoặc tên Cây thiết bị, phiên bản kernel đầu tiên
bị ảnh hưởng, phiên bản IGT được sử dụng để thử nghiệm và tỷ lệ lỗi gần đúng.

Chúng phải được cung cấp theo định dạng sau::

Báo cáo # Bug: $LORE_URL_OR_GITLAB_ISSUE
  # Board Tên: Broken-board.dtb
  Phiên bản # Linux: 6.6-rc1
  Phiên bản # ZZ0001ZZ: 1.28-gd2af13d9f
  Tỷ lệ # Failure: 100
  thử nghiệm bong tróc

Sử dụng liên kết thích hợp bên dưới để tạo sự cố GitLab:
trình điều khiển amdgpu: ZZ0000ZZ
trình điều khiển i915: ZZ0001ZZ
trình điều khiển msm: ZZ0002ZZ
trình điều khiển xe: ZZ0003ZZ

trình điều khiển/gpu/drm/ci/${DRIVER_NAME}-${HW_REVISION}-skips.txt
-----------------------------------------------------------

Liệt kê các bài kiểm tra sẽ không được chạy cho một trình điều khiển nhất định trên một phần cứng cụ thể
sửa đổi. Đây thường là các bài kiểm tra can thiệp vào việc chạy thử nghiệm
list do treo máy, gây ra OOM, mất quá nhiều thời gian, v.v.


Cách bật kiểm tra tự động trên cây của bạn
============================================

1. Tạo cây Linux trong ZZ0000ZZ nếu bạn chưa có
chưa

2. Trong cấu hình kho kernel của bạn (ví dụ:
ZZ0000ZZ thay đổi
Tệp cấu hình CI/CD từ .gitlab-ci.yml đến
trình điều khiển/gpu/drm/ci/gitlab-ci.yml.

3. Yêu cầu được thêm vào nhóm drm/ci-ok để người dùng của bạn có
các đặc quyền cần thiết để chạy CI trên ZZ0000ZZ

4. Lần tới khi bạn đẩy tới kho lưu trữ này, bạn sẽ thấy đường dẫn CI đang được
đã tạo (ví dụ: ZZ0000ZZ

5. Các công việc khác nhau sẽ được thực hiện và khi quy trình kết thúc, tất cả các công việc sẽ được thực hiện
phải có màu xanh trừ khi tìm thấy hồi quy.

6. Cảnh báo trong quy trình cho biết rằng lockdep
(xem Tài liệu/khóa/lockdep-design.rst) các vấn đề đã được phát hiện
trong các bài kiểm tra.


Cách cập nhật kỳ vọng kiểm tra
===============================

Nếu những thay đổi của bạn đối với mã khắc phục được bất kỳ thử nghiệm nào, bạn sẽ phải xóa một hoặc nhiều
dòng từ một hoặc nhiều tệp trong
driver/gpu/drm/ci/${DRIVER_NAME__*_fails.txt, cho từng nền tảng thử nghiệm
bị ảnh hưởng bởi sự thay đổi.


Cách mở rộng vùng phủ sóng
======================

Nếu mã của bạn thay đổi, bạn có thể chạy nhiều thử nghiệm hơn (bằng cách giải quyết độ tin cậy
chẳng hạn như các vấn đề), bạn có thể xóa các bài kiểm tra khỏi danh sách nhóm và/hoặc bỏ qua,
và sau đó là kết quả mong đợi nếu có bất kỳ lỗi nào đã biết.

Nếu có nhu cầu cập nhật phiên bản IGT đang sử dụng (có thể bạn có
đã thêm nhiều thử nghiệm hơn vào nó), hãy cập nhật biến IGT_VERSION ở đầu
tập tin gitlab-ci.yml.


Cách kiểm tra các thay đổi của bạn đối với tập lệnh
=======================================

Để kiểm tra các thay đổi đối với tập lệnh trong repo drm-ci, hãy thay đổi
Các biến DRM_CI_PROJECT_PATH và DRM_CI_COMMIT_SHA trong
driver/gpu/drm/ci/gitlab-ci.yml để khớp với nhánh của dự án (ví dụ:
janedoe/drm-ci). Ngã ba này cần phải ở ZZ0000ZZ


Cách kết hợp các bản sửa lỗi bên ngoài vào thử nghiệm của bạn
=================================================

Thông thường, hồi quy ở các cây khác sẽ ngăn cản việc kiểm tra các thay đổi cục bộ đối với cây
cây đang được thử nghiệm. Các bản sửa lỗi này sẽ được tự động hợp nhất trong quá trình xây dựng
công việc từ một nhánh trong cây mục tiêu được đặt tên là
${TARGET_BRANCH}-sửa lỗi bên ngoài.

Nếu đường dẫn không nằm trong yêu cầu hợp nhất và một nhánh có cùng tên
tồn tại trong cây cục bộ, các cam kết từ nhánh đó cũng sẽ được hợp nhất vào.


Cách xử lý các phòng thử nghiệm tự động có thể ngừng hoạt động
========================================================

Nếu một trang trại phần cứng ngừng hoạt động và do đó khiến đường ống bị hỏng, điều đó sẽ
nếu không thì vượt qua, người ta có thể vô hiệu hóa tất cả các công việc sẽ được gửi đến trang trại đó
bằng cách chỉnh sửa tập tin tại
ZZ0000ZZ