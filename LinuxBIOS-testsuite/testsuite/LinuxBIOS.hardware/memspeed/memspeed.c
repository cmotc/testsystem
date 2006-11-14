#include <stdio.h>
#include <stdlib.h>
#define MAX_SIZE (16*1024*1024)
#define COUNT 1000

int print_size(size_t size)
{
	double s=(double) size;
	int pot=0;
	while (s>1000) {
		s=s/1024;
		pot++;
	}
	printf("%5.1f ",s);
	switch (pot) {
	case 0: printf (" B");break;
	case 1: printf ("KB");break;
	case 2: printf ("MB");break;
	}
	return 0;
}

static inline void long_copy(void *p1, size_t size)
{
	struct timeval _tstart, _tend;
	double t1, t2, total;
	int i;
	size_t j;
	long *dst, src=0xdeadbabe; 
	unsigned long count;

	count = 819200 * 1024 / size;
		

	printf ("Testing ");
	print_size(size);
	
	// start measuring time.
	gettimeofday(&_tstart, NULL);
	
	// main loop
	for (i=0; i<count; i++) {
		dst = (long *)p1;

		for (j=0; j<size; j += 4*sizeof(long)) {
			*dst++ = src;
			*dst++ = src;
			*dst++ = src;
			*dst++ = src;
		}
	}
	
	// get required time
	gettimeofday(&_tend, NULL);
	t1 =  (double)_tstart.tv_sec + (double)_tstart.tv_usec * 1e-6;
	t2 =  (double)_tend.tv_sec + (double)_tend.tv_usec * 1e-6;
	total=t2-t1;
	
	printf (" %8.2f seconds, %8.3f MB/s \n",total,
			(double)size*count/total/(1.0*1024*1024));
	fflush(stdout);
}


int main(void)
{
	void *src, *dst;
	int i;

	double total;

	dst=malloc(MAX_SIZE+sizeof(long));

	if (!dst) {
		printf("MEMSPEED: FATAL ERROR - NO MEMORY\n");
		exit(1);
	}
	
	// function overhead impacts speed:
	//long_copy(src, dst, 1024);
	
	long_copy(dst, 4096);
	long_copy(dst, 16*1024);
	long_copy(dst, 32*1024);
	long_copy(dst, 64*1024);
	long_copy(dst, 128*1024);

	long_copy(dst, 256*1024);

	long_copy(dst, 512*1024);
	long_copy(dst, 1024*1024);
	long_copy(dst, 16*1024*1024);

	return 0;
}
