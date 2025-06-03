<?php
// Test database connection
$host = '127.0.0.1';
$port = '8889';
$dbname = 'moodle36';
$username = 'root';
$password = '';

echo "<h2>Testing Database Connection</h2>";

try {
    // Test connection
    $dsn = "mysql:host=$host;port=$port;charset=utf8mb4";
    $pdo = new PDO($dsn, $username, $password);
    $pdo->setAttribute(PDO::ATTR_ERRMODE, PDO::ERRMODE_EXCEPTION);
    
    echo "<p style='color: green;'>✓ MySQL connection successful!</p>";
    
    // Check if database exists
    $stmt = $pdo->query("SHOW DATABASES");
    $databases = $stmt->fetchAll(PDO::FETCH_COLUMN);
    
    echo "<h3>Available databases:</h3>";
    echo "<ul>";
    foreach ($databases as $db) {
        echo "<li>$db</li>";
    }
    echo "</ul>";
    
    if (in_array($dbname, $databases)) {
        echo "<p style='color: green;'>✓ Database '$dbname' exists!</p>";
        
        // Try to connect to the specific database
        $dsn_with_db = "mysql:host=$host;port=$port;dbname=$dbname;charset=utf8mb4";
        $pdo_db = new PDO($dsn_with_db, $username, $password);
        echo "<p style='color: green;'>✓ Successfully connected to '$dbname' database!</p>";
        
    } else {
        echo "<p style='color: red;'>✗ Database '$dbname' does not exist!</p>";
        echo "<p>You need to create the database '$dbname' first.</p>";
        
        // Try to create the database
        try {
            $pdo->exec("CREATE DATABASE `$dbname` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci");
            echo "<p style='color: green;'>✓ Database '$dbname' created successfully!</p>";
        } catch (PDOException $e) {
            echo "<p style='color: red;'>✗ Failed to create database: " . $e->getMessage() . "</p>";
        }
    }
    
} catch (PDOException $e) {
    echo "<p style='color: red;'>✗ Connection failed: " . $e->getMessage() . "</p>";
    echo "<p>Please check:</p>";
    echo "<ul>";
    echo "<li>MAMP MySQL is running</li>";
    echo "<li>Port is correct (8889)</li>";
    echo "<li>Username/password is correct</li>";
    echo "</ul>";
}
?> 