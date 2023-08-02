public class SPCM_CARSPaymentExceptionPacketUtils extends SPCM_eWorkflowBaseUtils
{

    // abstract overrides
    protected override Integer GetMaxConcurrentApprovers()
    {
        return (1);
    }
    
    protected override String GetEmailRecallTemplate()
    {
        return ('CARS_Payment_Exception_Packet_Recalled');
    }
    
    protected override String GetObjectType()
    {
        return ('SPCM_CARS_Wholesaler_Exception_Payment__c');
    }
    
    protected override String GetHistoryKeyField()
    {
        return ('CARS_Payment_Exception_Packet__c');
    }
    
    public static void ValidateProductsForPayment(List<SObject> newRecords)
    {
    	
    	Set<Id> paymentIds = new Set<Id>();
    	for (SObject newRecord : newRecords)
    	{
    		SPCM_CARS_Wholesaler_Payment_Products__c paymentProduct = (SPCM_CARS_Wholesaler_Payment_Products__c)newRecord;
    		paymentIds.add(paymentProduct.CARS_Wholesaler_Exception_Payment__c);
    	}
    	
    	Map<Id, SPCM_CARS_Wholesaler_Exception_Payment__c> idToPaymentMap = new Map<Id, SPCM_CARS_Wholesaler_Exception_Payment__c>([SELECT Id, Approval_Status__c, OwnerId FROM SPCM_CARS_Wholesaler_Exception_Payment__c WHERE Id IN :paymentIds]);

    	for (SObject newRecord : newRecords)
    	{
    		
			SPCM_CARS_Wholesaler_Payment_Products__c paymentProduct = (SPCM_CARS_Wholesaler_Payment_Products__c)newRecord;
			
			System.debug(idToPaymentMap.get(paymentProduct.CARS_Wholesaler_Exception_Payment__c).Approval_Status__c);
			
			if(idToPaymentMap.get(paymentProduct.CARS_Wholesaler_Exception_Payment__c).Approval_Status__c != 'New' && idToPaymentMap.get(paymentProduct.CARS_Wholesaler_Exception_Payment__c).Approval_Status__c != 'Recalled')
			{
				paymentProduct.addError('You can only delete Products from CARS Wholesaler Exception Payment when Approval Status is set to \'New\' or \'Recalled\'.');
			}
			
			System.debug('OWNER : ' + idToPaymentMap.get(paymentProduct.CARS_Wholesaler_Exception_Payment__c).OwnerId + ' ' + UserInfo.getUserId());
						
			if(idToPaymentMap.get(paymentProduct.CARS_Wholesaler_Exception_Payment__c).OwnerId != UserInfo.getUserId())
			{
				paymentProduct.addError('You cannot delete Products from CARS Wholesaler Exception Payment because you are not the Owner of this record.');
			}

    	}
    }
    
    public void ValidateApprover(List<SObject> newRecords) 
    {
    	for (SObject newRecord : newRecords)
    	{
    		SPCM_CARS_Wholesaler_Exception_Payment__c payment = (SPCM_CARS_Wholesaler_Exception_Payment__c)newRecord;
    		
    		if(payment.Level_1_Approver__c != null) 
    		{
    			if(payment.Level_1_Approver__c == UserInfo.getUserId())
    			{
    				payment.addError('You cannot choose you as Level 1 Approver. Please select other use as Level 1 Approver.');
    			}	
    		}
    	}
    }

    protected override void HandleApprovalEvents(List<SObject> newRecords, List<SObject> oldRecords, SPCM_ApprovalProcessConfig processConfig, GNE_BusinessRoleConfig roleConfig, SPCM_ApprovalManager approvalMgr)
    {
    	
    	Id recordTypeReadOnlyId = [SELECT Id FROM RecordType WHERE SobjectType = 'SPCM_CARS_Wholesaler_Exception_Payment__c' AND Name = 'ReadOnly' LIMIT 1].Id;

        system.debug('newRecordssize' + newRecords.size());
        system.debug('newrecords' + newRecords);
        for (integer i = 0; i < newRecords.size(); i++)
        {
        
            // get new and old records
            SPCM_CARS_Wholesaler_Exception_Payment__c newRecord = (SPCM_CARS_Wholesaler_Exception_Payment__c)newRecords[i];
            SPCM_CARS_Wholesaler_Exception_Payment__c oldRecord = (SPCM_CARS_Wholesaler_Exception_Payment__c)oldRecords[i];

            system.debug('current newRecord' + newRecord);
            system.debug('current Oldrecord' + oldRecord);
            
            if(newRecord.Approval_Status__c == 'Recalled') 
            {
            	newRecord.OwnerId = newRecord.Initiated_By__c;
            }            
            
            if(newRecord.Approval_Status__c == 'Withdrawn') 
            {
            	newRecord.RecordTypeId = recordTypeReadOnlyId;
            }
            
            if(newRecord.Approval_Status__c == 'Rejected') 
            {
            	newRecord.OwnerId = UserInfo.getUserId();
            }
        
            // set last approver
            newRecord.Last_Approver__c = UserInfo.getUserId();
 
            // set prior, and reset current, approval fields
            newRecord.Appr_Prior_Approval_Level__c = oldRecord.Appr_Approval_Level__c;
            
            Decimal approvedAmount = newRecord.WER_Approved_Amount__c;
            
            if (newRecord.WER_Approved_Amount__c < 0)
            {
            	approvedAmount = approvedAmount * -1;
            }
            
            for (integer fieldNum = 1; fieldNum <= GetMaxConcurrentApprovers(); fieldNum++)
            {
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '__c', oldRecord.get('Appr_Approver_' + fieldNum + '__c'));
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '_Original__c', oldRecord.get('Appr_Approver_' + fieldNum + '_Original__c'));
                newRecord.put('Appr_Prior_Approver_' + fieldNum + '_Process_Level__c', oldRecord.get('Appr_Approver_' + fieldNum + '_Process_Level__c'));
                newRecord.put('Appr_Approver_' + fieldNum + '__c', null);
                newRecord.put('Appr_Approver_' + fieldNum + '_Original__c', null);
                newRecord.put('Appr_Approver_' + fieldNum + '_Process_Level__c', null);
            }

            System.debug('## Approval Level : ' + newRecord.Appr_Approval_Level__c);
                
            system.debug('Actual Proces level' +  approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c));

            system.debug('Actual Approval level' + newRecord.Appr_Approval_Level__c);

            system.debug('Approved Amount' + approvedAmount);



            SPCM_Approval_Process_Level__c processLevel = approvalMgr.GetProcessLevelById(approvalMgr.GetSingleProcessLevelId(GetObjectType(), newRecord.Appr_Approval_Level__c));
            
    
            
            // LEVEL 1
            if (newRecord.Appr_Approval_Level__c == 1)
            {
            	
				newRecord.Initiated_By__c = UserInfo.getUserId();
				
				if(newRecord.Level_1_Approver__c != null) 
				{
					
					String approverId = newRecord.Level_1_Approver__c;
					
                	newRecord.Appr_Approver_1_Original__c = approverId;
                    
		            // check for delegated approver
		            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
		              
		            // set approver
		            if (approverId != null && approverId != '')
		            {
		            	newRecord.Appr_Approver_1__c = approverId;
		            	newRecord.OwnerId = approverId;
		            	newRecord.Appr_Approver_1_Process_Level__c = String.valueOf(processLevel.Id);
					}
		    	    else
		        	{
		    	    	newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
		                    	'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
		                    	'Approval Level: ' + newRecord.Appr_Approval_Level__c);
		        	}
		        	
				}
				else 
				{
					SetApproverFromLevel(newRecord, processLevel);
				}

            }
            
            // LEVEL 2
            if (newRecord.Appr_Approval_Level__c == 2)
            {
            	
       
				if(approvedAmount > processLevel.Low_Amount__c)
				{
					SetApproverFromLevel(newRecord, processLevel);
				}
				else 
				{
                    system.debug('skipping');
					//insertSkippedRecord(newRecord, 'Level 2 - C-Ops Channel Manager Approval', String.valueOf(processLevel.User__c));
					newRecord.Appr_Approval_Level__c += 1;
				}
            }
            
            // LEVEL 3
            if (newRecord.Appr_Approval_Level__c == 3)
            {
            	
            	System.debug('# Skip this level ? ' + !(newRecord.WER_Requested_Amount__c > processLevel.Low_Amount__c));

				if (approvedAmount > processLevel.Low_Amount__c)
				{
                    if (newRecord.Level_3_Approver__c != null) {
                    	Map<Id, Id> level3ApproverMap = InitializeLevel3ApproverMap();
                    	String approverId = level3ApproverMap.get(newRecord.Level_3_Approver__c);
	                    if (String.isNotBlank(approverId)) {
						    newRecord.Appr_Approver_1_Original__c = approverId;
				            newRecord.Final_Approver__c = newRecord.Last_Approver__c;
				            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
				            system.debug('## approverId' + approverId);
				            if (approverId != null && approverId != '')
				            {
				            	newRecord.Appr_Approver_1__c = approverId;
				            	newRecord.Appr_Approver_1_Process_Level__c = String.valueOf(processLevel.Id);
							}
				    	    else
				        	{
				    	    	newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
				                    	'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
				                    	'Approval Level: ' + newRecord.Appr_Approval_Level__c);
				        	}
	                    } else {
	                      	newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
			            		'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
			                    'Approval Level: ' + newRecord.Appr_Approval_Level__c);
	                    }
                    } else {
						system.debug('skipping records');
						newRecord.Appr_Approval_Level__c += 1;
                    }
				}
				else 
				{
                    system.debug('skipping records');
					//insertSkippedRecord(newRecord, 'Level 3 - C-Ops Group Channel Manager Approval', String.valueOf(processLevel.User__c));
					newRecord.Appr_Approval_Level__c += 1;
				}
            }


            // FINISH
            if(newRecord.Appr_Approval_Level__c == 4) 
            {
            	newRecord.Final_Approver__c = newRecord.Last_Approver__c;
            	newRecord.OwnerId = newRecord.Final_Approver__c;
            }

        }
    }
    
    private static void SetApproverFromLevel(SPCM_CARS_Wholesaler_Exception_Payment__c newRecord, SPCM_Approval_Process_Level__c processLevel)
    {

        

        if (GetErrorsForLevel(processLevel) == null)
       	{
            String approverId;


    		// fetch approver Id from process level
            if (processLevel.User__c == null) {
                approverId = getBusinessRoleUser(processLevel);
            }else{
                approverId = processLevel.User__c;
            }
	        
            		
            newRecord.Appr_Approver_1_Original__c = approverId;
            newRecord.Final_Approver__c = newRecord.Last_Approver__c;
                    
            // check for delegated approver
            approverId = GNE_UserDelegationUtils.GetDelegatedUser(approverId);
            system.debug('## approverId' + approverId);
            // set approver
            if (approverId != null && approverId != '')
            {
            	newRecord.Appr_Approver_1__c = approverId;
            	newRecord.Appr_Approver_1_Process_Level__c = String.valueOf(processLevel.Id);
			}
    	    else
        	{
                system.debug('## approverId');
    	    	newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
                    	'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
                    	'Approval Level: ' + newRecord.Appr_Approval_Level__c);
        	}
        }
        else
        {
             system.debug('## ERROR2');
        	newRecord.addError('Request requires approval but approver definition is incorrect. ' + 
            		'Please contact the administrator. Approval Type: ' + newRecord.Approval_Type__c + '; ' + 
                    'Approval Level: ' + newRecord.Appr_Approval_Level__c);
		}
    }
    
    public static String GetErrorsForLevel(SPCM_Approval_Process_Level__c processLevel)
    {
        Id businessRoleUser =  getBusinessRoleUser(processLevel);
        if (processLevel == null)
        {
            system.debug('## NO process level defined');
            return 'No process level defined';
        }
        else if (processLevel.User__c == null && businessRoleUser == null)
        {
            system.debug('##No user defined for process level');
            return 'No user defined for process level';
        }
        else if (GNE_UserDelegationUtils.GetDelegatedUser(processLevel.User__c) == null && GNE_UserDelegationUtils.GetDelegatedUser(businessRoleUser) == null)
        {
            system.debug('##No delegated approver defined');
            return 'No delegated approver defined';
        }
        
        return null;
    }
    
    private  void insertSkippedRecord(SPCM_CARS_Wholesaler_Exception_Payment__c newRecord,String apprLevel,String apprId)
    {
            SPCM_Approval_History__c newHistoryRecord = new SPCM_Approval_History__c();
                                newHistoryRecord.Name = apprLevel;
                                newHistoryRecord.CARS_Payment_Exception_Packet__c= newRecord.Id;
                                 newHistoryRecord.Approval_Status__c = 'Approved';
                                 newHistoryRecord.Actual_Approver__c=apprId;
                                 newHistoryRecord.Original_Approver__c=apprId;
                                  newHistoryRecord.Start_Date__c=newRecord.LastModifiedDate;
                                  dateTime myDate = dateTime.now();
                                  newHistoryRecord.End_Date__c= myDate+0.00005;
                                newHistoryRecord.Comments__c='Auto approved due to delegation';
                                insert newHistoryRecord;
                                

    }
    
    private static Map<Id, Id> InitializeLevel3ApproverMap() {
        Map<Id, Id> approverMap = new Map<Id, Id>();
        for (SPCM_Level_3_Approver__c record : [SELECT Id, User__c FROM SPCM_Level_3_Approver__c]) {
			approverMap.put(record.Id, record.User__c);
        }
        return approverMap;
    }

   public static Id getBusinessRoleUser(SPCM_Approval_Process_Level__c processLevel) {
        List<User_Business_Role_gne__c> ubrList = [SELECT Id, User_gne__c, Business_Role_gne__c FROM User_Business_Role_gne__c WHERE Business_Role_gne__c =: processLevel.Business_Role__r.Name AND User_gne__c != null];
    
        if(!ubrList.isEmpty()) {
            id businessUser = ubrList[0].User_gne__c;
            system.debug('## CurrentBusinessUser' + businessUser);
            return businessUser;
        }else {
            system.debug('## NULL BUSINESS USER');
        }

        return null;

    }
    
}