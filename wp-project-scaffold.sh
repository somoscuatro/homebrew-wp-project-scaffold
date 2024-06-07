#!/bin/bash

# Check for flags
if [[ "$1" == "--version" ]]; then
    echo "wp-project-scaffold v1.0.3"
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
echo
SAFE_PROJECT_NAME=$(echo "$PROJECT_NAME" | tr '[:upper:]' '[:lower:]' | LC_ALL=C sed -e 's/[^[:alnum:]-]/-/g' -e 's/--*/-/g')

read -p "💬 Enter the GitHub author (default: https://github.com/somoscuatro): " AUTHOR_GITHUB
echo
AUTHOR_GITHUB=${AUTHOR_GITHUB:-https://github.com/somoscuatro}

read -p "💬 Enter the author email (default: tech@somoscuatro.es): " AUTHOR_EMAIL
echo
AUTHOR_EMAIL=${AUTHOR_EMAIL:-tech@somoscuatro.es}

read -p "💬 Enter the author URL (default: https://somoscuatro.es): " AUTHOR_URL
echo
AUTHOR_URL=${AUTHOR_URL:-https://somoscuatro.es}

read -p "💬 Enter the author name (default: somoscuatro): " AUTHOR
echo
SAFE_AUTHOR=${AUTHOR:-somoscuatro}

read -p "💬 Enter the project description (default: “My beautiful WordPress project.”): " PROJECT_DESCRIPTION
echo
PROJECT_DESCRIPTION=${PROJECT_DESCRIPTION:-"My beautiful WordPress project."}

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

# Create .env file
mv .env.sample .env
sed -i.bak "s|your-project|$SAFE_PROJECT_NAME|g" .env && rm -f .env.bak

# Clone the wp-project-default-settings repository
echo "🚧 Adding default WordPress settings..."
echo
run_cmd git clone git@github.com:somoscuatro/wp-project-default-settings.git wp-project-default-settings-temp

if [ ! -d "wp-project-default-settings-temp" ]; then
    echo "☠️ Failed to clone the wp-project-default-settings repository. Please check the URL and try again."
    exit 1
fi

run_cmd cp -r wp-project-default-settings-temp/common/. .

if [[ $INSTALL_THEME =~ ^[Yy]$ ]]; then
    run_cmd cp -r wp-project-default-settings-temp/with-starter-theme/. .
else
    run_cmd cp -r wp-project-default-settings-temp/without-starter-theme/. .
fi

sed -i.bak -e "s|your-project|$SAFE_PROJECT_NAME|g" \
           -e "s|author-github|$AUTHOR_GITHUB|g" \
           -e "s|author-email|$AUTHOR_EMAIL|g" \
           -e "s|author-url|$AUTHOR_URL|g" \
           -e "s|author-name|$SAFE_AUTHOR|g" \
           -e "s|project-description|$PROJECT_DESCRIPTION|g" \
           .gitignore composer.json package.json phpstan.neon.dist
run_cmd rm -f .gitignore.bak composer.json.bak package.json.bak phpstan.neon.dist.bak

run_cmd rm -rf wp-project-default-settings-temp

# Prepare SSL certificates
mkdir -p .docker/certs
cd .docker/certs

echo "🚧 Installing SSL certificates..."
echo
run_cmd mkcert -key-file cert-key.pem -cert-file cert.pem "${SAFE_PROJECT_NAME}.test" localhost

cd ../../

# Start Docker containers
run_cmd docker-compose up -d

echo "🚧 Downloading WordPress Core..."
echo
while ! docker-compose exec -T wp ls "/var/www/html/wp-settings.php" &> /dev/null; do
    sleep 5
done

# Install dependencies
echo "🚧 Installing dependencies. This might take a while..."
    run_cmd docker-compose run --rm wp composer install
    run_cmd docker-compose run --rm wp pnpm install
echo

# Create project repo and make initial commit
rm -rf .git
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

# Wait for the database container to be ready
until docker-compose exec db mysqladmin ping --silent; do
  sleep 1
done

# Install WordPress
wp_core_install_command="core install --url=https://{$SAFE_PROJECT_NAME}.test --title=$SAFE_PROJECT_NAME --admin_user=admin --admin_password=admin --admin_email=$AUTHOR_EMAIL"
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

    echo "🚧 Installing sc-starter-theme dependencies. This might take a while..."
    echo
    run_cmd docker-compose run --rm wp composer install --working-dir=wp-content/themes/sc-starter-theme
    run_cmd docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme install
    run_cmd docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme run build

    if [ $? -ne 0 ]; then
        echo "☠️ Failed to install and build the sc-starter-theme. Please check for errors and try again."
        exit 1
    fi

    run_cmd rm -rf .git

    run_cmd rm -rf .github .husky .vscode patches .editorconfig .env.example
    rum_cmd rm -rf .eslintrc.json .gitignore .prettierignore .stylelintrc
    run_cmd rm -rf CODE_OF_CONDUCT.md commitlint.config.json LICENSE.md
    run_cmd rm -rf phpcs.xml phpstand.neon.dist README.md SECURITY.md

    cd ../../../
    run_cmd git add .
    run_cmd git commit -m "feat: add theme sc-starter-theme"

    run_cmd docker-compose run --rm cli theme activate sc-starter-theme
else
    echo
    echo "🦘 Skipping the installation of the sc-starter-theme."
fi

echo
echo "✅ The website is ready to be visited at https://${SAFE_PROJECT_NAME}.test"
