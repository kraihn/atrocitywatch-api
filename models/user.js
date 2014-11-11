"use strict";

module.exports = function(sequelize, DataTypes) {
  var User = sequelize.define("User", {
    phone: DataTypes.STRING,
    latitude: DataTypes.DECIMAL,
    longitude: DataTypes.DECIMAL,
    lastNotified: DataTypes.DATE
  }, {
    classMethods: {
      associate: function(models) {
        // associations can be defined here
      }
    }
  });

  return User;
};
