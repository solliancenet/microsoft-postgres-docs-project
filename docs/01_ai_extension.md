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
    - [Generate and store vectors](#generate-and-store-vectors)
  - [Integrate Azure Cognitive Services](#integrate-azure-cognitive-services)
    - [Set the Azure AI Language service endpoint and key](#set-the-azure-ai-language-service-endpoint-and-key)
    - [Summarize bills](#summarize-bills)
    - [Extract key phrases](#extract-key-phrases)
  - [Clean up resources](#clean-up-resources)
  - [Conclusion](#conclusion)
  - [Additional resources](#additional-resources)

**APPLIES TO**: Azure Database for PostgreSQL - Flexible Server

The `azure_ai` extension adds the ability to leverage [large language models](https://learn.microsoft.com/training/modules/fundamentals-generative-ai/3-language%20models) (LLMs) and build [generative AI](https://learn.microsoft.com/training/paths/introduction-generative-ai/) applications within an Azure Database for PostgreSQL - Flexible Server database by integrating the power of [Azure AI services](https://learn.microsoft.com/azure/ai-services/what-are-ai-services). Generative AI is a form of artificial intelligence in which LLMs are trained to generate original content based on natural language input. Using the `azure_ai` extension allows you to take advantage of generative AI's natural language query processing capabilities directly from the database.

This tutorial showcases how to add rich AI capabilities to an Azure Database for PostgreSQL - Flexible Server using the `azure_ai` extension. It covers integrating both [Azure OpenAI](https://learn.microsoft.com/azure/ai-services/openai/overview) and the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/) into your database using the extension.

## Prerequisites

   1. An Azure subscription - [Create one for free](https://azure.microsoft.com/free/cognitive-services?azure-portal=true).
   2. Access granted to Azure OpenAI in the desired Azure subscription. Currently, access to this service is granted only by application. You can apply for access to Azure OpenAI by completing the form at <https://aka.ms/oai/access>. Open an issue on this repo to contact us if you have an issue.
   3. An Azure OpenAI resource with the `text-embedding-ada-002` (Version 2) model deployed. This model is currently only available in [certain regions](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#model-summary-table-and-region-availability). If you do not have a resource, the process for creating one is documented in the [Azure OpenAI resource deployment guide](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource).
   4. An [Azure AI Language](https://learn.microsoft.com/azure/ai-services/language-service/overview) service. If you do not have a resource, you can [create a Language resource](https://portal.azure.com/#create/Microsoft.CognitiveServicesTextAnalytics) in the Azure portal by following the instructions provided in the [quickstart for summarization](https://learn.microsoft.com/azure/ai-services/language-service/summarization/custom/quickstart#create-a-new-resource-from-the-azure-portal) document. You can use the free pricing tier (`Free F0`) to try the service, and upgrade later to a paid tier for production.
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

Connect to your database using the [psql command-line utility](https://www.postgresguide.com/utilities/psql/) by entering the following at the prompt.

```bash
psql
```

## Install the `azure_ai` extension

**TODO**: Add link to existing doc for installing the extension.

The `azure_ai` extension provides the ability to integrate Azure OpenAI and Azure Cognitive Services into your database. To install and use the `azure_ai` extension, follow the steps below:

   1. Add the extension to your allowlist as described in [how to use PostgreSQL extensions](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions#how-to-use-postgresql-extensions).
   2. Verify that the extension was successfully added to the allowlist by running `SHOW azure.extensions;` from the `psql` command prompt.
   3. Install the `azure_ai` extension using the [CREATE EXTENSION](https://www.postgresql.org/docs/current/sql-createextension.html) command.

## Inspect the objects contained within the `azure_ai` extension

To better understand the capabilities provided by the extension, you can use the [`\dx` meta-command](https://www.postgresql.org/docs/current/app-psql.html#APP-PSQL-META-COMMAND-DX-LC) from the `psql` command prompt. Run the following command to list the objects contained within the `azure_ai` extension:

```psql
\dx+ azure_ai
```

Based on the schema listed in the output, installing the `azure_ai` extension creates three schemas in the database. It also adds multiple functions and composite types. The table below lists the schemas in the extension and provides a description of each:

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

> Important
>
> Because the connection information for Azure AI services, including API keys, is stored in a configuration table in the database, the `azure_ai` extension defines a role called `azure_ai_settings_manager` to ensure this information is protected and accessible only to users assigned that role. This role enables reading and writing of settings related to the extension. Only superusers and members of the `azure_ai_settings_manager` role can invoke the `azure_ai.get_setting()` and `azure_ai.set_setting()` functions. In Azure Database for PostgreSQL - Flexible Server, all admin users are assigned the `azure_ai_settings_manager` role.

The `azure_ai.set_setting()` function allows you to set the endpoint and key values for Azure AI services. It accepts a **key** and the **value** to assign it. The `azure_ai.get_setting()` function provides a way to retrieve the values you set with the `set_setting()` function. It accepts the **key** of the setting you want to view. For both functions, the key must be one of the following:

- `azure_openai.endpoint`: A supported OpenAI endpoint (e.g., <https://example.openai.azure.com>).
- `azure_openai.subscription_key`: A subscription key for an OpenAI resource.
- `azure_cognitive.endpoint`: A supported Cognitive Services endpoint (e.g., <https://example.cognitiveservices.azure.com>).
- `azure_cognitive.subscription_key`: A subscription key for a Cognitive Services resource.

For example, to configure the endpoint and API key for an Azure Open AI service, you would run the following:

```sql
SELECT azure_ai.set_setting('azure_openai.endpoint','https://example.openai.azure.com');
SELECT azure_ai.set_setting('azure_openai.subscription_key', '<API Key>');
```

And the following `get_setting()` function call shows an example of how to retrieve the endpoint associated with Azure Open AI:

```sql
SELECT azure_ai.get_setting('azure_openai.endpoint');
```

## Generate vector embeddings with Azure OpenAI

The `azure_ai` extension's `azure_openai` schema enables the use of Azure OpenAI for creating vector embeddings for text values. Using this schema, you can invoke [Azure OpenAI embeddings](https://learn.microsoft.com/azure/ai-services/openai/reference#embeddings) directly from the database to create vector representations of input, which can then be used in vector similarity searches, as well as consumed by machine learning models.

Embeddings are a technique of using machine learning models to evaluate how closely related information is. This allows for efficient identification of relationships and similarities between data, allowing algorithms to identify patterns and make accurate predictions.

### Set the Azure OpenAI endpoint and key

Before you can use the `azure_openai` functions, you must configure the extension with your Azure OpenAI service endpoint and key. Navigate to your Azure OpenAI resource in the Azure portal and select the **Keys and Endpoint** item under **Resource Management** from the left-hand menu. Copy your endpoint and access key. You can use either `KEY1` or `KEY2`. Always having two keys allows you to securely rotate and regenerate keys without causing service disruption.

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

This tutorial uses the `bill_sum_data.csv` file to provide sample data. It can be downloaded from the [Azure Samples GitHub repo](https://github.com/Azure-Samples/Azure-OpenAI-Docs-Samples/blob/main/Samples/Tutorials/Embeddings/data/bill_sum_data.csv). This CSV file contains a small subset of the [BillSum dataset](https://github.com/FiscalNote/BillSum), which provides a list of United States Congressional and California state bills.

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

The `azure_ai` extension allows you to generate embeddings for input text. To enable the generated vectors to be stored alongside the rest of your data in the database, you must install the `pg_vector` extension by following the guidance in the [enable vector support in your database](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-use-pgvector#enable-extension) documentation.

With vector supported added to your database, add a new column to the `bill_summaries` table using the `vector` data type to store embeddings within the table. The `text-embedding-ada-002` model produces vectors with 1536 dimensions, so you must specify `1536` as the vector size.

```sql
ALTER TABLE bill_summaries
ADD COLUMN bill_vector vector(1536);
```

### Generate and store vectors

The `bill_summaries` table is now ready to store embeddings. Using the `azure_openai.create_embeddings()` function, you will create vectors for the `bill_text` field and insert them into the newly created `bill_vector` column in the `bill_summaries` table.

Before using the `create_embeddings()` function, running the following command to inspect it and review the required arguments:

```sql
\x
\df+ azure_openai.*
\x
```

The `Argument data types` in the output of the `\df+ azure_openai.*` command reveals the arguments the function expects.

```sql
Argument data types | deployment_name text, input text, timeout_ms integer DEFAULT 3600000, throw_on_error boolean DEFAULT true
```

The first is the `deployment_name`, which was assigned when your embeddings model was deployed in your Azure OpenAI account. To retrieve this value, go to your Azure OpenAI resource in the Azure portal. From there, select the **Model deployments** item under **Resource Management** in the left-hand navigation menu, then select **Manage Deployments** to open Azure OpenAI Studio. On the **Deployments** tab in Azure OpenAI Studio, copy the **Deployment name** value associated with the `text-embedding-ada-002` model deployment.

![The embeddings deployment for the text-embedding-ada-002 model is highlighted on the Deployments tab in Azure OpenAI Studio.](./media/azure_openai_studio_deployments_embeddings.png)

Using this information, update each record in the `bill_summaries` table to add the vector for the `bill_text` field into the `bill_vector` column using the `azure_openai.create_embeddings()` function. This step also replaces newlines (`\n`) with a single space in each input text field, as inferior embeddings results these have been observed when these are present.

```sql
UPDATE bill_summaries b
SET bill_vector = azure_openai.create_embeddings('embeddings', REPLACE(b.bill_text, '\n', ' '));
```

To view the result, execute the following query to inspect a record. You can run `\x` first if the output is difficult to read.

```sql
SELECT bill_id, bill_vector FROM bill_summaries LIMIT 1;
```

Vector similarity is a method used to measure how similar two items are by representing them as vectors, which are series of numbers. Vectors are often used to perform searches using LLMs. Vector similarity is commonly calculated using distance metrics, such as Euclidean distance or cosine similarity. Euclidean distance measures the straight-line distance between two vectors in the n-dimensional space, while cosine similarity measures the cosine of the angle between two vectors. To enable more efficient searching over the `vector` field by creating an index on `bill_summaries` using cosine distance and [HNSW](https://github.com/pgvector/pgvector#hnsw), which is short for Hierarchical Navigable Small World. HNSW allows `pg_vector` to use the latest graph based algorithms to approximate nearest neighbor queries.

```sql
CREATE INDEX ON bill_summaries USING hnsw (bill_vector vector_cosine_ops);
```

With everything now in place, you can now execute a [cosine similarity](https://learn.microsoft.com/azure/ai-services/openai/concepts/understand-embeddings#cosine-similarity) search query against the database.

```sql
SELECT bill_id, title, summary FROM bill_summaries
ORDER BY bill_vector <=> azure_openai.create_embeddings('embeddings', 'Show me bills relating to veterans entrepreneurship.')::vector
LIMIT 3;
```

The query uses the `<=>` [vector operator](https://github.com/pgvector/pgvector#vector-operators), which represents the "cosine distance" operator used to calculate the distance between two vectors in a multi-dimensional space.

## Integrate Azure Cognitive Services

The Azure AI services integrations included in the the `azure_cognitive` schema of the `azure_ai` extension provide rich set of AI Language features accessible directly from the database. The list of functionality includes sentiment analysis, language detection, key phrase extraction, entity recognition, and text summarization. Access to these capabilities is through the [Azure AI Language service](https://learn.microsoft.com/azure/ai-services/language-service/overview).

To view the full list of Azure AI capabilities accessible through the extension, run the following command from the `psql` prompt to display a list of the functions available in the `azure_cognitive` schema.

```sql
\x
\df+ azure_cognitive.*
\x
```

### Set the Azure AI Language service endpoint and key

To successfully make calls against Azure AI services using the `azure_ai` extension, you must provide the endpoint and a key for your Azure AI Language service. Go to your Language service resource in the Azure portal and select the **Keys and Endpoint** item under **Resource Management** from the left-hand menu. Copy your endpoint and access key. You can use either `KEY1` or `KEY2`. Always having two keys allows you to securely rotate and regenerate keys without causing service disruption.

In the command below, replace the `{endpoint}` and `{api-key}` tokens with values you retrieved from the Azure portal, then run the commands from the `psql` command prompt to add your values to the configuration table.

```sql
SELECT azure_ai.set_setting('azure_cognitive.endpoint','{endpoint}');
SELECT azure_ai.set_setting('azure_cognitive.subscription_key', '{api-key}');
```

### Summarize bills

The `azure_cognitive` schema provides two functions for summarizing text, `summarize_abstractive` and `summarize_extractive`. Abstractive summarization produces a summary that captures the main concepts from input text, but may not use the same words. Extractive summarization produces a summary by extracting key sentences from the input text.

To take advantage of the Azure AI Language service's ability to generate new, original content, you can use the `summarize_abstractive()` function to generate a summarization of text input. The `summarize_abstractive()` function looks like the following:

```sql
azure_cognitive.summarize_abstractive(text TEXT, language TEXT)
```

The function requires two arguments, the text to summarize and the language of that text, which is the two-letter ISO 639-1 representation of the language the text is written in. Currently English (`en`) and Spanish (`es`) are supported.

The following query against the `bill_summaries` table uses the function to generate new one-sentence summaries of the text of each bill on the fly, allow you to incorporate the power of generative AI directly into your queries.

```sql
SELECT 
    bill_id,
    array_to_string(azure_cognitive.summarize_abstractive(bill_text, 'en', sentence_count => 1), ' ', '') one_sentence_summary
FROM bill_summaries
WHERE bill_id = '109_s2408' OR bill_id = '108_s1899';
```

THIS DOES NOT WORK.

```sql
SELECT
    bill_id,
    title,
    array_to_string(azure_cognitive.summarize_abstractive(bill_text, 'en', sentence_count => 1), ' ', '') one_sentence_summary
FROM bill_summaries
ORDER BY bill_vector <=> azure_openai.create_embeddings('embeddings', 'Show me bills relating to veterans entrepreneurship.')::vector
LIMIT 1;
```

TODO: This might not be necessary because bulk updates through calls to the extension don't seem to work in this case.

```sql
ALTER TABLE bill_summaries
ADD COLUMN one_sentence_summary text;
```

THIS FAILS. Maybe something to do with the number of simultaneous calls to the Language service endpoint? It works when doing one record at a time.

```sql
UPDATE bill_summaries b
SET one_sentence_summary = array_to_string(azure_cognitive.summarize_abstractive(REPLACE(b.bill_text, '\n', ' '), 'en', sentence_count => 1), ' ', '');
```

THIS ONE IS RETURNING 2 SENTENCES???

```sql
UPDATE bill_summaries b
SET one_sentence_summary = array_to_string(azure_cognitive.summarize_abstractive(REPLACE(b.bill_text, '\n', ' '), 'en', sentence_count => 1), ' ', '')
WHERE bill_id = '109_s2408';
```

```sql
SELECT bill_id, one_sentence_summary FROM bill_summaries;
```

### Extract key phrases

[Key phrase extraction](https://learn.microsoft.com/azure/ai-services/language-service/key-phrase-extraction/overview) in Azure AI extracts the main concepts in a text.


```sql
azure_cognitive.extract_key_phrases(text TEXT, language TEXT) 
```

```sql
SELECT 
    bill_id,
    azure_cognitive.extract_key_phrases(summary, 'en') key_phrases
FROM bill_summaries
WHERE bill_id = '109_s2408' OR bill_id = '108_s1899';
```

## Clean up resources

TODO: Is this needed? It doesn't seem to be in many of the how-to articles (just quickly skimming the docs).

## Conclusion

Congratulations, you just learned how to leverage the `azure_ai` extension to integrate generative AI capabilities into your database.

## Additional resources

- [How to use PostgreSQL extensions in Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-extensions)
- [Azure OpenAI Service embeddings models](https://learn.microsoft.com/azure/ai-services/openai/concepts/models#embeddings-models-1)
- [Understand embeddings in Azure OpenAI Service](https://learn.microsoft.com/azure/ai-services/openai/concepts/understand-embeddings)
