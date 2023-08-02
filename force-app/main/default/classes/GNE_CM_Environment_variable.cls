global class GNE_CM_Environment_variable
{
    private static final Boolean USE_ALL_ENV = true;
    private static final String ALL_ENV_NAME = 'ALL';
    private static final Map<String,Map<String,List<Environment_Variables__c>>> cache = new Map<String,Map<String,List<Environment_Variables__c>>>();
    
    private static void addVar(String e, String k, Environment_Variables__c v)
    {
        if (e == null || e.trim() == '') {
            return;
        }
        Map<String,List<Environment_Variables__c>> envVars = cache.get(e);
        if (envVars == null) {
            envVars = new Map<String,List<Environment_Variables__c>>();
        }
        List<Environment_Variables__c> keyVars = envVars.get(k);
        if (keyVars == null) {
            keyVars = new List<Environment_Variables__c>();
        }
        keyVars.add(v);
        envVars.put(k,keyVars);
        cache.put(e, envVars);      
    }
    
    private static List<Environment_Variables__c> getVars(String e, String k, Boolean useAllEnv)
    {
        if (e == null || e.trim() == '') {
            return null;
        }
        Map<String,List<Environment_Variables__c>> envVars = cache.get(e);
        if (envVars == null || !envVars.containsKey(k)) {
            if (useAllEnv) {
                return getVars(ALL_ENV_NAME, k , false);
            }
            return null;
        }
        return envVars.get(k);
    }
    
    public static List<Environment_Variables__c> get_env_variable(Set<String> keys)
    {
        try {
            Set<String> envs = new Set<String>();
            String env = GNE_CM_MPS_CustomSettingsHelper.self().getMPSConfig().get(GNE_CM_MPS_CustomSettingsHelper.CM_MPS_CONFIG).Environment_Name__c;
            if (env != null && env.trim() != '') {
                env = env.toUpperCase();
                envs.add(env);              
            }
            if (USE_ALL_ENV) {
                envs.add(ALL_ENV_NAME);
            }
            if (!envs.isEmpty()) {
                List<Environment_Variables__c> vars = new List<Environment_Variables__c>();
                Set<String> missingKeys = new Set<String>();
                if (cache.isEmpty()) {
                    missingKeys.addAll(keys);
                } else {
                    for (String k : keys) {
                        List<Environment_Variables__c> keyVars = getVars(env, k, USE_ALL_ENV);
                        if (keyVars == null) {
                            missingKeys.add(k);
                            continue;
                        }
                        vars.addAll(keyVars);
                    }
                }
                if (!missingKeys.isEmpty()) {
                    for (Environment_Variables__c v : [
                        SELECT Environment__c, Key__c, Value__c FROM Environment_Variables__c WHERE Environment__c IN :envs AND Key__c IN :missingKeys
                    ]) {
                        vars.add(v);
                        addVar(v.Environment__c.toUpperCase(), v.Key__c, v);
                    }
                }
                return vars;
            }
            return new List<Environment_Variables__c>();
        }
        catch (Exception e) {
            system.debug('EXCEPTION: ' + e.getStackTraceString());
            GNE_CM_MPS_Utils.insertError('GNE_CM_Environment_variable', 'Medium', 'get_env_variable', 'Apex Class', 'Error getting env var: ' + e.getMessage());
            return new List<Environment_Variables__c>();
        }
    }
}