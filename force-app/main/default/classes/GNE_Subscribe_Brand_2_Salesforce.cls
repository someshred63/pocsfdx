global without sharing class GNE_Subscribe_Brand_2_Salesforce extends GNE_Subscribe_Batch_Base implements Database.Batchable<sObject>, Database.Stateful, Schedulable {
	
	public static final String COMMENT_EXTERNAL_ID_NOT_SET = 'External ID is not set on Staging Record.';
	private static final String BATCH_NAME = 'Brand 2 Salesforce';
    private Boolean skipErrors;
    private Staging_Brand_2_Salesforce_gne__c[] recordsToReport = new Staging_Brand_2_Salesforce_gne__c[]{};
    private static final String baseUrl = URL.getSalesforceBaseUrl().toExternalForm() + '/'; 
    private static final String EMAIL_BODY = 'Subscribe Brand_2_Salesforce process {0} finished.<BR/>DEBUG INFO<BR/>Process start time: {1}<BR/>Process end time: {2}<BR/><BR/>';
    private static final String MISSING_SETTING = 'For these record <B>CDM Brand Code</b> is missing or invalid (custom setting: GNE_Foun_Brand_Map_gne__c).';
    private SubscribeMetrics metrics; 
	
	global GNE_Subscribe_Brand_2_Salesforce(Boolean prevMode) {
		previewMode = prevMode;
        skipErrors = false;
        this.metrics = new SubscribeMetrics();
	}
    
    global GNE_Subscribe_Brand_2_Salesforce(Boolean prevMode, Boolean skipErrors) {
		previewMode = prevMode;
        this.skipErrors = skipErrors;
        this.metrics = new SubscribeMetrics();
	}
    
    global void execute(SchedulableContext sc) {
        GNE_Subscribe_Brand_2_Salesforce job = new GNE_Subscribe_Brand_2_Salesforce(false, true);
        Database.executeBatch(job, 100);
	}
	
	protected override String getBatchName() {
    	return BATCH_NAME;
    }
	
	global Database.QueryLocator start(Database.BatchableContext BC) {
		 return Database.getQueryLocator ([
		 	SELECT Name, CDM_Brand_Code_gne__c, Comment_gne__c, External_Id_gne__c, Salesforce_Code_gne__c, Salesforce_Name_gne__c, 
                Salesforce_SubTeam_Code_gne__c, Salesforce_SubTeam_Name_gne__c,SFA_Brand_Name_gne__c, Status_gne__c
		 	FROM Staging_Brand_2_Salesforce_gne__c
		 	WHERE Status_gne__c = :GNE_Subscribe_Batch_Base.STATUS_LOADED
         ]);
	}
	
	public override void initCache(List<SObject> stgObjs) {
    	super.initCache(stgObjs);
    	System.debug('BOS::stagingCache.keySet() = ' + stagingCache.keySet());
    	
        List<Brand_2_Salesforce_gne__c> brand2Salesforces = [
        	SELECT 
        		Id, 
        		CDM_Brand_Code_gne__c, 
        		CDM_Salesforce_Code_gne__c, 
				CDM_Salesforce_SubTeam_Code_gne__c,
				External_Id_gne__c,
				Salesforce_Name_gne__c,
				Salesforce_SubTeam_Name_gne__c,
				SFA_Brand_Name_gne__c
			FROM Brand_2_Salesforce_gne__c
			WHERE External_Id_gne__c IN :stagingCache.keySet()];
			
		for(Brand_2_Salesforce_gne__c b2S : brand2Salesforces) {
			cacheTargetObject(b2S);
		}
    }
    
    protected override String getKeyFromTargetObject(SObject targetObj) {
    	String key = ((Brand_2_Salesforce_gne__c)targetObj).External_Id_gne__c;
    	return String.isNotBlank(key) ? key.toUpperCase() : '';
    }
    
    protected override String getKeyFromStagingObject(SObject stgObj) {
    	String key = ((Staging_Brand_2_Salesforce_gne__c)stgObj).External_Id_gne__c;
    	return String.isNotBlank(key) ? key.toUpperCase() : '';
    }
	
	global void execute(Database.BatchableContext BC, List<sObject> scope) {
		List<Staging_Brand_2_Salesforce_gne__c> stgObjs = (List<Staging_Brand_2_Salesforce_gne__c>)scope;
		initCache(stgObjs);
		
		List<Brand_2_Salesforce_gne__c> b2sToUpsert = new List<Brand_2_Salesforce_gne__c>();
        Set<Id> incorrectRecordsIds = new Set<Id>();
		
		for(Staging_Brand_2_Salesforce_gne__c stgB2S : stgObjs) {
			clearStagingObjectComment(stgB2S);
			Brand_2_Salesforce_gne__c b2S = (Brand_2_Salesforce_gne__c)getTargetForStagingObject(stgB2S);
            metrics.processed++;
			
			if(String.isBlank(stgB2S.External_Id_gne__c)) {
                if(skipErrors) {
                    recordsToReport.add(stgB2S);
                    incorrectRecordsIds.add(stgB2S.Id);
                } else {
				markStagingObjectWithError(stgB2S, COMMENT_EXTERNAL_ID_NOT_SET);
                }		
                metrics.incorrect ++;
			} else {
				if(b2S==null) {
					b2S = new Brand_2_Salesforce_gne__c(External_Id_gne__c = stgB2S.External_Id_gne__c);
                    metrics.inserted ++;
                } else {
                    metrics.updated ++;
				}
				
				updateBrand2SalesforceFields(b2S, stgB2S);
				b2sToUpsert.add(b2S);
				markStagingObjectAsProcessed(stgB2S);
			}
		}
		
		executeDml(b2sToUpsert, GNE_Subscribe_Batch_Base.DmlType.TARGET_UPSERT);
        if(skipErrors && !incorrectRecordsIds.isEmpty()) {
            stgObjs = removeIncorrectRecords(stgObjs, incorrectRecordsIds);
        } 
		executeDml(stgObjs, GNE_Subscribe_Batch_Base.DmlType.STAGING_UPDATE);
	}
	
	private void updateBrand2SalesforceFields(Brand_2_Salesforce_gne__c b2S, Staging_Brand_2_Salesforce_gne__c stgB2S) {
		b2S.CDM_Brand_Code_gne__c = stgB2S.CDM_Brand_Code_gne__c;
        b2S.CDM_Salesforce_Code_gne__c = stgB2S.Salesforce_Code_gne__c;
        b2S.CDM_Salesforce_SubTeam_Code_gne__c = stgB2S.Salesforce_SubTeam_Code_gne__c;
        b2S.Salesforce_Name_gne__c = stgB2S.Salesforce_Name_gne__c;
        b2S.Salesforce_SubTeam_Name_gne__c = stgB2S.Salesforce_SubTeam_Name_gne__c;
        b2S.SFA_Brand_Name_gne__c = stgB2S.SFA_Brand_Name_gne__c;
	}
	
	global void finish(Database.BatchableContext BC) {
        if(skipErrors) {    
            metrics.setEndTime();
            sendNotificationEmail();            
        } else {
			doFinish(BC);
		}
	}
    
    private List<Staging_Brand_2_Salesforce_gne__c> removeIncorrectRecords(List<Staging_Brand_2_Salesforce_gne__c> stgObjs, Set<Id> incorrectRecordsIds) {
        List<Staging_Brand_2_Salesforce_gne__c> newListStgObjs = new List<Staging_Brand_2_Salesforce_gne__c>();
        for(Staging_Brand_2_Salesforce_gne__c record : stgObjs){
            if(!incorrectRecordsIds.contains(record.Id)) {
                newListStgObjs.add(record);
            }
        }
        return newListStgObjs;
    }
    
    private void sendNotificationEmail() {
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Map<String, GNE_Foun_Misc_Config_Items_gne__c> configItemsMap = GNE_Foun_Misc_Config_Items_gne__c.getAll();
        if (configItemsMap.containsKey( 'SubscribeNotfyEmail')) {
            String addr = configItemsMap.get( 'SubscribeNotfyEmail').Configuration_Value_gne__c;
            String[] addrs = (addr != null ? addr : UserInfo.getUserEmail()).split(';');
            email.setToAddresses(addrs);
            email.setSubject(createSubject() );
            email.setHtmlBody(prepareEmailBody());
            List<Messaging.Sendemailresult> error = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email}, false);
            if (!error[0].isSuccess()){
                System.debug('Couldn\'t send metrics summary email!');
            }  
        }        
    }
    
    private String prepareEmailBody() {
        String htmlBody = String.format(EMAIL_BODY, new List<String>{Datetime.now().format('MM/dd/yyyy hh:mm a'), metrics.processStart.format('MM/dd/yyyy hh:mm a'), metrics.processEnd.format('MM/dd/yyyy hh:mm a') });
        htmlBody += metrics.print();
        if(!recordsToReport.isEmpty()){                     
            htmlBody += MISSING_SETTING;
            String startTable = '<BR/><TABLE cellpadding="10" style="border:1px solid black;border-collapse:collapse;" cellspacing="5">'+
                '<TR><TH style="border:1px solid black;">LINK</TH> '+
                '<TH style="border:1px solid black;">CDM Brand Code</TH> '+
                '<TH style="border:1px solid black;">SFA Brand Name</TH>'+
                '<TH style="border:1px solid black;"> Salesforce Code</TH>'+
                '<TH style="border:1px solid black;" >Salesforce Name</TH>';
            String endTable   = '</TABLE>';
            htmlBody += startTable;
            for(Staging_Brand_2_Salesforce_gne__c record: recordsToReport ) {
                htmlBody +='<TR style="border:1px solid black;"><TD style="border:1px solid black;"><a href ="'+baseUrl+''+record.Id+'">'+record.Name+'</TD>';
                htmlBody +='<TD style="border:1px solid black;">'+record.CDM_Brand_Code_gne__c+'</TD>';
                htmlBody +='<TD style="border:1px solid black;">'+(record.SFA_Brand_Name_gne__c==null ? '---':record.SFA_Brand_Name_gne__c)+'</TD>';
                htmlBody +='<TD style="border:1px solid black;">'+(record.Salesforce_Code_gne__c==null ? '---':record.Salesforce_Code_gne__c)+'</TD>';
                htmlBody +='<TD style="border:1px solid black;">'+(record.Salesforce_Name_gne__c==null ? '---':record.Salesforce_Name_gne__c)+'</TD>';            
            }
            htmlBody +='</TR>'+endTable;
        }
        
        return htmlBody;        
    }
    
    private static String createSubject() {        
        String subject = 'GNE_Subscribe_Brand_2_Salesforce finished';
        if(isProductionEnv()){
            subject = '[PROD] '+subject;
        } else {
            String sandboxName = UserInfo.getUserName().substringAfterLast('.');
            subject = '[' + sandboxName.toUpperCase() + '] ' + subject;
        }

        return subject;    
    }
    
    private static Boolean isProductionEnv() {
        return ![SELECT IsSandbox FROM Organization LIMIT 1].IsSandbox;
    }
	
    private class SubscribeMetrics {
        private Integer inserted;
        private Integer updated;
        private Integer incorrect;
        private Integer processed;
        private Datetime processStart {get;set;}
        private Datetime processEnd {get;set;}
        
        private SubscribeMetrics() {
            processStart = System.now();
            inserted = updated = incorrect = processed = 0;
        }
        private void setEndTime() {
            processEnd = System.now();
        }
        
        private String print() {            
            String result =  String.format('Metrics for: Brand_2_Salesforce_gne__c (Inserted/Updated): {0}/{1}', new String[]{String.valueOf(inserted), String.valueOf(updated)});
            result += '<BR/><BR/>';
            result += String.format('Metrics for:Staging_Brand_2_Salesforce_gne__c (Processed/Incorrect): {0}/{1}', new String[]{String.valueOf(processed), String.valueOf(incorrect)});
            result += '<BR/><BR/>';
            return result;
        }
    }
}