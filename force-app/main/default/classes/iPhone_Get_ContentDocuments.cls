@RestResource(urlMapping='/iPhoneGetContentDocuments/*')
global class iPhone_Get_ContentDocuments {
    global static Map<String, String> parentIdToName;

    @HttpPost
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId) {
       	return iPhone_Commons_gne.buildResponse(
            new iPhoneGetContentDocumentsResponseBuilder(), 
            new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId)
        );
    }

    class iPhoneGetContentDocumentsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder {

        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return getContentDocuments();
        }

        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new ContentDocumentsRecord((ContentDocument)sObj);
        }

        private List<ContentDocument> getContentDocuments(){
            parentIdToName = new Map<String, String>();
            Set<Id> libraryIds = new Set<Id>();
            List<ContentDocument> cdList = iPhone_DAO.getContentDocuments();
            for(ContentWorkspaceDoc cwd :[SELECT ContentWorkspace.Name, ContentWorkspaceId FROM ContentWorkspaceDoc WHERE ContentDocumentId IN :cdList]){
                parentIdToName.put(cwd.ContentWorkspaceId, cwd.ContentWorkspace.Name);
            }
            return cdList;
        }
    }

    class ContentDocumentsRecord extends iPhone_Commons_gne.DeltaRecord {
    	//Document Info
        public String title;
        public String description;
        public String authorName;
        public String createdDate;
        public String contentSize;
        public String fileExtension;
        public String libraryName;
        //Version Info
        public String versionNumber;
        //Additional Info
        public String documentCategory;
        public String documentType;
        public String programType;
        public String use;
        //Links
        public String downloadLink;

        public ContentDocumentsRecord(ContentDocument contentDoc) {
            this.id = iPhone_StringUtil.getString(contentDoc.Id);
            this.title = iPhone_StringUtil.getString(contentDoc.Title);
            this.description = iPhone_StringUtil.getString(contentDoc.Description);
            this.authorName = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.Owner.Name);
            this.createdDate = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.CreatedDate);
            this.contentSize = iPhone_StringUtil.getString(contentDoc.ContentSize);
            this.fileExtension = iPhone_StringUtil.getString(contentDoc.FileExtension);
            this.libraryName = parentIdToName.get(iPhone_StringUtil.getString(contentDoc.ParentId));

            this.versionNumber = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.VersionNumber);

            this.documentCategory = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.Document_Category__c);
            this.documentType = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.Document_Type__c);
            this.programType = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.Progam_Type__c);
            this.use = iPhone_StringUtil.getString(contentDoc.LatestPublishedVersion.Use__c);

            this.downloadLink = URL.getSalesforceBaseUrl().toExternalForm() + '/services/apexrest/iPhoneGetContentDocuments/' + iPhone_StringUtil.getString(contentDoc.LatestPublishedVersionId) + '/Body';
        }
    }    
}