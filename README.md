# takserverscripts
scripts to install takserver.deb and setup certs/letsencrypt

cd ~

git clone https://github.com/matt-desmarais/takserverscripts

copy takserver_4.8-RELEASE31_all.deb into takserverscripts folder

chmod +x install.sh
</br>
./install.sh

Enter Admin name:
</br>
Enter Admin password:
</br></br>
Wait for script to do its thing, it can take anywhere from 5 minutes (good vps) to 40 minutes (pi 4)
</br></br>
You must have a public ip/hostname to use this script in order for letsencrypt to work properly
</br>
chmod +x certs+letsencrypt.sh
</br>
./certs+letsencrypt.sh

Enter state: 
</br>
Enter city: 
</br>
Enter organization: 
</br>
Enter orgranizational unit:
</br>
Enter capass: 
</br>
Enter pass: 
</br>
Enter the domain: 
</br>
Enter your email: 
</br>
Enter CA cert name: 
</br>
Enter Server cert name: 

This script won't take long to run and needs your attention

Answer YES to any Y/N prompts
</br>
Congrats you are now ready to use your Tak server

If you want to secure your server edit /opt/tak/CoreConfig.xml
</br>
&emsp;&emsp;&emsp;&emsp;&lt;input _name="stdssl" auth="x509" protocol="tls" port="8089" /&gt;</br>
remove&nbsp;&nbsp;&lt;input auth="anonymous" _name="stdudp" protocol="udp" port="8087"/&gt;</br>
remove&nbsp;&nbsp;&lt;input auth="anonymous" _name="streamtcp" protocol="stcp" port="8088"/&gt;</br>
&emsp;&emsp;&emsp;&emsp;&lt;connector port="8443" _name="https"/&gt;</br>
&emsp;&emsp;&emsp;&emsp;&lt;connector port="8444" useFederationTruststore="true" _name="fed_https"/&gt;</br>
&emsp;&emsp;&emsp;&emsp;&lt;connector port="8446" _name="cert_https" truststorePass="password" truststoreFile="certs/files/trust...</br>
remove&nbsp;&nbsp;&lt;connector port="8080" tls="false" _name="http_plaintext"/&gt;</br>
