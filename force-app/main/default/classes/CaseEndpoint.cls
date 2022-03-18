/**
 * Created by POTERFI on 3/16/2022.
 */

@RestResource(urlMapping='/case')
global with sharing class CaseEndpoint {

    @HttpPost
    global static void upsertCases() {
        String requestBody = RestContext.request.requestBody.toString();
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
            casesToUpdateFormatted.add(newCase);
        }
        upsert casesToUpdateFormatted Case.External_Id__c;
    }

    @HttpDelete
    global static void deleteCases() {
        String requestBody = RestContext.request.requestBody.toString();
        List<CaseWrapper> casesToDelete = (List<CaseWrapper>) JSON.deserialize(requestBody, List<CaseWrapper>.class);
        List<String> IdsOfCasesToDelete = new List<String>();
        for (CaseWrapper receivedCase : casesToDelete){
            IdsOfCasesToDelete.add(receivedCase.external_id);
        }
        List<Case> casesToDeleteByExtId = [SELECT Id FROM Case WHERE External_Id__c IN: IdsOfCasesToDelete ];
        delete casesToDeleteByExtId;
    }
}