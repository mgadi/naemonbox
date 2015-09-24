prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
DATAROOTDIR=@datarootdir@
LIBEXECDIR=${exec_prefix}/libexec

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 755 $(INSTALL_OPTS) -d $(LOGDIR)/cache
	$(INSTALL) -m 666 $(INSTALL_OPTS) ndo_backend_cache $(LOGDIR)/cache/

