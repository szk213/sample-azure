
export const EnvironmentVariableKey = {
    FUNCTION_URL: 'FUNCTION_URL',
    FUNCTION_KEY: 'FUNCTION_KEY'
}
type EnvironmentVariableKey = typeof EnvironmentVariableKey[keyof typeof EnvironmentVariableKey];


export const getEnvironmentVariable = (key:EnvironmentVariableKey): string =>
{
  const value = process.env[key];
  if(null != value){
    return value
  }
  throw new Error(`Environment variable ${key} is not set`)
}
