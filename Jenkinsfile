pipeline {
    agent any

    stages {
        stage('Build Info') {
            steps {
                echo "Build Number: ${env.BUILD_NUMBER}"
                echo "Job Name: ${env.JOB_NAME}"
                echo "Workspace: ${env.WORKSPACE}"
            }
        }

        stage('List Files') {
            steps {
                sh 'ls -l'
            }
        }

        stage('Simple Script') {
            steps {
                sh '''
                echo "Running a simple script..."
                date
                whoami
                '''
            }
        }

        stage('Success Message') {
            steps {
                echo "Pipeline executed successfully 🚀"
            }
        }
    }
}
