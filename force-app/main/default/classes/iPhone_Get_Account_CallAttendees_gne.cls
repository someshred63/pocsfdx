/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Call2 (CallAttendees) for the specified 
*  accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountCallAttendees/*')
global with sharing class iPhone_Get_Account_CallAttendees_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {    
        return iPhone_Commons_gne.buildResponse(
                new GetAccountCallAttendeesResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
        );          
    } 
              
    class GetAccountCallAttendeesResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {
    	
    	private Map<String, String> attTypeValueToLabelMap;
    	
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
        	this.attTypeValueToLabelMap = getAttendeeTypeValueToLabelMap();            
            List<Call2_vod__c> ids = args.isEnhancedDelta() ? iPhone_DeltaDAO.getAttendeeParentCallsIdsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getCallsIdsByAccountIds(args.accountIds);
            return iPhone_DAO.getCallsByParentIds(ids);
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountCallAttendeesRecord((Call2_vod__c)sObj, attTypeValueToLabelMap);
        }      
        
        private Map<String, String> getAttendeeTypeValueToLabelMap() {
     	   Map<String, String> attendeeTypeValueToLabelMap = new Map<String, String>();
        	for (Schema.PicklistEntry plValue : Call2_vod__c.Attendee_Type_vod__c.getDescribe().getPicklistValues()) {
            	attendeeTypeValueToLabelMap.put(plValue.getValue().toUpperCase(), plValue.getLabel());
       		}
        	return attendeeTypeValueToLabelMap;
    	}
    	
    	protected override DeltaCalculator getDeltaCalculator(String lastSyncDate){
            return new GetAccountCallAttendeesDeltaCalculator(lastSyncDate);
        }
    } 
    
    public class GetAccountCallAttendeesDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator {

        public GetAccountCallAttendeesDeltaCalculator(String lastSyncDate) {
            super(lastSyncDate);
        }

        protected override String getDeltaStatus(SObject sObj) {
            if (lastSynchronized == null){ // delta is OFF.
                return null;
            }

            Call2_vod__c call = (Call2_vod__c) sObj;
            Datetime created = call.CreatedDate;
            Datetime lastModified = call.LastModifiedDate;
            Datetime accountLastModified = call.Account_vod__r.iPhone_Fields_LastModifiedDate_gne__c;
            Datetime contactLastModified = call.Contact_vod__r.LastModifiedDate;

            if (created >= lastSynchronized) {
                return STAT_INSERT;     // created AFTER last synchronization.
            }
            else {
                if(lastModified >= lastSynchronized || accountLastModified >= lastSynchronized || contactLastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization.
                }
                else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized).
                }
            }
        }
    }
    
    public class GetAccountCallAttendeesRecord extends iPhone_Commons_gne.DeltaRecord {    	                                
        public String iid; // Call2_vod__c.Parent_Call_vod__c
        public String nm;  // More complex logic, see CallAttendee()
        public String ty;  // Call2_vod__c.Attendee_Type_vod__c         
                           // Id: More complex logic, see constructor code.        
        public String moo; //Call2_vod__c.HCP_Attendee_Meal_Opt_Out_gne__c flag for meal opt out requirements
        public String tid; // target object id - Account, Contact or User
        public String prepst; // Call2_vod__c.PREP_Status_gne__c
        public String pt; // Call2_vod__c.Account_vod__c.PREP_Professional_Type_gne__c
        public String tyl; // Call2_vod__c.Attendee_Type_vod__c label
        public String attContactType; //flag for contact
                 
        public GetAccountCallAttendeesRecord(Call2_vod__c callAttendee, Map<String, String> attTypeValueToLabelMap) {
            this.id =  callAttendee.Id;
            this.iid = iPhone_StringUtil.getString(callAttendee.Parent_Call_vod__c);
            this.prepst = iPhone_StringUtil.getString(callAttendee.PREP_Status_gne__c);            
            this.ty = iPhone_StringUtil.getString(callAttendee.Attendee_Type_vod__c);            
            //when attendee is contact nad HCP
            if(callAttendee.Contact_vod__c != null) {
                this.attContactType = callAttendee.Attendee_Type_vod__c == 'Person_Account_vod' ? 'PERSONACCOUNT' : 'CONTACT';
            }
            
                if(callAttendee.Contact_vod__c != null) {
                    this.tid = iPhone_StringUtil.getString(callAttendee.Contact_vod__c);
                    this.nm = iPhone_StringUtil.getString(callAttendee.Contact_vod__r.Name);
                } else if (callAttendee.Account_vod__c != null) {
                    this.tid = iPhone_StringUtil.getString(callAttendee.Account_vod__c);
                    this.nm = iPhone_StringUtil.getString(callAttendee.Account_vod__r.Name);
                    if (String.isNotBlank(callAttendee.Parent_Call_vod__c) && callAttendee.Parent_Call_vod__r.Interaction_Status_gne__c != 'Completed'){
                        this.prepst = iPhone_StringUtil.getString(callAttendee.Account_vod__r.PREP_Status_gne__c);
                    }
                } else if(callAttendee.User_vod__c != null) {
                    this.tid = iPhone_StringUtil.getString(callAttendee.User_vod__c);
                    this.nm = iPhone_StringUtil.getString(callAttendee.User_vod__r.Name);
                }                               
            

            this.moo =  iPhone_StringUtil.getString(callAttendee.HCP_Attendee_Meal_Opt_Out_gne__c);
                                    
            this.pt = callAttendee.Account_vod__r!=null ? iPhone_StringUtil.getString(callAttendee.Account_vod__r.PREP_Professional_Type_gne__c) : '';
            this.tyl = getCallAttendeeTypeDesc(this.ty, attTypeValueToLabelMap);
        }
        
        private String getCallAttendeeTypeDesc(String attentyType, Map<String, String> attTypeValueToLabelMap){        	
        	String attendeTypeDesc = null;
        	if (String.isNotBlank(attentyType) && attTypeValueToLabelMap.containsKey(attentyType.toUpperCase())){
           		attendeTypeDesc = attTypeValueToLabelMap.get(attentyType.toUpperCase());
        	}
            return attendeTypeDesc;
        }
    }
}