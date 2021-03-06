#!/bin/zsh

homePath=~
omzPath="$homePath/.oh-my-zsh"
zshCustomPath="$homePath/.zsh_custom"
pluginGithubURLs="
	https://github.com/zsh-users/zsh-autosuggestions.git
	https://github.com/zsh-users/zsh-syntax-highlighting.git
	"
themesURLs="
	http://raw.github.com/caiogondim/bullet-train-oh-my-zsh-theme/master/bullet-train.zsh-theme
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
	cd $omzPath
	sh tools/upgrade.sh
}

fetchPlugins() {
	# Loop through arguments and install plugins
	while [ ${#} -gt 0 ]
	do
		# Set arguments to varailbe for readability
		url=$1
		name=$(echo $url |awk -F / '{ print $NF }' |awk -F. '{ print $1 }')
		path="$zshCustomPath/plugins/$name"

		# Get plugin from git repo or update if it already exist
		if [ ! -d $path ]
		then
			git clone $url $path
		else
			cd $path
			git pull --rebase --stat origin master
		fi

		# shift arguments over for next plug in
		shift
	done
}

fetchThemes() {
	# Loop through arguments and install themes
	while [ ${#} -gt 0 ]
	do
		# Set arguments to varailbe for readability
		url=$1
		name=$(echo $url |awk -F / '{ print $NF }')
		path="$zshCustomPath/themes"

		# Download latest theme version
		curl -fsSL $url -o $path/$name

		# shift arguments over for next plug in
		shift
	done
}

main() {
	if [ ! -d $omzPath ]; then
		installOMZ
	else
		cd $omzPath
		upgradeOMZ
		cd $homePath
	fi


	if [ ! -d $zshCustomPath ]; then
		if git clone https://github.com/jgranzow86/zsh_custom.git $zshCustomPath
		then
			echo "${colorsGreen}Install complete${colorsReset}"
		else
			echo "${colorsRed}Install failed${colorsReset}"
			exit 10
		fi
	else
		cd $zshCustomPath
		if git pull --rebase --stat origin master
		then
			echo "${colorsGreen}Update complete${colorsReset}"
		else
			echo "${colorsRed}Update failed${colorsReset}"
			exit 20
		fi
	fi

	# Link .zshrc
	if [ ! -h $homePath/.zshrc ]
	then
		if [ -f $homePath/.zshrc ]
		then
			rm $homePath/.zshrc
		fi
		cd $homePath
		ln -s .zsh_custom/.zshrc .zshrc
	fi
		
	mkdir -p $zshCustomPath/plugins
	fetchPlugins $pluginGithubURLs

	mkdir -p $zshCustomPath/themes
	fetchThemes $themesURLs
}

main $@