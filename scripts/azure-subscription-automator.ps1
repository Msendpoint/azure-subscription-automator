### FILE: index.php
<?php

session_start();

// Check if access token is available
if (!isset($_SESSION['ms_access_token'])) {
    exit('Access token is missing. Please authenticate first.');
}

$accessToken = $_SESSION['ms_access_token'];

// Fetch subscriptions from Microsoft Graph
try {
    $endpoint = '/subscriptions';
    $response = $ms->graphCall($endpoint, $accessToken);
    $subscriptions = json_decode($response);

    foreach ($subscriptions->value as $subscription) {
        render_premium_card(
            'Subscription', 
            "ID: {$subscription->id}, Name: {$subscription->displayName}", 
            null, 
            'neutral', 
            '📄'
        );
    }
} catch (Exception $e) {
    echo "Error fetching subscriptions: " . $e->getMessage();
}

?>

### FILE: scripts/Automation.ps1
<#
.SYNOPSIS
   Lists Azure subscriptions using Microsoft Graph.

.DESCRIPTION
   This script connects to Microsoft Graph using client credentials and lists all Azure subscriptions.
   It ensures error handling and disconnects from Graph after execution.

.EXAMPLE
   .\Automation.ps1 -TenantId '<TENANT_ID>' -ClientId '<CLIENT_ID>' -ClientSecret '<CLIENT_SECRET>'

.NOTES
   Author:      Souhaiel Morhag
   Company:     MSEndpoint.com
   Blog:        https://msendpoint.com
   Academy:     https://app.msendpoint.com/academy
   LinkedIn:    https://linkedin.com/in/souhaiel-morhag
   GitHub:      https://github.com/Msendpoint
   License:     MIT
#>

param(
    [string]$TenantId,
    [string]$ClientId,
    [string]$ClientSecret
)

Import-Module Microsoft.Graph

Try {
    # Connect to Microsoft Graph
    Connect-MgGraph -ClientId $ClientId -TenantId $TenantId -ClientSecret $ClientSecret
    
    # Retrieve and list subscriptions
    $subscriptions = Get-MgSubscription 
    if ($subscriptions) {
        foreach ($subscription in $subscriptions) {
            Write-Output ("ID: $($subscription.Id), Name: $($subscription.DisplayName)")
        }
    }
} Catch {
    Write-Error "Error: $($_.Exception.Message)"
    exit 1
} Finally {
    # Disconnect from Graph
    Disconnect-MgGraph
    exit 0
}