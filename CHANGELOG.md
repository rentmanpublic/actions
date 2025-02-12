## v1

Initial release

## v2

- Fixed a bug in redeploy_services.sh where the service name could be undefined

## v3

- Fixed a bug in redeploy_services.sh where the service name could be undefined

## v4

- config.json format changed, we now allow `ecsImageName` to be either a string or an array of strings.
This was needed for the db-backup-server because that is deployed as 2 different services using the same code.

## v5

- Releasing nodejs based services now works
