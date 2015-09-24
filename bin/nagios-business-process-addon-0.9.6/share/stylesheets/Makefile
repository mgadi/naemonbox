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
TOUCH=/usr/bin/touch

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DATADIR)/stylesheets
	for file in ./*.css; \
	do $(INSTALL) -m 664 $(INSTALL_OPTS) $$file $(DATADIR)/stylesheets; done
	${TOUCH} $(DATADIR)/stylesheets/user.css
