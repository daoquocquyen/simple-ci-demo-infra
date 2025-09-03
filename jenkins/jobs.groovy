pipelineJob('simple-ci-demo-pipeline') {
    definition {
        cpsScm {
            scm {
                git {
                    remote {
                        url('https://github.com/daoquocquyen/simple-ci-demo.git')
                    }
                    branches('**')
                }
            }
            scriptPath('Jenkinsfile')
        }
    }
}