
# Create and manage read replicas in Azure Database for PostgreSQL - Flexible Server from the Azure portal

## In this article

- Prerequisites
- Review primary settings
- Create a read replica
- Add virtual endpoints (preview)
- Promote replicas
- Monitor a replica
- Delete a replica
- Delete a primary server
- Next steps

### APPLIES TO: Azure Database for PostgreSQL Flexible Server

In this article, you learn how to create and manage read replicas in Azure Database for PostgreSQL Flexible Server from the Azure portal. To learn more about read replicas, see the [overview](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).

## Pre-requisites

An [Azure Database for PostgreSQL server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/quickstart-create-server-portal) to be the primary server with no current read replicas.

> NOTE: When deploying read replicas for persistent heavy write-intensive primary workloads, the replication lag could continue to grow and may never be able to catch-up with the primary. This may also increase storage usage at the primary as the WAL files are not deleted until they are received at the replica.

## Review primary settings

Before adding a replica for failover purposes, review the target Azure Database for PostgreSQL Flexible Server configuration.  It is a best practice to ensure that your replica configuration values match or exceed your primary configuration.  In some, but not all cases, Azure will attempt to notify you or automatically set the necessary values to support promote activities.

### Server configuration

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server that you want to setup a replica for.
- On the **Overview** dialog, note the PostgreSQL version (ex `15.4`).  Also note the region your primary is deployed too (ex. `East US`).

  ![Primary instance version and location is highlighted.](../media/enable-promote/primary-settings.png)

- On the server sidebar, under **Settings**, select **Compute + storage**.
- Review and note the following settings:

    - Compute: Tier, Processor, Size (ex `Standard_D4ads_v5`).
    - Storage: Storage size (ex `128GB`)
    - High Availability
      - Enabled / Disabled
      - Availability zone settings
    - Backup settings
      - Retention period
      - Redundancy Options

  ![Primary instance version and location is highlighted.](../media/enable-promote/primary-compute.png)

> **NOTE** Read replicas are not supported for primary that has **Storage Auto-growth** enabled.  Uncheck this box if it is checked.
    
- Under **Settings**, select **Networking**
- Review the network settings
    - Public access
    - Firewall rules
      - Allow public access
      - Allowed client ip addresses

### Server parameters

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server that you want to create replica for.
- Under **Settings**, select **Server parameters**.

  ![Primary server parameters are highlighted.](../media/enable-promote/primary-parameters.png)

- Record any values that you may have modified to support your application.

## Create a read replica

To create a read replica, follow these steps:

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server to use as the primary server.
- On the server sidebar, under **Settings**, select **Replication**.
- Select **Create replica**.

  ![Add a replica.](../media/enable-promote/add-replica-new.png)

- Enter the Basics form with the following information.
  - Set the replica server name.
  
  > NOTE: It is a Cloud Adoption Framework (CAF) best practice to [use a resource naming convention](https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming) that will allow you to easily determine what instance you are connecting too or managing and where it resides.

  - Select a location that is different from your primary but note that you can select the same region.

  > NOTE:  To learn more about which regions you can create a replica in, visit the [read replica concepts article](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).

  - Set the compute and storage to what you recorded from your primary. If the displayed compute does not match, select **Configure server** and select the appropriate one.
  
  > NOTE:  If you select a compute size smaller than the primary, the deployment will fail. Also be aware that the compute size may not be available in a different region.

    ![Compute size of the replica is highlighted.](../media/enable-promote/replica-compute.png)

  - Select an availability zone setting.
  - Notice that the Authentication settings are auto selected for you.

  ![Review the availability zone and authentication settings.](../media/enable-promote/replica-zone-auth.png)

- Select **Review + create** to confirm the creation of the replica or **Next: Networking** if you want to add, delete or modify any firewall rules.
- Verify the firewall settings. Notice how the primary settings have been copied automatically.

  ![Modify firewall rules.](../media/enable-promote/networking.png)

- Leave the remaining defaults and then select the **Review + create** button at the bottom of the page or proceed to the next forms to configure security or add tags.
- Review the information in the final confirmation window. When you're ready, select **Create**. A new deployment will be created and executed.

  ![Review the information in the final confirmation window.](../media/enable-promote/replica-review.png)

- During the deployment, you will see the primary in `Updating` status:

  ![Primary enters into updating status.](../media/enable-promote/primary-updating.png)

- After the read replica is created, it can be viewed from the Replication window.

  ![View the new replica in the Replication window.](../media/enable-promote/list-replica.png)

