<cfcomponent>

	<cfheader name="Access-Control-Allow-Origin" value="*">


    <cffunction name="init" access="remote" returntype="any">
 		 <cfreturn this />
	</cffunction>
    
    
    <cffunction name="getActiveMuseums" access="remote" returntype="Any" >
    	<cfstoredproc procedure="procMuseumGetMuseumsActive" datasource="sfarts_CFX" >
    	<cfprocresult name="active" >
    	</cfstoredproc>
    	<cfreturn active>
    </cffunction>
    
    <cffunction name="getEventsForMuseum" access="remote" returntype="Any" >
    	<cfargument name="orgNum" type="numeric" required="true" >
    	<cfstoredproc procedure="procMuseumGetActiveEvents" datasource="sfarts_CFX"  >
    		<cfprocparam cfsqltype="CF_SQL_INTEGER" value="#orgNum#" dbvarname="@orgNum" >
    		<cfprocresult name="musEvents" >
    </cfstoredproc>	
    <cfreturn musEvents>
    </cffunction>
    
     <!--- this is the main date query method for testing returns ONE DISP --- UPDATED AND CORRECTED FOR SINGLE DATES--->
   <cffunction name="getPublicArtByLocation" access="remote" returntype="any">

    	<cfargument name="date1" type="date" required="yes" default="#now()#">
        <cfargument name="date2" type="date" required="yes" default="#now()#">
        <cfargument name="Disp_Num" type="numeric" required="yes" default="13">
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procGetEventRecordsForDateRangePhoneByDisp]		"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
                 <cfprocparam dbvarname="@Disp_Num" value="#Disp_Num#" cfsqltype="CF_SQL_SMALLINT" >
            	<cfprocresult name="recordset1">
            </cfstoredproc>
          
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX">
    SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All, Event_Table.Date_Difference, Event_Table.Event_Phone, 
                      Event_Table.Event_Name, Event_Table.Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, Event_Table.Time_String, Event_Table.Org_Num, 
                      Org_Table.Org_Name, Org_Table.Org_Web, Venue_Table.Venue_address, Venue_Table.Venue_City, Venue_Table.Venue_Zip, Venue_Table.Venue_Name, 
                      Venue_Table.Venue_Phone, Venue_Table.Venue_Neighborhood, Event_Table.ticketLink, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount, Event_Table.TIXLink, Event_Table.TIXHalfPrice, Event_Table.Start_Date, Venue_Table.lat_lon, Venue_Table.lat, 
                      Venue_Table.lon, Venue_Table.instanceDistance
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID INNER JOIN
                      [Discipline List] ON Event_Table.ID = [Discipline List].ID INNER JOIN
                      [Discipline List] AS [Discipline List_1] ON Event_Table.ID2 = [Discipline List_1].ID LEFT OUTER JOIN
                      tbl_Neighborhoods ON Venue_Table.Venue_Neighborhood = tbl_Neighborhoods.neighborhoodID
WHERE     (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND 
                      (Event_Table.ID =  #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) 
                      AND (Event_Table.ID2 =  #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND 
                      (Event_Table.ID2 = #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) 
                      AND (Event_Table.ID =  #Recordset2__disp_num#)
ORDER BY Event_Table.Date_Difference
                </cfquery>
              	
      			<cfreturn baseQuery>
      </cfif>
  </cffunction> 
    
    
      <!--- this returns all events that DO NOT have a venue of "various" abd have a visual focus--->
   <cffunction name="getVisualEventsByDateByLocation" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfartsWebUser"  procedure="procGetEventRecordsForDateRange"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX">
SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All, Event_Table.Date_Difference, Event_Table.Event_Phone, 
                      Event_Table.Event_Name, Event_Table.Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, Event_Table.Time_String, Event_Table.Org_Num, 
                      Org_Table.Org_Name, Org_Table.Org_Web, Venue_Table.Venue_address, Venue_Table.Venue_City, Venue_Table.Venue_Zip, Venue_Table.Venue_Name, 
                      Venue_Table.Venue_Phone, Venue_Table.Venue_Neighborhood, Event_Table.ticketLink, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount, Event_Table.TIXLink, Event_Table.TIXHalfPrice, Event_Table.Start_Date, Venue_Table.lat_lon, Venue_Table.lat, 
                      Venue_Table.lon, Venue_Table.instanceDistance
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID
WHERE     ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 1)
                      OR
                      ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 1)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 1)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 1)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
    
    
    <!--- this returns all events that DO NOT have a venue of "various" abd have a PERFORMING focus--->
   <cffunction name="getPerformingEventsByDateByLocation" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfartsWebUser"  procedure="procGetEventRecordsForDateRange"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX">
SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All, Event_Table.Date_Difference, Event_Table.Event_Phone, 
                      Event_Table.Event_Name, Event_Table.Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, Event_Table.Time_String, Event_Table.Org_Num, 
                      Org_Table.Org_Name, Org_Table.Org_Web, Venue_Table.Venue_address, Venue_Table.Venue_City, Venue_Table.Venue_Zip, Venue_Table.Venue_Name, 
                      Venue_Table.Venue_Phone, Venue_Table.Venue_Neighborhood, Event_Table.ticketLink, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount, Event_Table.TIXLink, Event_Table.TIXHalfPrice, Event_Table.Start_Date, Venue_Table.lat_lon, Venue_Table.lat, 
                      Venue_Table.lon, Venue_Table.instanceDistance
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID
WHERE     ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 2)
                      OR
                      ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 2)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 2)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618 AND Event_Table.eventClass = 2)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
    
    
    
      <!--- this returns all events that DO NOT have a venue of "various" --->
   <cffunction name="getMasterEventsByDateByLocation" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfartsWebUser"  procedure="procGetEventRecordsForDateRange"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX">
SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All, Event_Table.Date_Difference, Event_Table.Event_Phone, 
                      Event_Table.Event_Name, Event_Table.Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, Event_Table.Time_String, Event_Table.Org_Num, 
                      Org_Table.Org_Name, Org_Table.Org_Web, Venue_Table.Venue_address, Venue_Table.Venue_City, Venue_Table.Venue_Zip, Venue_Table.Venue_Name, 
                      Venue_Table.Venue_Phone, Venue_Table.Venue_Neighborhood, Event_Table.ticketLink, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount, Event_Table.TIXLink, Event_Table.TIXHalfPrice, Event_Table.Start_Date, Venue_Table.lat_lon, Venue_Table.lat, 
                      Venue_Table.lon, Venue_Table.instanceDistance
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID
WHERE     ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618)
                      OR
                      ((Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND Event_Table.venueID <> 1618)
                      OR
                     ( (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) AND Event_Table.venueID <> 1618)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
  
    
    <cffunction name="getDispName" access="remote" returntype="Any" >
    	<cfargument name="disp" type="numeric" required="true" >
    	<cfquery datasource="sfarts_CFX" name="dispResult">
    		SELECT     Discipline
				FROM         [Discipline List]
				WHERE     (ID = #disp#)
    	</cfquery>
    	<cfreturn dispResult>
    </cffunction>
    
     <cffunction name="getSpecificEditorialItem" access="remote" returntype="query"> 
    	<cfargument name="ID" type="numeric" required="yes">
        	<cfstoredproc datasource="sfarts_CFX"  procedure="procEditorialGetSpecificItem"> 
            	<cfprocparam dbvarname="@ID" value="#ID#" cfsqltype="cf_sql_integer">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
    <cfreturn recordset1>
  </cffunction>
    
    
    <cffunction name="searchFunctionGetNumberOfRecords" access="remote" returntype="any">
    	<cfargument name="dateWindow" required="yes" type="string">
        <cfargument name="disp" required="yes" type="numeric" default="-1">
        <cfargument name="price" required="yes" type="numeric" default="-1">
         <cfargument name="neighborhood" required="yes" type="numeric" default="-1">
         <cfargument name="searchString" required="yes" type="string" default="">
        <cfargument name="date1" required="no" type="date">
        <cfargument name="date2" required="no" type="date">
        
        
    <!--- Get the events for the date window --->
	<cfif dateWindow EQ "today">
    	<cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) />
        <cfset date2 = date1>
        <cfset returnedEvents = getMasterEventsByDate_COUNT(date1,date2)>
    <cfelseif dateWindow EQ "weekend">
    	   <cfset returnedEvents = getEventsForWeekendNoDisp_Count()>
    <cfelseif dateWindow EQ "tomorrow">
           <cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) >
           <cfset date1 = dateAdd("d",1,date1)>
           <cfset date2 = date1>
           <cfset returnedEvents = getMasterEventsByDate_COUNT(date1,date2)>
      <cfelseif dateWindow EQ "all">
	  		<cfset returnedEvents = getAllLiveEventsCOUNT()>
        <cfelseif dateWindow EQ "99">
             <cfset returnedEvents = getMasterEventsByDate_COUNT(date1,date2)>       
    </cfif>
    <!--- end date window --->
    
	
	<!--- begin disp window --->
    <cfif disp GT 0>
    <cfquery name="dispFilter" dbtype="query">
    select *
    from returnedEvents
    where ID = #disp# OR ID2 = #disp#
    </cfquery>
    <cfset returnedEvents = dispFilter>
    </cfif>
		<!--- end disp window --->
        
        
         <!--- begin price window --->  
         <cfif price GT 0>
         	<cfif price EQ 1> <!--- free ---->
				<cfquery name="priceFilter" dbtype="query">
                select *
                from returnedEvents
                where ticket_string = 'Free'
                </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 2> <!--- child ---->
             <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Child_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 3><!--- student ---->
             		<cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Student_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
              <cfelseif price EQ 4><!--- senior ---->
              <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Senior_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             </cfif>  
               
         </cfif>
          <!--- end price window --->  
   
   			<!--- begin neighborhood window --->  
            <cfif neighborhood GT 0>
            	<cfquery name="neighborhoodFilter" dbtype="query">
                select *
                from returnedEvents
                where Venue_Neighborhood = #neighborhood#
                </cfquery>
                <cfset returnedEvents = neighborhoodFilter>
               </cfif> 
            <!--- end neighborhood window ---> 
            
            <!--- Begin string search window --->
            <cfif searchString NEQ ''>
            	<cfquery name="stringFilter" dbtype="query">
                select *
                from returnedEvents
                WHERE     ((LOWER(Org_Name) LIKE '%' + LOWER('#searchString#') + '%') OR
                      (LOWER(Event_Name) LIKE '%' + LOWER('#searchString#')+ '%') OR
                      (LOWER(Event_Description) LIKE '%' + LOWER('#searchString#') + '%'))
                </cfquery>
            		<cfset returnedEvents = stringFilter>
            
            </cfif>
            <!--- End String Search Window ----> 
   				
                
               
    <cfreturn returnedEvents>
    </cffunction>
    
    <!---- end of counting procedure ---->
    
    <cffunction name="searchFunctionPaged" access="remote" returntype="any">
    	<cfargument name="dateWindow" required="yes" type="string">
        <cfargument name="disp" required="yes" type="numeric" default="-1">
        <cfargument name="price" required="yes" type="numeric" default="-1">
         <cfargument name="neighborhood" required="yes" type="numeric" default="-1">
         <cfargument name="searchString" required="yes" type="string" default="">
        <cfargument name="date1" required="no" type="date">
        <cfargument name="date2" required="no" type="date">
        <cfargument name="intPage" required="no" type="numeric" default="1">
         <cfargument name="numberOfPages" required="no" type="numeric" default="999">
         <cfargument name="extraEvents" required="no" type="numeric" default="1">

        
        
    <!--- Get the events for the date window --->
	<cfif dateWindow EQ "today">
    	<cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) />
        <cfset date2 = date1>
        <cfset returnedEvents = getMasterEventsByDate(date1,date2)>
    <cfelseif dateWindow EQ "weekend">
    	   <cfset returnedEvents = getEventsForWeekendNoDisp()>
    <cfelseif dateWindow EQ "tomorrow">
           <cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) >
           <cfset date1 = dateAdd("d",1,date1)>
           <cfset date2 = date1>
           <cfset returnedEvents = getMasterEventsByDate(date1,date2)>
      <cfelseif dateWindow EQ "all">
	  		<cfset returnedEvents = getAllLiveEvents()>
        <cfelseif dateWindow EQ "99">
             <cfset returnedEvents = getMasterEventsByDate(date1,date2)>       
    </cfif>
    <!--- end date window --->
    
	
	<!--- begin disp window --->
    <cfif disp GT 0>
    <cfquery name="dispFilter" dbtype="query">
    select *
    from returnedEvents
    where ID = #disp# OR ID2 = #disp#
    </cfquery>
    <cfset returnedEvents = dispFilter>
    </cfif>
		<!--- end disp window --->
        
        
         <!--- begin price window --->  
         <cfif price GT 0>
         	<cfif price EQ 1> <!--- free ---->
				<cfquery name="priceFilter" dbtype="query">
                select *
                from returnedEvents
                where ticket_string = 'Free'
                </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 2> <!--- child ---->
             <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Child_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 3><!--- student ---->
             		<cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Student_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
              <cfelseif price EQ 4><!--- senior ---->
              <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Senior_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             </cfif>  
               
         </cfif>
          <!--- end price window --->  
   
   			<!--- begin neighborhood window --->  
            <cfif neighborhood GT 0>
            	<cfquery name="neighborhoodFilter" dbtype="query">
                select *
                from returnedEvents
                where Venue_Neighborhood = #neighborhood#
                </cfquery>
                <cfset returnedEvents = neighborhoodFilter>
               </cfif> 
            <!--- end neighborhood window ---> 
            
            <!--- Begin string search window --->
            <cfif searchString NEQ ''>
            	<cfquery name="stringFilter" dbtype="query">
                select *
                from returnedEvents
                WHERE     ((LOWER(Org_Name) LIKE '%' + LOWER('#searchString#') + '%') OR
                      (LOWER(Event_Name) LIKE '%' + LOWER('#searchString#')+ '%') OR
                      (LOWER(Event_Description) LIKE '%' + LOWER('#searchString#') + '%'))
                </cfquery>
            		<cfset returnedEvents = stringFilter>
            
            </cfif>
            <!--- End String Search Window ----> 
   
   		<!--- have to put the return filter here ---> 
        	<!--- determine rows to return --->
            <cfif returnedEvents.recordcount GT 0>
            <cfif intPage EQ 1>
            	<cfset startrow = 1>
            	<cfset endrow = startrow + 29>
             <cfelse>
             	<cfset startrow = (intPage-1) * 30> 
                <cfset endrow = startrow + 29>  
            </cfif>    
        
        <cfif numberOfPages GT intPage>
        	<cfset querySize = 30>
        <cfelse> 
        	<cfif extraEvents NEQ 0>
				<cfset querySize = extraEvents> 
                <cfset endrow = startrow  + extraEvents-1>
            <cfelse>
				<cfset querySize = 30> 
                <cfset endrow = (startrow)  + extraEvents-1>
            </cfif>
   
        </cfif>
        
        
        <cfset pagedQuery = QueryNew("Event_Num,Event_Name,Event_Description,Date_String,Org_Name,time_string,imagenamelarge,Ticket_String","Integer,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar,VarChar")>
          <cfset newRow = QueryAddRow(pagedQuery, querySize)>
          <cfset counter = 1>
        <cfloop query="returnedEvents" startrow="#startrow#" endrow="#endrow#">
        	
      		<cfset temp = QuerySetCell(pagedQuery, "Event_Name", #Event_Name#,#counter#)>
            <cfset temp = QuerySetCell(pagedQuery, "Event_Description", #Event_Description#,#counter#)>
            <cfset temp = QuerySetCell(pagedQuery, "Date_String", #Date_String#,#counter#)>
            <cfset temp = QuerySetCell(pagedQuery, "Event_Num", #Event_Num#,#counter#)>
             <cfset temp = QuerySetCell(pagedQuery, "Org_Name", #Org_Name#,#counter#)>
              <cfset temp = QuerySetCell(pagedQuery, "time_string", #time_string#,#counter#)>
              <cfset temp = QuerySetCell(pagedQuery, "imagenamelarge", #imagenamelarge#,#counter#)>
               <cfset temp = QuerySetCell(pagedQuery, "Ticket_String", #Ticket_String#,#counter#)>
               
            <cfset counter = counter +1>
        </cfloop>
      
		
       <cfset returnedEvents = pagedQuery> 
       </cfif>
    <cfreturn returnedEvents>
    </cffunction>
    
    
    <cffunction name="searchFunction" access="remote" returntype="any">
    	<cfargument name="dateWindow" required="yes" type="string">
        <cfargument name="disp" required="yes" type="numeric" default="-1">
        <cfargument name="price" required="yes" type="numeric" default="-1">
         <cfargument name="neighborhood" required="yes" type="numeric" default="-1">
         <cfargument name="searchString" required="yes" type="string" default="">
        <cfargument name="date1" required="no" type="date">
        <cfargument name="date2" required="no" type="date">

        
        
    <!--- Get the events for the date window --->
	<cfif dateWindow EQ "today">
    	<cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) />
        <cfset date2 = date1>
        <cfset returnedEvents = getMasterEventsByDate(date1,date2)>
    <cfelseif dateWindow EQ "weekend">
    	   <cfset returnedEvents = getEventsForWeekendNoDisp()>
    <cfelseif dateWindow EQ "tomorrow">
           <cfset date1 = DateFormat( Now(), "mm/dd/yyyy" ) >
           <cfset date1 = dateAdd("d",1,date1)>
           <cfset date2 = date1>
           <cfset returnedEvents = getMasterEventsByDate(date1,date2)>
      <cfelseif dateWindow EQ "all">
	  		<cfset returnedEvents = getAllLiveEvents()>
        <cfelseif dateWindow EQ "99">
             <cfset returnedEvents = getMasterEventsByDate(date1,date2)>       
    </cfif>
    <!--- end date window --->
    
	
	<!--- begin disp window --->
    <cfif disp GT 0>
    <cfquery name="dispFilter" dbtype="query">
    select *
    from returnedEvents
    where ID = #disp# OR ID2 = #disp#
    </cfquery>
    <cfset returnedEvents = dispFilter>
    </cfif>
		<!--- end disp window --->
        
        
         <!--- begin price window --->  
         <cfif price GT 0>
         	<cfif price EQ 1> <!--- free ---->
				<cfquery name="priceFilter" dbtype="query">
                select *
                from returnedEvents
                where ticket_string = 'Free'
                </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 2> <!--- child ---->
             <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Child_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             <cfelseif price EQ 3><!--- student ---->
             		<cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Student_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
              <cfelseif price EQ 4><!--- senior ---->
              <cfquery name="priceFilter" dbtype="query">
             	select *
                from returnedEvents
                where Senior_Discount = 'true'
                 </cfquery>
                <cfset returnedEvents = priceFilter>
             </cfif>  
               
         </cfif>
          <!--- end price window --->  
   
   			<!--- begin neighborhood window --->  
            <cfif neighborhood GT 0>
            	<cfquery name="neighborhoodFilter" dbtype="query">
                select *
                from returnedEvents
                where Venue_Neighborhood = #neighborhood#
                </cfquery>
                <cfset returnedEvents = neighborhoodFilter>
               </cfif> 
            <!--- end neighborhood window ---> 
            
            <!--- Begin string search window --->
            <cfif searchString NEQ ''>
            	<cfquery name="stringFilter" dbtype="query">
                select *
                from returnedEvents
                WHERE     ((LOWER(Org_Name) LIKE '%' + LOWER('#searchString#') + '%') OR
                      (LOWER(Event_Name) LIKE '%' + LOWER('#searchString#')+ '%') OR
                      (LOWER(Event_Description) LIKE '%' + LOWER('#searchString#') + '%'))
                </cfquery>
            		<cfset returnedEvents = stringFilter>
            
            </cfif>
            <!--- End String Search Window ----> 
   
    <cfreturn returnedEvents>
    </cffunction>
    
    <cffunction name="getEventsForWeekendNoDisp"  access="remote" returntype="any">
   <CFSET todaynum=#DayOfWeek(now())#>
        <cfset strdayOfWeek = #DayofWeekAsString(DayOfWeek(now()))#>
		<cfif strdayOfWeek EQ 'Monday'>
            <cfset startlimit = #DateAdd('D',4,Now())#>
            <cfset endlimit = #DateAdd('D',6,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Tuesday'>
            <cfset startlimit = #DateAdd('D',3,Now())#>
            <cfset endlimit = #DateAdd('D',5,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Wednesday'>
            <cfset startlimit = #DateAdd('D',2,Now())#>
            <cfset endlimit = #DateAdd('D',4,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Thursday'>
            <cfset startlimit = #DateAdd('D',1,Now())#>
            <cfset endlimit = #DateAdd('D',3,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Friday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',2,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Saturday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',1,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Sunday'>
            <cfset startlimit = #DateAdd('D',5,Now())#>
            <cfset endlimit = #DateAdd('D',7,Now())#>
        </cfif>
			<cfstoredproc datasource="sfarts_CFX" procedure="[procGetEventsForWeekend_NODISP_v4-1]" >
                <cfprocparam dbvarname="@startlimit" value="#startlimit#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@endlimit" value="#endlimit#" cfsqltype="cf_sql_date">
            	<cfprocresult name="XXYYXX">
            </cfstoredproc>
           
      			<cfreturn XXYYXX>
    </cffunction>
    
    <cffunction name= "getEventsForThisWeekend" access="remote" returntype="any">
   		<cfargument name="Disp_Num" type="numeric" required="yes">  
   		<CFSET todaynum=#DayOfWeek(now())#>
        <cfset strdayOfWeek = #DayofWeekAsString(DayOfWeek(now()))#>
		<cfif strdayOfWeek EQ 'Monday'>
            <cfset startlimit = #DateAdd('D',4,Now())#>
            <cfset endlimit = #DateAdd('D',6,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Tuesday'>
            <cfset startlimit = #DateAdd('D',3,Now())#>
            <cfset endlimit = #DateAdd('D',5,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Wednesday'>
            <cfset startlimit = #DateAdd('D',2,Now())#>
            <cfset endlimit = #DateAdd('D',4,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Thursday'>
            <cfset startlimit = #DateAdd('D',1,Now())#>
            <cfset endlimit = #DateAdd('D',3,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Friday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',2,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Saturday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',1,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Sunday'>
            <cfset startlimit = #DateAdd('D',5,Now())#>
            <cfset endlimit = #DateAdd('D',7,Now())#>
        </cfif>
			<cfstoredproc datasource="sfarts_CFX" procedure="procGetEventsForWeekendForPhone">
            	<cfprocparam dbvarname="@disp" value="#Disp_Num#" cfsqltype="cf_sql_integer">
                <cfprocparam dbvarname="@startlimit" value="#startlimit#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@endlimit" value="#endlimit#" cfsqltype="cf_sql_date">
            	<cfprocresult name="XXYYXX">
            </cfstoredproc>
           <cfreturn  XXYYXX>
     </cffunction>
    
    <cffunction name="getEventsForNeighborhood" access="remote"  returntype="Any" >
    	<cfargument name="neighborhoodNew" type="numeric" >
    		<cfstoredproc datasource="sfarts_CFX" procedure="proc_getEventsForNeighborhoodMobile">
    			<cfprocparam dbvarname="@neighborhoodNew" value="#neighborhoodNew#" cfsqltype="cf_sql_integer">
    			<cfprocresult name="neighborhoodEvents" >
    		</cfstoredproc>
		<cfreturn neighborhoodEvents>
    </cffunction>
    
    <cffunction name="getNeighborhoodName" access="remote" returntype="Any" >
    	<cfargument name="neighborhoodNew" type="numeric" >
    		<cfstoredproc procedure="procGetNeighborhoodNameNew" datasource="sfarts_CFX" >
    		<cfprocparam  dbvarname="@id" cfsqltype="CF_SQL_INTEGER" value="#neighborhoodNew#">
    		<cfprocresult name="neighborhood" >
    </cfstoredproc>
    <cfreturn neighborhood>    
    </cffunction>
    
    
    <cffunction name="getEventsForWeekendNoDisp_mobile"  access="remote" returntype="any">
   <CFSET todaynum=#DayOfWeek(now())#>
        <cfset strdayOfWeek = #DayofWeekAsString(DayOfWeek(now()))#>
		<cfif strdayOfWeek EQ 'Monday'>
            <cfset startlimit = #DateAdd('D',4,Now())#>
            <cfset endlimit = #DateAdd('D',6,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Tuesday'>
            <cfset startlimit = #DateAdd('D',3,Now())#>
            <cfset endlimit = #DateAdd('D',5,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Wednesday'>
            <cfset startlimit = #DateAdd('D',2,Now())#>
            <cfset endlimit = #DateAdd('D',4,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Thursday'>
            <cfset startlimit = #DateAdd('D',1,Now())#>
            <cfset endlimit = #DateAdd('D',3,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Friday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',2,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Saturday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',1,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Sunday'>
            <cfset startlimit = #DateAdd('D',5,Now())#>
            <cfset endlimit = #DateAdd('D',7,Now())#>
        </cfif>
			<cfstoredproc datasource="sfarts_CFX" procedure="[procGetEventsForWeekend_NODISP_v4-1_mobile]" >
                <cfprocparam dbvarname="@startlimit" value="#startlimit#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@endlimit" value="#endlimit#" cfsqltype="cf_sql_date">
            	<cfprocresult name="XXYYXX">
            </cfstoredproc>
           
      			<cfreturn XXYYXX>
    </cffunction>
    
     <cffunction name="getEventsForWeekendNoDisp_Count"  access="remote" returntype="any">
   <CFSET todaynum=#DayOfWeek(now())#>
        <cfset strdayOfWeek = #DayofWeekAsString(DayOfWeek(now()))#>
		<cfif strdayOfWeek EQ 'Monday'>
            <cfset startlimit = #DateAdd('D',4,Now())#>
            <cfset endlimit = #DateAdd('D',6,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Tuesday'>
            <cfset startlimit = #DateAdd('D',3,Now())#>
            <cfset endlimit = #DateAdd('D',5,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Wednesday'>
            <cfset startlimit = #DateAdd('D',2,Now())#>
            <cfset endlimit = #DateAdd('D',4,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Thursday'>
            <cfset startlimit = #DateAdd('D',1,Now())#>
            <cfset endlimit = #DateAdd('D',3,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Friday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',2,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Saturday'>
            <cfset startlimit = #DateAdd('D',0,Now())#>
            <cfset endlimit = #DateAdd('D',1,Now())#>
            <cfelseif 	strdayOfWeek EQ 'Sunday'>
            <cfset startlimit = #DateAdd('D',5,Now())#>
            <cfset endlimit = #DateAdd('D',7,Now())#>
        </cfif>
			<cfstoredproc datasource="sfarts_CFX" procedure="[procGetEventsForWeekend_NODISP_v4-1COUNT]">
                <cfprocparam dbvarname="@startlimit" value="#startlimit#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@endlimit" value="#endlimit#" cfsqltype="cf_sql_date">
            	<cfprocresult name="XXYYXX">
            </cfstoredproc>
           
      			<cfreturn XXYYXX>
    </cffunction>
    
    
    <cffunction name="getAllLiveEvents" access="remote" returntype="any" >
    	<cfstoredproc datasource="SFARTS_CFX" procedure="[procGetAllLiveEventsV4_PAGED_intRow]">
        <cfprocresult name="recordset1">
    </cfstoredproc>
      <cfreturn recordset1>
    </cffunction>
    
    <cffunction name="getAllLiveEventsNeighborhood" access="remote" returntype="any" >
    	<cfstoredproc datasource="SFARTS_CFX" procedure="[procGetLiveEventsForNeighborhood]">
        <cfprocresult name="recordset1">
    </cfstoredproc>
      <cfreturn recordset1>
    </cffunction>
    
    <cffunction name="getAllLiveEventsCOUNT" access="remote" returntype="any">
    	<cfstoredproc datasource="SFARTS_CFX" procedure="[procGetAllLiveEventsV4COUNT]">
        <cfprocresult name="recordset1">
    </cfstoredproc>
      <cfreturn recordset1>
    </cffunction>
    
      <cffunction name="getAllLiveEventsPAGED" access="remote" returntype="any">
      <cfargument name="intPage" type="numeric" required="no" default="1">
    	<cfstoredproc datasource="SFARTS_CFX" procedure="[procGetAllLiveEventsV4_PAGED]">
        <cfprocparam dbvarname="@intPage" value="#intPage#" cfsqltype="cf_sql_integer">
        <cfprocresult name="recordset1">
    </cfstoredproc>
      <cfreturn recordset1>
    </cffunction>
    
          <cffunction name="getDispsInNewOrder" access="remote" returntype="any">
    	<cfstoredproc datasource="SFARTS_CFX" procedure="[procAppNewDispOrder]">
        <cfprocresult name="recordset1">
    </cfstoredproc>
      <cfreturn recordset1>
    </cffunction>
    
    
    <cffunction name="getEventsBySimpleStringSearch" access="remote" returntype="any"> <!--- NO dates involved --->
    	<cfargument name="searchString" type="string" required="yes" default="Piano">
        	<cfset searchString = #replace(searchString,'+',' ')#>
        	<cfstoredproc datasource="SFARTS_CFX"  procedure="procSimpleSearchStringiPhoneAPI"> 
            	<cfprocparam dbvarname="@searchString" value="#searchString#" cfsqltype="cf_sql_varchar">
            	<cfprocresult name="recordset1">
            </cfstoredproc>     
    <cfreturn recordset1>
  </cffunction>
    
     <cffunction name="getPodSubjects2" access="remote" returntype="Query">
		<cfstoredproc datasource="SFARTS_CFX" procedure="[procGetPodsiPhoneAPI]">
        <cfprocresult name="podSubjects">
		</cfstoredproc>	
		<cfreturn podSubjects>
	</cffunction>
    
    <cffunction name="getHomePageEditorial" returntype="any">
    <cfstoredproc datasource="sfarts_CFX"  procedure="newGetHomePageEditorial"> 
            	<cfprocresult name="editorial">
    </cfstoredproc>
    <cfreturn editorial>
   	</cffunction>
    
    
    <cffunction name="getFeature" returntype="any">
    <cfargument name="featureID" type="numeric" required="yes">
    <cfstoredproc datasource="sfarts_CFX" procedure="procGetFeature">
    	<cfprocparam dbvarname="@featureID" value="#featureID#" cfsqltype="cf_sql_integer">
        <cfprocresult name="recordset1">
        </cfstoredproc>
    <cfreturn recordset1>
    </cffunction>
    
    

     <cffunction name="getHomePageEditorialNew" returntype="any">
    <cfstoredproc datasource="sfarts_CFX"  procedure="getHomePageEditorialV4"> 
            	<cfprocresult name="editorial">
    </cfstoredproc>
    <cfreturn editorial>
   	</cffunction>

	 <cffunction name="getEditorialContent" access="remote" returntype="any">
     	<cfargument name="Disp_Num" required="false" default="99" type="numeric">
     		<cfif Disp_Num EQ 99> 
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItems_v4]"> 
            	<cfprocresult name="recordset1">
            </cfstoredproc>
			<cfreturn recordset1>
            <cfelseif Disp_Num EQ 98>
            	<cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItemsLimit30_v4]"> 
            	<cfprocresult name="recordset1">
            </cfstoredproc>
			<cfreturn recordset1>
   		 <cfelse>
            <cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItems_v4ByDisp]"> 
                <cfprocparam cfsqltype="CF_SQL_INTEGER" dbvarname="@Disp_Num" value="#Disp_Num#">
                        <cfprocresult name="recordset1">
                    </cfstoredproc>
            <cfreturn recordset1>
	</cfif>
  </cffunction>
  
  <cffunction name="getEditorialContent_mobile" access="remote" returntype="any">
     	<cfargument name="Disp_Num" required="false" default="99" type="numeric">
     		<cfif Disp_Num EQ 99> 
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItems_v4_mobile]"> 
            	<cfprocresult name="recordset1">
            </cfstoredproc>
			<cfreturn recordset1>
            <cfelseif Disp_Num EQ 98>
            	<cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItemsLimit30_v4]"> 
            	<cfprocresult name="recordset1">
            </cfstoredproc>
			<cfreturn recordset1>
   		 <cfelse>
            <cfstoredproc datasource="sfarts_CFX"  procedure="[procEditorialGetItems_v4ByDisp]"> 
                <cfprocparam cfsqltype="CF_SQL_INTEGER" dbvarname="@Disp_Num" value="#Disp_Num#">
                        <cfprocresult name="recordset1">
                    </cfstoredproc>
            <cfreturn recordset1>
	</cfif>
  </cffunction>
  
  <cffunction name="getDispInfo" access="remote" returntype="any">
  	<cfargument name="Disp_Num" required="false" default="99" type="numeric">
  		<cfif Disp_Num NEQ 99>
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procGetDispInfoByDisp]"> 
            	<cfprocparam cfsqltype="CF_SQL_INTEGER" dbvarname="@Disp_Num" value="#Disp_Num#">
                <cfprocresult name="recordset1">
               </cfstoredproc>
              <cfreturn recordset1>
        </cfif>
  </cffunction>
  
 <cffunction name="getEventByEvent_Num" access="remote" returntype="any" >  
    	<cfargument name="EVENT_NUM" type="numeric" required="yes">
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procGetEventByEventID_V4]"> 
            	<cfprocparam dbvarname="@ID" value="#EVENT_NUM#" cfsqltype="cf_sql_integer">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
    <cfreturn recordset1>
  </cffunction>  
  
  <cffunction name="getPastFeatures" access="remote" returntype="any">
  	
   <cfstoredproc datasource="sfarts_CFX" procedure="procGetActivePastFeatures">

   	<cfprocresult name="recordset1">
    </cfstoredproc>
