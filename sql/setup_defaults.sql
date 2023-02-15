------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------
/*
            This script will set up the database with a complete UAV 
                - airframe model
                - battery model
                - motor model         

            three degradation models
                - battery capacitance 
                - battery internal resistance
                - motor coil resistance

            one process model
                - stochastic wind gusts

            six stop codes
                - flight stop codes such as 'arrival success' or 'low soc' 
            
            8 different trajectories
                - made in a two step process, first is PRM, then B-Spline

            Contributing and extending this is not difficult!

            Tim Darrah
            NASA Fellow
            PhD Student
            Vanderbilt University
            timothy.s.darrah@vanderbilt.edu
*/
------------------------------------------------------------------------------------------------
------------------------------------------------------------------------------------------------


/*
    Create process types
*/
insert into process_type_tb ("type", "subtype", "subtype2")
	values ('degradation', 'battery', 'capacitance'),
		('degradation', 'battery', 'internal resistance'),
		('degradation', 'motor', 'internal resistance'),
		('environment', 'wind', 'gust'),
		('environment', 'wind', 'constant'),
		('failure probability', 'electronic speed controller', 'abrupt onset'); 

/*
    now add the processes
*/
do $$
	declare 
		q_deg_id integer := (select id from process_type_tb ptt where "type" ilike 'degradation' and "subtype" ilike 'battery' and "subtype2" ilike 'capacitance');
		r_deg_id integer := (select id from process_type_tb ptt where "type" ilike 'degradation' and "subtype" ilike 'battery' and "subtype2" ilike 'internal resistance');
		m_deg_id integer := (select id from process_type_tb ptt where "type" ilike 'degradation' and "subtype" ilike 'motor' and "subtype2" ilike 'internal resistance');
		wind_id integer := (select id from process_type_tb ptt where "type" ilike 'environment' and "subtype" ilike 'wind' and "subtype2" ilike 'gust');
	begin
		insert into process_tb(type_id, description, "source", parameters)
			values (q_deg_id, 'discrete cycle based', 'NASA prognostics data set', '{"qdeg": [15,14.99,14.98,14.97,14.95,14.94,14.93,14.92,14.91,14.89,14.88,14.87,14.85,14.84,14.83,14.81,14.8,14.79,14.77,14.76,14.74,14.73,14.71,14.7,14.68,14.67,14.65,14.64,14.62,14.6,14.58,14.57,14.55,14.53,14.52,14.5,14.48,14.46,14.44,14.42,14.35,14.33,14.31,14.29,14.27,14.25,14.23,14.21,14.19,14.16,14.14,14.12,14.1,14.07,14.05,14.03,14,13.92,13.9,13.87,13.85,13.82,13.79,13.77,13.74,13.71,13.69,13.66,13.63,13.6,13.57,13.54,13.51,13.48,13.45,13.42,13.33,13.3,13.26,13.23,13.2,13.16,13.13,13.09,13.06,13.02,12.98,12.95,12.91,12.87,12.83,12.79,12.75,12.66,12.61,12.57,12.53,12.49,12.44,12.4,12.35,12.31,12.26,12.22,12.17,12.12,12.07,12.02,11.97,11.87,11.82,11.76,11.71,11.66,11.6,11.55,11.49,11.43,11.38,11.32,11.26,11.14,11.08,11.02,10.96,10.89,10.83,10.76,10.7,10.63,10.51,10.44,10.37,10.3,10.22,10.15,10.08,10,9.93,9.85,9.77,9.69,9.61,9.53]}'),
				(r_deg_id, 'discrete cycle based', 'NASA prognostics data set', '{"rdeg": [0.0011,0.00111,0.00112,0.00113,0.00114,0.00115,0.00116,0.00117,0.00118,0.00119,0.00121,0.00122,0.00124,0.00125,0.00127,0.00128,0.0013,0.00132,0.00134,0.00136,0.00138,0.00141,0.00143,0.00146,0.00148,0.00151,0.00154,0.00157,0.0016,0.00164,0.00167,0.00171,0.00175,0.00179,0.00184,0.00188,0.00193,0.00198,0.00204,0.00209,0.00215,0.00222,0.00228,0.00235,0.00242,0.0025,0.00258,0.00266,0.00275,0.00284,0.00294,0.00305,0.00315,0.00327,0.00339,0.00351,0.00364,0.00378,0.00393,0.00408,0.00424,0.00441,0.00459,0.00478,0.00498,0.00518,0.0054,0.00563,0.00587,0.00613,0.00639,0.00667,0.00697,0.00727,0.0076,0.00794,0.0083,0.00868,0.00908,0.00949,0.00993,0.01039,0.01088,0.01139,0.01192,0.01249,0.01308,0.0137,0.01436,0.01504,0.01577,0.01653,0.01733,0.01817,0.01905,0.01998,0.02096,0.02198,0.02275,0.02362,0.02479,0.02539,0.02664,0.02765,0.02865,0.0297,0.0308,0.03189,0.03313,0.03439,0.03564,0.03701,0.03834,0.03929,0.0407,0.04228,0.04332,0.04494,0.04662,0.04778,0.04957,0.05143,0.05271,0.05469,0.05674,0.05815,0.06034,0.06261,0.06417,0.06659,0.06909,0.07082,0.07349,0.07626,0.07817,0.08113,0.08418,0.08629,0.08956,0.09294,0.09527,0.09888,0.10262,0.10519,0.10918,0.11331,0.11615,0.12056,0.12359,0.1267,0.12988,0.13315,0.1365,0.13992,0.14344,0.14705,0.15075,0.15454,0.15843,0.16242,0.16045,0.15843,0.16242,0.16651,0.1707,0.175,0.1794,0.18392,0.18855,0.1933,0.19817]}'),
				(m_deg_id, 'discrete, mission-based', 'artificial non-linear profile with saturation', '{"mdeg": [0.2371,0.23757,0.23805,0.23853,0.23902,0.2395,0.23999,0.24048,0.24098,0.24148,0.24198,0.24248,0.24299,0.2435,0.24402,0.24453,0.24505,0.24558,0.2461,0.24663,0.24717,0.24771,0.24825,0.24879,0.24934,0.24989,0.25044,0.251,0.25156,0.25213,0.2527,0.25327,0.25385,0.25443,0.25501,0.2556,0.25619,0.25679,0.25739,0.25799,0.2586,0.25921,0.25983,0.26045,0.26107,0.2617,0.26233,0.26297,0.26361,0.26426,0.26491,0.26556,0.26622,0.26689,0.26756,0.26823,0.26891,0.26959,0.27028,0.27097,0.27167,0.27237,0.27308,0.27379,0.27451,0.27523,0.27596,0.2767,0.27743,0.27818,0.27893,0.27968,0.28044,0.28121,0.28198,0.28276,0.28354,0.28433,0.28513,0.28593,0.28674,0.28755,0.28837,0.2892,0.29003,0.29087,0.29171,0.29256,0.29342,0.29429,0.29516,0.29604,0.29692,0.29781,0.29871,0.29962,0.30053,0.30145,0.30238,0.30332,0.30426,0.30521,0.30617,0.30713,0.30811,0.30909,0.31008,0.31108,0.31208,0.3131,0.31412,0.31515,0.31619,0.31724,0.31829,0.31936,0.32043,0.32152,0.32261,0.32371,0.32482,0.32595,0.32708,0.32822,0.32937,0.33053,0.3317,0.33288,0.33407,0.33527,0.33648,0.3377,0.33894,0.34018,0.34143,0.3427,0.34398,0.34526,0.34656,0.34788,0.3492,0.35054,0.35188,0.35324,0.35462,0.356,0.3574,0.35881,0.36023,0.36167,0.36312,0.36458,0.36606,0.36755,0.36905,0.37057,0.3721,0.37365,0.37521,0.37679,0.37838,0.37999,0.38161,0.38325,0.3849,0.38657,0.38825,0.38995,0.39167,0.3934,0.39516,0.39692,0.39871,0.40051,0.40233,0.40417,0.40603,0.4079,0.40979,0.4117,0.41363,0.41558,0.41755,0.41954,0.42155,0.42358,0.42562,0.42769,0.42978,0.43189,0.43402,0.43618,0.43835,0.44054,0.44276,0.445,0.44726,0.44955,0.45186,0.45419,0.45654,0.45892,0.46132,0.46375,0.4662,0.46868,0.47118,0.4737,0.47625,0.47883,0.48143,0.48406,0.48671,0.48939,0.4921,0.49484,0.4976,0.50039,0.5032,0.50605,0.50892,0.51182,0.51475,0.5177,0.52069,0.5237,0.52675,0.52982,0.53292,0.53605,0.53922,0.54241,0.54563,0.54888,0.55216,0.55547,0.55882,0.56219,0.56559,0.56903,0.57249,0.57599,0.57951,0.58307,0.58666,0.59028,0.59393,0.59761,0.60132,0.60506,0.60883,0.61263,0.61646,0.62032,0.62421,0.62814,0.63209,0.63607,0.64008,0.64411,0.64818,0.65227,0.65639,0.66054,0.66472,0.66892,0.67315,0.67741,0.68169,0.686,0.69033,0.69468,0.69906,0.70346,0.70788,0.71232,0.71679,0.72127,0.72578,0.7303,0.73484,0.7394,0.74398,0.74857,0.75318,0.7578,0.76244,0.76709,0.77175,0.77642,0.7811,0.78579,0.79049,0.79519,0.79991,0.80463,0.80935,0.81408,0.81881,0.82354,0.82827,0.833,0.83774,0.84247,0.84719,0.85192,0.85664,0.86135,0.86606,0.87075,0.87545,0.88013,0.8848,0.88946,0.89411,0.89874,0.90336,0.90797,0.91256,0.91714,0.9217,0.92624,0.93076,0.93527,0.93976,0.94422,0.94866,0.95309,0.95749,0.96186,0.96622,0.97055,0.97485,0.97913,0.98339,0.98762,0.99182,0.996]}'),
				(wind_id, 'simulated wind gusts through direct application of force to the airframe', 'generated by experimentation', '{"x": [0, 3], "y": [0, 3], "z": [0, 0.3]}');

		insert into process_tb("type_id", "description", "source", "parameters")
			values (q_deg_id, 'continuous usage based v1', 'NASA prognostics data set', '{"q_coef": [-2.60790613405495e-07, 0.000202127057196420, 22.01127]}'),
				(q_deg_id, 'continuous usage based v2', 'NASA prognostics data set', '{"q_coef": [-3.01210332274714e-07, -5.42761316559006e-05, 22.12494]}'),
				(q_deg_id, 'continuous usage based v3', 'NASA prognostics data set', '{"q_coef": [-2.25101018930192e-07, 8.81789058412002e-05, 22.13401]}'),
				(r_deg_id, 'continuous usage based v1', 'NASA prognostics data set', '{"r_coef": [6.54652293777766e-10, 6.58971874986371e-06, 0.001110]}'),
				(r_deg_id, 'continuous usage based v2', 'NASA prognostics data set', '{"r_coef": [6.97217735057489e-10,3.57477472986362e-06, 0.0009142]}'),
				(m_deg_id, 'continuous usage based v1', 'experimentation', '{"r_coef": [8.94690226770960e-09, 5.81591333236189e-06, 0.262549405948150]}'),
				(m_deg_id, 'continuous usage based v2', 'experimentation', '{"r_coef": [1.02696062620220e-08, -9.56760048610097e-06, 0.271352413746098]}'),
				(m_deg_id, 'continuous usage based v3', 'experimentation', '{"r_coef": [6.07898474108156e-09, -1.29059483699015e-06, 0.273370450839261]}'),
				(m_deg_id, 'continuous usage based v4', 'experimentation', '{"r_coef": [1.26417830302006e-08, -6.10303742506496e-06, 0.268934942334966]}'),
				(m_deg_id, 'continuous usage based v5', 'experimentation', '{"r_coef": [4.60271060279920e-09, 3.28314849327494e-05, 0.254316546086248]}'),
				(m_deg_id, 'continuous usage based v6', 'experimentation', '{"r_coef": [5.72599877374256e-09, -8.78076852993736e-06, 0.272804720484866]}'),
				(m_deg_id, 'continuous usage based v7', 'experimentation', '{"r_coef": [8.94081387875484e-09, 1.81393974059100e-06, 0.264033112845751]}'),
				(m_deg_id, 'continuous usage based v8', 'experimentation', '{"r_coef": [9.83559322830326e-09, -7.98025430361802e-06, 0.272899847099848]}');
			
			
		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(r_deg_id, 'continuous usage based v3','experimentation', '{"r_coef":[6.4492e-10, 2.7599e-06, 0.00030526]}'), 
				(r_deg_id, 'continuous usage based v4','experimentation', '{"r_coef":[6.5783e-10, 5.1242e-06, 0.00044391]}'), 
				(r_deg_id, 'continuous usage based v5','experimentation', '{"r_coef":[6.3913e-10, 3.4147e-06, 0.00044992]}'), 
				(r_deg_id, 'continuous usage based v6','experimentation', '{"r_coef":[6.1234e-10, 2.7857e-06, 0.00075451]}'), 
				(r_deg_id, 'continuous usage based v7','experimentation', '{"r_coef":[6.1968e-10, 2.4427e-06, 0.00090999]}'), 
				(r_deg_id, 'continuous usage based v8','experimentation', '{"r_coef":[6.4172e-10, 4.2457e-06, 0.0005484]}'), 
				(r_deg_id, 'continuous usage based v9','experimentation', '{"r_coef":[5.8451e-10, 9.2901e-06, 0.001058]}'), 
				(r_deg_id, 'continuous usage based v10','experimentation', '{"r_coef":[6.6152e-10, 3.7749e-06, 0.00067391]}'), 
				(r_deg_id, 'continuous usage based v11','experimentation', '{"r_coef":[6.3688e-10, 5.0252e-06, 0.0012298]}'), 
				(r_deg_id, 'continuous usage based v12','experimentation', '{"r_coef":[6.4218e-10, 2.2236e-06, 0.0010922]}'), 
				(r_deg_id, 'continuous usage based v13','experimentation', '{"r_coef":[6.7102e-10, 3.2698e-06, 0.00045342]}'), 
				(r_deg_id, 'continuous usage based v14','experimentation', '{"r_coef":[6.3377e-10, 4.1756e-06, 0.00094044]}'), 
				(r_deg_id, 'continuous usage based v15','experimentation', '{"r_coef":[6.4479e-10, 4.0728e-06, 0.00026815]}'), 
				(r_deg_id, 'continuous usage based v16','experimentation', '{"r_coef":[6.0533e-10, 2.4859e-06, 0.0010063]}'), 
				(r_deg_id, 'continuous usage based v17','experimentation', '{"r_coef":[6.478e-10, 3.5465e-06, 0.00053043]}'), 
				(r_deg_id, 'continuous usage based v18','experimentation', '{"r_coef":[6.7418e-10, 2.6337e-06, 0.00015198]}'), 
				(r_deg_id, 'continuous usage based v19','experimentation', '{"r_coef":[6.4531e-10, 2.9898e-06, 0.00069376]}'), 
				(r_deg_id, 'continuous usage based v20','experimentation', '{"r_coef":[6.9186e-10, 3.9182e-06, 0.0011962]}'), 
				(r_deg_id, 'continuous usage based v21','experimentation', '{"r_coef":[6.9338e-10, 4.4599e-06, 0.0010177]}'), 
				(r_deg_id, 'continuous usage based v22','experimentation', '{"r_coef":[6.8841e-10, 4.0133e-06, 0.0011518]}'), 
				(r_deg_id, 'continuous usage based v23','experimentation', '{"r_coef":[6.3009e-10, 1.856e-06, 0.0012732]}'), 
				(r_deg_id, 'continuous usage based v24','experimentation', '{"r_coef":[6.2779e-10, 3.376e-06, 0.0011418]}'), 
				(r_deg_id, 'continuous usage based v25','experimentation', '{"r_coef":[6.3128e-10, 7.6039e-06, 0.00030363]}'), 
				(r_deg_id, 'continuous usage based v26','experimentation', '{"r_coef":[6.6475e-10, 4.1503e-06, 0.00075714]}'), 
				(r_deg_id, 'continuous usage based v27','experimentation', '{"r_coef":[6.4222e-10, 2.6577e-06, 0.0003004]}'), 
				(r_deg_id, 'continuous usage based v28','experimentation', '{"r_coef":[6.575e-10, 2.2626e-06, 0.0012956]}'), 
				(r_deg_id, 'continuous usage based v29','experimentation', '{"r_coef":[5.9583e-10, 1.7911e-06, 0.00094091]}'), 
				(r_deg_id, 'continuous usage based v30','experimentation', '{"r_coef":[6.9117e-10, 4.266e-06, 0.0012147]}'), 
				(r_deg_id, 'continuous usage based v31','experimentation', '{"r_coef":[6.6514e-10, 4.3257e-06, 0.0011735]}'), 
				(r_deg_id, 'continuous usage based v32','experimentation', '{"r_coef":[6.518e-10, 3.7198e-06, 0.00026679]}'), 
				(r_deg_id, 'continuous usage based v33','experimentation', '{"r_coef":[6.9164e-10, 4.4683e-06, 0.0012456]}'), 
				(r_deg_id, 'continuous usage based v34','experimentation', '{"r_coef":[6.6393e-10, 4.9401e-06, 0.0011518]}'), 
				(r_deg_id, 'continuous usage based v35','experimentation', '{"r_coef":[6.0779e-10, 1.9376e-06, 0.0018472]}'), 
				(r_deg_id, 'continuous usage based v36','experimentation', '{"r_coef":[6.4109e-10, 2.6375e-06, 0.00017619]}'), 
				(r_deg_id, 'continuous usage based v37','experimentation', '{"r_coef":[6.4841e-10, 4.4502e-06, 0.0011988]}'), 
				(r_deg_id, 'continuous usage based v38','experimentation', '{"r_coef":[6.563e-10, 4.6211e-06, 0.0011284]}'), 
				(r_deg_id, 'continuous usage based v39','experimentation', '{"r_coef":[6.1239e-10, 2.177e-06, 0.00086993]}'), 
				(r_deg_id, 'continuous usage based v40','experimentation', '{"r_coef":[5.8052e-10, 1.1536e-06, 0.0011911]}'), 
				(r_deg_id, 'continuous usage based v41','experimentation', '{"r_coef":[6.0645e-10, 2.716e-06, 0.00015748]}'), 
				(r_deg_id, 'continuous usage based v42','experimentation', '{"r_coef":[6.7157e-10, 2.8016e-06, 0.00011353]}'), 
				(r_deg_id, 'continuous usage based v43','experimentation', '{"r_coef":[6.8601e-10, 5.7836e-06, 0.00084669]}'), 
				(r_deg_id, 'continuous usage based v44','experimentation', '{"r_coef":[5.4973e-10, 1.0443e-05, 0.0011355]}'), 
				(r_deg_id, 'continuous usage based v45','experimentation', '{"r_coef":[6.6293e-10, 6.3554e-06, 0.00022595]}'), 
				(r_deg_id, 'continuous usage based v46','experimentation', '{"r_coef":[6.3326e-10, 4.4567e-06, 0.0011944]}'), 
				(r_deg_id, 'continuous usage based v47','experimentation', '{"r_coef":[6.39e-10, 5.2627e-06, 0.0011989]}'), 
				(r_deg_id, 'continuous usage based v48','experimentation', '{"r_coef":[7.1274e-10, 3.457e-06, 0.00011333]}'), 
				(r_deg_id, 'continuous usage based v49','experimentation', '{"r_coef":[6.714e-10, 4.5287e-06, 0.0004738]}'), 
				(r_deg_id, 'continuous usage based v50','experimentation', '{"r_coef":[6.2393e-10, 2.0216e-06, 0.00040505]}'), 
				(r_deg_id, 'continuous usage based v51','experimentation', '{"r_coef":[6.3944e-10, 4.7425e-06, 0.00045385]}'), 
				(r_deg_id, 'continuous usage based v52','experimentation', '{"r_coef":[5.8876e-10, 8.5984e-06, 0.001224]}');

		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(r_deg_id, 'continuous usage based v53','NASA prognostics data set', '{"r_coef":[1.1294e-09, 5.2823e-06, 0.00016165]}'), 
				(r_deg_id, 'continuous usage based v54','NASA prognostics data set', '{"r_coef":[1.0478e-09, 8.3345e-06, 0.00077806]}'), 
				(r_deg_id, 'continuous usage based v55','NASA prognostics data set', '{"r_coef":[1.1183e-09, 3.3089e-06, 0.00090516]}'), 
				(r_deg_id, 'continuous usage based v56','NASA prognostics data set', '{"r_coef":[9.8919e-10, 1.1268e-05, 0.0010118]}'), 
				(r_deg_id, 'continuous usage based v57','NASA prognostics data set', '{"r_coef":[1.0161e-09, 1.0318e-05, 0.0012684]}'), 
				(r_deg_id, 'continuous usage based v58','NASA prognostics data set', '{"r_coef":[1.0489e-09, 7.9621e-06, 0.0012351]}'), 
				(r_deg_id, 'continuous usage based v59','NASA prognostics data set', '{"r_coef":[1.1167e-09, 7.6871e-06, 0.0010821]}'), 
				(r_deg_id, 'continuous usage based v60','NASA prognostics data set', '{"r_coef":[1.1883e-09, 8.1783e-06, 0.00088917]}'), 
				(r_deg_id, 'continuous usage based v61','NASA prognostics data set', '{"r_coef":[1.0612e-09, 7.2968e-06, 0.00095831]}'),
				(r_deg_id, 'continuous usage based v62','NASA prognostics data set', '{"r_coef":[1.1361e-09, 7.0762e-06, 0.00076092]}'), 
				(r_deg_id, 'continuous usage based v63','NASA prognostics data set', '{"r_coef":[1.2335e-09, 3.8866e-06, 0.0011773]}'), 
				(r_deg_id, 'continuous usage based v64','NASA prognostics data set', '{"r_coef":[1.1001e-09, 3.5642e-06, 0.0011289]}'), 
				(r_deg_id, 'continuous usage based v65','NASA prognostics data set', '{"r_coef":[1.0602e-09, 7.7006e-06, 0.00080667]}'), 
				(r_deg_id, 'continuous usage based v66','NASA prognostics data set', '{"r_coef":[1.1607e-09, 4.1001e-06, 0.00096838]}'), 
				(r_deg_id, 'continuous usage based v67','NASA prognostics data set', '{"r_coef":[1.1107e-09, 8.3261e-06, 0.0010745]}'), 
				(r_deg_id, 'continuous usage based v68','NASA prognostics data set', '{"r_coef":[1.0691e-09, 7.8016e-06, 0.0012353]}'), 
				(r_deg_id, 'continuous usage based v69','NASA prognostics data set', '{"r_coef":[1.0897e-09, 5.3311e-06, 0.00089862]}'), 
				(r_deg_id, 'continuous usage based v70','NASA prognostics data set', '{"r_coef":[9.5051e-10, 1.1776e-05, 0.0011358]}'), 
				(r_deg_id, 'continuous usage based v71','NASA prognostics data set', '{"r_coef":[1.1549e-09, 7.7982e-06, 0.0008638]}'), 
				(r_deg_id, 'continuous usage based v72','NASA prognostics data set', '{"r_coef":[1.0911e-09, 4.3271e-06, 0.0010865]}'), 
				(r_deg_id, 'continuous usage based v73','NASA prognostics data set', '{"r_coef":[1.0522e-09, 5.1022e-06, 0.001177]}'), 
				(r_deg_id, 'continuous usage based v74','NASA prognostics data set', '{"r_coef":[1.1319e-09, 6.5058e-06, 0.0012583]}'), 
				(r_deg_id, 'continuous usage based v75','NASA prognostics data set', '{"r_coef":[1.1568e-09, 1.0167e-05, 0.0010427]}'), 
				(r_deg_id, 'continuous usage based v76','NASA prognostics data set', '{"r_coef":[1.1649e-09, 2.4538e-06, 0.00090003]}'), 
				(r_deg_id, 'continuous usage based v77','NASA prognostics data set', '{"r_coef":[9.9541e-10, 7.9112e-06, 0.00089331]}'), 
				(r_deg_id, 'continuous usage based v78','NASA prognostics data set', '{"r_coef":[1.0513e-09, 9.2434e-06, 0.00014513]}'), 
				(r_deg_id, 'continuous usage based v79','NASA prognostics data set', '{"r_coef":[1.072e-09, 6.8163e-06, 0.0011601]}'), 
				(r_deg_id, 'continuous usage based v80','NASA prognostics data set', '{"r_coef":[1.2079e-09, 7.7673e-06, 0.0010309]}'), 
				(r_deg_id, 'continuous usage based v81','NASA prognostics data set', '{"r_coef":[1.1122e-09, 6.2652e-06, 0.00085638]}'), 
				(r_deg_id, 'continuous usage based v82','NASA prognostics data set', '{"r_coef":[1.1279e-09, 4.4207e-06, 0.00012717]}'), 
				(r_deg_id, 'continuous usage based v83','NASA prognostics data set', '{"r_coef":[1.1468e-09, 5.4803e-06, 0.00086257]}'), 
				(r_deg_id, 'continuous usage based v84','NASA prognostics data set', '{"r_coef":[1.1393e-09, 4.9868e-06, 0.00034725]}'), 
				(r_deg_id, 'continuous usage based v85','NASA prognostics data set', '{"r_coef":[1.0307e-09, 5.8412e-06, 0.0012307]}'), 
				(r_deg_id, 'continuous usage based v86','NASA prognostics data set', '{"r_coef":[1.0531e-09, 7.1902e-06, 0.0012358]}'), 
				(r_deg_id, 'continuous usage based v87','NASA prognostics data set', '{"r_coef":[1.1467e-09, 6.5415e-06, 0.0010653]}'), 
				(r_deg_id, 'continuous usage based v88','NASA prognostics data set', '{"r_coef":[1.1636e-09, 6.4791e-06, 0.00085855]}'), 
				(r_deg_id, 'continuous usage based v89','NASA prognostics data set', '{"r_coef":[1.0011e-09, 7.4917e-06, 0.001134]}'), 
				(r_deg_id, 'continuous usage based v90','NASA prognostics data set', '{"r_coef":[1.0844e-09, 8.9884e-06, 0.00099465]}'), 
				(r_deg_id, 'continuous usage based v91','NASA prognostics data set', '{"r_coef":[1.0513e-09, 3.4106e-06, 0.0014724]}'), 
				(r_deg_id, 'continuous usage based v92','NASA prognostics data set', '{"r_coef":[1.1885e-09, 7.7164e-06, 0.0009792]}'), 
				(r_deg_id, 'continuous usage based v93','NASA prognostics data set', '{"r_coef":[1.083e-09, 7.2783e-06, 0.0011117]}'), 
				(r_deg_id, 'continuous usage based v94','NASA prognostics data set', '{"r_coef":[1.113e-09, 2.7881e-06, 0.00089019]}'), 
				(r_deg_id, 'continuous usage based v95','NASA prognostics data set', '{"r_coef":[1.0947e-09, 3.9821e-06, 0.0012366]}'), 
				(r_deg_id, 'continuous usage based v96','NASA prognostics data set', '{"r_coef":[1.0256e-09, 9.8263e-06, 0.001007]}'), 
				(r_deg_id, 'continuous usage based v97','NASA prognostics data set', '{"r_coef":[1.0047e-09, 6.8082e-06, 0.00034449]}'), 
				(r_deg_id, 'continuous usage based v98','NASA prognostics data set', '{"r_coef":[1.1131e-09, 5.4317e-06, 0.0011638]}'), 
				(r_deg_id, 'continuous usage based v99','NASA prognostics data set', '{"r_coef":[1.0874e-09, 2.8645e-06, 0.001147]}'), 
				(r_deg_id, 'continuous usage based v100','NASA prognostics data set', '{"r_coef":[1.1299e-09, 4.7247e-06, 0.0010075]}'),
				(r_deg_id, 'continuous usage based v101','NASA prognostics data set', '{"r_coef":[1.0069e-09, 6.1143e-06, 0.00088017]}'), 
				(r_deg_id, 'continuous usage based v102','NASA prognostics data set', '{"r_coef":[1.0666e-09, 7.03e-06, 0.0011617]}');
		
		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(q_deg_id, 'continuous usage based v4','experimentation', '{"q_coef":[-1.8078e-07, 0.00017066, 22.118]}'), 
				(q_deg_id, 'continuous usage based v5','experimentation', '{"q_coef":[-3.1391e-07, 0.00014561, 22.138]}'), 
				(q_deg_id, 'continuous usage based v6','experimentation', '{"q_coef":[-2.6836e-07, 0.0001, 22.033]}'), 
				(q_deg_id, 'continuous usage based v7','experimentation', '{"q_coef":[-1.988e-07, 0.00023657, 22.442]}'), 
				(q_deg_id, 'continuous usage based v8','experimentation', '{"q_coef":[-2.5887e-07, 0.00020873, 22.156]}'), 
				(q_deg_id, 'continuous usage based v9','experimentation', '{"q_coef":[-2.2579e-07, 0.00012841, 22.038]}'), 
				(q_deg_id, 'continuous usage based v10','experimentation', '{"q_coef":[-2.1245e-07, -3.4485e-05, 22.265]}'), 
				(q_deg_id, 'continuous usage based v11','experimentation', '{"q_coef":[-3.8312e-07, 0.00030525, 22.001]}'), 
				(q_deg_id, 'continuous usage based v12','experimentation', '{"q_coef":[-2.0152e-07, 0.00011599, 22.043]}'), 
				(q_deg_id, 'continuous usage based v13','experimentation', '{"q_coef":[-2.6383e-07, 0.00025113, 22.316]}'), 
				(q_deg_id, 'continuous usage based v14','experimentation', '{"q_coef":[-1.9644e-07, 0.00012371, 22.024]}'), 
				(q_deg_id, 'continuous usage based v15','experimentation', '{"q_coef":[-2.698e-07, 0.00027073, 22.067]}'), 
				(q_deg_id, 'continuous usage based v16','experimentation', '{"q_coef":[-3.0568e-07, 0.00018225, 21.999]}'), 
				(q_deg_id, 'continuous usage based v17','experimentation', '{"q_coef":[-2.2463e-07, 0.00024673, 22.01]}'), 
				(q_deg_id, 'continuous usage based v18','experimentation', '{"q_coef":[-2.1259e-07, 0.00024519, 22.052]}'), 
				(q_deg_id, 'continuous usage based v19','experimentation', '{"q_coef":[-2.4456e-07, 1.1158e-05, 22.266]}'), 
				(q_deg_id, 'continuous usage based v20','experimentation', '{"q_coef":[-3.2731e-07, 0.00040936, 21.985]}'), 
				(q_deg_id, 'continuous usage based v21','experimentation', '{"q_coef":[-3.1822e-07, 0.0002692, 21.996]}'), 
				(q_deg_id, 'continuous usage based v22','experimentation', '{"q_coef":[-1.9867e-07, 0.00018712, 22.108]}'), 
				(q_deg_id, 'continuous usage based v23','experimentation', '{"q_coef":[-2.5529e-07, 0.00011922, 22.042]}'), 
				(q_deg_id, 'continuous usage based v24','experimentation', '{"q_coef":[-2.7603e-07, 0.00016847, 22.138]}'), 
				(q_deg_id, 'continuous usage based v25','experimentation', '{"q_coef":[-2.7725e-07, 0.00016742, 22.047]}'), 
				(q_deg_id, 'continuous usage based v26','experimentation', '{"q_coef":[-2.94e-07, 0.0002807, 22.035]}'), 
				(q_deg_id, 'continuous usage based v27','experimentation', '{"q_coef":[-2.804e-07, 0.00012701, 22.377]}'), 
				(q_deg_id, 'continuous usage based v28','experimentation', '{"q_coef":[-2.5502e-07, 0.00017579, 22.075]}'), 
				(q_deg_id, 'continuous usage based v29','experimentation', '{"q_coef":[-2.0989e-07, 9.8453e-05, 22.056]}'), 
				(q_deg_id, 'continuous usage based v30','experimentation', '{"q_coef":[-1.8723e-07, 4.9151e-05, 22.323]}'), 
				(q_deg_id, 'continuous usage based v31','experimentation', '{"q_coef":[-2.6706e-07, 0.00022269, 22.037]}'), 
				(q_deg_id, 'continuous usage based v32','experimentation', '{"q_coef":[-2.2291e-07, -2.1074e-05, 22.239]}'), 
				(q_deg_id, 'continuous usage based v33','experimentation', '{"q_coef":[-2.4769e-07, 0.00019795, 22.021]}'), 
				(q_deg_id, 'continuous usage based v34','experimentation', '{"q_coef":[-1.493e-07, 4.9594e-05, 22.043]}'), 
				(q_deg_id, 'continuous usage based v35','experimentation', '{"q_coef":[-2.4435e-07, 0.00019649, 22.18]}'), 
				(q_deg_id, 'continuous usage based v36','experimentation', '{"q_coef":[-2.258e-07, -4.8861e-05, 22.079]}'), 
				(q_deg_id, 'continuous usage based v37','experimentation', '{"q_coef":[-2.4593e-07, 0.0001427, 22.048]}'), 
				(q_deg_id, 'continuous usage based v38','experimentation', '{"q_coef":[-2.6146e-07, 0.00018312, 22.032]}'), 
				(q_deg_id, 'continuous usage based v39','experimentation', '{"q_coef":[-2.418e-07, 0.00029457, 22.304]}'), 
				(q_deg_id, 'continuous usage based v40','experimentation', '{"q_coef":[-2.5268e-07, -9.3172e-06, 22.417]}'), 
				(q_deg_id, 'continuous usage based v41','experimentation', '{"q_coef":[-2.9247e-07, 0.00015378, 22.19]}'), 
				(q_deg_id, 'continuous usage based v42','experimentation', '{"q_coef":[-2.9094e-07, 0.00034185, 21.977]}'), 
				(q_deg_id, 'continuous usage based v43','experimentation', '{"q_coef":[-3.5276e-07, 0.00026037, 21.996]}'), 
				(q_deg_id, 'continuous usage based v44','experimentation', '{"q_coef":[-2.2276e-07, 0.00010628, 22.063]}'), 
				(q_deg_id, 'continuous usage based v45','experimentation', '{"q_coef":[-2.2881e-07, 0.00031787, 22.264]}'), 
				(q_deg_id, 'continuous usage based v46','experimentation', '{"q_coef":[-3.8328e-07, 0.00012019, 22.057]}'), 
				(q_deg_id, 'continuous usage based v47','experimentation', '{"q_coef":[-2.8472e-07, 0.00027558, 22.139]}'), 
				(q_deg_id, 'continuous usage based v48','experimentation', '{"q_coef":[-2.6094e-07, 4.4985e-05, 22.481]}'), 
				(q_deg_id, 'continuous usage based v49','experimentation', '{"q_coef":[-2.6035e-07, 0.00025114, 22.158]}'), 
				(q_deg_id, 'continuous usage based v50','experimentation', '{"q_coef":[-3.3557e-07, 0.00010062, 22.06]}'), 
				(q_deg_id, 'continuous usage based v51','experimentation', '{"q_coef":[-4.1174e-07, 0.00042333, 22.104]}'), 
				(q_deg_id, 'continuous usage based v52','experimentation', '{"q_coef":[-2.2797e-07, 0.00022527, 22.138]}'), 
				(q_deg_id, 'continuous usage based v53','experimentation', '{"q_coef":[-2.7947e-07, 0.00028487, 22.495]}');

		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(q_deg_id, 'continuous usage based v54','NASA prognostics data set', '{"q_coef":[-3.191e-07, -0.00013332, 21.79]}'), 
				(q_deg_id, 'continuous usage based v55','NASA prognostics data set', '{"q_coef":[-4.75e-07, 0.0001639, 21.789]}'), 
				(q_deg_id, 'continuous usage based v56','NASA prognostics data set', '{"q_coef":[-3.5212e-07, -6.4532e-05, 21.975]}'), 
				(q_deg_id, 'continuous usage based v57','NASA prognostics data set', '{"q_coef":[-3.9358e-07, 0.00023988, 22.151]}'), 
				(q_deg_id, 'continuous usage based v58','NASA prognostics data set', '{"q_coef":[-3.3737e-07, -7.0471e-05, 22.426]}'), 
				(q_deg_id, 'continuous usage based v59','NASA prognostics data set', '{"q_coef":[-3.2634e-07, 5.4828e-06, 21.942]}'), 
				(q_deg_id, 'continuous usage based v60','NASA prognostics data set', '{"q_coef":[-4.2623e-07, 9.5727e-05, 21.799]}'), 
				(q_deg_id, 'continuous usage based v61','NASA prognostics data set', '{"q_coef":[-3.8702e-07, 1.0279e-05, 22.481]}'), 
				(q_deg_id, 'continuous usage based v62','NASA prognostics data set', '{"q_coef":[-3.1175e-07, -0.00020311, 22.073]}'), 
				(q_deg_id, 'continuous usage based v63','NASA prognostics data set', '{"q_coef":[-2.969e-07, -0.00016466, 22.154]}'), 
				(q_deg_id, 'continuous usage based v64','NASA prognostics data set', '{"q_coef":[-4.1494e-07, 7.1112e-05, 22.216]}'), 
				(q_deg_id, 'continuous usage based v65','NASA prognostics data set', '{"q_coef":[-3.1411e-07, 1.2429e-05, 22.337]}'), 
				(q_deg_id, 'continuous usage based v66','NASA prognostics data set', '{"q_coef":[-3.6363e-07, -6.2444e-05, 22.368]}'),
				(q_deg_id, 'continuous usage based v67','NASA prognostics data set', '{"q_coef":[-4.2027e-07, 0.00012293, 22.277]}'), 
				(q_deg_id, 'continuous usage based v68','NASA prognostics data set', '{"q_coef":[-3.0471e-07, -5.2655e-05, 21.879]}'), 
				(q_deg_id, 'continuous usage based v69','NASA prognostics data set', '{"q_coef":[-4.0727e-07, 0.0001426, 21.947]}'), 
				(q_deg_id, 'continuous usage based v70','NASA prognostics data set', '{"q_coef":[-4.3942e-07, 4.7374e-06, 22.481]}'), 
				(q_deg_id, 'continuous usage based v71','NASA prognostics data set', '{"q_coef":[-2.6276e-07, -0.00030654, 22.555]}'), 
				(q_deg_id, 'continuous usage based v72','NASA prognostics data set', '{"q_coef":[-4.2984e-07, 0.00013569, 21.887]}'), 
				(q_deg_id, 'continuous usage based v73','NASA prognostics data set', '{"q_coef":[-5.2793e-07, 0.00030695, 21.818]}'), 
				(q_deg_id, 'continuous usage based v74','NASA prognostics data set', '{"q_coef":[-3.843e-07, 1.7369e-05, 22.131]}'), 
				(q_deg_id, 'continuous usage based v75','NASA prognostics data set', '{"q_coef":[-2.9939e-07, -2.2592e-06, 22.145]}'),
				(q_deg_id, 'continuous usage based v76','NASA prognostics data set', '{"q_coef":[-2.9775e-07, -0.00015524, 22.247]}'),
				(q_deg_id, 'continuous usage based v77','NASA prognostics data set', '{"q_coef":[-3.1513e-07, -0.00016422, 21.857]}'), 
				(q_deg_id, 'continuous usage based v78','NASA prognostics data set', '{"q_coef":[-4.238e-07, 0.00012079, 21.962]}'), 
				(q_deg_id, 'continuous usage based v79','NASA prognostics data set', '{"q_coef":[-4.4041e-07, -5.115e-05, 22.494]}'),
				(q_deg_id, 'continuous usage based v80','NASA prognostics data set', '{"q_coef":[-3.7765e-07, -8.7253e-05, 22.42]}'), 
				(q_deg_id, 'continuous usage based v81','NASA prognostics data set', '{"q_coef":[-3.9416e-07, 0.00025881, 21.793]}'), 
				(q_deg_id, 'continuous usage based v82','NASA prognostics data set', '{"q_coef":[-4.506e-07, 0.00017377, 21.985]}'), 
				(q_deg_id, 'continuous usage based v83','NASA prognostics data set', '{"q_coef":[-3.9432e-07, 0.00013273, 22.209]}'), 
				(q_deg_id, 'continuous usage based v84','NASA prognostics data set', '{"q_coef":[-3.7108e-07, -2.9584e-05, 22.445]}'), 
				(q_deg_id, 'continuous usage based v85','NASA prognostics data set', '{"q_coef":[-3.1957e-07, -4.8006e-05, 22.45]}'), 
				(q_deg_id, 'continuous usage based v86','NASA prognostics data set', '{"q_coef":[-3.7418e-07, -4.3055e-05, 21.789]}'),
				(q_deg_id, 'continuous usage based v87','NASA prognostics data set', '{"q_coef":[-2.7278e-07, -0.00026678, 21.854]}'), 
				(q_deg_id, 'continuous usage based v88','NASA prognostics data set', '{"q_coef":[-3.1528e-07, -0.000117, 22.354]}'), 
				(q_deg_id, 'continuous usage based v89','NASA prognostics data set', '{"q_coef":[-2.4633e-07, -0.00020162, 21.911]}'), 
				(q_deg_id, 'continuous usage based v90','NASA prognostics data set', '{"q_coef":[-3.4689e-07, -5.4951e-05, 22.182]}'), 
				(q_deg_id, 'continuous usage based v91','NASA prognostics data set', '{"q_coef":[-3.6036e-07, 3.7481e-05, 22.584]}'), 
				(q_deg_id, 'continuous usage based v92','NASA prognostics data set', '{"q_coef":[-3.5293e-07, 3.001e-05, 22.404]}'), 
				(q_deg_id, 'continuous usage based v93','NASA prognostics data set', '{"q_coef":[-5.279e-07, 0.00017683, 21.563]}'), 
				(q_deg_id, 'continuous usage based v94','NASA prognostics data set', '{"q_coef":[-4.6502e-07, 0.00012135, 22.011]}'), 
				(q_deg_id, 'continuous usage based v95','NASA prognostics data set', '{"q_coef":[-3.1929e-07, 6.5267e-05, 22.303]}'), 
				(q_deg_id, 'continuous usage based v96','NASA prognostics data set', '{"q_coef":[-2.7403e-07, -0.00022072, 22.392]}'), 
				(q_deg_id, 'continuous usage based v97','NASA prognostics data set', '{"q_coef":[-3.1557e-07, -8.0759e-05, 22.261]}'), 
				(q_deg_id, 'continuous usage based v98','NASA prognostics data set', '{"q_coef":[-3.4941e-07, -6.2977e-05, 22.46]}'), 
				(q_deg_id, 'continuous usage based v99','NASA prognostics data set', '{"q_coef":[-3.5983e-07, -0.00020625, 22.238]}'), 
				(q_deg_id, 'continuous usage based v100','NASA prognostics data set', '{"q_coef":[-5.12e-07, 0.00034588, 22.022]}'), 
				(q_deg_id, 'continuous usage based v101','NASA prognostics data set', '{"q_coef":[-4.1916e-07, -2.879e-05, 21.994]}'), 
				(q_deg_id, 'continuous usage based v102','NASA prognostics data set', '{"q_coef":[-3.7792e-07, 0.00015204, 22.101]}'), 
				(q_deg_id, 'continuous usage based v103','NASA prognostics data set', '{"q_coef":[-5.669e-07, 0.00047346, 22.035]}');
						
			
		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(m_deg_id, 'continuous usage based v9','experimentation', '{"r_coef":[6.9045e-09, 1.7015e-05, 0.25578]}'), 
				(m_deg_id, 'continuous usage based v10','experimentation', '{"r_coef":[8.1399e-09, -1.009e-05, 0.27184]}'), 
				(m_deg_id, 'continuous usage based v11','experimentation', '{"r_coef":[7.7477e-09, -2.9757e-06, 0.27219]}'), 
				(m_deg_id, 'continuous usage based v12','experimentation', '{"r_coef":[6.0664e-09, -6.405e-06, 0.28394]}'), 
				(m_deg_id, 'continuous usage based v13','experimentation', '{"r_coef":[1.0917e-08, 4.1796e-05, 0.25302]}'), 
				(m_deg_id, 'continuous usage based v14','experimentation', '{"r_coef":[2.3035e-08, -1.9239e-05, 0.29315]}'), 
				(m_deg_id, 'continuous usage based v15','experimentation', '{"r_coef":[2.7533e-08, -8.2747e-06, 0.28568]}'), 
				(m_deg_id, 'continuous usage based v16','experimentation', '{"r_coef":[2.2434e-08, -3.265e-05, 0.29907]}'), 
				(m_deg_id, 'continuous usage based v17','experimentation', '{"r_coef":[2.1013e-08, -2.5613e-05, 0.2866]}'), 
				(m_deg_id, 'continuous usage based v18','experimentation', '{"r_coef":[1.0779e-08, -1.6212e-05, 0.2837]}'), 
				(m_deg_id, 'continuous usage based v19','experimentation', '{"r_coef":[1.2817e-08, 2.7106e-05, 0.2589]}'), 
				(m_deg_id, 'continuous usage based v20','experimentation', '{"r_coef":[1.6241e-08, -1.9281e-05, 0.28353]}'), 
				(m_deg_id, 'continuous usage based v21','experimentation', '{"r_coef":[1.1212e-08, -3.0939e-06, 0.26997]}'), 
				(m_deg_id, 'continuous usage based v22','experimentation', '{"r_coef":[4.7079e-09, 4.2053e-06, 0.26251]}'), 
				(m_deg_id, 'continuous usage based v23','experimentation', '{"r_coef":[1.7558e-08, -3.7024e-05, 0.29816]}'), 
				(m_deg_id, 'continuous usage based v24','experimentation', '{"r_coef":[2.4736e-08, -3.0064e-05, 0.28616]}'), 
				(m_deg_id, 'continuous usage based v25','experimentation', '{"r_coef":[8.9292e-09, -1.2364e-05, 0.28608]}'), 
				(m_deg_id, 'continuous usage based v26','experimentation', '{"r_coef":[1.1514e-08, -2.678e-05, 0.28982]}'), 
				(m_deg_id, 'continuous usage based v27','experimentation', '{"r_coef":[1.4837e-08, -3.7862e-05, 0.29317]}'), 
				(m_deg_id, 'continuous usage based v28','experimentation', '{"r_coef":[8.9758e-09, 2.4582e-05, 0.25187]}'), 
				(m_deg_id, 'continuous usage based v29','experimentation', '{"r_coef":[1.0608e-08, -1.2811e-05, 0.27366]}'), 
				(m_deg_id, 'continuous usage based v30','experimentation', '{"r_coef":[1.876e-08, -1.9227e-05, 0.28863]}'), 
				(m_deg_id, 'continuous usage based v31','experimentation', '{"r_coef":[5.7269e-09, 2.7589e-06, 0.26333]}'), 
				(m_deg_id, 'continuous usage based v32','experimentation', '{"r_coef":[1.2326e-08, 8.9673e-06, 0.26028]}'), 
				(m_deg_id, 'continuous usage based v33','experimentation', '{"r_coef":[4.5941e-09, 3.7954e-05, 0.2654]}'), 
				(m_deg_id, 'continuous usage based v34','experimentation', '{"r_coef":[1.29e-08, 3.2719e-06, 0.26315]}'), 
				(m_deg_id, 'continuous usage based v35','experimentation', '{"r_coef":[6.883e-09, 1.9555e-05, 0.26342]}'), 
				(m_deg_id, 'continuous usage based v36','experimentation', '{"r_coef":[1.4408e-08, -3.1841e-05, 0.29575]}'), 
				(m_deg_id, 'continuous usage based v37','experimentation', '{"r_coef":[4.9947e-09, -8.0626e-06, 0.27637]}'), 
				(m_deg_id, 'continuous usage based v38','experimentation', '{"r_coef":[3.159e-08, -6.5279e-05, 0.31638]}'), 
				(m_deg_id, 'continuous usage based v39','experimentation', '{"r_coef":[7.2061e-09, -9.1833e-06, 0.2761]}'), 
				(m_deg_id, 'continuous usage based v40','experimentation', '{"r_coef":[1.7781e-08, -5.1845e-05, 0.31284]}'), 
				(m_deg_id, 'continuous usage based v41','experimentation', '{"r_coef":[9.1929e-09, -7.2622e-06, 0.27013]}'), 
				(m_deg_id, 'continuous usage based v42','experimentation', '{"r_coef":[9.8502e-09, -1.2017e-05, 0.27822]}'), 
				(m_deg_id, 'continuous usage based v43','experimentation', '{"r_coef":[6.372e-09, 3.1826e-06, 0.26307]}'), 
				(m_deg_id, 'continuous usage based v44','experimentation', '{"r_coef":[6.267e-09, 3.0607e-05, 0.25677]}'), 
				(m_deg_id, 'continuous usage based v45','experimentation', '{"r_coef":[8.9013e-09, 1.5916e-06, 0.26402]}'), 
				(m_deg_id, 'continuous usage based v46','experimentation', '{"r_coef":[1.1053e-08, 2.0638e-06, 0.27535]}'), 
				(m_deg_id, 'continuous usage based v47','experimentation', '{"r_coef":[2.2184e-08, -4.9648e-05, 0.30956]}'), 
				(m_deg_id, 'continuous usage based v48','experimentation', '{"r_coef":[8.1929e-09, 4.0423e-05, 0.25373]}'), 
				(m_deg_id, 'continuous usage based v49','experimentation', '{"r_coef":[9.6565e-09, -1.3999e-05, 0.27463]}'), 
				(m_deg_id, 'continuous usage based v50','experimentation', '{"r_coef":[9.0974e-09, 1.582e-05, 0.26142]}'), 
				(m_deg_id, 'continuous usage based v51','experimentation', '{"r_coef":[8.271e-09, 9.379e-06, 0.26133]}'), 
				(m_deg_id, 'continuous usage based v52','experimentation', '{"r_coef":[5.7142e-09, -6.9297e-06, 0.27376]}'), 
				(m_deg_id, 'continuous usage based v53','experimentation', '{"r_coef":[2.6113e-08, -4.8278e-05, 0.29913]}'), 
				(m_deg_id, 'continuous usage based v54','experimentation', '{"r_coef":[1.0005e-08, 2.266e-05, 0.26276]}'), 
				(m_deg_id, 'continuous usage based v55','experimentation', '{"r_coef":[7.1654e-09, 1.0345e-05, 0.26344]}'), 
				(m_deg_id, 'continuous usage based v56','experimentation', '{"r_coef":[8.4245e-09, -1.129e-05, 0.27816]}'), 
				(m_deg_id, 'continuous usage based v57','experimentation', '{"r_coef":[1.4498e-08, -3.836e-05, 0.29374]}'), 
				(m_deg_id, 'continuous usage based v58','experimentation', '{"r_coef":[5.103e-09, 2.2832e-05, 0.25558]}');



		insert into process_tb("type_id", "description", "source", "parameters") 
			values 
				(m_deg_id, 'continuous usage based v59','experimentation', '{"r_coef":[4.463e-09, 1.7906e-05, 0.26406]}'), 
				(m_deg_id, 'continuous usage based v60','experimentation', '{"r_coef":[5.2827e-09, 1.0225e-05, 0.26731]}'), 
				(m_deg_id, 'continuous usage based v61','experimentation', '{"r_coef":[4.5443e-09, 1.4944e-05, 0.25719]}'), 
				(m_deg_id, 'continuous usage based v62','experimentation', '{"r_coef":[2.1e-09, 3.865e-05, 0.27122]}'), 
				(m_deg_id, 'continuous usage based v63','experimentation', '{"r_coef":[3.0151e-09, 4.3915e-05, 0.24904]}'), 
				(m_deg_id, 'continuous usage based v64','experimentation', '{"r_coef":[4.3418e-09, 8.9908e-06, 0.26357]}'), 
				(m_deg_id, 'continuous usage based v65','experimentation', '{"r_coef":[5.2489e-09, 1.1127e-05, 0.26076]}'), 
				(m_deg_id, 'continuous usage based v66','experimentation', '{"r_coef":[4.0262e-09, 1.8536e-06, 0.27214]}'), 
				(m_deg_id, 'continuous usage based v67','experimentation', '{"r_coef":[6.2158e-09, 2.895e-05, 0.25505]}'), 
				(m_deg_id, 'continuous usage based v68','experimentation', '{"r_coef":[4.1553e-09, 2.5395e-05, 0.2574]}'), 
				(m_deg_id, 'continuous usage based v69','experimentation', '{"r_coef":[8.5314e-09, -8.9317e-06, 0.27531]}'), 
				(m_deg_id, 'continuous usage based v70','experimentation', '{"r_coef":[3.7886e-09, 1.708e-05, 0.26105]}'), 
				(m_deg_id, 'continuous usage based v71','experimentation', '{"r_coef":[5.0273e-09, 1.1654e-05, 0.25957]}'), 
				(m_deg_id, 'continuous usage based v72','experimentation', '{"r_coef":[4.3894e-09, 1.8088e-05, 0.26013]}'), 
				(m_deg_id, 'continuous usage based v73','experimentation', '{"r_coef":[5.3582e-09, 1.7134e-05, 0.26042]}'), 
				(m_deg_id, 'continuous usage based v74','experimentation', '{"r_coef":[4.3013e-09, 3.2906e-05, 0.25131]}'), 
				(m_deg_id, 'continuous usage based v75','experimentation', '{"r_coef":[6.6488e-09, 1.5868e-06, 0.26648]}'), 
				(m_deg_id, 'continuous usage based v76','experimentation', '{"r_coef":[5.9862e-09, 7.7731e-06, 0.26547]}'), 
				(m_deg_id, 'continuous usage based v77','experimentation', '{"r_coef":[5.9367e-09, 7.6854e-06, 0.2605]}'), 
				(m_deg_id, 'continuous usage based v78','experimentation', '{"r_coef":[4.4933e-09, 1.4363e-05, 0.26353]}'), 
				(m_deg_id, 'continuous usage based v79','experimentation', '{"r_coef":[5.0158e-09, 8.7383e-06, 0.25771]}'), 
				(m_deg_id, 'continuous usage based v80','experimentation', '{"r_coef":[9.2525e-09, -8.8592e-06, 0.2806]}'), 
				(m_deg_id, 'continuous usage based v81','experimentation', '{"r_coef":[5.3569e-09, 1.6287e-05, 0.25747]}'), 
				(m_deg_id, 'continuous usage based v82','experimentation', '{"r_coef":[7.6422e-09, -7.5522e-06, 0.27377]}'), 
				(m_deg_id, 'continuous usage based v83','experimentation', '{"r_coef":[5.5357e-09, 2.0171e-05, 0.25225]}'), 
				(m_deg_id, 'continuous usage based v84','experimentation', '{"r_coef":[4.3439e-09, 1.9525e-05, 0.26091]}'), 
				(m_deg_id, 'continuous usage based v85','experimentation', '{"r_coef":[6.0067e-09, -7.8655e-06, 0.2682]}'), 
				(m_deg_id, 'continuous usage based v86','experimentation', '{"r_coef":[2.727e-09, 4.345e-05, 0.25552]}'), 
				(m_deg_id, 'continuous usage based v87','experimentation', '{"r_coef":[6.0258e-09, 2.7399e-05, 0.26721]}'), 
				(m_deg_id, 'continuous usage based v88','experimentation', '{"r_coef":[5.4383e-09, 8.1876e-06, 0.26631]}'), 
				(m_deg_id, 'continuous usage based v89','experimentation', '{"r_coef":[5.9361e-09, 6.4148e-06, 0.26254]}'), 
				(m_deg_id, 'continuous usage based v90','experimentation', '{"r_coef":[3.5657e-09, 3.661e-05, 0.25797]}'), 
				(m_deg_id, 'continuous usage based v91','experimentation', '{"r_coef":[3.3328e-09, 6.3215e-06, 0.25862]}'), 
				(m_deg_id, 'continuous usage based v92','experimentation', '{"r_coef":[3.4718e-09, 4.4836e-05, 0.25118]}'), 
				(m_deg_id, 'continuous usage based v93','experimentation', '{"r_coef":[5.3402e-09, 2.2941e-05, 0.25055]}'), 
				(m_deg_id, 'continuous usage based v94','experimentation', '{"r_coef":[5.4104e-09, 6.3773e-06, 0.26445]}'), 
				(m_deg_id, 'continuous usage based v95','experimentation', '{"r_coef":[2.0181e-09, 3.9479e-05, 0.26375]}'), 
				(m_deg_id, 'continuous usage based v96','experimentation', '{"r_coef":[3.8334e-09, 6.0894e-05, 0.25711]}'), 
				(m_deg_id, 'continuous usage based v97','experimentation', '{"r_coef":[6.1441e-09, -3.4763e-06, 0.26851]}'), 
				(m_deg_id, 'continuous usage based v98','experimentation', '{"r_coef":[7.3602e-09, -2.3269e-06, 0.27223]}'), 
				(m_deg_id, 'continuous usage based v99','experimentation', '{"r_coef":[3.9143e-09, 1.771e-05, 0.25988]}'), 
				(m_deg_id, 'continuous usage based v100','experimentation', '{"r_coef":[2.4051e-09, 6.1877e-05, 0.26515]}'), 
				(m_deg_id, 'continuous usage based v101','experimentation', '{"r_coef":[4.5074e-09, 2.3339e-05, 0.25091]}'), 
				(m_deg_id, 'continuous usage based v102','experimentation', '{"r_coef":[4.9683e-09, 2.545e-05, 0.26003]}'), 
				(m_deg_id, 'continuous usage based v103','experimentation', '{"r_coef":[4.6984e-09, 1.2255e-05, 0.26782]}'), 
				(m_deg_id, 'continuous usage based v104','experimentation', '{"r_coef":[5.1161e-09, -3.397e-07, 0.26545]}'), 
				(m_deg_id, 'continuous usage based v105','experimentation', '{"r_coef":[3.6789e-09, 4.1958e-05, 0.24969]}'), 
				(m_deg_id, 'continuous usage based v106','experimentation', '{"r_coef":[6.6797e-09, 6.1006e-06, 0.26038]}'), 
				(m_deg_id, 'continuous usage based v107','experimentation', '{"r_coef":[8.9674e-09, -1.4149e-06, 0.27114]}'), 
				(m_deg_id, 'continuous usage based v108','experimentation', '{"r_coef":[4.1374e-09, 1.3619e-05, 0.26331]}');
					
