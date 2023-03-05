/**
 * Created by Edis Hulpea March 2023.
 */

public with sharing class WeatherService {
    static final Integer REQUEST_NULL = 1;
    static final Integer ID_NULL = 2;
    static final Integer INVALID_ID = 3;
    static final Integer FAILED_DML = 4;
    static final Integer DEFAULT_LATITUDE = 0;
    static final Integer DEFAULT_LONGITUDE = 0 ;

    static final String GET_METHOD = 'GET';
    static String ENDPOINT = 'callout:weather_forecast';

    private static final Date tomorrow = Date.today().addDays(1);
    private static final Datetime tomorrowDatetime = Datetime.newInstance(tomorrow.year(), tomorrow.month(), tomorrow.day());
    private static final String tomorrowFormated = tomorrowDatetime.format('yyyy-MM-dd');

    private static Account account = new Account();
    private static List<Error> errors = new  List<Error>();

    @AuraEnabled
    public static Response getWeatherForecast(Request request) {
        System.debug('!!!equest' + request);
        Response response = new Response();
        errors = validateRequest(request);
        System.debug('!!!errors' + errors);
        if (!errors.isEmpty()) {
            response.errors = errors;
            response.isSuccess = false;
            return response;
        }
        //Adding query parameters to the endpoint
        Decimal latitude;
        if(request.latitude != null) {
            latitude = request.latitude;
        } else if (account.BillingLatitude != null){
            latitude = account.BillingLatitude;
        } else {
            latitude = DEFAULT_LATITUDE;
        }

        Decimal longitude;
        if(request.longitude != null) {
            longitude = request.longitude;
        } else if (account.BillingLatitude != null){
            longitude = account.BillingLongitude;
        } else {
            longitude = DEFAULT_LONGITUDE;
        }

        ENDPOINT += '?latitude=' +latitude;
        ENDPOINT += '&longitude=' +longitude;
        ENDPOINT += '&start_date=' + tomorrowFormated + '&end_date=' + tomorrowFormated;
        ENDPOINT += '&hourly=temperature_2m,relativehumidity_2m,windspeed_10m';

        if (request.timezone != null) {
            ENDPOINT += '&timezone=' + String.escapeSingleQuotes(request.timezone);
        }

        //Make the HTTP request
        response = doCallout();
        updateAccount(request.recordId,response.data);
        if(errors.size() > 0){
            response.isSuccess = false;
            response.errors = errors;
            response.data = '';
        }
        System.debug('2@@@@response' + response);
        return response;
    }

    //Checking mandatory parameters
    private static List<Error> validateRequest(Request request) {
        List<Error> errors = new List<Error>();
        if (request == null) {
            errors.add(invalidRequestWithMessage('Request is null', REQUEST_NULL));
            return errors;
        }
        if (request.recordId == null) {
            errors.add(invalidRequestWithMessage('Id is mandatory', ID_NULL));
        } else {
            List<Account> accounts = [SELECT Id, Name, BillingLongitude, BillingLatitude FROM Account WHERE Id = :request.recordId];
            if (accounts.size() == 1) {
                account = accounts[0];
            } else {
                errors.add(invalidRequestWithMessage('Invalid account', INVALID_ID));
            }
        }
        return errors;
    }

    private static Response doCallout() {
        HttpRequest request = new HttpRequest();
        Response mappedResponse = new Response();
        request.setEndpoint(ENDPOINT);
        request.setMethod(GET_METHOD);
        request.setHeader('Content-Type', 'application/json');

        Http http = new Http();
        HTTPResponse httpResponse = new HttpResponse();
        httpResponse = http.send(request);

        if (httpResponse.getStatusCode() == 200) {
            mappedResponse.data = httpResponse.getBody();
            mappedResponse.statusCode = httpResponse.getStatusCode();
            mappedResponse.isSuccess = true;

        } else {
            mappedResponse.statusCode = httpResponse.getStatusCode();
            mappedResponse.isSuccess = false;
        }
        return mappedResponse;
    }

    private static Error invalidRequestWithMessage(String message, Integer code) {
        Error error = new Error();
        error.message = message;
        error.code = code;
        return error;
    }

    @Future
    private static void updateAccount( Id accId, String weatherForecast){
        System.debug('weatherForecast'+weatherForecast);
        List<Account> accountsToUpdate = new List<Account>();
        Account acc = new Account();
        acc.Id = accId;
        acc.Weather_forecast__c = weatherForecast;
        accountsToUpdate.add(acc);
        try {
            Database.update(accountsToUpdate);
        } catch(DmlException e) {
            errors.add(invalidRequestWithMessage(e.getMessage(), FAILED_DML));
        }
    }

    public class Request {
        @AuraEnabled
        public Integer latitude { get; set; }
        @AuraEnabled
        public Integer longitude { get; set; }
        @AuraEnabled
        public String timezone { get; set; }
        @AuraEnabled
        public Id recordId { get; set; }
    }

    public class Response {
        @AuraEnabled
        public String data;
        @AuraEnabled
        public Integer statusCode;
        @AuraEnabled
        public Boolean isSuccess;
        @AuraEnabled
        public List<Error> errors = new List<Error>();
    }

    public class Error {
        public String message;
        public Integer code;
    }
}