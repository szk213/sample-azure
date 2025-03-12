import { CosmosClient } from "@azure/cosmos";

const endpoint = process.env.COSMOSDB_ENDPOINT;
const key = process.env.COSMOSDB_KEY;
const client = new CosmosClient({ endpoint, key });

(async () => {
  const { database } = await client.databases.createIfNotExists({
    id: "test",
  });
  const { container } = await database.containers.createIfNotExists({
    id: "test",
  });
  const cities = [
    { id: "1", name: "Olympia", state: "WA", isCapitol: true },
    { id: "2", name: "Redmond", state: "WA", isCapitol: false },
    { id: "3", name: "Chicago", state: "IL", isCapitol: false },
  ];
  for (const city of cities) {
    await container.items.create(city);
  }
})();
