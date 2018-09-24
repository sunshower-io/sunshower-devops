#!/bin/bash -eu

increment_version() {
   echo "$1" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'
}

current_version() {
    echo $(mvn -f $1 -q -N org.codehaus.mojo:exec-maven-plugin:1.3.1:exec \
            -Dexec.executable='echo' \
            -Dexec.args='${project.version}' | cut -f2 -d '-')
}
