.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/usb/writing_usb_driver.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

.. _writing-usb-driver:

=============================
Viết trình điều khiển thiết bị USB
==========================

:Tác giả: Greg Kroah-Hartman

Giới thiệu
============

Hệ thống con Linux USB đã phát triển từ việc chỉ hỗ trợ hai
loại thiết bị trong nhân 2.2.7 (chuột và bàn phím), đến hơn 20
các loại thiết bị khác nhau trong kernel 2.4. Linux hiện hỗ trợ
hầu hết tất cả các thiết bị lớp USB (các loại thiết bị tiêu chuẩn như bàn phím,
chuột, modem, máy in và loa) và số lượng ngày càng tăng của
các thiết bị dành riêng cho nhà cung cấp (như USB sang bộ chuyển đổi nối tiếp, bộ chuyển đổi kỹ thuật số
máy ảnh, thiết bị Ethernet và đầu phát MP3). Để có danh sách đầy đủ các
các thiết bị USB khác nhau hiện được hỗ trợ, xem Tài nguyên.

Các loại thiết bị USB còn lại không hỗ trợ trên Linux là
hầu hết tất cả các thiết bị dành riêng cho nhà cung cấp. Mỗi nhà cung cấp quyết định thực hiện một
giao thức tùy chỉnh để giao tiếp với thiết bị của họ, vì vậy trình điều khiển tùy chỉnh thường
cần phải được tạo ra. Một số nhà cung cấp mở với giao thức USB của họ và
trợ giúp tạo trình điều khiển Linux, trong khi những trình điều khiển khác không xuất bản
chúng và các nhà phát triển buộc phải thiết kế ngược. Xem tài nguyên cho
một số liên kết đến các công cụ kỹ thuật đảo ngược tiện dụng.

Bởi vì mỗi giao thức khác nhau sẽ tạo ra một trình điều khiển mới, nên tôi
đã viết một bộ khung trình điều khiển USB chung, được mô phỏng theo
tập tin pci-skeleton.c trong cây nguồn kernel trên đó có nhiều PCI
trình điều khiển mạng đã được dựa. Bộ xương USB này có thể được tìm thấy tại
driver/usb/usb-skeleton.c trong cây nguồn kernel. Trong bài viết này tôi
sẽ tìm hiểu những điều cơ bản về trình điều khiển bộ xương, giải thích
các phần khác nhau và những gì cần phải làm để tùy chỉnh nó cho phù hợp với nhu cầu của bạn
thiết bị cụ thể.

Khái niệm cơ bản về Linux USB
================

Nếu bạn định viết trình điều khiển Linux USB, hãy làm quen
với đặc tả giao thức USB. Nó có thể được tìm thấy, cùng với nhiều
các tài liệu hữu ích khác, tại trang chủ USB (xem Tài nguyên). Một
Bạn có thể tìm thấy phần giới thiệu tuyệt vời về hệ thống con Linux USB tại
Danh sách thiết bị làm việc USB (xem Tài nguyên). Nó giải thích cách Linux USB
hệ thống con được cấu trúc và giới thiệu cho người đọc khái niệm USB
urbs (Khối yêu cầu USB), rất cần thiết cho trình điều khiển USB.

Điều đầu tiên trình điều khiển Linux USB cần làm là tự đăng ký với
hệ thống con Linux USB, cung cấp cho nó một số thông tin về những thiết bị nào
trình điều khiển hỗ trợ và chức năng nào sẽ gọi khi thiết bị được hỗ trợ
bởi trình điều khiển được chèn hoặc xóa khỏi hệ thống. Tất cả điều này
thông tin được chuyển đến hệ thống con USB trong ZZ0000ZZ
cấu trúc. Trình điều khiển khung khai báo ZZ0001ZZ là::

cấu trúc tĩnh usb_driver skel_driver = {
	    .name = "bộ xương",
	    .probe = skel_probe,
	    .disconnect = skel_disconnect,
	    .suspend = skel_suspend,
	    .resume = skel_resume,
	    .pre_reset = skel_pre_reset,
	    .post_reset = skel_post_reset,
	    .id_table = bảng skel_table,
	    .supports_autosuspend = 1,
    };


Tên biến là một chuỗi mô tả trình điều khiển. Nó được sử dụng trong
thông báo thông tin được in vào nhật ký hệ thống. Đầu dò và
con trỏ hàm ngắt kết nối được gọi khi một thiết bị phù hợp với
thông tin được cung cấp trong biến ZZ0000ZZ được nhìn thấy hoặc
bị loại bỏ.

