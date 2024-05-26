BRANCH='REL1_41'

# Install Composer
wget -N -cO composer.phar https://getcomposer.org/composer-2.phar

# Install CheckUser
cd src/extensions
[ ! -d 'CheckUser' ] && git clone -b ${BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/CheckUser

# Install AntiSpoof
[ ! -d 'AntiSpoof' ] && git clone -b ${BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/AntiSpoof

# Install CentralAuth
[ ! -d 'CentralAuth' ] && git clone -b ${BRANCH} https://gerrit.wikimedia.org/r/mediawiki/extensions/CentralAuth

# Install CreateWiki
[ ! -d 'CreateWiki' ] && git clone https://github.com/miraheze/CreateWiki

# Install ManageWiki
[ ! -d 'ManageWiki' ] && git clone https://github.com/miraheze/ManageWiki