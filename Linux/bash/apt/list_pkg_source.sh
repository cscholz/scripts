LC_ALL=C dpkg-query --showformat='${Package}:${Status}\n' -W '*' \
| fgrep ':install ok installed' \
| cut -d: -f1 \
| (while read pkg; do
inst_version=$(apt-cache policy $pkg \
| fgrep Installed: \
| cut -d: -f2-);
origin=$(apt-cache policy "$pkg" \
| fgrep " *** ${inst_version}" -C1 \
| tail -n 1 \
| cut -c12-);
echo $pkg $origin;
done)

