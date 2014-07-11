//var dataHost = "http://localhost:8500/SFArts_newApp/data/new_V4.cfc";
var dataHost = "http://sfarts.org/newApp/data/new_V4.cfc";
var myGlobalLocation = '';
var globalTestLocation = '';
var htmlContent = '';
getLocation();



document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    checkConnection();
}

document.addEventListener("resume", onResume, false);
function onResume() {
    setTimeout(function() {
        initPage();
    }, 0);
}

document.addEventListener("offline", onOffline, false);

function onOffline() {
    alert('Sorry -- it appears that you have lost your internet connection.');
}


document.addEventListener("online", onOnline, false);

function onOnline() {
    initPage();
}

$(function() {
    FastClick.attach(document.body);
});

function checkConnection() {
    var networkState = navigator.connection.type;

    var states = {};
    states[Connection.UNKNOWN]  = 'Unknown connection';
    states[Connection.ETHERNET] = 'Ethernet connection';
    states[Connection.WIFI]     = 'WiFi connection';
    states[Connection.CELL_2G]  = 'Cell 2G connection';
    states[Connection.CELL_3G]  = 'Cell 3G connection';
    states[Connection.CELL_4G]  = 'Cell 4G connection';
    states[Connection.CELL]     = 'Cell generic connection';
    states[Connection.NONE]     = 'No network connection';


    if (networkState == 'No network connection'){
        alert('Sorry -- a network connection is required for this App.');

    }

}

//page load events


function getBookMarksCount() {
    retrievedObject = localStorage.getItem('events');
    if (retrievedObject) {
        bookMarks = JSON.parse(retrievedObject)
        $('#bookCount').html(bookMarks.length);
    }

}

//map page
$(document).on('pageshow', "#pageMap",function () {
    //var map;
    var parameters = $(this).data("url").split("?")[1];
    lat_lon = parameters.replace("eventLatLong=","");
    if(navigator.geolocation) {
        navigator.geolocation.getCurrentPosition(function(position){
            //alert('gettingPosition');
            initialize(position.coords.latitude,position.coords.longitude,lat_lon);


        });

    }
});


function initialize(lat,lng,eventLatlng) {

    //create proper lat lon object
    var bits = eventLatlng.split(/,\s*/);
    point = new google.maps.LatLng(parseFloat(bits[0]),parseFloat(bits[1]));


    var latlng = new google.maps.LatLng(lat, lng);
    var myOptions = {
        zoom: 13,
        center: point,
        mapTypeId: google.maps.MapTypeId.ROADMAP
    };
    var map = new google.maps.Map(document.getElementById("map_canvas"),myOptions);
    var marker = new google.maps.Marker({
        position: latlng,
        map: map,
        title:"Your location"
    });
    var image = 'gps.png';

    var marker = new google.maps.Marker({
        position: point,
        map: map,
        icon:image,
        title:"Event location"
    });
    //$('#map_canvas').map('refresh');
    google.maps.event.trigger(map, 'resize');
}


$(document).on('pagebeforeshow', "#page",function () {
    getBookMarksCount();
});

