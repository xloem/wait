#include "readlogfile.h"

size_t frame = 0, last_frame;
struct timespec last_time;
uint32_t frequency, last_frequency;
uint32_t rate, last_rate;
int data_pending = 0;

void head()
{
	printf(
"<?xpacket begin='﻿' id='W5M0MpCehiHzreSzNTczkc9d'?>\n"
"<x:xmpmeta xmlns:x='adobe:ns:meta/' x:xmptk='Image::ExifTool 9.68'>\n"
"<rdf:RDF xmlns:rdf='http://www.w3.org/1999/02/22-rdf-syntax-ns#'>\n"
" <rdf:Description rdf:about='' xmlns:xmpDM='http://ns.adobe.com/xmp/1.0/DynamicMedia/'>\n"
	);
}

void handle_data(uint8_t(*samples)[2], size_t count)
{
	last_frame = frame;
	frame += count;
	data_pending = 1;
}

void handle_struct(rtlsdr_dev_t *dev)
{
	if (rtlsdr_get_center_freq(dev) != frequency) {
		last_frequency = frequency;
		frequency = rtlsdr_get_center_freq(dev);
	}
	if (rtlsdr_get_sample_rate(dev) != rate) {
		last_rate = rate;
		rate = rtlsdr_get_sample_rate(dev);

		if (last_rate != 0)
			printf(
"      </rdf:Seq>\n"
"     </xmpDM:markers>\n"
"    </rdf:li>\n"
"   </rdf:Bag>\n"
"  </xmpDM:Tracks>\n"
			);

		printf(
"  <xmpDM:Tracks>\n"
"    <rdf:li rdf:parseType='Resource'>\n"
"     <xmpDM:frameRate>f%u</xmpDM:frameRate>\n"
"     <xmpDM:markers>\n"
"      <rdf:Seq>\n",
			rate
		);
	}
}

void handle_time(struct timespec t)
{
	if (0 == data_pending) {
		last_time = t;
		return;
	}
	printf(
"       <rdf:li rdf:parseType='Resource'>\n"
"        <xmpDM:startTime>%lu</xmpDM:startTime>\n"
"        <xmpDM:duration>%lu</xmpDM:duration>\n"
"        <xmpDM:cuePointParams>\n"
"         <rdf:Seq>\n"
"          <rdf:li rdf:parseType='Resource'>\n"
"           <xmpDM:key>RequestTime</xmpDM:key>\n"
"           <xmpDM:value>%lu.%09lu</xmpDM:value>\n"
"          </rdf:li>\n"
"          <rdf:li rdf:parseType='Resource'>\n"
"           <xmpDM:key>ResultTime</xmpDM:key>\n"
"           <xmpDM:value>%lu.%09lu</xmpDM:value>\n"
"          </rdf:li>\n",
		last_frame,
		frame - last_frame,
		last_time.tv_sec, last_time.tv_nsec,
		t.tv_sec, t.tv_nsec
	);
	if (last_frequency != frequency) {
    		printf(
"          <rdf:li rdf:parseType='TuneTo'>\n"
"           <xmpDM:key>TuneFrequency</xmpDM:key>\n"
"           <xmpDM:value>%u</xmpDM:value>\n"
"          </rdf:li>\n",
			frequency
		);
		last_frequency = frequency;
	}
	printf(
"       </rdf:li>\n"
	);
	data_pending = 0;
	last_time = t;
}

void tail()
{
	printf(
" </rdf:Description>\n"
"</rdf:RDF>\n"
"</x:xmpmeta>\n"
"<?xpacket end='w'?>\n"
	);
}

int main(int argc, const char ** argv)
{
	FILE * file = stdin;
	if (argc == 2)
		file = fopen(argv[1], "rb");
	head();
	readlogfile(file, handle_data, handle_time, handle_struct);
	tail();
	return 0;
}
