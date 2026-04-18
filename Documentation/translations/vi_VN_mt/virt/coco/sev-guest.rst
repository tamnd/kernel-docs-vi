.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/virt/coco/sev-guest.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

========================================================================
Tài liệu SEV dành cho khách API dứt khoát
========================================================================

1. Mô tả chung
======================

SEV API là một tập hợp các ioctls được khách hoặc người ảo hóa sử dụng
để lấy hoặc đặt một khía cạnh nhất định của máy ảo SEV. Các ioctls thuộc về
vào các lớp sau:

- Hypervisor ioctls: Truy vấn và thiết lập các thuộc tính toàn cục ảnh hưởng đến
   toàn bộ phần mềm SEV.  Các ioctl này được sử dụng bởi các công cụ cung cấp nền tảng.

- Guest ioctls: Các truy vấn và thiết lập thuộc tính của máy ảo SEV.

2. Mô tả API
==================

Phần này mô tả ioctls được sử dụng để truy vấn báo cáo khách SEV
từ phần sụn SEV. Đối với mỗi ioctl, thông tin sau được cung cấp
cùng với một mô tả:

Công nghệ:
      công nghệ SEV nào cung cấp ioctl này. SEV, SEV-ES, SEV-SNP hoặc tất cả.

loại:
      hypervisor hoặc khách. ioctl có thể được sử dụng bên trong khách hoặc
      siêu giám sát.

Thông số:
      những tham số nào được ioctl chấp nhận.

Trả về:
      giá trị trả về.  Số lỗi chung (-ENOMEM, -EINVAL)
      không chi tiết nhưng có những lỗi có ý nghĩa cụ thể.

Ioctl khách phải được cấp trên bộ mô tả tệp của /dev/sev-guest
thiết bị.  Ioctl chấp nhận struct snp_user_guest_request. Đầu vào và
Cấu trúc đầu ra được chỉ định thông qua trường req_data và resp_data
tương ứng. Nếu ioctl không thực thi được do lỗi phần sụn thì
mã fw_error sẽ được đặt, nếu không fw_error sẽ được đặt thành -1.

Phần sụn kiểm tra xem bộ đếm chuỗi tin nhắn có lớn hơn một đơn vị không
bộ đếm trình tự tin nhắn của khách. Nếu trình điều khiển khách không tăng thông báo
bộ đếm (ví dụ: tràn bộ đếm), thì -EIO sẽ được trả về.

::

cấu trúc snp_guest_request_ioctl {
                /* Số phiên bản tin nhắn */
                __u32 tin nhắn_version;

/* Địa chỉ cấu trúc yêu cầu và phản hồi */
                __u64 req_data;
                __u64 resp_data;

/* bit[63:32]: Mã lỗi VMM, mã lỗi phần sụn bit[31:0] (xem psp-sev.h) */
                công đoàn {
                        __u64 exitinfo2;
                        cấu trúc {
                                __u32 fw_error;
                                __u32 vmm_error;
                        };
                };
        };

Các ioctls máy chủ được cấp cho bộ mô tả tệp của thiết bị/dev/sev.
Ioctl chấp nhận ID lệnh/cấu trúc đầu vào được ghi lại bên dưới.

::

cấu trúc thứ bảy_issue_cmd {
                /*ID lệnh */
                __u32 cmd;

/*Cấu trúc lệnh yêu cầu */
                __u64 dữ liệu;

/* Mã lỗi phần sụn bị lỗi (xem psp-sev.h) */
                __u32 lỗi;
        };


2.1 SNP_GET_REPORT
------------------

:Công nghệ: sev-snp
:Type: khách ioctl
:Thông số (trong): struct snp_report_req
:Trả về (ra): struct snp_report_resp khi thành công, - Negative khi có lỗi

SNP_GET_REPORT ioctl có thể được sử dụng để truy vấn báo cáo chứng thực từ
Phần mềm SEV-SNP. Ioctl sử dụng lệnh SNP_GUEST_REQUEST (MSG_REPORT_REQ)
được cung cấp bởi chương trình cơ sở SEV-SNP để truy vấn báo cáo chứng thực.

Nếu thành công, snp_report_resp.data sẽ chứa báo cáo. Báo cáo
chứa định dạng được mô tả trong đặc tả SEV-SNP. Xem SEV-SNP
đặc điểm kỹ thuật để biết thêm chi tiết.

