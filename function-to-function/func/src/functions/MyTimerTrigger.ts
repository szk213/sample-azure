import { app, InvocationContext, Timer } from "@azure/functions";
import {getEnvironmentVariable, EnvironmentVariableKey} from '../utils/env'

export async function MyTimerTrigger(myTimer: Timer, context: InvocationContext): Promise<void> {
    context.log('[START] Timer function processed request.');
    const url = getEnvironmentVariable(EnvironmentVariableKey.FUNCTION_URL);
    context.log(`url:${url}`);
    try {
        const response = await fetch(url)
        const body = await response.text();
        context.log(`body:${body}`)
    } catch (error) {
        context.log(`error:${error}`)
        context.log(`error-json:${JSON.stringify(error, null, 2)}`)
    }
    context.log('[END] Timer function processed request.');
}

app.timer('MyTimerTrigger', {
    schedule: '0 */5 * * * *',
    handler: MyTimerTrigger
});
