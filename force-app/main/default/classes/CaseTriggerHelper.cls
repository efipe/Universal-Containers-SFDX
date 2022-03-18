public with sharing class CaseTriggerHelper {

    public void getQueueForCase (List<Case> newCases, List<Case> oldCases){
        for (Case newCase : newCases){
            if (newCase.OwnerId.getSobjectType() != User.getSObjectType()){
                Id queueLanguageId = CaseRoutingService.getInstance().getQueueForCase(newCase);
                if(queueLanguageId != null){
                    newCase.OwnerId = queueLanguageId;
                    if(newCase.External_Id__c == null){
                        newCase.External_Id__c = GuidGenerator.generate();
                    }
                }
            }
        }
    }

    public void getDefaultQueue (List<Case> newCases, List<Case> oldCases){
        for (Case newCase : newCases) {
            for (Case oldCase : oldCases) {
                if (oldCase.Preferred_language__c != newCase.Preferred_language__c){
                    System.debug(newCase.OwnerId);
                    newCase.OwnerId = CaseRoutingService.getInstance().getDefaultQueue(oldCase.OwnerId, LanguageEnum.valueOf(oldCase.Preferred_language__c));
                    System.debug(newCase.OwnerId);
                }
            }
        }
    }

    public void incrementTimesOpenedField (List<Case> newCases, List<Case> oldCases){
        for (Case newCase : newCases) {
            for (Case oldCase : oldCases) {
                if (oldCase.Status == 'Closed' && oldCase.Status != newCase.Status) {
                    if (newCase.Times_reopened__c != null) {
                        newCase.Times_reopened__c += 1;                                    
                    } else {
                        newCase.Times_reopened__c = 1;
                    }
                }
            }
        }
    }

    public void setDateTimeOfLastStatusChange (List<Case> newCases, List<Case> oldCases){
        for(Case newCase : newCases){
            for (Case oldCase : oldCases) {
                if (oldCase.Status != newCase.Status) {
                    newCase.Last_status_change_date__c = Datetime.now();
                }
            }
        }
    }

    public void setDateTimeOfLastStatusChange (List<Case> newCases){
        for(Case newCase : newCases){
                    newCase.Last_status_change_date__c = Datetime.now();
            }
    }

    public void calculatePreviousCloseTimes (List<Case> newCases, List<Case> oldCases){
        String statusIndicatingClosed = 'Closed';
        for(Case newCase : newCases){
            for(Case oldCase: oldCases){
                if (oldCase.Status == statusIndicatingClosed && newCase.Status != statusIndicatingClosed) {
                    newCase.previous_closed_total_time__c = newCase.previous_closed_total_time__c += oldCase.Recent_close_time__c;
                }
            }
        }
    }

    public void assignRelatedBooking ( List<Case> newCases ){
        List<String> bookingNumber = new List<String>();
        Map<String, Id> bookingsNamesAndIds = new Map<String, Id>();
        List<Schedule_booking__c> bookings;
        for (Case newCase : newCases) {
            bookingNumber.add(newCase.Booking_number_from_webform__c);
        }
        bookings = new List<Schedule_booking__c>([SELECT Booking_name__c, Id FROM Schedule_booking__c WHERE Booking_name__c in: bookingNumber]);
        for (Schedule_booking__c booking : bookings) {
            bookingsNamesAndIds.put(booking.Booking_name__c, booking.Id);
        }
        for (Case newCase : newCases) {
            newCase.Related_booking__c = bookingsNamesAndIds.get(newCase.Booking_number_from_webform__c);
        }
    }

}