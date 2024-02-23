//
//  log_debug.c
//  DesktopTool
//
//  Created by Makoto Morita on 2024/02/22.
//
#include <stdarg.h>
#include <stdio.h>

// エラーメッセージを保持
static char error_message[1024];

// Reference of ToolLogFile function
void handle_log_debug(char *message);

void log_debug(const char *fmt, ...) {
    // ログファイルに出力するメッセージを生成
    va_list ap;
    va_start(ap, fmt);
    vsprintf(error_message, fmt, ap);
    va_end(ap);
    // メッセージをログファイルに出力
    handle_log_debug(error_message);
}
