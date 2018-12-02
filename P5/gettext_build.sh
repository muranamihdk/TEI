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
| jq -r '.needs_commit') = false ]
then
  echo "No changes to commit at Weblate"
  exit 0
fi

if [ $(curl \
 -s \
 -d operation=commit \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/components/tei-guidelines-ja/ab-about/repository/ \
| jq -r '.result') = false ]
then
  echo "Commit at Welate Failure."
  exit 1
else
  echo "Commit at Weblate Success."
fi

echo

echo "git pull origin localize_ja"
git pull origin localize_ja

echo

# poファイルをmoファイルに変換（Source/_mo 以下に poファイルと同じディレクトリ構成で）
for SOURCE in `find "${PREFIX_PATH}/${PO_DIR}/${TARGET_LANG}/${GUIDELINES_DIR}/" -type f -name "*.po" -print`
do
  SOURCE_DIR=`dirname $SOURCE`
  TARGET_DIR=${SOURCE_DIR/\/$PO_DIR/\/$MO_DIR}

  if [ ! -d "$TARGET_DIR" ]
  then
    mkdir -p "$TARGET_DIR"
    echo Created: "$TARGET_DIR"
  fi

  MO_FILE="$TARGET_DIR"/$(basename "$SOURCE" .po).mo
  if [ ! -f "MO_FILE" ]
  then
    msgfmt "$SOURCE" -o "$MO_FILE"
    echo Generated: "$MO_FILE"
  elif [ "$SOURCE" -nt "$MO_FILE" ]
  then
    msgfmt "$SOURCE" -o "$MO_FILE"
    echo Updated: "$MO_FILE"
  fi
done

echo

# mo ファイルから翻訳ファイルを作成（Source/Guidelines/ja 以下に）
for SOURCE in `find "${PREFIX_PATH}/${MO_DIR}/${TARGET_LANG}/${GUIDELINES_DIR}/${TARGET_LANG}/" -type f -name "*.mo" -print`
do
  SOURCE_DIR=`dirname $SOURCE`
  SOURCE_DIR="${SOURCE_DIR#$PREFIX_PATH/}"
  SOURCE_DIR="${SOURCE_DIR#$MO_DIR/}"
  SOURCE_DIR="${SOURCE_DIR#$TARGET_LANG/}"
  TARGET_DIR="${PREFIX_PATH}/${SOURCE_DIR}"
  ORIGINAL_DIR=${TARGET_DIR/\/$TARGET_LANG/\/$SOURCE_LANG}

  if [ ! -d "$TARGET_DIR" ]
  then
    mkdir -p "$TARGET_DIR"
    echo Created: "$TARGET_DIR"
  fi

  TRANSLATED_FILE="$TARGET_DIR"/$(basename "$SOURCE" .mo).xml
  ORIGINAL_FILE="$ORIGINAL_DIR"/$(basename "$SOURCE" .mo).xml
  if [ ! -f "$TRANSLATED_FILE" ]
  then
    itstool -m "$SOURCE" "$ORIGINAL_FILE" -o "$TRANSLATED_FILE"
    echo Created: "$TRANSLATED_FILE"
  elif [ "$SOURCE" -nt "$TRANSLATED_FILE" ]
  then
    itstool -m "$SOURCE" "$ORIGINAL_FILE" -o "$TRANSLATED_FILE"
    echo Updated: "$TRANSLATED_FILE"
  fi
done

echo

echo "git diff origin/localize_ja --name-only"
git diff origin/localize_ja --name-only
if [ $(git diff origin/localize_ja --name-only | wc -l) -ne 0 ]
then
  echo
  git add .
  git commit -m "update ja translation files"
  echo
  echo "git push origin localize_ja"
  git push origin localize_ja
fi

echo

# pull at Weblate
if [ $(curl \
 -s \
 -d operation=pull \
 -H "Authorization: Token 4uQDi24YSNEYgpxkkTvwdk7z9gZYupXiUvcxyccT" \
 http://www3420ue.sakura.ne.jp:8080/api/components/tei-guidelines-ja/ab-about/repository/ \
| jq -r '.result') = false ]
then
  echo "Pull at Weblate Failure."
  exit 1
else
  echo "Pull at Weblate Success."
  echo
fi
