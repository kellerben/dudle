# Authors
 * Benjamin Kellermann <Benjamin dot Kellermann at gmx in Germany>
 * a lot of contributers of small code pieces

# License
GNU AGPL v3 or higher (see file License)

# Requirements
 * ruby >=1.9
 * git >=1.6.5 (preferred and default setting) or bzr
 * ruby-gettext (for localization)
 * gettext, potool, make (optional, if you want to generate localization files)

# Installation
1.  Place this application into a directory where cgi-scripts are evaluated.
2.  If you want to change some configuration, state it in the file `config.rb`
    (see `config_sample.rb` for help)
    to start with a default configuration.
3.  The webserver needs the permission to write into the directory
4.  You need `.mo` files in order to use localisation.
    You have 2 possibilities:
    1. Run this small script to fetch the files from the main server:

       ```sh
       cd $DUDLE_INSTALLATION_PATH
       for i in locale/??; do
       	wget -O $i/dudle.mo https://dudle.inf.tu-dresden.de/locale/`basename $i`/dudle.mo
       done
       ```
    2. Build them on your own. This requires gettext,
       ruby-gettext, potool, and make to be installed.

       ```sh
       sudo aptitude install gettext potool make
       make
       ```
5.  In order to let access control work correctly, the webserver needs
    auth_digest support. It therefore may help to type:

    ```sh
    sudo a2enmod auth_digest
    ```
6.  In order to get atom-feed support you need ruby-ratom to be
    installed. E.g.:

    ```sh
    sudo aptitude install ruby-dev libxml2-dev zlib1g-dev
    sudo gem install ratom
    ```
7.  To make titles with umlauts working you need to check the encoding in
    .htaccess, e.g.

    ```sh
    SetEnv LC_ALL "en_US.UTF-8"
    ```
8.  It might be the case, that you have to set some additional Variables
    in your .htaccess:

   	```sh
    SetEnv GIT_AUTHOR_NAME="http user"
    SetEnv GIT_AUTHOR_EMAIL=foo@example.org
    SetEnv GIT_COMMITTER_NAME="$GIT_AUTHOR_NAME"
    SetEnv GIT_COMMITTER_EMAIL="$GIT_AUTHOR_EMAIL"
    ```
9.  If you installed dudle to a subdirectory (i.e. http://$YOUR_SERVER/$SOMEDIR/...),
    than you want to adopt the ErrorDocument directives in your .htaccess.
    (You need an absolute path here!)
10. Try to open http://$YOUR_SERVER/check.cgi to check if your config
    seems to work.
11. You may want to install a cronjob to cleanup dudle polls.
    See dudle_cleanup.sh for an example.
12. You can enable a maintenance mode if you need to change something
    with your installation. Using this mode, all users will see a static
    message and are not able to change anything. In order to enable this
    mode, create a file named `/maintenance.html` which may include a
    custom message. E.g.:

    ```sh
    echo "<div>We are updating the servers and expect to be online on 0 am, January 1st, 1970 (UTC).</div>" > $DUDLE_INSTALLATION_PATH/maintenance.html
    ```

# Docker image
There are two docker image available
 *  https://hub.docker.com/r/fonk/dudle/ with the code from here https://github.com/fonk/docker-dudle
 *  https://github.com/jpkorva/dudle-docker

# Pimp your Installation
 * If you want to create your own Stylesheet, you just have to put it in
   the folder `$DUDLE_HOME_FOLDER/css/`. Afterwards you may config this
   one to be the default Stylesheet. Examples can be found here:
    - https://dudle.inf.tu-dresden.de/css/
   You can fetch the whole repo from https://github.com/kellerben/dudle-css
 * If you want to extend the functionality you might want to place a file
   `main.rb` in `$DUDLE_HOME_FOLDER/extension/$YOUR_EXTENSION/main.rb`
   Examples can be found here: https://dudle.inf.tu-dresden.de/extensions/
   You can clone the whole sourcecode here:
    - https://github.com/kellerben/dudle-extensions-participate
    - https://github.com/kellerben/dudle-extensions-symcrypt
    - https://github.com/kellerben/dudle-extensions-asymcrypt
    - https://github.com/kellerben/dudle-extensions-gpgauth
    - https://github.com/kellerben/dudle-extensions-anonymous

# Translators
If you set `$DUDLE_POEDIT_AUTO` to your lang, poedit will launch
automatically when building the application. E.g.:

```sh
export DUDLE_POEDIT_AUTO=fr
git pull
make # will launch poedit if new french strings are to be translated
```

* To add a new translation
 - first add a new folder for your language under $DUDLE_HOME_FOLDER/locale, 
 - copy the dudle.pot file into your folder and name it dudle.po
 - translate sentences and phrases in your dudle.po file
 - add an entry for your language in dudle/dudle.rb at line 245
