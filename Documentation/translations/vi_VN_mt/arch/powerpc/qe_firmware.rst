.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/powerpc/qe_firmware.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Tải lên chương trình cơ sở công cụ QUICC Freescale
==================================================

(c) 2007 Timur Tabi <timur tại freescale.com>,
    Chất bán dẫn Freescale

.. Table of Contents

   I - Software License for Firmware

   II - Microcode Availability

   III - Description and Terminology

   IV - Microcode Programming Details

   V - Firmware Structure Layout

   VI - Sample Code for Creating Firmware Files

Thông tin sửa đổi
====================

30/11/2007: Rev 1.0 - Phiên bản đầu tiên

I - Giấy phép phần mềm cho Firmware
=================================

Mỗi tập tin phần sụn đi kèm với giấy phép phần mềm riêng.  Để biết thông tin về
giấy phép cụ thể, vui lòng xem văn bản giấy phép được phân phối cùng với
phần sụn.

II - Tính khả dụng của vi mã
===========================

Các tập tin phần sụn được phân phối qua nhiều kênh khác nhau.  Một số có sẵn trên
ZZ0000ZZ Để biết các file firmware khác, vui lòng liên hệ
đại diện Freescale hoặc nhà cung cấp hệ điều hành của bạn.

III - Mô tả và thuật ngữ
=================================

Trong tài liệu này, thuật ngữ 'microcode' đề cập đến chuỗi 32-bit
các số nguyên tạo nên vi mã QE thực tế.

Thuật ngữ 'chương trình cơ sở' dùng để chỉ một đốm màu nhị phân chứa vi mã dưới dạng
cũng như các dữ liệu khác

1) mô tả mục đích của vi mã
	2) mô tả cách thức và vị trí tải vi mã lên
	3) chỉ định giá trị của các thanh ghi khác nhau
	4) bao gồm dữ liệu bổ sung để trình điều khiển thiết bị cụ thể sử dụng

Tệp phần sụn là tệp nhị phân chỉ chứa phần sụn.

IV - Chi tiết lập trình vi mã
===================================

Kiến trúc QE chỉ cho phép một vi mã có trong I-RAM cho mỗi vi mã
Bộ xử lý RISC.  Để thay thế bất kỳ vi mã hiện tại nào, hãy thiết lập lại QE đầy đủ (điều này
tắt vi mã) phải được thực hiện trước tiên.

Mã vi QE được tải lên bằng quy trình sau:

1) Vi mã được đặt vào I-RAM tại một vị trí cụ thể, sử dụng
   Các thanh ghi IRAM.IADD và IRAM.IDATA.

2) Bit CERCR.CIR được đặt thành 0 hoặc 1, tùy thuộc vào việc phần sụn
   cần chia I-RAM.  Việc phân chia I-RAM chỉ có ý nghĩa đối với các SOC có
   QE có nhiều bộ xử lý RISC, chẳng hạn như 8360. Tách I-RAM
   cho phép mỗi bộ xử lý chạy một vi mã khác nhau, tạo ra một cách hiệu quả
   hệ thống đa xử lý bất đối xứng (AMP).

3) Các thanh ghi bẫy TIBCR được tải địa chỉ của trình xử lý bẫy
   trong vi mã.

4) Thanh ghi RSP.ECCR được lập trình với giá trị được cung cấp.

5) Nếu cần, trình điều khiển thiết bị cần bẫy ảo và chế độ mở rộng
   dữ liệu sẽ sử dụng chúng.

Bẫy vi mã ảo

Những bẫy ảo này là các nhánh có điều kiện trong vi mã.  Đây là
"mềm" tạm thời được giới thiệu trong ROMcode để kích hoạt tính năng cao hơn
linh hoạt và tiết kiệm bẫy h/w Nếu các tính năng mới được kích hoạt hoặc có vấn đề xảy ra
đang được sửa trong gói RAM bằng cách sử dụng chúng nên được kích hoạt.  Dữ liệu này
Cấu trúc báo hiệu cho vi mã biết bẫy ảo nào đang hoạt động.

Cấu trúc này chứa 6 từ mà ứng dụng nên sao chép vào một số
cụ thể đã được xác định.  Bảng này mô tả cấu trúc::

---------------------------------------------------------------
	ZZ0000ZZ ZZ0001ZZ Kích thước của |
	ZZ0002ZZ Giao thức ZZ0003ZZ Toán hạng |
	--------------------------------------------------------------|
	ZZ0004ZZ Ethernet ZZ0005ZZ 4 byte |
	ZZ0006ZZ tương tác ZZ0007ZZ |
	---------------------------------------------------------------
	ZZ0008ZZ ATM ZZ0009ZZ 4 byte |
	ZZ0010ZZ tương tác ZZ0011ZZ |
	---------------------------------------------------------------
	ZZ0012ZZ PPP ZZ0013ZZ 4 byte |
	ZZ0014ZZ tương tác ZZ0015ZZ |
	---------------------------------------------------------------
	ZZ0016ZZ Ethernet RX ZZ0017ZZ 1 byte |
	Trang nhà phân phối ZZ0018ZZ ZZ0019ZZ |
	---------------------------------------------------------------
	ZZ0020ZZ ATM Toàn cầu ZZ0021ZZ 1 byte |
	Bảng thông số ZZ0022ZZ ZZ0023ZZ |
	---------------------------------------------------------------
	ZZ0024ZZ Khung chèn ZZ0025ZZ 4 byte |
	---------------------------------------------------------------


