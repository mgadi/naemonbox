prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
LIBDIR=${exec_prefix}/lib
#DATAROOTDIR=@datarootdir@

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)$(CFGDIR)
	$(INSTALL) -m 664 $(INSTALL_OPTS) nagios-bp.conf-sample $(DESTDIR)$(CFGDIR)
	$(INSTALL) -m 664 $(INSTALL_OPTS) ndo.cfg-sample $(DESTDIR)$(CFGDIR)
	$(INSTALL) -m 664 $(INSTALL_OPTS) settings.cfg $(DESTDIR)$(CFGDIR)

