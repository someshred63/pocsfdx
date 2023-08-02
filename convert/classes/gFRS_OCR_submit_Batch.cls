global class gFRS_OCR_submit_Batch implements Database.Batchable<gFRS_OCR_Forms__c>, Database.AllowsCallouts{

    global List<gFRS_OCR_Forms__c> start(Database.BatchableContext BC){
        
       List<gFRS_OCR_Forms__c> scope = [Select id,gFRS_Batch_ID__c,gFRS_Document_ID__c,gFRS_Form_Organization__c 
                                         from gFRS_OCR_Forms__c where gFRS_Batch_ID__c != '' AND gFRS_Status_of_CreateBatch__c = 'Completed' 
                                        AND gFRS_Status_of_AddFileToBatch__c = 'Completed' AND
                                         ( gFRS_Status_of_submitBatch__c = 'Ready to Process' 
                                          OR gFRS_Status_of_submitBatch__c = 'Failed to process')];
        
        if(scope != null && scope.size()>0){
            return scope;	}
        
        return database.query('Select id from gFRS_OCR_Forms__c where id = null');
    }
    
    global void execute(Database.BatchableContext BC, List<gFRS_OCR_Forms__c> scope){
    	// following code
    	String StrbatchId;
        gFRS_OCR_Forms__c frmObj; // 97300
        if(scope != null){
            for(gFRS_OCR_Forms__c obj : scope ){
                frmObj =obj;
                StrbatchId = obj.gFRS_Batch_ID__c;
                if(frmObj != null && StrbatchId != ''){
                    break;    
                }
            }
        }
        
        try{
            if(frmObj != null && StrbatchId != null){
                HttpResponse res = gFRS_OCR_HTTPCallouts.submitBatchCallout(StrbatchId);
                if(res != null){
                    Integer stCd = res.getStatusCode();
                    if(stCd==200){
                        frmObj.gFRS_Status_of_submitBatch__c = 'Completed';
                        update frmObj;
                    }
                }
            }   
        }catch(Exception ex){
            system.debug('@@@:: Exception:::'+ex.getMessage());
            frmObj.gFRS_Status_of_submitBatch__c = 'Failed to process';
            update frmObj;
        }
    }
    
    global void finish(Database.BatchableContext BC){
        //finish method
    }
    
}