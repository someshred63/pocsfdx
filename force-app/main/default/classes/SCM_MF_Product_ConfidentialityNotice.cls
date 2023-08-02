public class SCM_MF_Product_ConfidentialityNotice  extends SCM_MergeField{
    public SCM_MF_Product_ConfidentialityNotice(SObject obj) 
    { 
        fieldValue = '';
        String productName='';
        if(obj instanceof Hotline_gne__c)
        {
            Hotline_gne__c hotline=(Hotline_gne__c)obj;
            productName=hotline.Product_gne__c;
        }
        else if(obj instanceof Case)
        {
            Case selectedCase=(Case)obj;
            productName =selectedCase.Product_gne__c;
        }
        
        setCommons(productName);
    }
    
    public SCM_MF_Product_ConfidentialityNotice(String productName)
    {
        setCommons(productName);
    }
    
    private void setCommons(String productName)
    {
        key = 'ConfidNotice';
        checked = false;
        displayCheck = false;
        displayTextBox = false;
        displayLabel = false;
        className = 'SCM_MF_Product_ConfidentialityNotice';
        fieldValue = 'The documents accompanying this facsimile transmission contain information that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        
        if(productName==null || productName=='')
            return;

        if(productName.contains('Lucentis'))
            fieldValue ='The documents accompanying this facsimile transmission contain information from LUCENTIS Access Solutions that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        else if(productName.contains('Nutropin'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information from Nutropin Access Solutions that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        else if(productName.contains('TNKase'))
            fieldValue = 'This document contains confidential information and is intended solely for the use of the individual(s) or entity to which it is addressed.';
        else if(productName.contains('Xolair'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information from XOLAIR Access Solutions that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        else if(productName.contains('Actemra'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        else if(productName.contains('Xeloda'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
        else if(productName.contains('Pegasys'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information from Pegasys Access Solutions that is confidential or privileged.    This Information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of the them to the intended recipient.';
        else if(productName.contains('Zelboraf'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information from Zelboraf Access Solutions that is confidential or privileged.    This Information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of the them to the intended recipient.';       
        else if(productName.contains('Erivedge'))
            fieldValue = 'The documents accompanying this facsimile transmission contain information from Erivedge Access Solutions that is confidential or privileged.    This Information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of the them to the intended recipient.';       
        else /*if(productName.contains('Avastin') || productName.contains('Herceptin') ||
                productName.contains('Raptiva') || productName.contains('Pulmozyme') ||
                productName=='Rituxan' || productName=='Rituxan RA' ||
                productName.contains('Tarceva') || productName.contains('TNKase') || 
                productName.contains('Activase')
                )*/
            fieldValue = 'The documents accompanying this facsimile transmission contain information that is confidential or privileged.  This information is intended for the individual or entity named on this transmission sheet.  If you are not the intended recipient, be aware that any disclosure, copying, distribution or use of the contents of this faxed information is strictly prohibited.  If you received this fax in error, please notify us by telephone so that we can arrange for the return of the original documents to us and the re-transmission of them to the intended recipient.';
    }
}