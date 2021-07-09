#!/usr/bin/bash

DIRECTORY="$HOME/hacking"

if [ -d "$DIRECTORY" ]; then echo "[INFO] Using $DIRECTORY for files, binaries will be in /usr/bin"; else mkdir "$DIRECTORY";fi

#GH_REPO="https://github.com/cli/cli"

declare -a repos=(
		"https://github.com/ffuf/ffuf" 
		"https://github.com/projectdiscovery/subfinder" 
		"https://github.com/projectdiscovery/httpx" 
		"https://github.com/tomnomnom/waybackurls"
	)

# Download jhaddix's all.txt wordlist
echo "Downloading all.txt..."
ALL_TXT_GIST="https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt"
curl "$ALL_TXT_GIST" -o "$DIRECTORY/all.txt"  -Ls

# Download FuzzDB
echo "Downloading FuzzDB..."
rm -rf "$DIRECTORY/fuzzdb"
git clone "https://github.com/fuzzdb-project/fuzzdb" "$DIRECTORY/fuzzdb" -q

function downloadRepo(){
	NAME=$(echo "$1" | grep "[^\/]\w+$" -ioE)
        echo "Downloading $NAME..."
        REGEX='\/.*\/.*\/releases\/download\/.*\/.*linux[-_]amd64.*\.\w+'
        LINK=$(curl "$1/releases" -s | grep "$REGEX" -ioP | head -n 1 | cut -c 2-)
	FILE=$(echo "$LINK" | grep "[^\/][a-zA-Z0-9\._]+$" -oPi)
	curl "https://github.com/$LINK" -sL -o "$FILE"
	mkdir "$NAME"
	tar -xf "$FILE" -C "$NAME"
	cp "$NAME/$NAME" "/usr/bin"
	rm -rf "$NAME" "$FILE" 
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


for REPO in "${repos[@]}"
do
	downloadRepo "$REPO"
done

downloadNodeJS
downloadGolang

#Update npm
echo "Updating npm to the latest version..."
npm install -g npm --silent

# Install zx and yarn
echo "Installing yarn and zx..."
npm install -g --silent yarn zx
