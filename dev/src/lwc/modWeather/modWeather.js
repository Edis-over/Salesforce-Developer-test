/**
 * Created by Edis Hulpea March 2023.
 */

import { LightningElement, track, wire, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getWeatherForecast from '@salesforce/apex/WeatherService.getWeatherForecast';

export default class ModWeather extends LightningElement {

    @api recordId;

    tableData;
    isFetched = false;
    timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;

    @track formData={
        latitude:0,
        longitude:0
    }

    connectedCallback(){
        console.log('FIRST',this.recordId)
        this.getWeather({
            timezone: this.timezone,
            recordId: this.recordId
        });
    }


    handleInputChange(e){
        const inputName = e.target.name;
        const inputValue = e.target.value;
        this.formData[inputName]=inputValue;
    }
    handleClick(){
        this.isFetched = false;
        const request={
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            latitude: this.formData.latitude,
            longitude: this.formData.longitude,
            recordId: this.recordId
        };
        this.getWeather(request);
    }

    getWeather(request){
        getWeatherForecast({request: request})
            .then(response => {
                console.log('response',response);
                if(response.isSuccess){
                    const rawData = JSON.parse(response.data);
                    this.plotTable(rawData);
                } else {
                    console.log('in else');
                }
                this.isFetched=true;
            })
            .catch(error => {
                this.isFetched=true;
                console.log('Error',error);
            });

    }
    plotTable(rawData){
        console.log('rawData',rawData)
        const filteredData={};
        filteredData.time =rawData.hourly.time ;
        filteredData.temperature = rawData.hourly.temperature_2m;;
        filteredData.windspeed = rawData.hourly.windspeed_10m;
        filteredData.relativeHumidity = rawData.hourly.relativehumidity_2m;
        filteredData.latitude = rawData.latitude;
        filteredData.longitude = rawData.longitude;
        filteredData.hourlyUnits = rawData.hourly_units;

        this.tableData = filteredData;
    }
}