//Close to you list...
$(document).on('pagebeforeshow', "#closeToYouList",function () {

    var parameters = $(this).data("url").split("?")[1];
    scope = parameters.replace("scope=","");
    switch(scope) {
        case 'all':
            currentMethod = 'getMasterEventsByDateByLocation';
            $('#scope').html('All Disciplines')
            break;
        case 'gallery':
            currentMethod = 'getVisualEventsByDateByLocation';
            $('#scope').html('Galleries/Museums')
            break;
        case 'perform':
            currentMethod = 'getPerformingEventsByDateByLocation';
            $('#scope').html('Performing Arts')
            break;
        case 'public':
            currentMethod = 'getPublicArtByLocation';
            $('#scope').html('Public Art')
    }
    getLocation();
    $.ajax({
        url: dataHost,
        data: {
            method: currentMethod,
            returnFormat: 'json',
            date1:currentDate,
            date2:currentDate
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            $('#thisDate').html(currentDate);
            finalArray = new Array();
            cleanEvents = d.DATA;
            htmlContent = '';
            //console.log(cleanEvents);
            p1 = new LatLon(Geo.parseDMS(myGlobalLocation.lat()),Geo.parseDMS(myGlobalLocation.lng()));

            if (cleanEvents.length > 0){
                for(i=0;i<cleanEvents.length;i++){
                    p2 =new LatLon(Geo.parseDMS(cleanEvents[i][28]),Geo.parseDMS(cleanEvents[i][29]));
                    instanceDistance =	kiloconv(p1.distanceTo(p2));


                    if(!isNaN(instanceDistance)) {
                        finalArray.push(cleanEvents[i]);
                        x = finalArray.length;
                        finalArray[x - 1][30] = instanceDistance;
                    }
                }
                //document.write(finalArray.length+ ' final length of final array');
                finalArray.sort(function(a, b){
                    return parseFloat(a[30]) > parseFloat(b[30])?1:-1;
                });



                for(i=0;i<finalArray.length;i++){
                    // put measurement units here ----
                    if (finalArray[i][30] <= .1){
                        finalArray[i][30] = (5280 * finalArray[i][30]).toFixed(0) + ' feet';
                    }else if (finalArray[i][30] > .1 && finalArray[i][30] < .50){
                        finalArray[i][30] = (1769 * finalArray[i][30]).toFixed(0) + ' yards';
                    }else{
                        finalArray[i][30] = finalArray[i][30] + ' miles';
                    }

                    htmlContent += '<li> <a href="eventFinalDetail.html?event_num='+finalArray[i][0]+' "><span style="font-size:10px; font-style:italic;">' + finalArray[i][30] + ' from you</span><br /><span class="summaryOrgName" style="font-weight:300">'+finalArray[i][6]+'</span> <br /> ' +finalArray[i][12]+'</li></a>';
                }

                $('#eventList').empty();
                $('#eventList').append(htmlContent);
                $('#eventList').listview();
                $('#eventList').listview('refresh');


            }


        }
    });


});


//todays events by disp
$(document).on('pagebeforeshow', "#todaysEventsListByDisp",function () {
    var parameters = $(this).data("url").split("?")[1];
    disp = parameters.replace("disp=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getMasterEventsByDateByDisp',
            returnFormat: 'json',
            Disp_Num: disp,
            date1:currentDate,
            date2:currentDate
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            console.log(workReturn);



            var todaysEventsTemplateScript = $('#todaysEventsTemplate').html();
            todaysEventsTemplate= Handlebars.compile(todaysEventsTemplateScript);
            $('#todaysEventsDiv').empty();
            $('#todaysEventsDiv').append(todaysEventsTemplate(workReturn));
            $("#todaysEventsDiv").listview().listview('refresh');

        }
    });
    $.ajax({
        url: dataHost,
        data: {
            method: 'getDispName',
            returnFormat: 'json',
            disp: disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            dispReturn = $.serializeCFJSON({
                data: d
            });

            //console.log(dispReturn);
            $('#todaysDisp').html(dispReturn.data[0].discipline);

        }
    });
});


//specDateDetailPage
$(document).on('pagebeforeshow', "#specDateEventsListDetail",function () {
    var urlString = $(this).data("url").split("?")[1];
    urlString = urlString.replace("disp=", "");
    urlString = urlString.replace("date=", "");
    urlArray = urlString.split('&');
    var disp = urlArray[0];
    var date = urlArray[1];
    $('#specDate').html(date);


    $.ajax({
        url: dataHost,
        data: {
            method: 'getMasterEventsByDateByDisp',
            returnFormat: 'json',
            date1:date,
            date2:date,
            Disp_Num:disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);



            var dateReturnEventsTemplateScript = $('#byDateDetailTemplate').html();
            specDatesReturn = Handlebars.compile(dateReturnEventsTemplateScript);
            $('#specDateDiscipline').empty();
            $('#specDateDiscipline').append(specDatesReturn(workReturn));
            $("#specDateDiscipline").listview().listview('refresh');



        }

    });
    $.ajax({
        url: dataHost,
        data: {
            method: 'getDispName',
            returnFormat: 'json',
            disp: disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            dispReturn = $.serializeCFJSON({
                data: d
            });
            $('#dispName').html(dispReturn.data[0].discipline);

        }
    });

});


