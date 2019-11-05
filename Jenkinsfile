/*
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at http://mozilla.org/MPL/2.0/.
 */

/*
 * Copyright 2019 Joyent, Inc.
 */

@Library('jenkins-joylib@v1.0.2') _

pipeline {

    agent {
        label joyCommonLabels(image_ver: '18.4.0')
    }

    options {
        buildDiscarder(logRotator(numToKeepStr: '30'))
        timestamps()
    }

    parameters {
        string(
            name: 'BUILDNAME',
            defaultValue: '${BRANCH_NAME} master',
            description:
                'The hierarchy of agent branch names to include in the shar ' +
                'archive. By default, we use the branch of ' +
                'sdc-agents-installer itself, and fallback to "master" ' +
                'unless this is a "release-*" branch, when we do not fallback.')
    }

    stages {
        stage('check') {
            steps{
                sh('make check')
            }
        }
        // avoid bundling devDependencies
        stage('re-clean') {
            steps {
                sh('git clean -fdx')
            }
        }
        stage('build image and upload') {
            steps {
                sh('''
set -o errexit
set -o pipefail
# If this is a release build, clobber the user-supplied parameter.
# See MANTA-4675.
JENKINS_RELEASE_BUILD=$(echo $BRANCH_NAME | sed -e 's/^release-[0-9]*//g')
if [[ -z "$JENKINS_RELEASE_BUILD" ]]; then
    echo "Overriding BUILDNAME parameter for $BRANCH_NAME"
    export BUILDNAME=$BRANCH_NAME
fi
export ENGBLD_BITS_UPLOAD_IMGAPI=true
make print-BRANCH print-STAMP all release publish bits-upload''')
            }
        }
    }

    post {
        always {
            joyMattermostNotification(channel: 'jenkins')
        }
    }

}
