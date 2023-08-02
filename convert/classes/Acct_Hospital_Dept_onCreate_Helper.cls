/****************************************************************************************
        Ability to create hospital departments from a hospital record As a Hospital Department related list. In addition, the hospital department will inherit the Primary(or first, with MDM_AdressID or first if no primary) address of the hospital. This is needed to support the Lytics Launch.

        Departments should not be creatable via SBC, as they require a parent hospital.

        Department are a related list of Hospital Accounts, keyed by parent(account) Id.
        Each department is to copy it's address from its parent hosptial.
        Use Primary Address of Hospital
        If no Primary
        Use oldest active address with MDM_AddressID
        If no MDM_AddressID
        Use oldest active address

        Fields to copy:

        Address_line_2_vod__c
        City_vod__c
        External_ID_vod__c
        DEA_vod__c
        DEA_Expiration_Date_vod__c
        DEA_License_Address_vod__c
        Phone_vod__c
        Fax_vod__c
        Map_vod__c
        Comment_vod__c
        Shipping_vod__c
        Primary_vod__c=true
        License_vod__c
        License_Expiration_Date_vod__c
        Staff_notes_vod__c
        Appt_Required_vod__c
        Office_Notes_vod__c
        License_Status_vod__c
        Zip_4_vod__c
        Phone_2_vod__c
        Fax_2_vod__c
        License_Valid_To_Sample_vod__c
        Sample_Status_vod__c
        TLX_Address_Id_gen__c
        Address_Line_3_gne__c
        Address_Line_4_gne__c
        Country_gen__c
        Phone_1_Ext_gne__c
        Latitude_vod__c
        Zip_vod__c
        Best_Times_vod__c
        Source_vod__c
        Phone_2_Ext_gne__c
        Hospital_gne__c
        Clinic_gne__c
        Practice_Type_gne__c
        Business_vod__c
        Billing_vod__c
        Home_vod__c
        Mailing_vod__c
        State_vod__c
        Longitude_vod__c
        Practice_Size_gne__c
        Third_Party_Index_gne__c
        Third_Party_gne__c
        Third_Party_Id_gne__c
        Appointment_Restrictions_gne__c
        Active_Flag_gne__c
        Data_Source_gne__c
        Gatekeeper_gne__c
        Office_gne__c
        Satellite_gne__c
        MDM_Address_ID_gne__c
        MDM_GLID_gne__c
        Include_in_Territory_Assignment_vod__c
        Appointment_Type_gne__c
        AMS_gold_record_gne__c
        Days_in_Surgery_frm_gne__c
        Address_Types_frm_gne__c

        RecordType should be Hospital_Department
        The recordtype for the address should be "Rep Mantained"
        Address should be of Hospital flag checked. No other flags

        Each department should be aligned to first territory the user is assigned to.
        TSF should be created with My Target flag set to false

        An affiliation should be created between Department and Hospital of type:
        ORG HIERARCHY

        The new dept. name should be prepopulated with the following pattern:
        Hospital name + " - " + department type when left blank by the user.
        If user changes name it will be left alone. If name is blank reset to above.

    ****************************************************************************************/
