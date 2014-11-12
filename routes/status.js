var models = require('../models');
var express = require('express');
var router = express.Router();

/* GET users listing. */
router.get('/', function (req, res) {

	var lat = req.query.lat;
	var lng = req.query.lng;
	var radius = 1;

	var status = "safe";
	var atrocities = [
		{
			"latitude" : 64.49501,
			"longitude" : 33.12924,
			"description": "Shooting"
		}
	];

	// getting atrocities
	models.sequelize.query("SELECT * FROM Atrocities WHERE earth_box(64.49501, 33.12924, 25) @> ll_to_earth(Atrocities.latitude, Atrocities.longitude);").success(function(atrocities){
		status = "false";
	});

	res.send({
		status: status,
		atrocities: atrocities
	});

});

module.exports = router;
