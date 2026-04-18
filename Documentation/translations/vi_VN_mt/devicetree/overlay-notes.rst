.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/devicetree/overlay-notes.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

===========================
Ghi chú lớp phủ Devicetree
===========================

Tài liệu này mô tả việc triển khai trong kernel
chức năng lớp phủ cây thiết bị nằm trong driver/of/overlay.c và là một
tài liệu đi kèm với Documentation/devicetree/dynamic-solution-notes.rst[1]

Cách lớp phủ hoạt động
----------------------

Mục đích lớp phủ của Devicetree là sửa đổi cây sống của kernel và
có sự sửa đổi ảnh hưởng đến trạng thái của kernel theo cách
đang phản ánh những thay đổi.
Vì hạt nhân chủ yếu xử lý các thiết bị nên bất kỳ nút thiết bị mới nào có kết quả
trong một thiết bị đang hoạt động phải được tạo trong khi nếu nút thiết bị là
bị vô hiệu hóa hoặc xóa tất cả, thiết bị bị ảnh hưởng sẽ bị hủy đăng ký.

Hãy lấy một ví dụ trong đó chúng ta có một bảng foo với cây cơ sở sau::

---- foo.dts --------------------------------------------------------
	/* Nền tảng FOO */
	/dts-v1/;
	/ {
		tương thích = "corp,foo";

/*tài nguyên được chia sẻ */
		độ phân giải: độ phân giải {
		};

/* Trên các thiết bị ngoại vi của chip */
		ocp: ocp {
			/* các thiết bị ngoại vi luôn được khởi tạo */
			ngoại vi1 { ... };
		};
	};
    ---- foo.dts --------------------------------------------------------

Thanh lớp phủ.dtso,
:::::::::::::::::::

---- bar.dtso - xếp chồng vị trí mục tiêu theo nhãn --------------------------
	/dts-v1/;
	/plugin/;
	&ocp {
		/* thanh ngoại vi */
		thanh {
			tương thích = "corp,bar";
			... /* various properties and child nodes */
};
	};
    ---- bar.dtso --------------------------------------------------------------

khi được tải (và được giải quyết như mô tả trong [1]) sẽ dẫn đến foo+bar.dts::

---- foo+bar.dts ----------------------------------------------------------
	/* Nền tảng FOO + thanh ngoại vi */
	/ {
		tương thích = "corp,foo";

/*tài nguyên được chia sẻ */
		độ phân giải: độ phân giải {
		};

/* Trên các thiết bị ngoại vi của chip */
		ocp: ocp {
			/* các thiết bị ngoại vi luôn được khởi tạo */
			ngoại vi1 { ... };

/* thanh ngoại vi */
			thanh {
				tương thích = "corp,bar";
				... /* various properties and child nodes */
};
		};
	};
    ---- foo+bar.dts ----------------------------------------------------------

Nhờ lớp phủ, một nút (thanh) thiết bị mới đã được tạo
do đó, thiết bị nền tảng thanh sẽ được đăng ký và nếu trình điều khiển thiết bị phù hợp
được tải, thiết bị sẽ được tạo như mong đợi.

Nếu DT cơ sở không được biên dịch bằng tùy chọn -@ thì nhãn "&ocp"
sẽ không có sẵn để phân giải (các) nút lớp phủ đến vị trí thích hợp
ở cơ sở DT. Trong trường hợp này, đường dẫn đích có thể được cung cấp. mục tiêu
cú pháp vị trí theo nhãn được ưa thích hơn vì lớp phủ có thể được áp dụng cho
bất kỳ DT cơ sở nào chứa nhãn, bất kể nhãn xuất hiện ở đâu trong DT.

Ví dụ bar.dtso ở trên được sửa đổi để sử dụng cú pháp đường dẫn đích là::

---- bar.dtso - che phủ vị trí mục tiêu theo đường dẫn rõ ràng -------------------
	/dts-v1/;
	/plugin/;
	&{/ocp} {
		/* thanh ngoại vi */
		thanh {
			tương thích = "corp,bar";
			... /* various properties and child nodes */
}
	};
    ---- bar.dtso --------------------------------------------------------------


Lớp phủ trong hạt nhân API
--------------------------------

API khá dễ sử dụng.

1) Gọi of_overlay_fdt_apply() để tạo và áp dụng bộ thay đổi lớp phủ. các
   giá trị trả về là lỗi hoặc cookie xác định lớp phủ này.

2) Gọi of_overlay_remove() để xóa và dọn dẹp bộ thay đổi lớp phủ
   được tạo trước đó thông qua lệnh gọi of_overlay_fdt_apply(). Loại bỏ một
   Bộ thay đổi lớp phủ được xếp chồng lên nhau sẽ không được phép.

Cuối cùng, nếu bạn cần xóa tất cả các lớp phủ trong một lần, chỉ cần gọi
of_overlay_remove_all() sẽ loại bỏ từng cái một cách chính xác
đặt hàng.

Có tùy chọn đăng ký người thông báo được gọi
hoạt động lớp phủ. Xem of_overlay_notifier_register/unregister và
enum of_overlay_notify_action để biết chi tiết.

Lệnh gọi lại của trình thông báo cho OF_OVERLAY_PRE_APPLY, OF_OVERLAY_POST_APPLY hoặc
OF_OVERLAY_PRE_REMOVE có thể lưu trữ con trỏ tới nút cây thiết bị trong lớp phủ
hoặc nội dung của nó nhưng những con trỏ này không được tồn tại qua lệnh gọi lại của trình thông báo
cho OF_OVERLAY_POST_REMOVE.  Bộ nhớ chứa lớp phủ sẽ được
kfree()ed sau khi trình thông báo OF_OVERLAY_POST_REMOVE được gọi.  Lưu ý rằng
bộ nhớ sẽ được kfree()ed ngay cả khi trình thông báo cho OF_OVERLAY_POST_REMOVE
trả về một lỗi.

Các thông báo thay đổi trong driver/of/dynamic.c là loại thông báo thứ hai
có thể được kích hoạt bằng cách áp dụng hoặc loại bỏ lớp phủ.  Những trình thông báo này
không được phép lưu trữ con trỏ tới nút cây thiết bị trong lớp phủ
hoặc nội dung của nó.  Mã lớp phủ không bảo vệ khỏi các con trỏ như vậy
kết quả là vẫn hoạt động khi bộ nhớ chứa lớp phủ được giải phóng
of removing the overlay.

Bất kỳ mã nào khác giữ lại một con trỏ tới các nút hoặc dữ liệu lớp phủ đều được
được coi là một lỗi vì sau khi loại bỏ lớp phủ con trỏ
sẽ đề cập đến bộ nhớ được giải phóng.

Người sử dụng lớp phủ phải đặc biệt nhận thức được các hoạt động tổng thể
xảy ra trên hệ thống để đảm bảo rằng mã kernel khác không giữ lại bất kỳ
con trỏ tới các nút hoặc dữ liệu lớp phủ.  Bất kỳ ví dụ nào về việc sử dụng vô ý
của các con trỏ như vậy là nếu một trình điều khiển hoặc mô-đun hệ thống con được tải sau một
lớp phủ đã được áp dụng và trình điều khiển hoặc hệ thống con sẽ quét toàn bộ
devicetree hoặc một phần lớn của nó, bao gồm cả các nút lớp phủ.