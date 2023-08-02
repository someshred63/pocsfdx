/******************************************************************************************
*  @author: Lukasz Kozminski, Roche
*  Created: 2016-07-22
*  Description: REST Webservice, returns a list of Field Intelligence for the current user 
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetUserFieldIntelligence/*')
global with sharing class iPhone_Get_User_Field_Intelligence_gne {
	
   @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId) {       
        return iPhone_Commons_gne.buildResponse(
                new GetUserFieldIntelligenceResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)
        );        
    } 
              
    class GetUserFieldIntelligenceResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
        		User user = iPhone_DAO.getUserByExternalId(args.unixId);
        		return iPhone_DAO.getUserFieldIntelligence(user.Id);
        }    
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new iPhone_Get_Acc_Field_Intelligence_gne.FieldIntelligence((GNE_MCCO_CRM_Field_Intelligence__c)sObj);
        }
    }
}