// JavaScript Document

function specialtyChanged(obj)
{
	if($('input[name=Specialty"]').length > 0)
	{
		if( $(obj).val().toLowerCase() == "oth")
		{
			$('input[name$=Specialty"]').show();
			$('input[name$=Specialty"]').focus();
		}else{
			$('input[name$=Specialty"]').hide();
		}
	}
}

function validateDateForm(obj)
{
	var noteslength= $('textarea[name$="notes"]').val().length;
	var datelength= $.trim($('input[name$="newScheduleDate"]').val()).length;
	var specialtyis = $('input[name$=Specialty"]').val();
	if( $('select[name$="specialty"]').val().toLowerCase() == "oth")
	{
		if($.trim(specialtyis)=="")
		{
			alert("Specialty needs to be specified");
			return false;
		}
	}else{
		specialtyis = $('select[name$="specialty"]').val().toLowerCase();
	}
	
	if(noteslength > 499)
	{
		alert("Notes are limited to 500 characters.");
		return false;
	}
	
	if(datelength < 1)
	{
		alert("Date cannot be empty");
		return false;
	}

	//alert('here '+specialtyis+' noteCount is '+noteslength);

	return true;
}


function cancelDate()
{
	location.href="schedule.cfc?method=viewSchedule";
}


function notesChanged(obj)
{
	var notelength = $(obj).val().length;
	if(notelength > 499)
	{
		$('#notesError').show(100);
		$('#notesError').html('Notes are limited to 500 characters.<br/>  You have '+notelength+ ' characters typed.');
	}else{
		$('#notesError').hide(100);
	}
}

function redirect(id)
{
	location.href="schedule.cfc?method=addDate&id"+id;
}

function deleteDate(id)
{
	var con = confirm("Are you sure you want to delete this date\nand all information regarding it.");
	if(con)
		location.href="schedule.cfc?method=deleteDate&id"+id
}

/*function validateCancelDate()
{
	if($('input[name$="required"]').val() != 0)
	{
		if($.trim($('input[name$="alt_fname"]').val())=="")
		{
			alert('Alternate\'s First Name is required.');
			$('input[name$="alt_fname"]').focus();
			return false;
		}
		
		if($.trim($('input[name$="alt_lname"]').val())=="")
		{
			alert('Alternate\'s Last Name is required.');
			$('input[name$="alt_lname"]').focus();
			return false;
		}

		var phone = $.trim($('input[name$="alt_phone"]').val())
		var mnum = phone.replace(/[^0-9]+/g,'');
		$('input[name$="alt_phone"]').val(mnum);
	    if(mnum.length < 7)
		{
			alert('A 7 digit number is required for phone.');
			$('input[name$="alt_phone"]').focus();
			return false;
		}
	}
	
	return true;
}*/

function validateCancelDate(schdID)
{
	if($('#'+schdID).find('input[name$="required"]').val() != 0)
	{
		if($.trim($('#'+schdID).find('input[name$="alt_fname"]').val())=="")
		{
			alert('Alternate\'s First Name is required.');
			$('#'+schdID).find('input[name$="alt_fname"]').focus();
			return false;
		}
		
		if($.trim($('#'+schdID).find('input[name$="alt_lname"]').val())=="")
		{
			alert('Alternate\'s Last Name is required.');
			$('#'+schdID).find('input[name$="alt_lname"]').focus();
			return false;
		}

		var phone = $.trim($('#'+schdID).find('input[name$="alt_phone"]').val())
		var mnum = phone.replace(/[^0-9]+/g,'');
		$('#'+schdID).find('input[name$="alt_phone"]').val(mnum);
	    if(mnum.length < 7)
		{
			alert('A 7 digit number is required for phone.');
			$('#'+schdID).find('input[name$="alt_phone"]').focus();
			return false;
		}
	}
	
	return true;
}

function checkphone()
{
	var num = $.trim($('input[name$="phone"]').val());
	 var mnum = num.replace(/[^0-9]+/g,'');
	 $('input[name$="phone"]').val(mnum);
	 if(mnum.length < 7)
	 {
		 return false;
	 }
	 
	 return true;
}

