# Azure_AI Extension outline

1. Introduction to the PostgreSQL `azure_ai` extension.
   1. Sentence or two about LLMs and generative AI, with links to additional details.
   2. About the `azure_ai` extension.
      1. Enables the database to make calls to Azure OpenAI and Azure Cognitive Services.
2. Prerequisites (add links for getting these set up)
   1. Create an Azure Database for PostgreSQL server.
   2. Create an Open AI account.
   3. Grant Access to Azure OpenAI.
   4. Grant permissions to [create Azure OpenAI resources and to deploy models](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control).
   5. [Create and deploy an Azure OpenAI service resource and a model](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource?pivots=web-portal), for example deploy the embeddings model `text-embedding-ada-002`.
3. Connect to the PostgreSQL server with psql.
4. Extension installation and setup.
   1. Enable the extension.
      1. "Allow-list" the extension.
      2. Verify extension on "allow-list" using `SHOW azure.extensions`.
      3. Install the extension using the `CREATE EXTENSION`.
   2. Review schemas added by extension.
      1. `azure_ai`
      2. `azure_openai`
      3. `azure_cognitive`
   3. Enable vector support.
      1. Brief intro to vector support in Azure PostgreSQL, with links for additional details.
      2. Install the `vector` extension.
5. Create vector embeddings with Azure OpenAI.
   1. Configure the extension.
      1. Provide endpoints and keys to Azure OpenAI.
      2. Add note mentioning required permissions for configuring the extension (`azure_ai_settings_manager` role).
   2. Database setup.
      1. Create necessary tables.
      2. Load data.
   3. Use `azure_openai` to create embeddings and then store the result using the `vector` data type.
   4. Retrieve rows that match a similarity search.
6. Integrate Azure Cognitive Services.
   1. Configure the extension.
      1. Provide endpoints and keys to Azure Cognitive Services.
   2. Database setup.
      1. Create any necessary tables and objects.
   3. Call out to various Cognitive Services endpoints:
      1. PII detection
      2. Sentiment analysis
      3. Language detection
      4. etc.
7. Clean up resources.
