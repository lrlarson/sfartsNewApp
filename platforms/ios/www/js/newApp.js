//var dataHost = "http://sfarts.org/newApp/data/new_V4.cfc";
var dataHost = "http://sfarts.org/newApp/data/new_V4.cfc";
var myGlobalLocation = '';
var globalTestLocation = '';
var htmlContent = '';

//getLocation();

$(document).on('pagebeforeshow', function () {
    $.mobile.activePage.find(".ui-header a.ui-btn-left").addClass("ui-btn-icon-notext");
    $.mobile.activePage.find(".ui-header a.ui-btn-left").removeClass("ui-btn-icon-left");
});

// Swipe to remove list item
$( document ).on( "swipeleft swiperight", "#list li.ui-li", function( event ) {
    var listitem = $( this ),
    // These are the classnames used for the CSS transition
        dir = event.type === "swipeleft" ? "left" : "right",
    // Check if the browser supports the transform (3D) CSS transition
        transition = $.support.cssTransform3d ? dir : false;

    confirmAndDelete( listitem, transition );
});

// If it's not a touch device...
if ( ! $.mobile.support.touch ) {

    // Remove the class that is used to hide the delete button on touch devices
    $( "#list" ).removeClass( "touch" );

    // Click delete split-button to remove list item
    $( ".delete" ).on( "click", function() {
        var listitem = $( this ).parent( "li.ui-li" );

        confirmAndDelete( listitem );
    });
}

function confirmAndDelete( listitem, transition ) {
    // Highlight the list item that will be removed
    listitem.addClass("ui-btn-down-d");
    // Inject topic in confirmation popup after removing any previous injected topics
    $("#confirm .topic").remove();
    listitem.find(".topic").clone().insertAfter("#question");
    // Show the confirmation popup
    $("#confirm").popup("open");
    // Proceed when the user confirms
    $("#confirm #yes").on("click", function () {
        // Remove with a transition
        if (transition) {

            listitem
                // Remove the highlight
                .removeClass("ui-btn-down-d")
                // Add the class for the transition direction
                .addClass(transition)
                // When the transition is done...
                .on("webkitTransitionEnd transitionend otransitionend", function () {
                    // ...the list item will be removed
                    listitem.remove();
                    // ...the list will be refreshed and the temporary class for border styling removed
                    $("#list").listview("refresh").find(".ui-li.border").removeClass("border");
                })
                // During the transition the previous list item should get bottom border
                .prev("li.ui-li").addClass("border");
        }
        // If it's not a touch device or the CSS transition isn't supported just remove the list item and refresh the list
        else {
            listitem.remove();
            $("#list").listview("refresh");
        }
    });
    // Remove active state and unbind when the cancel button is clicked
    $("#confirm #cancel").on("click", function () {
        listitem.removeClass("ui-btn-down-d");
        $("#confirm #yes").off();
    });
}

//document.addEventListener("deviceready", onDeviceReady, false);

$(function(){
    document.addEventListener("deviceready", onDeviceReady, false);
});



function onDeviceReady() {
    var devicePlatform = device.platform;
    checkConnection();
    //alert('deviceReady');
    navigator.geolocation.getCurrentPosition(onSuccess, onError);
    var options = { timeout: 31000, enableHighAccuracy: true, maximumAge: 90000 };
    if (devicePlatform == 'Android'){
        //alert('android');
        navigator.geolocation.getCurrentPosition(onSuccess, onError, options);
    }
    else
        {
           //alert('IOS')
            navigator.geolocation.getCurrentPosition(onSuccess, onError);
        }

}



document.addEventListener("resume", onResume, false);
function onResume() {
    setTimeout(function() {
        connected = checkConnection();
        if (connected) {
            initPage();
        }
    }, 0);
}

document.addEventListener("offline", onOffline, false);

/*
function initPage(){
    checkDatesInBookmarks();
    console.log('initPage');
    currentDate = moment().format('MM/DD/YYYY');
    getEventsForToday(currentDate);
    getEventsForThisWeekend();
    getEventHighlights();

    getBookMarksCount();
    getNeighborhoodCount();

}
*/

