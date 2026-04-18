.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/admin-guide/acpi/ssdt-overlays.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

==============
Lớp phủ SSDT
=============

Để hỗ trợ các cấu hình phần cứng mở ACPI (ví dụ: phát triển
board), chúng tôi cần một cách để tăng cường cấu hình ACPI do phần sụn cung cấp
hình ảnh. Một ví dụ phổ biến là kết nối các cảm biến trên xe buýt I2C / SPI đang được phát triển
bảng.

Mặc dù điều này có thể được thực hiện bằng cách tạo trình điều khiển nền tảng kernel hoặc
biên dịch lại hình ảnh chương trình cơ sở với các bảng ACPI đã cập nhật, điều này không thực tế:
cái trước tăng sinh mã hạt nhân cụ thể của bo mạch trong khi cái sau yêu cầu
truy cập vào các công cụ phần sụn thường không được cung cấp công khai.

Bởi vì ACPI hỗ trợ các tham chiếu bên ngoài trong mã AML một cách thực tế hơn
cách để tăng cường cấu hình firmware ACPI là tải động
Các bảng SSDT do người dùng xác định có chứa thông tin cụ thể về bảng.

Ví dụ: để liệt kê gia tốc kế Bosch BMA222E trên bus I2C của
Bo mạch phát triển Minnowboard MAX được hiển thị thông qua đầu nối LSE [1],
mã ASL sau đây có thể được sử dụng ::

DefinitionBlock ("minnowmax.aml", "SSDT", 1, "Nhà cung cấp", "Accel", 0x00000003)
    {
        Bên ngoài (\_SB.I2C6, DeviceObj)

Phạm vi (\_SB.I2C6)
        {
            Thiết bị (STAC)
            {
                Tên (_HID, "BMA222E")
                Tên (RBUF, ResourceTemplate ()
                {
                    I2cSerialBus (0x0018, Bộ điều khiển được khởi tạo, 0x00061A80,
                                Địa chỉMode7Bit, "\\_SB.I2C6", 0x00,
                                Người tiêu dùng tài nguyên, ,)
                    GpioInt (Edge, ActiveHigh, Độc quyền, PullDown, 0x0000,
                            "\\_SB.GPO2", 0x00, ResourceConsumer, , )
                    { // Ghim danh sách
                        0
                    }
                })

Phương thức (_CRS, 0, được tuần tự hóa)
                {
                    Trả lại (RBUF)
                }
            }
        }
    }

sau đó có thể được biên dịch sang định dạng nhị phân AML ::

$ iasl minnowmax.asl

Kiến trúc thành phần Intel ACPI
    Phiên bản trình biên dịch tối ưu hóa ASL 20140214-64 [29 tháng 3 năm 2014]
    Bản quyền (c) 2000 - 2014 Tập đoàn Intel

ASL Đầu vào: minnomax.asl - 30 dòng, 614 byte, 7 từ khóa
    AML Đầu ra: minnowmax.aml - 165 byte, 6 đối tượng được đặt tên, 1 opcode thực thi

[1] ZZ0000ZZ

Sau đó, mã AML kết quả có thể được hạt nhân tải bằng một trong các phương thức
bên dưới.

Đang tải SSDT ACPI từ initrd
==============================

Tùy chọn này cho phép tải SSDT do người dùng xác định từ initrd và rất hữu ích
khi hệ thống không hỗ trợ EFI hoặc khi không có đủ bộ nhớ EFI.

Nó hoạt động theo cách tương tự với ghi đè/nâng cấp bảng ACPI dựa trên initrd: SSDT
Mã AML phải được đặt ở vị trí initrd đầu tiên, không nén, bên dưới
đường dẫn "kernel/firmware/acpi". Có thể sử dụng nhiều tệp và điều này sẽ dịch
trong việc tải nhiều bảng. Chỉ cho phép các bảng SSDT và OEM. Xem
initrd_table_override.txt để biết thêm chi tiết.

Đây là một ví dụ::

# Add các bảng ACPI thô vào kho lưu trữ cpio không nén.
    # They phải được đặt vào thư mục /kernel/firmware/acpi bên trong
    Kho lưu trữ # cpio.
    Kho lưu trữ cpio không nén # The phải là kho lưu trữ đầu tiên.
    # Other, kho lưu trữ cpio nén điển hình, phải
    # concatenated nằm trên phần không nén.
    mkdir -p kernel/chương trình cơ sở/acpi
    cp ssdt.aml hạt nhân/chương trình cơ sở/acpi

