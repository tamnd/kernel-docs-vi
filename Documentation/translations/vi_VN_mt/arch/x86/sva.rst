.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/x86/sva.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===============================================
Địa chỉ ảo được chia sẻ (SVA) với ENQCMD
===============================================

Lý lịch
==========

Địa chỉ ảo được chia sẻ (SVA) cho phép bộ xử lý và thiết bị sử dụng
cùng một địa chỉ ảo tránh cần dùng phần mềm dịch ảo
địa chỉ thành địa chỉ vật lý. SVA được PCIe gọi là Shared Virtual
Bộ nhớ (SVM).

Ngoài sự tiện lợi của việc sử dụng địa chỉ ảo ứng dụng
bởi thiết bị, nó cũng không yêu cầu ghim trang cho DMA.
Dịch vụ dịch địa chỉ PCIe (ATS) cùng với Giao diện yêu cầu trang
(PRI) cho phép các thiết bị hoạt động giống như cách xử lý CPU
lỗi trang ứng dụng. Để biết thêm thông tin, vui lòng tham khảo PCIe
đặc điểm kỹ thuật Chương 10: Đặc điểm kỹ thuật ATS.

Việc sử dụng SVA cần có sự hỗ trợ của IOMMU trong nền tảng. IOMMU cũng vậy
cần thiết để hỗ trợ các tính năng PCIe ATS và PRI. ATS cho phép các thiết bị
để lưu vào bộ nhớ đệm các bản dịch cho các địa chỉ ảo. Trình điều khiển IOMMU sử dụng
hỗ trợ mmu_notifier() để giữ bộ đệm TLB của thiết bị và bộ đệm CPU ở
đồng bộ hóa. Khi tra cứu ATS không thành công đối với địa chỉ ảo, thiết bị sẽ
sử dụng PRI để yêu cầu địa chỉ ảo được phân trang vào
Bảng trang CPU. Thiết bị phải sử dụng lại ATS để tìm nạp
dịch trước khi sử dụng.

Hàng công việc phần cứng được chia sẻ
==========================

Không giống như Ảo hóa I/O gốc đơn (SR-IOV), giấy phép IOV (SIOV) có thể mở rộng
việc sử dụng Hàng đợi công việc chung (SWQ) của cả ứng dụng và Virtual
Máy (VM). Điều này cho phép sử dụng phần cứng tốt hơn so với phần cứng
phân vùng các tài nguyên có thể dẫn đến việc sử dụng dưới mức. để
cho phép phần cứng phân biệt bối cảnh của công việc đang được thực hiện
được thực thi trong phần cứng bằng giao diện SWQ, SIOV sử dụng Không gian địa chỉ quy trình
ID (PASID), là số 20 bit được xác định bởi PCIe SIG.

Giá trị PASID được mã hóa trong tất cả các giao dịch từ thiết bị. Điều này cho phép
IOMMU để theo dõi I/O ở mức độ chi tiết trên mỗi PASID ngoài việc sử dụng PCIe
Mã định danh tài nguyên (RID) là Bus/Thiết bị/Chức năng.


ENQCMD
======

ENQCMD là một hướng dẫn mới trên nền tảng Intel gửi một cách nguyên tử
mô tả công việc cho một thiết bị. Bộ mô tả bao gồm các hoạt động được
được thực hiện, địa chỉ ảo của tất cả các tham số, địa chỉ ảo của lần hoàn thành
bản ghi và PASID (ID không gian địa chỉ quy trình) của quy trình hiện tại.

ENQCMD hoạt động với ngữ nghĩa không được đăng và mang lại trạng thái nếu
lệnh đã được chấp nhận bởi phần cứng. Điều này cho phép người gửi biết liệu
việc gửi cần phải được thử lại hoặc các cơ chế cụ thể khác của thiết bị để
thực hiện sự công bằng hoặc đảm bảo tiến độ tiến bộ cần được cung cấp.

ENQCMD là chất keo đảm bảo các ứng dụng có thể gửi lệnh trực tiếp
cho phần cứng và cũng cho phép phần cứng nhận biết được bối cảnh ứng dụng
để thực hiện các thao tác I/O thông qua việc sử dụng PASID.

Gắn thẻ không gian địa chỉ quy trình
=============================

MSR trong phạm vi luồng mới (IA32_PASID) cung cấp kết nối giữa
quy trình người dùng và phần còn lại của phần cứng. Khi một ứng dụng đầu tiên
truy cập vào một thiết bị có khả năng SVA, MSR này được khởi tạo với một
được phân bổ PASID. Trình điều khiển cho thiết bị gọi API dành riêng cho IOMMU
thiết lập định tuyến cho DMA và các yêu cầu trang.

Ví dụ: Bộ tăng tốc truyền dữ liệu Intel (DSA) sử dụng
iommu_sva_bind_device(), sẽ thực hiện những việc sau:

