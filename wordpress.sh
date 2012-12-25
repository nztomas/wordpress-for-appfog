#/bin/bash

# This scripts fetches the current version of wordpress from the official
# SVN repository and amends its files to be easily deployed onto
# Appfog.com

SCRIPT=`readlink -f $0`
SCRIPTDIR=`dirname $SCRIPT`
BASEDIR=`pwd`
WORDPRESS_PLUGINS_DIR="./wp-content/plugins"
SVN_EXTERNALS="$WORDPRESS_PLUGINS_DIR/svn.externals"
HTACCESS=".htaccess"
DOMAIN=$1
DOMAIN_ESCAPED=`echo $DOMAIN | sed 's/\./\\\\./g'`

EXPECTED_ARGS=1
E_BADARGS=65

if [ $# -ne $EXPECTED_ARGS ]
then
  printf "\nUsage: `basename $0` {your-domain.com}\n\n"
  exit $E_BADARGS
fi

printf "Fetching the latest wordpress from SVN...\n\n"
svn co http://core.svn.wordpress.org/tags/3.5 . --ignore-externals
printf "Done!\n\n"

printf "Creating wp-config.php...\n"
`cp $SCRIPTDIR/wp-config.php.template wp-config.php`
printf "Done!\n\n"

printf "Generating Salts & Keys...\n"
KEYS=`curl https://api.wordpress.org/secret-key/1.1/salt/ -ss`
`head -n 17 $SCRIPTDIR/wp-config.php.template > wp-config.php`
`echo "$KEYS" >> wp-config.php`
`tail -n 12 $SCRIPTDIR/wp-config.php.template >> wp-config.php`
printf "Done!\n\n"

printf "Generating .htaccess\n"
`head -n 10 $SCRIPTDIR/$HTACCESS.template > $HTACCESS`
echo "RewriteCond %{HTTP_HOST} ^www\.$DOMAIN_ESCAPED$ [NC]" >> $HTACCESS
echo "RewriteRule ^(.+)$ http://$DOMAIN/\$1 [R=301,QSA,L]" >> $HTACCESS
`tail -n 7 $SCRIPTDIR/$HTACCESS.template >> $HTACCESS`
printf "Done!\n\n"

printf "Adding wordpress plugins...\n\n"

touch $SVN_EXTERNALS

for i in $(cat $SCRIPTDIR/plugins.default)
do
  echo " - $i"
  echo "$i http://svn.wp-plugins.org/$i/trunk" >> $SVN_EXTERNALS
done
printf "\n"

svn propset -q svn:externals -F "$SVN_EXTERNALS" "$WORDPRESS_PLUGINS_DIR/"
svn up "$WORDPRESS_PLUGINS_DIR/"
printf "Done!\n\n"

printf "All set up, continue with 'af push' to get your wordpress deployed to appfog!\n\n"
