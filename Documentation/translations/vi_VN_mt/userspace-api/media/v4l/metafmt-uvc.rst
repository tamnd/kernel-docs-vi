.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/metafmt-uvc.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. c:namespace:: V4L

.. _v4l2-meta-fmt-uvc:

*******************************
V4L2_META_FMT_UVC ('UVCH')
*******************************

Dữ liệu tiêu đề tải trọng UVC


Sự miêu tả
===========

Định dạng này mô tả siêu dữ liệu UVC tiêu chuẩn, được trích xuất từ các tiêu đề gói UVC
và được cung cấp bởi trình điều khiển UVC thông qua các nút video siêu dữ liệu. Dữ liệu đó bao gồm
bản sao chính xác của phần tiêu chuẩn của nội dung Tiêu đề tải trọng UVC và phần phụ trợ
thông tin thời gian, cần thiết để giải thích chính xác dấu thời gian, chứa
trong những tiêu đề đó. Xem phần "2.4.3.3 Tiêu đề tải trọng video và ảnh tĩnh" của
"Thông số kỹ thuật lớp UVC 1.5" để biết chi tiết.

Mỗi tiêu đề tải trọng UVC có thể lớn từ 2 đến 12 byte. Bộ đệm có thể
chứa nhiều tiêu đề, nếu nhiều tiêu đề như vậy được truyền bởi
máy ảnh cho khung tương ứng. Tuy nhiên, trình điều khiển có thể bỏ tiêu đề khi
bộ đệm đã đầy khi chúng không chứa thông tin hữu ích nào (ví dụ: những thông tin không có
Trường SCR hoặc trường đó giống hệt với tiêu đề trước đó) hoặc nói chung là
thực hiện giới hạn tốc độ khi thiết bị gửi một số lượng lớn tiêu đề.

Mỗi khối riêng lẻ chứa các trường sau:

.. flat-table:: UVC Metadata Block
    :widths: 1 4
    :header-rows:  1
    :stub-columns: 0

    * - Field
      - Description
    * - __u64 ts;
      - system timestamp in host byte order, measured by the driver upon
        reception of the payload
    * - __u16 sof;
      - USB Frame Number in host byte order, also obtained by the driver as
        close as possible to the above timestamp to enable correlation between
        them
    * - :cspan:`1` *The rest is an exact copy of the UVC payload header:*
    * - __u8 length;
      - length of the rest of the block, including this field. Please note that
        regardless of this value, for V4L2_META_FMT_UVC the kernel will never
        copy more than 2-12 bytes.
    * - __u8 flags;
      - Flags, indicating presence of other standard UVC fields
    * - __u8 buf[];
      - The rest of the header, possibly including UVC PTS and SCR fields