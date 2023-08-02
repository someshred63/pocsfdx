/**
 *  Sample Controller to make working with the Sample Template simpler, and to demo various data.
 **/


public with sharing class gFRS_SampleTemplateController {

    public GFRS_Funding_Request__c request          { get; set; }
    public Task[] tasks                             { get; set; } 
    public GFRS_Funding_Allocation__c[] allocations { get; set; }
    public GFRS_Organization__c org                 { get; set; }
    public GFRS_Program__c program                  { get; set; }
    public String caseCondition                     { get; set; }

    /** 
     *  A simple option that can be sent by GET, which can be used to show various
     *  version of the page for a specific condition
     **/

    public gFRS_SampleTemplateController( ApexPages.StandardController std ){
        this.request = (GFRS_Funding_Request__c) std.getRecord();
        
        //-- get the default record if we didn't get one
        if( this.request == null || this.request.id == null ){
        	ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.Error, 'no request was sent by the ID get variable' ));
        	return;
            
        } else { // EMPUC: if page was executed in context of particular record, then other neccesary fields needs to be retrieved
        	this.request = [ SELECT Id, Name, Organization__c FROM GFRS_Funding_Request__c WHERE id = :this.request.id][0];
        }
       
            this.org = [ SELECT Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, Account__c, Type__c, Tax_Status__c, ACCME_Accreditations__c, Other_Accredidations__c, State_Affiliation__c, Gene_Affiliation__c, Tax_Id__c, Is_Part_of_Parent_Org__c, US_Organization__c, Number_of_Employees__c, Roche_Purchaser__c, Roche_Prescriber__c, Medicare_Guideline_Development__c, Physician_Ownership__c, Mission_Statement__c, Geographic_Region_Service_Area__c, Website_Address__c, Description__c, W8BEN_Status__c, Operational_Budget__c, Pending_Litigation__c, of_Physicians_in__c
         FROM GFRS_Organization__c WHERE id = :this.request.Organization__c ][0];
         
        this.program       = new GFRS_Program__c();
        this.caseCondition = gFRS_TestCreationUtils.getCaseCondition();
        
        this.fetchRelatedObjects();
    }

    private void fetchRelatedObjects(){
        
        this.tasks       = [SELECT Id, Subject FROM Task WHERE whatId= :this.request.id ];
        
        this.allocations = [SELECT Id, Name FROM GFRS_Funding_Allocation__c WHERE Request_Name__c = :this.request.id ];
    }
   
}