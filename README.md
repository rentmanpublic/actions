## Github Actions

This repository contains re-usable workflows which can be run from our repositories.

To implement these workflows in your repository, you need to create a `.github/workflows` folder in the root of your repository and call the corresponding workflow in there.

Next to that you need a config.json file in the deployments/workflows folder of the repository you wish to deploy
You can find an example of that below.

### Workflows

The following workflows are available in this repository:

#### Deploy master

This workflow builds, and deploys the master branch and tags it in git (this is used for a production release)
After that the image is build and pushed to ECR (tagged as latest and with the new git tag as a version)
And the ecs instance is redeployed to all specified regions and clusters in the config.json file in the repository deployments/workflows folder

#### Deploy branch

This workflow builds and deploys a specific branch, whichout tagging it in git (can be used for testing on staging)
After that the image is build and pushed to ECR (tagged as latest, without a version)
And the ecs instance is redeployed to all specified regions and clusters in the config.json file in the repository deployments/workflows folder

#### Deploy version

This workflow builds a specific version which is passed as an input, the version is checked agains a git tag 
On the repository this action is used in, after that the image is build and pushed to ECR (tagged as latest and the version)
And the ecs instance is redeployed to all specified regions and clusters in the config.json file in the repository deployments/workflows folder

#### Redeploy latest image

This workflow redloys the ecr image tagged as 'latest' to all specified regions and clusters in the config.json file in the repository deployments/workflows folder

#### Other workflows

There are other workflow files in the folder which are used for internal processes by the workflows mentioned above

### Prerequisites

There are a couple of things needed to implement a workflow in your repository

#### config.json

This json file contains the names of regions and cluster that the service needs to de deployed to, and either the tag or name of the ecr image you wish to push to aws

This file _needs_ to be in deployment/workflows/config.json

For example:

```
{
    "ecsServiceTag": "Tag of ecs service, if existent, but preferred", #optional
    "environments": {
        "production": {
          "ecsCluster": "Name of cluster in aws", #required
          "ecsRegions": [ 
            "name of aws region" Can be multiple #required
          ],
          "ecrImageName": "Name of the ecr image" #required
          "ecsServiceName": "Optional name of the service in ecs if service has no tag" #optional
        },
       "staging": {
          "ecsCluster": "Name of cluster in aws", #required
          "ecsRegions": [ 
            "name of aws region" Can be multiple #required
          ],
          "ecrImageName": "Name of the ecr image" #required
          "ecsServiceName": "Optional name of the service in ecs if service has no tag" #optional
        }
    }
}
```

#### Dockerfile location

The dockerfile of the service should be located in deployments/dockerfiles/code/Dockerfile

### Working example

You can find a straightforward working example of the workflows in the translations repository