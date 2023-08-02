/***********************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of DataChangeRequests for the specified accounts.             
************************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountDataChangeRequests/*')
global with sharing class iPhone_Get_Account_DataChangeReq_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse executeRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {             
        return iPhone_Commons_gne.buildResponse(
                new GetAccountDataChangeReqResponseBuilder(), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
        );     
    } 
     
    class GetAccountDataChangeReqResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
                        
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getChangeRequestsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getChangeRequestsByAccountIds(args.accountIds);          
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountDataChangeReqRecord((Change_Request_gne__c)sObj);                          
        }                        
    }
    
    global class GetAccountDataChangeReqRecord extends iPhone_Commons_gne.DeltaRecord {
        public String nm;   // Name
        public String ai;   // Account Id
        public String adi;	// Address Id
        public String rt;   // Request Type
        public String aps;  // Approval State
        public String cd;   // Created Date
        public String cid;  // Created By Id
        public String lmd;  // Last Modified Date
        public String vt;   // Vendor Type
        public String vn;   // Vendor Notes
        
        public String pfn;  // HCP_UPDATE_INFO_FIRST_NAME        
        public String pmn;  // HCP_UPDATE_INFO_MIDDLE_NAME       
        public String pln;  // HCP_UPDATE_INFO_LAST_NAME             
        public String pat;  // HCP_UPDATE_INFO_ACCOUNT_TYPE         (CanadaOnly)
        public String pvg;  // HCP_UPDATE_INFO_VERIFY_GENDER        (CanadaOnly)
        
        public String psx;  // HCP_UPDATE_INFO_SUFFIX               (NonCanada) 
        public String ppt;  // HCP_UPDATE_INFO_PROFESSIONAL_TYPE    (NonCanada)
        public String pvc;  // HCP_UPDATE_INFO_VERIFY_CREDENTIALS   (NonCanada)
        public String pvs;  // HCP_UPDATE_INFO_VERIFY_SPECIALTIES   (NonCanada)
        
        public String pcr;  // HCP_UPDATE_INFO_CREDENTIALS   (NonCanada)
        public String psp;  // HCP_UPDATE_INFO_SPECIALTIES   (NonCanada)
        
        public String oan;  // HCO_UPDATE_INFO_ACCOUNT_NAME                  
        public String oat;  // HCO_UPDATE_INFO_ACCOUNT_TYPE                  
        public String ovs;  // HCO_UPDATE_INFO_VERIFY_SPECIALTIES   (NonCanada)
        public String od;   // HCO_UPDATE_INFO_DESCRIPTION          (NonCanada)
        
        public String air;  // ACCOUNT_INACTIVATE_REASON  
        public String arr;  // ACCOUNT_REACTIVATE_REASON
                
        public String da2;  // ACCOUNT_REMOVE_DUPLICATE_2
        public String da2Name;  // ACCOUNT_REMOVE_DUPLICATE_2 Name               
        public String da3;  // ACCOUNT_REMOVE_DUPLICATE_3
        public String da3Name;  // ACCOUNT_REMOVE_DUPLICATE_3 Name
        public String da4;  // ACCOUNT_REMOVE_DUPLICATE_4
        public String da4Name;  // ACCOUNT_REMOVE_DUPLICATE_4 Name
        public String da5;  // ACCOUNT_REMOVE_DUPLICATE_5
        public String da5Name;  // ACCOUNT_REMOVE_DUPLICATE_5 Name
        
        public String dad2;  // ADDRESS_REMOVE_DUPLICATE_2                
        public String dad3;  // ADDRESS_REMOVE_DUPLICATE_3                       
                
        public String asn;  // ADDRESS_UPDATE_STREET_NAME   
        public String asf;  // ADDRESS_SUITE_FLOOR_UNIT      
        public String acn;  // ADDRESS_UPDATE_CITY_NAME              
        public String ast;  // ADDRESS_UPDATE_STATE_NAME            (NonCanada)
        public String azc;  // ADDRESS_UPDATE_ZIP_CODE              (NonCanada)
        public String ap;   // ADDRESS_UPDATE_PROVINCE              (CanadaOnly)    
        public String apc;  // ADDRESS_UPDATE_POSTAL_CODE           (CanadaOnly)
            
        public String arir; // ADDRESS_REMOVE_INACTIVATE_REASON
        public String arrr; // ADDRESS_REACTIVATE_REASON     
            
        public String lse;  // LICENSE_UPDATE_LICENSE_STATE                  
        public String ln;   // LICENSE_UPDATE_LICENSE_NUMBER                 
        public String lpdf; // LICENSE_UPDATE_PROF_DESIGNATION_FAMILY        
        public String lss;  // LICENSE_UPDATE_STATUS                         
        public String laed; // LICENSE_UPDATE_ADJUST_LICENCE_EXPIR_DATE      
        public String loed; // LICENSE_UPDATE_LICENCE_OVERWRITE_EXPIR_DATE  
        public String lsa;  // LICENSE_UPDATE_LICENCE_SAMPLEABILITY          
        public String lrcr; // LICENSE_UPDATE_REASON_FOR_CHANGE_REQUEST      
        public String ldc;  // LICENSE_UPDATE_DESCRIPTION_FOR_CHANGE         
        public String lnn;  // LICENSE_UPDATE_NEW_NOTE      
        public String rid;  // Change_Request_gne__c.iPhone_Request_Id_gne__c
        public String gv;   // Change_Request_gne__c.Account_Group_gne__c
        public String npi;  // US_PHYSICIAN_NATIONAL_PROVIDER_ID
        
        public GetAccountDataChangeReqRecord(Change_Request_gne__c changeRequest) {                                 
            this.id   = iPhone_StringUtil.getString(changeRequest.Id);          
            this.nm   = iPhone_StringUtil.getString(changeRequest.Name);        
            this.ai   = iPhone_StringUtil.getString(changeRequest.Account_gne__c);   
            this.adi   = iPhone_StringUtil.getString(changeRequest.Current_Address_gne__c);
            this.rt   = iPhone_StringUtil.getString(changeRequest.Type_gne__c);             
            this.aps  = iPhone_StringUtil.getString(changeRequest.Approval_State__c);       
            this.cd   = iPhone_StringUtil.getString(changeRequest.CreatedDate);     
            this.cid   = iPhone_StringUtil.getString(changeRequest.CreatedById);                    
            this.lmd  = iPhone_StringUtil.getString(changeRequest.LastModifiedDate);            
            this.vt   = iPhone_StringUtil.getString(changeRequest.Vendor_Type_gne__c);                                              
            this.vn   = iPhone_StringUtil.getString(changeRequest.Vendor_Notes_gne__c);                                                                     
             
            this.pfn  = iPhone_StringUtil.getString(changeRequest.First_Name_DCR_gne__c);                     // HCP_UPDATE_INFO_FIRST_NAME          
            this.pmn  = iPhone_StringUtil.getString(changeRequest.New_Value_2_gne__c);                        // HCP_UPDATE_INFO_MIDDLE_NAME         
            this.pln  = iPhone_StringUtil.getString(changeRequest.Last_Name_DCR_gne__c);                      // HCP_UPDATE_INFO_LAST_NAME           
            this.pat  = iPhone_StringUtil.getString(changeRequest.Account_Type_DCR_gne__c);                   // HCP_UPDATE_INFO_ACCOUNT_TYPE       (CanadaOnly)
            this.pvg  = iPhone_StringUtil.getString(changeRequest.Verify_Gender_can_gne__c);                  // HCP_UPDATE_INFO_VERIFY_GENDER      (CanadaOnly)
            
            this.psx  = iPhone_StringUtil.getString(changeRequest.Suffix_DCR_gne__c);                         // HCP_UPDATE_INFO_SUFFIX             (NonCanada) 
            this.ppt  = iPhone_StringUtil.getString(changeRequest.Professional_Type_DCR_gne__c);              // HCP_UPDATE_INFO_PROFESSIONAL_TYPE  (NonCanada)
            this.pvc  = iPhone_StringUtil.getString(changeRequest.verify_HCP_credentials_gne__c);             // HCP_UPDATE_INFO_VERIFY_CREDENTIALS (NonCanada)
            this.pvs  = iPhone_StringUtil.getString(changeRequest.Verify_HCP_Specialties_gne__c);             // HCP_UPDATE_INFO_VERIFY_SPECIALTIES (NonCanada)
            this.pcr  = iPhone_StringUtil.getString(changeRequest.Credentials_dcr_gne__c);            		  // HCP_UPDATE_INFO_CREDENTIALS (NonCanada)
            this.psp  = iPhone_StringUtil.getString(changeRequest.Specialties_hcp_dcr_gne__c);           	  // HCP_UPDATE_INFO_SPECIALTIES (NonCanada)
            
            this.oan  = iPhone_StringUtil.getString(changeRequest.New_Organization_Name_gne__c);              // HCO_UPDATE_INFO_ACCOUNT_NAME                
            this.oat  = iPhone_StringUtil.getString(changeRequest.Account_Type_DCR_gne__c);                   // HCO_UPDATE_INFO_ACCOUNT_TYPE                
            this.ovs  = iPhone_StringUtil.getString(changeRequest.Verify_HCO_Specialties_gne__c);             // HCO_UPDATE_INFO_VERIFY_SPECIALTIES  (NonCanada)
            this.od   = iPhone_StringUtil.getString(changeRequest.Description_gne__c);                        // HCO_UPDATE_INFO_DESCRIPTION         (NonCanada)
            
            this.air  = iPhone_StringUtil.getString(changeRequest.Reason_dcr_gne__c);                         // ACCOUNT_INACTIVATE_REASON
            this.arr  = iPhone_StringUtil.getString(changeRequest.Reason_dcr_gne__c);                         // ACCOUNT_REACTIVATE_REASON           
                     
            this.da2  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_2_gne__c);                // ACCOUNT_REMOVE_DUPLICATE_2                  
            this.da2Name  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_2_gne__r.Name);
            this.da3  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_3_gne__c);                // ACCOUNT_REMOVE_DUPLICATE_3                  
            this.da3Name  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_3_gne__r.Name);
            this.da4  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_4_gne__c);                // ACCOUNT_REMOVE_DUPLICATE_4                  
            this.da4Name  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_4_gne__r.Name);
            this.da5  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_5_gne__c);                // ACCOUNT_REMOVE_DUPLICATE_5
            this.da5Name  = iPhone_StringUtil.getString(changeRequest.Duplicate_Account_5_gne__r.Name);
            
            this.dad2  = iPhone_StringUtil.getString(changeRequest.Duplicate_Address_2_gne__c);                // ADDRESS_REMOVE_DUPLICATE_2                  
            this.dad3  = iPhone_StringUtil.getString(changeRequest.Duplicate_Address_3_gne__c);                // ADDRESS_REMOVE_DUPLICATE_3
                    
            this.asn  = iPhone_StringUtil.getString(changeRequest.Address_Line_1_gne__c);                     // ADDRESS_UPDATE_STREET_NAME
            this.asf  = iPhone_StringUtil.getString(changeRequest.Address_Line_2_gne__c);                     // ADDRESS_SUITE_FLOOR_UNIT
                                     
            this.acn  = iPhone_StringUtil.getString(changeRequest.City_gne__c);                               // ADDRESS_UPDATE_CITY_NAME            
            this.ast  = iPhone_StringUtil.getString(changeRequest.State_gne__c);                              // ADDRESS_UPDATE_STATE_NAME           (NonCanada)
            this.azc  = iPhone_StringUtil.getString(changeRequest.Zip_gne__c);                                // ADDRESS_UPDATE_ZIP_CODE             (NonCanada)
            this.ap   = iPhone_StringUtil.getString(changeRequest.Province_can_gne__c);                       // ADDRESS_UPDATE_PROVINCE             (CanadaOnly)   
            this.apc  = iPhone_StringUtil.getString(changeRequest.Postal_Code_can_gne__c);                    // ADDRESS_UPDATE_POSTAL_CODE          (CanadaOnly)
                
            this.arir = iPhone_StringUtil.getString(changeRequest.Remove_Inactive_Address_gne__c);            // ADDRESS_REMOVE_INACTIVATE_REASON
            this.arrr = iPhone_StringUtil.getString(changeRequest.Reason_dcr_gne__c);          				  // ADDRESS_REACTIVATE_REASON   
                
            this.lse  = iPhone_StringUtil.getString(changeRequest.License_State_gne__c);                      // LICENSE_UPDATE_LICENSE_STATE                
            this.ln   = iPhone_StringUtil.getString(changeRequest.License_Number_gne__c);                     // LICENSE_UPDATE_LICENSE_NUMBER               
            this.lpdf = iPhone_StringUtil.getString(changeRequest.License_Designation_gne__c);                // LICENSE_UPDATE_PROF_DESIGNATION_FAMILY                                  
            this.laed = iPhone_StringUtil.getStringDate(changeRequest.Adjusted_License_Expiration_Date_gne__c);  // LICENSE_UPDATE_ADJUST_LICENCE_EXPIR_DATE     
            this.loed = iPhone_StringUtil.getStringDate(changeRequest.License_Overwrite_Expiration_Date_gne__c); // LICENSE_UPDATE_LICENCE_OVERWRITE_EXPIR_DATE  
            this.lsa  = iPhone_StringUtil.getString(changeRequest.License_Sample_ability_gne__c);             // LICENSE_UPDATE_LICENCE_SAMPLEABILITY        
            this.lrcr = iPhone_StringUtil.getString(changeRequest.Reason_dcr_gne__c);                         // LICENSE_UPDATE_REASON_FOR_CHANGE_REQUEST    
            this.ldc  = iPhone_StringUtil.getString(changeRequest.Description_gne__c);                        // LICENSE_UPDATE_DESCRIPTION_FOR_CHANGE       
            this.lnn  = iPhone_StringUtil.getString(changeRequest.New_Note_gne__c);                           // LICENSE_UPDATE_NEW_NOTE                    
            
            this.lss  = iPhone_StringUtil.getString(changeRequest.Status_cs_gne__c);                             // STATUS
            
            this.rid  = iPhone_StringUtil.getString(changeRequest.iphone_request_id_gne__c);
            this.gv   = iPhone_StringUtil.getString(changeRequest.Account_Group_gne__c);
            this.npi  = iPhone_StringUtil.getString(changeRequest.HCP_National_Provider_Id_gne__c);
        }                               
    }
    
}