### Server Parameters

- In the Azure portal, select the replica server.
- On the server sidebar, under **Settings**, select **Server parameters**.
- Set replica server parameters such that they match the primary server.

> Important: Review the [considerations section of the Read Replica overview](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas#considerations).

> To avoid issues during promotion of replicas always change the following server parameters on the replicas first, before applying them on the primary: max_connections, max_prepared_transactions, max_locks_per_transaction, max_wal_senders, max_worker_processes.

## Add Virtual Endpoints (preview)

- In the Azure portal, select the primary server.
- On the server sidebar, under **Settings**, select **Replication**.
- Select **Create endpoint**
- In the dialog, type a meaningful name for your endpoint.  Notice the DNS endpoint that is being generated.

  ![Add a new virtual endpoint with custom name.](../media/enable-promote/add-virtual-endpoint.png)

- Select **Create**

  > NOTE:  If you do not create a virtual endpoint you will receive an error on the promote replica attempt.

  ![Promotion error when missing virtual endpoint.](../media/enable-promote/replica-promote-attempt.png)

### Modify application(s) to point to virtual endpoint

Modify any applications that are using your Azure Database for PostgreSQL to use the new writer virtual endpoint (ex: `corp-pg-001-writer.postgres.database.azure.com`)

## Promote replicas

With all the necessary components in place, you are now ready to perform a promote replica to primary operation.  

> Important: Promotion of replicas cannot be undone. The read replica becomes a standalone server that supports both reads and writes. The standalone server can't be made into a replica again.

To promote replica from the Azure portal, follow these steps:

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server primary server.
- On the server sidebar, on the server menu, under **Settings**, select **Replication**
- Under **Servers**, select the **Promote** icon for the replica.

  ![Select promote for a replica.](../media/enable-promote/replica-promote.png)

- In the dialog, ensure the action is **Promote to primary server**.
- For **Data sync**, ensure **Planned - sync data before promoting** is selected.

  ![Promote the replica.](../media/enable-promote/replica-promote-final.png)

- Select **Promote**, the process will begin.  Once completed, the roles will be swapped with the replica now the primary and the primary the replica.

  > NOTE:  The replica you are promoting must have the reader virtual endpoint assigned or you will receive an error on promotion:

  ![Promote error when promtoing the wrong replica.](../media/enable-promote/promote-error.png)

### Test applications

Restart your applications, attempt to perform some operations.  The applications should work without any modifying of the virtual endpoint connection string or DNS entries.  This time leave your applications running.

### Failback to original

Repeat the same operations to promote the original server to the primary:

- In the [Azure portal](https://portal.azure.com/), select the replica.
- On the server sidebar, under **Settings**, select **Replication**
- Under **Servers**, select the **Promote** icon for the replica.
- In the dialog, ensure the action is **Promote to primary server**.
- For **Data sync**, ensure **Planned - sync data before promoting** is selected.
- Select **Promote**, the process will begin.  Once completed, the roles will be swapped with the replica now the primary and the primary the replica.

### Test applications

Again, switch to one of the consuming applications.  Wait for the primary and replica status to change to `updating` and then attempt to perform some operations.  During the replica promote, it is possible your application will encounter temporary connectivity issues to the writer endpoint:

  ![Potential failover connectivity errors.](../media/enable-promote/failover-connectivity-psql.png)

If no application is available to test directly, connectivity during a promotion can be tested against the writer endpoint using psql and the `\watch` switch with a simple psql `select 1` command:

```psql
select 1; \watch
```

## Add secondary read replica

Create a secondary read replica in a seperate region to modify the reader virtual endpoint and to allow for creating an independent server from the first replica.

- In the [Azure portal](https://portal.azure.com/), choose the primary Azure Database for PostgreSQL Flexible Server.
- On the server sidebar, under **Settings**, select **Replication**.
- Select **Create replica**.
- Enter the Basics form with information in a third region (ex `westus` and `corp-pg-westus-001`)
- Select **Review + create** to confirm the creation of the replica or **Next: Networking** if you want to add, delete or modify any firewall rules.
- Verify the firewall settings. Notice how the primary settings have been copied automatically.
- Leave the remaining defaults and then select the **Review + create** button at the bottom of the page or proceed to the next forms to configure security or add tags.
- Review the information in the final confirmation window. When you're ready, select **Create**. A new deployment will be created and executed.
- During the deployment, you will see the primary in `Updating` status:

## Modify virtual endpoint

- In the [Azure portal](https://portal.azure.com/), choose the primary Azure Database for PostgreSQL Flexible Server.
- On the server sidebar, under **Settings**, select **Replication**.
- Select the elipses and then select **Edit**

  ![Edit the virtual endpoint.](../media/enable-promote/edit-virtual-endpoint.png)

- In the dialog, select the new secondary replica

  ![Select the seconary replica.](../media/enable-promote/select-secondary-endpoint.png)

- Select **Save**.  The reader endpoint will now be pointed at the secondary replica and the promote operation will now be tied to this replica.

## Promote replica to independent server

Rather than failover to a replica, it is also possible to break the replication of a replica such that it becomes its own standalone server.

- In the [Azure portal](https://portal.azure.com/), choose the Azure Database for PostgreSQL Flexible Server primary server.
- On the server sidebar, on the server menu, under **Settings**, select **Replication**
- Under **Servers**, select the **Promote** icon for the replica you would like to promote to independent.

  ![Select promote for a replica.](../media/enable-promote/replica-promote.png)

- In the dialog, ensure the action is **Promote to independent server and remove from replication. This won't impact the primary server**.
  
  > NOTE: Once a replica is promoted to an independent server, it cannot be added back to the replication set.

- For **Data sync**, ensure **Planned - sync data before promoting** is selected.

  ![Promote the replica to independent server.](../media/enable-promote/replica-promote-independent.png)

- Select **Promote**, the process will begin.  Once completed, the server will no longer be a replica of the primary.

## Monitor a replica

As usage of your instance increased, so too will the amount of time to keep the replica(s) in-sync.  You can monitor the replication process with Azure Monitor metrics across the primary and the replicas.

### Max Physical Replication Lag

The Max Physical Replication Lag metric shows the lag in bytes between the primary server and the most-lagging replica and is available on the primary.

- In the Azure portal, select the primary server.
- Select **Metrics**. In the Metrics window, select **Max Physical Replication Lag**.

  ![Screenshot of the Metrics blade showing Read Replica Lag metric.](../media/enable-promote/primary-max-physical-replication-lag.png)

- For **Aggregation**, select **Max**.

### Read Replica Lag metric

The Read Replica Lag metric shows the time since the last replayed transaction on a replica. If there are no transactions occurring on your primary, the metric reflects this time lag. For instance if there are no transactions occurring on your primary server, and the last transaction was replayed 5 seconds ago, then the Read Replica Lag will show 5 second delay.  This metric is only available on a replica.

- In the Azure portal, select read replica.
- Select **Metrics**. In the Metrics window, select **Read Replica Lag**.

  ![Screenshot of the Metrics blade showing Read Replica Lag metric.](../media/enable-promote/replia-read-replica-lag.png)

- For **Aggregation**, select **Max**.

## Delete a replica

You can delete a read replica similar to how you delete a standalone Azure Database for PostgreSQL Flexible Server.

- In the Azure portal, open the **Overview** page for the read replica. Select **Delete**.

  ![On the replica Overview page, select to delete the replica.](../media/enable-promote/delete-replica.png)

- On the replica Overview page, select to delete the replica

You can also delete the read replica from the Replication window by following these steps:

- In the Azure portal, select your primary Azure Database for PostgreSQL server.
- On the server menu, under **Settings**, select **Replication**.
- Select the read replica to delete and then select the ellipses.  Select **Delete**.

  ![Select the replica to delete.](../media/enable-promote/delete-replica02.png)

- Select the replica to delete
- Acknowledge **Delete** operation.

  ![Confirm to delete te replica.](../media/enable-promote/delete-replica-confirm.png)

## Delete primary server

You can only delete primary server once all read replicas have been deleted. To delete a server from the Azure portal, follow these steps:

- In the Azure portal, select your primary Azure Database for PostgreSQL server.
- Open the **Overview** page for the server and select **Delete**.

  ![On the server Overview page, select to delete the primary server.](../media/enable-promote/delete-primary.png)

- Enter the name of the primary server to delete. Select **Delete** to confirm deletion of the primary server.

  ![Confirm to delete the primary server.](../media/enable-promote/delete-primary-confirm.png)

## Next Steps

- Learn more about [read replicas in Azure Database for PostgreSQL Flexible Server](https://learn.microsoft.com/en-us/azure/postgresql/flexible-server/concepts-read-replicas).
- Replication with Vnet Integration.