2.2 SNP_GET_DERIVED_KEY
-----------------------
:Công nghệ: sev-snp
:Type: khách ioctl
:Thông số (trong): struct snp_derived_key_req
:Trả về (ra): struct snp_derem_key_resp nếu thành công, - Negative nếu có lỗi

SNP_GET_DERIVED_KEY ioctl có thể được sử dụng để lấy khóa lấy từ khóa gốc.
Khách có thể sử dụng khóa dẫn xuất cho bất kỳ mục đích nào, chẳng hạn như khóa niêm phong
hoặc giao tiếp với các thực thể bên ngoài.

Ioctl sử dụng lệnh SNP_GUEST_REQUEST (MSG_KEY_REQ) do
Phần mềm SEV-SNP để lấy chìa khóa. Xem thông số kỹ thuật SEV-SNP để biết thêm chi tiết
trên các trường khác nhau được chuyển trong yêu cầu phái sinh khóa.

Nếu thành công, snp_derived_key_resp.data chứa giá trị khóa dẫn xuất. Xem
thông số kỹ thuật SEV-SNP để biết thêm chi tiết.


2.3 SNP_GET_EXT_REPORT
----------------------
:Công nghệ: sev-snp
:Type: khách ioctl
:Thông số (vào/ra): struct snp_ext_report_req
:Trả về (ra): struct snp_report_resp khi thành công, - Negative khi có lỗi

SNP_GET_EXT_REPORT ioctl tương tự như SNP_GET_REPORT. Sự khác biệt là
liên quan đến dữ liệu chứng chỉ bổ sung được trả về cùng với báo cáo.
Dữ liệu chứng chỉ được trả về đang được cung cấp bởi trình ảo hóa thông qua
SNP_SET_EXT_CONFIG.

Ioctl sử dụng lệnh SNP_GUEST_REQUEST (MSG_REPORT_REQ) do SEV-SNP cung cấp
firmware để nhận được báo cáo chứng thực.

Nếu thành công, snp_ext_report_resp.data sẽ chứa báo cáo chứng thực
và snp_ext_report_req.certs_address sẽ chứa blob chứng chỉ. Nếu
độ dài của blob nhỏ hơn dự kiến thì snp_ext_report_req.certs_len sẽ
được cập nhật với giá trị mong đợi.

Xem thông số kỹ thuật GHCB để biết thêm chi tiết về cách phân tích blob chứng chỉ.

2.4 SNP_PLATFORM_STATUS
-----------------------
:Công nghệ: sev-snp
:Type: hypervisor ioctl cmd
:Thông số (ngoài): struct sev_user_data_snp_status
:Trả về (ra): 0 nếu thành công, -âm tính nếu có lỗi

Lệnh SNP_PLATFORM_STATUS được sử dụng để truy vấn trạng thái nền tảng SNP. các
trạng thái bao gồm API phiên bản chính, phiên bản phụ và hơn thế nữa. Xem SEV-SNP
đặc điểm kỹ thuật để biết thêm chi tiết.

2.5 SNP_COMMIT
--------------
:Công nghệ: sev-snp
:Type: hypervisor ioctl cmd
:Trả về (ra): 0 nếu thành công, -âm tính nếu có lỗi

SNP_COMMIT được sử dụng để xác nhận phần sụn hiện được cài đặt bằng cách sử dụng
Lệnh SEV-SNP firmware SNP_COMMIT. Điều này ngăn chặn việc quay trở lại trạng thái trước đó
phiên bản phần mềm đã cam kết. Điều này cũng sẽ cập nhật TCB được báo cáo để phù hợp
của phần sụn hiện được cài đặt.

2.6 SNP_SET_CONFIG
------------------
:Công nghệ: sev-snp
:Type: hypervisor ioctl cmd
:Thông số (trong): struct sev_user_data_snp_config
:Trả về (ra): 0 nếu thành công, -âm tính nếu có lỗi

SNP_SET_CONFIG được sử dụng để đặt cấu hình toàn hệ thống, chẳng hạn như
đã báo cáo phiên bản TCB trong báo cáo chứng thực. Lệnh tương tự
tới lệnh SNP_CONFIG được xác định trong thông số SEV-SNP. Các giá trị hiện tại của
các tham số phần sụn bị ảnh hưởng bởi lệnh này có thể được truy vấn thông qua
SNP_PLATFORM_STATUS.