# Create kho lưu trữ cpio không nén và nối initrd gốc
    Đầu # on:
    tìm hạt nhân | cpio -H newc --create > /boot/instrumented_initrd
    cat /boot/initrd >>/boot/instrumented_initrd

Đang tải SSDT ACPI từ các biến EFI
=====================================

Đây là phương pháp ưa thích khi EFI được hỗ trợ trên nền tảng, vì nó
cho phép một cách lưu trữ SSDT do người dùng xác định một cách liên tục, độc lập với hệ điều hành. Ở đó
cũng đang tiến hành triển khai hỗ trợ EFI để tải SSDT do người dùng xác định
và sử dụng phương pháp này sẽ giúp việc chuyển đổi sang tải EFI dễ dàng hơn
cơ chế khi điều đó sẽ đến. Để kích hoạt nó,
CONFIG_EFI_CUSTOM_SSDT_OVERLAYS nên được chọn là y.

Để tải SSDT từ biến EFI, kernel ZZ0000ZZ
tham số dòng lệnh có thể được sử dụng (tên có giới hạn 16 ký tự).
Đối số cho tùy chọn là tên biến sẽ sử dụng. Nếu có nhiều
các biến có cùng tên nhưng với GUID của nhà cung cấp khác nhau, tất cả chúng sẽ
được tải.

Để lưu trữ mã AML trong biến EFI, hệ thống tệp efivarfs có thể được
đã sử dụng. Nó được bật và gắn theo mặc định trong /sys/firmware/efi/efivars trong tất cả
phân phối gần đây.

Tạo một tệp mới trong /sys/firmware/efi/efivars sẽ tự động tạo một tệp mới
Biến EFI. Cập nhật tệp trong /sys/firmware/efi/efivars sẽ cập nhật EFI
biến. Xin lưu ý rằng tên tệp cần phải được định dạng đặc biệt là
"Name-GUID" và 4 byte đầu tiên trong tệp (định dạng little-endian)
biểu thị các thuộc tính của biến EFI (xem EFI_VARIABLE_MASK trong
bao gồm/linux/efi.h). Việc ghi vào tập tin cũng phải được thực hiện bằng một lần ghi
hoạt động.

Ví dụ: bạn có thể sử dụng tập lệnh bash sau để tạo/cập nhật EFI
biến có nội dung từ một tệp nhất định::

#!/bin/sh -e

trong khi [ -n "$1" ]; làm
            trường hợp "$1" trong
            "-f") tên tệp="$2"; sự thay đổi;;
            "-g") hướng dẫn="$2"; sự thay đổi;;
            *) name="$1";;
            esac
            sự thay đổi
    xong

cách sử dụng()
    {
            echo "Cú pháp: ${0##*/} -f tên tệp [ -g guid ] tên"
            lối ra 1
    }

[ -n "$name" -a -f "$filename" ] || cách sử dụng

EFIVARFS="/sys/firmware/efi/efivars"

[ -d "$EFIVARFS" ] || lối ra 2

nếu stat -tf $EFIVARFS | grep -q -v de5e81e4; sau đó
            mount -t efivarfs none $EFIVARFS
    fi

# try để nhận GUID hiện có
    [ -n "$guid" ] |ZZ0000ZZ đầu -n1 | cắt -f2- -d-)

# use một GUID được tạo ngẫu nhiên
    [ -n "$ hướng dẫn" ] || guid="$(cat /proc/sys/kernel/random/uuid)"

# efivarfs mong đợi tất cả dữ liệu trong một lần ghi
    tmp=$(mktemp)
    /bin/echo -ne "\007\000\000\000" | con mèo - tên tệp $ > $ tmp
    dd if=$tmp of="$EFIVARFS/$name-$guid" bs=$(stat -c %s $tmp)
    rm $tmp

Đang tải SSDT ACPI từ configfs
================================

Tùy chọn này cho phép tải SSDT do người dùng xác định từ không gian người dùng thông qua configfs
giao diện. Tùy chọn CONFIG_ACPI_CONFIGFS phải được chọn và cấu hình phải được
gắn kết. Trong các ví dụ sau, chúng tôi giả sử rằng configfs đã được gắn vào
/sys/kernel/config.

Các bảng mới có thể được tải bằng cách tạo các thư mục mới trong /sys/kernel/config/acpi/table
và viết mã SSDT AML trong thuộc tính aml ::

cd /sys/kernel/config/acpi/bảng
    mkdir my_ssdt
    mèo ~/ssdt.aml > my_ssdt/aml