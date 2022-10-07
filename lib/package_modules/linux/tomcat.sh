#!/bin/bash
ENVIRONMENT_ROOT_DIR=$(echo "${BASH_SOURCE[0]}" | sed -e 's|\(.*\)/|\1___|' | awk -F "___" '{NF--; print}')
cd "$ENVIRONMENT_ROOT_DIR" || exit
cd ..
cd ..
cd ..
ENVIRONMENT_ROOT_DIR=$(pwd)
source "$ENVIRONMENT_ROOT_DIR"/lib/functions/linux/environment_functions.sh
environmentVariableSetup=$1

GREEN="\e[32m"
RED="\e[31m"
BLUE="\e[34m"
ENDCOLOR="\e[0m"
SUCCESS="[${GREEN}*${ENDCOLOR}]"
FAIL="[${RED}*${ENDCOLOR}]"

makePackageFolderStructure () {

    if [ ! -d "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat" ]
    then
        mkdir "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat"
    fi

}

getPackageVersionFromWeb () {

    # first argument passed to function
    formatType=$1

    # if argument '-reset' is passed, delete env_custom file
    latestVersionPackageName="apache-tomcat-9.0.65.tar.gz"

    case $formatType in

        "-downloadUrl")
            # example return: "https://nodejs.org/dist/latest/node-v*.*.*-linux-x64.tar.gz"
            latestVersionUrl="https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.65/bin/$latestVersionPackageName"
            echo "$latestVersionUrl"
        ;;
        "-packageFileName")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            echo "$latestVersionPackageName"
        ;;
        "-cachePackageFileNameLocallyAndReturn")
            # example return: "node-v*.*.*-linux-x64.tar.gz"
            makePackageFolderStructure
            echo "$latestVersionPackageName" > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/.downloaded_version_number
            echo "$latestVersionPackageName"
        ;;
        *)
            # example return: "node-v*.*.*-linux-x64"
            latestVersionFolderName=${latestVersionPackageName//.tar.gz/}
            echo "$latestVersionFolderName"
        ;;

    esac

}

