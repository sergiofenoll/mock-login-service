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
    def scmVars = checkout scm
    def git_branch = scmVars.GIT_BRANCH

    if (git_branch == 'origin/development'){
      branch = 'development'
    }
  }

  try {

    stage("Image Prune"){
      imagePrune(branch)
    }

    stage('Image Build'){
      imageBuild(branch)
    }

    stage('Run App'){
      runApp(branch)
    }

  } catch (err) {
    currentBuild.result = 'FAILED'
    throw err
  }

}

def imagePrune(branch){
    try {
        sh "docker-compose -f docker-compose.${branch}.yml down -v"
        sh "docker-compose -f docker-compose.${branch}.yml rm -f --remove-orphans"
    } catch(error){}
}

def imageBuild(branch){
    sh "docker-compose -f docker-compose.${branch}.yml build"
    echo "Image build complete"
}

def runApp(branch){
    sh "docker-compose -f docker-compose.${branch}.yml up -d --force-recreate"
    echo "Application started"
}
