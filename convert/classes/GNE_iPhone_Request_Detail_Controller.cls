public class GNE_iPhone_Request_Detail_Controller {

    class Node {
        final String name;
        final String value;
        
        public Node(String nodeName, String nodeValue) {
            this.name = nodeName;
            this.value = nodeValue;
        }
        
        public String getName() {
            return this.name;
        }
        
        public String getValue() {
            return this.value;
        }
    }

    public LIST<GNE_iPhone_Failed_Request__c> failedRequests = null;
    public GNE_iPhone_Failed_Request__c failedRequest = null;
    public LIST<Node> nodes = null;
    
    private LIST<Node> allNodes = null;
    
    public GNE_iPhone_Request_Detail_Controller(ApexPages.StandardController ctrl) {
        ID ifrid = ApexPages.currentPage().getParameters().get('id');
        
        try {
            failedRequests = 
            [ select Id, OwnerId, IsDeleted, Name, CreatedDate, CreatedById, LastModifiedDate, LastModifiedById, SystemModstamp, MayEdit, IsLocked, Request_gne__c, Response_gne__c, Request_Type_gne__c, Request_Signature_gne__c, iPhone_Request_Id_gne__c, Status_gne__c, Comments_gne__c, Region_Code_gne__c from GNE_iPhone_Failed_Request__c
                        where  Id = :ifrid ];
                        
        } catch (Exception ex) {
            ApexPages.addMessages(ex);
        }
    }
    
    public GNE_iPhone_Request_Detail_Controller() {
    }
    
    public List<GNE_iPhone_Failed_Request__c> getFailedRequests() {
        return failedRequests;
    }
    
    public GNE_iPhone_Failed_Request__c getFailedRequest() {
        return failedRequests[0];
    }
    
    public LIST<Node> getNodes() {
        if (this.allNodes == null) {
            GNE_iPhone_Failed_Request__c fr = this.getFailedRequest();
            this.parse(fr.Request_gne__c);
        }
        
        return this.allNodes;
    }

    private String parse(String toParse) {
        DOM.Document doc = new DOM.Document();
        try {
            doc.load(toParse);
            DOM.XMLNode root = doc.getRootElement();
            
            walkThrough(root);
            return '';
        } catch (System.XMLException e) {  // invalid XML
        
            this.allNodes = new LIST<Node>();
            Node tmpNode = new Node('', e.getMessage());
            this.allNodes.add(tmpNode);
            
            return e.getMessage();
        }
    }

    private void walkThrough(DOM.XMLNode node) {
        String result = '';
        
        Node tmpNode = null;
        if (this.allNodes == null)
        {
            this.allNodes = new LIST<Node>();
        }
        
        if (node.getNodeType() == DOM.XMLNodeType.ELEMENT) {
            result += 'Element: ' + node.getName();
            if (node.getText().trim() != '') {
                result += ', text=' + node.getText().trim();
            }
            tmpNode = new Node(node.getName(), node.getText());
            this.allNodes.add(tmpNode);
            
            for (Dom.XMLNode child: node.getChildElements()) {
                walkThrough(child/*, tmpNode*/);
            }
        }
    }
}