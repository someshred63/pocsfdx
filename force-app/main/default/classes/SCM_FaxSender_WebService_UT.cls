@isTest
private class SCM_FaxSender_WebService_UT {

    static testMethod void SCM_FaxSender_WebServiceTest() {
        string testString;
        SCM_FaxSender_WebService fsws = new SCM_FaxSender_WebService();

        SCM_FaxSender_WebService.CreateMailMergeJobResponse_element fsws_crmmjre = new SCM_FaxSender_WebService.CreateMailMergeJobResponse_element();
        SCM_FaxSender_WebService.MergeJobStatus fsws_mjs = new SCM_FaxSender_WebService.MergeJobStatus ();
        SCM_FaxSender_WebService.SendFax_element fsws_sfe = new SCM_FaxSender_WebService.SendFax_element();
        SCM_FaxSender_WebService.CheckMailMergeJobResponse_element fsws_chmmjre = new SCM_FaxSender_WebService.CheckMailMergeJobResponse_element();
        SCM_FaxSender_WebService.SendFaxResponse_element fsws_sfre = new SCM_FaxSender_WebService.SendFaxResponse_element();
        SCM_FaxSender_WebService.SendFaxAlternate_element fsws_sfae = new SCM_FaxSender_WebService.SendFaxAlternate_element();
        SCM_FaxSender_WebService.CheckMailMergeJob_element fsws_chmmje = new SCM_FaxSender_WebService.CheckMailMergeJob_element();
        SCM_FaxSender_WebService.FaxSenderSoap fsws_sfs = new SCM_FaxSender_WebService.FaxSenderSoap();
        SCM_FaxSender_WebService.SendFaxAlternateResponse_element fsws_sfare = new SCM_FaxSender_WebService.SendFaxAlternateResponse_element();
        SCM_FaxSender_WebService.CreateMailMergeJob_element fsws_crmmje = new SCM_FaxSender_WebService.CreateMailMergeJob_element();
        //SCM_FaxSender_WebService. fsws_ = new SCM_FaxSender_WebService.();
        SCM_FaxSender_WebService.ToSFChildIdResponse_element fsws_tsfcidre = new SCM_FaxSender_WebService.ToSFChildIdResponse_element();
        SCM_FaxSender_WebService.GetCaseFolderIDResponse_element fsws_gcfidre = new SCM_FaxSender_WebService.GetCaseFolderIDResponse_element();
        SCM_FaxSender_WebService.SetPatientIDOnDoc_element fsws_spidod = new SCM_FaxSender_WebService.SetPatientIDOnDoc_element();
        SCM_FaxSender_WebService.GetCaseFolderID_element fsws_gcfide = new SCM_FaxSender_WebService.GetCaseFolderID_element();
        SCM_FaxSender_WebService.SetPatientIDOnDocResponse_element fsws_spidodre = new SCM_FaxSender_WebService.SetPatientIDOnDocResponse_element();
        SCM_FaxSender_WebService.ArrayOfSCMFaxDocument fsws_aoscmfd = new SCM_FaxSender_WebService.ArrayOfSCMFaxDocument();
        SCM_FaxSender_WebService.GetCoverSheetsDocs_element fsws_gcsde = new SCM_FaxSender_WebService.GetCoverSheetsDocs_element();
        SCM_FaxSender_WebService.GetCoverSheetsDocsResponse_element fsws_gcsdre = new SCM_FaxSender_WebService.GetCoverSheetsDocsResponse_element();
        SCM_FaxSender_WebService.SCMFaxDocument fsws_scmfd = new SCM_FaxSender_WebService.SCMFaxDocument();
        SCM_FaxSender_WebService.GetNonCoverSheetsDocs_element fsws_gncsde = new SCM_FaxSender_WebService.GetNonCoverSheetsDocs_element();
        SCM_FaxSender_WebService.GetNonCoverSheetsDocsResponse_element fsws_gncsdre = new SCM_FaxSender_WebService.GetNonCoverSheetsDocsResponse_element();
        SCM_FaxSender_WebService.CheckWebserviceJob_element fsws_gncsdre2 = new SCM_FaxSender_WebService.CheckWebserviceJob_element();

        try {
            testString = fsws_sfs.SendFaxAlternate('Testing', '1001.0|1002.0|1003.0', '1000.0', '', '', '', '', '', '','','');
        }
        catch (Exception ex) {
            //What?!? Salesforce's testmethods do not support webservice callouts?
            //Yet, testmethods are required for webservice classes and they do 
            //these callouts, thats their whole purpose for existance.
            //Oh and they are auto generated by Salesforce. Go Salesforce!
        }
        
        try {
            testString = fsws_sfs.SendFax('Testing', '1001.0|1002.0|1003.0', '1000.0','','','','');
            //testString = fsws_sfs.SendFax('Testing', '1001.0|1002.0|1003.0', '1000.0','','','');
        } catch (Exception ex) {}
        try {
            testString = fsws_sfs.SendFax40('token','orgId','coverSheetID','documentIDs','senderId','senderUsername','caseNumber','destinationFolderID','faxBatchID');
            //testString = fsws_sfs.SendFax('Testing', '1001.0|1002.0|1003.0', '1000.0','','','');
        } catch (Exception ex) {}
        try {
            testString = fsws_sfs.ToSFChildId('000000000000000');
        } catch (Exception ex) {}
        try {
        testString = fsws_sfs.CreateMailMergeJob('Token','SourceDocumentKey','12345','DocumentFileName','FieldXML');
        } catch (Exception ex) {}
        try {
        testString = fsws_sfs.GetCaseFolderID('Token','CaseNumber', 'Product', false, 'CaseID','');
        } catch (Exception ex) {}
        try {
        fsws_mjs = fsws_sfs.CheckMailMergeJob('0');
        } catch (Exception ex) {}
        try {
        fsws_sfs.SetPatientIDOnDoc('Testing','023','0','00000000');
        } catch (Exception ex) {}
        try {
        fsws_sfs.CheckMailMergeJob('Testing');
        } catch (Exception ex) {}
         try {
        fsws_sfs.GetCoverSheetsDocs('','','','','');
        } catch (Exception ex) {}
         try {
        fsws_sfs.GetNonCoverSheetsDocs('','','','') ;
        } catch (Exception ex) {}
         try {
        fsws_sfs.SendFaxAlternate('','','','','','','','','','','');
        } catch (Exception ex) {}
    }
}