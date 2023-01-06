#!/bin/bash
#prompt for vars
read -p "Enter state: " state
read -p "Enter city: " city
read -p "Enter organization: " org
read -p "Enter orgranizational unit: " org_unit
read -p "Enter capass 6+ characters: " capass
read -p "Enter pass 6+ characters: " pass

#refresh CoreConfig.xml if script has ran before
sudo cp /opt/tak/CoreConfig.xml.BEFORESCRIPTRAN /opt/tak/CoreConfig.xml

#copy CoreConfig.xml to CoreConfig.xml.BEFORESCRIPTRAN
sudo cp /opt/tak/CoreConfig.xml /opt/tak/CoreConfig.xml.BEFORESCRIPTRAN

#prompt for letsencrypt
read -p "Enter the domain: " domain
read -p "Enter your email: " email

#replace vars in cert-metadata.sh
sudo sed -i 's+STATE=.*+STATE='$state'+g' /opt/tak/certs/cert-metadata.sh
sudo sed -i 's+CITY=.*+CITY='$city+'g' /opt/tak/certs/cert-metadata.sh
sudo sed -i 's+ORGANIZATION=.*+ORGANIZATION='$org_unit'+g' /opt/tak/certs/cert-metadata.sh
sudo sed -i 's+ORGANIZATIONAL_UNIT=.*+ORGANIZATIONAL_UNIT='$org_unit'+g' /opt/tak/certs/cert-metadata.sh
sudo sed -i 's+CAPASS=.*+CAPASS='$capass'+g' /opt/tak/certs/cert-metadata.sh
sudo sed -i 's+PASS=.*+PASS='$pass'+g' /opt/tak/certs/cert-metadata.sh

#Make the certs and edit the CoreConfig.xml
read -p "Enter CA cert name: " cacert
read -p "Enter Server cert name: " server

cd /opt/tak/certs/

sudo ./makeRootCa.sh --ca-name tak-ca #uses capass
sudo ./makeCert.sh ca $cacert #uses pass
sudo ./makeCert.sh server $server #uses pass

#Add auth, cert signing and port 8089
sudo sed -i '4 a\        <input _name="stdssl" auth="x509" protocol="tls" port="8089" />' /opt/tak/CoreConfig.xml
sudo sed -i 's|    <auth>|    <auth x509groups="true" x509addAnonymous="true">|g' /opt/tak/CoreConfig.xml
sudo sed -i '59 a\    <certificateSigning CA="TAKServer">' /opt/tak/CoreConfig.xml
sudo sed -i '60 a\        <certificateConfig>' /opt/tak/CoreConfig.xml
sudo sed -i '61 a\            <nameEntries>' /opt/tak/CoreConfig.xml
sudo sed -i '62 a\                <nameEntry name="O" value="TAK"/>' /opt/tak/CoreConfig.xml
sudo sed -i '63 a\                <nameEntry name="OU" value="TAK"/>' /opt/tak/CoreConfig.xml
sudo sed -i '64 a\            </nameEntries>' /opt/tak/CoreConfig.xml
sudo sed -i '65 a\        </certificateConfig>' /opt/tak/CoreConfig.xml
sudo sed -i '66 a\        <TAKServerCAConfig keystore="JKS" keystoreFile="certs/files/'$cacert'-signing.jks" keystorePass="'$pass'" validityDays="30" signatureAlg="SHA256WithRSA"/>' /opt/tak/CoreConfig.xml
sudo sed -i '67 a\    </certificateSigning>' /opt/tak/CoreConfig.xml

#replace ca truststore line
sudo sed -i '71d' /opt/tak/CoreConfig.xml
sudo sed -i '70 a\        <tls keystore="JKS" keystoreFile="certs/files/'$server'.jks" keystorePass="'$pass'" truststore="JKS" truststoreFile="certs/files/truststore-'$cacert'.jks" truststorePass="'$pass'" context="TLSv1.2" keymanager="SunX509"/>' /opt/tak/CoreConfig.xml

#replace fed truststore line
sudo sed -i '75d' /opt/tak/CoreConfig.xml
sudo sed -i '74 a\           <tls keystore="JKS" keystoreFile="certs/files/'$server'.jks" keystorePass="'$pass'" truststore="JKS" truststoreFile="certs/files/fed-truststore.jks" truststorePass="'$pass'" keymanager="SunX509"/>' /opt/tak/CoreConfig.xml

#install letsencrypt
sudo apt install snapd -y
sudo snap install core; sudo snap refresh core
sudo snap install --classic certbot
sudo ln -s /snap/bin/certbot /usr/bin/certbot
sudo certbot certonly --standalone --non-interactive --agree-tos --email $email --domains $domain

#var for domain for key names
domaindash=${domain//./-}

#setup ssl keys
echo -e '\n\nMake up your Export Password\n'
sudo openssl pkcs12 -export -in /etc/letsencrypt/live/$domain/fullchain.pem -inkey /etc/letsencrypt/live/$domain/privkey.pem -name $domaindash -out ~/takserverscripts/$domaindash.p12
echo -e '\n\nUse your Export Password\n'
sudo keytool -importkeystore -deststorepass $pass -destkeystore ~/takserverscripts/$domaindash.jks -srckeystore ~/takserverscripts/$domaindash.p12 -srcstoretype PKCS12
echo -e '\n\nuse '$pass' for next input\n'
sudo keytool -import -alias bundle -trustcacerts -file /etc/letsencrypt/live/$domain/fullchain.pem -keystore ~/takserverscripts/$domaindash.jks

#put ssl key files into /opt/tak/certs/files/letsencrypt
sudo mkdir /opt/tak/certs/files/letsencrypt
sudo cp ~/takserverscripts/$domaindash.jks /opt/tak/certs/files/letsencrypt
sudo cp ~/takserverscripts/$domaindash.p12 /opt/tak/certs/files/letsencrypt

#add port 8446 ssl cert to CoreConfig.xml
port8446='<connector port="8446" _name="cert_https" truststorePass="'$pass'" truststoreFile="certs/files/truststore-'$cacert'.jks" truststore="JKS" keystorePass="'$pass'" keystoreFile="certs/files/letsencrypt/'$domaindash'.jks" keystore="JKS" clientAuth="false"/>'
sudo sed -i "s|<connector port=\"8446\" clientAuth=\"false\" _name=\"cert_https\"/>|$port8446|g" /opt/tak/CoreConfig.xml
sudo systemctl restart takserver
echo -e "wait for server to come up then you are good to go"
