/**
 * Created by Edis Hulpea March 2023.
 */
@IsTest
public with sharing class WeatherService_TEST {
    @IsTest
    static void shouldDoCalloutSuccessfully(){
        Account acc= new Account();
        acc.Name = 'Test';
        acc.BillingLongitude = 50;
        acc.BillingLatitude = 60;
        insert acc;

        WeatherService.Request request = new WeatherService.Request();
        request.recordId= acc.Id;
        request.timezone = 'Europe/Bucharest';


        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockPositiveHttpResponse());
        Test.stopTest();
        WeatherService.Response result = WeatherService.getWeatherForecast(request);

        System.assertEquals(200, result.statusCode);
        System.assertEquals('{"message":"test"}', result.data);
    }

    @IsTest
    static void shouldReturnParameterErrors(){
        WeatherService.Request request = new WeatherService.Request();
        WeatherService.Response result = WeatherService.getWeatherForecast(request);

        System.assertEquals(1, result.errors.size());
        System.assertEquals(false, result.isSuccess);
    }

    @IsTest
    static void shouldReturnNullRequest(){
        WeatherService.Request request ;
        WeatherService.Response result = WeatherService.getWeatherForecast(request);

        System.assertEquals(1, result.errors[0].code);
        System.assertEquals(false, result.isSuccess);

    }
    @IsTest
    static void shouldDoCalloutWithUnsuccessfulResponse(){
        Account acc= new Account();
        acc.Name = 'Test';
        acc.BillingLongitude = 50;
        acc.BillingLatitude = 60;
        insert acc;

        WeatherService.Request request = new WeatherService.Request();
        request.recordId= acc.Id;
        request.timezone = 'Europe/Bucharest';

        Test.startTest();
        Test.setMock(HttpCalloutMock.class, new MockUnsuccessfulHttpResponse());
        Test.stopTest();

        WeatherService.Response result = WeatherService.getWeatherForecast(request);
        System.assertEquals(400, result.statusCode);
    }

    @IsTest
    static void shouldFailWithInvalidId(){
        Account acc= new Account();
        acc.Name = 'Test';
        acc.BillingLongitude = 50;
        acc.BillingLatitude = 60;
        insert acc;

        WeatherService.Request request = new WeatherService.Request();
        request.recordId= Id.valueOf('001000000000000AAA');
        request.timezone = 'Europe/Bucharest';

        WeatherService.Response result = WeatherService.getWeatherForecast(request);
        System.assertEquals(3, result.errors[0].code);
    }

    @IsTest
    static void shouldFailWithDmlException(){
        Account acc= new Account();
        acc.Name = 'Test';
        acc.BillingLongitude = 50;
        acc.BillingLatitude = 60;
        insert acc;

        WeatherService.Request request = new WeatherService.Request();
        request.recordId= acc.Id;
        request.timezone = 'Europe/Bucharest';
        acc.Name = '';


        Test.startTest();
//        Test.setMock(HttpCalloutMock.class, new MockPositiveHttpResponse());
        WeatherService.updateAccount('001000000000000AAA','Sunny');
        Test.stopTest();


        WeatherService.Response result = WeatherService.getWeatherForecast(request);
        System.assertEquals(4, result.errors[0].code);
    }
}