/* streaming DAC */


#include <stdio.h>
#include <unistd.h>
#include <vector>
#include "popt.h"

using namespace std;

#include "Buffer.h"
#include "knobs.h"
#include "tcp_server.h"

namespace G {
	unsigned play_bufferlen;		// Change bufferlen on play
	char* port = 0;				// 0 no server (inetd), else make a server
	char* host = 0;
	int verbose = 0;
	const char *dev = "/dev/acq400.0.dac";
};

struct poptOption opt_table[] = {
	{
	  "port", 'p', POPT_ARG_STRING, &G::port, 0, "server port 0: no tcp server (using inetd)"
	},
	{
	  "host", 'H', POPT_ARG_STRING, &G::host, 0, "server host 0: allow any host"
	},
	{
          "dev",  'd', POPT_ARG_STRING, &G::dev, 0, "device"
	},
	{
	  "verbose", 'v', POPT_ARG_INT, &G::verbose, 0, "debug"
	},
	POPT_AUTOHELP
	POPT_TABLEEND
};

int read_buffers(unsigned descriptors[], int ndesc)
{
	int totbytes = 0;

	if (G::verbose) fprintf(stderr, "%s %d\b", __FUNCTION__, __LINE__);
	for (int id = 0; id < ndesc; ++id){
		char* bp = Buffer::the_buffers[0]->getBase() + descriptors[id]*Buffer::bufferlen;
		int nb = fread(bp, 1, G::play_bufferlen, stdin);
		if (nb <= 0){
			fprintf(stderr, "read_buffers fread returned %d\n", nb);
			return 0;
		}else{
			totbytes += nb;
		}
	}
	if (G::verbose) fprintf(stderr, "%s %d\b", __FUNCTION__, __LINE__);
	return totbytes;
}

int playloop() {
	unsigned descriptors[2];

	FILE* fp = fopen(G::dev, "a+");
	if (fp == 0){
		fprintf(stderr, "ERROR failed to open file\n");
		return -1;
	}
	setvbuf(fp, NULL, _IONBF, 0);

	if (G::verbose) fprintf(stderr, "%s %d\b", __FUNCTION__, __LINE__);

	while(1){
		if (G::verbose) fprintf(stderr, "%s %d\b", __FUNCTION__, __LINE__);
		int nr = fread(descriptors, sizeof(unsigned), 2, fp);
		if (nr == 2){
			printf("rd %08x %08x\n", descriptors[0], descriptors[1]);
		}else{
			printf("read returned %d\n", nr);
			return -1;
		}

		int nbytes = read_buffers(descriptors, 2);
		if (nbytes <= 0){
			return nbytes;
		}

		if (G::verbose) fprintf(stderr, "%s %d\b", __FUNCTION__, __LINE__);
		int nw = fwrite(descriptors, sizeof(unsigned), 2, fp);
		if (nw == 2){
			printf("wr %08x %08x\n", descriptors[0], descriptors[1]);
		}else{
			printf("write returned %d\n", nw);
			return -1;
		}
	}
	return 0;
}

int playloop_redirect(FILE* fin, FILE* fout)
{
	close(0); dup(fileno(fin));
	return playloop();
}

#define MODPRAMS "/sys/module/acq420fmc/parameters/"
#define BUFLEN	 MODPRAMS "bufferlen"
#define NBUF	 MODPRAMS "nbuffers"

void ui(int argc, const char** argv)
{
	poptContext opt_context =
			poptGetContext(argv[0], argc, argv, opt_table, 0);

	int rc;

	while ( (rc = poptGetNextOpt( opt_context )) >= 0 ){
		switch(rc){
		default:
			;
		}
	}
	getKnob(-1, BUFLEN, &Buffer::bufferlen);
	getKnob(-1, "/etc/acq400/0/dist_bufferlen_play", &G::play_bufferlen);
	if (G::play_bufferlen == 0){
		G::play_bufferlen = Buffer::bufferlen;
	}
}
int main(int argc, const char* argv[]) {
	ui(argc, argv);
	BufferManager bm("/dev/acq400.0", 0);
	if (G::port){
		return tcp_server(G::host, G::port, playloop_redirect);
	}else{
		return playloop();
	}
}
