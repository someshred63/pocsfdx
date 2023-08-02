/**
* @author GFRS Dev Team
* @date 05/04/2017
* @description gFRS_GenentechLogoImagesController class - controller for gFRS_GenentechLogoImages page. 
*/
public with sharing class gFRS_GenentechLogoImagesController
{
    public Map<String,String> documentsMap {get;set;}
    
    public gFRS_GenentechLogoImagesController(){
        documentsMap = new Map<String,String>();
        try{
            List<Document> documentsList=[select Id,Description from Document where FolderId in (Select Id from Folder where DeveloperName = 'gFRS_Logos')];
            if(documentsList.size()>0)
            {
                for (Document d : documentsList){
                    documentsMap.put('/servlet/servlet.FileDownload?file='+d.Id,d.Description);
                } 
            }    
        } catch (Exception ex){
            System.debug( 'Error occured: ' + ex.getMessage() );
            ApexPages.addMessage( new ApexPages.Message( ApexPages.Severity.ERROR, 'Error occurred while loading genentech logos.' ));
        }
                
    }
}