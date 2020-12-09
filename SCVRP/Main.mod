/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 23.10.2020 at 15:02:24
 *********************************************/
 
 {int}		emptySet;		//Helper to create empty sets in ILOG Script
 tuple		tour {			//Subtour with set of customers
   	{int}		customers;
 };
 {tour}		solution;		//Set of tours to store the result
 {int} 		K;				//Set of vehicles

 main {
	writeln("############################################");
	writeln("Bin packing problem");
	writeln("############################################");

	var settings = new IloOplDataSource("settings.dat"); 
   
	var bpp_daten = new IloOplModelSource("BPP.mod");
 	var bpp_data = new IloOplDataSource("BPP.dat");
 		  	
  	var bpp_cplex = new IloCplex();
  	var bpp_def = new IloOplModelDefinition(bpp_daten);
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
	writeln("Symmetric vehicle routing problem");
	writeln("############################################");
	
  	var scvrp_daten = new IloOplModelSource("SCVRP.mod");
 	var scvrp_data = new IloOplDataSource("SCVRP.dat");
 		  	
  	var scvrp_cplex = new IloCplex();
  	var scvrp_def = new IloOplModelDefinition(scvrp_daten);
  	var scvrp_opl = new IloOplModel(scvrp_def,scvrp_cplex);
  	
  	scvrp_opl.addDataSource(settings);
  	scvrp_opl.addDataSource(bpp_solution);
  	scvrp_opl.addDataSource(scvrp_data);
  	
  	scvrp_opl.generate();
  	
  	writeln("--------------------------------------------");
  	writeln("Search Solution...")
  	writeln("--------------------------------------------");
  	
  	writeln(scvrp_opl.V.size + " nodes loaded (thereof 1 depot).\n");
  	
  	if (scvrp_cplex.solve()) {
    	writeln("--------------------------------------------");
  	  	writeln("Found solution!");
  	  	writeln("--------------------------------------------");
    	writeln("Required time: " + scvrp_cplex.getSolvedTime());
  	}  else {
    	wwriteln("--------------------------------------------");
    	writeln("No solution found for SCVRP!");
    	writeln("--------------------------------------------");
  	}
  	  	
  	var x = scvrp_opl.x;
  	
  	function nextNode(currentNode, tour, k){
  	  tour.add(currentNode);
  	  for(var i = 0; i < x[currentNode].size; i++) {
  	    if (x[currentNode][i][k] == 1) {
  	     	if (i != 0) {
        		tour = nextNode(i, tour, k);
        		return tour;
  	     	}
  	     	else {
  	     	  return tour;
  	     	}
  	    }
  	  }
  	}
  	
  	for(var i = 0; i < x[0].size; i++){
  		for(var k in scvrp_opl.K) {
	  		if (x[0][i][k] == 1) {
	  		  var tour = Opl.operatorUNION(thisOplModel.emptySet,thisOplModel.emptySet);
	  		  tour.add(0);
	  		  tour = nextNode(i, tour, k);
	  		  thisOplModel.solution.add(tour)
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
  	writeln("JSON-Output: ");
  	writeln("--------------------------------------------");
  	writeln("[");
  	for(var i in thisOplModel.solution) {
  	  	write("[");
  		for (var j in i.customers) {
  		  write("[" + scvrp_opl.coordinates[j][0] + "," + scvrp_opl.coordinates[j][1] + "],");
  		}
  		write("[" + scvrp_opl.coordinates[Opl.first(i.customers)][0] + "," + scvrp_opl.coordinates[Opl.first(i.customers)][1] + "]");
  		
  		if(Opl.last(thisOplModel.solution) != i){
  		  writeln("],");
  		} else {
  		  writeln("]");
  		}
  	}
  	writeln("]");
 }
 