prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
DATAROOTDIR=@datarootdir@
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:
	-rm nagios-bp.cgi
	-rm whereUsed.cgi

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)$(CGIDIR)
	$(INSTALL) -m 755 $(INSTALL_OPTS) *.cgi $(DESTDIR)$(CGIDIR)	
