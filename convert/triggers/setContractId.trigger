/**
* @File Name:   setContractId
* @Description: This trigger will set a default contract ID for Hemlibra .
* @group:       Apex Trigger
* @Modification Log :
______________________________________________________________________________________
* Ver       Date        Author        Modification
* 1.0       July 26, 2022  Jie
*/
trigger setContractId on PRP_Request__c (after insert) {
    List<PRP_Request__c> requests=new List<PRP_Request__c>();  
    for(PRP_Request__c pos : trigger.new){     
        if(pos.Request_Type__c=='New Request' && pos.Product_Name__c=='Hemlibra' ){
            PRP_Request__c temp=new PRP_Request__c(Id=pos.id);
            String contractID=pos.name.replace('PRP','HRP');
            temp.Contract_ID__c = contractID;
            requests.add(temp);
        }
    }
    UPDATE requests;
}