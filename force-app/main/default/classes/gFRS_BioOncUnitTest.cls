/**
* @author ADMD Team
* @date 13/06/2014
* @description Unit test class for testing BioOnc Wave 2 new profiles changes
*
*/

@isTest(SeeAllData=true)
private  class gFRS_BioOncUnitTest {
	
	
	static testMethod void testDecisionTreeForGNESFAActemraCS()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
    	System.assertEquals(true, ts.profileNameToIdMap.containsKey('GNE-SFA-Actemra-CS'),'Profile GNE-SFA-Actemra-CS need to be created on environment');
    	ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-SFA-BAM'));
            
        System.runAs(ts.objUser)
        { 
        	 ts.setFundingReqestTriggerMode(false);
	         ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
	         ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
	         ts.setFundingReqestTriggerMode(true);
	         
	         String finalUrl= 'apex/GFRS_Decision?loc='+ts.objLoc.id+'&org='+ts.objOrg+'&t=t';
	         PageReference pageRef = new ApexPages.PageReference( finalUrl);
	         Test.setCurrentPage(pageRef);
	         
	         //system.debug(pageRef.getUrl());
	         gFRS_DecisionController dc=new gFRS_DecisionController(new ApexPages.StandardController(new GFRS_Funding_Request__c()));
	         dc.organizationId= ts.objOrg.id;
	        
	         PageReference pageRef2=dc.checkValidPage();
	         
	         System.assertEquals(true,pageRef2.getUrl().contains('GFRS_Application'),'User with this profile should be redirected to application page without decision page selection for profile GNE-SFA-Actemra-CS');
	         
	         GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:pageRef2.getParameters().get('id') ];
	         System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_green.gif'),'Flag Requester-Not Submitted by Field should be always green if user profile contains SFA Phase');
	         
	         
        }
    }
    
    
    
    
    static testMethod void testCheckFlagRequestNotSumnittednByFieldIsGreenForAnySFAEndingWithCS()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
    	
    	ts.objUser = ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-SFA-Lytics-CS'));
            
        System.runAs(ts.objUser)
        { 
        	if(Schema.sObjectType.GFRS_Funding_Request__c.isCreateable()){
        		 ts.setFundingReqestTriggerMode(false);
		         ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
		         ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
		         ts.setFundingReqestTriggerMode(true);
		         
		         GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject( ts.objOrg.Id, ts.objLoc.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		         
		         GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:fundingRequest.id ];
		         System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_green.gif'),'Flag Requester-Not Submitted by Field should be always green if user profile contains SFA Phase and ending CS');
        	}
        }
    }
    
    static testMethod void testCheckFlagRequestNotSumnittednByFieldIsGreenForAnySFAEndingWithDM()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
    	
    	ts.objUser = ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-SFA-Lytics-DM'));
            
        System.runAs(ts.objUser)
        { 
        	if(Schema.sObjectType.GFRS_Funding_Request__c.isCreateable()){
        		 ts.setFundingReqestTriggerMode(false);
		         ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
		         ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
		         ts.setFundingReqestTriggerMode(true);
		         GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject( ts.objOrg.Id, ts.objLoc.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		         
		         GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:fundingRequest.id ];
		         System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_green.gif'),'Flag Requester-Not Submitted by Field should be always green if user profile contains SFA Phase and ending DM');
        	}
        }
    }
    
    
    static testMethod void testCheckFlagRequestNotSumnittednByFieldIsGreenForAnySFAEndingWithManager()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
    	
    	ts.objUser = ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-SFA-Lytics-Manager'));
            
        System.runAs(ts.objUser)
        { 
        	if(Schema.sObjectType.GFRS_Funding_Request__c.isCreateable()){
        		 ts.setFundingReqestTriggerMode(false);
		         ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
		         ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
		         ts.setFundingReqestTriggerMode(true);
		         GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject( ts.objOrg.Id, ts.objLoc.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		         
		         GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:fundingRequest.id ];
		         System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_green.gif'),'Flag Requester-Not Submitted by Field should be always green if user profile contains SFA Phase and ending Manager');
        	}
        }
    }
    
     static testMethod void testCheckFlagRequestNotSumnittednByFieldIsGreenForSpecificProfileGNEMCCOPFT()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
        
        ts.objUser = ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-MCCO-AM'));
            
        System.runAs(ts.objUser)
        { 
            if(Schema.sObjectType.GFRS_Funding_Request__c.isCreateable()){
                 ts.setFundingReqestTriggerMode(false);
                 ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
                 ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
                 ts.setFundingReqestTriggerMode(true);
                 GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject( ts.objOrg.Id, ts.objLoc.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
                 
                 GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:fundingRequest.id ];
                 System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_red.gif'),'Flag Requester-Not Submitted by Field should be always red if user profile is GNE-MCCO-AM');
            }
        }
    }
    
    static testMethod void testCheckFlagRequestNotSumnittednByFieldIsRedForOtherProfiles()
    {
    	SetUpTestObjects ts=new SetUpTestObjects();
    	
    	ts.objUser = ts.objUser = gFRS_UnitTestHelper.createUserWithSpecificProfile(ts.profileNameToIdMap.get('GNE-GFRS-User'));
            
        System.runAs(ts.objUser)
        { 
        	if(Schema.sObjectType.GFRS_Funding_Request__c.isCreateable()){
        		 ts.setFundingReqestTriggerMode(false);
		         ts.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', ts.objAccount.id );
		         ts.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', ts.objOrg.id );
		         ts.setFundingReqestTriggerMode(true);
		         GFRS_Funding_Request__c fundingRequest = gFRS_UnitTestHelper.createFieldInitiatedExhibitsFundingRequestObject( ts.objOrg.Id, ts.objLoc.Id, 'Intake', 'Not Submitted', 'Not Submitted', 'Cardiology', 'Acromegaly', 'Organization;Location;Application;Third Party;Program;Budget;Attachments');
		         
		         GFRS_Funding_Request__c fr=[select Event_Type_Not_Field_Sales__c from GFRS_Funding_Request__c where id =:fundingRequest.id ];
		         System.assertEquals(true,fr.Event_Type_Not_Field_Sales__c.contains('flag_red.gif'),'Flag Requester-Not Submitted by Field should be always red if user profile is not an sfa profile and not ending with CS,DM,Manager');
        	}
        }
    }
    
	 /**
    * @author ADMD Team
    * @date 13/06/2014
    * @description Private class for setting up test data
    * .
    */
    public class SetUpTestObjects
    {
        public Account objAccount;
        public Contact objContact;
        public User objUser {get;set;}
        public GFRS_Organization__c objOrg{get;set;}
        public GFRS_Location__c objLoc{get;set;}
        public Map<String,id> profileNameToIdMap;
        public Map<String,id> profileNameToIdMapGFRSProfiles;
        public List<id> profileIdsMapForSFAProfiles= new List<id>();
        public List<id> profileIdsForNotSFAProfilesWithGreenFlag= new List<id>();
        public id frId; // Funding Request ID
                
        public SetUpTestObjects()
        { 
            try
            {
                //setFundingReqestTriggerMode(false);
                profileNameToIdMap=new Map<String,id>();
                
                
                for(Profile p : [select name,id from profile where name in ('GNE-SFA-Actemra-CS', 'GNE-MCCO-AM', 'GNE-SFA-Lytics-CS','GNE-SFA-BAM',
                													   'GNE-SFA-Lytics-DM', 'GNE-SFA-Lytics-Manager','GNE-GFRS-User')]){
                																
                	profileNameToIdMap.put(p.name,p.id);
                	               																	
                }
                
                this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest'); 
                /*      
                this.objUser = gFRS_UnitTestHelper.CreateInternalGFRSUser();
            
                System.runAs(this.objUser)
                { 
                 this.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', this.objAccount.id );
                 this.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', this.objOrg.id );
                 this.frId = gFRS_UnitTestHelperCorporateMembership.CreateCorpMemberRequestInStatusNew(objOrg.id, objLoc.id,this.objUser);
                }
                */
                //setFundingReqestTriggerMode(true); 
            }
            catch(Exception ex)
            {
                system.debug('SetUpTestObjects exception->' + ex.getMessage());
            }
        }
        
        public void setFundingReqestTriggerMode(boolean mode)
        {
            GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
            myOrgCS.Funding_Request_Trigger_Enabled__c = mode;
            upsert myOrgCS; 
        }
    }

}