public class Acct_Hospital_Dept_onCreate_Helper {
	public static void triggerHelperMethod(Set<Id> departmentsIds){
        Savepoint sp = Database.setSavepoint();
        // SFA-Canada changes
        List<RecordType> tmp = [select Id from Recordtype where (name='Hospital Department_vod' or name='GNE-SFA-Roche_Canada_Hospital_Depatment') and sObjectType='Account'];
        Set<Id> hospitalDepartmentId = new Set<Id>();
        for (RecordType rt : tmp){
        	hospitalDepartmentId.add(rt.id);
        }
        // end
        List<Account> hospitalDepartments=[Select Id,ParentId,RecordTypeId from Account where id in:departmentsIds and RecordtypeId=:hospitalDepartmentId];

        Map<Id,List<Id>> parentHospitalsDepartments=new Map<Id,List<Id>>();
        List<Address_vod__c> allAddresses=new List<Address_vod__c>();
        Map<Id,Address_vod__c> parentHospitalAdressesMapped=new Map<Id,Address_vod__c>();
        List<Address_vod__c> allNewAddresses=new List<Address_vod__c>();
        List<Id> reverseDeptAdressesMap=new List<Id>();
        List<Id> involvedDepartments=new List<Id>();
        // SFA-Canada changes
        Id addressRTId;
        if(hasCanadaProfile()){
        	addressRTId=[select Id from Recordtype where name='SFA Canada Rep Maintained HCO' and sObjectType='Address_vod__c'].Id;
        }else{
        	addressRTId=[select Id from Recordtype where name='Rep Maintained' and sObjectType='Address_vod__c'].Id;
        }
        // end
        for(integer i=0; i<hospitalDepartments.size(); i++){
            if(hospitalDepartmentId.contains(hospitalDepartments[i].RecordtypeId) && hospitalDepartments[i].ParentId!=null){
                if(!parentHospitalsDepartments.containsKey(hospitalDepartments[i].ParentId)) parentHospitalsDepartments.put(hospitalDepartments[i].ParentId,new List<id>());
                parentHospitalsDepartments.get(hospitalDepartments[i].ParentId).add(hospitalDepartments[i].Id);
                involvedDepartments.add(hospitalDepartments[i].Id);
            }
        }
        if(parentHospitalsDepartments.isEmpty()) return;

        /*
            Use Primary Address of Hospital
            If no Primary
            Use oldest active address with MDM_AddressID
            If no MDM_AddressID
            Use oldest active address
        */

        allAddresses = [select RecordTypeId,
                                Address_line_2_vod__c,
                                City_vod__c,
                                External_ID_vod__c,
                                DEA_vod__c,
                                DEA_Expiration_Date_vod__c,
                                DEA_License_Address_vod__c,
                                Phone_vod__c,
                                Fax_vod__c,
                                Map_vod__c,
                                Name,
                                Comment_vod__c,
                                Shipping_vod__c,
                                Primary_vod__c,
                                License_vod__c,
                                License_Expiration_Date_vod__c,
                                Staff_notes_vod__c,
                                Appt_Required_vod__c,
                                Office_Notes_vod__c,
                                License_Status_vod__c,
                                Zip_4_vod__c,
                                Phone_2_vod__c,
                                Fax_2_vod__c,
                                License_Valid_To_Sample_vod__c,
                                Sample_Status_vod__c,
                                TLX_Address_Id_gen__c,
                                Address_Line_3_gne__c,
                                Address_Line_4_gne__c,
                                Country_gen__c,
                                Phone_1_Ext_gne__c,
                                Latitude_vod__c,
                                Zip_vod__c,
                                Best_Times_vod__c,
                                Source_vod__c,
                                Phone_2_Ext_gne__c,
                                Hospital_gne__c,
                                Clinic_gne__c,
                                Practice_Type_gne__c,
                                Business_vod__c,
                                Billing_vod__c,
                                Home_vod__c,
                                Mailing_vod__c,
                                State_vod__c,
                                Longitude_vod__c,
                                Practice_Size_gne__c,
                                Third_Party_Index_gne__c,
                                Third_Party_gne__c,
                                Third_Party_Id_gne__c,
                                Appointment_Restrictions_gne__c,
                                Active_Flag_gne__c,
                                Data_Source_gne__c,
                                Gatekeeper_gne__c,
                                Office_gne__c,
                                Satellite_gne__c,
                                MDM_Address_ID_gne__c,
                                MDM_GLID_gne__c,
                                Include_in_Territory_Assignment_vod__c,
                                Appointment_Type_gne__c,
                                AMS_gold_record_gne__c,
                                Days_in_Surgery_frm_gne__c,
                                Address_Types_frm_gne__c,
                                CreatedDate,
                                Account_vod__c,
                                // SFA-Canada specific fields
                                Postal_Code_can_gne__c,
                                Province_can_gne__c
                            from Address_vod__c where Account_vod__c in:parentHospitalsDepartments.keySet() and Inactive_vod__c=false];


        //Retrieving winning address records
        for(Address_vod__c addr:allAddresses){
            if(!parentHospitalAdressesMapped.containsKey(addr.Account_vod__c)){
                parentHospitalAdressesMapped.put(addr.Account_vod__c,addr);
                continue;
            }
            Address_vod__c currAddr=parentHospitalAdressesMapped.get(addr.Account_vod__c);
            if(currAddr.Primary_vod__c==true) continue;
            if(currAddr.CreatedDate<addr.CreatedDate && currAddr.MDM_Address_ID_gne__c!=null) continue;
            if( (addr.CreatedDate<currAddr.CreatedDate && addr.MDM_Address_ID_gne__c!=null)
                || (addr.CreatedDate<currAddr.CreatedDate && addr.MDM_Address_ID_gne__c==null && currAddr.MDM_Address_ID_gne__c==null)
                || addr.Primary_vod__c==true){
                parentHospitalAdressesMapped.put(addr.Account_vod__c,addr);
                continue;
            }
        }
        //Creating new address records
        for(id parentHospitalId:parentHospitalAdressesMapped.keyset()){
            Address_vod__c addr=parentHospitalAdressesMapped.get(parentHospitalId);
            for(Id departmentId:parentHospitalsDepartments.get(parentHospitalId)){
                Address_vod__c addr2=new Address_vod__c(
                                    Account_vod__c=departmentId,
                                    RecordTypeId=addressRTId,
                                    Address_line_2_vod__c=addr.Address_line_2_vod__c,
                                    City_vod__c=addr.City_vod__c,
                                    External_ID_vod__c=addr.External_ID_vod__c,
                                    DEA_vod__c=addr.DEA_vod__c,
                                    DEA_Expiration_Date_vod__c=addr.DEA_Expiration_Date_vod__c,
                                    DEA_License_Address_vod__c=addr.DEA_License_Address_vod__c,
                                    Phone_vod__c=addr.Phone_vod__c,
                                    Fax_vod__c=addr.Fax_vod__c,
                                    Name=addr.Name,
                                    //Map_vod__c=addr.Map_vod__c,
                                    Comment_vod__c=addr.Comment_vod__c,
                                    Shipping_vod__c=addr.Shipping_vod__c,
                                    Primary_vod__c=TRUE,
                                    License_vod__c=addr.License_vod__c,
                                    License_Expiration_Date_vod__c=addr.License_Expiration_Date_vod__c,
                                    Staff_notes_vod__c=addr.Staff_notes_vod__c,
                                    Appt_Required_vod__c=addr.Appt_Required_vod__c,
                                    Office_Notes_vod__c=addr.Office_Notes_vod__c,
                                    License_Status_vod__c=addr.License_Status_vod__c,
                                    Zip_4_vod__c=addr.Zip_4_vod__c,
                                    Phone_2_vod__c=addr.Phone_2_vod__c,
                                    Fax_2_vod__c=addr.Fax_2_vod__c,
                                    //License_Valid_To_Sample_vod__c=addr.License_Valid_To_Sample_vod__c,
                                    //Sample_Status_vod__c=addr.Sample_Status_vod__c,
                                    TLX_Address_Id_gen__c=addr.TLX_Address_Id_gen__c,
                                    Address_Line_3_gne__c=addr.Address_Line_3_gne__c,
                                    Address_Line_4_gne__c=addr.Address_Line_4_gne__c,
                                    Country_gen__c=addr.Country_gen__c,
                                    Phone_1_Ext_gne__c=addr.Phone_1_Ext_gne__c,
                                    Latitude_vod__c=addr.Latitude_vod__c,
                                    Zip_vod__c=addr.Zip_vod__c,
                                    Best_Times_vod__c=addr.Best_Times_vod__c,
                                    Source_vod__c=addr.Source_vod__c,
                                    Phone_2_Ext_gne__c=addr.Phone_2_Ext_gne__c,
                                    Clinic_gne__c=addr.Clinic_gne__c,
                                    Practice_Type_gne__c=addr.Practice_Type_gne__c,
                                    Business_vod__c=addr.Business_vod__c,
                                    Billing_vod__c=addr.Billing_vod__c,
                                    Home_vod__c=addr.Home_vod__c,
                                    Mailing_vod__c=addr.Mailing_vod__c,
                                    State_vod__c=addr.State_vod__c,
                                    Longitude_vod__c=addr.Longitude_vod__c,
                                    Practice_Size_gne__c=addr.Practice_Size_gne__c,
                                    Third_Party_Index_gne__c=addr.Third_Party_Index_gne__c,
                                    Third_Party_gne__c=addr.Third_Party_gne__c,
                                    Third_Party_Id_gne__c=addr.Third_Party_Id_gne__c,
                                    Appointment_Restrictions_gne__c=addr.Appointment_Restrictions_gne__c,
                                    Active_Flag_gne__c=addr.Active_Flag_gne__c,
                                    Data_Source_gne__c=addr.Data_Source_gne__c,
                                    Gatekeeper_gne__c=addr.Gatekeeper_gne__c,
                                    Office_gne__c=addr.Office_gne__c,
                                    Satellite_gne__c=addr.Satellite_gne__c,
                                    MDM_Address_ID_gne__c=addr.MDM_Address_ID_gne__c,
                                    MDM_GLID_gne__c=addr.MDM_GLID_gne__c,
                                    Include_in_Territory_Assignment_vod__c=addr.Include_in_Territory_Assignment_vod__c,
                                    Appointment_Type_gne__c=addr.Appointment_Type_gne__c,
                                    AMS_gold_record_gne__c=addr.AMS_gold_record_gne__c,
                                    Days_in_Surgery_frm_gne__c=addr.Days_in_Surgery_frm_gne__c,
                                    Hospital_gne__c=true,
                                    //Account_vod__cAddress_Types_frm_gne__c=addr.Address_Types_frm_gne__c
                                    // SFA-Canada specific fields
                                    Postal_Code_can_gne__c=addr.Postal_Code_can_gne__c,
                                    Province_can_gne__c=addr.Province_can_gne__c
                );
                allNewAddresses.add(addr2);
                reverseDeptAdressesMap.add(departmentId);
            }
        }
        //allNewAddresses now is ready for insert!

        /*

            Each department should be aligned to first territory the user is assigned to.

        */

        List<Id> reverseDeptAccountShareMap=new List<Id>();
        List<ObjectTerritory2Association> territoryAssociations = new List<ObjectTerritory2Association>();
        List<UserTerritory2Association> uts= [Select u.Territory2Id, u.UserId from UserTerritory2Association u where u.UserId=:userinfo.getuserid() LIMIT 1];
        if(uts.size()>0){
            Group grp=[Select g.Id from Group g where g.Type='Territory' and g.RelatedId=:uts[0].Territory2Id];
            for(Id hospitalId:parentHospitalsDepartments.keyset()){
                for(Id departmentId:parentHospitalsDepartments.get(hospitalId)){
                    ObjectTerritory2Association territoryAssociation = new ObjectTerritory2Association(ObjectId = departmentId, Territory2Id = uts[0].Territory2Id, AssociationCause='Territory2Manual');
                    territoryAssociations.add(territoryAssociation);
                    reverseDeptAccountShareMap.add(departmentId);
                }
            }
        }

        /*
        List<TSF_vod__c> hospitalTsfs=[ Select t.Account_vod__c, t.My_Target_vod__c,Territory_vod__c from TSF_vod__c t where t.Account_vod__c IN:parentHospitalsDepartments.keySet()];
        List<TSF_vod__c> departmentsTsfs=new List<TSF_vod__c>();
        List<Id> reverseDeptTSFMap=new List<Id>();
        for (TSF_vod__c tsf:hospitalTsfs){
            for(Id departmentId:parentHospitalsDepartments.get(tsf.Account_vod__c)){
                TSF_vod__c tsf2=new TSF_vod__c(Territory_vod__c=tsf.Territory_vod__c, My_Target_vod__c=FALSE, Account_vod__c=departmentId);
                departmentsTsfs.add(tsf2);
                reverseDeptTSFMap.add(departmentId);
            }
        }
        //departmentsTsfs now is ready for insert!
        */


        List<Affiliation_vod__c> departmentsAffiliations=new List<Affiliation_vod__c>();
        List<Id> reverseDeptAffiliationMap=new List<Id>();
        for(Id hospitalId:parentHospitalsDepartments.keyset()){
            for(Id departmentId:parentHospitalsDepartments.get(hospitalId)){
                Affiliation_vod__c aff2=new Affiliation_vod__c(Affiliation_Type_gne__c='ORG HIERARCHY', From_Account_vod__c=hospitalId, To_Account_vod__c=departmentId);
                departmentsAffiliations.add(aff2);
                reverseDeptAffiliationMap.add(departmentId);
            }
        }
        //departmentsAffiliations now is ready for insert!



        //-----------------------------------------------------------------------------
        //
        //      Upsert
        //
        //-----------------------------------------------------------------------------
        Database.UpsertResult[] lsr=new List<Database.UpsertResult>();
        integer exceptionsCount;

        //  Upserting Addresses

        lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(allNewAddresses,false);

        //  Error Verification
        exceptionsCount=0;
        for(integer i=0;i<lsr.size();i++){
            Database.UpsertResult  sr=lsr.get(i);
            if(!sr.isSuccess()){
                exceptionsCount++;
                for(Database.Error err:sr.getErrors()){
                   // hospitalDepartmentsMap.get(reverseDeptAdressesMap.get(i)).addError(err.getStatusCode().name() + ' ' + err.getMessage());
                    System.debug(logginglevel.ERROR,err.getStatusCode().name() + ' ' + err.getMessage());
                }
            }
        }
        if(exceptionsCount>0) {Database.rollback(sp); return;}

        lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(territoryAssociations,false);

        //  Error Verification
        exceptionsCount=0;
        for(integer i=0;i<lsr.size();i++){
            Database.UpsertResult  sr=lsr.get(i);
            if(!sr.isSuccess()){
                exceptionsCount++;
                for(Database.Error err:sr.getErrors()){
                    //hospitalDepartmentsMap.get(reverseDeptAccountShareMap.get(i)).addError(err.getStatusCode().name() + ' ' + err.getMessage());
                    System.debug(logginglevel.ERROR,err.getStatusCode().name() + ' ' + err.getMessage());
                }
            }
        }

        if(exceptionsCount>0) {Database.rollback(sp); return;}

        //  Upserting departmentsASH
        /*
        lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(departmentsTsfs,false);

        //  Error Verification
        exceptionsCount=0;
        for(integer i=0;i<lsr.size();i++){
            Database.UpsertResult  sr=lsr.get(i);
            if(!sr.isSuccess()){
                exceptionsCount++;
                for(Database.Error err:sr.getErrors()){
                    //hospitalDepartmentsMap.get(reverseDeptTSFMap.get(i)).addError(err.getStatusCode().name() + ' ' + err.getMessage());
                    System.debug(logginglevel.ERROR,err.getStatusCode().name() + ' ' + err.getMessage());
                }
            }
        }
        if(exceptionsCount>0) {Database.rollback(sp); return;}
        */

        //  Upserting departmentsAffiliations
        lsr = Utilities_BulkDMLOperationsUtils.batchDMLupsert(departmentsAffiliations,false);
        //  Error Verification
        exceptionsCount=0;
        for(integer i=0;i<lsr.size();i++){
            Database.UpsertResult  sr=lsr.get(i);
            if(!sr.isSuccess()){
                exceptionsCount++;
                for(Database.Error err:sr.getErrors()){
                    //hospitalDepartmentsMap.get(reverseDeptAffiliationMap.get(i)).addError(err.getStatusCode().name() + ' ' + err.getMessage());
                    System.debug(logginglevel.ERROR,err.getStatusCode().name() + ' ' + err.getMessage());
                }
            }
        }
        if(exceptionsCount>0) {Database.rollback(sp); return;}
    }

