var models = require('../models');
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res) {

	var lat = req.query.lat;
	var lng = req.query.lng;
	var radius = 1;

	var status = "safe";
	var atrocities = [];

	// getting atrocities
	models.sequelize.query("SELECT * FROM Atrocities WHERE earth_box("+lat+", "+lng+", "+radius+") @> ll_to_earth(Atrocities.latitude, Atrocities.longitude);").success(function(results){
		status = "danger";
		atrocities = results;
	});

	res.send({
		status: status,
		atrocities: atrocities
	});

});

module.exports = router;
