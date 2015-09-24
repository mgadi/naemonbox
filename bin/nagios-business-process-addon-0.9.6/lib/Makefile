prefix=/usr/local/nagiosbp
DATAROOTDIR=@datarootdir@
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
LIBDIR=${exec_prefix}/lib

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:
	-rm nagiosBp.pm
	-rm ndodb.pm
	-rm bsutils.pm
	-rm settings.pm

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)$(LIBDIR)
	$(INSTALL) -m 664 $(INSTALL_OPTS) *.pm $(DESTDIR)$(LIBDIR)	
