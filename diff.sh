#!/bin/sh
uplng=/data/data/com.termux/files/home/source/M.A.R.T/tools/lang/indonesia-lng
oldlng=/data/data/com.termux/files/home/source/M.A.R.T/.temp/indonesia-lng

diff $uplng $oldlng | grep "\+export" | sed "s/+export/export/"
