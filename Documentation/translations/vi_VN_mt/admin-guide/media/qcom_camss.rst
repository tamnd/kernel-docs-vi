.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/media/qcom_camss.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

.. include:: <isonum.txt>

Trình điều khiển hệ thống phụ máy ảnh Qualcomm
================================

Giới thiệu
------------

Tệp này ghi lại trình điều khiển Hệ thống con máy ảnh Qualcomm nằm bên dưới
trình điều khiển/phương tiện/nền tảng/qcom/camss.

Phiên bản hiện tại của trình điều khiển hỗ trợ Hệ thống con máy ảnh được tìm thấy trên
Bộ xử lý Qualcomm MSM8916/APQ8016 và MSM8996/APQ8096.

Trình điều khiển triển khai các giao diện V4L2, Bộ điều khiển đa phương tiện và V4L2.
Hỗ trợ cảm biến camera sử dụng giao diện subdev V4L2 trong kernel.

Trình điều khiển được triển khai bằng cách sử dụng hệ thống con máy ảnh Qualcomm làm tài liệu tham khảo
driver cho Android như được tìm thấy trong Code Linaro [#f1]_ [#f2]_.


Phần cứng của hệ thống con máy ảnh Qualcomm
----------------------------------

Phần cứng Hệ thống con máy ảnh được tìm thấy trên bộ xử lý 8x16 / 8x96 và được hỗ trợ bởi
người lái xe bao gồm:

- 2/3 module CSIPHY. Họ xử lý lớp Vật lý của máy thu CSI2.
  Một cảm biến camera riêng biệt có thể được kết nối với từng mô-đun CSIPHY;
- 2/4 module CSID (Bộ giải mã CSI). Họ xử lý Giao thức và Ứng dụng
  lớp của máy thu CSI2. CSID có thể giải mã luồng dữ liệu từ bất kỳ
  CSIPHY. Mỗi CSID cũng chứa khối TG (Trình tạo thử nghiệm) có thể tạo
  dữ liệu đầu vào nhân tạo cho mục đích thử nghiệm;
- Mô-đun ISPIF (Giao diện ISP). Xử lý việc định tuyến các luồng dữ liệu từ
  CSID tới đầu vào của VFE;
- 1/2 mô-đun VFE (Video Front End). Chứa một đường ống xử lý hình ảnh
  các khối phần cứng. VFE có các giao diện đầu vào khác nhau. Đầu vào PIX (Pixel)
  giao diện cung cấp dữ liệu đầu vào cho đường ống xử lý hình ảnh. Hình ảnh
  Đường ống xử lý cũng chứa một mô-đun chia tỷ lệ và cắt xén ở cuối. Ba
  Giao diện đầu vào RDI (Giao diện kết xuất thô) bỏ qua quá trình xử lý hình ảnh
  đường ống. VFE cũng chứa giao diện bus AXI để ghi đầu ra
  dữ liệu vào bộ nhớ.


Chức năng được hỗ trợ
-----------------------

Phiên bản hiện tại của trình điều khiển hỗ trợ:

- Đầu vào từ cảm biến camera qua CSIPHY;
- Tạo dữ liệu đầu vào thử nghiệm bằng TG trong CSID;
- Giao diện RDI của VFE

- Kết xuất thô dữ liệu đầu vào vào bộ nhớ.

Các định dạng được hỗ trợ:

- YUYV/UYVY/YVYU/VYUY (đóng gói YUV 4:2:2 - V4L2_PIX_FMT_YUYV /
      V4L2_PIX_FMT_UYVY / V4L2_PIX_FMT_YVYU / V4L2_PIX_FMT_VYUY);
    - MIPI RAW8 (8bit Bayer RAW - V4L2_PIX_FMT_SRGGB8 /
      V4L2_PIX_FMT_SGRBG8 / V4L2_PIX_FMT_SGBRG8 / V4L2_PIX_FMT_SBGGR8);
    - MIPI RAW10 (đóng gói 10bit Bayer RAW - V4L2_PIX_FMT_SBGGR10P /
      V4L2_PIX_FMT_SGBRG10P / V4L2_PIX_FMT_SGRBG10P / V4L2_PIX_FMT_SRGGB10P /
      V4L2_PIX_FMT_Y10P);
    - MIPI RAW12 (đóng gói 12bit Bayer RAW - V4L2_PIX_FMT_SRGGB12P /
      V4L2_PIX_FMT_SGBRG12P / V4L2_PIX_FMT_SGRBG12P / V4L2_PIX_FMT_SRGGB12P).
    - (chỉ 8x96) MIPI RAW14 (đóng gói 14bit Bayer RAW - V4L2_PIX_FMT_SRGGB14P /
      V4L2_PIX_FMT_SGBRG14P / V4L2_PIX_FMT_SGRBG14P / V4L2_PIX_FMT_SRGGB14P).

- (chỉ 8x96) Chuyển đổi định dạng của dữ liệu đầu vào.

Các định dạng đầu vào được hỗ trợ:

- MIPI RAW10 (đóng gói 10bit Bayer RAW - V4L2_PIX_FMT_SBGGR10P/V4L2_PIX_FMT_Y10P).

Các định dạng đầu ra được hỗ trợ:

- Plain16 RAW10 (10bit unpacked Bayer RAW - V4L2_PIX_FMT_SBGGR10/V4L2_PIX_FMT_Y10).

- Giao diện PIX của VFE

- Chuyển đổi định dạng dữ liệu đầu vào.

Các định dạng đầu vào được hỗ trợ:

- YUYV/UYVY/YVYU/VYUY (đóng gói YUV 4:2:2 - V4L2_PIX_FMT_YUYV /
      V4L2_PIX_FMT_UYVY / V4L2_PIX_FMT_YVYU / V4L2_PIX_FMT_VYUY).

Các định dạng đầu ra được hỗ trợ:

- NV12/NV21 (hai mặt phẳng YUV 4:2:0 - V4L2_PIX_FMT_NV12 / V4L2_PIX_FMT_NV21);
    - NV16/NV61 (hai mặt phẳng YUV 4:2:2 - V4L2_PIX_FMT_NV16 / V4L2_PIX_FMT_NV61).
    - (chỉ 8x96) YUYV/UYVY/YVYU/VYUY (đóng gói YUV 4:2:2 - V4L2_PIX_FMT_YUYV /
      V4L2_PIX_FMT_UYVY / V4L2_PIX_FMT_YVYU / V4L2_PIX_FMT_VYUY).

- Hỗ trợ mở rộng quy mô. Cấu hình của mô-đun Cân mã hóa VFE
    để thu nhỏ với tỷ lệ lên tới 16x.

- Hỗ trợ cắt xén. Cấu hình của mô-đun Crop mã hóa VFE.

- Sử dụng đồng thời và độc lập hai đầu vào dữ liệu (8x96: ba) -
  có thể là cảm biến camera và/hoặc TG.


Kiến trúc và thiết kế trình điều khiển
------------------------------

Trình điều khiển triển khai giao diện subdev V4L2. Với mục tiêu mô hình hóa
liên kết phần cứng giữa các mô-đun và để hiển thị một cách rõ ràng, hợp lý và có thể sử dụng được
giao diện, trình điều khiển được chia thành các thiết bị con V4L2 như sau (8x16 / 8x96):

- 2 / 3 thiết bị phụ CSIPHY - mỗi CSIPHY được đại diện bởi một thiết bị phụ duy nhất;
- 2 / 4 thiết bị phụ CSID - mỗi thiết bị phụ CSID được đại diện bởi một thiết bị phụ duy nhất;
- 2/4 thiết bị phụ ISPIF - ISPIF được đại diện bởi một số thiết bị phụ
  bằng số lượng thiết bị con CSID;
- 4/8 thiết bị con VFE - VFE được biểu thị bằng số thiết bị con bằng
  số lượng giao diện đầu vào (3 RDI và 1 PIX cho mỗi VFE).

Những cân nhắc để phân chia trình điều khiển theo cách cụ thể này như sau:

- đại diện cho các mô-đun CSIPHY và CSID bằng một thiết bị phụ riêng biệt cho mỗi mô-đun
  cho phép mô hình hóa các liên kết phần cứng giữa các mô-đun này;
- đại diện cho VFE bằng một thiết bị phụ riêng biệt cho mỗi giao diện đầu vào cho phép
  để sử dụng các giao diện đầu vào đồng thời và độc lập vì đây là
  được hỗ trợ bởi phần cứng;
- đại diện cho ISPIF bằng một số thiết bị phụ bằng số lượng CSID
  các thiết bị phụ cho phép tạo các đường ống điều khiển phương tiện tuyến tính khi sử dụng hai
  máy ảnh cùng một lúc. Điều này tránh các nhánh trong đường ống mà nếu không
  sẽ yêu cầu a) không gian người dùng và b) khung phương tiện (ví dụ: bật/tắt nguồn
  hoạt động) để đưa ra các giả định về luồng dữ liệu từ một bảng chìm đến một
  bảng nguồn trên một thực thể phương tiện duy nhất.

