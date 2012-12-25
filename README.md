wordpress-for-appfog
====================

This is a setup script for [Wordpress](http://www.wordpress.org) and [Appfog](http://www.appfog.com).

1. create a new directory: `mkdir wordpress; cd wordpress`
2. run this script: `./path/to/this/git/folder/wordpress.sh mydomainname.com`
3. upload to appfog: `af update yourappname`

The script does the following:

1. fetches latest wordpress files from SVN repo
2. generates wp-config.php appfog mysql db
3. generates wordpress salts & keys and puts them into wp-config.php
4. generates .htaccess for your the domain name you used as a script input parameter
5. generates a list of svn externals for plugins specified in plugins.template file (feel free to amend to suit your needs) and runs svn update for them
