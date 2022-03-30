/**
 * Created by POTERFI on 3/30/2022.
 */

@IsTest
private class UCPCaseDeleteCalloutQueueableTest {

    @TestSetup
    static void testSetup(){
        Case testCase = new Case();
        testCase.External_Id__c = '12345';
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        insert testCase;
    }

    @IsTest
    static void shouldAssignJobId() {
        Case testCase = [SELECT Id, External_Id__c FROM Case];
        Set<String> externalIds = new Set<String>{testCase.External_Id__c};
        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Id jobId = System.enqueueJob(new UCPCaseDeleteCalloutQueueable(externalIds));
        Test.stopTest();
        System.assertNotEquals(null, jobId);
    }
}