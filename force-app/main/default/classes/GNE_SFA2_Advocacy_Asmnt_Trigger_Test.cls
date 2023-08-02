/************************************************************
*  @author: probably Rakesh Boinepalli
*  Date: 2013-02-01
*  Description: This is a test class for GNE_SFA2_Advocacy_Assesment_Trigger trigger.
*  
*  Modification History
*  Date        Name        			Description
*  2013/12/16  Piotr Przesmycki     Fixed test, so that it runs trigger code, added comment header to this class
*  2014-02-19  Piotr Przesmycki 	Modified unit test to use GNE_SFA2_Triggers_Test_Util for creating data
*************************************************************/
@isTest
public with sharing class GNE_SFA2_Advocacy_Asmnt_Trigger_Test {

	public static testMethod void testInsert(){ 
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			Test.startTest();
								
			System.runAs(sfa2User){
				List<Advocacy_Assessment_gne__c> advocacyAsmntList = new List<Advocacy_Assessment_gne__c>();
				
				Advocacy_Assessment_gne__c mem1 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem2 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem3 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem4 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem5 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem6 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem7 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=10;
				
				advocacyAsmntList.add(mem1);advocacyAsmntList.add(mem2);advocacyAsmntList.add(mem3);advocacyAsmntList.add(mem4);advocacyAsmntList.add(mem5);advocacyAsmntList.add(mem6);advocacyAsmntList.add(mem7);
				
				try{
					insert advocacyAsmntList;
				} catch(Exception e){
					System.assert(true,e.getMessage());//this is expected. 
				}

				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=2;
				try{
					insert advocacyAsmntList;
				} catch(Exception e){
					System.assert(false,e.getMessage());//now it should save
				}
			}
			Test.stopTest();
		}
	}
	
	public static testMethod void testUpdate(){ 
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			Test.startTest();
							
			System.runAs(sfa2User){
				List<Advocacy_Assessment_gne__c> advocacyAsmntList = new List<Advocacy_Assessment_gne__c>();
				
				Advocacy_Assessment_gne__c mem1 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem2 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem3 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem4 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem5 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem6 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem7 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=2;
				advocacyAsmntList.add(mem1);advocacyAsmntList.add(mem2);advocacyAsmntList.add(mem3);advocacyAsmntList.add(mem4);advocacyAsmntList.add(mem5);advocacyAsmntList.add(mem6);advocacyAsmntList.add(mem7);
					
				try{
					insert advocacyAsmntList;
				} catch(Exception e){
					System.assert(false,e.getMessage());//now it should save
				}

				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=3;
				try{
					update advocacyAsmntList;
				} catch(Exception e){
					System.assert(false,e.getMessage());//now it should save
				}
			}
			Test.stopTest();
		}
	}

	public static testMethod void testValidationRules(){ 
		User sfa2User = GNE_SFA2_Util.selectSFA2User();
		if(sfa2User!=null){
			Test.startTest();

			System.runAs(sfa2User){

				List<Advocacy_Assessment_gne__c> advocacyAsmntList = new List<Advocacy_Assessment_gne__c>();

				Advocacy_Assessment_gne__c mem1 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem2 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem3 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem4 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem5 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem6 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				Advocacy_Assessment_gne__c mem7 = GNE_SFA2_Triggers_Test_Util.prepareAdvocacy_Assessment_gne();
				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=5;

				try{
					insert mem1;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem2;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem3;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem4;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				try{
					insert mem5;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				try{
					insert mem6;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem7;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				mem1.Usage_of_15_mg_gne__c=mem2.Brand_Message_3_gne__c=mem3.Benefit_in_multiple_lines_of_therapy_gne__c=mem4.Flare_Management_gne__c=mem5.Treatment_until_disease_progression_gne__c=mem6.Avastin_Lung_Standard_of_Care_gne__c=mem7.Rash_management_Tarceva_Pancreatic_gne__c=0;
				try{
					insert mem1;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}
					
				try{
					insert mem2;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem3;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				try{
					insert mem4;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				try{
					insert mem5;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}

				try{
					insert mem6;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION  , ex.getDmlType(0));
				}

				try{
					insert mem7;
					system.assert(false,'this line should not be reached');
				} catch(DMLException ex){
					System.assert(ex.getMessage().contains(System.Label.Advocay_Assmnt_Value_Check), ex.getMessage());
					System.assertEquals(StatusCode.FIELD_CUSTOM_VALIDATION_EXCEPTION , ex.getDmlType(0));
				}
			}
			Test.stopTest();
		}
	}
}