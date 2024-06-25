pipeline {
    agent any
 
     environment {
        REGION = 'us-east-1'
        STACK  = 'todo-list-aws-production'
        BUCKET = 'aws-sam-cli-managed-default-samclisourcebucket-tpehk8wctign'
        PREFIX = 'todo-list-aws'
        STAGE  = 'production'
    }

 
    stages {
        stage('Get Code') {
            steps {
                echo 'Inicio de la clonación del código fuente!!!'
                    git branch: 'master', url: 'https://github.com/Integra24/todo-list-aws.git' 
                    
            }
        }


        stage('Deploy'){
            steps{
                //sam build command
                sh "sam build"

                sleep(time: 1, unit: 'SECONDS')

                //sam deploy command
                sh "sam deploy --template-file template.yaml \
                        --stack-name ${env.STACK} --region ${env.REGION} \
                        --capabilities CAPABILITY_IAM \
                        --parameter-overrides Stage=${env.STAGE} \
                        --no-fail-on-empty-changeset \
                        --s3-bucket ${env.BUCKET} --s3-prefix ${env.PREFIX} \
                        --no-confirm-changeset"
            }
        }
        
        
        
        
        
        stage('Base Salida') {
            // variable de salida
            environment {
                FIND_BASE_URL_API = 'init'
            }
            steps {
                
                echo "Value for --> STAGE: ${env.STAGE}"
                echo "Value for --> REGION: ${env.REGION}"

                script {
                    //permiso para ejecutar
                    sh "chmod +x getting_base_url_api.sh"

                    //obtiene base_url
                    sh "./getting_base_url_api.sh ${env.STAGE} ${env.REGION}"

                    //lista archivos
                    sh "ls -l *.tmp"

                    // lee temporal
                    def BASE_URL = readFile('my_base_url_api.tmp').trim()
                    echo "Lee base_url: ${BASE_URL}"
                    
                    env.FIND_BASE_URL_API = "${BASE_URL}"
                    
                    //clean temporal files
                    sh "pwd"
                    sh "whoami"                    
                    sh "rm *.tmp"
                }
            }
        }
        stage('Rest tests') {
            steps {
                sh "hostname"
                sh "whoami"
	            sh "pwd"

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        export BASE_URL=${env.FIND_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py -m lee
                    """

                    junit 'result*.xml'
                }
            }
        }
    }
}
