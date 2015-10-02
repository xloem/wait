#include "readlogfile.h"

void handle_data(uint8_t (*data)[2], size_t len)
{
	fwrite(data, len, 2, stdout);
}

int main(int argc, const char ** argv)
{
	FILE * file = stdin;
	if (argc == 2)
		file = fopen(argv[1], "rb");
	return readlogfile(file, handle_data, NULL, NULL);
}
