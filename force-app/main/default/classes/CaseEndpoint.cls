/**
 * Created by POTERFI on 3/16/2022.
 */

@RestResource(urlMapping='/case/*')
global with sharing class CaseEndpoint {
    private static final String PARAM_EXTERNAL_ID = 'external_id';
    private static final String EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED = 'Wrong parameter provided';
    private static final String EXCEPTION_MESSAGE_CASE_NOT_FOUND = 'Case with given id not found';

    @HttpPost
    global static void upsertCases() {
        System.debug('Test receiving');
        String requestBody = RestContext.request.requestBody.toString();
        System.debug(requestBody);
        List<CaseWrapper> casesToUpdate = (List<CaseWrapper>) JSON.deserialize(requestBody, List<CaseWrapper>.class);
        List<Case> casesToUpdateFormatted = new List<Case>();
        for (CaseWrapper receivedCase : casesToUpdate) {
            Case newCase = new Case();
            newCase.Preferred_Language__c = receivedCase.Preferred_Language;
            newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(receivedCase.record_type);
            newCase.Priority = receivedCase.Priority;
            newCase.Subject = receivedCase.Subject;
            newCase.Description = receivedCase.Description;
            newCase.Comments = receivedCase.Comments;
            newCase.SuppliedEmail = receivedCase.SuppliedEmail;
            newCase.SuppliedPhone = receivedCase.SuppliedPhone;
            newCase.SuppliedName = receivedCase.SuppliedName;
            newCase.External_Id__c = receivedCase.external_id;
            newCase.Last_Change_Org_Id__c = receivedCase.last_change_source_org;
            casesToUpdateFormatted.add(newCase);
        }
        upsert casesToUpdateFormatted Case.External_Id__c;
    }

    @HttpDelete
    global static void deleteCases() {
        String requestParam = RestContext.request.params.get(PARAM_EXTERNAL_ID);
        List<String> parameterValues = requestParam.split(',');
        List<Case> caseToDeleteByExtId = [SELECT Id FROM Case WHERE External_Id__c In :parameterValues];
        if ( String.isEmpty(requestParam) ) {
            RestContext.response.responseBody = Blob.valueOf(EXCEPTION_MESSAGE_WRONG_PARAMETER_PROVIDED);
            RestContext.response.statusCode = 400;
            return ;
        } else if (caseToDeleteByExtId.isEmpty()) {
            RestContext.response.responseBody = Blob.valueOf(EXCEPTION_MESSAGE_CASE_NOT_FOUND);
            RestContext.response.statusCode = 400;
        } else {
            delete caseToDeleteByExtId;
        }
    }
}