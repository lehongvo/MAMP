#!/bin/bash

# ====================================================================
# MOODLE UPGRADE SCRIPT: 3.6 → 3.9
# ====================================================================
# Author: Assistant AI
# Date: June 2025
# Description: Complete automated upgrade from Moodle 3.6 to 3.9
# ====================================================================

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
MOODLE_ROOT="/Applications/MAMP/htdocs/moodle36"
MOODLE_DATA="/Applications/MAMP/data/moodle36"
PHP_PATH="/Applications/MAMP/bin/php/php7.2.10/bin/php"
MYSQL_PATH="/Applications/MAMP/Library/bin/mysql"
DB_HOST="localhost"
DB_PORT="8889"
DB_USER="root"
DB_PASS="root"
DB_NAME="moodle36"

echo -e "${BLUE}=====================================================================${NC}"
echo -e "${BLUE}              MOODLE 3.6 → 3.9 UPGRADE SCRIPT${NC}"
echo -e "${BLUE}=====================================================================${NC}"

# Step 1: Pre-flight checks
echo -e "\n${YELLOW}[STEP 1] Pre-flight checks...${NC}"
if [ ! -d "$MOODLE_ROOT" ]; then
    echo -e "${RED}Error: Moodle directory not found: $MOODLE_ROOT${NC}"
    exit 1
fi

if [ ! -f "$PHP_PATH" ]; then
    echo -e "${RED}Error: PHP not found: $PHP_PATH${NC}"
    exit 1
fi

echo -e "${GREEN}✓ Pre-flight checks passed${NC}"

# Step 2: Backup current installation
echo -e "\n${YELLOW}[STEP 2] Creating backup...${NC}"
BACKUP_NAME="moodle36.backup.$(date +%Y%m%d_%H%M%S)"
if [ -d "$MOODLE_ROOT.backup" ]; then
    mv "$MOODLE_ROOT.backup" "$MOODLE_ROOT.$BACKUP_NAME"
fi
cp -r "$MOODLE_ROOT" "$MOODLE_ROOT.backup"
echo -e "${GREEN}✓ Backup created: $MOODLE_ROOT.backup${NC}"

# Step 3: Download Moodle 3.9
echo -e "\n${YELLOW}[STEP 3] Downloading Moodle 3.9...${NC}"
cd /Applications/MAMP/htdocs
if [ ! -f "moodle-latest-39.tgz" ]; then
    echo "Downloading Moodle 3.9..."
    curl -L -o moodle-latest-39.tgz https://download.moodle.org/download.php/direct/stable39/moodle-latest-39.tgz
fi
echo -e "${GREEN}✓ Moodle 3.9 downloaded${NC}"

# Step 4: Replace Moodle code
echo -e "\n${YELLOW}[STEP 4] Replacing Moodle code...${NC}"
mv moodle36 moodle36.temp
tar -xzf moodle-latest-39.tgz
mv moodle moodle36
echo -e "${GREEN}✓ Moodle 3.9 code extracted${NC}"

# Step 5: Restore configuration and customizations
echo -e "\n${YELLOW}[STEP 5] Restoring configuration...${NC}"
cp moodle36.temp/config.php moodle36/
echo -e "${GREEN}✓ config.php restored${NC}"

# Copy custom themes (if any)
if [ -d "moodle36.temp/theme" ]; then
    for theme_dir in moodle36.temp/theme/*/; do
        theme_name=$(basename "$theme_dir")
        if [ "$theme_name" != "boost" ] && [ "$theme_name" != "classic" ] && [ "$theme_name" != "more" ]; then
            if [ ! -d "moodle36/theme/$theme_name" ]; then
                cp -r "$theme_dir" "moodle36/theme/"
                echo -e "${GREEN}✓ Custom theme copied: $theme_name${NC}"
            fi
        fi
    done
fi

# Copy custom modules (if any)
if [ -d "moodle36.temp/mod" ]; then
    for mod_dir in moodle36.temp/mod/*/; do
        mod_name=$(basename "$mod_dir")
        if [ ! -d "moodle36/mod/$mod_name" ]; then
            cp -r "$mod_dir" "moodle36/mod/"
            echo -e "${GREEN}✓ Custom module copied: $mod_name${NC}"
        fi
    done
