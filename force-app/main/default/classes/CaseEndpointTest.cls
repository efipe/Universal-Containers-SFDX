/**
 * Created by POTERFI on 3/29/2022.
 */

@IsTest
private class CaseEndpointTest {

    @TestSetup
    public static void setupTest() {

    }

    @IsTest
    static void shouldUpsertCases() {
        Case newCase = new Case();
        newCase.External_Id__c = '12345';
        insert newCase;

        Case insertedCase = [SELECT Id, Subject, External_Id__c, Preferred_language__c, RecordType.DeveloperName, Status, Priority, Origin, Description, Comments, SuppliedName, SuppliedPhone, SuppliedEmail, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];

        CaseWrapper wrappedCase = new CaseWrapper(insertedCase);

        RestRequest request = new RestRequest();
        insertedCase.Subject = 'updated';
        String serializedCase = JSON.serialize(new List<CaseWrapper>{wrappedCase});
        request.requestBody = Blob.valueOf(serializedCase);
        RestContext.request = request;
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.upsertCases();
        Test.stopTest();

        Case upsertedCase = [SELECT Id FROM Case WHERE Id = :insertedCase.Id LIMIT 1];
        System.assertNotEquals(insertedCase, upsertedCase);
    }


    @IsTest
    static void shouldDeleteCases() {
        Case newCase = new Case();
        newCase.External_Id__c = '12345';
        insert newCase;

        RestRequest request = new RestRequest();
        request.addParameter('external_id', '12345');
        RestContext.request = request;

        RestResponse expectedResponse = new RestResponse();
        expectedResponse.statusCode = 200;
        RestContext.response = expectedResponse;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        CaseEndpoint.deleteCases();
        Test.stopTest();

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :newCase.Id ALL ROWS];
        System.assertEquals(200, RestContext.response.statusCode);
        System.assertEquals(true, caseAfterDelete.IsDeleted);
    }


}