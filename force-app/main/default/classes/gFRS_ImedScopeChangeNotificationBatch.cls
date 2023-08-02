global with sharing class gFRS_ImedScopeChangeNotificationBatch implements Database.Batchable<sObject> {
	
	private Map<Id, List<GFRS_Program__c>> requestIdToPrograms = new Map<Id, List<GFRS_Program__c>>();
	Id senderId                                                = [select Id, Address from OrgWideEmailAddress where Address = 'fundingrequestsystem-donotreply-d@gene.com' limit 1][0].Id;
	EmailTemplate sendTemplate                                 = [SELECT Id, HtmlValue FROM EmailTemplate WHERE developerName = 'IMED_Scope_Change_Email_Notification'];
	
	private void getCanceledProgramsForRequestList(List<GFRS_Funding_Request__c> requestList){
		for(GFRS_Program__c tmpProgram : [select Funding_Request__r.Id, Funding_Request__r.Scope_Change_Date__c, Program_Status__c, Type__c, Venue_City__c, Start_Date__c, End_Date__c, LastModifiedDate, Program_Subtype__c
			from GFRS_Program__c 
			where Program_Status__c = 'Canceled' AND Funding_Request__c in :requestList]){
				
				if(requestIdToPrograms.containsKey(tmpProgram.Funding_Request__r.Id)){
					requestIdToPrograms.get(tmpProgram.Funding_Request__r.Id).add(tmpProgram);
				}else{
					requestIdToPrograms.put(tmpProgram.Funding_Request__r.Id, new List<GFRS_Program__c>{tmpProgram});
				}
			}
	}
	
	global Database.Querylocator start(Database.BatchableContext BC){

		Date newDate   = date.today().addDays(-1);
		Integer year   = newDate.year();
		Integer month  = newDate.month();
		Integer day    = newDate.day();
		String dayOut  = '' + day;
		String montOut = '' + month;

		if( month<10 ) montOut = '0' + month;
		if( day<10 ) dayOut = '0' + day;

		String out   = year + '-' + montOut + '-' + dayOut;
		String query = 'select Id, Scope_Change_Date__c, Business_Approver__r.email, Therapeutic_Area__c, name, Event_Program_Title__c, Did_Total_Budget_Amount_for_this_Program__c, If_Yes_New_Total_Budget_for_Program__c, Change_in_Number_of_Commercial__c, If_Yes_How_Many_Commercial__c, Did_Educational_Objectives_Change__c, If_Yes_New_Educational_Objectives__c from GFRS_Funding_Request__c where Scope_Change_Date__c =\'' +out+'\'';    

        return Database.getQueryLocator(query);
    }
    global void execute(Database.BatchableContext BC, List<sObject> scope){
    	
    	getCanceledProgramsForRequestList(((List<GFRS_Funding_Request__c>)scope));
    	
    	List<GFRS_Funding_Request__c> itempsToUpdate = new List<GFRS_Funding_Request__c>();
    	
    	for(GFRS_Funding_Request__c item : (List<GFRS_Funding_Request__c>)scope){
    		itempsToUpdate.add(item);
    	}
    	sendEmails(itempsToUpdate);
    }
    

    global void finish(Database.BatchableContext BC){
        system.debug('execution ended successfully');
    }
    
    public void sendEmails(List<GFRS_Funding_Request__c> itemsToUpdate){
    	
    	
		Messaging.SingleEmailMessage[] mails = new Messaging.SingleEmailMessage[]{}; 
		Messaging.SingleEmailMessage tmpMail = new Messaging.SingleEmailMessage();
		String[] toAddresses                 = new String[]{'szepietk@roche.com'};

		tmpMail.setToAddresses(toAddresses);
		tmpMail.setUseSignature(false);
		tmpMail.setSaveAsActivity(false);
		tmpMail.setSenderDisplayName('MMPT');
		tmpMail.setTargetObjectId(UserInfo.getUserId());
		tmpMail.setTemplateId(sendTemplate.Id);
		
		Savepoint sp                                           = Database.setSavepoint();
		Messaging.sendEmail(new Messaging.SingleEmailMessage[] {tmpMail});
		/*
		      WORKAROUND
		*/
		Database.rollback(sp);
		/*
		  We had to make this workaround with rollback, because on the time we developed this functionality there was a problem with loading Letterhead by salesforce.
		*/
		
		String bccEmailAddress='';
		GFRS_OrgSettings__c myOrgCS = GFRS_OrgSettings__c.getOrgDefaults();
        if(myOrgCS.gFRS_Inbound_Email__c != null){
               bccEmailAddress = myOrgCS.gFRS_Inbound_Email__c;
        }
        
        for(GFRS_Funding_Request__c item : itemsToUpdate){
        	
            System.debug('PN:: TEST:PROGRAMS: ' + requestIdToPrograms.get(item.Id));
            System.debug('PN:: TEST:REQUEST: ' + item);
            
			String canceledProgramsPlain           = '';
			String canceledProgramsHtml            = '';
			String canceledProgramStartDate        = '';
			String canceledProgramEndDate          = '';
			String canceledProgramLastModifiedDate = '';
            
            
            
			String subject                    = item.Therapeutic_Area__c + ': ' + item.Name + ' - Scope Change';
			Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
			List<String> addressList          = new List<String>();

            addressList.add(System.Label.gFRS_IMED_ScopeChangeAddress);

            if(item.Business_Approver__r != null && item.Business_Approver__r.email != null){
            	addressList.add(item.Business_Approver__r.email);
            }
            mail.setToAddresses(addressList);
            if(bccEmailAddress != null){
                    mail.setBccAddresses(new List<String>{bccEmailAddress});
            }
            
            mail.setSubject( subject );
            //String body = 'Dear '+r.CreatedBy.FirstName+' '+r.CreatedBy.LastName+',\n\nfunding request '+r.Name+' chenged status within the past 30 days.\n\n Genentech Team';
            String plainText = tmpMail.getPlainTextBody();
            plainText = plainText.replace('GFRS_Funding_Request__c.Name',item.Name).replace('GFRS_Funding_Request__c.Event_Program_Title__c',item.Event_Program_Title__c == null?'':item.Event_Program_Title__c).replace('GFRS_Funding_Request__c.Scope_Change_Date__c',item.Scope_Change_Date__c == null?'':item.Scope_Change_Date__c).replace('GFRS_Funding_Request__c.Did_Total_Budget_Amount_for_this_Program__c',item.Did_Total_Budget_Amount_for_this_Program__c == null?'':item.Did_Total_Budget_Amount_for_this_Program__c).replace('GFRS_Funding_Request__c.If_Yes_New_Total_Budget_for_Program__c',item.If_Yes_New_Total_Budget_for_Program__c == null?'':currency(String.valueOf(item.If_Yes_New_Total_Budget_for_Program__c))).replace('GFRS_Funding_Request__c.Change_in_Number_of_Commercial__c',item.Change_in_Number_of_Commercial__c == null?'':item.Change_in_Number_of_Commercial__c).replace('GFRS_Funding_Request__c.If_Yes_How_Many_Commercial__c',item.If_Yes_How_Many_Commercial__c == null?'':String.valueOf((integer)item.If_Yes_How_Many_Commercial__c)).replace('GFRS_Funding_Request__c.Did_Educational_Objectives_Change__c',item.Did_Educational_Objectives_Change__c == null?'':item.Did_Educational_Objectives_Change__c).replace('GFRS_Funding_Request__c.If_Yes_New_Educational_Objectives__c',item.If_Yes_New_Educational_Objectives__c == null?'':String.valueOf(item.If_Yes_New_Educational_Objectives__c)).replace('GFRS_Funding_Request__c.Id',item.id);
            
            if( requestIdToPrograms != null && requestIdToPrograms.containsKey(item.Id) && requestIdToPrograms.size()>0){
            
                canceledProgramsPlain += 'If a program was canceled: \n\n';
                canceledProgramsHtml += 'If a program was canceled: <br /><br />';
                
	            for(GFRS_Program__c tmpProgram : requestIdToPrograms.get(item.Id)){
	            	
	            	canceledProgramStartDate = tmpProgram.Start_Date__c != null ? tmpProgram.Start_Date__c.format() : '';
	                canceledProgramEndDate = tmpProgram.End_Date__c != null ? tmpProgram.End_Date__c.format() : '';
	                canceledProgramLastModifiedDate = tmpProgram.LastModifiedDate != null ? tmpProgram.LastModifiedDate.format(System.Label.gFRS_PST_Date_Pattern, System.Label.gFRS_PST_Signature) : '';
	                
	                 
	                
	                
	                if(tmpProgram.Type__c != null){
	                	canceledProgramsPlain += tmpProgram.Type__c + '\n';
	                	canceledProgramsHtml += tmpProgram.Type__c + '<br />';
	                }
	                if(tmpProgram.Program_Subtype__c != null){
	                	canceledProgramsPlain +=  tmpProgram.Program_Subtype__c + '\n' ;
	                	canceledProgramsHtml +=  tmpProgram.Program_Subtype__c + '<br />'; 
	                }
	                if(tmpProgram.Program_Status__c != null){
	                	canceledProgramsPlain +=  tmpProgram.Program_Status__c + '\n'; 
	                	canceledProgramsHtml +=  tmpProgram.Program_Status__c + '<br />';
	                }
	                if(tmpProgram.Venue_City__c != null){
	                	canceledProgramsPlain += tmpProgram.Venue_City__c + '\n'; 
	                	canceledProgramsHtml += tmpProgram.Venue_City__c + '<br />'; 
	                }
	                canceledProgramsPlain += Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel() + ': ' + canceledProgramStartDate + '\n' + Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel() + ': ' + canceledProgramEndDate + '\n' + Schema.sObjectType.GFRS_Program__c.fields.LastModifiedDate.getLabel() + ': ' + canceledProgramLastModifiedDate + '\n';
	                canceledProgramsHtml += Schema.sObjectType.GFRS_Program__c.fields.Start_Date__c.getLabel() + ': ' + canceledProgramStartDate + '<br />' + Schema.sObjectType.GFRS_Program__c.fields.End_Date__c.getLabel() + ': ' + canceledProgramEndDate + '<br />' + Schema.sObjectType.GFRS_Program__c.fields.LastModifiedDate.getLabel() + ': ' + canceledProgramLastModifiedDate + '<br /><br />';
	                
	                
	                
	            }
            }
            
            plainText = plainText.replace('[[programs]]', canceledProgramsPlain);
            
			plainText       += '\n\n' + '[ref:' + item.Id + ']';
			String htmlText = tmpMail.getHTMLBody();
			htmlText        = htmlText.replace('GFRS_Funding_Request__c.Name',item.Name).replace('GFRS_Funding_Request__c.Event_Program_Title__c',item.Event_Program_Title__c == null?'':item.Event_Program_Title__c).replace('GFRS_Funding_Request__c.Scope_Change_Date__c',item.Scope_Change_Date__c == null?'':item.Scope_Change_Date__c).replace('GFRS_Funding_Request__c.Did_Total_Budget_Amount_for_this_Program__c',item.Did_Total_Budget_Amount_for_this_Program__c == null?'':item.Did_Total_Budget_Amount_for_this_Program__c).replace('GFRS_Funding_Request__c.If_Yes_New_Total_Budget_for_Program__c',item.If_Yes_New_Total_Budget_for_Program__c == null?'':currency(String.valueOf(item.If_Yes_New_Total_Budget_for_Program__c))).replace('GFRS_Funding_Request__c.Change_in_Number_of_Commercial__c',item.Change_in_Number_of_Commercial__c == null?'':item.Change_in_Number_of_Commercial__c).replace('GFRS_Funding_Request__c.If_Yes_How_Many_Commercial__c',item.If_Yes_How_Many_Commercial__c == null?'':String.valueOf((integer)item.If_Yes_How_Many_Commercial__c)).replace('GFRS_Funding_Request__c.Did_Educational_Objectives_Change__c',item.Did_Educational_Objectives_Change__c == null?'':item.Did_Educational_Objectives_Change__c).replace('GFRS_Funding_Request__c.If_Yes_New_Educational_Objectives__c',item.If_Yes_New_Educational_Objectives__c == null?'':String.valueOf(item.If_Yes_New_Educational_Objectives__c)).replace('GFRS_Funding_Request__c.Id',item.id);
			htmlText        = htmlText.replace('[[programs]]', canceledProgramsHtml);
            mail.setPlainTextBody(plainText);
            mail.setHtmlBody(htmlText);
            mail.setOrgWideEmailAddressId(senderId);
            mails.add(mail);
            
        }
        
        Messaging.sendEmail(mails,false);
    }
    
    public static String currency(String i) {
	    String s = ( Decimal.valueOf(i == null || i.trim() == '' ? '0' : i).setScale(2) + 0.001 ).format();
	    return '$ '+ s.substring(0,s.length()-1);
	}
}