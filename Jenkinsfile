pipeline {
    agent any
 
     environment {
        REGION = 'us-east-1'
        STACK  = 'todo-list-aws'
        BUCKET = 'aws-sam-cli-managed-default-samclisourcebucket-tpehk8wctign'
        PREFIX = 'staging'
        STAGE  = 'staging'
    }

 
    stages {
        stage('Get Code') {
            steps {
                echo 'Inicio de la clonación del código fuente!!!'
                    //git branch: 'develop', url: 'https://github.com/Integra24/todo-list-aws.git' 
                    git branch: 'develop', url: 'https://my_token_git@github.com/Integra24/todo-list-aws.git' 
            }
        }
        stage('Static Test') {
            steps {
                echo 'Inicio de Static Test!'
                 catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                     sh "pwd"
                     sh "whoami"
                     sh "python -m flake8 --exit-zero --format=pylint --max-line-length=100 src >flake8.out"
                
                    recordIssues tools: [flake8(name: 'Flake8', pattern: 'flake8.out')], qualityGates: [[threshold: 90, type: 'TOTAL', unstable: true], [threshold: 100, type: 'TOTAL', unstable: false]]
                 }
            }
        }    
            
        stage('Security code'){
           steps{
               catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                  sh "pwd"
                  sh "whoami"
                  sh "bandit --exit-zero -r src -f custom -o bandit.out --severity-level medium --msg-template '{abspath}:{line}: {severity}: {test_id}: {msg}'"
                  
                  sh "export PATH=$PATH:/usr/bin/"
                    recordIssues( tools: [pyLint(name: 'Bandit', pattern: 'bandit.out')], qualityGates: [[threshold: 90, type: 'TOTAL', unstable: true], [threshold: 100, type: 'TOTAL', unstable: false]])

               }
            }
        }
        
        stage('Build Deploy'){
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
        stage('Integration tests') {
            steps {
                sh "hostname"
                sh "whoami"
	            sh "pwd"

                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    sh """
                        export BASE_URL=${env.FIND_BASE_URL_API}
                        pytest --junitxml=result-rest.xml test/integration/todoApiTest.py -m "not lee"
                    """
                    //pytest --junitxml=result-rest.xml test/integration/todoApiTest.py -m "not lee"
                    //pytest --junitxml=result-rest.xml test/integration/todoApiTest.py -m lee
                    junit 'result*.xml'
                }
            }
        }


        stage('Promote') {

            steps {
                sh "hostname"
                sh "whoami"
	            sh "pwd"
 
                catchError(buildResult: 'UNSTABLE', stageResult: 'FAILURE') {
                    withCredentials([string(credentialsId: 'my_token_git', variable: 'GIT_RUTA')]) {
                
                        script {
                            sh "git config --global user.email 'monicadevops4@gmail.com'"
                            sh "git config --global user.name 'Integra24'"
                            
			                // Limpiando directorio de trabajo	
                            sh "git checkout -- ."
			                // obtiene master	
                            sh "git checkout master"
                            sh "git pull https://${GIT_RUTA}@github.com/Integra24/todo-list-aws.git master"
			                // obtiene develop	"
                            sh "git checkout develop "
                            sh "git pull https://${GIT_RUTA}@github.com/Integra24/todo-list-aws.git develop "
                            // merge
			                sh "git checkout master "
            			    def mergeStatus = sh(script: "git merge develop", returnStatus: true)
            			     
            			    if (mergeStatus != 0) {
            			        
                				sh "echo 'presenta conflicto' " 
                				sh "git merge --abort "
                				sh "git merge develop -X ours --no-commit "
                				sh "git checkout --ours Jenkinsfile "
                				sh "git add Jenkinsfile "
                				sh "git commit -m 'Merge develop con master  excluye Jenkinsfile' "
            				}
                            else {
            	                sh "echo ' merge Ok' "
            	            }
                            sh "git push https://${GIT_RUTA}@github.com/Integra24/todo-list-aws.git master "
                        }    
                        
                    }
                }
            }
        }

    }
}
