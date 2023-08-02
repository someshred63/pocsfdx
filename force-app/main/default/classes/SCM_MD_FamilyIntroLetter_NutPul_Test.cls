@isTest
// Developer Name    : Jatin Setia		
// Document Name     : NUT- PUL CMGT-FAX-46 Family Intro Letter final.doc
private class SCM_MD_FamilyIntroLetter_NutPul_Test {
    static testMethod void testFamilyIntroLetter_NutPul() {
         //local variables
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        String argLookupId = '';
        
        SCM_MD_FamilyIntroLetter_NutPul mergeDoc =
             new SCM_MD_FamilyIntroLetter_NutPul(caseId, argLookupId);
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        String test = mergeDoc.getXMLString();
        System.debug(test);
    }
}