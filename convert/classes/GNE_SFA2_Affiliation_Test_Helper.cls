/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-08-21
*  Description: This is a helper class for GNE_SFA2_Affiliation_Trigger_Test
*  
*  Modification History
*  Date        Name        Description
*            
*************************************************************/
@isTest
public without sharing class GNE_SFA2_Affiliation_Test_Helper {
    
    public static Integer BATCH_SIZE = 30;
    
    /* helper method used for preparing test data */
    public static List<Account> prepareTestAccounts() {
        List<Account> testData = new List<Account>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            testData.add(new Account(firstName = 'firstName' + i, lastName = 'lastName' + i));
        }
        insert testData;
        return testData;
    }
    
    /* helper method used for preparing test data */
    public static List<Affiliation_vod__c> prepareTestAffiliations(Set<String> emptyFieldNames, Map<String, Object> testFieldValues, 
                                            List<Account> toAccounts, List<Affiliation_vod__c> childAffiliations) {
        List<Affiliation_vod__c> testData = new List<Affiliation_vod__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            Affiliation_vod__c affiliation = new Affiliation_vod__c();
            
            // populate Role_vod__c field
            affiliation.Role_vod__c = (String) getFieldValue('Role_vod__c', emptyFieldNames, testFieldValues);
            // populate Drug_gne__c field
            affiliation.Drug_gne__c = (String) getFieldValue('Drug_gne__c', emptyFieldNames, testFieldValues);  
            // populate From_Account_vod__c field
            affiliation.From_Account_vod__c = (String) getFieldValue('From_Account_vod__c', emptyFieldNames, testFieldValues);          
            // populate From_Contact_vod__c field
            affiliation.From_Contact_vod__c = (String) getFieldValue('From_Contact_vod__c', emptyFieldNames, testFieldValues);
            // populate To_Contact_vod__c field
            affiliation.To_Contact_vod__c = (String) getFieldValue('To_Contact_vod__c', emptyFieldNames, testFieldValues);
            // populate To_Account_vod__c field
            if(toAccounts != null) {
                affiliation.To_Account_vod__c =  toAccounts[i].Id;
            } else {
                affiliation.To_Account_vod__c =  (String) getFieldValue('To_Account_vod__c', emptyFieldNames, testFieldValues);
            }
            // populate Child_affiliation_vod__c field
            if(childAffiliations != null) {
                affiliation.Child_affiliation_vod__c = childAffiliations[i].Id;
            }
            // populate Influence_vod__c field
            affiliation.Influence_vod__c = (String) getFieldValue('Influence_vod__c', emptyFieldNames, testFieldValues);
            
            testData.add(affiliation);
        }
        
        return testData;
    }
    
    /* helper method for getting field value */
    public static Object getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
        Object result = null;
        if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
            result = null;          
        } else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
            result = (Object) testFieldValues.get(fieldName);
        } else {
            result = 'test';
        }
        return result;
    }
    
    static Boolean inAffilTrig = false;
    static Boolean upAffilTrig = false;
    static Boolean isMerge = false;
    static Integer count = 0;
    static List<Boolean> disableTrigger = new List<Boolean>();
    
    public static testMethod void test_VOD_AFFILIATIONS () {
        System.assertEquals (count, 0); 
        incCount();
        System.assertEquals (getCount(), 1);    
        System.assertEquals (getAfilTrig(), false);         
        System.assertEquals (getUpdAfilTrig(), false);   
        
        setAfilTrig(true);      
        
        System.assertEquals (getCount(), 1);    
        System.assertEquals (getAfilTrig(), true);          
        System.assertEquals (getUpdAfilTrig(), false);   
        
        setUpdAfilTrig(true);
        
        System.assertEquals (getCount(), 1);    
        System.assertEquals (getAfilTrig(), true);          
        System.assertEquals (getUpdAfilTrig(), true);    
        
    }  
            
            
    public static void setAfilTrig (Boolean p_inAffilTrig) {
        inAffilTrig = p_inAffilTrig;
    }
    public static Boolean getAfilTrig ()   {
        return inAffilTrig;
    } 

    public static void setUpdAfilTrig (Boolean p_upAffilTrig) {
        upAffilTrig = p_upAffilTrig;
    }
    public static Boolean getUpdAfilTrig ()    {
        return upAffilTrig;
    }
   
    public static List<Boolean> getDisableTrigger()
    {
       return disableTrigger;
    }

    public static void setDisableTrigger(List<Boolean> value)
    {
       disableTrigger = value;
    }
    
    public static void setMerge(boolean value) {
    	isMerge = value;
    }
    public static Boolean getMerge () {
    	return isMerge;
    }

    public static Integer getCount() { return count;}
    public static void incCount() { count++;}
}