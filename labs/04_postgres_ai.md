# Hands-on Lab: Generative AI with Azure Database for PostgreSQL Flexible Server

- [Hands-on Lab: Generative AI with Azure Database for PostgreSQL Flexible Server](#hands-on-lab-generative-ai-with-azure-database-for-postgresql-flexible-server)
  - [Prerequisites](#prerequisites)
    - [Task 1: Provision an Azure Database for PostgreSQL Flexible Server](#task-1-provision-an-azure-database-for-postgresql-flexible-server)
    - [Task 2: Connect to the database using psql in the Azure Cloud Shell](#task-2-connect-to-the-database-using-psql-in-the-azure-cloud-shell)
    - [Task 3: Add data to the database](#task-3-add-data-to-the-database)
  - [Exercise 1: Add Azure AI and Vector extensions to allowlist](#exercise-1-add-azure-ai-and-vector-extensions-to-allowlist)
  - [Exercise 2: Create an Azure OpenAI resource](#exercise-2-create-an-azure-openai-resource)
    - [Task 1: Provision an Azure OpenAI service](#task-1-provision-an-azure-openai-service)
    - [Task 2: Deploy an embedding model](#task-2-deploy-an-embedding-model)
  - [Exercise 3: Install and configure the `azure_ai` extension](#exercise-3-install-and-configure-the-azure_ai-extension)
    - [Task 1: Connect to the database using psql in the Azure Cloud Shell](#task-1-connect-to-the-database-using-psql-in-the-azure-cloud-shell)
    - [Task 2: Install the `azure_ai` extension](#task-2-install-the-azure_ai-extension)
    - [Task 3: Review the objects contained within the `azure_ai` extension](#task-3-review-the-objects-contained-within-the-azure_ai-extension)
    - [Task 4: Set the Azure OpenAI endpoint and key](#task-4-set-the-azure-openai-endpoint-and-key)
  - [Exercise 4: Generate vector embeddings with Azure OpenAI](#exercise-4-generate-vector-embeddings-with-azure-openai)
    - [Task 1: Enable vector support with the pgvector extension](#task-1-enable-vector-support-with-the-pgvector-extension)
    - [Task 2: Generate and store vector embeddings](#task-2-generate-and-store-vector-embeddings)
    - [Task 3: Perform a vector similarity search](#task-3-perform-a-vector-similarity-search)
  - [Exercise 5: Integrate Azure AI Services](#exercise-5-integrate-azure-ai-services)
    - [Task 1: Provision an Azure AI Language service](#task-1-provision-an-azure-ai-language-service)
    - [Task 2: Set the Azure AI Language service endpoint and key](#task-2-set-the-azure-ai-language-service-endpoint-and-key)
    - [Task 3: Analyze the sentiment of reviews](#task-3-analyze-the-sentiment-of-reviews)
  - [Exercise 6: Execute a final query to tie it all together (Optional)](#exercise-6-execute-a-final-query-to-tie-it-all-together-optional)
    - [Task 1: Connect to the database using pgAdmin](#task-1-connect-to-the-database-using-pgadmin)
    - [Task 2: Verify that the PostGIS extension is installed in your database](#task-2-verify-that-the-postgis-extension-is-installed-in-your-database)
    - [Task 3: Execute a query and view results on a map](#task-3-execute-a-query-and-view-results-on-a-map)
  - [Exercise 7: Clean up](#exercise-7-clean-up)
  - [Summary](#summary)

[Generative AI](https://learn.microsoft.com/training/paths/introduction-generative-ai/) is a form of artificial intelligence in which [large language models](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview#large-language-model-llm) (LLMs) are trained to generate original content based on natural language input. LLMs are designed to understand and generate human-like language output and are known for their ability to perform a wide range of natural language understanding and generation tasks. Generative AI has a wide range of applications for data-driven applications, including semantic search, recommendation systems, and content generation, such as summarization, among many others.

In this lab, you take advantage of [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) and the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/) to integrate rich generative AI capabilities directly into your Azure Database for PostgreSQL Flexible Server using the [Azure AI Extension](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview). The `azure_ai` extension adds the ability to leverage LLMs directly from your database.

## Prerequisites

This lab uses the Azure Database for PostgreSQL instance created in Lab 1, the data and tables created in Lab 2, and it builds upon the work you did with extensions in Lab 3. If you are starting this lab without completing the previous labs, expand the section below and complete the steps to set up your database.

<details>
<summary>Expand this section to view the prerequisite setup steps.</summary>

### Task 1: Provision an Azure Database for PostgreSQL Flexible Server

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com/).

2. select the **Cloud Shell** icon in the Azure portal toolbar to open a new [Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview) pane at the bottom of your browser window.

    ![The Cloud Shell icon is highlighted in the Azure portal's toolbar.](media/portal-toolbar-cloud-shell.png)

3. At the cloud shell prompt, run the following commands to define variables for creating resources. The variables represent the names to assign to your resource group and database and specify the Azure region into which resources should be deployed.

    The resource group name specified is `rg-postgresql-labs`, but you can provide any name you wish to use to host the resources associated with this lab.

    ```bash
    RG_NAME=rg-postgresql-labs
    ```

    In the database name, replace the `{SUFFIX}` token with a unique value, such as your initials, to ensure the database server name is globally unique.

    ```bash
    DATABASE_NAME=pgsql-flex-{SUFFIX}
    ```

    Replace the region with whatever location you want to use for lab resources.

    ```bash
    REGION=eastus
    ```

4. Run the following Azure CLI command to create a resource group, specifying the location. If you have more than one Azure subscription, use the `az account set --subscription <subscription id>` command first to select the subscription you want to use for lab resources.

    ```bash
    az group create --name $RG_NAME --location $REGION
    ```

5. Provision an Azure Database for PostgreSQL database instance within the resource group you created above by running the following Azure CLI command:

    ```bash
    az postgres flexible-server create --name $DATABASE_NAME --location $REGION --resource-group $RG_NAME \
        --admin-user s2admin --admin-password Seattle123Seattle123 --database-name airbnb \
        --public-access 0.0.0.0-255.255.255.255 --version 16 \
        --sku-name Standard_D2ds_v5 --storage-size 32 --yes
    ```

### Task 2: Connect to the database using psql in the Azure Cloud Shell

In this task, you use the [psql command-line utility](https://www.postgresql.org/docs/current/app-psql.html) from the [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview) to connect to your database.

1. You need the connection details for your database to connect to it using `psql` in the Cloud Shell. Using the open [Azure portal](https://portal.azure.com/) window with the cloud shell pane at the bottom, navigate to your Azure Database for PostgreSQL Flexible Server resource, and in the left-hand navigation menu, select **Connect** under **Settings**.

    ![The Connect menu item is highlighted under Settings in the left-hand navigation menu in the Azure portal.](media/azure-postgres-connect.png)

2. From the database's **Connect** page in the Azure portal, select **airbnb** for the **Database name**, then copy the **Connection details** block and paste it into the Cloud Shell.

    ![The Connection strings page of the Azure Cosmos DB Cluster resource is highlighted. On the Connection strings page, the copy to clipboard button to the right of the psql connection string is highlighted.](media/postgresql-connection-details-psql.png)

3. At the Cloud Shell prompt, replace the `{your_password}` token with the password you assigned to the `s2admin` user when creating your database, then run the command. If you followed the instructions in Lab 1, the password should be `Seattle123Seattle123`.

4. Connect to your database using the `psql` command-line utility by entering the following at the prompt:

    ```bash
    psql
    ```

    Connecting to the database from the Cloud Shell requires that the `Allow public access from any Azure service within Azure to the server` box is checked on the **Networking** page of the database. If you receive a message that you are unable to connect, please verify this is checked and try again.

### Task 3: Add data to the database

Using the `psql` command prompt, you will create tables and populate them with data for use in the lab.

1. Run the following commands to create temporary tables for importing JSON data from a public blob storage account.

    ```sql
    CREATE TABLE temp_calendar (data jsonb);
    CREATE TABLE temp_listings (data jsonb);
    CREATE TABLE temp_reviews (data jsonb);
    ```

2. Using the `COPY` command, populate each temporary table with data from JSON files in a public storage account.

    ```sql
    \COPY temp_calendar (data) FROM PROGRAM 'curl https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/calendar.json'
    ```

    ```sql
    \COPY temp_listings (data) FROM PROGRAM 'curl https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/listings.json'
    ```

    ```sql
    \COPY temp_reviews (data) FROM PROGRAM 'curl https://solliancepublicdata.blob.core.windows.net/ms-postgresql-labs/reviews.json'
    ```

3. Run the following command to create the tables for storing data in the shape used by this lab:

    ```sql
    CREATE TABLE listings (
        listing_id int,
        name varchar(50),
        street varchar(50),
        city varchar(50),
        state varchar(50),
        country varchar(50),
        zipcode varchar(50),
        bathrooms int,
        bedrooms int,
        latitude decimal(10,5), 
        longitude decimal(10,5), 
        summary varchar(2000),
        description varchar(2000),
        host_id varchar(2000),
        host_url varchar(2000),
        listing_url varchar(2000),
        room_type varchar(2000),
        amenities jsonb,
        host_verifications jsonb,
        data jsonb
    );
    ```

    ```sql
    CREATE TABLE reviews (
        id int, 
        listing_id int, 
        reviewer_id int, 
        reviewer_name varchar(50), 
        date date,
        comments varchar(2000)
    );
    ```

    ```sql
    CREATE TABLE calendar (
        listing_id int, 
        date date,
        price decimal(10,2), 
        available boolean
    );
    ```

4. Finally, run the following `INSERT INTO` statements to load data from the temporary tables to the main tables, extracting data from the JSON `data` field into individual columns:

    ```sql
    INSERT INTO listings
    SELECT 
        data['id']::int, 
        replace(data['name']::varchar(50), '"', ''),
        replace(data['street']::varchar(50), '"', ''),
        replace(data['city']::varchar(50), '"', ''),
        replace(data['state']::varchar(50), '"', ''),
        replace(data['country']::varchar(50), '"', ''),
        replace(data['zipcode']::varchar(50), '"', ''),
        data['bathrooms']::int,
        data['bedrooms']::int,
        data['latitude']::decimal(10,5),
        data['longitude']::decimal(10,5),
        replace(data['description']::varchar(2000), '"', ''),        
        replace(data['summary']::varchar(2000), '"', ''),        
        replace(data['host_id']::varchar(50), '"', ''),
        replace(data['host_url']::varchar(50), '"', ''),
        replace(data['listing_url']::varchar(50), '"', ''),
        replace(data['room_type']::varchar(50), '"', ''),
        data['amenities']::jsonb,
        data['host_verifications']::jsonb,
        data::jsonb
    FROM temp_listings;
    ```

    ```sql
    INSERT INTO reviews
    SELECT 
        data['id']::int,
        data['listing_id']::int,
        data['reviewer_id']::int,
        replace(data['reviewer_name']::varchar(50), '"', ''), 
        to_date(replace(data['date']::varchar(50), '"', ''), 'YYYY-MM-DD'),
        replace(data['comments']::varchar(2000), '"', '')
    FROM temp_reviews;
    ```

    ```sql
    INSERT INTO calendar
    SELECT 
        data['listing_id']::int,
        to_date(replace(data['date']::varchar(50), '"', ''), 'YYYY-MM-DD'),
        data['price']::decimal(10,2),
        replace(data['available']::varchar(50), '"', '')::boolean
    FROM temp_calendar;
    ```

    You are now ready to begin Lab 4!

</details>

## Exercise 1: Add Azure AI and Vector extensions to allowlist

Throughout this lab, you use the [azure_ai](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview) and [pgvector](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector) extensions to add generative AI capabilities to your PostgreSQL database. In this exercise, you add these extensions to your server's _allowlist_, as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).

1. In a web browser, navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. From the database's left-hand navigation menu, select **Server parameters** under **Settings**, then enter `azure.extensions` into the search box. Expand the **VALUE** dropdown list, then locate and check the box next to each of the following extensions:

    - AZURE_AI
    - POSTGIS (Note that this will already be checked if you completed lab 3.)
    - VECTOR

    ![On the Server parameters page of the Azure Database for PostgreSQL Flexible Server, azure.extensions is entered and highlighted in the search bar and the AZURE_AI extension is selected and highlighted.](media/postgresql-server-parameters-extensions-azure-ai.png)

3. Select **Save** on the toolbar, which will trigger a deployment on the database.

## Exercise 2: Create an Azure OpenAI resource

The `azure_ai` extension requires an underlying Azure OpenAI service to create [vector embeddings](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview#embeddings). In this exercise, you will provision an Azure OpenAI resource in the Azure portal and deploy an embedding model into that service.

### Task 1: Provision an Azure OpenAI service

In this task, you create a new Azure OpenAI service.

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com/).

2. On the portal home page, select **Create a resource** under Azure services.

    ![Create a resource is highlighted under Azure services on the portal home page.](media/create-a-resource.png)

3. On the **Create a resource** page, enter `azure openai` into the search the marketplace box, then select the **Azure OpenAI** tile and select **Create** on the Azure OpenAI page.

    ![On the Azure portal's create a resource screen, Storage is highlighted in the left-hand menu and Storage account is highlighted under Popular Azure services.](media/create-a-resource-azure-openai.png)

4. On the Create Azure OpenAI **Basics** tab, enter the following information:

    | Parameter            | Value |
    | -------------------- | ----- |
    | **Project details**  |       |
    | Subscription         | Select the subscription you use for lab resources. |
    | Resource group       | Select the resource group you created in Lab 1. |
    | **Instance details** |       |
    | Region               | For this lab, you will use a `text-embedding-ada-002` (version 2) embedding model. This model is currently only available in [certain regions](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings-models). Please select a region from this list, such as `East US`, for this resource. |
    | Name                 | _Enter a globally unique name_, such as `aoai-postgres-labs-SUFFIX`, where `SUFFIX` is a unique string, such as your initials. |
    | Pricing tier         | Select **Standard S0**. |

    ![The Basics tab of the Create Azure OpenAI dialog is displayed, and the fields are populated with the values specified in the task.](media/create-azure-openai-basics-tab.png)

    > Note: If you see a message that the Azure OpenAI Service is currently available to customers via an application form. The selected subscription has not been enabled for the service and does not have a quota for any pricing tiers; you will need to click the link to request access to the Azure OpenAI service and fill out the request form.

5. Select **Next** to move to the **Networking** tab.

6. On the **Networking** tab, select **All networks, including the internet, can access this resource**.

    ![The Networking tab of the Create Azure OpenAI dialog is displayed, with the All networks, including the internet, can access this resource radio button selected and highlighted.](media/create-azure-openai-networking-tab.png)

7. The default settings will be used for the remaining tabs of the storage account configuration, so select **Next** until you get to the **Review** screen, then select the **Create** button on the **Review** tab to provision the Azure OpenAI service.

### Task 2: Deploy an embedding model

The `azure_ai` extension allows the creation of vector embeddings from text. To create these embeddings requires a deployed `text-embedding-ada-002` (version 2) model within your Azure OpenAI service. In this task, you will use [Azure OpenAI Studio](https://oai.azure.com/) to create a model deployment that you can employ.

1. Navigate to your newly provisioned Azure OpenAI resource in the [Azure portal](https://portal.azure.com/).

2. On the resource's **Overview** page, select the **Go to Azure OpenAI Studio** button.  If prompted, select the lab credentials:

    ![Go to Azure OpenAI Studio is highlighted on the Azure OpenAI service's overview page.](media/go-to-azure-openai-studio.png)

3. In Azure OpenAI Studio, select the **Deployments** tab under **Management** in the left-hand menu, then select **+ Create new deployment** from the toolbar.

    ![On the Deployments page in Azure OpenAI Studio, the Create new deployment button is highlighted.](media/azure-openai-studio-deployments-create-new.png)

4. In the **Deploy model** dialog, set the following:

    - **Select a model**: Choose `text-embedding-ada-002` from the list.
    - **Model version**: Ensure **2 (Default)** is selected.
    - **Deployment name**: Enter `embeddings`.

    ![The Deploy model dialog is displayed with text-embedding-ada-002 selected in the select a model box, 2 (default) specified in the model version box, and embeddings entered for the deployment name.](media/azure-openai-studio-deployments-deploy-model-dialog.png)

5. Select **Create** to deploy the model. After a few moments, the deployment will appear in the list of deployments.

## Exercise 3: Install and configure the `azure_ai` extension

In this exercise, you install the `azure_ai` extension into your database and configure it to connect to your Azure OpenAI service.

### Task 1: Connect to the database using psql in the Azure Cloud Shell

In this task, you use the [psql command-line utility](https://www.postgresql.org/docs/current/app-psql.html) from the [Azure Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview) to connect to your database.

1. You need the connection details for your database to connect to it using `psql` in the Cloud Shell. Navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/), and in the left-hand navigation menu, select **Connect** under **Settings**.

    ![The Connect menu item is highlighted under Settings in the left-hand navigation menu in the Azure portal.](media/azure-postgres-connect.png)

2. With the **Connect** page open, select the **Cloud Shell** icon in the Azure portal toolbar to open a new [Cloud Shell](https://learn.microsoft.com/azure/cloud-shell/overview) pane at the bottom of your browser window.

    ![The Cloud Shell icon is highlighted in the Azure portal toolbar and a Cloud Shell window is open at the bottom of the browser window.](media/portal-cloud-shell-postgres.png)

3. From the database's **Connect** page in the Azure portal, select **airbnb** for the **Database name**, then copy the **Connection details** block and paste it into the Cloud Shell.

    ![The Connection strings page of the Azure Cosmos DB Cluster resource is highlighted. On the Connection strings page, the copy to clipboard button to the right of the psql connection string is highlighted.](media/postgresql-connection-details-psql.png)

4. At the Cloud Shell prompt, replace the `{your_password}` token with the password you assigned to the `s2admin` user when creating your database, then run the command. If you followed the instructions in Lab 1, the password should be `Seattle123Seattle123`.

5. Connect to your database using the `psql` command-line utility by entering the following at the prompt:

    ```bash
    psql
    ```

    Connecting to the database from the Cloud Shell requires that the `Allow public access from any Azure service within Azure to the server` box is checked on the **Networking** page of the database. If you receive a message that you are unable to connect, please verify this is checked and try again.

### Task 2: Install the `azure_ai` extension

The `azure_ai` extension allows you to integrate Azure OpenAI and Azure Cognitive Services into your database. To enable the extension in your database, follow the steps below:

1. Verify that the extension was successfully added to the allowlist by running the following from the `psql` command prompt:

    ```sql
    SHOW azure.extensions;
    ```

2. Install the `azure_ai` extension using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

    ```sql
    CREATE EXTENSION IF NOT EXISTS azure_ai;
    ```

### Task 3: Review the objects contained within the `azure_ai` extension

Reviewing the objects within the `azure_ai` extension can provide a better understanding of its capabilities. In this task, you inspect the various schemas, user-defined functions (UDFs), and composite types added to the database by the extension.

1. You can use the [`\dx` meta-command](https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMAND-DX-LC) from the `psql` command prompt to list the objects contained within the extension.

    ```psql
    \dx+ azure_ai
    ```

    The meta-command output shows the `azure_ai` extension creates three schemas, multiple user-defined functions (UDFs), and several composite types in the database. The table below lists the schemas added by the extension and describes each.

    | Schema | Description |
    | ------ | ----------- |
    | `azure_ai` | The principal schema where the configuration table and UDFs for interacting with it reside. |
    | `azure_openai` | Contains the UDFs that enable calling an Azure OpenAI endpoint. |
    | `azure_cognitive` | Provides UDFs and composite types related to integrating the database with Azure Cognitive Services. |

2. The functions and types are all associated with one of the schemas. To review the functions defined in the `azure_ai` schema, use the `\df` meta-command, specifying the schema whose functions should be displayed. The `\x auto` command preceding `\df` allows the expanded display to be automatically applied when necessary to make the output from the command easier to view in the Azure Cloud Shell.

    ```sql
    \x auto
    ```

    ```sql
    \df+ azure_ai.*
    ```

    The `azure_ai.set_setting()` function lets you set the endpoint and key values for Azure AI services. It accepts a **key** and the **value** to assign it. The `azure_ai.get_setting()` function provides a way to retrieve the values you set with the `set_setting()` function. It accepts the **key** of the setting you want to view. For both methods, the key must be one of the following:

    | Key | Description |
    | --- | ----------- |
    | `azure_openai.endpoint` | A supported OpenAI endpoint (e.g., <https://example.openai.azure.com>). |
    | `azure_openai.subscription_key` | A subscription key for an OpenAI resource. |
    | `azure_cognitive.endpoint` | A supported Cognitive Services endpoint (e.g., <https://example.cognitiveservices.azure.com>). |
    | `azure_cognitive.subscription_key` | A subscription key for a Cognitive Services resource. |

3. To ensure the **s2admin** account you specified as the database administrator has appropriate permissions to assign the settings for the `azure_ai` extension, run the following command to `GRANT` it the necessary rights.

    ```sql
    GRANT azure_ai_settings_manager TO s2admin;
    ```

    > Important
    >
    > Because the connection information for Azure AI services, including API keys, is stored in a configuration table in the database, the `azure_ai` extension defines a role called `azure_ai_settings_manager` to ensure this information is protected and accessible only to users assigned that role. This role enables reading and writing of settings related to the extension. Only superusers and members of the `azure_ai_settings_manager` role can invoke the `azure_ai.get_setting()` and `azure_ai.set_setting()` functions. In Azure Database for PostgreSQL Flexible Server, all admin users are assigned the `azure_ai_settings_manager` role.

### Task 4: Set the Azure OpenAI endpoint and key

Before using the `azure_openai` functions, configure the extension to your Azure OpenAI service endpoint and key.

1. Using the same browser tab where the Cloud Shell is open, navigate to your Azure OpenAI resource in the [Azure portal](https://portal.azure.com/) and select the **Keys and Endpoint** item under **Resource Management** from the left-hand menu, then copy your endpoint and access key.

    ![The Azure OpenAI service's Keys and Endpoints page is selected and highlighted, with the KEY 1 and Endpoint copy to clipboard buttons highlighted.](media/azure-openai-keys-and-endpoints.png)

    You can use either `KEY1` or `KEY2`. Always having two keys allows you to securely rotate and regenerate keys without causing service disruption.

2. In the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal, then run the commands from the `psql` command prompt in the Cloud Shell pane to add your values to the configuration table.

    ```sql
    SELECT azure_ai.set_setting('azure_openai.endpoint','{endpoint}');
    SELECT azure_ai.set_setting('azure_openai.subscription_key', '{api-key}');
    ```

3. Verify the settings written in the configuration table using the following queries:

    ```sql
    SELECT azure_ai.get_setting('azure_openai.endpoint');
    SELECT azure_ai.get_setting('azure_openai.subscription_key');
    ```

    The `azure_ai` extension is now connected to your Azure OpenAI account and ready to generate vector embeddings.

## Exercise 4: Generate vector embeddings with Azure OpenAI

The `azure_ai` extension's `azure_openai` schema enables Azure OpenAI to create vector embeddings for text values. Using this schema, you can [generate embeddings with Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/how-to/embeddings) directly from the database to create vector representations of input text, which can then be used in vector similarity searches, as well as consumed by machine learning models.

[Embeddings](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview#embeddings) are a concept in machine learning and natural language processing (NLP) that involves representing objects, such as words, documents, or entities, as [vectors](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-overview#vectors) in a multi-dimensional space. Embeddings allow machine learning models to evaluate how closely related information is. This technique efficiently identifies relationships and similarities between data, allowing algorithms to identify patterns and make accurate predictions.

### Task 1: Enable vector support with the pgvector extension

The `azure_ai` extension allows you to generate embeddings for input text. To enable the generated vectors to be stored alongside the rest of your data in the database, you must install the `pgvector` extension by following the guidance in the [enable vector support in your database](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector#enable-extension) documentation.

1. Install the `pgvector` extension using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

    ```sql
    CREATE EXTENSION IF NOT EXISTS vector;
    ```

2. With vector supported added to your database, add a new column to the `listings` table using the `vector` data type to store embeddings within the table. The `text-embedding-ada-002` model produces vectors with 1536 dimensions, so you must specify `1536` as the vector size.

    ```sql
    ALTER TABLE listings
    ADD COLUMN description_vector vector(1536);
    ```

### Task 2: Generate and store vector embeddings

The `listings` table is now ready to store embeddings. Using the `azure_openai.create_embeddings()` function, you create vectors for the `description` field and insert them into the newly created `description_vector` column in the `listings` table.

1. Before using the `create_embeddings()` function, run the following command to inspect it and review the required arguments:

    ```sql
    \df+ azure_openai.*
    ```

    The `Argument data types` property in the output of the `\df+ azure_openai.*` command reveals the list of arguments the function expects.

    | Argument | Type | Default | Description |
    | -------- | ---- | ------- | ----------- |
    | deployment_name | `text` || Name of the deployment in Azure OpenAI studio that contains the `text-embeddings-ada-002` model. |
    | input | `text` || Input text used to create embeddings. |
    | timeout_ms | `integer` | 3600000 | Timeout in milliseconds after which the operation is stopped. |
    | throw_on_error | `boolean` | true | Flag indicating whether the function should, on error, throw an exception resulting in a rollback of the wrapping transactions. |

2. The first argument required by the `azure_openai.create_embeddings()` function is the `deployment_name`. This name was assigned when you deployed the embedding model in your Azure OpenAI account. To retrieve this value, return to [Azure OpenAI Studio](https://oai.azure.com/) and select **Deployments** under **Management** in the left-hand navigation menu. On the **Deployments** page, copy the **Deployment name** value associated with the `text-embedding-ada-002` model deployment.

    ![The embeddings deployment for the text-embedding-ada-002 model is highlighted on the Deployments tab in Azure OpenAI Studio.](media/azure-openai-studio-deployments-embeddings.png)

3. Using the deployment name, run the following query to update each record in the `listings` table, inserting the generated vector embeddings for the `description` field into the `description_vector` column using the `azure_openai.create_embeddings()` function. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page. Note that this query takes approximately five minutes to complete.

    ```sql
    DO $$

    DECLARE counter integer := (SELECT COUNT(*) FROM listings WHERE description <> '' AND description_vector IS NULL);
    DECLARE r record;
    BEGIN
        RAISE NOTICE 'Total descriptions to embed: %', counter;
        WHILE counter > 0 LOOP
            BEGIN
                FOR r IN
                    SELECT listing_id FROM listings WHERE description <> '' AND description_vector IS NULL
                LOOP
                    BEGIN
                        UPDATE listings
                        SET description_vector = azure_openai.create_embeddings('{your-deployment-name}', description)
                        WHERE listing_id = r.listing_id;
                    EXCEPTION
                        WHEN OTHERS THEN
                            RAISE NOTICE 'Waiting 1 second before trying again...';
                            PERFORM pg_sleep(1);
                    END;
                    counter := (SELECT COUNT(*) FROM listings WHERE description <> '' AND description_vector IS NULL);
                    IF counter % 25 = 0 THEN
                        RAISE NOTICE 'Remaining descriptions to embed: %', counter;
                    END IF;
                END LOOP;
            END;
        END LOOP;
    END;
    $$;
    ```

    The above query uses a `WHILE` loop to retrieve records from the `listings` table where the `description_vector` field is null, and the `description` field is not an empty string. The query then attempts to update the `description_vector` column with a vector representation of the `description` column using the `azure_openai.create_embeddings` function. The loop is used when performing this update to prevent calls to create embeddings function from exceeding the call rate limit of the Azure OpenAI service. If the call rate limit is exceeded, you will see warnings similar to the following in the output:

    ```sql
    NOTICE: Waiting 1 second before trying again...
    ```

4. You can verify that the `description_vector` column has been populated for all `listings` records by running the following query:

    ```sql
    SELECT COUNT(*) FROM listings WHERE description_vector IS NULL AND description <> '';
    ```

    The result of the query should be a count of 0.

### Task 3: Perform a vector similarity search

Vector similarity is a method used to measure two items' similarity by representing them as vectors, a series of numbers. Vectors are often used to perform searches using LLMs. Vector similarity is commonly calculated using distance metrics, such as Euclidean distance or cosine similarity. Euclidean distance measures the straight-line distance between two vectors in the n-dimensional space, while cosine similarity measures the cosine of the angle between two vectors. Each embedding is a vector of floating point numbers, so the distance between two embeddings in the vector space correlates with the semantic similarity between two inputs in the original format.

1. Before executing a vector similarity search, run the below query using the `ILIKE` clause to observe the results of searching for records using a natural language query without using vector similarity:

    ```sql
    SELECT listing_id, name, description FROM listings WHERE description ILIKE '%Properties with a private room near Discovery Park%';
    ```

    The query returns zero results because it is attempting to match the text in the description field with the natural language query provided.

2. Now, execute a [cosine similarity](https://learn.microsoft.com/azure/ai-services/openai/concepts/understand-embeddings#cosine-similarity) search query against the `listings` table to perform a vector similarity search against listing descriptions. The embeddings are generated for an input question and then cast to a vector array (`::vector`), which allows it to be compared against the vectors stored in the `listings` table. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page.

    ```sql
    SELECT listing_id, name, description FROM listings
    ORDER BY description_vector <=> azure_openai.create_embeddings('{your-deployment-name}', 'Properties with a private room near Discovery Park')::vector
    LIMIT 3;
    ```

    The query uses the `<=>` [vector operator](https://github.com/pgvector/pgvector#vector-operators), which represents the "cosine distance" operator used to calculate the distance between two vectors in a multi-dimensional space.

3. Run the same query again using the `EXPLAIN ANALYZE` clause to view the query planning and execution times. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page.

    ```sql
    EXPLAIN ANALYZE
    SELECT listing_id, name, description FROM listings
    ORDER BY description_vector <=> azure_openai.create_embeddings('{your-deployment-name}', 'Properties with a private room near Discovery Park')::vector
    LIMIT 3;
    ```

    In the output, notice the query plan, which will start with something similar to:

    ```sql
    Limit  (cost=1098.54..1098.55 rows=3 width=261) (actual time=10.505..10.507 rows=3 loops=1)
       ->  Sort  (cost=1098.54..1104.10 rows=2224 width=261) (actual time=10.504..10.505 rows=3 loops=1)

    ...

    Sort Method: top-N heapsort  Memory: 27kB
        ->  Seq Scan on listings  (cost=0.00..1069.80 rows=2224 width=261) (actual time=0.005..9.997 rows=2224 loops=1)
    ```

    The query is using a sequential scan sort to perform the lookup. The planning and execution times will be listed at the end of the results, and should look similar to the following:

    ```sql
    Planning Time: 62.020 ms
    Execution Time: 10.530 ms
    ```

4. To enable more efficient searching over the `vector` field, create an index on `listings` using cosine distance and [HNSW](https://github.com/pgvector/pgvector#hnsw), which is short for Hierarchical Navigable Small World. HNSW allows `pgvector` to utilize the latest graph-based algorithms to approximate nearest-neighbor queries.

    ```sql
    CREATE INDEX ON listings USING hnsw (description_vector vector_cosine_ops);
    ```

5. To observe the impact of the `hnsw` index on the table, run the query again with the `EXPLAIN ANALYZE` clause to compare the query planning and execution times. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page.

    ```sql
    EXPLAIN ANALYZE
    SELECT listing_id, name, description FROM listings
    ORDER BY description_vector <=> azure_openai.create_embeddings('{your-deployment-name}', 'Properties with a private room near Discovery Park')::vector
    LIMIT 3;
    ```

    In the output, notice the query plan now includes a more efficient index scan:

    ```sql
    Limit  (cost=116.48..119.33 rows=3 width=261) (actual time=1.112..1.130 rows=3 loops=1)
       ->  Index Scan using listings_description_vector_idx on listings  (cost=116.48..2228.28 rows=2224 width=261) (actual time=1.111..1.128 rows=3 loops=1)
    ```

    The query execution times should reflect a significant reduction in the time it took to plan and run the query:

    ```sql
    Planning Time: 56.802 ms
    Execution Time: 1.167 ms
    ```

## Exercise 5: Integrate Azure AI Services

The Azure AI services integrations included in the `azure_cognitive` schema of the `azure_ai` extension provide a rich set of AI Language features accessible directly from the database. The functionalities include sentiment analysis, language detection, key phrase extraction, entity recognition, and text summarization. These capabilities are enabled through the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/overview).

To review the complete list of Azure AI capabilities accessible through the extension, view the [Integrate Azure Database for PostgreSQL Flexible Server with Azure Cognitive Services documentation](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-cognitive).

### Task 1: Provision an Azure AI Language service

An [Azure AI Language](https://learn.microsoft.com/azure/ai-services/language-service/overview) service is required to take advantage of the `azure_ai` extensions cognitive functions. In this exercise, you will create an Azure AI Language service.

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com/).

2. On the portal home page, select **Create a resource** under Azure services.

    ![Create a resource is highlighted under Azure services on the portal home page.](media/create-a-resource.png)

3. On the **Create a resource** page, select `AI + Machine Learning` from the left-hand menu, then select **Language service**.

    ![On the Azure portal's create a resource screen, Storage is highlighted in the left-hand menu and Storage account is highlighted under Popular Azure services.](media/create-a-resource-language-service.png)

4. On the **Select additional features** dialog, select **Continue to create your resource**.

    ![The continue to create your resource button is highlighted on the select additional features dialog.](media/create-a-resource-language-service-select-additional-features.png)

5. On the Create Language **Basics** tab, enter the following:

    | Parameter            | Value |
    | -------------------- | ----- |
    | **Project details**  |       |
    | Subscription         | Select the subscription you use for lab resources. |
    | Resource group       | Select the resource group you created in Lab 1. |
    | **Instance details** |       |
    | Region               | Select the region you used for your Azure Database for PostgreSQL Flexible Server resource. |
    | Name                 | _Enter a globally unique name_, such as `lang-postgres-labs-SUFFIX`, where `SUFFIX` is a unique string, such as your initials. |
    | Pricing tier         | Select the standard pricing tier, **S (1K Calls per minute)**. |
    | Responsible AI Notice | Check the box to certify you have reviewed and acknowledged the Responsible AI Notice. |

    ![The Basics tab of the Create Language dialog is displayed and populated with the values specified above.](media/create-language-service-basics-tab.png)

6. The default settings will be used for the remaining tabs of the Language service configuration, so select the **Review + create** button.

7. Select the **Create** button on the **Review + create** tab to provision the Language service.

8. Select **Go to resource group** on the deployment page when the language service deployment is complete.

    ![The go to resource group button is highlighted on the Language service deployment page.](media/create-language-service-deployment-complete.png)

### Task 2: Set the Azure AI Language service endpoint and key

As with the `azure_openai` functions, to successfully make calls against Azure AI services using the `azure_ai` extension, you must provide the endpoint and a key for your Azure AI Language service.

1. Using the same browser tab where the Cloud Shell is open, navigate to your Language service resource in the [Azure portal](https://portal.azure.com/) and select the **Keys and Endpoint** item under **Resource Management** from the left-hand navigation menu.

    ![The Keys and Endpoints page of the Language service is displayed, with the Keys and Endpoints menu item highlighted in the left-hand navigation menu.](media/azure-language-service-keys-and-endpoints.png)

2. Copy your endpoint and access key values, then in the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal. Run the commands from the `psql` command prompt in the Cloud Shell to add your values to the configuration table.

    ```sql
    SELECT azure_ai.set_setting('azure_cognitive.endpoint','{endpoint}');
    SELECT azure_ai.set_setting('azure_cognitive.subscription_key', '{api-key}');
    ```

### Task 3: Analyze the sentiment of reviews

In this task, you will use the `azure_cognitive.analyze_sentiment` function to evaluate reviews of Airbnb listings.

1. To perform sentiment analysis using the `azure_cognitive` schema in the `azure_ai` extension, you use the `analyze_sentiment` function. Run the command below to review that function:

    ```sql
    \df azure_cognitive.analyze_sentiment
    ```

    The output shows the function's schema, name, result data type, and argument data types. This information helps in gaining an understanding of how to use the function.

2. It is also essential to understand the structure of the result data type the function outputs so you can correctly handle its return value. Run the following command to inspect the `sentiment_analysis_result` type:

    ```sql
    \dT+ azure_cognitive.sentiment_analysis_result
    ```

3. The output of the above command reveals the `sentiment_analysis_result` type is a `tuple`. To understand the structure of that `tuple`,  run the following command to look at the columns contained within the `sentiment_analysis_result` composite type:

    ```sql
    \d+ azure_cognitive.sentiment_analysis_result
    ```

    The output of that command should look similar to the following:

    ```sql
                     Composite type "azure_cognitive.sentiment_analysis_result"
         Column     |       Type       | Collation | Nullable | Default | Storage  | Description 
    ----------------+------------------+-----------+----------+---------+----------+-------------
     sentiment      | text             |           |          |         | extended | 
     positive_score | double precision |           |          |         | plain    | 
     neutral_score  | double precision |           |          |         | plain    | 
     negative_score | double precision |           |          |         | plain    |
    ```

    The `azure_cognitive.sentiment_analysis_result` is a composite type containing the sentiment predictions of the input text. It includes the sentiment, which can be positive, negative, neutral, or mixed, and the scores for positive, neutral, and negative aspects found in the text. The scores are represented as real numbers between 0 and 1. For example, in (neutral,0.26,0.64,0.09), the sentiment is neutral with a positive score of 0.26, neutral of 0.64, and negative at 0.09.

4. Now that you have an understanding of how to analyze sentiment using the extension and the shape of the return type, execute the following query that looks for overwhelmingly positive reviews:

    ```sql
    WITH cte AS (
        SELECT id, azure_cognitive.analyze_sentiment(comments, 'en') AS sentiment FROM reviews LIMIT 100
    )
    SELECT
        id,
        (sentiment).sentiment,
        (sentiment).positive_score,
        (sentiment).neutral_score,
        (sentiment).negative_score,
        comments
    FROM cte
    WHERE (sentiment).positive_score > 0.98
    LIMIT 10;
    ```

    The above query uses a common table expression or CTE to get the sentiment scores for the first three records in the `reviews` table. It then selects the `sentiment` composite type columns from the CTE to extract the individual values from the `sentiment_analysis_result`.

## Exercise 6: Execute a final query to tie it all together (Optional)

In this exercise, you connect to your database in **pgAdmin** and execute a final query that ties together your work with the `azure_ai`, `postgis`, and `pgvector` extensions across labs 3 and 4.

### Task 1: Connect to the database using pgAdmin

In this task, you will open pgAdmin and connect to your database.

1. If you do not already have it installed, download and install [pgAdmin](https://www.pgadmin.org/download/).

2. Open **pgAdmin** and, if you have not already done so, register your server by right-clicking **Servers** in the Object Explorer and selecting **Register > Server**.

    **Note: you can skip this step if you registered the server in pgAdmin in a previous lab.**

    ![In the pgAdmin Object Explorer, Servers is selected and in its flyout menu, Register > Server is highlighted.](media/pgadmin-register-server.png)

    Retrieve the server name of your Azure Database for PostgreSQL Flexible Server from the Azure portal.

    ![The server name of the Azure Database for PostgresSQL Flexible Server is highlighted in the Azure portal.](media/azure-portal-postgresql-server-name.png)

    In the **Register - Server** dialog, paste your Azure Database for PostgreSQL Flexible Server server name into the **Name** field on the **General** tab.

    ![On the General tab of the Register - Server dialog, the Name field is populated with the server name value from the Azure portal and the field is highlighted.](media/pgadmin-register-server-general-tab.png)

    Next, select the **Connection** tab and paste your server name into the **Hostname/address** field. Enter **s2admin** into the **Username** field, enter **Seattle123Seattle123** into the **Password** box, and optionally, select **Save password**.

    ![On the Connection tab of the Register - Server dialog, the Hostname/address field is populated with the server name value from the Azure portal, and the field is highlighted. A value of s2admin has been entered into the Username box, Seattle123Seattle123 is entered into the password box, and the Save password option is selected. All these fields are highlighted.](media/pgadmin-register-server-connection-tab.png)

    Finally, select the **Parameters** tab and set the **SSL mode** to **require**.

    ![On the Parameters tab of the Register - Server dialog, the value of require is selected from the SSL Mode option, and the field is highlighted. The Save button is highlighted.](media/pgadmin-register-server-parameters-tab.png)

    Select **Save** to register your server.

3. Expand the **Servers** node within the Object Explorer, select your database server from the list, then right-click the server and select **Connect Server** from the context menu.

    ![The Azure Database for PostgreSQL Flexible Server instance is selected and highlighted in the Object Explorer in pgAdmin. In the server's context menu, Connect Server is highlighted.](media/pg-admin-server-connect.png)
  
4. Once connected to your server, expand the **Databases** node and select the **airbnb** database. Right-click the **airbnb** database and select **Query Tool** from the context menu.

    ![Under the server databases, the airbnb database is selected and Query Tool is highlighted in the context menu.](media/pg-admin-airbnb-database-query-tool.png)

### Task 2: Verify that the PostGIS extension is installed in your database

**If you completed Lab 3, you can skip to [Task 3, below](#task-3-execute-a-query-and-view-results-on-a-map).**

To install the `postgis` extension in your database, you will use the [CREATE EXTENSION](https://www.postgresql.org/docs/current/static/sql-createextension.html) command.

1. In the query window you opened above, run the `CREATE EXTENSION` command with the `IF NOT EXISTS` clause to install the `postgis` extension in your database.

    ```sql
    CREATE EXTENSION IF NOT EXISTS postgis;
    ```

    With the `PostGIS` extension now loaded, you are ready to begin working with geospatial data in the database. The `listings` table you created and populated above contains the latitude and longitude of all listed properties. To use these data for geospatial analysis, you must alter the `listings` table to add a `geometry` column that accepts the `point` data type. These new data types are included in the `postgis` extension.

2. To accommodate `point` data, add a new `geometry` column to the table that accepts `point` data. Copy and paste the following query into the open pgAdmin query window:

    ```sql
    ALTER TABLE listings
    ADD COLUMN listing_location geometry(point, 4326);
    ```

3. Next, update the table with geospatial data associated with each listing by adding the longitude and latitude values into the `geometry` column.

    ```sql
    UPDATE listings
    SET listing_location = ST_SetSRID(ST_Point(longitude, latitude), 4326);
    ```

### Task 3: Execute a query and view results on a map

You run a final query in this task that ties your work across labs 3 and 4.

1. Run the below query that incorporates elements of the `azure_ai`, `pgvector`, and `PostGIS` extensions you have worked with in labs 3 and 4. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page.

    ```sql
    WITH listings_cte AS (
        SELECT l.listing_id, name, listing_location, summary FROM listings l
        INNER JOIN calendar c ON l.listing_id = c.listing_id
        WHERE ST_DWithin(
            listing_location,
            ST_GeomFromText('POINT(-122.410347 47.655598)', 4326),
            0.025
        )
        AND c.date = '2016-01-13'
        AND c.available = 't'
        AND c.price <= 75.00
        AND l.listing_id IN (SELECT listing_id FROM reviews)
        ORDER BY description_vector <=> azure_openai.create_embeddings('{your-deployment-name}', 'Properties with a private room near Discovery Park')::vector
        LIMIT 3
    ),
    sentiment_cte AS (
        SELECT r.listing_id, comments, azure_cognitive.analyze_sentiment(comments, 'en') AS sentiment
        FROM reviews r
        INNER JOIN listings_cte l ON r.listing_id = l.listing_id
    )
    SELECT
        l.listing_id,
        name,
        listing_location,
        summary,
        avg((sentiment).positive_score) as avg_positive_score,
        avg((sentiment).neutral_score) as avg_neutral_score,
        avg((sentiment).negative_score) as avg_negative_score
    FROM sentiment_cte s
    INNER JOIN listings_cte l on s.listing_id = l.listing_id
    GROUP BY l.listing_id, name, listing_location, summary;
    ```

2. In the **Data Output** panel, select the **View all geometries in this column** button displayed in the `listing_location` column of the query results.

    ![In the query Data Output panel, the View all geometries in this column button is highlighted.](media/pgadmin-final-query-data-output.png)

    The **View all geometries in this column** button opens the **Geometry Viewer**, allowing you to view the query results on a map.

3. Select one of the three points displayed on the map to view details about the location, including the average positive, neutral, and negative sentiment scores across all ratings for the property.

    ![The Geometry Viewer tab is highlighted and a property point is highlighted on the map.](media/pgadmin-final-query-geometry-viewer.png)

## Exercise 7: Clean up

It is crucial that you clean up any resources you created for these labs once you have completed them. You are charged for the configured capacity, not how much the database is used. To delete your resource group and all resources you created for this lab, follow the instructions below:

1. Open a web browser and navigate to the [Azure portal](https://portal.azure.com/), and on the home page, select **Resource groups** under Azure services.

    ![Resource groups is highlighted under Azure services in the Azure portal.](media/azure-portal-home-azure-services-resource-groups.png)

2. In the filter for any field search box, enter the name of the resource group you created for these labs in Lab 1, and then select the resource group from the list.

3. In the **Overview** pane, select **Delete resource group**.

    ![On the Overview blade of the resource group. The Delete resource group button is highlighted.](media/resource-group-delete.png)

4. In the confirmation dialog, enter the name of the resource group you created to confirm and then select **Delete**.

## Summary

Congratulations! You have completed the **Generative AI with Azure Database for PostgreSQL Flexible Server** hands-on lab. In this lab, you explored the powerful extensibility of Azure Database for PostgreSQL Flexible Server by installing and using the `azure_ai` extension to directly add the power of generative AI and large language models into your database.
