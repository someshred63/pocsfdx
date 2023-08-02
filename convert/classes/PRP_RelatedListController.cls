/**
* @File Name:   PRPM_relatedListController
* @Description: Controller for PRPM_RelatedList Aura component
* @group:       Apex Class
* @Author:     Rabindranath
* @Modification Log  :
______________________________________________________________________________________
* Ver       Date         Modification
* 1.0       2021-10-27   Created the Component
**/

public class PRP_RelatedListController {
    @AuraEnabled
    public static PRP_Request__c retrieveContractInfo(String recordId){
        
        try{
            PRP_Request__c  prpRequest=  [select id,ContractId1__c from PRP_Request__c where  id=:recordId limit 1];
            return prpRequest;
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
     @AuraEnabled
   public static List<PRP_Request__c> getRelatedRecords(String recordId,String contrctId){
        List<PRP_Request__c> cntrcts = new List<PRP_Request__c>();
        List<String> ids = new List<String>();
        try{
            if(String.isNotBlank(contrctId)){
                cntrcts=  [select id,Name,ContractId1__c from PRP_Request__c where  ContractId1__c !='' limit 100000];
            }
            for(PRP_Request__c req : cntrcts){
                if(req.ContractId1__c == contrctId){
                    ids.add(req.Id);
                    for(Integer i = ids.size() - 1; i >= 0; i--) {
                        if(ids[i].equals(recordId)) {
                            ids.remove(i);
                        }
                    }
                }
            }
            List<PRP_Request__c>  allContrct=  [select id,Name,ContractId1__c,ContractId1__r.Name,Request_Status__c,Product_Name__c from PRP_Request__c where  Id IN:ids ];
  	        if (allContrct?.size() > 0)
            {
                return allContrct;
            } 
            else 
            {
                return null;
            }
        }
        catch(exception exp){
            throw new AuraHandledException(exp.getMessage());
        }
    }
}