# kernel-docs-vi — Tài liệu Linux kernel bằng tiếng Việt

> Vietnamese translation of the Linux kernel documentation (`Documentation/`
> from [torvalds/linux](https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git)).
> Bản dịch tuân theo quy ước của `Documentation/translations/` trong chính kernel.

Bản dịch tiếng Việt cho [tài liệu chính thức của Linux kernel](https://www.kernel.org/doc/html/latest/),
giữ nguyên bố cục gốc để có thể (nếu cần) gửi ngược lại upstream theo đường dẫn
`Documentation/translations/vi_VN/`.

## Nguồn gốc (Provenance)

Phiên bản upstream hiện tại được ghi trong tệp [`UPSTREAM`](UPSTREAM) — gồm ref,
commit SHA, ngày commit và thời điểm đồng bộ gần nhất. Tệp này do các script
trong [`scripts/`](scripts/) tự động cập nhật; đừng chỉnh tay.

## Bố cục kho

```
.
├── COPYING                       # GPL-2.0, bản sao từ kernel upstream
├── LICENSES/                     # toàn bộ thư mục giấy phép SPDX từ kernel
├── UPSTREAM                      # ref + SHA + ngày commit + thời điểm đồng bộ
├── Documentation/                # bản sao y nguyên Documentation/ của upstream
│   └── translations/
│       ├── zh_CN/  ja_JP/  ...   # các bản dịch có sẵn trong kernel
│       └── vi_VN/                # <-- bản dịch tiếng Việt của chúng ta
└── scripts/
    ├── init-upstream.sh          # nhập Documentation/ lần đầu
    ├── sync-upstream.sh          # đồng bộ với upstream, giữ nguyên vi_VN/
    ├── diff-upstream.sh          # xem trước các thay đổi sắp áp
    ├── translation-status.sh     # sinh TRANSLATION_STATUS.md
    └── lib/common.sh             # tiện ích dùng chung
```

Vì sao `vi_VN/` nằm trong `Documentation/translations/`?
Kernel đã quy ước đường dẫn đó cho các bản dịch (xem `zh_CN/`, `ja_JP/`, `it_IT/`,
`ko_KR/`, `sp_SP/`). Đặt đúng chỗ giúp `make htmldocs` nhận ra bản dịch, và
nếu sau này muốn gửi patch lên LKML thì không phải đổi đường dẫn.

## Làm việc với bản dịch

### Xem tiến độ

```sh
scripts/translation-status.sh
# Sinh TRANSLATION_STATUS.md: danh sách tệp nguồn và trạng thái dịch.
```

### Đồng bộ với upstream

```sh
scripts/diff-upstream.sh            # xem trước, không đổi gì
scripts/sync-upstream.sh            # áp thay đổi, giữ nguyên vi_VN/
scripts/sync-upstream.sh v6.15      # hoặc đồng bộ tới một tag cụ thể
```

Script dùng **blobless + shallow + sparse partial clone** để chỉ tải
`Documentation/`, `LICENSES/`, `COPYING` — khoảng 40–60 MB thay vì ~1.5 GB
của bản clone đầy đủ.

## Đóng góp

Quy trình tóm tắt (xem chi tiết trong [CONTRIBUTING.md](CONTRIBUTING.md)):

1. Fork và clone kho.
2. Chọn một tệp từ [TRANSLATION_STATUS.md](TRANSLATION_STATUS.md) chưa có người nhận.
3. Tạo nhánh: `git checkout -b vi_VN/<đường-dẫn-tệp>`.
4. Dịch vào `Documentation/translations/vi_VN/<cùng-đường-dẫn>.rst`, giữ nguyên
   dòng `SPDX-License-Identifier:` ở đầu tệp gốc.
5. Commit có chữ ký: `git commit -s` (DCO). Format chủ đề theo kernel:
   `Documentation/translations/vi_VN/<mục>: <mô tả ngắn>`.
6. Gửi pull request.

## Giấy phép

Tài liệu trong `Documentation/` mặc định là **GPL-2.0** (xem [COPYING](COPYING)).
Một số tệp mang giấy phép khác qua chỉ báo `SPDX-License-Identifier:` ở đầu
tệp — bản dịch **kế thừa nguyên** giấy phép đó. Toàn bộ văn bản giấy phép
có trong thư mục [`LICENSES/`](LICENSES/).

Khi đóng góp bản dịch, bạn đồng ý cấp phép tác phẩm của mình theo cùng giấy
phép của tệp gốc, và xác nhận điều đó qua chữ ký `Signed-off-by:`
([Developer Certificate of Origin](https://developercertificate.org/)).

## Nguyên tắc kế thừa từ Linux kernel

- **DCO, không CLA** — đóng góp chỉ cần `git commit -s`.
- **SPDX ở khắp mọi nơi** — mỗi tệp dịch giữ nguyên `SPDX-License-Identifier`
  của tệp gốc.
- **Đường dẫn thân thiện với upstream** — `Documentation/translations/vi_VN/`.
- **Reproducible provenance** — tệp `UPSTREAM` ghim ref + SHA + ngày commit.
- **Sphinx/RST nguyên bản** — không có công cụ lạ; `make htmldocs` upstream
  chạy được trực tiếp.
