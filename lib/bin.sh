# bin.sh - Executable files

bin.install() {
	file.install -mode=755 -prefix="$_USR"/bin "$@"
}

bin.use() {
	file.install -mode=755 -prefix="$_RUN"/bin "$@"
}
