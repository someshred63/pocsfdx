/******************************************************************************************
*  @author: Sebastian Karczmarski, Roche (contractor)
*  @email: sebastian.karczmarski@contractors.roche.com
*  Created: 2013-05-24
*  Project: OTR2
*  Description: REST Webservice, returns some details for the specified user id (unixId).

*  Modification History
*  Date            Name               Description
*  25-05-2015      Lukasz Bieniawski  Information about user devices are being logged during initial load
                                      Added method: storeUserConnectionInfo.
*  05-01-2015      Waclaw Smaga       Added picklist refresh
*******************************************************************************************/
@RestResource(urlMapping = '/iPhoneGetUserDetails/*')
global with sharing class iPhone_Get_User_Details_gne {

    private static final String SERVICE_SETTING_REQUIRED_VERSION = 'RequiredVersion';
    private static final String SERVICE_SETTING_REFERRAL_CREATE_REQUIRED_VERSION = 'ReferralCreateRequiredVersion';

    @HttpPost
    global static iPhone_Commons_gne.RestResponse processRequest(String unixId, String deviceId, String hardwareModel, String iosVersion, String otrVersion) {
        return iPhone_Commons_gne.buildResponse(
                   new GetUserDetailsResponseBuilder(),
                   new UserConnectionArgs(unixId, deviceId, hardwareModel, iosVersion, otrVersion)
               );
    }

    static Pattern isPrimaryCareUserPattern = Pattern.compile('^GNE-SFA-PRIMARY-CARE.*(-CS|-DM)');
    static Pattern isSFAUserPattern = Pattern.compile('^GNE-SFA-.*');
    static Pattern isCSUserPattern = Pattern.compile('^GNE-SFA-.*-CS');
    static Pattern isPfgUserPattern = Pattern.compile('^GNE-SFA-(ACTEMRA|NUTROPIN|RITUXAN-RA)-(CS|DM|MANAGER)$');
    static Pattern isTLLUserPattern = Pattern.compile('^GNE-TLS.*');
    static Pattern isMSLUserPattern = Pattern.compile('^GNE-MEDAFFAIRS.*');
    static Pattern isFRMUserPattern = Pattern.compile('^GNE-MCCO-FRM.*');
    static Pattern isMCCOUserPattern = Pattern.compile('^(GNE-MCCO-AM).*');
    static Pattern isSFDCUserPattern = Pattern.compile('GNE-INFREQUENT-USER|^(GNE-SFA-).*(?<!-MANAGER)$|^(GNE-SFA-PREP).*()$|^(GNE-SFA-CC).*()$|^(GNE-SFA-OCC).*()$|^(GNE-MCCO-FRM).*(?<!-OPS)$|^(GNE-MEDAFFAIRS).*()$|^(GNE-TLS).*()$|^(GNE-SFA-CANADA).*()$|^(RCANADA-SFA).*(?<!-MSL)$|^(GNE-MCCO-AM).*|^(GNE-SFA-).*(DM)$|^(GNE-MCCO-).*(MANAGER)$|^(RCANADA-).*(MANAGER)$|^(GNE-SFA-).*(MANAGER)$|^(GNE-CRM).*');
    static Pattern canSamplePattern = Pattern.compile('^GNE-SFA-PRIMARY-CARE.*(-CS|-DM)');
    static Pattern isPrepPattern = Pattern.compile('^GNE-SFA-PREP-.*');
    static Pattern isCCUserPattern = Pattern.compile('^GNE-SFA-CC.*');

    class GetUserDetailsResponseBuilder implements iPhone_Commons_gne.ResponseBuilder {

        public iPhone_Commons_gne.RestResponse build(Object args) {
            Boolean viewMyBrandsOnly;
            Boolean userForImmunoTerr;
            UserConnectionArgs connArgs = (UserConnectionArgs)args;
            User user = String.isNotBlank(connArgs.unixId) ? iPhone_DAO.getUserByExternalId(connArgs.unixId) : iPhone_DAO.getUserById(UserInfo.getUserId());
            if (user != null) {
                viewMyBrandsOnly = iPhone_DAO.getAffiliationsUserMode(user.Id).isEmpty();
                userForImmunoTerr = checkUserForImmunoTerr(user.Id);
                storeUserConnectionInfo(connArgs, user.Id);
            } else {
                throw new iPhone_Commons_gne.IPhoneException('User not found: ' + connArgs.unixId);
            }

            return new GetUserDetailsResponse(user, viewMyBrandsOnly, userForImmunoTerr, connArgs);
        }

        private Boolean checkUserForImmunoTerr(Id userId) {
            return GlobalUtils.isUserInTerr(userId, System.Label.GNE_MedAffairs_Immunology_Terr);
        }

        private void storeUserConnectionInfo(UserConnectionArgs args, Id userId) {
            if (args.hasDeviceInfo == false) {
                return;
            }
            OTR_User_Device_gne__c userDeviceInfo = iPhone_DAO.getUserDeviceInfo(args.deviceId, userId);
            Boolean isNew = userDeviceInfo == null;
            Boolean changed = false;
            if (isNew) {
                userDeviceInfo = new OTR_User_Device_gne__c(
                    User_gne__c = userId,
                    Device_ID_gne__c = args.deviceId
                );
            }
            if (isNew || userDeviceInfo.Model_Identifier_gne__c != args.modelIdentifier) {
                userDeviceInfo.Model_Identifier_gne__c = args.modelIdentifier;
                userDeviceInfo.Model_Name_gne__c = getIOSModelGeneration(args.modelIdentifier);
                changed = true;
            }
            if (isNew || userDeviceInfo.IOS_Version_gne__c != args.iOSVersion) {
                userDeviceInfo.IOS_Version_gne__c = args.iOSVersion;
                changed = true;
            }
            if (isNew || userDeviceInfo.OTR_Version_gne__c != args.otrVersion) {
                userDeviceInfo.OTR_Version_gne__c = args.otrVersion;
                changed = true;
            }

            if (isNew || changed) {
                userDeviceInfo.Last_Stamp_Date_gne__c = System.now();
                if (isNew) {
                    insert userDeviceInfo;
                } else if (changed) {
                    update userDeviceInfo;
                }
            }
        }

        private String getIOSModelGeneration(String modelIdentifier) {
            String result = null;
            if (String.isBlank(modelIdentifier)) {
                return result;
            }
            Boolean found = false;
            Map<String, IOS_Devices_Models_gne__c> models = IOS_Devices_Models_gne__c.getAll();
            for (String generation : models.keyset()) {
                String identifiers = models.get(generation).Identifiers_gne__c;
                if (String.isBlank(identifiers)) {
                    continue;
                }
                for (String identifier : identifiers.split(';')) {
                    if (identifier.trim() == modelIdentifier.trim()) {
                        result = generation;
                        found = true;
                        break;
                    }
                }
                if (found == true) {
                    break;
                }
            }
            return result;
        }
    }

    public class GetUserDetailsResponse extends iPhone_Commons_gne.RestResponse {
        public String id; //(sfdcId)
        public String unixId; //(unixId)
        public String cn; //(company name)
        public String pn; //(profile name)
        public String pi; //(profile id)
        public String fn; //(first name)
        public String ln; //(last name)
        public String mid; //(manager's sfdcId)
        public String mnm; //(manager's name)
        public String mem; //(manager's email)
        public String smallPhotoUrl; //SmallPhotoUrl
        public String fullPhotoUrl; //FullPhotoUrl
        public String cs; //(can sample)
        public String ip; //(is primary care)
        public String me; //(can enter meal expense)
        public String ao; //(can select HCO attendee)
        public String ifm; //(is FRM) Note: Field if => ifm
        public String im; //(is MSL)
        public String mclmsl; //(is MCL or MSL)
        public String it; //(is TTL)
        public String sfdc; //(is SFDC)
        public String mcco; //(is MCCO)
        public Boolean viewMyBrandsOnly;
        public Boolean userForImmunoTerr;
        public String pfg; //(can PFG)
        public String brd; //(PFG brand)
        public String dtp;//(is PFG DTP active)
        public String hc;//(is PFG Hand Carry active)
        public String loa; //(is on LOA)
        public String unc; //(is uncertified)
        public String bu; //(is brand user - CtD)
        public Boolean irc; // (is referral creatable)
        public String unv; // (upgrade needed version)

        public Map<String, Integer> pfgCallQtyLimits; // PFG Interaction Qty Limits per Brand & Distribution Method
        public String tl; // title
        public Boolean iprep;
        public List<GNE_SFA2_PREP_Util.TestingStrategyWrapper> prepStategies;
        public String fcr; //can FCR
        public String ap; //can AP
        public String pa2020; //can PA2020
        public Boolean afmb; //(can set 'Active for my brand' field on Afiliation)
        public Boolean hcf; //(can hide affiliations using 'Active for my brand' field)
        public String icc; // is CC user
        public Boolean gcne; // gCal Notifications Exclusion
        public String terr2Id; //Territory2 Id from  SFA2_User_Preferences_gne__c

        public GetUserDetailsResponse(User user, Boolean viewMyBrandsOnly, Boolean userForImmunoTerr, UserConnectionArgs connArgs) {
            String profileName = user.Profile_Name_gne__c.toUpperCase();
            this.id = user.id;
            this.unixId = user.External_ID_gne__c;
            this.cn = user.CompanyName;
            this.pn = user.Profile_Name_gne__c;
            this.pi = user.ProfileId;
            this.fn = user.FirstName;
            this.ln = user.LastName;
            this.mid = iPhone_StringUtil.getString(user.ManagerId);
            this.mnm = user.Manager != null ? iPhone_StringUtil.getString(user.Manager.Name) : '';
            this.mem = user.Manager != null ? iPhone_StringUtil.getString(user.Manager.Email) : '';
            this.smallPhotoUrl = user.SmallPhotoUrl;
            this.fullPhotoUrl = user.FullPhotoUrl;
            this.cs = String.valueOf(canSamplePattern.matcher(profileName).matches());
            this.ip = String.valueOf(isPrimaryCareUserPattern.matcher(profileName).matches());
            this.me = String.valueOf(user.CompanyName.indexOf('Roche') != -1);
            this.ao = String.valueOf(user.CompanyName.indexOf('LYTICS') != -1);
            this.ifm = isFRMUser(profileName);
            this.im = isMSLUser(profileName);
            this.mclmsl = String.valueOf(GNE_SFA2_Interaction_Util.getIsMSLORMCLUser());
            this.it = isTLLUser(profileName);
            this.sfdc = isSFDCUser(profileName);
            this.viewMyBrandsOnly = viewMyBrandsOnly;
            this.userForImmunoTerr = userForImmunoTerr;
            this.tl = user.Title;
            populatePfgDetails(user);
            populatePrepDetails(user);
            populateMCCODetails(user);
            populateFCRDetails(user);
            populateAPDetails(user);
            populatePA2020Details();
            this.afmb = GNE_Account_Affiliation_Dao.canSetActiveForMyBrand();
            this.hcf = GNE_Account_Affiliation_Dao.isMyBrandCalculated();
            this.bu = isBrandUser(profileName);
            this.icc = isCCUser(profileName);
            this.gcne = checkGCalNotificationsExclusion(user.Id);

            String requiredVersion = iPhoneBase.getServiceSettingValue(SERVICE_SETTING_REQUIRED_VERSION, '6.0.0');
            String rcRequiredVersion = iPhoneBase.getServiceSettingValue(SERVICE_SETTING_REFERRAL_CREATE_REQUIRED_VERSION, '6.0.0');
            this.unv = String.isNotBlank(connArgs.otrVersion) && !connArgs.isOtrVersionOrHigher(requiredVersion) ? requiredVersion : null;
            this.irc = String.isBlank(connArgs.otrVersion) || connArgs.isOtrVersionOrHigher(rcRequiredVersion);
            this.terr2Id = fetchTerritoryFormUserPreferences(user.Id);
        }
        
        private String fetchTerritoryFormUserPreferences(String userId) {
            String result;
            for(SFA2_User_Preferences_gne__c up :[
                SELECT Last_Territory_Used_gne__c 
                FROM SFA2_User_Preferences_gne__c WHERE User_gne__c = :userId
                	AND Last_View_Used_gne__r.Object_Type_gne__c = 'Account' 
                	AND Last_Territory_Used_gne__c != null 
				ORDER BY LastModifiedDate DESC 
				LIMIT 1
            ]) {
                result = up.Last_Territory_Used_gne__c;
            }
            
            return result;
        }

        private void populatePfgDetails(User user) {
            Boolean isPfg = false;
            Boolean isDtp = false;
            Boolean isHc = false;
            Boolean isLoa = false;
            Boolean isUnc = false;

            if (isPfgUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches()) {
                isDtp = GNE_SFA2_PFG_Util.isDtpActiveForUser(user.Id);
                isHc = GNE_SFA2_PFG_Util.isHcActiveForUser(user.Id);
                SFA2_User_Sales_Roster_gne__c sr = GNE_SFA2_PFG_Util.getSalesRosterForUser(user.Id);
                isPfg = isDtp || isHc;
                isLoa = GNE_SFA2_PFG_Util.checkIsUserLOA(user.Id);
                isUnc = !GNE_SFA2_PFG_Util.checkIsUserCertified(user.Id);
                this.brd = sr != null ? sr.Sales_Roster_gne__r.Brand_Name_gne__c : null;
                this.pfgCallQtyLimits = GNE_SFA2_PFG_Config.INTERACTION_QTY_LIMITS_PER_BRAND.get(this.brd);
            }

            this.pfg = String.valueOf(isPfg);
            this.dtp = String.valueOf(isDtp);
            this.hc = String.valueOf(isHc);
            this.loa = String.valueOf(isLoa);
            this.unc = String.valueOf(isUnc);
        }

        private void populatePrepDetails(User user) {
            if (this.iprep = isPrepPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches()) {
                this.prepStategies = GNE_SFA2_PREP_Util.getPrepStrategyWrappers();
            }
        }

        private void populateMCCODetails(User user) {
            this.mcco = String.valueOf(isMCCOUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches());
        }

        private void populateFCRDetails(User user) {
            this.fcr = 'false';
            if (isSFAUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches() || GNE_FCR_Util.getIsDataViewerAdmin()) {
                this.fcr = 'true';
            }
        }

        private void populateAPDetails(User user) {
            this.ap = 'false';
            if (isSFAUserPattern.matcher(user.Profile_Name_gne__c.toUpperCase()).matches() || GNE_AP_Util.getIsDataViewerAdmin()) {
                this.ap = 'true';
            }
        }

        private void populatePA2020Details() {
            Boolean isFeatureDisabled = GNE_Foun_Misc_Config_Items_gne__c.getValues('DisablePA2020ForOTR') != null && GNE_Foun_Misc_Config_Items_gne__c.getValues('DisablePA2020ForOTR').Configuration_Value_gne__c == 'TRUE';
            this.pa2020 = String.valueOf(GNE_SFA2_Util.isFRMUser() && !isFeatureDisabled);
        }
    }

    public static String isFRMUser(String profileName) {
        return String.valueOf(isFRMUserPattern.matcher(profileName).matches());
    }

    public static String isMSLUser(String profileName) {
        return String.valueOf(isMSLUserPattern.matcher(profileName).matches());
    }

    public static String isTLLUser(String profileName) {
        return String.valueOf(isTLLUserPattern.matcher(profileName).matches());
    }

    public static String isSFDCUser(String profileName) {
        return String.valueOf(isSFDCUserPattern.matcher(profileName).matches());
    }

    public static String isCSUser(String profileName) {
        return String.valueOf(isCSUserPattern.matcher(profileName).matches());
    }

    public static String isBrandUser(String profileName) {
        return String.valueOf(GNE_SFA2_Util.isBrandUser(profileName));
    }

    public static String isCCUser(String profileName) {
        return String.valueOf(isCCUserPattern.matcher(profileName).matches());
    }

    public static Boolean checkGCalNotificationsExclusion(Id userId) {
        return ![SELECT Id FROM GNE_Notifications_Exclusion__c WHERE SetupOwnerId =: userId].isEmpty();
    }

    private class UserConnectionArgs extends iPhone_Commons_gne.DeltaArgs {
        public String deviceId { get; private set; }
        public String modelIdentifier { get; private set; }
        public String iOSVersion { get; private set; }
        public Boolean hasDeviceInfo { get; private set; }

        public UserConnectionArgs(String unixId, String deviceId, String modelIdentifier, String iosVersion, String otrVersion) {
            super(null, unixId, null, null, otrVersion);
            this.deviceId = deviceId;
            this.modelIdentifier = modelIdentifier;
            this.iOSVersion = iosVersion;

            // Device parameters are filled and set during initial load.
            this.hasDeviceInfo = String.isNotBlank(deviceId) && String.isNotBlank(modelIdentifier) && String.isNotBlank(iosVersion) && String.isNotBlank(otrVersion);
        }
    }
}