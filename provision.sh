#!/usr/bin/env bash
#

# Locales
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LC_ALL=en_US.UTF-8

# Essentials
sudo apt-get install autoconf binutils-doc bison build-essential flex -y
sudo apt-get install git -y
sudo apt-get install python-software-properties -y

# Postgres
sudo add-apt-repository ppa:cartodb/postgresql-9.5 && sudo apt-get update
sudo apt-get install libpq5 libpq-dev postgresql-client-9.5 postgresql-client-common -y
sudo apt-get install postgresql-9.5 postgresql-contrib-9.5 postgresql-server-dev-9.5 postgresql-plpython-9.5 -y

sudo rm /etc/postgresql/9.5/main/pg_hba.conf
sudo su -c 'echo "local all postgres trust" >> /etc/postgresql/9.5/main/pg_hba.conf'
sudo su -c 'echo "local all all trust" >> /etc/postgresql/9.5/main/pg_hba.conf'
sudo su -c 'echo "host all all 127.0.0.1/32 trust" >> /etc/postgresql/9.5/main/pg_hba.conf'

sudo service postgresql restart

sudo createuser publicuser --no-createrole --no-createdb --no-superuser -U postgres
sudo createuser tileuser --no-createrole --no-createdb --no-superuser -U postgres

cd /opt/cartodb-postgresql
git fetch --tags

# Checkout latest tag
git checkout $(git describe --tags `git rev-list --tags --max-count=1`)
sudo make all install

# Gis
sudo add-apt-repository ppa:cartodb/gis && sudo apt-get update
sudo apt-get install proj proj-bin proj-data libproj-dev -y
sudo apt-get install libjson0 libjson0-dev python-simplejson -y
sudo apt-get install libgeos-c1v5 libgeos-dev -y
sudo apt-get install gdal-bin libgdal1-dev libgdal-dev -y
sudo apt-get install ogr2ogr2-static-bin -y

# PostGis
sudo apt-get install libxml2-dev -y
sudo apt-get install liblwgeom-2.2.2 postgis postgresql-9.5-postgis-2.2 postgresql-9.5-postgis-scripts -y
sudo createdb -T template0 -O postgres -U postgres -E UTF8 template_postgis
sudo createlang plpgsql -U postgres -d template_postgis
psql -U postgres template_postgis -c 'CREATE EXTENSION postgis;CREATE EXTENSION postgis_topology;'
sudo ldconfig
sudo PGUSER=postgres make installcheck
sudo service postgresql restart

# Redis
sudo add-apt-repository ppa:cartodb/redis && sudo apt-get update
sudo apt-get install redis-server -y

# NodeJS
cd /home/vagrant
wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh | bash
echo "source /home/vagrant/.nvm/nvm.sh" >> /home/vagrant/.profile
source /home/vagrant/.profile

nvm install 0.10.44
nvm alias default 0.10.44
npm install npm@2.14.16 -g

# SQL Api
cd /opt/cartodb-sql-api
git checkout master
cp config/environments/development.js.example config/environments/development.js

# Maps API
cd /opt/windshaft-cartodb
git checkout master
sudo apt-get install libpango1.0-dev -y

source /home/vagrant/.profile

npm install
cp config/environments/development.js.example config/environments/development.js

# Ruby
sudo apt-get install libreadline6-dev openssl libssl-dev zlib1g-dev -y

sudo -u vagrant git clone git://github.com/sstephenson/rbenv.git /home/vagrant/.rbenv
sudo -u vagrant echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> /home/vagrant/.profile
sudo -u vagrant echo 'eval "$(rbenv init -)"' >> /home/vagrant/.profile
sudo -u vagrant git clone git://github.com/sstephenson/ruby-build.git /home/vagrant/.rbenv/plugins/ruby-build

sudo -u vagrant -i rbenv install 2.2.3
sudo -u vagrant -i rbenv global 2.2.3
sudo -u vagrant -i ruby -v
sudo -u vagrant -i gem install bundler --no-ri --no-rdoc
sudo -u vagrant -i gem install compass --no-ri --no-rdoc
sudo -u vagrant -i rbenv rehash

# Editor
cd /opt/cartodb

sudo wget  -O /tmp/get-pip.py https://bootstrap.pypa.io/get-pip.py
sudo -H python /tmp/get-pip.py
sudo apt-get install python-all-dev -y
sudo apt-get install imagemagick unp zip -y

source /home/vagrant/.profile

RAILS_ENV=development bundle install
npm install -g grunt-cli
npm install

export CPLUS_INCLUDE_PATH=/usr/include/gdal
export C_INCLUDE_PATH=/usr/include/gdal
export PATH=$PATH:/usr/include/gdal

sudo -H pip install --no-use-wheel -r python_requirements.txt

export PATH=$PATH:$PWD/node_modules/grunt-cli/bin

bundle install
bundle exec grunt --environment development

cp config/app_config.yml.sample config/app_config.yml
cp config/database.yml.sample config/database.yml

RAILS_ENV=development bundle exec rake db:create:all
RAILS_ENV=development bundle exec rake db:migrate
RAILS_ENV=development bundle exec rake cartodb:db:create_publicuser
RAILS_ENV=development bundle exec rake cartodb:db:setup_user SUBDOMAIN="development" PASSWORD="cartodb" EMAIL="cartodb@example.com"

redis-server &