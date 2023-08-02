//
//
//

public class SCM_Security {
    public static String SCM_AuthenticateNonDefault(){
        SCM_WebServices.SpringCMServiceSoap SCM = new SCM_WebServices.SpringCMServiceSoap();
        try {
            String token = SCM.AuthenticateNonDefault(GetUsername(),GetPassword(),GetAccountID(), GetApiKey());
            return token;
        }
        catch (Exception ex) {
            SCM_LogError.sendEmail(ex,'');
            return null;
        }
    }
    
    private static String GetUsername() {
                
        return getEnvironmentVariable('SCM_Username',getEnvironmentByUsername());
    }
    
    private static String GetPassword() {
              
        return getEnvironmentVariable('SCM_Password',getEnvironmentByUsername());
    }
    
    private static String GetAccountID() {
               
       return getEnvironmentVariable('SCM_AccountID',getEnvironmentByUsername());
    }
    
    public static Boolean SendPerformanceEmail {
        get {
            return (getEnvironmentVariable('SCM_Performance_Email', getEnvironmentByUsername()).toLowerCase() == 'yes') ? true : false ;
        }
    }

    public static Boolean SendExceptionEmail {
        get {
            return (getEnvironmentVariable('SCM_Exception_Email', getEnvironmentByUsername()).toLowerCase() == 'yes') ? true : false ;
        }
    }

    private static String GetApiKey() {
        return '5E73BCDA-782E-48F6-904C-5E2CE8E43988';
    }

    public static string getEnvironmentByUsername()
    { 
        string userName = userinfo.getUserName();
        
	    if(userName.indexOf('.com.dev') > 0)
	        return 'dev';
	    else if(userName.indexOf('.com.sqa') > 0)
	        return 'sqa';
	    else if(userName.indexOf('.com.uat') > 0)
	        return 'uat';
	    else if(userName.indexOf('.com.misc') > 0)
	        return 'misc';
	    else if(userName.indexOf('.com.ord') > 0)
	        return 'ord';
	    else if(userName.indexOf('.com.sfa') > 0)
	        return 'sfa';
	    else if(userName.indexOf('.com.cmr2') > 0)
	       return 'cmr2';
	    else if(userName.indexOf('.com.trn') > 0)
	        return 'trn';
	    else if(userName.endswith('.com'))
	        return 'prod';
	    else if(userName.indexOf('@gene.com.') >0)
	    	return userName.Substring(userName.indexOf('@gene.com.')+10, userName.length());    
	    else return 'prod';
	}

	public static string getEnvironmentVariable(string key,string env){
		string vlu = '';
		
		try {
	    	vlu = [Select Environment__c, Key__c, Value__c from Environment_Variables__c where Key__c = :key and Environment__c = :env][0].value__c;
		}
        catch (Exception ex) {
            SCM_LogError.sendEmail(ex,'Key "' + key + '" was not found');
            throw ex;
        }
        
	    return vlu; 
	} 

	public static string getEnvironmentVariable(string key){
	    string env = getEnvironmentByUsername();

	    return getEnvironmentVariable(key,env); 
	} 
}