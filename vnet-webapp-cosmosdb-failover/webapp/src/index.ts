import express from "express";
import { CosmosClient } from "@azure/cosmos";

const app = express();

app.use(express.json())
app.use(express.urlencoded({ extended: true }));

app.get("/db", async (_, res) => {
    const endpoint = "";
    const key = "";
    const client = new CosmosClient({ endpoint, key });
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


  res.send("change me to see updates, express, hmr");
});

app.get("/", async (_, res) => {
  res.send("Success!!");
});

if (process.env.NODE_ENV === "production") {
  app.listen(process.env.PORT ? parseInt(process.env.PORT, 10) : 3000);
}

export const viteNodeApp = app;
