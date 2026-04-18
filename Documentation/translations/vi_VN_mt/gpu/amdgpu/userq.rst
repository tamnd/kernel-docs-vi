.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/amdgpu/userq.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. _amdgpu-userq:

====================
 Hàng đợi chế độ người dùng
==================

Giới thiệu
============

Tương tự như KFD, hàng đợi công cụ GPU di chuyển vào không gian người dùng.  Ý tưởng là để cho
quy trình người dùng quản lý trực tiếp nội dung gửi của họ tới các công cụ GPU, bỏ qua
IOCTL gọi tài xế nộp bài.  Điều này làm giảm chi phí và cũng cho phép
GPU để gửi tác phẩm cho chính nó.  Ứng dụng có thể thiết lập đồ thị công việc của các công việc
trên nhiều động cơ GPU mà không cần phải di chuyển qua CPU.

UMD giao tiếp trực tiếp với chương trình cơ sở thông qua các vùng bộ nhớ dùng chung cho mỗi ứng dụng.
Phương tiện chính cho việc này là xếp hàng.  Hàng đợi là một bộ đệm vòng có chức năng đọc
con trỏ (rptr) và con trỏ ghi (wptr).  UMD ghi các gói IP cụ thể
vào hàng đợi và phần sụn xử lý các gói đó, bắt đầu công việc trên
Động cơ GPU.  Bản cập nhật CPU trong ứng dụng (hoặc hàng đợi hoặc thiết bị khác)
wptr để thông báo cho phần sụn biết khoảng cách vào bộ đệm vòng để xử lý các gói
và rtpr cung cấp phản hồi cho UMD về tiến trình của chương trình cơ sở
trong việc thực thi các gói tin đó.  Khi wptr và rptr bằng nhau, hàng đợi sẽ
nhàn rỗi.

Lý thuyết hoạt động
===================

Các công cụ khác nhau trên GPU AMD hiện đại hỗ trợ nhiều hàng đợi cho mỗi công cụ với một
phần mềm lập kế hoạch xử lý động các hàng đợi của người dùng trên
khe hàng đợi phần cứng có sẵn.  Khi số lượng người dùng xếp hàng đông hơn
các khe hàng đợi phần cứng có sẵn, chương trình cơ sở lập kế hoạch tự động ánh xạ và
hủy bản đồ hàng đợi dựa trên mức độ ưu tiên và thời gian.  Trạng thái của mỗi hàng đợi người dùng
được quản lý trong trình điều khiển hạt nhân trong MQD (Bộ mô tả hàng đợi bộ nhớ).  Đây là một
bộ đệm trong bộ nhớ có thể truy cập GPU để lưu trữ trạng thái của hàng đợi người dùng.  các
chương trình cơ sở lập lịch sử dụng MQD để tải trạng thái hàng đợi vào HQD (Phần cứng
Bộ mô tả hàng đợi) khi hàng đợi người dùng được ánh xạ.  Mỗi hàng đợi người dùng yêu cầu một
số lượng bộ đệm bổ sung đại diện cho bộ đệm vòng và bất kỳ siêu dữ liệu nào
động cơ cần thiết cho hoạt động thời gian chạy.  Trên hầu hết các động cơ, điều này bao gồm
chính bộ đệm vòng, bộ đệm rptr (trong đó phần sụn sẽ theo dõi rptr
vào không gian người dùng), bộ đệm wptr (nơi ứng dụng sẽ ghi wptr cho
chương trình cơ sở để lấy nó) và chuông cửa.  Chuông cửa là một phần của
BAR MMIO của thiết bị có thể được ánh xạ tới hàng đợi người dùng cụ thể.  Khi
ứng dụng ghi vào chuông cửa, nó sẽ báo hiệu cho phần sụn thực hiện một số
hành động. Việc ghi vào chuông cửa sẽ đánh thức chương trình cơ sở và khiến nó tìm nạp
wptr và bắt đầu xử lý các gói trong hàng đợi. Mỗi trang 4K của chuông cửa
BAR hỗ trợ phạm vi bù cụ thể cho các động cơ cụ thể.  Chuông cửa của một
hàng đợi phải được ánh xạ vào khẩu độ được căn chỉnh theo IP được hàng đợi sử dụng
(ví dụ: GFX, VCN, SDMA, v.v.).  Các khẩu độ chuông cửa này được thiết lập thông qua NBIO
sổ đăng ký.  Chuông cửa có các khối 32 bit hoặc 64 bit (tùy theo động cơ)
chuông cửa BAR.  Trang chuông cửa 4K cung cấp 512 chuông cửa 64 bit với tối đa
512 hàng đợi người dùng.  Một tập hợp con của mỗi trang được dành riêng cho từng loại IP được hỗ trợ
trên thiết bị.  Người dùng có thể truy vấn phạm vi chuông cửa cho từng IP thông qua INFO
IOCTL.  Xem phần Giao diện IOCTL để biết thêm thông tin.

