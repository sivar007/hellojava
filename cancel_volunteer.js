// JavaScript Document


$(document).ready(
function () {
 $('#txtFirstName').autocomplete("schedule.cfc?method=getVolunteersByFirstName", {max:10,
										   formatItem: function(row){
														  return row[0];
													   },
											width:350,
											mustMatch:false
									}).result(function(a,row,b){
													 $('#txtFirstName').val(row[0]);
													   $('#txtLastName').val(row[1]);
													   $('#txtPhone').val(row[2]);
													   $('#substitute_volunteer_id').val(row[3]);
													 
										});
										
$('#txtLastName').autocomplete("schedule.cfc?method=getVolunteersByLastName", {max:10,
										   formatItem: function(row){
										   return row[1];
													   },
											width:350,
											mustMatch:false
									}).result(function(a,row,b){
													 $('#txtFirstName').val(row[0]);
													   $('#txtLastName').val(row[1]);
													   $('#txtPhone').val(row[2]);
													    $('#substitute_volunteer_id').val(row[3]);
										});
										

}
			  );
