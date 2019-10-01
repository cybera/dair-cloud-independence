pipeline {
	agent any
	stages {
		stage('Build') {
			steps {
				sh 'ls -la'
				sh 'cd apps/docker_files && bash -c "/usr/local/bin/docker-compose up >> ~/log 2>&1" &'
			}
		}
                stage('Wait') {
                        steps { 
                                sh './apps/docker_files/test.sh'
                        }
                }
                stage('Test') {
			steps {
                                sh 'curl http://172.17.0.1/polls/'
                        }
                }
                stage('Cleanup') {
                        steps { 
                                sh 'cd apps/docker_files && /usr/local/bin/docker-compose down'
                        }
                }
	}
}
