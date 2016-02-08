prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
DATAROOTDIR=@datarootdir@
DATADIR=${prefix}/share

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DATADIR)/lang
	for file in ./*.txt; \
	do $(INSTALL) -m 664 $(INSTALL_OPTS) $$file $(DATADIR)/lang; done
