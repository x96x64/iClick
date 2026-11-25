#!/bin/zsh
# Build iClick and keep it running in the background as the LaunchAgent
# local.iclick, started at login and restarted by launchd if it exits.
#
#   zsh install.zsh              build, install, and (re)start
#   zsh install.zsh --uninstall  stop and remove everything
#
# The source, this script, and the binary live in
# ~/Library/Application Support/iClick/, so the installed copy keeps working
# after the folder it was installed from is gone. Run it again from there after
# editing iclick.swift.
set -euo pipefail

label=local.iclick
dir="$HOME/Library/Application Support/iClick"
plist="$HOME/Library/LaunchAgents/$label.plist"
domain="gui/$(id -u)"
src="${0:A:h}"

launchctl bootout "$domain/$label" 2>/dev/null || true
while launchctl print "$domain/$label" &>/dev/null; do sleep 0.1; done

if [[ ${1:-} == --uninstall ]]; then
    rm -rf "$dir" "$plist"
    echo "Removed $label."
    exit 0
fi

mkdir -p "$dir" "${plist:h}"
if [[ $src != ${dir:A} ]]; then
    cp "$src/iclick.swift" "$src/install.zsh" "$dir/"
fi
swiftc -O -o "$dir/iclick" "$dir/iclick.swift"

cat > "$plist" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>$label</string>
    <key>ProgramArguments</key>
    <array>
        <string>$dir/iclick</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>ProcessType</key>
    <string>Interactive</string>
</dict>
</plist>
EOF

launchctl bootstrap "$domain" "$plist"
echo "Installed and started $label."
