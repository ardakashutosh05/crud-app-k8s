pipeline {
    agent any


    environment {
        SCANNER_HOME = tool 'sonar-scanner'
        SONAR_TOKEN = credentials('sonar-token')
        SONAR_ORGANIZATION = 'jenkins234'
        SONAR_PROJECT_KEY = 'jenkins234'
    }

    stages {

        stage('Code-Analysis') {
            steps {
                withSonarQubeEnv('SonarCloud') {
                     sh '''$SCANNER_HOME/bin/sonar-scanner -X \
     -Dsonar.organization=jenkins234 \
     -Dsonar.projectKey=jenkins234 \
     -Dsonar.sources=. \
     -Dsonar.host.url=https://sonarcloud.io \
     -Dsonar.login=$SONAR_TOKEN'''
          }
       }
   }

/*
       stage('Docker Build And Push') {
            steps {
                script {
                    docker.withRegistry('', 'docker-cred') {
                        def buildNumber = env.BUILD_NUMBER ?: '1'
                        def image = docker.build("ardakashutosh05/crud-123:latest")
                        image.push()
                    }
                }
            }
        }
*/

      stage('Docker Build And Push') {
    	    steps {
                script {
            	    docker.withRegistry('', 'docker-cred') {
                	def version = "v${env.BUILD_NUMBER ?: '1'}"
                	def image = docker.build("ardakashutosh05/crud-123:${version}")
                	image.push()
                	image.push("latest")  // optional: push 'latest' tag as well
        	    }
      	 	 }
 	   }
	}



/*
       stage('Deploy To EC2') {
            steps {
                script {
                        sh 'docker rm -f $(docker ps -q) || true'
                        sh 'docker run -d -p 3000:3000 ardakashutosh05/crud-123:latest'


                }
            }
        }
*/
}
}