Khi một ứng dụng muốn tạo hàng đợi người dùng, nó sẽ phân bổ số lượng cần thiết
bộ đệm cho hàng đợi (bộ đệm vòng, wptr và rptr, vùng lưu ngữ cảnh, v.v.).
Đây có thể là các bộ đệm riêng biệt hoặc là một phần của một bộ đệm lớn hơn.  ứng dụng
sẽ ánh xạ (các) bộ đệm vào GPUVM của nó và sử dụng địa chỉ ảo GPU của
vùng bộ nhớ họ muốn sử dụng cho hàng đợi người dùng.  Họ cũng sẽ
phân bổ một trang chuông cửa cho các chuông cửa được người dùng sử dụng trong hàng đợi.  các
sau đó ứng dụng sẽ đưa MQD vào cấu trúc USERQ IOCTL với
Địa chỉ ảo GPU và chỉ số chuông cửa mà họ muốn sử dụng.  Người dùng cũng có thể
chỉ định các thuộc tính cho hàng đợi người dùng (ưu tiên, liệu hàng đợi có an toàn không
đối với nội dung được bảo vệ, v.v.).  Ứng dụng sau đó sẽ gọi USERQ
CREATE IOCTL để tạo hàng đợi bằng cách sử dụng các chi tiết MQD được chỉ định trong IOCTL.
Sau đó, trình điều khiển hạt nhân sẽ xác thực MQD do ứng dụng cung cấp và
dịch MQD sang định dạng MQD dành riêng cho công cụ dành cho IP.  IP
MQD cụ thể sẽ được phân bổ và hàng đợi sẽ được thêm vào danh sách chạy
được duy trì bởi phần mềm lập kế hoạch.  Khi hàng đợi đã được tạo,
ứng dụng có thể ghi các gói trực tiếp vào hàng đợi, cập nhật wptr và
ghi vào phần bù chuông cửa để bắt đầu công việc trong hàng đợi của người dùng.

Khi ứng dụng hoàn tất với hàng đợi người dùng, nó sẽ gọi USERQ
FREE IOCTL để tiêu diệt nó.  Trình điều khiển hạt nhân sẽ chiếm trước hàng đợi và
xóa nó khỏi danh sách chạy của chương trình cơ sở lập lịch.  Sau đó là IP cụ thể MQD
sẽ được giải phóng và trạng thái hàng đợi của người dùng sẽ được dọn sạch.

Một số động cơ cũng có thể yêu cầu chuông cửa tổng hợp nếu động cơ không
hỗ trợ chuông cửa từ hàng đợi chưa được lập bản đồ.  Chuông cửa tổng hợp là một sản phẩm đặc biệt
trang của không gian chuông cửa đánh thức bộ lập lịch.  Trong trường hợp động cơ có thể
được đăng ký vượt mức, một số hàng đợi có thể không được ánh xạ.  Nếu chuông cửa rung khi
hàng đợi không được ánh xạ, phần sụn động cơ có thể bỏ lỡ yêu cầu.  Một số
chương trình cơ sở lập kế hoạch có thể giải quyết vấn đề này bằng cách thăm dò bóng wptr khi
phần cứng được đăng ký vượt mức, các công cụ khác có thể hỗ trợ cập nhật chuông cửa từ
hàng đợi chưa được ánh xạ.  Trong trường hợp một trong các tùy chọn này không có sẵn,
trình điều khiển hạt nhân sẽ ánh xạ một trang không gian chuông cửa tổng hợp vào mỗi GPUVM
không gian.  UMD sau đó sẽ cập nhật chuông cửa và wptr như bình thường rồi viết
đến cả chuông cửa tổng hợp.

Gói đặc biệt
---------------

