prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
LIBDIR=${exec_prefix}/lib
DATAROOTDIR=@datarootdir@
CRON_D_DIR=/etc/cron.d

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)$(CRON_D_DIR)
	$(INSTALL) -m 640 $(INSTALL_OPTS) nagiosbp $(DESTDIR)$(CRON_D_DIR)

