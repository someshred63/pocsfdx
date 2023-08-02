/************************************************************
*  @author: Lukasz Kwiatkowski, Roche
*  Date: 2012-09-17
*  Description: This is a helper class for GNE_SFA2_ART_Issue_Trigger
*    
*  Modification History
*  Date        Name        Description      
*************************************************************/
public without sharing class GNE_SFA2_ART_Issue_Test_Helper {
    
    public static Integer BATCH_SIZE = 201;  // 201 to test agains governor limits
    
    public static ART_Site_gne__c prepareTestARTSite() {
        ART_Site_gne__c testSite = new ART_Site_gne__c(Name = 'testSite');
        insert testSite;
        
        return testSite;
    }
    
    /* helper method used for preparing test ART Issues */
    public static List<ART_Issue_gne__c> prepareTestARTIssues(Set<String> emptyFieldNames, Map<String, Object> testFieldValues) {
        List<ART_Issue_gne__c> testData = new List<ART_Issue_gne__c>();
        for(Integer i = 0; i < BATCH_SIZE; i++) {
            ART_Issue_gne__c artIssue = new ART_Issue_gne__c();
            
            // populate ART_Site_Local_gne__c field
            artIssue.ART_Site_Local_gne__c = (String) getFieldValue('ART_Site_Local_gne__c', emptyFieldNames, testFieldValues);
            // populate Issue_Status_gne__c field
            artIssue.Issue_Status_gne__c = (String) getFieldValue('Issue_Status_gne__c', emptyFieldNames, testFieldValues);
            // populate Date_Closed_gne__c field
            artIssue.Date_Closed_gne__c = (Date) getFieldValue('Date_Closed_gne__c', emptyFieldNames, testFieldValues);
             // populate Name field
            artIssue.Name = (String) getFieldValue('Name', emptyFieldNames, testFieldValues);
            // populate Resolution_Type_gne__c field
            artIssue.Resolution_Type_gne__c = (String) getFieldValue('Resolution_Type_gne__c', emptyFieldNames, testFieldValues);
            // populate Type_gne__c field
            artIssue.Type_gne__c = (String) getFieldValue('Type_gne__c', emptyFieldNames, testFieldValues);
            
            testData.add(artIssue);
        }
        
        return testData;
    }
    
    /* helper method used for preparing test ART Memberships */
    public static ART_Team_gne__c prepareTestARTTeamMembership(ART_Site_gne__c testArtSite, User teamMember) {
        ART_Team_gne__c testMembership = new ART_Team_gne__c(ART_Site_gne__c = testArtSite.Id, Team_Member_gne__c = teamMember.Id);
        insert testMembership;
        
        return testMembership;
    }
    
    /* helper method for getting field value */
    public static Object getFieldValue(String fieldName, Set<String> emptyFieldNames, Map<String, Object> testFieldValues){
        Object result = null;
        if(emptyFieldNames != null && emptyFieldNames.contains(fieldName)) {
            result = null;          
        } else if(testFieldValues != null && testFieldValues.containsKey(fieldName)) {
            result = (Object) testFieldValues.get(fieldName);
        } else {
            result = 'test';
        }
        return result;
    }
}