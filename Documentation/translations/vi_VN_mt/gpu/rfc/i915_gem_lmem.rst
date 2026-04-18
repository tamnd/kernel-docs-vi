.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../../disclaimer-vi.rst

:Original: Documentation/gpu/rfc/i915_gem_lmem.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tai lieu nay duoc dich tu dong bang may va chua duoc review boi nguoi dich.
   Noi dung co the khong chinh xac hoac kho hieu o mot so cho. Khi co su khac
   biet voi ban goc, ban goc luon la chuan. Ban dich chat luong cao (duoc
   review) duoc dat trong thu muc vi_VN/.

===========================
Phần I915 DG1/LMEM RFC
=========================

Kế hoạch thượng nguồn
=============
Đối với kế hoạch tổng thể để hạ cánh tất cả nội dung DG1 và chuyển nó sang
thực, với tất cả các bit uAPI là:

* Hợp nhất kích hoạt CTNH cơ bản của DG1 (vẫn không có pciid)
* Hợp nhất các bit uAPI đằng sau cờ CONFIG_BROKEN(hoặc hơn) đặc biệt
        * Tại thời điểm này, chúng tôi vẫn có thể thực hiện các thay đổi, nhưng quan trọng là điều này cho phép chúng tôi
          bắt đầu chạy IGT có thể sử dụng bộ nhớ cục bộ trong CI
* Chuyển đổi sang TTM, đảm bảo tất cả vẫn hoạt động. Một số hạng mục công việc:
        * Bộ thu nhỏ TTM dành cho rời rạc
        * dma_resv_lockitem cho dma_resv_lock đầy đủ, tức là không chỉ trylock
        * Sử dụng trình xử lý lỗi trang TTM CPU
        * Định tuyến chương trình phụ trợ shmem tới TTM SYSTEM để rời rạc
        * Hỗ trợ đối tượng có thể xóa TTM
        * Di chuyển bộ cấp phát bạn bè i915 sang TTM
* Gửi RFC (với mesa-dev trên cc) để đăng xuất lần cuối trên uAPI
* Thêm pciid cho DG1 và bật uAPI thật
