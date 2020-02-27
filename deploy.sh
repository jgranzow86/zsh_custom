#!/bin/zsh

homePath=~
omzPath="$homePath/.oh-my-zsh"
zshCustomPath="$homePath/.zsh_custom"
pluginGithubURLs="
	https://github.com/zsh-users/zsh-autosuggestions.git
	https://github.com/zsh-users/zsh-syntax-highlighting.git
	"
themes="

"

# Common colors used
colorsReset='\033[0m'       # Restore Defaults
colorsRed='\033[0;31m'     # RED text
colorsGreen='\033[0;32m'   # GREEN text
colorsYellow='\033[0;33m'  # YELLOW text
colorsRedBG='\033[37;31m'     # WHITE text RED background
colorsGreenBG='\033[37;42m'   # WHITE text GREEN background
colorsYellowBG='\033[37;43m'  # WHITE text YELLOW background

installOMZ() {
	sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

uninstallOMZ() {
	sh $omzPath/tools/uninstall.sh
}

upgradeOMZ() {
	sh $omzPath/tools/upgrade.sh
}

fetchPlugins() {
	# Loop through arguments and install plugins
	while [ ${#} -gt 0 ]
	do
		# Set arguments to varailbe for readability
		url=$1
		name=$(echo $url |awk -F / '{ print $5 }' |awk -F. '{ print $1 }')
		path="$zshCustomPath/plugins/$name"

		# Get plugin from git repo or update if it already exist
		if [ ! -d $path/$name ]
		then
			git clone $url $path/$name
		else
			git --get-dir $path/$name pull --rebase --stat origin master
		fi

		# shift arguments over for next plug in
		shift 2
	done
}

fetchThemes() {
	echo "PASS"
}

main() {
	cd $omzPath
	if [ ! -d $omzPath ]; then
		installOMZ
	else
		upgradeOMZ
	fi

	cd -

	if [ ! -d $zshCustomPath ]; then
		if git clone https://github.com/jgranzow86/zsh_custom.git $zshCustomPath
		then
			echo ${colorsGreen}'Install complete!'${colorsReset}
		else
			echo ${colorsRed}'Install failed'${colorsReset}
			exit
		fi
	else
		if git --get-dir $zshCustomPath pull --rebase --stat origin master
		then
			echo ${colorsGreen}'Update complete!'${colorsReset}
		else
			echo ${colorsRed}'Update failed'${colorsReset}
			exit
		fi
	fi

	# Place updated .zshrc
	cp $zshCustomPath/.zshrc $homePath/.zshrc
	chmod 644 $homePath/.zshrc

	mkdir -p $zshCustomPath/plugins
	fetchPlugins $pluginGithubURLs

	mkdir -p $zshCustomPath/themes
	fetchThemes $themes
}

main $@