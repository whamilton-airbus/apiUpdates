#!/bin/bash
# make sure you have yq installed!

# set -x

# update the apiVersion of the yaml deployments (for Deployments
# with deprecated version !apps/v1

# works on multiple documents (deployments) within a single yaml
# doesn't work on cases in which the yaml file writes another one
# ... it just doesn't look like another document. Those need to be
# handled manually.
# checkapi.sh will find those

for f in $(find . | grep "\.yaml") ; do
	# this will reflect the number of documents in the file
	apis=$(yq read -d'*' $f kind | wc -l)

  	d=0;
  	while [ $d -lt $apis ] ; do

  		if [ $(yq read -d"$d" $f 'kind') = "Deployment" ] ; then
  			oldv=$(yq read -d"$d" $f 'apiVersion')
  			echo "Found" $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $oldv
    		if [ $oldv = "extensions/v1beta1" ] || [ $oldv  = "apps/v1beta1" ]  || [ $oldv  = "apps/v1beta2" ] ; then
   				yq write -i -d"$d" $f 'apiVersion' apps/v1
  				newv=$(yq read -d"$d" $f 'apiVersion')
  				if [ $oldv = $newv ] ; then
	   				echo "FAILED $f " $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $(yq read -d"$d" $f 'apiVersion')
	   			else
   					echo "Updated $f " $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $(yq read -d"$d" $f 'apiVersion')
				fi
    		fi

		elif [ $(yq read -d"$d" $f 'kind') = "StatefulSet" ] ; then
  			oldv=$(yq read -d"$d" $f 'apiVersion')
  			echo "Found" $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $oldv
    		if [ $oldv  = "apps/v1beta1" ]  || [ $oldv  = "apps/v1beta2" ] ; then
   				yq write -i -d"$d" $f 'apiVersion' apps/v1
  				newv=$(yq read -d"$d" $f 'apiVersion')
  				if [ $oldv = $newv ] ; then
	   				echo "FAILED $f " $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $(yq read -d"$d" $f 'apiVersion')
	   			else
   					echo "Updated $f " $(yq read -d"$d" $f 'metadata.name') $(yq read -d"$d" $f 'kind') $(yq read -d"$d" $f 'apiVersion')
   				fi
   			fi
		fi
		((d++)) #while
	done #while
done #for
