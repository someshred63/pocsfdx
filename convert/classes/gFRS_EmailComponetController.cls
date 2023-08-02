/**
* @author GFRS Dev Team
* @date 02/06/2014
* @description gFRS_EmailComponetController class - controller for gFRS_PaymentNotificationHelper component. Class is responsible for display correct content depending on funding type 
*/


public without sharing class gFRS_EmailComponetController{

    public Id fundIdController{get;set;}
    
    public String fundTypeController{get;set;}
    
    public gFRS_EmailComponetController(){
    	
    }
    /**
	* @author GFRS Dev Team
	* @date 02/06/2014
	* @description getProperContentId method - return information which contect inside component should be displayed. 
	*/
    public String getProperContentId(){
    	String contentId='0';
        
        
        if(fundIdController != null){
        	if(fundTypeController == 'IMED'){
        		if(new List<GFRS_Funding_Allocation_Line_Item__c>([select Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c, WBS__c from GFRS_Funding_Allocation_Line_Item__c
        		 												   where WBS__c='134.09042' and Funding_Allocation__r.Grant_Request__r.Record_Type_Name__c='IMED'
        		 												   and Funding_Allocation__r.Grant_Request__r.id=:fundIdController]).size()>0){
        	    
        	    		contentId='1';
        		} 
            	
        	}else if(fundTypeController =='HC CHAR'){
        		List<GFRS_Funding_Request__c>  hcFundings=new List<GFRS_Funding_Request__c>();
	            hcFundings=new List<GFRS_Funding_Request__c>([select Therapeutic_Area__c,Therapeutic_Area_Parent__c from GFRS_Funding_Request__c
	            											  where Record_Type_Name__c ='HC CHAR' and id =:fundIdController]);
		        
		        if(hcFundings.size()==0){
		            contentId='0';
		        }else{
		            if( hcFundings[0].Therapeutic_Area__c == 'Lung Cancer' || hcFundings[0].Therapeutic_Area__c == 'Pancreatic Cancer'){
		                contentId='2';
		            }else if(hcFundings[0].Therapeutic_Area__c =='Melanoma'){
		                contentId='3';
		            }else if(hcFundings[0].Therapeutic_Area__c == 'Allergic Asthma' || hcFundings[0].Therapeutic_Area__c=='Asthma'){
		                contentId='4';
		            }
		        }
        	}	
        }
        return contentId;
    }
     
}