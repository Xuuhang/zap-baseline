# Customized Owasp ZAP Dockerfile with support for authentication

FROM owasp/zap2docker-weekly
LABEL maintainer="Dick Snel <dick.snel@ictu.nl>"

USER root

# Install Ruby
RUN apt-get update
RUN apt-get install -y curl gnupg build-essential
RUN curl -sSL https://rvm.io/mpapis.asc | gpg --import
RUN curl -sSL https://rvm.io/pkuczynski.asc | gpg --import
RUN curl -sSL https://get.rvm.io | bash -s stable
#RUN source /etc/profile.d/rvm.sh
RUN /bin/bash -l -c "rvm requirements"
RUN /bin/bash -l -c "rvm install ruby-2.6.3"

# Install Apache2 & passenger & some dependencies
RUN apt-get install -y apache2 apache2-dev nodejs libmysqlclient-dev libcurl4-openssl-dev
RUN /bin/bash -l -c "gem install passenger -v '>= 6.0'"
RUN passenger-install-apache2-module -a --languages "ruby"

# Install Selenium compatible firefox
RUN apt-get -y remove firefox

RUN cd /opt && \
	wget -qO- -O geckodriver.tar.gz https://github.com/mozilla/geckodriver/releases/download/v0.20.1/geckodriver-v0.20.1-linux64.tar.gz && \
	tar -xvzf geckodriver.tar.gz && \
	chmod +x geckodriver && \
	ln -s /opt/geckodriver /usr/bin/geckodriver && \
	export PATH=$PATH:/usr/bin/geckodriver

RUN cd /opt && \
	wget -qO- -O firefox.tar.bz2 http://ftp.mozilla.org/pub/firefox/releases/62.0.3/linux-x86_64/en-US/firefox-62.0.3.tar.bz2 && \
	bunzip2 firefox.tar.bz2 && \
	tar xvf firefox.tar && \
	ln -s /opt/firefox/firefox /usr/bin/firefox

RUN pip2 install selenium
RUN pip2 install pyvirtualdisplay

# Support for using the deprecated version
COPY zap-baseline-custom.py /zap/
COPY auth_hook.py /zap/
COPY zap_webdriver.py /zap/

RUN chown zap:zap /zap/zap-baseline-custom.py  && \
		chown zap:zap /zap/auth_hook.py && \
		chown zap:zap /zap/zap_webdriver.py && \
		chmod +x /zap/zap-baseline-custom.py

WORKDIR /zap
