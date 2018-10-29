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

# xmlファイルからpotファイルを生成（Source/_pot 以下に）
for SOURCE in `find "${PREFIX_PATH}/${GUIDELINES_DIR}/${SOURCE_LANG}/" -type f -name "*.xml" -print`
do
  #echo "$SOURCE"
  #echo $(dirname "$SOURCE")/$(basename "$SOURCE" .xml).pot
  SOURCE_DIR=`dirname $SOURCE`
  TARGET_DIR="${PREFIX_PATH}/${POT_DIR}"/"${SOURCE_DIR#$PREFIX_PATH/}"
  if [ ! -d "$TARGET_DIR" ]
  then
    mkdir -p "$TARGET_DIR"
    echo Created: "$TARGET_DIR"
  fi
  itstool -o "$TARGET_DIR"/$(basename "$SOURCE" .xml).pot "$SOURCE"
done
