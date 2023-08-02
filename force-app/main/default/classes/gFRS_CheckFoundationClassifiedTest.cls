/**
* @author ADMD Team
* @date 20/08/2013
* @description gFRS_CheckFoundationClassifiedTest class - Unit test class for checking Foundation Classified and check if Payment Delivery is setting correctly
*/
@isTest(SeeAllData=true)
private with sharing class gFRS_CheckFoundationClassifiedTest {
    
    /**
    * @author ADMD Team
    * @date 20/08/2013
    * @description  testFellowshipFoundationClassified test method - testing if Foundation Classified is set correctly for Fellowship and check if Payment Delivery is set corecltlly
    */
    static testMethod void testFellowshipFoundationClassified()
    {
        GFRS_Funding_Request__c objReq;
        
        SetUpTestObjects testObjects = new SetUpTestObjects('Fellowship');
        system.assertEquals((testObjects.frIdFellowship!=null) ? true : false , true,'Funding Request was not set properly');
        objReq=objReq = [Select Id, Basic_Research_Fellow__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdFellowship];
        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,null,'field Foundation_Not_Eligible__c should be No');
        objReq.Basic_Research_Fellow__c='Yes';
        update objReq;
        objReq=objReq = [Select Id, Basic_Research_Fellow__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdFellowship];
        system.assertEquals(objReq.Foundation_Classified__c, 'TRUE', 'Foundation Classified should be set on TRUE');
        system.assertEquals(objReq.Delivery_Method__c, 'Manual', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,null,'field Foundation_Not_Eligible__c should be Yes');
        objReq.Foundation_Eligible__c='No';
        update objReq;
        objReq=objReq = [Select Id, Basic_Research_Fellow__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdFellowship];
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c, 'No','field Foundation_Eligible__c should be No');
        test.stopTest();
    }
    
    /**
    * @author ADMD Team
    * @date 20/08/2013
    * @description  testPhilanthropicFoundationClassified test method - testing if Foundation Classified is set correctly for Philanthropic and check if Payment Delivery is set corecltlly
    */
    static testMethod void testPhilanthropicFoundationClassified()
    {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        system.assertEquals((testObjects.frIdPhilanthropic!=null) ? true : false , true,'Funding Request was not set properly');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*At begining fields Students_of_Color_Scholarships__c, Hunger__c are set to No and Requested_Amount__c < 25000 so Foundation_Classified__c should be set to false*/
        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be set to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,null,'field Foundation_Not_Eligible__c should be No');
        Test.stopTest();
        System.debug('LIMIT 1: ' + Limits.getQueries());
    }

    static testMethod void testPhilanthropicFoundationClassified_Students_of_Color_Scholarships_YES()
    {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*Students_of_Color_Scholarships__c set to Yes Foundation should be classified and Payment Delivery should be changed to manual*/
        objReq.Students_of_Color_Scholarships__c='Yes';
        update objReq;

        objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];

        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'TRUE', 'Foundation Classified should be set on TRUE');
        system.assertEquals(objReq.Delivery_Method__c, 'Manual', 'Payment Delivery Method should be set to Manual');
        system.assertEquals(objReq.Students_of_Color_Scholarships__c,'Yes','field Students_of_Color_Scholarships__c should be set on YES');
        Test.stopTest();
    }

    static testMethod void testPhilanthropicFoundationClassified_Students_of_Color_Scholarships_NO()
    {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*Students_of_Color_Scholarships__c set to No Foundation should be not classified and Payment Delivery should be changed to vendor - before it was set to Manual*/
        objReq.Students_of_Color_Scholarships__c='No';
        update objReq;
        
        objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be set to Vendor');
        system.assertEquals(objReq.Students_of_Color_Scholarships__c,'No','field Students_of_Color_Scholarships__c should be set to No');
        Test.stopTest();
    }

    static testMethod void testPhilanthropicFoundationClassified_Hunger_YES()
    {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*Hunger__c set to Yes Foundation should be  classified and Payment Delivery should be changed to Manual - before it was set to Vendor*/
        objReq.Hunger__c='Yes';
        update objReq;
        
        objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'TRUE', 'Foundation Classified should be set on TRUE');
        system.assertEquals(objReq.Delivery_Method__c, 'Manual', 'Payment Delivery Method should be se to Manual');
        system.assertEquals(objReq.Hunger__c,'Yes','field Students_of_Color_Scholarships__c should be set to Yes');
        Test.stopTest();
    }

     static testMethod void testPhilanthropicFoundationClassified_Hunger_YES_Foundation_Eligible_NO()
     {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*Hunger__c set to Yes but Foundation_Not_Eligible__c is checked Foundation shouldn't  be  classified and Payment Delivery should be changed to Vendor - before it was set to Manual*/
        objReq.Hunger__c='Yes';
        objReq.Foundation_Eligible__c='No';
        update objReq;
        
        objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        Test.startTest();  
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be set to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,'No','field Foundation_Not_Eligible__c should be No');
        Test.stopTest();
    }

    static testMethod void testPhilanthropicFoundationClassified_Foundation_Eligible_YES()
     {
        SetUpTestObjects testObjects = new SetUpTestObjects('Philanthropic');
        GFRS_Funding_Request__c objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        /*Requested_Amount__c set to 26000 so it >25000 and Foundation_Not_Eligible__c is unchecked so Foundation should  be  classified and Payment Delivery should be changed to Manual - before it was set to Vendor*/
        objReq.Requested_Amount__c=26000;
        objReq.Approved_Amount__c=26000;
        objReq.Foundation_Eligible__c='Yes';
        update objReq;
        
        
        objReq = [Select Id, Students_of_Color_Scholarships__c,Hunger__c,Requested_Amount__c , Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdPhilanthropic];
        
        Test.startTest();
        system.assertEquals(objReq.Foundation_Classified__c, 'TRUE', 'Foundation Classified should be set on TRUE');
        system.assertEquals(objReq.Delivery_Method__c, 'Manual', 'Payment Delivery Method should be set to Manual');
        system.assertEquals(objReq.Requested_Amount__c,26000,'field Requested_Amount__c should be set to 26000');
        Test.stopTest();
    }
    
    /**
    * @author ADMD Team
    * @date 20/08/2013
    * @description  testFellowshipFoundationClassified test method - testing if Foundation Classified is set correctly for Fellowship and check if Payment Delivery is set corecltlly
    */
    static testMethod void testHcCharFoundationClassified()
    {
        GFRS_Funding_Request__c objReq;
        SetUpTestObjects testObjects = new SetUpTestObjects('HcChar');
        system.assertEquals((testObjects.frIdHcChar!=null) ? true : false , true,'Funding Request was not set properly');
        objReq=objReq = [Select Id, Pediatric_Cancer_Assistance__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdHcChar];
        Test.startTest();
        
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,null,'field Foundation_Eligible__c should be No');
        
        /*For HC CHAR if Pediatric_Cancer_Assistance__c is set to Yes Foundation should be Classified and Payment Delivery should be set to Manual*/
        objReq.Pediatric_Cancer_Assistance__c='Yes';
        update objReq;
        
        objReq=objReq = [Select Id, Pediatric_Cancer_Assistance__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdHcChar];
        system.assertEquals(objReq.Foundation_Classified__c, 'TRUE', 'Foundation Classified should be set on TRUE');
        system.assertEquals(objReq.Delivery_Method__c, 'Manual', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Pediatric_Cancer_Assistance__c,'Yes','field Pediatric_Cancer_Assistance__c should be Yes');
        
        objReq.Foundation_Eligible__c='No';
        update objReq;
        
        objReq=objReq = [Select Id, Basic_Research_Fellow__c, Foundation_Classified__c,Delivery_Method__c,Foundation_Eligible__c from GFRS_Funding_Request__c where id=: testObjects.frIdHcChar];
        system.assertEquals(objReq.Foundation_Classified__c, 'FALSE', 'Foundation Classified should be set on FALSE');
        system.assertEquals(objReq.Delivery_Method__c, 'Vendor', 'Payment Delivery Method should be se to Vendor');
        system.assertEquals(objReq.Foundation_Eligible__c,'No','field Foundation_Not_Eligible__c should be No');
        
        test.stopTest();
    }
    
    /**
    * @author ADMD Team
    * @date 20/08/2013
    * @description  SetUpTestObjects private class - private helper class for setting up data object for Unit Test.
    */
    private class SetUpTestObjects
    {
        public Account objAccount;
        public Contact objContact;
        public User objUser;
        public GFRS_Organization__c objOrg;
        public GFRS_Location__c objLoc;
        
        public id frIdFellowship; // Funding Request ID
        public id frIdPhilanthropic; // Funding Request ID
        public id frIdHcChar; // Funding Request ID
                
        public SetUpTestObjects(String fundingType)
        { 
            this.objAccount = gFRS_UnitTestHelper.CreateAccount('accTest' );            
            //this.objContact = gFRS_UnitTestHelper.CreateContact(this.objAccount.Id); -> contact not needed.
            this.objUser = gFRS_UnitTestHelper.CreateInternalGFRSUser();
            
            System.runAs(this.objUser)
            { 
             this.objOrg = gFRS_UnitTestHelper.CreateOrganization('01-9191329', this.objAccount.id );
             this.objLoc = gFRS_UnitTestHelper.CreateLocation( 'accTestLocation', this.objOrg.id );
             if(fundingType == 'Fellowship'){
                this.frIdFellowship = gFRS_UnitTestHelperFellowship.CreateFellowshipRequestInStatusNew(objOrg.id, objLoc.id,this.objUser);
             }else if(fundingType == 'Philanthropic'){  
                this.frIdPhilanthropic =gFRS_UnitTestHelperPhilanthropic.CreatePhilanthropicRequestInStatusNew(objOrg.id, objLoc.id,this.objUser);
             }else if(fundingType == 'HcChar'){ 
                this.frIdHcChar =gFRS_UnitTestHelperHcChar.CreateHcCharRequestInStatusNew(objOrg.id, objLoc.id,this.objUser);
             }
             
            }  
        }
    }

}