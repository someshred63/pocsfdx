global without sharing class GNE_CM_MPS_EnrollEsignConfirmRedir_Ctrl 
{
 private Patient_Enrollment_Request_gne__c patenrol; 
    public Boolean read_aggrement {get; set;}   
    public String logoURL {get; set;} 
    public String altLogo {get; set;}
    public String per_name {get; set;}
    public String theId {get; private set;}
    public String useLightBox {get; set;}
    
    private String DocId;
    private String documentAuthenticationToken;
    private Map<String, List<Environment_Variables__c>> environmentVariables;
    
    public GNE_CM_MPS_EnrollEsignConfirmRedir_Ctrl(ApexPages.StandardController controller) 
    {        
        theId = ApexPages.currentPage().getParameters().get('id');
        DocId = ApexPages.currentPage().getParameters().get('DiD');
        read_aggrement = false;
        List<Patient_Enrollment_Request_gne__c> enrollments = [SELECT Id, Name, First_Name_gne__c, Last_Name_gne__c,  product_gne__c 
                                                    FROM Patient_Enrollment_Request_gne__c 
                                                    WHERE id = :theId];
        if(enrollments != null && enrollments.size() > 0)
        {   
            patenrol = enrollments[0];      
            per_name = patenrol.Name;           
        }
        else
        {
            patenrol = new Patient_Enrollment_Request_gne__c();
        }
        Set<String> envVariables = new Set<String>();
        envVariables.add('SCM_URL');
        envVariables.add('GNE-CM-SpringCM-Partner-Webservice-URL');
        envVariables.add('GNE-CM-SpringCM-Partner-Webservice-URL');
        envVariables.add('SCM_WebserviceURL'); 
        envVariables.add('SCM_AccountID');
        envVariables.add('GNE_CM_MPS_LIGHTBOX');
        environmentVariables = GNE_CM_MPS_Utils.populateEnvVariables(envVariables); 
        List<Environment_Variables__c> envVar = environmentVariables.get('GNE_CM_MPS_LIGHTBOX');   
        if(envVar != null && envVar.size() > 0) 
        {
            useLightBox=envVar[0].value__c;
            system.debug('useLightBox---->'+useLightBox);
        }   
    }




public PageReference DoRedirect()
{


      
      PageReference p = new PageReference(PrinteSMNURL);
      return p;
}



  public String PrinteSMNURL{
        get{            
            String SCM_URL = '';    
            documentAuthenticationToken = getDocumentAuthenticationToken();        
            List<Environment_Variables__c> envVarResults = environmentVariables.get('SCM_URL'); 
            if(envVarResults !=null && envVarResults.size() > 0 )
            {
                SCM_URL = envVarResults[0].value__c;
                //String SCMPrintURL = SCM_Security.getEnvironmentVariable('SCM_URL').toLowerCase().replace('faxsender.asmx','Portal/Preview.aspx');
                String SCMPrintURL = SCM_URL.toLowerCase().replace('faxsender.asmx','Portal/Preview.aspx');
                if(documentAuthenticationToken != null && documentAuthenticationToken != '')
                    return SCMPrintURL + '?Etoken=' + documentAuthenticationToken + '&DiD=' + DocId + '&Type=PDF'; 
                else
                    return SCM_URL;
            }
            else
            {
                return SCM_URL;
            }
            
        }
    }
    
      private String getDocumentAuthenticationToken()
    {   
        try{
            SCM_Authentication.AuthenitcationServiceSoap auth = new SCM_Authentication.AuthenitcationServiceSoap();
            auth.timeout_x = 60000;          
            List<Environment_Variables__c> envVarURL = environmentVariables.get('SCM_WebserviceURL');
            List<Environment_Variables__c> envVarAccID = environmentVariables.get('SCM_AccountID');
            String envVarURLStr = '';
            String envVarAccIdStr = '';
            if(envVarURL != null || envVarURL.size() > 0)
            {
                envVarURLStr = envVarURL[0].value__c;
            }
            if(envVarAccID != null || envVarAccID.size() > 0)
            {
                envVarAccIdStr  = envVarAccID[0].value__c;
            }
            
            String orgId = System.UserInfo.getOrganizationId();
            String id = auth.CreateRequest(UserInfo.getSessionId(),System.UserInfo.getOrganizationId(),[select email from user where id = :UserInfo.getUserId()][0].email,'Enrollment','Enrollment',patenrol.Id,patenrol.Name,'Enrollment',GNE_CM_MPS_Utils.getApiHostURL() + '/services/Soap/u/18.0/' + orgId ,'',envVarURLStr,envVarAccIdStr);
            if(envVarURLStr =='' || envVarAccIdStr =='')
                return '';
            else
                return id;
        }
        catch(Exception e)
        {
            GNE_CM_MPS_Utils.insertError('GNE_CM_MPS_EnrollEsignConfirm_Ctrl', 
                                        'High',
                                        'getDocumentAuthenticationToken',
                                        'VF Page',
                                        GlobalUtils.getExceptionDescription(e));            
            return '';
        }       
    }
    }