# Azure_AI Extension outline

1. Introduction to the PostgreSQL `azure_ai` extension.
   1. Sentence or two about LLMs and generative AI, with links to additional details.
   2. About the `azure_ai` extension.
      1. Enables the database to make calls to Azure OpenAI and Azure Cognitive Services.
2. Prerequisites (add links for getting these set up)
   1. Create an Open AI account.
   2. Grant Access to Azure OpenAI.
   3. Grant permissions to [create Azure OpenAI resources and to deploy models](https://learn.microsoft.com/azure/ai-services/openai/how-to/role-based-access-control).
   4. [Create and deploy an Azure OpenAI service resource and a model](https://learn.microsoft.com/azure/ai-services/openai/how-to/create-resource?pivots=web-portal), for example deploy the embeddings model `text-embedding-ada-002`.
3. Database setup
   1. Enable the extension.
      1. "Allow-list" the extension.
      2. Verify extension on "allow-list" using `SHOW azure.extensions`.
      3. Install the extension using the `CREATE EXTENSION`.
   2. Review schemas added by extension.
      1. `azure_ai`
      2. `azure_openai`
      3. `azure_cognitive`
   3. Configure the extension.
      1. Provide endpoints and keys to Azure OpenAI / Azure Cognitive Services.
      2. Add note mentioning required permissions for configuring the extension (`azure_ai_settings_manager` role).
   4. Enable vector support.
      1. Brief intro to vector support in Azure PostgreSQL, with links for additional details.
      2. Install the `vector` extension.
4. Vector embeddings with Azure OpenAI
   1. Use `azure_openai` to create embeddings and then store the result using the `vector` data type.
   2. Retrieve rows that match a similarity search.
5. Integrate Azure Cognitive Services