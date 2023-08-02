public with sharing class GNE_SFA2_CanadaDocuments {
    public GNE_SFA2_CanadaDocuments (){}
    public String FolderEnv = GNE_SFA2_Util.getAllEnvVariables('SFA_Canada_Folder')[0].Value__c;     
    public List<Document> getFdcEnglish()
    {
        List<Document> fdcEnglish=[SELECT ID, Name,DeveloperName,Description FROM document where Folderid=:FolderEnv and DeveloperName like 'English%FDC%'];
        if(fdcEnglish.size() > 1){
            List<DocumentWrapper> documentsWrapper = new List<DocumentWrapper>();
            for(Document doc : fdcEnglish){
                documentsWrapper.add(new DocumentWrapper(doc));
            }
            documentsWrapper.sort();
            fdcEnglish.clear();
            for(DocumentWrapper docWrapper : documentsWrapper){
                fdcEnglish.add(docWrapper.document);
            }
            documentsWrapper.clear();
        }
        return fdcEnglish;
    }
    public List<Document> getOtrEnglish()
    {
        List<Document> otrEnglish=[SELECT ID, Name,DeveloperName,Description FROM document where Folderid=:FolderEnv and DeveloperName like 'English%OTR%'];
        if(otrEnglish.size() > 1){
            List<DocumentWrapper> documentsWrapper = new List<DocumentWrapper>();
            for(Document doc : otrEnglish){
                documentsWrapper.add(new DocumentWrapper(doc));
            }
            documentsWrapper.sort();
            otrEnglish.clear();
            for(DocumentWrapper docWrapper : documentsWrapper){
                otrEnglish.add(docWrapper.document);
            }
            documentsWrapper.clear();
        }
        return otrEnglish;
    }
    public List<Document> getFdcFrench()
    {
        List<Document> fdcFrench=[SELECT ID, Name,DeveloperName,Description FROM document where Folderid=:FolderEnv and DeveloperName like 'French%FDC%'];
        if(fdcFrench.size() > 1){
            List<DocumentWrapper> documentsWrapper = new List<DocumentWrapper>();
            for(Document doc : fdcFrench){
                documentsWrapper.add(new DocumentWrapper(doc));
            }
            documentsWrapper.sort();
            fdcFrench.clear();
            for(DocumentWrapper docWrapper : documentsWrapper){
                fdcFrench.add(docWrapper.document);
            }
            documentsWrapper.clear();
        }
        return fdcFrench;
    }
    public List<Document> getOtrFrench()
    {
        List<Document> otrFrench =[SELECT ID, Name,DeveloperName,Description FROM document where Folderid=:FolderEnv and DeveloperName like 'French%OTR%'];
        if(otrFrench.size() > 1){
            List<DocumentWrapper> documentsWrapper = new List<DocumentWrapper>();
            for(Document doc : otrFrench){
                documentsWrapper.add(new DocumentWrapper(doc));
            }
            documentsWrapper.sort();
            otrFrench.clear();
            for(DocumentWrapper docWrapper : documentsWrapper){
                otrFrench.add(docWrapper.document);
            }
            documentsWrapper.clear();
        }
        return otrFrench;
    }
    
    public class DocumentWrapper implements Comparable {

        public Document document;
        
        // Constructor
        public DocumentWrapper(Document doc) {
            document = doc;
        }
    
        public Integer compareTo(Object compareTo) {
            DocumentWrapper compareToDocument = (DocumentWrapper)compareTo;
            Integer returnValue = 0;
            if (getSortNumber(document.DeveloperName)> getSortNumber(compareToDocument.document.DeveloperName)) {
                returnValue = 1;
            } else if (getSortNumber(document.DeveloperName) < getSortNumber(compareToDocument.document.DeveloperName)) {
                returnValue = -1;
            }        
            return returnValue;       
        }
        private Integer getSortNumber(String stringName){
            Pattern p = Pattern.compile('[^0-9]+([0-9]+).+');
            Matcher m = p.matcher(stringName);
            if (m.find()) 
            {
               system.debug(m.group(1)); 
            }
            return Integer.valueOf(m.group(1));
        }
    }
   
}