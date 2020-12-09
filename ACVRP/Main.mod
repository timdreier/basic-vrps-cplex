/*********************************************
 * OPL 12.10.0.0 Model
 * Author: tim
 * Creation Date: 23.10.2020 at 15:02:24
 *********************************************/
 
 {int}			emptySet;	//Helper to create empty sets in ILOG Script
 tuple			tour {		//Subtour with set of customers
   	{int}		customers;
  };
  {tour}		solution;	//Set of tours to store the result

 main {
	writeln("############################################");
	writeln("Bin packing problem");
	writeln("############################################");

	var settings = new IloOplDataSource("settings.dat");
	var bpp_data = new IloOplDataSource("BPP.dat");
	
	var bpp_model = new IloOplModelSource("BPP.mod");
 		  	
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
  	
  	var bpp_loesung = new IloOplDataElements();
  	bpp_loesung.K = bpp_cplex.getObjValue();
  	
  	writeln("");
  	writeln("############################################");
	writeln("Asymmetric vehicle routing problem");
	writeln("############################################");
	
	var acvrp_data = new IloOplDataSource("ACVRP.dat");
  	var acvrp_daten = new IloOplModelSource("ACVRP.mod");
 		  	
  	var acvrp_cplex = new IloCplex();
  	var acvrp_def = new IloOplModelDefinition(acvrp_daten);
  	var acvrp_opl = new IloOplModel(acvrp_def,acvrp_cplex);
  	
  	acvrp_opl.addDataSource(settings);
  	acvrp_opl.addDataSource(bpp_loesung);
  	acvrp_opl.addDataSource(acvrp_data);
  	
  	acvrp_opl.generate();
  	
  	writeln("--------------------------------------------");
  	writeln("Search Solution...")
  	writeln("--------------------------------------------");
  	
  	writeln(acvrp_opl.V.size + " nodes loaded (thereof 1 depot).\n");
  	
  	
  	if (acvrp_cplex.solve()) {
  	  	writeln("--------------------------------------------");
  	  	writeln("Found solution!");
  	  	writeln("--------------------------------------------");
    	writeln("Required time: " + acvrp_cplex.getSolvedTime());
  	}  else {
  	  	writeln("--------------------------------------------");
    	writeln("No solution found for ACVRP!");
    	writeln("--------------------------------------------");
  	}
  	  	
  	var x = acvrp_opl.x;
  	thisOplModel.generate();
  	
  	function nextNode(currentNode, tour){
  	  tour.add(currentNode);
  	  for(var i = 0; i < x[currentNode].size; i++) {
  	    if (x[currentNode][i] == 1) {
  	     	if (i != 0) {
        		tour = nextNode(i, tour);
        		return tour;
  	     	}
  	     	else {
  	     	  return tour;
  	     	}
  	    }
  	  }
  	}
  	
  	for(var i = 0; i < x[0].size; i++){
  		if (x[0][i] == 1) {
  		  var tour = Opl.operatorUNION(thisOplModel.emptySet,thisOplModel.emptySet);
  		  tour.add(0);
  		  tour = nextNode(i, tour);
  		  thisOplModel.solution.add(tour)
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
  		  write("[" + acvrp_opl.coordinates[j][0] + "," + acvrp_opl.coordinates[j][1] + "],");
  		}
  		write("[" + acvrp_opl.coordinates[Opl.first(i.customers)][0] + "," + acvrp_opl.coordinates[Opl.first(i.customers)][1] + "]");
  		
  		if(Opl.last(thisOplModel.solution) != i){
  		  writeln("],");
  		} else {
  		  writeln("]");
  		}
  	}
  	writeln("]");
 }
 