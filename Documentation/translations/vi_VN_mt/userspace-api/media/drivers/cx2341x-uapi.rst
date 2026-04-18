.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/drivers/cx2341x-uapi.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Trình điều khiển cx2341x
========================

Định dạng file không nén
--------------------------

Cx23416 có thể tạo ra (và cx23415 cũng có thể đọc) đầu ra YUV thô. các
định dạng của khung YUV là NV12 xếp lớp tuyến tính 16x16 (V4L2_PIX_FMT_NV12_16L16).

Định dạng là YUV 4:2:0 sử dụng 1 byte Y cho mỗi pixel và 1 U và V byte cho mỗi pixel.
bốn pixel.

Dữ liệu được mã hóa dưới dạng hai mặt phẳng macroblock, mặt phẳng đầu tiên chứa Y
giá trị, giá trị thứ hai chứa macroblocks UV.

Mặt phẳng Y được chia thành các khối 16x16 pixel từ trái sang phải
và từ trên xuống dưới. Mỗi khối được truyền lần lượt, từng dòng một.

Vì vậy, 16 byte đầu tiên là dòng đầu tiên của khối trên cùng bên trái,
16 byte thứ hai là dòng thứ hai của khối trên cùng bên trái, v.v. Sau
truyền khối này dòng đầu tiên của khối bên phải tới
khối đầu tiên được truyền đi, v.v.

Mặt phẳng UV được chia thành các khối có giá trị UV 16x8 đi từ bên trái
sang phải, từ trên xuống dưới. Mỗi khối được truyền lần lượt, từng dòng một.

Vì vậy, 16 byte đầu tiên là dòng đầu tiên của khối trên cùng bên trái và
chứa 8 cặp giá trị UV (tổng cộng 16 byte). 16 byte thứ hai là
dòng thứ hai gồm 8 cặp UV của khối trên cùng bên trái, v.v. Sau khi truyền
khối này dòng đầu tiên của khối ở bên phải khối đầu tiên là
được truyền đi, v.v.

Đoạn mã dưới đây được đưa ra làm ví dụ về cách chuyển đổi V4L2_PIX_FMT_NV12_16L16
để tách các mặt phẳng Y, U và V. Mã này giả sử các khung hình có kích thước 720x576 (PAL) pixel.

Chiều rộng của khung luôn là 720 pixel, bất kể kích thước thực tế được chỉ định
chiều rộng.

Nếu chiều cao không phải là bội số của 32 dòng thì video được quay là
thiếu macroblocks ở cuối và không sử dụng được. Vậy chiều cao phải là a
bội số của 32.

Ví dụ về định dạng thô c
~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>

	static unsigned char frame[576*720*3/2];
	static unsigned char framey[576*720];
	static unsigned char frameu[576*720 / 4];
	static unsigned char framev[576*720 / 4];

	static void de_macro_y(unsigned char* dst, unsigned char *src, int dstride, int w, int h)
	{
	unsigned int y, x, i;

	// descramble Y plane
	// dstride = 720 = w
	// The Y plane is divided into blocks of 16x16 pixels
	// Each block in transmitted in turn, line-by-line.
	for (y = 0; y < h; y += 16) {
		for (x = 0; x < w; x += 16) {
		for (i = 0; i < 16; i++) {
			memcpy(dst + x + (y + i) * dstride, src, 16);
			src += 16;
		}
		}
	}
	}

	static void de_macro_uv(unsigned char *dstu, unsigned char *dstv, unsigned char *src, int dstride, int w, int h)
	{
	unsigned int y, x, i;

	// descramble U/V plane
	// dstride = 720 / 2 = w
	// The U/V values are interlaced (UVUV...).
	// Again, the UV plane is divided into blocks of 16x16 UV values.
	// Each block in transmitted in turn, line-by-line.
	for (y = 0; y < h; y += 16) {
		for (x = 0; x < w; x += 8) {
		for (i = 0; i < 16; i++) {
			int idx = x + (y + i) * dstride;

			dstu[idx+0] = src[0];  dstv[idx+0] = src[1];
			dstu[idx+1] = src[2];  dstv[idx+1] = src[3];
			dstu[idx+2] = src[4];  dstv[idx+2] = src[5];
			dstu[idx+3] = src[6];  dstv[idx+3] = src[7];
			dstu[idx+4] = src[8];  dstv[idx+4] = src[9];
			dstu[idx+5] = src[10]; dstv[idx+5] = src[11];
			dstu[idx+6] = src[12]; dstv[idx+6] = src[13];
			dstu[idx+7] = src[14]; dstv[idx+7] = src[15];
			src += 16;
		}
		}
	}
	}

	/*************************************************************************/
	int main(int argc, char **argv)
	{
	FILE *fin;
	int i;

	if (argc == 1) fin = stdin;
	else fin = fopen(argv[1], "r");

	if (fin == NULL) {
		fprintf(stderr, "cannot open input\n");
		exit(-1);
	}
	while (fread(frame, sizeof(frame), 1, fin) == 1) {
		de_macro_y(framey, frame, 720, 720, 576);
		de_macro_uv(frameu, framev, frame + 720 * 576, 720 / 2, 720 / 2, 576 / 2);
		fwrite(framey, sizeof(framey), 1, stdout);
		fwrite(framev, sizeof(framev), 1, stdout);
		fwrite(frameu, sizeof(frameu), 1, stdout);
	}
	fclose(fin);
	return 0;
	}


