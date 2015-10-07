# Customize the following lines if needed

PREFIX=/usr/local

BINDIR=$(PREFIX)/bin
AWKLIB=$(PREFIX)/share/awklib
AWKFILE_DIR=$(PREFIX)/share/weather
MANDIR=$(PREFIX)/share/man/man1

# END of custom lines

install:
	sed "s#AWKLIB=.*#AWKLIB=$$\{AWKLIB:-$(AWKLIB)\}#;s#AWKFILE_DIR=.*#AWKFILE_DIR=$$\{AWKFILE_DIR:-$(AWKFILE_DIR)\}#" < weather.sh > weather.sh.new
	test -d $(BINDIR) || mkdir -p $(BINDIR)
	install -m 0755 weather.sh.new $(BINDIR)/weather
	rm weather.sh.new
	test -d $(AWKFILE_DIR) || mkdir -p $(AWKFILE_DIR)
	install -m 0644 weather.awk $(AWKFILE_DIR)
	test -d $(MANDIR) || mkdir -p $(MANDIR)
	install -m 0644 weather.1 $(MANDIR)

clean:
	rm -f weather.sh.new

.PHONY: install clean
