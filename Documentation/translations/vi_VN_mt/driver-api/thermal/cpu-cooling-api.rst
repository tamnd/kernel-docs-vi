.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/driver-api/thermal/cpu-cooling-api.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==========================
API làm mát CPU Cách thực hiện
=======================

Viết bởi Amit Daniel Kachhap <amit.kachhap@linaro.org>

Cập nhật: ngày 6 tháng 1 năm 2015

Bản quyền (c) 2012 Samsung Electronics Co., Ltd(ZZ0000ZZ

0. Giới thiệu
===============

Tính năng làm mát CPU chung (cắt tần số) cung cấp các API đăng ký/hủy đăng ký
tới người gọi. Sự ràng buộc của các thiết bị làm mát với điểm dừng được để lại
người dùng. API đăng ký trả về con trỏ thiết bị làm mát.

1. API làm mát CPU
===================

1.1 API đăng ký/hủy đăng ký cpufreq
--------------------------------------------

    ::

cấu trúc Thermal_cooling_device
	*cpufreq_cooling_register(struct cpumask *clip_cpus)

Chức năng giao diện này đăng ký thiết bị làm mát cpufreq với tên
    "nhiệt-cpufreq-%x". API này có thể hỗ trợ nhiều phiên bản của cpufreq
    các thiết bị làm mát.

clip_cpus:
	cpumask của cpu nơi các hạn chế về tần số sẽ xảy ra.

    ::

cấu trúc Thermal_cooling_device
	Chính sách *of_cpufreq_cooling_register(struct cpufreq_policy *)

Chức năng giao diện này đăng ký thiết bị làm mát cpufreq với
    tên "thermal-cpufreq-%x" liên kết nó với nút cây thiết bị, trong
    để liên kết nó thông qua mã DT nhiệt. API này có thể hỗ trợ nhiều
    phiên bản của thiết bị làm mát cpufreq.

chính sách:
	Chính sách CPUFreq


    ::

void cpufreq_cooling_unregister(struct Thermal_cooling_device *cdev)

Chức năng giao diện này hủy đăng ký thiết bị làm mát "thermal-cpufreq-%x".

cdev: Con trỏ thiết bị làm mát phải được hủy đăng ký.

2. Mô hình điện
===============

Các chức năng đăng ký sức mạnh API cung cấp một mô hình sức mạnh đơn giản cho
CPU.  Công suất hiện tại được tính là công suất động (công suất tĩnh không
được hỗ trợ hiện tại).  Mô hình năng lượng này yêu cầu các điểm vận hành của
các CPU được đăng ký bằng thư viện opp của kernel và
ZZ0000ZZ được gán cho ZZ0001ZZ của
cpu.  Nếu bạn đang sử dụng CONFIG_CPUFREQ_DT thì
ZZ0002ZZ đã được gán cho CPU
thiết bị.

Mức tiêu thụ năng lượng động của bộ xử lý phụ thuộc vào nhiều yếu tố.
Đối với việc triển khai bộ xử lý nhất định, các yếu tố chính là:

- Thời gian bộ xử lý dành để chạy, tiêu thụ năng lượng động, như
  so với thời gian ở trạng thái nhàn rỗi nơi mức tiêu thụ năng động
  không đáng kể.  Ở đây chúng tôi gọi điều này là 'việc sử dụng'.
- Các mức điện áp và tần số là kết quả của DVFS.  DVFS
  mức là yếu tố chi phối chi phối mức tiêu thụ điện năng.
- Trong thời gian chạy, hành vi 'thực thi' (loại lệnh, bộ nhớ
  các mẫu truy cập, v.v.), trong hầu hết các trường hợp, gây ra lệnh thứ hai
  biến thể.  Trong các trường hợp bệnh lý, sự thay đổi này có thể rất đáng kể,
  nhưng thông thường nó có tác động ít hơn nhiều so với các yếu tố trên.

Khi đó, mô hình tiêu thụ năng lượng động ở mức cao có thể được biểu diễn dưới dạng::

Pdyn = f(chạy) * Điện áp^2 * Tần số * Mức sử dụng

f(run) ở đây thể hiện hành vi thực thi được mô tả và
kết quả có đơn vị là Watts/Hz/Volt^2 (điều này thường được biểu thị bằng
mW/MHz/uVolt^2)

Hành vi chi tiết của f(run) có thể được mô hình hóa trực tuyến.  Tuy nhiên,
trong thực tế, mô hình trực tuyến như vậy phụ thuộc vào một số
triển khai hỗ trợ và đặc tính bộ xử lý cụ thể
các yếu tố.  Vì vậy, trong quá trình triển khai ban đầu sự đóng góp đó là
được biểu diễn dưới dạng hệ số không đổi.  Đây là một sự đơn giản hóa
phù hợp với sự đóng góp tương đối vào sự thay đổi công suất tổng thể.

Trong cách trình bày đơn giản hóa này, mô hình của chúng tôi trở thành::

Pdyn = Điện dung * Điện áp^2 * Tần số * Công suất sử dụng

Trong đó ZZ0000ZZ là hằng số đại diện cho giá trị biểu thị
hệ số công suất động thời gian chạy tính bằng đơn vị cơ bản của
mW/MHz/uVolt^2.  Các giá trị tiêu biểu cho CPU di động có thể nằm trong phạm vi
từ 100 đến 500. Để tham khảo, các giá trị gần đúng cho SoC trong
Nền tảng phát triển Juno của ARM là 530 cho cụm Cortex-A57 và
140 cho cụm Cortex-A53.
