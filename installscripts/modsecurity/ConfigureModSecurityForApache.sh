if ( [ ! -d /etc/apache2/mods-enabled ] )
then
        /bin/mkdir /etc/apache2/mods-enabled
fi

if ( [ -f /usr/sbin/a2enmod ] )
then
        /usr/sbin/a2enmod security2
fi

/bin/sed -i "s/IncludeOptional/#IncludeOptional/g" /etc/apache2/mods-enabled/security2.conf
/bin/cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

/bin/sed -i 's/^SecRuleEngine.*/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
/bin/sed -i 's/^SecResponseBodyAccess.*/SecResponseBodyAccess Off/' /etc/modsecurity/modsecurity.conf
/bin/sed -i 's/^SecRequestBodyLimit.*/SecRequestBodyLimit 74448896/' /etc/modsecurity/modsecurity.conf

git clone https://github.com/coreruleset/coreruleset.git

cd coreruleset/

mv crs-setup.conf.example /etc/modsecurity/crs-setup.conf

mv rules/ /etc/modsecurity/

if ( [ -f /etc/apache2/mods-enabled/security2.conf ] )
then
        /bin/echo "IncludeOptional /etc/modsecurity/*.conf" >> /etc/apache2/mods-enabled/security2.conf
        /bin/echo "Include /etc/modsecurity/rules/*.conf" >> /etc/apache2/mods-enabled/security2.conf
fi

if ( [ -f /etc/apache2/modules.conf ] && [ -f /usr/lib/apache2/modules/mod_security2.so ] )
then
        /bin/echo "LoadModule security2_module /usr/lib/apache2/modules/mod_security2.so" >> /etc/apache2/modules.conf
fi
