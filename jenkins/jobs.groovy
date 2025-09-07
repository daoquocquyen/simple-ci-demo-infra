multibranchPipelineJob('simple-ci-demo-pipeline') {
  branchSources {
    branchSource {
      source {
        github {
          // A unique ID for this source (any stable string)
          id('gh-simple-ci-demo-mbp')

          credentialsId('github-creds')  // PAT or GitHub App credentials
          repoOwner('daoquocquyen')
          repository('simple-ci-demo')
          repositoryUrl('https://github.com/daoquocquyen/simple-ci-demo.git')
          configuredByUrl(true)

          traits {
            // NOTE: Shallow clone to speed up checkout
            cloneOption {
              extension {
                shallow(true)
                depth(5)
                noTags(true)
                reference('')
                timeout(10)
              }
            }
            // Discover all branches
            gitHubBranchDiscovery { strategyId(1) }
            // Discover PRs from the same repo
            gitHubPullRequestDiscovery { strategyId(2) }
          }
        }
      }
    }
  }

  // Jenkinsfile location
  factory {
    workflowBranchProjectFactory {
      scriptPath('Jenkinsfile')
    }
  }

  // Keep folder tidy
  orphanedItemStrategy {
    discardOldItems {
      numToKeep(20)
    }
  }

  // Fallback periodic re-scan (webhooks do the real-time work)
  triggers {
    periodicFolderTrigger {
      interval('1d')
    }
  }

  // --- IMPORTANT: register the GitHub webhook for THIS item ---
  // Some Job DSL/trait methods aren’t surfaced directly, so we add it via `configure`.
  configure { node ->
    def traits = node / sources / data / 'jenkins.branch.BranchSource' / source / traits
    traits << 'org.jenkinsci.plugins.github__branch__source.WebhookRegistrationTrait' {
      // Use 'ITEM' so Jenkins manages a per-repo webhook automatically
      mode('ITEM')
    }
  }
}
