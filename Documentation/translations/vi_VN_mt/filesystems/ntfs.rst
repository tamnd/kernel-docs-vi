.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/filesystems/ntfs.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

============================================
Trình điều khiển hệ thống tập tin Linux NTFS
============================================


.. Table of contents

   - Overview
   - Utilities support
   - Supported mount options


Tổng quan
=========

NTFS là trình điều khiển hệ thống tệp nhân Linux cung cấp khả năng đọc và ghi đầy đủ
hỗ trợ cho khối lượng NTFS. Nó được thiết kế cho hiệu suất cao, hiện đại
cơ sở hạ tầng hạt nhân (iomap, folio) và bảo trì ổn định lâu dài.


Tiện ích hỗ trợ
=================

Dự án tiện ích NTFS, được gọi là ntfsprogs-plus, cung cấp mkfs.ntfs,
fsck.ntfs và các công cụ liên quan khác (ví dụ: ntfsinfo, ntfsclone, v.v.) cho
tạo, kiểm tra và quản lý khối lượng NTFS. Những tiện ích này có thể được sử dụng
để kiểm tra hệ thống tập tin với xfstests cũng như để khôi phục bị hỏng
Thiết bị NTFS.

Dự án có sẵn tại:

ZZ0000ZZ


Tùy chọn gắn kết được hỗ trợ
============================

Trình điều khiển NTFS hỗ trợ các tùy chọn gắn kết sau:

=================================================================================
iocharset=name Bộ ký tự được sử dụng để chuyển đổi giữa
                        mã hóa được sử dụng cho tên tệp hiển thị của người dùng và
                        Ký tự Unicode 16 bit.

nls=name Tùy chọn không được dùng nữa.  Vẫn được hỗ trợ nhưng vui lòng sử dụng
                        iocharset=name trong tương lai.

uid=
gid=
umask= Cung cấp mặt nạ chủ sở hữu, nhóm và chế độ truy cập mặc định.
                        Các tùy chọn này hoạt động như được ghi trong mount(8).  Bởi
                        mặc định, các tập tin/thư mục được sở hữu bởi root
                        và anh ấy/cô ấy cũng có quyền đọc và viết
                        như quyền duyệt cho các thư mục.  Không ai khác
                        có bất kỳ quyền truy cập nào.  tức là chế độ trên tất cả
                        các tập tin theo mặc định rw------- và
                        đối với các thư mục rwx------, hệ quả của
                        fmask=0177 và dmask=0077 mặc định.
                        Việc sử dụng ô bằng 0 sẽ cấp tất cả các quyền cho
                        mọi người, tức là tất cả các tập tin và thư mục sẽ có
                        chế độ rwxrwxrwx.

fmask=
dmask= Thay vì chỉ định umask áp dụng cho cả hai
                        tập tin và thư mục, fmask chỉ áp dụng cho tập tin
                        và chỉ dmask cho các thư mục.

showmeta=<BOOL>
show_sys_files=<BOOL> Nếu show_sys_files được chỉ định, hãy hiển thị hệ thống
                        tập tin trong danh sách thư mục.  Nếu không thì mặc định
                        hành vi là ẩn các tập tin hệ thống.
                        Lưu ý rằng ngay cả khi show_sys_files được chỉ định,
                        "$MFT" sẽ không hiển thị do lỗi/tính năng sai
                        trong glibc. Hơn nữa, lưu ý rằng bất kể
                        show_sys_files, tất cả các tệp đều có thể truy cập được theo tên,
                        tức là bạn luôn có thể thực hiện "ls -l \$UpCase" chẳng hạn
                        để hiển thị cụ thể tệp hệ thống có chứa
                        bảng chữ hoa Unicode.

case_sensitive=<BOOL> Nếu case_sensitive được chỉ định, hãy xử lý tất cả tên tệp
                        phân biệt chữ hoa chữ thường và tạo tên tệp theo
                        không gian tên POSIX (hành vi mặc định). Lưu ý,
                        trình điều khiển Linux NTFS sẽ không bao giờ tạo ra lỗi ngắn
                        tên tập tin và sẽ loại bỏ chúng khi đổi tên/xóa
                        tên tập tin dài tương ứng. Lưu ý rằng các tập tin
                        vẫn có thể truy cập được thông qua tên tệp ngắn của họ, nếu nó
                        tồn tại.

