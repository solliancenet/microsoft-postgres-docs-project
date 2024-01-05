# Hands on Lab: Building AI Apps with Azure Open AI

- [Hands on Lab: Building AI Apps with Azure Open AI](#hands-on-lab-building-ai-apps-with-azure-open-ai)
  - [Exercise 1: Add Azure AI and Vector extensions to allowlist](#exercise-1-add-azure-ai-and-vector-extensions-to-allowlist)
  - [Exercise 2: Create an Azure OpenAI resource](#exercise-2-create-an-azure-openai-resource)
    - [Task 1: Provision an Azure OpenAI service](#task-1-provision-an-azure-openai-service)
    - [Task 2: Deploy an embedding model](#task-2-deploy-an-embedding-model)
  - [Exercise 3: Install and configure the `azure_ai` extension](#exercise-3-install-and-configure-the-azure_ai-extension)
    - [Task 1: Connect to the database using psql in the Azure Cloud Shell](#task-1-connect-to-the-database-using-psql-in-the-azure-cloud-shell)
    - [Task 2: Install the `azure_ai` extension](#task-2-install-the-azure_ai-extension)
    - [Task 3: Review the objects contained within the `azure_ai` extension](#task-3-review-the-objects-contained-within-the-azure_ai-extension)
  - [Exercise 4: Generate vector embeddings with Azure OpenAI](#exercise-4-generate-vector-embeddings-with-azure-openai)
    - [Task 1: Enable vector support with the pgvector extension](#task-1-enable-vector-support-with-the-pgvector-extension)
    - [Task 2: Generate and store vectors](#task-2-generate-and-store-vectors)
  - [Exercise 5: Integrate Azure AI Services](#exercise-5-integrate-azure-ai-services)
    - [Task 1: Provision an Azure AI Language service](#task-1-provision-an-azure-ai-language-service)
    - [Task 2: Set the Azure AI Language service endpoint and key](#task-2-set-the-azure-ai-language-service-endpoint-and-key)
    - [Task 3: Analyze sentiment of reviews](#task-3-analyze-sentiment-of-reviews)
  - [Exercise 6: Build sample app](#exercise-6-build-sample-app)
  - [Exercise 7: Clean up](#exercise-7-clean-up)

In this lab, you integrate Azure AI Services into your PostgreSQL Flexible Server using the [Azure AI Extension](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview). The `azure_ai` extension adds the ability to leverage [large language models](https://learn.microsoft.com/training/modules/fundamentals-generative-ai/3-language%20models) (LLMs) directly from your Azure Database for PostgreSQL Flexible Server. This capability allows you to build [generative AI](https://learn.microsoft.com/training/paths/introduction-generative-ai/) applications within a database by integrating the power of [Azure AI services](https://learn.microsoft.com/azure/ai-services/what-are-ai-services). Generative AI is a form of artificial intelligence in which LLMs are trained to generate original content based on natural language input. Using the `azure_ai` extension allows you to take advantage of generative AI's natural language query processing capabilities directly from the database.

This lab showcases adding rich AI capabilities to an Azure Database for PostgreSQL Flexible Server using the `azure_ai` extension. It covers integrating both [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) and the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/) into your database.

> Important:
>
> This lab builds upon the work done in Lab 3 and relies on data loaded into the Azure Database for PostgreSQL Flexible Server in that lab.

## Exercise 1: Add Azure AI and Vector extensions to allowlist

In this lab, you use the [azure_ai](https://learn.microsoft.com/azure/postgresql/flexible-server/generative-ai-azure-overview) and [pgvector](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector) extensions to add generative AI capabilities to your PostgreSQL database. In this exercise, you add these extensions to your server's _allowlist_, as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).

1. In a web browser, navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. From the database's left-hand navigation menu, select **Server parameters** under **Settings**, then enter `azure.extensions` into the search box. Expand the **VALUE** dropdown list, then locate and check the box next to each of the following extensions:

    - AZURE_AI
    - VECTOR

    ![On the Server parameters page of the Azure Database for PostgreSQL Flexible Server, azure.extensions is entered and highlighted in the search bar and the AZURE_AI extension is selected and highlighted.](media/postgresql-server-parameters-extensions-azure-ai.png)

3. Select **Save** on the toolbar, which will trigger a deployment on the database.

## Exercise 2: Create an Azure OpenAI resource

The `azure_ai` extension requires an underlying Azure OpenAI service. In this exercise, you will provision an Azure OpenAI resource in the Azure portal.

### Task 1: Provision an Azure OpenAI service

If you do not have a resource, the process for creating one is documented in the [Azure OpenAI resource deployment guide](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource).

1. In a web browser, navigate to the [Azure portal](https://portal.azure.com/).

2. On the portal home page, select **Create a resource** under Azure services.

    ![Create a resource is highlighted under Azure services on the portal home page.](media/create-a-resource.png)

3. On the **Create a resource** page, enter `azure openai` into the search the marketplace box, then select the **Azure OpenAI** tile and select **Create** on the Azure OpenAI page.

    ![On the Azure portal's create a resource screen, Storage is highlighted in the left-hand menu and Storage account is highlighted under Popular Azure services.](media/create-a-resource-azure-openai.png)

4. On the Create Azure OpenAI **Basics** tab, enter the following information:

    | Parameter            | Value |
    | -------------------- | ----- |
    | **Project details**  |       |
    | Subscription         | Select the subscription you are using for resources in this lab. |
    | Resource group       | Select the resource group you created in Lab 1. |
    | **Instance details** |       |
    | Region               | For this lab, you will use a `text-embedding-ada-002` (version 2) embedding model. This model is currently only available in [certain regions](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings-models). Please select a region from this list, such as `East US`, to use for this resource. |
    | Name                 | _Enter a globally unique name_, such as `aoai-postgres-labs-SUFFIX`, where `SUFFIX` is a unique string, such as your initials. |
    | Pricing tier         | Select **Standard S0**. |

    ![The Basics tab of the Create Azure OpenAI dialog is displayed, and the fields are populated with the values specified in the task.](media/create-azure-openai-basics-tab.png)

    > Note: If you see a message that the Azure OpenAI Service is currently available to customer via an application form. The selected subscription has not been enabled for use of the service and does not have quota for any pricing tiers, you will need to click the link to request access to the Azure OpenAI service and fill out the request form.

5. Select **Next** to move to the **Networking** tab.

6. On the **Networking** tab, select **All networks, including the internet, can access this resource**.

    ![The Networking tab of the Create Azure OpenAI dialog is displayed, with the All networks, including the internet, can access this resource radio button selected and highlighted.](media/create-azure-openai-networking-tab.png)

7. The default settings will be used for the remaining tabs of the storage account configuration, so select **Next** until you get to the **Review** screen, then select the **Create** button on the **Review** tab to provision the Azure OpenAI service.

### Task 2: Deploy an embedding model

The `azure_ai` extension provides the ability to create vector embeddings from text. To create these embeddings requires a deployed `text-embedding-ada-002` (version 2) model within your Azure OpenAI service. In this task, you will use [Azure OpenAI Studio](https://oai.azure.com/) to create a model deployment that use can use.

1. Navigate to your Azure OpenAI resource in the [Azure portal](https://portal.azure.com/).

2. On the resource's **Overview** page, select the **Go to Azure OpenAI Studio** button.

    ![Go to Azure OpenAI Studio is highlighted on the Azure OpenAI service's overview page.](media/go-to-azure-openai-studio.png)

3. In Azure OpenAI Studio, select the **Deployments** tab under **Management** in the left-hand menu, then select **+ Create new deployment** from the toolbar.

    ![On the Deployments page in Azure OpenAI Studio, the Create new deployment button is highlighted.](media/azure-openai-studio-deployments-create-new.png)

4. In the **Deploy model** dialog, set the following:

    - **Select a model**: Choose `text-embedding-ada-002` from the list.
    - **Model version**: Ensure **2 (Default)** is selected.
    - **Deployment name**: Enter `embeddings`.

    ![The Deploy model dialog is displayed with text-embedding-ada-002 selected in the select a model box, 2 (default) selected in the model version box, and embeddings entered for the deployment name.](media/azure-openai-studio-deployments-deploy-model-dialog.png)

5. Select **Create** to deploy the model. After a few moments, the deployment will appear in the list of deployments.

## Exercise 3: Install and configure the `azure_ai` extension

### Task 1: Connect to the database using psql in the Azure Cloud Shell

In this task, you use the `psql` command line utility from the Azure Cloud Shell to connect to your database.

1. Using the same browser tab where the Cloud Shell is open, navigate to your Azure Database for PostgreSQL Flexible Server resource in the [Azure portal](https://portal.azure.com/).

2. From the database's left-hand navigation menu, select **Connect** under **Settings**, then select **airbnb** for the **Database name** and copy the **Connection details** block.

    ![The Connection strings page of the Azure Cosmos DB Cluster resource is highlighted. On the Connection strings page, the copy to clipboard button to the right of the psql connection string is highlighted.](media/postgresql-connection-details-psql.png)

3. Paste the connection details into the Cloud Shell, and replace the `{your_password}` token with the password you assigned to the `s2admin` user when creating your database. If the followed the instructions in Lab 1, the password should be `Seattle123Seattle123`.

4. Add one additional environment variable to require an SSL connection to the database.

    ```bash
    export PGSSLMODE=require
    ```

5. Connect to your database using the [psql command-line utility](https://www.postgresguide.com/utilities/psql/) by entering the following at the prompt.

    ```bash
    psql
    ```

    Connecting to the database from the Cloud Shell requires that the `Allow public access from any Azure service within Azure to the server` box is checked on the **Networking** page of the database. If you receive a message that you are unable to connect, please verify this is checked and try again.

### Task 2: Install the `azure_ai` extension

The `azure_ai` extension allows you to integrate Azure OpenAI and Azure Cognitive Services into your database. To enable the extension in your database, follow the steps below:

1. Add the extension to your allowlist as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).

2. Verify that the extension was successfully added to the allowlist by running the following from the `psql` command prompt:

    ```sql
    SHOW azure.extensions;
    ```

3. Install the `azure_ai` extension using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

    ```sql
    CREATE EXTENSION azure_ai;
    ```

### Task 3: Review the objects contained within the `azure_ai` extension

Reviewing the objects contained within the `azure_ai` extension can provide a better understanding of the capabilities it offers. In this task, you inspect the various schemas, user-defined functions (UDFs), and composite types added to the database by the extension.

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

2. The functions and types are all associated with one of the schemas. To review the functions defined in the `azure_ai` schema, use the `\df` meta-command, specifying the schema whose functions should be displayed. The `\x` commands before and after the `\df` command toggle the expanded display on and off to make the output from the command easier to view in the Azure Cloud Shell.

    ```sql
    \x
    \df+ azure_ai.*
    \x
    ```

    The `azure_ai.set_setting()` function lets you set the endpoint and key values for Azure AI services. It accepts a **key** and the **value** to assign it. The `azure_ai.get_setting()` function provides a way to retrieve the values you set with the `set_setting()` function. It accepts the **key** of the setting you want to view. For both methods, the key must be one of the following:

    | Key | Description |
    | --- | ----------- |
    | `azure_openai.endpoint` | A supported OpenAI endpoint (e.g., <https://example.openai.azure.com>). |
    | `azure_openai.subscription_key` | A subscription key for an OpenAI resource. |
    | `azure_cognitive.endpoint` | A supported Cognitive Services endpoint (e.g., <https://example.cognitiveservices.azure.com>). |
    | `azure_cognitive.subscription_key` | A subscription key for a Cognitive Services resource. |

    > Important
    >
    > Because the connection information for Azure AI services, including API keys, is stored in a configuration table in the database, the `azure_ai` extension defines a role called `azure_ai_settings_manager` to ensure this information is protected and accessible only to users assigned that role. This role enables reading and writing of settings related to the extension. Only superusers and members of the `azure_ai_settings_manager` role can invoke the `azure_ai.get_setting()` and `azure_ai.set_setting()` functions. In Azure Database for PostgreSQL Flexible Server, all admin users are assigned the `azure_ai_settings_manager` role.

## Exercise 4: Generate vector embeddings with Azure OpenAI

The `azure_ai` extension's `azure_openai` schema enables the use of Azure OpenAI for creating vector embeddings for text values. Using this schema, you can [generate embeddings with Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/how-to/embeddings) directly from the database to create vector representations of input text, which can then be used in vector similarity searches, as well as consumed by machine learning models.

Embeddings are a technique of using machine learning models to evaluate how closely related information is. This technique allows for efficient identification of relationships and similarities between data, allowing algorithms to identify patterns and make accurate predictions.

### Task 1: Enable vector support with the pgvector extension

The `azure_ai` extension allows you to generate embeddings for input text. To enable the generated vectors to be stored alongside the rest of your data in the database, you must install the `pgvector` extension by following the guidance in the [enable vector support in your database](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector#enable-extension) documentation.

1. TODO: Add steps for installing `pgvector`...

    ```sql
    CREATE EXTENSION IF NOT EXISTS vector;
    ```

2. With vector supported added to your database, add a new column to the `listings` table using the `vector` data type to store embeddings within the table. The `text-embedding-ada-002` model produces vectors with 1536 dimensions, so you must specify `1536` as the vector size.

    ```sql
    ALTER TABLE listings
    ADD COLUMN bill_vector vector(1536);
    ```

### Task 2: Generate and store vectors

The `bill_summaries` table is now ready to store embeddings. Using the `azure_openai.create_embeddings()` function, you will create vectors for the `bill_text` field and insert them into the newly created `bill_vector` column in the `bill_summaries` table.

Before using the `create_embeddings()` function, run the following command to inspect it and review the required arguments:

```sql
\x
\df+ azure_openai.*
\x
```

The `Argument data types` property in the output of the `\df+ azure_openai.*` command reveals the list of arguments the function expects.

| Argument | Type | Default | Description |
| -------- | ---- | ------- | ----------- |
| deployment_name | `text` || Name of the deployment in Azure OpenAI studio that contains the `text-embeddings-ada-002` model. |
| input | `text` || Input text used to create embeddings. |
| timeout_ms | `integer` | 3600000 | Timeout in milliseconds after which the operation is stopped. |
| throw_on_error | `boolean` | true | Flag indicating whether the function should, on error, throw an exception resulting in a rollback of the wrapping transactions. |

The first argument is the `deployment_name`, assigned when your embeddings model was deployed in your Azure OpenAI account. To retrieve this value, go to your Azure OpenAI resource in the Azure portal. From there, select the **Model deployments** item under **Resource Management** in the left-hand navigation menu, then select **Manage Deployments** to open Azure OpenAI Studio. On the **Deployments** tab in Azure OpenAI Studio, copy the **Deployment name** value associated with the `text-embedding-ada-002` model deployment.

![The embeddings deployment for the text-embedding-ada-002 model is highlighted on the Deployments tab in Azure OpenAI Studio.](./media/azure_openai_studio_deployments_embeddings.png)

Using this information, run a query to update each record in the `bill_summaries` table, inserting the generated vector embeddings for the `bill_text` field into the `bill_vector` column using the `azure_openai.create_embeddings()` function. Replace `{your-deployment-name}` with the **Deployment name** value you copied from the Azure OpenAI Studio **Deployments** page, and then run the following command:

```sql
UPDATE bill_summaries b
SET bill_vector = azure_openai.create_embeddings('{your-deployment-name}', b.bill_text);
```

Execute the following query to view the embedding generated for the first record in the table. You can run `\x` first if the output is difficult to read.

```sql
SELECT bill_vector FROM bill_summaries LIMIT 1;
```

Each embedding is a vector of floating point numbers, such that the distance between two embeddings in the vector space is correlated with semantic similarity between two inputs in the original format.

## Exercise 5: Integrate Azure AI Services

The Azure AI services integrations included in the `azure_cognitive` schema of the `azure_ai` extension provide a rich set of AI Language features accessible directly from the database. The functionalities include sentiment analysis, language detection, key phrase extraction, entity recognition, and text summarization. Access to these capabilities is enabled through the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/overview).

To review the complete list of Azure AI capabilities accessible through the extension, view the [Integrate Azure Database for PostgreSQL Flexible Server with Azure Cognitive Services](**TODO: Add link to the doc here**).

### Task 1: Provision an Azure AI Language service

An [Azure AI Language](https://learn.microsoft.com/azure/ai-services/language-service/overview) service is required to take advantage of the `azure_ai` extensions cognitive functions. In this exercise, you will create an Azure AI Language service to use for the exercises in this lab.

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
    | Subscription         | Select the subscription you are using for resources in this lab. |
    | Resource group       | Select the resource group you created in Lab 1. |
    | **Instance details** |       |
    | Region               | Select the region you used for your Azure Database for PostgreSQL Flexible Server resource. |
    | Name                 | _Enter a globally unique name_, such as `lang-postgres-labs-SUFFIX`, where `SUFFIX` is a unique string, such as your initials. |
    | Pricing tier         | Select the free pricing tier, **Free F0**. |
    | Responsible AI Notice | Check the box to certify you have reviewed and acknowledged the Responsible AI Notice. |

    ![The Basics tab of the Create Language dialog is displayed and populated with the values specified above.](media/create-language-service-basics-tab.png)

6. The default settings will be used for the remaining tabs of the Language service configuration, so select the **Review + create** button.

7. Select the **Create** button on the **Review + create** tab to provision the Language service.

8. When the Language service deployment completes, select **Go to resource group** on the deployment page.

    ![The go to resource group button is highlighted on the Language service deployment page.](media/create-language-service-deployment-complete.png)

9. In the resource group, select the **Keys and Endpoint** item under **Resource Management** from the left-hand navigation menu.

    TODO: insert screenshot.

### Task 2: Set the Azure AI Language service endpoint and key

As with the `azure_openai` functions, to successfully make calls against Azure AI services using the `azure_ai` extension, you must provide the endpoint and a key for your Azure AI Language service. Retrieve those values by navigating to your Language service resource in the Azure portal and selecting the **Keys and Endpoint** item under **Resource Management** from the left-hand menu. Copy your endpoint and access key. You can use either `KEY1` or `KEY2`.

In the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal, then run the commands from the `psql` command prompt to add your values to the configuration table.

```sql
SELECT azure_ai.set_setting('azure_cognitive.endpoint','{endpoint}');
SELECT azure_ai.set_setting('azure_cognitive.subscription_key', '{api-key}');
```

### Task 3: Analyze sentiment of reviews

TODO...

## Exercise 6: Build sample app

Explore a low code/nocode chatbot using postgres? (Have to see how easy)

Possibly use a simple Steamlit app to interact with database and execute vector similarity searches?

## Exercise 7: Clean up

It is crucial that you clean up any unused resources. You are charged for the configured capacity, not how much the database is used. To delete your resource group and all resources you created for this lab, follow these instructions:

1. Open a web browser and navigate to the [Azure portal](https://portal.azure.com/).

2. In the left-hand navigation menu, select **Resource Groups**, and then select the resource group you created as part of Exercise 1.

3. In the **Overview** pane, select **Delete resource group**.

4. Enter the name of the resource group you created to confirm and then select **Delete**.
