cd `dirname $0`
echo cd ../../tei-guideline-ja/
cd ../../tei-guideline-ja/
git add .
git commit -m "rebuild html files"
git push origin master
