# file - File related operations

# bin: Install executable from URL
file.bin() {
	curl -fsSL -o "$2" "$1" && chmod +x "$2"
}

# enter: Get files from URL and chdir to directory
file.enter() {
	cd "$1" || exit
	pwd
}
