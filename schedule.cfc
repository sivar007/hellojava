<cfcomponent>
	<cfscript>
		application.globalTemplate.onrequeststart(); 
		this.usertype = "0";
	</cfscript>
    
    <!-------------------------------------------------------
	                Test Mailer                              
	------------------------------------------------------->
    <cffunction name="testmail" access="remote">
    	<cfset application.dbprocs.callProc("send_mail_test")>
    </cffunction>
	
    <!--------------------------------------------------------
	             View Schedule                            
	------------------------------------------------------>
	<cffunction name="viewSchedule" access="remote">
    	<cfparam name="url.msg" default="">
		<cfset var curDate = "">
        
        <cfif not isdefined("session.dates")>
           <cflock scope="session" timeout="10">
           		<cfset session.dates = structNew()>
           </cflock>
        </cfif>
        
    	<cfsavecontent variable="main">
        
        <cfset application.globalTemplate.addJS('jquery/jquery-ui-1.8.6.custom.min.js',request)>
        <cfset application.globalTemplate.addJS('scripts/schedule.js',request)>
        <cfset application.globalTemplate.addCSS('css/schedule.css',request)>
        <cfset application.globalTemplate.addJS('script/popupwindow.js',request)>
        <cfset application.globalTemplate.addCSS('css/popupwindow.css',request)>
        <!---><cfif isdefined("session.user.role")>
          <cfoutput>#session.user.role#</cfoutput>
        </cfif>--->
        <cfsavecontent variable="toolTip2">
        <h1>View/Edit Schedule</h1>
        <b>View Roster</b><br/>
        &nbsp;&nbsp; To view the roster of volunteers for a given event, click <b>"MM/DD/YYYY"</b> date of that event.  It will show just the volunteers for that event.
        <br/><br/>
        <b>Viewing Schedule</b><br/>
        &nbsp; &nbsp; By default, the schedule screen will show upcoming events only; if you need to see an event that has already happened, please click <b>View Past Events</b>. Once in the Past Events view, you can click <b>View Upcoming Events Only</b> to return.
        <br/><br/>
	  </cfsavecontent>
    
	  <cfif isdefined("session.user.role") and session.user.role gte application.roles.MDAdmin>
      	<cfsaveContent variable="adminToolTip">
                <strong>View/Edit Schedule Screen</strong><br />
                &nbsp; &nbsp; The View/Edit Schedule screen provides a calendar of BRIDGE clinic events. From View/Edit Schedule, admins can see the schedule, add new events, or make changes to existing events.
                <br/><br/>
                <b>Add Date</b><br />
                &nbsp; &nbsp; To schedule a new event, click <b>Add Date</b>. From the Date Registration screen which will display, you can pick a date from the calendar in the <b>Date</b> field, assign a <b>Specialty</b> from the drop-down list, and add any extra information necessary in the <b>Notes About Date</b> text field. When you are done, click <b>Save</b> to create the new event.
                <br/><br/>
                <b>Edit</b><br /> 
                &nbsp; &nbsp; To edit an event, click <b>Edit</b> in the left column of the calendar next to the event.
                <br/>
                &nbsp; &nbsp; The Date Registration screen will display, with the calendar entry for the event at the bottom of the screen. At that screen, you can make changes to the event. Changes are saved as you make them.
                <br/><br/>
                <b>Delete</b><br/>
                &nbsp; &nbsp; To delete an event, click <b>Delete</b> in the left column of the calendar next to the event. Please be careful with this function, because you will not get a warning message or a second step. Once you click Delete, the event is gone.
		</cfsaveContent>
        <cfset toolTip2 = toolTip2 & adminToolTip />
      </cfif>
      
      <cfset createObject("component","components.tooltip").replaceMsg("#toolTip2#")/>
        
			<cfif isdefined("url.msg")>
            	<cfset application.displaymsg.render()>
            </cfif>
            
            <cfif isDEFINED("url.viewPast")>
              <cfif url.viewPast eq 0>
                <cfset session.pagecontrol.schedule.viewPast = 0>
              <cfelse>
                <cfset session.pagecontrol.schedule.viewPast = 1>
              </cfif>
            </cfif>
              
              
            <cfif session.pagecontrol.schedule.viewPast eq 1>
              <cfset dateQuery = application.dbprocs.callProc("get_sched_dates")>
            <cfelse>
              <cfset dateQuery = application.dbprocs.callProc("get_new_sched_dates")>
            </cfif>
            
            <cfset menu = renderMenu()>
            
            <cfset renderScheduleKey()>
            
            <br/>
            <cfoutput>#menu#</cfoutput>
        	
            
            
            <table class="Bridge">
              <thead>
                <tr>
                  <td class="date_spec">
                    Date<br/>
                    Specialty
                  </td>
                  <td class="volunteerStaff" width="775px">
                  	Volunteer Staff 

                    <input type="button" class="floatRight ed_stdButton" value="Choose Tab" onclick="$('#tabOptions').toggle(); $(this).hide();" />
                    <span class="floatRight hide" id="tabOptions">
                    <cfoutput>
                    <select name="tabNum" class="floatRight" onChange="showScheduleTab($('select[name$=\'tabNum\']').val())">
                      <option value="#application.tabs.mdstaff#">Medical</option>
                      <option value="#application.tabs.PTstaff#">Physical Therapy</option>
                      <option value="#application.tabs.Socwork#">Social Work</option>
                      <option value="#application.tabs.intpub#">Interpreters/Public Health</option>
                      <option value="#application.tabs.mcoord#">Medical Coordinators</option>
                      <option value="#application.tabs.pcoord#">Physical Therapy Coordinators</option>
                   <!---   <option value="#application.tabs.ocoord#">Other Coordinators</option> --->
					 <option value="#application.tabs.pharmacy#">Pharmacy</option>
					 <option value="#application.tabs.phmcoord#">Pharmacy Coordinators</option>
					  <option value="#application.tabs.ncoord#">Nursing</option>
                    </select>
                    </cfoutput>
                    </span>
                    
                  </td>
                  <td>
                  	 NOTES
                  </td>
                </tr>
              </thead>
            
            <cfif dateQuery.recordCount lt 1>
            	<tr><td colspan="3" align="center">
                	<i>No Dates Are in Schedule <sub>(Maybe all in the past)</sub></i>
                </td></tr>
            <cfelse>
				<cfoutput>
                <cfset i=1>
                <cfloop query="dateQuery">
                    <cfif i gt 1 and curDate neq dateQuery.scheddate>
                      <tr class="dateSperator"><td colspan=3>&nbsp;</td></tr>
                    </cfif>
                    <tr class="shaded2<cfif i%2 eq 1><!---2---></cfif>" >
                      <td>
                        <a href="schedule.cfc?method=showSingleDayRoster&id=#dateQuery.schedule_id#">
                          #DateFormat(dateQuery.SCHEDDATE, "mm/d/yyyy")#<br/>
                        </a>
                        #dateQuery.Specialty#<br/>
                        <cfif isdefined("session.user.role") and session.user.role gte application.roles.MDAdmin >
                            <a href="schedule.cfc?method=addDate&id=#dateQuery.schedule_id#">Edit</a><br/>
                            <a href="schedule.cfc?method=deleteDate&id=#dateQuery.schedule_id#">Delete</a>
                        </cfif>
                      </td>
                      <td>
                        <cfset mtabs=createObject("component","elements.tabs")>
                        <cfset mtabs.init("volunteers"&i)>
                        <cfset mtabs.add("schedule.cfc?method=MSTab&id="&dateQuery.schedule_id,"Med Student","Medical"&i)>
                        <cfset mtabs.add("schedule.cfc?method=PTTab&id="&dateQuery.schedule_id,"Ph. Therapy","PhysicalTherapy"&i)>
                        <cfset mtabs.add("schedule.cfc?method=SWTab&id="&dateQuery.schedule_id,"Soc. Work","SocialWorkers"&i)>
                        <cfset mtabs.add("schedule.cfc?method=interpreterPHTab&id="&dateQuery.schedule_id,"Interps/Pub. Health","Interpreters"&i)>
                        <cfset mtabs.add("schedule.cfc?method=MCOORTab&id="&dateQuery.schedule_id,"MD/Resident","MedicalCoordinators"&i)>
                        <cfset mtabs.add("schedule.cfc?method=PTCOORTab&id="&dateQuery.schedule_id,"PT Coords","PhysicalTherapyCoordinators"&i)>
                      <!---  <cfset mtabs.add("schedule.cfc?method=OtherCOORTab&id="&dateQuery.schedule_id,"Othr Coords","DPT, Social Workers, and Public Health Coordinators"&i)> --->
                          <cfset mtabs.add("schedule.cfc?method=pharmacyTab&id="&dateQuery.schedule_id,"Pharmacy","Pharmacy"&i)>
						 <cfset mtabs.add("schedule.cfc?method=PHMCOORTab&id="&dateQuery.schedule_id,"Pharmacy Coords","Pharmacy Coordinators"&i)>
                        <cfset mtabs.add("schedule.cfc?method=NUCOORTab&id="&dateQuery.schedule_id,"Specialty","Nursing Coordinators"&i)>
						<cfset mtabs.selected = session.pageControl.schedule.tab>
                        <cfset mtabs.cache="false">
                        <cfset mtabs.render()>
                      
                      </td>
                      <td class="cutoff notes" onMouseOver="$(this).children('div').fadeIn(200)" onMouseOut="$(this).children('div').fadeOut(200)">#dateQuery.notes#<!---<cfif len(dateQuery.notes) gt 35>...<br/><br/><div class="notes hide" title="#dateQuery.notes#">#dateQuery.notes#</div></cfif>---></td>
                    </tr>
                    <cfset curDate=datequery.scheddate>
                    <cfset i=i+1>
                </cfloop>
                </cfoutput>
            </cfif>
            
            </table>
            
        </cfsavecontent>
        <cfset application.globaltemplate.render(main)>
	</cffunction>

	<!--------------------------------------------------------
	             RENDER SCHEDULE KEY                          
	------------------------------------------------------>
	<cffunction name="renderScheduleKey" access="private">
    	<div id="dumbo">
         <table class="floatRight" id="scheduleKeyLegend">
          <tr>
           <td>
            <ul class="scheduleKey">
              Schedule Key
              <li><div class="sampleColor notFullColor"></div>Positions available</li>
              <li><div class="sampleColor fullColor"></div>Alternate sign-up</li>
              <li><div class="sampleColor fullAltColor"></div>Group filled</li>
              <li><span class="redText"> * Alternate</span></li>
             <!---<sub>*View Full Notes by Mouse Over</sub>--->
            </ul>
           </td>
          </tr>
         </table>
        </div>
        <script type="text/javascript">
			  function moveDiv()
			  {
/*				  var tmp = $('#dumbo').html();
				  $('#dumbo').remove();
				  $('.banner').append(tmp);*/
				  initializeFloatingKey();
			  }
			  setTimeout('moveDiv()',1000);
		</script>
    </cffunction>

	<!--------------------------------------------------------
	             AJAX Function to set tab                     
	------------------------------------------------------>
	<cffunction name="setSelectedTab" access="remote">
    	<cfset session.pageControl.schedule.tab = form.selectedTab>
    </cffunction>

	<!--------------------------------------------------------
	             Add/edit Date                                
	------------------------------------------------------>
	<cffunction access="remote" name="addDate">
        <!--- Indicates a post back with updated info --->
    	<cfif isDefined("form.id")>
        
        	<cfset nuDate = form.newScheduleDate />
            
            <cfif form.specialty eq "OTH">
              <cfset mySpec = form.otherSpecialty>
            <cfelse>
              <cfset mySpec = form.specialty>
            </cfif>
            
            <!--- If id is predefined, we are updating, otherwise inserting --->
            <cfif form.id gt 0 >
            	<cfset application.dbprocs.callProc("upd_sched_date","#form.id#","#nuDate#","#mySpec#","#form.notes#")>
                <cfset dateID = form.id>
            <cfelse>
            	<cfset dateID =  application.dbprocs.callProc("ins_sched_date","#nuDate#","#mySpec#","#form.notes#")>
            </cfif>
        </cfif>

    	<!--- Indicates that this is editing a Date --->
		<cfif isDefined("url.id") and url.id gt 0>
        	<cfset schedDate = application.dbprocs.callProc("get_sched_date","#url.id#")>
            <!---<cfset volutineers = application.dbprocs.callProc("get_sched_vols","#url.id#")>--->
        <cfelse>
        	<!--- Set Default settings for data in form --->
        	<cfset schedDate = {}>
            <cfset schedDate.id=0>
            <cfset schedDate.schedule_id=0>
            <cfset schedDate.schedDate = now()>
            <cfset schedDate.specialty = "General">
            <cfset schedDate.notes = "">
            <cfset volunteers = []>
        </cfif>
    	
        <cfsavecontent variable="headContent">
        	<script type="text/javascript" src="/script/ui.datepicker-1.4.2.js"></script>
        	<script type="text/javascript">
			 	$(document).ready( function(){ setupNuDatePicker(new Date("<cfoutput>#dateFormat(schedDate.schedDate,'MM/DD/YYYY')#</cfoutput>"));
											});
				</script>
             <link rel="stylesheet" href="/bridge/css/schedule.css" type="text/css" />
        </cfsavecontent>
        
        <cfsavecontent variable="toolTip">
          <h1>Add/Edit Date</h1><br />
          &nbsp; &nbsp; In order to change the date, select the date input calendar box, which will show a calendar in order to select a day.  After choosing a month and year, you must select a day to finalize your date selection.  Then you can select a Specialty, add notes and save the events information.
          <br/><br/>
          <strong>Edit</strong><br />
          &nbsp; &nbsp; When editing a date, you will be presented with tabs giving information about the volunteers.  You can change the number of volunteers for the event, by changing the drop down menu and clicking <b>Update</b>.  To add a volunteer, begin typing their first or last name.  Their name should appear in drop down below, and you must select it from the drop down list.  It will then add them to the roster.
        </cfsavecontent>
        
    	<cfsavecontent variable="main">
       	  <cfoutput>
          
          <cfset createObject("component","components.tooltip").replaceMsg("#toolTip#")/>
      
          
          <cfif isDefined("nuDate")>
          	<cfset application.displaymsg.init("Date added Successfully.","3000","report")>
          	<cfset application.displaymsg.render()>
            <cflocation url="schedule.cfc?method=viewSchedule&msg">
          </cfif>
          
        	<fieldset>
        		<legend>Date Registration</legend>
                  <script src="scripts/schedule.js" type="text/javascript"></script>

                  <form method="post" onsubmit="return validateDateForm(this)">
                  <input type="hidden" name="id" value="#schedDate.schedule_id#" />
                
                    <fieldset>
                        <table><tr>
                          <td>
                            <div class="formField" style="z-index:1001;">
                                <label>Date</label>
                                <input name="newScheduleDate" type="text" align="left" id="newScheduleDate" class="date" readonly>
                                
                             </div>
                          </td>
                        </tr></table>
                    </fieldset>
                    
                    <fieldset>
                        <table><tr>
                          <td>
                            <div class="formField">
                              <label>Specialty</label>
                                <select name="specialty" value="#schedDate.specialty#" onchange="specialtyChanged(this)">
                          		  <option value="General" <cfif schedDate.specialty eq "General">selected</cfif> >General</option>
                          		  <option value="GI" <cfif schedDate.specialty eq"GI">selected</cfif>>GI</option>
                          		  <option value="GYN" <cfif schedDate.specialty eq"GYN">selected</cfif>>GYN</option>
                          		  <option value="OTH" <cfif schedDate.specialty neq"General" and schedDate.specialty neq "GI" and schedDate.specialty neq "GYN">selected</cfif>>Other</option>
                        		</select>
                                &nbsp;
                                <input type="text" name="otherSpecialty" <cfif schedDate.specialty eq 'General' or schedDate.specialty eq 'GI' or schedDate.specialty eq 'GYN'>class="hide"</cfif> value="" maxlength="30" />
                              </div>
                            </td>
                          </tr></table>
                       </fieldset>
                    
                    <fieldset>
                      <table><tr><td>
                        <div class="formField">
                          <label>Notes About Date</label>
                          <textarea name="notes" rows="3" cols="30" onKeyUp="notesChanged(this)">#schedDate.notes#</textarea>
                        </div>
                      </td><td>
                      	<div id="notesError" class="hide warning">
                        </div>
                      </td></tr></table>
                    </fieldset>
                    
                    <br/>
                    <fieldset>
                      <table><tr><td>
                        <div class="formField">
                          <input type="button" value="Cancel" onclick="cancelDate()" class="ed_stdButton" />
                          &nbsp; &nbsp; &nbsp; &nbsp;
                          <input type="submit" value="+ Save " onclick="dateSubmit()" class="ed_stdButton" />
                        </div>
                      </td></tr></table>
                    </fieldset>
                    
                    
        			<cfif schedDate.schedule_id gt 0>
                    
                    <table><tr><td>
                    <div class="msg_padding warning">
                      The following date details will be saved as you change them.
                    </div>
                    </td></tr></table>
                    
                    <cfset application.globaltemplate.addJS("jquery/jquery-ui-1.8.6.custom.min.js",request)>
                    <cfset application.globaltemplate.addcss("css/schedule.css",request)>
                    
                    <table><tr><td>
                    <cfset tabs = createObject("component","elements.tabs").init("scheduleTabs")>
                    <cfset tabs.add("schedule.cfc?method=showmedicaltab&id="&schedDate.schedule_id,"Medical","Medical Staff")>
                    <cfset tabs.add("schedule.cfc?method=showPhysicalTab&id="&schedDate.schedule_id,"Physical","Physical Therapy Staff")>
                    <cfset tabs.add("schedule.cfc?method=showSocialTab&id="&schedDate.schedule_id,"Social","Social Worker Staff")>
                    <cfset tabs.add("schedule.cfc?method=showInterpreterTab&id="&schedDate.schedule_id,"Interpreter","Interpreters")>
                    <cfset tabs.add("schedule.cfc?method=showPHTab&id="&schedDate.schedule_id,"Pub. Hlth","Public Health Staff")>
					          <cfset tabs.add("schedule.cfc?method=showPharmacyTab&id="&schedDate.schedule_id,"Pharmacy","Pharmacy Staff")>
          					<cfset tabs.add("schedule.cfc?method=showNursingTab&id="&schedDate.schedule_id,"Nursing","Nursing Staff")>
                    <cfset tabs.render(session.pageControl.schedule.edittab)>
                    </td></tr></table>
                    
                    </cfif>
                    
                  </form>
                </fieldset>
              </cfoutput>
        
    	</cfsavecontent>
		<cfset application.globaltemplate.render(main, headcontent) />    
    </cffunction>

	<!----------------------------------------------------------------
	                 Show Medical Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showMedicalTab" access="remote">
    				<cfset session.pageControl.schedule.editTab=0>
        	        <table><tr><td>
                    <cfset mtabs=createObject("component","elements.tabs")>
                    <cfset mtabs.init("MSchedule")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Medical12,"Med S. I/II","Medical12")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Medical34,"Med S. III/IV","Medical34")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Physician,"Physician","Physician")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Resident,"Resident","Resident")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.McoorPatient,"Patient Coord","MCoorPatient")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.McoorOperations,"Operations Coord","MCoorOperations")>
                    <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Mcoorstaff,"Staff Coord","MCoorStaff")>
                    <cfset mtabs.render(session.pagecontrol.schedule.editTab2[1])>
                    </td></tr></table>
    </cffunction>


	<!----------------------------------------------------------------
	                 Show PT   Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showPhysicalTab" access="remote">
    				<cfset session.pageControl.schedule.editTab=1>
			<table><tr><td>
            		<cfset mtabs2=createObject("component","elements.tabs")>
                    <cfset mtabs2.init("PSchedule")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Physical12,"DPT 1/2","Physical Therapy 12")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Physical23,"DPT 2/3","Physical Therapy 23")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Preceptor,"PT Preceptor","PT Preceptor")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.PTInterpreter,"PT Interp","PT Interpreter")>                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pcoorDirector,"Director","PT Director Coordinator")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pcoorstaff,"Staff Coord","PT Staff Coordinator")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pcoorOperations,"Operations Coord","PT Operations Coordinator")>
                    <cfset mtabs2.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pcoorPatient,"Patient Coord","PT Patient Coordinator")>
					<cfset mtabs2.render(session.pagecontrol.schedule.editTab2[2])>
                    </td></tr></table>
	</cffunction>

	<!----------------------------------------------------------------
	                 Show Soc   Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showSocialTab" access="remote">
			<cfset session.pageControl.schedule.editTab=2>
			<table><tr><td>
                    <cfset mtabs3=createObject("component","elements.tabs")>
                    <cfset mtabs3.init("SSchedule")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.SocialStudent,"Bachelor Student","Bachelor Student")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.swrMasterStudent,"Master Student","Master Student")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.swrDirector,"Social Director","Social Director")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.Sociallcsw,"Social(LCSW)","Social(LCSW)")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.scoorstaff,"SCoorStaff","SCoorStaff")>
                    <cfset mtabs3.render(session.pagecontrol.schedule.editTab2[3])>
                   </td></tr></table>
	</cffunction>
    
    
    <!----------------------------------------------------------------
	                 Show Interpreter   Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showInterpreterTab" access="remote">
			<cfset session.pageControl.schedule.editTab=3>
			<table><tr><td>
                    <cfset mtabs3=createObject("component","elements.tabs")>
                    <cfset mtabs3.init("ISchedule")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.interpreter,"Interpreter","Interpreter")>
                    <cfset mtabs3.render(session.pagecontrol.schedule.editTab2[4])>
					</td></tr></table>
	</cffunction>
    
    <!----------------------------------------------------------------
	                 Show PH   Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showPHTab" access="remote">
			<cfset session.pageControl.schedule.editTab=4>
            
			<table><tr><td>
                    <cfset mtabs3=createObject("component","elements.tabs")>
                    <cfset mtabs3.init("PHSchedule")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.phservice,"PH Student","Public Health Student")>
                    <cfset mtabs3.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.phcoord,"PH Coord.","Public Health Coordinator")>
                    <cfset mtabs3.render(session.pagecontrol.schedule.editTab2[5])>
					</td></tr></table>
	</cffunction>


	<!----------------------------------------------------------------
	                 Show Pharmacy Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showPharmacyTab" access="remote">
    				<cfset session.pageControl.schedule.editTab=5>
        	        <table><tr><td>
                    <cfset mtabs4=createObject("component","elements.tabs")>
                    <cfset mtabs4.init("PharmSchedule")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmPY1,"PY I/II","pharmPY1")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmPY2,"PY III/IV","pharmPY2")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmPharmD,"PharmD (Supervising Faculty)","PharmD (Supervising Faculty)")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmInptr,"Pharm Inptr","Pharmacy Interpreter")>
					<cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmcorDirector,"Director","Pharmacy Director Coordinator")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmcorStaff,"Staff Coord","Pharmacy Staff Coordinator")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmcorPatientCoordinator,"Patient Coord","Pharmacy Patient Coordinator")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.pharmcorOperations,"Operations Coord","Pharmacy Operations Coordinator")>
                    <cfset mtabs4.render(session.pagecontrol.schedule.editTab2[6])>
                    </td></tr></table>
    </cffunction>
	
	
	   <!----------------------------------------------------------------
	                 Show Nursing Tabs                                
	---------------------------------------------------------------->
    <cffunction name="showNursingTab" access="remote">
			<cfset session.pageControl.schedule.editTab=6>
            
			<table><tr><td>
                    <cfset mtabs4=createObject("component","elements.tabs")>
                    <cfset mtabs4.init("NSchedule")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.ncorARNPStudent,"ARNP Student","ARNP Student")>
                    <cfset mtabs4.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.id&"&designation="&application.scheduleDesignations.ncorARNPPreceptor,"ARNP Preceptor","ARNP Preceptor")>
                    <cfset mtabs4.render(session.pagecontrol.schedule.editTab2[7])>
			</td></tr></table>
	</cffunction>
	
	
	<!--------------------------------------------------------
	             Render Menu                            
	------------------------------------------------------>
    <cffunction access="private" name="renderMenu" >
      <cfset var ret="">
        <cfsavecontent variable="vol_signin_popup">
           <cfset loginpopup=createObject("component","components.popupwindow").init(
                                    title:"Volunteer Login",
                                    url:"volunteer.cfc?method=loginPopup",
                                    linkTitle:"Volunteer Sign-In",
                                    id:"volunteer_login")>                 
           <cfset loginpopup.render()>
        </cfsavecontent>
        <cfsavecontent variable="vol_register_popup">
            <cfset Registerpopup = createObject("component","components.popupwindow").init(
                            title:"Volunteer Registration",
                            url:"volunteer.cfc?method=register2",
                            linktitle:"Register as a Volunteer",
                            blockscreen:"1",
                            id:"volunteer_register_update")>
            <cfset  Registerpopup.render()>
        </cfsavecontent>
        
        <cfif isdefined("session.user.volunteerid")>
        <cfsavecontent variable="vol_update_popup">
            <cfset Registerpopup2 = createObject("component","components.popupwindow").init(
                            title:"Volunteer Registration Update",
                            url:"volunteer.cfc?method=register2&id="&session.user.volunteerid,
                            linktitle:"Update Volunteer Profile",
                            blockscreen:"1",
                            id:"volunteer_register_update") />
            <cfset Registerpopup2.render() />
        </cfsavecontent>
        </cfif>
        
        <cfscript>
        	if( isDefined("session.auth.isAuthenticated") and isDefined("session.user.Role"))
        	{
				if(application.roles.DVAdmin eq session.user.role
				or application.roles.MDAdmin eq session.user.role
				or application.roles.PHCoord eq session.user.role
				or application.roles.SWCoord eq session.user.role
				or application.roles.MDCoord eq session.user.role
				or application.roles.PHARMCoord eq session.user.role
				or application.roles.PTCoord eq session.user.role
				or application.roles.volunteer eq session.user.role
				)
				{
					ret = "<label><a href='schedule.cfc?method=addDate'>Add Date</a></label>"&ret;
				}

				if(application.roles.guest eq session.user.role)
				{
					ret = ret & '<label>' & vol_register_popup & '</label>';
					ret = ret & "<label>" & vol_signin_popup & "</label>";
				}
				
				if(isdefined("session.pagecontrol.schedule.viewpast") and session.pagecontrol.schedule.viewPast eq 0)
					ret = ret & '<label><a href="schedule.cfc?method=viewSchedule&viewPast=1">View Past Events</a></label>';
				else
					ret = ret & '<label><a href="schedule.cfc?method=viewSchedule&viewPast=0">View Upcoming Events Only</a></label>';
			}
			
		</cfscript>
        
        
        <cfreturn ret />    
    </cffunction>
    
    <!--------------------------------------------------------
	             Delete Date                                 
	------------------------------------------------------>
    <cffunction name="deleteDate" access="remote">
      <cfsavecontent variable="main" >
      	<cfif isDefined("url.id")>
        	<cfset res=application.dbprocs.callProc("del_sched_date2",url.id)>
        <cfelse>
        	<cfset res=0>
        </cfif>
        <cfif res gt 0>
        	<cfset application.displayMSG.init("Delete was successful","3000","report")>
        <cfelse>
        	<cfset application.displayMSG.init("Date Delete Failed.","3000","error")>
        </cfif>
        
        <cflocation url="schedule.cfc?method=viewSchedule&msg">
      </cfsavecontent>
	  <cfset application.globaltemplate.render(main)>
    </cffunction>
    
    <!--------------------------------------------------------
	             Add Volunteer                            
	------------------------------------------------------>
    <cffunction name="AddVolunteer" access="remote">
    	
		<cfset var ret = 0>
        
		
		<cfif isdefined("form.designation") and
		      isdefined("session.user.volunteerid") and
			  isDefined("form.scheduleid")>
        	<!---need to  add logic to add volunteer to schedule for the designation --->
            <cfset ret = application.dbprocs.callProc("ins_sched_volunteer2",form.scheduleid,session.user.volunteerid,form.designation)>
            <cfoutput>#ret#</cfoutput>
			
		 </cfif>
		
		<cfif ret gt 0 and ret neq 3>
           <cfset application.displayMSG.init("Added to schedule.","3000","warning")>
         <cfelseif ret eq 3>
            <cfset application.displayMSG.init("You are already scheduled for 2 events this month","3000","warning")>        
         <cfelse>
           <cfset application.displayMSG.init("Couldn't add to schedule. <Br/>Make sure that you aren't already scheduled.","5000","error")>
		   <cfset application.displaymsg.render()>
		   
		</cfif>
	
       <!--- <cflocation url="schedule.cfc?method=viewSchedule&msg">--->
         
    </cffunction>
    
    
     
    
    <!--------------------------------------------------------
	             Cancel Date                            
	------------------------------------------------------>
    <cffunction name="cancelDate" access="remote">
		<!---check if submitting this form --->
		
		<link href="jquery/jquery.autocomplete.css" rel="stylesheet" type="text/css">
		<script type="text/javascript" src="jquery/jquery.autocomplete.min.js"></script>
		
		<cfif isDefined("form.schedule_id") and
			  isDefined("form.volunteer_id") and isDefined("form.substitute_volunteer_id")>
              <cfset tmp = application.dbprocs.callproc("ins_cancel_date",form.schedule_id,session.user.volunteerid,form.alt_fname,form.alt_lname,form.alt_phone,form.substitute_volunteer_id)>
              <!---<cflocation url="schedule.cfc?method=viewSchedule">--->
              <cfabort />
        </cfif>
		
		<!--- variable to know whether the volunteer is medical or interpreter and accordingly show message --->
		<cfset this.two_week_window = 0>
        
       <cfset application.globaltemplate.addJS('scripts/schedule.js',request)>
        <cfoutput>
        
        <!--- Make database requests schedule date and volunteer info--->
		<cfset schedule_id = url.schedule_id>
        <cfset volunteer_id = session.user.volunteerid>
		<cfset scheduled_date = application.dbprocs.callproc("get_sched_date",schedule_id)>
        <cfset sched_volunteer = application.dbprocs.callproc("get_volunteer",volunteer_id)>
        
        <!--- Not Required for Preceptors, Doctors, residents, PharmD and Licensed Social worker --->
        <cfif session.user.affiliation eq application.affiliations.physician or
		      session.user.affiliation eq application.affiliations.resident or
			  session.user.affiliation eq application.affiliations.pharmd or
			  session.user.affiliation eq application.affiliations.sociallcsw or
			  session.user.affiliation eq application.affiliations.preceptor>
              <cfset this.required = 0 >
        <cfelse>
            <!---normalize the dates and check for 2 weeks window for medical students and interpreters and for others window is 48 hour --->
			<cfset curDate = dateAdd("h",-hour(now()),now()) />
        	<cfset schdDate = dateAdd("h",-hour(scheduled_date.scheddate),scheduled_date.scheddate)>
        	<cfset dateDifference = DateDiff('d',curDate,schdDate)>
			<!--- adding a check for medical students and interpreters --->
			<cfif session.user.affiliation eq application.affiliations.medical or
		      session.user.affiliation eq application.affiliations.interpreter>
			  <!--- if the volunteer is medical student or interpreter then window is 14 days)--->
				 <cfif  dateDifference gte 0 and datedifference lt 14>
					<cfset this.required = 1>
					<cfset this.two_week_window = 1>
				<cfelse>
					<cfset this.required = 0>
				</cfif>
			 <cfelse>
				<cfif  dateDifference gte 0 and datedifference lt 2>
					<cfset this.required = 1>
				<cfelse>
					<cfset this.required = 0>
				</cfif>
				
							 
			</cfif>
			</cfif>
        
        
        <!---Draw the form and fill --->
          <div id="Bridge">
		  
		
		
		<!---including the JS files --->
		
		
		<script type="text/javascript" src="scripts/cancel_volunteer.js"></script>
		
		 
          <form class="bridge" method="post" action="<!---schedule.cfc?method=cancelDate--->" onsubmit="return false; validateCancelDate()" >
            <input type="hidden" value=<cfif this.required >"1"<cfelse>"0"</cfif> name="required">
			<input type="hidden" value=<cfif this.two_week_window>"1"<cfelse>"0"</cfif> name="two_week_window">
			
			
            <input type="hidden" name="volunteer_id" value="#volunteer_id#">
            <input type="hidden" name="schedule_id" value="#schedule_id#">
            <input type="hidden" name="popup_id" value="<cfif isDefined("form.popup_id")>#form.popup_id#</cfif>" />
            <!---<a href="" onclick="testValidate(); return false;">validate</a>--->
            <!--- variable to store the volunteer id of substitute when we cancel--->
			<input type="hidden" id="substitute_volunteer_id" name="substitute_volunteer_id" value="">
			
              <table><tr><td class="top">
              <fieldset class="Bridge">
              <legend>Volunteer Cancelling</legend>
              <table><tr>
                <td>
                  <label class="indent"> #sched_volunteer.lname#, #sched_volunteer.fname# <cfif #sched_volunteer.spanish# eq '1' >- S</cfif> </label>
                </td>
              </tr></table>
              </fieldset>
              </td>
              <td>
              
              <fieldset>
              <legend>Date Being Cancelled</legend>
              <table><tr>
                <td>
                  <label class="indent">#DateFormat(scheduled_date.schedDate, "mmm. d, yyyy")#  (#DateFormat(scheduled_date.schedDate, "mm/d/yyyy")#)</label>
                  <label class="indent">Specialty: #scheduled_date.specialty#</label>
                </td>
              </tr></table>
              </fieldset>
              </td></tr></table>
            
            <table><tr><td>
              <cfif this.required>
                <div class="error  formField msg_padding">
					<cfif this.two_week_window>
						REQUIRED when within 2 weeks of the scheduled date.
					<cfelse>
						REQUIRED when within 48 hours of the scheduled date.
				  </cfif>
                </div>
              <cfelse>
            	<div class="report formField msg_padding">
               	  Optional
            	</div>
              </cfif>
            </td></tr>
            <tr><td>
              <div class="formField">
                Below you can specify a replacement for your cancellation.
              </div>
            </td></tr></table>
            
            <br/>
            
            <fieldset>
               <legend>Alternate</legend>
            	<table><tr>
                  <td>
            		<div class="formField">
            			<label>First Name </label>
                		<input type="text" name="alt_fname" id="txtFirstName" size="30" maxlength="60" value="" placeholder="John" />
            		</div>
                  </td><td>
                  	<div class="formField">
					
            			<label>Last name</label>
                		<input type="text" name="alt_lname" id="txtLastName" size="30" maxlength="60" value="" placeholder="Doe" />
            		</div>
                  </td>
                </tr>
            	<tr>
                  <td>
            		<div class="formField">
            			<label>Phone</label>
                		<input type="text" name="alt_phone" id="txtPhone" size="30" maxlength="12" value="" placeholder="813-555-5555" />
            		</div>
                  </td><td>
                  	<div class="formField">
                    	
            		</div>
                  </td>
                </tr>
                <tr>
                  <td>
                    <div class="formField">
                    </div>
                  </td>
                  <td>
                    <div class="formField">
                      <input type="button" class="ed_stdButton" value="Confirm" onclick="submitCancellation('<cfif isDefined("form.popup_id")>#form.popup_id#</cfif>');" />
                    </div>
                  </td>
                </tr>
                </table>
            </fieldset>
           </form>
           </div>
         </cfoutput>
        
    </cffunction>
    
	<!------------------------------------------------------
	          Function to get Volunteer details                        
	------------------------------------------------------>
	 <cffunction name="getVolunteersByFirstName" access="remote">
    	<cfset data =application.dbprocs.callproc("get_volunteer_auto_fname",url.q)>
        <cfset NL = CreateObject("java", "java.lang.System").getProperty("line.separator")>
        <cfset dataout = []>
		<cfloop query="data">
          <cfoutput>
            #data.fname#|#data.lname#|#data.phone#|#data.volunteer_id# |#data.email# #NL#
  		  </cfoutput>
		</cfloop>
        
    </cffunction>
	<cffunction name="getVolunteersByLastName" access="remote">
    	<cfset data =application.dbprocs.callproc("get_volunteer_auto_lname",url.q)>
        <cfset NL = CreateObject("java", "java.lang.System").getProperty("line.separator")>
        <cfset dataout = []>
		<cfloop query="data">
          <cfoutput>
            #data.fname#|#data.lname#|#data.phone#|#data.volunteer_id# |#data.email# #NL#
  		  </cfoutput>
		</cfloop>
        
    </cffunction>
    
    <!------------------------------------------------------
	          Show Single Day Roster                        
	------------------------------------------------------>
    <cffunction name="showSingleDayRoster" access="remote">
        <cfsavecontent variable="main">
        	<cfset showSingleDayRoster2()>
    	</cfsavecontent>
        <cfset application.globaltemplate.render(main)>
    </cffunction>
    
    <!-----------------------------------------------------------
	                 Show single day roster printable            
	------------------------------------------------------------>
    <cffunction name="showSingleDayRosterPrintable" access="remote">
      <html><head><title>Printable Roster</title>
        
       <link type="text/css" href="/bridge/css/site.css" rel="stylesheet" />
       <link type="text/css" href="/bridge/css/schedule.css" rel="stylesheet" />
       <script type="text/javascript" src="jquery/jquery.js"></script>
	   <script type="text/javascript" src="scripts/site.js"></script>
	   <script type="text/javascript" src="scripts/schedule.js"></script>
      </head>
      <body>
       <div class="banner">
       </div>
       <div id="Bridge">
       	<cfset showSingleDayRoster2("YES")>
       </div>
      </body>
      </html>
    </cffunction>
    
    <!------------------------------------------------------
	          Show Single Day Roster2 outputs raw data      
	          to be displayed as desired.                    
	-------------------------------------------------------->
    <cffunction name="showSingleDayRoster2" access="private">
        <cfargument name="hideExtra" default="" />
        
    	<cfset var event_id = '0'>
        <cfif isDefined("url.id")>
          <cfset event_id=url.id>
        </cfif>
		
        <cfset application.globaltemplate.addJS('scripts/schedule.js',request) />
        <cfset application.globaltemplate.addCSS('css/schedule.css',request) />
        <cfset cur_date = application.dbprocs.callProc('get_sched_date',event_id)>
        
        <cfset renderScheduleKey() />
        
        <cfif isdefined("hideExtra") and hideExtra neq "">
        	<label><a href="" onclick="window.print(); return false;">Print Roster</a></label>
        	<label><a href="" onclick="window.close(); return false;">Close Window</a></label>
            <label><a href="" onmouseOut="$('#printingHelpDiv').hide()" onclick="$('#printingHelpDiv').toggle(); return false;">Help with Printing</a></label>
            <div onmouseOut="$('#printingHelpDiv').hide()" id="printingHelpDiv" class="hide" style="width:350px; position:absolute; background-color:#6FC; z-index:1999; border:double 2px; padding:10px;">
              &nbsp; By Default, most browsers are set to not print background colors.  Therefore,
               when you try to print this schedule, you may get a plain white schedule printout,
               without any color coding.  If you desire to see the color coding on the printout,
               you need to go into the settings of your browser and select to print out background
               colors.
            </div>
        <cfelse>
           <label><a href="schedule.cfc?method=viewSchedule">Back to schedule</a></label>
           <cfoutput>
           <label><a href="schedule.cfc?method=showSingleDayRosterPrintable&id=#url.id#" target="_blank">Printable</a></label>
           </cfoutput>
        </cfif>

        <br/>
           <table class="Bridge" width="640px">
             <thead>
               <tr><td>
                 Specialty : <cfoutput>#cur_date.specialty#</cfoutput>
                 <span class="floatRight"><cfoutput>#DateFormat(cur_date.schedDate,"DDDD, MMMM d, yyyy")#</cfoutput></span>
               </td></tr>
               <tr><td>
                 Notes: <cfoutput>#cur_date.notes#</cfoutput>
               </td></tr>
             </thead>
            
           <tr><td>
            <strong>Medical</strong>
            <div id="medicalStaff" class="rosterView"></div>
            <br/>
            <strong>Physical Therapy</strong>
            <div id="ptStaff" class="rosterView"></div>
            <br/>
            <strong>Social Work</strong>            
            <div id="swStaff" class="rosterView"></div>
            <br/>
            <strong>Interpreters/Public Health Screeners</strong>            
            <div id="inPHstaff" class="rosterView"></div>
            <br/>
            <strong>Medical Coordinators</strong>
            <div id="medCoord" class="rosterView"></div>
            <br/>
            <strong>Physical Therapy Coordinators</strong>
            <div id="ptCoord" class="rosterView"></div>
            <br/>
           <!---> <strong>Other Coordinators</strong>
            <div id="othCoord" class="rosterView"></div>
			<br/> --->
			  <strong>Pharmacy</strong>
            <div id="pharmacy" class="rosterView"></div>
			<br/>
            <strong>Pharmacy Coordinators</strong>
            <div id="phmCoord" class="rosterView"></div>
			<br/>
            <strong>Nursing</strong>
            <div id="nuCoord" class="rosterView"></div>
          </td></tr></table>
            
            <cfoutput>
            <script type="text/javascript">
              fillDivWithData("medicalStaff","schedule.cfc?method=MSTab&id=#event_id#&rosterview=1");
              fillDivWithData("ptStaff","schedule.cfc?method=PTTab&id=#event_id#&rosterview=1");
              fillDivWithData("swStaff","schedule.cfc?method=SWTab&id=#event_id#&rosterview=1");
              fillDivWithData("inPHstaff","schedule.cfc?method=interpreterPHTab&id=#event_id#&rosterview=1");
              fillDivWithData("medCoord","schedule.cfc?method=MCOORTab&id=#event_id#&rosterview=1");
			  fillDivWithData("ptCoord","schedule.cfc?method=PTCOORTab&id=#event_id#&rosterview=1");
             <!--- fillDivWithData("othCoord","schedule.cfc?method=OtherCOORTab&id=#event_id#&rosterview=1"); --->
			  fillDivWithData("pharmacy","schedule.cfc?method=pharmacyTab&id=#event_id#&rosterview=1");
              fillDivWithData("phmCoord","schedule.cfc?method=PHMCOORTab&id=#event_id#&rosterview=1");
              fillDivWithData("nuCoord","schedule.cfc?method=NUCOORTab&id=#event_id#&rosterview=1");
            </script>
            <br /><br />
           </cfoutput>
    </cffunction>
    
    
    
    
    
    
    
    <!---<cffunction name="testemail" access="remote">
    	<cfset data = application.dbprocs.callProc("send_mail_Admin_empty_slots")>
        <cfoutput>#data#</cfoutput>
    </cffunction>--->
    <!----------------------------------------------------------------------------
	                             Generate Volunteer Btn                           
	---------------------------------------------------------------------------->
    <cffunction name="generateVolunteerBtn" access="private">
      <cfargument name="designation" default="#application.scheduleDesignations.medical34#">
      <cfargument name="schedule_id" required="yes">
      <cfoutput>
      				<!---<form class="bridge" method="post" action="schedule.cfc?method=AddVolunteer">
	                  <input type="hidden" name="scheduleid" value="#arguments.schedule_id#" />
	                  <input type="hidden" name="designation" value="#designation#">
    	          	  <input type="submit" value=" Sign Me Up " class="ed_stdButton_small">
                    </form>--->
                 <cfif isDefined("url.rosterview")>
          			<cfreturn />
        		 </cfif>
                 <a href="##" onclick="AddVolunteerByVol(this,#arguments.schedule_id#,#arguments.designation#)"><img src="image/icon-48x48-person_add.png" class="noborder" alt="Add Volunteer" /> Add Me </a>
      </cfoutput>
    </cffunction>
    
    <!----------------------------------------------------------------------------
	                             Generate Cancel Button                           
	---------------------------------------------------------------------------->
    <cffunction name="generateCancelBtn" access="private">
      <cfargument name="schedule_id" required="yes" />
      <cfargument name="vol_id" default="0999" />
      <cfoutput>
        <cfif isDefined("url.rosterview")>
          <cfreturn />
        </cfif>
        <cfif isdefined("session.user.volunteerid")>
        	<cfset popup = createObject("component","components.popupwindow").init(id:"popup#schedule_id#",
																		  title:"Volunteer Cancellation",
																		  arguts:"{popup_id : 'popup#schedule_id#'}",
																		  url:"schedule.cfc?method=cancelDate&schedule_id=#schedule_id#",
																		  button:"<span title='Cancel My Volunteer'><img class='noborder' src='image/cross.png' alt='X' /></span>",
																		  blockscreen:1)>
            <cfset popup.render()>
        <cfelse>
        	<a href="javascript:void()" style="line-height:24px; left:11px;" onclick="removeVolunteer(this,'#arguments.schedule_id#','#arguments.vol_id#');"><img class="noborder" src="image/cross.png" alt="X" /></a>
        	<!---<a href="javascript:void()" onclick="removeVolunteer(this,'#arguments.schedule_id#','#arguments.vol_id#');"><span title='Cancel Volunteer'>[x]</span></a>--->
        </cfif>
      	<!---<a href="schedule.cfc?method=cancelDate&schedule_id=#schedule_id#" title="Cancel Volunteer">[x]</a>--->
      </cfoutput>
    </cffunction>
    
    <!----------------------------------------------------------------------------
	                             Generate Admin Add Button                        
	---------------------------------------------------------------------------->
    <cffunction access="private" name="generateAdminAdd" >
        <cfargument name="designation" default="">
        <cfargument name="sched_id" default="">
        			<cfif isDefined("url.rosterview")>
          				<cfreturn />
        			</cfif>
        			<cfoutput>
                      <div id="div#arguments.sched_id&arguments.Designation#" class="popupWindow volunteerNameField" >
                       <font class="titletext">Add Volunteer</font><br>
                       <div class="closeBtn" onclick="$('##div#arguments.sched_id&arguments.Designation#').hide()" ></div>
                       <div id="updatewindow">
                         <div id="popup_content">
                           <cfset getAutoCompleteForDes(designation:"#arguments.Designation#", schedule_id:"#arguments.sched_id#")>
                         </div>                          
                       </div>
                     </div>
                     
                     <a href="" onclick="return showAdminAddDiv('div#arguments.sched_id&arguments.designation#');">
                     <img src="image/icon-48x48-person_add.png" class="noborder" alt="Add Volunteer" />
                     <span style="line-Height:24px; position:relative; left:5px; top:-5px;">Add Volunteer</span></a>        
    			  </cfoutput>
    </cffunction>
    
    <!----------------------------------------------------------------------------
	                             Generate None for volunteers                       
	---------------------------------------------------------------------------->
    <cffunction access="private" name="generateNone" >
       <span class="indicateNone">None! </span>
    </cffunction>

    
    <!----------------------------------------------------------------------------
	                             Medical Staff Tab                            
	---------------------------------------------------------------------------->
    <cffunction name="MSTab" access="remote">

		<cfscript>
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		if(IsDate(schedDateQuery.scheddate ))
				isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;

		//set default tab
		if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.mdstaff;
		
		 //check for volunteer and set variables
		if(isDefined("session.user.myyear"))
		{
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		}else{
            isVolunteered = 1;
            desList = "";
		}
		  
		if(isdefined("session.user.role"))
		{
		  if(session.user.role gte application.roles.MDAdmin)
		  	isAdminUser = 1;
		  else{
			  if(session.user.role eq application.roles.MDCoord)
			      isAdminUser = 1;
		  }
		}
		  

		  //<!--- get the designation counts for each position for the week ---->
		   ms12limit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.Medical12);
           ms34limit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.Medical34);
           
         
    	  //<!--- Get the volunteers for each position for the week --->
          ms12vols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.Medical12);
          ms34vols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.Medical34);
          
        
		  //check what designations are full
		  ms12full = ms12vols.recordcount gte ms12limit;//one for alternate
		  ms12max = ms12vols.recordcount gte (ms12limit + 1);
		  ms34full = ms34vols.recordcount gte ms34limit;//one for alternate
		  ms34max = ms34vols.recordcount gte (ms34limit + 1);//one for alternate

