
if ( [ -f /usr/sbin/a2enmod ] )
then
        if ( [ ! -d /etc/apache2/mods-enabled ] )
        then
                /bin/mkdir -p /etc/apache2/mods-enabled
        fi
        
        /usr/sbin/a2enmod security2
fi

/bin/cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

/bin/sed -i 's/^SecRuleEngine.*/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf
/bin/sed -i 's/^SecResponseBodyAccess.*/SecResponseBodyAccess Off/' /etc/modsecurity/modsecurity.conf
/bin/sed -i 's/^SecRequestBodyLimit.*/SecRequestBodyLimit 74448896/' /etc/modsecurity/modsecurity.conf

git clone https://github.com/coreruleset/coreruleset.git

cd coreruleset/

mv crs-setup.conf.example /etc/modsecurity/crs-setup.conf

mv rules/ /etc/modsecurity/

if ( [ -f /etc/apache2/mods-available/security2.conf ] )
then
        /bin/sed -i "s/IncludeOptional/#IncludeOptional/g" /etc/apache2/mods-available/security2.conf
      #  /bin/echo "IncludeOptional /etc/modsecurity/*.conf" >> /etc/apache2/mods-available/security2.conf
      #  /bin/echo "Include /etc/modsecurity/rules/*.conf" >> /etc/apache2/mods-available/security2.conf
fi

if ( [ -f /etc/apache2/modules.conf ] && [ -f /usr/lib/apache2/modules/mod_security2.so ] )
then
        /bin/echo "LoadModule unique_id_module /usr/lib/apache2/modules/mod_unique_id.so" >> /etc/apache2/modules.conf
        /bin/echo "LoadModule security2_module /usr/lib/apache2/modules/mod_security2.so" >> /etc/apache2/modules.conf
        /bin/echo "LoadModule lbmethod_byrequests_module /usr/lib/apache2/modules/mod_lbmethod_byrequests.so" >> /etc/apache2/modules.conf
        /bin/echo "LoadModule proxy_balancer_module /usr/local/apache2/modules/mod_proxy_balancer.so" >> /etc/apache2/modules.conf
        /bin/echo "LoadModule slotmem_shm_module /usr/local/apache2/modules/mod_slotmem_shm.so" >> /etc/apache2/modules.conf
fi
