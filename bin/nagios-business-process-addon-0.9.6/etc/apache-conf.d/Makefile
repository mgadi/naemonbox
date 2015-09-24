prefix=/usr/local/nagiosbp
exec_prefix=${prefix}
LOGDIR=${prefix}/var
CFGDIR=${prefix}/etc
BINDIR=${exec_prefix}/bin
CGIDIR=${exec_prefix}/sbin
LIBDIR=${exec_prefix}/lib
DATAROOTDIR=@datarootdir@
HTTPD_CONF=/etc/httpd/conf.d

INSTALL=/usr/bin/install -c
INSTALL_OPTS=-o naemon -g naemon

CP=/bin/cp

all html:

clean:

distclean: clean
	-rm Makefile

devclean: distclean

install:
	$(INSTALL) -m 775 $(INSTALL_OPTS) -d $(DESTDIR)$(HTTPD_CONF)
	$(INSTALL) -m 664 $(INSTALL_OPTS) nagiosbp.conf $(DESTDIR)$(HTTPD_CONF)

