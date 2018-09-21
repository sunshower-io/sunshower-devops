#!/bin/bash -eu

VERSION=""

BUILD_NUMBER=0
CURRENT_VERSION=1.0.0

IS_RELEASE="true"
NEXT_VERSION=""

increment_version() {
   echo "$1" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'
}

parse_version() {

    IFS='/'; 
    local components=();
    read -ra components <<< "$1"
    unset IFS;
    
    
    if [ ${#components[@]} -eq 1 ]; then
        if [ ${components[0]} == "master" ]; then
            VERSION="$CURRENT_VERSION-${BUILD_NUMBER}.Final";
        else     
            local cversion=$(echo ${components[0]} | sed s/x/${BUILD_NUMBER}/g)
            NEXT_VERSION=$cversion;
            VERSION="${cversion}.Final";
        fi
    fi
    
    if [ ${#components[@]} -eq 2 ]; then
        if [ ${components[1]} == "master" ]; then
            local cversion=$(echo ${components[0]} | sed s/x/${BUILD_NUMBER}/g)
            NEXT_VERSION=$cversion;
            VERSION="${cversion}.Final"
        else 
            IS_RELEASE="false"
            VERSION="${components[0]}-${components[1]}-SNAPSHOT"
        fi
    fi
    echo "$VERSION";
}




#parse_version $1
#
#if [ ${IS_RELEASE} == "true" ]; then
#    mvn clean install -f bom
#else 
#fi
#
#
#echo ${VERSION}
