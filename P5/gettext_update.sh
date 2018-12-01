GETTEXT="gettext"
MSGFMT="msgfmt"
MSGMERGE="msgmerge"
ITSTOOL="itstool"

PREFIX_PATH="Source"
SPECS_DIR="Specs"
GUIDELINES_DIR="Guidelines"
POT_DIR="_pot"
PO_DIR="_po"
MO_DIR="_mo"
SOURCE_LANG="en"
TARGET_LANG="ja"

WD=`pwd`
if [ "${WD##/*/}" != "P5" ]
then
  echo "Not in dir TEI/P5"
  exit
fi

for COMMAND in $GETTEXT $MSGFMT $MSGMERGE $ITSTOOL
do
  which "$COMMAND" >/dev/null 2>&1
  if [ "$?" -eq 1 ]
  then
    echo "$COMMAND command was not found."
    exit
  fi
done

echo "git checkout localize_ja"
git checkout localize_ja
echo


if [ $(curl \
 -s \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/projects/tei-guidelines-ja/repository/ \
| jq -r '.needs_commit') = true ]
then
  echo "Changes to commit exists at Weblate. Commit before local update."
  exit 1
fi

echo "git fetch teic"
git fetch teic
echo
echo "git diff origin/dev teic/dev --name-only"
git diff origin/dev teic/dev --name-only
echo
if [ $(git diff origin/dev teic/dev --name-only | wc -l) -eq 0 ]
then
  echo "No changes to merge."
  exit 0
fi

# Sync with upstream
git checkout dev
#git merge teic/master -m "Merge branch 'master' of https://github.com/TEIC/Documentation into master"
echo "git pull teic dev:dev"
git pull teic dev:dev
echo
echo "git push origin dev:dev"
git push origin dev:dev
git checkout -

echo
echo "git merge dev"
git merge dev -m "Merge branch 'dev' into localize_ja"
echo
echo "git push origin localize_ja"
git push origin localize_ja
echo


# xmlファイルからpotファイルを生成（Source/_pot 以下に）
for SOURCE in `find "${PREFIX_PATH}/${GUIDELINES_DIR}/${SOURCE_LANG}/" -type f -name "*.xml" -print`
do
  SOURCE_DIR=`dirname $SOURCE`
  TARGET_DIR="${PREFIX_PATH}/${POT_DIR}"/"${SOURCE_DIR#$PREFIX_PATH/}"
  if [ ! -d "$TARGET_DIR" ]
  then
    mkdir -p "$TARGET_DIR"
    echo Created: "$TARGET_DIR"
  fi
  TARGET_FILE="$TARGET_DIR"/$(basename "$SOURCE" .xml).pot
  if [ ! -f "$TARGET_FILE" ]
  then
    itstool -o "$TARGET_FILE" "$SOURCE"
    echo Created: "$TARGET_FILE"
  elif [ "$SOURCE" -nt "$TARGET_FILE" ]
  then
    itstool -o "$TARGET_FILE" "$SOURCE"
    echo Updated: "$TARGET_FILE"
  fi 
done

# potファイルからpoファイルを生成（Source/_po 以下に）／poファイルがあるときは変更をマージ
for SOURCE in `find "${PREFIX_PATH}/${POT_DIR}/${GUIDELINES_DIR}/${SOURCE_LANG}/" -type f -name "*.pot" -print`
do
  SOURCE_DIR=`dirname $SOURCE`
  SOURCE_DIR=${SOURCE_DIR/\/$SOURCE_LANG/\/$TARGET_LANG}
  SOURCE_DIR="${SOURCE_DIR#$PREFIX_PATH/}"
  SOURCE_DIR="${SOURCE_DIR#$POT_DIR/}"
  TARGET_DIR="${PREFIX_PATH}/${PO_DIR}/${TARGET_LANG}"/"${SOURCE_DIR}"

  if [ ! -d "$TARGET_DIR" ]
  then
    mkdir -p "$TARGET_DIR"
    echo Created: "$TARGET_DIR"
  fi

  PO_FILE="$TARGET_DIR"/$(basename "$SOURCE" .pot).po
  if [ ! -f "$PO_FILE" ]
  then
    cp "$SOURCE" "$PO_FILE"
    echo Created: "$PO_FILE"
    continue
  elif [ "$SOURCE" -nt "$PO_FILE" ]
  then
    msgmerge -U "$PO_FILE" "$SOURCE"
    echo Updated: "$PO_FILE"
  fi
done

echo "git diff origin/localize_ja --name-only"
git diff origin/localize_ja --name-only
if [ $(git diff origin/localize_ja --name-only | wc -l) -ne 0 ]
then
  echo
  git add .
  git commit -m "update po files"
  echo
  echo "git push origin localize_ja"
  git push origin localize_ja
fi


SOURCE_DIR=Source/Guidelines/en/Images/
TARGET_DIR=Source/Guidelines/ja/Images/
for file in `(ls "$SOURCE_DIR" | grep -v .xml)`
do
 if [ "${SOURCE_DIR}${file}" -nt "${TARGET_DIR}${file}" ]
 then
  cp "${SOURCE_DIR}${file}" "${TARGET_DIR}${file}"
  echo Copied: "$file"
 fi
done

echo "git diff origin/localize_ja --name-only"
git diff origin/localize_ja --name-only
if [ $(git diff origin/localize_ja --name-only | wc -l) -ne 0 ]
then
  echo
  git add .
  git commit -m "update image files"
  echo
  echo "git push origin localize_ja"
  git push origin localize_ja
fi


# pull at Weblate
if [ $(curl \
 -s \
 -d operation=pull \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/components/tei-guidelines-ja/about/repository/ \
| jq -r '.result') = false ]
then
  echo "Pull@Weblate Failure."
  exit 1
else
  echo "Pull@Weblate Success."
  echo
fi