//specDateSummaryPage
$(document).on('pagebeforeshow', "#specDateSummaryPage",function () {
    // alert('pageshow');
    var parameters = $(this).data("url").split("?")[1];
    date = parameters.replace("selectedDate=", "");
    dateDecoded = decodeURIComponent(date);
    $('.targetDate').html(dateDecoded);
    $.ajax({
        url: dataHost,
        data: {
            method: 'getDispsInNewOrder',
            returnFormat: 'json'
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            for (var i=0;i<workReturn.data.length;i++){
                workReturn.data[i].dt = dateDecoded;
            }
            //console.log(workReturn);



            var dateSearchEventsTemplateScript = $('#byDateSummaryTemplate').html();
            dateEventsTemplate = Handlebars.compile(dateSearchEventsTemplateScript);
            $('#specDateSummary').empty();
            $('#specDateSummary').append(dateEventsTemplate(workReturn));
            $("#specDateSummary").listview().listview('refresh');
        }
    });

});



//SearchReturn
$(document).on('pagebeforeshow', "#searchReturn",function () {
   // alert('pageshow');
    var parameters = $(this).data("url").split("?")[1];
    searchText = parameters.replace("searchText=", "");
    $('#searchTextHeader').html('Returns for '+ searchText);
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventsBySimpleStringSearch',
            returnFormat: 'json',
            searchString: searchText
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });

            //console.log(workReturn);

            $('#searchText').html(searchText);

            var searchEventsTemplateScript = $('#searchEventsTemplate').html();
            searchEventsTemplate = Handlebars.compile(searchEventsTemplateScript);
            $('#searchResults').empty();
            $('#searchResults').append(searchEventsTemplate(workReturn));
            $("#searchResults").listview().listview('refresh');

            $('#searchText').html(searchText);
        }
    });
});

//this weekends events by disp
$(document).on('pagebeforeshow', "#thisWeekendsEventsList",function () {
    var parameters = $(this).data("url").split("?")[1];
    disp = parameters.replace("disp=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventsForThisWeekend',
            returnFormat: 'json',
            Disp_Num: disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });

            //console.log(workReturn);


            var weekendEventsTemplateScript = $('#weekendEventsTemplate').html();
                weekendEventsTemplate= Handlebars.compile(weekendEventsTemplateScript);
            $('#weekendEvents').empty();
            $('#weekendEvents').append(weekendEventsTemplate(workReturn));
            $("#weekendEvents").listview().listview('refresh');


        }
    });
    $.ajax({
        url: dataHost,
        data: {
            method: 'getDispName',
            returnFormat: 'json',
            disp: disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            dispReturn = $.serializeCFJSON({
                data: d
            });
            $('#weekendDisp').html(dispReturn.data[0].discipline);

        }
    });

});



//editorial summary page
$(document).on('pagebeforeshow', "#editorialPageSummary",function () {
    var parameters = $(this).data("url").split("?")[1];
    disp = parameters.replace("disp=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEditorialContent',
            returnFormat: 'json',
            Disp_Num: disp
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
            $('#featuredDisp').html(workReturn.data[0].discipline);
            //$('#curator').html(workReturn.data[0].curatedby);

            var podTemplateScript = $('#podstemplate').html();
            podsTemplate = Handlebars.compile(podTemplateScript);
            $('#podsList').empty();
            $('#podsList').append(podsTemplate(workReturn));
            $("#podsList").listview().listview('refresh');
        }
    });
});

//event final detail page

