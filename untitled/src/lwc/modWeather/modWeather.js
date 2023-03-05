/**
 * Created by Edis Hulpea March 2023.
 */

import { LightningElement, track, api } from 'lwc';
import { getRecord } from 'lightning/uiRecordApi';
import getWeatherForecast from '@salesforce/apex/WeatherService.getWeatherForecast';

export default class ModWeather extends LightningElement {

    @api recordId;

    tableData;
    isFetched = false;
    timezone = Intl.DateTimeFormat().resolvedOptions().timeZone;
    disableButton = false;

    @track formData={
        latitude:0,
        longitude:0
    }

    formValidity = {
        latitude:true,
        longitude:true
    }

    connectedCallback(){
        //Initial weather fetch with account billing longitude and latitude
        this.getWeather({
            timezone: this.timezone,
            recordId: this.recordId
        });
    }

    handleClick(){
        this.isFetched = false;
        const request={
            timezone: Intl.DateTimeFormat().resolvedOptions().timeZone,
            latitude: this.formData.latitude,
            longitude: this.formData.longitude,
            recordId: this.recordId
        };

        //Fetch on demand with user input values for longitude and latitude
        this.getWeather(request);
    }

    //Call get weather forecast service
    getWeather(request){
        getWeatherForecast({request: request})
            .then(response => {
                if(response.isSuccess){
                    const rawData = JSON.parse(response.data);
                    this.plotTable(rawData);
                }
                this.isFetched=true;
            })
            .catch(error => {
                this.isFetched=true;
            });
    }

    //map response to the table props
    plotTable(rawData){
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

    handleBlur(e){
        const inputName = e.target.name;
        const inputValue = e.target.value.replace(/^0+/, '');

        //latitude validation
        if(inputName === 'latitude'){

            let latitudeField = this.template.querySelector(`lightning-input[data-field=${inputName}]`);
           if( inputValue > 90 || inputValue < - 90 ) {
               this.formValidity.latitude = false;
           }else {
               this.formValidity.latitude = true;
           }
           latitudeField.setCustomValidity(this.formValidity.latitude ? '' : 'Latitude must be between -90 and 90');
           latitudeField.reportValidity();
        }

        //longitude validation
        if(inputName === 'longitude'){

            let longitudeField = this.template.querySelector(`lightning-input[data-field=${inputName}]`);
            if( inputValue > 180 || inputValue < -180 ) {
                this.formValidity.longitude = false;
           } else {
                this.formValidity.longitude = true;
           }
           longitudeField.setCustomValidity(this.formValidity.longitude ? '' : 'Latitude must be between -180 and 180');
           longitudeField.reportValidity();
        }

        //disable button if invalid
        const validations = Object.keys(this.formValidity);
        const invalidFields = [];
        validations.forEach( validation =>{
             this.formValidity[validation] === false ? invalidFields.push(validation) : null;
        })

        this.disableButton = invalidFields.length > 0 ?  true : false;
        this.formData[inputName]=inputValue;
    }
}