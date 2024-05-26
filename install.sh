#!/bin/sh

/usr/local/bin/wait-for-it.sh mysql:3306 --timeout=60 --strict -- echo "MySQL is up"

SERVER_URL='https://test.example.com'

# MediaWiki Install
php maintenance/run install \
    --dbserver=mysql \
    --dbname=${MYSQL_DATABASE} \
    --installdbuser=${MYSQL_USER} \
    --installdbpass=${MYSQL_PASSWORD} \
    --dbuser=${MYSQL_USER} \
    --dbpass=${MYSQL_PASSWORD} \
    --server="${SERVER_URL}" \
    --scriptpath="" \
    --lang=en \
    --extensions=AbuseFilter,AntiSpoof,CheckUser,Echo,Interwiki,WikiEditor \
    --skins=Vector,MonoBook \
    --pass=Adminpassword "Wiki Name" "Admin"

echo '$wgShowExceptionDetails = true;' >> LocalSettings.php

echo "wfLoadExtension( 'CentralAuth' );" >> LocalSettings.php
echo '$wgCentralAuthDatabase = "centralauth";' >> LocalSettings.php
php maintenance/run.php sql --wikidb centralauth extensions/CentralAuth/schema/mysql/tables-generated.sql
php maintenance/run.php sql --wikidb centralauth extensions/AntiSpoof/sql/mysql/tables-generated.sql
php maintenance/run.php CentralAuth:migratePass0.php
php maintenance/run.php CentralAuth:migratePass1.php
echo '$wgCreateWikiDatabase = "wikidb";' >> LocalSettings.php
mkdir cw_cache
chmod 777 cw_cache
echo '$wgCreateWikiCacheDirectory = "cw_cache";' >> LocalSettings.php
php maintenance/run sql --wikidb wikidb extensions/CreateWiki/sql/cw_wikis.sql
php maintenance/run sql --wikidb wikidb extensions/CreateWiki/sql/cw_comments.sql
php maintenance/run sql --wikidb wikidb extensions/CreateWiki/sql/cw_requests.sql

echo Init_cw_wikis.sql
php maintenance/run sql --wikidb wikidb /var/www/mysql/init_cw_wikis.sql
echo "wfLoadExtension( 'CreateWiki' );" >> LocalSettings.php

sed -i '/# Enabled skins./i require_once "$IP/MirahezeFunctions.php";\n$wi = new MirahezeFunctions();' "LocalSettings.php"

TARGET_FILE="LocalSettings.php"

INSERT_FILE="wgConf.php"

TEMP_INSERT_FILE=$(mktemp)

sed '1d' "$INSERT_FILE" > "$TEMP_INSERT_FILE"

INSERT_TEXT="$(cat "$TEMP_INSERT_FILE")\nrequire_once \"\$IP/ManageWikiExtensions.php\";"


awk -v insert_text="$INSERT_TEXT" '
    { print }
    /\$wi = new MirahezeFunctions\(\);/ { print insert_text }
' "$TARGET_FILE" > "${TARGET_FILE}.tmp"

mv "${TARGET_FILE}.tmp" "$TARGET_FILE"

rm "$TEMP_INSERT_FILE"

sed -i '/^\$wgSitename/d' "$TARGET_FILE"
sed -i '/^\$wgLanguageCode/d' "$TARGET_FILE"
sed -i '/^\$wgLocaltimezone/d' "$TARGET_FILE"
sed -i '/^\$wgDBname/d' "$TARGET_FILE"
sed -i '/^\$wgMetaNamespace/d' "$TARGET_FILE"
sed -i '/^\$wgServer/d' "$TARGET_FILE"

rm -rf cw_cache/*

sed -i '/require_once "\$IP\/ManageWikiExtensions.php";/a $globals = MirahezeFunctions::getConfigGlobals();\n\n// phpcs:ignore MediaWiki.Usage.ForbiddenFunctions.extract\nextract($globals);' "$TARGET_FILE"

php maintenance/run update --wiki testwiki --quick

#sed -i '/# Further documentation/a var_dump("Hello");' LocalSettings.php

sed -i '/MirahezeFunctions.php/i $wgManageWiki = ["cdb" => false, "core" => true, "extensions" => true, "namespaces" => true, "permissions" => true, "settings" => true];' LocalSettings.php

php maintenance/run sql --wikidb wikidb --wiki testwiki extensions/ManageWiki/sql/mw_namespaces.sql
php maintenance/run sql --wikidb wikidb --wiki testwiki extensions/ManageWiki/sql/mw_permissions.sql
php maintenance/run sql --wikidb wikidb --wiki testwiki extensions/ManageWiki/sql/mw_settings.sql
php maintenance/run sql --wikidb wikidb --wiki testwiki extensions/ManageWiki/sql/defaults/mw_namespaces.sql
php maintenance/run sql --wikidb wikidb --wiki testwiki extensions/ManageWiki/sql/defaults/mw_permissions.sql

sed -i '/MirahezeFunctions\.php/i wfLoadExtension( "ManageWiki" );' LocalSettings.php
sed -i "/wfLoadExtension( 'CreateWiki' );/d" "$TARGET_FILE"
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "CreateWiki" );' LocalSettings.php

sed -i "/wfLoadExtension( 'AbuseFilter' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'AntiSpoof' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'CheckUser' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'Echo' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'Interwiki' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'WikiEditor' )/d" LocalSettings.php
sed -i "/wfLoadExtension( 'CentralAuth' )/d" LocalSettings.php
sed -i "/wfLoadSkin( 'Vector' )/d" LocalSettings.php
sed -i "/wfLoadSkin( 'MonoBook' )/d" LocalSettings.php

sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "AbuseFilter" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "AntiSpoof" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "CheckUser" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "Echo" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "Interwiki" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "WikiEditor" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadExtension( "CentralAuth" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadSkin( "Vector" );' LocalSettings.php
sed -i '/wfLoadExtension( "ManageWiki" );/i wfLoadSkin( "MonoBook" );' LocalSettings.php

php maintenance/run update --wiki testwiki --quick

sed -i "/extract($globals);/a $wi->loadExtensions();\nrequire_once __DIR__ . '/ManageWikiNamespaces.php';\nrequire_once __DIR__ . '/ManageWikiSettings.php';" LocalSettings.php

php maintenance/run createAndPromote --wiki testwiki Test2 Adminpassword --bureaucrat --sysop --interface-admin

php maintenance/run ManageWiki:populateNamespacesWithDefaults --wiki testwiki
php maintenance/run ManageWiki:populateGroupPermissionsWithDefaults --wiki testwiki
php maintenance/run ManageWiki:migrateSettingsAndExtensions --wiki testwiki

php maintenance/run update --wiki testwiki --quick

sed -i -e "$s|$|\n$wgGroupPermissions['bureaucrat']['createwiki'] = true;|g" LocalSettings.php

php-fpm
