@istest
private class SCM_Save_to_Case_test {
public static testmethod void mytest() {
    SCM_Save_to_Case s = new SCM_Save_to_Case();
    //regular test
s.SaveType = 'save';
s.casenum = '00003535';
s.assignto = 'Kosow, Andrew';
s.assigntoid = '005S0000000NBJoIAO';
s.UserEmail = 'hedget@gene.com';
s.UserKey = 'EA0012B461244ED9B8C6F99C191D5FEE';
s.DocumentString = 'Document,302012;';
s.istest = true;
s.save();
//save as a transfer
s.SaveType = 'transfer';
s.save();
//save as a copy
s.SaveType = 'copy';
s.save();
//nocase number test 
s.casenum = '';
s.save();
//no user selected
s.casenum = '00003535';
s.assignto = '';
s.assigntoid = '';
s.save();
//document is a folder
s.assignto = 'Kosow, Andrew';
s.assigntoid = '005S0000000NBJoIAO';
s.DocumentString = 'Folder,302012;';
s.save();
//nothing set
s.casenum = '';
s.assignto = '';
s.assigntoid = '';
s.UserEmail = '';
s.UserKey = '';
s.DocumentString = '';
s.istest = true;
SCM_CopyToCase_poll cp = new SCM_CopyToCase_poll();
cp.istest = true;
string teststr = cp.complete;
cp.complete = 'test';
teststr = cp.issave;
cp.issave = 'test';
teststr = cp.folid;
cp.folid  = 'test';

try {
	s.save();
}
Catch (Exception ex) {
}
SCM_WebServices.SCMDocument SCMdoc = new SCM_WebServices.SCMDocument();
SCM_WebServices.SCMMetadata md = new SCM_WebServices.SCMMetadata();
List<SCM_WebServices.SCMMetadata> metadataList = new List<SCM_WebServices.SCMMetadata>();     
                //Prepare scmMetadata Object for Dcoument Type Meta Data
                md.GroupName = 'test';
                md.FieldName = 'test';
                md.Value = 'test'; // Get all documents
                md.DataType = 'string';
    
                // Add Meta data object to the list of meta data fields to search
                metadataList.add(md);
                
                md = new SCM_WebServices.SCMMetadata();
                
               md.GroupName = 'test';
                md.FieldName = 'test';
                md.Value = 'test'; // Get all documents
                md.DataType = 'string';
    
                // Add Meta data object to the list of meta data fields to search
                metadataList.add(md);
                
//test get metadat method
s.closewin = 'false';
s.DocumentString = 'Document,302012;';
s.getDoctypes();
s.DocumentString = 'Folder,302012;';
s.getDoctypes();
//string t = s.CheckFolder;
string t;
t = s.AssignTo;
//s.istest = false; 
//SCM_WebServices.ArrayOfSCMMetadata metadataWSArray = new SCM_WebServices.ArrayOfSCMMetadata(); 
//metadataWSArray.SCMMetadata = metadataList;    // Assign list of meta data values to the SCMMetadata array
//SCMDoc.Metadata = metadataWSArray;
//s.GetMetadata(SCMDoc,'test');

s.istest = true;
//s.SetMetadata(SCMDoc,'test','test');


}

}