/**
 * This class contains unit tests for validating the behavior of Apex classes
 * and triggers.
 *
 * Unit tests are class methods that verify whether a particular piece
 * of code is working properly. Unit test methods take no arguments,
 * commit no data to the database, and are flagged with the testMethod
 * keyword in the method definition.
 *
 * All test methods in an organization are executed whenever Apex code is deployed
 * to a production organization to confirm correctness, ensure code
 * coverage, and prevent regressions. All Apex classes are
 * required to have at least 75% code coverage in order to be deployed
 * to a production organization. In addition, all triggers must have some code coverage.
 * 
 * The @isTest class annotation indicates this class only contains test
 * methods. Classes defined with the @isTest annotation do not count against
 * the organization size limit for all Apex scripts.
 *
 * See the Apex Language Reference for more information about Testing and Code Coverage.
 */
@isTest
private class GFRS_AttachmentCollectorTest {

    class TestSettings {
        Account acct;
        Account acct2;
        Attachment[] attachments;
        GFRS_AttachmentCollector collector;
        
        public TestSettings(){
        }
        
        public void setup1(){
            this.acct = gFRS_TestCreationUtils.createAccount('testAccount');
            insert this.acct;

            this.acct2 = gFRS_TestCreationUtils.createAccount('testAccount2');
            insert this.acct2;
            
            Attachment att = gFRS_TestCreationUtils.createAttachment(this.acct.Id, 'testName', Blob.valueOf('testBody'));
            insert att;
            this.attachments = [SELECT Id, name, body FROM Attachment WHERE Id =: att.Id]; 
            
            this.collector = new GFRS_AttachmentCollector( this.attachments );
        }
    }
    
    static testMethod void initialTest(){
        TestSettings ts = new TestSettings();
        ts.setup1();
        
        Attachment myAttachment;
        myAttachment = ts.collector.getFoundAttachmentByKey( null );
        System.assertEquals( null, myAttachment, 'null must not find an attachment' );
        
        myAttachment = ts.collector.getFoundAttachmentByKey( ts.attachments[0].id );
        System.assertNotEquals( null, myAttachment, 'attachment must be found since it was given an id' );
        System.assertEquals( ts.attachments[0].id, myAttachment.id, 'attachment id found must match that given to find it' );
        
        myAttachment = ts.collector.getFoundAttachmentByKey( 'someImpossibleId' );
        System.assertEquals( null, myAttachment, 'invalid id must not find an attachment' );
    }
    
    static testMethod void testFindOrMakeOne(){
        TestSettings ts = new TestSettings();
        ts.setup1();
        
        Attachment myAttachment;
        myAttachment = ts.collector.getFoundAttachmentByKeyOrMakeOne('unknownKey',ts.acct2.id );
        System.assertNotEquals( null, myAttachment, 'an unknown key must still have a response' );
        System.assertEquals( null, myAttachment.id );
        System.assertEquals( ts.acct2.id, myAttachment.ParentId );
        
        myAttachment = ts.collector.getFoundAttachmentByKeyOrMakeOne( null, ts.acct2.id );
        System.assertNotEquals( null, myAttachment, 'null key must still have a response' );
        System.assertEquals( null, myAttachment.id );
        System.assertEquals( ts.acct2.id, myAttachment.ParentId );
        
        myAttachment = ts.collector.getFoundAttachmentByKeyOrMakeOne( ts.attachments[0].id, ts.acct2.id  );
        System.assertNotEquals( null, myAttachment, 'attachment sent must be found' );
    }

    static testMethod void testFoundAttachments(){
        TestSettings ts = new TestSettings();
        ts.setup1();
        
        Boolean found = ts.collector.foundAttachments();
        System.assertEquals(true, found, 'Found should return true');
    }
}