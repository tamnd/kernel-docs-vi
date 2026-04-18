.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/userspace-api/fwctl/bnxt_fwctl.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===================
trình điều khiển fwctl bnxt
=================

:Tác giả: Pavan Chebbi

Tổng quan
========

Trình điều khiển BNXT cung cấp dịch vụ fwctl thông qua một thiết bị phụ trợ.
Trình điều khiển bnxt_fwctl liên kết với thiết bị này và tự đăng ký với
hệ thống con fwctl.

Trình điều khiển bnxt_fwctl không liên quan đến phần sụn bên trong thiết bị. Nó
sử dụng đường dẫn Giao thức lớp trên (ULP) do bnxt cung cấp để gửi
Lệnh quản lý tài nguyên phần cứng (HWRM) tới phần sụn.

Các lệnh này có thể truy vấn hoặc thay đổi cấu hình thiết bị điều khiển bằng chương trình cơ sở
và các thanh ghi đọc/ghi hữu ích cho việc gỡ lỗi.

bnxt_fwctl Người dùng API
===================

Mỗi yêu cầu RPC chứa cấu trúc đầu vào HWRM trong fwctl_rpc
Bộ đệm 'in' trong khi 'out' sẽ chứa phản hồi.

Một ứng dụng người dùng thông thường có thể gửi lệnh FWCTL_INFO bằng ioctl()
để khám phá các khả năng RPC của bnxt_fwctl như dưới đây:

ioctl(fd, FWCTL_INFO, &fwctl_info_msg);

trong đó fwctl_info_msg (thuộc loại struct fwctl_info) mô tả bnxt_info_msg
(thuộc loại struct fwctl_info_bnxt). fwctl_info_msg được thiết lập như sau:

kích thước = sizeof(struct fwctl_info);
        cờ = 0;
        device_data_len = sizeof(bnxt_info_msg);
        out_device_data = (__aligned_u64)&bnxt_info_msg;

uctx_caps của bnxt_info_msg thể hiện các khả năng như được mô tả
trong fwctl_bnxt_commands của include/uapi/fwctl/bnxt.h

Bản thân FW RPC, FWCTL_RPC có thể được gửi bằng ioctl() dưới dạng:

ioctl(fd, FWCTL_RPC, &fwctl_rpc_msg);

trong đó fwctl_rpc_msg (thuộc loại struct fwctl_rpc) mang lệnh HWRM
trong bộ đệm 'trong' của nó. Cấu trúc đầu vào HWRM được mô tả trong
bao gồm/linux/bnxt/hsi.h. Một ví dụ cho HWRM_VER_GET được hiển thị bên dưới:

cấu trúc hwrm_ver_get_output tương ứng;
        cấu trúc fwctl_rpc fwctl_rpc_msg;
        cấu trúc hwrm_ver_get_input req;

req.req_type = HWRM_VER_GET;
        req.hwrm_intf_maj = HWRM_VERSION_MAJOR;
        req.hwrm_intf_min = HWRM_VERSION_MINOR;
        req.hwrm_intf_upd = HWRM_VERSION_UPDATE;
        req.cmpl_ring = -1;
        req.target_id = -1;

fwctl_rpc_msg.size = sizeof(struct fwctl_rpc);
        fwctl_rpc_msg.scope = FWCTL_RPC_DEBUG_READ_ONLY;
        fwctl_rpc_msg.in_len = sizeof(req);
        fwctl_rpc_msg.out_len = sizeof(resp);
        fwctl_rpc_msg.in = (__aligned_u64)&req;
        fwctl_rpc_msg.out = (__aligned_u64)&resp;

Bạn có thể tìm thấy một chương trình python3 mẫu có thể thực hiện giao diện này trong
kho git sau:

ZZ0000ZZ