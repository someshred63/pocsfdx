@RestResource(urlMapping='/iPhoneManageFieldIntelligence/*')
global with sharing class iPhone_ManageFieldIntelligence implements iPhone_Commons_gne.Runnable{
	
	@HttpPost 
	global static iPhone_Commons_gne.RestResponse processRequest(String unixId, iPhone_Get_Acc_Field_Intelligence_gne.FieldIntelligence record) {		
		return iPhone_Commons_gne.executeAlterData(
			new iPhone_ManageFieldIntelligence(), 
			new ManageFieldIntelligenceRequest(unixId, record)
		);						 																					
	}
	
	class ManageFieldIntelligenceRequest implements iPhone_Commons_gne.BaseArgs {
		public String unixId;
		public iPhone_Get_Acc_Field_Intelligence_gne.FieldIntelligence recordWrapper; 
		
		public ManageFieldIntelligenceRequest(String unixId, iPhone_Get_Acc_Field_Intelligence_gne.FieldIntelligence recordWrapper) {
			this.unixId = unixId;
			this.recordWrapper = recordWrapper;
			
		}
		
		public String getIPhoneRequestId(){
            return recordWrapper != null ? recordWrapper.id : null;
        }
	}
	
	private static String getAnswerUniqueKey(GNE_MCCO_CRM_Field_Intelligence_Answer__c answer){
		system.debug(answer);
		String result = answer.Survey_Question_gne__c;
		system.debug(result);
		if(answer.MCCO_CRM_Survey_Group_gne__c != null){
			result += answer.MCCO_CRM_Survey_Group_gne__c;
		}
		if(answer.Group_Set_gne__c != null){
			result += answer.Group_Set_gne__c;
		}
		system.debug(result);
		return result;
	}
	
	private static String getAnswerUniqueKey(iPhone_Get_Acc_Field_Intelligence_gne.Answer answer){
		String result = answer.sq;
		result += (answer.sg != null ? answer.sg : '');
		result += (answer.gs != null ? answer.gs : '');
		return result;
	}
	
	public Object run(Object arg) {
        ManageFieldIntelligenceRequest request = (ManageFieldIntelligenceRequest)arg;
        GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence = iPhone_DAO.getFieldIntelligence(request.recordWrapper.Id);
        fieldIntelligence.Previous_Status__c = fieldIntelligence.Survey_Status_gne__c;
        fieldIntelligence.Survey_Status_gne__c = request.recordWrapper.fs;
        update fieldIntelligence;
        Map<String, GNE_MCCO_CRM_Field_Intelligence_Answer__c> questionToAnswerMap = new Map<String, GNE_MCCO_CRM_Field_Intelligence_Answer__c>();
        
        for(GNE_MCCO_CRM_Field_Intelligence_Answer__c answer : fieldIntelligence.Field_Intelligence_Answers__r){
        	questionToAnswerMap.put(getAnswerUniqueKey(answer), answer);
        }
        List<GNE_MCCO_CRM_Field_Intelligence_Answer__c> answerToUpsert = new List<GNE_MCCO_CRM_Field_Intelligence_Answer__c>();
         
        for(iPhone_Get_Acc_Field_Intelligence_gne.Answer answerWrapper: request.recordWrapper.answers){
        	GNE_MCCO_CRM_Field_Intelligence_Answer__c answer;
        	
        	if (!questionToAnswerMap.containsKey(getAnswerUniqueKey(answerWrapper))) {
        		answer = new GNE_MCCO_CRM_Field_Intelligence_Answer__c(Field_Intelligence_gne__c = answerWrapper.fi, MCCO_CRM_Survey_Group_gne__c = answerWrapper.sg, Survey_Question_gne__c = answerWrapper.sq, iPhone_Request_Id_gne__c = answerWrapper.rId);
        	} else {
        		answer = questionToAnswerMap.remove(getAnswerUniqueKey(answerWrapper));
        	} 
    		answer.Answer_gne__c = answerWrapper.an;
        	answer.Conditional_Answer_gne__c = answerWrapper.can;
        	if(String.isNotEmpty(answerWrapper.gs)){
        		answer.Group_Set_gne__c = Decimal.valueOf(answerWrapper.gs);
        	}
        	answerToUpsert.add(answer);
        }
        if(!answerToUpsert.isEmpty()){
        	upsert answerToUpsert;
        }
        //we have to remove all answers which has not been send by user (in case of chage group set numbers) - this answers remains in map
        if(!questionToAnswerMap.isEmpty()){
        	delete questionToAnswerMap.values();
        }
        
        return new iPhone_Commons_gne.AlterDataResponse(fieldIntelligence.Id);
    }
}