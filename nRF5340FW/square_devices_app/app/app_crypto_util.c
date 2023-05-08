/* 
 * File:   app_crypto_util.c
 * Author: makmorit
 *
 * Created on 2023/05/08, 10:02
 */
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/device.h>
#include <zephyr/init.h>

// for Mbed TLS
#include <mbedtls/aes.h>
#include <mbedtls/cipher.h>
#include <mbedtls/ctr_drbg.h>
#include <mbedtls/des.h>
#include <mbedtls/md.h>
#include <mbedtls/platform.h>
#include <mbedtls/sha256.h>

// ログ出力制御
#define LOG_LEVEL LOG_LEVEL_DBG
#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_crypto_util);

#define LOG_DEBUG_AES_PLAINTEXT_DATA    false
#define LOG_DEBUG_AES_ENCRYPTED_DATA    false
#define LOG_DEBUG_AES_DECRYPTED_DATA    false
#define LOG_DEBUG_RANDOM_VECTOR_DATA    false
#define LOG_DEBUG_SHA256_HASH_DATA      false
#define LOG_DEBUG_DES3_ECB_DATA         false

// 定義体
#include "app_crypto.h"
#include "app_crypto_define.h"

//
// AES-256暗号化処理
//
static uint8_t m_aes_iv[AES_IV_SIZE];

static bool aes_cbc_256_init(mbedtls_cipher_context_t *p_ctx)
{
    mbedtls_cipher_init(p_ctx);
    const mbedtls_cipher_info_t *p_cipher_info = mbedtls_cipher_info_from_values(MBEDTLS_CIPHER_ID_AES, AES_KEY_SIZE * 8, MBEDTLS_MODE_CBC);
    if (p_cipher_info == NULL) {
        LOG_ERR("mbedtls_cipher_info_from_values returns NULL");
        return false;
    }

    int ret = mbedtls_cipher_setup(p_ctx, p_cipher_info);
    if (ret != 0) {
        LOG_ERR("mbedtls_cipher_setup returns %d", ret);
        return false;
    }

    return true;
}

static bool aes_cbc_256_prepare(mbedtls_cipher_context_t *p_ctx, uint8_t *p_key, mbedtls_operation_t operation, mbedtls_cipher_padding_t padding)
{
    int ret = mbedtls_cipher_setkey(p_ctx, p_key, AES_KEY_SIZE * 8, operation);
    if (ret != 0) {
        LOG_ERR("mbedtls_cipher_setkey returns %d", ret);
        return false;
    }

    ret = mbedtls_cipher_set_padding_mode(p_ctx, padding);
    if (ret != 0) {
        LOG_ERR("mbedtls_cipher_set_padding_mode returns %d", ret);
        return false;
    }

    return true;
}

bool app_crypto_aes_cbc_256_encrypt(uint8_t *p_key, uint8_t *p_plaintext, size_t plaintext_size, uint8_t *encrypted, size_t *encrypted_size) 
{
#if LOG_DEBUG_AES_PLAINTEXT_DATA
    LOG_DBG("%d bytes", plaintext_size);
    LOG_HEXDUMP_DBG(p_plaintext, plaintext_size, "Plaintext data");
#endif

    mbedtls_cipher_context_t ctx;
    if (aes_cbc_256_init(&ctx) == false) {
        return false;
    }
    if (aes_cbc_256_prepare(&ctx, p_key, MBEDTLS_ENCRYPT, MBEDTLS_PADDING_NONE) == false) {
        return false;
    }

    memset(m_aes_iv, 0, sizeof(m_aes_iv));
    int ret = mbedtls_cipher_crypt(&ctx, m_aes_iv, sizeof(m_aes_iv), p_plaintext, plaintext_size, encrypted, encrypted_size);
    if (ret != 0) {
        LOG_ERR("mbedtls_cipher_crypt returns %d", ret);
        return false;
    }

    return true;
}

bool app_crypto_aes_cbc_256_decrypt(uint8_t *p_key, uint8_t *p_encrypted, size_t encrypted_size, uint8_t *decrypted, size_t *decrypted_size) 
{
#if LOG_DEBUG_AES_ENCRYPTED_DATA
    LOG_DBG("%d bytes", encrypted_size);
    LOG_HEXDUMP_DBG(p_encrypted, encrypted_size, "Encrypted data");
#endif

    mbedtls_cipher_context_t ctx;
    if (aes_cbc_256_init(&ctx) == false) {
        return false;
    }
    if (aes_cbc_256_prepare(&ctx, p_key, MBEDTLS_DECRYPT, MBEDTLS_PADDING_NONE) == false) {
        return false;
    }

    memset(m_aes_iv, 0, sizeof(m_aes_iv));
    int ret = mbedtls_cipher_crypt(&ctx, m_aes_iv, sizeof(m_aes_iv), p_encrypted, encrypted_size, decrypted, decrypted_size);
    if (ret != 0) {
        LOG_ERR("mbedtls_cipher_crypt returns %d", ret);
        return false;
    }

#if LOG_DEBUG_AES_DECRYPTED_DATA
    LOG_DBG("%d bytes", *decrypted_size);
    LOG_HEXDUMP_DBG(decrypted, *decrypted_size, "Decrypted data");
#endif

    return true;
}

//
// ランダムベクター生成
//   スタックを相当量消費するため、事前に専用スレッドで
//   `app_crypto_random_vector_pre_generate`を
//   実行しておくようにします。
//
static uint8_t m_random_vector[32];
static bool random_vector_generated;

