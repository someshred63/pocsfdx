// Added By: Deepak Yadav
// Doc Name: Fax Cover Sheet Analysis v3.1.doc
// PRODUCT GROUP: OPTHALMOLOGY
// CMGT-FAX-08	Request for Additional Information
public class SCM_MD_Fax_ReqForAddiInfo_Lucentis_Test {
	 
	  public static testMethod void testReqForAddiInfo_Lucentis() {      
        //local variables
        String argLookupID;       
          
         //First Test
        Case documentCase = SCM_CreateTestData.CreateCase();
        String caseId = documentCase.Id;
        argLookupID = '';  
        SCM_MD_Fax_ReqForAddiInfo_Lucentis mergeDoc = new   SCM_MD_Fax_ReqForAddiInfo_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields = mergeDoc.mergeRecipientInfo;
        string test = mergeDoc.getXMLString();
        System.debug(test);    
        /*
        //test for PaddressedTo
        String Attn = fields[0].fieldValue;
        System.assertEquals(Attn, '');       

        //test for PaddressedTo
        String addressedTo = fields[2].fieldValue;
        System.assertEquals(addressedTo, ' ');
        
        //test for From
        String caseMangName = fields[3].fieldValue;
        System.assertEquals(caseMangName, 'Aftan Allard');
        
        //test for extNo
        String extNo = fields[4].fieldValue;
        System.assertEquals(extNo, '1234');      
        
         //-------------------------------------------Second test---------------------------------------------          
        caseId = '500S0000000gRSvIAM'; 
        argLookupID = '';  
        mergeDoc = new SCM_MD_Fax_MessageFromSPOC_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields1 = mergeDoc.mergeRecipientInfo;
        
        //test for PaddressedTo
        String addressedTo1 = fields1[2].fieldValue;
        System.assertEquals(addressedTo1, ' Physician Account ,M.D.');
        
        //test for From
        String caseMangName1 = fields1[3].fieldValue;
        System.assertEquals(caseMangName1, 'Abhay Gupta');
        
        //test for extNo
        String extNo1 = fields1[4].fieldValue;
        System.assertEquals(extNo1, '');      
        
         
          //-------------------------------------------Third test---------------------------------------------          
        caseId = '500S0000000gj7dIAA'; 
        argLookupID = '';  
        mergeDoc = new SCM_MD_Fax_MessageFromSPOC_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields2 = mergeDoc.mergeRecipientInfo;
        
        //test for addressedTo
        String addressedTo2 = fields2[2].fieldValue;
        System.assertEquals(addressedTo2, 'Lance Briggs ,M.D.');
        
        //test for From
        String caseMangName2 = fields2[3].fieldValue;
        System.assertEquals(caseMangName2, 'Aftan Allard');
        
        //test for extNo
        String extNo2 = fields2[4].fieldValue;
        System.assertEquals(extNo2, '1234');    
        
         //-------------------------------------------Fourth test---------------------------------------------          
        caseId = '500S0000000gjnfIAA'; 
        argLookupID = '';  
        mergeDoc = new SCM_MD_Fax_MessageFromSPOC_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields3 = mergeDoc.mergeRecipientInfo;
        
        //test for PaddressedTo
        String addressedTo3 = fields3[2].fieldValue;
        System.assertEquals(addressedTo3, 'Tony Tennessee ,M.D.');
        
        //test for From
        String caseMangName3 = fields3[3].fieldValue;
        System.assertEquals(caseMangName3, 'Rosanne Chloupek');
        
        //test for extNo
        String extNo3 = fields3[4].fieldValue;
        System.assertEquals(extNo3, '');    
        
        //-------------------------------------------fivth test---------------------------------------------          
        caseId = '500S0000000g15YIAQ'; 
        argLookupID = '';  
        mergeDoc = new SCM_MD_Fax_MessageFromSPOC_Lucentis(caseId, argLookupID);
        mergeDoc.createMergeFields();
        SCM_MergeField[] fields4 = mergeDoc.mergeRecipientInfo;
        
        //test for PaddressedTo
        String addressedTo4 = fields4[2].fieldValue;
        System.assertEquals(addressedTo3, 'Tony Tennessee ,M.D.');
        
        //test for From
        String caseMangName4 = fields4[3].fieldValue;
        System.assertEquals(caseMangName3, 'Rosanne Chloupek');
        
        //test for extNo
        String extNo4 = fields4[4].fieldValue;
        System.assertEquals(extNo4, '');
            */  
    }

}