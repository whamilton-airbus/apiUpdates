#!/bin/bash
# make sure you have yq installed!

# set -x

# find the yaml files under this directory, then print out the
# name, kind, and apiVersion of the documents found in them

# will check multiple documents in files, and also check for cases
# in which the yaml writes another one, but is not a separate
# document. These will ERROR because they need to be handled
# manually for now.

for f in $(find . | grep "\.yaml$") ; do

	# this will reflect the number of documents in the file
	apis=$(yq read -d'*' $f 'kind' | wc -l)

	# sometimes a document will write another document, and then it
	# won't automate. these files probably need to be handled manually
	chk=$(grep kind $f | wc -l)
	if [ $apis -ne $chk ] ; then
		echo "ERROR something odd with " $f
	fi

  	d=0;
  	while [ $d -lt $apis ] ; do
  		kind=$(yq read -d"$d" $f 'kind')
		echo -e $f \
		'\t' $(yq read -d"$d" $f 'metadata.name') \
		'\t' $kind  \
		'\t' $(yq read -d"$d" $f 'apiVersion')

		# check for other things that will change
		case $kind in
			"DaemonSet")
				if [ $(yq read -d"$d" $f 'spec.templateGeneration') ] ; then
					echo "    found spec.templateGeneration"
				fi
				if [ -z "$(yq read -d"$d" $f 'spec.selector')" ] ; then
					echo "    NOT found spec.selector"
					echo "    spec.template.metadata.labels: " $(yq read -d"$d" $f 'spec.template.metadata.labels')
				fi
			;;
			"Deployment")
				if [ $(yq read -d"$d" $f 'spec.rollbackTo') ] ; then
					echo "    found spec.rollbackTo"
				fi
				if [ -z "$(yq read -d"$d" $f 'spec.selector')" ] ; then
					echo "    NOT found spec.selector"
					echo "    spec.template.metadata.labels: " $(yq read -d"$d" $f 'spec.template.metadata.labels')
				fi
			;;
			"StatefulSet" | "ReplicaSet")
				if [ -z "$(yq read -d"$d" $f 'spec.selector')" ] ; then
					echo "    NOT found spec.selector"
					echo "    spec.template.metadata.labels: " $(yq read -d"$d" $f 'spec.template.metadata.labels')
				fi
		esac
		((d++))
	done
done
