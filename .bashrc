#!/bin/bash

ff() {
	[ $# -eq 0 ] || find "$1" -type f
	[ $# -eq 0 ] && find . -type f
}

gitwhat() {
	git branch -l && git log --oneline -n 10
}
alias gitwaht=gitwhat
alias githwat=gitwhat

debug() {
	lldb ${@:1:1} -o 'r' -- ${@:2}
}

jerrypush() {
	git push origin HEAD:refs/for/$1
}
jerrypick() {
	git fetch origin $1 && git cherry-pick $1
}
jerrycheck() {
	git fetch origin $1 && git checkout $1
}

findc() {
	rg "$@" --no-heading
}
func() {
	rg "\s*\w+(\*|&)?\s(\*|&)?(\w+::)*$1\([^;]*$" --no-heading ${@:2}
	rg "\s*\w+(\*|&)?\s(\*|&)?(\w+::)*$1\([^;]*\{" --no-heading ${@:2}
}
datatype() {
	rg "^\s*(union|struct|typedef|class|enum class)\s(\w+\s)?$1($|\s.*)" --no-heading ${@:2}
	rg "^} $1;$" --no-heading ${@:2}
	rg "typedef \w+ $1;" --no-heading ${@:2}
}

hardkill() {
	killall $1 -s SIGKILL
}
exectime() {
	SECONDS=0 && $1 && echo "Took $SECONDS seconds to run $1"
}

switch_monitor() {
	hyprctl keyword monitor DP-$1,enable
	hyprctl dispatch moveworkspacetomonitor 1 DP-$1
	hyprctl dispatch moveworkspacetomonitor 2 DP-$1
	hyprctl dispatch moveworkspacetomonitor 3 DP-$1
	hyprctl dispatch moveworkspacetomonitor 4 DP-$1
	hyprctl dispatch moveworkspacetomonitor 5 DP-$1
	hyprctl dispatch moveworkspacetomonitor 6 DP-$1
	hyprctl dispatch moveworkspacetomonitor 7 DP-$1
	[[ $1 == '3' ]] && hyprctl keyword monitor DP-1,disable && hyprctl keyword monitor DP-2,disable
	[[ $1 == '2' ]] && hyprctl keyword monitor DP-1,disable && hyprctl keyword monitor DP-3,disable
	[[ $1 == '1' ]] && hyprctl keyword monitor DP-2,disable && hyprctl keyword monitor DP-3,disable
}

install_mips_binutils() {
	wget https://ftp.gnu.org/gnu/binutils/binutils-2.44.tar.zst
	tar -xf binutils-2.44.tar.zst
	cd binutils-2.44
	./configure --build=x86_64-linux-gnu --prefix="/usr/local" --with-lib-path="/usr/local/lib" --target=mips-elf --with-arch=vr4300 --enable-64-bit-bfd --enable-plugins --enable-shared --disable-gold --disable-multilib --disable-nls --disable-rpath --disable-static --disable-werror
	make -j16
	make install
}