Định dạng của dữ liệu V4L2_MPEG_STREAM_VBI_FMT_IVTV VBI được nhúng
------------------------------------------------------------------

Tác giả: Hans Verkuil <hverkuil@kernel.org>


Phần này mô tả định dạng V4L2_MPEG_STREAM_VBI_FMT_IVTV của dữ liệu VBI
được nhúng trong luồng chương trình MPEG-2. Định dạng này một phần được quyết định bởi một số
hạn chế phần cứng của trình điều khiển ivtv (trình điều khiển cho Conexant cx23415/6
chip), đặc biệt là kích thước tối đa cho dữ liệu VBI. Cái nào dài hơn sẽ bị cắt
tắt khi luồng MPEG được phát lại qua cx23415.

Ưu điểm của định dạng này là nó rất nhỏ gọn và tất cả dữ liệu VBI cho
tất cả các dòng có thể được lưu trữ trong khi vẫn vừa với kích thước tối đa cho phép.

ID luồng của dữ liệu VBI là 0xBD. Kích thước tối đa của dữ liệu nhúng là
4 + 43 * 36, tức là 4 byte cho tiêu đề và 2 * 18 dòng VBI có 1 byte
tiêu đề và mỗi tải trọng 42 byte. Bất cứ điều gì vượt quá giới hạn này sẽ bị cắt bởi
phần sụn cx23415/6. Bên cạnh dữ liệu cho các dòng VBI chúng ta cũng cần 36 bit
đối với mặt nạ bit xác định dòng nào được ghi lại và 4 byte cho cookie ma thuật,
biểu thị rằng gói dữ liệu này chứa dữ liệu V4L2_MPEG_STREAM_VBI_FMT_IVTV VBI.
Nếu tất cả các dòng được sử dụng thì sẽ không còn chỗ cho mặt nạ bit nữa. Để giải quyết vấn đề này
hai con số ma thuật khác nhau đã được giới thiệu:

'itv0': Sau phép thuật này, tiếp theo là hai khoảng thời gian dài không dấu. Bit 0-17 của bit đầu tiên
unsigned long biểu thị dòng nào của trường đầu tiên được ghi lại. Bit 18-31 của
độ dài không dấu đầu tiên và các bit 0-3 của độ dài không dấu thứ hai được sử dụng cho
trường thứ hai.

'ITV0': Con số kỳ diệu này giả định rằng tất cả các dòng VBI đều bị bắt, tức là nó ngầm định
ngụ ý rằng mặt nạ bit là 0xffffffff và 0xf.

Sau những cookie ma thuật này (và bitmask 8 byte trong trường hợp cookie 'itv0'),
bắt đầu dòng VBI:

Đối với mỗi dòng, 4 bit có ý nghĩa nhỏ nhất của byte đầu tiên chứa kiểu dữ liệu.
Các giá trị có thể được hiển thị trong bảng dưới đây. Tải trọng nằm trong 42 sau
byte.

Dưới đây là danh sách các kiểu dữ liệu có thể có:

.. code-block:: c

	#define IVTV_SLICED_TYPE_TELETEXT       0x1     // Teletext (uses lines 6-22 for PAL)
	#define IVTV_SLICED_TYPE_CC             0x4     // Closed Captions (line 21 NTSC)
	#define IVTV_SLICED_TYPE_WSS            0x5     // Wide Screen Signal (line 23 PAL)
	#define IVTV_SLICED_TYPE_VPS            0x7     // Video Programming System (PAL) (line 16)
