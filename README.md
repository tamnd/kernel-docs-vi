# kernel-docs-vi

Bản dịch tiếng Việt cho Linux kernel documentation. Source gốc là thư
mục `Documentation/` của
[torvalds/linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git).
Bản dịch nằm trong `Documentation/translations/vi_VN/`, đúng chỗ mà
kernel đã dành sẵn cho các ngôn ngữ khác như zh_CN, ja_JP, it_IT,
ko_KR, sp_SP, pt_BR, zh_TW.

Repo còn mới, coverage còn rất thấp. Ai muốn góp một tay thì mở pull
request. Xem CONTRIBUTING.md.

## Phiên bản upstream hiện tại

File `UPSTREAM` ở gốc repo ghi rõ commit nào được lấy về, date bao
nhiêu, ref gì. Khi sync upstream bằng script trong `scripts/`, file này
tự update. Đừng chỉnh tay.

## Repo có gì trong đó

```
.
├── COPYING                  license của kernel, copy nguyên từ upstream
├── LICENSE                  GPL-2.0 đầy đủ (từ LICENSES/preferred/GPL-2.0)
├── LICENSES/                toàn bộ thư mục SPDX license của kernel
├── UPSTREAM                 ref + SHA + commit date được lấy về
├── Documentation/           mirror nguyên của Documentation/ upstream
│   └── translations/
│       ├── zh_CN/ ja_JP/ it_IT/ ko_KR/ sp_SP/ pt_BR/ zh_TW/
│       └── vi_VN/           <-- bản dịch tiếng Việt ở đây
├── ROADMAP.md               hướng đi dự án (tiếng Anh)
├── CONTRIBUTING.md          quy tắc đóng góp
├── TRANSLATION_STATUS.md    bản đồ tiến độ, sinh tự động
├── TRANSLATORS              danh sách người đóng góp
└── scripts/                 init, sync, diff, translation-status, lib/common.sh
```

Vì sao `vi_VN` nằm trong `Documentation/translations/` chứ không ra
ngoài? Vì kernel đã quy ước đường dẫn đó cho bản dịch. Đặt đúng chỗ
được hai lợi ích cụ thể: `make htmldocs` của kernel tự nhận ra, và nếu
sau này gửi patch upstream thì không phải đổi path gì cả.

## Script

Mọi công cụ sync và báo cáo nằm trong `scripts/`.

### Xem tiến độ dịch

```sh
scripts/translation-status.sh
```

Sinh `TRANSLATION_STATUS.md` ở gốc repo. Liệt kê mọi file `.rst`,
`.txt`, `.md` trong `Documentation/` (trừ bản dịch), đánh dấu cái nào
đã có bản tiếng Việt tương ứng.

### Sync với upstream

```sh
scripts/diff-upstream.sh           # preview, không đổi gì
scripts/sync-upstream.sh           # apply thay đổi thực sự
scripts/sync-upstream.sh v6.15     # hoặc sync tới một tag cụ thể
```

Cả ba dùng chung một trick để tránh phải clone cả kernel (khoảng 1.5 GB):

1. `git clone --depth=1 --filter=blob:none --no-checkout` lấy về rất ít.
2. `git sparse-checkout set Documentation LICENSES COPYING` giới hạn
   tiếp chỉ còn những path cần thiết.
3. Kết quả: khoảng 60 MB trên mạng thay vì 1.5 GB.

Script sync giữ nguyên mọi thứ trong `Documentation/translations/vi_VN/`.
Bản dịch các ngôn ngữ khác (zh_CN, ja_JP, ...) sẽ được sync lại theo
upstream vì đó là phần của kernel, không phải của chúng ta.

## Đóng góp

Chi tiết trong CONTRIBUTING.md. Quick summary:

1. Fork repo và clone về.
2. Chạy `scripts/translation-status.sh`. Pick một file chưa có ai nhận.
3. Tạo branch: `git checkout -b vi_VN/<tên-file>`.
4. Dịch vào đúng path tương ứng dưới `Documentation/translations/vi_VN/`.
   Giữ nguyên cấu trúc thư mục.
5. Giữ nguyên dòng `SPDX-License-Identifier:` ở đầu file.
6. Commit bằng `git commit -s` (DCO). Commit message viết tiếng Anh
   theo format kernel.
7. Mở pull request. Title và body PR cũng tiếng Anh. Chỉ nội dung bên
   trong file dịch mới là tiếng Việt.

## License

Documentation/ mặc định là GPL-2.0, ghi rõ trong `COPYING` (file này
copy nguyên từ kernel). `LICENSE` ở gốc repo là GPL-2.0 full text, copy
từ `LICENSES/preferred/GPL-2.0` của kernel. Có `LICENSE` ở gốc để
GitHub và mấy công cụ quen với filename chuẩn nhận ra, không nhầm.

Một số file trong `Documentation/` có license khác qua dòng
`SPDX-License-Identifier:` ở đầu. Bản dịch kế thừa nguyên license của
file gốc, không đổi.

Khi đóng góp, bạn đồng ý cấp phép phần dịch theo đúng license của file
gốc, xác nhận bằng dòng `Signed-off-by:` (DCO) trên mỗi commit. Không
dùng CLA.

## Kế thừa từ kernel

Mấy thứ dưới đây không phải luật riêng, chỉ là convention đã có trong
cộng đồng kernel, và không có lý do gì để đổi:

- DCO thay cho CLA. Không muốn dựng rào cản thủ tục cho người mới.
- SPDX ở mọi nơi. License rõ ràng từng file, không đoán mò.
- Path dịch theo quy ước kernel, không bịa cấu trúc riêng.
- `UPSTREAM` nhớ commit được lấy về, có thể trace ra mọi lúc.
- RST thuần, không thêm build tool lạ. `make htmldocs` của kernel vẫn
  chạy được.

Dự án nhỏ theo standard của dự án to thì an toàn hơn là tự nghĩ ra
standard riêng.
