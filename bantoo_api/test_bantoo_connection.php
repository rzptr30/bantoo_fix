<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST');
header('Access-Control-Allow-Headers: Content-Type');

// Database connection parameters
$host = "localhost"; // Or your database host
$username = "root"; // Your database username
$password = ""; // Your database password
$database = "bantoo_db"; // Your database name

// Attempt database connection
try {
    $conn = new mysqli($host, $username, $password, $database);
    
    // Check connection
    if ($conn->connect_error) {
        echo json_encode([
            'connected' => false,
            'error' => $conn->connect_error,
            'message' => 'Failed to connect to database: ' . $conn->connect_error
        ]);
    } else {
        // Try to perform a simple query to verify database is working
        $testQuery = "SHOW TABLES";
        $result = $conn->query($testQuery);
        
        if ($result) {
            $tables = [];
            while($row = $result->fetch_array()) {
               $tables[] = $row[0];
            }
            
            echo json_encode([
                'connected' => true,
                'message' => 'Successfully connected to bantoo_db',
                'tables' => $tables,
                'database_info' => [
                    'host' => $host,
                    'database' => $database,
                    'server' => $_SERVER['SERVER_SOFTWARE']
                ]
            ]);
        } else {
            echo json_encode([
                'connected' => false,
                'error' => $conn->error,
                'message' => 'Database connection succeeded but query failed: ' . $conn->error
            ]);
        }
        
        $conn->close();
    }
} catch (Exception $e) {
    echo json_encode([
        'connected' => false,
        'error' => $e->getMessage(),
        'message' => 'Exception occurred: ' . $e->getMessage()
    ]);
}
?>