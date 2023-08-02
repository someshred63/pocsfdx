/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com   
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns a list of Accounts for the specified accounts.             
*******************************************************************************************/
@RestResource(urlMapping='/iPhoneGetAccountDetails/*')
global with sharing class iPhone_Get_Account_Details_gne {
    
    @HttpPost 
    global static iPhone_Commons_gne.RestResponse processRequest(String lastSyncDate, String unixId, List<String> accountIds, Boolean enhDelta, String otrVersion) {
        User user; 
        if(String.isNotEmpty(unixId)){
            user = iPhone_DAO.getUserByExternalId(unixId);
        }else {
            user = iPhone_DAO.getUserById(UserInfo.getUserId());
        }
        return iPhone_Commons_gne.buildResponse(
                new GetAccountDetailsResponseBuilder(user), 
                new iPhone_Commons_gne.DefaultDeltaArgs(lastSyncDate, unixId, accountIds, enhDelta, otrVersion)
        );                              
    } 
    
    class GetAccountDetailsResponseBuilder extends iPhone_Commons_gne.DeltaRecordsResponseBuilder { 
        private User currentUser;
           
        public GetAccountDetailsResponseBuilder(User currentUser){
            this.currentUser = currentUser; 
        }   
         
        protected override List<SObject> selectSObjects(iPhone_Commons_gne.DeltaArgs args) {
            return args.isEnhancedDelta() ? iPhone_DeltaDAO.getAccountDetailsByAccountIds(args.accountIds, args.getLastSyncDate()) : iPhone_DAO.getAccountDetailsByAccountIds(args.accountIds);             
        }   
                            
        protected override iPhone_Commons_gne.DeltaRecord getAsRecord(SObject sObj) {
            return new GetAccountDetailsRecord((Account)sObj, currentUser);                      
        }   
        
        protected override iPhone_Commons_gne.DeltaCalculator getDeltaCalculator(String lastSyncDate){
            return new AccountDeltaCalculator(lastSyncDate);
        }
    }       
    
    class AccountDeltaCalculator extends iPhone_Commons_gne.DeltaCalculator{
        
        private String lastModifiedDateFieldName; 
        
        public AccountDeltaCalculator(String lastSyncDate){
            super(lastSyncDate);
            this.lastModifiedDateFieldName = String.valueOf(Account.iPhone_Fields_LastModifiedDate_gne__c);         
        }
        
        protected override String getDeltaStatus(SObject sObj) {
            if(lastSynchronized == null) // delta is OFF.
                return null;        
            Datetime created = (Datetime)sObj.get('CreatedDate');
                            
            if(created >= lastSynchronized) { 
                return STAT_INSERT;     // created AFTER last synchronization.
            } else {
                object lastModifiedDateObj = sObj.get(this.lastModifiedDateFieldName);
                Datetime lastModified = null;
                if (lastModifiedDateObj != null){
                    lastModified =(Datetime)lastModifiedDateObj;                    
                }
                
                if(lastModified != null && lastModified >= lastSynchronized) {
                    return STAT_UPDATE; // created BEFORE last synchonization but updated AFTER last synchronization. 
                } else {
                    return STAT_SYNC; // created and updated BEFORE last synchronization (is eXisting = already synchronized). 
                }
            }                           
        }                           
    }                    
                    
    class GetAccountDetailsRecord extends iPhone_Commons_gne.DeltaRecord {
        public String nm;  //(name)
        public String fn;  //(first name)
        public String ln;  //(last name)
        public String mn;  //(middle name)
        public String mi;  //(mdm id)
        public String at;  //[Canada],
        public String stp;  //[Canada]
        public String ty;  //(type)
        public String ip;  //(is person)
        public String hc;  //(patient ed consent)
        public String em;  //(email)
        public String e2;  //(email 2)
        public String ph;  //(phone)
        public String mo;  //(mobile)
        public String lm;  //(last modified by name)
        public String md;  //(last modified date)
        public String cb;  //(created by name)
        public String cd;  //(created date)
        public String lp;  //(language)
        public String sp;  // Specialities [Canada],
        public String spu; // Specialties_gne__c (us)         
        public String rs;  //(speciality)
        public String rid; //(roche id)
        public String mt;  //[MSL] (TL Types) (is my target)
        public String is;  //[MSL] (SP Investigator Status)
        public String mc;  //[MSL] (Classification)
        public String ma;  //[MSL] (Areas of Expertise) 
        public String tr;  // Target__c
        public String rt;  //(record type)
        public String gr;  // Gender_vod__c
        public String cr;  // Credentials_gne__c
        public String al;  // Active_US_License_gne__c
        public String www; // Website
        public String lni; // LinkedIn_gne__c
        public String twr; // Twitter_gne__c
        public String prepst; // PREP_Status_gne__c
        public Boolean cdnc; // PersonDoNotCall
        public Boolean chooe; // PersonHasOptedOutOfEmail
        public Boolean choof; // PersonHasOptedOutOfFax
        public String pt; // PREP_Professional_Type_gne__c
        public String prt; // Professional_Type_gne__c
        public String st; // Status_gne__c
        
        public String fx; // Fax

        public String lv; //BAM_Level_gne__c
        public String ar; //BAM_Area_gne__c
        public String fpt; //BAM_Full_Primary_Title_gne__c
        public String ot; //BAM_Other_Title_gne__c
        public String dtr; //PREP_Double_Testing_Rate_gne__c
        public String ihpr; //PREP_Implied_HER2_Positivity_Rate_gne__c
        public String hts; //PREP_HER2_Testing_Segment_gne__c
        public String atb; //Est_Annual_Tested_Breast_Patients_gne__c
        public String atg; //Est_Annual_Tested_Gastric_Patients_gne__c
        public String atl; //Est_Annual_Tested_Lung_Patients_gne__c

        public Boolean ara; //Art_Account_frm_gne__c
        public String gv; //Group_gne__r.Name
        public Boolean ac; // String.isBlank(Status_gne__c) || Status_gne__c
        
        public String aa; //XFRM_Additional_Account_frm_gne__c
        public String ms; //XFRM_My_Tier_frm_gne__c

        public String photoUrl; // based on Picture_File_Id_gne__c
        public Boolean isAMS;
        public String ptt;  //Title_Position_Role_gne__c
        public String spr; //Spend_Rest_gne__c
        public String insid;//INS_ID_gne__c
                                             
        public GetAccountDetailsRecord(Account account, User currentUser) {                   
            this.id = account.Id;                                                                                           
            this.nm = account.Name;
            this.fn = iPhone_StringUtil.getString(account.FirstName);               
            this.ln = iPhone_StringUtil.getString(account.LastName);                
            this.mn =  iPhone_StringUtil.getString(account.Middle_vod__c);
            this.mi = iPhone_StringUtil.getString(account.MDMID_gne__c);        
            this.at = iPhone_StringUtil.getString(account.Account_Type_gne__c);
            this.stp = iPhone_StringUtil.getString(account.Sub_Type_can_gne__c);
            this.ty = iPhone_StringUtil.getString(account.RecordType.Description);             
            this.ip = iPhone_StringUtil.getString(account.IsPersonAccount);         
            this.hc = iPhone_StringUtil.getString(account.HCP_Patient_Ed_Consent_Form_gne__c); 
            this.em = iPhone_StringUtil.getString(account.PersonEmail);             
            this.e2 = iPhone_StringUtil.getString(account.Secondary_Email_gne__c);  
            this.ph = iPhone_StringUtil.getString(account.Phone_gne__c);            
            this.mo = iPhone_StringUtil.getString(account.Mobile_ID_vod__c);        
            this.lm = account.LastModifiedBy.Name;                                      
            this.md = iPhone_StringUtil.getString(account.LastModifiedDate);    
            this.cb = account.CreatedBy.Name;                                   
            this.cd = iPhone_StringUtil.getString(account.CreatedDate);     
            this.lp = iPhone_StringUtil.getString(account.Language_of_Preference_can_gne__c);
            this.sp = iPhone_StringUtil.getString(account.Specialties_can_gne__c);
            this.spu= iPhone_StringUtil.getString(account.Specialties_gne__c);             
            this.rs = iPhone_StringUtil.getString(account.Specialty_1_vod__c);      
            this.rid =iPhone_StringUtil.getString(account.Roche_Id_can_gne__c);     
            this.mt = iPhone_StringUtil.getString(account.TL_Type_gne__c);          
            this.is = iPhone_StringUtil.getString(account.SP_Investigator_Status_gne__c);
            this.mc = iPhone_StringUtil.getString(account.Classification_gne__c);   
            this.ma = iPhone_StringUtil.getString(account.Area_of_Expertise_gne__c);
            this.tr = iPhone_StringUtil.getString(account.Target__c); 
            this.rt = iPhone_StringUtil.getString(account.RecordType.DeveloperName);    
            this.gr = iPhone_StringUtil.getString(account.Gender_vod__c); 
            this.cr = iPhone_StringUtil.getString(account.Credentials_gne__c);
            this.al = iPhone_StringUtil.getString(account.Active_US_License_gne__c);
            this.www = iPhone_StringUtil.getString(account.Website);
            this.lni = iPhone_StringUtil.getString(account.LinkedIn_gne__c);
            this.twr = iPhone_StringUtil.getString(account.Twitter_gne__c);
            this.prepst = iPhone_StringUtil.getString(account.PREP_Status_gne__c);
            this.cdnc = account.PersonDoNotCall;
            this.chooe = account.PersonHasOptedOutOfEmail;
            this.choof = account.PersonHasOptedOutOfFax;
            this.pt = iPhone_StringUtil.getString(account.PREP_Professional_Type_gne__c);
            this.fx = iPhone_StringUtil.getString(account.Fax);
            this.prt = iPhone_StringUtil.getString(account.Professional_Type_gne__c);
            this.st = iPhone_StringUtil.getString(account.Status_gne__c);
            this.lv = iPhone_StringUtil.getString(account.BAM_Level_gne__c);
            this.ar = iPhone_StringUtil.getString(account.BAM_Area_gne__c);
            this.fpt = iPhone_StringUtil.getString(account.BAM_Full_Primary_Title_gne__c);
            this.ot = iPhone_StringUtil.getString(account.BAM_Other_Title_gne__c);
            this.dtr = iPhone_StringUtil.getString(account.PREP_Double_Testing_Rate_gne__c);
            this.ihpr = iPhone_StringUtil.getString(account.PREP_Implied_HER2_Positivity_Rate_gne__c);
            this.hts = iPhone_StringUtil.getString(account.PREP_HER2_Testing_Segment_gne__c);
            this.atb = iPhone_StringUtil.getString(account.Est_Annual_Tested_Breast_Patients_gne__c);
            this.atg = iPhone_StringUtil.getString(account.Est_Annual_Tested_Gastric_Patients_gne__c);
            this.atl = iPhone_StringUtil.getString(account.Est_Annual_Tested_Lung_Patients_gne__c);
            this.ara = account.Art_Account_frm_gne__c;
            this.gv = iPhone_StringUtil.getString(account.Group_gne__r.Name);
            this.ac = String.isBlank(account.Status_gne__c) || account.Status_gne__c == 'Active' ? true : false;
            this.photoUrl = buildPhotoUrl(account.Picture_File_Id_gne__c);
            this.isAMS = iPhone_REST_Utils.isAMSAccount(account);
            if(currentUser != null && GNE_SFA2_Util.isFrmUser(currentUser.Profile_Name_gne__c)){
                setFrmSpecificFields(account, currentUser); 
            }
            this.ptt = iPhone_StringUtil.getString(account.Title_Position_Role_gne__c);
            this.spr = iPhone_StringUtil.getString(account.Spend_Rest_gne__c);
            this.insid =  iPhone_StringUtil.getString(account.INS_ID_gne__c);
        }      
        
        private void setFrmSpecificFields(Account account, User currentUser){
            //changes made by JL for Karol SFA-3688
            Map<String, List<String>> profile2fields = new Map<String, List<String>>{
                'GNE-CRM-Manager' => new List<String> {'SMA_My_Tier_frm_gne__c','SMA_Additional_Account_frm_gne__c'},
                'GNE-CRM' => new List<String> {'SMA_My_Tier_frm_gne__c','SMA_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-BFRM' => new List<String> {'BFRM_My_Tier_frm_gne__c','BFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-BFRM-Manager' => new List<String> {'BFRM_My_Tier_frm_gne__c','BFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-EFRM' => new List<String> {'EFRM_My_Tier_frm_gne__c','EFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-EFRM-Manager' => new List<String> {'EFRM_My_Tier_frm_gne__c','EFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-IFRM' => new List<String> {'IFRM_My_Tier_frm_gne__c','IFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-IFRM-Manager' => new List<String> {'IFRM_My_Tier_frm_gne__c','IFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-NFRM' => new List<String> {'NFRM_My_Tier_frm_gne__c','NFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-NFRM-Manager' => new List<String> {'NFRM_My_Tier_frm_gne__c','NFRM_Additional_Account_frm_gne__c'}, 
                'GNE-MCCO-FRM-PFRM' => new List<String> {'PFRM_My_Tier_frm_gne__c','PFRM_Additional_Account_frm_gne__c'}, 
                'GNE-MCCO-FRM-PFRM-Manager' => new List<String> {'PFRM_My_Tier_frm_gne__c','PFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-RESPFRM' => new List<String> {'RESPFRM_My_Tier_frm_gne__c','RESPFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-RESPFRM-Manager' => new List<String> {'RESPFRM_My_Tier_frm_gne__c','RESPFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-RFRM' => new List<String> {'RFRM_My_Tier_frm_gne__c','RFRM_Additional_Account_frm_gne__c'},
                'GNE-MCCO-FRM-RFRM-Manager' => new List<String> {'RFRM_My_Tier_frm_gne__c','RFRM_Additional_Account_frm_gne__c'}                   
            };
               
            if(profile2fields.get(currentUser.Profile_Name_gne__c) != null) {
                this.aa = (String)account.get(profile2fields.get(currentUser.Profile_Name_gne__c)[1]);        
                this.ms = (String)account.get(profile2fields.get(currentUser.Profile_Name_gne__c)[0]); 
            }
        }

        private String buildPhotoUrl(String photoId){
            if(String.isBlank(photoId)){
                return null;
            }
            return '/services/data/v36.0/sobjects/Attachment/' + photoId + '/Body';
        }
    }
}