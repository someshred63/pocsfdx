public class SCM_AA_BatchFaxStatus {

    public PageReference close() {
        return null;
    }

public String StatusMessage{get
{
 if (ApexPages.currentPage().getParameters().get('status') == 'Failed') {
 	return ApexPages.currentPage().getParameters().get('Message').replace('$$returnLine$$','<BR>');
 }
 else if (ApexPages.currentPage().getParameters().get('status') == 'Success')
 {
 	return 'Your batch fax job was successfully placed in the queue.';
 }
 return 'there was an error ' + ApexPages.currentPage().getParameters().get('status');
}
set{StatusMessage = value;}}
}