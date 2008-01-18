#include <stdio.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <termios.h>

// This function is using DTR and RTS as these are
// two freely programmable output lines of the serial
// signal.

// We're using the two signals with a small logic to
// switch between bioses and turn on a machine using
// the ATX power button.

int toggle_port(int serfd, int port, int status)
{
	int arg=0;

	ioctl(serfd, TIOCMGET, &arg);

	if(port==0 && status==0) 
		arg &= ~TIOCM_DTR;
	if(port==1 && status==0)
		arg &= ~TIOCM_RTS;
	if(port==0 && status!=0) 
		arg |= TIOCM_DTR;
	if(port==1 && status!=0)
		arg |= TIOCM_RTS;

	ioctl(serfd, TIOCMSET, &arg);
}



int main(int argc, char *argv[])
{
	int serfd;
	int iosw=0, iopos=0;

	// setbios <device> [0|1] [on|off]

	if (argc!=4) {
		printf("usage: %s <device> [0|1] [on|off]\n", argv[0]);	
		return 1;
	}

	serfd = open(argv[1], O_RDWR);
	if(serfd==-1) {
		printf("error: could not connect to ioswitch on %s\n", argv[1]);
		return 1;
	}

	iosw=atoi(argv[2]);
	if (iosw!=0 && iosw != 1) {
		printf("error: only two io ports available: 0 and 1\n");
		return 1;
	}

	if(!strcmp(argv[3], "on")) {
		iopos=1;
	} else if(!strcmp(argv[3], "off")) {
		iopos=0;
	} else {
		printf("error: only two positions available: on and off\n");
		return 1;
	}

	toggle_port(serfd, iosw, iopos);

	close(serfd);
	return 0;
}

