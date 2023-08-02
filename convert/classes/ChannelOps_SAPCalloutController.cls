/**********************************************************************
Purpose: ChannelOps_SAPCalloutController class is used to invoke the 
		 actual business logic to send the request to SAP and Signed COD 
		 pdf to SAP and show the success/failure response.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      08/29/2019      INITIAL DEVELOPMENT           
***********************************************************************/
public class ChannelOps_SAPCalloutController {
    
    private String operation;
    private String spoilageRequestId;
    private String spoilageRequestCODId;
    public Boolean enableBtn {get;set;}
    public String btnLabel {get;set;}
    public String displayAttVal {get;set;}
    
    //Default constructor
    public ChannelOps_SAPCalloutController(){
        operation = ApexPages.currentPage().getParameters().get('op');
        spoilageRequestId = ApexPages.currentPage().getParameters().get('reqId');
        spoilageRequestCODId = ApexPages.currentPage().getParameters().get('codId');  
        enableBtn = false;
        btnLabel = 'Back';
        displayAttVal = 'block';
    }
    
    /*********************************************************************************************
     Purpose: This method sends the spoilage request details to SAP.
    **********************************************************************************************/
    public void sendToSAP(){
        ChannelOps_SAP_ConnectionHandler.MessageWrapper msgWrapper = null;
        if(String.isNotBlank(operation)){
            displayAttVal = 'none';
            enableBtn = true;
            ChannelOps_SAP_ConnectionHandler sapConnectionHandler = new ChannelOps_SAP_ConnectionHandler();
            if(operation == ChannelOps_Constants.OPERATION_QT){
            	msgWrapper = sapConnectionHandler.sendToSAP(spoilageRequestId);
                btnLabel = 'Back to Spoilage Request';
            }else if(operation == ChannelOps_Constants.OPERATION_COD){
                msgWrapper = sapConnectionHandler.sendSignedCODToSAP(spoilageRequestCODId);
                btnLabel = 'Back to Spoilage Request COD';                
            }else{
                msgWrapper = new ChannelOps_SAP_ConnectionHandler.MessageWrapper('Invalid Operation', ChannelOps_Constants.MSG_ERROR);
            }
        }
		if(msgWrapper != null){
            if(msgWrapper.severity == ChannelOps_Constants.MSG_SUCCESS){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.Confirm, msgWrapper.message));
            }else if(msgWrapper.severity == ChannelOps_Constants.MSG_ERROR){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR, msgWrapper.message));
            }else if(msgWrapper.severity == ChannelOps_Constants.MSG_WARNING){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING, msgWrapper.message));
            }
        }
		
    }
	
    /*********************************************************************************************
     Purpose: This method navigates back to spoilage request or COD detail page.
    **********************************************************************************************/
    public PageReference back(){
        PageReference pageRef = null;
        if(String.isNotBlank(spoilageRequestId)){
          pageRef = new PageReference('/'+spoilageRequestId);  
        }else if(String.isNotBlank(spoilageRequestCODId)){
          pageRef = new PageReference('/'+spoilageRequestCODId);    
        }      
        return pageRef;
    }    
}