.. SPDX-License-Identifier: GFDL-1.1-no-invariants-or-later

.. include:: ../../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/media/v4l/pixfmt-srggb8-pisp-comp.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. c:namespace:: V4L

.. _v4l2-pix-fmt-pisp-comp1-rggb:
.. _v4l2-pix-fmt-pisp-comp1-grbg:
.. _v4l2-pix-fmt-pisp-comp1-gbrg:
.. _v4l2-pix-fmt-pisp-comp1-bggr:
.. _v4l2-pix-fmt-pisp-comp1-mono:
.. _v4l2-pix-fmt-pisp-comp2-rggb:
.. _v4l2-pix-fmt-pisp-comp2-grbg:
.. _v4l2-pix-fmt-pisp-comp2-gbrg:
.. _v4l2-pix-fmt-pisp-comp2-bggr:
.. _v4l2-pix-fmt-pisp-comp2-mono:

********************************************************************************************************************************************************************************************************************* *********************************************************************************************************************************************************************************************************************
V4L2_PIX_FMT_PISP_COMP1_RGGB ('PC1R'), V4L2_PIX_FMT_PISP_COMP1_GRBG ('PC1G'), V4L2_PIX_FMT_PISP_COMP1_GBRG ('PC1g'), V4L2_PIX_FMT_PISP_COMP1_BGGR ('PC1B), V4L2_PIX_FMT_PISP_COMP1_MONO ('PC1M'), V4L2_PIX_FMT_PISP_COMP2_RGGB ('PC2R'), V4L2_PIX_FMT_PISP_COMP2_GRBG ('PC2G'), V4L2_PIX_FMT_PISP_COMP2_GBRG ('PC2g'), V4L2_PIX_FMT_PISP_COMP2_BGGR ('PC2B), V4L2_PIX_FMT_PISP_COMP2_MONO ('PC2M')
**************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************

====================================================
Raspberry Pi PiSP nén các định dạng Bayer 8 bit
================================================

Sự miêu tả
===========

Raspberry Pi ISP (PiSP) sử dụng nhóm ba nén tốc độ cố định của Bayer
các định dạng. Phần bù mức độ màu đen có thể được trừ đi để cải thiện khả năng nén
hiệu quả; mức đen danh nghĩa và lượng bù phải được báo hiệu
của ban nhạc. Mỗi đường quét được đệm thành bội số của chiều rộng 8 pixel và mỗi khối
gồm 8 pixel liền kề theo chiều ngang được mã hóa bằng 8 byte.

Chế độ 1 sử dụng sơ đồ mã hóa dựa trên lượng tử hóa và delta để bảo toàn tối đa
12 bit có ý nghĩa Chế độ 2 là sơ đồ nén đơn giản giống như sqrt với 6 PWL
hợp âm, bảo toàn tới 12 bit quan trọng. Chế độ 3 kết hợp cả nén
(với 4 hợp âm) và sơ đồ delta, bảo toàn tới 14 bit quan trọng.

Phần còn lại của mô tả này áp dụng cho Chế độ 1 và 3.

Mỗi khối 8 pixel được chia thành các pha chẵn và lẻ 4 pixel,
được mã hóa độc lập bằng các từ 32 bit tại các vị trí liên tiếp trong bộ nhớ.
Hai bit LS của mỗi từ 32 bit cung cấp "chế độ lượng tử hóa" của nó.

Trong chế độ lượng tử hóa 0, mức lượng tử hóa 321 thấp nhất là bội số của
FSD/4096 và các mức còn lại là bội số liên tiếp của FSD/2048.
Chế độ lượng tử hóa 1 và 2 sử dụng lượng tử hóa tuyến tính với kích thước bước là
FSD/1024 và FSD/512 tương ứng. Mỗi pixel trong số bốn pixel được lượng tử hóa
độc lập, làm tròn đến mức gần nhất.
Trong chế độ lượng tử hóa 2 trong đó hai mẫu ở giữa có giá trị lượng tử hóa
(q1,q2) cả trong phạm vi [384..511], chúng được mã hóa bằng 9 bit cho q1
theo sau là 7 bit cho (q2 & 127). Mặt khác, đối với các chế độ lượng tử hóa
0, 1 và 2: trường 9 bit mã hóa MIN(q1,q2) phải nằm trong phạm vi
[0..511] và trường 7 bit mã hóa (q2-q1+64) phải nằm trong [0..127].

Mỗi mẫu bên ngoài (q0,q3) được mã hóa bằng trường 7 bit
trên hàng xóm bên trong q1 hoặc q2 của nó. Trong chế độ lượng tử hóa 2 trong đó phần bên trong
mẫu có giá trị lượng tử hóa trong phạm vi [448..511], giá trị trường là
(q0-384). Mặt khác đối với các chế độ lượng tử hóa 0, 1 và 2: Mẫu bên ngoài
được mã hóa thành (q0-MAX(0,q1-64)). q3 cũng được mã hóa tương tự dựa trên q2.
Mỗi giá trị này phải nằm trong phạm vi [0..127]. Tất cả các trường này
gồm 2, 9, 7, 7, 7 bit tương ứng được đóng gói theo thứ tự endian nhỏ
để đưa ra một từ 32 bit với thứ tự byte LE.

Chế độ lượng tử hóa 3 có lối thoát "7,5 bit", được sử dụng khi không có điều nào ở trên
mã hóa sẽ phù hợp. Mỗi giá trị pixel được lượng tử hóa đến giá trị gần nhất là 176
mức, trong đó 95 mức thấp nhất là bội số của FSD/256 và
các mức còn lại là bội số của FSD/128 (mức 175 biểu thị các giá trị
rất gần với FSD và có thể yêu cầu số học bão hòa để giải mã).

Mỗi cặp pixel lượng tử hóa (q0,q1) hoặc (q2,q3) được mã hóa chung
bởi trường 15 bit: 2816*(q0>>4) + 16*q1 + (q0&15).
Ba trường 2, 15, 15 bit được sắp xếp theo thứ tự LE {15,15,2}.

Đã có sẵn phần mềm giải mã các định dạng nén
trong ZZ0000ZZ.