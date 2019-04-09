// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, or any plugin's
// vendor/assets/javascripts directory can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file. JavaScript code in this file should be added after the last require_* statement.
//
// Read Sprockets README (https://github.com/rails/sprockets#sprockets-directives) for details
// about supported directives.
// require jquery
//= require chart.js/dist/Chart.js
//= require chart.js/dist/Chart.bundle.js
//= require bootstrap/dist/js/bootstrap.js
//= require bootstrap/dist/js/bootstrap.bundle.min.js
//= require datatables.net/js/jquery.dataTables.js
//= require startbootstrap-sb-admin-2/js/sb-admin-2.js
//= require startbootstrap-sb-admin-2/js/demo/chart-area-demo.js
//= require startbootstrap-sb-admin-2/js/demo/chart-bar-demo.js
//= require startbootstrap-sb-admin-2/js/demo/chart-pie-demo.js
//= require startbootstrap-sb-admin-2/js/demo/datatables-demo.js
//= require rails-ujs
//= require activestorage
//= require turbolinks
//= require_tree .

/* directive de chargement du wiget*/
$.widget.bridge('uibutton', $.ui.button)

alert("bonjour Mr");

Rails.ajax({
	url: "/services.json",
	type: "get",
	data: "",
	success: function (data) {
		console.log("data are : "+data);
	},
	error: function (err) {
		console.log("Une erreur est survenue : "+err);
	}
})

/*
require jquery/dist/jquery.min.js
require bootstrap/dist/js/bootstrap.bundle.min.js
*/
