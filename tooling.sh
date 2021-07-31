#!/bin/bash

# Styling output
tput bold
tput setaf 6

DIRECTORY=$(pwd)"/hacking"

if [ -d "$DIRECTORY" ]; then true; else mkdir "$DIRECTORY";fi

echo "[INFO] Using $DIRECTORY for files, binaries will be in /usr/bin"

declare -a repos=(
		"https://github.com/ffuf/ffuf" 
		"https://github.com/projectdiscovery/subfinder" 
		"https://github.com/projectdiscovery/httpx"
	        "https://github.com/projectdiscovery/notify"	
		"https://github.com/tomnomnom/waybackurls"
		"https://github.com/tomnomnom/assetfinder"
		"https://github.com/OWASP/amass"
		"https://github.com/cli/cli"
	)

# Download jhaddix's all.txt wordlist
echo "Downloading all.txt..."
ALL_TXT_GIST="https://gist.github.com/jhaddix/f64c97d0863a78454e44c2f7119c2a6a/raw/96f4e51d96b2203f19f6381c8c545b278eaa0837/all.txt"
curl "$ALL_TXT_GIST" -o "$DIRECTORY/all.txt"  -Ls

# Download FuzzDB
echo "Downloading FuzzDB..."
rm -rf "$DIRECTORY/fuzzdb"
git clone "https://github.com/fuzzdb-project/fuzzdb" "$DIRECTORY/fuzzdb" -q

# Download masscan
echo "Downloading masscan..."
git clone https://github.com/robertdavidgraham/masscan -q
make -C masscan/ -s
cp masscan/bin/masscan /usr/bin
rm -rf masscan

# Download jq
echo "Downloading jq..."
curl -sL https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64 -o "jq"
chmod +x jq
cp jq /usr/bin
rm jq

function downloadRepo(){
	NAME=$(echo "$1" | grep "[^\/]\w+$" -ioE)
        echo "Downloading $NAME..."
        REGEX='\/.*\/.*\/releases\/download\/.*\/.*linux[-_]amd64.*\.(?:zip|gz|xz|tgz)'
        LINK=$(curl "$1/releases" -s | grep "$REGEX" -ioP | head -n 1 | cut -c 2-)
	FILE=$(echo "$LINK" | grep "[^\/][a-zA-Z0-9\._-]+$" -oPi)
	curl "https://github.com/$LINK" -sL -o "$FILE"
	mkdir "$NAME"
	if [ $(echo "$FILE" | grep "\w+$" -Poi | head -n 1) == "zip" ]
	then
		unzip "$FILE" -d "$NAME" > /dev/null
	else
		tar -xf "$FILE" -C "$NAME"
	fi

	SUB=$(echo "$NAME/"$(ls "$NAME" | head -n 1))

	if isThereABinary $NAME
	then
		cp "$NAME/$NAME" "/usr/bin"
	elif [ -f "$SUB/$NAME"  ]
	then
		cp "$SUB/$NAME" "/usr/bin"
	else
		copyToUsr "$SUB"
	fi

	rm -rf "$FILE" "$NAME"
}

function isThereABinary(){
        if [ $(ls "$1" | grep "^$1\$") ]
        then
                return 0
        else
                return 1
        fi
}

function copyToUsr(){
	cp "$1/bin" "$1/share" "$1/include" "$1/lib" "/usr/" -r &> /dev/null
}

function downloadNodeJS(){
        echo "Downloading NodeJS..."
        NODE_DEST=$(curl "https://nodejs.org/en" -Ls | grep "https:\/\/nodejs\.org\/dist\/v\d+.\d+.\d+" -iPo | tail -n 1)
        FILE=$(curl "$NODE_DEST" -Ls | grep 'node-v\d+\.\d+\.\d+-linux-x64\.tar\.xz' -iPo | head -n 1)
        FOLDER=$(echo "$FILE" | sed "s/.tar.xz//")
        curl "$NODE_DEST/$FILE" -Ls -o "$FILE"
        tar -xf "$FILE"
        copyToUsr "$FOLDER"
        rm "$FILE"
        rm -rf "$FOLDER"
}

function downloadGolang(){
        echo "Downloading Golang..."
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
npm install -g npm &> /dev/null

# Install zx and yarn
echo "Installing yarn and zx..."
npm install -g yarn zx &> /dev/null

# Reset colors
tput init
