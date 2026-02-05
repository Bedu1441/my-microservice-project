pipeline {
  agent {
    kubernetes {
      // важливо: shell/checkout/git-команди мають йти в контейнер з git + sh
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

    # контейнер з AWS CLI — щоб зробити ECR login і записати Docker config для Kaniko
    - name: aws
      image: amazon/aws-cli:2.15.30
      command: ["sh", "-c", "cat"]
      tty: true
      volumeMounts:
        - name: workspace-volume
          mountPath: /home/jenkins/agent
        - name: docker-config
          mountPath: /kaniko/.docker

    # ✅ Kaniko debug: є busybox; команда /busybox/cat щоб контейнер жив
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

    // ECR repo (має існувати)
    ECR_REPO_NAME     = "django-app"
    ECR_REGISTRY      = "${AWS_ACCOUNT_ID}.dkr.ecr.${AWS_REGION}.amazonaws.com"
    ECR_REPO_URI      = "${ECR_REGISTRY}/${ECR_REPO_NAME}"

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
        // checkout робиться в defaultContainer 'git'
        checkout scm
      }
    }

    stage("Build & Push to ECR (Kaniko)") {
      steps {
        script {
          // git є в контейнері git (default)
          def shortSha = sh(script: "git rev-parse --short=8 HEAD", returnStdout: true).trim()
          def tag = "${shortSha}-${env.BUILD_NUMBER}"
          writeFile file: "image_tag.env", text: "IMAGE_TAG=${tag}\n"
          echo "Image tag: ${tag}"

          // 1) Робимо ECR login і пишемо /kaniko/.docker/config.json у спільний volume
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

                echo "Wrote Docker config for ${ECR_REGISTRY}"
              """
            }
          }

          // 2) Kaniko build+push (без shell вимог, бо /kaniko/executor напряму)
          container('kaniko') {
            withCredentials([usernamePassword(credentialsId: 'aws-ecr', usernameVariable: 'AWS_ACCESS_KEY_ID', passwordVariable: 'AWS_SECRET_ACCESS_KEY')]) {
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
