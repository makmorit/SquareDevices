/* 
 * File:   app_settings.h
 * Author: makmorit
 *
 * Created on 2023/05/05, 11:08
 */
#ifndef APP_SETTINGS_H
#define APP_SETTINGS_H

#ifdef __cplusplus
extern "C" {
#endif

//
// レコードキーを保持
//   ファイルID
//   レコードID
//   連番（同一レコードID配下に複数のデータが存在する場合に使用）
//
typedef struct {
    uint16_t    file_id;
    uint16_t    record_key;
    bool        use_serial;
    uint16_t    serial;
} APP_SETTINGS_KEY;

//
// 関数群
//
void        app_settings_initialize(void);
bool        app_settings_save(APP_SETTINGS_KEY *key, void *value, size_t value_size);
bool        app_settings_find(APP_SETTINGS_KEY *key, bool *exist, void *value, size_t *value_size);
bool        app_settings_search(APP_SETTINGS_KEY *key, bool *exist, void *value, size_t *value_size, bool (*_condition_func)(const char *key, void *data, size_t size));
bool        app_settings_delete(APP_SETTINGS_KEY *key);
bool        app_settings_delete_multi(APP_SETTINGS_KEY *key);
bool        app_settings_fetch(APP_SETTINGS_KEY *key, int (*_fetch_func)(const char *key, void *data, size_t size));

#ifdef __cplusplus
}
#endif

#endif /* APP_SETTINGS_H */
