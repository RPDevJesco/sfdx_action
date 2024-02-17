/**
 * Created by Jesse Glover on 7/21/2023.
 */

public with sharing class UTIL_TimeCalculation {
    /**
     * @param caseList Cases to have the calculation run on.
     * @return the days between the start and end date excluding weekends and holidays.
     * this can be used on a formula field to return the days or hours between stated days
     * in a positive or negative direction.
     */
    public static Integer getWorkingDays(List<Case> caseList) {
        List<Holiday> holidayList = [SELECT Id, RecurrenceStartDate FROM Holiday];
        Integer daysBetween = 0;
        for (Case caseRecord : caseList) {
            Boolean isClosed = caseRecord.IsClosed;
            Datetime closedDate = caseRecord.ClosedDate;
            Datetime createdDate = caseRecord.CreatedDate;
            Date today = Date.today();

            Date startDate = Date.valueOf(createdDate);
            Date endDate = isClosed ? Date.valueOf(closedDate) : today;

            Integer numHolidays = subtractHolidays(startDate, endDate, holidayList);
            Integer workingDays = calculateWorkingDays(startDate, endDate) - numHolidays;

            if (createdDate > today) {
                daysBetween = workingDays != null ? workingDays * -1 : null;
            } else {
                daysBetween = workingDays != null ? workingDays : null;
            }
        }
        return daysBetween;
    }

    /**
     * @param startDate Beginning date
     * @param endDate ending date
     * @param holidayList Holiday List from the Holiday Object stored in Settings.
     *
     * @return Number of holidays that match the criteria.
     */
    public static Integer subtractHolidays(Date startDate, Date endDate, List<Holiday> holidayList) {
        Integer holidayCount = 0;
        for (Holiday holiday : holidayList) {
            Date holidayDate = Date.valueOf(holiday.RecurrenceStartDate);
            // Extract the month and day values from the holidayDate and created/closed dates
            Integer holidayMonth = holidayDate.month();
            Integer holidayDay = holidayDate.day();
            Integer createdMonth = startDate.month();
            Integer createdDay = startDate.day();
            Integer closedMonth = endDate.month();
            Integer closedDay = endDate.day();

            // Compare the month and day values to determine if the holiday falls within the range
            if ((holidayMonth > createdMonth || (holidayMonth == createdMonth && holidayDay >= createdDay)) &&
                    (holidayMonth < closedMonth || (holidayMonth == closedMonth && holidayDay <= closedDay))) {
                holidayCount++;
            }
        }
        return holidayCount;
    }

    /**
     * @param startDate Beginning date
     * @param endDate ending date
     *
     * @return the number of days between the start and end date that don't land on a Saturday or Sunday.
     */
    public static Integer calculateWorkingDays(Date startDate, Date endDate) {
        Integer workingDays = 0;
        Integer direction = startDate.daysBetween(endDate) > 0 ? 1 : -1;
        Integer days = Math.abs(startDate.daysBetween(endDate));

        for (Integer i = 0; i <= days; i++) {
            Datetime currentDateTime = Datetime.newInstance(
                    startDate.year(),
                    startDate.month(),
                    startDate.day(),
                    0,
                    0,
                    0
            ).addDays(i * direction);

            String dayOfWeek = currentDateTime.format('EEEE');

            if (!dayOfWeek.equalsIgnoreCase('Saturday') && !dayOfWeek.equalsIgnoreCase('Sunday')) workingDays++;
        }

        return workingDays;
    }
}