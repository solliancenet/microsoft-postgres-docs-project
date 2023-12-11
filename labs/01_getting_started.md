# Hand on lab: Provisioning, configuring, and getting started with development

In this lab you will create an Azure Database for PostgreSQL Flexible Server, configure it using the Azure Portal, Azure CLI and Azure REST APIs.  Once created and configured, you will then connect to it using pgAdmin to add a new 1532 dimension vector column.

## Pre-requistes

- [Azure subscription](https://azure.microsoft.com/free/)
- [Resource group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/manage-resource-groups-portal)

## Creating an Azure Database for Postgres Flexible Server

- Open the [Azure Portal](https://portal.azure.com/)
- Select **Create a resource (+)** in the upper-left corner of the portal.
- Select **Databases** > **Azure Database for PostgreSQL Flexible**.
- Select the **Flexible server** deployment option.
- Select **Azure Database for PostgreSQL - Flexible server** deployment option
- Fill out the Basics form with the following information:
  - Resource Group: Name of your lab resource group
  - Server name:  `dev-pg-eastus2-001`
  - Region: `East US 2`
  - PostgreSQL Version: `16`
  - Workload Type: `General purpose`
  - Compute + Storage: `Standard_D4ds_v4`
  - Authentication method: `PostgreSQL and Microsoft Entra authentication`
  - Admin username: `s2admin`
  - Password and confirm password: `S0lliance123`
- Select **Next: Networking**. On the Networking tab, you can choose how your server is reachable.
- Configure Networking options:
  - Select **Public access (allowed IP addresses)**
- Select **Review + create** to review your selections.
- Select **Create** to provision the server. This operation may take a few minutes.
- On the toolbar, select the Notifications icon (a bell) to monitor the deployment process.
- Open your server's **Overview** page.
  - Make a note of the Server name and the Server admin login name.
  - Hover your cursor over each field, and the copy symbol appears to the right of the text.
  - Select the copy symbol as needed to copy the values for use later

## Configuring backup retention using Azure REST API

The Azure portal makes calls to the Azure Management API similar to how the Azure CLI and Powershell does.

- Open a new PowerShell window, run the following commands. Be sure to set the subscritionId and resourceGroup variables:

```PowerShell
$token = $(Get-AzAccessToken -ResourceUrl "https://management.azure.com/").token

$subscriptionId = "YOUR_SUBSCRIPTION_ID"
$resourceGroup = "YOUR_RESOURCE_GROUP"
$resourceName = "dev-pg-eastus2-001"

$content = "{""properties"":{""Backup"":{""backupRetentionDays"":35}}"

$url = "/subscriptions/$subscriptionId/resourceGroups/$resourceGroup/providers/Microsoft.DBforPostgreSQL/flexibleServers/$resourceName?api-version=2023-06-01-preview"

$headers = @{   
 'Authorization' = "Bearer $token",
 'commandName' = "Microsoft_Azure_OSSDatabases.React/Views/Backups/BackupAndRestore/SaveCommand"
}

Invoke-WebRequest -Method GET -Uri $url -Headers $headers
```

## Adding a database in the portal

- Under **Settings**, select **Databases**
- Select **+Add**
- For the name, type **vector_cache**
- Select **Save**

## Configuring maintenance

- Under **Settings**
- Select **Maintenance**
- Select **Custom schedule**
- For the **Day of week**, select **Saturday**
- For the **Start time (UTC)**, select **23**
- Select **Save**

## Configuring a server parameter  

- Under **Settings**, select **Server paramters**
- For the **appliction_name**, type **vector_store**
- Select **Save**, notice an azure deployment is started
- Again, switch back to the **Server parameters**
- In the tabs, select **Static**, notice only static items are shown.
- Search for **max_connections**, then highlight the info icon. Notice the values range from 25 to 5000.
- Modify the value from **1718** to **2000**
- Select **Save**

## Connecting with PG Admin

- Download and Install [pgAdmin](https://www.pgadmin.org/download/)
- Once installed, open **pdAdmin**
- Right-click the **Servers** node
- For name, type **contoso-pg-eastus2-001**
- Select the **Connection** tab
- For the **host name/address**, paste the server name you copied from above
- For the username, type **s2admin**
- For the password, type **S0lliance123**
- Select **Save password?** to toggle it on.
- Select **Save**

## Writing your first query

- Expand the **contoso-pg-eastus2-001** node
- Expand the **Databases** node
- Expand the **vector_cache->Schemas->public** nodes
- Right-click the **Tables** node, select **Create**
- For the name, type **embeddings**
- Select **Save**
- Right-click the new table, select **Query Tool**
- Copy the following into the query tool window:

```sql
CREATE EXTENSION vector;

ALTER TABLE embeddings ADD COLUMN embedding vector(1536);
```

## Summary

In this lab, you created an instance, configured it and then added a table and vector column.  In the next set of labs, you will explore the new features of PostgreSQL 16.