function checkDatesInBookmarks() {
    var now = moment();
    var nowMoment = moment(now, 'MM-DD-YYYY');

    retrievedObject = localStorage.getItem('events');

    if (retrievedObject) {
        var jsonString = JSON.parse(retrievedObject);
        var length = jsonString.length;
        for (var i = 0; i < length; i++) {
            var endDate = jsonString[i].end_date;
            var event_num = jsonString[i].event_num;
            var endDateMoment = moment(endDate, 'MM-DD-YYYY');
            if (nowMoment.diff(endDate, 'days') * -1 >= 0) {} else {
                //remove from storage

                jsonString.splice(i, 1);
                console.log(jsonString);
                localStorage.events = JSON.stringify(jsonString);
                length--;
            }
        }

    }
}



function onOffline() {
    alert('Sorry -- it appears that you have lost your internet connection, and we need it.');
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
        return false;
    }else{

        return true;
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
    //getLocation();
    //alert('in pagemap')
    var parameters = $(this).data("url").split("?")[1];
    lat_lon = parameters.replace("eventLatLong=","");
    initialize(lat_lon);
    //navigator.geolocation.getCurrentPosition(onSuccess,onError);

        });

var onSuccess = function(position) {
    //alert('success');
    myGlobalLocation = position;
};


function initialize(eventLatlng) {

    //create proper lat lon object
    //alert('success');
    var bits = eventLatlng.split(/,\s*/);
    point = new google.maps.LatLng(parseFloat(bits[0]),parseFloat(bits[1]));


    var latlng = new google.maps.LatLng(myGlobalLocation.coords.latitude, myGlobalLocation.coords.longitude);

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

function onError(error){

    console.log('code: '    + error.code    + '\n' +
    'message: ' + error.message + '\n');
    //navigator.geolocation.getCurrentPosition(onSuccess, onError);
}


$(document).on('pagebeforeshow', "#page",function () {
    checkDatesInBookmarks();
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
    //getLocation();
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
            finalArray = [];
            cleanEvents = d.DATA;
            htmlContent = '';
            //console.log(cleanEvents);
            p1 = new LatLon(Geo.parseDMS(myGlobalLocation.coords.latitude),Geo.parseDMS(myGlobalLocation.coords.longitude));

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

$(document).on('pagebeforeshow', "#closeToYouMuseums",function () {


    $.ajax({
        url: dataHost,
        data: {
            method: 'getActiveMuseumsDistance',
            returnFormat: 'json'
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {

            finalArray = [];
            cleanEvents = d.DATA;
            htmlContent = '';
            //console.log(cleanEvents);
            p1 = new LatLon(Geo.parseDMS(myGlobalLocation.coords.latitude),Geo.parseDMS(myGlobalLocation.coords.longitude));

            if (cleanEvents.length > 0){
                for(i=0;i<cleanEvents.length;i++){
                    p2 =new LatLon(Geo.parseDMS(cleanEvents[i][3]),Geo.parseDMS(cleanEvents[i][4]));
                    instanceDistance =	kiloconv(p1.distanceTo(p2));


                    if(!isNaN(instanceDistance)) {
                        finalArray.push(cleanEvents[i]);
                        var x = finalArray.length;
                        finalArray[x - 1][5] = instanceDistance;
                    }
                }
                //document.write(finalArray.length+ ' final length of final array');
                finalArray.sort(function(a, b){
                    return parseFloat(a[5]) > parseFloat(b[5])?1:-1;
                });



                for(i=0;i<finalArray.length;i++){
                    // put measurement units here ----
                    if (finalArray[i][5] <= .1){
                        finalArray[i][5] = (5280 * finalArray[i][5]).toFixed(0) + ' feet';
                    }else if (finalArray[i][5] > .1 && finalArray[i][5] < .50){
                        finalArray[i][5] = (1769 * finalArray[i][5]).toFixed(0) + ' yards';
                    }else{
                        finalArray[i][5] = finalArray[i][5] + ' miles';
                    }

                    htmlContent += '<li> <a href="eventsForMuseum.html?id='+finalArray[i][0]+' "><span style="font-size:10px; font-style:italic;">' + finalArray[i][5] + ' from you</span><br /><span class="summaryOrgName" style="font-weight:300">'+finalArray[i][1]+'</span> <br /> </li></a>';
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

            getDispCountForSpecDate(dateDecoded);
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

//events for specific museum
$(document).on('pagebeforeshow', "#eventsForMuseum",function () {
    var parameters = $(this).data("url").split("?")[1];
    id = parameters.replace("id=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventsForMuseum',
            returnFormat: 'json',
            orgNum: id
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });

           // console.log(data);


            var museumEventsTemplateScript = $('#museumEventsTemplate').html();
            museumEventsTemplate= Handlebars.compile(museumEventsTemplateScript);
            $('#museumEvents').empty();
            $('#museumEvents').append(museumEventsTemplate(workReturn));
            $("#museumEvents").listview().listview('refresh');

            $('#museumName').html(workReturn.data[0].org_name);

        }
    });

});


//this neighborhood events
$(document).on('pagebeforeshow', "#neighborhoodEventList",function () {
    var parameters = $(this).data("url").split("?")[1];
    nb = parameters.replace("nb=","");
    $.ajax({
        url: dataHost,
        data: {
            method: 'getEventsForNeighborhood',
            returnFormat: 'json',
            neighborhoodNew: nb
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });

            //console.log('neighborhood');
            //console.log(workReturn);


            var neighborhoodEventsTemplateScript = $('#neighborhoodEventsTemplate').html();
            neighborhoodTemplate= Handlebars.compile(neighborhoodEventsTemplateScript);
            $('#neighborhoodTemplate').empty();
            $('#neighborhoodEvents').append(neighborhoodTemplate(workReturn));
            $("#neighborhoodEvents").listview().listview('refresh');

            $('#neighborhood').html(workReturn.data[0].neighborhood);
        }

    });

    $.ajax({
        url: dataHost,
        data: {
            method: 'getNeighborhoodName',
            returnFormat: 'json',
            neighborhoodNew: nb
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            dispReturn = $.serializeCFJSON({
                data: d
            });
            $('#neighborhood').html(dispReturn.data[0].Neighborhood);

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
            //console.log(workReturn);
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

    //navigator.geolocation.getCurrentPosition(onSuccess, onError);
    console.log('in init page');
    getEventsForToday(currentDate);
    getEventsForThisWeekend();
    getEventHighlights();
    getBookMarksCount();
    getNeighborhoodCount();
    getActiveMuseums();
}


function getActiveMuseums(){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getActiveMuseums',
            returnFormat: 'json'
        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);



            var museumEventsTemplateScript = $('#museumTemplate').html();
            museumEventsTemplate= Handlebars.compile(museumEventsTemplateScript);
            $('#museumList').empty();
            $('#museumList').append(museumEventsTemplate(workReturn));
            $("#museumList").listview().listview('refresh');

        }
    });

}

/**
 *
 * @param targetDate
 */
function getDispCountForSpecDate(targetDate){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getMasterEventsByDate_mobile',
            returnFormat: 'json',
            date1:targetDate,
            date2:targetDate
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
                        $('#specDisp1Count').html(internalCount);
                        break;
                    case 2:
                        $('#specDisp2Count').html(internalCount);
                        break;
                    case 3:
                        $('#specDisp3Count').html(internalCount);
                        break;
                    case 4:
                        $('#specDisp4Count').html(internalCount);
                        break;
                    case 5:
                        $('#specDisp5Count').html(internalCount);
                        break;
                    case 6:
                        $('#specDisp6Count').html(internalCount);
                        break;
                    case 7:
                        $('#specDisp7Count').html(internalCount);
                        break;
                    case 8:
                        $('#specDisp8Count').html(internalCount);
                        break;
                    case 9:
                        $('#specDisp9Count').html(internalCount);
                        break;
                    case 10:
                        $('#specDisp10Count').html(internalCount);
                        break;
                }
            });
        }
    });
}