Để hỗ trợ đồng bộ hóa tiềm ẩn kế thừa, cũng như người dùng hỗn hợp và
hàng đợi kernel, chúng ta cần một cơ chế đồng bộ hóa an toàn.  Bởi vì
hàng đợi kernel hoặc các tác vụ quản lý bộ nhớ phụ thuộc vào hàng rào kernel, chúng ta cần một cách
để hàng đợi người dùng cập nhật bộ nhớ mà kernel có thể sử dụng cho hàng rào, nhưng không thể
bị một diễn viên xấu làm phiền.  Để hỗ trợ điều này, chúng tôi đã thêm hàng rào được bảo vệ
gói.  Gói này hoạt động bằng cách ghi một giá trị tăng dần vào
một vị trí bộ nhớ mà chỉ những khách hàng có đặc quyền mới có quyền ghi vào. người dùng
hàng đợi chỉ có quyền truy cập đọc.  Khi gói này được thực thi, vị trí bộ nhớ
được cập nhật và các hàng đợi khác (kernel hoặc user) có thể xem kết quả.  các
ứng dụng người dùng sẽ gửi gói này trong luồng lệnh của họ.  thực tế
định dạng gói thay đổi từ IP này sang IP khác (GFX/Compute, SDMA, VCN, v.v.), nhưng
hành vi là như nhau.  Việc gửi gói được xử lý trong không gian người dùng.  các
trình điều khiển hạt nhân thiết lập bộ nhớ đặc quyền được sử dụng cho mỗi hàng đợi người dùng khi nó
thiết lập hàng đợi khi ứng dụng tạo chúng.


Quản lý bộ nhớ
=================

Giả định rằng tất cả các bộ đệm được ánh xạ vào không gian GPUVM cho quy trình đều được
hợp lệ khi động cơ trên GPU đang chạy.  Trình điều khiển kernel sẽ chỉ cho phép
hàng đợi người dùng chạy khi tất cả các bộ đệm được ánh xạ.  Nếu có một sự kiện bộ nhớ xảy ra
yêu cầu di chuyển bộ đệm, trình điều khiển kernel sẽ ưu tiên hàng đợi của người dùng,
di chuyển bộ đệm đến nơi cần thiết, cập nhật bảng trang GPUVM và
vô hiệu hóa TLB, sau đó tiếp tục hàng đợi của người dùng.

Tương tác với hàng đợi hạt nhân
==============================

Tùy thuộc vào IP và chương trình cơ sở lập lịch, bạn có thể kích hoạt hàng đợi kernel
và hàng đợi người dùng cùng một lúc, tuy nhiên, bạn bị giới hạn bởi các khe HQD.
Hàng đợi hạt nhân luôn được ánh xạ nên mọi công việc đi vào hàng đợi hạt nhân sẽ
ưu tiên.  Điều này giới hạn các khe HQD có sẵn cho hàng đợi người dùng.

Không phải tất cả IP đều hỗ trợ hàng đợi người dùng trên tất cả GPU.  Vì vậy, UMD sẽ cần phải
hỗ trợ cả hàng đợi người dùng và hàng đợi kernel tùy thuộc vào IP.  Ví dụ, một
GPU có thể hỗ trợ hàng đợi người dùng cho GFX, máy tính và SDMA, nhưng không hỗ trợ cho VCN, JPEG,
và VPE.  UMD cần hỗ trợ cả hai.  Trình điều khiển kernel cung cấp một cách để
xác định xem hàng đợi người dùng và hàng đợi kernel có được hỗ trợ trên cơ sở mỗi IP hay không.
UMD có thể truy vấn thông tin này thông qua INFO IOCTL và xác định xem có nên sử dụng
hàng đợi kernel hoặc hàng đợi người dùng cho mỗi IP.

Đặt lại hàng đợi
============

Đối với hầu hết các động cơ, hàng đợi có thể được đặt lại riêng lẻ.  GFX, tính toán và SDMA
hàng đợi có thể được thiết lập lại riêng lẻ.  Khi hàng đợi bị treo được phát hiện, nó có thể
đặt lại thông qua chương trình cơ sở lập lịch hoặc MMIO.  Vì không có kernel
hàng rào cho hầu hết các hàng đợi của người dùng, chúng thường chỉ được phát hiện khi một số hàng đợi khác
sự kiện xảy ra; ví dụ: một sự kiện bộ nhớ yêu cầu di chuyển bộ đệm.  Khi nào
hàng đợi được ưu tiên, nếu hàng đợi bị treo thì việc ưu tiên sẽ thất bại.
Sau đó, trình điều khiển sẽ tra cứu các hàng đợi không thể chiếm trước và đặt lại chúng và
ghi lại hàng đợi nào được treo.

