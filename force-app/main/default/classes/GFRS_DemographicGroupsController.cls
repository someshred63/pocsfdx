/**
* @author GFRS Dev Team
* @date 07/09/2016
* @description GFRS_DemographicGroupsController class - controller for GFRS_DemographicGroups page. 
*/
public with sharing class GFRS_DemographicGroupsController
{
    public GFRS_Demographic_Group__c demographicGroup { get; set; }
    public GFRS_Funding_Request__c fundReq {get; set;}
    public String ageValue {get;set;}
    public String sexualIdentityValue {get;set;}
    public String raceEthnicityValue {get;set;}
    public String socialEconomicStatusValue {get;set;}
    public String healthInsuranceValue {get;set;}
    public String workStatusValue {get;set;}
    public String supportESLValue {get;set;}
    public Boolean isEditable { get; set; }    

    /**
    * @author GFRS Dev Team
    * @date 07/09/2016
    * @description Constructor of the class. 
    */
    public GFRS_DemographicGroupsController( ApexPages.StandardController std ){

        String funding_request_id = ApexPages.currentPage().getParameters().get('request_id');

        try {            
            fundReq = [ select Id, Name, Record_Type_Name__c, Information_Needed__c,
                (select id, name, gFRS_Funding_Request__c, Age__c, Sexual_Identity__c, Race_and_Ethnicity__c, Social_and_Economic_Status__c, Health_and_Insurance_Status__c, Work_Status__c, Support_ESL_NonEnglish__c from GFRS_Demographic_Groups1__r)
                from GFRS_Funding_Request__c where id = :funding_request_id limit 1];
            
            isEditable = gFRS_Util.multiSelectHasItem( this.fundReq.Information_Needed__c, 'Application' );
            if (fundReq.GFRS_Demographic_Groups1__r.size() > 0){
                demographicGroup = fundReq.GFRS_Demographic_Groups1__r[0];
            } else {
				demographicGroup = new GFRS_Demographic_Group__c();
				demographicGroup.gFRS_Funding_Request__c = funding_request_id;
			}
        } catch( Exception err ){
            System.debug( 'Unable to load organization and funding request info:' + err.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading demographic data.' ));
            return;
        }
    }

    public void setDemographicGroupItemsValues(){
        if (!String.isBlank(ageValue)){
            demographicGroup.Age__c = ageValue;
        }
        if (!String.isBlank(sexualIdentityValue)){
            demographicGroup.Sexual_Identity__c = sexualIdentityValue;
        }
        if (!String.isBlank(raceEthnicityValue)){
            demographicGroup.Race_and_Ethnicity__c = raceEthnicityValue;
        }
        if (!String.isBlank(socialEconomicStatusValue)){
            demographicGroup.Social_and_Economic_Status__c = socialEconomicStatusValue;
        }
        if (!String.isBlank(healthInsuranceValue)){
            demographicGroup.Health_and_Insurance_Status__c = healthInsuranceValue;
        }
        if (!String.isBlank(workStatusValue)){
            demographicGroup.Work_Status__c = workStatusValue;
        }
        if (!String.isBlank(supportESLValue)){
            demographicGroup.Support_ESL_NonEnglish__c = supportESLValue;
        }

    }

    public ApexPages.PageReference next(){
        return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_PROGRAM, fundReq, '' ) ));   
    }

    public ApexPages.PageReference back(){
        if(gFRS_Util.checkIfThirdPartyVisible(fundReq)){
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_THIRDPARTY, fundReq, '')));
        } else {
            return( new ApexPages.PageReference( gFRS_Util.initializeLink( gFRS_Util.PATH_APPLICATION, fundReq, '')));
        }
    }

    public ApexPages.PageReference savePage(){
       
        try {
        	upsert demographicGroup;

        } catch ( DmlException dErr ) {
            System.debug('getDmlFieldNames(0): '+dErr.getDmlFieldNames(0));
            if(dErr.getDmlFieldNames(0).size() == 0){
                ApexPages.addMessage(  new ApexPages.Message(ApexPages.Severity.ERROR, gFRS_Util.getPrettyMessage(dErr) ) );
            }
            return( null );
        }
        return( next() );
    }

        
}