Chế độ mở rộng

Đây là mảng bit từ kép (64 bit) xác định chức năng đặc biệt
có ảnh hưởng đến trình điều khiển phần mềm.  Mỗi bit đều có tác động riêng
và có hướng dẫn đặc biệt cho s/w liên quan đến nó.  Cấu trúc này là
được mô tả trong bảng này::

-----------------------------------------------------------------------
	ZZ0000ZZ Tên ZZ0001ZZ
	-----------------------------------------------------------------------
	ZZ0002ZZ Tổng hợp ZZ0003ZZ
	Lệnh đẩy ZZ0004ZZ ZZ0005ZZ
	ZZ0006ZZ ZZ0007ZZ
	ZZ0008ZZ ZZ0009ZZ
	ZZ0010ZZ ZZ0011ZZ
	-----------------------------------------------------------------------
	ZZ0012ZZ UCC ATM ZZ0013ZZ
	ZZ0014ZZ RX INIT ZZ0015ZZ
	Lệnh đẩy ZZ0016ZZ ZZ0017ZZ
	ZZ0018ZZ ZZ0019ZZ
	ZZ0020ZZ ZZ0021ZZ
	ZZ0022ZZ ZZ0023ZZ
	ZZ0024ZZ ZZ0025ZZ
	ZZ0026ZZ ZZ0027ZZ
	ZZ0028ZZ ZZ0029ZZ
	-----------------------------------------------------------------------
	ZZ0030ZZ Thêm/xóa ZZ0031ZZ
	Lệnh ZZ0032ZZ ZZ0033ZZ
	Xác thực ZZ0034ZZ ZZ0035ZZ
	ZZ0036ZZ ZZ0037ZZ
	ZZ0038ZZ ZZ0039ZZ
	ZZ0040ZZ ZZ0041ZZ
	-----------------------------------------------------------------------
	ZZ0042ZZ Đẩy chung ZZ0043ZZ
	Lệnh ZZ0044ZZ ZZ0045ZZ
	ZZ0046ZZ ZZ0047ZZ
	ZZ0048ZZ ZZ0049ZZ
	ZZ0050ZZ ZZ0051ZZ
	-----------------------------------------------------------------------
	ZZ0052ZZ Đẩy chung ZZ0053ZZ
	Lệnh ZZ0054ZZ ZZ0055ZZ
	ZZ0056ZZ ZZ0057ZZ
	ZZ0058ZZ ZZ0059ZZ
	ZZ0060ZZ ZZ0061ZZ
	ZZ0062ZZ ZZ0063ZZ
	-----------------------------------------------------------------------
	ZZ0064ZZ Không có ZZ0065ZZ
	-----------------------------------------------------------------------

V - Bố cục cấu trúc phần cứng
==============================

Vi mã QE từ Freescale thường được cung cấp dưới dạng tệp tiêu đề.  Cái này
tệp tiêu đề chứa các macro xác định chính mã nhị phân vi mã cũng như
một số dữ liệu khác được sử dụng để tải lên vi mã đó.  Định dạng của các tập tin này
không cho phép mình đưa đơn giản vào mã khác.  Do đó,
sự cần thiết cho một định dạng di động hơn.  Phần này xác định định dạng đó.

Thay vì phân phối tệp tiêu đề, vi mã và dữ liệu liên quan được
được nhúng vào một đốm màu nhị phân.  Blob này được chuyển đến qe_upload_firmware()
chức năng phân tích blob và thực hiện mọi thứ cần thiết để tải lên
vi mã.

Tất cả các số nguyên đều là số cuối lớn.  Xem các bình luận cho chức năng
qe_upload_firmware() để biết thông tin triển khai cập nhật.

Cấu trúc này hỗ trợ lập phiên bản, trong đó phiên bản của cấu trúc được
được nhúng vào chính cấu trúc đó.  Để đảm bảo tiến và lùi
khả năng tương thích, tất cả các phiên bản của cấu trúc phải sử dụng cùng một 'qe_header'
cấu trúc lúc đầu.

'tiêu đề' (loại: struct qe_header):
	Trường 'độ dài' là kích thước tính bằng byte của toàn bộ cấu trúc,
	bao gồm tất cả các vi mã được nhúng trong đó, cũng như CRC (nếu
	hiện tại).

Trường 'ma thuật' là một mảng gồm ba byte chứa các chữ cái
	'Q', 'E' và 'F'.  Đây là mã định danh cho biết rằng
	cấu trúc là cấu trúc phần sụn QE.

Trường 'phiên bản' là một byte đơn cho biết phiên bản của phiên bản này
	cấu trúc.  Nếu bố cục của cấu trúc cần phải được
	đã thay đổi để thêm hỗ trợ cho các loại vi mã bổ sung, thì
	số phiên bản cũng nên được thay đổi.

