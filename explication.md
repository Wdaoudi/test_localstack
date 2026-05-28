# docker compose : 
    - montage: "/var/run/docker.sock:/var/run/docker.sock"
        give localstack access to intern docker, when using services like lambda, localstack need to run another container.
        give the socket docker 
    - port : 4566
        unique entrypoint for localstack. AWS has an URL distinct by service (s3.amazonaws.com, dynamodb.eu-west-3.amazonaws.com) localstack expose all services across port 4566

# localstack.env:
    - fake credentials that give access to aws cli, which doesn t send request to Amazon services but instead to localhost:4566
    - command : 'source localstack.env' need to be used to charge credential to running terminal

# commande : aws s3 mb s3://risk-poc-bucket
    - mb = "make bucket"
    - aws [options] help = show all command that exists