Các fops và các biến nhỏ là tùy chọn. Hầu hết các trình điều khiển USB đều kết nối với
một hệ thống con hạt nhân khác, chẳng hạn như hệ thống con SCSI, mạng hoặc TTY.
Các loại trình điều khiển này tự đăng ký với kernel khác
hệ thống con và mọi tương tác trong không gian người dùng đều được cung cấp thông qua đó
giao diện. Nhưng đối với các trình điều khiển không có hệ thống con kernel phù hợp,
chẳng hạn như trình phát hoặc máy quét MP3, một phương pháp tương tác với không gian người dùng
là cần thiết. Hệ thống con USB cung cấp cách đăng ký một thiết bị nhỏ
số và một tập hợp các con trỏ hàm ZZ0000ZZ cho phép
tương tác không gian người dùng này. Trình điều khiển bộ xương cần loại này
giao diện, do đó nó cung cấp một số bắt đầu nhỏ và một con trỏ tới
Chức năng ZZ0001ZZ.

Trình điều khiển USB sau đó được đăng ký bằng lệnh gọi tới usb_register(),
thường có trong hàm init của trình điều khiển, như được hiển thị ở đây::

int tĩnh __init usb_skel_init(void)
    {
	    kết quả int;

/* đăng ký trình điều khiển này với hệ thống con USB */
	    kết quả = usb_register(&skel_driver);
	    nếu (kết quả < 0) {
		    pr_err("USB_register không thành công đối với trình điều khiển %s. Số lỗi %d\n",
		           skel_driver.name, kết quả);
		    trả về -1;
	    }

trả về 0;
    }
    module_init(usb_skel_init);


Khi driver được dỡ khỏi hệ thống, nó cần hủy đăng ký
chính nó với hệ thống con USB. Việc này được thực hiện bằng usb_deregister()
chức năng::

khoảng trống tĩnh __exit usb_skel_exit(void)
    {
	    /* hủy đăng ký trình điều khiển này với hệ thống con USB */
	    usb_deregister(&skel_driver);
    }
    module_exit(usb_skel_exit);


Để cho phép hệ thống linux-hotplug tự động tải trình điều khiển khi
thiết bị đã được cắm, bạn cần tạo ZZ0000ZZ.
Đoạn mã sau cho các tập lệnh hotplug biết rằng mô-đun này hỗ trợ một
một thiết bị có ID nhà cung cấp và sản phẩm cụ thể::

/* bảng các thiết bị hoạt động với trình điều khiển này */
    cấu trúc tĩnh usb_device_id skel_table [] = {
	    {USB_DEVICE(USB_SKEL_VENDOR_ID, USB_SKEL_PRODUCT_ID) },
	    { } /* Kết thúc mục nhập */
    };
    MODULE_DEVICE_TABLE (usb, bảng skel_);


Có các macro khác có thể được sử dụng để mô tả cấu trúc
ZZ0000ZZ dành cho trình điều khiển hỗ trợ cả lớp USB
trình điều khiển. Xem ZZ0001ZZ để biết thêm thông tin về điều này.

Vận hành thiết bị
================

Khi một thiết bị được cắm vào bus USB khớp với ID thiết bị
mẫu mà trình điều khiển của bạn đã đăng ký với lõi USB, đầu dò
hàm được gọi. Cấu trúc ZZ0000ZZ, số giao diện và
ID giao diện được chuyển đến hàm::

int tĩnh skel_probe(struct usb_interface *interface,
	const struct usb_device_id *id)


Trình điều khiển bây giờ cần xác minh rằng thiết bị này thực sự là một thiết bị
có thể chấp nhận. Nếu vậy, nó trả về 0. Nếu không, hoặc nếu có lỗi xảy ra trong quá trình
khởi tạo, mã lỗi (như ZZ0000ZZ hoặc ZZ0001ZZ) sẽ
được trả về từ hàm thăm dò.

Trong trình điều khiển khung, chúng tôi xác định điểm cuối nào được đánh dấu là
hàng loạt vào và hàng loạt. Chúng tôi tạo bộ đệm để giữ dữ liệu sẽ được
được gửi và nhận từ thiết bị và một urb USB để ghi dữ liệu vào
thiết bị được khởi tạo.

Ngược lại, khi thiết bị được gỡ bỏ khỏi bus USB, việc ngắt kết nối sẽ
hàm được gọi bằng con trỏ thiết bị. Tài xế cần dọn dẹp
bất kỳ dữ liệu riêng tư nào đã được phân bổ vào thời điểm này và tắt
mọi urbs đang chờ xử lý có trong hệ thống USB.