end $$;

do $$
	declare 
		e_deg_id integer := (select id from process_type_tb ptt where "type" ilike 'failure probability');
		wind_id integer := (select id from process_type_tb ptt where "type" ilike 'environment' and "subtype" ilike 'wind' and "subtype2" ilike 'gust');
		wind2_id integer := (select id from process_type_tb ptt where "type" ilike 'environment' and "subtype" ilike 'wind' and "subtype2" ilike 'constant');
	begin	
insert into process_tb("type_id", "description", "source", "parameters") 
		values 
			(e_deg_id, 'usage based failure probability v0','experimentation', '{"e_coef":[4783.0, 0.98273, 0.0025357]}'), 
			(e_deg_id, 'usage based failure probability v1','experimentation', '{"e_coef":[7774.6, 0.98716, 0.0042121]}'), 
			(e_deg_id, 'usage based failure probability v2','experimentation', '{"e_coef":[4793.2, 0.98622, 0.0048864]}'), 
			(e_deg_id, 'usage based failure probability v3','experimentation', '{"e_coef":[6295.4, 0.98784, 0.008436]}'), 
			(e_deg_id, 'usage based failure probability v4','experimentation', '{"e_coef":[6177.5, 0.98423, 0.0032623]}'), 
			(e_deg_id, 'usage based failure probability v5','experimentation', '{"e_coef":[5893.9, 0.98706, 0.0067179]}'), 
			(e_deg_id, 'usage based failure probability v6','experimentation', '{"e_coef":[5785.1, 0.98444, 0.0038932]}'), 
			(e_deg_id, 'usage based failure probability v7','experimentation', '{"e_coef":[6280.6, 0.98434, 0.0036754]}'), 
			(e_deg_id, 'usage based failure probability v8','experimentation', '{"e_coef":[7290.5, 0.98556, 0.0069048]}'), 
			(e_deg_id, 'usage based failure probability v9','experimentation', '{"e_coef":[5586.5, 0.98456, 0.0039479]}'), 
			(e_deg_id, 'usage based failure probability v10','experimentation', '{"e_coef":[4494.2, 0.98644, 0.004879]}'), 
			(e_deg_id, 'usage based failure probability v11','experimentation', '{"e_coef":[6240.8, 0.99638, 0.0015347]}'),
			(e_deg_id, 'usage based failure probability v12','experimentation', '{"e_coef":[6902.0, 1.1136, 0.00075671]}'), 
			(e_deg_id, 'usage based failure probability v13','experimentation', '{"e_coef":[3697.6, 0.98775, 0.005472]}'),
			(e_deg_id, 'usage based failure probability v14','experimentation', '{"e_coef":[5095.7, 0.98804, 0.0068652]}'), 
			(e_deg_id, 'usage based failure probability v15','experimentation', '{"e_coef":[8381.2, 0.98743, 0.0058909]}'), 
			(e_deg_id, 'usage based failure probability v16','experimentation', '{"e_coef":[5992.9, 0.9866, 0.006313]}'), 
			(e_deg_id, 'usage based failure probability v17','experimentation', '{"e_coef":[2901.0, 0.9873, 0.0048649]}'), 
			(e_deg_id, 'usage based failure probability v18','experimentation', '{"e_coef":[4797.4, 0.98941, 0.0082304]}'),
			(e_deg_id, 'usage based failure probability v19','experimentation', '{"e_coef":[8190.2, 0.98535, 0.0083083]}'), 
			(e_deg_id, 'usage based failure probability v20','experimentation', '{"e_coef":[6691.3, 0.98591, 0.0064348]}'), 
			(e_deg_id, 'usage based failure probability v21','experimentation', '{"e_coef":[6646.2, 0.99387, 0.0018983]}'), 
			(e_deg_id, 'usage based failure probability v22','experimentation', '{"e_coef":[4192.6, 0.98042, 0.0016824]}'), 
			(e_deg_id, 'usage based failure probability v23','experimentation', '{"e_coef":[6392.8, 0.9865, 0.0067523]}'), 
			(e_deg_id, 'usage based failure probability v24','experimentation', '{"e_coef":[2650.4, 0.9767, 0.0018745]}'), 
			(e_deg_id, 'usage based failure probability v25','experimentation', '{"e_coef":[6484.4, 0.98467, 0.0044032]}'), 
			(e_deg_id, 'usage based failure probability v26','experimentation', '{"e_coef":[8176.4, 0.98832, 0.0048348]}'), 
			(e_deg_id, 'usage based failure probability v27','experimentation', '{"e_coef":[7546.8, 1.0033, 0.0022289]}'), 
			(e_deg_id, 'usage based failure probability v28','experimentation', '{"e_coef":[7491.9, 0.98581, 0.0078583]}'), 
			(e_deg_id, 'usage based failure probability v29','experimentation', '{"e_coef":[7291.3, 0.98574, 0.007253]}'),
			(e_deg_id, 'usage based failure probability v30','experimentation', '{"e_coef":[4873.5, 0.98305, 0.0016616]}'),
			(e_deg_id, 'usage based failure probability v31','experimentation', '{"e_coef":[6289.8, 0.98554, 0.0054425]}'), 
			(e_deg_id, 'usage based failure probability v32','experimentation', '{"e_coef":[7682.3, 0.98536, 0.0051978]}'), 
			(e_deg_id, 'usage based failure probability v33','experimentation', '{"e_coef":[6675.8, 0.98479, 0.0034693]}'), 
			(e_deg_id, 'usage based failure probability v34','experimentation', '{"e_coef":[6385.4, 0.98474, 0.0044861]}'), 
			(e_deg_id, 'usage based failure probability v35','experimentation', '{"e_coef":[4878.6, 0.98252, 0.0021732]}'), 
			(e_deg_id, 'usage based failure probability v36','experimentation', '{"e_coef":[6384.3, 0.98463, 0.0042961]}'),
			(e_deg_id, 'usage based failure probability v37','experimentation', '{"e_coef":[6295.1, 0.98763, 0.0081214]}'), 
			(e_deg_id, 'usage based failure probability v38','experimentation', '{"e_coef":[4878.3, 0.98824, 0.0011361]}'), 
			(e_deg_id, 'usage based failure probability v39','experimentation', '{"e_coef":[5170.4, 0.98349, 0.001913]}'),
			(e_deg_id, 'usage based failure probability v40','experimentation', '{"e_coef":[7986.7, 0.9853, 0.0066087]}'), 
			(e_deg_id, 'usage based failure probability v41','experimentation', '{"e_coef":[5692.7, 0.9865, 0.0058598]}'), 
			(e_deg_id, 'usage based failure probability v42','experimentation', '{"e_coef":[4892.5, 0.98598, 0.0047562]}'), 
			(e_deg_id, 'usage based failure probability v43','experimentation', '{"e_coef":[5747.7, 0.99209, 0.0014395]}'), 
			(e_deg_id, 'usage based failure probability v44','experimentation', '{"e_coef":[2403.6, 0.98792, 0.0051906]}'),
			(e_deg_id, 'usage based failure probability v45','experimentation', '{"e_coef":[5685.8, 0.98451, 0.0039289]}'), 
			(e_deg_id, 'usage based failure probability v46','experimentation', '{"e_coef":[6481.1, 0.98448, 0.0038963]}'), 
			(e_deg_id, 'usage based failure probability v47','experimentation', '{"e_coef":[2102.3, 0.99108, 0.0081143]}'), 
			(e_deg_id, 'usage based failure probability v48','experimentation', '{"e_coef":[7578.9, 0.98567, 0.004551]}'), 
			(e_deg_id, 'usage based failure probability v49','experimentation', '{"e_coef":[7383.9, 0.985, 0.0051775]}'),
			(e_deg_id, 'usage based failure probability v50','experimentation', '{"e_coef":[6577.9, 0.98457, 0.0035989]}'), 
			(e_deg_id, 'usage based failure probability v51','experimentation', '{"e_coef":[4591.5, 0.98498, 0.0039224]}'), 
			(e_deg_id, 'usage based failure probability v52','experimentation', '{"e_coef":[4388.4, 0.98276, 0.0026856]}'), 
			(e_deg_id, 'usage based failure probability v53','experimentation', '{"e_coef":[4682.2, 0.98227, 0.002253]}'),
			(e_deg_id, 'usage based failure probability v54','experimentation', '{"e_coef":[5095.2, 0.98769, 0.0064729]}'), 
			(e_deg_id, 'usage based failure probability v55','experimentation', '{"e_coef":[5392.8, 0.98648, 0.0055526]}'), 
			(e_deg_id, 'usage based failure probability v56','experimentation', '{"e_coef":[4596.3, 0.9882, 0.0065211]}'), 
			(e_deg_id, 'usage based failure probability v57','experimentation', '{"e_coef":[5683.4, 0.98414, 0.0035442]}'),
			(e_deg_id, 'usage based failure probability v58','experimentation', '{"e_coef":[6569.4, 0.98541, 0.0028965]}'), 
			(e_deg_id, 'usage based failure probability v59','experimentation', '{"e_coef":[5695.3, 0.98788, 0.0074497]}'),
			(e_deg_id, 'usage based failure probability v60','experimentation', '{"e_coef":[4796.1, 0.98818, 0.0067014]}'),
			(e_deg_id, 'usage based failure probability v61','experimentation', '{"e_coef":[5194.6, 0.98737, 0.0062454]}'),
			(e_deg_id, 'usage based failure probability v62','experimentation', '{"e_coef":[7269.0, 0.98705, 0.0033233]}'),
			(e_deg_id, 'usage based failure probability v63','experimentation', '{"e_coef":[5956.0, 0.9875, 0.0018822]}'), 
			(e_deg_id, 'usage based failure probability v64','experimentation', '{"e_coef":[4790.6, 0.98496, 0.0039739]}'), 
			(e_deg_id, 'usage based failure probability v65','experimentation', '{"e_coef":[5386.4, 0.9844, 0.0037459]}'), 
			(e_deg_id, 'usage based failure probability v66','experimentation', '{"e_coef":[6994.0, 0.98681, 0.0083808]}'),
			(e_deg_id, 'usage based failure probability v67','experimentation', '{"e_coef":[5576.7, 0.98362, 0.0027358]}'), 
			(e_deg_id, 'usage based failure probability v68','experimentation', '{"e_coef":[5873.4, 0.98406, 0.0027042]}'), 
			(e_deg_id, 'usage based failure probability v69','experimentation', '{"e_coef":[4680.8, 0.98208, 0.002054]}'), 
			(e_deg_id, 'usage based failure probability v70','experimentation', '{"e_coef":[5983.9, 0.9844, 0.0038772]}'), 
			(e_deg_id, 'usage based failure probability v71','experimentation', '{"e_coef":[6075.0, 0.9842, 0.0029703]}'), 
			(e_deg_id, 'usage based failure probability v72','experimentation', '{"e_coef":[7188.0, 0.98516, 0.0059047]}'),
			(e_deg_id, 'usage based failure probability v73','experimentation', '{"e_coef":[5792.4, 0.98639, 0.0058523]}'), 
			(e_deg_id, 'usage based failure probability v74','experimentation', '{"e_coef":[4896.5, 0.98858, 0.0072715]}'), 
			(e_deg_id, 'usage based failure probability v75','experimentation', '{"e_coef":[4894.7, 0.98725, 0.0058413]}'), 
			(e_deg_id, 'usage based failure probability v76','experimentation', '{"e_coef":[5490.4, 0.98555, 0.0047734]}'), 
			(e_deg_id, 'usage based failure probability v77','experimentation', '{"e_coef":[6295.0, 0.9876, 0.008077]}'), 
			(e_deg_id, 'usage based failure probability v78','experimentation', '{"e_coef":[5396.0, 0.98831, 0.0075754]}'),
			(e_deg_id, 'usage based failure probability v79','experimentation', '{"e_coef":[6357.2, 0.98784, 0.0021568]}'), 
			(e_deg_id, 'usage based failure probability v80','experimentation', '{"e_coef":[5694.9, 0.98763, 0.0071361]}'),
			(e_deg_id, 'usage based failure probability v81','experimentation', '{"e_coef":[5191.9, 0.98594, 0.0049107]}'), 
			(e_deg_id, 'usage based failure probability v82','experimentation', '{"e_coef":[6395.3, 0.98775, 0.0085081]}'),
			(e_deg_id, 'usage based failure probability v83','experimentation', '{"e_coef":[7342.1, 1.0055, 0.0019648]}'), 
			(e_deg_id, 'usage based failure probability v84','experimentation', '{"e_coef":[5297.0, 0.9892, 0.0086617]}'), 
			(e_deg_id, 'usage based failure probability v85','experimentation', '{"e_coef":[5892.7, 0.98653, 0.0061177]}'), 
			(e_deg_id, 'usage based failure probability v86','experimentation', '{"e_coef":[6892.4, 0.9862, 0.0072053]}'), 
			(e_deg_id, 'usage based failure probability v87','experimentation', '{"e_coef":[5593.8, 0.987, 0.0062771]}'), 
			(e_deg_id, 'usage based failure probability v88','experimentation', '{"e_coef":[5850.3, 0.98992, 0.0016132]}'), 
			(e_deg_id, 'usage based failure probability v89','experimentation', '{"e_coef":[4597.8, 0.98972, 0.0083958]}'), 
			(e_deg_id, 'usage based failure probability v90','experimentation', '{"e_coef":[5192.6, 0.98625, 0.0051737]}'), 
			(e_deg_id, 'usage based failure probability v91','experimentation', '{"e_coef":[4996.9, 0.98901, 0.0079403]}'), 
			(e_deg_id, 'usage based failure probability v92','experimentation', '{"e_coef":[5744.2, 1.008, 0.0010408]}'), 
			(e_deg_id, 'usage based failure probability v93','experimentation', '{"e_coef":[5162.8, 0.9902, 0.0012103]}'), 
			(e_deg_id, 'usage based failure probability v94','experimentation', '{"e_coef":[5596.3, 0.98859, 0.0082477]}'),
			(e_deg_id, 'usage based failure probability v95','experimentation', '{"e_coef":[4973.0, 0.983, 0.0018261]}'), 
			(e_deg_id, 'usage based failure probability v96','experimentation', '{"e_coef":[4193.9, 0.98031, 0.0016074]}'), 
			(e_deg_id, 'usage based failure probability v97','experimentation', '{"e_coef":[4498.0, 0.98992, 0.0085711]}'),
			(e_deg_id, 'usage based failure probability v98','experimentation', '{"e_coef":[6234.7, 1.0058, 0.0012853]}'), 
			(e_deg_id, 'usage based failure probability v99','experimentation', '{"e_coef":[5590.0, 0.98545, 0.0047561]}');


	insert into process_tb(type_id, description, "source", parameters)
		values (wind_id, 'wind gusts v1', 'generated by experimentation', '{"x": [0, 3], "y": [0, 3], "z": [0, 0.3]}'),
		(wind_id, 'wind gusts v2', 'generated by experimentation', '{"x": [0, 3], "y": [0, 3], "z": [0, 0.3]}'),
		(wind_id, 'wind gusts v3', 'generated by experimentation', '{"x": [0, 4], "y": [0, 2], "z": [0, 0.5]}'),
		(wind_id, 'wind gusts v4', 'generated by experimentation', '{"x": [0, 2.5], "y": [0, 2.5], "z": [0, 0.2]}'),
		(wind_id, 'wind gusts v5', 'generated by experimentation', '{"x": [0, 1], "y": [0, 4], "z": [0, 0.4]}'),
		(wind_id, 'wind gusts v6', 'generated by experimentation', '{"x": [0, 4], "y": [0, 1], "z": [0, 0.25]}'),
		(wind_id, 'wind gusts v7', 'generated by experimentation', '{"x": [0, 3.75], "y": [0, 3.25], "z": [0, 0.45]}'),
		(wind_id, 'wind gusts v8', 'generated by experimentation', '{"x": [0, 4.25], "y": [0, 2.75], "z": [0, 0.2]}'),
		(wind_id, 'wind gusts v9', 'generated by experimentation', '{"x": [0, 1.5], "y": [0, 3.25], "z": [0, 0.35]}'),
		(wind_id, 'wind gusts v10', 'generated by experimentation', '{"x": [0, 5], "y": [0, 5], "z": [0, 0.6]}');

	-- insert into process_tb(type_id, description, "source", parameters)
	-- 	values (wind2_id, 'constant wind force applied to airframe', 'experimentation', '{"x": [0, 3], "y": [0, 3], "z": [0, 0.3]}'),

