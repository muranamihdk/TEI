cd `dirname $0`
echo cp -r Guidelines-web/en ../../tei-guideline-ja/
cp -r Guidelines-web/en ../../tei-guideline-ja/
echo cp -r Guidelines-web/ja ../../tei-guideline-ja/
cp -r Guidelines-web/ja ../../tei-guideline-ja/
echo cd ../../tei-guideline-ja/
cd ../../tei-guideline-ja/
git add .
git commit -m "rebuild html files"
git push origin master
