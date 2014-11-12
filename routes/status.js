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
	// models.Atrocity.find({
	// 	where: [
	// 		"earthbox("+lat+", "+lng+", "+radius+") @> ll_to_earth(latitude, longitude)"
	// 	]
	// }).success(function(results){
	// 	status = "danger";
	// 	atrocities = results.dataValues;
	// });
	models.Atrocity.find({
		where: {
			type: 'shooting'
		}
	}).success(function(results){
		console.log(results);
		if(results != null){
			status = "danger";
			atrocities = results.dataValues;
		}
	});

	res.send({
		status: status,
		atrocities: atrocities
	});

});

module.exports = router;
