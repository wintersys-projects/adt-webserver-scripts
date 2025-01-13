if ( [ -d /root/scratch ] )                                             
then                                                                  
  /bin/rm -r /root/scratch                                        
else                                                                   
  /bin/mkdir /root/scratch                                        
fi                                                                      

cwd="`/usr/bin/pwd`"                                                    
/usr/bin/git clone https://github.com/kahing/goofys.git /root/scratch                                          
cd /root/scratch                                                                                        
/usr/bin/make install                                                                                  

if ( [ -f ${HOME}/go/bin/goofys ] )                                                                      
then                                                                                                    
  /bin/mv ${HOME}/go/bin/goofys /usr/bin                                                                  
  /bin/chmod 755 /usr/bin/goofys                                                                  
fi                                                                                                      

if ( [ -d /root/scratch ] )                                                                             
then                                                                                                   
  /bin/rm -r /root/scratch                                                                        
fi                                                                                                      
cd ${cwd}
/bin/touch ${HOME}/runtime/installedsoftware/InstallGoofyFS.sh	
