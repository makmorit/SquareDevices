//
//  mcumgr_app_image.h
//  DesktopTool
//
//  Created by Makoto Morita on 2023/12/15.
//
#ifndef mcumgr_app_image_h
#define mcumgr_app_image_h

#include <stdlib.h>
#include <stdbool.h>

char       *mcumgr_app_image_bin_filename(void);
char       *mcumgr_app_image_bin_version(void);
char       *mcumgr_app_image_bin_boardname(void);
bool        mcumgr_app_image_bin_filename_get(const char *bin_file_dir_path, const char *bin_file_name_prefix);
uint8_t    *mcumgr_app_image_bin(void);
size_t      mcumgr_app_image_bin_size(void);
uint8_t    *mcumgr_app_image_bin_hash_sha256(void);
bool        mcumgr_app_image_bin_read(const char *bin_file_path);

#endif /* mcumgr_app_image_h */
