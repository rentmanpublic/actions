## v1

Initial release

## v2

- Fixed a bug in redeploy_services.sh where the service name could be undefined

## v3

- Fixed a bug in redeploy_services.sh where the service name could be undefined

## v4

- BREAKING: config.json format changed, we now expect an array of service names if no service tag is provided. 
This was needed for the db-backup-server because that is deployed as 2 different services using the same code.