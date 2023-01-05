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

Wait for script to do its thing, it can take anywhere from 5 minutes (good vps) to 40 minutes (pi 4)

You must have a public ip/hostname to use this script in order for letsencrypt to work properly
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
