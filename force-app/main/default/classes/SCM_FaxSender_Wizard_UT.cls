@isTest
private class SCM_FaxSender_Wizard_UT {

    static testMethod void SCM_FaxSender_WizardUnitTest() {
        SCM_FaxSender_Wizard fsw = new SCM_FaxSender_Wizard();
        
        string testString;

        testString = fsw.getStep();
        
        PageReference pr;
        pr = fsw.next();
        pr = fsw.previous();
        pr = fsw.reset();
        pr = fsw.sendFax();
        pr = fsw.moveUp();
        pr = fsw.moveDown();
        
        testString = fsw.getTitle();
        testString = fsw.getCoverSheetTitle();
        testString = fsw.getDocumentsTitle();
        testString = fsw.getCoverSheetIndex();
        pr = fsw.reset();
        
        pr = fsw.next();
        testString = fsw.getTitle();
        testString = fsw.getCoverSheetTitle();
        testString = fsw.getDocumentsTitle();
        testString = fsw.getCoverSheetIndex();
        pr = fsw.reset();
        
        pr = fsw.next();
        testString = fsw.getTitle();
        testString = fsw.getCoverSheetTitle();
        testString = fsw.getDocumentsTitle();
        testString = fsw.getCoverSheetIndex();
        pr = fsw.reset();
        
        pr = fsw.next();
        testString = fsw.getTitle();
        testString = fsw.getCoverSheetTitle();
        testString = fsw.getDocumentsTitle();
        testString = fsw.getCoverSheetIndex();
        pr = fsw.reset();
        
        pr = fsw.sendFax();
        pr = fsw.next();
        testString = fsw.getTitle();
        testString = fsw.getCoverSheetTitle();
        testString = fsw.getDocumentsTitle();
        testString = fsw.getCoverSheetIndex();
        testString = fsw.getFormType();
        
        pr = fsw.sendFax();
        List<SCM_FaxSender_Doc> docs;
        docs = fsw.getCoverSheet();
        docs = fsw.getDocuments();
        
        boolean testFlag = false;
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        pr = fsw.next();
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        pr = fsw.next();
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        pr = fsw.next();
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        pr = fsw.next();
        testFlag = fsw.getShowRadioButton();
        testFlag = fsw.getShowCheckbox();
        testFlag = fsw.getShowSequencingButtons();
        testFlag = fsw.getShowFaxCovers();
        testFlag = fsw.getShowDocuments();
        testFlag = fsw.getShowWizard();
        testFlag = fsw.getShowConfirmation();
        testFlag = fsw.getShowPreviousButton();
        testFlag = fsw.getShowNextButton();
        testFlag = fsw.getShowResetButton();
        testFlag = fsw.getShowSendFaxButton();
        testFlag = fsw.getShowCancelButton();
        
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        pr = fsw.previous();
        
        fsw.HiddenAction = 'SelectedCover';
        fsw.processForm();
        pr = fsw.moveUp();
        pr = fsw.moveDown();
        
        pr = fsw.next();
        fsw.HiddenAction = 'SelectedCover';
        fsw.processForm();
        pr = fsw.moveUp();
        pr = fsw.moveDown();
        
        pr = fsw.next();
        fsw.HiddenAction = 'SelectedCover';
        fsw.processForm();
        pr = fsw.moveUp();
        pr = fsw.moveDown();
        
        pr = fsw.next();
        fsw.HiddenAction = 'SelectedCover';
        fsw.processForm();
        pr = fsw.moveUp();
        pr = fsw.moveDown();
    }
}