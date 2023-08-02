public without sharing class GNE_CM_MHRA_CCC_Case_Controller {
 	  public transient List<String> ccCaseFields { get; set; }
	  public transient Map<String, String> ccCaseLabels { get; set; }
	  public transient CCC_Case_gne__c cccRecord { get; set; }
  

    //public Set<String> fields2Hide=new Set<String> { 'Id',  'IsDeleted', 'IsLocked', 'MayEdit'};
     public Set<String> fields2Hide=new Set<String> {};
    

    public GNE_CM_MHRA_CCC_Case_Controller (ApexPages.StandardController stdController) 
    {
        string caseId = stdController.getId();
        system.debug('CASE ID==> '+caseId);
		
		ccCaseFields = GNE_CM_MHRA_Case_Util.getSObjectFieldList('CCC_Case_gne__c');
		 ccCaseFields.add(0, 'Name');  
		
		cccRecord = Database.query(GNE_CM_MHRA_Case_Util.getSObjectList('CCC_Case_gne__c', ccCaseFields, 'id', caseId));
		ccCaseLabels = GNE_CM_MHRA_Case_Util.getSObjectLabelMap('CCC_Case_gne__c');
       
        // sort
        ccCaseFields.sort();
        		             
    }
}