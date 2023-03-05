/**
 * Created by Edis Hulpea March 2023.
 */
@IsTest
global class MockPositiveHttpResponse implements HttpCalloutMock{
    global HttpResponse respond(HttpRequest request){
        HttpResponse response = new HttpResponse();
        response.setStatusCode(200);
        response.setBody('{"message":"test"}');
        response.setHeader('Content-type','application/json');
        return response;
    }
}