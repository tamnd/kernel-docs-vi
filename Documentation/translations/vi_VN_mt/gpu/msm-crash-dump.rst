.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/msm-crash-dump.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

:mồ côi:

=======================
Định dạng kết xuất sự cố MSM
=====================

Sau khi treo GPU, trình điều khiển MSM xuất thông tin gỡ lỗi qua
/sys/kernel/dri/X/show hoặc thông qua devcoredump (/sys/class/devcoredump/dcdX/data).
Tài liệu này mô tả cách định dạng đầu ra.

Mỗi mục có dạng key: value. Tiêu đề của phần sẽ không có giá trị
và tất cả nội dung của một phần sẽ được thụt vào hai khoảng trắng so với tiêu đề.
Mỗi phần có thể có nhiều mục mảng mà phần đầu được chỉ định
bởi một (-).

Ánh xạ
--------

hạt nhân
	Phiên bản kernel đã tạo kết xuất (UTS_RELEASE).

mô-đun
	Mô-đun đã tạo ra kết xuất sự cố.

thời gian
	Thời gian kernel gặp sự cố được định dạng là giây.micro giây.

liên lạc
	Chuỗi com cho mã nhị phân đã tạo ra lỗi.

dòng lệnh
	Dòng lệnh cho mã nhị phân tạo ra lỗi.

sửa đổi
	ID của GPU đã tạo ra sự cố có định dạng là
	core.major.minor.patchlevel được phân tách bằng dấu chấm.

trạng thái rbbm
	Giá trị hiện tại của RBBM_STATUS cho biết GPU cấp cao nhất là bao nhiêu
	các thành phần đang được sử dụng tại thời điểm xảy ra sự cố.

bộ đệm chuông
	Phần chứa nội dung của mỗi bộ đệm chuông. Mỗi bộ đệm chuông là
	được xác định bằng số id.

danh tính
		ID bộ đệm chuông (chỉ số dựa trên 0).  Mỗi bộ đệm chuông trong phần
		sẽ có id duy nhất của riêng mình.
	iova
		Địa chỉ GPU của bộ đệm chuông.

hàng rào cuối cùng
		Hàng rào cuối cùng được phát hành trên bộ đệm chuông

hàng rào đã nghỉ hưu
		Hàng rào cuối cùng đã nghỉ hưu trên bộ đệm chuông.

rptr
		Con trỏ đọc hiện tại (rptr) cho bộ đệm chuông.

wptr
		Con trỏ ghi hiện tại (wptr) cho bộ đệm chuông.

kích thước
		Kích thước tối đa của bộ đệm chuông được lập trình trong phần cứng.

dữ liệu
		Nội dung của vòng được mã hóa dưới dạng ascii85.  Chỉ có đồ đã qua sử dụng
		các phần của chiếc nhẫn sẽ được in.

bo
	Danh sách các bộ đệm từ bài nộp bị treo nếu có.
	Mỗi đối tượng đệm sẽ có một iova uinque.

iova
		Địa chỉ GPU của đối tượng bộ đệm.

kích thước
		Kích thước được phân bổ của đối tượng đệm.

dữ liệu
		Nội dung của đối tượng đệm được mã hóa bằng ascii85.  Chỉ
		Các số 0 ở cuối bộ đệm sẽ bị bỏ qua.

sổ đăng ký
	Tập hợp các giá trị đăng ký. Mỗi mục nằm trên một dòng riêng kèm theo
	bằng dấu ngoặc { }.

bù đắp
		Độ lệch byte của thanh ghi kể từ đầu
		Vùng bộ nhớ GPU.

giá trị
		Giá trị thập lục phân của thanh ghi.

đăng ký-hlsql
		(chỉ 5xx) Đăng ký giá trị từ khẩu độ HLSQ.
		Định dạng tương tự như phần đăng ký.
