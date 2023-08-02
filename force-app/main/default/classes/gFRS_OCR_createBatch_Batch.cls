global class gFRS_OCR_createBatch_Batch implements Database.Batchable<gFRS_OCR_Forms__c>, Database.AllowsCallouts{
    String strBlnk = '';
    global List<gFRS_OCR_Forms__c> start(Database.BatchableContext BC){
        List<gFRS_OCR_Forms__c> scope = [Select id,gFRS_Batch_ID__c,gFRS_Document_ID__c,gFRS_Form_Organization__c,
                                         gFRS_Form_Organization__r.gFRS_OCR_Batch_Process_Status__c 
                                         from gFRS_OCR_Forms__c where gFRS_Batch_ID__c = '' AND 
                                         gFRS_Form_Organization__r.gFRS_OCR_Batch_Process_Status__c = 'Ready for processing' AND
                                         ( gFRS_Status_of_CreateBatch__c = 'Ready to Process' 
                                          	OR gFRS_Status_of_CreateBatch__c = 'Failed to process')];
        
        if(scope != null && scope.size()>0){
            system.debug('@@@:::scope:::'+scope);
            return scope;	}
        
        return database.query('Select id from gFRS_OCR_Forms__c where id = null');
    }
    
    global void execute(Database.BatchableContext BC, List<gFRS_OCR_Forms__c> scope){
        String strBacthId;
        gFRS_OCR_Forms__c frmRcd;
        if(scope != null){
            
            frmRcd = [Select id,gFRS_Batch_ID__c,gFRS_Attachment_Name__c from gFRS_OCR_Forms__c where id=:scope];
            //system.debug('@@@::Scope::::'+scope);
            
            /* ---Actual call --*/
            
                        //String strName = 'gFRS ' + String.valueOf(DateTime.now());
            strBacthId = gFRS_OCR_HTTPCallouts.createBatchCallout(frmRcd.gFRS_Attachment_Name__c);
            
            //testing line - hard coding value to by pass callouts during development
            //strBacthId = '1111100000';
            
            if(frmRcd != null){
                try{
                    system.debug('@@@::'+strBacthId);
                    if(String.isNotBlank(strBacthId)){
                        // assign batch Id to form record.
                        frmRcd.gFRS_Batch_ID__c = strBacthId;
                        frmRcd.gFRS_Status_of_CreateBatch__c = 'Completed';
                        frmRcd.gFRS_Status_of_AddFileToBatch__c = 'Ready to Process';
                        update frmRcd;
                        //system.debug('@@@:::Form record updated:::'+frmRcd);                
                    }
                    
                }catch(Exception  ex){
                    //system.debug('@@@:: Exception:::'+ex.getMessage());
                    frmRcd.gFRS_Batch_ID__c = '';
                    frmRcd.gFRS_Status_of_CreateBatch__c = 'Failed to process';
                    update frmRcd; 
                } 
            }            
        }    	
    }
    
    global void finish(Database.BatchableContext BC){
        //finish method
        gFRS_OCR_addFileToBatch_Batch btc = new gFRS_OCR_addFileToBatch_Batch();
        Id batchId =  Database.executeBatch(btc, 1);
    }
    
}