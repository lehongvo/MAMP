<?php  // Moodle configuration file

unset($CFG);
global $CFG;
$CFG = new stdClass();

$CFG->dbtype    = 'mysqli';
$CFG->dblibrary = 'native';
$CFG->dbhost    = 'localhost';
$CFG->dbname    = 'moodle36';  // Changed from 'mysql' to a dedicated Moodle database
$CFG->dbuser    = 'root';
$CFG->dbpass    = 'root';      // Default MAMP password is usually 'root'
$CFG->prefix    = 'mdl_';
$CFG->dboptions = array (
  'dbpersist' => 0,
  'dbport' => '8889',          // Added MAMP's default MySQL port
  'dbsocket' => '/Applications/MAMP/tmp/mysql/mysql.sock',
  'dbcollation' => 'utf8mb4_unicode_ci',
);

$CFG->wwwroot   = 'http://localhost:8888/moodle36';
// $CFG->wwwroot   = 'http://192.168.0.199:8888/moodle36';
$CFG->dataroot  = '/Applications/MAMP/data/moodle36';
$CFG->admin     = 'admin';

$CFG->directorypermissions = 0777;

require_once(dirname(__FILE__) . '/lib/setup.php');

// There is no php closing tag in this file,
// it is intentional because it prevents trailing whitespace problems!
