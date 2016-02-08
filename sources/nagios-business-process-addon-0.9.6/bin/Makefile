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
	-rm bp_cfg2service_cfg.pl
	-rm nagios-bp-consistency-check.pl

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(BINDIR)
	$(INSTALL) -m 755 $(INSTALL_OPTS) *.pl $(BINDIR)
	$(INSTALL) -m 755 $(INSTALL_OPTS) nagios_bp_session_timeout $(BINDIR)

