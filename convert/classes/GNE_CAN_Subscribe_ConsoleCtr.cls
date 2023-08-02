public with sharing class GNE_CAN_Subscribe_ConsoleCtr 
{
	final GNE_CAN_Subscribe_BatchRunner hcoBatchRunner;
	
	final GNE_CAN_Subscribe_BatchRunner hcpBatchRunner;
	
	public Boolean isSubscribeHcoRunning{
		get{
			return this.hcoBatchRunner.isRunning; 			
		}
	}
	 
	public Boolean isSubscribeHcpRunning{
		get{
			return this.hcpBatchRunner.isRunning; 		 			
		}
	}
	
	public GNE_CAN_Subscribe_ConsoleCtr(){					
		this.hcoBatchRunner = GNE_CAN_Subscribe_BatchRunner.newInstanceForAllHCO();
		this.hcpBatchRunner = GNE_CAN_Subscribe_BatchRunner.newInstanceForAllHCP();			
	}
	
	public PageReference refreshView(){
		refreshStateMessages();										
		return null; 
    }        
             	 						 
	public PageReference subscribeHcoAction(){        
        runBatchJob(this.hcoBatchRunner);		
        this.hcpBatchRunner.disableMessages();						
		return null;
	}
		
	public PageReference subscribeHcpAction(){	
        runBatchJob(this.hcpBatchRunner); 
        this.hcoBatchRunner.disableMessages();				      
		return null;
	}
	
	public PageReference showJobDetailsAction(){
		return goToJobDetails();
	}
	
	private void runBatchJob(GNE_CAN_Subscribe_BatchRunner batchRunner){
		try{
			batchRunner.run();						
			showInfoMessage(batchRunner.stateMessage);	
		}
		catch (Exception e) {	
            showErrorMessage(e);
        }       		
	} 	
	
	private void refreshStateMessages(){
		String msg = prepareStateMessage();
		if(hasValue(msg)){
			showInfoMessage(msg);	
		}		
	}
	
	private String prepareStateMessage()	{
		String hcoMsg = hcoBatchRunner.stateMessage;
		String hcpMsg = hcpBatchRunner.stateMessage;
		
		if(hasValue(hcoMsg) && hasValue(hcpMsg)){
			return hcoMsg + '<BR>' + hcpMsg;		
		} else if(hasValue(hcoMsg)){
			return hcoMsg;		
		} else if(hasValue(hcpMsg)){
			return hcpMsg;
		}		
		return null;
	}
	
	private PageReference goToJobDetails(){
		String id = ApexPages.currentPage().getParameters().get('jobId');		
		PageReference pr = Page.GNE_CAN_SubscribeJob;	
		pr.getParameters().put('id', id);		
		return pr;		
	}
			 
	private void showInfoMessage(String message){
    	ApexPages.Message msg = new ApexPages.Message(ApexPages.Severity.INFO, message);
	   	ApexPages.addMessage(msg);
    } 
    
    private void showErrorMessage(Exception e){
    	 ApexPages.addMessages(e);
    }     
    
    private Boolean hasValue(String s){
    	return (s!=null) && (s.trim()!='');    	
    } 
    
    // how to remove it :-(  ?
    private class BatchJob{    	
    }   	                        
            
}