CREATE DATABASE IF NOT EXISTS `centralauth`;
GRANT ALL ON centralauth.* TO 'user'@'%';
CREATE DATABASE IF NOT EXISTS `wikidb`;
GRANT ALL ON wikidb.* TO 'user'@'%';