end $$;




/*
	Add some default asset types (i.e. types that we have models implemented for)
*/
insert into asset_type_tb("type", "subtype", "description")
	values ('airframe', 'octorotor', 'osmic_2016'),
		('battery', 'eqc', 'plett_2015'),
		('motor', 'dc', 'generic'),
		('esc', 'surrogate', 'generic'),
		('sensor', 'gps', 'generic'),
		('uav', 'system', '');


/*
    create the uav "assets" first
*/
do $$	
	declare 
		airframe_type_id integer := (select id from asset_type_tb where "type" ilike 'airframe');	 
		battery_type_id integer := (select id from asset_type_tb where "type" ilike 'battery');
		motor_type_id integer := (select id from asset_type_tb where "type" ilike 'motor');
		esc_type_id integer := (select id from asset_type_tb where "type" ilike 'esc');
		gps_type_id integer := (select id from asset_type_tb where "type" ilike 'sensor');
		uav_type_id integer := (select id from asset_type_tb where "type" ilike 'uav');
	begin
		insert into asset_tb("owner", "type_id", "process_id", "serial_number", "common_name")
		values (current_user, airframe_type_id, '{4}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, battery_type_id, '{8, 10}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, motor_type_id, '{11}', (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, gps_type_id, null, (select upper(substr(md5(random()::text), 0, 7))), 'default'),
			(current_user, uav_type_id, null, (select upper(substr(md5(random()::text), 0, 7))), 'default');
end $$;	


/*
    next, create the default components
*/
do $$
	declare 
		num_motors integer = 8;
		airframe_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'airframe') order by id desc limit 1);
		battery_id integer = (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'battery') order by id desc limit 1);
		motor_ids integer[] = (array(select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'motor') order by id desc limit 8));
		gps_id integer = (select id from  asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'sensor') order by id desc limit 1);
		uav_id integer := (select id from asset_tb where "type_id" = (select id from asset_type_tb where "type" ilike 'uav') order by id desc limit 1);
	begin
		insert into airframe_tb ("id", "num_motors")
			values (airframe_id, num_motors);
		insert into eqc_battery_tb ("id")
			values (battery_id);
		insert into dc_motor_tb (id, motor_number)
			values (motor_ids[1], 1),
				(motor_ids[2], 2),
				(motor_ids[3], 3),
				(motor_ids[4], 4),
				(motor_ids[5], 5),
				(motor_ids[6], 6),
				(motor_ids[7], 7),
				(motor_ids[8], 8);
		insert into sensor_tb("id") values (gps_id);
		insert into uav_tb("id", 
				"airframe_id", 
				"battery_id", 
				"m1_id",
				"m2_id",
				"m3_id",
				"m4_id",
				"m5_id",
				"m6_id",
				"m7_id",
				"m8_id",
				"gps_id")
			values (uav_id,
				airframe_id,
				battery_id,
				motor_ids[1],
				motor_ids[2],
				motor_ids[3],
				motor_ids[4],
				motor_ids[5],
				motor_ids[6],
				motor_ids[7],
				motor_ids[8],
				gps_id);	  
