#!/usr/bin/env bash
set -e

GHC_VERSION="7.8.2"
HOOGLE_VERSION="4.2.33"

GHC_DIRNAME="x86_64-osx-ghc-${GHC_VERSION}"
HOOGLE="/Users/karl/usr/hoogle/.cabal-sandbox"
BASE_DATABASES="${HOOGLE}/share/${GHC_DIRNAME}/hoogle-${HOOGLE_VERSION}/databases"
LOCAL_DATABASES=".cabal-sandbox/share/doc/${GHC_DIRNAME}"

RE_NAME='\w(\w|-)*\w'

dbnum=0
files=''

for line in $(cabal sandbox hc-pkg list); do

  if echo "$line" | grep -Eq '^/'; then
    dbnum=$(expr $dbnum + 1)
    continue
  fi

  if echo "$line" | grep -Fq '('; then
    # Parentheses indicate a hidden package
    continue
  fi
  
  name="$(echo "$line" | grep -Eo "${RE_NAME}-" | grep -Eo "${RE_NAME}")"

  if [ $dbnum -eq 1 ]; then
    dbfile="${BASE_DATABASES}/${name}.hoo"
  elif [ $dbnum -eq 2 ]; then
    dbfile="${LOCAL_DATABASES}/${line}/html/${name}.hoo"
  fi

  if [ ! -f "$dbfile" ]; then
    echo "Warning: no database for ${line}" 1>&2
    echo "Tried $dbfile" 1>&2
    continue
  fi

  files="${files} ${dbfile}"
done

echo "$files"
