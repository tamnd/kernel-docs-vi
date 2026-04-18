.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/fpga/fpga-mgr.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Người quản lý FPGA
==================

Tổng quan
---------

Lõi trình quản lý FPGA xuất một tập hợp các hàm để lập trình FPGA với
một hình ảnh.  API là nhà sản xuất bất khả tri.  Tất cả các chi tiết cụ thể của nhà sản xuất là
ẩn trong trình điều khiển cấp thấp đăng ký một tập hợp các hoạt động với lõi.
Bản thân dữ liệu hình ảnh FPGA rất cụ thể theo nhà sản xuất, nhưng nhằm mục đích của chúng tôi
nó chỉ là dữ liệu nhị phân.  Lõi trình quản lý FPGA sẽ không phân tích nó.

Hình ảnh FPGA được lập trình có thể nằm trong danh sách tập hợp phân tán, một
bộ đệm liền kề hoặc tệp chương trình cơ sở.  Bởi vì cấp phát kernel liền kề
nên tránh bộ nhớ cho bộ đệm, người dùng được khuyến khích sử dụng phân tán
thay vào đó hãy thu thập danh sách nếu có thể.

Các chi tiết để lập trình hình ảnh được trình bày trong một cấu trúc (struct
fpga_image_info).  Cấu trúc này chứa các tham số như con trỏ tới
Hình ảnh FPGA cũng như các chi tiết cụ thể về hình ảnh chẳng hạn như liệu hình ảnh có
được xây dựng để cấu hình lại toàn bộ hoặc một phần.

Cách hỗ trợ thiết bị FPGA mới
--------------------------------

Để thêm một trình quản lý FPGA khác, hãy viết trình điều khiển triển khai một tập hợp các hoạt động.  các
chức năng thăm dò gọi ZZ0000ZZ hoặc ZZ0001ZZ,
chẳng hạn như::

cấu trúc const tĩnh fpga_manager_ops socfpga_fpga_ops = {
		.write_init = socfpga_fpga_ops_configure_init,
		.write = socfpga_fpga_ops_configure_write,
		.write_complete = socfpga_fpga_ops_configure_complete,
		.state = socfpga_fpga_ops_state,
	};

int tĩnh socfpga_fpga_probe(struct platform_device *pdev)
	{
		thiết bị cấu trúc *dev = &pdev->dev;
		struct socfpga_fpga_priv *priv;
		cấu trúc fpga_manager *mgr;
		int ret;

priv = devm_kzalloc(dev, sizeof(*priv), GFP_KERNEL);
		nếu (!priv)
			trả về -ENOMEM;

/*
		 * thực hiện ioremaps, nhận các ngắt, v.v. và lưu
		 * họ ở nơi riêng tư
		 */

mgr = fpga_mgr_register(dev, "Trình quản lý Altera SOCFPGA FPGA",
					&socfpga_fpga_ops, riêng tư);
		nếu (IS_ERR(mgr))
			trả về PTR_ERR(mgr);

platform_set_drvdata(pdev, mgr);

trả về 0;
	}

int tĩnh socfpga_fpga_remove(struct platform_device *pdev)
	{
		struct fpga_manager *mgr = platform_get_drvdata(pdev);

fpga_mgr_unregister(mgr);

trả về 0;
	}

Ngoài ra, chức năng thăm dò có thể gọi một trong các tài nguyên được quản lý
chức năng đăng ký, ZZ0000ZZ hoặc
ZZ0001ZZ.  Khi các chức năng này được sử dụng,
cú pháp tham số giống nhau, nhưng lệnh gọi tới ZZ0002ZZ phải là
bị loại bỏ. Trong ví dụ trên, hàm ZZ0003ZZ sẽ không
được yêu cầu.

Các op sẽ triển khai bất kỳ thao tác ghi đăng ký cụ thể nào của thiết bị cần thiết để
thực hiện trình tự lập trình cho FPGA cụ thể này.  Các hoạt động này trả về 0 cho
thành công hoặc mã lỗi tiêu cực nếu không.

Trình tự lập trình là::
 1. .parse_header (tùy chọn, có thể gọi một lần hoặc nhiều lần)
 2. .write_init
 3. .write hoặc .write_sg (có thể gọi một lần hoặc nhiều lần)
 4. .write_complete

