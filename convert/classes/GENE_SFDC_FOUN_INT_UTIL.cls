public class GENE_SFDC_FOUN_INT_UTIL {

    // util class for Foundational Interfaces
    
    public static List<String> getCADSRoleListByRank () {
        // CADS HCP Role Code Rank List from highest to less significant order
        // this func errors out if no config is present                                  
        Environment_variables__c  env_record = [select key__c, value__c from environment_variables__C 
                                               where key__c like 'Account.CADSHCPRoleListByRank' 
                                                     and environment__c = 'all' 
                                                     order by key__c ];

        return env_record.value__c.split(':');                                   
    }
    
    public static Map<String, String> getRoleToProfessionalTypeMapping () {    
        // CADS HCP Role Code - Professional Type Mapping                                  
        Environment_variables__c[] env_list = [select key__c, value__c from environment_variables__C 
                                               where key__c like 'Account.CADSHCPRoleCodeToProfessionalType.%' 
                                                     and environment__c = 'all' 
                                                     order by key__c ];
                                                                               
        Map<String, String> roleToProfessionalTypeMap = new Map<String,String> ();
        for (Environment_variables__c env_var : env_list ) {
            String roleCode = env_var.key__c.split('\\.')[2];
            roleToProfessionalTypeMap.put ( roleCode, env_var.value__c);
        }
        
        return roleToProfessionalTypeMap;
                   
    }           
}