function getNeighborhoodCount(){
    $.ajax({
        url: dataHost,
        data: {
            method: 'getAllLiveEventsNeighborhood',
            returnFormat: 'json'

        },
        method: 'GET',
        dataType: "json",
        async: true,
        success: function (d, r, o) {
            workReturn = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
           // $('#todayCount').html(workReturn.data.length);
            dispArray = [1,2,3,4,5,6,8,11,12,13,14,15,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33];
            count=[];
            $.each( dispArray , function( index, value ) {
                internalCount = 0;
                for (i=0;i < workReturn.data.length;i++){
                    if (workReturn.data[i].neighborhoodnew == value ){
                        internalCount += 1;
                    }
                }
                switch(value){
                    case 1:
                        $('#nb1Count').html(internalCount);
                        break;
                    case 2:
                        $('#nb2Count').html(internalCount);
                        break;
                    case 3:
                        $('#nb3Count').html(internalCount);
                        break;
                    case 4:
                        $('#nb4Count').html(internalCount);
                        break;
                    case 5:
                        $('#nb5Count').html(internalCount);
                        break;
                    case 6:
                        $('#nb6Count').html(internalCount);
                        break;
                    case 8:
                        $('#nb8Count').html(internalCount);
                        break;
                    case 11:
                        $('#nb11Count').html(internalCount);
                        break;
                    case 12:
                        $('#nb12Count').html(internalCount);
                        break;
                    case 13:
                        $('#nb13Count').html(internalCount);
                        break;
                    case 14:
                        $('#nb14Count').html(internalCount);
                        break;
                    case 15:
                        $('#nb15Count').html(internalCount);
                        break;
                    case 18:
                        $('#nb18Count').html(internalCount);
                        break;
                    case 19:
                        $('#nb19Count').html(internalCount);
                        break;
                    case 20:
                        $('#nb20Count').html(internalCount);
                        break;
                    case 21:
                        $('#nb21Count').html(internalCount);
                        break;
                    case 22:
                        $('#nb22Count').html(internalCount);
                        break;
                    case 23:
                        $('#nb23Count').html(internalCount);
                        break;
                    case 24:
                        $('#nb24Count').html(internalCount);
                        break;
                    case 25:
                        $('#nb25Count').html(internalCount);
                        break;
                    case 26:
                        $('#nb26Count').html(internalCount);
                        break;
                    case 27:
                        $('#nb27Count').html(internalCount);
                        break;
                    case 28:
                        $('#nb28Count').html(internalCount);
                        break;
                    case 29:
                        $('#nb29Count').html(internalCount);
                        break;
                    case 30:
                        $('#nb30Count').html(internalCount);
                        break;
                    case 31:
                        $('#nb31Count').html(internalCount);
                        break;
                    case 32:
                        $('#nb32Count').html(internalCount);
                        break;
                    case 33:
                        $('#nb33Count').html(internalCount);
                        break;
                }
            });
        }
    });
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
            workReturn1 = $.serializeCFJSON({
                data: d
            });
            //console.log(workReturn);
            $('#todayCount').html(workReturn1.data.length);
            dispArray = [1,2,3,4,5,6,7,8,9,10];
            count=[];
            $.each( dispArray , function( index, value ) {
                internalCount = 0;
                for (i=0;i < workReturn1.data.length;i++){
                     if (workReturn1.data[i].id == value || workReturn1.data[i].id2 == value){
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
{   //alert('in show position');
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
    console.log('initLoc');
    if (navigator.geolocation)
    {
        navigator.geolocation.getCurrentPosition(showPosition);
        //console.log('good');
        
    }
    else{alert('This browser does not support location services');
    }
}
/*
var myErrorHandler = function(statusCode, statusMsg)
{
    alert('Status: ' + statusCode + ', ' + statusMsg);
}
*/

document.addEventListener('deviceready', function () {
    if (navigator.notification) { // Override default HTML alert with native dialog
        window.alert = function (message) {
            navigator.notification.alert(
                message,    // message
                null,       // callback
                "SF/Arts Express", // title
                'OK'        // buttonName
            );
        };
    }
}, false);

