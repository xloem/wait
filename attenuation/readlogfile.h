#include <stdint.h>
#include <stdio.h>
#include <time.h>

typedef struct rtlsdr_dev rtlsdr_dev_t;

void readlogfile(FILE * file,
                 void (*handle_data)(uint8_t(*samples)[2],size_t),
		 void (*handle_time)(struct timespec),
		 void (*handle_struct)(rtlsdr_dev_t *dev));
