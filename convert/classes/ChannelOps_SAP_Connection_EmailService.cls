/**********************************************************************
Purpose: ChannelOps_SAP_Connection_EmailService class is mainly accepts 
		 inbound email from SAP and process the emails.
========================================================
History                                                            
-------                                                            
VERSION  AUTHOR        DATE            DETAIL                       
1.0      Vijay      07/25/2019      INITIAL DEVELOPMENT           
***********************************************************************/

global class ChannelOps_SAP_Connection_EmailService implements Messaging.InboundEmailHandler {
     
	/*********************************************************************************************
     Purpose: This is handleInboundEmail method. It processes the SAP emails and updates the 
			  Channelops spoilage request status and SAP response email.
    **********************************************************************************************/                                
	global Messaging.InboundEmailResult handleInboundEmail(Messaging.inboundEmail email, 
                                                       Messaging.InboundEnvelope env){
        // Create an InboundEmailResult object for returning the result of the 
        // Apex Email Service
        Messaging.InboundEmailResult result = new Messaging.InboundEmailResult();
		System.debug('In handleInboundEmail method ----'+email);
        ChannelOps_SAP_ConnectionHandler sapConnectionHandler = new ChannelOps_SAP_ConnectionHandler();
  		sapConnectionHandler.processSAPEmail(email);
        //System.debug('emailSubject---'+emailSubject.split('\\|'));                                                    
   	    
        // Set the result to true. No need to send an email back to the user 
       // with an error message
       result.success = true;
   
       // Return the result for the Apex Email Service 
       return result;
                                                           
	}
}