- Phân bổ PASID và lập trình bảng trang quy trình (thanh ghi%cr3) trong
  Mục nhập ngữ cảnh PASID.
- Đăng ký mmu_notifier() để theo dõi bất kỳ sự vô hiệu hóa nào của bảng trang cần lưu giữ
  thiết bị TLB được đồng bộ hóa. Ví dụ: khi một mục trong bảng trang bị vô hiệu,
  IOMMU truyền thông tin vô hiệu đến thiết bị TLB. Điều này sẽ buộc bất kỳ
  thiết bị có quyền truy cập trong tương lai vào địa chỉ ảo này để tham gia vào
  ATS. Nếu IOMMU phản hồi đúng thì trang đó không được
  hiện tại, thiết bị sẽ yêu cầu phân trang trang thông qua PCIe PRI
  giao thức trước khi thực hiện I/O.

MSR này được quản lý với tính năng XSAVE được đặt làm "trạng thái giám sát" thành
đảm bảo MSR được cập nhật trong quá trình chuyển đổi ngữ cảnh.

Quản lý PASID
================

Hạt nhân phải phân bổ PASID thay mặt cho mỗi quy trình sẽ sử dụng
ENQCMD và lập trình nó vào MSR mới để truyền đạt nhận dạng quy trình tới
phần cứng nền tảng.  ENQCMD sử dụng PASID được lưu trữ trong MSR này để gắn thẻ các yêu cầu
từ quá trình này.  Khi người dùng gửi mô tả công việc tới một thiết bị bằng cách sử dụng
Lệnh ENQCMD, trường PASID trong bộ mô tả được tự động điền bằng
giá trị từ MSR_IA32_PASID. Yêu cầu DMA từ thiết bị cũng được gắn thẻ
với cùng PASID. Nền tảng IOMMU sử dụng PASID trong giao dịch để
thực hiện dịch địa chỉ. API IOMMU thiết lập PASID tương ứng
mục nhập trong IOMMU với địa chỉ quy trình được CPU sử dụng (ví dụ: đăng ký %cr3 trong
x86).

MSR phải được cấu hình trên mỗi CPU logic trước bất kỳ ứng dụng nào
thread có thể tương tác với một thiết bị. Các chủ đề thuộc cùng một chủ đề
quá trình chia sẻ cùng một bảng trang, do đó có cùng giá trị MSR.

Quản lý vòng đời PASID
===========================

PASID được khởi tạo là IOMMU_PASID_INVALID (-1) khi một quy trình được tạo.

Chỉ các quy trình truy cập các thiết bị có khả năng SVA mới cần có PASID
được phân bổ. Sự phân bổ này xảy ra khi một quá trình mở/liên kết một SVA có khả năng
thiết bị nhưng không tìm thấy PASID cho quá trình này. Các liên kết tiếp theo giống nhau, hoặc
các thiết bị khác sẽ dùng chung PASID.

Mặc dù PASID được phân bổ cho quy trình bằng cách mở một thiết bị,
nó không hoạt động trong bất kỳ luồng nào của quá trình đó. Nó được tải vào
IA32_PASID MSR lười biếng khi một chủ đề cố gắng gửi một bộ mô tả công việc
tới thiết bị sử dụng ENQCMD.

Lần truy cập đầu tiên đó sẽ gây ra lỗi #GP vì IA32_PASID MSR
chưa được khởi tạo với giá trị PASID được gán cho quy trình
khi thiết bị được mở. Trình xử lý #GP của Linux lưu ý rằng PASID có
được phân bổ cho quá trình và do đó khởi tạo IA32_PASID MSR
và trả về để lệnh ENQCMD được thực hiện lại.

Trên fork(2) hoặc exec(2), PASID bị xóa khỏi quy trình vì nó không
còn có cùng không gian địa chỉ như khi thiết bị được mở.

Trên bản sao (2), tác vụ mới chia sẻ cùng một không gian địa chỉ, do đó sẽ
có thể sử dụng PASID được phân bổ cho quy trình. IA32_PASID thì không
được khởi tạo trước vì giá trị PASID có thể chưa được phân bổ hoặc
kernel không biết liệu luồng này có truy cập vào thiết bị hay không
và IA32_PASID MSR đã xóa giúp giảm chi phí chuyển đổi ngữ cảnh bằng xstate
tối ưu hóa ban đầu. Vì các lỗi #GP phải được xử lý trên bất kỳ luồng nào
được tạo trước khi PASID được gán cho mm của quy trình, mới
các chủ đề đã tạo cũng có thể được xử lý một cách nhất quán.

Do sự phức tạp của việc giải phóng PASID và xóa tất cả các MSR IA32_PASID trong
tất cả các chủ đề được hủy liên kết, chỉ giải phóng PASID một cách lười biếng khi thoát mm.

