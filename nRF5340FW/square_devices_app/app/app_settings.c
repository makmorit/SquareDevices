/* 
 * File:   app_settings.c
 * Author: makmorit
 *
 * Created on 2023/05/05, 11:08
 */
#include <stdio.h>
#include <zephyr/types.h>
#include <zephyr/kernel.h>
#include <zephyr/settings/settings.h>

#include <zephyr/logging/log.h>
LOG_MODULE_REGISTER(app_settings);

#define LOG_SETTINGS_DEBUG          false
#define LOG_SETTINGS_DELETE         false
#define LOG_SETTINGS_EXIST_KEY      false

#include "app_settings.h"

// 登録データの読込用バッファ
static uint8_t settings_buf[CONFIG_APP_SETTINGS_BUFFER_SIZE];
static size_t  settings_buf_size;

// キー名称の編集用バッファ
static uint8_t settings_key[32];
static uint8_t settings_key_temp[32];

// app_settings_loadで指定された検索キーを保持
static const char *settings_key_to_find   = NULL;
static const char *settings_key_to_delete = NULL;
static const char *settings_key_to_fetch  = NULL;

// h_set内でデータ内容を比較するために
// 使用する関数の参照を保持
static bool (*settings_condition_func)(const char *key, void *data, size_t size);

// h_set内で読込データについて処理を実行させるために
// 使用する関数の参照を保持
static int (*settings_fetch_func)(const char *key, void *data, size_t size);

// サブツリー設定
static int h_set(const char *key, size_t len, settings_read_cb read_cb, void *cb_arg);
static int h_commit(void);
static struct settings_handler app_conf = {
    .name     = "app",
    .h_set    = h_set,
    .h_commit = h_commit,
};

static int find_setting(const char *key, size_t len, settings_read_cb read_cb, void *cb_arg)
{
    // すでに検索済みの場合は終了
    if (settings_buf_size > 0) {
        return 0;
    }

    // キーが検索対象でない場合は終了
    if (strncmp(key, settings_key_to_find, strlen(settings_key_to_find)) != 0) {
        return 0;
    }

    // バッファ長を上限として、検索対象のデータを読込
    size_t max = (len > sizeof(settings_buf) ? sizeof(settings_buf) : len);
    int read_len = read_cb(cb_arg, settings_buf, max);
    if (read_len < 0) {
        LOG_ERR("Failed to read from storage: read_cb returns %d", read_len);
        return read_len;
    }

    if (settings_condition_func != NULL) {
        // データ内容を比較し、所定の内容と一致していれば、
        // 読み込んだバイト数を保持
        if ((*settings_condition_func)(key, settings_buf, read_len)) {
            settings_buf_size = read_len;
        }

    } else {
        // 読み込んだバイト数を保持
        settings_buf_size = read_len;
    }

    return 0;
}

static int delete_setting(const char *key)
{
    // キーが削除対象でない場合は終了
    if (strncmp(key, settings_key_to_delete, strlen(settings_key_to_delete)) != 0) {
        return 0;
    }

    // 該当キーのデータをサブツリーから削除
    sprintf(settings_key_temp, "%s/%s", app_conf.name, key);
    int rc = settings_delete(settings_key_temp);
    if (rc < 0) {
        LOG_ERR("Failed to delete from storage: settings_delete returns %d", rc);
    }

#if LOG_SETTINGS_DELETE
    LOG_INF("settings_delete done: key[%s]", settings_key_temp);
#endif

    return rc;
}

static int fetch_setting(const char *key, size_t len, settings_read_cb read_cb, void *cb_arg)
{
    // キーが読込対象でない場合は終了
    if (strncmp(key, settings_key_to_fetch, strlen(settings_key_to_fetch)) != 0) {
        return 0;
    }

    // バッファ長を上限として、検索対象のデータを読込
    size_t max = (len > sizeof(settings_buf) ? sizeof(settings_buf) : len);
    int read_len = read_cb(cb_arg, settings_buf, max);
    if (read_len < 0) {
        LOG_ERR("Failed to read from storage: read_cb returns %d", read_len);
        return read_len;
    }

    // 指定されたコールバックを実行
    int rc = 0;
    if (settings_fetch_func != NULL) {
        rc = (*settings_fetch_func)(key, settings_buf, read_len);
    }
    return rc;
}

static int h_set(const char *key, size_t len, settings_read_cb read_cb, void *cb_arg)
{
#if LOG_SETTINGS_EXIST_KEY
    LOG_INF("h_set called: key[app/%s] length[%d]", key, len);
#endif

    // キーが検索対象であれば、検索対象のデータを読込
    if (settings_key_to_find != NULL) {
        return find_setting(key, len, read_cb, cb_arg);
    }

    // キーが削除対象であれば、該当キーのデータをサブツリーから削除
    if (settings_key_to_delete != NULL) {
        return delete_setting(key);
    }

    // キーが読込対象であれば、対象のデータを読込
    if (settings_key_to_fetch != NULL) {
        return fetch_setting(key, len, read_cb, cb_arg);
    }

    return 0;
}

