.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/networking/xfrm/xfrm_proc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

=====================================
XFRM Proc - tệp /proc/net/xfrm_*
=====================================

Masahide NAKAMURA <nakam@linux-ipv6.org>


Thống kê chuyển đổi
-------------------------

Mã xfrm_proc là một tập hợp số liệu thống kê hiển thị số lượng gói
bị bỏ qua mã chuyển đổi và tại sao.  Các bộ đếm này được xác định
như một phần của MIB riêng tư của Linux.  Những bộ đếm này có thể được xem trong
/proc/net/xfrm_stat.


Lỗi gửi đến
~~~~~~~~~~~~~~

XfrmInError:
	Tất cả các lỗi không khớp với các lỗi khác

XfrmInBufferLỗi:
	Không còn bộ đệm

XfrmInHdrLỗi:
	Lỗi tiêu đề

XfrmInNoStates:
	Không tìm thấy trạng thái nào
	tức là giao thức SPI, địa chỉ hoặc IPsec gửi đến tại SA đều sai

XfrmInStateProtoError:
	Lỗi cụ thể của giao thức chuyển đổi
	ví dụ: Phím SA bị sai

XfrmInStateModeError:
	Lỗi cụ thể của chế độ chuyển đổi

XfrmInStateSeqError:
	Lỗi trình tự
	tức là số thứ tự nằm ngoài cửa sổ

XfrmInStateĐã hết hạn:
	Trạng thái đã hết hạn

XfrmInStateKhông khớp:
	Bang có tùy chọn không khớp
	ví dụ: Kiểu đóng gói UDP không khớp

XfrmInStateKhông hợp lệ:
	Tiểu bang không hợp lệ

XfrmInTmplKhông khớp:
	Không có mẫu phù hợp cho các tiểu bang
	ví dụ: SA gửi đến đúng nhưng quy tắc SP sai

XfrmInNoPols:
	Không tìm thấy chính sách nào cho các tiểu bang
	ví dụ: SA gửi đến là chính xác nhưng không tìm thấy SP

XfrmInPolBlock:
	Chính sách loại bỏ

XfrmInPolLỗi:
	Lỗi chính sách

XfrmAcquireLỗi:
	Trạng thái chưa được thu thập đầy đủ trước khi sử dụng

XfrmFwdHdrLỗi:
	Không cho phép định tuyến chuyển tiếp gói tin

XfrmInStateDirError:
        Hướng trạng thái không khớp (tra cứu tìm thấy trạng thái đầu ra trên đường dẫn đầu vào, đầu vào dự kiến hoặc không có hướng)

Lỗi gửi đi
~~~~~~~~~~~~~~~
XfrmOutLỗi:
	Tất cả các lỗi không khớp với các lỗi khác

XfrmOutBundleGenError:
	Lỗi tạo gói

XfrmOutBundleCheckError:
	Lỗi kiểm tra gói

XfrmOutNoStates:
	Không tìm thấy trạng thái nào

XfrmOutStateProtoError:
	Lỗi cụ thể của giao thức chuyển đổi

XfrmOutStateModeError:
	Lỗi cụ thể của chế độ chuyển đổi

XfrmOutStateSeqError:
	Lỗi trình tự
	tức là tràn số thứ tự

XfrmOutStateĐã hết hạn:
	Trạng thái đã hết hạn

XfrmOutPolBlock:
	Chính sách loại bỏ

XfrmOutPolChết:
	Chính sách đã chết

XfrmOutPolLỗi:
	Lỗi chính sách

XfrmOutStateKhông hợp lệ:
	Trạng thái không hợp lệ, có thể đã hết hạn

XfrmOutStateDirError:
        Hướng trạng thái không khớp (tra cứu tìm thấy trạng thái đầu vào trên đường dẫn đầu ra, đầu ra dự kiến hoặc không có hướng)