Trường 'id' là một chuỗi kết thúc bằng null (phù hợp để in)
xác định phần sụn.

Trường 'đếm' cho biết số lượng cấu trúc 'vi mã'.  Ở đó
phải là một và chỉ một cấu trúc 'vi mã' cho mỗi bộ xử lý RISC.
Do đó, trường này cũng đại diện cho số lượng bộ xử lý RISC cho việc này
SOC.

Cấu trúc 'soc' chứa các số SOC và các bản sửa đổi được sử dụng để khớp với
microcode vào chính SOC.  Thông thường, trình tải vi mã sẽ
kiểm tra dữ liệu trong cấu trúc này với số SOC và các bản sửa đổi, và
chỉ tải lên vi mã nếu có kết quả trùng khớp.  Tuy nhiên, việc kiểm tra này không
được thực hiện trên tất cả các nền tảng.

Mặc dù không được khuyến khích nhưng bạn có thể chỉ định '0' trong soc.model
để bỏ qua hoàn toàn các SOC phù hợp.

Trường 'model' là số 16 bit khớp với SOC thực tế. các
Các trường 'chính' và 'phụ' là số sửa đổi chính và phụ,
tương ứng của SOC.

Ví dụ: để phù hợp với 8323, phiên bản 1.0::

soc.model = 8323
     soc.major = 1
     soc.minor = 0

'phần đệm' là cần thiết để căn chỉnh cấu trúc.  Trường này đảm bảo rằng
Trường 'extends_modes' được căn chỉnh trên ranh giới 64 bit.

'extends_modes' là một trường bit xác định chức năng đặc biệt có
tác động lên trình điều khiển thiết bị.  Mỗi bit đều có tác động riêng và có ý nghĩa đặc biệt
hướng dẫn cho trình điều khiển liên quan đến nó.  Trường này được lưu trữ trong
thư viện QE và có sẵn cho bất kỳ trình điều khiển nào gọi qe_get_firmware_info().

'vtraps' là một mảng gồm 8 từ chứa các giá trị bẫy ảo cho mỗi từ
bẫy ảo.  Giống như 'extents_modes', trường này được lưu trữ trong QE
library and available to any driver that calls qe_get_firmware_info().

'microcode' (loại: struct qe_microcode):
	Đối với mỗi bộ xử lý RISC có một cấu trúc 'vi mã'.  đầu tiên
	Cấu trúc 'vi mã' dành cho RISC đầu tiên, v.v.

Trường 'id' là một chuỗi kết thúc bằng null thích hợp để in
	xác định vi mã cụ thể này.

'bẫy' là một mảng gồm 16 từ chứa các giá trị bẫy phần cứng
	cho mỗi trong số 16 bẫy.  Nếu bẫy[i] bằng 0 thì điều này đặc biệt
	bẫy sẽ bị bỏ qua (tức là không được ghi vào TIBCR[i]).  Toàn bộ giá trị
	được ghi nguyên trạng vào thanh ghi TIBCR[i], vì vậy hãy đảm bảo đặt EN
	và các bit T_IBP nếu cần thiết.

'eccr' là giá trị để lập trình vào thanh ghi ECCR.

'iram_offset' là phần bù vào IRAM để bắt đầu ghi
	vi mã.

'đếm' là số từ 32 bit trong vi mã.

'code_offset' là phần bù, tính bằng byte, tính từ đầu này
	cấu trúc nơi có thể tìm thấy chính vi mã.  đầu tiên
	nhị phân vi mã phải được đặt ngay sau 'vi mã'
	mảng.

'chính', 'nhỏ' và 'sửa đổi' là chính, phụ và sửa đổi
	số phiên bản tương ứng của vi mã.  Nếu tất cả các giá trị là 0,
	thì các trường này sẽ bị bỏ qua.

'dành riêng' là cần thiết để căn chỉnh cấu trúc.  Vì 'vi mã'
	là một mảng, trường 'extends_modes' 64 bit cần được căn chỉnh
	trên ranh giới 64 bit và điều này chỉ có thể xảy ra nếu kích thước của
	'microcode' là bội số của 8 byte.  Để đảm bảo điều đó, chúng tôi thêm
	'dành riêng'.

Sau vi mã cuối cùng là CRC 32 bit.  Nó có thể được tính bằng cách sử dụng
thuật toán này::

u32 crc32(const u8 *p, unsigned int len)
  {
	unsigned int i;
	u32 crc = 0;

trong khi (len--) {
	   crc ^= *p++;
	   vì (i = 0; i < 8; i++)
		   crc = (crc >> 1) ^ ((crc & 1) ? 0xedb88320 : 0);
	}
	trả lại crc;
  }

VI - Mã mẫu để tạo tập tin phần sụn
============================================

Một chương trình Python tạo các tệp nhị phân phần sụn từ các tệp tiêu đề một cách bình thường
được phân phối bởi Freescale có thể được tìm thấy trên ZZ0000ZZ
