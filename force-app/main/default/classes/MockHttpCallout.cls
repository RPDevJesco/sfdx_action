/**
 * Created by Jesse Glover on 7/25/2023.
 */

public with sharing class MockHttpCallout implements HttpCalloutMock {
    // Map to store the HTTP response for each request URL
    private Map<String, HttpResponse> responseMap;

    /**
     * Constructor to initialize the response map.
     */
    public MockHttpCallout() {
        responseMap = new Map<String, HttpResponse>();
    }

    /**
     * Add a mock HTTP response for a specific request URL.
     * @param url The request URL for which to add the mock response.
     * @param response The mock HTTP response.
     */
    public void addHttpResponse(String url, HttpResponse response) {
        responseMap.put(url, response);
    }

    /**
     * This method is the implementation of the HttpCalloutMock interface.
     * It returns the mocked HTTP response for the given request.
     * @param request The HTTP request being sent.
     * @return The mocked HTTP response.
     */
    public HttpResponse respond(HttpRequest request) {
        String requestUrl = request.getEndpoint();
        HttpResponse mockedResponse = responseMap.get(requestUrl);

        if (mockedResponse != null) {
            return mockedResponse;
        } else {
            // If no specific mock response is found, return a default response.
            HttpResponse defaultResponse = new HttpResponse();
            defaultResponse.setHeader('Content-Type', 'application/json');
            defaultResponse.setBody('{"message": "Mock response not found."}');
            defaultResponse.setStatusCode(404);
            return defaultResponse;
        }
    }
}