/*
 * Staging_User_Assignments_Batch
 *
 * Created By :         Tomasz Kosecki (tomasz.kosecki@contractors.roche.com)
 * Last Modified By :   Tomasz Kosecki (tomasz.kosecki@contractors.roche.com)
 * Last Modified Date : 01/19/2017
 *
 * Comment:
 * - Batch class for processing Staging_User_Assignment_gne__c and UserTerritory2Association
 *
 */
global class Staging_User_Assignments_Batch implements Database.Batchable<sObject>, Database.Stateful, Database.AllowsCallouts {

	private String sessionId;
	private String userName;
	private List<Error_Log_gne__c> errorLogList = new List<Error_Log_gne__c>();
	private String batchId;

	global Staging_User_Assignments_Batch(String sessionId, String userName) {
		this.sessionId = sessionId;
		this.userName = userName;
	}

	global Database.QueryLocator start(Database.BatchableContext BC) {
		return Database.getQueryLocator([Select Id,
												Status_gne__c,
												Unalign_Date_gne__c,
												SFDC_User_gne__c,
												SFDC_UserTerritory_gne__c
					From Staging_User_Assignment_gne__c
					where Status_gne__c = 'Processed' AND SFDC_User_gne__c <> null AND SFDC_UserTerritory_gne__c <> null

			]);
	}

   	global void execute(Database.BatchableContext BC, List<sObject> scope) {
   		batchId = String.valueOf(bc.getJobId()) + '-' + String.valueOf(Datetime.now().getTime());
		List<Staging_User_Assignment_gne__c> recordsToUpdate = new List<Staging_User_Assignment_gne__c>();
		List<Staging_User_Assignment_gne__c> recordsToUpdateConfirmed = new List<Staging_User_Assignment_gne__c>();

        List<UserTerritory2Association> userTerritoriesToCreate = new List<UserTerritory2Association>();
        List<UserTerritory2Association> userTerritoriesToDelete = new List<UserTerritory2Association>();

        List<UserTerritoryMap> userTerrMapToDelete = new List<UserTerritoryMap>();
        List<UserTerritoryMap> userTerrMapToCreate = new List<UserTerritoryMap>();

		for (Staging_User_Assignment_gne__c record : (List<Staging_User_Assignment_gne__c>)scope) {
            try {
	            System.debug(record.SFDC_User_gne__c + ' -- ' + record.SFDC_UserTerritory_gne__c);
	            System.debug('DATE of Unalignment: ' + record.Unalign_Date_gne__c);

	            if (record.Unalign_Date_gne__c != null && record.Unalign_Date_gne__c < Date.today()) {
	                System.debug('Staging_User_Assignment_gne__c record id ' + record.Id + ' should be Unassigned');
	                record.Status_gne__c = 'Unassigned';
	                userTerrMapToDelete.add(new UserTerritoryMap(record.SFDC_User_gne__c, record.SFDC_UserTerritory_gne__c));
	            } else {
	            	System.debug('Staging_User_Assignment_gne__c record id ' + record.Id + ' should be Assigned');
	                UserTerritory2Association tmpUserTerr = new UserTerritory2Association();
	                tmpUserTerr.UserId = record.SFDC_User_gne__c;
	                tmpUserTerr.Territory2Id = record.SFDC_UserTerritory_gne__c;
	                userTerritoriesToCreate.add(tmpUserTerr);

	                record.Status_gne__c = 'Assigned';
	                userTerrMapToCreate.add(new UserTerritoryMap(record.SFDC_User_gne__c, record.SFDC_UserTerritory_gne__c));
	            }
	            recordsToUpdate.add(record);
	        } catch(Exception ex){
			    system.debug(ex.getMessage());

			    Error_Log_gne__c errLog = logError(ex.getMessage(), 'execute', 'Staging_User_Assignment_gne__c', record.id);
			    errorLogList.add(errLog);

			    insert errLog;
			}
        }

        try {
	        //delete unassigned territories for user
	    	List<UserTerritory2Association> userTerrList = [Select Id, UserId, Territory2Id from UserTerritory2Association where
	    												UserId IN :getUserIds(userTerrMapToDelete)
	    												AND Territory2Id IN :getTerritoryIds(userTerrMapToDelete)];
	    	for (UserTerritory2Association ut : userTerrList) {
				for (UserTerritoryMap utm : userTerrMapToDelete) {
					if(utm.territoryId == ut.Territory2Id && utm.userId == ut.userId) {
	            		userTerritoriesToDelete.add(ut);
	            		break;
					}
				}

	    	}
	        List<ResultElement> deleteResults = deleteUserTerritories(userTerritoriesToDelete);

	        //create assigned territories for user
	        List<ResultElement> createResults = createUserTerritories(userTerritoriesToCreate);

	        //log errors
	        List<Error_Log_gne__c> errList = new List<Error_Log_gne__c>();
	        errList.addAll(getResultErrLogs(deleteResults));
	        errList.addAll(getResultErrLogs(createResults));

	        errorLogList.addAll(errList);

	        if (!errList.isEmpty()) {
	        	insert errList;
	        }
	    } catch(Exception ex){
		    system.debug(ex.getMessage());

		    Error_Log_gne__c errLog = logError(ex.getMessage(), 'execute', 'UserTerritory2Association', null);
		    errorLogList.add(errLog);

		    insert errLog;
		}

		try{
	        //check state of UserTerritory2Association entries and prepare Staging_User_Assignment_gne__c objects to update properly
	        List<UserTerritory2Association> userTerrList = [Select Id, UserId, Territory2Id from UserTerritory2Association where
	        						(UserId IN :getUserIds(userTerrMapToDelete) OR UserId IN :getUserIds(userTerrMapToCreate))
	        					AND (Territory2Id IN :getTerritoryIds(userTerrMapToDelete) OR Territory2Id IN :getTerritoryIds(userTerrMapToCreate))];

	        for (Staging_User_Assignment_gne__c st : recordsToUpdate) {
	        	Boolean exist = false;
	        	for (UserTerritory2Association ut : userTerrList) {
	        		if (st.SFDC_User_gne__c == ut.userId && st.SFDC_UserTerritory_gne__c == ut.Territory2Id) {
	        			exist = true;
	        			break;
	        		}
	        	}
	        	if (exist && st.Status_gne__c == 'Assigned') {
	        		System.debug('Staging_User_Assignment_gne__c record id ' + st.Id + ' Assigned');
	        		recordsToUpdateConfirmed.add(st);
	        	} else if (!exist && st.Status_gne__c == 'Unassigned') {
	        		System.debug('Staging_User_Assignment_gne__c record id ' + st.Id + ' Unassigned');
	        		recordsToUpdateConfirmed.add(st);
	        	} else {
	        		//error
	        		String msg = 'Staging_User_Assignment_gne__c id ' + st.ID + ' should be updated but the cohesion with UserTerritory2Association is impaired';
	        		System.debug(msg);
	        		Error_Log_gne__c errLog = logError(msg, 'execute', 'Staging_User_Assignment_gne__c', st.ID);
	        		errorLogList.add(errLog);
		    		insert errLog;
	        	}

	        }

			//commit Staging_User_Assignment_gne__c
	    	if (!recordsToUpdateConfirmed.isEmpty()) {
	        	update recordsToUpdateConfirmed;
	        }
	    } catch(Exception ex){
		    system.debug(ex.getMessage());

		    Error_Log_gne__c errLog = logError(ex.getMessage(), 'execute', 'Staging_User_Assignment_gne__c', null);
		    errorLogList.add(errLog);

		    insert errLog;
		}
	}

	global void finish(Database.BatchableContext BC) {
		User activeUser = [Select Email From User where Username = :userName limit 1];
		String userEmail = activeUser.Email;

		List<String> lstToEmail = new List<String>();
		lstToEmail.add(userEmail);

		String body = '';
		if ( errorLogList.isEmpty() ) {
			body = 'Assigning/Unassigning users completed successfully.';
		} else {
			body = 'Assigning/Unassigning users completed with errors:<br /><br />';
			for (Error_Log_gne__c err : errorLogList) {
				body += err.Error_Description__c + '<br /><br />';
			}
		}
		String subject = 'Assigning/Unassigning users completed';
		sendEmails(lstToEmail, subject, body);

	}

	/*
		Send email with info and errors
	*/
	private void sendEmails(List<String> toEmail, String subject, String body) {
	    Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
	    String[] toAddresses        = toEmail;
	    mail.setToAddresses(toAddresses);
	    mail.setBccSender(false);
	    mail.setSubject(subject);

		mail.setHtmlBody(body);

		List<Messaging.Sendemailresult> emailResult;
		try{
			emailResult =  Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });
			if(emailResult!=null && !emailResult[0].isSuccess()) {
				List<Messaging.SendEmailError> emailError= emailResult[0].getErrors();
				if(emailError!=null) {
					System.debug('email error : ' + emailError[0].getMessage());
				}
			}
		}
		catch(Exception ex) {
			system.debug(ex.getMessage());
		    Error_Log_gne__c errLog = logError(ex.getMessage(), 'sendEmails', 'SingleEmailMessage', null);
		    insert errLog;
		}

	}

	/*
		Generate err logs based on soap results
	*/
	private List<Error_Log_gne__c> getResultErrLogs(List<ResultElement> results) {
		List<Error_Log_gne__c> result = new List<Error_Log_gne__c>();
		for (ResultElement re : results) {
        	if (!re.getSuccess()) {
        		result.add(logError(re.getMessage() + ' ' + re.getStatusCode(), 'execute', 'UserTerritory2Association', re.getId()));
        	}
	    }
	    return result;
	}

	/*
		Create UserTerritory2Association entries using soap api
	*/
	private List<ResultElement> createUserTerritories(List<UserTerritory2Association> userTerritoriesToCreate) {
		List<ResultElement> results = new List<ResultElement>();
		if (userTerritoriesToCreate != null && userTerritoriesToCreate.size() > 0) {
			results = doSoapAction('create', getSoapCreate(userTerritoriesToCreate));
		}
		return results;
	}

	/*
		Delete UserTerritory2Association entries using soap api
	*/
	private List<ResultElement> deleteUserTerritories(List<UserTerritory2Association> userTerritoriesToDelete) {
		List<ResultElement> results = new List<ResultElement>();
		if (userTerritoriesToDelete != null && userTerritoriesToDelete.size() > 0) {
			results = doSoapAction('delete', getSoapDelete(userTerritoriesToDelete));
		}
		return results;
	}

	/*
		Execute soap api action with given body
	*/
	private List<ResultElement> doSoapAction(String action, String body) {
		List<ResultElement> results = new List<ResultElement>();

		HttpRequest req = new HttpRequest();
		Http ht = new Http();
		String baseUrl = URL.getSalesforceBaseUrl().toExternalForm();

		req.setMethod('POST');
		req.setHeader('Content-Type', 'text/xml');
		req.setHeader('SOAPAction', action);
		req.setTimeout(120000);

		System.debug('Request: ' + body);
		req.setBody(body);
		req.setCompressed(false);
		req.setEndpoint(baseUrl + '/services/Soap/u/37.0');
		try {

			HTTPResponse res = ht.send(req);
			System.debug('Response: ' + res.getBody());

			if (res.getStatus() == 'OK') {
	            System.debug('##### XML Body === ' + res.getBodyDocument());
	            dom.Document doc = res.getBodyDocument();
	            if (doc != null) {
	                parseResults(doc.getRootElement(), results);
	            }
	        }

	        for (ResultElement re : results) {
	        	System.debug(action + ' result: ' + re.getId() + ', ' + re.getSuccess() + ', ' + re.getMessage() + ', ' + re.getStatusCode());
	        }

		} catch( exception ex){
		    Error_Log_gne__c errLog = logError(ex.getMessage(), 'doSoapAction', 'UserTerritory2Association', null);
		    errorLogList.add(errLog);

		    insert errLog;
		}

		return results;
	}

	/*
		Parse soap response
	*/
	private void parseResults(dom.XMLNode node, List<ResultElement> results) {
		if (results == null) {
			results = new List<ResultElement>();
		}
		if(node != null && node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
			if(node.getName().trim() == 'result') {
				ResultElement re = new ResultElement();
				for (Dom.XMLNode child: node.getChildElements()) {
					if (child.getName().trim() == 'id') {
						re.setId(child.getText().trim());
					}
					if (child.getName().trim() == 'success') {
						re.setSuccess(child.getText().trim());
					}
					if (child.getName().trim() == 'errors') {
						for(DOM.XMLNode grandChild : child.getChildElements()) {
							if (grandChild.getName().trim() == 'message') {
								re.setMessage(grandChild.getText().trim());
							}
							if (grandChild.getName().trim() == 'statusCode') {
								re.setStatusCode(grandChild.getText().trim());
							}
						}
					}
				}
				results.add(re);
				return;
			}
			for(DOM.XMLNode child : node.getChildElements()) {
				parseResults(child, results);
			}
        }
		return;
    }

    /*
		Build soap request xml for delete action
    */
	private String getSoapDelete(List<UserTerritory2Association> userTerritoriesToDelete) {
		String result = '<?xml version="1.0" encoding="UTF-8"?>' +
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com">'+
		   '<soapenv:Header>             '+
		      '<urn:AllOrNoneHeader>'+
		         '<urn:allOrNone>0</urn:allOrNone>'+
		      '</urn:AllOrNoneHeader>'+
		      '<urn:SessionHeader>'+
		         '<urn:sessionId>' + sessionId + '</urn:sessionId>'+
		      '</urn:SessionHeader>'+
		   '</soapenv:Header>'+
		   '<soapenv:Body>'+
		      '<urn:delete>';
		for (UserTerritory2Association ut : userTerritoriesToDelete) {
			result += '<urn:ids>' + ut.Id + '</urn:ids>';
		}
		result += '</urn:delete>'+
		   '</soapenv:Body>'+
		'</soapenv:Envelope>';

		return result;
	}

 	/*
		Build soap request xml for create action
    */
	private String getSoapCreate(List<UserTerritory2Association> userTerritoriesToDelete) {
		String result = '<?xml version="1.0" encoding="UTF-8"?>' +
		'<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:urn="urn:partner.soap.sforce.com" xmlns:urn1="urn:sobject.partner.soap.sforce.com">'+
		   '<soapenv:Header>             '+
		      '<urn:AllOrNoneHeader>'+
		         '<urn:allOrNone>0</urn:allOrNone>'+
		      '</urn:AllOrNoneHeader>'+
		      '<urn:SessionHeader>'+
		         '<urn:sessionId>' + sessionId + '</urn:sessionId>'+
		      '</urn:SessionHeader>'+
		   '</soapenv:Header>'+
		   '<soapenv:Body>'+
		      '<urn:create>';
		for (UserTerritory2Association ut : userTerritoriesToDelete) {
			result += '<urn:sObjects><urn1:type>UserTerritory2Association</urn1:type>';
			result += '<urn1:UserId>' + ut.userId + '</urn1:UserId><urn1:TerritoryId>' + ut.Territory2Id + '</urn1:TerritoryId>';
			result += '</urn:sObjects>';
		}
		result += '</urn:create>'+
		   '</soapenv:Body>'+
		'</soapenv:Envelope>';

		return result;
	}


	private static List<Id> getUserIds(List<UserTerritoryMap> utm) {
		List<Id> result = new List<Id>();
		if (utm != null) {
			for (UserTerritoryMap u : utm) {
				result.add(u.userId);
			}
		}
		return result;
	}

	private static List<Id> getTerritoryIds(List<UserTerritoryMap> utm) {
		List<Id> result = new List<Id>();
		if (utm != null) {
			for (UserTerritoryMap u : utm) {
				result.add(u.territoryId);
			}
		}
		return result;
	}


	/*
		Prepare err log record
	*/
	private Error_Log_gne__c logError(String message, String method, String objName, String recordId) {
		Error_Log_gne__c err = new Error_Log_gne__c();
		err.Code_Type__c = 'Apex Batch Class';
		err.Error_Level_gne__c = 'Low';
		err.Error_Description__c = message;
		err.Object_Name__c = objName;
		err.Record_Id_gne__c = recordId;
		err.Snippet_Name__c = 'Staging_User_Assignments_Batch.' + method + '.batchId-' + batchId;
		err.User_Name__c = userName;
		return err;
	}

	/*
		Wrapper class for soap response results
	*/
	private class ResultElement {
		private String id;
		private Boolean success;
		private String message;
		private String statusCode;

		public String getId() {
			return id;
		}

		public void setId(String id) {
			this.id = id;
		}

		public Boolean getSuccess() {
			return success;
		}

		public void setSuccess(Boolean s) {
			this.success = s;
		}

		public void setSuccess(String s) {
			if (String.isNotEmpty(s) && s.trim().equalsIgnoreCase('true')) {
				success = true;
			} else {
				success = false;
			}
		}

		public String getMessage() {
			return message;
		}

		public void setMessage(String e) {
			message = e;
		}

		public String getStatusCode() {
			return statusCode;
		}

		public void setStatusCode(String e) {
			statusCode = e;
		}
	}

	/*
		Determine whether timeout exception in soap action occured based on Error_Log_gne__c entries
	*/
	public static Boolean timeoutOccured(Id batchId) {
		Boolean result = false;
		String query = 'select id, Error_Description__c from  Error_Log_gne__c ' +
			' where Snippet_Name__c like \'Staging_User_Assignments_Batch.doSoapAction.batchId-' + String.valueOf(batchId) + '-%\'';
		List<Error_Log_gne__c> errList = Database.query(query);

		for (Error_Log_gne__c er : errList) {
			if (er.Error_Description__c.equalsIgnoreCase('Read timed out')) {
				result = true;
				break;
			}
		}
		return result;
	}


	/*
		Mapping class for user id and territory id
	*/
	private class UserTerritoryMap {
		public Id userId {get; set;}
		public Id territoryId {get; set;}

		public UserTerritoryMap(Id userId, Id territoryId) {
			this.userId = userID;
			this.territoryId = territoryId;
		}
	}
}