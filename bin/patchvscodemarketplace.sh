#!/usr/bin/env sh

# Patches vscodium's product.json file to enable access to the standard VS Code 
# extension marketplace. Use -R to revert.

declare -a possibilities=(
  '/usr/share/codium/resources/app/product.json'
  '/usr/share/vscodium/resources/app/product.json'
)

productpath=''
for p in "${possibilities[@]}"
do
  if [ -f "$p" ]; then
    productpath=$p
    fi
done

if [[ "$productpath" = "" ]]; then
  echo "Could not find a valid product.json path"
  exit 1
fi

rpmnewpath="$productpath.rpmnew"
echo "Looking for .rpmnew file at $rpmnewpath"
if [ -f "$rpmnewpath" ] ; then
  if [ "$rpmnewpath" -nt "$productpath" ] ; then
    echo ".rpmnew file exists at $rpmnewpath and is newer. Restoring to this first."
    mv "$productpath" "$productpath.old"
    cp "$rpmnewpath" "$productpath"
  else
      echo ".rpmnew file exists but is older than .product.json. Ignoring"
    echo
  fi
fi

if [ "${1}" = "-R" ]; then
  sed -i -e 's/^[[:blank:]]*"serviceUrl":.*/    "serviceUrl": "https:\/\/marketplace.visualstudio.com\/_apis\/public\/gallery",/' \
    -e '/^[[:blank:]]*"cacheUrl/d' \
    -e '/^[[:blank:]]*"serviceUrl/a\    "cacheUrl": "https:\/\/vscode.blob.core.windows.net\/gallery\/index",' \
    -e 's/^[[:blank:]]*"itemUrl":.*/    "itemUrl": "https:\/\/marketplace.visualstudio.com\/items"/' \
    -e '/^[[:blank:]]*"linkProtectionTrustedDomains/d' \
    $productpath
    echo "Reverted"
else
  sed -i -e 's/^[[:blank:]]*"serviceUrl":.*/    "serviceUrl": "https:\/\/open-vsx.org\/vscode\/gallery",/' \
    -e '/^[[:blank:]]*"cacheUrl/d' \
    -e 's/^[[:blank:]]*"itemUrl":.*/    "itemUrl": "https:\/\/open-vsx.org\/vscode\/item"/' \
    -e '/^[[:blank:]]*"linkProtectionTrustedDomains/d' \
    -e '/^[[:blank:]]*"documentationUrl/i\  "linkProtectionTrustedDomains": ["https://open-vsx.org"],' \
    $productpath
    echo "Patched"
fi
