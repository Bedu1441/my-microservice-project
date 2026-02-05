pipeline {
  agent {
    kubernetes {
      defaultContainer 'git'
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

    - name: aws
      image: amazon/aws-cli:2.15.30
      command: ["sh", "-c", "cat"]
      tty: true
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
        - name: docker-config
          mountPath: /kaniko/.docker

    - name: kaniko
      image: gcr.io/kaniko-project/executor:v1.23.2-debug
      command: ["/busybox/cat"]
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

    ECR_REPO_NAME     = "django-app"
    ECR_REGISTRY      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    ECR_REPO_URI      = "${ECR_REGISTRY}/${ECR_REPO_NAME}"

    HELM_REPO_URL     = "github.com/Bedu1441/my-microservice-helm.git"
    HELM_REPO_BRANCH  = "main"
    HELM_VALUES_PATH  = "charts/django-app/values.yaml"

    GIT_USER_NAME     = "jenkins-ci"
    GIT_USER_EMAIL    = "jenkins-ci@local"
  }

  options {
    disableConcurrentBuilds()
    skipDefaultCheckout(true)   // ✅ прибираємо автоматичний checkout (щоб не було 2 рази)
  }

  stages {

    stage("Checkout app repo") {
      steps {
        container('git') {
          checkout scm
          sh """
            set -e
            git config --global --add safe.directory "${WORKSPACE}"
          """
        }
      }
    }

    stage("Build & Push to ECR (Kaniko)") {
      steps {
        script {
          // ✅ shortSha рахуємо в git-контейнері (там є git + safe.directory)
          def shortSha = ""
          container('git') {
            shortSha = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
          }

          def tag = "${shortSha}-${env.BUILD_NUMBER}"
          writeFile file: "image_tag.env", text: "IMAGE_TAG=${tag}\n"
          echo "Image tag: ${tag}"

          // 1) ECR login → пишемо docker config для Kaniko
          container('aws') {
            withCredentials([usernamePassword(credentialsId: 'aws-ecr', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
              sh """
                set -e
                mkdir -p /kaniko/.docker

                PASS=\$(aws ecr get-login-password --region ${AWS_REGION})
                AUTH=\$(printf "AWS:%s" "\$PASS" | base64 | tr -d '\\n')

                cat > /kaniko/.docker/config.json <<EOF
{"auths":{"${ECR_REGISTRY}":{"auth":"\$AUTH"}}}
EOF
              """
            }
          }

          // 2) Kaniko build+push
          container('kaniko') {
            sh """
              set -e
              /kaniko/executor \
                --context \$(pwd) \
                --dockerfile Dockerfile \
                --destination ${ECR_REPO_URI}:${tag} \
                --destination ${ECR_REPO_URI}:latest
            """
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

                sed -i "s/^  tag:.*/  tag: \\"${tag}\\"/" ${HELM_VALUES_PATH}

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
