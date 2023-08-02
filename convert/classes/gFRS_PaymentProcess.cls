/**
* @author GFRS Dev Team
* @date 14/08/2013
* @description gFRS_PaymentProcess class - class used in triggers for storing methods connected with payment process. 
*/
public without sharing class gFRS_PaymentProcess extends gFRS_FundingProcess {
    
    /*** Funding Allocation Methods ***/
    
    /**
	* @author GFRS Dev Team	
	* @date 14/08/2013
	* @description createFundingAllocation method - creates default Funding Allocation record. 
	*/

    public static Set<ID> SETRequestToAvoidcreateFundingAllocation = new Set<ID>();

    public override void createFundingAllocation(Map<Id, GFRS_Funding_Request__c> newMapFundingRequest, Map<Id, gFRS_Funding_Request__c> oldRequests) {
        

        Boolean bCreateFA                                     = false;
        gFRS_Funding_Allocation__c newObjFundingAllocation    = null;
        gFRS_Funding_Allocation__c[] tabObjFundingAllocations = new gFRS_Funding_Allocation__c[]{};
        GFRS_Funding_Request__c newObjRequest                 = null;
        String strFiscalYear                                  = String.valueOf( date.today().year() );
        
        Set<ID> SetToChangedFunding = new Set<ID>();

        for(ID st : newMapFundingRequest.keySet()){
            if(!SETRequestToAvoidcreateFundingAllocation.contains(st)){
                SetToChangedFunding.add(st);
                SETRequestToAvoidcreateFundingAllocation.add(st);
            }
        }

        List<GFRS_Funding_Request__c> ListForLoopFundingRequest = new List<GFRS_Funding_Request__c>();

        if(SetToChangedFunding.size() > 0){
         ListForLoopFundingRequest = [
            SELECT Id, Record_Type_Name__c, ( SELECT Id FROM Funding_Allocations__r ) FROM gFRS_Funding_Request__c
            WHERE Id IN :SetToChangedFunding
        ];
        }


        for(GFRS_Funding_Request__c objRequest : ListForLoopFundingRequest)
        {
            //-- only requests under consideration are those that do not have allocations
            if( objRequest.Funding_Allocations__r == null || objRequest.Funding_Allocations__r.size() < 1 )
            {
                newObjRequest = newMapFundingRequest.get( objRequest.id );
                bCreateFA     = false;
                
                if( gFRS_Util.TYPE_IMED_NAME.equals( objRequest.Record_Type_Name__c ))
                {
                    if(newObjRequest.Therapeutic_Area__c != null)bCreateFA = true;
                    
                } 
                else if( gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME.equals( objRequest.Record_Type_Name__c ) &&  newObjRequest.Requested_Amount__c != null)
                {
                    bCreateFA = true;
                    
                } 
                else if( gFRS_Util.isInternalRequest( objRequest.Record_Type_Name__c ) && newObjRequest.Requested_Amount__c != null )
                {
                  bCreateFA = true;
                } 
                else
                {
                    bCreateFA = true;
                } 
                    if(bCreateFA)
                    {
                        newObjFundingAllocation = new GFRS_Funding_Allocation__c(Grant_Request__c = objRequest.Id, Fiscal_Year__c = strFiscalYear, RecordTypeId=idPaymentType);
                        tabObjFundingAllocations.add( newObjFundingAllocation );
                    } 
            }
        }
        
        if( tabObjFundingAllocations.size() > 0 )
        {
            try
            {
                 insert tabObjFundingAllocations;
            }
            catch(System.DmlException ex)
            {
                 for (Integer i = 0; i < ex.getNumDml(); i++)
                 {
                    System.debug(ex.getDmlMessage(i)); 
                 }
            }
        }  
    }
    
    
    /**
	* @author GFRS Dev Team
	* @date 14/08/2013
	* @description createDefaultFALineItems method - Method creates default Funding Allocation Line Items under initial master FA record
	*/
	public override void createDefaultFALineItems(GFRS_Funding_Allocation__c[] arrFundingAllocations)
	{
		String strFARecordType;

        GFRS_Cost_Center_Code__c costCode                 = null;
        GFRS_Cost_Center_Code__c[] costCodes              = null;
        Map<String,Id> costCodeMap                        = new Map<String,Id>();
        
        GFRS_Funding_Allocation_Line_Item__c newFALine    = null;
        GFRS_Funding_Allocation_Line_Item__c[] newFALines = new GFRS_Funding_Allocation_Line_Item__c[]{};
        
        GFRS_OrgSettings__c myOrgCS                       = GFRS_OrgSettings__c.getOrgDefaults();    
		
		
        for( GFRS_Cost_Center_Code__c costCenterCodeToProcess : [SELECT 
																	Id, 
																	IsActive__c,
																	Name
																FROM GFRS_Cost_Center_Code__c
																WHERE IsActive__c = true AND Name =:myOrgCS.CapDefaultCostCenterForLI__c ]){
														           
            if( myOrgCS.CapDefaultCostCenterForLI__c  == costCenterCodeToProcess.Name ){
            	
            	//Cost Center Code for CAPP
            	costCodeMap.put(myOrgCS.CapDefaultCostCenterForLI__c, costCenterCodeToProcess.Id);	
            	break;	
            }

        }
        
		//Main loop
		for (GFRS_Funding_Allocation__c allocation :
            [SELECT Id, Name, Fiscal_Year__c, Grant_Request__r.Therapeutic_Area__c, 
                Grant_Request__r.Requested_Amount__c, Grant_Request__r.Record_Type_Name__c
                FROM GFRS_Funding_Allocation__c
                WHERE RecordTypeId =:idPaymentType
                AND Id in : arrFundingAllocations])
        {
        	//Record Type of parent Funding Request
            strFARecordType = allocation.Grant_Request__r.Record_Type_Name__c;
            Id costCodeId   = null;

        	if(strFARecordType == gFRS_Util.TYPE_FELLOWSHIPS_NAME 
                || strFARecordType == gFRS_Util.TYPE_HC_CHAR_NAME 
                || strFARecordType == gFRS_Util.TYPE_PHILANTHROPIC_NAME 
                || strFARecordType == gFRS_Util.TYPE_SCIENTIFIC_PROJECTS_NAME){

        		costCodeId = costCodeMap.get(myOrgCS.CapDefaultCostCenterForLI__c);
        	}

        	//Internal Requests
        	if(gFRS_Util.isInternalRequest(strFARecordType))
            {
            	if(strFARecordType == gFRS_Util.TYPE_CORPORATE_MEMBERSHIPS_NAME 
                    || strFARecordType == gFRS_Util.TYPE_EXHIBHITS_OTHER_PROMOS_NAME 
                    || strFARecordType == gFRS_Util.TYPE_SCI_PIPELINE_EXHIBITS_NON_PROMO_NAME)
            	{	
            		// No Cost Center needed
                    newFALine              = new GFRS_Funding_Allocation_Line_Item__c(
                    Funding_Allocation__c  = allocation.Id,  
                    Percent__c             = 100, 
                    Split_Number__c        = 1,
                    WBS_Code_Lookup__c     = null,
                    Funding_Record_Type__c = strFARecordType
                    );
                    newFALines.add( newFALine );
             	}else{
             		// For FIE Cost Center must be set under Application external page	
                    
                    newFALine              = new GFRS_Funding_Allocation_Line_Item__c(
                    Funding_Allocation__c  = allocation.Id,  
                    Percent__c             = 100, 
                    Cost_Center_Lookup__c  = costCodeId, 	
                    Split_Number__c        = 1,
                    WBS_Code_Lookup__c     = null,
                    Funding_Record_Type__c = strFARecordType
                    );
                    newFALines.add( newFALine );
             	}	
            }
            else //all other requests HC Char, Fellowship, Sci Proj, Philanthropic. IMED will be created on FundingAllcationRadPage
            {
            	
            	if(strFARecordType != gFRS_Util.TYPE_IMED)
            	{
            		//for HC Char, Fellowship, Sci Proj, Philanthropic 
                    newFALine              = new GFRS_Funding_Allocation_Line_Item__c(
                    Funding_Allocation__c  = allocation.Id,  
                    Amount__c              = null, 
                    Percent__c             = 100, 
                    Cost_Center_Lookup__c  = costCodeId,
                    Funding_Record_Type__c = strFARecordType);
                            
                    newFALines.add( newFALine );      
            	}
            		            	
            }
        }
		
		try
        {
         	
            if(newFALines.size()>0)
            { 
                insert newFALines;
            }
         } 
         catch( Exception err )
         {
            System.debug( err.getmessage() );
         }		
	}
	

    /**
	* @author GFRS Dev Team
	* @date 14/08/2013
	* @description createDefaultFALineItemsWBSForIMED method - Method creates default Funding Allocation Line Items under initial master FA record for IMED
	*/
	public void createDefaultFALineItemsWBSForIMED(GFRS_Funding_Allocation__c[] arrFundingAllocations)
	{
		String fundingAllocationRecordType;
		
		//WBS Codes collection
        GFRS_WBS_Codes__c wbsCode                                        = null;
        List<gFRS_Imed_Ds_Wbs_Mapping__c> mappedWbs                      = new List<gFRS_Imed_Ds_Wbs_Mapping__c>();
        Map<String, gFRS_Imed_Ds_Wbs_Mapping__c[]> imedMappingObjectsMap = new map<String, gFRS_Imed_Ds_Wbs_Mapping__c[]>();
        
        // Cost centers collection
        GFRS_Cost_Center_Code__c costCode                = null;
        GFRS_Cost_Center_Code__c[] costCodes             = null;
        Map<String,GFRS_Cost_Center_Code__c> costCodeMap = new Map<String,GFRS_Cost_Center_Code__c>();
        
        //Funding Allocation line items collection
        GFRS_Funding_Allocation_Line_Item__c newFALine    = null;
        GFRS_Funding_Allocation_Line_Item__c[] newFALines = new GFRS_Funding_Allocation_Line_Item__c[]{};
        GFRS_OrgSettings__c myOrgCS                       = GFRS_OrgSettings__c.getOrgDefaults();
        
        //Initial collections
        //Creating WBS code map. Only Used for IMED
        for(gFRS_Imed_Ds_Wbs_Mapping__c mappingItem : [SELECT 
            												Id, 
            												Name, 
            												Disease_State__c, 
            												Funding_Type__c, 
            												isActive__c, 
            												IsDeleted, 
            												Percent_Allocation__c, 
            												WBS_Code__c, 
            												WBS_Name__c 
        												FROM gFRS_Imed_Ds_Wbs_Mapping__c
        												WHERE isActive__c = true AND isDeleted = false
        												]){
													
			String wbsKey = mappingItem.Disease_State__c;
			if( imedMappingObjectsMap.containsKey( wbsKey )){
                imedMappingObjectsMap.get( wbsKey ).add( mappingItem );
            } else {
                imedMappingObjectsMap.put( wbsKey, new gFRS_Imed_Ds_Wbs_Mapping__c[]{ mappingItem } );
            }								
		}
		
		//Creating WBS cost center map    
		GFRS_Cost_Center_Code__c costCodeForImed = [	SELECT 
															Id, 
															IsActive__c,
															Name
														FROM GFRS_Cost_Center_Code__c
														WHERE IsActive__c = true
														AND Cost_Center__c =: myOrgCS.IMEDDefaultCostCenterForLI__c LIMIT 1];

        
		//Main loop
		for (GFRS_Funding_Allocation__c allocation : [ SELECT 
															Id, 
															Name, 
															Fiscal_Year__c, 
															Grant_Request__r.Therapeutic_Area__c, 
															Grant_Request__r.Requested_Amount__c, 
															Grant_Request__r.Record_Type_Name__c
            											FROM GFRS_Funding_Allocation__c
            											WHERE RecordTypeId=:idPaymentType AND Id IN : arrFundingAllocations])
        {
        	//get record type	
        	fundingAllocationRecordType = allocation.Grant_Request__r.Record_Type_Name__c;

        	//IMED need try find WBS code
        	if(fundingAllocationRecordType == gFRS_Util.TYPE_IMED)
        	{
        		//create WBS Key
        		String strWBSKey = allocation.Grant_Request__r.Therapeutic_Area__c;
        		//try find Wbs key in WBS collection 
        		if( imedMappingObjectsMap.containsKey( strWBSKey ) && imedMappingObjectsMap.get(strWBSKey) != null )
            	{
            		//Wbs key found
            		mappedWbs = imedMappingObjectsMap.get(strWBSKey);
                  		
                  		for(gFRS_Imed_Ds_Wbs_Mapping__c mappingItem : mappedWbs )
                  		{
	                       	//create one line for each matching wbs code
                            newFALine              = new GFRS_Funding_Allocation_Line_Item__c(
                            Funding_Allocation__c  = allocation.Id,  
                            WBS_Code_Lookup__c     = mappingItem.WBS_Code__c, 
                            Cost_Center_Lookup__c  = costCodeForImed.Id,
                            Funding_Record_Type__c = fundingAllocationRecordType,
                            Percent__c             = (mappingItem.Percent_Allocation__c == null ? 0.0 :mappingItem.Percent_Allocation__c));
                    
                    		newFALines.add( newFALine ); 
                    	}
            	}
            	else
            	{
            		//Wbs key not found
                    newFALine              = new GFRS_Funding_Allocation_Line_Item__c(
                    Funding_Allocation__c  = allocation.Id,  
                    Amount__c              = 0, 
                    Cost_Center_Lookup__c  = costCodeForImed.Id,
                    Funding_Record_Type__c = fundingAllocationRecordType
                    );
                        
                    newFALines.add( newFALine );
            	}	
        	}
            	  
        }
		
		try
        {
         	system.debug('Insert new Funding Allocation Lines size->' + newFALines.size() );
            if(newFALines.size()>0)
            { 
                insert newFALines;
            }
            else
            {
            	system.debug('No FALines for insert. Potential bug.');
            }
         } 
         catch( Exception err )
         {
            System.debug( err.getmessage() );
         }		
	}
	
    
    
    
     //Trigger method. Update Field Initiated Exhibits for funding request in status Decision.
     public override void updateFieldInitiatedExhibitsSplits(GFRS_Funding_Request__c[] newRequests, Map<id,GFRS_Funding_Request__c> oldMap, Map<id,GFRS_Funding_Request__c> newMap){

         GFRS_Funding_Request__c[] filteredRequestslist = new List<GFRS_Funding_Request__c>();
         gFRS_ObjectUtil.filterChangedObjects(newRequests, oldMap, 'Status__c', filteredRequestslist);

         if( filteredRequestslist == null || filteredRequestslist.size() == 0 ){
             return ;
         }

        //get requests in order to update them
        filteredRequestslist = [SELECT ID, Name, Status__c, Accountable_Employee_Approval__c, Record_Type_Name__c  
                                FROM GFRS_Funding_Request__c 
                                WHERE Id in :filteredRequestslist];

        //get FA line items
        List<GFRS_Funding_Allocation_Line_Item__c> lines = [SELECT Id, Name, Funding_Allocation__r.Grant_Request__c, Amount__c 
                                                            FROM GFRS_Funding_Allocation_Line_Item__c
                                                            WHERE Funding_Allocation__r.Grant_Request__c 
                                                            IN :filteredRequestslist ORDER BY Split_Number__c];

        //build line items map
        Map<String, GFRS_Funding_Allocation_Line_Item__c[]> linesMap = new map<String, GFRS_Funding_Allocation_Line_Item__c[]>();
        for(GFRS_Funding_Allocation_Line_Item__c line : lines){
            if(linesMap.get(line.Funding_Allocation__r.Grant_Request__c) == null){
               linesMap.put(line.Funding_Allocation__r.Grant_Request__c, new List<GFRS_Funding_Allocation_Line_Item__c>());
            }
            linesMap.get(line.Funding_Allocation__r.Grant_Request__c).add(line);
        }


        GFRS_Funding_Request__c[] requestsToUpdate = new List<GFRS_Funding_Request__c>();
        for(GFRS_Funding_Request__c selRequest : filteredRequestslist){
            //check condition
            if(selRequest.Status__c.equals(gFRS_Util.REQUEST_STATUS_DECISION) 
                && selRequest.Record_Type_Name__c.equals(gFRS_Util.TYPE_FIELD_INITIATED_EXHIBITS_NAME)){

                GFRS_Funding_Allocation_Line_Item__c[] splits = linesMap.get(selRequest.Id);
                Integer currentSplitIndex                     = 1;
                Boolean wasUpdated                            = false;

                if( splits != null ){
                    for(GFRS_Funding_Allocation_Line_Item__c split : splits){
                        if(split.Amount__c >0){

                            wasUpdated = true;
                            selRequest.put( 'Financial_Approver_' + currentSplitIndex + '_Split_Amount__c', split.Amount__c);
                            selRequest.put( 'Financial_Approver_' + currentSplitIndex + '__c', selRequest.Accountable_Employee_Approval__c );
                            currentSplitIndex+=1;
                        }
                    }
                }
                if(wasUpdated == true){
                    requestsToUpdate.add(selRequest);
                }

            }
        }
        //make update
        update requestsToUpdate;
    } 

    /**
	* @author GFRS Dev Team	
	* @date 19/09/2013
	* @description saveFinancialApprovers method - Trigger method that resets Total Amount on FALI (the funding allocation line items) of a funding request
    * when the approved amount changes.
	*/

    public override void resetFALITotalAmount(gFRS_Funding_Request__c[] arrNewRequest, Map<id,gFRS_Funding_Request__c> oldMapRequest)
    {

        gFRS_Funding_Request__c[] changedRequests = new gFRS_Funding_Request__c[]{};
        gFRS_ObjectUtil.filterChangedObjects( arrNewRequest, oldMapRequest, 'Approved_Amount__c', changedRequests );

        if( changedRequests == null || changedRequests.size() == 0 ){
            return ;
        }
        
        Set<Id> changedRequestIds = gFRS_ObjectUtil.createIdFieldSet( changedRequests, 'id' );
        
        //-- there is a possibility of having a large number of items in this set
        //-- to avoid the risk of the 10k dml limit, a for list query is used instead of a for query
        //for( gFRS_Funding_Allocation_Line_Item__c[] updatedLineItems : [ select... ] )
        
        gFRS_Funding_Allocation_Line_Item__c[] updatedLineItems = new gFRS_Funding_Allocation_Line_Item__c[]{};
        for(gFRS_Funding_Allocation_Line_Item__c changedLineItem : [SELECT
																		Line_Item_Total_Literal__c
																	FROM GFRS_Funding_Allocation_Line_Item__c 
																	WHERE Funding_Allocation__r.Grant_Request__r.id IN :changedRequestIds 
																	AND isDeleted = false]){
        	
        	changedLineItem.Line_Item_Total_Literal__c = null;
           	updatedLineItems.add( changedLineItem );	
        }
        
        if(updatedLineItems.size()>0){
        	update updatedLineItems;        	
        }
    }
    
     /**
     * Trigger method that updates the allocation line item values if the recordtype has changed on a funding request.
     * @param newRequests (gFRS_Funding_Request__c[]) - List of updated requests.
     * @param oldRequestMap (Map<id,gFRS_Funding_Request__c>) - Map of old requests
     * @return gFRS_Funding_Request__c[] - list of updated funding requests
     **/
    public override gFRS_Funding_Allocation_Line_Item__c[] updateFALIFundingRequestType( gFRS_Funding_Request__c[] newRequests, Map<id,gFRS_Funding_Request__c> oldRequestMap ){
        try {
            //-- filter down list of changed funding requests to ONLY those that have changed their recordTypeId
            gFRS_Funding_Request__c[] changedRequests = new gFRS_Funding_Request__c[]{};
            gFRS_ObjectUtil.filterChangedObjects( newRequests, oldRequestMap, 'recordTypeId', changedRequests );
            //System.debug( 'updateFundingRequestAllocationLI_Type.changed:' + changedRequests );

            //-- short circuit if no records there
            if( changedRequests == null || changedRequests.size() == 0 ) return( null );

            Map<id, gFRS_Funding_Request__c> changedRequestMap = new Map<id,gFRS_Funding_Request__c>( changedRequests );
            Set<id> changedRequestIds = gFRS_ObjectUtil.createIdFieldSet( changedRequests, 'id' );

            gFRS_Funding_Allocation_Line_Item__c[] changedAllocLIs = new gFRS_Funding_Allocation_Line_Item__c[]{};
            for( gFRS_Funding_Allocation_Line_Item__c changedAllocLI : [
                SELECT Id, Funding_Allocation__r.Grant_Request__c
                FROM gFRS_Funding_Allocation_Line_Item__c
                WHERE Funding_Allocation__r.Grant_Request__c in :changedRequestIds
            ]){
                //System.debug( 'updateFundingRequestAllocationLI_Type: checking allocation that should change' );
                changedAllocLI.Funding_Record_Type__c = changedRequestMap.get( changedAllocLI.Funding_Allocation__r.Grant_Request__c ).Record_Type_Name__c;
                changedAllocLIs.add( changedAllocLI );
            }

            System.debug( 'changedAllocLIs:' + changedAllocLIs );
            gFRS_Util_NoShare.saveLockedAllocationLIs( changedAllocLIs );
            return( changedAllocLIs );
        }
        catch( Exception err )
        {
            String errMsg = gFRS_Util.getPrettyMessage( err );
            
            if( errMsg != null && errMsg.contains( gFRS_Util.DOES_NOT_MATCH_FILTER ))
            {
                throw( new gFRS_Util.CustomException( System.Label.gFRS_ERROR_FALI_REQUEST_TYPE_CHANGED ));
            } 
            else
            {
                throw( new gFRS_Util.CustomException( errMsg ));
            }
        }
    }
}