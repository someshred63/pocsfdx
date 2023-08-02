public with sharing class GNE_SFA2_Question_Ext {
 
   public Question_gne__c qstn{get;set;}
    public GNE_SFA2_Question_Ext(ApexPages.StandardController controller) {
    	 Question_gne__c question = (Question_gne__c)controller.getRecord();
    	 Id qstnId = question.Id;
    	 qstn = [select Id,createdby.name,createddate,LastModifiedBy.Name,lastmodifieddate,Force_Ranking_Value_gne__c,Help_Text_gne__c,Labels_gne__c,Maximum_Score_gne__c,Minimum_Score_gne__c,Multiple_Responses_gne__c,Position_gne__c,Questionnaire_gne__c,Region_Code_gne__c,Category_gne__c,Title_gne__c,Type_gne__c,Values_gne__c,Weight_gne__c from  Question_gne__c where Id=: qstnId ] ;
   }
    
   
    public PageReference edit(){
    	 
    	pagereference pageref = new pagereference('/apex/GNE_SFA2_Question_Edit_Create_Layout?id='+qstn.Id);
        pageref.setredirect(true);
        return pageref;
            	
    }
    
    public PageReference deleteQuestion(){
    	List<Questionnaire_gne__c> questionar = [select Id,No_Edit_gne__c from Questionnaire_gne__c where Id=:qstn.Questionnaire_gne__c];
				if(questionar!=null && questionar.size()>0){
					
					if(questionar[0].No_Edit_gne__c){
						 Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,'This questionnaire is Not Editable, thus no question can be deleted from it.'));
						 return null;
					}
				}
    	
    	try{
    		delete qstn;
    	}
    	catch(exception e){
    		Apexpages.addMessage(new Apexpages.Message(ApexPages.severity.ERROR,e.getMessage()));
    		return null;
    	}
    	
		String retUrl = ApexPages.currentPage().getParameters().get('retURL');
		if(retUrl != null && retUrl != '') {
			PageReference pg = new PageReference(retUrl);
			pg.setredirect(true);
    		return pg;
		} else {
			PageReference pg = new PageReference('/apex/GNE_SFA2_Questionnaires');
			pg.setredirect(true);
    		return pg;
		}	
    	
    }
    
    public PageReference cloneQuestion(){
    	
    	pagereference pageref = new pagereference('/apex/GNE_SFA2_Question_Edit_Create_Layout?id='+qstn.Id+'&isClone=true');
        pageref.setredirect(true);
        return pageref;
            	
    }
    
    
}