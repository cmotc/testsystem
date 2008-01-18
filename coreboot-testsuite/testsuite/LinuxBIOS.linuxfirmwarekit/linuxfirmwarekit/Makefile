
OBJECTS:=
OBJECTS:=$(OBJECTS) linuxfirmwarekit/libstandalone.so
OBJECTS:=$(OBJECTS) linuxfirmwarekit/plugins
OBJECTS:=$(OBJECTS) linuxfirmwarekit/run-test.sh
OBJECTS:=$(OBJECTS) linuxfirmwarekit/REVISION

linuxfirmwarekit.tar.bz2:
	svn export http://linuxfirmwarekit.googlecode.com/svn/trunk linuxfirmwarekit
	svn info http://linuxfirmwarekit.googlecode.com/svn/trunk|grep Revision &> linuxfirmwarekit/REVISION
	cd linuxfirmwarekit; patch -p0 < ../firmwarekit-pluginsonly.diff
	cd linuxfirmwarekit; make subdirs
	cd linuxfirmwarekit; make libstandalone.so
	cp run-test.sh linuxfirmwarekit
	tar cvjf linuxfirmwarekit.tar.bz2 $(OBJECTS)

clean:
	rm -rf linuxfirmwarekit

distclean: clean
	rm -f linuxfirmwarekit.tar.bz2