	//method to indicate whether the logged on user is a Canada user
    private static boolean hasCanadaProfile() {
    	String profileName = [SELECT Name FROM Profile WHERE Id = :Userinfo.getProfileId()].Name;
        if (profileName != null && profileName.toUpperCase().contains('CANADA')) {
              return true;
        } else {
              return false;
        }
    }

}
 /****************************************************************************************
        Requirement # 2211
        Owner Christine Holland [Change] Status Ready for Deployment
        Project SFA Brands Impact Analysis Unknown
        Req # SOIM-563 Approval Date 2/26/2009
        Source CRM Enhancements Approved By Christine Holland
        Priority High Baseline GNE 4.0.10 (April M/E)
        Profile Requirement Applies To Lytics Development Resource Alberto Marabini
        Subject Provide the Ability to Create Hospital Departments Using Search Before Create'
        Description Ability to create hospital departments from a hospital record As a Hospital Department related list. In addition, the hospital department will inherit the Primary(or first, with MDM_AdressID or first if no primary) address of the hospital. This is needed to support the Lytics Launch.

        Department are a related list of Hospital Accounts, keyed by parent(account) Id.
        Each department is to copy it's address from its parent hosptial.
        Use Primary Address of Hospital
        If no Primary
        Use oldest active address with MDM_AddressID
        If no MDM_AddressID
        Use oldest active address

        Fields to copy:

        Address_line_2_vod__c
        City_vod__c
        External_ID_vod__c
        DEA_vod__c
        DEA_Expiration_Date_vod__c
        DEA_License_Address_vod__c
        Phone_vod__c
        Fax_vod__c
        Map_vod__c
        Comment_vod__c
        Shipping_vod__c
        Primary_vod__c=true
        License_vod__c
        License_Expiration_Date_vod__c
        Staff_notes_vod__c
        Appt_Required_vod__c
        Office_Notes_vod__c
        License_Status_vod__c
        Zip_4_vod__c
        Phone_2_vod__c
        Fax_2_vod__c
        License_Valid_To_Sample_vod__c
        Sample_Status_vod__c
        TLX_Address_Id_gen__c
        Address_Line_3_gne__c
        Address_Line_4_gne__c
        Country_gen__c
        Phone_1_Ext_gne__c
        Latitude_vod__c
        Zip_vod__c
        Best_Times_vod__c
        Source_vod__c
        Phone_2_Ext_gne__c
        Hospital_gne__c
        Clinic_gne__c
        Practice_Type_gne__c
        Business_vod__c
        Billing_vod__c
        Home_vod__c
        Mailing_vod__c
        State_vod__c
        Longitude_vod__c
        Practice_Size_gne__c
        Third_Party_Index_gne__c
        Third_Party_gne__c
        Third_Party_Id_gne__c
        Appointment_Restrictions_gne__c
        Active_Flag_gne__c
        Data_Source_gne__c
        Gatekeeper_gne__c
        Office_gne__c
        Satellite_gne__c
        MDM_Address_ID_gne__c
        MDM_GLID_gne__c
        Include_in_Territory_Assignment_vod__c
        Appointment_Type_gne__c
        AMS_gold_record_gne__c
        Days_in_Surgery_frm_gne__c
        Address_Types_frm_gne__c

        RecordType should be Hospital_Department
        The recordtype for the address should be "Rep Mantained"
        Address should be of Hospital flag checked. No other flags

        Each department should be aligned to first territory the user is assigned to.
        TSF My Target flag should be set a false

        An affiliation should be created between Department and Hospital of type:
        ORG HIERARCHY

        The new dept. name should be prepopulated with the following pattern:
        Hospital name + " - " + department type when left blank by the user.
        If user changes name it will be left alone. If name is blank reset to above.

    ****************************************************************************************/
    /****************************************************************************************
    Prior Versioning Requirements
    Req #
        SOIM-563
    Approval Date
        2/26/2009
    Source
        CRM Enhancements
    Subject
        Provide the Ability to Create Hospital Departments Using Search Before Create'
    Description
        Ability to create hospital departments using the 'Search Before Create' functionality. This is needed to support the Lytics Launch.

        Department are a related list of Hospital Accounts, keyed by parent(account) Id.
        Each department is to copy it's address from its parent hosptial.
        Use Primary Address of Hospital
        If no Primary
        Use oldest active address

        Each department should copy any alignment from parent acccount
        TSF My Target flag should be copied as well

        An affiliation should be created between Department and Hospital of type:
        ORG HIERARCHY
    ****************************************************************************************/