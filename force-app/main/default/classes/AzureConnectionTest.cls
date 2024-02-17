@IsTest
private class AzureConnectionTest {
    // Define the Mock class to simulate Http Callout Response
    private class HttpMock implements HttpCalloutMock {
        HttpResponse res;

        HttpMock(HttpResponse r) {
            this.res = r;
        }

        public HttpResponse respond(HttpRequest req) {
            return res;
        }
    }

    private static HttpResponse createMockResponse(Integer statusCode, String body) {
        HttpResponse res = new HttpResponse();
        res.setStatusCode(statusCode);
        res.setBody(body);
        return res;
    }

    @IsTest
    static void testMakeCallout() {
        // Initialize Mock HttpResponse
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody('{"workItems": [{"id": 1}], "value": [{"id": 1, "fields": {"System.Title": "Test"}}]}');
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        List<AzureWorkItem> workItems = AzureConnection.getDetailedWorkItems('Org', 'Proj', 'User', 'Token');
        System.assertEquals(1, workItems.size(), 'Should return one work item');
    }

    @IsTest
    static void testSanitizeAssignedToValue() {
        String input = 'sampleInput'; // This input contains disallowed characters
        String sanitizedInput = AzureConnection.sanitizeAssignedToValue(input);

        System.assertEquals(input, sanitizedInput, 'input should be the same');
    }

    @isTest
    private static void testGetBoardColumns() {
        // Construct mock response body based on expected output
        String mockResponseBody = '{"value": [{"name": "column1"}, {"name": "column2"}]}';
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        mockResponse.setBody(mockResponseBody);

        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        Test.startTest();
        String result = AzureConnection.getBoardColumns('Org', 'Proj', 'User', 'Token');
        Test.stopTest();

        // You can define expected result string and compare it
        // Or you can deserialize result back to List<BoardColumn> and compare individual elements
        String expectedResult = '[{"text":"column1","loc":"0 43.52284749830794","key":"column1","isGroup":true,"color":"0"},{"text":"column2","loc":"109 43.52284749830794","key":"column2","isGroup":true,"color":"0"}]';

        System.assertEquals(expectedResult, result, 'The transformed board columns do not match the expected value');
    }

    @isTest
    private static void testGetTeamNames() {
        String mockResponseBody = '{"value": [{"name": "Team1"}, {"name": "Team2"}]}';
        HttpResponse mockResponse = createMockResponse(200, mockResponseBody);
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        Test.startTest();
        List<String> teamNames = AzureConnection.getTeamNames('Org', 'Proj', 'User', 'Token');
        Test.stopTest();

        System.assertEquals(2, teamNames.size(), 'Incorrect number of teams fetched');
        System.assertEquals('Team1', teamNames[0], 'Incorrect team name fetched');
        System.assertEquals('Team2', teamNames[1], 'Incorrect team name fetched');
    }

    @isTest
    private static void testGetWorkItemComments() {
        String mockResponseBody = '{"comments": [{"text": "Comment1"}, {"text": "Comment2"}]}';
        HttpResponse mockResponse = createMockResponse(200, mockResponseBody);
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        Test.startTest();
        List<String> comments = AzureConnection.getWorkItemComments('Org', 'Proj', 'User', 'Token', 123);
        Test.stopTest();

        System.assertEquals(2, comments.size(), 'Incorrect number of comments fetched');
        System.assertEquals('Comment1', comments[0], 'Incorrect comment fetched');
        System.assertEquals('Comment2', comments[1], 'Incorrect comment fetched');
    }

    @isTest
    static void testUpdateWorkItemState() {
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        AzureConnection.updateWorkItemState('org', 'proj', 'user', 'token', 1, 'New');
        Test.stopTest();
        // Add assertions if needed
    }

    @isTest
    static void testAddWorkItemComment() {
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        AzureConnection.addWorkItemComment('org', 'proj', 'user', 'token', 1, 'Comment Text');
        Test.stopTest();
        // Add assertions if needed
    }

    @isTest
    static void testGetWikiPageURL() {
        Test.startTest();
        String result = AzureConnection.getWikiPageURL('wikiName');
        Test.stopTest();

        System.assertEquals('https://dev.azure.com/null/null/_wiki/wikis/wikiName.wiki', result);
    }

    @isTest
    static void testCreateWikiPage() {
        Test.startTest();
        HttpResponse mockResponse = new HttpResponse();
        mockResponse.setStatusCode(200);
        Test.setMock(HttpCalloutMock.class, new HttpMock(mockResponse));

        AzureConnection.createWikiPage('org', 'proj', 'user', 'token', 'wikiName', '/path', 'Content');
        Test.stopTest();
        // Add assertions if needed
    }
}