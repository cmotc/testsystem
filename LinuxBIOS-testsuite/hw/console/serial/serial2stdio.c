/*
 * serial2stdio.c:
 *
 * Copyright (c) 2002 James McKenzie <james@fishsoup.dhs.org>,
 * Copyright (c) 2006 coresystems GmbH <info@coresystems.de>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 *
 */

#include <fcntl.h>
#include <signal.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>
#include <termios.h>
#include <unistd.h>

#include <errno.h>



int serial_open(char *name, int speed)
{
  int fd;
  struct termios tios;
  int baud = 0;
  fd = open(name, O_RDWR | O_NDELAY);

  if (fd < 0)
    return -1;

  tcgetattr(fd, &tios);

  tios.c_cflag &= ~(CSIZE | CSTOPB | PARENB | CLOCAL | CRTSCTS);
  // tios.c_cflag |= CLOCAL;
  tios.c_cflag |= CS8;

  tios.c_cflag |= CREAD;
  tios.c_iflag = IGNBRK | IGNPAR;

  tios.c_oflag = 0;
  tios.c_lflag = 0;
  tios.c_cc[VMIN] = 1;
  tios.c_cc[VTIME] = 0;

//Fixme: maybe a numeric to Bxxxx speed converter switch stm here...

  switch (speed) {
#ifdef B50
  case 50:
    baud = B50;
    break;
#endif
#ifdef B75
  case 75:
    baud = B75;
    break;
#endif
#ifdef B110
  case 110:
    baud = B110;
    break;
#endif
#ifdef B134
  case 134:
    baud = B134;
    break;
#endif
#ifdef B150
  case 150:
    baud = B150;
    break;
#endif
#ifdef B200
  case 200:
    baud = B200;
    break;
#endif
#ifdef B300
  case 300:
    baud = B300;
    break;
#endif
#ifdef B600
  case 600:
    baud = B600;
    break;
#endif
#ifdef B1200
  case 1200:
    baud = B1200;
    break;
#endif
#ifdef B1800
  case 1800:
    baud = B1800;
    break;
#endif
#ifdef B2400
  case 2400:
    baud = B2400;
    break;
#endif
#ifdef B4800
  case 4800:
    baud = B4800;
    break;
#endif
#ifdef B9600
  case 9600:
    baud = B9600;
    break;
#endif
#ifdef B19200
  case 19200:
    baud = B19200;
    break;
#endif
#ifdef B38400
  case 38400:
    baud = B38400;
    break;
#endif
#ifdef B57600
  case 57600:
    baud = B57600;
    break;
#endif
#ifdef B115200
  case 115200:
    baud = B115200;
    break;
#endif
#ifdef B230400
  case 230400:
    baud = B230400;
    break;
#endif
#ifdef B460800
  case 460800:
    baud = B460800;
    break;
#endif
#ifdef B500000
  case 500000:
    baud = B500000;
    break;
#endif
#ifdef B576000
  case 576000:
    baud = B576000;
    break;
#endif
#ifdef B921600
  case 921600:
    baud = B921600;
    break;
#endif
#ifdef B1000000
  case 1000000:
    baud = B1000000;
    break;
#endif
#ifdef B1152000
  case 1152000:
    baud = B1152000;
    break;
#endif
#ifdef B1500000
  case 1500000:
    baud = B1500000;
    break;
#endif
#ifdef B2000000
  case 2000000:
    baud = B2000000;
    break;
#endif
#ifdef B2500000
  case 2500000:
    baud = B2500000;
    break;
#endif
#ifdef B3000000
  case 3000000:
    baud = B3000000;
    break;
#endif
#ifdef B3500000
  case 3500000:
    baud = B3500000;
    break;
#endif
#ifdef B4000000
  case 4000000:
    baud = B4000000;
    break;
#endif
  case 0:
    baud = 0;
    break;
  default:
    fprintf(stderr, "Speed %d not supported\n", speed);
  }



  if (baud) {
    cfsetospeed(&tios, baud);
    cfsetispeed(&tios, baud);
  }

  tcsetattr(fd, TCSAFLUSH, &tios);


  return fd;
}

void gp_turn_off_canonical_mode_and_echo()
{
  int fd = 0;
  struct termios tios;

  tcgetattr(fd, &tios);
  tios.c_iflag = IGNBRK | IGNPAR;
  tios.c_lflag &= ~ICANON;
  tios.c_lflag &= ~ECHO;
  tios.c_cc[VMIN] = 1;
  tios.c_cc[VTIME] = 0;

  tcsetattr(fd, TCSAFLUSH, &tios);
}

int main(int argc, char *argv[])
{

  fd_set rd;
  int fd, logfd=1;
  int writetimestamp=1;
  unsigned char buf;
  int q = 0;
  int speed = 0;
  int echo = 0;
  time_t s=0;
  char *logname=NULL;


  signal(SIGPIPE, SIG_IGN);

  switch (argc) {
  case 1:
    fprintf(stderr, "Usage: %s serialport [echo [speed [logfile]]]\n", argv[0]);
    exit(1);
  case 5:
    logname=argv[4];
  case 4:
    speed = atoi(argv[3]);
  case 3:
    echo = atoi(argv[2]);
    break;
  }


  gp_turn_off_canonical_mode_and_echo();

  fd = serial_open(argv[1], speed);
  if (fd == -1) {
    printf("error opening serial device %s.\n", argv[1]);
    exit(1);
  }

  if (logname) {
    logfd = open(logname,O_RDWR|O_CREAT|O_APPEND);
    
    if (logfd==-1) {
      printf("could not open logfile %s.\n", logname);
      exit(1);
    }
 
  }

  /* flush serial device before doing anything. */
  tcflush(fd, TCIOFLUSH);
  
  
  while (1) {
    FD_ZERO(&rd);
    FD_SET(0, &rd);
    FD_SET(fd, &rd);

    select(fd + 1, &rd, NULL, NULL, NULL);

    if(writetimestamp && logname) {
      struct timeval tv;
      struct timezone tz;
      char datestring[]="0000000000.000000   ";

      gettimeofday(&tv, &tz);
      if(!s) s=tv.tv_sec;
      snprintf(datestring,sizeof(datestring),"%03d.%03d ", tv.tv_sec-s,
		      tv.tv_usec/1000); 	
      write(logfd, datestring, strlen(datestring));
      writetimestamp=0;
    }

    if (FD_ISSET(0, &rd)) {
      if (read(0, &buf, 1) == 1) {
        write(fd, &buf, 1);
        if (echo) {
          if ((buf < 31) && (buf != 10))
            fprintf(stderr, "<%02x>", buf);
          else if ((buf > 126))
            fprintf(stderr, "<%02x>", buf);
          else
            fprintf(stderr, "%c", buf);
        }
      } else {
        /* flush serial device before doing anything. */
        tcflush(fd, TCIOFLUSH);
	close(fd);
        exit(1);
      }

    }

    if (FD_ISSET(fd, &rd)) {
      if (read(fd, &buf, 1) == 1) {
        if (write(1, &buf, 1) != 1) {
          /* flush serial device before doing anything. */
          tcflush(fd, TCIOFLUSH);
	  close(fd);
          exit(1);
	}

	if(logname) {
	  write(logfd, &buf, 1);
	  // printf(" %s\n", strerror(errno));
	  if(buf=='\n')
	    writetimestamp=1;
	}
      }
    }
    
  }

}
