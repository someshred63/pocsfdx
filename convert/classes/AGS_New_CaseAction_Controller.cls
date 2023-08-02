public class AGS_New_CaseAction_Controller {
    
    private AGS_Case_Action_gne__c ca = new AGS_Case_Action_gne__c();       
    
    public AGS_New_CaseAction_Controller(ApexPages.StandardController controller) {     
        this.ca = (AGS_Case_Action_gne__c)controller.getRecord(); 
        System.debug('RELATED CASE:'+this.ca.AGS_Case_gne__c);
        this.ca.Action_Status_internal_gne__c = 'Open';
        system.debug('AGS_Confirm_Compliance_des:'+this.ca.AGS_Confirm_Compliance_desc_gne__c);
    }             

    /*public pageReference save(){     
        try {         
            System.debug('ACTION ID:'+this.ca.id);
            insert ca;              
        } catch(System.DMLException e) {
            ApexPages.addMessages(e);
        }                   
        pageReference case_Action_Ref = new PageReference('/'+ca.AGS_Case_gne__c);                
        return case_Action_Ref;             
    }*/
}