nocase=<BOOL> Nếu nocase được chỉ định, hãy xử lý tên tệp
                        không phân biệt chữ hoa chữ thường.

vô hiệu hóa_sparse=<BOOL> Nếu vô hiệu hóa_sparse được chỉ định, việc tạo thưa thớt
                        các vùng, tức là các lỗ hổng, các tập tin bên trong bị vô hiệu hóa đối với
                        âm lượng (chỉ trong thời gian gắn kết này).
                        Theo mặc định, việc tạo các vùng thưa thớt được bật,
                        phù hợp với hành vi của
                        hệ thống tập tin Unix truyền thống.

error=opt Chỉ định hành vi của NTFS đối với các lỗi nghiêm trọng: hoảng loạn,
                        gắn lại phân vùng ở chế độ chỉ đọc hoặc
                        tiếp tục mà không làm gì cả (hành vi mặc định).

mft_zone_multiplier= Đặt hệ số nhân vùng MFT cho âm lượng (cái này
                        cài đặt không liên tục trên các lần gắn kết và có thể
                        đã thay đổi từ mount này sang mount khác nhưng không thể thay đổi được
                        khi kể lại).  Cho phép các giá trị từ 1 đến 4, 1 là
                        mặc định.  Bộ nhân vùng MFT xác định
                        bao nhiêu không gian được dành riêng cho MFT trên
                        khối lượng.  Nếu tất cả không gian khác đã được sử dụng hết thì
                        Vùng MFT sẽ được thu nhỏ một cách linh hoạt, vì vậy vùng này không có
                        ảnh hưởng đến số lượng không gian trống.  Tuy nhiên, nó
                        có thể có tác động đến hiệu suất bằng cách ảnh hưởng
                        sự phân mảnh của MFT. Nói chung hãy sử dụng
                        mặc định.  Nếu bạn có nhiều tệp nhỏ thì hãy sử dụng
                        một giá trị cao hơn.  Các giá trị có những điều sau đây
                        ý nghĩa:

===== ====================================
                        Kích thước vùng MFT giá trị (% kích thước âm lượng)
                        ===== ====================================
                          1 12,5%
                          2 25%
                          3 37,5%
                          4 50%
                        ===== ====================================

Lưu ý rằng tùy chọn này không liên quan đến chế độ gắn kết chỉ đọc.

preallocated_size=Đặt kích thước được phân bổ trước để tối ưu hóa việc hợp nhất danh sách chạy
                        chi phí chung với kích thước chunkk nhỏ. (Kích thước 64KB bằng
                        mặc định)

acl=<BOOL> Kích hoạt hỗ trợ POSIX ACL. Khi được chỉ định, POSIX
                        ACL được lưu trữ trong các thuộc tính mở rộng được thực thi.
                        Mặc định là tắt. Yêu cầu cấu hình kernel
                        Đã bật NTFS_FS_POSIX_ACL.

sys_immutable=<BOOL> Tạo các tệp hệ thống NTFS (ví dụ: $MFT, $LogFile,
                        $Bitmap, $UpCase, v.v.) không thể thay đổi đối với người dùng bắt đầu
                        sửa đổi để đảm bảo an toàn hơn. Mặc định là tắt.

nohidden=<BOOL> Ẩn các tập tin và thư mục được đánh dấu bằng Windows
                        thuộc tính "ẩn". Theo mặc định các mục ẩn là
                        hiển thị.

Hide_dot_files=<BOOL> Ẩn tên bắt đầu bằng dấu chấm ("."). Theo mặc định
                        tập tin dấu chấm được hiển thị. Khi được bật, các tập tin và
                        các thư mục được tạo bằng dấu '.' ở đầu sẽ được
                        ẩn khỏi danh sách thư mục.

windows_names=<BOOL> Từ chối tạo/đổi tên các tệp có ký tự hoặc
                        tên thiết bị dành riêng không được phép trên Windows (ví dụ:
                        CON, NUL, AUX, COM1, LPT1, v.v.). Mặc định là tắt.
loại bỏ=<BOOL> Vấn đề loại bỏ thiết bị chặn đối với các cụm được giải phóng trên
                        xóa/cắt bớt tập tin để thông báo cơ bản
                        lưu trữ.
=================================================================================