# MeaPay Backend CICD

## TODO

- Finish Docker build step in application (Docker) pipeline (and adjust docs)
- Finish deploy step in application (Docker) pipeline
- Create release pipeline for applications

---
## Pipelines
[Trunk-based](https://trunkbaseddevelopment.com) version control management and branching model is used for backend repositories.  
[GitHub Actions](https://docs.github.com/en/actions) are used as tool for pipelines. Pipelines consist of steps. As syntax of those is simple and self-descriptive, please check each pipeline source code to see list of them.
### Repository configuration
There are multiple sensitive variables needed to be passed to pipeline. Those should be stored as encrypted [secrets](https://docs.github.com/en/actions/security-guides/encrypted-secrets) in repository. Here is the list:
- `AWS_CA_DOMAIN` - CodeArtifact [domain](https://docs.aws.amazon.com/codeartifact/latest/ug/domain-overview.html).
- `AWS_CA_OWNER_ID` - CoreArtifact domain owner ID.
- `AWS_ROLE_TO_ASSUME_DEV` - AWS DEV IAM role ARN.
- `AWS_ROLE_TO_ASSUME_TST` - AWS TEST IAM role ARN.
- `SLACK_BOT_TOKEN` - Slack bot token (see action [docs](https://github.com/slackapi/slack-github-action#setup-1)) for notifications (master pipeline only).  

To use pipeline in repository, appropriate configuration should be added to root folder under `.github/workflows/` as YAML file. 
In order to keep it easy to understand name configuration file the same as pipeline file here is named (for example `pr.yml` for PR pipeline).
Configuration for each pipeline type can be found below. Please notice comments there to fill repository specific parameters.

---
### Feature (PR) pipeline
#### Library (.jar)
Pipeline located [here](/.github/workflows/library/pr.yml). Configuration:
```
name: <repository name>-pr                                                # For example: meapay-backend-commons-pr

on:
  pull_request:

permissions:
      id-token: write
      contents: read
      checks: write
      issues: read
      pull-requests: write

jobs:
  pull-request:
    uses: meawallet/meapay-backend-cicd/.github/workflows./library/pr.yml@master
    with:
      build_command: clean build --console=plain                        # Gradle command to build project
      spotbugs_results_files: |
        */build/reports/spotbugs/*.xml
      utest_command: test --no-parallel --stacktrace --console=plain    # Gradle command to launch Unit tests
      itest_command: itest --no-parallel --stacktrace --console=plain   # Gradle command to launch Integration tests
      test_results_files: |
        */build/test-results/test/TEST-*.xml
        */build/test-results/itest/TEST-*.xml
    secrets:
      aws_ca_domain: ${{ secrets.AWS_CA_DOMAIN }}
      aws_ca_owner_id: ${{ secrets.AWS_CA_OWNER_ID }}
      aws_role_to_assume: ${{ secrets.AWS_ROLE_TO_ASSUME_DEV }}
```
#### Application (Docker)
Pipeline located [here](/.github/workflows/application/pr.yml). Configuration:
```
name: <repository name>-pr                                                # For example: meapay-service-geolocation-pr

on:
  pull_request:

permissions:
      id-token: write
      contents: read
      checks: write
      issues: read
      pull-requests: write

jobs:
  pull-request:
    uses: meawallet/meapay-backend-cicd/.github/workflows./application/pr.yml@master
    with:
      build_command: clean build --console=plain                        # Gradle command to build project
      spotbugs_results_files: |
        */build/reports/spotbugs/*.xml
      utest_command: test --no-parallel --stacktrace --console=plain    # Gradle command to launch Unit tests
      itest_command: itest --no-parallel --stacktrace --console=plain   # Gradle command to launch Integration tests
      test_results_files: |
        */build/test-results/test/TEST-*.xml
        */build/test-results/itest/TEST-*.xml
    secrets:
      aws_ca_domain: ${{ secrets.AWS_CA_DOMAIN }}
      aws_ca_owner_id: ${{ secrets.AWS_CA_OWNER_ID }}
      aws_role_to_assume: ${{ secrets.AWS_ROLE_TO_ASSUME_DEV }}
```

---
### Master pipeline
#### Library (.jar)
Pipeline located [here](/.github/workflows/library/master.yml). Configuration:
```
name: <repository name>-master                                            # For example: meapay-backend-commons-master

on:
  push:
    branches:
      - master

  workflow_dispatch:

permissions:
      id-token: write
      contents: write
      checks: write
      issues: read
      pull-requests: write
      packages: write

jobs:
  master:
    uses: meawallet/meapay-backend-cicd/.github/workflows./library/master.yml@master
    with:
      build_command: clean build --console=plain                        # Gradle command to build project
      artifacts_publish_command: publish --stacktrace --console=plain   # Gradle command to publish .jar artifacts
      slack_channel_id: be_dev_softpos                                  # Slack channel ID, channel name, or user ID to notify about failure.
    secrets:
      aws_ca_domain: ${{ secrets.AWS_CA_DOMAIN }}
      aws_ca_owner_id: ${{ secrets.AWS_CA_OWNER_ID }}
      aws_role_to_assume: ${{ secrets.AWS_ROLE_TO_ASSUME_TST }}
      slack_bot_token: ${{ secrets.SLACK_BOT_TOKEN }}
```
#### Application (Docker)
Pipeline located [here](/.github/workflows/application/pr.yml). Configuration:
```
name: <repository name>-master                                            # For example: meapay-service-geolocation-master

on:
  push:
    branches:
      - master

  workflow_dispatch:

permissions:
      id-token: write
      contents: write
      checks: write
      issues: read
      pull-requests: write
      packages: write

jobs:
  master:
    uses: meawallet/meapay-backend-cicd/.github/workflows./library/master.yml@master
    with:
      build_command: clean build --console=plain                        # Gradle command to build project
      docker_build_command: build                                       # Command to build Docker image
      docker_ecr_repository: ecr-repo                                   # ECR repository where Docker image should be pushed
      artifacts_publish_command: publish --stacktrace --console=plain   # Gradle command to publish .jar artifacts
      slack_channel_id: be_dev_softpos                                  # Slack channel ID, channel name, or user ID to notify about failure.
    secrets:
      aws_ca_domain: ${{ secrets.AWS_CA_DOMAIN }}
      aws_ca_owner_id: ${{ secrets.AWS_CA_OWNER_ID }}
      aws_role_to_assume: ${{ secrets.AWS_ROLE_TO_ASSUME_TST }}
      slack_bot_token: ${{ secrets.SLACK_BOT_TOKEN }}
```

---
### Release pipeline
TBD

