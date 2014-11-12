"use strict";

module.exports = function(sequelize, DataTypes) {
  var Atrocity = sequelize.define("Atrocity", {
    latitude: DataTypes.DECIMAL,
    longitude: DataTypes.DECIMAL,
    reportedDate: DataTypes.DATE,
    severity: DataTypes.INTEGER,
    type: DataTypes.STRING,
    description: DataTypes.STRING
  }, {
    classMethods: {
      associate: function(models) {
        // associations can be defined here
      }
    }
  });

  return Atrocity;
};