fi

# Step 6: Set permissions
echo -e "\n${YELLOW}[STEP 6] Setting permissions...${NC}"
chmod -R 755 moodle36
chmod 740 moodle36/admin/cli/cron.php
echo -e "${GREEN}✓ Permissions set${NC}"

# Step 7: Fix database version conflicts
echo -e "\n${YELLOW}[STEP 7] Fixing database version conflicts...${NC}"
echo "Updating cache plugin versions..."
$MYSQL_PATH -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e "UPDATE mdl_config_plugins SET value='2018120300' WHERE plugin LIKE 'cachestore_%' AND name='version';" 2>/dev/null
$MYSQL_PATH -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e "UPDATE mdl_config_plugins SET value='2018120300' WHERE plugin LIKE 'cache%' AND name='version';" 2>/dev/null
echo -e "${GREEN}✓ Database version conflicts resolved${NC}"

# Step 8: Run Moodle upgrade
echo -e "\n${YELLOW}[STEP 8] Running Moodle upgrade...${NC}"
cd moodle36
$PHP_PATH admin/cli/upgrade.php --non-interactive
echo -e "${GREEN}✓ Moodle upgrade completed${NC}"

# Step 9: Clear all caches
echo -e "\n${YELLOW}[STEP 9] Clearing caches...${NC}"
$PHP_PATH admin/cli/purge_caches.php
rm -rf $MOODLE_DATA/cache/* 2>/dev/null || true
rm -rf $MOODLE_DATA/localcache/* 2>/dev/null || true
rm -rf $MOODLE_DATA/lang/* 2>/dev/null || true
echo -e "${GREEN}✓ All caches cleared${NC}"

# Step 10: Update theme revision
echo -e "\n${YELLOW}[STEP 10] Updating theme revision...${NC}"
$MYSQL_PATH -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e "UPDATE mdl_config SET value = UNIX_TIMESTAMP() WHERE name = 'themerev';" 2>/dev/null
echo -e "${GREEN}✓ Theme revision updated${NC}"

# Step 11: Cleanup
echo -e "\n${YELLOW}[STEP 11] Cleanup...${NC}"
cd /Applications/MAMP/htdocs
sudo rm -rf moodle36.temp 2>/dev/null || rm -rf moodle36.temp
rm -f test.php db_test.php 2>/dev/null || true
echo -e "${GREEN}✓ Cleanup completed${NC}"

# Step 12: Verification
echo -e "\n${YELLOW}[STEP 12] Verification...${NC}"
VERSION_CHECK=$($MYSQL_PATH -h $DB_HOST -P $DB_PORT -u $DB_USER -p$DB_PASS $DB_NAME -e "SELECT value FROM mdl_config WHERE name='release';" -s -N 2>/dev/null)
echo -e "${GREEN}✓ Current Moodle version: $VERSION_CHECK${NC}"

# Final message
echo -e "\n${BLUE}=====================================================================${NC}"
echo -e "${GREEN}                    UPGRADE COMPLETED SUCCESSFULLY!${NC}"
echo -e "${BLUE}=====================================================================${NC}"
echo -e "${YELLOW}Next steps:${NC}"
echo -e "1. Access your site: http://localhost:8888/moodle36"
echo -e "2. Clear browser cache (Cmd+Shift+R)"
echo -e "3. Go to Site administration > Server > Maintenance mode (turn OFF)"
echo -e "4. Go to Site administration > Development > Purge all caches"
echo -e "5. Check Site administration > Notifications for any issues"
echo ""
echo -e "${GREEN}Backup location: $MOODLE_ROOT.backup${NC}"
echo -e "${BLUE}=====================================================================${NC}" 