$(document).on('pagebeforeshow', "#eventFinalDetail",function () {
    var parameters = $(this).data("url").split("?")[1];
    event_num = parameters.replace("event_num=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventByEvent_Num',
            returnFormat: 'json',
            Event_Num: event_num
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            console.log(workReturn);
            $('#eventFinalName').html(workReturn.data[0].event_name);
            var eventTemplateScript = $('#eventDetailTemplate').html();
            eventTemplate = Handlebars.compile(eventTemplateScript);
            $('#eventDetailBlock').empty();
            $('#eventDetailBlock').append(eventTemplate(workReturn)).trigger('create');

            $('#bookmarkButton').click(function( event ) {

                var storedEvents = [];
                if (localStorage.getItem('events')){
                    retrievedObject = localStorage.getItem('events');
                    storedEvents = JSON.parse(retrievedObject);
                }

                var eventDetail = {eventName:workReturn.data[0].event_name,eventDateString:workReturn.data[0].date_string,end_date:workReturn.data[0].end_date,event_num:workReturn.data[0].event_num,org_name:workReturn.data[0].org_name};

                storedEvents.push(eventDetail);
                localStorage.setItem('events',JSON.stringify(storedEvents));
                $('#bookmarkButton').hide();


            });

        }
    });
});



//editorial detail page
$(document).on('pagebeforeshow', "#editorialDetail",function () {
    var parameters = $(this).data("url").split("?")[1];
    editorialIndex = parameters.replace("id=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getSpecificEditorialItem',
            returnFormat: 'json',
            ID: editorialIndex
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);

            $('#dispString').html(workReturn.data[0].dispstring);
            $('#curatorFinal').html("By "+ workReturn.data[0].curatedby);

            var storyTemplateScript = $('#storyDetailTemplate').html();
            storyTemplate = Handlebars.compile(storyTemplateScript);
            $('#editorialStory').empty();
            $('#editorialStory').append(storyTemplate(workReturn)).trigger('create');

        }
    });
});




function initPage(){
    currentDate = moment().format('MM/DD/YYYY');
    getEventsForToday(currentDate);
    getEventsForThisWeekend();
    getEventHighlights();
    getBookMarksCount();
}

function testAlert(){

    alert('testAlert');
}


function getEventsForToday(currentDate){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getMasterEventsByDate_mobile',
            returnFormat: 'json',
            date1:currentDate,
            date2:currentDate
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
            $('#todayCount').html(workReturn.data.length);
            dispArray = [1,2,3,4,5,6,7,8,9,10];
            count=[];
            $.each( dispArray , function( index, value ) {
                internalCount = 0;
                for (i=0;i < workReturn.data.length;i++){
                     if (workReturn.data[i].id == value || workReturn.data[i].id2 == value){
                         internalCount += 1;
                    }
                }
                switch(value){
                    case 1:
                        $('#disp1Count').html(internalCount);
                        break;
                    case 2:
                        $('#disp2Count').html(internalCount);
                        break;
                    case 3:
                        $('#disp3Count').html(internalCount);
                        break;
                    case 4:
                        $('#disp4Count').html(internalCount);
                        break;
                    case 5:
                        $('#disp5Count').html(internalCount);
                        break;
                    case 6:
                        $('#disp6Count').html(internalCount);
                        break;
                    case 7:
                        $('#disp7Count').html(internalCount);
                        break;
                    case 8:
                        $('#disp8Count').html(internalCount);
                        break;
                    case 9:
                        $('#disp9Count').html(internalCount);
                        break;
                    case 10:
                        $('#disp10Count').html(internalCount);
                        break;
                }
            });
        }
    });
}

function getEventsForThisWeekend(){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventsForWeekendNoDisp_mobile',
            returnFormat: 'json'
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            //alert("success");
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
            $('#weekendCount').html(workReturn.data.length);
            dispArray = [1,2,3,4,5,6,7,8,9,10];
            count=[];
            $.each( dispArray , function( index, value ) {
                internalCount = 0;
                for (i=0;i < workReturn.data.length;i++){
                    if (workReturn.data[i].id == value || workReturn.data[i].id2 == value){
                        internalCount += 1;
                    }
                }
                switch(value){
                    case 1:
                        $('#week1Count').html(internalCount);
                        break;
                    case 2:
                        $('#week2Count').html(internalCount);
                        break;
                    case 3:
                        $('#week3Count').html(internalCount);
                        break;
                    case 4:
                        $('#week4Count').html(internalCount);
                        break;
                    case 5:
                        $('#week5Count').html(internalCount);
                        break;
                    case 6:
                        $('#week6Count').html(internalCount);
                        break;
                    case 7:
                        $('#week7Count').html(internalCount);
                        break;
                    case 8:
                        $('#week8Count').html(internalCount);
                        break;
                    case 9:
                        $('#week9Count').html(internalCount);
                        break;
                    case 10:
                        $('#week10Count').html(internalCount);
                        break;
                }
            });

        }
    });
}

