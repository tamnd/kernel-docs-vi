.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/arch/riscv/hwprobe.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Giao diện thăm dò phần cứng RISC-V
----------------------------------

Giao diện thăm dò phần cứng RISC-V dựa trên một tòa nhà chung cư duy nhất,
được định nghĩa trong <asm/hwprobe.h>::

cấu trúc riscv_hwprobe {
        phím __s64;
        giá trị __u64;
    };

sys_riscv_hwprobe dài (struct riscv_hwprobe *cặp, size_t pair_count,
                           kích thước_t cpusetsize, cpu_set_t *cpus,
                           cờ int không dấu);

Các đối số được chia thành ba nhóm: một mảng các cặp khóa-giá trị, CPU
thiết lập, và một số lá cờ. Các cặp khóa-giá trị được cung cấp cùng với số lượng. Không gian người dùng
phải điền trước trường khóa cho mỗi phần tử và kernel sẽ điền vào
giá trị nếu khóa được nhận dạng. Nếu một khóa không được biết đến trong hạt nhân thì trường khóa của nó
sẽ bị xóa thành -1 và giá trị của nó được đặt thành 0. Bộ CPU được xác định bởi
CPU_SET(3) với kích thước byte ZZ0000ZZ. Đối với các khóa giống giá trị (ví dụ: nhà cung cấp,
Arch, impl), giá trị trả về sẽ chỉ hợp lệ nếu tất cả CPU trong tập hợp đã cho
có cùng giá trị. Ngược lại -1 sẽ được trả về. Đối với các khóa giống như boolean,
giá trị được trả về sẽ là AND logic của các giá trị cho CPU được chỉ định.
Usermode có thể cung cấp NULL cho ZZ0001ZZ và 0 cho ZZ0002ZZ làm phím tắt cho
tất cả các CPU trực tuyến. Các cờ hiện được hỗ trợ là:

* ZZ0000ZZ: Cờ này về cơ bản đảo ngược hành vi
  của sys_riscv_hwprobe().  Thay vì điền các giá trị của các khóa cho một
  bộ CPU, các giá trị của từng khóa được đưa ra và bộ CPU bị giảm
  bởi sys_riscv_hwprobe() để chỉ những cặp khớp với từng cặp khóa-giá trị.
  Việc khớp được thực hiện như thế nào tùy thuộc vào loại khóa.  Đối với các khóa giống giá trị, việc khớp
  có nghĩa là hoàn toàn giống với giá trị.  Đối với các khóa giống như boolean, việc khớp
  có nghĩa là kết quả của AND logic của giá trị của cặp với giá trị của CPU là
  hoàn toàn giống với giá trị của cặp.  Ngoài ra, khi ZZ0001ZZ trống
  được thiết lập, thì nó sẽ được khởi tạo cho tất cả các CPU trực tuyến phù hợp với nó, tức là
  Bộ CPU được trả về là việc giảm tất cả các CPU trực tuyến có thể
  được biểu thị bằng bộ CPU có kích thước ZZ0002ZZ.

Tất cả các cờ khác được dành riêng cho khả năng tương thích trong tương lai và phải bằng 0.

Khi thành công sẽ trả về 0, nếu thất bại sẽ trả về mã lỗi âm.

Các khóa sau được xác định:

* ZZ0000ZZ: Chứa giá trị của ZZ0001ZZ,
  như được xác định bởi đặc tả kiến trúc đặc quyền RISC-V.

* ZZ0000ZZ: Chứa giá trị của ZZ0001ZZ, như
  được xác định bởi đặc tả kiến trúc đặc quyền RISC-V.

* ZZ0000ZZ: Chứa giá trị của ZZ0001ZZ, như
  được xác định bởi đặc tả kiến trúc đặc quyền RISC-V.

* ZZ0000ZZ: Một bitmask chứa đế
  hành vi mà người dùng có thể nhìn thấy mà hạt nhân này hỗ trợ.  ABI của người dùng cơ sở sau đây
  được định nghĩa:

