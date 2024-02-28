# Hands-on Lab: Working with common PostgreSQL extensions

- [Hands-on Lab: Working with common PostgreSQL extensions](#hands-on-lab-working-with-common-postgresql-extensions)
  - [Exercise 1: Add extensions to allowlist](#exercise-1-add-extensions-to-allowlist)
  - [Exercise 2: Load data into the database from Azure storage using the Azure Storage extension](#exercise-2-load-data-into-the-database-from-azure-storage-using-the-azure-storage-extension)
    - [Task 1: Create an Azure Blob Storage account](#task-1-create-an-azure-blob-storage-account)
    - [Task 2: Create a container](#task-2-create-a-container)
    - [Task 3: Upload data files](#task-3-upload-data-files)
    - [Task 4: Connect to the database using psql in the Azure Cloud Shell](#task-4-connect-to-the-database-using-psql-in-the-azure-cloud-shell)
    - [Task 5: Enable and configure the pg\_azure\_storage extension](#task-5-enable-and-configure-the-pg_azure_storage-extension)
    - [Task 6: Import data from blob storage](#task-6-import-data-from-blob-storage)
    - [Task 7: Export data into blob storage using the blob\_put function](#task-7-export-data-into-blob-storage-using-the-blob_put-function)
  - [Exercise 3: Store geospatial data with the PostGIS extension](#exercise-3-store-geospatial-data-with-the-postgis-extension)
    - [Task 1: Connect to the database using pgAdmin](#task-1-connect-to-the-database-using-pgadmin)
    - [Task 2: Install the PostGIS extension](#task-2-install-the-postgis-extension)
    - [Task 3: Add a geospatial column to the listings table](#task-3-add-a-geospatial-column-to-the-listings-table)
    - [Task 4: View geospatial query results with the geometry data viewer](#task-4-view-geospatial-query-results-with-the-geometry-data-viewer)
  - [Exercise 4: Set up scheduled jobs](#exercise-4-set-up-scheduled-jobs)
    - [Task 1: Install pg\_cron extension](#task-1-install-pg_cron-extension)
    - [Task 2: Create a scheduled task using pg\_cron](#task-2-create-a-scheduled-task-using-pg_cron)
  - [Summary](#summary)

Azure Database for PostgreSQL Flexible Server provides the ability to extend a database's functionality using [many popular PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#extension-versions). Extensions allow you to add extra functionality to your database by adding and extending the capabilities of processes within the database. They work by bundling multiple related SQL objects in a single package that can be loaded or removed from your database with a single command. After being loaded into the database, extensions function like built-in features.

You can view the list of supported extensions by running `SHOW azure.extensions;` within the database. Note that extensions not listed are not currently supported on Azure Database for PostgreSQL flexible server. You cannot create or load your own extension in Azure Database for the PostgreSQL flexible server.

> Important
>
> This lab relies on the Azure Database for PostgreSQL Flexible Server database created in **Hands-on Lab 1: Provisioning, configuring, and getting started with development**.

In this lab, you work with the following common PostgreSQL extensions:

| Extension | Description |
| --------- | ----------- |
| [pg_azure_storage](https://learn.microsoft.com/azure/postgresql/flexible-server/reference-pg-azure-storage) | Allows for importing and exporting data in multiple file formats directly between Azure blob storage and an Azure Database for PostgreSQL Flexible Server database. |
| [postgis](https://www.postgis.net/) | Adds support for storing, indexing, and querying geospatial data (geometry, geography). |
| [pg_cron](https://github.com/citusdata/pg_cron) | A cron-based job scheduler that allows you to schedule PostgreSQL commands directly from the database. |

## Exercise 1: Add extensions to allowlist

Before you can install and use extensions in an Azure Database for PostgreSQL Flexible Server, you must _allowlist_ the desired extensions, as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).

1. In a web browser, navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. From the database's left-hand navigation menu, select **Server parameters** under **Settings**, then enter `azure.extensions` into the search box. Expand the **VALUE** dropdown list, then locate and check the box next to each of the following extensions:

    - AZURE_STORAGE
    - PG_CRON
    - POSTGIS

    ![On the Server parameters page of the Azure Database for PostgreSQL Flexible Server, azure.extensions is entered and highlighted in the search bar and the AZURE_STORAGE extension is selected and highlighted.](media/postgresql-server-parameters-extensions-azure-storage.png)

    If the extension you are attempting to allowlist is not present in the list, it may not be supported in the version of PostgreSQL you are using. You can review the [supported extension versions in the Microsoft docs](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#extension-versions). Alternatively, you can run the query, `SELECT * FROM pg_available_extensions;`, against your database.

3. To install some extensions, they must also be included in the server's shared preloaded libraries. Of the extensions you will use in this lab, `pg_azure_storage` and `pg_cron` need to be preloaded at server start. Clear the search box on the **Server parameters** page and enter `shared_preload`. Expand the **VALUE** dropdown list, then locate and check the box next to each of the following extensions:

    - AZURE_STORAGE
    - PG_CRON (This should already be checked, so verify that this is the case.)

    ![On the Server parameters page of the Azure Database for PostgreSQL Flexible Server, shared_preload is entered and highlighted in the search bar and the AZURE_STORAGE and PG_CRON extensions are selected and highlighted.](media/postgresql-server-parameters-shared-preloaded-libraries.png)

4. Select **Save** on the toolbar, then select **Save and Restart** in the dialog that appears.

    ![The Save and Restart button is highlighted on the Save server parameter dialog.](media/save-server-parameter-dialog.png)

## Exercise 2: Load data into the database from Azure storage using the Azure Storage extension

The [pg_azure_storage extension](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-storage-extension) enables seamless integration of Azure blob storage with PostgreSQL databases. The extension allows you to import and export data in multiple file formats directly from Azure blob storage and your database. To use the `pg_azure_storage` extension for this lab, you must first provision an Azure Storage account, retrieve its access key, create a container, and copy the sample Seattle Airbnb data files into the container.

### Task 1: Create an Azure Blob Storage account

In this task, you provision an Azure Storage account in the Azure portal to host the sample data files.

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com/).

2. On the portal home page, select **Create a resource** under Azure services.

    ![Create a resource is highlighted under Azure services on the portal home page.](media/create-a-resource.png)

3. On the **Create a resource** page, select **Storage** in the left-hand menu then **Storage account**. You can also use the **Search** functionality to find the resource.

    ![On the Azure portal's create a resource screen, Storage is highlighted in the left-hand menu and Storage account is highlighted under Popular Azure services.](media/create-a-resource-storage-account.png)

4. On the Create a storage account **Basics** tab, enter the following information:

    | Parameter            | Value |
    | -------------------- | ----- |
    | **Project details**  |       |
    | Subscription         | Select the subscription you use for lab resources. |
    | Resource group       | Select the resource group you created in Lab 1. |
    | **Instance details** |       |
    | Storage account name | _Enter a globally unique name_, such as `stpostgreslabs`. |
    | Region               | Select the same region you chose for your Azure Database for PostgreSQL Flexible Server database. |
    | Performance          | Select **Standard**. |
    | Redundancy           | Select **Locally-redundant storage (LRS)**. |

    ![The Basics tab of the Create a storage account dialog is displayed, and the fields are populated with the values specified in the exercise.](media/create-a-storage-account-basics-tab.png)

5. The default settings will be used for the remaining tabs of the storage account configuration, so select the **Review** button.

6. Select the **Create** button on the **Review** tab to provision the storage account.

### Task 2: Create a container

You have been provided with sample Seattle Airbnb data files in CSV format. To host these files, you will create a container named `seattle-airbnb-data` in the new storage account.

1. Navigate to your new storage account in the [Azure portal](https://portal.azure.com/).

2. In the left-hand navigation menu, select **Containers** under **Data storage**, and then select **+ Container** on the toolbar.

    ![On the Storage account page, Containers is selected and highlighted under Data storage in the left-hand navigation menu, and + Container is highlighted on the Containers page.](media/storage-account-add-container.png)

3. In the **New container** dialog, enter `seattle-airbnb-data` in the **Name** field and leave **Private (no anonymous access)** selected for the **Public access level** setting, then select **Create**.

    ![The New container dialog is displayed, with the name set to seattle-airbnb-data and the public access level set to private (no anonymous access).](media/storage-account-new-container.png)

    Setting the container's access level to **Private (no anonymous access)**prevents public access to the container and its contents. Below, you will provide the `pg_azure_storage` extension with the account name and access key, allowing it to access the files securely.

### Task 3: Upload data files

In this task, you upload the sample Seattle Airbnb data files into the container you created using the [Azure CLI](https://learn.microsoft.com/cli/azure/).

1. You need the name and key associated with your storage account to upload files using the Azure CLI. In the left-hand navigation menu, select **Access keys** under **Security + networking**.

    ![Access keys is selected and highlighted in the left-hand menu of the Storage account page.](media/storage-account-access-keys.png)

2. With the **Access keys** page open, select the **Cloud Shell** icon in the Azure portal toolbar to open a new [Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview) pane at the bottom of your browser window.

    ![The Cloud Shell icon is highlighted in the Azure portal toolbar and a Cloud Shell window is open at the bottom of the browser window.](media/portal-cloud-shell.png)

3. At the Azure Cloud Shell prompt, execute the following `curl` commands to download the Seattle Airbnb data files.

    ```bash
    curl -O https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/listings.csv
    ```

    ```bash
    curl -O https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/calendar.csv
    ```

    ```bash
    curl -O https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/reviews.csv
    ```

    The above commands download the files into the storage account associated with your Cloud Shell.

4. Next, you will use the [Azure CLI](https://learn.microsoft.com/cli/azure/) to upload the files into the `seattle-airbnb-data` container you created in your storage account. Create variables to hold your storage account name and key values to make things easier.

    Copy your storage account name by selecting the **Copy to clipboard** button next to the storage account name on the Access keys page above your Cloud Shell:

    ![The Copy to clipboard button is highlighted next to the Storage account name value, and the ACCOUNT_NAME variable declaration line is highlighted in the Cloud Shell.](media/storage-account-name.png)

    Now, execute the following command at the Cloud Shell prompt to create a variable for your storage account name, replacing the `{your_storage_account_name}` token with your storage account name.

    ```bash
    ACCOUNT_NAME={your_storage_account_name}
    ```

    Next, select the **Show** button next to the **Key** for **key1** and then select the **Copy to clipboard** button next to the key's value.

    ![The Copy to clipboard button is highlighted next to the key1 Key value, and the ACCOUNT_KEY variable declaration line is highlighted in the Cloud Shell.](media/storage-account-key.png)

    Then, run the following, replacing the `{your_storage_account_key}` token with the key value you copied.

    ```bash
    ACCOUNT_KEY={your_storage_account_key}
    ```

5. You are now ready to upload the data files. To accomplish this, you will use the [`az storage blob upload`](https://learn.microsoft.com/cli/azure/storage/blob?view=azure-cli-latest#az-storage-blob-upload) CLI command from the Cloud Shell prompt. Run the following commands to upload the three data files into your storage account's `seattle-airbnb-data` container.

    ```bash
    az storage blob upload --account-name $ACCOUNT_NAME --account-key $ACCOUNT_KEY --container-name seattle-airbnb-data --file listings.csv --name listings.csv --overwrite
    ```

    ```bash
    az storage blob upload --account-name $ACCOUNT_NAME --account-key $ACCOUNT_KEY --container-name seattle-airbnb-data --file calendar.csv --name calendar.csv --overwrite
    ```

    ```bash
    az storage blob upload --account-name $ACCOUNT_NAME --account-key $ACCOUNT_KEY --container-name seattle-airbnb-data --file reviews.csv --name reviews.csv --overwrite
    ```

    In this exercise, you are working with a small number of files. You will most likely work with many more files in real-world scenarios. In those circumstances, you can review different methods for [migrating files to an Azure Storage account](https://learn.microsoft.com/azure/storage/common/storage-use-azcopy-migrate-on-premises-data) and select the technique that will work best for your situation.

6. To verify the files uploaded successfully, you can navigate to your storage account's **Containers** page by selecting **Containers** from the left-hand navigation menu. Select the `seattle-airbnb-data` container from the list of containers and observe that it now contains three files, named `calendar.csv`, `listings.csv`, and `reviews.csv.`

    ![The three CSV files are highlighted in the list of blobs in the seattle-airbnb-data container.](media/storage-account-container-blobs.png)

### Task 4: Connect to the database using psql in the Azure Cloud Shell

With the files now securely stored in blob storage, it's time to set up the `pg_azure_storage` extension in your database. To accomplish this, you will use the `psql` command line utility from the [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview).

1. Using the same browser tab where the Cloud Shell is open, navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. Select **Connect** under **Settings** from the database's left-hand navigation menu, then select **airbnb** for the **Database name** and copy the **Connection details** block.

    ![The Connection strings page of the Azure Cosmos DB Cluster resource is highlighted. On the Connection strings page, the copy to clipboard button to the right of the psql connection string is highlighted.](media/postgresql-connection-details-psql.png)

3. Paste the connection details into the Cloud Shell, and replace the `{your_password}` token with the password you assigned to the `s2admin` user when creating your database. If you followed the instructions in Lab 1, the password should be `Seattle123Seattle123`.

4. Connect to your database using the [psql command-line utility](https://www.postgresguide.com/utilities/psql/) by entering the following at the prompt.

    ```bash
    psql
    ```

    Connecting to the database from the Cloud Shell requires that the `Allow public access from any Azure service within Azure to the server` box is checked on the **Networking** page of the database. If you receive a message that you cannot connect, please verify this is checked and try again.

### Task 5: Enable and configure the pg_azure_storage extension

Now that you are connected to your database, you can install the `pg_azure_storage` extension. You install extensions using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

1. From the `psql` prompt in the Cloud Shell, run the following command to install the extension in your database:

    ```sql
    CREATE EXTENSION azure_storage;
    ```

    When creating and working with the `pg_azure_storage` extension in your database, note that the extension's name is abbreviated to `azure_storage`.

2. With the extension now installed, you can configure the extension to connect to your storage account. You will need the name and key associated with your storage account. Using the same browser tab where the Cloud Shell is open, navigate to your storage account resource in the [Azure portal](https://portal.azure.com/). In the left-hand navigation menu, select **Access keys** under **Security + networking**.

    ![Access keys is selected and highlighted in the left-hand menu of the Storage account page.](media/storage-account-access-keys-psql.png)

3. Before importing data from blob storage, you need to map to the storage account using the `account_add` method, providing the account access key defined when the account was created. At the `psql` prompt, execute the following command after replacing the `{your_storage_account_name}` and `{your_storage_account_key}` tokens with the **Storage account name** and **Key** values, respectively.

    ```sql
    SELECT azure_storage.account_add('{your_storage_account_name}', '{your_storage_account_key}');
    ```

4. Once your storage account has been mapped, you can list the storage account contents. After replacing the `{your_storage_account_name}` token with the **Storage account name**, run the following command to view the list of files in the `seattle-airbnb-data` container:

    ```sql
    SELECT path, bytes, pg_size_pretty(bytes), content_type
    FROM azure_storage.blob_list('{your_storage_account_name}', 'seattle-airbnb-data');
    ```

    The `blob_list` function output should be similar to the following:

    ![The output from the azure_storage.blob_list function is displayed in the Azure Cloud Shell.](media/azure-storage-extension-blob-list-output.png)

### Task 6: Import data from blob storage

With the `pg_azure_storage` extension now connected to your blob storage account, you can import the data it contains into your database. Using the queries below, you will create a new schema in the database, add tables to the new schema, and then import data from the files in blob storage into the new tables using the `pg_azure_storage` extension.

1. To host the new tables, you will create a new schema named `abb` in the database. To create a new schema, use the following command:

    ```sql
    CREATE SCHEMA IF NOT EXISTS abb;
    ```

2. Before importing data, you must create tables to store data from the CSV files. Run the commands below to create the three required tables in the `abb` schema. The table structures are based on the columns defined in each file.

    ```sql
    CREATE TABLE abb.calendar
    (
        listing_id bigint,
        date date,
        available boolean,
        price text
    );
    ```

    ```sql
    CREATE TABLE abb.listings
    (
        id bigint PRIMARY KEY,
        listing_url text,
        scrape_id bigint,
        last_scraped date,
        name text,
        summary text,
        space text,
        description text,
        experiences_offered text,
        neighborhood_overview text,
        notes text,
        transit text,
        thumbnail_url text,
        medium_url text,
        picture_url text,
        xl_picture_url text,
        host_id bigint,
        host_url text,
        host_name text,
        host_since date,
        host_location text,
        host_about text,
        host_response_time text,
        host_response_rate text,
        host_acceptance_rate text,
        host_is_superhost boolean,
        host_thumbnail_url text,
        host_picture_url text,
        host_neighbourhood text,
        host_listings_count int,
        host_total_listings_count int,
        host_verifications text,
        host_has_profile_pic boolean,
        host_identity_verified boolean,
        street text,
        neighbourhood text,
        neighbourhood_cleansed text,
        neighbourhood_group_cleansed text,
        city text,
        state text,
        zipcode text,
        market text,
        smart_location text,
        country_code text,
        country text,
        latitude float,
        longitude float,
        is_location_exact boolean,
        property_type text,
        room_type text,
        accommodates int,
        bathrooms real,
        bedrooms int,
        beds int,
        bed_type text,
        amenities text,
        square_feet int,
        price text,
        weekly_price text,
        monthly_price text,
        security_deposit text,
        cleaning_fee text,
        guests_included int,
        extra_people text,
        minimum_nights int,
        maximum_nights int,
        calendar_updated text,
        has_availability boolean,
        availability_30 int,
        availability_60 int,
        availability_90 int,
        availability_365 int,
        calendar_last_scraped date,
        number_of_reviews int,
        first_review date,
        last_review date,
        review_scores_rating int,
        review_scores_accuracy int,
        review_scores_cleanliness int,
        review_scores_checkin int,
        review_scores_communication int,
        review_scores_location int,
        review_scores_value int,
        requires_license boolean,
        license text,
        jurisdiction_names text,
        instant_bookable boolean,
        cancellation_policy text,
        require_guest_profile_picture boolean,
        require_guest_phone_verification boolean,
        calculated_host_listings_count int,
        reviews_per_month numeric
    );
    ```

    ```sql
    CREATE TABLE abb.reviews
    (
        listing_id bigint,
        id bigint PRIMARY KEY,
        date date,
        reviewer_id bigint,
        reviewer_name text,
        comments text
    );
    ```

3. You can now import data using the `pg_azure_storage` extension. Starting with the `calendar.csv` file, use the [blob_get function](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-storage-extension#import-data-using-blob_get-function) with the [azure_storage.options_csv_get](https://learn.microsoft.com/azure/cosmos-db/postgresql/reference-pg-azure-storage#azure_storageoptions_csv_get) utility function to specify the decoding options for the CSV file. The `blob_get` function retrieves a file from blob storage. For `blob_get` to know how to parse the data, you can explicitly define the columns in the `FROM` clause. Run the following command to import data from the file. Be sure to replace the `{your_storage_account_name}` token with your storage account name.

    ```sql
    INSERT INTO abb.calendar
    SELECT * FROM azure_storage.blob_get('{your_storage_account_name}', 'seattle-airbnb-data', 'calendar.csv', options:= azure_storage.options_csv_get(header=>true)) AS cal_rec (
        listing_id bigint,
        date date,
        available boolean,
        price text
    );
    ```

    Note the `price` column is assigned a `text` data type in the table. This data type assignment occurs because the CSV file contains dollar signs (`$`) and commas (`,`) in some values. You will correct this below to allow numeric operations to occur on the field.

4. With the data imported, you can now fix the data type associated with the `price` column so numeric operations can be conducted on the column.

    ```sql
    ALTER TABLE abb.calendar ALTER column price TYPE numeric USING (REPLACE(REPLACE(price, ',', ''), '$', '')::numeric);
    ```

5. Above, you explicitly defined the columns in the `calendar.csv` file in the `FROM` clause in the `blob_get` function. Alternatively, you can pass a value (`NULL::table_name`), which infers the file's columns based on the definition of the target table. This method is beneficial when the target table has many columns, as with the `listings` table. Note that this requires the file and table to have the same structure. Run the following command to import the `listings` data from the file. Replace the `{your_storage_account_name}` token with your storage account name.

    ```sql
    INSERT INTO abb.listings
    SELECT * FROM azure_storage.blob_get('{your_storage_account_name}','seattle-airbnb-data','listings.csv', NULL::abb.listings,options:= azure_storage.options_csv_get(header=>true));
    ```

6. To load data into the `reviews` table, you will employ the alternative approach for importing data in the `pg_azure_storage` extension and use the [COPY statement](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-storage-extension#import-data-using-copy-statement). Run the following command to import `reviews` data from blob storage. Be sure to replace the `{your_storage_account_name}` token with your storage account name.

    ```sql
    COPY abb.reviews
    FROM 'https://{your_storage_account_name}.blob.core.windows.net/seattle-airbnb-data/reviews.csv'
    WITH (FORMAT 'csv', header);
    ```

    Using the `COPY` command in conjunction with the `pg_azure_storage` extension allows it to be used against a private, secured blob storage account container by extending the native PostgreSQL `COPY` command to make it capable of handling Azure Blob Storage resource URLs. The `COPY` statement does not allow you to specify columns, so verifying the table and file column definitions match precisely is essential.

7. Run a few queries to verify the data loaded into each table.

    ```sql
    SELECT * FROM abb.calendar WHERE price BETWEEN 100 AND 125 LIMIT 10;
    ```

    ```sql
    SELECT COUNT(id) FROM abb.listings WHERE neighbourhood_group_cleansed = 'Ballard';
    ```

    By running the `\x auto` command below before executing the last query, you enable the extended display to be automatically applied when necessary to make the output from the command easier to view in the Azure Cloud Shell.

    ```sql
    \x auto
    ```

    ```sql
    SELECT listing_id, date, reviewer_name, comments FROM abb.reviews WHERE listing_id = 7202016 LIMIT 3;
    ```

### Task 7: Export data into blob storage using the blob_put function

The `pg_azure_storage` extension also allows data to be exported from an Azure Database for PostgreSQL to Azure blob storage. In this task, you will export the cleansed `calendar` data back to blob storage using the [blob_put function](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-storage-extension#export-data-from-azure-database-for-postgresql-flexible-server-to-azure-blob-storage).

1. Above, you fixed the data type associated with the `price` column in the `calendar` table by cleaning up unwanted characters from the `text` column and assigning a `numeric` data type to the column. You can use the following command to push the updated data back into blob storage. Make sure to replace the `{your_storage_account_name}` token with the name of your storage account before executing the query.

    ```sql
    SELECT azure_storage.blob_put('{your_storage_account_name}', 'seattle-airbnb-data', 'calendar.csv', cal_rec)
    FROM (SELECT listing_id, date, available, price FROM abb.calendar) cal_rec;
    ```

2. After the query completes, navigate to your storage account in the [Azure portal](https://portal.azure.com/), select **Containers** under **Data storage** in the left-hand menu, choose the **seattle-airbnb-data** container, and then download the `calendar.csv` file.

3. Open the file and observe that data in the `price` column not longer contains dollar signs (`$`) or commas (`,`) and that the rows with values contain a numeric value.

## Exercise 3: Store geospatial data with the PostGIS extension

[PostGIS](https://www.postgis.net/) is a 3rd party open-source spatial database extender for PostgreSQL object-relational databases, which adds support for geographic objects that allow location queries to be run in SQL. This extension enables complex geospatial queries and analysis within PostgreSQL, essential for mapping, location tracking, and spatial analysis. It provides a variety of spatial data types, indexing options, and functions to query and manipulate geospatial data efficiently.

You will use [pgAdmin](https://www.pgadmin.org/docs/pgadmin4/latest/index.html) to connect to and execute queries against your database for this exercise. The pgAdmin tool offers a [Geometry Data Viewer](https://www.pgadmin.org/docs/pgadmin4/8.0/editgrid.html#the-data-grid), which allows you to view GIS objects on a map.

### Task 1: Connect to the database using pgAdmin

In Lab 1, you downloaded and installed [pgAdmin](https://www.pgadmin.org/download/) and registered a connection to your database server. In this task, you will open pgAdmin and connect to your database.

> Note: you configured pgAdmin to connect to your server in Lab 1. If necessary, refer back to those steps to register your database server and establish a connection to your database.

1. Open **pgAdmin** on your local or lab virtual machine.

2. Expand the **Servers** node within the Object Explorer, select your database server from the list, then right-click the server and select **Connect Server** from the context menu.

    ![The Azure Database for PostgreSQL Flexible Server instance is selected and highlighted in the Object Explorer in pgAdmin. In the server's context menu, Connect Server is highlighted.](media/pg-admin-server-connect.png)
  
3. Once connected to your server, expand the **Databases** node and select the **airbnb** database. Right-click the **airbnb** database and select **Query Tool** from the context menu.

    ![Under the server databases, the airbnb database is selected and Query Tool is highlighted in the context menu.](media/pg-admin-airbnb-database-query-tool.png)

### Task 2: Install the PostGIS extension

To install the `postgis` extension in your database, you will use the [CREATE EXTENSION](https://www.postgresql.org/docs/current/static/sql-createextension.html) command, as you did with the `pg_azure_storage` extension. Behind the scenes, executing `CREATE EXTENSION` runs the extension's script file. The script typically creates new SQL objects such as functions, data types, operators, and index support methods. Additionally, `CREATE EXTENSION` records the identities of all the created objects so they can be dropped again if `DROP EXTENSION` is issued.

1. In the query window you opened above, run the `CREATE EXTENSION` command to install the `postgis` extension in your database.

    ```sql
    CREATE EXTENSION IF NOT EXISTS postgis;
    ```

    If you attempt to install an extension with the same name as one already loaded in the database, you will receive an error that the extension already exists. Specifying the `IF NOT EXISTS` clause when running the `CREATE EXTENSION` command allows you to avoid this error.

### Task 3: Add a geospatial column to the listings table

With the `PostGIS` extension now loaded, you are ready to begin working with geospatial data in the database. The `listings` table you created and populated above contains the latitude and longitude of all listed properties. To use these data for geospatial analysis, you must alter the `listings` table to add a `geometry` column that accepts the `point` data type. These new data types are included in the `postgis` extension.

1. To accommodate `point` data, add a new `geometry` column to the table that accepts `point` data. Copy and paste the following query into the open pgAdmin query window:

    ```sql
    ALTER TABLE abb.listings
    ADD COLUMN listing_location geometry(point, 4326);
    ```

2. Next, update the table with geospatial data associated with each listing by adding the longitude and latitude values into the `geometry` column.

    ```sql
    UPDATE abb.listings
    SET listing_location = ST_SetSRID(ST_Point(longitude, latitude), 4326);
    ```

### Task 4: View geospatial query results with the geometry data viewer

With `PostGIS` installed in your database, you can take advantage of the [Geometry Data Viewer](https://www.pgadmin.org/docs/pgadmin4/8.0/editgrid.html#the-data-grid) in pgAdmin to view GIS objects in a map.

1. Copy and paste the following query into the open query editor, then run it to view the data stored in the `listing_location` column:

    ```sql
    SELECT name, listing_location FROM abb.listings LIMIT 50;
    ```

2. In the **Data Output** panel, select the **View all geometries in this column** button displayed in the `listing_location` column of the query results.

    ![In the query Data Output panel, the View all geometries in this column button is highlighted.](media/pg-admin-data-output-view-geometries-on-map.png)

    The **View all geometries in this column** button opens the **Geometry Viewer**, allowing you to view the query results on a map.

3. Select one of the points displayed on the map to view details about the location. In this case, the query only provided the name of the property.

    ![The Geometry Viewer tab is highlighted and a property point is highlighted on the map.](media/pg-admin-geometry-viewer-property-name.png)

4. Now, run the following query to perform a geospatial proximity query, returning properties that are available for the week of January 13, 2016, are under $75.00 per night, and are within a short distance of Discovery Park in Seattle. The query uses the [ST_DWithin](https://postgis.net/docs/ST_DWithin.html) function provided by the `PostGIS` extension to identify listings within a given distance from the park, which has a longitude of `-122.410347` and a latitude of `47.655598`.

    ```sql
    SELECT name, listing_location, summary
    FROM abb.listings l
    INNER JOIN abb.calendar c ON l.id = c.listing_id
    WHERE ST_DWithin(
        listing_location,
        ST_GeomFromText('POINT(-122.410347 47.655598)', 4326),
        0.025
    )
    AND c.date = '2016-01-13'
    AND c.available = true
    and c.price <= 75.00;
    ```

5. Select the **View all geometries in this column** button displayed in the `listing_location` column of the query results to open the **Geometry Viewer** and examine the results.

    ![The Geometry Viewer map shows several properties close to Discovery Park. One property has been selected, and its name and summary are displayed in a pop-up dialog.](media/pg-admin-proximity-query-geometry-viewer-results.png)

## Exercise 4: Set up scheduled jobs

The following extension you will work with is [pg_cron](https://github.com/citusdata/pg_cron), a simple, cron-based job scheduler for PostgreSQL that runs inside the database as an extension. This powerful and simple extension can be used for many tasks, including aggregating data in near-real time, database cleanup and administrative tasks, and much more.

Extending your database with the [pg_cron](https://github.com/citusdata/pg_cron) extension allows you to schedule PostgreSQL commands directly from the database using a cron-based job scheduler. Using this extension, you can schedule a job that calls a function to execute on a schedule, such as every month, hour, or minute. In this exercise, you will create a scheduled task that runs the `VACUUM` operation against the `airbnb` database.

### Task 1: Install pg_cron extension

The `pg_cron` extension works slightly differently than the extensions you worked with above. It can only be installed in the `postgres` database, which requires access to the background worker process to schedule jobs. To install the `pg_cron` extension, you will open a new **pgAdmin** query window from the `postgres` database.

1. In your open **pgAdmin** session, locate the `postgres` databases under the **Databases** node in the Object Explore, then right-click the database and select **Query Tool** from the context menu.

    ![Under the server databases, the postgres database is selected and Query Tool is highlighted in the context menu.](media/pg-admin-postgres-database-query-tool.png)

2. In the new query panel, run the `CREATE EXTENSION` command to install the `pg_cron` extension in the `postgres` database.

    ```sql
    CREATE EXTENSION IF NOT EXISTS pg_cron;
    ```

### Task 2: Create a scheduled task using pg_cron

In this task, you will use `pg_cron` to create a scheduled job for performing garbage collection in the `airbnb` database using the [VACUUM](https://www.postgresql.org/docs/current/sql-vacuum.html) operation.

1. Copy and paste the following query into the query window for the `postgres` database, then run it to schedule a `VACUUM` operation in the `airbnb` database every five minutes.

    ```sql
    SELECT cron.schedule_in_database('VACUUM','*/5 * * * * ','VACUUM','airbnb');
    ```

2. Next, run the following query to view the job list, including the one you just added.

    ```sql
    SELECT * FROM cron.job;
    ```

    ![The output from the SELECT * FROM cron.job query is displayed.](media/pg-admin-pg-cron-job-list.png)

    If you need to stop a job, you must retrieve the `jobid` for your job using this query.

3. To unschedule the job, use the following, replacing the `{job_id}` token with the `jobid` you retrieved from the previous query.

    ```sql
    SELECT cron.unschedule({job_id});
    ```

## Summary

Congratulations! You have completed the **Working with common PostgreSQL extensions** hands-on lab. In this lab, you explored the powerful extensibility of Azure Database for PostgreSQL Flexible Server by installing and using some common PostgreSQL extensions.

In the next lab, you will continue exploring these capabilities, looking at how you can extend the database to add the power of generative AI and Large Language Models.
