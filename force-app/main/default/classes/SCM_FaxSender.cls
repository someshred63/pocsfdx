//
// FaxSender
// 

public class SCM_FaxSender {
        private String hiddentUserMessage;
        
        public SCM_FaxSender() {
            hiddentUserMessage = '';
        }
        
        public String UserMessage() {
            return hiddentUserMessage; 
        } 

        public static List<String> MoveUp(List<String> docList, Integer docLoc){
            if(docList != null && docLoc > 0) {
                String tmpId = docList[docLoc-1];
                docList[docLoc-1] = docList[docLoc];
                docList[docLoc] = tmpId;
            }
            
            return docList;
        }

        public static List<String> MoveDown(List<String> docList, Integer docLoc){
            if(docList != null && docLoc < docList.size() - 1) {
                String tmpId = docList[docLoc+1];
                docList[docLoc+1] = docList[docLoc];
                docList[docLoc] = tmpId;
            }
            
            return docList;
        }

        //Finds the docs location by it's ID
        public static Integer Searcher(List<SCM_FaxSender_Doc> docs, String docId) {
            Integer idx = 0;
            Integer docLoc;

            if(docs != null) {
                for (SCM_FaxSender_Doc doc : docs) {
                    if (doc.Id == docId) {
                        docLoc = idx;
                    }
     
                    idx++;
                }
    
                if (idx < 0 ) {
                    // thrown exception, value not found
                }
            }

            return docLoc;
        }
        
        //Finds the docs location by it's ID
        public static Integer Searcher(List<String> docs, String docId) {
            Integer idx = 0;
            Integer docLoc = 0;
            
            if(docs != null)
            {
                for (String doc : docs) {
                    if (doc == docId) {
                        docLoc = idx;
                    }
     
                    idx++;
                }
    
                if (idx < 0 ) {
                    // thrown exception, value not found
                }
            }

            return docLoc;
        }

        public static List<String> NewList(List<SCM_FaxSender_Doc> docList) {
            List<String> orderList = new List<String>();
            
            if(docList != null)
            {
                for (SCM_FaxSender_Doc doc : docList) {
                    orderList.Add(doc.Id);
                }
            }

            return orderList;
        }

        public static List<SCM_FaxSender_Doc> Sorter(List<SCM_FaxSender_Doc> docList, List<String> orderList) {
            List<SCM_FaxSender_Doc> sortedDocs = new List<SCM_FaxSender_Doc>();

            if(docList != null && orderList != null)
            {
                for (String docId : orderList) {
                    Integer docLoc = Searcher(docList, docId);
                    if (docLoc >= 0) {
                        sortedDocs.Add(docList[docLoc]);
                        sortedDocs[sortedDocs.size() - 1].First = false;
                        sortedDocs[sortedDocs.size() - 1].Last = false;
                    }
                }
                
                // This sets where the up/down arrows should be hidden
                //sortedDocs[0].First = true;
                //sortedDocs[sortedDocs.size() - 1].Last = true;
            }

            return sortedDocs;
        }
        
        public static List<SCM_FaxSender_Doc> SorterByUpdateDate(List<SCM_FaxSender_Doc> docList) {
            List<SCM_FaxSender_Doc> sortedDocs = new List<SCM_FaxSender_Doc>();

            sortedDocs = docList;

            boolean allSorted = false;

            if(docList != null)
            {
                Integer limitor = 0;
                while(!allSorted && limitor < 100)
                {
                    for(Integer i = 0; i < sortedDocs.size() - 1; i++)
                    {
                        allSorted = true;
                        if (sortedDocs[i].UpdatedDate < sortedDocs[i + 1].UpdatedDate)
                        {
                            SCM_FaxSender_Doc tmp = new SCM_FaxSender_Doc();
                            tmp = sortedDocs[i + 1];
                            sortedDocs[i + 1] = sortedDocs[i];
                            sortedDocs[i] = tmp;
                            allSorted = false;
                            break;
                        }
                    }
                    limitor ++;
                }
            }

            return sortedDocs;
        }

        public static List<String> SelectedDocuments(List<SCM_FaxSender_Doc> docs) {
            List<String> docList = new List<String>();
            
            if(docs != null)
            {
                for (SCM_FaxSender_Doc doc : docs) {
                    if(doc.selected) {
                        docList.Add(doc.Id);
                    }
                }
            }

            return docList;
        }
        
        public static List<SCM_FaxSender_Doc> ClearSelectedDocuments(List<SCM_FaxSender_Doc> docs) {
            if(docs != null)
            {
                for (SCM_FaxSender_Doc doc : docs) {
                    doc.selected = false;
                }
            }

            return docs;
        }
 
        public List<SCM_FaxSender_Doc> AvailableCoverSheets(String caseNumber, String product, String sfoid) {
            return SorterByUpdateDate(GetCoverSheets(caseNumber, product, sfoid));
        }

        public List<SCM_FaxSender_Doc> AvailableDocuments(String sfoid, List<SCM_FaxSender_Doc> covers) {
            if (covers != null)
            {
                return SorterByUpdateDate(GetNonCoverSheets('', covers[0].ParentFolderId));
            }
            return null;
        }
        