end $$;



/*
    include some different stop codes (not an exhaustive list, nothing is an exhaustive list...)
*/
insert into stop_code_tb ("description")
	values ('low soc'),
		('low voltage'),
		('position error'),
		('arrival success'),
		('position error variance'),
		('esc fault'),
		('low soh (battery)');


/*
    include a few different short trajectories
*/
insert into trajectory_tb ("path_distance",	"path_time", "risk_factor", "start", "destination", "x_waypoints", "y_waypoints", "x_ref_points", "y_ref_points", "sample_time", "reward")
	values (70.94, 0.91, 0.01, '{50, 25}', '{70, 90}', '{70}', '{90}', '{50.69,51.36,52.01,52.63,53.23,53.81,54.37,54.91,55.44,55.95,56.44,56.93,57.4,57.86,58.31,58.75,59.18,59.61,60.03,60.45,60.86,61.28,61.69,62.11,62.52,62.94,63.37,63.8,64.23,64.67,65.11,65.54,65.97,66.4,66.81,67.22,67.61,67.98,68.34,68.68,68.99,69.29,69.55,69.79,70,70.17,70.31,70.41,70.48,70.5,70.47,70.4,70.29,70.12}', '{25.56,26.16,26.8,27.48,28.2,28.96,29.77,30.61,31.5,32.42,33.38,34.38,35.42,36.5,37.62,38.77,39.96,41.19,42.45,43.75,45.09,46.46,47.87,49.31,50.78,52.29,53.84,55.42,57.03,58.66,60.31,61.97,63.64,65.31,66.97,68.62,70.26,71.87,73.45,75,76.51,77.97,79.38,80.73,82.02,83.24,84.38,85.45,86.42,87.31,88.09,88.77,89.34,89.79}', 1, 1), 
		(497.71, 6.38, 0.01, '{50, 25}', '{440, 190}',  '{260,440}', '{80,190}', '{50.2,50.49,50.85,51.28,51.78,52.34,52.95,53.61,54.31,55.05,55.82,56.62,57.44,58.28,59.12,59.98,60.83,61.67,62.5,63.32,64.11,64.88,65.61,66.31,66.98,67.61,68.22,68.81,69.39,69.94,70.48,71.02,71.55,72.07,72.6,73.13,73.66,74.21,74.77,75.34,75.93,76.55,77.19,77.87,78.57,79.31,80.09,80.9,81.74,82.62,83.53,84.48,85.47,86.48,87.53,88.61,89.73,90.88,92.06,93.27,94.52,95.79,97.1,98.44,99.81,101.21,102.64,104.1,105.6,107.11,108.66,110.23,111.83,113.44,115.08,116.74,118.42,120.11,121.82,123.54,125.28,127.02,128.78,130.54,132.31,134.09,135.87,137.65,139.44,141.22,143.01,144.79,146.57,148.34,150.11,151.88,153.65,155.41,157.16,158.92,160.66,162.4,164.13,165.86,167.58,169.29,171,172.69,174.38,176.06,177.73,179.39,181.04,182.68,184.31,185.93,187.54,189.15,190.75,192.34,193.94,195.52,197.1,198.69,200.26,201.84,203.42,205,206.58,208.16,209.74,211.33,212.92,214.51,216.12,217.72,219.34,220.95,222.56,224.17,225.77,227.36,228.94,230.5,232.05,233.57,235.07,236.54,237.99,239.4,240.78,242.11,243.41,244.67,245.88,247.04,248.15,249.2,250.2,251.15,252.04,252.88,253.67,254.42,255.11,255.76,256.37,256.93,257.45,257.93,258.38,258.78,259.15,259.49,259.79,260.06,260.3,260.51,260.7,260.86,260.99,261.1,261.19,261.26,261.31,261.34,261.36,261.36,261.35,261.32,261.29,261.24,261.19,261.12,261.06,260.98,260.91,260.83,260.76,260.68,260.6,260.53,260.47,260.41,260.35,260.3,260.26,260.22,260.19,260.17,260.15,260.13,260.12,260.12,260.13,260.13,260.15,260.17,260.2,260.23,260.27,260.31,260.36,260.41,260.47,260.54,260.61,260.69,260.77,260.86,260.96,261.05,261.16,261.27,261.38,261.5,261.62,261.74,261.87,262,262.14,262.28,262.43,262.57,262.72,262.88,263.03,263.19,263.36,263.52,263.69,263.86,264.03,264.21,264.39,264.57,264.76,264.95,265.15,265.35,265.55,265.75,265.97,266.18,266.4,266.62,266.85,267.09,267.32,267.57,267.82,268.07,268.34,268.61,268.91,269.22,269.55,269.9,270.28,270.68,271.12,271.59,272.1,272.65,273.24,273.87,274.55,275.28,276.06,276.89,277.78,278.74,279.75,280.83,281.97,283.17,284.42,285.72,287.08,288.48,289.92,291.4,292.91,294.46,296.05,297.65,299.29,300.94,302.61,304.3,306,307.71,309.42,311.14,312.85,314.57,316.28,317.99,319.69,321.4,323.1,324.81,326.52,328.24,329.96,331.68,333.42,335.16,336.9,338.66,340.43,342.21,344.01,345.82,347.64,349.48,351.33,353.21,355.1,357.01,358.94,360.89,362.86,364.85,366.86,368.88,370.93,373,375.08,377.19,379.31,381.45,383.62,385.8,388,390.23,392.47,394.73,397.02,399.32,401.65,403.98,406.33,408.67,410.99,413.29,415.56,417.79,419.97,422.09,424.14,426.12,428.01,429.8,431.48,433.05,434.5,435.81,436.98,438,438.86,439.55}', '{25.03,25.31,25.82,26.55,27.47,28.58,29.85,31.27,32.83,34.5,36.28,38.14,40.07,42.06,44.08,46.12,48.17,50.2,52.21,54.18,56.08,57.91,59.65,61.29,62.83,64.28,65.64,66.92,68.11,69.23,70.27,71.24,72.14,72.97,73.74,74.46,75.11,75.72,76.28,76.79,77.26,77.69,78.09,78.46,78.79,79.11,79.39,79.66,79.9,80.12,80.32,80.51,80.67,80.81,80.94,81.05,81.15,81.23,81.3,81.36,81.4,81.43,81.46,81.47,81.48,81.48,81.47,81.46,81.44,81.42,81.4,81.38,81.35,81.32,81.3,81.27,81.25,81.23,81.21,81.2,81.2,81.2,81.21,81.22,81.25,81.28,81.33,81.38,81.45,81.54,81.63,81.74,81.86,81.99,82.13,82.28,82.43,82.59,82.76,82.92,83.09,83.26,83.42,83.58,83.74,83.9,84.05,84.19,84.32,84.44,84.55,84.65,84.74,84.81,84.86,84.9,84.93,84.95,84.96,84.96,84.94,84.92,84.89,84.85,84.81,84.75,84.7,84.63,84.57,84.49,84.42,84.34,84.26,84.18,84.1,84.02,83.94,83.86,83.78,83.7,83.61,83.53,83.44,83.35,83.26,83.16,83.06,82.96,82.86,82.75,82.63,82.51,82.39,82.26,82.13,81.99,81.84,81.69,81.53,81.37,81.2,81.03,80.86,80.68,80.51,80.33,80.16,79.99,79.82,79.66,79.5,79.35,79.21,79.08,78.95,78.84,78.74,78.65,78.57,78.51,78.46,78.43,78.41,78.41,78.42,78.44,78.47,78.5,78.55,78.61,78.67,78.73,78.8,78.88,78.95,79.03,79.11,79.19,79.27,79.34,79.42,79.48,79.55,79.61,79.66,79.71,79.75,79.78,79.81,79.84,79.86,79.87,79.88,79.88,79.88,79.87,79.86,79.84,79.81,79.78,79.74,79.7,79.65,79.6,79.54,79.48,79.41,79.34,79.28,79.22,79.17,79.13,79.11,79.11,79.12,79.16,79.23,79.33,79.46,79.63,79.84,80.09,80.39,80.73,81.13,81.58,82.09,82.66,83.29,83.98,84.73,85.53,86.38,87.28,88.23,89.22,90.25,91.32,92.43,93.57,94.73,95.93,97.14,98.38,99.64,100.92,102.21,103.5,104.81,106.12,107.44,108.75,110.07,111.39,112.71,114.03,115.34,116.66,117.97,119.28,120.58,121.89,123.19,124.48,125.77,127.05,128.33,129.6,130.86,132.11,133.36,134.59,135.82,137.03,138.24,139.43,140.61,141.78,142.93,144.06,145.18,146.29,147.37,148.43,149.48,150.5,151.5,152.48,153.43,154.36,155.26,156.14,156.99,157.81,158.6,159.36,160.09,160.8,161.48,162.13,162.77,163.38,163.98,164.56,165.12,165.67,166.21,166.74,167.27,167.79,168.3,168.82,169.33,169.85,170.37,170.89,171.42,171.97,172.52,173.08,173.65,174.22,174.81,175.39,175.98,176.57,177.16,177.75,178.34,178.93,179.51,180.09,180.66,181.22,181.77,182.32,182.85,183.37,183.87,184.36,184.83,185.29,185.73,186.14,186.55,186.93,187.29,187.63,187.95,188.25,188.53,188.78,189.02,189.23,189.41,189.58,189.71,189.83,189.91,189.97,190.01,190.02}', 1, 1),
		(469.96, 6.03, 0.01, '{50, 25}', '{330, 230}',  '{260,330}', '{80,230}', '{50.29,50.66,51.11,51.62,52.2,52.83,53.52,54.25,55.03,55.83,56.67,57.53,58.4,59.29,60.18,61.06,61.95,62.82,63.67,64.49,65.29,66.05,66.78,67.47,68.14,68.78,69.39,69.98,70.56,71.12,71.67,72.2,72.74,73.26,73.79,74.32,74.85,75.39,75.94,76.5,77.08,77.68,78.3,78.94,79.61,80.3,81.02,81.76,82.53,83.33,84.15,84.99,85.87,86.77,87.71,88.67,89.66,90.68,91.73,92.81,93.92,95.06,96.24,97.45,98.69,99.96,101.27,102.6,103.97,105.37,106.81,108.27,109.76,111.29,112.84,114.43,116.04,117.69,119.36,121.06,122.79,124.55,126.34,128.16,130,131.87,133.77,135.69,137.64,139.6,141.59,143.59,145.6,147.63,149.68,151.73,153.79,155.86,157.94,160.01,162.09,164.17,166.25,168.32,170.39,172.46,174.51,176.55,178.59,180.62,182.63,184.64,186.64,188.63,190.6,192.57,194.53,196.48,198.42,200.35,202.27,204.18,206.08,207.96,209.84,211.71,213.57,215.41,217.25,219.07,220.87,222.65,224.41,226.14,227.84,229.51,231.14,232.73,234.28,235.78,237.24,238.65,240,241.29,242.52,243.69,244.8,245.83,246.79,247.68,248.5,249.25,249.94,250.56,251.13,251.65,252.12,252.55,252.93,253.28,253.6,253.88,254.14,254.37,254.59,254.79,254.98,255.16,255.34,255.52,255.7,255.89,256.08,256.27,256.46,256.65,256.85,257.04,257.23,257.42,257.6,257.78,257.96,258.14,258.31,258.47,258.62,258.77,258.91,259.04,259.16,259.27,259.37,259.46,259.54,259.61,259.67,259.72,259.75,259.78,259.8,259.8,259.8,259.78,259.75,259.72,259.67,259.61,259.54,259.47,259.38,259.28,259.17,259.05,258.92,258.78,258.64,258.49,258.34,258.19,258.04,257.89,257.74,257.6,257.46,257.33,257.21,257.09,256.99,256.9,256.82,256.76,256.72,256.69,256.68,256.7,256.73,256.78,256.86,256.95,257.07,257.22,257.38,257.57,257.79,258.03,258.29,258.59,258.9,259.25,259.62,260.02,260.45,260.91,261.4,261.92,262.47,263.04,263.63,264.25,264.88,265.54,266.2,266.87,267.55,268.24,268.93,269.62,270.31,270.99,271.67,272.34,272.99,273.63,274.26,274.86,275.44,276,276.54,277.07,277.58,278.09,278.6,279.11,279.62,280.13,280.66,281.21,281.77,282.36,282.97,283.61,284.29,285,285.75,286.55,287.39,288.29,289.23,290.23,291.27,292.34,293.44,294.57,295.72,296.89,298.06,299.23,300.41,301.58,302.73,303.87,304.98,306.06,307.11,308.12,309.08,310,310.85,311.65,312.39,313.07,313.7,314.28,314.82,315.32,315.77,316.2,316.58,316.94,317.28,317.59,317.88,318.16,318.42,318.68,318.93,319.17,319.42,319.67,319.92,320.19,320.46,320.75,321.06,321.38,321.72,322.08,322.46,322.87,323.31,323.77,324.27,324.8,325.36,325.96,326.59,327.27,327.99,328.76,329.57}', '{24.72,24.68,24.87,25.28,25.88,26.68,27.65,28.78,30.06,31.48,33.01,34.65,36.39,38.2,40.09,42.02,44,46,48.01,50.02,52.02,53.99,55.93,57.83,59.69,61.52,63.3,65.04,66.73,68.37,69.96,71.5,72.98,74.4,75.77,77.07,78.31,79.48,80.58,81.62,82.57,83.46,84.27,85,85.65,86.24,86.76,87.22,87.62,87.96,88.25,88.49,88.69,88.85,88.96,89.05,89.1,89.13,89.13,89.11,89.07,89.03,88.97,88.9,88.84,88.77,88.7,88.62,88.55,88.47,88.39,88.32,88.24,88.17,88.09,88.02,87.95,87.88,87.82,87.76,87.7,87.65,87.61,87.56,87.53,87.5,87.48,87.46,87.44,87.44,87.43,87.43,87.43,87.43,87.44,87.45,87.46,87.47,87.47,87.48,87.49,87.5,87.5,87.5,87.5,87.5,87.49,87.48,87.46,87.45,87.42,87.4,87.37,87.34,87.31,87.27,87.24,87.2,87.16,87.12,87.08,87.04,87,86.95,86.91,86.87,86.83,86.78,86.74,86.7,86.66,86.61,86.56,86.51,86.45,86.38,86.31,86.23,86.14,86.04,85.92,85.8,85.66,85.51,85.34,85.16,84.96,84.75,84.51,84.26,83.99,83.7,83.4,83.09,82.78,82.45,82.13,81.8,81.48,81.16,80.84,80.53,80.24,79.95,79.68,79.43,79.2,78.99,78.8,78.64,78.51,78.41,78.33,78.28,78.25,78.24,78.25,78.27,78.31,78.37,78.43,78.51,78.6,78.69,78.78,78.88,78.99,79.09,79.19,79.28,79.37,79.46,79.53,79.6,79.66,79.71,79.75,79.79,79.82,79.84,79.85,79.85,79.85,79.84,79.82,79.79,79.75,79.71,79.66,79.6,79.53,79.46,79.38,79.29,79.19,79.09,79,78.9,78.81,78.72,78.65,78.58,78.52,78.49,78.46,78.46,78.48,78.52,78.59,78.69,78.82,78.98,79.17,79.41,79.68,79.99,80.35,80.74,81.19,81.68,82.22,82.8,83.44,84.13,84.88,85.68,86.53,87.45,88.42,89.46,90.56,91.72,92.95,94.24,95.6,97.03,98.53,100.08,101.69,103.34,105.02,106.74,108.48,110.24,112.01,113.78,115.55,117.31,119.05,120.77,122.46,124.11,125.72,127.28,128.78,130.22,131.58,132.88,134.1,135.26,136.36,137.4,138.38,139.31,140.18,141.01,141.79,142.54,143.24,143.91,144.54,145.15,145.73,146.28,146.82,147.34,147.84,148.33,148.82,149.3,149.78,150.26,150.75,151.25,151.76,152.29,152.85,153.43,154.03,154.67,155.35,156.06,156.82,157.63,158.48,159.39,160.36,161.4,162.49,163.66,164.89,166.19,167.55,168.98,170.47,172.02,173.62,175.29,177.01,178.78,180.6,182.48,184.41,186.38,188.4,190.46,192.57,194.72,196.91,199.14,201.4,203.69,205.98,208.27,210.54,212.76,214.93,217.02,219.03,220.93,222.71,224.35,225.84,227.16,228.29,229.22,229.94,230.42,230.64,230.6,230.28}', 1, 1),
		(647.4, 8.3, 0.01, '{50, 25}', '{210, 90}',  '{100,250,210}', '{230,181,90}', '{50.39,50.77,51.14,51.49,51.84,52.18,52.51,52.83,53.15,53.47,53.79,54.1,54.42,54.74,55.07,55.4,55.73,56.08,56.43,56.8,57.18,57.57,57.97,58.38,58.8,59.22,59.65,60.08,60.5,60.93,61.35,61.76,62.17,62.57,62.95,63.32,63.68,64.02,64.33,64.63,64.9,65.15,65.37,65.57,65.74,65.89,66.02,66.14,66.23,66.3,66.36,66.41,66.44,66.46,66.47,66.47,66.46,66.45,66.42,66.4,66.37,66.33,66.3,66.26,66.22,66.17,66.12,66.05,65.96,65.86,65.74,65.6,65.44,65.24,65.02,64.77,64.49,64.17,63.81,63.42,62.98,62.49,61.96,61.38,60.75,60.08,59.37,58.63,57.86,57.07,56.25,55.42,54.57,53.72,52.86,51.99,51.14,50.28,49.44,48.62,47.81,47.03,46.27,45.55,44.86,44.2,43.58,42.99,42.42,41.89,41.38,40.9,40.45,40.02,39.61,39.22,38.86,38.52,38.2,37.89,37.6,37.33,37.07,36.83,36.6,36.38,36.19,36.02,35.87,35.76,35.69,35.67,35.69,35.76,35.9,36.09,36.36,36.69,37.1,37.6,38.18,38.86,39.63,40.5,41.48,42.56,43.76,45.05,46.44,47.91,49.46,51.07,52.75,54.49,56.27,58.09,59.95,61.83,63.73,65.64,67.55,69.46,71.36,73.24,75.09,76.91,78.69,80.43,82.12,83.76,85.35,86.89,88.38,89.81,91.19,92.5,93.75,94.94,96.05,97.1,98.08,98.99,99.82,100.57,101.24,101.83,102.34,102.76,103.11,103.38,103.58,103.71,103.79,103.81,103.79,103.72,103.61,103.46,103.29,103.1,102.89,102.66,102.42,102.18,101.95,101.72,101.5,101.3,101.11,100.95,100.81,100.68,100.58,100.49,100.43,100.38,100.36,100.35,100.36,100.39,100.44,100.51,100.6,100.71,100.84,100.99,101.16,101.35,101.55,101.78,102.02,102.28,102.56,102.85,103.16,103.49,103.83,104.18,104.54,104.92,105.31,105.7,106.11,106.53,106.96,107.39,107.83,108.28,108.73,109.19,109.65,110.13,110.63,111.14,111.67,112.23,112.81,113.43,114.08,114.76,115.49,116.27,117.09,117.96,118.88,119.86,120.91,122.01,123.18,124.43,125.74,127.13,128.57,130.08,131.64,133.26,134.92,136.63,138.38,140.17,142,143.85,145.73,147.62,149.54,151.48,153.42,155.37,157.32,159.28,161.22,163.17,165.1,167.03,168.96,170.89,172.82,174.74,176.67,178.59,180.52,182.45,184.39,186.33,188.27,190.22,192.18,194.15,196.13,198.12,200.12,202.13,204.15,206.17,208.2,210.23,212.26,214.27,216.28,218.27,220.24,222.2,224.12,226.02,227.89,229.72,231.52,233.27,234.97,236.63,238.23,239.78,241.27,242.7,244.07,245.37,246.61,247.78,248.89,249.93,250.9,251.8,252.63,253.38,254.06,254.67,255.2,255.65,256.02,256.31,256.52,256.65,256.7,256.66,256.54,256.36,256.11,255.8,255.45,255.05,254.62,254.15,253.66,253.16,252.64,252.12,251.61,251.1,250.61,250.15,249.71,249.31,248.95,248.64,248.39,248.18,248.01,247.89,247.81,247.76,247.75,247.77,247.81,247.87,247.96,248.06,248.18,248.31,248.45,248.59,248.73,248.87,249.01,249.13,249.25,249.36,249.45,249.54,249.61,249.67,249.71,249.75,249.78,249.79,249.79,249.78,249.76,249.73,249.68,249.62,249.55,249.47,249.38,249.28,249.17,249.04,248.9,248.76,248.62,248.48,248.34,248.21,248.08,247.97,247.88,247.8,247.74,247.71,247.71,247.73,247.79,247.89,248.03,248.21,248.43,248.7,249.02,249.39,249.79,250.23,250.7,251.2,251.72,252.25,252.79,253.34,253.88,254.43,254.96,255.48,255.99,256.46,256.92,257.33,257.71,258.05,258.34,258.57,258.75,258.87,258.92,258.9,258.81,258.64,258.39,258.06,257.63,257.11,256.48,255.76,254.93,253.98,252.92,251.74,250.44,249,247.44,245.73,243.91,241.98,239.95,237.86,235.72,233.55,231.36,229.18,227.02,224.9,222.84,220.86,218.97,217.2,215.56,214.07,212.75,211.62,210.7,210}', '{24.67,24.43,24.28,24.22,24.26,24.37,24.58,24.86,25.24,25.69,26.22,26.83,27.51,28.28,29.11,30.02,31,32.05,33.17,34.35,35.6,36.92,38.29,39.71,41.18,42.69,44.23,45.81,47.42,49.04,50.68,52.33,53.98,55.63,57.28,58.91,60.53,62.13,63.7,65.23,66.73,68.18,69.59,70.96,72.3,73.61,74.89,76.15,77.4,78.64,79.87,81.1,82.34,83.59,84.84,86.12,87.42,88.76,90.12,91.52,92.96,94.46,96,97.59,99.24,100.93,102.66,104.44,106.25,108.1,109.97,111.88,113.82,115.78,117.77,119.77,121.79,123.82,125.86,127.91,129.97,132.03,134.09,136.14,138.2,140.24,142.28,144.31,146.32,148.33,150.31,152.28,154.23,156.16,158.07,159.95,161.81,163.64,165.44,167.21,168.94,170.64,172.3,173.92,175.5,177.05,178.56,180.03,181.48,182.89,184.27,185.63,186.97,188.28,189.58,190.85,192.11,193.35,194.59,195.81,197.02,198.23,199.43,200.64,201.84,203.04,204.23,205.43,206.61,207.79,208.95,210.1,211.24,212.36,213.45,214.53,215.57,216.6,217.59,218.55,219.48,220.37,221.22,222.03,222.8,223.53,224.21,224.85,225.44,226,226.52,227,227.44,227.85,228.23,228.58,228.9,229.19,229.45,229.69,229.9,230.1,230.27,230.42,230.55,230.67,230.77,230.86,230.93,231,231.05,231.09,231.11,231.13,231.14,231.14,231.14,231.12,231.1,231.08,231.05,231.01,230.98,230.94,230.9,230.86,230.81,230.77,230.73,230.69,230.65,230.61,230.57,230.53,230.5,230.46,230.42,230.39,230.36,230.33,230.29,230.27,230.24,230.21,230.19,230.16,230.14,230.12,230.11,230.09,230.08,230.07,230.06,230.05,230.04,230.04,230.03,230.03,230.03,230.04,230.04,230.05,230.06,230.07,230.08,230.09,230.11,230.13,230.15,230.17,230.19,230.22,230.24,230.27,230.3,230.32,230.35,230.38,230.41,230.44,230.46,230.49,230.52,230.54,230.57,230.59,230.61,230.63,230.65,230.66,230.68,230.69,230.7,230.71,230.72,230.74,230.75,230.77,230.78,230.8,230.83,230.86,230.89,230.92,230.96,231.01,231.06,231.12,231.18,231.26,231.34,231.42,231.52,231.61,231.71,231.81,231.91,232.02,232.12,232.22,232.31,232.4,232.49,232.56,232.64,232.7,232.75,232.79,232.82,232.83,232.83,232.82,232.79,232.75,232.7,232.63,232.56,232.47,232.37,232.26,232.14,232.02,231.89,231.75,231.6,231.44,231.29,231.12,230.96,230.78,230.61,230.43,230.25,230.07,229.88,229.69,229.48,229.27,229.05,228.82,228.58,228.32,228.05,227.76,227.46,227.14,226.8,226.44,226.06,225.66,225.24,224.79,224.32,223.82,223.29,222.74,222.16,221.55,220.91,220.24,219.55,218.82,218.06,217.27,216.44,215.58,214.69,213.76,212.8,211.8,210.77,209.7,208.59,207.44,206.27,205.07,203.84,202.6,201.36,200.1,198.85,197.61,196.38,195.17,193.97,192.81,191.68,190.6,189.55,188.56,187.62,186.75,185.94,185.2,184.53,183.94,183.41,182.94,182.53,182.18,181.87,181.61,181.4,181.23,181.09,180.98,180.91,180.85,180.82,180.81,180.81,180.82,180.84,180.86,180.88,180.9,180.91,180.92,180.94,180.95,180.95,180.96,180.96,180.97,180.97,180.96,180.96,180.96,180.95,180.94,180.93,180.91,180.9,180.88,180.86,180.84,180.81,180.78,180.72,180.65,180.55,180.42,180.26,180.07,179.83,179.54,179.2,178.81,178.36,177.84,177.25,176.59,175.85,175.03,174.13,173.13,172.04,170.86,169.59,168.25,166.83,165.34,163.79,162.18,160.51,158.79,157.03,155.22,153.38,151.51,149.61,147.69,145.75,143.81,141.85,139.89,137.93,135.98,134.04,132.12,130.2,128.31,126.43,124.58,122.76,120.97,119.21,117.49,115.8,114.16,112.57,111.02,109.52,108.08,106.7,105.37,104.11,102.92,101.79,100.72,99.71,98.77,97.88,97.05,96.27,95.54,94.86,94.22,93.63,93.09,92.58,92.11,91.68,91.29,90.92,90.59,90.28,90}', 1, 1),
		(337.51, 4.33, 0.01, '{50, 25}', '{120, 240}',  '{45,120}', '{165,240}', '{50.09,50.26,50.53,50.86,51.26,51.73,52.24,52.8,53.4,54.03,54.68,55.35,56.02,56.69,57.36,58.01,58.64,59.24,59.8,60.31,60.78,61.19,61.57,61.89,62.18,62.44,62.66,62.86,63.03,63.18,63.31,63.43,63.53,63.63,63.73,63.82,63.92,64.02,64.14,64.26,64.41,64.56,64.72,64.89,65.07,65.24,65.41,65.57,65.72,65.85,65.97,66.06,66.13,66.17,66.18,66.16,66.1,65.99,65.84,65.64,65.39,65.1,64.75,64.37,63.94,63.48,62.98,62.46,61.9,61.32,60.72,60.1,59.46,58.81,58.15,57.48,56.81,56.14,55.47,54.81,54.15,53.5,52.86,52.23,51.62,51.02,50.43,49.87,49.32,48.79,48.29,47.81,47.35,46.92,46.51,46.13,45.79,45.47,45.19,44.94,44.73,44.55,44.4,44.28,44.19,44.12,44.08,44.05,44.05,44.06,44.08,44.12,44.17,44.22,44.28,44.35,44.42,44.49,44.55,44.61,44.67,44.72,44.76,44.8,44.83,44.86,44.88,44.89,44.9,44.9,44.9,44.89,44.87,44.85,44.82,44.79,44.75,44.7,44.65,44.59,44.53,44.46,44.38,44.31,44.23,44.14,44.06,43.97,43.88,43.79,43.71,43.62,43.54,43.45,43.37,43.3,43.22,43.16,43.1,43.04,42.99,42.94,42.9,42.86,42.81,42.76,42.7,42.63,42.55,42.46,42.35,42.22,42.08,41.91,41.71,41.49,41.25,40.97,40.66,40.31,39.93,39.52,39.08,38.63,38.18,37.72,37.26,36.81,36.38,35.97,35.59,35.24,34.94,34.68,34.48,34.34,34.27,34.27,34.35,34.52,34.78,35.12,35.55,36.05,36.63,37.28,38,38.79,39.63,40.53,41.49,42.49,43.54,44.63,45.76,46.92,48.11,49.33,50.57,51.84,53.12,54.42,55.76,57.12,58.52,59.96,61.45,62.98,64.58,66.23,67.94,69.72,71.57,73.5,75.52,77.61,79.8,82.09,84.47,86.96,89.54,92.19,94.88,97.59,100.27,102.92,105.49,107.97,110.31,112.5,114.51,116.3,117.85,119.13,120.12,120.78,121.08,121.01,120.52}', '{24.32,24.02,24.07,24.44,25.11,26.05,27.22,28.62,30.19,31.93,33.8,35.77,37.82,39.92,42.05,44.17,46.26,48.28,50.23,52.06,53.75,55.32,56.78,58.12,59.38,60.56,61.66,62.71,63.71,64.68,65.63,66.56,67.5,68.45,69.43,70.44,71.5,72.61,73.8,75.08,76.44,77.89,79.42,81.03,82.7,84.44,86.22,88.06,89.93,91.84,93.78,95.73,97.7,99.68,101.66,103.63,105.59,107.53,109.44,111.32,113.17,114.97,116.74,118.47,120.16,121.81,123.43,125.01,126.55,128.05,129.52,130.96,132.35,133.72,135.04,136.34,137.59,138.82,140.01,141.16,142.28,143.37,144.43,145.45,146.44,147.4,148.33,149.23,150.1,150.93,151.74,152.52,153.26,153.98,154.67,155.33,155.97,156.58,157.16,157.71,158.24,158.74,159.22,159.67,160.1,160.5,160.89,161.25,161.59,161.9,162.2,162.48,162.74,162.98,163.21,163.42,163.61,163.78,163.94,164.09,164.22,164.34,164.44,164.53,164.6,164.66,164.71,164.74,164.76,164.77,164.76,164.73,164.69,164.64,164.58,164.5,164.4,164.29,164.17,164.03,163.89,163.73,163.56,163.4,163.23,163.07,162.92,162.79,162.67,162.57,162.5,162.46,162.45,162.47,162.54,162.65,162.8,163.01,163.28,163.6,163.99,164.43,164.94,165.51,166.13,166.8,167.54,168.32,169.16,170.05,170.99,171.98,173.02,174.1,175.23,176.4,177.62,178.87,180.17,181.51,182.88,184.29,185.72,187.19,188.67,190.18,191.69,193.22,194.76,196.3,197.84,199.37,200.9,202.42,203.92,205.4,206.86,208.29,209.69,211.05,212.38,213.67,214.93,216.14,217.32,218.46,219.56,220.62,221.65,222.63,223.57,224.48,225.34,226.16,226.95,227.69,228.39,229.05,229.66,230.24,230.77,231.27,231.73,232.16,232.56,232.93,233.27,233.6,233.9,234.19,234.46,234.73,234.98,235.23,235.48,235.73,235.98,236.23,236.5,236.78,237.06,237.36,237.66,237.96,238.26,238.55,238.83,239.1,239.35,239.58,239.79,239.96,240.11,240.22,240.29,240.32,240.3,240.23,240.11}', 1, 1),
		(606.07, 7.77, 0.01, '{50, 25}', '{250, 181}',  '{380,250}', '{40,181}', '{49.6,49.4,49.39,49.55,49.87,50.33,50.93,51.64,52.47,53.38,54.38,55.44,56.56,57.71,58.9,60.09,61.29,62.48,63.64,64.76,65.83,66.83,67.78,68.67,69.5,70.3,71.06,71.8,72.51,73.21,73.89,74.58,75.27,75.98,76.7,77.45,78.23,79.05,79.91,80.83,81.81,82.85,83.96,85.15,86.4,87.72,89.09,90.5,91.97,93.47,95,96.56,98.15,99.75,101.36,102.98,104.59,106.2,107.8,109.38,110.94,112.47,113.97,115.43,116.85,118.23,119.58,120.9,122.2,123.48,124.75,126,127.25,128.49,129.73,130.99,132.25,133.52,134.81,136.13,137.47,138.85,140.26,141.71,143.2,144.74,146.31,147.92,149.56,151.23,152.91,154.6,156.29,157.99,159.68,161.36,163.02,164.67,166.28,167.86,169.39,170.89,172.33,173.72,175.04,176.29,177.48,178.6,179.66,180.67,181.64,182.57,183.48,184.36,185.24,186.11,186.98,187.87,188.77,189.7,190.66,191.67,192.72,193.84,195.01,196.26,197.59,199.01,200.5,202.08,203.72,205.43,207.19,209,210.85,212.73,214.64,216.57,218.52,220.47,222.42,224.37,226.3,228.2,230.09,231.93,233.73,235.49,237.19,238.83,240.43,241.98,243.49,244.97,246.42,247.84,249.24,250.64,252.02,253.4,254.78,256.16,257.56,258.98,260.42,261.88,263.38,264.91,266.49,268.12,269.79,271.5,273.26,275.04,276.85,278.69,280.54,282.4,284.27,286.14,288,289.86,291.7,293.52,295.32,297.08,298.82,300.51,302.15,303.74,305.28,306.76,308.18,309.55,310.88,312.16,313.4,314.6,315.77,316.91,318.03,319.12,320.2,321.26,322.31,323.36,324.4,325.44,326.49,327.55,328.61,329.69,330.8,331.91,333.05,334.2,335.37,336.54,337.74,338.94,340.15,341.37,342.59,343.83,345.07,346.31,347.55,348.8,350.05,351.29,352.54,353.78,355.01,356.25,357.47,358.68,359.88,361.07,362.24,363.39,364.52,365.62,366.7,367.74,368.76,369.74,370.68,371.59,372.45,373.27,374.05,374.77,375.45,376.07,376.63,377.14,377.6,378.01,378.38,378.7,378.97,379.21,379.42,379.59,379.73,379.85,379.93,380,380.05,380.08,380.1,380.1,380.1,380.1,380.08,380.07,380.06,380.05,380.05,380.04,380.03,380.03,380.02,380.02,380.02,380.02,380.02,380.02,380.02,380.03,380.03,380.04,380.04,380.05,380.06,380.07,380.08,380.09,380.1,380.11,380.1,380.08,380.06,380.01,379.95,379.86,379.75,379.61,379.45,379.25,379.02,378.74,378.43,378.07,377.67,377.22,376.72,376.16,375.55,374.89,374.17,373.4,372.59,371.73,370.83,369.89,368.92,367.91,366.87,365.8,364.7,363.57,362.43,361.26,360.08,358.88,357.67,356.44,355.21,353.98,352.74,351.5,350.26,349.03,347.81,346.59,345.39,344.21,343.05,341.9,340.78,339.69,338.63,337.6,336.6,335.64,334.72,333.85,333.02,332.24,331.51,330.83,330.19,329.6,329.06,328.55,328.08,327.65,327.24,326.87,326.52,326.2,325.9,325.61,325.35,325.1,324.85,324.62,324.4,324.17,323.95,323.73,323.51,323.28,323.05,322.82,322.58,322.35,322.11,321.87,321.63,321.38,321.14,320.89,320.65,320.4,320.15,319.9,319.65,319.4,319.15,318.9,318.65,318.39,318.14,317.88,317.62,317.35,317.08,316.79,316.5,316.19,315.87,315.53,315.18,314.82,314.43,314.02,313.6,313.15,312.67,312.18,311.65,311.09,310.51,309.9,309.25,308.56,307.84,307.08,306.28,305.43,304.54,303.6,302.62,301.58,300.49,299.35,298.15,296.89,295.57,294.19,292.74,291.23,289.65,288,286.29,284.52,282.7,280.84,278.94,277.01,275.05,273.08,271.09,269.1,267.11,265.13,263.16,261.21,259.29,257.41,255.56,253.77,252.02,250.34}', '{25.23,25.71,26.42,27.33,28.45,29.74,31.19,32.78,34.49,36.31,38.22,40.2,42.24,44.31,46.4,48.49,50.56,52.6,54.59,56.51,58.34,60.07,61.7,63.22,64.65,65.98,67.23,68.39,69.48,70.48,71.41,72.28,73.08,73.82,74.5,75.13,75.71,76.25,76.75,77.21,77.64,78.03,78.41,78.76,79.09,79.4,79.69,79.96,80.21,80.44,80.66,80.86,81.04,81.22,81.37,81.52,81.65,81.78,81.89,81.99,82.09,82.18,82.26,82.34,82.41,82.47,82.53,82.59,82.64,82.69,82.74,82.78,82.82,82.86,82.9,82.93,82.96,83,83.03,83.06,83.09,83.13,83.16,83.2,83.23,83.27,83.31,83.35,83.4,83.44,83.49,83.53,83.58,83.63,83.67,83.72,83.77,83.82,83.87,83.92,83.97,84.02,84.06,84.11,84.16,84.2,84.25,84.29,84.33,84.38,84.42,84.46,84.51,84.56,84.61,84.66,84.71,84.77,84.83,84.89,84.96,85.04,85.11,85.2,85.29,85.38,85.48,85.59,85.7,85.82,85.93,86.05,86.16,86.26,86.35,86.44,86.5,86.56,86.59,86.61,86.6,86.57,86.5,86.41,86.29,86.14,85.94,85.71,85.44,85.12,84.77,84.38,83.96,83.5,83.02,82.51,81.96,81.4,80.81,80.21,79.58,78.94,78.29,77.62,76.94,76.26,75.57,74.88,74.18,73.49,72.79,72.1,71.41,70.73,70.05,69.37,68.69,68.02,67.35,66.68,66.03,65.37,64.72,64.08,63.45,62.82,62.19,61.58,60.97,60.37,59.78,59.19,58.62,58.06,57.5,56.96,56.43,55.91,55.41,54.92,54.45,53.99,53.55,53.13,52.72,52.34,51.97,51.63,51.3,51,50.72,50.46,50.23,50.02,49.83,49.66,49.5,49.36,49.23,49.12,49.01,48.91,48.81,48.72,48.63,48.54,48.45,48.35,48.25,48.14,48.02,47.89,47.75,47.59,47.42,47.23,47.03,46.83,46.61,46.38,46.15,45.91,45.67,45.42,45.17,44.92,44.67,44.43,44.18,43.94,43.7,43.47,43.24,43.02,42.82,42.62,42.43,42.25,42.08,41.92,41.77,41.62,41.49,41.36,41.24,41.12,41.02,40.92,40.83,40.74,40.66,40.59,40.52,40.45,40.4,40.34,40.3,40.25,40.22,40.18,40.16,40.13,40.12,40.1,40.1,40.09,40.09,40.1,40.11,40.13,40.15,40.18,40.21,40.25,40.29,40.34,40.39,40.44,40.51,40.57,40.65,40.73,40.81,40.9,41,41.11,41.22,41.34,41.47,41.6,41.74,41.9,42.06,42.22,42.4,42.59,42.78,42.99,43.21,43.43,43.66,43.9,44.14,44.39,44.63,44.88,45.13,45.38,45.63,45.87,46.11,46.35,46.57,46.79,47,47.2,47.39,47.56,47.72,47.87,48,48.13,48.25,48.37,48.49,48.62,48.76,48.91,49.08,49.27,49.49,49.73,50,50.31,50.66,51.05,51.48,51.97,52.5,53.1,53.75,54.47,55.24,56.06,56.93,57.86,58.83,59.84,60.89,61.99,63.11,64.27,65.46,66.68,67.93,69.19,70.48,71.78,73.09,74.42,75.76,77.11,78.45,79.81,81.17,82.54,83.91,85.29,86.68,88.07,89.47,90.87,92.29,93.71,95.13,96.57,98.01,99.46,100.92,102.38,103.86,105.34,106.83,108.33,109.83,111.33,112.83,114.32,115.8,117.28,118.73,120.17,121.58,122.97,124.32,125.65,126.94,128.19,129.39,130.55,131.67,132.72,133.73,134.67,135.55,136.38,137.16,137.9,138.61,139.29,139.94,140.58,141.22,141.85,142.49,143.14,143.8,144.49,145.22,145.98,146.79,147.65,148.56,149.54,150.59,151.72,152.92,154.19,155.51,156.88,158.3,159.77,161.26,162.78,164.32,165.87,167.43,168.99,170.55,172.09,173.62,175.12,176.58,178.01,179.4,180.73}', 1, 1),
		(656.56, 8.42, 0.01, '{50, 25}', '{350, 350}',  '{260,350}', '{40,350}', '{50.37,50.76,51.17,51.6,52.05,52.53,53.02,53.53,54.06,54.6,55.16,55.74,56.34,56.95,57.58,58.22,58.87,59.54,60.21,60.91,61.61,62.32,63.05,63.78,64.52,65.27,66.03,66.8,67.58,68.37,69.16,69.96,70.78,71.59,72.42,73.26,74.11,74.96,75.82,76.69,77.57,78.46,79.36,80.26,81.17,82.1,83.03,83.96,84.91,85.87,86.83,87.8,88.78,89.77,90.78,91.79,92.82,93.86,94.91,95.98,97.06,98.16,99.28,100.41,101.57,102.74,103.93,105.14,106.37,107.63,108.9,110.2,111.53,112.88,114.25,115.65,117.08,118.53,120,121.48,122.99,124.5,126.02,127.54,129.07,130.6,132.12,133.64,135.15,136.64,138.12,139.59,141.03,142.44,143.83,145.19,146.51,147.8,149.05,150.26,151.42,152.53,153.6,154.63,155.63,156.59,157.52,158.43,159.32,160.19,161.05,161.89,162.74,163.58,164.42,165.27,166.14,167.01,167.91,168.82,169.77,170.74,171.74,172.79,173.87,175.01,176.19,177.42,178.69,180.02,181.38,182.78,184.23,185.7,187.22,188.76,190.33,191.93,193.56,195.21,196.88,198.57,200.27,201.99,203.72,205.46,207.21,208.96,210.72,212.48,214.24,215.99,217.74,219.48,221.22,222.94,224.64,226.33,227.99,229.64,231.26,232.85,234.41,235.94,237.44,238.9,240.32,241.7,243.04,244.33,245.57,246.76,247.89,248.97,249.99,250.95,251.85,252.68,253.45,254.16,254.81,255.41,255.96,256.46,256.91,257.31,257.68,258,258.29,258.54,258.76,258.95,259.11,259.25,259.36,259.46,259.54,259.6,259.65,259.7,259.73,259.76,259.79,259.81,259.84,259.86,259.87,259.89,259.9,259.92,259.93,259.93,259.94,259.94,259.94,259.94,259.93,259.93,259.92,259.91,259.9,259.88,259.86,259.84,259.82,259.8,259.77,259.74,259.71,259.68,259.64,259.61,259.57,259.53,259.49,259.45,259.41,259.36,259.32,259.28,259.24,259.19,259.15,259.11,259.07,259.03,258.99,258.95,258.91,258.88,258.85,258.81,258.78,258.76,258.73,258.71,258.69,258.67,258.65,258.64,258.62,258.61,258.6,258.59,258.59,258.58,258.58,258.58,258.58,258.58,258.58,258.58,258.59,258.6,258.6,258.61,258.62,258.63,258.65,258.66,258.67,258.69,258.71,258.73,258.74,258.76,258.79,258.81,258.83,258.86,258.88,258.91,258.94,258.97,259,259.03,259.06,259.1,259.13,259.17,259.21,259.25,259.29,259.33,259.37,259.42,259.46,259.51,259.56,259.61,259.66,259.71,259.76,259.82,259.88,259.93,259.99,260.06,260.12,260.18,260.25,260.31,260.38,260.45,260.52,260.6,260.67,260.75,260.83,260.91,260.99,261.07,261.16,261.24,261.33,261.41,261.5,261.59,261.68,261.77,261.86,261.95,262.05,262.14,262.23,262.32,262.42,262.51,262.6,262.69,262.78,262.87,262.96,263.05,263.14,263.23,263.32,263.41,263.51,263.6,263.7,263.8,263.9,264.01,264.12,264.24,264.36,264.49,264.62,264.76,264.91,265.07,265.23,265.4,265.59,265.78,265.98,266.2,266.42,266.66,266.91,267.16,267.43,267.71,268,268.3,268.6,268.92,269.24,269.57,269.9,270.24,270.59,270.94,271.3,271.66,272.03,272.4,272.78,273.15,273.53,273.91,274.3,274.68,275.06,275.45,275.84,276.23,276.62,277.02,277.43,277.84,278.25,278.67,279.1,279.54,279.99,280.45,280.91,281.39,281.88,282.38,282.9,283.43,283.97,284.53,285.11,285.7,286.31,286.94,287.59,288.25,288.92,289.61,290.32,291.03,291.75,292.49,293.23,293.97,294.72,295.48,296.24,297,297.76,298.51,299.27,300.02,300.77,301.51,302.24,302.97,303.68,304.39,305.08,305.76,306.43,307.1,307.76,308.43,309.09,309.76,310.44,311.13,311.83,312.55,313.29,314.06,314.84,315.66,316.5,317.38,318.3,319.26,320.26,321.3,322.39,323.53,324.73,325.98,327.29,328.64,330.03,331.45,332.89,334.33,335.77,337.2,338.6,339.98,341.31,342.59,343.81,344.95,346.02,346.99,347.86,348.62,349.26,349.77,350.14,350.36,350.42,350.31,350.02}',	'{26.5,27.96,29.38,30.77,32.13,33.47,34.77,36.06,37.33,38.58,39.81,41.03,42.25,43.45,44.65,45.85,47.05,48.26,49.47,50.68,51.91,53.15,54.41,55.68,56.98,58.3,59.64,61,62.37,63.75,65.14,66.53,67.92,69.31,70.68,72.05,73.39,74.72,76.02,77.3,78.54,79.75,80.92,82.05,83.13,84.16,85.14,86.05,86.91,87.7,88.43,89.08,89.67,90.19,90.65,91.05,91.39,91.68,91.92,92.12,92.26,92.36,92.43,92.45,92.44,92.39,92.32,92.22,92.09,91.95,91.78,91.59,91.4,91.19,90.97,90.74,90.52,90.28,90.04,89.79,89.52,89.25,88.96,88.65,88.33,87.99,87.63,87.25,86.85,86.42,85.96,85.48,84.96,84.42,83.84,83.23,82.58,81.9,81.18,80.41,79.61,78.76,77.87,76.95,75.99,75,73.99,72.95,71.89,70.81,69.72,68.62,67.51,66.4,65.29,64.19,63.09,61.99,60.92,59.86,58.81,57.8,56.8,55.84,54.91,54.02,53.17,52.35,51.58,50.84,50.14,49.48,48.86,48.27,47.71,47.19,46.7,46.24,45.82,45.42,45.05,44.71,44.4,44.12,43.86,43.63,43.42,43.24,43.07,42.94,42.82,42.72,42.64,42.58,42.53,42.51,42.49,42.49,42.5,42.52,42.55,42.58,42.62,42.67,42.72,42.77,42.83,42.88,42.93,42.98,43.03,43.06,43.1,43.12,43.13,43.14,43.13,43.1,43.07,43.02,42.97,42.9,42.83,42.74,42.65,42.55,42.45,42.34,42.23,42.11,42,41.88,41.76,41.63,41.51,41.4,41.28,41.16,41.06,40.95,40.85,40.76,40.67,40.59,40.52,40.45,40.4,40.35,40.3,40.27,40.24,40.21,40.2,40.19,40.19,40.2,40.21,40.23,40.26,40.29,40.33,40.38,40.44,40.5,40.57,40.65,40.73,40.82,40.92,41.03,41.16,41.3,41.45,41.63,41.83,42.05,42.29,42.57,42.87,43.2,43.57,43.98,44.43,44.91,45.44,46.01,46.63,47.3,48.02,48.79,49.62,50.51,51.45,52.46,53.52,54.64,55.8,57.02,58.28,59.58,60.92,62.3,63.72,65.16,66.64,68.14,69.66,71.2,72.76,74.34,75.93,77.52,79.12,80.73,82.33,83.94,85.53,87.12,88.7,90.28,91.84,93.39,94.94,96.48,98.02,99.56,101.08,102.61,104.13,105.66,107.18,108.7,110.23,111.75,113.28,114.81,116.34,117.88,119.43,120.98,122.54,124.11,125.69,127.27,128.87,130.47,132.08,133.69,135.32,136.94,138.57,140.21,141.84,143.48,145.12,146.76,148.4,150.04,151.67,153.31,154.94,156.56,158.18,159.79,161.4,163,164.59,166.17,167.74,169.3,170.85,172.4,173.93,175.46,176.98,178.5,180.01,181.52,183.03,184.53,186.03,187.53,189.02,190.52,192.02,193.52,195.02,196.52,198.03,199.54,201.06,202.58,204.11,205.64,207.18,208.73,210.28,211.84,213.4,214.96,216.52,218.09,219.65,221.22,222.78,224.34,225.89,227.44,228.99,230.53,232.06,233.59,235.11,236.61,238.11,239.6,241.07,242.53,243.98,245.41,246.83,248.23,249.62,250.98,252.33,253.66,254.97,256.26,257.52,258.77,259.99,261.19,262.36,263.51,264.63,265.72,266.79,267.82,268.83,269.81,270.75,271.67,272.55,273.4,274.21,274.99,275.74,276.45,277.14,277.79,278.42,279.01,279.58,280.12,280.63,281.11,281.57,282.01,282.42,282.8,283.17,283.51,283.83,284.13,284.41,284.67,284.91,285.14,285.34,285.53,285.71,285.88,286.04,286.19,286.34,286.5,286.65,286.82,286.99,287.18,287.39,287.61,287.86,288.13,288.43,288.77,289.14,289.54,289.99,290.48,291.02,291.61,292.25,292.95,293.71,294.53,295.4,296.33,297.32,298.36,299.46,300.6,301.79,303.03,304.32,305.65,307.02,308.43,309.88,311.37,312.89,314.45,316.03,317.65,319.3,320.98,322.68,324.4,326.15,327.92,329.71,331.5,333.28,335.06,336.8,338.52,340.18,341.79,343.33,344.79,346.16,347.43,348.6,349.64,350.55,351.31,351.93,352.38,352.65,352.74,352.64,352.33,351.8,351.04,350.05}', 1, 1),
		(567.33, 7.27, 0.01, '{50, 25}', '{180, 240}',  '{260,180}', '{40,240}', '{48.91,48.03,47.33,46.82,46.48,46.29,46.25,46.35,46.57,46.9,47.34,47.88,48.49,49.18,49.92,50.72,51.55,52.41,53.28,54.16,55.04,55.9,56.73,57.53,58.29,59.02,59.73,60.41,61.08,61.74,62.38,63.03,63.67,64.32,64.97,65.64,66.32,67.02,67.75,68.51,69.3,70.13,71,71.91,72.88,73.9,74.97,76.1,77.29,78.53,79.82,81.16,82.55,83.98,85.46,86.98,88.54,90.14,91.78,93.45,95.16,96.9,98.67,100.47,102.3,104.16,106.03,107.93,109.85,111.79,113.74,115.71,117.67,119.63,121.59,123.53,125.45,127.36,129.23,131.07,132.88,134.64,136.35,138.01,139.61,141.15,142.62,144.01,145.33,146.56,147.7,148.75,149.7,150.56,151.34,152.03,152.65,153.21,153.7,154.14,154.53,154.88,155.19,155.48,155.74,155.98,156.21,156.44,156.67,156.91,157.16,157.44,157.74,158.07,158.44,158.86,159.32,159.82,160.35,160.92,161.53,162.17,162.83,163.53,164.24,164.98,165.75,166.53,167.32,168.13,168.96,169.79,170.63,171.48,172.33,173.18,174.03,174.88,175.73,176.57,177.41,178.26,179.12,179.99,180.87,181.76,182.67,183.6,184.56,185.54,186.55,187.6,188.67,189.79,190.94,192.14,193.38,194.67,196.02,197.41,198.87,200.37,201.94,203.55,205.2,206.88,208.61,210.35,212.12,213.91,215.71,217.51,219.32,221.12,222.92,224.7,226.46,228.2,229.91,231.59,233.23,234.82,236.36,237.86,239.29,240.66,241.98,243.25,244.46,245.62,246.72,247.78,248.78,249.73,250.64,251.5,252.31,253.07,253.79,254.46,255.09,255.68,256.22,256.73,257.19,257.62,258.01,258.36,258.67,258.95,259.2,259.42,259.61,259.78,259.92,260.03,260.13,260.2,260.26,260.3,260.33,260.34,260.34,260.33,260.32,260.3,260.27,260.25,260.22,260.19,260.17,260.15,260.13,260.11,260.09,260.08,260.07,260.06,260.06,260.05,260.05,260.05,260.05,260.06,260.07,260.08,260.09,260.1,260.12,260.14,260.16,260.18,260.21,260.24,260.27,260.3,260.34,260.37,260.41,260.45,260.5,260.54,260.59,260.64,260.69,260.74,260.8,260.86,260.92,260.98,261.04,261.11,261.17,261.24,261.31,261.39,261.46,261.54,261.61,261.69,261.77,261.84,261.92,262,262.07,262.15,262.22,262.29,262.36,262.43,262.49,262.56,262.61,262.67,262.72,262.77,262.81,262.84,262.88,262.9,262.92,262.94,262.95,262.96,262.96,262.96,262.95,262.94,262.92,262.9,262.88,262.85,262.81,262.78,262.74,262.69,262.65,262.6,262.54,262.48,262.42,262.36,262.29,262.22,262.15,262.08,262,261.91,261.83,261.74,261.65,261.55,261.45,261.34,261.23,261.12,261,260.88,260.75,260.62,260.48,260.34,260.19,260.04,259.88,259.72,259.55,259.38,259.21,259.03,258.85,258.67,258.49,258.31,258.13,257.95,257.77,257.59,257.42,257.24,257.08,256.91,256.75,256.6,256.45,256.31,256.17,256.05,255.92,255.81,255.69,255.58,255.46,255.34,255.21,255.07,254.92,254.75,254.57,254.36,254.14,253.89,253.62,253.31,252.98,252.61,252.2,251.76,251.28,250.75,250.18,249.56,248.9,248.18,247.41,246.59,245.72,244.8,243.81,242.78,241.68,240.52,239.31,238.03,236.69,235.29,233.82,232.29,230.68,229.01,227.27,225.46,223.57,221.62,219.59,217.51,215.38,213.21,211.02,208.82,206.61,204.41,202.22,200.07,197.95,195.89,193.88,191.95,190.1,188.34,186.69,185.15,183.73,182.46,181.32,180.35}', '{24.71,24.55,24.53,24.63,24.84,25.18,25.62,26.17,26.81,27.56,28.39,29.31,30.31,31.39,32.54,33.76,35.04,36.38,37.77,39.2,40.68,42.2,43.75,45.33,46.94,48.56,50.19,51.84,53.49,55.13,56.78,58.41,60.02,61.61,63.18,64.72,66.22,67.68,69.1,70.46,71.77,73.02,74.2,75.31,76.35,77.31,78.18,78.97,79.69,80.33,80.9,81.41,81.85,82.23,82.56,82.83,83.06,83.24,83.37,83.48,83.54,83.58,83.59,83.58,83.54,83.49,83.43,83.36,83.28,83.21,83.12,83.04,82.95,82.86,82.76,82.65,82.54,82.41,82.28,82.14,81.99,81.83,81.66,81.48,81.28,81.07,80.84,80.6,80.34,80.07,79.78,79.46,79.14,78.79,78.42,78.03,77.62,77.19,76.74,76.27,75.78,75.26,74.72,74.16,73.57,72.96,72.33,71.67,70.99,70.28,69.55,68.79,68,67.19,66.35,65.48,64.59,63.68,62.75,61.81,60.86,59.9,58.94,57.98,57.03,56.08,55.15,54.22,53.32,52.44,51.58,50.75,49.95,49.19,48.47,47.79,47.15,46.56,46.03,45.54,45.1,44.7,44.34,44.02,43.73,43.48,43.26,43.06,42.89,42.74,42.61,42.49,42.39,42.3,42.21,42.14,42.06,41.98,41.91,41.82,41.73,41.63,41.52,41.4,41.27,41.14,41,40.85,40.7,40.55,40.4,40.25,40.09,39.94,39.78,39.63,39.48,39.34,39.2,39.07,38.94,38.83,38.72,38.61,38.52,38.44,38.37,38.31,38.25,38.21,38.17,38.14,38.12,38.1,38.09,38.09,38.1,38.11,38.12,38.14,38.17,38.2,38.23,38.27,38.31,38.36,38.4,38.46,38.51,38.56,38.62,38.68,38.74,38.8,38.86,38.93,38.99,39.05,39.12,39.18,39.24,39.3,39.36,39.41,39.47,39.52,39.57,39.62,39.66,39.7,39.74,39.78,39.81,39.83,39.86,39.88,39.89,39.91,39.91,39.92,39.92,39.92,39.92,39.91,39.9,39.88,39.86,39.84,39.82,39.79,39.75,39.72,39.68,39.64,39.6,39.56,39.54,39.53,39.54,39.58,39.64,39.73,39.86,40.03,40.24,40.5,40.81,41.18,41.61,42.11,42.67,43.31,44.02,44.82,45.7,46.67,47.74,48.89,50.12,51.43,52.81,54.26,55.78,57.36,58.99,60.68,62.41,64.18,65.99,67.84,69.71,71.61,73.53,75.47,77.42,79.37,81.33,83.29,85.24,87.18,89.11,91.03,92.95,94.85,96.75,98.63,100.5,102.37,104.22,106.06,107.89,109.7,111.51,113.3,115.08,116.85,118.6,120.34,122.07,123.78,125.48,127.17,128.84,130.5,132.14,133.78,135.4,137.02,138.62,140.22,141.81,143.4,144.98,146.56,148.13,149.7,151.27,152.85,154.42,155.99,157.57,159.15,160.73,162.32,163.92,165.52,167.12,168.73,170.34,171.95,173.55,175.15,176.74,178.32,179.89,181.44,182.99,184.51,186.02,187.51,188.97,190.41,191.83,193.21,194.57,195.9,197.19,198.44,199.66,200.85,202,203.12,204.21,205.26,206.28,207.28,208.25,209.19,210.1,210.99,211.85,212.69,213.5,214.3,215.07,215.82,216.56,217.27,217.97,218.65,219.32,219.97,220.61,221.24,221.85,222.44,223.03,223.6,224.16,224.71,225.24,225.77,226.28,226.79,227.28,227.77,228.24,228.71,229.17,229.62,230.06,230.5,230.93,231.35,231.76,232.17,232.58,232.97,233.37,233.76,234.15,234.53,234.91,235.29,235.67,236.05,236.42,236.8,237.17,237.55,237.92,238.3,238.68,239.07,239.45,239.84}', 1, 1),
		(1466.96, 18.81, .01, '{50, 25}', '{200, 30}',  '{30, 200, 100, 410, 200}', '{150, 235, 350, 380, 30}', '{50.51, 51.04, 51.59, 52.14, 52.7, 53.27, 53.84, 54.42, 54.99, 55.56, 56.12, 56.68, 57.22, 57.75, 58.27, 58.76, 59.24, 59.69, 60.12, 60.52, 60.89, 61.23, 61.53, 61.81, 62.06, 62.29, 62.49, 62.67, 62.83, 62.97, 63.1, 63.21, 63.31, 63.4, 63.47, 63.55, 63.61, 63.67, 63.73, 63.79, 63.85, 63.91, 63.98, 64.05, 64.13, 64.21, 64.3, 64.39, 64.48, 64.58, 64.68, 64.78, 64.89, 65.0, 65.11, 65.23, 65.35, 65.47, 65.59, 65.72, 65.85, 65.98, 66.11, 66.25, 66.38, 66.5, 66.61, 66.7, 66.78, 66.83, 66.85, 66.83, 66.78, 66.69, 66.55, 66.36, 66.11, 65.81, 65.44, 65.01, 64.5, 63.92, 63.26, 62.51, 61.68, 60.77, 59.79, 58.76, 57.67, 56.53, 55.35, 54.14, 52.91, 51.66, 50.4, 49.14, 47.89, 46.65, 45.43, 44.24, 43.08, 41.97, 40.91, 39.91, 38.98, 38.11, 37.31, 36.57, 35.88, 35.26, 34.69, 34.17, 33.7, 33.28, 32.89, 32.55, 32.24, 31.97, 31.73, 31.51, 31.33, 31.16, 31.02, 30.89, 30.77, 30.67, 30.57, 30.49, 30.42, 30.35, 30.3, 30.26, 30.22, 30.2, 30.19, 30.18, 30.19, 30.21, 30.23, 30.27, 30.32, 30.37, 30.44, 30.52, 30.6, 30.7, 30.81, 30.93, 31.05, 31.18, 31.32, 31.47, 31.62, 31.78, 31.94, 32.11, 32.28, 32.45, 32.62, 32.79, 32.96, 33.13, 33.3, 33.46, 33.63, 33.79, 33.94, 34.09, 34.23, 34.36, 34.49, 34.62, 34.73, 34.84, 34.94, 35.03, 35.12, 35.2, 35.27, 35.33, 35.38, 35.42, 35.46, 35.48, 35.5, 35.5, 35.5, 35.48, 35.45, 35.42, 35.39, 35.37, 35.35, 35.35, 35.38, 35.43, 35.51, 35.64, 35.81, 36.02, 36.3, 36.63, 37.03, 37.5, 38.05, 38.68, 39.4, 40.22, 41.13, 42.15, 43.26, 44.46, 45.74, 47.1, 48.51, 49.99, 51.51, 53.07, 54.66, 56.27, 57.9, 59.53, 61.17, 62.79, 64.4, 65.98, 67.53, 69.03, 70.49, 71.88, 73.21, 74.49, 75.71, 76.88, 78.02, 79.12, 80.19, 81.23, 82.27, 83.29, 84.31, 85.33, 86.36, 87.4, 88.46, 89.55, 90.67, 91.83, 93.03, 94.29, 95.6, 96.97, 98.4, 99.88, 101.41, 103.0, 104.63, 106.3, 108.02, 109.77, 111.56, 113.38, 115.23, 117.11, 119.01, 120.93, 122.87, 124.83, 126.8, 128.78, 130.76, 132.75, 134.74, 136.74, 138.73, 140.71, 142.69, 144.66, 146.63, 148.58, 150.52, 152.44, 154.35, 156.23, 158.1, 159.94, 161.76, 163.56, 165.32, 167.05, 168.76, 170.42, 172.06, 173.65, 175.21, 176.72, 178.2, 179.63, 181.02, 182.37, 183.67, 184.93, 186.14, 187.3, 188.41, 189.47, 190.48, 191.44, 192.34, 193.19, 193.98, 194.72, 195.4, 196.01, 196.58, 197.08, 197.53, 197.94, 198.3, 198.61, 198.88, 199.12, 199.32, 199.48, 199.62, 199.73, 199.82, 199.89, 199.93, 199.97, 199.99, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 200.0, 199.99, 199.98, 199.95, 199.9, 199.84, 199.76, 199.65, 199.51, 199.34, 199.14, 198.9, 198.62, 198.29, 197.91, 197.49, 197.01, 196.47, 195.88, 195.22, 194.49, 193.7, 192.86, 191.96, 191.02, 190.03, 189.01, 187.96, 186.89, 185.8, 184.7, 183.59, 182.48, 181.37, 180.27, 179.18, 178.12, 177.08, 176.07, 175.1, 174.18, 173.3, 172.47, 171.68, 170.94, 170.25, 169.6, 168.99, 168.43, 167.9, 167.42, 166.98, 166.58, 166.22, 165.9, 165.61, 165.36, 165.15, 164.97, 164.82, 164.71, 164.63, 164.59, 164.56, 164.56, 164.58, 164.61, 164.65, 164.69, 164.74, 164.77, 164.8, 164.81, 164.79, 164.76, 164.7, 164.6, 164.46, 164.28, 164.05, 163.77, 163.43, 163.03, 162.57, 162.04, 161.44, 160.79, 160.08, 159.31, 158.48, 157.6, 156.66, 155.68, 154.64, 153.55, 152.42, 151.24, 150.01, 148.75, 147.44, 146.09, 144.71, 143.29, 141.83, 140.34, 138.82, 137.28, 135.73, 134.16, 132.58, 131.0, 129.43, 127.86, 126.31, 124.77, 123.26, 121.77, 120.32, 118.9, 117.53, 116.21, 114.94, 113.73, 112.59, 111.51, 110.5, 109.56, 108.68, 107.87, 107.12, 106.43, 105.79, 105.2, 104.66, 104.17, 103.72, 103.31, 102.94, 102.61, 102.3, 102.03, 101.79, 101.57, 101.38, 101.2, 101.04, 100.89, 100.76, 100.65, 100.55, 100.47, 100.4, 100.35, 100.31, 100.29, 100.28, 100.29, 100.31, 100.35, 100.4, 100.47, 100.56, 100.66, 100.77, 100.9, 101.05, 101.21, 101.38, 101.58, 101.79, 102.02, 102.28, 102.56, 102.86, 103.18, 103.54, 103.92, 104.33, 104.77, 105.24, 105.74, 106.28, 106.86, 107.47, 108.12, 108.81, 109.55, 110.32, 111.14, 112.0, 112.9, 113.85, 114.84, 115.87, 116.95, 118.07, 119.23, 120.44, 121.69, 122.99, 124.33, 125.71, 127.14, 128.61, 130.13, 131.69, 133.3, 134.95, 136.65, 138.39, 140.17, 141.99, 143.85, 145.74, 147.67, 149.62, 151.61, 153.62, 155.65, 157.7, 159.78, 161.87, 163.98, 166.1, 168.23, 170.36, 172.51, 174.66, 176.81, 178.96, 181.11, 183.26, 185.41, 187.55, 189.69, 191.82, 193.94, 196.06, 198.17, 200.28, 202.37, 204.45, 206.52, 208.58, 210.63, 212.66, 214.68, 216.68, 218.67, 220.63, 222.59, 224.52, 226.43, 228.32, 230.19, 232.04, 233.87, 235.67, 237.44, 239.19, 240.92, 242.61, 244.28, 245.92, 247.53, 249.1, 250.65, 252.16, 253.64, 255.08, 256.49, 257.87, 259.2, 260.51, 261.79, 263.04, 264.26, 265.46, 266.64, 267.8, 268.94, 270.07, 271.18, 272.28, 273.37, 274.46, 275.54, 276.61, 277.69, 278.76, 279.84, 280.92, 282.01, 283.1, 284.2, 285.3, 286.39, 287.49, 288.58, 289.67, 290.74, 291.81, 292.87, 293.92, 294.95, 295.97, 296.97, 297.95, 298.91, 299.85, 300.76, 301.65, 302.51, 303.35, 304.16, 304.94, 305.7, 306.43, 307.14, 307.84, 308.51, 309.17, 309.81, 310.43, 311.05, 311.65, 312.23, 312.81, 313.38, 313.95, 314.5, 315.06, 315.6, 316.15, 316.7, 317.25, 317.81, 318.37, 318.94, 319.53, 320.13, 320.75, 321.39, 322.05, 322.75, 323.46, 324.21, 325.0, 325.82, 326.68, 327.58, 328.53, 329.52, 330.56, 331.65, 332.8, 333.99, 335.23, 336.5, 337.82, 339.16, 340.53, 341.93, 343.35, 344.78, 346.22, 347.68, 349.14, 350.6, 352.05, 353.5, 354.94, 356.36, 357.77, 359.15, 360.51, 361.84, 363.14, 364.42, 365.69, 366.93, 368.16, 369.38, 370.58, 371.78, 372.97, 374.15, 375.34, 376.52, 377.71, 378.9, 380.09, 381.3, 382.52, 383.75, 385.0, 386.26, 387.54, 388.83, 390.13, 391.43, 392.72, 394.0, 395.28, 396.53, 397.77, 398.97, 400.14, 401.28, 402.38, 403.43, 404.43, 405.37, 406.26, 407.07, 407.82, 408.5, 409.1, 409.62, 410.07, 410.45, 410.77, 411.03, 411.23, 411.38, 411.49, 411.56, 411.58, 411.58, 411.55, 411.49, 411.41, 411.31, 411.21, 411.09, 410.97, 410.86, 410.75, 410.64, 410.55, 410.47, 410.4, 410.34, 410.29, 410.25, 410.22, 410.2, 410.19, 410.19, 410.2, 410.22, 410.25, 410.29, 410.34, 410.4, 410.47, 410.55, 410.64, 410.74, 410.85, 410.97, 411.08, 411.2, 411.31, 411.4, 411.48, 411.54, 411.58, 411.58, 411.56, 411.5, 411.39, 411.24, 411.04, 410.78, 410.47, 410.09, 409.65, 409.13, 408.54, 407.87, 407.12, 406.31, 405.43, 404.49, 403.49, 402.44, 401.35, 400.22, 399.04, 397.84, 396.61, 395.36, 394.08, 392.8, 391.51, 390.21, 388.91, 387.62, 386.34, 385.07, 383.83, 382.59, 381.38, 380.17, 378.97, 377.78, 376.59, 375.41, 374.23, 373.04, 371.85, 
						370.66, 369.45, 368.24, 367.01, 365.76, 364.5, 363.22, 361.92, 360.59, 359.24, 357.85, 356.45, 355.03, 353.6, 352.16, 350.71, 349.27, 347.83, 346.4, 344.98, 343.58, 342.21, 340.86, 339.55, 338.27, 337.04, 335.85, 334.71, 333.62, 332.59, 331.63, 330.73, 329.9, 329.12, 328.4, 327.73, 327.11, 326.54, 326.01, 325.52, 325.07, 324.65, 324.26, 323.9, 323.56, 323.25, 322.95, 322.67, 322.4, 322.13, 321.88, 321.62, 321.37, 321.12, 320.87, 320.63, 320.39, 320.15, 319.92, 319.7, 319.48, 319.27, 319.06, 318.87, 318.68, 318.51, 318.34, 318.18, 318.04, 317.9, 317.78, 317.68, 317.58, 317.5, 317.44, 317.38, 317.34, 317.31, 317.28, 317.26, 317.26, 317.25, 317.26, 317.26, 317.28, 317.29, 317.31, 317.33, 317.35, 317.37, 317.38, 317.4, 317.41, 317.42, 317.42, 317.42, 317.42, 317.41, 317.4, 317.39, 317.37, 317.35, 317.33, 317.3, 317.27, 317.24, 317.21, 317.17, 317.13, 317.09, 317.05, 317.01, 316.96, 316.92, 316.87, 316.82, 316.76, 316.7, 316.63, 316.54, 316.44, 316.32, 316.18, 316.03, 315.84, 315.63, 315.39, 315.12, 314.82, 314.48, 314.1, 313.69, 313.22, 312.72, 312.17, 311.56, 310.91, 310.22, 309.49, 308.72, 307.92, 307.09, 306.23, 305.35, 304.45, 303.53, 302.61, 301.67, 300.73, 299.78, 298.84, 297.9, 296.97, 296.05, 295.14, 294.25, 293.39, 292.54, 291.71, 290.91, 290.12, 289.36, 288.61, 287.88, 287.16, 286.46, 285.78, 285.12, 284.47, 283.83, 283.21, 282.6, 282.01, 281.42, 280.85, 280.29, 279.75, 279.21, 278.68, 278.16, 277.65, 277.14, 276.65, 276.16, 275.67, 275.19, 274.71, 274.24, 273.77, 273.3, 272.84, 272.37, 271.9, 271.43, 270.96, 270.49, 270.02, 269.54, 269.06, 268.57, 268.08, 267.58, 267.07, 266.56, 266.03, 265.5, 264.96, 264.42, 263.86, 263.28, 262.7, 262.11, 261.5, 260.88, 260.25, 259.6, 258.93, 258.25, 257.55, 256.84, 256.1, 255.33, 254.54, 253.7, 252.83, 251.91, 250.94, 249.91, 248.83, 247.69, 246.48, 245.19, 243.83, 242.39, 240.86, 239.25, 237.54, 235.73, 233.82, 231.8, 229.69, 227.49, 225.24, 222.96, 220.66, 218.38, 216.12, 213.93, 211.81, 209.78, 207.88, 206.12, 204.53, 203.12, 201.92, 200.95, 200.23, 199.79, 199.65, 199.82}', '{25.94, 26.94, 27.99, 29.1, 30.25, 31.45, 32.69, 33.96, 35.25, 36.58, 37.93, 39.29, 40.66, 42.05, 43.43, 44.82, 46.2, 47.57, 48.92, 50.26, 51.57, 52.86, 54.12, 55.36, 56.58, 57.79, 58.97, 60.15, 61.31, 62.46, 63.61, 64.75, 65.89, 67.02, 68.16, 69.31, 70.46, 71.62, 72.79, 73.97, 75.17, 76.38, 77.62, 78.87, 80.13, 81.41, 82.7, 84.0, 85.3, 86.61, 87.93, 89.24, 90.56, 91.87, 93.18, 94.48, 95.78, 97.06, 98.33, 99.59, 100.84, 102.06, 103.27, 104.45, 105.62, 106.77, 107.9, 109.02, 110.13, 111.22, 112.31, 113.39, 114.46, 115.53, 116.6, 117.67, 118.74, 119.81, 120.88, 121.96, 123.04, 124.14, 125.25, 126.36, 127.49, 128.63, 129.77, 130.92, 132.06, 133.19, 134.31, 135.42, 136.51, 137.58, 138.63, 139.65, 140.63, 141.58, 142.49, 143.36, 144.18, 144.95, 145.67, 146.33, 146.92, 147.46, 147.94, 148.37, 148.74, 149.06, 149.34, 149.58, 149.77, 149.93, 150.06, 150.16, 150.23, 150.28, 150.3, 150.31, 150.31, 150.29, 150.27, 150.24, 150.21, 150.18, 150.16, 150.13, 150.11, 150.1, 150.08, 150.07, 150.06, 150.05, 150.05, 150.05, 150.05, 150.06, 150.06, 150.07, 150.09, 150.1, 150.12, 150.14, 150.17, 150.19, 150.22, 150.26, 150.3, 150.36, 150.43, 150.53, 150.65, 150.8, 150.98, 151.2, 151.46, 151.76, 152.12, 152.52, 152.98, 153.5, 154.08, 154.73, 155.45, 156.25, 157.13, 158.08, 159.12, 160.24, 161.42, 162.68, 163.99, 165.37, 166.8, 168.27, 169.8, 171.36, 172.97, 174.6, 176.26, 177.95, 179.66, 181.38, 183.12, 184.86, 186.6, 188.34, 190.08, 191.8, 193.51, 195.21, 196.88, 198.53, 200.14, 201.73, 203.28, 204.79, 206.25, 207.67, 209.03, 210.34, 211.59, 212.78, 213.9, 214.94, 215.92, 216.81, 217.63, 218.35, 219.0, 219.57, 220.07, 220.5, 220.86, 221.17, 221.41, 221.61, 221.76, 221.87, 221.94, 221.98, 221.98, 221.96, 221.92, 221.86, 221.79, 221.72, 221.63, 221.55, 221.48, 221.4, 221.33, 221.27, 221.21, 221.15, 221.1, 221.05, 221.01, 220.97, 220.93, 220.9, 220.88, 220.85, 220.84, 220.82, 220.82, 220.81, 220.81, 220.82, 220.83, 220.84, 220.86, 220.88, 220.91, 220.94, 220.97, 221.01, 221.05, 221.09, 221.14, 221.19, 221.24, 221.29, 221.35, 221.41, 221.47, 221.53, 221.6, 221.66, 221.73, 221.79, 221.86, 221.93, 222.0, 222.07, 222.13, 222.2, 222.27, 222.34, 222.4, 222.46, 222.53, 222.59, 222.64, 222.7, 222.75, 222.8, 222.85, 222.89, 222.93, 222.96, 222.99, 223.02, 223.04, 223.07, 223.09, 223.12, 223.15, 223.19, 223.24, 223.29, 223.35, 223.43, 223.52, 223.62, 223.75, 223.88, 224.04, 224.22, 224.43, 224.66, 224.91, 225.19, 225.5, 225.83, 226.18, 226.56, 226.95, 227.35, 227.76, 228.18, 228.61, 229.04, 229.47, 229.89, 230.31, 230.73, 231.13, 231.52, 231.89, 232.25, 232.58, 232.89, 233.18, 233.43, 233.66, 233.86, 234.04, 234.18, 234.3, 234.39, 234.45, 234.49, 234.5, 234.48, 234.43, 234.36, 234.26, 234.13, 233.97, 233.79, 233.57, 233.33, 233.07, 232.77, 232.45, 232.12, 231.76, 231.4, 231.04, 230.67, 230.31, 229.95, 229.62, 229.3, 229.0, 228.73, 228.5, 228.3, 228.15, 228.04, 227.99, 227.99, 228.05, 228.18, 228.39, 228.66, 229.0, 229.42, 229.9, 230.46, 231.09, 231.78, 232.55, 233.38, 234.28, 235.25, 236.29, 237.39, 238.56, 239.8, 241.11, 242.48, 243.91, 245.41, 246.98, 248.61, 250.3, 252.04, 253.84, 255.67, 257.55, 259.46, 261.39, 263.35, 265.33, 267.32, 269.32, 271.32, 273.32, 275.31, 277.28, 279.24, 281.17, 283.08, 284.95, 286.78, 288.56, 290.31, 292.01, 293.67, 295.29, 296.87, 298.4, 299.9, 301.37, 302.79, 304.18, 305.54, 306.85, 308.14, 309.39, 310.61, 311.8, 312.96, 314.09, 315.19, 316.26, 317.31, 318.33, 319.32, 320.29, 321.24, 322.16, 323.06, 323.95, 324.82, 325.67, 326.5, 327.32, 328.12, 328.91, 329.69, 330.46, 331.22, 331.97, 332.71, 333.45, 334.18, 334.91, 335.63, 336.35, 337.05, 337.75, 338.43, 339.11, 339.77, 340.42, 341.05, 341.66, 342.26, 342.83, 343.39, 343.92, 344.44, 344.92, 345.39, 345.82, 346.23, 346.61, 346.96, 347.28, 347.58, 347.85, 348.09, 348.32, 348.52, 348.7, 348.86, 349.01, 349.14, 349.25, 349.35, 349.43, 349.51, 349.57, 349.63, 349.68, 349.72, 349.75, 349.79, 349.82, 349.84, 349.87, 349.89, 349.9, 349.92, 349.93, 349.94, 349.94, 349.94, 349.94, 349.94, 349.93, 349.92, 349.9, 349.89, 349.87, 349.84, 349.82, 349.79, 349.75, 349.72, 349.68, 349.64, 349.59, 349.54, 349.5, 349.44, 349.39, 349.33, 349.28, 349.22, 349.15, 349.09, 349.03, 348.96, 348.89, 348.83, 348.76, 348.69, 348.62, 348.54, 348.47, 348.4, 348.33, 348.25, 348.18, 348.11, 348.03, 347.96, 347.89, 347.82, 347.74, 347.67, 347.6, 347.53, 347.46, 347.39, 347.32, 347.25, 347.19, 347.12, 347.06, 346.99, 346.93, 346.87, 346.8, 346.74, 346.67, 346.59, 346.52, 346.44, 346.35, 346.26, 346.17, 346.06, 345.95, 345.83, 345.7, 345.57, 345.42, 345.26, 345.1, 344.92, 344.72, 344.52, 344.31, 
						344.1, 343.87, 343.64, 343.41, 343.17, 342.93, 342.68, 342.44, 342.19, 341.95, 341.71, 341.48, 341.24, 341.02, 340.8, 340.59, 340.38, 340.19, 340.0, 339.81, 339.61, 339.41, 339.19, 338.96, 338.7, 338.41, 338.09, 337.73, 337.33, 336.89, 336.39, 335.84, 335.22, 334.54, 333.79, 332.97, 332.06, 331.07, 329.99, 328.84, 327.61, 326.32, 324.97, 323.57, 322.13, 320.66, 319.17, 317.66, 316.14, 314.62, 313.1, 311.6, 310.12, 308.68, 307.27, 305.91, 304.6, 303.36, 302.19, 301.09, 300.07, 299.12, 298.25, 297.44, 296.72, 296.06, 295.47, 294.95, 294.5, 294.12, 293.8, 293.55, 293.36, 293.24, 293.17, 293.17, 293.24, 293.36, 293.54, 293.78, 294.07, 294.42, 294.82, 295.28, 295.78, 296.33, 296.93, 297.57, 298.25, 298.97, 299.72, 300.52, 301.34, 302.2, 303.09, 304.01, 304.95, 305.92, 306.91, 307.92, 308.94, 309.99, 311.05, 312.12, 313.21, 314.3, 315.41, 316.52, 317.64, 318.77, 319.9, 321.03, 322.16, 323.29, 324.42, 325.54, 326.66, 327.78, 328.88, 329.97, 331.06, 332.13, 333.19, 334.23, 335.26, 336.28, 337.28, 338.27, 339.24, 340.2, 341.14, 342.07, 342.98, 343.87, 344.75, 345.61, 346.46, 347.29, 348.1, 348.89, 349.67, 350.43, 351.17, 351.89, 352.59, 353.29, 353.96, 354.63, 355.28, 355.92, 356.56, 357.18, 357.8, 358.41, 359.02, 359.62, 360.22, 360.82, 361.42, 362.03, 362.63, 363.24, 363.85, 364.47, 365.09, 365.72, 366.35, 366.97, 367.6, 368.23, 368.84, 369.46, 370.06, 370.66, 371.24, 371.82, 372.37, 372.92, 373.44, 373.94, 374.43, 374.89, 375.33, 375.74, 376.12, 376.48, 376.81, 377.12, 377.4, 377.67, 377.91, 378.13, 378.33, 378.51, 378.67, 378.82, 378.96, 379.08, 379.19, 379.28, 379.37, 379.45, 379.52, 379.58, 379.63, 379.68, 379.73, 379.77, 379.8, 379.83, 379.86, 379.88, 379.89, 379.9, 379.91, 379.91, 379.9, 379.89, 379.88, 379.86, 379.83, 379.81, 379.77, 379.73, 379.69, 379.64, 379.58, 379.52, 379.45, 379.38, 379.29, 379.19, 379.09, 378.97, 378.83, 378.68, 378.52, 378.34, 378.14, 377.92, 377.68, 377.42, 377.14, 376.83, 376.5, 376.15, 375.76, 375.35, 374.92, 374.46, 373.97, 373.47, 372.95, 372.41, 371.85, 371.28, 370.7, 370.1, 369.5, 368.88, 368.26, 367.64, 367.01, 366.38, 365.76, 365.13, 364.51, 363.89, 363.27, 362.67, 362.06, 361.46, 360.86, 360.26, 359.66, 359.05, 358.45, 357.84, 357.22, 356.59, 355.96, 355.32, 354.67, 354.0, 353.33, 352.64, 351.93, 351.21, 350.47, 349.72, 348.94, 348.15, 347.35, 346.53, 345.7, 344.86, 344.01, 343.15, 342.29, 341.41, 340.53, 339.65, 338.77, 337.88, 336.99, 336.1, 335.21, 334.33, 333.45, 332.57, 331.7, 330.82, 329.95, 329.07, 328.17, 327.27, 326.34, 325.39, 324.42, 323.42, 322.39, 321.32, 320.22, 319.07, 317.87, 316.63, 315.33, 313.97, 312.56, 311.07, 309.53, 307.91, 306.23, 304.5, 302.71, 300.88, 299.01, 297.1, 295.16, 293.19, 291.21, 289.2, 287.19, 285.17, 283.15, 281.14, 279.14, 277.15, 275.18, 273.24, 271.32, 269.44, 267.6, 265.79, 264.01, 262.26, 260.53, 258.83, 257.14, 255.47, 253.81, 252.16, 250.52, 248.88, 247.25, 245.61, 243.97, 242.33, 240.67, 239.01, 237.32, 235.62, 233.9, 232.16, 230.4, 228.63, 226.84, 225.03, 223.22, 221.4, 219.56, 217.73, 215.89, 214.04, 212.2, 210.36, 208.52, 206.68, 204.85, 203.03, 201.22, 199.43, 197.64, 195.87, 194.12, 192.39, 190.68, 188.99, 187.32, 185.68, 184.07, 182.48, 180.92, 179.4, 177.9, 176.45, 175.03, 173.64, 172.3, 170.99, 169.73, 168.52, 167.35, 166.22, 165.15, 164.12, 163.14, 162.2, 161.3, 160.44, 159.61, 158.82, 158.05, 157.32, 156.62, 155.94, 155.28, 154.64, 154.02, 153.41, 152.82, 152.24, 151.67, 151.1, 150.54, 149.99, 149.43, 148.86, 148.29, 147.71, 147.11, 146.5, 145.86, 145.2, 144.52, 143.8, 143.04, 142.25, 141.42, 140.55, 139.62, 138.65, 137.62, 136.53, 135.39, 134.18, 132.9, 131.56, 130.16, 128.7, 127.19, 125.62, 124.01, 122.35, 120.65, 118.91, 117.14, 115.33, 113.49, 111.63, 109.74, 107.83, 105.91, 103.96, 102.01, 100.05, 98.08, 96.11, 94.14, 92.18, 90.22, 88.27, 86.33, 84.4, 82.49, 80.61, 78.74, 76.91, 75.1, 73.32, 71.58, 69.88, 68.21, 66.59, 65.02, 63.49, 62.02, 60.6, 59.24, 57.93, 56.67, 55.46, 54.3, 53.18, 52.1, 51.07, 50.07, 49.11, 48.19, 47.29, 46.43, 45.59, 44.78, 43.99, 43.22, 42.48, 41.74, 41.02, 40.32, 39.62, 38.94, 38.27, 37.62, 36.98, 36.36, 35.76, 35.17, 34.61, 34.07, 33.55, 33.06, 32.59, 32.15, 31.73, 31.34, 30.99, 30.66, 30.36, 30.1}', 1, 1);
		
		