static int h_commit(void)
{
#if LOG_SETTINGS_DEBUG
    LOG_INF("h_commit called");
#endif

    // 検索キーをクリア
    settings_key_to_find   = NULL;
    settings_key_to_delete = NULL;
    settings_key_to_fetch  = NULL;
    return 0;
}

void app_settings_initialize(void)
{
    // データバッファサイズをログ表示
    LOG_INF("Buffer size for reading data from storage: %d bytes", sizeof(settings_buf));

    // 業務処理で使用する永続化用のサブツリーを登録
    settings_register(&app_conf);

    // 永続化機能を初期化
    if (IS_ENABLED(CONFIG_BT_SETTINGS)) {
        settings_load();
    }
}

static void create_app_settings_key(APP_SETTINGS_KEY *key, char *buf)
{
    // キー名を生成
    if (key->use_serial) {
        sprintf(buf, "%s/%04x/%04x/%04x", app_conf.name, key->file_id, key->record_key, key->serial);
    } else if (key->record_key != 0) {
        sprintf(buf, "%s/%04x/%04x", app_conf.name, key->file_id, key->record_key);
    } else {
        sprintf(buf, "%s/%04x", app_conf.name, key->file_id);
    }
}

bool app_settings_save(APP_SETTINGS_KEY *key, void *value, size_t value_size)
{
    // キー名を生成
    create_app_settings_key(key, settings_key);

    // サブツリーにデータを登録
    int ret = settings_save_one(settings_key, value, value_size);
    if (ret != 0) {
        LOG_ERR("settings_save_one returns %d", ret);
        return false;
    }

#if LOG_SETTINGS_DEBUG
    LOG_INF("settings_save_one done: key[%s]", settings_key);
    LOG_HEXDUMP_INF(value, value_size, "value");
#endif

    return true;
}

static bool app_settings_load(APP_SETTINGS_KEY *key, const char **key_to_find)
{
    // キー名を生成
    create_app_settings_key(key, settings_key);

    if (settings_name_steq(settings_key, app_conf.name, key_to_find) == 0) {
        // 検索対象のキーが抽出できなかった場合は何も行わない
        return false;
    }

    // サブツリーをロード
    int ret = settings_load_subtree(app_conf.name);
    if (ret != 0) {
        LOG_ERR("settings_load_subtree returns %d", ret);
        return false;
    }

#if LOG_SETTINGS_DEBUG
    LOG_INF("settings_load_subtree done: key[%s]", app_conf.name);
#endif
    return true;
}

bool app_settings_find(APP_SETTINGS_KEY *key, bool *exist, void *value, size_t *value_size)
{
    return app_settings_search(key, exist, value, value_size, NULL);
}

bool app_settings_search(APP_SETTINGS_KEY *key, bool *exist, void *value, size_t *value_size, bool (*_condition_func)(const char *key, void *data, size_t size))
{
    // データ格納領域を初期化
    memset(settings_buf, 0, sizeof(settings_buf));
    settings_buf_size = 0;
    *exist = false;

    // 条件判定用関数の参照を保持
    settings_condition_func = _condition_func;

    // サブツリーをロード
    //   検索対象データがサブツリー内に存在する場合、
    //   データが settings_buf に格納され、
    //   データ長が settings_buf_size に設定されます。
    if (app_settings_load(key, &settings_key_to_find) == false) {
        return false;
    }

    // ロードしたデータをコピー
    if (settings_buf_size > 0) {
        memcpy(value, settings_buf, settings_buf_size);
        *exist = true;
    }
    *value_size = settings_buf_size;
    return true;
}

bool app_settings_delete(APP_SETTINGS_KEY *key)
{
    // キー名を生成
    create_app_settings_key(key, settings_key);

    // サブツリーから該当データだけを削除
    int ret = settings_delete(settings_key);
    if (ret != 0) {
        LOG_ERR("settings_delete returns %d", ret);
        return false;
    }

#if LOG_SETTINGS_DELETE
    LOG_INF("settings_delete done: key[%s]", settings_key);
#endif

    return true;
}

bool app_settings_delete_multi(APP_SETTINGS_KEY *key)
{
    // キー名を生成
    create_app_settings_key(key, settings_key);

    // 指定されたキーの配下に属するデータを
    // サブツリーから全て削除
    if (app_settings_load(key, &settings_key_to_delete) == false) {
        return false;
    }

    return true;
}

bool app_settings_fetch(APP_SETTINGS_KEY *key, int (*_fetch_func)(const char *key, void *data, size_t size))
{
    // 読込レコード処理用関数の参照を保持
    settings_fetch_func = _fetch_func;

    // サブツリーをロード
    if (app_settings_load(key, &settings_key_to_fetch) == false) {
        return false;
    }

    return true;
}
