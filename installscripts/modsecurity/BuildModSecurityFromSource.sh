cd /opt
/usr/bin/git clone https://github.com/owasp-modsecurity/ModSecurity
cd ModSecurity/
/usr/bin/git submodule init
/usr/bin/git submodule update
/bin/sh build.sh
./configure --with-pcre2
make
make install

cd /opt
/usr/bin/git clone https://github.com/owasp-modsecurity/ModSecurity-nginx.git



/bin/rm -rf /usr/share/modsecurity-crs
/usr/bin/git clone https://github.com/coreruleset/coreruleset /usr/local/modsecurity-crs
/bin/mv /usr/local/modsecurity-crs/crs-setup.conf.example /usr/local/modsecurity-crs/crs-setup.conf
/bin/mv /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf.example /usr/local/modsecurity-crs/rules/REQUEST-900-EXCLUSION-RULES-BEFORE-CRS.conf
/bin/mkdir -p /etc/nginx/modsec
/bin/cp /opt/ModSecurity/unicode.mapping /etc/nginx/modsec
/bin/cp /opt/ModSecurity/modsecurity.conf-recommended /etc/nginx/modsec
/bin/cp /etc/nginx/modsec/modsecurity.conf-recommended /etc/nginx/modsec/modsecurity.conf

/bin/sed -i 's/^SecRuleEngine.*/SecRuleEngine On/' /etc/nginx/modsec/modsecurity.conf
/bin/sed -i 's/^SecResponseBodyAccess.*/SecResponseBodyAccess Off/' /etc/nginx/modsec/modsecurity.conf
/bin/sed -i 's/^SecRequestBodyLimit.*/SecRequestBodyLimit 74448896/' /etc/nginx/modsec/modsecurity.conf


/bin/echo "Include /etc/nginx/modsec/modsecurity.conf" > /etc/nginx/modsec/main.conf
/bin/echo "Include /usr/local/modsecurity-crs/crs-setup.conf" >> /etc/nginx/modsec/main.conf
/bin/echo "Include /usr/local/modsecurity-crs/rules/*.conf" >> /etc/nginx/modsec/main.conf

#/bin/rm  /usr/local/modsecurity-crs/rules/RESPONSE-959-BLOCKING-EVALUATION.conf



