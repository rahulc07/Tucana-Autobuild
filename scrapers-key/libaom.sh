#!/bin/bash
PACKAGE=$1
wget "https://storage.googleapis.com/aom-releases/" --output-document index.xml &> /dev/null
cat index.xml | grep -E -o "libaom-[0-9].[0-9].[0-9].tar.gz" | sort | tail -n 1 | sed 's/libaom-//g' | sed 's/\.tar\.gz//'
rm -f index.xml