Nếu một quá trình thực hiện đóng (2) bộ mô tả tệp thiết bị và munmap (2)
của cổng MMIO của thiết bị, sau đó trình điều khiển sẽ hủy liên kết thiết bị. các
PASID vẫn được đánh dấu VALID trong PASID_MSR cho bất kỳ chủ đề nào trong
quá trình đã truy cập vào thiết bị. Nhưng điều này vô hại vì không có
Cổng thông tin MMIO họ không thể gửi tác phẩm mới tới thiết bị.

Mối quan hệ
=============

* Mỗi tiến trình có nhiều luồng nhưng chỉ có một PASID.
 * Các thiết bị có số lượng hàng đợi công việc phần cứng giới hạn (~10 đến 1000).
   Trình điều khiển thiết bị quản lý việc phân bổ hàng đợi công việc phần cứng.
 * Một mmap() ánh xạ một hàng công việc phần cứng duy nhất dưới dạng "cổng thông tin" và
   mỗi cổng ánh xạ xuống một hàng công việc duy nhất.
 * Đối với mỗi thiết bị mà một tiến trình tương tác với nó, phải có
   một hoặc nhiều cổng mmap()'d.
 * Nhiều luồng trong một quy trình có thể chia sẻ một cổng thông tin duy nhất để truy cập
   một thiết bị duy nhất.
 * Nhiều quy trình có thể mmap() riêng biệt trên cùng một cổng, trong
   trong trường hợp đó họ vẫn chia sẻ một chuỗi công việc phần cứng của thiết bị.
 * PASID toàn quy trình được tất cả các luồng sử dụng để tương tác
   với tất cả các thiết bị.  Chẳng hạn, không có PASID cho mỗi
   luồng hoặc từng luồng <-> cặp thiết bị.

FAQ
===

* SVA/SVM là gì?

Địa chỉ ảo được chia sẻ (SVA) cho phép phần cứng I/O và bộ xử lý
làm việc trong cùng một không gian địa chỉ, tức là để chia sẻ nó. Một số người gọi nó là Chia sẻ
Bộ nhớ ảo (SVM), nhưng cộng đồng Linux muốn tránh nhầm lẫn nó với
Bộ nhớ chia sẻ POSIX và Máy ảo an toàn đã có sẵn trong
tuần hoàn.

* PASID là gì?

ID không gian địa chỉ quy trình (PASID) là Gói lớp giao dịch được xác định bởi PCIe
(TLP) tiền tố. PASID là số 20 bit được hệ điều hành phân bổ và quản lý.
PASID được bao gồm trong tất cả các giao dịch giữa nền tảng và thiết bị.

* Hàng đợi công việc được chia sẻ khác nhau như thế nào?

Theo truyền thống, để các ứng dụng không gian người dùng tương tác với phần cứng,
có một phiên bản phần cứng riêng biệt được yêu cầu cho mỗi quy trình. Ví dụ,
coi chuông cửa như một cơ chế thông báo cho phần cứng về công việc cần xử lý.
Mỗi chuông cửa phải cách nhau 4k (hoặc kích thước trang) để xử lý
sự cô lập. Điều này đòi hỏi phần cứng phải cung cấp không gian đó và dự trữ nó trong
MMIO. Điều này không mở rộng vì số lượng chủ đề trở nên khá lớn. các
phần cứng cũng quản lý độ sâu hàng đợi cho Hàng đợi công việc được chia sẻ (SWQ) và
người tiêu dùng không cần theo dõi độ sâu của hàng đợi. Nếu không có chỗ để chấp nhận
một lệnh, thiết bị sẽ trả về lỗi cho biết thử lại.

Người dùng nên kiểm tra khả năng Ghi bộ nhớ trì hoãn (DMWr) trên thiết bị
và chỉ gửi ENQCMD khi thiết bị hỗ trợ. Trong DMWr PCIe mới
thuật ngữ, thiết bị cần hỗ trợ khả năng hoàn thiện DMWr. Ngoài ra,
nó yêu cầu tất cả các cổng chuyển mạch hỗ trợ định tuyến DMWr và phải được kích hoạt bởi
hệ thống con PCIe, giống như cách quản lý các hoạt động nguyên tử của PCIe cho
ví dụ.

SWQ cho phép phần cứng chỉ cung cấp một địa chỉ duy nhất trong thiết bị. Khi nào
được sử dụng với ENQCMD để gửi tác phẩm, thiết bị có thể phân biệt quy trình
gửi tác phẩm vì nó sẽ bao gồm PASID được gán cho tác phẩm đó
quá trình. Điều này giúp thiết bị có thể mở rộng quy mô cho một số lượng lớn quy trình.

