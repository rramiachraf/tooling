## Installation
*Make sure you have unzip, git, gcc and make.
#### Debian/Ubuntu
```sh
rramiachraf@distro:~$ sudo apt update
rramiachraf@distro:~$ sudo apt install unzip gcc make git -y
rramiachraf@distro:~$ git clone https://github.com/rramiachraf/tooling.git
```
#### RedHat/Fedora
```sh
rramiachraf@distro:~$ sudo dnf update
rramiachraf@distro:~$ sudo dnf install unzip git make gcc
rramiachraf@distro:~$ git clone https://github.com/rramiachraf/tooling.git
```
## Usage
```sh
rramiachraf@distro:~$ sudo ./tooling/tooling.sh
```

## Things you'll install
- [x] ffuf
- [x] subfinder
- [x] httpx
- [x] fprobe
- [x] waybackurls
- [x] all.txt
- [x] FuzzDB
- [x] NodeJS
- [ ] Golang (Not working due to $PATH in sudo mode)
- [x] npm & yarn
- [x] zx
- [x] Github CLI
- [x] Amass
- [ ] GoSpider
- [x] masscan
- [ ] sqlmap (Not yet implemented)
- [ ] dirsearch (Not yet implemented)
- [ ] massdns (Not yet implemented)
- [ ] googler (Not yet implemented)
- [x] assetfinder
- [x] notify
- [x] jq
