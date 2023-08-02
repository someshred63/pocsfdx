global class Utilities 
{
    public static string domainName='gene.com';
    
    public static string ccoManager='ccomanager';
    public static string noSpendUser='nospenduser';

    
    WebService static string getGlobalVariable(String key){
        string envName=getEnvironmentName();
        Environment_Variables__c[] var= [   Select Environment__c, Key__c, Value__c from Environment_Variables__c 
                                        where Key__c = :key and Environment__c =:envName];
        if(var.size()==0) return null;
        else return var[0].Value__c;    
    }
    WebService static string getSControlId(String controlName){
        Scontrol sc=[Select s.DeveloperName, s.Id from Scontrol s where s.DeveloperName=:controlName];
        if(sc==null) return null;
        return sc.Id;
    }
    WebService static string getEnvironmentName(){
        string userName = UserInfo.getUserName();
        if(userName.endsWith(Utilities.domainName)) return 'prod';
        return userName.substring(userName.indexOf(domainName) + domainName.length()+1);
    }
    WebService static void logError(string LogLevel,string Body){
        if(LogLevel.equalsIgnoreCase('WARN')) System.debug(Logginglevel.WARN,Body);
        else if(LogLevel.equalsIgnoreCase('INFO')) System.debug(Logginglevel.INFO,Body);
        else if(LogLevel.equalsIgnoreCase('DEBUG')) System.debug(Logginglevel.DEBUG,Body);
        else if(LogLevel.equalsIgnoreCase('FINE')) System.debug(Logginglevel.FINE,Body);
        else if(LogLevel.equalsIgnoreCase('FINER')) System.debug(Logginglevel.FINER,Body);
        else if(LogLevel.equalsIgnoreCase('FINEST')) System.debug(Logginglevel.FINEST,Body);
        else System.debug(Logginglevel.ERROR,Body);
    }
    WebService static string getProfileName(){
        return [Select Name from Profile where ID=:UserInfo.getProfileId()].Name;
    }
    /*-------------------------Testing Methods-------------------------
    static testMethod void getGlobalVariableTest() {
        System.assertEquals(getGlobalVariable(''),null);
    }
    static testMethod void getEnvironmentNameTest() {
        System.assertEquals(getEnvironmentName(),'sfa');
    }
    */
}