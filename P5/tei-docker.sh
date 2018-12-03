if [ $(docker ps | grep tei | wc -l) -eq 0 ]
then
  docker start -ai tei
elif [ $(whoami) == "venus" ]
then
  docker attach tei
fi
