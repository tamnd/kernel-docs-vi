.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/msm-preemption.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

:mồ côi:

================
Ưu tiên MSM
==============

Quyền ưu tiên cho phép GPU Adreno chuyển sang vòng ưu tiên cao hơn khi công việc kết thúc.
được đẩy tới đó, giảm độ trễ cho các nội dung gửi có mức độ ưu tiên cao.

Khi bật quyền ưu tiên, 4 vòng được khởi tạo, tương ứng với các vòng khác nhau
các mức độ ưu tiên. Có nhiều vòng hoàn toàn là một khái niệm phần mềm như GPU
chỉ có các thanh ghi để theo dõi một vòng đồ họa.
Hạt nhân có thể chuyển đổi vòng nào hiện đang được xử lý bởi
yêu cầu ưu tiên. Khi đáp ứng được một số điều kiện nhất định, tùy thuộc vào
mức độ ưu tiên, GPU sẽ lưu trạng thái hiện tại của nó vào một loạt bộ đệm,
sau đó khôi phục trạng thái từ một bộ đệm tương tự được chỉ định bởi kernel. Nó
sau đó tiếp tục thực thi và kích hoạt IRQ để cho kernel biết ngữ cảnh
công tắc đã hoàn tất.

Cơ chế này có thể được kernel sử dụng để chuyển đổi giữa các vòng. Bất cứ khi nào một
quá trình gửi xảy ra, kernel tìm thấy vòng ưu tiên cao nhất không trống
và ưu tiên thực hiện nếu vòng nói trên không phải là vòng hiện đang được thực thi. Đây là
cũng được thực hiện bất cứ khi nào quá trình gửi hoàn tất để đảm bảo quá trình thực thi được tiếp tục trên
vòng ưu tiên thấp hơn khi vòng ưu tiên cao hơn được thực hiện.

Mức độ ưu tiên
-----------------

Quyền ưu tiên chỉ có thể xảy ra ở một số ranh giới nhất định. Các điều kiện chính xác có thể
được cấu hình bằng cách thay đổi mức độ ưu tiên, điều này cho phép thỏa hiệp giữa
độ trễ (tức là thời gian trôi qua giữa thời điểm hạt nhân yêu cầu quyền ưu tiên
và khi SQE bắt đầu lưu trạng thái) và chi phí chung (lượng trạng thái
cần được lưu lại).

GPU cung cấp 3 cấp độ:

Cấp 0
  Quyền ưu tiên chỉ xảy ra ở cấp độ nộp hồ sơ. Điều này đòi hỏi số tiền ít nhất
  trạng thái sẽ được lưu khi việc thực thi các IB được gửi qua không gian người dùng không bao giờ
  bị gián đoạn, tuy nhiên nó mang lại rất ít lợi ích so với việc không kích hoạt
  quyền ưu tiên dưới bất kỳ hình thức nào.

Cấp 1
  Quyền ưu tiên xảy ra ở cấp độ bin, nếu sử dụng kết xuất GMEM hoặc cấp độ vẽ
  trong trường hợp kết xuất hệ thống.

Cấp 2
  Quyền ưu tiên xảy ra ở cấp độ hòa.

Cấp 1 là chế độ được sử dụng bởi trình điều khiển msm.

Ngoài ra, GPU cho phép chỉ định tùy chọn ZZ0000ZZ. Cái này
vô hiệu hóa việc lưu và khôi phục tất cả các thanh ghi ngoại trừ những thanh ghi liên quan đến
hoạt động của chính SQE, giảm chi phí. Việc lưu và khôi phục chỉ
bị bỏ qua khi sử dụng GMEM với quyền ưu tiên Cấp 1. Khi kích hoạt không gian người dùng này là
dự kiến sẽ thiết lập trạng thái không được bảo toàn bất cứ khi nào xảy ra quyền ưu tiên
được thực hiện bằng cách chỉ định lời mở đầu và lời mở đầu. Đó là những IB được thực thi
trước và sau quyền ưu tiên.

Bộ đệm ưu tiên
------------------

Cần có một loạt bộ đệm để lưu trữ trạng thái của các vòng khi chúng không hoạt động.
đang bị xử tử. Có nhiều loại hồ sơ ưu tiên khác nhau và hầu hết
những yêu cầu một bộ đệm cho mỗi vòng. Điều này là do quyền ưu tiên không bao giờ xảy ra
giữa các lần gửi trên cùng một vòng, luôn chạy theo trình tự khi vòng
đang hoạt động. Điều này có nghĩa là chỉ có một bối cảnh trên mỗi vòng hoạt động hiệu quả.

SMMU_INFO
  Bộ đệm này chứa thông tin về cấu hình SMMU hiện tại chẳng hạn như
  đăng ký ttbr0. Phần sụn SQE thực sự không thể lưu bản ghi này.
  Kết quả là thông tin SMMU phải được lưu thủ công từ CP vào bộ đệm và
  Bản ghi SMMU được cập nhật với thông tin từ bộ đệm đã nói trước khi kích hoạt
  quyền ưu tiên.

NON_SECURE
  Đây là bản ghi ưu tiên chính nơi hầu hết trạng thái được lưu. Nó chủ yếu là
  mờ đối với kernel ngoại trừ một vài từ đầu tiên phải được khởi tạo
  bởi hạt nhân.

SECURE
  Thao tác này sẽ lưu trạng thái liên quan đến chế độ bảo mật của GPU.

NON_PRIV
  Mục đích dự định của hồ sơ này là không rõ. Thực tế thì phần sụn SQE
  bỏ qua nó và do đó msm không xử lý nó.

COUNTER
  Bản ghi này được sử dụng để lưu và khôi phục bộ đếm hiệu suất.

Việc xử lý các quyền của các vùng đệm đó là rất quan trọng để bảo mật. Tất cả trừ
Bản ghi NON_PRIV cần không thể truy cập được từ không gian người dùng, vì vậy chúng phải được ánh xạ
trong không gian địa chỉ kernel với cờ MSM_BO_MAP_PRIV.
Ví dụ: làm cho bản ghi NON_SECURE có thể truy cập được từ không gian người dùng sẽ cho phép
bất kỳ quy trình nào để thao tác RPTR của vòng đã lưu có thể được sử dụng để bỏ qua
thực hiện một số gói trong vòng và thực thi các lệnh của người dùng với tốc độ cao hơn
đặc quyền.