insert into trajectory_tb ("path_distance",	"path_time", "start", "destination", "x_waypoints", "y_waypoints")
	values (822.46, 13.71, '{50.0, 25.0}', '{300.0,290.0}', '{150.0,60.0,80.0,160.0,300.0}', '{90.0,180.0,290.0,380.0,290.0}'),
		(880.81, 14.68, '{50.0, 25.0}', '{450.0,50.0}', '{40.0,130.0,260.0,440.0,450.0}', '{140.0,180.0,275.0,210.0,50.0}'),
		(835.1, 13.92, '{50.0, 25.0}', '{390.0,370.0}', '{150.0,260.0,300.0,350.0,400.0,390.0}', '{90.0,40.0,60.0,155.0,240.0,370.0}'),
		(872.6, 14.54, '{50.0, 25.0}', '{450.0,50.0}', '{40.0,80.0,450.0}', '{140.0,290.0,50.0}'),
		(863.19, 14.39, '{50.0, 25.0}', '{260.0,140.0}', '{110.0,200.0,300.0,325.0,260.0}', '{240.0,360.0,290.0,160.0,140.0}'),
		(827.56, 13.79, '{50.0, 25.0}', '{300.0,290.0}', '{260.0,160.0,300.0}', '{140.0,380.0,290.0}'),
		(788.08, 13.13, '{50.0, 25.0}', '{200.0,360.0}', '{150.0,260.0,350.0,325.0,200.0}', '{90.0,40.0,155.0,300.0,360.0}'),
		(818.69, 13.64, '{50.0, 25.0}', '{160.0,380.0}', '{325.0,400.0,160.0}', '{160.0,240.0,380.0}'),
		(718.69, 11.98, '{50.0,25.0}', '{75.0,290.0}', '{140.0,340.0,75.0}', '{90.0,155.0,290.0}'),
		(733.18, 12.22, '{50.0,25.0}', '{320.0,160.0}', '{220.0,320.0}', '{360.0,160.0}'),
		(684.51, 11.41, '{50.0,25.0}', '{435.0,210.0}', '{140.0,250.0,295.0,260.0,390.0,435.0}', '{90.0,40.0,60.0,140.0,240.0,210.0}'),
		(715.58, 11.93, '{50.0,25.0}', '{220.0,360.0}', '{140.0,250.0,295.0,260.0,220.0}', '{90.0,40.0,60.0,140.0,360.0}'),
		(692.82, 11.55, '{50.0,25.0}', '{100.0,350.0}', '{290.0,220.0,140.0,100.0}', '{290.0,360.0,380.0,350.0}'),
		(747.00, 12.45, '{50.0,25.0}', '{440.0,50.0}', '{40.0,340.0,435.0,440.0}', '{140.0,155.0,210.0,50.0}'),
		(733.78, 12.23, '{50.0,25.0}', '{320.0,160.0}', '{125.0,75.0,320.0}', '{180.0,290.0,160.0}'),
		(768.45, 12.81, '{50.0,25.0}', '{100.0,350.0}', '{295.0,190.0,100.0}', '{60.0,360.0,350.0}');


-- add the example group
insert into group_tb ("info") 
	values ('examaple');

-- show a listing of tables
select * from pg_catalog.pg_tables
    where schemaname = 'public';

-- show the asset type table
select * from asset_type_tb;

-- show the process type table
select * from process_type_tb;

-- show the uav table
select * from uav_tb;

select 'setup_default.sql script is complete, a couple of tables were displayed for satisfaction.';




