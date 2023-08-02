global class SCM_MergeFaxCover_WS {
    webservice static String mergeFaxCover(String caseId, String sourceDocumentKey,
                                            String folderId, String fileName)
    {   
        try
        { 
            
            Case documentCase =null;
            List<Case> caseList = [Select Product_gne__c from Case where Id=:caseId];
            
            if(caseList.size()>0)
				documentCase=caseList[0];
            else
            	return null;
            
            List<SCM_Merge_Document__c> docList=[Select Name, Document_Type__c, Product__c, Metadata_Key__c,Merge_Class_Name__c 
            									 from SCM_Merge_Document__c
                            					 where Metadata_Key__c=:sourceDocumentKey and Product__c=:documentCase.Product_gne__c];
            SCM_Merge_Document__c document=null;
            String className = null;
            if(docList.size()>0)
            { 
            	document=docList[0];
            	system.debug(docList[0].id);
            	className=document.Merge_Class_Name__c;
            	system.debug(className);
            }
            if(className!=null)
            {        
                SCM_MergeDocument mergeDoc = SCM_MergeDocumentFactory.createMergeDocument(className, caseId, sourceDocumentKey);
           
                if(mergeDoc!=null)
                { 
                    // = [Select Name, Document_Type__c, Product__c, Metadata_Key__c from SCM_Merge_Document__c where Id=:mergeDoc.mergeLookupID];
                    //if(document==null)
                    //   return null; 
                    mergeDoc.sfDocumentRecord=document;
                    mergeDoc.addTypeInfo2MergeList();
                    String token=SCM_Security.SCM_AuthenticateNonDefault();
                    String fieldXML = mergeDoc.getXMLString();
                    SCM_FaxSender_WebService.FaxSenderSoap sender = new SCM_FaxSender_WebService.FaxSenderSoap();
                 //   return fieldXML;
                    return sender.CreateMailMergeJob(token,sourceDocumentKey,folderId,fileName,fieldXML);
                }
                else
                    return null;
            }
            else 
                return null;
        }
        catch(Exception exp)
        {
            // To-do : create debug log
            system.debug(exp.getmessage());
            scm_logerror.sendEmail(exp);
            return null;
        }
    }
    webservice static String getmergeFaxCoverxml(String caseId, String sourceDocumentKey)
    {  
         
        try
        { 
            
            Case documentCase =null;
            List<Case> caseList = [Select Product_gne__c from Case where Id=:caseId];
            
            if(caseList.size()>0)
				documentCase=caseList[0];
            else
            	return null;
            system.debug('src doc key:' + sourceDocumentKey);
            List<SCM_Merge_Document__c> docList=[Select Name, Document_Type__c, Product__c, Metadata_Key__c,Merge_Class_Name__c 
            									 from SCM_Merge_Document__c
                            					 where Metadata_Key__c=:sourceDocumentKey limit 1];
            SCM_Merge_Document__c document=null;
            String className = null;
            if(docList.size()>0)
            { 
            	document=docList[0];
            	system.debug(docList[0].id);
            	className=document.Merge_Class_Name__c;
            	system.debug(className);
            }
            if(className!=null)
            {        
                SCM_MergeDocument mergeDoc = SCM_MergeDocumentFactory.createMergeDocument(className, caseId, sourceDocumentKey);
           
                if(mergeDoc!=null)
                { 
                    // = [Select Name, Document_Type__c, Product__c, Metadata_Key__c from SCM_Merge_Document__c where Id=:mergeDoc.mergeLookupID];
                    //if(document==null)
                    //   return null; 
                    mergeDoc.sfDocumentRecord=document;
                    mergeDoc.addTypeInfo2MergeList();
                    String token=SCM_Security.SCM_AuthenticateNonDefault();
                    String fieldXML = mergeDoc.getXMLString();
                    SCM_FaxSender_WebService.FaxSenderSoap sender = new SCM_FaxSender_WebService.FaxSenderSoap();
                 //   return fieldXML;
                    return  fieldXML;//sender.CreateMailMergeJob(token,sourceDocumentKey,folderId,fileName,fieldXML);
                }
                else
                    return null;
            }
            else 
                return null;
        }
        catch(Exception exp)
        {
            // To-do : create debug log
            scm_logerror.sendEmail(exp);
            system.debug(exp.getmessage());
            return null;
        }
    }
    public static testMethod void testit(){
    	 try {
    	SCM_MergeFaxCover_WS.mergeFaxCover('a1nS0000000001SIAQ', '',
                                            '', '');
    }catch (exception ex) {}
     try {
    	SCM_MergeFaxCover_WS.getmergeFaxCoverxml('a1nS0000000001SIAQ', '');
    }catch (exception ex) {}
    }
}