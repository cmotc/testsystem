#
#  LinuxBIOS autotest
#
#  LinuxBIOS regression testing.
#
#  (C) 2006 by coresystems GmbH <info@coresystems.de>
#
#  This file is subject to the terms and conditions of the GNU General
#  Public License. See the file COPYING in the main directory of this
#  archive for more details.
#

all: all-info 
	@printf 'To run all tests, do:\n\n  $$ make all-tests\n\n'

all-info:
	@bin/check-images.sh

all-tests:
	@bin/test-images.sh

all-uploads:
	@bin/upload-results.sh

clean:
	rm -rf results
	rm -f images/abuild-*/*/linuxbios.result

distclean: clean

