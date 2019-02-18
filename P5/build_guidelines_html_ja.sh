cd `dirname $0`
make clean
make html-web
echo cp -r Guidelines-web/en ../../tei-guideline-ja/
cp -r Guidelines-web/en ../../tei-guideline-ja/
make clean
make html-web ALLLANGUAGES=ja LANGUAGE=ja INPUTLANGUAGE=ja
echo cp -r Guidelines-web/ja ../../tei-guideline-ja/
cp -r Guidelines-web/ja ../../tei-guideline-ja/