Mỗi thiết bị phụ VFE được liên kết với một nút thiết bị video riêng biệt.

Biểu đồ đường dẫn của bộ điều khiển phương tiện như sau (với hai/ba được kết nối
Cảm biến máy ảnh OV5645):

.. _qcom_camss_graph:

.. kernel-figure:: qcom_camss_graph.dot
    :alt:   qcom_camss_graph.dot
    :align: center

    Media pipeline graph 8x16

.. kernel-figure:: qcom_camss_8x96_graph.dot
    :alt:   qcom_camss_8x96_graph.dot
    :align: center

    Media pipeline graph 8x96


Thực hiện
--------------

Cấu hình thời gian chạy của phần cứng (cập nhật cài đặt trong khi phát trực tuyến) là
không bắt buộc phải triển khai chức năng hiện được hỗ trợ. hoàn chỉnh
cấu hình trên mỗi mô-đun phần cứng được áp dụng trên STREAMON ioctl dựa trên
các liên kết, định dạng và điều khiển phương tiện đang hoạt động hiện tại.

Kích thước đầu ra của mô-đun bộ chia tỷ lệ trong VFE được định cấu hình với kích thước thực tế
soạn hình chữ nhật lựa chọn trên bảng chìm của thực thể 'msm_vfe0_pix'.

Vùng đầu ra cắt xén của mô-đun cắt xén trong VFE được định cấu hình với giá trị thực tế
cắt hình chữ nhật lựa chọn trên bảng nguồn của thực thể 'msm_vfe0_pix'.


Tài liệu
-------------

Đặc điểm kỹ thuật APQ8016:
ZZ0000ZZ
Tham chiếu 24-11-2016.

Đặc điểm kỹ thuật APQ8096:
ZZ0000ZZ
Tham chiếu 22-06-2018.

Tài liệu tham khảo
----------

.. [#f1] https://git.codelinaro.org/clo/la/kernel/msm-3.10/
.. [#f2] https://git.codelinaro.org/clo/la/kernel/msm-3.18/