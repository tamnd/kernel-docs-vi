.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/fwctl/fwctl-cxl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

==========================
trình điều khiển fwctl cxl
==========================

:Tác giả: Dave Jiang

Tổng quan
=========

Thông số CXL xác định một tập hợp các lệnh có thể được gửi tới hộp thư của một
Thiết bị hoặc công tắc CXL. Nó cũng chừa chỗ cho các lệnh cụ thể của nhà cung cấp
cũng được phát hành vào hộp thư. fwctl cung cấp một đường dẫn để đưa ra một tập hợp các quyền được phép
các lệnh hộp thư từ không gian người dùng đến thiết bị được kiểm duyệt bởi trình điều khiển hạt nhân.

3 lệnh sau sẽ được sử dụng để hỗ trợ các tính năng của CXL:
CXL spec r3.1 8.2.9.6.1 Nhận các tính năng được hỗ trợ (Opcode 0500h)
CXL spec r3.1 8.2.9.6.2 Nhận tính năng (Opcode 0501h)
CXL spec r3.1 8.2.9.6.3 Đặt tính năng (Opcode 0502h)

Dữ liệu trả về "Nhận các tính năng được hỗ trợ" có thể được trình điều khiển hạt nhân lọc để
loại bỏ bất kỳ tính năng nào bị kernel cấm hoặc được sử dụng độc quyền bởi
hạt nhân. Trình điều khiển sẽ đặt "Đặt kích thước tính năng" của "Được hỗ trợ
Các tính năng được hỗ trợ Nhập tính năng" thành 0 để cho biết rằng Tính năng không thể được
đã sửa đổi. Lệnh "Nhận tính năng được hỗ trợ" và lệnh "Nhận tính năng" rơi
theo chính sách fwctl của FWCTL_RPC_CONFIGURATION.

Đối với lệnh "Đặt tính năng", chính sách truy cập hiện được chia thành hai
các danh mục tùy thuộc vào hiệu ứng Đặt tính năng được thiết bị báo cáo. Nếu
Đặt tính năng sẽ gây ra thay đổi ngay lập tức cho thiết bị, chính sách truy cập fwctl
phải là FWCTL_RPC_DEBUG_WRITE_FULL. Tác dụng của cấp độ này là
"thay đổi cấu hình ngay lập tức", "thay đổi dữ liệu ngay lập tức", "thay đổi chính sách ngay lập tức",
hoặc "thay đổi nhật ký ngay lập tức" cho mặt nạ hiệu ứng đã đặt. Nếu hiệu ứng là "config
thay đổi bằng thiết lập lại nguội" hoặc "thay đổi cấu hình bằng thiết lập lại thông thường", thì
Chính sách truy cập fwctl phải là FWCTL_RPC_DEBUG_WRITE trở lên.

fwctl cxl Người dùng API
========================

.. kernel-doc:: include/uapi/fwctl/cxl.h

1. Truy vấn thông tin driver
----------------------------

Bước đầu tiên của ứng dụng là phát hành ioctl(FWCTL_CMD_INFO). thành công
việc gọi ioctl ngụ ý khả năng Tính năng đang hoạt động và
trả về tải trọng 32 bit hoàn toàn bằng 0. Một ZZ0000ZZ cần được điền
out với ZZ0001ZZ được đặt thành ZZ0002ZZ.
Dữ liệu trả về phải là ZZ0003ZZ chứa dữ liệu dành riêng
Trường 32 bit phải là tất cả số không.

2. Gửi lệnh phần cứng
-------------------------

Bước tiếp theo là gửi lệnh 'Nhận các tính năng được hỗ trợ' tới trình điều khiển từ
không gian người dùng thông qua ioctl(FWCTL_RPC). ZZ0000ZZ được trỏ tới
bởi ZZ0001ZZ. ZZ0002ZZ trỏ tới
cấu trúc đầu vào phần cứng được xác định bởi thông số CXL. ZZ0003ZZ
trỏ tới bộ đệm chứa ZZ0004ZZ bao gồm
dữ liệu đầu ra phần cứng được nội tuyến là ZZ0005ZZ. Lệnh này
được gọi hai lần. Lần đầu tiên lấy số lượng tính năng được hỗ trợ.
Lần thứ hai để lấy chi tiết tính năng cụ thể làm dữ liệu đầu ra.

Sau khi nhận được thông tin chi tiết về tính năng cụ thể, lệnh Nhận/Đặt tính năng có thể được thực hiện
được lập trình và gửi đi một cách thích hợp. Đối với lệnh "Đặt tính năng", dữ liệu được truy xuất
thông tin tính năng chứa trường hiệu ứng nêu chi tiết kết quả
Lệnh "Đặt tính năng" sẽ kích hoạt. Điều đó sẽ thông báo cho người dùng biết liệu
hệ thống có được cấu hình để cho phép lệnh "Đặt tính năng" hay không.

Ví dụ về mã của Tính năng Nhận
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

.. code-block:: c

        static int cxl_fwctl_rpc_get_test_feature(int fd, struct test_feature *feat_ctx,
                                                  const uint32_t expected_data)
        {
                struct cxl_mbox_get_feat_in *feat_in;
                struct fwctl_rpc_cxl_out *out;
                struct fwctl_rpc rpc = {0};
                struct fwctl_rpc_cxl *in;
                size_t out_size, in_size;
                uint32_t val;
                void *data;
                int rc;

                in_size = sizeof(*in) + sizeof(*feat_in);
                rc = posix_memalign((void **)&in, 16, in_size);
                if (rc)
                        return -ENOMEM;
                memset(in, 0, in_size);
                feat_in = &in->get_feat_in;

                uuid_copy(feat_in->uuid, feat_ctx->uuid);
                feat_in->count = feat_ctx->get_size;

                out_size = sizeof(*out) + feat_ctx->get_size;
                rc = posix_memalign((void **)&out, 16, out_size);
                if (rc)
                        goto free_in;
                memset(out, 0, out_size);

                in->opcode = CXL_MBOX_OPCODE_GET_FEATURE;
                in->op_size = sizeof(*feat_in);

                rpc.size = sizeof(rpc);
                rpc.scope = FWCTL_RPC_CONFIGURATION;
                rpc.in_len = in_size;
                rpc.out_len = out_size;
                rpc.in = (uint64_t)(uint64_t *)in;
                rpc.out = (uint64_t)(uint64_t *)out;

                rc = send_command(fd, &rpc, out);
                if (rc)
                        goto free_all;

                data = out->payload;
                val = le32toh(*(__le32 *)data);
                if (memcmp(&val, &expected_data, sizeof(val)) != 0) {
                        rc = -ENXIO;
                        goto free_all;
                }

        free_all:
                free(out);
        free_in:
                free(in);
                return rc;
        }

Hãy xem thư mục kiểm tra CXL CLI
<ZZ0000ZZ để biết mã người dùng chi tiết
để biết ví dụ về cách thực hiện con đường này.


hạt nhân fwctl cxl API
======================

.. kernel-doc:: drivers/cxl/core/features.c
   :export:
.. kernel-doc:: include/cxl/features.h