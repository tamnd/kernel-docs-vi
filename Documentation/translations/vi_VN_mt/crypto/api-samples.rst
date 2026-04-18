.. SPDX-License-Identifier: GPL-2.0

.. include:: ../../disclaimer-vi.rst

:Original: Documentation/crypto/api-samples.rst
:Translator: Google Translate (machine translation)
:Upstream-at: 8541d8f725c6

.. warning::
   Tài liệu này được dịch tự động bằng máy và chưa được review bởi người dịch.
   Nội dung có thể không chính xác hoặc khó hiểu ở một số chỗ. Khi có sự khác
   biệt với bản gốc, bản gốc luôn là chuẩn. Bản dịch chất lượng cao (được
   review) được đặt trong thư mục vi_VN/.

Ví dụ về mã
=============

Ví dụ về mã cho hoạt động mã hóa khóa đối xứng
-----------------------------------------------

Mã này mã hóa một số dữ liệu bằng AES-256-XTS.  Vì ví dụ,
tất cả đầu vào đều là byte ngẫu nhiên, quá trình mã hóa được thực hiện tại chỗ và
giả sử mã đang chạy trong ngữ cảnh có thể ngủ.

::

int tĩnh test_skcipher(void)
    {
            struct crypto_skcipher *tfm = NULL;
            struct skcipher_request *req = NULL;
            u8 *dữ liệu = NULL;
            const size_t datasize = 512; /*Kích thước dữ liệu tính bằng byte */
            danh sách phân tán cấu trúc sg;
            DECLARE_CRYPTO_WAIT(chờ);
            u8 iv[16];  /* AES-256-XTS lấy IV 16 byte */
            phím u8[64]; /* AES-256-XTS lấy khóa 64 byte */
            int lỗi;

/*
             * Phân bổ một tfm (một đối tượng chuyển đổi) và đặt khóa.
             *
             * Trong sử dụng thực tế, tfm và key thường được sử dụng cho nhiều mục đích
             * hoạt động mã hóa/giải mã.  Nhưng trong ví dụ này, chúng ta sẽ chỉ làm một
             * hoạt động mã hóa đơn lẻ với nó (không hiệu quả lắm).
             */

tfm = crypto_alloc_skcipher("xts(aes)", 0, 0);
            nếu (IS_ERR(tfm)) {
                    pr_err("Lỗi cấp phát xts(aes) xử lý: %ld\n", PTR_ERR(tfm));
                    trả về PTR_ERR(tfm);
            }

get_random_bytes(key, sizeof(key));
            err = crypto_skcipher_setkey(tfm, key, sizeof(key));
            nếu (lỗi) {
                    pr_err("Lỗi cài đặt khóa: %d\n", err);
                    đi ra ngoài;
            }

/* Phân bổ đối tượng yêu cầu */
            req = skcipher_request_alloc(tfm, GFP_KERNEL);
            nếu (!req) {
                    lỗi = -ENOMEM;
                    đi ra ngoài;
            }

/*Chuẩn bị dữ liệu đầu vào*/
            dữ liệu = kmalloc(datasize, GFP_KERNEL);
            nếu (!dữ liệu) {
                    lỗi = -ENOMEM;
                    đi ra ngoài;
            }
            get_random_bytes(dữ liệu, kích thước dữ liệu);

/* Khởi tạo IV */
            get_random_bytes(iv, sizeof(iv));

/*
             * Mã hóa dữ liệu tại chỗ.
             *
             * Để đơn giản, trong ví dụ này chúng ta đợi request hoàn thành
             * trước khi tiếp tục, ngay cả khi việc triển khai cơ bản không đồng bộ.
             *
             * Để giải mã thay vì mã hóa, chỉ cần thay đổi crypto_skcipher_encrypt() thành
             * crypto_skcipher_decrypt().
             */
            sg_init_one(&sg, dữ liệu, kích thước dữ liệu);
            skcipher_request_set_callback(req, CRYPTO_TFM_REQ_MAY_BACKLOG |
                                               CRYPTO_TFM_REQ_MAY_SLEEP,
                                          crypto_req_done, &đợi);
            skcipher_request_set_crypt(req, &sg, &sg, datasize, iv);
            err = crypto_wait_req(crypto_skcipher_encrypt(req), &wait);
            nếu (lỗi) {
                    pr_err("Lỗi mã hóa dữ liệu: %d\n", err);
                    đi ra ngoài;
            }

pr_debug("Mã hóa thành công\n");
    ra:
            crypto_free_skcipher(tfm);
            skcipher_request_free(req);
            kfree(dữ liệu);
            trả lại lỗi;
    }


Ví dụ mã để sử dụng bộ nhớ trạng thái hoạt động với SHASH
-----------------------------------------------------------

::


cấu trúc sdesc {
        cấu trúc shash_desc shash;
        char ctx[];
    };

cấu trúc tĩnh sdesc *init_sdesc(struct crypto_shash *alg)
    {
        cấu trúc sdesc *sdesc;
        kích thước int;

kích thước = sizeof(struct shash_desc) + crypto_shash_descsize(alg);
        sdesc = kmalloc(kích thước, GFP_KERNEL);
        nếu (!sdesc)
            trả về ERR_PTR(-ENOMEM);
        sdesc->shash.tfm = alg;
        trả về sdesc;
    }

int tĩnh calc_hash(struct crypto_shash *alg,
                 const dữ liệu char * không dấu, dữ liệu int không dấu,
                 ký tự không dấu *tiêu hóa)
    {
        cấu trúc sdesc *sdesc;
        int ret;

sdesc = init_sdesc(alg);
        nếu (IS_ERR(sdesc)) {
            pr_info("không thể cấp phát sdesc\n");
            trả về PTR_ERR(sdesc);
        }

ret = crypto_shash_digest(&sdesc->shash, data, datalen, dig);
        kfree(sdesc);
        trở lại ret;
    }

static int test_hash(const unsigned char *data, unsigned int datalen,
                 ký tự không dấu *tiêu hóa)
    {
        struct crypto_shash *alg;
        char *hash_alg_name = "sha1-padlock-nano";
        int ret;

alg = crypto_alloc_shash(hash_alg_name, 0, 0);
        nếu (IS_ERR(alg)) {
                pr_info("không thể cấp phát alg %s\n", hash_alg_name);
                trả về PTR_ERR(alg);
        }
        ret = calc_hash(alg, data, datalen, dig);
        crypto_free_shash(alg);
        trở lại ret;
    }


Ví dụ về mã để sử dụng trình tạo số ngẫu nhiên
----------------------------------------------

::


int tĩnh get_random_numbers(u8 *buf, unsigned int len)
    {
        struct crypto_rng *rng = NULL;
        char ZZ0000ZZ Hash DRBG với SHA-256, không có PR */
        int ret;

if (!buf || !len) {
            pr_debug("Không cung cấp bộ đệm đầu ra\n");
            trả về -EINVAL;
        }

rng = crypto_alloc_rng(drbg, 0, 0);
        nếu (IS_ERR(rng)) {
            pr_debug("không thể phân bổ bộ xử lý RNG cho %s\n", drbg);
            trả về PTR_ERR(rng);
        }

ret = crypto_rng_get_bytes(rng, buf, len);
        nếu (ret < 0)
            pr_debug("tạo số ngẫu nhiên không thành công\n");
        khác nếu (ret == 0)
            pr_debug("RNG không trả về dữ liệu");
        khác
            pr_debug("RNG trả về %d byte dữ liệu\n", ret);

ra:
        crypto_free_rng(rng);
        trở lại ret;
    }
