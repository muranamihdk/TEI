cd `dirname $0`
make clean
make html-web
make clean
make html-web ALLLANGUAGES=ja LANGUAGE=ja INPUTLANGUAGE=ja
