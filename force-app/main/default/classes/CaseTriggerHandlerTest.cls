@IsTest
public with sharing class CaseTriggerHandlerTest {

    @TestSetup
    public static void setupTest() {
        Opportunity opportunity = new Opportunity();
        opportunity.Name = 'Opp test';
        opportunity.StageName = OpportunityUtilities.OPPORTUNITY_STAGE_NAME;
        opportunity.CloseDate = Date.newInstance(2022, 10, 15);
        Schedule__c schedule = new Schedule__c();
        schedule.Departure_date__c = Date.newInstance(2023, 10, 15);

        insert opportunity;
        insert schedule;

        Schedule_booking__c booking = new Schedule_booking__c();
        booking.Declared_Teu__c = 500;
        booking.Amount__c = 1250;
        booking.Opportunity__c = opportunity.Id;
        booking.Schedule__c = schedule.Id;
        insert booking;
    }

    @IsTest
    private static void shouldInitializeCaseDataOnInsert() {
        Case newCase = new Case();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_status_change_date__c, Last_Change_Org_Id__c, External_Id__c, Preferred_language__c, Status FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertNotEquals(null, caseAfterInsert.Last_status_change_date__c);
        System.assertEquals(Date.today(), caseAfterInsert.Last_status_change_date__c.date());
        System.assertEquals(CaseTriggerHelper.MY_LAST_CHANGE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
        System.assertNotEquals(null, caseAfterInsert.External_Id__c);
        System.assertNotEquals(null, caseAfterInsert.Preferred_language__c);
        System.assertNotEquals(null, caseAfterInsert.Status);
    }

    @isTest
    private static void shouldAssignBookingToCaseBeforeInsert() {

        Schedule_booking__c testBookingAfterInsert = [SELECT Id, Name FROM Schedule_booking__c LIMIT 1];
        Case newCase = new Case();
        newCase.Booking_number_from_webform__c = testBookingAfterInsert.Name;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseToCheck = [SELECT Id, Related_booking__c, Booking_number_from_webform__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(caseToCheck.Related_booking__c, testBookingAfterInsert.Id);
    }

    @isTest
    private static void shouldNotAssignBookingToCaseBeforeInsertNoValue() {
        Schedule_Booking__c scheduleBooking = [SELECT Id FROM Schedule_Booking__c];

        Case newCase = new Case();

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Related_booking__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(null, caseAfterInsert.Related_booking__c);
    }

    @IsTest
    private static void shouldNotAssignBookingToCaseBeforeInsertNoBooking() {

        Case newCase = new Case();
        newCase.Booking_number_from_webform__c = 'Not existing schedule Booking Id';

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Related_booking__c, Booking_number_from_webform__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(null, caseAfterInsert.Related_booking__c);
    }

    @IsTest private static void shouldAssignCorrectQueueToCaseAfterInsert() {

        Group queue;
        Group expectedQueue;
        for (Group queueRecord : [SELECT Id, DeveloperName FROM Group WHERE Type = :CaseTriggerHelper.GROUP_TYPE AND DeveloperName In (:CaseTriggerHelper.QUEUE_DEVELOPER_NAME_MAIN_QUEUE, :CaseTriggerHelper.QUEUE_DEVELOPER_NAME_ENGLISH)]) {
            if (queueRecord.DeveloperName == CaseTriggerHelper.QUEUE_DEVELOPER_NAME_MAIN_QUEUE) {
                queue = queueRecord;
            } else {
                expectedQueue = queueRecord;
            }
        }

        Case newCase = new Case();
        newCase.Preferred_Language__c = LanguageEnum.ENGLISH.name();
        newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        insert newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(expectedQueue.Id, caseAfterInsert.OwnerId);
    }

    @IsTest private static void shouldAssignCorrectQueueToCaseBeforeUpdateLanguageChange() {

        Group expectedQueue = [SELECT Id, DeveloperName FROM GROUP WHERE Type = :CaseTriggerHelper.GROUP_TYPE AND DeveloperName = :CaseTriggerHelper.QUEUE_DEVELOPER_NAME_GERMAN];
        Case newCase = new Case();
        newCase.Preferred_Language__c = LanguageEnum.ENGLISH.name();
        newCase.RecordTypeId = CaseUtilities.getRecordTypeIdByDevName(CaseUtilities.RT_INVOICE_REQUEST);
        Database.DMLOptions dmo = new Database.DMLOptions();
        dmo.assignmentRuleHeader.useDefaultRule = true;
        newCase.setOptions(dmo);
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Preferred_Language__c = LanguageEnum.GERMAN.name();
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, OwnerId, Preferred_Language__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(expectedQueue.id, caseAfterInsert.OwnerId);
    }

    @IsTest private static void shouldAssignSourceOrgToCaseBeforeUpdate() {

        Case newCase = new Case();
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Last_Change_Org_Id__c = CaseTriggerHelper.SOURCE_ORG_NAME_DENYS;
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(CaseTriggerHelper.SOURCE_ORG_NAME_DENYS, caseAfterInsert.Last_Change_Org_Id__c);
    }

    @IsTest private static void shouldUpdateSourceOrgWhenSensitiveDataChanged() {

        Case newCase = new Case();
        newCase.Last_Change_Org_Id__c = CaseTriggerHelper.SOURCE_ORG_NAME_DENYS;
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Subject = 'updated Subject';
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(CaseTriggerHelper.MY_LAST_CHANGE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
    }

    @IsTest private static void shouldUpdateTimesReopenedAndDateTimeOfLastChange() {
        Case newCase = new Case();
        newCase.Times_reopened__c = 1;
        newCase.Status = CaseTriggerHelper.statusIndicatingClosed;
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Status = CaseTriggerHelper.statusIndicatingNew;
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c, Times_reopened__c, Last_status_change_date__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(2, caseAfterInsert.Times_reopened__c);
        System.assertEquals(Date.today(), caseAfterInsert.Last_status_change_date__c.date());
    }

    @IsTest private static void shouldSetFirstCaseReopen(){
        Case newCase = new Case();
        newCase.Times_reopened__c = null;
        newCase.Status = CaseTriggerHelper.statusIndicatingClosed;
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Status = CaseTriggerHelper.statusIndicatingNew;
        update newCase;
        Test.stopTest();

        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c, Times_reopened__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertEquals(1, caseAfterInsert.Times_reopened__c);

    }

    @IsTest private static void shouldNotUpdateSourceOrgWhenSensitiveDataIsUnchanged() {

        Case newCase = new Case();
        newCase.Last_Change_Org_Id__c = CaseTriggerHelper.SOURCE_ORG_NAME_DENYS;
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        newCase.Booking_number_from_webform__c = 'not a valid number';
        update newCase;
        System.debug(newCase.Last_Change_Org_Id__c);
        Test.stopTest();
        Case caseAfterInsert = [SELECT Id, Last_Change_Org_Id__c FROM Case WHERE Id = :newCase.Id LIMIT 1];
        System.assertNotEquals(CaseTriggerHelper.MY_LAST_CHANGE_ORG_NAME, caseAfterInsert.Last_Change_Org_Id__c);
    }

    @IsTest private static void shouldSendDeleteRequestOnDelete() {

        Case newCase = new Case();
        insert newCase;

        Test.setMock(HttpCalloutMock.class, new HTTPMockFactory());
        Test.startTest();
        delete newCase;
        Test.stopTest();

        Case caseAfterDelete = [SELECT Id, External_Id__c, IsDeleted FROM Case WHERE Id = :newCase.Id ALL ROWS];
        System.assertEquals(true, caseAfterDelete.IsDeleted);
    }


}