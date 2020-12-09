/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 23.10.2020 at 15:02:24
 *********************************************/
 
 {int}		K;				//Set of vehicles
 {int}		emptySet;		//Helper to create empty sets in ILOG Script
 tuple			tour {		//Subtour with set of customers
   	{int}		customers;
 };
 {tour}		solution;		//Set of tours to store the result

 main {
	writeln("############################################");
	writeln("Bin packing problem");
	writeln("############################################");

	var settings = new IloOplDataSource("settings.dat"); 
   
	var bpp_model = new IloOplModelSource("BPP.mod");
 	var bpp_data = new IloOplDataSource("BPP.dat");
 		  	
  	var bpp_cplex = new IloCplex();
  	var bpp_def = new IloOplModelDefinition(bpp_model);
  	var bpp_opl = new IloOplModel(bpp_def,bpp_cplex);
  	
  	bpp_opl.addDataSource(settings);
  	bpp_opl.addDataSource(bpp_data);
  	
  	bpp_opl.generate();
  	if (bpp_cplex.solve()) {
    	writeln("Required number of vehicles (BPP): " + bpp_cplex.getObjValue());
  	}  else {
    	writeln("No solution found for BPP!");
  	}
  	
  	thisOplModel.generate();
  	for (var i = 1; i <= bpp_cplex.getObjValue(); i++) {
  		thisOplModel.K.add(i);
  	}
  	
  	var bpp_solution = new IloOplDataElements();
  	bpp_solution.K = thisOplModel.K;
  	  	
  	writeln("");
  	writeln("############################################");
	writeln("Multi depot vehicle routing problem");
	writeln("############################################");
	
  	var mdvrp_model = new IloOplModelSource("MDVRP.mod");
 	var mdvrp_data = new IloOplDataSource("MDVRP.dat");
 		  	
  	var mdvrp_cplex = new IloCplex();
  	var mdvrp_def = new IloOplModelDefinition(mdvrp_model);
  	var mdvrp_opl = new IloOplModel(mdvrp_def,mdvrp_cplex);
  	
  	mdvrp_opl.addDataSource(settings);
  	mdvrp_opl.addDataSource(bpp_solution);
  	mdvrp_opl.addDataSource(mdvrp_data);
  	 
  	mdvrp_opl.generate(); 
  	  	
  	writeln("--------------------------------------------");
  	writeln("Search solution...")
  	writeln("--------------------------------------------");
  	writeln(mdvrp_opl.V.size + " nodes loaded (thereof " + mdvrp_opl.M + " depots).\n");
  	
  	if (mdvrp_cplex.solve()) {
  	  	writeln("--------------------------------------------");
  	  	writeln("Found solution!");
  	  	writeln("--------------------------------------------");
    	writeln("Required time: " + mdvrp_cplex.getSolvedTime());
  	}  else {
  	  	writeln("--------------------------------------------");
    	writeln("No solution found for ACVRP!");
    	writeln("--------------------------------------------");
  	}
  	  	
  	var x = mdvrp_opl.x;
  	
  	function nextNode(currentNode, tour, vehicle, depot){
  	  tour.add(currentNode);
  	  for(var i = 1; i <= x[currentNode].size; i++) {
  	    if (x[currentNode][i][vehicle] == 1) {
  	     	if (i != depot) {
        		tour = nextNode(i, tour, vehicle, depot);
        		return tour;
  	     	}
  	     	else {
  	     	  return tour;
  	     	}
  	    }
  	  }
  	}
  	
  	for(var i = mdvrp_opl.N + 1; i <= x.size; i++) {
    	for(var j = 1; j <= mdvrp_opl.K.size; j++) {
    	  for(var l = 1; l <= x[i].size; l++) {
    	  	if(x[i][l][j] == 1) {
    	  		var tour = Opl.operatorUNION(thisOplModel.emptySet,thisOplModel.emptySet);
  		  		tour = nextNode(i, tour, j, i);
  		  		thisOplModel.solution.add(tour)
    	  	}
    	  }
    	}
    }  	
  	
  	writeln("");
  	writeln("--------------------------------------------");
  	writeln("Generated tours: ");
  	writeln("--------------------------------------------");
  	writeln(thisOplModel.solution);
  	
  	writeln("");
  	writeln("--------------------------------------------");
  	writeln("JSON-Output: ")
  	writeln("--------------------------------------------");
  	writeln("[");
  	for(var i in thisOplModel.solution) {
  	  	write("[");
  		for (var j in i.customers) {
  		  write("[" + mdvrp_opl.coordinates[j][0] + "," + mdvrp_opl.coordinates[j][1] + "],");
  		}
  		write("[" + mdvrp_opl.coordinates[Opl.first(i.customers)][0] + "," + mdvrp_opl.coordinates[Opl.first(i.customers)][1] + "]");
  		
  		if(Opl.last(thisOplModel.solution) != i){
  		  writeln("],");
  		} else {
  		  writeln("]");
  		}
  	}
  	writeln("]");
 }