Hàm .parse_header sẽ đặt header_size và data_size thành
cấu trúc fpga_image_info. Trước lệnh gọi par_header, header_size được khởi tạo
với kích thước ban đầu_header_size. Nếu cờ Skip_header của fpga_manager_ops là đúng,
Hàm .write sẽ lấy bộ đệm hình ảnh bắt đầu từ offset header_size từ
bắt đầu. Nếu data_size được đặt, hàm .write sẽ nhận được byte data_size của
bộ đệm hình ảnh, nếu không .write sẽ lấy dữ liệu đến cuối bộ đệm hình ảnh.
Điều này sẽ không ảnh hưởng đến .write_sg, .write_sg vẫn sẽ đưa toàn bộ hình ảnh vào
dạng sg_table. Nếu hình ảnh FPGA đã được ánh xạ dưới dạng một bộ đệm liền kề,
toàn bộ bộ đệm sẽ được chuyển vào .parse_header. Nếu hình ảnh ở chế độ thu thập phân tán
biểu mẫu, mã lõi sẽ đệm ít nhất .initial_header_size trước mã đầu tiên
gọi .parse_header, nếu chưa đủ thì đặt .parse_header như mong muốn
size thành info->header_size và trả về -EAGAIN, sau đó nó sẽ được gọi lại
với phần lớn bộ đệm hình ảnh trên đầu vào.

Hàm .write_init sẽ chuẩn bị cho FPGA nhận dữ liệu hình ảnh. các
bộ đệm được chuyển vào .write_init sẽ có độ dài ít nhất là info->header_size byte;
nếu toàn bộ dòng bit không có sẵn ngay lập tức thì mã lõi sẽ
hãy chuẩn bị ít nhất mức này trước khi bắt đầu.

Hàm .write ghi bộ đệm vào FPGA. Bộ đệm có thể chứa
toàn bộ hình ảnh FPGA hoặc có thể là một đoạn nhỏ hơn của hình ảnh FPGA.  Ở phần sau
trường hợp này, hàm này được gọi nhiều lần cho các đoạn liên tiếp. Giao diện này
phù hợp với trình điều khiển sử dụng PIO.

Phiên bản .write_sg hoạt động giống như .write ngoại trừ đầu vào là sg_table
danh sách phân tán. Giao diện này phù hợp với trình điều khiển sử dụng DMA.

Hàm .write_complete được gọi sau khi tất cả hình ảnh đã được viết xong
để đưa FPGA vào chế độ hoạt động.

Các hoạt động bao gồm một hàm .state sẽ xác định trạng thái của FPGA
và trả về mã loại enum fpga_mgr_states.  Nó không dẫn đến một sự thay đổi
ở trạng thái.

API để triển khai trình điều khiển Trình quản lý FPGA mới
---------------------------------------------------------

* ZZ0001ZZ - Giá trị cho ZZ0000ZZ.
* struct fpga_manager - cấu trúc trình quản lý FPGA
* struct fpga_manager_ops - Hoạt động của trình điều khiển trình quản lý FPGA cấp thấp
* struct fpga_manager_info - Cấu trúc tham số cho fpga_mgr_register_full()
* __fpga_mgr_register_full() - Tạo và đăng ký trình quản lý FPGA bằng cách sử dụng
  Cấu trúc fpga_mgr_info để cung cấp đầy đủ tính linh hoạt của các tùy chọn
* __fpga_mgr_register() - Tạo và đăng ký trình quản lý FPGA theo tiêu chuẩn
  lý lẽ
* __devm_fpga_mgr_register_full() - Phiên bản được quản lý tài nguyên của
  __fpga_mgr_register_full()
* __devm_fpga_mgr_register() - Phiên bản quản lý tài nguyên của __fpga_mgr_register()
* fpga_mgr_unregister() - Hủy đăng ký người quản lý FPGA

Các macro trợ giúp ZZ0000ZZ, ZZ0001ZZ,
ZZ0002ZZ và ZZ0003ZZ có sẵn
để dễ dàng đăng ký.

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :functions: fpga_mgr_states

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :functions: fpga_manager

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :functions: fpga_manager_ops

.. kernel-doc:: include/linux/fpga/fpga-mgr.h
   :functions: fpga_manager_info

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: __fpga_mgr_register_full

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: __fpga_mgr_register

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: __devm_fpga_mgr_register_full

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: __devm_fpga_mgr_register

.. kernel-doc:: drivers/fpga/fpga-mgr.c
   :functions: fpga_mgr_unregister
