# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
	config.vm.define "dudle"

	config.vm.network "forwarded_port", guest: 80, host: 8080
	config.vm.box = "bento/debian-11"

	config.vm.hostname = "dudle"
	ENV['LC_ALL']="en_US.UTF-8"

	config.vm.provision "shell", inline: <<-END
		apt-get install -y apache2
		apt-get install -y ruby ruby-gettext git
		apt-get install -y gettext potool make
		cd /vagrant/
		cat > /etc/apache2/sites-available/000-default.conf <<FILE
<VirtualHost *:80>
	ServerAdmin webmaster@localhost
	DocumentRoot /var/www/html/
	ErrorLog ${APACHE_LOG_DIR}/error.log
	CustomLog ${APACHE_LOG_DIR}/access.log combined
	SetEnv GIT_AUTHOR_NAME="http user"
	SetEnv GIT_AUTHOR_EMAIL=foo@example.org
	SetEnv GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
	SetEnv GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
	<Directory "/var/www/html/">
		AllowOverride All
	</Directory>
</VirtualHost>
FILE
		for i in * .htaccess; do
			sudo ln -s /vagrant/$i /var/www/html/
		done
		cd /var/www/html/
		make
		a2enmod auth_digest
		a2enmod rewrite
		systemctl restart apache2
		apt-get install -y ruby-dev libxml2-dev zlib1g-dev
		apt-get install -y gcc
		gem install ratom
	END
end
