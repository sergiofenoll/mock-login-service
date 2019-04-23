def CONTAINER_NAME=""
def CONTAINER_TAG="latest"
def HTTP_PORT="8081"


node {

  env.NODEJS_HOME = "${tool 'node'}"
  env.PATH="${env.NODEJS_HOME}/bin:${env.PATH}"
  currentBuild.result = 'SUCCESS'
  boolean skipBuild = false

  stage('Initialize'){
    def dockerHome = tool 'myDocker'
  }

  def branch = 'master'

  stage('Checkout') {
    checkout scm
  }

  try {

    stage('Image Build'){
      imageBuild(CONTAINER_NAME, CONTAINER_TAG, DRC_PATH, branch)
    }

  } catch (err) {
    currentBuild.result = 'FAILED'
    throw err
  }

}

def imageBuild(containerName, tag, DRC_PATH, branch){
    sh "docker build ."
    echo "Image 'mock-login-service' build"
}

