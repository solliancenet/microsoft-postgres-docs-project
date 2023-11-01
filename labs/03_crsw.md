
# Tutorial: Enable Cross region Site Swap

## Enable Cross-Region Site Swap for existing Azure Database for PostgresSQL - Flexible Server

## Pre-requistes

To complete this how-to guide, you need a single instance of Azure Database for PostgreSQL - Flexible Server with no replicas.

## Review primary settings

Before adding a replica for cross-site failover, review the Azure Database for PostgreSQL server configuration.  Althought not a necessary step, it is a best practice to ensure that your replica configuration values match or exceeds your primary configuration.

## Server configuration

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to setup site swap.
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

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to setup site swap.
- Under **Settings**, select **Server parameters**.
- Record any values that you may have modified to support your application.

## Add a replica

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to setup site swap.
- Under **Settings**, select **Replication**.
- Select **Add replica**.
- Set the server name.  It is a best practice to use a naming scheme that will allow you to easily .determine what instance you are connecting to or managing.
- Select a location that is different from your primary.
- Set the compute and storage to what you recorded from your primary.
- Select an availability zone setting.
- Notice that the Authentication settings are auto selected for you.
- Select **Next: Networking**.
- Verify the firewall settings.
- Select **Next: Security**.
- Select **Review + create**.
- Select **Create**, a new deployment will be created and executed.

### Server Parameters

- In the Azure portal, select the replica server.
- Under **Settings**, select **Server parameters**.
- Set and server parameters such that they matche your priamry server.

## Add Virtual Endpoint

- In the Azure portal, select the replica server.
- Under **Settings**, select **Replication**.
- Select **Create endpoint**
- In the dialog, type a meaningfull name for your endpoint.  Notice the DNS endpoint that is being generated.
- Select **Create**

### Modify application to point to virtual endpoint

Modify any applications that are using your Azure Database for PostgreSQL to use the new virtual endpoint.

## Perform site-swap

With all the necessary components in place, you are now ready to perform a site-swap.

### Stop applications

To ensure no data loss, you should stop any applications that use the database.  If control of the application(s) is not by owned by the Azure administrator, utilize failover procedures to notify these owners a cross-site operation is going to occur.  Although this should be a seamless operation, the applications may temporarily lose connectivity during the site-swap.

### Monitor connections

Before you perform the site-swap opeeration, utilize Azure Monitor to monitor the server metrics for connections.  Once you are certain all applications have stopped, you can proceed to promote your replica to the primary role.

### Promote replica

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to promote.
- Under **Settings**, select **Replication**
- Under **Servers**, seelct the **Promote** icon for the replica.
- In the dialog, ensure the action is **Promote to primary server**.
- For **Data sync**, ensure **Planned - sync data before promoting** is selected.
- Select **Promote**, the site-swap will start.  Once completed, the roles will be swapped with the replica now the primary and the primary the replica.

### Test applications

Restart your applications, attempt to perform some operations.  The applications should work without any modifying of the connection string or DNS entries.  This time leave your applications running.

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

- Cross region Site Swap with private endpoints