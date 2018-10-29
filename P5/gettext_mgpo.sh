GETTEXT="gettext"
MSGFMT="msgfmt"
MSGMERGE="msgmerge"
ITSTOOL="itstool"

PREFIX_PATH="Source"
SPECS_DIR="Specs"
GUIDELINES_DIR="Guidelines"
POT_DIR="_pot"
PO_DIR="_po"
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
  fi

  msgmerge -U "$PO_FILE" "$SOURCE"
done
