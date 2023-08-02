/**
* @author: GFRS Dev Team
* @date: 17/06/2013
* @description: gFRS_DAO class - Data Access Object class which is dedicated for retrieving data from database. 
* In class methods there should be only appropriate query, which return needed data. Any processing of data should be made in class where the data is needed.
* For now this class should be used only for unit tests and for newly created queries.
*
*/
public with sharing class gFRS_DAO {
    
    /**
    * @author: GFRS Dev Team
    * @date: 17/06/2013
    * @description: Retrieve gFRS Funding Requests which has id equals to value given in parameter. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Funding_Request__c> getFundingRequestById(Id fundingRequestId) {
        return [
        SELECT 
            Id,
            Name,
            Sunshine_Communication_Sent__c,
            Event_Project_type__c,
            Event_Project_sub_type__c, 
            Fellowship_Project_Description__c,
            Information_Needed__c,
            Is_Reconciliation_In_RFI__c,
            Record_Type_Name__c,
            Students_of_Color_Scholarships__c,
            Hunger__c,
            Meeting_Agenda__c,
            Organization__c,
            RecordTypeId,
            Requested_Amount__c,
            Pediatric_Cancer_Assistance__c,
            Basic_Research_Fellow__c,
            SYS_Program_HCP_Roll_up_Count__c,
            Location__c,
                ACH_Received__c,
            Letter_of_Request__c,
            Total_Program_Budget__c,
            Authorized_Signer__c,
            Signing_Authority_Email__c
        FROM GFRS_Funding_Request__c 
        WHERE Id =:fundingRequestId
        ]; 
        
    }

    public static Set<Id> getFundingRequestsIds(List<GFRS_Funding_Request__c> requests) {
        Set<Id> requestsIds = new Set<Id>();
        for (GFRS_Funding_Request__c request : requests) {
            requestsIds.add(request.Id);
        }
        return requestsIds;
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 16/08/2013
    * @description: Retrieve gFRS Organization which has id equals to value given in parameter
    */
    public static List<GFRS_Organization__c> getOrganizationById(Id organizationId) {
        return [
        SELECT 
            Id,
            Name,
            Audited_Financials_for_the_previous_thre__c
        FROM GFRS_Organization__c
        WHERE Id = :organizationId AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description: Retrieve gFRS Organization list. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Organization__c> getOrganizationsList() {
        return [
        SELECT 
            Id,
            Name
        FROM GFRS_Organization__c
        WHERE isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 08/08/2013
    * @description: Retrieve gFRS Third Parites list. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Third_Party__c> getThirdPartiesListForGivenRequest(GFRS_Funding_Request__c fundingRequest) {
        return [ 
        SELECT
            Id, 
            Funding_Request__c, 
            Company_Name__c, 
            Third_Party_Contact_First_Name__c, 
            Third_Party_Contact_Last_Name__c, 
            Third_Party_Company_Function__c, 
            Third_Party_Contact_Email__c,
            isDeleted
        FROM GFRS_Third_Party__c
        WHERE Funding_Request__c = :fundingRequest.Id AND isDeleted = false
        ORDER BY CreatedDate
        ];
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description: Retrieve gFRS Location list. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Location__c> getLocationsList() {
        return [
        SELECT
            Id,
            Name,
            Organization__c 
        FROM GFRS_Location__c
        WHERE isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getWBSCodeList method Retrieve GFRS WBS Codes list which SAP Company code passed in parameter sapCompanyCode. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_WBS_Codes__c> getWBSCodeList(String sapCompanyCode) {
        return [
        SELECT 
            id 
        FROM GFRS_WBS_Codes__c
        WHERE SAP_Company_Code__c=:sapCompanyCode 
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 08/08/2014
    * @description: getWBSCodeByName method Retrieve GFRS WBS Codes list by Name
    * in query.  
    */
    public static List<GFRS_WBS_Codes__c> getWBSCodeByName(String wbsName) {
        return [
        SELECT 
            Id,
            Name,
            SAP_Company_Code__c
        FROM GFRS_WBS_Codes__c
        WHERE Name =:wbsName 
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getCostCenterList method Retrieve Cost Center Code list which SAP Company code passed in parameter sapCompanyCode. This is basic form of the query - if needed please extend list of fields
    * in query.
    */
    public static List<GFRS_Cost_Center_Code__c> getCostCenterList(String sapCompanyCode) {
        return [
        SELECT 
            id 
        FROM GFRS_Cost_Center_Code__c
        WHERE SAP_Company_Code__c=:sapCompanyCode 
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getAllocationLineItemListByRequestId method Retrieve Funding Allocation Line Item list which are assigned to specified request id. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */
    public static List<GFRS_Funding_Allocation_Line_Item__c> getAllocationLineItemListByRequestId(Id requestId) {
        return [
        SELECT 
            Id,
            Cost_Center_Description__c, 
            Cost_Center_Lookup__c, 
            WBS_Code_Lookup__c,
            WBS_Description__c,
            Line_Item_Total_Literal__c,
            WBS_Code_Lookup__r.IsActive__c,
            Cost_Center_Lookup__r.IsActive__c 
        FROM GFRS_Funding_Allocation_Line_Item__c 
        WHERE Funding_Allocation__r.Grant_Request__r.id=:requestId 
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 18/09/2013
    * @description: getAllocationLineItemListByRequestIds method Retrieve Funding Allocation Line Item list which are assigned to specified request Ids list. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */
    public static List<GFRS_Funding_Allocation_Line_Item__c> getAllocationLineItemListByRequestIds(List<Id> requestIds) {
        return [
        SELECT 
            Id,
            Grant_Request__c,
            Cost_Center_Description__c, 
            Cost_Center_Lookup__c, 
            WBS_Code_Lookup__c,
            WBS_Description__c,
            Line_Item_Total_Literal__c,
            WBS_Code_Lookup__r.IsActive__c,
            Cost_Center_Lookup__r.IsActive__c,
            Percent__c,
            Amount__c
        FROM GFRS_Funding_Allocation_Line_Item__c 
        WHERE Funding_Allocation__r.Grant_Request__r.id IN :requestIds 
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 18/09/2013
    * @description: getAllocationLineItemListByRequestIds method Retrieve Funding Allocation Line Item list which are assigned to specified request Ids list. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */
    public static List<GFRS_Funding_Allocation_Line_Item__c> getAllocationLineItemListByRequestIdsAndAllocationType(List<Id> requestIds, String allocationType) {
        return [
        SELECT 
            Id,
            Grant_Request__c,
            Funding_Allocation__r.Grant_Request__c,
            Cost_Center_Description__c,
            Cost_Center_Lookup__c, 
            WBS_Code_Lookup__c,
            WBS__c,
            WBS_Description__c,
            Line_Item_Total_Literal__c,
            WBS_Code_Lookup__r.IsActive__c,
            Cost_Center_Lookup__r.IsActive__c,
            Percent__c,
            Amount__c,
            Funding_Allocation__r.RecordType.Name
        FROM GFRS_Funding_Allocation_Line_Item__c 
        WHERE Funding_Allocation__r.Grant_Request__r.id IN :requestIds AND Funding_Allocation__r.RecordType.Name = :allocationType
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getFundingAllocationsByRequestId method Retrieve Funding Allocation list which are assigned to specified request id. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */  
    public static List<GFRS_Funding_Allocation__c> getFundingAllocationsByRequestId(Id requestId) {
        return [
        SELECT
            Request_Name__c,
            Sum_of_Amounts__c,
            Sum_of_Percents__c,
            Payment_Amount__c
        FROM GFRS_Funding_Allocation__c 
        WHERE Grant_Request__r.Id = :requestId
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 29/08/2014
    * @description:getFundingAllocationsByIdsList method - Retrieve Funding Allocation list 
    * in query. 
    */  
    public static Map<Id, GFRS_Funding_Allocation__c> getFundingAllocationsByIdsList(Set<Id> fundingAllocationIdList) {
        Map<Id, GFRS_Funding_Allocation__c> tmpMap = new Map<Id, GFRS_Funding_Allocation__c>([SELECT
                                                                                                    Id,
                                                                                                    Grant_Request__r.Record_Type_Name__c
                                                                                                FROM GFRS_Funding_Allocation__c 
                                                                                                WHERE Id IN :fundingAllocationIdList
                                                                                                AND isDeleted = false]);
        return tmpMap;
        
    }
    
    
    /**
    * @author: GFRS Dev Team
    * @date: 22/08/2014
    * @description:getFundingAllocationsByRequestIds method Retrieve Funding Allocation list which are assigned to specified request id list. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */  
    public static List<GFRS_Funding_Allocation__c> getFundingAllocationsByRequestIds(Set<Id> requestIds) {
        return [
        SELECT
            Pct_Covered__c,
            Grant_Request__c,
            GL_Account__c,
            Request_Name__c,
            Sum_of_Amounts__c,
            Sum_of_Percents__c,
            Payment_Amount__c,
            Grant_Request__r.Approved_Amount__c,
            Grant_Request__r.Decision_Date__c,
            Grant_Request__r.Refundable_Deposit_Amount_if_any__c,
            Grant_Request__r.Financial_Approver_1_Decision_Date__c,
            Grant_Request__r.Financial_Approver_1_Decision__c,
            Grant_Request__r.Financial_Approver_2_Decision__c,
            Grant_Request__r.Financial_Approver_3_Decision__c,
            Grant_Request__r.Financial_Approver_4_Decision__c,
            Grant_Request__r.Financial_Approver_5_Decision__c,
            Grant_Request__r.Business_Approver_2_Decision__c,
            Grant_Request__r.Business_Approver_3_Decision__c,
            Grant_Request__r.Business_Approver_Decision__c,
            Grant_Request__r.Date_Submitted__c,
            Grant_Request__r.Name,
            Fiscal_Year__c,
            RecordType.Name
        FROM GFRS_Funding_Allocation__c 
        WHERE Grant_Request__r.Id IN :requestIds
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 22/08/2014
    * @description:getFundingAllocationsByRequestIds method Retrieve Funding Allocation list which are assigned to specified request id list. This is basic form of the query - if needed please extend list of fields
    * in query. 
    */  
    public static List<GFRS_Funding_Allocation__c> getFundingAllocationsByRequestIdsAndAllocationType(Set<Id> requestIds, String typeOfAllocation) {
        return [
        SELECT
            Pct_Covered__c,
            Grant_Request__c,
            GL_Account__c,
            Request_Name__c,
            Sum_of_Amounts__c,
            Sum_of_Percents__c,
            Payment_Amount__c,
            Grant_Request__r.Approved_Amount__c,
            Grant_Request__r.Refundable_Deposit_Amount_if_any__c,
            RecordType.Name
        FROM GFRS_Funding_Allocation__c 
        WHERE Grant_Request__r.Id IN :requestIds AND RecordType.Name = :typeOfAllocation
        AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getProgramListByRequestId method Retrieve Program list which are assigned to specified request id. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Program__c> getProgramListByRequestId(Id requestId) {
        return [
        SELECT 
            Status__c,
            Start_Date__c, 
            End_Date__c, 
            Expected_Number_of_Attendees__c,
            Expected_of_Attendees_US_Based_HCPs__c,
            Product_being_Promoted__c,
            Booth_Type__c,
            Size_of_Exhibit__c,
            Actual_Time_at_Display_Table_Hours__c,
            Venue_Name__c,
            Venue_City__c,
            Venue_State__c,
            Venue_Province_Region__c,
            Venue_Zip_Code__c,
            Venue_Country__c,
            HCP_Compliance_Check__c,
            Short_Start_Date_Resp__c,
            Expected_of_attendees_that_are_HCPs__c 
        FROM GFRS_Program__c 
        WHERE Funding_Request__r.id=:requestId 
        AND isDeleted = false
        ]; 
        
    }

    /**
    * @author: GFRS Dev Team
    * @date: 10/10/2018
    * @description: getProgramMapByRequestIds method retrieve programs for provided request ids. Return map with keys as request Ids and values as list of programs. This is basic form of the query - if needed please extend list of fields
    * in query.
    */
    public static Map<Id, List<GFRS_Program__c>> getProgramMapByRequestIds(Set<Id> requestIds) {
        Map<Id, List<GFRS_Program__c>> requestToPrograms = new Map<Id, List<GFRS_Program__c>>();
        for (GFRS_Program__c program : [
                SELECT
                        Id,
                        Funding_Request__c,
                        RecordTypeId,
                        Status__c,
                        Start_Date__c,
                        End_Date__c,
                        Expected_Number_of_Attendees__c,
                        Expected_of_Attendees_US_Based_HCPs__c,
                        Product_being_Promoted__c,
                        Booth_Type__c,
                        Size_of_Exhibit__c,
                        Actual_Time_at_Display_Table_Hours__c,
                        Venue_Name__c,
                        Venue_City__c,
                        Venue_State__c,
                        Venue_Province_Region__c,
                        Venue_Zip_Code__c,
                        Venue_Country__c,
                        HCP_Compliance_Check__c,
                        Expected_of_attendees_that_are_HCPs__c
                FROM GFRS_Program__c
                WHERE Funding_Request__r.id IN :requestIds
                AND isDeleted = false
        ]) {
            if (!requestToPrograms.containsKey(program.Funding_Request__c)) {
                requestToPrograms.put(program.Funding_Request__c, new List<GFRS_Program__c>());
            }
            requestToPrograms.get(program.Funding_Request__c).add(program);
        }
        return requestToPrograms;
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 19/07/2013
    * @description:getProgramListByRequestId method Retrieve Program list which are assigned to specified request id. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<GFRS_Program__c> getProgramListByRequestIdAndStartDate(Id requestId, Date startDate){
        return [
        SELECT 
            Name, 
            Start_Date__c
        FROM GFRS_Program__c 
        WHERE Funding_Request__c =:requestId 
        AND (Start_Date__c < :startDate OR Start_Date__c = null)
        
        ];
    }

    /**
    * @author: GFRS Dev Team
    * @date: 21/06/2013
    * @description:getBudgetListByRequestId method Retrieve Budget list which are assigned to specified request id. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */  
    public static List<GFRS_RequestBudget__c> getBudgetListByRequestId(Id requestId) {
        return [
        SELECT 
            Amount__c, 
            Grant_Request__c
            FROM GFRS_RequestBudget__c 
        WHERE Grant_Request__c =:requestId AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 22/08/2013
    * @description: getGfrsTaskByRequestId method - Retrieve gFRS Tasks for given requests. Used in RFI.
    * in query.  
    */
    public static List<gFRS_Tasks__c> getGfrsTaskByRequestId(Id requestId) {
        return [
        SELECT  
            CreatedDate,
            gFRS_Funding_Request__c,
            Action_Type__c
        FROM gFRS_Tasks__c
        WHERE gFRS_Funding_Request__c =:requestId AND isDeleted = false
        ]; 
        
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 08/10/2013
    * @description: getGfrsTaskByRequestId method - Retrieve gFRS Tasks for given requests. Used in RFI.
    * in query.  
    */
    public static List<gFRS_Tasks__c> getGfrsTaskByRequestIdAndActionType(Id requestId, String actionType) {
        return [
        SELECT  
            CreatedDate,
            gFRS_Funding_Request__c,
            Action_Type__c
        FROM gFRS_Tasks__c
        WHERE gFRS_Funding_Request__c =:requestId AND Action_Type__c =:actionType AND isDeleted = false
        ]; 
        
    }

    /**
    * @author: GFRS Dev Team
    * @date: 19/06/2013
    * @description:getUserInfo method Retrieve User list by User  id. This is basic form of the query - if needed please extend list of fields
    * in query.  
    */
    public static List<User> getUserInfo(Id userId) {
        return [
        SELECT 
            Id,
            FirstName,
            LastName,
            Email,
            Username
        FROM User 
        WHERE Id=:userId 
        limit 1
        ]; 
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 13/09/2013
    * @description: getUserDelegationByUsername method - retrieves User Delegations for given username
    * in query.  
    */
    public static List<GNE_User_Delegation__c> getUserDelegationByUsername(String username) {
        return [
        SELECT 
            Id,
            Delegated_User__c,
            Start_Date__c,
            End_Date__c,
            Comments__c,
            Is_Delegation_Active__c
        FROM GNE_User_Delegation__c 
        WHERE Name=:username
        limit 1
        ]; 
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 24/01/2014
    * @description: getPaymentHistoryByFundingAllocation method - retrieves list of Payment/Refund History for given Funding Allocation.
    * in query.  
    */
    public static List<GFRS_Payment_History__c> getPaymentHistoryByFundingAllocation(GFRS_Funding_Allocation__c fundingAllocation) {
        return [
        SELECT 
            SAP_Doc_ID__c, 
            Status__c 
        FROM GFRS_Payment_History__c
        WHERE Funding_Allocation__c = : fundingAllocation.Id AND isDeleted = false
        ]; 
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 22/08/2014
    * @description: getPaymentHistoryByFundingAllocationList method - retrieves list of Payment/Refund History for given Funding Allocation List.
    * in query.  
    */
    public static List<GFRS_Payment_History__c> getPaymentHistoryByFundingAllocationList(List<GFRS_Funding_Allocation__c> fundingAllocationList) {
        return [
        SELECT 
            SAP_Doc_ID__c, 
            Status__c,
            Grant__c
        FROM GFRS_Payment_History__c
        WHERE Funding_Allocation__c IN : fundingAllocationList AND isDeleted = false
        ]; 
    }
    
    /**
    * @author: GFRS Dev Team
    * @date: 27/01/2014
    * @description: getProfileById method - retrieves Profile for given Id. 
    */
    public static Profile getProfileById(Id profileId) {
        return [
        SELECT 
            Name
        FROM Profile
        WHERE Id = : profileId
        ]; 
    }
    
    
}