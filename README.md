# kernel-docs-vi

Bản dịch tiếng Việt cho Linux kernel documentation. Nội dung gốc là thư
mục `Documentation/` trong
[torvalds/linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git).
Bản dịch được đặt tại `Documentation/translations/vi_VN/`, theo đúng
quy ước đường dẫn mà kernel đã dành cho các ngôn ngữ khác (zh_CN,
ja_JP, it_IT, ko_KR, sp_SP, pt_BR, zh_TW).

Dự án đang ở giai đoạn đầu và tỷ lệ coverage còn rất thấp. Mọi đóng
góp được chào đón qua pull request; quy trình chi tiết nằm trong
[CONTRIBUTING.md](CONTRIBUTING.md).

## Phiên bản upstream hiện tại

File `UPSTREAM` ở gốc repo ghi lại thông tin về thời điểm đồng bộ gần
nhất, bao gồm ref, commit SHA và commit date. File này được cập nhật
tự động bởi các script trong `scripts/` và không nên chỉnh sửa thủ
công.

## Cấu trúc repo

```
.
├── COPYING                  license của kernel, copy nguyên từ upstream
├── LICENSE                  GPL-2.0 full text (từ LICENSES/preferred/GPL-2.0)
├── LICENSES/                toàn bộ thư mục SPDX license của kernel
├── UPSTREAM                 thông tin ref, SHA, commit date của bản sync
├── Documentation/           mirror của Documentation/ upstream
│   └── translations/
│       ├── zh_CN/ ja_JP/ it_IT/ ko_KR/ sp_SP/ pt_BR/ zh_TW/
│       └── vi_VN/           bản dịch tiếng Việt
├── ROADMAP.md               định hướng phát triển dự án
├── CONTRIBUTING.md          quy tắc đóng góp
├── TRANSLATION_STATUS.md    báo cáo tiến độ dịch, sinh tự động
├── TRANSLATORS              danh sách người đóng góp
└── scripts/                 init, sync, diff, translation-status, lib/common.sh
```

Lý do đặt `vi_VN/` trong `Documentation/translations/` thay vì ở
thư mục ngoài: kernel đã quy ước đường dẫn này cho các bản dịch. Tuân
thủ quy ước đem lại hai lợi ích cụ thể. Thứ nhất, `make htmldocs` của
kernel tự động nhận diện và build bản dịch mà không cần cấu hình
thêm. Thứ hai, khi muốn gửi patch đóng góp ngược lên LKML, cấu trúc
thư mục sẽ không cần điều chỉnh.

## Script

Toàn bộ công cụ đồng bộ upstream và báo cáo tiến độ được đặt trong
thư mục `scripts/`.

### Báo cáo tiến độ

```sh
scripts/translation-status.sh
```

Sinh file `TRANSLATION_STATUS.md` ở gốc repo. Báo cáo liệt kê toàn bộ
file `.rst`, `.txt`, `.md` trong `Documentation/` (ngoại trừ các
thư mục bản dịch), kèm trạng thái cho biết mỗi file đã có bản tiếng
Việt tương ứng hay chưa.

### Đồng bộ upstream

```sh
scripts/diff-upstream.sh           # preview, không thay đổi working tree
scripts/sync-upstream.sh           # apply thay đổi thực tế
scripts/sync-upstream.sh v6.15     # đồng bộ tới một tag cụ thể
```

Cả ba script áp dụng cùng một cơ chế fetch tối ưu để tránh clone toàn
bộ kernel tree (khoảng 1.5 GB):

1. `git clone --depth=1 --filter=blob:none --no-checkout` fetch tối
   thiểu cần thiết.
2. `git sparse-checkout set Documentation LICENSES COPYING` giới hạn
   working tree về các path cần thiết.
3. Kết quả: lưu lượng mạng khoảng 60 MB thay cho 1.5 GB của full clone.

Trong quá trình sync, script bảo toàn nội dung của
`Documentation/translations/vi_VN/`. Các bản dịch ngôn ngữ khác (zh_CN,
ja_JP, và các bản khác) được đồng bộ theo upstream vì đó là phần
thuộc kernel, không thuộc phạm vi của dự án này.

## Quy trình đóng góp

Tài liệu chi tiết trong [CONTRIBUTING.md](CONTRIBUTING.md). Tóm tắt
các bước chính:

1. Fork repo và clone về máy.
2. Chạy `scripts/translation-status.sh` và chọn một file chưa có
   người nhận.
3. Tạo branch mới: `git checkout -b vi_VN/<tên-file>`.
4. Dịch vào đường dẫn tương ứng bên dưới
   `Documentation/translations/vi_VN/`, giữ nguyên cấu trúc thư mục.
5. Giữ nguyên dòng `SPDX-License-Identifier:` ở đầu file gốc.
6. Commit sử dụng `git commit -s` để bổ sung dòng `Signed-off-by:`
   theo chuẩn DCO. Commit message được viết bằng tiếng Anh, theo
   format của kernel.
7. Mở pull request. Title và description của PR cũng được viết bằng
   tiếng Anh. Chỉ nội dung bên trong file dịch được viết bằng tiếng
   Việt.

## License

Tài liệu trong `Documentation/` mặc định phát hành theo giấy phép
GPL-2.0, nội dung được ghi rõ trong file `COPYING` (copy nguyên từ
kernel). File `LICENSE` tại gốc repo chứa toàn văn của GPL-2.0, copy
từ `LICENSES/preferred/GPL-2.0` của kernel. Mục đích của việc đặt
`LICENSE` tại root là để GitHub và các công cụ làm việc với tên file
chuẩn nhận diện license chính xác.

Một số file trong `Documentation/` sử dụng license khác, được khai
báo qua dòng `SPDX-License-Identifier:` ở đầu file. Bản dịch kế thừa
nguyên license của file gốc, không thay đổi.

Khi đóng góp, người đóng góp đồng ý cấp phép phần dịch theo license
của file gốc tương ứng, và xác nhận điều này thông qua dòng
`Signed-off-by:` (DCO) trên mỗi commit. Dự án không sử dụng CLA.

## Quy ước kế thừa từ kernel

Các quy ước dưới đây được giữ theo upstream thay vì tự định nghĩa
riêng, nhằm đảm bảo tính nhất quán với cộng đồng kernel:

- DCO thay cho CLA: giảm rào cản thủ tục cho người đóng góp mới.
- SPDX License Identifier trên mọi file: license rõ ràng, kiểm tra
  được bằng công cụ.
- Đường dẫn bản dịch theo quy ước kernel: không phát sinh cấu trúc
  riêng.
- File `UPSTREAM` lưu trace của bản sync: đảm bảo tính truy ngược
  được của nội dung.
- Định dạng RST thuần không cần build tool tùy biến: `make htmldocs`
  của kernel hoạt động bình thường.

Tuân theo chuẩn của dự án upstream là cách tiếp cận an toàn hơn so
với việc phát sinh chuẩn riêng cho một dự án phái sinh quy mô nhỏ.
