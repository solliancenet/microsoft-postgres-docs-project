
# Create and manage read replicas in Azure Database for PostgreSQL - Flexible Server with VNet intergation from the Azure portal

In this article, you learn how to create and manage read replicas in Azure Database for PostgreSQL with Vnet intefration from the Azure portal. To learn more about read replicas, see the [overview](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).

## Enable Promote Primary for existing Azure Database for PostgresSQL - Flexible Server

## Pre-requistes

An [Azure Database for PostgreSQL server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal) to be the primary server with no current read replicas.

> NOTE: When deploying read replicas for persistent heavy write-intensive primary workloads, the replication lag could continue to grow and may never be able to catch-up with the primary. This may also increase storage usage at the primary as the WAL files are not deleted until they are received at the replica.

## Review primary settings

Before adding a replica for cross-site failover, review the Azure Database for PostgreSQL Flexible Server configuration.  Althought not a necessary step, it is a best practice to ensure that your replica configuration values match or exceeds your primary configuration.

## Server configuration

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server that you want to setup site swap.
- On the **Overview** dialog, note the PostgreSQL version (ex `15.3`).  Also note the region your primary is deployed too (ex. `East US`).
- Under **Settings**, select **Compute + storage**.
- Review and note the following settings:

    - Compute: Tier, Processor, Size (ex `Standard_D4ads_v5`).
    - Storage: Storage size (ex `128GB`)
    - High Availability
      - Enabled / Disabled
      - Availability zone settings
    - Backup settings
      - Retention period
      - Redundancy Options

> **NOTE** Read replicas are not supported for primary that has **Storage Auto-growth** enabled.  Uncheck this box if it is checked.
    
- Under **Settings**, select **Networking**
- Reviewing the following settings:
    - Public access
    - Firewall rules
      - Allow public access
      - Allowed client ip addresses

## Server parameters

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server that you want to create replica for.
- Under **Settings**, select **Server parameters**.
- Record any values that you may have modified to support your application.

## Create a read replica

To create a read replica, follow these steps:

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server to use as the primary server.
- On the server sidebar, under **Settings**, select **Replication**.
- Select **Add replica**.

  ![Add a replica.](../media/enable-promote/add-replica.png)

- Enter the Basics form with the following information.
  - Set the server name.  It is a best practice to use a naming scheme that will allow you to easily determine what instance you are connecting to or managing.
  - Select a location that is different from your primary.
  - Set the compute and storage to what you recorded from your primary.
  
  > NOTE:  If you select a compute size smaller than the primary, the deployment will fail.

  - Select an availability zone setting.
  - Notice that the Authentication settings are auto selected for you.

  ![Enter the Basics information.](../media/enable-promote/add-replica.png)

  > NOTE:  To learn more about which regions you can create a replica in, visit the [read replica concepts article](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).

- Select **Review + create** to confirm the creation of the replica or **Next: Networking** if you want to add, delete or modify any firewall rules.
- Verify the firewall settings.

  ![Modify firewall rules.](../media/enable-promote/networking.png)

- Leave the remaining defaults and then select the **Review + create** button at the bottom of the page or proceed to the next forms to configure security or add tags.
- Review the information in the final confirmation window. When you're ready, select **Create**. A new deployment will be created and executed.

  ![Review the information in the final confirmation window.](../media/enable-promote/review.png)

- After the read replica is created, it can be viewed from the Replication window.

  ![View the new replica in the Replication window.](../media/enable-promote/list-replica.png)

### Server Parameters

- In the Azure portal, select the replica server.
- Under **Settings**, select **Server parameters**.
- Set and server parameters such that they matche your priamry server.

> Important: Review the [considerations section of the Read Replica overview](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas#considerations).
  
> To avoid issues during promotion of replicas always change the following server parameters on the replicas first, before applying them on the primary: max_connections, max_prepared_transactions, max_locks_per_transaction, max_wal_senders, max_worker_processes.

## Add Virtual Endpoint

- In the Azure portal, select the primary server.
- Under **Settings**, select **Replication**.
- Select **Create endpoint**
- In the dialog, type a meaningfull name for your endpoint.  Notice the DNS endpoint that is being generated.
- Select **Create**

### Modify application to point to virtual endpoint

Modify any applications that are using your Azure Database for PostgreSQL to use the new virtual endpoint.

## Promote replicas

With all the necessary components in place, you are now ready to perform a promote replica to primary operation.  

> Important: Promotion of replicas cannot be undone. The read replica becomes a standalone server that supports both reads and writes. The standalone server can't be made into a replica again.

To promote replica from the Azure portal, follow these steps:

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server primary server.
- On the server menu, under **Settings**, select **Replication**
- Under **Servers**, seelct the **Promote** icon for the replica.

  ![Select promote for a replica.](../media/enable-promote/select-replica.png)

- In the dialog, ensure the action is **Promote to primary server**.
- For **Data sync**, ensure **Planned - sync data before promoting** is selected.
- Select **Promote**, the site-swap will start.  Once completed, the roles will be swapped with the replica now the primary and the primary the replica.

### Test applications

Restart your applications, attempt to perform some operations.  The applications should work without any modifying of the virtual endpoint connection string or DNS entries.  This time leave your applications running.

### Failback to original

Repeat the same operations to promote the original server to the primary:

- In the [Azure portal](https://portal.azure.com/), select the replica.
- Under **Settings**, select **Replication**
- Under **Servers**, seelct the **Promote** icon for the replica.
- In the dialog, ensure the action is **Promote to primary server**.
- For **Data sync**, ensure **Planned - sync data before promoting** is selected.
- Select **Promote**, the site-swap will start.  Once completed, the roles will be swapped with the replica now the primary and the primary the replica.

### Test appications

Again, switch to one of the consuming applications.  Attempt to perform some operations.

## Next Steps

- Learn more about [read replicas in Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).
- Replication with Vnet Integration.