//		  pharmfull = pharmvols.recordcount gte pharmlimit;
		</cfscript>
        
        <cfoutput>
        <cfset gy = createObject("component","components.gradYear")>

        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr>
              <td width="50%">
                 MS I/II (#ms12limit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.medical12#">edit</a>
                 </cfif>
              </td>
              <td width="50%"> 
                MS III/IV (#ms34limit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.medical34#">edit</a>
                 </cfif>
              </td>

		</tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
              <td <cfif ms12max>class="shaded2"<cfelse><cfif ms12full>class="shaded"</cfif></cfif>>
                <cfif ms12vols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="ms12vols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  ms12vols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,ms12vols.f_volunteer_id)>
                  </cfif>
                    <cfif ms12vols.currentrow eq ms12vols.recordcount and ms12max><span class="redText"></cfif>
                    -#ms12vols.lname#, #ms12vols.fname#, <cfif #ms12vols.spanish# eq '1'>- S</cfif> #gy.renderGradYear(gy.init(application.affiliations.medical,ms12vols.gradyear))# 
                    <cfif ms12vols.currentrow eq ms12vols.recordcount and ms12max>*</span></cfif>
                    <br/>
                    
                </cfloop>
              	
              </td>
              <td <cfif ms34max>class="shaded2"<cfelse><cfif ms34full>class="shaded"</cfif></cfif>>
                <cfif ms34vols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="ms34vols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  ms34vols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,ms34vols.f_volunteer_id)>
                  </cfif>
                  	<cfif ms34vols.currentrow eq ms34vols.recordcount and ms34max><span class="redText"></cfif>
                    -#ms34vols.lname#, #ms34vols.fname# <cfif  #ms34vols.spanish# eq '1'> - S</cfif> #gy.renderGradYear(gy.init(application.affiliations.medical,ms34vols.gradyear))# 
                    <cfif ms34vols.currentrow eq ms34vols.recordcount and ms34max>*</span></cfif><br/>
                    
                </cfloop>
                
              </td>
   </tr>
            </cfoutput>
            
            <cfif not isDatePast gt 0 and not isdefined("url.rosterview")>
              <!--- Add option for a volunteer to add his/her name to the volunteer list --->
				<cfif isVolunteered lt 1 and (not isDatePast)>
                  <tr><td class="noborder">
                      <cfif  not ms12max and listfind(desList,application.scheduleDesignations.medical12)>
                        <cfset generateVolunteerBtn(application.scheduleDesignations.medical12,url.id)>
                      </cfif>
                  </td><td class="noborder">
                      <cfif  not ms34max and listfind(desList,application.scheduleDesignations.medical34)>
                        <cfset generateVolunteerBtn(application.scheduleDesignations.medical34,url.id)>
                      </cfif>
     </tr>
                </cfif>
                
              <!---Give option for the administrator to add users --->
				<cfif isAdminUser>
                  <tr><td class="noborder">
                      <cfif not ms12max>
                         <cfset generateAdminAdd(designation:application.scheduleDesignations.medical12, affiliation:application.affiliations.medical, sched_id:url.id)>
                      </cfif>
                    </td><td class="noborder">
                      <cfif not ms34max>
                        <cfset generateAdminAdd(designation:application.scheduleDesignations.medical34, affiliation:application.affiliations.medical, sched_id:url.id)>
                      </cfif>
                    </td>
			</tr>
                </cfif>
              </cfif>  
            
          </tbody>
        </table>
        </cfoutput>
            
    </cffunction>
    
    
    
    
    
    <!----------------------------------------------------------------
	                      Physical Therapy Tab
	----------------------------------------------------------------->
    <cffunction name="PTTab" access="remote">
    	
        <cfscript>
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  if(IsDate(schedDateQuery.scheddate ))
				isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.ptstaff;
		  
		  
		  if(isdefined("session.user.role"))
		  {
		  	  if(session.user.role gte application.roles.MDAdmin)
		      	isAdminUser = 1;
			  else{
				  if(session.user.role eq application.roles.PTCoord)
				      isAdminUser = 1;
			  }
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
		  pt12limit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.physical12);
          pt23limit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.physical23);
		  prelimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.Preceptor);
    	  intLimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.PTInterpreter);
		  
    	  //<!--- Get the volunteers for each position for the week --->
          pt12vols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.physical12);
          pt23vols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.physical23);
          prvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.Preceptor);
		  intvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.PTInterpreter);
          
		  //check what designations are full
		  pt12full = pt12vols.recordcount gte pt12limit;//one for alternate
		  pt12max = pt12vols.recordcount gte (pt12limit+1);
		  pt23full = pt23vols.recordcount gte pt23limit;//one for alternate
		  pt23max = pt23vols.recordcount gte (pt23limit+1);
		  prfull = prvols.recordcount gte prelimit;
		  intfull = intvols.recordcount gte intlimit;
		</cfscript>
        
        <cfoutput>
        <cfset gy = createObject("component","components.gradYear")>

        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr>
              <td width="25%">
                 DPT I/II (#pt12limit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.physical12#">edit</a>
                 </cfif>
              </td>
              <td width="25%"> 
                DPT II/III (#pt23limit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.physical23#">edit</a>
                 </cfif>
              </td>
              <td width="25%">
               Preceptors (#prelimit#)
               <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.Preceptor#">edit</a>
               </cfif>
              </td>
              <td width="25%">
                PT Inptr (#intLimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.PTInterpreter#">edit</a>
                 </cfif>
              </td>
            </tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
              <td <cfif pt12max>class="shaded2"<cfelse><cfif pt12full>class="shaded"</cfif></cfif>>
                <cfif pt12vols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="pt12vols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  pt12vols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,pt12vols.f_volunteer_id)>
                  </cfif>
                  <cfif pt12vols.currentrow eq pt12vols.recordcount and pt12max><span class="redText"></cfif>
                    -#pt12vols.lname#, #pt12vols.fname# <cfif  #pt12vols.spanish# eq '1'>- S</cfif> #gy.renderGradYear(gy.init(application.affiliations.physical,pt12vols.gradyear))#
                  <cfif pt12vols.currentrow eq pt12vols.recordcount and pt12max>*</span></cfif>
                  <br/> 
                </cfloop>
              	
              </td>
              <td <cfif pt23max>class="shaded2"<cfelse><cfif pt23full>class="shaded"</cfif></cfif>>
                <cfif pt23vols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="pt23vols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  pt23vols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,pt23vols.f_volunteer_id)>
                  </cfif>
                  <cfif pt23vols.currentrow eq pt23vols.recordcount and pt23max><span class="redText"></cfif>
                    -#pt23vols.lname#, #pt23vols.fname# <cfif  #pt23vols.spanish# eq '1'>- S</cfif> #gy.renderGradYear(gy.init(application.affiliations.physical,pt23vols.gradyear))# 
                  <cfif pt23vols.currentrow eq pt23vols.recordcount and pt23max>*</span></cfif><br/>
                  <br/>
                </cfloop>
                
              </td>
              <td <cfif prfull>class="shaded2"</cfif>>
                <cfif prvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="prvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  prvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,prvols.f_volunteer_id)>
                  </cfif>
                    -#prvols.lname#, #prvols.fname# <cfif  #prvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>

              </td>
              
              <td <cfif intfull>class="shaded2"</cfif>>
                <cfif intvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="intvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  intvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,intvols.f_volunteer_id)>
                  </cfif>
                    -#intvols.lname#, #intvols.fname#  <cfif #intvols.spanish# eq '1'>- S</cfif>  <br/>
                </cfloop>

              </td>
              
            </tr>
            </cfoutput>
            
            <cfif isDatePast lt 1 and not isdefined("url.rosterview")>
              <!--- add option for volunteer to register --->
              <cfif isVolunteered lt 1>
              <tr><td class="noborder">
                  <cfif  not pt12full and listfind(desList,application.scheduleDesignations.physical12)>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.physical12,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not pt23full and listfind(desList,application.scheduleDesignations.physical23)>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.physical23,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not prfull and  listfind(desList,application.scheduleDesignations.Preceptor)>
					<cfset generateVolunteerBtn(application.scheduleDesignations.Preceptor,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not intfull>
					<cfset generateVolunteerBtn(application.scheduleDesignations.PTInterpreter,url.id)>
                  </cfif>
              </td></tr>
              </cfif>
            
              <!---Add options for the admin users --->
              <cfif isAdminUser gt 0>
              <tr><td class="noborder">
                  <cfif not pt12max>
                     <cfset generateAdminAdd(designation:application.scheduleDesignations.physical12, affiliation:application.affiliations.physical, sched_id:url.id)>
				  </cfif>
                </td><td class="noborder">
                  <cfif not pt23max>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.physical23, affiliaton:application.affiliations.physical, sched_id:url.id)>
				  </cfif>
                </td><td class="noborder">
                  <cfif not prfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.Preceptor, affiliation:application.affiliations.Preceptor, sched_id:url.id)>                 
				   </cfif>
                </td><td class="noborder">
                  <cfif not intfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.PTInterpreter, affiliation:application.affiliations.Interpreter, sched_id:url.id)> 
				  </cfif>
                </td></tr>
                </cfif>
              </cfif>

          </tbody>
        </table>
        </cfoutput>
            
    </cffunction>
    
    
    <!----------------------------------------------------------------
	                      SocialWorker Tab
	----------------------------------------------------------------->
    <cffunction name="SWTab" access="remote">
    	<cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  if(IsDate(schedDateQuery.scheddate ))
			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
        	 desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.Socwork;
			
		  if(isdefined("session.user.role"))
		  {
		  	  if(session.user.role gte application.roles.MDAdmin)
		      	isAdminUser = 1;
			  else{
				  if(session.user.role eq application.roles.SWCoord)
				      isAdminUser = 1;
			  }
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
		  swlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.socialstudent); 
          swMasterLimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.swrMasterStudent);
		  swDirectorLimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.swrDirector);
          swlcswlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.socialLCSW);
    
    	  //<!--- Get the volunteers for each position for the week --->
          swvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.socialstudent);
		  swMastervols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.swrMasterStudent);
		  swDirectorvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.swrDirector);
          swlcswvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.socialLCSW);
          
		  //check what designations are full
		  swfull = swvols.recordcount gte swlimit;//one for alternate
		  swMasterfull = swMastervols.recordcount gte swMasterLimit;
		  swDirectorfull = swDirectorvols.recordcount gte swDirectorLimit;
		  swlcswfull = swlcswvols.recordcount gte swlcswlimit;//one for alternate
		</cfscript>
        
        <cfoutput>
				  
        <cfset gy = createObject("component","components.gradYear")>

        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr><td width="25%">
                 BSW Students (#swlimit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.socialstudent#">edit</a>
                 </cfif>
              </td><td width="25%"> 
                MSW Students (#swMasterLimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.swrMasterStudent#">edit</a>
                 </cfif>
            </td><td width="25%"> 
                Director (#swDirectorLimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.swrDirector#">edit</a>
                 </cfif>
            </td><td width="25%"> 
                LCSW (#swlcswlimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.sociallcsw#">edit</a>
                 </cfif>
            </td></tr>
          </thead>

          <tbody>
            <cfoutput>
            <tr>
              <td <cfif swfull>class="shaded2"</cfif>>
                <cfif swvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,swvols.f_volunteer_id)>
                  </cfif>
                    #swvols.lname#, #swvols.fname# <cfif  #swvols.spanish# eq '1'>- S</cfif><br/>
                </cfloop>
              	
              </td>
              <td <cfif swMasterfull>class="shaded2"</cfif>>
                <cfif swMastervols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swMastervols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swMastervols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,swMastervols.f_volunteer_id)>
                  </cfif>
                    #swMastervols.lname#, #swMastervols.fname# <cfif  #swMastervols.spanish# eq '1'>- S</cfif><br/>
                </cfloop>
              	
              </td>
              <td <cfif swDirectorfull>class="shaded2"</cfif>>
                <cfif swDirectorvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swDirectorvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swDirectorvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,swvols.f_volunteer_id)>
                  </cfif>
                    #swDirectorvols.lname#, #swDirectorvols.fname# <cfif  #swDirectorvols.spanish# eq '1'>- S</cfif><br/>
                </cfloop>
              	
              </td>
              <td <cfif swlcswfull>class="shaded2"</cfif>>
                <cfif swlcswvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swlcswvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swlcswvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,swlcswvols.f_volunteer_id)>
                  </cfif>
                    #swlcswvols.lname#, #swlcswvols.fname# <cfif  #swlcswvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>
                
              </td>
            </tr>
            </cfoutput>
            
		  <cfif not isDatePast and not isdefined("url.rosterview")>
            <!---add volunteer controls --->
			<cfif isVolunteered lt 1>
              <tr><td class="noborder">
                  <cfif  not isDatePast and not swfull and listfind(desList,application.scheduleDesignations.socialstudent)>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.socialstudent,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not isDatePast and not swMasterfull and listfind(desList,application.scheduleDesignations.swrMasterStudent)>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.swrMasterStudent,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not isDatePast and not swDirectorfull and listfind(desList,application.scheduleDesignations.swrDirector)>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.swrDirector,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not isDatePast and not swlcswfull and listfind(desList,application.scheduleDesignations.sociallcsw)>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.sociallcsw,url.id)>
                  </cfif>
              </td></tr>
            </cfif>

            <!--- Add Administrator controls --->
            <cfif isAdminUser>
              <tr><td class="noborder">
                  <cfif not swfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.socialstudent,affiliation:application.affiliations.social,sched_id:url.id)>
	              </cfif>
                </td><td class="noborder">
                  <cfif not swMasterfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.swrMasterStudent,affiliation:application.affiliations.social,sched_id:url.id)>
	              </cfif>
                </td><td class="noborder">
                  <cfif not swDirectorfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.swrDirector,affiliation:application.affiliations.sociallcsw,sched_id:url.id)>
	              </cfif>
                </td><td class="noborder">
                  <cfif not swfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.socialLCSW,affiliation:application.affiliations.sociallcsw,sched_id:url.id)>
	              </cfif>
              </td></tr>
              </cfif>
            </cfif>
            
          </tbody>
        </table>
        </cfoutput>
            
    </cffunction>
	
  <cfset this.PHARMACY_TAB = 'pharmacy'>
  <cfset this.PHARMACY_COORD_TAB = 'pharmacycoord'>
  <Cfset this.NURSING_COORD_TAB = 'nursingcoord'>
	<cffunction name="renderDesignationTab" output="yes">
		<cfargument name="designationsList" required="yes">
		<cfargument name="designationsNamesList" required="yes">
    <cfargument name="tabID" required="yes" hint="one of pharmacy, pharmacycoord, nursingcoord">
	<cfscript>
  		var designationsData = [];
		  var isDatePast = false;
		  var isAdminUser = false;
		  var isVolunteered = true;
		  var desList = '';
		  
		  var schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  var cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  
		  /*if(isdefined('session.user.role'))
		    writeoutput('sess.user.role=#session.user.role#');*/
		  
		  if(isdate(schedDateQuery.scheddate))
  			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
		  		/*writeoutput('session.user.myyear=#session.user.myyear#');
		  		writeoutput('session.user.affiliation=#session.user.affiliation#');*/
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
        	
          desList = valueList(designations.f_designation_id);
          isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		  }
	
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.phmcoord;
			
		  if(isdefined("session.user.role"))
		  {
		  	  if(session.user.role gte application.roles.MDAdmin)
		      	isAdminUser = true;
				  else if(session.user.role eq application.roles.PHARMCoord 
				        and (tabID eq this.PHARMACY_TAB or tabID eq this.PHARMACY_COORD_TAB))
				    isAdminUser = true;
		  }
		  
		  
		  for(i=1;i<=listlen(designationsList);i++)
		  {		  		  
		  	designation = listgetat(designationsList, i);
		  	data = {};
		  	
		  	data.designation = designation;
		  	
		  	//<!--- get the designation counts for each position for the week ---->
		  	data.limit = application.dbprocs.callProc("get_limit_designation",url.id,designation);

    	  	//<!--- Get the volunteers for each position for the week --->
          	data.vols = application.dbprocs.callProc("sel_med_designation",url.id,designation);

		  	//check what designations are full
			data.full = data.vols.recordcount gte data.limit;//one for alternate

			data.name = listgetat(designationsNamesList,i);
			arrayappend(designationsData, data);
			
			
		  }
			//writeoutput('isAdminUser=#isAdminUser#');
		</cfscript>
        
        <cfoutput>
        <!---<cfif isdefined('variables.designations')>
          <cfdump var=#designations#>
        </cfif>
		<cfdump var=#designationsData#--->
        <cfset gy = createObject("component","components.gradYear")>
        <table class="Volunteer volunteerStaff" width="630">
          <thead>
			<tr>
			<cfloop array=#designationsData# index="designation">
            <td width="#round(100/arraylen(designationsData))#%">
                 #designation.name# (#designation.limit#) 			
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#designation.designation#">edit</a>
                 </cfif>
              </td>
			</cfloop></tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
			<cfloop array=#designationsData# index="designation">
              <td <cfif designation.full>class="shaded2"</cfif>>
                <cfif designation.vols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="designation.vols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,f_volunteer_id)>
                  </cfif>
                    #lname#, #fname# <cfif spanish eq '1'>- S</cfif><br/>
                </cfloop>
              	
              </td>
			</cfloop>
            </tr>
            </cfoutput>
            
		  <cfif not isDatePast and not isdefined("url.rosterview")>
			<!---add volunteer controls--->
			<cfif not isVolunteered>
              <tr>
                <cfset var designation = ''>
				<cfloop array=#designationsData# index="designation">
					<td class="noborder">            				
	         <cfif  not isDatePast and not designation.full and listfind(desList,designation.designation)>
					    <cfset generateVolunteerBtn(designation.designation,url.id)>
	         </cfif>
	         </td>
				</cfloop>
			 </tr>
            </cfif>
            
            <!--- Add Administrator controls --->
            <cfif isAdminUser>
              <tr>
				<cfloop array=#designationsData# index="desig">
				<td class="noborder">
                  <cfif not desig.full>
                    <cfset generateAdminAdd(designation:desig.designation,sched_id:url.id)>
	              </cfif>
                </td>
				</cfloop>
				</tr>
              </cfif>
            </cfif>
            
          </tbody>
        </table>
        </cfoutput>
	</cffunction>
	
	   <!----------------------------------------------------------------
	                      Pharmacy  Tab
	----------------------------------------------------------------->
	<cffunction name="pharmacyTab" access="remote">
    	   <cfset renderdesignationtab('#application.scheduleDesignations.pharmPY1#,#application.scheduleDesignations.pharmPY2#,#application.scheduleDesignations.pharmPharmD#,#application.scheduleDesignations.pharmInptr#',
		'PY I/II,PY III/IV,PharmD (Supervising Faculty),Pharm Inptr', this.PHARMACY_TAB)>
            
    </cffunction>
    
     <!----------------------------------------------------------------
	                      Pharmacy Coordinator Tab
	----------------------------------------------------------------->
	<cffunction name="PHMCOORTab" access="remote">
    	   <cfset renderdesignationtab('#application.scheduleDesignations.pharmcorDirector#,#application.scheduleDesignations.pharmcorStaff#,#application.scheduleDesignations.pharmcorPatientCoordinator#,#application.scheduleDesignations.pharmcorOperations#',
		'Director,Staff,Patient,Operations', this.PHARMACY_COORD_TAB)>
            
    </cffunction>
    
	   <!----------------------------------------------------------------
	                      Nursing Coordinator Tab
	----------------------------------------------------------------->
	<cffunction name="NUCOORTab" access="remote">
    	   <cfset renderdesignationtab('#application.scheduleDesignations.ncorARNPStudent#,#application.scheduleDesignations.ncorARNPPreceptor#',
		'MS I/II,MS III/IV', this.NURSING_COORD_TAB)>
            
    </cffunction>
	
    <!----------------------------------------------------------------
	                      interpreters public health Tab
	----------------------------------------------------------------->
    <cffunction name="interpreterPHTab" access="remote">
    	<cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  if(IsDate(schedDateQuery.scheddate ))
			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		 
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",0,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		 }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.intpub;
		  
		  if(isdefined("session.user.role"))
		  {
		  	  if(session.user.role gte application.roles.MDAdmin)
	  			  isAdminUser = 1;
  			  else if(session.user.role eq application.roles.MDCoord)
			      	isAdminUser = 1;			  
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
		  swlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.interpreter);
          swlcswlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.phService);
		  //<!--- get substitute for event --->
		  
    
    	  //<!--- Get the volunteers for each position for the week --->
          swvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.interpreter);
          swlcswvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.phService);
		  
		  
		  //check what designations are full
		  swfull = swvols.recordcount gte swlimit;//one for alternate
		  swlcswfull = swlcswvols.recordcount gte swlcswlimit;//one for alternate
		</cfscript>
        
        <cfoutput>
        <cfset gy = createObject("component","components.gradYear")>
		
        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr><td width="50%">
                 Interpreters (#swlimit#) 
                 <cfif  not isDatePast and isAdminUser >
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.interpreter#">edit</a>
                 </cfif>
              </td><td width="50%"> 
                Public Health Screener (#swlcswlimit#)
                <cfif  not isDatePast and (isAdminUser or (isDefined("session.user.role") and session.user.role eq application.roles.phcoord))>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.phservice#">edit</a>
                 </cfif>
            </td></tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
              <td <cfif swfull>class="shaded2"</cfif>>
                <cfif swvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,swvols.f_volunteer_id)>
                  </cfif>
                    -#swvols.lname#, #swvols.fname# <cfif #swvols.spanish# eq '1'> - S</cfif> <br/>
                </cfloop>
				
              </td>
              <td <cfif swlcswfull>class="shaded2"</cfif>>
                <cfif swlcswvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="swlcswvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  swlcswvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser or session.user.role eq application.roles.phcoord >
                    <cfset generateCancelBtn(url.id,swlcswvols.f_volunteer_id)>
                  </cfif>
                    -#swlcswvols.lname#, #swlcswvols.fname# <cfif #swvols.spanish# eq '1'> - S</cfif> <br/>
                </cfloop>
                
              </td>
            </tr>
            </cfoutput>
            
			<cfif not isDatePast gt 0 and not isdefined("url.rosterview")>
            <!---add volunteer controls --->
			<cfif isVolunteered lt 1>
              <tr><td class="noborder">
                  <cfif  not isDatePast and not swfull<!---removed listfind on designations because anyone can be interpreter--->>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.interpreter,url.id)>
                  </cfif>
                </td><td class="noborder">
                  <cfif  not isDatePast and not swlcswfull and listfind(desList,application.scheduleDesignations.phservice) gt 0>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.phservice,url.id)>
                  </cfif>
              </td></tr>
            </cfif>
            
            <!--- Add administrator controls--->
            <cfif not isAdminUser lt 1>
              <tr><td class="noborder">
                  <cfif not swfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.interpreter,affiliation:application.affiliations.interpreter,sched_id:url.id)>
	              </cfif>
                </td><td class="noborder">
                  <cfif not swfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.phService,affiliation:application.affiliations.phscreener,sched_id:url.id)>
	              </cfif>
              </td></tr>
            </cfif>
           </cfif>
            
          </tbody>
        </table>
        </cfoutput>
            
    </cffunction>
    
    

	<!---<!----------------------------------------------------------------
	                      Interpreters Tab                         
	----------------------------------------------------------------->
	<cffunction name="INTab" access="remote">
        <cfset singleTab(schedule_id:"#url.id#", designation:application.scheduleDesignations.interpreter, affiliation:application.affiliations.interpreter)>
    </cffunction>
    
    <!----------------------------------------------------------------
	                      Public Health Tab                         
	----------------------------------------------------------------->
	<cffunction name="PHTab" access="remote">
    	<cfset singleTab(schedule_id:"#url.id#",designation:application.scheduleDesignations.phService,affiliation:application.affiliations.phscreener)>
    </cffunction>

	<!----------------------------------------------------------------
	                      General Single Tab                          
	----------------------------------------------------------------->
	<cffunction name="singleTab" access="private">
    	<cfargument name="schedule_id" default="1000" />
        <cfargument name="designation" default="000" />
        <cfargument name="affiliation" default="000" />
        
        <cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,arguments.schedule_id);
			schedDateQuery = application.dbprocs.callProc("get_sched_date",arguments.schedule_id);
			cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  desName = application.dbprocs.callProc("get_designation_name",arguments.designation);
		  
		  if(isdefined("session.user.role"))
		  {
			  if(session.user.role gte application.roles.MDAdmin)
		      	isAdminUser = 1;
			  else{
				  if(designation eq application.scheduleDesignations.interpreter and
					 session.user.role eq application.roles.MDCoord)
				    isAdminUser = 1;
				  if(designation eq application.scheduleDesignations.phservice and
					 session.user.role eq application.roles.PHCoord)
				    isAdminUser = 1;
			  }
		  }
		  
		  //<!--- get the designation counts for each position for the week ---->
		  inlimit = application.dbprocs.callProc("get_limit_designation",arguments.schedule_id,arguments.designation);
    	  //<!--- Get the volunteers for each position for the week --->
          invols = application.dbprocs.callProc("sel_med_designation",arguments.schedule_id,arguments.designation);
		  //check what designations are full
		  infull = invols.recordcount gte inlimit;//one for alternate
		</cfscript>
        
        <cfoutput>
        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr><td>
                 #desName# (#inlimit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#arguments.schedule_id#&designation=#arguments.designation#">edit</a>
                 </cfif>
            </td></tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr><td <cfif infull>class="shaded2"</cfif>>
                <cfloop query="invols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  invols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(arguments.schedule_id,invols.f_volunteer_id)>
                  </cfif>
                    -#invols.lname#, #invols.fname# <br/>
                </cfloop>
            </td></tr>
            </cfoutput>
            
            <cfif isVolunteered lt 1>
             <cfif  not isDatePast and not infull and listfind(desList,arguments.designation)>
                <tr>
			      <td class="noborder">
            	    <cfset generateVolunteerBtn(arguments.designation,arguments.schedule_id)>
                  </td>
                </tr>
              </cfif>
            </cfif>
            
            <cfif isAdminUser and not infull>
              <tr><td class="noborder">
                <cfset generateAdminAdd(designation:arguments.designation, sched_id:arguments.schedule_id, affiliation:arguments.affiliation)>
              </td></tr>
            </cfif>
            
          </tbody>
        </table>
        </cfoutput>
            
    </cffunction>--->


	<!--------------------------------------------------------
	                 Med Coordinators Tab                     
	--------------------------------------------------------->
	<cffunction name="MCOORTab" access="remote">
    	
	    <cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  if(IsDate(schedDateQuery.scheddate ))
			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.mcoord;
		  
		  if(isdefined("session.user.role"))
		  {
			  if(session.user.role gte application.roles.MDAdmin)
			       isAdminUser = 1;
			  else{
				  if(session.user.role eq application.roles.MDCoord)
				    isAdminUser = 1;
			  }
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
          phlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.Physician);
          resdlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.Resident);
          
    	  //<!--- Get the volunteers for each position for the week --->
          phvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.Physician);
          resdvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.Resident);
          
		  //check what designations are full
    		  phfull = phvols.recordcount gte phlimit;
    		  resdfull = resdvols.recordcount gte resdlimit;	  
		</cfscript>
        
        <cfoutput>
      
					 	 	
    
	    <table class="Volunteer volunteerStaff" width="630px">
          <thead>
            <tr>
              <td width="50%">
               Physicians (#phlimit#)
               <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.Physician#">edit</a>
               </cfif>
              </td>
			 <td width="50%">
               Resident (#resdlimit#)
               <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.Resident#">edit</a>
               </cfif>
              </td>
            </tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
              <td <cfif phfull>class="shaded2"</cfif>>
                <cfif phvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="phvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  phvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,phvols.f_volunteer_id)>
                  </cfif>
                    -#phvols.lname#, #phvols.fname# <cfif #phvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>

              </td>
			
			   <td <cfif resdfull>class="shaded2"</cfif>>
                <cfif resdvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="resdvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  resdvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(url.id,resdvols.f_volunteer_id)>
                  </cfif>
                    -#resdvols.lname#, #resdvols.fname# <cfif #resdvols.spanish# eq '1'>- S </cfif>  <br/>
                </cfloop>

              </td>
            </tr>
            </cfoutput>
			<!--->  stafffull = staffvols.recordcount gte stafflimit;//one for alternate
		  patientfull = patientvols.recordcount gte patientlimit;//one for alternate
		  operationsfull = operationsvols.recordcount gte operationslimit;
		  directorsfull--->
			<cfif not IsdatePast and not isdefined("url.rosterview")>
            <cfif not isAdminUser and isVolunteered lt 1>
              <tr><td class="noborder">
                      <cfif  not phfull and listfind(desList,application.scheduleDesignations.Physician)>
                        <cfset generateVolunteerBtn(application.scheduleDesignations.Physician,url.id)>
                      </cfif>
                  </td>
				 </td><td class="noborder">
					
                      <cfif  not resdfull and listfind(desList,application.scheduleDesignations.Resident)>
                        <cfset generateVolunteerBtn(application.scheduleDesignations.Resident,url.id)>
                      </cfif>
                  </td>
				</tr>
            </cfif>
            <cfif isAdminUser>
              <tr>
                <td class="noborder">
                      <cfif not phfull>
                        <cfset generateAdminAdd(designation:application.scheduleDesignations.physician, affiliation:application.affiliations.physician, sched_id:url.id)>
                      </cfif>
                    </td>
					   </td><td class="noborder">

                      <cfif not resdfull>
						
                        <cfset generateAdminAdd(designation:application.scheduleDesignations.Resident, affiliation:application.affiliations.Resident, sched_id:url.id)>
                      </cfif>
                    </td>
              </tr>
            </cfif>
			</cfif>
          </tbody>
        </table>
        </cfoutput>            
    </cffunction>
  
    

	<!--------------------------------------------------------------
	                    Physical Therapy Coordinator Tab           
	--------------------------------------------------------------->
	<cffunction name="PTCOORTab" access="remote">
    	<cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  schedDateQuery = application.dbprocs.callProc("get_sched_date",url.id);
		  cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
		  if(IsDate(schedDateQuery.scheddate ))
			isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,url.id);
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  //set default tab
		  if(not isdefined("url.rosterview"))
			Session.pageControl.schedule.tab = application.tabs.pcoord;
		  
		  if(isdefined("session.user.role"))
		  {
			  if(session.user.role gte application.roles.MDAdmin)
			       isAdminUser = 1;
			  else{
				  if(session.user.role eq application.roles.PTCoord)
				    isAdminUser = 1;
			  }
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
		  dirLimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.pcoorDirector);
		  stafflimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.pcoorstaff);
          patientlimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.pcoorpatient);
          operationslimit = application.dbprocs.callProc("get_limit_designation",url.id,application.scheduleDesignations.pcooroperations);
          
		  
    	  //<!--- Get the volunteers for each position for the week --->
		  dirVols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.pcoorDirector);
		  staffvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.pcoorStaff);
          patientvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.pcoorPatient);
          operationsvols = application.dbprocs.callProc("sel_med_designation",url.id,application.scheduleDesignations.pcoorOperations);
          
		  //check what designations are full
		  dirFull = dirvols.recordcount gte dirlimit;
		  stafffull = staffvols.recordcount gte stafflimit;
		  patientfull = patientvols.recordcount gte patientlimit;
		  operationsfull = operationsvols.recordcount gte operationslimit;
		</cfscript>
        
        <cfoutput>
        
        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr>
              <td width="25%">
                Director (#dirLimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.pcoordirector#">edit</a>
                 </cfif>
              </td>
              <td width="25%">
                 Staff (#stafflimit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.pcoorstaff#">edit</a>
                 </cfif>
              </td>
              <td width="25%"> 
                Patient (#patientlimit#)
                <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.pcoorpatient#">edit</a>
                 </cfif>
              </td>
              <td width="25%">
               Operations (#operationslimit#)
               <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#url.id#&designation=#application.scheduleDesignations.pcooroperations#">edit</a>
               </cfif>
              </td>
            </tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr>
              <td <cfif dirfull>class="shaded2"</cfif>>
                <cfif dirvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="dirvols">
                  <cfif  not isDatePast and (isAdminUser  or (isdefined("session.user.volunteerid") and session.user.volunteerid eq staffVols.f_volunteer_id)) >
                    <cfset generateCancelBtn(url.id,dirvols.f_volunteer_id)>
                  </cfif>
                    #dirvols.lname#, #dirvols.fname# <cfif #dirvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>
              	
              </td>
              <td <cfif stafffull>class="shaded2"</cfif>>
                <cfif staffvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="staffvols">
                  <cfif  not isDatePast and (isAdminUser  or (isdefined("session.user.volunteerid") and session.user.volunteerid eq staffVols.f_volunteer_id)) >
                    <cfset generateCancelBtn(url.id,staffvols.f_volunteer_id)>
                  </cfif>
                    #staffvols.lname#, #staffvols.fname# <cfif #staffvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>
              	
              </td>
              <td <cfif patientfull>class="shaded2"</cfif>>
                <cfif patientvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="patientvols">
                  <cfif  not isDatePast and (isAdminUser  or (isdefined("session.user.volunteerid") and session.user.volunteerid eq patientVols.f_volunteer_id))>
                    <cfset generateCancelBtn(url.id,patientvols.f_volunteer_id)>
                  </cfif>
                    #patientvols.lname#, #patientvols.fname# <cfif #patientvols.spanish# eq '1'>- S</cfif><br/>
                </cfloop>
                
              </td>
              <td <cfif operationsfull>class="shaded2"</cfif>>
                <cfif operationsvols.recordcount eq 0>
                   <cfset generateNone() />
                </cfif>
                <cfloop query="operationsvols">
                  <cfif  not isDatePast and  (isAdminUser  or (isdefined("session.user.volunteerid") and session.user.volunteerid eq operationsVols.f_volunteer_id)) >
                    <cfset generateCancelBtn(url.id,operationsvols.f_volunteer_id)>
                  </cfif>
                    #operationsvols.lname#, #operationsvols.fname# <cfif #operationsvols.spanish# eq '1'>- S</cfif> <br/>
                </cfloop>

              </td>
            </tr>
            </cfoutput>
			
			<cfif not IsdatePast and not isdefined("url.rosterview")>
            <cfif not isAdminUser and isVolunteered lt 1>
              <tr><td class="noborder">
                  <cfif  not dirFull and listfind(desList, application.scheduleDesignations.pcoorDirector ) gt 0>
				    <cfset generateVolunteerBtn(application.scheduleDesignations.pcoorDirector,url.id)>
                  </cfif>
                </td>
				<td class="noborder">
                  <cfif not stafffull and listfind(desList,application.scheduleDesignations.pcoorStaff) gt 0>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.pcoorStaff,url.id)>
                  </cfif>
              </td>
		<td class="noborder">
                  <cfif  not patientfull and listfind(desList,application.scheduleDesignations.pcoorPatient) gt 0>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.pcoorPatient,url.id)>
                  </cfif>
              </td>
 			<td class="noborder">
                  <cfif  not operationsfull and listfind(desList,application.scheduleDesignations.pcoorOperations) gt 0>
                    <cfset generateVolunteerBtn(application.scheduleDesignations.pcoorOperations,url.id)>
                  </cfif>
              </td>
				</tr>
            </cfif>
			</cfif>
            
            <cfif not IsdatePast and not isdefined("url.rosterview")  and isAdminUser>
              <tr>
                <td class="noborder">
                  <cfif not dirfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.pcoorDirector, sched_id:url.id, affiliation:application.affiliations.physical)>
                  </cfif>
                </td>
                <td class="noborder">
                  <cfif not stafffull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.pcoorStaff, sched_id:url.id, affiliation:application.affiliations.physical)>
                  </cfif>
                </td>
                <td class="noborder">
                  <cfif not patientfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.pcoorPatient, sched_id:url.id, affiliation:application.affiliations.physical)>
                  </cfif>
                </td>
              
                <td class="noborder">
                  <cfif not operationsfull>
                    <cfset generateAdminAdd(designation:application.scheduleDesignations.pcoorOperations, sched_id:url.id, affiliation:application.affiliations.physical)>
                  </cfif>
                </td>
              </tr>
            </cfif>
          </tbody>
        </table>
        </cfoutput>
    </cffunction>
    
    <!--------------------------------------------------------------
	                    Social Work       Coordinator Tab           
	--------------------------------------------------------------->
    <cffunction name="SCOORTab" access="remote">
    	   <cfset coorTab("#url.id#","#application.scheduleDesignations.ScoorStaff#","#application.affiliations.social#")> 	
    </cffunction>
    
    <!--------------------------------------------------------------
	                    Public Health     Coordinator Tab           
	--------------------------------------------------------------->
    <cffunction name="PHCOORTab" access="remote">
    	<cfset coorTab("#url.id#","#application.scheduleDesignations.phcoord#","#application.affiliations.phscreener#")>
    </cffunction>
    
    <!--------------------------------------------------------------
	                    General Coordinator Tab Generator           
	--------------------------------------------------------------->
    <cffunction name="coorTab" access="private">
    	<cfargument name="schedule_id" default="1000" />
        <cfargument name="designation" default="" />
        <cfargument name="affiliation" default="" />
    
    	<cfscript>
		
		  isDatePast = 0;
		  isAdminUser = 0;
		  
		  //check for volunteer and set variables
		  if(isDefined("session.user.myyear"))
		  {
        	designations = application.dbprocs.callProc("sel_user_designations",session.user.myyear,session.user.affiliation);
            desList = valueList(designations.f_designation_id);
            isVolunteered = application.dbprocs.callProc("is_vol_scheduled",session.user.volunteerid,arguments.schedule_id);
			schedDateQuery = application.dbprocs.callProc("get_sched_date",arguments.schedule_id);
			cur = parseDateTime(dateFormat(now(),"MM/DD/YYYY"));
			if(IsDate(schedDateQuery.scheddate ))
				isDatePast = DateCompare(schedDateQuery.scheddate,cur) lt 0;
		  }else{
            isVolunteered = 1;
            desList = "";
		  }
		  
		  if(isdefined("session.user.role")){
		     if(session.user.role gte application.roles.MDAdmin){
			    isAdminUser = 1;
			 }else{
			    if(designation eq application.scheduleDesignations.pcoorStaff and
				    session.user.role eq application.roles.PTCoord)
				  isAdminUser = 1;
				if(designation eq application.scheduleDesignations.scoorStaff and
				    session.user.role eq application.roles.SWCoord)
				  isAdminUser = 1;
				if(designation eq application.scheduleDesignations.phcoord and
				    session.user.role eq application.roles.PHCoord)
				  isAdminUser = 1;
			 }
		  }
		  

		  //<!--- get the designation counts for each position for the week ---->
		  stafflimit = application.dbprocs.callProc("get_limit_designation",arguments.schedule_id,arguments.designation);
          //<!--- Get the volunteers for each position for the week --->
          staffvols = application.dbprocs.callProc("sel_med_designation",arguments.schedule_id,arguments.designation);
          //check what designations are full
		  stafffull = staffvols.recordcount gte stafflimit;
		 </cfscript>
        
        <cfoutput>
        
        <table class="Volunteer volunteerStaff" width="630">
          <thead>
            <tr><td>
                 Staff (#stafflimit#) 
                 <cfif  not isDatePast and isAdminUser>
                   <a href="schedule.cfc?method=viewDesignation&schedule_id=#arguments.schedule_id#&designation=#arguments.designation#">edit</a>
                 </cfif>
            </td></tr>
          </thead>
          
          <tbody>
            <cfoutput>
            <tr><td <cfif stafffull>class="shaded2"</cfif>>
                <cfloop query="staffvols">
                  <cfif  not isDatePast and (isdefined("session.user.volunteerid") and  staffvols.f_volunteer_id eq session.user.volunteerid) or isAdminUser >
                    <cfset generateCancelBtn(arguments.schedule_id,staffvols.f_volunteer_id)>
                  </cfif>
                    -#staffvols.lname#, #staffvols.fname# <cfif #staffvols.spanish# eq '1'>-S </cfif><br/>
                </cfloop>
            </td></tr>
            </cfoutput>
            
            <cfif isAdminUser and not stafffull>
              <tr>
                <td class="noborder">
                  <cfset generateAdminAdd(designation:arguments.designation, sched_id:arguments.schedule_id, affiliation:arguments.affiliation) />
                </td>
              </tr>
            </cfif>
            
          </tbody>
        </table>
        </cfoutput>  
    </cffunction>
    
    
    <!------------------------------------------------------------------
	                   Get Auto Complete for Designation                
	------------------------------------------------------------------>
    <cffunction name="getAutoCompleteForDes" access="private">
    	<cfargument name="designation" default="#application.scheduleDesignations.phcoord#" />
        <cfargument name="schedule_id" default="1000" />
                    <cfset var myCurl = "schedule.cfc?method=getVolunteers" />
					<cfoutput>
                    
                    <cfif designation eq application.scheduleDesignations.scoorStaff or
						  designation eq application.scheduleDesignations.phcoord>
                      <cfset myCurl = "schedule.cfc?method=getCoordinators">
                    </cfif>
                    

                    <!---<cfif designation eq application.scheduleDesignations.mcoorStaff or
					      designation eq application.scheduleDesignations.mcoorPatient or
						  designation eq application.scheduleDesignations.mcoorOperations or
						  designation eq application.scheduleDesignations.pcoorStaff or
						  designation eq application.scheduleDesignations.pcoorOperations or
						  designation eq application.scheduleDesignations.pcoorPatient or
						  designation eq application.scheduleDesignations.pcoorDirector or
						  designation eq application.scheduleDesignations.scoorStaff or
						  designation eq application.scheduleDesignations.phcoord>
                      <cfset myCurl = "schedule.cfc?method=getCoordinators">
                    </cfif>--->
                    
         			<form method="POST" onsubmit="return false;">
                      <label>Volunteer Name</label>
            		  <input id="hscVolunteer#arguments.schedule_id&arguments.designation#" name="doesntmatter" type="text" size="20" />
            		  <input type="hidden" name="schedule_id" value="#arguments.schedule_id#" />
            		  <input type="hidden" name="designation" value="#arguments.designation#" />
            		  <input name="personID" id="hscPersonID#arguments.schedule_id&arguments.designation#" type="hidden" />
            
            		  <script type="text/javascript" src="jquery/jquery.autocomplete.min.js"></script>
            		  <link href="jquery/jquery.autocomplete.css" rel="stylesheet" type="text/css">
            		  <script type="text/javascript">
					         $('##hscVolunteer#arguments.schedule_id&arguments.designation#').focus(function(){ });
                             $('##hscVolunteer#arguments.schedule_id&arguments.designation#').autocomplete("#mycurl#", {max:10,
										   formatItem: function(row){
											   			  var output = row[0];
														  if($.trim(row[1])!='')
														      output=output+'  '+row[1];
														  return output;
													   },
											width:350,
											extraParams:{schid:#arguments.schedule_id#,des:#arguments.designation#}, 
											mustMatch:false
									}).result(function(a,row,b){
													   $('##hscPersonID#arguments.schedule_id&arguments.designation#').val(row[2]);
													   addVolunteer(this,'#arguments.schedule_id#',row[2],#arguments.designation#);
													   //$('##volunteer#arguments.schedule_id&arguments.designation#').html('<b>'+row[0]+'</b> is to be added.');
										});
							        
            		  </script>
            		  
                      <!---<input type="button" class="ed_stdButton_small" value="+ Add" onclick="addVolunteer(this,#arguments.schedule_id#,$('##hscPersonID#arguments.schedule_id&arguments.designation#').val(),#arguments.designation#)" /><br>--->
                      <span id="volunteer#arguments.schedule_id&arguments.designation#"></span>
                      <br/>
                    </form>
                   </cfoutput>
    </cffunction>
    
    
    
    
    
    
    
    
    
    <!--------------------------------------------------------------
	                    View Designation                            
	--------------------------------------------------------------->
    <cffunction name="viewDesignation" access="remote">
      <cfif not( isdefined("url.designation") and isdefined("url.schedule_id") and isDefined("session.user.role"))>
        <cflocation url="schedule.cfc?method=viewSchedule">
      </cfif>

		<cfsavecontent variable="main">
        	
            <label><a href="schedule.cfc?method=viewSchedule">Back to the Schedule</a></label>
            <br />
            
            <fieldset>
            <table class="stdTab"><tr><td>
            <cfset application.globaltemplate.addJS("jquery/jquery-ui-1.8.6.custom.min.js",request)>
            <cfset application.globaltemplate.addJS("scripts/schedule.js",request)>
            <cfset application.globaltemplate.addcss("css/schedule.css",request)>
            <cfset mtabs=createObject("component","elements.tabs")>
            <cfset mtabs.init("Designation")>
            <cfset mtabs.add("schedule.cfc?method=viewDesignation2&schedule_id="&url.schedule_id&"&designation="&url.designation,"Designation","thisDesignation")>
            <cfset mtabs.render()>
            </td></tr></table>
            </fieldset>
                    
            
			<!---<cfset outputDesignation(url.designation,url.schedule_id,session.user.role)>--->
        </cfsavecontent>
        
        <cfset application.globaltemplate.render(main)>
      
    </cffunction>
    
    <!--------------------------------------------------------------
	                    View Designation 2                          
	--------------------------------------------------------------->
    <cffunction name="viewDesignation2" access="remote">
      <cfif isdefined("url.designation") and isdefined("url.schedule_id") and isDefined("session.user.role")>
         <div class="Bridge stdTab">
		   <cfset outputDesignation(url.designation,url.schedule_id,session.user.role)>
         </div>
      </cfif>
    </cffunction>
    
    <!--------------------------------------------------------------
	                    Output Designation                          
	--------------------------------------------------------------->
    <cffunction name="outputDesignation" access="private">
      <cfargument name="designation" required="yes">
      <cfargument name="schedule_id" required="yes">
      <cfargument name="role" required="yes">
      
      <cfscript>
		  
		  VolunteerQuery = application.dbprocs.callProc('sel_sched_vol_by_des', arguments.schedule_id, arguments.designation);
		  Title="";
		  limit = application.dbprocs.callProc("get_limit_designation",arguments.schedule_id,arguments.designation);
		  reachedLimit = volunteerQuery.recordCount gte limit;
		  numAlts = 0;
		  if( designation eq application.scheduleDesignations.Medical12 or
			  designation eq application.scheduleDesignations.Medical34 or
			  designation eq application.scheduleDesignations.Physical12 or
			  designation eq application.scheduleDesignations.Physical23)
	  			numAlts = 1;

		  maxCount = limit +numAlts;
		  reachedMax = volunteerQuery.recordCount gte maxCount;
				

		  //aff=100;
		  //aff=application.dbprocs.callProc("get_aff_from_des",designation);
       	  //strlimit='#limit#';

		  Title = application.dbprocs.callProc("get_designation_name",arguments.designation);
		  myACurl = "schedule.cfc?method=getVolunteers";
		  if(arguments.designation eq application.scheduleDesignations.mcoorStaff or
			 arguments.designation eq application.scheduleDesignations.pcoorStaff or
			 arguments.designation eq application.scheduleDesignations.scoorStaff or
			 arguments.designation eq application.scheduleDesignations.phcoord)
		  	myACurl = "schedule.cfc?method=getCoordinators";
	 
     </cfscript>
        
        <cfset gy = createObject('component','components.gradYear')>
        <cfset application.globaltemplate.addJS('scripts/schedule.js',request)>
        <cfoutput>
          <fieldset>
            <legend>#title#
              <form method="post" id="#arguments.schedule_id#des#arguments.designation#" action="schedule.cfc?method=changeLimit" onsubmit="return false; validateDesignationUpdate(this)">
                  <input type="hidden" name="schedule_id" value="#arguments.schedule_id#" />
                  <input type="hidden" name="volunteerCount" value="#VolunteerQuery.recordcount#" />
                  <input type="hidden" name="designation" value="#arguments.designation#" />
                  <input type="hidden" name="numAlts" value="#numAlts#" />
                  Limit:
                  <select name="newLimit">
                    <cfloop from="0" to="10" index="ind">
                      <option value="#ind#" <cfif ind eq limit>selected</cfif>>#ind#</option>
                    </cfloop>
                  </select>
                  <input type="submit" class="ed_stdButton" value="Update" onclick="updateDesignation('#arguments.schedule_id#des#arguments.designation#')">
                  <div class='hide'>updated!</div>
               </form>
            </legend>
          <table class='Bridge'>
            <thead>
              <tr>
                <td>
                  <!---Delete Button--->
                </td>
                
                <td>
                  <!---info --->
                  Volunteers
                </td>
              </tr>
            </thead>
            
            <tbody>
              <cfloop query='VolunteerQuery'>
                <tr>
                  <td <cfif reachedmax>class="shaded2"<cfelse><cfif reachedlimit>class="shaded"</cfif></cfif>>
                    <form> <!---action="schedule.cfc?method=adminRemoveVolunteer" method="POST" >--->
                      <input type="hidden" name="schedule_id" value="#arguments.schedule_id#" />
            		  <input type="hidden" name="designation" value="#arguments.designation#" />
                      <input type="hidden" name="volunteer_id" value="#volunteerQuery.volunteer_id#" />
                      <input type="button" class='ed_stdButton_small' value='Remove' onclick="deleteVolunteer(this, #arguments.schedule_id#, #volunteerQuery.volunteer_id#)" >
                    </form>
                  </td>
                  
                  <td  <cfif reachedmax>class="shaded2"<cfelse><cfif reachedlimit>class="shaded"</cfif></cfif>>
                    <div>
                      #VolunteerQuery.fname# #VolunteerQuery.lname#<br/>
                      #volunteerquery.email#<br/>
                      #formatNumber(volunteerquery.phone)#<br/>
                      <cfif trim(volunteerQuery.specialty) neq "">
                      	Specialty:#volunteerQuery.specialty#<br/>
                      </cfif>
                      <cfset gy.init(volunteerQuery.affiliation,volunteerQuery.gradYear)>
                      #gy.getAffiliationTitle()#
                    </div>
                  </td>
                </tr>
              </cfloop>
            </tbody>
          </table>
          <br/><br/>
          <cfif not reachedMax>
              <form method="POST" onSubmit="return false;"> <!--- method="POST" action="schedule.cfc?method=adminAddVolunteer">--->
                <input id="hscVolunteer#arguments.designation#" name="doesntmatter" type="text" />
                <input type="hidden" name="schedule_id" value="#arguments.schedule_id#" />
                <input type="hidden" name="designation" value="#arguments.designation#" />
                <input name="personID" id="hscPersonID#arguments.designation#" type="hidden" />
                
                <script type="text/javascript" src="jquery/jquery.autocomplete.min.js"></script>
                <link href="jquery/jquery.autocomplete.css" rel="stylesheet" type="text/css">
                <script type="text/javascript">                 
                                 $('##hscVolunteer#arguments.designation#').autocomplete("#myACurl#", {max:10,
                                               formatItem: function(row){
                                                              var output = row[0];
                                                              if($.trim(row[1])!='')
                                                                  output=output+'  '+row[1];
                                                              return output;
                                                           },
                                                width:350,
                                                extraParams:{schid:#arguments.schedule_id#,des:#designation#}, 
                                                mustMatch:false
                                        }).result(function(a,row,b){
                                                           $('##hscPersonID#arguments.designation#').val(row[2]);
                                                           $('##volunteer#arguments.designation#').html('<b>'+row[0]+'</b> is to be added.');
                                            });
                </script>
                
                <input type="button" class="ed_stdButton" value="+ Add" onclick="addVolunteer(this,#arguments.schedule_id#,$('##hscPersonID#arguments.designation#').val(),#arguments.designation#)" /><br>
                <span id="volunteer#arguments.designation#"></span>
              </form>
           </cfif>
          
          </fieldset>
        </cfoutput>
    </cffunction>
    
    <cffunction name="getPossibleVols" access="private">
       <cfargument name="designation" required="yes">
       <cfargument name="schedule_id" required="yes">
    </cffunction>
    
    
    <cffunction name="adminAddVolunteer" access="remote" >
      <cfset application.dbprocs.callProc("ins_sched_volunteer2",form.schedule_id,form.personid,form.designation)>
      <!---<cflocation url="schedule.cfc?method=viewDesignation&schedule_id=#form.schedule_id#&designation=#form.designation#">--->
    </cffunction>
    
    
    <cffunction name="adminRemoveVolunteer" access="remote">
      <cfset application.dbprocs.callProc("del_sched_volunteer2",form.schedule_id,form.volunteer_id)>
      <!---<cflocation url="schedule.cfc?method=viewDesignation&schedule_id=#form.schedule_id#&designation=#form.designation#">--->
    </cffunction>
    
    <cffunction name="changeLimit" access="remote">
    	<cfif isdefined("form.schedule_id") and isdefined("form.designation") and isdefined("form.newLimit")>
        	<cfset ret=application.dbprocs.callProc("upd_schd_designation",form.schedule_id,form.designation,form.newLimit)>
            
			<cfif ret gt 0>
              Successfully Update
            <cfelse>
              Failed to Update
            </cfif>
        <cfelse>
          Failed.  No input.
        </cfif>
        <script type="text/javascript">
		  function goback(){
			  history.go(-1);
		  }
		  
		  setTimeout('goback()',2000);
		</script>
    </cffunction>
    
    
    
    <cffunction access="private" name="formatNumber">
      <cfargument required="yes" name="number">
        <cfscript>
		  current_phone = #ReReplaceNoCase(number, '[^0123456789]', '', 'ALL')#;
		  if(len(current_phone) gte 10)
		  {
		  	areacode=left(current_phone,3);
			firstthree = mid(current_phone, 4, 3);
		  }else{
		    areacode="";
			firstthree = left(current_phone,3);
		  }
		  lastfour = right(current_phone,4);
		</cfscript>
        
		<cfreturn "(#areacode#)#firstthree#-#lastfour#">  
      
    </cffunction>
    
    
    <!--- Function is to get volunteers for a given date --->
    <cffunction access="remote" name="getCoordinators">
		<cfargument name="schid" default="0">
		<cfargument name="aff" default="100">
        <cfset var NL = CreateObject("java", "java.lang.System").getProperty("line.separator")>
        <cfset var gy = createObject("component","components.gradyear")>
        <cfset var myear = "">
		<cfset var vl=application.dbprocs.callProc("sel_avail_coord_for_aff", schid , aff, url.q )>
        
        <cfloop query="vl">
          <cfif trim(vl.gradyear) neq ''>
             <cfset myear=gy.getAffiliationTitle(gy.init(aff,vl.gradyear))>
          </cfif>
          <cfoutput>
            #vl.fname# #vl.lname#|#myear#|#vl.volunteer_id#  #NL#
          </cfoutput>
        </cfloop>
        
    </cffunction>
    
    <!--- Function is to get volunteers for a given date --->
    <cffunction access="remote" name="getVolunteers">
        <cfargument name="schid" default= "0">
        <cfargument name="des" default= "0">
		
        <cfset var NL = CreateObject("java", "java.lang.System").getProperty("line.separator")>
        <cfset var gy = createObject("component","components.gradyear")>      
        <cfset var myear = "">
		<cfset var vl = "">
        
        <!---<cfset vl=application.dbprocs.callProc("sel_avail_volunteers_for_aff", schid , aff, url.q )>--->
        <cfscript>
		  if(des eq application.scheduleDesignations.Medical12 or
			 des eq application.scheduleDesignations.Medical34 or
			 des eq application.scheduleDesignations.pharmPY1 or
			 des eq application.scheduleDesignations.pharmPY2){
            vl=application.dbprocs.callProc("srch_avail_volunteers_for_des",schid,des,url.q);
		  }else{			
		    	vl=application.dbprocs.callProc("sel_avail_volunteers_for_des", schid , des, url.q);			
		  }
			
  		  /*if(des eq application.scheduleDesignations.Medical12 or
			 des eq application.scheduleDesignations.Medical34 or
			 des eq application.scheduleDesignations.Physical12 or
			 des eq application.scheduleDesignations.Physical23)
            vl=application.dbprocs.callProc("srch_avail_volunteers_for_des",schid,des,url.q);
		  else
		    vl=application.dbprocs.callProc("sel_avail_volunteers_for_aff", schid , aff, url.q);*/
		</cfscript>
     <!---> <cfdump var=#vl#> 
      <cfabort> ---->
        <cfloop query="vl">
          <cfif trim(vl.gradyear) neq ''>
             <cfset myear=gy.getAffiliationTitle(gy.init(affiliation,vl.gradyear))>
          </cfif>
          <cfoutput>
            #vl.fname# #vl.lname#|#myear#|#vl.volunteer_id#  #NL#
          </cfoutput>
        </cfloop>
        
    </cffunction>
    

</cfcomponent>