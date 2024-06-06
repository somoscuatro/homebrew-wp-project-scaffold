#!/bin/bash

# Check for flags
if [[ "$1" == "--version" ]]; then
    echo "wp-project-scaffold v1.0.0"
    exit 0
fi

VERBOSE=false
if [[ "$1" == "--verbose" ]]; then
    VERBOSE=true
fi

# Functions
run_cmd() {
    if [ "$VERBOSE" = true ]; then
        "$@"
    else
        "$@" > /dev/null 2>&1
    fi
}

# Prompts
read -p "💬 Enter the name of your project: " PROJECT_NAME
SAFE_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -e 's/[^[:alnum:]-]/-/g' -e 's/--*/-/g')

echo
echo "Optionally, you can install the somoscuatro starter theme, which"
echo "offers a robust foundation for your WordPress project. Please note"
echo "that this theme relies on the Advanced Custom Fields Pro (ACF Pro)"
echo "plugin to function properly."
echo

while true; do
    read -p "💬 Do you want to install the somoscuatro starter theme? (Y/n) " -r
    echo

    case "$(echo "$REPLY" | tr '[:upper:]' '[:lower:]')" in
        'y'|'yes')
            INSTALL_THEME='y'
            break
            ;;
        'n'|'no')
            INSTALL_THEME='n'
            break
            ;;
        '')  # Default to 'Y' if the user presses Enter
            INSTALL_THEME='y'
            break
            ;;
        *)
            echo "⚠️ Invalid response. Please answer 'y' or 'yes' for yes, or 'n' or 'no' for no."
            ;;
    esac
done

# Check for git, docker-compose, and curl
if ! command -v git &> /dev/null; then
    echo "☠️ git could not be found. Please install it and try again."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "☠️ docker-compose could not be found. Please install it and try again."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "☠️ curl could not be found. Please install it and try again."
    exit 1
fi

# Clone the Git repository
run_cmd git clone https://github.com/somoscuatro/docker-wordpress-local.git "$SAFE_PROJECT_NAME"
if [ ! -d "$SAFE_PROJECT_NAME" ]; then
    echo "Failed to clone the repository. Please check the URL and try again."
    exit 1
fi

cd "$SAFE_PROJECT_NAME"

# Prepare project local repository
rm -rf .git
cat << 'EOF' > .gitignore
# WordPress
/wp-config.php
/wp-content/uploads/*
!/wp-content/uploads/.htaccess

# WordPress development plugins
*/plugins/mailhog/
*/plugins/disable-emails/
*/plugins/woocommerce-email-test/
*/plugins/query-monitor/

# Ignore these WordPress plugins from the core
*/plugins/hello.php
*/plugins/akismet/

# Ignore specific WordPress themes
*/themes/twenty*/
*/themes/storefront*/

# Ignore cache files
/wp-content/litespeed/
/wp-content/cache/
/wp-content/autoptimize_404_handler.php

# Plugin ewww-image-optimizer
/wp-content/ewww/

# Plugin webp-express
/wp-content/webp-express/
/wp-content/themes/.htaccess
/wp-content/uploads/.htaccess

# Env
.env*
!.env.example

# Dependencies
/vendor
node_modules/

# SQL dumps
*.sql
*.sqlite

# Logs
*.log
*/debug.log
php_errorlog

# OS
*.url
*.lnk
.DS*

# Git
.project
.idea/
.well-known
/tags

# Patch/diff artifacts
*.diff
*.orig
*.rej
interdiff*.txt

# VS Code
*code-workspace

# VIM
*.un~
Session.vim
.netrwhist
*~
*.swp
.lvimrc

# emacs artifacts
*~
\#*\#
EOF

# Create .env file
mv .env.sample .env
sed -i.bak "s|your-project|$SAFE_PROJECT_NAME|g" .env && rm -f .env.bak

# Prepare SSL certificates
mkdir -p .docker/certs
cd .docker/certs

echo
echo "🚧 Installing SSL certificates..."
run_cmd mkcert -key-file cert-key.pem -cert-file cert.pem "${SAFE_PROJECT_NAME}.test" localhost

cd ../../

# Start Docker containers
run_cmd docker-compose up -d

echo
echo "🚧 Downloading WordPress Core..."
while ! docker-compose exec -T wp ls "/var/www/html/wp-settings.php" &> /dev/null; do
    sleep 5
done

# Create project repo and make initial commit
run_cmd git init
run_cmd git add .
run_cmd git commit -m "feat: scaffold wordpress installation using somoscuatro/docker-wordpress-local"

if [ $? -ne 0 ]; then
    echo "☠️ Git commit failed. Please check for errors and try again."
    exit 1
fi

# Prepare wp-config.php
cp wp-config-sample.php wp-config.php
sed -i '' -e "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', getenv( 'DB_NAME' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', getenv( 'DB_USER' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', getenv( 'DB_PASSWORD' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', getenv( 'DB_HOST' ) );/" wp-config.php
sed -i '' -e "/define( 'DB_COLLATE', '' );/a\\
define( 'WP_SITEURL', getenv( 'WP_SITEURL' ) );\\
define( 'WP_HOME', getenv( 'WP_HOME' ) );" wp-config.php

# Install WordPress
wp_core_install_command="core install --url=https://${SAFE_PROJECT_NAME}.test --title=${PROJECT_NAME} --admin_user=admin --admin_password=admin --admin_email=tech@somoscuatro.es"
run_cmd docker-compose run --rm cli $wp_core_install_command

# Install sc-startup-theme
if [[ $INSTALL_THEME =~ ^[Yy]$ ]]; then
    mkdir -p wp-content/themes
    cd wp-content/themes

    run_cmd git clone git@github.com:somoscuatro/sc-starter-theme.git sc-starter-theme

    if [ $? -ne 0 ]; then
        echo "☠️ Failed to clone the sc-starter-theme repository. Please check for errors and try again."
        exit 1
    fi

    cd sc-starter-theme

    echo
    echo "🚧 Installing sc-starter-theme dependencies. This might take a while..."
    run_cmd docker-compose run --rm wp composer install --working-dir=wp-content/themes/sc-starter-theme
    run_cmd docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme install
    run_cmd docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme run build

    if [ $? -ne 0 ]; then
        echo "☠️ Failed to install and build the sc-starter-theme. Please check for errors and try again."
        exit 1
    fi

    run_cmd docker-compose run --rm cli theme activate sc-starter-theme
else
    echo
    echo "🦘 Skipping the installation of the sc-starter-theme."
fi

echo
echo "✅ The website is ready is ready to be visited at https://${SAFE_PROJECT_NAME}.test"