Bây giờ thiết bị đã được cắm vào hệ thống và trình điều khiển đã bị ràng buộc
đối với thiết bị, bất kỳ chức năng nào trong cấu trúc ZZ0000ZZ
đã được chuyển đến hệ thống con USB sẽ được gọi từ chương trình người dùng
đang cố gắng nói chuyện với thiết bị. Hàm đầu tiên được gọi sẽ được mở, vì
chương trình cố gắng mở thiết bị để vào/ra. Chúng tôi tăng cường sự riêng tư của mình
số lần sử dụng và lưu con trỏ tới cấu trúc bên trong của chúng tôi trong tệp
cấu trúc. Điều này được thực hiện để các lệnh gọi tới thao tác tệp trong tương lai sẽ
cho phép trình điều khiển xác định thiết bị nào người dùng đang đánh địa chỉ. Tất cả
việc này được thực hiện với đoạn mã sau ::

/* tăng số lượng sử dụng của chúng tôi cho thiết bị */
    kref_get(&dev->kref);

/* lưu đối tượng của chúng ta vào cấu trúc riêng tư của tệp */
    tệp->private_data = dev;


Sau khi hàm open được gọi, các hàm đọc và ghi sẽ được thực hiện
được gọi để nhận và gửi dữ liệu đến thiết bị. Trong ZZ0000ZZ
hàm, chúng ta nhận được một con trỏ tới một số dữ liệu mà người dùng muốn gửi
vào thiết bị và kích thước của dữ liệu. Hàm xác định bao nhiêu
dữ liệu nó có thể gửi đến thiết bị dựa trên kích thước của urb ghi mà nó có
được tạo (kích thước này phụ thuộc vào kích thước của điểm cuối đầu ra hàng loạt mà
thiết bị có). Sau đó, nó sao chép dữ liệu từ không gian người dùng vào kernel
space, trỏ urb vào dữ liệu và gửi urb tới USB
hệ thống con. Điều này có thể được nhìn thấy trong đoạn mã sau::

/* chúng tôi chỉ có thể viết tối đa 1 đô thị có thể chứa được */
    size_t writesize = min_t(size_t, count, MAX_TRANSFER);

/* sao chép dữ liệu từ không gian người dùng vào khu vực đô thị của chúng tôi */
    copy_from_user(buf, user_buffer, writesize);

/* thiết lập đô thị của chúng tôi */
    usb_fill_bulk_urb(urb,
		      dev->udev,
		      usb_sndbulkpipe(dev->udev, dev->bulk_out_endpointAddr),
		      bạn ơi,
		      viết kích thước,
		      skel_write_bulk_callback,
		      nhà phát triển);

/* gửi dữ liệu ra cổng số lượng lớn */
    retval = usb_submit_urb(urb, GFP_KERNEL);
    if (retval) {
	    dev_err(&dev->giao diện->dev,
                "%s - gửi urb ghi không thành công, lỗi %d\n",
                __func__, thu hồi);
    }


Khi urb ghi được điền đầy đủ thông tin thích hợp bằng cách sử dụng
Hàm ZZ0000ZZ, chúng tôi trỏ đến cuộc gọi lại hoàn thành của đô thị
để gọi hàm ZZ0001ZZ của riêng chúng ta. Chức năng này là
được gọi khi đô thị được hoàn thành bởi hệ thống con USB. Cuộc gọi lại
hàm được gọi trong ngữ cảnh ngắt, do đó phải thận trọng để không
thực hiện rất nhiều xử lý vào thời điểm đó. Việc thực hiện của chúng tôi
ZZ0002ZZ chỉ báo cáo nếu đô thị đã được hoàn thành
thành công hay không rồi trả về.

Chức năng đọc hoạt động hơi khác so với chức năng ghi trong
rằng chúng tôi không sử dụng đô thị để truyền dữ liệu từ thiết bị sang
người lái xe. Thay vào đó chúng ta gọi hàm ZZ0000ZZ, hàm này có thể được sử dụng
để gửi hoặc nhận dữ liệu từ một thiết bị mà không cần phải tạo urbs và
xử lý các chức năng gọi lại hoàn thành đô thị. Chúng tôi gọi là ZZ0001ZZ
chức năng, cung cấp cho nó một bộ đệm để đặt bất kỳ dữ liệu nào nhận được từ
thiết bị và giá trị thời gian chờ. Nếu thời gian chờ hết hạn mà không
nhận bất kỳ dữ liệu nào từ thiết bị, chức năng sẽ không thành công và trả về kết quả
thông báo lỗi. Điều này có thể được hiển thị với đoạn mã sau ::

