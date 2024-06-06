#!/bin/bash
# version 0.4.0

# Define the repository URL
REPO_URL="https://github.com/somoscuatro/docker-wordpress-local.git"

# Ask the user for the project name
read -p "Enter the name of your project: " DIR_NAME

# Create the project directory if it doesn't exist
mkdir -p "$DIR_NAME"

# Check for git, docker-compose, and curl
if ! command -v git &> /dev/null; then
    echo "git could not be found. Please install it and try again."
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "docker-compose could not be found. Please install it and try again."
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo "curl could not be found. Please install it and try again."
    exit 1
fi

# Clone the Git repository into the specified directory
git clone "$REPO_URL" "$DIR_NAME"

# Check if the clone was successful
if [ ! -d "$DIR_NAME" ]; then
    echo "Failed to clone the repository. Please check the URL and try again."
    exit 1
fi

# Navigate to the project directory
cd "$DIR_NAME"

# Remove the existing .git directory
rm -rf .git

# Create a new .gitignore file with the specified content
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

# Assuming the .env.sample file is at the root of the cloned repository
# Rename .env.sample to .env
mv .env.sample .env

# Replace all occurrences of 'your-project' in the .env file with the actual project name
escaped_project_name=$(printf '%s\n' "$DIR_NAME" | sed -e 's/[\/&]/\\&/g')
sed -i.bak "s|your-project|$escaped_project_name|g" .env && rm -f .env.bak

# Create certs directory inside .docker folder
mkdir -p .docker/certs

# Navigate to the certs directory
cd .docker/certs

# Generate SSL certificates using the project name for the domain
mkcert -key-file cert-key.pem -cert-file cert.pem "${DIR_NAME}.test" localhost

# Navigate back to the root of your project directory
cd ../../

# Run docker-compose up in detached mode
docker-compose up -d

# Define the path to the WordPress directory inside the container
# Update this path if your WordPress directory is different
WP_CORE_PATH="/var/www/html"

# Wait for WordPress Core to be downloaded inside the Docker container
echo "Waiting for WordPress Core to be downloaded..."
while ! docker-compose exec -T wp ls "$WP_CORE_PATH/wp-settings.php" &> /dev/null; do
    printf '.'
    sleep 5
done
echo "WordPress Core download is complete."

# Initialize a new git repository
git init

# Add all files to the repository
git add .

# Commit the changes with the specified message
git commit -m "feat: scaffold wordpress installation using somoscuatro/docker-wordpress-local"

# Check if the commit was successful
if [ $? -ne 0 ]; then
    echo "Git commit failed. Please check for errors and try again."
    exit 1
fi

echo "WordPress core has been downloaded and committed successfully."

# Copy wp-config-sample.php to wp-config.php
cp wp-config-sample.php wp-config.php

# Use sed to replace database constants with getenv calls
# The following syntax works for both GNU and BSD sed. For BSD (including macOS), an empty string is provided with the -i option.
sed -i '' -e "s/define( 'DB_NAME', 'database_name_here' );/define( 'DB_NAME', getenv( 'DB_NAME' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_USER', 'username_here' );/define( 'DB_USER', getenv( 'DB_USER' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_PASSWORD', 'password_here' );/define( 'DB_PASSWORD', getenv( 'DB_PASSWORD' ) );/" wp-config.php
sed -i '' -e "s/define( 'DB_HOST', 'localhost' );/define( 'DB_HOST', getenv( 'DB_HOST' ) );/" wp-config.php

# Add WP_SITEURL and WP_HOME definitions
sed -i '' -e "/define( 'DB_COLLATE', '' );/a\\
define( 'WP_SITEURL', getenv( 'WP_SITEURL' ) );\\
define( 'WP_HOME', getenv( 'WP_HOME' ) );" wp-config.php

# Install WordPress using WP-CLI
wp_core_install_command="core install --url=https://${escaped_project_name}.test --title='${escaped_project_name}' --admin_user=admin --admin_password=admin --admin_email=tech@somoscuatro.es"

# Execute the WP-CLI command using docker-compose run
docker-compose run --rm cli $wp_core_install_command

# Ask the user if they want to install the SomosCuatro starter theme
read -p "Do you want to install the somoscuatro starter theme? (y/n) " -n 1 -r
echo # Move to a new line

if [[ $REPLY =~ ^[Yy]$ ]]; then
    # Ensure the themes directory exists
    mkdir -p wp-content/themes

    # Navigate to the themes directory
    cd wp-content/themes

    # Clone the sc-starter-theme repository
    git clone git@github.com:somoscuatro/sc-starter-theme.git sc-starter-theme

    # Check if the clone was successful
    if [ $? -ne 0 ]; then
        echo "Failed to clone the sc-starter-theme repository. Please check for errors and try again."
        exit 1
    fi

    # Navigate to the sc-starter-theme directory
    cd sc-starter-theme

    # Install theme dependencies with pnpm and composer
    docker-compose run --rm wp composer install --working-dir=wp-content/themes/sc-starter-theme
    docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme install
    docker-compose run --rm wp pnpm --dir=wp-content/themes/sc-starter-theme run build

    # Check if the installation and build were successful
    if [ $? -ne 0 ]; then
        echo "Failed to install and build the sc-starter-theme. Please check for errors and try again."
        exit 1
    fi

    # Execute the WP-CLI command using docker-compose run
    docker-compose run --rm cli theme activate sc-starter-theme

    echo "The sc-starter-theme has been installed and built successfully."
else
    echo "Skipping the installation of the sc-starter-theme."
fi
