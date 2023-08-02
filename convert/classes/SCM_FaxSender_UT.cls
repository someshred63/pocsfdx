@isTest
private class SCM_FaxSender_UT {

        static testMethod void SCM_FaxSenderUnitTest() {
            // Vars
            string resultString;
            Boolean resultBool;
            List<SCM_FaxSender_Doc> resultDocs;
            List<String> resultDouble;
            integer resultInt;
            
            string caseNo = '00000000';
            
            string testString;
            List<SCM_FaxSender_Doc> testDocs = new List<SCM_FaxSender_Doc>();
            testDocs.Add(new SCM_FaxSender_Doc());
            testDocs.Add(new SCM_FaxSender_Doc());
            testDocs.Add(new SCM_FaxSender_Doc());
            testDocs.Add(new SCM_FaxSender_Doc());

            List<String> testDoubles = new List<String>();
            testDoubles.Add('1001');
            testDoubles.Add('1002');
            testDoubles.Add('1003');
            testDoubles.Add('1004');
            
            testDocs[0].ID = testDoubles[0];
            testDocs[0].ParentFolderId = '0';
            testDocs[1].ID = testDoubles[1];
            testDocs[1].ParentFolderId = '1';
            testDocs[2].ID = testDoubles[2];
            testDocs[2].ParentFolderId = '2';
            testDocs[3].ID = testDoubles[3];
            testDocs[3].ParentFolderId = '3';
            
            testDocs[0].Selected = true;
            testDocs[1].Selected = false;
            testDocs[2].Selected = true;
            testDocs[3].Selected = false;
            
            integer testInt = 2;

            //Nulls
            string nullTestString;
            List<SCM_FaxSender_Doc> nullTestDocs;
            List<String> nullTestDoubles;
            integer nullTestInt;

            SCM_FaxSender fs = new SCM_FaxSender();

            //fs.UTesting = true;

            // Null tests
            resultDocs = fs.AvailableCoverSheets(nullTestString,nullTestString,nullTestString);
            resultDocs = fs.AvailableDocuments(nullTestString, nullTestDocs );
            
            resultDouble = SCM_FaxSender.MoveUp(nullTestDoubles, nullTestInt);
            resultDouble = SCM_FaxSender.MoveDown(nullTestDoubles, nullTestInt);
            
            resultInt = SCM_FaxSender.Searcher(nullTestDocs, '0');
            resultInt = SCM_FaxSender.Searcher(nullTestDoubles, '0');
            
            resultDouble = SCM_FaxSender.NewList(nullTestDocs);
            resultDocs = SCM_FaxSender.Sorter(nullTestDocs, nullTestDoubles);
            
            resultDouble = SCM_FaxSender.SelectedDocuments(nullTestDocs);
            resultDocs = SCM_FaxSender.ClearSelectedDocuments(nullTestDocs);
            resultDocs = SCM_FaxSender.CompleteFax(nullTestDocs, nullTestDocs, '0', nullTestDoubles);

            // Other tests
            fs = new SCM_FaxSender();
            
            List<SCM_FaxSender_Doc> coverSheetDocs = fs.AvailableCoverSheets(caseNo,caseNo,caseNo);
            
            //resultDocs = fs.GetCoverSheets(caseNo, caseNo, caseNo);
            resultDocs = fs.GetNonCoverSheets(caseNo, '1');
            resultDocs = SCM_FaxSender.SorterByUpdateDate(testDocs);
            resultDocs = fs.AvailableDocuments(caseNo, testDocs);
            
            string message = fs.UserMessage();

            resultDouble = SCM_FaxSender.MoveUp(testDoubles, testInt);
            resultDouble = SCM_FaxSender.MoveDown(testDoubles, testInt);
            
            resultInt = SCM_FaxSender.Searcher(testDocs, '0');
            resultInt = SCM_FaxSender.Searcher(testDoubles, '0');
            
            resultDouble = SCM_FaxSender.NewList(testDocs);
            resultDocs = SCM_FaxSender.Sorter(testDocs, testDoubles);
            
            resultDouble = SCM_FaxSender.SelectedDocuments(testDocs);
            resultDocs = SCM_FaxSender.ClearSelectedDocuments(testDocs);
            resultDocs = SCM_FaxSender.CompleteFax(testDocs, testDocs, '0', testDoubles);
            
            resultBool = fs.SendFax(testDoubles, '1', 'Test', 'Testing','XYZ');

        }
}