#!/bin/bash -eu

increment_version() {
   echo "$1" | awk -F. -v OFS=. 'NF==1{print ++$NF}; NF>1{if(length($NF+1)>length($NF))$(NF-1)++; $NF=sprintf("%0*d", length($NF), ($NF+1)%(10^length($NF))); print}'
}

current_version() {
    echo $(mvn -f $1 -q -N org.codehaus.mojo:exec-maven-plugin:1.3.1:exec \
            -Dexec.executable='echo' \
            -Dexec.args='${project.version}' | cut -f2 -d '-')
}
release_env() {

    local repo=$1;
    local org=$2;

    if [ "$BRANCH_NAME" = "release" ]; then
        mvn versions:set -f sunshower-env/pom.xml -DnewVersion=$VERSION;
        mvn versions:set -f sunshower-env/parent/pom.xml -DnewVersion=$VERSION;
        mvn clean install deploy -f sunshower-env/pom.xml -P ${MAVEN_PROFILE};
        mvn clean install deploy -f sunshower-env/parent/pom.xml -P ${MAVEN_PROFILE};
        mvn versions:set -f sunshower-env/pom.xml -DnewVersion=$NEXT_VERSION -P ${MAVEN_PROFILE};
        mvn versions:set -f sunshower-env/parent/pom.xml -DnewVersion="${NEXT_VERSION}-SNAPSHOT" -P ${MAVEN_PROFILE};
        git remote set-url origin https://${GITHUB_USERNAME}:${GITHUB_PASSWORD}@github.com/$1/$2
        git config user.email "${GITHUB_USERNAME}@sunshower.io"
        git config user.name "${GITHUB_USERNAME}"
        git config user.password "${GITHUB_PASSWORD}"
        git checkout -b release
        git commit -am "Releasing new version ${VERSION}"
        git tag -a v$VERSION -m "Released version ${VERSION}"
        git push origin release --tags
    fi;
}

