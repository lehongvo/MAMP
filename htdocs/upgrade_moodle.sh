#!/bin/bash

echo "Starting Moodle upgrade process..."

# Navigate to htdocs directory
cd /Users/user/Desktop/MAMP/htdocs

# Check current version
echo "Current Moodle version:"
grep "release" moodle/version.php

# Download Moodle 3.9 if not exists
if [ ! -f "moodle-latest-39-stable.tgz" ]; then
    echo "Downloading Moodle 3.9..."
    curl -o moodle-latest-39-stable.tgz https://download.moodle.org/download.php/direct/stable39/moodle-latest-39.tgz
fi

# Create new backup
echo "Creating backup..."
if [ -d "moodle.backup.$(date +%Y%m%d)" ]; then
    rm -rf "moodle.backup.$(date +%Y%m%d)"
fi
cp -r moodle "moodle.backup.$(date +%Y%m%d)"

# Move current moodle to temporary location
echo "Moving current moodle..."
mv moodle moodle.temp

# Extract new Moodle
echo "Extracting new Moodle 3.9..."
tar -xzf moodle-latest-39-stable.tgz

# Copy config.php back
echo "Copying config.php..."
cp moodle.temp/config.php moodle/

# Copy custom themes if they exist
if [ -d "moodle.temp/theme" ]; then
    echo "Checking for custom themes..."
    for theme_dir in moodle.temp/theme/*/; do
        theme_name=$(basename "$theme_dir")
        if [ "$theme_name" != "boost" ] && [ "$theme_name" != "classic" ] && [ "$theme_name" != "more" ]; then
            echo "Found custom theme: $theme_name"
            if [ ! -d "moodle/theme/$theme_name" ]; then
                cp -r "$theme_dir" "moodle/theme/"
                echo "Copied custom theme: $theme_name"
            fi
        fi
    done
fi

# Copy custom mods if they exist
if [ -d "moodle.temp/mod" ]; then
    echo "Checking for custom modules..."
    for mod_dir in moodle.temp/mod/*/; do
        mod_name=$(basename "$mod_dir")
        # Check if it's a custom module (not in standard Moodle)
        if [ ! -d "moodle/mod/$mod_name" ]; then
            cp -r "$mod_dir" "moodle/mod/"
            echo "Copied custom module: $mod_name"
        fi
    done
fi

# Set permissions
echo "Setting permissions..."
chmod -R 755 moodle
chmod 740 moodle/admin/cli/cron.php

# Clean up
rm -rf moodle.temp

echo "Code upgrade completed!"
echo "Next steps:"
echo "1. Go to your Moodle site in browser"
echo "2. Navigate to Site administration > Notifications"
echo "3. Follow the database upgrade process"
echo "4. After completion, clear all caches"

echo "New Moodle version:"
grep "release" moodle/version.php 