# Integrate Azure AI capabilities into Azure Database for PostgreSQL - Flexible Server

**In this article**

- [Integrate Azure AI capabilities into Azure Database for PostgreSQL - Flexible Server](#integrate-azure-ai-capabilities-into-azure-database-for-postgresql---flexible-server)
  - [Prerequisites](#prerequisites)
  - [Connect to the database using `psql` in the Azure Cloud Shell](#connect-to-the-database-using-psql-in-the-azure-cloud-shell)
  - [Install the `azure_ai` extension](#install-the-azure_ai-extension)
  - [Inspect the objects contained within the `azure_ai` extension](#inspect-the-objects-contained-within-the-azure_ai-extension)
  - [Generate vector embeddings with Azure OpenAI](#generate-vector-embeddings-with-azure-openai)
    - [Set the Azure OpenAI endpoint and key](#set-the-azure-openai-endpoint-and-key)
    - [Populate the database with sample data](#populate-the-database-with-sample-data)
    - [Enable vector support](#enable-vector-support)
  - [Integrate Azure Cognitive Services](#integrate-azure-cognitive-services)
    - [Retrieve Azure Cognitive Services endpoint and key](#retrieve-azure-cognitive-services-endpoint-and-key)
  - [Conclusion](#conclusion)
  - [Additional resources](#additional-resources)

**APPLIES TO**: Azure Database for PostgreSQL - Flexible Server

The `azure_ai` extension adds the ability to leverage [large language models](https://learn.microsoft.com/training/modules/fundamentals-generative-ai/3-language%20models) (LLMs) and build [generative AI](https://learn.microsoft.com/training/paths/introduction-generative-ai/) applications within an Azure Database for PostgreSQL - Flexible Server database by integrating the power of [Azure AI services](https://learn.microsoft.com/azure/ai-services/what-are-ai-services). Generative AI is a form of artificial intelligence in which LLMs are trained to generate new original content based on natural language input. By adding these capabilities to a database, generative AI enables natural language queries to return appropriate responses in a variety of formats such as natural language, images, or code.

This tutorial showcases how to add rich AI capabilities to an Azure Database for PostgreSQL - Flexible Server using the `azure_ai` extension. It covers integrating both [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) and the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/) into your database using the extension.

## Prerequisites

   1. An Azure subscription - [Create one for free](https://azure.microsoft.com/free/cognitive-services?azure-portal=true).
   2. Access granted to Azure OpenAI in the desired Azure subscription. Currently, access to this service is granted only by application. You can apply for access to Azure OpenAI by completing the form at <https://aka.ms/oai/access>. Open an issue on this repo to contact us if you have an issue.
   3. An Azure OpenAI resource with the `text-embedding-ada-002` (Version 2) model deployed. The deployment should be named `embeddings`. This model is currently only available in [certain regions](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability). If you do not have a resource, the process for creating one is documented in the [Azure OpenAI resource deployment guide](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource).
   4. A multi-service resource for Azure AI services. If you do not have a resource, you can provision one by following the [create a multi-service resource for Azure AI services quick](https://learn.microsoft.com/azure/ai-services/multi-service-resource?tabs=macos&pivots=azportal).
   5. An Azure Database for PostgreSQL - Flexible Server instance in your Azure subscription. If you do not have a resource, use either the [Azure portal](https://learn.microsoft.com/azure/postgresql/flexible-server/quickstart-create-server-portal) or the [Azure CLI](https://learn.microsoft.com/azure/postgresql/flexible-server/quickstart-create-server-cli) guide for creating one.

## Connect to the database using `psql` in the Azure Cloud Shell

Open the [Azure Cloud Shell](https://shell.azure.com/) in a web browser. Select **Bash** as the environment and, if prompted, select the subscription you used for your Azure Database for PostgreSQL - Flexible Server database, then select **Create storage**.

To retrieve the database connection details, navigate to your Azure Database for PostgreSQL - Flexible Server resource in the [Azure portal](https://portal.azure.com/). From the left-hand navigation menu, select **Connect** under **Settings** and copy the **Connection details** block. Paste the copied environment variable declaration lines into the Azure Cloud Shell terminal you opened above, replacing the `{your-password}` token with the password you set when creating the database.

```bash
export PGHOST={your-server-name}.postgresql.database.azure.com
export PGUSER={your-user-name}
export PGPORT=5432
export PGDATABASE={your-database-name}
export PGPASSWORD="{your-password}"
```

Add one additional environment variable to require an SSL connection to the database.

```bash
export PGSSLMODE=require
```

Connect to your database using the [psql command-line utility](https://www.postgresguide.com/utilities/psql/) by entering `psql` at the prompt.

## Install the `azure_ai` extension

The `azure_ai` extension enables you to integrate Azure OpenAI and Azure Cognitive Services into your database. To enable and use the `azure_ai` extension in your database, follow the steps below:

   1. Add the extension to your allowlist as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).
   2. Verify that the extension was successfully added to the allowlist by running `SHOW azure.extensions;` from the `psql` command prompt.
   3. Install the `azure_ai` extension using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

## Inspect the objects contained within the `azure_ai` extension

To better understand the capabilities provided by the extension, you can use the [`\dx` meta-command](https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMAND-DX-LC) from the `psql` command prompt. Run the following command to list the objects contained within the `azure_ai` extension:

```psql
\dx+ azure_ai
```

Based on the output, installing the `azure_ai` extension creates three schemas in the database as well as multiple functions and types. The table below details the three schemas added and provides a description of the purpose of each:

| Schema            | Description |
| ----------------- | ----------- |
| `azure_ai`        | The principal schema where the configuration table and user-defined functions (UDFs) used to interact with it reside. |
| `azure_openai`    | Contains the UDFs that enable calling an Azure OpenAI endpoint. |
| `azure_cognitive` | Provides UDFs and composite types related to integrating the database with Azure Cognitive Services. |

Next, take a look at the functions associated with the `azure_ai` schema by running the following `\df` meta-command. The included `\x` commands toggle the expanded display on and off to make it easier to view the output from the command.

```sql
\x
\df+ azure_ai.*
\x
```

These functions provide the mechanism for setting and retrieving the service endpoints and API keys required to connect your database to Azure OpenAI and Cognitive Services. You can also get the version of the extension.

The `azure_ai.set_setting()` function allows you to set the endpoint and key values for Azure AI services. It accepts a **key** and the **value** to assign it. The `azure_ai.get_setting()` function provides a way to retrieve the values you set with the `set_settings()` function. It accepts the **key** of the setting you want to view. For both functions, the key must be one of the following:

- `azure_openai.endpoint`: A supported OpenAI endpoint (e.g., <https://example.openai.azure.com>).
- `azure_openai.subscription_key`: A subscription key for an OpenAI resource.
- `azure_cognitive.endpoint`: A supported Cognitive Services endpoint (e.g., <https://example.cognitiveservices.azure.com>).
- `azure_cognitive.subscription_key`: A subscription key for a Cognitive Services resource.

Examples of how to use the `set_settings()` function to configure the endpoint and API key for Azure Open AI:

```sql
SELECT azure_ai.set_setting('azure_openai.endpoint','https://<endpoint>.openai.azure.com');
SELECT azure_ai.set_setting('azure_openai.subscription_key', '<API Key>');
```

An example of how to retrieve the endpoint and API key for Azure Open AI:

```sql
SELECT azure_ai.get_setting('azure_openai.endpoint');
```

Because the connection information for Azure AI services, including API keys, is stored in the database by the extension, the `azure_ai` extension defines a role called `azure_ai_settings_manager` to ensure this information is protected and accessible only to users assigned that role. This role enables reading and writing of settings related to the extension. Only superusers and members of the `azure_ai_settings_manager` role can invoke the `azure_ai.get_settings()` and `azure_ai.set_settings()` functions. In Azure Database for PostgreSQL - Flexible Server, all admin users are assigned the `azure_ai_settings_manager` role.

## Generate vector embeddings with Azure OpenAI

The `azure_ai` extension's `azure_openai` schema enables the use of Azure OpenAI for creating vector embeddings for text values. Using this schema, you can invoke [Azure OpenAI embeddings](https://learn.microsoft.com/azure/ai-services/openai/reference#embeddings) directly from the database to create vector representations of input, which can then be used in vector similarity searches, as well as consumed by machine learning models.

### Set the Azure OpenAI endpoint and key

Before you can use the `azure_openai` functions, you must configure the extension with your service endpoint and key. Navigate to your Azure OpenAI resource in the Azure portal and select the **Keys and Endpoint** item under **Resource Management** from the left-hand menu. Copy your endpoint and access key. You can use either `KEY1` or `KEY2`. Always having two keys allows you to securely rotate and regenerate keys without causing service disruption.

In the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal, then run the commands from the `psql` command prompt to add your values to the configuration table.

```sql
SELECT azure_ai.set_setting('azure_openai.endpoint','{endpoint}');
SELECT azure_ai.set_setting('azure_openai.subscription_key', '{api-key}');
```

You can verify the settings in the configuration table by using the `azure_ai.get_setting()` function.

```sql
SELECT azure_ai.get_setting('azure_openai.endpoint');
SELECT azure_ai.get_setting('azure_openai.subscription_key');
```

### Populate the database with sample data

This tutorial uses the `bill_sum_data.csv` file that can be downloaded from the [Azure Samples GitHub repo](https://github.com/Azure-Samples/Azure-OpenAI-Docs-Samples/blob/main/Samples/Tutorials/Embeddings/data/bill_sum_data.csv). This CSV file contains a small subset of the [BillSum dataset](https://github.com/FiscalNote/BillSum), which provides a list of United States Congressional and California state bills.

To host the sample data, create a table named `bill_summaries`.

```sql
CREATE TABLE bill_summaries
(
    id bigint PRIMARY KEY,
    bill_id text,
    bill_text text,
    summary text,
    title text,
    text_len bigint,
    sum_len bigint
);
```

Using the PostgreSQL [COPY command](https://www.postgresql.org/docs/current/sql-copy.html) from the `psql` command prompt, load the sample data from the CSV into the `bill_summaries` table, specifying that the first row of the CSV file is a header row.

```sql
\COPY bill_summaries (id, bill_id, bill_text, summary, title, text_len, sum_len) FROM PROGRAM 'curl "https://raw.githubusercontent.com/Azure-Samples/Azure-OpenAI-Docs-Samples/main/Samples/Tutorials/Embeddings/data/bill_sum_data.csv"' WITH CSV HEADER ENCODING 'UTF8'
```

### Enable vector support

Prior to using the `azure_ai` extension to generate embeddings, you must install the `pg_vector` extension by following the guidance in the [enable vector support in your database](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector#enable-extension) documentation. The `pg_vector` extension provides the ability to store your generated vectors alongside the rest of your data.

With vector supported added to your database, add a new column to the `bill_summaries` table using the `vector` data type to stored embeddings within the table. The `text-embedding-ada-002` model you used to deploy your `embeddings` model produces vectors with 1536 dimensions, so you need to specify `1536` as the vector size.

```sql
ALTER TABLE bill_summaries
ADD COLUMN bill_vector vector(1536);
```

6. TODO: Inspect the functions and types associated with the `azure_openai` schema.

    ```sql
    \df+ azure_openai.*
    ```

    ```sql
    List of functions
    -[ RECORD 1 ]-------+----------------------------------------------------------------------------------------------------------
    Schema              | azure_openai
    Name                | create_embeddings
    Result data type    | real[]
    Argument data types | deployment_name text, input text, timeout_ms integer DEFAULT 3600000, throw_on_error boolean DEFAULT true
    Type                | func
    Volatility          | immutable
    Parallel            | safe
    Owner               | azuresu
    Security            | invoker
    Access privileges   | 
    Language            | c
    Source code         | create_embeddings_scalar_wrapper
    Description         |
    ```

    TODO: Talk about the above output, specifically point out the argument data types, and what we need to pass into the function to generate embeddings. (e.g., deployment_name and the input text)

    The table is now ready to store embeddings for the `bill_text` field. Using the `azure_openai.create_embeddings()` function, insert embeddings for the `bill_text` column into the newly created `bill_vector` column in the `bill_summaries` table.

    TODO: Need to provide instructions above to create a `text-embedding-ada-002` embeddings model in Azure OpenAI and name it `embeddings`, as that is what must be referenced below.

    ```sql
    UPDATE bill_summaries b
    SET bill_vector = azure_openai.create_embeddings('embeddings', b.bill_text);
    ```

TODO: Look at a record...

TODO: Switch to `\x` first, as it prints a bit cleaner.

```sql
SELECT bill_id, bill_vector FROM bill_summaries LIMIT 1;
```

Create an index on `bill_summaries` using `hnsw` (session_embedding_vector_cosine_ops).

    TODO: the addition of HNSW, `pg_vector` can use the latest graph based algorithms to approximate nearest neighbor queries. HNSW is short for Hierarchical Navigable Small World.
    TODO: Add link to HNSW details, for those interested...

```sql
CREATE INDEX ON bill_summaries USING hnsw (bill_vector vector_cosine_ops);
```

Execute a query against the database to find bills that match a cosine similarity search.

```sql
SELECT bill_id, title, summary FROM bill_summaries
ORDER BY bill_vector <=> azure_openai.create_embeddings('embeddings', 'Show me bills relating to veterans entrepreneurship.')::vector
LIMIT 3;
```

## Integrate Azure Cognitive Services

### Retrieve Azure Cognitive Services endpoint and key

To successfully make calls against Azure AI services using the `azure_ai` extension, you must provide an endpoint and key for each service. Go to your Cognitive Services resource in the Azure portal and select the **Keys and Endpoint** item under **Resource Management** from the left-hand menu. Copy your endpoint and access key. You can use either `KEY1` or `KEY2`. Always having two keys allows you to securely rotate and regenerate keys without causing service disruption.

In the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal, then run the commands from the `psql` command prompt to add your values to the configuration table.

```sql
SELECT azure_ai.set_setting('azure_cognitive.endpoint','{endpoint}');
SELECT azure_ai.set_setting('azure_cognitive.subscription_key', '{api-key}');
```

TODO: Inspect the functions and types associated with the `azure_cognitive` schema.

- azure_cognitive functions:

    ```sql
    \df+ azure_cognitive.*
    ```

- azure_cognitive types:

    ```sql
    \dT+ azure_cognitive.*
    ```

1. Configure the extension.
   1. Provide endpoints and keys to Azure Cognitive Services.
2. Database setup.
   1. Create any necessary tables and objects.
3. Call out to various Cognitive Services endpoints:
   1. PII detection
   2. Sentiment analysis
   3. Language detection
   4. etc.

## Conclusion

Congratulations, you just learned how to leverage the `azure_ai` extension to integrate generative AI capabilities into your database and applications.

## Additional resources

- [How to use PostgreSQL extensions in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions)
- [Azure OpenAI Service embeddings models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings-models-1)
- [Understand embeddings in Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/concepts/understand-embeddings)


1. 

   1. 
2. Integrate Azure Cognitive Services.
   
3. Clean up resources.
