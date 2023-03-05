/**
 * Created by Edis Hulpea March 2023.
 */

import { LightningElement, api, track } from 'lwc';

const columns = [
    { label: 'Time',fieldName: 'time' },
    { label: 'Temperature', fieldName: 'temperature' },
    { label: 'Wind speed', fieldName: 'windspeed' },
    { label: 'Relative humidity', fieldName: 'relativeHumidity' }
];

export default class Table extends LightningElement {

    @api tableData={};
    formattedTableData;
    columns = columns;
    latitude;
    longitude;

    connectedCallback() {
       this.formattedTableData =  this.formatTable(this.tableData);
    }

    formatTable(tabledata){
        const time = tabledata.time;
        const temperature =  tabledata.temperature;
        const windspeed = tabledata.windspeed;
        const relativeHumidity = tabledata.relativeHumidity;
        const formattedData = [];
        const hourlyUnits = tabledata.hourlyUnits;
        this.latitude = tabledata.latitude ;
        this.longitude = tabledata.longitude ;

        for(let i = 0; i<time.length; i++){
            formattedData.push({
                time: this.formatTime(time[i]),
                temperature: temperature[i]+hourlyUnits.temperature_2m,
                windspeed: windspeed[i]+hourlyUnits.windspeed_10m,
                relativeHumidity: relativeHumidity[i]+hourlyUnits.relativehumidity_2m
            })
        }
        return formattedData;
    }

    formatTime(time){
        const dateTime = new Date(time);
        const hours = dateTime.getHours().toString().padStart(2, '0');
        const minutes = dateTime.getMinutes().toString().padStart(2, '0');
        return `${hours}:${minutes}`
    }
}