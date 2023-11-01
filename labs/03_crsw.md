
# Tutorial: Enable Cross region Site Swap

## Enable Cross-Region Site Swap for existing Azure Database for PostgresSQL - Flexible Server

## Pre-requistes

To complete this how-to guide, you need a single instance of Azure Database for PostgreSQL - Flexible Server. The procedure is applicable for flexible servers in the same region and in different regions.

## Review primary settings

Before adding a replica for cross-site failover, review the Azure Database for PostgreSQL server configuration.  Althought not a necessary step, it is a best practice to ensure that your replica configuration matches your primary configuration.

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
- Under **Settings**, select **Server parameters**
- Record any values that you may have modified to support your application

## Add a replica

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to setup site swap.
- Under **Settings**, select **Replication**.
- Select **Add replica**.
- Set the server name.  It is a best practice to use a naming scheme that will allow you to easily .determine what instance you are connecting to or managing.
- Select a location that is different from your primary.
- Set the compute and storage to what you recorded from your primary.
- Select an availability zone setting.
- Notice that the Authentication settings are auto selected for you
- Select **Next: Networking**
- Verify the firewall settings
- Select **Next: Security**
- Select **Review + create**
- Select **Create**, a new deployment will be created and executed.

### Server Parameters

- In the Azure portal, select the replica server
- Under **Settings**, select **Server parameters**

## Add Virtual Endpoint

- 

### Add Writer Endpoint

- TBD

### Modify application to point to virtual endpoint

- TBD

## Perform site-swap

With all the necessary components in place, you are now ready to perform a site-swap.

### Stop applications

To ensure no data loss, you should stop any applications that use the database.  In the event control of the application(s) is not by owned by the Azure administrator, utilize failover procedures to notify these owners a cross-site operation is going to occur.  Although this should be a seamless operation, the applications may temporarily lose connectivity during the site-swap.

### Monitor connections

Before you perform the site-swap opeeration, utilize Azure Monitor to monitor the server metrics for connections.  Once you are sure all applications have stopped, you can promote your replica.

### Promote replica

- In the [Azure portal](https://portal.azure.com/), choose the flexible server that you want to promote.
- Under
