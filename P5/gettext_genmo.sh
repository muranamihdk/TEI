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