getCachedVersion () {

    if [ ! -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/.downloaded_version_number ]
    then
        echo ""
    else
        thisVersion=$(cat "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/.downloaded_version_number)
        echo "$thisVersion"
    fi

}

isPackageAlreadyDeployed () {

    makePackageFolderStructure
    cachedVersionName=$(getCachedVersion | sed -e 's/.tar.gz//g')

    if [ "$cachedVersionName" == "" ]
    then
        echo "no"
        return
    fi

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$cachedVersionName"/bin/startup.sh ]
    then
        echo "yes"
    else
        echo "no"
    fi

}

isPackageAtLatestVersion () {

    makePackageFolderStructure
    cachedVersionName=$(getCachedVersion)
    latestVersionNameFromWeb=$(getPackageVersionFromWeb -packageFileName)

    if [ "$cachedVersionName" == "$latestVersionNameFromWeb" ]
    then
        deployedAlready=$(isPackageAlreadyDeployed)

        if [ "$deployedAlready" == "yes" ]
        then
            echo "yes"
        else
            echo "no"
        fi
    else
        echo "no"
    fi

}

buildStopTomcat () {

    # $1 = LatestTomcatVersion

    if [ -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/stop_tomcat.sh" ]
    then
        rm -rf "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/stop_tomcat.sh"
    fi

    {

        echo "#!/bin/bash"
        echo " "
        echo "ENVIRONMENT_ROOT_DIR=\"$2\""
        echo "cd \"\$ENVIRONMENT_ROOT_DIR\" || exit"

        echo " "

        echo "ENVIRONMENT_ROOT_DIR=\$(pwd)"
        echo "source \"\$ENVIRONMENT_ROOT_DIR\"/lib/functions/linux/environment_functions.sh"

        echo " "

        echo "consoleLog 'Stopping Tomcat' 'SUCCESS' 0"

        echo " "

        echo "latestName=\"$1\""
        echo "pidCheck=\`ps ax | grep java | grep tomcat | awk '{print \$1}'\`"

        echo " "

        echo "if [ \"\$pidCheck\" == \"\" ]"
        echo "then"
        echo "    consoleLog 'Tomcat not running' 'SUCCESS' 1"
        echo "else"
        echo "    kill \$pidCheck"
        echo "    sleep 2"
        echo "    kill \$pidCheck 2> /dev/null"
        echo "    consoleLog 'Tomcat stopped' 'SUCCESS' 1"
        echo "fi"

    } >> "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/stop_tomcat.sh"

    chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/stop_tomcat.sh"

}

buildStartTomcat () {

    # $1 = LatestTomcatVersion

    if [ -f "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/start_tomcat.sh" ]
    then
        rm -rf "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/start_tomcat.sh"
    fi

    {

        echo "#!/bin/bash"
        echo " "
        echo "ENVIRONMENT_ROOT_DIR=\"$2\""
        echo "cd \"\$ENVIRONMENT_ROOT_DIR\" || exit"

        echo " "

        echo "ENVIRONMENT_ROOT_DIR=\$(pwd)"
        echo "source \"\$ENVIRONMENT_ROOT_DIR\"/lib/functions/linux/environment_functions.sh"

        echo " "

        echo "consoleLog 'Starting Tomcat' 'SUCCESS' 0"

        echo " "

        echo "latestName=\"$1\""
        echo "\$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/stop_tomcat.sh"

        echo " "

        echo "if [ -f \$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/\$latestName/bin/catalina.sh ]"
        echo "then"
        echo "    \$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/\$latestName/bin/catalina.sh start"
        echo "fi"


    } >> "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/start_tomcat.sh"

    chmod 755 "$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/start_tomcat.sh"

}

ensureSymLinksExist () {

    versionName=$(getCachedVersion | sed -e 's/.tar.gz//g')

    buildStopTomcat $versionName "$ENVIRONMENT_ROOT_DIR"
    buildStartTomcat $versionName "$ENVIRONMENT_ROOT_DIR"

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_start ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_start
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/start_tomcat.sh "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_start
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/start_tomcat.sh "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_start
    fi

    if [ -L "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_stop ]
    then
        unlink "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_stop
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/stop_tomcat.sh "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_stop
    else
        ln -s "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/stop_tomcat.sh "$ENVIRONMENT_ROOT_DIR"/bin/tomcat_stop
    fi

}

installPackage () {
    consoleLog "tomcat needs installing" "SUCCESS" 0

    latestVersionUrlFromWeb=$(getPackageVersionFromWeb -cachePackageFileNameLocallyAndReturn)
    latestDownloadUrlFromWeb=$(getPackageVersionFromWeb -downloadUrl)
    "$ENVIRONMENT_ROOT_DIR"/bin/curl "$latestDownloadUrlFromWeb" -L > "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestVersionUrlFromWeb"

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestVersionUrlFromWeb" ]
    then
        tar x -C "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestVersionUrlFromWeb"
    else
        consoleLog "tomcat tarball not downloaded" "FAIL" 0
    fi
}

buildTomcatUsersXml () {

    latestName=$(getPackageVersionFromWeb)

    if [ -f /tmp/tomcat-users.xml ]
    then
        rm -rf /tmp/tomcat-users.xml
    fi

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"                                       >> /tmp/tomcat-users.xml
    echo "<tomcat-users xmlns=\"http://tomcat.apache.org/xml\""                             >> /tmp/tomcat-users.xml
    echo "          xmlns:xsi=\"http://www.w3.org/2001/XMLSchema-instance\""                >> /tmp/tomcat-users.xml
    echo "          xsi:schemaLocation=\"http://tomcat.apache.org/xml tomcat-users.xsd\""   >> /tmp/tomcat-users.xml
    echo "          version=\"1.0\">"                                                       >> /tmp/tomcat-users.xml
    echo ""                                                                                 >> /tmp/tomcat-users.xml
    echo "<role rolename=\"manager-gui\" />"                                                >> /tmp/tomcat-users.xml
    echo "<user username=\"admin\""                                                         >> /tmp/tomcat-users.xml
    echo "    password=\"admin\""                                                           >> /tmp/tomcat-users.xml
    echo "    roles=\"admin-gui,manager-gui,manager-script,manager-jmx,manager-status\"/>"  >> /tmp/tomcat-users.xml
    echo ""                                                                                 >> /tmp/tomcat-users.xml
    echo "</tomcat-users>"                                                                  >> /tmp/tomcat-users.xml

    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/conf/tomcat-users.xml ]
    then 
        rm -rf "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/conf/tomcat-users.xml
        consoleLog "updating tomcat-users.xml" "SUCCESS" 0
    fi

    mv /tmp/tomcat-users.xml "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/conf/tomcat-users.xml

}


buildDefaultContextXmls () {

    latestName=$(getPackageVersionFromWeb)

    if [ -f /tmp/manager-context.xml ]
    then
        rm -rf /tmp/manager-context.xml
    fi

    echo "<?xml version=\"1.0\" encoding=\"UTF-8\"?>"                                               >> /tmp/manager-context.xml
    echo "<Context antiResourceLocking=\"false\" privileged=\"true\" >"                             >> /tmp/manager-context.xml
    echo "<CookieProcessor className=\"org.apache.tomcat.util.http.Rfc6265CookieProcessor\""        >> /tmp/manager-context.xml
    echo "          sameSiteCookies=\"strict\" />"                                                  >> /tmp/manager-context.xml
    echo "<Manager sessionAttributeValueClassNameFilter=\"java\\.lang\\.(?:Boolean|Integer|Long|Number|String)|org\\.apache\\.catalina\\.filters\\.CsrfPreventionFilter\\\$LruCache(?:\\\$1)?|java\\.util\\.(?:Linked)?HashMap\"/>" >> /tmp/manager-context.xml
    echo ""                                                                                         >> /tmp/manager-context.xml
    echo "</Context>"                                                                               >> /tmp/manager-context.xml


    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/manager/META-INF/context.xml ]
    then 
        rm -rf "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/manager/META-INF/context.xml
        consoleLog "updating manager context.xml" "SUCCESS" 0
    fi

    cp /tmp/manager-context.xml "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/manager/META-INF/context.xml


    if [ -f "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/host-manager/META-INF/context.xml ]
    then 
        rm -rf "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/host-manager/META-INF/context.xml
        consoleLog "updating host-manager context.xml" "SUCCESS" 0
    fi

    mv /tmp/manager-context.xml "$ENVIRONMENT_ROOT_DIR"/bin/.linux/.tomcat/"$latestName"/webapps/host-manager/META-INF/context.xml

}




deployPackage=$(shouldBeDeployed tomcat)

if [ "$deployPackage" == "yes" ]
then

    case $environmentVariableSetup in

        "-environmentSetup")
            latestVersionNameFromWeb=$(getPackageVersionFromWeb)
            echo "export CATALINA_HOME=$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/$latestVersionNameFromWeb :: export CATALINA_BASE=$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/$latestVersionNameFromWeb :: export CATALINA_TMPDIR=$ENVIRONMENT_ROOT_DIR/bin/.linux/.tomcat/$latestVersionNameFromWeb/temp"
        ;;
        *)

            makePackageFolderStructure
            isPackageDeployed=$(isPackageAlreadyDeployed)
            isPackageLatestVersionInstalled=$(isPackageAtLatestVersion)

            if [ "$isPackageDeployed" == "no" ]
            then
                installPackage
            fi

            if [ "$isPackageDeployed" == "yes" ] && [ "$isPackageLatestVersionInstalled" == "no" ]
            then

                read -r -t 5 -p 'tomcat has a new version. Upgrade? (timeout to no in 5 seconds) [y/n]: ' installDirective

                case $installDirective in

                    "y"|"Y")
                        installPackage
                    ;;
                    "n"|"N")
                        consoleLog "skipping tomcat upgrade" "SUCCESS" 0
                    ;;
                    *)
                        consoleLog "skipping tomcat upgrade" "SUCCESS" 0
                    ;;

                esac

            fi

            ensureSymLinksExist
            buildTomcatUsersXml
            buildDefaultContextXmls
        ;;
    esac
    
fi

