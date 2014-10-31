#include "readlogfile.h"

#include <stdlib.h>

#define LOG_DATA 0
#define LOG_TIME 1
#define LOG_STRUCT 2



void readlogfile(FILE * file,
                 void (*handle_data)(uint8_t(*)[2],size_t),
		 void (*handle_time)(struct timespec),
		 void (*handle_struct)(rtlsdr_dev_t *dev))
{
	uint8_t op, last_op = 0;
	uint32_t structlen;
	rtlsdr_dev_t * dev;
	struct timespec time;
	uint32_t sec, nsec;

	uint32_t datalen;
	uint32_t data_alloc = 0;
	uint8_t (* data)[2] = 0;

	fread(&structlen, sizeof(structlen), 1, file);
	dev = malloc(structlen);

	while (fread(&op, sizeof(op), 1, file))
	{
		switch(op) {
		case LOG_DATA:
			fread(&datalen, sizeof(datalen), 1, file);
			if (datalen > data_alloc) {
				free(data);
				data = malloc(datalen);
				data_alloc = datalen;
			}
			fread(data, datalen, 1, file);
			if (NULL != handle_data)
				handle_data(data, datalen >> 1);
			break;
		case LOG_TIME:
			fread(&sec, sizeof(sec), 1, file);
			fread(&nsec, sizeof(nsec), 1, file);
			time.tv_sec = sec;
			time.tv_nsec = nsec;
			if (NULL != handle_time)
				handle_time(time);
			break;
		case LOG_STRUCT:
			fread(dev, structlen, 1, file);
			if (NULL != handle_struct)
				handle_struct(dev);
			break;
		default:
			fprintf(stderr, "!! Unexpected rtl logfile op 0x%02x after op 0x%02x !!\n", op, last_op);
			return;
		}
		last_op = op;
	}
}
