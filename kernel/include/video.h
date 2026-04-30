#ifndef VIDEO_H
#define VIDEO_H

#include "types.h"

#define FB_WIDTH  1920
#define FB_HEIGHT 1080
#define FB_BPP    4

#ifdef QEMU
#define FB_BASE   0x87000000
#else
#define FB_BASE   0x7f700000
#endif

void video_init();
void video_bmp_display(unsigned int* bmp_image, int width, int height);

#endif /* VIDEO_H */
