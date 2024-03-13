#!/bin/sh
##########################################################################################################
# Description: Sometimes if you have a blog or something which doesn't require dynamic interaction from a user
# it might be preferable to generate as static copy of your site and host it in (for example) an S3 bucket
# and have the content served statically to your readers. This has some advantages for some website profiles:
# Its more secure, its cheaper, its faster, and its more resilient (properly set up there should be about zero
# chance of server errors and misconfigurations). What I am doing here is providing a way to generate a static site
# copy to a (for example) S3 bucket based on the dyanmic site you are running and updating. If youa are a blogger,
# therefore, in full flight this system would work by you hosting a private (no public access at all) dynamic site
# that only you (or your team of bloggers) can access and update your blog posts on and to. At a given periodicity
# (perhaps as often as every hour) your private dynamic site can use "GENERATE_STATIC" to generate a static copy
# of your website and uploading it to your, for example, S3 bucket with any changes that have been made to your blogs
# since you last generate a static copy. Using this has the advantages I have outlined. I have used this in a rudimentary
# way I would be interested to see if you can get it to work fully if that is your usecase
# Date: 16/11/2016
# Author: Peter Winter
###########################################################################################################
# License Agreement:
# This file is part of The Agile Deployment Toolkit.
# The Agile Deployment Toolkit is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
# The Agile Deployment Toolkit is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# You should have received a copy of the GNU General Public License
# along with The Agile Deployment Toolkit.  If not, see <http://www.gnu.org/licenses/>.
#######################################################################################################
#######################################################################################################
#set -x

periodicity="${1}"
buildidentifier="${2}"

trap cleanup 0 1 2 3 6 9 14 15

cleanup()
{
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "backuplock.${periodicity}.file"
    exit
}

#In the case where there are multiple webservers running, we don't want backups to spawn concurrently,
#so put in a random delay before the backup begins. This will make sure that it is unlikely two or more
#backup processes will run concurrently.

/bin/sleep "`/usr/bin/shuf -i1-300 -n1`"

if ( [ "`${HOME}/providerscripts/datastore/configwrapper/CheckConfigDatastore.sh "staticlock.file"`" = "0" ] )
then
    /usr/bin/touch ${HOME}/runtime/staticlock.file
    ${HOME}/providerscripts/datastore/configwrapper/PutToConfigDatastore.sh ${HOME}/runtime/staticlock.file 
    ${HOME}/providerscripts/datastore/GenerateStaticSite.sh
    /bin/sleep 800
    ${HOME}/providerscripts/datastore/configwrapper/DeleteFromConfigDatastore.sh "staticlock.file"
else
    /bin/echo "script already running"
fi
