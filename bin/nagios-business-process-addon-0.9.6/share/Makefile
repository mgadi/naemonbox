prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
HTMLDIR=@HTML_DIR@
INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon
#DATAROOTDIR=@datarootdir@
DATADIR=${prefix}/share

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DATADIR)
	for file in ./*.gif; \
	do $(INSTALL) -m 664 $(INSTALL_OPTS) $$file $(DATADIR); done
	
