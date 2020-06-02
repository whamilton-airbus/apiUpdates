# Misc 

## checkapi.sh 
List the filename, name, kind, and apiVersion of the deployments found 
recursively from the current directory.

Will check multiple documents in files.

Also checks for cases in which the yaml writes another one, but 
is not a separate document. These will ERROR because they need 
to be handled manually for now.
 
#### dependecies
yq: https://mikefarah.gitbook.io/yq/

#### instructions
1. download, put somewhere useful
2. run `checkapi.sh` from the top level directory of the files
to be checked

## apiupdate.sh 
Update the deprecated versions of the deployments, found recursively 
from the current directory. Currently handles the following updates:  

* Deployment versions extensions/v1beta1, apps/v1beta1, and apps/v1beta2 are deprecated
  * use apps/v1, available since Kubernetes 1.9
* StatefulSet versions apps/v1beta1 and apps/v1beta2 are deprecated
  * use apps/v1, available since Kubernetes 1.9
  
Those are all I've found so far that are part of the deprecated list.
`checkapi.sh` can be used to check. 

   Here is the full list: 

   * DaemonSet versions extensions/v1beta and apps/v1beta2 are deprecated
      * use apps/v1, available since Kubernetes 1.9
   * Deployment versions extensions/v1beta1, apps/v1beta1, and apps/v1beta2 are deprecated
      * use apps/v1, available since Kubernetes 1.9
   * ReplicaSet versions extensions/v1beta1, apps/v1beta1, and apps/v1beta2 are deprecated
      * use apps/v1, available since Kubernetes 1.9
   * StatefulSet versions apps/v1beta1 and apps/v1beta2 are deprecated
      * use apps/v1, available since Kubernetes 1.9
   * NetworkPolicy version extensions/v1beta1 is deprecated
      * use networking.k8s.io/v1, available since Kubernetes 1.8
   * PodSecurityPolicy version extensions/v1beta1 is deprecated
      * use policy/v1beta1, available since Kubernetes 1.10

Works on multiple documents (deployments) within a single yaml

Ignores cases in which the yaml file writes another one... yq can't handle 
them. They need to be handled manually. `checkapi.sh` will report them as ERROR 
 
#### dependecies
yq: https://mikefarah.gitbook.io/yq/

#### instructions
1. download, put somewhere useful
2. run `apiupdate.sh` from the top level directory of the set of deployment 
files to be updated
