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
	-rm check_bp_status.pl

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(LIBEXECDIR)
	$(INSTALL) -m 755 $(INSTALL_OPTS) check_bp_status.pl $(LIBEXECDIR)

