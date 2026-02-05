pipeline {
  agent {
    kubernetes {
      defaultContainer 'jnlp'
      yaml """
apiVersion: v1
kind: Pod
metadata:
  labels:
    app: jenkins-kaniko
spec:
  serviceAccountName: jenkins
  restartPolicy: Never
  volumes:
    - name: workspace-volume
      emptyDir: {}
    - name: docker-config
      emptyDir: {}
  containers:
    - name: git
      image: alpine/git:2.45.2
      command: ["sh", "-c", "cat"]
      tty: true
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2
      command: ["sh", "-c", "cat"]
      tty: true
      env:
        - name: DOCKER_CONFIG
          value: /kaniko/.docker
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
        - name: docker-config
          mountPath: /kaniko/.docker
"""
    }
  }

  environment {
    AWS_REGION        = "us-east-1"
    AWS_ACCOUNT_ID    = "428941813622"

    // ECR repo (має існувати)
    ECR_REPO_NAME     = "django-app"
    ECR_REPO_URI      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com/${ECR_REPO_NAME}"

    // Helm repo (GitOps)
    HELM_REPO_URL     = "github.com/Bedu1441/my-microservice-helm.git"
    HELM_REPO_BRANCH  = "main"
    HELM_VALUES_PATH  = "charts/django-app/values.yaml"

    // Git author for commits
    GIT_USER_NAME     = "jenkins-ci"
    GIT_USER_EMAIL    = "jenkins-ci@local"
  }

  options {
    disableConcurrentBuilds()
  }

  stages {

    stage("Checkout app repo") {
      steps {
        checkout scm
      }
    }

    stage("Build & Push to ECR (Kaniko)") {
      steps {
        container('kaniko') {
          script {
            def shortSha = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
            def tag = "${shortSha}-${env.BUILD_NUMBER}"
            writeFile file: "image_tag.env", text: "IMAGE_TAG=${tag}\n"
            echo "Image tag: ${tag}"

            withCredentials([usernamePassword(credentialsId: 'aws-ecr', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
              sh """
                set -e
                /kaniko/executor \
                  --context \$(pwd) \
                  --dockerfile Dockerfile \
                  --destination ${ECR_REPO_URI}:${tag} \
                  --destination ${ECR_REPO_URI}:latest \
                  --cache=true \
                  --cache-repo ${ECR_REPO_URI}-cache
              """
            }
          }
        }
      }
    }

    stage("Update Helm repo & push to main") {
      steps {
        container('git') {
          script {
            def tag = sh(script: "cat image_tag.env | cut -d= -f2", returnStdout: true).trim()
            echo "Updating Helm values with tag: ${tag}"

            withCredentials([string(credentialsId: 'github-pat', variable: 'GITHUB_PAT')]) {
              sh """
                set -e
                rm -rf helmrepo
                git clone -b ${HELM_REPO_BRANCH} https://${GITHUB_PAT}@${HELM_REPO_URL} helmrepo

                cd helmrepo
                git config user.name "${GIT_USER_NAME}"
                git config user.email "${GIT_USER_EMAIL}"

                # update ONLY tag in values.yaml: expects 'image:' then 'tag:' with 2 spaces indent
                if grep -q "^  tag:" ${HELM_VALUES_PATH}; then
                  sed -i "s/^  tag:.*/  tag: \\"${tag}\\"/" ${HELM_VALUES_PATH}
                elif grep -q "^imageTag:" ${HELM_VALUES_PATH}; then
                  sed -i "s/^imageTag:.*/imageTag: \\"${tag}\\"/" ${HELM_VALUES_PATH}
                else
                  echo "ERROR: Could not find image tag field in ${HELM_VALUES_PATH}"
                  exit 1
                fi

                git add ${HELM_VALUES_PATH}
                git commit -m "ci: update django image tag to ${tag}" || echo "No changes to commit"
                git push origin ${HELM_REPO_BRANCH}
              """
            }
          }
        }
      }
    }
  }

  post {
    always {
      echo "Done. ArgoCD should auto-sync from Helm repo."
    }
  }
}