function cancelDateCancel()
{
	location.href="schedule.cfc?method=viewSchedule";
}

function validateDesignationUpdate(form)
{
	var VolCount = $(form).closest("form").find("input[name='volunteerCount']").val();
	var SelCount = $(form).closest("form").find("select[name='newLimit']").val();
	var numAlts = $(form).closest("form").find("input[name='numAlts']").val();
	
	if(VolCount > (eval(SelCount) + eval(numAlts)))
	{
		alert('You have selected less than the \nnumber of volunteers.\nCorrect before proceeding.');
		return false;
	}
	
	return true;
}

function updateDesignation(formid)
{
	if(!validateDesignationUpdate($('#'+formid)))
		return;
	
	var schid = $.trim($('#'+formid).find("input[name$='schedule_id']").val());
	var volct = $.trim($('#'+formid).find("input[name$='volunteerCount']").val());
	var desid = $.trim($('#'+formid).find("input[name$='designation']").val());
	var nulim = $.trim($('#'+formid).find("select[name$='newLimit']").val());
	$.ajax({ type:"POST",
		     url:'schedule.cfc?method=changeLimit',
			 data: { schedule_id:schid , volunteerCount:volct, designation:desid, newLimit:nulim  },
			 success: function(){
				 		$('#'+formid).find("div.hide").fadeIn(400).delay(800).fadeOut(400);
						var tab = $('#'+formid).closest(".ui-tabs").tabs('option',"selected");
						setTimeout('$("#'+formid+'").closest(".ui-tabs").tabs("load",'+tab+')',1600);
			          },
			 error: function(){
				 		alert('Failed to update quantity');
			 		}
		   });
}


function testValidate()
{
	alert('value returned is '+validateCancelDate());
}


function deleteVolunteer(obj, schd, vol)
{
	$.ajax({ type:"POST",
		     url:'schedule.cfc?method=adminRemoveVolunteer',
		     data : {schedule_id: schd,volunteer_id:vol,designation:'100'},
			 success: function () {
				 			var tab = $(obj).closest('.ui-tabs').tabs('option',"selected");
				 			$(obj).closest('.ui-tabs').tabs('load',tab);
			 			},
			error: function () {
						alert('There was an unexpected error.');
					}
						
		   });
}

function addVolunteer(obj,schd, vol, des)
{
	$.ajax({ type:"POST",
		     url:'schedule.cfc?method=adminAddVolunteer',
		     data : {schedule_id: schd,personid:vol,designation:des},
			 success: function () {
				 			var tab = $(obj).closest('.ui-tabs').tabs('option',"selected");
				 			$(obj).closest('.ui-tabs').tabs('load',tab);
			 			},
			error: function () {
						alert('There was an unexpected error.\n'+vol);
					}
						
		   });
}


function testfunc(obj)
{	
	var tab = $(obj).parents('.ui-tabs').tabs('option',"selected");
	$(obj).parents('.ui-tabs').tabs('load',tab);
	//$("#MSchedule").tabs('load',0);
}

function removeVolunteer(obj,sched_id, vol_id)
{
	$.ajax({ type:"POST",
		     url:'schedule.cfc?method=adminRemoveVolunteer',
			 data: {schedule_id:sched_id, volunteer_id:vol_id},
			 success:function () {
				 //var tab= $(obj).parents('.ui-tabs').tabs('option',"selected");
				 //$(obj).parents('.ui-tabs').tabs('load',tab);
				  $('.ui-tabs').each(function(i){
													 var tab = $(this).tabs('option',"selected");
													 $(this).tabs('load',tab);
													 });
			   },
			 error: function () {
				       alert('There was an unexpected error\n');
			         }
		   });
	
	return false;
}

