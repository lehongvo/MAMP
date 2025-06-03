#! /bin/sh
#
#  This GIT installer for macOS is part 
#  of the installation package Moodle4Mac
# 
#  20181112 - Ralf Krause
#

echo
echo "+--------------------------------------------+"
echo "| GIT updater for your local Moodle server"
echo "+--------------------------------------------+"
echo

cd /Applications/MAMP/htdocs

if ! test -e moodle36/.git ; then
    ## the first git update must get everything including .git
    git clone --depth 1 -b MOODLE_36_STABLE git://github.com/moodle/moodle.git moodle36-git
    if test -e moodle36-git ; then
        if test -e moodle36 ; then
            if test -e moodle36/config.php ; then
                cp moodle36/config.php moodle36-git/.
            fi
            DATE=`date +%Y%m%d-%H%M`
            mv moodle36 moodle36-$DATE
        fi
        mv moodle36-git moodle36
    fi
    ## the old folder can be deleted now
    ## if you want to do this please remove '##' from the following line
    ## rm -R moodle36-*
else
    ## the next git update only gets the new files
    cd moodle36
    git pull
    cd ..
fi