void app_crypto_random_vector_pre_generate(void)
{
    // ランダムベクターを事前生成
    int ret = mbedtls_ctr_drbg_random(app_crypto_ctr_drbg_context(), m_random_vector, sizeof(m_random_vector));
    if (ret != 0) {
        LOG_ERR("mbedtls_ctr_drbg_random returns %d", ret);
        random_vector_generated = false;
    } else {
        LOG_INF("Random vector pre-generate success");
        random_vector_generated = true;
    }
}

bool app_crypto_generate_random_vector(uint8_t *vector_buf, size_t vector_size)
{
    // 生成したランダムベクターを取得
    if (random_vector_generated == false) {
        LOG_ERR("Random vector is not pre-generated");
        return false;
    }
    memcpy(vector_buf, m_random_vector, vector_size);
    random_vector_generated = false;

#if LOG_DEBUG_RANDOM_VECTOR_DATA
    LOG_DBG("%d bytes", vector_size);
    LOG_HEXDUMP_DBG(vector_buf, vector_size, "Random vector data");
#endif

    return true;
}

//
// ハッシュ生成
//
bool app_crypto_generate_sha256_hash(uint8_t *data, size_t data_size, uint8_t *hash_digest)
{
    int ret = mbedtls_sha256(data, data_size, hash_digest, false);
    if (ret != 0) {
        LOG_ERR("mbedtls_sha256 returns %d", ret);
        return false;
    }

#if LOG_DEBUG_SHA256_HASH_DATA
    LOG_DBG("%d bytes", SHA256_HASH_SIZE);
    LOG_HEXDUMP_DBG(hash_digest, SHA256_HASH_SIZE, "SHA-256 hash data");
#endif

    return true;
}

//
// HMACハッシュ生成
//
static mbedtls_md_context_t md_context;

static bool calculate_md_hmac_terminate(bool b)
{
    mbedtls_md_free(&md_context);
    return b;
}

bool calculate_md_hmac(mbedtls_md_type_t md_type, uint8_t *key_data, size_t key_data_size, uint8_t *src_data, size_t src_data_size, uint8_t *src_data_2, size_t src_data_2_size, uint8_t *hash_digest)
{
    // 初期化
    mbedtls_md_init(&md_context);
    const mbedtls_md_info_t *p_md_info = mbedtls_md_info_from_type(md_type);
    int ret = mbedtls_md_setup(&md_context, p_md_info, 1);
    if (ret != 0) {
        LOG_ERR("mbedtls_md_setup returns %d", ret);
        return calculate_md_hmac_terminate(false);
    }

    // HMACハッシュ計算には、引数のkey_dataを使用
    ret = mbedtls_md_hmac_starts(&md_context, key_data, key_data_size);
    if (ret != 0) {
        LOG_ERR("mbedtls_md_hmac_starts returns %d", ret);
        return calculate_md_hmac_terminate(false);
    }

    // 引数を計算対象に設定
    ret = mbedtls_md_hmac_update(&md_context, src_data, src_data_size);
    if (ret != 0) {
        LOG_ERR("mbedtls_md_hmac_update(1) returns %d", ret);
        return calculate_md_hmac_terminate(false);
    }

    // 2番目の引数を計算対象に設定
    if (src_data_2 != NULL && src_data_2_size > 0) {
        ret = mbedtls_md_hmac_update(&md_context, src_data_2, src_data_2_size);
        if (ret != 0) {
            LOG_ERR("mbedtls_md_hmac_update(2) returns %d", ret);
            return calculate_md_hmac_terminate(false);
        }
    }

    // HMACハッシュを計算
    ret = mbedtls_md_hmac_finish(&md_context, hash_digest);
    if (ret != 0) {
        LOG_ERR("mbedtls_md_hmac_finish returns %d", ret);
        return calculate_md_hmac_terminate(false);
    }

#if LOG_DEBUG_SHA256_HASH_DATA
    LOG_DBG("%d bytes", SHA256_HASH_SIZE);
    LOG_HEXDUMP_DBG(hash_digest, SHA256_HASH_SIZE, "HMAC SHA-256 hash data");
#endif

    return calculate_md_hmac_terminate(true);
}

bool app_crypto_generate_hmac_sha256(uint8_t *key_data, size_t key_data_size, uint8_t *src_data, size_t src_data_size, uint8_t *src_data_2, size_t src_data_2_size, uint8_t *hash_digest)
{
    return calculate_md_hmac(MBEDTLS_MD_SHA256, key_data, key_data_size, src_data, src_data_size, src_data_2, src_data_2_size, hash_digest);
}

bool app_crypto_generate_hmac_sha1(uint8_t *key_data, size_t key_data_size, uint8_t *src_data, size_t src_data_size, uint8_t *src_data_2, size_t src_data_2_size, uint8_t *hash_digest)
{
    return calculate_md_hmac(MBEDTLS_MD_SHA1, key_data, key_data_size, src_data, src_data_size, src_data_2, src_data_2_size, hash_digest);
}

//
// 3DES-ECB暗号化処理
//
bool app_crypto_des3_ecb(const uint8_t *in, uint8_t *out, const uint8_t *key)
{
    mbedtls_des3_context ctx;
    mbedtls_des3_init(&ctx);
    mbedtls_des3_set3key_enc(&ctx, key);

    int ret = mbedtls_des3_crypt_ecb(&ctx, in, out);
    mbedtls_des3_free(&ctx);
    if (ret != 0) {
        LOG_ERR("mbedtls_des3_crypt_ecb returns %d", ret);
        return false;
    }

#if LOG_DEBUG_DES3_ECB_DATA
    LOG_DBG("%d bytes", DES3_CRYPTO_SIZE);
    LOG_HEXDUMP_DBG(out, DES3_CRYPTO_SIZE, "3DES-ECB crypto data");
#endif

    return true;
}
