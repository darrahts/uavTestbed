
-- create the database
create database uav_db;

-- create a database user 
create user :user with encrypted password :passwd;

-- grant permissions
grant all privileges on database uav_db to :user;

go

use uav_db;

go


@table_schema.sql;

go





-- insert into process_type_tb ("type", "subtype1", "subtype2")
-- 	values ('degradation', 'battery', 'capacitance');

-- insert into process_type_tb ("type", "subtype1", "subtype2")
-- 	values ('degradation', 'battery', 'internal resistance');

-- insert into process_type_tb ("type", "subtype1", "subtype2")
-- 	values ('degradation', 'motor', 'internal resistance');

-- insert into process_type_tb("type", "subtype1", "subtype2")
-- 	values ('environment', 'wind', 'gust');

-- insert into process_type_tb("type", "subtype1", "subtype2")
-- 	values ('environment', 'wind', 'constant');



	-- insert into process_tb(type_id, description, "source", parameters)
	-- 	values(1, 'discrete cycle based', 'NASA prognostics data set', '{"qdeg": [15,14.99,14.98,14.97,14.95,14.94,14.93,14.92,14.91,14.89,14.88,14.87,14.85,14.84,14.83,14.81,14.8,14.79,14.77,14.76,14.74,14.73,14.71,14.7,14.68,14.67,14.65,14.64,14.62,14.6,14.58,14.57,14.55,14.53,14.52,14.5,14.48,14.46,14.44,14.42,14.35,14.33,14.31,14.29,14.27,14.25,14.23,14.21,14.19,14.16,14.14,14.12,14.1,14.07,14.05,14.03,14,13.92,13.9,13.87,13.85,13.82,13.79,13.77,13.74,13.71,13.69,13.66,13.63,13.6,13.57,13.54,13.51,13.48,13.45,13.42,13.33,13.3,13.26,13.23,13.2,13.16,13.13,13.09,13.06,13.02,12.98,12.95,12.91,12.87,12.83,12.79,12.75,12.66,12.61,12.57,12.53,12.49,12.44,12.4,12.35,12.31,12.26,12.22,12.17,12.12,12.07,12.02,11.97,11.87,11.82,11.76,11.71,11.66,11.6,11.55,11.49,11.43,11.38,11.32,11.26,11.14,11.08,11.02,10.96,10.89,10.83,10.76,10.7,10.63,10.51,10.44,10.37,10.3,10.22,10.15,10.08,10,9.93,9.85,9.77,9.69,9.61,9.53]}');
	
	-- insert into process_tb(type_id, description, "source", parameters)
	-- 	values(2, 'discrete cycle based', 'NASA prognostics data set', '{"rdeg": [0.0011,0.00111,0.00112,0.00113,0.00114,0.00115,0.00116,0.00117,0.00118,0.00119,0.00121,0.00122,0.00124,0.00125,0.00127,0.00128,0.0013,0.00132,0.00134,0.00136,0.00138,0.00141,0.00143,0.00146,0.00148,0.00151,0.00154,0.00157,0.0016,0.00164,0.00167,0.00171,0.00175,0.00179,0.00184,0.00188,0.00193,0.00198,0.00204,0.00209,0.00215,0.00222,0.00228,0.00235,0.00242,0.0025,0.00258,0.00266,0.00275,0.00284,0.00294,0.00305,0.00315,0.00327,0.00339,0.00351,0.00364,0.00378,0.00393,0.00408,0.00424,0.00441,0.00459,0.00478,0.00498,0.00518,0.0054,0.00563,0.00587,0.00613,0.00639,0.00667,0.00697,0.00727,0.0076,0.00794,0.0083,0.00868,0.00908,0.00949,0.00993,0.01039,0.01088,0.01139,0.01192,0.01249,0.01308,0.0137,0.01436,0.01504,0.01577,0.01653,0.01733,0.01817,0.01905,0.01998,0.02096,0.02198,0.02275,0.02362,0.02479,0.02539,0.02664,0.02765,0.02865,0.0297,0.0308,0.03189,0.03313,0.03439,0.03564,0.03701,0.03834,0.03929,0.0407,0.04228,0.04332,0.04494,0.04662,0.04778,0.04957,0.05143,0.05271,0.05469,0.05674,0.05815,0.06034,0.06261,0.06417,0.06659,0.06909,0.07082,0.07349,0.07626,0.07817,0.08113,0.08418,0.08629,0.08956,0.09294,0.09527,0.09888,0.10262,0.10519,0.10918,0.11331,0.11615,0.12056,0.12359,0.1267,0.12988,0.13315,0.1365,0.13992,0.14344,0.14705,0.15075,0.15454,0.15843,0.16242,0.16045,0.15843,0.16242,0.16651,0.1707,0.175,0.1794,0.18392,0.18855,0.1933,0.19817]}');
	
	-- insert into process_tb(type_id, description, "source", parameters)	
	-- 	values(3, 'discrete, mission-based', 'artificial non-linear profile with saturation', '{"mdeg": [0.2371,0.23757,0.23805,0.23853,0.23902,0.2395,0.23999,0.24048,0.24098,0.24148,0.24198,0.24248,0.24299,0.2435,0.24402,0.24453,0.24505,0.24558,0.2461,0.24663,0.24717,0.24771,0.24825,0.24879,0.24934,0.24989,0.25044,0.251,0.25156,0.25213,0.2527,0.25327,0.25385,0.25443,0.25501,0.2556,0.25619,0.25679,0.25739,0.25799,0.2586,0.25921,0.25983,0.26045,0.26107,0.2617,0.26233,0.26297,0.26361,0.26426,0.26491,0.26556,0.26622,0.26689,0.26756,0.26823,0.26891,0.26959,0.27028,0.27097,0.27167,0.27237,0.27308,0.27379,0.27451,0.27523,0.27596,0.2767,0.27743,0.27818,0.27893,0.27968,0.28044,0.28121,0.28198,0.28276,0.28354,0.28433,0.28513,0.28593,0.28674,0.28755,0.28837,0.2892,0.29003,0.29087,0.29171,0.29256,0.29342,0.29429,0.29516,0.29604,0.29692,0.29781,0.29871,0.29962,0.30053,0.30145,0.30238,0.30332,0.30426,0.30521,0.30617,0.30713,0.30811,0.30909,0.31008,0.31108,0.31208,0.3131,0.31412,0.31515,0.31619,0.31724,0.31829,0.31936,0.32043,0.32152,0.32261,0.32371,0.32482,0.32595,0.32708,0.32822,0.32937,0.33053,0.3317,0.33288,0.33407,0.33527,0.33648,0.3377,0.33894,0.34018,0.34143,0.3427,0.34398,0.34526,0.34656,0.34788,0.3492,0.35054,0.35188,0.35324,0.35462,0.356,0.3574,0.35881,0.36023,0.36167,0.36312,0.36458,0.36606,0.36755,0.36905,0.37057,0.3721,0.37365,0.37521,0.37679,0.37838,0.37999,0.38161,0.38325,0.3849,0.38657,0.38825,0.38995,0.39167,0.3934,0.39516,0.39692,0.39871,0.40051,0.40233,0.40417,0.40603,0.4079,0.40979,0.4117,0.41363,0.41558,0.41755,0.41954,0.42155,0.42358,0.42562,0.42769,0.42978,0.43189,0.43402,0.43618,0.43835,0.44054,0.44276,0.445,0.44726,0.44955,0.45186,0.45419,0.45654,0.45892,0.46132,0.46375,0.4662,0.46868,0.47118,0.4737,0.47625,0.47883,0.48143,0.48406,0.48671,0.48939,0.4921,0.49484,0.4976,0.50039,0.5032,0.50605,0.50892,0.51182,0.51475,0.5177,0.52069,0.5237,0.52675,0.52982,0.53292,0.53605,0.53922,0.54241,0.54563,0.54888,0.55216,0.55547,0.55882,0.56219,0.56559,0.56903,0.57249,0.57599,0.57951,0.58307,0.58666,0.59028,0.59393,0.59761,0.60132,0.60506,0.60883,0.61263,0.61646,0.62032,0.62421,0.62814,0.63209,0.63607,0.64008,0.64411,0.64818,0.65227,0.65639,0.66054,0.66472,0.66892,0.67315,0.67741,0.68169,0.686,0.69033,0.69468,0.69906,0.70346,0.70788,0.71232,0.71679,0.72127,0.72578,0.7303,0.73484,0.7394,0.74398,0.74857,0.75318,0.7578,0.76244,0.76709,0.77175,0.77642,0.7811,0.78579,0.79049,0.79519,0.79991,0.80463,0.80935,0.81408,0.81881,0.82354,0.82827,0.833,0.83774,0.84247,0.84719,0.85192,0.85664,0.86135,0.86606,0.87075,0.87545,0.88013,0.8848,0.88946,0.89411,0.89874,0.90336,0.90797,0.91256,0.91714,0.9217,0.92624,0.93076,0.93527,0.93976,0.94422,0.94866,0.95309,0.95749,0.96186,0.96622,0.97055,0.97485,0.97913,0.98339,0.98762,0.99182,0.996]}');
		
	-- insert into process_tb(type_id, description, "source", parameters)	
	-- 	values(4, 'simulated wind gusts through direct application of force to the airframe', 'generated by experimentation', '{"x": [1.0, 0.25], "y": [0.5, 0.5], "z": [0.1, 0.1]}');
	