<cfreturn recordset1>
  </cffunction>
  
   <cffunction name="getPastMonths" access="remote" returntype="any">
   <cfstoredproc datasource="sfarts_CFX" procedure="procGetEditorialMonths">
   	<cfprocresult name="recordset1">
    </cfstoredproc>
<cfreturn recordset1>
  </cffunction>
  
  
  <cffunction name="getEventsByDispForEventPage" access="remote" returntype="any">
  	<cfargument name="disp" type="numeric" required="yes">
    	<cfstoredproc datasource="sfarts_CFX" procedure="procGetEventsByDispNext30Days">
        	<cfprocparam dbvarname="@disp" value="#disp#" cfsqltype="cf_sql_integer">
            <cfprocresult name="recordset1">
            </cfstoredproc>
            <cfreturn recordset1> 
  </cffunction>
  
   <!--- this is the main date query method --->
   <cffunction name="getMasterEventsByDate" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfarts_cfx"  procedure="procGetEventRecordsForDateRangev4" cachedWithin="#createtimespan(0,0,6,0)#"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX" cachedWithin="#createtimespan(0,0,6,0)#">
SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All, Event_Table.Date_Difference, Event_Table.Event_Phone, 
                      Event_Table.Event_Name, Event_Table.Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, Event_Table.Time_String, Event_Table.Org_Num, 
                      Org_Table.Org_Name, Org_Table.Org_Web, Venue_Table.Venue_address, Venue_Table.Venue_City, Venue_Table.Venue_Zip, Venue_Table.Venue_Name, 
                      Venue_Table.Venue_Phone, Venue_Table.Venue_Neighborhood, Event_Table.ticketLink, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount, Event_Table.TIXLink, Event_Table.TIXHalfPrice, Event_Table.Start_Date, Venue_Table.lat_lon, Venue_Table.lat, Venue_Table.lon, 
                      Venue_Table.instanceDistance, [Discipline List].Discipline, tbl_NewEditorial.imageName,tbl_NewEditorial.imageNameLarge
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID INNER JOIN
                      [Discipline List] ON Event_Table.ID = [Discipline List].ID LEFT OUTER JOIN
                      tbl_NewEditorial ON Event_Table.Event_Num = tbl_NewEditorial.event
