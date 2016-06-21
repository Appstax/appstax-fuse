
set -e

mkdir -p build/appstax-fuse

## Copy to build/appstax-fuse

cp -a starterprojects build/appstax-fuse/starterprojects
cp -a examples        build/appstax-fuse/examples

## ZIP

cd build
zip -rq appstax-fuse.zip appstax-fuse
cd -

