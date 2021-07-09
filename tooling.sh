#!/usr/bin/bash

DIRECTORY="~/hacking"

FUFF_REPO="https://github.com/ffuf/ffuf"
SUBFINDER_REPO="https://github.com/projectdiscovery/subfinder"
HTTPX_REPO="https://github.com/projectdiscovery/httpx"
WAYBACKURLS_REPO="https://github.com/tomnomnom/waybackurls"
GH_REPO="https://github.com/cli/cli"

# Download jhaddix's all.txt wordlist
#echo "Downloading all.txt..."
#ALL_TXT_GIST="https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt"
#curl "$ALL_TXT_GIST" -o "all.txt"  -Ls

# Download FuzzDB
#echo "Downloading FuzzDB..."
#git clone "https://github.com/fuzzdb-project/fuzzdb" "fuzzdb" -q

function getDownloadURL(){
        echo "Downloading $(echo "$1" | grep "[^\/]\w+$" -ioE)..."
        REGEX='href="(\/.*\/.*\/releases\/download\/.*\/.*linux[-_]amd64.*)" rel="nofollow"'
        URL=$(curl "$1/releases" -s | grep "$REGEX" -ioP | head -n 1)
        echo "$URL"
}

function downloadNodeJS(){
        echo "Downloading NodeJS..."
        NODE_DEST=$(curl "https://nodejs.org/en" -Ls | grep "https:\/\/nodejs\.org\/dist\/v\d+.\d+.\d+" -iPo | tail -n 1)
        FILE=$(curl "$NODE_DEST" -Ls | grep 'node-v\d+\.\d+\.\d+-linux-x64\.tar\.xz' -iPo | head -n 1)
        FOLDER=$(echo "$FILE" | sed "s/.tar.xz//")
        curl "$NODE_DEST/$FILE" -Ls -o "$FILE"
        tar -xf "$FILE"
        cp "$FOLDER/bin" "$FOLDER/include" "$FOLDER/lib" "$FOLDER/share" "/usr" -r
        rm "$FILE"
        rm -rf "$FOLDER"
}

function downloadGolang(){
        echo "Downloading Golang"
        URL="https://golang.org/dl"
        FILE=$(curl "$URL" -sL |  grep "go.*linux-amd64\.tar\.gz" -oPi | head -n 1)
        curl "$URL/$FILE" -sL -o "$FILE"
        rm -rf /usr/local/go && tar -C /usr/local -xzf "$FILE"
        export PATH=$PATH:/usr/local/go/bin
        rm "$FILE"
}

getDownloadURL "$FUFF_REPO"
downloadGolang