        public static List<SCM_FaxSender_Doc> CompleteFax(List<SCM_FaxSender_Doc> covers, List<SCM_FaxSender_Doc> docs, String coverId, List<String> docIds) {
            List<SCM_FaxSender_Doc> theFax;
            List<String> theIds;
            
            if(docs != null && docIds != null)
            {
                theFax = docs.Clone();
                theIds = docIds.Clone();

                if (theFax.IsEmpty()) {
                    theFax = new List<SCM_FaxSender_Doc>();
                }
                
                if (theIds.IsEmpty()) {
                    theIds = new List<String>();
                }
    
                //Merge the to SCMDoc lists
                for(SCM_FaxSender_Doc cdoc: covers){
                    theFax.Add(cdoc);
                }
    
                //Insert coversheet to the top;
                if (theIds.size() == 0) {
                    theIds.Add(coverId);
                }
                else {
                    theIds.Add(0, coverId);
                }
            }

            return Sorter(theFax, theIds);
        }
       
        public Boolean SendFax(List<String> docIds, String coverId, String sfoid, String user, String caseNumber,String TrackingID) {                      
            try {
                SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
    
                string docIdsString = '';
                                   
                string coverIdString = coverId;
                
                for(String docId : docIds){
                    if(docIdsString != '' + coverId)
                    {
                        docIdsString = docIdsString + '|';
                    }
    
                    docIdsString = docIdsString + docId;
                }
                
                String returnMessage = '';
                string token = '';
                    try
				
                {
					token = SCM_Security.SCM_AuthenticateNonDefault();
                    returnMessage = fsws.SendFax40(token, UserInfo.getOrganizationId(), coverIdString, docIdsString, UserInfo.getUserId(), user, caseNumber, '', '',TrackingID);
					SCM_WSLogger.InsertLog(fsws.log.MethodName__c,fsws.log.Parameters__c);
                } 

                catch (Exception ex1) {

                    try

                    {
                    	
						emailError(ex1, 'Send Fax Failed on the first try from the Salesforce Send Fax Wizard the webservice call with be retried. Token = ' + token + '\r\n' + hiddentUserMessage );
                        if (token == ''){
                    		token = SCM_Security.SCM_AuthenticateNonDefault();
                    	}
                        returnMessage = fsws.SendFax40(token, UserInfo.getOrganizationId(), coverIdString, docIdsString, UserInfo.getUserId(), user, caseNumber, '', '',TrackingID);
				SCM_WSLogger.InsertLog(fsws.log.MethodName__c,fsws.log.Parameters__c);
                    }

                    catch (Exception ex2) {

                        emailError(ex2,'Send Fax Failed on the Second try from the Salesforce Send Fax Wizard this was the final attempt. Token = ' + token + '\r\n' + hiddentUserMessage );

                    }

                }

                system.debug(fsws.log.MethodName__c);
                system.debug(fsws.log.Parameters__c);
                System.debug(returnMessage);
                
                if(returnMessage == 'Fax queued'){
                    return true;
                }
                else {
                    hiddentUserMessage = 'Sending facsimile problem: ' + returnMessage;
                    SCM_LogError.sendEmail('Sending problem', hiddentUserMessage, true);
                }
            }
            catch (Exception ex) {
                hiddentUserMessage = 'Connection problem: Could not send facsimile information, please try again shortly.';
                emailError(ex,hiddentUserMessage);
            }
            return false;
        }
        // Retrieves a list of cover sheet documents
        public List<SCM_FaxSender_Doc> GetCoverSheets(String caseNumber, String product, String SFChildID)
        {
            List<SCM_FaxSender_Doc> theDocs = new List<SCM_FaxSender_Doc>();

                try {
                    SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
                    
                    theDocs = SCM_FaxSender_Doc.ToSCMDocs(fsws.GetCoverSheetsDocs(SCM_Security.SCM_AuthenticateNonDefault(), caseNumber, product, SFChildId,UserInfo.getOrganizationId()).SCMFaxDocument);
                }
                catch (Exception ex) {
                    try {
                        SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
                        
                        theDocs = SCM_FaxSender_Doc.ToSCMDocs(fsws.GetCoverSheetsDocs(SCM_Security.SCM_AuthenticateNonDefault(), caseNumber, product, SFChildId,UserInfo.getOrganizationId()).SCMFaxDocument);
                    }
                    catch (Exception ex2) {
                        hiddentUserMessage = 'Connection problem: Could not retrieve facsimile cover sheet list, please try again shortly.';
                        emailError(ex2,hiddentUserMessage );
                    }
                }

            return theDocs;
        }

        // Retrieves a list of non cover sheet documents
        public List<SCM_FaxSender_Doc> GetNonCoverSheets(String SFChildID, String folderID)
        {
            List<SCM_FaxSender_Doc> theDocs;
                try {
                    SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
                    
                    theDocs = SCM_FaxSender_Doc.ToSCMDocs(fsws.GetNonCoverSheetsDocs(SCM_Security.SCM_AuthenticateNonDefault(), SFChildID, folderID,UserInfo.getOrganizationId()).SCMFaxDocument);
                }
                catch (Exception ex) {
                    try {
                        SCM_FaxSender_WebService.FaxSenderSoap fsws = new SCM_FaxSender_WebService.FaxSenderSoap();
                        
                        theDocs = SCM_FaxSender_Doc.ToSCMDocs(fsws.GetNonCoverSheetsDocs(SCM_Security.SCM_AuthenticateNonDefault(), SFChildID, folderID,UserInfo.getOrganizationId()).SCMFaxDocument);
                    }
                    catch (Exception ex2) {
                        hiddentUserMessage = 'Connection problem: Could not retrieve facsimile non cover sheet list, please try again shortly.' + ex2.getMessage();
                        emailError(ex2,hiddentUserMessage);
                    }
                }

            return theDocs;
        }
        
        private void emailError(Exception ex,string message)
        {
            SCM_LogError.sendEmail(ex,message);
        }
}