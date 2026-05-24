#!/bin/sh -e

# This script installs bitwarden as the default password manager.
# It also installs the bw-login-and-unlock script to ensure that bitwarden is logged in and unlocked.
# getcred is built on top of bitwarden, so we need to install bitwarden first.
#
# This script is idempotent: if the bw command is already present, all package
# installation steps are skipped and only the helper scripts are (re-)copied.

if ! command -v bw > /dev/null 2>&1; then
	# install bitwarden using aptdcon, because we assume that this install script can be run at a time
	# when other scripts (like the ubuntu installer) are still running, and aptdcon can handle that gracefully.
	yes | aptdcon --hide-terminal --install="curl jq"
	export RELEASE=$(lsb_release -rs)

	if [ "$RELEASE" != "99.99" ];
	then
		echo "# Ubuntu $RELEASE detected, installing upstream nodejs"
		curl -fsSL https://deb.nodesource.com/setup_24.x | bash -e
		yes | aptdcon --hide-terminal --install="nodejs"
	else
		echo "# Ubuntu $RELEASE detected, installing npm via apt"
		yes | aptdcon --hide-terminal --install="npm"
	fi

	npm install -g @bitwarden/cli
else
	echo "bw already installed, skipping package installation"
fi

# Copy the bw-login-and-unlock script to /usr/local/bin so that it can be used by getcred.
cp scripts/bw-login-and-unlock /usr/local/bin/bw-login-and-unlock
chmod +x /usr/local/bin/bw-login-and-unlock

# Copy the getcred script to /usr/local/bin so that it can be used by the user.
cp src/getcred /usr/local/bin/getcred
chmod +x /usr/local/bin/getcred