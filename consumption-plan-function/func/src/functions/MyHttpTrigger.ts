import { app, HttpRequest, HttpResponseInit, InvocationContext } from "@azure/functions";
import { sleep } from '../utils/promise';

export async function MyHttpTrigger(request: HttpRequest, context: InvocationContext): Promise<HttpResponseInit> {
    context.log(`Http function processed request for url "${request.url}"`);

    const name = request.query.get('name') || await request.text() || 'world';

    // await sleep(1000 * 60 * 30)
    await sleep(1000 * 5)

    return { body: `Hello, ${name}!` };
};

app.http('MyHttpTrigger', {
    methods: ['GET', 'POST'],
    authLevel: 'anonymous',
    handler: MyHttpTrigger
});
