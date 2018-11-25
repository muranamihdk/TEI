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
