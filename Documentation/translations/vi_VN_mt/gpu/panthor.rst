.. SPDX-License-Identifier: GPL-2.0+

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/gpu/panthor.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
 trình điều khiển drm/Panthor CSF
=========================

.. _panthor-usage-stats:

Triển khai thống kê sử dụng máy khách Panthor DRM
==============================================

Trình điều khiển drm/Panthor triển khai thông số thống kê sử dụng máy khách DRM như
được ghi lại trong ZZ0000ZZ.

Ví dụ về đầu ra hiển thị các cặp giá trị khóa được triển khai và toàn bộ
các tùy chọn định dạng hiện có thể có:

::
     vị trí: 0
     cờ: 02400002
     mnt_id: 29
     vào: 491
     trình điều khiển drm: panhor
     drm-client-id: 10
     drm-động cơ-panthor: 111110952750 ns
     drm-chu kỳ-panthor: 94439687187
     drm-maxfreq-panthor: 1000000000 Hz
     drm-curfreq-panthor: 1000000000 Hz
     bộ nhớ thường trú của panhor: 10396 KiB
     bộ nhớ hoạt động panhor: 10396 KiB
     drm-tổng bộ nhớ: 16480 KiB
     bộ nhớ chia sẻ drm: 0
     bộ nhớ hoạt động drm: 16200 KiB
     drm-cư dân-bộ nhớ: 16480 KiB
     bộ nhớ có thể xóa drm: 0

Tên khóa ZZ0000ZZ có thể có là: ZZ0001ZZ.
Giá trị ZZ0002ZZ truyền tải tần số hoạt động hiện tại của động cơ đó.

Người dùng phải nhớ rằng việc lấy mẫu động cơ và chu trình bị tắt theo mặc định,
vì lo ngại tiết kiệm điện. Người dùng ZZ0000ZZ và các ứng dụng chuẩn
truy vấn tệp fdinfo phải đảm bảo chuyển đổi trạng thái hồ sơ công việc của
trình điều khiển bằng cách ghi vào nút sysfs thích hợp::

echo <N> > /sys/bus/platform/drivers/panthor/[a-f0-9]*.gpu/profiling

Trong đó ZZ0000ZZ là mặt nạ bit trong đó lấy mẫu chu kỳ và dấu thời gian tương ứng
được kích hoạt bởi bit thứ nhất và thứ hai.

Các khóa ZZ0000ZZ có thể có là: ZZ0001ZZ và ZZ0002ZZ.
Các giá trị này truyền tải kích thước của BO shmem do trình điều khiển nội bộ sở hữu
không được tiếp xúc với không gian người dùng thông qua bộ điều khiển DRM, như bộ đệm vòng xếp hàng,
đồng bộ hóa mảng đối tượng và khối heap. Bởi vì chúng đều được phân bổ và ghim
tại thời điểm tạo, chỉ cần có ZZ0003ZZ để cho chúng tôi biết
kích thước. ZZ0004ZZ hiển thị kích thước của kernel BO được liên kết với
Các nhóm và máy ảo hiện đang được GPU lên lịch thực thi.