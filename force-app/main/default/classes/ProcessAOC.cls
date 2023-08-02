public with sharing class ProcessAOC {

 ApexPages.StandardSetController setCon;
 ApexPages.StandardController sc;
 static GneProductOrderUpdateAOC.UpdateOrderAOC updateAOC = new GneProductOrderUpdateAOC.UpdateOrderAOC();
 private List<LWO_AOC_Audit__c> aoc_audit=new List<LWO_AOC_Audit__c>();
 private Boolean displayprocessAoc=true;
 
 
  public ProcessAOC (ApexPages.StandardSetController controller) { 
  	
  	System.debug('*********controller is ---->'+controller);
  setCon = controller;
  aoc_audit=setCon.getSelected();
  }
 
 
 
  public pageReference checkRedirect(){
 	if( getMySelectedSize()>10)
 	{
          	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'You can select a maximun of 10 records at a time to submit for AOC.Please click on Cancel button and select 10 or less number of records');
          	ApexPages.addMessage(myMsg); 		
 	}
 	
 	if(getMySelectedSize()<=0)
 	{
 		    ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'No Records selected to Process AOC');
          	ApexPages.addMessage(myMsg);
 	}
 	
     return null;
  }
 
  public integer getMySelectedSize() {
  System.debug(setCon.getSelected());
   return setCon.getSelected().size();
  }
 
   public pageReference submitAOC()
   {
   	 boolean all_valid_orders=true; 
   	
   	
   	 
   	
   	 /* SFDC Limit is 10 callouts per request . so make sure to limit aoc_audit.size() to be less than or equal to 10  
   	 */
   	
   	 
   	 List<LWO_AOC_Audit__c> process_aoc=new List<LWO_AOC_Audit__c>();
   	 
   	 for(integer i=0;i<aoc_audit.size();i++)
   	 {
   	 	System.debug('entered here');
   	 	System.debug('********AOC STATUS **********'+ aoc_audit[i].AOC_Status__c);
   	 	System.debug('********STATUS RESPONSE **********'+ aoc_audit[i].Status_Response__c);
   	 	if(aoc_audit[i].Status_Response__c=='true')
   	 	{
   	 		all_valid_orders=false;
   	 		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Order #  '+ aoc_audit[i].Order_ID__c+': Status for this Order is true . You can only submit Orders for AOC when Status is false. Please click Cancel button and select valid records.');
          	ApexPages.addMessage(myMsg);
          	displayprocessAoc=false;
   	 		
   	 	}
   	 }
   	 
   	 
   	 
   	 System.debug('initial check point done : all valid orders and size--> '+all_valid_orders+'size'+aoc_audit.size());
   	 
   	 if(all_valid_orders){
   	 	
 
   	 for(integer i=0;i<aoc_audit.size();i++)
   	 {
   	 	 System.debug('*******entered here as status is not true ******'+ aoc_audit[i].Status_Response__c);
   	 	 //always good to check again ..
   	 	 if(aoc_audit[i].Status_Response__c!='true')
   	 	 {
   	 	  try{ 
   	  	  GneProductOrderUpdateAOC.UpdateOrderAOCResponseItem responseItem = null;     
   	  	  responseItem = updateAOC.updateOrderAOC(aoc_audit[i].Order_ID__c,aoc_audit[i].SAP_Account_ID__c,'COMPLETE', System.Now().format('yyyy-MM-dd HH:mm:ss'),aoc_audit[i].Recieved_date__c,aoc_audit[i].User_Name__c,aoc_audit[i].User_First_Name__c,aoc_audit[i].User_Last_Name__c);
   	  	  
   	  	  
   	  	  String status = responseItem.messageCode;
   	  	  if (status == null) {              
            status = 'true';
          }
        
        System.debug('responded status --------->'+ status);
          if(status!='true')
          {
          	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, 'Error occured while submitting AOC for Order# :'+ aoc_audit[i].Order_ID__c+'  Status response is false');
          	ApexPages.addMessage(myMsg);
          }
          
          else{
          	aoc_audit[i].Status_Response__c='true';
          	process_aoc.add(aoc_audit[i]);
          	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.INFO, 'Selected Order(s) are processed Successfully');
          	ApexPages.addMessage(myMsg);
          	displayprocessAoc=false;
          	
          }
          
   	 }
   	
   	 catch(Exception e)
   	 {
   	 		ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
          	ApexPages.addMessage(myMsg);
   	 }
   	 
    }
    
    
   }
   	 try{
   	 if(process_aoc.size()>0)
   	 update process_aoc;
   	 }
   	 
    catch(Exception e){
   	ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR, e.getMessage());
    ApexPages.addMessage(myMsg); 	
   	}
   } 
  
   	  return null;
   }
   	 
   }