  #!/bin/bash
  echo "Cheking meteor project..."
  secs=$((3))
  while [ $secs -gt 0 ]; do
     echo -ne "$secs\033[0K\r"
     sleep 1
     : $((secs--))
  done

  if ! [ -d .meteor ] 
  then
    echo "============================="
    echo "This is not a meteor project!"
    echo "============================="
  else
    echo "======================="
    echo "This is meteor project!"
    echo "======================="

    while [[ $username == '' ]] 
    do
      read -p "Docker username:" username
      if [[ -z "$username" ]]; then
        echo "No input. Try again!"
      else
        echo $username
      fi
    done

    while [[ $name == '' ]] 
    do
      read -p "Name for docker image:" name
      if [[ -z "$name" ]]; then
        echo "No input. Try again!"
      else
        echo $name
      fi
    done  

    read -p "Tag: (latest)?" tag
    tag=${tag:-latest}
    echo $tag
    
    currentFolder="${PWD##*/}"

    build_folder="$currentFolder-build"
    if [ ! -d "../$build_folder" ]; then
      mkdir -p "../$build_folder";
    fi
    
    echo "=========================="
    echo "Building meteor project..."
    echo "=========================="
    secs=$((3))
    while [ $secs -gt 0 ]; do
      echo -ne "$secs\033[0K\r"
      sleep 1
      : $((secs--))
    done
    meteor build --architecture=os.linux.x86_64 "../$build_folder"

    cd ../$build_folder

    tar -xvzf "$currentFolder.tar.gz"

    cd bundle

    dockerfile=Dockerfile

    if [ ! -e $dockerfile ]; then
      echo "FROM node:4.4.7-slim
COPY . /bundle
RUN (cd /bundle/programs/server && npm install)
ENV PORT=80
EXPOSE 80
CMD node /bundle/main.js" > $dockerfile
    fi

    if [ -e $dockerfile ]; then
      echo "=============="
      echo "Dockerizing..."
      echo "=============="
      secs=$((3))
      while [ $secs -gt 0 ]; do
        echo -ne "$secs\033[0K\r"
        sleep 1
        : $((secs--))
      done
      docker build -t "$username/$name:$tag" .
    else
      echo "File $dockerfile does not exist!"
    fi
    echo "====================================================="
    echo "Meteor project is successfully builded and dockerized"
    echo "Builded meteor project is in folder $currentFolder-build"
    echo "New docker image: $username/$name:$tag"
    echo "====================================================="

  fi