* ZZ0000ZZ: Hỗ trợ rv32ima hoặc
    rv64ima, như được xác định bởi phiên bản 2.2 của người dùng ISA và phiên bản 1.10 của
    ISA đặc quyền, với các ngoại lệ đã biết sau đây (có thể có nhiều ngoại lệ hơn
    đã thêm, nhưng chỉ khi có thể chứng minh được rằng người dùng ABI không bị hỏng):

* Lệnh ZZ0000ZZ không thể được thực thi trực tiếp bởi không gian người dùng
      chương trình (nó vẫn có thể được thực thi trong không gian người dùng thông qua
      cơ chế kiểm soát hạt nhân như vDSO).

* ZZ0000ZZ: Một bitmask chứa các phần mở rộng
  tương thích với ZZ0001ZZ:
  hành vi của hệ thống cơ sở

* ZZ0000ZZ: Phần mở rộng F và D được hỗ trợ, như
    được xác định bởi cam kết cd20cee ("FMIN/FMAX hiện đang triển khai
    Số tối thiểu/Số tối đa, không phải số tối thiểu/số tối đa") của hướng dẫn sử dụng RISC-V ISA.

* ZZ0000ZZ: Phần mở rộng C được hỗ trợ, như đã xác định
    theo phiên bản 2.2 của sách hướng dẫn RISC-V ISA.

* ZZ0000ZZ: Phần mở rộng V được hỗ trợ, như được xác định bởi
    phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Phần mở rộng tạo địa chỉ Zba là
       được hỗ trợ, như được định nghĩa trong phiên bản 1.0 của ISA thao tác bit
       phần mở rộng.

* ZZ0000ZZ: Phần mở rộng Zbb được hỗ trợ, như được xác định
       trong phiên bản 1.0 của tiện ích mở rộng ISA thao tác bit.

* ZZ0000ZZ: Phần mở rộng Zbs được hỗ trợ, như đã xác định
       trong phiên bản 1.0 của tiện ích mở rộng ISA thao tác bit.

* ZZ0000ZZ: Tiện ích mở rộng Zicboz được hỗ trợ, như
       được phê chuẩn trong cam kết 3dd606f ("Tạo cmobase-v1.0.pdf") của riscv-CMO.

* ZZ0000ZZ Phần mở rộng Zbc được hỗ trợ, như được xác định
       trong phiên bản 1.0 của tiện ích mở rộng ISA thao tác bit.

* ZZ0000ZZ Phần mở rộng Zbkb được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zbkc được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zbkx được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zknd được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zkne được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zknh được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zksed được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zksh được hỗ trợ, như
       được xác định trong phiên bản 1.0 của phần mở rộng Scalar Crypto ISA.

* ZZ0000ZZ Phần mở rộng Zkt được hỗ trợ, như được xác định
       trong phiên bản 1.0 của tiện ích mở rộng Scalar Crypto ISA.

* ZZ0000ZZ: Tiện ích mở rộng Zvbb được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Phần mở rộng Zvbc được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvkb được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvkg được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvkned được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvknha được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvknhb được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvksed được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvksh được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Tiện ích mở rộng Zvkt được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của Phần mở rộng mật mã RISC-V Tập II.

* ZZ0000ZZ: Phiên bản mở rộng Zfh 1.0 được hỗ trợ
       như được định nghĩa trong sách hướng dẫn RISC-V ISA.

* ZZ0000ZZ: Phiên bản mở rộng Zfhmin 1.0 là
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA.

* ZZ0000ZZ: Phiên bản mở rộng Zihintntl 1.0
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA.

* ZZ0000ZZ: Tiện ích mở rộng Zvfh được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V Vector bắt đầu từ cam kết e2ccd0548d6c
       ("Xóa cảnh báo dự thảo khỏi Zvfh[min]").

* ZZ0000ZZ: Tiện ích mở rộng Zvfhmin được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V Vector bắt đầu từ cam kết e2ccd0548d6c
       ("Xóa cảnh báo dự thảo khỏi Zvfh[min]").

* ZZ0000ZZ: Tiện ích mở rộng Zfa được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết 056b6ff467c7
       ("Zfa được phê chuẩn").

* ZZ0000ZZ: Tiện ích mở rộng Ztso được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết 5618fb5a216b
       ("Ztso hiện đã được phê chuẩn.")

* ZZ0000ZZ: Tiện ích mở rộng Zacas được hỗ trợ dưới dạng
       được xác định trong hướng dẫn khởi động Hướng dẫn so sánh và hoán đổi nguyên tử (CAS)
       từ cam kết 5059e0ca641c ("cập nhật để phê chuẩn").

* ZZ0000ZZ: Phiên bản mở rộng Zicntr 2.0
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA.

* ZZ0000ZZ: Tiện ích mở rộng Zicond được hỗ trợ dưới dạng
       được xác định trong phần mở rộng hoạt động Số nguyên có điều kiện (Zicond) của RISC-V
       hướng dẫn sử dụng bắt đầu từ cam kết 95cf1f9 ("Thêm các thay đổi được yêu cầu bởi Ved
       trong quá trình ký kết")

* ZZ0000ZZ: Tiện ích mở rộng Zihintpause là
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết
       d8ab5c78c207 ("Zihintpause được phê chuẩn").

* ZZ0000ZZ: Phiên bản mở rộng Zihpm 2.0
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA.

* ZZ0000ZZ: Phần mở rộng phụ Vector Zve32x là
    được hỗ trợ, như được xác định bởi phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Phần mở rộng phụ Vector Zve32f là
    được hỗ trợ, như được xác định bởi phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Phần mở rộng phụ Vector Zve64x là
    được hỗ trợ, như được xác định bởi phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Phần mở rộng phụ Vector Zve64f là
    được hỗ trợ, như được xác định bởi phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Phần mở rộng phụ Vector Zve64d là
    được hỗ trợ, như được xác định bởi phiên bản 1.0 của hướng dẫn sử dụng tiện ích mở rộng Vector RISC-V.

* ZZ0000ZZ: Tiện ích mở rộng Zimop May-Be-Operations là
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết
       58220614a5f ("Zimop được phê chuẩn/1.0").

* ZZ0000ZZ: Phần mở rộng Zca của tiêu chuẩn Zc*
       các tiện ích mở rộng để giảm kích thước mã, như được phê chuẩn trong cam kết 8be3419c1c0
       ("Zcf không tồn tại trên RV64 vì nó không chứa hướng dẫn") của
       giảm kích thước mã riscv.

* ZZ0000ZZ: Phần mở rộng Zcb của tiêu chuẩn Zc*
       các tiện ích mở rộng để giảm kích thước mã, như được phê chuẩn trong cam kết 8be3419c1c0
       ("Zcf không tồn tại trên RV64 vì nó không chứa hướng dẫn") của
       giảm kích thước mã riscv.

* ZZ0000ZZ: Phần mở rộng Zcd của chuẩn Zc*
       các tiện ích mở rộng để giảm kích thước mã, như được phê chuẩn trong cam kết 8be3419c1c0
       ("Zcf không tồn tại trên RV64 vì nó không chứa hướng dẫn") của
       giảm kích thước mã riscv.

* ZZ0000ZZ: Phần mở rộng Zcf của chuẩn Zc*
       các tiện ích mở rộng để giảm kích thước mã, như được phê chuẩn trong cam kết 8be3419c1c0
       ("Zcf không tồn tại trên RV64 vì nó không chứa hướng dẫn") của
       giảm kích thước mã riscv.

* ZZ0000ZZ: Phần mở rộng hoạt động có thể hoạt động của Zcmop là
       được hỗ trợ như được định nghĩa trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết
       c732a4f39a4 ("Zcmop được phê chuẩn/1.0").

* ZZ0000ZZ: Tiện ích mở rộng Zawrs được hỗ trợ dưới dạng
       được phê chuẩn trong cam kết 98918c844281 ("Hợp nhất yêu cầu kéo #1217 từ
       riscv/zawrs") của riscv-isa-manual.

* ZZ0000ZZ: Tiện ích mở rộng Zaamo được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết e87412e621f1
       ("tích hợp văn bản Zaamo và Zalrsc (#1304)").

* ZZ0000ZZ: Tiện ích mở rộng Zalasr được hỗ trợ dưới dạng
       bị đóng băng tại cam kết 194f0094 ("Phiên bản 0.9 để đóng băng") của riscv-zalasr.

* ZZ0000ZZ: Tiện ích mở rộng Zalrsc được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết e87412e621f1
       ("tích hợp văn bản Zaamo và Zalrsc (#1304)").

* ZZ0000ZZ: Tiện ích mở rộng Supm được hỗ trợ dưới dạng
       được xác định trong phiên bản 1.0 của phần mở rộng Mặt nạ con trỏ RISC-V.

* ZZ0000ZZ: Tiện ích mở rộng Zfbfmin được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết 4dc23d6229de
       ("Đã thêm tiêu đề Chương vào BF16").

* ZZ0000ZZ: Tiện ích mở rộng Zvfbfmin được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết 4dc23d6229de
       ("Đã thêm tiêu đề Chương vào BF16").

* ZZ0000ZZ: Tiện ích mở rộng Zvfbfwma được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết 4dc23d6229de
       ("Đã thêm tiêu đề Chương vào BF16").

* ZZ0000ZZ: Tiện ích mở rộng Zicbom được hỗ trợ, như
       được phê chuẩn trong cam kết 3dd606f ("Tạo cmobase-v1.0.pdf") của riscv-CMO.

* ZZ0000ZZ: Tiện ích mở rộng Zabha được hỗ trợ dưới dạng
       được phê chuẩn trong cam kết 49f49c842ff9 ("Cập nhật lên trạng thái đã được phê chuẩn") của
       riscv-zabha.

* ZZ0000ZZ: Tiện ích mở rộng Zicbop được hỗ trợ, như
       được phê chuẩn trong cam kết 3dd606f ("Tạo cmobase-v1.0.pdf") của riscv-CMO.

* ZZ0000ZZ: Tiện ích mở rộng Zilsd được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết f88abf1 ("Tích hợp
       cặp tải/lưu trữ cho RV32 với hướng dẫn chính") của hướng dẫn sử dụng riscv-isa.

* ZZ0000ZZ: Tiện ích mở rộng Zclsd được hỗ trợ dưới dạng
       được xác định trong hướng dẫn sử dụng RISC-V ISA bắt đầu từ cam kết f88abf1 ("Tích hợp
       cặp tải/lưu trữ cho RV32 với hướng dẫn chính") của hướng dẫn sử dụng riscv-isa.

* ZZ0000ZZ: Không được dùng nữa.  Trả về các giá trị tương tự cho
     ZZ0001ZZ, nhưng chìa khóa là
     bị phân loại nhầm thành mặt nạ bit thay vì giá trị.

* ZZ0000ZZ: Một giá trị enum mô tả
  hiệu suất của các truy cập từ gốc vô hướng không được căn chỉnh trên tập hợp đã chọn
  của các bộ vi xử lý.

* ZZ0000ZZ: Hiệu suất của
    truy cập vô hướng sai lệch là không xác định.

* ZZ0000ZZ: Vô hướng lệch
    quyền truy cập được mô phỏng thông qua phần mềm, trong hoặc bên dưới kernel.  Những cái này
    truy cập luôn cực kỳ chậm.

* ZZ0000ZZ: gốc vô hướng không thẳng hàng
    truy cập có kích thước từ chậm hơn số lượng byte tương đương
    truy cập. Các quyền truy cập không được căn chỉnh có thể được hỗ trợ trực tiếp trong phần cứng hoặc
    bị mắc kẹt và mô phỏng bởi phần mềm.

* ZZ0000ZZ: gốc vô hướng không thẳng hàng
    truy cập có kích thước từ nhanh hơn số lượng byte tương đương
    truy cập.

* ZZ0000ZZ: Vô hướng lệch
    quyền truy cập hoàn toàn không được hỗ trợ và sẽ tạo ra một địa chỉ sai lệch
    lỗi.

* ZZ0000ZZ: Một int không dấu
  đại diện cho kích thước của khối Zicboz tính bằng byte.

* ZZ0000ZZ: Dài không dấu
  đại diện cho địa chỉ ảo không gian người dùng cao nhất có thể sử dụng được.

* ZZ0000ZZ: Tần số (tính bằng Hz) của ZZ0001ZZ.

* ZZ0000ZZ: Một giá trị enum mô tả
     hiệu suất truy cập vectơ không thẳng hàng trên bộ bộ xử lý đã chọn.

* ZZ0000ZZ: Hiệu suất điều chỉnh sai
    truy cập vector là không rõ.

* ZZ0000ZZ: Truy cập sai lệch 32 bit bằng vectơ
    các thanh ghi chậm hơn so với số lượng truy cập byte tương đương thông qua các thanh ghi vectơ.
    Các quyền truy cập sai có thể được hỗ trợ trực tiếp trong phần cứng hoặc bị bẫy và mô phỏng bởi phần mềm.

* ZZ0000ZZ: Truy cập sai lệch 32 bit bằng vectơ
    các thanh ghi nhanh hơn số lượng truy cập byte tương đương thông qua các thanh ghi vectơ.

* ZZ0000ZZ: Truy cập vectơ không thẳng hàng
    hoàn toàn không được hỗ trợ và sẽ tạo ra lỗi địa chỉ sai.

* ZZ0000ZZ: Một bitmask chứa
  tiện ích mở rộng của nhà cung cấp mips tương thích với
  ZZ0001ZZ: hành vi hệ thống cơ bản.

* MIPS

* ZZ0000ZZ: Nhà cung cấp xmipsexectl
        tiện ích mở rộng được hỗ trợ trong thông số tiện ích mở rộng MIPS ISA.

* ZZ0000ZZ: Một bitmask chứa
  các tiện ích mở rộng của nhà cung cấp quảng cáo tương thích với
  ZZ0001ZZ: hành vi hệ thống cơ bản.

* T-HEAD

* ZZ0000ZZ: Nhà cung cấp xtheadvector
        tiện ích mở rộng được hỗ trợ trong thông số tiện ích mở rộng T-Head ISA bắt đầu từ
	cam kết a18c801634 ("Thêm tiện ích mở rộng nhà cung cấp T-Head VECTOR.").

* ZZ0000ZZ: Một int không dấu
  đại diện cho kích thước của khối Zicbom tính bằng byte.

* ZZ0000ZZ: Một bitmask chứa
  năm phần mở rộng của nhà cung cấp tương thích với
  ZZ0001ZZ: hành vi hệ thống cơ bản.

* SIFIVE

* ZZ0000ZZ: Nhà cung cấp Xsfqmaccdod
        tiện ích mở rộng được hỗ trợ trong phiên bản 1.1 của Phép nhân ma trận SiFive Int8
	Đặc tả phần mở rộng.

* ZZ0000ZZ: Nhà cung cấp Xsfqmaccqoq
        tiện ích mở rộng được hỗ trợ trong phiên bản 1.1 của Phép nhân ma trận SiFive Int8
	Đặc tả phần mở rộng hướng dẫn.

* ZZ0000ZZ: Xsfvfnrclipxfqf
        tiện ích mở rộng nhà cung cấp được hỗ trợ trong phiên bản 1.0 của SiFive FP32-to-int8 Ranged
	Clip Hướng dẫn Đặc tả Tiện ích mở rộng.

* ZZ0000ZZ: Xsfvfwmaccqqq
        tiện ích mở rộng nhà cung cấp được hỗ trợ trong phiên bản 1.0 của Tích lũy nhân ma trận
	Đặc tả phần mở rộng hướng dẫn.

* ZZ0000ZZ: Một int không dấu
  đại diện cho kích thước của khối Zicbop tính bằng byte.

* ZZ0000ZZ: Một bitmask chứa bổ sung
  các tiện ích mở rộng tương thích với
  ZZ0001ZZ: hành vi hệ thống cơ bản.