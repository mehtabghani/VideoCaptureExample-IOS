pipeline {
    agent any

    stages {
        stage('Install Gems') {
            steps {
                dir ('code') { 
                    sh 'bundle install'
                }
            }
        }
        stage('Generate Build') {
            steps {
                dir ('code') { 
                    script {
                        if (env.BRANCH_NAME == "master") {                                          
                            sh 'bundle exec fastlane prod'
                        } else if (env.BRANCH_NAME == "qa") {                                   
                            sh 'bundle exec fastlane qa'
                        } else {
                            sh 'bundle exec fastlane develop'
                       }
                    }
                }
            }
        }
        stage('Archive Build') {
            steps {
                dir ('code') { 
                    archiveArtifacts artifacts: 'output/**', fingerprint: true
                }
            }
        }
    }
}