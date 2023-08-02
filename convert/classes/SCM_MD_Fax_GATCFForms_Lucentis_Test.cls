// Added By: Deepak Yadav
// Doc Name: Fax Cover Sheet Analysis v3.1.doc
// PRODUCT GROUP: OPTHALMOLOGY
public class SCM_MD_Fax_GATCFForms_Lucentis_Test {
     public static testMethod void testGATCFForms_Lucentis() {      
        //local variables
       	String caseId;
        String argLookupID;  
        
        Case documentCase = SCM_CreateTestData.CreateCase();
        caseId = documentCase.Id;
        argLookupID = '';
        SCM_MD_Fax_GATCFForms_Lucentis mergeDoc = new SCM_MD_Fax_GATCFForms_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        string test = mergeDoc.getXMLString();
        System.debug(test);
     }
}