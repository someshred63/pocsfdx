public with sharing class GNE_SFA2_XMLParser {

    public static String getValueForXMLElement(String label, HttpResponse res) {
        String result = null;

        if (res.getStatus() == 'OK') {
            System.debug('##### XML Body === ' + res.getBodyDocument());
            dom.Document doc = res.getBodyDocument();
            if (doc != null) {
                dom.XMLNode root = doc.getRootElement();

                result = findValueInXML(label, root);
            }
        }

        return result;
    }

    public static List<dom.XMLNode> getListOfIncidents(Set<String> labels, HttpResponse res){
        List<dom.XMLNode> result = null;

        if (res.getStatus() == 'OK') {
            dom.Document doc = res.getBodyDocument();
            if (doc != null) {
                dom.XMLNode root = doc.getRootElement();
                dom.XMLNode incidentListRoot = findIncidentListInXML('incidentList', root);
                system.debug('incidentListRoot: ' + incidentListRoot);
                if(incidentListRoot != null){
                    result = incidentListRoot.getChildElements();
                }
            }
        }

        return result;
    }

    public static dom.XMLNode findIncidentListInXML(String label, dom.XMLNode xmlNode){
        if (xmlNode != null) {
            if(xmlNode.getName() == label){
                return xmlNode;
            }
            if (xmlNode.getChildElements().isEmpty()) {
                if (xmlNode.getName() == label) {
                    return xmlNode;
                } else {
                    return null;
                }
            } else {
                for (dom.XMLNode child : xmlNode.getChildElements()) {
                    if (child.getName() == label) {
                        return child;
                    } else {
                        for (dom.XMLNode grandChild : child.getChildElements()) {
                            if (findIncidentListInXML(label, grandchild) != null) {
                                return findIncidentListInXML(label, grandchild);
                            }
                        }
                    }
                }
            }
        }

        return null;
    }

    public static List<Map<String, String>> getValuesForListOfXMLElements(Set<String> labels, HttpResponse res){
        List<dom.XMLNode> incidents = getListOfIncidents(labels, res);
        system.debug(incidents);
        String responseStatus = res.getStatus();
        List<Map<String, String>> result = new List<Map<String, String>>();
        if(incidents != null){
            if(!labels.isEmpty()){
                for(dom.XMLNode incidentNode :incidents){
                    Map<String, String> incident = new Map<String, String>();
                    for(String label :labels){
                        incident.put(label, findValueInXML(label, incidentNode));
                    }
                    incident.put('responseStatus', responseStatus);
                    result.add(incident);
                }
            }
        } else {
            result.add(getValuesForXMLElements(new Set<String>{'adapterTrackingId', 'errorCode', 'description'}, res));
        }
        return result;
    }

    public static Map<String, String> getValuesForXMLElements(Set<String> labels, HttpResponse res) {
        Map<String, String> result = new Map<String, String>();
        if(!labels.isEmpty()) {
            for(String label : labels) {
                result.put(label, getValueForXMLElement(label, res));
            }
        } 
        return result;
    }

    private static String findValueInXML(String label, dom.XMLNode xmlNode) {
        if (xmlNode != null) {
            if (xmlNode.getChildElements().isEmpty()) {
                if (xmlNode.getName() == label) {
                    return xmlNode.getText();
                } else {
                    return null;
                }
            } else {
                for (dom.XMLNode child : xmlNode.getChildElements()) {
                    if (child.getName() == label) {
                        return child.getText();
                    } else {
                        for (dom.XMLNode grandChild : child.getChildElements()) {
                            if (findValueInXML(label, grandchild) != null) {
                                return findValueInXML(label, grandchild);
                            }
                        }
                    }
                }
            }
        }

        return null;
    }

    public static String getAttributeValueForXMLElement(String label, String attribute, HttpResponse res) {
        String result = null;

        if (res.getStatus() == 'OK') {
            dom.Document doc = res.getBodyDocument();
            if (doc != null) {
                dom.XMLNode root = doc.getRootElement();
                result = findAttributeInXML(label, attribute, root);
            }
        }

        return result;
    }

    private static String findAttributeInXML(String label, String attribute, dom.XMLNode xmlNode) {
        if (xmlNode != null) {
            if (xmlNode.getChildElements().isEmpty()) {
                if (xmlNode.getName() == label) {
                    return xmlNode.getAttribute(attribute, null);
                } else {
                    return null;
                }
            } else {
                for (dom.XMLNode child : xmlNode.getChildElements()) {
                    if (child.getName() == label) {
                        return child.getAttribute(attribute, null);
                    } else {
                        for (dom.XMLNode grandChild : child.getChildElements()) {
                            if (findAttributeInXML(label, attribute, grandchild) != '') {
                                return findAttributeInXML(label, attribute, grandchild);
                            }
                        }
                    }
                }
            }
        }

        return null;
    }

    public static dom.XMLNode getChildsForMatchingLabelAndAttribute(String label, String attribute, String attValue, dom.XMLNode xmlNode) {

        if (xmlNode != null && xmlNode.getName() == label && xmlNode.getAttribute(attribute, null) == attValue) {
            return xmlNode;
        } else {
            for (dom.XMLNode child : xmlNode.getChildElements()) {
                if (getChildsForMatchingLabelAndAttribute(label, attribute, attValue, child) != null) {
                    return getChildsForMatchingLabelAndAttribute(label, attribute, attValue, child);
                }
            }
        }

        return null;
    }

    public static String findExactValueInXML(String parentLabel, String parentAttribute, String parentAttValue, String childLabel, dom.XMLNode xmlNode) {
        return findValueInXML(childLabel, getChildsForMatchingLabelAndAttribute(parentLabel, parentAttribute, parentAttValue, xmlNode));
    }

    public static String findExactValueInResponse(String parentLabel, String parentAttribute, String parentAttValue, String childLabel, HttpResponse res) {
        if (res != null) {
            dom.Document doc = res.getBodyDocument();
            dom.XMLNode xmlNode = doc.getRootElement();
            return findValueInXML(childLabel, getChildsForMatchingLabelAndAttribute(parentLabel, parentAttribute, parentAttValue, xmlNode));
        } else {
            return null;
        }
    }

}