function getEventHighlights(){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEditorialContent_mobile',
            returnFormat: 'json'
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            //alert("success");
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
            $('#highlightCount').html(workReturn.data.length);
            dispArray = [1,2,3,4,5,6,7,8,9,10];
            count=[];
            $.each( dispArray , function( index, value ) {
                internalCount = 0;
                for (i=0;i < workReturn.data.length;i++){
                    if (workReturn.data[i].disp_num == value){
                        internalCount += 1;
                    }
                }
                switch(value){
                    case 1:
                        $('#high1Count').html(internalCount);
                        break;
                    case 2:
                        $('#high2Count').html(internalCount);
                        break;
                    case 3:
                        $('#high3Count').html(internalCount);
                        break;
                    case 4:
                        $('#high4Count').html(internalCount);
                        break;
                    case 5:
                        $('#high5Count').html(internalCount);
                        break;
                    case 6:
                        $('#high6Count').html(internalCount);
                        break;
                    case 7:
                        $('#high7Count').html(internalCount);
                        break;
                    case 8:
                        $('#high8Count').html(internalCount);
                        break;
                    case 9:
                        $('#high9Count').html(internalCount);
                        break;
                    case 10:
                        $('#high10Count').html(internalCount);
                        break;
                }
            });
        }
    });

}

function getUrlParameter(sParam)
{
    var sPageURL = window.location.search.substring(1);
    var sURLVariables = sPageURL.split('&');
    for (var i = 0; i < sURLVariables.length; i++)
    {
        var sParameterName = sURLVariables[i].split('=');
        if (sParameterName[0] == sParam)
        {
            return sParameterName[1];
        }
    }
}

Handlebars.registerHelper("isVenuePhone", function (venue_phone) {
    if (venue_phone) {
        var string = '<br /> Venue Phone: ' + venue_phone;
        return string;
    }

});

Handlebars.registerHelper("isTicketLink", function (ticketlink) {
    if (ticketlink) {
        var string = ' <a href="' + ticketlink + '" data-role="button" data-mini="true" data-theme="b"target="_blank">More Ticket Information</a>'
        return string;
    }

});


Handlebars.registerHelper("isPhoto", function (imagenamelarge) {
    if (imagenamelarge) {
        var string = '<img src="' + imagenamelarge +'" class="centerPhoto"  /> <br /><br />';
        return string;
    }

});

Handlebars.registerHelper("isWebSite", function (org_web) {
    if (org_web) {
        var string = ' <a href="' + org_web + '" data-role="button" data-mini="true" data-theme="b" target="_blank">Event Website</a>'
        return string;
    }

});

function showPosition(position)
{ //alert('in show position');
    //var myLocation = new google.maps.LatLng(37.779789,-122.418812)//city hall temp value
    //var myLocation = new google.maps.LatLng(37.973535,-122.531087)//standford temp value
    var myLocation = new google.maps.LatLng(position.coords.latitude,position.coords.longitude);
    var myLatlng = new google.maps.LatLng(40.650429,-73.950348);
    myGlobalLocation = myLocation;
    globalTestLocation = myLatlng;
}

function kiloconv(val){

    var distance=((val* 0.621)).toFixed(2);
    return distance;

}

function getLocation(){
    if (navigator.geolocation)
    {
        navigator.geolocation.getCurrentPosition(showPosition);
        //alert('good');
    }
    else{alert('This browser does not support location services');
    }
}

var myErrorHandler = function(statusCode, statusMsg)
{
    alert('Status: ' + statusCode + ', ' + statusMsg);
}


document.addEventListener('deviceready', function () {
    if (navigator.notification) { // Override default HTML alert with native dialog
        window.alert = function (message) {
            navigator.notification.alert(
                message,    // message
                null,       // callback
                "Workshop", // title
                'OK'        // buttonName
            );
        };
    }
}, false);

