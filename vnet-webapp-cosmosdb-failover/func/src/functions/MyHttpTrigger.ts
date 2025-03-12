import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { CosmosClient } from "@azure/cosmos";
import { sleep } from '../utils/promise';

export async function MyHttpTrigger(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    const name = request.query.get('name') || await request.text() || 'world';
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


    await sleep(1000 * 5)
    // await sleep(1000 * 5)

    return { body: `Hello, ${name}!` };
};

app.http('MyHttpTrigger', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: MyHttpTrigger
});
