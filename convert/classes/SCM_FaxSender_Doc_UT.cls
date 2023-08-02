@isTest
private class SCM_FaxSender_Doc_UT {

        static testMethod void SCM_FaxSender_DocUnitTest() {
            // Vars
            
            SCM_FaxSender_WebService.SCMFaxDocument faxDoc = new SCM_FaxSender_WebService.SCMFaxDocument();
            
            faxDoc.Id = '1001';
            faxDoc.Filename = 'Test.c';
            faxDoc.ParentFolderId = '9001';
                //faxDoc.UpdatedDate = DateTime.valueOf(document.UpdatedDate);
            //faxDoc.DateModified= null;
                //faxDoc.Description = faxDocument.Description;
            faxDoc.FileSize = '20480';
            faxDoc.CompanyOffice = 'Office';
            faxDoc.Attention = 'You';
            faxDoc.FaxNumber = '123';
            faxDoc.DocumentType = 'Documnet';
            faxDoc.FileType= 'Document';

            SCM_FaxSender_Doc resultDoc = SCM_FaxSender_Doc.ToDoc(faxDoc);
            
            integer test = resultDoc.getSizeOfFile();
            
            List<SCM_WebServices.SCMDocument> docs = new List<SCM_WebServices.SCMDocument>();

            List<SCM_FaxSender_WebService.SCMFaxDocument> faxDocs = new List<SCM_FaxSender_WebService.SCMFaxDocument>();
            faxDocs.Add(faxDoc);
            
            List<SCM_FaxSender_Doc> resultDocs = SCM_FaxSender_Doc.ToSCMDocs(null);
            resultDocs = SCM_FaxSender_Doc.ToSCMDocs(faxDocs);
            String longResult = resultDoc.Id;
            String stringResult = resultDocs[0].Name;
            stringResult = resultDocs[0].FaxNumber;
            resultDocs[0].FaxNumber = '';
            resultDocs[0].FaxNumber = '(123)456-7890';
            resultDocs[0].FaxNumber = '1(123)456-7890';
            stringResult = resultDoc.getUpdatedDateFormatted();
            stringResult = SCM_FaxSender_Doc.ExtractNumbers('123abc');
            Boolean boolResult = resultDocs[0].IsFaxNumberValid;
            boolResult = resultDocs[0].IsDocumentValid;
        }
}