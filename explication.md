# docker compose : 
    - montage: "/var/run/docker.sock:/var/run/docker.sock"
        give localstack access to intern docker, when using services like lambda, localstack need to run another container.
        give the socket docker 
    - port : 4566 (unique entrypoint for localstack ) 