function AddVolunteerByVol(obj, sched_id, des)
{
	$.ajax( {type:"POST",
		     url:"schedule.cfc?method=AddVolunteer",
			 data:{scheduleid:sched_id, designation:des},
			 success: function () {
				         //var tab = $(obj).parents('.ui-tabs').tabs('option',"selected");
				         //$(obj).parents('.ui-tabs').tabs('load',tab); 
						 $('.ui-tabs').each(function(i){
													 var tab = $(this).tabs('option',"selected");
													 $(this).tabs('load',tab);
													 window.location.reload(true);
													 });
			          }
		   });
}

function showScheduleTab(tabNum)
{
	
	$('.ui-tabs').each(function() {
								$(this).tabs('select',eval(tabNum));
								});
	$.ajax({type:"POST",
		    url:'schedule.cfc?method=setSelectedTab',
			data: {selectedTab: tabNum}
		   });
}

function submitCancellation(schdID)
{
	if(!validateCancelDate(schdID))
	{
		return;
	}
	
	var vol_id= $('#'+schdID).find('input[name$="volunteer_id"]').val();
	var sch_id= $('#'+schdID).find('input[name$="schedule_id"]').val();
	var fname = $('#'+schdID).find('input[name$="alt_fname"]').val();
	var lname = $('#'+schdID).find('input[name$="alt_lname"]').val();
	var phone = $('#'+schdID).find('input[name$="alt_phone"]').val();
	
	var v_sub_vol_id= $('#'+schdID).find('input[name$="substitute_volunteer_id"]').val();
	var pop_up_id = schdID;
	
	$.ajax({ type:"POST",
		     url:"schedule.cfc?method=cancelDate",
			 data: { 'volunteer_id':vol_id,
			         'schedule_id':sch_id,
					 'alt_fname':fname,
					 'alt_lname':lname,
					 'alt_phone':phone,
					 'substitute_volunteer_id':v_sub_vol_id},
			success: function() {
						 var elem = $('input[value$='+pop_up_id+'][name$="popupWindowID"]');
						 //var tab = $(elem).parents('.ui-tabs').tabs('option',"selected");
				         //$(elem).parents('.ui-tabs').tabs('load',tab);
						 $('.ui-tabs').each(function(i){
													 var tab = $(this).tabs('option',"selected");
													 $(this).tabs('load',tab);
													 });
						 Close_PopupWindow(pop_up_id);
						},
			  error: function () {
					alert("There was an unexpected error with your request.\n  Please contact the webmaster for support.");
				}
		   });
	/*try{
		Close_PopupWindow();
	}catch(ex){}*/
}

function fillDivWithData(divid,url)
{
	$.ajax({ type:"GET",
		     url:url,
			 success: function(data) {
						   $('#'+divid).html(data);
						},
			  error: function () {
					//console.log('error');
				}
		   });
}

function showAdminAddDiv(divid)
{
	$('#'+divid).show();
	$('#'+divid).find('input').focus();
	
	return false;
}

function setupNuDatePicker(nudate) {
	/*$('#hit_date_month_nuDate').hide();
	$('#hit_date_year_nuDate').hide();
	$('#hit_date_day_nuDate').hide();
	$('#hit_date_calImg_nuDate').hide();*/
	$("#newScheduleDate").datepicker({
									 flat:true,
									 prev:true,
									 next:true,
									 calendars:1,
									 changeMonth:true,
									 changeYear:true,
									 onSelect: function (dateText,inst){
											/*mdate = dateText.split('/');
											var month = parseInt(mdate[0]);
											var day = parseInt(mdate[1]);
											var year = parseInt(mdate[2]);
											$('#hit_date_month_nuDate').val(month);
											$('#hit_date_year_nuDate').val(year);
											$('#hit_date_day_nuDate').val(day);
											$('#hit_date_month_nuDate').change();
											$('#hit_date_year_nuDate').change();
											$('#hit_date_day_nuDate').change();*/
										}
									 });
	$("#newScheduleDate").datepicker('setDate',nudate);
}

function initializeFloatingKey()
{
     $('#scheduleKeyLegend').addClass('floatingBox');
     $(window).scroll(
		 		function(){
        	$('#scheduleKeyLegend')
						.animate(
							{top:($(window).scrollTop() + $(window).height()*.20)+"px" },
							{queue: false, duration: 300});
      });
}
