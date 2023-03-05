/**
 * Created by Edis Hulpea March 2023.
 */
@IsTest
global with sharing class MockUnsuccessfulHttpResponse implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request) {
        HttpResponse response = new HttpResponse();
        response.setStatusCode(400);
        response.setHeader('Content-type', 'application/json');
        return response;
    }
}