* Điều này có giống với trình điều khiển thiết bị không gian người dùng không?

Giao tiếp với thiết bị thông qua hàng làm việc được chia sẻ đơn giản hơn nhiều
hơn là một trình điều khiển không gian người dùng đầy đủ. Trình điều khiển kernel thực hiện tất cả
khởi tạo phần cứng. Không gian người dùng chỉ cần lo lắng về
gửi công việc và xử lý hoàn tất.

* Cái này có giống với SR-IOV không?

Ảo hóa I/O gốc đơn (SR-IOV) tập trung vào việc cung cấp độc lập
giao diện phần cứng để ảo hóa phần cứng. Do đó, bắt buộc phải có
một giao diện gần như đầy đủ chức năng cho phần mềm hỗ trợ truyền thống
BAR, không gian cho các ngắt thông qua MSI-X, bố cục thanh ghi riêng.
Chức năng ảo (VF) được hỗ trợ bởi Chức năng vật lý (PF)
người lái xe.

Ảo hóa I/O có thể mở rộng được xây dựng trên khái niệm PASID để tạo ra thiết bị
trường hợp cho ảo hóa. SIOV yêu cầu phần mềm máy chủ hỗ trợ
tạo thiết bị ảo; mỗi thiết bị ảo được đại diện bởi một PASID
cùng với bus/thiết bị/chức năng của thiết bị.  Điều này cho phép thiết bị
phần cứng để tối ưu hóa việc tạo tài nguyên thiết bị và có thể phát triển linh hoạt trên
nhu cầu. Việc tạo và quản lý SR-IOV có bản chất rất tĩnh. tư vấn
tài liệu tham khảo dưới đây để biết thêm chi tiết.

* Tại sao không tạo một chức năng ảo cho từng ứng dụng?

Việc tạo các Chức năng ảo (VF) loại PCIe SR-IOV rất tốn kém. VF yêu cầu
phần cứng trùng lặp cho không gian cấu hình PCI và các ngắt như MSI-X.
Các tài nguyên như ngắt phải được phân chia cứng giữa các VF tại
thời gian tạo và không thể mở rộng quy mô linh hoạt theo yêu cầu. Các VF không
hoàn toàn độc lập với Chức năng vật lý (PF). Hầu hết các VF đều yêu cầu
một số thông tin liên lạc và hỗ trợ từ trình điều khiển PF. Ngược lại, SIOV,
tạo ra một thiết bị được xác định bằng phần mềm trong đó tất cả cấu hình và điều khiển
các khía cạnh được trung gian thông qua con đường chậm. Việc nộp và hoàn thành công việc
xảy ra mà không cần bất kỳ sự trung gian nào.

* Điều này có hỗ trợ ảo hóa không?

ENQCMD có thể được sử dụng từ bên trong VM khách. Trong những trường hợp này, VMM sẽ giúp
với việc lập bảng dịch để dịch từ Guest PASID sang Host
PASID. Vui lòng tham khảo tài liệu tham khảo tập lệnh ENQCMD để biết thêm
chi tiết.

* Bộ nhớ có cần được ghim không?

Khi thiết bị hỗ trợ SVA cùng với phần cứng nền tảng như IOMMU
hỗ trợ các thiết bị như vậy, không cần phải ghim bộ nhớ cho mục đích DMA.
Các thiết bị hỗ trợ SVA cũng hỗ trợ các tính năng PCIe khác giúp loại bỏ
yêu cầu ghim cho bộ nhớ.

Hỗ trợ thiết bị TLB - Thiết bị yêu cầu IOMMU tra cứu địa chỉ trước đó
sử dụng thông qua các yêu cầu Dịch vụ dịch địa chỉ (ATS).  Nếu bản đồ tồn tại
nhưng không có trang nào được hệ điều hành phân bổ, phần cứng IOMMU trả về rằng không có trang nào
bản đồ tồn tại.

Thiết bị yêu cầu ánh xạ địa chỉ ảo thông qua Yêu cầu trang
Giao diện (PRI). Khi hệ điều hành đã hoàn thành việc ánh xạ thành công, nó
trả lại phản hồi cho thiết bị. Thiết bị lại yêu cầu
một bản dịch và tiếp tục.

IOMMU hoạt động với HĐH trong việc quản lý tính nhất quán của bảng trang với
thiết bị. Khi xóa trang, nó sẽ tương tác với thiết bị để xóa mọi trang
mục TLB của thiết bị có thể đã được lưu vào bộ nhớ đệm trước khi xóa ánh xạ khỏi
hệ điều hành.

Tài liệu tham khảo
==========

VT-D:
ZZ0000ZZ

SIOV:
ZZ0000ZZ

ENQCMD trong ISE:
ZZ0000ZZ

Thông số DSA:
ZZ0000ZZ