2.7 SNP_VLEK_LOAD
-----------------
:Công nghệ: sev-snp
:Type: hypervisor ioctl cmd
:Thông số (trong): struct sev_user_data_snp_vlek_load
:Trả về (ra): 0 nếu thành công, -âm tính nếu có lỗi

Khi yêu cầu báo cáo chứng thực, khách có thể chỉ định liệu
nó muốn phần sụn SNP ký báo cáo bằng cách sử dụng Chip có phiên bản
Khóa xác thực (VCEK), được lấy từ các bí mật riêng của chip hoặc một
Khóa xác nhận được tải theo phiên bản (VLEK) được lấy từ AMD
Dịch vụ phái sinh chính (KDS) và bắt nguồn từ hạt giống được phân bổ cho
nhà cung cấp dịch vụ đám mây đã đăng ký.

Trong trường hợp khóa VLEK, lệnh SNP_VLEK_LOAD SNP được sử dụng để tải
chúng vào hệ thống sau khi lấy chúng từ KDS và tương ứng
chặt chẽ với lệnh phần sụn SNP_VLEK_LOAD được chỉ định trong SEV-SNP
thông số kỹ thuật.

3. Thực thi SEV-SNP CPUID
============================

Khách SEV-SNP có thể truy cập một trang đặc biệt chứa bảng các giá trị CPUID
đã được PSP xác nhận là một phần của chương trình cơ sở SNP_LAUNCH_UPDATE
lệnh. Nó cung cấp các đảm bảo sau đây về tính hợp lệ của CPUID
giá trị:

- Địa chỉ của nó được lấy thông qua bộ nạp khởi động/chương trình cơ sở (thông qua CC blob) và những địa chỉ đó
   các tệp nhị phân sẽ được đo lường như một phần của báo cáo chứng thực SEV-SNP.
 - Trạng thái ban đầu của nó sẽ được mã hóa/pvalidated, do đó cố gắng sửa đổi
   nó trong thời gian chạy sẽ dẫn đến việc ghi rác hoặc ngoại lệ #VC
   được tạo do những thay đổi trong trạng thái xác thực nếu trình ảo hóa cố gắng
   để hoán đổi trang hỗ trợ.
 - Cố gắng bỏ qua việc kiểm tra PSP của trình ảo hóa bằng cách sử dụng một trang bình thường hoặc
   một trang được mã hóa không phải CPUID sẽ thay đổi phép đo được cung cấp bởi
   Báo cáo chứng thực SEV-SNP.
 - Nội dung trang CPUID được ZZ0000ZZ đo lường, nhưng cố gắng sửa đổi
   nội dung dự kiến của trang CPUID như một phần của quá trình khởi tạo khách sẽ là
   được kiểm soát bởi PSP CPUID, các hoạt động kiểm tra chính sách thực thi được thực hiện trên trang
   trong SNP_LAUNCH_UPDATE và đáng chú ý sau này nếu chủ khách
   thực hiện kiểm tra riêng các giá trị CPUID.

Điều quan trọng cần lưu ý là sự đảm bảo cuối cùng này chỉ hữu ích nếu kernel
đã cẩn thận sử dụng SEV-SNP CPUID trong tất cả các giai đoạn khởi động.
Mặt khác, chứng thực của chủ sở hữu khách không đảm bảo rằng hạt nhân không
đã cung cấp các giá trị không chính xác tại một số điểm trong quá trình khởi động.

4. Khóa giao tiếp trình điều khiển khách SEV
============================================

Giao tiếp giữa khách SEV và chương trình cơ sở SEV trong AMD Secure
Bộ xử lý (ASP, còn gọi là PSP) được bảo vệ bằng Khóa giao tiếp nền tảng VM
(VMPCK). Theo mặc định, trình điều khiển khách thứ bảy sử dụng VMPCK được liên kết với
Cấp đặc quyền VM (VMPL) mà khách đang chạy. Chìa khóa này có nên
bị xóa bởi trình điều khiển thứ bảy (xem trình điều khiển để biết lý do tại sao VMPCK có thể
đã xóa), có thể sử dụng một khóa khác bằng cách tải lại trình điều khiển thứ bảy và
chỉ định khóa mong muốn bằng tham số mô-đun vmpck_id.


Thẩm quyền giải quyết
---------------------

Thông số kỹ thuật SEV-SNP và GHCB: dev.amd.com/sev

Trình điều khiển dựa trên phần sụn SEV-SNP thông số 0.9 và thông số GHCB phiên bản 2.0.