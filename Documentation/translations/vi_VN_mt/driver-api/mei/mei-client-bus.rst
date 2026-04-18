.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/mei/mei-client-bus.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==================================================
Bus máy khách Intel(R) Management Engine (ME) API
==================================================


Cơ sở lý luận
=========

Thiết bị ký tự MEI rất hữu ích cho các ứng dụng chuyên dụng để gửi và nhận
dữ liệu tới nhiều thiết bị FW có trong ME của Intel từ không gian người dùng.
Tuy nhiên, đối với một số chức năng ME, việc tận dụng phần mềm hiện có là điều hợp lý.
xếp chồng và hiển thị chúng thông qua các hệ thống con kernel hiện có.

Để cắm liền mạch vào mô hình trình điều khiển thiết bị kernel, chúng tôi thêm kernel ảo
trừu tượng hóa xe buýt trên trình điều khiển MEI. Điều này cho phép triển khai trình điều khiển nhân Linux
dành cho các tính năng MEI khác nhau dưới dạng các thực thể độc lập được tìm thấy trong hệ thống con tương ứng của chúng.
Trình điều khiển thiết bị hiện có thậm chí có thể được sử dụng lại bằng cách thêm lớp bus MEI CL vào
mã hiện có.


Xe buýt MEI CL API
==============

Việc triển khai trình điều khiển cho Máy khách MEI rất giống với bất kỳ xe buýt hiện có nào khác
trình điều khiển thiết bị dựa trên. Trình điều khiển tự đăng ký làm trình điều khiển xe buýt MEI CL thông qua
cấu trúc ZZ0001ZZ được xác định trong ZZ0000ZZ

.. code-block:: C

        struct mei_cl_driver {
                struct device_driver driver;
                const char *name;

                const struct mei_cl_device_id *id_table;

                int (*probe)(struct mei_cl_device *dev, const struct mei_cl_id *id);
                int (*remove)(struct mei_cl_device *dev);
        };



Cấu trúc mei_cl_device_id được xác định trong ZZ0000ZZ cho phép
trình điều khiển để liên kết chính nó với tên thiết bị.

.. code-block:: C

        struct mei_cl_device_id {
                char name[MEI_CL_NAME_SIZE];
                uuid_le uuid;
                __u8    version;
                kernel_ulong_t driver_info;
        };

Để thực sự đăng ký trình điều khiển trên xe buýt ME Client, người ta phải gọi ZZ0000ZZ
API. Điều này thường được gọi tại thời điểm khởi tạo mô-đun.

Sau khi trình điều khiển được đăng ký và liên kết với thiết bị, trình điều khiển thường sẽ
hãy thử thực hiện một số thao tác I/O trên bus này và việc này sẽ được thực hiện thông qua ZZ0000ZZ
và chức năng ZZ0001ZZ. Thông tin chi tiết hơn có trong phần ZZ0002ZZ.

Để người lái xe được thông báo về tình trạng giao thông hoặc sự kiện đang chờ xử lý, người lái xe
nên đăng ký gọi lại qua ZZ0000ZZ và
Chức năng ZZ0001ZZ tương ứng.

.. _api:

API:
----
.. kernel-doc:: drivers/misc/mei/bus.c
    :export: drivers/misc/mei/bus.c



Ví dụ
=======

Như một ví dụ lý thuyết, hãy giả sử ME đi kèm với IP NFC "liên hệ".
Các quy trình khởi tạo và thoát trình điều khiển cho thiết bị này sẽ như sau:

.. code-block:: C

        #define CONTACT_DRIVER_NAME "contact"

        static struct mei_cl_device_id contact_mei_cl_tbl[] = {
                { CONTACT_DRIVER_NAME, },

                /* required last entry */
                { }
        };
        MODULE_DEVICE_TABLE(mei_cl, contact_mei_cl_tbl);

        static struct mei_cl_driver contact_driver = {
                .id_table = contact_mei_tbl,
                .name = CONTACT_DRIVER_NAME,

                .probe = contact_probe,
                .remove = contact_remove,
        };

        static int contact_init(void)
        {
                int r;

                r = mei_cl_driver_register(&contact_driver);
                if (r) {
                        pr_err(CONTACT_DRIVER_NAME ": driver registration failed\n");
                        return r;
                }

                return 0;
        }

        static void __exit contact_exit(void)
        {
                mei_cl_driver_unregister(&contact_driver);
        }

        module_init(contact_init);
        module_exit(contact_exit);

Và quy trình thăm dò được đơn giản hóa của trình điều khiển sẽ như sau:

.. code-block:: C

        int contact_probe(struct mei_cl_device *dev, struct mei_cl_device_id *id)
        {
                [...]
                mei_cldev_enable(dev);

                mei_cldev_register_rx_cb(dev, contact_rx_cb);

                return 0;
        }

Trong quy trình thăm dò, trước tiên trình điều khiển kích hoạt thiết bị MEI rồi đăng ký
một trình xử lý rx gần giống như việc đăng ký một trình xử lý IRQ theo luồng.
Việc triển khai trình xử lý thường sẽ gọi ZZ0000ZZ và sau đó
xử lý dữ liệu nhận được.

.. code-block:: C

        #define MAX_PAYLOAD 128
        #define HDR_SIZE 4
        static void conntact_rx_cb(struct mei_cl_device *cldev)
        {
                struct contact *c = mei_cldev_get_drvdata(cldev);
                unsigned char payload[MAX_PAYLOAD];
                ssize_t payload_sz;

                payload_sz = mei_cldev_recv(cldev, payload,  MAX_PAYLOAD)
                if (reply_size < HDR_SIZE) {
                        return;
                }

                c->process_rx(payload);

        }

Trình điều khiển xe buýt khách MEI
======================

.. toctree::
   :maxdepth: 2

   hdcp
   nfc