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
  		echo "Checking " $f

  		name=$(yq read -d"$d" $f 'metadata.name')
  		kind=$(yq read -d"$d" $f 'kind')

  		if [ $kind = "Deployment" ] ; then
  			oldv=$(yq read -d"$d" $f 'apiVersion')
  			echo "    Found" $f $name $kind $oldv

    		if [ $oldv = "extensions/v1beta1" ] || [ $oldv  = "apps/v1beta1" ]  || [ $oldv  = "apps/v1beta2" ] ; then

    			# update the apiVersion
   				yq write -i -d"$d" $f 'apiVersion' apps/v1

    			# add required spec.selector (to match spec.template.metadata.labels)
    			type=$(yq read -d"$d" $f 'spec.template.metadata.labels' | awk -F: '{ print $1 }')
    			name=$(yq read -d"$d" $f 'spec.template.metadata.labels' | awk '{ print $2 }')
    			yq write -i -d"$d" $f spec.selector.matchLabels.$type $name

    			# check for rollbackTo (to be removed) - none found so far

   				echo "    Updated $f " $name $kind $(yq read -d"$d" $f 'apiVersion')
    		fi

		elif [ $kind = "StatefulSet" ] ; then
  			oldv=$(yq read -d"$d" $f 'apiVersion')
  			echo "    Found" $name $kind $oldv
    		if [ $oldv  = "apps/v1beta1" ]  || [ $oldv  = "apps/v1beta2" ] ; then

    			# update the apiVersion
   				yq write -i -d"$d" $f 'apiVersion' apps/v1

    			# add required spec.selector (to match spec.template.metadata.labels)
    			type=$(yq read -d"$d" $f 'spec.template.metadata.labels' | awk -F: '{ print $1 }')
    			name=$(yq read -d"$d" $f 'spec.template.metadata.labels' | awk '{ print $2 }')
    			yq write -i -d"$d" $f spec.selector.matchLabels.$type $name

   				echo "    Updated $f " $name $kind $(yq read -d"$d" $f 'apiVersion')
   			fi
		fi
		((d++)) #while
	done #while
done #for