/* thực hiện đọc hàng loạt ngay lập tức để lấy dữ liệu từ thiết bị */
    retval = usb_bulk_msg (skel->dev,
			   usb_rcvbulkpipe (skel->dev,
			   skel->bulk_in_endpointAddr),
			   skel->bulk_in_buffer,
			   skel->bulk_in_size,
			   &đếm, 5000);
    /* nếu đọc thành công, sao chép dữ liệu vào vùng người dùng */
    nếu (!retval) {
	    if (copy_to_user (bộ đệm, skel->bulk_in_buffer, đếm))
		    giá trị trả lại = -EFAULT;
	    khác
		    hồi lại = đếm;
    }


Chức năng ZZ0000ZZ có thể rất hữu ích khi thực hiện đọc một lần
hoặc ghi vào thiết bị; tuy nhiên, nếu bạn cần đọc hoặc viết liên tục vào
một thiết bị, bạn nên thiết lập urbs của riêng mình và gửi chúng tới
hệ thống con USB.

Khi chương trình người dùng giải phóng phần xử lý tệp mà nó đang sử dụng để
nói chuyện với thiết bị, chức năng giải phóng trong trình điều khiển sẽ được gọi. trong
chức năng này chúng tôi giảm số lượng sử dụng riêng tư của mình và chờ đợi nếu có thể
đang chờ ghi::

/* giảm số lượng sử dụng của chúng tôi cho thiết bị */
    --skel->open_count;


Một trong những vấn đề khó khăn hơn mà trình điều khiển USB phải giải quyết được
xử lý trơn tru là thực tế là thiết bị USB có thể được gỡ bỏ khỏi
hệ thống tại bất kỳ thời điểm nào, ngay cả khi một chương trình hiện đang nói chuyện với
nó. Nó cần có khả năng tắt mọi hoạt động đọc và ghi hiện tại và
thông báo cho các chương trình trong không gian người dùng rằng thiết bị không còn ở đó nữa. các
đoạn mã sau (chức năng ZZ0000ZZ) là một ví dụ về cách thực hiện
cái này::

nội tuyến tĩnh void skel_delete (struct usb_skel *dev)
    {
	kfree (dev->bulk_in_buffer);
	nếu (dev->bulk_out_buffer != NULL)
	    usb_free_coherent (dev->udev, dev->bulk_out_size,
		dev->bulk_out_buffer,
		dev->write_urb->transfer_dma);
	usb_free_urb (dev->write_urb);
	kfree (dev);
    }


Nếu một chương trình hiện có bộ điều khiển mở cho thiết bị, chúng tôi sẽ đặt lại
cờ ZZ0000ZZ. Đối với mỗi lần đọc, viết, phát hành và các hoạt động khác
chức năng mong muốn có thiết bị, trước tiên trình điều khiển sẽ kiểm tra
cờ này để xem thiết bị có còn tồn tại không. Nếu không, nó sẽ phát hành
rằng thiết bị đã biến mất và lỗi ZZ0001ZZ được trả về
chương trình không gian người dùng. Khi hàm phát hành cuối cùng được gọi, nó
xác định xem có thiết bị nào không và nếu không, nó sẽ dọn dẹp
chức năng ZZ0002ZZ thường hoạt động nếu không có tệp nào đang mở
trên thiết bị (xem Liệt kê 5).

Dữ liệu đẳng thời
================

Trình điều khiển bộ xương USB này không có bất kỳ ví dụ nào về ngắt hoặc
dữ liệu đẳng thời được gửi đến hoặc từ thiết bị. Dữ liệu ngắt là
được gửi gần như chính xác như dữ liệu hàng loạt, với một vài ngoại lệ nhỏ.
Dữ liệu đẳng thời hoạt động khác với các luồng dữ liệu liên tục được
được gửi đến hoặc từ thiết bị. Trình điều khiển máy ảnh âm thanh và video rất
những ví dụ hay về trình điều khiển xử lý dữ liệu đẳng thời và sẽ hữu ích
nếu bạn cũng cần phải làm điều này.

Phần kết luận
==========

Viết trình điều khiển thiết bị Linux USB không phải là một nhiệm vụ khó khăn vì
Trình điều khiển bộ xương USB hiển thị. Trình điều khiển này, kết hợp với dòng điện khác
Trình điều khiển USB, phải cung cấp đủ ví dụ để giúp tác giả mới bắt đầu
tạo một trình điều khiển hoạt động trong một khoảng thời gian tối thiểu. Linux-usb-devel
kho lưu trữ danh sách gửi thư cũng chứa rất nhiều thông tin hữu ích.

Tài nguyên
=========

Dự án Linux USB:
ZZ0000ZZ

Dự án cắm nóng Linux:
ZZ0000ZZ

Lưu trữ danh sách gửi thư linux-usb:
ZZ0000ZZ

Hướng dẫn lập trình cho Trình điều khiển thiết bị Linux USB:
ZZ0000ZZ

USB Trang chủ: ZZ0000ZZ
