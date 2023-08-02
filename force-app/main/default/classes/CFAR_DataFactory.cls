public class CFAR_DataFactory {
    public static Integer counter = 0;
    
    public static CFAR_Trial_gne__c createTrial(Integer days){
        String str = string.valueof(Math.abs(Crypto.getRandomLong()));
        String randomNumber = str.substring(0, 5);
        return new CFAR_Trial_gne__c(
            Planned_Enrollment_gne__c = 100,
            IIS_Portal_RO_Number_gne__c = 'RO-IIS-2017-'+randomNumber,
            Received_Date_gne__c = System.today().addDays(days)        
        );        
    }

    public static CFAR_Trial_gne__c createTrial2(Integer days, String portalRONumber){
        return new CFAR_Trial_gne__c(
                Planned_Enrollment_gne__c = 100,
                IIS_Portal_RO_Number_gne__c = portalRONumber,
                Received_Date_gne__c = System.today().addDays(days)
        );
    }
    
    public static CFAR_Cohort_gne__c createCohort(CFAR_Trial_gne__c trial, Integer cohortNumber, Integer totalPatients){
        return new CFAR_Cohort_gne__c(
            Trial_ref_gne__c = trial.Id,
            Cohort_number_gne__c = cohortNumber,
            Total_Cohort_Patients_gne__c = totalPatients
        );
    }
    
    public static CFAR_Cohort_Molecule_gne__c createCohortMolecule(
        CFAR_Cohort_gne__c cohort, 
        Integer freq, 
        Integer qty,
        CFAR_Molecule_Configuration_gne__c molecConfig
    ){
        return new CFAR_Cohort_Molecule_gne__c(
            Cohort_ref_gne__c = cohort.Id,
            Dosage_Frequency_gne__c = freq,
            Dosage_Qty_gne__c = qty,
            Molecule_Configuration_ref_gne__c = molecConfig.Id
        );
    }
    
    public static CFAR_Team_Member_gne__c createTeamMember(
        CFAR_Trial_gne__c trial, 
        String name, 
        CFAR_Contact_Address_JO_gne__c contactAddress,
        String role
    ){
        return new CFAR_Team_Member_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Name = name,
            contact_address_ref_gne__c = contactAddress.Id,
            Function_Role_gne__c = role
        );
    }
    
     public static CFAR_Team_Member_gne__c createTeamMemberWithActiveOn(
        CFAR_Trial_gne__c trial, 
        String name, 
        CFAR_Contact_Address_JO_gne__c contactAddress,
        String role,
        Date activeOn
    ){
        return new CFAR_Team_Member_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Name = name,
            contact_address_ref_gne__c = contactAddress.Id,
            Function_Role_gne__c = role,
            Active_on_gne__c = activeOn
        );
    }
    
    public static CFAR_Contact_Address_JO_gne__c createContactAddressJO(CFAR_Contact_gne__c contact, CFAR_Contact_Address_gne__c contactAddress){
        return new CFAR_Contact_Address_JO_gne__c(
            CFAR_Contact_ref_gne__c = contact.Id,
            Contact_Address_ref_gne__c = contactAddress.Id
        );
    }
    
    public static CFAR_Contact_gne__c createContact(String name, String role){
        return new CFAR_Contact_gne__c(
            Name = name,
            Primary_Role_Function_gne__c = role
        );
    }
    
    public static CFAR_Contact_gne__c createContact2(String name, String role, String FirstName, String LastName, Date ActiveDate){
        return new CFAR_Contact_gne__c(
            Name = name,
            Primary_Role_Function_gne__c = role,
            First_Name_gne__c = FirstName,
            Last_Name_gne__c = LastName,
            Active_date_gne__c = ActiveDate
        );
    }
    
    public static CFAR_Contact_Address_gne__c createContactAddress(CFAR_Institution_gne__c institution){
        return new CFAR_Contact_Address_gne__c(
            Active_gne__c = true,
            Address_gne__c = 'Address ',
            Country_gne__c = 'USA',
            Zip_gne__c = '99999',
            City_gne__c = 'City',
            Province_gne__c = 'NY',
            Postal_Code_gne__c = '00000',
            State_gne__c = 'NY',
            Institution_gne__c = institution.Id
        );
    }
    
     public static CFAR_Contact_Address_gne__c createContactAddress2(CFAR_Institution_gne__c institution, CFAR_Address_Type_gne__c addressType){
        return new CFAR_Contact_Address_gne__c(
            Active_gne__c = true,
            Address_Type_ref_gne__c = addressType.id,
            Address_gne__c = 'Address ',
            Country_gne__c = 'USA',
            Zip_gne__c = '99999',
            City_gne__c = 'City',
            Province_gne__c = 'NY',
            Postal_Code_gne__c = '00000',
            State_gne__c = 'NY',
            Institution_gne__c = institution.Id
        );
    }
    
    /*
     * Name should be unique
     */ 
    public static CFAR_Parent_Organization_gne__c createParentOrganization(){
        counter++;
        String uniqueName = counter + '-' + System.now().getTime();
        return new CFAR_Parent_Organization_gne__c(
            Name = uniqueName,
            Active_gne__c = true
        );
    }
    
    public static CFAR_Institution_gne__c createInstitution(CFAR_Parent_Organization_gne__c parentOrg, String name){
        counter++;
        String uniqueName = counter + '-' + System.now().getTime();
        return new CFAR_Institution_gne__c(            
            Name = name + '_' + uniqueName,
        	Active_gne__c = true,
            Parent_Organization__c = parentOrg.Id
        );
    }
    
    public static CFAR_Milestone_Activity_gne__c createMilestoneActivity(CFAR_Trial_gne__c trial, String name){
        return new CFAR_Milestone_Activity_gne__c(
            Name = name,
            CFAR_Trial_ref_gne__c= trial.Id,
            Actual_Date_gne__c = System.today().addMonths(-1),
            Planned_Date_gne__c = System.today().addMonths(2)
        );
    }
    
    public static CFAR_Trial_Other_GNE_Agent_gne__c createTrialOtherAgent(CFAR_Trial_gne__c trial, CFAR_Product_gne__c product){
        return new CFAR_Trial_Other_GNE_Agent_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Other_GNE_Agent_ref_gne__c = product.Id
        );
    }
    
    public static CFAR_Budget_Contract_gne__c createBudgetContract(CFAR_Team_Member_gne__c tm){
        return new CFAR_Budget_Contract_gne__c(
            Team_Member_ref_gne__c = tm.Id
        );
    }
    
    public static CFAR_Rate_Table_gne__c createRateTable(CFAR_Budget_Contract_gne__c bc){
        return new CFAR_Rate_Table_gne__c(
            Budget_Contract_ref_gne__c = bc.Id,
            Status_gne__c = 'Active'
        );
    }
    
    public static CFAR_Budget_CPS_Payments_gne__c createBudgePayments(
        CFAR_Rate_Table_gne__c rt,
        CFAR_Budget_Contract_gne__c  bc, 
        CFAR_Payment_Schedule_Status_gne__c pss
    ){
        return new CFAR_Budget_CPS_Payments_gne__c(
            Budget_Contract_ref_gne__c = bc.Id,
            Rate_Table_ref_gne__c = rt.Id,
            Payment_Status_ref_gne__c = pss.Id
        );
    }
    
    public static CFAR_Payment_Schedule_Status_gne__c createPaymentScheduleStatus(String name){
        return new CFAR_Payment_Schedule_Status_gne__c(
            Active_gne__c = true,
            Name = name
        );
    }
    
    public static CFAR_Actual_Enrollment_gne__c createActualEnrollment(CFAR_Trial_gne__c trial, Integer enrolled){
        return new CFAR_Actual_Enrollment_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Enrolled_Num_gne__c = enrolled
        );
    }
    
    public static CFAR_WBS_gne__c createWbs(String name){
        return new CFAR_WBS_gne__c(
            Active_gne__c = true,
            Name = name
        );
    }
    
    public static CFAR_Specific_Indication_for_Trial_gne__c createSpecificIndicationForTrial(
        CFAR_Specific_Indication_gne__c si,
        CFAR_Trial_gne__c tr
    ){
        return new CFAR_Specific_Indication_for_Trial_gne__c(
            CFAR_Specific_Indication_ref_gne__c = si.Id,
            CFAR_Trial_ref_gne__c = tr.Id
        );
    }
    
    public static CFAR_Specific_Indication_gne__c createSpecificIndication(String name){
        return new CFAR_Specific_Indication_gne__c(
            Active_gne__c = true,
            Name = name
        );
    }
    
    public static CFAR_Budget_Contract_Tracking_gne__c createBudgetContractTracking(
        CFAR_Budget_Contract_gne__c bc,
        CFAR_Budget_Contract_Type_gne__c bct,
        Decimal amount
    ){
        return new CFAR_Budget_Contract_Tracking_gne__c(
            Budget_Contract_ref_gne__c = bc.Id,
            Type_ref_gne__c = bct.Id,
            Amount_gne__c = amount
        );
    }
    
    public static CFAR_Budget_Contract_Type_gne__c createBudgetContractType(){
        return new CFAR_Budget_Contract_Type_gne__c(
            Active_gne__c = true
        );
    }
    
    public static CFAR_Comment_gne__c createComment(CFAR_Trial_gne__c trial, String comment){
        return new CFAR_Comment_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Activity_Date_gne__c = Date.Today(),
            Comments_gne__c = comment
        );
    }
    
    public static CFAR_Budget_CPS_Projection_gne__c createBudgetProjection(
        CFAR_Trial_gne__c trial,
        Integer q1,
        Integer q2,
        Integer q3,
        Integer q4
    ){
        return new CFAR_Budget_CPS_Projection_gne__c(
            CFAR_Trial_ref_gne__c = trial.Id,
            Quarter_1_gne__c = q1,
            Quarter_2_gne__c = q2,
            Quarter_3_gne__c = q3,
            Quarter_4_gne__c = q4
        );
    }

    public class TeamMemberWithOrgInstAddrAggregate {
        public CFAR_Parent_Organization_gne__c org;
        public CFAR_Institution_gne__c inst;
        public CFAR_Contact_Address_gne__c addr;
        public CFAR_Contact_Address_JO_gne__c addrJO;
        public CFAR_Contact_gne__c contact;
        public CFAR_Team_Member_gne__c teamMember;
        public CFAR_Trial_gne__c trial;

        public TeamMemberWithOrgInstAddrAggregate(CFAR_Trial_gne__c trial) {
            this.trial = trial;
        }

        public void createTeamMemberWithRandomStructure() {
            createTeamMemberWithRandomStructure(CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, false);
        }

        public void createAnotherTeamMemberWithSameAddr(String roleName) {
            createTeamMemberWithRandomStructure(roleName, true);
        }

        public void createTeamMemberWithRandomStructure(String roleName, boolean sameAddr) {
            if (!sameAddr) {
                org = CFAR_DataFactory.createParentOrganization();
                insert org;
                inst = CFAR_DataFactory.createInstitution(org, 'Institution_' + Math.random());
                insert inst;
                addr = CFAR_DataFactory.createContactAddress2(inst, getRandomAddressType());
                insert addr;
            }
            Date activeOn = Date.newInstance(2016, 7, 4);
            contact = CFAR_DataFactory.createContact2('Contact Name' + Math.random(), CFAR_TeamMemberHelper.ROLE_PRIMARY_INVESTIGATOR, 'FirstName', 'LastName', activeOn);
            insert contact;
            addrJO = CFAR_DataFactory.createContactAddressJO(contact, addr);
            insert addrJO;
            teamMember = CFAR_DataFactory.createTeamMemberWithActiveOn(trial, 'teamMember1', addrJO, roleName, activeOn);
            insert teamMember;
        }

        private CFAR_Address_Type_gne__c getRandomAddressType() {
            CFAR_Address_Type_gne__c[] addresses = CFAR_DAO.getAddressTypes(new CFAR_SearchParameters());
            if (addresses.isEmpty()) {
                CFAR_TestUtils.createAddressTypes();
                addresses = CFAR_DAO.getAddressTypes(new CFAR_SearchParameters());
            }
            return addresses[0];
        }
    }
}