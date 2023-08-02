global class getAGSCase_Controller {
        
    public AGS_Case_gne__c agsCase;    
    public getAGSCase_Controller(ApexPages.StandardController controller){
        this.agsCase = (AGS_Case_gne__c)controller.getRecord();
        this.agsCase = [select id, name from AGS_Case_gne__c where id = :ApexPages.currentPage().getParameters().get('id')];
    }       
    
    public getAGSCase_Controller(){
    }
    
    public void testMarker(){
        system.debug('Testing code is a very trying objective to accomplish!');
        system.debug('Adding lines should not be a solution!');
        system.debug('I\'m not sure what else to say');
        system.debug('Testing code is a very trying objective to accomplish!');
        system.debug('Adding lines should not be a solution!');     
    }
    
    global  AGS_Case_Action_gne__c [] getActions() {           
        List<ID> agsCA= new List<ID>();
        
        for(AGS_Case_Action_gne__c agsActions : [Select id, OwnerId, Action_Status_internal_gne__c, Name from AGS_Case_Action_gne__c where AGS_Case_gne__c =: ApexPages.currentPage().getParameters().get('id')]){
            agsCA.add(agsActions.id);
        }                
    
        return [select id, name, OwnerId, Action_Status_internal_gne__c from AGS_Case_Action_gne__c  where id in :agsCA];                               
    }        
     
        
}