INSTALL = install
PREFIX  = /usr/local
INSTALL_LIB = $(PREFIX)/lib

all: linenoise.c linenoise.h
	$(CC) -Wall -W -Os -fPIC -c linenoise.c -o linenoise.o
	$(CC) -shared linenoise.o -o liblinenoise.so

install: all
	$(INSTALL) liblinenoise.so $(INSTALL_LIB)

uninstall:
	rm -f $(INSTALL_LIB)/liblinenoise.so

clean:
	rm -f liblinenoise.so linenoise.o
