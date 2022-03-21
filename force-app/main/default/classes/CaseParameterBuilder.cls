public with sharing class CaseParameterBuilder {

    public static String constructParameterForEndpoint (List<String> extIds){
        String externalIdField = '?external_id=';
        for (String externalId : extIds) {
            externalIdField += externalId + ',';
            }
        externalIdField.removeEnd(',');
        return externalIdField;
    }
}