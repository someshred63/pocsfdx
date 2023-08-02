public with sharing class GNE_SFA2_Edit_Dispatcher_Ext  {
    private String sObjectType;
    private String sObjectId;
    private String urlParameters;
    private String parentRetUrl;
    
    private Boolean isSFA2User;    
    
    public GNE_SFA2_Edit_Dispatcher_Ext (ApexPages.StandardController stdController){
        sObjectType = String.valueOf(stdController.getRecord().getSObjectType());
        sObjectId = stdController.getRecord().Id;
        
        System.PageReference pageReference = System.currentPageReference();
        if (pageReference != null){
            Map<String,String> parameters = pageReference.getParameters();                                  
            if (parameters != null && parameters.size() > 0){
                parentRetUrl = parameters.get('retURL');
                urlParameters = '?';
                for (String key : parameters.keyset()){
                    if (urlParameters != '?'){
                        urlParameters += '&'; 
                    } 
                    urlParameters += String.format('{0}={1}', new String[]{key, parameters.get(key)});
                }
            }
        }        
    } 
    
    public PageReference doRedirect(){
        
         isSFA2User = GNE_SFA2_Util.isSFA2UserForUI();
         String aId = apexpages.currentpage().getParameters().get('id'); 
        
        // for all SFA2 users open SFA2 custom page
        if(isSFA2User){
            
            if (sObjectType == 'Task'){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_Task_Edit_Create_Layout?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;   
            }
            else if (sObjectType == 'ART_Site_gne__c'){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_ART_Site_Edit_Create_Layout?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;   
            }
            else if (sObjectType == 'ART_Issue_gne__c'){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_ART_Issue_Edit_Create_Layout?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;   
            }
            else if (sObjectType == 'ART_Team_gne__c'){
                PageReference pageref = new PageReference('/apex/GNE_SFA2_ART_Team_Edit_Create_Layout?id='+sObjectId);
                pageref.setredirect(true);
                return pageref;   
            }                                          
        } else { // NOT SFA2 users and standard layout
               if (sObjectType == 'ART_Issue_gne__c'){
                    PageReference pageref = new PageReference('/apex/GNE_MCCO_Edit_ART_Issue_Page?id='+sObjectId);
                    pageref.setredirect(true);
                    return pageref;   
               }

             	PageReference pageref = new PageReference('/'+sObjectId+'/e?nooverride=1'+'&retURL='+parentRetUrl);
				pageref.setredirect(true);
                return pageref;
            }  
        return null;
    }
    
    private String getPageUrlFormated(String vfPageName){
        String pageUrl;
        if (!String.isBlank(urlParameters)){
            pageUrl = String.format('/apex/{0}{1}', new String[]{vfPageName, urlParameters});
        } else {
            pageUrl = String.format('/apex/{0}?id={1}', new String[]{vfPageName, sObjectId});
        }
        return pageUrl;               
    }
}