WHERE     (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
  
  <cffunction name="getMasterEventsByDate_mobile" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfarts_cfx"  procedure="procGetEventRecordsForDateRangev4" cachedWithin="#createtimespan(0,0,6,0)#"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX" >
SELECT     Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2,Venue_Table.Venue_Neighborhood
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID INNER JOIN
                      [Discipline List] ON Event_Table.ID = [Discipline List].ID 
WHERE     (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
  
   
   <cffunction name="getMasterEventsByDate_COUNT" access="remote" returntype="query">
    	<cfargument name="date1" type="date" required="yes">
        <cfargument name="date2" type="date" required="yes">
        
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfarts_cfx"  procedure="[procGetEventRecordsForDateRangeV4_COUNT]"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
            	<cfprocresult name="recordset1">
            </cfstoredproc>
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			<cfparam name="disp_num" default="3">
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX">
SELECT   Event_Table.Event_Num, Event_Table.ID, Event_Table.ID2, Event_Table.Free_For_All,
                      Event_Table.Ticket_String,
                      
                      Venue_Table.Venue_Neighborhood, Event_Table.Child_Discount, Event_Table.Senior_Discount, 
                      Event_Table.Student_Discount,dbo.Org_Table.Org_Name,Event_Table.Event_Name,Event_Table.Event_Description
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID INNER JOIN
                      [Discipline List] ON Event_Table.ID = [Discipline List].ID LEFT OUTER JOIN
                      tbl_NewEditorial ON Event_Table.Event_Num = tbl_NewEditorial.event
WHERE     (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#  , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1)
ORDER BY Event_Table.Date_Difference
                </cfquery>
      	<cfreturn baseQuery>
      </cfif>
  </cffunction>
  
   <!--- this is the main date query method for testing returns ONE DISP --- UPDATED AND CORRECTED FOR SINGLE DATES--->
   <cffunction name="getMasterEventsByDateByDisp" access="remote" returntype="any">
    	<cfargument name="date1" type="date" required="yes" default="5/30/2010">
        <cfargument name="date2" type="date" required="yes" default="5/30/2010">
        <cfargument name="Disp_Num" type="numeric" required="yes" default="2">
        <cfif date1 NEQ date2>
        
        	<cfstoredproc datasource="sfarts_CFX"  procedure="[procGetEventRecordsForDateRangePhoneByDisp]		"> 
            	<cfprocparam dbvarname="@date1" value="#date1#" cfsqltype="cf_sql_date">
                <cfprocparam dbvarname="@date2" value="#date2#" cfsqltype="cf_sql_date">
                 <cfprocparam dbvarname="@Disp_Num" value="#Disp_Num#" cfsqltype="CF_SQL_SMALLINT" >
            	<cfprocresult name="recordset1">
            </cfstoredproc>
          
      <cfreturn recordset1>
      <cfelse>
      	<!--- It is a query for a specific date --->
       <!--- set variables for use in the code below --->
         	<cfparam name="date_ahead" default="3">
			<cfparam name="day_string" default="Wednesday">
			<cfparam name="num" default="27">
			
			<CFSET today_date=#now()#>
			
			<CFPARAM NAME="month" DEFAULT="DATEPART(m,date1)">
			<CFPARAM NAME="year" DEFAULT="DATEPART(yyyy,date1)">
			<CFPARAM NAME="day" DEFAULT="DATEPART(dd,date1)">
			<CFPARAM NAME="Discipline" DEFAULT="All_Events">	
            
            <!---  Calculate variables for date portion query  --->
       
            <CFSET future_date = #date1#>
			<CFSET type="d">
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#+1>
            <CFIF #Dateformat(today_date)# EQ #Dateformat(future_date)#>
            <CFSET date_ahead=#Abs(DateDiff(type, future_date, today_date))#>
            </CFIF>
            <CFSET target_date=#now()#+#date_ahead#>
            <CFSET day_string = #dateformat(target_date, "dddd")#>
            <cfset num = #dateformat(target_date, "d")#>
            <cfset num = "D" & num>
           
         	<!--- query for the date test--->
            
			<cfparam name="Recordset2__date_ahead" default="#date_ahead#">
		<cfparam name="Recordset2__day_string" default="#day_string#">
		<cfparam name="Recordset2__num" default="#num#">
		<cfparam name="Recordset2__disp_num" default="#disp_num#">

			
			
            <cfquery name="baseQuery" datasource="sfarts_CFX" cachedwithin="#createTimeSpan(0,0,30,0)#">
SELECT     Event_Table.Event_Num, Event_Table.Date_Difference, ISNULL(Event_Table.Event_Phone, '') AS Event_Phone, dbo.clean_text(Event_Table.Event_Name) 
                      AS Event_Name, dbo.clean_text(Event_Table.Event_Description) AS Event_Description, Event_Table.Ticket_String, Event_Table.Date_String, 
                      Event_Table.Time_String, Org_Table.Org_Name, ISNULL(Org_Table.Org_Web, '') AS Org_Web, ISNULL(Venue_Table.Venue_address, '') AS Venue_Address, 
                      ISNULL(Venue_Table.Venue_City, '') AS Venue_City, Venue_Table.Venue_Name, ISNULL(Venue_Table.Venue_Phone, '') AS Venue_Phone, 
                      ISNULL(Event_Table.ticketLink, '') AS TicketLink, ISNULL(dbo.MakeYesNo(Event_Table.Child_Discount), 'NO') AS Child_Discount, 
                      ISNULL(dbo.MakeYesNo(Event_Table.Senior_Discount), 'NO') AS Senior_Discount, ISNULL(dbo.MakeYesNo(Event_Table.Student_Discount), 'NO') 
                      AS Student_Discount, ISNULL(dbo.MakeYesNo(Event_Table.TIXLink), 'NO') AS TixLink, ISNULL(dbo.MakeYesNo(Event_Table.TIXHalfPrice), 'NO') AS TIXHalfPrice, 
                      tbl_Neighborhoods.Neighborhood, [Discipline List].Discipline, [Discipline List_1].Discipline AS Discipline_2, Venue_Table.lat, Venue_Table.lon, 
                      ISNULL(Venue_Table.Venue_State, '') AS Venue_State, 'http://www.sfarts.org/share/index.cfm?eventID=' + CAST(Event_Table.Event_Num AS VARCHAR(80)) 
                      AS shareURL, tbl_NewEditorial.imageName
FROM         Venue_Table INNER JOIN
                      Org_Table INNER JOIN
                      Event_Table ON Org_Table.Org_Num = Event_Table.Org_Num ON Venue_Table.ID = Event_Table.venueID INNER JOIN
                      [Discipline List] ON Event_Table.ID = [Discipline List].ID INNER JOIN
                      [Discipline List] AS [Discipline List_1] ON Event_Table.ID2 = [Discipline List_1].ID LEFT OUTER JOIN
                      tbl_NewEditorial ON Event_Table.Event_Num = tbl_NewEditorial.event LEFT OUTER JOIN
                      tbl_Neighborhoods ON Venue_Table.Venue_Neighborhood = tbl_Neighborhoods.neighborhoodID
WHERE     (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND 
                      (Event_Table.ID =  #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) 
                      AND (Event_Table.ID2 =  #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# ,dbo.getPacificTime())) AND (Event_Table.Performing_Arts_Event = 1) AND (Event_Table.[#Recordset2__num#] = 1) AND 
                      (Event_Table.ID2 = #Recordset2__disp_num#) OR
                      (Event_Table.Start_Date <= DATEADD(day, #Recordset2__date_ahead#, dbo.getPacificTime())) AND (Event_Table.End_Date >= DATEADD(day, 
                      #Recordset2__date_ahead# , dbo.getPacificTime())) AND (Event_Table.[#Recordset2__day_string#] = 1) AND (Event_Table.Gallery_Museum_Event = 1) 
                      AND (Event_Table.ID =  #Recordset2__disp_num#)
ORDER BY Event_Table.Date_Difference
                </cfquery>
              	
      			<cfreturn baseQuery>
      </cfif>
  </cffunction>  
  
  
  <cffunction 
 access="remote" 
 name="doEncode" 
 output="false" 
 returntype="string">

 <cfargument 
 name="stringToEncode" 
 type="string" 
 required="yes">

 <cfscript>
 variables.encodedString = arguments.stringToEncode;
 variables.encodedString = replace( variables.encodedString, "!", "%21", "all" );
 variables.encodedString = replace( variables.encodedString, "*", "%2A", "all" );
 variables.encodedString = replace( variables.encodedString, "##", "%23", "all" );
 variables.encodedString = replace( variables.encodedString, "$", "%24", "all" );
 variables.encodedString = replace( variables.encodedString, "%", "%25", "all" );
 variables.encodedString = replace( variables.encodedString, "&", "%26", "all" );
 variables.encodedString = replace( variables.encodedString, "'", "%27", "all" );
 variables.encodedString = replace( variables.encodedString, "(", "%28", "all" );
 variables.encodedString = replace( variables.encodedString, ")", "%29", "all" );
 variables.encodedString = replace( variables.encodedString, "@", "%40", "all" );
 variables.encodedString = replace( variables.encodedString, "/", "%2F", "all" );
 variables.encodedString = replace( variables.encodedString, "^", "%5E", "all" );
 variables.encodedString = replace( variables.encodedString, "~", "%7E", "all" );
 variables.encodedString = replace( variables.encodedString, "{", "%7B", "all" );
 variables.encodedString = replace( variables.encodedString, "}", "%7D", "all" );
 variables.encodedString = replace( variables.encodedString, "[", "%5B", "all" );
 variables.encodedString = replace( variables.encodedString, "]", "%5D", "all" );
 variables.encodedString = replace( variables.encodedString, "=", "%3D", "all" );
 variables.encodedString = replace( variables.encodedString, ":", "%3A", "all" );
 variables.encodedString = replace( variables.encodedString, ",", "%2C", "all" );
 variables.encodedString = replace( variables.encodedString, ";", "%3B", "all" );
 variables.encodedString = replace( variables.encodedString, "?", "%3F", "all" );
 variables.encodedString = replace( variables.encodedString, "+", "%2B", "all" );
 variables.encodedString = replace( variables.encodedString, "\", "%5C", "all" );
 variables.encodedString = replace( variables.encodedString, '"', "%22", "all" );
 return variables.encodedString;
 </cfscript>

 </cffunction>
  
</cfcomponent>