@isTest
private class SCM_WebServices_UT {

    static testMethod void SCM_WebServicesUnitTest() {
        SCM_WebServices scm_ws = new SCM_WebServices();
        
        SCM_WebServices.AuthenticateNonDefaultResponse_element t1 = new SCM_WebServices.AuthenticateNonDefaultResponse_element();
        SCM_WebServices.Authenticate_element t2 = new SCM_WebServices.Authenticate_element();
        SCM_WebServices.DocumentDownload_element t3 = new SCM_WebServices.DocumentDownload_element ();
        SCM_WebServices.SCMObject t4 = new SCM_WebServices.SCMObject ();
        SCM_WebServices.AuthenticateResponse_element t5 = new SCM_WebServices.AuthenticateResponse_element ();
        SCM_WebServices.DocumentSearchResponse_element t6 = new SCM_WebServices.DocumentSearchResponse_element ();
        SCM_WebServices.ArrayOfString t7 = new SCM_WebServices.ArrayOfString ();
        SCM_WebServices.SCMSearch t8 = new SCM_WebServices.SCMSearch ();
        SCM_WebServices.SCMMetadata t9 = new SCM_WebServices.SCMMetadata ();
        SCM_WebServices.SCMBaseObject tA = new SCM_WebServices.SCMBaseObject ();
        SCM_WebServices.DocumentDownloadResponse_element tB = new SCM_WebServices.DocumentDownloadResponse_element ();
        SCM_WebServices.ArrayOfSCMDocument tC = new SCM_WebServices.ArrayOfSCMDocument ();
        SCM_WebServices.SpringCMServiceSoap tD = new SCM_WebServices.SpringCMServiceSoap ();
        SCM_WebServices.DocumentSearch_element tE = new SCM_WebServices.DocumentSearch_element ();
        SCM_WebServices.AuthenticateNonDefault_element tF = new SCM_WebServices.AuthenticateNonDefault_element ();
        SCM_WebServices.SCMSearchDocument tG = new SCM_WebServices.SCMSearchDocument ();
        SCM_WebServices.SCMDocument tH = new SCM_WebServices.SCMDocument ();
        SCM_WebServices.SCMDocument tI = new SCM_WebServices.SCMDocument ();
        SCM_WebServices.ArrayOfSCMMetadata tJ = new SCM_WebServices.ArrayOfSCMMetadata ();
        
        SCM_WebServices.FolderCreateResponse_element tK = new SCM_WebServices.FolderCreateResponse_element();
        SCM_WebServices.ArrayOfSCMFolder tL = new SCM_WebServices.ArrayOfSCMFolder();
        SCM_WebServices.FolderSearchResponse_element tM = new SCM_WebServices.FolderSearchResponse_element();
        SCM_WebServices.CopyResponse_element tN = new SCM_WebServices.CopyResponse_element();
        SCM_WebServices.DocumentSave_element tO = new SCM_WebServices.DocumentSave_element();
        SCM_WebServices.FolderSearch_element tP = new SCM_WebServices.FolderSearch_element();
        SCM_WebServices.DocumentSaveResponse_element tQ = new SCM_WebServices.DocumentSaveResponse_element();
        SCM_WebServices.FolderSave_element tR = new SCM_WebServices.FolderSave_element();
        SCM_WebServices.AuthenticateWithKeys_element tS = new SCM_WebServices.AuthenticateWithKeys_element();
        SCM_WebServices.Copy_element tT = new SCM_WebServices.Copy_element();
        SCM_WebServices.FolderCreate_element tU = new SCM_WebServices.FolderCreate_element();
        SCM_WebServices.DocumentCopyResult tV = new SCM_WebServices.DocumentCopyResult();
        SCM_WebServices.FolderSaveResponse_element tW = new SCM_WebServices.FolderSaveResponse_element();
        SCM_WebServices.AuthenticateWithKeysResponse_element tX = new SCM_WebServices.AuthenticateWithKeysResponse_element();
        SCM_WebServices.ArrayOfDocumentCopyResult tY = new SCM_WebServices.ArrayOfDocumentCopyResult();
        SCM_WebServices.BPMInitiateWorkflow_element tZ = new SCM_WebServices.BPMInitiateWorkflow_element();
        SCM_WebServices.DocumentGetById_element tAA = new SCM_WebServices.DocumentGetById_element();
        SCM_WebServices.SCMFolder tBB = new SCM_WebServices.SCMFolder();
        SCM_WebServices.BPMInitiateWorkflowResponse_element tDD = new SCM_WebServices.BPMInitiateWorkflowResponse_element();
        SCM_WebServices.SCMSearchFolder tEE = new SCM_WebServices.SCMSearchFolder();
        SCM_WebServices.SCMList tFF = new SCM_WebServices.SCMList();
        SCM_WebServices.FolderGetContentsResponse_element tGG = new SCM_WebServices.FolderGetContentsResponse_element();
        SCM_WebServices.DocumentGetByIdResponse_element tHH = new SCM_WebServices.DocumentGetByIdResponse_element();
		SCM_WebServices.SCMMetadataField tII = new SCM_WebServices.SCMMetadataField();
		SCM_WebServices.ArrayOfSCMMetadataField  tJJ = new SCM_WebServices.ArrayOfSCMMetadataField();
		SCM_WebServices.GetMetadataFieldsResponse_element tKK = new SCM_WebServices.GetMetadataFieldsResponse_element();
		SCM_WebServices.ParsePath_element tLL = new SCM_WebServices.ParsePath_element();
		SCM_WebServices.GetMetadataFields_element tMM = new SCM_WebServices.GetMetadataFields_element();
		SCM_WebServices.ParsePathResponse_element tNN = new SCM_WebServices.ParsePathResponse_element();
		SCM_WebServices.FolderGetContents_element tNN1 = new SCM_WebServices.FolderGetContents_element();
		SCM_WebServices.FolderGetById_element tNN3 = new SCM_WebServices.FolderGetById_element();
		SCM_WebServices.SCMPath tNN4 = new SCM_WebServices.SCMPath();
		SCM_WebServices.FolderGetByIdResponse_element tNN5 = new SCM_WebServices.FolderGetByIdResponse_element();
        String stringResult = '';
        try {
        stringResult = tD.AuthenticateWithKeys('userName','userKey','apiKey');
        } catch (Exception ex) {}
        try {
        stringResult = tD.AuthenticateNonDefault('userName','password','AccountId','apiKey');
        } catch (Exception ex) {}
        try {
        stringResult = tD.Authenticate('userName','password','apiKey');
        } catch (Exception ex) {}
         try {
         stringResult = td.DocumentDownload('','','','','');
        } catch (Exception ex) {}
    }
}