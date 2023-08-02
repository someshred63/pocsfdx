/******************************************************************************************
*  @author: Lukasz Kozminski, Roche
*  Created: 2016-07-22
*  Description: REST Webservice, returns a list of Field Intelligence for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountFieldIntelligence/*')
global with sharing class iPhone_Get_Acc_Field_Intelligence_gne {
	
   @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds) {       
        return iPhone_Commons_gne.buildResponse(
                new GetAccountFieldIntelligenceResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(
                                        lastSyncDate, unixId, accountIds
            )
        );        
    } 
              
    class GetAccountFieldIntelligenceResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                                                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
        		User user = iPhone_DAO.getUserByExternalId(args.unixId);
                return iPhone_DAO.getFieldIntelligence(args.accountIds, user);
        }    
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new FieldIntelligence((GNE_MCCO_CRM_Field_Intelligence__c)sObj);
        }
    }
    
    global class Answer extends iPhone_Commons_gne.DeltaRecord {
        public String an;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Answer_gne__c
        public String can;  // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Conditional_Answer_gne__c
        
        public String nm;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Name
        public String gs;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Group_Set_gne__c
        public String fi;  // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Field_Intelligence_gne__c
        public String sg;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.MCCO_CRM_Survey_Group_gne__c
        public String sq;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.Survey_Question_gne__c
        public String rId;   // GNE_MCCO_CRM_Field_Intelligence_Answer__c.iPhone_Request_Id_gne__c
        
        public Answer(GNE_MCCO_CRM_Field_Intelligence_Answer__c answer){
        	this.id = answer.id;
        	this.an = answer.Answer_gne__c;
        	this.can = answer.Conditional_Answer_gne__c;
        	this.nm = answer.Name;
        	this.gs = iPhone_StringUtil.getString(answer.Group_Set_gne__c);
        	this.fi = answer.Field_Intelligence_gne__c;
        	this.sg = answer.MCCO_CRM_Survey_Group_gne__c;
        	this.sq = answer.Survey_Question_gne__c;
        	this.rId = answer.iPhone_Request_Id_gne__c;
        }
    }
     
    global class FieldIntelligence extends iPhone_Commons_gne.DeltaRecord {
    	public String na;   // GNE_MCCO_CRM_Field_Intelligence__c.Name  
        public String sid;   // GNE_MCCO_CRM_Field_Intelligence__c.Survey_gne__c
        public String st;   // GNE_MCCO_CRM_Field_Intelligence__c.Survey_gne__c.Title_gne__c
        public String sn;   // GNE_MCCO_CRM_Field_Intelligence__c.Survey_gne__c.Notification_gne__c
        
        public String ti;   // GNE_MCCO_CRM_Field_Intelligence__c.Title_gne__c
        public String fs;  // GNE_MCCO_CRM_Field_Intelligence__c.Survey_Status_gne__c
        public String aid;  // GNE_MCCO_CRM_Field_Intelligence__c.Account_gne__c
        
        public String av;   // GNE_MCCO_CRM_Field_Intelligence__c.Available_gne__c
        public String cm;  // GNE_MCCO_CRM_Field_Intelligence__c.Comment_gne__c
        public String ps;   // GNE_MCCO_CRM_Field_Intelligence__c.Previous_Status__c
        public String us;   // GNE_MCCO_CRM_Field_Intelligence__c.User_gne__c
        public String usn;   // GNE_MCCO_CRM_Field_Intelligence__c.User_gne__r.Name
        public String md;   // GNE_MCCO_CRM_Field_Intelligence__c.LastModifiedDate
        public String cd;   // GNE_MCCO_CRM_Field_Intelligence__c.CreatedDate
        public String cb;   // GNE_MCCO_CRM_Field_Intelligence__c.CreatedBy.Name
        public List<Answer> answers; // survey answer
         
        public FieldIntelligence(GNE_MCCO_CRM_Field_Intelligence__c fieldIntelligence) {
            id  = fieldIntelligence.Id;
            na  = fieldIntelligence.Name;
            sid  = fieldIntelligence.Survey_gne__c;
            ti  = iPhone_StringUtil.getString(fieldIntelligence.Title_gne__c);
            fs  = iPhone_StringUtil.getString(fieldIntelligence.Survey_Status_gne__c);
            aid = fieldIntelligence.Account_gne__c;
            av =  iPhone_StringUtil.getString(fieldIntelligence.Available_gne__c);
            cm  = iPhone_StringUtil.getString(fieldIntelligence.Comment_gne__c);
            ps  = iPhone_StringUtil.getString(fieldIntelligence.Previous_Status__c);
            us  = fieldIntelligence.User_gne__c;
            usn  = fieldIntelligence.User_gne__r.Name;
            cb  = fieldIntelligence.CreatedBy.Name;
            md  = iPhone_StringUtil.getString(fieldIntelligence.LastModifiedDate);
            cd  = iPhone_StringUtil.getString(fieldIntelligence.CreatedDate);
            answers = new List<Answer>();
            for(GNE_MCCO_CRM_Field_Intelligence_Answer__c fa: fieldIntelligence.Field_Intelligence_Answers__r){
            	answers.add(new Answer(fa));
            }
        }
    }
}