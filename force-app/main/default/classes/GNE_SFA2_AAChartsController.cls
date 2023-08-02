public with sharing class GNE_SFA2_AAChartsController {
    
    public String hostName {get;set;}
    public boolean isIframe{get;set;}
    private SFA2_Configuration_Object_gne__c pageConfiguration;  
      
    public String url{
        get{
            return Utilities.getGlobalVariable('BO_Server_Name');
        }
        private set;
    }
    
    public GNE_SFA2_AAChartsController(){
        hostName = System.URL.getSalesforceBaseUrl().toExternalForm();  
        isIframe=false;
        pageConfiguration = GNE_SFA2_Util.getListPageConfiguration('AACharts');
        
    }
    
    public PageReference aACharts(){
        isIframe=true;
        //PageReference pg = new pagereference(buildURL());
        //pg.setRedirect(false);
        //System.debug('***' + getbuildURL());
        //return pg;
        return null;
        
    }
    
    public PageReference checkNewWindow(){
        PageReference pageRef = System.currentPageReference();
        String newWindow= pageRef.getParameters().get('new_window');
        if(newWindow!=null && newWindow.equals('true')){
            PageReference pg = new pagereference(getbuildURL());
            pg.setRedirect(false);
            System.debug('***' + getbuildURL());
            return pg;
            
            
        } 
        //if existing window
        return null;
    }
    
    public String getActiveMenuItem() {
       String result = '';
        if(pageConfiguration != null && pageConfiguration.Attributes_gne__c!=null && pageConfiguration.Attributes_gne__c.contains('activeMenuItem')){
        result = pageConfiguration.Attributes_gne__c.substringBetween('activeMenuItem=',';');
        }
        return result;
    }    
    
    public String getbuildURL(){
        String host=System.URL.getSalesforceBaseUrl().toExternalForm();     
        String pgURL = 'https://'+ url+ '/iMap/AdvAssess1.jsp?serverName='+host;
        
        return pgURL;   
    }
    
    
}