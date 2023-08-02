public class CFAR_TeamMemberHelper {
    public static final String ROLE_CLINICAL_STUDY_MANAGER        = 'CSM = Clinical Study Manager';
    public static final String ROLE_PRIMARY_INVESTIGATOR          = 'PI = Primary (or Principal) Investigator';
    public static final String ROLE_SUB_INVESTIGATOR              = 'Sub-I = Sub-investigator';
    public static final String ROLE_CLINICAL_STUDY_ASSOCIATE      = 'CSA = Clinical Study Associate';
    public static final String ROLE_CLINICAL_ASSISTANT			  = 'CA = Clinical Assistant';
    public static final String ROLE_SPECIALTY_LAB_CONTACT         = 'SLC = Specialty Lab Contact';
    public static final String ROLE_DRUG_DEPOT_CONTACT            = 'DDC = Drug Depot Contact';
    public static final String ROLE_READING_CENTER_CONTACT        = 'RCC = Reading Center Contact';
    public static final String ROLE_OTHER_EXTERNAL		          = 'Other-External';
    public static final String ROLE_PHARMACIST			          = 'Ph = Pharmacist';
    public static final String ROLE_STUDY_COORDINATOR             = 'SC = Study Coordinator';
    public static final String ROLE_CLINICAL_PROGRAM_LEADER       = 'CPL = Clinical Program Leader';
    
    public static final String GNE_SUPPORT_DOLLAR_AND_DRUG        = '$ and Drug';
    public static final String GNE_SUPPORT_DOLLAR_ONLY            = '$ Only';
    public static final String GNE_SUPPORT_DRUG_ONLY              = 'Drug Only';

	public static final String TRIAL_STATUS_ADMIN_FIX             = 'Admin Fix';

    public static final Set<String> CONTRACT_ROLES = new Set<String> {
            ROLE_PRIMARY_INVESTIGATOR,
            ROLE_SUB_INVESTIGATOR,
            ROLE_SPECIALTY_LAB_CONTACT,
            ROLE_DRUG_DEPOT_CONTACT,
            ROLE_READING_CENTER_CONTACT
    };

    public static boolean isContractRole(String role) {
        return CONTRACT_ROLES.contains(role);
    }
}