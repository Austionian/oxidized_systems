# List available commands
default:
    just -l

dev:
    #!/bin/bash
    minify() {
        just build-tailwind
    }

    # Add a trap to run the minify function before exiting
    trap "minify; kill 0" SIGINT

    open 'http://127.0.0.1:1111'

    zola serve & just run-tailwind
    TAILWIND_PID=$!

    wait $TAILWIND_PID

# Script to run the Tailwind binary in watch mode
run-tailwind:
    #!/bin/bash
    echo "Starting the Tailwind binary."
    ./tailwindcss -i ./styles/styles.css -o ./static/styles/styles.css --watch

# Script to build and minify the Tailwind binary
build-tailwind:
    #!/bin/bash
    echo -e "\nMinifying css"
    sh -c './tailwindcss -i ./styles/styles.css -o ./static/styles/styles.css --minify'

build-zola:
    #!/bin/bash
    zola build

build:
    #!/bin/bash
    just build-tailwind && just build-zola

# Builds the docker image
docker-build:
    docker build --tag oxidized .

docker-deploy:
    DOCKER_HOST="ssh://austin@raspberrypi.local" docker compose up -d

# Builds the new images, saves it to the pi, remotely starts it up with docker compose
deploy:
     just build && just docker-build && docker save oxidized | bzip2 | ssh austin@raspberrypi.local docker load && just docker-deploy