Về phía UMD, chúng tôi sẽ thêm USERQ QUERY_STATUS IOCTL để truy vấn hàng đợi
trạng thái.  UMD sẽ cung cấp id hàng đợi trong IOCTL và trình điều khiển kernel
sẽ kiểm tra xem nó đã ghi hàng đợi là bị treo chưa (ví dụ: do không thành công
peemption) và báo cáo lại trạng thái.

Giao diện IOCTL
================

Địa chỉ ảo GPU được sử dụng cho hàng đợi và dữ liệu liên quan (rptrs, wptrs, context
vùng lưu, v.v.) phải được xác nhận bởi trình điều khiển chế độ kernel để ngăn chặn
người dùng chỉ định địa chỉ ảo GPU không hợp lệ.  Nếu người dùng cung cấp
địa chỉ ảo GPU hoặc chỉ báo chuông cửa không hợp lệ, IOCTL sẽ trả về một
thông báo lỗi.  Những bộ đệm này cũng cần được theo dõi trong trình điều khiển hạt nhân để
rằng nếu người dùng cố gắng hủy ánh xạ (các) bộ đệm khỏi GPUVM, lệnh gọi umap
sẽ trả về một lỗi.

INFO
----
Có một số truy vấn INFO mới liên quan đến hàng đợi của người dùng để truy vấn
kích thước của dữ liệu meta hàng đợi người dùng cần thiết cho hàng đợi người dùng (ví dụ: khu vực lưu ngữ cảnh
hoặc bộ đệm bóng), cho dù hàng đợi kernel hay người dùng hay cả hai đều được hỗ trợ
cho từng loại IP và mức chênh lệch cho từng loại IP trong mỗi trang chuông cửa.

USERQ
-----
USERQ IOCTL được sử dụng để tạo, giải phóng và truy vấn trạng thái của người dùng
hàng đợi.  Nó hỗ trợ 3 opcodes:

1. CREATE - Tạo hàng đợi người dùng.  Ứng dụng này cung cấp cấu trúc giống MQD
   xác định loại hàng đợi cũng như siêu dữ liệu và cờ liên quan cho điều đó
   kiểu hàng đợi.  Trả về id hàng đợi.
2. FREE - Giải phóng hàng đợi người dùng.
3. QUERY_STATUS - Truy vấn trạng thái của hàng đợi.  Được sử dụng để kiểm tra xem hàng đợi có
   khỏe mạnh hay không.  Ví dụ: nếu hàng đợi đã được đặt lại. (WIP)

USERQ_SIGNAL
------------
USERQ_SIGNAL IOCTL được sử dụng để cung cấp danh sách các đối tượng đồng bộ sẽ được báo hiệu.

USERQ_WAIT
----------
USERQ_WAIT IOCTL được sử dụng để cung cấp danh sách đối tượng đồng bộ hóa cần chờ.

Hàng đợi hạt nhân và người dùng
======================

Để xác thực và kiểm tra hiệu suất một cách chính xác, chúng tôi có tùy chọn trình điều khiển để
chọn loại hàng đợi nào được bật (hàng đợi kernel, hàng đợi người dùng hoặc cả hai).
Tham số trình điều khiển user_queue chỉ cho phép bạn kích hoạt hàng đợi kernel (0),
hàng đợi người dùng và hàng đợi kernel (1) và chỉ hàng đợi người dùng (2).  Cho phép người dùng
chỉ hàng đợi sẽ giải phóng các bài tập hàng đợi tĩnh lẽ ra sẽ được sử dụng
bởi hàng đợi kernel để sử dụng bởi phần mềm lập lịch.  Một số hàng đợi kernel
cần thiết cho hoạt động của trình điều khiển hạt nhân và chúng sẽ luôn được tạo.  Khi
hàng đợi kernel không được kích hoạt, chúng không được đăng ký với bộ lập lịch drm
và CS IOCTL sẽ từ chối mọi lệnh gửi đến nhắm vào những lệnh đó
các loại hàng đợi.  Hàng đợi hạt nhân chỉ phản ánh hành vi trên tất cả các GPU hiện có.
Kích hoạt cả hai hàng đợi cho phép tương thích ngược với không gian người dùng cũ trong khi
vẫn hỗ trợ hàng đợi người dùng.
